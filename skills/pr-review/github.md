# GitHub commands for pr-review

`gh api` fills `{owner}` and `{repo}` from the current repo. Replace `<n>` with the PR
number.

## Load the context

```sh
gh pr view <n> --json title,body,author,url,baseRefName,baseRefOid,headRefOid,closingIssuesReferences
gh pr checks <n>
gh pr diff <n>
```

Check out the head commit in a separate worktree. The pull ref also exists for a PR from
a fork.

```sh
wt="$(mktemp -d)/pr-<n>"
git fetch origin "pull/<n>/head"
git worktree add --detach "$wt" FETCH_HEAD
```

Remove it after you post: `git worktree remove "$wt"`.

The review threads, with the thread id, the resolved state, and the comment ids:

```sh
gh api graphql -F owner='{owner}' -F repo='{repo}' -F n=<n> -f query='
query($owner: String!, $repo: String!, $n: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $n) {
      reviewThreads(first: 100) {
        nodes {
          id isResolved isOutdated path line
          comments(first: 50) { nodes { databaseId author { login } body } }
        }
      }
    }
  }
}'
```

The summary comment from an earlier run:

```sh
gh api 'repos/{owner}/{repo}/issues/<n>/comments' --paginate \
  --jq '.[] | select(.body | startswith("<!-- pr-review:summary")) | {id, body}'
```

## Post the review

Put all inline findings in one review. Build `review.json` with `jq`, so that quotes and
newlines in the bodies are escaped:

```sh
jq -n --arg sha '<head sha>' --rawfile f1 finding-1.md '{
  commit_id: $sha,
  event: "COMMENT",
  body: "pr-review: see the summary comment.",
  comments: [
    { path: "app/src/main/kotlin/Api.kt", line: 42, side: "RIGHT", body: $f1 }
  ]
}' > review.json
gh api 'repos/{owner}/{repo}/pulls/<n>/reviews' --input review.json
```

For a finding over several lines, add `start_line` and `start_side: "RIGHT"`. A
suggestion block replaces the lines from `start_line` to `line`:

~~~markdown
```suggestion
<the replacement lines>
```
~~~

If GitHub answers `422` about a line, that line is outside the diff hunks. Compare the
line number with `gh pr diff`.

## Reply and resolve

Reply to the first comment of the thread, with its `databaseId` from the thread query.
GitHub refuses a reply to a reply.

```sh
gh api 'repos/{owner}/{repo}/pulls/<n>/comments/<databaseId>/replies' -f body='Resolved in a1b2c3d.'
gh api graphql -f id='<thread id>' -f query='
mutation($id: ID!) { resolveReviewThread(input: {threadId: $id}) { thread { isResolved } } }'
```

## Summary comment

```sh
# First run:
gh pr comment <n> --body-file summary.md
# Later runs, with the id from the summary query:
gh api --method PATCH 'repos/{owner}/{repo}/issues/comments/<id>' -F body=@summary.md
```

## Issues and labels

```sh
gh issue list --state all --search '<key words> in:title,body'
gh label list --search business-decision
gh label create business-decision --color D93F0B --description 'A product choice that the code cannot make'
gh issue create --title '<title>' --body-file issue.md --label business-decision
```

A permalink to lines on the base commit:
`https://github.com/<owner>/<repo>/blob/<base sha>/<path>#L10-L14`.

## Screenshots

GitHub has no API that attaches an image to a comment. If the `compose-preview` CLI is
installed, `compose-preview share-preview` uploads images. See the
`compose-preview-review` skill. Otherwise, commit the image to a side branch through the
contents API, and embed it by commit SHA.

Create the side branch once per repo:

```sh
default=$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name)
sha=$(gh api "repos/{owner}/{repo}/git/ref/heads/$default" --jq .object.sha)
gh api 'repos/{owner}/{repo}/git/refs' -f ref=refs/heads/pr-review-assets -f sha="$sha"
```

Upload each image under a new file name. The contents API refuses to overwrite a file
unless you send the SHA of the old file.

```sh
base64 < shot.png | tr -d '\n' \
  | jq -Rs '{message: "Screenshot for PR #<n>", branch: "pr-review-assets", content: .}' > upload.json
gh api --method PUT 'repos/{owner}/{repo}/contents/pr-<n>/<finding-id>-<short head sha>.png' \
  --input upload.json --jq .commit.sha
```

Embed the image with the commit SHA that the upload printed. A link to a commit keeps
working after later pushes to the branch.

```markdown
![<finding-id>](https://github.com/<owner>/<repo>/blob/<commit sha>/pr-<n>/<finding-id>-<short head sha>.png?raw=true)
```

# GitLab commands for pr-review

`glab api` fills `:id` with the current project. Replace `<iid>` with the MR number, the
number after `!`.

## Load the context

```sh
glab api projects/:id/merge_requests/<iid>                # title, description, diff_refs, web_url
glab api projects/:id/merge_requests/<iid>/closes_issues  # the linked issues
glab api projects/:id/merge_requests/<iid>/pipelines      # the CI result
glab mr diff <iid>
```

Check out the head commit in a separate worktree:

```sh
wt="$(mktemp -d)/mr-<iid>"
git fetch origin "merge-requests/<iid>/head"
git worktree add --detach "$wt" FETCH_HEAD
```

Remove it after you post: `git worktree remove "$wt"`.

The threads, which GitLab calls discussions, with their resolved state:

```sh
glab api projects/:id/merge_requests/<iid>/discussions --paginate --output ndjson \
  | jq -c '{id, notes: [.notes[] | {id, author: .author.username, body, resolved, position}]}'
```

The summary note from an earlier run:

```sh
glab api projects/:id/merge_requests/<iid>/notes --paginate --output ndjson \
  | jq -c 'select(.body | startswith("<!-- pr-review:summary")) | {id, body}'
```

## Post the findings

GitLab has no call that posts a whole review, so each inline finding is its own
discussion. Take the three SHAs from `diff_refs` in the MR:

```sh
jq -n --rawfile body finding-1.md --arg path app/src/main/kotlin/Api.kt --argjson line 42 \
  --arg base '<base_sha>' --arg start '<start_sha>' --arg head '<head_sha>' '{
  body: $body,
  position: { position_type: "text", base_sha: $base, start_sha: $start, head_sha: $head,
              old_path: $path, new_path: $path, new_line: $line }
}' > discussion.json
glab api --method POST projects/:id/merge_requests/<iid>/discussions --input discussion.json
```

- For an added line, set `new_line` only.
- For an unchanged line inside a hunk, set both `old_line` and `new_line`.
- For a renamed file, set `old_path` to the old name.

After you post, make sure that the first note of the new discussion has a `position`.
Without one, the comment is not on a line.

A suggestion block replaces the commented line. With `-2+0`, it also replaces the two
lines above:

~~~markdown
```suggestion:-0+0
<the replacement line>
```
~~~

## Reply and resolve

```sh
glab api --method POST projects/:id/merge_requests/<iid>/discussions/<discussion id>/notes -f body='Resolved in a1b2c3d.'
glab api --method PUT projects/:id/merge_requests/<iid>/discussions/<discussion id> -F resolved=true
```

If the project turns on "All threads must be resolved", an open thread blocks the merge.

## Summary note

```sh
# First run:
glab api --method POST projects/:id/merge_requests/<iid>/notes -F body=@summary.md
# Later runs, with the id from the summary query:
glab api --method PUT projects/:id/merge_requests/<iid>/notes/<note id> -F body=@summary.md
```

## Issues and labels

```sh
glab issue list --all --search '<key words>'
glab api projects/:id/labels --paginate --output ndjson | jq -r .name | rg -x business-decision
glab label create --name business-decision --color '#D93F0B' --description 'A product choice that the code cannot make'
glab issue create --title '<title>' --description-file issue.md --label business-decision --yes
```

A permalink to lines on the base commit:
`<project web_url>/-/blob/<base sha>/<path>#L10-14`.

## Screenshots

```sh
glab api --method POST projects/:id/uploads --form "file=@shot.png" | jq -r .markdown
```

Paste the printed Markdown into the finding. The link works inside this project only.

---
name: pr-review
description: Review a pull request (GitHub PR or GitLab MR) and post the findings on it, with severity, a fixed comment format, and a scope check. Use when asked to review a PR or MR by number, URL, or branch, to re-review one after new commits, or to answer review threads on your own PR.
---

# pr-review

Review one pull request and post the result on it. A **finding** is one problem with
evidence, one severity, and one destination. On GitLab a pull request is a merge request
(MR), and the same rules apply.

The commands differ per platform. Read the file that matches `git remote -v`:

- GitHub: [github.md](github.md)
- GitLab: [gitlab.md](gitlab.md)

If the repo has `docs/agents/issue-tracker.md`, follow it for issues and labels. It
overrides both files.

## Review a PR

1. **Load the context.** Read the title, the description, the linked issue, every review
   thread, and the CI result. Check out the head commit in a separate worktree, so that
   the user's checkout stays as it is. Look for a summary comment from an earlier run. If
   one exists, go to "Re-review after new commits". Done when you know the base commit,
   the head commit, and the open findings.
2. **Check the claims.** List every claim that the description and the linked issue make.
   Match each claim to the hunk that delivers it. Then match each hunk to a claim. Apply
   "Claims and scope" to what is left over. Done when each claim has a hunk or a finding,
   and each hunk has a claim or a note.
3. **Find the problems.** Read each changed hunk, the code it calls, and the code that
   calls it. Write each problem with its failure scenario: the input or state, and the
   wrong result. Back it with evidence: a test you ran, a reproduction, or a code path you
   traced. If you cannot write the scenario, post a question instead. Leave out what CI
   and linters already report. Done when you read every changed file.
4. **Sort each finding** with "Sort a finding". Done when each finding has one
   destination: a PR comment, an issue, or a business-decision issue.
5. **Rank and write.** Give each finding a severity, and write it in the comment format.
   Done when each finding has a location, a severity, a suggestion, and a marker.
6. **Add screenshots** to each finding that shows on screen. See "Screenshots".
7. **Post.** Fetch the head commit again. If it moved, review the new commits first. If a
   human is in the session, show the full draft and post after a clear go. The draft
   holds the comments, the summary, the issues, and any label or branch that you will
   create. In an unattended run, such as a CI job, post directly. Post in this order:
   1. The issues, so that the summary can link them.
   2. One review with all inline comments, as a plain comment review (see "Gotchas").
   3. The summary comment. Create it on the first run, and edit it on later runs.

## Re-review after new commits

Each finding ends with a hidden marker. The marker matches a finding across runs, so
each finding is posted once.

1. Read `reviewed=<sha>` from the summary marker.
2. For each open finding, check whether its failure scenario still happens at the head
   commit:
   - Fixed: reply `Resolved in <short-sha>.` in the thread, and resolve the thread. If
     the finding showed on screen, attach a screenshot of the fixed state. Mark it
     `resolved` in the summary.
   - Not fixed, and the author did not reply: leave the thread as it is. It stays `open`
     in the summary.
   - The author replied: read the reply. If the reply convinces you, answer once, resolve
     the thread, and mark it `wontfix`. If it does not, answer once with new evidence.
3. Run step 2 of "Review a PR" on the whole PR, because a new commit can add or drop a
   claim.
4. Run steps 3 to 7 on the commits after `reviewed=<sha>`. If a force-push removed that
   commit, run them on the whole PR. Before you post a new finding, compare it with every
   thread, open or resolved. Skip it if a thread already covers it.
5. Set `reviewed=` in the summary marker to the new head commit.

Resolve only the threads that you opened. A human reviewer resolves their own threads.

## Answer review threads on your own PR

When you push a fix for a review comment on a PR that you authored:

1. Reply in the thread: `Fixed in <short-sha>.` Add one line on what changed.
2. If the change shows on screen, attach a before and after screenshot.
3. Leave the thread for the reviewer to resolve.

If you disagree with a comment, reply with your reason and evidence, and leave the thread
open.

## Severity

| Level | Use it for | Merge |
| --- | --- | --- |
| 🔴 Critical | Data loss or corruption, a security hole, a crash or hang in a main flow, a broken build, a migration that cannot be undone | Blocks |
| 🟠 High | Wrong behavior in a real user flow, a claim that the diff does not deliver, an error that real input reaches and nothing handles | Blocks |
| 🟡 Medium | A bug in an edge case, new logic with no test, a design that makes the next change expensive | Fix here, or open an issue |
| 🟢 Low | Naming, readability, a style point that no tool enforces | Optional |

Rank by the effect on users and data. The effort of the fix does not count. If a finding
sits between two levels, pick the lower one. An inflated scale teaches readers to ignore
it.

## Comment format

~~~markdown
🟠 High · Retry loop never stops on 401

**What:** `fetchProfile()` retries every failure. After a 401, it retries until the app closes.
**Why it matters:** A logged-out user sees a spinner forever, and each retry calls the API.
**Suggestion:** Retry only on network errors and 5xx responses.

```suggestion
if (error is IOException || error.code >= 500) retry()
```

<!-- pr-review:id=retry-loop-401 -->
~~~

- **Title line**: the severity icon and name, then a title of ten words or fewer.
- **What**: the problem and its failure scenario.
- **Why it matters**: the effect on users, data, or later work.
- **Suggestion**: a concrete fix. If the fix replaces lines in the diff, use a suggestion
  block, so that the author applies it in one click. The block syntax differs per
  platform. Otherwise, give a code snippet.
- **Marker**: the last line, `<!-- pr-review:id=<slug> -->`. The slug is short
  kebab-case, and it stays the same across runs. The platform hides it in the rendered
  comment.
- **Language**: write the text in the language of the PR description. Keep the labels,
  identifiers, and technical terms in English.

A **question** is for a suspicion without a failure scenario. It has no severity and
blocks nothing. The title line is `❓ Question · <title>`. The body names the concern and
the fact that settles it. It ends with a marker, like a finding.

## Claims and scope

- A claim with no hunk is a 🟠 High finding: the PR says that it does something that the
  diff does not do.
- A hunk that changes behavior and serves no claim is a 🟡 Medium finding. Ask the author
  to move it to its own PR. If the hunk also has a bug, rank the finding by the bug.
- A hunk that changes no behavior and serves no claim, such as formatting or a typo fix,
  gets a note in the summary only.
- If the PR has no description and no linked issue, say so in the summary. Ask the author
  for a description, and review the diff on its own.

## Sort a finding

| The problem is | Destination |
| --- | --- |
| On lines that the PR adds or changes | PR comment |
| On lines that the PR does not touch, and on the base branch too | Issue (pre-existing) |
| Old, but the PR copies the pattern into new code, or makes the old bug reachable | PR comment that links the issue for the old code |
| A choice between business rules that the description and the issue leave open | Business-decision issue |

To tell a pre-existing problem from a new one:

- `git diff <base>...<head>` shows the lines that the PR touches.
- `git show <base>:<path>` shows a file before the PR.
- `git grep -n '<pattern>' <base>` finds the same problem elsewhere on the base branch.
  If the problem is in many places, open one issue for the pattern.

Before you open an issue, search the open and closed issues for the same problem. If one
exists, link it in the summary instead.

A pre-existing issue holds the severity, the failure scenario, permalinks to the lines on
the base commit, and "Found in the review of <PR link>". Add the repo's bug label if it
has one.

A **business decision** is a behavior that more than one answer fits, where the answer is
a product call and not a code call. Example: what happens to a discount when an order is
partly refunded. Open an issue with the `business-decision` label, and create the label if
the repo lacks it. The issue holds:

- the question, in one sentence
- each option, with its effect on users
- what the PR does today
- a link to the PR

Then post a short PR comment on the line, with a link to the issue. It has no severity,
and it ends with a marker, like a finding. The product owner picks the answer in the
issue.

## Summary comment

One summary comment per PR, edited in place on every run. Its first line is the marker,
which records the last reviewed commit.

~~~markdown
<!-- pr-review:summary reviewed=9f3c2e1 -->
## Review summary

Blocking: yes, 1 High open.

| | Finding | Where | Status |
| --- | --- | --- | --- |
| 🟠 | Retry loop never stops on 401 | `Api.kt:42` | open |
| 🟡 | No test for an empty cart | `CartViewModel.kt:88` | resolved in `a1b2c3d` |
| ❓ | Is the cache cleared on logout? | `Session.kt:17` | question |

Scope: every claim has a hunk. The Ktor version bump in `libs.versions.toml` serves no claim.
Pre-existing, filed as issues: #51 The same retry loop in `SearchApi.kt`.
Business decisions: #52 Refund rule for partly shipped orders.
Not checked: tablet layouts, because no emulator ran in this session.
~~~

The PR is blocking when any Critical or High finding is open. The merge decision stays
with a human. List under "Not checked" everything that you did not verify.

## Screenshots

Attach a screenshot when a finding or a fix shows on screen: layout, color, text, an empty
state, an error message. Capture it with the tool that fits:

- Compose `@Preview`: the `compose-preview-review` skill. It renders base and head, so you
  get a before and an after.
- An Android device or emulator: `adb exec-out screencap -p > shot.png`
- The iOS Simulator: `xcrun simctl io booted screenshot shot.png`
- A web page: the screenshot action of your browser tool.

Upload the image with the commands in the platform file. Show test data only. Crop out
personal data, tokens, and real account names before the upload, because anyone who can
read the PR can see the image. If you cannot capture the screen, write the steps that show
the problem, and say in the finding that no screenshot was possible.

## Gotchas

- Inline comments attach only to lines inside a diff hunk. A problem on an untouched line
  is pre-existing, so it goes to an issue anyway.
- Post the review as a plain comment, and state the blocking status in the summary. A
  "request changes" review from an agent blocks the merge until someone dismisses it.
  GitHub also refuses it on a PR that you authored.
- Inline line numbers are head-commit numbers on the new side of the diff.

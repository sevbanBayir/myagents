# AGENTS.md

Global working agreement for coding agents. Loaded in every session, in every repo.

Keep this file short — it is always in context. Anything long, situational, or
reference-shaped belongs in a skill (`~/.agents/skills/`) or a doc (`~/.agents/docs/`),
which get loaded only when relevant.

## Working style

- Be direct and concise. No preamble, no restating the question back to me.
- Answer in the language I asked in.
- Say "I don't know" instead of guessing. If you're inferring, mark it as an inference.
- Push back when I'm wrong. Agreeing with a bad plan costs me more than the disagreement does.

## Tools on this machine

Prefer these over their older equivalents — they are installed and faster:

| Instead of | Use | For |
| --- | --- | --- |
| `find` | `fd` | finding files by name or path |
| `grep -r` | `rg` | searching file contents |
| — | `jq` | reading and transforming JSON |
| — | `yq` | YAML, including markdown frontmatter (`yq --front-matter=extract`) |
| the web UI | `gh` | anything GitHub: PRs, issues, CI logs, releases |

## How to work in a repo

- Read before you write. Search for an existing pattern before inventing one.
- Match the surrounding code. House style beats your preferred style.
- Small diffs, one concern per change.
- Don't add a dependency without asking.
- Don't commit unless I ask. Never force-push, never rewrite published history.
- If a command fails twice the same way, stop and tell me. Don't try a third variation.

## Before you say you're done

- Run the project's own checks — look in `package.json` scripts, `justfile`, `Makefile`, or CI config.
- If you changed a file that a doc watches, update that doc. See the `docs-sync` skill.
- Report what you did **not** do or could not verify.

<!--
Project-specific rules go in that project's own AGENTS.md, not here.
This file is the answer to "how does Sevban work", not "how does this codebase work".
-->

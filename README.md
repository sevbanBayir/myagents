# ~/.agents

Agent configuration as dotfiles. One repo, two open formats, everything else is a symlink.

## The model

| Layer | Format | Loaded | Holds |
| --- | --- | --- | --- |
| `AGENTS.md` | [AGENTS.md](https://agents.md) | always | how I work — must stay short |
| `skills/*/SKILL.md` | [Agent Skills](https://agentskills.io) | on demand, by description | one capability each |
| `docs/*.md` | plain markdown + frontmatter | when a skill links to it | reference material |

Both formats are open standards read by 30+ agents, so nothing here is Claude-specific.
Tool-specific paths (`~/.claude/`, `~/.codex/`) are symlinks into this repo and are never
edited directly.

The three layers exist to avoid burning context: AGENTS.md is always loaded, so it stays
small; skills are loaded only when their description matches; docs are loaded only when a
skill points at them. Duplicating content across the layers is the main way this rots.

## Install

```sh
git clone <your-remote> ~/.agents
cd ~/.agents
just sync
```

Requires [`just`](https://github.com/casey/just), `fd`, `rg`, `yq`, `jq` — `brew install just fd ripgrep yq jq`.

`just sync-dry` first if you want to see what it will touch. It refuses to overwrite
anything that isn't already one of its own symlinks.

## Daily use

```sh
just                       # list every command
just new-skill my-thing    # scaffold skills/my-thing/SKILL.md
just new-doc my-thing      # scaffold docs/my-thing.md
just check                 # find docs whose source changed
just bless docs/x.md       # mark a doc reviewed
just ci                    # find stale docs
```

**You do not re-run `sync` after adding a skill.** The symlinks point at directories, so
new files inside `skills/` are visible to every agent immediately. Run `sync` only on a
new machine, or when you wire up a new agent.

## Living docs

A doc declares the source files it describes:

```yaml
watch_root: ~/code/api
watch:
  - packages/db/schema.ts
verified: 2026-08-14
checksum: a1b2c3d4e5f6
```

`just check` hashes those files and compares. If they changed and the doc didn't, the doc
is flagged. This is deliberately not a TTL — nobody honours "review every 30 days", but
"this doc describes code that just changed" is a fact you can act on.

Wire it into git so it runs on its own:

```sh
printf '#!/bin/sh\ncd ~/.agents && just ci\n' > .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## Adding an agent

Add two lines to `bin/sync` and re-run it. Most agents read `AGENTS.md` natively and only
need the skills symlink; the ones with their own instruction filename (Claude Code's
`CLAUDE.md`, Gemini's `GEMINI.md`) get a one-line `@import` shim instead of a copy.

Resist the urge to generate tool-specific formats — `.cursor/rules/*.mdc`, Copilot
instruction files — from this repo. That translation layer looks tidy and immediately
becomes the thing you maintain.

## MCP

`mcp/servers.json` is the canonical list of servers you run. It is *not* installed
automatically: Claude Code keeps user-scope MCP config inside `~/.claude.json` next to
unrelated state, and Codex uses TOML — writing either would risk losing data. Add servers
with each tool's own CLI and keep this file as the list you replay on a new machine.

Secrets never go in this repo. Reference them as `${VAR}` and export from your shell
profile or a password manager.

## Vendored skills

Some skills are copied in from other people's repos, not written here. Each keeps the
upstream `LICENSE` next to its `SKILL.md`, so the origin stays visible in the file tree.

| Source | Skills | License |
| --- | --- | --- |
| [mattpocock/skills](https://github.com/mattpocock/skills) | the 18 `engineering` and 7 `productivity` skills | MIT |
| Philipp Lackner (Android/KMP architecture skills, shipped as `skills.zip`) | the 7 `android-*` skills | not stated |
| [android/skills](https://github.com/android/skills) | `agp-9-upgrade`, `adaptive`, `edge-to-edge`, `migrate-xml-views-to-jetpack-compose`, `navigation-3`, `navigation-event`, `styles`, `testing-setup` | Apache 2.0 |
| [yschimke/skills](https://github.com/yschimke/skills) | `compose-preview`, `compose-preview-review`, `compose-preview-ci`, `compose-preview-design-board`, `compose-design-catalog`, `compose-ui-builder`, `figma-catalog-import`, `design-parity-review` | Apache 2.0 |
| [AminBlg/SimpleEnglish](https://github.com/AminBlg/SimpleEnglish) | `simple-english`, and the matching `output-styles/simple-english.md` | MIT |

Every skill that the table does not list is written here. Today that is `docs-sync`
alone, and it carries no `LICENSE` for that reason.

Upstream groups them into category folders. This repo keeps `skills/` flat, so the
category level is dropped on copy. To update, re-copy the folders from upstream.
Run `/setup-matt-pocock-skills` once per repository before you use the rest.

One local deviation: upstream `code-review` is renamed to `mp-code-review`, because
Claude Code ships a built-in skill under the original name. Its three cross-references
in `ask-matt`, `implement` and `tdd` are rewritten to match. Re-apply this on update.

The `android/skills` set keeps its upstream names, so an update is a plain re-copy. Their
`LICENSE.txt` is the repo-root Apache 2.0 file, because each `SKILL.md` points at that
filename. The official installer is `android skills add <name> --project=.`, but it writes
per-agent directories instead of this repo, so copy the folders by hand.

One overlap remains with the `android-*` set: `testing-setup` sets up test
infrastructure, while `android-testing` covers how to write the tests. The old
`android-navigation` skill (type-safe Navigation 2) was deleted in favor of
`navigation-3`.

### The compose-preview CLI

The `yschimke/skills` set drives a `compose-preview` CLI. The CLI is a JVM program from
[yschimke/compose-ai-tools](https://github.com/yschimke/compose-ai-tools), so it belongs on
the machine and not in this repo. Install it per machine:

```sh
SKILL_DIR="$HOME/.local/share/compose-preview" \
  curl -fsSL https://raw.githubusercontent.com/yschimke/skills/main/scripts/install.sh \
  | bash -s -- --cli-only
```

Two details make that command different from the one upstream advertises:

- `--cli-only` stops the installer from writing its own copy of the skill content, and from
  symlinking that copy into `~/.claude/skills`, which is already this repo.
- `SKILL_DIR` moves the unpacked CLI out of the installer's default,
  `~/.agents/skills/compose-preview`. That default collides with this repo on a machine
  that clones it to `~/.agents`, as the Install section above suggests.

The result is `~/.local/bin/compose-preview`, which must be on your PATH. The CLI needs
Java 17 or later, from PATH or from `JAVA_HOME`. Android Studio's bundled runtime works:
`export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"`.

Do not run `compose-preview update` to upgrade. It pipes the installer without
`--cli-only`, so it writes the second skill copy that the flag exists to prevent. Re-run
the command above instead, and re-copy the skill folders from upstream.

One local deviation lives inside the vendored content: `skills/compose-preview/SKILL.md`
carries a short note with the two flags above, because an agent that reads the skill never
reads this file. Re-apply that note on update.

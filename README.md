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

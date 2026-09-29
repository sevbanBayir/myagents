# myagents

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
git clone https://github.com/sevbanBayir/myagents.git ~/myagents
cd ~/myagents
just bootstrap
```

`bootstrap` installs what is missing, runs `just doctor`, then runs `just sync`. It is safe
to re-run.

`~/myagents` is the canonical path. Nothing in `bin/` hardcodes it — every script derives
its own root — but the docs and the `docs-sync` skill name it, and `just lint-paths`
enforces one spelling. Clone elsewhere only if you are willing to fix those by hand.

Two groups of tools, required for two different reasons. `just doctor` reports both.

| Tool | Needed for | Required by |
| --- | --- | --- |
| [`just`](https://github.com/casey/just) | every entry point in the `justfile` | `bin/` |
| `git` | cloning, and re-copying vendored skills | `bin/` |
| `sha256sum` or `shasum` | the checksums in `just check` | `bin/`, and one of the two always exists |
| `fd` | finding files by name or path | `AGENTS.md` |
| `rg` | searching file contents | `AGENTS.md` |
| `jq` | reading and transforming JSON | `AGENTS.md` |
| `yq` | YAML, including markdown frontmatter | `AGENTS.md` |
| `gh` | anything GitHub | `AGENTS.md`, and it needs `gh auth login` |

The second group is not optional. `AGENTS.md` is loaded in every session, in every repo,
and it tells the agent these are installed and must be preferred. A missing one is worse
than an absent feature, because the agent follows an instruction that then fails.

`yq` must be [mikefarah's Go one](https://github.com/mikefarah/yq), because `AGENTS.md`
names `yq --front-matter=extract`. Debian's `yq` package is kislyuk's Python one and has
no such flag, so `bin/doctor` tests the flag rather than trusting the binary name.

`bin/` itself parses frontmatter with `awk`, not `yq`. That is a separate decision, argued
in the header of `bin/_frontmatter.sh`, and it is why `yq` sits in the second group.

`just sync-dry` first if you want to see what it will touch. It refuses to overwrite
anything that isn't already one of its own symlinks.

## Daily use

```sh
just                       # list every command
just doctor                # report which tools are present
just new-skill my-thing    # scaffold skills/my-thing/SKILL.md
just new-doc my-thing      # scaffold docs/my-thing.md
just check                 # find docs whose source changed
just bless docs/x.md       # mark a doc reviewed
just lint-paths            # enforce one spelling of the repo path
just ci                    # lint-paths + check
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
just install-hook
```

That recipe writes `.git/hooks/pre-commit` with absolute paths taken from `$PWD`, so it
works whatever the clone is called.

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
| [tt-a1i/archify](https://github.com/tt-a1i/archify) | `archify` | MIT |

Every skill that the table does not list is written here. Today that is `docs-sync` and
`pr-review`, and neither carries a `LICENSE` for that reason.

Upstream groups them into category folders. This repo keeps `skills/` flat, so the
category level is dropped on copy. To update, re-copy the folders from upstream.
Run `/setup-matt-pocock-skills` once per repository before you use the rest.

One local deviation: upstream `code-review` is renamed to `mp-code-review`, because
Claude Code ships a built-in skill under the original name. Its three cross-references
in `ask-matt`, `implement` and `tdd` are rewritten to match. Re-apply this on update.

`archify` is not a copied folder. It is the `archify.zip` release asset, unpacked. That
package carries no `test/` tree, so it is the smaller half of the upstream repo. The
vendored copy is v2.16.0. To update, download the newest `archify.zip` from the releases
page and replace the folder. `THIRD_PARTY_NOTICES.md` is added by hand, because the zip
omits it and the repo ships it beside `SKILL.md`.

`archify` ships runnable code inside this repo, which no other vendored skill does.
`compose-preview` also drives a CLI, but that CLI is installed separately, outside the
repo. `archify` needs Node.js 18 or later on PATH. `bin/doctor` does not check for it,
because no other skill needs it.

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
  `$HOME/.agents/skills/compose-preview`. This setup does not use that directory, so the
  default would leave a stray skills tree next to the real one. Clone this repo to
  `$HOME/.agents` and the default overwrites your vendored copy instead.

The result is `~/.local/bin/compose-preview`, which must be on your PATH. The CLI needs
Java 17 or later, from PATH or from `JAVA_HOME`. Android Studio's bundled runtime works:
`export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"`.

Do not run `compose-preview update` to upgrade. It pipes the installer without
`--cli-only`, so it writes the second skill copy that the flag exists to prevent. Re-run
the command above instead, and re-copy the skill folders from upstream.

One local deviation lives inside the vendored content: `skills/compose-preview/SKILL.md`
carries a short note with the two flags above, because an agent that reads the skill never
reads this file. Re-apply that note on update.

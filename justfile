# myagents — one source of truth for every coding agent.
# Run `just` with no arguments to see this list.

_default:
    @just --list --unsorted

# Install missing tools, report, then sync. The one command a new machine needs.
bootstrap:
    @./bin/bootstrap

# Report which tools this repo needs, and which are present. Installs nothing.
doctor:
    @./bin/doctor

# Wire this repo into each agent's expected paths. Run once per machine.
sync:
    @./bin/sync

# Show what sync would do, without touching anything.
sync-dry:
    @DRY_RUN=1 ./bin/sync

# Flag docs whose watched source files changed since the doc was verified.
check *paths:
    @./bin/check-staleness {{ paths }}

# Mark a doc as reviewed: refresh its checksum and verified date.
bless path:
    @./bin/check-staleness --bless {{ path }}

# Fail if a first-party file names a non-canonical repo path.
lint-paths:
    @./bin/lint-paths

# Everything a pre-commit hook or CI must run.
ci: lint-paths check

# Scaffold a new skill.
new-skill name:
    @./bin/new-skill {{ name }}

# Scaffold a new living doc.
new-doc name:
    @./bin/new-doc {{ name }}

# Install the pre-commit hook that runs `just ci`.
install-hook:
    @printf '#!/bin/sh\nexec just --justfile "%s/justfile" --working-directory "%s" ci\n' "$PWD" "$PWD" > .git/hooks/pre-commit
    @chmod +x .git/hooks/pre-commit
    @echo "installed .git/hooks/pre-commit"

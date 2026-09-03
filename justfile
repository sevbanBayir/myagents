# ~/.agents — one source of truth for every coding agent.
# Run `just` with no arguments to see this list.

_default:
    @just --list --unsorted

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

# Everything a pre-commit hook or CI should run.
ci: check

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

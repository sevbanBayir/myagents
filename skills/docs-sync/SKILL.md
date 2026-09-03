---
name: docs-sync
description: Keep living docs in sync with the code they describe. Use when `just check` reports a stale doc, when a doc's checksum no longer matches, or immediately after changing any source file listed in a doc's `watch:` frontmatter.
---

# docs-sync

Docs in `~/.agents/docs/` are bound to source files, not to a calendar. Each doc
declares which files it describes; when those files change, the doc is presumed
stale until a human or agent re-reads it and blesses it.

## When this applies

- `just check` printed a `✗` line
- You just edited a file and want to know whether a doc covers it
- You are finishing a change and the "before you say you're done" checklist sent you here

## How the binding works

```yaml
---
name: drizzle-migrations
watch_root: ~/code/api        # optional; defaults to the doc's own directory
watch:
  - packages/db/schema.ts
  - drizzle.config.ts
verified: 2026-08-14
checksum: a1b2c3d4e5f6
---
```

`checksum` is a hash over the *contents* of every path in `watch:`. `just check`
recomputes it and compares. Docs with no `watch:` block are ignored.

## Fixing a stale doc

1. See what actually changed:
   ```sh
   git -C <watch_root> log --oneline -- <watched paths>
   git -C <watch_root> diff HEAD~1 -- <watched paths>
   ```
2. Read the doc against the current source. Look for statements that are now false:
   renamed symbols, changed defaults, removed steps, commands that no longer exist.
3. Edit the doc. Fix what's wrong; delete what no longer exists. Do **not** append a
   changelog section — a living doc describes the present, and history is what git is for.
4. Bless it:
   ```sh
   just bless docs/<name>.md
   ```

Only bless after actually reading the doc. Blessing without reading turns the whole
mechanism into a rubber stamp, and a doc that is confidently wrong is worse than no doc.

## Finding which docs cover a file

```sh
rg -l 'watch:' ~/.agents/docs | xargs rg -l '<filename>'
```

## Adding a watch to an existing doc

Add the `watch:` list (and `watch_root` if the sources live outside this repo), then
run `just bless <doc>` once to record the first checksum.

Watch the *narrowest* set of files that would actually invalidate the doc. Watching a
whole directory, or a file that churns for unrelated reasons, produces false staleness —
and a checker that cries wolf gets ignored within a week.

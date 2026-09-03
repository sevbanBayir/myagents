---
name: _template
description: One line. What is this doc about, and who needs it.
watch_root: ~/code/some-project
watch:
  - src/the/file/this/doc/describes.ts
verified: ""
checksum: ""
---

# Title

What this covers, in one or two sentences. Then the actual content.

Write it as reference material an agent reads *after* deciding it's relevant — the
deciding is done by the skill that links here, so you don't need to sell it.

Delete `watch_root` if the watched files live inside this repo. Delete `watch:`
entirely if this doc isn't bound to any source (it will then be skipped by `just check`).

Once filled in, run `just bless docs/<name>.md` to record the first checksum.

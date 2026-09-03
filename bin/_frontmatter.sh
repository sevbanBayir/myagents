#!/usr/bin/env bash
#
# Shared frontmatter helpers. Sourced by check-staleness.
#
# Deliberately awk, not yq: the two yq implementations in the wild (mikefarah's Go
# one from brew, kislyuk's Python one from pip) disagree on flags and expression
# syntax, and yq rewriting a doc header in place would reorder keys and strip
# comments. The frontmatter shape used here is fixed and tiny:
#
#   flat `key: value` scalars, plus a `watch:` list of "  - path" lines.
#
# That subset is all these scripts need. Anything fancier — nested maps, anchors,
# multi-line strings — is not supported on purpose. Use yq for real YAML files.

# _fm_scalar <key> <file>
_fm_scalar() {
  local v
  v="$(awk -v key="$1" '
    NR==1 { if ($0 !~ /^---[ \t]*$/) exit; next }
    /^---[ \t]*$/ { exit }
    index($0, key ":") == 1 {
      v = substr($0, length(key) + 2)
      sub(/^[ \t]+/, "", v)
      sub(/[ \t]+$/, "", v)
      print v
      exit
    }
  ' "$2")"
  # strip one layer of surrounding quotes
  v="${v%\"}"; v="${v#\"}"
  v="${v%\'}"; v="${v#\'}"
  printf '%s' "$v"
}

# _fm_list <key> <file>   -> one item per line
_fm_list() {
  awk -v key="$1" '
    NR==1 { if ($0 !~ /^---[ \t]*$/) exit; next }
    /^---[ \t]*$/ { exit }
    inlist && /^[ \t]*-[ \t]+/ {
      sub(/^[ \t]*-[ \t]+/, "")
      sub(/[ \t]+$/, "")
      gsub(/^"|"$/, "")
      gsub(/^'\''|'\''$/, "")
      print
      next
    }
    inlist { inlist = 0 }
    index($0, key ":") == 1 { inlist = 1 }
  ' "$2"
}

# _fm_set_meta <file> <checksum> <date>
# Rewrites checksum: and verified: inside the frontmatter, inserting them if absent.
# Every other line, including comments and key order, is preserved byte for byte.
_fm_set_meta() {
  local doc="$1" sum="$2" today="$3" tmp
  tmp="$(mktemp)"
  awk -v sum="$sum" -v today="$today" '
    NR==1 && /^---[ \t]*$/ { print; infm=1; next }
    infm && /^---[ \t]*$/ {
      if (!ds) print "checksum: " sum
      if (!dv) print "verified: " today
      infm=0; print; next
    }
    infm && index($0,"checksum:")==1 { print "checksum: " sum;   ds=1; next }
    infm && index($0,"verified:")==1 { print "verified: " today; dv=1; next }
    { print }
  ' "$doc" > "$tmp"
  cat "$tmp" > "$doc"
  rm -f "$tmp"
}

# _list_md <dir>   -> markdown files, fd if available, find otherwise.
# Files whose name starts with _ are scaffolding (templates) and are skipped.
_list_md() {
  if command -v fd >/dev/null 2>&1; then
    fd -e md --exclude '_*.md' . "$1"
  else
    find "$1" -type f -name '*.md' ! -name '_*' | sort
  fi
}

# _list_skills <dir>
_list_skills() {
  if command -v fd >/dev/null 2>&1; then
    fd -g 'SKILL.md' "$1"
  else
    find "$1" -type f -name 'SKILL.md' | sort
  fi
}

# _sha  (reads stdin)
if command -v sha256sum >/dev/null 2>&1; then
  _sha() { sha256sum | cut -d' ' -f1; }
else
  _sha() { shasum -a 256 | cut -d' ' -f1; }
fi

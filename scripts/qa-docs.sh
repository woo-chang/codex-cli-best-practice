#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

failures=0
targets=(
  README.md
  AGENTS.md
  best-practice
  docs
  examples
  reports
  .codex
  .agents
  orchestration-workflow
  .github
)

text_files=()
while IFS= read -r file; do
  text_files+=("$file")
done < <(
  find "${targets[@]}" -type f \( -name '*.md' -o -name '*.toml' -o -name '*.yml' -o -name '*.yaml' \) 2>/dev/null | sort
)

echo "Checking Markdown relative links..."
while IFS=$'\t' read -r file target; do
  case "$target" in
    http* | mailto:* | \#* | "")
      continue
      ;;
  esac

  clean="${target%%#*}"
  clean="${clean%%\?*}"
  dir="$(dirname "$file")"
  path="$dir/$clean"

  if [ ! -e "$path" ]; then
    echo "Missing relative target: $file -> $target"
    failures=1
  fi
done < <(
  while IFS= read -r file; do
    perl -ne '
      if (/^```/) { $in_fence = !$in_fence; next; }
      next if $in_fence;
      while (/\[[^]]*\]\(([^)]+)\)/g) { print "$ARGV\t$1\n"; }
      while (/<(?:img|a)\b[^>]*(?:src|href)="([^"]+)"/g) { print "$ARGV\t$1\n"; }
    ' "$file"
  done < <(find . -path './.git' -prune -o -name '*.md' -print | sort)
)

echo "Checking for retired schema strings..."
patterns=(
  'codex\.toml'
  'codex\.local\.toml'
  'approval_policy = "(suggest|auto-edit|full-auto)"'
  '^\[sandbox\]'
  'sandbox\.mode[[:space:]]*='
  '^\[profile\.'
  '^\[mcp\.servers\.'
  '--approval-policy'
  'codex config show'
  '--as-mcp-server'
  'mcpServers:'
  '\.codex/skills/'
  '\.codex/agents/<name>\.md'
  'wttr\.in'
)

match_file="$(mktemp)"
trap 'rm -f "$match_file"' EXIT

for pattern in "${patterns[@]}"; do
  if grep -nE -- "$pattern" "${text_files[@]}" >"$match_file"; then
    echo "Retired pattern matched: $pattern"
    cat "$match_file"
    failures=1
  fi
done

if [ "$failures" -ne 0 ]; then
  echo "Docs QA failed."
  exit 1
fi

echo "Docs QA passed."

#!/usr/bin/env bash
# Copy the utr and utr-poh skills into Claude Code and/or Codex.
# utr-poh reads ../utr/SKILL.md, so both skills are always installed together.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS=(utr utr-poh)
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
CODEX_DIR="${CODEX_DIR:-$HOME/.codex}"

usage() {
  echo "usage: $0 [--claude] [--codex] [--all]"
  echo "  --claude  install into \$CLAUDE_DIR/skills (default ~/.claude/skills)"
  echo "  --codex   install into \$CODEX_DIR/skills (default ~/.codex/skills)"
  echo "  --all     both"
  exit 1
}

install_into() {
  local dst="$1/skills"
  for s in "${SKILLS[@]}"; do
    mkdir -p "$dst/$s"
    rsync -a --delete --exclude .DS_Store "$REPO/skills/$s/" "$dst/$s/"
    echo "installed: $s -> $dst/$s"
  done
}

[ $# -gt 0 ] || usage
command -v rsync >/dev/null || { echo "rsync not found" >&2; exit 1; }

do_claude=false do_codex=false
for arg in "$@"; do
  case "$arg" in
    --claude) do_claude=true ;;
    --codex) do_codex=true ;;
    --all) do_claude=true do_codex=true ;;
    *) usage ;;
  esac
done

$do_claude && install_into "$CLAUDE_DIR"
$do_codex && install_into "$CODEX_DIR"
echo "Done. Restart the agent session to pick up the skills."

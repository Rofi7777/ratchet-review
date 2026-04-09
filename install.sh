#!/bin/bash
# Ratchet Review installer for Claude Code
# https://github.com/Rofi7777/ratchet-review

set -e

SKILL_DIR="${HOME}/.claude/skills/ratchet-review"

if [ -d "$SKILL_DIR" ]; then
  echo "Ratchet Review is already installed at $SKILL_DIR"
  read -p "Overwrite? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
  rm -rf "$SKILL_DIR"
fi

# Find the script's directory (works even if called from another location)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$SKILL_DIR"
cp "$SCRIPT_DIR/skill/SKILL.md" "$SKILL_DIR/"
cp "$SCRIPT_DIR/skill/PPTX-RULES.md" "$SKILL_DIR/"
cp "$SCRIPT_DIR/skill/DESIGN-RULES.md" "$SKILL_DIR/"

echo ""
echo "Ratchet Review installed to $SKILL_DIR"
echo ""
echo "Usage: Open Claude Code and say 'review my output' or 'quality check'."
echo ""
echo "Optional: Copy examples to customize personas and anchors:"
echo "  cp -r $SCRIPT_DIR/examples/ $SKILL_DIR/examples/"
echo ""

#!/bin/bash
set -e

SKILL_NAME="stay-on-target"
SKILL_DIR="$HOME/.claude/skills/$SKILL_NAME"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/skills/$SKILL_NAME"

if [ ! -f "$SOURCE_DIR/SKILL.md" ]; then
  echo "Error: SKILL.md not found in $SOURCE_DIR"
  exit 1
fi

mkdir -p "$SKILL_DIR"
cp "$SOURCE_DIR/SKILL.md" "$SKILL_DIR/SKILL.md"

echo "Installed $SKILL_NAME to $SKILL_DIR"
echo ""
echo "You can now use /stay-on-target in Claude Code."
echo ""
echo "On first use, the skill will ask who's driving the session"
echo "and create a drift profile for you over time."

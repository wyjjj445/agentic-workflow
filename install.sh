#!/usr/bin/env bash
set -euo pipefail

# Agentic Workflow — Install Script (Unix: macOS/Linux)

CLAUDE_DIR="${HOME}/.claude"
SKILLS_DIR="${CLAUDE_DIR}/skills/agentic-flow"
RULES_DIR="${CLAUDE_DIR}/rules"
REPO_BASE="https://raw.githubusercontent.com/wyjjj445/agentic-workflow/main"

echo ""
echo "🧠 Agentic Workflow Installer"
echo "================================"
echo ""

# Create directories
mkdir -p "${SKILLS_DIR}" "${RULES_DIR}"

# Install SKILL.md
echo "📦 Installing skill file..."
if [ -f "./SKILL.md" ]; then
    cp ./SKILL.md "${SKILLS_DIR}/SKILL.md"
    echo "  ✅ Copied SKILL.md (local)"
else
    curl -fsSL "${REPO_BASE}/SKILL.md" -o "${SKILLS_DIR}/SKILL.md"
    echo "  ✅ Downloaded SKILL.md"
fi

# Install RULES.md
echo "📦 Installing rules file..."
if [ -f "./RULES.md" ]; then
    cp ./RULES.md "${RULES_DIR}/agentic-workflow.md"
    echo "  ✅ Copied RULES.md (local)"
else
    curl -fsSL "${REPO_BASE}/RULES.md" -o "${RULES_DIR}/agentic-workflow.md"
    echo "  ✅ Downloaded RULES.md"
fi

# Verify
echo ""
echo "🔍 Verifying installation..."
if [ -f "${SKILLS_DIR}/SKILL.md" ] && [ -f "${RULES_DIR}/agentic-workflow.md" ]; then
    echo ""
    echo "✅ Agentic Workflow installed successfully!"
    echo ""
    echo "  SKILL.md → ${SKILLS_DIR}/SKILL.md"
    echo "  RULES.md → ${RULES_DIR}/agentic-workflow.md"
    echo ""
    echo "📖 Usage:"
    echo "  Start a new Claude Code session and type:"
    echo "    /agentic-flow <your task>"
    echo ""
    echo "  Or just describe a non-trivial task and Claude will"
    echo "  automatically suggest using agentic workflow."
else
    echo "❌ Installation failed - files missing!"
    exit 1
fi

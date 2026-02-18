#!/bin/bash
set -euo pipefail

# Only run in remote Claude Code on the web environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# This project is a zero-dependency static HTML app.
# No package installation is needed.
echo "jlpt-n5: static HTML project — no dependencies to install."

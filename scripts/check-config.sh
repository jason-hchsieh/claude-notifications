#!/usr/bin/env bash
#
# check-config.sh - Validate notification configuration
#
# Usage: check-config.sh
#
# Exit codes:
#   0: Configuration is valid
#   1: Configuration is invalid or missing
#

set -euo pipefail

# Configuration file path
# Respect CLAUDE_CONFIG_DIR if set, otherwise use default ~/.claude
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-${HOME}}/.claude"
CONFIG_FILE="${CLAUDE_DIR}/claude-notifications.local.md"

# Check if config file exists
if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "❌ Configuration file not found: ${CONFIG_FILE}"
    echo ""
    echo "Run /notify:setup to create the configuration file."
    exit 1
fi

# Parse YAML frontmatter from config file
parse_yaml() {
    local key=$1
    sed -n '/^---$/,/^---$/p' "${CONFIG_FILE}" | \
        grep "^${key}:" | \
        sed 's/^[^:]*:[[:space:]]*//' | \
        tr -d '"' | \
        tr -d "'"
}

# Read configuration
GOTIFY_URL=$(parse_yaml "gotify_url")
GOTIFY_TOKEN=$(parse_yaml "gotify_token")

# Validate required fields
ERRORS=0

if [[ -z "${GOTIFY_URL}" ]]; then
    echo "❌ Missing required field: gotify_url"
    ERRORS=$((ERRORS + 1))
fi

if [[ -z "${GOTIFY_TOKEN}" ]]; then
    echo "❌ Missing required field: gotify_token"
    ERRORS=$((ERRORS + 1))
fi

if [[ ${ERRORS} -gt 0 ]]; then
    echo ""
    echo "Configuration file is invalid. Please check ${CONFIG_FILE}"
    exit 1
fi

# All validation passed
echo "✅ Configuration is valid"
echo ""
echo "  Server: ${GOTIFY_URL}"
echo "  Token:  ${GOTIFY_TOKEN:0:8}... (hidden)"

exit 0

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
NTFY_URL=$(parse_yaml "ntfy_url")
NTFY_TOKEN=$(parse_yaml "ntfy_token")
NTFY_TOPIC=$(parse_yaml "ntfy_topic")

# Validate required fields
ERRORS=0

if [[ -z "${NTFY_URL}" ]]; then
    echo "❌ Missing required field: ntfy_url"
    ERRORS=$((ERRORS + 1))
fi

if [[ -z "${NTFY_TOKEN}" ]]; then
    echo "❌ Missing required field: ntfy_token"
    ERRORS=$((ERRORS + 1))
fi

if [[ -z "${NTFY_TOPIC}" ]]; then
    echo "❌ Missing required field: ntfy_topic"
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
echo "  Server: ${NTFY_URL}"
echo "  Topic:  ${NTFY_TOPIC}"
echo "  Token:  ${NTFY_TOKEN:0:8}... (hidden)"

exit 0

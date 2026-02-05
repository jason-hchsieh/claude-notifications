#!/usr/bin/env bash
#
# send-notification.sh - Send notification via Gotify
#
# Usage: send-notification.sh <event_type> <priority> <message>
#
# Arguments:
#   event_type: Type of event (question, approval, completion, error, stop)
#   priority: Priority level (0-10, Gotify scale)
#   message: Additional context message
#

set -euo pipefail

# Configuration file path
CONFIG_FILE="${HOME}/.claude/claude-notifications.local.md"
PAUSE_FILE="${HOME}/.claude/.notifications-paused"

# Check if notifications are paused
if [[ -f "${PAUSE_FILE}" ]]; then
    exit 0  # Silently exit if paused
fi

# Check if config file exists
if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "Error: Configuration file not found: ${CONFIG_FILE}" >&2
    echo "Run /notify:setup to configure notifications" >&2
    exit 1
fi

# Parse YAML frontmatter from config file
parse_yaml() {
    local key=$1
    # Extract value from YAML frontmatter (between --- markers)
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
if [[ -z "${GOTIFY_URL}" ]] || [[ -z "${GOTIFY_TOKEN}" ]]; then
    echo "Error: Missing required configuration fields" >&2
    echo "Required: gotify_url, gotify_token" >&2
    exit 1
fi

# Get arguments
EVENT_TYPE="${1:-stop}"
PRIORITY="${2:-5}"  # Gotify uses 0-10 scale, 5 is normal
MESSAGE="${3:-}"

# Get project name (basename of current working directory)
PROJECT_NAME=$(basename "$(pwd)")

# Determine title based on event type
case "${EVENT_TYPE}" in
    question)
        TITLE="🔔 Claude has a question"
        PRIORITY=7
        ;;
    approval)
        TITLE="🔔 Claude needs approval"
        PRIORITY=7
        ;;
    error)
        TITLE="⚠️ Claude encountered an error"
        PRIORITY=8
        ;;
    completion)
        TITLE="✅ Task completed"
        PRIORITY=5
        ;;
    stop)
        TITLE="🛑 Claude stopped"
        PRIORITY=5
        ;;
    test)
        TITLE="🔔 Test notification"
        PRIORITY=5
        ;;
    *)
        TITLE="🔔 Claude notification"
        PRIORITY=5
        ;;
esac

# Construct message body
BODY="[${PROJECT_NAME}]"
if [[ -n "${MESSAGE}" ]]; then
    BODY="${BODY} ${MESSAGE}"
fi

# Escape JSON special characters in title and body
escape_json() {
    local str="$1"
    str="${str//\\/\\\\}"  # Escape backslash
    str="${str//\"/\\\"}"  # Escape double quote
    str="${str//$'\n'/\\n}"  # Escape newline
    str="${str//$'\r'/\\r}"  # Escape carriage return
    str="${str//$'\t'/\\t}"  # Escape tab
    echo "$str"
}

TITLE_ESCAPED=$(escape_json "${TITLE}")
BODY_ESCAPED=$(escape_json "${BODY}")

# Send notification to Gotify
curl -s -o /dev/null \
    -X POST "${GOTIFY_URL}/message?token=${GOTIFY_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"title\":\"${TITLE_ESCAPED}\",\"message\":\"${BODY_ESCAPED}\",\"priority\":${PRIORITY}}" \
    > /dev/null 2>&1

exit 0

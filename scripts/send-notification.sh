#!/usr/bin/env bash
#
# send-notification.sh - Send notification via ntfy.sh
#
# Usage: send-notification.sh <event_type> <priority> <message>
#
# Arguments:
#   event_type: Type of event (question, approval, completion, error, stop)
#   priority: Priority level (1-5)
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
NTFY_URL=$(parse_yaml "ntfy_url")
NTFY_TOKEN=$(parse_yaml "ntfy_token")
NTFY_TOPIC=$(parse_yaml "ntfy_topic")

# Validate required fields
if [[ -z "${NTFY_URL}" ]] || [[ -z "${NTFY_TOKEN}" ]] || [[ -z "${NTFY_TOPIC}" ]]; then
    echo "Error: Missing required configuration fields" >&2
    echo "Required: ntfy_url, ntfy_token, ntfy_topic" >&2
    exit 1
fi

# Get arguments
EVENT_TYPE="${1:-stop}"
PRIORITY="${2:-3}"
MESSAGE="${3:-}"

# Get project name (basename of current working directory)
PROJECT_NAME=$(basename "$(pwd)")

# Determine title and tags based on event type
case "${EVENT_TYPE}" in
    question)
        TITLE="🔔 Claude has a question"
        TAGS="loudspeaker"
        ;;
    approval)
        TITLE="🔔 Claude needs approval"
        TAGS="loudspeaker"
        ;;
    error)
        TITLE="⚠️ Claude encountered an error"
        TAGS="warning"
        ;;
    completion)
        TITLE="✅ Task completed"
        TAGS="white_check_mark"
        ;;
    stop)
        TITLE="🛑 Claude stopped"
        TAGS="octagonal_sign"
        ;;
    *)
        TITLE="🔔 Claude notification"
        TAGS="bell"
        ;;
esac

# Construct message body
BODY="[${PROJECT_NAME}]"
if [[ -n "${MESSAGE}" ]]; then
    BODY="${BODY} ${MESSAGE}"
fi

# Send notification to ntfy.sh
curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer ${NTFY_TOKEN}" \
    -H "Title: ${TITLE}" \
    -H "Priority: ${PRIORITY}" \
    -H "Tags: ${TAGS}" \
    -d "${BODY}" \
    "${NTFY_URL}/${NTFY_TOPIC}" > /dev/null 2>&1

exit 0

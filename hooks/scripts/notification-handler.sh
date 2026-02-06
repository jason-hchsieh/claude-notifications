#!/usr/bin/env bash
#
# notification-handler.sh - Handle Notification hook events
#
# This script is called by the Notification hook and determines the type
# of notification (question, approval, error) to send with appropriate priority.
#

set -euo pipefail

# Get the plugin root directory
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-}"
if [[ -z "${PLUGIN_ROOT}" ]]; then
    # Fallback to script location
    PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

SEND_SCRIPT="${PLUGIN_ROOT}/scripts/send-notification.sh"

# Read input from stdin (if provided by hook)
INPUT=""
if [[ ! -t 0 ]]; then
    INPUT=$(cat)
fi

# Determine notification type and priority based on context
# The Notification hook fires for various Claude UI notifications:
# - AskUserQuestion (questions needing user input)
# - Plan mode approval requests
# - Error messages
# - Task completions

# Default values (ntfy.sh uses 1-5 scale, 5 is most urgent)
EVENT_TYPE="question"
PRIORITY=5  # Urgent by default for questions
MESSAGE="Needs your attention"

# Analyze input to determine specific type (if available)
if [[ -n "${INPUT}" ]]; then
    # Check for common patterns to determine notification type
    if echo "${INPUT}" | grep -qi "error\|failed\|exception"; then
        EVENT_TYPE="error"
        PRIORITY=4
        MESSAGE="An error occurred"
    elif echo "${INPUT}" | grep -qi "plan\|approval\|approve"; then
        EVENT_TYPE="approval"
        PRIORITY=5
        MESSAGE="Approval needed"
    elif echo "${INPUT}" | grep -qi "complete\|finished\|done"; then
        EVENT_TYPE="completion"
        PRIORITY=3
        MESSAGE="Task completed"
    elif echo "${INPUT}" | grep -qi "question\|input\|choice"; then
        EVENT_TYPE="question"
        PRIORITY=5
        MESSAGE="Has a question"
    fi
fi

# Send notification
bash "${SEND_SCRIPT}" "${EVENT_TYPE}" "${PRIORITY}" "${MESSAGE}"

exit 0

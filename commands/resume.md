---
name: resume
description: Re-enable notifications after being paused
allowed-tools: [Bash]
argument-hint: ""
---

# Resume Notifications

Re-enable Claude Code notifications after they have been paused with `/notify:pause`.

## Instructions

1. **Check if notifications are currently paused**:
   - Use Bash tool to check if pause file exists:
     ```bash
     CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-${HOME}}/.claude"
     if [[ -f "${CLAUDE_DIR}/.notifications-paused" ]]; then
       echo "Notifications are currently paused"
     else
       echo "Notifications are already active"
     fi
     ```

2. **Remove the pause state file**:
   - Delete the pause file:
     ```bash
     CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-${HOME}}/.claude"
     rm -f "${CLAUDE_DIR}/.notifications-paused"
     ```

3. **Verify pause file was removed**:
   - Confirm the file no longer exists:
     ```bash
     CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-${HOME}}/.claude"
     if [[ ! -f "${CLAUDE_DIR}/.notifications-paused" ]]; then
       echo "✅ Pause file removed successfully"
     else
       echo "❌ Failed to remove pause file"
     fi
     ```

4. **Send confirmation notification** (optional):
   - Send a notification that notifications are resumed:
     ```bash
     ${CLAUDE_PLUGIN_ROOT}/scripts/send-notification.sh completion 3 "Notifications resumed"
     ```

5. **Inform user**:
   - Notifications are now active again
   - All Claude stopping points will trigger notifications
   - Applies to all Claude Code sessions globally

## Behavior

After resuming:
- ✅ All hooks start sending notifications again
- ✅ Applies immediately to all Claude Code sessions
- ✅ Configuration unchanged (Gotify settings intact)

## Use Cases

- **End of focus time**: Re-enable alerts after working actively with Claude
- **Monitoring mode**: Switch back to being notified when Claude needs attention
- **After debugging**: Turn notifications back on after testing

## Checking Notification Status

To check if notifications are active or paused:
```bash
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-${HOME}}/.claude"
if [[ -f "${CLAUDE_DIR}/.notifications-paused" ]]; then
  echo "⏸️  Notifications are PAUSED"
else
  echo "▶️  Notifications are ACTIVE"
fi
```

Or simply run `/notify:test` - if you receive a test notification, they're active.

## Tips

- If you're unsure whether notifications are paused, run `/notify:test`
- Resume sends a confirmation notification so you know it worked
- Safe to run even if notifications aren't paused (idempotent)
- Pause/resume state is global across all Claude sessions

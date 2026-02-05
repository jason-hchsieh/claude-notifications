---
name: test
description: Validate configuration and send a test notification
allowed-tools: [Bash]
argument-hint: ""
---

# Test Notification Setup

Validate the notification configuration and send a test notification to verify everything is working.

## Instructions

1. **Check configuration validity**:
   - Use Bash tool to run the check-config script:
     ```bash
     ${CLAUDE_PLUGIN_ROOT}/scripts/check-config.sh
     ```
   - This will verify that `~/.claude/claude-notifications.local.md` exists and has all required fields

2. **If validation fails**:
   - Display the error message from check-config script
   - Suggest running `/notify:setup` to configure notifications
   - Exit without sending test notification

3. **If validation succeeds**:
   - Inform user that configuration is valid
   - Send a test notification using the send-notification script:
     ```bash
     ${CLAUDE_PLUGIN_ROOT}/scripts/send-notification.sh test 3 "Test notification from Claude Code"
     ```

4. **Inform user**:
   - Test notification sent successfully
   - Ask them to check their device (phone, browser, etc.) for the notification
   - If they didn't receive it, troubleshoot:
     - Check ntfy.sh mobile app is installed and subscribed to the topic
     - Verify the topic name matches in both config and app
     - Check server URL is correct and accessible
     - Verify access token has proper permissions
     - Test manually with curl:
       ```bash
       curl -d "Manual test" -H "Authorization: Bearer YOUR_TOKEN" https://your-server.com/topic-name
       ```

## Expected Behavior

When successful, you should see:
- ✅ Configuration validation passed
- Test notification sent
- Notification appears on subscribed devices with:
  - Title: "🔔 Claude notification"
  - Body: "[project-name] Test notification from Claude Code"
  - Priority: Default (3)

## Troubleshooting

If the test fails:

1. **Configuration errors**: Run `/notify:setup` again
2. **Network errors**: Check server URL and network connectivity
3. **Authentication errors**: Verify access token is valid
4. **Topic errors**: Ensure topic name matches in config and ntfy app subscription

## Tips

- Run this command after initial setup to verify configuration
- Run periodically to ensure notifications are still working
- Use this to debug if automatic notifications stop working

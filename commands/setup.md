---
name: setup
description: Interactive setup wizard to configure Gotify notifications
allowed-tools: [Write, Bash, AskUserQuestion]
argument-hint: ""
---

# Setup Notification Configuration

Configure the claude-notifications plugin by creating the settings file with Gotify connection details.

## Instructions

Follow these steps to set up notifications:

1. **Check if configuration already exists**:
   - Use Bash tool to check if `~/.claude/claude-notifications.local.md` exists
   - If it exists, inform the user and ask if they want to overwrite it

2. **Gather required information** using AskUserQuestion:
   - **Gotify server URL**: Ask for the full URL (e.g., `https://gotify.example.com`)
     - Must be their self-hosted Gotify instance (no public server)
     - Should NOT include trailing slash
   - **Application token**: Ask for the Gotify application token
     - Explain how to get one: Create an application in Gotify web UI → Settings → Apps → Create Application
     - Token format: Alphanumeric string (e.g., `Ahc4eJUerK8MpYG`)
     - Note: This provides built-in user isolation, unlike topic-based systems

3. **Validate inputs**:
   - Ensure URL starts with `https://` (security)
   - Remove trailing slash from URL if present
   - Ensure token is not empty

4. **Create configuration directory** if needed:
   ```bash
   mkdir -p ~/.claude
   ```

5. **Write configuration file** using Write tool to `~/.claude/claude-notifications.local.md`:
   ```yaml
   ---
   gotify_url: "USER_PROVIDED_URL"
   gotify_token: "USER_PROVIDED_TOKEN"
   ---
   ```

6. **Set secure file permissions**:
   ```bash
   chmod 600 ~/.claude/claude-notifications.local.md
   ```

7. **Verify configuration** by running the check script:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/check-config.sh
   ```

8. **Send test notification** to verify setup:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/send-notification.sh test 3 "Setup completed successfully!"
   ```

9. **Inform user**:
   - Configuration saved successfully
   - Test notification sent (check your device)
   - Notifications are now active
   - Remind them they can use `/notify:pause` and `/notify:resume` to control notifications
   - Suggest running `/notify:test` anytime to verify setup

## Tips

- If the user doesn't have a Gotify server yet, guide them to:
  - Self-host Gotify: [Installation guide](https://gotify.net/docs/install)
  - Docker: `docker run -p 80:80 -v /var/gotify/data:/app/data gotify/server`
  - Supports SQLite or PostgreSQL backend

- For application tokens:
  - Log into Gotify web UI (usually on port 80)
  - Navigate to Settings → Apps
  - Click "Create Application"
  - Enter a name like "Claude Code"
  - Copy the generated token (shown only once!)

- Gotify provides built-in user isolation through application tokens
  - Each application has its own token
  - No topic-based guessing needed
  - Better security than public notification services

## Security Notes

- Configuration file contains sensitive access token
- File permissions are set to 600 (owner read/write only)
- Always use HTTPS URLs
- Never commit `.local.md` files to version control

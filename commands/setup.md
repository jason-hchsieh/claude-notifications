---
name: setup
description: Interactive setup wizard to configure ntfy.sh notifications
allowed-tools: [Write, Bash, AskUserQuestion]
argument-hint: ""
---

# Setup Notification Configuration

Configure the claude-notifications plugin by creating the settings file with ntfy.sh connection details.

## Instructions

Follow these steps to set up notifications:

1. **Check if configuration already exists**:
   - Use Bash tool to check if `~/.claude/claude-notifications.local.md` exists
   - If it exists, inform the user and ask if they want to overwrite it

2. **Gather required information** using AskUserQuestion:
   - **ntfy.sh server URL**: Ask for the full URL (e.g., `https://ntfy.sh` or `https://ntfy.example.com`)
     - Suggest `https://ntfy.sh` for public server or their self-hosted URL
   - **Access token**: Ask for the ntfy.sh access token (starts with `tk_`)
     - Explain how to get one: [ntfy.sh authentication docs](https://docs.ntfy.sh/publish/#authentication)
   - **Topic name**: Ask for the topic/channel name (e.g., `claude-notifications`)
     - Suggest `claude-notifications` as default
     - Explain that this should be unique and memorable

3. **Validate inputs**:
   - Ensure URL starts with `https://` (security)
   - Ensure token is not empty
   - Ensure topic name is alphanumeric with hyphens/underscores only

4. **Create configuration directory** if needed:
   ```bash
   mkdir -p ~/.claude
   ```

5. **Write configuration file** using Write tool to `~/.claude/claude-notifications.local.md`:
   ```yaml
   ---
   ntfy_url: "USER_PROVIDED_URL"
   ntfy_token: "USER_PROVIDED_TOKEN"
   ntfy_topic: "USER_PROVIDED_TOPIC"
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

- If the user doesn't have an ntfy.sh server yet, guide them to:
  - Use public server: `https://ntfy.sh` (easiest)
  - Self-host: [Installation guide](https://docs.ntfy.sh/install/)

- For access tokens:
  - Public ntfy.sh: Create account at https://ntfy.sh/account
  - Self-hosted: Use `ntfy token add` command

- Topic names should be unique enough to avoid collisions with other users (on public server)

## Security Notes

- Configuration file contains sensitive access token
- File permissions are set to 600 (owner read/write only)
- Always use HTTPS URLs
- Never commit `.local.md` files to version control

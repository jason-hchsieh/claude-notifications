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
   - **ntfy.sh server URL**: Ask which server to use
     - Options:
       - "Use public ntfy.sh server" → Use `https://ntfy.sh`
       - "Use self-hosted ntfy.sh" → Ask for URL

   - **Topic name**: Ask for a topic name
     - Explain: This is a unique identifier for your notifications (e.g., `my-claude-notifications`)
     - Should be something hard to guess (acts as security through obscurity)
     - Will be created automatically on first use

   - **Access token**: Ask if user wants to use an access token
     - Optional but recommended for security
     - Explain: Can be created in ntfy.sh web UI → Settings → Access Tokens
     - If user doesn't have one, they can leave it empty (notifications will work without it on public server)

3. **Validate inputs**:
   - Ensure URL starts with `http://` or `https://`
   - Remove trailing slash from URL if present
   - Ensure topic name is not empty
   - Topic name should be URL-safe (alphanumeric, hyphens, underscores)
   - Warn if topic name is very short or guessable

4. **Determine configuration directory**:
   - Check if CLAUDE_CONFIG_DIR environment variable is set
   - If set, use `${CLAUDE_CONFIG_DIR}/.claude/`
   - Otherwise, use `~/.claude/`
   - Create directory if needed:
     ```bash
     CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-${HOME}}/.claude"
     mkdir -p "${CLAUDE_DIR}"
     ```

5. **Write configuration file** using Write tool to `${CLAUDE_DIR}/claude-notifications.local.md`:
   ```yaml
   ---
   ntfy_url: "USER_PROVIDED_URL"
   ntfy_topic: "USER_PROVIDED_TOPIC"
   ntfy_token: "USER_PROVIDED_TOKEN_OR_EMPTY"
   ---
   ```

6. **Set secure file permissions**:
   ```bash
   CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-${HOME}}/.claude"
   chmod 600 "${CLAUDE_DIR}/claude-notifications.local.md"
   ```

7. **Verify configuration** by running the check script:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/check-config.sh
   ```

8. **Help user subscribe to notifications**:
   - Inform user they need to subscribe to their topic to receive notifications
   - Provide options:
     - **Web**: `https://ntfy.sh/their-topic-name` (open in browser)
     - **Mobile app**: Download ntfy app, subscribe to topic
     - **CLI**: `curl -s 'https://ntfy.sh/their-topic-name/json' | jq`

9. **Send test notification** to verify setup:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/send-notification.sh test 3 "Setup completed successfully!"
   ```

10. **Inform user**:
   - Configuration saved successfully
   - Test notification sent (check your subscribed devices)
   - Notifications are now active
   - Remind them they can use `/notify:pause` and `/notify:resume` to control notifications
   - Suggest running `/notify:test` anytime to verify setup
   - For security, remind them to use a strong, unique topic name

## Tips

- **Public vs Self-hosted**:
  - Public ntfy.sh (https://ntfy.sh): Zero setup, free, suitable for most users
  - Self-hosted: More control, better privacy, requires server
    - Docker: `docker run -d -p 80:80 binwiederhier/ntfy serve`
    - [Installation guide](https://docs.ntfy.sh/install)

- **Topic security**:
  - Choose a long, unique topic name (minimum 10+ characters)
  - Avoid using project names, usernames, or other identifiable info
  - Topics with access tokens are more secure
  - Example good topic: `claude-abc123xyz789`

- **Access tokens**:
  - Log into ntfy.sh web UI
  - Navigate to Settings → Access Tokens
  - Click "Create Token"
  - Grant "Write" permission to your topic
  - Copy the token (format: `tk_live_XXX`)

## Security Notes

- Configuration file contains sensitive credentials (access token)
- File permissions are set to 600 (owner read/write only)
- Always use HTTPS URLs (https://ntfy.sh uses HTTPS)
- Never commit `.local.md` files to version control
- Topics are visible to anyone who knows the name; don't include sensitive info in notifications

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

2. **Check if user has Gotify server** using AskUserQuestion:
   - Ask: "Do you have a Gotify server already running?"
   - Options:
     - "Yes, I have a Gotify server" → Skip to step 3
     - "No, help me set one up" → Proceed to deploy Gotify

   **If user needs Gotify deployment**:
   - Check if Docker is available:
     ```bash
     docker --version
     ```
   - If Docker is not available, inform user they need to install Docker first:
     - Linux: `curl -fsSL https://get.docker.com | sh`
     - Or follow: https://docs.docker.com/engine/install/

   - Ask user using AskUserQuestion:
     - **Port**: Which port to expose Gotify on (suggest 8080 if 80 is taken)
     - **Data directory**: Where to store Gotify data (suggest `~/gotify-data`)

   - Deploy Gotify container:
     ```bash
     docker run -d \
       --name gotify \
       --restart unless-stopped \
       -p USER_PROVIDED_PORT:80 \
       -v USER_PROVIDED_DATA_DIR:/app/data \
       gotify/server
     ```

   - Wait for container to start (2-3 seconds):
     ```bash
     sleep 3
     ```

   - Check if Gotify is running:
     ```bash
     docker ps | grep gotify
     ```

   - Get default admin credentials:
     - Username: `admin`
     - Password: `admin`

   - Inform user:
     - Gotify is now running at `http://localhost:USER_PROVIDED_PORT`
     - Default login: admin/admin
     - **IMPORTANT**: Change the default password immediately!
     - Open the web UI to:
       1. Log in with admin/admin
       2. Change password in Settings → Users
       3. Create an application in Settings → Apps
       4. Copy the application token

   - Set GOTIFY_URL for next steps:
     - Use `http://localhost:USER_PROVIDED_PORT`

3. **Gather required information** using AskUserQuestion:
   - **Gotify server URL**: Ask for the full URL (e.g., `https://gotify.example.com`)
     - Must be their self-hosted Gotify instance (no public server)
     - Should NOT include trailing slash
   - **Application token**: Ask for the Gotify application token
     - Explain how to get one: Create an application in Gotify web UI → Settings → Apps → Create Application
     - Token format: Alphanumeric string (e.g., `Ahc4eJUerK8MpYG`)
     - Note: This provides built-in user isolation, unlike topic-based systems

4. **Validate inputs**:
   - Ensure URL starts with `http://` or `https://`
   - For production, recommend HTTPS (can set up later with reverse proxy)
   - Remove trailing slash from URL if present
   - Ensure token is not empty

5. **Create configuration directory** if needed:
   ```bash
   mkdir -p ~/.claude
   ```

6. **Write configuration file** using Write tool to `~/.claude/claude-notifications.local.md`:
   ```yaml
   ---
   gotify_url: "USER_PROVIDED_URL"
   gotify_token: "USER_PROVIDED_TOKEN"
   ---
   ```

7. **Set secure file permissions**:
   ```bash
   chmod 600 ~/.claude/claude-notifications.local.md
   ```

8. **Verify configuration** by running the check script:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/check-config.sh
   ```

9. **Send test notification** to verify setup:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/send-notification.sh test 5 "Setup completed successfully!"
   ```

10. **Inform user**:
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

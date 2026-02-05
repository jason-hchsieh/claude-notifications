---
gotify_url: "https://gotify.example.com"
gotify_token: "Ahc4eJUerK8MpYG"
---

# Claude Notifications Configuration

This is an example configuration file for the claude-notifications plugin.

## Setup Instructions

1. Copy this file to `~/.claude/claude-notifications.local.md`:
   ```bash
   mkdir -p ~/.claude
   cp example-settings.local.md ~/.claude/claude-notifications.local.md
   ```

2. Edit the configuration file with your values:
   - `gotify_url`: Your Gotify server URL
     - Must be self-hosted: `https://gotify.example.com`
     - Do NOT include trailing slash

   - `gotify_token`: Your application token
     - Get from: Gotify web UI → Settings → Apps → Create Application
     - Copy the token shown after creating the application
     - Token is shown only once, so save it securely

3. Secure the file (recommended):
   ```bash
   chmod 600 ~/.claude/claude-notifications.local.md
   ```

4. Test the configuration:
   ```
   /notify:test
   ```

## Alternative: Use Setup Command

Instead of manually creating this file, you can run:
```
/notify:setup
```

This will guide you through an interactive setup process.

## Security Notes

- This file contains sensitive credentials (access token)
- Never commit this file to version control
- Keep file permissions restricted (chmod 600)
- Use HTTPS URLs only

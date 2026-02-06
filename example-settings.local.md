---
ntfy_url: "https://ntfy.sh"
ntfy_topic: "my-secret-topic"
ntfy_token: "tk_live_ABC123xyz"
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
   - `ntfy_url`: Your ntfy.sh server URL
     - Use public server: `https://ntfy.sh`
     - Or self-hosted: `https://ntfy.example.com`
     - Do NOT include trailing slash

   - `ntfy_topic`: Your notification topic name
     - Choose any unique name for your notifications (e.g., `my-claude-notifications`)
     - Should be something hard to guess (used as unique identifier)
     - Topics are created automatically when first used

   - `ntfy_token`: Your access token (optional but recommended for security)
     - Create in ntfy.sh web UI: Settings → Access Tokens → Create Token
     - Or leave as empty string if using public topic without auth
     - Provides write access to your topic

3. Secure the file (recommended):
   ```bash
   chmod 600 ~/.claude/claude-notifications.local.md
   ```

4. Subscribe to notifications:
   - **Web**: Open `https://ntfy.sh/my-secret-topic` in browser
   - **Mobile**: Download ntfy app, subscribe to your topic
   - **CLI**: `curl -s 'https://ntfy.sh/my-secret-topic/json' | jq`

5. Test the configuration:
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

- Choose a long, unique topic name (avoid guessable names)
- This file contains sensitive credentials (access token)
- Never commit this file to version control
- Keep file permissions restricted (chmod 600)
- Use HTTPS URLs only
- Use access tokens to restrict write access to your topic

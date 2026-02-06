# claude-notifications

Send notifications to your local machine when Claude Code (running on a remote workstation) reaches stopping points that need your attention.

## Overview

When running Claude Code on a remote workstation, it's easy to miss when Claude needs input or completes a task. This plugin uses [ntfy.sh](https://ntfy.sh) to send push notifications to your local device whenever Claude:

- Asks a question (AskUserQuestion)
- Requests approval (ExitPlanMode)
- Completes a task
- Encounters an error
- Stops and waits for input

## Why ntfy.sh?

- **Zero setup**: No server to deploy or manage
- **Lightweight**: Minimal dependencies, works anywhere
- **Free**: Public server available at ntfy.sh
- **Optional self-hosting**: Can self-host if desired
- **Cross-platform**: Web, mobile (iOS/Android), and CLI support

## Features

- **Automatic notifications** on all Claude stopping points
- **Priority-based alerts**: Urgent for questions, high for errors, normal for completions
- **Pause/resume** notifications when needed
- **Easy setup** with interactive configuration
- **Multiple access methods**: Web browser, mobile apps, or CLI

## Prerequisites

1. **ntfy.sh server** (public or self-hosted)
   - Public: Use https://ntfy.sh (no setup required)
   - Self-hosted: [Installation guide](https://docs.ntfy.sh/install)
   - Docker: `docker run -d -p 80:80 binwiederhier/ntfy serve`

2. **A topic name** (unique identifier for your notifications)
   - Choose any name: `my-claude-notifications`, `claude-xyz`, etc.
   - Topics are created automatically on first use

3. **Access token** (optional but recommended)
   - Create in ntfy.sh web UI: Settings → Access Tokens
   - Provides security by restricting write access

4. **ntfy mobile app** (optional)
   - [iOS](https://apps.apple.com/app/ntfy/id1625396347)
   - [Android](https://play.google.com/store/apps/details?id=io.ntfy.android)
   - [Web](https://ntfy.sh) - works on any browser

## Installation

### Install the plugin

```bash
# Clone or copy this plugin to your Claude plugins directory
cd ~/.claude/plugins
git clone <repository-url> claude-notifications

# Or install from Claude marketplace (if published)
cc plugin install claude-notifications
```

### Configure notifications

Run the setup command in Claude Code:

```
/notify:setup
```

This will prompt you for:
- ntfy.sh server URL (use `https://ntfy.sh` for public, or your self-hosted URL)
- Topic name (e.g., `my-claude-notifications`)
- Access token (optional, leave empty for public topics)

The configuration is stored in `~/.claude/claude-notifications.local.md`:

```yaml
---
ntfy_url: "https://ntfy.sh"
ntfy_topic: "my-secret-topic"
ntfy_token: "tk_live_ABC123xyz"
---
```

### Test notifications

```
/notify:test
```

You should receive a test notification on your device.

## Usage

### Automatic notifications

Once configured, notifications are sent automatically when Claude:

- **🔔 Asks a question** (Priority: Urgent)
- **🔔 Requests approval** (Priority: Urgent)
- **⚠️ Encounters an error** (Priority: High)
- **✅ Completes a task** (Priority: Default)
- **🛑 Stops and waits** (Priority: Default)

### Pause/resume notifications

Temporarily disable notifications:

```
/notify:pause
```

Re-enable notifications:

```
/notify:resume
```

### Test notifications

Send a test notification:

```
/notify:test
```

## Commands

| Command | Description |
|---------|-------------|
| `/notify:setup` | Interactive setup wizard to configure Gotify |
| `/notify:test` | Validate configuration and send test notification |
| `/notify:pause` | Temporarily disable notifications |
| `/notify:resume` | Re-enable notifications |

## Configuration

Configuration is stored in the Claude config directory:
- Default: `~/.claude/claude-notifications.local.md`
- Respects `CLAUDE_CONFIG_DIR` environment variable if set

```yaml
---
ntfy_url: "https://ntfy.sh"              # Required: ntfy.sh server URL
ntfy_topic: "my-secret-topic"            # Required: Your topic name
ntfy_token: "tk_live_ABC123xyz"          # Optional: Access token for security
---
```

### Manual configuration

You can manually create or edit the configuration file:

```bash
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-${HOME}}/.claude"
mkdir -p "${CLAUDE_DIR}"
cat > "${CLAUDE_DIR}/claude-notifications.local.md" << 'EOF'
---
ntfy_url: "https://ntfy.sh"
ntfy_topic: "my-secret-topic"
ntfy_token: "tk_live_ABC123xyz"
---
EOF
```

### Custom configuration location

Set `CLAUDE_CONFIG_DIR` to use a custom configuration directory:
```bash
export CLAUDE_CONFIG_DIR="/custom/path"
# Plugin will use /custom/path/.claude/claude-notifications.local.md
```

## How it works

1. **Hooks** listen for Claude Code events (Stop, AskUserQuestion, ExitPlanMode, etc.)
2. When an event occurs, **send-notification.sh** script is called
3. Script checks if notifications are paused (`~/.claude/.notifications-paused`)
4. If not paused, constructs and sends notification via Gotify API
5. Notification includes:
   - Event type in title
   - Project name (working directory basename)
   - Appropriate priority (0-10 scale)
   - Emoji in title

## Troubleshooting

### Notifications not received

1. **Check configuration**:
   ```
   /notify:test
   ```

2. **Verify ntfy.sh server is accessible**:
   ```bash
   curl -H "Title: Test" -d "Hello" https://ntfy.sh/my-secret-topic
   ```

3. **Check if notifications are paused**:
   ```bash
   ls ~/.claude/.notifications-paused
   # If exists, run /notify:resume
   ```

4. **Verify you're subscribed to the topic**:
   - Web: Open `https://ntfy.sh/my-secret-topic` in browser
   - Mobile app: Ensure you've subscribed to your topic name
   - Check notification permissions on your device

5. **Verify hooks are enabled**:
   - Check Claude Code is running with plugin enabled
   - Use `claude --debug` to see hook execution

### Configuration errors

If `/notify:setup` fails or configuration is invalid:

1. Manually check the config file exists:
   ```bash
   cat ~/.claude/claude-notifications.local.md
   ```

2. Verify required fields are present: `ntfy_url`, `ntfy_topic`, `ntfy_token`

3. Test ntfy.sh access manually:
   ```bash
   curl -H "Title: Test" -H "Priority: 3" -d "Manual test" https://ntfy.sh/my-secret-topic
   ```

4. Verify access token (if using one):
   ```bash
   curl -H "Authorization: Bearer YOUR_TOKEN" -d "Test" https://ntfy.sh/my-secret-topic
   ```

### Permission issues

If scripts fail to execute:

```bash
chmod +x ~/.claude/plugins/claude-notifications/scripts/*.sh
chmod +x ~/.claude/plugins/claude-notifications/hooks/scripts/*.sh
```

## Security

- **Access tokens**: Stored in `~/.claude/claude-notifications.local.md` (not committed to git)
- **File permissions**: Configuration file should be readable only by you (chmod 600)
- **HTTPS**: Always use HTTPS URLs (ntfy.sh uses HTTPS by default)
- **Topic security**: Use a long, unique topic name (avoid easily guessable names)
- **Access control**: Use access tokens to restrict write access to your topic
- **Topic privacy**: Topics are visible to anyone who knows the name (don't use sensitive data in messages)

## License

MIT

## Contributing

Issues and pull requests welcome!

## Resources

- [ntfy.sh Documentation](https://docs.ntfy.sh/)
- [ntfy.sh Installation Guide](https://docs.ntfy.sh/install)
- [ntfy.sh Android App](https://play.google.com/store/apps/details?id=io.ntfy.android)
- [ntfy.sh iOS App](https://apps.apple.com/app/ntfy/id1625396347)
- [Claude Code Plugin Development](https://github.com/anthropics/claude-code)

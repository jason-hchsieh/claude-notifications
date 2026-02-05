# claude-notifications

Send notifications to your local machine when Claude Code (running on a remote workstation) reaches stopping points that need your attention.

## Overview

When running Claude Code on a remote workstation, it's easy to miss when Claude needs input or completes a task. This plugin uses [Gotify](https://gotify.net) to send push notifications to your local device whenever Claude:

- Asks a question (AskUserQuestion)
- Requests approval (ExitPlanMode)
- Completes a task
- Encounters an error
- Stops and waits for input

## Why Gotify?

- **Built-in user isolation**: Each application gets its own token, no topic-based guessing
- **Self-hosted**: Complete control over your notification server
- **Secure**: No public topic exposure like ntfy.sh
- **Simple**: Easy to deploy with Docker
- **Lightweight**: Minimal resource requirements

## Features

- **Automatic notifications** on all Claude stopping points
- **Priority-based alerts**: Urgent for questions, high for errors, normal for completions
- **Pause/resume** notifications when needed
- **Easy setup** with interactive configuration
- **Secure authentication** with application tokens

## Prerequisites

1. **Gotify server** (self-hosted)
   - [Installation guide](https://gotify.net/docs/install)
   - Docker: `docker run -p 80:80 -v /var/gotify/data:/app/data gotify/server`
   - Supports SQLite or PostgreSQL

2. **Application token** (create in Gotify web UI)
   - Log into Gotify → Settings → Apps → Create Application
   - Copy the generated token

3. **Gotify mobile app** (optional but recommended)
   - [iOS](https://apps.apple.com/app/gotify/id1514458538)
   - [Android](https://play.google.com/store/apps/details?id=com.github.gotify)
   - [F-Droid](https://f-droid.org/packages/com.github.gotify/)

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
- Gotify server URL (e.g., `https://gotify.example.com`)
- Application token (from Gotify web UI)

The configuration is stored in `~/.claude/claude-notifications.local.md`:

```yaml
---
gotify_url: "https://gotify.example.com"
gotify_token: "Ahc4eJUerK8MpYG"
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

Configuration is stored globally in `~/.claude/claude-notifications.local.md`:

```yaml
---
gotify_url: "https://gotify.example.com"  # Required: Your Gotify server URL
gotify_token: "Ahc4eJUerK8MpYG"           # Required: Application token
---
```

### Manual configuration

You can manually create or edit the configuration file:

```bash
mkdir -p ~/.claude
cat > ~/.claude/claude-notifications.local.md << 'EOF'
---
gotify_url: "https://gotify.example.com"
gotify_token: "Ahc4eJUerK8MpYG"
---
EOF
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

2. **Verify Gotify server is accessible**:
   ```bash
   curl -X POST "https://gotify.example.com/message?token=YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"title":"Test","message":"Hello","priority":5}'
   ```

3. **Check if notifications are paused**:
   ```bash
   ls ~/.claude/.notifications-paused
   # If exists, run /notify:resume
   ```

4. **Verify hooks are enabled**:
   - Check Claude Code is running with plugin enabled
   - Use `claude --debug` to see hook execution

### Configuration errors

If `/notify:setup` fails or configuration is invalid:

1. Manually check the config file exists:
   ```bash
   cat ~/.claude/claude-notifications.local.md
   ```

2. Verify required fields are present: `gotify_url`, `gotify_token`

3. Test Gotify access manually:
   ```bash
   curl -X POST "https://gotify.example.com/message?token=YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"title":"Test","message":"Manual test","priority":5}'
   ```

### Permission issues

If scripts fail to execute:

```bash
chmod +x ~/.claude/plugins/claude-notifications/scripts/*.sh
chmod +x ~/.claude/plugins/claude-notifications/hooks/scripts/*.sh
```

## Security

- **Application tokens**: Stored in `~/.claude/claude-notifications.local.md` (not committed to git)
- **File permissions**: Configuration file should be readable only by you (chmod 600)
- **HTTPS**: Always use HTTPS URLs for Gotify servers
- **Self-hosted**: Gotify requires self-hosting, providing complete control
- **User isolation**: Each application token is isolated, no topic guessing needed

## License

MIT

## Contributing

Issues and pull requests welcome!

## Resources

- [Gotify Documentation](https://gotify.net/docs/)
- [Gotify Installation Guide](https://gotify.net/docs/install)
- [Claude Code Plugin Development](https://github.com/anthropics/claude-code)
- [Gotify Mobile Apps](https://gotify.net/docs/)

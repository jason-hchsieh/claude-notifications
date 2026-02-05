# claude-notifications

Send notifications to your local machine when Claude Code (running on a remote workstation) reaches stopping points that need your attention.

## Overview

When running Claude Code on a remote workstation, it's easy to miss when Claude needs input or completes a task. This plugin uses [ntfy.sh](https://ntfy.sh) to send push notifications to your local device whenever Claude:

- Asks a question (AskUserQuestion)
- Requests approval (ExitPlanMode)
- Completes a task
- Encounters an error
- Stops and waits for input

## Features

- **Automatic notifications** on all Claude stopping points
- **Priority-based alerts**: Urgent for questions, high for errors, normal for completions
- **Pause/resume** notifications when needed
- **Easy setup** with interactive configuration
- **Self-hosted or public** ntfy.sh support

## Prerequisites

1. **ntfy.sh server** (self-hosted or use public ntfy.sh)
   - Self-hosted: [Installation guide](https://docs.ntfy.sh/install/)
   - Public: Use `https://ntfy.sh` (less private but easier)

2. **Access token** (for authentication)
   - Self-hosted: [Generate token](https://docs.ntfy.sh/publish/#authentication)
   - Public: [Create account](https://ntfy.sh/account)

3. **ntfy mobile app** (optional but recommended)
   - [iOS](https://apps.apple.com/us/app/ntfy/id1625396347)
   - [Android](https://play.google.com/store/apps/details?id=io.heckel.ntfy)

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
- ntfy.sh server URL (e.g., `https://ntfy.example.com` or `https://ntfy.sh`)
- Access token
- Topic name (e.g., `claude-notifications`)

The configuration is stored in `~/.claude/claude-notifications.local.md`:

```yaml
---
ntfy_url: "https://ntfy.example.com"
ntfy_token: "tk_your_access_token_here"
ntfy_topic: "claude-notifications"
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
| `/notify:setup` | Interactive setup wizard to configure ntfy.sh |
| `/notify:test` | Validate configuration and send test notification |
| `/notify:pause` | Temporarily disable notifications |
| `/notify:resume` | Re-enable notifications |

## Configuration

Configuration is stored globally in `~/.claude/claude-notifications.local.md`:

```yaml
---
ntfy_url: "https://ntfy.example.com"  # Required: Your ntfy.sh server URL
ntfy_token: "tk_xxxxxxxxxxxxx"         # Required: Access token for authentication
ntfy_topic: "claude-notifications"     # Required: Topic/channel name
---
```

### Manual configuration

You can manually create or edit the configuration file:

```bash
mkdir -p ~/.claude
cat > ~/.claude/claude-notifications.local.md << 'EOF'
---
ntfy_url: "https://ntfy.sh"
ntfy_token: "tk_your_token_here"
ntfy_topic: "my-claude-alerts"
---
EOF
```

## How it works

1. **Hooks** listen for Claude Code events (Stop, AskUserQuestion, ExitPlanMode, etc.)
2. When an event occurs, **send-notification.sh** script is called
3. Script checks if notifications are paused (`~/.claude/.notifications-paused`)
4. If not paused, constructs and sends notification via ntfy.sh API
5. Notification includes:
   - Event type in title
   - Project name (working directory basename)
   - Appropriate priority and emoji tags

## Troubleshooting

### Notifications not received

1. **Check configuration**:
   ```
   /notify:test
   ```

2. **Verify ntfy.sh server is accessible**:
   ```bash
   curl -H "Authorization: Bearer YOUR_TOKEN" https://your-server.com/topic-name
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

2. Verify required fields are present: `ntfy_url`, `ntfy_token`, `ntfy_topic`

3. Test ntfy.sh access manually:
   ```bash
   curl -d "Test message" \
     -H "Authorization: Bearer YOUR_TOKEN" \
     https://your-server.com/topic-name
   ```

### Permission issues

If scripts fail to execute:

```bash
chmod +x ~/.claude/plugins/claude-notifications/scripts/*.sh
chmod +x ~/.claude/plugins/claude-notifications/hooks/scripts/*.sh
```

## Security

- **Access tokens**: Stored in `~/.claude/claude-notifications.local.md` (not committed to git)
- **File permissions**: Configuration file should be readable only by you
- **HTTPS**: Always use HTTPS URLs for ntfy.sh servers
- **Self-hosting**: Recommended for sensitive projects

## License

MIT

## Contributing

Issues and pull requests welcome!

## Resources

- [ntfy.sh Documentation](https://docs.ntfy.sh/)
- [Claude Code Plugin Development](https://github.com/anthropics/claude-code)
- [ntfy.sh Self-hosting Guide](https://docs.ntfy.sh/install/)

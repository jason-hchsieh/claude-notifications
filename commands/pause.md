---
name: pause
description: Temporarily disable notifications
allowed-tools: [Bash]
argument-hint: ""
---

# Pause Notifications

Temporarily disable all Claude Code notifications. Useful when you're actively monitoring Claude and don't need interruptions.

## Instructions

1. **Create the pause state file**:
   - Use Bash tool to create `~/.claude/.notifications-paused`:
     ```bash
     mkdir -p ~/.claude && touch ~/.claude/.notifications-paused
     ```

2. **Verify pause file was created**:
   - Check that the file exists:
     ```bash
     ls -la ~/.claude/.notifications-paused
     ```

3. **Inform user**:
   - Notifications are now paused globally
   - All Claude Code sessions will skip notifications
   - Automatic notifications will resume when they run `/notify:resume`
   - The pause state persists across Claude Code sessions

## Behavior

When notifications are paused:
- ✅ Hook scripts still execute (minimal overhead)
- ✅ send-notification.sh detects pause file and exits silently
- ✅ No notifications sent to ntfy.sh
- ✅ Applies to all Claude Code sessions globally
- ✅ Persists until `/notify:resume` is run

## Use Cases

- **Active monitoring**: You're watching Claude work and don't need alerts
- **Focus time**: Working on something else and don't want interruptions
- **Debugging**: Testing plugin behavior without spam notifications
- **Temporary disable**: Quick way to turn off notifications without changing config

## Resuming Notifications

To re-enable notifications, run:
```
/notify:resume
```

## Tips

- Pause state is global - affects all Claude Code sessions
- If you forget notifications are paused, run `/notify:test` to check
- The pause file is just a flag - no data is stored in it
- Safe to manually delete the file: `rm ~/.claude/.notifications-paused`

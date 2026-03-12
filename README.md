# cbk-headsup #

A lightweight, secure, and polished RP chat bubble system for FiveM.

`cbk-headsup` gives players a clean input panel and renders proximity-based chat bubbles above player heads with distance fade, sanitization, and anti-spam protections.

## Highlights

- Standalone (no framework dependency)
- Proximity broadcast (server-side distance filtering)
- On-screen bubble rendering with world-to-screen projection
- Distance fade for readability
- Built-in rate limiting and text sanitization
- Blocklist support for links/advertising text
- Draggable input panel UI
- Compact, high-visibility bubble style tuned for RP

## Version

Current version: `1.0.1`

## Resource Structure

```text
cbk-headsup/
  fxmanifest.lua
  LICENSE
  CHANGELOG.md
  README.md
  shared/
    config.lua
  client/
    main.lua
  server/
    server.lua
  ui/
    index.html
    style.css
    script.js
```

## Installation

1. Place `cbk-headsup` in your server `resources` folder.
2. Add this line to your `resources.cfg`:

```cfg
ensure cbk-headsup
```

3. Restart the server or run:

```cfg
restart cbk-headsup
```

## Usage

Default open command:

```text
/bubbleui
```

Default keybind:

```text
F2
```

Both are configurable in `shared/config.lua`.

## Configuration

All settings are in `shared/config.lua`.

### UI / Control

- `Config.Command`
- `Config.Keybind`

### Bubble Behavior

- `Config.DisplayTimeMs`: how long a bubble stays visible
- `Config.MaxLength`: max message length
- `Config.MaxLines`: reserved for presentation limits

### Distances

- `Config.RenderDistance`: client render distance for visible bubbles
- `Config.ServerBroadcastDistance`: who receives bubble updates from server

### Update / Anti-Spam

- `Config.RateLimitMs`: per-player send cooldown
- `Config.RenderTickMs`: UI refresh cadence when bubbles are visible

### Bubble Look

- `Config.WorldZOffset`: vertical bubble anchor above ped
- `Config.DistanceFadeStart`: fade begins at this distance

### Filtering / Sanitization

- `Config.BlockedSubstrings`: plain-text blocklist entries
- `Config.NormalizeWhitespace`: normalize whitespace and control characters

## Security & Validation

Server-side checks in `server/server.lua` include:

- Text type validation
- Control character cleanup
- Whitespace normalization (optional)
- Trimming and empty message rejection
- Max length enforcement
- Blocklist substring rejection
- Per-player rate limiting

This keeps the client UI simple while ensuring authoritative server validation.

## How It Works

1. Player opens UI (`/bubbleui` or keybind F2).
2. NUI sends message to client callback (`send`).
3. Client triggers server event: `ultra_chatbubble:send`.
4. Server sanitizes/rate-limits and sends to nearby players.
5. Clients render active bubbles with world-space tracking + fade.

## Events

### Server Event

- `ultra_chatbubble:send` (client -> server)

### Client Events

- `ultra_chatbubble:setBubble`
- `ultra_chatbubble:clearBubble`

## UI Notes

- Input panel can be dragged by header.
- NUI close/send use callback POSTs and proper CSP connect policy.
- Panel focus is released cleanly on close and on resource stop.

## Troubleshooting

### Bubble UI does not open

- Confirm `ensure cbk-headsup` is present and resource started.
- Verify no keybind conflict with `Config.Keybind`.

### Bubbles not visible

- Make sure players are within `Config.ServerBroadcastDistance`.
- Increase `Config.RenderDistance` if needed.
- Adjust `Config.WorldZOffset` for ped/model camera angle differences.

### Messages not sending

- Check `Config.RateLimitMs` (anti-spam cooldown).
- Check `Config.BlockedSubstrings` and sanitization constraints.

## Changelog

See `CHANGELOG.md` for release history.

## License

See `LICENSE`.


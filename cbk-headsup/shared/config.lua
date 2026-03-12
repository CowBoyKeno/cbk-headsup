Config = {}

-- UI / control
Config.Command = 'bubbleui'
Config.Keybind = 'F2'

-- Bubble behavior
Config.DisplayTimeMs = 30000
Config.MaxLength = 160
Config.MaxLines = 4

-- Distances
Config.RenderDistance = 22.0        -- client render distance
Config.ServerBroadcastDistance = 30.0 -- who receives the update event

-- Update / spam protection
Config.RateLimitMs = 2000
Config.RenderTickMs = 75

-- Bubble look
Config.WorldZOffset = 0.92
Config.DistanceFadeStart = 14.0

-- Optional lightweight text filtering
Config.BlockedSubstrings = {
    'discord.gg/',
    'http://',
    'https://',
    'www.'
}

-- If true, strips most non-basic control characters and normalizes whitespace
Config.NormalizeWhitespace = true
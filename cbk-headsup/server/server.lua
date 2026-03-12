local lastSendAt = {}

local function trim(str)
    return (str:gsub('^%s+', ''):gsub('%s+$', ''))
end

local function normalizeWhitespace(str)
    -- replace newlines/tabs with spaces, collapse repeated spaces
    str = str:gsub('[\r\n\t]', ' ')
    str = str:gsub('%s%s+', ' ')
    return str
end

local function sanitizeText(input)
    if type(input) ~= 'string' then
        return nil
    end

    local text = input

    -- Remove null bytes and most ASCII control chars except regular spaces
    text = text:gsub('%z', '')
    text = text:gsub('[%c]', ' ')

    if Config.NormalizeWhitespace then
        text = normalizeWhitespace(text)
    end

    text = trim(text)

    if text == '' then
        return nil
    end

    if #text > Config.MaxLength then
        text = text:sub(1, Config.MaxLength)
        text = trim(text)
    end

    local lowered = text:lower()
    for i = 1, #Config.BlockedSubstrings do
        local blocked = Config.BlockedSubstrings[i]:lower()
        if lowered:find(blocked, 1, true) then
            return nil
        end
    end

    return text
end

local function getNearbyPlayers(sourceId, maxDistance)
    local sourcePed = GetPlayerPed(sourceId)
    if sourcePed == 0 then
        return {}
    end

    local sourceCoords = GetEntityCoords(sourcePed)
    local recipients = {}

    local players = GetPlayers()
    for i = 1, #players do
        local targetId = tonumber(players[i])
        if targetId then
            local targetPed = GetPlayerPed(targetId)
            if targetPed ~= 0 then
                local targetCoords = GetEntityCoords(targetPed)
                local dist = #(sourceCoords - targetCoords)
                if dist <= maxDistance then
                    recipients[#recipients + 1] = targetId
                end
            end
        end
    end

    return recipients
end

RegisterNetEvent('ultra_chatbubble:send', function(rawText)
    local src = source
    if not src then
        return
    end

    local now = GetGameTimer()
    local last = lastSendAt[src] or 0

    if (now - last) < Config.RateLimitMs then
        return
    end

    local text = sanitizeText(rawText)
    if not text then
        return
    end

    lastSendAt[src] = now

    local recipients = getNearbyPlayers(src, Config.ServerBroadcastDistance)

    for i = 1, #recipients do
        TriggerClientEvent('ultra_chatbubble:setBubble', recipients[i], src, text, Config.DisplayTimeMs)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    lastSendAt[src] = nil

    local recipients = getNearbyPlayers(src, Config.ServerBroadcastDistance)
    for i = 1, #recipients do
        TriggerClientEvent('ultra_chatbubble:clearBubble', recipients[i], src)
    end
end)
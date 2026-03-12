local uiOpen = false
local activeBubbles = {}

local function closeUi()
    if not uiOpen then
        return
    end

    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'setInputVisible',
        visible = false
    })
end

local function openUi()
    if uiOpen then
        return
    end

    uiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'setInputVisible',
        visible = true
    })
end

RegisterCommand(Config.Command, function()
    openUi()
end, false)

RegisterKeyMapping(Config.Command, 'Open RP chat bubble UI', 'keyboard', Config.Keybind)

RegisterNUICallback('send', function(data, cb)
    local text = ''
    if type(data) == 'table' and type(data.text) == 'string' then
        text = data.text
    end

    TriggerServerEvent('ultra_chatbubble:send', text)
    closeUi()

    cb({ ok = true })
end)

RegisterNUICallback('close', function(_, cb)
    closeUi()
    cb({ ok = true })
end)

RegisterNetEvent('ultra_chatbubble:setBubble', function(serverId, text, durationMs)
    local playerId = GetPlayerFromServerId(serverId)
    if playerId == -1 then
        return
    end

    local ped = GetPlayerPed(playerId)
    if ped == 0 then
        return
    end

    local now = GetGameTimer()

    activeBubbles[serverId] = {
        text = text,
        playerId = playerId,
        expiresAt = now + (durationMs or Config.DisplayTimeMs)
    }
end)

RegisterNetEvent('ultra_chatbubble:clearBubble', function(serverId)
    activeBubbles[serverId] = nil
end)

CreateThread(function()
    while true do
        local now = GetGameTimer()
        local myPed = PlayerPedId()
        local myCoords = GetEntityCoords(myPed)
        local visible = {}
        local hasVisible = false

        for serverId, bubble in pairs(activeBubbles) do
            if now >= bubble.expiresAt then
                activeBubbles[serverId] = nil
            else
                local playerId = GetPlayerFromServerId(serverId)
                if playerId == -1 then
                    activeBubbles[serverId] = nil
                else
                    local ped = GetPlayerPed(playerId)
                    if ped == 0 or not DoesEntityExist(ped) then
                        activeBubbles[serverId] = nil
                    else
                        local coords = GetEntityCoords(ped)
                        local dist = #(coords - myCoords)

                        if dist <= Config.RenderDistance then
                            local onScreen, screenX, screenY = World3dToScreen2d(
                                coords.x,
                                coords.y,
                                coords.z + Config.WorldZOffset
                            )

                            if onScreen then
                                local alpha = 1.0
                                if dist > Config.DistanceFadeStart then
                                    local fadeSpan = (Config.RenderDistance - Config.DistanceFadeStart)
                                    if fadeSpan > 0.0 then
                                        alpha = 1.0 - ((dist - Config.DistanceFadeStart) / fadeSpan)
                                        if alpha < 0.0 then alpha = 0.0 end
                                        if alpha > 1.0 then alpha = 1.0 end
                                    end
                                end

                                hasVisible = true
                                visible[#visible + 1] = {
                                    id = tostring(serverId),
                                    x = screenX,
                                    y = screenY,
                                    alpha = alpha,
                                    text = bubble.text
                                }
                            end
                        end
                    end
                end
            end
        end

        SendNUIMessage({
            action = 'renderBubbles',
            bubbles = visible
        })

        if hasVisible then
            Wait(Config.RenderTickMs)
        else
            Wait(200)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    SetNuiFocus(false, false)
end)
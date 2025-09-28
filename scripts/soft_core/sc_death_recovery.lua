local levelLossRange = {
    [1] = 10,
    [10] = 5,
    [20] = 2,
    [30] = 2,
    [40] = 1,
    [50] = 1,
    [60] = 0,
    [61] = 1,
    [70] = 0,
    [71] = 1,
    [80] = 0,
}

local function lowerLevel(player)
    local level = player:GetLevel()
    local min_level = 1
    local level_loss = 10

    for _, k in pairs(get_sorted_keys(levelLossRange)) do
        if k > level then
            break
        end
        min_level = k
        level_loss = levelLossRange[k]
    end

    player:SendBroadcastMessage(level)
    player:SendBroadcastMessage(min_level)
    player:SendBroadcastMessage(level_loss)
    player:SendBroadcastMessage(math.max(level - level_loss, min_level))

    player:SetLevel(math.max(level - level_loss, min_level))
end

local function onOutdoorDeath(player)
    player:ResurrectPlayer()
    if player:IsAlliance() then
        player:TeleportTo("Stormwind")
        return
    end
    player:TeleportTo("Orgrimmar")

    lowerLevel(player)
end

local function onDeath(_, _, player)
    local map = player:GetMap()
    if map ~= nil and (map:IsDungeon() or map:IsBattleground() or map:IsRaid()) then
        return
    end
    onOutdoorDeath(player)
end

RegisterPlayerEvent(8, onDeath)

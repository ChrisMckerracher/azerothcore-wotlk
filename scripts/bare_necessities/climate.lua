-- Bare Necessities: climate modifiers

local CLIMATE_TYPES = {
    TEMPERATE = "temperate",
    TROPICAL = "tropical",
    ARID = "arid",
    ARCTIC = "arctic",
    SWAMP = "swamp",
    TAIGA = "taiga"
}

local CLIMATE_ZONES = {
    -- Eastern Kingdoms
    { mapId = 0, zoneId = 12, name = "Elwynn Forest", climate = CLIMATE_TYPES.TEMPERATE },
    { mapId = 0, zoneId = 1, name = "Dun Morogh", climate = CLIMATE_TYPES.ARCTIC },
    { mapId = 0, zoneId = 10, name = "Duskwood", climate = CLIMATE_TYPES.TEMPERATE },
    { mapId = 0, zoneId = 33, name = "Stranglethorn Vale", climate = CLIMATE_TYPES.TROPICAL },
    { mapId = 0, zoneId = 36, name = "Burning Steppes", climate = CLIMATE_TYPES.ARID },
    { mapId = 0, zoneId = 41, name = "Deadwind Pass", climate = CLIMATE_TYPES.SWAMP },
    { mapId = 0, zoneId = 44, name = "Redridge Mountains", climate = CLIMATE_TYPES.TEMPERATE },
    { mapId = 0, zoneId = 45, name = "Arathi Highlands", climate = CLIMATE_TYPES.TEMPERATE },
    { mapId = 0, zoneId = 46, name = "Badlands", climate = CLIMATE_TYPES.ARID },
    { mapId = 0, zoneId = 47, name = "Searing Gorge", climate = CLIMATE_TYPES.ARID },
    { mapId = 0, zoneId = 51, name = "Swamp of Sorrows", climate = CLIMATE_TYPES.SWAMP },
    { mapId = 0, zoneId = 85, name = "Tirisfal Glades", climate = CLIMATE_TYPES.SWAMP },
    { mapId = 0, zoneId = 130, name = "Silverpine Forest", climate = CLIMATE_TYPES.TAIGA },
    { mapId = 0, zoneId = 139, name = "Eastern Plaguelands", climate = CLIMATE_TYPES.TAIGA },
    { mapId = 0, zoneId = 142, name = "Dustwallow Marsh", climate = CLIMATE_TYPES.SWAMP },
    { mapId = 0, zoneId = 143, name = "Ashenvale", climate = CLIMATE_TYPES.TEMPERATE },
    { mapId = 0, zoneId = 144, name = "Feralas", climate = CLIMATE_TYPES.TROPICAL },
    { mapId = 0, zoneId = 145, name = "Darkshore", climate = CLIMATE_TYPES.TAIGA },
    { mapId = 0, zoneId = 148, name = "Loch Modan", climate = CLIMATE_TYPES.TEMPERATE },
    { mapId = 0, zoneId = 1497, name = "Undercity", climate = CLIMATE_TYPES.SWAMP },

    -- Kalimdor
    { mapId = 1, zoneId = 14, name = "Durotar", climate = CLIMATE_TYPES.ARID },
    { mapId = 1, zoneId = 16, name = "Azshara", climate = CLIMATE_TYPES.TEMPERATE },
    { mapId = 1, zoneId = 17, name = "The Barrens", climate = CLIMATE_TYPES.ARID },
    { mapId = 1, zoneId = 331, name = "Ashenvale", climate = CLIMATE_TYPES.TEMPERATE },
    { mapId = 1, zoneId = 357, name = "Feralas", climate = CLIMATE_TYPES.TROPICAL },
    { mapId = 1, zoneId = 400, name = "Thousand Needles", climate = CLIMATE_TYPES.ARID },
    { mapId = 1, zoneId = 405, name = "Desolace", climate = CLIMATE_TYPES.ARID },
    { mapId = 1, zoneId = 406, name = "Stonetalon Mountains", climate = CLIMATE_TYPES.TAIGA },
    { mapId = 1, zoneId = 440, name = "Tanaris", climate = CLIMATE_TYPES.ARID },
    { mapId = 1, zoneId = 490, name = "Un'Goro Crater", climate = CLIMATE_TYPES.TROPICAL },
    { mapId = 1, zoneId = 493, name = "Moonglade", climate = CLIMATE_TYPES.TAIGA },
    { mapId = 1, zoneId = 618, name = "Winterspring", climate = CLIMATE_TYPES.ARCTIC },
    { mapId = 1, zoneId = 1377, name = "Silithus", climate = CLIMATE_TYPES.ARID },
    { mapId = 1, zoneId = 1637, name = "Orgrimmar", climate = CLIMATE_TYPES.ARID },
    { mapId = 1, zoneId = 1657, name = "Darnassus", climate = CLIMATE_TYPES.TAIGA }
}

local function buildZoneLookup()
    local lookup = {}
    for _, zone in ipairs(CLIMATE_ZONES) do
        lookup[zone.zoneId] = zone
    end
    return lookup
end

local ZONE_LOOKUP = buildZoneLookup()

local function getClimateForPlayer(player)
    local zoneId = player:GetZoneId()
    local zone = ZONE_LOOKUP[zoneId]
    if zone then
        return zone.climate, zone.name
    end
    return CLIMATE_TYPES.TEMPERATE, "Unknown"
end

local function OnClimateTick()
    local players = GetPlayersInWorld()
    if not players then
        return
    end

    for _, player in pairs(players) do
        if player and player:IsInWorld() then
            local climate, zoneName = getClimateForPlayer(player)
            player:SendBroadcastMessage(string.format("Climate report: %s (%s)", zoneName, climate))
        end
    end
end

CreateLuaEvent(OnClimateTick, 5 * 60 * 1000, 0)

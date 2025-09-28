-- Bare Necessities: climate modifiers

local CLIMATE_TYPES = {
    TEMPERATE = "temperate",
    TROPICAL = "tropical",
    ARID = "arid",
    ARCTIC = "arctic",
    SWAMP = "swamp",
    TAIGA = "taiga"
}

local WEATHER_TYPES = {
    FINE = 0,
    RAIN = 1,
    SNOW = 2,
    STORM = 3,
    THUNDERS = 86,
    BLACKRAIN = 90
}

local CLIMATE_TICK_MS = 10 * 1000
local CLIMATE_DEFAULT_AURA = nil
local CLIMATE_DEBUFFS = {
    TEMPERATE = {
        [WEATHER_TYPES.FINE] = nil,        -- Clear skies (no effect)
        [WEATHER_TYPES.RAIN] = nil,
        [WEATHER_TYPES.SNOW] = nil,
        [WEATHER_TYPES.STORM] = nil,
        [WEATHER_TYPES.THUNDERS] = nil,
        [WEATHER_TYPES.BLACKRAIN] = nil
    },
    TROPICAL = {
        [WEATHER_TYPES.FINE] = nil,
        [WEATHER_TYPES.RAIN] = nil,
        [WEATHER_TYPES.SNOW] = nil,
        [WEATHER_TYPES.STORM] = nil,
        [WEATHER_TYPES.THUNDERS] = nil,
        [WEATHER_TYPES.BLACKRAIN] = nil
    },
    ARID = {
        [WEATHER_TYPES.FINE] = nil,
        [WEATHER_TYPES.RAIN] = nil,
        [WEATHER_TYPES.SNOW] = nil,
        [WEATHER_TYPES.STORM] = nil,
        [WEATHER_TYPES.THUNDERS] = nil,
        [WEATHER_TYPES.BLACKRAIN] = nil
    },
    ARCTIC = {
        [WEATHER_TYPES.FINE] = DEBUFFS.CHILLED,
        [WEATHER_TYPES.RAIN] = DEBUFFS.CHILLED,
        [WEATHER_TYPES.SNOW] = DEBUFFS.CHILLED,
        [WEATHER_TYPES.STORM] = DEBUFFS.CHILLED,
        [WEATHER_TYPES.THUNDERS] = DEBUFFS.CHILLED,
        [WEATHER_TYPES.BLACKRAIN] = DEBUFFS.CHILLED
    },
    SWAMP = {
        [WEATHER_TYPES.FINE] = nil,
        [WEATHER_TYPES.RAIN] = nil,
        [WEATHER_TYPES.SNOW] = nil,
        [WEATHER_TYPES.STORM] = nil,
        [WEATHER_TYPES.THUNDERS] = nil,
        [WEATHER_TYPES.BLACKRAIN] = nil
    },
    TAIGA = {
        [WEATHER_TYPES.FINE] = nil,
        [WEATHER_TYPES.RAIN] = nil,
        [WEATHER_TYPES.SNOW] = nil,
        [WEATHER_TYPES.STORM] = nil,
        [WEATHER_TYPES.THUNDERS] = nil,
        [WEATHER_TYPES.BLACKRAIN] = nil
    }
}

local PLAYER_CLIMATE_STATE = {}

local ClimateZone = {}
ClimateZone.__index = ClimateZone
ClimateZone.registry = {}

function ClimateZone:new(opts)
    local zone = setmetatable({
        mapId = opts.mapId,
        zoneId = opts.zoneId,
        name = opts.name,
        climate = opts.climate
    }, self)

    ClimateZone.registry[zone.zoneId] = zone
    return zone
end

function ClimateZone:getWeather()
    if type(GetWeather) ~= "function" then
        return nil
    end

    return GetWeather(self.mapId, self.zoneId)
end

local function GetDebuff(climate, weather)
    local climateTable = CLIMATE_DEBUFFS[climate]
    if not climateTable then
        return CLIMATE_DEFAULT_AURA
    end

    return climateTable[weather] or CLIMATE_DEFAULT_AURA
end

function ClimateZone:resolveAura(weather)
    return GetDebuff(self.climate, weather)
end

function ClimateZone:affect(player)
    local weather = self:getWeather()
    local weatherType = WEATHER_TYPES.FINE

    if weather and weather.GetWeatherState then
        weatherType = weather:GetWeatherState()
    end

    local auraId = self:resolveAura(weatherType)

    local guid = player:GetGUIDLow()
    local state = PLAYER_CLIMATE_STATE[guid]

    if not state then
        state = {}
        PLAYER_CLIMATE_STATE[guid] = state
    end

    local current = state.auraId
    local previousWeather = state.weatherType

    if current == auraId and previousWeather == weatherType and (not current or player:HasAura(current)) then
        return
    end

    if current then
        player:RemoveAura(current)
    end

    if auraId then
        player:AddAura(auraId, player)
    end

    state.auraId = auraId
    state.weatherType = weatherType
end

local CLIMATE_ZONES = {
    -- Eastern Kingdoms
    ClimateZone:new({ mapId = 0, zoneId = 12, name = "Elwynn Forest", climate = CLIMATE_TYPES.TEMPERATE }),
    ClimateZone:new({ mapId = 0, zoneId = 1, name = "Dun Morogh", climate = CLIMATE_TYPES.ARCTIC }),
    ClimateZone:new({ mapId = 0, zoneId = 10, name = "Duskwood", climate = CLIMATE_TYPES.TEMPERATE }),
    ClimateZone:new({ mapId = 0, zoneId = 33, name = "Stranglethorn Vale", climate = CLIMATE_TYPES.TROPICAL }),
    ClimateZone:new({ mapId = 0, zoneId = 36, name = "Burning Steppes", climate = CLIMATE_TYPES.ARID }),
    ClimateZone:new({ mapId = 0, zoneId = 41, name = "Deadwind Pass", climate = CLIMATE_TYPES.SWAMP }),
    ClimateZone:new({ mapId = 0, zoneId = 44, name = "Redridge Mountains", climate = CLIMATE_TYPES.TEMPERATE }),
    ClimateZone:new({ mapId = 0, zoneId = 45, name = "Arathi Highlands", climate = CLIMATE_TYPES.TEMPERATE }),
    ClimateZone:new({ mapId = 0, zoneId = 46, name = "Badlands", climate = CLIMATE_TYPES.ARID }),
    ClimateZone:new({ mapId = 0, zoneId = 47, name = "Searing Gorge", climate = CLIMATE_TYPES.ARID }),
    ClimateZone:new({ mapId = 0, zoneId = 51, name = "Swamp of Sorrows", climate = CLIMATE_TYPES.SWAMP }),
    ClimateZone:new({ mapId = 0, zoneId = 85, name = "Tirisfal Glades", climate = CLIMATE_TYPES.SWAMP }),
    ClimateZone:new({ mapId = 0, zoneId = 130, name = "Silverpine Forest", climate = CLIMATE_TYPES.TAIGA }),
    ClimateZone:new({ mapId = 0, zoneId = 139, name = "Eastern Plaguelands", climate = CLIMATE_TYPES.TAIGA }),
    ClimateZone:new({ mapId = 0, zoneId = 142, name = "Dustwallow Marsh", climate = CLIMATE_TYPES.SWAMP }),
    ClimateZone:new({ mapId = 0, zoneId = 143, name = "Ashenvale", climate = CLIMATE_TYPES.TEMPERATE }),
    ClimateZone:new({ mapId = 0, zoneId = 144, name = "Feralas", climate = CLIMATE_TYPES.TROPICAL }),
    ClimateZone:new({ mapId = 0, zoneId = 145, name = "Darkshore", climate = CLIMATE_TYPES.TAIGA }),
    ClimateZone:new({ mapId = 0, zoneId = 148, name = "Loch Modan", climate = CLIMATE_TYPES.TEMPERATE }),
    ClimateZone:new({ mapId = 0, zoneId = 1497, name = "Undercity", climate = CLIMATE_TYPES.SWAMP }),

    -- Kalimdor
    ClimateZone:new({ mapId = 1, zoneId = 14, name = "Durotar", climate = CLIMATE_TYPES.ARID }),
    ClimateZone:new({ mapId = 1, zoneId = 16, name = "Azshara", climate = CLIMATE_TYPES.TEMPERATE }),
    ClimateZone:new({ mapId = 1, zoneId = 17, name = "The Barrens", climate = CLIMATE_TYPES.ARID }),
    ClimateZone:new({ mapId = 1, zoneId = 331, name = "Ashenvale", climate = CLIMATE_TYPES.TEMPERATE }),
    ClimateZone:new({ mapId = 1, zoneId = 357, name = "Feralas", climate = CLIMATE_TYPES.TROPICAL }),
    ClimateZone:new({ mapId = 1, zoneId = 400, name = "Thousand Needles", climate = CLIMATE_TYPES.ARID }),
    ClimateZone:new({ mapId = 1, zoneId = 405, name = "Desolace", climate = CLIMATE_TYPES.ARID }),
    ClimateZone:new({ mapId = 1, zoneId = 406, name = "Stonetalon Mountains", climate = CLIMATE_TYPES.TAIGA }),
    ClimateZone:new({ mapId = 1, zoneId = 440, name = "Tanaris", climate = CLIMATE_TYPES.ARID }),
    ClimateZone:new({ mapId = 1, zoneId = 490, name = "Un'Goro Crater", climate = CLIMATE_TYPES.TROPICAL }),
    ClimateZone:new({ mapId = 1, zoneId = 493, name = "Moonglade", climate = CLIMATE_TYPES.TAIGA }),
    ClimateZone:new({ mapId = 1, zoneId = 618, name = "Winterspring", climate = CLIMATE_TYPES.ARCTIC }),
    ClimateZone:new({ mapId = 1, zoneId = 1377, name = "Silithus", climate = CLIMATE_TYPES.ARID }),
    ClimateZone:new({ mapId = 1, zoneId = 1637, name = "Orgrimmar", climate = CLIMATE_TYPES.ARID }),
    ClimateZone:new({ mapId = 1, zoneId = 1657, name = "Darnassus", climate = CLIMATE_TYPES.TAIGA })
}

local function clearClimateAura(player)
    local guid = player:GetGUIDLow()
    local state = PLAYER_CLIMATE_STATE[guid]
    if not state then
        return
    end

    if state.auraId then
        player:RemoveAura(state.auraId)
    end

    PLAYER_CLIMATE_STATE[guid] = nil
end

local function applyClimateEffects()
    local players = GetPlayersInWorld()
    if not players then
        return
    end

    for _, player in pairs(players) do
        if player and player:IsInWorld() then
            local zone = ClimateZone.registry[player:GetZoneId()]
            if zone then
                zone:affect(player)
            else
                clearClimateAura(player)
            end
        end
    end
end

CreateLuaEvent(applyClimateEffects, CLIMATE_TICK_MS, 0)

local function OnClimateLogout(event, player)
    clearClimateAura(player)
end

RegisterPlayerEvent(4, OnClimateLogout)

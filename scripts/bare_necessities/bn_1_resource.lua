-- Bare Necessities: necessity helpers

local TICK_MESSAGE = "Your %s is now %s."
local LOGIN_PREFIX = "Welcome back!"

Necessity = {}
Necessity.__index = Necessity

local function format_value(value)
    if math.floor(value) == value then
        return string.format("%d", value)
    end

    return string.format("%.2f", value)
end

local function is_fractional(value)
    if type(value) ~= "number" then
        return false
    end

    return math.abs(value - math.floor(value + 0.5)) > 1e-9
end

local function determine_scale(config)
    if config.scale then
        return config.scale
    end

    local candidates = { config.increment_step, config.decrement_step, config.default, config.minimum, config.maximum, config.step }
    for _, candidate in ipairs(candidates) do
        if is_fractional(candidate or 0) then
            return 100
        end
    end

    return 1
end

function Necessity:new(config)
    local resource = {
        column = config.column,
        label = config.label,
        decrement_step = config.decrement_step or config.decrement or config.step or 1,
        increment_step = config.increment_step or config.increment or config.step or config.decrement or 1,
        default = config.default or 0,
        minimum = config.minimum or 0,
        maximum = config.maximum or config.default or 0,
        debuff_spell = config.debuff_spell,
        scale = determine_scale(config)
    }

    return setmetatable(resource, self)
end

function Necessity:to_stored(value)
    return math.floor((value or 0) * self.scale + 0.5)
end

function Necessity:from_stored(value)
    return value / self.scale
end
function Necessity:set(player, value, suppress_message)
    local current_value, sanitized_name = self:fetch(player:GetName())

    local clamped = value or current_value
    if clamped > self.maximum then
        clamped = self.maximum
    end
    if clamped < self.minimum then
        clamped = self.minimum
    end

    local stored_value = self:to_stored(clamped)
    CharDBExecute(string.format([[
        UPDATE player_needs
        SET %s = %d
        WHERE ID = '%s'
    ]], self.column, stored_value, sanitized_name))

    if self.debuff_spell then
        if clamped <= self.minimum then
            player:AddAura(self.debuff_spell, player)
        elseif self.debuff_spell == DEBUFFS.RESURRECTION_SICKNESS then
            player:RemoveAura(self.debuff_spell)
        end
    end

    if not suppress_message then
        player:SendBroadcastMessage(string.format(TICK_MESSAGE, self.label, format_value(clamped)))
    end

    return clamped
end

function Necessity:fetch(player_name)
    local sanitized_name = sanitize_sql_string(player_name)
    local result = CharDBQuery(string.format([[
        SELECT %s
        FROM player_needs
        WHERE ID = '%s'
    ]], self.column, sanitized_name))

    if result then
        local stored

        if result.GetUInt32 then
            stored = result:GetUInt32(0)
        elseif result.GetInt32 then
            stored = result:GetInt32(0)
        else
            stored = tonumber(result:GetString(0))
        end

        if stored == nil then
            stored = self:to_stored(self.default)
        end

        -- Backwards compatibility for previously stored decimals
        if self.scale > 1 and is_fractional(stored) then
            return stored, sanitized_name
        end

        return self:from_stored(stored), sanitized_name
    end

    local default_stored = self:to_stored(self.default)
    CharDBExecute(string.format([[
        INSERT IGNORE INTO player_needs (ID)
        VALUES ('%s')
    ]], sanitized_name))
    CharDBExecute(string.format([[
        UPDATE player_needs
        SET %s = %d
        WHERE ID = '%s'
    ]], self.column, default_stored, sanitized_name))

    return self.default, sanitized_name
end

function Necessity:increment(player)
    local current_value, sanitized_name = self:fetch(player:GetName())
    local next_value = current_value + self.increment_step

    if next_value > self.maximum then
        next_value = self.maximum
    end

    local stored_value = self:to_stored(next_value)
    CharDBExecute(string.format([[
        UPDATE player_needs
        SET %s = %d
        WHERE ID = '%s'
    ]], self.column, stored_value, sanitized_name))

    player:SendBroadcastMessage(string.format(TICK_MESSAGE, self.label, format_value(next_value)))
end

function Necessity:decrement(player)
    local current_value, sanitized_name = self:fetch(player:GetName())
    local next_value = current_value - self.decrement_step

    if next_value < self.minimum then
        next_value = self.minimum
    end

    local stored_value = self:to_stored(next_value)
    CharDBExecute(string.format([[
        UPDATE player_needs
        SET %s = %d
        WHERE ID = '%s'
    ]], self.column, stored_value, sanitized_name))

    if self.debuff_spell then
        if next_value <= self.minimum then
            player:AddAura(self.debuff_spell, player)
        elseif self.debuff_spell == DEBUFFS.RESURRECTION_SICKNESS then
            player:RemoveAura(self.debuff_spell)
        end
    end

    player:SendBroadcastMessage(string.format(TICK_MESSAGE, self.label, format_value(next_value)))
end

function Necessity:tick(players)
    for _, player in pairs(players) do
        if player and player:IsInWorld() then
            self:decrement(player)
        end
    end
end

function Necessity:summary(player)
    local value = self:fetch(player:GetName())
    return string.format("%s: %s", self.label, format_value(value))
end

local function OnLogin(event, player)
    local summaries = {}
    for _, key in ipairs(NecessityResourceOrder) do
        local resource = NecessityResources[key]
        local value = resource:fetch(player:GetName())

        if key == "Rest" and value < resource.maximum then
            value = resource:set(player, resource.maximum, true)
        end

        table.insert(summaries, string.format("%s: %s", resource.label, format_value(value)))
    end
    player:SendBroadcastMessage(string.format("%s %s.", LOGIN_PREFIX, table.concat(summaries, ", ")))
end

RegisterPlayerEvent(3, OnLogin)

-- Bare Necessities: necessity helpers

local TICK_MESSAGE = "Your %s is now %d."
local LOGIN_PREFIX = "Welcome back!"

Necessity = {}
Necessity.__index = Necessity

function Necessity:new(config)
    local resource = {
        column = config.column,
        label = config.label,
        decrement_step = config.decrement_step or config.decrement or config.step or 1,
        increment_step = config.increment_step or config.increment or config.step or config.decrement or 1,
        default = config.default or 0,
        minimum = config.minimum or 0,
        maximum = config.maximum or config.default or 0,
        debuff_spell = config.debuff_spell
    }
    return setmetatable(resource, self)
end

function Necessity:fetch(player_name)
    local sanitized_name = sanitize_sql_string(player_name)
    local result = CharDBQuery(string.format([[
        SELECT %s
        FROM player_needs
        WHERE ID = '%s'
    ]], self.column, sanitized_name))

    if result then
        return result:GetInt32(0), sanitized_name
    end

    CharDBExecute(string.format([[
        INSERT IGNORE INTO player_needs (ID)
        VALUES ('%s')
    ]], sanitized_name))

    return self.default, sanitized_name
end

function Necessity:increment(player)
    local current_value, sanitized_name = self:fetch(player:GetName())
    local next_value = current_value + self.increment_step

    if next_value > self.maximum then
        next_value = self.maximum
    end

    CharDBExecute(string.format([[
        UPDATE player_needs
        SET %s = %d
        WHERE ID = '%s'
    ]], self.column, next_value, sanitized_name))

    player:SendBroadcastMessage(string.format(TICK_MESSAGE, self.label, next_value))
end

function Necessity:decrement(player)
    local current_value, sanitized_name = self:fetch(player:GetName())
    local next_value = current_value - self.decrement_step

    if next_value < self.minimum then
        next_value = self.minimum
    end

    CharDBExecute(string.format([[
        UPDATE player_needs
        SET %s = %d
        WHERE ID = '%s'
    ]], self.column, next_value, sanitized_name))

    if self.debuff_spell then
        if next_value <= self.minimum then
            player:AddAura(self.debuff_spell, player)
        else
            player:RemoveAura(self.debuff_spell)
        end
    end

    player:SendBroadcastMessage(string.format(TICK_MESSAGE, self.label, next_value))
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
    return string.format("%s: %d", self.label, value)
end

local function OnLogin(event, player)
    local summaries = {}
    for _, key in ipairs(NecessityResourceOrder) do
        table.insert(summaries, NecessityResources[key]:summary(player))
    end
    player:SendBroadcastMessage(string.format("%s %s.", LOGIN_PREFIX, table.concat(summaries, ", ")))
end

RegisterPlayerEvent(3, OnLogin)

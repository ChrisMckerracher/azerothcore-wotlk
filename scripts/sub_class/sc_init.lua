-- This function exists so I have a single spot to handle sanitization if I get around to that
local function GenerateInsertStatement(player_name)
    return string.format(
        [[
        INSERT IGNORE INTO
            player_sub_class (ID, SubClass)
        VALUES
            ('%s', 'None')
        ]], sanitize_sql_string(player_name)
    )
end

local function OnLogin(event, player)
    local player_name = player:GetName()
    CharDBExecute(GenerateInsertStatement(player_name))
    local msg = string.format("Sub Class Module loaded! Select a subclass with .%s <class-name>", SUBCLASS_COMMAND)
    -- Note: This is tmp to get around the class that Azerothcore deallocates spells
    local current_subclass = SUBCLASSES[GetSubclass(player_name)]
    if current_subclass ~= nil then
        current_subclass:Register(player)
    end
    player:SendBroadcastMessage(msg)
end

RegisterPlayerEvent(3, OnLogin)

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
    CharDBExecute(GenerateInsertStatement(player:GetName()))
    local msg = string.format("Sub Class Module loaded! Select a subclass with .%s <class-name>", SUBCLASS_COMMAND)
    player:SendBroadcastMessage(msg)
end

RegisterPlayerEvent(3, OnLogin)

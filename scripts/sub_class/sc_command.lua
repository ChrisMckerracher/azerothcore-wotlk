local function UpdateSubclass(player_name, sub_class)
     CharDBExecute(string.format(
        [[
        UPDATE player_sub_class
        SET SubClass = '%s'
        WHERE id = '%s'
        ]],
        sanitize_sql_string(sub_class),
        sanitize_sql_string(player_name)
    ))
end

function GetSubclass(player_name)
    local subclass_result = CharDBQuery(string.format(
        [[
        SELECT SubClass from
            player_sub_class
        WHERE id ='%s'
        ]], sanitize_sql_string(player_name)
    ))

    if subclass_result == nil then
        return nil
    end

    return subclass_result:GetString(0)
end

local function ClassChoice(event, player, msg)
    local player_name = player:GetName()
    local words = split_words(msg)
    if words[1] == SUBCLASS_COMMAND then
        if words[2] ~= nil then
            -- We specifically work off an allowlist. Not a perfect solution to prevent injection but a bit less bad
            -- Only do the sql command after this
            local subclass = SUBCLASSES[words[2]]
            if subclass == nil then
                player:SendBroadcastMessage("You tried to write a fake class, idiot!")
                return false
            end

            local current_subclass = SUBCLASSES[GetSubclass(player_name)]
            if current_subclass ~= nil then
                current_subclass:Deregister(player)
            end
            UpdateSubclass(player_name, subclass.name)
            subclass:Register(player)
            player:SendBroadcastMessage(string.format("You have become %s", subclass.name))
        else
            player:SendBroadcastMessage("You forgot the class, idiot!")
        end
        return false
    end

    return true
end

RegisterPlayerEvent(42, ClassChoice)

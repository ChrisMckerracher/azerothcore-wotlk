local function GenerateUpdateStatement(player_name)
    return string.format(
        [[
        INSERT IGNORE INTO
            player_sub_class (ID, SubClass)
        VALUES
            ('%s', 'None')
        ]], sanitize_sql_string(player_name)
    )
end

local function ClassChoice(event, player, msg)
    local words = split_words(msg)
    if words[1] == SUBCLASS_COMMAND then
        if words[2] ~= nil then
            player:SendBroadcastMessage(words[2])
        else
            player:SendBroadcastMessage("You forgot the class, idiot!")
        end
        return false
    end

    return true
end

RegisterPlayerEvent(42, ClassChoice)

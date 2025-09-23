-- This file has all shared SQL code
function UpdateSubclass(player_name, sub_class)
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

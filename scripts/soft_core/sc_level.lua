PLAYER_NEXT_LEVEL_XP = 635-- determined from codex scanning the source code

function getRemainingLevelPercent(player)
    local total_exp = player:GetUInt32Value(PLAYER_NEXT_LEVEL_XP)
    local used_exp = player:GetXP()

    return used_exp / total_exp
end

function getPartialLevel(player, percent)
    local total_exp = player:GetUInt32Value(PLAYER_NEXT_LEVEL_XP)
    return total_exp * percent
end

function setLevel(player, level, min_level)
    local player_level_total = player:GetLevel() + getRemainingLevelPercent(player)
    local new_level_total = math.max(player_level_total - level, min_level)

    local new_level = math.floor(new_level_total)
    local exp_portion = new_level_total - new_level

    player:SetLevel(new_level)
    player:GiveXP(getPartialLevel(player, exp_portion))
end

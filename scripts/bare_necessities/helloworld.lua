-- Sanity test from ChatGPT, to verify queryability of the db
local function OnLogin(event, player)
    -- Example: Count total characters in the DB
    local result = CharDBQuery("SELECT COUNT(*) FROM characters")
    local msg = "Hello! I could not query the DB."

    if result then
        local count = result:GetUInt32(0)
        msg = "Hello from SQL! There are currently " .. count .. " characters in the DB."
    end
    player:ModifyMoney(10000)
    -- ToDo: Generalize Proficiencies, probably as a new concept alongside sc_spells
    -- Note: this alongside learning Leather spell worked
    -- ToDo: https://github.com/xiii-hearts/mod-npc-subclass/blob/master/src/npc_subclass.cpp use this to generalize
    player:SetSkill(414, 0, 1, 1)
    player:SendBroadcastMessage(player:GetClassAsString())
end

RegisterPlayerEvent(3, OnLogin)

-- Sanity test from ChatGPT, to verify queryability of the db
local function OnLogin(event, player)
    -- Example: Count total characters in the DB
    local result = CharDBQuery("SELECT COUNT(*) FROM characters")
    local msg = "Hello! I could not query the DB."

    if result then
        local count = result:GetUInt32(0)
        msg = "Hello from SQL! There are currently " .. count .. " characters in the DB."
    end

    player:SendBroadcastMessage(msg)
end

RegisterPlayerEvent(3, OnLogin)

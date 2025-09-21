local function OnLogin(event, player)
    player:SendBroadcastMessage("test")
end
RegisterPlayerEvent(3, OnLogin)

RegisterPlayerEvent(13, function(_, player)
    local player_name = player:GetName()
    local current_subclass = SUBCLASSES[GetSubclass(player_name)]
    if current_subclass ~= nil then
        current_subclass:Register(player)
    end
end)

function testTele(_, player)
    player:TeleportTo("Orgrimmar")

end
RegisterPlayerEvent(3, testTele)

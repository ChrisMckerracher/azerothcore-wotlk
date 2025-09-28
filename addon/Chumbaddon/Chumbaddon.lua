local addon_name = ...

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")

local function safe_invoke(label, fn)
  local ok, err = pcall(fn)
  if not ok then
    if DEFAULT_CHAT_FRAME then
      DEFAULT_CHAT_FRAME:AddMessage(string.format("[Chumbaddon] %s failed: %s", label, tostring(err)))
    else
      print(string.format("[Chumbaddon] %s failed: %s", label, tostring(err)))
    end
  end
end

loader:SetScript("OnEvent", function(_, event, arg1)
  if event == "ADDON_LOADED" and arg1 == addon_name then
    if DEFAULT_CHAT_FRAME then
      DEFAULT_CHAT_FRAME:AddMessage("[Chumbaddon] AddOn files loaded")
    else
      print("[Chumbaddon] AddOn files loaded")
    end

    if BareNecessities and BareNecessities.new then
      safe_invoke("BareNecessities", function()
        BareNecessities:new():register()
      end)
    else
      safe_invoke("BareNecessities missing", function()
        error("BareNecessities table not found; file may not be loading")
      end)
    end

    if SpellRunes and SpellRunes.new then
      safe_invoke("SpellRunes", function()
        SpellRunes:new():register()
      end)
    else
      safe_invoke("SpellRunes missing", function()
        error("SpellRunes table not found; file may not be loading")
      end)
    end

    if DebugBar and DebugBar.new then
      safe_invoke("DebugBar", function()
        DebugBar:new():register()
      end)
    else
      safe_invoke("DebugBar missing", function()
        error("DebugBar table not found; file may not be loading")
      end)
    end
  elseif event == "PLAYER_LOGIN" then
    if DEFAULT_CHAT_FRAME then
      DEFAULT_CHAT_FRAME:AddMessage("[Chumbaddon] Readyz for tinkering!")
    else
      print("[Chumbaddon] Ready for tinkering!")
    end
  elseif event == "PLAYER_ENTERING_WORLD" then
    if DEFAULT_CHAT_FRAME then
      DEFAULT_CHAT_FRAME:AddMessage("[Chumbaddon] Systems coming online...")
    else
      print("[Chumbaddon] Systems coming online...")
    end
  end
end)

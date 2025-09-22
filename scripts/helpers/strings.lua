function split_words(s)
    local t = {}
    for w in s:gmatch("%S+") do
        table.insert(t, w)
    end
    return t
end

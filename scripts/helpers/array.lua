-- Note: This will bug out if you use it for tables with explicit keys
function append(t1, t2)
    new_array = {}
    for i = 1, #t1 do
        new_array[i] = t1[i]
    end
    for i = 1, #t2 do
        new_array[#t1+i] = t2[i]
    end

    return new_array
end

function item_exists(t, i)
    for k = 1, #t do
        if t[k] == i then
            return true
        end
    end

    return false
end

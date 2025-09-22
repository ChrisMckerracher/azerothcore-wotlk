-- Copied from https://ssojet.com/escaping/sql-escaping-in-lua/
-- This is the bare minimum you can do for sanitization, don't expect it to be
-- all encompassing.
function sanitize_sql_string(input_str)
    return string.gsub(input_str, "'", "''") -- Escape single quotes
end

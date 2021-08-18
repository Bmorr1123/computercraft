--[[
This is an attempt at a Python interpreter for lua.
Bmorr1123
--]]

file_py = arg[1] or "test.py"

-- Lexer
keywords = {}
function kv(key, value)
  keywords[key] = value
end

kv("for", 'FOR')
kv("[%w%_]", "VAR")
kv("(.*)", "EXPRESSION")
kv("  ", "INDENTATION")
kv("  .*\n")
kv("\n.*:\n")

function startsWith(str, substr)
  return str:find("^"..substr) ~= nil
end

function endsWith(str, substr)
  return str:sub(-#substr) == substr
end

for line in io.lines(file_py) do
  print(line)
end



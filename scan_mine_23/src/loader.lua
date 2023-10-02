--[[
pastebin get nudQtV3F scan_mine.lua
--]]
 
-- Process args
local tArgs = { ... }
if not (#tArgs >= 1) then
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    print("Usage: " .. programName .. " <length> Optional: <direction>")
    return
end
 
local length = tonumber(tArgs[1])
if length < 1 then
    print("Tunnel length must be positive")
    return
end
 
requirements = {
    ["inventory_util.lua"] = "4bUbgNP7",
    [".scan_mine.lua"] = "c5vdk7EE",
    ["left.lua"] = "X75n2YnV",
    ["right.lua"] = "UeKidsC2"
}

for file, paste in pairs(requirements) do
    if fs.exists(file) then
        fs.delete(file)
    end
    shell.run("pastebin get "..paste.." "..file)
end

 
local arg_string = ""
for i, arg in ipairs(arg) do
    arg_string = arg_string.." "..arg
end
 
shell.run(".scan_mine.lua "..arg_string)

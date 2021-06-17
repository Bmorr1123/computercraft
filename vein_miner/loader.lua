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

-- config.txt
if fs.exists("config.txt") then
    fs.delete("config.txt")
end
shell.run("pastebin get 1FcmHrkr config.txt")
-- scan_mine.lua updater
if fs.exists(".scan_mine.lua") then
    fs.delete(".scan_mine.lua")
end
shell.run("pastebin get c5vdk7EE .scan_mine.lua")

local arg_string = ""
for i, arg in ipairs(arg) do
    arg_string = arg_string.." "..arg
end

shell.run(".scan_mine.lua "..arg_string)

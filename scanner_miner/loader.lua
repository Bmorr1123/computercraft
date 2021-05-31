--[[
pastebin get AM7K54ri scan_mine.lua
--]]


-- Process args
local tArgs = { ... }
if not (#tArgs >= 1) then
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    print("Usage: " .. programName .. " <length> Optional: <debugMode>")
    return
end

local length = tonumber(tArgs[1])
if length < 1 then
    print("Tunnel length must be positive")
    return
end

local debugMode = ""
if #tArgs == 2 then
    print("DebugMode Active")
    debugMode = 1
end

-- config.txt
if fs.exists("config.txt") then
    fs.delete("config.txt")
end
shell.run("pastebin get 1FcmHrkr config.txt")
-- strip_mine.lua updater
if fs.exists(".strip_mine.lua") then
    fs.delete(".strip_mine.lua")
end
shell.run("pastebin get Uimcvayy .strip_mine.lua")

shell.run(".strip_mine.lua "..arg[1].." "..debugMode)

print("This will load", tonumber(arg[1]) / 16, "chunks")

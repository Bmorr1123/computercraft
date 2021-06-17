--[[
pastebin get QHCDQSyA super_mine.lua
--]]

-- Process args
local tArgs = { ... }
if not (#tArgs >= 4) then
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    print("Usage: " .. programName .. " <length> <direction> <tunnels> <slideDir> Optional: <spacing>")
    return
end

local length, dir, tunnels, slideDir = tonumber(tArgs[1]), tonumber(tArgs[2]), tonumber(tArgs[3]), tArgs[4]
if length < 1 then
    print("Tunnel length must be positive")
    return
elseif not (0 <= dir and dir <= 3) then
    print("Direction must be within [0, 4].")
    return
elseif tunnels < 0 then
    print("Tunnel count must be positive!")
    return
elseif not (slideDir:find("[Ll]") or slideDir:find("[Rr]")) then
    print("SlideDir must contain either L or R")
    return
end

local spacing = 4
if #tArgs > 4 then
    spacing = tonumber(tArgs[5])
    if spacing <= 0 then
        print("Spacing must be positive!")
        return
    end
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



slideDir = slideDir:find("[Ll]")
if not fs.exists("left.lua") then
    shell.run("pastebin get X75n2YnV left.lua")
end

if not fs.exists("right.lua") then
    shell.run("pastebin get UeKidsC2 right.lua")
end

local arg_string = ""
for i, arg in ipairs(arg) do
    arg_string = arg_string.." "..arg
end

for i = 1, tunnels do
    shell.run(".scan_mine.lua "..length.." "..dir)
    if i ~= tunnels then
        if slideDir then
            shell.run("left.lua "..spacing)
        else
            shell.run("right.lua "..spacing)
        end
    end
end

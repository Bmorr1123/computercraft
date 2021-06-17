--[[
pastebin get c5vdk7EE scan_mine.lua
--]]

if not turtle then
    printError("Requires a Turtle")
    return
end

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

local starting_direction = -1
if #tArgs == 2 then
    starting_direction = tonumber(tArgs[2])
end

-- String Functions
function currentTimeString()
    return textutils.formatTime(os.time("local"))
end

function startsWith(str, substr)
    return str:find("^"..substr) ~= nil
end

-- Vector functions
function compareVectors(a, b)
    return a.x == b.x and a.y == b.y and a.z == b.z
end

-- Load up config
blacklist = {}
config = io.open("config.txt", "r")
for line in config:lines() do
    if startsWith(line, "-") then
        blacklist[#blacklist + 1] = string.sub(line, 2)
    end
end

-- Scanner Code
local scanner = peripheral.wrap("left")

local scanner_radius = 8
local scanner_width = scanner_radius * 2 + 1

local scanned = scanner.scan()

local function scanned_at(x, y, z)
  return scanned[scanner_width ^ 2 * (x + scanner_radius) + scanner_width * (y + scanner_radius) + (z + scanner_radius) + 1]
end

-- Inventory Functions
function checkIfSlotIsItem(slot, name)
    local item = turtle.getItemDetail(slot)
    if item ~= nil then
        return item["name"] == name
    end
    return false
end

function findItem(name)
    for slot = 1, 16 do
        if checkIfSlotIsItem(slot, name) then
            return slot
        end
    end
    return -1
end

function checkIfHaveItem(name)
    return findItem(name) ~= -1
end

function findEmpty()
    for index = 1, 16 do
        if turtle.getItemCount(index) == 0 then
            return index
        end
    end
    return -1
end

function countItems()
    local total = 0
    for index = 1, 16 do
        total = turtle.getItemCount(index) + total
    end
    return total
end

function emptyInventory()
    print("Dropping:")
    for i = 1, 16 do
        turtle.select(i)
        local data = turtle.getItemDetail()
        if data then
            print(tostring(turtle.getItemCount()).."x "..data["name"])
        end
        turtle.dropDown()
    end
end
-- Mining Functions
function tryDig()
    while turtle.detect() do
        if turtle.dig() then
            sleep(0.5)
        else
            return false
        end
    end
    return true
end

function tryDigUp()
    while turtle.detectUp() do
        if turtle.digUp() then
            sleep(0.5)
        else
            return false
        end
    end
    return true
end

function tryDigDown()
    while turtle.detectDown() do
        if turtle.digDown() then
            sleep(0.5)
        else
            return false
        end
    end
    return true
end


-- Refueling
function refuel()
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel == "unlimited" or fuelLevel > 0 then
        return
    end

    function tryRefuel()
        for n = 1, 16 do
            if turtle.getItemCount(n) > 0 then
                turtle.select(n)
                if turtle.refuel(1) then
                    turtle.select(1)
                    return true
                end
            end
        end
        turtle.select(1)
        return false
    end

    if not tryRefuel() then
        print("Add more fuel to continue.")
        while not tryRefuel() do
            os.pullEvent("turtle_inventory")
        end
        print("Resuming Tunnel.")
    end
end

-- Movement Functions
local pos, dir = vector.new(0, 0, 0), 0

local cardinal_directions = {}
cardinal_directions["N"] = 0
cardinal_directions["E"] = 1
cardinal_directions["S"] = 2
cardinal_directions["W"] = 3
cardinal_directions[0] = vector.new( 0,  0, -1)
cardinal_directions[1] = vector.new(1,  0,  0)
cardinal_directions[2] = vector.new( 0,  0, 1)
cardinal_directions[3] = vector.new(-1,  0,  0)
local up, down = vector.new(0, 1, 0), vector.new(0, -1, 0)

local function iDir(num) -- Increment dir
    local ldir = dir + num  -- local dir
    if ldir < 0 then
        ldir = ldir + 4
    elseif ldir > 3 then
        ldir = ldir - 4
    end
    return ldir
end

function tryUp()
    scanned = scanner.scan()
    refuel()
    while not turtle.up() do
        if turtle.detectUp() then
            if not tryDigUp() then
                return false
            end
        else
            sleep(0.5)
        end
    end
    pos = pos + up
    print("Moved to", pos)
    return true
end

function tryDown()
    scanned = scanner.scan()
    refuel()
    while not turtle.down() do
        if turtle.detectDown() then
            if not tryDigDown() then
                return false
            end
        else
            sleep(0.5)
        end
    end
    pos = pos + down
    print("Moved to", pos)
    return true
end

function tryForward(doprint)
    scanned = scanner.scan()
    doprint = doprint or true
    refuel()
    while not turtle.forward() do
        if turtle.detect() then
            if not tryDig() then
                return false
            end
        else
            sleep(0.5)
        end
    end
    pos = pos + cardinal_directions[dir]
    if doprint then
        print("Moved to", pos)
    end
    return true
end

function tryBack()
    scanned = scanner.scan()
    refuel()
    if not turtle.back() then
        turnLeft(2)
        local ret = tryForward()
        turnLeft(2)
        return ret
    else
        pos = pos - cardinal_directions[dir]
        print("Moved to", pos)
    end
    return true
end

function turnRight(count)
    scanned = scanner.scan()
    count = count or 1
    turtle.turnRight()
    dir = iDir(1)
    if count > 1 then
        turnRight(count - 1)
    end
end

function turnLeft(count)
    scanned = scanner.scan()
    count = count or 1
    turtle.turnLeft()
    dir = iDir(-1)
    if count > 1 then
        turnLeft(count - 1)
    end
end

-- Mapping Functions
function scanUp()
    local isthere, info = turtle.inspectUp()
    if isthere then
        return info["name"]
    end
    return "minecraft:air"
end

function scanFront()
    lpos = pos + cardinal_directions[dir]
    local isthere, info = turtle.inspect()
    if isthere then
        return info["name"]
    end
    return "minecraft:air"
end

function scanDown()
    local isthere, info = turtle.inspectDown()
    if isthere then
        return info["name"]
    else
        return "air"
    end
end

function isOre(item_name)
    for i, v in ipairs(blacklist) do
        if item_name == v then
            return false
        end
    end
    return item_name ~= "minecraft:air"
end
-- Mining functions
function followVein()
    scanned = scanner.scan()
    -- Front
    local to_check = cardinal_directions[dir]
    if isOre(scanned_at(to_check.x, to_check.y, to_check.z).name) then
        tryDig()
        tryForward()
        followVein()
        tryBack()
        if checkIfHaveItem("minecraft:cobblestone") then
            turtle.select(findItem("minecraft:cobblestone"))
            turtle.place()
            turtle.select(1)
        end
    end
    -- Left
    to_check = cardinal_directions[iDir(-1)]
    if isOre(scanned_at(to_check.x, to_check.y, to_check.z).name) then
        turnLeft()
        tryDig()
        tryForward()
        followVein()
        tryBack()
        if checkIfHaveItem("minecraft:cobblestone") then
            turtle.select(findItem("minecraft:cobblestone"))
            turtle.place()
            turtle.select(1)
        end
        turnRight()
    end
    -- Right
    to_check = cardinal_directions[iDir(1)]
    if isOre(scanned_at(to_check.x, to_check.y, to_check.z).name) then
        turnRight()
        tryDig()
        tryForward()
        followVein()
        tryBack()
        if checkIfHaveItem("minecraft:cobblestone") then
            turtle.select(findItem("minecraft:cobblestone"))
            turtle.place()
            turtle.select(1)
        end
        turnLeft()
    end
    -- Back
    to_check = cardinal_directions[iDir(-2)]
    if isOre(scanned_at(to_check.x, to_check.y, to_check.z).name) then
        turnLeft(2)
        tryDig()
        tryForward()
        followVein()
        tryBack()
        if checkIfHaveItem("minecraft:cobblestone") then
            turtle.select(findItem("minecraft:cobblestone"))
            turtle.place()
            turtle.select(1)
        end
        turnRight(2)
    end
    -- Up
    to_check = up
    if isOre(scanned_at(to_check.x, to_check.y, to_check.z).name) then
        tryDigUp()
        tryUp()
        followVein()
        tryDown()
        if checkIfHaveItem("minecraft:cobblestone") then
            turtle.select(findItem("minecraft:cobblestone"))
            turtle.placeUp()
            turtle.select(1)
        end
    end
    -- Down
    to_check = down
    if isOre(scanned_at(to_check.x, to_check.y, to_check.z).name) then
        tryDigDown()
        tryDown()
        followVein()
        tryUp()
        if checkIfHaveItem("minecraft:cobblestone") then
            turtle.select(findItem("minecraft:cobblestone"))
            turtle.placeDown()
            turtle.select(1)
        end
    end

end

-- Main
if starting_direction == -1 then
    print("Enter direction turtle is facing: ")
    print("(N = 0, W = 3)")
    dir = tonumber(read())
else
    dir = starting_direction
end

term.clear()
term.setCursorPos(1, 1)

local start_pos = pos
local end_pos = pos + cardinal_directions[dir] * length
print(pos, "->", end_pos)
while not compareVectors(pos, end_pos) do
    followVein()
    tryForward()
end
while not compareVectors(pos, start_pos) do
    tryBack()
end



print("Fuel is currently "..turtle.getFuelLevel().."!")

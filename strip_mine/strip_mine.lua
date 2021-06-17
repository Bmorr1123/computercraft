if not turtle then
    printError("Requires a Turtle")
    return
end
-- String Functions
function currentTimeString()
    return textutils.formatTime(os.time("local"))
end

function startsWith(str, substr)
    return str:find("^"..substr) ~= nil
end

-- Process args
local tArgs = { ... }
if #tArgs ~= 1 then
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    print("Usage: " .. programName .. " <length>")
    return
end

local length = tonumber(tArgs[1])
if length < 1 then
    print("Tunnel length must be positive")
    return
end

-- Load up config
blacklist = {}
config = io.open("config.txt", "r")
for line in config:lines() do
    if startsWith(line, "-") then
        blacklist[#blacklist + 1] = string.sub(line, 2)
    end
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
local x, y, z, dir = 0, 0, 0, 0

function tryUp()
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
    y = y + 1
    print("Moved to", x, y, z)
    return true
end

function tryDown()
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
    y = y - 1
    print("Moved to", x, y, z)
    return true
end

function tryForward(doprint)
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
    if dir == 0 then
        x = x + 1
    elseif dir == 1 then
        z = z + 1
    elseif dir == 2 then
        x = x - 1
    elseif dir == 3 then
        z = z - 1
    end
    if doprint then
        print("Moved to", x, y, z)
    end
    return true
end

function tryBack()
    refuel()
    if not turtle.back() then
        turnLeft(2)
        local ret = tryForward()
        turnLeft(2)
        return ret
    else
        if dir == 0 then
            x = x - 1
        elseif dir == 1 then
            z = z - 1
        elseif dir == 2 then
            x = x + 1
        elseif dir == 3 then
            z = z + 1
        end
        print("Moved to", x, y, z)
    end
    return true
end

function turnRight(count)
    count = count or 1
    turtle.turnRight()
    dir = dir - 1
    if dir < 0 then
        dir = 3
    end
    if count > 1 then
        turnRight(count - 1)
    end
end

function turnLeft(count)
    count = count or 1
    turtle.turnLeft()
    dir = dir + 1
    if dir > 3 then
        dir = 0
    end
    if count > 1 then
        turnLeft(count - 1)
    end
end

-- Mapping Functions
local world_data = {}

function spotExists(fx, fy, fz)
    local exists = world_data[fx] ~= nil
    if exists then
        exists = world_data[fx][fy] ~= nil
    end
    if exists then
        exists = world_data[fx][fy][fz] ~= nil
    end
    return exists
end

function getSpot(fx, fy, fz)
    if spotexists(fx, fy, fz) then
        return world_data[fx][fy][fz]
    end
    return "?"
end

function enterSpot(fx, fy, fz, value)
    local exists = world_data[fx] ~= nil
    if not exists then
        world_data[fx] = {}
    end
    exists = world_data[fx][fy] ~= nil
    if not exists then
        world_data[fx][fy] = {}
    end
    world_data[fx][fy][fz] = value
end

function scanUp()
    local isthere, info = turtle.inspectUp()
    if isthere then
        enterSpot(x, y + 1, z, info["name"])
        return info["name"]
    else
        enterSpot(x, y + 1, z, "empty")
        return "empty"
    end
end

function scanFront()
    lx, ly, lz = x, y, z
    if dir == 0 then
        lx = lx + 1
    elseif dir == 1 then
        lz = lz + 1
    elseif dir == 2 then
        lx = lx - 1
    elseif dir == 3 then
        lz = lz - 1
    end
    local isthere, info = turtle.inspect()
    if isthere then
        enterSpot(lx, ly, lz, info["name"])
        return info["name"]
    else
        enterSpot(lx, ly, lz, "empty")
        return "empty"
    end
end

function scanDown()
    local isthere, info = turtle.inspectDown()
    if isthere then
        enterSpot(x, y - 1, z, info["name"])
        return info["name"]
    else
        enterSpot(x, y - 1, z, "empty")
        return "empty"
    end
end

function isOre(item_name)
    for i, v in ipairs(blacklist) do
        if item_name == v then
            return false
        end
    end
    return item_name ~= "empty"
end
-- Mining functions
function followOre()
    if isOre(scanFront()) then
        tryDig()
        tryForward()
        followOre()
        tryBack()
        if checkIfHaveItem("minecraft:cobblestone") then
            turtle.select(findItem("minecraft:cobblestone"))
            turtle.place()
            turtle.select(1)
        end
    end
    if isOre(scanUp()) then
        tryDigUp()
        tryUp()
        followOre()
        tryDown()
        if checkIfHaveItem("minecraft:cobblestone") then
            turtle.select(findItem("minecraft:cobblestone"))
            turtle.placeUp()
            turtle.select(1)
        end
    end
    if isOre(scanDown()) then
        tryDigUp()
        tryDown()
        followOre()
        tryUp()
        if checkIfHaveItem("minecraft:cobblestone") then
            turtle.select(findItem("minecraft:cobblestone"))
            turtle.placeDown()
            turtle.select(1)
        end
    end
    turnLeft()
    if isOre(scanFront()) then
        tryDig()
        tryForward()
        followOre()
        tryBack()
        if checkIfHaveItem("minecraft:cobblestone") then
            turtle.select(findItem("minecraft:cobblestone"))
            turtle.place()
            turtle.select(1)
        end
    end
    turnLeft()
    if isOre(scanFront()) then
        tryDig()
        tryForward()
        followOre()
        tryBack()
        if checkIfHaveItem("minecraft:cobblestone") then
            turtle.select(findItem("minecraft:cobblestone"))
            turtle.place()
            turtle.select(1)
        end
    end
    turnLeft()
    if isOre(scanFront()) then
        tryDig()
        tryForward()
        followOre()
        tryBack()
        if checkIfHaveItem("minecraft:cobblestone") then
            turtle.select(findItem("minecraft:cobblestone"))
            turtle.place()
            turtle.select(1)
        end
    end
    turnLeft()
end

function scanAround()
    scanUp()
    scanDown()
    for index = 1, 3 do
        scanFront()
        turnLeft()
    end
end

local start_count = countItems()
-- Return to where we started
for dist = 1, length do
    tryForward()
    followOre()
end
for dist = 1, length do
    tryBack()
end

local i, back = 0, 6
local below = scanDown()
while i < back and below ~= "minecraft:water" and below ~= "minecraft:spruce_sign" and below ~= "minecraft:oak_sign" and below ~= "minecraft:spruce_wall_sign" and below ~= "minecraft:oak_wall_sign" do
    tryBack()
    below = scanDown()
    i = i + 1
end
if below == "minecraft:spruce_sign" or below == "minecraft:oak_sign" or below == "minecraft:spruce_wall_sign" or below == "minecraft:oak_wall_sign" then
    turnLeft()
    tryForward()
    emptyInventory()
    tryBack()
    turnRight()
elseif below == "minecraft:water" then
    emptyInventory()
else
    print("Couldn't empty inventory!")
end
for lcv = 1, i do
    tryForward(false)
end
-- print("Found", (start_count - countItems()), "items during expedition.")

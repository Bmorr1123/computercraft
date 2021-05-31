if not turtle then
    printError("Requires a Turtle")
    return
end

local tArgs = { ... }
if #tArgs ~= 1 then
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    print("Usage: " .. programName .. " <length>")
    return
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
    for i = 1, 16 do
        turtle.select(i)
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


-- Mine in a quarry pattern until we hit something we can't dig
local length = tonumber(tArgs[1])
if length < 1 then
    print("Tunnel length must be positive")
    return
end
local collected = 0

local function collect()
    collected = collected + 1
    if math.fmod(collected, 25) == 0 then
        print("Mined " .. collected .. " items.")
    end
end

local function tryDig()
    while turtle.detect() do
        if turtle.dig() then
            collect()
            sleep(0.5)
        else
            return false
        end
    end
    return true
end

local function tryDigUp()
    while turtle.detectUp() do
        if turtle.digUp() then
            collect()
            sleep(0.5)
        else
            return false
        end
    end
    return true
end

local function tryDigDown()
    while turtle.detectDown() do
        if turtle.digDown() then
            collect()
            sleep(0.5)
        else
            return false
        end
    end
    return true
end

local function refuel()
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel == "unlimited" or fuelLevel > 0 then
        return
    end

    local function tryRefuel()
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

local function tryUp()
    refuel()
    while not turtle.up() do
        if turtle.detectUp() then
            if not tryDigUp() then
                return false
            end
        elseif turtle.attackUp() then
            collect()
        else
            sleep(0.5)
        end
    end
    return true
end

local function tryDown()
    refuel()
    while not turtle.down() do
        if turtle.detectDown() then
            if not tryDigDown() then
                return false
            end
        elseif turtle.attackDown() then
            collect()
        else
            sleep(0.5)
        end
    end
    return true
end

local function tryForward()
    refuel()
    while not turtle.forward() do
        if turtle.detect() then
            if not tryDig() then
                return false
            end
        elseif turtle.attack() then
            collect()
        else
            sleep(0.5)
        end
    end
    return true
end

print("Tunnelling...")

for n = 1, length do
    turtle.placeDown()
    tryDigUp()
    turtle.turnLeft()
    tryDig()
    tryUp()
    -- Modification
    tryDigUp()
    tryDig()
    tryUp()
    tryDig()
    turtle.turnRight()
    turtle.turnRight()
    tryDig()
    tryDown()
    tryDig()
    tryDown()
    tryDig()
    turtle.turnLeft()
    tryDigDown()
    tryDown()



    if n < length then
        tryDig()
        if not tryForward() then
            print("Aborting Tunnel.")
            break
        end
    else
        print("Tunnel complete.")
    end

end


print( "Returning to start..." )

-- Return to where we started
turtle.turnLeft()
turtle.turnLeft()
while length > 1 do
    if turtle.forward() then
        length = length - 1
    else
        turtle.dig()
    end
end
turtle.turnRight()
turtle.turnRight()


print("Tunnel complete.")
print("Mined " .. collected .. " items total.")

--[[
    pastebin get FJS8kYTw btunnel.lua
--]]


local tArgs = { ... }
if not (#tArgs >= 1) then
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    print("Usage: " .. programName .. " <length>")
    return
end

local length = tonumber(tArgs[1])
if length < 1 then
    print("Tunnel length must be positive")
    return
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
    count = count or 1
    turtle.turnRight()
    dir = iDir(1)
    if count > 1 then
        turnRight(count - 1)
    end
end

function turnLeft(count)
    count = count or 1
    turtle.turnLeft()
    dir = iDir(-1)
    if count > 1 then
        turnLeft(count - 1)
    end
end

for i = 1, length do
    tryForward()
    turnLeft()
    tryDig()
    tryUp()
    tryDig()
    tryUp()
    tryDig()
    turnRight(2)
    tryDig()
    tryDown()
    tryDig()
    tryDown()
    tryDig()
    turnLeft()
end

for i = 1, length do
    tryBack()
end

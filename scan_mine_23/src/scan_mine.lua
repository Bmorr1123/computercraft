
--[[
pastebin get c5vdk7EE scan_mine.lua
--]]

inv = require("inventory_util")

if not turtle then
    printError("Requires a Turtle")
    return
end

-- Process args
local tArgs = { ... }
if not (#tArgs >= 1) then
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    print("Usage: " .. programName .. " <length> <ore>")
    return
end

local length = tonumber(tArgs[1])
if length < 1 then
    print("Tunnel length must be witive")
    return
end

local starting_direction = -1
if #tArgs >= 2 then
    starting_direction = tonumber(tArgs[2])
end

local deposit_and_continue = tArgs[3] or nil

print(deposit_and_continue)

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

-- Scanner Code
local scanner = peripheral.wrap("left")

local scanner_radius = 1

function scanned_at(scanned, x, y, z)
    for i, block_data in ipairs(scanned) do
        if block_data.x == x and block_data.y == y and block_data.z == z then
            return block_data
        end
    end
    return nil
end
-- Inventory Functions
local has_ender_chest = inv.checkIfHaveItem("enderstorage:ender_storage")
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

function isOre(item_data)
    if item_data == nil then
        return false
    end
    if item_data.name == "minecraft:obsidian" then
        return true
    end
    local tags = item_data["tags"]
    if tags ~= nil then
        for i, tag in pairs(tags) do
            if tag == "minecraft:block/forge:ores" then
                return true
            end
        end
    end
    return false
end

-- Mining functions
function followVein()
    local scanned_data = scanner.scan(scanner_radius)
    while scanned_data == nil do
        sleep(0.25)
        scanned_data = scanner.scan(scanner_radius)
    end
    -- Front
    local to_check = cardinal_directions[dir]
    if isOre(scanned_at(scanned_data, to_check.x, to_check.y, to_check.z)) then
        tryDig()
        tryForward()
        followVein()
        tryBack()
    end
    -- Enderchest
    if has_ender_chest and checkIfInventoryFull() then
        tryDig()
        turtle.select(inv.findItem("enderstorage:ender_storage"))
        turtle.place()
        emptyInventory()
        tryDig()
    end
    -- Left
    to_check = cardinal_directions[iDir(-1)]
    if isOre(scanned_at(scanned_data, to_check.x, to_check.y, to_check.z)) then
        turnLeft()
        tryDig()
        tryForward()
        followVein()
        tryBack()
        turnRight()
    end
    -- Right
    to_check = cardinal_directions[iDir(1)]
    if isOre(scanned_at(scanned_data, to_check.x, to_check.y, to_check.z)) then
        turnRight()
        tryDig()
        tryForward()
        followVein()
        tryBack()
        turnLeft()
    end
    -- Back
    to_check = cardinal_directions[iDir(-2)]
    if isOre(scanned_at(scanned_data, to_check.x, to_check.y, to_check.z)) then
        turnLeft(2)
        tryDig()
        tryForward()
        followVein()
        tryBack()
        turnRight(2)
    end
    -- Up
    to_check = up
    if isOre(scanned_at(scanned_data, to_check.x, to_check.y, to_check.z)) then
        tryDigUp()
        tryUp()
        followVein()
        tryDown()
        if inv.checkIfHaveItem("minecraft:cobblestone") then
            turtle.select(inv.findItem("minecraft:cobblestone"))
            turtle.placeUp()
            turtle.select(1)
        end
    end
    -- Down
    to_check = down
    if isOre(scanned_at(scanned_data, to_check.x, to_check.y, to_check.z)) then
        tryDigDown()
        tryDown()
        followVein()
        tryUp()
        if inv.checkIfHaveItem("minecraft:cobblestone") then
            turtle.select(inv.findItem("minecraft:cobblestone"))
            turtle.placeDown()
            turtle.select(1)
        end
    end

end

-- Main
function main(call)
    call = call or 0
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
    print(pos, "->", end_pos, "x"..tostring(call))
    while not compareVectors(pos, end_pos) do
        followVein()
        tryForward()
    end
    while not compareVectors(pos, start_pos) do
        tryBack()
    end

    if deposit_and_continue ~= nil then
        turnLeft(2)
        exists, data = turtle.inspect()
        if exists and data.name == "minecraft:chest" then
            inv.emptyInventory()
        else
            print("Could not find chest!")
            turnRight(2)
            return -1
        end
        turnRight(2)

        if turtle.getFuelLevel() > 512 then
            shell.run(deposit_and_continue.." 3")
            main(call + 1)
        else
            print("Not enough fuel to safely continue.")
        end
        
    end

end

main()
print("Fuel is currently "..turtle.getFuelLevel().."!")
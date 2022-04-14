if not turtle then
    printError("Requires a Turtle")
    return
end

local tArgs = { ... }

local doFull = true
if (#tArgs == 1) then
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    print("Usage: " .. programName .. " <length>")
    doFull = false
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

if not checkIfHaveItem("minecraft:bucket") then
    print("Needs a bucket")
    return
end

local start_fuel = turtle.getFuelLevel()
local toCollect = math.floor((turtle.getFuelLimit() - start_fuel) / 1000)

if not doFull then
    toCollect = tArgs[1]
end

for i = 1, toCollect / 2 do
    turtle.placeDown()
    turtle.refuel()
    turtle.dig()
    turtle.forward()
end
turtle.digDown()
turtle.down()
turtle.turnLeft()
turtle.turnLeft()
for i = 1, toCollect / 2 do
    turtle.placeDown()
    turtle.refuel()
    turtle.dig()
    turtle.forward()
end
turtle.up()
turtle.turnLeft()
turtle.turnLeft()

print("Fuel level is: "..turtle.getFuelLevel())

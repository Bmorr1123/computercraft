function checkIfSlotIsItem(slot, name)
    local sslot = turtle.getSelectedSlot()
    turtle.select(slot)
    local item = turtle.getItemDetail(slot)
    if item ~= nil then
        turtle.select(sslot)
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

function replenishFuel()
    if turtle.getFuelLevel() <= 16 then
        turtle.suckUp()
        for i = 1, 16 do
            turtle.select(i)
            turtle.refuel(turtle.getItemCount(i))
        end
        index = findItem("minecraft:bucket")
        if index ~= -1 then
            turtle.dropUp(turtle.getItemCount(index))
        end
    end
end

rednet.open("right")
replenishFuel()

-- Determine heading
heading = 0 -- north = 0
start_location = vector.new(gps.locate())
can_forward = turtle.forward()
if can_forward then
    dLocation = vector.new(gps.locate())
    turtle.back()
    if dLocation.x < 0 then
        heading = 1
    elseif dLocation.z > 0 then
        heading = 2
    elseif dLocation.z < 0 then
        heading = 0
    end
else
    heading = 3
end

-- Turning to north
while heading ~= 0 do
    if heading - 2 >= 0 then
        turtle.turnRight()
        heading = (heading + 1) % 4
    elseif heading > 0 then
        turtle.turnLeft()
        heading = heading - 1
    end
end

-- Place and send off the imps
count = 0
while turtle.getItemCount(1) > 0 and checkIfSlotIsItem(1, "computercraft:turtle_advanced") do
    turtle.select(1)
    while not turtle.placeDown() do
        os.sleep(5)
    end
    turtle.suckUp()
    for index = 1, 16 do
        if checkIfSlotIsItem(index, "minecraft:lava_bucket") then
            turtle.select(index)
            break
        end
    end
    turtle.dropDown()
    peripheral.call("bottom", "turnOn")
    print("Turned on imp")
    os.sleep(0.25)
    impId = peripheral.call("bottom", "getID")
    print("impId = "..impId)
    rednet.send(impId, "layer.lua 16 1 16 -699 "..(236 - count).." -315 "..heading, "imp")
    turtle.turnRight()
    heading = (heading + 1) % 4
    count = count + 1
end
rednet.close()

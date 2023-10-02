function checkIfSlotIsItem(slot, name)
    local item = turtle.getItemDetail(slot)
    turtle.select(1)
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

function checkIfInventoryFull()
    return findEmpty() == -1
end

drop_directions = {
    ["down"] = turtle.dropDown,
    ["up"] = turtle.dropUp,
    ["forward"] = turtle.drop
}

function emptyInventory(direction)
    direction = direction or "forward"
    direction = drop_directions[direction]
    print("Dropping:")
    for i = 1, 16 do
        turtle.select(i)
        local data = turtle.getItemDetail()
        if data then
            print(tostring(turtle.getItemCount()).."x "..data["name"])
        end

        direction()
    end
    turtle.select(1)
end

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

return { checkIfSlotIsItem = checkIfSlotIsItem, findItem = findItem, checkIfHaveItem = checkIfHaveItem, findEmpty = findEmpty, countItems = countItems, checkIfInventoryFull = checkIfInventoryFull, emptyInventory = emptyInventory, refuel = refuel,}
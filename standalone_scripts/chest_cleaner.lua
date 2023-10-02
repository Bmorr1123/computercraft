inv = require("inventory_util")

--[[
    pastebin get YrQEHQdQ chest_cleaner.lua
    Start on chest to deposit in, facing AWAY from the chests you wish to unload.
]]

requirements = {
    ["inventory_util.lua"] = "4bUbgNP7"
}

for file, paste in pairs(requirements) do
    print("Grabbing \""..file.."\"...")
    if fs.exists(file) then
        fs.delete(file)
    end
    shell.run("pastebin get "..paste.." "..file)
end

function main(count)
    count = count or 0

    print("Beginning loop #"..tostring(count))

    turtle.turnLeft()
    turtle.turnLeft()
    turtle.forward()
    distance = 1

    -- This loop goes until it reaches the first chest.
    exists, data = turtle.inspectDown()
    while not exists or data.name ~= "minecraft:chest" do
        turtle.forward()
        exists, data = turtle.inspectDown()
        distance = distance + 1
    end
    closest_chest = distance
    print("Found closest chest!")

    -- Now every two blocks there better be another chest.
    turtle.forward()
    turtle.forward()
    turtle.forward()
    distance = distance + 3

    exists, data = turtle.inspectDown()
    while exists and data.name == "minecraft:chest" do
        turtle.forward()
        turtle.forward()
        turtle.forward()
        distance = distance + 3

        exists, data = turtle.inspectDown()
    end

    turtle.turnLeft()
    turtle.turnLeft()

    distance = distance - 3
    turtle.forward()
    turtle.forward()
    turtle.forward()

    closest_looted = -1

    while not inv.checkIfInventoryFull() and distance > 5 do
        closest_looted = distance
        if not turtle.suckDown() and not inv.checkIfInventoryFull() then
            turtle.digDown()

            turtle.forward()
            turtle.forward()
            turtle.forward()
            distance = distance - 3
        end
    end

    print("Inventory Full! Returning to drop-off...")

    turtle.up()

    for i = 1, distance do
        turtle.forward()
    end

    turtle.down()
    exists, data = turtle.inspectDown()
    if exists and data.name == "minecraft:chest" then
        inv.emptyInventory("down")
    end

    if closest_looted > 0 and closest_looted > closest_chest then
        main(count + 1)
    end
end

main()


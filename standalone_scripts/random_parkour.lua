--[[
pastebin get U7QGw0sv parkour.lua


pastebin run U7QGw0sv
--]]

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
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

-- Movement Functions
local moves = {}

function goForward()
    local success = turtle.forward()
    if not success then
        turtle.dig()
        turtle.forward()
    end
    moves[#moves + 1] = "f"
end

function goBack()
    local success = turtle.back()
    if not success then
        turtle.turnLeft()
        turtle.dig()
        turtle.forward()
        turtle.turnLeft()
    end
    moves[#moves + 1] = "b"
end

function goUp()
    local success = turtle.up()
    if not success then
        turtle.digUp()
        turtle.up()
    end
    moves[#moves + 1] = "u"
end

function goDown()
    local success = turtle.down()
    if not success then
        turtle.digDown()
        turtle.down()
    end
    moves[#moves + 1] = "d"
end

function turnLeft()
    turtle.turnLeft()
    moves[#moves + 1] = "l"
end

function turnRight()
    turtle.turnRight()
    moves[#moves + 1] = "r"
end

function doMove(str)
    if str == "f" then
        goForward()
    elseif str == "b" then
        goBack()
    elseif str == "u" then
        goUp()
    elseif str == "d" then
        goDown()
    elseif str == "l" then
        turnLeft()
    elseif str == "r" then
        turnRight()
    end
end
-- Main
print("Building Parkour!")
local first = true
while findItem("minecraft:cobblestone") ~= -1 do
    turtle.select(findItem("minecraft:cobblestone"))
    local toTurn = math.random(3)
    if toTurn == 1 and not first then
        if math.random(2) == 1 then
            turnRight()
        else
            turnLeft()
        end
    end

    local random = math.random(3, 4)  -- second num == 5 if 4 blocks included
    for i = 1, random do
        goForward()
        if i == 1 and first then
            turtle.turnLeft()
            turtle.turnLeft()
            turtle.place()
            turtle.turnLeft()
            turtle.turnLeft()
        end
    end
    if random ~= 5 and math.random(3) == 3 and not first then
        goUp()
    elseif math.random(3) == 1 then
        if math.random(2) == 1 then
            turnRight()
            for i = 1, math.random(2) do
                goForward()
            end
            turnLeft()
        else
            turnLeft()
            for i = 1, math.random(2) do
                goForward()
            end
            turnRight()
        end
    end
    if first then
        first = false
    end
    turtle.placeUp()
end
local initial_moves = shallowcopy(moves)
-- Return to start
print("Returning to start!")
local opposites = {l="r", r="l", u="d", d="u", f="b", b="f"}
for i = #initial_moves, 2, -1 do
    local move = initial_moves[i]
    doMove(opposites[move])
end

sleep(10)

print("Destroying Parkour!")
for i = 2, #initial_moves, 1 do
    local move = initial_moves[i]
    doMove(move)
    turtle.digUp()
end

print("Returning to start!")
for i = #initial_moves, 2, -1 do
    local move = initial_moves[i]
    doMove(opposites[move])
end
turnLeft()
turnLeft()
turtle.dig()
goForward()
turnLeft()
turnLeft()

-- Data Management Area

local world_data = {}

function spotExists(fx, fy)
    local exists = world_data[fx] ~= nil
    if exists then
        exists = world_data[fx][fy] ~= nil
    end
    return exists
end

function getSpot(fx, fy)
    if spotExists(fx, fy) then
        return world_data[fx][fy]
    end
    return "?"
end

function enterSpot(fx, fy, value)
    local exists = world_data[fx] ~= nil
    if not exists then
        world_data[fx] = {}
    end

    world_data[fx][fy] = value

end

enterSpot(10, 10, "poop")

-- Actual Code
function main()
    width, height = term.getSize()

    for y = 1, height do
        for x = 1, width do
            spot = getSpot(x, y)
            if spot ~= "?" then
                term.setBackgroundColor(colors.white)
            else
                term.setBackgroundColor(colors.black)
            end
            term.write(" ")
        end
        term.setCursorPos(1, y)
    end
end

main()

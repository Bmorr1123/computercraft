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

    --print(world_data[fx][fy])

end

function loadMap(map_path)
    local file = fs.open(map_path, "r")

    local y = 1
    local line = file.readLine()
    while line do
        for x = 1, #line do
            enterSpot(x, y, line:sub(x, x))
        end

        line = file.readLine()
        y = y + 1
    end
end

-- Actual Code
function main()
    term.clear()
    width, height = term.getSize()

    for y = 1, height do
        term.setCursorPos(1, y)
        for x = 1, width do
            spot = getSpot(x, y)

            if spot ~= "?" and spot ~= " " then
                term.setBackgroundColor(colors.white)
            else
                term.setBackgroundColor(colors.black)
            end
            term.write(" ")
        end

    end
end

loadMap("map.txt")
main()
read()

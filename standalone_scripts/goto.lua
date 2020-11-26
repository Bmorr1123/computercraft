x = arg[1]
y = arg[2]
z = arg[3]
heading = arg[4]

function turnRight()
    ret = turtle.turnRight()
    heading = (heading + 1) % 4
end

function turnLeft()
    turtle.turnLeft()
    heading = (heading - 1)
    if heading < 0 then
        heading = heading + 4
    end
end

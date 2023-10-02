

local function execute_moves(moves)
    while #moves > 0 do
        local move = table.remove(moves, 1)

        local result = movement_functions[move]()
        if not result then
            print("Something went horribly wrong.")
        end

    end
end

return {execute_moves=execute_moves}
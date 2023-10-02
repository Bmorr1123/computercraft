exists, data = turtle.inspect()

file = io.open("inspect_data", "a")

function table_print(data, indent, indent_string)
    indent = indent or 1
    indent_string = indent_string or "    "

    file:write("{\n")
    for i, v in pairs(data) do
        for i = 1, indent do
            file:write(indent_string)
        end
        file:write("\"", i, "\": ")

        -- Need to remove , on last element
        if type(v) == "table" then
            table_print(v, indent + 1, indent_string)
        elseif type(v) == "string" then
            file:write("\"", v, "\",\n")
        else
            file:write(tostring(v), ",\n")
        end
    end
    for i = 1, indent - 1 do
        file:write(indent_string)
    end
    
    file:write("},\n")  -- Need to remove , on last element

end

if exists then
    table_print(data)
end

file:close()

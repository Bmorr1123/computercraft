parentDir = "disk/file_server/files"

print(parentDir)
monitor = peripheral.wrap("left")

function sPrint(...)
    local s = "&0"
    for k, v in ipairs(arg) do
        s = s .. v
    end
    s = s .. "&0"

    local fields = {}
    local lastcolor, lastpos = "0", 0
    for pos, clr in s:gmatch"()&(%x)" do
        table.insert(fields, {s:sub(lastpos + 2, pos - 1), lastcolor})
        lastcolor, lastpos = clr, pos
    end

    for i = 2, #fields do
        monitor.setTextColor(2 ^ (tonumber(fields[i][2], 16)))
        monitor.write(fields[i][1])
    end
    local x, y = monitor.getCursorPos()
    monitor.setCursorPos(0, y + 1)
end

-- The rainbow
clrs = {"&e", "&1", "&4", "&5", "&d", "&9", "&b", "&2"}
function walk(dir, indentation, clr)
    local indentation = indentation or ""
    local clr = clr or 0
    if not fs.exists(dir) then
        monitor.write("Cannot find \""..dir.."\"")
    elseif dir == "/rom" then

    elseif fs.isDir(dir) then

        -- Prints dir indented and colored appropriately
        local lastSlash = #dir - (dir:reverse():find("/") or 1) + 1
        local c = clrs[(clr % #clrs) + 1]
        sPrint(indentation..c..string.sub(dir, lastSlash + 1)..":")

        -- Gets all subdirs of dir
        local list = fs.list(dir)

        --Sorting files so directories are behind the files
        for x = 1, #list, 1 do
            for y = x + 1, #list, 1 do
                if fs.isDir(dir.."/"..list[x]) and not fs.isDir(dir.."/"..list[y]) then
                    local hold = list[x]
                    list[x] = list[y]
                    list[y] = hold
                    break
                end
            end
        end
        -- Sorting directories alphabetically
        for x = 1, #list, 1 do
            if fs.isDir(dir.."/"..list[x]) then
                for y = x + 1, #list, 1 do
                    if list[x] > list[y] then
                        local hold = list[x]
                        list[x] = list[y]
                        list[y] = hold
                    end
                end
            end
        end
        -- Prints each file/dir in dir
        local hasDir = false
        for i = 1, #list, 1 do
            local file = list[i]
            -- Checks if it's the first dir in list
            if fs.isDir(dir.."/"..file) and not hasDir then
                hasDir = true
                -- Checks if there are files before it
                if i ~= 1 then
                    -- \n
                    sPrint()
                end
            end
            walk(dir.."/"..file, indentation.."    ", clr + 1)
        end
        if #fs.list(dir) == 0 then
            sPrint(indentation..clrs[((clr + 1) % #clrs) + 1].."    nil")
        end
    else
        local lastSlash = #dir - dir:reverse():find("/") + 1
        sPrint(indentation..clrs[(clr % #clrs) + 1]..string.sub(dir, lastSlash + 1))
    end
end

while true do
    monitor.clear()
    monitor.setCursorPos(1, 1)
    walk(parentDir)
    sleep(10)
end

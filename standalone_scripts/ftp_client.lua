function currentTimeString()
    return textutils.formatTime(os.time("local"))
end

myId = os.getComputerID()
myProtocol = "ftp"
startupTime = currentTimeString()
parentDir = "/disk/"
termWidth, termHeight = term.getSize()

function printMessage(id, message, protocol)
    print(id, "("..currentTimeString().."):", message)
    return id, message, protocol
end

function startsWith(str, substr)
    if str == nil then
        print("str == nil so str doesn't start with", substr)
    end
    return str:find("^"..substr) ~= nil
end

function shortenPath(debug, path, size, ...)
    if debug then
        print("in:", path)
    end
    local lastLen = path:len() - 1
    if debug then
        print("l1", lastLen)
    end
    while path:len() >= size and path:len() ~= lastLen do
        lastLen = path:len()
        local s = path:len()
        local e = 1
        for k, v in ipairs(arg) do
            if debug then
                print(v)
            end
            local s2, e2 = path:find(v)
            s2 = s2 or path:len()
            e2 = e2 or 0
            if debug then
                print(e2)
            end
            s = math.min(s2, s)
            e = math.max(e2, e)
        end
        if debug then
            print(e)
        end
        --if e ~= 0 then
            path = path:sub(1, math.max(e - 1, 1))..path:sub(math.max(e, 2), path:len()):gsub("%/.-%/", "/.../", 1)
        --end
    end
    if debug then
        print("ret:", path)
    end
    return path
end

function rfind(str, substr)
    return #str - str:reverse():find(substr:reverse()) + 1
end

function receiveDir(data, protocol, timeout, indentation)
    timeout = timeout or 1
    indentation = indentation or "    "
    if startsWith(data, "dir:") then
        dir = string.sub(data, 5)
        fs.makeDir(parentDir..dir)
        print(indentation..parentDir..dir)
        id, data, protocol = rednet.receive(protocol, timeout)
        while data ~= "EOD" do
            print("Waiting for EOD")
            receiveDir(data, protocol, timeout, indentation.."    ")
            id, data, protocol = rednet.receive(protocol, timeout)
        end
    elseif startsWith(data, "file:") then
        file = string.sub(data, 6)
        print(indentation..parentDir..file)
        file = fs.open(parentDir..file, "w")
        id, data, protocol = rednet.receive(protocol, timeout)
        while data ~= "EOF" do
            file.write(data.."\n")
            id, data, protocol = rednet.receive(protocol, timeout)
        end
        file.close()
    else
        print("Received unknown command \""..data.."\"!")
    end
end

rednet.open("back")
local servers = {rednet.lookup(myProtocol)}

if servers == nil then
    print("No servers were found!")
else
    for _, id in pairs(servers) do
        response = "busy"
        repeat
            rednet.send(id, "u up?", myProtocol)
            id, response, protocol = rednet.receive(myProtocol)
            if response == "busy" then
                print("Server is busy...waiting in queue")
                sleep(3)
                term.clear()
                term.setCursorPos(1, 1)
            else
                term.setTextColor(colors.green)
                write(response.."\n")
                term.setTextColor(colors.white)
            end
        until (response ~= "busy")
        id, message, protocol = rednet.receive(myProtocol, 5)
        while message ~= nil do
            -- Printing the "0/ftp>" in color
            term.setTextColor(colors.blue)
            -- Shorten the path until it fits on one line.
            local path = shortenPath(false, id.."/ftp/"..message.."> ", termWidth, "/ftp/", "/%.+/")
            write(path)
            -- If near the end, then return
            if path:len() + 3 > termWidth then
                print()
            end
            term.setTextColor(colors.white)
            -- Handling and forwarding user input
            cmd = read()
            rednet.send(id, cmd, protocol)
            id, data, protocol = rednet.receive(protocol, 1)
            -- command cases
            if startsWith(cmd, "update ") then
                receiveDir(data)
            elseif startsWith(cmd, "ls") then
                while data ~= "EOD" do
                    if startsWith(data, "dir:") then
                        term.setTextColor(colors.green)
                        -- data = data:sub(5):gsub("/^[^/]*/", "/.../")
                        print(data:sub(rfind(data, "/") + 1))
                        term.setTextColor(colors.white)
                    elseif startsWith(data, "file:") then
                        -- shortenPath(false, data:sub(6), termWidth, "/files/", "/%.+/")
                        -- data = data:sub(6):gsub("/^[^/]*/", "/.../")
                        print(data:sub(rfind(data, "/") + 1))
                    else
                        print(data, "edge cased!")
                    end
                    id, data, protocol = rednet.receive(protocol, 1)
                end
            end
            if cmd == "" or startsWith(cmd, "e") or startsWith(cmd, "st") then
                print("Ended session. Press enter to proceed.")
                read()
                message = nil
                term.clear()
                term.setCursorPos(1, 1)
            else
                id, message, protocol = rednet.receive(protocol, 3)
            end
        end
    end
end
rednet.close("back")

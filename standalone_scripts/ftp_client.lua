function currentTimeString()
    return textutils.formatTime(os.time("local"))
end

myId = os.getComputerID()
myProtocol = "ftp"
startupTime = currentTimeString()
parentDir = "/disk/"

function printMessage(id, message, protocol)
    print(id, "("..currentTimeString().."):", message)
    return id, message, protocol
end

function startsWith(str, substr)
    return str:find("^"..substr) ~= nil
end

function receiveDir(data, protocol, timeout, indentation)
    timeout = timeout or 1
    indentation = indentation or "    "
    if startsWith(data, "dir:") then
        dir = string.sub(data, 5)
        fs.makeDir(parentDir..dir)g
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

rednet.open("right")
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
            write(id.."/ftp/"..message.."> ")
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
                        print(string.sub(data, 5))
                        term.setTextColor(colors.white)

                    elseif startsWith(data, "file:") then
                        print(string.sub(data, 6))
                    end
                    id, data, protocol = rednet.receive(protocol, 1)
                end
            end
            if cmd == "" or startsWith(cmd, "e") or startsWith(cmd, "st") then
                print("Ended session.")
                message = nil
                sleep(3)
                term.clear()
                term.setCursorPos(1, 1)
            else
                id, message, protocol = rednet.receive(protocol, 3)
            end
        end
    end
end
rednet.close("right")
sleep(1)

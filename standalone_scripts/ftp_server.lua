function currentTimeString()
    return textutils.formatTime(os.time("local"))
end

myId = os.getComputerID()
myProtocol = "ftp"
startupTime = currentTimeString()
parentDir = "disk/file_server/"

function startsWith(str, substr)
    return str:find("^"..substr) ~= nil
end

function printMessage(id, message, protocol)
    print(id, "("..currentTimeString().."):", message)
    return id, message, protocol
end

function sendDir(path, id, protocol, indentation)
    indentation = indentation or ""
    sPath = string.sub(path, string.len(parentDir) + 1)

    if fs.isDir(path) then
        print(indentation..path)
        rednet.send(id, "dir:"..path, protocol)

        filesSent = 0
        dirsSent = 1

        for _, file in pairs(fs.list(path)) do
            f, d = sendDir(sPath.."/"..file, id, protocol)
            filesSent = filesSent + f
            dirsSent = dirsSent + d
        end
        rednet.send(id, "EOD", protocol)
        return filesSent, dirsSent
    elseif fs.exists(path) then
        print(indentation..path)
        rednet.send(id, "file:"..sPath, protocol)
        file = io.open(path, "r")
        for line in file:lines() do
            os.sleep(0.25)
            rednet.send(id, line, protocol)
        end
        rednet.send(id, "EOF", protocol)
        return 1, 0
    else
        print("Could not find file/dir \""..path.."\"!")
        print(fs.find(path.."*"))
        return 0, 0
    end
end

function transmitDir(path, id, protocol)
    sPath = string.sub(path, string.len(parentDir) + 1)
    if fs.exists(path) then
        print("Sent \""..sPath.."\"")
        if fs.isDir(path) then
            rednet.send(id, "dir:"..sPath, protocol)
            print("sent dir:"..sPath)
            for _, file in pairs(fs.list(path)) do
                if fs.isDir(path..file) then
                    rednet.send(id, "dir:"..sPath..file, protocol)
                else
                    print(file)
                    rednet.send(id, "file:"..sPath..file, protocol)
                end
            end
            rednet.send(id, "EOD", protocol)
        else
            rednet.send(id, "file:"..sPath, protocol)
        end
    else
        rednet.send(id, "Couldn't find \""..sPath.."\"")
    end
end
rednet.open("top")
rednet.host(myProtocol, tostring(myId))
print("Hosting \""..myProtocol.."\" on \""..myId.."\" at "..startupTime.."!")

subDir = "files/"

lastMessage = nil
currentClient = nil
while true do
    term.setTextColor(colors.yellow)
    if currentClient ~= nil and lastMessage == currentClient then
        rednet.send(currentClient, subDir, myProtocol)
        print("Waiting for message...")
    else
        print("Waiting for connection")
    end

    term.setTextColor(colors.blue)
    id, message, protocol = printMessage(rednet.receive(myProtocol))
    term.setTextColor(colors.white)
    lastMessage = id
    if currentClient ~= nil and id ~= currentClient then
        rednet.send(id, "busy", protocol)
        print("told", id, "busy")
    elseif currentClient == nil or id == currentClient then
        currentClient = id
        if message == "u up?" then -- u up?
            rednet.send(id, "Welcome to "..myId.."/ftp!", protocol)
        elseif message == "ls" then  -- ls
            transmitDir(parentDir..subDir, id, protocol)
        elseif startsWith(message, "cd ") then -- cd
            dir = string.sub(message, 4)
            cd = parentDir..subDir..dir
            if dir == ".." and subDir ~= "files/" then -- parent
                -- Remove the last /
                subDir = string.sub(subDir, 1, -2)
                -- Cut to the previous dir
                subDir = string.sub(subDir, 1, #subDir - subDir:reverse():find("/") + 1)
                rednet.send(id, "Successfully moved to parent directory!", protocol)
            elseif fs.exists(cd) then
                if fs.isDir(cd) then
                    subDir = subDir..dir.."/"
                    rednet.send(id, "Directory change successful!", protocol)
                else
                    rednet.send(id, "Directory specified is file!", protocol)
                end
            else
                rednet.send(id, "Directory does not exist!", protocol)
            end
        elseif startsWith(message, "update ") then -- send
            file = parentDir..subDir..string.sub(message, 8)
            filesSent, dirsSent = 0, 0
            if file == parentDir.."/all" then
                filesSent, dirsSent = sendDir(parentDir, id, protocol)
            else
                filesSent, dirsSent = sendDir(file, id, protocol)
            end
            term.setTextColor(colors.green)
            print("Sent -> "..id..":")
            print("    "..dirsSent, "directories")
            print("    "..filesSent, "files")
            term.setTextColor(colors.white)
        elseif message == "" or startsWith(message, "st") or startsWith(message, "e") then
            term.setTextColor(colors.red)
            print(id, "exited.")
            term.setTextColor(colors.white)
            currentClient = nil
            lastMessage = nil
        end
    end
end
rednet.close("top")

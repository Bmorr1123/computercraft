
---------------------------------------------------------- Argument Checking ---
function check_args()
    local args = { ... }
    if not #args >= 0 then
        print("Usage:"..fs.getName(shell.getRunningProgram()).."")
        return
    end
    return args
end

-------------------------------------------------------- Peripheral Checking ---
function check_peripherals()

    if not turtle then
        printError("Requires a Turtle.")
        return
    end

    local peripheral_combinations = {
        ["miner"]={"modem", nil},
        ["scanner"]={"modem", "geoScanner"},
        ["loader"]={"modem", "chunky"}
    }

    local left, right = peripheral.getType("left"), peripheral.getType("right")

    for job, combo in pairs(peripheral_combinations) do
        if peripheral.isPresent(combo[1]) and peripheral.isPresent(combo[2]) then
            return job
        end
    end

    print("Could not find the proper peripherals. \nPlease give your turtles the correct peripherals for the job.")
    for job, combo in pairs(peripheral_combinations) do
        print("\t"..job..": "..tostring(combo[1]).." + "..tostring(combo[2]))
    end
end

function main()
    local args = check_args()
    local job = check_peripherals()
    if job == nil then
        return
    end

    if job == "miner" then
        shell.run("miner.lua")
    end

end

main()
------------------------------------------------------------------------------------------
-- ORE3D - Fully Immersive Augmented Reality X-RAY Vision for Ore Mining using Plethora --
------------------------------------------------------------------------------------------

-- CREATED BY:
--   HydroNitrogen (a.k.a. GoogleTech, Wendelstein7)
--   Bram S. (a.k.a ThatBram0101, bram0101)

-- LICENCE: ZLIB/libpng Licence (Zlib) (MODIFIED)
--   Copyright (c) 2018 HydroNitrogen & Bram S.
--   This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
--   Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
--   1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
--   2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
--   3. Every version, altered and original, must always contain a link to the following internet page: https://energetic.pw/computercraft/ore3d
--   4. This notice may not be removed or altered from any source distribution.

-- VERSION 2018-03-29 15:52 (Dates are way easier than version numbers, :P )

-- GLOBAL SETTINGS
-- Change the settings here to your likings.
local fov = math.rad(70) -- Change according to your Minecraft settings! Minecraft default: 75
local ar = 1.8 -- Aspect ratio of your view - for a full HD screen: fullscreen: 1.7777, windowed: 1.8
local hintToBehind = true -- Show all blocks behind you on the sides of your screen
local charSize = 16 -- the base size of the indicators
local maxOreGroups = 32 -- The max amount of ore groups/veins to show.
local maxOreGroupRadius = 2 -- Radius to look for adjecent ores to combine to group

-- PERFORMANCE OPTIONS: These affect how badly this program will use your CPU.
-- SinglePlayer reccommended values: scansPerSecond = 10, rendersPerSecond = 30
-- MultiPlayer reccommended values: scansPerSecond = 1, rendersPerSecond = 5
local scansPerSecond = 1 -- how many times per second should it scan for new blocks?
local rendersPerSecond = 5 -- how many times per second should it draw a new frame?


-- Initialising modules [ IF YOU ERROR HERE, THEN YOU PROBABLY MISS ONE OR MORE REQUIRED MODULES!]
-- Required modules: Overlay Glasses, Introspection Module, Block Scanner
local modules = peripheral.find("neuralInterface")
local modb = peripheral.wrap("back")
local can = modb.canvas()
can.clear()


-- Performance optimalisation precalculations and initialising

local renderDelay = 1 / rendersPerSecond
local scanDelay = 1 / scansPerSecond

local scrhor = (1 / math.tan(fov / 2)) / ar
local scrver = (1 / math.tan(fov / 2))

local oreGroups = { }
local oreTexts = { }
for i = 1,maxOreGroups do
    oreGroups[i] =  { ["x"]=0, ["y"]=0, ["z"]=0, ["color"]=0x0, ["amount"]=0 }
    oreTexts[i] = can.addText({0,0}, " ", 0xFFFFFF00, 1)
end

local checkedBlocks = { }

local cx, cy = can.getSize()
local cxhalf = cx / 2
local cyhalf = cy / 2

local blocksToShow = { -- Add any blocks here to show up with respective colors. Blocks with the same color will be considered as a group.
    ["minecraft:emerald_ore"] = 0x46FF26AA,
    ["minecraft:diamond_ore"] = 0x50F8FFAA,
    ["minecraft:gold_ore"] = 0xFFDF50AA,
    ["minecraft:redstone_ore"] = 0xCC121566,
    ["minecraft:lit_redstone_ore"] = 0xCC121566,
    ["minecraft:iron_ore"] = 0xFFAC8766,
    ["minecraft:lapis_ore"] = 0x0A107F66,
    ["minecraft:coal_ore"] = 0x20202066,
    ["quark:biotite_ore"] = 0x02051C66,
    ["minecraft:quartz_ore"] = 0xCCCCCC66,
    ["minecraft:glowstone"] = 0xFFDFA166
}

function rotate(x, y, z) -- Matrix operation: rotate (optimized, uses precalculated values)
    newx = ycos * x + ysin * z
    newz = -ysin * x + ycos * z

    newy = pcos * y - psin * newz
    newz = psin * y + pcos * newz

    return newx,newy,newz
end

function toPerspective(x, y, z) -- Convert to perspective projection, removes a dimention (z)  (optimized, uses precalculated values)
    x = scrhor * x / z
    y = scrver * y / z

    return x,y
end

function ndcToSpc(x, y)
    x = x * cxhalf + cxhalf
    y = y * cyhalf + cyhalf

    return x, y
end

function getCharSize(d) -- Calculates size of indicators using distance
    return charSize / d
end

function isOnScreen(x, y, d) -- determines if something is visible
    return ( x >= 1 and x - getCharSize(d) < cx ) and ( y >= 1 and y - getCharSize(d) < cy )
end

function getDistance(x, y, z) -- calculates distance. We love you, Pythagoras.
    return math.sqrt(x * x + y * y + z * z)
end

function drawOre(x, y, z, color, amount, n) -- draw function for an ore, combines the above matrix operations
    d = getDistance(x, y, z)

    x,y,z = rotate(x, y, z)

    if hintToBehind and z < 0 then z = 0.001 end

    if z >= 0 or hintToBehind then -- render only if point is visible OR hintToBehind is enabled
        x,y = toPerspective(x, y, -z)
        x,y = ndcToSpc(x, y)

        if not hintToBehind and not isOnScreen(x, y, d) then
            oreTexts[n].setText(" ")
            return -- don't render.
        end

        x = math.min(math.max(x, 1), cx - 10 * getCharSize(d))
        y = math.min(math.max(cy - y, 1), cy - 10 * getCharSize(d))

        oreTexts[n].setPosition(x, y)
        oreTexts[n].setText(tostring(amount))
        oreTexts[n].setScale(getCharSize(d))
        oreTexts[n].setColor(color)
    else
        oreTexts[n].setText(" ")
    end
end

function scan() -- Scan blocks and group them
    while true do
        blocks = modb.scan()

        for i = 1,maxOreGroups do
            oreGroups[i] =  { ["x"]=0, ["y"]=0, ["z"]=0, ["color"]=0x0, ["amount"]=0 }
        end

        checkedBlocks = { }

        local n = 1

        local finished = false


        for x = -8,8 do

            if finished then break end

            for y = -8,8 do

                if finished then break end

                for z = -8,8 do
                    if n > maxOreGroups then
                        finished = true
                        break
                    end

                    if checkedBlocks[17^2 * (x + 8) + 17 * (y + 8) + (z + 8) + 1] == nil then
                        local block = blocks[17^2 * (x + 8) + 17 * (y + 8) + (z + 8) + 1]
                        local color = blocksToShow[block.name]

                        local blockb = false
                        local colorb = false

                        if color ~= nil then
                            local amount = 0
                            local xa,ya,za = 0,0,0

                            for xb = x-maxOreGroupRadius, x+maxOreGroupRadius do
                                for yb = y-maxOreGroupRadius, y+maxOreGroupRadius do
                                    for zb = z-maxOreGroupRadius, z+maxOreGroupRadius do
                                        if xb >= -8 and xb <= 8 and yb >= -8 and yb <= 8 and zb >= -8 and zb <= 8 and not checkedBlocks[17^2 * (xb + 8) + 17 * (yb + 8) + (zb + 8) + 1] then
                                            blockb = blocks[17^2 * (xb + 8) + 17 * (yb + 8) + (zb + 8) + 1]
                                            colorb = blocksToShow[blockb.name]

                                            if color == colorb then
                                                amount = amount + 1
                                                xa,ya,za = xa+xb,ya+yb,za+zb
                                                checkedBlocks[17^2 * (xb + 8) + 17 * (yb + 8) + (zb + 8) + 1] = true
                                            end
                                        end
                                    end
                                end
                            end

                            xa,ya,za = xa / amount, ya / amount, za / amount

                            oreGroups[n] = { ["x"]=xa, ["y"]=ya, ["z"]=za, ["color"]=color, ["amount"]=amount }

                            n = n + 1
                        end
                    end
                end
            end
        end
        sleep(scanDelay)
    end
end

function render()
    while true do
        local meta = modules.getMetaOwner()
        local yaw = math.rad(meta.yaw)
        local pitch = math.rad(meta.pitch)

        ysin = math.sin(yaw)
        ycos = math.cos(yaw)

        psin = math.sin(pitch)
        pcos = math.cos(pitch)

        local block = false

        for n = 1, maxOreGroups do
            block = oreGroups[n]
            if block.amount > 0 then
                drawOre(block.x - meta.x + 0.5, -block.y + meta.y + 1, block.z - meta.z + 0.5, block.color, block.amount, n)
            else
                oreTexts[n].setText(" ")
            end
        end

        sleep(renderDelay)
    end
end

parallel.waitForAny(
    render,
    scan
)

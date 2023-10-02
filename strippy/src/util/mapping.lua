--[[
    pastebin get 3EjbHEPN mapping.lua
]]


local Chunk = {
    new = function()
        local chunk = {
            voxels = {}
        }
        return chunk
    end
}

local World = {
    new = function(chunkSize)
        local world = {
            chunkSize = chunkSize,
            chunks = {}
        }
        return world
    end,

    setVoxel = function(world, x, y, z, value)
        local chunkX = math.floor(x / world.chunkSize)
        local chunkY = math.floor(y / world.chunkSize)
        local chunkZ = math.floor(z / world.chunkSize)

        local chunkKey = string.format("%d,%d,%d", chunkX, chunkY, chunkZ)

        -- Create the chunk if it doesn't exist
        if not world.chunks[chunkKey] then
            world.chunks[chunkKey] = Chunk.new()
        end

        local chunk = world.chunks[chunkKey]
        local voxelX = x % world.chunkSize
        local voxelY = y % world.chunkSize
        local voxelZ = z % world.chunkSize

        local voxelKey = string.format("%d,%d,%d", voxelX, voxelY, voxelZ)
        chunk.voxels[voxelKey] = value
    end,

    getVoxel = function(world, x, y, z)
        local chunkX = math.floor(x / world.chunkSize)
        local chunkY = math.floor(y / world.chunkSize)
        local chunkZ = math.floor(z / world.chunkSize)

        local chunkKey = string.format("%d,%d,%d", chunkX, chunkY, chunkZ)
        local chunk = world.chunks[chunkKey]

        if chunk then
            local voxelX = x % world.chunkSize
            local voxelY = y % world.chunkSize
            local voxelZ = z % world.chunkSize

            local voxelKey = string.format("%d,%d,%d", voxelX, voxelY, voxelZ)
            return chunk.voxels[voxelKey]
        end

        return nil
    end,

    getNode = function(world, node)
        local chunkX = math.floor(node.x / world.chunkSize)
        local chunkY = math.floor(node.y / world.chunkSize)
        local chunkZ = math.floor(node.z / world.chunkSize)

        local chunkKey = string.format("%d,%d,%d", chunkX, chunkY, chunkZ)

        -- Create the chunk if it doesn't exist
        if not world.chunks[chunkKey] then
            world.chunks[chunkKey] = Chunk.new()
        end

        -- Get the chunk
        local chunk = world.chunks[chunkKey]

        local voxelX = node.x % world.chunkSize
        local voxelY = node.y % world.chunkSize
        local voxelZ = node.z % world.chunkSize

        local voxelKey = string.format("%d,%d,%d", voxelX, voxelY, voxelZ)

        -- Create the node if it doesn't exist
        if not chunk.voxels[voxelKey] then
            chunk.voxels[voxelKey] = node
        end
        
        -- Return the node
        return chunk.voxels[voxelKey]
    end,

    setNode = function(world, node)
        local chunkX = math.floor(node.x / world.chunkSize)
        local chunkY = math.floor(node.y / world.chunkSize)
        local chunkZ = math.floor(node.z / world.chunkSize)

        local chunkKey = string.format("%d,%d,%d", chunkX, chunkY, chunkZ)

        -- Create the chunk if it doesn't exist
        if not world.chunks[chunkKey] then
            world.chunks[chunkKey] = Chunk.new()
        end

        local chunk = world.chunks[chunkKey]
        local voxelX = node.x % world.chunkSize
        local voxelY = node.y % world.chunkSize
        local voxelZ = node.z % world.chunkSize

        local voxelKey = string.format("%d,%d,%d", voxelX, voxelY, voxelZ)
        chunk.voxels[voxelKey] = node
    end
}

function example()
    -- Example usage
    local world = World.new(16) -- Chunk size of 16

    -- Set voxel at coordinates (5, 5, 5) to 1
    World.setVoxel(world, 5, 5, 5, 1)

    -- Get voxel value at coordinates (5, 5, 5)
    local voxelValue = World.getVoxel(world, 5, 5, 5)

    print(voxelValue) -- Output: 1
end


return {Chunk=Chunk, World=World, example=example}
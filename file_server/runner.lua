--[[
This file is the runner for the ftp_server.
It needs to be run by a startup file
It must have shell and multishell as environment variables
TODO: Make an install script
--]]
local ftp_id = multishell.launch({}, "/disk/file_server/ftp_server.lua")
multishell.setTitle(ftp_id, "ftp")

local git_id = multishell.launch({shell = shell}, "disk/file_server/gitget.lua", "bmorr1123", "computercraft", "main", "github_repos")
multishell.setTitle(git_id, "git")

local mon_id = multishell.launch({}, "/disk/file_server/file_structure.lua", "/disk/file_server/files")
multishell.setTitle(mon_id, "fsu")

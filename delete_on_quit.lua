local mp = require 'mp'
local utils = require 'mp.utils'

local function delete_file()
    local path = mp.get_property("path")
    if not path then
        mp.msg.warn("No file path found.")
        return
    end
    
    if path:match("^%w+://") then
        mp.msg.info("File is a stream, skipping deletion.")
        return
    end
    
    local args = {"rm", path}
    local res = utils.subprocess({args = args})
    if res.error == nil then
        mp.msg.info("Deleted file: " .. path)
    else
        mp.msg.error("Failed to delete file: " .. res.error)
    end
end

local function confirm_delete()
    delete_file()
    mp.command("quit")
end

local function prompt_delete()
    local filename = mp.get_property("filename") or mp.get_property("path"):match("^.+/(.+)$")
    if not filename then
        mp.msg.warn("Filename could not be determined.")
        return
    end
    
    local prompt_msg = "Do you want to delete \"" .. filename .. "\"? Press 'y' to confirm, 'n' to cancel."
    mp.osd_message(prompt_msg, 3)
    
    mp.add_forced_key_binding("y", "confirm_delete", confirm_delete)
    mp.add_forced_key_binding("n", "cancel_delete", function() mp.command("quit") end)
end

mp.add_key_binding("d", "delete_with_prompt", prompt_delete)

-- delete_on_quit.lua
local mp = require 'mp'
local utils = require 'mp.utils'

-- Function to delete the file
local function delete_file()
    local path = mp.get_property("path")
    if not path then
        mp.msg.warn("No file path found.")
        return
    end

    -- Check if file is a URL (like a YouTube video), skip deletion
    if path:match("^%w+://") then
        mp.msg.info("File is a stream, skipping deletion.")
        return
    end

    -- Try to delete the file
    local args = {"rm", path}
    local res = utils.subprocess({args = args})

    if res.error == nil then
        mp.msg.info("Deleted file: " .. path)
    else
        mp.msg.error("Failed to delete file: " .. res.error)
    end
end

-- Function to confirm and handle deletion
local function confirm_delete()
    delete_file()
    mp.command("quit")  -- Quit after deletion
end

-- Prompt the user to delete the video upon pressing 'q'
local function prompt_delete()
    local filename = mp.get_property("filename") or mp.get_property("path"):match("^.+/(.+)$")
    if not filename then
        mp.msg.warn("Filename could not be determined.")
        return
    end

    local prompt_msg = "Do you want to delete \"" .. filename .. "\"? Press 'y' to confirm, 'n' to cancel."
    mp.osd_message(prompt_msg, 3)

    -- Temporarily bind keys 'y' for yes and 'n' for no
    mp.add_forced_key_binding("y", "confirm_delete", confirm_delete)
    mp.add_forced_key_binding("n", "cancel_delete", function() mp.command("quit") end)
end

-- Override the default 'q' key to show the delete prompt instead of immediately quitting
mp.add_key_binding("q", "quit_with_prompt", prompt_delete)


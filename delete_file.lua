local stored_path = nil

function start_delete_process()
    mp.add_timeout(1, function()
        stored_path = mp.get_property("path")
        print("File path retrieved:", stored_path) -- Debug
    end)
end

function custom_quit()
    if stored_path then
        print("Delete process initiated") -- Debug
        mp.osd_message("Delete file? (y/n)", 3)
        mp.register_script_message("delete_response", function(response)
            if response == "y" then
                print("Deleting file:", stored_path) -- Debug
                os.remove(stored_path)
            else
                print("File will not be deleted") -- Debug
            end
            stored_path = nil
            mp.command("quit")
        end)
        mp.add_forced_key_binding("y", "delete_yes", function() mp.commandv("script-message", "delete_response", "y") end)
        mp.add_forced_key_binding("n", "delete_no", function() mp.commandv("script-message", "delete_response", "n") end)
    else
        mp.command("quit")
    end
end

mp.register_event("file-loaded", start_delete_process)
mp.add_forced_key_binding("q", "custom_quit", custom_quit)
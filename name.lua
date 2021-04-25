local steamworks = require "gamesense/steamworks"

local ISteamFriends = steamworks.ISteamFriends

stealname = ui.reference("Misc", "Miscellaneous", "Steal player name")

name = cvar.name

client.set_cvar("name", "\n\xAD\xAD")

local function on_paint()
        local local_player = entity.get_local_player()
    
        if local_player ~= nil then
                local name = entity.get_player_name(local_player)
                if name ~= nil then 
                        renderer.text(1, 10, 255, 255, 255, 255, "+b", 0, "name: '"..name.."'")
                end
        end
end

client.set_event_callback("paint", on_paint)

client.set_event_callback("player_connect_full", function(e)
        if client.userid_to_entindex(e.userid) == entity.get_local_player() then 
                ui.set(stealname, true)

                name:invoke_callback()
                client.set_cvar("name", "\n\xAD\xAD")
                client.delay_call(0.2, function()
                        client.set_cvar("name", "nigger\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n") 
                end)
        end
end)

client.set_event_callback("cs_win_panel_match", function(e)
        client.set_cvar("name", "nigger\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n") 
end)
local steamworks = require "gamesense/steamworks"

if steamworks == nil then
    error("Steamworks is nil, make sure you have subscribed SteamWork SDK from lua workshop")
end

local ISteamFriends = steamworks.ISteamFriends

stealname = ui.reference("Misc", "Miscellaneous", "Steal player name")

stole_player_name = false

function paint()
    local local_player = entity.get_local_player()

    if local_player ~= nil then
        local name = entity.get_player_name(local_player)
        if name ~= nil then
            renderer.text(1, 10, 255, 255, 255, 255, "+b", 0, string.format("name: \"%s\"", name))
        end
    end
end

function player_connect_full(e)
    if client.userid_to_entindex(e.userid) == entity.get_local_player() then 
        client.delay_call(globals.tickinterval(), function()
            local is_warmup_period = entity.get_prop(entity.get_game_rules(), "m_bWarmupPeriod")
            if is_warmup_period == 0 then
                if not stole_player_name then
                    ui.set(stealname, true)
                    stole_player_name = true
                end

                client.set_cvar("name", "\n\xAD\xAD")
                client.delay_call(0.2, function()
                        client.set_cvar("name", ISteamFriends.GetPersonaName()) 
                end)
            end
        end)
    end
end

function round_prestart(e)
    client.delay_call(globals.tickinterval(), function()
        local is_warmup_period = entity.get_prop(entity.get_game_rules(), "m_bWarmupPeriod")
        if is_warmup_period == 0 then
            if not stole_player_name then
                ui.set(stealname, true)
                stole_player_name = true
            end

            client.set_cvar("name", "\n\xAD\xAD")
            client.delay_call(0.2, function()
                    client.set_cvar("name", ISteamFriends.GetPersonaName()) 
            end)
        end
    end)
end

function cs_win_panel_match()
    client.set_cvar("name", "ez game\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n") 
end

client.set_event_callback("paint", paint)
client.set_event_callback("player_connect_full", player_connect_full)
client.set_event_callback("round_prestart", round_prestart)
client.set_event_callback("cs_win_panel_match", cs_win_panel_match)
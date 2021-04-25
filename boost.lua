local client_userid_to_entindex, client_set_event_callback, client_screen_size, client_trace_bullet, client_unset_event_callback, client_color_log, client_reload_active_scripts, client_scale_damage, client_get_cvar, client_camera_position, client_create_interface, client_random_int, client_latency, client_set_clan_tag, client_find_signature, client_log, client_timestamp, client_delay_call, client_trace_line, client_register_esp_flag, client_get_model_name, client_system_time, client_visible, client_exec, client_key_state, client_set_cvar, client_unix_time, client_error_log, client_draw_debug_text, client_update_player_list, client_camera_angles, client_eye_position, client_draw_hitboxes, client_random_float = client.userid_to_entindex, client.set_event_callback, client.screen_size, client.trace_bullet, client.unset_event_callback, client.color_log, client.reload_active_scripts, client.scale_damage, client.get_cvar, client.camera_position, client.create_interface, client.random_int, client.latency, client.set_clan_tag, client.find_signature, client.log, client.timestamp, client.delay_call, client.trace_line, client.register_esp_flag, client.get_model_name, client.system_time, client.visible, client.exec, client.key_state, client.set_cvar, client.unix_time, client.error_log, client.draw_debug_text, client.update_player_list, client.camera_angles, client.eye_position, client.draw_hitboxes, client.random_float
local entity_get_local_player, entity_is_enemy, entity_get_bounding_box, entity_get_all, entity_set_prop, entity_is_alive, entity_get_steam64, entity_get_classname, entity_get_player_resource, entity_get_esp_data, entity_is_dormant, entity_get_player_name, entity_get_game_rules, entity_get_origin, entity_hitbox_position, entity_get_player_weapon, entity_get_players, entity_get_prop = entity.get_local_player, entity.is_enemy, entity.get_bounding_box, entity.get_all, entity.set_prop, entity.is_alive, entity.get_steam64, entity.get_classname, entity.get_player_resource, entity.get_esp_data, entity.is_dormant, entity.get_player_name, entity.get_game_rules, entity.get_origin, entity.hitbox_position, entity.get_player_weapon, entity.get_players, entity.get_prop
local globals_realtime, globals_absoluteframetime, globals_chokedcommands, globals_oldcommandack, globals_tickcount, globals_commandack, globals_lastoutgoingcommand, globals_curtime, globals_mapname, globals_tickinterval, globals_framecount, globals_frametime, globals_maxplayers = globals.realtime, globals.absoluteframetime, globals.chokedcommands, globals.oldcommandack, globals.tickcount, globals.commandack, globals.lastoutgoingcommand, globals.curtime, globals.mapname, globals.tickinterval, globals.framecount, globals.frametime, globals.maxplayers
local ui_new_slider, ui_new_combobox, ui_reference, ui_set_visible, ui_new_textbox, ui_new_color_picker, ui_new_checkbox, ui_mouse_position, ui_new_listbox, ui_new_multiselect, ui_is_menu_open, ui_new_hotkey, ui_set, ui_update, ui_menu_size, ui_name, ui_menu_position, ui_set_callback, ui_new_button, ui_new_label, ui_new_string, ui_get = ui.new_slider, ui.new_combobox, ui.reference, ui.set_visible, ui.new_textbox, ui.new_color_picker, ui.new_checkbox, ui.mouse_position, ui.new_listbox, ui.new_multiselect, ui.is_menu_open, ui.new_hotkey, ui.set, ui.update, ui.menu_size, ui.name, ui.menu_position, ui.set_callback, ui.new_button, ui.new_label, ui.new_string, ui.get
local renderer_load_svg, renderer_world_to_screen, renderer_circle_outline, renderer_rectangle, renderer_gradient, renderer_circle, renderer_text, renderer_line, renderer_load_jpg, renderer_load_png, renderer_triangle, renderer_measure_text, renderer_load_rgba, renderer_indicator, renderer_texture = renderer.load_svg, renderer.world_to_screen, renderer.circle_outline, renderer.rectangle, renderer.gradient, renderer.circle, renderer.text, renderer.line, renderer.load_jpg, renderer.load_png, renderer.triangle, renderer.measure_text, renderer.load_rgba, renderer.indicator, renderer.texture
local math_ceil, math_tan, math_cos, math_sinh, math_pi, math_max, math_atan2, math_floor, math_sqrt, math_deg, math_atan, math_fmod, math_acos, math_pow, math_abs, math_min, math_sin, math_log, math_exp, math_cosh, math_asin, math_rad = math.ceil, math.tan, math.cos, math.sinh, math.pi, math.max, math.atan2, math.floor, math.sqrt, math.deg, math.atan, math.fmod, math.acos, math.pow, math.abs, math.min, math.sin, math.log, math.exp, math.cosh, math.asin, math.rad
local table_clear, table_sort, table_remove, table_concat, table_insert = table.clear, table.sort, table.remove, table.concat, table.insert
local string_find, string_format, string_len, string_gsub, string_gmatch, string_match, string_reverse, string_upper, string_lower, string_sub = string.find, string.format, string.len, string.gsub, string.gmatch, string.match, string.reverse, string.upper, string.lower, string.sub
local materialsystem_chams_material, materialsystem_arms_material, materialsystem_find_texture, materialsystem_find_material, materialsystem_override_material, materialsystem_find_materials, materialsystem_get_model_materials = materialsystem.chams_material, materialsystem.arms_material, materialsystem.find_texture, materialsystem.find_material, materialsystem.override_material, materialsystem.find_materials, materialsystem.get_model_materials
local ipairs, assert, pairs, next, tostring, tonumber, setmetatable, unpack, type, getmetatable, pcall, error = ipairs, assert, pairs, next, tostring, tonumber, setmetatable, unpack, type, getmetatable, pcall, error
local database_read, database_write = database.read, database.write

local ragebot_enabled = ui_reference("RAGE", "Aimbot", "Enabled")
local aimstep = ui_reference("RAGE", "Aimbot", "Reduce aim step")

local js = panorama.open()
local compapi = js.CompetitiveMatchAPI
local gamestateapi = js.GameStateAPI
local friendsapi = js.FriendsListAPI

local tears = {

    menu = {
        draw_player_name = ui_new_checkbox("LUA", "B", "[Boost] Draw local player name"),
        kill_nonwhitelisted = ui_new_checkbox("LUA", "B", "[Boost] Kill non-whitelisted player"),
        auto_kick = ui_new_checkbox("LUA", "B", "[Boost] Auto vote"),
        disalbe_ragebot = ui_new_checkbox("LUA", "B", "[Boost] Turn off rb after x kills"),
        disalbe_ragebot_kills = ui_new_slider("LUA", "B", "Kill", "10", "50", "10"),
        disalbe_ragebot_when_immune = ui_new_checkbox("LUA", "B", "[Boost] Turn off rb when immune"),
        auto_disconnect_reconnect = ui_new_checkbox("LUA", "B", "[Boost] Auto disconnect"),
        disconnect_match_is_over = ui_new_checkbox("LUA", "B", "[Boost] Auto disconnect when match is over"),
        reconnect_delay = ui_new_slider("LUA", "B", "Time to reconnect after disconnecting", "0.0", "15.5", "3.5", true, "s", "1.00"),
        get_steamid = ui_new_button("LUA", "B", "Get SteamID3", function()
            local local_player = entity_get_local_player()
            local steamid3 = entity_get_steam64(local_player)
            tears.log({text = steamid3})
        end)
    },

    database = {
        name = {
            steamid = "tears.database.steamid",
            webhook = "tears.database.webhook"
        }
    },

    steamid = {},

    -- https://gamesense.pub/forums/viewtopic.php?id=18281 credit goes to x0m
    vote = {
        indices_noteam = {
			[0] = "kick",
			[1] = "changelevel",
			[3] = "scrambleteams",
			[4] = "swapteams",
		},
		indices_team = {
			[1] = 'starttimeout',
			[2] = 'surrender'
		},
		descriptions = {
			changelevel = 'change the map',
			scrambleteams = 'scramble the teams',
			starttimeout = 'start a timeout',
			surrender = 'surrender',
			kick = 'kick'
		},
		ongoing_votes = {},
		vote_options = {}
    },

    match = {
        maxs_round = 0,
        current_round = 0,
        rounds_to_win = 0
    },

    log = function(elements)
        local text = elements.text
        local usage = elements.usage

        local use_color = elements.use_color

        local red = elements.red
        local green = elements.green
        local blue = elements.blue

        local clr = {
            [1] = use_color and red or 255,
            [2] = use_color and green or 255,
            [3] = use_color and blue or 255
        }

        if text ~= nil then 
            client_color_log(255, 255, 255, "[\0")
            client_color_log(128, 255, 128, "tears\0")
            client_color_log(255, 255, 255, "] - \0")

            client_color_log(clr[1], clr[2], clr[3], string_format("%s%s", text, usage == nil and "" or " - "..usage))
        end
    end,
}

tears.functions = {
    update_steamid_list = function(str)
        for k in pairs(tears.steamid) do 
            tears.steamid[k] = nil
        end
    
        local i = 0
        for w in string_gmatch(str, "([^;]+)") do
            i = i + 1
            tears.steamid[i] = w
        end
    end,

    table_contains = function(tbl, value)
        for i=1, #tbl do
            if tbl[i] == value then
                return true
            end
        end
        return false
    end,

    string_explode = function(separator, str)
        local ret = {}
        local currentPos = 1

        for i = 1, #str do
            local startPos, endPos = string.find(str, separator, currentPos)
            if ( not startPos ) then break end
            ret[ i ] = string.sub( str, currentPos, startPos - 1 )
            currentPos = endPos + 1
        end

        ret[#ret + 1] = string.sub( str, currentPos )

        return ret
    end,

    update_list = function(id, set, clean)
        if set == true and clean == false then 
            database_write(tears.database.name.steamid, id)
            tears.functions.update_steamid_list(id)
        elseif set == false and clean == true then
            database_write(tears.database.name.steamid, "\0")
            tears.functions.update_steamid_list("\0")
        elseif set == false and clean == false then 
            local a = database_read(tears.database.name.steamid)
            a = a..";"..id
            tears.log({text= string_format("%s", a)})
            database_write(tears.database.name.steamid, a)
            tears.functions.update_steamid_list(a)
        end
    end
}

tears.command_list = {
    ["help"] = {
        usage = "Show all available commands."
    },
    ["set_steamid_list"] = {
        usage = "tears_set_steamid_list <id3|clean>. id3 is steamid3. To clear the data please use <clear>."
    },
    ["add_steamid_to_list"] = {
        usage = "tears_add_steamid_list <id3>. Basically the same as set_steamid_list, but the id can be added based on the list and cannot clean the list."
    },
    ["get_steamid_list"] = {
        usage = "Get steamid list from the databse."
    }
}

tears.commands_callback = {
    ["help"] = function()
        tears.log("The following commands are available:")
        for cmd, l in pairs(tears.command_list) do 
            tears.log({text = "tears_"..cmd, usage = l.usage })
        end
    end,
    ["set_steamid_list"] = function(tab)
        if tab[1] ~= nil then 
            if tab[1] == "clean" then 
                tears.functions.update_list(tab[1], false, true)
            else
                tears.log({text = tab[1][1]})
                tears.functions.update_list(tab[1], true, false)
            end
        end
    end,
    ["add_steamid_to_list"] = function(tab)
        if tab[1] ~= nil then 
            tears.functions.update_list(tab[1], false, false)
        end
    end,
    ["get_steamid_list"] = function(tab)
        local list = database_read(tears.database.name.steamid)

        for w in list:gmatch("([^;]+)") do
            tears.log({text = string_format("%s", string_len(list) > 1 and "[U:1:"..w.."]" or "empty" )})
        end 
    end,
}

tears.callbacks = {
    events = {
        paint = function()
            local local_player = entity_get_local_player()
        
            if local_player ~= nil then
                if ui_get(tears.menu.draw_player_name) == true then 
                    local name = entity_get_player_name(local_player)
                    if name ~= nil then 
                        renderer_text(1, 10, 255, 255, 255, 255, "+b", 0, "name: "..name)
                    end
                end
            end
        end,

        setup_command = function(cmd)
            local local_player = entity_get_local_player()
            if local_player ~= nil then 
                if ui_get(tears.menu.disalbe_ragebot) == true then 

                    local kills = entity_get_prop(entity_get_player_resource(), "m_iKills", local_player)
            
                    if ui_get(tears.menu.disalbe_ragebot_when_immune) == true then 
                        local is_immunity = entity_get_prop(local_player, "m_bGunGameImmunity")
                        if entity_is_alive(local_player) then
                            if is_immunity == 1  then 
                                ui_set(ragebot_enabled, false)
                            else 
                                ui_set(ragebot_enabled, true)
                            end
                        end
                    end

                    if kills >= ui_get(tears.menu.disalbe_ragebot_kills) then 
                        ui_set(ragebot_enabled, false)
                    else 
                        ui_set(ragebot_enabled, true)
                    end
                end
            end
        end,

        console_input = function(text)
            if text:sub(1, #"tears") == "tears" then
                text = tears.functions.string_explode(" ", text)
                local cmd = text[1]:sub(#"tears_" + 1, -1):lower()
        
                table_remove(text, 1)
        
                if tears.command_list[cmd] then 
                    tears.commands_callback[cmd](text)
                else
                    tears.log({text = string_format("The command you typed doesn't exist, please type tears_help for all available commands.")})
                end
                return true
        
            end
        end,

        player_connect_full = function(e)
            if client_userid_to_entindex(e.userid) == entity_get_local_player() then 
                local valve_server = entity_get_prop(entity_get_game_rules(), "m_bIsValveDS")
                local game_mode = client_get_cvar("game_mode")
                local game_type = client_get_cvar("game_type")

                if valve_server == 1 then 
                    if cvar.game_type:get_int() == 0 then
                        if cvar.game_mode:get_int() == 0 then -- classic type and casual mode 
                            if ui_get(aimstep) == false then
                                ui_set(aimstep, true)
                            end
                        else
                            if ui_get(ragebot_enabled) == true then
                                ui_set(ragebot_enabled, false)
                            end
                        end
                    elseif cvar.game_type:get_int() == 1 then -- gungame type includes wargames/dm
                        if ui_get(aimstep) == false then
                            ui_set(aimstep, true)
                        end
                    end
                end
            end
        end
    },

    menu = {
        get_steamid = function()
            local local_player = entity_get_local_player()
            local steamid3 = entity_get_steam64(local_player)
            tears.log({text = steamid3})
        end
    },

    -- https://gamesense.pub/forums/viewtopic.php?id=18281 credit goes to x0m
    vote = {
        vote_options = function(e)
			tears.vote.vote_options = {e.option1, e.option2, e.option3, e.option4, e.option5}
			for i = #tears.vote.vote_options, 1, -1 do
				if (tears.vote.vote_options[i] == '') then
					table.remove(tears.vote.vote_options, i)
				end
			end
        end,
        
        vote_cast = function(e)
			client_delay_call(0.3, function()
				local team = e.team
				local base = tears.vote

				if (base.vote_options) then
					local controller
					local voteControllers = entity_get_all('CVoteController')

					for i = 1, #voteControllers do
						if entity_get_prop(voteControllers[i], 'm_iOnlyTeamToVote') == team then
							controller = voteControllers[i]
							break
						end
					end

					if (controller) then
						local ongoing_vote = {
							team = team,
							options = base.vote_options,
							controller = controller,
							issue_index = entity_get_prop(controller, 'm_iActiveIssueIndex'),
							votes = {}
						}

						for i = 1, #tears.vote.vote_options do
							ongoing_vote.votes[base.vote_options[i]] = {}
						end

						ongoing_vote.type = base.indices_noteam[ongoing_vote.issue_index]

						if (team ~= -1 and base.indices_team[ongoing_vote.issue_index]) then
							ongoing_vote.type = base.indices_team[ongoing_vote.issue_index]
						end

						base.ongoing_votes.team = ongoing_vote
					end

					base.vote_options = nil
				end

				local ongoing_vote = base.ongoing_votes.team

				if (ongoing_vote) then
					local player = e.entityid
					local vote_text = ongoing_vote.options[e.vote_option + 1]

					table.insert(ongoing_vote.votes[vote_text], player)

					if (vote_text == 'Yes' and ongoing_vote.caller == nil) then
						ongoing_vote.caller = player

                        if (ongoing_vote.type ~= 'kick') then
							--tears.log({text = string_format("%s %s %s", entity_get_player_name(player) or 'n/a', description = tears.vote.descriptions[ongoing_vote.type], team = e.team)})
						end
					end

					if (ongoing_vote.type == 'kick') then
						if (vote_text == 'No') then
							if (ongoing_vote.target == nil) then
                                ongoing_vote.target = player
                                
                                local steamid3 = entity_get_steam64(player)
                                local is_in_database = false
                                local list = database_read(tears.database.name.steamid)
                                for w in list:gmatch("([^;]+)") do
                                    if w == steamid3 then
                                        is_in_database = true
                                        client_log("in database")
                                        break 
                                    end
                                    client_log("not in database")
                                end 

                                if ui_get(tears.menu.auto_kick) == true then
                                    if is_in_database == true then 
                                        client_exec("vote option2")
                                    else
                                        client_exec("vote option1")
                                    end
                                end
							end
						end
                    end
				end
			end)
        end,
        
        run_command = function(cmd)
			for team, vote in pairs(tears.vote.ongoing_votes) do
				if (entity_get_prop(vote.controller, 'm_iActiveIssueIndex') ~= vote.issue_index) then
					tears.vote.ongoing_votes.team = nil
				end
			end
		end
    },

    match = {
        player_connect_full = function(e)
            if client_userid_to_entindex(e.userid) == entity_get_local_player() then
                local m_totalRoundsPlayed = entity_get_prop(entity_get_game_rules(), "m_totalRoundsPlayed")
                
                tears.match.maxs_round = cvar.mp_maxrounds:get_int()
                tears.match.rounds_to_win = tears.match.maxs_round / 2 + 1
                tears.match.current_round = m_totalRoundsPlayed + 1
                --client_log(tears.match.rounds_to_win)
            end
        end,

        round_start = function()
            local m_totalRoundsPlayed = entity_get_prop(entity_get_game_rules(), "m_totalRoundsPlayed")

            tears.match.current_round = m_totalRoundsPlayed + 1
        end,

        round_freeze_end = function() 
            if ui_get(tears.menu.auto_disconnect_reconnect) == true then 
                local valve_server = entity_get_prop(entity_get_game_rules(), "m_bIsValveDS")
                if valve_server == 1 then
                    local is_warmup_period = entity_get_prop(entity_get_game_rules(), "m_bWarmupPeriod")

                    if is_warmup_period == 0 then
                        local delay = 0.1
                        client_delay_call(delay, client_exec, "disconnect")
                        client_delay_call(delay + ui_get(tears.menu.reconnect_delay), function()
                            if compapi.HasOngoingMatch() then
                                compapi.ActionReconnectToOngoingMatch()
                            end
                        end)
                    end
                end
            end
        end,

        cs_win_panel_match = function()
            if ui_get(tears.menu.disconnect_match_is_over) == true then
                local valve_server = entity_get_prop(entity_get_game_rules(), "m_bIsValveDS")
                if valve_server == 1 then
                    client_delay_call(0.1, client_exec, "disconnect")
                end
            end
        end
    }
    
}
tears.steamid = database_read(tears.database.name.steamid)

client_set_event_callback("paint", tears.callbacks.events.paint)
client_set_event_callback("setup_command", tears.callbacks.events.setup_command)
client_set_event_callback("console_input", tears.callbacks.events.console_input)
client_set_event_callback("player_connect_full", tears.callbacks.events.player_connect_full)

client_set_event_callback("run_command", tears.callbacks.vote.run_command)
client_set_event_callback("vote_options", tears.callbacks.vote.vote_options)
client_set_event_callback("vote_cast", tears.callbacks.vote.vote_cast)

client_set_event_callback("player_connect_full", tears.callbacks.match.player_connect_full)
client_set_event_callback("round_freeze_end", tears.callbacks.match.round_freeze_end)
client_set_event_callback("round_start", tears.callbacks.match.round_start)
client_set_event_callback("cs_win_panel_match", tears.callbacks.match.cs_win_panel_match)

ui_set_callback(tears.menu.get_steamid, tears.callbacks.menu.get_steamid)

ui_set(tears.menu.draw_player_name, true)


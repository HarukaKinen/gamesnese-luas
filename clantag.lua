local steamworks = require "gamesense/steamworks"

if steamworks == nil then
    error("Steamworks is nil, make sure you have subscribed SteamWork SDK from lua workshop")
end

local client_set_clan_tag, client_delay_call, client_log, client_latency, client_set_event_callback = client.set_clan_tag, client.delay_call, client.log, client.latency, client.set_event_callback
local entity_get_local_player, entity_get_prop, entity_get_player_resource = entity.get_local_player, entity.get_prop, entity.get_player_resource
local globals_tickcount, globals_tickinterval = globals.tickcount, globals.tickinterval
local math_floor = math.floor
local ui_get, ui_set_visible, ui_reference, ui_new_checkbox, ui_new_combobox, ui_new_slider, ui_set_callback = ui.get, ui.set_visible, ui.reference, ui.new_checkbox, ui.new_combobox, ui.new_slider, ui.set_callback

local steam_friends = steamworks.ISteamFriends

function string:manipulate(index, character)
    return self:sub(1,index-1)..character..self:sub(index+1,-1)
end

variables = {

    ref_gamesense_clantag = ui_reference("MISC", "Miscellaneous", "Clan tag spammer"),
    clantag_enabled = ui_new_checkbox("MISC", "Miscellaneous", "Custom ClanTag"),
    clantag_type = ui_new_combobox("MISC", "Miscellaneous", "Clantag type", {"Static", "Loop", "Builder"}),
    clantag_update_interval = ui_new_slider("MISC", "Miscellaneous", "Update interval", 1, 20, 10, true, "s", 0.1),
    clantag = "",

    previous_clantag = "",

    builder_characters = {
        "|",
        "/",
        "-",
        "\\"
    },

    clantag_characters = { },

    built_clantag = { },

    initialize_clantag = function(text)
        variables.clantag = text
        variables.clantag_characters = { }

        for c in text:gmatch"." do
            variables.clantag_characters[#variables.clantag_characters + 1] = c
        end

    end,

    initialize_display_text = function()
        variables.built_clantag = { }
        local display_text = "\0"
        for i=1, #variables.clantag_characters - 1 do
            display_text = " "..display_text
        end

        local last_text = display_text
        variables.built_clantag[#variables.built_clantag + 1] = " "
        for i=1, #variables.clantag_characters do
            for j=1, #variables.builder_characters do
                last_text = last_text:manipulate(i, variables.builder_characters[j])
                variables.built_clantag[#variables.built_clantag + 1] =  last_text
            end
            last_text = last_text:manipulate(i, variables.clantag_characters[i])
            variables.built_clantag[#variables.built_clantag + 1] = last_text
        end

        variables.built_clantag[#variables.built_clantag] = variables.clantag

        -- strip the string
        for i=2, #variables.built_clantag do
            variables.built_clantag[i] = variables.built_clantag[i]:gsub("%s+", "")
        end
    end
}

functions = {
    get_original_clantag = function()
        local clan_id = cvar.cl_clanid:get_int()
        if clan_id == 0 then return "\0" end

        local clan_count = steam_friends.GetClanCount()
        for i = 0, clan_count do 
            group_id = steam_friends.GetClanByIndex(i)
            if group_id == clan_id then
                return steam_friends.GetClanTag(group_id)
            end
        end
    end,

    time_to_ticks = function(time)
        return math_floor(time / globals_tickinterval() + 0.5)
    end,

    -- credit goes to @sapphyrus
    gamesense_animation = function(text, indices)
        local text_anim = "               " .. text .. "                      " 
        local tickcount = globals_tickcount() + functions.time_to_ticks(client_latency())
        local i = tickcount / functions.time_to_ticks(0.3)
        i = math_floor(i % #indices)
        i = indices[i+1]+1
    
        return text_anim:sub(i, i+15)
    end,

    builder_animation = function()
        local update_interval = ui_get(variables.clantag_update_interval) / 10
        local tickcount = globals_tickcount() + functions.time_to_ticks(client_latency())
        local i = tickcount / functions.time_to_ticks(update_interval)
        i = math_floor(i % #variables.built_clantag) + 1
        return variables.built_clantag[i]
    end,

    run_clantag_animation = function()
        -- if gamesense clantag spammer is enabled then we dont use our clantag
        if ui_get(variables.ref_gamesense_clantag) then return end

        if not ui_get(variables.clantag_enabled) then return end

        if ui_get(variables.clantag_type) == "Static" then
            local clan_tag = entity_get_prop(entity_get_player_resource(), "m_szClan", entity_get_local_player())
            
            if clan_tag ~= variables.clantag then
                client_set_clan_tag(variables.clantag)
            end

        elseif ui_get(variables.clantag_type) == "Loop" then
            local clan_tag = functions.gamesense_animation(variables.clantag, {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 11, 11, 11, 11, 11, 11, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22})
            
            if clan_tag ~= variables.previous_clantag then
                client_set_clan_tag(clan_tag)
            end

            variables.previous_clantag = clan_tag
        elseif ui_get(variables.clantag_type) == "Builder" then 
            local clan_tag = functions.builder_animation()

            if clan_tag ~= variables.previous_clantag then
                client_set_clan_tag(clan_tag)
            end

            variables.previous_clantag = clan_tag
        end
    end
}

callbacks = {
    paint = function()
        if entity_get_local_player() ~= nil then
            if globals_tickcount() % 2 == 0 then
                functions.run_clantag_animation()
            end
        end
    end,

    run_command = function(e)
        if entity_get_local_player() ~= nil then 
            if e.chokedcommands == 0 then
                functions.run_clantag_animation()
            end
        end
    end,

    console_input = function(text)
        if text:sub(1, #"set_clantag") == "set_clantag" then
            -- in case the clantag has spacebar
            local texts = { }

            for segment in text:gmatch("([^ ]+)") do 
                -- ignore the command
                if segment ~= "set_clantag" then
                    texts[#texts + 1] = segment
                end
            end

            if #texts == 0 then
                client_log("Current clantag: "..variables.clantag)
                return true
            end

            local final_text = ""
            for i = 1, #texts do
                if texts[i] == "\\n" then texts[i] = "\n"
                elseif texts[i] == "\\t" then texts[i] = "\t" 
                end

                if final_text:len() == 0 then 
                    final_text = texts[i]
                else
                    final_text = string.format("%s %s", final_text, texts[i])
                end
            end

            variables.clantag = final_text
            database.write("deadwinter.clantag", final_text)
            variables.initialize_clantag(final_text)
            variables.initialize_display_text()
            client_log("Current clantag: "..variables.clantag)
            return true
        end
    end,
    
    ui_checkbox = function(self)
        if self == variables.clantag_enabled then
            ui_set_visible(variables.clantag_type, ui_get(self))

            if ui_get(variables.clantag_type) == "Builder" then
                ui_set_visible(variables.clantag_update_interval, ui_get(self))
            end

            if not ui_get(self) then 
                local original_clantag = functions.get_original_clantag()
                client_set_clan_tag(original_clantag)
            end

            return
        end

        if self == variables.ref_gamesense_clantag then
            if not ui_get(variables.clantag_enabled) then
                client_delay_call(globals_tickinterval(), function()
                    local original_clantag = functions.get_original_clantag()
                    client_set_clan_tag(original_clantag)
                end)
                return
            end
        end
    end,

    ui_combobox = function(self)
        local is_builder = ui_get(self) == "Builder"
        ui_set_visible(variables.clantag_update_interval, is_builder)
    end,

    shutdown = function()
        local original_clantag = functions.get_original_clantag()
        client_set_clan_tag(original_clantag)
    end
}

variables.initialize_clantag(database.read("deadwinter.clantag") or "set_your_clantag")
variables.initialize_display_text()
client_log("Current clantag: \""..variables.clantag.."\". Example: set_clantag netorare.gang")

ui_set_visible(variables.clantag_type, false)
ui_set_visible(variables.clantag_update_interval, false)
ui_set_callback(variables.clantag_enabled, callbacks.ui_checkbox)
ui_set_callback(variables.ref_gamesense_clantag, callbacks.ui_checkbox)
ui_set_callback(variables.clantag_type, callbacks.ui_combobox)
client_set_event_callback("paint", callbacks.paint)
client_set_event_callback("run_command", callbacks.run_command)
client_set_event_callback("console_input", callbacks.console_input)
client_set_event_callback("shutdown", callbacks.shutdown)
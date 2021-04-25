local steamworks = require "gamesense/steamworks"

function string:manipulate(index, character)
    return self:sub(1,index-1)..character..self:sub(index+1,-1)
end

variables = {
    steam_friends = steamworks.ISteamFriends,

    ref_gamesense_clantag = ui.reference("MISC", "Miscellaneous", "Clan tag spammer"),
    clantag_enabled = ui.new_checkbox("MISC", "Miscellaneous", "Custom ClanTag"),
    clantag_type = ui.new_combobox("MISC", "Miscellaneous", "Clantag type", {"Static", "Loop", "Builder"}),
    clantag_update_interval = ui.new_slider("MISC", "Miscellaneous", "Update interval", 1, 20, 10, true, "s", 0.1),
    clantag = "",

    original_clantag = "",
    previous_clantag = "",

    builder_characters = {
        "|",
        "/",
        "-",
        "\\"
    },

    clantag_characters = { },

    display_text = "",

    text_count = 1,
    builder_count = 1,

    next_tickcount_to_change = 0,

    initialize_clantag = function(text)
        variables.clantag = text
        variables.clantag_characters = { }
        variables.display_text = "\0"
        variables.text_count = 1
        variables.builder_count = 0
        variables.next_tickcount_to_change = 0

        for c in text:gmatch"." do
            table.insert(variables.clantag_characters, c)
        end

        for i=1, #text - 1 do
            variables.display_text = " "..variables.display_text
        end
    end

}

functions = {
    get_original_clantag = function()
        local clan_id = cvar.cl_clanid:get_int()
        if clan_id == 0 then return "\0" end

        local clan_count = variables.steam_friends.GetClanCount()
        for i = 0, clan_count do 
            group_id = variables.steam_friends.GetClanByIndex(i)
            if group_id == clan_id then
                return variables.steam_friends.GetClanTag(group_id)
            end
        end
    end,

    time_to_ticks = function(time)
        return math.floor(time / globals.tickinterval() + 0.5)
    end,

    -- credit goes to @sapphyrus
    gamesense_animation = function(text, indices)
        local text_anim = "               " .. text .. "                      " 
        local tickinterval = globals.tickinterval()
        local tickcount = globals.tickcount() + functions.time_to_ticks(client.latency())
        local i = tickcount / functions.time_to_ticks(0.3)
        i = math.floor(i % #indices)
        i = indices[i+1]+1
    
        return string.sub(text_anim, i, i+15)
    end,

    builder_animation = function()
        local final_text = variables.display_text
        --print(variables.builder_count.." | "..#variables.builder_characters.." | "..variables.text_count.." | "..#variables.clantag_characters)
        if variables.text_count <= #variables.clantag_characters then
            if variables.builder_count < #variables.builder_characters then
                variables.builder_count = variables.builder_count + 1
                variables.display_text = final_text:manipulate(variables.text_count, variables.builder_characters[variables.builder_count])
            else
                variables.builder_count = 0
                variables.display_text = final_text:manipulate(variables.text_count, variables.clantag_characters[variables.text_count])
                variables.text_count = variables.text_count + 1
            end
        else
            variables.text_count = 1
            variables.display_text = "\0"
            for i=1, #variables.clantag - 1 do
                variables.display_text = " "..variables.display_text
            end
        end
    end,

    run_clantag_animation = function()
        -- if gamesense clantag spammer is enabled then we dont use our clantag
        if ui.get(variables.ref_gamesense_clantag) then return end

        if not ui.get(variables.clantag_enabled) then return end

        if ui.get(variables.clantag_type) == "Static" then
            local clantag = entity.get_prop(entity.get_player_resource(), "m_szClan", entity.get_local_player())
            
            if clantag ~= variables.clantag then
                client.set_clan_tag(variables.clantag)
            end

        elseif ui.get(variables.clantag_type) == "Loop" then
            local clan_tag = functions.gamesense_animation(variables.clantag, {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 11, 11, 11, 11, 11, 11, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22})
            
            if clan_tag ~= variables.previous_clantag then
                client.set_clan_tag(clan_tag)
            end

            variables.previous_clantag = clan_tag
        elseif ui.get(variables.clantag_type) == "Builder" then 
            
            if globals.tickcount() >= variables.next_tickcount_to_change then
                functions.builder_animation()
                client.set_clan_tag(variables.display_text)
                local update_interval = ui.get(variables.clantag_update_interval) / 10
                variables.next_tickcount_to_change = globals.tickcount() + functions.time_to_ticks(update_interval)
            end

        end

    end
}

callbacks = {
    paint = function()
        if entity.get_local_player() ~= nil then
            if globals.tickcount() % 2 == 0 then
                functions.run_clantag_animation()
            end
        end
    end,

    run_command = function(e)
        if entity.get_local_player() ~= nil then 
            if e.chokedcommands == 0 then
                functions.run_clantag_animation()
            end
        end
    end,

    player_connect_full = function(e)
        if client.userid_to_entindex(e.userid) == entity.get_local_player() then 
            variables.original_clantag = functions.get_original_clantag()
        end
    end,

    console_input = function(text)
        if string.sub(text, 1, #"set_clantag") == "set_clantag" then
            -- in case the clantag has spacebar
            local texts = { }

            for segment in string.gmatch(text, "([^ ]+)") do 
                -- ignore the command
                if segment ~= "set_clantag" then
                    table.insert(texts, segment)
                end
            end

            if #texts == 0 then
                client.log("Current clantag: "..variables.clantag)
                return true
            end

            local final_text = ""
            for i = 1, #texts do
                if texts[i] == "\\n" then texts[i] = "\n"
                elseif texts[i] == "\\t" then texts[i] = "\t" 
                end

                if string.len(final_text) == 0 then 
                    final_text = texts[i]
                else
                    final_text = string.format("%s %s", final_text, texts[i])
                end
            end

            variables.clantag = final_text
            database.write("deadwinter.clantag", final_text)
            variables.initialize_clantag(final_text)
            client.log("Current clantag: "..variables.clantag)
            return true
        end
    end,
    
    ui_checkbox = function(self)
        if self == variables.clantag_enabled then
            ui.set_visible(variables.clantag_type, ui.get(self))
            if not ui.get(self) then 
                client.set_clan_tag(variables.original_clantag)
                return
            end
        end

        if self == variables.ref_gamesense_clantag then
            if not ui.get(variables.clantag_enabled) then
                client.delay_call(globals.tickinterval(), function()
                    client.set_clan_tag(variables.original_clantag)
                end)
                return
            end
        end
    end,

    ui_combobox = function(self)
        local is_builder = ui.get(self) == "Builder"
        ui.set_visible(variables.clantag_update_interval, is_builder)
    end,

    shutdown = function()
        client.set_clan_tag(functions.get_original_clantag())
    end
}

variables.original_clantag = functions.get_original_clantag()
variables.initialize_clantag(database.read("deadwinter.clantag") or "set_your_clantag")
client.log("Current clantag: \""..variables.clantag.."\". Example: set_clantag netorare.gang")

ui.set_visible(variables.clantag_type, false)
ui.set_visible(variables.clantag_update_interval, false)
ui.set_callback(variables.clantag_enabled, callbacks.ui_checkbox)
ui.set_callback(variables.ref_gamesense_clantag, callbacks.ui_checkbox)
ui.set_callback(variables.clantag_type, callbacks.ui_combobox)
client.set_event_callback("paint", callbacks.paint)
client.set_event_callback("run_command", callbacks.run_command)
client.set_event_callback("player_connect_full", callbacks.player_connect_full)
client.set_event_callback("console_input", callbacks.console_input)
client.set_event_callback("shutdown", callbacks.shutdown)
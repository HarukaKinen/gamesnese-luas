local globals_realtime = globals.realtime
local globals_curtime = globals.curtime
local globals_frametime = globals.frametime
local globals_absolute_frametime = globals.absoluteframetime
local globals_maxplayers = globals.maxplayers
local globals_tickcount = globals.tickcount
local globals_tickinterval = globals.tickinterval
local globals_mapname = globals.mapname
 
local client_set_event_callback = client.set_event_callback
local client_console_log = client.log
local client_color_log = client.color_log
local client_console_cmd = client.exec
local client_userid_to_entindex = client.userid_to_entindex
local client_get_cvar = client.get_cvar
local client_set_cvar = client.set_cvar
local client_draw_debug_text = client.draw_debug_text
local client_draw_hitboxes = client.draw_hitboxes
local client_draw_indicator = client.draw_indicator
local client_random_int = client.random_int
local client_random_float = client.random_float
local client_draw_text = client.draw_text
local client_draw_rectangle = client.draw_rectangle
local client_draw_line = client.draw_line
local client_draw_gradient = client.draw_gradient
local client_draw_cricle = client.draw_circle
local client_draw_circle_outline = client.draW_circle_outline
local client_world_to_screen = client.world_to_screen
local client_screen_size = client.screen_size
local client_visible = client.visible
local client_delay_call = client.delay_call
local client_latency = client.latency
local client_camera_angles = client.camera_angles
local client_trace_line = client.trace_line
local client_eye_position = client.eye_position
local client_set_clan_tag = client.set_clan_tag
local client_system_time = client.system_time
 
local entity_get_local_player = entity.get_local_player
local entity_get_all = entity.get_all
local entity_get_players = entity.get_players
local entity_get_classname = entity.get_classname
local entity_set_prop = entity.set_prop
local entity_get_prop = entity.get_prop
local entity_is_enemy = entity.is_enemy
local entity_get_player_name = entity.get_player_name
local entity_get_player_weapon = entity.get_player_weapon
local entity_hitbox_position = entity.hitbox_position
local entity_get_steam64 = entity.get_steam64
local entity_get_bounding_box = entity.get_bounding_box
local entity_is_alive = entity.is_alive
local entity_is_dormant = entity.is_dormant
local entity_get_game_rules = entity.get_game_rules 
local entity_get_player_resource = entity.get_player_resource

local ui_new_checkbox = ui.new_checkbox
local ui_new_slider = ui.new_slider
local ui_new_combobox = ui.new_combobox
local ui_new_multiselect = ui.new_multiselect
local ui_new_hotkey = ui.new_hotkey
local ui_new_button = ui.new_button
local ui_new_color_picker = ui.new_color_picker
local ui_reference = ui.reference
local ui_set = ui.set
local ui_new_textbox = ui.new_textbox
local ui_get = ui.get
local ui_set_callback = ui.set_callback
local ui_set_visible = ui.set_visible
local ui_is_menu_open = ui.is_menu_open
 
local math_floor = math.floor
local math_random = math.random
local math_sqrt = math.sqrt
local table_insert = table.insert
local table_remove = table.remove
local table_size = table.getn
local table_sort = table.sort
local string_format = string.format
local string_length = string.len
local string_reverse = string.reverse
local string_sub = string.sub

local ffi = require("ffi")
ffi.cdef[[
typedef void***(__thiscall* FindHudElement_t)(void*, const char*);
typedef void(__cdecl* ChatPrintf_t)(void*, int, int, const char*, ...);
]]

local signature_gHud = "\xB9\xCC\xCC\xCC\xCC\x88\x46\x09"
local signature_FindElement = "\x55\x8B\xEC\x53\x8B\x5D\x08\x56\x57\x8B\xF9\x33\xF6\x39\x77\x28"

local match = client.find_signature("client_panorama.dll", signature_gHud) or error("sig1 not found")
local hud = ffi.cast("void**", ffi.cast("char*", match) + 1)[0] or error("hud is nil")

match = client.find_signature("client_panorama.dll", signature_FindElement) or error("FindHudElement not found")
local find_hud_element = ffi.cast("FindHudElement_t", match)
local hudchat = find_hud_element(hud, "CHudChat") or error("CHudChat not found")

local chudchat_vtbl = hudchat[0] or error("CHudChat instance vtable is nil")
local print_to_chat = ffi.cast("ChatPrintf_t", chudchat_vtbl[27])

--[[
\x01 - white
\x02 - red
\x03 - purple
\x04 - green
\x05 - yellow green
\x06 - light green
\x07 - light red
\x08 - gray
\x09 - light yellow
\x0A - gray
\x0C - dark blue
\x10 - gold
]]
local function print_chat(text)
	print_to_chat(hudchat, 0, 0, text)
end

------------ team damage & team kiils ------------

local damage = 0
local kills = 0
local function player_hurt(e)
    if client_userid_to_entindex(e.attacker) == entity_get_local_player() and client_userid_to_entindex(e.userid) ~= entity_get_local_player() and not entity_is_enemy(client_userid_to_entindex(e.userid)) then
        damage = damage + e.dmg_health
        print_chat("\x01[ \x06tears \x01] Damage to your teammates: \x02"..damage.."\x01/300  Killed teammates: \x02"..kills.."\x01/3")
    end
end

local function player_death(e)
    if client_userid_to_entindex(e.attacker) == entity_get_local_player() and client_userid_to_entindex(e.userid) ~= entity_get_local_player() and not entity_is_enemy(client_userid_to_entindex(e.userid))  then
        kills = kills + 1
        print_chat("\x01[ \x06tears \x01] Damage to your teammates: \x02"..damage.."\x01/300  Killed teammates: \x02"..kills.."\x01/3")
	end
end

local function player_connect_full(e)
-- reset damage and kills also we need to turn aimstep on if we are in a valve casual/wargames/dm server
    local valve_server = entity_get_prop(entity_get_game_rules(), "m_bIsValveDS")
    local game_mode = client_get_cvar("game_mode")
    local game_type = client_get_cvar("game_type")
    local aimstep = ui_reference("RAGE", "Aimbot", "Reduce aim step")


    if valve_server == 1 then 
        if cvar.game_type:get_int() == 0 and cvar.game_mode:get_int() == 0 then -- classic type and casual mode 
            ui_set(aimstep, true)
        elseif cvar.game_type:get_int() == 1 then -- gungame type includes wargames/dm
            ui_set(aimstep, true)
        end
    else 
        ui_set(aimstep, false)
    end

    if client_userid_to_entindex(e.userid) == entity_get_local_player() then
        damage = 0
        kills = 0
    end
end

local function on_paint()
    local valve_server = entity_get_prop(entity_get_game_rules(), "m_bIsValveDS")
    local game_mode = client_get_cvar("game_mode")
    local game_type = client_get_cvar("game_type")

    if valve_server == 1 then 
        if cvar.game_type:get_int() == 0 then 
            if not cvar.game_mode:get_int() == 0 then
                renderer.text(2, 200, 255,255,255,255, "b+", 0, "Damage: ", damage)
                renderer.text(2, 230, 255,255,255,255, "b+", 0, "Kills: ", kills)
            end
        end
    end

end

client.set_event_callback("player_hurt", player_hurt)
client.set_event_callback("player_death", player_death)
client.set_event_callback("player_connect_full", player_connect_full)
client.set_event_callback("paint", on_paint)

-----------------------------------------------------------------------

local disable_aa_on_round_end = ui.new_checkbox("aa", "Anti-aimbot angles", "Disable anti aim on round end")
local aa_enabled_reference = ui.reference("aa", "Anti-aimbot angles", "enabled")

local function handle_round_start(e)
	if ui_get(disable_aa_on_round_end) then -- Enable aa
		ui_set(aa_enabled_reference, true)
	end
end 

local function handle_round_end(e)
	if ui_get(disable_aa_on_round_end) then -- Disable aa
		ui_set(aa_enabled_reference, false)
	end
end

client.set_event_callback("round_start", handle_round_start)
client.set_event_callback("round_end", handle_round_end)

i = 0

------------------------------------------------------------------------
local function on_setup_command(cmd)

    local game_mode = client_get_cvar("game_mode")
    local game_type = client_get_cvar("game_type")
    local is_immunity = entity_get_prop(entity_get_local_player(), "m_bGunGameImmunity")

    if  entity_is_alive(entity_get_local_player()) and i % 3 == 0 and cvar.game_mode:get_int() == 2 and cvar.game_type:get_int() == 1 and is_immunity == 1 then
        client_console_cmd("open_buymenu")
        i = 0
    end
    i = i + 1
end

client.set_event_callback('setup_command', on_setup_command)
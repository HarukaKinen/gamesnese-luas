local vector = require "vector"
local ffi = require "ffi"

ffi.cdef[[
    typedef struct 
    {
    	void*   fnHandle;        
    	char    szName[260];     
    	int     nLoadFlags;      
    	int     nServerCount;    
    	int     type;            
    	int     flags;           
    	float  vecMins[3];       
    	float  vecMaxs[3];       
    	float   radius;          
    	char    pad[0x1C];       
    }model_t;
    
	typedef void(__thiscall* slv_create_follow_beam_t)(void*, int start_ent, int model_index, int halo_index, float halo_scale, float life, float width, float end_width, float fade_length, float r, float g, float b, float brightness);
    typedef int(__thiscall* get_model_index_t)(void*, const char*);
    typedef const model_t(__thiscall* find_or_load_model_t)(void*, const char*);
    typedef void*(__thiscall* find_table_t)(void*, const char*);
    typedef int(__thiscall* add_string_t)(void*, bool, const char*, int, const void*);
    typedef int(__thiscall* precache_model_t)(void*, const char*, bool);
]]

local render_beams_signature = "\xB9\xCC\xCC\xCC\xCC\xA1\xCC\xCC\xCC\xCC\xFF\x10\xA1\xCC\xCC\xCC\xCC\xB9"
local match = client.find_signature("client_panorama.dll", render_beams_signature) or error("render_beams_signature not found")
local render_beams = ffi.cast('void**', ffi.cast("char*", match) + 1)[0] or error("render_beams is nil") 
local render_beams_class = ffi.cast("void***", render_beams)
local render_beams_vtbl = render_beams_class[0]
local create_follow_beam = ffi.cast("slv_create_follow_beam_t", render_beams_vtbl[19]) or error("couldn't cast slv_create_follow_beam_t", 2)

local rawivmodelinfo = client.create_interface("engine.dll", "VModelInfoClient004") or error("VModelInfoClient004 wasnt found", 2)
local ivmodelinfo = ffi.cast(ffi.typeof("void***"), rawivmodelinfo) or error("rawivmodelinfo is nil", 2)
local get_model_index = ffi.cast("get_model_index_t", ivmodelinfo[0][2]) or error("get_model_info is nil", 2)
local find_or_load_model = ffi.cast("find_or_load_model_t", ivmodelinfo[0][39]) or error("find_or_load_model is nil", 2)

local rawnetworkstringtablecontainer = client.create_interface("engine.dll", "VEngineClientStringTable001") or error("VEngineClientStringTable001 wasnt found", 2)
local networkstringtablecontainer = ffi.cast(ffi.typeof("void***"), rawnetworkstringtablecontainer) or error("rawnetworkstringtablecontainer is nil", 2)
local find_table = ffi.cast("find_table_t", networkstringtablecontainer[0][3]) or error("find_table is nil", 2)

local function create_beam(ent_index, model_index, life_time, width, r, g, b, a)
    create_follow_beam(render_beams, ent_index, model_index, 0, 0, life_time, width, width, 0, r, g, b, a)
end

local last_speed = 0

local draw_trails = ui.new_checkbox("VISUALS", "Effects", "Draw player trails")
local trails_color = ui.new_color_picker("VISUALS", "Effects", "Color", 255, 255, 255, 255)
local trails_lifetime = ui.new_slider("VISUALS", "Effects", "Life time", 1, 50, 10, true, nil, 0.1)
local trails_width = ui.new_slider("VISUALS", "Effects", "Width", 1, 50, 10, true, nil, 0.1)
local unk = ui.new_label("VISUALS", "Effects", "Texture name for trails")
local trails_name = ui.new_textbox("VISUALS", "Effects", "name")

local anti_aim_enabled = ui.reference("aa", "Anti-aimbot angles", "Enabled")

local function menu_handler()
    ui.set_visible(trails_color, ui.get(draw_trails))
    ui.set_visible(trails_lifetime, ui.get(draw_trails))
    ui.set_visible(trails_width, ui.get(draw_trails))
    ui.set_visible(unk, ui.get(draw_trails))
    ui.set_visible(trails_name, ui.get(draw_trails))
end

menu_handler()
ui.set_callback(draw_trails, menu_handler)
ui.set(trails_name, "sprites/physbeam.vmt")

local function precache_model(modelname)
    local rawprecache_table = find_table(networkstringtablecontainer, "modelprecache") or error("couldnt find modelprecache", 2)
    if rawprecache_table then 
        local precache_table = ffi.cast(ffi.typeof("void***"), rawprecache_table) or error("couldnt cast precache_table", 2)
        if precache_table then 
            local add_string = ffi.cast("add_string_t", precache_table[0][8]) or error("add_string is nil", 2)

            find_or_load_model(ivmodelinfo, modelname)
            local idx = add_string(precache_table, false, modelname, -1, nil)
            if idx == -1 then 
                return false
            end
        end
    end
    return true
end

local function on_setup_command(cmd)
    local local_player = entity.get_local_player()
    if local_player ~= nil and entity.is_alive(local_player) and ui.get(draw_trails) == true then 

        -- if player doesn't move then the follow beam will get killed
        -- so we need to recreate a follow beam when player moves

        local speed = vector(entity.get_prop(local_player, "m_vecVelocity")):length2d()
        
        local check_speed = 0.000001

        if ui.get(anti_aim_enabled) == true then 
            check_speed = 1.011 -- just in case
        end

        if last_speed < check_speed and speed > check_speed then 
            if ui.get(draw_trails) == true then

                local name = ui.get(trails_name)
                if string.match(name, ".vmt") then

                    local model_index = get_model_index(ivmodelinfo, name)
                    if model_index == -1 then 
                        if precache_model(name) == false then 
                            error("failed to precache model")
                        end
                    end

                    local lifetime = ui.get(trails_lifetime) / 10
                    local width = ui.get(trails_width) / 10
                    local r,g,b,a = ui.get(trails_color)

                    create_beam(local_player, model_index, lifetime, width, r, g, b, a)
                end

            end
        end

        last_speed = speed 

    end
end

local function on_player_death(e)
    local userid = e.userid
    if client.userid_to_entindex(userid) == entity.get_local_player() then 
        last_speed = 0
    end
end

client.set_event_callback("player_death", on_player_death)
client.set_event_callback("setup_command", on_setup_command)
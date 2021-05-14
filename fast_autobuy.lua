local ffi = require("ffi")

local server_frame = ffi.new("float[1]")
local server_dev_frame = ffi.new("float[1]")
local server_dev_start_frame = ffi.new("float[1]")

local interface_ptr = ffi.typeof('void***')
local net_fr_to = ffi.typeof("void(__thiscall*)(void*, float*, float*, float*)")
local netc_float = ffi.typeof("float(__thiscall*)(void*, int)")

local rawivengineclient = client.create_interface("engine.dll", "VEngineClient014") or error("VEngineClient014 wasnt found", 2)
local ivengineclient = ffi.cast(interface_ptr, rawivengineclient) or error("rawivengineclient is nil", 2)
local get_net_channel_info = ffi.cast("void*(__thiscall*)(void*)", ivengineclient[0][78]) or error("ivengineclient is nil")

local bought = false
local wait_time = 0

local weapon_to_buy = ui.new_combobox("MISC", "Miscellaneous", "Auto buy", {"-", "Auto", "AWP", "Scout"})

local main_weapon = {
    ["Auto"] = {
        "buy scar20;",
        5650
    },
    ["AWP"] = {
        "buy awp;",
        5400
    },
    ["Scout"] = {
        "buy ssg08;",
        2350
    }
}

local GetNetFramerate = function(net_channel_info)
    if net_channel_info == nil then
        return 0, 0
    end

    ffi.cast(net_fr_to, net_channel_info[0][25])(net_channel_info, server_frame, server_dev_frame, server_dev_start_frame)

    if server_frame ~= nil and server_dev_frame ~= nil and server_dev_start_frame ~= nil then
        if server_frame[0] > 0 then
            return server_frame[0], server_dev_frame[0]
        end
    end
end

local GetLatency = function(net_channel_info)
    if net_channel_info == nil then return 0 end

    return ffi.cast(netc_float, net_channel_info[0][10])(net_channel_info, 0)
end

function buy_weapon() 
    local weapon_name = ui.get(weapon_to_buy)
    if weapon_name == "-" then return end
    local command = main_weapon[weapon_name][1]
    local money = main_weapon[weapon_name][2]
    
    if entity.get_prop(entity.get_local_player(), "m_iAccount") >= money then
        client.exec(command)
    else
        print("you dont enough money to buy "..weapon_name)
    end
end

function time_to_ticks(time)
    return math.floor(time / globals.tickinterval() + 0.5)
end

client.set_event_callback("paint", function()
    local net_chan = ffi.cast("void***", get_net_channel_info(engine_client)) or error("netchaninfo is nil")
    local server_frame, server_dev_frame = GetNetFramerate(net_chan)
    local latency = GetLatency(net_chan)

    if not bought and wait_time - time_to_ticks(latency) <= globals.tickcount() then
        buy_weapon()
        client.delay_call(server_frame * 10, buy_weapon)
        client.delay_call(0.01, buy_weapon)
        client.delay_call(0.05, buy_weapon)
        client.delay_call(0.1, buy_weapon)
        bought = true
    end
end)

client.set_event_callback("round_end", function()
	wait_time = globals.tickcount() + time_to_ticks(cvar.mp_round_restart_delay:get_float())
	bought = false
end)

client.set_event_callback("round_prestart", function()
    if not bought then
        buy_weapon()
        client.delay_call(0.01, buy_weapon)
        client.delay_call(0.05, buy_weapon)
        client.delay_call(0.1, buy_weapon)
        bought = true
    end
end)
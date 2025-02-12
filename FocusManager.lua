-- FocusManager addon 

--   - Draws a border around the FFXI window (yellow when in focus, grey when out-of-focus).
--   - Automatically sends /mutebgm commands on focus change:
--         * When losing focus: sends "input /mutebgm on"
--         * When gaining focus: sends "input /mutebgm off" and "send @others input /mutebgm on" (requires send addon)

--	COMMANDS:
--         fm border on/off 
--         fm bgm on/off

_addon.name    = 'FocusManager'
_addon.author  = 'Kainminter'
_addon.version = '1.0'
_addon.commands = {'focusmanager', 'fm'}

-- Settings
local border_enabled = true
local bgm_enabled    = true
local border_thickness = 3

local current_focus = windower.has_focus()

-- Create borders
windower.prim.create('top_border')
windower.prim.create('bottom_border')
windower.prim.create('left_border')
windower.prim.create('right_border')

local function update_border_positions()
    local settings = windower.get_windower_settings()
    local window_width  = settings.ui_x_res
    local window_height = settings.ui_y_res

    windower.prim.set_position('top_border', 0, 0)
    windower.prim.set_size('top_border', window_width, border_thickness)

    windower.prim.set_position('bottom_border', 0, window_height - border_thickness)
    windower.prim.set_size('bottom_border', window_width, border_thickness)

    windower.prim.set_position('left_border', 0, 0)
    windower.prim.set_size('left_border', border_thickness, window_height)

    windower.prim.set_position('right_border', window_width - border_thickness, 0)
    windower.prim.set_size('right_border', border_thickness, window_height)
end


local function update_border_color()
    if border_enabled then
        windower.prim.set_visibility('top_border', true)
        windower.prim.set_visibility('bottom_border', true)
        windower.prim.set_visibility('left_border', true)
        windower.prim.set_visibility('right_border', true)

        local color = current_focus and {200, 255, 255, 0} or {200, 128, 128, 128} -- Yellow if focused, Grey if unfocused
        for _, border in pairs({'top_border', 'bottom_border', 'left_border', 'right_border'}) do
            windower.prim.set_color(border, color[1], color[2], color[3], color[4])
        end
    else
        -- Hide borders if disabled
        for _, border in pairs({'top_border', 'bottom_border', 'left_border', 'right_border'}) do
            windower.prim.set_visibility(border, false)
        end
    end
end


windower.register_event('prerender', function()
    local focus = windower.has_focus()
    if focus ~= current_focus then
        current_focus = focus
        update_border_color()
        if bgm_enabled then
            if current_focus then

                windower.send_command('input /mutebgm off')
                windower.send_command('send @others input /mutebgm on')
            else

                windower.send_command('input /mutebgm on')
            end
        end
    end
end)


windower.register_event('addon command', function(command, ...)
    local args = {...}
    command = command and command:lower() or ''

    if command == 'border' then
        if args[1] and args[1]:lower() == 'on' then
            border_enabled = true
            update_border_positions()
            update_border_color()
            windower.add_to_chat(123, 'FocusManager: Border enabled.')
        elseif args[1] and args[1]:lower() == 'off' then
            border_enabled = false
            update_border_color()
            windower.add_to_chat(123, 'FocusManager: Border disabled.')
        else
            windower.add_to_chat(123, 'Usage: fm border on/off')
        end
    elseif command == 'bgm' then
        if args[1] and args[1]:lower() == 'on' then
            bgm_enabled = true
            windower.add_to_chat(123, 'FocusManager: BGM control enabled.')
        elseif args[1] and args[1]:lower() == 'off' then
            bgm_enabled = false
            windower.add_to_chat(123, 'FocusManager: BGM control disabled.')
        else
            windower.add_to_chat(123, 'Usage: fm bgm on/off')
        end
    else
        windower.add_to_chat(123, 'FocusManager commands:')
        windower.add_to_chat(123, '  fm border on/off')
        windower.add_to_chat(123, '  fm bgm on/off')
    end
end)


update_border_positions()
update_border_color()

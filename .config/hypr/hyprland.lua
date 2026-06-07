dofile("/home/bob/.config/hypr/monitors.lua")


---- enviroment vars ----
-- xdg desktop --
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_CONFIG_HOME", "/home/bob/.config")
hl.env("GTK_USE_PORTAL", "1")
hl.env("XDG_DESKTOP_PORTAL", "1")

-- cursor --
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "breeze_cursors")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "hyprcursor_Dracula")

-- wayland as default --
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
-- env = SDL_VIDEODRIVER,wayland # causes issues

-- qt tweaks --
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QUICK_CONTROLS_STYLE", "org.kde.desktop")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

-- keyboard --
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("QT_IM_MODULES", "wayland;fcitx;ibus")
hl.env("SDL_IM_MODULE", "fcitx")
hl.env("GTK_IM_MODULE", "fcitx")

---- start all apps ----

---@param m HL.Monitor
local function open_glpaper(m)
    hl.exec_cmd("glpaper " .. m.name .. " ~/.config/hypr/sky.frag --fps 5 -F")
end

---@param m HL.Monitor
local function close_glpaper(m)
    hl.exec_cmd("pkill -f \"glpaper " .. m.name .. "\"")
end

function hl_lock()
    hl.exec_cmd("pkill -9 waybar")
    for _, window in ipairs(hl.get_windows()) do
        hl.dispatch(hl.dsp.window.tag({ tag = "gone", window = window }))
    end
    hl.config({ group = { groupbar = { enabled = false } } })
    hl.exec_cmd("swaync-client -Ia locked")
    hl.exec_cmd("hyprlock --no-fade-in && hyprctl eval \"hl_unlock()\"")
end

function hl_unlock()
    for _, window in ipairs(hl.get_windows()) do
        hl.dispatch(hl.dsp.window.tag({ tag = "-gone", window = window }))
    end
    hl.config({ group = { groupbar = { enabled = true } } })
    hl.exec_cmd("swaync-client -Ir locked")
    hl.exec_cmd("waybar")
end

hl.on("hyprland.start", function()
    -- lock on start --
    hl_lock()

    -- start essential programs --
    hl.exec_cmd("swaync")
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd("playerctld daemon")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("ydotoold")
    hl.exec_cmd("nwg-drawer -r ")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("bluetoothctl power off")
    hl.exec_cmd("openrgb -p on")
    hl.exec_cmd("tailscale-systray")
    hl.exec_cmd("anyrun daemon")

    -- wallpaper --
    for _, m in ipairs(hl.get_monitors()) do
        open_glpaper(m)
    end

    -- cursor --
    hl.exec_cmd("hyprctl setcursor hyprcursor_Dracula 24")
    hl.exec_cmd("xsetroot -cursor_name left_ptr") -- this is needed to make xcursor work
end)

hl.on("monitor.added", function(m)
    local gamemodeEnabled = not hl.get_config("animations.enabled")
    if not gamemodeEnabled then
        open_glpaper(m)
    end
end)

hl.on("monitor.removed", function(m)
    close_glpaper(m)
end)

-- floating popups --

---@param win HL.Window
---@param matchTag string
local function hasTag(win, matchTag)
    local matchedTag = false
    local tags = win.tags
    if type(tags) == "string" then
        for tag in tags:gmatch('[^ ]+') do
            if tag == matchTag then
                matchedTag = true
                break
            end
        end
    elseif type(tags) == "table" then
        for _, tag in ipairs(tags) do
            if tag == matchTag then
                matchedTag = true
                break
            end
        end
    end
    return matchedTag
end

local popupTarget = { W = 500, H = 500, X = 0, Y = 0 }

local function resizePopup(win)
    hl.timer(function()
        hl.dispatch(hl.dsp.window.resize({ window = win, x = popupTarget.W, y = popupTarget.H }))
        hl.dispatch(hl.dsp.window.move({ window = win, x = popupTarget.X, y = popupTarget.Y }))
    end, { timeout = 50, type = "oneshot" }):set_enabled(true)
end

---@param win HL.Window
hl.on("window.active", function(win)
    if hasTag(win, "float-popup*") then
        resizePopup(win)
    else
        if win.size == nil or win.at == nil then
            return
        end

        popupTarget.W = win.size.x / 2
        popupTarget.H = win.size.y / 2
        popupTarget.X = win.at.x + popupTarget.W / 2
        popupTarget.Y = win.at.y + popupTarget.H / 2
    end
end)

hl.on("window.open", function(win)
    if hasTag(win, "float-popup*") then
        resizePopup(win)
    end
end)

hl.config({
    debug = {
        disable_logs = false,
        full_cm_proto = true
    },

    cursor = {
        zoom_factor = 1.0,
        zoom_detached_camera = false
    },

    input = {
        kb_layout = "us",
        kb_options = "compose:caps",

        touchpad = {
            natural_scroll = false,
            disable_while_typing = false,
            clickfinger_behavior = true
        },
    },

    general = {
        gaps_in = 5,
        gaps_out = 8,
        border_size = 2,
        ["col.active_border"] = "#a07cb4ff",
        ["col.inactive_border"] = "#595959aa",

        layout = "dwindle",

        resize_on_border = true,
        allow_tearing = true,
    },

    decoration = {
        rounding = 5,

        shadow = {
            enabled = false,
        },

        blur = {
            enabled = false,
        },

        dim_special = 0,
    },

    gestures = {
        -- workspace_swipe = true
        workspace_swipe_forever = true,
    },

    dwindle = {
        preserve_split = true
    },

    group = {
        ["col.border_active"] = "#a07cb4ff",
        ["col.border_inactive"] = "#595959aa",

        groupbar = {
            gradients = true,

            ["col.active"] = "#a07cb4ff",
            ["col.inactive"] = "#595959aa",
        },
    },

    xwayland = {
        force_zero_scaling = true
    },

    render = {
        direct_scanout = 2
    },

    misc = {
        key_press_enables_dpms = true,
        mouse_move_enables_dpms = true,

        -- locking
        session_lock_xray = true,

        enable_swallow = true,
        swallow_regex = "^(kitty)$",

        -- background tweaks
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        background_color = "#360A62"
    },

    quirks = {
        prefer_hdr = 1
    }
})


hl.curve("my_bezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "my_bezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })
hl.animation({ leaf = "specialWorkspace", enabled = false })

---- controls ----
-- general --
hl.bind("SUPER + W", hl.dsp.window.close())
hl.bind("ALT + space", hl.dsp.exec_cmd("/home/bob/.cargo/bin/anyrun"))
hl.bind("SUPER + space", hl.dsp.exec_cmd("nwg-drawer"))
hl.bind("SUPER + F", hl.dsp.window.float())
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + G", hl.dsp.group.toggle())
hl.bind("SUPER + SHIFT+ G", hl.dsp.window.move({ out_of_group = true }))
hl.bind("SUPER + P", hl.dsp.window.pin())
hl.bind("SUPER + home", function()
    local enabled = hl.get_config("animations.enabled")

    if enabled then
        hl.config({
            animations = {
                enabled = false
            },
            decoration = {
                rounding = 0,
            },
            general = {
                gaps_out = 0,
                border_size = 0
            },
            input = {
                follow_mouse = 0
            }
        })
        hl.exec_cmd("pkill -9 waybar")
        for _, m in ipairs(hl.get_monitors()) do
            close_glpaper(m)
        end
    else
        hl.config({
            animations = {
                enabled = true
            },
            decoration = {
                rounding = 5,
            },
            general = {
                gaps_out = 8,
                border_size = 2
            },
            input = {
                follow_mouse = 1
            }
        })
        hl.exec_cmd("waybar")
        for _, m in ipairs(hl.get_monitors()) do
            open_glpaper(m)
        end
    end
end)
hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd("nwg-displays"))

-- screenshot --
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("grimblast copysave area"))
hl.bind("SUPER + Print", hl.dsp.exec_cmd("grimblast copysave active"))

-- locking --
hl.bind("SUPER + L", function()
    hl_lock()
end)

-- media --
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

-- volume / mute --
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"))

-- brightness --
hl.bind("XF86MonBrightnessDown", function()
    hl.exec_cmd("swayosd-client --brightness lower")
    hl.exec_cmd("ddcutil --bus 1 setvcp 10 - 10 --sleep-multiplier .2")
end)
hl.bind("XF86MonBrightnessUp", function()
    hl.exec_cmd("swayosd-client --brightness raise")
    hl.exec_cmd("ddcutil --bus 1 setvcp 10 + 10 --sleep-multiplier .2")
end)

-- ignore bluetooth key --
-- hl.bind("XF86Bluetooth", function() end)

-- move/resize windows --
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + Control_L", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("SUPER + Alt_L", hl.dsp.window.resize(), { mouse = true })

hl.bind("SUPER + left", hl.dsp.window.move({ direction = "l", group_aware = true }))
hl.bind("SUPER + right", hl.dsp.window.move({ direction = "r", group_aware = true }))
hl.bind("SUPER + up", hl.dsp.window.move({ direction = "u", group_aware = true }))
hl.bind("SUPER + down", hl.dsp.window.move({ direction = "d", group_aware = true }))

-- move a window into a (c)orner --
--[[
hl.bind("SUPER + C", function ()
    hl.exec_cmd("hyprctl --batch \"dispatch setfloating; dispatch resizeactive exact 30% 30%; dispatch movewindow r; dispatch movewindow u; dispatch moveactive -15 15\"")
end)
]]

-- make a window fakefull(s)creen --
hl.bind("SUPER + S", hl.dsp.window.fullscreen_state({ internal = -1, client = 2 }))

-- (y)outube --
--[[
hl.bind("SUPER + Y", function ()
    hl.exec_cmd("hyprctl dispatch \"fullscreenstate -1 2\" && sleep 0.1 && ydotool key CTRL+- --repeat 4 && ydotool key f")
end)
]]

-- alt tab --
hl.bind("ALT + tab", function()
    local clients = hl.get_windows()

    local lastFocusedNum = -1
    local lastFocusedWin = nil
    for i, win in ipairs(clients) do
        if win.focus_history_id > lastFocusedNum then
            lastFocusedNum = win.focus_history_id
            lastFocusedWin = win
        end
    end

    if lastFocusedWin ~= nil then
        hl.dispatch(hl.dsp.focus({ window = lastFocusedWin }))
    end
end)

-- zoom --
hl.bind("SUPER + z", function()
    local zoomed = hl.get_config("cursor.zoom_factor") == 1
    if zoomed then
        hl.config({ cursor = { zoom_factor = 2.0 } })
    else
        hl.config({ cursor = { zoom_factor = 1.0 } })
    end
end)

-- (Z)uspend the active process --
hl.bind("SUPER + SHIFT + Z", hl.dsp.exec_cmd("hyprfreeze -a"))

-- switch workspaces with super + [1-9]
for i = 1, 9, 1 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end


-- sw(A)llow --
hl.bind("SUPER + A", hl.dsp.window.toggle_swallow())

-- screen drawing --
hl.bind("SUPER + D", hl.dsp.exec_cmd("wayscriber --active"))

--[[
# lock the (m)ouse to the current window
bind=super,m,submap,mouselock
submap=mouselock
bind=,l,exec, hyprctl --batch "keyword input:follow_mouse 2; dispatch submap reset" && notify-send "Locked mouse"
bind=,u,exec, hyprctl --batch "keyword input:follow_mouse 1; dispatch submap reset" && notify-send "Unlocked mouse"
submap=reset

# mouse but key
bind=super,q,submap,click
submap=click
binde=,q,exec, ydotool click 0x40
bindr=,q,exec, ydotool click 0x80
binde=,w,exec, ydotool click 0x41
bindr=,w,exec, ydotool click 0x81
bindr=,Left,exec, ydotool mousemove -x -5 -y 0
bindr=,Right,exec, ydotool mousemove -x 5 -y 0
bindr=,Up,exec, ydotool mousemove -x 0 -y -5
bindr=,Down,exec, ydotool mousemove -x 0 -y 5
bind=,catchall,submap,reset
submap=reset
]]

---- window rules ----

hl.window_rule({
    name = "gamescope",
    match = {
        class = "gamescope"
    },
    fullscreen = true,
    -- immediate = true
})

-- modals --
hl.window_rule({
    match = {
        class = "org.kde.polkit-kde-authentication-agent-1"
    },
    float = true
})
hl.window_rule({
    match = {
        class = "obsidian",
        title = "^$"
    },
    float = true
})

hl.window_rule({
    name = "float-popup",
    match = {
        tag = "float-popup"
    },
    float = true,
    fullscreen_state = "0 3",
    stay_focused = true
})
hl.window_rule({
    name = "float-popup-disable-focus",
    match = {
        tag = "float-popup-disable-focus"
    },
    no_focus = true
})

hl.window_rule({
    match = {
        title = "Bitwarden - Vivaldi"
    },
    tag = "float-popup"
})

-- fixes --
hl.window_rule({
    match = {
        class = "Aseprite"
    },
    tile = true
})

--[[
# shimeji
windowrule {
    name = shimeji
    match:class = ^(shimeji)$
    # com-group_finity-mascot-Main

    float = on
    no_blur = on
    no_shadow = on
    border_size = 0
    rounding = 0
}
]]

-- locking --
hl.window_rule({
    name = "lock_fade",
    match = {
        tag = "gone"
    },
    opacity = 0,
    no_anim = true
})

-- misc --
hl.window_rule({
    match = {
        float = true
    },
    no_blur = true
})
hl.window_rule({
    suppress_event = "maximize"
})

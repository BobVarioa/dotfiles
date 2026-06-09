
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
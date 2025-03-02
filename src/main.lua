local desktop = {"Windows", "Linux", "OS X"}
IS_DESKTOP = false
nest = require("lib.nest").init({ console = "3ds", scale = 1, mode = "720", emulateJoystick = true })

__DEBUG__ = false

if love.graphics.setLineStyle then
    love.graphics.setLineStyle("rough")
end

FONT = love.graphics.newFont("resources/fonts/m6x11plus.ttf", 24)
love.graphics.setFont(FONT)

require("misc_functions")
require("blind_functions")
require("ui_functions")
require("music_manager")

require("sprite")
require("card")

require("cursor")

musicManager.load()

local curstate = ""

states = {
    menu = require("states.menu")
}

TOPSCREEN = {
    -- 3ds top screen
    getWidth = function() return 400 end,
    getHeight = function() return 240 end
}

BOTTOMSCREEN = {
    -- 3ds bottom screen
    getWidth = function() return 320 end,
    getHeight = function() return 240 end
}

function switchState(state)
    if curstate ~= "" then states[curstate]:leave() end
    curstate = state
    states[curstate]:enter()
end

switchState("menu")

function table.find(t, value)
    for k, v in pairs(t) do
        if v == value then
            return k
        end
    end
    return nil
end

if love.graphics.setDefaultFilter then
    love.graphics.setDefaultFilter("nearest", "nearest")
end

function love.load()
    IS_DESKTOP = table.find(desktop, love.system.getOS())
end

function love.update(dt)
    states[curstate]:update(dt)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if states[curstate].touchpressed then
        states[curstate]:touchpressed(id, x, y, dx, dy, pressure)
    end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    if states[curstate].touchreleased then
        states[curstate]:touchreleased(id, x, y, dx, dy, pressure)
    end

    cursor:release()
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    if states[curstate].touchmoved then
        states[curstate]:touchmoved(id, x, y, dx, dy, pressure)
    end

    cursor:moved(x, y, dx, dy)
end

function love.keypressed(k)
    nest.video.keypressed(k)
end

function love.draw(screen)
    if screen == "bottom" then
        states[curstate]:drawBottom()
    else
        states[curstate]:drawTop()
    end
end
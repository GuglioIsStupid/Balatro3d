local desktop = {"Windows", "Linux", "OS X"}
IS_DESKTOP = false
nest = require("lib.nest").init({ console = "3ds", scale = 1, mode = "720" })

__DEBUG__ = false

require "engine.object"
bit = require "bit"
require "engine.string_packer"
require "engine.controller"
require "back"
require "tag"
require "engine.event"

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

function love.keypressed(k)
    nest.video.keypressed(k)
end

function love.draw(screen)
end
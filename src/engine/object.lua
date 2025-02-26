Object = {}
Object.__index = Object

function Object:index() -- Override me!
end

function Object:extend()
    local object = {}
    for k, v in pairs(self) do
        if k:find("__") == 1 then
            object[k] = v
        end
    end
    object.__index = object
    object.super = self
    return setmetatable(object, self)
end

function Object:is(object)
    local mt = getmetatable(self)
    while mt do
        if mt == object then
            return true
        end
        mt = getmetatable(mt)
    end
    return false
end

function Object:__call(...)
    local object = setmetatable({}, self)
    object:index(...)
    return object
end
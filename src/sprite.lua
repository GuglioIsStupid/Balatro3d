function screenDepth(screen)
    local depth = screen ~= "bottom" and -love.graphics.getDepth() or 0
    if screen == "right" then
        depth = -depth
    end
    return depth
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

function Sprite(imgData)
    local self = {}

    self.origX, self.origY = 0, 0
    self.x, self.y = 0, 0

    function self:setPos(x, y)
        self.x, self.y = x, y
        self.origX, self.origY = x, y
    end

    self.rotation = 0
    self.scale = 1
    self.origScale = 1
    self.imgData = imgData
    self.width, self.height = imgData:getWidth(), imgData:getHeight()

    self.depth = 0

    function self:draw(addX, addY, rotation, scale, col, forced)
        local lastColor
        if col then
            lastColor = {love.graphics.getColor()}
            love.graphics.setColor(col)
        end
        if not forced then
            x, y = (addX or 0) + self.x, (addY or 0) + self.y
        else
            x, y = addX, addY
        end
        x = x - (screenDepth(love.graphics.getActiveScreen()) * self.depth)
        rotation = rotation or self.rotation
        scale = scale or self.scale
        love.graphics.draw(self.imgData, x, y, rotation, scale, scale, self.width / 2, self.height / 2)
        if col then
            love.graphics.setColor(lastColor)
        end
    end

    function self:update(dt)
        self.x = lerp(self.x, self.origX, 10 * dt)
        self.y = lerp(self.y, self.origY, 10 * dt)

        self.scale = lerp(self.scale, self.origScale, 10 * dt)
    end

    function self:moved(x, y)
        self.x, self.y = x, y
    end

    return self
end
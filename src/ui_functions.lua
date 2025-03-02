function button(name, x, y, w, h, col, callback, txtScale)
    txtScale = txtScale or 1
    col = col or {0.5, 0.5, 0.5, 1}
    local hoverCol = {col[1] * 0.8, col[2] * 0.8, col[3] * 0.8, col[4]}
    local under = {col[1] * 0.2, col[2] * 0.2, col[3] * 0.2, col[4]}
    local state = col
    local clicked = false
    local hover = false
    x, y, w, h = x, y, w, h
    callback = callback or function() end

    local fnt = love.graphics.getFont()
    local fntWidth = fnt:getWidth(name)
    local fntHeight = fnt:getHeight(name)

    return {
        x = x,
        y = y,
        draw = function(self)
            local txtX = self.x + (w - fntWidth * txtScale) / 2
            local txtY = self.y + (h - fntHeight * txtScale) / 2

            love.graphics.setColor(under)
            love.graphics.rectangle("fill", self.x, self.y+4, w, h, 5, 5)
            love.graphics.setColor(state or col)
            love.graphics.rectangle("fill", self.x, self.y + (clicked and 4 or 0), w, h, 5, 5)

            love.graphics.setColor(1, 1, 1, 1)        
            love.graphics.print(name, txtX, txtY + (clicked and 4 or 0), 0, txtScale, txtScale)
        end,
        touchpressed = function(self, _, tx, ty)
            local x, y = self.x, self.y
            if tx > x and tx < x + w and ty > y and ty < y + h then
                state = hoverCol
                clicked = true
            end
        end,

        touchreleased = function(self, _, tx, ty)
            local x, y = self.x, self.y
            if tx > x and tx < x + w and ty > y and ty < y + h and clicked then
                callback(self)
            end
            state = col
            clicked = false
        end,

        touchmoved = function(self, _, tx, ty)
            local x, y = self.x, self.y
            if tx > x and tx < x + w and ty > y and ty < y + h then
                state = hoverCol
                clicked = true
            else
                state = col
                clicked = false
            end
        end
    }
end
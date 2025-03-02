local menu = {}

local function makeRadialGradient(col1, col2, radius)
    radius = radius or 300
    local imgData = love.image.newImageData(400, 240)
    for x = 0, 400-1 do
        for y = 0, 240-1 do
            local dist = math.sqrt((x - 200)^2 + (y - 120)^2)

            local r = math.floor(col1[1] + (col2[1] - col1[1]) * dist / radius)
            local g = math.floor(col1[2] + (col2[2] - col1[2]) * dist / radius)
            local b = math.floor(col1[3] + (col2[3] - col1[3]) * dist / radius)
            local a = math.floor(col1[4] + (col2[4] - col1[4]) * dist / radius)

            r,g,b = r/255, g/255, b/255
            imgData:setPixel(x, y, r, g, b, a)
        end
    end

    -- now we do pixel sampling to pixelize
    -- higher sample means it processes faster but makes it more pixelized
    local sample = 16
    for x = 0, 400-1, sample do
        if x + sample > 400 then break end
        for y = 0, 240-1, sample do
            if y + sample > 240 then break end
            local r, g, b, a = 0, 0, 0, 0
            for i = 0, sample-1 do
                for j = 0, sample-1 do
                    local _r, _g, _b, _a = imgData:getPixel(x+i, y+j)
                    r = r + _r
                    g = g + _g
                    b = b + _b
                    a = a + _a
                end
            end
            r = r / sample^2
            g = g / sample^2
            b = b / sample^2
            a = a / sample^2
            for i = 0, sample-1 do
                for j = 0, sample-1 do
                    imgData:setPixel(x+i, y+j, r, g, b, a)
                end
            end
        end
    end

    return love.graphics.newImage(imgData)
end

function menu:enter()
    self.logo = Sprite(getTexture("balatro"))
    self.logo.x, self.logo.y = TOPSCREEN.getWidth() / 2, TOPSCREEN.getHeight() / 2
    self.logo.scale = 0.85
    
    self.ace = Card("Ace", "Spade", "None")
    self.ace.x, self.ace.y = TOPSCREEN.getWidth() / 2, TOPSCREEN.getHeight() / 2
    self.ace.scale = 0.85

    self.logo.depth = 2
    self.ace.depth = 3

    self.bg = makeRadialGradient({0, 0, 255, 255}, {255, 0, 0, 255})

    self.curSubMenu = nil

    self.playbtn = button("Play", 15, BOTTOMSCREEN:getHeight()/2-45, 100, 85, COLOURS.BLUE, function() 
        self.curSubMenu = "play"
    end)

    self.optionsbtn = button("Options", 120, BOTTOMSCREEN:getHeight()/2-45, 80, 40, COLOURS.ORANGE, function() 
        print("Options!")
    end, 0.7)

    self.quitbtn = button("Quit", 120, BOTTOMSCREEN:getHeight()/2, 80, 40, COLOURS.RED, function() 
        love.event.quit()
    end, 0.7)

    self.collectionbtn = button("Collection", 205, BOTTOMSCREEN:getHeight()/2-45, 100, 85, COLOURS.GREEN, function() 
        print("Collection!")
    end)

    self.t = 0 -- used for lerping
    self.targetSubmenuY = 20
    self.startSubmenuY = BOTTOMSCREEN:getHeight()+5
    self.submenuGoingBack = false
    self.submenu = {
        ["play"] = {
            y = self.startSubmenuY,
            curbtn = "newrun",
            btns = {
                newrunbtn = button("New Run", 15, 5, 92, 25, COLOURS.RED, function(self)
                    print("New Run!")
                    self.parent.curbtn = "newrun"
                end, 0.8),
                continuebtn = button("Continue", 114, 5, 92, 25, COLOURS.L_BLACK, function(self)
                    print("Continue!")
                    self.parent.curbtn = "continue"
                end, 0.8),
                challengesbtn = button("Challenges", 213, 5, 92, 25, COLOURS.L_BLACK, function(self)
                    print("Challenges!")
                    self.parent.curbtn = "challenges"
                end, 0.8),
                bckbtn = button("Back", 15, 165, 290, 25, COLOURS.ORANGE, function()
                    self.t = 0
                    self.submenuGoingBack = true
                end, 0.8),
            },
            onUpdate = function(self, dt)
                for _, btn in pairs(self.btns) do
                    if not btn.origY then
                        btn.origY = btn.y
                    end
                    btn.y = btn.origY + self.y
                end
            end,
            sections = {
                ["newrun"] = {
                    btns = {
                        leftdeckbtn = button("<", 165, 38, 20, 75, COLOURS.L_BLACK, function()
                            print("<")
                        end),
                        rightdeckbtn = button(">", 285, 38, 20, 75, COLOURS.L_BLACK, function()
                            print(">")
                        end),
                        leftstakebtn = button("<", 165, 120, 20, 35, COLOURS.L_BLACK, function()
                            print("<")
                        end),
                        rightstakebtn = button(">", 285, 120, 20, 35, COLOURS.L_BLACK, function()
                            print(">")
                        end),
                        playbtn = button("Play", 15, 38, 140, 75, COLOURS.GREEN, function()
                            print("Play!")
                        end, 0.8),
                    },
                    onUpdate = function(self, dt)
                        for _, btn in pairs(self.btns) do
                            if not btn.origY then
                                btn.origY = btn.y
                            end
                            btn.y = btn.origY + self.parent.y
                        end

                        self.deckCard:update(dt)
                    end,
                    onDrawTop = function(self)
                        
                    end,
                    onDrawBottom = function(self)
                        self.deckCard:draw(237, 80 + self.parent.y, 0, 0.8, {0.5, 0.5, 0.5, 1}, true)
                        self.deckCard:draw(236, 79 + self.parent.y, 0, 0.8, not self.deckCard.grabbed and {0.5, 0.5, 0.5, 1} or {1, 1, 1, 1}, true)
                        self.deckCard:draw(0, self.parent.y, 0, 0.8)
                    end,
                    deckCard = Card("Ace", "Spade", "Back", {x = 235, y = 77})
                },
                ["continue"] = {
                    btns = {},
                    onUpdate = function(self, dt)
                        for _, btn in pairs(self.btns) do
                            if not btn.origY then
                                btn.origY = btn.y
                            end
                            btn.y = btn.origY + self.parent.y
                        end
                    end,
                    onDrawTop = function(self)
                        
                    end,
                    onDrawBottom = function(self)
                        
                    end,
                },
                ["challenges"] = {
                    btns = {},
                    onUpdate = function(self, dt)
                        for _, btn in pairs(self.btns) do
                            if not btn.origY then
                                btn.origY = btn.y
                            end
                            btn.y = btn.origY + self.parent.y
                        end
                    end,
                    onDrawTop = function(self)
                        
                    end,
                    onDrawBottom = function(self)
                        
                    end,
                }
            }
        }
    }

    self.submenu.play.sections.newrun.deckCard.parent = self.submenu.play.sections.newrun

    -- set parents
    for _, btn in pairs(self.submenu["play"].btns) do
        btn.parent = self.submenu["play"]
    end

    -- set the parents to the sections
    for _, section in pairs(self.submenu["play"].sections) do
        section.parent = self.submenu["play"]

        for _, btn in pairs(section.btns) do
            btn.parent = section
        end
    end
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function linear(t)
    return t
end

local function outQuad(t)
    return t * (2 - t)
end

function menu:update(dt)
    self.ace.rotation = math.sin(love.timer.getTime() * 0.85) * 0.075

    if self.curSubMenu then
        self.t = math.min(self.t + dt * 10, 1)
        if self.submenuGoingBack then
            self.submenu[self.curSubMenu].y = lerp(self.targetSubmenuY, BOTTOMSCREEN:getHeight()+5, outQuad(self.t))
            if self.t >= 1 then
                self.submenuGoingBack = false
                self.t = 0
                self.curSubMenu = nil
            end
        else
            self.submenu[self.curSubMenu].y = lerp(BOTTOMSCREEN:getHeight()+5, self.targetSubmenuY, outQuad(self.t))
        end
        if self.curSubMenu then
            self.submenu[self.curSubMenu]:onUpdate(dt)

            self.submenu[self.curSubMenu].sections[self.submenu[self.curSubMenu].curbtn]:onUpdate(dt)
        end
    end
end

function menu:touchpressed(id, x, y, dx, dy, pressure)
    if cursor.currentObj then return end
    if not self.curSubMenu then
        self.playbtn:touchpressed(id, x, y, dx, dy, pressure)
        self.optionsbtn:touchpressed(id, x, y, dx, dy, pressure)
        self.quitbtn:touchpressed(id, x, y, dx, dy, pressure)
        self.collectionbtn:touchpressed(id, x, y, dx, dy, pressure)
    else
        for _, btn in pairs(self.submenu[self.curSubMenu].btns) do
            btn:touchpressed(id, x, y, dx, dy, pressure)
        end

        for _, section in pairs(self.submenu[self.curSubMenu].sections[self.submenu[self.curSubMenu].curbtn].btns) do
            section:touchpressed(id, x, y, dx, dy, pressure)
        end

        if self.curSubMenu == "play" and self.submenu[self.curSubMenu].curbtn == "newrun" then
            local deckCard = self.submenu[self.curSubMenu].sections[self.submenu[self.curSubMenu].curbtn].deckCard

            if deckCard:inBounds(x,y, nil, nil, 0.8) then
                deckCard.origScale = 1.1
                cursor:grab(deckCard)
                print("grabbed")
            end
        end
    end
end

function menu:touchreleased(id, x, y, dx, dy, pressure)
    if cursor.currentObj then return end
    if not self.curSubMenu then
        self.playbtn:touchreleased(id, x, y, dx, dy, pressure)
        self.optionsbtn:touchreleased(id, x, y, dx, dy, pressure)
        self.quitbtn:touchreleased(id, x, y, dx, dy, pressure)
        self.collectionbtn:touchreleased(id, x, y, dx, dy, pressure)
    else
        for _, btn in pairs(self.submenu[self.curSubMenu].btns) do
            btn:touchreleased(id, x, y, dx, dy, pressure)
        end

        for _, section in pairs(self.submenu[self.curSubMenu].sections[self.submenu[self.curSubMenu].curbtn].btns) do
            section:touchreleased(id, x, y, dx, dy, pressure)
        end

        if self.curSubMenu == "play" and self.submenu[self.curSubMenu].curbtn == "newrun" then
            local deckCard = self.submenu[self.curSubMenu].sections[self.submenu[self.curSubMenu].curbtn].deckCard

            deckCard.origScale = 1
        end
    end
end

function menu:touchmoved(id, x, y, dx, dy, pressure)
    if cursor.currentObj then return end
    if not self.curSubMenu then
        self.playbtn:touchmoved(id, x, y, dx, dy, pressure)
        self.optionsbtn:touchmoved(id, x, y, dx, dy, pressure)
        self.quitbtn:touchmoved(id, x, y, dx, dy, pressure)
        self.collectionbtn:touchmoved(id, x, y, dx, dy, pressure)
    else
        for _, btn in pairs(self.submenu[self.curSubMenu].btns) do
            btn:touchmoved(id, x, y, dx, dy, pressure)
        end

        for _, section in pairs(self.submenu[self.curSubMenu].sections[self.submenu[self.curSubMenu].curbtn].btns) do
            section:touchmoved(id, x, y, dx, dy, pressure)
        end

        if self.curSubMenu == "play" and self.submenu[self.curSubMenu].curbtn == "newrun" then
            local deckCard = self.submenu[self.curSubMenu].sections[self.submenu[self.curSubMenu].curbtn].deckCard

            if deckCard:inBounds(x,y, nil, nil, 0.8) then
                deckCard.origScale = 1.1
            else
                deckCard.origScale = 1
            end
        end
    end
end

function menu:leave()

end

function menu:drawTop()
    love.graphics.draw(self.bg, 0, 0)
    self.logo:draw()
    self.ace:draw()

    if self.curSubMenu then
        self.submenu[self.curSubMenu].sections[self.submenu[self.curSubMenu].curbtn]:onDrawTop()
    end
end

function menu:drawBottom()
    love.graphics.draw(self.bg, -40, 0)

    love.graphics.setColor(COLOURS.BLACK)
    love.graphics.rectangle("fill", 10, BOTTOMSCREEN:getHeight()/2-50, 300, 100, 5, 5)

    self.playbtn:draw()
    self.optionsbtn:draw()
    self.quitbtn:draw()
    self.collectionbtn:draw()

    if self.curSubMenu then
        love.graphics.setColor(COLOURS.GREY[1], COLOURS.GREY[2], COLOURS.GREY[3], 0.7)
        love.graphics.rectangle("fill", 0, 0, BOTTOMSCREEN:getWidth(), BOTTOMSCREEN:getHeight())

        love.graphics.setColor(COLOURS.BLACK)
        love.graphics.rectangle("fill", 10, self.submenu[self.curSubMenu].y, 300, 200, 5, 5)
        
        for _, btn in pairs(self.submenu[self.curSubMenu].btns) do
            btn:draw()
        end

        for _, section in pairs(self.submenu[self.curSubMenu].sections[self.submenu[self.curSubMenu].curbtn].btns) do
            section:draw()
        end

        self.submenu[self.curSubMenu].sections[self.submenu[self.curSubMenu].curbtn]:onDrawBottom()
    end
end

return menu
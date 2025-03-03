local cards = {
    -- name: quad
    -- name format is type_card
    -- e.g. Space_Ace
}

CARD_ATLAS = getTexture("8BitDeck")
local cardOrder = {
    ["2"] = 1,
    ["3"] = 2,
    ["4"] = 3,
    ["5"] = 4,
    ["6"] = 5,
    ["7"] = 6,
    ["8"] = 7,
    ["9"] = 8,
    ["10"] = 9,
    ["Jack"] = 10,
    ["Queen"] = 11,
    ["King"] = 12,
    ["Ace"] = 13
}
local suitOrder = {
    ["Heart"] = 1,
    ["Club"] = 2,
    ["Diamond"] = 3,
    ["Spade"] = 4
}

local enhancerTILE = {
    ["Back"] = 1,
    ["None"] = 2,
    ["GoldSeal"] = 3,
    ["IDK"] = 4,
    ["Locked"] = 5,
    ["Stone"] = 6,
    ["Gold"] = 7,
    ["Prism"] = 8 -- New line!
}

local CARD_ATLAS_PX, CARD_ATLAS_PY = 13, 4
ENHANCERS_ATLAS = getTexture("Enhancers")
local ENHANCER_ATLAS_PX, ENHANCER_ATLAS_PY = 7, 5
local function convertEnhancerTile(tile)
    -- converts tile into the px, py
    -- e.g. "Back" -> 1, 1
    -- e.g. "Prism" -> 1, 2
    return (tile - 1) % ENHANCER_ATLAS_PX + 1, math.floor((tile - 1) / ENHANCER_ATLAS_PX) + 1
end

local quadCache = {}
local function getQuad(px, py, atlas_px, atlas_py, atlas, name)
    if not quadCache[name] then
        local atlasWidth, atlasHeight = atlas:getWidth(), atlas:getHeight()

        local width = atlasWidth / atlas_px
        local height = atlasHeight / atlas_py

        local x = (px - 1) * width
        local y = (py - 1) * height

        quadCache[name] = love.graphics.newQuad(x, y, width, height, atlasWidth, atlasHeight)
    end

    return quadCache[name]
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

function Card(card, type, enhancer, data)
    enhancer = enhancer or "None"
    data = data or {}
    local self = {}

    self.card = card
    self.type = type
    self.name = self.type .. "_" .. self.card
    self.cardQuad = getQuad(cardOrder[self.card], suitOrder[self.type], CARD_ATLAS_PX, CARD_ATLAS_PY, CARD_ATLAS, self.name)
    local epx, epy = convertEnhancerTile(enhancerTILE[enhancer])
    self.enhancerQuad = getQuad(epx, epy, ENHANCER_ATLAS_PX, ENHANCER_ATLAS_PY, ENHANCERS_ATLAS, enhancer)
    local _, _, width, height = self.cardQuad:getViewport()
    self.width, self.height = width, height

    self.origX, self.origY = data.x or 0, data.y or 0
    self.x, self.y = data.x or 0, data.y or 0

    self.selected = false

    function self:setPos(x, y)
        self.x, self.y = x, y
        self.origX, self.origY = x, y
    end
    self.rotation = 0
    self.scale = 1
    self.origScale = 1
    self.origRotation = 0
    self.grabbed = false

    self.depth = 0

    self.dx, self.dy = 0, 0
    self.mx, self.my = 0, 0

    self.doRotationMagic = false

    function self:draw(addX, addY, rotation, scale, col, forced)
        local lastColor
        if col then
            lastColor = {love.graphics.getColor()}
            love.graphics.setColor(col)
        end
        if not forced then
            x, y = (addX or 0) + self.x, (addY or 0) + self.y
            scale = self.scale * (scale or 1)
            rotation = self.rotation + (rotation or 0)
        else
            x, y = addX, addY
            scale = scale or 1
            rotation = rotation or 0
        end
        x = x - (screenDepth(love.graphics.getActiveScreen()) * self.depth)
        
        love.graphics.draw(ENHANCERS_ATLAS, self.enhancerQuad, x, y - (self.selected and 8 or 0), rotation, scale, scale, self.width / 2, self.height / 2)
        if enhancer ~= "Back" then
            love.graphics.draw(CARD_ATLAS, self.cardQuad, x, y - (self.selected and 8 or 0), rotation, scale, scale, self.width / 2, self.height / 2)
        end
        if col then
            love.graphics.setColor(lastColor)
        end
    end

    function self:inBounds(x, y, ox, oy, scale)
        -- since the origin is half the width and height, we need to take that into account (subtractit)
        ox = ox or self.x
        oy = oy or self.y
        oy = oy + 20
        scale = scale or 1

        local width, height = self.width * scale, self.height * scale

        return x > ox - width / 2 and x < ox + width / 2 and y > oy - height / 2 and y < oy + height / 2
    end

    function self:update(dt)
        if self.doRotationMagic then
            -- sin the rotation
            self.rotation = math.sin(love.timer.getTime() * 2) / 2
        end
        if not self.grabbed then
            local ox, oy = self.x, self.y
            self.x = lerp(self.x, self.origX, 10 * dt)
            self.y = lerp(self.y, self.origY, 10 * dt)
            if math.floor(self.x) == math.floor(ox) and math.floor(self.y) == math.floor(oy) then
                self.rotation = lerp(self.rotation, self.origRotation, 10 * dt)
            else
                local angle = math.atan2(self.y - oy, self.x - ox) + math.pi / 2
                local diff = angle - self.rotation
                if diff > math.pi then
                    diff = diff - 2 * math.pi
                elseif diff < -math.pi then
                    diff = diff + 2 * math.pi
                end

                -- max of 15deg (0.261799 rad)
                local rot = math.min(math.max(diff, -0.5), 0.5)

                self.rotation = lerp(self.rotation, rot, 25 * dt)
            end
        else
            local ox, oy = self.x, self.y
            self.x = lerp(self.x, self.mx, 25 * dt)
            self.y = lerp(self.y, self.my, 25 * dt)
            
            local angle = math.atan2(self.y - oy, self.x - ox) + math.pi / 2
            local diff = angle - self.rotation
            if diff > math.pi then
                diff = diff - 2 * math.pi
            elseif diff < -math.pi then
                diff = diff + 2 * math.pi
            end

            if math.floor(self.x) == math.floor(ox) and math.floor(self.y) == math.floor(oy) then
                diff = 0
            end

            -- max of 15deg (0.261799 rad)
            local rot = math.min(math.max(diff, -0.5), 0.5)

            self.rotation = lerp(self.rotation, rot, 10 * dt)
        end
        self.scale = lerp(self.scale, self.origScale, 50 * dt)
    end
    
    function self:moved(x, y)
        self.mx, self.my = x, y
    end

    return self
end
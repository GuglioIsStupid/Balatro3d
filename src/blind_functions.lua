local allAmounts = {
    {300,  800,  2000,  5000,  11000,  20000,  35000,   50000 },
    {300,  900,  2600,  8000,  20000,  36000,  60000,   100000},
    {300,  1000, 3200,  9000,  25000,  60000,  110000,  200000}
}
-- A cleaned up function from the official game. It's a bit more readable now (and runs better on the 3DS)
function getBlindAmount(ante)
    local k = 0.75
    local amounts = allAmounts[1]

    if ante < 1 then return 100 end
    if ante <= 8 then return amounts[ante] end

    local a = amounts[8]
    local c = ante - 8
    local d = 1 + 0.2 * c
    local baseAmount = a * (1.6 + k * c)^d

    local amount = math.floor(baseAmount)
    local scale = 10 ^ math.floor(math.log10(amount) - 1)
    amount = math.floor(amount / scale) * scale

    return amount
end

function getBlindScore(blind, base)
    base = base or getBlindAmount(runInfo.ante)

    return base * (1 + 0.5 * (blind - 1))
end

local blindTILE = {
    ["SMALL"] = 1,
    ["boss_1"] = 2,
    ["boss_2"] = 3,
    ["boss_3"] = 4,
    ["BIG"] = 5 -- New line!
}
local tileToBlindName = {
    ["SMALL"] = "Small Blind",
    ["boss_1"] = "Boss Blind",
    ["boss_2"] = "Boss Blind",
    ["boss_3"] = "Boss Blind",
    ["BIG"] = "Big Blind"
}
BLIND_ATLAS = getTexture("BlindChips")
local blind_PX, blind_PY = 4, 8
local function convertBlindTile(tile)
    return (tile - 1) % blind_PX + 1, math.floor((tile - 1) / blind_PX) + 1
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

function Blind(name, data)
    data = data or {}
    local self = {}

    self._name = name
    self.name = tileToBlindName[name]
    local bpx, bpy = convertBlindTile(blindTILE[self._name])
    self.blindQuad = getQuad(bpx, bpy, blind_PX, blind_PY, BLIND_ATLAS, self.name)
    local _, _, width, height = self.blindQuad:getViewport()
    self.width, self.height = width, height

    self.origX, self.origY = data.x or 0, data.y or 0
    self.x, self.y = data.x or 0, data.y or 0

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
        love.graphics.draw(BLIND_ATLAS, self.blindQuad, x, y, rotation, scale, scale, self.width / 2, self.height / 2)
        if col then
            love.graphics.setColor(lastColor)
        end
    end

    function self:inBounds(x, y, ox, oy, scale)
        -- since the origin is half the width and height, we need to take that into account (subtractit)
        ox = ox or self.x
        oy = oy or self.y

        local width, height = self.width * scale, self.height * scale

        return x > ox - width / 2 and x < ox + width / 2 and y > oy - height / 2 and y < oy + height / 2
    end

    function self:update(dt)
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
        self.x, self.y = x, y
    end

    return self
end
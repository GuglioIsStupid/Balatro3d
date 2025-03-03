local game = {}
local cardY = 200
local cardX = 150

local function lerp(a, b, t)
    return a + (b - a) * t
end

function game:enter()
    self.currentScreen = "blind"
    self.blinds = {
        Blind("SMALL"),
        Blind("BIG"),
        Blind("boss_1")
    }

    self.screens = {
        ["blind"] = {
            btns = {
                {
                    button("Select", 20, 110, 75, 15, COLOURS.GREEN, function()
                        self.currentScreen = nil
                        self.fillingCards = true
                        cardX, cardY = 55, 180
                    end, 0.6),
                    button("Skip", 20, 210, 75, 15, COLOURS.RED, function()
                        print("Skip not implemented")
                    end, 0.6),
                },
                {
                    button("Select", 123, 110, 75, 15, COLOURS.GREEN, function()
                        self.currentScreen = "game"
                    end, 0.6),
                    button("Skip", 123, 210, 75, 15, COLOURS.RED, function()
                        print("Skip not implemented")
                    end, 0.6),
                },
                {
                    button("Select", 225, 110, 75, 15, COLOURS.GREEN, function()
                        self.currentScreen = "game"
                    end, 0.6),
                    button("Skip", 225, 210, 75, 15, COLOURS.RED, function()
                        print("Skip not implemented")
                    end, 0.6),
                }
            }
        },
        ["shop"] = {
            btns = {}
        }
    }

    self.fillingCards = false
    self.timer = {
        maxCardTimer = 0.08,
        cardTimer = 0
    }

    self.chips = 0
    self.mult = 0
end

local crdWidth = 0
local cardSpacing = crdWidth/2 - 5
-- the higher the handSize, the closer they get
local selectedCount = 0

function game:update(dt)
    if self.fillingCards then
        crdWidth = runInfo.deck[1].width * 0.7
        cardSpacing = (runInfo.handSize - 8) * 2 - crdWidth/2 - 5
        self.timer.cardTimer = self.timer.cardTimer + dt

        if self.timer.cardTimer >= self.timer.maxCardTimer then
            self.timer.cardTimer = 0
            local topCrd = table.remove(runInfo.deck, 1)
            table.insert(runInfo.currentDeck, topCrd)
            topCrd.origX, topCrd.origY = cardX, cardY
            
            cardX = cardX - cardSpacing
            
            if #runInfo.currentDeck == runInfo.handSize then
                self.fillingCards = false
                self.justFinishedFilling = true
                cardX = 55
            end
        end
    else
        if self.justFinishedFilling then
            runInfo.currentDeck = sortDeckByRank(runInfo.currentDeck)
            self.justFinishedFilling = false

            -- resort origX
            for k, v in pairs(runInfo.currentDeck) do
                v.origX = cardX
                cardX = cardX - cardSpacing
            end
        end
    end

    if not self.currentScreen then
        for k, v in pairs(runInfo.currentDeck) do
            v:update(dt)
        end
    end
end

function game:touchpressed(id, x, y, dx, dy, pressure)
    if self.currentScreen then
        if self.currentScreen == "blind" then
            for k, v in pairs(self.screens[self.currentScreen].btns[runInfo.curBlind]) do
                v:touchpressed(id, x, y)
            end
        end
    else
        for i = #runInfo.currentDeck, 1, -1 do
            local crd = runInfo.currentDeck[i]
            if crd:inBounds(x, y, nil, nil, 0.8) then
                if crd.selected then
                    crd.selected = false
                    selectedCount = selectedCount - 1
                elseif selectedCount < runInfo.playSize - 1 then
                    crd.selected = true
                    selectedCount = selectedCount + 1
                end
                break
            end
        end
    end
end

function game:touchreleased(id, x, y, dx, dy, pressure)
    if self.currentScreen then
        if self.currentScreen == "blind" then
            for k, v in pairs(self.screens[self.currentScreen].btns[runInfo.curBlind]) do
                v:touchreleased(id, x, y)
            end
        end
    end
end

function game:touchmoved(id, x, y, dx, dy, pressure)
    if self.currentScreen then
        if self.currentScreen == "blind" then
            for k, v in pairs(self.screens[self.currentScreen].btns[runInfo.curBlind]) do
                v:touchmoved(id, x, y)
            end
        end
    end
end

function game:drawTop()
    love.graphics.draw(BG_ASSET, 0, 0)

    if self.currentScreen == "blind" then
        local smlBlindScore = getBlindScore(1)
        local bigBlindScore = getBlindScore(2)
        local bssBlindScore = getBlindScore(3)

        love.graphics.setColor(COLOURS.L_BLACK)
        local topW = TOPSCREEN:getWidth()

        local boxWidth = topW / 3 - 10
        local boxHeight = 225

        love.graphics.rectangle("fill", 10, 5, boxWidth, boxHeight, 5, 5) -- Small Blind
        love.graphics.rectangle("fill", boxWidth + 15, 5, boxWidth, boxHeight, 5, 5) -- Big Blind
        love.graphics.rectangle("fill", boxWidth * 2 + 20, 5, boxWidth, boxHeight, 5, 5) -- Boss Blind

        local lastLineWidth = love.graphics.getLineWidth()
        love.graphics.setLineWidth(5)
        
        love.graphics.setColor(COLOURS.BLACK)
        love.graphics.rectangle("line", 10, 5, boxWidth, boxHeight, 5, 5)
        love.graphics.rectangle("line", boxWidth + 15, 5, boxWidth, boxHeight, 5, 5)
        love.graphics.rectangle("line", boxWidth * 2 + 20, 5, boxWidth, boxHeight, 5, 5)

        love.graphics.setLineWidth(lastLineWidth)
        love.graphics.setColor(1, 1, 1)

        love.graphics.print("Small Blind", 15, 10, 0, 0.75, 0.75)
        love.graphics.print("Big Blind", boxWidth + 20, 10, 0, 0.75, 0.75)
        love.graphics.print("Boss Blind", boxWidth * 2 + 25, 10, 0, 0.75, 0.75)

        love.graphics.print({{1, 1, 1, 1}, "Score at least:\n", {1, 0, 0, 1}, smlBlindScore}, 15, 55, 0, 0.75, 0.75)
        love.graphics.print({{1, 1, 1, 1}, "Score at least:\n", {1, 0, 0, 1}, bigBlindScore}, boxWidth + 20, 55, 0, 0.75, 0.75)
        love.graphics.print({{1, 1, 1, 1}, "Score at least:\n", {1, 0, 0, 1}, bssBlindScore}, boxWidth * 2 + 25, 55, 0, 0.75, 0.75)

        for k, v in pairs(self.blinds) do
            v:draw(70 + (k - 1) * (boxWidth + 5), 125, 0, 1.5)
        end
    elseif not self.currentScreen then
        -- display blind info at the left
        love.graphics.setColor(COLOURS.L_BLACK)
        love.graphics.rectangle("fill", 10, 5, 100, 180, 5, 5)
        
        local lastLineWidth = love.graphics.getLineWidth()
        love.graphics.setLineWidth(5)
        love.graphics.setColor(COLOURS.BLACK)
        love.graphics.rectangle("line", 10, 5, 100, 180, 5, 5)

        love.graphics.setLineWidth(lastLineWidth)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Round: " .. runInfo.round, 15, 10, 0, 0.75, 0.75)
        love.graphics.print("Ante: " .. runInfo.ante, 15, 35, 0, 0.75, 0.75)
        love.graphics.print(self.blinds[runInfo.curBlind].name, 15, 60, 0, 0.75, 0.75)
        love.graphics.print("Score:\n" .. getBlindScore(runInfo.curBlind), 15, 85, 0, 0.75, 0.75)

        -- print the current chips and current mult
        -- chips in a blue box, mult in a red box
        love.graphics.setColor(COLOURS.BLUE)
        love.graphics.rectangle("fill", 15, 125, 85/2.5, 25, 5, 5)
        love.graphics.setColor(COLOURS.RED)
        love.graphics.rectangle("fill", 15+85/2.5+20, 125, 85/2.5, 25, 5, 5)

        -- Red X 
        love.graphics.setColor(COLOURS.RED)
        love.graphics.print("X", 15+85/2.5+6, 128, 0, 0.8, 0.8)

        love.graphics.setColor(1, 1, 1)
        love.graphics.print(self.chips, 17, 128, 0, 0.75, 0.75)
        love.graphics.print(self.mult, 15+85/2.5+22, 128, 0, 0.75, 0.75)
    end
end

function game:drawBottom()
    love.graphics.draw(BG_ASSET, -40, 0)

    if self.currentScreen == "blind" then
        love.graphics.setColor(COLOURS.L_BLACK)
        love.graphics.rectangle("fill", 15, 100, 85, 135, 5, 5) -- Small Blind
        love.graphics.rectangle("fill", 118, 100, 85, 135, 5, 5) -- Big Blind
        love.graphics.rectangle("fill", 220, 100, 85, 135, 5, 5) -- Boss Blind
        
        local lastLineWidth = love.graphics.getLineWidth()
        love.graphics.setLineWidth(5)
        love.graphics.setColor(COLOURS.BLACK)
        love.graphics.rectangle("line", 15, 100, 85, 135, 5, 5)
        love.graphics.rectangle("line", 118, 100, 85, 135, 5, 5)
        love.graphics.rectangle("line", 220, 100, 85, 135, 5, 5)
        love.graphics.setLineWidth(lastLineWidth)

        love.graphics.setColor(1, 1, 1)
        for k, v in pairs(self.screens[self.currentScreen].btns[runInfo.curBlind]) do
            v:draw()
        end

        love.graphics.print("Small Blind", 20, 135, 0, 0.75, 0.75)
        love.graphics.print("Big Blind", 130, 135, 0, 0.75, 0.75)
        love.graphics.print("Boss Blind\n(Ik it says \nthe name)", 226, 135, 0, 0.75, 0.75)
    elseif not self.currentScreen then
        -- draw the cards laid out with a slight (flipped) u curve
        local deck = runInfo.deck
        local deckSize = #deck
        local cardWidth = deck[1].width
        local cardHeight = deck[1].height
        --[[ local cardSpacing = 10 ]]
        -- the spacing is about card.width/2-5, but changes depending on how many runInfo.handSize is over 8
        
        --[[ for k, v in pairs(runInfo.currentDeck) do
            v:draw(0, 0, 0, 0.8)
        end ]]
        local drawOdr = {}
        for i = #runInfo.currentDeck, 1, -1 do
            table.insert(drawOdr, runInfo.currentDeck[i])
        end

        table.sort(drawOdr, function(a, b)
            return a.origX < b.origX
        end)

        for k, v in pairs(drawOdr) do
            v:draw(0, 0, 0, 0.8)
        end
    end
end

function game:leave()
end

return game
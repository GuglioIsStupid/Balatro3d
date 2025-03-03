---@diagnostic disable: param-type-mismatch
runInfo = {
    deckType = "Red",
    ante = 1,
    round = 1,
    deck = {},
    currentDeck = {},
}

local cards = {
    "2", "3", "4",
    "5", "6", "7",
    "8", "9", "10",
    "Jack", "Queen", "King",
    "Ace"
}
local suits = {
    "Heart", "Club", "Diamond", "Spade"
}

local blinds = {
    "Small Blind", "Big Blind", "BOSS"
}

function runInfo:reset(deckType)
    self.deckType = deckType or "Red"
    self.ante = 1
    self.round = 1
    self.deck = {} -- the full deck
    self.currentDeck = {} -- the current shown cards
    self.jokers = {}
    self.maxJokers = 5 -- +1 for each negative
    self.handSize = 8
    self.playSize = 5
    self.curBlinds = {
        "Small Blind", "Big Blind", "Big Blind" -- always 1 small blind, 1 big blind, 1 boss blind
        --                                         until I have boss blinds implemented, it's just 2 big blinds
    }
    self.curBlind = 1

    for _, suit in ipairs(suits) do
        for _, card in ipairs(cards) do
            table.insert(self.deck, Card(card, suit, "None")) -- 4 suits, 13 cards = 52 cards
        end
    end
end

function runInfo:setSeed(seed)
    -- seed e.g: 8F67AZ7D
    print("Setting seed to " .. seed)
    math.randomseed(randomSeedToNumber(seed))
end

function runInfo:shuffleDeck()
    -- shuffles the deck
    for i = 1, #self.deck do
        local j = math.random(i, #self.deck)
        self.deck[i], self.deck[j] = self.deck[j], self.deck[i]
    end
end

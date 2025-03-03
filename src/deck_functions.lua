local cards = {
    --[[ "2", "3", "4",
    "5", "6", "7",
    "8", "9", "10",
    "Jack", "Queen", "King",
    "Ace" ]]
    "Ace",
    "King", "Queen", "Jack",
    "10", "9", "8",
    "7", "6", "5",
    "4", "3", "2"
}
local suits = {
    "Heart", "Club", "Diamond", "Spade"
}

function sortDeckByRank(deck, backwards)
    local sortedDeck = {}

    for _, card in ipairs(cards) do
        for _, suit in ipairs(suits) do
            for _, deckCard in ipairs(deck) do
                if deckCard.card == card and deckCard.type == suit then
                    table.insert(sortedDeck, deckCard)
                end
            end
        end
    end
    
    return sortedDeck
end

local ranks = {
    ["Ace"] = 11,
    ["King"] = 10,
    ["Queen"] = 10,
    ["Jack"] = 10,
    ["10"] = 10,
    ["9"] = 9,
    ["8"] = 8,
    ["7"] = 7,
    ["6"] = 6,
    ["5"] = 5,
    ["4"] = 4,
    ["3"] = 3,
    ["2"] = 2
}
local ranksForStraight = { -- makes it easier
    ["Ace"] = 14,
    ["King"] = 13,
    ["Queen"] = 12,
    ["Jack"] = 11,
    ["10"] = 10,
    ["9"] = 9,
    ["8"] = 8,
    ["7"] = 7,
    ["6"] = 6,
    ["5"] = 5,
    ["4"] = 4,
    ["3"] = 3,
    ["2"] = 2
}

function countRanks(stdeck)
    local rankCount = {}
    for _, card in ipairs(stdeck) do
        rankCount[card.card] = (rankCount[card.card] or 0) + 1
    end
    return rankCount
end

function getHandType(deck)
    local stdeck = sortDeckByRank(deck)
    local l = #stdeck

    local rankCount = countRanks(stdeck)

    local hasFlush = true
    for i = 2, l do
        if stdeck[i].type ~= stdeck[1].type then
            hasFlush = false
            break
        end
    end

    local hasStraight = true
    for i = 1, l do
        ranksForStraight[stdeck[i].card] = i
    end
    for i = 1, l - 1 do
        if ranksForStraight[stdeck[i].card] + 1 ~= ranksForStraight[stdeck[i + 1].card] then
            hasStraight = false
            break
        end
    end

    local hasFiveKind = false
    local hasFourKind = false
    local hasThreeKind = false
    local hasTwoPair = false
    local hasFullHouse = false
    local pairCount = 0

    for _, count in pairs(rankCount) do
        if count == 5 then
            hasFiveKind = true
        elseif count == 4 then
            hasFourKind = true
        elseif count == 3 then
            hasThreeKind = true
        elseif count == 2 then
            pairCount = pairCount + 1
        end
    end

    if pairCount == 2 then
        hasTwoPair = true
    end

    if hasThreeKind and pairCount == 1 then
        hasFullHouse = true
    end

    if hasFiveKind then
        return "Five of a Kind"
    elseif hasStraight and hasFlush then
        return "Straight Flush"
    elseif hasFourKind then
        return "Four of a Kind"
    elseif hasFullHouse then
        return "Full House"
    elseif hasFlush then
        return "Flush"
    elseif hasStraight then
        return "Straight"
    elseif hasThreeKind then
        return "Three of a Kind"
    elseif hasTwoPair then
        return "Two Pair"
    elseif pairCount == 1 then
        return "Pair"
    else
        return "High Card"
    end
end

local fourKindPlay = {
    Card("Ace", "Heart"),
    Card("Ace", "Club"),
    Card("Ace", "Diamond"),
    Card("Ace", "Spade"),
}
local straightFlushPlay = {
    Card("Ace", "Heart"),
    Card("King", "Heart"),
    Card("Queen", "Heart"),
    Card("Jack", "Heart"),
    Card("10", "Heart"),
}
local fullHousePlay = {
    Card("Ace", "Heart"),
    Card("Ace", "Club"),
    Card("Ace", "Diamond"),
    Card("King", "Heart"),
    Card("King", "Club"),
}
local twoPairPlay = {
    Card("Ace", "Heart"),
    Card("Ace", "Club"),
    Card("King", "Diamond"),
    Card("King", "Heart"),
    Card("10", "Club"),
}
local staightPlay = {
    Card("Ace", "Heart"),
    Card("King", "Club"),
    Card("Queen", "Diamond"),
    Card("Jack", "Heart"),
    Card("10", "Club"),
}
local threeKindPlay = {
    Card("Ace", "Heart"),
    Card("Ace", "Club"),
    Card("Ace", "Diamond"),
    Card("King", "Heart"),
    Card("10", "Club"),
}
local pairPlay = {
    Card("Ace", "Heart"),
    Card("Ace", "Club"),
    Card("King", "Diamond"),
}

print(getHandType(fourKindPlay)) -- Four of a Kind
print(getHandType(straightFlushPlay)) -- Straight Flush
print(getHandType(fullHousePlay)) -- Full House
print(getHandType(twoPairPlay)) -- Two Pair
print(getHandType(staightPlay)) -- Straight
print(getHandType(threeKindPlay)) -- Three of a Kind
print(getHandType(pairPlay)) -- Pair
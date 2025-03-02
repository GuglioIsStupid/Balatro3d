local SWITCH_POINT = 100000000000
function numberFormat(num)    
    if type(num) ~= 'number' then return num or '' end

    if num >= SWITCH_POINT then
      local fac = math.floor(math.log10(num))
      return string.format("%.3fe%d", num / 10^fac, fac)
    end

    local format_spec = num >= 100 and "%.0f" or (num >= 10 and "%.1f" or "%.2f")
    local formatted_num = string.format(format_spec, num)

    local left, right = formatted_num:match("^(%-?%d+)(%.%d+)$")
    if not left then left = formatted_num end

    left = left:reverse():gsub("(%d%d%d)", "%1,"):reverse()

    local str = right and left..right or left

    if str:sub(1, 1) == ',' then
      str = str:sub(2)
    end

    return str
end

function scoreNumberScale(scale, amt)
    scale = scale or 1

    if type(amt) ~= 'number' or amt >= (SWITCH_POINT or 100000000000) then
      return 0.7 * scale
    end

    if amt >= 1000000 then
      return 14 * 0.75 / (math.floor(math.log10(amt)) + 4) * scale
    end

    return 0.75 * scale
end

local cache = {texture = {}, audio = {}, font = {}}
function getTexture(name)
    if not cache.texture[name] then
        cache.texture[name] = love.graphics.newImage("resources/textures/" .. name .. ".png")
    end

    print(cache.texture[name])
    return cache.texture[name]
end

function getAudio(name)
    if not cache.audio[name] then
        cache.audio[name] = love.audio.newSource("resources/sounds/" .. name .. ".ogg", "static")
    end

    return cache.audio[name]
end

function getFont(name, size)
    if not cache.font[name] then
        cache.font[name] = {}
    end

    if not cache.font[name][size] then
        cache.font[name][size] = love.graphics.newFont("resources/fonts/" .. name .. ".ttf", size)
    end

    return cache.font[name][size]
end

function Hex(hex)
    if #hex <= 6 then hex = hex.."FF" end
    local _, _, r, g, b, a = hex:find('(%x%x)(%x%x)(%x%x)(%x%x)')
    return {tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, tonumber(a, 16) / 255}
end

COLOURS = {
    MULT = Hex('FE5F55'),
    CHIPS = Hex("009dff"),
    MONEY = Hex('f3b958'),
    XMULT = Hex('FE5F55'),
    FILTER = Hex('ff9a00'),
    BLUE = Hex("009dff"),
    RED = Hex('FE5F55'),
    GREEN = Hex("4BC292"),
    PALE_GREEN = Hex("56a887"),
    ORANGE = Hex("fda200"),
    IMPORTANT = Hex("ff9a00"),
    GOLD = Hex('eac058'),
    YELLOW = {1,1,0,1},
    CLEAR = {0, 0, 0, 0}, 
    WHITE = {1,1,1,1},
    PURPLE = Hex('8867a5'),
    BLACK = Hex("374244"),--4f6367"),
    L_BLACK = Hex("4f6367"),
    GREY = Hex("5f7377"),
    CHANCE = Hex("4BC292"),
    JOKER_GREY = Hex('bfc7d5'),
    VOUCHER = Hex("cb724c"),
    BOOSTER = Hex("646eb7"),
    EDITION = {1,1,1,1},
    DARK_EDITION = {0,0,0,1},
    ETERNAL = Hex('c75985'),
    PERISHABLE = Hex('4f5da1'),
    RENTAL = Hex('b18f43'),
    DYN_UI = {
        MAIN = Hex('374244'),
        DARK = Hex('374244'),
        BOSS_MAIN = Hex('374244'),
        BOSS_DARK = Hex('374244'),
        BOSS_PALE = Hex('374244')
    },
    --For other high contrast suit colours
    SO_1 = {
        Hearts = Hex('f03464'),
        Diamonds = Hex('f06b3f'),
        Spades = Hex("403995"),
        Clubs = Hex("235955"),
    },
    SO_2 = {
        Hearts = Hex('f83b2f'),
        Diamonds = Hex('e29000'),
        Spades = Hex("4f31b9"),
        Clubs = Hex("008ee6"),
    },
    SUITS = {
        Hearts = Hex('FE5F55'),
        Diamonds = Hex('FE5F55'),
        Spades = Hex("374649"),
        Clubs = Hex("424e54"),
    },
    UI = {
        TEXT_LIGHT = {1,1,1,1},
        TEXT_DARK = Hex("4F6367"),
        TEXT_INACTIVE = Hex("88888899"),
        BACKGROUND_LIGHT = Hex("B8D8D8"),
        BACKGROUND_WHITE = {1,1,1,1},
        BACKGROUND_DARK = Hex("7A9E9F"),
        BACKGROUND_INACTIVE = Hex("666666FF"),
        OUTLINE_LIGHT = Hex("D8D8D8"),
        OUTLINE_LIGHT_TRANS = Hex("D8D8D866"),
        OUTLINE_DARK = Hex("7A9E9F"),
        TRANSPARENT_LIGHT = Hex("eeeeee22"),
        TRANSPARENT_DARK = Hex("22222222"),
        HOVER = Hex('00000055'),
    },
    SET = {
        Default = Hex("cdd9dc"),
        Enhanced = Hex("cdd9dc"),
        Joker = Hex('424e54'),
        Tarot = Hex('424e54'),--Hex('29adff'),
        Planet = Hex("424e54"),
        Spectral = Hex('424e54'),
        Voucher = Hex("424e54"),
    }, 
    SECONDARY_SET = {
        Default = Hex("9bb6bdFF"),
        Enhanced = Hex("8389DDFF"),
        Joker = Hex('708b91'),
        Tarot = Hex('a782d1'),--Hex('29adff'),
        Planet = Hex('13afce'),
        Spectral = Hex('4584fa'),
        Voucher = Hex("fd682b"),
        Edition = Hex("4ca893"),
    }, 
    RARITY = {
        Hex('009dff'),--Hex("708b91"),
        Hex("4BC292"),
        Hex('fe5f55'),
        Hex("b26cbb")
    },
    BLIND = {
        Small = Hex("50846e"),
        Big = Hex("50846e"),
        Boss = Hex("b44430"),
        won = Hex("4f6367")
    },
    HAND_LEVELS = {
        Hex("efefef"),
        Hex("95acff"),
        Hex("65efaf"),
        Hex('fae37e'), 
        Hex('ffc052'), 
        Hex('f87d75'),
        Hex('caa0ef')
    },
    BACKGROUND = {
        L = {1,1,0,1},
        D = Hex("374244"),
        C = Hex("374244"),
        contrast = 1
    }
}
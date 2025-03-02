local allAmounts = {
    {300,  800,  2000,  5000,  11000,  20000,  35000,   50000 },
    {300,  900,  2600,  8000,  20000,  36000,  60000,   100000},
    {300,  1000, 3200,  9000,  25000,  60000,  110000,  200000}
}
-- A cleaned up function from the official game. It's a bit more readable now.
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

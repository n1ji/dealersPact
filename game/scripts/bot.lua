-- scripts/bot.lua

Bot = {}

function Bot:decide(hand)
    -- Simple bot logic: Discard cards with value less than 7
    local newHand = {}
    for _, card in ipairs(hand) do
        if card.value >= 7 then
            table.insert(newHand, card)
        end
    end
    return newHand
end
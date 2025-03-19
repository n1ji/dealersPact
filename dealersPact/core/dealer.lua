-- core/dealer.lua

Dealer = {}

function Dealer:new()
    local dealer = {
        hand = {},  -- The dealer's current hand of cards
        deck = {},  -- The dealer's deck of cards
    }
    setmetatable(dealer, self)
    self.__index = self
    return dealer
end

function Dealer:resetHand(game)
    -- Reset the dealer's hand at the start of each round
    self.hand = {}
    for i = 1, 5 do
        if #self.deck > 0 then
            local card = table.remove(self.deck, 1)
            if card then
                table.insert(self.hand, card)
                -- Debug: Print the card added to the dealer's hand
                print("Added card to dealer's hand:", card.name)
            else
                print("Warning: No more cards in the dealer's deck!")
                break
            end
        else
            print("Warning: Dealer's deck is empty!")
            break
        end
    end
end

function Dealer:playHand(game)
    -- Track if the dealer has played a resource card
    local hasPlayedResource = false

    -- Play cards based on the round number
    if game.roundNumber <= 5 then
        -- Random strategy for the first 5 rounds
        for _, card in ipairs(self.hand) do
            -- Always play at least 1 resource card
            if not hasPlayedResource and card.type == "resource" then
                game:applyResourceEffect(card)
                hasPlayedResource = true
            elseif math.random(2) == 1 then  -- 50% chance to play each card
                if card.type == "resource" then
                    game:applyResourceEffect(card)
                elseif card.type == "action" then
                    game:applyActionEffect(card)
                elseif card.type == "gamble" then
                    game:applyGambleEffect(card)
                end
            end
        end
    else
        -- Improved strategy after round 5
        for _, card in ipairs(self.hand) do
            -- Always play at least 1 resource card
            if not hasPlayedResource and card.type == "resource" then
                game:applyResourceEffect(card)
                hasPlayedResource = true
            -- Play resource cards
            elseif card.type == "resource" then
                game:applyResourceEffect(card)
            -- Play action and gamble cards with a higher probability
            elseif card.type == "action" or card.type == "gamble" then
                if math.random(3) <= 2 then  -- 66% chance to play action/gamble cards
                    game:applyActionEffect(card)
                    game:applyGambleEffect(card)
                end
            end
        end
    end
end

return Dealer
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
    print("Resetting dealer's hand. Current hand size: " .. #self.hand)
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
    print("Dealer is playing their hand...")
    -- Ensure the dealer has cards to play
    if #self.hand == 0 then
        print("Dealer has no cards to play! Drawing cards...")
        self:resetHand(game)  -- Reset the dealer's hand
    end

    -- Track if the dealer has played a card
    local hasPlayedCard = false

    -- Play cards based on the round number
    if game.roundNumber <= 5 then
        -- Early rounds: Play 1-2 cards, prioritizing resource cards
        for _, card in ipairs(self.hand) do
            if not hasPlayedCard and card.type == "resource" then
                print("Dealer playing resource card:", card.name)
                game:applyDealerResourceEffect(card)
                hasPlayedCard = true
            elseif math.random(2) == 1 then  -- 50% chance to play additional cards
                if card.type == "resource" then
                    print("Dealer playing resource card:", card.name)
                    game:applyDealerResourceEffect(card)
                elseif card.type == "action" then
                    print("Dealer playing action card:", card.name)
                    game:applyDealerActionEffect(card)
                elseif card.type == "gamble" then
                    print("Dealer playing gamble card:", card.name)
                    game:applyDealerGambleEffect(card)
                end
                hasPlayedCard = true
            end
        end
    else
        -- Later rounds: Play 2-3 cards, prioritizing stronger cards
        local cardsPlayed = 0
        for _, card in ipairs(self.hand) do
            if cardsPlayed < 2 or math.random(2) == 1 then  -- Play at least 2 cards, with a chance for more
                if card.type == "resource" then
                    print("Dealer playing resource card:", card.name)
                    game:applyDealerResourceEffect(card)
                elseif card.type == "action" then
                    print("Dealer playing action card:", card.name)
                    game:applyDealerActionEffect(card)
                elseif card.type == "gamble" then
                    print("Dealer playing gamble card:", card.name)
                    game:applyDealerGambleEffect(card)
                end
                cardsPlayed = cardsPlayed + 1
                hasPlayedCard = true
            end
        end
    end

    -- If no cards were played (unlikely), force the dealer to play one card
    if not hasPlayedCard then
        local card = self.hand[1]  -- Play the first card in the hand
        print("Dealer forced to play card:", card.name)
        if card.type == "resource" then
            game:applyDealerResourceEffect(card)
        elseif card.type == "action" then
            game:applyDealerActionEffect(card)
        elseif card.type == "gamble" then
            game:applyDealerGambleEffect(card)
        end
    end
end

return Dealer
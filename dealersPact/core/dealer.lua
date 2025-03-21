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

                -- Track the dealer's "dealer" card for the current round
                if card.type == "dealer" then
                    Game.dealerCurrentDealerCard = card
                end
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
    print("\nDealer is playing their hand...")

    -- Ensure the dealer has cards to play
    if #self.hand == 0 then
        print("Dealer has no cards to play! Drawing cards...")
        self:resetHand(game)  -- Reset the dealer's hand
    end

    -- Track the number of cards played
    local cardsPlayed = 0

    -- Determine the number of cards to play based on the round number
    local minCardsToPlay = 3
    local maxCardsToPlay = 3
    if game.roundNumber <= 2 then
        maxCardsToPlay = 3
    elseif game.roundNumber <= 4 then
        maxCardsToPlay = 5
    elseif game.roundNumber <= 6 then
        maxCardsToPlay = 7
    elseif game.roundNumber <= 9 then
        maxCardsToPlay = 10
    else
        maxCardsToPlay = 15
    end

    -- Shuffle the dealer's hand to randomize card selection
    self.hand = self:shuffleHand(self.hand)

    -- Play cards based on the round number
    for _, card in ipairs(self.hand) do
        if cardsPlayed >= maxCardsToPlay then
            break  -- Stop if the max number of cards has been played
        end

        print("Considering card:", card.name, "Type:", card.type)

        -- Play the card based on its type
        if card.type == "dealer" then
            print("Dealer playing dealer card:", card.name)
            game:applyDealerCardEffect(card)  -- Apply the dealer card effect
            cardsPlayed = cardsPlayed + 1
        elseif card.type == "resource" then
            print("Dealer playing resource card:", card.name)
            game:applyDealerResourceEffect(card)  -- Apply the resource card effect
            cardsPlayed = cardsPlayed + 1
        elseif card.type == "action" then
            print("Dealer playing action card:", card.name)
            game:applyDealerActionEffect(card)  -- Apply the action card effect
            cardsPlayed = cardsPlayed + 1
        elseif card.type == "gamble" then
            print("Dealer playing gamble card:", card.name)
            game:applyDealerGambleEffect(card)  -- Apply the gamble card effect
            cardsPlayed = cardsPlayed + 1
        end

        -- Ensure the dealer plays at least minCardsToPlay cards
        if cardsPlayed < minCardsToPlay then
            -- Force the dealer to play additional cards if needed
            for i = cardsPlayed + 1, minCardsToPlay do
                local forcedCard = self.hand[i]
                if forcedCard then
                    print("Dealer forced to play card:", forcedCard.name)
                    if forcedCard.type == "dealer" then
                        game:applyDealerCardEffect(forcedCard)
                    elseif forcedCard.type == "resource" then
                        game:applyDealerResourceEffect(forcedCard)
                    elseif forcedCard.type == "action" then
                        game:applyDealerActionEffect(forcedCard)
                    elseif forcedCard.type == "gamble" then
                        game:applyDealerGambleEffect(forcedCard)
                    end
                    cardsPlayed = cardsPlayed + 1
                else
                    break  -- Stop if there are no more cards to play
                end
            end
        end
    end

    -- If no cards were played (unlikely), force the dealer to play one card
    if cardsPlayed == 0 then
        local card = self.hand[1]  -- Play the first card in the hand
        print("Dealer forced to play card:", card.name)
        if card.type == "dealer" then
            game:applyDealerCardEffect(card)
        elseif card.type == "action" then
            game:applyDealerActionEffect(card)
        elseif card.type == "gamble" then
            game:applyDealerGambleEffect(card)
        elseif card.type == "resource" then
            game:applyDealerResourceEffect(card)
        end
        cardsPlayed = 1
    end

    print("Dealer played", cardsPlayed, "cards.")
end

function Dealer:shuffleHand(hand)
    for i = #hand, 2, -1 do
        local j = math.random(i)
        hand[i], hand[j] = hand[j], hand[i]
    end
    return hand
end

function Dealer:getStrongestCards()
    -- Sort the hand by card strength (assuming higher value means stronger)
    table.sort(self.hand, function(a, b)
        return (a.value or 0) > (b.value or 0)
    end)
    return self.hand
end

return Dealer
-- scripts/game.lua

Game = {
    state = "menu",  -- "menu", "card_pack_selection", or "playing"
    cardPack = nil,
    deck = {},
    players = {},
    currentPlayer = 1,
    newCardsButton = nil  -- Button for selecting new cards
}

function Game:start(cardPack)
    self.state = "playing"
    self.cardPack = cardPack

    -- Initialize the "New Cards" button
    self.newCardsButton = Button:new("New Cards", 100, 600, 200, 50, "new_cards", 10, 20)

    -- Initialize the deck and players
    self:initializeDeck()
    self:initializePlayers()
    self:dealCards()
end

function Game:update(dt)
    -- Update game logic (e.g., bot decisions)
    for _, player in ipairs(self.players) do
        for _, card in ipairs(player.hand) do
            card:update(dt)  -- Update the holographic overlay animation
        end
    end
end

function Game:initializeDeck()
    -- Create a deck of 52 cards
    self.deck = {}
    for suit = 1, 4 do
        for value = 1, 13 do
            table.insert(self.deck, Card:new(value, suit, self.cardPack))
        end
    end

    -- Seed the random number generator for better randomness
    math.randomseed(os.time())

    -- Shuffle the deck using the Fisher-Yates algorithm
    for i = #self.deck, 2, -1 do
        local j = math.random(i)
        self.deck[i], self.deck[j] = self.deck[j], self.deck[i]
    end
end

function Game:initializePlayers()
    self.players = {
        {name = "Player", hand = {}, isBot = false}
    }
end

function Game:dealCards()
    -- Deal 5 cards to each player
    for i = 1, 5 do
        for _, player in ipairs(self.players) do
            table.insert(player.hand, table.remove(self.deck, 1))
        end
    end
end

function Game:draw()
    -- Draw the game screen
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Game Screen - Card Pack: " .. self.cardPack, 20, 20)

    -- Draw each player's hand
    local cardWidth, cardHeight = 512, 768  -- Original card dimensions
    local scale = 0.35  -- Scaling factor
    local scaledWidth = cardWidth * scale
    local scaledHeight = cardHeight * scale
    local borderPadding = 60 * scale  -- Increased padding for larger text
    local startX, startY = 100, 100  -- Starting position for drawing cards

    for playerIndex, player in ipairs(self.players) do
        local x = startX
        local y = startY + (playerIndex - 1) * (scaledHeight + 2 * borderPadding + 20)  -- Offset each player's hand vertically

        for cardIndex, card in ipairs(player.hand) do
            -- Draw the card with the larger border and proper text alignment
            card:draw(x, y)
            x = x + scaledWidth + 2 * borderPadding + 10  -- Offset each card horizontally
        end
    end

    -- Draw the "New Cards" button
    if self.newCardsButton then
        self.newCardsButton:draw()
    end
end

function Game:handleMousePress(x, y, button)
    -- Handle mouse input during gameplay
    if self.newCardsButton and self.newCardsButton:isHovered(x, y) then
        self:reshuffleAndDeal()
    else
        -- Check if a card was clicked
        for _, player in ipairs(self.players) do
            for _, card in ipairs(player.hand) do
                local cardX, cardY = self:getCardPosition(card)
                local cardWidth, cardHeight = 512 * 0.35, 768 * 0.35  -- Scaled card dimensions
                local borderPadding = 60 * 0.35  -- Scaled border padding

                -- Check if the click is within the card's bounds
                if x >= cardX - borderPadding and x <= cardX + cardWidth + borderPadding and
                   y >= cardY - borderPadding and y <= cardY + cardHeight + borderPadding then
                    -- Toggle the card's flipped state
                    card:toggleFlip()
                end
            end
        end
    end
end

function Game:getCardPosition(card)
    -- Calculate the position of a card based on its index and player
    local cardWidth, cardHeight = 512 * 0.35, 768 * 0.35  -- Scaled card dimensions
    local borderPadding = 60 * 0.35  -- Scaled border padding
    local startX, startY = 100, 100  -- Starting position for drawing cards

    for playerIndex, player in ipairs(self.players) do
        for cardIndex, c in ipairs(player.hand) do
            if c == card then
                local x = startX + (cardIndex - 1) * (cardWidth + 2 * borderPadding + 10)
                local y = startY + (playerIndex - 1) * (cardHeight + 2 * borderPadding + 20)
                return x, y
            end
        end
    end
    return 0, 0
end

function Game:reshuffleAndDeal()
    -- Reshuffle the deck
    self:initializeDeck()

    -- Clear all players' hands
    for _, player in ipairs(self.players) do
        player.hand = {}
    end

    -- Deal new cards
    self:dealCards()
end
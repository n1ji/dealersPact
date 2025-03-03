-- scripts/game.lua

Game = {
    state = "menu",
    deck = {},
    dealerDeck = {},
    playerHand = {},
    dealerHand = {},
    soulEssence = 100,
    wheelOfFate = {},
    cardScale = 0.3,
    cardSpacing = 20,
    dealerStartX = 450,
    dealerStartY = 350,
    playerStartX = 450,
    playerStartY = 600,
    cardWidth = 512 * 0.3,
    cardHeight = 768 * 0.3,
    hoveredCard = nil,
    hoverFont = love.graphics.newFont("fonts/NotoSansBold.ttf", 14),
}

function Game:indexOf(table, element)
    for i, v in ipairs(table) do
        if v == element then
            return i
        end
    end
    return -1
end

function Game:initialize()
    math.randomseed(os.time())
    self:initializeDecks()
    self:initializeWheelOfFate()
    self:drawHands()
end

function Game:initializeDecks()
    self.deck = {}
    self.dealerDeck = {}

    -- Load cards from cards.lua
    local cards = require("scripts.cards")

    -- Add resource cards to player's deck
    for _, cardData in ipairs(cards.resourceCards) do
        table.insert(self.deck, Card:new("resource", cardData.name, cardData.effect))
    end

    -- Add action cards to player's deck
    for _, cardData in ipairs(cards.actionCards) do
        table.insert(self.deck, Card:new("action", cardData.name, cardData.effect))
    end

    -- Add gamble cards to player's deck
    for _, cardData in ipairs(cards.gambleCards) do
        table.insert(self.deck, Card:new("gamble", cardData.name, cardData.effect))
    end

    -- Add dealer cards to dealer's deck
    for _, cardData in ipairs(cards.dealerCards) do
        table.insert(self.dealerDeck, Card:new("dealer", cardData.name, cardData.effect))
    end

    self:shuffleDeck(self.deck)
    self:shuffleDeck(self.dealerDeck)
end

function Game:initializeWheelOfFate()
    local cards = require("scripts.cards")
    self.wheelOfFate = cards.wheelOfFate
end

function Game:shuffleDeck(deck)
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
end

function Game:drawHands()
    self.playerHand = {}
    self.dealerHand = {}
    for i = 1, 5 do
        table.insert(self.playerHand, table.remove(self.deck, 1))
        table.insert(self.dealerHand, table.remove(self.dealerDeck, 1))
    end
end

function Game:drawCard()
    if #self.deck > 0 then
        table.insert(self.playerHand, table.remove(self.deck, 1))
    else
        print("No more cards in the deck!")
    end
end

function Game:update(dt)
    -- Update hovered card
    local mouseX, mouseY = love.mouse.getPosition()
    self.hoveredCard = nil
    for i, card in ipairs(self.playerHand) do
        local cardX = self.playerStartX + (i - 1) * (self.cardWidth + self.cardSpacing)
        local cardY = self.playerStartY
        if mouseX >= cardX and mouseX <= cardX + self.cardWidth and
           mouseY >= cardY and mouseY <= cardY + self.cardHeight then
            self.hoveredCard = card
        end
    end
end

function Game:draw()
    love.graphics.clear(hexToRGB("#A77464"))
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont("fonts/NotoSansBold.ttf", 20))
    love.graphics.print("Soul Essence: " .. self.soulEssence, 20, 20)

    -- Draw player's hand
    for i, card in ipairs(self.playerHand) do
        local cardX = self.playerStartX + (i - 1) * (self.cardWidth + self.cardSpacing)
        local cardY = self.playerStartY
        card:draw(cardX, cardY)
    end

    -- Draw dealer's hand
    for i, card in ipairs(self.dealerHand) do
        local cardX = self.dealerStartX + (i - 1) * (self.cardWidth + self.cardSpacing)
        local cardY = self.dealerStartY - 200
        card:draw(cardX, cardY)
    end

    -- Draw hovered card details
    -- if self.hoveredCard then
    --     love.graphics.setColor(0, 0, 0, 0.8) -- Semi-transparent black background
    --     love.graphics.rectangle("fill", 10, 50, 300, 100)
    --     love.graphics.setColor(1, 1, 1) -- White text
    --     love.graphics.setFont(love.graphics.newFont(14))
    --     love.graphics.print("Card: " .. self.hoveredCard.name, 20, 60)
    --     love.graphics.print("Effect: " .. self.hoveredCard.effect, 20, 80)
    -- end
    -- Draw hovered card details

    if self.hoveredCard then
        local font = self.hoverFont
        local padding = 10 -- Padding around the text
        local maxWidth = 500 -- Maximum width of the hover box

        -- Split the effect text into multiple lines if it's too long
        local effectLines = {}
        local currentLine = ""
        for word in self.hoveredCard.effect:gmatch("%S+") do
            if font:getWidth(currentLine .. " " .. word) <= maxWidth then
                currentLine = currentLine .. " " .. word
            else
                table.insert(effectLines, currentLine)
                currentLine = word
            end
        end
        table.insert(effectLines, currentLine)

        -- Calculate the total height of the hover box
        local lineHeight = font:getHeight()
        local totalHeight = padding * 2 + lineHeight * (#effectLines + 1) -- +1 for the card name

        -- Draw the hover box background
        love.graphics.setColor(0, 0, 0, 0.8) -- Semi-transparent black background
        love.graphics.rectangle("fill", 10, 50, maxWidth + padding * 2, totalHeight)

        -- Draw the card name
        love.graphics.setColor(1, 1, 1) -- White text
        love.graphics.setFont(font)
        love.graphics.print("Card: " .. self.hoveredCard.name, 10 + padding, 50 + padding)

        -- Draw the effect lines
        love.graphics.print("Effect: " .. effectLines[1], 10 + padding, 50 + padding + lineHeight) -- First line with "Effect: "
        for i = 2, #effectLines do
            love.graphics.print(effectLines[i], 10 + padding, 50 + padding + lineHeight * (i + 1)) -- Subsequent lines without "Effect: "
        end
    end
end

function Game:handleMousePress(x, y, button)
    if button == 1 then
        for i, card in ipairs(self.playerHand) do
            local cardX = self.dealerStartX + (i - 1) * (self.cardWidth + self.cardSpacing)
            local cardY = self.dealerStartY
            if x >= cardX and x <= cardX + self.cardWidth and y >= cardY and y <= cardY + self.cardHeight then
                self:playCard(card)
            end
        end
    end
end

function Game:playCard(card)
    if card.type == "resource" then
        self:applyResourceEffect(card.effect)
    elseif card.type == "action" then
        self:applyActionEffect(card.effect)
    elseif card.type == "gamble" then
        self:applyGambleEffect(card.effect)
    end
    local index = self:indexOf(self.playerHand, card)
    if index ~= -1 then
        table.remove(self.playerHand, index)
    end
end

function Game:applyResourceEffect(effect)
    if effect == "+10 points" then
        self.soulEssence = self.soulEssence + 10
    elseif effect == "+5 points, Draw 1" then
        self.soulEssence = self.soulEssence + 5
        self:drawCard() -- Draw a card after gaining points
    -- Add more resource effects here
    end
end

function Game:applyActionEffect(effect)
    if effect == "Swap one of your cards with a random card from the Dealer's hand" then
        self:swapCardWithDealer()
    elseif effect == "Reroll the Wheel of Fate effect for this round" then
        self:spinWheelOfFate()
    -- Add more action effects here
    end
end

function Game:applyGambleEffect(effect)
    if effect == "Flip a coin: Heads, gain 20 points. Tails, lose 10 points" then
        if math.random(2) == 1 then
            self.soulEssence = self.soulEssence + 20
        else
            self.soulEssence = self.soulEssence - 10
        end
    -- Add more gamble effects here
    end
end

function Game:spinWheelOfFate()
    local effect = self.wheelOfFate[math.random(#self.wheelOfFate)]
    print("Wheel of Fate: " .. effect.name)
    -- Apply the effect
end

function Game:start(cardPack)
    self.cardPack = cardPack
    self.state = "playing"
    self:initialize()
end
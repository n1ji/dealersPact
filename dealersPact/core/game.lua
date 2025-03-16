-- core/game.lua

Game = {
    state = "menu",
    deck = {},
    dealerDeck = {},
    playerHand = {},
    dealerHand = {},
    soulEssence = 100,
    wheelOfFate = {},
    cardScale = 0.5,
    cardSpacing = 10,
    dealerStartX = 430,
    dealerStartY = 300,
    playerStartX = 430,
    playerStartY = 600,
    cardWidth = 338 * 0.5,
    cardHeight = 507 * 0.5,
    hoveredCard = nil,
    hoverFont = love.graphics.newFont("assets/fonts/NotoSansBold.ttf", 14),
    deckPosition = {x = 1400, y = 100},
    dealingAnimation = nil,
    maxHandSize = 5, -- Maximum number of cards in the player's hand
    shakeDuration = 0,
    shakeIntensity = 1.6,
    shakeOffset = {x = 0, y = 0},
    wheel = nil,
    screenWidth = love.graphics.getWidth(),
    screenHeight = love.graphics.getHeight(),
    musicVolume = 0.00,
    effectVolume = 0.5
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

    -- Load the deck and mask textures
    self.deckImage = love.graphics.newImage("assets/cards/back_lq.png")
    self.backMask = love.graphics.newImage("assets/cards/back_mask_lq.png")
    
    -- Load the gold shader
    self.goldShader = love.graphics.newShader("assets/shaders/gold.glsl")

    -- Send the mask texture to the shader
    self.goldShader:send("u_mask", self.backMask)

    -- Load other shaders (holo and rainbow)
    self.holoShader = love.graphics.newShader("assets/shaders/holo.glsl")
    self.holoShader:send("u_mask", self.backMask)
    self.rainbowShader = love.graphics.newShader("assets/shaders/rainbow.glsl")
    self.rainbowShader:send("u_mask", self.backMask)

    -- Initialize the options menu
    self.optionsMenu = require("states.options")
    self.optionsMenu:initialize()

    -- self.wheel = require("core.wheel")
    -- self.wheel:initialize(self.screenWidth, self.screenHeight)
end

function Game:initializeDecks()
    self.deck = {}
    self.dealerDeck = {}

    -- Load cards from cards.lua
    local cards = require("data.cards")

    -- Add resource cards to player's deck
    for _, cardData in ipairs(cards.resourceCards) do
        table.insert(self.deck, Card:new("resource_lq", cardData.name, cardData.effect, cardData.id))
    end

    -- Add action cards to player's deck
    for _, cardData in ipairs(cards.actionCards) do
        table.insert(self.deck, Card:new("action_lq", cardData.name, cardData.effect, cardData.id))
    end

    -- Add gamble cards to player's deck
    for _, cardData in ipairs(cards.gambleCards) do
        table.insert(self.deck, Card:new("gamble_lq", cardData.name, cardData.effect, cardData.id))
    end

    -- Add dealer cards to dealer's deck
    for _, cardData in ipairs(cards.dealerCards) do
        table.insert(self.dealerDeck, Card:new("dealer_lq", cardData.name, cardData.effect, cardData.id))
    end

    self:shuffleDeck(self.deck)
    self:shuffleDeck(self.dealerDeck)
end

function Game:initializeWheelOfFate()
    local cards = require("data.cards")
    self.wheelOfFate = cards.wheelOfFate
end

function Game:update(dt)
    -- Update hover state for options menu buttons
    if self.state == "settings" then
        local mouseX, mouseY = love.mouse.getPosition()
        self.optionsMenu:updateHoverState(mouseX, mouseY)
    end

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

    -- Update dealing animation
    if self.dealingAnimation then
        local card = self.dealingAnimation
        card.animationProgress = card.animationProgress + dt * 5 -- Draw speed
        if card.animationProgress >= 1 then
            card.animationProgress = 1
            table.insert(self.playerHand, card)
            self.dealingAnimation = nil
        end
    end

    -- Shake Animation
    if self.shakeDuration > 0 then
        self.shakeDuration = self.shakeDuration - dt
        self.shakeOffset.x = (math.random() - 0.5) * 2 * self.shakeIntensity
        self.shakeOffset.y = (math.random() - 0.5) * 2 * self.shakeIntensity
    else
        self.shakeOffset.x = 0
        self.shakeOffset.y = 0
    end

    -- Normalize the cursor position to [0, 1] range
    local cursorX = mouseX / love.graphics.getWidth()
    local cursorY = mouseY / love.graphics.getHeight()

    -- Update gold shader uniforms
    self.goldShader:send("u_time", love.timer.getTime())
    self.goldShader:send("u_resolution", {love.graphics.getWidth(), love.graphics.getHeight()})
    self.goldShader:send("u_cursor", {cursorX, cursorY})  -- Pass cursor position to the shader

    -- -- Update holo shader uniforms
    -- self.holoShader:send("u_time", love.timer.getTime())
    -- self.holoShader:send("u_resolution", {love.graphics.getWidth(), love.graphics.getHeight()})

    -- -- Update rainbow shader uniforms
    -- self.rainbowShader:send("time", love.timer.getTime())
    -- self.rainbowShader:send("u_resolution", {love.graphics.getWidth(), love.graphics.getHeight()})

    -- Update the wheel
    --self.wheel:update(dt)
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
        table.insert(self.dealerHand, table.remove(self.dealerDeck, 1))
    end
end

function Game:dealCard()
    -- Check if the player's hand is already full
    if #self.playerHand >= self.maxHandSize then
        print("Your hand is full! You can't draw more than 5 cards.")
        return
    end

    if #self.deck > 0 then
        local card = table.remove(self.deck, 1)
        card.x = self.deckPosition.x
        card.y = self.deckPosition.y
        card.targetX = self.playerStartX + (#self.playerHand) * (self.cardWidth + self.cardSpacing)
        card.targetY = self.playerStartY
        card.animationProgress = 0
        self.dealingAnimation = card
        card.sound:play()
    else
        print("No more cards in the deck!")
    end
end

function Game:draw()
    love.graphics.clear(hexToRGB("#1A1B3A"))
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont("assets/fonts/EnchantedLand.otf", 36))
    love.graphics.print("Soul Essence: " .. self.soulEssence, 20, 20)

    -- Draw deck with the rainbow shader
    love.graphics.setShader(self.goldShader)
    love.graphics.draw(self.deckImage, self.deckPosition.x + self.shakeOffset.x, self.deckPosition.y + self.shakeOffset.y, 0, self.cardScale, self.cardScale)
    love.graphics.setShader()

    -- Draw player's hand
    for i, card in ipairs(self.playerHand) do
        local cardX = self.playerStartX + (i - 1) * (self.cardWidth + self.cardSpacing)
        local cardY = self.playerStartY
        card:draw(cardX, cardY)
        card:drawText(cardX, cardY)
    end

    -- Draw dealer's hand
    for i, card in ipairs(self.dealerHand) do
        local cardX = self.dealerStartX + (i - 1) * (self.cardWidth + self.cardSpacing)
        local cardY = self.dealerStartY - 200
        card:draw(cardX, cardY)
    end

    -- Draw the card being dealt (if any)
    if self.dealingAnimation then
        local card = self.dealingAnimation
        local x = card.x + (card.targetX - card.x) * card.animationProgress
        local y = card.y + (card.targetY - card.y) * card.animationProgress
        card:draw(x, y)
        card:drawText(x, y)
    end

    -- Draw hovered card details
    if self.hoveredCard then
        love.graphics.setColor(1, 1, 1)
        local font = self.hoverFont
        local padding = 10
        local maxWidth = 290
        local maxBoxWidth = 320

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
        local totalHeight = padding * 2 + lineHeight * (#effectLines + 1)

        -- Draw the hover box background
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 10, 100, maxBoxWidth + 20 * 2, totalHeight - 15)
        love.graphics.setColor(1, 1, 1)

        -- Draw the effect lines
        love.graphics.setFont(font)
        love.graphics.print("Effect: " .. effectLines[1], 10 + padding, 100 + padding)
        for i = 2, #effectLines do
            love.graphics.print(effectLines[i], 10 + padding, 100 + padding * (i + 1))
        end
    end
--    self.wheel:draw()
end

function Game:handleMousePress(x, y, button)
    if button == 1 then
        -- Check if the deck was clicked
        if x >= self.deckPosition.x and x <= self.deckPosition.x + self.cardWidth and
           y >= self.deckPosition.y and y <= self.deckPosition.y + self.cardHeight then
            if self.dealingAnimation then
                return
            end

            if #self.playerHand >= self.maxHandSize then
                self.shakeDuration = 0.12
            else
                self:dealCard()
            end
        end

        -- Check if a card in the player's hand was clicked
        for i, card in ipairs(self.playerHand) do
            local cardX = self.playerStartX + (i - 1) * (self.cardWidth + self.cardSpacing)
            local cardY = self.playerStartY
            if x >= cardX and x <= cardX + self.cardWidth and y >= cardY and y <= cardY + self.cardHeight then
                self:playCard(card)
            end
        end

        --self.wheel:handleMousePress(x, y)
    end
end

function Game:playCard(card)
    if card.type == "resource" then
        self:applyResourceEffect(card)
    elseif card.type == "action" then
        self:applyActionEffect(card)
    elseif card.type == "gamble" then
        self:applyGambleEffect(card)
    end
    local index = self:indexOf(self.playerHand, card)
    if index ~= -1 then
        table.remove(self.playerHand, index)
    end
end

function Game:applyResourceEffect(card)
    if card.id == 1 then
        self.soulEssence = self.soulEssence + 10
    elseif card.id == 2 then
        self.soulEssence = self.soulEssence + 5
        self:dealCard()
    elseif card.id == 3 then
        self.soulEssence = self.soulEssence + 20
        self.SE = self.SE - 3
    elseif card.id == 4 then
        if self.dealerScore > self.soulEssence then
            self.soulEssence = self.soulEssence + 30
        else
            self.soulEssence = self.soulEssence + 15
        end
    elseif card.id == 5 then
        if self.SE >= 10 then
            self.soulEssence = self.soulEssence + 25
            self.SE = self.SE - 10
        end
    elseif card.id == 7 then
        self.soulEssence = self.soulEssence + 10
        self.reuseActionCard = true
    elseif card.id == 8 then
        self.soulEssence = self.soulEssence + 20
        -- Card is destroyed (no further action needed)
    elseif card.id == 9 then
        self.soulEssence = self.soulEssence + 10
        self.SE = self.SE + 3
    elseif card.id == 10 then
        if not self.playedGambleCard then
            self.soulEssence = self.soulEssence + 15
        end
    elseif card.id == 11 then
        self.soulEssence = self.soulEssence + 25
        self.dealerScore = self.dealerScore + 5
    elseif card.id == 12 then
        self.soulEssence = self.soulEssence + 10
        self:revealDealerCards(1)
    elseif card.id == 13 then
        if self.SE >= 5 then
            self.soulEssence = self.soulEssence + 30
            self.SE = self.SE - 5
            self.dealerScore = self.dealerScore - 5
        end
    elseif card.id == 14 then
        self.soulEssence = self.soulEssence + 5
        self.returnToHand = true
    elseif card.id == 15 then
        self.soulEssence = self.soulEssence + 15
        self.extraDrawOnWin = true
    elseif card.id == 16 then
        self.soulEssence = self.soulEssence + 10
        self.SE = self.SE + math.floor(self.soulEssence / 5)
    elseif card.id == 17 then
        self.soulEssence = self.soulEssence + 40
        self.SE = self.SE - 10
        self:discardRandomCard()
    elseif card.id == 18 then
        self.soulEssence = self.soulEssence + 15
        self:revealTopCard()
    elseif card.id == 19 then
        self.soulEssence = self.soulEssence + 5
        self:dealCard()
        self:discardRandomCard()
    elseif card.id == 20 then
        if self.SE >= 20 then
            self.soulEssence = self.soulEssence + 50
            self.SE = self.SE - 20
        end
    end
end

function Game:applyActionEffect(card)
    if card.id == 21 then
        self:swapCardWithDealer()
    elseif card.id == 23 then
        self:dealCard()
        self:dealCard()
    elseif card.id == 24 then
        if self.soulEssence >= 10 then
            self.soulEssence = self.soulEssence - 10
            self.SE = self.SE + 5
        end
    elseif card.id == 25 then
        self:revealDealerCards(2)
    elseif card.id == 26 then
        self:negateDealerCard()
    elseif card.id == 27 then
        self:playDealerCard()
    elseif card.id == 28 then
        self:undoLastCard()
    elseif card.id == 29 then
        self.dealerScore = self.dealerScore + 5
        self.soulEssence = self.soulEssence + 10
    elseif card.id == 30 then
        self.extraCardPlay = true
    elseif card.id == 31 then
        if self.SE >= 5 then
            self.SE = self.SE - 5
            self:stealDealerCard()
        end
    elseif card.id == 32 then
        local transferAmount = math.min(10, self.dealerScore)
        self.dealerScore = self.dealerScore - transferAmount
        self.soulEssence = self.soulEssence + transferAmount
    elseif card.id == 33 then
        self.SE = self.SE + 10
        self.soulEssence = self.soulEssence - 10
    elseif card.id == 35 then
        self:copyDealerCard()
    elseif card.id == 36 then
        if self.SE >= 5 then
            self.SE = self.SE - 5
            self:removeDealerCard()
        end
    elseif card.id == 37 then
        self:discardHand()
        for i = 1, 5 do
            self:dealCard()
        end
    elseif card.id == 38 then
        self:revealDealerHand()
    elseif card.id == 39 then
        self:swapHandsWithDealer()
    elseif card.id == 40 then
        self.dealerDisabled = true
    elseif card.id == 41 then
        self.dealerScore = self.dealerScore - 10
        self.soulEssence = self.soulEssence + 10
    elseif card.id == 43 then
        self.dealerSEDisabled = true
    elseif card.id == 44 then
        self:swapWithDiscard()
    elseif card.id == 45 then
        self.SE = self.SE + (5 * self.gambleCardsPlayed)
    end
end

function Game:applyGambleEffect(card)
    if card.id == 47 then
        if math.random(2) == 1 then
            self.soulEssence = self.soulEssence * 2
        else
            self.soulEssence = self.soulEssence / 2
        end
    elseif card.id == 48 then
        if self.SE >= 10 then
            self.SE = self.SE - 10
            if math.random(2) == 1 then
                self.SE = self.SE + 30
            end
        end
    elseif card.id == 49 then
        self:playRandomDealerCard()
    elseif card.id == 50 then
        for i = 1, 3 do
            self:dealCard()
        end
        for i = 1, 2 do
            self:discardRandomCard()
        end
    elseif card.id == 51 then
        local roll = math.random(6)
        if roll <= 3 then
            self.SE = self.SE - 10
        else
            self.SE = self.SE + 15
        end
    elseif card.id == 52 then
        if self.SE >= 5 then
            self.SE = self.SE - 5
            if math.random(2) == 1 then
                self.SE = self.SE + 10
            else
                self:discardRandomCard()
            end
        end
    elseif card.id == 53 then
        self.soulEssence = self.soulEssence + 50
        self.SE = self.SE - 20
    elseif card.id == 54 then
        if self.SE >= 10 then
            self.SE = self.SE - 10
            if math.random(2) == 1 then
                self.soulEssence = self.soulEssence * 2
            else
                self.soulEssence = self.soulEssence / 2
            end
        end
    elseif card.id == 55 then
        if self.SE >= 5 then
            self.SE = self.SE - 5
            if math.random(2) == 1 then
                self.SE = self.SE + 10
                self.dealerSE = self.dealerSE - 10
            else
                self.SE = self.SE - 10
                self.dealerSE = self.dealerSE + 10
            end
        end
    elseif card.id == 57 then
        self.soulEssence = self.soulEssence * 2
        self.doublePointsActive = true
    elseif card.id == 58 then
        if self.SE >= 5 then
            self.SE = self.SE - 5
            if math.random(2) == 1 then
                self.soulEssence = self.soulEssence + 15
            else
                self.soulEssence = self.soulEssence - 10
            end
        end
    elseif card.id == 59 then
        if self.SE >= 10 then
            self.SE = self.SE - 10
            if math.random(2) == 1 then
                self.SE = self.SE + 20
            else
                self.SE = self.SE - 15
            end
        end
    elseif card.id == 60 then
        local betAmount = self.SE
        if math.random(2) == 1 then
            self.SE = self.SE * 2
        else
            self.SE = 0
        end
    end
end

function Game:swapCardWithDealer()
    if #self.playerHand > 0 and #self.dealerHand > 0 then
        -- Choose a random card from the player's hand
        local playerCardIndex = math.random(#self.playerHand)
        local playerCard = self.playerHand[playerCardIndex]

        -- Choose a random card from the dealer's hand
        local dealerCardIndex = math.random(#self.dealerHand)
        local dealerCard = self.dealerHand[dealerCardIndex]

        -- Swap the cards
        self.playerHand[playerCardIndex] = dealerCard
        self.dealerHand[dealerCardIndex] = playerCard
    end
end

function Game:revealDealerCards(numCards)
    for i = 1, numCards do
        if #self.dealerDeck > 0 then
            local card = self.dealerDeck[1]
            table.remove(self.dealerDeck, 1)
            print("Revealed Dealer Card: " .. card.name)
        else
            print("No more cards in the dealer's deck!")
            break
        end
    end
end

function Game:discardRandomCard()
    if #self.playerHand > 0 then
        local randomIndex = math.random(#self.playerHand)
        table.remove(self.playerHand, randomIndex)
        print("Discarded a random card from the player's hand.")
    else
        print("Player's hand is empty!")
    end
end

function Game:revealTopCard()
    if #self.deck > 0 then
        local card = self.deck[1]
        print("Revealed Top Card: " .. card.name)
    else
        print("No more cards in the deck!")
    end
end

function Game:negateDealerCard()
    if self.lastDealerCard then
        print("Negated Dealer Card: " .. self.lastDealerCard.name)
        self.lastDealerCard = nil
    else
        print("No dealer card to negate!")
    end
end

function Game:playDealerCard()
    if #self.dealerHand > 0 then
        local randomIndex = math.random(#self.dealerHand)
        local card = self.dealerHand[randomIndex]
        self:applyDealerEffect(card.effect)
        print("Played Dealer Card: " .. card.name)
    else
        print("Dealer's hand is empty!")
    end
end

function Game:undoLastCard()
    if self.lastPlayedCard then
        print("Undid Last Card: " .. self.lastPlayedCard.name)
        self.lastPlayedCard = nil
    else
        print("No card to undo!")
    end
end

function Game:stealDealerCard()
    if #self.dealerHand > 0 then
        local randomIndex = math.random(#self.dealerHand)
        local card = table.remove(self.dealerHand, randomIndex)
        table.insert(self.playerHand, card)
        print("Stole Dealer Card: " .. card.name)
    else
        print("Dealer's hand is empty!")
    end
end

function Game:copyDealerCard()
    if self.lastDealerCard then
        local copiedCard = Card:new(self.lastDealerCard.type, self.lastDealerCard.name, self.lastDealerCard.effect)
        table.insert(self.playerHand, copiedCard)
        print("Copied Dealer Card: " .. copiedCard.name)
    else
        print("No dealer card to copy!")
    end
end

function Game:removeDealerCard()
    if #self.dealerHand > 0 then
        local randomIndex = math.random(#self.dealerHand)
        local card = table.remove(self.dealerHand, randomIndex)
        print("Removed Dealer Card: " .. card.name)
    else
        print("Dealer's hand is empty!")
    end
end

function Game:discardHand()
    self.playerHand = {}
    print("Discarded the player's entire hand.")
end

function Game:revealDealerHand()
    for i, card in ipairs(self.dealerHand) do
        print("Dealer Card " .. i .. ": " .. card.name)
    end
end

function Game:swapHandsWithDealer()
    local tempHand = self.playerHand
    self.playerHand = self.dealerHand
    self.dealerHand = tempHand
    print("Swapped hands with the dealer.")
end

function Game:spinWheelOfFate()
    local effect = self.wheelOfFate[math.random(#self.wheelOfFate)]
    print("Wheel of Fate: " .. effect.name)
end

function Game:start()
    self.state = "playing"
    self:initialize()

    -- Deal 5 cards to the player at the start of the game
    for i = 1, 5 do
        self:dealCard()
    end
end
-- core/game.lua

local utils = require("utils")
print("Utils loaded", utils)

Game = {
    state = "menu",
    deck = {},
    dealerDeck = {},
    playerHand = {},
    dealerHand = {},
    soulEssence = 20,
    dealerSE = 100,
    playerPoints = 0,  -- Track player's points for the current round
    dealerPoints = 0,  -- Track dealer's points for the current round
    wheelOfFate = {},
    cardScale = 0.5,
    cardSpacing = 10,
    dealerStartX = 430,
    dealerStartY = 300,
    playerStartX = 430,
    playerStartY = 580,
    cardWidth = 338 * 0.5,
    cardHeight = 507 * 0.5,
    hoveredCard = nil,
    hoverFont = love.graphics.newFont("assets/fonts/NotoSansBold.ttf", 14),
    deckPosition = {x = 1400, y = 100},
    dealingAnimation = nil,
    maxHandSize = 5,
    shakeDuration = 0,
    shakeIntensity = 1.6,
    shakeOffset = {x = 0, y = 0},
    wheel = nil,
    screenWidth = love.graphics.getWidth(),
    screenHeight = love.graphics.getHeight(),
    roundNumber = 1,
    canDrawCards = true,
    dealerCardsVisible = false,
    extraDrawOnWin = false,
    extraDrawCards = 0,
    gambleCardsPlayed = 0,
    silver = "#C0C0C0",
    dealerCurrentDealerCard = nil
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

    self.soulEssence = 2
    self.dealerSE = 100
    self.playerPoints = 0
    self.dealerPoints = 0

    -- Initialize the dealer
    self.dealer = require("core.dealer"):new()
    self.dealer.deck = self.dealerDeck  -- Share the dealer's deck

    -- Initialize the dealer's hand
    self.dealer:resetHand(self)

    -- Initialize the timer
    self.timer = utils.Timer:new()

    -- Debug: Print the utils table
    print("Utils loaded:", utils)

    -- Load the deck and mask textures
    self.deckImage = love.graphics.newImage("assets/cards/back_lq.png")
    self.backMask = love.graphics.newImage("assets/cards/back_mask_lq.png")

    self.dealerBack = love.graphics.newImage("assets/cards/dealer1.png")
    
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

    local Button = require("ui.button")
    self.playButton = Button:new("Play Hand", love.graphics.getWidth() / 2 - 20, self.playerStartY - 70, 100, 50, function() self:completeRound() end, 20, 10)

    -- Add replay button
    self.replayButton = Button:new("Replay", love.graphics.getWidth() / 2 - 50, love.graphics.getHeight() / 2 + 150, 120, 50, function()
        self:resetGame()  -- Reset the game state
        self:goToMainMenu()  -- Go back to the main menu
    end, 20, 10)

    -- self.wheel = require("core.wheel")
    -- self.wheel:initialize(self.screenWidth, self.screenHeight)
end

function Game:initializeDecks()
    self.deck = {}
    self.dealerDeck = {}

    -- Load cards from cards.lua
    local cards = require("data.cards")

    -- add to player deck
    for _, cardData in ipairs(cards.resourceCards) do
        table.insert(self.deck, Card:new("resource", cardData.name, cardData.effect, cardData.id))
    end

    for _, cardData in ipairs(cards.actionCards) do
        table.insert(self.deck, Card:new("action", cardData.name, cardData.effect, cardData.id))
    end

    for _, cardData in ipairs(cards.gambleCards) do
        table.insert(self.deck, Card:new("gamble", cardData.name, cardData.effect, cardData.id))
    end

    -- add to dealer deck
    for _, cardData in ipairs(cards.dealerCards) do
        table.insert(self.dealerDeck, Card:new("dealer", cardData.name, cardData.effect, cardData.id))
    end
    
    for _, cardData in ipairs(cards.resourceCards) do
        table.insert(self.dealerDeck, Card:new("dealer", cardData.name, cardData.effect, cardData.id))
    end

    for _, cardData in ipairs(cards.actionCards) do
        table.insert(self.dealerDeck, Card:new("dealer", cardData.name, cardData.effect, cardData.id))
    end

    for _, cardData in ipairs(cards.gambleCards) do
        table.insert(self.dealerDeck, Card:new("dealer", cardData.name, cardData.effect, cardData.id))
    end

    self:shuffleDeck(self.deck)
    self:shuffleDeck(self.dealerDeck)

    print("Dealer's deck initialized with " .. #self.dealerDeck .. " cards.")
    print("Player's deck initialized with " .. #self.deck .. " cards.")
end

function Game:initializeWheelOfFate()
    local cards = require("data.cards")
    self.wheelOfFate = cards.wheelOfFate
end

function Game:update(dt)
    local mouseX, mouseY = love.mouse.getPosition()

    -- Check for game over condition
    if self.soulEssence <= 0 then
        self.state = "gameOver"
    end

    -- Update timers
    self.timer:updateTimers(dt)

    -- Update hover state for options menu buttons
    if self.state == "settings" then
        self.optionsMenu:updateHoverState(mouseX, mouseY)
    end

    self.playButton.hovered = self.playButton:isHovered(mouseX, mouseY)
    self.replayButton.hovered = self.replayButton:isHovered(mouseX, mouseY)

    -- Update hovered card
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
        card.animationProgress = card.animationProgress + dt * 7 -- draw speed
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
    -- Check if the player's hand is already full or if drawing is disabled
    if #self.playerHand >= self.maxHandSize or not self.canDrawCards then
        print("Your hand is full or drawing is disabled!")
        return
    end

    -- Count the number of gamble and action cards in the player's hand
    local gambleCount = 0
    local actionCount = 0
    -- for _, card in ipairs(self.playerHand) do
    --     if card.type == "gamble" then
    --         gambleCount = gambleCount + 1
    --     elseif card.type == "action" then
    --         actionCount = actionCount + 1
    --     end
    -- end

    if #self.deck > 0 then
        local card = table.remove(self.deck, 1)

        -- Check if the card exceeds the allowed limits
        if (card.type == "gamble" and gambleCount >= 2) or (card.type == "action" and actionCount >= 2) then
            -- If the card exceeds the limit, put it back in the deck and try again
            table.insert(self.deck, card)
            self:dealCard()  -- Try drawing another card
            return
        end

        card.x = self.deckPosition.x
        card.y = self.deckPosition.y
        card.targetX = self.playerStartX + (#self.playerHand) * (self.cardWidth + self.cardSpacing)
        card.targetY = self.playerStartY
        card.animationProgress = 0
        self.dealingAnimation = card
        card.sound:play()

        -- Debug: Print the card being drawn
        print("Drew card:", card.name .. "ID:" .. card.id)

        -- Disable drawing until the current card's animation is complete
        self.canDrawCards = false
        self.timer:setTimer(function()
            self.canDrawCards = true
        end, card.animationProgress)  -- Adjust the delay time as needed
    else
        print("No more cards in the deck!")
    end
end

function Game:draw()
    love.graphics.clear(hexToRGB("#2e1115")) --bg
    love.graphics.setColor(hexToRGB(self.silver))
    love.graphics.setFont(love.graphics.newFont("assets/fonts/EnchantedLand.otf", 36))

    if self.state == "gameOver" then
        -- Display "Game Over" in the center of the screen
        local gameOverText = "Game Over"
        local dealerWinsText = "Dealer Wins!"
        local reasonText = "Dealer's Card: " .. (self.lastDealerCard and self.lastDealerCard.name or "Unknown")
        local font = love.graphics.newFont("assets/fonts/EnchantedLand.otf", 72)
        love.graphics.setFont(font)
        local textWidth = font:getWidth(gameOverText)
        local textHeight = font:getHeight(gameOverText)
        love.graphics.print(gameOverText, (love.graphics.getWidth() - textWidth) / 2, (love.graphics.getHeight() - textHeight) / 2 - 150)
        
        font = love.graphics.newFont("assets/fonts/EnchantedLand.otf", 48)
        love.graphics.setFont(font)
        textWidth = font:getWidth(dealerWinsText)
        textHeight = font:getHeight(dealerWinsText)
        love.graphics.print(dealerWinsText, (love.graphics.getWidth() - textWidth) / 2, (love.graphics.getHeight() - textHeight) / 2 - 80)
        
        font = love.graphics.newFont("assets/fonts/EnchantedLand.otf", 36)
        love.graphics.setFont(font)
        textWidth = font:getWidth(reasonText)
        textHeight = font:getHeight(reasonText)
        love.graphics.print(reasonText, (love.graphics.getWidth() - textWidth) / 2, (love.graphics.getHeight() - textHeight) / 2 )

        -- Display the dealer's "dealer" card description
        if self.lastDealerCard then
            -- local cardName = "Dealer's Card: " .. self.lastDealerCard.name
            local cardEffect = "Effect: " .. self.lastDealerCard.effect

            -- Split the effect text into multiple lines if it's too long
            local effectLines = {}
            local currentLine = ""
            for word in cardEffect:gmatch("%S+") do
                if font:getWidth(currentLine .. " " .. word) <= 600 then
                    currentLine = currentLine .. " " .. word
                else
                    table.insert(effectLines, currentLine)
                    currentLine = word
                end
            end
            table.insert(effectLines, currentLine)

            -- Draw the card name
            -- love.graphics.print(cardName, (love.graphics.getWidth() - font:getWidth(cardName)) / 2, (love.graphics.getHeight() - textHeight) / 2 + 40)

            -- Draw the effect lines
            for i, line in ipairs(effectLines) do
                love.graphics.print(line, (love.graphics.getWidth() - font:getWidth(line)) / 2, (love.graphics.getHeight() - textHeight) / 2 + 60 + (i - 1) * 30)
            end
        else
            -- Debug: Print a message if the dealer's "dealer" card is not set
            print("No dealer's dealer card found for the game over screen.")
        end
        
        -- Draw replay button
        self.replayButton:draw()
        
        return
    end

    if self.state == "playerWins" then
        -- Display "You Beat the Dealer!" in the center of the screen
        local winText = "You Beat the Dealer!"
        local finalSEText = "Final Soul Essence: " .. self.soulEssence
        local finalScoreText = "Total Score: " .. self.playerPoints
        local font = love.graphics.newFont("assets/fonts/EnchantedLand.otf", 72)
        love.graphics.setFont(font)
        local textWidth = font:getWidth(winText)
        local textHeight = font:getHeight(winText)
        love.graphics.print(winText, (love.graphics.getWidth() - textWidth) / 2, (love.graphics.getHeight() - textHeight) / 2 - 50)
        
        font = love.graphics.newFont("assets/fonts/EnchantedLand.otf", 48)
        love.graphics.setFont(font)
        textWidth = font:getWidth(finalSEText)
        textHeight = font:getHeight(finalSEText)
        love.graphics.print(finalSEText, (love.graphics.getWidth() - textWidth) / 2, (love.graphics.getHeight() - textHeight) / 2 + 20)
        
        textWidth = font:getWidth(finalScoreText)
        textHeight = font:getHeight(finalScoreText)
        love.graphics.print(finalScoreText, (love.graphics.getWidth() - textWidth) / 2, (love.graphics.getHeight() - textHeight) / 2 + 80)
        
        -- Draw replay button
        self.replayButton:draw()
        
        return
    end

    -- draw stats
    local halfScreen = love.graphics.getHeight() / 2
    love.graphics.setColor(hexToRGB("#222222"))
    love.graphics.rectangle("fill", 10, 0, 300, 960)
    love.graphics.setColor(hexToRGB("#1A1B3A"))
    love.graphics.polygon("fill", 10, halfScreen + 30, 310, halfScreen - 30, 310, 960, 10, 960) -- bottom
    love.graphics.setColor(hexToRGB("#4E2A84"))
    love.graphics.polygon("fill", 10, halfScreen - 30, 310, halfScreen - 90, 310, halfScreen - 30, 10, halfScreen + 30) -- stripe 1
    love.graphics.setColor(hexToRGB("#CF5C36"))
    --love.graphics.polygon("fill", 10, halfScreen - 90, 310, halfScreen - 150, 310, halfScreen - 90, 10, halfScreen - 30) -- stripe 2
    love.graphics.setColor(hexToRGB(self.silver))
    
    love.graphics.print("Soul Essence: " .. self.soulEssence, 30, 525)
    love.graphics.print("Score: " .. self.playerPoints, 30, 565)
    love.graphics.print("Round: " .. self.roundNumber, 30, 605)

    love.graphics.print("Dealer Soul Essence: " .. self.dealerSE, 30, 20)
    love.graphics.print("Dealer Score: " .. self.dealerPoints, 30, 60)

    -- Draw the dealer's "dealer" card name and description
    if self.dealerCurrentDealerCard then
        love.graphics.setFont(love.graphics.newFont("assets/fonts/EnchantedLand.otf", 24))
        love.graphics.print("Dealer's Card:", 30, 120)
        love.graphics.print(self.dealerCurrentDealerCard.name, 30, 160)

        -- Split the effect text into multiple lines if it's too long
        local effectLines = {}
        local currentLine = ""
        for word in self.dealerCurrentDealerCard.effect:gmatch("%S+") do
            if love.graphics.getFont():getWidth(currentLine .. " " .. word) <= 250 then
                currentLine = currentLine .. " " .. word
            else
                table.insert(effectLines, currentLine)
                currentLine = word
            end
        end
        table.insert(effectLines, currentLine)

        -- Draw the effect lines
        for i, line in ipairs(effectLines) do
            love.graphics.print(line, 30, 200 + (i - 1) * 30)
        end
    end

    -- draw shader
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
    for i, card in ipairs(self.dealer.hand) do
        local cardX = self.dealerStartX + (i - 1) * (self.cardWidth + self.cardSpacing)
        local cardY = self.dealerStartY - 200
        if self.dealerCardsVisible or card.type == "dealer" then
            -- Draw the actual card if dealerCardsVisible is true or if it's a "dealer" card
            card:draw(cardX, cardY)
            -- card:drawText(cardX, cardY)

            if card.type == "dealer" then
            end
        else
            -- Draw the placeholder back image if dealerCardsVisible is false
            love.graphics.setShader(self.goldShader)
            love.graphics.draw(self.deckImage, cardX, cardY, 0, self.cardScale, self.cardScale)
            love.graphics.setShader()
        end
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
        local lineHeight = font:getHeight()
        local boxPosY = self.playerStartY + self.cardHeight + 20
        local boxPosX = love.graphics.getWidth() / 2 - maxBoxWidth / 2
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
        
        local totalHeight = padding * 2 + lineHeight * (#effectLines + 1)

        -- Draw the hover box background
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", boxPosX, boxPosY, maxBoxWidth + 20 * 2, totalHeight - 15)
        love.graphics.setColor(1, 1, 1)

        -- Draw the effect lines
        love.graphics.setFont(font)
        love.graphics.print("Effect: " .. effectLines[1], boxPosX + padding, boxPosY + padding)
        for i = 2, #effectLines do
            love.graphics.print(effectLines[i], boxPosX + padding, boxPosY + padding * (i + 1))
        end
    end

    -- Draw play button
    self.playButton:draw()
end

function Game:handleMousePress(x, y, button)
    print("Mouse clicked at:", x, y)
    -- if self.state ~= "playing" then
    --     return
    -- end

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

        -- Check if the "Play Hand" button was clicked
        if self.playButton:isHovered(x, y) then
            self.playButton.action()  -- Call the button's action
        end

        -- Check if the replay button was clicked
        if self.replayButton:isHovered(x, y) then
            self.replayButton.action()  -- Call the replay button's action
        end
    end
end

function Game:completeRound()
    -- Reset gamble cards played counter
    self.gambleCardsPlayed = 0

    -- Debug: Print the dealer's hand before playing
    print("\n\nDealer's hand before playing:")
    for i, card in ipairs(self.dealer.hand) do
        print("Card " .. i .. ": " .. card.name)
    end

    -- Dealer plays their hand first
    self.dealer:playHand(self)

    -- Debug: Print the dealer's hand after playing
    print("\nDealer's hand after playing:")
    for i, card in ipairs(self.dealer.hand) do
        print("Card " .. i .. ": " .. card.name)
    end

    -- Debug: Print dealer's points and SE after playing their hand
    print("Dealer Points after playing hand: " .. self.dealerPoints)
    print("Dealer SE after playing hand: " .. self.dealerSE .. "\n")

    -- Calculate the total points from the player's hand (only if the player has played cards)
    if #self.playerHand > 0 then
        for _, card in ipairs(self.playerHand) do
            if card.played then  -- Only process cards that have been explicitly played
                if card.type == "resource" then
                    self:applyResourceEffect(card)
                elseif card.type == "action" then
                    self:applyActionEffect(card)
                elseif card.type == "gamble" then
                    self:applyGambleEffect(card)
                end
            end
        end
    end

    -- Debug: Print player points
    print("Player Points after applying effects: " .. self.playerPoints)

    -- Update soul essence based on the round outcome
    if self.playerPoints > self.dealerPoints then
        self.soulEssence = self.soulEssence + self.playerPoints
        print("Player wins! Gained " .. self.playerPoints .. " soul essence.\n")

        -- Check if an extra card should be drawn
        if self.extraDrawOnWin then
            print("Extra card will be drawn next round due to Gambler’s Favor.")
            self.extraDrawOnWin = false  -- Reset the flag
            self.extraDrawNextRound = true  -- Set a flag for the next round
        end
    elseif self.dealerPoints > self.playerPoints then
        self.soulEssence = self.soulEssence - self.dealerPoints
        print("Dealer wins! Lost " .. self.dealerPoints .. " soul essence.\n")
    else
        print("It's a tie! No change in soul essence.\n")
    end

    -- Check for game over condition
    if self.soulEssence <= 0 then
        self.state = "gameOver"
        return
    end

    -- Check for player win condition
    if self.roundNumber >= 10 then
        self.state = "playerWins"
        return
    end

    -- Make dealer cards visible
    self.dealerCardsVisible = true  -- Set this flag to true to reveal dealer's cards

    -- Reset the player's hand for the next round
    self.playerHand = {}

    -- Reset the dealer's hand for the next round
    self.dealer:resetHand(self)

    -- Reset points for the next round
    self.playerPoints = 0
    self.dealerPoints = 0

    -- Increment the round number
    self.roundNumber = self.roundNumber + 1

    -- Start dealing cards for the next round
    local numCards = 5
    if self.extraDrawNextRound then
        numCards = numCards + self.extraDrawCards  -- Draw an extra card
        self.extraDrawNextRound = false  -- Reset the flag
    end
    self:startDealingCards(numCards)

    print("---\nRound: " .. self.roundNumber .. "\n---")
end

function Game:startDealingCards(numCards)
    -- Disable drawing cards manually while dealing
    self.canDrawCards = false

    -- Reset the dealer's "dealer" card for the new round
    self.dealerCurrentDealerCard = nil

    -- Use a timer to deal cards with a delay
    for i = 1, numCards do
        self.timer:setTimer(function()
            -- Enable drawing for this card
            self.canDrawCards = true
            self:dealCard()
            self.canDrawCards = false
        end, (i - 1) * 0.2)
    end

    -- Re-enable drawing after all cards are dealt
    self.timer:setTimer(function()
        self.canDrawCards = true
    end, numCards * 0.5)
end

function Game:playCard(card)
    if card.type == "resource" then
        self:calculateResourcePoints(card)
    elseif card.type == "action" then
        self:applyActionEffect(card)
    elseif card.type == "gamble" then
        self:applyGambleEffect(card)
    end

    -- Mark the card as played
    card.played = true

    -- Remove the card from the player's hand
    local index = self:indexOf(self.playerHand, card)
    if index ~= -1 then
        table.remove(self.playerHand, index)
    end
end

function Game:calculateResourcePoints(card)
    -- Store the current soulEssence value
    local originalSoulEssence = self.soulEssence
    local originalPlayerPoints = self.playerPoints

    -- Apply the resource effect to calculate the points
    self:applyResourceEffect(card)

    -- Calculate the difference in soulEssence after applying the effect
    local SE = self.soulEssence - originalSoulEssence
    local playerPoints = self.playerPoints - originalPlayerPoints
    -- Debug: Print the calculated points
    print("Calculated SE for card " .. card.name .. ": " .. SE)
    print("Player points: " .. playerPoints)

    -- Return the calculated points
    return SE
end







function Game:applyResourceEffect(card)
    print("Applying resource effect for card:", card.name, "ID:", card.id)
    print("SE: ", self.soulEssence)
    print("Player: ", self.playerPoints)
    print("Dealer: ", self.dealerPoints)

    if card.id == 1 then
        self.playerPoints = self.playerPoints + 10
    elseif card.id == 2 then
        self.playerPoints = self.playerPoints + 5
        self:dealCard()
    elseif card.id == 3 then
        if self.soulEssence < 3 then
            print("Not enough SE to play this card!")
            return
        else
            self.playerPoints = self.playerPoints + 20
            self.soulEssence = self.soulEssence - 3
        end
    elseif card.id == 4 then
        if self.dealerPoints > self.playerPoints then
            self.playerPoints = self.playerPoints + 30
        else
            self.playerPoints = self.playerPoints + 15
        end
    elseif card.id == 5 then
        if self.soulEssence >= 10 then
            self.playerPoints = self.playerPoints + 25
            self.soulEssence = self.soulEssence - 10
        end
    elseif card.id == 7 then
        self.playerPoints = self.playerPoints + 10
        self.reuseActionCard = true
    elseif card.id == 8 then
        self.playerPoints = self.playerPoints + 20
        -- Card is destroyed (no further action needed)
    elseif card.id == 9 then
        self.playerPoints = self.playerPoints + 10
        self.soulEssence = self.soulEssence - 3
    elseif card.id == 10 then
        if not self.playedGambleCard then
            self.playerPoints = self.playerPoints + 15
        end
    elseif card.id == 11 then
        self.playerPoints = self.playerPoints + 25
        self.dealerPoints = self.dealerPoints + 5
    elseif card.id == 12 then
        self.playerPoints = self.playerPoints + 10
        self:revealDealerCards(1)
    elseif card.id == 13 then
        if self.soulEssence >= 5 then
            self.playerPoints = self.playerPoints + 30
            self.soulEssence = self.soulEssence - 5
            self.dealerPoints = self.dealerPoints - 5
        end
    elseif card.id == 14 then
        self.playerPoints = self.playerPoints + 5
        self.returnToHand = true
    elseif card.id == 15 then
        self.playerPoints = self.playerPoints + 15
        self.extraDrawOnWin = true
    elseif card.id == 16 then
        self.playerPoints = self.playerPoints + 10
        self.soulEssence = self.soulEssence + math.floor(self.playerPoints / 5)
    elseif card.id == 17 then
        if self.soulEssence < 10 then
            print("Not enough SE to play this card!")
            return
        else
            self.playerPoints = self.playerPoints + 40
            self.soulEssence = self.soulEssence - 10
            self:discardRandomCard()
        end
    elseif card.id == 18 then
        self.playerPoints = self.playerPoints + 15
        self:revealTopCard()
    elseif card.id == 19 then
        self.playerPoints = self.playerPoints + 5
        self:dealCard()
        self:discardRandomCard()
    elseif card.id == 20 then
        if self.soulEssence >= 20 then
            self.playerPoints = self.playerPoints + 50
            self.soulEssence = self.soulEssence - 20
        end
    end

    -- Debug: Print updated values
    print("Updated SE: ", self.soulEssence)
    print("Updated Player Points: ", self.playerPoints)
end

function Game:applyActionEffect(card)
    if card.id == 21 then
        self:swapCardWithDealer()
    elseif card.id == 23 then
        self.canDrawCards = true
        for i = 1, 2 do
            self.timer:setTimer(function()
                -- Enable drawing for this card
                self.canDrawCards = true
                self:dealCard()
                self.canDrawCards = false
            end, (i - 1) * 0.2)
        end
    elseif card.id == 24 then
        if self.soulEssence >= 10 then
            self.soulEssence = self.soulEssence - 10
            self.playerPoints = self.playerPoints + 5
        end
    elseif card.id == 25 then
        self:revealDealerCards(2)
    elseif card.id == 26 then
        self:negateDealerCard()
    elseif card.id == 27 then  -- Shadow Play
        print("Attempting to play Shadow Play...")
        if #self.dealer.hand > 0 then
            local randomIndex = math.random(#self.dealer.hand)
            local dealerCard = self.dealer.hand[randomIndex]
            print("Playing Dealer Card: " .. dealerCard.name)
            self:applyDealerEffect(dealerCard.effect)
        else
            print("Dealer's hand is empty!")
        end
    elseif card.id == 28 then
        self:undoLastCard()
    elseif card.id == 29 then
        self.dealerPoints = self.dealerPoints + 5
        self.playerPoints = self.playerPoints + 10
    elseif card.id == 30 then
        self.extraCardPlay = true
    elseif card.id == 31 then
        if self.soulEssence >= 5 then
            self.soulEssence = self.soulEssence - 5
            self:stealDealerCard()
        end
    elseif card.id == 32 then
        local transferAmount = math.min(10, self.dealerPoints)
        self.dealerPoints = self.dealerPoints - transferAmount
        self.playerPoints = self.playerPoints + transferAmount
    elseif card.id == 33 then
        if self.playerPoints < 10 then
            print("Not enough SE to play this card!")
            return
        else
            self.soulEssence = self.soulEssence + 10
            self.playerPoints = self.playerPoints - 10
        end
    elseif card.id == 35 then
        self:copyDealerCard()
    elseif card.id == 36 then
        if self.soulEssence >= 5 then
            self.soulEssence = self.soulEssence - 5
            self:removeDealerCard()
        end
    elseif card.id == 37 then
        self:discardHand()
        self:startDealingCards(5)
    elseif card.id == 38 then
        self:revealDealerHand()
    elseif card.id == 39 then
        self:swapHandsWithDealer()
    elseif card.id == 40 then
        self.dealerDisabled = true
    elseif card.id == 41 then
        self.dealerPoints = self.dealerPoints - 10
        self.playerPoints = self.playerPoints + 10
    elseif card.id == 43 then
        self.dealerSEDisabled = true
    elseif card.id == 44 then
        self:swapWithDiscard()
    elseif card.id == 45 then
        self.soulEssence = self.soulEssence + (5 * self.gambleCardsPlayed)
    end
end

function Game:applyGambleEffect(card)
    self.gambleCardsPlayed = self.gambleCardsPlayed + 1  -- Increment the counter
    if card.id == 47 then
        if math.random(2) == 1 then
            self.playerPoints = self.playerPoints * 2
        else
            self.playerPoints = self.playerPoints / 2
        end
    elseif card.id == 48 then
        if self.soulEssence >= 10 then
            self.soulEssence = self.soulEssence - 10
            if math.random(2) == 1 then
                self.soulEssence = self.soulEssence + 30
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
            self.soulEssence = self.soulEssence - 10
        else
            self.soulEssence = self.soulEssence + 15
        end
    elseif card.id == 52 then
        if self.soulEssence >= 5 then
            self.soulEssence = self.soulEssence - 5
            if math.random(2) == 1 then
                self.soulEssence = self.soulEssence + 10
            else
                self:discardRandomCard()
            end
        end
    elseif card.id == 53 then
        self.playerPoints = self.playerPoints + 50
        self.soulEssence = self.soulEssence - 20
    elseif card.id == 54 then
        if self.soulEssence >= 10 then
            self.soulEssence = self.soulEssence - 10
            if math.random(2) == 1 then
                self.playerPoints = self.playerPoints * 2
            else
                self.playerPoints = self.playerPoints / 2
            end
        end
    elseif card.id == 55 then
        if self.soulEssence >= 5 then
            self.soulEssence = self.soulEssence - 5
            if math.random(2) == 1 then
                self.soulEssence = self.soulEssence + 10
                self.dealerSE = self.dealerSE - 10
            else
                self.soulEssence = self.soulEssence - 10
                self.dealerSE = self.dealerSE + 10
            end
        end
    elseif card.id == 57 then
        self.playerPoints = self.playerPoints * 2
        self.doublePointsActive = true
    elseif card.id == 58 then
        if self.soulEssence >= 5 then
            self.soulEssence = self.soulEssence - 5
            if math.random(2) == 1 then
                self.playerPoints = self.playerPoints + 15
            else
                self.playerPoints = self.playerPoints - 10
            end
        end
    elseif card.id == 59 then
        if self.soulEssence >= 10 then
            self.soulEssence = self.soulEssence - 10
            if math.random(2) == 1 then
                self.soulEssence = self.soulEssence + 20
            else
                self.soulEssence = self.soulEssence - 15
            end
        end
    elseif card.id == 60 then
        local betAmount = self.soulEssence
        if math.random(2) == 1 then
            self.soulEssence = self.soulEssence * 2
        else
            self.soulEssence = 0
        end
    end
end

function Game:applyDealerResourceEffect(card)
    print("Applying dealer resource effect for card:", card.name, "ID:", card.id)
    print("Dealer SE: ", self.dealerSE)
    print("Dealer Points: ", self.dealerPoints)

    if card.id == 1 then
        self.dealerPoints = self.dealerPoints + 10
    elseif card.id == 2 then
        self.dealerPoints = self.dealerPoints + 5
        -- Dealer draws a card (if needed)
    elseif card.id == 3 then
        if self.dealerSE >= 3 then
            self.dealerPoints = self.dealerPoints + 20
            self.dealerSE = self.dealerSE - 3
        end
    elseif card.id == 4 then
        if self.playerPoints > self.dealerPoints then
            self.dealerPoints = self.dealerPoints + 30
        else
            self.dealerPoints = self.dealerPoints + 15
        end
    elseif card.id == 5 then
        if self.dealerSE >= 10 then
            self.dealerPoints = self.dealerPoints + 25
            self.dealerSE = self.dealerSE - 10
        end
    elseif card.id == 7 then
        self.dealerPoints = self.dealerPoints + 10
        -- Dealer can reuse an action card (if needed)
    elseif card.id == 8 then
        self.dealerPoints = self.dealerPoints + 20
        -- Card is destroyed (no further action needed)
    elseif card.id == 9 then
        self.dealerPoints = self.dealerPoints + 10
        self.dealerSE = self.dealerSE + 3
    elseif card.id == 10 then
        if not self.playedGambleCard then
            self.dealerPoints = self.dealerPoints + 15
        end
    elseif card.id == 11 then
        self.dealerPoints = self.dealerPoints + 25
        self.playerPoints = self.playerPoints + 5
    elseif card.id == 12 then
        self.dealerPoints = self.dealerPoints + 10
        -- Reveal the player's next card (if needed)
    elseif card.id == 13 then
        if self.dealerSE >= 5 then
            self.dealerPoints = self.dealerPoints + 30
            self.dealerSE = self.dealerSE - 5
            self.playerPoints = self.playerPoints - 5
        end
    elseif card.id == 14 then
        self.dealerPoints = self.dealerPoints + 5
        -- Card returns to the dealer's hand (if needed)
    elseif card.id == 15 then
        self.dealerPoints = self.dealerPoints + 15
        -- Dealer draws an extra card if they win (if needed)
    elseif card.id == 16 then
        self.dealerPoints = self.dealerPoints + 10
        self.dealerSE = self.dealerSE + math.floor(self.dealerPoints / 5)
    elseif card.id == 17 then
        if self.dealerSE >= 10 then
            self.dealerPoints = self.dealerPoints + 40
            self.dealerSE = self.dealerSE - 10
            -- Dealer discards a random card (if needed)
        end
    elseif card.id == 18 then
        self.dealerPoints = self.dealerPoints + 15
        -- Reveal the top card of the dealer's deck (if needed)
    elseif card.id == 19 then
        self.dealerPoints = self.dealerPoints + 5
        -- Dealer draws a card and discards a random card (if needed)
    elseif card.id == 20 then
        if self.dealerSE >= 20 then
            self.dealerPoints = self.dealerPoints + 50
            self.dealerSE = self.dealerSE - 20
        end
    end

    -- Debug: Print updated values
    print("Updated Dealer SE: ", self.dealerSE)
    print("Updated Dealer Points: ", self.dealerPoints)
end

function Game:applyDealerActionEffect(card)
    if card.id == 21 then
        self:swapCardWithDealer()
    elseif card.id == 23 then
        -- Dealer draws two cards (if needed)
    elseif card.id == 24 then
        if self.dealerSE >= 10 then
            self.dealerSE = self.dealerSE - 10
            self.dealerPoints = self.dealerPoints + 5
        end
    elseif card.id == 25 then
        -- Reveal the player's next two cards (if needed)
    elseif card.id == 26 then
        self:negatePlayerCard()
    elseif card.id == 27 then
        self:playPlayerCard()
    elseif card.id == 28 then
        self:undoLastCard()
    elseif card.id == 29 then
        self.playerPoints = self.playerPoints + 5
        self.dealerPoints = self.dealerPoints + 10
    elseif card.id == 30 then
        -- Dealer plays an additional card (if needed)
    elseif card.id == 31 then
        if self.dealerSE >= 5 then
            self.dealerSE = self.dealerSE - 5
            self:stealPlayerCard()
        end
    elseif card.id == 32 then
        local transferAmount = math.min(10, self.playerPoints)
        self.playerPoints = self.playerPoints - transferAmount
        self.dealerPoints = self.dealerPoints + transferAmount
    elseif card.id == 33 then
        if self.dealerPoints < 10 then
            print("Dealer does not have enough points to play this card!")
            return
        else
            self.dealerSE = self.dealerSE + 10
            self.dealerPoints = self.dealerPoints - 10
        end
    elseif card.id == 35 then
        self:copyPlayerCard()
    elseif card.id == 36 then
        if self.dealerSE >= 5 then
            self.dealerSE = self.dealerSE - 5
            self:removePlayerCard()
        end
    elseif card.id == 37 then
        -- Dealer discards their hand and draws 5 new cards (if needed)
    elseif card.id == 38 then
        self:revealPlayerHand()
    elseif card.id == 39 then
        self:swapHandsWithPlayer()
    elseif card.id == 40 then
        self.playerDisabled = true
    elseif card.id == 41 then
        self.playerPoints = self.playerPoints - 10
        self.dealerPoints = self.dealerPoints + 10
    elseif card.id == 43 then
        self.playerSEDisabled = true
    elseif card.id == 44 then
        -- Dealer swaps a card with the discard pile (if needed)
    elseif card.id == 45 then
        -- Dealer gains 5 SE for every gamble card played this round
        self.dealerSE = self.dealerSE + (5 * self.gambleCardsPlayed)
    end
end

function Game:applyDealerGambleEffect(card)
    self.gambleCardsPlayed = self.gambleCardsPlayed + 1  -- Increment the counter
    if card.id == 47 then
        if math.random(2) == 1 then
            self.dealerPoints = self.dealerPoints * 2
        else
            self.dealerPoints = self.dealerPoints / 2
        end
    elseif card.id == 48 then
        if self.dealerSE >= 10 then
            self.dealerSE = self.dealerSE - 10
            if math.random(2) == 1 then
                self.dealerSE = self.dealerSE + 30
            end
        end
    elseif card.id == 49 then
        self:playRandomPlayerCard()
    elseif card.id == 50 then
        -- Dealer draws 3 cards and discards 2 (if needed)
    elseif card.id == 51 then
        local roll = math.random(6)
        if roll <= 3 then
            self.dealerSE = self.dealerSE - 10
        else
            self.dealerSE = self.dealerSE + 15
        end
    elseif card.id == 52 then
        if self.dealerSE >= 5 then
            self.dealerSE = self.dealerSE - 5
            if math.random(2) == 1 then
                self.dealerSE = self.dealerSE + 10
            else
                -- Dealer discards a random card (if needed)
            end
        end
    elseif card.id == 53 then
        self.dealerPoints = self.dealerPoints + 50
        self.dealerSE = self.dealerSE - 20
    elseif card.id == 54 then
        if self.dealerSE >= 10 then
            self.dealerSE = self.dealerSE - 10
            if math.random(2) == 1 then
                self.dealerPoints = self.dealerPoints * 2
            else
                self.dealerPoints = self.dealerPoints / 2
            end
        end
    elseif card.id == 55 then
        if self.dealerSE >= 5 then
            self.dealerSE = self.dealerSE - 5
            if math.random(2) == 1 then
                self.dealerSE = self.dealerSE + 10
                self.playerSE = self.playerSE - 10
            else
                self.dealerSE = self.dealerSE - 10
                self.playerSE = self.playerSE + 10
            end
        end
    elseif card.id == 57 then
        self.dealerPoints = self.dealerPoints * 2
        self.doublePointsActive = true
    elseif card.id == 58 then
        if self.dealerSE >= 5 then
            self.dealerSE = self.dealerSE - 5
            if math.random(2) == 1 then
                self.dealerPoints = self.dealerPoints + 15
            else
                self.dealerPoints = self.dealerPoints - 10
            end
        end
    elseif card.id == 59 then
        if self.dealerSE >= 10 then
            self.dealerSE = self.dealerSE - 10
            if math.random(2) == 1 then
                self.dealerSE = self.dealerSE + 20
            else
                self.dealerSE = self.dealerSE - 15
            end
        end
    elseif card.id == 60 then
        local betAmount = self.dealerSE
        if math.random(2) == 1 then
            self.dealerSE = self.dealerSE * 2
        else
            self.dealerSE = 0
        end
    end
end

function Game:applyDealerCardEffect(card)
    self.lastDealerCard = card  -- Track the last dealer card played
    if card.id == 61 then
        -- Card Ban: Prevents the player from using one type of card this round
        self.playerCardBan = true
    elseif card.id == 62 then
        -- SE Drain: Steals 5 SE from the player
        if self.soulEssence >= 5 then
            self.soulEssence = self.soulEssence - 5
            self.dealerSE = self.dealerSE + 5
        end
    elseif card.id == 63 then
        -- Unstable Points: The player's points fluctuate randomly (-15 to +5)
        local fluctuation = math.random(-15, 5)
        self.playerPoints = self.playerPoints + fluctuation
    elseif card.id == 64 then
        -- Hand Disruption: Forces the player to discard a random card
        self:discardRandomCard()
    elseif card.id == 65 then
        -- Forced Wager: The player must gamble 10 SE
        self.soulEssence = self.soulEssence - 10
    elseif card.id == 66 then
        -- Extra Draw: The Dealer draws an extra card
        self:dealCard()
    elseif card.id == 68 then
        -- Phantom Stash: The Dealer can reuse one of their previously played cards
        self.dealerReuseCard = true
    elseif card.id == 69 then
        -- Soul Tax: The player loses 1 SE for every 10 points they score this round
        local tax = math.floor(self.playerPoints / 10)
        self.soulEssence = self.soulEssence - tax
    elseif card.id == 70 then
        -- Dealer’s Gambit: The Dealer gains 20 points but loses 10 SE
        self.dealerPoints = self.dealerPoints + 20
        self.dealerSE = self.dealerSE - 10
    elseif card.id == 71 then
        -- Soul Theft: Steals a random amount of SE from the player (1-10 SE)
        local stolenSE = math.random(1, 10)
        if self.soulEssence >= stolenSE then
            self.soulEssence = self.soulEssence - stolenSE
            self.dealerSE = self.dealerSE + stolenSE
        end
    elseif card.id == 72 then
        -- Point Drain: Steals 10 points from the player
        self.playerPoints = self.playerPoints - 10
        self.dealerPoints = self.dealerPoints + 10
    elseif card.id == 73 then
        -- Double Trouble: The Dealer plays two additional cards this round
        if self.doubleTroubleCount < self.maxDoubleTroublePlays then
            self.doubleTroubleCount = self.doubleTroubleCount + 1
            self.dealer:playHand(self)
            self.dealer:playHand(self)
        else
            print("Double Trouble limit reached for this round.")
        end
    elseif card.id == 74 then
        -- Essence Swap: Swaps SE with the player
        local tempSE = self.soulEssence
        self.soulEssence = self.dealerSE
        self.dealerSE = tempSE
    elseif card.id == 75 then
        -- Total Disruption: Forces the player to discard their entire hand
        self:discardHand()
    end
end



                    ----------------------------
                    --- Card effect functions---
                    ----------------------------

function Game:playRandomDealerCard()
    if #self.dealerHand > 0 then
        local randomIndex = math.random(#self.dealerHand)
        local card = self.dealerHand[randomIndex]
        print("Playing random dealer card:", card.name)
        if card.type == "resource" then
            self:applyDealerResourceEffect(card)
        elseif card.type == "action" then
            self:applyDealerActionEffect(card)
        elseif card.type == "gamble" then
            self:applyDealerGambleEffect(card)
        elseif card.type == "dealer" then
            self:applyDealerCardEffect(card)
        end
    else
        print("Dealer's hand is empty!")
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

function Game:goToMainMenu()
    self.state = "menu"
end

function Game:resetGame()
    -- Reset game state variables
    self.state = "menu"
    self.deck = {}
    self.dealerDeck = {}
    self.playerHand = {}
    self.dealerHand = {}
    self.soulEssence = 20
    self.dealerSE = 100
    self.playerPoints = 0
    self.dealerPoints = 0
    self.roundNumber = 1
    self.canDrawCards = true
    self.dealerCardsVisible = false
    self.extraDrawOnWin = false
    self.extraDrawCards = 0
    self.gambleCardsPlayed = 0

    -- Reinitialize the decks
    self:initializeDecks()

    -- Reset the dealer's hand
    self.dealer:resetHand(self)

    -- Reset the timer
    -- self.timer:clearTimers()

    -- Reset any other necessary variables
    self.lastDealerCard = nil
    self.doublePointsActive = false
    self.doubleTroubleCount = 0
    self.dealerDisabled = false
    self.playerDisabled = false
    self.dealerSEDisabled = false
    self.playerSEDisabled = false
    self.reuseActionCard = false
    self.returnToHand = false
    self.extraCardPlay = false
    self.playedGambleCard = false

    -- Debug: Print a message to confirm the game has been reset
    print("Game reset! Ready to start a new game.")
end

function Game:start()
    self.state = "playing"
    self:initialize()
    self.timer:setTimer(function()
        self:startDealingCards(5)
    end, 1)
end
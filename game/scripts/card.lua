Card = {}

function Card:new(value, suit, cardPack)
    local card = {
        value = value,
        suit = suit,
        image = love.graphics.newImage("assets/card_packs/" .. cardPack .. "/" .. value .. ".jpeg"),
        backImage = love.graphics.newImage("assets/card_packs/" .. cardPack .. "/back.jpeg"),
        holographicShader = love.graphics.newShader("assets/shaders/gold.glsl"),
        goldShader = love.graphics.newShader("assets/shaders/gold.glsl"),
        maskImage = love.graphics.newImage("assets/card_packs/back_mask.png"),  -- Initialize mask here
        time = 0,
        flipped = false
    }
    
    -- Send mask texture once during initialization
    card.goldShader:send("u_mask", card.maskImage)
    
    setmetatable(card, self)
    self.__index = self
    return card
end


function Card:draw(x, y)
    -- Define card dimensions and scaling
    local cardWidth, cardHeight = 512, 768  -- Original card dimensions
    local scale = 0.35  -- Scaling factor
    local scaledWidth = cardWidth * scale
    local scaledHeight = cardHeight * scale

    -- Define border dimensions
    local borderPadding = 60 * scale  -- Increased padding for larger text
    local borderWidth = scaledWidth + 2 * borderPadding
    local borderHeight = scaledHeight + 2 * borderPadding
    local cornerRadius = 10 * scale  -- Corner radius for the rounded rectangle

    -- Draw the larger rounded border (background)
    love.graphics.setColor(1, 1, 1)  -- White border
    drawRoundedRectangle(x - borderPadding, y - borderPadding, borderWidth, borderHeight, cornerRadius)

    -- Draw the card image (front or back)
    local cardX = x + (borderWidth - scaledWidth) / 2 - borderPadding
    local cardY = y + (borderHeight - scaledHeight) / 2 - borderPadding
    love.graphics.setColor(1, 1, 1)  -- Reset color to white

    if self.flipped then
        -- Use gold shader
        self.goldShader:send("u_time", self.time)  -- Send time to animate the shader
        self.goldShader:send("u_resolution", {love.graphics.getWidth(), love.graphics.getHeight()})
        love.graphics.setShader(self.goldShader)
        love.graphics.draw(self.backImage, cardX, cardY, 0, scale, scale)
        love.graphics.setShader()  -- Reset the shader
    else
        love.graphics.draw(self.image, cardX, cardY, 0, scale, scale)
    end
    
    -- Draw the value and suit overlay on the border (if not flipped)
    if not self.flipped then
        local valueText = self:getValueText()
        local suitText = self:getSuitText()

        -- Set font and color for the overlay
        local overlayFont = love.graphics.newFont("fonts/NotoSansBold.ttf", 40 * scale)  -- Larger font size
        love.graphics.setFont(overlayFont)
        love.graphics.setColor(0, 0, 0)  -- Black text

        -- Calculate text positions relative to the border
        local textOffsetX = 10 * scale  -- Increased horizontal offset for larger text
        local textOffsetY = 5 * scale  -- Increased vertical offset for larger text

        -- Draw value and suit at the top-left corner of the border
        love.graphics.print(valueText, x - borderPadding + textOffsetX + 2.5, y - borderPadding + textOffsetY)
        love.graphics.print(suitText, x - borderPadding + textOffsetX, y - borderPadding + textOffsetY + 50 * scale)

        -- Draw value and suit at the bottom-right corner of the border (rotated)
        love.graphics.print(valueText, x + borderWidth - borderPadding - textOffsetX - overlayFont:getWidth(valueText) - 2.5, y + borderHeight - borderPadding - textOffsetY - 110 * scale)
        love.graphics.print(suitText, x + borderWidth - borderPadding - textOffsetX - overlayFont:getWidth(suitText), y + borderHeight - borderPadding - textOffsetY - 60 * scale)
    end
end

function Card:update(dt)
    -- Update the time variable for the shader animation
    if self.flipped then
        self.time = self.time + dt
        self.goldShader:send("u_time", self.time)  -- Ensure this is called every frame
    end
end

function Card:getValueText()
    -- Convert numeric value to card face (e.g., 1 -> "A", 11 -> "J")
    local values = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"}
    return values[self.value]
end

function Card:getSuitText()
    -- Convert numeric suit to symbol (e.g., 1 -> "♠", 2 -> "♥")
    local suits = {"♠", "♥", "♦", "♣"}
    return suits[self.suit]
end

function Card:toggleFlip()
    -- Toggle the flipped state
    self.flipped = not self.flipped
end

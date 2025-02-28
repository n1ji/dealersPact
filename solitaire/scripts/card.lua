-- scripts/card.lua

Card = {}

function Card:new(value, suit, cardPack)
    local card = {
        value = value,
        suit = suit,
        image = love.graphics.newImage("assets/card_packs/" .. cardPack .. "/" .. value .. ".jpeg"),
        backImage = love.graphics.newImage("assets/card_packs/" .. cardPack .. "/back.jpeg"),
        flipped = false
    }
    setmetatable(card, self)
    self.__index = self
    return card
end

function Card:draw(x, y)
    local scale = Game.cardScale  -- Use the global card scale
    local cardWidth = self.image:getWidth() * scale
    local cardHeight = self.image:getHeight() * scale

    -- Draw the card image
    if self.flipped then
        love.graphics.draw(self.backImage, x, y, 0, scale, scale)
    else
        love.graphics.draw(self.image, x, y, 0, scale, scale)
        -- Draw the card border
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", x, y, cardWidth, cardHeight)
        love.graphics.setColor(1, 1, 1)  -- Reset color to white

        -- Draw a rounded white box behind the value and suit text
        love.graphics.setColor(1, 1, 1)  -- White color
        drawRoundedRectangle(x + 5, y + 5, 30, 20, 5)  -- Rounded rectangle with corner radius 5

        -- Draw the card value and suit in the corner
        love.graphics.setFont(love.graphics.newFont("fonts/NotoSansBold.ttf", 12))
        -- Convert card value to display text
        local valueText
        if self.value == 1 then
            valueText = "A"
        elseif self.value == 11 then
            valueText = "J"
        elseif self.value == 12 then
            valueText = "Q"
        elseif self.value == 13 then
            valueText = "K"
        else
            valueText = tostring(self.value)
        end
        -- Set text color based on suit (red for hearts and diamonds, black for others)
        if self.suit == 2 or self.suit == 3 then  -- Hearts (2) or Diamonds (3)
            love.graphics.setColor(1, 0, 0)  -- Red
        else
            love.graphics.setColor(0, 0, 0)  -- Black
        end
        love.graphics.print(valueText .. self:getSuitSymbol(), x + 5, y + 5)
        love.graphics.setColor(1, 1, 1)  -- Reset color
    end
end

function Card:getSuitSymbol()
    local suits = {"♠", "♥", "♦", "♣"}
    return suits[self.suit]
end

function Card:toggleFlip()
    self.flipped = not self.flipped
end
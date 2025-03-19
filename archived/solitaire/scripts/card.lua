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
    end
end

function Card:toggleFlip()
    self.flipped = not self.flipped
end
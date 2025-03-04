-- scripts/card.lua

Card = {}

function Card:new(type, name, effect)
    local card = {
        type = type,
        name = name,
        effect = effect,
        sound = love.audio.newSource("assets/sounds/card.ogg", "static"),
        image = love.graphics.newImage("assets/cards/" .. type .. ".png"),
        flipped = false
    }
    setmetatable(card, self)
    self.__index = self
    return card
end

function Card:draw(x, y)
    local scale = Game.cardScale
    local cardWidth = self.image:getWidth() * scale
    local cardHeight = self.image:getHeight() * scale
    love.graphics.draw(self.image, x, y, 0, scale, scale)

    -- if self.flipped then
    --     love.graphics.draw(self.image, x, y, 0, scale, scale)
    -- else
    --     love.graphics.draw(self.image, x, y, 0, scale, scale)
    --     love.graphics.setColor(0, 0, 0)
    --     love.graphics.rectangle("line", x, y, cardWidth, cardHeight)
    --     love.graphics.setColor(1, 1, 1)
    -- end
end

function Card:toggleFlip()
    self.flipped = not self.flipped
end
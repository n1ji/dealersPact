-- scripts/card.lua

Card = {}

function Card:new(type, name, effect, id)
    local card = {
        type = type,
        name = name,
        effect = effect,
        id = id,
        sound = love.audio.newSource("assets/sounds/card.mp3", "static"),
        image = love.graphics.newImage("assets/cards/" .. type .. ".png"),
        flipped = false
    }
    card.sound:setVolume(Settings.effectVolume)
    setmetatable(card, self)
    self.__index = self
    return card
end

function Card:draw(x, y, shader)
    local scale = Game.cardScale
    local cardWidth = self.image:getWidth() * scale
    local cardHeight = self.image:getHeight() * scale
    love.graphics.draw(self.image, x, y, 0, scale, scale)

    if shader then
        love.graphics.setShader(shader)
    end

    love.graphics.draw(self.image, x, y, 0, scale, scale)

    if shader then
        love.graphics.setShader()
    end
end

function Card:drawText(x, y)
    love.graphics.setColor(0, 0, 0)

    -- Card type text
    local typeFont = love.graphics.newFont("assets/fonts/EnchantedLand.otf", 28)
    love.graphics.setFont(typeFont)
    local typeText = self.type
    if self.type == "resource" then
        typeText = "Resource"
    elseif self.type == "action" then
        typeText = "Action"
    else
        typeText = "Gamble"
    end
    local typeTextWidth = typeFont:getWidth(typeText)
    local typeX = x + (self.image:getWidth() * Game.cardScale - typeTextWidth) / 2 -- Calculate the x position to center the text horizontally
    love.graphics.print(typeText, typeX, y + 22)

    -- Card name text
    local nameFont = love.graphics.newFont("assets/fonts/EnchantedLand.otf", 24)
    love.graphics.setFont(nameFont)
    local nameText = self.name
    local nameTextWidth = nameFont:getWidth(nameText)
    local nameX = x + (self.image:getWidth() * Game.cardScale - nameTextWidth) / 2
    love.graphics.print(nameText, nameX, y + 190)
    love.graphics.setColor(1, 1, 1)
end
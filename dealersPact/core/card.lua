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

function Card:draw(x, y, shader)
    local scale = Game.cardScale
    local cardWidth = self.image:getWidth() * scale
    local cardHeight = self.image:getHeight() * scale
    love.graphics.draw(self.image, x, y, 0, scale, scale)

    -- love.graphics.setColor(0, 0, 0) -- black text
    -- love.graphics.newFont("assets/fonts/EnchantedLand.otf", 12)
    -- love.graphics.print(self.name, y + 5, y + 5)
    -- love.graphics.setColor(1, 1, 1)

    if shader then
        love.graphics.setShader(shader)
    end

    love.graphics.draw(self.image, x, y, 0, scale, scale)

    if shader then
        love.graphics.setShader()
    end
end

function Card:drawText(x, y)
    -- Set the color for the text
    love.graphics.setColor(0, 0, 0)

    -- Set the font for the card type
    local typeFont = love.graphics.newFont("assets/fonts/EnchantedLand.otf", 28)
    love.graphics.setFont(typeFont)

    -- Calculate the width of the type text
    local typeText = self.type
    local typeTextWidth = typeFont:getWidth(typeText)

    -- Calculate the x position to center the type text horizontally
    local typeX = x + (self.image:getWidth() * Game.cardScale - typeTextWidth) / 2

    -- Draw the type text
    love.graphics.print(typeText, typeX, y + 22)

    -- Set the font for the card name
    local nameFont = love.graphics.newFont("assets/fonts/EnchantedLand.otf", 24)
    love.graphics.setFont(nameFont)

    -- Calculate the width of the name text
    local nameText = self.name
    local nameTextWidth = nameFont:getWidth(nameText)

    -- Calculate the x position to center the name text horizontally
    local nameX = x + (self.image:getWidth() * Game.cardScale - nameTextWidth) / 2

    -- Draw the name text
    love.graphics.print(nameText, nameX, y + 190)

    -- Reset the color to white
    love.graphics.setColor(1, 1, 1)
end
local utils = require ("utils")
Button = {}

function Button:new(text, x, y, width, height, action, cornerRadius, padding)
    local button = {
        text = text,
        x = x,
        y = y,
        width = width,
        height = height,
        action = action,
        cornerRadius = cornerRadius or 0,
        padding = padding or 0,
        hovered = false
    }
    setmetatable(button, self)
    self.__index = self
    return button
end

function Button:draw()
    local color = {hexToRGB("#086788")} -- button color
    if self.hovered then
        color = {hexToRGB("#0b132b")}  -- hover color
    end
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.cornerRadius)

    -- Set text color and font
    love.graphics.setColor(1, 1, 1)
    local font = love.graphics.newFont("assets/fonts/EnchantedLand.otf", 24)
    love.graphics.setFont(font)

    -- Calculate the text's position to center it
    local textWidth = font:getWidth(self.text)
    local textHeight = font:getHeight()
    local textX = self.x + (self.width - textWidth) / 2  -- Center horizontally
    local textY = self.y + (self.height - textHeight) / 2  -- Center vertically

    -- Draw the text
    love.graphics.print(self.text, textX, textY)
end

function Button:isHovered(mouseX, mouseY)
    return mouseX >= self.x and mouseX <= self.x + self.width and
           mouseY >= self.y and mouseY <= self.y + self.height
end

return Button
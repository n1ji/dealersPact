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
    local color = {0.8, 0.8, 0.8}  -- Gray color
    if self.hovered then
        color = {0.6, 0.6, 0.6}  -- Darker gray when hovered
    end
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.cornerRadius)
    love.graphics.setColor(0, 0, 0)  -- Black text
    love.graphics.setFont(love.graphics.newFont("assets/fonts/EnchantedLand.otf", 24))  -- Ensure the correct font is set
    local textX = self.x + self.padding
    local textY = self.y + self.height / 2 - love.graphics.getFont():getHeight() / 2
    love.graphics.print(self.text, textX, textY)
end

function Button:isHovered(mouseX, mouseY)
    return mouseX >= self.x and mouseX <= self.x + self.width and
           mouseY >= self.y and mouseY <= self.y + self.height
end

return Button
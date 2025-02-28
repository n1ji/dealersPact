-- scripts/button.lua

Button = {}

function Button:new(text, x, y, width, height, action, cornerRadius, padding)
    local button = {
        text = text,
        x = x,
        y = y,
        width = width,
        height = height,
        action = action,
        cornerRadius = cornerRadius,
        padding = padding
    }
    setmetatable(button, self)
    self.__index = self
    return button
end

function Button:draw()
    local color = Menu.gray
    if self:isHovered(love.mouse.getPosition()) then
        color = Menu.hoverColor
    end
    love.graphics.setColor(color)
    drawRoundedRectangle(self.x, self.y, self.width, self.height, self.cornerRadius)
    love.graphics.setColor(Menu.black)
    local textX = self.x + self.padding
    local textY = self.y + self.height / 2 - Menu.buttonFont:getHeight() / 2
    love.graphics.print(self.text, textX, textY)
end

function Button:isHovered(mouseX, mouseY)
    return mouseX >= self.x and mouseX <= self.x + self.width and
           mouseY >= self.y and mouseY <= self.y + self.height
end

function Button:handleClick()
    if self.action == "new_cards" then
        print("New Cards button clicked!")
        -- Add your game logic here
    end
end
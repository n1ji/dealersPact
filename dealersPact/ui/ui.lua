local UI = {}

-- Button object
function UI.createButton(x, y, width, height, text, color, hoverColor)
    return {
        x = x,
        y = y,
        width = width,
        height = height,
        text = text,
        color = color or {0.2, 0.6, 0.8},
        hoverColor = hoverColor or {0.3, 0.7, 0.9},
        isHovered = false
    }
end

-- Draw a button
function UI.drawButton(button)
    if button.isHovered then
        love.graphics.setColor(button.hoverColor)
    else
        love.graphics.setColor(button.color)
    end
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)

    love.graphics.setColor(1, 1, 1)
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(button.text)
    local textHeight = font:getHeight()
    love.graphics.print(button.text, button.x + (button.width - textWidth) / 2, button.y + (button.height - textHeight) / 2)
end

-- Check if a button is hovered
function UI.updateButton(button)
    local mouseX, mouseY = love.mouse.getPosition()
    button.isHovered = mouseX >= button.x and mouseX <= button.x + button.width and
                       mouseY >= button.y and mouseY <= button.y + button.height
end

-- Check if a button is clicked
function UI.checkButtonClick(button, x, y)
    return button.isHovered and x >= button.x and x <= button.x + button.width and
           y >= button.y and y <= button.y + button.height
end

return UI
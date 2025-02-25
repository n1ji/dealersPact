-- main.lua

function love.load()
    -- Screen dimensions
    screenWidth = 1200
    screenHeight = 700
    love.window.setMode(screenWidth, screenHeight, {resizable=false})
    love.window.setTitle("Poker-Inspired Game - Main Menu")

    -- Colors
    white = {1, 1, 1, 1}
    black = {0, 0, 0, 1}
    gray = {0.8, 0.8, 0.8, 1}
    hoverColor = {0.6, 0.6, 0.6, 1}

    -- Fonts
    titleFont = love.graphics.newFont("ZCOOLKuaiLe-Regular.ttf", 74)
    buttonFont = love.graphics.newFont("ZCOOLKuaiLe-Regular.ttf", 50)

    -- Main menu text
    titleText = "Poker Game"
    titleX = screenWidth / 2 - titleFont:getWidth(titleText) / 2
    titleY = 100

    -- Buttons
    buttons = {
        {
            text = "Play",
            x = screenWidth / 2 - 150,
            y = 200,
            width = 300,
            height = 70,
            action = "play",
            cornerRadius = 20, -- Rounded corners
            padding = 40 -- Padding around text
        },
        {
            text = "Settings",
            x = screenWidth / 2 - 150,
            y = 300,
            width = 300,
            height = 70,
            action = "settings",
            cornerRadius = 20,
            padding = 40
        },
        {
            text = "Quit",
            x = screenWidth / 2 - 150,
            y = 400,
            width = 300,
            height = 70,
            action = "quit",
            cornerRadius = 20,
            padding = 40
        }
    }
end

function love.draw()
    -- Draw title
    love.graphics.setFont(titleFont)
    love.graphics.setColor(white)
    love.graphics.print(titleText, titleX, titleY)

    -- Draw buttons
    love.graphics.setFont(buttonFont)
    for i, button in ipairs(buttons) do
        local color = gray
        if isHovered(button) then
            color = hoverColor
        end
        love.graphics.setColor(color)
        drawRoundedRectangle(button.x, button.y, button.width, button.height, button.cornerRadius)
        love.graphics.setColor(black)
        local textX = button.x + button.padding
        local textY = button.y + button.height / 2 - buttonFont:getHeight() / 2
        love.graphics.print(button.text, textX, textY)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        for i, btn in ipairs(buttons) do
            if isHovered(btn) then
                handleButtonClick(btn.action)
            end
        end
    end
end

function isHovered(button)
    local mouseX, mouseY = love.mouse.getPosition()
    return mouseX >= button.x and mouseX <= button.x + button.width and
           mouseY >= button.y and mouseY <= button.y + button.height
end

function handleButtonClick(action)
    if action == "play" then
        print("Play button clicked!")
        -- Add your game logic here
    elseif action == "settings" then
        print("Settings button clicked!")
        -- Add your settings logic here
    elseif action == "quit" then
        love.event.quit()
    end
end

function drawRoundedRectangle(x, y, width, height, cornerRadius)
    -- Draw rounded rectangle using arcs and lines
    love.graphics.rectangle("fill", x + cornerRadius, y, width - 2 * cornerRadius, height) -- Center rectangle
    love.graphics.rectangle("fill", x, y + cornerRadius, cornerRadius, height - 2 * cornerRadius) -- Left rectangle
    love.graphics.rectangle("fill", x + width - cornerRadius, y + cornerRadius, cornerRadius, height - 2 * cornerRadius) -- Right rectangle

    -- Draw rounded corners
    love.graphics.arc("fill", x + cornerRadius, y + cornerRadius, cornerRadius, math.pi, 1.5 * math.pi) -- Top-left corner
    love.graphics.arc("fill", x + width - cornerRadius, y + cornerRadius, cornerRadius, 1.5 * math.pi, 2 * math.pi) -- Top-right corner
    love.graphics.arc("fill", x + cornerRadius, y + height - cornerRadius, cornerRadius, 0.5 * math.pi, math.pi) -- Bottom-left corner
    love.graphics.arc("fill", x + width - cornerRadius, y + height - cornerRadius, cornerRadius, 0, 0.5 * math.pi) -- Bottom-right corner
end
-- main.lua

function love.load()
    -- Screen dimensions
    screenWidth = 800
    screenHeight = 600
    love.window.setMode(screenWidth, screenHeight, {resizable=false})
    love.window.setTitle("Poker-Inspired Game - Main Menu")

    -- Colors
    white = {1, 1, 1, 1}
    black = {0, 0, 0, 1}
    gray = {0.8, 0.8, 0.8, 1}
    hoverColor = {0.6, 0.6, 0.6, 1}

    -- Fonts
    titleFont = love.graphics.newFont(74)
    buttonFont = love.graphics.newFont(50)

    -- Main menu text
    titleText = "Poker Game"
    titleX = screenWidth / 2 - titleFont:getWidth(titleText) / 2
    titleY = 100

    -- Buttons
    buttons = {
        {
            text = "Play",
            x = screenWidth / 2 - 100,
            y = 200,
            width = 200,
            height = 50,
            action = "play"
        },
        {
            text = "Settings",
            x = screenWidth / 2 - 100,
            y = 300,
            width = 200,
            height = 50,
            action = "settings"
        },
        {
            text = "Quit",
            x = screenWidth / 2 - 100,
            y = 400,
            width = 200,
            height = 50,
            action = "quit"
        }
    }
end

function love.draw()
    -- Draw title
    love.graphics.setFont(titleFont)
    love.graphics.setColor(black)
    love.graphics.print(titleText, titleX, titleY)

    -- Draw buttons
    love.graphics.setFont(buttonFont)
    for i, button in ipairs(buttons) do
        local color = gray
        if isHovered(button) then
            color = hoverColor
        end
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
        love.graphics.setColor(black)
        local textX = button.x + button.width / 2 - buttonFont:getWidth(button.text) / 2
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
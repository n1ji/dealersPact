-- scripts/menu.lua

Menu = {}

function Menu:initialize()
    -- Screen dimensions
    self.screenWidth = 1680
    self.screenHeight = 1050
    love.window.setMode(self.screenWidth, self.screenHeight, {resizable=false})
    love.window.setTitle("Solitaire")

    -- Colors
    self.white = {1, 1, 1, 1}
    self.black = {0, 0, 0, 1}
    self.gray = {0.8, 0.8, 0.8, 1}
    self.hoverColor = {0.6, 0.6, 0.6, 1}
    self.backgroundColor = {hexToRGB("#A77464")}

    -- Load custom fonts
    self.titleFont = love.graphics.newFont("fonts/ZCOOL.ttf", 74)
    self.buttonFont = love.graphics.newFont("fonts/ZCOOL.ttf", 50)

    -- Main menu text
    self.titleText = "Solitaire"
    self.titleX = self.screenWidth / 2 - self.titleFont:getWidth(self.titleText) / 2
    self.titleY = 100

    -- Buttons for main menu
    self.mainMenuButtons = {
        Button:new("Play", self.screenWidth / 2 - 100, 200, 200, 50, "play", 20, 40),
        Button:new("Card Packs", self.screenWidth / 2 - 100, 300, 200, 50, "card_packs", 20, 40),
        Button:new("Quit", self.screenWidth / 2 - 100, 400, 200, 50, "quit", 20, 40)
    }

    -- Buttons for card pack selection
    self.cardPackButtons = {
        Button:new("Animals", self.screenWidth / 2 - 150, 200, 300, 70, "animals", 20, 40),
        Button:new("Modern", self.screenWidth / 2 - 150, 300, 300, 70, "modern", 20, 40),
        Button:new("Fantasy", self.screenWidth / 2 - 150, 400, 300, 70, "fantasy", 20, 40)
    }
end

function Menu:draw()
    -- Set background color
    love.graphics.clear(self.backgroundColor)

    -- Draw title
    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(self.black)
    love.graphics.print(self.titleText, self.titleX, self.titleY)

    -- Draw main menu buttons
    love.graphics.setFont(self.buttonFont)
    for i, button in ipairs(self.mainMenuButtons) do
        button:draw()
    end
end

function Menu:handleMousePress(x, y, button)
    for i, btn in ipairs(self.mainMenuButtons) do
        if btn:isHovered(x, y) then
            if btn.action == "play" then
                Game.state = "playing"  -- Transition to playing state
                Game:initialize()
            elseif btn.action == "card_packs" then
                Game.state = "card_pack_selection"  -- Transition to card pack selection
            elseif btn.action == "quit" then
                love.event.quit()
            end
        end
    end
end

function Menu:drawCardPackSelection()
    -- Draw title
    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(self.black)
    love.graphics.print("Choose Card Pack", self.titleX, self.titleY)

    -- Draw card pack buttons
    love.graphics.setFont(self.buttonFont)
    for i, button in ipairs(self.cardPackButtons) do
        button:draw()
    end
end

function Menu:handleCardPackSelection(x, y, button)
    for i, btn in ipairs(self.cardPackButtons) do
        if btn:isHovered(x, y) then
            Game:start(btn.action)  -- Start the game with the selected card pack
            print("Game started with card pack: " .. btn.action)
        end
    end
end
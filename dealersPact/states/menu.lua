-- scripts/menu.lua

Menu = {}

function Menu:initialize()
    self.screenWidth = 1680
    self.screenHeight = 960
    love.window.setMode(self.screenWidth, self.screenHeight, {resizable=false})
    love.window.setTitle("The Dealer's Pact")

    self.white = {1, 1, 1, 1}
    self.black = {hexToRGB("#0B0B0B")}
    self.red = {hexToRGB("#8B0000")}
    self.gold = {hexToRGB("#CAA52B")}
    self.purple = {hexToRGB("#3B1E5F")}
    self.blue = {hexToRGB("#1A1B3A")}
    self.gray = {0.8, 0.8, 0.8, 1}
    self.hoverColor = {0.6, 0.6, 0.6, 1}

    self.titleFont = love.graphics.newFont("assets/fonts/EnchantedLand.otf", 74)
    self.buttonFont = love.graphics.newFont("assets/fonts/EnchantedLand.otf", 50)

    self.music = love.audio.newSource("assets/sounds/bgm.mp3", "stream")
    love.audio.setVolume(0)
    love.audio.play(self.music)

    self.titleText = "The Dealer's Pact"
    self.titleX = self.screenWidth / 2 - self.titleFont:getWidth(self.titleText) / 2
    self.titleY = 100

    local buttonGap = 30
    local buttonStartY = 250

    self.mainMenuButtons = {
        Button:new("Play", self.screenWidth / 2 - 100, buttonStartY, 200, 50, "play", 20, 40),
        Button:new("Settings", self.screenWidth / 2 - 100, buttonStartY + 50 + buttonGap, 200, 50, "settings", 20, 40),
        Button:new("Quit", self.screenWidth / 2 - 100, buttonStartY + 2 * (50 + buttonGap), 200, 50, "quit", 20, 40)
    }

    self.settingsButtons = {
        Button:new("Music Volume +", self.screenWidth / 2 - 100, 200, self.titleFont:getWidth(self.titleText), 50, "musicUp", 20, 40),
        Button:new("Music Volume -", self.screenWidth / 2 - 100, 250, self.titleFont:getWidth(self.titleText), 50, "musicDown", 20, 40),
        Button:new("Effects Volume +", self.screenWidth / 2 - 100, 300, self.titleFont:getWidth(self.titleText), 50, "effectsUp", 20, 40),
        Button:new("Effects Volume -", self.screenWidth / 2 - 100, 350, self.titleFont:getWidth(self.titleText), 50, "effectsDown", 20, 40),
        Button:new("Mute Music", self.screenWidth / 2 - 100, 400, self.titleFont:getWidth(self.titleText), 50, "muteMusic", 20, 40),
        Button:new("Back", self.screenWidth / 2 - 100, 400, 200, 50, "back", 20, 40)
    }

    self.state = "mainMenu"
end

function Menu:draw()
    love.graphics.clear(self.blue)
    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(self.white)
    love.graphics.print(self.titleText, self.titleX, self.titleY)

    love.graphics.setFont(self.buttonFont)
    for i, button in ipairs(self.mainMenuButtons) do
        button:draw()
    end
    if self.state == "mainMenu" then
        for i, button in ipairs(self.mainMenuButtons) do
            button:draw()
        end
    elseif self.state == "settings" then
        for i, button in ipairs(self.settingsButtons) do
            button:draw()
        end
    end
end

function Menu:handleMousePress(x, y, button)
    if self.state == "mainMenu" then
        for i, btn in ipairs(self.mainMenuButtons) do
            if btn:isHovered(x, y) then
                if btn.action == "play" then
                    Game.state = "playing"
                    Game:initialize()
                elseif btn.action == "settings" then
                    self.state = "settings"
                elseif btn.action == "quit" then
                    love.event.quit()
                end
            end
        end
    elseif self.state == "settings" then
        for i, btn in ipairs(self.settingsButtons) do
            if btn:isHovered(x, y) then
                if btn.action == "musicUp" then
                    love.audio.setVolume(love.audio.getVolume() + 0.1)
                elseif btn.action == "musicDown" then
                    love.audio.setVolume(love.audio.getVolume() - 0.1)
                elseif btn.action == "effectsUp" then
                    -- Increase effects volume
                elseif btn.action == "effectsDown" then
                    -- Decrease effects volume
                elseif btn.action == "muteMusic" then
                    love.audio.setVolume(0)
                elseif btn.action == "back" then
                    self.state = "mainMenu"
                end
            end
        end
    end
end
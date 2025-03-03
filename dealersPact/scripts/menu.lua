-- scripts/menu.lua

Menu = {}

function Menu:initialize()
    self.screenWidth = 1680
    self.screenHeight = 1050
    love.window.setMode(self.screenWidth, self.screenHeight, {resizable=false})
    love.window.setTitle("The Dealer's Pact")

    self.white = {1, 1, 1, 1}
    self.black = {0, 0, 0, 1}
    self.gray = {0.8, 0.8, 0.8, 1}
    self.hoverColor = {0.6, 0.6, 0.6, 1}
    self.backgroundColor = {hexToRGB("#A77464")}

    self.titleFont = love.graphics.newFont("fonts/ZCOOL.ttf", 74)
    self.buttonFont = love.graphics.newFont("fonts/ZCOOL.ttf", 50)

    self.titleText = "The Dealer's Pact"
    self.titleX = self.screenWidth / 2 - self.titleFont:getWidth(self.titleText) / 2
    self.titleY = 100

    self.mainMenuButtons = {
        Button:new("Play", self.screenWidth / 2 - 100, 200, 200, 50, "play", 20, 40),
        Button:new("Quit", self.screenWidth / 2 - 100, 300, 200, 50, "quit", 20, 40)
    }
end

function Menu:draw()
    love.graphics.clear(self.backgroundColor)
    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(self.black)
    love.graphics.print(self.titleText, self.titleX, self.titleY)

    love.graphics.setFont(self.buttonFont)
    for i, button in ipairs(self.mainMenuButtons) do
        button:draw()
    end
end

function Menu:handleMousePress(x, y, button)
    for i, btn in ipairs(self.mainMenuButtons) do
        if btn:isHovered(x, y) then
            if btn.action == "play" then
                Game.state = "playing"
                Game:initialize()
            elseif btn.action == "quit" then
                love.event.quit()
            end
        end
    end
end
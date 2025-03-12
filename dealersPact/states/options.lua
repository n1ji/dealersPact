local Button = require("ui.button")

OptionsMenu = {
    musicVolume = Game.musicVolume,
    effectVolume = Game.effectVolume
}

function OptionsMenu:initialize()
    self.font = love.graphics.newFont("assets/fonts/EnchantedLand.otf", 36)
    self.buttonFont = love.graphics.newFont("assets/fonts/EnchantedLand.otf", 24)
    self.screenWidth = love.graphics.getWidth()
    self.screenHeight = love.graphics.getHeight()

    -- Define buttons for the options menu
    self.settingsButtons = {
        Button:new("Music Volume +", self.screenWidth / 2 - 100, 200, 200, 50, "musicUp", 10, 20),
        Button:new("Music Volume -", self.screenWidth / 2 - 100, 260, 200, 50, "musicDown", 10, 20),
        Button:new("Effects Volume +", self.screenWidth / 2 - 100, 320, 200, 50, "effectsUp", 10, 20),
        Button:new("Effects Volume -", self.screenWidth / 2 - 100, 380, 200, 50, "effectsDown", 10, 20),
        Button:new("Mute Music", self.screenWidth / 2 - 100, 440, 200, 50, "muteMusic", 10, 20),
        Button:new("Back", self.screenWidth / 2 - 100, 500, 200, 50, "back", 10, 20)
    }
end

function OptionsMenu:draw()
    -- Draw the options menu background
    love.graphics.setColor(hexToRGB("#1A1B3A"))
    love.graphics.rectangle("fill", 0, 0, self.screenWidth, self.screenHeight)

    -- Draw the title
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.font)
    love.graphics.print("Settings", self.screenWidth / 2 - 40, 100)

    -- Draw buttons
    for i, button in ipairs(self.settingsButtons) do
        button:draw()
    end
end

function OptionsMenu:handleMousePress(x, y)
    for i, button in ipairs(self.settingsButtons) do
        if button:isHovered(x, y) then
            if button.action == "musicUp" then
                Game.musicVolume = self.musicVolume + 0.05
                self.music:setVolume(Game.musicVolume) -- Update music volume
                
                --love.audio.setVolume(love.audio.getVolume + 0.1)
                print("VolY " .. tostring(self.musicVolume))
            elseif button.action == "musicDown" then
                Game.music:setVolume(Game.musicVolume - 0.05) -- Update music volume
                print("VolY " .. tostring(self.musicVolume))
            elseif button.action == "effectsUp" then
                print("VolY " .. tostring(self.effectVolume))
            elseif button.action == "effectsDown" then
                print("VolY " .. tostring(self.effectVolume))
            elseif button.action == "muteMusic" then
                love.audio.setVolume(0)
                -- Handle mute music
                print("Mute Music clicked")
            elseif button.action == "back" then
                -- Return to the previous state
                return "return"
            end
        end
    end
end

function OptionsMenu:updateHoverState(mouseX, mouseY)
    for i, button in ipairs(self.settingsButtons) do
        button.hovered = button:isHovered(mouseX, mouseY)
    end
end

return OptionsMenu
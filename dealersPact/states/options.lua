local Button = require("ui.button")

OptionsMenu = {}

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
                -- Increase music volume
                Settings.setMusicVolume(Settings.musicVolume + 0.05)
                print("Music Volume: " .. tostring(Settings.musicVolume))
            elseif button.action == "musicDown" then
                -- Decrease music volume
                Settings.setMusicVolume(Settings.musicVolume - 0.05)
                print("Music Volume: " .. tostring(Settings.musicVolume))
            elseif button.action == "effectsUp" then
                -- Increase effects volume
                Settings.setEffectVolume(Settings.effectVolume + 0.05)
                print("Effects Volume: " .. tostring(Settings.effectVolume))
            elseif button.action == "effectsDown" then
                -- Decrease effects volume
                Settings.setEffectVolume(Settings.effectVolume - 0.05)
                print("Effects Volume: " .. tostring(Settings.effectVolume))
            elseif button.action == "muteMusic" then
                -- Toggle mute for music
                if Settings.musicVolume > 0 then
                    Settings.setMusicVolume(0)  -- Mute music
                    print("Music Muted")
                else
                    Settings.setMusicVolume(0.5)  -- Unmute music (reset to default)
                    print("Music Unmuted")
                end
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
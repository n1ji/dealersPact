-- main.lua

function love.load()
    -- Load scripts
    require("scripts.menu")
    require("scripts.button")
    require("scripts.utils")
    require("scripts.game")
    require("scripts.card")
    require("scripts.bot")

    -- Initialize the menu
    Menu:initialize()

    -- Convert colors from hex
    require("scripts.utils")

    local bgR, bgG, bgB = hexToRGB("#A77464") -- Brown Sugar
    love.graphics.setBackgroundColor(bgR, bgG, bgB)
end

function love.update(dt)
    if Game.state == "playing" then
        Game:update(dt)
    end
end

function love.draw()
    if Game.state == "menu" then
        Menu:draw()
    elseif Game.state == "card_pack_selection" then
        Menu:drawCardPackSelection()
    elseif Game.state == "playing" then
        Game:draw()
    end
end

function love.mousepressed(x, y, button)
    if Game.state == "menu" then
        Menu:handleMousePress(x, y, button)
    elseif Game.state == "card_pack_selection" then
        Menu:handleCardPackSelection(x, y, button)
    elseif Game.state == "playing" then
        Game:handleMousePress(x, y, button)
    end
end
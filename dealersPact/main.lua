-- main.lua

function love.load()
    love.window.setIcon(love.image.newImageData("assets/icon.png"))
    -- Load scripts
    require("scripts.game")
    require("scripts.card")
    require("scripts.button")
    require("scripts.menu")
    require("scripts.utils")
    require("scripts.cards")
    require("scripts.ui")

    -- Initialize the menu
    Menu:initialize()
end

function love.update(dt)
    if Game.state == "menu" then
        -- Update menu logic if needed
    elseif Game.state == "card_pack_selection" then
        -- Update card pack selection logic if needed
    else
        Game:update(dt)
    end
end

function love.draw()
    if Game.state == "menu" then
        Menu:draw()
    elseif Game.state == "card_pack_selection" then
        Menu:drawCardPackSelection()
    else
        Game:draw()
    end
end

function love.mousepressed(x, y, button)
    if Game.state == "menu" then
        Menu:handleMousePress(x, y, button)
    else
        Game:handleMousePress(x, y, button)
    end
end
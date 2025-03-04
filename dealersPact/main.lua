-- main.lua

function love.load()
    love.window.setIcon(love.image.newImageData("assets/icon.png"))
    -- Load scripts
    require("states.menu")
    require("core.game")
    require("core.card")
    require("data.cards")
    require("utils")
    require("ui.button")

    -- Initialize the menu
    Menu:initialize()
end

function love.update(dt)
    if Game.state == "menu" then
        Menu:update(dt)
    elseif Game.state == "playing" or Game.state == "settings" then
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
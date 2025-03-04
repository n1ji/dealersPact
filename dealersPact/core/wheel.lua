-- core/wheel.lua

Wheel = {
    spinning = false,
    spinDuration = 2,
    spinProgress = 0,
    currentEffect = nil,
    wheelImage = nil,
    spinButton = nil,
    screenWidth = nil,
    screenHeight = nil
}

function Wheel:initialize(screenWidth, screenHeight)
    self.screenWidth = screenWidth
    self.screenHeight = screenHeight
    self.wheelImage = love.graphics.newImage("assets/wheel.png")
    self.spinButton = {
        x = Game.screenWidth / 2 - 50,
        y = Game.screenHeight - 100,
        width = 100,
        height = 50,
        text = "Spin"
    }
end

function Wheel:draw()
    if self.spinning then
        local angle = self.spinProgress * 2 * math.pi
        love.graphics.draw(self.wheelImage, self.screenWidth / 2, self.screenHeight / 2, angle, 1, 1, self.wheelImage:getWidth() / 2, self.wheelImage:getHeight() / 2)
    else
        love.graphics.draw(self.wheelImage, self.screenWidth / 2, self.screenHeight / 2, 0, 1, 1, self.wheelImage:getWidth() / 2, self.wheelImage:getHeight() / 2)
    end

    -- Draw button
    love.graphics.setColor(0, 0.5, 1)
    love.graphics.rectangle("fill", self.spinButton.x, self.spinButton.y, self.spinButton.width, self.spinButton.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.spinButton.text, self.spinButton.x + 10, self.spinButton.y + 10)
end

function Wheel:update(dt)
    if self.spinning then
        self.spinProgress = self.spinProgress + dt / self.spinDuration
        if self.spinProgress >= 1 then
            self.spinning = false
            self.spinProgress = 0
            self.currentEffect = Game.wheelOfFate[math.random(#Game.wheelOfFate)]
            print("Wheel of Fate: " .. self.currentEffect.name)
        end
    end
end

function Wheel:handleMousePress(x, y)
    -- Ensure spinButton is properly initialized
    if self.spinButton and self.spinButton.x and self.spinButton.y and self.spinButton.width and self.spinButton.height then
        -- Check if the mouse click is within the spin button's bounds
        if x >= self.spinButton.x and x <= self.spinButton.x + self.spinButton.width and
           y >= self.spinButton.y and y <= self.spinButton.y + self.spinButton.height then
            self.spinning = true
        end
    else
        print("Error: spinButton is not properly initialized.")
    end
end

return Wheel
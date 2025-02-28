-- scripts/utils.lua

function drawRoundedRectangle(x, y, width, height, cornerRadius)
    -- Draw rounded rectangle using arcs and lines
    love.graphics.rectangle("fill", x + cornerRadius, y, width - 2 * cornerRadius, height) -- Center rectangle
    love.graphics.rectangle("fill", x, y + cornerRadius, cornerRadius, height - 2 * cornerRadius) -- Left rectangle
    love.graphics.rectangle("fill", x + width - cornerRadius, y + cornerRadius, cornerRadius, height - 2 * cornerRadius) -- Right rectangle

    -- Draw rounded corners
    love.graphics.arc("fill", x + cornerRadius, y + cornerRadius, cornerRadius, math.pi, 1.5 * math.pi) -- Top-left corner
    love.graphics.arc("fill", x + width - cornerRadius, y + cornerRadius, cornerRadius, 1.5 * math.pi, 2 * math.pi) -- Top-right corner
    love.graphics.arc("fill", x + cornerRadius, y + height - cornerRadius, cornerRadius, 0.5 * math.pi, math.pi) -- Bottom-left corner
    love.graphics.arc("fill", x + width - cornerRadius, y + height - cornerRadius, cornerRadius, 0, 0.5 * math.pi) -- Bottom-right corner
end

function hexToRGB(hex)
    -- Remove the '#' if present
    hex = hex:gsub("#", "")

    -- Extract RR, GG, BB components
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255

    return r, g, b
end
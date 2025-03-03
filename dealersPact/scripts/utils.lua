-- scripts/utils.lua

function drawRoundedRectangle(x, y, width, height, cornerRadius)
    love.graphics.rectangle("fill", x + cornerRadius, y, width - 2 * cornerRadius, height)
    love.graphics.rectangle("fill", x, y + cornerRadius, cornerRadius, height - 2 * cornerRadius)
    love.graphics.rectangle("fill", x + width - cornerRadius, y + cornerRadius, cornerRadius, height - 2 * cornerRadius)

    love.graphics.arc("fill", x + cornerRadius, y + cornerRadius, cornerRadius, math.pi, 1.5 * math.pi)
    love.graphics.arc("fill", x + width - cornerRadius, y + cornerRadius, cornerRadius, 1.5 * math.pi, 2 * math.pi)
    love.graphics.arc("fill", x + cornerRadius, y + height - cornerRadius, cornerRadius, 0.5 * math.pi, math.pi)
    love.graphics.arc("fill", x + width - cornerRadius, y + height - cornerRadius, cornerRadius, 0, 0.5 * math.pi)
end

function hexToRGB(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    return r, g, b
end
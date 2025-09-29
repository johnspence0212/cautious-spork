local Anvil = {}
Anvil.__index = Anvil

function Anvil:new(x, y)
    local instance = {
        x = x or 400,
        y = y or 250,
        width = 64,
        height = 48,
        color = {0.4, 0.4, 0.4, 1}, -- Dark gray
        highlightColor = {0.6, 0.6, 0.6, 1}, -- Lighter gray when highlighted
        interactionRange = 80,
        isHighlighted = false
    }
    setmetatable(instance, self)
    return instance
end

function Anvil:update(dt, playerX, playerY)
    -- Check if player is within interaction range
    local distance = math.sqrt((playerX - (self.x + self.width/2))^2 + (playerY - (self.y + self.height/2))^2)
    self.isHighlighted = distance <= self.interactionRange
end

function Anvil:draw()
    -- Choose color based on interaction state
    local color = self.isHighlighted and self.highlightColor or self.color
    love.graphics.setColor(color)
    
    -- Draw anvil body (rectangle)
    love.graphics.rectangle("fill", self.x, self.y + 20, self.width, self.height - 20)
    
    -- Draw anvil top (wider rectangle)
    love.graphics.rectangle("fill", self.x - 8, self.y, self.width + 16, 25)
    
    -- Draw anvil horn (small rectangle on the left)
    love.graphics.rectangle("fill", self.x - 12, self.y + 5, 20, 15)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function Anvil:canInteract(playerX, playerY)
    local distance = math.sqrt((playerX - (self.x + self.width/2))^2 + (playerY - (self.y + self.height/2))^2)
    return distance <= self.interactionRange
end

function Anvil:getInteractionPrompt()
    return "Press E to use Anvil"
end

function Anvil:getBounds()
    return {
        x = self.x,
        y = self.y,
        width = self.width,
        height = self.height
    }
end

return Anvil
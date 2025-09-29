local GuildMerchant = {}
GuildMerchant.__index = GuildMerchant

function GuildMerchant:new(x, y)
    local instance = {
        x = x or 200,
        y = y or 200,
        width = 32,
        height = 48,
        color = {0.2, 0.6, 0.2, 1}, -- Green for merchant
        highlightColor = {0.3, 0.8, 0.3, 1}, -- Brighter green when highlighted
        hatColor = {0.4, 0.2, 0.8, 1}, -- Purple hat
        interactionRange = 60,
        isHighlighted = false
    }
    setmetatable(instance, self)
    return instance
end

function GuildMerchant:update(dt, playerX, playerY)
    -- Check if player is within interaction range
    local distance = math.sqrt((playerX - (self.x + self.width/2))^2 + (playerY - (self.y + self.height/2))^2)
    self.isHighlighted = distance <= self.interactionRange
end

function GuildMerchant:draw()
    -- Choose color based on interaction state
    local bodyColor = self.isHighlighted and self.highlightColor or self.color
    
    -- Draw merchant body
    love.graphics.setColor(bodyColor)
    love.graphics.rectangle("fill", self.x, self.y + 16, self.width, self.height - 16)
    
    -- Draw merchant head (lighter skin tone)
    love.graphics.setColor(0.9, 0.7, 0.6, 1)
    love.graphics.rectangle("fill", self.x + 6, self.y + 8, self.width - 12, 16)
    
    -- Draw merchant hat
    love.graphics.setColor(self.hatColor)
    love.graphics.rectangle("fill", self.x + 4, self.y, self.width - 8, 12)
    
    -- Draw eyes
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", self.x + 10, self.y + 12, 2, 2)
    love.graphics.rectangle("fill", self.x + 20, self.y + 12, 2, 2)
    
    -- Draw money pouch (small rectangle at side)
    love.graphics.setColor(0.6, 0.4, 0.2, 1)
    love.graphics.rectangle("fill", self.x - 4, self.y + 28, 8, 12)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function GuildMerchant:canInteract(playerX, playerY)
    local distance = math.sqrt((playerX - (self.x + self.width/2))^2 + (playerY - (self.y + self.height/2))^2)
    return distance <= self.interactionRange
end

function GuildMerchant:getInteractionPrompt()
    return "Press E to talk to Guild Merchant"
end

return GuildMerchant
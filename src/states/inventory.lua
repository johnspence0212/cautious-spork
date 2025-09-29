local InventoryState = {}

function InventoryState:enter(previousState)
    self.previousState = previousState or 'game'
    self.font = love.graphics.newFont(18)
    self.titleFont = love.graphics.newFont(24)
    
    -- Exit button properties
    self.exitButtonSize = 30
    self.exitButtonPadding = 10
end

function InventoryState:update(dt)
    -- Nothing to update for simple inventory
end

function InventoryState:draw()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    -- Dark semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, width, height)
    
    -- Main inventory panel
    local panelWidth = 400
    local panelHeight = 300
    local panelX = (width - panelWidth) / 2
    local panelY = (height - panelHeight) / 2
    
    -- Panel background
    love.graphics.setColor(0.2, 0.2, 0.3, 1)
    love.graphics.rectangle("fill", panelX, panelY, panelWidth, panelHeight)
    love.graphics.setColor(0.6, 0.6, 0.7, 1)
    love.graphics.rectangle("line", panelX, panelY, panelWidth, panelHeight)
    
    -- Title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.titleFont)
    local title = "Inventory"
    local titleWidth = self.titleFont:getWidth(title)
    love.graphics.print(title, panelX + (panelWidth - titleWidth) / 2, panelY + 20)
    
    -- Inventory content (placeholder)
    love.graphics.setFont(self.font)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    local content = {
        "Your inventory is empty.",
        "",
        "Press 'I' to close inventory",
        "Or click the X button"
    }
    
    for i, line in ipairs(content) do
        love.graphics.print(line, panelX + 20, panelY + 80 + (i - 1) * 25)
    end
    
    -- Draw exit button (X button in top right)
    self:drawExitButton()
end

function InventoryState:drawExitButton()
    local width = love.graphics.getWidth()
    local buttonSize = self.exitButtonSize
    local padding = self.exitButtonPadding
    
    -- Button position (top right corner)
    local buttonX = width - buttonSize - padding
    local buttonY = padding
    
    -- Check if mouse is over button
    local mouseX, mouseY = love.mouse.getPosition()
    local isHovered = mouseX >= buttonX and mouseX <= buttonX + buttonSize and
                     mouseY >= buttonY and mouseY <= buttonY + buttonSize
    
    -- Button background
    if isHovered then
        love.graphics.setColor(0.6, 0.2, 0.2, 0.8)
    else
        love.graphics.setColor(0.4, 0.4, 0.4, 0.8)
    end
    love.graphics.rectangle("fill", buttonX, buttonY, buttonSize, buttonSize)
    
    -- Button border
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.rectangle("line", buttonX, buttonY, buttonSize, buttonSize)
    
    -- X symbol
    love.graphics.setColor(1, 1, 1, 1)
    local xText = "×"
    local font = love.graphics.newFont(16)
    love.graphics.setFont(font)
    local textWidth = font:getWidth(xText)
    local textHeight = font:getHeight()
    love.graphics.print(xText, 
                       buttonX + (buttonSize - textWidth) / 2, 
                       buttonY + (buttonSize - textHeight) / 2)
end

function InventoryState:keypressed(key, scancode, isrepeat)
    if key == "i" then
        -- Close inventory and return to previous state
        StateManager:switch(self.previousState)
    end
end

function InventoryState:mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        -- Check if exit button was clicked
        local width = love.graphics.getWidth()
        local buttonSize = self.exitButtonSize
        local padding = self.exitButtonPadding
        local buttonX = width - buttonSize - padding
        local buttonY = padding
        
        if x >= buttonX and x <= buttonX + buttonSize and
           y >= buttonY and y <= buttonY + buttonSize then
            -- Exit button clicked - return to previous state
            StateManager:switch(self.previousState)
        end
    end
end

function InventoryState:exit()
    -- Clean up any resources if needed
end

return InventoryState
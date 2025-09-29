--[[
    CraftingState - UI layer for active crafting
    
    This is now a "thin" state that focuses only on:
    - Rendering the crafting progress UI
    - Handling input for skill usage
    - Delegating all logic to CraftingSystem
--]]

local CraftingState = {}

function CraftingState:enter(craftingSystem)
    -- UI resources
    self.fonts = {
        title = love.graphics.newFont(24),
        normal = love.graphics.newFont(16),
        small = love.graphics.newFont(14)
    }
    
    -- UI state for interaction
    self.hoveredSkill = nil
    self.mouseX = 0
    self.mouseY = 0
    
    -- Button layout constants
    self.buttonWidth = 120
    self.buttonHeight = 60
    self.buttonSpacing = 20
    self.skillBarY = love.graphics.getHeight() - 100
    
    -- Get reference to the crafting system (passed as parameter or from global)
    self.craftingSystem = craftingSystem or _G.CraftingSystem
    if not self.craftingSystem then
        error("CraftingState: CraftingSystem not found! Make sure GameState passes it as parameter.")
    end
    
    -- Verify we have an active crafting session
    if not self.craftingSystem:isCurrentlyCrafting() then
        print("Warning: Entered CraftingState but no active crafting session!")
        -- Could auto-return to previous state here
    end
end

function CraftingState:update(dt)
    -- Update mouse position for hover detection
    self.mouseX = love.mouse.getX()
    self.mouseY = love.mouse.getY()
    
    -- Check which skill button is hovered (using CraftingSystem skill data)
    self.hoveredSkill = nil
    local skills = self.craftingSystem:getSkills()
    local startX = (love.graphics.getWidth() - (5 * self.buttonWidth + 4 * self.buttonSpacing)) / 2
    
    for i, skill in ipairs(skills) do
        local buttonX = startX + (i - 1) * (self.buttonWidth + self.buttonSpacing)
        local buttonY = self.skillBarY
        
        if self.mouseX >= buttonX and self.mouseX <= buttonX + self.buttonWidth and
           self.mouseY >= buttonY and self.mouseY <= buttonY + self.buttonHeight then
            self.hoveredSkill = i
            break
        end
    end
    
    -- The system itself tracks completion state, no need to duplicate logic here
end

function CraftingState:draw()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    -- Get all data from CraftingSystem
    local craftingState = self.craftingSystem:getCraftingState()
    local recipe = craftingState.activeRecipe
    local skills = self.craftingSystem:getSkills()
    
    -- Safety check
    if not recipe then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.print("Error: No active recipe!", 10, 10)
        return
    end
    
    -- Dark crafting background
    love.graphics.clear(0.1, 0.05, 0.02, 1)
    
    -- Draw recipe being crafted
    love.graphics.setColor(1, 0.8, 0.4, 1) -- Golden
    love.graphics.setFont(self.fonts.title)
    local titleText = "Crafting: " .. recipe.name
    local titleWidth = self.fonts.title:getWidth(titleText)
    love.graphics.print(titleText, (width - titleWidth) / 2, 50)
    
    -- Draw recipe description
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.setFont(self.fonts.normal)
    local descWidth = self.fonts.normal:getWidth(recipe.description)
    love.graphics.print(recipe.description, (width - descWidth) / 2, 90)
    
    -- Draw materials needed
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.setFont(self.fonts.small)
    local materialsText = "Materials: " .. table.concat(recipe.materials, ", ")
    local materialsWidth = self.fonts.small:getWidth(materialsText)
    love.graphics.print(materialsText, (width - materialsWidth) / 2, 115)
    
    -- Draw progress bar (using system data)
    local progressBarWidth = 400
    local progressBarHeight = 30
    local progressBarX = (width - progressBarWidth) / 2
    local progressBarY = 180
    
    -- Progress bar background
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", progressBarX, progressBarY, progressBarWidth, progressBarHeight)
    
    -- Progress bar fill
    local fillWidth = (craftingState.progress / craftingState.maxProgress) * progressBarWidth
    love.graphics.setColor(0.2, 0.8, 0.2, 1) -- Green progress
    love.graphics.rectangle("fill", progressBarX, progressBarY, fillWidth, progressBarHeight)
    
    -- Progress bar border
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", progressBarX, progressBarY, progressBarWidth, progressBarHeight)
    
    -- Progress text
    love.graphics.setFont(self.fonts.normal)
    local progressText = math.floor(craftingState.progress) .. "/" .. craftingState.maxProgress
    local progressTextWidth = self.fonts.normal:getWidth(progressText)
    love.graphics.print(progressText, progressBarX + (progressBarWidth - progressTextWidth) / 2, progressBarY + 5)
    
    -- Draw skill buttons (using system data)
    local startX = (width - (5 * self.buttonWidth + 4 * self.buttonSpacing)) / 2
    
    for i, skill in ipairs(skills) do
        local buttonX = startX + (i - 1) * (self.buttonWidth + self.buttonSpacing)
        local buttonY = self.skillBarY
        
        -- Button background (highlighted if hovered)
        local color = skill.color
        if self.hoveredSkill == i then
            love.graphics.setColor(color[1] * 1.3, color[2] * 1.3, color[3] * 1.3, color[4])
        else
            love.graphics.setColor(color)
        end
        love.graphics.rectangle("fill", buttonX, buttonY, self.buttonWidth, self.buttonHeight)
        
        -- Button border
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", buttonX, buttonY, self.buttonWidth, self.buttonHeight)
        
        -- Button text
        love.graphics.setFont(self.fonts.normal)
        local keyText = skill.key .. ": " .. skill.name
        local keyTextWidth = self.fonts.normal:getWidth(keyText)
        love.graphics.print(keyText, buttonX + (self.buttonWidth - keyTextWidth) / 2, buttonY + 10)
    end
    
    -- Draw hover tooltip (using system data)
    if self.hoveredSkill then
        local skill = skills[self.hoveredSkill]
        local tooltipText = skill.description
        local tooltipWidth = self.fonts.small:getWidth(tooltipText) + 20
        local tooltipHeight = 30
        local tooltipX = self.mouseX - tooltipWidth / 2
        local tooltipY = self.mouseY - tooltipHeight - 10
        
        -- Keep tooltip on screen
        tooltipX = math.max(5, math.min(width - tooltipWidth - 5, tooltipX))
        tooltipY = math.max(5, tooltipY)
        
        -- Tooltip background
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", tooltipX, tooltipY, tooltipWidth, tooltipHeight)
        
        -- Tooltip border
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", tooltipX, tooltipY, tooltipWidth, tooltipHeight)
        
        -- Tooltip text
        love.graphics.setFont(self.fonts.small)
        love.graphics.print(tooltipText, tooltipX + 10, tooltipY + 8)
    end
    
    -- Draw instructions
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.fonts.small)
    if craftingState.isCompleted then
        love.graphics.print("Crafting Complete! Press ESC to return to game", 10, 10)
    else
        love.graphics.print("Use skills 1-5 to craft the item. Press ESC to cancel crafting.", 10, 10)
    end
    
    -- Draw completion message
    if craftingState.isCompleted then
        love.graphics.setColor(0, 1, 0, 1) -- Bright green
        love.graphics.setFont(self.fonts.title)
        local completeText = "CRAFTING COMPLETE!"
        local completeWidth = self.fonts.title:getWidth(completeText)
        love.graphics.print(completeText, (width - completeWidth) / 2, height / 2 - 50)
    end
end

function CraftingState:keypressed(key, scancode, isrepeat)
    if key == "escape" then
        -- Stop crafting and return to game
        self.craftingSystem:stopCrafting()
        StateManager:switch('game')
    else
        -- Use CraftingSystem to handle skill usage
        if self.craftingSystem:useSkillByKey(key) then
            -- Skill was used successfully
            -- Check if crafting completed
            if self.craftingSystem:isCraftingCompleted() then
                -- Could show completion animation or delay here
                -- For now, let the user manually exit
            end
        end
    end
end

function CraftingState:handleEscape()
    -- Custom escape handling - always return to game, never quit
    self.craftingSystem:stopCrafting()
    StateManager:switch('game')
end

-- useSkill method removed - now handled by CraftingSystem

function CraftingState:mousemoved(x, y, dx, dy, istouch)
    -- Mouse position is updated in update() function
end

function CraftingState:exit()
    -- Clean up any resources if needed
end

return CraftingState
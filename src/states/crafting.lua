local CraftingState = {}

function CraftingState:enter(recipe)
    self.recipe = recipe or {
        name = "Unknown Item",
        materials = {"Unknown"},
        description = "No recipe provided"
    }
    
    self.fonts = {
        title = love.graphics.newFont(24),
        normal = love.graphics.newFont(16),
        small = love.graphics.newFont(14)
    }
    
    -- Crafting progress
    self.progress = 0
    self.maxProgress = 100
    self.isCompleted = false
    
    -- Skill buttons (1-5)
    self.skills = {
        {
            key = "1",
            name = "Forge",
            description = "+25 to progress",
            progressBonus = 25,
            color = {0.8, 0.2, 0.2, 1} -- Red
        },
        {
            key = "2", 
            name = "Temper",
            description = "+15 to progress",
            progressBonus = 15,
            color = {0.2, 0.8, 0.2, 1} -- Green
        },
        {
            key = "3",
            name = "Polish",
            description = "+10 to progress",
            progressBonus = 10,
            color = {0.2, 0.2, 0.8, 1} -- Blue
        },
        {
            key = "4",
            name = "Sharpen",
            description = "+20 to progress",
            progressBonus = 20,
            color = {0.8, 0.8, 0.2, 1} -- Yellow
        },
        {
            key = "5",
            name = "Enchant",
            description = "+30 to progress",
            progressBonus = 30,
            color = {0.8, 0.2, 0.8, 1} -- Magenta
        }
    }
    
    -- UI state
    self.hoveredSkill = nil
    self.mouseX = 0
    self.mouseY = 0
    
    -- Button layout
    self.buttonWidth = 120
    self.buttonHeight = 60
    self.buttonSpacing = 20
    self.skillBarY = love.graphics.getHeight() - 100
end

function CraftingState:update(dt)
    -- Update mouse position for hover detection
    self.mouseX = love.mouse.getX()
    self.mouseY = love.mouse.getY()
    
    -- Check which skill button is hovered
    self.hoveredSkill = nil
    local startX = (love.graphics.getWidth() - (5 * self.buttonWidth + 4 * self.buttonSpacing)) / 2
    
    for i, skill in ipairs(self.skills) do
        local buttonX = startX + (i - 1) * (self.buttonWidth + self.buttonSpacing)
        local buttonY = self.skillBarY
        
        if self.mouseX >= buttonX and self.mouseX <= buttonX + self.buttonWidth and
           self.mouseY >= buttonY and self.mouseY <= buttonY + self.buttonHeight then
            self.hoveredSkill = i
            break
        end
    end
    
    -- Check if crafting is completed
    if self.progress >= self.maxProgress and not self.isCompleted then
        self.isCompleted = true
        -- Could add completion effects here
    end
end

function CraftingState:draw()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    -- Dark crafting background
    love.graphics.clear(0.1, 0.05, 0.02, 1)
    
    -- Draw recipe being crafted
    love.graphics.setColor(1, 0.8, 0.4, 1) -- Golden
    love.graphics.setFont(self.fonts.title)
    local titleText = "Crafting: " .. self.recipe.name
    local titleWidth = self.fonts.title:getWidth(titleText)
    love.graphics.print(titleText, (width - titleWidth) / 2, 50)
    
    -- Draw recipe description
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.setFont(self.fonts.normal)
    local descWidth = self.fonts.normal:getWidth(self.recipe.description)
    love.graphics.print(self.recipe.description, (width - descWidth) / 2, 90)
    
    -- Draw materials needed
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.setFont(self.fonts.small)
    local materialsText = "Materials: " .. table.concat(self.recipe.materials, ", ")
    local materialsWidth = self.fonts.small:getWidth(materialsText)
    love.graphics.print(materialsText, (width - materialsWidth) / 2, 115)
    
    -- Draw progress bar
    local progressBarWidth = 400
    local progressBarHeight = 30
    local progressBarX = (width - progressBarWidth) / 2
    local progressBarY = 180
    
    -- Progress bar background
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", progressBarX, progressBarY, progressBarWidth, progressBarHeight)
    
    -- Progress bar fill
    local fillWidth = (self.progress / self.maxProgress) * progressBarWidth
    love.graphics.setColor(0.2, 0.8, 0.2, 1) -- Green progress
    love.graphics.rectangle("fill", progressBarX, progressBarY, fillWidth, progressBarHeight)
    
    -- Progress bar border
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", progressBarX, progressBarY, progressBarWidth, progressBarHeight)
    
    -- Progress text
    love.graphics.setFont(self.fonts.normal)
    local progressText = math.floor(self.progress) .. "/" .. self.maxProgress
    local progressTextWidth = self.fonts.normal:getWidth(progressText)
    love.graphics.print(progressText, progressBarX + (progressBarWidth - progressTextWidth) / 2, progressBarY + 5)
    
    -- Draw skill buttons
    local startX = (width - (5 * self.buttonWidth + 4 * self.buttonSpacing)) / 2
    
    for i, skill in ipairs(self.skills) do
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
    
    -- Draw hover tooltip
    if self.hoveredSkill then
        local skill = self.skills[self.hoveredSkill]
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
    if self.isCompleted then
        love.graphics.print("Crafting Complete! Press ESC to return to game", 10, 10)
    else
        love.graphics.print("Use skills 1-5 to craft the item. Press ESC to cancel crafting.", 10, 10)
    end
    
    -- Draw completion message
    if self.isCompleted then
        love.graphics.setColor(0, 1, 0, 1) -- Bright green
        love.graphics.setFont(self.fonts.title)
        local completeText = "CRAFTING COMPLETE!"
        local completeWidth = self.fonts.title:getWidth(completeText)
        love.graphics.print(completeText, (width - completeWidth) / 2, height / 2 - 50)
    end
end

function CraftingState:keypressed(key, scancode, isrepeat)
    if key == "escape" then
        -- Return to game (or crafting select if you want)
        StateManager:switch('game')
    else
        -- Check skill buttons
        for i, skill in ipairs(self.skills) do
            if key == skill.key and not self.isCompleted then
                self:useSkill(skill)
                break
            end
        end
    end
end

function CraftingState:useSkill(skill)
    -- Add progress
    self.progress = math.min(self.maxProgress, self.progress + skill.progressBonus)
    
    -- Could add skill-specific effects or animations here
    print("Used " .. skill.name .. " - Progress: " .. self.progress .. "/" .. self.maxProgress)
end

function CraftingState:mousemoved(x, y, dx, dy, istouch)
    -- Mouse position is updated in update() function
end

function CraftingState:exit()
    -- Clean up any resources if needed
end

return CraftingState
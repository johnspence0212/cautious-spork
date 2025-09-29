--[[
    CraftingSelectState - UI layer for recipe selection
    
    This is now a "thin" state that focuses only on:
    - Rendering the recipe selection UI
    - Handling input for navigation
    - Delegating all logic to CraftingSystem
--]]

local CraftingSelectState = {}

function CraftingSelectState:enter(craftingSystem)
    -- UI resources
    self.font = love.graphics.newFont(18)
    self.titleFont = love.graphics.newFont(24)
    self.smallFont = love.graphics.newFont(14)
    
    -- Instructions for the UI
    self.instructions = {
        "Use UP/DOWN arrows to browse recipes",
        "Press ENTER to start crafting selected recipe",
        "Press ESC or C to exit crafting"
    }
    
    -- Scrolling state
    self.scrollOffset = 0
    self.itemHeight = 105 -- Height per recipe item (4 lines * 25 + padding)
    self.viewportHeight = love.graphics.getHeight() - 200 -- Space for title and instructions
    self.maxVisible = math.floor(self.viewportHeight / self.itemHeight)
    
    -- Get reference to the crafting system (passed as parameter or from global)
    self.craftingSystem = craftingSystem or _G.CraftingSystem
    if not self.craftingSystem then
        error("CraftingSelectState: CraftingSystem not found! Make sure GameState passes it as parameter.")
    end
end

function CraftingSelectState:update(dt)
    -- Update scroll position to keep selected recipe visible
    local selectedRecipe = self.craftingSystem:getSelectedRecipe()
    local recipes = self.craftingSystem:getRecipes()
    local selectedIndex = 1
    
    -- Find selected recipe index
    for i, recipe in ipairs(recipes) do
        if recipe.id == selectedRecipe.id then
            selectedIndex = i
            break
        end
    end
    
    -- Auto-scroll to keep selection visible
    local selectedY = (selectedIndex - 1) * self.itemHeight
    local viewportTop = self.scrollOffset
    local viewportBottom = self.scrollOffset + self.viewportHeight - self.itemHeight
    
    if selectedY < viewportTop then
        -- Scroll up to show selected item
        self.scrollOffset = selectedY
    elseif selectedY > viewportBottom then
        -- Scroll down to show selected item
        self.scrollOffset = selectedY - self.viewportHeight + self.itemHeight
    end
    
    -- Clamp scroll offset
    local maxScroll = math.max(0, (#recipes * self.itemHeight) - self.viewportHeight)
    self.scrollOffset = math.max(0, math.min(maxScroll, self.scrollOffset))
end

function CraftingSelectState:draw()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    -- Get data from CraftingSystem
    local recipes = self.craftingSystem:getRecipes()
    local selectedRecipe = self.craftingSystem:getSelectedRecipe()
    
    -- Dark background with anvil theme
    love.graphics.clear(0.15, 0.1, 0.05, 1)
    
    -- Draw title
    love.graphics.setColor(1, 0.8, 0.4, 1) -- Golden color
    love.graphics.setFont(self.titleFont)
    local title = "Anvil Crafting - Select Recipe (" .. #recipes .. " recipes)"
    local titleWidth = self.titleFont:getWidth(title)
    love.graphics.print(title, (width - titleWidth) / 2, 30)
    
    -- Set up clipping for scrollable area
    local clipX, clipY = 0, 100
    local clipWidth, clipHeight = width, self.viewportHeight
    
    -- Enable scissor test for clipping
    love.graphics.setScissor(clipX, clipY, clipWidth, clipHeight)
    
    -- Draw recipes list with scroll offset
    love.graphics.setFont(self.font)
    local startY = 100 - self.scrollOffset
    local lineHeight = 25
    
    for i, recipe in ipairs(recipes) do
        local y = startY + (i - 1) * self.itemHeight
        
        -- Skip items that are completely outside the viewport
        if y + self.itemHeight < 100 or y > 100 + self.viewportHeight then
            goto continue
        end
        
        -- Highlight selected recipe
        if recipe.id == selectedRecipe.id then
            love.graphics.setColor(0.3, 0.2, 0.1, 1)
            love.graphics.rectangle("fill", 50, y - 5, width - 100, self.itemHeight - 10)
        end
        
        -- Recipe name
        love.graphics.setColor(1, 1, 1, 1)
        if recipe.id == selectedRecipe.id then
            love.graphics.setColor(1, 0.8, 0.4, 1) -- Golden for selected
        end
        love.graphics.print(recipe.name, 70, y)
        
        -- Materials
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        love.graphics.setFont(self.smallFont)
        local materialsText = "Materials: " .. table.concat(recipe.materials, ", ")
        love.graphics.print(materialsText, 70, y + lineHeight)
        
        -- Description
        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        love.graphics.print(recipe.description, 70, y + lineHeight * 2)
        
        -- Difficulty and progress requirement
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.print("Difficulty: " .. recipe.difficulty .. " (" .. recipe.maxProgress .. " progress needed)", 70, y + lineHeight * 3)
        
        love.graphics.setFont(self.font)
        
        ::continue::
    end
    
    -- Disable scissor test
    love.graphics.setScissor()
    
    -- Draw scroll bar if needed
    if #recipes * self.itemHeight > self.viewportHeight then
        local scrollBarX = width - 20
        local scrollBarY = 100
        local scrollBarWidth = 15
        local scrollBarHeight = self.viewportHeight
        
        -- Scroll bar background
        love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
        love.graphics.rectangle("fill", scrollBarX, scrollBarY, scrollBarWidth, scrollBarHeight)
        
        -- Scroll bar thumb
        local totalContentHeight = #recipes * self.itemHeight
        local thumbHeight = math.max(20, (self.viewportHeight / totalContentHeight) * scrollBarHeight)
        local thumbY = scrollBarY + (self.scrollOffset / (totalContentHeight - self.viewportHeight)) * (scrollBarHeight - thumbHeight)
        
        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        love.graphics.rectangle("fill", scrollBarX + 2, thumbY, scrollBarWidth - 4, thumbHeight)
    end
    
    -- Draw instructions
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.smallFont)
    local instructY = height - 100
    for i, instruction in ipairs(self.instructions) do
        love.graphics.print(instruction, 20, instructY + (i - 1) * 18)
    end
    
    -- Draw anvil decoration in corner
    love.graphics.setColor(0.4, 0.4, 0.4, 0.3)
    love.graphics.rectangle("fill", width - 100, height - 80, 32, 24)
    love.graphics.rectangle("fill", width - 104, height - 90, 40, 15)
end

function CraftingSelectState:keypressed(key, scancode, isrepeat)
    if key == "escape" or key == "c" then
        -- Return to game state
        StateManager:switch('game')
    elseif key == "up" then
        -- Use CraftingSystem to handle selection logic
        self.craftingSystem:selectPreviousRecipe()
    elseif key == "down" then
        -- Use CraftingSystem to handle selection logic
        self.craftingSystem:selectNextRecipe()
    elseif key == "return" or key == "enter" then
        -- Start crafting the selected recipe through the system
        local selectedRecipe = self.craftingSystem:getSelectedRecipe()
        if self.craftingSystem:startCrafting(selectedRecipe) then
            StateManager:switch('crafting', self.craftingSystem)
        else
            print("Failed to start crafting!")
        end
    end
end

function CraftingSelectState:handleEscape()
    -- Custom escape handling - return to game instead of quitting
    StateManager:switch('game')
end

function CraftingSelectState:exit()
    -- Clean up any resources if needed
end

return CraftingSelectState
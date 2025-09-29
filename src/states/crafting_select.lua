local CraftingSelectState = {}

function CraftingSelectState:enter()
    self.font = love.graphics.newFont(18)
    self.titleFont = love.graphics.newFont(24)
    self.smallFont = love.graphics.newFont(14)
    
    -- Sample crafting recipes (you can expand this)
    self.recipes = {
        {
            name = "Iron Sword",
            materials = {"Iron Bar x2", "Wood Handle x1"},
            description = "A basic iron sword"
        },
        {
            name = "Steel Armor",
            materials = {"Steel Bar x5", "Leather x2"},
            description = "Protective steel armor"
        },
        {
            name = "Magic Ring",
            materials = {"Gold Bar x1", "Gem x1", "Magic Essence x1"},
            description = "A ring imbued with magic"
        }
    }
    
    self.selectedRecipe = 1
    self.instructions = {
        "Use UP/DOWN arrows to browse recipes",
        "Press ENTER to start crafting selected recipe",
        "Press ESC or C to exit crafting"
    }
end

function CraftingSelectState:update(dt)
    -- Crafting state doesn't need continuous updates for now
end

function CraftingSelectState:draw()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    -- Dark background with anvil theme
    love.graphics.clear(0.15, 0.1, 0.05, 1)
    
    -- Draw title
    love.graphics.setColor(1, 0.8, 0.4, 1) -- Golden color
    love.graphics.setFont(self.titleFont)
    local title = "Anvil Crafting"
    local titleWidth = self.titleFont:getWidth(title)
    love.graphics.print(title, (width - titleWidth) / 2, 30)
    
    -- Draw recipes list
    love.graphics.setFont(self.font)
    local startY = 100
    local lineHeight = 25
    
    for i, recipe in ipairs(self.recipes) do
        local y = startY + (i - 1) * (lineHeight * 3 + 20)
        
        -- Highlight selected recipe
        if i == self.selectedRecipe then
            love.graphics.setColor(0.3, 0.2, 0.1, 1)
            love.graphics.rectangle("fill", 50, y - 5, width - 100, lineHeight * 3 + 10)
        end
        
        -- Recipe name
        love.graphics.setColor(1, 1, 1, 1)
        if i == self.selectedRecipe then
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
        
        love.graphics.setFont(self.font)
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
        self.selectedRecipe = math.max(1, self.selectedRecipe - 1)
    elseif key == "down" then
        self.selectedRecipe = math.min(#self.recipes, self.selectedRecipe + 1)
    elseif key == "return" or key == "enter" then
        -- Start crafting the selected recipe
        local selectedRecipe = self.recipes[self.selectedRecipe]
        StateManager:switch('crafting', selectedRecipe)
    end
end

function CraftingSelectState:exit()
    -- Clean up any resources if needed
end

return CraftingSelectState
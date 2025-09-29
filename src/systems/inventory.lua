--[[
    InventorySystem - Manages player inventory (Bag of Holding + Recipe Book)
    
    Features:
    - Bag of Holding: stores completed crafted items
    - Recipe Book: tracks unlocked and completed recipes
    - Statistics tracking and caching
    - Save/load functionality
    - UI support with selection and sorting
    - Event system for UI updates
--]]

local InventoryData = require('data.inventory')
local RecipeData = require('data.recipes')

local InventorySystem = {}
InventorySystem.__index = InventorySystem

function InventorySystem:new()
    local instance = {
        -- Core data
        bagOfHolding = {},
        recipeBook = {},
        
        -- UI state
        selectedBagItem = 1,
        selectedRecipeItem = 1,
        currentTab = "bag",
        bagSortMode = "name",
        
        -- Events
        onItemAdded = nil,
        onItemRemoved = nil,
        onRecipeUnlocked = nil,
        onRecipeCompleted = nil,
        
        -- Cache
        cache = {
            unlocked = nil,
            bagStats = nil,
            recipeStats = nil,
            lastUpdate = 0
        }
    }
    
    setmetatable(instance, self)
    
    -- Initialize empty inventory
    instance:createStarterInventory()
    
    print("InventorySystem: Initialized")
    
    return instance
end

-- ============= BAG OF HOLDING MANAGEMENT =============

function InventorySystem:addItem(recipeId, quantity, quality)
    quantity = quantity or 1
    quality = quality or "Normal"
    
    -- Find existing item or create new one
    local existingItem = nil
    for _, item in ipairs(self.bagOfHolding) do
        if item.recipeId == recipeId and item.quality == quality then
            existingItem = item
            break
        end
    end
    
    if existingItem then
        existingItem.quantity = existingItem.quantity + quantity
    else
        local newItem = {
            recipeId = recipeId,
            quantity = quantity,
            quality = quality,
            dateAdded = os.time()
        }
        table.insert(self.bagOfHolding, newItem)
        existingItem = newItem
    end
    
    -- Clear cache
    self:clearCache()
    
    -- Get recipe info for logging
    local recipe = RecipeData.getById(recipeId)
    local recipeName = recipe and recipe.name or "Unknown Item"
    
    print("InventorySystem: Added " .. quantity .. "x " .. recipeName .. " (" .. quality .. ") to bag")
    
    -- Fire event
    if self.onItemAdded then
        self.onItemAdded(item, quantity)
    end
    
    return item
end

function InventorySystem:removeItem(recipeId, quantity, quality)
    quantity = quantity or 1
    quality = quality or "Normal"
    
    for i, item in ipairs(self.bagOfHolding) do
        if item.recipeId == recipeId and item.quality == quality then
            if item.quantity >= quantity then
                item.quantity = item.quantity - quantity
                if item.quantity <= 0 then
                    table.remove(self.bagOfHolding, i)
                end
                
                -- Clear cache
                self:clearCache()
                
                -- Get recipe info for logging
                local recipe = RecipeData.getById(recipeId)
                local recipeName = recipe and recipe.name or "Unknown Item"
                
                print("InventorySystem: Removed " .. quantity .. "x " .. recipeName .. " (" .. quality .. ") from bag")
                
                -- Fire event
                if self.onItemRemoved then
                    self.onItemRemoved(recipeId, quantity, quality)
                end
                
                return true
            end
        end
    end
    
    return false
end

function InventorySystem:getItemQuantity(recipeId, quality)
    quality = quality or "Normal"
    
    for _, item in ipairs(self.bagOfHolding) do
        if item.recipeId == recipeId and item.quality == quality then
            return item.quantity
        end
    end
    
    return 0
end

function InventorySystem:getBagContents()
    return self.bagOfHolding
end

function InventorySystem:sortBag(sortMode)
    self.bagSortMode = sortMode or self.bagSortMode
    
    local sortFunctions = {
        name = function(a, b)
            local recipeA = RecipeData.getById(a.recipeId)
            local recipeB = RecipeData.getById(b.recipeId)
            if recipeA and recipeB then
                return recipeA.name < recipeB.name
            end
            return false
        end,
        quantity = function(a, b) return a.quantity > b.quantity end,
        date = function(a, b) return a.dateAdded > b.dateAdded end,
        quality = function(a, b)
            local order = {Normal = 1, Fine = 2, Exceptional = 3, Masterwork = 4}
            return (order[a.quality] or 1) > (order[b.quality] or 1)
        end,
        value = function(a, b)
            local recipeA = RecipeData.getById(a.recipeId)
            local recipeB = RecipeData.getById(b.recipeId)
            if recipeA and recipeB then
                return (recipeA.value * a.quantity) > (recipeB.value * b.quantity)
            end
            return false
        end
    }
    
    if sortFunctions[self.bagSortMode] then
        table.sort(self.bagOfHolding, sortFunctions[self.bagSortMode])
    end
    
    self:clearCache()
end

-- ============= RECIPE BOOK MANAGEMENT =============

function InventorySystem:unlockRecipe(recipeId)
    -- Check if already unlocked
    for _, entry in ipairs(self.recipeBook) do
        if entry.recipeId == recipeId then
            return entry -- Already unlocked
        end
    end
    
    -- Create new entry
    local entry = {
        recipeId = recipeId,
        dateUnlocked = os.time(),
        timesCompleted = 0,
        favorite = false
    }
    
    table.insert(self.recipeBook, entry)
    
    -- Clear cache
    self:clearCache()
    
    -- Get recipe info for logging
    local recipe = RecipeData.getById(recipeId)
    local recipeName = recipe and recipe.name or "Unknown Recipe"
    
    print("InventorySystem: Unlocked recipe - " .. recipeName)
    
    -- Fire event
    if self.onRecipeUnlocked then
        self.onRecipeUnlocked(entry)
    end
    
    return entry
end

function InventorySystem:completeRecipe(recipeId)
    local entry = nil
    for _, e in ipairs(self.recipeBook) do
        if e.recipeId == recipeId then
            e.timesCompleted = e.timesCompleted + 1
            entry = e
            break
        end
    end
    
    -- Clear cache
    self:clearCache()
    
    -- Get recipe info for logging
    local recipe = RecipeData.getById(recipeId)
    local recipeName = recipe and recipe.name or "Unknown Recipe"
    
    print("InventorySystem: Completed recipe - " .. recipeName .. " (total: " .. entry.timesCompleted .. " times)")
    
    -- Fire event
    if self.onRecipeCompleted then
        self.onRecipeCompleted(entry)
    end
    
    return entry
end

function InventorySystem:getUnlockedRecipes()
    -- Use cache if available and recent
    if self.cache.unlocked and (os.time() - self.cache.lastUpdate) < 1 then
        return self.cache.unlocked
    end
    
    -- Rebuild cache - sort by favorites first, then by name
    local unlocked = {}
    for _, entry in ipairs(self.recipeBook) do
        table.insert(unlocked, entry)
    end
    
    table.sort(unlocked, function(a, b)
        if a.favorite and not b.favorite then return true end
        if not a.favorite and b.favorite then return false end
        
        local recipeA = RecipeData.getById(a.recipeId)
        local recipeB = RecipeData.getById(b.recipeId)
        
        if recipeA and recipeB then
            return recipeA.name < recipeB.name
        end
        
        return false
    end)
    
    self.cache.unlocked = unlocked
    self.cache.lastUpdate = os.time()
    
    return unlocked
end

function InventorySystem:getRecipeBook()
    return self.recipeBook
end

function InventorySystem:isRecipeUnlocked(recipeId)
    for _, entry in ipairs(self.recipeBook) do
        if entry.recipeId == recipeId and entry.unlocked then
            return true
        end
    end
    return false
end

function InventorySystem:getRecipeCompletionCount(recipeId)
    for _, entry in ipairs(self.recipeBook) do
        if entry.recipeId == recipeId then
            return entry.timesCompleted
        end
    end
    return 0
end

function InventorySystem:toggleRecipeFavorite(recipeId)
    for _, entry in ipairs(self.recipeBook) do
        if entry.recipeId == recipeId then
            entry.favorite = not entry.favorite
            self:clearCache()
            return entry.favorite
        end
    end
    
    self:clearCache()
    return false
end

-- ============= INTEGRATION WITH CRAFTING SYSTEM =============

function InventorySystem:getAvailableRecipes()
    -- Return only unlocked recipes that the crafting system can use
    local unlocked = self:getUnlockedRecipes()
    local available = {}
    
    for _, entry in ipairs(unlocked) do
        local recipe = RecipeData.getById(entry.recipeId)
        if recipe then
            table.insert(available, recipe)
        end
    end
    
    return available
end

function InventorySystem:onCraftingCompleted(recipe, quality)
    -- Called by CraftingSystem when an item is completed
    quality = quality or "Normal"
    
    -- Add completed item to bag
    self:addItem(recipe.id, 1, quality)
    
    -- Mark recipe as completed in recipe book
    self:completeRecipe(recipe.id)
    
    print("InventorySystem: Crafting completed - " .. recipe.name .. " added to inventory")
end

-- ============= UI SUPPORT =============

function InventorySystem:setCurrentTab(tab)
    if tab == "bag" or tab == "recipes" then
        self.currentTab = tab
    end
end

function InventorySystem:getCurrentTab()
    return self.currentTab
end

function InventorySystem:selectBagItem(index)
    self.selectedBagItem = math.max(1, math.min(#self.bagOfHolding, index))
end

function InventorySystem:selectRecipeItem(index)
    local unlocked = self:getUnlockedRecipes()
    self.selectedRecipeItem = math.max(1, math.min(#unlocked, index))
end

function InventorySystem:getSelectedBagItem()
    if #self.bagOfHolding > 0 then
        return self.bagOfHolding[self.selectedBagItem]
    end
    return nil
end

function InventorySystem:getSelectedRecipe()
    local unlocked = self:getUnlockedRecipes()
    if #unlocked > 0 then
        local entry = unlocked[self.selectedRecipeItem]
        return RecipeData.getById(entry.recipeId), entry
    end
    return nil, nil
end

-- ============= STATISTICS =============

function InventorySystem:getBagStats()
    -- Use cache if available and recent
    if self.cache.bagStats and (os.time() - self.cache.lastUpdate) < 1 then
        return self.cache.bagStats
    end
    
    -- Calculate stats
    local stats = {
        totalItems = 0,
        totalValue = 0,
        qualityBreakdown = {
            Normal = 0,
            Fine = 0,
            Exceptional = 0,
            Masterwork = 0
        }
    }
    
    for _, item in ipairs(self.bagOfHolding) do
        local recipe = RecipeData.getById(item.recipeId)
        if recipe then
            stats.totalItems = stats.totalItems + item.quantity
            stats.totalValue = stats.totalValue + (recipe.value * item.quantity)
            stats.qualityBreakdown[item.quality] = (stats.qualityBreakdown[item.quality] or 0) + item.quantity
        end
    end
    
    self.cache.bagStats = stats
    return stats
end

function InventorySystem:getRecipeBookStats()
    if self.cache.recipeStats and (os.time() - self.cache.lastUpdate) < 1 then
        return self.cache.recipeStats
    end
    
    local totalRecipes = #RecipeData.getAll()
    local unlockedCount = #self.recipeBook
    local completedCount = 0
    
    for _, entry in ipairs(self.recipeBook) do
        if entry.timesCompleted > 0 then
            completedCount = completedCount + 1
        end
    end
    
    local stats = {
        totalRecipes = totalRecipes,
        unlockedCount = unlockedCount,
        completedCount = completedCount,
        completionRate = unlockedCount > 0 and (completedCount / unlockedCount) or 0
    }
    
    self.cache.recipeStats = stats
    return stats
end

function InventorySystem:getInventoryStats()
    return {
        bag = self:getBagStats(),
        recipeBook = self:getRecipeBookStats()
    }
end

-- ============= PERSISTENCE =============

function InventorySystem:saveInventory()
    local data = self.inventoryData.serializeInventory(self.bagOfHolding, self.recipeBook)
    -- In a real game, you'd save this to a file
    -- For now, just return the data for potential saving
    return data
end

function InventorySystem:loadInventory(data)
    local bag, recipeBook = self.inventoryData.deserializeInventory(data)
    
    -- Validate loaded data
    local valid, issues = self.inventoryData.validateInventory(bag, recipeBook)
    if not valid then
        print("InventorySystem: Warning - loaded inventory has issues:")
        for _, issue in ipairs(issues) do
            print("  - " .. issue)
        end
        -- Could fall back to starter inventory here
    end
    
    self.bagOfHolding = bag
    self.recipeBook = recipeBook
    self:clearCache()
    
    print("InventorySystem: Loaded inventory with " .. #bag .. " items and " .. #recipeBook .. " recipes")
end

-- ============= CACHE MANAGEMENT =============

function InventorySystem:clearCache()
    self.cache.unlocked = nil
    self.cache.bagStats = nil
    self.cache.recipeStats = nil
    self.cache.lastUpdate = 0
end

function InventorySystem:update(dt)
    -- System doesn't need continuous updates for now
    -- But this is where you'd add:
    -- - Item decay over time
    -- - Durability degradation
    -- - Auto-sorting
    -- - Cache management
end

-- ============= EVENT SYSTEM =============

function InventorySystem:setOnItemAdded(callback)
    self.onItemAdded = callback
end

function InventorySystem:setOnItemRemoved(callback)
    self.onItemRemoved = callback
end

function InventorySystem:setOnRecipeUnlocked(callback)
    self.onRecipeUnlocked = callback
end

function InventorySystem:setOnRecipeCompleted(callback)
    self.onRecipeCompleted = callback
end

-- ============= DEBUG/UTILITY =============

function InventorySystem:debugPrint()
    print("=== InventorySystem Debug ===")
    print("Bag Items: " .. #self.bagOfHolding)
    print("Recipe Book Entries: " .. #self.recipeBook)
    print("Current Tab: " .. self.currentTab)
    print("Selected Bag Item: " .. self.selectedBagItem)
    print("Selected Recipe Item: " .. self.selectedRecipeItem)
    
    local stats = self:getInventoryStats()
    print("Total Items: " .. stats.bag.totalItems)
    print("Total Value: " .. stats.bag.totalValue)
    print("Unlocked Recipes: " .. stats.recipeBook.unlockedCount)
    print("Completed Recipes: " .. stats.recipeBook.completedCount)
    print("=========================")
end

function InventorySystem:createStarterInventory()
    -- Initialize empty inventory - recipes will be unlocked by game state
    self.bagOfHolding = {}
    self.recipeBook = {}
end

function InventorySystem:giveTestItems()
    -- For testing - give player some items
    self:unlockRecipe(2) -- Steel Armor
    self:unlockRecipe(4) -- Steel Chestplate
    self:addItem(1, 3, "Normal")      -- 3x Iron Sword
    self:addItem(1, 1, "Fine")        -- 1x Fine Iron Sword
    self:addItem(9, 5, "Normal")      -- 5x Healing Potion
    print("InventorySystem: Added test items and recipes")
end

return InventorySystem
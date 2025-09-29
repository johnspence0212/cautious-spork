--[[
    Recipes Data - All crafting recipes for the game
    
    This file contains the complete recipe database that drives the crafting system.
    Each recipe defines what can be crafted, materials needed, difficulty, and progress requirements.
    
    Recipe Schema:
    {
        id = unique_number,
        name = "Display Name",
        materials = {"Material 1 x qty", "Material 2 x qty", ...},
        description = "Flavor text description",
        maxProgress = number,  -- How much progress needed to complete
        difficulty = "Easy|Medium|Hard|Master",
        category = "Weapons|Armor|Tools|Consumables|Magic", -- For future organization
        unlockLevel = number,  -- For future progression system
        craftTime = number,    -- For future time-based crafting
        value = number         -- For future economy system
    }
--]]

local recipes = {
    -- ===== WEAPONS =====
    {
        id = 1,
        name = "Iron Sword",
        materials = {"Iron Bar x2", "Wood Handle x1", "Leather Grip x1"},
        description = "A reliable iron blade, sharp and balanced for combat",
        maxProgress = 100,
        difficulty = "Easy",
        category = "Weapons",
        unlockLevel = 1,
        craftTime = 300, -- 5 minutes
        value = 50
    },
    
    {
        id = 2,
        name = "Steel Longsword", 
        materials = {"Steel Bar x3", "Iron Crossguard x1", "Leather Wrap x2"},
        description = "A masterfully forged longsword with superior reach and damage",
        maxProgress = 150,
        difficulty = "Medium",
        category = "Weapons",
        unlockLevel = 3,
        craftTime = 600, -- 10 minutes
        value = 120
    },
    
    {
        id = 3,
        name = "Enchanted Blade",
        materials = {"Mithril Bar x2", "Enchanted Crystal x1", "Dragon Scale x1"},
        description = "A mystical weapon humming with arcane energy",
        maxProgress = 250,
        difficulty = "Master",
        category = "Weapons",
        unlockLevel = 8,
        craftTime = 1200, -- 20 minutes
        value = 500
    },
    
    -- ===== ARMOR =====
    {
        id = 4,
        name = "Steel Chestplate",
        materials = {"Steel Bar x5", "Leather Padding x3", "Iron Buckles x4"},
        description = "Heavy steel armor providing excellent protection",
        maxProgress = 180,
        difficulty = "Medium",
        category = "Armor",
        unlockLevel = 4,
        craftTime = 900, -- 15 minutes
        value = 200
    },
    
    {
        id = 5,
        name = "Chainmail Hauberk",
        materials = {"Iron Wire x10", "Steel Rings x50", "Cloth Lining x2"},
        description = "Flexible armor made of interlocked metal rings",
        maxProgress = 200,
        difficulty = "Hard",
        category = "Armor",
        unlockLevel = 5,
        craftTime = 1800, -- 30 minutes
        value = 300
    },
    
    -- ===== TOOLS =====
    {
        id = 6,
        name = "Iron Pickaxe",
        materials = {"Iron Bar x3", "Oak Handle x1", "Steel Head x1"},
        description = "A sturdy pickaxe for mining stone and ore",
        maxProgress = 120,
        difficulty = "Easy",
        category = "Tools",
        unlockLevel = 2,
        craftTime = 450, -- 7.5 minutes
        value = 75
    },
    
    {
        id = 7,
        name = "Masterwork Hammer",
        materials = {"Steel Bar x4", "Hardwood Handle x1", "Grip Leather x1"},
        description = "A perfectly balanced hammer for precision crafting",
        maxProgress = 160,
        difficulty = "Hard",
        category = "Tools",
        unlockLevel = 6,
        craftTime = 720, -- 12 minutes
        value = 180
    },
    
    -- ===== MAGIC ITEMS =====
    {
        id = 8,
        name = "Ring of Power",
        materials = {"Gold Bar x1", "Sapphire x1", "Magic Essence x2"},
        description = "A ring that pulses with mystical energy and ancient power",
        maxProgress = 200,
        difficulty = "Hard",
        category = "Magic",
        unlockLevel = 7,
        craftTime = 1500, -- 25 minutes
        value = 800
    },
    
    {
        id = 9,
        name = "Healing Potion",
        materials = {"Glass Vial x1", "Red Herb x3", "Spring Water x1"},
        description = "A crimson potion that restores health when consumed",
        maxProgress = 80,
        difficulty = "Easy",
        category = "Consumables",
        unlockLevel = 1,
        craftTime = 180, -- 3 minutes
        value = 25
    },
    
    {
        id = 10,
        name = "Arcane Staff",
        materials = {"Wizard Wood x1", "Crystal Orb x1", "Mana Silk x2", "Silver Inlay x1"},
        description = "A staff that amplifies magical abilities and channels arcane forces",
        maxProgress = 300,
        difficulty = "Master",
        category = "Magic",
        unlockLevel = 10,
        craftTime = 2400, -- 40 minutes
        value = 1200
    }
}

-- Helper functions for recipe management
local RecipeData = {}

function RecipeData.getAll()
    return recipes
end

function RecipeData.getById(id)
    for _, recipe in ipairs(recipes) do
        if recipe.id == id then
            return recipe
        end
    end
    return nil
end

function RecipeData.getByCategory(category)
    local filtered = {}
    for _, recipe in ipairs(recipes) do
        if recipe.category == category then
            table.insert(filtered, recipe)
        end
    end
    return filtered
end

function RecipeData.getByDifficulty(difficulty)
    local filtered = {}
    for _, recipe in ipairs(recipes) do
        if recipe.difficulty == difficulty then
            table.insert(filtered, recipe)
        end
    end
    return filtered
end

function RecipeData.getByUnlockLevel(maxLevel)
    local filtered = {}
    for _, recipe in ipairs(recipes) do
        if recipe.unlockLevel <= maxLevel then
            table.insert(filtered, recipe)
        end
    end
    return filtered
end

function RecipeData.getCategories()
    local categories = {}
    local seen = {}
    for _, recipe in ipairs(recipes) do
        if not seen[recipe.category] then
            table.insert(categories, recipe.category)
            seen[recipe.category] = true
        end
    end
    return categories
end

function RecipeData.getDifficulties()
    return {"Easy", "Medium", "Hard", "Master"}
end

-- Validation function
function RecipeData.validate()
    local issues = {}
    local ids = {}
    
    for i, recipe in ipairs(recipes) do
        -- Check for required fields
        if not recipe.id then
            table.insert(issues, "Recipe " .. i .. " missing id")
        elseif ids[recipe.id] then
            table.insert(issues, "Duplicate recipe id: " .. recipe.id)
        else
            ids[recipe.id] = true
        end
        
        if not recipe.name or recipe.name == "" then
            table.insert(issues, "Recipe " .. (recipe.id or i) .. " missing name")
        end
        
        if not recipe.materials or #recipe.materials == 0 then
            table.insert(issues, "Recipe " .. (recipe.id or i) .. " missing materials")
        end
        
        if not recipe.maxProgress or recipe.maxProgress <= 0 then
            table.insert(issues, "Recipe " .. (recipe.id or i) .. " invalid maxProgress")
        end
    end
    
    return #issues == 0, issues
end

return RecipeData
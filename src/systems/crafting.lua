--[[
    CraftingSystem - Handles all crafting logic and data
    
    Responsibilities:
    - Store and manage recipes (loaded from data/recipes.lua)
    - Track crafting progress and state
    - Handle skill usage and bonuses (loaded from data/skills.lua)
    - Validate crafting completion
    - Manage active crafting session
    
    This system is UI-agnostic and data-driven - it loads content from external
    data files, making it easy to modify recipes and skills without touching code.
--]]

-- Import data modules
local RecipeData = require('data.recipes')
local SkillData = require('data.skills')

local CraftingSystem = {}
CraftingSystem.__index = CraftingSystem

function CraftingSystem:new()
    -- Validate data files on initialization
    local recipeValid, recipeIssues = RecipeData.validate()
    local skillValid, skillIssues = SkillData.validate()
    
    if not recipeValid then
        error("CraftingSystem: Recipe data validation failed:\n" .. table.concat(recipeIssues, "\n"))
    end
    
    if not skillValid then
        error("CraftingSystem: Skill data validation failed:\n" .. table.concat(skillIssues, "\n"))
    end
    
    print("CraftingSystem: Loaded " .. #RecipeData.getAll() .. " recipes and " .. #SkillData.getAll() .. " skills")
    
    local instance = {
        -- Data is now loaded from external files
        recipeData = RecipeData,
        skillData = SkillData,
        
        -- Current crafting session state
        activeRecipe = nil,
        progress = 0,
        isActive = false,
        isCompleted = false,
        selectedRecipeIndex = 1, -- For recipe selection UI
        
        -- Events (simple callback system)
        onCraftingComplete = nil,
        onProgressChanged = nil
    }
    
    setmetatable(instance, self)
    return instance
end

-- ============= RECIPE MANAGEMENT =============

function CraftingSystem:getRecipes()
    return self.recipeData.getAll()
end

function CraftingSystem:getRecipe(id)
    return self.recipeData.getById(id)
end

function CraftingSystem:getRecipesByCategory(category)
    return self.recipeData.getByCategory(category)
end

function CraftingSystem:getRecipesByDifficulty(difficulty)
    return self.recipeData.getByDifficulty(difficulty)
end

function CraftingSystem:getSelectedRecipe()
    local recipes = self:getRecipes()
    return recipes[self.selectedRecipeIndex]
end

function CraftingSystem:setSelectedRecipe(index)
    local recipes = self:getRecipes()
    self.selectedRecipeIndex = math.max(1, math.min(#recipes, index))
end

function CraftingSystem:selectNextRecipe()
    self:setSelectedRecipe(self.selectedRecipeIndex + 1)
end

function CraftingSystem:selectPreviousRecipe()
    self:setSelectedRecipe(self.selectedRecipeIndex - 1)
end

-- ============= CRAFTING SESSION MANAGEMENT =============

function CraftingSystem:startCrafting(recipe)
    if not recipe then
        print("CraftingSystem: Cannot start crafting - no recipe provided")
        return false
    end
    
    self.activeRecipe = recipe
    self.progress = 0
    self.isActive = true
    self.isCompleted = false
    
    print("CraftingSystem: Started crafting " .. recipe.name)
    return true
end

function CraftingSystem:stopCrafting()
    if self.activeRecipe then
        print("CraftingSystem: Stopped crafting " .. self.activeRecipe.name)
    else
        print("CraftingSystem: Stopped crafting (no active recipe)")
    end
    
    self.activeRecipe = nil
    self.progress = 0
    self.isActive = false
    self.isCompleted = false
end

function CraftingSystem:isCurrentlyCrafting()
    return self.isActive and not self.isCompleted
end

function CraftingSystem:isCraftingCompleted()
    return self.isCompleted
end

-- ============= SKILL SYSTEM =============

function CraftingSystem:getSkills()
    -- Return only active skills (first 5 for current UI)
    return self.skillData.getActive(5)
end

function CraftingSystem:getAllSkills()
    return self.skillData.getAll()
end

function CraftingSystem:getSkill(id)
    return self.skillData.getById(id)
end

function CraftingSystem:getSkillByKey(key)
    return self.skillData.getByKey(key)
end

function CraftingSystem:getSkillsByCategory(category)
    return self.skillData.getByCategory(category)
end

function CraftingSystem:useSkill(skillId)
    if not self:isCurrentlyCrafting() then
        print("CraftingSystem: Cannot use skill - not currently crafting")
        return false
    end
    
    local skill = self:getSkill(skillId)
    if not skill then
        print("CraftingSystem: Invalid skill ID: " .. tostring(skillId))
        return false
    end
    
    -- Add progress
    local oldProgress = self.progress
    self.progress = math.min(self.activeRecipe.maxProgress, self.progress + skill.progressBonus)
    
    print("CraftingSystem: Used " .. skill.name .. " - Progress: " .. self.progress .. "/" .. self.activeRecipe.maxProgress)
    
    -- Check for completion
    if self.progress >= self.activeRecipe.maxProgress then
        self.isCompleted = true
        print("CraftingSystem: Crafting completed!")
        
        -- Fire completion callback if set
        if self.onCraftingComplete then
            self.onCraftingComplete(self.activeRecipe)
        end
    end
    
    -- Fire progress changed callback if set
    if self.onProgressChanged then
        self.onProgressChanged(self.progress, self.activeRecipe.maxProgress, self.progress - oldProgress)
    end
    
    return true
end

function CraftingSystem:useSkillByKey(key)
    local skill = self:getSkillByKey(key)
    if skill then
        return self:useSkill(skill.id)
    end
    return false
end

-- ============= PROGRESS TRACKING =============

function CraftingSystem:getProgress()
    return self.progress
end

function CraftingSystem:getMaxProgress()
    return self.activeRecipe and self.activeRecipe.maxProgress or 100
end

function CraftingSystem:getProgressPercentage()
    local maxProgress = self:getMaxProgress()
    if maxProgress == 0 then return 0 end
    return (self.progress / maxProgress) * 100
end

-- ============= STATE QUERIES =============

function CraftingSystem:getActiveRecipe()
    return self.activeRecipe
end

function CraftingSystem:getCraftingState()
    return {
        isActive = self.isActive,
        isCompleted = self.isCompleted,
        activeRecipe = self.activeRecipe,
        progress = self.progress,
        maxProgress = self:getMaxProgress(),
        progressPercentage = self:getProgressPercentage()
    }
end

-- ============= UPDATE LOOP =============

function CraftingSystem:update(dt)
    -- System doesn't need continuous updates for now
    -- But this is where you'd add things like:
    -- - Time-based progress decay
    -- - Skill cooldowns
    -- - Animation state management
    -- - Sound effect triggers
end

-- ============= EVENT SYSTEM =============

function CraftingSystem:setOnCraftingComplete(callback)
    self.onCraftingComplete = callback
end

function CraftingSystem:setOnProgressChanged(callback)
    self.onProgressChanged = callback
end

-- ============= DATA-DRIVEN QUERIES =============

function CraftingSystem:getRecipeCategories()
    return self.recipeData.getCategories()
end

function CraftingSystem:getRecipeDifficulties()
    return self.recipeData.getDifficulties()
end

function CraftingSystem:getSkillCategories()
    return self.skillData.getCategories()
end

function CraftingSystem:getTotalSkillPotential(playerLevel)
    return self.skillData.getTotalProgressPotential(playerLevel)
end

-- ============= DEBUG/UTILITY =============

function CraftingSystem:debugPrint()
    print("=== CraftingSystem Debug ===")
    print("Active: " .. tostring(self.isActive))
    print("Completed: " .. tostring(self.isCompleted))
    print("Recipe: " .. (self.activeRecipe and self.activeRecipe.name or "none"))
    print("Progress: " .. self.progress .. "/" .. self:getMaxProgress())
    print("Selected Recipe Index: " .. self.selectedRecipeIndex)
    print("Total Recipes: " .. #self:getRecipes())
    print("Total Skills: " .. #self:getAllSkills())
    print("Active Skills: " .. #self:getSkills())
    print("========================")
end

function CraftingSystem:debugDataFiles()
    print("=== Data File Contents ===")
    print("Recipe Categories: " .. table.concat(self:getRecipeCategories(), ", "))
    print("Skill Categories: " .. table.concat(self:getSkillCategories(), ", "))
    print("Difficulties: " .. table.concat(self:getRecipeDifficulties(), ", "))
    print("========================")
end

return CraftingSystem
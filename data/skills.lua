--[[
    Skills Data - All crafting skills for the game
    
    This file contains the complete skill database that drives the crafting system.
    Each skill defines how players can interact with crafting, progress bonuses, and visual presentation.
    
    Skill Schema:
    {
        id = unique_number,
        key = "keyboard_key",  -- Which key activates this skill
        name = "Display Name",
        description = "Tooltip description (+X to progress)",
        progressBonus = number,  -- How much progress this skill adds
        color = {r, g, b, a},   -- Color for UI button
        category = "Primary|Secondary|Special", -- Skill grouping
        cooldown = number,      -- Future: skill cooldown in seconds
        manaCost = number,      -- Future: mana/stamina cost
        unlockLevel = number,   -- Future: when skill becomes available
        critChance = number,    -- Future: chance for bonus progress
        critMultiplier = number, -- Future: bonus multiplier on crit
        soundEffect = "string", -- Future: sound file to play
        visualEffect = "string" -- Future: particle effect to show
    }
--]]

local skills = {
    -- ===== PRIMARY SKILLS (Main crafting actions) =====
    {
        id = 1,
        key = "1",
        name = "Forge",
        description = "+25 to progress",
        progressBonus = 25,
        color = {0.8, 0.2, 0.2, 1}, -- Red
        category = "Primary",
        cooldown = 0,
        manaCost = 5,
        unlockLevel = 1,
        critChance = 0.15, -- 15% chance
        critMultiplier = 1.5,
        soundEffect = "hammer_strike.ogg",
        visualEffect = "sparks"
    },
    
    {
        id = 2,
        key = "2",
        name = "Temper",
        description = "+15 to progress",
        progressBonus = 15,
        color = {0.2, 0.8, 0.2, 1}, -- Green
        category = "Primary", 
        cooldown = 0,
        manaCost = 3,
        unlockLevel = 1,
        critChance = 0.20, -- 20% chance
        critMultiplier = 1.8,
        soundEffect = "quench.ogg",
        visualEffect = "steam"
    },
    
    {
        id = 3,
        key = "3", 
        name = "Polish",
        description = "+10 to progress",
        progressBonus = 10,
        color = {0.2, 0.2, 0.8, 1}, -- Blue
        category = "Secondary",
        cooldown = 0,
        manaCost = 2,
        unlockLevel = 2,
        critChance = 0.25, -- 25% chance
        critMultiplier = 2.0,
        soundEffect = "polish.ogg", 
        visualEffect = "shine"
    },
    
    -- ===== SECONDARY SKILLS (Support actions) =====
    {
        id = 4,
        key = "4",
        name = "Sharpen",
        description = "+20 to progress",
        progressBonus = 20,
        color = {0.8, 0.8, 0.2, 1}, -- Yellow
        category = "Secondary",
        cooldown = 1.0, -- 1 second cooldown
        manaCost = 4,
        unlockLevel = 3,
        critChance = 0.10, -- 10% chance
        critMultiplier = 2.5,
        soundEffect = "sharpen.ogg",
        visualEffect = "blade_glow"
    },
    
    -- ===== SPECIAL SKILLS (Advanced/magical actions) =====
    {
        id = 5,
        key = "5",
        name = "Enchant",
        description = "+30 to progress",
        progressBonus = 30,
        color = {0.8, 0.2, 0.8, 1}, -- Magenta
        category = "Special",
        cooldown = 2.0, -- 2 second cooldown
        manaCost = 10,
        unlockLevel = 5,
        critChance = 0.30, -- 30% chance
        critMultiplier = 1.2,
        soundEffect = "magic_chime.ogg",
        visualEffect = "magic_sparkles"
    },
    
    -- ===== FUTURE EXPANSION SKILLS =====
    {
        id = 6,
        key = "6",
        name = "Infuse",
        description = "+40 to progress (High mana cost)",
        progressBonus = 40,
        color = {0.9, 0.4, 0.1, 1}, -- Orange
        category = "Special",
        cooldown = 3.0,
        manaCost = 15,
        unlockLevel = 7,
        critChance = 0.05, -- 5% chance
        critMultiplier = 3.0,
        soundEffect = "infusion.ogg",
        visualEffect = "energy_swirl"
    },
    
    {
        id = 7,
        key = "7", 
        name = "Perfect",
        description = "+50 to progress (Very long cooldown)",
        progressBonus = 50,
        color = {1.0, 0.9, 0.0, 1}, -- Gold
        category = "Special",
        cooldown = 10.0, -- 10 second cooldown
        manaCost = 20,
        unlockLevel = 10,
        critChance = 0.50, -- 50% chance
        critMultiplier = 1.5,
        soundEffect = "perfection.ogg",
        visualEffect = "golden_aura"
    }
}

-- Helper functions for skill management
local SkillData = {}

function SkillData.getAll()
    return skills
end

function SkillData.getActive(maxSkills)
    -- Return only the first N skills (for current UI that shows 5 buttons)
    maxSkills = maxSkills or 5
    local active = {}
    for i = 1, math.min(maxSkills, #skills) do
        table.insert(active, skills[i])
    end
    return active
end

function SkillData.getById(id)
    for _, skill in ipairs(skills) do
        if skill.id == id then
            return skill
        end
    end
    return nil
end

function SkillData.getByKey(key)
    for _, skill in ipairs(skills) do
        if skill.key == key then
            return skill
        end
    end
    return nil
end

function SkillData.getByCategory(category)
    local filtered = {}
    for _, skill in ipairs(skills) do
        if skill.category == category then
            table.insert(filtered, skill)
        end
    end
    return filtered
end

function SkillData.getByUnlockLevel(maxLevel)
    local filtered = {}
    for _, skill in ipairs(skills) do
        if skill.unlockLevel <= maxLevel then
            table.insert(filtered, skill)
        end
    end
    return filtered
end

function SkillData.getCategories()
    local categories = {}
    local seen = {}
    for _, skill in ipairs(skills) do
        if not seen[skill.category] then
            table.insert(categories, skill.category)
            seen[skill.category] = true
        end
    end
    return categories
end

-- Calculate total possible progress from all skills
function SkillData.getTotalProgressPotential(playerLevel)
    playerLevel = playerLevel or 999 -- Default to max level
    local total = 0
    for _, skill in ipairs(skills) do
        if skill.unlockLevel <= playerLevel then
            total = total + skill.progressBonus
        end
    end
    return total
end

-- Get skills organized by their keyboard layout
function SkillData.getKeyboardLayout()
    local layout = {}
    for _, skill in ipairs(skills) do
        layout[skill.key] = skill
    end
    return layout
end

-- Validation function
function SkillData.validate()
    local issues = {}
    local ids = {}
    local keys = {}
    
    for i, skill in ipairs(skills) do
        -- Check for required fields
        if not skill.id then
            table.insert(issues, "Skill " .. i .. " missing id")
        elseif ids[skill.id] then
            table.insert(issues, "Duplicate skill id: " .. skill.id)
        else
            ids[skill.id] = true
        end
        
        if not skill.key then
            table.insert(issues, "Skill " .. (skill.id or i) .. " missing key")
        elseif keys[skill.key] then
            table.insert(issues, "Duplicate skill key: " .. skill.key)
        else
            keys[skill.key] = true
        end
        
        if not skill.name or skill.name == "" then
            table.insert(issues, "Skill " .. (skill.id or i) .. " missing name")
        end
        
        if not skill.progressBonus or skill.progressBonus <= 0 then
            table.insert(issues, "Skill " .. (skill.id or i) .. " invalid progressBonus")
        end
        
        if not skill.color or #skill.color ~= 4 then
            table.insert(issues, "Skill " .. (skill.id or i) .. " invalid color (should be {r,g,b,a})")
        end
    end
    
    return #issues == 0, issues
end

return SkillData
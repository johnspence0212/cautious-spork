--[[
    Sprite Integration Guide
    
    This file demonstrates how to integrate sprite sheets into your cautious-spork game.
    Follow these steps to add your sprite sheet:
--]]

--[[
    STEP 1: Place your sprite sheet file in the project
    
    Create an "assets" or "images" folder in your project root:
    cautious-spork/
    ├── assets/
    │   ├── player_spritesheet.png
    │   ├── merchant_sprites.png
    │   └── ui_sprites.png
    └── src/
        └── ...
    
    OR place directly in project root:
    cautious-spork/
    ├── player.png
    ├── merchant.png
    └── src/
        └── ...
--]]

--[[
    STEP 2: Basic sprite usage example
    
    Here's how to load and use a simple sprite sheet:
--]]

local Sprite = require('src.utils.sprite')

-- Example 1: Simple sprite sheet usage
function example_loadSpriteSheet()
    -- Load a sprite sheet
    -- Parameters: (imagePath, spriteWidth, spriteHeight, options)
    local playerSprites = Sprite:new("assets/player.png", 32, 32)
    
    -- The system automatically calculates how many sprites fit
    playerSprites:printInfo() -- Shows sprite sheet details
    
    return playerSprites
end

-- Example 2: Drawing individual sprites
function example_drawSprites()
    local sprites = Sprite:new("assets/characters.png", 32, 32)
    
    -- In your draw function:
    love.graphics.setColor(1, 1, 1, 1) -- White tint (normal colors)
    
    -- Draw sprite by index (1-based)
    sprites:drawSprite(1, 100, 100) -- First sprite at position 100,100
    sprites:drawSprite(5, 150, 100) -- Fifth sprite at position 150,100
    
    -- Draw sprite by row/column (0-based)
    sprites:drawSpriteByPosition(0, 0, 200, 100) -- First row, first column
    sprites:drawSpriteByPosition(1, 2, 250, 100) -- Second row, third column
end

--[[
    STEP 3: Animation examples
--]]

local AnimatedSprite = require('src.utils.animated_sprite')

function example_animations()
    -- Load sprite sheet
    local characterSheet = Sprite:new("assets/character.png", 32, 48)
    
    -- Create animations
    -- Walking animation from sprites 1-4, duration 0.8 seconds, looping
    characterSheet:createAnimation("walk_down", 1, 4, 0.8, true)
    characterSheet:createAnimation("walk_up", 5, 8, 0.8, true)
    characterSheet:createAnimation("idle", 1, 1, 1.0, true)
    
    -- Create animated sprite instance
    local animatedPlayer = AnimatedSprite:new(characterSheet, 300, 200)
    
    -- Play animation
    animatedPlayer:playAnimation("walk_down")
    
    -- In your update loop:
    -- animatedPlayer:update(dt)
    
    -- In your draw loop:
    -- animatedPlayer:draw()
    
    return animatedPlayer
end

--[[
    STEP 4: Integration with existing entities
    
    Here's how to add sprites to your existing Guild Merchant:
--]]

function example_upgradeGuildMerchant()
    -- In your GuildMerchant:new() function, add:
    
    local GuildMerchant = require('src.entities.guild_merchant')
    local Sprite = require('src.utils.sprite')
    local AnimatedSprite = require('src.utils.animated_sprite')
    
    -- Add to the instance table:
    local instance = {
        -- ... existing properties ...
        spriteSheet = nil,
        animatedSprite = nil,
        useSprites = false
    }
    
    -- Try to load sprite sheet (optional)
    local success, spriteSheet = pcall(function()
        return Sprite:new("assets/merchant.png", 32, 48)
    end)
    
    if success then
        instance.spriteSheet = spriteSheet
        instance.animatedSprite = AnimatedSprite:new(spriteSheet, instance.x, instance.y)
        instance.useSprites = true
        
        -- Set up merchant animations
        spriteSheet:createAnimation("idle", 1, 1, 1.0, true)
        spriteSheet:createAnimation("talking", 1, 3, 0.6, true)
        
        instance.animatedSprite:playAnimation("idle")
        print("GuildMerchant: Loaded sprite sheet successfully")
    else
        print("GuildMerchant: No sprite sheet found, using fallback rendering")
    end
    
    -- In update function, add:
    -- if self.useSprites then
    --     self.animatedSprite:setPosition(self.x + self.width/2, self.y + self.height/2)
    --     self.animatedSprite:update(dt)
    -- end
    
    -- In draw function, replace drawing code with:
    -- if self.useSprites then
    --     love.graphics.setColor(1, 1, 1, 1)
    --     self.animatedSprite:draw()
    -- else
    --     -- ... existing drawing code ...
    -- end
end

--[[
    STEP 5: Common sprite sheet layouts
    
    Different sprite sheet organizations:
--]]

function example_spriteSheetLayouts()
    -- Layout 1: Character with 4 directions, 4 frames each
    -- Row 0: Down (frames 1-4)
    -- Row 1: Up (frames 5-8) 
    -- Row 2: Left (frames 9-12)
    -- Row 3: Right (frames 13-16)
    local character = Sprite:new("assets/character_4dir.png", 32, 32)
    character:createAnimation("walk_down", 1, 4, 0.8, true)
    character:createAnimation("walk_up", 5, 8, 0.8, true)
    character:createAnimation("walk_left", 9, 12, 0.8, true)
    character:createAnimation("walk_right", 13, 16, 0.8, true)
    
    -- Layout 2: Items in a grid
    local items = Sprite:new("assets/items.png", 32, 32)
    -- Use individual sprites: items:drawSprite(1, x, y) for sword, etc.
    
    -- Layout 3: UI elements
    local ui = Sprite:new("assets/ui.png", 64, 32)
    -- buttons, panels, icons, etc.
    
    -- Layout 4: Sprite sheet with margins and spacing
    local spritesWithGaps = Sprite:new("assets/sprites.png", 32, 32, {
        margin = 1,     -- 1 pixel margin around the sheet
        spacing = 2,    -- 2 pixels between each sprite
        offsetX = 0,    -- No X offset
        offsetY = 0     -- No Y offset
    })
end

--[[
    STEP 6: Performance tips
--]]

function example_performanceTips()
    -- 1. Load sprite sheets once, reuse them
    local sharedSprites = Sprite:new("assets/shared.png", 32, 32)
    
    -- 2. Use sprite batching for many similar sprites
    local spriteBatch = love.graphics.newSpriteBatch(sharedSprites.image, 100)
    
    -- 3. Preload all sprite sheets at game start
    local SpriteManager = {
        player = Sprite:new("assets/player.png", 32, 32),
        enemies = Sprite:new("assets/enemies.png", 32, 32),
        items = Sprite:new("assets/items.png", 16, 16),
        ui = Sprite:new("assets/ui.png", 64, 32)
    }
    
    return SpriteManager
end

--[[
    STEP 7: Quick integration for your game
    
    To quickly add your sprite sheet:
--]]

function quickIntegration()
    print("=== Quick Sprite Integration Guide ===")
    print("1. Place your sprite sheet file in: cautious-spork/assets/yoursprite.png")
    print("2. Tell me:")
    print("   - What the sprite sheet is for (player, merchant, items, etc.)")
    print("   - Individual sprite dimensions (e.g., 32x32, 16x16)")
    print("   - How sprites are arranged (rows/columns)")
    print("   - If there are animations, how many frames per animation")
    print("3. I'll help you integrate it into the specific entity!")
    print("=====================================")
end

return {
    loadSpriteSheet = example_loadSpriteSheet,
    drawSprites = example_drawSprites,
    animations = example_animations,
    upgradeGuildMerchant = example_upgradeGuildMerchant,
    spriteSheetLayouts = example_spriteSheetLayouts,
    performanceTips = example_performanceTips,
    quickStart = quickIntegration
}
--[[
    Example: Using sprites with the player character
    
    This shows how to integrate sprite sheets into your existing game entities.
--]]

local Sprite = require('src.utils.sprite')
local AnimatedSprite = require('src.utils.animated_sprite')

local SpritePlayer = {}
SpritePlayer.__index = SpritePlayer

function SpritePlayer:new(x, y, spriteSheetPath)
    local instance = {
        x = x or 400,
        y = y or 300,
        width = 32,
        height = 32,
        speed = 200,
        
        -- Movement state
        direction = "down", -- down, up, left, right
        isMoving = false,
        
        -- Sprite components
        spriteSheet = nil,
        animatedSprite = nil
    }
    
    setmetatable(instance, self)
    
    -- Load sprite sheet if provided
    if spriteSheetPath then
        instance:loadSpriteSheet(spriteSheetPath)
    end
    
    return instance
end

-- Load and set up sprite sheet
function SpritePlayer:loadSpriteSheet(imagePath, spriteWidth, spriteHeight, options)
    spriteWidth = spriteWidth or 32
    spriteHeight = spriteHeight or 32
    
    -- Create sprite sheet
    self.spriteSheet = Sprite:new(imagePath, spriteWidth, spriteHeight, options)
    
    -- Create animated sprite
    self.animatedSprite = AnimatedSprite:new(self.spriteSheet, self.x, self.y, {
        originX = spriteWidth / 2,
        originY = spriteHeight / 2
    })
    
    -- Set up typical character animations
    -- Adjust these based on your sprite sheet layout
    self:setupAnimations()
    
    -- Start with idle animation
    self.animatedSprite:playAnimation("idle_down")
    
    print("SpritePlayer: Loaded sprite sheet with " .. self.spriteSheet.totalSprites .. " sprites")
end

-- Set up animations based on common character sprite layouts
function SpritePlayer:setupAnimations()
    if not self.spriteSheet then return end
    
    -- Example for a typical 4-direction character sprite sheet
    -- Adjust frame indices based on your sprite sheet layout
    
    -- Row 0: Down facing sprites
    self.spriteSheet:createAnimation("idle_down", 1, 1, 1.0, true)
    self.spriteSheet:createAnimation("walk_down", 1, 4, 0.6, true)
    
    -- Row 1: Up facing sprites
    self.spriteSheet:createAnimation("idle_up", 13, 13, 1.0, true)
    self.spriteSheet:createAnimation("walk_up", 13, 16, 0.6, true)
    
    -- Row 2: Left facing sprites
    self.spriteSheet:createAnimation("idle_left", 25, 25, 1.0, true)
    self.spriteSheet:createAnimation("walk_left", 25, 28, 0.6, true)
    
    -- Row 3: Right facing sprites
    self.spriteSheet:createAnimation("idle_right", 37, 37, 1.0, true)
    self.spriteSheet:createAnimation("walk_right", 37, 40, 0.6, true)
    
    print("SpritePlayer: Set up character animations")
end

-- Update player movement and animation
function SpritePlayer:update(dt)
    local wasMoving = self.isMoving
    self.isMoving = false
    
    local newDirection = self.direction
    
    -- Handle input
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        self.y = self.y - self.speed * dt
        self.isMoving = true
        newDirection = "up"
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        self.y = self.y + self.speed * dt
        self.isMoving = true
        newDirection = "down"
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        self.x = self.x - self.speed * dt
        self.isMoving = true
        newDirection = "left"
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        self.x = self.x + self.speed * dt
        self.isMoving = true
        newDirection = "right"
    end
    
    -- Keep player within screen bounds
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    self.x = math.max(0, math.min(width - self.width, self.x))
    self.y = math.max(0, math.min(height - self.height, self.y))
    
    -- Update sprite position
    if self.animatedSprite then
        self.animatedSprite:setPosition(self.x + self.width/2, self.y + self.height/2)
        self.animatedSprite:update(dt)
        
        -- Update animation based on movement state
        self:updateAnimation(newDirection, wasMoving)
    end
    
    self.direction = newDirection
end

-- Update animation based on movement and direction
function SpritePlayer:updateAnimation(newDirection, wasMoving)
    if not self.animatedSprite then return end
    
    local animationChanged = false
    
    -- Determine which animation to play
    local animationName
    if self.isMoving then
        animationName = "walk_" .. newDirection
    else
        animationName = "idle_" .. newDirection
    end
    
    -- Only change animation if it's different from current
    if self.animatedSprite:getCurrentAnimation() ~= animationName then
        self.animatedSprite:playAnimation(animationName)
    end
end

-- Draw the player
function SpritePlayer:draw()
    if self.animatedSprite then
        -- Draw with sprite
        love.graphics.setColor(1, 1, 1, 1)
        self.animatedSprite:draw()
    else
        -- Fallback to rectangle if no sprite
        love.graphics.setColor(0.2, 0.8, 0.2, 1)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    end
end

-- Get player center position for interaction checks
function SpritePlayer:getCenterPosition()
    return self.x + self.width/2, self.y + self.height/2
end

return SpritePlayer
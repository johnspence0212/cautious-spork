--[[
    AnimatedSprite - Handle animated sprite rendering and state
    
    This component manages:
    - Animation playback
    - Frame timing
    - Animation switching
    - Sprite positioning and rendering
--]]

local AnimatedSprite = {}
AnimatedSprite.__index = AnimatedSprite

-- Create a new animated sprite instance
function AnimatedSprite:new(spriteSheet, x, y, options)
    options = options or {}
    
    local instance = {
        spriteSheet = spriteSheet,
        x = x or 0,
        y = y or 0,
        
        -- Animation state
        currentAnimation = nil,
        currentFrame = 1,
        animationTime = 0,
        isPlaying = false,
        
        -- Rendering options
        rotation = options.rotation or 0,
        scaleX = options.scaleX or 1,
        scaleY = options.scaleY or options.scaleX or 1,
        originX = options.originX,
        originY = options.originY,
        
        -- Callbacks
        onAnimationComplete = options.onAnimationComplete,
        onFrameChange = options.onFrameChange
    }
    
    setmetatable(instance, self)
    return instance
end

-- Set position
function AnimatedSprite:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Get position
function AnimatedSprite:getPosition()
    return self.x, self.y
end

-- Set scale
function AnimatedSprite:setScale(scaleX, scaleY)
    self.scaleX = scaleX
    self.scaleY = scaleY or scaleX
end

-- Set rotation
function AnimatedSprite:setRotation(rotation)
    self.rotation = rotation
end

-- Play an animation
function AnimatedSprite:playAnimation(animationName, restart)
    restart = restart ~= false -- Default to true
    
    local animation = self.spriteSheet.animations[animationName]
    if not animation then
        print("AnimatedSprite: Warning - animation '" .. animationName .. "' not found")
        return false
    end
    
    if self.currentAnimation ~= animationName or restart then
        self.currentAnimation = animationName
        self.currentFrame = 1
        self.animationTime = 0
        self.isPlaying = true
        
        if self.onFrameChange then
            self.onFrameChange(self.currentFrame, animation.frames[self.currentFrame])
        end
    end
    
    return true
end

-- Stop current animation
function AnimatedSprite:stopAnimation()
    self.isPlaying = false
end

-- Pause current animation
function AnimatedSprite:pauseAnimation()
    self.isPlaying = false
end

-- Resume current animation
function AnimatedSprite:resumeAnimation()
    self.isPlaying = true
end

-- Check if animation is playing
function AnimatedSprite:isAnimationPlaying()
    return self.isPlaying
end

-- Get current animation info
function AnimatedSprite:getCurrentAnimation()
    return self.currentAnimation
end

-- Get current frame index
function AnimatedSprite:getCurrentFrame()
    return self.currentFrame
end

-- Update animation (call this in your update loop)
function AnimatedSprite:update(dt)
    if not self.isPlaying or not self.currentAnimation then
        return
    end
    
    local animation = self.spriteSheet.animations[self.currentAnimation]
    if not animation then
        return
    end
    
    self.animationTime = self.animationTime + dt
    
    -- Check if we need to advance to next frame
    if self.animationTime >= animation.frameTime then
        local oldFrame = self.currentFrame
        self.currentFrame = self.currentFrame + 1
        self.animationTime = self.animationTime - animation.frameTime
        
        -- Handle end of animation
        if self.currentFrame > #animation.frames then
            if animation.loop then
                self.currentFrame = 1
            else
                self.currentFrame = #animation.frames
                self.isPlaying = false
                
                if self.onAnimationComplete then
                    self.onAnimationComplete(self.currentAnimation)
                end
            end
        end
        
        -- Call frame change callback
        if oldFrame ~= self.currentFrame and self.onFrameChange then
            self.onFrameChange(self.currentFrame, animation.frames[self.currentFrame])
        end
    end
end

-- Draw the current frame
function AnimatedSprite:draw()
    if not self.currentAnimation then
        -- Draw first sprite if no animation is set
        self.spriteSheet:drawSprite(1, self.x, self.y, self.rotation, self.scaleX, self.scaleY, self.originX, self.originY)
        return
    end
    
    local animation = self.spriteSheet.animations[self.currentAnimation]
    if not animation or not animation.frames[self.currentFrame] then
        return
    end
    
    local spriteIndex = animation.frames[self.currentFrame]
    self.spriteSheet:drawSprite(spriteIndex, self.x, self.y, self.rotation, self.scaleX, self.scaleY, self.originX, self.originY)
end

-- Draw a specific sprite index (ignoring animation)
function AnimatedSprite:drawSprite(spriteIndex)
    self.spriteSheet:drawSprite(spriteIndex, self.x, self.y, self.rotation, self.scaleX, self.scaleY, self.originX, self.originY)
end

-- Set animation callbacks
function AnimatedSprite:setOnAnimationComplete(callback)
    self.onAnimationComplete = callback
end

function AnimatedSprite:setOnFrameChange(callback)
    self.onFrameChange = callback
end

-- Get sprite dimensions
function AnimatedSprite:getDimensions()
    return self.spriteSheet.spriteWidth, self.spriteSheet.spriteHeight
end

-- Get scaled dimensions
function AnimatedSprite:getScaledDimensions()
    return self.spriteSheet.spriteWidth * self.scaleX, self.spriteSheet.spriteHeight * self.scaleY
end

return AnimatedSprite
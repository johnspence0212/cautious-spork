--[[
    Sprite System - Handle sprite sheets and animated sprites
    
    This utility provides:
    - Sprite sheet loading and management
    - Individual sprite extraction (quads)
    - Animation support
    - Easy integration with Love2D drawing
--]]

local Sprite = {}
Sprite.__index = Sprite

-- Create a new sprite sheet
function Sprite:new(imagePath, spriteWidth, spriteHeight, options)
    options = options or {}
    
    local instance = {
        image = love.graphics.newImage(imagePath),
        spriteWidth = spriteWidth,
        spriteHeight = spriteHeight,
        quads = {},
        animations = {},
        
        -- Options
        margin = options.margin or 0,      -- Space around each sprite
        spacing = options.spacing or 0,    -- Space between sprites
        offsetX = options.offsetX or 0,    -- Starting X offset
        offsetY = options.offsetY or 0,    -- Starting Y offset
    }
    
    setmetatable(instance, self)
    
    -- Calculate how many sprites fit in the sheet
    local imageWidth = instance.image:getWidth()
    local imageHeight = instance.image:getHeight()
    
    instance.spritesPerRow = math.floor((imageWidth - instance.offsetX - instance.margin) / (spriteWidth + instance.spacing))
    instance.spritesPerCol = math.floor((imageHeight - instance.offsetY - instance.margin) / (spriteHeight + instance.spacing))
    instance.totalSprites = instance.spritesPerRow * instance.spritesPerCol
    
    -- Create quads for each sprite
    instance:generateQuads()
    
    print("Sprite: Loaded " .. imagePath .. " - " .. instance.totalSprites .. " sprites (" .. 
          instance.spritesPerRow .. "x" .. instance.spritesPerCol .. ")")
    
    return instance
end

-- Generate Love2D quads for each sprite in the sheet
function Sprite:generateQuads()
    self.quads = {}
    
    for row = 0, self.spritesPerCol - 1 do
        for col = 0, self.spritesPerRow - 1 do
            local x = self.offsetX + self.margin + col * (self.spriteWidth + self.spacing)
            local y = self.offsetY + self.margin + row * (self.spriteHeight + self.spacing)
            
            local quad = love.graphics.newQuad(
                x, y, 
                self.spriteWidth, self.spriteHeight, 
                self.image:getWidth(), self.image:getHeight()
            )
            
            local index = row * self.spritesPerRow + col + 1 -- 1-based indexing
            self.quads[index] = quad
        end
    end
end

-- Get a specific sprite quad by index (1-based)
function Sprite:getQuad(index)
    return self.quads[index]
end

-- Get sprite quad by row and column (0-based)
function Sprite:getQuadByPosition(row, col)
    local index = row * self.spritesPerRow + col + 1
    return self.quads[index]
end

-- Draw a specific sprite
function Sprite:drawSprite(index, x, y, rotation, scaleX, scaleY, originX, originY)
    local quad = self.quads[index]
    if not quad then
        print("Sprite: Warning - sprite index " .. index .. " not found")
        return
    end
    
    rotation = rotation or 0
    scaleX = scaleX or 1
    scaleY = scaleY or scaleX
    originX = originX or self.spriteWidth / 2
    originY = originY or self.spriteHeight / 2
    
    love.graphics.draw(self.image, quad, x, y, rotation, scaleX, scaleY, originX, originY)
end

-- Draw sprite by row/col position
function Sprite:drawSpriteByPosition(row, col, x, y, rotation, scaleX, scaleY, originX, originY)
    local index = row * self.spritesPerRow + col + 1
    self:drawSprite(index, x, y, rotation, scaleX, scaleY, originX, originY)
end

-- Create an animation from a range of sprites
function Sprite:createAnimation(name, startIndex, endIndex, duration, loop)
    loop = loop ~= false -- Default to true
    
    local frames = {}
    for i = startIndex, endIndex do
        if self.quads[i] then
            table.insert(frames, i)
        end
    end
    
    self.animations[name] = {
        frames = frames,
        duration = duration,
        loop = loop,
        frameTime = duration / #frames
    }
    
    print("Sprite: Created animation '" .. name .. "' with " .. #frames .. " frames")
end

-- Create animation from specific frame indices
function Sprite:createAnimationFromFrames(name, frameIndices, duration, loop)
    loop = loop ~= false -- Default to true
    
    local frames = {}
    for _, index in ipairs(frameIndices) do
        if self.quads[index] then
            table.insert(frames, index)
        end
    end
    
    self.animations[name] = {
        frames = frames,
        duration = duration,
        loop = loop,
        frameTime = duration / #frames
    }
    
    print("Sprite: Created custom animation '" .. name .. "' with " .. #frames .. " frames")
end

-- Get sprite sheet info
function Sprite:getInfo()
    return {
        totalSprites = self.totalSprites,
        spritesPerRow = self.spritesPerRow,
        spritesPerCol = self.spritesPerCol,
        spriteWidth = self.spriteWidth,
        spriteHeight = self.spriteHeight,
        imageWidth = self.image:getWidth(),
        imageHeight = self.image:getHeight()
    }
end

-- Print sprite sheet information
function Sprite:printInfo()
    local info = self:getInfo()
    print("=== Sprite Sheet Info ===")
    print("Total Sprites: " .. info.totalSprites)
    print("Grid: " .. info.spritesPerRow .. " x " .. info.spritesPerCol)
    print("Sprite Size: " .. info.spriteWidth .. " x " .. info.spriteHeight)
    print("Image Size: " .. info.imageWidth .. " x " .. info.imageHeight)
    print("=========================")
end

return Sprite
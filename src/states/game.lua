local Anvil = require('src.entities.anvil')

local GameState = {}

function GameState:enter()
    self.font = love.graphics.newFont(16)
    self.gameTime = 0
    self.instructions = "Game State - Press M to return to menu, ESC to quit"
    
    -- Simple player rectangle for demonstration
    self.player = {
        x = 400,
        y = 300,
        width = 32,
        height = 32,
        speed = 200,
        color = {0.2, 0.8, 0.2, 1} -- Green
    }
    
    -- Create the anvil (cornerstone object)
    self.anvil = Anvil:new(200, 150)
    
    -- Interaction state
    self.nearInteractable = false
    self.interactionPrompt = ""
end

function GameState:update(dt)
    self.gameTime = self.gameTime + dt
    
    -- Simple player movement
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        self.player.y = self.player.y - self.player.speed * dt
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        self.player.y = self.player.y + self.player.speed * dt
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        self.player.x = self.player.x - self.player.speed * dt
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        self.player.x = self.player.x + self.player.speed * dt
    end
    
    -- Keep player within screen bounds
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    self.player.x = math.max(0, math.min(width - self.player.width, self.player.x))
    self.player.y = math.max(0, math.min(height - self.player.height, self.player.y))
    
    -- Update anvil (check for player proximity)
    self.anvil:update(dt, self.player.x + self.player.width/2, self.player.y + self.player.height/2)
    
    -- Check interaction state
    if self.anvil:canInteract(self.player.x + self.player.width/2, self.player.y + self.player.height/2) then
        self.nearInteractable = true
        self.interactionPrompt = self.anvil:getInteractionPrompt()
    else
        self.nearInteractable = false
        self.interactionPrompt = ""
    end
end

function GameState:draw()
    -- Set background color
    love.graphics.clear(0.1, 0.2, 0.1, 1)
    
    -- Draw anvil first (so it appears behind player)
    self.anvil:draw()
    
    -- Draw player
    love.graphics.setColor(self.player.color)
    love.graphics.rectangle("fill", self.player.x, self.player.y, self.player.width, self.player.height)
    
    -- Draw UI
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.font)
    
    -- Instructions
    love.graphics.print(self.instructions, 10, 10)
    
    -- Game time
    love.graphics.print("Time: " .. string.format("%.1f", self.gameTime), 10, 30)
    
    -- Player position
    love.graphics.print("Player: (" .. math.floor(self.player.x) .. ", " .. math.floor(self.player.y) .. ")", 10, 50)
    
    -- Movement instructions
    love.graphics.print("Use WASD or Arrow Keys to move", 10, love.graphics.getHeight() - 50)
    
    -- Interaction prompt
    if self.nearInteractable then
        love.graphics.setColor(1, 1, 0, 1) -- Yellow for interaction prompt
        love.graphics.print(self.interactionPrompt, 10, love.graphics.getHeight() - 30)
        love.graphics.setColor(1, 1, 1, 1) -- Reset color
    end
end

function GameState:keypressed(key, scancode, isrepeat)
    if key == "m" then
        StateManager:switch('menu')
    elseif key == "e" and self.nearInteractable then
        -- Interact with anvil - switch to crafting select state
        StateManager:switch('crafting_select')
    end
end

function GameState:exit()
    -- Clean up any resources if needed
end

return GameState
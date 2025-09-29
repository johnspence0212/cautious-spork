-- Import our state files
local MenuState = require('src.states.menu')
local GameState = require('src.states.game')
local CraftingSelectState = require('src.states.crafting_select')
local CraftingState = require('src.states.crafting')
local InventoryState = require('src.states.inventory')

-- Import player state system
local PlayerState = require('src.systems.player')

-- Game state manager
local StateManager = {
    current = nil,
    states = {}
}

function StateManager:register(name, state)
    self.states[name] = state
end

function StateManager:switch(name, ...)
    if self.current and self.current.exit then
        self.current:exit()
    end
    
    self.current = self.states[name]
    
    if self.current and self.current.enter then
        self.current:enter(...)
    end
end

function StateManager:update(dt)
    if self.current and self.current.update then
        self.current:update(dt)
    end
end

function StateManager:draw()
    if self.current and self.current.draw then
        self.current:draw()
    end
end

function StateManager:keypressed(key, scancode, isrepeat)
    if self.current and self.current.keypressed then
        self.current:keypressed(key, scancode, isrepeat)
    end
end

function StateManager:keyreleased(key, scancode)
    if self.current and self.current.keyreleased then
        self.current:keyreleased(key, scancode)
    end
end

function StateManager:mousepressed(x, y, button, istouch, presses)
    if self.current and self.current.mousepressed then
        self.current:mousepressed(x, y, button, istouch, presses)
    end
end

function StateManager:mousereleased(x, y, button, istouch, presses)
    if self.current and self.current.mousereleased then
        self.current:mousereleased(x, y, button, istouch, presses)
    end
end

function StateManager:mousemoved(x, y, dx, dy, istouch)
    if self.current and self.current.mousemoved then
        self.current:mousemoved(x, y, dx, dy, istouch)
    end
end

function StateManager:handleEscape()
    -- Let current state handle escape first
    if self.current and self.current.keypressed then
        self.current:keypressed("escape", "escape", false)
        return true -- State handled it
    end
    return false -- State didn't handle it, allow global quit
end

-- Global state manager accessible to all states
_G.StateManager = StateManager

function love.load()
    -- Set up graphics
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- Initialize global player state
    _G.PlayerState = PlayerState:new()
    
    -- Register our states
    StateManager:register('menu', MenuState)
    StateManager:register('game', GameState)
    StateManager:register('crafting_select', CraftingSelectState)
    StateManager:register('crafting', CraftingState)
    StateManager:register('inventory', InventoryState)
    
    -- Start with the menu state
    StateManager:switch('menu')
end

function love.update(dt)
    StateManager:update(dt)
end

function love.draw()
    StateManager:draw()
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        -- Let current state handle escape first
        if StateManager.current and StateManager.current.handleEscape then
            -- State has custom escape handling
            StateManager.current:handleEscape()
        elseif StateManager.current and StateManager.current.keypressed then
            -- State has normal keypressed handling
            StateManager.current:keypressed(key, scancode, isrepeat)
        else
            -- No state or state doesn't handle input - quit game
            love.event.quit()
        end
    else
        -- Forward all other keys to state
        StateManager:keypressed(key, scancode, isrepeat)
    end
end

function love.keyreleased(key, scancode)
    StateManager:keyreleased(key, scancode)
end

function love.mousepressed(x, y, button, istouch, presses)
    StateManager:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    StateManager:mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
    StateManager:mousemoved(x, y, dx, dy, istouch)
end
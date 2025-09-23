local MenuState = {}

function MenuState:enter()
    self.title = "Love2D Game"
    self.subtitle = "Press SPACE to start or ESC to quit"
    self.font = love.graphics.newFont(24)
    self.subtitleFont = love.graphics.newFont(16)
end

function MenuState:update(dt)
    -- Menu doesn't need to update anything continuously
end

function MenuState:draw()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    -- Set background color
    love.graphics.clear(0.1, 0.1, 0.2, 1)
    
    -- Draw title
    love.graphics.setFont(self.font)
    love.graphics.setColor(1, 1, 1, 1)
    local titleWidth = self.font:getWidth(self.title)
    love.graphics.print(self.title, (width - titleWidth) / 2, height / 2 - 50)
    
    -- Draw subtitle
    love.graphics.setFont(self.subtitleFont)
    local subtitleWidth = self.subtitleFont:getWidth(self.subtitle)
    love.graphics.print(self.subtitle, (width - subtitleWidth) / 2, height / 2 + 10)
end

function MenuState:keypressed(key, scancode, isrepeat)
    if key == "space" then
        StateManager:switch('game')
    end
end

function MenuState:exit()
    -- Clean up any resources if needed
end

return MenuState
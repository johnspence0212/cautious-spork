local ItemCard = require('src.ui.item_card')

local InventoryState = {}

function InventoryState:enter(previousState)
    self.previousState = previousState or 'game'
    self.font = love.graphics.newFont(18)
    self.titleFont = love.graphics.newFont(24)
    self.tabFont = love.graphics.newFont(16)
    
    -- Exit button properties
    self.exitButtonSize = 30
    self.exitButtonPadding = 10
    
    -- Tab system
    self.activeTab = 'bag' -- 'bag' or 'recipes'
    self.tabs = {
        {id = 'bag', name = 'Bag of Holding'},
        {id = 'recipes', name = 'Recipe Codex'}
    }
    self.tabHeight = 40
    self.tabPadding = 10
    
    -- Scrolling and selection
    self.scrollOffset = 0
    self.selectedItemIndex = nil
    self.hoveredItemIndex = nil
end

function InventoryState:update(dt)
    -- Nothing to update for simple inventory
end

function InventoryState:draw()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    -- Dark semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, width, height)
    
    -- Main inventory panel (larger for tabs)
    local panelWidth = 500
    local panelHeight = 400
    local panelX = (width - panelWidth) / 2
    local panelY = (height - panelHeight) / 2
    
    -- Draw tabs
    self:drawTabs(panelX, panelY, panelWidth)
    
    -- Panel background (below tabs)
    love.graphics.setColor(0.2, 0.2, 0.3, 1)
    love.graphics.rectangle("fill", panelX, panelY + self.tabHeight, panelWidth, panelHeight - self.tabHeight)
    love.graphics.setColor(0.6, 0.6, 0.7, 1)
    love.graphics.rectangle("line", panelX, panelY + self.tabHeight, panelWidth, panelHeight - self.tabHeight)
    
    -- Draw tab content
    self:drawTabContent(panelX, panelY + self.tabHeight, panelWidth, panelHeight - self.tabHeight)
    
    -- Draw exit button (X button in top right)
    self:drawExitButton()
    
    -- Draw gold display in bottom right corner of screen
    if _G.PlayerState then
        love.graphics.setColor(1, 0.8, 0.2, 1) -- Golden color for gold
        love.graphics.setFont(love.graphics.newFont(18))
        local goldText = "Gold: " .. _G.PlayerState:getGold()
        local goldWidth = love.graphics.getFont():getWidth(goldText)
        love.graphics.print(goldText, width - goldWidth - 15, height - 30)
    end
end

function InventoryState:drawExitButton()
    local width = love.graphics.getWidth()
    local buttonSize = self.exitButtonSize
    local padding = self.exitButtonPadding
    
    -- Button position (top right corner)
    local buttonX = width - buttonSize - padding
    local buttonY = padding
    
    -- Check if mouse is over button
    local mouseX, mouseY = love.mouse.getPosition()
    local isHovered = mouseX >= buttonX and mouseX <= buttonX + buttonSize and
                     mouseY >= buttonY and mouseY <= buttonY + buttonSize
    
    -- Button background
    if isHovered then
        love.graphics.setColor(0.6, 0.2, 0.2, 0.8)
    else
        love.graphics.setColor(0.4, 0.4, 0.4, 0.8)
    end
    love.graphics.rectangle("fill", buttonX, buttonY, buttonSize, buttonSize)
    
    -- Button border
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.rectangle("line", buttonX, buttonY, buttonSize, buttonSize)
    
    -- X symbol
    love.graphics.setColor(1, 1, 1, 1)
    local xText = "×"
    local font = love.graphics.newFont(16)
    love.graphics.setFont(font)
    local textWidth = font:getWidth(xText)
    local textHeight = font:getHeight()
    love.graphics.print(xText, 
                       buttonX + (buttonSize - textWidth) / 2, 
                       buttonY + (buttonSize - textHeight) / 2)
end

function InventoryState:keypressed(key, scancode, isrepeat)
    if key == "i" then
        -- Close inventory and return to previous state
        StateManager:switch(self.previousState)
    end
end

function InventoryState:mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        -- Check if exit button was clicked
        local width = love.graphics.getWidth()
        local buttonSize = self.exitButtonSize
        local padding = self.exitButtonPadding
        local buttonX = width - buttonSize - padding
        local buttonY = padding
        
        if x >= buttonX and x <= buttonX + buttonSize and
           y >= buttonY and y <= buttonY + buttonSize then
            -- Exit button clicked - return to previous state
            StateManager:switch(self.previousState)
            return
        end
        
        -- Check if a tab was clicked
        local panelWidth = 500
        local panelX = (width - panelWidth) / 2
        local panelY = (love.graphics.getHeight() - 400) / 2
        self:handleTabClick(x, y, panelX, panelY, panelWidth)
        
        -- Check if an item card was clicked (for bag tab)
        if self.activeTab == 'bag' and _G.PlayerState and _G.PlayerState:hasItems() then
            local items = _G.PlayerState:getInventoryItems()
            local contentX = panelX
            local contentY = panelY + self.tabHeight
            local contentWidth = panelWidth
            
            local clickedIndex = ItemCard:getClickedCardIndex(x, y, items, contentX, contentY, contentWidth, self.scrollOffset)
            if clickedIndex then
                self.selectedItemIndex = clickedIndex
                print("Selected item: " .. items[clickedIndex].name)
            end
        end
    end
end

function InventoryState:drawTabs(panelX, panelY, panelWidth)
    local tabWidth = panelWidth / #self.tabs
    
    for i, tab in ipairs(self.tabs) do
        local tabX = panelX + (i - 1) * tabWidth
        local isActive = tab.id == self.activeTab
        
        -- Tab background
        if isActive then
            love.graphics.setColor(0.3, 0.3, 0.4, 1) -- Active tab color
        else
            love.graphics.setColor(0.15, 0.15, 0.2, 1) -- Inactive tab color
        end
        love.graphics.rectangle("fill", tabX, panelY, tabWidth, self.tabHeight)
        
        -- Tab border
        love.graphics.setColor(0.6, 0.6, 0.7, 1)
        love.graphics.rectangle("line", tabX, panelY, tabWidth, self.tabHeight)
        
        -- Tab text
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(self.tabFont)
        local textWidth = self.tabFont:getWidth(tab.name)
        local textHeight = self.tabFont:getHeight()
        love.graphics.print(tab.name, 
                           tabX + (tabWidth - textWidth) / 2, 
                           panelY + (self.tabHeight - textHeight) / 2)
    end
end

function InventoryState:drawTabContent(contentX, contentY, contentWidth, contentHeight)
    if self.activeTab == 'bag' then
        -- Get items from player state
        if _G.PlayerState and _G.PlayerState:hasItems() then
            local items = _G.PlayerState:getInventoryItems()
            
            -- Title
            love.graphics.setColor(0.9, 0.9, 0.9, 1)
            love.graphics.setFont(self.titleFont)
            local titleText = "Bag of Holding (" .. #items .. " items)"
            local titleWidth = self.titleFont:getWidth(titleText)
            love.graphics.print(titleText, contentX + (contentWidth - titleWidth) / 2, contentY + 10)
            
            -- Draw scrollable item cards
            ItemCard:drawScrollableGrid(items, contentX, contentY, contentWidth, contentHeight, self.scrollOffset, {
                selectedIndex = self.selectedItemIndex,
                hoveredIndex = self.hoveredItemIndex,
                showIcons = false
            })
            
            -- Draw scrollbar if needed
            self:drawScrollbar(contentX, contentY, contentWidth, contentHeight, #items)
            
        else
            -- Empty bag message
            love.graphics.setColor(0.7, 0.7, 0.7, 1)
            love.graphics.setFont(self.titleFont)
            local emptyText = "Your Bag is Empty"
            local emptyWidth = self.titleFont:getWidth(emptyText)
            love.graphics.print(emptyText, contentX + (contentWidth - emptyWidth) / 2, contentY + 80)
            
            love.graphics.setFont(self.font)
            local hintText = "Craft items at the anvil to fill your bag!"
            local hintWidth = self.font:getWidth(hintText)
            love.graphics.print(hintText, contentX + (contentWidth - hintWidth) / 2, contentY + 120)
        end
        
        -- Instructions at bottom left
        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        love.graphics.setFont(love.graphics.newFont(14))
        local instructions = "Press 'I' to close • Click X to exit"
        love.graphics.print(instructions, contentX + 20, contentY + contentHeight - 25)
        
    elseif self.activeTab == 'recipes' then
        -- Recipe Codex content
        love.graphics.setFont(self.font)
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        local recipeContent = {
            "=== Recipe Codex ===",
            "",
            "Known Recipes:",
            "• Iron Sword",
            "• Healing Potion", 
            "• Magic Scroll",
            "",
            "Use the anvil to craft items.",
            "",
            "Press 'I' to close inventory"
        }
        
        for i, line in ipairs(recipeContent) do
            love.graphics.print(line, contentX + 20, contentY + 20 + (i - 1) * 25)
        end
    end
end

function InventoryState:handleTabClick(x, y, panelX, panelY, panelWidth)
    -- Check if click is within tab area
    if y >= panelY and y <= panelY + self.tabHeight then
        local tabWidth = panelWidth / #self.tabs
        
        for i, tab in ipairs(self.tabs) do
            local tabX = panelX + (i - 1) * tabWidth
            
            if x >= tabX and x <= tabX + tabWidth then
                self.activeTab = tab.id
                break
            end
        end
    end
end

function InventoryState:drawScrollbar(contentX, contentY, contentWidth, contentHeight, itemCount)
    if itemCount == 0 then return end
    
    local maxScroll = ItemCard:getMaxScrollOffset(itemCount, contentWidth, contentHeight)
    if maxScroll <= 0 then return end -- No scrolling needed
    
    -- Scrollbar dimensions
    local scrollbarWidth = 8
    local scrollbarX = contentX + contentWidth - scrollbarWidth - 5
    local scrollbarY = contentY + 60
    local scrollbarHeight = contentHeight - 85
    
    -- Scrollbar track
    love.graphics.setColor(0.2, 0.2, 0.2, 0.5)
    love.graphics.rectangle("fill", scrollbarX, scrollbarY, scrollbarWidth, scrollbarHeight)
    
    -- Scrollbar thumb
    local thumbHeight = math.max(20, scrollbarHeight * (scrollbarHeight / (scrollbarHeight + maxScroll)))
    local thumbY = scrollbarY + (self.scrollOffset / maxScroll) * (scrollbarHeight - thumbHeight)
    
    love.graphics.setColor(0.6, 0.6, 0.6, 0.8)
    love.graphics.rectangle("fill", scrollbarX, thumbY, scrollbarWidth, thumbHeight, 2, 2)
end

function InventoryState:mousemoved(x, y)
    -- Update hovered item for bag tab
    if self.activeTab == 'bag' and _G.PlayerState and _G.PlayerState:hasItems() then
        local items = _G.PlayerState:getInventoryItems()
        local panelWidth = 500
        local panelHeight = 400
        local contentX = (love.graphics.getWidth() - panelWidth) / 2
        local contentY = (love.graphics.getHeight() - panelHeight) / 2 + self.tabHeight
        local contentWidth = panelWidth
        
        self.hoveredItemIndex = ItemCard:getClickedCardIndex(x, y, items, contentX, contentY, contentWidth, self.scrollOffset)
    end
end

function InventoryState:wheelmoved(x, y)
    -- Handle scrolling in bag tab
    if self.activeTab == 'bag' and _G.PlayerState and _G.PlayerState:hasItems() then
        local items = _G.PlayerState:getInventoryItems()
        local panelWidth = 500
        local panelHeight = 400
        local contentWidth = panelWidth
        local contentHeight = panelHeight - self.tabHeight
        
        local maxScroll = ItemCard:getMaxScrollOffset(#items, contentWidth, contentHeight)
        local scrollSpeed = 30
        
        self.scrollOffset = math.max(0, math.min(maxScroll, self.scrollOffset - y * scrollSpeed))
    end
end

function InventoryState:exit()
    -- Clean up any resources if needed
end

return InventoryState
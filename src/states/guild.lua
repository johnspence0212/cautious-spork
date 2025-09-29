local ItemCard = require('src.ui.item_card')
local RecipeData = require('data.recipes')

local GuildState = {}

function GuildState:enter(previousState)
    self.previousState = previousState or 'game'
    self.font = love.graphics.newFont(18)
    self.titleFont = love.graphics.newFont(24)
    self.sellButtonFont = love.graphics.newFont(14)
    
    -- Exit button properties
    self.exitButtonSize = 30
    self.exitButtonPadding = 10
    
    -- Store interface properties
    self.scrollOffset = 0
    self.hoveredItemIndex = nil
    self.sellButtonHovered = nil
    
    -- Get all recipes for price lookup
    self.recipes = RecipeData.getAll()
    self.recipesByName = {}
    for _, recipe in ipairs(self.recipes) do
        self.recipesByName[recipe.name] = recipe
    end
end

function GuildState:update(dt)
    -- Update hover state for mouse position
    local mouseX, mouseY = love.mouse.getPosition()
    self:updateHoverState(mouseX, mouseY)
end

function GuildState:updateHoverState(mouseX, mouseY)
    if not _G.PlayerState then return end
    
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    local contentX = 50
    local contentY = 100
    local contentWidth = width - 100
    local contentHeight = height - 150
    
    local items = _G.PlayerState:getInventoryItems()
    
    -- Check item hover
    local hoveredIndex = ItemCard:getClickedCardIndex(mouseX, mouseY, items, contentX, contentY, contentWidth, self.scrollOffset)
    self.hoveredItemIndex = hoveredIndex
    
    -- Check sell button hover
    self.sellButtonHovered = nil
    if hoveredIndex then
        local sellButtonX, sellButtonY = self:getSellButtonPosition(hoveredIndex, items, contentX, contentY, contentWidth)
        if mouseX >= sellButtonX and mouseX <= sellButtonX + 60 and
           mouseY >= sellButtonY and mouseY <= sellButtonY + 25 then
            self.sellButtonHovered = hoveredIndex
        end
    end
end

function GuildState:getSellButtonPosition(itemIndex, items, contentX, contentY, contentWidth)
    local cardsPerRow, startX = ItemCard:calculateLayout(contentWidth)
    local startY = contentY + 60 - self.scrollOffset
    local cardX, cardY = ItemCard:getGridPosition(itemIndex, cardsPerRow, contentX + startX, startY)
    
    -- Position sell button in bottom right of card
    local sellButtonX = cardX + ItemCard.WIDTH - 65
    local sellButtonY = cardY + ItemCard.HEIGHT - 30
    
    return sellButtonX, sellButtonY
end

function GuildState:draw()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    -- Set background color
    love.graphics.clear(0.15, 0.1, 0.2, 1) -- Slightly purple background
    
    -- Draw title
    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(1, 1, 1, 1)
    local title = "Guild Merchant - Sell Your Items"
    local titleWidth = self.titleFont:getWidth(title)
    love.graphics.print(title, (width - titleWidth) / 2, 20)
    
    -- Draw player gold
    love.graphics.setFont(self.font)
    local goldText = "Gold: " .. (_G.PlayerState and _G.PlayerState:getGold() or 0)
    love.graphics.setColor(1, 1, 0.3, 1) -- Golden color
    love.graphics.print(goldText, width - 150, 60)
    
    -- Draw store content
    self:drawStoreContent()
    
    -- Draw exit button (X in top-right corner)
    local exitX = width - self.exitButtonSize - self.exitButtonPadding
    local exitY = self.exitButtonPadding
    
    love.graphics.setColor(0.8, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", exitX, exitY, self.exitButtonSize, self.exitButtonSize)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.font)
    love.graphics.print("X", exitX + 8, exitY + 4)
end

function GuildState:drawStoreContent()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    local contentX = 50
    local contentY = 100
    local contentWidth = width - 100
    local contentHeight = height - 150
    
    if not _G.PlayerState then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(self.font)
        love.graphics.print("Player state not available", contentX, contentY)
        return
    end
    
    local items = _G.PlayerState:getInventoryItems()
    
    if #items == 0 then
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        love.graphics.setFont(self.font)
        local noItemsText = "No items to sell. Craft some items first!"
        local textWidth = self.font:getWidth(noItemsText)
        love.graphics.print(noItemsText, (width - textWidth) / 2, height / 2)
        return
    end
    
    -- Instructions
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.setFont(self.font)
    love.graphics.print("Click 'SELL' buttons to sell items for gold", contentX, contentY - 25)
    
    -- Draw items using ItemCard component
    ItemCard:drawScrollableGrid(items, contentX, contentY, contentWidth, contentHeight, self.scrollOffset, {
        hoveredIndex = self.hoveredItemIndex
    })
    
    -- Draw sell buttons on top of cards
    self:drawSellButtons(items, contentX, contentY, contentWidth)
end

function GuildState:drawSellButtons(items, contentX, contentY, contentWidth)
    local cardsPerRow, startX = ItemCard:calculateLayout(contentWidth)
    local startY = contentY + 60 - self.scrollOffset
    
    -- Set up clipping for sell buttons
    love.graphics.setScissor(contentX, contentY + 60, contentWidth, love.graphics.getHeight() - contentY - 110)
    
    for i, item in ipairs(items) do
        local cardX, cardY = ItemCard:getGridPosition(i, cardsPerRow, contentX + startX, startY)
        
        -- Only draw buttons for visible cards
        if cardY + ItemCard.HEIGHT >= contentY + 60 and cardY <= contentY + love.graphics.getHeight() - 50 then
            local sellButtonX, sellButtonY = self:getSellButtonPosition(i, items, contentX, contentY, contentWidth)
            
            -- Get sell price for this item
            local recipe = self.recipesByName[item.name]
            local sellPrice = recipe and recipe.sellPrice or 1
            
            -- Button background
            local buttonColor = {0.2, 0.8, 0.2, 0.9} -- Green
            if self.sellButtonHovered == i then
                buttonColor = {0.3, 0.9, 0.3, 0.9} -- Brighter green
            end
            
            love.graphics.setColor(buttonColor)
            love.graphics.rectangle("fill", sellButtonX, sellButtonY, 60, 25, 3, 3)
            
            -- Button border
            love.graphics.setColor(0.1, 0.5, 0.1, 1)
            love.graphics.rectangle("line", sellButtonX, sellButtonY, 60, 25, 3, 3)
            
            -- Button text
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setFont(self.sellButtonFont)
            love.graphics.print("SELL", sellButtonX + 15, sellButtonY + 5)
            
            -- Sell price below button
            love.graphics.setColor(1, 1, 0.3, 1) -- Golden color
            love.graphics.print(sellPrice .. "g", sellButtonX + 20, sellButtonY - 15)
        end
    end
    
    -- Reset clipping
    love.graphics.setScissor()
end

function GuildState:keypressed(key, scancode, isrepeat)
    -- For now, just handle basic exit
end

function GuildState:mousepressed(x, y, button, istouch, presses)
    if button == 1 then -- Left mouse button
        local width = love.graphics.getWidth()
        local exitX = width - self.exitButtonSize - self.exitButtonPadding
        local exitY = self.exitButtonPadding
        
        -- Check if exit button was clicked
        if x >= exitX and x <= exitX + self.exitButtonSize and
           y >= exitY and y <= exitY + self.exitButtonSize then
            StateManager:switch(self.previousState)
            return
        end
        
        -- Check if sell button was clicked
        self:handleSellButtonClick(x, y)
    end
end

function GuildState:handleSellButtonClick(x, y)
    if not _G.PlayerState then return end
    
    local items = _G.PlayerState:getInventoryItems()
    if #items == 0 then return end
    
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    local contentX = 50
    local contentY = 100
    local contentWidth = width - 100
    
    -- Check each sell button
    for i, item in ipairs(items) do
        local sellButtonX, sellButtonY = self:getSellButtonPosition(i, items, contentX, contentY, contentWidth)
        
        if x >= sellButtonX and x <= sellButtonX + 60 and
           y >= sellButtonY and y <= sellButtonY + 25 then
            self:sellItem(item.name)
            break
        end
    end
end

function GuildState:sellItem(itemName)
    if not _G.PlayerState then return end
    
    -- Get the recipe to find sell price
    local recipe = self.recipesByName[itemName]
    if not recipe or not recipe.sellPrice then
        print("GuildState: No sell price found for " .. itemName)
        return
    end
    
    -- Check if player has the item
    local quantity = _G.PlayerState:getItemQuantity(itemName)
    if quantity <= 0 then
        print("GuildState: Player doesn't have " .. itemName)
        return
    end
    
    -- Perform the transaction
    if _G.PlayerState:removeItem(itemName, 1) then
        _G.PlayerState:addGold(recipe.sellPrice)
        print("GuildState: Sold " .. itemName .. " for " .. recipe.sellPrice .. " gold")
    end
end

function GuildState:mousemoved(x, y, dx, dy, istouch)
    self:updateHoverState(x, y)
end

function GuildState:wheelmoved(x, y)
    if not _G.PlayerState then return end
    
    local items = _G.PlayerState:getInventoryItems()
    if #items == 0 then return end
    
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    local contentWidth = width - 100
    local contentHeight = height - 150
    
    -- Calculate scroll parameters
    local maxScrollOffset = ItemCard:getMaxScrollOffset(#items, contentWidth, contentHeight)
    
    -- Update scroll offset
    self.scrollOffset = self.scrollOffset - y * 30 -- Scroll speed
    self.scrollOffset = math.max(0, math.min(maxScrollOffset, self.scrollOffset))
end

function GuildState:handleEscape()
    StateManager:switch(self.previousState)
end

function GuildState:exit()
    -- Clean up any resources if needed
end

return GuildState
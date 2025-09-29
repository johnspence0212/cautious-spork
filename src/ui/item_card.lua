--[[
    ItemCard - Reusable UI component for displaying items as cards
    
    Features:
    - Configurable card dimensions and styling
    - Rarity-based coloring
    - Word-wrapped descriptions
    - Grid layout calculations
    - Selection and hover states
    - Click detection
--]]

local ItemCard = {}

-- Card configuration
ItemCard.WIDTH = 200
ItemCard.HEIGHT = 80
ItemCard.SPACING = 15
ItemCard.CORNER_RADIUS = 5

-- Colors
ItemCard.COLORS = {
    background = {0.25, 0.25, 0.35, 0.9},
    border = {0.5, 0.5, 0.6, 1},
    itemName = {0.9, 0.8, 0.3, 1},     -- Golden
    quantity = {0.7, 0.9, 0.7, 1},     -- Light green
    description = {0.8, 0.8, 0.8, 1},  -- Light gray
    rarity = {
        common = {0.9, 0.8, 0.3, 1},
        uncommon = {0.3, 0.9, 0.3, 1},
        rare = {0.3, 0.3, 0.9, 1},
        epic = {0.6, 0.3, 0.9, 1},
        legendary = {0.9, 0.6, 0.1, 1}
    }
}

-- Fonts (will be initialized when first used)
ItemCard.fonts = {}

function ItemCard:getFont(size)
    if not self.fonts[size] then
        self.fonts[size] = love.graphics.newFont(size)
    end
    return self.fonts[size]
end

-- Calculate grid position for a card
function ItemCard:getGridPosition(index, cardsPerRow, startX, startY)
    local row = math.floor((index - 1) / cardsPerRow)
    local col = (index - 1) % cardsPerRow
    
    local x = startX + col * (self.WIDTH + self.SPACING)
    local y = startY + row * (self.HEIGHT + self.SPACING)
    
    return x, y
end

-- Calculate how many cards can fit in a given area
function ItemCard:calculateLayout(contentWidth, contentHeight)
    local cardsPerRow = math.floor((contentWidth - 40) / (self.WIDTH + self.SPACING))
    cardsPerRow = math.max(1, cardsPerRow) -- At least 1 card per row
    
    local totalWidth = cardsPerRow * self.WIDTH + (cardsPerRow - 1) * self.SPACING
    local startX = (contentWidth - totalWidth) / 2
    
    return cardsPerRow, startX
end

-- Calculate total height needed for all items
function ItemCard:calculateTotalHeight(itemCount, cardsPerRow)
    local rows = math.ceil(itemCount / cardsPerRow)
    return rows * (self.HEIGHT + self.SPACING) - self.SPACING
end

-- Word wrap text to fit within a given width
function ItemCard:wrapText(text, maxWidth, font)
    local words = {}
    for word in text:gmatch("%S+") do
        table.insert(words, word)
    end
    
    local lines = {}
    local currentLine = ""
    
    for _, word in ipairs(words) do
        local testLine = currentLine == "" and word or currentLine .. " " .. word
        if font:getWidth(testLine) <= maxWidth then
            currentLine = testLine
        else
            if currentLine ~= "" then
                table.insert(lines, currentLine)
                currentLine = word
            else
                -- Single word too long, truncate it
                table.insert(lines, string.sub(word, 1, 20) .. "...")
                currentLine = ""
            end
        end
    end
    
    if currentLine ~= "" then
        table.insert(lines, currentLine)
    end
    
    return lines
end

-- Truncate text if it's too long
function ItemCard:truncateText(text, maxWidth, font)
    if font:getWidth(text) <= maxWidth then
        return text
    end
    
    local truncated = text
    while font:getWidth(truncated .. "...") > maxWidth and #truncated > 0 do
        truncated = string.sub(truncated, 1, #truncated - 1)
    end
    
    return truncated .. "..."
end

-- Draw a single item card
function ItemCard:draw(item, x, y, options)
    options = options or {}
    local isSelected = options.selected or false
    local isHovered = options.hovered or false
    
    -- Determine rarity color
    local rarity = item.rarity or "common"
    local nameColor = self.COLORS.rarity[rarity] or self.COLORS.itemName
    
    -- Card background
    love.graphics.setColor(self.COLORS.background)
    if isSelected then
        love.graphics.setColor(0.35, 0.35, 0.45, 0.9) -- Lighter when selected
    elseif isHovered then
        love.graphics.setColor(0.3, 0.3, 0.4, 0.9) -- Slightly lighter when hovered
    end
    love.graphics.rectangle("fill", x, y, self.WIDTH, self.HEIGHT, self.CORNER_RADIUS, self.CORNER_RADIUS)
    
    -- Card border
    love.graphics.setColor(self.COLORS.border)
    if isSelected then
        love.graphics.setColor(nameColor) -- Border matches rarity when selected
        love.graphics.setLineWidth(2)
    end
    love.graphics.rectangle("line", x, y, self.WIDTH, self.HEIGHT, self.CORNER_RADIUS, self.CORNER_RADIUS)
    love.graphics.setLineWidth(1) -- Reset line width
    
    -- Item name (top of card)
    love.graphics.setColor(nameColor)
    love.graphics.setFont(self:getFont(16))
    local nameText = self:truncateText(item.name, self.WIDTH - 60, self:getFont(16))
    love.graphics.print(nameText, x + 10, y + 8)
    
    -- Quantity (top right)
    love.graphics.setColor(self.COLORS.quantity)
    local quantityText = "x" .. (item.quantity or 1)
    local quantityWidth = self:getFont(16):getWidth(quantityText)
    love.graphics.print(quantityText, x + self.WIDTH - quantityWidth - 10, y + 8)
    
    -- Description (bottom of card)
    love.graphics.setColor(self.COLORS.description)
    love.graphics.setFont(self:getFont(12))
    local descText = item.description or "No description"
    
    -- Word wrap description to fit card
    local maxWidth = self.WIDTH - 20
    local lines = self:wrapText(descText, maxWidth, self:getFont(12))
    
    -- Draw description lines (max 2 lines to fit in card)
    for i = 1, math.min(2, #lines) do
        love.graphics.print(lines[i], x + 10, y + 35 + (i - 1) * 15)
    end
end

-- Draw multiple cards in a scrollable grid layout
function ItemCard:drawScrollableGrid(items, contentX, contentY, contentWidth, contentHeight, scrollOffset, options)
    options = options or {}
    local selectedIndex = options.selectedIndex
    local hoveredIndex = options.hoveredIndex
    
    -- Calculate layout
    local cardsPerRow, startX = self:calculateLayout(contentWidth)
    local startY = contentY + 60 - scrollOffset -- Apply scroll offset
    
    -- Set up clipping for the content area
    love.graphics.setScissor(contentX, contentY + 60, contentWidth, contentHeight - 60)
    
    -- Draw cards
    for i, item in ipairs(items) do
        local cardX, cardY = self:getGridPosition(i, cardsPerRow, contentX + startX, startY)
        
        -- Only draw cards that are visible (basic culling)
        if cardY + self.HEIGHT >= contentY + 60 and cardY <= contentY + contentHeight then
            local cardOptions = {
                selected = (selectedIndex == i),
                hovered = (hoveredIndex == i),
                showIcons = options.showIcons
            }
            
            self:draw(item, cardX, cardY, cardOptions)
        end
    end
    
    -- Reset clipping
    love.graphics.setScissor()
    
    return cardsPerRow, startX, startY + scrollOffset
end

-- Check if a point is inside a card at a given position
function ItemCard:isPointInside(pointX, pointY, cardX, cardY)
    return pointX >= cardX and pointX <= cardX + self.WIDTH and
           pointY >= cardY and pointY <= cardY + self.HEIGHT
end

-- Find which card was clicked in a scrollable grid
function ItemCard:getClickedCardIndex(clickX, clickY, items, contentX, contentY, contentWidth, scrollOffset)
    local cardsPerRow, startX = self:calculateLayout(contentWidth)
    local startY = contentY + 60 - scrollOffset
    
    for i = 1, #items do
        local cardX, cardY = self:getGridPosition(i, cardsPerRow, contentX + startX, startY)
        
        if self:isPointInside(clickX, clickY, cardX, cardY) then
            return i
        end
    end
    
    return nil -- No card clicked
end

-- Calculate maximum scroll offset
function ItemCard:getMaxScrollOffset(itemCount, contentWidth, contentHeight)
    local cardsPerRow = self:calculateLayout(contentWidth)
    local totalHeight = self:calculateTotalHeight(itemCount, cardsPerRow)
    local availableHeight = contentHeight - 60 -- Subtract title space
    
    return math.max(0, totalHeight - availableHeight)
end

return ItemCard
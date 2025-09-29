--[[
    PlayerState - Manages player data including inventory
    
    Responsibilities:
    - Track player inventory (Bag of Holding)
    - Manage collected items
    - Handle inventory operations (add, remove, count)
    - Save/load player state
--]]

local PlayerState = {}
PlayerState.__index = PlayerState

function PlayerState:new()
    local instance = setmetatable({}, self)
    
    -- Initialize player inventory
    instance.inventory = {
        items = {} -- table of {name, quantity, description}
    }
    
    -- Initialize player currency
    instance.currency = {
        gold = 0
    }
    
    return instance
end

-- Add an item to the player's inventory
function PlayerState:addItem(itemName, quantity, description)
    quantity = quantity or 1
    description = description or itemName
    
    -- Check if item already exists
    local found = false
    for i, item in ipairs(self.inventory.items) do
        if item.name == itemName then
            item.quantity = item.quantity + quantity
            found = true
            print("PlayerState: Added " .. quantity .. " " .. itemName .. " (total: " .. item.quantity .. ")")
            break
        end
    end
    
    -- If item doesn't exist, create new entry
    if not found then
        table.insert(self.inventory.items, {
            name = itemName,
            quantity = quantity,
            description = description
        })
        print("PlayerState: Added new item: " .. quantity .. " " .. itemName)
    end
end

-- Remove an item from inventory
function PlayerState:removeItem(itemName, quantity)
    quantity = quantity or 1
    
    for i, item in ipairs(self.inventory.items) do
        if item.name == itemName then
            if item.quantity >= quantity then
                item.quantity = item.quantity - quantity
                print("PlayerState: Removed " .. quantity .. " " .. itemName .. " (remaining: " .. item.quantity .. ")")
                
                -- Remove item if quantity reaches 0
                if item.quantity == 0 then
                    table.remove(self.inventory.items, i)
                    print("PlayerState: " .. itemName .. " removed from inventory")
                end
                return true
            else
                print("PlayerState: Not enough " .. itemName .. " (have: " .. item.quantity .. ", need: " .. quantity .. ")")
                return false
            end
        end
    end
    
    print("PlayerState: " .. itemName .. " not found in inventory")
    return false
end

-- Get quantity of an item
function PlayerState:getItemQuantity(itemName)
    for _, item in ipairs(self.inventory.items) do
        if item.name == itemName then
            return item.quantity
        end
    end
    return 0
end

-- Get all items in inventory
function PlayerState:getInventoryItems()
    return self.inventory.items
end

-- Check if inventory has items
function PlayerState:hasItems()
    return #self.inventory.items > 0
end

-- Get total number of unique items
function PlayerState:getUniqueItemCount()
    return #self.inventory.items
end

-- Handle crafting completion - add crafted item to inventory
function PlayerState:onItemCrafted(recipe)
    if recipe and recipe.name then
        -- Add the crafted item to inventory
        local itemDescription = recipe.description or "A crafted item"
        self:addItem(recipe.name, 1, itemDescription)
    end
end

-- Currency management methods
function PlayerState:addGold(amount)
    amount = amount or 0
    if amount > 0 then
        self.currency.gold = self.currency.gold + amount
        print("PlayerState: Gained " .. amount .. " gold (total: " .. self.currency.gold .. ")")
    end
end

function PlayerState:removeGold(amount)
    amount = amount or 0
    if amount > 0 and self.currency.gold >= amount then
        self.currency.gold = self.currency.gold - amount
        print("PlayerState: Spent " .. amount .. " gold (remaining: " .. self.currency.gold .. ")")
        return true
    elseif amount > 0 then
        print("PlayerState: Not enough gold (have: " .. self.currency.gold .. ", need: " .. amount .. ")")
        return false
    end
    return true
end

function PlayerState:getGold()
    return self.currency.gold
end

function PlayerState:hasGold(amount)
    return self.currency.gold >= (amount or 0)
end

-- Debug function to print all inventory contents
function PlayerState:printInventory()
    print("=== Player Inventory ===")
    print("Gold: " .. self.currency.gold)
    print("Items:")
    if #self.inventory.items == 0 then
        print("  No items")
    else
        for i, item in ipairs(self.inventory.items) do
            print("  " .. i .. ". " .. item.name .. " x" .. item.quantity .. " - " .. item.description)
        end
    end
    print("========================")
end

return PlayerState
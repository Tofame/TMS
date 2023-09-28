-- Credits : Dewral
------------------------ Configuration ------------------------
local levers = {
    [5005] = {
        position = Position(1162, 1196, 7),
        transformations = {
            [471] = 472,
            [472] = 473,
            [473] = 474,
            [474] = 471
        },
        gateItems = {473}
    },
    [5006] = {
        position = Position(1164, 1196, 7),
        transformations = {
            [967] = 968,
            [968] = 970,
            [970] = 973,
            [973] = 967
        },
        gateItems = {973}
    },
    [5007] = {
        position = Position(1166, 1196, 7),
        transformations = {
            [3212] = 3213,
            [3213] = 3214,
            [3214] = 3215,
            [3215] = 3212
        },
        gateItems = {3215}
    }
}

local gatePos = {
    Position(1163, 1200, 7),
    Position(1164, 1200, 7),
    Position(1165, 1200, 7)
}
------------------------ Configuration ------------------------

------------------------ Functions ------------------------

-- Function for transforming tiles on defined position --
local function transformItem(tile, itemID, nextItemID)
    if not nextItemID then
        return false
    end

    -- Get the tile item ID
    local item = tile:getItemById(itemID)
    if not item then
        return false
    end

    -- Transform to next Item ID
    item:transform(nextItemID)
    item:getPosition():sendMagicEffect(3)
    return true
end


-- Function for checking positions with action ID --
local function checkPos(player, actionID)

    -- Get the lever action ID
    local lever = levers[actionID]

    if not lever then
        return false
    end

    -- Get tile from lever table positions
    local tile = Tile(lever.position)

    if not tile then
        return false
    end

    -- Iterate through transformations table and change the ID --
    for itemID, nextItemID in pairs(lever.transformations) do
        if transformItem(tile, itemID, nextItemID) then
            player:sendTextMessage(MESSAGE_INFO_DESCR, "You transformed a tile : " .. itemID .. " to " .. nextItemID)
            return true
        end
    end

    return false
end


------------------------ Functions ------------------------

-- Action of the script --
local changeTileID = Action()

function changeTileID.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if not player then
        return
    end

    local actionID = item:getActionId()
    checkPos(player, actionID)
end

changeTileID:aid(5005, 5006, 5007)
changeTileID:register()


------------------------ Open Gate Script ------------------------

-- Local Functions --

local function checkGate(player, item)
    local gateOpen = true

    -- Iterating through all levers in table 'levers' 
    for _, lever in pairs(levers) do
        local tile = Tile(lever.position)

        if not tile then
            gateOpen = false
            break
        end

        local gateItemsExist = true

        --  Iterating through all correct tiles to check if they exist
        for _, gateItemID in ipairs(lever.gateItems) do
            if not tile:getItemById(gateItemID) then
                gateItemsExist = false
                player:sendTextMessage(MESSAGE_STATUS_WARNING, "You are missing some IDs on tiles!")
                tile:getPosition():sendMagicEffect(3)
                break
            end
        end

        -- If one position is missing its Tile ID then set gateOpen to false
        if not gateItemsExist then
            gateOpen = false
        end
    end

    -- Iterate through positions
    if gateOpen then
        for _, position in ipairs(gatePos) do
            local tile = Tile(position)
            local gateItem = tile:getItemById(3362)

            -- If there is not defined ID of the Gate it will return false and send the magic effects
            if not gateItem then
                player:sendTextMessage(MESSAGE_STATUS_WARNING, "Fuck off!")

                -- Send magic effects for all gate positions
                for _, position in ipairs(gatePos) do
                    local tile = Tile(position)
                    local dirt = tile:getItemById(103)
                    dirt:getPosition():sendMagicEffect(3)
                end

                return false
            end

            local time = 5

            -- Use addEvent to recreate the item after a delay (time * 1000 milliseconds = time seconds)
            addEvent(function()
                local newGateItem = Game.createItem(3362, 1, position)
                if newGateItem then
                    newGateItem:getPosition():sendMagicEffect(3)
                end
            end, time * 1000)

            -- Open the gate
            player:sendTextMessage(MESSAGE_INFO_DESCR, "You successfully opened the gate!")
            gateItem:getPosition():sendMagicEffect(3)
            gateItem:remove(1)
        end
    end
end

-- Load script

local openGate = Action()

function openGate.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if not player then
        return
    end

    checkGate(player, item)

end

openGate:aid(5008) 
openGate:register()
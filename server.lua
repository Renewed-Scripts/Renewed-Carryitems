local Config = require 'config'

local Players = {}

local function equipItem(source, item)
    local coords = GetEntityCoords(GetPlayerPed(source))
    local itemConfig = Config[item]

    local object = CreateObject(itemConfig.model, coords.x, coords.y, coords.z - 20, true, true, true)

    while not DoesEntityExist(object) do
        Wait(0)
    end

    Players[source] = object

    SetEntityIgnoreRequestControlFilter(object, true)

    Player(source).state:set('attachEntity', {
        entity = NetworkGetNetworkIdFromEntity(object),
        bone = itemConfig.bone,
        offset = itemConfig.offset,
        item = item,
        rotation = itemConfig.rotation
    }, true)

    return true
end

local function canCarry(source)
    return source and not Players[source]
end

exports('canCarry', canCarry)

exports.ox_inventory:registerHook('swapItems', function(payload)
    if not payload.source then return true end

    local item = payload.fromSlot and payload.fromSlot.name or payload.toSlot.name
    local addItem = type(payload.fromInventory) == 'string'
    local source = payload.source


    if addItem then
        return not Players[source] and equipItem(source, item) or false
    elseif Players[source] then
        DeleteEntity(Players[source])
        Players[source] = nil
        Player(source).state:set('attachEntity', nil, true)
    end

    return true
end, {
    itemFilter = Config,
})

exports.ox_inventory:registerHook('buyItem', function(payload)
    local banned = canCarry(payload.source)

    if banned then
        TriggerClientEvent('ox_lib:notify', payload.source, { type = 'error', description = 'You cannot carry this item' })
        return false
    end

    return false
end, {
    itemFilter = Config,
})

exports.ox_inventory:registerHook('craftItem', function(payload)
    local banned = canCarry(payload.source)

    if banned then
        TriggerClientEvent('ox_lib:notify', payload.source, { type = 'error', description = 'You cannot carry this item' })
        return false
    end

    return false
end, {
    itemFilter = Config,
})

local Config = require 'config'

for _, v in pairs(Config) do
    if not v.animDict then
        v.animDict = 'anim@heists@box_carry@'
    end

    if not v.animName then
        v.animName = 'idle'
    end
end

local DisableControlAction = DisableControlAction
local itemAttached = LocalPlayer.state.attachEntity
AddStateBagChangeHandler('attachEntity', ('player:%s'):format(cache.serverId), function(_, _, value)
    if value and value.item then
        local itemConfig = Config[value.item]

        if itemConfig then
            SetTimeout(50, function()
                lib.RequestAnimDict(itemConfig.animDict)

                while itemAttached do
                    if not IsEntityPlayingAnim(cache.ped, itemConfig.animDict, itemConfig.animName, 3) then
                        TaskPlayAnim(cache.ped, itemConfig.animDict, itemConfig.animName, 8.0, -8, -1, 49, 0, 0, 0, 0)
                    end

                    if itemConfig.blockAttack then
                        DisableControlAction(0, 24, true) -- disable attack
                        DisableControlAction(0, 25, true) -- disable aim
                        DisableControlAction(0, 47, true) -- disable weapon
                        DisableControlAction(0, 58, true) -- disable weapon
                        DisableControlAction(0, 263, true) -- disable melee
                        DisableControlAction(0, 264, true) -- disable melee
                        DisableControlAction(0, 257, true) -- disable melee
                        DisableControlAction(0, 140, true) -- disable melee
                        DisableControlAction(0, 141, true) -- disable melee
                        DisableControlAction(0, 142, true) -- disable melee
                        DisableControlAction(0, 143, true) -- disable melee
                    end

                    if itemConfig.blockCar and IsPedGettingIntoAVehicle(ped) then
                        ClearPedTasksImmediately(ped) -- Stops all tasks for the ped
                    end

                    if itemConfig.blockRun then
                        DisableControlAction(0, 22, true) -- disable jumping
                        DisableControlAction(0, 21, true) -- disable sprinting
                    end


                    Wait(0)
                end

                ClearPedTasks(cache.ped)
                RemoveAnimDict(itemConfig.animDict)
            end)
        end
    end

    itemAttached = value
end)

local function canCarry()
    if itemAttached and itemAttached.item and Config[itemAttached.item] then
        return false
    end

    return true
end

local function isCarryingObject()
    if itemAttached and itemAttached.item and Config[itemAttached.item] then
        return true
    end

    return false
end

exports('canCarry', canCarry)
exports('isCarryingObject', isCarryingObject)
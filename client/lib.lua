lib = {}

if Config.Framework == 'esx' and GetResourceState('es_extended'):match('start') then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == 'qb' and GetResourceState('qb-core'):match('start') then
    QBCore = exports['qb-core']:GetCoreObject()
else
    print('Framework not found')
    return
end

lib.GetJob = function ()
    if Config.Framework == 'esx' then
        return ESX.PlayerData.job.label
    elseif Config.Framework == 'qb' then
        return QBCore.Functions.GetPlayerData().job.label
    end
end

lib.ShowNotification = function (msg)
    if Config.Framework == 'esx' then
        ESX.ShowNotification(msg)
    elseif Config.Framework == 'qb' then
        QBCore.Functions.Notify(msg)
    end
end

lib.GetStats = function ()
    local thirst, hunger
    if Config.Framework == 'qb' then
         thirst = math.floor(QBCore.Functions.GetPlayerData().metadata['thirst'])
         hunger = math.floor(QBCore.Functions.GetPlayerData().metadata['hunger'])
        return thirst, hunger
    elseif Config.Framework == 'esx' then
        TriggerEvent('esx_status:getStatus', 'thirst', function(status)
            thirst = math.floor(status.getPercent())
        end)

        TriggerEvent('esx_status:getStatus', 'hunger', function(status)
            hunger = math.floor(status.getPercent())
        end)
        return thirst, hunger
    end
end
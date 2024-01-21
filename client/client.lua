local playerid, health, armor, stamina, thirst, hunger, map, job
local show, inVeh = true, false

Citizen.CreateThread(function()
    while ESX == nil or QBCore == nil do
        Citizen.Wait(0)
        if Config.Framework == 'esx' then
            ESX = exports['es_extended']:getSharedObject()
        elseif Config.Framework == 'qb' then
            QBCore = exports['qb-core']:GetCoreObject()
        end
    end
end)

TurnEngine = function()
    local ped = GetPlayerPed(-1)
    local vehicle = GetVehiclePedIsIn(ped, false)
    if inVeh and IsPedInAnyVehicle(ped, false) then
        SetVehicleEngineOn(vehicle, not GetIsVehicleEngineRunning(vehicle), false, true)
    end
end

Citizen.CreateThread(function()
    while true do
        Wait(500)
        if show and not IsPauseMenuActive() then
            local ped = GetPlayerPed(-1)
            if DoesEntityExist(ped) then
                playerid = GetPlayerServerId(PlayerId())
                health = GetEntityHealth(ped) / 2
                armor = GetPedArmour(ped)
                stamina = math.floor(100 - GetPlayerSprintStaminaRemaining(PlayerId()))

                if Config.Framework == 'esx' then
                    TriggerEvent('esx_status:getStatus', 'thirst', function(status)
                        thirst = math.floor(status.getPercent())
                    end)
                    TriggerEvent('esx_status:getStatus', 'hunger', function(status)
                        hunger = math.floor(status.getPercent())
                    end)
                elseif Config.Framework == 'qb' then
                    thirst = math.floor(QBCore.Functions.GetPlayerData().metadata['thirst'])
                    hunger = math.floor(QBCore.Functions.GetPlayerData().metadata['hunger'])
                end

                if Config.UseMap then DisplayRadar(true) end

                if Config.ShowJob then
                    if Config.Framework == 'esx' then
                        job = ESX.PlayerData.job and ESX.PlayerData.job.label or 'Unemployed'
                    elseif Config.Framework == 'qb' then
                        local playerData = QBCore.Functions.GetPlayerData()
                        job = playerData.job and playerData.job.label or 'Unemployed'
                    end
                    SendNUIMessage({
                        action = 'showHud',
                        health = health,
                        armor = armor,
                        stamina = stamina,
                        thirst = thirst,
                        hunger = hunger,
                        job = job,
                        playerid = playerid,
                        map = Config.UseMap
                    })
                else
                    SendNUIMessage({
                        action = 'showHud',
                        health = health,
                        armor = armor,
                        stamina = stamina,
                        thirst = thirst,
                        hunger = hunger,
                        playerid = playerid
                    })
                end
            end
        elseif not show or IsPauseMenuActive then
            SendNUIMessage({
                action = 'hideHud',
            })
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(1000)
        if IsPedInAnyVehicle(PlayerPedId(), false) and Config.OnVehicleMap then
            SendNUIMessage({
                action = 'showSpeed',
                map = true
            })
            inVeh = true
            DisplayRadar(true)
        else
            SendNUIMessage({
                action = 'hideSpeed',
                map = false
            })
            inVeh = false
            DisplayRadar(false)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(100)
        if inVeh and IsPedInAnyVehicle(PlayerPedId(), false) then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            local engine = GetIsVehicleEngineRunning(vehicle)
            local lights = GetVehicleLightsState(vehicle)
            local rpm = math.floor((GetVehicleCurrentRpm(vehicle) * 100))
            local speed = math.floor(GetEntitySpeed(vehicle) * 3.6)
            SendNUIMessage({
                action = 'vehicleStatus',
                engine = engine,
                lights = lights,
                rpm = rpm,
                speed = speed
            })
        end
    end
end)

RegisterKeyMapping('TurnEngine', 'Apagar el motor del vehiculo', 'keyboard', Config.TurnEngine)
RegisterCommand('TurnEngine', TurnEngine, false)

RegisterCommand('togglecolor', function() SendNUIMessage({ action = 'toggleColor', }) end, false)

RegisterCommand('hud', function()
    show = not show
    local status = show and "activado" or "desactivado"
    ShowNotification("Se ha " .. status .. " el HUD.")
end, false)

ShowNotification = function(msg)
    if Config.Framework == 'esx' then
        ESX.ShowNotification(msg)
    elseif Config.Framework == 'qb' then
        QBCore.Functions.Notify(msg)
    end
end

RegisterKeyMapping('CruiseControl', 'Activar/Desactivar el control de crucero', 'keyboard', Config.CruiseControl)
RegisterCommand("CruiseControl", function() CruiseControl() end, false)

CruiseControl = function()
    local ped = GetPlayerPed(-1)
    local vehicle = GetVehiclePedIsIn(ped, false)
    local isDriver = GetPedInVehicleSeat(vehicle, -1) == ped

    if inVeh and isDriver then
        if not Cruise then
            SetVehicleMaxSpeed(vehicle, GetEntitySpeed(vehicle))
            Cruise = true
        else
            Cruise = false
            SetVehicleMaxSpeed(vehicle, 0.0)
        end
        SendNUIMessage({
            action = 'cruiseControl',
            cruise = Cruise
        })
    end
end

Citizen.CreateThread(function()
    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)
    while true do
        Wait(0)
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)

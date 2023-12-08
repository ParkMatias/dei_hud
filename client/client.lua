local ESX = exports["es_extended"]:getSharedObject()
local playerid, health, armor, stamina, thirst, hunger, speed, fuel, map
local show = true

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        ActualizarHud()
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    ActualizarHud()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function()
    ActualizarHud()
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function()
    ActualizarHud()
end)

function TurnEngine()
    local ped = GetPlayerPed(-1)
    local vehicle = GetVehiclePedIsIn(ped, false)
    if IsPedInAnyVehicle(ped, false) then
        if GetIsVehicleEngineRunning(vehicle) then
            SetVehicleEngineOn(vehicle, false, false, true)
        else
            SetVehicleEngineOn(vehicle, true, false, true)
        end
    end
end

function IsPedValid(ped)
    return ped and DoesEntityExist(ped) and not IsEntityDead(ped)
end

function ActualizarHud()
    Citizen.CreateThread(function()
        while true do
            if show and not IsPauseMenuActive() then
                local ped = GetPlayerPed(-1)
                if IsPedValid(ped) then
                    map = Config.UseMap
                    playerid = GetPlayerServerId(PlayerId())
                    health = GetEntityHealth(ped) / 2
                    armor = GetPedArmour(ped)
                    stamina = math.floor(100 - GetPlayerSprintStaminaRemaining(PlayerId()))

                    TriggerEvent('esx_status:getStatus', 'thirst', function(status)
                        thirst = math.floor(status.getPercent())
                    end)

                    TriggerEvent('esx_status:getStatus', 'hunger', function(status)
                        hunger = math.floor(status.getPercent())
                    end)
                    
                    DisplayRadar(Config.UseMap)

                    if Config.ShowJob then
                        local job = ESX.GetPlayerData().job.label
                        SendNUIMessage({
                            action = 'showHud',
                            health = health,
                            armor = armor,
                            stamina = stamina,
                            thirst = thirst,
                            hunger = hunger,
                            job = job,
                            playerid = playerid,
                            map = map
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

                    if IsPedInAnyVehicle(ped, false) then
                        local vehicle = GetVehiclePedIsIn(ped, false)
                        local fuel = GetVehicleFuelLevel(vehicle)
                        speed = math.floor(GetEntitySpeed(vehicle) * 3.6)
                        SendNUIMessage({
                            action = 'showSpeed',
                            speed = speed,
                            fuel = fuel
                        })
                        local lights = GetVehicleLightsState(vehicle)
                        local engine = GetIsVehicleEngineRunning(vehicle)
                        SendNUIMessage({
                            action = 'vehicleStatus',
                            lights = lights,
                            engine = engine
                        })
                    else
                        SendNUIMessage({
                            action = 'hideSpeed',
                        })
                    end
                end
                Citizen.Wait(300)
            elseif not show or IsPauseMenuActive then
                SendNUIMessage({
                    action = 'hideHud',
                })
            end
            Citizen.Wait(300)
        end
    end)
end

RegisterKeyMapping('TurnEngine', 'Apagar el motor del vehiculo', 'keyboard', Config.TurnEngine)
RegisterCommand('TurnEngine', function()
    TurnEngine()
end, false)

RegisterCommand('hud', function()
    show = not show
    local status = show and "activado" or "desactivado"
    ESX.ShowNotification("Se ha " .. status .. " el HUD.")
end, false)
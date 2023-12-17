local playerid, health, armor, stamina, thirst, hunger, map
local show, inVeh = true, false

TurnEngine = function()
    local ped = GetPlayerPed(-1)
    local vehicle = GetVehiclePedIsIn(ped, false)
    if inVeh and IsPedInAnyVehicle(ped, false) then
        if GetIsVehicleEngineRunning(vehicle) then
            SetVehicleEngineOn(vehicle, false, false, true)
        else
            SetVehicleEngineOn(vehicle, true, false, true)
        end
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
                thirst, hunger = lib.GetStats()

                if Config.UseMap then
                    DisplayRadar(true)
                end

                if Config.ShowJob then
                    SendNUIMessage({
                        action = 'showHud',
                        health = health,
                        armor = armor,
                        stamina = stamina,
                        thirst = thirst,
                        hunger = hunger,
                        job = lib.GetJob(),
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
                action = 'showSpeed', map = true })
            inVeh = true
            DisplayRadar(true)
        else
            SendNUIMessage({ action = 'hideSpeed', map = false })
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
RegisterCommand('TurnEngine', function()
    TurnEngine()
end, false)

RegisterCommand('togglecolor', function()
    SendNUIMessage({
        action = 'toggleColor',
    })
end, false)

RegisterCommand('hud', function()
    show = not show
    local status = show and "activado" or "desactivado"
    lib.ShowNotification("Se ha " .. status .. " el HUD.")
end, false)

RegisterKeyMapping('CruiseControl', 'Activar/Desactivar el control de crucero', 'keyboard', Config.CruiseControl)
RegisterCommand("CruiseControl", function()
    CruiseControl()
end, false)

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
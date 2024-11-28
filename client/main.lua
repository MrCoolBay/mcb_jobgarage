local currentVehicle = nil
local spawnedPeds = {}

-- Fonction pour charger la langue
local function LoadLanguage()
    local language = Config.DefaultLanguage or 'en'
    if not Locales[language] then
        print('^1Erreur: Langue '..language..' non trouvée, utilisation de l\'anglais^0')
        return Locales['en']
    end
    return Locales[language]
end

local function CreateGaragePed(garageId, pedConfig)
    lib.requestModel(pedConfig.model)
    
    local ped = CreatePed(4, pedConfig.model, 
        pedConfig.coords.x, 
        pedConfig.coords.y, 
        pedConfig.coords.z, 
        pedConfig.coords.w, 
        false, 
        true
    )
    
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetPedCanPlayAmbientAnims(ped, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    
    if pedConfig.scenario then
        TaskStartScenarioInPlace(ped, pedConfig.scenario, 0, true)
    end
    
    spawnedPeds[garageId] = ped
    return ped
end

-- Events côté client
RegisterNetEvent('mcb_jobgarage:client:spawnVehicleConfirmed', function(garageId)
    local garage = Config.Garages[garageId]
    if not garage then return end
    
    SpawnVehicle(garage)
end)

RegisterNetEvent('mcb_jobgarage:client:returnVehicleConfirmed', function()
    if currentVehicle and DoesEntityExist(currentVehicle) then
        DeleteEntity(currentVehicle)
        currentVehicle = nil
        lib.notify({
            title = LoadLanguage()['success'],
            description = LoadLanguage()['vehicle_returned'],
            type = 'success'
        })
    end
end)

RegisterNetEvent('mcb_jobgarage:client:setVehicleStatus', function(hasVehicle)
    currentVehicle = hasVehicle
end)

-- Vérification du statut du véhicule au démarrage
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        TriggerServerEvent('mcb_jobgarage:server:checkVehicle')
    end
end)

local function SpawnVehicle(garage, vehicleData)
    lib.requestModel(vehicleData.model)
    
    currentVehicle = CreateVehicle(
        vehicleData.model,
        garage.spawnPoint.x,
        garage.spawnPoint.y,
        garage.spawnPoint.z,
        garage.spawnPoint.w,
        true,
        false
    )
    
    SetEntityAsMissionEntity(currentVehicle, true, true)
    SetVehicleOnGroundProperly(currentVehicle)
    
    lib.notify({
        title = LoadLanguage()['success'],
        description = LoadLanguage()['vehicle_spawned'],
        type = 'success'
    })
end

local function OpenGarageMenu(garage)
    local options = {}
    local L = LoadLanguage()
    
    for _, vehicle in ipairs(garage.vehicles) do
        table.insert(options, {
            title = vehicle.label,
            description = L['press_to_spawn']:format(vehicle.label),
            icon = 'car',
            onSelect = function()
                if currentVehicle then
                    lib.notify({
                        title = L['error'],
                        description = L['already_has_vehicle'],
                        type = 'error'
                    })
                    return
                end
                
                lib.requestModel(vehicle.model)
                
                currentVehicle = CreateVehicle(
                    vehicle.model,
                    garage.spawnPoint.x,
                    garage.spawnPoint.y,
                    garage.spawnPoint.z,
                    garage.spawnPoint.w,
                    true,
                    false
                )
                
                SetEntityAsMissionEntity(currentVehicle, true, true)
                SetVehicleOnGroundProperly(currentVehicle)
                
                lib.notify({
                    title = L['success'],
                    description = L['vehicle_spawned'],
                    type = 'success'
                })
            end
        })
    end
    
    lib.registerContext({
        id = 'job_garage_menu',
        title = garage.label,
        options = options
    })
    
    lib.showContext('job_garage_menu')
end

-- Initialisation des garages
CreateThread(function()
    for garageId, garage in pairs(Config.Garages) do
        -- Création du ped
        if garage.ped then
            local ped = CreateGaragePed(garageId, garage.ped)
            
            -- Ajout de l'interaction sur le ped
            exports.ox_target:addLocalEntity(ped, {
                {
                    label = LoadLanguage()['open_garage'],
                    icon = 'fas fa-warehouse',
                    groups = garage.job,
                    onSelect = function()
                        OpenGarageMenu(garage)
                    end
                }
            })
        end
        
        -- Point de retour du véhicule
        exports.ox_target:addSphereZone({
            coords = garage.returnPoint,
            radius = 3.0,
            debug = Config.Debug,
            options = {
                {
                    label = LoadLanguage()['return_vehicle'],
                    icon = 'fas fa-parking',
                    groups = garage.job,
                    canInteract = function()
                        return currentVehicle ~= nil and DoesEntityExist(currentVehicle)
                    end,
                    onSelect = function()
                        if currentVehicle and DoesEntityExist(currentVehicle) then
                            DeleteEntity(currentVehicle)
                            currentVehicle = nil
                            lib.notify({
                                title = LoadLanguage()['success'],
                                description = LoadLanguage()['vehicle_returned'],
                                type = 'success'
                            })
                        end
                    end
                }
            }
        })
    end
end)

-- Nettoyage des peds au redémarrage de la ressource
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, ped in pairs(spawnedPeds) do
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
    end
end)
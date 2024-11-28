local activeVehicles = {}

-- Event lors de la sortie d'un véhicule
RegisterNetEvent('mcb_jobgarage:server:spawnVehicle', function(garageId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source) -- ou QB-Core selon ton framework
    
    -- Vérifie si le joueur a déjà un véhicule sorti
    if activeVehicles[source] then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = _U('already_has_vehicle')
        })
        return
    end
    
    -- Vérifie si le joueur a le bon job
    local garage = Config.Garages[garageId]
    if not garage then return end
    
    if xPlayer.job.name ~= garage.job then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = _U('no_permission')
        })
        return
    end
    
    -- Enregistre le véhicule comme actif
    activeVehicles[source] = true
    TriggerClientEvent('mcb_jobgarage:client:spawnVehicleConfirmed', source, garageId)
end)

-- Event lors du rangement d'un véhicule
RegisterNetEvent('mcb_jobgarage:server:returnVehicle', function()
    local source = source
    
    -- Vérifie si le joueur avait bien un véhicule sorti
    if not activeVehicles[source] then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = _U('no_vehicle_out')
        })
        return
    end
    
    -- Supprime l'enregistrement du véhicule
    activeVehicles[source] = nil
    TriggerClientEvent('mcb_jobgarage:client:returnVehicleConfirmed', source)
end)

-- Supprime l'enregistrement du véhicule quand un joueur se déconnecte
AddEventHandler('playerDropped', function()
    local source = source
    if activeVehicles[source] then
        activeVehicles[source] = nil
    end
end)

-- Event pour vérifier si un joueur a un véhicule sorti
RegisterNetEvent('mcb_jobgarage:server:checkVehicle', function()
    local source = source
    local hasVehicle = activeVehicles[source] or false
    TriggerClientEvent('mcb_jobgarage:client:setVehicleStatus', source, hasVehicle)
end)
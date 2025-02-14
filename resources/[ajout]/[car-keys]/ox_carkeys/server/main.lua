lib.locale()

local ox_inventory = exports.ox_inventory

RegisterServerEvent('ox_carkeys:KeyOnBuy', function(plate,model)
    if ox_inventory:CanCarryItem(source, Keys.ItemName, 1) then
        ox_inventory:AddItem(source, Keys.ItemName, 1, {plate = plate, description = locale('key_description',plate,model)})
    end
end)

RegisterServerEvent('ox_carkeys:BuyKeys', function(plate,model)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getMoney() >= Keys.CopyPrice then
        if ox_inventory:CanCarryItem(source, Keys.ItemName, 1) then
            exports.ox_inventory:RemoveItem(source, 'money', Keys.CopyPrice)
            ox_inventory:AddItem(source, Keys.ItemName, 1, {plate = plate, description = locale('key_description',plate,model)})
            TriggerClientEvent('ox_carkeys:Notification', source, locale('title'), locale('llavecomprada',model,Keys.CopyPrice), 'success')
        end
    else
        TriggerClientEvent('ox_carkeys:Notification', source, locale('title'), locale('NoDinero'), 'error')
    end
    
end)

lib.callback.register('ox_carkeys:getVehicles', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local vehicles = {}

    local results = MySQL.Sync.fetchAll("SELECT * FROM `owned_vehicles` WHERE `owner` = @identifier", {
        ['@identifier'] = identifier,
    })
    if results[1] ~= nil then
        for i = 1, #results do
            local result = results[i]
            local veh = json.decode(result.vehicle)
            vehicles[#vehicles + 1] = { plate = result.plate, vehicle = veh }
        end
        return vehicles
    end
end)

if Keys.CloseDoorsNPC then
    AddEventHandler('entityCreated', function(entity)
        if not DoesEntityExist(entity) then
            return
        end
        local entityType = GetEntityType(entity)
        if entityType ~= 2 then
            return
        end
        if GetEntityPopulationType(entity) > 5 then
            return
        end
        if Keys.DoorProbability then
            if math.random() > Keys.OpenDoorProbability then
                return
            end
        end

        SetVehicleDoorsLocked(entity, 2)

    end)
end

RegisterServerEvent('ox_carkeys:sendems')
AddEventHandler('ox_carkeys:sendems', function(coords)
    TriggerClientEvent('ox_carkeys:sendems2', -1, coords)
end)

RegisterServerEvent('ox_carkeys:remove')
AddEventHandler('ox_carkeys:remove', function()
	_source = source
    xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.removeInventoryItem('lockpick', 1)
end)
ESX                = nil
local playervehiclelist = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Event to evaluate where should every vehicle be saved in the table.
RegisterServerEvent('esx_jb_stopvehicledespawn:savevehicle')
AddEventHandler('esx_jb_stopvehicledespawn:savevehicle', function(id, model, x, y, z, heading, vehicleProps)
	local vehiclestable = LoadVehiclesFile()
	saveVehicleToFile(id, model, x, y, z, heading, vehicleProps)
	print("test1")
end)

RegisterServerEvent("esx_jb_stopvehicledespawn:getallvehicles")
AddEventHandler("esx_jb_stopvehicledespawn:getallvehicles", function()
	local _source = source
	local vehiclelist = LoadVehiclesFile()
	TriggerClientEvent("esx_jb_stopvehicledespawn:vehiclecheck", _source, vehiclelist)
	print("test2")
end)

RegisterServerEvent('esx_jb_stopvehicledespawn:getvehicletable')
AddEventHandler('esx_jb_stopvehicledespawn:getvehicletable', function()
	local _source = source
	local vehiclelist = LoadVehiclesFile()
	TriggerClientEvent('esx_jb_stopvehicledespawn:vehiclecheck', _source, vehiclelist)
	print("test3")
end)

RegisterServerEvent("esx_jb_stopvehicledespawn:replacevehicleid")
AddEventHandler("esx_jb_stopvehicledespawn:replacevehicleid", function(oldid, newid)
	replacevehicleid(oldid, newid)
	print("test4")
end)

RegisterServerEvent("esx_jb_stopvehicledespawn:MakeNewNetworkedCar")
AddEventHandler("esx_jb_stopvehicledespawn:MakeNewNetworkedCar", function(oldid)
	local _source = source
	local vehiclelist = LoadVehiclesFile()
	oldid = tostring(oldid)
	if vehiclelist[oldid] ~= nil then
		deleteVehicleId(oldid)
		TriggerClientEvent("esx_jb_stopvehicledespawn:SpawnNewNetworkedCar", _source, vehiclelist[oldid])
	end
	print("test5")
end)


RegisterServerEvent("esx_jb_stopvehicledespawn:vehicleenteredingarage")
AddEventHandler("esx_jb_stopvehicledespawn:vehicleenteredingarage", function(networkid)
	local _source = source
	local vehiclelist = LoadVehiclesFile()
	networkid = tostring(networkid)
	if vehiclelist[networkid] ~= nil then
		deleteVehicleId(networkid)
	end
	print("test6")
end)

RegisterServerEvent("esx_jb_stopvehicledespawn:deleteFromListAndPutInPound")
AddEventHandler("esx_jb_stopvehicledespawn:deleteFromListAndPutInPound", function(vehicleid)
	local vehiclelist = LoadVehiclesFile()
	vehicleid = tostring(vehicleid)
	if vehiclelist[vehicleid] ~= nil then
		for i = 1, #playervehiclelist do
			local plate = playervehiclelist[i]
			if string.upper(plate) == string.upper(vehiclelist[vehicleid].vehicleProps.plate) then
				MySQL.Async.execute(
					"UPDATE owned_vehicles set state = 1 where id = @id",
					{
						['@identifier'] = v.owner,
						['@id'] = v.id
					}
				)
				MySQL.Async.execute(
					'INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (@identifier, @sender, @target_type, @target, @label, @amount)',
					{
						['@identifier']  = v.owner,
						['@sender']      = 'steam:110000112230801',
						['@target_type'] = 'player',
						['@target']      = 'steam:110000112230801',
						['@label']       = "Dépannage véhicule",
						['@amount']      = 3000
					},
					function(rowsChanged)
					end
				)
				break
			end
		end
		deleteVehicleId(vehicleid)
	end
	print("test7")
end)


ESX.RegisterServerCallback('getplatelist', function(source, cb)
	local platelist = {}
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles',{},function(vehicleplatelist)
		for i = 1, #vehicleplatelist do
			local plate = vehicleplatelist[i].plate
			playervehiclelist[i] = plate
			platelist[plate] = true
		end
		cb(platelist)
	end)
	print("test8")
end)

function dump(o, nb)
  if nb == nil then
    nb = 0
  end
   if type(o) == 'table' then
      local s = ''
      for i = 1, nb + 1, 1 do
        s = s .. "    "
      end
      s = '{\n'
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
          for i = 1, nb, 1 do
            s = s .. "    "
          end
         s = s .. '['..k..'] = ' .. dump(v, nb + 1) .. ',\n'
      end
      for i = 1, nb, 1 do
        s = s .. "    "
      end
      return s .. '}'
   else
      return tostring(o)
   end
end

ESX						= nil
local GUI				= {}
local PlayerData		= {}
local playervehiclesplates = {}


Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(3000)
	ESX.TriggerServerCallback('getplatelist', function(platelist)
		playervehiclesplates = platelist
	end)
  end
end)

function savevehtofile(vehicle)
	local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
	local plate = vehicleProps.plate
	plate = tostring(plate)
	
	local model = vehicleProps.model
	local x,y,z = table.unpack(GetEntityCoords(vehicle))
	local heading = GetEntityHeading(vehicle)
	
	networkid = NetworkGetNetworkIdFromEntity(vehicle)
	SetNetworkIdExistsOnAllMachines(networkid, true)
	SetNetworkIdCanMigrate(networkid, true)
	if playervehiclesplates[plate] then
		TriggerServerEvent('esx_jb_stopvehicledespawn:savevehicle', networkid, model, x, y, z, heading, vehicleProps)
	end

end


if saveOnEnter then
	Citizen.CreateThread(function()
		local inVehicle = false
		while true do
			local playerPed = GetPlayerPed(-1)
			if IsPedInAnyVehicle(playerPed) then
				local vehicle =GetVehiclePedIsIn(playerPed,false)
				if GetPedInVehicleSeat(vehicle, -1) == playerPed then
					if not inVehicle then
						savevehtofile(vehicle)
						inVehicle = true
					end
				else
					inVehicle = false
				end
				
			else
				inVehicle = false
			end
			Citizen.Wait(500)
		end
	end)
end

Citizen.CreateThread(function()
	local vehicle = 0
	local inVeh = false
	while true do
		local playerPed = GetPlayerPed(-1)
		if IsPedInAnyVehicle(playerPed) then
			local vehicle =GetVehiclePedIsIn(playerPed,false)
			if GetPedInVehicleSeat(vehicle, -1) == playerPed then
				inVeh = true
				savevehtofile(vehicle)
				SetVehicleHasBeenOwnedByPlayer(vehicle, true)
			else
				inVeh = false
			end
		elseif saveOnExit then
			if inVeh then
				local vehicle = GetVehiclePedIsIn(playerPed, true)
				savevehtofile(vehicle)
			end
			inVeh = false
		end

		Citizen.Wait(intervals.save*1000)
	end
end)



RegisterNetEvent('esx_jb_stopvehicledespawn:vehiclecheck')
AddEventHandler('esx_jb_stopvehicledespawn:vehiclecheck', function(vehiclelist)
	for vehicleid, vehicle in pairs(vehiclelist) do
		vehicleid = tonumber(vehicleid)
		networkvehicleid = NetworkGetEntityFromNetworkId(vehicleid)
		if not DoesEntityExist(networkvehicleid) and NetworkIsHost() then
			TriggerServerEvent('esx_jb_stopvehicledespawn:MakeNewNetworkedCar',vehicleid)
		else
			if GetVehicleBodyHealth_2(networkvehicleid) == 0.0 and GetVehicleBodyHealth(networkvehicleid) == 0.0 then
				DeleteEntity(networkvehicleid)
				if NetworkIsHost() then
					TriggerServerEvent('esx_jb_stopvehicledespawn:deleteFromListAndPutInPound', vehicleid)
				end
			end
		end
	end
end)


RegisterNetEvent('esx_jb_stopvehicledespawn:SpawnNewNetworkedCar')
AddEventHandler('esx_jb_stopvehicledespawn:SpawnNewNetworkedCar', function(vehicle)
	local model = tonumber(vehicle.model)
		ESX.Game.SpawnVehicle(model, {
		x = tonumber(vehicle.x),
		y = tonumber(vehicle.y),
		z = tonumber(vehicle.z)											
		},tonumber(vehicle.heading), function(callback_vehicle)
			ESX.Game.SetVehicleProperties(callback_vehicle, vehicle.vehicleProps)
			SetVehicleOnGroundProperly(callback_vehicle)
			SetVehicleNeedsToBeHotwired(callback_vehicle, false)

			SetVehicleHasBeenOwnedByPlayer(callback_vehicle, true)
			savevehtofile(callback_vehicle)
		end)
end)

Citizen.CreateThread(function()
	while true do
		TriggerServerEvent('esx_jb_stopvehicledespawn:getvehicletable')
		Citizen.Wait(intervals.check*1000)
	end
end)

-- Citizen.CreateThread(function()
	-- while true do
		 -- if IsControlJustPressed(0, 38) then
			-- local playerPed = GetPlayerPed(-1)
			 -- local coords    = GetEntityCoords(playerPed)
             -- local vehicle   = GetClosestVehicle(coords.x,  coords.y,  coords.z,  3.0,  0,  71)
			 -- print(GetVehicleBodyHealth_2(vehicle))
			 -- print(GetVehicleBodyHealth(vehicle))
			 -- networkid = NetworkGetNetworkIdFromEntity(vehicle)
			  -- print(networkid)
			 -- networkvehicleid = NetworkGetEntityFromNetworkId(networkid)
			 -- print(networkvehicleid)
			 -- DeleteEntity(networkvehicleid)
		 -- end
		 -- Citizen.Wait(0)
	-- end
-- end)

AddEventHandler("playerSpawned", function(spawnInfo)
  if GetNumberOfPlayers() == 1 then
    TriggerServerEvent("esx_jb_stopvehicledespawn:getallvehicles")
  end
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

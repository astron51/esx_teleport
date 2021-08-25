ESX				= nil
local hasAlreadyEnteredMarker	= nil
local CurrentAction		= nil
local CurrentActionMsg		= ''
local CurrentActionData		= {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

-- Diplay Markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local coords 		= GetEntityCoords(PlayerPedId())
		local inCar 		= IsPedInAnyVehicle(PlayerPedId(), false)
		
		if not inCar then
			for k,zoneID in pairs(KalaxConfig.Zones) do
				local isAuthorized 	= Authorized(zoneID)
				if isAuthorized and (zoneID.Type ~= -1 and GetDistanceBetweenCoords(coords, zoneID.PosEnterMarker.x, zoneID.PosEnterMarker.y, zoneID.PosEnterMarker.z, true) < KalaxConfig.DrawDistance) then
					DrawMarker(zoneID.Type, zoneID.PosEnterMarker.x, zoneID.PosEnterMarker.y, zoneID.PosEnterMarker.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, zoneID.Size.x, zoneID.Size.y, zoneID.Size.z, zoneID.Color.r, zoneID.Color.g, zoneID.Color.b, 100, false, true, 2, false, false, false, false)
				end
				if isAuthorized and (zoneID.Type ~= -1 and GetDistanceBetweenCoords(coords, zoneID.PosExitMarker.x, zoneID.PosExitMarker.y, zoneID.PosExitMarker.z, true) < KalaxConfig.DrawDistance) then
					DrawMarker(zoneID.Type, zoneID.PosExitMarker.x, zoneID.PosExitMarker.y, zoneID.PosExitMarker.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, zoneID.Size.x, zoneID.Size.y, zoneID.Size.z, zoneID.Color.r, zoneID.Color.g, zoneID.Color.b, 100, false, true, 2, false, false, false, false)
				end
			end		
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local inCar 			= IsPedInAnyVehicle(PlayerPedId(), false)
		local coords			= GetEntityCoords(PlayerPedId())
		local isInEntryMarker	= false
		local isInExitMarker	= false
		local isInWashMarker	= false
		local currentZone 		= nil
		
		for k,zoneID in pairs(KalaxConfig.Zones) do
			local isAuthorized 	= Authorized(zoneID)
			if isAuthorized and (GetDistanceBetweenCoords(coords, zoneID.PosEnterMarker.x, zoneID.PosEnterMarker.y, zoneID.PosEnterMarker.z, true) < 1.2) then
				isInEntryMarker = true
				currentZone = k
			end
			if isAuthorized and (GetDistanceBetweenCoords(coords, zoneID.PosExitMarker.x, zoneID.PosExitMarker.y, zoneID.PosExitMarker.z, true) < 1.2) then
				isInExitMarker = true
				currentZone = k
			end
		end

		if isInEntryMarker and not hasAlreadyEnteredMarker and not inCar then
			hasAlreadyEnteredMarker = true
			TriggerEvent('esx_teleport:hasEnteredEntryMarker', currentZone)
			LastEntryZone = currentZone
		end
		
		if isInExitMarker and not hasAlreadyEnteredMarker and not inCar then
			hasAlreadyEnteredMarker = true
			TriggerEvent('esx_teleport:hasEnteredExitMarker', currentZone)
		end
		
		if not isInEntryMarker and not isInExitMarker and not isInWashMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('esx_teleport:masterExitMarker', LastZone)
		end
		
		Citizen.Wait(500)
	end
end)

-- Key Control
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if CurrentAction ~= nil then
			ESX.ShowHelpNotification(CurrentActionMsg)
			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'waiting_entry' or CurrentAction == 'waiting_exit' then
					local Heading = 0
					local WhereTo = vector3(0,0,0)
					if CurrentAction == "waiting_entry" then
						for k,zoneID in pairs(KalaxConfig.Zones) do
							if k == CurrentActionData.zone then 
								Heading = zoneID.PositionLand.w
								WhereTo = vector3(zoneID.PositionLand.x ,zoneID.PositionLand.y ,zoneID.PositionLand.z)
							end
						end
					elseif CurrentAction == "waiting_exit" then
						for k,zoneID in pairs(KalaxConfig.Zones) do
							if k == CurrentActionData.zone then 
								Heading = zoneID.PositionExit.w
								WhereTo = vector3(zoneID.PositionExit.x ,zoneID.PositionExit.y ,zoneID.PositionExit.z)
							end
						end
					end
					NetworkFadeOutEntity(PlayerPedId(), false, true)
					DoScreenFadeOut(1000)
					while not IsScreenFadedOut() do
						Citizen.Wait(0)
					end
					RequestCollisionAtCoord(WhereTo.x, WhereTo.y, WhereTo.z)
					NewLoadSceneStart(WhereTo.x, WhereTo.y, WhereTo.z, WhereTo.x, WhereTo.y, WhereTo.z, 100.0, 0);
					ESX.Game.Teleport(PlayerPedId(), WhereTo)
					SetEntityHeading(PlayerPedId(), Heading)
					SetGameplayCamRelativeHeading(0)
					local tempTimer = GetGameTimer()
					while IsNetworkLoadingScene() do
						if GetGameTimer() - tempTimer > 1000 then
							break
						end
						Citizen.Wait(0)
					end
					Citizen.Wait(1000)
					NetworkFadeInEntity(PlayerPedId(), true, true)
					DoScreenFadeIn(1000)
					SetGameplayCamRelativePitch(0.0, 1.0)
				end
				CurrentAction = nil
			end
		else
			Citizen.Wait(500)
		end
	end
end)

-- Get authorized jobs
function Authorized(zoneID)
	if ESX.PlayerData.job == nil then
		return false
	end
	for _,job in pairs(zoneID.Jobs) do
		
		if job == 'any' or job == ESX.PlayerData.job.name then
			return true
		end
	end
	return false
end

-- Enter / Exit Marker Events and money laundry event ( Promp Press E )
AddEventHandler('esx_teleport:hasEnteredEntryMarker', function(zone)
	CurrentAction     = 'waiting_entry'
	CurrentActionMsg  = _U('prompt_Enter')
	CurrentActionData = {zone = zone}
end)

AddEventHandler('esx_teleport:hasEnteredExitMarker', function(zone)
	CurrentAction     = 'waiting_exit'
	CurrentActionMsg  = _U('prompt_Exit')
	CurrentActionData = {zone = zone}
end)

AddEventHandler('esx_teleport:hasEnteredWashArea', function(zone)
	CurrentAction     = 'wash_menu'
	CurrentActionMsg  = _U('press_menu')
	CurrentActionData = {zone = zone}
end)

AddEventHandler('esx_teleport:masterExitMarker', function(zone)
	CurrentAction = nil
	CurrentActionData = nil
	CurrentActionData = {zone = zone}
end)

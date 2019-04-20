ESX               = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		local animal, distance = GetClosestAnimal()
		if distance ~= -1 and distance <= 15 and not IsPedInAnyVehicle(GetPlayerPed(-1)) then
			if IsPedDeadOrDying(animal, 1) then
				DrawText3d(GetEntityCoords(animal), "Appuyez sur E pour dépeçer")
				
				if distance <= 3.0 and IsControlJustPressed(1, 51) then
					-- Start recup
					ESX.TriggerServerCallback('nexthunt:butchering', function(recup)
						if recup == true then
							-- Play anim
							TaskStartScenarioInPlace(GetPlayerPed(-1), "CODE_HUMAN_MEDIC_KNEEL", 0, 1)
							SetTextEntry_2("STRING")
							AddTextComponentString("~g~Vous ramassez de la viande fraiche")
							DrawSubtitleTimed(8000, 1)
							Citizen.Wait(8000)
							ClearPedTasksImmediately(GetPlayerPed(-1))
						end
					end, animal, GetEntityModel(animal))
				end
			end
		end
	end
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		local coords = GetEntityCoords(GetPlayerPed(-1))
		local distance = GetDistanceBetweenCoords(coords, Config.Marker.Pos.x, Config.Marker.Pos.y, Config.Marker.Pos.z, true)

		if distance < Config.Marker.DrawDistance then
			DrawMarker(27, Config.Marker.Pos.x, Config.Marker.Pos.y, Config.Marker.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Marker.Size.x, Config.Marker.Size.y, Config.Marker.Size.z, Config.Marker.Color.r, Config.Marker.Color.g, Config.Marker.Color.b, 100, false, true, 2, false, false, false, false)
		end

		if distance < Config.Marker.Size.x then
			TriggerServerEvent('nexthunt:sell')
			Citizen.Wait(4000)
		end
	end
end)

Citizen.CreateThread(function()
	TriggerEvent('nexthunt:createBlip', 141, "Boucherie", 960.1961,-2105.532,31.9527)

	RequestModel(GetHashKey(Config.Ped.Model))
	while not HasModelLoaded(GetHashKey(Config.Ped.Model)) do
		Wait(1)
	end

	local ped =  CreatePed(4, Config.Ped.ModelHex, Config.Ped.Pos.x, Config.Ped.Pos.y, Config.Ped.Pos.z, Config.Ped.Pos.h, false, true)
	SetEntityHeading(ped, Config.Ped.Pos.h)
	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
	SetBlockingOfNonTemporaryEvents(ped, true)
end)

RegisterNetEvent('nexthunt:deletebody')
AddEventHandler('nexthunt:deletebody', function(animal)
	-- Delete body
	Citizen.InvokeNative(0xAE3CBE5BF394C9C9, Citizen.PointerValueIntInitialized(animal))
end)

RegisterNetEvent("nexthunt:createBlip")
AddEventHandler("nexthunt:createBlip", function(type, text, x, y, z)
	local blip = AddBlipForCoord(x, y, z)
	SetBlipSprite(blip, type)
	SetBlipScale(blip, 0.8)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(text)
	EndTextCommandSetBlipName(blip)
end)

function GetClosestAnimal(coords)
	local peds            = ESX.Game.GetPeds({})
	local closestDistance = -1
	local closestPed      = -1

	if coords == nil then
		coords          = GetEntityCoords(GetPlayerPed(-1))
	end

	for i=1, #peds, 1 do

	if GetPedType(peds[i]) == 28 and Config.Animals[GetEntityModel(peds[i])] ~= nil then
		local pedCoords = GetEntityCoords(peds[i])
		local distance  = GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, coords.x, coords.y, coords.z, true)

		if closestDistance == -1 or closestDistance > distance then
			closestPed      = peds[i]
			closestDistance = distance
		end
	end

	end

	return closestPed, closestDistance
end

function DrawText3d(coords, text)
	local onScreen,_x,_y=World3dToScreen2d(coords.x, coords.y, coords.z)
	local px,py,pz=table.unpack(GetGameplayCamCoords())

	if onScreen then
		SetTextScale(0.2, 0.2)
		SetTextFont(0)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 255)
		SetTextDropshadow(0, 0, 0, 0, 55)
		SetTextEdge(2, 0, 0, 0, 150)
		SetTextDropShadow()
		SetTextOutline()
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x,_y)
	end
end
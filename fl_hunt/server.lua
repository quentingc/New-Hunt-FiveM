ESX                = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local animals = {}

ESX.RegisterServerCallback("nexthunt:butchering", function(source, cb, animal, animalhash)
	local _source 		= source
	
	if animals[animal] == nil then
		animals[animal] = true
		cb(true)
		TriggerClientEvent('esx:showNotification', _source, 'Récupération de ~b~viande~s~...')
		SetTimeout(4000, function()
			local xPlayer  = ESX.GetPlayerFromId(source)

			xPlayer.addInventoryItem('viande', Config.Animals[animalhash])
			TriggerClientEvent('nexthunt:deletebody', -1, animal)
			animals[animal] = nil
		end)
	else
		cb(false)
		TriggerClientEvent('esx:showNotification', source, '~r~Cet animal se fait déjà dépeçer')
	end
end)

RegisterServerEvent('nexthunt:sell')
AddEventHandler('nexthunt:sell', function()
	local _source = source
	TriggerClientEvent('esx:showNotification', _source, 'Vente de ~b~viande~s~...')
	sell(_source)
end)

function sell(source) 
	SetTimeout(2000, function()
		local xPlayer  = ESX.GetPlayerFromId(source)
		local ViandeQuantity = xPlayer.getInventoryItem('viande').count

		if ViandeQuantity <= 0 then
			TriggerClientEvent('esx:showNotification', source, 'Vous n\'avez ~r~pas assez~s~ de viande')			
		else   
			xPlayer.removeInventoryItem('viande', 1)
			xPlayer.addMoney(Config.SellPrice)
			
			sell(source)
		end
	end)
end
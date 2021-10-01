QBCore = nil
local ResetStress = false

-- Events

RegisterServerEvent("hud:Server:UpdateStress")
AddEventHandler('hud:Server:UpdateStress', function(StressGain)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local newStress
    if Player ~= nil then
        if not ResetStress then
            if Player.PlayerData.metadata["stress"] == nil then
                Player.PlayerData.metadata["stress"] = 0
            end
            newStress = Player.PlayerData.metadata["stress"] + StressGain
            if newStress <= 0 then newStress = 0 end
        else
            newStress = 0
        end
        if newStress > 100 then
            newStress = 100
        end
        Player.Functions.SetMetaData("stress", newStress)
		TriggerClientEvent("hud:client:update:stress", src, newStress)
	end
end)

RegisterServerEvent('hud:server:gain:stress')
AddEventHandler('hud:server:gain:stress', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local newStress
    if Player ~= nil then
        if not ResetStress then
            if Player.PlayerData.metadata["stress"] == nil then
                Player.PlayerData.metadata["stress"] = 0
            end
            newStress = Player.PlayerData.metadata["stress"] + amount
            if newStress <= 0 then newStress = 0 end
        else
            newStress = 0
        end
        if newStress > 100 then
            newStress = 100
        end
        Player.Functions.SetMetaData("stress", newStress)
        TriggerClientEvent("hud:client:update:stress", src, newStress)
        TriggerClientEvent('QBCore:Notify', src, 'Gained stress', 'error', 1500)
	end
end)

RegisterServerEvent('hud:server:RelieveStress')
AddEventHandler('hud:server:RelieveStress', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local newStress
    if Player ~= nil then
        if not ResetStress then
            if Player.PlayerData.metadata["stress"] == nil then
                Player.PlayerData.metadata["stress"] = 0
            end
            newStress = Player.PlayerData.metadata["stress"] - amount
            if newStress <= 0 then newStress = 0 end
        else
            newStress = 0
        end
        if newStress > 100 then
            newStress = 100
        end
        Player.Functions.SetMetaData("stress", newStress)
        TriggerClientEvent("hud:client:update:stress", src, newStress)
        TriggerClientEvent('QBCore:Notify', src, 'Stress relieved')
	end
end)

RegisterServerEvent('hud:server:remove:stress')
AddEventHandler('hud:server:remove:stress', function(Amount)
    local Player = QBCore.Functions.GetPlayer(source)
    local NewStress = nil
    if Player ~= nil then
      NewStress = Player.PlayerData.metadata["stress"] - Amount
      if NewStress <= 0 then NewStress = 0 end
      if NewStress > 105 then NewStress = 100 end
      Player.Functions.SetMetaData("stress", NewStress)
      TriggerClientEvent("hud:client:update:stress", Player.PlayerData.source, NewStress)
    end
end)

TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

-- In-game Commands

QBCore.Commands.Add("cash", "Check cash", {}, false, function(source, args)
	TriggerClientEvent('hud:client:ShowMoney', source, "cash")
end)
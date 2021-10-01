QBCore = nil
local toggleHud = true
local cashAmount = 0
local bankAmount = 0
local StressGain = 0
local IsGaining = false
local speed = 0.0
local seatbeltOn = false
local cruiseOn = false
local bleedingPercentage = 0
local hunger = 100
local thirst = 100
local level = 100
local radarActive = false
local LastHeading = nil
local Rotating = "left"
isLoggedIn = true
stress = 0
PlayerJob = {}

-- Events

RegisterNetEvent("QBCore:Client:OnPlayerUnload")
AddEventHandler("QBCore:Client:OnPlayerUnload", function()
    isLoggedIn = false
    Config.Show = false
    SendNUIMessage({
        action = "hudtick",
        show = true,
    })
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    isLoggedIn = true
    Config.Show = true
    --showRoundMap()
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('hud:toggleHud')
AddEventHandler('hud:toggleHud', function(toggleHud)
    Config.Show = toggleHud
end)

RegisterNetEvent("hud:client:UpdateNeeds")
AddEventHandler("hud:client:UpdateNeeds", function(newHunger, newThirst)
    hunger = newHunger
    thirst = newThirst
end)

RegisterNetEvent('hud:client:UpdateStress')
AddEventHandler('hud:client:UpdateStress', function(newStress)
    stress = newStress
end)

RegisterNetEvent("hud:client:EngineHealth")
AddEventHandler("hud:client:EngineHealth", function(newEngine)
    engine = newEngine
end)

RegisterNetEvent("seatbelt:client:ToggleSeatbelt")
AddEventHandler("seatbelt:client:ToggleSeatbelt", function(toggle)
    if toggle == nil then
        seatbeltOn = not seatbeltOn
        SendNUIMessage({
            action = "seatbelt",
            seatbelt = seatbeltOn,
        })
    else
        seatbeltOn = toggle
        SendNUIMessage({
            action = "seatbelt",
            seatbelt = toggle,
        })
    end
end)

RegisterNetEvent('hud:client:ToggleHarness')
AddEventHandler('hud:client:ToggleHarness', function(toggle)
    SendNUIMessage({
        action = "harness",
        toggle = toggle
    })
end)

RegisterNetEvent('hud:client:UpdateNitrous')
AddEventHandler('hud:client:UpdateNitrous', function(toggle, level, IsActive)
    on = toggle
    nivel = level
    activo = IsActive
end)



RegisterNetEvent("hud:client:ShowMoney")
AddEventHandler("hud:client:ShowMoney", function(type)
    QBCore.Functions.GetPlayerData(function(PlayerData)
        CashAmount = PlayerData.money["cash"]
    end)
    TriggerEvent("hud:client:SetMoney")
    SendNUIMessage({
        action = "show",
        cash = cashAmount,
        bank = bankAmount,
        type = type,
    })
end)

RegisterNetEvent("qb-hud:client:money:change")
AddEventHandler("qb-hud:client:money:change", function(type, amount, isMinus)
    QBCore.Functions.GetPlayerData(function(PlayerData)
        CashAmount = PlayerData.money["cash"]
    end)
     SendNUIMessage({
         action = "update",
         cash = CashAmount,
         amount = amount,
         minus = isMinus,
         type = type,
     })
end)


RegisterNetEvent("hud:client:SetMoney")
AddEventHandler("hud:client:SetMoney", function()
   QBCore.Functions.GetPlayerData(function(PlayerData)
       if PlayerData ~= nil and PlayerData.money ~= nil then
           cashAmount = PlayerData.money["cash"]
           bankAmount = PlayerData.money["bank"]
       end
   end)
   if Config.Money.ShowConstant then
       SendNUIMessage({
           action = "open",
           cash = cashAmount,
           bank = bankAmount,
       })
   end
end)

RegisterNetEvent("hud:client:ShowMoney")
AddEventHandler("hud:client:ShowMoney", function(type)
   TriggerEvent("hud:client:SetMoney")
   SendNUIMessage({
       action = "show",
       cash = cashAmount,
       bank = bankAmount,
       type = type,
   })
end)

RegisterNetEvent("hud:client:OnMoneyChange")
AddEventHandler("hud:client:OnMoneyChange", function(type, amount, isMinus)
   QBCore.Functions.GetPlayerData(function(PlayerData)
       cashAmount = PlayerData.money["cash"]
       bankAmount = PlayerData.money["bank"]
   end)
   
   if Config.Money.ShowConstant then
       SendNUIMessage({
           action = "open",
           cash = cashAmount,
           bank = bankAmount,
       })
   else
       SendNUIMessage({
           action = "update",
           cash = cashAmount,
           bank = bankAmount,
           amount = amount,
           minus = isMinus,
           type = type,
       })
   end
end)

-- Money HUD

Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(200)
        if QBCore == nil then
            TriggerEvent("QBCore:getObject", function(obj) QBCore = obj end)    
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if QBCore == nil then
            TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj end)    
            Citizen.Wait(200)
        end
        if QBCore ~= nil then
            TriggerEvent("hud:client:SetMoney")
            return
        end
    end
end)

-- Player HUD

function CalculateTimeToDisplay() -- Don't Touch This
    hour = GetClockHours()
    minute = GetClockMinutes()
    local obj = {}
	if minute <= 9 then
		minute = "0" .. minute
    end
	if hour <= 9 then
		hour = "0" .. hour
    end
    obj.hour = hour
    obj.minute = minute
    return obj
end

Citizen.CreateThread(function()
    Citizen.Wait(500)
    while true do 
        if QBCore ~= nil and isLoggedIn and Config.Show then
            QBCore.Functions.GetPlayerData(function(PlayerData)
                if PlayerData ~= nil and PlayerData.money ~= nil then
                    CashAmount = PlayerData.money["cash"]
                    hunger, thirst, stress = PlayerData.metadata["hunger"], PlayerData.metadata["thirst"], PlayerData.metadata["stress"]
                end
        end)
            speed = GetEntitySpeed(GetVehiclePedIsIn(PlayerPedId(), false)) * 2.236936
            local Plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId()))
            local pos = GetEntityCoords(PlayerPedId())
            local time = CalculateTimeToDisplay()
            local speaking = NetworkIsPlayerTalking(PlayerId())
            local street1, street2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
            local current_zone = GetLabelText(GetNameOfZone(pos.x, pos.y, pos.z))
            local fuel = exports['LegacyFuel']:GetFuel(GetVehiclePedIsIn(PlayerPedId()))
            local engine = (GetVehicleEngineHealth(GetVehiclePedIsIn(PlayerPedId()))/10)
            local level = LocalPlayer.state["proximity"].distance
            if level == 1 then talking = 33
            elseif level == 2.3 then talking = 66
            elseif level == 5.0 then talking = 100 end
            if hunger < 0 then hunger = 0 end
            if thirst < 0 then thirst = 0 end
            if stress < 0 then stress = 0 end

            SendNUIMessage({
                action = "hudtick",
                show = IsPauseMenuActive(),
                health = GetEntityHealth(PlayerPedId()),
                armor = GetPedArmour(PlayerPedId()),
                thirst = thirst,
                hunger = hunger,
                engine = engine,
                stress = stress,
                seatbelt = seatbeltOn,
                speaking = speaking,
                talking = talking,

                street1 = GetStreetNameFromHashKey(street1),
                street2 = GetStreetNameFromHashKey(street2),
                area_zone = current_zone,
                speed = math.ceil(speed),
                fuel = fuel,
                on = on,
                nivel = nivel,
                activo = activo,
                time = time,
                togglehud = toggleHud
            })
            Citizen.Wait(500)
        else
            Citizen.Wait(1000)
        end
    end
end)

Citizen.CreateThread(function() -- Stress 
    while true do
        local ped = PlayerPedId()
        if IsPedShooting(PlayerPedId()) then
            local StressChance = math.random(1, 3)
            local odd = math.random(1, 3)
            if StressChance == odd then
                local PlusStress = math.random(2, 4) / 100
                StressGain = StressGain + PlusStress
            end
            if not IsGaining then
                IsGaining = true
            end
        else
            if IsGaining then
                IsGaining = false
            end
        end

        if (PlayerJob.name ~= "police") then
            if IsPlayerFreeAiming(PlayerId()) and not IsPedShooting(PlayerPedId()) then
                local CurrentWeapon = GetSelectedPedWeapon(ped)
                local WeaponData = QBCore.Shared.Weapons[CurrentWeapon]
                if WeaponData.name:upper() ~= "WEAPON_UNARMED" then
                    local StressChance = math.random(1, 20)
                    local odd = math.random(1, 20)
                    if StressChance == odd then
                        local PlusStress = math.random(1, 3) / 100
                        StressGain = StressGain + PlusStress
                    end
                end
                if not IsGaining then
                    IsGaining = true
                end
            else
                if IsGaining then
                    IsGaining = false
                end
            end
        end
            Citizen.Wait(2)
    end
end)

function GetShakeIntensity(stresslevel)
    local retval = 0.05
    for k, v in pairs(Config.Intensity["shake"]) do
        if stresslevel >= v.min and stresslevel < v.max then
            retval = v.intensity
            break
        end
    end
        return retval
end

function GetEffectInterval(stresslevel)
    local retval = 23000
    for k, v in pairs(Config.EffectInterval) do
        if stresslevel >= v.min and stresslevel < v.max then
            retval = v.timeout
            break
        end
    end
        return retval
end

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local Wait = GetEffectInterval(stress)
        if stress >= 100 then
            local ShakeIntensity = GetShakeIntensity(stress)
            local FallRepeat = math.random(2, 4)
            local RagdollTimeout = (FallRepeat * 1750)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
            SetFlash(0, 0, 500, 3000, 500)
            if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
                local player = PlayerPedId()
                SetPedToRagdollWithFall(player, RagdollTimeout, RagdollTimeout, 1, GetEntityForwardVector(player), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            end
                Citizen.Wait(500)
            for i = 1, FallRepeat, 1 do
                Citizen.Wait(750)
                DoScreenFadeOut(200)
                Citizen.Wait(1000)
                DoScreenFadeIn(200)
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
                SetFlash(0, 0, 200, 750, 200)
        end
        elseif stress >= Config.MinimumStress then
            local ShakeIntensity = GetShakeIntensity(stress)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
            SetFlash(0, 0, 500, 2500, 500)
        end
            Citizen.Wait(Wait)
    end
end)

Citizen.CreateThread(function() -- Stress
    while true do
        if not IsGaining then
            StressGain = math.ceil(StressGain)
            if StressGain > 0 then
                QBCore.Functions.Notify('You are feeling stressed', "primary", 2000)
                TriggerServerEvent('hud:Server:UpdateStress', StressGain)
                StressGain = 0
            end
        end
            Citizen.Wait(3000)
    end
end)

-- Vehicle HUD

Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(1000)
        if IsPedInAnyVehicle(PlayerPedId()) and isLoggedIn and Config.Show then
            DisplayRadar(true)
            SendNUIMessage({
                action = "car",
                show = true,
            })
            radarActive = true
        else
            DisplayRadar(false)
            SendNUIMessage({
                action = "car",
                show = false,
            })
            seatbeltOn = false
            cruiseOn = false

            SendNUIMessage({
                action = "seatbelt",
                seatbelt = seatbeltOn,
            })

            SendNUIMessage({
                action = "cruise",
                cruise = cruiseOn,
            })
            radarActive = false
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if QBCore ~= nil and isLoggedIn and Config.Show then

            -- Low Fuel Alert

            if IsPedInAnyVehicle(PlayerPedId(), false) then
                while exports['LegacyFuel']:GetFuel(GetVehiclePedIsIn(PlayerPedId())) <= 20 do -- At 20% Fuel Left
                    TriggerServerEvent("InteractSound_SV:PlayOnSource", "pager", 0.10)
                    QBCore.Functions.Notify('Low Fuel!', "error")
                    Wait(60000) -- Displays Every 1 Minute
                end
                speed = GetEntitySpeed(GetVehiclePedIsIn(PlayerPedId(), false)) * 2.236936
                if speed >= Config.MinimumSpeed then
                    TriggerServerEvent('hud:server:gain:stress', math.random(1, 2))
                end
            end
        end
            Citizen.Wait(20000)
    end
end)

RegisterCommand("neon", function() -- In-game Command to Toggle Neon Lights on Vehicle
    local veh = GetVehiclePedIsIn(PlayerPedId())
    if veh ~= nil and veh ~= 0 and veh ~= 1 then
        if IsVehicleNeonLightEnabled(veh) then
            SetVehicleNeonLightEnabled(veh, 0, false)
            SetVehicleNeonLightEnabled(veh, 1, false)
            SetVehicleNeonLightEnabled(veh, 2, false)
            SetVehicleNeonLightEnabled(veh, 3, false)
        else
            SetVehicleNeonLightEnabled(veh, 0, true)
            SetVehicleNeonLightEnabled(veh, 1, true)
            SetVehicleNeonLightEnabled(veh, 2, true)
            SetVehicleNeonLightEnabled(veh, 3, true)
        end
    end
end, false)

-- Navigation Compass 

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num + 0.5 * mult)
end

Citizen.CreateThread( function()
	local heading, lastHeading = 0, 1

	while Config.compass.show do
		Citizen.Wait(0)

		if Config.compass.followGameplayCam then
			-- Converts [-180, 180] to [0, 360] where E = 90 and W = 270
			local camRot = GetGameplayCamRot(0)
			heading = tostring(round(360.0 - ((camRot.z + 360.0) % 360.0)))
		else
			-- Converts E = 270 to E = 90
			heading = tostring(round(360.0 - GetEntityHeading(PlayerPedId())))
		end
		if heading == '360' then heading = '0' end
		if heading ~= lastHeading then
			if IsPedInAnyVehicle(PlayerPedId()) then
				SendNUIMessage({ action = "display", value = heading })
			else
				SendNUIMessage({ action = "hide", value = heading })
			end
			
		end
		lastHeading = heading
	end
end)

Citizen.CreateThread( function()
	local lastStreetA = 0
	local lastStreetB = 0

	while Config.streetName.show do
		Citizen.Wait(0)

		local playerPos = GetEntityCoords(PlayerPedId(), true)
		local streetA, streetB = GetStreetNameAtCoord(playerPos.x, playerPos.y, playerPos.z)
		street = {}

		if not ((streetA == lastStreetA or streetA == lastStreetB) and (streetB == lastStreetA or streetB == lastStreetB)) then
			lastStreetA = streetA
			lastStreetB = streetB
		end

		if lastStreetA ~= 0 then
			table.insert(street, GetStreetNameFromHashKey(lastStreetA))
		end

		if lastStreetB ~= 0 then
			table.insert(street, GetStreetNameFromHashKey(lastStreetB))
		end

		street = table.concat(street, " & ")

		if street ~= laststreet then
			if IsPedInAnyVehicle(PlayerPedId()) then
				SendNUIMessage({action = "display", type = street})
			else
				SendNUIMessage({action = "hide", type = street})
			end
			
			Citizen.Wait(50)
		end
		laststreet = street
		Citizen.Wait(100)
	end
end)

-- Raise Circular Map

if Config.EnableCircleMap then
    Citizen.CreateThread(function()
        RequestStreamedTextureDict("circlemap", false)
        while not HasStreamedTextureDictLoaded("circlemap") do
            Wait(0)
        end
    
        AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "circlemap", "radarmasksm")
        AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "circlemap", "radarmasksm")
    
        SetMinimapClipType(1)
        SetMinimapComponentPosition("minimap", "L", "B", -0.0180, -0.030, 0.180, 0.258)
        SetMinimapComponentPosition("minimap_mask", "L", "B", 0.2, 0.0, 0.065, 0.20)
        SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.01, 0.021, 0.252, 0.338)
    
        SetMinimapClipType(1)
        DisplayRadar(0)
        SetRadarBigmapEnabled(true, false)
        Citizen.Wait(0)
        SetRadarBigmapEnabled(false, false)
        DisplayRadar(1)
    end) 

    local pauseActive = false
Citizen.CreateThread(function()
    while true do
        HideMinimapInteriorMapThisFrame()
        SetRadarZoom(1000)
        Citizen.Wait(0)
    end
end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(50)
            local player = PlayerPedId()
            SetRadarZoom(1000)
            SetRadarBigmapEnabled(false, false)
            local isPMA = IsPauseMenuActive()
            if isPMA and not pauseActive or IsRadarHidden() then 
                pauseActive = true 
                SendNUIMessage({
                    action = "hideCircleUI"
                })
                uiHidden = true
            elseif not isPMA and pauseActive then
                pauseActive = false
                SendNUIMessage({
                    action = "displayCircleUI"
                })
                uiHidden = false
            end
                Citizen.Wait(0)
        end
    end)

else     

-- Raise Square Map

Citizen.CreateThread(function()
	RequestStreamedTextureDict("squaremap", false)
	while not HasStreamedTextureDictLoaded("squaremap") do
		Wait(0)
	end

    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "squaremap", "radarmasksm")
    AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "squaremap", "radarmasksm")

	SetMinimapClipType(0)
    SetMinimapComponentPosition("minimap", "L", "B", 0.0, -0.047, 0.1638, 0.236)
    SetMinimapComponentPosition("minimap_mask", "L", "B", 0.2, 0.0, 0.065, 0.20)
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.01, 0.025, 0.262, 0.351)

    SetMinimapClipType(0)
    DisplayRadar(0)
    SetRadarBigmapEnabled(true, false)
    Citizen.Wait(0)
    SetRadarBigmapEnabled(false, false)
    DisplayRadar(1)
end)

local pauseActive = false
Citizen.CreateThread(function()
    while true do
        HideMinimapInteriorMapThisFrame()
        SetRadarZoom(1000)
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(50)
        local player = PlayerPedId()
        SetRadarZoom(1000)
        SetRadarBigmapEnabled(false, false)
        local isPMA = IsPauseMenuActive()
        if isPMA and not pauseActive or IsRadarHidden() then 
            pauseActive = true 
            SendNUIMessage({
                action = "hideSquareUI"
            })
            uiHidden = true
        elseif not isPMA and pauseActive then
            pauseActive = false
            SendNUIMessage({
                action = "displaySquareUI"
            })
            uiHidden = false
        end
            Citizen.Wait(0)
        end
    end)
end

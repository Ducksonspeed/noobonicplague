local function HMPlayerSpawn(ply)
	ply:setSelfDarkRPVar("Energy", 100)
end
hook.Add("PlayerSpawn", "HMPlayerSpawn", HMPlayerSpawn)

local function HMThink()
	if not GAMEMODE.Config.hungerspeed then return end
	local hungerRate = SVNOOB_VARS:Get( "HungerDecreaseRate", true, "number", 10 )
	local zombieHungerRate = SVNOOB_VARS:Get( "ZombieHungerDecreaseRate", true, "number", 1 )
	for k, v in pairs(player.GetAll()) do
		if ( v:Team( ) == TEAM_ZOMBIE ) then
			if (v:Alive()) and (not v.LastHungerUpdate or CurTime() - v.LastHungerUpdate > zombieHungerRate ) then
				if ( v:IsGhost( ) or v:GetObserverMode( ) ~= OBS_MODE_NONE or v:IsFrozen( ) ) then continue end
				v:hungerUpdate()
			end
		else
			if v:Alive() and (not v.LastHungerUpdate or CurTime() - v.LastHungerUpdate > hungerRate ) then
				if ( v:IsGhost( ) or v:GetObserverMode( ) ~= OBS_MODE_NONE or v:IsFrozen( ) ) then continue end
				v:hungerUpdate()
			end
		end
	end
end
hook.Add("Think", "HMThink", HMThink)

local function HMPlayerInitialSpawn(ply)
	ply:newHungerData()
end
hook.Add("PlayerInitialSpawn", "HMPlayerInitialSpawn", HMPlayerInitialSpawn)

for k, v in pairs(player.GetAll()) do
	v:newHungerData()
end

local function BuyFood(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	for _,v in pairs(FoodItems) do
		if string.lower(args) ~= string.lower(v.name) then continue end

		if (v.requiresCook == nil or v.requiresCook == true) and
		(not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].cook) then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buyfood", DarkRP.getPhrase("cooks_only")))
			return ""
		end

		if v.customCheck and not v.customCheck(ply) then
			if v.customCheckMessage then
				DarkRP.notify(ply, 1, 4, v.customCheckMessage)
			end
			return ""
		end

		local cost = v.price

		if not ply:canAfford(cost) then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", string.lower(DarkRP.getPhrase("food"))))
			return ""
		end

		if ( util.CheckCustomEntLimit( "spawned_food", ply, "SpawnedFoodLimit", "Spawned Food" ) ) then 
			return ""
		end

		ply:addMoney(-cost)
		DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought", v.name, DarkRP.formatMoney(cost), ""))

		local SpawnedFood = ents.Create("spawned_food")
		SpawnedFood:Setowning_ent(ply)
		SpawnedFood.ShareGravgun = true
		SpawnedFood:SetPos(tr.HitPos)
		SpawnedFood.onlyremover = true
		SpawnedFood.SID = ply.SID
		SpawnedFood:SetModel(v.model)
		SpawnedFood.FoodName = v.name
		SpawnedFood.FoodEnergy = v.energy
		SpawnedFood.FoodPrice = v.price
		SpawnedFood:Spawn()
		return ""
	end
	DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
	return ""
end
DarkRP.defineChatCommand("buyfood", BuyFood)

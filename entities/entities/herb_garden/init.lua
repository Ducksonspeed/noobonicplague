AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
util.AddNetworkString( "N00BRP_HerbGarden_NET" )
local plantFuncTable = plantFuncTable or { }

function ENT:Initialize()
	plantFuncTable[1] = { getStage = self.GetPlantOneStage, setStage = self.SetPlantOneStage }
	plantFuncTable[2] = { getStage = self.GetPlantTwoStage, setStage = self.SetPlantTwoStage }
	plantFuncTable[3] = { getStage = self.GetPlantThreeStage, setStage = self.SetPlantThreeStage }
	plantFuncTable[4] = { getStage = self.GetPlantFourStage, setStage = self.SetPlantFourStage }
	self:SetModel( "models/props/de_tides/planter.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.ghostCollisionGroupOverride = COLLISION_GROUP_WEAPON
	self.unGhostCollisionGroupOverride = COLLISION_GROUP_WEAPON
	local phys = self:GetPhysicsObject()
	phys:Wake( )
	self:SetPlantOneStage( 0 )
	self:SetPlantTwoStage( 0 )
	self:SetPlantThreeStage( 0 )
	self:SetPlantFourStage( 0 )
	self:SetPlantsHydration( "100;100;100;100" )
	self:PlantGrowth( )
	self.currentHealth = 100
end

function ENT:OnTakeDamage( dmgInfo )
	if ( self.currentHealth <= 0 ) then
		self:Destruct( )
	else
		self.currentHealth = self.currentHealth - dmgInfo:GetDamage( )
	end
end

function ENT:Destruct( )
	local effectData = EffectData( )
	effectData:SetStart( self:GetPos( ) )
	effectData:SetOrigin( self:GetPos( ) )
	effectData:SetScale( 1 )
	util.Effect( "Explosion", effectData )
	SafeRemoveEntity( self )
end

function ENT:PlantGrowth( )
	timer.Simple( math.random( 30, 120 ), function( )
		if not ( IsValid( self ) ) then return end
		local rndPlant = math.random( 1, 4 )
		local curGrowth = plantFuncTable[rndPlant].getStage( self )
		if ( curGrowth ~= 0 ) then
			local hydrationTable = string.Explode( ";", self:GetPlantsHydration( ) )
			local dehydrateAmount = math.random( 10, 40 )
			hydrationTable[rndPlant] = math.Clamp( tonumber( hydrationTable[rndPlant] ) - dehydrateAmount, 0, 100 )
			self:SetPlantsHydration( string.Implode( ";", hydrationTable ) )
			if ( tonumber( hydrationTable[rndPlant] ) == 0 ) then
				local newStage = math.Clamp( plantFuncTable[rndPlant].getStage( self ) - 1, 0, 4 )
				plantFuncTable[rndPlant].setStage( self, newStage )
				if ( newStage == 0 ) then 
					hydrationTable[rndPlant] = 100
					self:SetPlantsHydration( string.Implode( ";", hydrationTable ) )
				end
			else
				if ( curGrowth < 4 and curGrowth ~= 0 ) then
					plantFuncTable[rndPlant].setStage( self, curGrowth + 1 )
				end
			end
		end
		self:PlantGrowth( )
	end )
end

function ENT:Use( activator, caller )
	if not ( activator:IsEntityUseOnCooldown( self:EntIndex( ) ) ) then
		activator:SetEntityUseCooldown( self:EntIndex( ), 1 )
		net.Start( "N00BRP_HerbGarden_NET" )
			net.WriteUInt( self.OPEN_MENU, 8 )
			net.WriteEntity( self )
		net.Send( activator )
	end
end

local function ReceiveHerbGardenNET( len, ply )
	local messType = net.ReadUInt( 8 )
	local gardenEnt = net.ReadEntity( )
	local herbIndex = net.ReadUInt( 8 )
	if ( !IsValid( gardenEnt ) or gardenEnt:GetClass( ) ~= "herb_garden" ) then return end
	if not ( ply:GetPos( ):FastDist( gardenEnt:GetPos( ) ) < 512 ) then return end
	if ( herbIndex > 4 or herbIndex < 1 ) then return end
	local herbHydrationTable = string.Explode( ";", gardenEnt:GetPlantsHydration( ) )
	if ( messType == gardenEnt.HARVEST_HERB ) then
		if ( plantFuncTable[herbIndex].getStage( gardenEnt ) == 4 ) then
			local herbReward = "Burdock Root"
			local rndRoll = math.random( 1, 100 )
			if ( rndRoll > 0 and rndRoll < 60 ) then
				herbReward = "Burdock Root"
			elseif ( rndRoll >= 60 and rndRoll <= 99 ) then
				herbReward = "Gingko Biloba"
			else
				herbReward = "Valerian Root"
			end
			local rndAmount = math.random( 2, 6 )
			DarkRP.notify( ply, NOTIFY_HINT, 4, "You've harvested the herb, you gathered " .. rndAmount .. " units of " .. herbReward .. "!" )
			plantFuncTable[herbIndex].setStage( gardenEnt, 0 )
			herbHydrationTable[herbIndex] = 100
			gardenEnt:SetPlantsHydration( string.Implode( ";", herbHydrationTable ) )
			ply:GiveHerb( herbReward, rndAmount )
			ply:RewardXP( math.random( 1, 3 ), NOOB_SKILL_HERBALISM, "HerbalismXP", "Herbalism", true )
		else
			DarkRP.notify( ply, NOTIFY_ERROR, 4, "That herb isn't fully grown yet." )
		end
	elseif ( messType == gardenEnt.PLANT_HERB ) then
		if ( plantFuncTable[herbIndex].getStage( gardenEnt ) == 0 ) then
			if ( ply:canAfford( gardenEnt.PlantHerbCost ) ) then
				ply:addMoney( -gardenEnt.PlantHerbCost )
				DarkRP.notify( ply, NOTIFY_HINT, 4, "You've planted a herb for $" .. string.Comma( gardenEnt.PlantHerbCost ) .. "!" )
				plantFuncTable[herbIndex].setStage( gardenEnt, 1 )
			else
				DarkRP.notify( ply, NOTIFY_ERROR, 4, "You cannot afford to plant that herb." )
			end
		else
			DarkRP.notify( ply, NOTIFY_ERROR, 4, "There's already a herb planted there." )
		end
	elseif ( messType == gardenEnt.WATER_HERB ) then
		if ( tonumber( herbHydrationTable[herbIndex] ) ~= 100 ) then
			local waterCost = ( 100 - tonumber( herbHydrationTable[herbIndex] ) ) * gardenEnt.WaterCostMultiplier
			if ( ply:canAfford( waterCost ) ) then
				ply:addMoney( -waterCost )
				DarkRP.notify( ply, NOTIFY_HINT, 4, "You've watered a herb for $" .. string.Comma( waterCost ) .. "!" )
				herbHydrationTable[herbIndex] = 100
				gardenEnt:SetPlantsHydration( string.Implode( ";", herbHydrationTable ) )
			else
				DarkRP.notify( ply, NOTIFY_ERROR, 4, "You cannot afford to water that herb." )
			end
		else
			DarkRP.notify( ply, NOTIFY_ERROR, 4, "That herb is already hydrated." )
		end
	end
end
net.Receive( "N00BRP_HerbGarden_NET", ReceiveHerbGardenNET )
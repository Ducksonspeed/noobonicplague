AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel( "models/props/de_inferno/largebush0" .. math.random( 1, 6 ) .. ".mdl" ) 
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
	self:SetAngles( Angle( 0, math.random( 0, 360 ), 0 ) )
	local randScale = math.Rand( 0.5, 1 )
	self:SetModelScale( randScale, 0 )
	timer.Simple( 0.5, function( )
		if not ( IsValid ( self ) ) then return end
		self:MoveToGround( )
	end )
	local phys = self:GetPhysicsObject()
	local herbGatherTime = math.random( 5, 10 )
	local herbGatherTimeTable = SVNOOB_VARS:Get( "HerbGatherTime" ) or nil
	if ( istable( herbGatherTimeTable ) ) then
		if ( tonumber( herbGatherTimeTable.min ) and tonumber( herbGatherTimeTable.max ) ) then
			herbGatherTime = math.random( herbGatherTimeTable.min, herbGatherTimeTable.max )
		end
	end
	self.randomHarvestLength = herbGatherTime
	phys:Wake()
	phys:EnableMotion( false )
	local despawnData = tonumber( SVNOOB_VARS:Get( "HerbDespawnTimer" ) ) or { min = 180, max = 300 }
	local despawnTimer = math.random( despawnData.min, despawnData.max )
	timer.Simple( despawnTimer, function( )
		if not ( IsValid( self ) ) then return end
		SafeRemoveEntity( self )
	end )
end

function ENT:MoveToGround( )
	local traceRes = util.TraceLine( { start = self:GetPos( ), endpos = self:GetPos( ) - Vector( 0, 0, 360 ), filter = self } )
	if ( traceRes.HitWorld ) then
		self:SetPos( traceRes.HitPos )
	end
end

function ENT:Use(activator,caller)
	if not ( IsValid( self:GetUsingEnt( ) ) ) then
		local herbData = NOOBRP_SkillAlgorithms:CalculateHerbalism( activator )
		local herbLevel = herbData["CurrentLevel"]
		local harvestTimeDrain = herbLevel / 6
		local herbalistTimeDec = tonumber( SVNOOB_VARS:Get( "HerbalistTimeDecrement") ) or 2
		local minGatherTime = tonumber( SVNOOB_VARS:Get( "HerbMinGatherTime" ) ) or 1
		if ( activator:Team( ) == TEAM_HERBALIST ) then 
			harvestTimeDrain = harvestTimeDrain + herbalistTimeDec
		end
		activator.lastUsedHerbFinishTime = CurTime( ) + self:GetHarvestLength( )
		self.harvestProgress = 0
		self:SetUsingEnt( activator )
		self:SetHarvestLength( math.Clamp( self.randomHarvestLength - harvestTimeDrain , minGatherTime, 600 ) )
		self:SetFinishTime( CurTime( ) + self:GetHarvestLength( ) )
		timer.Create( self:EntIndex( ) .. ":BeingHarvested", 1, self:GetHarvestLength( ), function( )
			if not ( IsValid( self ) ) then return end
			if not ( IsValid( self:GetUsingEnt( ) ) ) then
				self:CancelHarvesting( )
				return
			end
			if ( !IsValid( self:GetUsingEnt( ):RangeEyeTrace( 160 ).Entity ) or self:GetUsingEnt( ):RangeEyeTrace( 160 ).Entity ~= self ) then
				self:CancelHarvesting( )
				return
			end
			self.harvestProgress = self.harvestProgress + 1
			if ( self.harvestProgress == self:GetHarvestLength( ) ) then
				self:SucceedHarvesting( self:GetUsingEnt( ) )
				self:CancelHarvesting( )
				SafeRemoveEntity( self )
			end
		end )
	end
end

function ENT:SucceedHarvesting( ply )
	local herbData = NOOBRP_SkillAlgorithms:CalculateHerbalism( ply )
	local herbLevel = herbData["CurrentLevel"]
	local bonusHerbRoll = math.random( 1, 100 )
	local extraHerbs = 0
	if ( bonusHerbRoll < herbLevel ) then
		extraHerbs = math.random( 2, 3 )
	end
	local herbChances = {
		[1] = { name = "Burdock Root", chance = 65 },
		[2] = { name = "Gingko Biloba", chance = 25 },
		[3] = { name = "Valerian Root", chance = 2 }
	}
	local rndRoll = math.Rand( 0, 100 )
	if ( ply:Team( ) == TEAM_HERBALIST ) then
		rndRoll = math.Rand( 0, 75 )
	end
	local herbType = nil
	local xp = 0
	if ( rndRoll < herbChances[1].chance and rndRoll > herbChances[2].chance ) then
		herbType = "Burdock Root"
		xp = 2 * ( math.Clamp( extraHerbs, 1, 3 ) )
	elseif ( rndRoll < herbChances[2].chance and rndRoll > herbChances[3].chance ) then
		herbType = "Gingko Biloba"
		xp = 4 * ( math.Clamp( extraHerbs, 1, 3 ) )
	elseif ( rndRoll < herbChances[3].chance ) then
		herbType = "Valerian Root"
		xp = 15 * ( math.Clamp( extraHerbs, 1, 3 ) )
	end
	if ( herbType ) then
		local herbCount = math.Clamp( extraHerbs, 1, 3 )
		if ( herbCount > 1 ) then
			ply:ChatPrint( "You've found " .. herbCount .. " units of " .. herbType .. "!" )
		else
			ply:ChatPrint( "You've found some " .. herbType .. "!" )
		end
		ply:RewardXP( xp, NOOB_SKILL_HERBALISM, "HerbalismXP", "Herbalism", false )
		ply:GiveHerb( herbType, herbCount )
		hook.Call( "OnPlayerGatherHerb", { }, ply, herbType, math.Clamp( extraHerbs, 1, 3 ) )
	else
		ply:ChatPrint( "You finished harvesting the herb but found nothing of value." )
	end
end

function ENT:CancelHarvesting( )
	if ( timer.Exists( self:EntIndex( ) .. ":BeingHarvested"  ) ) then
		timer.Destroy( self:EntIndex( ) .. ":BeingHarvested" )
	end
	self:SetUsingEnt( nil )
end

function ENT:OnRemove()
end
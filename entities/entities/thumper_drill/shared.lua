if ( SERVER ) then AddCSLuaFile( ) end

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Thumper Drill"
ENT.Author = "Sinavestos : Edited By Jeezy"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "owning_ent" )
end

if not ( SERVER ) then return end

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube2x2x2.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:SetColor( Color( 255, 255, 255, 0 ) )
	if ( self:GetPhysicsObject( ):IsValid( ) ) then
		self:GetPhysicsObject( ):EnableMotion( false )
	end
	self.thumperActivated = true
	self.thumperHealth = 200
	self.thumperEnt = ents.Create( "prop_thumper" )
	self.thumperEnt:SetPos( self:GetPos( ) + Vector( 0, 0, -47.7 ) )
	self.thumperEnt:Spawn( )
	self.thumperEnt:Activate( )
	self.thumperEnt:SetParent( self )
	self:InitiateGemIntervalTimer( self:EntIndex( ) )
	self:MoveToGround( )
end

function ENT:InitiateGemIntervalTimer( thumpEntIndex )
	local entIndex = thumpEntIndex
	local gemIntervals = SVNOOB_VARS:Get( "DrillingIntervals" )
	local currentLevel = NOOBRP_SkillAlgorithms:CalculateMining( self:Getowning_ent( ) )["CurrentLevel"]
	local minInt = math.Clamp( gemIntervals.min - (currentLevel / 3), 60, gemIntervals.min )
	local maxInt = math.Clamp( gemIntervals.max - (currentLevel / 3), 180, gemIntervals.max )
	timer.Create( entIndex .. ":IsDrilling", math.random( minInt, maxInt ), 0, function( )
		if not ( IsValid( self ) ) then timer.Destroy( entIndex ..":IsDrilling" ) return end
		self:DropRandomGem( )
		self:GemIntervalTimer( entIndex )
	end )
end

function ENT:GemIntervalTimer( thumpEntIndex )
	local entIndex = thumpEntIndex
	local gemIntervals = SVNOOB_VARS:Get( "DrillingIntervals" )
	local currentLevel = NOOBRP_SkillAlgorithms:CalculateMining( self:Getowning_ent( ) )["CurrentLevel"]
	local minInt = math.Clamp( gemIntervals.min - (currentLevel / 3), 60, gemIntervals.min )
	local maxInt = math.Clamp( gemIntervals.max - (currentLevel / 3), 180, gemIntervals.max )
	timer.Adjust( entIndex .. ":IsDrilling", math.random( minInt, maxInt ), 0, function( )
		if not ( IsValid( self ) ) then timer.Destroy( entIndex ..":IsDrilling" ) return end
		self:DropRandomGem( )
		self:GemIntervalTimer( entIndex )
	end )
end

function ENT:CancelGemIntervalTimer( )
	timer.Destroy( self:EntIndex( ) .. ":IsDrilling" )
end

function ENT:MoveToGround( )
	local maxHeight = self.thumperEnt:OBBMaxs( )[3]
	local traceData = { }
	traceData.start = self:GetPos( ) + Vector( 0, 0, maxHeight )
	traceData.endpos = traceData.start - Vector( 0, 0, 16000 )
	traceData.filter = { self, self.thumperEnt }
	local traceRes = util.TraceLine( traceData )
	if ( traceRes.HitWorld ) then
		//traceRes.HitPos = traceRes.HitPos + Vector( 0, 0, maxHeight )
		self:SetPos( traceRes.HitPos + ( ( self.thumperEnt:OBBMaxs( ) - self.thumperEnt:OBBMins( ) ) / 7 ) )
		self.thumperEnt:SetPos( self:GetPos( ) + Vector( 0, 0, -47.7 ) )
	end
end

function ENT:Use( activator, caller )
	if not ( self:Getowning_ent( ) == activator ) then return end
	self.nextPowerToggle = self.nextPowerToggle or CurTime( )
	if ( self.nextPowerToggle < CurTime( ) ) then
		if ( self.thumperActivated ) then
			self.thumperEnt:Fire( "Disable", 1, { } )
			self.thumperActivated = false
			self:CancelGemIntervalTimer( )
		else
			self.thumperEnt:Fire( "Enable", 1, { } )
			self.thumperActivated = true
			self:InitiateGemIntervalTimer( self:EntIndex( ) )
		end
		self.nextPowerToggle = CurTime( ) + 5
	end
end

function ENT:OnTakeDamage( dmgInfo )
	self.thumperHealth = self.thumperHealth - dmgInfo:GetDamage( )
	if self.thumperHealth <= 0 then
		local destructPos = self:GetPos( )
		self:Remove( )
		local effectData = EffectData()
		effectData:SetOrigin( destructPos )
		util.Effect( "Explosion", effectData, true, true )		
	end
end

function ENT:DropRandomGem( )
	local rndChance = math.Rand( 0, 100 )
	local gemChances = { }
	if ( SVNOOB_VARS:Get( "MiningBoostActive", true, "boolean", false ) == true ) then
		gemChances = SVNOOB_VARS:Get( "MiningEventDrillRates", true )
	else
		gemChances = SVNOOB_VARS:Get( "NormalDrillRates", true )
	end
	if ( !gemChances or !istable( gemChances ) or #gemChances < 1 ) then
		local errorMsg = "Fatal error occured for Mining Drills, gem chances table is invalid."
		ErrorNoHalt( errorMsg )
		NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, "[ERROR] " .. errorMsg, true )
	end
	local gemType, gemName = 3, "shale"
	if ( rndChance < gemChances[1].chanceMax and rndChance > gemChances[1].chanceMin ) then
		gemType, gemName = 3, "shale"
	elseif ( rndChance < gemChances[2].chanceMax and rndChance > gemChances[2].chanceMin ) then
		gemType, gemName = 4, "emerald"
	elseif ( rndChance < gemChances[3].chanceMax and rndChance > gemChances[3].chanceMin ) then
		gemType, gemName = 5, "ruby"
	elseif ( rndChance < gemChances[4].chanceMax and rndChance > gemChances[4].chanceMin ) then
		gemType, gemName = 6, "sapphire"
	elseif ( rndChance < gemChances[5].chanceMax and rndChance > gemChances[5].chanceMin ) then
		gemType, gemName = 7, "obsidian"
	elseif ( rndChance < gemChances[6].chanceMax and rndChance > gemChances[6].chanceMin ) then
		gemType, gemName = 8, "diamond"
	end
	local rndPos = self.thumperEnt:GetPos( ) + Vector( math.random( -128, 128 ), math.random( -128, 128 ), 30 )
	local spawnedGem = ents.Create( "ent_gem" )
	spawnedGem:SetGemType( gemName )
	spawnedGem:SetPos( rndPos )
	spawnedGem:Spawn( )
	local traceRes = util.TraceLine( { start = spawnedGem:GetPos( ), endpos = spawnedGem:GetPos( ) - Vector( 0, 0, 1024 ), filter = { spawnedGem } } )
	if ( traceRes.HitNoDraw ) then 
		local rndPos = self.thumperEnt:GetPos( ) + Vector( math.random( -128, 128 ), math.random( -128, 128 ), 30 )
		spawnedGem:SetPos( rndPos )
	end
	if ( IsValid( self:Getowning_ent( ) ) ) then
		self:Getowning_ent( ):RewardXP( gemType * 1.5, NOOB_SKILL_MINING, "MiningXP", "Mining", false )
	end
	hook.Call( "OnDrillGemDrop", { }, self:Getowning_ent( ), gemType )
	if ( gemType > 6 ) then
		NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, self:Getowning_ent( ):NiceInfo( ) .. "'s drills has spawned a " .. gemName, true )
	end
end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.MaxSpawnedMushrooms = 24

function ENT:Initialize()
	self:SetModel( "models/props/jeezy/mushroom/mushroom.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetAngles( Angle( 0, math.random( 0, 360 ), 0 ) )
	self:SetColor( Color( math.random( 100, 200 ), math.random( 100, 200 ), math.random( 100, 200 ) ) )
	local phys = self:GetPhysicsObject()

	phys:Wake()
	phys:EnableMotion( false )
	self.isRooted = false

	timer.Simple( 0.5, function( )
		local hitGrass = self:FindGrass( self:GetPos( ) )
		if (  hitGrass ) then
			self.isRooted = true
			self:SetPos( hitGrass + ( self:GetAngles( ):Up( ) * -4 ) )
			timer.Create( "SpawnMoreMushrooms", 30, 60, function( )
				if !IsValid( self ) then return end
				self:AttemptToSpread( )
			end )
			timer.Simple( math.random( 600, 1200 ), function( ) if !IsValid( self ) then return end self:Remove( ) end )
		else
			self:GetPhysicsObject( ):EnableMotion( true )
			self:GetPhysicsObject( ):ApplyForceCenter( Vector( 0, 0, 14000 ) )
			local rndAngle = self:GetAngles( )
			timer.Simple( 0.5, function( )
				if !IsValid( self ) then return end
				timer.Create( "SpinMushroom", 0.05, 10, function( ) 
					if !IsValid( self ) then return end
					local lerp = math.sin( CurTime( ) ) * 15
					rndAngle:RotateAroundAxis( self:GetAngles( ):Forward( ), lerp )
					self:SetAngles( rndAngle )
				end )
			end )
			timer.Simple( 5, function( ) if !IsValid( self ) then return end self:Remove( ) end )
		end
	end )
	local despawnData = tonumber( SVNOOB_VARS:Get( "MushroomDespawnTimer" ) ) or { min = 300, max = 600 }
	local despawnTimer = math.random( despawnData.min, despawnData.max )
	timer.Simple( despawnTimer, function( )
		if not ( IsValid( self ) ) then return end
		SafeRemoveEntity( self )
	end )
end

function ENT:Use( activator, caller )
	if not ( self.isRooted ) then return end
	local ply = activator
	local MushroomChanceTable = {
		[1] = { name = "Coral Fungus", chance = 75 },
		[2] = { name = "Red Reishi", chance = 35 },
		[3] = { name = "Psilocybe Cubensis", chance = 0.5 }
	}
	local rndRoll = math.Rand( 0, 100 )
	local shroomType = nil
	local xpReward = 0
	if ( rndRoll <= MushroomChanceTable[1].chance and rndRoll > MushroomChanceTable[2].chance ) then
		shroomType = "Coral Fungus"
		xpReward = 2
	elseif ( rndRoll <= MushroomChanceTable[2].chance and rndRoll > MushroomChanceTable[3].chance ) then
		shroomType = "Red Reishi"
		xpReward = 4
	elseif ( rndRoll <= MushroomChanceTable[3].chance ) then
		ply:ChatPrint( "You get a funny feeling in your stomach after picking up this mushroom." )
		shroomType = "Psilocybe Cubensis"
		xpReward = 20
	end
	if ( shroomType ) then
		ply:ChatPrint( "You've found a " .. shroomType .. "!" )
		ply:RewardXP( xpReward, NOOB_SKILL_HERBALISM, "HerbalismXP", "Herbalism", false )
		ply:GiveHerb( shroomType, 1 )
	else
		ply:ChatPrint( "You uprooted the mushroom but it broke apart in your hands." )
	end
	hook.Call( "OnPlayerGatherMushroom", { }, ply, shroomType )
	self:Remove()
end

function ENT:FindGrass( pos )
	local traceRes = util.TraceLine( { start = pos, endpos = pos + ( self:GetAngles( ):Up( ) * -35 ), filter = self } )
	if ( traceRes.HitWorld ) then
		if ( traceRes.HitTexture == "**displacement**" and traceRes.MatType == 68 ) then
			return traceRes.HitPos
		else
			return false
		end
	end
end

function ENT:AttemptToSpread( )
	local maxMushrooms = tonumber( SVNOOB_VARS:Get( "MaxMushroomEntities" ) ) or 5
	if ( #ents.FindByClass( "ent_mushroom" ) >= maxMushrooms ) then return end
	local rndPos = self:GetPos( ) + Vector( math.random( -64, 64 ), math.random( -64, 64 ), 32 )
	local hitGrass = self:FindGrass( rndPos )
	if ( hitGrass ) then
		local newShroom = ents.Create( "ent_mushroom" )
		newShroom:SetPos( hitGrass )
		newShroom:SetAngles( Angle( 0, 0, 0 ) )
		newShroom:Spawn( )
	end
end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel( "models/props_lab/hev_case.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	phys:Wake()
	phys:EnableMotion( false )
	self.healthRemaining = 250
	local entIndex = self:EntIndex( )
	local plagueLabRate = tonumber( SVNOOB_VARS:Get( "PlagueLabRate" ) ) or 800
	timer.Create( entIndex .. ":PlagueCanisterGeneration", plagueLabRate, 0, function( )
		if ( IsValid( self ) ) then
			local plagueCanister = ents.Create( "plague_canister" )
			plagueCanister:SetPos( self:GetPos( ) )
			plagueCanister:SetAngles( Angle( 0, 0, 0 ) )
			plagueCanister:Spawn( )
			plagueCanister:Activate( )
			hook.Call( "OnPlagueCanisterMade", { }, self:Getowning_ent( ) )
		else
			timer.Destroy( entIndex .. ":PlagueCanisterGeneration" )
		end
	end )
	self:MoveToGround( )
end

function ENT:MoveToGround( )
	local traceRes = util.TraceLine( { start = self:GetPos( ), endpos = self:GetPos( ) - Vector( 0, 0, 360 ), filter = self } )
	if ( traceRes.HitWorld ) then
		self:SetPos( traceRes.HitPos )
	end
end


function ENT:OnTakeDamage( dmgInfo )
	local dam = dmgInfo:GetDamage( )
	self.healthRemaining = self.healthRemaining - dam
	if ( self.healthRemaining <= 0 ) then
		timer.Destroy( self:EntIndex( ) .. ":PlagueCanisterGeneration" )
		SafeRemoveEntity( self )
	end
end

function ENT:OnRemove( )
	timer.Destroy( self:EntIndex( ) .. ":PlagueCanisterGeneration" )
end
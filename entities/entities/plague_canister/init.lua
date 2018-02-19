AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.RandomInfectionPhrases = { " HAS BEEN INFECTED! KILL IT WITH FIRE!", " HAS TURNED, FUCKING KILL THEM!", " WAS ZOMBIFIED, RUN FOR YOUR LIVES!" }
function ENT:Initialize()
	self:SetModel( "models/props_junk/propane_tank001a.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	phys:Wake()
	PrintMessage( HUD_PRINTTALK, "A deadly plague canister has arrived somewhere in Evocity, it will infect all those around it when destroyed!" )
	self.healthRemaining = 150
end

function ENT:OnTakeDamage( dmgInfo )
	local dam = dmgInfo:GetDamage( )
	self.healthRemaining = self.healthRemaining - dam
	if ( self.healthRemaining <= 0 ) then
		local infectRate = tonumber( SVNOOB_VARS:Get( "InfectionRate" ) ) or 25
		if ( infectRate < 50 ) then
			PrintMessage( HUD_PRINTTALK, "The canister has been destroyed! The infection rate has skyrocketed!" )
			SVNOOB_VARS:Set( "InfectionRate", 70 )
			timer.Simple( 30, function( )
				PrintMessage( HUD_PRINTTALK, "The infection rates have returned to normal." )
				SVNOOB_VARS:Set( "InfectionRate", SVNOOB_VARS:Get( "DefaultInfectionRate" ) )
			end )
		end
		local entitiesInBox = ents.FindInBox( ClampWorldVector( self:GetPos( ) - Vector( 256, 256, 256 ) ), ClampWorldVector( self:GetPos( ) + Vector( 256, 256, 256 ) ) )
		if ( #entitiesInBox > 0 ) then
			for index, ent in ipairs ( entitiesInBox ) do
				//if ( ent:IsPlayer( ) and ent:Team( ) ~= TEAM_ZOMBIE and !ent:getDarkRPVar( "IsGhost" ) ) then
				if ( ent:IsPlayer( ) and ent:Team( ) ~= TEAM_ZOMBIE and !ent:IsGhost( ) ) then
					ent:changeTeam( TEAM_ZOMBIE, true )
					timer.Simple( 0.1, function( ) ent:SetBodygroup( 1, math.random( 0, 1 ) ) end )
					PrintMessage( HUD_PRINTTALK, string.upper( ent:Nick( ) ) .. self.RandomInfectionPhrases[math.random( #self.RandomInfectionPhrases) ] )
				end
			end
			SafeRemoveEntity( self )
		else
			SafeRemoveEntity( self )
		end
	end
end
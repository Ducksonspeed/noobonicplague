AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
util.AddNetworkString( "N00BRP_RadioEntity_NET" )

function ENT:Initialize()
	self:SetModel( "models/props/cs_office/radio.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.ghostCollisionGroupOverride = COLLISION_GROUP_WEAPON
	self.unGhostCollisionGroupOverride = COLLISION_GROUP_WEAPON
	local phys = self:GetPhysicsObject()
	phys:Wake()
	self.currentHealth = 100
end

function ENT:OnTakeDamage( dmgInfo )
	if ( self.currentHealth <= 0 ) then
		self:Destruct( )
	else
		self.currentHealth = self.currentHealth - dmgInfo:GetDamage( )
	end
end

function ENT:Destruct()
	local effectData = EffectData( )
	effectData:SetStart( self:GetPos( ) )
	effectData:SetOrigin( self:GetPos( ) )
	effectData:SetScale( 1 )
	util.Effect( "Explosion", effectData )
	SafeRemoveEntity( self )
end

function ENT:Use( activator, caller )
	self.nextUse = self.nextUse or 0
	if ( self.nextUse > CurTime( ) ) then return end
	self.nextUse = CurTime( ) + 2
	self:SetIsPlaying( true )
	net.Start( "N00BRP_RadioEntity_NET" )
		net.WriteUInt( self.RadioMenu, 8 )
		net.WriteUInt( self:EntIndex( ), 32 )
	net.Send( activator )
end

local nextNetMessage = 0
local function ReceiveRadioNET( len, ply )
	local messType = net.ReadUInt( 8 )
	local entRadio = net.ReadEntity( )
	if ( nextNetMessage > CurTime( ) ) then return end
	nextNetMessage = CurTime( ) + 2
	if ( !IsValid( entRadio ) or entRadio:GetClass( ) ~= "ent_radio" or ply:GetEyeTrace( ).Entity ~= entRadio ) then
		return
	end
	if ( messType == entRadio.SetStation ) then
		local station = net.ReadString( )
		if not ( SHNOOB_VARS:Get( "RadioStations" )[ station ] ) then return end
		DarkRP.notify( ply, 0, 4, "You changed the radio station to: " .. station )
		entRadio:SetRadioStation( SHNOOB_VARS:Get( "RadioStations" )[ station ] )
		entRadio:SetIsPlaying( true )
		timer.Simple( 1, function( )
			if not ( IsValid( entRadio ) ) then return end
			net.Start( "N00BRP_RadioEntity_NET" )
				net.WriteUInt( entRadio.PlayRadio, 8 )
				net.WriteUInt( entRadio:EntIndex( ), 32 )
			net.Send( player.GetAll( ) )
		end )
	elseif ( messType == entRadio.PlayRadio ) then
		DarkRP.notify( ply, 0, 4, "You turned on the radio." )
		entRadio:SetIsPlaying( true )
		net.Start( "N00BRP_RadioEntity_NET" )
			net.WriteUInt( entRadio.PlayRadio, 8 )
			net.WriteUInt( entRadio:EntIndex( ), 32 )
		net.Send( player.GetAll( ) )
	elseif ( messType == entRadio.StopRadio ) then
		DarkRP.notify( ply, 0, 4, "You turned off the radio." )
		entRadio:SetIsPlaying( false )
		net.Start( "N00BRP_RadioEntity_NET" )
			net.WriteUInt( entRadio.StopRadio, 8 )
			net.WriteUInt( entRadio:EntIndex( ), 32 )
		net.Send( player.GetAll( ) )
	end
end
net.Receive( "N00BRP_RadioEntity_NET", ReceiveRadioNET )
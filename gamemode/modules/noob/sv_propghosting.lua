local physgunConVar = CreateConVar( "N00BRP_AdminCanPhysgunWorldProps", "0", FCVAR_ARCHIVE, "Only enable for testing." )
local playerPhysgunConVar = CreateConVar( "N00BRP_AdminCanPhysgunPlayers", "0", FCVAR_ARCHIVE, "Whether admins can physgun players." )
local saPlayerPhysgunConVar = CreateConVar( "N00BRP_SuperAdminCanPhysgunPlayers", "0", FCVAR_ARCHIVE, "Whether super admins can physgun players." )
local entMeta = FindMetaTable( "Entity" )
local timerPrefix = "N00BRP_UnghostProp_"
local entWhitelist = {
	["prop_physics"] = true,
	["microwave"] = true,
	["ent_pictureframe"] = true,
	["ent_motd"] = true,
	["ent_lawsboard"] = true,
	["ent_radio"] = true,
	["herb_garden"] = true,
	["gunlab"] = true,
	["ak47_gunlab"] = true,
	["m4a1_gunlab"] = true,
	["xm1014_gunlab"] = true
}

function entMeta:ToggleGhosting( status )
	if ( status ) then
		local curColor = self:GetColor( )
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
		self:SetColor( Color( curColor.r, curColor.g, curColor.b, 100 ) )
		self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		if ( self.ghostCollisionGroupOverride ) then
			self:SetCollisionGroup( self.ghostCollisionGroupOverride )
		end
		self.isGhosted = true
	else
		local curColor = self:GetColor( )
		self:SetColor( Color( curColor.r, curColor.g, curColor.b, 255 ) )
		self:SetCollisionGroup( COLLISION_GROUP_NONE )
		if ( self.unGhostCollisionGroupOverride ) then
			self:SetCollisionGroup( self.unGhostCollisionGroupOverride )
		end
		self.isGhosted = false
		local physObj = self:GetPhysicsObject( )
		if not ( physObj:IsValid( ) ) then return end
		physObj:EnableMotion( false )
	end
end

local function UnghostProp( ent )
	if not ( IsValid( ent ) ) then return end
	if ( ent.heldWithPhysgun ) then return end
	ent:ToggleGhosting( false )
end

local function OnPlayerSpawnedProp( ply, model, ent )
	local physObj = ent:GetPhysicsObject( )
	if ( physObj:IsValid( ) ) then
		physObj:EnableMotion( false )
	end
	ent:ToggleGhosting( true )
	timer.Create( timerPrefix .. ent:EntIndex( ), 5, 1, function( )
		UnghostProp( ent )
	end )
end
hook.Add( "PlayerSpawnedProp", "N00BRP_OnPlayerSpawnedProp_PlayerSpawnedProp", OnPlayerSpawnedProp )

local function OnPhysgunPickupProp( ply, ent )
	if ( ent.isFadingDoor ) then return false end
	if ( isfunction( ent.isDoor ) and ent:isDoor( ) ) then return false end
	if ( ent:IsPlayer( ) and ( ( ply:IsSuperAdmin( ) and saPlayerPhysgunConVar:GetBool( ) ) or ( ply:IsAdmin( ) and playerPhysgunConVar:GetBool( ) ) ) and !ply.adminPhysgunDisabled ) then 
		return true 
	end
	if not ( entWhitelist[ent:GetClass( )] ) then
		return ( ply:IsSuperAdmin( ) and physgunConVar:GetBool( ) )
	end
	if ( isfunction( ent.CPPIGetOwner ) and ent:CPPIGetOwner( ) == ply ) or ( isfunction( ent.Getowning_ent ) and ent:Getowning_ent( ) == ply ) or
	( ent:GetClass( ) == "prop_physics" and IsValid( ent:CPPIGetOwner( ) ) ) and ( ply:IsAdmin( ) and !ply.adminPhysgunDisabled ) then 
		ent:ToggleGhosting( true )
		ent.heldWithPhysgun = true
		if ( ent:GetModel( ) == "models/props/cs_office/paper_towels.mdl" ) then
			ply:BeginTowelTimer( ent )
		end
		return true
	else
		return false
	end
end
hook.Add( "PhysgunPickup", "N00BRP_OnPhysgunPickupProp_PhysgunPickup", OnPhysgunPickupProp )

local function OnPhysgunDropProp( ply, ent )
	if not ( entWhitelist[ent:GetClass( )] ) then return end
	if ( timer.Exists( timerPrefix .. ent:EntIndex( ) ) ) then
		timer.Adjust( timerPrefix .. ent:EntIndex( ), 5, 1, function( )
			UnghostProp( ent )
		end )
	else
		timer.Create( timerPrefix .. ent:EntIndex( ), 5, 1, function( )
			UnghostProp( ent )
		end )
	end
	if ( ent:GetModel( ) == "models/props/cs_office/paper_towels.mdl" ) then
		ply:CeaseTowelHatTimer( ent )
	end
	ent.heldWithPhysgun = false
end
hook.Add( "PhysgunDrop", "N00BRP_OnPhysgunDropProp_PhysgunDrop", OnPhysgunDropProp )

local function OnPhysgunFreezeProp( wep, physObj, ent, ply )
	if not ( entWhitelist[ent:GetClass( )] ) then return end
	if ( timer.Exists( timerPrefix .. ent:EntIndex( ) ) ) then
		timer.Adjust( timerPrefix .. ent:EntIndex( ), 5, 1, function( )
			UnghostProp( ent )
		end )
	else
		timer.Create( timerPrefix .. ent:EntIndex( ), 5, 1, function( )
			UnghostProp( ent )
		end )
	end
end
hook.Add( "OnPhysgunFreeze", "N00BRP_OnPhysgunFreezeProp_OnPhysgunFreeze", OnPhysgunFreezeProp )

function GM:OnPhysgunReload( physgun, ply )
	return false
end
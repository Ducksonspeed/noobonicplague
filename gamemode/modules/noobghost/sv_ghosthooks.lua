util.AddNetworkString( "N00BRP_GhostMode_ToggleCollision" )

local function TriggerGhostMode( victim, inflictor, attacker )
	victim:SetModelScale( 1, 0 )
	victim:ResetViewOffset( )
	victim:ScaleHull( nil, true )
	if ( !IsValid( inflictor ) or ( IsValid( inflictor ) and inflictor:GetClass( ) ~= "goombastomp" ) ) then
		victim:CreatePlayerCorpse( victim:GetPos( ) )
		victim.spawnPosOverride = victim:GetPos( )
	else
		victim.spawnPosOverride = nil
	end
	victim.aboutToGhost = true
	victim:Spawn( )
	victim:EnableGhostMode( true )
	//print(tostring(victim.DeathAngles))
	victim:SetEyeAngles( victim.DeathAngles )
end
hook.Add( "PlayerDeath", "N00BRP_TriggerGhostMode_PlayerDeath", TriggerGhostMode )

/*local function EnableGhostCustomCollision( ply )
	if ( ply:IsPlayer( ) ) then
		ply:SetCustomCollisionCheck( true )
	end
end
hook.Add( "OnEntityCreated", "N00BRP_EnableGhostCustomCollision_OnEntityCreated", EnableGhostCustomCollision )*/

local function CanGhostBeArrested( arrester, ply )
	//if ( ply:getDarkRPVar( "IsGhost" ) ) then
	if ( ply:IsGhost( ) ) then
		return false, ""
	end
end
hook.Add( "canArrest", "N00BRP_CanGhostBeArrested_canArrest", CanGhostBeArrested )

local function GhostCanPickupItem( ply, item )
	//if ( ply:getDarkRPVar( "IsGhost" ) ) then
	if ( ply:IsGhost( ) ) then
		return false
	end
end
hook.Add( "PlayerCanPickupItem", "N00BRP_GhostCanPickupItem_PlayerCanPickupItem", GhostCanPickupItem )

local function GhostCanPickupWeapon( ply, wep )
	//if ( ply:getDarkRPVar( "IsGhost" ) ) then
	if ( ply:IsGhost( ) ) then
		return false
	end
end
hook.Add( "PlayerCanPickupWeapon", "N00BRP_GhostCanPickupWeapon_PlayerCanPickupWeapon", GhostCanPickupWeapon )

local function GhostCanEnterVehicle( ply, veh, sRole )
	//if ( ply:getDarkRPVar( "IsGhost" ) ) then
	if ( ply:IsGhost( ) ) then
		return false
	end
end
hook.Add( "CanPlayerEnterVehicle", "N00BRP_GhostCanEnterVehicle_CanPlayerEnterVehicle", GhostCanEnterVehicle )

local function GhostCanBuyDoor( ply, ent )
	//if ( ply:getDarkRPVar( "IsGhost" ) ) then
	if ( ply:IsGhost( ) ) then
		return false, "", true
	end
end
hook.Add( "playerBuyDoor", "N00BRP_GhostCanBuyDoor_playerBuyDoor", GhostCanBuyDoor )

local function GhostCanUse( ply, ent )
	//if ( ply:getDarkRPVar( "IsGhost" ) and ent:GetClass( ) ~= "soul_orb" ) then
	if ( ply:IsGhost( ) and ent:GetClass( ) ~= "soul_orb" ) then
		return false
	end
end
hook.Add( "PlayerUse", "N00BRP_GhostCanUse_PlayerUse", GhostCanUse )

local function GhostCanBuyAmmo( ply, ammoTable )
	//if ( ply:getDarkRPVar( "IsGhost" ) ) then
	if ( ply:IsGhost( ) ) then
		return false
	end
end
hook.Add( "canBuyAmmo", "N00BRP_GhostCanBuyAmmo_canBuyAmmo", GhostCanBuyAmmo )

local function GhostCanBuyCustomEntity( ply, entTable )
	//if ( ply:getDarkRPVar( "IsGhost" ) ) then
	if ( ply:IsGhost( ) ) then
		return false
	end
end
hook.Add( "canBuyCustomEntity", "N00BRP_GhostCanBuyCustomEntity_canBuyCustomEntity", GhostCanBuyCustomEntity )

local function GhostCanBuyPistol( ply, shipmentTable )
	//if ( ply:getDarkRPVar( "IsGhost" ) ) then
	if ( ply:IsGhost( ) ) then
		return false
	end
end
hook.Add( "canBuyPistol", "N00BRP_GhostCanBuyPistol_canBuyPistol", GhostCanBuyPistol )

local function GhostCanBuyShipment( ply, shipmentTable )
	//if ( ply:getDarkRPVar( "IsGhost" ) ) then
	if ( ply:IsGhost( ) ) then
		return false
	end
end
hook.Add( "canBuyShipment", "N00BRP_GhostCanBuyShipment_canBuyShipment", GhostCanBuyShipment )

local function GhostCanBuyVehicle( ply, vehicleTable )
	//if ( ply:getDarkRPVar( "IsGhost" ) ) then
	if ( ply:IsGhost( ) ) then
		return false
	end
end
hook.Add( "canBuyVehicle", "N00BRP_GhostCanBuyVehicle_canBuyVehicle", GhostCanBuyVehicle )

local function GhostBuyVehicle( ply, ent )
	//if ( ply:getDarkRPVar( "IsGhost" ) ) then
	if ( ply:IsGhost( ) ) then
		return false
	end
end
hook.Add( "playerBuyVehicle", "N00BRP_GhostBuyVehicle_playerBuyVehicle", GhostBuyVehicle )

local function GhostCanUnWant( target, actor )
	//if ( actor:getDarkRPVar( "IsGhost" ) ) then
	if ( actor:IsGhost( ) ) then
		return false
	end
end
hook.Add( "canUnwant", "N00BRP_GhostCanUnWant_canUnwant", GhostCanUnwant ) 

local function GhostCanWanted( target, actor )
	//if ( actor:getDarkRPVar( "IsGhost" ) ) then
	if ( actor:IsGhost( ) ) then
		return false
	end
end
hook.Add( "canWanted", "N00BRP_GhostCanUnWant_canWanted", GhostCanWanted )

local function GhostTakeDamage( ply, hitGroup, dmgInfo )
	//if ( ply:getDarkRPVar( "IsGhost" ) ) then
	if ( ply:IsGhost( ) ) then
		dmgInfo:ScaleDamage( 0 )
	end
end
hook.Add( "ScalePlayerDamage", "N00BRP_GhostTakeDamage_ScalePlayerDamage", GhostTakeDamage )
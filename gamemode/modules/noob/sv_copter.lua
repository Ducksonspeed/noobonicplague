local heliEntity = nil
local heliEntitySound = nil
local helicopterDamageTable = { }
local nextTargetChange = 0

function HelicopterDamageHook( ent, dmgInfo )
	local attacker = dmgInfo:GetAttacker( )
	if ( IsValid( attacker ) and attacker:IsNPC( ) and IsValid( heliEntity ) and attacker == heliEntity ) then
		dmgInfo:ScaleDamage( 4 )
	end
	if ( IsValid( attacker ) and attacker:IsPlayer( ) and IsValid( heliEntity ) and ent == heliEntity ) then
		helicopterDamageTable[attacker:SteamID( )] = helicopterDamageTable[attacker:SteamID( )] or 0
		helicopterDamageTable[attacker:SteamID( )] = helicopterDamageTable[attacker:SteamID( )] + dmgInfo:GetDamage( )
	end
end

local function HelicopterSelectTarget( )
	if not ( IsValid( heliEntity ) ) then 
		heliEntitySound:Stop( )
		heliEntitySound = nil
		for index, ply in ipairs( player.GetAll( ) ) do
			local plyDamage = helicopterDamageTable[ ply:SteamID( ) ]
			if ( plyDamage and plyDamage > 0 ) then
				local cashReward = math.Round( plyDamage * 25 )
				ply:ChatPrint( "(EVENT) The chopper spins wildly out of control and smashes into the ground! You receive $" .. cashReward .. " in bounties for damage dealt to the attacker!" )
				ply:addMoney( cashReward )
			else
				ply:ChatPrint( "(EVENT) The chopper spins wildly out of control and smashes into the ground!" )
			end			
		end
		helicopterDamageTable = { }
		hook.Remove( "EntityTakeDamage", "N00BRP_HelicopterDamage_EntityTakeDamage" )
		hook.Remove( "Think", "N00BRP_HelicopterSelectTarget_Think" )
		timer.Simple( 60, function( )
			for index, ply in ipairs( player.GetAll( ) ) do
				ply:ChatPrint( "Something hits you hard on the back of the head ... when you wake up your RPG is gone." )
				ply:StripWeapon( "weapon_rpg" )
			end
			for index, ent in pairs( ents.FindByClass( "helicopter_chunk" ) ) do
				SafeRemoveEntity( ent )
			end
		end )
		return
	end
	if ( nextTargetChange > CurTime( ) ) then return end
	nextTargetChange = CurTime( ) + 5
	if not IsValid( heliEntity ) then return end
	for index, ply in ipairs( player.GetAll( ) ) do
		if ( ply:IsGhost( ) or ply:GetObserverMode( ) ~= OBS_MODE_NONE ) then
			heliEntity:AddEntityRelationship( ply, D_NU, 99 )
		else
			heliEntity:AddEntityRelationship( ply, D_HT, 99 )
		end
	end
end

local function SpawnHelicopter( ply, cmd, args )
	if not ( ply:IsSuperAdmin( ) ) then return end
	if ( IsValid( heliEntity ) ) then return end
	nextTargetChange = 0
	heliEntity = ents.Create( "npc_helicopter" )
	heliEntity:SetPos( ply:GetPos( ) )
	if ( ply:IsOnGround( ) ) then
		heliEntity:SetPos( ply:GetPos( ) + Vector( 0, 0, 200 ) )
	end
	heliEntity:Spawn( )
	heliEntity:Activate()
	heliEntitySound = CreateSound( heliEntity, "npc/attack_helicopter/aheli_rotor_loop1.wav" )
	heliEntitySound:Play( )
	timer.Create( "N00BRP_Helicopter_NoiseTimer", 8, 0, function( )
		if not ( IsValid( heliEntity ) ) then
			timer.Remove( "N00BRP_Helicopter_NoiseTimer" )
			return
		end
		heliEntitySound:Stop()
		heliEntitySound = CreateSound( heliEntity, "npc/attack_helicopter/aheli_rotor_loop1.wav" )
		heliEntitySound:Play()
	end )

	local plyID = ply:UniqueID( )
	timer.Create( "N00BRP_Helicopter_FollowPlayer:" .. plyID, 1, 0, function( )
		if ( !IsValid( ply ) or !IsValid( heliEntity ) ) then
			timer.Remove( "N00BRP_Helicopter_FollowPlayer:" .. plyID ) 
			return
		end 
		if ( IsValid( heliEntity ) ) then
			local plyDirection = ply:GetPos( ) - heliEntity:GetPos( )
			heliEntity:SetVelocity( plyDirection * 0.3 + Vector( 0, 0, 100 ) )
		else
			timer.Remove( "N00BRP_Helicopter_FollowPlayer:" .. plyID )
		end
	end )

	timer.Create( "N00BRP_Helicopter_GiveRPGs", 60, 0, function( )
		if not ( IsValid( heliEntity ) ) then
			timer.Remove( "N00BRP_Helicopter_GiveRPGs" )
			return
		end
		for index, ply in ipairs( player.GetAll( ) ) do
			if ( !ply:IsGhost( ) and ply:GetObserverMode( ) == OBS_MODE_NONE ) then
				ply:ChatPrint( "A rebel sympathizer runs up to you and hands you a rocket launcher and some ammo, then runs off." )
				ply:Give( "weapon_rpg" )
				ply:GiveAmmo( 3, "rpg_round" )
			end
		end
	end )

	hook.Add( "EntityTakeDamage", "N00BRP_HelicopterDamage_EntityTakeDamage", HelicopterDamageHook )
	hook.Add( "Think", "N00BRP_HelicopterSelectTarget_Think", HelicopterSelectTarget )
end
concommand.Add("np_heli", SpawnHelicopter )

local function DropHelicopterBomb( ply, cmd, args )
	if not ( ply:IsSuperAdmin( ) ) then return end
	ply.nextHeliBomb = ply.nextHeliBomb or 0
	if ( ply.nextHeliBomb > CurTime( ) ) then return end
	ply.nextHeliBomb = CurTime( ) + 0.5
	if not ( IsValid( heliEntity ) ) then return end
	heliEntity:Fire( "DropBombStraightDown" )
end
concommand.Add("np_helibomb", DropHelicopterBomb )

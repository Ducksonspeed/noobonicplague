util.AddNetworkString( "N00BRP_SendVehicleGas" )
local function DatabaseInitialize( )
	mySQLControl:CreateTable( "darkrp_eventmeters", { "location varchar(255) UNIQUE KEY, progress int" } )
	mySQLControl:CreateTable( "darkrp_revenges", { "uniqueid BIGINT", "otheruniqueid BIGINT", "killAmt int", "PRIMARY KEY ( uniqueid, otheruniqueid )" } )
	mySQLControl:CreateTable( "darkrp_pacifists", { "uniqueid BIGINT PRIMARY KEY", "unixtime BIGINT" } )
	mySQLControl:CreateTable( "darkrp_miningxp", { "uniqueid BIGINT PRIMARY KEY", "xp int" } )
	mySQLControl:CreateTable( "darkrp_policexp", { "uniqueid BIGINT PRIMARY KEY", "xp int" } )
	mySQLControl:CreateTable( "darkrp_runningxp", { "uniqueid BIGINT PRIMARY KEY", "xp int" } )
	mySQLControl:CreateTable( "darkrp_criminalxp", { "uniqueid BIGINT PRIMARY KEY", "xp int" } )
	mySQLControl:CreateTable( "darkrp_printingxp", { "uniqueid BIGINT PRIMARY KEY", "xp int" } )
	mySQLControl:CreateTable( "darkrp_endurancexp", { "uniqueid BIGINT PRIMARY KEY", "xp int" } )
	mySQLControl:CreateTable( "darkrp_gems", { "uniqueid BIGINT PRIMARY KEY", "rocks int", "granite int", "shale int", "emeralds int", "rubies int", "sapphires int", "obsidians int", "diamonds int" } )
	mySQLControl:CreateTable( "darkrp_perks", { "uniqueid BIGINT PRIMARY KEY", "perk int" } )
	mySQLControl:CreateTable( "darkrp_bonusperks", { "uniqueid BIGINT PRIMARY KEY", "points int", "max int" } )
	mySQLControl:CreateTable( "darkrp_permweps", { "steamid varchar(255), class varchar(255)" } )
	mySQLControl:CreateTable( "darkrp_clans", { "uniqueid BIGINT PRIMARY KEY, name varchar(255), rank int" } )
	mySQLControl:CreateTable( "darkrp_bankitems", { "steamid varchar(255), class varchar(255), model varchar(255), content varchar(255), count int, name varchar(255), id MEDIUMINT NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)" } )
	mySQLControl:CreateTable( "darkrp_herbalism", { "uniqueid BIGINT PRIMARY KEY", "xp int" } )
	mySQLControl:CreateTable( "darkrp_alchemy", { "uniqueid BIGINT PRIMARY KEY", "xp int"} )
	mySQLControl:CreateTable( "darkrp_ingredients", { "uniqueid BIGINT PRIMARY KEY", "burdockroot int", "gingkobiloba int", "valerianroot int", "coralfungus int", "redreishi int", "psilocybecubensis int" } )
	mySQLControl:CreateTable( "darkrp_perkpoints", { "uniqueid BIGINT PRIMARY KEY", "amount int" } )
	mySQLControl:CreateTable( "darkrp_toweltimer", { "uniqueid BIGINT PRIMARY KEY", "time MEDIUMINT" } )
	mySQLControl:CreateTable( "darkrp_weaponcolor", { "uniqueid BIGINT PRIMARY KEY", "r int", "g int", "b int" } )
	mySQLControl:CreateTable( "darkrp_playercolor", { "uniqueid BIGINT PRIMARY KEY", "r int", "g int", "b int" } )
	mySQLControl:CreateTable( "darkrp_playertitles", { "uniqueid BIGINT NOT NULL", "enumtitle int NOT NULL", "PRIMARY KEY( uniqueid, enumtitle )" } )
	mySQLControl:CreateTable( "darkrp_playeractivetitle", { "uniqueid BIGINT NOT NULL PRIMARY KEY", "enumtitle int NOT NULL" } )
	mySQLControl:CreateTable( "darkrp_playerips", { "steam varchar(255)", "ip varchar(45)", "id int AUTO_INCREMENT NOT NULL", "PRIMARY KEY( id, steam )" } )
	mySQLControl:CreateTable( "darkrp_adminlogin", { "steamid varchar(255) PRIMARY KEY", "unixtime BIGINT" } )
	mySQLControl:CreateTable( "darkrp_potionvault", { "uniqueid BIGINT NOT NULL", "potionid int NOT NULL", "amt int", "PRIMARY KEY( uniqueid, potionid )" } )
	mySQLControl:CreateTable( "darkrp_potionindex", { "potionid int AUTO_INCREMENT NOT NULL PRIMARY KEY", "potionname varchar(255)" } )
	mySQLControl:CreateTable( "darkrp_rentedperms", { "uniqueid BIGINT NOT NULL", "class varchar(255) NOT NULL", "expiretime BIGINT", "PRIMARY KEY( uniqueid, class )" } )
	mySQLControl:CreateTable( "darkrp_playerclothes", { "uniqueid BIGINT NOT NULL PRIMARY KEY", "maleClothing varchar(255)", "femaleClothing varchar(255)" } )
	mySQLControl:CreateTable( "darkrp_beastlairs", { "id int AUTO_INCREMENT NOT NULL PRIMARY KEY", "port int NOT NULL", "spawnTime BIGINT NOT NULL", "spawnDate VARCHAR(255) NOT NULL", "playerAmt int" } )
	NOOBRP = NOOBRP or { }
	mySQLControl:Query( "SELECT * FROM darkrp_beastlairs WHERE spawnDate = " .. SQLStr( os.date( "%x" ) ) .. " OR spawnDate = " .. SQLStr( os.date( "%x" , os.time( ) - 86400 ) ) .." ORDER BY spawnTime DESC LIMIT 1;", function( data )
		if ( data and #data > 0 and data[1] ) then
			NOOBRP.LastBeastLair = { port = data[1].port, time = data[1].spawnTime }
		else
			NOOBRP.LastBeastLair = nil
		end
	end )
	NOOBRP.GeneratePotionIndex( )
	if ( !NOOBRP.TeamSpawns or table.Count( NOOBRP.TeamSpawns ) == 0 ) then
		NOOBRP:RetrieveTeamSpawns( )
	end
	if ( !NOOBRP.JailPoses or table.Count( NOOBRP.JailPoses ) == 0 ) then
		NOOBRP:RetrieveJailPositions( )
	end
end
hook.Add( "NOOBRP_MySQL_Connected", "N00BRP_DatabaseInitialize_NOOBRP_MySQL_Connected", DatabaseInitialize )

local function OnGamemodeInitialize( )
	local defaultHostName = SVNOOB_VARS:Get( "DefaultHostName", true, "string", "Noobonic Plague | Reborn" )
	concommand.Remove( "rp_setmoney" )
	RunConsoleCommand( "hostname", defaultHostName )
	RunConsoleCommand( "sbox_maxkeypads", 2 )
	SetGlobalInt( "N00BRP_SpeedLimit", 35 )
	SHNOOB_VARS:Set( "RadioStations", NOOBRP.Config.RadioStations )
	SHNOOB_VARS:Set( "MinimapWaypoints", NOOBRP.Config.Waypoints )
end
hook.Add( "Initialize", "N00BRP_OnGamemodeInitialize_Initialize", OnGamemodeInitialize )

local function OnPlayerBoughtCustomEntity( ply, entTable, ent, price )
	ent.ownerSteamID = ply:SteamID( )
	local mes = ply:NiceInfo( true ) .. " has purchased a " .. ent:GetClass( )
	NOOB_LOGGER:Log( NOOB_LOGGING_WARNING, mes, false )
end
hook.Add( "playerBoughtCustomEntity", "N00BRP_OnPlayerBoughtCustomEntity_playerBoughtCustomEntity", OnPlayerBoughtCustomEntity )

local function OnPlayerSpawn( ply )
	ply:SetMoveType( MOVETYPE_WALK )
	ply.spawnedPreviously = ply.spawnedPreviously or false
	if ( ply.spawnedPreviously ) then
		ply:ResetViewOffset( )
		ply:ScaleHull( nil, true )
		if ( IsValid( ply ) ) then
			timer.Simple( 0.5, function( ) -- Correctly check if player is a Ghost.
				if ( IsValid( ply ) ) then
					ply:GivePurgeEventGear( )
					ply:EquipAllPurgeDurationItems( )
					ply:GiveRentedPerms( )
				end
			end )
		end
	else
		ply.spawnedPreviously = true
	end
	if ( !ply:IsGhost( ) ) then
		timer.Simple(0.5, function( )
			if not ply or not IsValid( ply ) then return end
			if ( game.GetMap( ) ~= "rp_evocity_v2d_updated" and NOOBRP.BeastFightStarted ) then
				if ( !ply.reviveExpireTime or ( ply.reviveExpireTime and ply.reviveExpireTime < CurTime( ) ) ) then
					ply.reviveExpireTime = nil
					local randomSpawns = { Vector( 2448.138, -748.861, -687.969 ), Vector( 2146.907, -448.736, -687.885 ), Vector( 2393.175, -202.283, -686.955 ) }
					local randomSpawn = randomSpawns[math.random(#randomSpawns)]
					ply:SetPos( randomSpawn )
				end
			end
		end )
		ply:ToggleCollision( true )
		local mes = ply:NiceInfo( true ) .. " has spawned."
		NOOB_LOGGER:Log( NOOB_LOGGING_WARNING, mes, true )
		ply:AttemptWearClothes( )
	end
end
hook.Add( "PlayerSpawn", "N00BRP_OnPlayerSpawn_PlayerSpawn", OnPlayerSpawn )

local function SetColorOnSpawn( ply )
	local defaultColor = Vector( 1, 1, 1 )
	if ( ply.savedWeaponColor ) then 
		ply:SetWeaponColor( ply.savedWeaponColor:ToVector( ) ) 
	else
		ply:SetWeaponColor( defaultColor )
	end
	if ( ply.savedPlayerColor ) then
		ply:SetPlayerColor( ply.savedPlayerColor:ToVector( ) )
	else
		ply:SetPlayerColor( defaultColor )
	end
end
hook.Add( "SetPlayerAndWeaponColor", "N00BRP_SetColorOnSpawn_SetPlayerAndWeaponColor", SetColorOnSpawn )

/*local function OnDarkRPPlayerSpawn( ply, pos )
	timer.Simple( 1, function( )
		if not ( IsValid( ply ) ) then return end
		local traceRes = ply:TraceHull( Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), { ply }, false )
		if ( traceRes.HitWorld and !ply:IsGhost( ) and !ply.cantEquipWeapons ) then
			print( "[WARNING] Player spawned stuck, attempting to unstuck them." )
			ply:SetPos( ply:GetPos( ) + Vector( 0, 0, 128 ) )
		end
	end )
end
hook.Add( "N00BRP_OnDarkRPPlayerSpawn", "N00BRP_OnDarkRPPlayerSpawn", OnDarkRPPlayerSpawn )*/

local function OnPlayerInitialized( ply )
	ply:RetrieveCurrentGhosts( )
	ply:RetrieveSpawnTimes( )
	ply:RetrieveMiscData( )
	ply:RetrieveRevenges( )
	ply:CheckForPacifism( )
	ply:ResetViewOffset( )
	ply:ScaleHull( nil, true )
	ply:setDarkRPVar( "IsInitialized", true )
	ply:ConCommand( "motd" )
	ply:GivePurgeEventGear( )
	ply:EquipAllPurgeDurationItems( )
	ply:TrackAdminJoinTime( )
	ply:LoadAchievements( )
	ply:RetrieveTitles( )
	ply:RetrieveClothes( )
	ply:SendNPCTitles( )
	ply:RemoveExpiredRentals( function( )
		ply:AddRentedPermsToLoadout( function( )
			ply:GiveRentedPerms( )
		end )
	end )
	for index, wep in ipairs ( ply:GetWeapons( ) ) do
		if not ( noob_WeaponIndex:Get( wep:GetClass( ) ) ) then continue end
		net.Start( "N00BRP_TempWeapons_NET" )
			net.WriteUInt( ENUM_TEMPWEPS_ADDWEP, 8 )
			net.WriteString( wep:GetClass( ) )
		net.Send( ply )
	end
	if ( ply.setGhostModeOnInitialize ) then
		if ( IsValid( ply.playerCorpse ) ) then
			ply.spawnPosOverride = ply.playerCorpse:GetPos( )
		end
		ply:UnSpectate( )
		ply:Spawn( )
		ply.respawnTimeOverride = NOOBRP.StatusTrackers:GetRespawnLength( ply:SteamID( ) )
		ply.aboutToGhost = true
		ply:EnableGhostMode( true )
		ply.setGhostModeOnInitialize = false
	end
	local murdererTime = NOOBRP.StatusTrackers.CurrentMurderers[ ply:SteamID( ) ]
	if ( murdererTime ) then
		if ( murdererTime > CurTime( ) ) then
			local timeRemaining = NOOBRP.StatusTrackers:GetRemainingMurdererTime( ply:SteamID( ) )
			ply:EnableMurdererStatus( timeRemaining )
		else
			NOOBRP.StatusTrackers.CurrentMurderers[ ply:SteamID( ) ] = nil
		end
	end
end
hook.Add( "NOOBRP_OnRequestData", "N00BRP_OnPlayerInitialized_OnRequestData", OnPlayerInitialized )

local function OnPlayerDisconnected( ply )
	ply:DidCrabQueenDisconnect( )
	ply:DropAllPrintersFromBackpack( )
	if ( ply:AlreadyOnQuest( ) ) then
		local questName = ply.currentQuest.name
		ply:SetQuestCooldown( questName, 3600 )
	end
	if ( ply.isTasered and ply:getDarkRPVar( "wanted" ) ) then
		local defaultTimer = tonumber( SVNOOB_VARS:Get( "DefaultArrestTimer" ) ) or 300
		local murdererArrestTimer = tonumber( SVNOOB_VARS:Get( "MurdererPenaltyTime" ) ) or 600
		local isMurderer = false
		if ( NOOBRP.StatusTrackers.CurrentMurderers[ ply:SteamID( ) ] ) then isMurderer = true end
		PrintMessage( HUD_PRINTCENTER, ply:Name( ) .. " has disconnected while tased and was automatically jailed." )
		if ( isMurderer ) then
			NOOBRP.StatusTrackers.ArrestedPlayers[ ply:SteamID( ) ] = CurTime( ) + murdererArrestTimer
		else
			NOOBRP.StatusTrackers.ArrestedPlayers[ ply:SteamID( ) ] = CurTime( ) + defaultTimer
		end
	end
	if ( timer.Exists( ply:EntIndex( ) .. ":RespawnTimer" ) ) then
		NOOBRP.StatusTrackers:SetRespawnLength( ply:SteamID( ), timer.TimeLeft( ply:EntIndex( ) .. ":RespawnTimer" ) )
		local steamID = ply:SteamID( )
		local entIndex = ply:EntIndex( )
		if ( IsValid( ply.playerCorpse ) ) then
			local corpseIndex = ply.playerCorpse:EntIndex( )
			timer.Create( corpseIndex .. ":CorpseDespawnTimer", timer.TimeLeft( entIndex .. ":RespawnTimer" ), 1, function( )
				SafeRemoveEntity( Entity(corpseIndex) )
				NOOBRP.StatusTrackers:ClearRespawnTimer( steamID )
			end )
		end
		timer.Destroy( entIndex .. ":RespawnTimer" )
	end
end
hook.Add( "PlayerDisconnected", "N00BRP_OnPlayerDisconnected_PlayerDisconnected", OnPlayerDisconnected )

local function OnPlayerArrested( crim, time, arrester )
	if ( IsValid( arrester ) and arrester:IsPlayer( ) ) then
		crim.teleSWEPDestination = nil
		if ( crim:IsWearingBackItem( "jetpack" ) or crim:IsWearingBackItem( "backpack" ) ) then
			crim:UnequipBackItem( )
		end
		if ( crim:IsTrespassingInNexus( ) and !crim:isArrested( ) ) then
			PrintMessage( HUD_PRINTCONSOLE, crim:Name( ) .. " has been arrested while trespassing in the Nexus!" )
			crim.policeDemoteBlacklist = crim.policeDemoteBlacklist or { }
			crim.policeDemoteBlacklist[arrester:SteamID( )] = CurTime( ) + time
		end
		local mes = arrester:NiceInfo( true ) .. " has arrested " .. crim:NiceInfo( true ) .. " for " .. string.NiceTime( time )
		NOOB_LOGGER:Log( NOOB_LOGGING_WARNING, mes, false )
		local isOnQuest, questStage = arrester:IsOnQuest( "police_duty_quest" )
		if ( isOnQuest and questStage == "stage_in_progress" ) then
			DarkRP.notify( arrester, 2, 4, "You've completed the Police Duty Quest, return to the jailguard." )
			arrester:SetQuestComplete( )
		end
	end
	if not ( NOOBRP.StatusTrackers.ArrestedPlayers[ crim:SteamID( ) ] ) then
		NOOBRP.StatusTrackers.ArrestedPlayers[ crim:SteamID( ) ] = CurTime( ) + time
	end
end
hook.Add( "playerArrested", "N00BRP_OnPlayerArrested_playerArrested", OnPlayerArrested )

local function OnPlayerUnarrested( crim, arrester )
	if ( NOOBRP.StatusTrackers.ArrestedPlayers[ crim:SteamID( ) ] ) then
		NOOBRP.StatusTrackers.ArrestedPlayers[ crim:SteamID( ) ] = nil
	end
	crim.policeDemoteBlacklist = { }
	timer.Simple( 1, function( ) 
		local mins = Vector( -7432.157, -9309.672, 840.031 )
		local maxs = Vector( -8089.354, -9009.595, 967.969 )
		if ( crim:GetPos( ):IsInBox( mins, maxs ) ) then
			print( "[UNARREST] " .. crim:Name( ) .. " did not teleport out of jail after being unarrested, manually respawning them." )
			crim:Spawn( )
		end
	end )
end
hook.Add( "playerUnArrested", "N00BRP_OnPlayerUnarrested_playerUnArrested", OnPlayerUnarrested )

local function OnPlayerInitialSpawn( ply )
	ply:UpdateLastViolentAction( )
	ply:CacheUniqueID( )
	ply:SearchForOwnedEntities( )
	local arrestTime = NOOBRP.StatusTrackers.ArrestedPlayers[ ply:SteamID( ) ]
	if ( arrestTime ) then
		if ( arrestTime > CurTime( ) ) then
			local timeRemaining = arrestTime - CurTime( )
			ply:arrest( timeRemaining )
		else
			NOOBRP.StatusTrackers.ArrestedPlayers[ ply:SteamID( ) ] = nil
		end
	end
	local respawnTime = NOOBRP.StatusTrackers:CheckIfRespawning( ply:SteamID( ) )
	if ( respawnTime ) then
		if ( respawnTime < CurTime( ) ) then
			NOOBRP.StatusTrackers:ClearRespawnTimer( ply:SteamID( ) )
		else
			for index, ent in ipairs( ents.FindByClass( "prop_ragdoll" ) ) do
				if ( ent.isPlayerCorpse and ent.ownerSteamID == ply:SteamID( ) ) then
					ent:SetOwner( ply )
					ply.spawnPosOverride = ply:GetPos( )
					ply.playerCorpse = ent
					timer.Destroy( ent:EntIndex( ) .. ":CorpseDespawnTimer" )
					break
				end
			end
			ply.setGhostModeOnInitialize = true
			ply:Spectate( OBS_MODE_ROAMING )
		end
	end
end
hook.Add( "PlayerInitialSpawn", "N00BRP_OnPlayerInitialSpawn", OnPlayerInitialSpawn )

local function OnPlayerModifySpeed( ply, isArrested, isCP )
	ply:ApplyMovementSpeed( )
end
hook.Add( "N00BRP_ModifyPlayerSpeed", "N00BRP_OnPlayerModifySpeed_ModifyPlayerSpeed", OnPlayerModifySpeed )

local function OnPlayerModifyHealth( ply, startingHealth )
	ply:ApplyBonusHealth( startingHealth )
end
hook.Add( "N00BRP_ModifyPlayerHealth", "N00BRP_OnPlayerModifyHealth_ModifyPlayerHealth", OnPlayerModifyHealth )

local function OnPlayerKeyPress( ply, keyCode )
	if ( ( keyCode == IN_USE and ply:KeyDown( IN_DUCK ) ) and ply:IsWearingBackItem( "backpack" ) ) then
		local traceRes = ply:RangeEyeTrace( 80 )
		if ( IsValid( traceRes.Entity ) ) then
			local ent = traceRes.Entity
			if ( ent:GetClass( ) == "basic_money_printer" or ent:GetClass( ) == "adv_money_printer" ) then
				if ( ply:HasRoomInBackpack( ) ) then
					ply:StorePrinterInBackpack( ent )
				else
					ply:ErrorNotify( "You have no room left in your backpack." )
				end
			end
		end
	end
	if ( keyCode == IN_RELOAD and !ply:KeyDown( IN_SPEED ) ) then
		if ( ply:InVehicle( ) and IsValid( ply:GetVehicle( ) ) ) then
			if ( ply:GetVehicle( ):GetClass( ) ~= "prop_vehicle_prisoner_pod" ) then
				ply.nextVehicleHorn = ply.nextVehicleHorn or 0
				if ( ply.nextVehicleHorn < CurTime( ) ) then
					ply:EmitSound( "horn.wav", 100, 100 )
					ply.nextVehicleHorn = CurTime( ) + 1
				end
			end
		end
	end
	if ( keyCode == IN_USE ) then
		ply.lastEnteredVehicle = ply.lastEnteredVehicle or CurTime( )
		if ( ply.lastEnteredVehicle + 2 < CurTime( ) ) then
			if ( ply:InVehicle( ) ) then ply:ExitVehicle( ) end
		end
		ply.lastUsePress = ply.lastUsePress or 0
		ply.nextPlayerPush = ply.nextPlayerPush or CurTime( )
		local traceRes = ply:RangeEyeTrace( 96 )
		local traceEnt = traceRes.Entity
		if ( ply:IsGhost( ) ) then return end
		if ( IsValid( traceEnt ) and traceEnt:GetClass( ) == "prop_ragdoll" and traceEnt.isPlayerCorpse and IsValid( traceEnt:GetOwner( ) ) ) then
			if ( traceEnt:GetOwner( ) == ply ) then return end
			if ( ply:Team( ) == TEAM_ZOMBIE ) then
				if not ( traceEnt.wasCorpseEaten ) then
					if ( traceEnt:GetOwner( ):Team( ) ~= TEAM_CITIZEN ) then
						local hpGainTable = SVNOOB_VARS:Get( "ZombieEatCorpseHPGain", true, "table", { min = 25, max = 50 } )
						local hpGain = math.random( hpGainTable.min, hpGainTable.max )
						ply:SetHealth( math.Clamp( ply:Health( ) + hpGain, 0, ply:GetMaxHealth( ) ) )
						ply:setSelfDarkRPVar( "Energy", math.Clamp( ( ply:getDarkRPVar("Energy" ) or 0 ) + 100, 0, 100) )
					end
					traceEnt.wasCorpseEaten = true
					ply:SayMessage( CHAT_PLAYER_ME, " devours " .. traceEnt:GetOwner( ):Name( ) .. "'s corpse." )
				else
					ply:ChatPrint( "There's no meat left on that corpse." )
				end
				return
			end
			if ( ply:IsWearingHat( "hamburger_hat" ) and ply:KeyDown( IN_RELOAD ) ) then
				ply.nextHamburgerDevour = ply.nextHamburgerDevour or 0
				if ( ply.nextHamburgerDevour < CurTime( ) ) then
					local useCooldown = SVNOOB_VARS:Get( "HamburgerHatUseCooldown", true, "number", 420 )
					ply.nextHamburgerDevour = CurTime( ) + useCooldown
					traceEnt:GetOwner( ).spawnPosOverride = nil
					SafeRemoveEntity( traceEnt:GetOwner( ).playerCorpse )
					ply:EmitSound( "ambient/creatures/town_child_scream1.wav", 100, math.random( 170, 250 ) )
					if not ( ply:IsMurderer( ) ) then
						PrintMessage( HUD_PRINTCENTER, ply:Name( ) .. " was deemed a Murderer for Cannablism!" )
						local penaltyTime = SVNOOB_VARS:Get( "MurdererPenaltyTime", true, "number", 600 )
						ply:EnableMurdererStatus( penaltyTime )
						NOOBRP.StatusTrackers:AddMurderer( ply:SteamID( ), penaltyTime )
					end
				else
					local timeLeft = string.NiceTime( ply.nextHamburgerDevour - CurTime( ) )
					DarkRP.notify( ply, 1, 4, "You're full, you can't eat another corpse for " .. timeLeft .. "." )
				end
			end
			if ( ply.lastUsePress > CurTime( ) - 2 ) then
				ply:AttemptCorpseCPR( traceEnt )
				ply.lastUsePress = CurTime( )
			else
				ply.lastUsePress = CurTime( )
				if ( traceEnt.beingDragged ) then return end
				local entIndex = ply:EntIndex( )
				traceEnt.beingDragged = true
				ply:ChatPrint("Press E every second to give CPR, or go ahead and drag that fucker's body around.")
				timer.Create( entIndex .. ":CorpseDrag", 0.1, 70, function( )
					if ( !IsValid( ply ) or !IsValid( traceEnt ) or !ply:KeyDown( IN_USE ) ) then
						timer.Destroy( entIndex .. ":CorpseDrag" )
						traceEnt.beingDragged = false
						return
					end
					local physBone = traceRes.PhysicsBone
					local targetPos = ply:RangeEyeTrace( 96 ).HitPos
					local physObj = traceEnt:GetPhysicsObjectNum( physBone )
					physObj:SetVelocity( ( targetPos - traceEnt:GetPhysicsObjectNum( physBone ):GetPos( ) ) * 15 )
				end )
			end
		elseif ( IsValid( traceEnt ) and traceEnt:IsPlayer( ) and !traceEnt:IsGhost( ) and ply.nextPlayerPush < CurTime( ) ) then
			if ( ply:IsPacifist( ) ) then return end
			local pushStrength = SVNOOB_VARS:Get( "PlayerPushStrength" )
			local pushCooldown = SVNOOB_VARS:Get( "PlayerPushCooldown" )
			traceEnt:SetVelocity( ply:GetAimVector( ):GetNormalized( ) * pushStrength )
			ply:EmitSound( "physics/body/body_medium_impact_hard"..math.random( 1, 6 )..".wav", 100, math.random( 75, 150 ) )
			ply.nextPlayerPush = CurTime( ) + pushCooldown
		end
	elseif ( keyCode == IN_JUMP ) then -- Credit to _Kilburn, only modified the variable names because I couldn't help it.
		if not ( IsValid( ply ) ) then return end
		if not ( ply:IsWearingBackItem( "jetpack" ) ) then
			if ( !ply.jumpCount or ply:IsOnGround( ) ) then 
				ply.jumpCount = 0
			end
			if ( ply.jumpCount == 2 ) then return end
			ply.jumpCount = ply.jumpCount + 1
			if ( ply.jumpCount == 2 ) then
				ply:SetVelocity( Vector( 0, 0, 200 ) )
			end
		end
		if ( ply:IsWearingBackItem( "jetpack" ) and !ply.isUsingJetpack and !ply:IsShrunk( ) and !ply:InVehicle( ) ) then
			ply.isUsingJetpack = true
			if ( ply.jetpackSoundPatch ) then ply.jetpackSoundPatch:Stop( ) ply.jetpackSoundPatch = nil end
			ply.jetpackSoundPatch = CreateSound( ply, "ambient/levels/citadel/citadel_drone_loop1.wav" )
			ply.jetpackSoundPatch:Play( )
			ply.jetpackSoundPatch:ChangeVolume( 0.2, 0 )
			ply.jetpackSoundPatch:ChangePitch( 90, 0 )
			local soundPatch = ply.jetpackSoundPatch
			BroadcastLua( "Entity( " .. ply:EntIndex( ) .. " ).isUsingJetpack = true" )
			local entIndex = ply:EntIndex( )
			timer.Create( ply:EntIndex( ) .. ":UsingJetpack", 0.1, 0, function( )
				if not ( IsValid( ply ) ) then
					soundPatch:Stop( )
					soundPatch = nil
					timer.Destroy( entIndex .. ":UsingJetpack" )
				end
				if ( !ply:KeyDown( IN_JUMP ) or !ply:IsWearingBackItem( "jetpack" ) ) then
					BroadcastLua( "Entity( " .. entIndex .. " ).isUsingJetpack = false" )
					ply.isUsingJetpack = false
					ply.jetpackSoundPatch:Stop( )
					ply.jetpackSoundPatch = nil
					timer.Destroy( entIndex .. ":UsingJetpack" )
				else
					ply:SetVelocity( Vector( 0, 0, SVNOOB_VARS:Get( "JetpackStrength", true, "number", 100 ) ) )
				end
			end )
		end
	end
end
hook.Add( "KeyPress", "N00BRP_OnPlayerKeyPress_KeyPress", OnPlayerKeyPress )

local function PlayerDeathCheck( victim, inflictor, attacker )
	victim:setDarkRPVar( "IsStealthed", false )
	victim:CureInfection( )
	local roadkill = false
	if ( IsValid( victim.stealthSpriteTrail ) ) then
		SafeRemoveEntity( victim.stealthSpriteTrail )
	end
	if ( IsValid( victim.sprintingSpriteTrail ) ) then
		SafeRemoveEntity( victim.sprintingSpriteTrail )
	end
	victim:RemovePotionTimers( )
	victim:ResetCopKillerStatus( )
	if ( victim:WasKilledInRoad( ) and ( attacker:IsVehicle( ) or ( attacker:IsPlayer( ) and attacker:InVehicle( ) ) ) ) then
		PrintMessage( HUD_PRINTCONSOLE, victim:Name( ) .. " was struck while standing in the road!" )
		roadkill = true
	end
	if ( victim:WasKilledForHerb( ) ) then
		PrintMessage( HUD_PRINTCONSOLE, victim:Name( ) .. " was killed for a Herb!" )
	end
	if ( victim:IsPlayer( ) and victim:isCP( ) and attacker:IsPlayer( ) ) then 
		attacker:SetCopKiller( )
	end
	victim:SetDeathsWithoutRetribution( 0 )
	victim.teleSWEPDestination = nil
	victim:CurePoison( )
	victim:SetDisguised( nil, true )
	if ( victim:IsPlayer( ) and !victim:IsBot( ) ) then
		local isOnQuest, questStage = victim:IsOnQuest( "beast_hat_quest" )
		if ( isOnQuest ) then
			DarkRP.notify( victim, 1, 4, "You've failed the Beast Hat Quest." )
			victim:RemoveQuest( )
		end
	end
	if ( IsValid( attacker ) and attacker:IsVehicle( ) and IsValid( attacker:GetDriver( ) ) ) then
		attacker = attacker:GetDriver( )
	end
	local currentCrabQueen = SVNOOB_VARS:Get( "CrabQueen", true, "player", nil )
	victim:DidCrabQueenPerish( currentCrabQueen, attacker )
	if ( ( ( !IsValid( victim ) or !victim:IsPlayer( ) ) or ( !IsValid( attacker ) or !attacker:IsPlayer( ) ) ) )  then return end
	if ( victim:IsBot( ) or attacker:IsBot( ) ) then return end
	local mes = attacker:NiceInfo( true ) .. " has killed " .. victim:NiceInfo( true )
	NOOB_LOGGER:Log( NOOB_LOGGING_WARNING, mes, false )
	attacker:IsBountyKill( victim )
	victim:ClearTempWeapons( )
	victim.deathGodLength = CurTime( ) + 1
	if ( attacker:IsPacifist( ) and attacker ~= victim ) then
		attacker:RevokePacifism( )
	end
	victim.selfDefenseTable = { }
	local wasSelfDefense = false
	if ( victim ~= attacker ) then
		local shouldPunish = true
		if ( attacker:WasSelfDefense( victim ) ) then
			PrintMessage( HUD_PRINTCONSOLE, attacker:Name( ) .. " has killed " .. victim:Name( ) .. " in self defense!" )
			local mes = attacker:NiceInfo( true ) .. " has killed " .. victim:NiceInfo( true ) .. " in self defense"
			NOOB_LOGGER:Log( NOOB_LOGGING_WARNING, mes, false )
			attacker:ResetSelfDefense( victim )
			wasSelfDefense = true
			shouldPunish = false
		end
		local didKillInnocent = attacker:DidHitmanKillInnocent( wasSelfDefense, victim )
		local bank = ents.FindByClass( "bank_button" )[ 1 ];
		if ( !didKillInnocent and attacker:Team( ) ~= TEAM_ZOMBIE ) then
			if ( !IsValid( bank ) or bank.GetRobber ~= attacker ) then
				if ( attacker:HasRevenge( victim ) and !attacker:isCP( ) ) then
					local mes = attacker:NiceInfo( true ) .. " has gotten revenge on " .. victim:NiceInfo( true )
					NOOB_LOGGER:Log( NOOB_LOGGING_WARNING, mes, false )
					PrintMessage( HUD_PRINTCONSOLE, attacker:Name( ) .. " has gotten revenge on " .. victim:Name( ) .. "!" )
					PrintMessage( HUD_PRINTCENTER, attacker:Name( ) .. " has gotten revenge on " .. victim:Name( ) .. "!" )
					attacker:RemoveRevenge( victim )
					shouldPunish = false
					attacker:SetDeathsWithoutRetribution( 0 )
					hook.Call( "OnPlayerGetRevenge", { }, attacker, victim )
				else
					local noRetribution, amt = victim:WasKillWithoutRetribution( attacker )
					if ( noRetribution ) then
						local tempAmount = amt + 1
						if ( tempAmount > 3 ) then
							victim:PrintMessage( HUD_PRINTCENTER, attacker:Name( ) .. " has killed you ".. tempAmount .. " times without retribution!" )
							victim:SetDeathsWithoutRetribution( tempAmount )
						end
						victim:IncrementRetributionAmount( attacker, amt )
					else
						victim:InsertNewRevenge( attacker )
					end
				end
			end
		end
		if ( attacker:IsClanAtWar( victim:IsInClan( ) ) ) then
			PrintMessage( HUD_PRINTCONSOLE, attacker:Name( ) .. " has killed " .. victim:Name( ) .. " as part of their Clan War!" )
			hook.Call( "OnPlayerKillClanEnemy", { }, attacker, victim )
			shouldPunish = false
		end
		if ( victim:WasKilledDuringRobbery( ) ) then
			PrintMessage( HUD_PRINTCONSOLE, victim:Name( ) .. " was killed while inside the Bank during a robbery!" )
			hook.Call( "OnPlayerKillBankRobber", { }, attacker, victim )
			shouldPunish = false
		end
		if ( NOOBRP:IsPurgeOccuring( ) ) then
			if ( victim:IsCivilian( ) ) then
				PrintMessage( HUD_PRINTCONSOLE, attacker:Name( ) .. " killed the harmless Civilian, " .. victim:Name( ) .. ", during the Purge Event!" )
				victim.respawnTimeOverride = 3
				hook.Call( "OnPlayerPurgeKill", { }, attacker, victim, true )
			else
				PrintMessage( HUD_PRINTCONSOLE, attacker:Name( ) .. " has slain " .. victim:Name( ) .. " during the Purge Event!" )
				shouldPunish = false
				hook.Call( "OnPlayerPurgeKill", { }, attacker, victim, false )
			end
		end
		victim:AttemptZombieInfection( attacker )
		victim:WasCrabQueenKilled( currentCrabQueen, attacker )
		if not ( shouldPunish ) then return end
		/*if not roadkill then
			if attacker:IsMurderer() then
				local medBills = math.Round(attacker:getDarkRPVar("money") / 20)
				attacker:DisplayNotify( "You were charged 5% of your wealth ($" .. medBills .. ") (MURDERER TAX) for " .. victim:Name() .. "'s medical bills.", 6, "icon16/heart.png", COLOR_WHITE, nil, true, "N00BRP_2DIndicator_LobsterMiniText" )
				attacker:addMoney(-medBills)
			else
				local medBills = math.Round(attacker:getDarkRPVar("money") / 100)
				attacker:DisplayNotify( "You were charged 1% of your wealth ($" .. medBills .. ") for " .. victim:Name() .. "'s medical bills.", 6, "icon16/heart.png", COLOR_WHITE, nil, true, "N00BRP_2DIndicator_LobsterMiniText" )
				attacker:addMoney(-medBills)
			end
		end*/
		attacker.hasKilledPlayer = true
		if ( attacker:CheckIfMurderer( ) ) then
			local penaltyTime = SVNOOB_VARS:Get( "MurdererPenaltyTime", true, "number", 600 )
			NOOBRP.StatusTrackers:AddMurderer( attacker:SteamID( ), penaltyTime )
		end
		attacker:UpdateLastViolentAction( )
		attacker:UpdateLastCriminalAction( )
		attacker:AttemptIncrementKillCount( )
	end
end
hook.Add( "PlayerDeath", "N00BRP_PlayerDeathCheck_OnPlayerDeath", PlayerDeathCheck )

local function OnPlayerKillNPC( npc, attacker, inflictor )
	if ( !IsValid( attacker ) or !attacker:IsPlayer( ) ) then return end
	if ( npc.QuestObjective ) then
		local isOnQuest, questStage = attacker:IsOnQuest( "vial_retrieval_quest" )
		if ( isOnQuest and questStage == "stage_in_progress" ) then
			npc.QuestFunc( attacker )
		end
	end
	if ( npc:GetClass( ) == "npc_combine_s" and npc.adminSpawned ) then
		DarkRP.notify( attacker, NOTIFY_HINT, 4, "You were rewarded $5,000 for the kill." )
		attacker:addMoney( 5000 )
	elseif ( npc:GetClass( ) == "npc_vortigaunt" and npc.adminSpawned ) then
		DarkRP.notify( attacker, NOTIFY_HINT, 4, "You were rewarded $10,000 for the kill." )
		attacker:addMoney( 10000 )
	elseif ( string.find( npc:GetClass( ), "npc_headcrab" ) ) then
		DarkRP.notify( attacker, NOTIFY_HINT, 4, "You were rewarded $1,000 for the kill." )
		attacker:addMoney( 1000 )
	end
end
hook.Add( "OnNPCKilled", "N00BRP_OnPlayerKillNPC_OnNPCKilled", OnPlayerKillNPC )

local function OnScalePlayerDamage( ply, hitGroup, dmgInfo )
	if ( dmgInfo:GetAttacker( ):IsPlayer( ) and ply:IsWearingBackItem( "dreadwings" ) ) then
		local rndRoll = math.random( 1, 100 )
		if ( rndRoll <= 6 ) then
			local attacker = dmgInfo:GetAttacker( )
			if not ( attacker:IsOnFire( ) ) then
				local time = math.random( 3, 7 )
				attacker:Ignite( time )
				timer.Simple( time + 1, function( )
					if not ( IsValid( attacker ) ) then return end
					attacker:Extinguish( ) 
				end )
			end
		end
	end
	if ( ply.equippedRiotShield and ( dmgInfo:GetAttacker( ):IsPlayer( ) or dmgInfo:GetAttacker( ):GetClass( ) == "env_explosion" ) ) then
		local betweenNormal = ( dmgInfo:GetAttacker( ):GetPos( ) - ply:GetShootPos( ):GetNormal( ) )
		if ( dmgInfo:GetAttacker( ):IsPlayer( ) ) then
			betweenNormal = ( dmgInfo:GetAttacker( ):GetPos( ) - ply:GetShootPos( ) ):GetNormal( )
		end
		if ( dmgInfo:GetInflictor( ):GetClass( ) == "env_explosion" ) then
			betweenNormal = ( dmgInfo:GetInflictor( ):GetPos( ) - ply:GetShootPos( ) ):GetNormal( )
		end
		if ( ply:GetAimVector( ):DotProduct( betweenNormal ) > 0.7 ) then
			dmgInfo:ScaleDamage( 0 )
			return
		end
	end
	if ( IsValid( ply ) ) then
		if ( ply:IsInSafeZone( ) and NOOBRP:IsPurgeOccuring( ) ) then
			dmgInfo:ScaleDamage( 0 )
		end
	end
	if ( IsValid( dmgInfo:GetAttacker( ) ) and dmgInfo:GetAttacker( ):IsPlayer( ) ) then
		local attacker = dmgInfo:GetAttacker( )
		if ( attacker:Team( ) ~= TEAM_CRAB and attacker:GetModelScale( ) < 0.5 ) then
			dmgInfo:ScaleDamage( 0.05 )
		end
		if ( dmgInfo:GetAttacker( ):IsInSafeZone( ) and NOOBRP:IsPurgeOccuring( ) ) then
			dmgInfo:GetAttacker( ):ChatPrint( "You cannot attack within the Safe Zone!" )
			dmgInfo:ScaleDamage( 0 )
		end
	end
	if ( ply.deathGodLength and ply.deathGodLength > CurTime( ) ) then
		dmgInfo:ScaleDamage( 0 )
		return
	end
	if ( isfunction( ply.defensePotionFunc ) ) then
		ply.defensePotionFunc( dmgInfo )
		return
	end
	if not ( math.RandomChance( 4 ) ) then return end
	if ( hitGroup == HITGROUP_RIGHTLEG or hitGroup == HITGROUP_LEFTLEG ) then
		if ( ply:GetBodyPartInjured( ENUM_INJURIES_LEGS ) ) then return end
		local defaultWalkSpeed = SVNOOB_VARS:Get( "DefaultWalkSpeed" )
		ply:SetBodyPartInjured( ENUM_INJURIES_LEGS, true )
		ply:ChatPrint( "Your legs have been badly injured! You're having trouble moving." )
		ply:SetRunSpeed( defaultWalkSpeed )
		util.ExecuteDelayedFunction( ply, math.random( 3, 7 ), function( ply )
			if not ( ply:IsGhost( ) ) then ply:ChatPrint( "Your legs have recovered! You can move normally again." ) end
			ply:SetBodyPartInjured( ENUM_INJURIES_LEGS, false )
			ply:ApplyMovementSpeed( ) 
		end, ply )
	elseif ( hitGroup == HITGROUP_RIGHTARM or hitGroup == HITGROUP_LEFTARM ) then
		if ( ply:GetBodyPartInjured( ENUM_INJURIES_ARMS ) ) then return end
		if ( IsValid( ply:GetActiveWeapon( ) ) and ply:GetActiveWeapon( ):GetClass( ) == "riot_shield" ) then return end
		ply:SelectWeapon( "pocket" )
		ply:SetBodyPartInjured( ENUM_INJURIES_ARMS, true )
		ply:ChatPrint( "Your weapon has been shot out of your hands!" )
		util.ExecuteDelayedFunction( ply, math.random( 2, 6 ), function( ply )
			if not ( ply:IsGhost( ) ) then ply:ChatPrint( "Your arms feel much better." ) end
			ply:SetBodyPartInjured( ENUM_INJURIES_ARMS, false )
		end, ply )
	end
end
hook.Add( "ScalePlayerDamage", "N00BRP_OnScalePlayerDamage_ScalePlayerDamage", OnScalePlayerDamage )

local function AttemptMeleeThroughProp( attacker, ent, dmgInfo )
	if ( ent:GetCollisionGroup( ) == COLLISION_GROUP_WEAPON ) then
		local wep = attacker:GetActiveWeapon( )
		local multiTable = SVNOOB_VARS:Get( "MeleeWeaponMultipliers", true )
		multiTable = multiTable[wep:GetClass( )]
		if ( multiTable ) then
			local unscaledDamage = dmgInfo:GetDamage( ) / multiTable.prop
			local traceData = { }
			traceData.start = attacker:GetShootPos( )
			traceData.endpos = traceData.start + attacker:GetAimVector( ) * 64
			traceData.filter = { attacker, ent, wep }
			local traceRes = util.TraceLine( traceData )
			local hitPlayer = traceRes.Entity
			if ( IsValid( hitPlayer ) and hitPlayer:IsPlayer( ) ) then
				hitPlayer:TakeDamage( unscaledDamage, attacker, wep )
			end
		end
	end
end

local function OnEntityTakeDamage( ent, dmgInfo )
	local attacker = dmgInfo:GetAttacker( )
	if ( ent:IsPlayer( ) and dmgInfo:IsFallDamage( ) ) then
		if ( ent:IsWearingHat( "boot_hat" ) ) then
			dmgInfo:ScaleDamage( 0.5 )
		end
	end
	if ( attacker:GetClass( ) == "prop_physics" and IsValid( attacker:CPPIGetOwner( ) ) ) then
		dmgInfo:SetAttacker( dmgInfo:GetAttacker( ):CPPIGetOwner( ) )
	end
	if ( ent.IsGodded and ent:IsGodded( ) ) then dmgInfo:ScaleDamage( 0 ) return end
	if ( ent:IsPlayer( ) and ent:IsGhost( ) ) then dmgInfo:ScaleDamage( 0 ) return end
	if ( ent:IsPlayer( ) and ent:IsWearingHat( { "traffic_hat", "uncommon_traffic_hat", "rare_traffic_hat" } ) ) then
		if ( IsValid( attacker ) ) then
			if ( attacker:IsVehicle( ) or ( attacker:IsPlayer( ) and IsValid( attacker:GetVehicle( ) ) ) ) then
				dmgInfo:ScaleDamage( 0 )
				return
			end
		end
	end
	if ( IsValid( attacker ) and attacker:IsPlayer( ) ) then
		if ( IsValid( attacker:GetActiveWeapon( ) ) and ent:GetClass( ) == "prop_physics" ) then
			AttemptMeleeThroughProp( attacker, ent, dmgInfo )
		end
		if ( attacker:IsPacifist( ) and dmgInfo:GetDamageType( ) ~= DMG_FALL ) then
			local fragilePacifism = SVNOOB_VARS:Get( "FragilePacifismEnabled", true )
			if ( fragilePacifism ) then
				attacker:RevokePacifism( )
			elseif ( ent:IsNPC( ) and ent.QuestObjective ~= "vial_retrieval_quest" ) then
				attacker:RevokePacifism( )
			end
		end
		if ( ent:GetClass( ) == "prop_physics" ) then
			local propOwner = ent:CPPIGetOwner( )
			if ( IsValid( propOwner ) and propOwner:IsPlayer( ) ) then
				propOwner:AttemptFlagSelfDefense( attacker, dmgInfo:GetDamage( ) )
			end
		elseif ( ent:IsVehicle( ) ) then
			local vehicleOwner = ent:getDoorOwner( )
			if ( IsValid( vehicleOwner ) ) then
				vehicleOwner:AttemptFlagSelfDefense( attacker, dmgInfo:GetDamage( ) )
			end
		end
	end
	if ( dmgInfo:GetDamageType( ) ~= 17 and dmgInfo:GetDamageType( ) ~= DMG_VEHICLE ) then return end
	if not ( ent:IsPlayer( ) ) then return end
	if ( ent:IsGhost( ) ) then dmgInfo:ScaleDamage( 0 ) end
end
hook.Add( "EntityTakeDamage", "N00BRP_OnEntityTakeDamage_EntityTakeDamage", OnEntityTakeDamage )

local function OnPlayerHurt( victim, attacker, healthRemaining, dmgTaken )
	if ( attacker:IsVehicle( ) and healthRemaining < 0 ) then victim.killedByVehicle = true end
	if not ( attacker:IsPlayer( ) ) then return end
	victim:AttemptFlagSelfDefense( attacker, dmgTaken )
end
hook.Add( "PlayerHurt", "N00BRP_OnPlayerHurt_PlayerHurt", OnPlayerHurt )

local function CanPlayerDemote( ply, target, reason )
	if not ( IsValid( target ) ) then return false, "That player doesn't exist!" end
	local tarTeam = target:Team( )
	if ( team.IsCivilProtection( tarTeam ) ) then
		if ( ply.policeDemoteBlacklist and ply.policeDemoteBlacklist[target:SteamID( )] ) then
			local time = ply.policeDemoteBlacklist[target:SteamID( )]
			if ( time < CurTime( ) ) then
				ply.policeDemoteBlacklist[target:SteamID( )] = nil
			else
				return false, "That Cop arrested you for trespassing in the Nexus, can't demote them for another " .. string.NiceTime( time - CurTime( ) ) .. "!"
			end
		end
	end
	if ( tarTeam == TEAM_MAYOR or tarTeam == TEAM_COOK or tarTeam == TEAM_FOREMAN ) then
		local graceTime = SVNOOB_VARS:Get( "DisallowDemoteGraceTime", true, "number", 300 )
		if ( target.jobChangeTime + graceTime > CurTime( ) ) then
			return false, "That job cannot be demoted within the first five minutes of changing!"
		end
	end
	if ( tarTeam == TEAM_ZOMBIE ) then
		return false, "You're just going to have to kill the fucker."
	elseif ( tarTeam == TEAM_FOREMAN ) then
		local drillEnt = target.foremanThumperDrill
		if ( IsValid( drillEnt ) ) then
			return false, "You cannot demote a Mining Foreman while their drill is spawned."
		end
	elseif ( tarTeam == TEAM_HITMAN or tarTeam == TEAM_CRAB ) then
		return false, "That job cannot be demoted."
	end
end
hook.Add( "canDemote", "N00BRP_CanPlayerDemote_canDemote", CanPlayerDemote )

local function AttemptCustomEntityPurchase( ply, ent )
	if ( ply:IsGhost( ) ) then return end
	if ( ent.ent == "money_printer" or ent.ent == "adv_money_printer" or ent.ent == "basic_money_printer" ) then
		local printerLimit = SVNOOB_VARS:Get( "MaxMoneyPrinters", true, "number", 1 )
		local currentCount = ply:CountMultipleEntities( "money_printer", "adv_money_printer", "basic_money_printer" )
		currentCount = currentCount + ply:GetTrunkEntityClassAmount( "money_printer" )
		currentCount = currentCount + ply:GetTrunkEntityClassAmount( "basic_money_printer" )
		currentCount = currentCount + ply:GetTrunkEntityClassAmount( "adv_money_printer" )
		currentCount = currentCount + ply:GetBackpackEntityClassAmount( "money_printer" )
		currentCount = currentCount + ply:GetBackpackEntityClassAmount( "basic_money_printer" )
		currentCount = currentCount + ply:GetBackpackEntityClassAmount( "adv_money_printer" )
		if ( currentCount >= printerLimit ) then
			ply:ErrorNotify( "You've hit the Money Printer limit!" )
			return false
		end
		if ( ent.ent == "adv_money_printer" ) then
			if ( NOOBRP_SkillAlgorithms:CalculatePrinting( ply )["CurrentLevel"] < 10 ) then
				ply:ErrorNotify( "You must reach Printing Level 10 to buy that." )
				return false
			end
		end
	elseif ( ent.ent == "thumper_drill" ) then
		if game.GetMap( ) == "rp_evocity_v2d_updated" then
			local traceRes = ply:RangeEyeTrace( 256 )
			if ( traceRes.HitPos:IsInBox( Vector( 2438, -8745, 64 ), Vector( 3734, -6684, 543 ) ) ) then
				DarkRP.notify( ply, 1, 4, "You can only spawn your drill on grass." )
				return false
			end
			if ( traceRes.HitTexture ~= "**displacement**" and traceRes.MatType ~= 68 ) then
				DarkRP.notify( ply, 1, 4, "You can only spawn your drill on grass." )
				return false
			end
		end
		return !util.CheckCustomEntLimit( ent.ent, ply, "ThumperDrillLimit", "Thumper Drill" )
	end
end
hook.Add( "canBuyCustomEntity", "N00BRP_AttemptCustomEntityPurchase_canBuyCustomEntity", AttemptCustomEntityPurchase )

local function AttemptVehiclePurchase( ply, veh )
	if ( game.GetMap( ) == "lair_of_the_Beast8" ) then
		return false, false, "You cannot use vehicles here!"
	end
	if ( ply:IsGhost( ) ) then return false end
	if ( ply:GetVehicleCount( ) >= 1 ) then
		return false, false, "You hit the Vehicle limit!"
	else
		if ( ply:canAfford( veh.price ) ) then
			ply:SetVehicleCount( ply:GetVehicleCount( ) + 1 )
			return true
		end
		return false, false, "You cannot afford that Vehicle!"
	end
end
hook.Add( "canBuyVehicle", "N00BRP_AttemptVehiclePurchase_canBuyVehicle", AttemptVehiclePurchase )

local function ShouldStoreWeapon( ply, wep )
	if ( ply:IsGhost( ) ) then
		return false
	end
	if ( ply:Team( ) == TEAM_ZOMBIE and ( IsValid( wep ) and wep:GetClass( ) ~= "weapon_crowbar" ) ) then
		return false
	end
	local wepData = noob_WeaponIndex:Get( wep:GetClass( ) )
	if ( wepData and ( ply:IsCivilian( ) and !( wepData.citizen ) ) ) then return false end
	if ( wepData and ( ply:IsCrab( ) and !( wepData.crab ) ) ) then return false end
	ply:StoreTempWeapon( wep:GetClass( ) )
end
hook.Add( "PlayerCanPickupWeapon", "N00BRP_ShouldStoreWeapon_PlayerCanPickupWeapon", ShouldStoreWeapon )

local function CanDropWeapon( ply, wep )
	if not ( IsValid( wep ) ) then return false end
	local wepClass = wep:GetClass( )
	local weaponBlacklist = { "weapon_physcannon", "weapon_physgun", "gmod_tool", "gmod_camera", "pocket", "keys", "weapon_keypadchecker", "weapon_rpg", "weapon_ar2" }
	weaponBlacklist = table.CleanMerge( RPExtraTeams[ply:Team( )].weapons, weaponBlacklist )
	for index, wep in ipairs ( weaponBlacklist ) do
		if ( wepClass == wep ) then
			return false
		end
	end
	for index, wepTbl in ipairs ( ply:getDarkRPVar( "PermWeapons" ) ) do
		if ( wepClass == wepTbl.class ) then
			return false
		end
	end
	if ( ply:HasPurgeDurationItem( wepClass ) ) then
		return false
	end
	if ( ply:HasInRentLoadout( wepClass ) ) then
		return false
	end
	ply:RemoveTempWeapon( wepClass )
	return true
end
hook.Add( "canDropWeapon", "N00BRP_ShouldDropWeapon_canDropWeapon", CanDropWeapon )

local function OnPlayerEquipWeapon( ply, oldWeapon, newWeapon )
	if ( ply:GetBodyPartInjured( ENUM_INJURIES_ARMS ) and !ply.aboutToGhost and !ply:IsGhost( ) ) then
		DarkRP.notify( ply, 1, 4, "Your arms are in too much pain to equip a weapon." )
		return true
	end
	if ( newWeapon.Base == "base_hat" ) then
		if ( ply:getDarkRPVar( "HatClass" ) ) then
			ply:UnequipHat( )
		end
		if ( newWeapon.EquipFunc ) then
			newWeapon.EquipFunc( ply )
		end
	elseif ( newWeapon.Base == "base_backitem" ) then
		if ( ply:getDarkRPVar( "BackItemClass" ) ) then
			ply:UnequipBackItem( )
		end 
		if ( newWeapon.EquipFunc ) then
			newWeapon.EquipFunc( ply )
		end
	end
end
hook.Add( "PlayerSwitchWeapon", "N00BRP_OnPlayerEquipWeapon_PlayerSwitchWeapon", OnPlayerEquipWeapon )

local function UnEquipOnPlayerDeath( ply, dmgInflictor, entAttacker )
	ply:UnequipHat( )
	ply:UnequipBackItem( )
end
hook.Add( "PlayerDeath", "N00BRP_UnEquipOnPlayerDeath_PlayerDeath", UnEquipOnPlayerDeath )

local function CanPlayerWant( target, ply, reason )
	if not ( IsValid( target ) ) then return end
	if ( target:isCP( ) ) then
		return false, "You cannot want fellow law enforcement officers!"
	end
	if ( target:Team( ) == TEAM_ZOMBIE ) then
		return false, "JUST KILL THE MOTHERFUCKER!"
	end
	if not ( ply:isCP( ) ) then
		return false, "You must be a cop in order to arrest people!"
	end
	return true
end
hook.Add( "canWanted", "N00BRP_CanPlayerWant_canWanted", CanPlayerWant )

local function CanRequestWarrant( target, ply, reason )
	if ( ply:IsGhost( ) ) then return false, "You can't request a warrant while dead!" end
	if ( ply:isCP( ) ) then return true end
end
hook.Add( "canRequestWarrant", "N00BRP_CanRequestWarrant_canRequestWarrant", CanRequestWarrant )

local function CanRequestHit( hitman, customer, target, price )
	if ( customer:HasRevenge( target ) ) then
		if ( !IsValid( hitman ) or !IsValid( customer ) or !IsValid( target ) ) then return end
		if ( IsValid( hitman:getHitTarget( ) ) ) then
			DarkRP.notify( customer, 1, 4, hitman:Name( ) .. " is already assigned a hit." )
			return false, ""
		end
		hitman:placeHit( customer, target, price )
	else
		DarkRP.notify( customer, 1, 4, "You must have revenge on that player to request a hit!" )
	end
	return false, ""
end
hook.Add( "canRequestHit", "N00BRP_CanRequestHit_canRequestHit", CanRequestHit )

local function HitmanAcceptedHit( hitman, target, customer )
	if ( customer:HasRevenge( target ) ) then
		hitman.playerHitmanContract = target
		customer:RemoveRevenge( target )
		DarkRP.notify( customer, 2, 4, hitman:Name( ) .. " has accepted your hit on " .. target:Name( ) .. "!" )
		local mes = hitman:NiceInfo( ) .. " has accepted a hit from " .. customer:NiceInfo( ) .. " on " .. target:NiceInfo( )
		NOOB_LOGGER:Log( NOOB_LOGGING_WARNING, mes, false )
	end
end
hook.Add( "onHitAccepted", "N00BRP_HitmanAcceptedHit_onHitAccepted", HitmanAcceptedHit )

local function HitmanFailedHit( hitman, target, customer )
	hitman.playerHitmanContract = nil
end
hook.Add( "onHitFailed", "N00BRP_HitmanFailedHit_onHitFailed", HitmanFailedHit )

local function HitmanCompletedHit( hitman, target, customer )
	PrintMessage( HUD_PRINTCENTER, hitman:Name( ) .. " has taken a hit out on " .. target:Name( ) .. " courtesy of " .. customer:Name( ) .. "!" )
end
hook.Add( "onHitCompleted", "N00BRP_HitmanCompletedHit_onHitCompleted", HitmanCompletedHit )

local function ModifySalary( ply, amt )
	if ( ply:IsGhost( ) ) then return false, "You can't receive a paycheck while dead!", 0 end
	if ( ply.isMarkedAFK ) then return false, "You cannot receive a paycheck while AFK!", 0 end
	local peacefulPrc = math.Clamp( ( ply:GetLastViolentAction( ) + 300 - CurTime( ) ) / 300, 0, 1 )
	local bonusAmt = math.floor( math.Clamp( amt - ( amt * peacefulPrc ), 0, amt ) )
	util.ExecuteDelayedFunction( ply, 0.1, function( ply, bonusAmt )
		DarkRP.notify( ply, 1, 4, "You've received a $" .. bonusAmt .. " bonus for your peaceful behavior." )
		ply:addMoney( bonusAmt ) 
	end, ply, bonusAmt )
	if ( ply:GetRank( ) == "VIP" ) then
		local vipBonus = amt * 2
		return false, "You've received your salary of $" .. vipBonus, vipBonus
	else
		return false, "You've received your salary of $" .. amt, amt
	end
end
hook.Add( "playerGetSalary", "N00BRP_ModifySalary_playerGetSalary", ModifySalary )

local function FireBulletsThroughProp( ent, data )
	if ( IsValid( data.Attacker ) and IsValid( data.Attacker:GetActiveWeapon( ) ) ) then
		if ( data.Attacker:GetActiveWeapon( ):GetClass( ) == "dart_gun" ) then return end
	end
	local bulletDir = data.Dir
	local bulletDamage = data.Damage
	local attacker = data.Attacker
	data.Callback = function( ent, traceRes, dmgInfo )
		if ( IsValid( traceRes.Entity ) and traceRes.Entity:GetClass( ) == "prop_physics" ) then
			local prop = traceRes.Entity
			if ( prop:GetCollisionGroup( ) == COLLISION_GROUP_WEAPON ) then
				local traceData = { }
				traceData.start = dmgInfo:GetDamagePosition( )
				traceData.endpos = traceData.start + bulletDir * 16000
				traceData.filter = { ent, prop }
				local traceRes = util.TraceLine( traceData )
				if ( IsValid( traceRes.Entity ) and traceRes.Entity:IsPlayer( ) ) then
					local hitPlayer = traceRes.Entity
					hitPlayer:TakeDamage( bulletDamage, attacker, attacker:GetActiveWeapon( ) )
				end
			end
		end
	end
	return true
end
hook.Add( "EntityFireBullets", "N00BRP_FireBulletsThroughProp_EntityFireBullets", FireBulletsThroughProp )

local function CanPlayerSpawnProp( ply, model )
	// Ensure there is no possibility of bypassing the whitelist... hopefully.
	ply.nextPropSpawn = ply.nextPropSpawn or 0
	if ( game.GetMap( ) == "lair_of_the_Beast8" ) then ply:ErrorNotify( "You cannot spawn props in here!" ) return false end
	if ( ply:IsGhost( ) ) then return false end
	if ( ply:isArrested( ) ) then return false end
	if ( ply.isTasered ) then return false end
	if ( ply:InVehicle( ) ) then return false end
	if ( ply:Team( ) == TEAM_ZOMBIE ) then return false end
	if ( string.find( model, [[\]] ) or string.find( model, "/../" ) ) then return false end
	if not ( noob_ValidPropList[model] ) then return false end
	if ( ply:ReachedPropLimit( ) ) then DarkRP.notify( ply, 1, 4, "You reached the prop limit!" ) return false end
	local propPrice = noob_ValidPropList[model]
	if not ( ply:canAfford( propPrice ) ) then DarkRP.notify( ply, 1, 4, "You can't afford that prop!" ) return false end
	if ( ply.nextPropSpawn > CurTime( ) ) then return false end
	ply.nextPropSpawn = CurTime( ) + 1
	ply:addMoney( -propPrice )
	hook.Call( "OnPlayerBuyProp", { }, ply, model, propPrice )
	local mes = ply:NiceInfo( true ) .. " has spawned [ " .. model .. " ] at: " .. tostring( ply:GetEyeTrace( ).HitPos )
	NOOB_LOGGER:Log( NOOB_LOGGING_WARNING, mes, false )
	return true
end
hook.Add( "PlayerSpawnProp", "N00BRP_CanPlayerSpawnProp_PlayerSpawnProp", CanPlayerSpawnProp )

local function OnPlayerAttemptSuicide( ply )
	local crabQueen = SVNOOB_VARS:Get( "CrabQueen", true, "player", nil )
	if ( ply:IsGhost( ) or ply:GetObserverMode( ) ~= OBS_MODE_NONE or ply:isWanted( ) or
	( ply:Team( ) == TEAM_CRAB and ply == crabQueen ) or ply.isTasered or ply:IsFrozen( ) or ply:isArrested( ) ) then
		return false
	else
		return true
	end
end
hook.Add( "CanPlayerSuicide", "N00BRP_OnPlayerAttemptSuicide_CanPlayerSuicide", OnPlayerAttemptSuicide )

local function OnPlayerSellVehicle( ply, ent )
	ply:SetVehicleCount( ply:GetVehicleCount( ) - 1 )
	ent.playerLastUsed = CurTime( )
end
hook.Add( "playerSellVehicle", "N00BRP_OnPlayerSellVehicle_playerSellVehicle", OnPlayerSellVehicle )

local function OnPlayerBoughtVehicle( ply, ent, cost )
	ply:SetVehicleCount( ply:GetVehicleCount( ) + 1 )
	ent.playerLastUsed = CurTime( )
end
hook.Add( "playerBoughtVehicle", "N00BTESTTEST", OnPlayerBoughtVehicle )

local function OnPlayerBuyVehicle( ply, ent )
	if ( ply:ReachedVehicleLimit( ) ) then return false, "", true end
	return true, "", true
end
hook.Add( "playerBuyVehicle", "N00BRP_OnPlayerBuyVehicle_playerbuyVehicle", OnPlayerBuyVehicle )

local function ShowPlayerMenu( ply )
	ply:ConCommand( "rp_playermenu" )
end
hook.Add( "ShowHelp", "N00BRP_ShowPlayerMenu_ShowHelp", ShowPlayerMenu )

local function OnEntitySpawned( ent )
	timer.Simple( 0.25, function( )
		if not ( IsValid( ent ) ) then return end
		if ( ent:IsVehicle( ) and !ent.isPassengerSeat ) then
			if not ( noob_VehicleIndex:IsUnColorableVehicle( ent:GetModel( ) ) or ent.EMV ) then
				ent.currentColor = noob_VehicleIndex:RandomColor()
				ent:SetColor( ent.currentColor )
			end
			local vehData = noob_VehicleIndex:Get( ent:GetModel( ) )
			if ( vehData ) then
				ent.passengerSeats = ent.PassengerSeats or { }
				if ( vehData.passengerSeats ) then
					for index, seatData in ipairs ( vehData.passengerSeats ) do
						local vehAng = ent:GetAngles( )
						local seatOffset = ( vehAng:Forward( ) * seatData.pos.x ) + ( vehAng:Right( ) * seatData.pos.y ) + ( vehAng:Up( ) * seatData.pos.z )
						local vehSeat = ents.Create( "prop_vehicle_prisoner_pod" )
						vehSeat:SetModel( "models/nova/jeep_seat.mdl" )
						vehSeat:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
						vehSeat:SetKeyValue( "limitview", "0" )
						local ang = ent:GetAngles( )
						vehSeat:SetAngles( ang + seatData.ang )
						vehSeat:SetPos( ent:GetPos( ) + seatOffset )
						vehSeat:Spawn( )
						vehSeat:Activate( )
						vehSeat:SetParent( ent )
						vehSeat.isPassengerSeat = true
						vehSeat.seatIndex = index + 1
						if ( vehData.hideSeats ) then
							vehSeat:SetNoDraw( true )
						end
						table.insert( ent.passengerSeats, vehSeat )
					end
				end
			end
			ent:keysLock( )
			ent.playerLastUsed = CurTime( )
			if ( !ent.isPassengerSeat and !ent.isPermaVehicle ) then
				noob_VehicleIndex:TrackVehicle( ent )
			end
		end
	end )
end
hook.Add( "OnEntityCreated", "N00BRP_OnEntitySpawned_OnEntityCreated", OnEntitySpawned )

local function OnEntityRemoved( ent )
	if not ( IsValid( ent ) ) then return end
	if not ( ent:IsVehicle( ) ) then return end
	if ( ent:GetClass( ) == "prop_vehicle_prisoner_pod" ) then return end
	ent.passengerSeats = ent.passengerSeats or { }
	if ( ent.passengerSeats and istable( ent.passengerSeats ) and #ent.passengerSeats > 0 ) then
		for index, seat in ipairs ( ent.passengerSeats ) do
			SafeRemoveEntity( seat )
		end
	end
end
hook.Add( "EntityRemoved", "N00BRP_OnEntityRemoved_EntityRemoved", OnEntityRemoved )

local function CanPlayerExitVehicle( veh, ply )
	return true
end
hook.Add( "CanExitVehicle", "sdfsdfafdfadsfwe", CanPlayerExitVehicle )

local function OnPlayerUseEntity( ply, ent )
    if not ( ent:IsVehicle( ) ) then return end
    //if ent:IsLocked( ) and not ( IsValid( ent:getDoorOwner( ) ) and ent:getDoorOwner( ) == ply ) then return end
    if ( !ent.passengerSeats or #ent.passengerSeats <= 0 ) then return end
    ply.nextVehicleUse = ply.nextVehicleUse or 0
    if ( ply.nextVehicleUse > CurTime( ) ) then return end
    ply.nextVehicleUse = CurTime( ) + 1
    ply.nextCanEnterVehicle = ply.nextCanEnterVehicle or 0
    if ( ply.nextCanEnterVehicle > CurTime( ) ) then return end
 	ply.lastEjectedFromVehicle = ply.lastEjectedFromVehicle or 0
    if ( !ent:IsLocked( ) and !IsValid( ent:GetDriver( ) ) ) then
    	ply:EnterVehicle( ent )
    	return
    end
    local attemptSeat = ent.passengerSeats[ math.random( #ent.passengerSeats ) ]
    local distanceTable = { }
    for index, seat in ipairs ( ent.passengerSeats ) do
    	if ( !IsValid( seat ) or IsValid ( seat:GetDriver( ) ) ) then continue end
    	table.insert( distanceTable, { seatEnt = seat, seatDist = ply:GetPos( ):Distance( seat:GetPos( ) ) } )
    end
    if ( !distanceTable or #distanceTable <= 0 ) then return end
    table.SortByMember( distanceTable, "seatDist", true )
    ply:EnterVehicle( distanceTable[1].seatEnt )
    ent.playerLastUsed = CurTime( )
end
hook.Add( "PlayerUse", "N00BRP_OnPlayerUseEntity_PlayerUse", OnPlayerUseEntity )

local function RemoveVehicleOnDisconnect( ply )
	if ( !noob_VehicleIndex.spawnedVehicles or #noob_VehicleIndex.spawnedVehicles <= 0 ) then return end
	for index, veh in ipairs ( noob_VehicleIndex.spawnedVehicles ) do
		if ( IsValid( veh.isPermaVehicle ) and veh.isPermaVehicle == ply ) then
			veh:Destroy( )
			table.remove( noob_VehicleIndex.spawnedVehicles, index )
		elseif ( veh:getDoorOwner( ) == ply ) then
			veh:keysUnOwn( )
			veh.playerLastUsed = CurTime( )
		end
	end
end
hook.Add( "PlayerDisconnected", "N00BRP_RemoveVehicleOnDisconnect_PlayerDisconnected", RemoveVehicleOnDisconnect )

local function OnPlayerLeaveVehicle( ply, veh )
	ply.IsInVehicle = false;
	ply.nextCanEnterVehicle = CurTime( ) + 1
	veh.playerLastUsed = CurTime( )
	veh:CeaseGasDrain( )
	local origin = veh
	local seatIndex = 1
	if ( veh.isPassengerSeat and IsValid( veh:GetParent( ) ) ) then
		if veh.seatIndex then seatIndex = veh.seatIndex end
		veh = veh:GetParent( )
	end
	if ( noob_VehicleIndex:Get( veh:GetModel( ) ) ) then
		local vehData = noob_VehicleIndex:Get( veh:GetModel( ) )
		if ( vehData.customExits ) then

			local exit = vehData.customExits[seatIndex]
			local finalPos = Vector()
			local dir = 0

			if exit then 
				local lpos = Vector( exit[1], exit[2],  exit[3] )
				finalPos = veh:LocalToWorld( lpos )
			else
				local gpos = origin:GetPos()
				local lpos = veh:WorldToLocal( gpos )
				lpos.x = lpos.x * 6
				finalPos = veh:LocalToWorld( lpos )
			end
			local tr = {}
			tr.start = finalPos
			tr.endpos = veh:GetPos()
			tr.filter = { ply, veh }
			local traceres = util.TraceEntity(tr, ply)
			if not traceres.Hit then
				ply:SetPos( finalPos )
			else
				return false
			end
		end
	end
end
hook.Add( "PlayerLeaveVehicle", "N00BRP_OnPlayerLeaveVehicle_PlayerLeaveVehicle", OnPlayerLeaveVehicle )

local function OnPlayerEnteredVehicle( ply, veh, role )
	ply.IsInVehicle = true;
	ply.lastEnteredVehicle = ply.lastEnteredVehicle or CurTime( )
	local vehIndex = veh:EntIndex( )
	if ( noob_VehicleIndex:Get( veh:GetModel( ) ) ) then
		if not ( veh:IsGasDraining( ) ) then
			veh:InitiateGasDrain( )
		end
	end
end
hook.Add( "PlayerEnteredVehicle", "N00BRP_OnPlayerEnteredVehicle_PlayerEnteredVehicle", OnPlayerEnteredVehicle )

local function OnPlayerKeysLocked( ent )
	if ( ent:IsVehicle( ) ) then ent.playerLastUsed = CurTime( ) end
end
hook.Add( "onKeysLocked", "N00BRP_OnPlayerKeysLocked_onKeysLocked", OnPlayerKeysLocked )

local function OnPlayerKeysUnlocked( ent )
	if ( ent:IsVehicle( ) ) then ent.playerLastUsed = CurTime( ) end
end
hook.Add( "onKeysUnlocked", "N00BRP_OnPlayerKeysUnlocked_onKeysUnlocked", OnPlayerKeysUnlocked )

local function OnPlayerAttemptArrest( cp, ply )
	if ( ply:IsGhost( ) ) then return false, "" end
	if ( ply:GetObserverMode( ) ~= OBS_MODE_NONE ) then return false, "" end
	if ( ply:Team( ) == TEAM_ZOMBIE ) then
		return false, "You're just going to have to kill the fucker!"
	end
end
hook.Add( "canArrest", "N00BRP_OnPlayerAttemptArrest_canArrest", OnPlayerAttemptArrest )

local function OnPlayerAttemptVehicleEntry( ply, veh, role )
	 if ( ply.lastEjectedFromVehicle and ply.lastEjectedFromVehicle + 10 > CurTime( ) ) then
    	DarkRP.notify( ply, 1, 4, "You can't enter a vehicle immediately after recently being ejected." )
    	return false
	elseif ( ply.VehicleEnterWait and ply.VehicleEnterWait.Delay and ply.VehicleEnterWait.Vehicle ) then
		if ( ply.VehicleEnterWait.Delay > CurTime() and ply.VehicleEnterWait.Vehicle == veh ) then
			DarkRP.notify( ply, 1, 4, Format( "You need to wait %d second(s) before entering in the vehicle again.", math.floor( ply.VehicleEnterWait.Delay - CurTime() ) ) );
			return false;
		end
	elseif ( ply.isTasered ) then
		DarkRP.notify( ply, 1, 4, "You are unable to enter the vehicle." );
		return false;
	elseif ( ply:Team( ) == TEAM_ZOMBIE ) then
		DarkRP.notify( ply, 1, 4, "Zombies don't know how to operate vehicles!" )
		return false
	end
end
hook.Add( "CanPlayerEnterVehicle", "N00BRP_OnPlayerAttemptVehicleEntry_CanPlayerEntryVehicle", OnPlayerAttemptVehicleEntry )

local function AddEventMeterPVS( ply )
	if not ( ply:IsWearingHat( "golden_beast_hat" ) ) then return end
	if ( ply:IsGhost( ) or !ply:Alive( ) ) then return end
	local eventMeter = ents.FindByClass( "event_meter" )
	if ( istable( eventMeter ) and IsValid( eventMeter[1] ) ) then
		eventMeter = eventMeter[1]
		AddOriginToPVS( eventMeter:GetPos( ) )
	end
end
hook.Add( "SetupPlayerVisibility", "N00BRP_SetupPlayerVisibility_AddEventMeterPVS", AddEventMeterPVS )

local toolWhitelist = { ["remover"] = true, ["camera"] = true, ["keypad"] = true, ["fading_door"] = true }
local toolAdminWhitelist = { ["colour"] = true, ["material"] = true, ["light"] = true }
local toolSAWhitelist = { ["box_creator"] = true, ["info_display"] = true, ["spawnpoint_creator"] = true }
local function RestrictTools( ply, tr, tool )
	if ( !toolWhitelist[tool] and !toolAdminWhitelist[tool] and !toolSAWhitelist[tool] ) then return false end
	if ( !ply:IsAdmin( ) and toolAdminWhitelist[tool] ) then return false end
	if ( !ply:IsSuperAdmin( ) and toolSAWhitelist[tool] ) then return false end
	if ( ( tool == "remover" or tool == "fading_door" ) and IsValid( tr.Entity ) and ( !isfunction( tr.Entity.CPPIGetOwner ) or !IsValid( tr.Entity:CPPIGetOwner( ) ) ) ) then return false end
	if ( tool == "remover" and IsValid( tr.Entity ) and tr.Entity:IsVehicle( ) ) then return false end
	if ( tool == "remover" and ply:IsAdmin( ) and IsValid( tr.Entity ) and tr.Entity:GetClass( ) == "prop_physics" and isfunction( tr.Entity.CPPIGetOwner ) and IsValid( tr.Entity:CPPIGetOwner( ) ) ) then return true end
end
hook.Add( "CanTool", "N00BRP_CanTool_RestrictTools", RestrictTools )

/*
local niceWords = { "charming lad", "attractive fellow", "sexy mama", "neogreen", "bodacious dude", "nice chap", "awesome guy", "my future lover", "strapping lad" }
local naughtyWords = { "nigger", "faggot", "nigg3r", "fag", "f@g", "f@gg0t", "fagg", "niggger", "niggerr", "n!gg3r", "faglord" }
local function ChatFilter( ply, text, public )
	local newText = text
	local foundBadWord = false
	for index, word in ipairs ( naughtyWords ) do
		if ( string.find( string.lower( text ), string.lower( word ) ) ) then
			newText = string.Replace( newText, word, niceWords[math.random(#niceWords)] )
			foundBadWord = true
		end
	end
	if ( foundBadWord ) then
		ply:Say( newText )
		return ""
	end
end
hook.Add( "PlayerSay", "N00BRP_PlayerSay_ChatFilter", ChatFilter )
*/
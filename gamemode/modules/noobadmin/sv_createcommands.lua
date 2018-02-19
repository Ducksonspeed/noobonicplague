local function doplayercheck( val )
	local pl = false;

	for k, v in pairs( player.GetAll() ) do
		if ( tonumber( val ) == v:UserID() or val == v:SafeUniqueID( ) or val == v:SteamID() or val == v:Nick() or v:Nick():lower():find( val:lower() ) ) then
			pl = v;
			break;
		end
	end
	
	return pl;
end

local npcMeta = FindMetaTable( "NPC" )
function npcMeta:CreateTargetCheckingTimer( )
	local entIndex = self:EntIndex( )
	timer.Create( entIndex .. ":NPCTargetCheckTimer", 2, 0, function( )
		if not ( IsValid( self ) ) then timer.Destroy( entIndex .. ":NPCTargetCheckTimer" ) return end
		local curTarget = self:GetEnemy( ) or self:GetTarget( )
		if ( IsValid( curTarget ) and curTarget:IsPlayer( ) and ( curTarget:IsGhost( ) or curTarget:GetObserverMode( ) ~= OBS_MODE_NONE ) ) then
			self:AddEntityRelationship( curTarget, D_NU, 99 )
		end
		local nearbyEnts = ents.FindInBox( ClampWorldVector( self:GetPos( ) - Vector( 1024, 1024, 128 ) ), ClampWorldVector( self:GetPos( ) + Vector( 1024, 1024, 128 ) ) )
		if ( table.IsValid( nearbyEnts, true ) ) then
			for index, ent in ipairs ( nearbyEnts ) do
				if ( IsValid( ent ) and ent:IsPlayer( ) and !ent:IsGhost( ) and ent:GetObserverMode( ) == OBS_MODE_NONE ) then
					self:SetTarget( ent )
					self:AddEntityRelationship( ent, D_HT, 99 )
					break
				end
			end
		end
	end )
end

NOOB_ADMIN:CreateCommand( "removenpcs", "admin", function( _self, className, allNPCs )
	local entTable = ents.FindByClass( string.lower( className ) )
	if ( table.IsValid( entTable, true ) ) then
		local ownedNPCs = { }
		local entCount = nil
		local allNPCs = tobool( allNPCs )
		for index, ent in ipairs ( entTable ) do
			if ( ent.adminSpawned == _self ) then
				if ( allNPCs ) then
					entCount = entCount or 0
					entCount = entCount + 1
					SafeRemoveEntity( ent )
				else
					table.insert( ownedNPCs, { npc = ent, time = ent.spawnedTime } )
				end
			end
		end
		if ( allNPCs ) then
			if ( entCount ) then
				DarkRP.notify( _self, NOTIFY_HINT, 4, "You removed ( " .. tostring( entCount ) .. " ) instances of [" .. className .. "]" )
			else
				_self:ChatPrint( "Could not find NPCs with that class spawned by you." )
			end
			return
		end
		if ( table.IsValid( ownedNPCs, true ) ) then
			table.SortByMember( ownedNPCs, "time" )
			SafeRemoveEntity( ownedNPCs[1].npc )
			DarkRP.notify( _self, NOTIFY_HINT, 4, "You removed your last spawned [" .. className .. "]" )
		else
			_self:ChatPrint( "Could not find NPCs with that class spawned by you." )
		end
	else
		_self:ChatPrint( "There are no NPCs spawned with that class." )
	end
end, {
	desc = "Removes all or last spawned NPC.^Must declare a class, if unsure^look at the killfeed.",
	syntax = "np_removenpcs <class> <removeAll>",
	args = 2
} )

NOOB_ADMIN:CreateCommand( "bombfuckcanister", "superadmin", function( _self )
	local canisterTarget = ents.Create( "info_target" )
	local entCanister = ents.Create( "env_headcrabcanister" )
	entCanister:SetPos( _self:GetEyeTrace( ).HitPos )
	canisterTarget:SetKeyValue( "targetname", "target" )
	canisterTarget:SetPos( _self:GetEyeTrace( ).HitPos + Vector( math.random( -7500, 7500 ), math.random( -7500, 7500 ), 15000) )
	canisterTarget:Spawn( )
	canisterTarget:Activate( )
	entCanister:SetAngles( ( canisterTarget:GetPos( ) - _self:GetEyeTrace( ).HitPos ):Angle( ) )
	entCanister:SetKeyValue( "HeadcrabType", 0 )
	entCanister:SetKeyValue( "HeadcrabCount", 10 )
	entCanister:SetKeyValue( "LaunchPositionName", "target" )
	entCanister:SetKeyValue( "FlightSpeed", 200 )
	entCanister:SetKeyValue( "FlightTime", .5 )
	entCanister:SetKeyValue( "Damage",10000 )
	entCanister:SetKeyValue( "DamageRadius", 1000 )
	entCanister:SetKeyValue( "SmokeLifetime", 60 )
	entCanister:Fire( "Spawnflags", "16384", 0 )
	entCanister:Fire( "FireCanister", "", 0 )
	entCanister:Fire( "AddOutput", "OnImpacted OpenCanister", 0 )
	entCanister:Fire( "AddOutput", "OnOpened SpawnHeadcrabs", 0 )
	entCanister:Spawn( )
	entCanister:Activate( )
	timer.Simple( 10, function( )
		if not ( IsValid( entCanister ) ) then return end
		entCanister:EmitSound( "weapons/mortar/mortar_explode2.wav" )
		timer.Simple( 180, function( )
			SafeRemoveEntity( canisterTarget )
			SafeRemoveEntity( entCanister )
		end )
	end )
end, {
	desc = "Fires a headcrab canister where^you're aimed at.^Try not to spawn too many.",
	syntax = "np_bombfuckcanister",
	args = 0
} )

NOOB_ADMIN:CreateCommand( "spawnvortigaunt", "admin", function( _self )
	local vortCost = 20000
	if not ( _self:canAfford( vortCost ) ) then
		DarkRP.notify( _self, NOTIFY_ERROR, 4, "You need $" .. string.Comma( vortCost ) .. " to spawn a Vortigaunt." )
	else
		_self:addMoney( -vortCost )
		DarkRP.notify( _self, NOTIFY_HINT, 4, "You spawned a Vortigaunt for $" .. string.Comma( vortCost ) .. "!" )
		local entVort = ents.Create( "npc_vortigaunt" )
		entVort:SetPos( _self:GetEyeTrace( ).HitPos )
		entVort:SetKeyValue( "spawnflags", "256" )
		entVort.adminSpawned = _self
		entVort.spawnedTime = CurTime( )
		local spawnTime = math.random( 2, 5 )
		util.BeginPortalEffect( _self:GetEyeTrace( ).HitPos, 1, 1, 16, Vector( 0, 0, 0 ), nil, entVort:EntIndex( ) .. "-Vortigauntspawn", spawnTime )
		timer.Simple( spawnTime, function( )
			if not ( IsValid( entVort ) ) then return end
			entVort:Spawn( )
			entVort:Activate( )
			entVort:SetHealth( entVort:Health( ) * 100 )
			entVort:SetMaxHealth( entVort:Health( ) )
			entVort:CreateTargetCheckingTimer( )
			entVort:EmitSound( "ambient/machines/teleport4.wav", 100, math.random( 70, 120 ) )
		end )
	end
end, {
	desc = "Spawns a powerful Vortigaunt^wherever your cursor is aimed.^Do not spawn too many.",
	syntax = "np_spawnvortigaunt",
	args = 0
} )

NOOB_ADMIN:CreateCommand( "spawnelitesoldier", "admin", function( _self )
	local soldierCost = 10000
	if not ( _self:canAfford( soldierCost ) ) then
		DarkRP.notify( _self, NOTIFY_ERROR, 4, "You need $" .. string.Comma( soldierCost ) .. " to spawn an Elite Combine Soldier." )
	else
		_self:addMoney( -soldierCost )
		DarkRP.notify( _self, NOTIFY_HINT, 4, "You spawned an Elite Combine Soldier for $" .. string.Comma( soldierCost ) .. "!" )
		local entCombine = ents.Create( "npc_combine_s" )
		entCombine:SetPos( _self:GetShootPos( ) + _self:GetAimVector( ) * 200 )
		entCombine:SetKeyValue( "additionalequipment", "weapon_ar2" )
		entCombine:SetKeyValue( "Squad Name", "Bravo" )
		entCombine:SetKeyValue( "SquadName", "Bravo" )
		entCombine:SetKeyValue( "NumGrenades", "1337" )
		entCombine:SetKeyValue( "waitingtorappel", "1" )
		entCombine:SetKeyValue( "model", "models/combine_super_soldier.mdl" )
		entCombine.adminSpawned = _self
		entCombine.spawnedTime = CurTime( )
		entCombine:Spawn( )
		entCombine:Activate( )
		entCombine:CreateTargetCheckingTimer( )
		timer.Simple( math.random( 4, 10 ), function( )
			if not ( IsValid( entCombine ) ) then return end
			entCombine:Fire( "BeginRappel" )
		end )
		entCombine:SetMaxHealth( entCombine:Health( ) * 100 )
		entCombine:SetHealth( entCombine:GetMaxHealth( ) )
		entCombine:SetNPCState( NPC_STATE_ALERT )
		entCombine:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_GOOD )
	end
end, {
	desc = "Spawns an Elite Combine Soldier^a bit past where your shoot position is.^It will then grapple down.",
	syntax = "np_spawnelitesoldier",
	args = 0
} )

NOOB_ADMIN:CreateCommand( "spawnsoldier", "admin", function( _self )
	local soldierCost = 5000
	if not ( _self:canAfford( soldierCost ) ) then
		DarkRP.notify( _self, NOTIFY_ERROR, 4, "You need $" .. string.Comma( soldierCost ) .. " to spawn a Combine Soldier." )
	else
		_self:addMoney( -soldierCost )
		DarkRP.notify( _self, NOTIFY_HINT, 4, "You spawned a Combine Soldier for $" .. string.Comma( soldierCost ) .. "!" )
		local entCombine = ents.Create( "npc_combine_s" )
		entCombine:SetPos( _self:GetEyeTrace( ).HitPos )
		entCombine:SetKeyValue( "additionalequipment", "weapon_ar2" )
		entCombine:SetKeyValue( "Squad Name", "Bravo" )
		entCombine:SetKeyValue( "SquadName", "Bravo" )
		entCombine.adminSpawned = _self
		entCombine.spawnedTime = CurTime( )
		entCombine:Spawn( )
		entCombine:Activate( )
		entCombine:CreateTargetCheckingTimer( )
		entCombine:SetMaxHealth( entCombine:Health( ) * 100 )
		entCombine:SetHealth( entCombine:GetMaxHealth( ) )
		entCombine:SetNPCState( NPC_STATE_ALERT )
		entCombine:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_GOOD )
	end
end, {
	desc = "Spawns a Combine Soldier^wherever your cursor is aimed.^Do not spawn too many.",
	syntax = "np_spawnsoldier",
	args = 0
} )

NOOB_ADMIN:CreateCommand( "present", "admin", function( _self )
	if not ( os.date("%m") == "12" ) then 
		DarkRP.notify( _self, NOTIFY_ERROR, 4, "It's not December, you can't spawn presents!" )
		return
	end
	if ( _self:canAfford( 20000 ) ) then
		local maxPresents = 5
		local spawnedPresents = ents.FindByClass( "present" )
		if ( table.IsValid( spawnedPresents, true ) ) then
			local presentCount = 0
			for index, present in ipairs ( spawnedPresents ) do
				if ( present.adminOwner == _self ) then
					presentCount = presentCount + 1
				end
			end
			if ( presentCount >= maxPresents ) then
				DarkRP.notify( _self, NOTIFY_ERROR, 4, "You've reached the Present limit." )
				return
			end
		end
		_self:addMoney( -20000 )
		DarkRP.notify( _self, NOTIFY_HINT, 4, "You spawned a Present for $20,000!" )
		local traceData = { }
		traceData.start = _self:GetShootPos( )
		traceData.endpos = traceData.start + _self:GetAimVector( ) * 100
		traceData.filter = self
		local traceRes = util.TraceLine( traceData )
		local entPresent = ents.Create( "present" )
		entPresent:SetPos( traceRes.HitPos )
		entPresent:Spawn( )
		entPresent:Activate( )
		entPresent.adminOwner = _self:SteamID( )
	else
		_self:ChatPrint( "You cannot afford that amount." )
	end
end, {
	desc = "Spawns a Present for $20,000^Only spawn these during December!",
	syntax = "np_present",
	args = 0
} )

NOOB_ADMIN:CreateCommand( "removepresents", "admin", function( _self )
	local spawnedPresents = ents.FindByClass( "present" )
	if ( table.IsValid( spawnedPresents, true ) ) then
		for index, present in ipairs ( spawnedPresent ) do
			if ( present.adminOwner == _self:SteamID( ) ) then
				DarkRP.notify( _self, NOTIFY_HINT, 4, "You were refunded $20,000 for a Present." )
				_self:addMoney( -20000 )
				SafeRemoveEntity( present )
			end
		end
	else
		_self:ChatPrint( "There currently are no Presents spawned.")
	end
end, {
	desc = "Removes and refunds all your^currently spawned Presents.",
	syntax = "np_removepresents",
	args = 0
} )

NOOB_ADMIN:CreateCommand( "roller", "admin", function( _self, val )
	if not ( tonumber( val ) ) then
		_self:ChatPrint( "You must specify how much the rollermine is worth." )
	end
	local amt = tonumber( val )
	local prizeRange = SVNOOB_VARS:Get( "RollerMinePrize", true, "table", { min = 5000, max = 100000 } )
	if ( amt > prizeRange.max or amt < prizeRange.min ) then
		_self:ChatPrint( "The worth must be between $" .. string.Comma( prizeRange.min ) .. " and $" .. string.Comma( prizeRange.max ) .. "." )
		return
	end
	if ( _self:canAfford( amt ) ) then
		local maxRollers = SVNOOB_VARS:Get( "MaxRollerMines", true, "number", 5 )
		local spawnedRollers = ents.FindByClass( "roller_prize" )
		if ( table.IsValid( spawnedRollers, true ) ) then
			local rollerCount = 0
			for index, roller in ipairs ( spawnedRollers ) do
				if ( roller.adminOwner == _self ) then
					rollerCount = rollerCount + 1
				end
			end
			if ( rollerCount >= maxRollers ) then
				DarkRP.notify( _self, NOTIFY_ERROR, 4, "You've reached the Rollermine limit." )
				return
			end
		end
		_self:addMoney( -amt )
		DarkRP.notify( _self, NOTIFY_HINT, 4, "You spawned a Rollermine worth $" .. string.Comma( amt ) .. "!" )
		local traceData = { }
		traceData.start = _self:GetShootPos( )
		traceData.endpos = traceData.start + _self:GetAimVector( ) * 100
		traceData.filter = self
		local traceRes = util.TraceLine( traceData )
		local entRoller = ents.Create( "roller_prize" )
		entRoller:SetPos( traceRes.HitPos )
		entRoller:Spawn( )
		entRoller:Activate( )
		entRoller.adminOwner = _self:SteamID( )
		entRoller:SetWorth( amt )
	else
		_self:ChatPrint( "You cannot afford that amount." )
	end
end, {
	desc = "Spawns a rollermine worth money.^You can claim or remove them with^the other commands.",
	syntax = "np_roller <amt>",
	args = 1
} )

NOOB_ADMIN:CreateCommand( "getplayerip", "superadmin", function( _self, steamID )
	if not ( steamID ) then
		_self:ErrorNotify( "You must specify a SteamID!" )
		return
	end
	mySQLControl:Query("SELECT * from darkrp_playerips where steam = " .. SQLStr( steamID ) .. ";", function( data )
		if ( #data < 1 ) then
			_self:ErrorNotify( "Could not match any IP(s) for specified SteamID!" )
		else 
			_self:SuccessNotify( "Found IP(s) for specified SteamID!" )
			for index, ipTbl in pairs( data ) do
				_self:ChatPrint( "IP Match: [ " .. steamID .. " ] [ " .. ipTbl.ip .. " ] " )
			end
		end
	end )
end, {
	desc = "Find IP(s) for specified SteamID.",
	syntax = "np_getplayerip <steamid>",
	args = 1
} )

NOOB_ADMIN:CreateCommand( "getplayersbyip", "superadmin", function( _self, ip )
	if not ( ip ) then
		_self:ErrorNotify( "You must specify an IP!" )
		return
	end
	mySQLControl:Query("SELECT * from darkrp_playerips where ip = " .. SQLStr( ip ) .. ";", function( data )
		if ( #data < 1 ) then
			_self:ErrorNotify( "No players with that IP were found!" )
			return
		else 
			_self:SuccessNotify( "Found player(s) for specified IP!" )
			for index, plyTbl in pairs( data ) do
				NOOB_ADMIN:GetNameBySteamID( plyTbl.steam, function( data )
					if not ( data ) then
						_self:ChatPrint( "SteamID Match: [ " .. ip .. " ] [ " .. plyTbl.steam .. " ] " )
					else
						_self:ChatPrint( "SteamID Match: [ " .. ip .. " ] [ " .. plyTbl.steam .. " ] [ " .. data .. " ] " )
					end
				end )
			end
		end
	end);
end, {
	desc = "Find players for specified IP.",
	syntax = "np_getplayersbyip <ip>",
	args = 1
} )

NOOB_ADMIN:CreateCommand( "addradiostation", "admin", function( _self, title, url )
	local title = title or "Untitled"
	if not ( url ) then return end
	local radioStations = SHNOOB_VARS:Get( "RadioStations" )
	radioStations[title] = url
	SHNOOB_VARS:Set( "RadioStations", radioStations )
	DarkRP.notify( _self, 1, 4, "You've added the Radio Station " .. title .. "\nLink: " .. url )
end, {
	desc = "Temporarily adds a Radio Station players^can listen to. Only specific URLs will work.",
	syntax = "np_addradiostation <title> <url>",
	args = 2
} )

NOOB_ADMIN:CreateCommand( "removeradiostation", "admin", function( _self, title )
	if not ( title ) then return end
	local radioStations = SHNOOB_VARS:Get( "RadioStations" )
	if not ( radioStations[title] ) then
		DarkRP.notify( _self, 1, 4, "That Radio Station doesn't exist." )
		return
	end
	radioStations[title] = nil
	SHNOOB_VARS:Set( "RadioStations", radioStations )
	DarkRP.notify( _self, 1, 4, "You've removed the Radio Station " .. title .. "." )
end, {
	desc = "Temporarily removes a radio station.",
	syntax = "np_removeradiostation <title>",
	args = 1
} )

NOOB_ADMIN:CreateCommand( "clearradiostations", "admin", function( _self )
	SHNOOB_VARS:Set( "RadioStations", { } )
	DarkRP.notify( _self, 1, 4, "You've cleared all Radio Stations." )
end, {
	desc = "Temporarily clear all Radio Stations.",
	syntax = "np_clearradiostations",
	args = 0
} )

NOOB_ADMIN:CreateCommand( "resetradiostations", "admin", function( _self )
	SHNOOB_VARS:Set( "RadioStations", nil )
	SHNOOB_VARS:Set( "RadioStations", NOOBRP.Config.RadioStations )
	DarkRP.notify( _self, 1, 4, "You've reset the Radio Stations to default." )
end, {
	desc = "Sets all Radio Stations back to default.",
	syntax = "np_resetradiostations",
	args = 0
} )

NOOB_ADMIN:CreateCommand( "addstaticwaypoint", "admin", function( _self, name )
	if not ( name ) then _self:ErrorNotify( "You need to specify a name!" ) return end
	local staticWaypoints = SHNOOB_VARS:Get( "MinimapStaticWaypoints" )
	if ( !staticWaypoints or !istable( staticWaypoints ) ) then _self:ErrorNotify( "Couldn't find Static Waypoints table." ) return end
	if ( staticWaypoints[name] ) then _self:ErrorNotify( "That Static Waypoint already exists!" ) return end
	NOOBRP.AddStaticWaypoint( name, _self:GetPos( ) )
	_self:SuccessNotify( "You've added the Static Waypoint " .. name .. " at your position!" )
end, {
	desc = "Creates a Static Minimap Waypoint at your^ position. Always visible on minimap.",
	syntax = "np_addstaticwaypoint <name>",
	args = 1
} )

NOOB_ADMIN:CreateCommand( "removestaticwaypoint", "admin", function( _self, name )
	if not ( name ) then _self:ErrorNotify( "You need to specify a name!" ) return end
	local staticWaypoints = SHNOOB_VARS:Get( "MinimapStaticWaypoints" )
	if ( !staticWaypoints or !istable( staticWaypoints ) ) then _self:ErrorNotify( "Couldn't find Static Waypoints table." ) return end
	if not ( staticWaypoints[name] ) then _self:ErrorNotify( "That Static Waypoint doesn't exist." ) return end
	NOOBRP.RemoveStaticWaypoint( name )
	_self:SuccessNotify( "You've removed the Static Waypoint " .. name .. "!" )
end, {
	desc = "Removes the specified Static Waypoint.",
	syntax = "np_removestaticwaypoint <name>",
	args = 1
} )

NOOB_ADMIN:CreateCommand( "createwaypoint", "admin", function( _self, name )
	local waypointTable = SHNOOB_VARS:Get( "MinimapWaypoints", true ) or NOOBRP.Config.Waypoints
	if ( waypointTable[name] ) then return end
	waypointTable[name] = _self:GetPos( )
	SHNOOB_VARS:Set( "MinimapWaypoints", waypointTable )
	DarkRP.notify( _self, 1, 4, "You've added the Waypoint " .. name .. " at your position!" )
end, {
	desc = "Creates a Minimap Waypoint at your position.",
	syntax = "np_createwaypoint <name>",
	args = 1
} )

NOOB_ADMIN:CreateCommand( "removewaypoint", "admin", function( _self, name )
	local waypointTable = SHNOOB_VARS:Get( "MinimapWaypoints", true ) or NOOBRP.Config.Waypoints
	if not ( waypointTable[name] ) then DarkRP.notify( _self, 1, 4, "No Waypoint with that name exists." ) return end
	waypointTable[name] = nil
	SHNOOB_VARS:Set( "MinimapWaypoints", waypointTable )
	DarkRP.notify( _self, 1, 4, "You've removed the Waypoint " .. name .. "!" )
end, {
	desc = "Removes the specified waypoint.",
	syntax = "np_removewaypoint <name>",
	args = 1
} )

NOOB_ADMIN:CreateCommand( "spectateesp", "admin", function( _self )
	local isToggled = _self:getDarkRPVar( "SpectateESP" )
	if ( isToggled ) then
		DarkRP.notify( _self, 1, 4, "You've disabled Spectate ESP." )
		_self:setSelfDarkRPVar( "SpectateESP", !isToggled )
	else
		DarkRP.notify( _self, 1, 4, "You've enabled Spectate ESP." )
		_self:setSelfDarkRPVar( "SpectateESP", !isToggled )
	end
	
end, {
	desc = "Enables ESP while in spectate.",
	syntax = "np_spectateesp",
	args = 0
} )

NOOB_ADMIN:CreateCommand( "getnamebyid", "admin", function( _self, steamID )
	if not ( steamID ) then
		_self:ErrorNotify( "You must specify a SteamID!" )
		return
	end
	NOOB_ADMIN:GetNameBySteamID( steamID, function( data )
		if not ( data ) then
			_self:ErrorNotify( "No name could be found for that SteamID." )
		else
			_self:SuccessNotify( "That SteamID belongs to [ " .. data .. " ] " )
		end
	end )
end, {
	desc = "Gets a player's rpname via SteamID",
	syntax = "np_getnamebyid <steamid>",
	args = 1
} )

NOOB_ADMIN:CreateCommand( "rollerreveal", "admin", function( _self )
	local spawnedRollers = ents.FindByClass( "roller_prize" )
	if ( table.IsValid( spawnedRollers, true ) ) then
		for index, roller in ipairs ( spawnedRollers ) do
			if ( roller.adminOwner == _self:SteamID( ) ) then
				local nearestPlayer = roller:GetNearestPlayer( )
				if ( IsValid( nearestPlayer ) ) then
					local foundLocation = nearestPlayer:LookFor( )
					if ( foundLocation ) then
						PrintMessage( HUD_PRINTTALK, nearestPlayer:Name( ) .. " currently has at least one rollermine at " .. foundLocation .. "!" )
					end
				end
			end
		end
	else
		_self:ErrorNotify( "There currently are no Rollermines spawned.")
	end
end, {
	desc = "Gets the nearest player and^attempts to reveal their location globally.",
	syntax = "np_rollerreveal",
	args = 0
} )

NOOB_ADMIN:CreateCommand( "rollerscan", "admin", function( _self )
	local spawnedRollers = ents.FindByClass( "roller_prize" )
	if ( table.IsValid( spawnedRollers, true ) ) then
		for index, roller in ipairs ( spawnedRollers ) do
			if ( roller.adminOwner == _self:SteamID( ) ) then
				local nearestPlayer = roller:GetNearestPlayer( )
				if not ( IsValid( nearestPlayer ) ) then
					PrintMessage( HUD_PRINTTALK, "(EVENT) A Rollermine is currently closest to nobody." )
				else
					PrintMessage( HUD_PRINTTALK, "(EVENT) A Rollermine is currently closest to " .. nearestPlayer:Name( ) .. "!" )
				end
			end
		end
	else
		_self:ErrorNotify( "There currently are no Rollermines spawned.")
	end
end, {
	desc = "Scans for Rollermines and prints^the closest player to everybody.",
	syntax = "np_rollerscan",
	args = 0
} )

NOOB_ADMIN:CreateCommand( "rollerclaim", "admin", function( _self )
	local spawnedRollers = ents.FindByClass( "roller_prize" )
	if ( table.IsValid( spawnedRollers, true ) ) then
		for index, roller in ipairs ( spawnedRollers ) do
			if ( roller.adminOwner == _self:SteamID( ) ) then
				local nearestPlayer = roller:GetNearestPlayer( )
				if not ( IsValid( nearestPlayer ) ) then
					PrintMessage( HUD_PRINTTALK, "(EVENT) A Rollermine remains unclaimed." )
				else
					local rollerWorth = roller:GetWorth( )
					PrintMessage( HUD_PRINTTALK, "(EVENT) " .. nearestPlayer:Name( ) .. " has claimed a Rollermine for $" .. string.Comma( rollerWorth ) .. "!" )
					nearestPlayer:addMoney( rollerWorth )
					DarkRP.notify( nearestPlayer, NOTIFY_HINT, 4, "You were rewarded $" .. string.Comma( rollerWorth ) .. "!" )
					SafeRemoveEntity( roller )
				end
			end
		end
	else
		_self:ChatPrint( "There currently are no Rollermines spawned.")
	end
end, {
	desc = "Rewards players nearby your^Rollermines the amount you specified.",
	syntax = "np_rollerclaim",
	args = 0
} )

NOOB_ADMIN:CreateCommand( "rollerremove", "admin", function( _self )
	local spawnedRollers = ents.FindByClass( "roller_prize" )
	if ( table.IsValid( spawnedRollers, true ) ) then
		for index, roller in ipairs ( spawnedRollers ) do
			if ( roller.adminOwner == _self:SteamID( ) ) then
				local rollerWorth = roller:GetWorth( )
				DarkRP.notify( _self, NOTIFY_HINT, 4, "You were refunded $" .. string.Comma( rollerWorth ) .. " for a Rollermine." )
				_self:addMoney( rollerWorth )
				SafeRemoveEntity( roller )
			end
		end
	else
		_self:ChatPrint( "There currently are no Rollermines spawned.")
	end
end, {
	desc = "Removes and refunds all your^currently spawned Rollermines.",
	syntax = "np_rollerclaim",
	args = 0
} )

NOOB_ADMIN:CreateCommand( "movebeast", "superadmin", function( _self )
	local guardEntities = ents.FindByClass( "npc_antlionguard" )
	if ( !istable( guardEntities ) or #guardEntities < 1 ) then
		_self:ChatPrint( "There isn't a Beast spawned at the moment." )
		return
	end
	for index, antlionGuard in ipairs ( guardEntities ) do
		if ( antlionGuard.isBeast ) then
			antlionGuard:SetPos( _self:GetPos( ) )
			antlionGuard:SetAngles( Angle( 0, 0, 0) )
			_self:ChatPrint( "Moved the Beast to your current position." )
			break
		end
	end
end, {
	desc = "Moves the Beast to your current position.",
	syntax = "np_movebeast",
	args = 0
} )

NOOB_ADMIN:CreateCommand( "movemound", "superadmin", function( _self )
	local moundEntities = ents.FindByClass( "beast_mound" )
	if ( !istable( moundEntities ) or #moundEntities < 1 ) then
		_self:ChatPrint( "There isn't a Beast Mound spawned at the moment." )
		return
	end
	moundEntities[1]:SetPos( _self:GetPos( ) )
	_self:ChatPrint( "Moved the Beast Mound to your current position." )
end, {
	desc = "Moves the Beast Mound to your current position.",
	syntax = "np_movemound",
	args = 0
} )

NOOB_ADMIN:CreateCommand( "weakenbeastplayer", "superadmin", function( _self, val )
	local guardEntities = ents.FindByClass( "npc_antlionguard" )
	if ( !istable( guardEntities ) or #guardEntities < 1 ) then
		_self:ChatPrint( "There isn't a Beast spawned at the moment." )
		return
	end
	local foundPlayer = DarkRP.findPlayer( val )
	if not ( IsValid( foundPlayer ) ) then
		DarkRP.notify( _self, 1, 4, "That player could not be found." )
		return
	end
	for index, antlionGuard in ipairs ( guardEntities ) do
		if ( antlionGuard.isBeast ) then
			if ( antlionGuard.weakenedPlayers[foundPlayer:SteamID( )] ) then
				DarkRP.notify( _self, 1, 4, "Set " .. foundPlayer:Name( ) .. "'s damage against the Beast back to normal." )
				antlionGuard.weakenedPlayers[foundPlayer:SteamID( )] = nil
				break
			else
				DarkRP.notify( _self, 1, 4, "Weakened " .. foundPlayer:Name( ) .. "'s damage against the Beast." )
				antlionGuard.weakenedPlayers[foundPlayer:SteamID( )] = true
				break
			end
		end
	end
end, {
	desc = "Reduces the player's damage to the^current Beast by 75%. Used for players^who win too much.",
	syntax = "np_weakenbeastplayer <player>",
	args = 1
} )

NOOB_ADMIN:CreateCommand( "cleanplayerprints", "superadmin", function( _self, val, class )
	if ( !val or !class ) then return end
	local ply = util.FindPlayer( val )
	local spawnedPrinters = ents.FindByClass( class )
	if not ( string.find( string.lower( class ), "printer" ) ) then return end
	if ( !istable( spawnedPrinters ) or #spawnedPrinters < 1 ) then
		_self:ChatPrint( "There aren't any of those printers spawned.." )
		return
	end
	if not ( IsValid( ply ) ) then
		DarkRP.notify( _self, 1, 4, "That player could not be found." )
		return
	end
	for index, printer in ipairs ( spawnedPrinters ) do
		if ( printer:Getowning_ent( ) == ply ) then
			_self:ChatPrint( "Removing " .. ply:Nick( ) .. "'s " .. printer:GetClass( ) .. "( " .. printer:EntIndex( ) .. " )" )
			local color = printer:GetColor( )
			print( "[PRINTERDEBUG] No Draw: " .. tostring( printer:GetNoDraw( ) ) .. " Color: ( " .. color.r .. ", " .. color.g .. ", " .. color.b .. ", " .. color.a .. " )" .. " Material: " .. tostring( printer:GetMaterial( ) ) .. " Position: " .. tostring( printer:GetPos( ) ) )
			SafeRemoveEntity( printer )
		end
	end
end, {
	desc = "Cleans up all of a player's specific printer type. Temporary fix to printers vanishing.",
	syntax = "np_cleanplayerprints <player> <class>",
	args = 2
} )	

NOOB_ADMIN:CreateCommand( "remove", "admin", function( _self )
	if ( IsValid( _self:GetEyeTrace( ).Entity ) and !_self:GetEyeTrace( ).Entity:IsWorld( ) ) then
		local ent = _self:GetEyeTrace( ).Entity
		_self:ChatPrint( "Removing Entity [ " .. ent:GetClass( ) .. " ] ( " .. ent:EntIndex( ) .. " )" )
		local mes = _self:NiceInfo( ) .. " has removed Entity [ " .. ent:GetClass( ) .. " ]" 
		NOOB_LOGGER:Log( NOOB_LOGGING_WARNING, mes, true )
		SafeRemoveEntity( ent )
	else
		_self:ChatPrint( "There's no entity in your line of sight." )
	end
end, {
	desc = "Removes the entity infront of you^Only use this when necessary.",
	syntax = "np_remove",
	args = 0
} )

NOOB_ADMIN:CreateCommand( "permaprop", "admin", function( _self )
	local ent = _self:GetEyeTrace( ).Entity
	if ( IsValid( ent ) and ent:GetClass( ) == "prop_physics" ) then
		if ( ent:IsGodded( ) ) then
			ent:SetGodmode( false )
			DarkRP.notify( _self, NOTIFY_HINT, 4, "Enabled damage on the prop you're looking at." )
		else
			ent:SetGodmode( true )
			DarkRP.notify( _self, NOTIFY_HINT, 4, "Disabled damage on the prop you're looking at." )
		end
	end
end, {
	desc = "Toggles damage on the prop you're^looking at. Use this only for events.",
	syntax = "np_permaprop",
	args = 0
} )

NOOB_ADMIN:CreateCommand( "chatban", "admin", function( _self, val, time )
	local other = doplayercheck( val )
	if not time then time = 3 end
	if ( other ) then
		if not ( other.isChatBanned ) then
			local banTime = time or nil
			if not ( banTime ) then
				other.isChatBanned = true
				NOOB_ADMIN:Notification( _self:Nick( ), "has chat-banned", other:Nick( ), "indefinitely." )
			else
				other.isChatBanned = true
				local niceTime = string.NiceTime( tonumber( banTime ) )
				NOOB_ADMIN:Notification( _self:Nick( ), "has chat-banned", other:Nick( ), "for", niceTime .. "." )
				timer.Simple( banTime, function( ) 
					if not ( IsValid( other ) ) then return end
					if not ( other.isChatBanned ) then return end
					NOOB_ADMIN:Notification( other:Nick( ), "is no longer chat-banned." )
					other.isChatBanned = false
				end )
			end
		else
			_self:ChatPrint( "That player is already chat-banned." )
		end
	end
end, {
	desc = "Player will be unable to speak^Time is defaulted to 3 minutes",
	syntax = "np_chatban <player> <time>",
	args = 2
} )

NOOB_ADMIN:CreateCommand( "unchatban", "admin", function( _self, val)
	local other = doplayercheck( val )
	if ( other ) then
		if ( other.isChatBanned ) then
			NOOB_ADMIN:Notification( _self:Nick( ), "has removed", other:Nick( ), "'s chat-ban." )
			other.isChatBanned = false
		else
			_self:ChatPrint( "That player isn't currently chat-banned." )
		end
	end
end, {
	desc = "Allows a player to speak again.^This will cancel a timed chat-ban.",
	syntax = "np_unchatban <player>",
	args = 1
} )

NOOB_ADMIN:CreateCommand( "adminchatban", "admin", function( _self, val, time )
	local other = doplayercheck( val )
	if not time then time = 180 end
	if ( other ) then
		if not ( other.isAdminChatBanned ) then
			local banTime = time or nil
			if not ( banTime ) then
				other.isAdminChatBanned = true
				_self:SuccessNotify( "You have admin chat-banned " .. other:Name( ) .. " indefinitely. " )
			else
				other.isAdminChatBanned = true
				local niceTime = string.NiceTime( tonumber( banTime ) )
				_self:SuccessNotify( "You have admin chat-banned " .. other:Name( ) .. " for " .. niceTime .. "!" )
				timer.Simple( banTime, function( ) 
					if not ( IsValid( other ) ) then return end
					if not ( other.isAdminChatBanned ) then return end
					other.isAdminChatBanned = false
				end )
			end
		else
			_self:ChatPrint( "That player is already admin chat-banned." )
		end
	end
end, {
	desc = "Player will be unable to speak in admin chat^Time is defaulted to 3 minutes",
	syntax = "np_adminchatban <player> <time>",
	args = 2
} )

NOOB_ADMIN:CreateCommand( "unadminchatban", "admin", function( _self, val)
	local other = doplayercheck( val )
	if ( other ) then
		if ( other.isAdminChatBanned ) then
			_self:SuccessNotify( "You have lifted " .. other:Name( ) .. "'s admin chat-ban." )
			other.isAdminChatBanned = false
		else
			_self:ErrorNotify( "That player isn't currently admin chat-banned." )
		end
	end
end, {
	desc = "Allows a player to speak to admins again.^This will cancel a timed admin chat-ban.",
	syntax = "np_unadminchatban <player>",
	args = 1
} )

NOOB_ADMIN:CreateCommand( "pacifism", "superadmin", function( _self, val )
	local other = doplayercheck( val )
	if ( other ) then
		if not ( other:IsPacifist( ) ) then
			other:GivePacifism( )
			_self:SuccessNotify( "Granting " .. other:Name( ) .. " Pacifist status." )
		else
			_self:ErrorNotify( "That player is already a Pacifist!" )
		end
	else
		_self:ErrorNotify( "Invalid palyer specified!")
	end
end, {
	desc = "Grants a player pacifism, used^either for testing or^rare cases.",
	syntax = "np_pacifism <player>",
	args = 1
} )

NOOB_ADMIN:CreateCommand( "revokepacifism", "admin", function( _self, val )
	local other = doplayercheck( val )
	if ( other ) then
		if ( other:IsPacifist( ) ) then
			NOOB_ADMIN:Notification( _self:Nick( ), "has revoked", other:Nick( ) .. "'s Pacifism." )
			other:RevokePacifism( )
			local mes = _self:NiceInfo( true ) .. " has revoked " .. other:NiceInfo( true ) .. "'s Pacifism." 
			NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, mes, true )
		else
			_self:ErrorNotify( "That player is not a Pacifist!" )
		end
	else
		_self:ErrorNotify( "Invalid player specified!" )
	end
end, {
	desc = "Revokes a player's Pacifism.^Used when a player breaks^expected behavior of Pacifism.",
	syntax = "np_revokepacifism <player>",
	args = 1
} )

NOOB_ADMIN:CreateCommand( "fixelevator", "admin", function( _self )
	local btnTable = ents.FindByName( "ash47_btn_01" )
	local elevatorBtn = btnTable[1]
	if not ( elevatorBtn ) then 
		_self:ErrorNotify( "The elevator button could not be found, contact a developer." )
		return 
	end
	elevatorBtn:Fire( "unlock", 0, 1 )
	elevatorBtn:Fire( "use", 0, 1 )
	_self:SuccessNotify( "You've attempted to fix the elevator." )
end, {
	desc = "Use this to fix the nexus elevator^when it doesn't stop moving.",
	syntax = "np_fixelevator",
	args = 0
} )

NOOB_ADMIN:CreateCommand( "deleteclan", "admin", function( _self, clanName )
	mySQLControl:Query( "SELECT * FROM darkrp_clans WHERE name = '" .. mySQLControl:Escape( clanName ) .. "';", function( data )
		if ( #data < 1 ) then
			_self:ChatPrint( "The clan " .. clanName .. " does not exist." )
		else
			mySQLControl:Query( "DELETE FROM darkrp_clans WHERE uniqueid = " .. data[1].uniqueid .. ";", function( ) end )
			NOOB_ADMIN:Notification( _self:Nick( ), "has deleted the clan", clanName, "." )
			for index, ply in ipairs ( player.GetAll( ) ) do
				if ( ply:getDarkRPVar( "Clan" ) == clanName ) then
					ply:setDarkRPVar( "Clan", nil )
					ply.clanRank = 0
				end
			end
		end
	end )
end, {
	desc = "Delete a clan permanently^Use this for racist clan names^Issue a ban as well.",
	syntax = "np_deleteclan <clanname>",
	args = 1
} )

NOOB_ADMIN:CreateCommand( "storespawn", "superadmin", function( _self, teamEnum )
	local teamEnum = teamEnum or _self:Team( )
	DarkRP.storeTeamSpawnPos( teamEnum, _self:GetPos( ) )
	DarkRP.notify( _self, 1, 4, "Created a spawn point for the " .. team.GetName( teamEnum ) .. " job. " )
	DarkRP.notify( _self, 1, 4, "Position: " .. tostring( _self:GetPos( ) ) )
	local mes = _self:NiceInfo( ) .. " has created a spawn point for " .. team.GetName( teamEnum ) .. " at: " .. tostring( _self:GetPos( ) )
	NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
end, {
	desc = "Stores a spawn point at your^position.Specify no job^to choose current job.",
	syntax = "np_storespawn <team>",
	args = 1
} );

NOOB_ADMIN:CreateCommand( "givegem", "superadmin", function( _self, val, gType, amt )
	local nameWhitelist = { ["Rocks"] = true, ["Granite"] = true, ["Shale"] = true, ["Emeralds"] = true, ["Rubies"] = true, ["Sapphires"] = true, ["Obsidians"] = true, ["Diamonds"] = true }
	local other = doplayercheck( val );
	local amt = tonumber( amt ) or 1 
	if not ( nameWhitelist[gType] ) then 
		_self:ErrorNotify( "Type the gem name right, asshole." )
		return 
	end
	if ( other ) then
		NOOB_ADMIN:Notification( _self:Nick( ), "has gifted", other:Nick( ), "x" .. amt, gType .. "!" );
		other:GiveGem( gType, amt )
		local mes = _self:NiceInfo( ) .. " gifted " .. other:Nick( ) .. " x" .. amt .. " " .. gType
		NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
	end
end, {
	desc = "Gives a player the specified gem.^Only to be used when donations aren't automatic.",
	syntax = "np_givegem <player> <type (Ex. Rocks> <amt>",
	args = 3
} );

NOOB_ADMIN:CreateCommand( "giveherb", "superadmin", function( _self, val, hType, amt )
	local nameWhitelist = { ["Burdock Root"] = true, ["Gingko Biloba"] = true, ["Valerian Root"] = true, ["Coral Fungus"] = true, ["Red Reishi"] = true, ["Psilocybe Cubensis"] = true }
	local other = doplayercheck( val );
	local amt = tonumber( amt ) or 1
	if not ( nameWhitelist[hType] ) then 

		return end
	if ( other ) then
		NOOB_ADMIN:Notification( _self:Nick( ), "has gifted", other:Nick( ), "x" .. amt, hType .. "!" );
		other:GiveHerb( hType, amt )
		local mes = _self:NiceInfo( ) .. " gifted " .. other:Nick( ) .. " x" .. amt .. " " .. hType
		NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
	end
end, {
	desc = "Gives a player the specified herb.^Probably won't be used at all.",
	syntax = "np_giveherb <player> <type> <amt>",
	args = 3
} );

NOOB_ADMIN:CreateCommand( "givexp", "superadmin", function( _self, val, xpType, amt )
	local enumTable = { 
		["Running"] = { enum = NOOB_SKILL_RUNNING, var = "RunningXP", niceName = "running" },
		["Police"] = { enum = NOOB_SKILL_COP, var = "PoliceXP", niceName = "Civil Protection" },
		["Criminal"] = { enum = NOOB_SKILL_CRIMINAL, var = "CriminalXP", niceName = "Criminal Expertise" }, 
		["Printing"] = { enum = NOOB_SKILL_PRINTING, var = "PrintingXP", niceName = "Printer Management" }, 
		["Endurance"] = { enum = NOOB_SKILL_ENDURANCE, var = "EnduranceXP", niceName = "Endurance" }, 
		["Mining"] = { enum = NOOB_SKILL_MINING, var = "MiningXP", niceName = "Mining" }, 
		["Herbalism"] = { enum = NOOB_SKILL_HERBALISM, var = "HerbalismXP", niceName = "Herbalism" }, 
		["Alchemy"] = { enum = NOOB_SKILL_ALCHEMY, var = "AlchemyXP", niceName = "Alchemy" } 
	}
	local other = doplayercheck( val );
	local amt = tonumber( amt ) or 1
	if not ( enumTable[xpType] ) then return end
	if ( other ) then
		NOOB_ADMIN:Notification( _self:Nick( ), "has given", other:Nick( ), amt, enumTable[xpType].niceName .. " experience!" );
		local mes = _self:NiceInfo( ) .. " has given " .. other:Nick( ) .. " " .. amt .. " " .. enumTable[xpType].niceName .. " experience"
		if ( other:IsVIP( ) ) then
			amt = amt / 2
		end
		other:RewardXP( amt, enumTable[xpType].enum, enumTable[xpType].var, enumTable[xpType].niceName, true )
		NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
	end
end, {
	desc = "Gives a player the specified amount.^of experience. Also probably won't be used.",
	syntax = "np_givexp <player> <type> <amt>",
	args = 3
} );

NOOB_ADMIN:CreateCommand( "giveperma", "superadmin", function( _self, val, perm )
	local other = doplayercheck( val );
	local item = weapons.Get( perm );
	if ( other and item ) then
		other:HasPermItem( perm, function( bool )
			if ( bool ) then
				DarkRP.notify( _self, 1, 4, "That player already has that permanent item." );
			else
				NOOB_ADMIN:Notification( _self:Nick( ), "has gifted", other:Nick( ), "a permanent", perm .. "." );
				other:GivePermWeapon( perm );
				local mes = _self:NiceInfo( ) .. " gifted " .. other:Nick( ) .. " a permanent " .. perm
				NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
			end
		end );
	end
end, {
	desc = "Give a player a permanent^weapon, will do nothing if^the weapon doesn't exist.",
	syntax = "np_giveperma <player> <class>",
	args = 2
} );

NOOB_ADMIN:CreateCommand( "resetperks", "superadmin", function( _self, val )
	local other = doplayercheck( val )
	if ( other ) then
		NOOB_ADMIN:Notification( _self:Nick( ), "has reset", other:Nick( ),"'s perks." )
		other:PlayerResetPerks( )
		local mes = _self:NiceInfo( ) .. " has reset " .. other:Nick( ) .. "'s perks"
		NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
	end
end, {
	desc = "Resets a player's perks,^mainly just for debugging,^should not be used otherwise.",
	syntax = "np_resetperks <player>",
	args = 1
} );

NOOB_ADMIN:CreateCommand( "togglevisionblur", "admin", function( _self, val, status )
	local other = doplayercheck( val )
	if ( other ) then
		local status = tobool( status )
		NOOB_ADMIN:Notification( _self:Nick( ), "has toggled", other:Nick( ),"'s vision blur to", tostring( status ), "!" )
		other:EnableVisionBlur( status )
		local mes = _self:NiceInfo( ) .. " has set " .. other:Nick( ) .. "'s vision blur to " .. tostring( status )
		NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, mes, false )
	end
end, {
		desc = "Toggle whether a player's^vision is blurred.",
		syntax = "np_togglevisionblur <player> <status>",
		args = 2
} );

NOOB_ADMIN:CreateCommand( "purge", "admin", function( _self, val )
	if ( tonumber( val ) ) then
		if ( NOOBRP:IsPurgeOccuring( ) ) then
			_self:ChatPrint( "There's already a Purge Event occuring." )
			return
		end
		local minutes = math.Clamp( val * 60, 5 * 60, 60 * 60 )
		NOOB_ADMIN:Notification( _self:Nick( ), "has begun a Purge Event! It will last " .. string.NiceTime( minutes ) .. ". Players can kill eachother, but you cannot spawn kill. Killing citizens will lengthen your spawn timer." )
		NOOBRP:SpawnPurgeVendor( )
		SHNOOB_VARS:Set( "PurgeEventActive", true )
		SVNOOB_VARS:Set( "DefaultRespawnTime", 30 )
		SVNOOB_VARS:Set( "DefaultArrestTimer", 150 )
		SVNOOB_VARS:Set( "DefibrillatorCooldown", 10 )
		for index, ply in ipairs( player.GetAll( ) ) do
			if ( ply:IsValid( ) ) then
				ply:GivePurgeEventGear( )
			end
		end
		timer.Create( "N00BRP_PurgeEventTimer", minutes, 1, function( )
			PrintMessage( HUD_PRINTTALK, "The Purge Event has ended." )
			SHNOOB_VARS:Set( "PurgeEventActive", false )
			SVNOOB_VARS:Set( "DefaultRespawnTime", 60 )
			SVNOOB_VARS:Set( "DefaultArrestTimer", 300 )
			SVNOOB_VARS:Set( "DefibrillatorCooldown", 120 )
			NOOBRP:DespawnPurgeVendor( )
			NOOBRP:ClearPurgeDurationItems( )
		end )
		local mes = _self:NiceInfo( ) .. " has begun a Purge Event! "
		NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, mes, false )
	else
		_self:ChatPrint( "You must enter a length." )
	end
end, {
		desc = "Start a Purge Event^Player may kill eachother.^Min: 5m Max: 1hr",
		syntax = "np_purge <time>",
		args = 1
} );

NOOB_ADMIN:CreateCommand( "endpurge", "admin", function( _self  )
	if ( NOOBRP:IsPurgeOccuring( ) ) then
		NOOB_ADMIN:Notification( _self:Nick( ), "has ended the Purge Event." )
		SHNOOB_VARS:Set( "PurgeEventActive", false )
		SVNOOB_VARS:Set( "DefaultRespawnTime", 60 )
		SVNOOB_VARS:Set( "DefaultArrestTimer", 300 )
		SVNOOB_VARS:Set( "DefibrillatorCooldown", 120 )
		NOOBRP:DespawnPurgeVendor( )
		NOOBRP:ClearPurgeDurationItems( )
		timer.Destroy( "N00BRP_PurgeEventTimer" )
		local mes = _self:NiceInfo( ) .. " has ended the Purge Event"
		NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, mes, false )
	else
		_self:ChatPrint( "No Purge Event is occuring." )
	end
end, {
		desc = "Ends an ongoing Purge Event.",
		syntax = "np_endpurge",
		args = 0
} );

NOOB_ADMIN:CreateCommand( "disorientate", "admin", function( _self, val )
	local other = doplayercheck( val )
	if ( other ) then
		NOOB_ADMIN:Notification( _self:Nick( ), "has disorientated", other:Nick( ),", what an asshole." )
		other:DisorientPlayer( math.random( 7, 15 ) )
		local mes = _self:NiceInfo( ) .. " has disorientated " .. other:Nick( )
		NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, mes, false )
	end
end, {
		desc = "Show off your^douchebaggeryness and^disorientate fuckers.",
		syntax = "np_disorientate <player>",
		args = 1
} );

NOOB_ADMIN:CreateCommand( "freeze", "admin", function( _self, val )
	local other = doplayercheck( val )
	if ( other ) then
		if ( other:IsFrozen( ) ) then
			_self:ErrorNotify( "That player is already frozen." )
			return
		end
		NOOB_ADMIN:Notification( _self:Nick( ), "has frozen", other:Nick( ) .. "." )
		other:Freeze( true )
		other:setDarkRPVar( "PlayerColorMod", { r = 25, g = 25, b = 175, a = 255 } )
		local mes = _self:NiceInfo( ) .. " has frozen " .. other:Nick( ) .. "."
		NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, mes, false )
	end
end, {
		desc = "Freeze a player rendering^them unable to do anything.",
		syntax = "np_freeze <player>",
		args = 1
} );

NOOB_ADMIN:CreateCommand( "unfreeze", "admin", function( _self, val )
	local other = doplayercheck( val )
	if ( other ) then
		if not ( other:IsFrozen( ) ) then
			_self:ErrorNotify( "That player is not frozen." )
			return
		end
		NOOB_ADMIN:Notification( _self:Nick( ), "has unfroze", other:Nick( ) .. "." )
		other:Freeze( false )
		other:setDarkRPVar( "PlayerColorMod", nil )
		local mes = _self:NiceInfo( ) .. " has unfroze " .. other:Nick( ) .. "."
		NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, mes, false )
	end
end, {
		desc = "Unfreeze a player allowing^them to move and act again.",
		syntax = "np_unfreeze <player>",
		args = 1
} );

NOOB_ADMIN:CreateCommand( "disease", "admin", function( _self, val )
	local other = doplayercheck( val )
	if ( other ) then
		NOOB_ADMIN:Notification( _self:Nick( ), "has given", other:Nick( ),"a contagious disease, oh fuck." )
		other:InfectPlayer( other )
		local mes = _self:NiceInfo( ) .. " gave " .. other:Nick( ) .. " a disease"
		NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, mes, false )
	end
end, {
		desc = "Nothing more fun then^spreading out a deadly disease.",
		syntax = "np_disease <player>",
		args = 1
} );

NOOB_ADMIN:CreateCommand( "revive", "admin", function( _self, val )
	local other = doplayercheck( val );
	if ( other ) then
		//if ( other:getDarkRPVar( "IsGhost" ) ) then
		if ( other:IsGhost( ) ) then
			NOOB_ADMIN:Notification( _self:Nick( ), "has brought", other:Nick( ), "back to life!" );
			other:RevivePlayer( );
			local mes = _self:NiceInfo( ) .. " has revived " .. other:Nick( )
			NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, mes, false )
		else
			DarkRP.notify( _self, 1, 4, "That player is currently alive." );
		end
	end
end, {
	desc = "Revives a player if they're^dead, and respawns them at ^their corpse, will do nothing^if they're alive.",
	syntax = "np_revive <player>",
	args = 1
} );

NOOB_ADMIN:CreateCommand( "setrank", "superadmin", function( _self, val, rank )
	local other = doplayercheck( val );
	if ( other ) then
		NOOB_ADMIN:Notification( _self:Nick(), "has granted", rank, "status on", other:Nick().."." );
		other:SetRank( rank, true );
		if ( rank == "vip" or rank == "admin" or rank == "superadmin" ) then
			NOOB_ADMIN_VIPTABLE[other:SteamID( )] = true
		end
		local mes = _self:Nick( ) .. " has set " .. other:Nick( ) .. "'s rank to " .. rank
		NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
	end
end, {
	desc = "Sets the rank of a player,^it also sets their usergroup^as well.",
	syntax = "np_setrank <player> <rank>",
	args = 2
} );

NOOB_ADMIN:CreateCommand( "remrank", "superadmin", function( _self, val )
	local other = doplayercheck( val );
	if ( other ) then
		if ( other:GetRank() != "" ) then
			-- set player to VIP
			NOOB_ADMIN:Notification( _self:Nick(), "revoked", other:Nick().."'s", other:GetRank(), "status." );
			other:RemoveRank();
			local mes = _self:Nick( ) .. " has revoked " .. other:Nick( ) .. "'s rank"
			NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
		end
	else
		if ( val:find( "STEAM_" ) ) then
			val = mySQLControl:Escape( val ); val = "'"..val.."'";
			mySQLControl:Query( "SELECT * FROM noobadmin_ranks WHERE steamid = "..val.." LIMIT 1;", function( data )
				if ( #data > 0 ) then
					mySQLControl:Query( "DELETE FROM noobadmin_ranks WHERE steamid = "..val..";" );
				end
			end );
		end
	end
end, {
	desc = "Revokes the player's current^rank, deletes them from the^database entirely.",
	syntax = "np_remrank <player>",
	args = 1
} );

NOOB_ADMIN:CreateCommand( "spectate", "admin", function( _self, val, mode )
	local other = nil
	if ( val ) then other = doplayercheck( val ) end
	if ( _self:GetObserverMode( ) == OBS_MODE_NONE ) then _self.spawnPosOverride = _self:GetPos( ) end
	_self:SetMoveType( MOVETYPE_OBSERVER )
	if ( other ) then
		if ( other:IsAdmin() and !_self:IsSuperAdmin() ) then 
			_self:ChatPrint( "You can't spectate other admins." );
			return;
		end
		_self:StripWeapons( )
		local notifyMsg = nil
		if not ( mode ) then notifyMsg = "No mode specified, or an invalid one, entering chase spectate mode." end
		local obsMode = string.lower( ( mode or "chase" ) )
		if ( obsMode == "chase" or obsMode == "1" ) then
			if ( notifyMsg ) then _self:ChatPrint( notifyMsg ) end
			_self:Spectate( OBS_MODE_CHASE )
		elseif ( obsMode == "fixed" or obsMode == "2" ) then
			_self:Spectate( OBS_MODE_FIXED )
		elseif ( obsMode == "eye" or obsMode == "3" ) then
			_self:Spectate( OBS_MODE_IN_EYE ) 
		end
		_self:SpectateEntity( other )
		_self:ChatPrint( "You're now spectating " .. other:Nick( ) .. " | ( " .. other:SteamID( ) .. " ) " )
	else
		_self:Spectate( OBS_MODE_ROAMING )
		_self:StripWeapons( )
		_self:ChatPrint( "You specified no player, or an invalid one, entering free-roam spectate." )
	end
end, {
	desc = "Allows you to spectate players^with three different modes.^No arguments for free-roaming.",
	syntax = "np_spectate <player> <mode>",
	args = 2
} );

NOOB_ADMIN:CreateCommand( "unspectate", "admin", function( _self )
	if ( _self:GetObserverMode( ) == OBS_MODE_NONE ) then return end
	_self:UnSpectate( )
	_self:Spawn( )
	_self:SetMoveType( MOVETYPE_WALK )
	_self.spawnPosOverride = false
	_self:ChatPrint( "You are no longer spectating." )
	_self:setSelfDarkRPVar( "SpectateESP", false )
end, {
	desc = "Leaves spectate mode, returns^you to your original position.",
	syntax = "np_unspectate",
	args = 0
} );

NOOB_ADMIN:CreateCommand( "noclip", "admin", function( _self )
	local mes = _self:NiceInfo( true )
	if ( _self:GetMoveType( ) == MOVETYPE_NOCLIP ) then
		NOOB_ADMIN:Notification( _self:Nick( ), "is no longer noclipping." )
		_self:SetMoveType( MOVETYPE_WALK )
		mes = mes .. " has disabled noclipping"
	elseif ( _self:GetMoveType( ) == MOVETYPE_WALK ) then
		NOOB_ADMIN:Notification( _self:Nick( ), "is now noclipping." )
		_self:SetMoveType( MOVETYPE_NOCLIP )
		mes = mes .. " has enabled noclipping"
	end
	NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, mes, false )
end, {
	desc = "Toggles between noclipping,^this command should rarely^be used.",
	syntax = "np_noclip",
	args = 0
} );

NOOB_ADMIN:CreateCommand( "sanoclip", "superadmin", function( _self )
	local mes = _self:NiceInfo( true )
	if ( _self:GetMoveType( ) == MOVETYPE_NOCLIP ) then
		_self:SetMoveType( MOVETYPE_WALK )
		mes = mes .. " has disabled noclipping"
	elseif ( _self:GetMoveType( ) == MOVETYPE_WALK ) then
		_self:SetMoveType( MOVETYPE_NOCLIP )
		mes = mes .. " has enabled noclipping"
	end
	NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, mes, false )
end, {
	desc = "Toggles between noclipping,^this command should rarely^be used.",
	syntax = "np_sanoclip",
	args = 0
} );

NOOB_ADMIN:CreateCommand( "cleanupents", "admin", function( _self )
	local shipmentEnts = ents.FindByClass( "spawned_shipment" );
	local weaponEnts = ents.FindByClass( "spawned_weapon" );
	local moneyEnts = ents.FindByClass( "spawned_money" );
	local ammoEnts = ents.FindByClass( "spawned_ammo" );
	if ( #shipmentEnts > 0 ) then
		for index, ent in ipairs ( shipmentEnts ) do
			SafeRemoveEntity( ent )
		end
	end
	if ( #weaponEnts > 0 ) then
		for index, ent in ipairs ( weaponEnts ) do
			SafeRemoveEntity( ent )
		end
	end
	if ( #moneyEnts > 0 ) then
		for index, ent in ipairs ( moneyEnts ) do
			SafeRemoveEntity( ent )
		end
	end
	if ( #ammoEnts > 0 ) then
		for index, ent in ipairs ( ammoEnts ) do
			SafeRemoveEntity( ent )
		end
	end
	local mes = _self:NiceInfo( ) .. " has cleaned up all spawned entities"
	NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, mes, false )
	NOOB_ADMIN:Notification( _self:Nick( ), "has cleaned up all spawned shipments, weapons, money, and ammo." );
end, {
	desc = "Cleans up all spawned shipments,^weapons, money, and ammo.^You may want to give warning^before doing so.",
	syntax = "np_cleanupents",
	args = 0
} );

/*
NOOB_ADMIN:CreateCommand( "bringall", "superadmin", function( _self, range, stepSize )
	if ( #player.GetAll( ) <= 1 ) then return end
	local posRange = math.Clamp( tonumber( range ) or 512, 0, 4096 )
	local posStepSize = math.Clamp( tonumber( stepSize ) or 32, 0, 512 )
	for index, ply in ipairs ( player.GetAll( ) ) do
		//if ( ply == _self or ply:getDarkRPVar( "IsGhost" ) ) then continue end 
		if ( ply == _self or ply:IsGhost( ) ) then continue end 
		ply.posBeforeBring = ply:GetPos( )
		local goalPos = DarkRP.findEmptyPos( _self:GetPos( ), nil, posRange, posStepSize, Vector( 0, 0, 0 ) )
		ply:SetPos( goalPos )
	end
	NOOB_ADMIN:Notification( _self:Nick( ), "has brought all players." )
	local mes = _self:NiceInfo( ) .. " has brought all players"
	NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, false )
end, {
	desc = "Brings all the players^nearby you, can be take a toll^on the server with lots of^players, two optional arguments.",
	syntax = "np_bringall <range> <stepsize>",
	args = 2
} );

NOOB_ADMIN:CreateCommand( "unbringall", "superadmin", function( _self )
	if ( #player.GetAll( ) <= 1 ) then return end
	for index, ply in ipairs ( player.GetAll( ) ) do
		//if ( ply == _self or ply:getDarkRPVar( "IsGhost" ) ) then ply.posBeforeBring = nil continue end 
		if ( ply == _self or ply:IsGhost( ) ) then ply.posBeforeBring = nil continue end 
		if ( ply.posBeforeBring ) then
			ply:SetPos( ply.posBeforeBring )
			ply.posBeforeBring = nil
		end
	end
	NOOB_ADMIN:Notification( _self:Nick( ), "has returned all the players to their original position." )
	local mes = _self:NiceInfo( ) .. " has returned all brought players"
	NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, false )
end, {
	desc = "Returns all the players you^brought to their original position.",
	syntax = "np_unbringall",
	args = 0
} );
*/

NOOB_ADMIN:CreateCommand( "goto", "admin", function( _self, val )
	local other = doplayercheck( val );
	if ( other ) then
		_self.posBeforeGoto = _self:GetPos( )
		local goalPos = DarkRP.findEmptyPos( other:GetPos( ), nil, 256, 32, Vector( 0, 0, 0 ) )
		_self:SetPos( goalPos );
		NOOB_ADMIN:Notification( _self:Nick( ), "has gone to", other:Nick( ), "." )
		local mes = _self:NiceInfo( true ) .. " has gone to " .. other:Nick( )
		NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, mes, false )
	end
end, {
	desc = "Teleports to a position near^the targeted player, should^be used sparingly.",
	syntax = "np_goto <player>",
	args = 1
} );

NOOB_ADMIN:CreateCommand( "ungoto", "admin", function( _self )
	if ( _self.posBeforeGoto ) then
		_self:SetPos( _self.posBeforeGoto )
		_self.posBeforeGoto = nil
		NOOB_ADMIN:Notification( _self:Nick( ), "has returned to their original position." )
		local mes = _self:NiceInfo( true ) .. " has returned to their position"
		NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, mes, false )
	end
end, {
	desc = "Teleports you back to your^position before you went to a^player, will do nothing if^no pos is stored.",
	syntax = "np_ungoto",
	args = 0
} );

NOOB_ADMIN:CreateCommand( "bring", "admin", function( _self, val )
	local other = doplayercheck( val );
	if ( other ) then
		other.posBeforeBring = other:GetPos( )
		local goalPos = DarkRP.findEmptyPos( _self:GetPos( ), nil, 256, 32, Vector( 0, 0, 0 ) )
		other:SetPos( goalPos ); 
		NOOB_ADMIN:Notification( _self:Nick( ), "has brought", other:Nick( ), "." )
		local mes = _self:NiceInfo( true ) .. " has brought " .. other:Nick( )
		NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, mes, false )
	end
end, {
	desc = "Brings a player to a^position nearby you, use this^sparingly.",
	syntax = "np_bring <player>",
	args = 1
} );

NOOB_ADMIN:CreateCommand( "unbring", "admin", function( _self, val )
	local other = doplayercheck( val )
	if ( other ) then
		if ( other.posBeforeBring ) then
			other:SetPos( other.posBeforeBring )
			other.posBeforeBring = nil
			NOOB_ADMIN:Notification( _self:Nick( ), "has brought", other:Nick( ), "back to their original position." )
			local mes = _self:NiceInfo( true ) .. " has returned " .. other:Nick( )
			NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, mes, false )
		end
	end
end, {
	desc = "Teleports the player back to^their position before you^brought them, will do nothing^ifno pos is stored.",
	syntax = "np_unbring <player>",
	args = 1
} );

NOOB_ADMIN:CreateCommand( "motd", "superadmin", function( _self, str )
	SHNOOB_VARS:Set( "MOTD", str );
end, {
	desc = "Sets the message that^displays on the MOTD entity,^it supports the next line^characters.",
	syntax = "np_motd <message>",
	args = 1
} );

NOOB_ADMIN:CreateCommand( "tp", "admin", function( _self, str )
	local telePos = _self:GetEyeTrace( ).HitPos
	_self:SetPos( telePos );
	local mes = _self:NiceInfo( true ) .. " has teleported to: " .. tostring( telePos )
	NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, mes, false )
end, {
	desc = "Teleports you to the^position that you are looking at.",
	syntax = "np_tp",
	args = 0
} );

NOOB_ADMIN:CreateCommand( "admins", "admin", function( _self, str )
	_self:SendColoredMessage( { Color( 175, 175, 255 ), "All Online Admins:" } )
	for index, ply in ipairs ( player.GetAll( ) ) do
		if ( ply:IsAdmin( ) ) then
			if ( ply.isMarkedAFK ) then
				_self:SendColoredMessage( { team.GetColor( ply:Team( ) ), ply:Name( ), Color( 255, 255, 255 ), " was last active " .. string.NiceTime( CurTime( ) - ply.isMarkedAFK ) } )
			else
				_self:SendColoredMessage( { team.GetColor( ply:Team( ) ), ply:Name( ), Color( 255, 255, 255 ), " is not AFK." } )
			end
		end
	end
end, {
	desc = "Shows all the online admins^ and if they're AFK.",
	syntax = "np_admins",
	args = 0
} );

NOOB_ADMIN:CreateCommand( "mostafk", "admin", function( _self, str )
	local foundAFK = false
	local afkTable = { }
	for index, ply in ipairs ( player.GetAll( ) ) do
		if ( ply.isMarkedAFK ) then
			foundAFK = true
			table.insert( afkTable, { ply = ply, time = ( CurTime( ) - ply.isMarkedAFK ) } )
		end
	end
	if not ( foundAFK ) then
		DarkRP.notify( _self, 1, 4, "There are no players marked AFK." )
	else
		table.SortByMember( afkTable, "time" )
		DarkRP.notify( _self, 1, 4, afkTable[1].ply:Name( ) .. " is the most AFK, they have been away for " .. string.NiceTime( afkTable[1].time ) )
	end
end, {
	desc = "Gets the most AFK player^ and displays the time.",
	syntax = "np_mostafk",
	args = 0
} );

NOOB_ADMIN:CreateCommand( "checkrevenges", "admin", function( _self, str )
	local other = doplayercheck( str )
	if ( IsValid( other ) and istable( other.revengeTable ) ) then
		local builtString = ""
		for index, revenge in pairs ( other.revengeTable ) do
			local ply = doplayercheck( index )
			if ( IsValid( ply ) ) then
				builtString = builtString .. ply:Name( ) .. ", "
			end
		end
		_self:SendColoredMessage( { Color( 255, 175, 175 ), other:Name( ) .. "'s Revenges:" } )
		_self:SendColoredMessage( { Color( 175, 175, 255 ), builtString } )
	else
		DarkRP.notify( _self, 1, 4, "Either the player was invalid or they have no revenges." )
	end
end, {
	desc = "Prints all the player's who are online^that the target player has revenge on.",
	syntax = "np_checkrevenges <player>",
	args = 1
} );

NOOB_ADMIN:CreateCommand( "kick", "admin", function( _self, str, reason )
	local other = doplayercheck( str );
	if ( other and !other:IsSuperAdmin() ) then
		_self:ConCommand( 'np_note "' .. other:UserID( ) .. '" "' .. "(KICK): " .. reason .. '"' )
		local mes = _self:NiceInfo( ) .. " has kicked " .. other:Nick( ) .. " for ( " .. reason .. " )"
		NOOB_ADMIN:Notification( _self:Nick( ), "has kicked", other:Nick( ), "(", reason, ")" )
		timer.Simple( 1, function( )
			if ( !IsValid( _self ) or !IsValid( other ) ) then return end
			other:NoobKick( "You've been kicked by: ".._self:Nick(), "Reason: "..reason );
		end )
		NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, false )
	end
end, {
	desc = "Kicks a player with the^provided reason, try to use^this over bans.",
	syntax = "np_kick <player> <reason>",
	args = 2
} );

NOOB_ADMIN:CreateCommand( "ban", "admin", function( _self, str, time, reason )
	time = tonumber( time );
	if ( !str or !time or !reason ) then return end
	if ( ( _self:IsAdmin() and time < 1 or time > 10800 ) and !_self:IsSuperAdmin( ) ) then
		_self:ChatPrint( "You can't ban permanently or over 10800 minutes. Contact a superadmin if needed." );
		return;
	end

	local other = doplayercheck( str );
	if ( other and !other:IsSuperAdmin() ) then
		NOOB_ADMIN:Notification( _self:Nick( ), "has banned", other:Nick( ), "for", time, "minutes.", "(", reason, ")" )
		other:NoobBan( time, reason, _self:Nick() ); 
	end
end, {
	desc = "Bans a player for the^specified amount of time with^a reason, maximum is 10800^for regular admins.",
	syntax = "np_ban <player> <time> '<reason>'",
	args = 3
} );

NOOB_ADMIN:CreateCommand( "silentban", "superadmin", function( _self, str, time, reason )
	time = tonumber( time );
	if ( !str or !time or !reason ) then return end

	local other = doplayercheck( str );
	if ( other and !other:IsSuperAdmin() ) then
		other:NoobBan( time, reason, _self:Nick() ); 
	end
end, {
	desc = "Bans a player silenty for the^specified amount of time with^a reason.",
	syntax = "np_silentban <player> <time> '<reason>'",
	args = 3
} );

NOOB_ADMIN:CreateCommand( "banid", "admin", function( _self, str, time, reason )
	time = tonumber( time )
	if ( !str or !time or !reason ) then return end
	if ( ( _self:IsAdmin() and time < 1 or time > 10800 ) and !_self:IsSuperAdmin( ) ) then
		_self:ChatPrint( "You can't ban permanently or over 10800 minutes. Contact a superadmin if needed." );
		return;
	end

	if ( str ) then
		if ( NOOB_ADMIN_BANTABLE[ str ] ) then
			if ( NOOB_ADMIN_BANTABLE[ str ].time > os.time( ) or NOOB_ADMIN_BANTABLE[ str ].time == 0 ) then
				_self:ChatPrint( "The SteamID [ " .. str .. " ] is currently banned, ceasing ban attempt." )
				return
			end
		end
		NOOB_ADMIN:Notification( _self:Nick( ), "has banned SteamID [,", str, "] for", time, "minutes.", "(", reason, ")" )
		NOOB_ADMIN:BanID( str, time, reason, _self:Nick( ) )
	end
end, {
	desc = "Bans a player by their^SteamID, for offline banning.",
	syntax = "np_banid '<steamid>' <time> '<reason>'",
	args = 3
})

NOOB_ADMIN:CreateCommand( "silentbanid", "superadmin", function( _self, str, time, reason )
	time = tonumber( time )
	if ( !str or !time or !reason ) then return end

	if ( str ) then
		if ( NOOB_ADMIN_BANTABLE[ str ] ) then
			if ( NOOB_ADMIN_BANTABLE[ str ].time > os.time( ) or NOOB_ADMIN_BANTABLE[ str ].time == 0 ) then
				_self:ChatPrint( "The SteamID [ " .. str .. " ] is currently banned, ceasing ban attempt." )
				return
			end
		end
		NOOB_ADMIN:BanID( str, time, reason, _self:Nick( ) )
	end
end, {
	desc = "Bans a player by their^SteamID silently, for offline banning.",
	syntax = "np_silentbanid '<steamid>' <time> '<reason>'",
	args = 3
})

NOOB_ADMIN:CreateCommand( "unban", "superadmin", function( _self, str )
	local unbanID = str
	if not ( NOOB_ADMIN_BANTABLE[str] ) then
		_self:ChatPrint( "The SteamID [ " .. str .. " ] is not currently banned." )
		return
	else
		local expireTime = NOOB_ADMIN_BANTABLE[str].time
		if ( ( expireTime > os.time( ) or expireTime == 0 ) ) then
			NOOB_ADMIN:Notification( _self:Nick( ), "has unbanned SteamID [", str, "]." )
			NOOB_ADMIN:UnBan( str )
			local mes = _self:NiceInfo( ) .. " has unbanned ( " .. str .. " )"
			NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
		else
			_self:ChatPrint( "The SteamID [ " .. str .. " ] is not currently banned." )
			NOOB_ADMIN_BANTABLE[str] = nil
		end
	end
end, {
	desc = "Unbans a currently^banned player.",
	syntax = "np_unban <steamid>",
	args = 1	
} )

NOOB_ADMIN:CreateCommand( "note", "admin", function( _self, str, msg )
	if ( !str or !msg ) then return end
	file.CreateDir( "noobadmin" )
	file.CreateDir( "noobadmin/notes" )
	// local foundPly = DarkRP.findPlayer( str )
	local foundPly = doplayercheck( str );
	if not ( IsValid( foundPly ) ) then
		DarkRP.notify( _self, 1, 4, "That player could not be found." )
		return
	else
		local fileDir = "noobadmin/notes/"
		local fileName = foundPly:SteamID64( ) .. ".txt"
		local curNotes = { }
		if ( file.Exists( fileDir .. fileName, "DATA" ) ) then
			curNotes = util.JSONToTable( file.Read( fileDir .. fileName, "DATA" ) )
			table.insert( curNotes, { time = os.time( ), admin = _self:Nick( ), note = msg } )
			file.Write( fileDir .. fileName, util.TableToJSON( curNotes ) )
		else
			table.insert( curNotes, { time = os.time( ), admin = _self:Nick( ), note = msg } )
			file.Write( fileDir .. fileName, util.TableToJSON( curNotes ) )
		end
		_self:ChatPrint( "Created a note for: " .. foundPly:Name( ) .. "\nMessage: " .. msg )
	end
end, {
	desc = "Write a note for^admins about a player.^Such as when you warn^somebody.",
	syntax = "np_note <player> '<msg>'",
	args = 2
} )

NOOB_ADMIN:CreateCommand( "notes", "admin", function( _self, str )
	if not ( str ) then return end
	// local foundPly = DarkRP.findPlayer( str )
	local foundPly = doplayercheck( str );
	if not ( IsValid( foundPly ) ) then
		DarkRP.notify( _self, 1, 4, "That player could not be found." )
		return
	else
		local fileDir = "noobadmin/notes/"
		local fileName = foundPly:SteamID64( ) .. ".txt"
		if not ( file.Exists( fileDir .. fileName, "DATA" ) ) then
			DarkRP.notify( _self, 1, 4, "That player has no notes." )
			return
		else
			local noteTable = util.JSONToTable( file.Read( fileDir .. fileName, "DATA" ) )
			DarkRP.notify( _self, 2, 4, "Printing " .. #noteTable .. " note(s) to console." )
			for index, noteData in SortedPairsByMemberValue( noteTable, "time", false ) do
				local date = os.date( "%x", noteData.time )
				_self:PrintMessage( HUD_PRINTCONSOLE, "Date: " .. date .. "\nAdmin: " .. noteData.admin .. "\nNote: " .. noteData.note .. "\n" )
				net.Start( "N00BRP_NotesMenu" )
					net.WriteTable( { date = date, admin = noteData.admin, note = noteData.note } )
				net.Send( _self )
			end
		end
	end
end, {
	desc = "Get the notes^about a player for looking^up their history.",
	syntax = "np_notes <player>",
	args = 1
})

NOOB_ADMIN:CreateCommand( "searchforprops", "admin", function( _self )
	local boxMins = ClampWorldVector( _self:GetPos( ) - Vector( 250, 250, 250 ) )
	local boxMaxs = ClampWorldVector( _self:GetPos( ) + Vector( 250, 250, 250 ) )
	local entTable = ents.FindInBox( boxMins, boxMaxs )
	if ( istable( entTable ) and #entTable > 0 ) then
		for index, ent in ipairs ( entTable ) do
			if ( ent:GetClass( ) == "prop_physics" and isfunction( ent.CPPIGetOwner ) and IsValid( ent:CPPIGetOwner( ) ) ) then
				_self:SendColoredMessage( { Color( 255, 175, 175 ), "Model", Color( 255, 255, 255 ), ": " .. ent:GetModel( ) } )
				_self:SendColoredMessage( { Color( 255, 175, 175 ), "Is Fading Door", Color( 255, 255, 255 ), ": " .. tostring( ( ent.isFadingDoor or false ) ) } )
				_self:SendColoredMessage( { Color( 255, 175, 175 ), "Owner", Color( 255, 255, 255 ), ": " .. ent:CPPIGetOwner( ):Name( ) } )
			end
		end
	else
		_self:ErrorNotify( "There are no props near you.")
	end

end, {
	desc = "Searches for props nearby you.^Indicates whether they're a fading door.",
	syntax = "np_searchforprops",
	args = 0
} )

NOOB_ADMIN:CreateCommand( "cruisecontrol", "superadmin", function( _self )
	local veh = _self:GetVehicle();
	if ( !IsValid( veh ) ) then return; end
	if ( !veh.CruiseControlled ) then
		local vel = veh:GetVelocity();
		timer.Create( "cruisecontrol_"..tostring( veh:EntIndex() ), 0, 0, function()
			if ( veh:GetPhysicsObject() ) then
				veh:GetPhysicsObject():SetVelocity( vel );
			end
		end );
		veh.CruiseControlled = true;
	else
		timer.Destroy( "cruisecontrol_"..tostring( veh:EntIndex() ) );
		veh.CruiseControlled = false;
	end
end,
{ 
	desc = "",
	syntax = "np_cruisecontrol",
	args = 0
} );

NOOB_ADMIN:CreateCommand( "killsilent", "superadmin", function( _self, str )
	if not ( str ) then return end
	// local foundPly = DarkRP.findPlayer( str )
	local foundPly = doplayercheck( str );
	if not ( IsValid( foundPly ) ) then
		DarkRP.notify( _self, 1, 4, "That player could not be found." )
		return
	else
		foundPly:KillSilent()
	end
end,
{ 
	desc = "Performs silent kill on player.",
	syntax = "np_killsilent <player>",
	args = 1
} );

NOOB_ADMIN:CreateCommand( "setglobalvar", "superadmin", function( _self, var, value, silent )
	if not ( SVNOOB_VARS[ var ] ) then _self:ErrorNotify( "That Global Variable doesn't exist." ) return end
	local val = SVNOOB_VARS[ var ]
	local valType = type( val )
	if ( valType ~= "number" and valType ~= "string" ) then _self:ErrorNotify( "Global Variable needs to be a number or a string." ) return end
	if not ( value ) then _self:ErrorNotify( "You must enter a value to change it to." ) return end
	local newVal = value
	if ( valType == "number" ) then
		if not ( tonumber( newVal ) ) then
			_self:ErrorNotify( "You must enter a valid number to change the value to." )
			return
		else
			newVal = tonumber( newVal )
		end
	end
	if not ( valType == type( newVal ) ) then
		_self:ErrorNotify( "Unable to set the Global Variable to a different type." )
		return
	end
	if not ( tobool( silent ) ) then
		DarkRP.notifyAll( NOTIFY_HINT, 4, "(ADMIN) " .. _self:Name( ) .. " has changed the Global Variable [ " .. var .. " ] to " .. newVal .. "!" )
	end
	SVNOOB_VARS:Set( var, newVal )
	local mes = _self:NiceInfo( ) .. " has set the Global Variable [ " .. var .. " ] to " .. newVal
	NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
end, {
	desc = "Sets a Global Variable temporarily to the^specified value, use with caution.",
	syntax = "np_setglobalvar <var> <val> <silent>",
	args = 3
} )

NOOB_ADMIN:CreateCommand( "listglobalvars", "superadmin", function( _self )
	_self:SendColoredMessage( { Color( 89, 171, 227 ), "Global Variables: " } )
	for var, val in pairs ( SVNOOB_VARS ) do
		local valType = type( val )
		if ( valType ~= "string" and valType ~= "number" ) then continue end
		_self:SendColoredMessage( { Color( 255, 255, 255 ), "Name: ", Color( 63, 195, 128 ), tostring( var ), Color( 255, 255, 255 ), " | Value: ", Color( 210, 77, 87 ), tostring( val ) } )
	end
end,
{ 
	desc = "Lists all of the Global Variables^that you may change.",
	syntax = "np_listglobalvars",
	args = 0
} );

NOOB_ADMIN:CreateCommand( "resetnoobtimers", "superadmin", function( _self )
	_self:SuccessNotify( "Reseting all of the noob looping timers." )
	NOOBRP.StartEntitySpawningTimer( )
	NOOBRP.StartPropCleanupTimer( )
	NOOBRP.StartMessageBroadcastTimer( )
	NOOBRP.StartElevatorFixTimer( )
end, {
	desc = "Resets the looping timers such^as herb spawning and prop cleanup.^Used when changing a global variable.",
	syntax = "np_resetnoobtimers",
	args = 0
} )

NOOB_ADMIN:CreateCommand( "hideme", "admin", function( _self )
	if ( _self:getDarkRPVar( "AdminHidden" ) ) then
		_self:SuccessNotify( "You're no longer hiding yourself from the Scoreboard." )
		_self:setDarkRPVar( "AdminHidden", false )
	else
		_self:SuccessNotify( "You are now hiding yourself from the Scoreboard." )
		_self:setDarkRPVar( "AdminHidden", true )
	end
end, {
	desc = "Toggles whether you're hidden^from the scoreboard or not.",
	syntax = "np_hideme",
	args = 0
} );

NOOB_ADMIN:CreateCommand( "freezeallprops", "admin", function( _self )
	local foundProps = ents.FindByClass( "prop_physics" )
	if not ( istable( foundProps ) ) then
		_self:ErrorNotify( "No props seem to be spawned." )
		return
	end
	local propCount = 0
	for index, prop in ipairs ( foundProps ) do
		if ( IsValid( prop ) ) then
			local physObj = prop:GetPhysicsObject( )
			if ( physObj:IsValid( ) and physObj:IsMotionEnabled( ) ) then
				propCount = propCount + 1
				physObj:EnableMotion( false )
			end
		end
	end
	_self:SuccessNotify( "You froze " .. tostring( propCount ) .. " unfrozen props!" )
end, {
	desc = "Loops through all spawned props^and freezes the unfrozen ones.",
	syntax = "np_freezeallprops",
	args = 0
} );

NOOB_ADMIN:CreateCommand( "setplayermodel", "admin", function( _self, model )
	if not ( model ) then
		_self:ErrorNotify( "You must specify a model!" )
		return
	end
	local chosenModel = player_manager.TranslatePlayerModel( model )
	if ( chosenModel == "models/player/kleiner.mdl" and ( model ~= "models/player/kleiner.mdl" or model ~= "kleiner" ) ) then
		chosenModel = model
	end
	if not ( util.IsValidModel( chosenModel ) ) then
		_self:ErrorNotify( "You have chosen an invalid model!" )
		return
	end
	_self:SetModel( chosenModel )
	_self:SuccessNotify( "You changed your player model to: [ " .. chosenModel .. " ]!" )
end,
{ 
	desc = "Sets your player model. You can either^type the full path or use^the short names from your context menu.",
	syntax = "np_setplayermodel <model>",
	args = 1
} );

NOOB_ADMIN:CreateCommand( "setmyscale", "admin", function( _self, scale )
	if not ( tonumber( scale ) ) then
		_self:ErrorNotify( "You must specify a valid scale!" )
		return
	end
	local scale = tonumber( scale )
	if ( scale > 10 or scale < 0.01 ) then
		_self:ErrorNotify( "The specified scale must be between 0.01 and 10!" )
		return
	end
	_self:SetModelScale( scale, 0 )
	_self:ScaleViewOffset( scale )
	_self:ScaleHull( scale, false )
	_self:ApplyMovementSpeed( )
	_self:SuccessNotify( "You changed your Model Scale to: [ " .. scale .. " ]" )
end, {
	desc = "Changes your Model Scale.^Use this command with care.",
	syntax = "np_setmyscale <scale>",
	args = 1
} );

NOOB_ADMIN:CreateCommand( "setscale", "superadmin", function( _self, scale )
	if not ( tonumber( scale ) ) then
		_self:ErrorNotify( "You must specify a valid scale!" )
		return
	end
	local scale = tonumber( scale )
	local traceEnt = _self:GetEyeTrace( ).Entity
	if ( !IsValid( traceEnt ) or traceEnt:IsWorld( ) ) then
		_self:ErrorNotify( "You aren't looking at a valid entity!" )
		return
	end
	if ( traceEnt:IsPlayer( ) ) then
		traceEnt:SetModelScale( scale, 0 )
		traceEnt:ScaleViewOffset( scale )
		traceEnt:ScaleHull( scale, false )
		traceEnt:ApplyMovementSpeed( )
		_self:SuccessNotify( "You changed the Model Scale for [ " .. traceEnt:Nick( ) .. " ] to [ " .. scale .. " ]" )
	else
		traceEnt:SetModelScale( scale, 0 )
		_self:SuccessNotify( "You changed the Model Scale for [ " .. traceEnt:GetClass( ) .. " ] to [ " .. scale .. " ] " )
	end
end, {
	desc = "Changes the Model Scale for^the entity you're looking at.",
	syntax = "np_setscale <scale>",
	args = 1
} );

-- NOOB_ADMIN:CreateCommand( "neofag", "superadmin", function( _self, name )
-- 	local targetEnt = nil
-- 	if not ( name ) then
-- 		local traceEnt = _self:GetEyeTrace( ).Entity
-- 		if ( !IsValid( traceEnt ) or traceEnt:IsWorld( ) ) then
-- 			_self:ErrorNotify( "You're not looking at a valid entity." )
-- 			return
-- 		else
-- 			targetEnt = traceEnt
-- 		end
-- 	else
-- 		targetEnt = DarkRP.findPlayer( name )
-- 	end
-- 	if not ( IsValid( targetEnt ) ) then
-- 		_self:ErrorNotify( "A valid entity was not specified." )
-- 		return
-- 	else
-- 		local newVel = targetEnt:GetVelocity( )
-- 		newVel[1] = ( ( newVel[1] + 1 ) * math.random( -10, 10 ) * 100 )
-- 		newVel[2] = ( ( newVel[2] + 1 ) * math.random( -10, 10 ) * 100 )
-- 		newVel[3] = 10000
-- 		if not ( targetEnt:IsPlayer( ) ) then
-- 			local physObj = targetEnt:GetPhysicsObject( )
-- 			if ( physObj:IsValid( ) ) then
-- 				physObj:SetVelocity( newVel )
-- 				_self:SuccessNotify( "Smiting " .. targetEnt:GetClass( ) .. " with the power of Neogreen." )
-- 			end
-- 		else
-- 			targetEnt:SetVelocity( newVel )
-- 			_self:SuccessNotify( "Smiting " .. targetEnt:Nick( ) .. " with the power of Neogreen!" )
-- 		end
-- 	end
-- end, {
-- 	desc = "Smites the player, or entity^that you're looking at^with the power of Neogreen.",
-- 	syntax = "np_neofag <player>",
-- 	args = 1
-- } );

-- NOOB_ADMIN:CreateCommand( "comehither", "superadmin", function( _self, name )
-- 	local targetEnt = nil
-- 	if not ( name ) then
-- 		local traceEnt = _self:GetEyeTrace( ).Entity
-- 		if ( !IsValid( traceEnt ) or traceEnt:IsWorld( ) ) then
-- 			_self:ErrorNotify( "You're not looking at a valid entity." )
-- 			return
-- 		else
-- 			targetEnt = traceEnt
-- 		end
-- 	else
-- 		targetEnt = DarkRP.findPlayer( name )
-- 	end
-- 	if not ( IsValid( targetEnt ) ) then
-- 		_self:ErrorNotify( "A valid entity was not specified." )
-- 		return
-- 	else
-- 		if not ( targetEnt:IsPlayer( ) ) then
-- 			local physObj = targetEnt:GetPhysicsObject( )
-- 			if ( physObj:IsValid( ) ) then
-- 				local newVel = _self:GetAimVector( ) * -( 1000000000 * physObj:GetMass( ) )
-- 				physObj:SetVelocity( newVel )
-- 				_self:SuccessNotify( "Come hither " .. targetEnt:GetClass( ) .. "!" )
-- 			end
-- 		else
-- 			targetEnt:SetVelocity( _self:GetAimVector( ) * -1000 )
-- 			_self:SuccessNotify( "Come hither " .. targetEnt:Nick( ) .. "!" )
-- 		end
-- 	end
-- end, {
-- 	desc = "Brings the player or^entity that you're looking at^towards you.",
-- 	syntax = "np_comehither <player>",
-- 	args = 1
-- } );

/*
NOOB_ADMIN:CreateCommand( "rippydippy", "superadmin", function( _self, name )
	local canRun = _self:IsValidSuperAdmin( )
	if not ( canRun ) then
		_self:ErrorNotify( "You cannot run this command!" )
		return
	end
	if not ( name ) then
		_self:ErrorNotify( "You must specify a player's name!" )
		return
	end
	local foundPlayer = doplayercheck( name )
	if not ( IsValid( foundPlayer ) ) then
		_self:ErrorNotify( "That player could not be found!" )
		return
	else
		_self:SuccessNotify( "Rippy Dippy " .. foundPlayer:Nick( ) .. "!" )
		NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, _self:NiceInfo( ) .. " ran rippy dippy on " .. foundPlayer:NiceInfo( ), true )
		foundPlayer:SendLua( "cam.End3D( )" )
	end
end, {
	desc = "rippy dippy skippy",
	syntax = "np_rippydippy <name>",
	args = 1
} );
*/

/*
NOOB_ADMIN:CreateCommand( "forceplayersay", "superadmin", function( _self, name, message )
	if not ( name ) then
		_self:ErrorNotify( "You must specify a player's name!" )
		return
	end
	if not ( message ) then
		_self:ErrorNotify( "You must specify a message!" )
		return
	end
	local foundPlayer = doplayercheck( name )
	if not ( IsValid( foundPlayer ) ) then
		_self:ErrorNotify( "That player could not be found!" )
		return
	else
		foundPlayer:Say( message )
	end
end, {
	desc = "Forces a player to say something.",
	syntax = "np_forceplayersay <name> <message>",
	args = 2
} );
*/

NOOB_ADMIN:CreateCommand( "toggleadminphysgun", "admin", function( _self )
	if not ( _self.adminPhysgunDisabled ) then
		_self.adminPhysgunDisabled = true
		_self:SuccessNotify( "You disabled being able to physgun other player's props." )
	else
		_self.adminPhysgunDisabled = false
		_self:SuccessNotify( "You enabled being able to physgun other player's props." )
	end
end, {
	desc = "Toggles whether you can physgun^other players props or not.",
	syntax = "np_toggleadminphysgun",
	args = 0
} );

/*
NOOB_ADMIN:CreateCommand( "runlua", "superadmin", function( _self, lua )
	// Extra proection just incase someone somehow gol superadmin that shouldn't have.
	local canRun = _self:IsValidSuperAdmin( )
	if not ( canRun ) then
		_self:ErrorNotify( "You cannot run Lua!" )
		return
	else
		if not ( lua ) then
			_self:ErrorNotify( "You must specify Lua to run!" )
			return
		else
			_self:SuccessNotify( "Running Luad:\n" .. tostring( lua ) )
			NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, _self:NiceInfo( ) .. " ran Lua [ " .. lua .. " ]", true )
			RunString( lua )
		end
	end
end, {
	desc = "Runs the specified Lua on the server.",
	syntax = "np_runlua <lua>",
	args = 1
} );
*/

NOOB_ADMIN:CreateCommand( "togglemotion", "superadmin", function( _self )
	local traceEnt = _self:GetEyeTrace( ).Entity
	if ( IsValid( traceEnt ) and traceEnt:GetClass( ) == "prop_physics" and traceEnt:GetPhysicsObject( ):IsValid( ) ) then
		local physObj = traceEnt:GetPhysicsObject( )
		if ( physObj:IsMotionEnabled( ) ) then
			physObj:EnableMotion( false )
			_self:SuccessNotify( "You've froze [ " .. traceEnt:EntIndex( ) .. " ] prop_physics." )
		else
			physObj:EnableMotion( true )
			_self:SuccessNotify( "You've unfroze [ " .. traceEnt:EntIndex( ) .. " ] prop_physics." )
		end
	else
		_self:ErrorNotify( "You're not looking at a valid entity." )
	end
end, {
	desc = "Toggles whether you're hidden^from the scoreboard or not.",
	syntax = "np_hideme",
	args = 0
} );
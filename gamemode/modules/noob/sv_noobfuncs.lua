NOOBRP = NOOBRP or { }
NOOBRP.PurgeDurationItems = NOOBRP.PurgeDurationItems or { }
NOOBRP.StatusTrackers = NOOBRP.StatusTrackers or { }
NOOBRP.StatusTrackers.currentRespawnTimers = NOOBRP.StatusTrackers.currentRespawnTimers or { }
NOOBRP.StatusTrackers.ArrestedPlayers = { }
NOOBRP.StatusTrackers.CurrentMurderers = { }
NOOBRP.TeamSpawns = { }
NOOBRP.JailPoses = { }

function NOOBRP:RetrieveJailPositions( )
	mySQLControl:Query( "SELECT id, x, y, z FROM darkrp_position WHERE map = " .. SQLStr( game.GetMap( ) ) .. " AND type = 'J';", function( data )
		if ( data and #data > 0 ) then
			for index, datTbl in pairs ( data ) do
				local jailPos = Vector( datTbl.x, datTbl.y, datTbl.z )
				table.insert( NOOBRP.JailPoses, jailPos )
			end
		end
	end )
end

function NOOBRP:RetrieveTeamSpawns( )
	mySQLControl:Query( "SELECT id, x, y, z FROM darkrp_position WHERE map = " .. SQLStr( game.GetMap( ) ) .. " AND type = 'T';", function( data )
		if ( data and #data > 0 and data[1] ) then
			for index, datTbl in pairs ( data ) do
				mySQLControl:Query( "SELECT team FROM darkrp_jobspawn WHERE id = " .. datTbl.id .. ";", function( dat )
					if ( dat and #dat > 0 and dat[1] ) then
						local jobTeam = dat[1].team
						local jobSpawn = Vector( datTbl.x, datTbl.y, datTbl.z )
						NOOBRP.TeamSpawns[jobTeam] = NOOBRP.TeamSpawns[jobTeam] or { }
						table.insert( NOOBRP.TeamSpawns[jobTeam], jobSpawn )
					end
				end )
			end
		end
	end )
end

function NOOBRP:GetTeamSpawns( job )
	return ( NOOBRP.TeamSpawns[job] )
end

function NOOBRP:IsPurgeOccuring( )
	return ( timer.Exists( "N00BRP_PurgeEventTimer" ) )
end

function NOOBRP:SpawnPurgeVendor( )
	if ( #ents.FindByClass( "npc_purgedealer" ) > 0 ) then return end
	local entTable = scripted_ents.Get( "npc_purgedealer" )
	local spawnPoint = entTable.Position
	local spawnAngles = entTable.Angles
	local purgeVendor = ents.Create( "npc_purgedealer" )
	purgeVendor:SetPos( spawnPoint )
	purgeVendor:SetAngles( spawnAngles )
	purgeVendor:Spawn( )
	purgeVendor:Activate( )
end

function NOOBRP:DespawnPurgeVendor( )
	local purgeVendor = ents.FindByClass( "npc_purgedealer" )[1]
	if not ( IsValid( purgeVendor ) ) then return end
	SafeRemoveEntity( purgeVendor )
end

function NOOBRP:ClearPurgeDurationItems( )
	for index, ply in ipairs ( player.GetAll( ) ) do
		if ( IsValid( ply ) ) then
			ply:RemoveAllPurgeDurationItems( )
		end
	end
	NOOBRP.PurgeDurationItems = { }
end

function NOOBRP.StatusTrackers:CheckIfRespawning( steamID )
	local tracker = NOOBRP.StatusTrackers
	if ( tracker.currentRespawnTimers[steamID] ) then
		if ( CurTime( ) > tracker.currentRespawnTimers[steamID] ) then
			NOOBRP.StatusTrackers:ClearRespawnTimer( steamID )
			return nil
		else
			return tracker.currentRespawnTimers[steamID]
		end
	else
		return nil
	end
end

function NOOBRP.StatusTrackers:GetRespawnLength( steamID )
	return NOOBRP.StatusTrackers.currentRespawnTimers[steamID] - CurTime( )
end

function NOOBRP.StatusTrackers:SetRespawnLength( steamID, len )
	NOOBRP.StatusTrackers.currentRespawnTimers[steamID] = CurTime( ) + len
end

function NOOBRP.StatusTrackers:ClearRespawnTimer( steamID )
	NOOBRP.StatusTrackers.currentRespawnTimers[steamID] = nil
end

function NOOBRP.StatusTrackers:GetRemainingJailTime( steamID )
	local remainingTime = NOOBRP.StatusTrackers.ArrestedPlayers[steamID] - CurTime( )
	if ( NOOBRP.StatusTrackers.ArrestedPlayers[steamID] < CurTime( ) ) then
		remainingTime = 1
		NOOBRP.StatusTrackers.ArrestedPlayers[steamID] = nil
	end
	return remainingTime
end

function NOOBRP.StatusTrackers:AddMurderer( steamID, len )
	NOOBRP.StatusTrackers.CurrentMurderers[steamID] = CurTime( ) + len
end

function NOOBRP.StatusTrackers:GetRemainingMurdererTime( steamID )
	local remainingTime = NOOBRP.StatusTrackers.CurrentMurderers[steamID] - CurTime( )
	if ( NOOBRP.StatusTrackers.CurrentMurderers[steamID] < CurTime( ) ) then
		remainingTime = 1
		NOOBRP.StatusTrackers.CurrentMurderers[steamID] = nil
	end
	return remainingTime
end

function NOOBRP.AddStaticWaypoint( name, pos )
	local currentWaypoints = SHNOOB_VARS:Get( "MinimapStaticWaypoints" )
	currentWaypoints[name] = pos
	SHNOOB_VARS:Set( "MinimapStaticWaypoints", currentWaypoints )
end

function NOOBRP.RemoveStaticWaypoint( name )
	local currentWaypoints = SHNOOB_VARS:Get( "MinimapStaticWaypoints" )
	currentWaypoints[name] = nil
	SHNOOB_VARS:Set( "MinimapStaticWaypoints", currentWaypoints )
end

function NOOBRP.StartEntitySpawningTimer( )
	if ( timer.Exists( "EntitySpawningTimer" ) ) then timer.Destroy( "EntitySpawningTimer" ) end
	if ( file.Exists( "noob_entspawns.txt", "DATA" ) ) then
		if ( game.GetMap( ) ~= "rp_evocity_v2d_updated" ) then return end
		local MaxClassEntities = { }
		MaxClassEntities[ "ent_herb" ] = nil
		MaxClassEntities[ "ent_mushroom" ] = nil
		MaxClassEntities[ "soul_orb" ] = nil
		local entSpawnTable = util.JSONToTable( file.Read( "noob_entspawns.txt", "DATA" ) )
		timer.Create( "EntitySpawningTimer", SVNOOB_VARS:Get( "HerbSpawnInterval", true, "number", 5 ), 0, function( )
			if not ( MaxClassEntities[ "ent_herb" ] ) then MaxClassEntities[ "ent_herb" ] = tonumber( SVNOOB_VARS:Get( "MaxHerbEntities" ) ) or 20 end
			if not ( MaxClassEntities[ "ent_mushroom" ] ) then MaxClassEntities[ "ent_mushroom" ] = tonumber( SVNOOB_VARS:Get( "MaxMushroomEntities" ) ) or 5 end
			if not ( MaxClassEntities[ "soul_orb" ] ) then MaxClassEntities[ "soul_orb" ] = tonumber( SVNOOB_VARS:Get( "MaxSoulOrbEntities" ) ) or 10 end
			local rndSpawn = entSpawnTable[ math.random( #entSpawnTable ) ]
			if not ( rndSpawn ) then return end
			if ( #ents.FindByClass( rndSpawn.class ) < MaxClassEntities[ rndSpawn.class ] ) then
				local canSpawn = true
				if not ( rndSpawn.class == "soul_orb" ) then
					local checkForEnts = ents.FindInBox( ClampWorldVector( rndSpawn.pos - Vector( 64, 64, 64 ) ), ClampWorldVector( rndSpawn.pos + Vector( 64, 64, 64 ) ) )
					if ( #checkForEnts > 0 ) then
						for index, ent in ipairs ( checkForEnts ) do
							if ( ent:GetClass( ) == "ent_herb" or ent:GetClass( ) == "ent_mushroom" ) then
								canSpawn = false
								break
							end
						end
					end
				end
				if not ( canSpawn ) then return end
				local spawnEnt = ents.Create( rndSpawn.class )
				spawnEnt:SetPos( rndSpawn.pos )
				if ( spawnEnt:GetPhysicsObject( ):IsValid( ) ) then
					spawnEnt:GetPhysicsObject( ):EnableMotion( false )
				end
				spawnEnt:Spawn( )
			end
		end )
	end
end

function NOOBRP.StartPropCleanupTimer( )
	if ( timer.Exists( "N00BRP_PropRemovalTimer" ) ) then timer.Destroy( "N00BRP_PropRemovalTimer" ) end
	timer.Create( "N00BRP_PropRemovalTimer", SVNOOB_VARS:Get( "PropCleanupTimer", true, "number", 900 ), 0, function( ) 
		local cleanedProps = 0
		for index, prop in ipairs ( ents.FindByClass( "prop_physics" ) ) do
			if ( IsValid( prop ) and IsValid( prop:CPPIGetOwner( ) ) and prop:CPPIGetOwner( ).isMarkedAFK ) then
				prop:Destroy( )
				cleanedProps = cleanedProps + 1
			end
		end
		local mes = "Cleaned up " .. cleanedProps .. " props that AFK players owned."
		NOOB_LOGGER:Log( NOOB_LOGGING_WARNING, mes, true )
	end )
end

function NOOBRP.StartMessageBroadcastTimer( )
	if ( timer.Exists( "N00BRP_MessageBroadcastTimer" ) ) then timer.Destroy( "N00BRP_MessageBroadcastTimer" ) end
	timer.Create( "N00BRP_MessageBroadcastTimer", SVNOOB_VARS:Get( "MessageBroadcastInterval", true, "number", 300 ), 0, function( )
		local mesTable = SVNOOB_VARS:Get( "MessageBroadcasts", true, "table", { Color( 96, 96, 96 ), "Press F1 to access the Gems, Herbs, Skills, and Alchemy menu." } )
		local randMessage = mesTable[ math.random( #mesTable ) ]
		BroadcastColoredMessage( randMessage )
	end )
end

function NOOBRP.StartElevatorFixTimer( )
	if ( timer.Exists( "N00BRP_ElevatorFixTimer" ) ) then timer.Destroy( "N00BRP_ElevatorFixTimer" ) end
	timer.Create( "N00BRP_ElevatorFixTimer", SVNOOB_VARS:Get( "ElevatorFixInterval", true, "number", 14400 ), 0, function( )
		local btnTable = ents.FindByName( "ash47_btn_01" )
		local elevatorBtn = btnTable[1]
		if not ( elevatorBtn ) then 
			print( "The elevator button could not be found, failed to automatically fix it." )
			return 
		end
		elevatorBtn:Fire( "unlock", 0, 1 )
		elevatorBtn:Fire( "use", 0, 1 )
		print( "[NOTIFY] The elevator has been automatically fixed." )
	end )
end

hook.Add( "N00BRP_ServerVariablesLoaded", "N00BRP_InitializeTimers_ServerVariablesLoaded", function( )
	NOOBRP.StartEntitySpawningTimer( )
	NOOBRP.StartPropCleanupTimer( )
	NOOBRP.StartMessageBroadcastTimer( )
	NOOBRP.StartElevatorFixTimer( )
end )
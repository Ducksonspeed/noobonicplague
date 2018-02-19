util.AddNetworkString( "N00BRP_SetViewOffset" )
util.AddNetworkString( "N00BRP_SetHull" )

local function CanPlayerChangeJob( ply, newTeam, force )
	if ( force ) then return true end
	if ( ( team.IsCivilProtection( newTeam ) and ( ply:IsMurderer( ) or ply:isWanted( ) ) ) ) then
		DarkRP.notify( ply, 1, 4, "You cannot work for the government while being a fugitive!" )
		return false
	end
	local modelScale = ply:GetNiceModelScale( 2 )
	local shrinkSize = 0.1
	local rayTable = weapons.Get( "shrink_ray" )
	if ( rayTable ) then
		shrinkSize = rayTable.ShrinkSize
	end
	//if ( ply:getDarkRPVar( "IsGhost" ) ) then
	if ( ply:IsGhost( ) ) then
		DarkRP.notify( ply, 1, 4, "You can't change jobs while dead." )
		return false
	elseif ( modelScale == shrinkSize and ply:Team( ) ~= TEAM_CRAB ) then
		DarkRP.notify( ply, 1, 4, "You're too small to reconsider your job!" )
		return false
	elseif ( ply.isTasered ) then
		DarkRP.notify( ply, 1, 4, "You're too disorientated to change jobs!" )
		return false
	elseif ( ply:Team( ) == TEAM_CRAB ) then
		DarkRP.notify( ply, 1, 4, "You must be a crab person until your death." )
		return false
	elseif ( ply:Team( ) == TEAM_ZOMBIE ) then
		DarkRP.notify( ply, 1, 4, "Zombies don't know what a job is! You can't change!" )
		return false
	elseif ( team.IsCivilProtection( newTeam ) and ( ply:HasEntitySpawned( "basic_money_printer" ) or ply:HasEntitySpawned( "adv_money_printer" ) or ply:HasEntitySpawned( "money_printer" ) or ply:HasMoneyPrintersInTrunk( ) ) ) then
		DarkRP.notify( ply, 1, 4, "You cannot become part of the Government while owning illegal printers!" )
		return false
	elseif ( newTeam == TEAM_FOREMAN ) then
		local foremanLimit = tonumber( SVNOOB_VARS:Get( "MiningForemanLimit" ) ) or 2
		if ( #team.GetPlayers( TEAM_FOREMAN ) >= foremanLimit ) then
			DarkRP.notify( ply, 1, 4, "The Mining Foreman limit has been reached." )
			return false
		end
	elseif ( newTeam == TEAM_CRAB ) then
		local crabLimit = tonumber( SVNOOB_VARS:Get( "CrabPersonLimit" ) ) or 3
		if ( #team.GetPlayers( TEAM_CRAB ) >= crabLimit ) then
			DarkRP.notify( ply, 1, 4, "The Crab Person limit has been reached." )
			return false
		end
	end
end
hook.Add( "playerCanChangeTeam", "N00BRP_CanPlayerChangeJob_playerCanChangeTeam", CanPlayerChangeJob )

local function PlayerChangedJob( ply, oldTeam, newTeam )
	ply:ResetViewOffset( )
	ply:ScaleHull( nil, true )
	ply:RemovePotionTimers( )
	ply.jobChangeTime = CurTime( )
	ply:ClearTempWeapons( )
	ply:UnequipHat( )
	ply:UnequipBackItem( )
	ply:ClearDisabledPermas( )
	ply:GiveRentedPerms( )
	ply:AttemptWearClothes( )
	if ( team.IsCivilProtection( newTeam ) and !team.IsCivilProtection( oldTeam ) ) then
		ply:KillSilent( )
		timer.Simple( 0.1, function( ) 
			ply:Spawn( )
		end )
	elseif ( team.IsCivilProtection( oldTeam ) and !team.IsCivilProtection( newTeam ) ) then
		ply:KillSilent( )
		ply:Spawn( )
	elseif ( newTeam == TEAM_HOBO ) then
		timer.Simple( SVNOOB_VARS:Get( "ZombieTime", true, "number", 600 ), function( ) 
			if ( IsValid( ply ) and ply:Team( ) == TEAM_HOBO ) then
				ply:changeTeam( TEAM_ZOMBIE, true )
			end
		end )
	elseif ( newTeam == TEAM_CRAB ) then
		ply:KillSilent( )
		ply:Spawn( )
	elseif ( newTeam == TEAM_ZOMBIE ) then
		//if ( ply:Alive( ) and !ply:getDarkRPVar( "IsGhost" ) ) then
		if ( ply:Alive( ) and !ply:IsGhost( ) ) then
			timer.Simple( 0.1, function( )
				local startingHealth = SVNOOB_VARS:Get( "ZombieStartingHealth", true, "number", 500 )
				local maxHealth = SVNOOB_VARS:Get( "ZombieMaximumHealth", true, "number", 3000 )
				ply:SetBodygroup( 1, math.random( 0, 1 ) )
				ply:SayMessage( CHAT_PLAYER_YELL, "BRAAAAAIIINNNSSSS!" )
				ply:SetHealth( startingHealth )
				ply:SetMaxHealth( maxHealth )
				ply:StripWeapons( )
				ply:Give( "weapon_crowbar" )
			end )
		end
	end
end
hook.Add( "OnPlayerChangedTeam", "N00BRP_PlayerChangedJob_OnPlayerChangedTeam", PlayerChangedJob )

local function PlayerJobSpawnCheck( ply )
	timer.Simple( 0.1, function( ) -- Some functions in here need to run after DarkRP's.
		if not ( IsValid( ply ) ) then return end
		if ( ply:Team( ) == TEAM_CRAB ) then
			ply:SetModelScale( 0.1, 0 )
			ply:IncrementCrabSize( )
		elseif ( ply:Team( ) == TEAM_ZOMBIE ) then
			local startingHealth = SVNOOB_VARS:Get( "ZombieStartingHealth", true, "number", 500 )
			local maxHealth = SVNOOB_VARS:Get( "ZombieMaximumHealth", true, "number", 3000 )
			ply:SetHealth( startingHealth )
			ply:SetMaxHealth( maxHealth )
			ply:StripWeapons( )
			ply:Give( "weapon_crowbar" )
			ply:SayMessage( CHAT_PLAYER_SAY, "Mmmmmm... ME WANT BRAINS!" )
			ply:SetBodygroup( 1, math.random( 0, 1 ) )
		end
	end )
end
hook.Add( "PlayerSpawn", "N00BRP_PlayerJobSpawnCheck_PlayerSpawn", PlayerJobSpawnCheck )

local function OnCustomJobLimitChange( var, oldValue, newValue )
	local curTable = SHNOOB_VARS:Get( "CustomJobLimits" )
	if ( var == "MiningForemanLimit" ) then
		curTable[ "Mining Foreman" ] = newValue
		SHNOOB_VARS:Set( "CustomJobLimits", curTable )
	elseif ( var == "CrabPersonLimit" ) then
		curTable[ "Crab Person" ] = newValue
		SHNOOB_VARS:Set( "CustomJobLimits", curTable )
	end
end
hook.Add( "N00BRP_ServerVariableChanged", "N00BRP_OnCustomJobLimitChange_N00BRP_ServerVariableChanged", OnCustomJobLimitChange )
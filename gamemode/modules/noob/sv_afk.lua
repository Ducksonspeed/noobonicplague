local afkConVar = CreateConVar( "N00BRP_EnableAntiAFK", "1", FCVAR_ARCHIVE, "Demotes players and disables paycheck for afk players." )
local spectateAFKConVar = CreateConVar( "N00BRP_EnableSpectateAFK", "1", FCVAR_ARCHIVE, "Makes players spectate while AFK." )

local keyDownFlagLength = 420
local afkCheckInterval = 450
local lastKeyPressFlagLength = 420

// The key whitelist for marking the player's last key press.
// Didn't put forward, right, left, or jump because those are the only most likely to be pressed by afk scripts.
local keyPressTriggers = {
	[IN_ATTACK] = true,
	[IN_ATTACK2] = true,
	[IN_DUCK] = true,
	[IN_MOVELEFT] = true,
	[IN_MOVERIGHT] = true,
	[IN_RELOAD] = true,
	[IN_SPEED] = true,
	[IN_USE] = true,
	[IN_BACK] = true
}

// Keys that will be watched for how long they're down.
local keyDownWatchList = {
	[IN_FORWARD] = true,
	[IN_RIGHT] = true,
	[IN_LEFT] = true,
	[IN_DUCK] = true
}

local function SetLastKeyPress( ply, key )
	if ( ply.isMarkedAFK and ply:GetObserverMode( ) ~= OBS_MODE_NONE ) then -- So the player can't move while spectating.
		ply:UnSpectate( )
		ply:Spawn( )
	end
	if ( keyPressTriggers[key] ) then
		if ( ply.isMarkedAFK ) then
			DarkRP.notify( ply, 0, 4, "You're no longer marked AFK." )
			ply:setDarkRPVar( "IsAFK", false )
			if ( spectateAFKConVar:GetBool( ) and ply:GetObserverMode( ) ~= OBS_MODE_NONE ) then
				ply:UnSpectate( )
				ply:Spawn( )
			end
		end
		ply.afkCheckTimerRan = 0
		ply.isMarkedAFK = false
		ply.afkCheckLastKeyPressed = CurTime( )
	elseif ( keyDownWatchList[key] ) then
		ply.afkCheckKeyWatchList = ply.afkCheckKeyWatchList or { }
		ply.afkCheckKeyWatchList[key] = CurTime( )
	end
end
hook.Add( "KeyPress", "N00BRP_SetLastKeyPress_KeyPress", SetLastKeyPress )

local function CheckKeyWatchList( ply, key )
	ply.afkCheckKeyWatchList = ply.afkCheckKeyWatchList or { }
	if ( ply.afkCheckKeyWatchList[key] ) then
		ply.afkCheckKeyWatchList[key] = nil
	end
end
hook.Add( "KeyRelease", "N00BRP_CheckKeyWatchList_KeyRelease", CheckKeyWatchList )

local function ShouldFlagKeyDownLength( inKey, ply )
	if ( ply:KeyDown( inKey ) and ply.afkCheckKeyWatchList[ inKey ] ) then
		local keyLengthFlag = keyDownFlagLength
		if ( keyLengthFlag < CurTime( ) - ply.afkCheckKeyWatchList[ inKey ] ) then
			return true
		end
	end
end

local function BeginAFKCheckingTimer( ply )
	if not ( afkConVar:GetBool( ) ) then return end
	dAfkCheckInterval = math.random( 900, 1800 )
	local entIndex = ply:EntIndex( )
	timer.Create( entIndex .. ":AFKCheckingTimer", dAfkCheckInterval, 0, function( )
		if not ( IsValid( ply ) ) then timer.Destroy( entIndex .. ":AFKCheckingTimer" ) return end
		ply.afkCheckTimerRan = ply.afkCheckTimerRan or 0
		ply.afkCheckTimerRan = ply.afkCheckTimerRan + 1
		local afkCheckChance = math.random( 1, 2 )
		if ( afkCheckChance == 1 and ply.afkCheckTimerRan > 1 ) then
			local pointAmount = 0
			if ( ply.afkCheckLastEyePos and ply.afkCheckLastEyePos:IsEqualTol( ply:EyePos( ), 16 ) ) then
				pointAmount = pointAmount + 1
			end
			local eyeAng = ply:EyeAngles( )
			eyeAng = Angle( math.Round( eyeAng[1] ), math.Round( eyeAng[2] ), math.Round( eyeAng[3] ) )
			if ( ply.afkCheckLastEyeAngles and ply.afkCheckLastEyeAngles == eyeAng ) then
				pointAmount = pointAmount + 1
			end
			if ( ply.afkCheckLastPos and ply.afkCheckLastPos:IsEqualTol( ply:GetPos( ), 16 ) ) then
				pointAmount = pointAmount + 1
			end
			local isAFKMoving = false
			if ( ShouldFlagKeyDownLength( IN_FORWARD, ply ) ) then pointAmount = pointAmount + 3 isAFKMoving = true end
			if ( ShouldFlagKeyDownLength( IN_RIGHT, ply ) ) then pointAmount = pointAmount + 3 isAFKMoving = true end
			if ( ShouldFlagKeyDownLength( IN_LEFT, ply ) ) then pointAmount = pointAmount + 3 isAFKMoving = true end
			if ( ShouldFlagKeyDownLength( IN_DUCK, ply ) ) then pointAmount = pointAmount + 3 isAFKMoving = true end
			local lastKeyPressFlag = lastKeyPressFlagLength
			if ( ply.afkCheckLastKeyPressed and lastKeyPressFlag < ( CurTime( ) - ply.afkCheckLastKeyPressed ) ) then
				pointAmount = pointAmount + 2
			end
			local pointTriggerAmount = SVNOOB_VARS:Get( "AFKPointTriggerAmount", true, "number", 4 )
			if ( pointAmount >= 5 and !ply.isMarkedAFK ) then
				ply.isMarkedAFK = CurTime( )
				ply:setDarkRPVar( "IsAFK", true )
				if ( spectateAFKConVar:GetBool( ) ) then
					ply:Spectate( OBS_MODE_ROAMING )
					ply:StripWeapons( )
				end
				NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, ply:NiceInfo( ) .. " has been marked AFK with [" .. pointAmount .. "] points." , true )
				PrintMessage( HUD_PRINTCONSOLE, ply:Nick( ) .. " has been marked AFK." )
				if ( ply:Team( ) ~= TEAM_CITIZEN ) then
					ply:ChatPrint( "You've been autodemoted for being afk." )
					ply:changeTeam( TEAM_CITIZEN, true )
				end
				if ( isAFKMoving ) then
					ply:ConCommand( "-left" )
					ply:ConCommand( "-right" )
					ply:ConCommand( "-forward" )
					ply:ConCommand( "-back" )
				end
			end
		end
		local eyeAng = ply:EyeAngles( )
		ply.afkCheckLastEyePos = ply:EyePos( )
		ply.afkCheckLastEyeAngles = Angle( math.Round( eyeAng[1] ), math.Round( eyeAng[2] ), math.Round( eyeAng[3] ) )
		ply.afkCheckLastPos = ply:GetPos( )
	end )
end
hook.Add( "PlayerInitialSpawn", "N00BRP_BeginAFKCheckingTimer_PlayerInitialSpawn", BeginAFKCheckingTimer )

local function RemoveTimerOnDisconnect( ply )
	if ( timer.Exists( ply:EntIndex( ) .. ":AFKCheckingTimer" ) ) then
		timer.Destroy( ply:EntIndex( ) .. ":AFKCheckingTimer" )
	end
end
hook.Add( "PlayerDisconnected", "N00BRP_RemoveTimerOnDisconnect_PlayerDisconnected", RemoveTimerOnDisconnect )
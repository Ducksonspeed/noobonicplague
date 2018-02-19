SHNOOB_VARS = { }
SHNOOB_VARS.VarTable = { }
--IMPORTANT ENUMS
local SHNOOB_REQUESTVARS = 1
local SHNOOB_RECEIVEVAR = 2
local SHNOOB_RECEIVEVARS = 3

function SHNOOB_VARS:Get( index, raw )
	if ( raw ) then
		return SHNOOB_VARS.VarTable[index] or nil
	else
		return SHNOOB_VARS.VarTable[index] or "nil"
	end
end

if ( CLIENT ) then
	function SHNOOB_VARS:RequestAll( )
		net.Start( "N00BRP_SharedGlobal_Vars" )
			net.WriteInt( SHNOOB_REQUESTVARS, 8 )
		net.SendToServer( )
	end
	local function Receive_SharedGlobal_Vars( len )
		local enum = net.ReadInt( 8 )
		if ( enum == SHNOOB_RECEIVEVAR ) then
			local singleVarTable = net.ReadTable( )
			local oldVal = SHNOOB_VARS.VarTable[ singleVarTable.varIndex ]
			SHNOOB_VARS.VarTable[ singleVarTable.varIndex ] = singleVarTable.varVal
			hook.Call( "OnSharedVariableChange", { }, singleVarTable.varIndex, oldVal, singleVarTable.varVal )
		elseif ( enum == SHNOOB_RECEIVEVARS ) then
			local varTable = net.ReadTable( )
			for index, var in pairs ( varTable ) do
				SHNOOB_VARS.VarTable[ index ] = var
			end
		end
	end
	net.Receive( "N00BRP_SharedGlobal_Vars", Receive_SharedGlobal_Vars )

	local function RequestSharedGlobalVars( )
		SHNOOB_VARS:RequestAll( )
	end
	hook.Add( "InitPostEntity", "N00BRP_RequestSharedGlobalVars_InitPostEntity", RequestSharedGlobalVars )

	local function OnClientVariablesReloaded( )
		SHNOOB_VARS:RequestAll( )
	end
	hook.Add( "OnReloaded", "N00BRP_OnClientVariablesReloaded_OnReloaded", OnClientVariablesReloaded )
end

if ( SERVER ) then
	util.AddNetworkString( "N00BRP_SharedGlobal_Vars" )
	function SHNOOB_VARS:Set( index, val )
		local oldVal = SHNOOB_VARS.VarTable[index]
		SHNOOB_VARS.VarTable[index] = val
		net.Start( "N00BRP_SharedGlobal_Vars" )
			net.WriteInt( SHNOOB_RECEIVEVAR, 8 )
			net.WriteTable( { varIndex = index, varVal = val } )
		net.Send( player.GetAll( ) )
		hook.Call( "OnSharedVariableChange", { }, index, oldVal, val )
	end
	local function Requested_SharedGlobal_Vars( len, ply )
		if ( ply.alreadyRequestedVars ) then return end
		local enum = net.ReadInt( 8 )
		if ( enum == SHNOOB_REQUESTVARS ) then
			hook.Call( "NOOBRP_OnRequestData", { }, ply )
			local varTable = { }
			local varCount = 0
			for index, var in pairs ( SHNOOB_VARS.VarTable ) do
				if ( varCount >= 2 ) then
					net.Start( "N00BRP_SharedGlobal_Vars" )
						net.WriteInt( SHNOOB_RECEIVEVARS, 8 )
						net.WriteTable( varTable )
					net.Send( ply )
					varTable = { }
					varCount = 0
				end
				varTable[index] = var
				varCount = varCount + 1
			end
			if ( varTable and varTable ~= { } ) then
				net.Start( "N00BRP_SharedGlobal_Vars" )
					net.WriteInt( SHNOOB_RECEIVEVARS, 8 )
					net.WriteTable( varTable )
				net.Send( ply )
			end
			varTable = { }
			varCount = 0
			ply.alreadyRequestedVars = true
		end
	end
	net.Receive( "N00BRP_SharedGlobal_Vars", Requested_SharedGlobal_Vars )

	local function OnVariablesReloaded( )
		timer.Simple( 1, function( )
			for index, val in pairs ( SHNOOB_VARS.VarTable ) do
				SHNOOB_VARS:Set( index, val )
			end
			SHNOOB_VARS:Set( "RadioStations", NOOBRP.Config.RadioStations )
			SHNOOB_VARS:Set( "MinimapWaypoints", NOOBRP.Config.Waypoints )
		end )
	end
	hook.Add( "OnReloaded", "N00BRP_OnVariablesReloaded_OnReloaded", OnVariablesReloaded )

	SHNOOB_VARS:Set( "BeastEventActive", false )
	SHNOOB_VARS:Set( "CustomJobLimits", {{ [ "Mining Foreman" ] = 2, [ "Crab Person" ] = 3 }} )
	SHNOOB_VARS:Set( "SpeedLimit", 25 )
	SHNOOB_VARS:Set( "MayorLaws", { } )
	SHNOOB_VARS:Set( "ItemSales", { "No sales are occuring." } )
	SHNOOB_VARS:Set( "EventName", "No Event Occuring" )
	SHNOOB_VARS:Set( "MOTD", "Welcome to Noobonic Plague :: Reborn!" )
	SHNOOB_VARS:Set( "NightmareEvent", false )
	SHNOOB_VARS:Set( "RadioStations", {	} )
	SHNOOB_VARS:Set( "MinimapWaypoints", { } )
	SHNOOB_VARS:Set( "MinimapStaticWaypoints", { } )
	SHNOOB_VARS:Set( "PurgeEventActive", false )
	SHNOOB_VARS:Set( "IsLockdown", false )
	SHNOOB_VARS:Set( "HerbWorth",
	{
		[1] = 50, -- Burdock Root
		[2] = 100, -- Gingko Biloba
		[3] = 10000, -- Valerian Root
		[4] = 35, -- Coral Fungus
		[5] = 85, -- Red Reishi
		[6] = 50000 -- Psilocybe Cubensis
	} )

	SHNOOB_VARS:Set( "GemWorth",
	{
		[1] = 1, -- Rocks
		[2] = 2, -- Granite
		[3] = 4, -- Shale
		[4] = 25, -- Emeralds
		[5] = 50, -- Rubies
		[6] = 1500, -- Sapphires
		[7] = 30000, -- Obsidians
		[8] = 75000 -- Diamonds
	} )

end

DarkRP.declareChatCommand{
        command = "skillmenu",
        description = "Toggle the skill menu!",
        delay = 1.5
}
if ( SERVER ) then
	local onGoingNightmare = false
	local spawnPoints = { Vector( -6433.002, -4516.589, 72.031 ), Vector( -6763.947, -6051.79, 64.031 ), Vector( -6481.489, -6960.595, 64.031 ),
	Vector( -6314.875, -7723.365, 72.031 ), Vector( -6910, -8408.187, 64.031 ), Vector( -7609.303, -9156.978, 840.031 ),
	Vector( -4308.617, -8182.901, 190.031 ), Vector( -4335.012, -6216.903, 190.031 ), Vector( -4670.439, -4751.209, 208.031 ),
	Vector( -5805.728, -987.183, 64.031 ), Vector( -3982.987, -610.096, 64.031 ), Vector( -2918.131, -635.364, 64.031 ),
	Vector( -1031.197, -640.82, 64.031 ), Vector( 52.334, 3094.204, 64.031 ), Vector( 2983.281, 6529.016, 68.031 ),
	Vector( 3979.504, 6529.562, 68.031 ), Vector( 3958.273, 3944.469, 64.031 ), Vector( 115.713, 3179.592, 64.031 ),
	Vector( -862.97, -5273.213, 64.031 ), Vector( 748.758, -5741.987, 64.031 ), Vector( 4746.678, -5171.844, 64.031 ),
	Vector( 4808.083, -7094.406, 64.031 ), Vector( 7821.029, -2154.339, 64.031 ), Vector( 8297.781, 1554.791, 55.248 ),
	Vector( 11018.042, 592.64, 49.613 ), Vector( 11412.087, 87.077, 63 ) }
	local spawnableNPCs = { "npc_fastzombie", "npc_zombie", "npc_antlion", "npc_poisonzombie" }
	local npcLimit = 15

	local function GetSpawnedNPCs( remove )
		local spawnedNPCs = 0
		for index, npc in ipairs ( spawnableNPCs ) do
			local npcTable = ents.FindByClass( npc )
			local amt = 0
			if not ( istable( npcTable ) ) then continue end
			amt = #npcTable
			spawnedNPCs = spawnedNPCs + amt
			if ( remove ) then
				for index, npc in ipairs ( npcTable ) do
					if ( npc.isNightmareNPC ) then
						SafeRemoveEntity( npc )
					end
				end
			end
		end
		return spawnedNPCs
	end
	
	local function BeginNightmareEvent( ply, cmd, args, fstring )
		if not ( ply:IsSuperAdmin( ) ) then return end
		if ( onGoingNightmare ) then return end
		local length = tonumber( args[1] ) or 600
		PrintMessage( HUD_PRINTTALK, "(EVENT) You suddenly remember your deepest fears..." )
		SHNOOB_VARS:Set( "NightmareEvent", true )
		onGoingNightmare = true
		timer.Create( "N00BRP_NightmareEvent_SpawnTimer", 60, 0, function( )
			if ( GetSpawnedNPCs( ) >= npcLimit ) then return end
			local randomClass = spawnableNPCs[ math.random( #spawnableNPCs ) ]
			local randomPos = spawnPoints[ math.random( #spawnPoints ) ]
			local npc = ents.Create( randomClass )
			npc:SetPos( randomPos )
			npc:Spawn( )
			npc:Activate( )
			npc:SetMaterial( "models/shadertest/shader3" )
			npc:SetHealth( npc:Health( ) * 20 )
			npc:CreateTargetCheckingTimer( )
			npc.isNightmareNPC = true
			timer.Simple( 180, function( )
				if ( IsValid( npc ) ) then
					SafeRemoveEntity( npc )
				end
			end )
		end )
		timer.Simple( length, function( )
			if not ( onGoingNightmare ) then return end
			SHNOOB_VARS:Set( "NightmareEvent", false )
			onGoingNightmare = false
			PrintMessage( HUD_PRINTTALK, "(EVENT) You feel much better now..." )
			timer.Destroy( "N00BRP_NightmareEvent_SpawnTimer" )
		end )
	end
	concommand.Add( "np_nightmare", BeginNightmareEvent )

	local function ForceEndNightmareEvent( ply, cmd, args, fstring )
		if not ( ply:IsSuperAdmin( ) ) then return end
		if not ( onGoingNightmare ) then return end
		timer.Destroy( "N00BRP_NightmareEvent_SpawnTimer" )
		PrintMessage( HUD_PRINTTALK, "(EVENT) You feel much better now..." )
		onGoingNightmare = false
		SHNOOB_VARS:Set( "NightmareEvent", false )
		GetSpawnedNPCs( true )
	end
	concommand.Add( "np_endnightmare", ForceEndNightmareEvent )

else

	local function RenderNightmareScreenspace( )
		local tab =
		{
			["$pp_colour_addr"] = 1,
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = 0,
			["$pp_colour_contrast"] = 0.11,
			["$pp_colour_colour"] = 0,
			["$pp_colour_mulr"] = math.abs( math.sin( CurTime( ) * 0.5 ) * 0.2 ),
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		}
		if ( !LocalPlayer( ):IsGhost( ) and SHNOOB_VARS:Get( "NightmareEvent" ) == true ) then
			DrawColorModify( tab )
		end
	end
	hook.Add( "RenderScreenspaceEffects", "N00BRP_RenderNightmareScreenspace_RenderScreenspaceEffects", RenderNightmareScreenspace )
end
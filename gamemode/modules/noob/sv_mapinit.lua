local spots = 
{
	[ "bank_button" ] =
	{
		{ pos = Vector( -6804, -7537, 73 ), ang = Angle( ) }
	},
	[ "npc_bp" ] =
	{
		{ pos = Vector( -7306, -6026, 136 ), ang = Angle( ) }
	},
	[ "npc_medic" ] =
	{
		{ pos = Vector( 10757, -12420, -989 ), ang = Angle( 0, -180, 0 ) }	
	},
	[ "npc_gemdealer" ] =
	{
		{ pos = Vector( -3020, -6003, 262 ), ang = Angle( 0, -90, 0 ) }
	},
	[ "npc_slums" ] = 
	{
		{ pos = Vector( -928, -6433, 73 ), ang = Angle( 0, 90, 0 ) }
	},
	[ "npc_jailguard" ] =
	{
		{ pos = Vector( -6549, -9363, 967 ), ang = Angle( 0, -180, 0 ) }
	},
	[ "npc_warden" ] =
	{
		{ pos = Vector( -7253, -8571, 235 ), ang = Angle( 0, 90, 0 ) }
	},
	[ "npc_bartender" ] =
	{
		{ pos = Vector( 11880, 14, 236 ), ang = Angle( 0, 180, 0 ) }
	},
	[ "npc_forestsalesman" ] =
	{
		{ pos = Vector( 1737, 13795, 224 ), ang = Angle( 0, 139, 0 ) }
	},
	[ "npc_blackmarket" ] =
	{
		{ pos = Vector( 12117, 1966, 355 ), ang = Angle( 0, -156, 0 ) }
	},
	[ "npc_exoticmarket" ] =
	{
		{ pos = Vector( -7460, -9774, 236 ), ang = Angle( 0, 175, 0 ) }
	},
	[ "npc_nexusdealer" ] =
	{
		{ pos = Vector( -7855, -8805, 1736 ), ang = Angle( 0, -90, 0 ) }
	},
	[ "npc_cardealer" ] =
	{
		{ pos = Vector( 4309, -4413, 72 ), ang = Angle( 0, -90, 0 ) }
	},
	[ "npc_cook" ] =
	{
		{ pos = Vector( -6550.508, -4647.965, 235 ), ang = Angle( 0, 0, 0 ) }
	},
	[ "npc_permrental" ] =
	{
		{ pos = Vector( -6333.975586, -7954.186523, 120.031 ), ang = Angle( 0, 0, 0 ) }
	},
	[ "npc_clothingdealer" ] =
	{
		{ pos = Vector( -5711.203, -7533.494, 120.031 ), ang = Angle( 0, 180, 0 ) }
	},
	/*[ "bus_stop"] =
	{
		{ pos = Vector( -118, 3625, 66 ), ang = Angle( 0, 90, 0 ) },
		{ pos = Vector( -6177, -6914, 66 ), ang = Angle( 0, 90, 0 ) },
		{ pos = Vector( -9742, 8851, 66 ), ang = Angle( 0, 180, 0 ) },
		{ pos = Vector( 5530, -5896, 66 ), ang = Angle( 0, 180, 0 ) },
		{ pos = Vector( 7345, 13179, 66 ), ang = Angle( 0, 0, 0 ) }
	},*/
	[ "doorportal_industrialtosubs" ] =
	{
		{ pos = Vector( 4903, 8899, 134 ), ang = Angle( 0, 90, 0 ) }
	},
	[ "doorportal_substoindustrial" ] =
	{
		{ pos = Vector( 5373, 11480, 166 ), ang = Angle( 0, -90, 0 ) }
	},
	[ "doorportal_fleamarkettomotel" ] =
	{
		{ pos = Vector( -2407, -5805, 262 ), ang = Angle( 0, 0, 0 ) }
	},
	[ "doorportal_moteltofleamarket" ] =
	{
		{ pos = Vector( -1700, -5807, 153 ), ang = Angle( 0, 180, 0 ) }
	},
	[ "doorportal_industtowater" ] =
	{
		{ pos = Vector( -322.125, 7995.813, 133.656 ), ang = Angle( 0, 0, 0 ) }
	},
	[ "doorportal_watertoindust" ] =
	{
		{ pos = Vector( -4057.969, 10144.75, 183.125 ), ang = Angle( 0, 0, 0 ) }
	},
	["ent_motd"] =
	{
		{ pos = Vector( -5678, -7135, 290 ), ang = Angle( 90, 180, 180 ) }
	},
	["ent_lawsboard"] =
	{
		{ pos = Vector( -5678, -7350, 271 ), ang = Angle( 0, -90, -90 ) }
	},
	["event_meter"] =
	{
		{ pos = Vector( -7762, -9284, 1774 ), ang = Angle( 0, -90, -90 ) }
	},
	["cardealer_event_meter"] =
	{
		{ pos = Vector( 4460.719, -3618.25, 134.625 ), ang = Angle( 0, 180, -90 ) }
	},
	["valet_button"] = 
	{
		{ pos = Vector( -4958, -10724, 161 ), ang = Angle( 90, 180, 90 ) },
		{ pos = Vector( 3671, 6223, 148 ), ang = Angle( 90, 180, 90 ) }
	},
	["rx_slotmachine"] = 
	{
		{ pos = Vector( -6571, -4482, 99 ), ang = Angle( 0, 0, 0 ) },
		{ pos = Vector( -6571, -4810, 98 ), ang = Angle( 0, 0, 0 ) },
		{ pos = Vector( -6395, -7514, 98 ), ang = Angle( 0, 0, 0 ) },
		{ pos = Vector( -6395, -7888, 97 ), ang = Angle( 0, 0, 0 ) }
	}
};

local vehicles =
{
	["Evo City Bus"] = {
		{ pos = Vector( -4003, -10096, 72 ), ang = Angle( 0, 90, 0 ), doorGroup = "Public Transportation" }
	}, 
	["ECPD Taurus"] = {
		{ pos = Vector( -6666.9375, -8850.25, -134.8125 ), ang = Angle( 0, 180, 0 ), doorGroup = "Government Owned" },
		{ pos = Vector( -6842.375, -8858.6875, -134.78125 ), ang = Angle( 0, 180, 0 ), doorGroup = "Government Owned" },
		{ pos = Vector( -7018.375, -8858.6875, -134.78125 ), ang = Angle( 0, 180, 0 ), doorGroup = "Government Owned" },
		{ pos = Vector( -7194.375, -8858.6875, -134.78125 ), ang = Angle( 0, 180, 0 ), doorGroup = "Government Owned" }
	},
	["Evo City Ambulance"] = {
		{ pos = Vector( -7627, -8060, -128 ), ang = Angle( 0, 90, 0 ), doorGroup = "Medical Personnel" },
		{ pos = Vector( -7613, -8242, -128 ), ang = Angle( 0, 90, 0 ), doorGroup = "Medical Personnel" }
	},
}

/*
local function BlowUpFuckingNeogreen( prop )
	if not ( IsValid( prop ) ) then return end
	prop:AddCallback( "PhysicsCollide", function( ent, data )
		local otherEnt = data.HitEntity
		if ( IsValid( otherEnt ) and otherEnt:IsPlayer( ) and !otherEnt:IsGhost( ) and otherEnt:IsNeogreen( ) ) then
			if ( otherEnt:GetPos( ).z > ( prop:GetPos( ).z + 16 ) ) then
				otherEnt:Say( "/y I'm fucking worthless!" )
				util.CreateExplosion( otherEnt:GetPos( ), 0 )
				otherEnt:Kill( )
			end
		end
	end )
end
*/

local props =
{
	["models/props/cs_assault/pylon.mdl"] = 
	{
		{ pos = Vector( -6250, -7300, 64 ), ang = Angle( 0, 0, 0 ), frozen = true, godded = true, ignoreEarthquakes = true },
		{ pos = Vector( -6150, -7300, 64 ), ang = Angle( 0, 0, 0 ), frozen = true, godded = true, ignoreEarthquakes = true },
		{ pos = Vector( -6150, -7400, 64 ), ang = Angle( 0, 0, 0 ), frozen = true, godded = true, ignoreEarthquakes = true },
		{ pos = Vector( -6150, -7500, 64 ), ang = Angle( 0, 0, 0 ), frozen = true, godded = true, ignoreEarthquakes = true },
		{ pos = Vector( -6150, -7600, 64 ), ang = Angle( 0, 0, 0 ), frozen = true, godded = true, ignoreEarthquakes = true },
		{ pos = Vector( -6150, -7700, 64 ), ang = Angle( 0, 0, 0 ), frozen = true, godded = true, ignoreEarthquakes = true },
		{ pos = Vector( -6150, -7800, 64 ), ang = Angle( 0, 0, 0 ), frozen = true, godded = true, ignoreEarthquakes = true },
		{ pos = Vector( -6150, -7900, 64 ), ang = Angle( 0, 0, 0 ), frozen = true, godded = true, ignoreEarthquakes = true },
		{ pos = Vector( -6150, -8000, 64 ), ang = Angle( 0, 0, 0 ), frozen = true, godded = true, ignoreEarthquakes = true },
		{ pos = Vector( -6250, -8000, 64 ), ang = Angle( 0, 0, 0 ), frozen = true, godded = true, ignoreEarthquakes = true }
	}
}

local respawningVehicles = {
	"Evo City Bus",
	"ECPD Taurus",
	"Evo City Ambulance"
}

local entitiesToRemove = { 1294, 1296, 1295, 1284, 1300, 1299, 2211, 2219,
2218, 2217, 2216, 2208, 2222, 2223, 2220, 2221, 2209, 2225, 2224, 2227, 2226,
2210, 2214, 2215, 2212, 2213, 2369, 2371, 2333, 2338, 2337, 2339, 2340, 2607,
2602, 2600, 2601, 2603, 2604, 2353, 2354, 2351, 2352, 2343, 2344, 2349, 2350,
2348, 2345, 2346, 2579, 1794, 1793, 1795, 1905, 1906, 1904, 1907, 1908, 1395,
1394, 1393, 1392, 1391, 1390, 2268, 2267, 2266, 2265, 2264, 2263, 2262, 2274,
2279, 2276, 1344, 2006, 2005, 2004, 2007, 2001, 2002, 2003, 2198, 2023, 2022,
1435, 1436, 1437, 1794, 1793, 1780, 1779, 1778, 1777, 1736, 1731, 1732, 1733,
1738, 1737, 1734, 1739, 1735, 1775, 1776, 1747, 1746, 1745, 1744, 1748, 1749,
1750, 1751, 1766, 1765, 1764, 1763, 1767, 1768, 1769, 1770, 1762, 1753, 1752,
1761, 1760, 1759, 1773, 1774, 1771, 1772, 1762, 1753, 1752, 1761, 2084, 2085 }

if ( game.GetMap( ) == "rp_evocity_v2d_updated" ) then
	hook.Add( "InitPostEntity", "SpawnEntitiesInMap", function( )
		NOOBRP = NOOBRP or { }
		SHNOOB_VARS:Set( "MayorLaws", SVNOOB_VARS:Get( "DefaultMayorLaws", true ) )
		for	a, b in pairs( spots ) do
			for k, v in pairs( b ) do
				local e = ents.Create( a );
				if not ( IsValid( e ) ) then continue end
				e:SetPos( v.pos );
				e:SetAngles( v.ang );
				e:Spawn( );
				e:Activate( );
			end
		end
		for index, posData in pairs ( vehicles ) do
			for _, dat in ipairs ( posData ) do
				local veh = noob_VehicleIndex:SpawnVehicle( index, dat.pos, dat.ang )
				if ( IsValid( veh ) and dat.doorGroup ) then
					veh:setDoorGroup( dat.doorGroup )
				end
			end
		end
		for _, ent in ipairs ( ents.GetAll( ) ) do
			for index, id in ipairs ( entitiesToRemove ) do
				if ( ent:MapCreationID( ) == id ) then
					SafeRemoveEntity( ent )
					table.remove( entitiesToRemove, index )
				end
			end
			if ent:GetClass() == "prop_physics_multiplayer" and (ent:GetModel() == "models/props_c17/furniturefridge001a.mdl" or ent:GetModel() == "models/props_c17/door01_left.mdl") then
				local phys = ent:GetPhysicsObject()
				if IsValid(phys) then 
					phys:EnableMotion(false)
					ent.ignoreEarthquakes = true
				else
					SafeRemoveEntity(ent)
				end
			end
		end
		for mdl, tbl in pairs ( props ) do
			for index, dat in pairs ( tbl ) do
				local prop = ents.Create( "prop_physics" )
				prop:SetModel( mdl )
				prop:SetPos( dat.pos )
				prop:SetAngles( dat.ang )
				prop:Spawn( )
				prop:Activate( )
				local physObj = prop:GetPhysicsObject( )
				if ( physObj:IsValid( ) ) then
					physObj:Wake( )
					if ( dat.frozen ) then
						physObj:EnableMotion( false )
					end
				end
				if ( dat.godded ) then
					timer.Simple( 1, function( ) prop:SetGodmode( true ) end ) -- Ensure it gets godded.
				end
				if ( dat.ignoreEarthquakes ) then
					prop.ignoreEarthquakes = true
				end
				if ( isfunction( dat.runFunc ) ) then
					dat.runFunc( prop )
				end
				--if dat.permanent then prop.Permanent = true end
			end
		end
	end );

	timer.Create( "N00BRP_VehicleRespawnTimer", 5, 0, function( )
		for index, veh in ipairs ( respawningVehicles ) do
			local vehicleAmount = 0
			for index, ent in ipairs ( ents.GetAll( ) ) do
				if not ( ent:IsVehicle( ) ) then continue end
				if ( ent.vehicleName == veh ) then
					vehicleAmount = vehicleAmount + 1
				end
			end
			local vehicleMax = #vehicles[veh]
			local spawnedVehicleAmount = 0
			if ( vehicleAmount >= vehicleMax ) then continue end
			for name, spot in pairs ( vehicles[veh] ) do
				if ( spawnedVehicleAmount >= vehicleMax ) then break end
				local boxMins, boxMaxs = ClampWorldVector( spot.pos - Vector( 128, 128, 128 ) ), ClampWorldVector( spot.pos + Vector( 128, 128, 128 ) )
				local nearbyEnts = ents.FindInBox( boxMins, boxMaxs )
				if ( istable( nearbyEnts ) and #nearbyEnts > 0 ) then continue end
				spawnedVehicleAmount = spawnedVehicleAmount + 1
				local vehData = util.FindVehicleData( veh )
				if not ( vehData ) then continue end
				local spawnedVehicle = ents.Create( vehData.Class )
				spawnedVehicle:SetModel( vehData.Model )
				if ( vehData.KeyValues ) then
					for key, val in pairs ( vehData.KeyValues ) do
						spawnedVehicle:SetKeyValue( key, val )
					end
				end
				spawnedVehicle:SetPos( spot.pos )
				spawnedVehicle:SetAngles( spot.ang )
				spawnedVehicle:Spawn( )
				spawnedVehicle:Activate( )
				spawnedVehicle.vehicleName = veh
				spawnedVehicle.VehicleTable = list.Get("Vehicles")[spawnedVehicle.vehicleName]
				if ( spot.doorGroup ) then
					spawnedVehicle:setDoorGroup( spot.doorGroup )
				end
			end
		end
	end )
elseif ( game.GetMap( ) == "lair_of_the_Beast8" ) then
	local lairEventStarted = false
	local uberBeastEntity = nil
	local npcSpawns = {
		["npc_uberbeast"] = {
			pos = Vector( -720, -595, -915 ),
			ang = Angle( 0, -180, 0 ),
			health = 60000
		},
		["npc_uberantlion"] = {
			spawnPoints = {
				{
					pos = Vector( 287, -1223, 140 ),
					ang = Angle( 0, 90, 0 ),
					health = 300
				},
				{
					pos = Vector( -245, -1527, 140 ),
					ang = Angle( 0, 100, 0 ),
					health = 400
				},
				{
					pos = Vector( -509, -1377, 140 ),
					ang = Angle( 0, 50, 0 ),
					health = 250
				},
				{
					pos = Vector( 98, -765, 140 ),
					ang = Angle( 0, -77, 0 ),
					health = 350
				},
				{
					pos = Vector( 644, -636, 140 ),
					ang = Angle( 0, -95, 0 ),
					health = 500
				},
				{
					pos = Vector( 947.652, -3566.557, -431.402 ),
					ang = Angle( 0, 0, 0 ),
					health = 500
				},
				{
					pos = Vector( 2409.553, -3809.019, -643.535 ),
					ang = Angle( 0, 0, 0 ),
					health = 300
				},
				{
					pos = Vector( 2039.297, -4784.386, -630.45 ),
					ang = Angle( 0, 0, 0 ),
					health = 350
				},
				{
					pos = Vector( 2612.132, -5325.856, -833.955 ),
					ang = Angle( 0, 0, 0 ),
					health = 500
				},
				{
					pos = Vector( 3250.643, -5180.067, -837.557 ),
					ang = Angle( 0, 0, 0 ),
					health = 350
				},
				{
					pos = Vector( 4763.376, -6122.309, -1109.969 ),
					ang = Angle( 0, 0, 0 ),
					health = 200
				},
				{
					pos = Vector( 4466.8, -6399.812, -1109.969 ),
					ang = Angle( 0, 0, 0 ),
					health = 300
				},
				{
					pos = Vector( 3822.763, -5370.219, -618 ),
					ang = Angle( 0, 0, 0 ),
					health = 250
				},
				{
					pos = Vector( 3822.763, -5370.219, -618 ),
					ang = Angle( 0, 0, 0 ),
					health = 300
				},
				{
					pos = Vector( 3822.763, -5370.219, -618 ),
					ang = Angle( 0, 0, 0 ),
					health = 550
				},
				{
					pos = Vector( 3822.763, -5370.219, -618 ),
					ang = Angle( 0, 0, 0 ),
					health = 400
				},
				{
					pos = Vector( 3822.763, -5370.219, -618 ),
					ang = Angle( 0, 0, 0 ),
					health = 300
				},
				{
					pos = Vector( 3822.763, -5370.219, -618 ),
					ang = Angle( 0, 0, 0 ),
					health = 350
				},
				{
					pos = Vector( 3822.763, -5370.219, -618 ),
					ang = Angle( 0, 0, 0 ),
					health = 400
				},
				{
					pos = Vector( 3822.763, -5370.219, -618 ),
					ang = Angle( 0, 0, 0 ),
					health = 200
				},
				{
					pos = Vector( -709.196, -428.552, -841.689 ),
					ang = Angle( 0, 0, 0 ),
					health = 250
				},
				{
					pos = Vector( -495.87, -860.661, -856.306 ),
					ang = Angle( 0, 0, 0 ),
					health = 300
				},
				{
					pos = Vector( 2105.353, -474.245, -686.986 ),
					ang = Angle( 0, 0, 0 ),
					health = 300
				},
				{
					pos = Vector( 2383.117, -746.278, -687.969 ),
					ang = Angle( 0, 0, 0 ),
					health = 350
				},
				{
					pos = Vector( 2236.315, -280.865, -687.969 ),
					ang = Angle( 0, 0, 0 ),
					health = 300
				}
			},
			spawnChance = 75,
			spawnInterval = { 5, 15 }
		}
	}

	local function CreateCountdownTimer( delay, timeLeft )
		timer.Simple( delay * 60, function( )
			player.SendColoredMessage( { COLOR_GREEN, string.NiceTime( timeLeft * 60 ), COLOR_RED, " REMAINING!" }, player.GetAll( ) )
		end )
	end

	hook.Add( "InitPostEntity", "SpawnEntitiesInMap", function( )
		RunConsoleCommand( "sbox_godmode", "0" ) // Let's make sure this is off.
		RunConsoleCommand( "bot" ) // Just incase of the unlikely case people never join the server, the shut down timer will still begin.
		SHNOOB_VARS:Set( "BeastEventActive", true )
		timer.Simple( 1, function( )
			for index, bot in ipairs( player.GetBots( ) ) do
				bot:Kick( )
			end
		end )
		timer.Simple( 1, function ( )
			for k, v in pairs( ents.GetAll( ) ) do
				if ( v:MapCreationID( ) == 1842 ) then SafeRemoveEntity( v ) end -- killer cave
				if ( v:GetClass( ) == "prop_physics" ) then v:SetGodmode( true ) end -- map props
			end
		end )
		// Fourty five minutes should be good.
		CreateCountdownTimer( 5, 40 )
		CreateCountdownTimer( 15, 30 )
		CreateCountdownTimer( 30, 15 )
		CreateCountdownTimer( 35, 10 )
		CreateCountdownTimer( 40, 5 )
		CreateCountdownTimer( 44, 1 )
		timer.Simple( 45 * 60, function( )
			if ( uberBeastEntity and IsValid( uberBeastEntity ) and uberBeastEntity:Health( ) < 5000 ) then -- if they're close to killing beast, cut them a break
				player.SendColoredMessage( { COLOR_GREEN, "Due to the ", COLOR_RED, "BLOODY ", COLOR_GREEN, "condition of the beast, you have ", COLOR_RED, "5 ", COLOR_GREEN, "extra minutes! Finish that fucker!!!" }, player.GetAll( ) )
			else -- either beast is dead or it has > 5k hp still
				player.SendColoredMessage( { COLOR_GREEN, "WOW YOU FUCKING ", COLOR_RED, "SUCK", COLOR_GREEN, "!!!" }, player.GetAll( ) )
				for k, v in pairs( player.GetAll() ) do
					net.Start("N00BRP_ConnectToBeast")
					net.WriteString( "108.61.9.83" )
					net.WriteString( "27017" )
					net.Send( v )
				end
				timer.Simple( 5, function( ) Entity( 0 ):Remove( ) end )
			end
		end )
		timer.Simple( 50 * 60, function( ) -- extension timer
			for k, v in pairs( player.GetAll() ) do
				net.Start("N00BRP_ConnectToBeast")
				net.WriteString( "108.61.9.83" )
				net.WriteString( "27017" )
				net.Send( v )
			end
			timer.Simple( 5, function( ) Entity( 0 ):Remove( ) end )
		end )
	end )

	local function AntlionSpawning( )
		local spawnTable = npcSpawns["npc_uberantlion"]
		if ( #ents.FindByClass( "npc_uberantlion" ) < 15 ) then
			local randomChance = math.random( 1, 100 )
			if ( randomChance < spawnTable.spawnChance ) then
				if ( #player.GetAll( ) > 0 ) then
					local distanceTable = { }
					local randPlayer = player.GetAll( )[ math.random( #player.GetAll( ) ) ]
					for index, spawnPoint in pairs ( spawnTable.spawnPoints ) do
						table.insert( distanceTable, { index = index, dist = spawnPoint.pos:Distance( randPlayer:GetPos( ) ) } )
					end
					table.SortByMember( distanceTable, "dist", true )
					local closestSpawnIndex = distanceTable[1].index
					local closestSpawn = spawnTable.spawnPoints[closestSpawnIndex]
					if ( util.PointContents( closestSpawn.pos ) ~= CONTENTS_MONSTER ) then
						local pos = closestSpawn.pos
						local entBox = ents.FindInBox( pos - Vector( 1500, 1500, 512 ), pos + Vector( 1500, 1500, 512 ) )
						local nearbyAntlions = 0
						for index, ent in ipairs ( entBox ) do
							if ( ent:GetClass( ) == "npc_uberantlion" ) then
								nearbyAntlions = nearbyAntlions + 1
							end
							if ( nearbyAntlions >= 3 ) then
								break
							end
						end
						if not ( nearbyAntlions >= 3 ) then
							local antlionEntity = ents.Create( "npc_uberantlion" )
							antlionEntity:SetPos( closestSpawn.pos )
							antlionEntity:SetAngles( closestSpawn.ang )
							antlionEntity.MaxHealth = closestSpawn.health
							antlionEntity:Spawn( )
						end
					end
				end
			end
		end
		timer.Adjust( "N00BRP_BeastLair_AntlionSpawner", math.random( spawnTable.spawnInterval[1], spawnTable.spawnInterval[2] ), 0, function( ) 
			AntlionSpawning( ) 
		end )
	end
	
	hook.Add( "PlayerInitialSpawn", "N00BRP_BeastLair_InitialSpawn", function( ply )
		if ( ply:IsBot( ) ) then return end
		if ( lairEventStarted ) then return end
		lairEventStarted = true
		timer.Simple( 60, function( )
			local beastSpawnTable = npcSpawns["npc_uberbeast"]
			uberBeastEntity = ents.Create( "npc_uberbeast" )
			uberBeastEntity:SetPos( beastSpawnTable.pos )
			uberBeastEntity:SetAngles( beastSpawnTable.ang )
			uberBeastEntity.MaxHealth = beastSpawnTable.health
			uberBeastEntity:Spawn( )
			local spawnTable = npcSpawns["npc_uberantlion"]
			timer.Create( "N00BRP_BeastLair_AntlionSpawner", math.random( spawnTable.spawnInterval[1], spawnTable.spawnInterval[2] ), 0, function( )
				AntlionSpawning( )
			end )
		end )
	end )
end
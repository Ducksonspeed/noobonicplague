noob_VehicleIndex = noob_VehicleIndex or { }
noob_VehicleIndex.spawnedVehicles = noob_VehicleIndex.spawnedVehicles or  { }

noob_VehicleIndex.Colors = {
	{ 
		Name = "Brick",
		Color = Color( 144, 63, 63 )
	},
	{ 
		Name = "Copper",
		Color = Color( 89, 57, 57 )
	},
	{ 
		Name = "Red",
		Color = Color( 189, 49, 44 )
	},
	{ 
		Name = "Cherry",
		Color = Color( 217, 12, 12 )
	},
	{ 
		Name = "Orange",
		Color = Color( 198, 76, 57 )
	},
	{ 
		Name = "Gold",
		Color = Color( 203, 151, 61 )
	},
	{ 
		Name = "Yellow",
		Color = Color( 177, 171, 60 )
	},
	{ 
		Name = "Lime",
		Color = Color( 171, 210, 94 )
	},
	{ 
		Name = "Olive",
		Color = Color( 81, 89, 66 )
	},
	{ 
		Name = "Green",
		Color = Color( 87, 160, 83 )
	},
	{ 
		Name = "Teal",
		Color = Color( 47, 57, 60 )
	},
	{ 
		Name = "Cyan",
		Color = Color( 85, 159, 175 )
	},
	{ 
		Name = "Graphite",
		Color = Color( 47, 51, 53 )
	},
	{ 
		Name = "Sky",
		Color = Color( 97, 151, 211 )
	},
	{ 
		Name = "Blue",
		Color = Color( 26, 73, 136 )
	},
	{ 
		Name = "Cobalt",
		Color = Color( 19, 77, 203 )
	},
	{ 
		Name = "Orchid",
		Color = Color( 103, 107, 210 )
	},
	{ 
		Name = "Purple",
		Color = Color( 91, 81, 167 )
	},
	{ 
		Name = "Violet",
		Color = Color( 72, 49, 118 )
	},
	{ 
		Name = "Pink",
		Color = Color( 185, 118, 232 )
	},
	{ 
		Name = "Hot Pink",
		Color = Color( 213, 64, 129 )
	},
	{ 
		Name = "Silver",
		Color = Color( 114, 116, 117 )
	},
	{ 
		Name = "Black",
		Color = Color( 8, 8, 8 )
	},
	{ 
		Name = "Silver",
		Color = Color( 114, 116, 117 )
	},
	{ 
		Name = "White",
		Color = Color( 225, 225, 225 )
	},
}

function noob_VehicleIndex:RandomColor()
	local max = #noob_VehicleIndex.Colors
	return noob_VehicleIndex.Colors[ math.random( 1, max ) ].Color
end

function noob_VehicleIndex:Add( model, niceName, vehHealth, minSalvage, maxSalvage, passengerSeats, hideSeats, seatType, maxGas, customExits )
	noob_WeaponIndex[ model ] = { name = niceName, health = vehHealth, minSalvage = minSalvage, maxSalvage = maxSalvage, passengerSeats = passengerSeats, hideSeats = hideSeats, seatType = seatType, maxGas = maxGas, customExits = customExits }
end

function noob_VehicleIndex:Get( model )
	return noob_WeaponIndex[ model ]
end

function noob_VehicleIndex:TrackVehicle( veh )
	table.insert( noob_VehicleIndex.spawnedVehicles, veh )
end

function noob_VehicleIndex:GetTrackedVehicles( )
	return noob_VehicleIndex.spawnedVehicles
end

function noob_VehicleIndex:IsUnColorableVehicle( model )
	local unColorableVehicles = { }
	unColorableVehicles["models/sentry/c5500_ambu.mdl"] = true
	unColorableVehicles["models/sentry/07crownvic_cvpi.mdl"] = true
	unColorableVehicles["models/sentry/rv.mdl"] = true
	unColorableVehicles["models/airboat.mdl"] = true
	unColorableVehicles["models/lonewolfie/ford_f350_ambu.mdl"] = true
	unColorableVehicles["ECPD Taurus"] = true
	if ( unColorableVehicles[model] ) then
		return true
	else
		return false
	end
end

function noob_VehicleIndex:SpawnVehicle( name, spawnPos, spawnAng )
	local vehData = util.FindVehicleData( name )
	if not ( vehData ) then return nil end
	local spawnedVehicle = ents.Create( vehData.Class )
	spawnedVehicle:SetModel( vehData.Model )
	if ( vehData.KeyValues ) then 
		for index, val in pairs( vehData.KeyValues ) do
			spawnedVehicle:SetKeyValue( index, val )
		end
	end
	if list.Get( "Vehicles" )[name] then spawnedVehicle.VehicleTable = list.Get( "Vehicles" )[name] end
	if name == "Evo City Bus" or name == "ECPD Taurus" or name == "Evo City Ambulance" then spawnedVehicle.EMV = true end
	spawnedVehicle:SetPos( spawnPos )
	spawnedVehicle:SetAngles( spawnAng )
	spawnedVehicle:Spawn( )
	spawnedVehicle:Activate( )
	spawnedVehicle.vehicleName = name
	noob_VehicleIndex:TrackVehicle( spawnedVehicle )
	return spawnedVehicle
end

timer.Create( "N00BRP_VehicleCleanup", 360, 0, function( )
	if ( !noob_VehicleIndex.spawnedVehicles or #noob_VehicleIndex.spawnedVehicles <= 0 ) then return end
	for index, veh in ipairs ( noob_VehicleIndex.spawnedVehicles ) do
		if not ( IsValid( veh ) ) then
			table.remove( noob_VehicleIndex.spawnedVehicles, index )
			continue
		end
		veh.playerLastUsed = veh.playerLastUsed or CurTime( )
		local vehExpireTime = tonumber( SVNOOB_VARS:Get( "VehicleExpireTime" ) ) or 360
		if ( ( !IsValid( veh:getDoorOwner( ) ) or veh:getDoorOwner( ).isMarkedAFK ) and veh.playerLastUsed < ( CurTime( ) - vehExpireTime ) ) then
			if ( IsValid( veh:GetDriver( ) ) ) then
				veh.playerLastUsed = CurTime( )
				continue
			end
			veh:Destroy( )
			table.remove( noob_VehicleIndex.spawnedVehicles, index )
		end
	end
end )

/*---------------------TDM Vehicles------------*/
noob_VehicleIndex:Add( "models/tdmcars/bus.mdl", "Evo City Bus", 10000, 300, 700, {
	{ pos = Vector( -30, 63, 32 ), ang = Angle( 0, 0, 10 ) },
	{ pos = Vector( -30, 22, 32 ), ang = Angle( 0, 0, 10 ) },
	{ pos = Vector( -30, -19, 32 ), ang = Angle( 0, 0, 10 ) },
	{ pos = Vector( -30, -60, 32 ), ang = Angle( 0, 0, 10 ) },
	{ pos = Vector( -30, -100, 32 ), ang = Angle( 0, 0, 10 ) },
	{ pos = Vector( -30, 118, 54 ), ang = Angle( 0, 0, 10 ) },
	{ pos = Vector( -30, 170, 54 ), ang = Angle( 0, 0, 10 ) },
	{ pos = Vector( -30, 208, 54 ), ang = Angle( 0, 0, 10 ) },
	{ pos = Vector( -30, 240, 54 ), ang = Angle( 0, 0, 10 ) },
	{ pos = Vector( 30, -19, 32 ), ang = Angle( 0, 0, 10 ) },
	{ pos = Vector( 30, -60, 32 ), ang = Angle( 0, 0, 10 ) },
	{ pos = Vector( 30, -100, 32 ), ang = Angle( 0, 0, 10 ) },
	{ pos = Vector( 30, 118, 54 ), ang = Angle( 0, 0, 10 ) },
	{ pos = Vector( 30, 170, 54 ), ang = Angle( 0, 0, 10 ) },
	{ pos = Vector( 30, 208, 54 ), ang = Angle( 0, 0, 10 ) },
	{ pos = Vector( 30, 240, 54 ), ang = Angle( 0, 0, 10 ) },
	{ pos = Vector( 0, 240, 54 ), ang = Angle( 0, 0, 10 ) }
}, true, "jeep_seat", 400, {
	{ -100, 250, 20 },
	{ -100, 63, 20 },
	{ -100, 22, 20 },
	{ -100, -19, 20 },
	{ -100, -60, 20 },
	{ -100, -100, 20 },
	{ -100, 118, 20 },
	{ -100, 170, 20 },
	{ -100, 208, 20 },
	{ -100, 270, 20 },
	{ 100, -19, 20 },
	{ 100, -60, 20 },
	{ 100, -100, 20 },
	{ 100, 118, 20 },
	{ 100, 170, 20 },
	{ 100, 208, 20 },
	{ 100, 240, 20 },
} )

/*---------------------SentryGunMan Vehicles------------*/


noob_VehicleIndex:Add( "models/sentry/c5500_ambu.mdl", "GMC C5500 Ambulance", 3500, 500, 1000, {
	{ pos = Vector( 23, -30, 38 ), ang = Angle( 0, 0, 0 ) }
}, true, "jeep_seat", 150 )

noob_VehicleIndex:Add( "models/sentry/07crownvic_cvpi.mdl", "ECPD Crown Victoria", 3000, 500, 1000, {
	{ pos = Vector( 20, -15, 15 ), ang = Angle( 0, 0, 5 ) },
	{ pos = Vector( 20, 26, 19 ), ang = Angle( 0, 0, 5 ) },
	{ pos = Vector( 0, 26, 19 ), ang = Angle( 0, 0, 5 ) },
	{ pos = Vector( -20, 26, 19 ), ang = Angle( 0, 0, 5 ) }
}, true, "jeep_seat", 250, {
	{ -80, -15, 10 },
	{ 80, -15, 10 },
	{ 80, 26, 10 },
	{ 0, -200, 10 },
	{ -80, 26, 10 },
} )

noob_VehicleIndex:Add( "models/sentry/mp4-12c.mdl", "McLaren MP4-12C", 4000, 1000, 4000, {
	{ pos = Vector( 16.6, -5, 13 ), ang = Angle( 0, 0, 12 ) }
}, true, "jeep_seat", 200, {
	{ -80, -5, 10 },
	{ 80, -5, 10 },
} )


noob_VehicleIndex:Add( "models/sentry/elcamino.mdl", "1970 Chevrolet El Camino SS 454", 3500, 450, 1250, {
	{ pos = Vector( 13.5, -23, 13 ), ang = Angle( 0, 0, 10 ) }
}, true, "jeep_seat", 170, {
	{ -80, -23, 10 },
	{ 80, -23, 10 },
} )

noob_VehicleIndex:Add( "models/sentry/lfa.mdl", "Lexus LF-A", 5000, 750, 1750, {
	{ pos = Vector( 21, 12, 11.75 ), ang = Angle( 0, 0, 10 ) }
}, true, "jeep_seat", 200, {
	{ -80, 12, 10 },
	{ 80, 12, 10 }
} )

noob_VehicleIndex:Add( "models/sentry/boss302.mdl", "2013 Ford Mustang Boss 302", 3750, 400, 1000, {
	{ pos = Vector( 18, -3, 14 ), ang = Angle( 0, 0, 12 ) },
	{ pos = Vector( 13.6, 32, 16 ), ang = Angle( 0, 0, 14 ) },
	{ pos = Vector( -13.6, 32, 16 ), ang = Angle( 0, 0, 14 ) }
}, true, "jeep_seat", 230, {
	{ -80, -3, 10 },
	{ 80, -3, 10 },
	{ 80, 32, 10 },
	{ -80, 32, 10 },
} )

noob_VehicleIndex:Add( "models/sentry/supercab.mdl", "2008 Saleen S331 Supercab", 6500, 650, 1000, {
	{ pos = Vector( 21, -25, 30 ), ang = Angle( 0, 0, 5 ) },
	{ pos = Vector( 21, 12, 30 ), ang = Angle( 0, 0, 5 ) },
	{ pos = Vector( -21, 12, 30 ), ang = Angle( 0, 0, 5 ) },
	{ pos = Vector( 0, 12, 30 ), ang = Angle( 0, 0, 5 ) }
}, true, "jeep_seat", 150, {
	{ -90, -25, 10 },
	{ 90, -25, 10 },
	{ 90, 12, 10 },
	{ -90, 12, 10 },
	{ 0, -300, 10 },
} )

noob_VehicleIndex:Add( "models/sentry/ccx.mdl", "Koenigsegg CCX", 3850, 1000, 3000, {
	{ pos = Vector( 18, -2, 6 ), ang = Angle( 0, 0, 0 ) }
}, true, "jeep_seat", 180, {
	{ -80, -2, 10 },
	{ 80, -2, 10 },
} )

noob_VehicleIndex:Add( "models/sentry/taurussho.mdl", "ECPD Taurus", 3500, 300, 1000, {
	{ pos = Vector( 19, -3.5, 23 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( 16, 37, 23 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( -16, 37, 23 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( 0, 37, 23 ), ang = Angle( 0, 0, 0 ) }
}, true, "jeep_seat", 210, {
	{ -80, 0, 10 },
	{ 80, 0, 10 },
	{ 80, -37, 10 },
	{ -80, -37, 10 },
	{ 0, -200, 10 },
})
/*noob_VehicleIndex:Add( "models/sentry/taurussho.mdl", "2010 Ford Taurus SHO", 3500, 900, 1300, {
	{ pos = Vector( 19, -3.5, 23 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( 16, 37, 23 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( -16, 37, 23 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( 0, 37, 23 ), ang = Angle( 0, 0, 0 ) }
}, true, "jeep_seat", 210, {
	{ -80, 0, 10 },
	{ 80, 0, 10 },
	{ 80, -37, 10 },
	{ -80, -37, 10 },
	{ 0, -200, 10 },
})*/

noob_VehicleIndex:Add( "models/sentry/peelp50.mdl", "Peel P50", 2500, 450, 950, {
}, true, "jeep_seat", 180, {
	{ -70, 10, 10 },
	{ 70, 10, 10 },
} )

noob_VehicleIndex:Add( "models/sentry/ram3500.mdl", "Dodge Ram 3500", 3500, 750, 1450, {
	{ pos = Vector( 19, -3.5, 23 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( 16, 37, 23 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( -16, 37, 23 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( 0, 37, 23 ), ang = Angle( 0, 0, 0 ) }
}, true, "jeep_seat", 210, {
	{ -80, 0, 10 },
	{ 80, 0, 10 },
	{ 80, -37, 10 },
	{ -80, -37, 10 },
	{ 0, -200, 10 },
} )

/*---------------------Lonewolfie Vehicles------------*/

noob_VehicleIndex:Add( "models/lonewolfie/smart_fortwo.mdl", "Smart ForTwo", 3000, 450, 600, {
	{ pos = Vector( 16, 10, 25 ), ang = Angle( 0, 0, 0 ) }
}, true, "jeep_seat", 250, {
	{ -70, 10, 10 },
	{ 70, 10, 10 },
} )

noob_VehicleIndex:Add( "models/lonewolfie/lam_huracan.mdl", "Lamborghini Huracan LP 610-4", 3000, 700, 1230, {
	{ pos = Vector( 20, -5, 10 ), ang = Angle( 0, 0, 5 ) }
	--{ pos = Vector( -20, 26, 19 ), ang = Angle( 0, 0, 5 ) }
}, true, "jeep_seat", 125, {
	{ -80, -5, 10 },
	{ 80, -5, 10 },
 } )

noob_VehicleIndex:Add( "models/lonewolfie/ford_f350_ambu.mdl", "Evo City Ambulance", 8000, 400, 1200, {
	{ pos = Vector( 20, -45, 40 ), ang = Angle( 0, 0, 10 ) },
	{ pos = Vector( 16, 125, 65 ), ang = Angle( 0, 180, 0 ) },
}, true, "jeep_seat", 400, {
	{ -90, 45, 10 },
	{ 90, 45, 10 },
	{ 90, 200, 10 },
 } )

noob_VehicleIndex:Add( "models/lonewolfie/suzuki_kingquad.mdl", "Suzuki Kingquad", 2000, 300, 600, {
	{ pos = Vector( 0, 32.5, 35 ), ang = Angle( 0, 0, 0 ) }
}, true, "jeep_seat", 100, {
	{ -50, 20, 10 },
	{ 50, 20, 10 },
} )

/*------------------------------------------------*/

noob_VehicleIndex:Add( "models/airboat.mdl", "Passenger Airboat", 3000, 200, 500, {
	{ pos = Vector( 32, -22, 18 ), ang = Angle( 0, -90, 0 ) },
	{ pos = Vector( -32, -22, 18 ), ang = Angle( 0, 90, 0 ) },
	{ pos = Vector( 32, 22, 18 ), ang = Angle( 0, -90, 0 ) },
	{ pos = Vector( -32, 22, 18 ), ang = Angle( 0, 90, 0 ) }
}, false, "jeep_seat", 240, {
	{ 0, -150, 10 },
	{ 80, -22, 10 },
	{ -80, -22, 10 },
	{ 80, 22, 10 },
	{ -80, 22, 10 },
} )

noob_VehicleIndex:Add( "models/buggy.mdl", "Jeep", 4000, 100, 300, {
	{ pos = Vector( 16, 37, 19 ), ang = Angle( 0, 0, 0 ) }
}, false, "jeep_seat", 190, {
	{ -80, 37, 10 },
	{ 80, 37, 10 },
} )

noob_VehicleIndex:Add( "models/sentry/rv.mdl", "Recreation Vehicle", 10000, 300, 700, {
	{ pos = Vector( 33, -122, 37 ), ang = Angle( 0, 0, 0 ) }, // shotgun passenger seat
	{ pos = Vector( -34, -46, 40 ), ang = Angle( 0, 180, 0 ) }, // backfacing table
	{ pos = Vector( -34, 0, 40 ), ang = Angle( 0, 0, 0 ) }, // forward facing table
	{ pos = Vector( -33, 30, 40 ), ang = Angle( 0, -90, 0 ) }, // side seat
	{ pos = Vector( 30, 138, 110 ), ang = Angle( 0, 180, 0 ) }, // ladder
	{ pos = Vector( -34, 85, 107 ), ang = Angle( 180, 180, 45 ) }, // closet upside down
	{ pos = Vector( -15, 118, 42 ), ang = Angle( 0, -90, 45 ) }, // bed1
	{ pos = Vector( -15, 134, 42 ), ang = Angle( 0, -90, 45 ) } // bed2
}, true, "jeep_seat", 150, {
	{ -95, -122, 10 },
	{ 95, -122, 10 },
	{ -95, 0, 10 },
	{ -95, 30, 10 },
	{ 95, 138, 10 },
	{ -95, 85, 10 },
	{ -95, 118, 10 },
	{ -95, 134, 10 },
} )
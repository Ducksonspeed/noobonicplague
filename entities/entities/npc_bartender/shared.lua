ENT.Base 	= "npc_noob_base";
ENT.Model 	 = "models/Characters/hostage_04.mdl";
ENT.Position = Vector( 11880, 14, 236 );
ENT.EnableReputation = false
ENT.Angles = Angle( 0, 180, 0 )
ENT.isRobbable = true
ENT.robRewardRange = { 500, 1500 }
ENT.FloatingTitle = "Bartender"

if ( SERVER ) then
	ENT.NPCTable = 
	{
		[ "perm_airboat" ] =
		{
			text = "Permanent Airboat",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "airboat_keys", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Airboat!" )
					end
				end )
			end,
			price = 250000
		},
		[ "perm_jeep" ] = 
		{
			text = "Permanent Jeep",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "jeep_keys", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Jeep!" )
					end
				end )
			end,
			price = 150000
		},
		[ "perm_vehiclehat" ] = 
		{
			text = "Permanent Vehicle Hat",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "vehicle_hat", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Vehicle Hat!" )
					end
				end )
			end,
			price = 75000
		},
		[ "perm_p228" ] = 
		{
			text = "Permanent P228",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "swb_p228", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent P228!" )
					end
				end )
			end,
			price = 200000
		},
		[ "perm_boothat" ] = 
		{
			text = "Permanent Boot Hat",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "boot_hat", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Boot Hat!" )
					end
				end )
			end,
			price = 1000000
		},
		[ "perm_planthat" ] = 
		{
			text = "Permanent Plant Hat",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "plant_hat", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Plant Hat!" )
					end
				end )
			end,
			price = 750000
		},
		[ "rob_me" ] =
		{
			text = "This is a robbery!",
			func = function( pl, ent )
				if ( ent.isRobbable and ent.RobNPC ) then
					ent:RobNPC( pl )
				end
			end
		}
	};
end

ENT.Base 	= "npc_noob_base";
ENT.Model 	 = "models/Characters/hostage_03.mdl";
ENT.Position = Vector( 1737, 13795, 224 );
ENT.EnableReputation = false
ENT.Angles = Angle( 0, 139, 0 )
ENT.isRobbable = true
ENT.robRewardRange = { 500, 1500 }
ENT.FloatingTitle = "Miscellaneous Salesman"

if ( SERVER ) then
	ENT.NPCTable = 
	{
		[ "perm_koenigsegg" ] = 
		{
			text = "Permanent Koenigsegg CCX",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "koenigsegg_keys", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Koenigsegg CCX!" )
					end
				end )
			end,
			price = 3500000
		},
		[ "perm_supercab" ] = 
		{
			text = "Permanent Supercab",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "supercab_keys", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Supercab!" )
					end
				end )
			end,
			price = 2500000
		},
		[ "rob_me" ] =
		{
			text = "Hand over the cash, mate.",
			func = function( pl, ent )
				if ( ent.isRobbable and ent.RobNPC ) then
					ent:RobNPC( pl )
				end
			end
		},
		[ "perm_shovel" ] =
		{
			text = "Permanent Shovel",
			func = function( pl, ent, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "shovel", price, false, nil, function( success ) 
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Shovel!" )
					end
				end )
			end,
			price = 5000000
		},
		[ "perm_defib" ] =
		{
			text = "Permanent Defibrillator",
			func = function( pl, ent, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "defibrillator", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Defibrillator!" )
					end
				end )
			end,
			price = 4000000
		}
	};
end
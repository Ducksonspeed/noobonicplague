ENT.Base 	= "npc_noob_base";
ENT.Model 	 = "models/humans/group02/male_08.mdl";
ENT.Position = Vector( -7855, -8805, 1736 );
ENT.EnableReputation = false
ENT.Angles = Angle( 0, -90, 0 )
ENT.isRobbable = true
ENT.robRewardRange = { 500, 1500 }
ENT.onlyCP = true
ENT.FloatingTitle = "Civil Protection Dealer"

if ( SERVER ) then
	ENT.NPCTable = 
	{
		[ "perm_ak47" ] =
		{
			text = "Permanent AK47",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "swb_ak47", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent AK47!" )
					end
				end )
			end,
			price = 3700000
		},
		[ "perm_m249" ] =
		{
			text = "Permanent M249",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "swb_m249", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent M249!" )
					end
				end )
			end,
			price = 6400000
		},
		[ "perm_xm1014" ] =
		{
			text = "Permanent XM1014",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "swb_xm1014", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent XM1014!" )
					end
				end )
			end,
			price = 4000000
		},
		[ "perm_m3super90" ] =
		{
			text = "Permanent M3 Super 90",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "swb_m3super90", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent M3 Super 90!" )
					end
				end )
			end,
			price = 4400000
		},
		[ "perm_m4a1" ] =
		{
			text = "Permanent M4A1",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "swb_m4a1", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent M4A1!" )
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
		}
	};
end
ENT.Base 	= "npc_noob_base";
ENT.Model 	 = "models/humans/group02/female_07.mdl";
ENT.Position = Vector( 4309, -4413, 72 );
ENT.EnableReputation = false
ENT.Angles = Angle( 0, -90, 0 )
ENT.isRobbable = true
ENT.robRewardRange = { 500, 1500 }
ENT.FloatingTitle = "Car Dealer"

if ( SERVER ) then
	ENT.NPCTable = 
	{
		/*[ "perm_taurus" ] =
		{
			text = "Permanent Ford Taurus",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "taurus_keys", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Ford Taurus!" )
					end
				end )
			end,
			price = 3800000
		},*/
		[ "perm_lexus" ] =
		{
			text = "Permanent Lexus",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "taurus_keys", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Lexus!" )
					end
				end )
			end,
			price = 4500000
		},
		[ "perm_lambo" ] =
		{
			text = "Permanent Lamborghini",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "lambo_keys", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Lamborghini!" )
					end
				end )
			end,
			price = 5000000
		},
		[ "perm_p50" ] =
		{
			text = "Permanent Peel P50",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "p50_keys", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Peel P50!" )
					end
				end )
			end,
			price = 500000
		},
		/*[ "perm_dodgeram" ] =
		{
			text = "Permanent Dodge Ram 3500",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "dodgeram_keys", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Dodge Ram 3500!" )
					end
				end )
			end,
			price = 3500000
		}*/
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
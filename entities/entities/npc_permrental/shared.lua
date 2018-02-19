ENT.Base 	= "npc_noob_base";
ENT.Model 	 = "models/odessa.mdl";
ENT.Position = Vector( -6333.975586, -7954.186523, 120.031 )
ENT.EnableReputation = false
ENT.Angles = Angle( 0, 0, 0 )
ENT.isRobbable = false
ENT.FloatingTitle = "Item Rental"

if ( SERVER ) then
	ENT.NPCTable = 
	{
		[ "rent_ugalil" ] =
		{
			text = "Uncommon Galil: 3 Days",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:RentPerm( "swb_uncommon_galil", 4320, price, function( success, enum )
					if not ( success ) then
						pl:DisplayFeedback( enum, nil, nil )
					else
						pl:DisplayFeedback( enum, "swb_uncommon_galil", 4320 )
					end
				end )
			end,
			price = 1000000
		},
		[ "rent_um249" ] =
		{
			text = "Uncommon M249: 3 Days",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:RentPerm( "swb_uncommon_m249", 4320, price, function( success, enum )
					if not ( success ) then
						pl:DisplayFeedback( enum, nil, nil )
					else
						pl:DisplayFeedback( enum, "swb_uncommon_m249", 4320 )
					end
				end )
			end,
			price = 1000000
		},
		[ "rent_um4a1" ] =
		{
			text = "Uncommon M4A1: 3 Days",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:RentPerm( "swb_uncommon_m4a1", 4320, price, function( success, enum )
					if not ( success ) then
						pl:DisplayFeedback( enum, nil, nil )
					else
						pl:DisplayFeedback( enum, "swb_uncommon_m4a1", 4320 )
					end
				end )
			end,
			price = 1000000
		},
		[ "rent_ushotty" ] =
		{
			text = "Uncommon Shotgun: 3 Days",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:RentPerm( "swb_uncommon_m3super90", 4320, price, function( success, enum )
					if not ( success ) then
						pl:DisplayFeedback( enum, nil, nil )
					else
						pl:DisplayFeedback( enum, "swb_uncommon_m3super90", 4320 )
					end
				end )
			end,
			price = 1000000
		},
		[ "rent_ushovel" ] =
		{
			text = "Uncommon Shovel: 1 Day",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:RentPerm( "uncommon_shovel", 1440, price, function( success, enum )
					if not ( success ) then
						pl:DisplayFeedback( enum, nil, nil )
					else
						pl:DisplayFeedback( enum, "uncommon_shovel", 1440 )
					end
				end )
			end,
			price = 1000000
		},
		[ "rent_rak47" ] =
		{
			text = "Rare AK47: 3 Days",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:RentPerm( "swb_rare_ak47", 4320, price, function( success, enum )
					if not ( success ) then
						pl:DisplayFeedback( enum, nil, nil )
					else
						pl:DisplayFeedback( enum, "swb_rare_ak47", 4320 )
					end
				end )
			end,
			price = 3000000
		},
		[ "rent_rknife" ] =
		{
			text = "Rare Knife: 3 Days",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:RentPerm( "swb_rare_knife", 4320, price, function( success, enum )
					if not ( success ) then
						pl:DisplayFeedback( enum, nil, nil )
					else
						pl:DisplayFeedback( enum, "swb_rare_knife", 4320 )
					end
				end )
			end,
			price = 2000000
		},
		[ "rent_sg552" ] =
		{
			text = "SG552: 1 Day",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:RentPerm( "swb_sg552", 1440, price, function( success, enum )
					if not ( success ) then
						pl:DisplayFeedback( enum, nil, nil )
					else
						pl:DisplayFeedback( enum, "swb_sg552", 1440 )
					end
				end )
			end,
			price = 250000
		},
		[ "rent_sg550" ] =
		{
			text = "SG550: 1 Day",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:RentPerm( "swb_sg550", 1440, price, function( success, enum )
					if not ( success ) then
						pl:DisplayFeedback( enum, nil, nil )
					else
						pl:DisplayFeedback( enum, "swb_sg550", 1440 )
					end
				end )
			end,
			price = 250000
		},
		[ "rent_riotshield" ] =
		{
			text = "Riot Shield: 3 Days",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:RentPerm( "riot_shield", 4320, price, function( success, enum )
					if not ( success ) then
						pl:DisplayFeedback( enum, nil, nil )
					else
						pl:DisplayFeedback( enum, "riot_shield", 4320 )
					end
				end )
			end,
			price = 500000
		}
	};
end

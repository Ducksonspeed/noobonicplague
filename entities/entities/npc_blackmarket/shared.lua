ENT.Base 	= "npc_noob_base";
ENT.Model 	 = "models/Humans/Group03/Male_01.mdl";
ENT.Position = Vector( 12117, 1966, 355 );
ENT.EnableReputation = false
ENT.Angles = Angle( 0, -156, 0 )
ENT.isRobbable = true
ENT.robRewardRange = { 500, 1500 }
ENT.FloatingTitle = "Black Market Dealer"

if ( SERVER ) then
	ENT.NPCTable = 
	{
		[ "perm_galil" ] = 
		{
			text = "Permanent Galil",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "swb_galil", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Galil!" )
					end
				end )
			end,
			price = 2000000
		},
		[ "perm_famas" ] = 
		{
			text = "Permanent FAMAS",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "swb_famas", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent FAMAS!" )
					end
				end )
			end,
			price = 1000000
		},
		[ "perm_p90" ] = 
		{
			text = "Permanent P90",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "swb_p90", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent P90!" )
					end
				end )
			end,
			price = 1200000
		},
		[ "perm_ump" ] = 
		{
			text = "Permanent UMP",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "swb_ump", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent UMP!" )
					end
				end )
			end,
			price = 750000
		},
		[ "rob_me" ] =
		{
			text = "Give me the money, now!",
			func = function( pl, ent )
				if ( ent.isRobbable and ent.RobNPC ) then
					ent:RobNPC( pl )
				end
			end
		}
	};
end

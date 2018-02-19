ENT.Base 	= "npc_noob_base";
ENT.Model 	 = "models/police.mdl";
ENT.Position = Vector( -7253, -8571, 235 );
ENT.EnableReputation = false
ENT.Angles = Angle( 0, 90, 0 )
ENT.FloatingTitle = "The Warden"

if ( SERVER ) then
	ENT.NPCTable = 
	{
		[ "unarrest_me" ] =
		{
			text = "Am I free to go?",
			func = function( pl )
				if ( pl:isArrested( ) ) then
					pl:ChatPrint( "Uhh lemme check these papers.. wait.. COME BACK HERE!" )
					pl:SetWanted( 300, " has escaped from Jail and was automatically wanted!" )
					pl:unArrest( )
					hook.Call( "OnPlayerEscapeJail", { }, pl )
				else
					pl:ChatPrint( "Get out of my face." )
				end
			end
		},
		[ "perm_mac10" ] = 
		{
			text = "Permanent Mac10",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "swb_mac10", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Mac10!" )
					end
				end )
			end,
			price = 600000
		},
		[ "perm_usp" ] = 
		{
			text = "Permanent USP",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "swb_usp", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent USP!" )
					end
				end )
			end,
			price = 300000
		},
		[ "perm_fiveseven" ] = 
		{
			text = "Permanent FiveSeven",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "swb_fiveseven", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent FiveSeven!" )
					end
				end )
			end,
			price = 250000
		},
		[ "perm_deagle" ] = 
		{
			text = "Permanent Deagle",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "swb_deagle", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Deagle!" )
					end
				end )
			end,
			price = 750000
		},
		[ "perm_mp5" ] = 
		{
			text = "Permanent MP5",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "swb_mp5", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent MP5!" )
					end
				end )
			end,
			price = 1500000
		}
	};
end

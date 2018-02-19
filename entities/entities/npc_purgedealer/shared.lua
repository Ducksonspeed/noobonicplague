ENT.Base 	= "npc_noob_base";

ENT.Model 	 = "models/humans/group03/male_06.mdl";

ENT.Position = Vector( -2856.887695, 217.033264, 133.031250 )
ENT.Angles = Angle( 0, -90, 0 )
ENT.EnableReputation = false
ENT.isRobbable = true
ENT.robRewardRange = { 500, 1500 }
ENT.disallowCitizens = true
ENT.FloatingTitle = "Purge Dealer"

if ( SERVER ) then
	ENT.NPCTable = 
	{
		[ "stick_up" ] =
		{
			text = "Give me all the cash, now.",
			func = function( pl, ent )
				if ( ent.isRobbable and ent.RobNPC ) then
					ent:RobNPC( pl )
				end
			end
		},
		[ "purge_hp_100" ] =
		{
			text = "100 Health",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				if ( pl:canAfford( price ) ) then
					if ( pl:Health( ) >= pl:GetMaxHealth( ) ) then
						DarkRP.notify( pl, 1, 4, "You're already at full health!" )
					else
						pl:addMoney( -price )
						pl:SetHealth( math.Clamp( pl:Health( ) + 100, 0, pl:GetMaxHealth( ) ) )
						DarkRP.notify( pl, 2, 4, "You've purchased 100hp for $" .. tostring( price ) .. "!" )
					end
				else
					DarkRP.notify( pl, 1, 4, "You can't afford that." )
				end
			end,
			price = 250
		},
		[ "purge_crowbar" ] =
		{
			text = "Purge Duration Crowbar",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:RentPurgeItem( "weapon_crowbar", price, "Crowbar" )
			end,
			price = 30000
		},
		[ "purge_ak47" ] =
		{
			text = "Purge Duration AK-47",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:RentPurgeItem( "swb_ak47", price, "AK-47" )
			end,
			price = 20000
		},
		[ "purge_m249" ] =
		{
			text = "Purge Duration M249",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:RentPurgeItem( "swb_m249", price, "M249 SAW" )
			end,
			price = 30000
		},
		[ "purge_awp" ] =
		{
			text = "Purge Duration AWP",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:RentPurgeItem( "swb_awp", price, "AWP" )
			end,
			price = 25000
		},
		[ "purge_riotshield" ] =
		{
			text = "Purge Duration Riot Shield",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:RentPurgeItem( "riot_shield", price, "Riot Shield" )
			end,
			price = 30000
		},
		[ "purge_defibrillator" ] =
		{
			text = "Purge Duration Defibrillator",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:RentPurgeItem( "defibrillator", price, "Defibrillator" )
			end,
			price = 12500
		},
		[ "purge_traffic_hat" ] =
		{
			text = "Purge Duration Traffic Hat",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:RentPurgeItem( "traffic_hat", price, "Traffic Hat" )
			end,
			price = 17500
		}
	};
end

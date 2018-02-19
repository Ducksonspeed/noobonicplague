ENT.Base 	= "npc_noob_base";

ENT.Model 	 = "models/Humans/Group03m/Female_02.mdl";

ENT.Position = Vector( -3020, -6003, 262 )
ENT.Angles = Angle( 0, -90, 0 )

ENT.EnableReputation = false
ENT.isRobbable = true
ENT.robRewardRange = { 500, 1500 }
ENT.FloatingTitle = "Gem Trader"

if ( SERVER ) then
	ENT.NPCTable = 
	{
		[ "gem_menu" ] =
		{
			text = "Combine & Sell Gems",
			func = function( pl )
				pl:ConCommand( "rp_gemsmenu" )
			end
		},
		[ "rob_me" ] =
		{
			text = "Fork over the cash.",
			func = function( pl, ent )
				if ( ent.isRobbable and ent.RobNPC ) then
					ent:RobNPC( pl )
				end
			end
		},
		[ "perm_smartcar" ] =
		{
			text = "Permanent Smart Car",
			func = function( pl, ent, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "smart_keys", price, false, nil, function( success ) 
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Smart Car!" )
					end
				end )
			end,
			price = 500000
		},
		[ "perm_rv" ] =
		{
			text = "Permanent RV",
			func = function( pl, ent, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "rv_keys", price, false, nil, function( success ) 
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Recreational Vehicle!" )
					end
				end )
			end,
			price = 1350000
		},
		[ "perm_traffichat" ] =
		{
			text = "Permanent Traffic Hat",
			func = function( pl, ent, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "traffic_hat", price, false, nil, function( success ) 
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Traffic Hat!" )
					end
				end )
			end,
			price = 3250000
		},
		[ "perm_tophat" ] =
		{
			text = "Permanent Top Hat",
			func = function( pl, ent, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "top_hat", price, false, nil, function( success ) 
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Top Hat!" )
					end
				end )
			end,
			price = 2650000
		}
	}
	ENT.NPCQuestTable = 
	{
		["beast_hat_quest"] =
		{
			["stage_not_started"] =
			{
				text = "Interested in a Beast Hat?",
				func = function( pl )
					if ( pl:AlreadyOnQuest( ) ) then
						DarkRP.notify( pl, 1, 4, "You're already on a quest." )
					else
						DarkRP.notify( pl, 1, 4, "You've begun the Beast Hat Quest!" )
						pl:BeginQuest( "beast_hat_quest" )
						pl:ChatPrint( "If you slay one of the Beast's children without getting killed, I will award you with a Beast Hat." )
					end
				end,
				allowPickup = function( pl )
					if ( pl:HasWeaponStored( "beast_hat" ) ) then
						return false
					else
						return true
					end
				end
			},
			["stage_in_progress"] =
			{
				text = "You're back already?",
				func = function( pl )
					pl:ChatPrint( "You didn't kill one of the Beast's children yet? Why are you even talking to me?" )
				end
			},
			["stage_complete"] =
			{
				text = "I've been waiting for you.",
				func = function( pl )
					local isOnQuest, questStage = pl:IsOnQuest( "beast_hat_quest" )
					if not ( isOnQuest ) then
						DarkRP.notify( pl, 1, 4, "You aren't on this quest." )
					else
						if not ( pl:IsQuestCompleted( ) ) then
							DarkRP.notify( pl, 1, 4, "You haven't finished this quest." )
						else
							DarkRP.notify( pl, 2, 4, "Nice work, here's the beast hat like I promised." )
							pl:GivePermWeapon( "beast_hat" )
							PrintMessage( HUD_PRINTTALK, pl:Nick( ) .. " has slain one of the Beast's children and was awarded a permanent Beast Hat!" )
							pl:RemoveQuest( )
						end
					end
				end
			}
		}
	}
end

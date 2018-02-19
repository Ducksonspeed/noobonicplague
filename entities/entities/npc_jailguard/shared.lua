ENT.Base 	= "npc_noob_base";

ENT.Model 	 = "models/humans/group03/male_08.mdl";
ENT.Position = Vector( -6549, -9363, 967 );
ENT.EnableReputation = true
ENT.Angles = Angle( 0, -180, 0 )
ENT.onlyCP = true
ENT.FloatingTitle = "The Jail Guard"

if ( SERVER ) then
	ENT.NPCTable = 
	{
		[ "perm_spy_kit" ] =
		{
			text = "Permanent Spy Kit",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "spy_kit", price, false, nil, function( success ) 
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Disguise Kit!" )
					end
				end  )
			end,
			price = 500000
		},
		[ "perm_357" ] = 
		{
			text = "Permanent .357",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "swb_357", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent .357!" )
					end
				end )
			end,
			price = 150000
		},
		[ "perm_glock18" ] = 
		{
			text = "Permanent Glock18",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "swb_glock18", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Glock18!" )
					end
				end )
			end,
			price = 200000
		},
		[ "perm_cpmask" ] = 
		{
			text = "Permanent CP Mask",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "cp_mask", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Civil Protection Mask!" )
					end
				end )
			end,
			repReq = 99,
			price = 2000000
		}
		
	};
	ENT.NPCQuestTable = 
	{
		["police_duty_quest"] =
		{
			["stage_not_started"] =
			{
				text = "Looking to do some good?",
				func = function( pl )
					if ( pl:AlreadyOnQuest( ) ) then
						DarkRP.notify( pl, 1, 4, "You're already on a quest." )
					else
						DarkRP.notify( pl, 1, 4, "You've begun the Police Duty Quest." )
						pl:BeginQuest( "police_duty_quest" )
						pl:ChatPrint( "Go patrol the streets and keep an eye out for any criminals. If you make an arrest, come back to me." )
					end
				end
			},
			["stage_in_progress"] =
			{
				text = "You're done already?",
				func = function( pl )
					DarkRP.notify( pl, 1, 4, "You didn't make an arrest. You can't fool me." )
				end
			},
			["stage_complete"] =
			{
				text = "Did you make an arrest?",
				func = function( pl )
					local isOnQuest, questStage = pl:IsOnQuest( "police_duty_quest" )
					if not ( isOnQuest ) then
						DarkRP.notify( pl, 1, 4, "You aren't on this quest." )
					else
						if not ( pl:IsQuestCompleted( ) ) then
							DarkRP.notify( pl, 1, 4, "You haven't finished this quest." )
						else
							pl:AddReputation( "npc_jailguard", 1 )
							DarkRP.notify( pl, 2, 4, "Great work, here's a small reward." )
							DarkRP.notify( pl, 2, 4, "You received $10000!" )
							DarkRP.notify( pl, 2, 4, "You've gained a reputation point with this NPC." )
							pl:addMoney( 10000 )
							pl:RemoveQuest( )
							pl:SetQuestCooldown( "police_duty_quest", 3600 )
						end
					end
				end
			}
		}
	}
end

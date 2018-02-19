ENT.Base 	= "npc_noob_base";

ENT.Model 	 = "models/humans/group03m/male_07.mdl";

ENT.Position = Vector( 10757, -12420, -989 )
ENT.Angles = Angle( 0, -180, 0 )

ENT.EnableReputation = true
ENT.isRobbable = true
ENT.robRewardRange = { 500, 1500 }
ENT.FloatingTitle = "Medic"

if ( SERVER ) then
	ENT.NPCTable = 
	{
		[ "buy_hp_100" ] =
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
		[ "buy_armor_100" ] = 
		{
			text = "100 Armor",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				if ( pl:canAfford( price ) ) then
					if ( pl:Armor( ) >= 100 ) then
						DarkRP.notify( pl, 1, 4, "You're already at full armor!" )
					else
						pl:addMoney( -price )
						pl:SetArmor( math.Clamp( pl:Armor( ) + 100, 0, 100 ) )
						DarkRP.notify( pl, 2, 4, "You've purchased 100 armor for $" .. tostring( price ) .. "!" )
					end
				else
					DarkRP.notify( pl, 1, 4, "You can't afford that." )
				end
			end,
			price = 350
		},
		[ "become_pacifist" ] =
		{
			text = "Become a Pacifist",
			func = function( pl )
				pl:AttemptPacifism( )
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
		[ "perm_dartgun" ] =
		{
			text = "Permanent Dart Gun",
			func = function( pl, ent, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "dart_gun", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Dart Gun!" )
					end
				end )
			end,
			repReq = 99,
			price = 2000000
		},
		[ "reset_perks" ] =
		{
			text = "Reset Perk Points",
			func = function( pl, ent, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				if ( pl:canAfford( price ) ) then
					pl:addMoney( -price )
					pl:PlayerResetPerks( )
					pl:ChatPrint( "You have reset your perks for $" .. tostring( price ) .. "!" )
				else
					pl:ChatPrint( "You can't afford to reset your perks." )
				end
			end,
			price = 500000
		},
		[ "surgical_mask" ] =
		{
			text = "Surgical Mask",
			func = function( pl, ent, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				if ( pl:HasWeaponStored( "surgical_mask") ) then
					pl:ChatPrint( "You already have the Surgical Mask." )
				else
					if ( pl:canAfford( price ) ) then
						pl:addMoney( -price )
						pl:ChatPrint( "You purchased a Surgical Mask for $" .. tostring( price ) .. "!" )
						pl:Give( "surgical_mask" )
					else
						pl:ChatPrint( "You cannot afford that." )
					end
				end
			end,
			price = 2500
		}
	}
	ENT.NPCQuestTable = 
	{
		["vial_retrieval_quest"] =
		{
			["stage_not_started"] =
			{
				text = "Can you help my find my lost vial?",
				func = function( pl )
					if ( pl:AlreadyOnQuest( ) ) then
						DarkRP.notify( pl, 1, 4, "You're already on a quest." )
					else
						DarkRP.notify( pl, 1, 4, "You've begun the Vial Retrieval Quest!" )
						pl:BeginQuest( "vial_retrieval_quest" )
						pl:ChatPrint( "I believe someone stole it from me when I wasn't paying attention. I wouldn't be surprised if it ended up in a slummy area." )
					end
				end
			},
			["stage_complete"] =
			{
				text = "Did you find the vial?",
				func = function( pl )
					local isOnQuest, questStage = pl:IsOnQuest( "vial_retrieval_quest" )
					if not ( isOnQuest ) then
						DarkRP.notify( pl, 1, 4, "You aren't on this quest." )
					else
						if not ( pl:IsQuestCompleted( ) ) then
							DarkRP.notify( pl, 1, 4, "You haven't finished this quest." )
						else
							DarkRP.notify( pl, 2, 4, "Well that's a shame, have $10,000 for the trouble!" )
							DarkRP.notify( pl, 2, 4, "You received $10000!" )
							pl:ChatPrint( "You've gained one reputation point with this npc." )
							pl:addMoney( 10000 )
							pl:AddReputation( "npc_medic", 1 )
							pl:RemoveQuest( )
							pl:SetQuestCooldown( "vial_retrieval_quest", 3600 )
						end
					end
				end
			}
		}
	}
end

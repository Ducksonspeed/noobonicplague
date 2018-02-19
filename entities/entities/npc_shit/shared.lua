ENT.Base 	= "npc_noob_base";

ENT.Model 	 = "models/Humans/Group01/Male_01.mdl";
ENT.Position = Vector( 0, 0, 0 );
ENT.EnableReputation = true

if ( SERVER ) then
	ENT.NPCTable = 
	{
		[ "hey_whats_up" ] =
		{
			text = "Hey what's up dude?",
			func = function( pl )
				DarkRP.notify( pl, 1, 4, "Nothing much how about you?" )
			end,
			repReq = 10
		},
		[ "buy_health_10" ] = 
		{
			text = "Buy Health +10 -> $100",
			func = function( pl )
				if ( pl:canAfford( 100 ) ) then
					if ( pl:Health() <= 190 ) then
						pl:SetHealth( pl:Health() + 10 );
						pl:addMoney( -100 );
						DarkRP.notify( pl, 2, 4, "You purchased +10 health." )
					else
						DarkRP.notify( pl, 1, 4, "Can't purchase more health." );
					end
				else
					DarkRP.notify( pl, 1, 4, "You can't afford that." );
				end
			end
		},

		[ "buy_armor_10" ] =
		{
			text = "Buy Armor +10 -> $100",
			func = function( pl )
				if ( pl:canAfford( 100 ) ) then
					if ( pl:Health() <= 190 ) then
						pl:SetHealth( pl:Health() + 10 );
						pl:addMoney( -100 );
						DarkRP.notify( pl, 2, 4, "You purchased +10 armor." )
					else
						DarkRP.notify( pl, 1, 4, "Can't purchase more health." );
					end
				else
					DarkRP.notify( pl, 1, 4, "You can't afford that." );
				end
			end
		},
		[ "buy_turtle_hat" ] =
		{
			text = "Temporary Turtle Hat -> $5000",
			func = function( pl )
				if ( pl:canAfford( 5000 ) ) then
					if not ( pl:HasWeaponStored( "turtle_hat" ) ) then
						pl:Give( "turtle_hat" )
						pl:addMoney( -5000 )
						DarkRP.notify( pl, 2, 4, "You bought a Temporary Turtle Hat!" )
					else
						DarkRP.notify( pl, 1, 4, "You already have a Turtle Hat." )
					end
				else
					DarkRP.notify( pl, 1, 4, "You cannot afford that." )
				end
			end
		},
		[ "buy_perm_santahat" ] =
		{
			text = "Perm Santa Hat -> 1 Obsidian, $500k",
			func = function( pl )
				local requiredGems = { }
				requiredGems["Obsidians"] = 1
				pl:PurchasePerm( "santa_hat", 500000, true, requiredGems, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Nick( ) .. " has purchased a permanent Santa Hat!" )
					end
				end )
			end
		}
		
	};
	ENT.NPCQuestTable = 
	{
		["turtle_retrieval_quest"] =
		{
			["stage_not_started"] =
			{
				text = "Can you help my find my turtle?",
				func = function( pl )
					if ( pl:AlreadyOnQuest( ) ) then
						DarkRP.notify( pl, 1, 4, "You're already on a quest." )
					else
						DarkRP.notify( pl, 1, 4, "You've begun the turtle retrieval quest." )
						pl:BeginQuest( "turtle_retrieval_quest" )
						//pl.currentQuest = { name = "turtle_retrieval_quest", stage = "stage_in_progress" }
						local questItem = ents.Create( "quest_item" )
						questItem.Model = "models/props/de_tides/vending_turtle.mdl"
						questItem:SetPos( Vector( 59, 699, -53 ) )
						questItem:Spawn( )
						questItem.QuestObjective = "turtle_retrieval_quest"
						questItem.QuestFunc = function( pl )
							pl:SetQuestComplete( )
							DarkRP.notify( pl, 2, 4, "You've found the lost turtle!" )
							SafeRemoveEntity( questItem )
						end
					end
				end
			},
			["stage_in_progress"] =
			{
				text = "Did you find my turtle yet?",
				func = function( pl )
					DarkRP.notify( pl, 1, 4, "Quit wasting my time, come back when you find it." )
				end
			},
			["stage_complete"] =
			{
				text = "Any news about my turtle?",
				func = function( pl )
					local isOnQuest, questStage = pl:IsOnQuest( "turtle_retrieval_quest" )
					if not ( isOnQuest ) then
						DarkRP.notify( pl, 1, 4, "You aren't on this quest." )
					else
						if not ( pl:IsQuestCompleted( ) ) then
							DarkRP.notify( pl, 1, 4, "You haven't finished this quest." )
						else
							DarkRP.notify( pl, 2, 4, "Thank you so much! Here's a small reward!" )
							DarkRP.notify( pl, 2, 4, "You received $5000!" )
							pl:addMoney( 5000 )
							pl:RemoveQuest( )
						end
					end
				end
			}
		},
		["shit_give_me_money"] =
		{
			["stage_not_started"] =
			{
				text = "Can I have some money?",
				func = function( pl )
					if ( pl:AlreadyOnQuest( ) ) then
						DarkRP.notify( pl, 1, 4, "You're already on a quest." )
					else
						DarkRP.notify( pl, 1, 4, "You've begun the Give Me Money quest." )
						pl:BeginQuest( "shit_give_me_money" )
					end
				end
			},
			["stage_in_progress"] =
			{
				text = "So are you gonna give me $10,000?",
				func = function( pl )
					if not ( pl:canAfford( 10000 ) ) then
						DarkRP.notify( pl, 1, 4, "You poor bastard, you cannot afford that." )
					else
						DarkRP.notify( pl, 2, 4, "Wooh thanks a lot, sucker!" )
						pl:addMoney( -10000 )
						pl:SetQuestComplete( )
					end
				end
			},
			["stage_complete"] =
			{
				text = "Were you expecting an award?",
				func = function( pl )
					local isOnQuest, questStage = pl:IsOnQuest( "shit_give_me_money" )
					if not ( isOnQuest ) then
						DarkRP.notify( pl, 1, 4,  "You aren't on this quest." )
					else
						pl:AddReputation( "npc_shit", 1 )
						DarkRP.notify( pl, 2, 4, "You're not getting shit in return!" )
						pl:RemoveQuest( )
						pl:SetQuestCooldown( "shit_give_me_money", 3600 )
					end
				end
			}
		}
	}
end

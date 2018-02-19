ENT.Base 	= "npc_noob_base";

ENT.Model 	 = "models/humans/group01/female_04.mdl";

ENT.Position = Vector( -6550.508, -4647.965, 235 )
ENT.Angles = Angle( 0, 0, 0 )
ENT.EnableReputation = true
ENT.isRobbable = true
ENT.robRewardRange = { 500, 1500 }
ENT.clothingMaterial = "models/humans/female/players_sheet_stripedredshirt"
ENT.FloatingTitle = "The Cook"

local randomOrcaSpawns = { Vector( 3216.709, -8292.274, 80.051 ), Vector( 2906.866, -7822.265, 71.903 ), Vector( 3197.838, -7508.203, 66.701 ) }
util.AddNetworkString( "N00BRP_PlayerColorSelector" )

if ( SERVER ) then
	ENT.NPCTable = 
	{
		[ "buy_food" ] =
		{
			text = "Chinese Food",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				if ( #team.GetPlayers( TEAM_COOK ) > 0 ) then
					DarkRP.notify( pl, 1, 4, "There are people who are currently Cooks." )
					return
				end
				if ( pl:canAfford( price ) ) then
					if not ( pl:HasSpaceInPocket( ) ) then
						DarkRP.notify( pl, 1, 4, "Your pocket is currently full." )
					else
						pl:addMoney( -price )
						DarkRP.notify( pl, 2, 4, "You purchased a Chinese Food for $" .. tostring( price ) .. "!" )
						local foodEnt = ents.Create( "food" )
						foodEnt:SetPos( pl:GetPos( ) )
						foodEnt:Spawn( )
						foodEnt:Activate( )
						pl:PocketEntity( foodEnt )
					end
				else
					DarkRP.notify( pl, 1, 4, "You can't afford that." )
				end
			end,
			price = 300
		},
		[ "ply_wep_colorchange"] =
		{
			text = "Change Player & Weapon Color",
			func = function( pl, npcEnt )
				net.Start( "N00BRP_PlayerColorSelector" )
					net.WriteTable( pl.savedPlayerColor )
					net.WriteTable( pl.savedWeaponColor )
				net.Send( pl )
			end
		},
		[ "buy_perm_lasersmg" ] =
		{
			text = "Permanent Laser SMG",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "lasersmg", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Nick( ) .. " has purchased a Permanent Laser SMG!" )
					end
				end )
			end,
			repReq = 99,
			price = 10000000
		},
		[ "rob_me" ] =
		{
			text = "I'm taking yo cash mang.",
			func = function( pl, ent )
				if ( ent.isRobbable and ent.RobNPC ) then
					ent:RobNPC( pl )
				end
			end
		}
	}

	ENT.NPCQuestTable = 
	{
		["orca_retrieval_quest"] =
		{
			["stage_not_started"] =
			{
				text = "HELP I CAN'T FIND MY ORCA!",
				func = function( pl )
					if ( pl:AlreadyOnQuest( ) ) then
						DarkRP.notify( pl, 1, 4, "You're already on a quest." )
					else
						DarkRP.notify( pl, 1, 4, "You've begun the Orca Retrieval Quest!" )
						pl:BeginQuest( "orca_retrieval_quest" )
						pl:ChatPrint( "I was enjoying a nice swim at the pool with my Orca but all of a sudden a bunch of men came in with guns and I had to get the fuck out of there. Can you go back there and get it for me?")
						local questItem = ents.Create( "quest_item" )
						questItem.Model = "models/env/misc/pool_whale/pool_whale.mdl"
						questItem:SetPos( randomOrcaSpawns[ math.random( #randomOrcaSpawns ) ] )
						questItem:SetUseType( SIMPLE_USE )
						questItem:Spawn( )
						questItem:SetRenderMode( RENDERMODE_TRANSCOLOR )
						questItem:SetColor( Color( 45, 175, 45 ) )
						questItem.questPlayer = pl
						timer.Simple( 300, function( ) 
							if ( IsValid( questItem ) ) then
								SafeRemoveEntity( questItem )
								if ( IsValid( pl ) ) then
									pl:RemoveQuest( )
									DarkRP.notify( pl, 1, 4, "You took too long and failed the quest." )
								end
							end
						end )
						questItem.QuestObjective = "orca_retrieval_quest"
						questItem.QuestFunc = function( pl )
							if not ( questItem.beingUsed ) then
								if not ( questItem.questPlayer == pl ) then
									pl:ChatPrint( "That doesn't look like the right Orca..." )
									return
								end
								SafeRemoveEntity( questItem )
								pl:SetQuestComplete( )
								DarkRP.notify( pl, 1, 4, "This looks like the right Orca..." )
								DarkRP.notify( pl, 1, 4, "All of a sudden you feel sick to your stomach, you should probably get back." )
								if not ( pl:IsPoisoned( ) ) then pl:Poison( ) end
							end
						end
					end
				end
			},
			["stage_in_progress"] =
			{
				text = "Did you find my beloved Orca?",
				func = function( pl )
					DarkRP.notify( pl, 1, 4, "Please don't give me false hope like that." )
				end
			},
			["stage_complete"] =
			{
				text = "Oh my gosh, you look terrible.",
				func = function( pl )
					local isOnQuest, questStage = pl:IsOnQuest( "orca_retrieval_quest" )
					if not ( isOnQuest ) then
						DarkRP.notify( pl, 1, 4, "You aren't on this quest." )
					else
						if not ( pl:IsQuestCompleted( ) ) then
							DarkRP.notify( pl, 1, 4, "You haven't finished this quest." )
						else
							DarkRP.notify( pl, 2, 4, "I'm so relieved my Orca is okay, here's some cash and I'll cure you as well." )
							DarkRP.notify( pl, 2, 4, "You received $15000!" )
							pl:CurePoison( )
							pl:ChatPrint( "You've gained one reputation point with this npc." )
							pl:addMoney( 10000 )
							pl:AddReputation( "npc_cook", 1 )
							pl:RemoveQuest( )
							pl:SetQuestCooldown( "orca_retrieval_quest", 3600 )
						end
					end
				end
			}
		},

	}
end

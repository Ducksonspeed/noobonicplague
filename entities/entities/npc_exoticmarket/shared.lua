ENT.Base 	= "npc_noob_base";
ENT.Model 	 = "models/vortigaunt.mdl";
ENT.Position = Vector( -7460, -9774, 236 );
ENT.EnableReputation = true
ENT.Angles = Angle( 0, 175, 0 )
ENT.SpeaksToCriminals = true
ENT.disallowCP = true
ENT.FloatingTitle = "Exotic Market"

if ( SERVER ) then
	ENT.NPCTable = 
	{
		[ "perm_giantbanana" ] = 
		{
			text = "Permanent Giant Banana",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "giant_banana", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Giant Banana! This shit is bananas!" )
					end
				end )
			end,
			price = 100000
		},
		[ "perm_mclaren" ] = 
		{
			text = "Permanent McLaren",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "mclaren_keys", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent McLaren MP4-12C!" )
					end
				end )
			end,
			price = 5000000
		},
		[ "perm_quadbike" ] = 
		{
			text = "Permanent Quadbike",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "quadbike_keys", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Quadbike!" )
					end
				end )
			end,
			price = 1500000
		},
		[ "perm_potionlauncher" ] = 
		{
			text = "Permanent Potion Launcher",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "potionlauncher", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Potion Launcher!" )
					end
				end )
			end,
			repReq = 99,
			price = 7500000
		}
		
	};
	ENT.NPCQuestTable = 
	{
		["terminal_hacking_quest"] =
		{
			["stage_not_started"] =
			{
				text = "Want to partake in some.. data mining?",
				func = function( pl )
					if ( pl:AlreadyOnQuest( ) ) then
						DarkRP.notify( pl, 1, 4, "You're already on a quest." )
					else
						local canContinue = true
						local questItems = ents.FindByClass( "quest_item" )
						if ( istable( questItems ) and #questItems > 0 ) then
							for index, item in ipairs ( questItems ) do
								if ( item.QuestObjective == "terminal_hacking_quest" ) then
									canContinue = false
									break
								end
							end
						end
						if not ( canContinue ) then
							pl:ChatPrint( "Somebody is currently doing this quest, come back later." )
							return
						end
						DarkRP.notify( pl, 1, 4, "You've begun the Terminal Hacking Quest!" )
						pl:BeginQuest( "terminal_hacking_quest" )
						pl:ChatPrint( "There's some rumors going around that the combine have stumbled upon exotic technology. I'm quite interested, but I am too feeble to seek it myself. There's a terminal in the Nexus Labs, I'd like you to hack it. You have five minutes." )
						local questItem = ents.Create( "quest_item" )
						questItem.Model = "models/props_lab/workspace004.mdl"
						questItem:SetPos( Vector( -6452, -8262, -2191 ) )
						questItem:SetAngles( Angle( 0, -100, 0 )	 )
						questItem:Spawn( )
						questItem.questPlayer = pl
						if ( questItem:GetPhysicsObject( ):IsValid( ) ) then
							questItem:GetPhysicsObject( ):EnableMotion( false )
						end
						timer.Simple( 300, function( ) 
							if ( IsValid( questItem ) ) then
								SafeRemoveEntity( questItem )
								if ( IsValid( pl ) ) then
									pl:RemoveQuest( )
									pl:ChatPrint( "You ran out of time, you've failed the quest.")
								end
							end
						end )
						questItem.QuestObjective = "terminal_hacking_quest"
						questItem.QuestFunc = function( pl )
							if not ( questItem.beingUsed ) then
								if not ( questItem.questPlayer == pl ) then
									pl:ChatPrint( "Somebody else is going to hack that terminal." )
									return
								end
								questItem.beingUsed = true
								local hackProgress = 0;
								pl:ChatPrint( "You've begun to hack the terminal. Hold down 'E' for about ten seconds." )
								timer.Create( pl:EntIndex( ) .. ":TerminalHacking", 1, 10, function( )
									if not ( IsValid( questItem ) ) then timer.Destroy( pl:EntIndex( ) .. ":TerminalHacking" ) return end
									hackProgress = hackProgress + 1;
									questItem:EmitSound( "npc/scanner/scanner_electric1.wav", 100, math.random( 80, 100 ) )
									if not ( pl:KeyDown( IN_USE ) ) then
										pl:ChatPrint( "You stopped hacking the terminal." )
										timer.Destroy( pl:EntIndex( ) .. ":TerminalHacking" )
										questItem.beingUsed = false
										return
									end
									if ( hackProgress == 9 ) then
										timer.Destroy( pl:EntIndex( ) .. ":TerminalHacking" )
										SafeRemoveEntity( questItem )
										pl:SetQuestComplete( )
										DarkRP.notify( pl, 2, 4, "You've finished hacking the terminal. Return to the Vortigaunt." )
									end
								end )
							end
						end
					end
				end
			},
			["stage_in_progress"] =
			{
				text = "You already hacked it?",
				func = function( pl )
					DarkRP.notify( pl, 1, 4, "You're wasting your time, and mine." )
				end
			},
			["stage_complete"] =
			{
				text = "Excellent. I was awaiting your return.",
				func = function( pl )
					local isOnQuest, questStage = pl:IsOnQuest( "terminal_hacking_quest" )
					if not ( isOnQuest ) then
						DarkRP.notify( pl, 1, 4, "You aren't on this quest." )
					else
						if not ( pl:IsQuestCompleted( ) ) then
							DarkRP.notify( pl, 1, 4, "You haven't finished this quest." )
						else
							DarkRP.notify( pl, 2, 4, "Take this cash as my appreciation, I hope to see you again." )
							DarkRP.notify( pl, 2, 4, "You received $15,000!" )
							pl:ChatPrint( "You've gained one reputation point with this npc." )
							pl:addMoney( 10000 )
							pl:AddReputation( "npc_exoticmarket", 1 )
							pl:RemoveQuest( )
							pl:SetQuestCooldown( "terminal_hacking_quest", 3600 )
						end
					end
				end
			}
		},

	}
end

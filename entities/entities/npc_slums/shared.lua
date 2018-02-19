ENT.Base 	= "npc_noob_base";

ENT.Model 	 = "models/Humans/Group01/Male_01.mdl";

ENT.Position = Vector( -928, -6433, 73 )
ENT.Angles = Angle( 0, 90, 0 )

ENT.EnableReputation = false
ENT.isRobbable = true
ENT.robRewardRange = { 500, 1500 }
ENT.disallowCitizens = true
ENT.FloatingTitle = "Slums Salesman"

if ( SERVER ) then
	ENT.NPCTable = 
	{
		[ "stick_up" ] =
		{
			text = "This is a stick up.",
			func = function( pl, ent )
				if ( ent.isRobbable and ent.RobNPC ) then
					ent:RobNPC( pl )
				end
			end
		},
		[ "herb_menu" ] =
		{
			text = "Sell Herbs & Mushrooms",
			func = function( pl )
				pl:ConCommand( "rp_herbsmenu" )
			end
		},
		[ "perm_knife" ] =
		{
			text = "Permanent Knife",
			func = function( pl, ent, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "swb_knife", price, false, nil, function( success ) 
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Combat Knife!" )
					end
				end )
			end,
			price = 300000
		},
		[ "perm_lockpick" ] =
		{
			text = "Permanent Lockpick",
			func = function( pl, ent, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "lockpick", price, false, nil, function( success ) 
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Lockpick!" )
					end
				end )
			end,
			price = 1300000
		},
		[ "perm_turtlehat" ] =
		{
			text = "Permanent Turtle Hat",
			func = function( pl, ent, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "turtle_hat", price, false, nil, function( success ) 
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent Turtle Hat!" )
					end
				end )
			end,
			price = 3000000
		},
		[ "perm_elcamino" ] =
		{
			text = "Permanent El Camino",
			func = function( pl, ent, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "elcamino_keys", price, false, nil, function( success ) 
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Name( ) .. " has purchased a Permanent El Camino!" )
					end
				end )
			end,
			price = 1800000
		},
		[ "buy_shovel" ] =
		{
			text = "Shovel",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				if ( pl:canAfford( price ) ) then
					if ( pl:HasWeaponStored( "shovel" ) ) then
						DarkRP.notify( pl, 1, 4, "You already have a Shovel." )
					else
						pl:addMoney( -price )
						pl:Give( "shovel" )
						DarkRP.notify( pl, 2, 4, "You purchased a Shovel for $" .. tostring( price ) .. "!" )
					end
				else
					DarkRP.notify( pl, 1, 4, "You can't afford that." )
				end
			end,
			price = 1500
		}
	}
	ENT.NPCQuestTable = 
	{
		["vial_retrieval_quest"] =
		{
			["stage_in_progress"] =
			{
				text = "A vial? What vial?",
				func = function( pl )
					local isOnQuest, questStage = pl:IsOnQuest( "vial_retrieval_quest" )
					if ( isOnQuest and questStage == "stage_in_progress" ) then
						local checkZombies = ents.FindByClass( "npc_fastzombie" )
						local canContinue = true
						if ( checkZombies and #checkZombies > 0 ) then
							for index, zombie in ipairs ( checkZombies ) do
								if ( zombie.QuestObjective and zombie.questObjective == "vial_retrieval_quest" ) then
									canContinue = false
									break
								end
							end
						end
						if not ( canContinue ) then
							pl:ChatPrint( "Why are you talking to me? THERE'S A FUCKING ZOMBIE OUT THERE!" )
							return
						else
							local spawnedZombies = ents.FindByClass( "npc_fastzombie" )
							local isSpawned = false
							if ( istable( spawnedZombies ) and #spawnedZombies > 0 ) then
								for index, zomb in ipairs ( spawnedZombies ) do
									if ( zomb.QuestObjective and zomb.QuestObjective == "vial_retrieval_quest" ) then
										isSpawned = true
										break
									end
								end
							end
							if ( isSpawned ) then
								pl:ChatPrint( "Whatever, but someone got it before you, maybe come back later." )
								return
							end
							pl:ChatPrint( "Fine, you win. Here you go... OH SHIT I DROPPED IT! WATCH OUT BEHIND YOU!" )
							local fastZombie = ents.Create( "npc_fastzombie" )
							fastZombie:SetPos( Vector( -942, -6102, 137 ) )
							fastZombie:SetAngles( Angle( 0, -90, 0 ) )
							fastZombie:Spawn( )
							fastZombie:Activate( )
							fastZombie:SetRenderMode( RENDERMODE_TRANSCOLOR )
							fastZombie:SetColor( Color( 45, 145, 45 ) )
							fastZombie:SetHealth(500)
							fastZombie.QuestObjective = "vial_retrieval_quest"
							fastZombie.QuestFunc = function( pl )
								pl:SetQuestComplete( )
								DarkRP.notify( pl, 2, 4, "The vial has been lost, but you have slain the zombie. Return to the medic." )
							end
							timer.Simple( 300, function( ) 
								if not ( IsValid( fastZombie ) ) then return end 
								SafeRemoveEntity( fastZombie )
							end )
						end
					end
				end
			}
		}
	}
end

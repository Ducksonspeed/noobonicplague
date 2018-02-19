ENT.Base 	= "npc_noob_base";

ENT.Model 	 = "models/monk.mdl";

ENT.Position = Vector( -7306, -6026, 136 )
ENT.EnableReputation = true
ENT.isRobbable = true
ENT.robRewardRange = { 500, 1500 }
ENT.FloatingTitle = "Gas Station Clerk"
local randomTankSpots = { Vector( 570.688, 12536.738, 170.298 ), Vector( -2098.524, 14540.572, 58 ), Vector( -1663.038, 12712.752, 58 ),
Vector( -5941.759, 13963.591, 186 ), Vector( -6231.301, 14693.761, 186 ), Vector( -6738.773, 11953.539, 186 ),
Vector( -4836.466, 14788.808, 197.177 ), Vector( -1654.592, 14758.088, 56.21 ), Vector( 1495, 13898, 122 ) }

if ( SERVER ) then
	ENT.NPCTable = 
	{
		[ "buy_deagle" ] =
		{
			text = "Deagle",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				if ( pl:canAfford( price ) ) then
					if ( pl:HasWeaponStored( "swb_deagle" ) ) then
						DarkRP.notify( pl, 1, 4, "You already have that weapon." )
					else
						pl:addMoney( -price )
						pl:Give( "swb_deagle" )
						DarkRP.notify( pl, 2, 4, "You purchased a Deagle for $" .. tostring( price ) .. "!" )
					end
				else
					DarkRP.notify( pl, 1, 4, "You can't afford that." )
				end
			end,
			price = 600
		},
		[ "buy_gas" ] = 
		{
			text = "Gas -> $1/second",
			func = function( pl )
				local mins = ClampWorldVector( Vector( -6586, -6671, 64 ) )
				local maxs = ClampWorldVector( Vector( -6396, -5904, 238 ) )
				local nearbyEnts = ents.FindInBox( mins, maxs )
				if ( nearbyEnts and istable( nearbyEnts ) ) then
					local foundCar = false
					for index, ent in ipairs ( nearbyEnts ) do
						if not ( ent:IsVehicle( ) ) then continue end
						if ( ent:getDoorOwner( ) == pl or ( ent:getKeysDoorGroup( ) == "Government Owned" and pl:isCP( ) ) or 
							( ent:getKeysDoorGroup( ) == "Medical Personnel" and pl:Team( ) == TEAM_PARAMEDIC ) or 
							( ent:getKeysDoorGroup( ) == "Public Transportation" and pl:Team( ) == TEAM_BUSDRIVER ) ) then
							foundCar = ent
							break
						end
					end
					if ( foundCar and noob_VehicleIndex:Get( foundCar:GetModel( ) ) ) then
						local maxGas = noob_VehicleIndex:Get( foundCar:GetModel( ) ).maxGas
						local currentGas = foundCar.gasRemaining
						if ( currentGas < maxGas ) then
							local gasNeeded = maxGas - currentGas
							if ( pl:canAfford( gasNeeded ) ) then
								pl:addMoney( -gasNeeded )
								local isDead = ( foundCar.gasRemaining == 0 )
								foundCar.gasRemaining = maxGas
								DarkRP.notify( pl, 2, 4, "You filled up your gas tank for $" .. gasNeeded .."." )
								foundCar:SendCurrentGas( pl, maxGas )
								if ( isDead ) then
									foundCar:Fire( "TurnOn", "", 0 )
									if ( IsValid( foundCar:GetDriver( ) ) ) then
										if not ( foundCar:IsGasDraining( ) ) then
											foundCar:InitiateGasDrain( )
										end
									end
								end
							else
								DarkRP.notify( pl, 1, 4, "It costs $" .. gasNeeded .. " to fill up your gas tank, you can't afford it." )
							end
						else
							pl:ChatPrint( "You already have a full tank of gas." )
						end
					else
						pl:ChatPrint( "Did you park your car by the gas pumps?" )
					end
				end
			end
		},
		[ "buy_perm_mustang" ] =
		{
			text = "Permanent Mustang",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "mustang_keys", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Nick( ) .. " has purchased a Permanent Ford Mustang!" )
					end
				end )
			end,
			price = 1500000
		},
		[ "buy_perm_crowbar" ] =
		{
			text = "Permanent Crowbar",
			func = function( pl, npcEnt, price )
				if ( price and pl:IsVIP( ) ) then price = price / 2 end
				pl:PurchasePerm( "weapon_crowbar", price, false, nil, function( success )
					if ( success ) then
						PrintMessage( HUD_PRINTTALK, pl:Nick( ) .. " has purchased a Permanent Crowbar!" )
					end
				end )
			end,
			repReq = 99,
			price = 5000000
		},
		[ "rob_me" ] =
		{
			text = "Hand over the money!",
			func = function( pl, ent )
				if ( ent.isRobbable and ent.RobNPC ) then
					ent:RobNPC( pl )
				end
			end
		}
	}

	ENT.NPCQuestTable = 
	{
		["gas_retrieval_quest"] =
		{
			["stage_not_started"] =
			{
				text = "You looking for work?",
				func = function( pl )
					if ( pl:AlreadyOnQuest( ) ) then
						DarkRP.notify( pl, 1, 4, "You're already on a quest." )
					else
						DarkRP.notify( pl, 1, 4, "You've begun the Gas Retrieval Quest!" )
						pl:BeginQuest( "gas_retrieval_quest" )
						pl:ChatPrint( "I need high octane gas! Find the gas depot near the suburbs, press 'e' on it to extract a can of gas, and bring it back here. Hurry! The gas depot will run out of gas in three minutes.")
						local questItem = ents.Create( "quest_item" )
						questItem:SetUseType( SIMPLE_USE );
						questItem.Model = "models/props/de_train/biohazardtank.mdl"
						questItem:SetPos( randomTankSpots[ math.random( #randomTankSpots ) ] )
						questItem:Spawn( )
						if ( questItem:GetPhysicsObject( ):IsValid( ) ) then
							questItem:GetPhysicsObject( ):EnableMotion( false )
						end
						questItem.questPlayer = pl
						timer.Simple( 180, function( ) 
							if ( IsValid( questItem ) ) then
								SafeRemoveEntity( questItem )
								if ( IsValid( pl ) ) then
									pl:RemoveQuest( )
								end
							end
						end )
						questItem.QuestObjective = "gas_retrieval_quest"
						questItem.QuestFunc = function( pl )
							if not ( questItem.beingUsed ) then
								if not ( questItem.questPlayer == pl ) then
									pl:ChatPrint( "That's not your Gas Tank, keep looking." )
									return
								end
								questItem.beingUsed = true
								local gasTick = 0;
								pl:ChatPrint( "You've begun gathering the gas, continue holding down 'e'." )
								timer.Create( pl:EntIndex( ) .. ":GasRetrieval", 1, 10, function( )
									if not ( IsValid( questItem ) ) then timer.Destroy( pl:EntIndex( ) .. ":GasRetrieval" ) return end
									gasTick = gasTick + 1;
									questItem:EmitSound( "ambient/water/distant_drip2.wav", 100, math.random( 80, 100 ) )
									if not ( pl:KeyDown( IN_USE ) ) then
										pl:ChatPrint( "You stopped gathering the gas." )
										timer.Destroy( pl:EntIndex( ) .. ":GasRetrieval" )
										questItem.beingUsed = false
										return
									end
									if ( gasTick == 9 ) then
										timer.Destroy( pl:EntIndex( ) .. ":GasRetrieval" )
										SafeRemoveEntity( questItem )
										pl:SetQuestComplete( )
										DarkRP.notify( pl, 2, 4, "You've finished gathering the gas. Return to BP." )
									end
								end )
							end
						end
					end
				end
			},
			["stage_in_progress"] =
			{
				text = "Did you gather the high octane gas yet?",
				func = function( pl )
					DarkRP.notify( pl, 1, 4, "No? Why are you even speaking to me then?" )
				end
			},
			["stage_complete"] =
			{
				text = "I'm assumine you have the gas?",
				func = function( pl )
					local isOnQuest, questStage = pl:IsOnQuest( "gas_retrieval_quest" )
					if not ( isOnQuest ) then
						DarkRP.notify( pl, 1, 4, "You aren't on this quest." )
					else
						if not ( pl:IsQuestCompleted( ) ) then
							DarkRP.notify( pl, 1, 4, "You haven't finished this quest." )
						else
							DarkRP.notify( pl, 2, 4, "Thank you so much! I'll remember this! Here's $10,000!" )
							DarkRP.notify( pl, 2, 4, "You received $10000!" )
							pl:ChatPrint( "You've gained one reputation point with this npc." )
							pl:addMoney( 10000 )
							pl:AddReputation( "npc_bp", 1 )
							pl:RemoveQuest( )
							pl:SetQuestCooldown( "gas_retrieval_quest", 3600 )
						end
					end
				end
			}
		},

	}
end

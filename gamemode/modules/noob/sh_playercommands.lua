
if ( SERVER ) then
	util.AddNetworkString( "N00BRP_PlayerReviveMenu" )
	local function IsRevivable( ply )
		return ( IsValid( ply.playerCorpse ) and ply.playerCorpse.wasRevived )
	end
	
	local function AcceptReviveCommand( ply )
		if not ( IsRevivable( ply ) ) then return end
		local spawnOverride = nil
		if ( IsValid( ply.playerCorpse ) ) then
			spawnOverride = ply.playerCorpse:GetPos( )
		end
		ply:RevivePlayer( false )
		ply.spawnPosOverride = spawnOverride
		timer.Simple( 0.1, function( )
			if ( !ply:Alive( ) ) then
				ply:Spawn( )
				ply.spawnPosOverride = nil
			end
		end )
	end
	concommand.Add( "rp_acceptrevive", AcceptReviveCommand )

	local function DenyReviveCommand( ply )
		if not ( IsRevivable( ply ) ) then return end
		ply.playerCorpse.wasRevived = nil
	end
	concommand.Add( "rp_denyrevive", DenyReviveCommand )

	local function RespawnReviveCommand( ply )
		if not ( IsRevivable( ply ) ) then return end
		ply:RevivePlayer( true )
		timer.Simple( 0.1, function( )
			if ( !ply:Alive( ) ) then
				ply:Spawn( )
			end
		end )
	end
	concommand.Add( "rp_respawnrevive", RespawnReviveCommand )

	util.AddNetworkString( "N00BRP_ColorSelector" )

	local function IsColorSupplied( args )
		return ( args[1] ~= nil and tonumber( args[1] ) and args[2] ~= nil and tonumber( args[2]) and args[3] ~= nil and tonumber( args[3] ) )
	end

	local function IsEntitySupplied( args )
		return ( args[4] ~= nil and tonumber( args[4] ) and IsValid( Entity( args[4]) ) )
	end

	local function PurchaseClothing( ply, cmd, args )
		if ( ply:GetPos( ):Distance( ents.FindByClass( "npc_clothingdealer" )[1]:GetPos( ) ) > 200 ) then return end
		if ( !NOOBRP.Config.MaleClothing[ args[1] ] and !NOOBRP.Config.FemaleClothing[ args[1] ] ) then
			ErrorNoHalt( ply:Nick( ) .. " has attempted to purchase invalid clothing." )
			return
		end
		if not ( ply:canAfford( 100 ) ) then
			ply:ErrorNotify( "You cannot afford $100 for those clothes!" )
			return
		else
			ply:addMoney( -100 )
			ply:SuccessNotify( "You have purchased those clothes for $100!" )
			ply:SaveClothing( args[1] )
		end
	end
	concommand.Add( "rp_purchaseclothing", PurchaseClothing )

	local function SetVehicleColorCommand( ply, cmd, args )
		if not ( IsColorSupplied( args ) ) then return end
		if not ( IsEntitySupplied( args ) ) then return end
		if ( ply:Team( ) ~= TEAM_CARDEALER and ply:Team( ) ~= TEAM_MECHANIC ) then return end
		local vehEnt = Entity( args[4] )
		if not ( vehEnt:IsVehicle( ) ) then return end
		ply.nextColorSelect = ply.nextColorSelect or 0
		if ( ply.nextColorSelect > CurTime( ) ) then
			local remainTime = string.NiceTime( ply.nextColorSelect - CurTime( ) )
			DarkRP.notify( ply, 1, 4, "You cannot set the color for another " .. remainTime .. "!" )
			return
		end
		if ( vehEnt:IsLocked( ) ) then
			DarkRP.notify( ply, 1, 4, "You cannot paint a locked vehicle." )
			return
		end
		ply.nextColorSelect = CurTime( ) + 10
		if not ( ply:GetPos( ):Distance( vehEnt:GetPos( ) ) < 100 ) then return end
		local paintColor = Color( tonumber( args[1] ), tonumber( args[2] ), tonumber( args[3] ), 255 )
		vehEnt:SetRenderMode( RENDERMODE_TRANSCOLOR )
		vehEnt:SetColor( paintColor )
		vehEnt.currentColor = paintColor
		DarkRP.notify( ply, 2, 4, "You changed the vehicle's color." )
	end
	concommand.Add( "rp_setvehiclecolor", SetVehicleColorCommand )

	local function NearNPC( ply, class )
		local entNPC = ents.FindByClass( class )
		if not ( entNPC or #entNPC <= 0 ) then return false end
		entNPC = entNPC[1]
		if not ( IsValid( entNPC ) ) then return false end
		if ( ply:GetPos( ):FastDist( entNPC:GetPos( ) ) > 400 ) then return false end
		return true
	end

	local function SetPlayerAndWeaponColor( ply, cmd, args, fstring )
		if not ( NearNPC( ply, "npc_cook" ) ) then return end
		if not ( IsColorSupplied( args ) ) then return end
		if not ( IsColorSupplied( { args[4], args[5], args[6] } ) ) then return end
		if not ( ply:canAfford( 1000000 ) ) then
			DarkRP.notify( ply, 1, 4, "You cannot afford $1,000,000." )
			return
		else
			ply:addMoney( -1000000 )
			DarkRP.notify( ply, 1, 4, "You paid $1,000,000 to change your Player and Weapon colors." )
			local plyRed = math.Clamp( tonumber( args[1] ), 0, 255 )
			local plyGreen = math.Clamp( tonumber( args[2] ), 0, 255 )
			local plyBlue = math.Clamp( tonumber( args[3] ), 0, 255 )
			local wepRed = math.Clamp( tonumber( args[4] ), 0, 255 )
			local wepGreen = math.Clamp( tonumber( args[5] ), 0, 255 )
			local wepBlue = math.Clamp( tonumber( args[6] ), 0, 255 )
			ply.savedPlayerColor = Color( plyRed, plyGreen, plyBlue )
			ply:SetPlayerColor( ply.savedPlayerColor:ToVector( ) )
			ply.savedWeaponColor = Color( wepRed, wepGreen, wepBlue )
			ply:SetWeaponColor( ply.savedWeaponColor:ToVector( ) )
			mySQLControl:Query( "UPDATE darkrp_playercolor SET r = " .. plyRed .. ", g = " .. plyGreen .. ", b = " .. plyBlue .. " WHERE uniqueid = " .. ply:SafeUniqueID( ) .. ";", function( ) end )
			mySQLControl:Query( "UPDATE darkrp_weaponcolor SET r = " .. wepRed .. ", g = " .. wepGreen .. ", b = " ..wepBlue .. " WHERE uniqueid = " .. ply:SafeUniqueID( ) .. ";", function( ) end )
		end
	end
	concommand.Add( "rp_setplayerandweaponcolor", SetPlayerAndWeaponColor )

	local function CombineGems( ply, cmd, args, fstring )
		if not ( NearNPC( ply, "npc_gemdealer" ) ) then return end
		//if ( ply:getDarkRPVar( "IsGhost" ) ) then return end
		if ( ply:IsGhost( ) ) then return end
		if ( ply:IsTrading() ) then return; end
		local rockAmt = tonumber( args[1] ) or 0
		local graniteAmt = tonumber( args[2] ) or 0
		local shaleAmt = tonumber( args[3] ) or 0
		local emeraldAmt = tonumber( args[4] ) or 0
		local rubyAmt = tonumber( args[5] ) or 0
		local sapphireAmt = tonumber( args[6] ) or 0
		local obsidianAmt = tonumber( args[7] ) or 0
		local diamondAmt = tonumber( args[8] ) or 0
		local comboString = rockAmt .. "-" .. graniteAmt .. "-" .. shaleAmt .. "-" .. emeraldAmt .. "-" .. rubyAmt .. "-" .. sapphireAmt .. "-" .. obsidianAmt .. "-" .. diamondAmt
		local gemTable = {
			["Rocks"] = rockAmt,
			["Granite"] = graniteAmt,
			["Shale"] = shaleAmt,
			["Emeralds"] = emeraldAmt,
			["Rubies"] = rubyAmt,
			["Sapphires"] = sapphireAmt,
			["Obsidians"] = obsidianAmt,
			["Diamonds"] = diamondAmt
		}
		local gemFunction = SVNOOB_VARS:Get( "GemCombos" )[comboString]
		if ( gemFunction and isfunction( gemFunction ) ) then
			gemFunction( ply, gemTable )
		end
	end
	concommand.Add( "rp_combinegems", CombineGems )

	local function SellGem( ply, cmd, args, fstring )
		if not ( NearNPC( ply, "npc_gemdealer" ) ) then return end
		if ( ply:IsTrading() ) then return; end
		if not ( tonumber( args[1] ) ) then return end
		if not ( tonumber( args[2] ) ) then return end
		local gemWorthTable = SHNOOB_VARS:Get( "GemWorth" ) or nil
		if not ( gemWorthTable ) then return end
		if not ( gemWorthTable[ tonumber( args[1] ) ] ) then return end
		if ( tonumber( args[2] ) <= 0 ) then return end
		local gemTranslationTable = {
			[1] = "Rocks",
			[2] = "Granite",
			[3] = "Shale",
			[4] = "Emeralds",
			[5] = "Rubies",
			[6] = "Sapphires",
			[7] = "Obsidians",
			[8] = "Diamonds"
		}
		local gemTable = {
			["Rocks"] = 0,
			["Granite"] = 0,
			["Shale"] = 0,
			["Emeralds"] = 0,
			["Rubies"] = 0,
			["Sapphires"] = 0,
			["Obsidians"] = 0,
			["Diamonds"] = 0
		}
		gemTable[ gemTranslationTable[ tonumber( args[1] ) ] ] = tonumber( args[2] )
		if ( ply:HasGems( gemTable ) ) then
			local cashReward = tonumber( gemWorthTable[ tonumber( args[1] ) ] ) * tonumber( args[2] )
			ply:ChatPrint( "You sold " .. tonumber( args[2] ) .. " " .. gemTranslationTable[ tonumber( args[1] ) ] .. " for $" .. cashReward .. "." )
			ply:addMoney( cashReward )
			ply:TakeGems( gemTable )
		else
			ply:ChatPrint( "You don't have that many " .. gemTranslationTable[ tonumber( args[1] ) ] .. "." )
		end
	end
	concommand.Add( "rp_sellgem", SellGem )

	local function SellHerb( ply, cmd, args, fstring )
		if not ( NearNPC( ply, "npc_slums" ) ) then return end
		if ( ply:IsTrading() ) then return; end
		if not ( tonumber( args[1] ) ) then return end
		if not ( tonumber( args[2] ) ) then return end
		local herbWorthTable = SHNOOB_VARS:Get( "HerbWorth" ) or nil
		if not ( herbWorthTable ) then return end
		if not ( herbWorthTable[ tonumber( args[1] ) ] ) then return end
		if ( tonumber( args[2] ) <= 0 ) then return end
		local herbTranslationTable = {
			[1] = "Burdock Root",
			[2] = "Gingko Biloba",
			[3] = "Valerian Root",
			[4] = "Coral Fungus",
			[5] = "Red Reishi",
			[6] = "Psilocybe Cubensis",
		}
		local herbTable = {
			["Burdock Root"] = 0,
			["Gingko Biloba"] = 0,
			["Valerian Root"] = 0,
			["Coral Fungus"] = 0,
			["Red Reishi"] = 0,
			["Psilocybe Cubensis"] = 0
		}
		herbTable[ herbTranslationTable[ tonumber( args[1] ) ] ] = tonumber( args[2] )
		if ( ply:HasHerbs( herbTable ) ) then
			local cashReward = tonumber( herbWorthTable[ tonumber( args[1] ) ] ) * tonumber( args[2] )
			ply:ChatPrint( "You sold " .. tonumber( args[2] ) .. " " .. herbTranslationTable[ tonumber( args[1] ) ] .. " for $" .. cashReward .. "." )
			ply:addMoney( cashReward )
			ply:TakeHerbs( herbTable )
		else
			ply:ChatPrint( "You don't have that many " .. herbTranslationTable[ tonumber( args[1] ) ] .. "." )
		end
	end
	concommand.Add( "rp_sellherb", SellHerb )

	local function MutePlayer( ply, args )
		local target = DarkRP.findPlayer( args )
		if not ( IsValid( target ) ) then
			DarkRP.notify( ply, 1, 4, "That player could not be found." )
		else
			ply.mutedPlayerList = ply.mutedPlayerList or { }
			if ( ply.mutedPlayerList[target:SteamID( )] ) then
				DarkRP.notify( ply, 1, 4, "That player is already muted." )
			else
				ply.mutedPlayerList[target:SteamID( )] = true
				DarkRP.notify( ply, 1, 4, "You have muted " .. target:Name( ) .. "." )
			end
		end
		return ""
	end
	DarkRP.defineChatCommand( "mute", MutePlayer )

	local function UnMutePlayer( ply, args )
		local target = DarkRP.findPlayer( args )
		if not ( IsValid( target ) ) then
			DarkRP.notify( ply, 1, 4, "That player could not be found." )
		else
			ply.mutedPlayerList = ply.mutedPlayerList or { }
			if not ( ply.mutedPlayerList[target:SteamID( )] ) then
				DarkRP.notify( ply, 1, 4, "That player is not muted." )
			else
				ply.mutedPlayerList[target:SteamID( )] = nil
				DarkRP.notify( ply, 1, 4, "You have unmuted " .. target:Name( ) .. "." )
			end
		end
		return ""
	end
	DarkRP.defineChatCommand( "unmute", UnMutePlayer )

	local function WantedTrace( ply, args )
		local ent = ply:GetEyeTrace( ).Entity
		if (ply:IsGhost( ) ) then 
			DarkRP.notify( ply, 1, 4, "Cannot want when dead!" )
			return "" 
		end
		if not ( IsValid ( ent ) ) then return "" end
		if not ( ent:IsPlayer( ) ) then return "" end
		if ( ent:isCP( ) ) then return "" end
		if ( ent:IsGhost( ) ) then return "" end
		if not ( ply:isCP( ) ) then return "" end
		if ( ent:isWanted( ) ) then
			DarkRP.notify( ply, 1, 4, "That player is already wanted!" )
			return ""
		end
		ent:SetWanted( 300, "is wanted by the Police!\nOrdered by: " .. ply:Nick( ) )
		return ""
	end
	DarkRP.defineChatCommand( "wantedtrace", WantedTrace )

	local function GetTowelHoldLength( ply, args )
		ply.towelHoldTime = tonumber( ply.towelHoldTime ) or 0
		local timeHeld = string.NiceTime( ply.towelHoldTime )
		ply:ChatPrint( "You been held the towel for a total of " .. timeHeld .. "!" )
		return ""
	end
	DarkRP.defineChatCommand( "towel", GetTowelHoldLength )

	local function SetVehicleColorChatCommand( ply, args )
		if ( ply:Team( ) ~= TEAM_CARDEALER and ply:Team( ) ~= TEAM_MECHANIC ) then return "" end
		local traceEnt = ply:GetEyeTrace( ).Entity
		ply.nextColorSelectChatCMD = ply.nextColorSelectChatCMD or 0
		if ( ply.nextColorSelectChatCMD > CurTime( ) ) then
			local remainTime = string.NiceTime( ply.nextColorSelectChatCMD - CurTime( ) )
			DarkRP.notify( ply, 1, 4, "You cannot set the color for another " .. remainTime .. "!" )
			return ""
		end
		if ( !IsValid( traceEnt ) or !traceEnt:IsVehicle( ) ) then return "" end
		if ( traceEnt:IsLocked( ) ) then
			DarkRP.notify( ply, 1, 4, "You cannot paint a locked vehicle." )
			return ""
		end
		ply.nextColorSelectChatCMD = CurTime( ) + 10
		if ( ply:GetPos( ):Distance( traceEnt:GetPos( ) ) > 100 ) then return "" end
		ply:SendColorSelector( "rp_setvehiclecolor", traceEnt )
	end
	DarkRP.defineChatCommand( "setcolor", SetVehicleColorChatCommand )

	local function TransferPlayerMoney( ply, args )
		if ( ply:IsTrading() ) then return ""; end

		local args = string.Split( args, " " )
		if ( !args[1] or !args[2] ) then DarkRP.notify( ply, 1, 4, "Invalid arguments specified. /transfer <name> <amount>" ) return "" end
		local findPlayer = DarkRP.findPlayer( args[1] )
		if not ( IsValid( findPlayer ) ) then DarkRP.notify( ply, 1, 4, "That player was not found." ) return "" end
		if ( ply == findPlayer ) then DarkRP.notify( ply, 1, 4, "You cannot transfer money to yourself." ) return "" end
		local moneyAmount = tonumber( args[2] ) or 0
		if ( moneyAmount <= 0 ) then DarkRP.notify( ply, 1, 4, "You must input a valid amount of money." ) return "" end
		if not ( ply:canAfford( moneyAmount ) ) then DarkRP.notify( ply, 1, 4, "You cannot afford that transfer!" ) return "" end
		ply:addMoney( -moneyAmount )
		DarkRP.notify( ply, 2, 4, "You transfered " .. findPlayer:Name( ) .. " $" .. moneyAmount .. "!" )
		findPlayer:addMoney( moneyAmount )
		DarkRP.notify( findPlayer, 2, 4, ply:Name( ) .. " has transfered you $" .. moneyAmount .. "!" )
		return ""
	end
	DarkRP.defineChatCommand( "transfer", TransferPlayerMoney )

	local function GivePlayerMoney( ply, args )
		if ( ply:IsTrading() ) then return ""; end

		if not ( args ) then DarkRP.notify( ply, 1, 4, "Invalid arguments specified. /give <amount>" ) return "" end
		local moneyAmount = tonumber( args ) or 0
		if ( moneyAmount <= 0 ) then DarkRP.notify( ply, 1, 4, "You must input a valid amount of money." ) return "" end
		local traceEnt = ply:RangeEyeTrace( 80, nil )
		if ( !IsValid( traceEnt ) or !traceEnt:IsPlayer( ) ) then DarkRP.notify( ply, 1, 4, "You must be looking at a player." ) return "" end
		if ( traceEnt:IsPlayer( ) and traceEnt:IsGhost( ) ) then DarkRP.notify( ply, 1, 4, "Cannot give money to Ghosts." ) return end
		if not ( ply:canAfford( moneyAmount ) ) then DarkRP.notify( ply, 1, 4, "You cannot afford that transfer!" ) return "" end
		ply:addMoney( -moneyAmount )
		DarkRP.notify( ply, 2, 4, "You gave " .. traceEnt:Name( ) .. " $" .. moneyAmount .. "!" )
		traceEnt:addMoney( moneyAmount )
		DarkRP.notify( traceEnt, 2, 4, ply:Name( ) .. " has given you $" .. moneyAmount .. "!" )
		return ""
	end
	DarkRP.defineChatCommand( "give", GivePlayerMoney )

	local function RollDice( ply, args )
		local firstRoll = math.random( 1, 6 )
		local secondRoll = math.random( 1, 6 )
		if ( ply:IsSuperAdmin( ) ) then secondRoll = math.random( 1, 7 ) end -- Heheheh
		local rollSum = firstRoll + secondRoll
		DarkRP.talkToRange( ply, "(DICE) " .. ply:Nick( ) .. " rolls the dice", rollSum, 500 )
		return ""
	end
	DarkRP.defineChatCommand( "dice", RollDice )
	
	local function ToggleThirdPerson( ply, args )
		local thirdPersonStatus = tonumber( ply:GetInfoNum( "noobrp_thirdperson", "1" ) ) or 1
		if ( thirdPersonStatus == 0 ) then
			ply:ConCommand( "noobrp_thirdperson 1" )
		else
			ply:ConCommand( "noobrp_thirdperson 0" )
		end
		return ""
	end
	DarkRP.defineChatCommand( "thirdperson", ToggleThirdPerson )
	DarkRP.defineChatCommand( "firstperson", ToggleThirdPerson )
	DarkRP.defineChatCommand( "toggleview", ToggleThirdPerson )

	local function PacifistBuyHealth( ply, args )
		if ( ply:IsTrading() ) then return; end
		if ( ply:IsGhost( ) ) then return end
		if ( ply:getDarkRPVar( "Energy" ) == 0 and ply:getDarkRPVar( "IsAFK" ) ) then
			if ( ply:Team() == TEAM_COOK ) then
				DarkRP.notify( ply, 1, 4, "Buy food instead, dumbass." );
			else
				DarkRP.notify( ply, 1, 4, "You can't do that if you're AFK." );
			end
			return;
		end
		local healthToBuy = ply:GetMaxHealth( ) - ply:Health( )
		local healthCost = healthToBuy * 25
		if not ( ply:canAfford( healthCost ) ) then DarkRP.notify( ply, 1, 4, "You cannot afford to buy health!" ) return "" end
		if not ( ply:getDarkRPVar( "IsPacifist" ) ) then return "" end
		if ( ply:Team( ) == TEAM_ZOMBIE ) then return "" end
		if ( ply:Health( ) >= ply:GetMaxHealth( ) ) then DarkRP.notify( ply, 1, 4, "You're already at max health!" ) return "" end
		ply.nextBuyHealth = ply.nextBuyHealth or 0
		if ( ply.nextBuyHealth > CurTime( ) ) then
			local timeLeft = string.NiceTime( ply.nextBuyHealth - CurTime( ) )
			DarkRP.notify( ply, 1, 4, "You cannot buy health for another " .. timeLeft .. "." )
			return
		end
		ply.nextBuyHealth = CurTime( ) + 10
		ply:SetHealth( ply:GetMaxHealth() )
		DarkRP.notify( ply, 2, 4, "You bought " .. healthToBuy .. " health for $" .. healthCost .. "!" )
		ply:addMoney( -healthCost )
		return ""
	end
	DarkRP.defineChatCommand( "buyhealth", PacifistBuyHealth )

	local function MayorPostLaw( ply, args )
		if not ( ply:Team( ) == TEAM_MAYOR ) then return "" end
		local lawTable = SHNOOB_VARS:Get( "MayorLaws" ) or { }
		if ( #lawTable >= 10 ) then DarkRP.notify( ply, 1, 4, "You cannot add anymore laws to the board." ) return "" end
		if not ( args ) then DarkRP.notify( ply, 1, 4, "You did not enter valid input." ) return "" end
		if ( string.len( args ) >= 34 ) then DarkRP.notify( ply, 1, 4, "The law can't be longer than 34 characters." ) return "" end
		ply.nextLawboardLawAdd = ply.nextLawboardLawAdd or 0
		if ( CurTime( ) > ply.nextLawboardLawAdd ) then
			table.insert( lawTable, args )
			SHNOOB_VARS:Set( "MayorLaws", lawTable )
			ply.nextLawboardLawAdd = CurTime( ) + 10
			DarkRP.notify( ply, 2, 4, "You successfully added a law to the lawboard." )
		else
			local timeRemaining = ply.nextLawboardLawAdd - CurTime( )
			DarkRP.notify( ply, 1, 4, "You must wait " .. string.NiceTime( timeRemaining ) .. " before adding another law." )
		end
		return ""
	end
	DarkRP.defineChatCommand( "postlaw", MayorPostLaw )

	local function MayorClearLaws( ply, args )
		if not ( ply:Team( ) == TEAM_MAYOR ) then return "" end
		ply.nextLawboardClearLaws = ply.nextLawboardClearLaws or 0
		if ( CurTime( ) > ply.nextLawboardClearLaws ) then
			SHNOOB_VARS:Set( "MayorLaws", { } )
			ply.nextLawboardClearLaws = CurTime( ) + 10
			DarkRP.notify( ply, 2, 4, "You successfully cleared the laws on the lawboard." )
		else
			local timeRemaining = ply.nextLawboardClearLaws - CurTime( )
			DarkRP.notify( ply, 1, 4, "You must wait " .. string.NiceTime( timeRemaining ) .. " before clearing the laws again." )
		end
		return ""
	end
	DarkRP.defineChatCommand( "clearlaws", MayorClearLaws )

	local function MayorSetSpeedLimit( ply, args )
		if ( !args or !tonumber( args ) ) then return "" end
		if not ( ply:Team( ) == TEAM_MAYOR ) then return "" end
		ply.nextSpeedLimitChange = ply.nextSpeedLimitChange or 0
		if ( ply.nextSpeedLimitChange > CurTime( ) ) then
			local timeLeft = string.NiceTime( ply.nextSpeedLimitChange - CurTime( ) )
			DarkRP.notify( ply, 1, 4, "You must wait another " .. timeLeft .. "." )
			return ""
		end
		local speedLimitConstraints = SVNOOB_VARS:Get( "SpeedLimitConstraints" ) or { min = 20, max = 100 }
		local desiredSpeedLimit = tonumber( args )
		if ( desiredSpeedLimit > speedLimitConstraints.max ) then
			DarkRP.notify( ply, 1, 4, "You cannot set the speed limit above " .. speedLimitConstraints.max .. "." )
		elseif ( desiredSpeedLimit < speedLimitConstraints.min ) then
			DarkRP.notify( ply, 1, 4, "You cannot set the speed limit below " .. speedLimitConstraints.min .. "." )
		else
			PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has set the speed limit to " .. desiredSpeedLimit .. "!" )
			SetGlobalInt( "N00BRP_SpeedLimit", desiredSpeedLimit )
			ply.nextSpeedLimitChange = CurTime( ) + 30
		end
		return ""
	end
	DarkRP.defineChatCommand( "speedlimit", MayorSetSpeedLimit )

	local function MayorFireCop( ply, args )
		if not ( args ) then return "" end
		local findPlayer = DarkRP.findPlayer( args )
		local canUse = false
		local cpLevel = NOOBRP_SkillAlgorithms:CalculatePolice( ply )["CurrentLevel"]
		local mayorAmount = team.GetPlayers( TEAM_MAYOR )
		if ( #mayorAmount < 1 and ply:Team( ) == TEAM_CHIEF and ( cpLevel >= 20 ) ) then
			canUse = true
		elseif ( #mayorAmount < 1 and ply:Team( ) == TEAM_CHIEF and ( cpLevel < 20 ) ) then
			DarkRP.notify( ply, 1, 4, "You need Civil Protection Level 20 to fire as the Chief." )
			return ""
		end
		if ( ply:Team( ) == TEAM_MAYOR ) then
			canUse = true
		end
		if not ( canUse ) then
			DarkRP.notify( ply, 1, 4, "You don't have the right job to fire Civil Protection!" )
			return ""
		end
		if not ( IsValid( findPlayer ) ) then
			DarkRP.notify( ply, 1, 4, "That player could not be found." )
			return ""
		end
		if not ( findPlayer:isCP( ) ) then
			DarkRP.notify( ply, 1, 4, "You can only fire Law Enforcement." )
			return ""
		end
		if ( findPlayer == ply ) then
			DarkRP.notify( ply, 1, 4, "You cannot fire yourself." )
			return ""
		end
		DarkRP.notifyAll( 1, 4, ply:Name( ) .. " has fired " .. findPlayer:Name( ) .. "!" )
		findPlayer:changeTeam( TEAM_CITIZEN, true )
		findPlayer:ChatPrint( "You've been fired by " .. ply:Name( ) .. "!" )
		local mes = ply:NiceInfo( ) .. " has fired " .. findPlayer:NiceInfo( )
		NOOB_LOGGER:Log( NOOB_LOGGING_WARNING, mes, false )
		return ""
	end
	DarkRP.defineChatCommand( "fire", MayorFireCop )

	local function TextToSpeech( ply, args )
		ply.LastTextToSpeech = ply.LastTextToSpeech or 0
		if ( ply.LastTextToSpeech + 2 > CurTime( ) ) then
			local timeLeft = string.NiceTime( ( ply.LastTextToSpeech + 2 ) - CurTime( ) )
			DarkRP.notify( ply, 1, 4, "You cannot use Text To Speech for another " .. timeLeft .. "!" )
			return ""
		end
		if ( !args or args == "" ) then
			DarkRP.notify( ply, 1, 4, "You need to enter text." )
			return ""
		end
		/*if not ( string.IsAlphabetical( args ) ) then
			DarkRP.notify( ply, 1, 4, "Your text cannot have symbols in it!" )
			return ""
		end*/
		ply:Say( "/me says " .. args .. "." )
		ply.LastTextToSpeech = CurTime( )
		net.Start( "N00BRP_TextToSpeech" )
			net.WriteEntity( ply )
			net.WriteString( string.Replace( args, " ", "+" ) )
		net.Broadcast( )
		return ""
	end
	DarkRP.defineChatCommand( "texttospeech", TextToSpeech )
	DarkRP.defineChatCommand( "tts", TextToSpeech )
	/*local function MayorPlaceBounty( ply, args )
		if not ( ply:Team( ) == TEAM_MAYOR ) then
			ply:ErrorNotify( "You must be the Mayor to place bounties!" )
			return
		end
		ply.nextMayorBountyTime = ply.nextMayorBountyTime or 0
		if ( ply.nextMayorBountyTime > CurTime( ) ) then
			local time = string.NiceTime( ply.nextMayorBountyTime - CurTime( ) )
			ply:ErrorNotify( "You cannot place another bounty for another " .. time .. "!" )
			return
		end
		local findPlayer = util.FindPlayer( args )
		if not ( IsValid( findPlayer ) ) then
			ply:ErrorNotify( "That player could not be found." )
			return
		end
		if not ( findPlayer:getDarkRPVar( "IsMurderer" ) ) then
			ply:ErrorNotify( "You can only place bounties on Murderers!" )
			return
		end
		if ( findPlayer:getDarkRPVar( "HasBounty" ) ) then
			ply:ErrorNotify( "That player already has a bounty on them!" )
			return
		end
		local bountyWorth = math.random( 2500, 15000 )
		DarkRP.notifyAll( NOTIFY_HINT, 4, "Mayor " .. ply:Name( ) .. " has placed a bounty on " .. findPlayer:Name( ) .. " worth $" .. string.Comma( bountyWorth ) .. "!" )
		NOOBRP = NOOBRP or { }
		NOOBRP.MayorBounties = NOOBRP.MayorBounties or { }
		NOOBRP.MayorBounties[findPlayer:SteamID( )] = bountyWorth
		findPlayer:setDarkRPVar( "HasBounty", true )
		ply.nextMayorBountyTime = CurTime( ) + SVNOOB_VARS:Get( "BountyCooldownTime", true, "number", 600 )
	end
	DarkRP.defineChatCommand( "placebounty", MayorPlaceBounty )*/

	local function ExecuteStuckCommand( ply, args )
		ply.unStuckInProgress = ply.unStuckInProgress or false
		if ( ply.unStuckInProgress ) then
			DarkRP.notify( ply, 1, 4, "You're already attempting to unstuck")
		end
		/*local traceRes = ply:TraceHull( Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), { ply }, false )
		if ( !traceRes.Hit and !IsValid( traceRes.Entity ) ) then
			DarkRP.notify( ply, 1, 4, "It doesn't appear you're stuck. Contact an admin for further assistance." )
			return ""
		elseif ( IsValid( traceRes.Entity ) ) then
			if ( traceRes.Entity:CPPIGetOwner( ) == ply ) then
				DarkRP.notify( ply, 1, 4, "It doesn't appear you're stuck. Contact an admin for further assistance." )
				return ""
			end
		end*/
		local bankButton = ents.FindByClass( "bank_button" )[1]
		if ( bankButton.GetRobber == ply ) then
			ply:ErrorNotify( "You cannot use /stuck while robbing the bank!" )
			return ""
		end
		local currentCrabQueen = SVNOOB_VARS:Get( "CrabQueen", true, "player", nil )
		if ( currentCrabQueen == ply ) then
			DarkRP.notify( ply, 1, 4, "You cannot use the stuck command as Crab Queen, contact an admin." )
			return ""
		end
		ply.unStuckInProgress = true
		local entIndex = ply:EntIndex( )
		local savedViewAngles = ply:EyeAngles( )
		local savedPos = ply:GetPos( )
		local intervalCount = 0
		ply:PrintMessage( HUD_PRINTCENTER, "REMAIN COMPLETELY STILL FOR 30 SECONDS" )
		timer.Create( ply:EntIndex( ) .. ":UnStuckProcess", 5, 6, function( )
			if not ( IsValid( ply ) ) then
				timer.Destroy( entIndex .. ":UnStuckProcess" )
				return ""
			end
			if ( ply:EyeAngles( ) ~= savedViewAngles or !ply:GetPos( ):IsEqualTol( savedPos, 80 ) ) then
				ply:PrintMessage( HUD_PRINTCENTER, "You've moved and the unstuck process was aborted." )
				ply.unStuckInProgress = false
				timer.Destroy( entIndex .. ":UnStuckProcess" )
				return ""
			end
			//if ( ply:getDarkRPVar( "IsGhost" ) ) then
			if ( ply:IsGhost( ) ) then
				ply.unStuckInProgress = false
				timer.Destroy( entIndex .. ":UnStuckProcess" )
				return ""
			end
			intervalCount = intervalCount + 1
			if ( intervalCount == 6 ) then
				ply.unStuckInProgress = false
				ply:KillSilent( )
			end
		end )
	end
	DarkRP.defineChatCommand( "stuck", ExecuteStuckCommand )

	local function CheckQuest( ply, args )
		if ( ply:AlreadyOnQuest( ) ) then
			local questName = ply.currentQuest.name
			ply:SuccessNotify( "You are currently doing the quest " .. questName .. "!" )
		else
			ply:ErrorNotify( "You are not on a quest." )
		end
	end
	DarkRP.defineChatCommand( "checkquest", CheckQuest )

	local function AbandonQuest( ply, args )
		if ( ply:AlreadyOnQuest( ) ) then
			local questName = ply.currentQuest.name
			ply:RemoveQuest( )
			ply:SuccessNotify( "You've abandoned your quest " .. questName .. "." )
			ply:SuccessNotify( "You can't do it for another hour." )
			ply:SetQuestCooldown( questName, 3600 )
		else
			ply:ErrorNotify( "You're not on a quest." )
		end
	end
	DarkRP.defineChatCommand( "abandonquest", AbandonQuest )

	local function OpenMOTD( ply, args )
		ply:ConCommand( "motd" )
	end
	DarkRP.defineChatCommand( "motd", OpenMOTD )

	local function AttemptPotionStore( ply, args )
		local traceEnt = ply:RangeEyeTrace( 120, { ply } ).Entity
		if ( IsValid( traceEnt ) and traceEnt:GetClass( ) == "ent_alchemypotion" ) then
			if not ( traceEnt:GetPotionName( ) ) then return end
			ply:StorePotionInVault( traceEnt:GetPotionName( ), 1 )
			DarkRP.notify( ply, 1, 4, "You've stored a " .. traceEnt:GetPotionName( ) .. " in your Potion Vault!" )
			SafeRemoveEntity( traceEnt )
		end
	end
	DarkRP.defineChatCommand( "storepotion", AttemptPotionStore )

	local function OpenPotionVault( ply, args )
		ply:ConCommand( "rp_potionvault" )
	end
	DarkRP.defineChatCommand( "viewpotionvault", OpenPotionVault )

	local function StopAllStreams( ply, args )
		ply:ConCommand( "rp_stopallstreams" )
		DarkRP.notify( ply, 1, 4, "Stopped all Radio Streams." )
	end
	DarkRP.defineChatCommand( "stopallstreams", StopAllStreams )

	local function HitmanAbortHit( ply, args )
		if ( ply:Team( ) == TEAM_HITMAN and ply:hasHit( ) ) then
			ply:finishHit( )
			ply.playerHitmanContract = nil
			DarkRP.notifyAll( 1, 4, ply:Name( ) .. " has aborted their contract!" )
		end
	end
	DarkRP.defineChatCommand( "aborthit", HitmanAbortHit )

	local function ForgivePlayer( ply, args )
		local findPlayer = DarkRP.findPlayer( args )
		if not ( IsValid( findPlayer ) ) then return "" end
		if ( findPlayer == ply ) then return "" end
		if not ( ply:HasRevenge( findPlayer ) ) then return "" end
		PrintMessage( HUD_PRINTCENTER, ply:Name( ) .. " has forgiven " .. findPlayer:Name( ) .. "!" )
		ply:RemoveRevenge( findPlayer )
		return ""
	end
	DarkRP.defineChatCommand( "forgive", ForgivePlayer )

	local function GetRevenges( ply, args )
		if not ( ply.revengeTable ) then return "" end
		if not ( istable( ply.revengeTable ) ) then return "" end
		ply:PrintMessage( HUD_PRINTCONSOLE, "-- Current Revenges --" )
		for index, plr in ipairs ( player.GetAll( ) ) do
			if ( ply.revengeTable[plr:SafeUniqueID( )] ) then
				ply:PrintMessage( HUD_PRINTCONSOLE, plr:Name( ) )
			end
		end
		return ""
	end
	DarkRP.defineChatCommand( "revenges", GetRevenges )

	local function AddWaypoint( ply, args )
		ply:ConCommand( 'rp_addminimapwaypoint "' .. args .. '"' )
		return ""
	end
	DarkRP.defineChatCommand( "addwaypoint", AddWaypoint )

	local function RemoveWaypoint( ply, args )
		ply:ConCommand( 'rp_removeminimapwaypoint "' .. args .. '"' )
		return ""
	end
	DarkRP.defineChatCommand( "removewaypoint", RemoveWaypoint )

	local function ListWaypoints( ply, args )
		ply:ConCommand( "rp_listwaypoints" )
		return ""
	end
	DarkRP.defineChatCommand( "listwaypoints", ListWaypoints )

	local function ToggleMinimap( ply, args )
		ply:ConCommand( "rp_toggleminimap" )
		return ""
	end
	DarkRP.defineChatCommand( "toggleminimap", ToggleMinimap )

	local function ViewRentedPermas( ply, args )
		ply.rentedPermsTable = ply.rentedPermsTable or { }
		if ( istable( ply.rentedPermsTable ) ) then
			local count = 0
			for class, time in pairs ( ply.rentedPermsTable ) do
				local wepName = noob_WeaponIndex:Get( class ).name
				ply:SendColoredMessage( { Color( 255, 255, 255 ), "[ ", Color( 145, 45, 45 ), wepName, Color( 255, 255, 255 ), "] ", Color( 45, 45, 175 ), "Time Remaining: ", Color( 255, 255, 255 ), string.NiceTime( time - os.time( ) ) } )
				count = count + 1
			end
			if ( count == 0 ) then
				ply:ErrorNotify( "You aren't renting any items at the moment." )
			end
		end
		return ""
	end
	DarkRP.defineChatCommand( "viewrentedpermas", ViewRentedPermas )

	local function ViewAchievements( ply, args )
		local findPlayer = DarkRP.findPlayer( args )
		if not ( IsValid( findPlayer ) ) then ply:ErrorNotify( "That player could not be found." ) return "" end
		if ( findPlayer == ply ) then ply:ErrorNotify( "You cannot target yourself." ) return "" end
		if not ( findPlayer.achievementsLoaded ) then ply:ErrorNotify( "That player's achievements haven't loaded yet." ) return "" end
		ply.nextAchievementsView = ply.nextAchievementsView or 0
		if ( ply.nextAchievementsView > CurTime( ) ) then
			local timeLeft = string.NiceTime( ply.nextAchievementsView - CurTime( ) )
			ply:ErrorNotify( "You cannot view another player's achievements for another " .. timeLeft .. "!" )
			return ""
		end
		ply.nextAchievementsView = CurTime( ) + 15
		ply:RetrieveAchievements( findPlayer )
		return ""
	end
	DarkRP.defineChatCommand( "viewachievements", ViewAchievements )

	local function ToggleMeterView( ply )
		ply:ConCommand( "rp_togglemeterview" )
		return ""
	end
	DarkRP.defineChatCommand( "togglemeterview", ToggleMeterView )

	local function DropBackpackPrinter( ply )
		if not ( ply:IsWearingBackItem( "backpack" ) ) then
			ply:ErrorNotify( "You aren't wearing a backpack." )
			return ""
		end
		if ( ply:HasPrintersInBackpack( ) ) then
			ply:RetrievePrinterFromBackpack( )
		else
			ply:ErrorNotify( "You don't have any printers in your backpack." )
		end
		return ""
	end
	DarkRP.defineChatCommand( "dropprinter", DropBackpackPrinter )

	local function CheckBackpackPrinterCount( ply )
		if not ( ply:IsWearingBackItem( "backpack" ) ) then
			ply:ErrorNotify( "You aren't wearing a backpack." )
			return ""
		end
		if ( ply:HasPrintersInBackpack( ) ) then
			ply:SuccessNotify( "You have " .. #ply.printerBackpack .. " printer(s) in your backpack." )
		else
			ply:ErrorNotify( "You don't have any printers in your backpack." )
		end
		return ""
	end
	DarkRP.defineChatCommand( "checkbackpack", CheckBackpackPrinterCount )
else
	CreateClientConVar( "noobrp_displaycprnotifies", "1", true, true )
	CreateClientConVar( "noobrp_enablelegacycpr", "0", true, true )
	CreateClientConVar( "noobrp_thirdperson", "1", true, true )
	CreateClientConVar( "noobrp_disableghosttoytown", "0", true, true )
	CreateClientConVar( "noobrp_disableradiostreams", "0", true, true )
	CreateClientConVar( "noobrp_enablecustomchatbox", "0", true, true )
	CreateClientConVar( "noobrp_enableminimap", "1", true, true )
	CreateClientConVar( "noobrp_disabletts", "1", true, true )
	local function AddMinimapWaypoint( ply, cmd, args, fstring )
		local waypointTable = SHNOOB_VARS:Get( "MinimapWaypoints", true ) or NOOBRP.Config.Waypoints
		if not ( waypointTable[ args[1] ] ) then return "" end
		LocalPlayer( ).currentWaypoints = LocalPlayer( ).currentWaypoints or { }
		LocalPlayer( ).currentWaypoints[ args[1] ] = waypointTable[ args[1] ]
		notification.AddLegacy( "Added a Waypoint to " .. args[1] .. "!", 1, 4 )
	end
	concommand.Add( "rp_addminimapwaypoint", AddMinimapWaypoint )

	local function RemoveMinimapWaypoint( ply, cmd, args, fstring )
		local waypointTable = SHNOOB_VARS:Get( "MinimapWaypoints", true ) or NOOBRP.Config.Waypoints
		if not ( waypointTable[ args[1] ] ) then return end
		LocalPlayer( ).currentWaypoints = LocalPlayer( ).currentWaypoints or { }
		LocalPlayer( ).currentWaypoints[ args[1] ] = nil
		notification.AddLegacy( "Removed a Waypoint to " .. args[1] .. "!", 1, 4 )
	end
	concommand.Add( "rp_removeminimapwaypoint", RemoveMinimapWaypoint )

	local function ListWaypoints( ply, cmd, args, fstring )
		local waypointTable = SHNOOB_VARS:Get( "MinimapWaypoints", true ) or NOOBRP.Config.Waypoints
		chat.AddText( Color( 175, 255, 175 ), "All Waypoints:" )
		local builtString = ""
		for index, vec in pairs ( waypointTable ) do
			builtString = builtString .. index .. ", "
		end
		chat.AddText( Color( 175, 175, 255 ), builtString )
	end
	concommand.Add( "rp_listwaypoints", ListWaypoints )

	local function ToggleMinimap( ply, cmd, args, fstring )
		if ( tobool( GetConVarNumber( "noobrp_enableminimap" ) ) ) then
			LocalPlayer( ):ConCommand( "noobrp_enableminimap 0" )
			notification.AddLegacy( "You have disabled the Minimap.", 1, 4 )
		else
			LocalPlayer( ):ConCommand( "noobrp_enableminimap 1" )
			notification.AddLegacy( "You have enabled the Minimap.", 1, 4 )
		end
	end
	concommand.Add( "rp_toggleminimap", ToggleMinimap )

	local function StopAllStreams( ply, cmd, args, fstring )
		ply.radioStations = ply.radioStations or { }
		if ( #ply.radioStations > 0 ) then
			for index, station in ipairs ( ply.radioStations ) do
				if ( IsValid( station ) ) then
					station:Stop( )
				end
				station = nil
				table.remove( ply.radioStations, index )
			end
		end
	end
	concommand.Add( "rp_stopallstreams", StopAllStreams )

	local function ToggleEventMeterView( ply, cmd, args, fstring )
		if not ( ply:IsWearingHat( "golden_beast_hat" ) ) then
			notification.AddLegacy( "You must be wearing the Golden Beast Hat to use this command!", NOTIFY_ERROR, 4 )
			return
		end
		ply.isViewingEventMeter = ply.isViewingEventMeter or false
		if not ( ply.isViewingEventMeter ) then
			notification.AddLegacy( "You are now viewing the Event Meter.", NOTIFY_HINT, 4 )
			ply.isViewingEventMeter = true
		else
			notification.AddLegacy( "You are no longer viewing the Event Meter.", NOTIFY_HINT, 4 )
			ply.isViewingEventMeter = false
		end
	end
	concommand.Add( "rp_togglemeterview", ToggleEventMeterView )
end
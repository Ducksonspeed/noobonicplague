SVNOOB_VARS = {}

// Types: Entity, Player, string, table, boolean, number
function SVNOOB_VARS:Get( index, raw, isType, defaultValue )
	if ( isType ) then
		local val = SVNOOB_VARS[index]
		if ( string.lower( type( val ) ) ~= string.lower( isType ) ) then
			if ( raw ) then
				return defaultValue
			else
				return defaultValue or "no_default"
			end
		end
	end
	if not ( raw ) then
		return SVNOOB_VARS[index] or "nil"
	end
	return SVNOOB_VARS[index]
end

function SVNOOB_VARS:Set( index, val )
	hook.Call( "N00BRP_ServerVariableChanged", { }, index, SVNOOB_VARS[index], val ) // function( varName, oldValue, newValue )
	SVNOOB_VARS[index] = val
end

SVNOOB_VARS:Set( "MeleeWeaponMultipliers", -- Multipliers for melee weapons
	{ 									   -- agaisnt players, props, and vehicles.
	  ["weapon_crowbar"] = { ply = 1, prop = 10, veh = 1 },
	  ["swb_knife"] = { ply = 1, prop = 2.857, veh = 1 }, 
	  ["swb_rare_knife"] = { ply = 1.1, prop = 3, veh = 1 },
	  ["stunstick"] = { ply = 0, prop = 0, veh = 0 }
	} 
)

SVNOOB_VARS:Set( "BeastLairObsidianReq", 5 )
SVNOOB_VARS:Set( "BackpackPrinterLimit", 2 )
SVNOOB_VARS:Set( "RiotShieldDeployTime", 1.5 ) -- Amount of time until Riot Shield deploys.
SVNOOB_VARS:Set( "TradingBans", { [ "STEAM_0:0:40393659" ] = true, [ "STEAM_0:0:89957777" ] = true } )
SVNOOB_VARS:Set( "DemotesTilVoteCount", 5 ) -- Amount of demotes needed to pass first stage.
SVNOOB_VARS:Set( "DemoteExpireTime", 30 ) -- Time until first stage of the demote expires.
SVNOOB_VARS:Set( "HerbSpawnInterval", 5 ) -- Interval between herbs and mushrooms spawning.
SVNOOB_VARS:Set( "PropCleanupTimer", 900 ) -- Interval between AFK player's props being cleaned up.
SVNOOB_VARS:Set( "MessageBroadcastInterval", 300 ) -- Interval between server's help messages.
SVNOOB_VARS:Set( "ElevatorFixInterval", 14400 ) -- Interval between the server fixing the elevator
SVNOOB_VARS:Set( "BountyCooldownTime", 600 ) -- Amounts of seconds inbetween Mayor bounties
SVNOOB_VARS:Set( "VehicleGasDrainRate", 4 ) -- Interval in seconds for gas drain
SVNOOB_VARS:Set( "JetpackStrength", 100 ) -- How much the Jetpack pushes you up.
SVNOOB_VARS:Set( "ClanWarLength", 3600 ) -- Length in seconds of a Clan War.
SVNOOB_VARS:Set( "ItemDropInterval", 300 ) -- Amount of seconds inbetween an attempted item drop.
SVNOOB_VARS:Set( "ItemDropChance", 1000 )
SVNOOB_VARS:Set( "ItemDropUncommons", { "uncommon_traffic_hat", "uncommon_turtle_hat", "uncommon_top_hat" } )
SVNOOB_VARS:Set( "ItemDropRares", { "rare_traffic_hat", "rare_turtle_hat", "rare_top_hat" } )
SVNOOB_VARS:Set( "SpawnedFoodLimit", 5 )
SVNOOB_VARS:Set( "ExplosiveProps", { ["models/props_c17/oildrum001_explosive.mdl" ] = true } )
SVNOOB_VARS:Set( "ExplosiveMagnitude", 125 )
-- Entites that won't vanish when the player disconnects.
SVNOOB_VARS:Set( "PersistentEntityWhitelist", { "adv_money_printer", "basic_money_printer", "money_printer" } )
SVNOOB_VARS:Set( "SpeedLimitConstraints", { min = 20, max = 100 } )
SVNOOB_VARS:Set( "AFKPointTriggerAmount", 4 )
SVNOOB_VARS:Set( "HungerDecreaseRate", 17 ) -- Interval of seconds between hunger drain.
SVNOOB_VARS:Set( "HamburgerHatUseCooldown", 420 ) -- Amount of time inbetween eating corpses.
SVNOOB_VARS:Set( "GreenPoisonDamage", { min = 5, max = 10 } )
SVNOOB_VARS:Set( "DefaultHostName", "NoobonicPlague.com | 24/7 RP, FastDL, Custom Mods" )
SVNOOB_VARS:Set( "RollerMinePrize", { min = 5000, max = 100000 } )
SVNOOB_VARS:Set( "MaxRollerMines", 5 )
SVNOOB_VARS:Set( "PrintingXPBoostActive", false )
SVNOOB_VARS:Set( "CriminalXPBoostActive", false )
SVNOOB_VARS:Set( "PoliceXPBoostActive", false )

SVNOOB_VARS:Set( "ZombieHungerDecreaseRate", 1 )
SVNOOB_VARS:Set( "ZombieTime", 300 ) -- time it takes to become a zombie
SVNOOB_VARS:Set( "ZombieStartingHealth", 500 )
SVNOOB_VARS:Set( "ZombieMaximumHealth", 3000 )
SVNOOB_VARS:Set( "ZombieEatCorpseHPGain", { min = 25, max = 50 } )
SVNOOB_VARS:Set( "DefaultInfectionRate", 30 ) -- Default hance of a zombie infecting another
SVNOOB_VARS:Set( "InfectionRate", 30 ) -- Changed throughout the gamemode.
SVNOOB_VARS:Set( "PlagueLabRate", 600 ) -- Time is takes to create a plague canister

SVNOOB_VARS:Set( "CrabQueen", nil ) -- The current crab queen, changed throughout the gamemode.
SVNOOB_VARS:Set( "MaxCrabSize", 0.5 )
SVNOOB_VARS:Set( "MaxCrabQueenSize", 1 )
SVNOOB_VARS:Set( "CrabBountyReward", 35000 )
SVNOOB_VARS:Set( "CrabSizeInc", 0.10 ) -- Size increment each growth.
SVNOOB_VARS:Set( "CrabGrowInt", 120 ) -- Amount of time inbetween growth spouts.
SVNOOB_VARS:Set( "CrabHealthIncrement", 25 ) -- Amount of health gained when growing as queen.
SVNOOB_VARS:Set( "CrabPersonLimit", 3 )
SVNOOB_VARS:Set( "CrabPersonLimitInc", 3 ) -- The limit increment when when growing as queen.
SVNOOB_VARS:Set( "MaxCrabPersonLimit", 15 )
SVNOOB_VARS:Set( "CrabHillPrintAmt", 250 )

-- Don't change these next four variables. 
SVNOOB_VARS:Set( "BaseViewOffset", Vector( 0, 0, 64 ) )
SVNOOB_VARS:Set( "BaseViewOffsetDucked", Vector( 0, 0, 28 ) )
SVNOOB_VARS:Set( "BaseOBBMaxs", Vector( 16, 16, 72 ) )
SVNOOB_VARS:Set( "BaseOBBMins", Vector( -16, -16, 0 ) )

SVNOOB_VARS:Set( "DisallowDemoteGraceTime", 300 ) -- Amount of time after becoming a job that demotes are denied. 
SVNOOB_VARS:Set( "MurdererPenaltyTime", 600 ) -- Spawn time, arrest time, and wait time as a murderer.
SVNOOB_VARS:Set( "KillGraceTime", 120 ) -- Amount of time it takes for the next kill not to count towards murderer.
SVNOOB_VARS:Set( "ViolentActionPenaltyTime", 300 ) -- Spawn time, and wait time for performing violent or criminal actions
SVNOOB_VARS:Set( "PacifismRequiredTime", 3600 ) -- Amount of time to aqcuire pacifist.

SVNOOB_VARS:Set( "FragilePacifismEnabled", false ) -- Enable if attacking anything should revoke pacifism.
SVNOOB_VARS:Set( "PacifistRespawnTime", 5 )
SVNOOB_VARS:Set( "DefaultRespawnTime", 60 )
SVNOOB_VARS:Set( "ReqChestCompressions", 10 )

SVNOOB_VARS:Set( "PlayerPushStrength", 500 )
SVNOOB_VARS:Set( "PlayerPushCooldown", 1 )

SVNOOB_VARS:Set( "CrabShriekCooldown", 60 )
SVNOOB_VARS:Set( "DefibrillatorCooldown", 60 ) -- 
SVNOOB_VARS:Set( "MaxMoneyPrinters", 1 ) -- Currently disabled.
SVNOOB_VARS:Set( "MaxBasicMoneyPrinters", 1 )
SVNOOB_VARS:Set( "MaxAdvMoneyPrinters", 1 )
SVNOOB_VARS:Set( "PrinterPrintSpeed", { min = 70, max = 280 } ) -- The speed at which cash is printed.
SVNOOB_VARS:Set( "PrinterPowerDrainRate", { min = 90, max = 180 } ) -- Power lost per interval, 
SVNOOB_VARS:Set( "PrinterPowerDrainAmt", { min = 3, max = 6 } ) -- stops printing when out of power.
SVNOOB_VARS:Set( "PrinterInkDrainAmt", { min = 6, max = 12 } )
SVNOOB_VARS:Set( "PrinterCoolantDrainAmt", { min = 1, max = 3 } ) -- Coolant drains at same rate as power, blows up below 60%.
SVNOOB_VARS:Set( "PrinterBaseCPUBonus", { min = 150, max = 375 } )
SVNOOB_VARS:Set( "PrinterMaxCores", 5 ) -- random( minBonus, maxBonus ) * coreAmount = Cash Bonus
SVNOOB_VARS:Set( "PrinterRAMBoostMulti", 7 ) -- boostMulti * ramUpgradeAmount = minimumSpeed & maximumSpeed
SVNOOB_VARS:Set( "PrinterLevelPrintBonus", 100 ) -- printerLevel * levelPrintBonus = Cash Bonus
SVNOOB_VARS:Set( "AdvPrinterOverheatPoint", 45 ) -- The point at which the printer will risk overheating.
SVNOOB_VARS:Set( "AdvPrinterOverheatChance", 10 ) -- if ( random( coolAmount/overHeatChance ) == 1 ) then ignite. 
SVNOOB_VARS:Set( "BasicPrinterXPReward", 1 ) -- XP per print, doubled for VIP.
SVNOOB_VARS:Set( "AdvPrinterXPReward", 2 )

SVNOOB_VARS:Set( "ArrestStickXPCooldown", 240 )
SVNOOB_VARS:Set( "DefaultArrestTimer", 300 )
SVNOOB_VARS:Set( "MurdererArrestTimer", 600 )

SVNOOB_VARS:Set( "MaxTrunkSlots", 15 )
SVNOOB_VARS:Set( "MaxBankSlots", 20 )

SVNOOB_VARS:Set( "DefaultMaxProps", 10 )
SVNOOB_VARS:Set( "VIPMaxProps", 15 )
SVNOOB_VARS:Set( "AdminMaxProps", 20 )
SVNOOB_VARS:Set( "SuperAdminMaxProps", 50 )
SVNOOB_VARS:Set( "ConstructionWorkerMaxProps", 25 )

SVNOOB_VARS:Set( "CriminalArrestDecrementAmt", 10 ) -- criminalLevel * decrementAmt = jailReductionTime
SVNOOB_VARS:Set( "ArrestBatonBaseRange", 105 ) -- baseRange + ( copLevel * levelMulti ) = arrestRange
SVNOOB_VARS:Set( "ArrestBatonLevelMulti", 2 )
SVNOOB_VARS:Set( "TaserBaseRange", 270 ) -- baseRawnge + ( copLevel * levelMulti ) = taseRange
SVNOOB_VARS:Set( "TaserLevelMulti", 4 )

SVNOOB_VARS:Set( "BeastThinkInterval", 15 ) // How often the beast attempts to attack.
SVNOOB_VARS:Set( "BeastHPMultiplier", 150 ) // Default HP is 1000
SVNOOB_VARS:Set( "BeastChildHPMultiplier", 32 ) // Default HP is 30
SVNOOB_VARS:Set( "BeastMeleeDamageMulti", 2.5 )
SVNOOB_VARS:Set( "TimeUntilBeastMound", 300 )
SVNOOB_VARS:Set( "BeastMoundLength", 1800 )

SVNOOB_VARS:Set( "DefaultWalkSpeed", 150 )
SVNOOB_VARS:Set( "DefaultRunSpeed", 255 )

SVNOOB_VARS:Set( "BankRobberyCooldown", 900 )
SVNOOB_VARS:Set( "BankRobberyMinuteLength", 5 )

SVNOOB_VARS:Set( "HerbGatherTime", { min = 5, max = 10 } )
SVNOOB_VARS:Set( "HerbalistTimeDecrement", 2 )
SVNOOB_VARS:Set( "HerbMinGatherTime", 1 )
SVNOOB_VARS:Set( "HerbDespawnTimer", { min = 180, max = 600 } )
SVNOOB_VARS:Set( "MushroomDespawnTimer", { min = 300, max = 600 } )
SVNOOB_VARS:Set( "MaxMushroomEntities", 7 )
SVNOOB_VARS:Set( "MaxHerbEntities", 15 )
SVNOOB_VARS:Set( "AlchemyPotionLimit", 5 )

SVNOOB_VARS:Set( "EventMeterTickRate", 90 )
SVNOOB_VARS:Set( "EventMeterMulti", .6 ) -- ( amountOfPlayers * meterMulti ) = incrementRate
SVNOOB_VARS:Set( "EventMeterSaveDataInterval", 300 ) -- Intervals in which the progress is saved to the database.

SVNOOB_VARS:Set( "MaxSoulOrbEntities", 20 )
SVNOOB_VARS:Set( "SoulOrbStrength", 300 )

SVNOOB_VARS:Set( "ValetSearchTime", 30 )
SVNOOB_VARS:Set( "MaxVehicles", 1 )
SVNOOB_VARS:Set( "VehicleExpireTime", 300 ) -- Time it takes for a unused/unowned vehicle to despawn.

SVNOOB_VARS:Set( "ThumperDrillLimit", 1 )
SVNOOB_VARS:Set( "MiningBoostActive", false ) -- If a mining event is active.
SVNOOB_VARS:Set( "MiningForemanLimit", 2 )
SVNOOB_VARS:Set( "GemDespawnTimer", 300 )
SVNOOB_VARS:Set( "DrillingIntervals", { min = 180, max = 400 } )
SVNOOB_VARS:Set( "DefaultMayorLaws", { 
		"All automatic weapons are illegal", 
		"Printing and salvaging are illegal.", 
		"Raiding drills is illegal.",
		"Destroying other's propery is illegal.",
		"All drugs are illegal, except alcohol.",
		"Being past the nexus desk is arrestable.",
		"Pushing cops will get you arrested.",
		"Interfering with arrests is illegal.",
		"Driving intoxicated will lead to jail time."
})

SVNOOB_VARS:Set( "NormalShovelRates", { -- Nothing, 22%
    { name = "Rock", chanceMin = 43, chanceMax = 78 }, -- 35%
    { name = "Granite", chanceMin = 20, chanceMax = 43 }, -- 23%
    { name = "Shale", chanceMin = 2.5, chanceMax = 20 }, -- 17%
    { name = "Emerald", chanceMin = .7, chanceMax = 2.5 }, -- 1.8%
    { name = "Ruby", chanceMin = .001, chanceMax = .7 },  -- .7%
    { name = "Sapphire", chanceMin = 0.000003, chanceMax = .001 }, -- A little less than .001%
    { name = "Obsidian", chanceMin = 0.000001, chanceMax = 0.000003 }, -- 1 in 500,000
    { name = "Diamond", chanceMin = 0, chanceMax = 0.000001 }  -- 1 in 1,000,000
} )

SVNOOB_VARS:Set( "MiningEventShovelRates", {
	{ name = "Rock", chanceMin = 50, chanceMax = 90 }, -- 40%
	{ name = "Granite", chanceMin = 20, chanceMax = 50 }, -- 30%
	{ name = "Shale", chanceMin = 7, chanceMax = 20 }, -- 12.3%
	{ name = "Emerald", chanceMin = .8, chanceMax = 7 }, -- 6.5%
	{ name = "Ruby", chanceMin = 0.01, chanceMax = .8 }, -- 1.1%
	{ name = "Sapphire", chanceMin = 0.000004, chanceMax = 0.01 }, -- % 0.01
	{ name = "Obsidian", chanceMin = 0.00000125, chanceMax = 0.000004 }, -- 1 in 250,000
	{ name = "Diamond", chanceMin = 0, chanceMax = 0.00000125 } -- 1 in 800,000
} )

SVNOOB_VARS:Set( "DecreasedMiningShovelRates", { // pls set these cobra or schmal
	{ name = "Shale", chanceMin = 66, chanceMax = 100 }, -- 34%
	{ name = "Emerald", chanceMin = 33, chanceMax = 66 }, -- 33%
	{ name = "Ruby", chanceMin = 5, chanceMax = 33 }, -- 28%
	{ name = "Sapphire", chanceMin = 0.42, chanceMax = 5 }, -- 4.58%
	{ name = "Obsidian", chanceMin = 0.03, chanceMax = 0.42 }, -- 0.39
	{ name = "Diamond", chanceMin = 0, chanceMax = 0.03 } -- .03%
} )

SVNOOB_VARS:Set( "NormalDrillRates", { 
	{ name = "Shale", chanceMin = 42, chanceMax = 100 }, -- 64%
	{ name = "Emerald", chanceMin = 17, chanceMax = 42 }, -- 25%
	{ name = "Ruby", chanceMin = 3, chanceMax = 17 }, -- 13.2%
	{ name = "Sapphire", chanceMin = .8, chanceMax = 3 }, -- 3%
	{ name = "Obsidian", chanceMin = 0.01, chanceMax = .8 }, -- .3%
	{ name = "Diamond", chanceMin = 0, chanceMax = 0.01 } -- 0.01%
} )

SVNOOB_VARS:Set( "MiningEventDrillRates", {
	{ name = "Shale", chanceMin = 66, chanceMax = 100 }, -- 34%
	{ name = "Emerald", chanceMin = 33, chanceMax = 66 }, -- 33%
	{ name = "Ruby", chanceMin = 5, chanceMax = 33 }, -- 28%
	{ name = "Sapphire", chanceMin = 1.2, chanceMax = 5 }, -- 4.58%
	{ name = "Obsidian", chanceMin = 0.03, chanceMax = 1.2 }, -- 0.39
	{ name = "Diamond", chanceMin = 0, chanceMax = 0.03 } -- .03%
} )

SVNOOB_VARS:Set( "MessageBroadcasts", {
	{ Color( 128, 128, 128 ), "Usage of any third party scripts such as macros and autoclickers may result in a permanent ban." },
	{ Color( 128, 128, 128 ), "You can usually find public microwaves near the bank." },
	{ Color( 128, 128, 128 ), "You can access your bank using E+R with your pocket out, or /viewbank." },
	{ Color( 128, 128, 128 ), "You can toggle between first and third person using /toggleview." },
	{ Color( 128, 128, 128 ), "If you need admin assistance, you may contact them like this. @ <message here>" },
	{ Color( 128, 128, 128 ), "Racism is not allowed and will result in punishment." },
	{ Color( 128, 128, 128 ), "Cars require gas, if your car will not move, it's probably out." },
	{ Color( 128, 128, 128 ), "You can find useful commands and information on the forums. http://www.noobonicplague.com" },
	{ Color( 128, 128, 128 ), "This server is unlike other DarkRP servers, be sure to read the MOTD. You can open it again with /motd." },
	{ Color( 128, 128, 128 ), "You can put printers in the trunk of your car with /trunk, the car must be unlocked." },
	{ Color( 128, 128, 128 ), "Mechanics can change the color of their car by looking at it and typing /setcolor." },
	{ Color( 128, 128, 128 ), "You can get unique items from maxing out your reputation with shopkeepers by doing their quests." },
	{ Color( 128, 128, 128 ), "While the bank is being robbed there will be absolute chaos within, stay out if you want to avoid getting killed." },
	{ Color( 128, 128, 128 ), "If you're in the road, other players may run you over." },
	{ Color( 128, 128, 128 ), "The Mayor can add laws to the Lawboard infront of the bank with /postlaw, and can clear them with /clearlaws." },
	{ Color( 128, 128, 128 ), "Mining Foremen must have their drills spawned or they can be demoted." },
	{ Color( 128, 128, 128 ), "Cooks must place at least one public microwave or they can face demotion." },
	{ Color( 128, 128, 128 ), "Being past the Nexus desk can lead to an arrest, same with going into the garage." },
	{ Color( 128, 128, 128 ), "Zombies are allowed to kill anybody, there are no restrictions other than spawn camping." },
	{ Color( 128, 128, 128 ), "Hacking and exploiting bugs will result in a permanent ban." },
	{ Color( 128, 128, 128 ), "There is no New Life Rule here, this is why there is a respawn timer." },
	{ Color( 128, 128, 128 ), "If you don't know your way around you can add waypoints to your minimap. The commands are, /listwaypoints, /addwaypoint, and /remove waypoint. You can also disable the minimap with /toggleminimap." }
} )

///////////////////////////////////////////////////////////////////////////////////////////////
///////////////// Gem Combos : Rocks-Granite-Shale-Emeralds-Rubies-Sapphires-Obsidians-Diamonds
///////////////// See first combo for information.
///////////////// Example:	
/////////////////	["0-0-0-0-0-0-0-0"] = function( ply, gemTable ) -- Index equals the gems required in order.
/////////////////		ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_knife" ) end,  -- Return true or false, depending if
/////////////////		function( ply )																			  -- player meets requirements.
/////////////////			ply:Give( "swb_rare_knife" ) -- The actual giving of the reward
/////////////////		end, "You crafted a temporary Rare Combat Knife." ) -- The message just the player sees.
/////////////////	end

SVNOOB_VARS:Set( "GemCombos",
	{
		///-----------------Shipments------------------\\\
		["45-23-8-4-2-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return ply:HasSpaceInPocket( ) end,
			function( ply )
				local spawnedShipment = SpawnShipmentEntity( "turtle_hat", ply:GetPos( ) )
				ply:PocketEntity( spawnedShipment )
			end, "You crafted a Turtle Hat shipment." )
		end,
		["33-40-6-7-3-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return ply:HasSpaceInPocket( ) end,
			function( ply )
				local spawnedShipment = SpawnShipmentEntity( "traffic_hat", ply:GetPos( ) )
				ply:PocketEntity( spawnedShipment )
			end, "You crafted a Traffic Hat shipment." )
		end,
		["65-35-4-2-1-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return ply:HasSpaceInPocket( ) end,
			function( ply )
				local spawnedShipment = SpawnShipmentEntity( "plant_hat", ply:GetPos( ) )
				ply:PocketEntity( spawnedShipment )
			end, "You crafted a Plant Hat shipment." )
		end,
		["42-41-7-4-3-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return ply:HasSpaceInPocket( ) end,
			function( ply )
				local spawnedShipment = SpawnShipmentEntity( "surgical_mask", ply:GetPos( ) )
				ply:PocketEntity( spawnedShipment )
			end, "You crafted a Surgical Mask shipment." )
		end,
		["37-14-16-2-3-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return ply:HasSpaceInPocket( ) end,
			function( ply )
				local spawnedShipment = SpawnShipmentEntity( "lockpick", ply:GetPos( ) )
				ply:PocketEntity( spawnedShipment )
			end, "You crafted a Lockpick shipment." )
		end,
		["58-8-24-1-2-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return ply:HasSpaceInPocket( ) end,
			function( ply )
				local spawnedShipment = SpawnShipmentEntity( "shovel", ply:GetPos( ) )
				ply:PocketEntity( spawnedShipment )
			end, "You crafted a Shovel shipment." )
		end,
		["21-13-24-2-2-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return ply:HasSpaceInPocket( ) end,
			function( ply )
				local spawnedShipment = SpawnShipmentEntity( "swb_deagle", ply:GetPos( ) )
				ply:PocketEntity( spawnedShipment )
			end, "You crafted a Deagle shipment." )
		end,
		["23-46-13-4-1-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return ply:HasSpaceInPocket( ) end,
			function( ply )
				local spawnedShipment = SpawnShipmentEntity( "swb_fiveseven", ply:GetPos( ) )
				ply:PocketEntity( spawnedShipment )
			end, "You crafted a Five-Seven shipment." )
		end,
		["16-24-13-2-1-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return ply:HasSpaceInPocket( ) end,
			function( ply )
				local spawnedShipment = SpawnShipmentEntity( "swb_glock18", ply:GetPos( ) )
				ply:PocketEntity( spawnedShipment )
			end, "You crafted a Glock-18 shipment." )
		end,
		["36-17-26-3-2-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return ply:HasSpaceInPocket( ) end,
			function( ply )
				local spawnedShipment = SpawnShipmentEntity( "swb_ak47", ply:GetPos( ) )
				ply:PocketEntity( spawnedShipment )
			end, "You crafted an AK47 shipment." )
		end,
		["27-12-32-2-1-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return ply:HasSpaceInPocket( ) end,
			function( ply )
				local spawnedShipment = SpawnShipmentEntity( "swb_mp5", ply:GetPos( ) )
				ply:PocketEntity( spawnedShipment )
			end, "You crafted a MP5 shipment." )
		end,
		["30-16-14-1-2-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return ply:HasSpaceInPocket( ) end,
			function( ply )
				local spawnedShipment = SpawnShipmentEntity( "swb_m4a1", ply:GetPos( ) )
				ply:PocketEntity( spawnedShipment )
			end, "You crafted a M4A1 shipment." )
		end,
		["16-28-13-3-1-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return ply:HasSpaceInPocket( ) end,
			function( ply )
				local spawnedShipment = SpawnShipmentEntity( "swb_mac10", ply:GetPos( ) )
				ply:PocketEntity( spawnedShipment )
			end, "You crafted a Mac-10 shipment." )
		end,
		["36-24-20-3-2-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return ply:HasSpaceInPocket( ) end,
			function( ply )
				local spawnedShipment = SpawnShipmentEntity( "swb_m3super90", ply:GetPos( ) )
				ply:PocketEntity( spawnedShipment )
			end, "You crafted a M3 Super 90 shipment." )
		end,
		["24-35-16-2-3-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return ply:HasSpaceInPocket( ) end,
			function( ply )
				local spawnedShipment = SpawnShipmentEntity( "swb_g3sg1", ply:GetPos( ) )
				ply:PocketEntity( spawnedShipment )
			end, "You crafted a G3SG1 shipment." )
		end,
		["52-36-28-6-4-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return ply:HasSpaceInPocket( ) end,
			function( ply )
				local spawnedShipment = SpawnShipmentEntity( "swb_awp", ply:GetPos( ) )
				ply:PocketEntity( spawnedShipment )
			end, "You crafted an AWP shipment." )
		end,
		["33-31-24-2-2-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return ply:HasSpaceInPocket( ) end,
			function( ply )
				local spawnedShipment = SpawnShipmentEntity( "swb_m249", ply:GetPos( ) )
				ply:PocketEntity( spawnedShipment )
			end, "You crafted a M249 shipment." )
		end,
		["20-14-16-2-2-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return ply:HasSpaceInPocket( ) end,
			function( ply )
				local spawnedShipment = SpawnShipmentEntity( "swb_knife", ply:GetPos( ) )
				ply:PocketEntity( spawnedShipment )
			end, "You crafted a Combat Knife shipment." )
		end,
		///-----------------Permanent Items------------------\\\
		["58-24-32-16-8-2-1-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "riot_shield" ) end,
			function( ply )
				ply:GivePermWeapon( "riot_shield" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Riot Shield!" )
			end, "You receive a Permanent Riot Shield." )
		end,
		["32-48-16-7-12-3-2-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "surgical_mask" ) end,
			function( ply )
				ply:GivePermWeapon( "surgical_mask" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Surgical Mask!" )
			end, "You receive a Permanent Surgical Mask." )
		end,
		["43-31-25-9-7-4-2-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_sg552" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_sg552" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent SG552!" )
			end, "You receive a Permanent SG552" )
		end,
		["71-22-36-13-5-3-2-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_sg550" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_sg550" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent SG550!" )
			end, "You receive a Permanent SG550" )
		end,
		["32-41-23-17-16-4-1-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "blue_cape" ) end,
			function( ply )
				ply:GivePermWeapon( "blue_cape" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Blue Cape!" )
			end, "You receive a Permanent Blue Cape" )
		end,
		["123-4-5-6-7-8-0-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "turtle_hat" ) end,
			function( ply )
				ply:GivePermWeapon( "turtle_hat" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into Permanent Turtle Hat!" )
			end, "You receive a Permanent Turtle Hat" )
		end,
		["65-70-6-5-7-0-0-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "traffic_hat" ) end,
			function( ply )
				ply:GivePermWeapon( "traffic_hat" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into Traffic Hat!" )
			end, "You receive a Permanent Traffic Hat" )
		end,
		["420-4-2-0-4-2-0-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "plant_hat" ) end,
			function( ply )
				ply:GivePermWeapon( "plant_hat" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into Permanent Plant Hat!" )
			end, "You receive a Permanent Plant Hat" )
		end,
		["75-47-23-12-6-4-1-2"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "dreadwings" ) end,
			function( ply )
				ply:GivePermWeapon( "dreadwings" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into Permanent Dread Wings!" )
			end, "You receive Permanent Dread Wings" )
		end,
		/*["63-21-47-24-13-12-7-5"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "jetpack" ) end,
			function( ply )
				ply:GivePermWeapon( "jetpack" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Jetpack!" )
			end, "You receive a Permanent Jetpack!" )
		end,*/
		["27-15-32-7-12-18-2-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "split_cape" ) end,
			function( ply )
				ply:GivePermWeapon( "split_cape" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Split Cape!" )
			end, "You receive a Permanent Split Cape!" )
		end,
		-- beginning of new/old stuff
		["0-0-0-0-0-0-2-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "shrink_ray" ) end,
			function( ply )
				ply:GivePermWeapon( "shrink_ray" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Shrink Ray!" )
			end, "You receive a Permanent Shrink Ray!" )
		end,
		["21-13-8-5-3-2-1-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "riot_shield" ) end,
			function( ply )
				ply:GivePermWeapon( "riot_shield" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Riot Shield!" )
			end, "You receive a Permanent Riot Shield!" )
		end,
		["0-0-0-0-0-0-1-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "grappling_hook" ) end,
			function( ply )
				ply:GivePermWeapon( "grappling_hook" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Grappling Hook!" )
			end, "You receive a Permanent Grappling Hook!" )
		end,
		["65-70-6-5-7-0-0-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "traffic_hat" ) end,
			function( ply )
				ply:GivePermWeapon( "traffic_hat" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Traffic Hat!" )
			end, "You receive a Permanent Traffic Hat!" )
		end,
		["123-4-5-6-7-8-0-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "turtle_hat" ) end,
			function( ply )
				ply:GivePermWeapon( "turtle_hat" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Turtle Hat!" )
			end, "You receive a Permanent Turtle Hat!" )
		end,
		["44-4-3-2-2-5-2-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "shovel" ) end,
			function( ply )
				ply:GivePermWeapon( "shovel" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Shovel!" )
			end, "You receive a Permanent Shovel!" )
		end,
		["16-5-3-2-1-4-2-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "defibrillator" ) end,
			function( ply )
				ply:GivePermWeapon( "defibrillator" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a PERMANENT FUCKING DEFIBRILLATOR!" )
			end, "You receive a PERMANENT FUCKING DEFIBRILLATOR!" )
		end,
		["22-4-3-2-0-4-2-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "lockpick" ) end,
			function( ply )
				ply:GivePermWeapon( "lockpick" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Lockpick!" )
			end, "You receive a Permanent Lockpick!" )
		end,
		["40-4-2-2-7-3-2-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_awp" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_awp" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent AWP!" )
			end, "You receive a Permanent AWP!" )
		end,
		["40-3-2-2-4-3-2-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_g3sg1" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_g3sg1" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent G3SG1!" )
			end, "You receive a Permanent G3SG1!" )
		end,
		["28-3-2-2-3-3-2-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_aug" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_aug" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Aug A1!" )
			end, "You receive a Permanent Aug A1!" )
		end,
		["7-3-2-2-2-2-2-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_scout" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_scout" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Scout!" )
			end, "You receive a Permanent Scout!" )
		end,
		["30-4-2-2-5-3-1-1"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_m249" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_m249" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent M249 SAW!" )
			end, "You receive a Permanent M249 SAW!" )
		end,
		["35-2-2-2-5-4-2-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_famas" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_famas" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Famas!" )
			end, "You receive a Permanent Famas!" )
		end,
		["26-2-2-2-5-4-2-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_galil" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_galil" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Galil!" )
			end, "You receive a Permanent Galil!" )
		end,
		["18-2-2-2-4-4-2-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_ak47" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_ak47" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent AK47!" )
			end, "You receive a Permanent AK47!" )
		end,
		["11-2-2-2-3-4-2-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_m4a1" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_m4a1" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent M4A1!" )
			end, "You receive a Permanent M4A1!" )
		end,
		["32-3-1-2-3-4-2-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_p90" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_p90" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent P90!" )
			end, "You receive a Permanent P90!" )
		end,
		["30-3-1-2-3-3-2-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_mp5" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_mp5" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent MP5!" )
			end, "You receive a Permanent MP5!" )
		end,
		["26-3-1-2-2-3-2-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_ump" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_ump" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent UMP!" )
			end, "You receive a Permanent UMP!" )
		end,
		["21-3-1-2-2-2-2-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_mac10" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_mac10" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Mac-10!" )
			end, "You receive a Permanent Mac-10!" )
		end,
		["36-2-1-2-1-2-2-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_tmp" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_tmp" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent TMP!" )
			end, "You receive a Permanent TMP!" )
		end,
		["55-2-1-2-4-3-1-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_knife" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_knife" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Knife!" )
			end, "You receive a Permanent Knife!" )
		end,
		["22-2-1-2-4-3-1-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_deagle" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_deagle" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Desert Eagle!" )
			end, "You receive a Permanent Desert Eagle!" )
		end,
		["15-2-1-2-3-2-1-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_usp" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_usp" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent USP!" )
			end, "You receive a Permanent USP!" )
		end,
		["10-2-1-2-2-2-1-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_glock18" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_glock18" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Glock!" )
			end, "You receive a Permanent Glock!" )
		end,
		["57-1-1-2-2-2-1-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_fiveseven" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_fiveseven" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent Five-Seven!" )
			end, "You receive a Permanent Five-Seven!" )
		end,
		["5-1-1-2-1-1-1-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return !ply:HasWeaponStored( "swb_p228" ) end,
			function( ply )
				ply:GivePermWeapon( "swb_p228" )
				PrintMessage( HUD_PRINTTALK, ply:Name( ) .. " has combined gems into a Permanent P228!" )
			end, "You receive a Permanent P228!" )
		end,
		["9-0-0-1-0-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return true end,
			function( ply )
				ply:Kill()
			end, "IT'S OVER 9000!!!!! DIE LIKE YOU MEAN IT!!!")
		end,
		["1-3-3-7-0-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return true end,
			function( ply )
			end, "You Are Cool. Thanks for the gems, faggot.")
		end,
		["52-5-3-2-0-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return true end,
			function( ply )
				ply:SetPos(Vector(-6034, -6566, 2910))
			end, "The Wright Brothers would be proud!!!")
		end,
		["50-5-3-2-0-0-0-0"] = function( ply, gemTable )
			ply:CraftGems( gemTable, function( ply ) return true end,
			function( ply )
				ply:Ignite(60)
			end, "Congratulations-you've discovered fire! OH GOD FIRE!!!")
		end
	}
)

hook.Call( "N00BRP_ServerVariablesLoaded", { } )













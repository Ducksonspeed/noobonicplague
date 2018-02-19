NOOBRP = NOOBRP or { }
NOOBRP.Achievements = NOOBRP.Achievements or { }

ENUM_ACHIEVEMENTS_BEGINTRANSFER = 1
ENUM_ACHIEVEMENTS_TRANSFERACHIEVE = 2
ENUM_ACHIEVEMENTS_ENDTRANSFER = 3

ENUM_ACHIEVEMENTS_CATEGORY_SKILL = 4
ENUM_ACHIEVEMENTS_CATEGORY_MURDER = 5
ENUM_ACHIEVEMENTS_CATEGORY_CRIMEANDLAW = 6
ENUM_ACHIEVEMENTS_CATEGORY_EVENT = 7
ENUM_ACHIEVEMENTS_CATEGORY_JOBRELATED = 8
ENUM_ACHIEVEMENTS_CATEGORY_GATHERINGANDMINING = 9
ENUM_ACHIEVEMENTS_CATEGORY_MISC = 10

/*----------- Skill Achievements --------------*/

NOOBRP.Achievements["Level 10 Endurance"] = {
	name = "Fresh Blood",
	desc = "Play long enough to get to Level 10 Endurance.",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_SKILL,
	achieveFunc = function( ply )
		if ( ply:GetCurrentLevel( NOOB_SKILL_ENDURANCE ) >= 10 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000!" )
	end,
	rewardText = "$25,000"
}

NOOBRP.Achievements["Level 35 Endurance"] = {
	name = "Feeling Old",
	desc = "Play long enough to get to Level 35 Endurance.",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_SKILL,
	achieveFunc = function( ply )
		if ( ply:GetCurrentLevel( NOOB_SKILL_ENDURANCE ) >= 35 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 50000 )
		ply:SuccessNotify( "You were rewarded $50,000!" )
	end,
	rewardText = "$50,000"
}

NOOBRP.Achievements["Level 25 Mining"] = {
	name = "Steady Mining",
	desc = "Bash your Shovel at the wall until you reach Level 25 Mining.",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_SKILL,
	achieveFunc = function( ply )
		if ( ply:GetCurrentLevel( NOOB_SKILL_MINING ) >= 25 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000 and 5 Sapphires!" )
		ply:GiveGem( "Sapphires", 5 )
	end,
	rewardText = "$25,000 and 5 Sapphires",
	globalAnnounce = true
}

NOOBRP.Achievements["Level 75 Mining"] = {
	name = "Relentless Foreman",
	desc = "Bash your Shovel at the wall until you reach Level 75 Mining.",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_SKILL,
	achieveFunc = function( ply )
		if ( ply:GetCurrentLevel( NOOB_SKILL_MINING ) >= 75 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:GiveGem( "Obsidians", 1 )
		ply:SuccessNotify( "You were rewarded an Obsidian!" )
	end,
	rewardText = "1 Obsidian",
	globalAnnounce = true
}

NOOBRP.Achievements["Level 25 Police"] = {
	name = "Respect the Badge",
	desc = "Arrest all criminal scum until you reach Civil Protection Level 25!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_SKILL,
	achieveFunc = function( ply )
		if ( ply:GetCurrentLevel( NOOB_SKILL_COP ) >= 25 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000!" )
	end,
	rewardText = "$25,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Level 75 Police"] = {
	name = "Not On My Streets",
	desc = "Arrest all criminal scum until you reach Civil Protection Level 75!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_SKILL,
	achieveFunc = function( ply )
		if ( ply:GetCurrentLevel( NOOB_SKILL_COP ) >= 75 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 50000 )
		ply:SuccessNotify( "You were rewarded $50,000!" )
	end,
	rewardText = "$50,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Level 25 Criminal"] = {
	name = "Small Time Crook",
	desc = "Commit crimes until you reach Criminal Expertise Level 25!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_SKILL,
	achieveFunc = function( ply )
		if ( ply:GetCurrentLevel( NOOB_SKILL_CRIMINAL ) >= 25 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000!" )
	end,
	rewardText = "$25,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Level 75 Criminal"] = {
	name = "Competent Criminal",
	desc = "Commit crimes until you reach Criminal Expertise Level 75!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_SKILL,
	achieveFunc = function( ply )
		if ( ply:GetCurrentLevel( NOOB_SKILL_CRIMINAL ) >= 75 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 50000 )
		ply:SuccessNotify( "You were rewarded $50,000!" )
	end,
	rewardText = "$50,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Level 25 Printing"] = {
	name = "An Individual With a Dream",
	desc = "Print money all the way to Printer Management Level 25!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_SKILL,
	achieveFunc = function( ply )
		if ( ply:GetCurrentLevel( NOOB_SKILL_PRINTING ) >= 25 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000!" )
	end,
	rewardText = "$25,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Level 75 Printing"] = {
	name = "Hardcore Counterfeiter",
	desc = "Print money all the way to Printer Management Level 75!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_SKILL,
	achieveFunc = function( ply )
		if ( ply:GetCurrentLevel( NOOB_SKILL_PRINTING ) >= 75 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 50000 )
		ply:SuccessNotify( "You were rewarded $50,000!" )
	end,
	rewardText = "$50,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Level 25 Running"] = {
	name = "Moderately Fit",
	desc = "Continue running until you reach Running Level 25!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_SKILL,
	achieveFunc = function( ply )
		if ( ply:GetCurrentLevel( NOOB_SKILL_RUNNING ) >= 25 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000!" )
	end,
	rewardText = "$25,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Level 75 Running"] = {
	name = "Born to Run",
	desc = "Continue running until you reach Running Level 75!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_SKILL,
	achieveFunc = function( ply )
		if ( ply:GetCurrentLevel( NOOB_SKILL_RUNNING ) >= 75 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 50000 )
		ply:SuccessNotify( "You were rewarded $50,000, and a Boot Hat if you didn't already have one!" )
		ply:GivePermWeapon( "boot_hat" )
	end,
	rewardText = "$50,000 and a Boot Hat!",
	globalAnnounce = true
}

NOOBRP.Achievements["Level 25 Herbalism"] = {
	name = "Green Thumb",
	desc = "Garden and gather Herbs until Herbalism Level 25!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_SKILL,
	achieveFunc = function( ply )
		if ( ply:GetCurrentLevel( NOOB_SKILL_HERBALISM ) >= 25 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:SuccessNotify( "You were rewarded $25,000 and x1 Valerian Root!" )
		ply:GiveHerb( "Valerian Root", 1 )
	end,
	rewardText = "x1 Valerian Root",
	globalAnnounce = true
}

NOOBRP.Achievements["Level 75 Herbalism"] = {
	name = "Attuned with Nature",
	desc = "Garden and gather Herbs until Herbalism Level 75!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_SKILL,
	achieveFunc = function( ply )
		if ( ply:GetCurrentLevel( NOOB_SKILL_HERBALISM ) >= 75 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:SuccessNotify( "You were rewarded x5 Valerian Root!" )
		ply:GiveHerb( "Valerian Root", 5 )
	end,
	rewardText = "x5 Valerian Root",
	globalAnnounce = true
}

NOOBRP.Achievements["Level 25 Alchemy"] = {
	name = "Adept Conjurer",
	desc = "Conjure all types of potions up to Alchemy Level 25!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_SKILL,
	achieveFunc = function( ply )
		if ( ply:GetCurrentLevel( NOOB_SKILL_ALCHEMY ) >= 25 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000!" )
	end,
	rewardText = "$25,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Level 75 Alchemy"] = {
	name = "One with Alchemy",
	desc = "Conjure all types of potions up to Alchemy Level 75!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_SKILL,
	achieveFunc = function( ply )
		if ( ply:GetCurrentLevel( NOOB_SKILL_ALCHEMY ) >= 75 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 50000 )
		ply:SuccessNotify( "You were rewarded $50,000!" )
	end,
	rewardText = "$50,000",
	globalAnnounce = true
}

/*------------- End Skill Achievements -------------------*/

NOOBRP.Achievements["Get 25 Revenge Kills"] = {
	name = "Sweet Revenge",
	desc = "Slay 25 players whom you have revenge on.",
	goal = 25,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MURDER,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Get 25 Revenge Kills" ) >= 25 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000!" )
	end,
	rewardText = "$25,000"
}

NOOBRP.Achievements["Get 75 Revenge Kills"] = {
	name = "Getting Ticked",
	desc = "Slay 75 players whom you have revenge on.",
	goal = 75,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MURDER,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Get 75 Revenge Kills" ) >= 75 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 50000 )
		ply:SuccessNotify( "You were rewarded $50,000!" )
	end,
	rewardText = "$50,000"
}

NOOBRP.Achievements["Get 200 Revenge Kills"] = {
	name = "Bloodthirsty for Vengeance",
	desc = "Slay 200 players whom you have revenge on.",
	goal = 200,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MURDER,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Get 200 Revenge Kills" ) >= 200 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 100000 )
		ply:SuccessNotify( "You were rewarded $100,000!" )
	end,
	rewardText = "$100,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Get 1000 Revenge Kills"] = {
	name = "The Avenger",
	desc = "Slay 1000 players whom you have revenge on.",
	goal = 1000,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MURDER,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Get 1000 Revenge Kills" ) >= 1000 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:GiveNewTitle( ENUM_TITLES_AVENGER )
	end,
	rewardText = "Avenger Title",
	globalAnnounce = true
}

NOOBRP.Achievements["Open the Beast Lair Portal"] = {
	name = "A Wild New World",
	desc = "Assist in opening a portal to the Beast's Lair!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_EVENT,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000!" )
	end,
	rewardText = "$25,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Open the Beast Lair Portal 5 Times"] = {
	name = "Portal Jockey",
	desc = "Assist in opening the Beast Lair portal five times.",
	goal = 5,
	category = ENUM_ACHIEVEMENTS_CATEGORY_EVENT,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Open the Beast Lair Portal 5 Times" ) >= 5 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 50000 )
		ply:SuccessNotify( "You were rewarded $50,000!" )
	end,
	rewardText = "$50,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Clear The Beast Lair"] = {
	name = "Beauty and the Beast",
	desc = "Venture to the Lair of the Beast and clear it.",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_EVENT,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 100000 )
		ply:SuccessNotify( "You were rewarded $100,000!" )
	end,
	rewardText = "$100,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Win Beast Event"] = {
	name = "The Beast Slayer",
	desc = "Deal the highest damage to the Beast.",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_EVENT,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 50000 )
		ply:SuccessNotify( "You were rewarded $50,000!" )
	end,
	rewardText = "$50,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Win Beast Event Second Place"] = {
	name = "So Close But So Far",
	desc = "Deal the second highest damage to the Beast.",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_EVENT,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000!" )
	end,
	rewardText = "$25,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Deal Over 50k Beast Damage"] = {
	name = "Among the Beasts",
	desc = "During a single Beast event, deal over 50,000 damage.",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_EVENT,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 100000 )
		ply:SuccessNotify( "You were rewarded $100,000!" )
	end,
	rewardText = "$100,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Become Crab Queen"] = {
	name = "Queen of the Crabs",
	desc = "Outlive your fellow crabs and become the Crab Queen!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_JOBRELATED,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 10000 )
		ply:SuccessNotify( "You were rewarded $10,000!" )
	end,
	rewardText = "$10,000"
}

NOOBRP.Achievements["Become Crab Queen 10 Times"] = {
	name = "Loyal to the Crab's Plight",
	desc = "Live to become the Crab Queen ten times!",
	goal = 10,
	category = ENUM_ACHIEVEMENTS_CATEGORY_JOBRELATED,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Become Crab Queen 10 Times" ) >= 10 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 20000 )
		ply:SuccessNotify( "You were rewarded $20,000!" )
	end,
	rewardText = "$20,000"
}

NOOBRP.Achievements["Complete 10 Quests"] = {
	name = "Running Some Errands",
	desc = "Complete any of the quests ten times.",
	goal = 10,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MISC,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Complete 10 Quests" ) >= 10 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000!" )
	end,
	rewardText = "$25,000"
}

NOOBRP.Achievements["Complete 100 Quests"] = {
	name = "Feeling Really Helpful",
	desc = "Complete any of the quests one hundred times.",
	goal = 100,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MISC,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Complete 100 Quests" ) >= 100 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 50000 )
		ply:SuccessNotify( "You were rewarded $50,000!" )
	end,
	rewardText = "$50,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Become Pacifist"] = {
	name = "Explore Pacifism",
	desc = "Go an hour without killing anyone and become a Pacifist.",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MISC,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 10000 )
		ply:SuccessNotify( "You were rewarded $10,000!" )
	end,
	rewardText = "$10,000"
}

NOOBRP.Achievements["Lose Pacifist"] = {
	name = "Lost Your Cool",
	desc = "Commit a violent action and lose Pacifism.",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MISC,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 5000 )
		ply:SuccessNotify( "You were rewarded $5,000!" )
	end,
	rewardText = "$5,000"
}

NOOBRP.Achievements["Become Pacifist 10 Times"] = {
	name = "Stop the Violence",
	desc = "Avoid killing and become a Pacifist ten times.",
	goal = 10,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MISC,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Become Pacifist 10 Times" ) >= 10 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000!" )
	end,
	rewardText = "$25,000"
}

NOOBRP.Achievements["Kill 10 Purge Players"] = {
	name = "Feeling Aggressive",
	desc = "In total, kill ten players during a Purge Event.",
	goal = 10,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MURDER,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Kill 10 Purge Players" ) >= 10 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 10000 )
		ply:SuccessNotify( "You were rewarded $10,000!" )
	end,
	rewardText = "$10,000"
}

NOOBRP.Achievements["Kill 100 Purge Players"] = {
	name = "No Sympathy",
	desc = "In total, kill one hundred players during a Purge Event.",
	goal = 100,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MURDER,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Kill 100 Purge Players" ) >= 100 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 35000 )
		ply:SuccessNotify( "You were rewarded $35,000!" )
	end,
	rewardText = "$35,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Combine Gems"] = {
	name = "Gem Opportunist",
	desc = "Combine gems into anything.",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MISC,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 5000 )
		ply:SuccessNotify( "You were rewarded $5,000!" )
	end,
	rewardText = "$5,000"
}

NOOBRP.Achievements["Combine Gems 10 Times"] = {
	name = "Skilled Crafter",
	desc = "Combine gems into anything ten times.",
	goal = 10,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MISC,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Combine Gems 10 Times" ) >= 10 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 10000 )
		ply:SuccessNotify( "You were rewarded $10,000!" )
	end,
	rewardText = "$10,000"
}

NOOBRP.Achievements["Combine Gems 100 Times"] = {
	name = "The Gem Transmuter",
	desc = "Combine gems into anything one hundred times.",
	goal = 100,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MISC,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Combine Gems 100 Times" ) >= 100 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 15000 )
		ply:SuccessNotify( "You were rewarded $15,000!" )
	end,
	rewardText = "$15,000"
}

NOOBRP.Achievements["Drill A Sapphire"] = {
	name = "Beginner's Luck",
	desc = "Drill the earth as a Mining Foreman until you recover a Sapphire!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_GATHERINGANDMINING,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 5000 )
		ply:SuccessNotify( "You were rewarded $5,000!" )
	end,
	rewardText = "$5,000"
}

NOOBRP.Achievements["Drill 100 Sapphires"] = {
	name = "Blue Dream",
	desc = "Drill one hundred Sapphires as a Mining Foreman!",
	goal = 100,
	category = ENUM_ACHIEVEMENTS_CATEGORY_GATHERINGANDMINING,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000!" )
	end,
	rewardText = "$25,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Drill A Obsidian"] = {
	name = "I Thought It Was Shale",
	desc = "Drill the earth as a Mining Foreman until you recover a Obsidian!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_GATHERINGANDMINING,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000!" )
	end,
	rewardText = "$25,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Drill A Diamond"] = {
	name = "I'm Feeling Lucky",
	desc = "Drill the earth as a Mining Foreman until you recover a Diamond!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_GATHERINGANDMINING,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 100000 )
		ply:SuccessNotify( "You were rewarded $100,000!" )
	end,
	rewardText = "$100,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Create Plague Canister"] = {
	name = "Bad Intentions",
	desc = "As a Scientist, use your Plague Lab to create a canister!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_JOBRELATED,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 10000 )
		ply:SuccessNotify( "You were rewarded $10,000!" )
	end,
	rewardText = "$10,000"
}

NOOBRP.Achievements["Kill Bank Robber"] = {
	name = "Not In My Vault!",
	desc = "During a robbery, kill the robber!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MURDER,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 10000 )
		ply:SuccessNotify( "You were rewarded $10,000!" )
	end,
	rewardText = "$10,000"
}

NOOBRP.Achievements["Arrest Bank Robber"] = {
	name = "A Good Deed",
	desc = "During a robbery, be the one to arrest the robber!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_CRIMEANDLAW,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000!" )
	end,
	rewardText = "$25,000"
}

NOOBRP.Achievements["Kill Clan Enemy"] = {
	name = "Stop the Opposition",
	desc = "During a Clan War, kill a enemy clan member!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MURDER,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 5000 )
		ply:SuccessNotify( "You were rewarded $5,000!" )
	end,
	rewardText = "$5,000"
}

NOOBRP.Achievements["Kill 100 Clan Enemies"] = {
	name = "Endless Bloodshed",
	desc = "In total, kill one hundred enemy clan members during a Clan War!",
	goal = 100,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MURDER,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Kill 100 Clan Enemies" ) >= 100 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000!" )
	end,
	rewardText = "$25,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Escape From Jail"] = {
	name = "Get Out of Jail Free Card",
	desc = "Manage to reach the prison warden outside the nexus and escape from jail!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_CRIMEANDLAW,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 5000 )
		ply:SuccessNotify( "You were rewarded $5,000!" )
	end,
	rewardText = "$5,000"
}

NOOBRP.Achievements["Escape From Jail 10 Times"] = {
	name = "The Wannabe Escapist",
	desc = "Reach the prison warden and escape from jail ten times!",
	goal = 10,
	category = ENUM_ACHIEVEMENTS_CATEGORY_CRIMEANDLAW,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Escape From Jail 10 Times" ) >= 10 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000!" )
	end,
	rewardText = "$25,000"
}

NOOBRP.Achievements["Spend 50k On Props"] = {
	name = "Another Day Another Dollar",
	desc = "Purchase $50,000 worth of props.",
	goal = 50000,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MISC,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Spend 50k On Props" ) >= 50000 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000!" )
	end,
	rewardText = "$25,000"
}

NOOBRP.Achievements["Spend 200k On Props"] = {
	name = "Spend Some to Make Some",
	desc = "Purchase $200,000 worth of props.",
	goal = 200000,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MISC,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Spend 200k On Props" ) >= 200000 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 100000 )
		ply:SuccessNotify( "You were rewarded $100,000!" )
	end,
	rewardText = "$100,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Rob A Shopkeeper"] = {
	name = "What's Armed Robbery?",
	desc = "Rob any of the shopkeepers.",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_CRIMEANDLAW,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 5000 )
		ply:SuccessNotify( "You were rewarded $5,000!" )
		ply:RewardXP( 5, NOOB_SKILL_CRIMINAL, "CriminalXP", "Criminal Expertise", true )
	end,
	rewardText = "$5,000 and 5 Criminal XP"
}

NOOBRP.Achievements["Rob 10 Shopkeepers"] = {
	name = "Lust for Money",
	desc = "In total, rob any of the shopkeepers ten times.",
	goal = 10,
	category = ENUM_ACHIEVEMENTS_CATEGORY_CRIMEANDLAW,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Rob 10 Shopkeepers" ) >= 10 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 10000 )
		ply:SuccessNotify( "You were rewarded $10,000!" )
		ply:RewardXP( 10, NOOB_SKILL_CRIMINAL, "CriminalXP", "Criminal Expertise", true )
	end,
	rewardText = "$10,000 and 10 Criminal XP"
}

NOOBRP.Achievements["Rob 100 Shopkeepers"] = {
	name = "The Swift Swindler",
	desc = "In total, rob any of the shopkeepers one hundred times.",
	goal = 100,
	category = ENUM_ACHIEVEMENTS_CATEGORY_CRIMEANDLAW,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Rob 100 Shopkeepers" ) >= 100 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 35000 )
		ply:SuccessNotify( "You were rewarded $35,000!" )
		ply:RewardXP( 20, NOOB_SKILL_CRIMINAL, "CriminalXP", "Criminal Expertise", true )
	end,
	rewardText = "$35,000 and 20 Criminal XP",
	globalAnnounce = true
}

NOOBRP.Achievements["Kill A Shopkeeper"] = {
	name = "Guns Don't Kill People",
	desc = "Kill any of the shopkeepers.",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_CRIMEANDLAW,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 5000 )
		ply:SuccessNotify( "You were rewarded $5,000!" )
		ply:RewardXP( 2, NOOB_SKILL_CRIMINAL, "CriminalXP", "Criminal Expertise", true )
	end,
	rewardText = "$5,000 and 2 Criminal XP"
}

NOOBRP.Achievements["Kill 10 Shopkeepers"] = {
	name = "Everybody is Worthless",
	desc = "In total, kill any of the shopkeepers ten times.",
	goal = 10,
	category = ENUM_ACHIEVEMENTS_CATEGORY_CRIMEANDLAW,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Kill 10 Shopkeepers" ) >= 10 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 7500 )
		ply:SuccessNotify( "You were rewarded $7,500!" )
		ply:RewardXP( 4, NOOB_SKILL_CRIMINAL, "CriminalXP", "Criminal Expertise", true )
	end,
	rewardText = "$7,500 and 4 Criminal XP"
}

NOOBRP.Achievements["Kill 100 Shopkeepers"] = {
	name = "Humanity is Disgusting",
	desc = "In total, kill any of the shopkeepers one hundred times.",
	goal = 100,
	category = ENUM_ACHIEVEMENTS_CATEGORY_CRIMEANDLAW,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Kill 100 Shopkeepers" ) >= 100 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 17500 )
		ply:SuccessNotify( "You were rewarded $17,500!" )
		ply:RewardXP( 5, NOOB_SKILL_CRIMINAL, "CriminalXP", "Criminal Expertise", true )
	end,
	rewardText = "$17,500 and 5 Criminal XP",
	globalAnnounce = true
}

NOOBRP.Achievements["Use A Soul Orb"] = {
	name = "Another Chance",
	desc = "While you're a ghost, find and absorb a Soul Orb.",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MISC,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 7500 )
		ply:SuccessNotify( "You were rewarded $7,500!" )
	end,
	rewardText = "$7,500"
}

NOOBRP.Achievements["Use 10 Soul Orbs"] = {
	name = "Too Many Chances",
	desc = "In total, absorb ten Soul Orbs while a ghost.",
	goal = 10,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MISC,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Use 10 Soul Orbs" ) >= 10 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 15000 )
		ply:SuccessNotify( "You were rewarded $15,000!" )
	end,
	rewardText = "$15,000"
}

NOOBRP.Achievements["Use 100 Soul Orbs"] = {
	name = "The Determined Fool",
	desc = "In total, absorb one hundred Soul Orbs while a ghost.",
	goal = 100,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MISC,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Use 100 Soul Orbs" ) >= 100 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 35000 )
		ply:SuccessNotify( "You were rewarded $35,000!" )
	end,
	rewardText = "$35,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Rob The Bank"] = {
	name = "Looked Harder in Movies",
	desc = "Successfully rob the bank!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_CRIMEANDLAW,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 10000 )
		ply:SuccessNotify( "You were rewarded $10,000!" )
	end,
	rewardText = "$10,000"
}

NOOBRP.Achievements["Rob The Bank 10 Times"] = {
	name = "The Trustfund Pillager",
	desc = "Successfully rob the bank on ten different occasions.",
	goal = 10,
	category = ENUM_ACHIEVEMENTS_CATEGORY_CRIMEANDLAW,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Rob The Bank 10 Times" ) >= 10 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000!" )
		ply:RewardXP( 10, NOOB_SKILL_CRIMINAL, "CriminalXP", "Criminal Expertise", true )
	end,
	rewardText = "$25,000 and 10 Criminal XP"
}

NOOBRP.Achievements["Rob The Bank 100 Times"] = {
	name = "The Vault Buccaneer",
	desc = "Successfully rob the bank on one hundred different occasions.",
	goal = 100,
	category = ENUM_ACHIEVEMENTS_CATEGORY_CRIMEANDLAW,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Rob The Bank 100 Times" ) >= 100 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 50000 )
		ply:SuccessNotify( "You were rewarded $50,000!" )
		ply:RewardXP( 50, NOOB_SKILL_CRIMINAL, "CriminalXP", "Criminal Expertise", true )
	end,
	rewardText = "$50,000 and 50 Criminal XP",
	globalAnnounce = true
}

NOOBRP.Achievements["Get 100 Reputation"] = {
	name = "Somebody Loves Me!",
	desc = "Earn up to one hundred reputation with a Shopkeeper!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_MISC,
	achieveFunc = function( ply, class )
		if ( ply:GetReputation( class ) >= 100 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 20000 )
		ply:SuccessNotify( "You were rewarded $20,000 and 5 Sapphires!" )
		ply:GiveGem( "Sapphires", 5 )
	end,
	rewardText = "$20,000 and 5 Sapphires",
	globalAnnounce = true
}

NOOBRP.Achievements["Mine 500k Rocks"] = {
	name = "Rocks and Spades",
	desc = "Mine 500,000 Rocks using your Shovel.",
	goal = 500000,
	category = ENUM_ACHIEVEMENTS_CATEGORY_GATHERINGANDMINING,
	achieveFunc = function( ply, class )
		if ( ply:GetAchieveProgress( "Mine 500k Rocks" ) >= 500000 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 20000 )
		ply:SuccessNotify( "You were rewarded an Obsidian" )
		ply:GiveGem( "Obsidians", 1 )
	end,
	rewardText = "1 Obsidian",
	globalAnnounce = true
}

NOOBRP.Achievements["Gather A Herb"] = {
	name = "Flower Picker",
	desc = "Gather a naturally occuring Herb!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_GATHERINGANDMINING,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 5000 )
		ply:SuccessNotify( "You were rewarded $5,000!" )
	end,
	rewardText = "$5,000"
}

NOOBRP.Achievements["Gather 10 Herbs"] = {
	name = "Greenskeeper",
	desc = "Gather ten naturally occuring Herbs!",
	goal = 10,
	category = ENUM_ACHIEVEMENTS_CATEGORY_GATHERINGANDMINING,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Gather 10 Herbs" ) >= 10 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 10000 )
		ply:SuccessNotify( "You were rewarded $10,000!" )
		ply:RewardXP( 5, NOOB_SKILL_HERBALISM, "HerbalismXP", "Herbalism", true )
	end,
	rewardText = "$10,000 and 5 Herbalism XP"
}

NOOBRP.Achievements["Gather 100 Herbs"] = {
	name = "Surrounded by Nature",
	desc = "Gather one hundred naturally occuring Herbs!",
	goal = 100,
	category = ENUM_ACHIEVEMENTS_CATEGORY_GATHERINGANDMINING,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Gather 100 Herbs" ) >= 100 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000!" )
		ply:RewardXP( 15, NOOB_SKILL_HERBALISM, "HerbalismXP", "Herbalism", true )
	end,
	rewardText = "$25,000 and 15 Herbalism XP",
	globalAnnounce = true
}

NOOBRP.Achievements["Gather 1000 Herbs"] = {
	name = "Herbmaster",
	desc = "Gather one thousand naturally occuring Herbs!",
	goal = 1000,
	category = ENUM_ACHIEVEMENTS_CATEGORY_GATHERINGANDMINING,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Gather 1000 Herbs" ) >= 1000 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 50000 )
		ply:SuccessNotify( "You were rewarded $50,000 and x5 Valerian Root!" )
		ply:GiveHerb( "Valerian Root", 3 )
		ply:RewardXP( 30, NOOB_SKILL_HERBALISM, "HerbalismXP", "Herbalism", true )
	end,
	rewardText = "$50,000, 30 Herbalism XP, and 3 Valerian Root",
	globalAnnounce = true
}

NOOBRP.Achievements["Gather A Valerian Root"] = {
	name = "Rare Herb Seeker",
	desc = "Find naturally occuring Valerian Root!",
	goal = 1,
	category = ENUM_ACHIEVEMENTS_CATEGORY_GATHERINGANDMINING,
	achieveFunc = function( ply )
		return false
	end,
	rewardFunc = function( ply )
		ply:addMoney( 35000 )
		ply:SuccessNotify( "You were rewarded $35,000!" )
		ply:RewardXP( 10, NOOB_SKILL_HERBALISM, "HerbalismXP", "Herbalism", true )
	end,
	rewardText = "$35,000 and 10 Herbalism XP",
	globalAnnounce = true
}

NOOBRP.Achievements["Gather 50 Valerian Roots"] = {
	name = "The Gardener",
	desc = "Find fifty units of naturally occuring Valerian Root!",
	goal = 50,
	category = ENUM_ACHIEVEMENTS_CATEGORY_GATHERINGANDMINING,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Gather 50 Valerian Roots" ) >= 50 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:GiveNewTitle( ENUM_TITLES_GARDENER )
	end,
	rewardText = "Gardener Title",
	globalAnnounce = true
}

NOOBRP.Achievements["Craft 25 Potions"] = {
	name = "The Novice Alchemist",
	desc = "Craft twenty-five potions of any type.",
	goal = 25,
	category = ENUM_ACHIEVEMENTS_CATEGORY_GATHERINGANDMINING,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Craft 25 Potions" ) >= 25 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 25000 )
		ply:SuccessNotify( "You were rewarded $25,000!" )
	end,
	rewardText = "$25,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Craft 100 Potions"] = {
	name = "The Adept Alchemist",
	desc = "Craft one hundred potions of any type.",
	goal = 100,
	category = ENUM_ACHIEVEMENTS_CATEGORY_GATHERINGANDMINING,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Craft 100 Potions" ) >= 100 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 35000 )
		ply:SuccessNotify( "You were rewarded $35,000!" )
	end,
	rewardText = "$35,000",
	globalAnnounce = true
}

NOOBRP.Achievements["Craft 1000 Potions"] = {
	name = "The Master Alchemist",
	desc = "Craft one thousand potions of any type.",
	goal = 1000,
	category = ENUM_ACHIEVEMENTS_CATEGORY_GATHERINGANDMINING,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Craft 1000 Potions" ) >= 1000 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:GiveNewTitle( ENUM_TITLES_ALCHEMIST )
	end,
	rewardText = "Alchemist Title",
	globalAnnounce = true
}

NOOBRP.Achievements["Make 100 Arrests"] = {
	name = "Civil Protection Novice",
	desc = "Make one hundred arrests, not included jailed people.",
	goal = 100,
	category = ENUM_ACHIEVEMENTS_CATEGORY_CRIMEANDLAW,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Make 100 Arrests" ) >= 100 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 20000 )
		ply:SuccessNotify( "You were rewarded $20,000!" )
		ply:RewardXP( 20, NOOB_SKILL_COP, "PoliceXP", "Civil Protection", true )
	end,
	rewardText = "$20,000 and 20 Civil Protection XP",
	globalAnnounce = true
}

NOOBRP.Achievements["Make 1000 Arrests"] = {
	name = "Civil Protection Pro",
	desc = "Make one thousand arrests, not included jailed people.",
	goal = 1000,
	category = ENUM_ACHIEVEMENTS_CATEGORY_CRIMEANDLAW,
	achieveFunc = function( ply )
		if ( ply:GetAchieveProgress( "Make 1000 Arrests" ) >= 1000 ) then
			return true
		else
			return false
		end
	end,
	rewardFunc = function( ply )
		ply:addMoney( 50000 )
		ply:SuccessNotify( "You were rewarded $50,000!" )
		ply:RewardXP( 50, NOOB_SKILL_COP, "PoliceXP", "Civil Protection", true )
	end,
	rewardText = "$50,000 and 50 Civil Protection XP",
	globalAnnounce = true
}

if ( SERVER ) then return end

local function OnReceiveAchieveData( len )
	local achieveName = net.ReadString( )
	local achieveProgress = net.ReadString( )
	local achieveComplete = tobool( net.ReadBit( ) )
	LocalPlayer( ).achieveTable = LocalPlayer( ).achieveTable or { }
	LocalPlayer( ).achieveTable[ achieveName ] = { progress = achieveProgress, completed = achieveComplete }
end
net.Receive( "N00BRP_Achievements", OnReceiveAchieveData )

local function OnReceiveGetAchieveData( len )
	local mesType = net.ReadUInt( 8 )
	if ( mesType == ENUM_ACHIEVEMENTS_BEGINTRANSFER ) then
		if ( LocalPlayer( ).isReceivingAchievements ) then return end
		LocalPlayer( ).isReceivingAchievements = true
		LocalPlayer( ).playerAchievementViewing = net.ReadEntity( )
	elseif ( mesType == ENUM_ACHIEVEMENTS_TRANSFERACHIEVE ) then
		local achieveName = net.ReadString( )
		local achieveProgress = net.ReadString( )
		local achieveComplete = tobool( net.ReadBit( ) )
		if not ( IsValid( LocalPlayer( ).playerAchievementViewing ) ) then return end
		LocalPlayer( ).playerAchievementViewing.achieveTable = LocalPlayer( ).playerAchievementViewing.achieveTable or { }
		LocalPlayer( ).playerAchievementViewing.achieveTable[ achieveName ] = { progress = achieveProgress, completed = achieveComplete }
	elseif ( mesType == ENUM_ACHIEVEMENTS_ENDTRANSFER ) then
		if ( ValidPanel( LocalPlayer( ).achievementViewer ) ) then
			LocalPlayer( ).achievementViewer:Remove( )
		end
		LocalPlayer( ).achievementViewer = vgui.Create( "N00BRP_AchievementViewer" )
		LocalPlayer( ).achievementViewer:SetViewData( LocalPlayer( ).playerAchievementViewing )
		LocalPlayer( ).playerAchievementViewing = nil
		LocalPlayer( ).isReceivingAchievements = false
	end
end
net.Receive( "N00BRP_GetAchievements", OnReceiveGetAchieveData )
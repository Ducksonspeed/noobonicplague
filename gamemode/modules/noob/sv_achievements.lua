util.AddNetworkString( "N00BRP_Achievements" )
util.AddNetworkString( "N00BRP_GetAchievements" )

local plyMeta = FindMetaTable( "Player" )

if not ( file.IsDir( "noob", "DATA" ) ) then file.CreateDir( "noob" ) end
if not ( file.IsDir( "noob/achievements", "DATA" ) ) then file.CreateDir( "noob/achievements" ) end


function plyMeta:DidAchieve( name )
	if not ( NOOBRP.Achievements[ name ] ) then return false end
	local didAchieve = NOOBRP.Achievements[ name ].achieveFunc( self )
	if ( didAchieve ) then
		self:SetAchieveComplete( name )
	end
	return didAchieve
end

function plyMeta:RetrieveAchievements( other )
	if ( !IsValid( other ) or !other:IsPlayer( ) or other == self ) then return end
	if ( !other.achieveTable or !istable( other.achieveTable ) ) then return end
	net.Start( "N00BRP_GetAchievements" )
		net.WriteUInt( ENUM_ACHIEVEMENTS_BEGINTRANSFER, 8 )
		net.WriteEntity( other )
	net.Send( self )
	for name, tbl in pairs ( other.achieveTable ) do
		net.Start( "N00BRP_GetAchievements" )
			net.WriteUInt( ENUM_ACHIEVEMENTS_TRANSFERACHIEVE, 8 )
			net.WriteString( name )
			net.WriteString( tbl.progress )
			net.WriteBit( tbl.completed )
		net.Send( self )
	end
	net.Start( "N00BRP_GetAchievements" )
		net.WriteUInt( ENUM_ACHIEVEMENTS_ENDTRANSFER, 8 )
	net.Send( self )
end

function plyMeta:LoadAchievements( )
	local path = "noob/achievements/" .. self:SteamID64( ) .. ".txt"
	if ( file.Exists( path, "DATA" ) ) then
		self.achieveTable = util.JSONToTable( file.Read( path, "DATA" ) )
		self.achievementsLoaded = true
		for name, tbl in pairs ( self.achieveTable ) do
			net.Start( "N00BRP_Achievements" )
				net.WriteString( name )
				net.WriteString( tbl.progress )
				net.WriteBit( tbl.completed )
			net.Send( self )
		end
	else
		NOOBRP = NOOBRP or { }
		NOOBRP.Achievements = NOOBRP.Achievements or { }
		self.achieveTable = self.achieveTable or { }
		for name, tbl in pairs ( NOOBRP.Achievements ) do
			self.achieveTable[ name ] = { progress = 0, completed = false }
		end
		file.Write( path, util.TableToJSON( self.achieveTable ) )
		self.achievementsLoaded = true
	end
end

function plyMeta:IncrementAchieveProgress( name, amt )
	if not ( NOOBRP.Achievements[ name ] ) then return end
	local max = NOOBRP.Achievements[ name ].goal
	local currentProgress = self:GetAchieveProgress( name )
	self:SetAchieveProgress( name, math.Clamp( currentProgress + amt, 0, max ) )
end

function plyMeta:SetAchieveProgress( name, progress )
	if not ( self.achievementsLoaded ) then return end
	local path = "noob/achievements/" .. self:SteamID64( ) .. ".txt"
	self.achieveTable = self.achieveTable or { }
	if not ( NOOBRP.Achievements[ name ] ) then return end
	if ( self.achieveTable[ name ] and self.achieveTable[ name ].completed ) then return end
	self.achieveTable[ name ] = { progress = progress, completed = false }
	file.Write( path, util.TableToJSON( self.achieveTable ) )
	net.Start( "N00BRP_Achievements" )
		net.WriteString( name )
		net.WriteString( progress )
		net.WriteBit( false )
	net.Send( self )
end

function plyMeta:SetAchieveComplete( name )
	if not ( self.achievementsLoaded ) then return end
	local path = "noob/achievements/" .. self:SteamID64( ) .. ".txt"
	self.achieveTable = self.achieveTable or { }
	if not ( NOOBRP.Achievements[ name ] ) then return end
	local progress = NOOBRP.Achievements[ name ].goal
	self.achieveTable[ name ] = { progress = progress, completed = true }
	file.Write( path, util.TableToJSON( self.achieveTable ) )
	net.Start( "N00BRP_Achievements" )
		net.WriteString( name )
		net.WriteString( progress )
		net.WriteBit( true )
	net.Send( self )
	self:SuccessNotify( "You've completed the Achievement: " .. NOOBRP.Achievements[ name ].name )
	//if ( NOOBRP.Achievements[ name ].globalAnnounce ) then
		BroadcastColoredMessage( { team.GetColor( self:Team( ) ), self:Name( ), Color( 255, 255, 255 ), " has completed the Achievement: ", Color( 45, 175, 45 ), NOOBRP.Achievements[ name ].name, Color( 255, 255, 255 ), "!" } )
	//end
	if ( NOOBRP.Achievements[ name ].rewardFunc ) then
		NOOBRP.Achievements[ name ].rewardFunc( self )
	end
end

function plyMeta:GetAchieveProgress( name )
	local progress = 0
	self.achieveTable = self.achieveTable or { }
	if not ( NOOBRP.Achievements[ name ] ) then return 0 end
	if not ( self.achieveTable[ name ] ) then
		self.achieveTable[ name ] = { progress = 0, completed = false }
	end
	return ( self.achieveTable[ name ].progress )
end

function plyMeta:IsAchieveComplete( name )
	self.achieveTable = self.achieveTable or { }
	if not ( self.achieveTable[ name ] ) then return false end
	return ( self.achieveTable[ name ].completed )
end

local function OnPlayerLevelUp( ply, enum, level )
	if ( enum == NOOB_SKILL_ENDURANCE ) then
		if ( !ply:IsAchieveComplete( "Level 10 Endurance" ) ) then
			ply:DidAchieve( "Level 10 Endurance" )
		elseif ( !ply:IsAchieveComplete( "Level 35 Endurance" ) ) then
			ply:DidAchieve( "Level 35 Endurance" )
		end
	elseif ( enum == NOOB_SKILL_MINING ) then
		if ( !ply:IsAchieveComplete( "Level 25 Mining" ) ) then
			ply:DidAchieve( "Level 25 Mining" )
		elseif ( !ply:IsAchieveComplete( "Level 75 Mining" ) ) then
			ply:DidAchieve( "Level 75 Mining" )
		end
	elseif ( enum == NOOB_SKILL_PRINTING ) then
		if ( !ply:IsAchieveComplete( "Level 25 Printing" ) ) then
			ply:DidAchieve( "Level 25 Printing" )
		elseif ( !ply:IsAchieveComplete( "Level 75 Printing" ) ) then
			ply:DidAchieve( "Level 75 Printing" )
		end
	elseif ( enum == NOOB_SKILL_COP ) then
		if ( !ply:IsAchieveComplete( "Level 25 Police" ) ) then
			ply:DidAchieve( "Level 25 Police" )
		elseif ( !ply:IsAchieveComplete( "Level 75 Police" ) ) then
			ply:DidAchieve( "Level 75 Police" )
		end
	elseif ( enum == NOOB_SKILL_CRIMINAL ) then
		if ( !ply:IsAchieveComplete( "Level 25 Criminal" ) ) then
			ply:DidAchieve( "Level 25 Criminal" )
		elseif ( !ply:IsAchieveComplete( "Level 75 Criminal" ) ) then
			ply:DidAchieve( "Level 75 Criminal" )
		end
	elseif ( enum == NOOB_SKILL_RUNNING ) then
		if ( !ply:IsAchieveComplete( "Level 25 Running" ) ) then
			ply:DidAchieve( "Level 25 Running" )
		elseif ( !ply:IsAchieveComplete( "Level 75 Running" ) ) then
			ply:DidAchieve( "Level 75 Running" )
		end
	elseif ( enum == NOOB_SKILL_HERBALISM ) then
		if ( !ply:IsAchieveComplete( "Level 25 Herbalism" ) ) then
			ply:DidAchieve( "Level 25 Herbalism" )
		elseif ( !ply:IsAchieveComplete( "Level 75 Herbalism" ) ) then
			ply:DidAchieve( "Level 75 Herbalism" )
		end
	elseif ( enum == NOOB_SKILL_ALCHEMY ) then
		if ( !ply:IsAchieveComplete( "Level 25 Alchemy" ) ) then
			ply:DidAchieve( "Level 25 Alchemy" )
		elseif ( !ply:IsAchieveComplete( "Level 75 Alchemy" ) ) then
			ply:DidAchieve( "Level 75 Alchemy" )
		end
	end
end
hook.Add( "OnPlayerLevelUp", "N00BRP_Achievements_OnPlayerLevelUp", OnPlayerLevelUp )

local function OnPlayerGetRevenge( attacker, victim )
	if ( !attacker:IsAchieveComplete( "Get 25 Revenge Kills" ) ) then
		attacker:IncrementAchieveProgress( "Get 25 Revenge Kills", 1 )
		attacker:DidAchieve( "Get 25 Revenge Kills" )
	elseif ( !attacker:IsAchieveComplete( "Get 75 Revenge Kills" ) ) then
		attacker:IncrementAchieveProgress( "Get 75 Revenge Kills", 1 )
		attacker:DidAchieve( "Get 75 Revenge Kills" )
	elseif ( !attacker:IsAchieveComplete( "Get 200 Revenge Kills" ) ) then
		attacker:IncrementAchieveProgress( "Get 200 Revenge Kills", 1 )
		attacker:DidAchieve( "Get 200 Revenge Kills" )
	elseif ( !attacker:IsAchieveComplete( "Get 1000 Revenge Kills" ) ) then
		attacker:IncrementAchieveProgress( "Get 1000 Revenge Kills", 1 )
		attacker:DidAchieve( "Get 1000 Revenge Kills" )
	end
end
hook.Add( "OnPlayerGetRevenge", "N00BRP_Achievements_OnPlayerGetRevenge", OnPlayerGetRevenge )

local function OnBeastEventEnd( firstPlace, firstPlaceDamage, secondPlace, secondPlaceDamage )
	if ( !firstPlace:IsAchieveComplete( "Win Beast Event" ) ) then
		firstPlace:SetAchieveComplete( "Win Beast Event" )
	end
	if ( IsValid( secondPlace ) and !secondPlace:IsAchieveComplete( "Win Beast Event Second Place" ) ) then
		secondPlace:SetAchieveComplete( "Win Beast Event Second Place" )
	end
	if ( !firstPlace:IsAchieveComplete( "Deal Over 50k Beast Damage" ) and firstPlaceDamage > 50000 ) then
		firstPlace:SetAchieveComplete( "Deal Over 50k Beast Damage" )
	end
end
hook.Add( "OnBeastEventEnd", "N00BRP_Achievements_OnBeastEventEnd", OnBeastEventEnd )

local function OnCrabQueenEvolve( ply )
	if not ( ply:IsAchieveComplete( "Become Crab Queen" ) ) then
		ply:SetAchieveComplete( "Become Crab Queen" )
	end
	if not ( ply:IsAchieveComplete( "Become Crab Queen 10 Times" ) ) then
		ply:IncrementAchieveProgress( "Become Crab Queen 10 Times", 1 )
		ply:DidAchieve( "Become Crab Queen 10 Times" )
	end
end
hook.Add( "OnCrabQueenEvolve", "N00BRP_Achievements_OnCrabQueenEvolve", OnCrabQueenEvolve )

local function OnQuestComplete( ply )
	if ( !ply:IsAchieveComplete( "Complete 10 Quests" ) ) then
		ply:IncrementAchieveProgress( "Complete 10 Quests", 1 )
		ply:DidAchieve( "Complete 10 Quests" )
	elseif ( !ply:IsAchieveComplete( "Complete 100 Quests" ) ) then
		ply:IncrementAchieveProgress( "Complete 100 Quests", 1 )
		ply:DidAchieve( "Complete 100 Quests" )
	end
end
hook.Add( "OnQuestComplete", "N00BRP_Achievements_OnQuestComplete", OnQuestComplete )

local function OnPlayerPacifism( ply )
	if ( !ply:IsAchieveComplete( "Become Pacifist" ) ) then
		ply:SetAchieveComplete( "Become Pacifist" )
	end
	if ( !ply:IsAchieveComplete( "Become Pacifist 10 Times" ) ) then
		ply:IncrementAchieveProgress( "Become Pacifist 10 Times", 1 )
		ply:DidAchieve( "Become Pacifist 10 Times" )
	end
end
hook.Add( "OnPlayerPacifism", "N00BRP_Achievements_OnPlayerPacifism", OnPlayerPacifism )

local function OnPlayerRevokePacifism( ply )
	if not ( ply:IsAchieveComplete( "Lose Pacifist" ) ) then
		ply:SetAchieveComplete( "Lose Pacifist" )
	end
end
hook.Add( "OnPlayerRevokePacifism", "N00BRP_Achievements_OnPlayerRevokePacifism", OnPlayerRevokePacifism )

local function OnPlayerPurgeKill( attacker, victim, wasCivilian )
	if ( !ply:IsAchieveComplete( "Kill 10 Purge Players" ) ) then
		ply:IncrementAchieveProgress( "Kill 10 Purge Players", 1 )
		ply:DidAchieve( "Kill 10 Purge Players" )
	elseif ( !ply:IsAchieveComplete( "Kill 100 Purge Players" ) ) then
		ply:IncrementAchieveProgress( "Kill 100 Purge Players", 1 )
		ply:DidAchieve( "Kill 100 Purge Players" )
	end
end
hook.Add( "OnPlayerPurgeKill", "N00BRP_Achievements_OnPlayerPurgeKill", OnPlayerPurgeKill )

local function OnPlayerCraftGems( ply )
	if not ( ply:IsAchieveComplete( "Combine Gems" ) ) then
		ply:SetAchieveComplete( "Combine Gems" )
	end
	if ( !ply:IsAchieveComplete( "Combine Gems 10 Times" ) ) then
		ply:IncrementAchieveProgress( "Combine Gems 10 Times", 1 )
		ply:DidAchieve( "Combine Gems 10 Times" )
	elseif ( !ply:IsAchieveComplete( "Combine Gems 100 Times" ) ) then
		ply:IncrementAchieveProgress( "Combine Gems 100 Times", 1 )
		ply:DidAchieve( "Combine Gems 100 Times" )
	end
end
hook.Add( "OnPlayerCraftGems", "N00BRP_Achievements_OnPlayerCraftGems", OnPlayerCraftGems )

local function OnDrillGemDrop( ply, gemType )
	if ( gemType == 6 ) then
		if not ( ply:IsAchieveComplete( "Drill A Sapphire" ) ) then
			ply:SetAchieveComplete( "Drill A Sapphire" )
		end
		if not ( ply:IsAchieveComplete( "Drill 100 Sapphires" ) ) then
			ply:IncrementAchieveProgress( "Drill 100 Sapphires", 1 )
			ply:DidAchieve( "Drill 100 Sapphires" )
		end
	elseif ( gemType == 7 ) then
		if not ( ply:IsAchieveComplete( "Drill A Obsidian" ) ) then
			ply:SetAchieveComplete( "Drill A Obsidian" )
		end
	elseif ( gemType == 8 ) then
		if not ( ply:IsAchieveComplete( "Drill A Diamond" ) ) then
			ply:SetAchieveComplete( "Drill A Diamond" )
		end
	end
end
hook.Add( "OnDrillGemDrop", "N00BRP_Achievements_OnDrillGemDrop", OnDrillGemDrop )

local function OnPlagueCanisterMade( ply )
	if not ( ply:IsAchieveComplete( "Create Plague Canister" ) ) then
		ply:SetAchieveComplete( "Create Plague Canister" )
	end
end
hook.Add( "OnPlagueCanisterMade", "N00BRP_Achievements_OnPlagueCanisterMade", OnPlagueCanisterMade )

local function OnPlayerKillBankRobber( ply, robber )
	if not ( ply:IsAchieveComplete( "Kill Bank Robber" ) ) then
		ply:SetAchieveComplete( "Kill Bank Robber" )
	end
end
hook.Add( "OnPlayerKillBankRobber", "N00BRP_Achievements_OnPlayerKillBankRobber", OnPlayerKillBankRobber )

local function OnPlayerArrestBankRobber( ply, robber )
	if not ( ply:IsAchieveComplete( "Arrest Bank Robber" ) ) then
		ply:SetAchieveComplete( "Arrest Bank Robber" )
	end
end
hook.Add( "OnPlayerArrestBankRobber", "N00BRP_Achievements_OnPlayerArrestBankRobber", OnPlayerArrestBankRobber )

local function OnPlayerKillClanEnemy( ply, victim )
	if ( !ply:IsAchieveComplete( "Kill Clan Enemy" ) ) then
		ply:SetAchieveComplete( "Kill Clan Enemy" )
	end
	if ( !ply:IsAchieveComplete( "Kill 100 Clan Enemies" ) ) then
		ply:IncrementAchieveProgress( "Kill 100 Clan Enemies", 1 )
		ply:DidAchieve( "Kill 100 Clan Enemies" )
	end
end
hook.Add( "OnPlayerKillClanEnemy", "N00BRP_Achievements_OnPlayerKillClanEnemy", OnPlayerKillClanEnemy )

local function OnPlayerEscapeJail( ply )
	if ( !ply:IsAchieveComplete( "Escape From Jail" ) ) then
		ply:SetAchieveComplete( "Escape From Jail" )
	end
	if ( !ply:IsAchieveComplete( "Escape From Jail 10 Times" ) ) then
		ply:IncrementAchieveProgress( "Escape From Jail 10 Times", 1 )
		ply:DidAchieve( "Escape From Jail 10 Times" )
	end
end
hook.Add( "OnPlayerEscapeJail", "N00BRP_Achievements_OnPlayerEscapeJail", OnPlayerEscapeJail )

local function OnPlayerBuyProp( ply, model, propPrice )
	if ( !ply:IsAchieveComplete( "Spend 50k On Props" ) ) then
		ply:IncrementAchieveProgress( "Spend 50k On Props", propPrice )
		ply:DidAchieve( "Spend 50k On Props" )
	elseif ( !ply:IsAchieveComplete( "Spend 200k On Props" ) ) then
		ply:IncrementAchieveProgress( "Spend 200k On Props", propPrice )
		ply:DidAchieve( "Spend 200k On Props" )
	end
end
hook.Add( "OnPlayerBuyProp", "N00BRP_Achievements_OnPlayerBuyProp", OnPlayerBuyProp )

local function OnPlayerRobNPC( ply, npc, robReward )
	if ( !ply:IsAchieveComplete( "Rob A Shopkeeper" ) ) then
		ply:SetAchieveComplete( "Rob A Shopkeeper" )
	end
	if ( !ply:IsAchieveComplete( "Rob 10 Shopkeepers" ) ) then
		ply:IncrementAchieveProgress( "Rob 10 Shopkeepers", 1 )
		ply:DidAchieve( "Rob 10 Shopkeepers" )
	elseif ( !ply:IsAchieveComplete( "Rob 100 Shopkeepers" ) ) then
		ply:IncrementAchieveProgress( "Rob 100 Shopkeepers", 1 )
		ply:DidAchieve( "Rob 100 Shopkeepers" )
	end
end
hook.Add( "OnPlayerRobNPC", "N00BRP_Achievements_OnPlayerRobNPC", OnPlayerRobNPC )

local function OnPlayerKillNPC( ply, npc )
	if ( !ply:IsAchieveComplete( "Kill A Shopkeeper" ) ) then
		ply:SetAchieveComplete( "Kill A Shopkeeper" )
	end
	if ( !ply:IsAchieveComplete( "Kill 10 Shopkeepers" ) ) then
		ply:IncrementAchieveProgress( "Kill 10 Shopkeepers", 1 )
		ply:DidAchieve( "Kill 10 Shopkeepers" )
	elseif ( !ply:IsAchieveComplete( "Kill 100 Shopkeepers" ) ) then
		ply:IncrementAchieveProgress( "Kill 100 Shopkeepers", 1 )
		ply:DidAchieve( "Kill 100 Shopkeepers" )
	end
end
hook.Add( "OnPlayerKillNPC", "N00BRP_Achievements_OnPlayerKillNPC", OnPlayerKillNPC )

local function OnPlayerUseSoulOrb( ply )
	if ( !ply:IsAchieveComplete( "Use A Soul Orb" ) ) then
		ply:SetAchieveComplete( "Use A Soul Orb" )
	end
	if ( !ply:IsAchieveComplete( "Use 10 Soul Orbs" ) ) then
		ply:IncrementAchieveProgress( "Use 10 Soul Orbs", 1 )
		ply:DidAchieve( "Use 10 Soul Orbs" )
	elseif ( !ply:IsAchieveComplete( "Use 100 Soul Orbs" ) ) then
		ply:IncrementAchieveProgress( "Use 100 Soul Orbs", 1 )
		ply:DidAchieve( "Use 100 Soul Orbs" )
	end
end
hook.Add( "OnPlayerUseSoulOrb", "N00BRP_Achievements_OnPlayerUseSoulOrb", OnPlayerUseSoulOrb )

local function OnPlayerRobbedBank( ply )
	if ( !ply:IsAchieveComplete( "Rob The Bank" ) ) then
		ply:SetAchieveComplete( "Rob The Bank" )
	end
	if ( !ply:IsAchieveComplete( "Rob The Bank 10 Times" ) ) then
		ply:IncrementAchieveProgress( "Rob The Bank 10 Times", 1 )
		ply:DidAchieve( "Rob The Bank 10 Times" )
	elseif ( !ply:IsAchieveComplete( "Rob The Bank 100 Times" ) ) then
		ply:IncrementAchieveProgress( "Rob The Bank 100 Times", 1 )
		ply:DidAchieve( "Rob The Bank 100 Times" )
	end
end
hook.Add( "OnPlayerRobbedBank", "N00BRP_Achievements_OnPlayerRobbedBank", OnPlayerRobbedBank )

local function OnPlayerGetReputation( ply, class, amt )
	if not ( ply:IsAchieveComplete( "Get 100 Reputation" ) ) then
		local didAchieve = NOOBRP.Achievements[ "Get 100 Reputation" ].achieveFunc( ply, class )
		if ( didAchieve ) then
			ply:SetAchieveComplete( "Get 100 Reputation" )
		end
	end
end
hook.Add( "OnPlayerGetReputation", "N00BRP_Achievements_OnPlayerGetReputation", OnPlayerGetReputation )

local function OnPlayerUnearthGem( ply, gemType )
	if ( !ply:IsAchieveComplete( "Mine 500k Rocks" ) and gemType == 1 ) then
		ply:IncrementAchieveProgress( "Mine 500k Rocks", 1 )
		ply:DidAchieve( "Mine 500k Rocks" )
	end
end
hook.Add( "OnPlayerUnearthGem", "N00BRP_Achievements_OnPlayerUnearthGem", OnPlayerUnearthGem )

local function OnPlayerGatherHerb( ply, herbType, amt )
	if ( !ply:IsAchieveComplete( "Gather A Herb" ) ) then
		ply:SetAchieveComplete( "Gather A Herb" )
	end
	if ( !ply:IsAchieveComplete( "Gather A Valerian Root" ) and herbType == "Valerian Root" ) then
		ply:SetAchieveComplete( "Gather A Valerian Root" )
	elseif ( !ply:IsAchieveComplete( "Gather 50 Valerian Roots" ) and herbType == "Valerian Root" ) then
		ply:IncrementAchieveProgress( "Gather 50 Valerian Roots", amt )
		ply:DidAchieve( "Gather 50 Valerian Roots" )
	end
	if ( !ply:IsAchieveComplete( "Gather 10 Herbs" ) ) then
		ply:IncrementAchieveProgress( "Gather 10 Herbs", amt )
		ply:DidAchieve( "Gather 10 Herbs" )
	elseif ( !ply:IsAchieveComplete( "Gather 100 Herbs" ) ) then
		ply:IncrementAchieveProgress( "Gather 100 Herbs", amt )
		ply:DidAchieve( "Gather 100 Herbs" )
	elseif ( !ply:IsAchieveComplete( "Gather 1000 Herbs" ) ) then
		ply:IncrementAchieveProgress( "Gather 1000 Herbs", amt )
		ply:DidAchieve( "Gather 1000 Herbs" )
	end
end
hook.Add( "OnPlayerGatherHerb", "N00BRP_Achievements_OnPlayerGatherHerb", OnPlayerGatherHerb )

local function OnPlayerArrested( criminal, time, actor )
	if not ( IsValid( actor ) ) then return end
	if ( criminal:isArrested( ) ) then return end
	if ( !actor:IsAchieveComplete( "Make 100 Arrests" ) ) then
		actor:IncrementAchieveProgress( "Make 100 Arrests", 1 )
		actor:DidAchieve( "Make 100 Arrests" )
	elseif ( !actor:IsAchieveComplete( "Make 1000 Arrests" ) ) then
		actor:IncrementAchieveProgress( "Make 1000 Arrests", 1 )
		actor:DidAchieve( "Make 1000 Arrests" )
	end
end
hook.Add( "playerArrested", "N00BRP_Achievements_playerArrested", OnPlayerArrested )

local function OnPlayerCraftPotion( ply, potionName, potionAmount )
	if ( !ply:IsAchieveComplete( "Craft 25 Potions" ) ) then
		ply:IncrementAchieveProgress( "Craft 25 Potions", potionAmount )
		ply:DidAchieve( "Craft 25 Potions" )
	elseif ( !ply:IsAchieveComplete( "Craft 100 Potions" ) ) then
		ply:IncrementAchieveProgress( "Craft 100 Potions", potionAmount )
		ply:DidAchieve( "Craft 100 Potions" )
	elseif ( !ply:IsAchieveComplete( "Craft 1000 Potions" ) ) then
		ply:IncrementAchieveProgress( "Craft 1000 Potions", potionAmount )
		ply:DidAchieve( "Craft 1000 Potions" )
	end
end
hook.Add( "OnPlayerCraftPotion", "N00BRP_Achievements_OnPlayerCraftPotion", OnPlayerCraftPotion )

local function OnBeastLairCleared( plyTable )
	for index, ply in ipairs ( plyTable ) do
		if ( !ply:IsAchieveComplete( "Clear The Beast Lair" ) ) then
			ply:SetAchieveComplete( "Clear The Beast Lair" )
		end
	end
end
hook.Add( "OnBeastLairWon", "N00BRP_Achievements_OnBeastLairCleared", OnBeastLairCleared )

local function OnBeastLairPortalOpened( plyTable, beastPortal )
	for index, ply in ipairs ( plyTable ) do
		if ( !ply:IsAchieveComplete( "Open the Beast Lair Portal" ) ) then
			ply:SetAchieveComplete( "Open the Beast Lair Portal" )
		end
		if ( !ply:IsAchieveComplete( "Open the Beast Lair Portal 5 Times" ) ) then
			ply:IncrementAchieveProgress( "Open the Beast Lair Portal 5 Times", 1 )
			ply:DidAchieve( "Open the Beast Lair Portal 5 Times" )
		end
	end
end
hook.Add( "OnBeastPortalOpened", "N00BRP_Achievements_OnBeastLairPortalOpened", OnBeastLairPortalOpened )

// These hooks below may come in handy for achievements.
//hook.Call( "OnPlayerGetRevenge", { }, attacker, victim )
//hook.Call( "OnBeastEventEnd", { }, foundWinner.ent, foundWinner.dmg, foundSecondPlace.ent, foundSecondPlace.dmg )
//hook.Call( "OnPlayerRobbedBank", { }, robber )
//hook.Call( "OnCrabQueenEvolve", { }, self )
//hook.Call( "OnQuestComplete", { }, self, self.currentQuest.name )
//hook.Call( "OnPlayerRevokePacifism", { }, self )
//hook.Call( "OnPlayerPacifism", { }, self )
//hook.Call( "OnPlayerPurgeKill", { }, attacker, victim, true ) -- true if civilian kill
//hook.Call( "OnPlayerCraftGems", { }, self )
//hook.Call( "OnDrillGemDrop", { }, self:Getowning_ent( ), gemType )
//hook.Call( "OnPlagueCanisterMade", { }, self:Getowning_ent( ) )
//hook.Call( "OnPlayerUseSoulOrb", { }, ply )
//hook.Call( "OnPlayerUnearthGem", { }, self.Owner, gemType )
//hook.Call( "OnPlayerGatherHerb", { }, ply, herbType, extraHerbs )
//hook.Call( "OnPlayerGatherMushroom", { }, ply, shroomType )
//hook.Call( "OnPlayerCraftPotion", { }, ply, args[1], potionAmount )
//hook.Call( "OnPlayerKillBankRobber", { }, attacker, victim )
//hook.Call( "OnPlayerKillClanEnemy", { }, attacker, victim )
//hook.Call( "OnPlayerArrestBankRobber", { }, arrester, bank.GetRobber )
//hook.Call( "OnPlayerEscapeJail", { }, pl )
//hook.Call( "OnPlayerBuyProp", { }, ply, model, propPrice )
//hook.Call( "OnPlayerGetReputation", { }, self, class, amt )
//hook.Call( "OnPlayerKillNPC", { }, attacker, self )
//hook.Call( "OnPlayerRobNPC", { }, ply, self, robReward )
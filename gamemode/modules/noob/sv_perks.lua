// Basically, the main reason I used JSON to store the perk tree information wasn't because I was too lazy to make tables and columns for it in the database.
// Using this method, we can add more perks later on without needing to add new columns to the said database table.
// Besides, the perk trees won't really ever be browsed when surfing the mySQL database.

util.AddNetworkString( "noob_playerperks" );

local perksDir = "noob/playerperks/"
local pmeta = FindMetaTable( "Player" ); 

function pmeta:PlayerResetPerks( )
	self:setSelfDarkRPVar( "PlayerPerks", { } )
	local bonusPerks = self:getDarkRPVar( "BonusPerks" )
	local bonusPoints = 0
	if ( istable( bonusPerks ) ) then
		bonusPoints = bonusPerks.maximum or 0
	end
	self:UpdateBonusPerkPoints( bonusPoints )
	self:UpdatePerkPoints( self:CalculateMaxPerkPoints( ) )
	file.Write( perksDir .. self:SteamID64( ) .. ".txt", util.TableToJSON( { } ) )
end

function pmeta:CalculateMaxPerkPoints( )
	local enduranceLevel = NOOBRP_SkillAlgorithms:CalculateEndurance( self )["CurrentLevel"]
	local perkPoints = math.Clamp( math.floor( enduranceLevel / 5 ), 0, 7 )
	local bonusPoints = self:getDarkRPVar( "BonusPerks" ) or 0
	return perkPoints
end

function pmeta:CalculateSpentPerkPoints( )
	local bonusPerks = self:getDarkRPVar( "BonusPerks" )
	local unSpentBonus, maxBonus = 0, 0
	if ( istable( bonusPerks ) ) then
		unSpentBonus = bonusPerks.unspent or 0
		maxBonus = bonusPerks.maximum or 0
	end
	local spentPoints = 0
	for tree, amt in pairs ( self:getDarkRPVar( "PlayerPerks" ) ) do
		spentPoints = spentPoints + amt
	end
	if ( spentPoints > 0 ) then
		if ( maxBonus ~= 0 and unSpentBonus ~= maxBonus ) then
			local totalBonusSpent = math.abs( unSpentBonus - maxBonus )
			spentPoints = spentPoints - totalBonusSpent
		end
	end
	return spentPoints
end

function pmeta:AttemptPerkPointReward( )
	local maxPoints = self:CalculateMaxPerkPoints( )
	local spentPoints = self:CalculateSpentPerkPoints( )
	local unspentPoints = tonumber( self:getDarkRPVar( "PlayerPerkPoints" ) )
	if ( spentPoints + unspentPoints < maxPoints ) then
		self:UpdatePerkPoints( unspentPoints + 1 )
		self:ChatPrint( "You have received an additional perk point." )
	end
end

function pmeta:RetrievePerkPoints( )
	local perkPoints = self:getDarkRPVar( "PlayerPerkPoints" )
	if not ( perkPoints ) then
		mySQLControl:ColumnValueExists( "darkrp_perkpoints", "uniqueid", self:SafeUniqueID( ), function( data )
			if ( #data > 0 ) then
				self:setSelfDarkRPVar( "PlayerPerkPoints", data[1].amount )
			else
				mySQLControl:InsertInto( "darkrp_perkpoints", { self:SafeUniqueID( ), 0 } )
				self:setSelfDarkRPVar( "PlayerPerkPoints", 0 )
			end
		end )
	end
	self:setSelfDarkRPVar( "PlayerPerks", util.JSONToTable( ( file.Read( perksDir .. self:SteamID64( ) .. ".txt", "DATA" ) ) or "[]" ) )
end

function pmeta:HasPerkPoint( cback )
	local perkPoints = self:getDarkRPVar( "PlayerPerkPoints" )
	if not ( perkPoints ) then -- Just for precaution.
		mySQLControl:ColumnValueExists( "darkrp_perkpoints", "uniqueid", self:SafeUniqueID( ), function( data )
			if ( #data > 0 ) then
				self:setSelfDarkRPVar( "PlayerPerkPoints", data[1].amount )
				cback( ( data[1].amount > 0 ) )
			else
				mySQLControl:InsertInto( "darkrp_perkpoints", { self:SafeUniqueID( ), 0 } )
				self:setSelfDarkRPVar( "PlayerPerkPoints", 0 )
				cback( true )
			end
		end )
		return
	end
	if ( perkPoints > 0 ) then
		cback( true )
	else
		cback( false )
	end
end

function pmeta:UpdatePerkPoints( amt )
	self:setSelfDarkRPVar( "PlayerPerkPoints", amt )
	mySQLControl:UpdateRow( "darkrp_perkpoints", { "amount = " .. amt }, { "uniqueid = " .. self:SafeUniqueID( ) } )
end

function pmeta:GetBonusPerkPoints( )
	local bonusPerksData = self:getDarkRPVar( "BonusPerks" )
	local points, max = 0, 0
	if ( istable( bonusPerksData ) ) then
		points = bonusPerksData.unspent or 0
		max = bonusPerksData.maximum or 0
	end
	return points, max
end

function pmeta:AwardBonusPerkPoint( printMes )
	mySQLControl:Query( "UPDATE darkrp_bonusperks SET points = points + 1, max = max + 1 WHERE uniqueid = " .. self:SafeUniqueID( ) .. ";", function( ) end )
	local points, maxPoints = self:GetBonusPerkPoints( )
	self:setSelfDarkRPVar( "BonusPerks", { unspent = points + 1, maximum = maxPoints + 1 } )
	if not ( printMes ) then return end
	self:ChatPrint( "You've been awarded a bonus perk point! Congratulations!" )
end

function pmeta:UpdateBonusPerkPoints( amt )
	local points, maxPoints = self:GetBonusPerkPoints( )
	self:setSelfDarkRPVar( "BonusPerks", { unspent = amt, maximum = maxPoints } )
	mySQLControl:UpdateRow( "darkrp_bonusperks", { "points = " .. amt }, { "uniqueid = " .. self:SafeUniqueID( ) } )
end

function pmeta:SetPerk( perk, level )
	local currentPerks = self:getDarkRPVar( "PlayerPerks" ) or { }
	if ( currentPerks == 1 ) then currentPerks = { } end
	currentPerks[perk] = level
	self:setSelfDarkRPVar( "PlayerPerks", currentPerks )
	file.Write( perksDir .. self:SteamID64( ) .. ".txt", util.TableToJSON( currentPerks ) )
end

function pmeta:HasPerk( perk, level )
	local currentPerks = self:getDarkRPVar( "PlayerPerks" ) or { }
	if not ( currentPerks[perk] ) then return false end
	if ( currentPerks[perk] >= level ) then
		return true
	else
		return false
	end
end

function pmeta:HasPerksInTree( perk )
	local currentPerks = self:getDarkRPVar( "PlayerPerks" ) or { }
	if not ( currentPerks[perk] ) then return false end
	return currentPerks[perk]
end

function pmeta:CanSetPerk( perk, level )
	local currentPerks = self:getDarkRPVar( "PlayerPerks" ) or { }
	if ( currentPerks[perk] and currentPerks[perk] >= level ) then
		return false, "You already have that perk."
	elseif ( ( level > 1 ) and ( !currentPerks[perk] or currentPerks[perk] < ( level - 1 ) ) ) then
		return false, "You lack the required perks within this tree to select that one."
	end
	return true
end

function pmeta:CanBuff( )
	self.nextBuffCommand = self.nextBuffCommand or 0
	//if ( self:getDarkRPVar( "IsGhost" ) ) then return false end
	if ( self:IsGhost( ) ) then return false end
	if ( self.nextBuffCommand > CurTime( ) ) then
		DarkRP.notify( self, 1, 4, "You cannot use that skill for another " .. string.NiceTime( self.nextBuffCommand - CurTime( ) ) )
		return false
	end
	self.nextBuffCommand = CurTime( ) + 120
	return true
end

net.Receive( "noob_playerperks", function( len, pl )
	local tab = net.ReadTable();
	local canSet, errorMsg = pl:CanSetPerk( tab.tree, tab.rank )
	if ( canSet ) then
		pl:HasPerkPoint( function( bool )
			if ( bool ) then
				pl:SetPerk( tab.tree, tab.rank )
				DarkRP.notify( pl, 3, 4, "You've unlocked Rank " .. tab.rank .. " in the " .. tab.tree .. " Tree!" )
				pl:UpdatePerkPoints( pl:getDarkRPVar( "PlayerPerkPoints") - 1 )
			else
				local bonusPerks = pl:getDarkRPVar( "BonusPerks" )
				local bonusPoints = 0
				if ( istable( bonusPerks ) ) then
					bonusPoints = bonusPerks.unspent or 0
				end
				if ( bonusPoints > 0 ) then
					pl:SetPerk( tab.tree, tab.rank )
					DarkRP.notify( pl, 3, 4, "You've unlocked Rank " .. tab.rank .. " in the " .. tab.tree .. " Tree!" )
					pl:UpdateBonusPerkPoints( bonusPerks.unspent - 1 )
				else
					DarkRP.notify( pl, 1, 4, "You have no more perk points." )
				end
			end
		end )
	else
		DarkRP.notify( pl, 1, 4, errorMsg )
	end
end )

DarkRP.defineChatCommand( "perks", function( ply, args )
	ply:ConCommand( "noob_perktree" );
end );

function pmeta:ScalePerkDamage( name, level, dmgInfo )
	if ( level <= 4 ) then
		NOOB_PERK_TREE[ name ][ level ].func( dmgInfo )
	else
		NOOB_PERK_TREE[ name ][4].func( dmgInfo )
	end
end


function pmeta:ScaleEntityDamage( ent, dmgInfo )
	local attackerAttackPerkLevel = self:HasPerksInTree( "Offensive Perks" )
	local attackerDefensePerkLevel = self:HasPerksInTree( "Defensive Perks" )
	if ( attackerAttackPerkLevel ) then
		self:ScalePerkDamage( "Offensive Perks", attackerAttackPerkLevel, dmgInfo )
	end
	if ( self.currentBuff == "OffensiveAura" ) then dmgInfo:ScaleDamage( 1.4 ) end
	if ( attackerDefensePerkLevel ) then
		self:ScalePerkDamage( "Defensive Perks", attackerDefensePerkLevel, dmgInfo )
	end
	if ( self.currentBuff == "DefensiveAura" ) then dmgInfo:ScaleDamage( 0.6 ) end
	if ( ent.currentBuff == "DefensiveAura" ) then dmgInfo:ScaleDamage( 0.6 ) end
end

local function ScaleMeleeDamage( wep, dmgInfo, ent )
	local meleeDamageMultiTable = SVNOOB_VARS:Get( "MeleeWeaponMultipliers", true )
	if ( IsValid( wep ) and IsValid( ent ) ) then
		if ( meleeDamageMultiTable[ wep:GetClass( ) ] ) then
			if ( ent:IsPlayer( ) ) then
				dmgInfo:ScaleDamage( meleeDamageMultiTable[ wep:GetClass( ) ].ply )
			else
				dmgInfo:ScaleDamage( meleeDamageMultiTable[ wep:GetClass( ) ].prop )
			end
			//print( wep:GetClass( ) .. " : " .. ent:GetClass( ) .. " : " .. dmgInfo:GetDamage( ) )
		end
	end
end

hook.Add( "ScalePlayerDamage", "AttackPerkDamage", function( pl, hitgroup, dmgInfo )
	if not ( dmgInfo:GetAttacker( ):IsPlayer( ) ) then return end
	--local wep = dmgInfo:GetAttacker( ):GetActiveWeapon( )
	--ScaleMeleeDamage( wep, dmgInfo, pl )
	local attacker = dmgInfo:GetAttacker( )
	local attackerAttackPerkLevel = attacker:HasPerksInTree( "Offensive Perks" )
	local attackerDefensePerkLevel =attacker:HasPerksInTree( "Defensive Perks" )
	if ( attackerAttackPerkLevel ) then
		attacker:ScalePerkDamage( "Offensive Perks", attackerAttackPerkLevel, dmgInfo )
	end
	if ( attackerDefensePerkLevel ) then
		attacker:ScalePerkDamage( "Defensive Perks", attackerDefensePerkLevel, dmgInfo )
	end
	if ( attacker.currentBuff == "OffensiveAura" ) then dmgInfo:ScaleDamage( 1.4 ) end
	local victimAttackPerkLevel = pl:HasPerksInTree( "Offensive Perks" )
	local victimDefensePerkLevel = pl:HasPerksInTree( "Defensive Perks" )
	if ( victimAttackPerkLevel ) then
		pl:ScalePerkDamage( "Offensive Perks", victimAttackPerkLevel, dmgInfo )
	end
	if ( victimDefensePerkLevel ) then
		pl:ScalePerkDamage( "Defensive Perks", victimDefensePerkLevel, dmgInfo )
	end
	if ( pl.currentBuff == "DefensiveAura" ) then dmgInfo:ScaleDamage( 0.6 ) end
end  )

local function PerkEntityDamage( ent, dmgInfo )
	if ( ent.IsGodded and ent:IsGodded( ) ) then dmgInfo:ScaleDamage( 0 ) return end
	local attacker = dmgInfo:GetAttacker( )
	if ( !IsValid( attacker ) or !attacker:IsPlayer( ) ) then return end
	local wep = attacker:GetActiveWeapon( )
	/*if ( IsValid( wep ) and ( ent:GetClass( ) == "prop_physics" or ent:IsPlayer( ) ) ) then
		ScaleMeleeDamage( wep, dmgInfo, ent )
	end*/
	if ( !IsValid( ent ) or ( !ent:GetClass( ) == "prop_physics" and !ent:IsVehicle( ) ) ) then return end
	if ( ent:IsPlayer( ) ) then return end
end
hook.Add( "EntityTakeDamage", "N00BRP_PerkEntityDamage_EntityTakeDamage", PerkEntityDamage )

local function RP_HealAll( plr, cmd, args, fstring )
	if not ( plr:HasPerk( "Healing Perks", 4 ) ) then return end
	if not ( plr:CanBuff( ) ) then return end
	plr:SayMessage( CHAT_PLAYER_ME, "surrounds everyone around them with their Healing Aura." )
	local foundEnts = ents.FindInBox( plr:GetPos( ) - Vector( 128, 128, 128 ), plr:GetPos( ) + Vector( 128, 128, 128 ) )
	for index, ent in ipairs ( foundEnts ) do
		//if ( !IsValid( ent ) or !ent:IsPlayer( ) or ent:getDarkRPVar( "IsGhost" ) ) then continue end
		if ( !IsValid( ent ) or !ent:IsPlayer( ) or ent:IsGhost( ) ) then continue end
		ent:SetHealth( math.Clamp( ent:Health( ) + 100, 0, ent:GetMaxHealth( ) ) )
		effectTable = { lifeTime = "1", spawnRadius = "25", minSpeed = "25", maxSpeed = "50", spawnRate = "25", startSize = "80", startColor = "25 25 175", endColor = "0 0 125" }
		util.CreateSmokeClouds( effectTable, plr:EyePos( ) - Vector( 0, 0, 16 ), nil )
	end
end
concommand.Add( "rp_healall", RP_HealAll )

local function RP_TeamAttack( plr, cmd, args, fstring )
	if not ( plr:HasPerk( "Offensive Perks", 5 ) ) then return end
	if not ( plr:CanBuff( ) ) then return end
	plr:SayMessage( CHAT_PLAYER_ME, "surrounds everyone around them with their Offensive Aura." )
	local foundPlayers = { }
	timer.Simple( 0.1, function( )
		if not ( IsValid( plr ) ) then return end
		local foundEnts = ents.FindInBox( plr:GetPos( ) - Vector( 128, 128, 128 ), plr:GetPos( ) + Vector( 128, 128, 128 ) )
			for index, ent in ipairs ( foundEnts ) do
			//if ( !IsValid( ent ) or !ent:IsPlayer( ) or ent:getDarkRPVar( "IsGhost" ) ) then continue end
			if ( !IsValid( ent ) or !ent:IsPlayer( ) or ent:IsGhost( ) ) then continue end
			if ( ent.currentBuff ) then ent:ChatPrint( "The Offensive Aura overpowers your existing aura." ) end
			ent:SetRenderMode( RENDERMODE_TRANSCOLOR )
			ent:SetMaterial( "models/shiny" )
			ent:setDarkRPVar( "PlayerColorMod", { r = 175, g = 25, b = 25, a = 255 } )
			ent.currentBuff = "OffensiveAura"
			table.insert( foundPlayers, ent )
		end
		effectTable = { lifeTime = "1", spawnRadius = "25", minSpeed = "25", maxSpeed = "50", spawnRate = "25", startSize = "80", startColor = "175 25 25", endColor = "125 0 0" }
		util.CreateSmokeClouds( effectTable, plr:EyePos( ) - Vector( 0, 0, 16 ), nil )
	end )
	timer.Simple( 10, function( )
		for index, ply in ipairs ( foundPlayers ) do
			if ( !IsValid( ply ) or ply.currentBuff ~= "OffensiveAura" ) then continue end
			ply:SetMaterial( "" )
			ply:setDarkRPVar( "PlayerColorMod", nil )
			ply.currentBuff = nil
			ply:ChatPrint( "The Offensive Aura has diminished, you feel normal again." )
		end
	end )
end
concommand.Add( "rp_teamattack", RP_TeamAttack )

local function RP_TeamDefense( plr, cmd, args, fstring )
	if not ( plr:HasPerk( "Defensive Perks", 5 ) ) then return end
	if not ( plr:CanBuff( ) ) then return end
	plr:SayMessage( CHAT_PLAYER_ME, "surrounds everyone around them with their Defensive Aura." )
	local foundPlayers = { }
	local foundEnts = { }
	util.ExecuteDelayedFunction( plr, 0.1, function( plr )
		local foundEnts = ents.FindInBox( plr:GetPos( ) - Vector( 128, 128, 128 ), plr:GetPos( ) + Vector( 128, 128, 128 ) )
		for index, ent in ipairs ( foundEnts ) do
			/*if ( IsValid( ent ) and ent:GetClass( ) == "prop_physics" ) then
				ent.currentBuff = "DefensiveAura"
				ent:SetMaterial( "debug/env_cubemap_model" )
				table.insert( foundEnts, ent )
			end*/
			//if ( !IsValid( ent ) or !ent:IsPlayer( ) or ent:getDarkRPVar( "IsGhost" ) ) then continue end
			if ( !IsValid( ent ) or !ent:IsPlayer( ) or ent:IsGhost( ) ) then continue end
			if ( ent.currentBuff ) then ent:ChatPrint( "The Defensive Aura overpowers your existing aura." ) end
			ent:SetRenderMode( RENDERMODE_TRANSCOLOR )
			ent:SetMaterial( "models/shiny" )
			ent:setDarkRPVar( "PlayerColorMod", { r = 25, g = 25, b = 25, a = 255 } )
			ent.currentBuff = "DefensiveAura"
			table.insert( foundPlayers, ent )
		end
		effectTable = { lifeTime = "1", spawnRadius = "25", minSpeed = "25", maxSpeed = "50", spawnRate = "25", startSize = "80", startColor = "25 25 25", endColor = "0 0 0" }
		util.CreateSmokeClouds( effectTable, plr:EyePos( ) - Vector( 0, 0, 16 ), nil )
	end, plr )
	timer.Simple( 10, function( )
		for index, ply in ipairs ( foundPlayers ) do
			if ( !IsValid( ply ) or ply.currentBuff ~= "DefensiveAura" ) then continue end
			ply:SetMaterial( "" )
			ply:setDarkRPVar( "PlayerColorMod", nil )
			ply.currentBuff = nil
			ply:ChatPrint( "The Defensive Aura has diminished, you feel normal again." )
		end
		/*for index, ent in ipairs ( foundEnts ) do
			if ( !IsValid( ent ) or ent:GetClass( ) ~= "prop_physics" or ent.currentBuff ~= "DefensiveAura" ) then continue end
			ent:SetMaterial( "" )
			ent.currentBuff = nil
		end*/
	end )
end
concommand.Add( "rp_teamdefense", RP_TeamDefense )

local function RP_TeamSprint( plr, cmd, args, fstring )
	if not ( plr:HasPerk( "Running Speed Perks", 5 ) ) then return end
	if not ( plr:CanBuff( ) ) then return end
	plr:SayMessage( CHAT_PLAYER_ME, "surrounds everyone around them with their Running Boost Aura." )
	local foundPlayers = { }
	util.ExecuteDelayedFunction( plr, 0.1, function( plr )
		local foundEnts = ents.FindInBox( plr:GetPos( ) - Vector( 128, 128, 128 ), plr:GetPos( ) + Vector( 128, 128, 128 ) )
		for index, ent in ipairs ( foundEnts ) do
			//if ( IsValid( ent ) and ent:IsPlayer( ) and !ent:getDarkRPVar( "IsGhost" ) ) then
			if ( IsValid( ent ) and ent:IsPlayer( ) and !ent:IsGhost( ) ) then
				if ( ent.currentBuff ) then ent:ChatPrint( "The Running Boost Aura overpowers your existing aura." ) end
				ent:SetRenderMode( RENDERMODE_TRANSCOLOR )
				ent:SetMaterial( "models/props_combine/portalball001_sheet" )
				ent:setDarkRPVar( "PlayerColorMod", { r = 255, g = 255, b = 255, a = 255 } )
				ent.currentBuff = "SprintingAura"
				ent:BoostRunSpeed( 1.5 )
				if ( IsValid( ent.sprintingSpriteTrail ) ) then
					SafeRemoveEntity( ent.sprintingSpriteTrail )
				end
				ent.sprintingSpriteTrail = util.SpriteTrail( ent, 3, Color( 125, 125, 255 ), false, 50, 25, 2, 0.5, "trails/plasma.vmt" )
				table.insert( foundPlayers, ent )
			end
		end
		effectTable = { lifeTime = "1", spawnRadius = "25", minSpeed = "25", maxSpeed = "50", spawnRate = "25", startSize = "80", startColor = "228 241 254", endColor = "255 255 255" }
		util.CreateSmokeClouds( effectTable, plr:EyePos( ) - Vector( 0, 0, 16 ), nil )
	end, plr )
	timer.Simple( 10, function( )
		for index, ply in ipairs ( foundPlayers ) do
			if ( !IsValid( ply ) ) then continue end
			ply:ApplyMovementSpeed( )
			if ( IsValid( ply.sprintingSpriteTrail ) ) then SafeRemoveEntity( ply.sprintingSpriteTrail ) end
			if ( ply.currentBuff ~= "SprintingAura" ) then continue end
			ply:SetMaterial( "" )
			ply:setDarkRPVar( "PlayerColorMod", nil )
			ply.currentBuff = nil
			ply:ChatPrint( "The Running Boost Aura has diminished, you feel normal again." )
		end
	end )
end
concommand.Add( "rp_teamsprint", RP_TeamSprint )

local function RP_Stealth( ply, cmd, args, fstring )
	if not ( ply:HasPerk( "Stealth Perks", 1 ) ) then return end
	if not ( ply:CanBuff( ) ) then return end
	ply.nextBuffCommand = CurTime() + 30
	local baseFolder = "stealthperk_sounds/"
	local stealthPerkSounds = { "stealth1", "stealth2", "stealth3", "stealth6" }
	ply:EmitSound( baseFolder .. stealthPerkSounds[ math.random( #stealthPerkSounds ) ] .. ".wav" )
	ply:SayMessage( CHAT_PLAYER_ME, "slips into the shadows." )
	local perkCount = ply:HasPerksInTree( "Stealth Perks" )
	ply:setDarkRPVar( "IsStealthed", true )
	ply.stealthSpriteTrail = util.SpriteTrail( ply, 3, Color( 65, 65, 65 ), false, 10, 5, 0.25, 0.5, "trails/smoke.vmt" )
	effectTable = { lifeTime = "1", spawnRadius = "25", minSpeed = "25", maxSpeed = "50", spawnRate = "25", startSize = "80", startColor = "125 125 125", endColor = "75 75 75" }
	util.CreateSmokeClouds( effectTable, ply:EyePos( ) - Vector( 0, 0, 16 ), nil )
	timer.Simple( NOOB_PERK_TREE["Stealth Perks"][perkCount].time, function( )
		if not ( IsValid( ply ) ) then return end
		ply:ChatPrint( "Your stealth has worn off." )
		ply:setDarkRPVar( "IsStealthed", false )
		if ( IsValid( ply.stealthSpriteTrail ) ) then
			SafeRemoveEntity( ply.stealthSpriteTrail )
		end
	end )
end
concommand.Add( "rp_stealth", RP_Stealth )
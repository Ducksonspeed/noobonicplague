local meta = FindMetaTable( "Player" )

-- Important Enums, needs to be accessable from the entire gamemode.
CHAT_PLAYER_SAY = 1
CHAT_PLAYER_YELL = 2
CHAT_PLAYER_ME = 3
CHAT_PLAYER_WHISPER = 4

local availablePermas = { "backpack", "pikachu_hat", "golden_beast_hat" }
function meta:GiveBeastLairReward( )
	self:DisplayNotify("You receive a bounty of $10,000 for killing the Beast.", 6, "icon16/heart.png", COLOR_WHITE, nil, true, "N00BRP_2DIndicator_LobsterMiniText")
	self:addMoney(10000)
	local randomChance = math.random( 1, 100 )
	print( self:Name() .. " (" .. self:SteamID() .. ") had a beast lair roll of: " .. randomChance )
	if ( randomChance <= 30 ) then -- 30% chance you get nothing
		self:DisplayNotify( "You were awarded ... ABSOLUTELY NOTHING! God really does hate you.", 6, "icon16/heart.png", COLOR_WHITE, nil, true, "N00BRP_2DIndicator_LobsterMiniText" )
		return
	elseif ( randomChance <= 90 ) then -- 60% chance you get your obby back
		self:GiveGem( "Obsidians", 1 )
		self:DisplayNotify( "You were returned your Obsidian!", 6, "icon16/heart.png", COLOR_WHITE, nil, true, "N00BRP_2DIndicator_LobsterMiniText" )
	else -- 10% chance for a perm/diamond
		local wantedPerms = {}
		for k,v in pairs( availablePermas ) do
			if ( !self:HasWeaponStored( v ) ) then
				table.insert( wantedPerms, v )
			end
		end
		if ( #wantedPerms == 0 ) then -- already has perms
			local secondChance = math.random(1, 10) -- 10% chance for a diamond, 10% chance after 10% chance = 1% chance overall for diamond if already have all perms
			if ( secondChance == 7 ) then
				self:GiveGem( "Diamonds", 1 )
				self:DisplayNotify( "A Diamond. You got a Diamond. No, rly. A fucking Diamond.", 6, "icon16/heart.png", COLOR_WHITE, nil, true, "N00BRP_2DIndicator_LobsterMiniText" )
			else -- give them their obby back anyway
				self:GiveGem( "Obsidians", 1 )
				self:DisplayNotify( "You were returned your Obsidian!", 6, "icon16/heart.png", COLOR_WHITE, nil, true, "N00BRP_2DIndicator_LobsterMiniText" )
			end
		else
			local permReward = wantedPerms[ math.random( #wantedPerms ) ]
			self:GivePermWeapon( permReward )
			self:DisplayNotify( "You were rewarded a Permanent " .. permReward .. "!", 6, "icon16/heart.png", COLOR_WHITE, nil, true, "N00BRP_2DIndicator_LobsterMiniText" )
		end
	end
end

function meta:HasPrintersInBackpack( )
	self.printerBackpack = self.printerBackpack or { }
	if ( #self.printerBackpack > 0 ) then
		return true
	else
		return false
	end
end

function meta:HasRoomInBackpack( )
	self.printerBackpack = self.printerBackpack or { }
	if ( #self.printerBackpack >= SVNOOB_VARS:Get( "BackpackPrinterLimit", true, "number", 2 ) ) then 
		return false
	else
		return true
	end
end

function meta:StorePrinterInBackpack( ent )
	self.printerBackpack = self.printerBackpack or { }
	if ( ent:GetClass( ) == "basic_money_printer" ) then
		local owningEnt = nil
		if ( ent.Getowning_ent and IsValid( ent:Getowning_ent( ) ) ) then
			owningEnt = ent:Getowning_ent( )
		end
		local ownerSteamID = ent.ownerSteamID
		table.insert( self.printerBackpack, {
			class = ent:GetClass( ),
			model = ent:GetModel( ),
			power = ent:GetPower( ),
			ink = ent:GetInk( ),
			cpu = ent:GetCPU( ),
			owner = owningEnt,
			ownerSteamID = ownerSteamID
		} )
		if ( IsValid( owningEnt ) ) then
			owningEnt:AddToBackpackEntities( ent:GetClass( ) )
		end
		SafeRemoveEntity( ent )
	elseif ( ent:GetClass( ) == "adv_money_printer" ) then
		local owningEnt = nil
		if ( ent.Getowning_ent and IsValid( ent:Getowning_ent( ) ) ) then
			owningEnt = ent:Getowning_ent( )
		end
		local ownerSteamID = ent.ownerSteamID
		table.insert( self.printerBackpack, {
			class = ent:GetClass( ),
			model = ent:GetModel( ),
			power = ent:GetPower( ),
			ink = ent:GetInk( ),
			cpu = ent:GetCPU( ),
			ram = ent:GetRAM( ),
			coolant = ent:GetCoolant( ),
			owner = owningEnt,
			ownerSteamID = ownerSteamID
		} )
		if ( IsValid( owningEnt ) ) then
			owningEnt:AddToBackpackEntities( ent:GetClass( ) )
		end
		SafeRemoveEntity( ent )
	end
	self:SuccessNotify( "You put a " .. ent:GetClass( ) .. " in your backpack." )
	self:SuccessNotify( "Type /dropprinter to drop it." )
end

function meta:DropAllPrintersFromBackpack( pos )
	local pos = pos
	if not ( pos ) then pos = self:GetPos( ) + Vector( 0, 0, 10 ) end
	if ( self:HasPrintersInBackpack( ) ) then
		for i=1, #self.printerBackpack do
			self:RetrievePrinterFromBackpack( pos, true )
		end
	end
end

function meta:RetrievePrinterFromBackpack( pos, noMessage )
	self.printerBackpack = self.printerBackpack or { }
	if ( istable( self.printerBackpack ) and #self.printerBackpack > 0 ) then
		local printerTable = self.printerBackpack[1]
		local traceRes = self:RangeEyeTrace( 80 )
		local pos = pos
		if not ( pos ) then pos = traceRes.HitPos end
		local moneyPrinter = ents.Create( printerTable.class )
		moneyPrinter:SetPos( pos )
		moneyPrinter:Spawn( )
		moneyPrinter:SetPower( printerTable.power )
		moneyPrinter:SetInk( printerTable.ink )
		moneyPrinter:SetCPU( printerTable.cpu )
		if ( printerTable.class == "adv_money_printer" ) then
			moneyPrinter:SetRAM( printerTable.ram )
			moneyPrinter:SetCoolant( printerTable.coolant )
		end
		moneyPrinter:Setowning_ent( printerTable.owner )
		moneyPrinter.ownerSteamID = printerTable.ownerSteamID
		local entOwner = printerTable.owner
		if ( IsValid( entOwner ) ) then
			entOwner:RemoveFromBackpackEntities( printerTable.class )
		end
		table.remove( self.printerBackpack, 1 )
		if not ( noMessage ) then
			self:SuccessNotify( "You took a " .. printerTable.class .. " out of your backpack." )
		end
	end
end

function meta:AddToBackpackEntities( class, amt )
	self.backpackEntities = self.backpackEntities or { }
	self.backpackEntities[ class ] = self.backpackEntities[ class ] or 0
	self.backpackEntities[ class ] = self.backpackEntities[ class ] + ( tonumber( amt ) or 1 )
end

function meta:RemoveFromBackpackEntities( class, amt )
	self.backpackEntities = self.backpackEntities or { }
	if not ( self.backpackEntities[ class ] ) then return end
	self.backpackEntities[ class ] = self.backpackEntities[ class ] - ( tonumber( amt ) or 1 )
	if ( self.backpackEntities[ class ] == 0 ) then
		self.backpackEntities[ class ] = nil
	end
end

function meta:GetBackpackEntityClassAmount( class )
	local furtherCheck = false
	if not ( self.backpackEntities ) then furtherCheck = true end
	if ( self.backpackEntities and !self.backpackEntities[ class ] ) then furtherCheck = true end
	local entityCount = 0
	if ( furtherCheck ) then
		for index, ply in ipairs ( player.GetAll( ) ) do
			if ( istable( ply.printerBackpack ) and #ply.printerBackpack > 0 ) then
				for index, entTable in ipairs ( ply.printerBackpack ) do
					if ( entTable.owner == self and entTable.class == class ) then
						entityCount = entityCount + 1
					end
				end
			end
		end
		self:AddToBackpackEntities( class, entityCount )
		return entityCount
	else
		return self.backpackEntities[ class ]
	end
end

function meta:HasMoneyPrintersInBackpack( )
	local basicCount = self:GetBackpackEntityClassAmount( "basic_money_printer" )
	local advCount = self:GetBackpackEntityClassAmount( "adv_money_printer" )
	local defaultCount = self:GetBackpackEntityClassAmount( "money_printer" )
	return ( basicCount ~= 0 or advCount ~= 0 or defaultCount ~= 0 )
end

function meta:SetRespawnTime( time, plyTable )
	self.respawnTimeDelay = time
	self.timeUntilRespawn = CurTime( ) + time
	net.Start( "N00BRP_RespawnTimer" )
		net.WriteEntity( self )
		net.WriteUInt( time, 16 )
	net.Send( plyTable )
end

function meta:ToggleGhostMode( status, plyTable )
	self.ghostModeStatus = status
	net.Start( "N00BRP_GhostModeToggle" )
		net.WriteEntity( self )
		net.WriteBool( status )
	net.Send( plyTable )
end

function meta:RetrieveCurrentGhosts( )
	for index, ply in ipairs ( player.GetAll( ) ) do
		if ( ply:IsGhost( ) ) then
			net.Start( "N00BRP_GhostModeToggle" )
				net.WriteEntity( ply )
				net.WriteBool( true )
			net.Send( self )
		end
	end
end

function meta:RetrieveSpawnTimes( )
	for index, ply in ipairs ( player.GetAll( ) ) do
		if ( ply:IsGhost( ) and self.respawnTimeDelay ) then
			net.Start( "N00BRP_RespawnTimer" )
				net.WriteEntity( ply )
				net.WriteUInt( self.respawnTimeDelay, 16 )
			net.Send( self )
		end
	end
end

function meta:SendNPCTitles( )
	local npcTable = ents.FindByClass( "npc_*" )
	for index, npc in ipairs ( npcTable ) do
		if not ( npc.FloatingTitle ) then continue end
		net.Start( "N00BRP_NPCTitles" )
			net.WriteUInt( npc:EntIndex( ), 32 )
			net.WriteString( npc.FloatingTitle )
		net.Send( self )
	end
end

-----------------------------------------------------------
--------- Size Modification Functions

function meta:IncrementCrabSize( )
	local curScale = self:GetModelScale( )
	local maxScale = SVNOOB_VARS:Get( "MaxCrabSize", true, "number", 0.4 )
	local maxQueenScale = SVNOOB_VARS:Get( "MaxCrabQueenSize", true, "number", 1 )
	local currentCrabQueen = SVNOOB_VARS:Get( "CrabQueen", true, "player", nil )
	if ( currentCrabQueen == self and maxScale ~= maxQueenScale ) then
		maxScale = maxQueenScale
	end
	if ( curScale < maxScale ) then
		local scaleInc = SVNOOB_VARS:Get( "CrabSizeInc", true, "number", 0.1 )
		local newScale = math.Clamp( curScale + scaleInc, 0, maxScale )
		local scaleInterval = SVNOOB_VARS:Get( "CrabGrowInt", true, "number", 45 )
		if ( self:GetObserverMode( ) == OBS_MODE_NONE and !self:IsGhost( ) and self:Alive( ) and !self.cantEquipWeapons ) then
			if ( currentCrabQueen == self ) then self.crabQueenLastScale = newScale end
			self:SetModelScale( newScale, 1 )
			self:ScaleViewOffset( newScale )
			self:ScaleHull( newScale, false )
			self:ApplyMovementSpeed( )
			local crabLimit = SVNOOB_VARS:Get( "CrabPersonLimit", true, "number", 3 )
			local crabLimitInc = SVNOOB_VARS:Get( "CrabPersonLimitInc", true, "number", 3 )
			local maxCrabLimit = SVNOOB_VARS:Get( "MaxCrabPersonLimit", true, "number", 15 )
			local newLimit = crabLimit + crabLimitInc
			if ( crabLimit == maxCrabLimit ) then -- already at max
				newLimit = -1 -- set to -1 so we can ignore it later
			end
			if ( newLimit > maxCrabLimit ) then
				newLimit = maxCrabLimit
			end
			local healthIncrement = SVNOOB_VARS:Get( "CrabHealthIncrement", true, "number", 25 )
			if ( self == currentCrabQueen ) then
				self:SetHealth( self:Health( ) + healthIncrement )
				if ( newLimit > 0 ) then
					SVNOOB_VARS:Set( "CrabPersonLimit", newLimit )
					for index, ply in ipairs ( player.GetAll( ) ) do
						DarkRP.notify( ply, 2, 4, "The Crab Person limit has been raised to " .. newLimit .. "." )
					end
				end
			end
			if ( ( newScale == maxScale ) and !IsValid( currentCrabQueen ) ) then
				local sizeInc = SVNOOB_VARS:Get( "CrabSizeInc", true, "number", 0.1 )
				local sizeLeft = maxQueenScale - curScale
				local maxHealth = self:GetMaxHealth( ) + ( healthIncrement * math.Round( ( sizeLeft / sizeInc ) ) )
				self:SetMaxHealth( maxHealth )
				self:SetHealth( self:Health( ) + healthIncrement )
				PrintMessage( HUD_PRINTTALK, self:Nick( ) .. " has evolved into the Queen of the Crab People!" )
				hook.Call( "OnCrabQueenEvolve", { }, self )
				SVNOOB_VARS:Set( "CrabQueen", self )
				currentCrabQueen = self
				if ( newLimit > 0 ) then
					SVNOOB_VARS:Set( "CrabPersonLimit", newLimit )
					for index, ply in ipairs ( player.GetAll( ) ) do
						DarkRP.notify( ply, 2, 4, "The Crab Person limit has been raised to " .. newLimit .. "." )
					end
				end
			end
		end
		if ( newScale < maxScale or ( currentCrabQueen == self and maxScale ~= maxQueenScale ) ) then
			timer.Create( self:EntIndex( ) .. ":CrabGrowthTimer", scaleInterval, 1, function( )
				if ( IsValid( self ) and self:Team( ) == TEAM_CRAB ) then
					self:IncrementCrabSize( )
				end
			end )
		end
	end
end

function meta:ResetViewOffset( )
	local viewOffset = SVNOOB_VARS:Get( "BaseViewOffset" )
	local viewOffsetDucked = SVNOOB_VARS:Get( "BaseViewOffsetDucked" )
	self:SetViewOffset( viewOffset )
	self:SetViewOffsetDucked( viewOffsetDucked )
	net.Start( "N00BRP_SetViewOffset" )
		net.WriteVector( viewOffset )
		net.WriteVector( viewOffsetDucked )
	net.Send( self )
end

function meta:ScaleViewOffset( scale )
	local viewOffset = SVNOOB_VARS:Get( "BaseViewOffset" )
	local viewOffsetDucked = SVNOOB_VARS:Get( "BaseViewOffsetDucked" )
	viewOffset = viewOffset * scale
	viewOffsetDucked = viewOffsetDucked * scale
	self:SetViewOffset( viewOffset )
	self:SetViewOffsetDucked( viewOffsetDucked )
	net.Start( "N00BRP_SetViewOffset" )
		net.WriteVector( viewOffset )
		net.WriteVector( viewOffsetDucked )
	net.Send( self )
end

function meta:ScaleHull( scale, reset )
	local resetHull = reset or false
	local hullMins = SVNOOB_VARS:Get( "BaseOBBMins" )
	local hullMaxs = SVNOOB_VARS:Get( "BaseOBBMaxs" )
	hullMins = hullMins * ( scale or 1 )
	hullMaxs = hullMaxs * ( scale or 1 )
	self:SetHull( hullMins, hullMaxs )
	self:SetHullDuck( hullMins, Vector( hullMaxs.x, hullMaxs.y, ( hullMaxs.z / 2 ) ) )
	net.Start( "N00BRP_SetHull" )
		net.WriteBit( resetHull )
		net.WriteVector( hullMins )
		net.WriteVector( hullMaxs )
	net.Send( self )
end

function meta:IsInBox( mins, maxs )
	OrderVectors( mins, maxs )
	return self:GetPos():WithinAABox( mins, maxs )
end

function meta:ApplyMovementSpeed( )
	if ( self:IsGhost( ) ) then return end
	local runningPerks = self:HasPerksInTree( "Running Speed Perks" )
	local runningLevel = NOOBRP_SkillAlgorithms:CalculateRunning( self )["CurrentLevel"]
	local defaultWalkSpeed = SVNOOB_VARS:Get( "DefaultWalkSpeed" )
	local defaultRunSpeed = SVNOOB_VARS:Get( "DefaultRunSpeed" )
	local runningLevelBoost = ( 1.66 * runningLevel )
	local finalRunningSpeed = defaultRunSpeed + runningLevelBoost
	if ( self:Team( ) ~= TEAM_CRAB and self:GetModelScale( ) < 0.5 ) then
		self:SetWalkSpeed( defaultWalkSpeed / 2 )
		self:SetRunSpeed( defaultRunSpeed / 2 )
		return
	elseif ( self:Team( ) == TEAM_CRAB ) then
		self:SetWalkSpeed( math.Clamp( defaultWalkSpeed * ( self:GetModelScale( ) * 1.35 ), 50, defaultWalkSpeed ) )
		self:SetRunSpeed( math.Clamp( defaultRunSpeed * ( self:GetModelScale( ) * 1.35 ), 100, defaultRunSpeed ) )
		return
	end
	if ( runningPerks ) then
		if ( runningPerks <= 4 ) then
			finalRunningSpeed = finalRunningSpeed * NOOB_PERK_TREE["Running Speed Perks"][runningPerks].percent
		else
			finalRunningSpeed = finalRunningSpeed * NOOB_PERK_TREE["Running Speed Perks"][4].percent
		end
	end
	if ( ( self:getDarkRPVar( "HatClass" ) and string.find( self:getDarkRPVar( "HatClass" ), "turtle_hat" ) ) or self:isArrested( ) ) then
		self:SetWalkSpeed( defaultWalkSpeed )
		self:SetRunSpeed( defaultWalkSpeed )
	else
		self:SetWalkSpeed( defaultWalkSpeed )
		self:SetRunSpeed( finalRunningSpeed )
	end
end

function meta:BoostRunSpeed( multi )
	if ( self:IsGhost( ) ) then return end
	if ( ( self:getDarkRPVar( "HatClass" ) and string.find( self:getDarkRPVar( "HatClass" ), "turtle_hat" ) ) or self:isArrested( ) ) then return end
	self:SetRunSpeed( self:GetRunSpeed( ) * multi )
end

function meta:MultiplyMovementSpeed( multi )
	if ( self:IsGhost( ) ) then return end
	if ( multi > 1 and ( ( self:getDarkRPVar( "HatClass" ) and string.find( self:getDarkRPVar( "HatClass" ), "turtle_hat" ) ) or self:isArrested( ) ) ) then return end
	self:SetRunSpeed( self:GetRunSpeed( ) * multi )
	self:SetWalkSpeed( self:GetWalkSpeed( ) * multi )
end

local function playerWantDecay( ply, decayMess )
	if not ( IsValid( ply ) ) then return end
	if not ( ply:getDarkRPVar( "wanted" ) ) then return end
	PrintMessage( HUD_PRINTCENTER, decayMess )
	PrintMessage( HUD_PRINTCONSOLE, decayMess )
	ply:setDarkRPVar( "wanted", false )
end

function meta:SetWanted( length, mes )
	if ( self:IsGhost() or self:GetObserverMode() != OBS_MODE_NONE ) then return; end
	if not ( self:getDarkRPVar( "wanted" ) ) then
		local entIndex = self:EntIndex( )
		local wantMess = self:Nick( ) .. " " .. mes or self:Nick( ) .. " is wanted by the Police!"
		local decayMess = self:Nick( ) .. " is no longer wanted by the Police!"
		self:setDarkRPVar( "wanted", true )
		if not ( timer.Exists( "WantedDecayTimer:" .. entIndex ) ) then
			PrintMessage( HUD_PRINTCENTER, wantMess )
			PrintMessage( HUD_PRINTCONSOLE, wantMess )
			timer.Create( "WantedDecayTimer:" .. entIndex, length, 1, function( )
				playerWantDecay( self, decayMess )
			end )
		else
			timer.Adjust( "WantedDecayTimer:" .. entIndex, length, 1, function( )
				playerWantDecay( self, decayMess )
			end )
		end
	end
end

-----------------------------------------------------------
--------- Player Trace Functions

function meta:RangeEyeTrace( range, filter )
	local filterTable = filter or { }
	table.insert( filterTable, self )
	local traceData = { }
	traceData.start = self:GetShootPos( )
	traceData.endpos = self:GetShootPos( ) + self:EyeAngles( ):Forward( ) * range
	traceData.filter = filterTable
	local traceRes = util.TraceLine( traceData )
	return traceRes
end

function meta:RangeAboveTrace( range, filter )
	local filterTable = filter or { }
	table.insert( filterTable, self )
	local traceData = { }
	traceData.start = self:GetPos( )
	traceData.endpos = self:GetPos( ) + Vector( 0, 0, math.abs( range ) )
	traceData.filter = filterTable
	local traceRes = util.TraceLine( traceData )
	return traceRes
end

function meta:TraceHull( offset, dir, filter, onlyPlayers )
	local filterTable = filter or { }
	table.insert( filterTable, self )
	local traceData = { }
	traceData.start = self:GetPos( )
	traceData.endpos = self:GetPos( ) + dir * offset
	traceData.mins = self:OBBMins( )
	traceData.maxs = self:OBBMaxs( )
	if ( onlyPlayers ) then
		traceData.filter = function( ent ) return ( ent:IsPlayer( ) and ent ~= self ) end
	else
		traceData.filter = filterTable
	end
	local traceRes = util.TraceHull( traceData )
	return traceRes
end

-----------------------------------------------------------
--------- Player Killed Helper Functions

function meta:ResetCopKillerStatus( )
	self.isCopKiller = false
end

function meta:IsCopKiller( )
	return ( self.isCopKiller )
end

function meta:SetCopKiller( )
	self.isCopKiller = true
end

function meta:AttemptZombieInfection( attacker )
	if ( attacker:Team( ) == TEAM_ZOMBIE && self:Team( ) ~= TEAM_CRAB && self:Team( ) ~= TEAM_ZOMBIE ) then
		if not ( self:IsMurderer( ) ) then
			self.respawnTimeOverride = 3
		end
		local rndChance = math.random( 1, 100 )
		if ( rndChance <= tonumber( SVNOOB_VARS:Get( "InfectionRate" ) ) ) then
			timer.Simple( 1, function( )
				if not ( IsValid( self ) ) then return end
				self:RevivePlayer( )
				self:changeTeam( TEAM_ZOMBIE, true )
				--timer.Simple( 0.1, function( ) self:SetBodygroup( 1, math.random( 0, 1 ) ) end )
			end )
			attacker:SayMessage( CHAT_PLAYER_SAY, " BRAINNNSSSSS!" )
			if ( self:Team( ) == TEAM_CITIZEN ) then
				attacker:PrintMessage( HUD_PRINTCENTER, "Civilian brains have no substance!" )
				return
			end
			local healthGain = SVNOOB_VARS:Get( "ZombieEatCorpseHPGain", true, "table", { min = 25, max = 35 } )
			healthGain = math.random( healthGain.min, healthGain.max )
			attacker:SetHealth( attacker:Health( ) + healthGain )
			attacker:SayMessage( CHAT_PLAYER_ME, " devours " .. self:Name( ) .. "!" )
		end
	end
end

function meta:WasCrabQueenKilled( currentQueen, attacker )
	if ( self == currentQueen and self ~= attacker ) then
		local bountyMulti = 2 * (self.crabQueenLastScale or 0) - 1
		local bountyReward = math.Clamp(math.Round(35000 * bountyMulti), 0, 35000)
		if ( attacker:IsPlayer( ) ) then
			if bountyReward > 0 then
				PrintMessage( HUD_PRINTTALK, attacker:Name( ) .. " has slain the Queen of the Crab People, " .. self:Name( ) .. ", they were given a partial reward of $" .. bountyReward .. "!" )
				attacker:addMoney( bountyReward )
			else
				PrintMessage( HUD_PRINTTALK, attacker:Name( ) .. " has slain the Queen of the Crab People, " .. self:Name( ) .. ", blowing their load way too early for a reward." )
			end
		end
		SVNOOB_VARS:Set( "CrabQueen", nil )
		SVNOOB_VARS:Set( "CrabPersonLimit", 3 )
		for index, ply in ipairs ( player.GetAll( ) ) do
			DarkRP.notify( ply, 2, 4, "The Crab Person limit has been reset to 3." )
		end
		self.crabQueenLastScale = nil
	end
end

function meta:DidCrabQueenPerish( currentQueen, attacker )
	if ( self == currentQueen and ( attacker == self or attacker:IsWorld( ) ) ) then
		PrintMessage( HUD_PRINTTALK, "The Queen of the Crab People, " .. self:Nick( ) .. " has perished." )
		SVNOOB_VARS:Set( "CrabQueen", nil )
		SVNOOB_VARS:Set( "CrabPersonLimit", 3 )
		for index, ply in ipairs ( player.GetAll( ) ) do
			DarkRP.notify( ply, 2, 4, "The Crab Person limit has been reset to 3." )
		end
		self.crabQueenLastScale = nil
	end
end

function meta:DidCrabQueenDisconnect( )
	local currentCrabQueen = SVNOOB_VARS:Get( "CrabQueen" )
	if ( self == currentCrabQueen ) then
		PrintMessage( HUD_PRINTTALK, "The Queen of the Crab People, " .. self:Nick( ) .. ", has disconnected." )
		SVNOOB_VARS:Set( "CrabQueen", nil )
		SVNOOB_VARS:Set( "CrabPersonLimit", 3 )
		for index, ply in ipairs ( player.GetAll( ) ) do
			DarkRP.notify( ply, 2, 4, "The Crab Person limit has been reset to 3." )
		end
		self.crabQueenLastScale = nil
	end
end

function meta:DidHitmanKillInnocent( wasSelfDefense, victim )
	if ( self:Team( ) == TEAM_HITMAN and !wasSelfDefense ) then
		local hitTarget = self.playerHitmanContract
		if ( victim ~= self.playerHitmanContract ) then
			PrintMessage( HUD_PRINTCENTER, self:Nick( ) .. " has killed an innocent and was fired!" )
			PrintMessage( HUD_PRINTCONSOLE, self:Nick( ) .. " has killed an innocent and was fired!" )
			self:changeTeam( TEAM_CITIZEN, true )
			return true
		else
			self.playerHitmanContract = nil
		end
	end
	return false
end

function meta:WasKilledDuringRobbery( )
	local bankButton = ents.FindByClass( "bank_button" )[1]
	if ( !IsValid( bankButton ) or !bankButton.IsBeingRobbed ) then return false end
	if not ( self:IsInBank( ) ) then return false end
	return true
end

function meta:WasKilledForHerb( )
	if ( self.lastUsedHerbFinishTime ) then
		if ( self.lastUsedHerbFinishTime < CurTime( ) ) then
			return false
		else
			return true
		end
	end
	return false
end

function meta:WasKilledInRoad( )
	local traceData = { }
	traceData.start = self:GetPos( )
	traceData.endpos = self:GetPos( ) - Vector( 0, 0, 50 )
	traceData.filter = { self }
	local traceRes = util.TraceLine( traceData )
	if ( string.find( traceRes.HitTexture, "AJACKS/AJACKS_ROAD" ) ) then
		return true
	end
	return false
end


-----------------------------------------------------------
--------- Self Defense Helper Functions

function meta:WasSelfDefense( victim )
	if ( self.selfDefenseTable and self.selfDefenseTable[ victim:SteamID( ) ] ) then
		return true
	end
end

function meta:ResetSelfDefense( victim )
	self.selfDefenseTable[ victim:SteamID( ) ] = nil
end

function meta:AttemptFlagSelfDefense( attacker, dmg )
	self.selfDefenseTable = self.selfDefenseTable or { }
	if ( !attacker.selfDefenseTable or !attacker.selfDefenseTable[ self:SteamID( ) ] ) then
		local dmgTaken = dmg or 0
		self.selfDefenseTable[attacker:SteamID( )] = self.selfDefenseTable[attacker:SteamID( )] or 0
		self.selfDefenseTable[attacker:SteamID( )] = self.selfDefenseTable[attacker:SteamID( )] + dmgTaken
	end
end

-----------------------------------------------------------
--------- Output Helper Functions

function meta:GetNiceModelScale( decimals )
	return math.Round( self:GetModelScale( ), decimals )
end

function meta:EncloseSteamID( )
	return "'" .. self:SteamID( ) .. "'"
end

function meta:TeamColor( )
	return team.GetColor( self:Team( ) )
end

function meta:NiceInfo( includeJob )
	local niceInfo = "[ " .. self:SteamID( ) .. " ] [ " .. self:SafeUniqueID( ) .. " ] " .. self:Nick( )
	if not ( includeJob ) then return niceInfo end
	niceInfo = niceInfo .. " ( " .. team.GetName( self:Team( ) ) .. " )"
	return niceInfo
end

-----------------------------------------------------------
--------- Miscellaneous Gameplay Functions

function meta:EnableGhostMode( bStatus )
	if ( bStatus and !self.ghostModeStatus ) then
	--if ( bStatus and !self:getDarkRPVar( "IsGhost" ) ) then
		if ( self:IsDisguised( ) ) then
			self:SetDisguised( nil, true )
		end
		local respawnTime = SVNOOB_VARS:Get( "DefaultRespawnTime" )
		local violentActionPenaltyTime = tonumber( SVNOOB_VARS:Get( "ViolentActionPenaltyTime" ) ) or 300
		if ( self.respawnTimeOverride ) then
			respawnTime = self.respawnTimeOverride
			self.respawnTimeOverride = nil
		elseif ( self:isArrested( ) ) then
			respawnTime = NOOBRP.StatusTrackers:GetRemainingJailTime( self:SteamID( ) )
		elseif ( self:IsMurderer( ) ) then
			local penaltyTime = tonumber( SVNOOB_VARS:Get( "MurdererPenaltyTime" ) ) or 600
			respawnTime = penaltyTime
		elseif ( self:IsPacifist( ) ) then
			local pacifistRespawnTime = tonumber( SVNOOB_VARS:Get( "PacifistRespawnTime" ) ) or 3
			respawnTime = pacifistRespawnTime
		elseif ( self.killedByVehicle ) then
			respawnTime = respawnTime / 2
			DarkRP.notify( self, 1, 4, "Killed by a vehicle, respawn timer has been shortened." )
		/*elseif ( self:LastViolentActionWithinTime( violentActionPenaltyTime ) and self.hasKilledPlayer ) then
			respawnTime = violentActionPenaltyTime
			self.hasKilledPlayer = false*/
		elseif ( self:DidCommitCrimeWithinTime( 300 ) ) then
			respawnTime = violentActionPenaltyTime
		elseif ( self:GetDeathsWithoutRetribution( ) >= 5 ) then
			respawnTime = 25
		elseif ( self:GetDeathsWithoutRetribution( ) >= 3 ) then
			respawnTime = 5
		end
		self:SetCustomCollisionCheck( true )
		self.killedByVehicle = false
		local playerCorpse = self.playerCorpse
		//self:SetNetworkedBool( "IsGhost", true )
		self:ToggleGhostMode( true, player.GetAll( ) )
		//self:setDarkRPVar( "IsGhost", true )
		//self:SetNetworkedInt( "RespawnTime", CurTime( ) + respawnTime )
		self:SetRespawnTime( respawnTime, player.GetAll( ) )
		//self:setDarkRPVar( "RespawnTime", CurTime( ) + respawnTime )
		self:DrawViewModel( false )
		self:DrawWorldModel( false )
		self:DrawShadow( false )
		self:GodEnable( )
		self:StripWeapons( )
		self:StripAmmo( )
		self:SetGravity( 0.35 )
		self:ToggleCollision( false )
		-- I DON'T KNOW WHY I HAVE TO USE A TIMER BUT IT'S PISSING ME OFF
		timer.Simple( .001, function( )
			if ( isangle( self.DeathAngles ) ) then
				self:SetEyeAngles( self.DeathAngles )
			end
		end )
		timer.Create( self:EntIndex( ) .. ":RespawnTimer", respawnTime, 1, function( )
			if ( IsValid( playerCorpse ) ) then 
				SafeRemoveEntity( playerCorpse )
			end
			if not ( IsValid( self ) ) then return end
			self.spawnPosOverride = nil -- Timer ran out, don't respawn at corpse.
			self.reviveExpireTime = nil
			self:EnableGhostMode( false )
		end )
	end
	if ( !bStatus and self.ghostModeStatus ) then
	--if ( !bStatus and self:getDarkRPVar( "IsGhost" ) ) then
		if not ( IsValid( self ) ) then return end
		if ( timer.Exists( self:EntIndex( ) .. ":RespawnTimer" ) ) then
			timer.Destroy( self:EntIndex( ) .. ":RespawnTimer" )
		end
		if ( IsValid( self.playerCorpse ) ) then
			SafeRemoveEntity( self.playerCorpse )
		end
		self:ToggleGhostMode( false, player.GetAll( ) )
		//self:SetNetworkedBool( "IsGhost", false )
		//self:setDarkRPVar( "IsGhost", false )
		self:DrawViewModel( true )
		self:DrawViewModel( true )
		self:DrawShadow( true )
		self:GodDisable( )
		self:ClearTempWeapons( ) -- To ensure weapon list is cleared.
		self:ClearDisabledPermas( )
		// self:Spawn( )
		self:KillSilent();
		self:SetCustomCollisionCheck( false )
		self:CloseReviveMenu( )
		self:SetGravity( 1 )
		//self:SetNetworkedBool( "NoDrawPlayer", false )
		self.aboutToGhost = false
		self.spawnPosOverride = nil
		NOOBRP.StatusTrackers:ClearRespawnTimer( self:SteamID( ) )
	end
end

function meta:CreatePlayerCorpse( pos )
	if ( IsValid( self.playerCorpse ) ) then return end
	self.playerCorpse = ents.Create( "prop_ragdoll" )
	self.playerCorpse:SetModel( self:GetModel( ) )
	self.playerCorpse:SetPos( pos )
	self.playerCorpse:SetAngles( self:GetAngles( ) )
	self.playerCorpse:SetOwner( self )
	self.playerCorpse:Spawn( )
	self.playerCorpse:Activate( )
	self.playerCorpse.isPlayerCorpse = true
	self.playerCorpse:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
	self.playerCorpse.ownerSteamID = self:SteamID( )
	if ( string.find( self:GetModel( ), "group01/female" ) and self.femaleClothingMaterial and string.len( self.femaleClothingMaterial ) > 0 ) then
		self.playerCorpse:SetSubMaterial( self:GetClothingIndex( ), self.femaleClothingMaterial )
	elseif ( string.find( self:GetModel( ), "group01/male" ) and self.maleClothingMaterial and string.len( self.maleClothingMaterial ) > 0 ) then
		self.playerCorpse:SetSubMaterial( self:GetClothingIndex( ), self.maleClothingMaterial )
	end
	local playerCorpse = self.playerCorpse
	local playerCorpseIndex = playerCorpse:EntIndex( )
	local playerCorpseColor = self:GetPlayerColor( )
	playerCorpse.GetPlayerColor = function( )
		return playerCorpseColor
	end
	-- I hate using SendLua or BroadcastLua, but it seemed like a waste of lines to write a net message for this.
	timer.Simple( 1, function( )
		BroadcastLua( "Entity( " .. playerCorpseIndex .. " ).GetPlayerColor = function( ) return Vector( " .. playerCorpseColor.x ..", " .. playerCorpseColor.y .. ", " .. playerCorpseColor.z .. " ) end" )
	end )
	-- local maxBones = self.playerCorpse:GetPhysicsObjectCount( ) - 1
	-- for i = 0, maxBones do
	-- 	local ragBone = self.playerCorpse:GetPhysicsObjectNum( i )
	-- 	if ( IsValid( ragBone ) ) then
	-- 		local ragBonePos, ragBoneAng = self:GetBonePosition( self.playerCorpse:TranslatePhysBoneToBone( i ) )
	-- 		if ( ragBonePos and ragBoneAng ) then
	-- 			ragBone:SetPos( ragBonePos )
	-- 			ragBone:SetAngles( ragBoneAng )
	-- 		end
	-- 	end
	-- end
	local num = self.playerCorpse:GetPhysicsObjectCount()-1
	local v = self:GetVelocity()*2
	if self.VehicleVelocity then
		v = self.VehicleVelocity*2
		v.VehicleVelocity = nil
	end

			-- bullets have a lot of force, which feels better when shooting props,
			-- but makes bodies fly, so dampen that here

	for i=0, num do
		local bone = self.playerCorpse:GetPhysicsObjectNum(i)
		if IsValid(bone) then
		local bp, ba = self:GetBonePosition(self.playerCorpse:TranslatePhysBoneToBone(i))
		if bp and ba then
		bone:SetPos(bp)
		bone:SetAngles(ba)
		end

		-- not sure if this will work:
		bone:SetVelocity(v)
		end
	end
end

function meta:ToggleCollision( status )
	local status = tobool( status )
	if ( status ) then
		self:SetNotSolid( false )
		self:SetCollisionGroup( COLLISION_GROUP_PLAYER )
	else
		self:SetNotSolid( true )
		self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
	end
	net.Start( "N00BRP_GhostMode_ToggleCollision" )
		net.WriteEntity( self )
		net.WriteBit( status )
	net.Broadcast( )
end

function meta:AttemptCorpseCPR( corpse )
	self.lastCPRCorpse = self.lastCPRCorpse or nil
	self.chestCompressionCount = self.chestCompressionCount or 0
	self.lastChestCompression = self.lastChestCompression or CurTime( )
	local reqChestCompressions = SVNOOB_VARS:Get( "ReqChestCompressions" )
	if ( self:IsPacifist( ) ) then
		reqChestCompressions = math.Round( reqChestCompressions / 2 )
	end
	if ( IsValid( self.lastCPRCorpse ) and self.lastCPRCorpse ~= corpse ) then
		self.chestCompressionCount = 0
	else
		if ( IsValid( corpse:GetOwner( ) ) ) then
			if ( corpse.wasRevived ) then
				self.chestCompressionCount = 0
				self:ChatPrint( corpse:GetOwner( ):Name( ) .. " has already been revived." )
				return
			end
		else
			self.chestCompressionCount = 0
			self:ChatPrint( "You cannot revived a disconnected player's body." )
			return
		end
		local healingPerks = self:HasPerksInTree( "Healing Perks" )
		if ( healingPerks and healingPerks >= 5 ) then
			if ( IsValid( corpse:GetOwner( ) ) ) then
				self.chestCompressionCount = 0
				--corpse:GetOwner( ):RevivePlayer( )
				corpse:GetOwner( ):SendReviveMenu( self )
				corpse.wasRevived = true
				local newHealth = math.Clamp( self:Health( ) - 15, 0, self:GetMaxHealth( ) )
				if ( newHealth == 0 ) then
					self:SayMessage( CHAT_PLAYER_ME, "has given their life for " .. corpse:GetOwner( ):Name( ) .. "!" )
					self:Kill( )
				else
					self:SayMessage( CHAT_PLAYER_ME, " has ressurected " .. corpse:GetOwner( ):Name( ) .. "!" )
					self:SetHealth( newHealth )
				end
				return
			end
		end
		if ( self.chestCompressionCount > 0 and math.Round( self.lastChestCompression ) == math.Round( CurTime( ) - 1 ) ) then
			local displayNotifies = tobool( tonumber( self:GetInfoNum( "noobrp_displaycprnotifies", "0" ) ) )
			local legacyCPR = tobool( tonumber( self:GetInfoNum( "noobrp_enablelegacycpr", "0" ) ) )
			if ( displayNotifies and !legacyCPR ) then
				DarkRP.notify( self, 1, 2, tostring( self.chestCompressionCount ) .. "!" )
				self:EmitSound( "player/geiger1.wav", 100, math.random( 50, 75 ) )
			elseif ( legacyCPR ) then
				self:ChatPrint( tostring( self.chestCompressionCount ) .. "!" )
			elseif ( !displayNotifies and !legacyCPR ) then
				self:EmitSound( "player/geiger1.wav", 100, math.random( 50, 75 ) )
			end
			self.chestCompressionCount = self.chestCompressionCount + 1
			self.lastChestCompression = CurTime( )
			if ( IsValid( corpse:GetOwner( ) ) and self.chestCompressionCount == math.Round( reqChestCompressions / 2 ) ) then
				self:SayMessage( CHAT_PLAYER_YELL, "Comeon, " .. corpse:GetOwner( ):Name( ) .. ", breathe damn you!" )
			end
		elseif ( self.chestCompressionCount > 0 and math.Round( self.lastChestCompression ) ~= math.Round( CurTime( ) - 1 ) ) then
			self.chestCompressionCount = 0
			self:SayMessage( CHAT_PLAYER_YELL, "Dammit! I've lost them!" )
			return
		end
		if ( self.chestCompressionCount == 0 ) then
			self.chestCompressionCount = self.chestCompressionCount + 1
			self.lastChestCompression = CurTime( )
			self:SayMessage( CHAT_PLAYER_YELL, "Hold on, " .. corpse:GetOwner( ):Name( ) .. ", come away from the light!" )
		end
		if ( self.chestCompressionCount == reqChestCompressions ) then
			if ( IsValid( corpse:GetOwner( ) ) ) then
				self.chestCompressionCount = 0
				self:SayMessage( CHAT_PLAYER_ME, " has successfully given CPR to " .. corpse:GetOwner( ):Name( ) .. "!" )
				corpse:GetOwner( ):SendReviveMenu( self )
				corpse.wasRevived = true
				--corpse:GetOwner( ):RevivePlayer( )
			end
		end
	end
end

function meta:RevivePlayer( ignoreOverride )
	if ( IsValid( self.playerCorpse ) ) then
		self.spawnPosOverride = self.playerCorpse:GetPos( )
		self.reviveExpireTime = CurTime( ) + timer.TimeLeft( self:EntIndex( ) .. ":RespawnTimer" )
		if ( ignoreOverride ) then self.spawnPosOverride = nil end
		self:EnableGhostMode( false )
	else
		self:EnableGhostMode( false )
	end
end

function meta:SendReviveMenu( plyReviver )
	net.Start( "N00BRP_PlayerReviveMenu" )
		net.WriteString( "OpenMenu" )
		net.WriteEntity( plyReviver )
	net.Send( self )
end

function meta:CloseReviveMenu( )
	net.Start( "N00BRP_PlayerReviveMenu" )
		net.WriteString( "CloseMenu" )
		net.WriteEntity( self )
	net.Send( self )
end

function meta:SendColorSelector( cmd, ent )
	net.Start( "N00BRP_ColorSelector" )
		net.WriteString( cmd )
		if ( IsValid( ent ) ) then
			net.WriteEntity( ent )
		end
	net.Send( self )
end

function meta:DisorientPlayer( length )
	self.isDisorientated = true
	self:ChatPrint( "You suddenly feel very helpless and flustered." )
	local entIndex = self:EntIndex( )
	local tickCount = 0
	local lastCMD = false
	timer.Create( "N00BRP_DisorientPlayer_" .. entIndex, 1, length, function()
		if not ( IsValid( self ) ) then
			timer.Remove( "N00BRP_DisorientPlayer_" .. entIndex )
			return
		end
		if ( lastCMD ) then
			self:ConCommand( lastCMD )
			lastCMD = false
		elseif ( tickCount < 9 ) then
			local rndCMD = math.random( 1, 4 )
			if ( rndCMD == 1 ) then
				self:ConCommand( "+right" )
				lastCMD = "-right"
			elseif ( rndCMD == 2 ) then
				self:ConCommand( "+left" )
				lastCMD = "-left"
			end
		end
		tickCount = tickCount + 1
		if ( tickCount == length ) then
			self.isDisorientated = false
			self:ChatPrint( "You no longer feel disoriented." )
			timer.Remove( "N00BRP_DisorientPlayer_" .. entIndex )
		end
	end )
	timer.Simple( length + 2, function( )
		if not ( IsValid( self ) ) then return end
		self:ConCommand( "-right" )
		self:ConCommand( "-left" )
	end )	
end

function meta:ParalyzePlayer( length, attacker )
	self.tasedBody = ents.Create( "prop_ragdoll" )
	self.tasedBody:SetModel( self:GetModel( ) )
	self.tasedBody:SetKeyValue( "origin", self:GetPos( ).x .. " " .. self:GetPos( ).y .. " " .. self:GetPos( ).z )
	self.tasedBody:SetAngles( self:GetAngles( ) )
	if ( self:Team( ) == TEAM_CRAB ) then
		self.tasedBody.playerModelScale = self:GetModelScale( )
	end
	self:StripWeapons( )
	if ( self:IsWearingBackItem( "jetpack" ) or self:IsWearingBackItem( "backpack" ) ) then
		self:UnequipBackItem( )
	end
	self:DrawViewModel( false )
	self:DrawWorldModel( false )
	self:Spectate( OBS_MODE_CHASE )
	self:SpectateEntity( self.tasedBody )
	self.isTasered = true
	self.tasedBody:Spawn( )
	self.tasedBody:Activate( )
	self.tasedBody:GetPhysicsObject( ):SetVelocity( 4 * self:GetVelocity( ) )
	if ( string.find( self:GetModel( ), "group01/female" ) and self.femaleClothingMaterial and string.len( self.femaleClothingMaterial ) > 0 ) then
		self.tasedBody:SetSubMaterial( self:GetClothingIndex( ), self.femaleClothingMaterial )
	elseif ( string.find( self:GetModel( ), "group01/male" ) and self.maleClothingMaterial and string.len( self.maleClothingMaterial ) > 0 ) then
		self.tasedBody:SetSubMaterial( self:GetClothingIndex( ), self.maleClothingMaterial )
	end
	local tasedBodyIndex = self.tasedBody:EntIndex( )
	local tasedBodyColor = self:GetPlayerColor( )
	self.tasedBody.GetPlayerColor = function( )
		return tasedBodyColor
	end
	-- I hate using SendLua or BroadcastLua, but it seemed like a waste of lines to write a net message for this.
	timer.Simple( 1, function( )
		BroadcastLua( "Entity( " .. tasedBodyIndex.. " ).GetPlayerColor = function( ) return Vector( " .. tasedBodyColor.x ..", " .. tasedBodyColor.y .. ", " .. tasedBodyColor.z .. " ) end" )
	end )
	local entIndex = self:EntIndex( )
	local tasedBody = self.tasedBody
	timer.Create( entIndex .. ":ParalysisRecover", length, 1, function( )
		local standPos = standPos or tasedBody:GetPos( )
		local modelScale = nil
		if ( IsValid( tasedBody ) and tasedBody.playerModelScale ) then
			modelScale = tasedBody.playerModelScale
		end
		if not ( IsValid( self ) ) then
			SafeRemoveEntity( tasedBody )
			return
		end
		self:UnSpectate( )
		self:Spectate( OBS_MODE_NONE )
		self:DrawViewModel( true )
		self:DrawWorldModel( true )
		local oldHealth = self:Health( )
		local oldArmor = self:Armor( )
		self.spawnPosOverride = standPos
		self:Spawn( )
		if ( modelScale ) then
			timer.Simple( 0.5, function( )
				self:SetModelScale( modelScale, 0 )
			end )
		end
		self.spawnPosOverride = nil
		self:SetHealth( oldHealth )
		self:SetArmor( oldArmor )
		self:EnableVisionBlur( true )
		self:setDarkRPVar( "PlayerColorMod", { r = 175, g = 25, b = 25, a = 255 } )
		SafeRemoveEntity( tasedBody )
		self.isTasered = false
		self.cantEquipWeapons = true
		self:BoostRunSpeed( 0.5 )
		util.ExecuteDelayedFunction( self, 5, function( ply )
			ply:ApplyMovementSpeed( )
			self.cantEquipWeapons = false
			ply:setDarkRPVar( "PlayerColorMod", nil )
			ply:EnableVisionBlur( false )
		end, self )
	end )
end

function meta:ApplyBonusHealth( startingHealth )
	local enduranceLevel = NOOBRP_SkillAlgorithms:CalculateEndurance( self )["CurrentLevel"]
	local maxHealth = math.Clamp( startingHealth + ( 5 * enduranceLevel ), 0, 200 )
	self:SetMaxHealth( maxHealth )
	self:SetHealth( maxHealth )
	self:SetArmor( math.Clamp( 5 * enduranceLevel, 0, 100 ) )
end

function meta:Poison( )
	local entIndex = self:EntIndex( )
	local poisonPhrases = { "You feel sharp pains throughout your body.", "You begin to notice your limbs turning green.", "It becomes difficult to breathe as your throat fills with foam.",
	"Your eyes begin to ooze some sort of pus like liquid.", "You head throbs with pain and your body continues to become very stiff.", "You taste metallic in your mouth and have trouble thinking clearly.",
	"Blood excretes from every orifice in your body.", "You lose all your strength, death is surely near." }
	if not ( IsValid( self ) ) then return end
	self:setDarkRPVar( "PlayerColorMod", { r = 25, g = 175, b = 25, a = 255 } )
	timer.Create( entIndex .. ":GreenPoisonTimer", math.random( 3, 5 ), 0, function( )
		if not ( IsValid( self ) ) then
			timer.Destroy( entIndex .. ":GreenPoisonTimer" )
			return
		end
		local dmgData = SVNOOB_VARS:Get( "GreenPoisonDamage", true, "table", { min = 5, max = 10 } )
		self:ChatPrint( poisonPhrases[ math.random( #poisonPhrases ) ] )
		self:TakeDamage( math.random( dmgData.min, dmgData.max ), self, nil )
	end )
end

function meta:IsPoisoned( )
	local entIndex = self:EntIndex( )
	if ( timer.Exists( entIndex .. ":GreenPoisonTimer" ) ) then
		return true
	else
		return false
	end
end

function meta:CurePoison( )
	local entIndex = self:EntIndex( )
	if ( timer.Exists( entIndex .. ":GreenPoisonTimer" ) ) then
		timer.Destroy( entIndex .. ":GreenPoisonTimer" )
		if ( istable( self:getDarkRPVar( "PlayerColorMod" ) ) ) then
			local colorMod = self:getDarkRPVar( "PlayerColorMod" )
			if ( colorMod.r == 25 and colorMod.g == 175 and colorMod.b == 25 ) then
				self:setDarkRPVar( "PlayerColorMod", nil )
			end
		end
	end
end

function meta:CureInfection( )
	timer.Destroy( self:EntIndex( ) .. ":InfectedTimer" )
end

function meta:InfectPlayer( ply, shouldSpread, spreadChance )
	if ( ply:GetObserverMode( ) ~= OBS_MODE_NONE ) then return end
	if ( ply:IsWearingHat( "rare_surgical_mask" ) ) then return end
	local entIndex = ply:EntIndex( )
	local patientZero = self
	local chance = spreadChance or 40
	if ( timer.Exists( entIndex .. ":InfectedTimer" ) ) then return end
	ply:SayMessage( CHAT_PLAYER_ME, "begins to feel rather ill." )
	timer.Create( entIndex .. ":InfectedTimer", 10, 6, function( )
		if ( !IsValid( ply ) or !IsValid( self ) or ply:IsGhost( ) or !ply:Alive( ) ) then
			timer.Destroy( entIndex .. ":InfectedTimer" )
			return
		end
		local poisonDamage = math.random( 5, 15 )
		local aidsEnt = ents.Create( "aids" )
		aidsEnt:SetPos( Vector( 0, 0, 0 ) )
		aidsEnt:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		aidsEnt:SetNoDraw( true )
		aidsEnt:Spawn( )
		if ( IsValid( patientZero ) ) then
			ply:TakeDamage( poisonDamage, patientZero, aidsEnt )
		else
			ply:TakeDamage( poisonDamage, nil, aidsEnt )
		end
		SafeRemoveEntity( aidsEnt )
		ply:SetVelocity( Vector( 0, 35, 0 ) )
		ply:EmitSound( "ambient/voices/cough" .. math.random(1, 4) .. ".wav", 100, 100 )
		local effectData = { startColor = "45 160 45", endColor = "25 100 45", lifeTime = "1", startSize = "20", 
		endSize = "8", startSpeed = "1.5", endSpeed = "0.5", spawnRate = "10", spawnRadius = "15" }
		util.CreateSmokeClouds( effectData, ply:EyePos( ), 0.1 )
		if not ( shouldSpread ) then return end
		local nearbyEnts = ents.FindInBox( ClampWorldVector( ply:GetPos( ) - Vector( 256, 256, 256 ) ), ClampWorldVector( ply:GetPos( ) + Vector( 256, 256, 256 ) ) )
		for index, ent in ipairs ( nearbyEnts ) do
			if ( ply == ent ) then continue end
			if ( IsValid( ent ) and ent:IsPlayer( ) and ent:Alive( ) and !ent:IsGhost( ) and ent:GetObserverMode( ) == OBS_MODE_NONE and !ent.isMarkedAFK  ) then
				local chanceToSpread = math.random( 1, 100 )
				if not ( chanceToSpread < chance ) then continue end
				if ( IsValid( patientZero ) ) then
					if ( ent:IsWearingHat( "surgical_mask" ) ) then
						continue
					end
					patientZero:InfectPlayer( ent, shouldSpread, chance )
				end
			end
		end
	end )
end

function meta:SayMessage( enum, message )
	local plyMess = ""
	if ( enum == CHAT_PLAYER_YELL ) then
		plyMess = "/y "
	elseif ( enum == CHAT_PLAYER_ME ) then
		plyMess = "/me "
	elseif ( enum == CHAT_PLAYER_WHISPER ) then
		plyMess = "/w "
	end
	local finishedMessage = plyMess .. message
	self:ConCommand( "say " .. finishedMessage .. "" )
end

function meta:BeginTowelTimer( ent )
	local plyIndex = self:EntIndex( )
	local timerName = plyIndex .. ":TowelHoldTimer"
	ent.towelFarmerPly = self
	if ( timer.Exists( timerName ) ) then
		timer.Destroy( timerName )
	end
	timer.Create( timerName, 60, 0, function( )
		if not ( IsValid( self ) ) then
			timer.Destroy( timerName )
			return
		end
		if ( !IsValid( ent ) or ent.towelFarmerPly ~= self ) then
			timer.Destroy( timerName )
			return
		end
		self.towelHoldTime = self.towelHoldTime + 60
		self:SaveTowelHoldProgress( )
	end )
end

function meta:CeaseTowelHatTimer( ent )
	if ( IsValid( ent ) ) then
		ent.towelFarmerPly = nil
	end
	timer.Destroy( self:EntIndex( ) .. ":TowelHoldTimer" )
end

function meta:SaveTowelHoldProgress( )
	if ( self.towelHoldTime > 86400 and !self:HasWeaponStored( "towel_hat") ) then
		PrintMessage( HUD_PRINTTALK, self:Name( ) .. " was rewarded a Permanent Towel Hat for completing the secret task!" )
		self:GivePermWeapon( "towel_hat" )
	elseif ( self.towelHoldTime > 259200 and !self:HasWeaponStored( "gold_towel_hat") ) then
		PrintMessage( HUD_PRINTTALK, self:Name( ) .. " was rewarded a Permanent Golden Towel Hat for hoarding towels for a ridiculous amount of time." )
		self:GivePermWeapon( "gold_towel_hat" )
	end
	mySQLControl:Query( "UPDATE darkrp_toweltimer SET time = " .. self.towelHoldTime .. " WHERE uniqueid = " .. self:SafeUniqueID( ) .. ";", function( ) end )
end

function meta:SendColoredMessage( messTbl )
	net.Start( "N00BRP_Miscellaneous_NET" )
		net.WriteInt( ENUM_MISC_NET_COLOREDMESSAGE, 8 )
		net.WriteTable( messTbl )
	net.Send( { self } )
end

function meta:ClientConCommand( cmdTable )
	net.Start( "N00BRP_Miscellaneous_NET" )
		net.WriteInt( ENUM_MISC_NET_CONCOMMAND, 8 )
		net.WriteTable( cmdTable )
	net.Send( { self } )
end

function meta:ReachedPropLimit( )
	local physProps = ents.FindByClass( "prop_physics" )
	local propCount = 0
	for index, ent in ipairs( physProps ) do
		if ( ent:CPPIGetOwner( ) ~= self ) then continue end
		propCount = propCount + 1
	end
	local defaultLimit = tonumber( SVNOOB_VARS:Get( "DefaultMaxProps" ) ) or 10
	local vipLimit = tonumber( SVNOOB_VARS:Get( "VIPMaxProps" ) ) or 15
	local adminLimit = tonumber( SVNOOB_VARS:Get( "AdminMaxProps" ) ) or 20
	local superAdminLimit = tonumber( SVNOOB_VARS:Get( "SuperAdminMaxProps" ) ) or 50
	local constructionWorkerLimit = tonumber( SVNOOB_VARS:Get( "ConstructionWorkerMaxProps" ) ) or 20
	if ( self:IsSuperAdmin( ) ) then
		return ( propCount >= superAdminLimit )
	elseif ( self:IsAdmin( ) ) then
		return ( propCount >= adminLimit )
	elseif ( self:Team( ) == TEAM_CONSTRUCTION ) then
		return ( propCount >= constructionWorkerLimit )
	elseif ( self:IsVIP( ) ) then
		return ( propCount >= vipLimit )
	else
		return ( propCount >= defaultLimit )
	end
	return false
end

function meta:RewardXP( amt, enum, varName, printName, printGain )
	local skillFunc = NOOB_SKILLFUNCTIONS[ enum ]
	if not ( skillFunc ) then return end
	local printingBoost = SVNOOB_VARS:Get( "PrintingXPBoostActive", true, "boolean", false )
	local criminalBoost = SVNOOB_VARS:Get( "CriminalXPBoostActive", true, "boolean", false)
	local policeBoost = SVNOOB_VARS:Get( "PoliceXPBoostActive", true, "boolean", false)
	local levelData = skillFunc( NOOBRP_SkillAlgorithms, self )
	local curXP = self:getDarkRPVar( varName )
	local xpGain = amt
	if ( self:IsVIP( ) ) then xpGain = xpGain * 2 end
	if ( varName == "PrintingXP" and printingBoost == true ) then
		xpGain = xpGain * 2 -- I may change these rates later.
	elseif ( varName == "CriminalXP" and criminalBoost == true ) then
		xpGain = xpGain * 2
	elseif ( varName == "PoliceXP" and policeBoost == true ) then
		xpGain = xpGain * 2
	end
	if ( printName == "Endurance" and self.isMarkedAFK ) then
		xpGain = 1
	end
	if ( self.isMarkedAFK ) then
		if ( printName == "Endurance" ) then
			xpGain = 1
		else
			DarkRP.notify( self, 1, 4, "You did not gain " .. printName .. " experience because you were AFK too long." )
			return
		end
	end
	if not ( curXP ) then return end
	if ( printName == "Endurance" ) then
		self:setDarkRPVar( varName, curXP + xpGain )
	else
		self:setSelfDarkRPVar( varName, curXP + xpGain )
	end
	self:StoreSkillXP( enum, varName )
	self:DidLevelUp( levelData["CurrentLevel"], enum, printName )
	if not ( printGain ) then return end
	DarkRP.notify( self, 0, 3, "You gained " .. xpGain .. " " .. printName .. " experience!" )
end

function meta:DidLevelUp( oldLevel, enum, name )
	local skillFunc = NOOB_SKILLFUNCTIONS[enum]
	if not ( skillFunc ) then return end
	local incLevelData = skillFunc( NOOBRP_SkillAlgorithms, self )
	if ( oldLevel < incLevelData[ "CurrentLevel" ] ) then
		if ( name == "Endurance" ) then
			PrintMessage( HUD_PRINTTALK, self:Name( ) .. " has reached Endurance Level " .. incLevelData["CurrentLevel"] .. ", Congratulations!" )
		end
		self:ChatPrint( "You have reached " .. name .. " Level " .. incLevelData["CurrentLevel"] .. "!" )
		local mes = self:NiceInfo( true ) .. " has reached " .. name .. " Level " .. incLevelData["CurrentLevel"]
		NOOB_LOGGER:Log( NOOB_LOGGING_WARNING, mes, false )
		if ( enum == NOOB_SKILL_ENDURANCE ) then
			self:AttemptPerkPointReward( )
		end
		hook.Call( "OnPlayerLevelUp", { }, self, enum, incLevelData["CurrentLevel"] )
		if ( ( tonumber( incLevelData["CurrentLevel"] ) or 0 ) > 99 ) then
			local skillCape = NOOB_SKILLCAPES[enum]
			if not ( skillCape ) then return end
			if ( self:HasWeaponStored( skillCape ) ) then return end
			PrintMessage( HUD_PRINTTALK, self:Name( ) .. " has reached Level 100 " .. name .. "! They've been rewarded a Permanent " .. name .. " Skill Cape!" )
			self:GivePermWeapon( skillCape )
		end
	end	
end

function meta:GetRPTeamModel( var )
	local targetTeam = TEAM_CITIZEN
	local returnedModel = ""
	if ( RPExtraTeams[ var ] ) then targetTeam = var end
	local modelVar = RPExtraTeams[ targetTeam ].model
	if ( type( modelVar ) == "table" ) then
		returnedModel = modelVar[ math.random( #modelVar ) ]
	else
		returnedModel = modelVar
	end
	return returnedModel
end

function meta:SetDisguised( disguiseTeam, disable )
	if ( disable ) then
		if ( timer.Exists( self:EntIndex( ) .. ":DisguiseTimer" ) ) then
			timer.Destroy( self:EntIndex( ) .. ":DisguiseTimer" )
		end
		self:setDarkRPVar( "IsDisguised", nil )
		self:SetModel( self:GetRPTeamModel( self:Team( ) ) )
	else
		self:setDarkRPVar( "IsDisguised", disguiseTeam )
		self:SetModel( self:GetRPTeamModel( disguiseTeam ) )
	end
end

function meta:EnableVisionBlur( bStatus )
	if ( bStatus ) then
		self:ConCommand( "pp_motionblur 1" )
		self:ConCommand( "pp_motionblur_addalpha 0.06" )
		self:ConCommand( "pp_motionblur_delay 0")
		self:ConCommand( "pp_motionblur_drawalpha 0.99" )
	else
		self:ConCommand( "pp_motionblur 0" )
	end
	self.VisionBlurred = bStatus;
end

function meta:UnequipHat( )
	if not ( self:getDarkRPVar( "HatClass" ) ) then return end
	local hatTable = weapons.Get( self:getDarkRPVar( "HatClass" ) )
	self:setDarkRPVar( "HatClass", nil )
	if ( hatTable.UnEquipFunc ) then
		hatTable.UnEquipFunc( self )
	end
end

function meta:UnequipBackItem( )
	if not ( self:getDarkRPVar( "BackItemClass" ) ) then return end
	local backItemTable = weapons.Get( self:getDarkRPVar( "BackItemClass" ) )
	self:setDarkRPVar( "BackItemClass", nil )
	if ( backItemTable.UnEquipFunc ) then
		backItemTable.UnEquipFunc( self )
	end
end

function meta:GivePurgeEventGear( )
	if ( NOOBRP:IsPurgeOccuring( ) ) then
		if ( !self:IsCivilian( ) and !self:IsGhost( ) ) then
			self:Give( "swb_deagle" )
			self:GiveAmmo( 200, "pistol" )
			self:ChatPrint( "You've received a Deagle to defend yourself." )
		end
	end
end

function meta:HasPurgeDurationItem( class )
	NOOBRP = NOOBRP or { }
	NOOBRP.PurgeDurationItems = NOOBRP.PurgeDurationItems or { }
	if ( NOOBRP.PurgeDurationItems[ self:SteamID( ) ] and NOOBRP.PurgeDurationItems[ self:SteamID( ) ][ class ] ) then
		return true
	else
		return false
	end
end

function meta:GivePurgeDurationItem( class )
	NOOBRP = NOOBRP or { }
	NOOBRP.PurgeDurationItems = NOOBRP.PurgeDurationItems or { }
	NOOBRP.PurgeDurationItems[ self:SteamID( ) ] = NOOBRP.PurgeDurationItems[ self:SteamID( ) ] or { }
	NOOBRP.PurgeDurationItems[ self:SteamID( ) ][ class ] = true
	if ( !self:IsCivilian( ) and !self:IsGhost( ) ) then
		self:Give( class )
	end
end

function meta:EquipAllPurgeDurationItems( )
	if ( self:IsGhost( ) ) then return end
	NOOBRP = NOOBRP or { }
	NOOBRP.PurgeDurationItems = NOOBRP.PurgeDurationItems or { }
	NOOBRP.PurgeDurationItems[ self:SteamID( ) ] = NOOBRP.PurgeDurationItems[ self:SteamID( ) ] or { }
	if not ( istable( NOOBRP.PurgeDurationItems[ self:SteamID( ) ] ) ) then return end
	for wep, _ in pairs ( NOOBRP.PurgeDurationItems[ self:SteamID( ) ] ) do
		if ( !self:HasWeaponStored( wep ) and !self:HasWeapon( wep ) and !self:IsCivilian( ) ) then
			self:Give( wep )
		end
	end
end

function meta:RemovePurgeDurationItem( class )
	NOOBRP = NOOBRP or { }
	NOOBRP.PurgeDurationItems = NOOBRP.PurgeDurationItems or { }
	NOOBRP.PurgeDurationItems[ self:SteamID( ) ] = NOOBRP.PurgeDurationItems[ self:SteamID( ) ] or { }
	NOOBRP.PurgeDurationItems[ self:SteamID( ) ][ class ] = nil
	if ( self:HasWeaponStored( class ) ) then
		self:RemoveTempWeapon( class )
	end
	if ( self:HasWeapon( class ) ) then
		self:StripWeapon( class )
	end
end

function meta:RemoveAllPurgeDurationItems( )
	NOOBRP = NOOBRP or { }
	NOOBRP.PurgeDurationItems = NOOBRP.PurgeDurationItems or { }
	NOOBRP.PurgeDurationItems[ self:SteamID( ) ] = NOOBRP.PurgeDurationItems[ self:SteamID( ) ] or { }
	if not ( istable( NOOBRP.PurgeDurationItems[ self:SteamID( ) ] ) ) then return end
	for wep, _ in pairs ( NOOBRP.PurgeDurationItems[ self:SteamID( ) ] ) do
		self:RemovePurgeDurationItem( wep )
	end
end

function meta:RentPurgeItem( class, cost, name )
	if ( self:HasWeaponStored( class ) or self:HasPurgeDurationItem( class ) ) then
		self:ErrorNotify( "You already have that weapon!" )
		return
	end
	if not ( self:canAfford( cost ) ) then
		self:ErrorNotify( "You cannot afford that temporary weapon!" )
		return
	end
	if not ( NOOBRP:IsPurgeOccuring( ) ) then
		self:ErrorNotify( "You can only purchase these weapons during a Purge Event!" )
		return
	end
	self:addMoney( -cost )
	self:GivePurgeDurationItem( class )
	self:SuccessNotify( "You've bought a " .. name .. " for $" .. string.Comma( cost ) .. " which will last for the duration of the Purge Event.")
end

-----------------------------------------------------------
--------- Permanent Item Rentable Functions

function meta:DisplayFeedback( enum, class, length )
	if ( enum == ENUM_WEAPONRENTAL_ALREADYHAS ) then
		self:ErrorNotify( "You are already renting that item." )
	elseif ( enum == ENUM_WEAPONRENTAL_ALREADYHASPERMA ) then
		self:ErrorNotify( "You cannot rent that because you have a permanent one." )
	elseif ( enum == ENUM_WEAPONRENTAL_CANTAFFORD ) then
		self:ErrorNotify( "You can't afford to rent that item." )
	elseif ( enum == ENUM_WEAPONRENTAL_RENTSUCCESS ) then
		local wepTable = noob_WeaponIndex:Get( class )
		self:SuccessNotify( "You have rented the " .. wepTable.name .. " for " .. string.NiceTime( length * 60 ) .. "!" )
	elseif ( enum == ENUM_WEAPONRENTAL_DOESNTHAVE ) then
		self:ErrorNotify( "You aren't renting that item right now." )
	elseif ( enum == ENUM_WEAPONRENTAL_CANCELSUCCESS ) then
		local wepTable = noob_WeaponIndex:Get( class )
		self:SuccessNotify( "You are no longer renting the " .. wepTable.name .. "!" )
	end
end

function meta:RentPerm( class, length, cost, cback )
	if not ( self:canAfford( cost ) ) then cback( false, ENUM_WEAPONRENTAL_CANTAFFORD ) return end
	self:HasPermItem( class, function( alreadyHas )
		if ( alreadyHas ) then cback( false, ENUM_WEAPONRENTAL_ALREADYHASPERMA ) return end
		mySQLControl:Query( "SELECT uniqueid FROM darkrp_rentedperms WHERE class = " .. SQLStr( class ) .. " AND uniqueid = " .. self:SafeUniqueID( ) .. ";", function( data ) 
			if ( !data or #data < 1 ) then
				local newLength = ( length * 60 )
				mySQLControl:Query( "INSERT INTO darkrp_rentedperms VALUES( " .. self:SafeUniqueID( ) .. ", " .. SQLStr( class ) .. ", " .. ( os.time( ) + newLength ) .." );", function( ) end )
				cback( true, ENUM_WEAPONRENTAL_RENTSUCCESS )
				self:addMoney( -cost )
				self.rentedPermsTable = self.rentedPermsTable or { }
				self.rentedPermsTable[ class ] = ( os.time( ) + newLength )
				local wepTable = noob_WeaponIndex:Get( class )
				if ( wepTable.citizen ) then
					self:Give( class )
				elseif ( !self:IsCivilian( ) and !wepTable.citizen ) then
					self:Give( class )
				end
				local mes = self:NiceInfo( ) .. " has rented a " .. class .. " for " .. string.NiceTime( newLength )
				NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
			else
				cback( false, ENUM_WEAPONRENTAL_ALREADYHAS )
			end
		end )
	end )
end

function meta:CancelPermRental( class, cback )
	mySQLControl:Query( "SELECT uniqueid FROM darkrp_rentedperms WHERE class = " .. SQLStr( class ) .. " AND uniqueid = " .. self:SafeUniqueID( ) .. ";", function( data )
		if ( !data or #data < 1 ) then
			cback( false, ENUM_WEAPONRENTAL_DOESNTHAVE )
		else
			mySQLControl:Query( "DELETE FROM darkrp_rentedperms WHERE class = " .. SQLStr( class ) .. " AND uniqueid = " .. self:SafeUniqueID( ) .. ";", function( ) end )
			cback( true, ENUM_WEAPONRENTAL_CANCELSUCCESS )
			self.rentedPermsTable = self.rentedPermsTable or { }
			self.rentedPermsTable[ class ] = nil
			local mes = self:NiceInfo( ) .. " has canceled the rental for a " .. class .. "."
			NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
		end
	end )
end

function meta:RetrieveRentedPerms( cback )
	mySQLControl:Query( "SELECT class, expiretime FROM darkrp_rentedperms WHERE uniqueid = " .. self:SafeUniqueID( ) .. ";", function( data )
		if ( !data or #data < 1 ) then
			cback( nil )
		else
			cback( data )
		end
	end )
end

function meta:RemoveExpiredRentals( cback )
	self:RetrieveRentedPerms( function( data )
		if ( data ) then
			for index, dat in ipairs ( data ) do
				if ( tonumber( dat.expiretime ) < os.time( ) ) then
					local mes = self:NiceInfo( ) .. "'s " .. dat.class .. " rental has expired."
					NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
					self:CancelPermRental( dat.class, function( success, enum )
						if not ( IsValid( self ) ) then return end
						self.rentedPermsTable = self.rentedPermsTable or { }
						self.rentedPermsTable[ dat.class ] = nil
					end )
				end
			end
			cback( )
		end
	end )
end

function meta:AddRentedPermsToLoadout( cback )
	self.rentedPermsTable = self.rentedPermsTable or { }
	self:RetrieveRentedPerms( function( data )
		if not ( data ) then return end
		for index, dat in ipairs ( data ) do
			self.rentedPermsTable[ dat.class ] = dat.expiretime
		end
		cback( )
	end )
end

function meta:GiveRentedPerms( )
	self.rentedPermsTable = self.rentedPermsTable or { }
	if not ( istable( self.rentedPermsTable ) ) then return end
	for class, expireTime in pairs ( self.rentedPermsTable ) do
		if ( tonumber( expireTime ) < os.time( ) ) then
			self:CancelPermRental( class, function( success, enum )
				if not ( IsValid( self ) ) then return end
				self.rentedPermsTable[ class ] = nil
			end )
			continue
		end
		local wepData = noob_WeaponIndex:Get( class )
		if not ( wepData ) then continue end
		if ( self:IsCivilian( ) and !wepData.citizen ) then continue end
		self:Give( class )
	end
end

function meta:HasInRentLoadout( class )
	self.rentedPermsTable = self.rentedPermsTable or { }
	return ( self.rentedPermsTable[ class ] )
end


-----------------------------------------------------------
--------- Clothes Helper Functions

function meta:ResetSubMaterials( )
	local subMaterials = self:GetMaterials( )
	for i=0, 10 do
		self:SetSubMaterial( i, "" )
	end
	/*for index, mat in ipairs ( subMaterials ) do
		self:SetSubMaterial( index, "" )
	end*/
end

function meta:RetrieveClothes( )
	mySQLControl:Query( "SELECT maleClothing, femaleClothing FROM darkrp_playerclothes WHERE uniqueid = " .. self:SafeUniqueID( ) .. ";", function( data )
		if ( data and #data > 0 and data[1] ) then
			self.maleClothingMaterial = data[1].maleClothing
			self.femaleClothingMaterial = data[1].femaleClothing
			net.Start( "N00BRP_SetPlayerClothing" )
				net.WriteString( self.maleClothingMaterial or "" )
				net.WriteString( self.femaleClothingMaterial or "" )
			net.Send( self )
		end
		self:AttemptWearClothes( )
	end )
end

function meta:AttemptWearClothes( )
	self:ResetSubMaterials( )
	timer.Simple( 0.1, function( )
		if not ( IsValid( self ) ) then return end
		if ( string.find( self:GetModel( ), "group01/female" ) ) then
			if ( string.len( self.maleClothingMaterial or "" ) > 0 ) then
				self:SetSubMaterial( self:GetClothingIndex( ), self.femaleClothingMaterial )
			end
		elseif ( string.find( self:GetModel( ), "group01/male" ) ) then
			if ( string.len( self.maleClothingMaterial or "" ) > 0 ) then
				self:SetSubMaterial( self:GetClothingIndex( ), self.maleClothingMaterial )
			end
		end
	end )
end

function meta:SaveClothing( clothing )
	if ( !NOOBRP.Config.MaleClothing[clothing] and !NOOBRP.Config.FemaleClothing[clothing] ) then
		ErrorNoHalt( self:Nick( ) .. " tried to save invalid clothing." )
		return
	end
	mySQLControl:ColumnValueExists( "darkrp_playerclothes", "uniqueid", self:SafeUniqueID( ), function( data )
		if ( !data or !istable( data ) or #data <= 0 ) then
			local maleClothing = ""
			local femaleClothing = ""
			if ( string.find( self:GetModel( ), "female" ) ) then
				femaleClothing = clothing
				self.femaleClothingMaterial = clothing
			else
				maleClothing = clothing
				self.maleClothingMaterial = clothing
			end
			mySQLControl:Query( "INSERT INTO darkrp_playerclothes VALUES( " .. self:SafeUniqueID( ) .. ", " .. SQLStr( maleClothing ) .. ", " .. SQLStr( femaleClothing ) .. " );", function( ) end )
			self:AttemptWearClothes( )
		else
			if ( string.find( self:GetModel( ), "female" ) ) then
				self.femaleClothingMaterial = clothing
				mySQLControl:Query( "UPDATE darkrp_playerclothes SET femaleClothing = " .. SQLStr( clothing ) .. " WHERE uniqueid = " .. self:SafeUniqueID( ) .. ";", function( ) end )
			else
				self.maleClothingMaterial = clothing
				mySQLControl:Query( "UPDATE darkrp_playerclothes SET maleClothing = " .. SQLStr( clothing ) .. " WHERE uniqueid = " .. self:SafeUniqueID( ) .. ";", function( ) end )
			end
			self:AttemptWearClothes( )
		end
		net.Start( "N00BRP_SetPlayerClothing" )
			net.WriteString( self.maleClothingMaterial or "" )
			net.WriteString( self.femaleClothingMaterial or "" )
		net.Send( self )
	end )
end

-----------------------------------------------------------
--------- Title Helper Functions

function meta:RetrieveTitles( )
	mySQLControl:Query( "SELECT enumtitle FROM darkrp_playertitles WHERE uniqueid = " .. self:SafeUniqueID( ) .. ";", function( data )
		if ( data and #data > 1 ) then
			self.titlesTable = data
			net.Start( "N00BRP_Titles_NET" )
				net.WriteUInt( ENUM_TITLES_BEGINSEND, 8 )
			net.Send( self )
			for index, dat in ipairs ( data ) do
				net.Start( "N00BRP_Titles_NET" )
					net.WriteUInt( ENUM_TITLES_SENDTITLE, 8 )
				net.Send( self )
			end
			net.Start( "N00BRP_Titles_NET" )
				net.WriteUInt( ENUM_TITLES_ENDSEND, 8 )
			net.Send( self )
		end
		mySQLControl:Query( "SELECT enumtitle FROM darkrp_playeractivetitle WHERE uniqueid = " .. self:SafeUniqueID( ) .. ";", function( data )
			if ( data and #data > 0 and data[1] ) then
				self:setDarkRPVar( "TitleEnum", tonumber( data[1].enumtitle ) )
			end
		end )
	end )
end

function meta:SetActiveTitle( enum )
	local foundTitle = self:CurrentlyHasTitle( enum )
	if not ( foundTitle ) then
		self:ErrorNotify( "You can't set a title to one you don't have!" )
		return
	else
		mySQLControl:Query( "REPLACE INTO darkrp_playeractivetitle VALUES( " .. self:SafeUniqueID( ) .. ", " .. enum .. " );", function( ) end )
		self:setDarkRPVar( "TitleEnum", tonumber( enum ) )
	end
end

function meta:CurrentlyHasTitle( enum )
	local foundTitle = false
	self.titlesTable = self.titlesTable or { }
	for index, data in ipairs ( self.titlesTable ) do
		if ( tonumber( data.enumtitle ) == enum ) then
			foundTitle = true
			break
		end
	end
	return foundTitle
end

function meta:DisableTitle( )
	self:setDarkRPVar( "TitleEnum", nil )
	mySQLControl:Query( "DELETE FROM darkrp_playeractivetitle WHERE uniqueid = " .. self:SafeUniqueID( ) .. ";", function( ) end )
end

function meta:GiveNewTitle( enum )
	local foundTitle = self:CurrentlyHasTitle( enum )
	if ( foundTitle ) then
		self:ErrorNotify( "You already have that title." )
		return
	else
		mySQLControl:Query( "INSERT INTO darkrp_playertitles VALUES( " .. self:SafeUniqueID( ) .. ", " .. enum .. " );", function( ) end )
		self.titlesTable = self.titlesTable or { }
		table.insert( self.titlesTable, { enumtitle = enum } )
		self:SuccessNotify( "You have been rewarded the [ " .. NOOBRP.Titles[ enum ].title .. " ] title!" )
	end
end
-----------------------------------------------------------
--------- Permanent & Temporary Weapon Functions

if not ( meta.OldGive) then -- Wish there was a hook for this so I wouldn't have to override it.
	meta.OldGive = meta.Give
end

function meta:Give( class, skipCheck )
	self:OldGive( class )
	if not ( skipCheck ) then
		local bool, index = self:IsPermaDisabled( class )
		if ( bool ) then
			table.remove( self.disabledPermas, index )
		else
			self:StoreTempWeapon( class )
		end
	end
end

function meta:RetrievePermWeapons( )
	mySQLControl:GrabRows( "darkrp_permweps", "steamid", self:EncloseSteamID( ), function( data ) 
		if ( #data > 0 ) then
			self:setSelfDarkRPVar( "PermWeapons", data )
		else
			self:setSelfDarkRPVar( "PermWeapons", { } )
		end
	end )
end

function meta:ClearDisabledPermas( )
	self.disabledPermas = { }
end

function meta:DisablePermaItem( class )
	self.disabledPermas = self.disabledPermas or { }
	table.insert( self.disabledPermas, class )
end

function meta:IsPermaDisabled( class )
	self.disabledPermas = self.disabledPermas or { }
	for index, perm in ipairs ( self.disabledPermas ) do
		if ( class == perm ) then
			return true, index
		end
	end
	return false
end

function meta:RemoveTempWeapon( class )
	if not ( noob_WeaponIndex:Get( class ) ) then return end
	self.tempWeapons = self.tempWeapons or { }
	for index, wep in ipairs ( self.tempWeapons ) do
		if ( wep == class ) then
			table.remove( self.tempWeapons, index )
			net.Start( "N00BRP_TempWeapons_NET" )
				net.WriteUInt( ENUM_TEMPWEPS_REMOVEWEP, 8 )
				net.WriteString( class )
			net.Send( self )
			break
		end
	end
end

function meta:IsTempItem( class )
	self.tempWeapons = self.tempWeapons or { }
	for index, tempWep in pairs ( self.tempWeapons ) do
		if ( class == tempWep ) then
			return true
		end
	end
	return false
end

function meta:ClearTempWeapons( )
	self.tempWeapons = { }
	net.Start( "N00BRP_TempWeapons_NET" )
		net.WriteUInt( ENUM_TEMPWEPS_CLEARWEPS, 8 )
	net.Send( self )
end

function meta:StoreTempWeapon( class )
	self.tempWeapons = self.tempWeapons or { }
	if ( !self:HasWeaponStored( class ) and noob_WeaponIndex:Get( class ) ) then
		table.insert( self.tempWeapons, class )
		net.Start( "N00BRP_TempWeapons_NET" )
			net.WriteUInt( ENUM_TEMPWEPS_ADDWEP, 8 )
			net.WriteString( class )
		net.Send( self )
	end
end

function meta:HasWeaponStored( class )
	local canEquip = false
	self:setSelfDarkRPVar( "PermWeapons", self:getDarkRPVar( "PermWeapons" ) or { } )
	self.tempWeapons = self.tempWeapons or { }
	for index, wep in pairs ( self:getDarkRPVar( "PermWeapons" ) ) do
		if ( wep.class == class ) then
			canEquip = true
			break
		end
	end
	if not ( canEquip ) then
		for index, wep in ipairs ( self.tempWeapons ) do
			if ( wep == class ) then
				canEquip = true
				break
			end
		end
	end
	return canEquip
end

function meta:GivePermWeapon( class, duplicate, amount, notupdatevar )
	local wep = noob_WeaponIndex:Get( class )
	if not ( wep ) then return end
	amount = amount or 1;
	mySQLControl:PreciseSelectFrom( "darkrp_permweps", { "steamid = " .. self:EncloseSteamID( ), "class = " .. string.Enclose( class ) }, function( data )
		if ( duplicate or #data < 1 ) then
			local wepTable = table.Copy( self:getDarkRPVar( "PermWeapons" ) );
			self:CancelPermRental( class, function( ) end )
			for i = 1, amount do
				mySQLControl:InsertInto( "darkrp_permweps", { self:EncloseSteamID( ), string.Enclose( class ) } );
				if ( !notupdatevar ) then
					table.insert( wepTable, { steamid = self:SteamID( ), class = class } );
					if ( i >= amount ) then
						self:setSelfDarkRPVar( "PermWeapons", wepTable );
						if ( TRADING_SYSTEM.DEBUGMODE ) then
							print( Format( "Took %s seconds to give weapons to %s", tostring( CurTime() - __CHECK ), self:Name() ) );
						end
					end
				end
			end
		end
	end )
end

function meta:RemovePermWeapon( class, amount, notupdatevar )
	local wep = noob_WeaponIndex:Get( class )
	if not ( wep ) then return end
	amount = amount or 1;
	mySQLControl:PreciseSelectFrom( "darkrp_permweps", { "steamid = " .. self:EncloseSteamID( ), "class = " .. string.Enclose( class ) }, function( data )
		if ( #data > 0 ) then
			mySQLControl:Query( Format( "DELETE FROM darkrp_permweps WHERE steamid = %s AND class = %s LIMIT %d;", self:EncloseSteamID(), string.Enclose( class ), amount ), function( data ) end );
			if ( notupdatevar ) then return; end
			self:RetrievePermWeapons();
		end
	end )
end

function meta:PurchasePerm( class, cost, andGems, gemTable, cback )
	local wep = noob_WeaponIndex:Get( class )
	if not ( wep ) then return end
	if ( self.isPurchasingWeapon ) then return end
	if ( self:canAfford( cost ) ) then
		self.isPurchasingWeapon = true
		self:HasPermItem( class, function( alreadyHas )
			if ( alreadyHas ) then
				self:ChatPrint( "You already have that permanent item." )
				self.isPurchasingWeapon = false
				cback( false )
			else
				if ( andGems ) then
					//local currentGems = self:getDarkRPVar( "Gems" )
					local canAfford = true
					canAfford = self:HasGems( gemTable )
					/*for index, gems in pairs ( gemTable ) do
						if ( currentGems[index] < gems ) then
							canAfford = false
							break
						end
						currentGems[index] = currentGems[index] - gems
					end*/
					if ( canAfford ) then
						self:TakeGems( gemTable )
					else
						self:ChatPrint( "You lack the required gems for that permanent item." )
						self.isPurchasingWeapon = false
						cback( false )
						return
					end
				end
				self:addMoney( -cost )
				self:GivePermWeapon( class )
				self.isPurchasingWeapon = false
				cback( true )
				local mes = "[" .. self:SteamID( ) .. "] " .. self:Nick( ) .. " has purchased a Permanent " .. class .. "."
				NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, mes, printConsole )
			end
		end )
	else
		self:ChatPrint( "You cannot afford that permanent item. " )
		self.isPurchasingWeapon = false
		cback( false )
	end
end

function meta:HasPermItem( class, cback )
	local item = noob_WeaponIndex:Get( class )
	if not ( item ) then return end
	mySQLControl:PreciseSelectFrom( "darkrp_permweps", { "steamid = " .. self:EncloseSteamID( ), "class = " .. string.Enclose( class ) }, function( data )
		if ( #data > 0 ) then
			cback( true )
		else
			cback( false )
		end
	end )
end

function meta:HasEntitySpawned( class )
	local entTable = ents.FindByClass( class )
	local isSpawned = false
	if ( #entTable <= 0 ) then return isSpawned end
	for index, ent in ipairs ( entTable ) do
		if ( ent:Getowning_ent( ) == self ) then
			isSpawned = true
			break
		end
	end
	return isSpawned
end

-----------------------------------------------------------
--------- Vehicle Helper Functions

function meta:GetVehicleCount( )
	self.vehicleCount = self.vehicleCount or 0
	return self.vehicleCount
end

function meta:SetVehicleCount( amt )
	self.vehicleCount = self.vehicleCount or 0
	self.vehicleCount = amt
end

function meta:ReachedVehicleLimit( )
	if not ( self.vehicleCount ) then self.vehicleCount = 0 end
	local maxVehicles = SVNOOB_VARS:Get( "MaxVehicles" )
	if ( maxVehicles ~= 0 and self.vehicleCount >= maxVehicles ) then
		DarkRP.notify( self, 1, 4, "You've reached the vehicle limit." )
		return true
	end
	return false
end

function meta:HasPermaVehicleSpawned( class, model )
	local classVehicles = ents.FindByClass( class )
	if ( #classVehicles > 0 ) then
		for index, vehicle in ipairs ( classVehicles ) do
			if ( string.lower( vehicle:GetModel( ) ) ~= string.lower( model ) ) then continue end
			if ( vehicle.isPermaVehicle and vehicle.isPermaVehicle == self ) then
				return true
			end
		end
	else
		return false
	end
	return false
end

function meta:IsVehicleOnCooldown( class )
	self.vehicleCooldowns = self.vehicleCooldowns or { }
	if ( self.vehicleCooldowns[class] ) then
		if ( self.vehicleCooldowns[class] < CurTime( ) ) then
			self.vehicleCooldowns[class] = nil
			return false
		else
			return true, self.vehicleCooldowns[class]
		end
	else
		return false
	end
end

function meta:SetVehicleCooldown( class, delay )
	self.vehicleCooldowns = self.vehicleCooldowns or { }
	self.vehicleCooldowns[class] = CurTime( ) + delay
end

function meta:AddToTrunkEntities( class, amt )
	self.trunkEntities = self.trunkEntities or { }
	self.trunkEntities[ class ] = self.trunkEntities[ class ] or 0
	self.trunkEntities[ class ] = self.trunkEntities[ class ] + ( tonumber( amt ) or 1 )
end

function meta:RemoveFromTrunkEntities( class, amt )
	self.trunkEntities = self.trunkEntities or { }
	if not ( self.trunkEntities[ class ] ) then return end
	self.trunkEntities[ class ] = self.trunkEntities[ class ] - ( tonumber( amt ) or 1 )
	if ( self.trunkEntities[ class ] == 0 ) then
		self.trunkEntities[ class ] = nil
	end
end

function meta:GetTrunkEntityClassAmount( class )
	local furtherCheck = false
	if not ( self.trunkEntities ) then furtherCheck = true end
	if ( self.trunkEntities and !self.trunkEntities[ class ] ) then furtherCheck = true end
	local entityCount = 0
	if ( furtherCheck ) then // Just incase they disconnected and they trunk entities table was cleared.
		for index, veh in ipairs ( noob_VehicleIndex.spawnedVehicles ) do
			if ( veh.trunkItems and #veh.trunkItems > 0 ) then
				for index, entTable in ipairs ( veh.trunkItems ) do
					if ( entTable.owner == self and entTable.class == class ) then
						entityCount = entityCount + 1
					end
				end
			end
		end
		self:AddToTrunkEntities( class, entityCount )
		return entityCount
	else
		return self.trunkEntities[ class ]
	end
end

function meta:HasMoneyPrintersInTrunk( )
	local basicCount = self:GetTrunkEntityClassAmount( "basic_money_printer" )
	local advCount = self:GetTrunkEntityClassAmount( "adv_money_printer" )
	local defaultCount = self:GetTrunkEntityClassAmount( "money_printer" )
	//print( basicCount .. " : " .. advCount .. " " .. defaultCount )
	return ( basicCount ~= 0 or advCount ~= 0 or defaultCount ~= 0 )
end
-----------------------------------------------------------
--------- Entity Use Cooldowns

function meta:IsEntityUseOnCooldown( entIndex )
	self.entityUseCooldowns = self.entityUseCooldowns or { }
	if not ( self.entityUseCooldowns[ entIndex ] ) then
		return false
	else
		if ( self.entityUseCooldowns[ entIndex ] > CurTime( ) ) then
			return true
		else
			self.entityUseCooldowns[ entIndex ] = nil
			return false
		end
	end
end

function meta:SetEntityUseCooldown( entIndex, time )
	self.entityUseCooldowns = self.entityUseCooldowns or { }
	self.entityUseCooldowns[ entIndex ] = CurTime( ) + time
end

-----------------------------------------------------------
--------- Injury Helper Functions

function meta:GetBodyPartInjured( enum )
	if ( enum == ENUM_INJURIES_ARMS ) then
		return self.areArmsInjured or false
	elseif ( enum == ENUM_INJURIES_LEGS ) then
		return self.areLegsCrippled or false
	end
end

function meta:SetBodyPartInjured( enum, bool )
	if ( enum == ENUM_INJURIES_ARMS ) then
		self.areArmsInjured = bool
	elseif ( enum == ENUM_INJURIES_LEGS ) then
		self.areLegsCrippled = bool
	end
end

-----------------------------------------------------------
--------- Murderer Helper Functions

function meta:UpdateLastCriminalAction( )
	self.lastCriminalAction = CurTime( )
end

function meta:GetLastCriminalAction( )
	self.lastCriminalAction = self.lastCriminalAction or 0
	return self.lastCriminalAction
end

function meta:DidCommitCrimeWithinTime( time )
	local lastAction = self:GetLastCriminalAction( )
	if ( lastAction == 0 and time > CurTime( ) ) then return false end
	if ( lastAction + time > CurTime( ) ) then
		return true
	else
		return false
	end
end

-----------------------------------------------------------
--------- Murderer Helper Functions

function meta:AttemptIncrementKillCount( )
	self.killCount = self.killCount or 0
	local graceTime = tonumber( SVNOOB_VARS:Get( "KillGraceTime" ) ) or 120
	if ( self:GetLastViolentAction( ) < CurTime( ) - graceTime ) then
		self.killCount = 1
	else
		self.killCount = self.killCount + 1
	end
end

function meta:CheckIfMurderer( )
	self.killCount = self.killCount or 0
	if ( self.killCount >= 10 and !self:IsMurderer( ) ) then
		PrintMessage( HUD_PRINTCENTER, self:Name( ) .. " is now a Murderer!" )
		local penaltyTime = SVNOOB_VARS:Get( "MurdererPenaltyTime", true, "number", 600 )
		self:EnableMurdererStatus( penaltyTime )
		if ( self:isCP( ) ) then
			PrintMessage( HUD_PRINTCENTER, self:Name( ) .. " was fired for becoming a Murderer!" )
			self:changeTeam( TEAM_CITIZEN, true )
		end
		return true
	else
		return false
	end
end

function meta:EnableMurdererStatus( time )
	self:setDarkRPVar( "IsMurderer", true )
	self.killCount = 0
	util.ExecuteDelayedFunction( self, time, function( self )
		self:setDarkRPVar( "IsMurderer", false )
		PrintMessage( HUD_PRINTCENTER, self:Name( ) .. " is no longer considered a Murderer." )
		NOOBRP = NOOBRP or { }
		NOOBRP.MayorBounties = NOOBRP.MayorBounties or { }
		if ( NOOBRP.MayorBounties[self:SteamID( )] or self:getDarkRPVar( "HasBounty" ) ) then
			DarkRP.notifyAll( NOTIFY_ERROR, 4, "The bounty on " .. self:Name( ) .. " has expired, they're no longer a Murderer." )
			self:setDarkRPVar( "HasBounty", false )
			NOOBRP.MayorBounties[self:SteamID( )] = nil
		end
	end, self )
end

function meta:IsMurderer( )
	return self:getDarkRPVar( "IsMurderer" ) or false
end

function meta:IsBountyKill( victim )
	if not ( IsValid( victim ) ) then return end
	NOOBRP = NOOBRP or { }
	NOOBRP.MayorBounties = NOOBRP.MayorBounties or { }
	if ( NOOBRP.MayorBounties[victim:SteamID( )] ) then
		if not ( victim:IsMurderer( ) ) then
			NOOBRP.MayorBounties[victim:SteamID( )] = nil
			victim:setDarkRPVar( "HasBounty", false )
			self:ErrorNotify( "That player is no longer a Murderer, so the bounty is invalid." )
		else
			local bountyReward = NOOBRP.MayorBounties[victim:SteamID( )]
			DarkRP.notifyAll( NOTIFY_HINT, 4, self:Name( ) .. " has slain the Murderer " .. victim:Name( ) .. " and completed the Mayor's Bounty. They were rewarded $" .. string.Comma( bountyReward ) .. "!" )
			self:addMoney( bountyReward )
			NOOBRP.MayorBounties[victim:SteamID( )] = nil
			victim:setDarkRPVar( "HasBounty", false )
		end
	end
end

-----------------------------------------------------------
--------- Last Violent Action Helper Functions

function meta:GetLastViolentAction( )
	self.lastViolentAction = self.lastViolentAction or 0
	return self.lastViolentAction
end

function meta:IsShrunk( ) 
	return ( self:GetModelScale( ) < 0.3 and self:Team( ) ~= TEAM_CRAB )
end

function meta:UpdateLastViolentAction( )
	self.lastViolentAction = CurTime( )
end

function meta:LastViolentActionWithinTime( seconds )
	self.lastViolentAction = self.lastViolentAction or 0
	local actionExpire = self:GetLastViolentAction( ) + seconds
	if ( CurTime( ) > actionExpire ) then
		return false
	else
		return true
	end
end

-----------------------------------------------------------
--------- Quest Helper Functions

NOOB_NPCQUESTS_COOLDOWN_TABLE = { }

function meta:SetQuestCooldown( quest, delay )
	local cooldownLength = CurTime( ) + delay
	if not ( NOOB_NPCQUESTS_COOLDOWN_TABLE[self:SteamID( )] ) then
		NOOB_NPCQUESTS_COOLDOWN_TABLE[self:SteamID( )] = { }
		NOOB_NPCQUESTS_COOLDOWN_TABLE[self:SteamID( )][quest] = cooldownLength
	else
		NOOB_NPCQUESTS_COOLDOWN_TABLE[self:SteamID( )][quest] = cooldownLength
	end
end

function meta:IsOnQuestCooldown( quest )
	if not ( NOOB_NPCQUESTS_COOLDOWN_TABLE[self:SteamID( )] ) then return false end
	if not ( NOOB_NPCQUESTS_COOLDOWN_TABLE[self:SteamID( )][quest] ) then return false end
	if ( NOOB_NPCQUESTS_COOLDOWN_TABLE[self:SteamID( )][quest] > CurTime( ) ) then
		return true
	else
		NOOB_NPCQUESTS_COOLDOWN_TABLE[self:SteamID( )][quest] = nil
		return false
	end
end

function meta:IsOnQuest( name )
	if not ( self.currentQuest ) then
		return false
	end
	if not ( self.currentQuest.name == name ) then
		return false
	end
	return true, self.currentQuest.stage
end

function meta:AlreadyOnQuest( )
	if not ( self.currentQuest ) then
		return false
	else
		return true
	end
end

function meta:IsQuestCompleted( )
	if ( self.currentQuest.stage == "stage_complete" ) then
		return true
	else
		return false
	end
end

function meta:SetQuestComplete( )
	self.currentQuest.stage = "stage_complete"
	self:RollForItem( )
	self:RollForPerkPoint( )
	hook.Call( "OnQuestComplete", { }, self, self.currentQuest.name )
end

function meta:RemoveQuest( )
	self.currentQuest = nil
end

function meta:BeginQuest( name )
	self.currentQuest = { name = name, stage = "stage_in_progress" }
end

function meta:QuestProgress( newStage )
	self.currentQuest.stage = newStage
end

-----------------------------------------------------------
--------- Revenge Helper Functions

function meta:HasRevenge( victim )
	self.revengeTable = self.revengeTable or { }
	if not ( self.revengeTable ) then return false end
	if ( self.revengeTable[victim:SafeUniqueID( )] ) then
		return true
	else
		return false
	end
end

function meta:RemoveRevenge( victim )
	self.revengeTable = self.revengeTable or { }
	mySQLControl:Query( "DELETE FROM darkrp_revenges WHERE otheruniqueid = " .. self:SafeUniqueID( ) .. " AND uniqueid = " .. victim:SafeUniqueID( ) .. ";", function( ) end )
	self.revengeTable[victim:SafeUniqueID( )] = nil
	net.Start( "N00BRP_Revenge_NET" )
		net.WriteUInt( ENUM_REVENGE_REMOVEREVENGE, 8 )
		net.WriteUInt( victim:SafeUniqueID( ), 32 )
	net.Send( self )
end

function meta:WasKillWithoutRetribution( attacker )
	self.revengeTable = self.revengeTable or { }
	if not ( self.revengeTable ) then return false, 0 end
	if ( self.revengeTable[attacker:SafeUniqueID( )] ) then
		return true, self.revengeTable[attacker:SafeUniqueID( )]
	else
		return false, 0
	end
end

function meta:GetDeathsWithoutRetribution( )
	self.deathsWithoutRetribution = self.deathsWithoutRetribution or 0
	return self.deathsWithoutRetribution
end

function meta:SetDeathsWithoutRetribution( amt )
	self.deathsWithoutRetribution = amt
end

function meta:IncrementRetributionAmount( attacker, currentAmount )
	self.revengeTable = self.revengeTable or { }
	local newAmount = currentAmount + 1
	mySQLControl:Query( "UPDATE darkrp_revenges SET killAmt = " .. newAmount .. " WHERE otheruniqueid = " .. self:SafeUniqueID( ) .. " AND uniqueid = " .. attacker:SafeUniqueID( ) .. ";", function( ) end )
	self.revengeTable[attacker:SafeUniqueID( )] = newAmount
	net.Start( "N00BRP_Revenge_NET" )
		net.WriteUInt( ENUM_REVENGE_INCREMENTREVENGE, 8 )
		net.WriteUInt( attacker:SafeUniqueID( ), 32 )
	net.Send( self )
	--self:setSelfDarkRPVar( "Revenges", revengeTable )
end

function meta:InsertNewRevenge( attacker )
	self.revengeTable = self.revengeTable or { }
	mySQLControl:Query( "INSERT INTO darkrp_revenges ( uniqueid, otheruniqueid, killAmt ) VALUES ( " .. attacker:SafeUniqueID( ) .. ", " .. self:SafeUniqueID( ) .. ", 1 );", function( ) end )
	self.revengeTable[attacker:SafeUniqueID( )] = 1
	net.Start( "N00BRP_Revenge_NET" )
		net.WriteUInt( ENUM_REVENGE_SENDREVENGE, 8 )
		net.WriteUInt( attacker:SafeUniqueID( ), 32 )
		net.WriteUInt( 1, 16 )
	net.Send( self )
	--self:setSelfDarkRPVar( "Revenges", revengeTable )
end

-----------------------------------------------------------
--------- Data Retrieval Functions

function meta:RetrieveMiscData( )

	mySQLControl:Query( "SELECT time FROM darkrp_toweltimer WHERE uniqueid = " .. self:SafeUniqueID( ) .. ";", function( towelData )
		if ( #towelData > 0 ) then
			for index, dat in pairs ( towelData ) do
				self.towelHoldTime = dat.time
				break
			end
		else
			mySQLControl:Query( "INSERT INTO darkrp_toweltimer VALUES( " .. self:SafeUniqueID( ) .. ", 0 );", function( ) end )
			self.towelHoldTime = 0
		end
	end )

	mySQLControl:Query( "SELECT r, g, b FROM darkrp_weaponcolor WHERE uniqueid = " .. self:SafeUniqueID( ) .. ";", function( wepColorData ) 
		if ( #wepColorData > 0 ) then
			for index, dat in pairs ( wepColorData ) do
				self.savedWeaponColor = Color( tonumber( dat.r ), tonumber( dat.g ), tonumber( dat.b ) )
			end
		else
			mySQLControl:Query( "INSERT INTO darkrp_weaponcolor VALUES( " .. self:SafeUniqueID( ) .. ", 255, 255, 255 );", function( ) end )
			self.savedWeaponColor = Color( 255, 255, 255 )
		end
		self:SetWeaponColor( self.savedWeaponColor:ToVector( ) )
	end )

	mySQLControl:Query( "SELECT r, g, b FROM darkrp_playercolor WHERE uniqueid = " .. self:SafeUniqueID( ) .. ";", function( plyColorData )
		if ( #plyColorData > 0 ) then
			for index, dat in pairs ( plyColorData ) do
				self.savedPlayerColor = Color( tonumber( dat.r ), tonumber( dat.g ), tonumber( dat.b ) )
			end
		else
			mySQLControl:Query( "INSERT INTO darkrp_playercolor VALUES( " .. self:SafeUniqueID( ) .. ", 255, 255, 255 );", function( ) end )
			self.savedPlayerColor = Color( 255, 255, 255 )
		end
		self:SetPlayerColor( self.savedPlayerColor:ToVector( ) )
	end )

	mySQLControl:Query( "SELECT points, max FROM darkrp_bonusperks WHERE uniqueid = " .. self:SafeUniqueID( ) .. ";", function( bonusPerkData ) 
		if ( #bonusPerkData > 0 ) then
			self:setSelfDarkRPVar( "BonusPerks", { unspent = bonusPerkData[1].points, maximum = bonusPerkData[1].max } )
		else
			mySQLControl:Query( "INSERT INTO darkrp_bonusperks VALUES ( " .. self:SafeUniqueID( ) .. ", 0, 0 );", function( ) end )
		end
	end )
end

function meta:RetrieveRevenges( )
	mySQLControl:GrabRows( "darkrp_revenges", "otheruniqueid", self:SafeUniqueID( ), function( data )
		if ( #data > 0 ) then
			local revengeTable = { }
			for index, revenge in pairs ( data ) do
				revengeTable[revenge.uniqueid] = revenge.killAmt
				net.Start( "N00BRP_Revenge_NET" )
					net.WriteUInt( ENUM_REVENGE_SENDREVENGE, 8 )
					net.WriteUInt( revenge.uniqueid, 32 )
					net.WriteUInt( revenge.killAmt, 16 )
				net.Send( self )
			end
			self.revengeTable = revengeTable
			--self:setSelfDarkRPVar( "Revenges", revengeTable )
		else
			self.revengeTable = { }
			--self:setSelfDarkRPVar( "Revenges", { } )
		end
	end )
end

function meta:RetrieveSkill( enum, darkRPVar, cback )
	mySQLControl:ColumnValueExists( enum, "uniqueid", self:SafeUniqueID( ), function( data )
		if ( #data > 0 ) then
			if ( isfunction( cback ) ) then
				cback( )
			end
			if ( darkRPVar == "EnduranceXP" ) then
				self:setDarkRPVar( darkRPVar, data[1].xp )
			else
				self:setSelfDarkRPVar( darkRPVar, data[1].xp )
			end
		else
			mySQLControl:InsertInto( enum, { self:SafeUniqueID( ), "0" } )
			if ( enum == "EnduranceXP" ) then
				self:setDarkRPVar( darkRPVar, 0 )
			else
				self:setSelfDarkRPVar( darkRPVar, 0 )
			end
		end
	end )
end

function meta:RetrieveClan( )
	mySQLControl:ColumnValueExists( "darkrp_clans", "uniqueid", self:SafeUniqueID( ), function( data )
		if ( #data > 0 ) then
			self:setDarkRPVar( "Clan", data[1].name )
			self.clanRank = data[1].rank
		end
	end )
end

function meta:RetrieveGems( )
	mySQLControl:ColumnValueExists( "darkrp_gems", "uniqueid", self:SafeUniqueID( ), function( data )
		if ( #data > 0 ) then
			self.gemTable = {
				["Rocks"] = tonumber( data[1].rocks ),
				["Granite"] = tonumber( data[1].granite ),
				["Shale"] = tonumber( data[1].shale ),
				["Emeralds"] = tonumber( data[1].emeralds ),
				["Rubies"] = tonumber( data[1].rubies ),
				["Sapphires"] = tonumber( data[1].sapphires ),
				["Obsidians"] = tonumber( data[1].obsidians ),
				["Diamonds"] = tonumber( data[1].diamonds ),
			}
			/*self:setSelfDarkRPVar( "Gems", { ["Rocks"] = data[1].rocks, ["Granite"] = data[1].granite, ["Shale"] = data[1].shale,
			["Emeralds"] = data[1].emeralds, ["Rubies"] = data[1].rubies, ["Sapphires"] = data[1].sapphires, ["Obsidians"] = data[1].obsidians,
			["Diamonds"] = data[1].diamonds  } )*/
		else
			mySQLControl:InsertInto( "darkrp_gems", { self:SafeUniqueID( ), "0", "0", "0", "0", "0", "0", "0", "0" } )
			self.gemTable = {
				["Rocks"] = 0,
				["Granite"] = 0,
				["Shale"] = 0,
				["Emeralds"] = 0,
				["Rubies"] = 0,
				["Sapphires"] = 0,
				["Obsidians"] = 0,
				["Diamonds"] = 0,
			}
			/*self:setSelfDarkRPVar( "Gems", { ["Rocks"] = 0, ["Granite"] = 0, ["Shale"] = 0, ["Emeralds"] = 0, ["Rubies"] = 0, ["Sapphires"] = 0,
			["Obsidians"] = 0, ["Diamonds"] = 0 } )*/
		end
		for index, amt in pairs ( self.gemTable ) do
			net.Start( "N00BRP_Gems_NET" )
				net.WriteString( index )
				net.WriteUInt( amt, 32 )
			net.Send( self )
		end
	end )
end

function meta:RetrieveIngredients( )
	mySQLControl:ColumnValueExists( "darkrp_ingredients", "uniqueid", self:SafeUniqueID( ), function( data )
		if ( #data > 0 ) then
			self.herbTable = {
				["Burdock Root"] = tonumber( data[1].burdockroot ),
				["Gingko Biloba"] = tonumber( data[1].gingkobiloba ),
				["Valerian Root"] = tonumber( data[1].valerianroot ),
				["Coral Fungus"] = tonumber( data[1].coralfungus ),
				["Red Reishi"] = tonumber( data[1].redreishi ),
				["Psilocybe Cubensis"] = tonumber( data[1].psilocybecubensis )
			}
			/*self:setSelfDarkRPVar( "Ingredients", { ["Burdock Root"] = data[1].burdockroot, ["Gingko Biloba"] = data[1].gingkobiloba, ["Valerian Root"] = data[1].valerianroot,
			["Coral Fungus"] = data[1].coralfungus, ["Red Reishi"] = data[1].redreishi, ["Psilocybe Cubensis"] = data[1].psilocybecubensis } )*/
		else
			mySQLControl:InsertInto( "darkrp_ingredients", { self:SafeUniqueID( ), "0", "0", "0", "0", "0", "0" } )
			self.herbTable = {
				["Burdock Root"] = 0,
				["Gingko Biloba"] = 0,
				["Valerian Root"] = 0,
				["Coral Fungus"] = 0,
				["Red Reishi"] = 0,
				["Psilocybe Cubensis"] = 0
			}
			/*self:setSelfDarkRPVar( "Ingredients", { ["Burdock Root"] = 0, ["Gingko Biloba"] = 0, ["Valerian Root"] = 0,
			["Coral Fungus"] = 0, ["Red Reishi"] = 0, ["Psilocybe Cubensis"] = 0 } )*/
		end
		for index, amt in pairs ( self.herbTable ) do
			net.Start( "N00BRP_Herbs_NET" )
				net.WriteString( index )
				net.WriteUInt( amt, 32 )
			net.Send( self )
		end
	end )
end

-----------------------------------------------------------
--------- NPC Reputation Storage & Manipulation

function meta:LoadReputation( )
	local path = "noob/reputation/" .. self:SteamID64( ) .. ".txt"
	if ( file.Exists( path, "DATA" ) ) then
		self:setSelfDarkRPVar( "PlayerNPCReputation", self:GetReputationTable( ) )
	end
end

function meta:GetReputationTable( )
	local path = "noob/reputation/" .. self:SteamID64( ) .. ".txt"
	if ( file.Exists( path, "DATA" ) ) then
		return util.JSONToTable( file.Read( path, "DATA" ) ) or { }
	else
		return { }
	end
end

function meta:HasReputation( class, amt )
	local repTable = self:getDarkRPVar( "PlayerNPCReputation" )
	if not ( repTable ) then
		local path = "noob/reputation/" .. self:SteamID64( ) .. ".txt"
		if ( file.Exists( path, "DATA" ) ) then
			repTable = util.JSONToTable( file.Read( path ) )
			self:setSelfDarkRPVar( "PlayerNPCReputation", repTable )
		else
			return false
		end
	end
	if not ( repTable[class] ) then return false end
	if ( repTable[class] < amt ) then return false end
	return true
end

function meta:GetReputation( class )
	/*local repTable = self:getDarkRPVar( "PlayerNPCReputation" )
	if ( self:HasReputation( class, 0 ) ) then
		return repTable[class]
	else
		return 0
	end*/
	local path = "noob/reputation/" .. self:SteamID64( ) .. ".txt"
	if ( file.Exists( path, "DATA" ) ) then
		local repTable = util.JSONToTable( file.Read( path, "DATA" ) )
		if ( repTable and repTable[class] ) then
			return repTable[class] or 0
		else
			return 0
		end
	else
		return 0
	end
end

function meta:AddReputation( class, amt )
	local currentAmount = self:GetReputation( class )
	local repTable = self:GetReputationTable( )
	repTable[ class ] = currentAmount + amt
	NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, self:NiceInfo( ) .. " now has" .. currentAmount + amt .. " reputation with " .. class, false )
	local path = "noob/reputation/" .. self:SteamID64( ) .. ".txt"
	file.Write( path, util.TableToJSON( repTable ) )
	self:setSelfDarkRPVar( "PlayerNPCReputation", repTable )
	hook.Call( "OnPlayerGetReputation", { }, self, class, amt )
end

if not ( file.IsDir( "noob", "DATA" ) ) then file.CreateDir( "noob" ) end
if not ( file.IsDir( "noob/reputation", "DATA" ) ) then file.CreateDir( "noob/reputation" ) end

-----------------------------------------------------------
--------- Pacifism Helper Functions

function meta:AttemptPacifism( )
	if ( self:IsPacifist( ) ) then self:ChatPrint( "You're already a pacifist." ) return end
	local lastKill = self:GetLastViolentAction( )
	local pacifismTime = tonumber( SVNOOB_VARS:Get( "PacifismRequiredTime" ) ) or 3600
	if ( lastKill + pacifismTime < CurTime( ) ) then
		self:GivePacifism( )
		PrintMessage( HUD_PRINTCENTER, self:Nick( ) .. " has been accepted as a pacifist." )
		hook.Call( "OnPlayerPacifism", { }, self )
	else
		local newTime = lastKill - CurTime( )
		local goalTime = ( lastKill + pacifismTime ) - CurTime( )
		self:ChatPrint( "Your last kill was " .. string.NiceTime( math.abs( newTime ) ) .. ", you must wait another " .. string.NiceTime( goalTime ) .. " to become a Pacifist." )
	end
end

function meta:GivePacifism( )
	if ( self:IsPacifist( ) ) then return end
	self:setDarkRPVar( "IsPacifist", true )
	mySQLControl:InsertInto( "darkrp_pacifists", { self:SafeUniqueID( ), os.time( ) } )
	self.pacifistTime = os.time( )
end

function meta:RevokePacifism( )
	PrintMessage( HUD_PRINTCENTER, self:Nick( ) .. " has committed a violent crime lost their Pacifism!" )
	self:setDarkRPVar( "IsPacifist", false )
	mySQLControl:DeleteFrom( "darkrp_pacifists", "uniqueid", self:SafeUniqueID( ) )
	self:UpdateLastViolentAction( )
	hook.Call( "OnPlayerRevokePacifism", { }, self )
end

function meta:IsPacifist( )
	return self:getDarkRPVar( "IsPacifist" )
end

function meta:CheckForPacifism( )
	local uniqueID = self:SafeUniqueID( )
	mySQLControl:Query( "SELECT unixtime FROM darkrp_pacifists WHERE uniqueid = " .. uniqueID .. ";", function( data )
		if ( #data > 0 ) then
			self.pacifistTime = data[1].unixtime
			self:setDarkRPVar( "IsPacifist", true )
		end
	end )
end

-----------------------------------------------------------
--------- Data Storage & Manipulation

function meta:StoreSkillXP( enum, darkRPVar, setVar )
	local xp = self:getDarkRPVar( darkRPVar )
	if ( setVar and tonumber( setVar ) ) then
		xp = setVar
		if ( darkRPVar == "EnduranceXP" ) then
			self:setDarkRPVar( darkRPVar, xp )
		else
			self:setSelfDarkRPVar( darkRPVar, xp )
		end
	end
	mySQLControl:UpdateRow( enum, { "xp = " .. xp }, { "uniqueid = " .. self:SafeUniqueID( ) } )
end

function meta:CraftGems( gemTable, preqFunc, func, mess )
	local canAfford = self:HasGems( gemTable )
	if ( canAfford ) then
		local canCraft = preqFunc( self )
		if not ( canCraft ) then DarkRP.notify( self, 1, 4, "You already have what those gems combine into." ) return end
		local mess = mess or "You successfully crafted the gems."
		self:TakeGems( gemTable )
		func( self )
		DarkRP.notify( self, 2, 4, mess )
		hook.Call( "OnPlayerCraftGems", { }, self )
	else
		DarkRP.notify( self, 1, 4, "You lack the required gems" )
	end
end

/*function meta:StoreIngredients( ingredientTable )
	for index, ingredient in pairs ( ingredientTable ) do
	local builtIngredientsTable = { }
	local varIngredientsTable = self:getDarkRPVar( "Ingredients" )
	for index, amt in pairs ( varIngredientsTable ) do
		local dbIndex = string.Replace( index, " ", "" )
		table.insert( builtIngredientsTable, string.lower( dbIndex ) .. " = " .. amt )
	end
	mySQLControl:UpdateRow( "darkrp_ingredients", builtIngredientsTable, { "uniqueid = " .. self:SafeUniqueID( ) } )
end*/

function meta:StoreIngredient( name, amt )
	local dbIndex = string.lower( string.Replace( name, " ", "" ) )
	mySQLControl:Query( "UPDATE darkrp_ingredients SET " .. dbIndex .. " = " .. dbIndex .. " + " .. amt .. " WHERE uniqueid = " .. self:SafeUniqueID( ) .. ";", function( ) end )
end

function meta:StoreGem(gtype)
	mySQLControl:Query("UPDATE darkrp_gems SET " .. string.lower(gtype) .. " = " .. string.lower(gtype) .. " + 1 WHERE uniqueid= " .. self:SafeUniqueID() .. ";", function( ) end )
end

function meta:StoreGems( name, amt )
	mySQLControl:Query("UPDATE darkrp_gems SET " .. string.lower( name ) .. " = " .. string.lower( name ) .. " + " .. amt .. " WHERE uniqueid = " .. self:SafeUniqueID( ) .. ";", function( ) end )
	/*local builtGemTable = { }
	local varGemTable = self:getDarkRPVar( "Gems" )
	for index, amt in pairs ( varGemTable ) do
		table.insert( builtGemTable, string.lower( index ) .. " = " .. amt )
	end
	mySQLControl:UpdateRow( "darkrp_gems", builtGemTable, { "uniqueid = " .. self:SafeUniqueID( ) } )*/
end

function meta:HasGems( gemTable )
	local currentGems = self.gemTable or { ["Rocks"] = 0, ["Granite"] = 0, ["Shale"] = 0, ["Emeralds"] = 0, ["Rubies"] = 0, ["Sapphires"] = 0, ["Obsidians"] = 0, ["Diamonds"] = 0 }
	local hasGems = true
	for index, gems in pairs ( currentGems ) do
		if ( gemTable[index] > gems ) then
			hasGems = false
			break
		end
	end
	return hasGems
end

function meta:TakeGems( gemTable )
	self.gemTable = self.gemTable or { ["Rocks"] = 0, ["Granite"] = 0, ["Shale"] = 0, ["Emeralds"] = 0, ["Rubies"] = 0, ["Sapphires"] = 0, ["Obsidians"] = 0, ["Diamonds"] = 0 }
	for index, gems in pairs ( gemTable ) do
		self.gemTable[index] = self.gemTable[index] - gems
		self:StoreGems( index, -gems )
		net.Start( "N00BRP_Gems_NET" )
			net.WriteString( index )
			net.WriteUInt( self.gemTable[index], 32 )
		net.Send( self )
	end
	--self:setSelfDarkRPVar( "Gems", currentGems )
end

function meta:HasHerbs( herbTable )
	local currentHerbs = self.herbTable or { ["Burdock Root"] = 0, ["Gingko Biloba"] = 0, ["Valerian Root"] = 0, ["Coral Fungus"] = 0, ["Red Reishi"] = 0, ["Psilocybe Cubensis"] = 0 }
	local hasHerbs = true
	for index, herbs in pairs ( currentHerbs ) do
		if not ( herbTable[index] ) then continue end
		if ( herbTable[index] > herbs ) then
			hasHerbs = false
			break
		end
	end
	return hasHerbs
end

function meta:TakeHerbs( herbTable )
	self.herbTable = self.herbTable or { ["Burdock Root"] = 0, ["Gingko Biloba"] = 0, ["Valerian Root"] = 0, ["Coral Fungus"] = 0, ["Red Reishi"] = 0, ["Psilocybe Cubensis"] = 0 }
	for index, herbs in pairs ( herbTable ) do
		self.herbTable[index] = self.herbTable[index] - herbs
		self:StoreIngredient( index, -herbs )
		net.Start( "N00BRP_Herbs_NET" )
			net.WriteString( index )
			net.WriteUInt( self.herbTable[index], 32 )
		net.Send( self )
	end
end

function meta:GiveHerb( herbType, amt )
	self.herbTable = self.herbTable or { ["Burdock Root"] = 0, ["Valerian Root"] = 0, ["Gingko Biloba"] = 0, ["Red Reishi"] = 0, ["Coral Fungus"] = 0, ["Psilocybe Cubensis"] = 0 }
	if ( self.herbTable[herbType] ) then
		self.herbTable[herbType] = self.herbTable[herbType] + amt
		net.Start( "N00BRP_Herbs_NET" )
			net.WriteString( herbType )
			net.WriteUInt( self.herbTable[herbType], 32 )
		net.Send( self )
		//self:setSelfDarkRPVar( "Ingredients", currentHerbs )
		self:StoreIngredient( herbType, amt )
	end
end

function meta:GiveGem( gemType, amt )
	if not amt then amt = 1 end
	self.gemTable = self.gemTable or { ["Rocks"] = 0, ["Granite"] = 0, ["Shale"] = 0, ["Emeralds"] = 0, ["Rubies"] = 0, ["Sapphires"] = 0, ["Obsidians"] = 0, ["Diamonds"] = 0 }
	if ( self.gemTable ) then
		self.gemTable[gemType] = self.gemTable[gemType] + amt
		net.Start( "N00BRP_Gems_NET" )
			net.WriteString( gemType )
			net.WriteUInt( self.gemTable[gemType], 32 )
		net.Send( self )
		self:StoreGems( gemType, amt )
	end
end

function meta:DropGem( gType )
	/*local gemColor = Color( 255, 255, 255, 255 )
	local gemMaterial = ""
	if ( gType == "rock" ) then
	elseif ( gType == "granite" ) then
		gemColor = Color( 160, 160, 160 )
	elseif ( gType == "shale" ) then
		gemColor = Color( 100, 100, 100 )
	elseif ( gType == "emerald" ) then
		gemColor = Color( 0, 255, 0 )
		gemMaterial = "models/shiny"
	elseif ( gType == "ruby" ) then
		gemColor = Color( 255, 0, 0 )
		gemMaterial = "models/shiny"
	elseif ( gType == "sapphire" ) then
		gemColor = Color( 0, 0, 255 )
		gemMaterial = "models/shiny"
	elseif ( gType == "obsidian" ) then
		gemColor = Color( 0, 0, 0 )
		gemMaterial = "models/shiny"
	elseif ( gType == "diamond" ) then
		gemColor = Color( 255, 255, 255, 150 )
		gemMaterial = "models/shiny"
	end*/
	local traceRes = self:RangeEyeTrace( 64 )
	/*local gem = ents.Create( "prop_physics" )
	gem:SetRenderMode( RENDERMODE_TRANSALPHA )
	gem:SetModel( "models/props_junk/rock001a.mdl" )
	gem:SetColor( gemColor )
	gem:SetMaterial( gemMaterial )
	gem:SetPos( traceRes.HitPos )
	gem.isGem = true
	gem.gemType = gType
	gem.Owner = self
	gem:Spawn( )
	gem:Activate( )*/
	local gem = ents.Create( "ent_gem" )
	gem:SetGemType( gType )
	gem:SetGemOwner( self )
	gem:SetPos( traceRes.HitPos )
	gem.droppedFrom = self
	gem:Spawn( )
	self.droppedGems = self.droppedGems or 0
	self.droppedGems = self.droppedGems + 1
	/*timer.Simple( SVNOOB_VARS:Get( "GemDespawnTimer" ), function( )
		if not ( IsValid( gem ) ) then return end
		if ( IsValid( gem.Owner ) ) then
			gem.Owner.droppedGems = math.Clamp( gem.Owner.droppedGems - 1, 0, 5 )
		end
		SafeRemoveEntity( gem )
	end )*/
end

function meta:StoreBankItem( class, model, content, count, plyCBack )
	mySQLControl:PreciseSelectFrom( "darkrp_bankitems", { "steamid = " .. self:EncloseSteamID( ), "class = " .. SQLStr( class ), "content = " .. SQLStr( content ) }, function( data )
		if ( #data > 0 ) then
			for index, dat in pairs ( data ) do
				local totalCount = dat.count + count
				local itemData = nil
				local insertNew = true
				if ( class == "spawned_shipment" ) then
					for index, shipment in ipairs ( CustomShipments ) do
						if ( shipment.entity == content ) then
							itemData = shipment
							break
						end 
					end
					if ( itemData.amount >= totalCount ) then
						insertNew = false
					else
						if ( index ~= #data ) then
							continue
						end
					end
				end
				if ( insertNew ) then
					--mySQLControl:GetMaxValue( "darkrp_bankitems", "id", function( idTbl )
					--	local nextID = ( tonumber( idTbl[1]["MAX(id)"] ) or 0 ) + 1
						mySQLControl:Query( "INSERT INTO darkrp_bankitems ( steamid, class, model, content, count, name ) VALUES ( " .. self:EncloseSteamID( ) .. ", " .. SQLStr( class ) .. ", " .. SQLStr( model ) .. ", " .. SQLStr( content ) .. ", " .. count .. ", " .. SQLStr( self:Name( ) ) .. " );", function( ) end )
						--mySQLControl:InsertInto( "darkrp_bankitems", { self:EncloseSteamID( ), SQLStr( class ), SQLStr( model ), SQLStr( content ), count, SQLStr( self:Name( ) ), nextID } )
						plyCBack( )
						break
					--end )
				else
					mySQLControl:UpdateRow( "darkrp_bankitems", { "count = " .. ( totalCount ) }, { "id = " .. dat.id } )
					plyCBack( )
					break
				end
			end
		else
			--mySQLControl:GetMaxValue( "darkrp_bankitems", "id", function( data )
			--	local nextID = ( tonumber( data[1]["MAX(id)"] ) or 0 ) + 1
				mySQLControl:Query( "INSERT INTO darkrp_bankitems ( steamid, class, model, content, count, name ) VALUES ( " .. self:EncloseSteamID( ) .. ", " .. SQLStr( class ) .. ", " .. SQLStr( model ) .. ", " .. SQLStr( content ) .. ", " .. count .. ", " .. SQLStr( self:Name( ) ) .. " );", function( ) end )
				--mySQLControl:InsertInto( "darkrp_bankitems", { self:EncloseSteamID( ), SQLStr( class ), SQLStr( model ), SQLStr( content ), count, SQLStr( self:Name( ) ), nextID } )
				plyCBack( )
			--end )
		end
	end )
end

function meta:RetrieveBankItem( id, plyCBack )
	mySQLControl:Query( "SELECT class, model, content, count, id FROM darkrp_bankitems WHERE steamid = " .. self:EncloseSteamID( ) .. " AND id = " .. id .. ";", function( data )
		if ( #data > 0 ) then
			mySQLControl:Query( "DELETE FROM darkrp_bankitems WHERE steamid = " .. self:EncloseSteamID( ) .. " AND id = " .. data[1].id .. ";", function( ) end )
			plyCBack( data[1] )
		else
			plyCBack( nil )
		end
	end )
end

function meta:LoadBankTable( cback )
	mySQLControl:Query( "SELECT class, model, content, count, id FROM darkrp_bankitems WHERE steamid = " .. self:EncloseSteamID( ) .. ";", function( data )
		for index, dat in pairs ( data ) do
			net.Start( "N00BRP_BankItems_NET" )
				net.WriteUInt( ENUM_BANKITEMS_ADDITEM, 8 )
				net.WriteString( dat.class )
				net.WriteString( dat.model )
				net.WriteString( dat.content )
				net.WriteUInt( tonumber( dat.count ), 16 )
				net.WriteUInt( tonumber( dat.id ), 32 )
			net.Send( self )
			self.bankItems = self.bankItems or { }
			self.bankItems[tonumber( dat.id )] = { class = dat.class, model = dat.mode, content = dat.content, count = tonumber( dat.count ) }
		end
		cback( self.bankItems )
	end )
end

function meta:GetOccupiedBankSlots( cBack )
	mySQLControl:Query( "SELECT COUNT( steamid ) AS amount FROM darkrp_bankitems WHERE steamid = " .. self:EncloseSteamID( ) .. ";", function( data )
		cBack( tonumber( data[1].amount ) )
	end )
end

function meta:RefreshPocketAndBank( )
	self:SendLua( "if ( ValidPanel( LocalPlayer( ).bankMenu ) ) then LocalPlayer( ).bankMenu:GenerateBankItems( ) LocalPlayer( ).bankMenu:GeneratePocketItems( ) end" )
end

function meta:PocketEntity( ent )
	local maxSlots = GAMEMODE.Config.pocketitems
	if ( table.Count( self.darkRPPocket or { } ) >= maxSlots ) then
		return false
	else
		self:addPocketItem( ent )
		return true
	end
end

function meta:HasPocketSpacesLeft( amt )
	local maxSlots = GAMEMODE.Config.pocketitems
	local itemCount = table.Count( self.darkRPPocket or { } )
	if ( itemCount + amt <= maxSlots ) then
		return true
	else
		local remainingSlots = maxSlots - itemCount
		return false, remainingSlots
	end
end

function meta:HasSpaceInPocket( )
	local maxSlots = GAMEMODE.Config.pocketitems
	if ( table.Count( self.darkRPPocket or { } ) < maxSlots ) then
		return true
	else
		DarkRP.notify( self, 1, 4, "Your pocket is full." )
		return false
	end
end

function meta:HasPotionInPocket( name )
	local pocketItems = self:getPocketItems( )
	local doesHas = false
	if ( istable( pocketItems ) ) then
		for index, item in pairs ( pocketItems ) do
			if ( item.class == "ent_alchemypotion" and item.name == name ) then
				doesHas = true
				break
			end
		end
	end
	return doesHas
end

function meta:RemovePotionFromPocket( name )
	local pocketItems = self:getPocketItems( )
	if ( istable( pocketItems ) ) then
		for index, item in pairs ( pocketItems ) do
			if ( item.class == "ent_alchemypotion" and item.name == name ) then
				self:removePocketItem( index )
				break
			end
		end
	end
end

-----------------------------------------------------------
--------- Data Helper Functions


function meta:IsClanLeader( cback )
	mySQLControl:PreciseSelectFrom( "darkrp_clans", { "uniqueid = " .. self:SafeUniqueID( ), "name = " .. SQLStr( self:getDarkRPVar( "Clan" ) ) }, function( data )
		if ( #data > 0 ) then
			local rank = data[1].rank
			if ( rank ~= 1 ) then
				cback( data, false )
			else
				cback( data, true )
			end
		end
	end )
end

function meta:IsClanOfficer( cback )
	mySQLControl:PreciseSelectFrom( "darkrp_clans", { "uniqueid = " .. self:SafeUniqueID( ), "name = " .. SQLStr( self:getDarkRPVar( "Clan" ) ) }, function( data )
		if ( #data > 0 ) then
			local rank = data[1].rank
			if ( rank < 1 ) then
				cback( data, false )
			else
				cback( data, true )
			end
		end
	end )
end

function meta:PromoteToClanOfficer( ply, cback )
	self:IsClanOfficer( function( data, bool )
		if ( !bool or ply.clanRank ~= 0 ) then
			DarkRP.notify( self, 1, 4, "You lack the rank to promote!" )
			return
		end
		if not ( ply:IsInClan( self:IsInClan( ) ) ) then
			return
		end
		mySQLControl:Query( "UPDATE darkrp_clans SET rank = 2 WHERE uniqueid = " .. ply:SafeUniqueID( ) .. ";" , function( ) end )
		cback( )
		ply.clanRank = 2
	end )
end

function meta:DemoteToMember( ply, cback )
	self:IsClanOfficer( function( data, bool )
		if ( !bool or ply.clanRank ~= 2 ) then
			DarkRP.notify( self, 1, 4, "That member cannot be demoted!" )
			return
		end
		if not ( ply:IsInClan( self:IsInClan( ) ) ) then
			return
		end
		mySQLControl:Query( "UPDATE darkrp_clans SET rank = 0 WHERE uniqueid = " .. ply:SafeUniqueID( ) .. " AND rank = 2;" , function( ) end )
		cback( )
		ply.clanRank = 0
	end )
end

function meta:IsInClan( name )
	local clan = self:getDarkRPVar( "Clan" ) or ""
	if not ( name ) then	
		return self:getDarkRPVar( "Clan" )
	end
	if ( clan == name ) then
		return true
	else
		return false
	end
end

function meta:GetOnlineClanMembers( )
	local clanMembers = { }
	local clanName = self:getDarkRPVar( "Clan" )
	if ( clanName ) then
		for index, ply in ipairs ( player.GetAll( ) ) do
			if ( ply:getDarkRPVar( "Clan" ) == clanName ) then
				table.insert( clanMembers, ply )
			end
		end
	end
	return clanMembers
end

function meta:GetOfflineClanMembers( cback )
	local clanName = self:getDarkRPVar( "Clan" )
	if ( clanName ) then
		mySQLControl:Query( "SELECT rpname, rank FROM darkrp_clans JOIN darkrp_player ON darkrp_clans.uniqueid = darkrp_player.uid WHERE darkrp_clans.name = " .. SQLStr( clanName ) .. ";", function( data )
			if ( #data > 0 ) then
				cback( data )
			else
				cback( nil )
			end
		end )
	end
end

function meta:IsClanAtWar( name )
	local otherClan = name or ""
	local clanName = self:getDarkRPVar( "Clan" ) or ""
	if ( NOOBRP.OngoingClanWars[clanName] == otherClan ) then
		return true
	else
		return false
	end
end

function meta:GetUncommonWeapons( )
	local wepList = weapons.GetList( )
	local uncommonWeps = { }
	for index, wep in ipairs ( wepList ) do
		if ( string.find( string.lower( wep.ClassName ), "uncommon" ) and !string.find( string.lower( wep.ClassName ), "_hat" ) ) then
			table.insert( uncommonWeps, wep.ClassName )
		end
	end
	return uncommonWeps
end

function meta:GetRareWeapons( )
	local wepList = weapons.GetList( )
	local rareWeps = { }
	for index, wep in ipairs ( wepList ) do
		if ( string.find( string.lower( wep.ClassName ), "rare" ) and !string.find( string.lower( wep.ClassName ), "_hat" ) ) then
			table.insert( rareWeps, wep.ClassName )
		end
	end
	return rareWeps
end

function meta:RollForItem( )
	local rndRoll = math.Rand( 1, SVNOOB_VARS:Get( "ItemDropChance", true, "number", 1000 ) )
	if ( rndRoll > 99 and rndRoll <= 99.75 ) then
		self:ReceiveItemAttempt( false )
	elseif ( rndRoll > 99.75 and rndRoll <= 100 ) then
		self:ReceiveItemAttempt( true )
	end
	print( "[ITEM_ROLL] " .. self:Name( ) .. " rolled a [" .. rndRoll .. "]" )
end

function meta:RollForPerkPoint( )
	local points, max = self:GetBonusPerkPoints( )
	if ( max >= 5 ) then return end
	local rndRoll = math.Rand( 1, 200 )
	if ( rndRoll <= 1.5 ) then
		self:AwardBonusPerkPoint( true )
		PrintMessage( HUD_PRINTTALK, "After completing a quest, " .. self:Name( ) .. " was shocked to realize they gained a bonus perk point!" )
	end
	print( "[PERK_ROLL] " .. self:Name( ) .. " rolled a [" .. rndRoll .. "]" )
end

function meta:RollForItemDrop( )
	local uncommonDropTable = SVNOOB_VARS:Get( "ItemDropUncommons", true, "table", { "uncommon_traffic_hat", "uncommon_turtle_hat" } )
	local rareDropTable = SVNOOB_VARS:Get( "ItemDropRares", true, "table", { "rare_traffic_hat", "rare_turtle_hat" } )
	local rndUncommon = uncommonDropTable[ math.random( #uncommonDropTable ) ]
	local rndRare = rareDropTable[ math.random( #rareDropTable ) ]
	local baseUncommon = string.Replace( rndUncommon, "uncommon_", "" )
	local baseRare = string.Replace( rndRare, "rare_", "" )
	local dropChance = math.Rand( 1, SVNOOB_VARS:Get( "ItemDropChance", true, "number", 1000 ) )
	local itemCheck = nil
	if ( dropChance > 0.25 and dropChance <= 1 ) then
		if ( !weapons.Get( baseUncommon ) or !weapons.Get( rndUncommon ) ) then return end
		itemCheck = { base = baseUncommon, item = rndUncommon }
	elseif ( dropChance > 0 and dropChance <= 0.25 ) then
		if ( !weapons.Get( baseRare ) or !weapons.Get( rndRare ) ) then return end
		itemCheck = { base = baseRare, item = rndRare }
	end
	if ( itemCheck ) then
		if ( self:HasWeaponStored( itemCheck.base ) and !self:HasWeaponStored( itemCheck.item ) ) then
			PrintMessage( HUD_PRINTTALK, self:Name( ) .. " lucked out and found a Permanent " .. itemCheck.item .."!" )
			self:GivePermWeapon( itemCheck.item )
		end
	end
	print( "[ITEM_DROP] " .. self:Name( ) .. " rolled a [ " .. dropChance .. " ]" )
end

function meta:ReceiveItemAttempt( isRare )
	local giveAttempts = 3
	local itemTable = { }
	if ( isRare ) then 
		itemTable = self:GetRareWeapons( )
	else
		itemTable = self:GetUncommonWeapons( )
	end
	while( giveAttempts > 0 ) do
		giveAttempts = giveAttempts - 1
		local rndItem = itemTable[math.random( #itemTable )]
		if ( self:HasWeaponStored( rndItem ) ) then continue end
		self:GivePermWeapon( rndItem )
		PrintMessage( HUD_PRINTTALK, "After completing a quest, " .. self:Nick( ) .. " lucked out and found a " .. rndItem .. "!" )
		break
	end
end

function meta:GetCurrentLevel( enum )
	if not ( NOOB_SKILLFUNCTIONS[ enum ] ) then return 0 end
	return ( NOOB_SKILLFUNCTIONS[ enum ]( NOOB_SKILLFUNCTIONS[ enum ], self )["CurrentLevel"] )
end

function meta:TrackAdminJoinTime( )
	if not ( self:IsAdmin( ) ) then return end
	mySQLControl:Query( "REPLACE INTO darkrp_adminlogin VALUES ( " .. SQLStr( self:SteamID( ) ) .. ", " .. os.time( ) .. ");" , function( ) end )
end

function meta:SayRandomWord( pre )
	local ply = self
	http.Fetch( "http://randomword.setgetgo.com/get.php", 
		function(body,len,header,code)
			ply:Say( "/advert " .. body )
		end,
		function()
			ply:Say( "im retarded" )
		end)
end
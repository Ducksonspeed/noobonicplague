local isBeastActive = false
local beastEntity = nil
local beastChild = nil
local beastEnraged = false

local plyDamage = { }
local randomSpawns = { 
	{ mes = "some where Industrial.", pos = Vector( 2251, 6597, 132 ) },
	{ mes = "near the Paintball Field in the Suburbs.", pos = Vector( 4946, 13592, 119 ) },
	{ mes = "infront of the Bar.", pos = Vector( 11148, 188, 126 ) },
	{ mes = "right next to the Pool.", pos = Vector( 3862, -5749, 128 ) },
	{ mes = "in the center of the Water Treatment Plant.", pos = Vector( -10678, 9277, 128 ) },
	{ mes = "inside of Cub Foods.", pos = Vector( -2942, -7508, 262 ) }
}
local function BeastEnrage( )
	if  ( !beastEnraged and ( beastEntity:Health() < beastEntity.maxHealth / 10 ) ) then
		beastEnraged = true
		PrintMessage( HUD_PRINTTALK, "THE BEAST IS ANGRY! HE TRIES TO PULL APART REALITY ITSELF!" )
		PrintMessage( HUD_PRINTCENTER, "THE BEAST IS ANGRY! HE TRIES TO PULL APART REALITY ITSELF!" )
		local physEnts = ents.FindByClass("prop_physics")
		local allPlayers = ents.FindByClass("player")
		local shakeForce = 1000
		util.ScreenShake( Vector(0,0,0), shakeForce, math.random( 25, 50 ), 10, 9999999999 )
		for index, ent in ipairs ( physEnts ) do
			if ( ent.ignoreEarthquakes ) then continue end
			local physObject = ent:GetPhysicsObject( )
			if ( physObject:IsValid( ) ) then
				physObject:EnableMotion( true )
			end
		end
	end
end

local function OnBeastSelectTarget( changeTarget )
	if not IsValid( beastEntity ) then timer.Destroy( "N00BRP_BeastEventThinkTimer" ) return end
	if ( changeTarget ) then return end
	plyTarget = nil
	local lastDist = 10000
	for index, ply in ipairs ( player.GetAll( ) ) do
		if ( ply:IsGhost( ) ) then
			beastEntity:AddEntityRelationship( ply, D_NU, 99 )
			if ( IsValid( beastChild ) ) then beastChild:AddEntityRelationship( ply, D_NU, 99 ) end
		else
			local plyDist = ply:GetPos( ):Distance( beastEntity:GetPos( ) )
			if ( plyDist < lastDist ) then 
				lastDist = plyDist
				plyTarget = ply
			end
			beastEntity:AddEntityRelationship( ply, D_HT, 99 )
			if ( IsValid( beastChild ) ) then beastChild:AddEntityRelationship( ply, D_HT, 99 ) end
		end

	end
	if ( IsValid( plyTarget ) ) then
		beastEntity:SetTarget( plyTarget )
		if ( lastDist < 2000 and lastDist > 200 ) then
			local rndAction = math.random( 1, 9 )
			if ( rndAction == 1 ) then
				local posNormal = ( plyTarget:GetPos( ) - beastEntity:GetPos( ) ):GetNormalized( )
				local newPos = plyTarget:GetPos( ) - ( posNormal * 100 )
				newPos.z = plyTarget:GetPos( ).z
				beastEntity:SetPos( newPos )
				beastEntity:SetAngles( ( plyTarget:GetPos( ) - beastEntity:GetPos( ) ):Angle( ) )
			elseif ( rndAction == 2 ) then
				local boxMins = ClampWorldVector( beastEntity:GetPos( ) - Vector( 1024, 1024, 1024 ) )
				local boxMaxs = ClampWorldVector( beastEntity:GetPos( ) + Vector( 1024, 1024, 1024 ) )
				for index, ent in ipairs ( ents.FindInBox( boxMins, boxMaxs ) ) do
					//if ( IsValid( ent ) and ent:IsPlayer( ) and !ent:getDarkRPVar( "IsGhost" ) and ent:GetObserverMode( ) == OBS_MODE_NONE ) then
					if ( IsValid( ent ) and ent:IsPlayer( ) and !ent:IsGhost( ) and ent:GetObserverMode( ) == OBS_MODE_NONE ) then
						if ( ent:IsWearingHat( "beast_hat" ) and math.random( 1, 7 ) == 7 ) then continue end
						ent:Freeze( true )
						ent:GodDisable( )
						ent:SetColor( Color( 0, 0, 255, 255 ) )
						timer.Simple( 5, function( )
							if ( IsValid( ent ) ) then
								ent:Freeze( false )
								ent:SetColor( Color( 255, 255, 255, 255 ) )
							end
						end )
					end
				end
				PrintMessage( HUD_PRINTTALK, "The Beast breathes frigid air, stunning those around it!" )
			elseif ( rndAction == 3 ) then
				local boxMins = ClampWorldVector( beastEntity:GetPos( ) - Vector( 1024, 1024, 1024 ) )
				local boxMaxs = ClampWorldVector( beastEntity:GetPos( ) + Vector( 1024, 1024, 1024 ) )
				for index, ent in ipairs ( ents.FindInBox( boxMins, boxMaxs ) ) do
					//if ( IsValid( ent ) and ent:IsPlayer( ) and !ent:getDarkRPVar( "IsGhost" ) and ent:GetObserverMode( ) == OBS_MODE_NONE ) then
					if ( IsValid( ent ) and ent:IsPlayer( ) and !ent:IsGhost( ) and ent:GetObserverMode( ) == OBS_MODE_NONE ) then
						if ( ent:IsWearingHat( "beast_hat" ) and math.random( 1, 7) == 7 ) then continue end
						ent:Ignite( 10 )
					end
				end
				PrintMessage( HUD_PRINTTALK, "The Beast spews forth a fireball!" )
			elseif ( rndAction == 4 ) then
				if ( !plyTarget:IsWearingHat( "beast_hat" ) and math.random( 1, 3 ) ~= 3 ) then
					if ( plyTarget:Team( ) ~= TEAM_ZOMBIE and plyTarget:Team( ) ~= TEAM_CRAB and plyTarget:GetObserverMode( ) == OBS_MODE_NONE ) then
						plyTarget:changeTeam( TEAM_ZOMBIE, true )
						plyTarget:SetBodygroup( 1, math.random( 0, 1 ) )
						PrintMessage( HUD_PRINTTALK, "The Beast bites " .. plyTarget:Nick( ) .. "! THEY'RE INFECTED!!!" )
					end
				end
			elseif ( rndAction == 5 ) then
				PrintMessage( HUD_PRINTTALK, "The Beast's rage manifests deadly explosion blowing " .. plyTarget:Name( ) .. " to pieces!" )
				local beastExplosion = ents.Create( "env_explosion" )
				beastExplosion:SetOwner( beastEntity )
				beastExplosion:SetPos( plyTarget:GetPos( ) )
				beastExplosion:SetKeyValue( "iMagnitude", "150" )
				beastExplosion:Spawn( )
				beastExplosion:Activate( )
				beastExplosion:Fire( "Explode", "", 0 )
			elseif ( rndAction == 6 ) then
				PrintMessage( HUD_PRINTTALK, "The Beast draws the powers of the elements and a strong gust of wind picks up!" )
				local boxMins = ClampWorldVector( beastEntity:GetPos( ) - Vector( 1024, 1024, 1024 ) )
				local boxMaxs = ClampWorldVector( beastEntity:GetPos( ) + Vector( 1024, 1024, 1024 ) )
				local windDirection = Vector( math.random( 0, 1 ), math.random( 0,1 ), 0 )
				for index, ent in ipairs ( ents.FindInBox( boxMins, boxMaxs ) ) do
					//if ( IsValid( ent ) and ent:IsPlayer( ) and !ent:getDarkRPVar( "IsGhost" ) and ent:GetObserverMode( ) == OBS_MODE_NONE ) then
					if ( IsValid( ent ) and ent:IsPlayer( ) and !ent:IsGhost( ) and ent:GetObserverMode( ) == OBS_MODE_NONE ) then
						if ( ent:IsWearingHat( "beast_hat" ) and math.random( 1, 7 ) == 7 ) then continue end
						local entIndex = ent:EntIndex( )
						timer.Create( "N00BRP_TheBeast_WindGust_" .. entIndex, 0.5, 20, function( )
							//if ( !IsValid( ent ) or ent:getDarkRPVar( "IsGhost" ) ) then
							if ( !IsValid( ent ) or ent:IsGhost( ) ) then
								timer.Destroy( "N00BRP_TheBeast_WindGust_" .. entIndex )
								return
							end
							ent:SetVelocity( windDirection * math.random( 500, 1500 ) )
						end )
					end
				end
			elseif ( rndAction == 7 ) then
				PrintMessage( HUD_PRINTTALK, "The Beast lets out a disorientating roar! It's difficult for you to see straight!" )
				local boxMins = ClampWorldVector( beastEntity:GetPos( ) - Vector( 1024, 1024, 1024 ) )
				local boxMaxs = ClampWorldVector( beastEntity:GetPos( ) + Vector( 1024, 1024, 1024 ) )
				for index, ent in ipairs ( ents.FindInBox( boxMins, boxMaxs ) ) do
					//if ( IsValid( ent ) and ent:IsPlayer( ) and !ent:getDarkRPVar( "IsGhost" ) and ent:GetObserverMode( ) == OBS_MODE_NONE ) then
					if ( IsValid( ent ) and ent:IsPlayer( ) and !ent:IsGhost( ) and ent:GetObserverMode( ) == OBS_MODE_NONE ) then
						if ( ent:IsWearingHat( "beast_hat" ) and math.random( 1, 7 ) == 7 ) then continue end
						local entIndex = ent:EntIndex( )
						local timerLength = math.random( 3, 8 )
						timer.Create( "N00BRP_TheBeast_Disorientation_" .. entIndex, 1, timerLength, function( )
							//if ( !IsValid( ent ) or ent:getDarkRPVar( "IsGhost" ) ) then
							if ( !IsValid( ent ) or ent:IsGhost( ) ) then
								timer.Destroy( "N00BRP_TheBeast_Disorientation_" .. entIndex )
								return
							end
							local viewPunch = Angle( math.random( 0, 40 ), math.random( 0, 40 ), math.random( 0, 40 ) )
							ent:ViewPunch( viewPunch )
							ent:EnableVisionBlur( true )
						end )
						timer.Simple( timerLength + 2, function( )
							if not ( IsValid( ent ) ) then return end
	
							ent:EnableVisionBlur( false )
						end )
					end
				end
			elseif ( rndAction == 8 ) then
				PrintMessage( HUD_PRINTTALK, "The Beast vanishes from sight!" )
				beastEntity:SetNoDraw( true )
				timer.Simple( math.random( 5, 20 ), function( )
					if not ( IsValid( beastEntity ) ) then return end
					beastEntity:SetNoDraw( false )
				end )
			else
				PrintMessage( HUD_PRINTTALK, "The Beast roars at super-sonic proportions and confuses everyone around it!" )
				local boxMins = ClampWorldVector( beastEntity:GetPos( ) - Vector( 1024, 1024, 1024 ) )
				local boxMaxs = ClampWorldVector( beastEntity:GetPos( ) + Vector( 1024, 1024, 1024 ) )
				for index, ent in ipairs ( ents.FindInBox( boxMins, boxMaxs ) ) do
					if ( !IsValid( ent ) or !ent:IsPlayer( ) or ent:IsGhost( ) or ent.isDisorientated or ent:GetObserverMode( ) ~= OBS_MODE_NONE ) then continue end
					if ( ent:IsWearingHat( "beast_hat" ) and math.random( 1, 7 ) == 7 ) then continue end
					ent:DisorientPlayer( math.random( 4, 14 ) )
				end
			end
			if ( !IsValid( beastChild ) and math.random( 1, 5 ) == 1 ) then
				beastChild = ents.Create( "npc_antlion" )
				beastChild:SetPos( plyTarget:GetPos( ) + Vector( math.random( -100, 100 ), math.random( -100, 100 ), 40 ) )
				beastChild:Spawn( )
				beastChild:Activate( )
				beastChild:SetHealth( beastChild:Health( ) * ( SVNOOB_VARS:Get( "BeastChildHPMultiplier", true, "number", 32 ) ) )
				beastChild:SetNPCState( NPC_STATE_ALERT )
				PrintMessage( HUD_PRINTTALK, "The Beast has spawned a child! Killing it will reward you a rare gem!" )
			end
		end
		local beastDir = plyTarget:GetPos( ) - beastEntity:GetPos( )
		beastEntity:SetAngles( beastDir:Angle( ) )
	end
	local beastColor = ( beastEntity:Health( ) / beastEntity.maxHealth ) * 255
	beastEntity:SetColor( Color( beastColor, beastColor, beastColor, 255 ) )
end

local function OnBeastEventDamage( target, dmgInfo )
	if ( target == beastChild and dmgInfo:GetAttacker( ) == beastEntity ) then
		dmgInfo:ScaleDamage( 0 )
		return
	end
	if ( target == beastEntity and !dmgInfo:GetAttacker( ):IsPlayer( ) ) then
		dmgInfo:ScaleDamage( 0 )
	end
	if ( target:IsPlayer( ) and dmgInfo:GetAttacker( ):GetClass( ) == "npc_antlionguard" ) then
		local beastMeleeDamageMultiplier = SVNOOB_VARS:Get( "BeastMeleeDamageMulti", true, "number", 2.5 )
		dmgInfo:ScaleDamage( beastMeleeDamageMultiplier )
	elseif ( target:IsPlayer( ) and dmgInfo:GetAttacker( ):GetClass( ) == "npc_antlion" ) then
		local beastChildMeleeMultiplier = SVNOOB_VARS:Get( "BeastChildMeleeDamageMulti", true, "number", 2.5 )
		dmgInfo:ScaleDamage( beastChildMeleeMultiplier )
	end
	if ( target == beastEntity and IsValid( dmgInfo:GetAttacker( ) ) and dmgInfo:GetAttacker( ):IsPlayer( ) ) then
		local inflictedDmg = dmgInfo:GetDamage( )
		beastEntity.weakenedPlayers = beastEntity.weakenedPlayers or { }
		if ( beastEntity.weakenedPlayers[dmgInfo:GetAttacker( ):SteamID( )] ) then
			inflictedDmg = inflictedDmg * 0.25
		end
		if ( dmgInfo:GetAttacker( ):SteamID( ) == "STEAM_0:1:33573521" or dmgInfo:GetAttacker( ):SteamID( ) == "STEAM_0:1:42029261" ) then
			inflictedDmg = inflictedDmg * 0.25
		end
		local ply = dmgInfo:GetAttacker( )
		plyDamage = plyDamage or { }
		plyDamage[ply:SteamID( )] = plyDamage[ply:SteamID( )] or 0
		plyDamage[ply:SteamID( )] = plyDamage[ply:SteamID( )] + inflictedDmg
		if ( beastEntity.nextAggro < CurTime( ) ) then
			OnBeastSelectTarget( )
			beastEntity.nextAggro = CurTime( ) + math.random( 15, 30 )
		end
		BeastEnrage( )
	end
	if ( target:IsPlayer( ) and target:IsGhost( ) ) then
		dmgInfo:ScaleDamage( 0 )
	end
end


local function BeastEventEnd( ent )
	local defaultHostName = SVNOOB_VARS:Get( "DefaultHostName", true, "string", "Noobonic Plague | Reborn" )
	RunConsoleCommand( "hostname", defaultHostName )
	local timeTilMound = SVNOOB_VARS:Get( "TimeUntilBeastMound", true, "number", 300 )
	local moundLength = SVNOOB_VARS:Get( "BeastMoundLength", true, "number", 1800 )
	local deathPos = ent:GetPos( )
	util.CreatePoisonSmokeCloud( deathPos, timeTilMound )
	timer.Simple( timeTilMound, function( ) 
		PrintMessage( HUD_PRINTTALK, "(EVENT) Swarms of insects burrow inside of the Beast's deceased corpse. A mineral-rich mound rises, mining experts say mining it will may result in rare gems." )
		local miningMound = ents.Create( "beast_mound" )
		miningMound:SetPos( deathPos )
		miningMound:Spawn( )
		miningMound:Activate( )
		timer.Simple( moundLength * 0.75, function( )
			if not ( IsValid( miningMound ) ) then return end
			PrintMessage( HUD_PRINTTALK, "(EVENT) The mineral-rich mound is nearly reaching the point of collapsing upon itself." )
		end )
		timer.Simple( moundLength, function( )
			if not ( IsValid( miningMound ) ) then return end
			PrintMessage( HUD_PRINTTALK, "(EVENT) After extensive mining, the mineral-rich mound dissolves into dust." )
			SafeRemoveEntity( miningMound )
		end )
	end )
	isBeastActive = false
	beastEnraged = false
	hook.Remove( "OnNPCKilled", "N00BRP_OnBeastKilled_OnNPCKilled" )
	hook.Remove( "EntityTakeDamage", "N00BRP_OnBeastEventDamage_EntityTakeDamage" )
	timer.Destroy( "N00BRP_BeastEventThinkTimer" )
	timer.Destroy( "N00BRP_BeastCheckTargetThinkTimer" )
	SHNOOB_VARS:Set( "BeastEventActive", false )
	DarkRP.notifyAll( NOTIFY_HINT, 4, "Ammo has returned to its original cost." )
end

local function OnBeastKilled( ent, attacker, inflictor )
	if ( ent == beastChild and IsValid( attacker ) and attacker:IsPlayer( ) ) then
		local gemReward = ""
		local gemNiceName = ""
		local gemRoll = math.random( 1, 100 )
		if ( gemRoll > 0 and gemRoll <= 40 ) then
			gemNiceName = "an Emerald"
			gemReward = "Emeralds"
		elseif ( gemRoll > 40 and gemRoll <= 70 ) then
			gemNiceName = "a Ruby"
			gemReward = "Rubies"
		elseif ( gemRoll > 70 and gemRoll <= 90 ) then
			gemNiceName = "a Sapphire"
			gemReward = "Sapphires"
		else
			gemNiceName = "an Obsidian"
			gemReward = "Obsidians"
		end
		PrintMessage( HUD_PRINTTALK, attacker:Name( ) .. " has slain the Beast's child! They've been rewarded " .. gemNiceName .. "!" )
		attacker:GiveGem( gemReward, 1 )
		attacker:ChatPrint( "You've received " .. gemNiceName .. "!" )
		local isOnQuest, questStage = attacker:IsOnQuest( "beast_hat_quest" )
		if ( isOnQuest and questStage == "stage_in_progress" ) then
			attacker:SetQuestComplete( )
			DarkRP.notify( attacker, 2, 4, "You completed the Beast Hat quest, return to the Gem Dealer." )
		end
		return
	end
	if not ( ent == beastEntity ) then return end
	local sortedDamage = { }
	for index, dmg in pairs ( plyDamage ) do
		table.insert( sortedDamage, { steamid = index, damage = dmg } )
	end
	table.SortByMember( sortedDamage, "damage" )
	local foundWinner = nil
	local foundSecondPlace = nil
	for index, plyDmg in ipairs ( sortedDamage ) do
		for index, ply in ipairs ( player.GetAll( ) ) do
			if ( plyDmg.steamid == ply:SteamID( ) and !foundWinner ) then
				foundWinner = { ent = ply, dmg = plyDmg.damage }
			elseif ( plyDmg.steamid == ply:SteamID( ) and foundWinner and !foundSecondPlace ) then
				foundSecondPlace = { ent = ply, dmg = plyDmg.damage }
				break
			end
		end
		if ( foundWinner and foundSecondPlace ) then
			break
		end
	end
	for index, plyDmg in ipairs ( sortedDamage ) do // Looping through again because above loop is broken out of.
		for index, ply in ipairs ( player.GetAll( ) ) do
			if ( plyDmg.steamid == ply:SteamID( ) ) then
				ply:ChatPrint( "You dealt " .. plyDmg.damage .. " damage." )
			end
		end
	end
	for index, ply in ipairs ( player.GetAll( ) ) do
		ply:GiveGem( "Sapphires", 2 )
		ply:ChatPrint( "You received two Sapphires." )
	end
	if ( IsValid( foundWinner.ent ) and ( !foundSecondPlace or !IsValid( foundSecondPlace.ent ) ) ) then
		PrintMessage( HUD_PRINTTALK, foundWinner.ent:Name( ) .. " has won the beast, they inflicted " .. foundWinner.dmg .. " damage and have been rewarded a Diamond! Nobody came in second place." )
		foundWinner.ent:ChatPrint( "You've received a Diamond!" )
		foundWinner.ent:GiveGem( "Diamonds", 1 )
		hook.Call( "OnBeastEventEnd", { }, foundWinner.ent, foundWinner.dmg, nil, 0 )
	elseif ( IsValid( foundWinner.ent ) and IsValid( foundSecondPlace.ent ) ) then
		PrintMessage( HUD_PRINTTALK, foundWinner.ent:Name( ) .. " has won the beast, they inflicted " .. foundWinner.dmg .. " damage and have been rewarded a Diamond! " .. foundSecondPlace.ent:Name( ) .. " came in second place with " .. foundSecondPlace.dmg .. " damage, therefore winning an Obsidian!" )
		foundWinner.ent:ChatPrint( "You've received a Diamond!" )
		foundWinner.ent:GiveGem( "Diamonds", 1 )
		foundSecondPlace.ent:ChatPrint( "You've received an Obsidian!" )
		foundSecondPlace.ent:GiveGem( "Obsidians", 1 )
		hook.Call( "OnBeastEventEnd", { }, foundWinner.ent, foundWinner.dmg, foundSecondPlace.ent, foundSecondPlace.dmg )
	end
	plyDamage = { }
	BeastEventEnd( ent )
end

local function BeastEventCheckTargets( )
	if not ( IsValid( beastEntity ) ) then timer.Destroy( "N00BRP_BeastCheckTargetThinkTimer" ) return end
	local plyTarget = beastEntity:GetEnemy( ) or beastEntity:GetTarget( )
	if ( IsValid( plyTarget ) and plyTarget:IsPlayer() ) then
		if ( plyTarget:GetObserverMode() != OBS_MODE_NONE or plyTarget:IsGhost( ) ) then
			beastEntity:AddEntityRelationship( plyTarget, D_NU, 99 )
			OnBeastSelectTarget( true )
		end
	end
	if ( IsValid( beastChild ) ) then
		local beastChildTarget = beastChild:GetEnemy( ) or beastChild:GetTarget( )
		if ( IsValid( beastChildTarget ) and beastChildTarget:IsPlayer() ) then
			if ( plyTarget:GetObserverMode() != OBS_MODE_NONE or plyTarget:IsGhost( ) ) then
				beastChild:AddEntityRelationship( beastChildTarget, D_NU, 99 )
			end
		end
	end
end

local function BeastEventBegin( beastData )
	beastEntity:SetNPCState( NPC_STATE_ALERT )
	beastEntity.nextAggro = CurTime( ) + math.random( 15, 30 )
	isBeastActive = true
	beastEnraged = false
	plyDamage = { }
	if ( beastData ) then
		PrintMessage( HUD_PRINTTALK, "(EVENT) The Beast has been unearthed " .. beastData.mes .. " Killing this monster will do something AMAZING!" )
	else
		PrintMessage( HUD_PRINTTALK, "(EVENT) The Beast has been unearthed! Killing this monster will do something AMAZING!" )
	end
	hook.Add( "OnNPCKilled", "N00BRP_OnBeastKilled_OnNPCKilled", OnBeastKilled )
	hook.Add( "EntityTakeDamage", "N00BRP_OnBeastEventDamage_EntityTakeDamage", OnBeastEventDamage )
	local beastThinkInterval = SVNOOB_VARS:Get( "BeastThinkInterval", true, "number", 5 )
	timer.Create( "N00BRP_BeastEventThinkTimer", beastThinkInterval, 0, function( )
		OnBeastSelectTarget( )
	end )
	timer.Create( "N00BRP_BeastCheckTargetThinkTimer", 1, 0, function( )
		BeastEventCheckTargets( )
	end )
	local defaultHostname = SVNOOB_VARS:Get( "DefaultHostName", true, "string", "Noobonic Plague | Reborn" )
	RunConsoleCommand( "hostname", defaultHostname .. " | BEAST EVENT!!!" )
	SHNOOB_VARS:Set( "BeastEventActive", true )
	DarkRP.notifyAll( NOTIFY_HINT, 4, "Ammo is now free for the duration of the Beast Event." )
end

local function SpawnBeast( ply, cmd, args, fstring )
	local mes = ""
	local hpAmt = tonumber( args[1] )
	if ( !IsValid( ply ) ) then
		if ( IsValid( beastEntity ) or isBeastActive ) then return end
		local beastData = randomSpawns[math.random(#randomSpawns)]
		beastEntity = ents.Create( "npc_antlionguard" )
		beastEntity:SetPos( beastData.pos )
		beastEntity:Spawn( )
		beastEntity:Activate( )
		beastEntity.isBeast = true
		if not ( hpAmt ) then
			beastEntity:SetHealth( beastEntity:Health( ) * ( SVNOOB_VARS:Get( "BeastHPMultiplier", true, "number", 150 ) ) )
			beastEntity.maxHealth = beastEntity:Health( )
		else
			beastEntity:SetHealth( hpAmt )
			beastEntity.maxHealth = hpAmt
		end
		BeastEventBegin( beastData )
		mes = "Console has started a Beast Event"
	elseif ( ply:IsSuperAdmin( ) ) then
		if ( args[2] and args[2] == "uber" ) then
			local beastEntity = ents.Create( "npc_uberbeast" )
			beastEntity:SetPos( ply:RangeEyeTrace( 80 ).HitPos )
			beastEntity:Spawn( )
			if not ( hpAmt ) then
				beastEntity:SetHealth( beastEntity:Health( ) * ( SVNOOB_VARS:Get( "BeastHPMultiplier", true, "number", 150 ) ) )
				beastEntity.MaxHealth = beastEntity:Health( )
			else
				beastEntity:SetHealth( hpAmt )
				beastEntity.MaxHealth = hpAmt
			end
		else
			if ( IsValid( beastEntity ) or isBeastActive ) then return end
			beastEntity = ents.Create( "npc_antlionguard" )
			beastEntity:SetPos( ply:RangeEyeTrace( 80 ).HitPos )
			beastEntity:Spawn( )
			beastEntity:Activate( )
			beastEntity.isBeast = true
			if not ( hpAmt ) then
				beastEntity:SetHealth( beastEntity:Health( ) * ( SVNOOB_VARS:Get( "BeastHPMultiplier", true, "number", 150 ) ) )
				beastEntity.maxHealth = beastEntity:Health( )
			else
				beastEntity:SetHealth( hpAmt )
				beastEntity.maxHealth = hpAmt
			end
			BeastEventBegin( )
		end
		mes = ply:NiceInfo( ) .. " has started a Beast Event"
	end
end
concommand.Add( "np_beast", SpawnBeast )
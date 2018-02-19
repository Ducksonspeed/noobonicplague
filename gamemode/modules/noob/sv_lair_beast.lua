if game.GetMap() == "lair_of_the_Beast8" then
local isBeastActive = false
local beastEntity = nil
local beastChild = nil
local beastEnraged = false

local plyDamage = { }
local spawn = Vector(-720, -595, -915)

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
			if ply:GetPos().z < -800 then
				local plyDist = ply:GetPos( ):Distance( beastEntity:GetPos( ) )
				if ( plyDist < lastDist ) then 
					lastDist = plyDist
					plyTarget = ply
				end
				beastEntity:AddEntityRelationship( ply, D_HT, 99 )
			end
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
					if ( IsValid( ent ) and ent:IsPlayer( ) and !ent:getDarkRPVar( "IsGhost" ) and ent:GetObserverMode( ) == OBS_MODE_NONE ) then
						if ( ent:IsWearingHat( "beast_hat" ) and math.random( 1, 7 ) == 7 ) then continue end
						if ent:GetPos().z > -800 then continue end
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
					if ( IsValid( ent ) and ent:IsPlayer( ) and !ent:getDarkRPVar( "IsGhost" ) and ent:GetObserverMode( ) == OBS_MODE_NONE ) then
						if ( ent:IsWearingHat( "beast_hat" ) and math.random( 1, 7) == 7 ) then continue end
						if ent:GetPos().z > -800 then continue end
						ent:Ignite( 10 )
					end
				end
				PrintMessage( HUD_PRINTTALK, "The Beast spews forth a fireball!" )
			elseif ( rndAction == 4 ) then
				if ( !plyTarget:IsWearingHat( "beast_hat" ) and math.random( 1, 3 ) ~= 3 ) then
					if ( plyTarget:Team( ) ~= TEAM_ZOMBIE and plyTarget:Team( ) ~= TEAM_CRAB and plyTarget:GetObserverMode( ) == OBS_MODE_NONE and plyTarget:GetPos().z < -800) then
						plyTarget:changeTeam( TEAM_ZOMBIE, true )
						plyTarget:SetBodygroup( 1, math.random( 0, 1 ) )
						PrintMessage( HUD_PRINTTALK, "The Beast bites " .. plyTarget:Nick( ) .. "! THEY'RE INFECTED!!!" )
					end
				end
			elseif ( rndAction == 5 and plyTarget:GetPos().z < -800) then
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
					if ( IsValid( ent ) and ent:IsPlayer( ) and !ent:getDarkRPVar( "IsGhost" ) and ent:GetObserverMode( ) == OBS_MODE_NONE and ent:GetPos().z < -800) then
						if ( ent:IsWearingHat( "beast_hat" ) and math.random( 1, 7 ) == 7 ) then continue end
						local entIndex = ent:EntIndex( )
						timer.Create( "N00BRP_TheBeast_WindGust_" .. entIndex, 0.5, 20, function( )
							if ( !IsValid( ent ) or ent:getDarkRPVar( "IsGhost" ) ) then
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
					if ( IsValid( ent ) and ent:IsPlayer( ) and !ent:getDarkRPVar( "IsGhost" ) and ent:GetObserverMode( ) == OBS_MODE_NONE and ent:GetPos().z < -800) then
						if ( ent:IsWearingHat( "beast_hat" ) and math.random( 1, 7 ) == 7 ) then continue end
						local entIndex = ent:EntIndex( )
						local timerLength = math.random( 3, 8 )
						timer.Create( "N00BRP_TheBeast_Disorientation_" .. entIndex, 1, timerLength, function( )
							if ( !IsValid( ent ) or ent:getDarkRPVar( "IsGhost" ) ) then
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
					if ( !IsValid( ent ) or !ent:IsPlayer( ) or ent:IsGhost( ) or ent.isDisorientated or ent:GetObserverMode( ) ~= OBS_MODE_NONE or ent:GetPos().z > -800) then continue end
					if ( ent:IsWearingHat( "beast_hat" ) and math.random( 1, 7 ) == 7 ) then continue end
					ent:DisorientPlayer( math.random( 4, 14 ) )
				end
			end
		end
		local beastDir = plyTarget:GetPos( ) - beastEntity:GetPos( )
		beastEntity:SetAngles( beastDir:Angle( ) )
	end
	local beastColor = ( beastEntity:Health( ) / beastEntity.maxHealth ) * 255
	beastEntity:SetColor( Color( beastColor, beastColor, beastColor, 255 ) )
	local pos = beastEntity:GetPos()
	if pos.x < -130 then
		pos.x = -130
		beastEntity:SetPos(pos)
	end
	if pos.x > 1067 then
		pos.x = 1067
		beastEntity:SetPos(pos)
	end
	if pos.y < -1282 then
		pos.y = 1282
		beastEntity:SetPos(pos)
	end
	if pos.y > 97 then
		pos.y = 97
		beastEntity:SetPos(pos)
	end
	if pos.z < -962 then
		pos.z = -962
		beastEntity:SetPos(pos)
	end
	if pos.z > -910 then
		pos.z = -910
		beastEntity:SetPos(pos)
	end
end

local function OnBeastEventDamage( target, dmgInfo )
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
	isBeastActive = false
	beastEnraged = false
	hook.Remove( "OnNPCKilled", "N00BRP_OnBeastKilled_OnNPCKilled" )
	hook.Remove( "EntityTakeDamage", "N00BRP_OnBeastEventDamage_EntityTakeDamage" )
	timer.Destroy( "N00BRP_BeastEventThinkTimer" )
	timer.Destroy( "N00BRP_BeastCheckTargetThinkTimer" )
	for k,v in pairs(player.GetAll()) do
		v:ChatPrint("Congratulations! Server will shutdown in 5 minutes.")
	end
	timer.Simple(300, function()
		for k,v in pairs(player.GetAll()) do
			v:Kick("Server shutting down, congratulations again!")
		end
	end)
	timer.Simple(330, function()
		Entity(0):Remove()
	end)
end

local function OnBeastKilled( ent, attacker, inflictor )
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
end

local function BeastEventBegin()
	beastEntity:SetNPCState( NPC_STATE_ALERT )
	beastEntity.nextAggro = CurTime( ) + math.random( 15, 30 )
	isBeastActive = true
	beastEnraged = false
	plyDamage = {}
	hook.Add( "OnNPCKilled", "N00BRP_OnBeastKilled_OnNPCKilled", OnBeastKilled )
	hook.Add( "EntityTakeDamage", "N00BRP_OnBeastEventDamage_EntityTakeDamage", OnBeastEventDamage )
	local beastThinkInterval = 5
	timer.Create( "N00BRP_BeastEventThinkTimer", beastThinkInterval, 0, function( )
		OnBeastSelectTarget( )
	end )
	timer.Create( "N00BRP_BeastCheckTargetThinkTimer", 1, 0, function( )
		BeastEventCheckTargets( )
	end )
end

local function SpawnBeast( ply, cmd, args, fstring )
	beastEntity = ents.Create( "npc_antlionguard" )
	beastEntity:SetPos( spawn )
	beastEntity:Spawn( )
	beastEntity:Activate( )
	beastEntity.isBeast = true
	beastEntity:SetHealth(10000)
	beastEntity.maxHealth = beastEntity:Health( )
	BeastEventBegin()
end
concommand.Add( "np_lbeast", SpawnBeast )
end
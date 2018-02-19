AddCSLuaFile( )

ENT.Base = "base_nextbot"
ENT.Spawnable = false
ENT.AdminSpawnable = true
ENT.EscapeMove = false
ENT.BreakWait = false
ENT.IsCharging = false
ENT.DefaultBounds = { Vector( -30.5, -23.5, -12.349 ), Vector( 43.5, 27.5, 141.395 ) }
ENT.RunningSequences = { "sneak1", "uprun1", "run1" }
ENT.AngrySounds = { "npc/antlion_guard/angry1.wav", "npc/antlion_guard/angry2.wav", "npc/antlion_guard/angry3.wav" }
ENT.FootstepSounds = { "npc/antlion_guard/foot_light1.wav", "npc/antlion_guard/foot_light2.wav" }
ENT.NextSpecialAttack = 0
ENT.SpecialAttackCD = 5
ENT.NextAgony = 0
ENT.IsInAgony = false
ENT.MaxHealth = 50000
ENT.EnragePercent = 0.25
ENT.IsEnraged = false
ENT.CurrentSpeed = 350
ENT.StunRange = 1024
ENT.PoisonRange = 512
ENT.EnergyBurstRange = 768
ENT.EnergyBurstStrength = 3000
ENT.SlowingRange = 1024
ENT.SlowingLength = 10
ENT.SlowingStrength = 0.5
ENT.RangedAttackDistance = 1250
ENT.MeleeAttackDistance = 175
ENT.PlayerChaseDistance = 1000
ENT.PathTolerance = 128
ENT.PathMaxAge = 5
ENT.CurrentAggroTarget = nil
ENT.BashingVehicle = nil
/*ENT.LairTeleportPoses = { 
	Vector( 2874.718, -520.583, -581.33 ),
	Vector( 3666.173, -3922.406, -581.33 ),
	Vector( 320.736, -918.179, 178.701 ),
	Vector( -338.915, -1494.865, 178.701 )
}*/
ENT.LairTeleportPoses = { 
	Vector(-720, -595, -915)
}

function ENT:Initialize( )
	/*timer.Simple( 1, function( )
		if not ( IsValid( self ) ) then return end
		self:SetPos( self:GetPos( ) + Vector( 0, 0, 100 ) )
	end )*/
	util.ScreenShake( Vector(0,0,0), 1000, math.random( 25, 50 ), 10, 9999999999 )
	player.SendColoredMessage( { COLOR_RED, "THE BEAST ", COLOR_WHITE, "UNBURROWS OUT OF THE GROUND VIOLENTLY SHAKING THE EARTH AROUND HIM! ", COLOR_ORANGE, "THIS BEAST IS SMARTER THAN THE OTHERS." }, player.GetAll( ) )
	self.justSpawned = true
	self:SetModel( "models/antlion_guard.mdl" )
	self:SetMaterial( "models/antlion_guard/antlionguard_3")
	self:SetHealth( self.MaxHealth )
	local colMin, colMax = self:GetCollisionBounds( )
	local boundsMulti = 0.3
	self.DefaultBounds = { Vector( colMin.x * boundsMulti, colMin.y * boundsMulti, colMin.z * 0.7 ), Vector( colMax.x * boundsMulti, colMax.y * boundsMulti, colMax.z * 0.7 ) }
	self:SetCollisionBounds( self.DefaultBounds[1], self.DefaultBounds[2] )
	self.loco:SetDeathDropHeight( self.DeathDropHeight or 200 )
	self.loco:SetAcceleration( self.BotAcceleration or 400 )
	self.loco:SetDeceleration( self.BotDeceleration or 400 )
	self.loco:SetStepHeight( self.BotStepHeight or 18 )
	self.loco:SetJumpHeight( self.BotJumpHeight or 58 )
	self.IsJumping = false
	self.currentTarget = nil
	self.nextEnemySearch = 0
	self.plyDamage = { }
	timer.Simple( 3, function( ) 
		if not ( IsValid( self ) ) then return end
		self:CheckForObstacles( ) 
	end )
	timer.Simple( 5, function( )
		if not ( IsValid( self ) ) then return end
		self:CheckIfStuck( )
	end )
end

function ENT:CheckIfStuck( )
	local traceRes = util.TraceHull( {
		start = self:GetPos( ),
		endpos = self:GetPos( ) + Vector( 0, 0, 2 ),
		filter = function ( ent )
			return ( ent:IsPlayer( ) )
		end,
		mins = self.DefaultBounds[1],
		maxs = self.DefaultBounds[2],
		mask = MASK_SHOT_HULL
	} )
	if ( traceRes.Hit and IsValid( traceRes.Entity ) ) then
		if ( !self.isGhosting ) then
			self:SetCollisionBounds( Vector( 0, 0, 0 ), Vector( 0, 0, 0 ) )
			self.isGhosting = true
			timer.Simple( 1, function( ) 
			if not ( IsValid( self ) ) then return end
				self:SetCollisionBounds( self.DefaultBounds[1], self.DefaultBounds[2] )
				self.isGhosting = false
			end )
		end
	end
	timer.Simple( 5, function( )
		if not ( IsValid( self ) ) then return end
		self:CheckIfStuck( )
	end )
end

function ENT:CheckForObstacles( )
	local traceRes = util.TraceLine( {
		start = self:GetPos( ),
		endpos = self:GetPos( ) + self:GetAngles( ):Forward( ) * 250,
		filter = function( ent ) 
			if ( ent:GetClass( ) == "prop_physics" ) then
				return true
			end
		end
	} )
	if ( IsValid( traceRes.Entity ) and !traceRes.Entity.godded ) then
		traceRes.Entity:Destroy( )
	elseif ( IsValid( traceRes.Entity ) and !traceRes.Entity.godded ) then
		self.EscapeMove = true
	elseif ( !IsValid( traceRes.Entity ) ) then
		local traceRes = util.TraceLine( {
		start = ( self:GetPos( ) + Vector( 0, 0, 25 ) ) + self:GetAngles( ):Forward( ) * 25,
		endpos = ( self:GetPos( ) + Vector( 0, 0, 25 ) ) + self:GetAngles( ):Forward( ) * 275,
		filter = function( ent ) 
			if ( ent:GetClass( ) == "prop_vehicle_jeep" ) then
					return true
				end
			end
		} )
		if ( IsValid( traceRes.Entity ) ) then
			self.BashingVehicle = traceRes.Entity
			self.EscapeMove = true
			self.BreakWait = true
		end
	end
	timer.Simple( 3, function( ) 
		if not ( IsValid( self ) ) then return end
		self:CheckForObstacles( ) 
	end )
end

function ENT:TeleportToBetterSpot( )
	local foundPos = false
	for index, pos in ipairs ( self.LairTeleportPoses ) do
		if not ( util.PointContents( pos ) == CONTENTS_MONSTER ) then
			self:SetPos( pos )
			player.SendColoredMessage( { COLOR_RED, "THE BEAST ", COLOR_ORANGE, "JUMPS THROUGH A WORMHOLE TO ANOTHER LOCATION IN THE LAIR." }, player.GetAll( ) )
			foundPos = true
			break
		end
	end
	if not ( foundPos ) then
		timer.Simple( 20, function( )
			if not ( IsValid( self ) ) then return end
			self:TeleportToBetterSpot( )
		end )
	end
end

function ENT:OnLandOnGround( )
	if ( game.GetMap( ) == "lair_of_the_Beast8" and self:GetPos( ).z < -1000 ) then
		self:TeleportToBetterSpot( )
	end
end

function ENT:OnKilled( dmgInfo )
	self:OnBeastKilled( )
	self:BecomeRagdoll( dmgInfo )
end

function ENT:DoCycles( )
	if ( self:GetCycle( ) == 1 ) then
		self:SetCycle( 0 )
	end
end

function ENT:SearchForEnemy( )
	local plyTable = player.GetAll( )
	local distanceTable = { }
	local returnPly = nil
	for index, ply in ipairs ( plyTable ) do
		if ( ply:GetPos( ):Distance( self:GetPos( ) ) < self.PlayerChaseDistance and ( !ply:IsGhost( ) and ply:Alive( ) ) ) then
			table.insert( distanceTable, { ply = ply, dist = self:GetPos( ):Distance( ply:GetPos( ) ) } )
		end
	end
	if ( istable( distanceTable ) and #distanceTable > 0 ) then
		table.SortByMember( distanceTable, "dist" )
		returnPly = distanceTable[1].ply
	end
	return ( returnPly )
end

function ENT:IsInMeleeDistance( enemy )
	if not ( IsValid( enemy ) ) then return false end
	if ( enemy:GetPos( ):Distance( self:GetPos( ) ) < self.MeleeAttackDistance ) then
		return true
	else
		return false
	end
end

function ENT:IsInRangedDistance( enemy )
	if not ( IsValid( enemy ) ) then return false end
	if ( enemy:GetPos( ):Distance( self:GetPos( ) ) < self.RangedAttackDistance ) then
		return true
	else
		return false
	end
end

function ENT:OnInjured( dmgInfo )
	if ( self.justSpawned or self.IsInAgony ) then
		dmgInfo:ScaleDamage( 0 )
	end
	if ( self:Health( ) < ( self.MaxHealth * self.EnragePercent ) and !self.IsEnraged ) then
		self.IsEnraged = true
		self.CurrentSpeed = self.CurrentSpeed * 1.5
		player.SendColoredMessage( { COLOR_RED, "THE BEAST", COLOR_WHITE, " BECOMES VERY ANGRY! HE ATTEMPTS TO TEAR APART REALITY ITSELF!" }, player.GetAll( ) )
		util.ScreenShake( Vector(0,0,0), 1000, math.random( 25, 50 ), 10, 9999999999 )
		local physEnts = ents.FindByClass("prop_physics")
		for index, ent in ipairs ( physEnts ) do
			if ( ent.ignoreEarthquakes ) then continue end
			local physObject = ent:GetPhysicsObject( )
			if ( physObject:IsValid( ) ) then
				physObject:EnableMotion( true )
			end
		end
	end
	if ( IsValid( dmgInfo:GetAttacker( ) ) and dmgInfo:GetAttacker( ):IsPlayer( ) ) then
		NOOBRP = NOOBRP or { }
		NOOBRP.BeastFightStarted = true
		local inflictedDmg = dmgInfo:GetDamage( )
		local ply = dmgInfo:GetAttacker( )
		if ( ply:GetPos().x > 450 ) then -- if they're hitting beast from cave entrance
			ply:SetPos( Vector( -631, -354, -777 ) ) -- teleport them onto beast's island. kinda hacky but works
		end
		if ( istable( self.CurrentAggroTarget ) and self.CurrentAggroTarget.ply ~= ply ) then
			if ( !IsValid( self.CurrentAggroTarget.ply ) or self.CurrentAggroTarget.expireTime < CurTime( ) ) then
				self.CurrentAggroTarget = { ply = ply, expireTime = CurTime( ) + 5 }
			elseif ( IsValid( self.CurrentAggroTarget.ply ) and self.CurrentAggroTarget.expireTime > CurTime( ) ) then
				local changeTarget = math.random( 1, 15 )
				if ( changeTarget > 10 ) then
					self.currentTarget = ply
					self.CurrentAggroTarget = { ply = ply, expireTime = CurTime( ) + 5 }
				end
			end
		elseif ( istable( self.CurrentAggroTarget) and self.CurrentAggroTarget.ply == ply ) then
			self.CurrentAggroTarget.expireTime = CurTime( ) + 5
		elseif ( !istable( self.CurrentAggroTarget ) ) then
			self.CurrentAggroTarget = { ply = ply, expireTime = CurTime( ) + 5 }
		end
		self.plyDamage = self.plyDamage or { }
		self.plyDamage[ply:SteamID( )] = self.plyDamage[ply:SteamID( )] or 0
		self.plyDamage[ply:SteamID( )] = self.plyDamage[ply:SteamID( )] + inflictedDmg
	end
	self.EscapeMove = true
	self.BreakWait = true
	if ( self.NextAgony < CurTime( ) ) then
		local randChance = math.random( 1, 3 )
		if ( randChance > 2 ) then
			player.SendColoredMessage( { COLOR_RED, "THE BEAST ", COLOR_WHITE, "YELLS OUT IN ", COLOR_ORANGE, " AGONY", COLOR_WHITE, "!" }, player.GetAll( ) )
		end
		local roarSoundPatch = CreateSound( self, "npc/antlion_guard/growl_high.wav" )
		roarSoundPatch:Play( )
		timer.Simple( 1, function( )
			roarSoundPatch:Stop( )
			roarSoundPatch = nil
		end )
		self.NextAgony = CurTime( ) + 15
		self.IsInAgony = true
	end
end

function ENT:ShoveEnemy( enemy )
	if ( ( !enemy:IsGhost( ) and enemy:Alive( ) ) ) then
		local vel = ( ( enemy:GetPos( ) - self:GetPos( ) ):GetNormalized( ) ) * 2500
		vel.z = 0
		enemy:SetVelocity( vel )
		enemy:TakeDamage( math.random( 10, 35 ), self, nil )
		self:EmitSound( "npc/antlion_guard/shove1.wav" )
	end
end

function ENT:PerformSpecialAttack( attackRange, attackFunc )
	self.NextSpecialAttack = CurTime( ) + math.random( self.SpecialAttackCD, self.SpecialAttackCD * 2 )
	local nearbyEnts = ents.FindInBox( self:GetPos( ) - Vector( attackRange, attackRange, attackRange * 0.5 ), self:GetPos( ) + Vector( attackRange, attackRange, attackRange * 0.5 ) )
	for index, ent in ipairs ( nearbyEnts ) do
		if ( ent:IsPlayer( ) and !ent:IsGhost( ) and ent:Alive( ) ) then
			attackFunc( ent )
		end
	end
end

function ENT:RunBehaviour( )
	while ( true ) do
		if ( self.justSpawned ) then
			timer.Simple( 0.5, function( )
				if not ( IsValid( self ) ) then return end
				util.CreateParticleEffect( self:GetPos( ) + Vector( 0, 0, 15 ), 50, "sprites/jeezy/flames_02", { color = Color( 0, 0, 0, 255 ), dieTime = 2, randomStartSize = { 25, 50 }, randomEndSize = { 5, 15 }, randomVelocity = { Vector( -200, -200, 0 ), Vector( 200, 200, 0 ), angle = Angle( 90, 90, 90 ) }, randomColor = { Color( 10, 10, 10, 0 ), Color( 45, 45, 45, 0 ) }, rollDelta = 120, shouldCollide = true } )
			end )
			self:PlaySequenceAndWait( "floor_break", 1 )
			self.justSpawned = false
		end
		if ( self.BashingVehicle ) then
			timer.Simple( 0.5, function( )
				if ( IsValid( self ) and IsValid( self.BashingVehicle ) ) then
					local physObj = self.BashingVehicle:GetPhysicsObject( )
					if ( IsValid( physObj ) ) then
						physObj:SetVelocity( ( self.BashingVehicle:GetPos( ) - self:GetPos( ) ):GetNormalized( ) * 10000 )
					end
				end
				self.BashingVehicle = false
			end )
			self:PlaySequenceAndWait( "shove", 1.5 )
		end
		if ( self.IsInAgony ) then
			self:PlaySequenceAndWait( "roar", 1.5 )
			self.IsInAgony = false
		end
		local randChance = math.random( 1, 100 )
		if ( randChance < 3 and self.NextSpecialAttack < CurTime( ) ) then
			player.SendColoredMessage( { COLOR_RED, "THE BEAST ", COLOR_WHITE, "DISCHARGES A SHOCKWAVE AND ", COLOR_BLUE, "STUNS ", COLOR_WHITE, " EVERYONE AROUND HIM!" }, player.GetAll( ) )
			util.CreateParticleEffect( self:GetPos( ) + Vector( 0, 0, 15 ), 50, "sprites/jeezy/arcanecircle_01", { color = Color( 50, 50, 50, 255 ), dieTime = 2, randomStartSize = { 25, 50 }, randomEndSize = { 5, 15 }, randomVelocity = { Vector( -500, -500, 0 ), Vector( 500, 500, 0 ), angle = Angle( 90, 90, 90 ) }, randomColor = { Color( 35, 35, 35, 0 ), Color( 65, 65, 150, 0 ) }, rollDelta = 120, shouldCollide = true } )
			self:PerformSpecialAttack( self.StunRange, function( ent )
				ent:Freeze( true )
				ent:GodDisable( )
				ent:SetColor( Color( 0, 0, 255, 255 ) )
				timer.Simple( 5, function( )
					if ( IsValid( ent ) ) then
						ent:Freeze( false )
						ent:SetColor( Color( 255, 255, 255, 255 ) )
					end
				end )
			end )
			local confusedSoundPatch = CreateSound( self, "npc/antlion_guard/confused1.wav" )
			confusedSoundPatch:Play( )
			self:PlaySequenceAndWait( "bark", 1 )
			confusedSoundPatch:Stop( )
			confusedSoundPatch = nil
		elseif ( randChance > 3 and randChance < 9 and self.NextSpecialAttack < CurTime( ) ) then
			self:PlaySequenceAndWait( "peek_enter", 1.5 )
			timer.Simple( 0.5, function( )
				if not ( IsValid( self ) ) then return end
				player.SendColoredMessage( { COLOR_RED, "THE BEAST ", COLOR_WHITE, "SHOOTS OUT ", COLOR_GREEN, "POISON ", COLOR_WHITE, " AT EVERYONE AROUND HIM." }, player.GetAll( ) )
				self:PerformSpecialAttack( self.PoisonRange, function( ent )
					util.CreateParticleEffect( self:GetPos( ) + Vector( 0, 0, 30 ), 7, "sprites/jeezy/lightning_01", { velocity = ( ent:GetPos( ) - self:GetPos( ) ) * 3, shouldCollide = true, dieTime = 1, randomStartSize = { 5, 15 }, randomEndSize = { 0, 2 }, randomVelocity = { Vector( -5, -5, -2 ), Vector( 5, 5, 5 ) }, rollDelta = 15, particleDelay = 0.015 } )
					ent:Poison( )
				end )
			end )
			self:PlaySequenceAndWait( "peek_flinch", 1.5 )
			self:PlaySequenceAndWait( "peek_exit", 1.5 )
		elseif ( randChance > 9 and randChance < 16 and !self.IsCharging ) then
			self.IsCharging = true
		elseif ( randChance > 16 and randChance < 22 and self.NextSpecialAttack < CurTime( ) ) then
			self:PlaySequenceAndWait( "roar", 1.5 )
			player.SendColoredMessage( { COLOR_RED, "THE BEAST ", COLOR_WHITE, "RELEASES A MASSIVE ", COLOR_PURPLE, "BURST OF ENERGY ", COLOR_WHITE, ", KNOCKING BACK THOSE AROUND HIM!" }, player.GetAll( ) )
			self:PerformSpecialAttack( self.EnergyBurstRange, function( ent )
				util.CreateParticleEffect( self:GetPos( ) + Vector( 0, 0, 30 ), 20, "sprites/jeezy/lightning_01", { color = Color( 45, 45, 175 ), velocity = ( ent:GetPos( ) - self:GetPos( ) ) * 10, shouldCollide = true, dieTime = 2, randomStartSize = { 5, 30 }, randomEndSize = { 0, 5 }, randomVelocity = { Vector( -5, -5, -2 ), Vector( 5, 5, 5 ) }, rollDelta = 35, particleDelay = 0.015 } )
				ent:SetVelocity( ( ent:GetPos( ) - self:GetPos( ) ):GetNormalized( ) * self.EnergyBurstStrength )
			end )
		elseif ( randChance > 22 and randChance < 30 and self.NextSpecialAttack < CurTime( ) ) then
			player.SendColoredMessage( { COLOR_RED, "THE BEAST ", COLOR_WHITE, "LETS OUT AN ", COLOR_YELLOW, "AGONIZING ROAR ", COLOR_WHITE, ", SLOWING THOSE AROUND HIM!" }, player.GetAll( ) )
			self:PerformSpecialAttack( self.SlowingRange, function( ent )
				util.CreateParticleEffect( ent:GetPos( ) + Vector( 0, 0, 35 ), 7, "sprites/jeezy/arcanecircle_01", { color = Color( 175, 45, 45 ), shouldCollide = false, dieTime = self.SlowingLength, randomStartSize = { 10, 15 }, randomEndSize = { 2, 7 }, randomVelocity = { Vector( -15, -15, -15 ), Vector( 15, 15, 15 ) }, rollDelta = 45, followEntity = ent, followEntitySpeed = 5, followEntityOffset = Vector( 0, 0, 25 ) } )
				ent:MultiplyMovementSpeed( self.SlowingStrength )
				timer.Simple( self.SlowingLength, function( )
					if ( IsValid( ent ) ) then
						ent:ApplyMovementSpeed( )
					end
				end )
			end )
		else
			if not ( self.IsCharging ) then
				if not ( IsValid( self.currentTarget ) ) then
					local enemy = self:SearchForEnemy( )
					if ( IsValid( enemy ) or ( istable( self.CurrentAggroTarget ) and IsValid( self.CurrentAggroTarget.ply ) and self.CurrentAggroTarget.expireTime > CurTime( ) ) ) then
						if not ( IsValid( enemy ) ) then
							enemy = self.CurrentAggroTarget.ply
						end
						self:ResetSequence( self.RunningSequences[math.random(#self.RunningSequences)])
						self.loco:SetDesiredSpeed( self.CurrentSpeed )
						local zDifference = math.abs( self:GetPos( ).z - enemy:GetPos( ).z )
						if ( zDifference > 60 and math.random( 1, 5 ) < 2 ) then
							enemy:SetVelocity( ( self:GetPos( ) - enemy:GetPos( ) ):GetNormalized( ) * 1000 )
							player.SendColoredMessage( { COLOR_RED, "THE BEAST ", COLOR_ORANGE, " MANIPULATES THE WIND TO BRING YOU TOWARDS HIM!" }, enemy )
						end
						self:EscapableMoveToPos( enemy:GetPos( ), { tolerance = self.PathTolerance, maxage = self.PathMaxAge }, enemy )
						self:EmitSound( self.AngrySounds[math.random(#self.AngrySounds)] )
						if ( self:IsInMeleeDistance( enemy ) ) then
							self.loco:FaceTowards( enemy:GetPos( ) )
							timer.Simple( 0.5, function( )
								if ( !IsValid( self ) or !IsValid( enemy ) ) then return end
								self.loco:FaceTowards( enemy:GetPos( ) )
								self:ShoveEnemy( enemy )
							end )
							self:PlaySequenceAndWait( "shove", 1.5 )
							self:BreakableWait( 0.5 )
						elseif ( self:IsInRangedDistance( enemy ) ) then
							self.loco:FaceTowards( enemy:GetPos( ) )
							timer.Simple( 0.4, function( )
								if ( IsValid( self ) and IsValid( enemy ) and !enemy:IsGhost( ) and enemy:Alive( ) ) then
									self.loco:FaceTowards( enemy:GetPos( ) )
								end
							end )
							timer.Simple( 0.5, function( )
								if ( !IsValid( enemy ) or !IsValid( self ) ) then return end
								if ( !enemy:IsGhost( ) and enemy:Alive( ) ) then
									//self.loco:FaceTowards( enemy:GetPos( ) )
									local traceRes = util.TraceLine( { start = self:GetPos( ) + Vector( 0, 0, 50 ), endpos = self:GetPos( ) + self:GetAngles( ):Forward( ) * 10000, filter = self } )
									if ( IsValid( traceRes.Entity ) and traceRes.Entity:IsPlayer( ) ) then
										util.CreateParticleEffect( self:GetPos( ) + Vector( 0, 0, 30 ), 30, "sprites/jeezy/flames_02", { startSize = 20, endSize = 5, shouldCollide = true, dieTime = 1, randomStartSize = { 10, 30 }, randomEndSize = { 1, 5 }, randomVelocity = { Vector( -100, -100, -2 ), Vector( 100, 100, 30 ) }, randomAngle = { Angle( -25, -25, -25 ), Angle( 25, 25, 25 ) }, followEntity = enemy, followEntitySpeed = 10, followEntityOffset = Vector( 0, 0, 50 ) } )
										local hitEnt = traceRes.Entity
										local entsTable = { }
										table.insert( entsTable, hitEnt )
										hitEnt:Ignite( 10 )
										local nearbyEnts = ents.FindInBox( hitEnt:GetPos( ) - Vector( 256, 256, 256 ), hitEnt:GetPos( ) + Vector( 256, 256, 256 ) )
										util.CreateParticleEffect( hitEnt:GetPos( ) + Vector( 0, 0, 30 ), 30, "sprites/jeezy/flames_02", { color = Color( 175, 45, 45 ), startSize = 10, endSize = 0, dieTime = 0.5, randomStartSize = { 10, 5 }, randomEndSize = { 0, 3 }, randomVelocity = { Vector( -100, -100, -100 ), Vector( 100, 100, 100 ) }, randomAngle = { Angle( -45, -45, -45 ), Angle( 45, 45, 45 ) } } )
										hitEnt:EmitSound( "ambient/fire/mtov_flame2.wav" )
										hitEnt:TakeDamage( math.random( 10, 35 ), self, nil )
										for index, ent in ipairs ( nearbyEnts ) do
											if ( ent == hitEnt ) then continue end
											if ( ent:IsPlayer( ) ) then
												ent:Ignite( 10 )
												table.insert( entsTable, ent )
											end
										end
										timer.Simple( 10, function( ) 
											for index, ent in ipairs ( entsTable ) do
												if ( IsValid( ent ) ) then
													ent:Extinguish( )
												end
											end 
										end )
									else
										util.CreateParticleEffect( self:GetPos( ) + Vector( 0, 0, 30 ), 30, "sprites/jeezy/flames_02", { velocity = ( self:GetAngles( ):Forward( ) * 1000 ), startSize = 20, endSize = 5, shouldCollide = true, dieTime = 1, randomStartSize = { 10, 30 }, randomEndSize = { 1, 5 }, randomVelocity = { Vector( -100, -100, -2 ), Vector( 100, 100, 30 ) }, randomAngle = { Angle( -25, -25, -25 ), Angle( 25, 25, 25 ) } } )
									end
								end
							end )
							self:PlaySequenceAndWait( "fireattack", 1.5 )
							self:BreakableWait( 0.5 )
						else
							local switchEnemy = math.random( 1, 5 )
							if ( switchEnemy > 3 ) then
								local enemy = self:SearchForEnemy( )
								if ( IsValid( enemy ) ) then
									self.currentTarget = enemy
									self:BreakableWait( 0.5 )
								end
							end
						end
					else
						self:NavigateToRandomPos( tobool( math.random( 0, 1 ) ), math.random( 100, 300 ), math.random( 100, 500 ) )
						self:ResetSequence( "idle" )
						self:BreakableWait( math.random( 3, 5 ) )
					end
				end
			else
				if ( IsValid( enemy ) or ( istable( self.CurrentAggroTarget ) and IsValid( self.CurrentAggroTarget.ply ) and self.CurrentAggroTarget.expireTime > CurTime( ) ) ) then
					if not ( IsValid( enemy ) ) then
						enemy = self.CurrentAggroTarget.ply
					end
					self:PlaySequenceAndWait( "charge_startfast" )
					self:ResetSequence( "charge_loop" )
					self.loco:SetDesiredSpeed( self.CurrentSpeed )
					self:EscapableMoveToPos( enemy:GetPos( ), { tolerance = self.PathTolerance, maxage = self.PathMaxAge }, enemy )
					if ( self:IsInMeleeDistance( enemy ) ) then
						self.loco:FaceTowards( enemy:GetPos( ) )
						timer.Simple( 0.5, function( )
							if ( !IsValid( self ) or !IsValid( enemy ) ) then return end
							self:ShoveEnemy( enemy )
						end )
					end
					self:PlaySequenceAndWait( "charge_crash" )
				end
				self:ResetSequence( "idle" )
				self.IsCharging = false
				self:BreakableWait( math.random( 1, 2 ) )
			end	
		end	
		local pos = self:GetPos() -- checks to keep beast out of lava
		if pos.x > -130 then
			pos.x = -130
			self:SetPos(pos)
		end
		if pos.x < -1067 then
			pos.x = -1067
			self:SetPos(pos)
		end
		if pos.y < -1282 then
			pos.y = -1282
			self:SetPos(pos)
		end
		if pos.y > 97 then
			pos.y = 97
			self:SetPos(pos)
		end
	end
end

function ENT:NavigateToRandomPos( isWalking, desiredSpeed, maxDistance )
	if ( isWalking ) then
		self:ResetSequence( "walk1" )
	else
		self:ResetSequence( "run1" )
	end
	self.loco:SetDesiredSpeed( self.CurrentSpeed * 0.5 )
	local destinationPos = self:GetPos( ) + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * maxDistance
	self:EscapableMoveToPos( destinationPos, { maxage = self.PathMaxAge, tolerance = self.PathTolerance } )
end

function ENT:BreakableWait( time ) -- Credit To CrashLemon
	self.BreakWait = false
	self.waitTime = CurTime( ) + time
	while ( ( self.waitTime + FrameTime( ) ) > CurTime( ) ) do
		if ( self.BreakWait ) then
			self.BreakWait = false
			break
		end
		coroutine.wait( FrameTime( ) )
	end

end

function ENT:EscapableMoveToPos( pos, options, enemy )
	self.EscapeMove = false
	local options = options or {}
	local path = Path( "Follow" )
	local pos = pos
	pos = path:GetClosestPosition( pos )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, pos )

	if ( !path:IsValid() ) then return "failed" end

	while ( path:IsValid() ) do
		if ( self.EscapeMove and !self.IsFleeing ) then
			path:Invalidate( )
			self.EscapeMove = false
			continue
		end
		local rndChance = math.random( 1, 20 )
		if ( rndChance > 15 ) then
			self:EmitSound( self.FootstepSounds[math.random(#self.FootstepSounds)])
		end
		self:DoCycles( )
		path:Update( self )

		if ( options.draw ) then
			path:Draw()
		end

		if ( self.loco:IsStuck( ) ) then
			self:HandleStuck( )
			return "stuck"
		end

		if ( options.maxage ) then
			if ( path:GetAge() > options.maxage ) then return "timeout" end
		end

		if ( options.repath ) then
			if ( path:GetAge() > options.repath ) then 
				path:Compute( self, pos ) 
			end
		end

		coroutine.yield()

	end

	return "ok"
end

function ENT:OnBeastKilled( )
	local sortedDamage = { }
	for index, dmg in pairs ( self.plyDamage ) do
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
	if ( game.GetMap( ) ~= "lair_of_the_Beast8" ) then
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
	else
		player.SendColoredMessage( { COLOR_GREEN, "Congratulations, you have taken down ", COLOR_RED, "The Beast ", COLOR_GREEN, ", you may now return to evocity." }, player.GetAll( ) )
		player.SendColoredMessage({COLOR_GREEN, "A ", COLOR_RED, "MINING EVENT ", COLOR_GREEN, "is now active for the duration of the Lair."}, player.GetAll())
		SVNOOB_VARS:Set( "MiningForemanLimit", 5 )
		SVNOOB_VARS:Set( "MiningBoostActive", true )
		for index, ply in ipairs ( player.GetAll( ) ) do
			ply:GiveBeastLairReward( )
			/*if not ( ply:HasWeaponStored( "golden_beast_hat" ) ) then -- Just a fun gift, not meant to be the real one.
				player.SendColoredMessage( { COLOR_BLUE, "You've been rewarded a ", COLOR_YELLOW, "Golden Beast Hat", COLOR_BLUE, "!" }, ply )
				ply:GivePermWeapon( "golden_beast_hat" )
			end*/
		end
		timer.Destroy( "N00BRP_BeastLair_AntlionSpawner" )
		hook.Call( "OnBeastLairWon", { }, player.GetAll( ) )
	end
	self.plyDamage = { }
end
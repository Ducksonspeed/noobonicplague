AddCSLuaFile( )

ENT.Base = "base_nextbot"
ENT.Spawnable = false
ENT.AdminSpawnable = true
ENT.EscapeMove = false
ENT.BreakWait = false
ENT.IsCharging = false
ENT.IsBurrowed = false
ENT.IsBurrowing = false
ENT.BurrowLength = 5
ENT.JustSpawned = true
ENT.RangedAttackDistance = 1250
ENT.MeleeAttackDistance = 220
ENT.PlayerChaseDistance = 1000
ENT.MaxHealth = 1500
ENT.RunSpeed = 300
ENT.WalkSpeed = 200
ENT.PathTolerance = 96
ENT.PathMaxAge = 5
ENT.AttackSequences = { "attack1", "attack2", "attack3", "attack4", "attack5", "attack6", "pounce", "pounce2" }
ENT.RangedAttackSequences = { "distract", "distract_arrived" }
ENT.RunningSequences = { "run_all", "runagitated" }
ENT.AntlionMaterials = { "models/antlion/antlionhigh_sheet02", "models/antlion/antlionhigh_sheet03", "models/antlion/antlionhigh_sheet04" }
ENT.AttackSounds = { "npc/antlion/attack_single1.wav", "npc/antlion/attack_single2.wav", "npc/antlion/attack_single3.wav" }
ENT.FootstepSounds = { "npc/antlion/foot1.wav", "npc/antlion/foot2.wav", "npc/antlion/foot3.wav", "npc/antlion/foot4.wav" }
ENT.IdleSounds = { "npc/antlion/idle1.wav", "npc/antlion/idle2.wav", "npc/antlion/idle3.wav", "npc/antlion/idle4.wav", "npc/antlion/idle5.wav" }
ENT.PainSounds = { "npc/antlion/pain1.wav", "npc/antlion/pain2.wav" }
ENT.CurrentAggroTarget = nil
ENT.SoundPatches = { }
ENT.LastTargetFound = CurTime( )
//ENT.DefaultBounds = { Vector( -4, -4, 0 ), Vector( 4, 4, 32 ) }

function ENT:Initialize( )
	self:SetNoDraw( true )
	self:SetSequence( "digidle" )
	self.IsBurrowed = true
	self:SetModel( "models/antlion.mdl" )
	self:SetMaterial( self.AntlionMaterials[ math.random( #self.AntlionMaterials ) ] )
	self:SetHealth( self.MaxHealth / 3 )
	self.DefaultBoundsMin, self.DefaultBoundsMax = self:GetCollisionBounds( )
	self.DefaultBoundsMin = Vector( self.DefaultBoundsMin.x * 0.4, self.DefaultBoundsMin.y * 0.4, self.DefaultBoundsMin.z * 0.7 )
	self.DefaultBoundsMax = Vector( self.DefaultBoundsMax.x * 0.4, self.DefaultBoundsMax.y * 0.4, self.DefaultBoundsMax.z * 0.7 )
	self:SetCollisionBounds( self.DefaultBoundsMin, self.DefaultBoundsMax )
	--self:SetCollisionBounds( self.DefaultBounds[1], self.DefaultBounds[2] )
	self.loco:SetDeathDropHeight( self.DeathDropHeight or 200 )
	self.loco:SetAcceleration( self.BotAcceleration or 400 )
	self.loco:SetDeceleration( self.BotDeceleration or 400 )
	self.loco:SetStepHeight( self.BotStepHeight or 18 )
	self.loco:SetJumpHeight( self.BotJumpHeight or 120 )
	self.timeUntilUnburrow = 0
	self.IsJumping = false
	timer.Simple( 3, function( ) 
		if not ( IsValid( self ) ) then return end
		self:CheckForObstacles( ) 
	end )
	if ( game.GetMap( ) == "lair_of_the_Beast8" ) then
		timer.Simple( 60, function( )
			if not ( IsValid( self ) ) then return end
			self:CheckDistanceToPlayers( )
		end )
		timer.Simple( 30, function( ) 
			if not ( IsValid( self ) ) then return end
			self:CheckLastEnemyFound( )
		end )
	end
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
		mins = self.DefaultBoundsMin,
		maxs = self.DefaultBoundsMax,
		mask = MASK_SHOT_HULL
	} )
	if ( traceRes.Hit and IsValid( traceRes.Entity ) ) then
		if ( !self.isGhosting ) then
			self:SetCollisionBounds( Vector( 0, 0, 0 ), Vector( 0, 0, 0 ) )
			self.isGhosting = true
			timer.Simple( 1, function( ) 
			if not ( IsValid( self ) ) then return end
				self:SetCollisionBounds( self.DefaultBoundsMin, self.DefaultBoundsMax )
				self.isGhosting = false
			end )
		end
	end
	timer.Simple( 5, function( )
		if not ( IsValid( self ) ) then return end
		self:CheckIfStuck( )
	end )
end

function ENT:CheckLastEnemyFound( )
	if ( self.LastTargetFound < CurTime( ) - 30 ) then
		SafeRemoveEntity( self )
	else
		timer.Simple( 30, function( )
			if not ( IsValid( self ) ) then return end
			self:CheckLastEnemyFound( )
		end )
	end
end

function ENT:CheckDistanceToPlayers( )
	local plyCount = 0
	local plyTable = player.GetAll( )
	for index, ply in ipairs ( plyTable ) do
		if ( ply:GetPos( ):Distance( self:GetPos( ) ) < 2000 ) then
			plyCount = plyCount + 1
		end
	end
	if ( plyCount == 0 ) then
		SafeRemoveEntity( self )
	else
		timer.Simple( 60, function( )
			if not ( IsValid( self ) ) then return end
			self:CheckDistanceToPlayers( )
		end )
	end
end

function ENT:CheckForObstacles( )
	local traceRes = util.TraceLine( {
		start = self:GetPos( ),
		endpos = self:GetPos( ) + self:GetAngles( ):Forward( ) * 150,
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
	end
	timer.Simple( 3, function( ) 
		if not ( IsValid( self ) ) then return end
		self:CheckForObstacles( ) 
	end )
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

function ENT:Think( )
	if ( self.loco:IsClimbingOrJumping( ) and self:GetSequenceName( self:GetSequence( ) ) ~= "jump_start" ) then
		self:SetSequence( "jump_glide" )
	end
end

function ENT:OnLeaveGround( )
	self:ResetSequence( "jump_start" )
	timer.Simple( self:SequenceDuration( ), function( )
		if ( !IsValid( self ) or !self.loco:IsClimbingOrJumping( ) ) then return end
		self:SetSequence( "jump_glide" ) 
	end )
end

function ENT:OnLandOnGround( )
	self.IsJumping = false
	self:EmitSound( "npc/antlion/land1.wav" )
	self:ResetSequence( "jump_stop" )
	if ( self.flySoundPatch ) then
		self.flySoundPatch:Stop( )
		self.flySoundPatch = nil
	end
	if ( game.GetMap( ) == "lair_of_the_Beast8" and self:GetPos( ).z < -1200 ) then
		SafeRemoveEntity( self )
	end
end

function ENT:OnRemove( )
	for index, soundPatch in ipairs ( self.SoundPatches ) do
		if ( soundPatch ) then
			soundPatch:Stop( )
			soundPatch = nil
		end
	end
end

function ENT:OnKilled( dmgInfo )
	local ply = dmgInfo:GetAttacker( )
	if ( IsValid( ply ) and ply:IsPlayer( ) ) then
		ply:DisplayNotify("You receive a bounty of $50 for killing an antlion.", 6, "icon16/heart.png", COLOR_WHITE, nil, true, "N00BRP_2DIndicator_LobsterMiniText")
		ply:addMoney(50)
	end
	self:BecomeRagdoll( dmgInfo )

end

function ENT:OnInjured( dmgInfo )
	if ( self.IsBurrowed or self.IsBurrowing ) then
		dmgInfo:ScaleDamage( 0 )
		return
	end
	if ( IsValid( dmgInfo:GetAttacker( ) ) and dmgInfo:GetAttacker( ):IsPlayer( ) ) then
		local ply = dmgInfo:GetAttacker( )
		if ( istable( self.CurrentAggroTarget ) and self.CurrentAggroTarget.ply ~= ply ) then
			if ( !IsValid( self.CurrentAggroTarget.ply ) or self.CurrentAggroTarget.expireTime < CurTime( ) ) then
				self.CurrentAggroTarget = { ply = ply, expireTime = CurTime( ) + 5 }
			end
		elseif ( istable( self.CurrentAggroTarget) and self.CurrentAggroTarget.ply == ply ) then
			self.CurrentAggroTarget.expireTime = CurTime( ) + 5
		elseif ( !istable( self.CurrentAggroTarget ) ) then
			self.CurrentAggroTarget = { ply = ply, expireTime = CurTime( ) + 5 }
		end
	end
	self.EscapeMove = true
	self.BreakWait = true
	local painSoundChance = math.random( 1, 5 )
	if ( painSoundChance < 2 ) then
		self:EmitSound( self.PainSounds[ math.random( #self.PainSounds) ] )
	end
	local burrowChance = math.random( 1, 15 )
	if ( burrowChance < 5 ) then
		self.IsBurrowing = true
		self.timeUntilUnburrow = CurTime( ) + self.BurrowLength
	end
end

function ENT:NudgeEnemy( enemy )
	if ( ( !enemy:IsGhost( ) and enemy:Alive( ) ) ) then
		local vel = ( ( enemy:GetPos( ) - self:GetPos( ) ):GetNormalized( ) ) * 1000
		vel.z = 0
		enemy:SetVelocity( vel )
		enemy:TakeDamage( math.random( 5, 15 ), self, nil )
		//self:EmitSound( "npc/antlion_guard/shove1.wav" )
	end
end

function ENT:RunBehaviour( )
	while ( true ) do
		if ( self.IsBurrowed and self.timeUntilUnburrow < CurTime( ) ) then
			self:SetNoDraw( false )
			self:SetCollisionBounds( self.DefaultBoundsMin, self.DefaultBoundsMax )
			timer.Simple( 0.5, function( )
				if not ( IsValid( self ) ) then return end
				util.CreateParticleEffect( self:GetPos( ) + Vector( 0, 0, 15 ), 50, "sprites/jeezy/flames_02", { color = Color( 0, 0, 0, 255 ), dieTime = 1, randomStartSize = { 15, 30 }, randomEndSize = { 1, 5 }, randomVelocity = { Vector( -100, -100, 0 ), Vector( 100, 100, 0 ), angle = Angle( 90, 90, 90 ) }, randomColor = { Color( 10, 10, 10, 0 ), Color( 45, 45, 45, 0 ) }, rollDelta = 120, shouldCollide = true } )
			end )
			self:EmitSound( "npc/antlion/digup1.wav" )
			self:PlaySequenceAndWait( "digout" )
			self:EmitSound( self.IdleSounds[ math.random( #self.IdleSounds) ] )
			self:ResetSequence( "idle" )
			self.IsBurrowed = false
		end
		if ( self.IsBurrowing ) then
			self:EmitSound( "npc/antlion/digdown1.wav" )
			self:PlaySequenceAndWait( "digin" )
			self:SetSequence( "digidle" )
			self.IsBurrowed = true
			self.IsBurrowing = false
			self:SetCollisionBounds( Vector( 0, 0, 0 ), Vector( 0, 0, 0 ) )
			self:BreakableWait( self.BurrowLength )
		end
		if ( !self.IsBurrowed ) then
			local randChance = math.random( 1, 100 )
			if ( randChance < 10 and !self.IsCharging ) then
				self.IsCharging = true
			end
			/*local randNum = math.random( 1, 3 )
			if ( randNum > 2 ) then
				local destinationPos = self:GetPos( ) + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 512
				self:JumpTowards( destinationPos, { maxage = 2 } )
				self:ResetSequence( "idle" )
				self:BreakableWait( math.random( 1, 3 ) )
			else*/
			if not ( self.IsCharging ) then
				local enemy = self:SearchForEnemy( )
				if ( IsValid( enemy ) or ( ( istable( self.CurrentAggroTarget ) and IsValid( self.CurrentAggroTarget.ply ) and self.CurrentAggroTarget.expireTime > CurTime( ) ) ) ) then
					if not ( IsValid( enemy ) ) then
						enemy = self.CurrentAggroTarget.ply
					end
					self.LastTargetFound = CurTime( )
					if ( enemy:IsGhost( ) or !enemy:Alive( ) ) then enemy = nil end
					local jumpChance = math.random( 1, 5 )
					if ( IsValid( enemy ) ) then
						if ( jumpChance < 2 ) then
							local destinationPos = enemy:GetPos( ) + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 128
							self:JumpTowards( destinationPos, { maxage = self.PathMaxAge } )
							self:ResetSequence( "idle" )
							self:BreakableWait( 0.25 )
						end
						self.loco:SetDesiredSpeed( self.RunSpeed )
						self:ResetSequence( self.RunningSequences[ math.random( #self.RunningSequences ) ] )
						self:EscapableMoveToPos( enemy:GetPos( ), { tolerance = self.PathTolerance, maxage = self.PathMaxAge } )
					else
						self:BreakableWait( 0.5 )
					end
					if ( IsValid( enemy ) and self:IsInMeleeDistance( enemy ) ) then
						self.loco:FaceTowards( enemy:GetPos( ) )
						timer.Simple( 0.5, function( )
							if ( !IsValid( self ) or !IsValid( enemy ) ) then return end
							self:EmitSound( self.AttackSounds[ math.random( #self.AttackSounds ) ] )
							self:NudgeEnemy( enemy )
						end )
						self:PlaySequenceAndWait( self.AttackSequences[ math.random( #self.AttackSequences) ] )
						self:BreakableWait( 0.5 )
					elseif ( IsValid( enemy ) and self:IsInRangedDistance( enemy ) ) then
						self.loco:FaceTowards( enemy:GetPos( ) )
						timer.Simple( 0.4, function( )
							if ( IsValid( self ) and IsValid( enemy ) and !enemy:IsGhost( ) and enemy:Alive( ) ) then
								self.loco:FaceTowards( enemy:GetPos( ) )
							end
						end )
						timer.Simple( 0.5, function( )
							if ( !IsValid( self ) or !IsValid( enemy ) ) then return end
							if ( !enemy:IsGhost( ) and enemy:Alive( ) ) then
								//self.loco:FaceTowards( enemy:GetPos( ) )
								self:EmitSound( "npc/antlion/distract1.wav" )
								local traceRes = util.TraceLine( { start = self:GetPos( ) + Vector( 0, 0, 50 ), endpos = self:GetPos( ) + self:GetAngles( ):Forward( ) * 10000, filter = self } )
								if ( IsValid( traceRes.Entity ) and traceRes.Entity:IsPlayer( ) ) then
									util.CreateParticleEffect( self:GetPos( ) + Vector( 0, 0, 30 ), 15, "sprites/jeezy/lightning_01", { shouldCollide = true, dieTime = 1, randomStartSize = { 5, 15 }, randomEndSize = { 0, 2 }, randomVelocity = { Vector( -5, -5, -2 ), Vector( 5, 5, 5 ) }, rollDelta = 15, particleDelay = 0.02, followEntity = enemy, followEntitySpeed = 10 } )
									local hitEnt = traceRes.Entity
									util.CreateParticleEffect( hitEnt:GetPos( ) + Vector( 0, 0, 30 ), 30, "sprites/jeezy/lightning_01", { color = Color( 255, 255, 255 ), startSize = 10, endSize = 0, dieTime = 0.5, randomStartSize = { 10, 5 }, randomEndSize = { 0, 3 }, randomVelocity = { Vector( -100, -100, -100 ), Vector( 100, 100, 100 ) }, randomAngle = { Angle( -45, -45, -45 ), Angle( 45, 45, 45 ) } } )
									hitEnt:EmitSound( "npc/antlion_grub/squashed.wav" )
									hitEnt:TakeDamage( math.random( 5, 15 ), self, nil )
								else
									util.CreateParticleEffect( self:GetPos( ) + Vector( 0, 0, 30 ), 15, "sprites/jeezy/lightning_01", { velocity = ( self:GetAngles( ):Forward( ) * 1000 ), shouldCollide = true, dieTime = 1, randomStartSize = { 5, 15 }, randomEndSize = { 0, 2 }, randomVelocity = { Vector( -5, -5, -2 ), Vector( 5, 5, 5 ) }, rollDelta = 15, particleDelay = 0.02 } )
								end
							end
						end )
						self:PlaySequenceAndWait( self.RangedAttackSequences[ math.random( #self.RangedAttackSequences ) ] )
						self:BreakableWait( 0.5 )
					end
				else
					self:NavigateToRandomPos( tobool( math.random( 0, 1 ) ), math.random( 100, 300 ), math.random( 100, 500 ) )
					self:EmitSound( self.IdleSounds[ math.random( #self.IdleSounds) ] )
					self:ResetSequence( "idle" )
					//self:StartActivity( ACT_IDLE )
					self:BreakableWait( 1 )
				end
			else
				if ( IsValid( enemy ) or ( istable( self.CurrentAggroTarget ) and IsValid( self.CurrentAggroTarget.ply ) and self.CurrentAggroTarget.expireTime > CurTime( ) ) ) then
					if not ( IsValid( enemy ) ) then
						enemy = self.CurrentAggroTarget.ply
					end
					self.LastTargetFound = CurTime( )
					self:PlaySequenceAndWait( "charge_start" )
					self:ResetSequence( "charge_run" )
					self.loco:SetDesiredSpeed( self.RunSpeed * 1.5 )
					local chargeSoundPatch = CreateSound( self, "npc/antlion/charge_loop1.wav" )
					table.insert( self.SoundPatches, chargeSoundPatch )
					chargeSoundPatch:Play( )
					timer.Simple( 5, function( )
						if ( chargeSoundPatch ) then
							chargeSoundPatch:Stop( )
							chargeSoundPatch = nil
						end
					end )
					self:EscapableMoveToPos( enemy:GetPos( ), { tolerance = self.PathTolerance, maxage = self.PathMaxAge } )
					if ( self:IsInMeleeDistance( enemy ) and IsValid( enemy ) ) then
						self.loco:FaceTowards( enemy:GetPos( ) )
						timer.Simple( 0.5, function( )
							if ( !IsValid( self ) or !IsValid( enemy ) ) then return end
							self:EmitSound( self.AttackSounds[ math.random( #self.AttackSounds ) ] )
							self:NudgeEnemy( enemy )
						end )
					end
					if ( chargeSoundPatch ) then
						chargeSoundPatch:Stop( )
						chargeSoundPatch = nil
					end
					self:PlaySequenceAndWait( "charge_end" )
				end
 				self:EmitSound( self.IdleSounds[ math.random( #self.IdleSounds) ] )
				self:ResetSequence( "idle" )
				self.IsCharging = false
				self:BreakableWait( math.random( 1, 2 ) )
			end	
		end	
	end
end

function ENT:DoCycles( )
	if ( self:GetCycle( ) == 1 ) then
		self:SetCycle( 0 )
	elseif ( self:GetCycle( ) == 1 ) then
		self:SetCycle( 1 )
	end
end

function ENT:NavigateToRandomPos( isWalking, desiredSpeed, maxDistance )
	if ( isWalking ) then
		self:ResetSequence( "walk_all" )
		//self:StartActivity( ACT_WALK )
	else
		self:ResetSequence( "run_all" )
		//self:StartActivity( ACT_RUN )
	end
	self.loco:SetDesiredSpeed( desiredSpeed )
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

function ENT:EscapableMoveToPos( pos, options )
	self.EscapeMove = false
	local options = options or {}
	local path = Path( "Follow" )
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
			self:EmitSound( self.FootstepSounds[ math.random( #self.FootstepSounds ) ] )
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

function ENT:JumpTowards( pos, options )
	self.loco:SetDesiredSpeed( 600 )     
	self.loco:SetAcceleration( 1200 )
	local options = options or {}
	local path = Path( "Follow" )

	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, pos )

	if ( !path:IsValid() ) then return "failed" end
	while ( path:IsValid() ) do
		//self:SetSequence( "jump_start" )

		local rndChance = math.random( 1, 20 )
		if ( rndChance > 15 ) then
			self:EmitSound( self.FootstepSounds[ math.random( #self.FootstepSounds ) ] )
		end

		self.loco:FaceTowards( pos )
		self:DoCycles( )
		path:Update( self )

		if ( options.draw ) then
			path:Draw()
		end

		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
		end

		if ( options.maxage ) then
			if ( path:GetAge() > options.maxage ) then return "timeout" end
		end

		if ( options.repath ) then
			if ( path:GetAge() > options.repath ) then path:Compute( self, pos ) end
		end
		/*if ( !self.loco:IsClimbingOrJumping( ) and path:GetAge( ) > options.maxage * 0.2 ) then
			
		end*/
		-- Basically what this does is as soon as the cat begins moving to the position, it will jump, and then it breaks out of the while loop.
		if ( !self.loco:IsClimbingOrJumping( ) and path:GetAge( ) > options.maxage * 0.1 ) then
			if not( self.flySoundPatch ) then
				self.flySoundPatch = CreateSound( self, "npc/antlion/fly1.wav" )
				self.flySoundPatch:Play( )
				table.insert( self.SoundPatches, self.flySoundPatch )
			else
				if not ( self.flySoundPatch:IsPlaying( ) ) then
					self.flySoundPatch:Play( )
				end
			end
			self.loco:Jump( )
			path:Invalidate( )
			continue
		end

		coroutine.yield()
	end

	return "ok"
end
AddCSLuaFile( )

ENT.Base = "base_nextbot"
ENT.Spawnable = false
ENT.AdminSpawnable = true
ENT.EscapeMove = false
ENT.BreakWait = false
ENT.AggroTable = { }
function ENT:Initialize( )

	self:SetModel( "models/combine_soldier.mdl" )
	self:SetSkin( math.random( 0, 1 ) )
	self:SetHealth( math.random( 100, 300 ) )
	--self:SetCollisionBounds( self.DefaultBounds[1], self.DefaultBounds[2] )
	self.loco:SetDeathDropHeight( self.DeathDropHeight or 200 )
	self.loco:SetAcceleration( self.BotAcceleration or 200 )
	self.loco:SetDeceleration( self.BotDeceleration or 200 )
	self.loco:SetStepHeight( self.BotStepHeight or 18 )
	self.loco:SetJumpHeight( self.BotJumpHeight or 58 )

	local wep = ents.Create( "weapon_ar2" )
	local pos = self:GetAttachment( self:LookupAttachment( "anim_attachment_RH" ) ).Pos
	wep:SetOwner( self )
	wep:SetPos( pos )
	wep:Spawn( )
	wep:SetSolid( SOLID_NONE )
	wep:SetParent( self )
	wep:Fire( "setparentattachment", "anim_attachment_RH" )
	wep:AddEffects( EF_BONEMERGE )
	wep.nextBotWep = true
	wep.nextBotOwner = self
	self.Weapon = wep
	timer.Simple( 3, function( )
		if not ( IsValid( self ) ) then return end
		self:CheckTargetDistance( )
	end )
end

function ENT:CheckTargetDistance( )
	if ( IsValid( self.target ) ) then
		if ( self:GetPos( ):Distance( self.target:GetPos( ) ) > 1500 ) then
			if ( self.AggroTable[self.target:SteamID( )] and self.AggroTable[self.target:SteamID( )] < CurTime( ) ) then
				self.target = nil
			end
		end
	end
	timer.Simple( 3, function( )
		if not ( IsValid( self ) ) then return end
		self:CheckTargetDistance( )
	end )
end

function ENT:SearchForEnemy( )
	local plyTable = player.GetAll( )
	local distanceTable = { }
	local returnPly = nil
	for index, ply in ipairs ( plyTable ) do
		if ( ply:GetPos( ):Distance( self:GetPos( ) ) < 1000 and ( !ply:IsGhost( ) and ply:Alive( ) ) ) then
			table.insert( distanceTable, { ply = ply, dist = self:GetPos( ):Distance( ply:GetPos( ) ) } )
		end
	end
	if ( istable( distanceTable ) and #distanceTable > 0 ) then
		table.SortByMember( distanceTable, "dist" )
		returnPly = distanceTable[1].ply
	end
	return ( returnPly )
end

function ENT:ShootBullets( )
	local shootPos = self.Weapon:GetAttachment( self.Weapon:LookupAttachment( "muzzle" ) ).Pos
	local bullet = {}
	bullet.Num 		= 2
	bullet.Src 		= shootPos
	bullet.Dir 		= self:GetForward( )
	bullet.Spread 	= Vector( 0, 0, 0 )
	bullet.TracerName = "NextBotPlainTracer"
	bullet.Tracer	= 1	
	bullet.Force	= 1
	bullet.Damage	= 5
	bullet.AmmoType = "ar2"
	self:FireBullets( bullet )
end

function ENT:OnLandOnGround( )
	//self:ResetSequence( "idle1_smg1" )
end

function ENT:OnKilled( dmgInfo )

	self:BecomeRagdoll( dmgInfo )

end

function ENT:OnInjured( dmgInfo )
	if ( dmgInfo:GetAttacker( ):IsPlayer( ) ) then
		self.AggroTable[dmgInfo:GetAttacker( ):SteamID( )] = CurTime( ) + 5
		self.EscapeMove = true
	end
end

function ENT:BehaveUpdate( num )
	if ( !self.BehaveThread ) then return end
	local ok, message = coroutine.resume( self.BehaveThread )
	if ( IsValid( self.enemy ) ) then
		self.loco:FaceTowards( self.enemy:GetPos( ) )
	end
	if ( ok == false ) then
		self.BehaveThread = nil
		Msg( self, "error: ", message, "\n" );
	end
end

function ENT:RunBehaviour( )
	while ( true ) do
		self.enemy = self:SearchForEnemy( )
		if ( IsValid( self.enemy ) ) then
			if ( self.enemy:GetPos( ):Distance( self:GetPos( ) ) > 600 ) then
				self:ResetSequence( "runall" )
				self.loco:SetDesiredSpeed( 300 )
				self:EscapableMoveToPos( self.enemy:GetPos( ), { tolerance = 600 } )
				if ( self.enemy:GetPos( ):Distance( self:GetPos( ) ) < 600 ) then
					self:ResetSequence( "shootsmg1s" )
					local timerName = "FireBullets_" .. self:EntIndex( )
					timer.Create( timerName, 0.1, 10, function( ) 
					if not ( IsValid( self ) ) then timer.Destroy( timerName ) return end
					if ( !IsValid( self.enemy ) or !self.enemy:Alive( ) or self.enemy:IsGhost( ) ) then timer.Destroy( timerName ) return end
						self:ShootBullets( )
					end )
				end
			else
				self:SetSequence( "shootsmg1s" )
				local timerName = "FireBullets_" .. self:EntIndex( )
				timer.Create( timerName, 0.1, 10, function( ) 
					if not ( IsValid( self ) ) then timer.Destroy( timerName ) return end
					if ( !IsValid( self.enemy ) or !self.enemy:Alive( ) or self.enemy:IsGhost( ) ) then timer.Destroy( timerName ) return end
					self:ShootBullets( )
				end )
			end
			self:BreakableWait( 0.25 )
		else
			self:NavigateToRandomPos( false, 300, 768 )
			self:ResetSequence( "idle1_smg1" )
			self:BreakableWait( 1 )
		end

	end
end

function ENT:NavigateToRandomPos( isWalking, desiredSpeed, maxDistance )
	if ( isWalking ) then
		self:ResetSequence( "walk_all" )
	else
		self:ResetSequence( "runall" )
	end
	self.loco:SetDesiredSpeed( desiredSpeed )
	local destinationPos = self:GetPos( ) + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * maxDistance
	self:EscapableMoveToPos( destinationPos )
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


local function DontPickupWeapons( ply, wep )
	if ( wep.nextBotWep and IsValid( wep.nextBotOwner ) ) then
		return false
	end
end
hook.Add( "PlayerCanPickupWeapon", "NextbotWeapons", DontPickupWeapons)
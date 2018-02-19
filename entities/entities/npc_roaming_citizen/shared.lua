AddCSLuaFile( )

ENT.Base = "base_nextbot"
ENT.Spawnable = false
ENT.AdminSpawnable = true
ENT.EscapeMove = false
ENT.BreakWait = false
ENT.IsFleeing = false
ENT.DefaultBounds = { Vector( -4, -4, 0 ), Vector( 4, 4, 32 ) }
ENT.ModelTable = { "models/Humans/Group02/Male_01.mdl", "models/Humans/Group02/Male_02.mdl", "models/Humans/Group02/Male_03.mdl", 
"models/Humans/Group02/Male_04.mdl", "models/Humans/Group02/Male_05.mdl", "models/Humans/Group02/Male_06.mdl", 
"models/Humans/Group02/Male_07.mdl", "models/Humans/Group02/Male_08.mdl", "models/Humans/Group02/Male_09.mdl",
"models/Humans/Group01/Female_01.mdl", "models/Humans/Group01/Female_02.mdl", "models/Humans/Group01/Female_03.mdl",
"models/Humans/Group01/Female_04.mdl", "models/Humans/Group01/Female_06.mdl", "models/Humans/Group01/Female_07.mdl" }

ENT.MalePainSounds = { "vo/npc/male01/pain01.wav", "vo/npc/male01/pain02.wav", "vo/npc/male01/pain03.wav",
"vo/npc/male01/pain04.wav", "vo/npc/male01/pain05.wav", "vo/npc/male01/pain06.wav", "vo/npc/male01/pain07.wav", 
"vo/npc/male01/pain08.wav", "vo/npc/male01/pain09.wav" }

ENT.FemalePainSounds = { "vo/npc/female01/pain01.wav", "vo/npc/female01/pain02.wav", "vo/npc/female01/pain03.wav",
"vo/npc/female01/pain04.wav", "vo/npc/female01/pain05.wav", "vo/npc/female01/pain06.wav", "vo/npc/female01/pain07.wav",
"vo/npc/female01/pain08.wav", "vo/npc/female01/pain09.wav" }

function ENT:Initialize( )

	self:SetModel( self.ModelTable[ math.random( #self.ModelTable ) ] )
	self:SetSkin( self.BotSkin or 0 )
	self:SetHealth( math.random( 100, 300 ) )
	--self:SetCollisionBounds( self.DefaultBounds[1], self.DefaultBounds[2] )
	self.loco:SetDeathDropHeight( self.DeathDropHeight or 200 )
	self.loco:SetAcceleration( self.BotAcceleration or 400 )
	self.loco:SetDeceleration( self.BotDeceleration or 400 )
	self.loco:SetStepHeight( self.BotStepHeight or 18 )
	self.loco:SetJumpHeight( self.BotJumpHeight or 58 )

	self.IsJumping = false

end

function ENT:OnLandOnGround( )
	self.IsJumping = false
	self:StartActivity( ACT_RUN )
end

function ENT:OnKilled( dmgInfo )

	self:BecomeRagdoll( dmgInfo )

end

function ENT:OnInjured( )
	self.EscapeMove = true
	self.BreakWait = true
	if ( self:IsMale( ) ) then
		self:EmitSound( self.MalePainSounds[ math.random( #self.MalePainSounds ) ] )
	else
		self:EmitSound( self.FemalePainSounds[ math.random( #self.FemalePainSounds ) ] )
	end 
	self.IsFleeing = true
end

function ENT:RunBehaviour( )
	while ( true ) do
		if not ( self.IsFleeing ) then
			self:NavigateToRandomPos( tobool( math.random( 0, 1 ) ), math.random( 100, 300 ), math.random( 100, 500 ) )
			self:StartActivity( ACT_IDLE )
			self:BreakableWait( math.random( 3, 5 ) )
		else
			self:NavigateToRandomPos( false, math.random( 300, 500), math.random( 900, 1600 ) )
			self.IsFleeing = false
			self:StartActivity( ACT_IDLE )
			self:BreakableWait( math.random( 1, 3 ) )
		end						
	end
end

function ENT:IsMale( )
	if ( string.find( string.lower( self:GetModel( ) ), "female" ) ) then
		return false
	else
		return true
	end
end

function ENT:NavigateToRandomPos( isWalking, desiredSpeed, maxDistance )
	if ( isWalking ) then
		self:StartActivity( ACT_WALK )
	else
		self:StartActivity( ACT_RUN )
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
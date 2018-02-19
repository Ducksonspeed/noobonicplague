ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Frag Grenade"
ENT.Author = "Jeezy"
ENT.Spawnable = false

if ( SERVER ) then
	AddCSLuaFile( )
	function ENT:Initialize( )
		self:SetModel( "models/weapons/w_eq_fraggrenade.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		local phys = self:GetPhysicsObject( )
		if phys:IsValid( ) then
			phys:Wake( )
		end
		timer.Simple( 3, function( ) self:Explode( ) SafeRemoveEntity( self ) end )
	end

	function ENT:Explode( )
		local curPos = self:GetPos( )
		local fragExplosion = ents.Create( "env_explosion" )
		fragExplosion:SetOwner( self.OwningEnt )
		fragExplosion:SetPos( curPos )
		fragExplosion:SetKeyValue( "iMagnitude", "100" )
		fragExplosion:Spawn( )
		fragExplosion:Activate( )
		fragExplosion:Fire( "Explode", "", 0 )
		/*local explodeRange = Vector( 1024, 1024, 1024 )
		local nearbyEnts = ents.FindInBox( curPos - explodeRange, curPos + explodeRange )
		if ( istable( nearbyEnts ) and #nearbyEnts > 1 ) then
			local curHits = { }
			for index, ent in ipairs ( nearbyEnts ) do
				if ( ent:IsPlayer( ) ) then
					local traceData = { }
					traceData.start = curPos
					traceData.endpos = ent:GetPos( )
					traceData.filter = function( ent ) 
						if ( curHits[ent:EntIndex( )] ) then 
							return false 
						else
							return true
						end
					end
					local traceRes = util.TraceLine( traceData )
					if ( traceRes.HitPos:IsEqualTol( ent:GetPos( ), 48 ) ) then
						local dmgAmt = ent:Health( ) * math.Rand( 0.4, 0.8 )
						ent:TakeDamage( 50, self.OwningEnt, self )
						curHits[traceRes.Entity:EntIndex( )] = true
					end
				end
			end
		end
		local effectData = EffectData()
		effectData:SetStart( self:GetPos( ) )
		effectData:SetOrigin( self:GetPos( ) )
		effectData:SetScale( 1 )
		util.Effect( "Explosion", effectData )*/
	end
else
	function ENT:Draw( )
		self:DrawModel( )
	end
end
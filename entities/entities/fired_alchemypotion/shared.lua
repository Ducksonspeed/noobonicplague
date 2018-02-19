ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Fired Alchemy Potion"
ENT.Author = "Jeezy"
ENT.Spawnable = false
ENT.MaxBounces = 3
ENT.DefaultFiredPotionCooldown = 30
ENT.PotionSplashColors = { Color( 125, 125, 175 ), Color( 175, 125, 125 ), Color( 125, 175, 125 ) }
if ( SERVER ) then
	AddCSLuaFile( )
	function ENT:Initialize( )
		self:SetModel( "models/props/jeezy/potions/potion01.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		local phys = self:GetPhysicsObject( )
		if phys:IsValid( ) then
			phys:Wake( )
		end
		self.potionBounces = 0
		self:SetModelScale( 0.75, 0 )
		self:SetSkin( math.random( 0, 2 ) )
		local splashColor = self.PotionSplashColors[math.random( #self.PotionSplashColors ) ]
		self.stringSplashColor = splashColor.r .. ", " .. splashColor.g .. ", " .. splashColor.b
 	end

	function ENT:PhysicsCollide( colData, collider )
		if ( self.potionBounces == self.MaxBounces ) then
			SafeRemoveEntity( self )
		end
		local physObj = self:GetPhysicsObject( )
		if not ( IsValid( physObj ) ) then return end
		if ( physObj ~= colData.PhysObj ) then
			self.potionBounces = self.potionBounces + 1
			local effectData = { }
			effectData.startSize = "5"
			effectData.endSize = "10"
			effectData.startColor = self.stringSplashColor
			effectData.endColor = self.stringSplashColor
			effectData.spawnRate = "3"
			effectData.spawnRadius = "5"
			effectData.lifeTime = "1"
			util.CreateSmokeClouds( effectData, self:GetPos( ), 0.25 )
			self:EmitSound( "physics/glass/glass_bottle_impact_hard" .. math.random( 1, 2 ) .. ".wav", 100, math.random( 100, 150 ) )
		end
		local lastSpeed = math.max( colData.OurOldVelocity:Length(), colData.Speed )
		local newVelocity = physObj:GetVelocity()
		newVelocity:Normalize()
		
		lastSpeed = math.max( newVelocity:Length(), lastSpeed )
		
		local targetVelocity = newVelocity * lastSpeed * 1.3
		
		physObj:SetVelocity( targetVelocity + Vector( 0, 0, 300 ) )
	end

	function ENT:Touch( ent )
		if ( ent:IsPlayer( ) and !ent:IsGhost( ) ) then
			local typeEnum = NOOBRP.PotionCategories[ self.PotionName ]
			if ( typeEnum and NOOBRP.PotionFunctions[ self.PotionName ] ) then
				ent.PotionCooldowns = ent.PotionCooldowns or { }
				local cooldownLength = ent.PotionCooldowns[ typeEnum ] or 0
				if ( cooldownLength < CurTime( ) ) then
					NOOBRP.PotionFunctions[ self.PotionName ]( ent, self )
					ent.PotionCooldowns[ typeEnum ] = ent.PotionCooldowns[ typeEnum ] or 0
					ent.PotionCooldowns[ typeEnum ] = CurTime( ) + self.DefaultFiredPotionCooldown
				end
			end
			local effectData = { }
			effectData.startSize = "15"
			effectData.endSize = "50"
			effectData.startColor = self.stringSplashColor
			effectData.endColor = self.stringSplashColor
			effectData.spawnRadius = "10"
			effectData.spawnRate = "1"
			effectData.lifeTime = "1"
			util.CreateSmokeClouds( effectData, self:GetPos( ), 1 )
			ent:EmitSound( "physics/glass/glass_cup_break" .. math.random( 1, 2 ) .. ".wav", 100, math.random( 100, 150 ) )
			if ( IsValid( self.OwningEnt ) ) then
				ent:AttemptFlagSelfDefense( self.OwningEnt, 1 )
			end
			SafeRemoveEntity( self )
		end
	end
else
	function ENT:Draw( )
		self:DrawModel( )
	end
end
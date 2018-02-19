function EFFECT:Init( data )
	local Pos = data:GetOrigin()
	
	local emitter = ParticleEmitter( Pos )
	
	for i = 1,11 do

		local particle = emitter:Add( "particles/fire_glow", Pos + Vector( math.random(0,0),math.random(0,0),math.random(0,0) ) ) 
		 
		if particle == nil then particle = emitter:Add( "particles/fire_glow", Pos + Vector(   math.random(0,0),math.random(0,0),math.random(0,0) ) ) end
		
		if (particle) then
			particle:SetVelocity(Vector(math.random(0,0),math.random(0,0),math.random(0,0)))
			particle:SetLifeTime(0.55365493856289) 
			particle:SetDieTime(1.026560194883) 
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(15.980479493773) 
			particle:SetEndSize(35.120339868708)
			particle:SetAngles( Angle(0,0,0) )
			particle:SetAngleVelocity( Angle(0,0,0) ) 
			particle:SetRoll(math.Rand( 0, 360 ))
			particle:SetColor(math.random(37,70),math.random(74,155),math.random(149,240),math.random(255,255))
			particle:SetGravity( Vector(0,0,0) ) 
			particle:SetAirResistance(0 )  
			particle:VelocityDecay( false )
			particle:SetCollide(false)
			particle:SetBounce(0)
		end
	end

	emitter:Finish()
		
end

function EFFECT:Think()		
	return false
end

function EFFECT:Render()
end
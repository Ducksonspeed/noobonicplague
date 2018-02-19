EFFECT.Mat = Material( "effects/spark" )

--[[---------------------------------------------------------
   Init( data table )
-----------------------------------------------------------]]
function EFFECT:Init( data )

	self.StartPos 	= data:GetStart( )
	self.EndPos 	= data:GetOrigin()
	self.Dir 		= self.EndPos - self.StartPos
	
	
	self:SetRenderBoundsWS( self.StartPos, self.EndPos )
	
	self.TracerTime = math.Rand( 0.2, 0.3 )
	self.Length = math.Rand( 0.1, 0.15 )
	
	-- Die when it reaches its target
	self.DieTime = CurTime() + self.TracerTime
	
end

--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]
function EFFECT:Think( )

	if ( CurTime() > self.DieTime ) then

		-- Awesome End Sparks
		local effectdata = EffectData()
			effectdata:SetOrigin( self.EndPos + self.Dir:GetNormalized() * -2 )
			effectdata:SetNormal( self.Dir:GetNormalized() * -3 )
			effectdata:SetMagnitude( 0.15 )
			effectdata:SetScale( 0.15 )
			effectdata:SetRadius( 0.15 )
		util.Effect( "Sparks", effectdata )
	
		return false 
	end
	
	return true

end

--[[---------------------------------------------------------
   Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render( )

	local fDelta = (self.DieTime - CurTime()) / self.TracerTime
	fDelta = math.Clamp( fDelta, 0, 1 ) ^ 0.5
			
	render.SetMaterial( self.Mat )
	
	//local sinWave = math.sin( fDelta * math.pi )
	local sinWave = 0.05
	render.DrawBeam( self.EndPos - self.Dir * (fDelta - sinWave * self.Length ), 		
					 self.EndPos - self.Dir * (fDelta + sinWave * self.Length ),
					 2 + sinWave * 2,					
					 1,					
					 0,				
					 Color( 255, 255, 255, 255 ) )
					 
end
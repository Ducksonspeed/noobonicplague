AddCSLuaFile("shared.lua")
include('shared.lua')
SWEP.loaded = true

function SWEP:DoHolster()
	if IsValid( self.hook ) then 
		self.hook:Remove( ) 
	end
end

function SWEP:DoPrimary()
	if not self.loaded then return end
	local dir = self.Owner:GetAimVector()
	local pos = self.Owner:GetShootPos() + dir * 20
	local trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = trace.start + dir * 50
	trace.filter = {self.Owner}
	if util.TraceLine(trace).Fraction < 1 then self.Owner:ChatPrint("No room to fire.") return end
	local ent = ents.Create("ent_grappling_hook")
	ent.OwnerID = self.Owner.SID
	ent.SID = self.Owner.SID
	ent.Owner = self.Owner
	ent.aimvec = dir
	ent:Spawn()
	ent:Activate()
	ent:SetPos(pos)
	ent:SetAngles(self.Owner:GetAngles())
	local function ReloadGrap()
		if IsValid(self) then self.loaded = true end
	end
	ent:CallOnRemove("Reload", ReloadGrap)
	self.Owner:EmitSound(self.Sound)
	self.loaded = false
	self.hook = ent
	
	local rope = ents.Create( "keyframe_rope" )
	rope:SetPos( pos )
	rope:SetKeyValue( "Width", 2 )
	rope:SetKeyValue( "RopeMaterial", "cable/rope" )
	rope:SetEntity( "StartEntity", 		self.Owner )
	rope:SetKeyValue( "StartOffset", 	tostring(Vector(0, 0, 55)) )
	rope:SetKeyValue( "StartBone", 		5 )
	rope:SetEntity( "EndEntity", 		ent )
	-- rope:SetKeyValue( "EndOffset", 		tostring(LPos2) )
	rope:SetKeyValue( "EndBone", 		0 )
	rope:SetKeyValue("Collide", 1)
	rope:SetKeyValue("Slack", 0)
	rope:Spawn()
	rope:Activate()

	self:DeleteOnRemove( rope )
	self:DeleteOnRemove( ent )
	ent:DeleteOnRemove( rope )

	ent.rope = rope
	self.rope = rope
end

function SWEP:DoSecondary()
	if not IsValid(self.rope) or not IsValid(self.hook) or not self.hook.stuck then 
		return 
	end
	self.rope:SetKeyValue("Slack", 0)
	local vec = (self.hook:GetPos() + Vector(0, 0, 80)) - self.Owner:GetShootPos()
	local len = math.Clamp(vec:Length(), 50, 500)
	local dir = vec:GetNormal()
	if not ( vec.z > self.Owner:GetPos( ).z + 250 ) then
		if ( self.Owner:IsWearingTurtleHat( ) ) then
			len = math.Clamp( len, 50, 100 )
		end
	end
	self.Owner:SetVelocity((dir * len) - self.Owner:GetVelocity())
end

function SWEP:DoReload()
	if self.hook and IsValid(self.hook) then self.hook:Remove() end
end

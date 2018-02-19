// By Sinvavestos

ENT.Type = "anim"  
ENT.Base = "base_gmodentity"  
  
if SERVER then   
AddCSLuaFile("shared.lua")

function ENT:Initialize()   
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_NONE )
	self:PhysicsInitSphere(1)
	self:GetPhysicsObject():Wake()
	self:GetPhysicsObject():EnableCollisions( false )
	self:GetPhysicsObject():EnableGravity( false )
	self:GetPhysicsObject():EnableMotion( true )
	self:DrawShadow(false)
	self:SetNoDraw(true)
	self:SetNotSolid(true)
end

end  
  
/*if CLIENT then  
function ENT:Draw() 
	local p = self:GetOwner():GetRagdollEntity() or self:GetOwner()
      local head = p:LookupBone("ValveBiped.Bip01_Spine")

	local pos, angle = p:GetBonePosition(head)
			
	self:SetPos(pos + (angle:Forward() * 40) )  
	self:SetAngles(angle)  

end  
end*/
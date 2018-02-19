AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/items/crossbowrounds.mdl")
	util.PrecacheSound("weapons/crossbow/hit1.wav")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	local phys = self.Entity:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
		phys:AddVelocity(self.aimvec * 1000)
	end
	timer.Simple(10, function() if IsValid(self) then self:Remove() end end)
end

function ENT:PhysicsCollide(dat, obj)
	self.stuck = true
	obj:EnableMotion(false)
	self:EmitSound("weapons/crossbow/hit1.wav")
	self.rope:SetKeyValue("Slack", (self:GetPos() - self.Owner:GetShootPos()):Length() + 100)
end
	
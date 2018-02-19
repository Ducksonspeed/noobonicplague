AddCSLuaFile( )
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Beast Mound"
ENT.Author = "Jeezy"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:Initialize( )
	self:SetModel("models/props_wasteland/antlionhill.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetModelScale( 1, 0 )
	local physObj = self:GetPhysicsObject( )
	if ( physObj:IsValid( ) ) then
		physObj:Wake( )
		physObj:EnableMotion( false )
	end
end

if ( CLIENT ) then
	function ENT:Draw()
		self.Entity:DrawModel()
	end
end
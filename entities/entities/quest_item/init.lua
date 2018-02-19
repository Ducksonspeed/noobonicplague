AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel( self.Model )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	phys:Wake()
end

function ENT:Use( activator, caller )
	if not ( self.QuestObjective ) then return end
	local isOnQuest, questStage = activator:IsOnQuest( self.QuestObjective )
	if ( questStage == "stage_complete" ) then return end
	if not ( isOnQuest ) then return end
	if not ( self.QuestFunc ) then return end
	self.QuestFunc( activator )
end
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Herb"
ENT.Author = "Jeezy"
ENT.Spawnable = false

function ENT:SetupDataTables()
	self:NetworkVar( "Entity",0, "owning_ent" )
	self:NetworkVar( "Entity",1, "UsingEnt" )
	self:NetworkVar( "Int", 2, "HarvestLength" )
	self:NetworkVar( "Int", 3, "FinishTime" )
end
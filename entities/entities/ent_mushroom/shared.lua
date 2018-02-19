ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Mushroom"
ENT.Author = "Jeezy"
ENT.Spawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Entity",1,"owning_ent")
end
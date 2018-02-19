ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Plague Laboratory"
ENT.Author = "Jeezy"
ENT.Spawnable = false

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "owning_ent" )
end
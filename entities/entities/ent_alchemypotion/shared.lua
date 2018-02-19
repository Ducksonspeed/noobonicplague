ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Alchemy Potion"
ENT.Author = "Jeezy"
ENT.Spawnable = false

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "owning_ent" )
	self:NetworkVar( "String", 0, "PotionName" )
end
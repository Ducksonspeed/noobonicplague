ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "2014 Christmas Present"
ENT.Author = "Jeezy"
ENT.Spawnable = false

function ENT:SetupDataTables( )
	self:NetworkVar( "Entity", 0, "GiftPlayer" )
end
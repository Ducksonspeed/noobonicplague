ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Basic Money Printer"
ENT.Author = "Jeezy"
ENT.Spawnable = false
ENT.OPEN_CLIENT_MENU = 0
ENT.REPLENISH_POWER = 1
ENT.REFILL_INK = 2
ENT.UPGRADE_CPU = 3
ENT.POWER_COST_MULTI = 8
ENT.INK_COST_MULTI = 16
ENT.CPU_COST_MULTI = 400

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "price" )
	self:NetworkVar( "Int", 1, "Power" )
	self:NetworkVar( "Int", 2, "Ink" )
	self:NetworkVar( "Int", 3, "CPU" )
	self:NetworkVar( "Entity", 0, "owning_ent" )
end
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Advanced Money Printer"
ENT.Author = "Jeezy"
ENT.Spawnable = false
ENT.OPEN_CLIENT_MENU = 0
ENT.REPLENISH_POWER = 1
ENT.REFILL_INK = 2
ENT.UPGRADE_CPU = 3
ENT.UPGRADE_RAM = 4
ENT.RESTORE_COOLANT = 5

ENT.POWER_COST_MULTI = 8
ENT.INK_COST_MULTI = 16
ENT.CPU_COST_MULTI = 500
ENT.RAM_COST_MULTI = 400
ENT.COOLANT_COST_MULTI = 20

ENT.RAMLevelNames = { }
ENT.RAMLevelNames[1] = "256MB"
ENT.RAMLevelNames[2] = "512MB"
ENT.RAMLevelNames[3] = "1024MB"
ENT.RAMLevelNames[4] = "2 x 1024MB"
ENT.RAMLevelNames[5] = "2 x 2GB"
ENT.RAMLevelNames[6] = "2 x 4GB"
ENT.RAMLevelNames[7] = "2 x 8GB"

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "price" )
	self:NetworkVar( "Int", 1, "Power" )
	self:NetworkVar( "Int", 2, "Ink" )
	self:NetworkVar( "Int", 3, "CPU" )
	self:NetworkVar( "Int", 4, "RAM" )
	self:NetworkVar( "Int", 5, "Coolant" )
	self:NetworkVar( "Entity", 0, "owning_ent" )
end
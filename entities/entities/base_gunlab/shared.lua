ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Base Gun Lab"
ENT.Author = "Pcwizdan"
ENT.Spawnable = false
ENT.WeaponName = ""
ENT.WeaponWorldModel = ""
ENT.WeaponClass = ""
ENT.GunLabModel = "models/props_c17/TrapPropeller_Engine.mdl"

if ( SERVER ) then
	ENT.GunPrice = 0
	ENT.Once = false
end

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"price")
	self:NetworkVar("Entity",1,"owning_ent")
end
AddCSLuaFile( )
ENT.Type = "anim"
ENT.Base = "base_gunlab"
ENT.PrintName = "M4A1 Gun Lab"
ENT.Author = "Pcwizdan"
ENT.Spawnable = false
ENT.WeaponName = "M4A1"
ENT.WeaponWorldModel = "models/weapons/w_rif_m4a1.mdl"
ENT.WeaponClass = "swb_m4a1"
ENT.GunLabModel = "models/props_c17/TrapPropeller_Engine.mdl"

if ( SERVER ) then
	ENT.GunPrice = 550
	ENT.Once = false
end

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"price")
	self:NetworkVar("Entity",1,"owning_ent")
end
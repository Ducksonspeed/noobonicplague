AddCSLuaFile( )
ENT.Type = "anim"
ENT.Base = "base_gunlab"
ENT.PrintName = "AK47 Gun Lab"
ENT.Author = "Pcwizdan"
ENT.Spawnable = false
ENT.WeaponName = "AK47"
ENT.WeaponWorldModel = "models/weapons/w_rif_ak47.mdl"
ENT.WeaponClass = "swb_ak47"
ENT.GunLabModel = "models/props_c17/TrapPropeller_Engine.mdl"

if ( SERVER ) then
	ENT.GunPrice = 750
	ENT.Once = false
end

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"price")
	self:NetworkVar("Entity",1,"owning_ent")
end
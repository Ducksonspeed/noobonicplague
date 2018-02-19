AddCSLuaFile( )
ENT.Type = "anim"
ENT.Base = "base_gunlab"
ENT.PrintName = "XM1014 Gun Lab"
ENT.Author = "Pcwizdan"
ENT.Spawnable = false
ENT.WeaponName = "XM1014"
ENT.WeaponWorldModel = "models/weapons/w_shot_xm1014.mdl"
ENT.WeaponClass = "swb_xm1014"
ENT.GunLabModel = "models/props_c17/TrapPropeller_Engine.mdl"

if ( SERVER ) then
	ENT.GunPrice = 1250
	ENT.Once = false
end

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"price")
	self:NetworkVar("Entity",1,"owning_ent")
end
SWEP.PrintName = "Occupy Hat"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Author = "Sinavestos"
SWEP.Instructions = "ALL DAY ALL WEEK OCCUPY WALL STREET!"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Base = "base_hat"

SWEP.ViewModel = "models/props/cs_assault/dollar.mdl"
SWEP.WorldModel = "models/props/cs_assault/dollar.mdl"

SWEP.Spawnable = false
SWEP.AdminSpawnable = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.FrameVisible = false
SWEP.OnceReload = false

SWEP.CanEquip = function( ply )
	return true
end

SWEP.EquipFunc = function( ply )
	ply:setDarkRPVar( "HatClass", "occupy_hat" )
end

SWEP.UnEquipFunc = nil
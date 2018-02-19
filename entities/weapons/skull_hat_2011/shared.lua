SWEP.PrintName = "2011 Skull Hat"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Author = "Sinavestos"
SWEP.Instructions = "Equip to scare little children"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Base = "base_hat"

SWEP.ViewModel = "models/Gibs/HGIBS.mdl"
SWEP.WorldModel = "models/Gibs/HGIBS.mdl"

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
	ply:setDarkRPVar( "HatClass", "skull_hat_2011" )
end

SWEP.UnEquipFunc = nil
SWEP.PrintName = "Blue Cape"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Author = "Jeezy"
SWEP.Instructions = "Happy Halloween!"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Base = "base_backitem"

SWEP.ViewModel = "models/accessories/jeezy/cape.mdl"
SWEP.WorldModel = "models/accessories/jeezy/cape.mdl"

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
	ply:setDarkRPVar( "BackItemClass", "blue_cape" )
end

SWEP.UnEquipFunc = nil
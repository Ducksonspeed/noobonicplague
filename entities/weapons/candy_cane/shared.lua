SWEP.PrintName = "Candy Cane"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Author = "Sinavestos"
SWEP.Instructions = "Mmm... looks delicious."
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Base = "base_backitem"

SWEP.ViewModel = "models/cloudstrifexiii/candycane/candycane_large.mdl"
SWEP.WorldModel = "models/cloudstrifexiii/candycane/candycane_large.mdl"

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
	ply:setDarkRPVar( "BackItemClass", "candy_cane" )
end

SWEP.UnEquipFunc = nil
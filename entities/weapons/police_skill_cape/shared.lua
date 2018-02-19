SWEP.PrintName = "Police Skill Cape"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Author = "Jeezy"
SWEP.Instructions = "You're a talented cop."
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Base = "base_backitem"

SWEP.ViewModel = "models/accessories/jeezy/splitcape.mdl"
SWEP.WorldModel = "models/accessories/jeezy/splitcape.mdl"

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
	ply:setDarkRPVar( "BackItemClass", "police_skill_cape" )
end

SWEP.UnEquipFunc = nil
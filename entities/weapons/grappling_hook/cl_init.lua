SWEP.PrintName = "Grappling Hook"
SWEP.Author = "Sinavestos"
SWEP.Slot = 4
SWEP.SlotPos = 3
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Left click to fire hook, right click to retract"

SWEP.DrawAmmo = false
SWEP.ViewModel 	= "models/weapons/c_crossbow.mdl";
SWEP.WorldModel = "models/weapons/w_crossbow.mdl";
SWEP.Primary.Recoil = 0
SWEP.Primary.ClipSize  = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic  = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Recoil = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.UseHands = true

function SWEP:SecondaryAttack( )
	return true
end
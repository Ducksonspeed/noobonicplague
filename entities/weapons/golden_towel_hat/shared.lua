SWEP.PrintName = "Golden Towel Hat"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Author = "Cobra"
SWEP.Instructions = "Be extra clean."
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Base = "base_hat"

SWEP.ViewModel = "models/props/cs_office/paper_towels.mdl"
SWEP.WorldModel = "models/props/cs_office/paper_towels.mdl"

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
	local HatData = { }
	HatData.Class = "golden_towel_hat"
	HatData.Model = "models/props/cs_office/paper_towels.mdl"
	HatData.AttachmentType = ENUM_HAT_BONE
	HatData.ParentName = "ValveBiped.Bip01_Head1"
	HatData.UpOffset = 0
	HatData.RightOffset = 0
	HatData.ForwardOffset = 5.3
	HatData.PitchOffset = 90
	HatData.YawOffset = 0
	HatData.RollOffset = 180
	HatData.ModelScale = 1
	HatData.ModelColor = Color( 241, 196, 15, 255 )
	HatData.ModelMaterial = ""
	ply:setDarkRPVar( "HatData", HatData )
end

SWEP.UnEquipFunc = nil
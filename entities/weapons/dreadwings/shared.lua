SWEP.PrintName = "Dreadwings"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Author = "Sinavestos"
SWEP.Instructions = "OoooOOooo scary."
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Base = "base_backitem"

SWEP.ViewModel = "models/props/jeezy/dreadwings/dreadwings.mdl"
SWEP.WorldModel = "models/props/jeezy/dreadwings/dreadwings.mdl"

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
SWEP.Color = Color( 45, 45, 45, 255 )

SWEP.CanEquip = function( ply )
	return true
end

SWEP.EquipFunc = function( ply )
	ply:setDarkRPVar( "BackItemClass", "dreadwings" )
	if not ( ply:IsWearingTurtleHat( ) ) then
		ply:SetGravity( 0.6 )
	end
end

SWEP.UnEquipFunc = function( ply )
	if not ( ply:IsGhost( ) ) then
		ply:SetGravity( 1 )
	end
end
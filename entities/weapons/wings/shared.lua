SWEP.PrintName = "Wings"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Author = "Jeezy"
SWEP.Instructions = "I believe I can fly!"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Base = "base_backitem"

SWEP.ViewModel = "models/props/jeezy/wings/wings.mdl"
SWEP.WorldModel = "models/props/jeezy/wings/wings.mdl"

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
	ply:setDarkRPVar( "BackItemClass", "wings" )
	if not ( ply:IsWearingTurtleHat( ) ) then
		ply:SetGravity( 0.6 )
	end
end

SWEP.UnEquipFunc = function( ply )
	if not ( ply:IsGhost( ) ) then
		ply:SetGravity( 1 )
	end
end
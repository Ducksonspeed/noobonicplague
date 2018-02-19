SWEP.PrintName = "Jetpack"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Author = "Jeezy"
SWEP.Instructions = "I believe I can fly!"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Base = "base_backitem"

SWEP.ViewModel = "models/accessories/jeezy/jetpack/jetpack.mdl"
SWEP.WorldModel = "models/accessories/jeezy/jetpack/jetpack.mdl"

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
	if ( ply:IsWearingHat( { "turtle_hat", "uncommon_turtle_hat", "rare_turtle_hat" } ) ) then
		ply:ErrorNotify( "You cannot equip both a Turtle Hat and a Jetpack." )
		return false
	else
		ply.nextJetpackEquip = ply.nextJetpackEquip or 0
		if ( ply.nextJetpackEquip > CurTime( ) ) then
			ply:ErrorNotify( "You cannot equip your Jetpack again for another " .. string.NiceTime( ply.nextJetpackEquip - CurTime( ) ) .. "!" )
			return false
		end
		return true
	end
end

SWEP.EquipFunc = function( ply )
	ply:setDarkRPVar( "BackItemClass", "jetpack" )
end

SWEP.UnEquipFunc = nil
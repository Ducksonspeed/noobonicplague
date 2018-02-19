SWEP.PrintName = "Uncommon Turtle Hat"
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Base = "base_hat"
SWEP.Author = "Cobra"
SWEP.Instructions = "Equip to reduce damage by 20%"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModel = "models/props/de_tides/vending_turtle.mdl"
SWEP.WorldModel = "models/props/de_tides/vending_turtle.mdl"

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
	if ( ply.isTasered ) then
		DarkRP.notify( ply, 1, 4, "How to put turtle on my head? I feel too funny..." )
		return false
	else
		if ( ply:IsWearingBackItem( "jetpack" ) ) then
			ply:ErrorNotify( "You cannot equip both a Turtle Hat and a Jetpack." )
			return false
		else
			return true
		end
	end
end

SWEP.EquipFunc = function( ply )
	ply:setDarkRPVar( "HatClass", "uncommon_turtle_hat" )
	ply:SetRunSpeed( SVNOOB_VARS:Get( "DefaultWalkSpeed" ) )
	ply:SetJumpPower( 100 )
	if ( ply:IsWearingWings( ) ) then
		ply:SetGravity( 1 )
	end
end

SWEP.UnEquipFunc = function( ply )
	ply:ApplyMovementSpeed( )
	ply:SetJumpPower( 200 )
	if ( ply:IsWearingWings( ) ) then
		local wepTable = weapons.Get( ply:getDarkRPVar( "BackItemClass" ) )
		if ( isfunction( wepTable.EquipFunc ) ) then
			wepTable.EquipFunc( ply )
		end
	end
end
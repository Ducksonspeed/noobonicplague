-- We don't need any client functions so I'm not going to AddCSLua file this.
SWEP.Author = "Noobonic Plague"
SWEP.PrintName = "Hat Base"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

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

-- Server and Client Functions & Variables
function SWEP:Initialize( )
	self:SetHoldType( "normal" )
end

function SWEP:Deploy( )
	if ( self.CanEquip( self.Owner ) ) then
		if ( SERVER ) then
			self.EquipFunc( self.Owner )
			if ( IsValid( self ) and IsValid( self.Owner ) ) then
				self.Owner:DrawWorldModel( false )
			end
			timer.Simple( 1, function( ) 
				if ( !IsValid( self ) or !IsValid( self.Owner ) ) then return end
				if ( self.Owner:IsTempItem( self:GetClass( ) ) ) then
					self.Owner:RemoveTempWeapon( self:GetClass( ) )
				else
					self.Owner:DisablePermaItem( self:GetClass( ) )
				end
				self.Owner:StripWeapon( self:GetClass( ) )
			end )
		end
		return true
	else
		self.Owner:StripWeapon( self:GetClass( ) )
		return false
	end
end
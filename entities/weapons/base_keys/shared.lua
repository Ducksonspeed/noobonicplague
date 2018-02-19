SWEP.PrintName = "Noobonic Key Base"
SWEP.Slot = 4
SWEP.SlotPos = 4
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Author = "Sinavestos/Schmal/Jeezy"
SWEP.Instructions = "Left click to spawn car."
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "rpg"

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

function SWEP:Initialize()
	self:SetHoldType( "normal" )
	-- if self.SpecifiedVehicle then
	-- 	local car = util.FindVehicleData( self.SpecifiedVehicle )
	-- 	local model = Model( car.Model )
	-- 	self.WorldModel = model
	-- 	self:SetModelScale( .05, .01 )
	-- end
end

function SWEP:PrimaryAttack()
	self:SetNextSecondaryFire(CurTime() + 0.2)
	self:SetHoldType( "pistol" )
	timer.Simple(0.2, function( )
		if ( IsValid( self ) and IsValid( self.Owner ) ) then
			self:SetHoldType( "normal" )
		end
	end )
	if SERVER then self:SpawnCar( ) end
end

function SWEP:SecondaryAttack( )
end

function SWEP:Reload( )
end
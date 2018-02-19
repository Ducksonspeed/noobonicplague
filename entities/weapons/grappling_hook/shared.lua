SWEP.Spawnable 		= false       -- Change to false to make Admin only.
SWEP.AdminSpawnable = true

SWEP.ViewModel 	= "models/weapons/c_crossbow.mdl";
SWEP.WorldModel = "models/weapons/w_crossbow.mdl";
SWEP.UseHands = true

util.PrecacheModel( SWEP.ViewModel );
util.PrecacheModel( SWEP.WorldModel );

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

SWEP.Sound = "weapons/crossbow/fire1.wav"

function SWEP:Initialize()
	if SERVER then util.PrecacheSound(self.Sound) end
	self:SetHoldType( "pistol" )
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 1)
	if SERVER then self:DoPrimary() end
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + 0.1)
	if SERVER then self:DoSecondary() end
end

function SWEP:Reload()
	if SERVER then self:DoReload() end
end

function SWEP:Holster()
	if SERVER then self:DoHolster() end
	return true
end

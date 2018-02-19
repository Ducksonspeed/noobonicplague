SWEP.PrintName = "Personal Camera"
SWEP.Author = "Jeezy"
SWEP.Purpose = ""
SWEP.Instructions = "Right click to view yourself, left click to take a picture."
SWEP.Contact = ""

SWEP.Weight = 2
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Category = "Noobonic Plague"

SWEP.ViewModel			= "models/weapons/v_hands.mdl"
SWEP.WorldModel			= "models/maxofs2d/camera.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= ""

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= ""
SWEP.ViewingSelf = false
SWEP.NextToggleView = CurTime( )
SWEP.NextPicture = CurTime( )

function SWEP:Initialize( )
	self:SetHoldType( "camera" )
end

SWEP.Category = 		"Noob"
SWEP.Spawnable      = true
SWEP.AdminOnly = false

SWEP.Purpose        	= "Shoot potions inside your category."

SWEP.Instructions   	= "Right click to change selected potion, left click to fire."

SWEP.Primary.Delay			= 1 
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1	
SWEP.Primary.Automatic   	= true	
SWEP.Primary.Ammo         	= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

SWEP.HoldType = "ar2"
SWEP.ViewModel = "models/weapons/c_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_irifle.mdl"
SWEP.UseHands = true

function SWEP:Deploy( )
	self:SetHoldType( self.HoldType )
end

function SWEP:SetupDataTables( )
	self:NetworkVar( "Int", 0, "PotionSkin" )
	self:NetworkVar( "Bool", 0, "IsFiring" )
end
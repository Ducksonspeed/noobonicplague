if ( SERVER ) then
	AddCSLuaFile( )
end

SWEP.PrintName = "Riot Shield"
SWEP.Author = "Sinavestos"
SWEP.Slot = 4
SWEP.SlotPos = 3
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "So I can dodge bullets? No..."

SWEP.Spawnable = false 
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/arleitiss/riotshield/shield.mdl"
SWEP.WorldModel = "models/arleitiss/riotshield/shield.mdl"

SWEP.Primary.Recoil = 0
SWEP.Primary.ClipSize  = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic  = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Recoil = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize( )
	self:SetHoldType( "pistol" )
	if ( SERVER ) then
		util.PrecacheSound( "physics/rubber/rubber_tire_impact_soft1.wav" )
	end
end

function SWEP:PrimaryAttack( )
end

function SWEP:SecondaryAttack( )
end

function SWEP:DeployShield( )
	timer.Simple( 0.1, function( )
		if ( !IsValid( self ) or !IsValid( self.Owner ) ) then return end
		self.Owner:DrawViewModel( false ) 
	end )
	self.Owner:DrawWorldModel( false )
	local wepIndex = self:EntIndex( )
	self.Owner:EmitSound( "physics/rubber/rubber_tire_impact_soft1.wav" )
	local deployTime = SVNOOB_VARS:Get( "RiotShieldDeployTime", true, "number", 3 )
	timer.Create( wepIndex .. ":DeployRiotShield", deployTime, 1, function( )
		if ( !IsValid( self ) or !IsValid( self.Owner ) ) then return end
		self.Owner:DrawViewModel( true )
		self.riotShieldEntity = ents.Create( "ent_riot_shield" )
		self.riotShieldEntity:SetOwner( self.Owner ) 
		self.riotShieldEntity:SetParent( self.Owner )
		self.riotShieldEntity:SetPos( self.Owner:GetPos( ) )
		self.riotShieldEntity:Spawn( )
		self.Owner.equippedRiotShield = true
	end )
end

function SWEP:RemoveShield( )
	timer.Remove( self:EntIndex( ) .. ":DeployRiotShield" )
	if ( IsValid( self ) and IsValid( self.riotShieldEntity ) ) then
		SafeRemoveEntity( self.riotShieldEntity )
	end
	if ( IsValid( self.Owner ) ) then self.Owner.equippedRiotShield = false end
end

function SWEP:Deploy( )
	if ( SERVER ) then 
		self:DeployShield( )
	end
	return true
end

function SWEP:Holster( )
	if ( SERVER ) then 
		self:RemoveShield( ) 
	end
	return true
end

function SWEP:OnRemove( )
	if ( SERVER ) then 
		self:RemoveShield( ) 
	end
end

if not ( CLIENT ) then return end

function SWEP:DrawWorldModel()
	return false
end
	
function SWEP:GetViewModelPosition( pos, ang )
	pos = pos + ( ang:Forward( ) * 20 )
	pos = pos + ( ang:Up( ) * -45 )
 
	return pos, ang
end
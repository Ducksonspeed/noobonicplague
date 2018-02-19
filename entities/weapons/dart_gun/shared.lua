if ( SERVER ) then
	AddCSLuaFile("shared.lua")
end

if ( CLIENT ) then
	SWEP.PrintName = "Dart Gun"
	SWEP.Slot = 1
	SWEP.SlotPos = 9
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "Noobonic Plague Developers"
SWEP.Instructions = "Left click to cause mayhem."
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "rpg"
SWEP.UseHands = true
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.Sound = Sound( "Weapon_USP.SilencedShot ")
SWEP.Primary.Recoil = 1.5
SWEP.Primary.Damage = 1
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.02
SWEP.Primary.Delay = 0.5

SWEP.Category = "Noobonic Plague"
SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"

function SWEP:Initialize()
	self:SetHoldType( "pistol" )
	util.PrecacheSound( "ambient/voices/cough1.wav" )
	util.PrecacheSound( "ambient/voices/cough2.wav" )
	util.PrecacheSound( "ambient/voices/cough3.wav" )
	util.PrecacheSound( "ambient/voices/cough4.wav" )
end

function SWEP:Deploy()
	self:SetHoldType( "pistol" )
	return true
end

function SWEP:Holster( )
	return true
end

function SWEP:Reload()
	self.Weapon:DefaultReload( ACT_VM_RELOAD )
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	if not self:CanPrimaryAttack() then return end

	self.Weapon:EmitSound(self.Primary.Sound)

	local bullet = {}
	bullet.Num = 1
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Spread = Vector(0.1, 0.1, 0) 
	bullet.Tracer = 1
	bullet.Force = 5
	bullet.Damage = self.Primary.Damage
	bullet.Callback = function(atk, tr, dmg)
		if ( SERVER and IsValid( tr.Entity ) and tr.Entity:IsPlayer( ) ) then
			self.Owner:InfectPlayer( tr.Entity )
		end
	end
	self.Owner:FireBullets(bullet)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self:TakePrimaryAmmo(1)

	self.Owner:ViewPunch(Angle(math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0))
end

function SWEP:SecondaryAttack()

end
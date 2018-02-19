if ( SERVER ) then
	AddCSLuaFile( )
end

SWEP.PrintName = "Disorientator"
SWEP.Author = "Sinavestos Edited by Jeezy"
SWEP.Slot = 4
SWEP.SlotPos = 3
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Left click to confuse the target."

SWEP.Spawnable = false
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/v_c4.mdl"
SWEP.WorldModel = "models/weapons/w_c4.mdl"
SWEP.UseHands = true
SWEP.Primary.Recoil = 0
SWEP.Primary.ClipSize  = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic  = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Recoil = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "none"

SWEP.DisorientSound = "ambient/energy/zap1.wav"
SWEP.DisorientCooldown = 30

if ( SERVER ) then

	function SWEP:Initialize()
		util.PrecacheSound( self.DisorientSound )
		self:SetHoldType( "pistol" )
	end

	function SWEP:PrimaryAttack( )
		self.Owner.nextDisorient = self.Owner.nextDisorient or 0
		if ( self.Owner.nextDisorient > CurTime( ) ) then
			local timeRemaining = string.NiceTime( self.Owner.nextDisorient - CurTime( ) )
			DarkRP.notify( self.Owner, 1, 4, "You must wait another " .. timeRemaining .. "." )
			return
		end
		local traceRes = self.Owner:RangeEyeTrace( 256 )
		//if ( IsValid( traceRes.Entity ) and ( traceRes.Entity:IsPlayer( ) and !traceRes.Entity:getDarkRPVar( "IsGhost" ) ) ) then
		if ( IsValid( traceRes.Entity ) and ( traceRes.Entity:IsPlayer( ) and !traceRes.Entity:IsGhost( ) ) ) then
			local traceEnt = traceRes.Entity
			if not ( traceEnt.isDisorientated ) then
				traceEnt:DisorientPlayer( math.random( 4, 9 ) )
				self.Owner:EmitSound( self.DisorientSound )
				self.Owner.nextDisorient = CurTime( ) + self.DisorientCooldown
			else
				DarkRP.notify( self.Owner, 1, 4, "That player is already disorientated!" )
			end
		end
		self:SetNextPrimaryFire( CurTime( ) + 2 )
	end
end

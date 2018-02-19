AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );
include( "shared.lua" );

SWEP.AutoSwitchTo 	= false;
SWEP.AutoSwitchFrom = false;
SWEP.Weight = 5;

function SWEP:CanPrimaryAttack()
	if ( self:GetNWBool( "reloading" ) ) then return false; end
	if ( !self:GetNWBool( "deployed" ) ) then return false; end
	return true;
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return; end

	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay );

	if ( self:Clip1() <= 0 ) then
		self:EmitSound( self.EmptyClip );
		return false;
	end

	self.Weapon:EmitSound( self.ShootSound );

	self:CSShootBullet( self.Damage, self.Recoil, self.NumOfBullets, self.Spread );
	self:TakePrimaryAmmo( 1 );
end

function SWEP:SecondaryAttack()
	if ( self:GetNWBool( "reloading" ) ) then return; end
	-- aim down sight or other
end

function SWEP:Reload()
	if ( self:GetNWBool( "reloading" ) or self:GetNextPrimaryFire() + 0.5 > CurTime() ) then return; end
	if ( self:Clip1() >= self.Primary.DefaultClip or self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then return; end

	self:SetNWBool( "reloading", true );

	self.Owner:SetAnimation( PLAYER_RELOAD );
	self:SendWeaponAnim( ACT_VM_RELOAD );
	self.Owner:GetViewModel():SetPlaybackRate( self.SeqDuration );

	local clip1 = self.Primary.DefaultClip - self:Clip1();
	local clip2 = self.Owner:GetAmmoCount( self.Primary.Ammo ) - clip1;
	if ( clip2 <= 0 ) then
		clip1 = self:Clip1() + self.Owner:GetAmmoCount( self.Primary.Ammo );
		clip2 = 0; 
	end

	if ( self.Primary.Ammo == "buckshot" ) then
		local loop = ( self.Owner:GetAmmoCount( self.Primary.Ammo ) < self.Primary.DefaultClip - self:Clip1() and self.Owner:GetAmmoCount( self.Primary.Ammo ) ) or self.Primary.DefaultClip - self:Clip1();
		
		for i = 1, loop do
			timer.Simple( i / 2, function()
				if ( !IsValid( self ) ) then return; end
				
				if ( self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
					self:SendWeaponAnim( ACT_VM_RELOAD );
					self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false );
					self:SetClip1( self.Weapon:Clip1() + 1 );
				end

				if ( self:Clip1() >= self.Primary.ClipSize or self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then
					-- if ( self:GetNWBool( "reloading" ) ) then return; end
					self:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH );
					timer.Simple( 1, function() self:SetNWBool( "reloading", false ); end );
				end
			end );
		end
	else
		timer.Simple( ( 1 + self.SeqDurationAdd / self.SeqDuration ), function()
			if ( !IsValid( self ) ) then return; end

			self:SetClip1( ( clip2 <= 0 and clip1 ) or self.Primary.DefaultClip ); -- just for reload testing purposes..
			self.Owner:RemoveAmmo( clip1, self.Primary.Ammo );

			self.ReloadAnimFix = CurTime() + 0.4;
			self:SendWeaponAnim( ACT_VM_PRIMARYATTACK ); -- apparently this fixes up reloading anim at times

			self:SetNWBool( "reloading", false );
		end );
	end
end

function SWEP:Holster()
	if ( self:GetNWBool( "reloading" ) ) then return false; end
	if ( !self:GetNWBool( "deployed" ) ) then return false; end

	return true;
end

function SWEP:Deploy()
	self.Owner:GetViewModel():SetPlaybackRate( 1.4 );
	self:SetNWBool( "deployed", false );

	timer.Simple( self.Owner:GetViewModel():SequenceDuration(), function()
		self:SetNWBool( "deployed", true );
	end );

	return true;
end

function SWEP:ShouldDropOnDie()
	return false;
end

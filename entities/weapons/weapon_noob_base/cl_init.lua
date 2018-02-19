include( "shared.lua" );

SWEP.Slot			= 1;
SWEP.SlotPos		= 2;
SWEP.DrawCrosshair	= false;

function SWEP:FireAnimationEvent( pos, ang, event, name )
	if ( self:GetNWBool( "reloading" ) ) then return true; end
	if ( self.ReloadAnimFix and self.ReloadAnimFix > CurTime() ) then return true; end
	if ( event == 5001 ) then
		if ( math.random( 1, 2 ) == 1 ) then
			local efx = EffectData();
				efx:SetFlags( 0 );
				efx:SetEntity( self.Owner:GetViewModel() );
				efx:SetAttachment( math.floor( ( event - 4991 ) / 10 ) );
				efx:SetScale( math.Rand( 1, 2 ) );
			util.Effect( "CS_MuzzleFlash", efx );
		end

		return true;
	end
end

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
end

function SWEP:SecondaryAttack()
	if ( self:GetNWBool( "reloading" ) ) then return; end
	-- aim down sight or other
end

function SWEP:Reload()
	if ( LocalPlayer():KeyDown( IN_RELOAD ) or !IsFirstTimePredicted() ) then return; end

	if ( self:GetNWBool( "reloading" ) or self:GetNextPrimaryFire() + 0.5 > CurTime() ) then return; end
	if ( self:Clip1() >= self.Primary.DefaultClip or self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then return; end

	self.Owner:SetAnimation( PLAYER_RELOAD );
end

function SWEP:Holster()
	if ( self:GetNWBool( "reloading" ) ) then return false; end
	if ( !self:GetNWBool( "deployed" ) ) then return false; end

	return true;
end

hook.Add( "HUDPaint", "DrawCrosshairNoobWeapon", function()
	local wep = LocalPlayer():GetActiveWeapon();

	if ( wep.NoobWeaponCrosshair ) then
		draw.RoundedBox( 4, ( ScrW() / 2 ) - 1, ( ScrH() / 2 ) - 1, 7, 7, color_black );
		draw.RoundedBox( 4, ScrW() / 2, ScrH() / 2, 5, 5, color_white );
	end
end );

--[[
if ( SERVER ) then AddCSLuaFile(); end

SWEP.Base 		= "weapon_base";

SWEP.PrintName    = "Noob Weapon Base";
SWEP.Instructions = "Noob Weapon Base";
SWEP.Author 	  = "Rocksofspades";

if ( CLIENT ) then
	SWEP.Slot			= 1;
	SWEP.SlotPos		= 2;
	SWEP.DrawCrosshair	= false;
elseif ( SERVER ) then
	SWEP.AutoSwitchTo 	= false;
	SWEP.AutoSwitchFrom = false;
	SWEP.Weight = 5;
end

SWEP.Spawnable 		= false;
SWEP.AdminSpawnable = true;

SWEP.ViewModelFOV  = 60;

SWEP.UseHands = true;

SWEP.ViewModel 	= "models/weapons/c_pistol.mdl";
SWEP.WorldModel = "models/weapons/w_pistol.mdl";

SWEP.Primary.ClipSize 	 = 30;
SWEP.Primary.DefaultClip = 30;
SWEP.Primary.Automatic 	 = false;
SWEP.Primary.Ammo 		 = "smg1";
SWEP.Primary.Delay 		 = 0.7;

SWEP.Secondary.ClipSize 	 = -1;
SWEP.Secondary.DefaultClip 	 = -1;
SWEP.Secondary.Automatic 	 = false;
SWEP.Secondary.Ammo 		 = "none";

SWEP.ShootSound = Sound( "Weapon_AK47.Single" );
SWEP.EmptyClip  = "weapons/clipempty_pistol.wav";

SWEP.Damage 	  = 10;
SWEP.Recoil 	  = 1;
SWEP.Spread 	  = 0.1;
SWEP.NumOfBullets = 1;

SWEP.SeqDuration 	= 1;
SWEP.SeqDurationAdd = 1;

SWEP.HoldType = "normal";
SWEP.NoobWeaponCrosshair = true;

function SWEP:Initialize()
	self:SetHoldType( self.HoldType );

	self:SetNWBool( "reloading", false );
	self:SetNWBool( "deployed", false );
end

function SWEP:CSShootBullet( dmg, recoil, numbul, cone )
	numbul = numbul or 1;
	cone = cone or 0.01;

	local bullet = {};
	bullet.Num 		= numbul;
	bullet.Src 		= self.Owner:GetShootPos();
	bullet.Dir 		= self.Owner:GetAimVector();
	bullet.Spread 	= Vector( cone, cone, 0 );
	bullet.Tracer	= 4;
	bullet.Force	= dmg;
	bullet.Damage	= dmg;
	
	self.Owner:FireBullets( bullet );
	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );

	if ( self.Owner:IsNPC() ) then return; end

	if ( CLIENT ) then
		local eyeang = self.Owner:EyeAngles();
		eyeang.pitch = eyeang.pitch - recoil;
		self.Owner:SetEyeAngles( eyeang );
	end

	/*
	if ( SERVER ) then -- thanks to Jvs for this lag compensation snippet
		local tracedata = 
		{
			start = self.Owner:GetShootPos(), 
			endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 75 ), 
			filter = self.Owner,
			mins = Vector( -8, -8, -8 ),
			maxs = Vector( 8, 8, 8 )
		};

		self.Owner:LagCompensation( true );
			local tr = util.TraceHull( tracedata );
		self.Owner:LagCompensation( false );
		
		-- if ( tr.Hit ) then return; end
	end
	*/
end

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
	self.Owner:GetViewModel():SetPlaybackRate( 1.3 );
	self:SetNWBool( "deployed", false );

	timer.Simple( self.Owner:GetViewModel():SequenceDuration() + 0.1, function()
		self:SetNWBool( "deployed", true );
	end );

	return true;
end

function SWEP:ShouldDropOnDie()
	return false;
end

if ( CLIENT ) then
	hook.Add( "HUDPaint", "DrawCrosshairNoobWeapon", function()
		local wep = LocalPlayer():GetActiveWeapon();

		if ( wep.NoobWeaponCrosshair ) then
			draw.RoundedBox( 4, ( ScrW() / 2 ) - 1, ( ScrH() / 2 ) - 1, 7, 7, color_black );
			draw.RoundedBox( 4, ScrW() / 2, ScrH() / 2, 5, 5, color_white );
		end
	end );
end
]]

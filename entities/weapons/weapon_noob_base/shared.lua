SWEP.Base 		  = "weapon_base";

SWEP.PrintName    = "Noob Weapon Base";
SWEP.Instructions = "Noob Weapon Base";
SWEP.Author 	  = "Rocksofspades";

SWEP.Spawnable 		= false;
SWEP.AdminSpawnable = true;

SWEP.ViewModelFOV  = 60;

SWEP.ViewModel 	= "models/weapons/c_pistol.mdl";
SWEP.WorldModel = "models/weapons/w_pistol.mdl";

SWEP.UseHands 	  = true;

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

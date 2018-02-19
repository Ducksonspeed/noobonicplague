if ( SERVER ) then
	AddCSLuaFile( )
end

SWEP.PrintName 	= "Frag Grenade";
SWEP.Author 	= "Jeezy";
 
SWEP.Slot = 5;
SWEP.SlotPos = 1;

SWEP.ViewModel = "models/weapons/cstrike/c_eq_fraggrenade.mdl";
SWEP.WorldModel = "models/weapons/w_eq_fraggrenade.mdl";
SWEP.ViewModelFOV = 60;
SWEP.DrawAmmo = true

SWEP.HoldType = "melee";
 
SWEP.Primary.ClipSize = 1;
SWEP.Primary.DefaultClip = 1;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo = "grenade";

SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = true;
SWEP.Secondary.Ammo = "none";
SWEP.UseHands = true

SWEP.Spawnable 			= true;
SWEP.AdminSpawnable 	= false;


function SWEP:Initialize( )
	self:SetHoldType( self.HoldType );
end

function SWEP:PrimaryAttack( )
	if not ( SERVER ) then return end
	if not ( self.isThrowing ) then
		self.isThrowing = true
		self:SendWeaponAnim( ACT_VM_PULLPIN )
		timer.Simple( 1, function( )
			if ( !IsValid( self ) or !IsValid( self.Owner ) ) then return end
			self:SendWeaponAnim( ACT_VM_THROW )
			timer.Simple( 0.5, function( )
				self.Owner:SetAnimation( PLAYER_ATTACK1 );
				self:TakePrimaryAmmo( 1 )
				local nade = ents.Create( "ent_fragnade" )
				if not ( IsValid( nade ) ) then return end
				self.Owner:GetViewModel( ):SetPlaybackRate( 0 )
				local shootPos = self.Owner:GetShootPos( )
				local shootAng = self.Owner:EyeAngles( )
				local posOffset = shootPos + ( shootAng:Right( ) * 10 )
				nade:SetPos( posOffset + ( self.Owner:GetAimVector( ) * 16 ) )
				local nadeAng = nade:GetAngles( )
				nadeAng:RotateAroundAxis( nadeAng:Right( ), 45 )
				nade:SetAngles( nadeAng )
				nade:Spawn( )
				nade.OwningEnt = self.Owner
				local physObj = nade:GetPhysicsObject( )
				if not ( IsValid( physObj ) ) then return end
				local velDir = self.Owner:GetAimVector( )
				local nadeVel = ( velDir * 500 ) + ( VectorRand( ) * 10 )
				physObj:ApplyForceCenter( nadeVel )
				timer.Simple( 1.5, function( )
					if ( !IsValid( self ) or !IsValid( self.Owner ) ) then return end
					if ( self:Clip1( ) == 0 and self.Owner:GetAmmoCount( self.Weapon:GetPrimaryAmmoType( ) ) == 0 ) then
						self.Owner:StripWeapon( "frag_grenade" )
					else
						self:DefaultReload( ACT_VM_DRAW )
						self.isThrowing = false
					end
				end )
			end )
		end ) 
	end
end

function SWEP:SecondaryAttack( )
end

if ( CLIENT ) then
	surface.CreateFont( "JZY_FragNadeFont_b", { font = "HalfLife2", size = 140, weight = 400, antialiasing = true, blursize = 5 } );
	surface.CreateFont( "JZY_FragNadeFont", { font = "HalfLife2", size = 140, weight = 400, antialiasing = true } );

	function SWEP:DrawWeaponSelection( x, y, w, t, a )
		for i = 1, 7 do
			draw.SimpleText( "k", "JZY_FragNadeFont_b", x + w / 2, y, color_black, TEXT_ALIGN_CENTER );			
		end
		draw.SimpleText( "k", "JZY_FragNadeFont", x + w / 2, y, Color( 255, 255, 0, 255 ), TEXT_ALIGN_CENTER );
	end
end


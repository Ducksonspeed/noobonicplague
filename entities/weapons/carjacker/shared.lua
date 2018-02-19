if ( SERVER ) then
	AddCSLuaFile( )
else
	SWEP.PrintName = "Carjacker"
	SWEP.Slot = 5
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "Rickster, modified by Sinavestos & Jeezy"
SWEP.Instructions = "Left click to get people out of their vehicles."
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/v_rpg.mdl")
SWEP.WorldModel = Model("models/weapons/w_rocket_launcher.mdl")
SWEP.AnimPrefix = "rpg"

SWEP.Spawnable = false
SWEP.AdminSpawnable = true

SWEP.CarJackSound = Sound("physics/wood/wood_box_impact_hard3.wav")

SWEP.Primary.ClipSize = -1 
SWEP.Primary.DefaultClip = 0        
SWEP.Primary.Automatic = false    
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        
SWEP.Secondary.DefaultClip = 0     
SWEP.Secondary.Automatic = false     
SWEP.Secondary.Ammo = ""

/*---------------------------------------------------------
Name: SWEP:Initialize()
Desc: Called when the weapon is first loaded
---------------------------------------------------------*/
function SWEP:Initialize()
	self.LastIron = CurTime()
	self:SetHoldType("normal")
	self.carJackReady = false
end

function SWEP:Deploy()
	self.carJackReady = false
end

function SWEP:PrimaryAttack()
	if ( CLIENT ) then return end

	if not self.carJackReady then return end

	local traceRes = self.Owner:RangeEyeTrace( 80 )

	self.Weapon:SetNextPrimaryFire( CurTime( ) + 2.5 )

	if ( self.Owner.nextCarJack and self.Owner.nextCarJack > CurTime( ) ) then
		local waitTime = string.NiceTime( self.Owner.nextCarJack - CurTime( ) )
		DarkRP.notify( self.Owner, 1, 4, "You must wait another " .. waitTime .. " before carjacking someone again." )
		return
	end
	if ( !IsValid( traceRes.Entity ) or !traceRes.Entity:IsVehicle( ) ) then return end

	if ( traceRes.Entity:IsVehicle( ) and string.find( string.lower( traceRes.Entity:GetClass( ) ), "bus" ) ) then
		DarkRP.notify( self.Owner, 1, 4, "You cannot carjack a bus!" )
		return
	end
	
	local drivingEnt = traceRes.Entity:GetDriver( )
	if ( IsValid( drivingEnt ) and drivingEnt:IsPlayer( ) ) then
		if ( drivingEnt:isCP( ) ) then
			self.Owner:SetWanted( 300, "" );
			PrintMessage( HUD_PRINTCENTER, self.Owner:Name( ) .. " tried to carjack a cop and is now wanted." )
			return
		end
	end
	if not ( IsValid( drivingEnt ) ) then return end
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Owner:EmitSound( self.CarJackSound )
	drivingEnt:ExitVehicle( )
	drivingEnt.VehicleEnterWait = { Delay = CurTime() + 20, Vehicle = traceRes.Entity };
	local levelData = NOOBRP_SkillAlgorithms:CalculateCriminal( self.Owner )
	/*self.Owner:setDarkRPVar( "CriminalXP", self.Owner:getDarkRPVar( "CriminalXP" ) + 1 )
	self.Owner:StoreSkillXP( NOOB_SKILL_CRIMINAL, "CriminalXP" )*/
	self.Owner:RewardXP( 1, NOOB_SKILL_CRIMINAL, "CriminalXP", "Criminal Expertise", true )
	local baseCooldown = 300
	baseCooldown = baseCooldown - ( (levelData["CurrentLevel"] / 3) or 0 ) * 10
	if ( baseCooldown < 10 ) then baseCooldown = 10 end
	self.Owner.nextCarJack = CurTime() + baseCooldown
	self.Owner:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) )
end

function SWEP:SecondaryAttack()
	if ( self.LastIron > CurTime() - 0.2 ) then return end
	self.LastIron = CurTime( )
	self.carJackReady = not self.carJackReady
	if ( self.carJackReady ) then
		self:SetHoldType( "rpg" )
	else
		self:SetHoldType( "normal" )
	end
end

function SWEP:GetViewModelPosition( pos, ang )
	local Mul = 1
	if ( self.LastIron > CurTime() - 0.25 ) then
		Mul = math.Clamp( ( CurTime( ) - self.LastIron ) / 0.25, 0, 1 )
	end

	if ( self.Ready ) then
		Mul = 1 - Mul
	end

	ang:RotateAroundAxis( ang:Right( ), - 15 * Mul )
	return pos, ang
end
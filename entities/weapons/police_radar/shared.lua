if ( SERVER ) then
	AddCSLuaFile( )
end

SWEP.Weight				= 2
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= true
SWEP.HoldType			= "pistol"

SWEP.PrintName = "Police Radar"
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.Author = "Noobonic Plague"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Hold left-click to measure speeds."
SWEP.UseHands = true

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/c_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= ""

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= ""
SWEP.RadarCooldown = 10

function SWEP:Initialize( )
	self:SetHoldType( self.HoldType )
end

function SWEP:Reload()
end 

function SWEP:PrimaryAttack()
	if not ( SERVER ) then return end
	self.nextRadarCheck = self.nextRadarCheck or 0
	if ( self.nextRadarCheck > CurTime( ) ) then
		local timeLeft = string.NiceTime( self.nextRadarCheck - CurTime( ) )
		DarkRP.notify( self.Owner, 1, 4, "You must wait another " .. timeLeft .. "!" )
		return
	end
	local traceRes = self.Owner:RangeEyeTrace( 1024 )
	if not ( IsValid( traceRes.Entity ) ) then return end
	if not ( traceRes.Entity:IsVehicle( ) ) then return end
	if not ( IsValid( traceRes.Entity:GetDriver( ) ) ) then return end
	local vehDriver = traceRes.Entity:GetDriver( )
	if ( vehDriver:isCP( ) ) then
		DarkRP.notify( self.Owner, 1, 4, "The driver is a member of the Civil Protection." )
		return
	end
	local vehSpeed = math.floor( traceRes.Entity:GetVelocity( ):Length( ) / 10 )
	if ( vehSpeed > GetGlobalInt( "N00BRP_SpeedLimit" ) ) then
		local enduranceData = { }
		enduranceData = NOOBRP_SkillAlgorithms:CalculateEndurance( vehDriver )
		levelBonus = enduranceData["CurrentLevel"];
		local amtOver = vehSpeed - GetGlobalInt( "N00B_SpeedLimit" )
		local speedBounty = math.Round( ( amtOver * 50 ) * ( math.Clamp( levelBonus / 25, 0.1, 1 ) ) )
		local cappedSpeedBounty = math.Clamp( speedBounty, 0, 2500 )
		vehDriver:SetWanted( 300, "was wanted for speeding by " .. self.Owner:Name( ) .."!" )
		if ( speedBounty > 7000 ) then
			vehDriver:RewardXP( 1, NOOB_SKILL_CRIMINAL, "CriminalXP", "Criminal Expertise", true )
			self.Owner:RewardXP( 1, NOOB_SKILL_COP, "PoliceXP", "Civil Protection", true )
		end
		PrintMessage( HUD_PRINTTALK, vehDriver:Name( ) .. " was fined $" .. cappedSpeedBounty .. " for speeding by " .. self.Owner:Name( ) .. "!" )
		if ( cappedSpeedBounty > vehDriver:getDarkRPVar( "money" ) ) then
			cappedSpeedBounty = vehDriver:getDarkRPVar( "money" )
		end
		vehDriver:addMoney( -cappedSpeedBounty )
		self.nextRadarCheck = CurTime( ) + self.RadarCooldown
	end
	self:SetNextPrimaryFire( CurTime( ) + 2 )
end 

function SWEP:SecondaryAttack()
end

if not CLIENT then return end

function SWEP:GenerateRadarTones()
	local samplerate = 44100
	local frequency = 200
	local function data( t )
		return math.sin( t / samlerate * frequency )
	end
	for i=1,300 do
		local soundName = "RADAR::" .. i
		sound.Generate( soundName, samplerate, 1, data )
		frequency = frequency + ( i * 8 )
	end
end
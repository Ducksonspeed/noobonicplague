if ( SERVER ) then
	AddCSLuaFile( )
	function SWEP:Initialize()
		util.PrecacheSound("vehicles/digger_grinder_loop1.wav")
	end
	function SWEP:SucceedSalvage( )
		self.nextSuccess = self.nextSuccess or 0
		if ( CurTime( ) < self.nextSuccess ) then return end
		self.nextSuccess = CurTime( ) + 2
		local traceRes = self.Owner:RangeEyeTrace( 96, { self } )
		if ( IsValid( traceRes.Entity ) and traceRes.Entity:IsVehicle( ) ) then
			if ( traceRes.Entity:IsLocked( ) ) then 
				self.Owner:ErrorNotify( "You cannot salvage a locked vehicle.") 
				return
			end
			if ( traceRes.Entity.isPermaVehicle == self.Owner ) then
				self.Owner:ErrorNotify( "You cannot salvage your own vehicle." )
				return
			end
			if ( traceRes.Entity.isPassengerSeat ) then
				self.Owner:ErrorNotify( "You cannot salvage a Passenger Seat!" )
				return
			end
			if traceRes.Entity.EMV then
				self.Owner:ErrorNotify( "You cannot chopshop emergency vehicles!" )
				return
			end
			local vehDriver = traceRes.Entity:GetDriver( )
			if ( IsValid( vehDriver ) and vehDriver:IsPlayer( ) ) then
				self.Owner:ErrorNotify( "That vehicle is occupied." )
				return;
			end
			local vehData = noob_VehicleIndex:Get( traceRes.Entity:GetModel( ) )
			local rndCash = math.random( 100, 300 )
			if ( vehData ) then
				rndCash = math.random( vehData.minSalvage, vehData.maxSalvage )
			end
			DarkRP.notify( self.Owner, 1, 4, "You strip the car for $" .. rndCash .. " worth of parts." )
			self.Owner:addMoney( rndCash )

			traceRes.Entity:EntitySetDamage( rndCash * 0.7, self.Owner );

			local xpRoll = math.random( 1, 10 )
			if ( xpRoll == 1 ) then
				self.Owner:RewardXP( 1, NOOB_SKILL_CRIMINAL, "CriminalXP", "Criminal Expertise", true )
			end
		end
	end
end

SWEP.PrintName = "Chopshop Tool"
SWEP.Category = "Noobonic Plague"
SWEP.Slot = 4
SWEP.SlotPos = 0
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Author = "Sinavestos : Rewritten by Jeezy"
SWEP.Instructions = "Left click to strip vehicle"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model( "models/weapons/v_crowbar.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_crowbar.mdl" )

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = -1     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false        -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""
SWEP.SalvageTime = 5
SWEP.Upgrading = false
SWEP.SalvageSoundInstance = nil

function SWEP:Initialize( )
	self:SetHoldType( "normal" )
end

function SWEP:PrimaryAttack( )
	if ( self.IsSalvaging ) then return end
	self:SetNextPrimaryFire( CurTime( ) + 0.4 )
	local traceRes = util.TraceLine( { start = self.Owner:GetShootPos( ), endpos = self.Owner:GetShootPos( ) + self.Owner:EyeAngles( ):Forward( ) * 96, filter = { self, self.Owner } } )
	if ( IsValid( traceRes.Entity ) and traceRes.Entity:IsVehicle( ) ) then
		local targetVehicle = traceRes.Entity
		self.IsSalvaging = true
		self.SalvageBegin = CurTime( )
		self.SalvageEnd = CurTime( ) + self.SalvageTime
		self:SetHoldType( "pistol" )
		if ( SERVER ) then
			self.SalvageSoundInstance = CreateSound( self.Owner, "vehicles/digger_grinder_loop1.wav" )
			self.SalvageSoundInstance:Play( )
			self.SalvageSoundInstance:ChangeVolume( 0.25, 0 )
			targetVehicle.playerLastUsed = CurTime( )
		end
	end
end

function SWEP:Holster( )
	self.IsSalvaging = false
	self:SetHoldType( "normal" )
	if ( SERVER and self.SalvageSoundInstance ) then
		self.SalvageSoundInstance:Stop( )
	end
	return true
end

function SWEP:Finish( )
	self.IsSalvaging = false
	self:SetHoldType( "normal" )
	if ( SERVER and self.SalvageSoundInstance ) then
		self.SalvageSoundInstance:Stop( )
	end
end

function SWEP:Think( )
	if ( self.IsSalvaging ) then
		local traceRes = util.TraceLine( { start = self.Owner:GetShootPos( ), endpos = self.Owner:GetShootPos( ) + self.Owner:EyeAngles( ):Forward( ) * 96, filter = { self, self.Owner } } )
		if ( !IsValid( traceRes.Entity ) or !traceRes.Entity:IsVehicle( ) ) then
			self:Finish( )
		end
		if ( self.SalvageEnd <= CurTime( ) ) then
			if ( SERVER ) then
				self:SucceedSalvage( )
			end
			self:Finish( )
		end
	end
end

function SWEP:DrawHUD( )
	if ( self.IsSalvaging ) then
		local x, y, width, height = ScrW( ) / 2 - ScrW( ) / 10, ScrH( ) / 2, ScrW( ) / 5, ScrH( ) / 15
		draw.RoundedBox( 8, x, y, width, height, Color( 10, 10, 10, 120 ) )
		local time = self.SalvageEnd - self.SalvageBegin
		local timeLeft = CurTime( ) - self.SalvageBegin
		local status = timeLeft/time
		local barWidth = status * ( width - 16 ) + 8
		draw.RoundedBox( 8, x + ScreenScale( 4 ), y + ScreenScale( 4 ), barWidth, height - ScreenScale( 8 ), Color( 255 - ( status * 255 ), 0 + ( status * 255), 0, 255 ) )
		draw.SimpleText( "Salvaging Car...", "N00BRP_DisguiseKit_HUDFont", ScrW( ) / 2, ScrH( ) / 2 + height / 2, Color( 255, 255, 255, 255 ), 1, 1 )
	end
end
if ( SERVER ) then
	AddCSLuaFile( )
	function SWEP:Initialize()
		util.PrecacheSound("vehicles/digger_grinder_loop1.wav")
	end
	function SWEP:SucceedRepair( )
		self.nextSuccess = self.nextSuccess or 0
		if ( CurTime( ) < self.nextSuccess ) then return end
		self.nextSuccess = CurTime( ) + 2
		local traceRes = self.Owner:RangeEyeTrace( 96, { self } )
		if ( IsValid( traceRes.Entity ) and traceRes.Entity:IsVehicle( ) ) then
			local vehData = noob_VehicleIndex:Get( traceRes.Entity:GetModel( ) )
			local repairAmount = math.random( 250, 1250 )
			local missingHealth = 3000 - traceRes.Entity:GetEntityHealth( )
			if ( vehData ) then
				missingHealth = vehData.health - traceRes.Entity:GetEntityHealth( )
			end
			local repairTotal = 0
			if ( repairAmount > missingHealth ) then
				repairTotal = missingHealth
			else
				repairTotal = repairAmount
			end
			if not ( self.Owner:canAfford( repairTotal ) ) then 
				DarkRP.notify( self.Owner, NOTIFY_ERROR, 4, "You can't afford to repair that." ) 
				return 
			end
			DarkRP.notify( self.Owner, 1, 4, "You repair the vehicle, costing you $" .. repairTotal .."." )
			self.Owner:addMoney( -repairTotal )

			traceRes.Entity:EntitySetDamage( -repairTotal, self.Owner );
		elseif ( IsValid( traceRes.Entity ) and traceRes.Entity:GetClass( ) == "prop_physics" ) then
			local targetProp = traceRes.Entity
			if ( targetProp:IsGodded( ) or targetProp:GetEntityHealth( ) == targetProp.EntityMaxHealth ) then return end
			local repairAmount = math.random( 250, 850 )
			local missingHealth = targetProp.EntityMaxHealth - targetProp:GetEntityHealth( )
			local repairTotal = 0
			if ( repairAmount > missingHealth ) then
				repairTotal = missingHealth
			else
				repairTotal = repairAmount
			end
			if not ( self.Owner:canAfford( repairTotal ) ) then 
				DarkRP.notify( self.Owner, NOTIFY_ERROR, 4, "You can't afford to repair that." ) 
				return 
			end
			DarkRP.notify( self.Owner, NOTIFY_HINT, 4, "You repaired the prop, costing you $" .. string.Comma( repairTotal ) .. "." )
			self.Owner:addMoney( -repairAmount )
			traceRes.Entity:EntitySetDamage( -repairTotal, self.Owner )
		end
	end
	function SWEP:FlipVehicle( veh )
		timer.Simple( 2, function( )
			if ( !IsValid( self ) or !IsValid( self.Owner ) or !IsValid( veh ) ) then return end
			local spawnPos, spawnAng = self.Owner:GetVehicleSpawnPos( )
			if ( !spawnPos or !spawnAng ) then return end
			local currentHealth = veh:GetEntityHealth( )
			local currentGas = veh.gasRemaining
			local currentColor = veh:GetColor( )
			local currentSkin = veh:GetSkin( )
			local vehName = veh.vehicleName
			local vehOwner = veh:getDoorOwner( )
			if ( IsValid( veh ) ) then SafeRemoveEntity( veh ) end
			local spawnedVehicle = noob_VehicleIndex:SpawnVehicle( vehName, spawnPos, spawnAng )
			if not ( spawnedVehicle ) then 
				return -- Not sure why it'd reach this point?
			end
			spawnedVehicle:SetEntityHealth( currentHealth )
			spawnedVehicle.gasRemaining = currentGas
			spawnedVehicle:SetRenderMode( RENDERMODE_TRANSCOLOR )
			spawnedVehicle:SetColor( currentColor )
			spawnedVehicle:SetSkin( currentSkin )
			if ( IsValid( vehOwner ) ) then
				spawnedVehicle:keysOwn( vehOwner )
				spawnedVehicle:keysLock( )
			end
			self.nextVehicleFlip = CurTime( ) + 5
		end )
	end
end

SWEP.PrintName = "Repair Tool"
SWEP.Category = "Noobonic Plague"
SWEP.Slot = 4
SWEP.SlotPos = 0
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Author = "Sinavestos : Rewritten by Jeezy"
SWEP.Instructions = "Left click to repair a vehicle."
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
SWEP.RepairTime = 5
SWEP.Upgrading = false
SWEP.RepairSoundInstance = nil

function SWEP:Initialize( )
	self:SetHoldType( "normal" )
end

function SWEP:PrimaryAttack( )
	if ( self.IsRepairing ) then return end
	self:SetNextPrimaryFire( CurTime( ) + 0.4 )
	local traceRes = util.TraceLine( { start = self.Owner:GetShootPos( ), endpos = self.Owner:GetShootPos( ) + self.Owner:EyeAngles( ):Forward( ) * 128, filter = { self, self.Owner } } )
	if ( IsValid( traceRes.Entity ) and traceRes.Entity:IsVehicle( ) ) then
		local targetVehicle = traceRes.Entity
		self.IsRepairing = true
		self.MechanicRepairBegin = CurTime( )
		self.MechanicRepairEnd = CurTime( ) + self.RepairTime
		self:SetHoldType( "pistol" )
		if ( SERVER ) then
			self.RepairSoundInstance = CreateSound( self.Owner, "vehicles/digger_grinder_loop1.wav" )
			self.RepairSoundInstance:Play( )
			targetVehicle.playerLastUsed = CurTime( )
		end
	elseif ( IsValid( traceRes.Entity ) and traceRes.Entity:GetClass( ) == "prop_physics" ) then
		local targetProp = traceRes.Entity
		self.IsRepairing = true
		self.MechanicRepairBegin = CurTime( )
		self.MechanicRepairEnd = CurTime( ) + self.RepairTime
		self:SetHoldType( "pistol" )
		if ( SERVER ) then
			self.RepairSoundInstance = CreateSound( self.Owner, "vehicles/digger_grinder_loop1.wav" )
			self.RepairSoundInstance:Play( )
		end
	end
end

function SWEP:SecondaryAttack( )
	self:SetNextSecondaryFire( CurTime( ) + 1 )
	self.nextVehicleFlip = self.nextVehicleFlip or 0
	if ( self.nextVehicleFlip < CurTime( ) ) then
		if ( SERVER ) then
			local traceEnt = self.Owner:RangeEyeTrace( 128 ).Entity
			if ( !IsValid( traceEnt ) or !traceEnt:IsVehicle( ) ) then
				self.Owner:ErrorNotify( "You must be looking at a Vehicle!" )
			else
				local canFlip = true
				if ( IsValid( traceEnt:GetDriver( ) ) ) then
					canFlip = false
				end
				if ( istable( traceEnt.passengerSeats ) and #traceEnt.passengerSeats > 0 ) then
					for index, seat in ipairs ( traceEnt.passengerSeats ) do
						if ( IsValid( seat:GetDriver( ) ) ) then
							canFlip = false
							break
						end
					end
				end
				if ( canFlip ) then
					self:FlipVehicle( traceEnt )
				else
					self.Owner:ErrorNotify( "The Vehicle cannot be occupied!" )
				end
			end
		end
	else
		if ( SERVER ) then
			self.Owner:ErrorNotify( "You cannot flip a Vehicle for another " .. string.NiceTime( self.nextVehicleFlip - CurTime( ) ) .. "!" )
		end
	end
end

function SWEP:Holster( )
	self.IsRepairing = false
	self:SetHoldType( "normal" )
	if ( SERVER and self.RepairSoundInstance ) then
		self.RepairSoundInstance:Stop( )
	end
	return true
end

function SWEP:Finish( )
	self.IsRepairing = false
	self:SetHoldType( "normal" )
	if ( SERVER and self.RepairSoundInstance ) then
		self.RepairSoundInstance:Stop( )
	end
end

function SWEP:Think( )
	if ( self.IsRepairing ) then
		local traceRes = util.TraceLine( { start = self.Owner:GetShootPos( ), endpos = self.Owner:GetShootPos( ) + self.Owner:EyeAngles( ):Forward( ) * 128, filter = { self, self.Owner } } )
		local traceEnt = traceRes.Entity
		if ( !IsValid( traceEnt ) or ( !traceEnt:IsVehicle( ) and !traceEnt:GetClass( ) == "prop_physics" ) ) then
			self:Finish( )
			return
		end
		if ( SERVER ) then
			if ( traceEnt:GetClass( ) == "prop_physics" and ( traceEnt:IsGodded( ) or traceEnt:GetEntityHealth( ) == traceEnt.EntityMaxHealth ) ) then 
				DarkRP.notify( self.Owner, NOTIFY_ERROR, 4, "That prop doesn't need to be repaired." )
				self:CallOnClient( "Finish", "" )
				self:Finish( )
				return 
			end
		end
		if ( self.MechanicRepairEnd <= CurTime( ) ) then
			if ( SERVER ) then
				self:SucceedRepair( )
			end
			self:Finish( )
		end
	end
end

function SWEP:DrawHUD( )
	if ( self.IsRepairing ) then
		local x, y, width, height = ScrW( ) / 2 - ScrW( ) / 10, ScrH( ) / 2, ScrW( ) / 5, ScrH( ) / 15
		draw.RoundedBox( 8, x, y, width, height, Color( 10, 10, 10, 120 ) )
		local time = self.MechanicRepairEnd - self.MechanicRepairBegin
		local timeLeft = CurTime( ) - self.MechanicRepairBegin
		local status = timeLeft/time
		local barWidth = status * ( width - 16 ) + 8
		draw.RoundedBox( 8, x + ScreenScale( 4 ), y + ScreenScale( 4 ), barWidth, height - ScreenScale( 8 ), Color( 255 - ( status * 255 ), 0 + ( status * 255), 0, 255 ) )
		draw.SimpleText( "Repairing Vehicle...", "N00BRP_DisguiseKit_HUDFont", ScrW( ) / 2, ScrH( ) / 2 + height / 2, Color( 255, 255, 255, 255 ), 1, 1 )
	end
end
AddCSLuaFile( )

if (SERVER) then
	AddCSLuaFile("shared.lua")
end

SWEP.PrintName = "Teleporter"
SWEP.Author = "Sinavestos : Revamped by Jeezy"
SWEP.Slot = 4
SWEP.SlotPos = 3
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Left click to mark location, right click to teleport"

SWEP.Spawnable = false       -- Change to false to make Admin only.
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/effects/combineball.mdl"
SWEP.WorldModel = "models/effects/combineball.mdl"

SWEP.Primary.Recoil = 0
SWEP.Primary.ClipSize  = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic  = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Recoil = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "none"

SWEP.TeleportSound = "ambient/machines/teleport4.wav"

function SWEP:Initialize()
	util.PrecacheSound( self.TeleportSound )
	self:SetHoldType( "normal" )
	self:DrawShadow( false )
end

if ( SERVER ) then
	
	local function BeginTeleportEffects( entIndex )
		local plyEnt = Entity( entIndex )
		if not ( IsValid( plyEnt ) ) then return end
		if not ( plyEnt.teleSWEPDestination ) then return end
		local hookOriginName = "TeleSWEPOrigin_" .. entIndex
		local hookDestName = "TeleSWEPDest_" .. entIndex
		util.BeginPortalEffect( plyEnt:GetPos( ), 1, 1, 40, Vector( 0, 0, 1 ), plyEnt, hookOriginName, nil )
		util.BeginPortalEffect( plyEnt.teleSWEPDestination, 1, 1, 40, Vector( 0, 0, 1 ), nil, hookDestName, nil )
	end

	local function EndTeleportEffects( entIndex )
		local hookOriginName = "TeleSWEPOrigin_" .. entIndex
		local hookDestName = "TeleSWEPDest_" .. entIndex
		util.EndPortalEffect( hookOriginName )
		util.EndPortalEffect( hookDestName )
	end

	function SWEP:PrimaryAttack()
		local wep = self
		wep:SetNextPrimaryFire( CurTime( ) + 1 )
		wep:SetHoldType( "pistol" )
		timer.Simple( 0.2, function( ) 
			if ( IsValid( wep ) ) then 
				wep:SetHoldType( "normal" ) 
			end 
		end )
		local traceData =  { }
		traceData.start = self.Owner:GetShootPos( )
		traceData.endpos = traceData.start + ( self.Owner:GetAimVector( ) * 100 )
		traceData.filter = { self.Owner, self }
		traceRes = util.TraceLine( traceData )
		if ( traceRes.HitWorld ) then
			self.Owner.teleSWEPDestination = traceRes.HitPos
			self.Owner:ChatPrint( "You've marked the teleport destination." )
		end
	end

	function SWEP:SecondaryAttack()
		self:SetNextSecondaryFire( CurTime( ) + 1 )
		self.Owner.teleSWEPNextUse = self.Owner.teleSWEPNextUse or 0
		self.Owner.teleSWEPNextAttempt = self.Owner.teleSWEPNextAttempt or 0
		if ( self.Owner.teleSWEPNextUse > CurTime( ) ) then
			local remainTime = string.NiceTime( self.Owner.teleSWEPNextUse - CurTime( ) )
			DarkRP.notify( self.Owner, 1, 4, "Recharging, will complete in " .. remainTime .. "." )
			return
		end
		if ( self.Owner.teleSWEPNextAttempt > CurTime( ) ) then
			local remainTime = string.NiceTime( self.Owner.teleSWEPNextAttempt - CurTime( ) )
			DarkRP.notify( self.Owner, 1, 4, "You must wait " ..  remainTime .. " before attempting to teleport again." )
			return
		end
		if not ( self.Owner.teleSWEPDestination ) then
			self.Owner:ChatPrint( "No teleport destination set." )
			self.teleSWEPNextAttempt = CurTime( ) + 5
			return
		end
		local wep = self
		local wepOwner = self.Owner
		local ownerIndex = wepOwner:EntIndex( )
		local beginPos = wepOwner:GetPos( )
		local teleTick = 0
		BeginTeleportEffects( ownerIndex )
		timer.Create( "N00BRP_TeleporterSWEP_AttemptTeleport_" .. ownerIndex, 1, 5, function( )
			if ( !IsValid( wep ) or !IsValid( wepOwner ) ) then
				timer.Destroy( "N00BRP_TeleporterSWEP_AttemptTeleport_" .. ownerIndex )
				EndTeleportEffects( ownerIndex )
				return
			end
			if ( wepOwner:GetPos( ):FastDist( beginPos ) > 80 ) then
				timer.Destroy( "N00BRP_TeleporterSWEP_AttemptTeleport_" .. ownerIndex )
				EndTeleportEffects( ownerIndex )
				wepOwner.teleSWEPNextAttempt = CurTime( ) + 5
				return
			end
			teleTick = teleTick + 1
			if ( teleTick == 5 ) then
				wep:EmitSound( wep.TeleportSound, 100, 100 )
				sound.Play( wep.TeleportSound, wepOwner.teleSWEPDestination, 100, 100 )
				wepOwner:SetPos( wepOwner.teleSWEPDestination )
				wepOwner.teleSWEPDestination = nil
				wepOwner.teleSWEPNextUse = CurTime( ) + 20
				EndTeleportEffects( ownerIndex )
				return
			end
		end )
	end
else
	function SWEP:DrawWorldModel( )
		if ( !IsValid( self.Owner ) or !IsValid( self ) ) then return end
		self:SetRenderOrigin( self.Owner:GetPos( ) + Vector(0, 0, 1) )
		self:SetRenderAngles( Angle( -90, 0, 0 ) )
		self:DrawModel( )
	end
end
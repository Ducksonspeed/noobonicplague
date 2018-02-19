if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
	local function ShrunkPlayerSquish( ply, inWater, onFloater, speed )
		local rayTable = weapons.Get( "shrink_ray" )
		local shrinkSize = 0.2
		if ( rayTable ) then
			shrinkSize = rayTable.ShrinkSize or 0.2
		end
		if ( ply:Team( ) == TEAM_CRAB or ply:GetNiceModelScale( 2 ) == shrinkSize or ply:IsGhost( ) ) then
			return
		end
		local traceRes = ply:TraceHull( -64, ply:GetUp( ), { }, true )
		if ( IsValid( traceRes.Entity ) and ( traceRes.Entity:Team( ) ~= TEAM_CRAB and traceRes.Entity:GetNiceModelScale( 2 ) == shrinkSize ) ) then
			local entPos = traceRes.Entity:GetPos( )
			traceRes.Entity:EmitSound( "physics/flesh/flesh_squishy_impact_hard" .. math.random( 4 ) .. ".wav" )
			local stompEnt = ents.Create( "goombastomp" )
			stompEnt:SetPos( Vector( 0, 0, 0 ) )
			stompEnt:Spawn( )
			traceRes.Entity:TakeDamage( ( traceRes.Entity:Health( ) * 2 ), ply, stompEnt )
			local distToGround = ( traceRes.Entity:OBBMaxs( ) / 2 )
			--entPos = entPos - Vector( 0, 0, distToGround.z )
			timer.Simple( 0.1, function( )
				for i = 1, 5 do
					local rndPos = math.Rand( -10, 10 )
					local rndPos2 = math.Rand( -10, 10 )
					util.Decal( "yellowblood", entPos + Vector( rndPos, rndPos2, -1 ), entPos + Vector( rndPos, rndPos2, 1 ) )
				end
				for i = 1, 5 do
					local rndPos = math.Rand( -10, 10 )
					local rndPos2 = math.Rand( -10, 10 )
					util.Decal( "blood", entPos + Vector( rndPos, rndPos2, -1 ), entPos + Vector( rndPos, rndPos2, 1 ) )
				end
			end )
		end
	end
	hook.Add( "OnPlayerHitGround", "N00BRP_ShrunkPlayerSquish_OnPlayerHitGround", ShrunkPlayerSquish )
else
	surface.CreateFont( "N00BRP_ShrinkRayIcon", { font = "HalfLife2", size = ScreenScale( 64 ), weight = 500, antialiasing = true, blursize = 0 } )
	surface.CreateFont( "N00BRP_ShrinkRayBlur", { font = "HalfLife2", size = ScreenScale( 64 ), weight = 500, antialiasing = true, blursize = 4 } )
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		local iconPos = { x = x + wide / 2, y = y + tall / 16 }
		local txtBounce = math.abs( math.sin( CurTime( ) * self.WepIconBounceRate ) ) * self.WepIconBounceOffset
		for i = 1, 5 do
			draw.SimpleText( "m", "N00BRP_ShrinkRayBlur", iconPos.x, iconPos.y + txtBounce, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER )
		end
		draw.SimpleText( "m", "N00BRP_ShrinkRayIcon", iconPos.x, iconPos.y + txtBounce, Color( 45, 255, 45, 255 ), TEXT_ALIGN_CENTER )
	end
end

SWEP.PrintName = "Shrink Ray"
SWEP.Author = "Sinavestos : Rewritten by Jeezy"
SWEP.Slot = 4
SWEP.SlotPos = 3
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Left click to shrink a player, right click to shrink yourself."
SWEP.Category = "Noobonic Plague"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/v_superphyscannon.mdl"
SWEP.WorldModel = "models/weapons/w_physics.mdl"

SWEP.Primary.Recoil = 0
SWEP.Primary.ClipSize  = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic  = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Recoil = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "none"

SWEP.FireRaySound = "weapons/gauss/fire1.wav"
SWEP.HitPlayerSound = "weapons/physcannon/energy_disintegrate4.wav"

SWEP.WepIconBounceRate = 8
SWEP.WepIconBounceOffset = 4
SWEP.WeaponColor = Vector( 0.1, 1, 0.1 )
SWEP.PrimaryShrinkDelay = 5
SWEP.SecondaryShrinkDelay = 30
SWEP.ShrinkSize = 0.2
SWEP.UnShrinkTime = 10

function SWEP:Initialize( )
	util.PrecacheSound( self.FireRaySound )
	util.PrecacheSound( self.HitPlayerSound )
	self:SetHoldType( "physgun" )
	self:SetSkin( 1 )
end

function SWEP:Holster( )
	if ( IsValid( self.Owner ) ) then
		if not ( SERVER ) then return true end
		local wepColor = Vector( 1, 1, 1 )
		if ( self.Owner.savedWeaponColor ) then
			wepColor = self.Owner.savedWeaponColor:ToVector( )
		end
		self.Owner:SetWeaponColor( wepColor )
	end
	return true
end

function SWEP:Deploy( )
	if ( IsValid( self.Owner ) ) then
		if ( self.Owner.VisionBlurred ) then
			DarkRP.notify( self.Owner, 1, 4, "You can't use the Shrink Ray after being tased." );
			return false;
		end
		--self.oldWeaponColor = self.Owner:GetWeaponColor( )
		self.Owner:SetWeaponColor( self.WeaponColor )
	end
	return true
end

function SWEP:OnRemove( )
	if ( IsValid( self.Owner ) ) then
		if not ( SERVER ) then return end
		local wepColor = Vector( 1, 1, 1 )
		if ( self.Owner.savedWeaponColor ) then
			wepColor = self.Owner.savedWeaponColor:ToVector( )
		end
		self.Owner:SetWeaponColor( wepColor )
	end
end

function SWEP:ZapEffect( )
	if ( IsValid( self.Owner ) ) then
		local traceRes = self.Owner:GetEyeTrace( )
		local eData = EffectData( )
		eData:SetOrigin( traceRes.HitPos )
		eData:SetStart( self.Owner:GetShootPos( ) )
		eData:SetAttachment( 1 )
		eData:SetEntity( self )
		util.Effect( "ToolTracer", eData )
	end
end

function SWEP:PrimaryAttack( )
	self:SetNextPrimaryFire( CurTime( ) + 1 )
	self.nextShrink = self.nextShrink or 0
	if ( self.nextShrink > CurTime( ) ) then
		local nextShrink = math.Round( self.nextShrink - CurTime( ) )
		if not ( SERVER ) then return end
		DarkRP.notify( self.Owner, 1, 4, "Recharging.. ready in " .. string.NiceTime( nextShrink ) .. "." )
		return
	end
	if ( SERVER ) then
		self:DoPrimaryShrink( )
	end
	
	if ( IsValid( self.Owner ) ) then
		self.Owner:ZapEffect( self, 1 )
	end
	self.nextShrink = CurTime( ) + self.PrimaryShrinkDelay
	self.nextSelfShrink = CurTime( ) + self.SecondaryShrinkDelay
end

function SWEP:SecondaryAttack( )
	if ( SERVER ) then
		self:SetNextSecondaryFire( CurTime( ) + 1 )
		self.nextSelfShrink = self.nextSelfShrink or 0
		if ( self.nextSelfShrink > CurTime( ) ) then
			local nextShrink = math.Round( self.nextSelfShrink - CurTime( ) )
			DarkRP.notify( self.Owner, 1, 4, "Recharging.. ready in " .. string.NiceTime( nextShrink ) .. "." )
			return
		end
		self:DoSecondaryShrink( )
		self.nextSelfShrink = CurTime( ) + self.SecondaryShrinkDelay
	end
end

function SWEP:DoPrimaryShrink( )
	self.Owner:EmitSound( self.FireRaySound )
	local traceRes = self.Owner:RangeEyeTrace( 16000, { self } )
	if ( traceRes.HitNonWorld and traceRes.Entity and IsValid( traceRes.Entity ) and traceRes.Entity:IsPlayer( ) and traceRes.Entity:Alive( ) ) then
		local hitEnt = traceRes.Entity
		if ( hitEnt:Team( ) == TEAM_CRAB or hitEnt:GetNiceModelScale( 2 ) == self.ShrinkSize ) then
			DarkRP.notify( self.Owner, 1, 4, hitEnt:Name( ) .. " is already pretty fucking small." )
			return
		end
		if ( hitEnt:IsGhost( ) ) then return end
		if ( self.Owner:IsPacifist( ) ) then
			self.Owner:RevokePacifism( )
		end
		hitEnt:AttemptFlagSelfDefense( self.Owner, 1 )
		hitEnt:ChatPrint( "Everything around you seems to grow..." )
		hitEnt:EmitSound( self.HitPlayerSound )
		hitEnt:SetModelScale( self.ShrinkSize, 0 )
		hitEnt:ScaleViewOffset( self.ShrinkSize )
		hitEnt:ScaleHull( self.ShrinkSize )
		hitEnt:ApplyMovementSpeed( )
		self.Owner.lastShrunkPlayer = hitEnt
		self.Owner.lastBadEvent = CurTime( )
		self.Owner.lastKill = CurTime( )
		local lShrinkSize = self.ShrinkSize + 0
		timer.Simple( self.UnShrinkTime, function( ) 
			//if ( !IsValid( hitEnt ) or hitEnt:Team( ) == TEAM_CRAB or hitEnt:getDarkRPVar( "IsGhost" ) or hitEnt:GetNiceModelScale( 2 ) ~= lShrinkSize ) then
			if ( !IsValid( hitEnt ) or hitEnt:Team( ) == TEAM_CRAB or hitEnt:IsGhost( ) or hitEnt:GetNiceModelScale( 2 ) ~= lShrinkSize ) then
				return
			end
			hitEnt:ChatPrint( "Things return to normal size." )
			hitEnt:SetModelScale( 1, 0 )
			hitEnt:ResetViewOffset( )
			hitEnt:ScaleHull( nil, true )
			hitEnt:ApplyMovementSpeed( )
			local traceRes = hitEnt:RangeAboveTrace( 72 )
			if ( traceRes.Fraction < 0.55 ) then
				hitEnt:ChatPrint( "There isn't enough room for you to unshrink! You're crushed to death." )
				hitEnt:Kill( )
			end
		end )
	end
end

function SWEP:DoSecondaryShrink( )
	local ply = self.Owner
	if ( !IsValid( ply ) or !ply:IsPlayer( ) ) then
		return
	end
	if ( ply:Team( ) == TEAM_CRAB or ply:GetNiceModelScale( 2 ) == self.ShrinkSize ) then
		DarkRP.notify( ply, 1, 4, "You're already as small as you can get!" )
		return
	end
	ply:EmitSound( self.HitPlayerSound )
	ply:ChatPrint( "Everything around you seems to grow..." )
	ply:SetModelScale( self.ShrinkSize, 0 )
	ply:ScaleViewOffset( self.ShrinkSize )
	ply:ScaleHull( self.ShrinkSize )
	ply:ApplyMovementSpeed( )
	ply.isShrunk = true;
	timer.Simple( self.UnShrinkTime, function( ) 
		//if ( !IsValid( ply ) or ply:getDarkRPVar( "IsGhost" ) ) then
		if ( !IsValid( ply ) or ply:IsGhost( ) ) then
			return
		end
		if ( ply:Team( ) == TEAM_CRAB or ply:GetNiceModelScale( 2 ) ~= self.ShrinkSize ) then
			return
		end
		ply:ChatPrint( "Things return to normal size." )
		ply:SetModelScale( 1, 0 )
		ply:ResetViewOffset( )
		ply:ScaleHull( nil, true )
		ply:ApplyMovementSpeed( )
		local traceRes = ply:RangeAboveTrace( 72 )
		if ( traceRes.Fraction < 0.55 ) then
			ply:ChatPrint( "There isn't enough room for you to unshrink! You're crushed to death." )
			ply:Kill( )
		end
	end )
end
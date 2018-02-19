if ( SERVER ) then
	AddCSLuaFile( )
end

SWEP.Author = "Noobonic Plague Developers"
SWEP.Instructions = "Left click to fry your enemy."
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "rpg"
SWEP.UseHands = true
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.PrintName = "Laser SMG"
SWEP.Slot = 1
SWEP.SlotPos = 9
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Category = "Noobonic Plague"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.ViewModel = "models/weapons/c_smg1.mdl"
SWEP.WorldModel = "models/weapons/w_smg1.mdl"

SWEP.MaxCoolant = 1000
SWEP.CoolantStages = {
	["Full"] = { max = ( 1 * SWEP.MaxCoolant ), min = ( 0.8 * SWEP.MaxCoolant ) },
	["Semi-Full"] = { max = ( 0.8 * SWEP.MaxCoolant ), min = ( 0.6 * SWEP.MaxCoolant ) },
	["Halfway Depleted"] = { max = ( 0.6 * SWEP.MaxCoolant ), min = ( 0.3 * SWEP.MaxCoolant ) },
	["Critical"] = { max = ( 0.3 * SWEP.MaxCoolant ), min = ( 0.1 * SWEP.MaxCoolant ) }
}

SWEP.WepIconBounceRate = 6
SWEP.WepIconBounceOffset = 4

function SWEP:Initialize()
	self:SetHoldType( "ar2" )
	if not ( SERVER ) then return end
	self:SetCoolantStage( "Full" )
	self.coolantRemaining = self.MaxCoolant
end

function SWEP:SetupDataTables( )
	self:NetworkVar( "Bool", 0, "IsFiring" )
	self:NetworkVar( "String", 0, "CoolantStage" )
end

function SWEP:Deploy()
	return true
end

function SWEP:OnRemove( )
	if ( self.laserLoopPatch ) then
		self.laserLoopPatch:Stop( )
		self.laserLoopPatch = nil
	end
end

function SWEP:Holster( )
	if ( self.laserLoopPatch ) then
		self.laserLoopPatch:Stop( )
		self.laserLoopPatch = nil
	end
	return true
end

function SWEP:CheckStages( )
	if ( ( self.coolantRemaining <= self.CoolantStages["Full"].max and self.coolantRemaining > self.CoolantStages["Full"].min ) and self:GetCoolantStage( ) ~= "Full" ) then
		self:SetCoolantStage( "Full" )
	elseif ( ( self.coolantRemaining <= self.CoolantStages["Semi-Full"].max and self.coolantRemaining > self.CoolantStages["Semi-Full"].min ) and self:GetCoolantStage( ) ~= "Semi-Full" ) then
		self:SetCoolantStage( "Semi-Full" )
	elseif ( ( self.coolantRemaining <= self.CoolantStages["Halfway Depleted"].max and self.coolantRemaining > self.CoolantStages["Halfway Depleted"].min ) and self:GetCoolantStage( ) ~= "Halfway Depleted" ) then
		self:SetCoolantStage( "Halfway Depleted" )
	elseif ( ( self.coolantRemaining <= self.CoolantStages["Critical"].max and self.coolantRemaining > self.CoolantStages["Critical"].min ) and self:GetCoolantStage( ) ~= "Critical" ) then
		self:SetCoolantStage( "Critical" )
	elseif ( self.coolantRemaining <= self.CoolantStages["Critical"].min ) then
		self:SetCoolantStage( "Empty" )
	end
end

function SWEP:Think( )
	if not ( SERVER ) then return end
	if ( self.Owner:KeyDown( IN_ATTACK ) and self.coolantRemaining > 0 ) then
		self:SetIsFiring( true )
		self.coolantRemaining = math.Clamp( self.coolantRemaining - 1, 0, 1000 )
		self:CheckStages( )
		if ( self.Owner:GetEyeTrace( ).Entity:IsPlayer( ) ) then
			if not ( self.Owner.equippedRiotShield ) then
				if ( self.Owner:Team( ) == TEAM_CRAB or self.Owner:Team( ) == TEAM_ZOMBIE ) then
					self.Owner:GetEyeTrace( ).Entity:TakeDamage(self.Owner:GetEyeTrace( ).Entity:GetMaxHealth( ) * 0.035, self.Owner, self )
				else
					self.Owner:GetEyeTrace( ).Entity:TakeDamage(self.Owner:GetEyeTrace( ).Entity:GetMaxHealth( ) * 0.005, self.Owner, self )
				end
			end
		elseif ( self.Owner:GetEyeTrace( ).Entity:GetClass( ) == "prop_physics" ) then
			self.Owner:GetEyeTrace( ).Entity:TakeDamage( 0.25, self.Owner, self )
		end
		if not ( self.laserLoopPatch ) then
			self.laserLoopPatch = CreateSound( self.Owner, "ambient/energy/electric_loop.wav" )
			self.laserLoopPatch:Play( )
		end
	else
		self:SetIsFiring( false )
		if ( self.laserLoopPatch ) then
			self.laserLoopPatch:Stop( )
			self.laserLoopPatch = nil
		end
		if not ( self.Owner:KeyDown( IN_ATTACK ) ) then
			self.coolantRemaining = math.Clamp( self.coolantRemaining + 1, 0, 1000 )
			self:CheckStages( )
		end
	end
end

if ( CLIENT ) then

	SWEP.LaserMaterial = Material( "cable/redlaser" )
	surface.CreateFont( "LaserSMG_StatFontBold", {
		font = "Tempus Sans ITC",
		size = ScreenScale( 9 ),
		weight = 600
	} )
	surface.CreateFont( "LaserSMG_StatFont", {
		font = "Tempus Sans ITC",
		size = ScreenScale( 12 ),
		weight = 600
	} )
	function SWEP:CreateSparks( eyeTrace )
		local rndChance = math.random( 1, 1000 )
		if not ( rndChance > 850 ) then return end
		local traceEnt = eyeTrace.Entity
		local effectType = "cball_explode"
		if ( IsValid( traceEnt ) and traceEnt:IsPlayer( ) or traceEnt:IsNPC( ) ) then
			effectType = "bloodimpact"
		end
		local effectData = EffectData()
		effectData:SetOrigin( eyeTrace.HitPos )
		effectData:SetStart( eyeTrace.HitPos )
		util.Effect( effectType, effectData )	
	end
	
	function SWEP:PreDrawViewModel( )
		Material( "models/weapons/v_smg1/v_smg1_sheet" ):SetVector( "$color2", Vector( 1, 0.1, 0.1 ) )
	end

	function SWEP:PostDrawViewModel( )
		Material( "models/weapons/v_smg1/v_smg1_sheet" ):SetVector( "$color2", Vector( 1, 1, 1 ) )
	end
	
	function SWEP:ViewModelDrawn( vm )
		if ( self:GetIsFiring( ) ) then
			local boneID = vm:LookupBone( "ValveBiped.base" )
			if ( boneID ) then
				local laserPos, laserAng = vm:GetBonePosition( boneID )
				local startVector = laserPos + ( laserAng:Right( ) * -0.5 ) + ( laserAng:Up( ) * 14 ) + ( laserAng:Forward( ) * -0.5 )
				local endVector = self.Owner:GetEyeTrace( ).HitPos
				render.SetMaterial( self.LaserMaterial )
				render.DrawBeam( startVector, endVector, 5, 1, 1 + ( math.sin( CurTime( ) * 2 ) ), Color( 255, 45, 45, 255 ) )
			end
			self:CreateSparks( self.Owner:GetEyeTrace( ) )
		end
	end
	
	function SWEP:DrawWorldModel( )
		render.SetColorModulation( 1, 0.1, 0.1 )
		self:DrawModel( )
		render.SetColorModulation( 1, 1, 1 )
		if ( self:GetIsFiring( ) ) then
			local boneID = self.Owner:LookupBone( "ValveBiped.Bip01_R_Hand" )
			if ( boneID ) then
				local laserPos, laserAng = self.Owner:GetBonePosition( boneID )
				local startVector = laserPos + ( laserAng:Forward( ) * 17 ) + ( laserAng:Up( ) * -8 ) + ( laserAng:Right( ) * 1.5 )
				local endVector = self.Owner:GetEyeTrace( ).HitPos
				render.SetMaterial( self.LaserMaterial )
				render.DrawBeam( startVector, endVector, 5, 1, 1 + ( math.sin( CurTime( ) * 2 ) ), Color( 255, 45, 45, 255 ) )
			end
			self:CreateSparks( self.Owner:GetEyeTrace( ) )
		end
	end

	function SWEP:DrawHUD( )
		draw.RoundedBox( 4, ScrW( ) * 0.85, ScrH( ) * 0.93, ScrW( ) * 0.125, ScrH( ) * 0.06, Color( 25, 25, 25, 255 ) )
		draw.RoundedBox( 4, ScrW( ) * 0.85, ScrH( ) * 0.93, ScrW( ) * 0.125, ScrH( ) * 0.025, Color( 45, 45, 45, 255 ) )
		draw.SimpleText( "Coolant Status", "LaserSMG_StatFontBold", ScrW( ) * 0.915, ScrH( ) * 0.93, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( self:GetCoolantStage( ), "LaserSMG_StatFont", ScrW( ) * 0.915, ScrH( ) * 0.96, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
		--local barWidth = math.Clamp( ( ScrW( ) * 0.2 ) * ( self:GetCoolant( ) / 50 ), 5, ScrW( ) * 0.2 )
		--draw.RoundedBox( 4, ScrW( ) * 0.795, ScrH( ) * 0.96, barWidth, ScrH( ) * 0.03, Color( 52, 152, 219, 255 ) )
	end

	surface.CreateFont( "N00BRP_LaserSMGIcon", { font = "HalfLife2", size = ScreenScale( 64 ), weight = 750, antialiasing = true, blursize = 0 } )
	surface.CreateFont( "N00BRP_LaserSMGBlur", { font = "HalfLife2", size = ScreenScale( 64 ), weight = 750, antialiasing = true, blursize = 4 } )
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		local iconPos = { x = x + wide / 2, y = y }
		local txtBounce = math.abs( math.sin( CurTime( ) * self.WepIconBounceRate ) ) * self.WepIconBounceOffset
		for i = 1, 5 do
			draw.SimpleText( "a", "N00BRP_LaserSMGBlur", iconPos.x, iconPos.y + txtBounce, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER )
		end
		draw.SimpleText( "a", "N00BRP_LaserSMGIcon", iconPos.x, iconPos.y + txtBounce, Color( 255, 45, 45, 255 ), TEXT_ALIGN_CENTER )
	end
end
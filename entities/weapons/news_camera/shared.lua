SWEP.PrintName = "News Camera"
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Author = "Sinavestos"
SWEP.Instructions = "Equip to use"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "rpg"

SWEP.ViewModel = Model( "models/dav0r/camera.mdl" )
SWEP.WorldModel = ""

SWEP.Spawnable = false
SWEP.AdminSpawnable = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.FrameVisible = false
SWEP.OnceReload = false

if ( CLIENT ) then

	local rtTexture = surface.GetTextureID( "pp/rt" )
	local rtSize = {}
	local drawTex = false

	function DrawRTTexture()

		if not drawTex then return end

		rtSize.x = 25
		rtSize.y = 25
		rtSize.w = ScrW( ) * 0.25
		rtSize.h = ScrH( ) * 0.25
		
		rtTexture = surface.GetTextureID( "pp/rt" )
		surface.SetTexture( rtTexture )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( rtSize.x , rtSize.y, rtSize.w, rtSize.h ) 
		
		surface.SetDrawColor( 0, 0, 0, 220 )
		surface.DrawOutlinedRect( rtSize.x-1, rtSize.y-1, rtSize.w+2, rtSize.h+2 )

	end

	function SWEP:GetViewModelPosition( pos, ang )
	 
		pos = pos + ( ang:Right() * 8 )
	 
		return pos, ang
	 
	end
end

function SWEP:Initialize()
	self:SetHoldType("rpg")
	if CLIENT then drawTex = true end
end

function SWEP:Deploy()
	if SERVER then self:TurnOnCamera() end
	if CLIENT then
		drawTex = true
		hook.Add( "HUDPaint", "N00BRP_DrawRTTexture", DrawRTTexture )
	end
	return true
end

function SWEP:Holster()
	if SERVER then self:TurnOffCamera() end
	if CLIENT then
		drawTex = false
		hook.Remove( "HUDPaint", "N00BRP_DrawRTTexture" )
	end
	return true
end

function SWEP:OnRemove()
	if SERVER then self:TurnOffCamera() end
	if CLIENT then
		drawTex = false
		hook.Remove( "HUDPaint", "N00BRP_DrawRTTexture" )
	end
end

/*---------------------------------------------------------
Name: SWEP:Initialize()
Desc: Called when the weapon is first loaded
---------------------------------------------------------*/

local running = false

function UpdateRenderTarget( ent )

	if ( !ent || !ent:IsValid( ) ) then 
		SafeRemoveEntity( RenderTargetCamera ) 
		SafeRemoveEntity( RenderThing )
		return 
	end

	local angle = ent:EyeAngles()
	pos = ent:GetShootPos() + (angle:Forward() * 40)
	if ( !RenderTargetCamera || !RenderTargetCamera:IsValid() ) then

		RenderTargetCamera = ents.Create( "point_camera" )
		RenderTargetCamera:SetKeyValue( "GlobalOverride", 1 )
		RenderTargetCamera:SetPos( pos )
		RenderTargetCamera:SetAngles( angle )
		RenderTargetCamera:Spawn( )
		RenderTargetCamera:Activate( )
		RenderTargetCamera:Fire( "SetOn", "", 0.0 )
		RenderThing = ents.Create( "camera_node" )
		RenderThing:SetPos(pos)
		RenderThing:SetAngles(angle)
		RenderThing:Spawn( )
		RenderThing:Activate( )
		RenderTargetCamera:SetParent(RenderThing)
	end
	
	RenderThing:GetPhysicsObject( ):SetPos( pos )
	RenderThing:GetPhysicsObject( ):SetVelocity( ent:GetVelocity( ) )
	RenderThing:GetPhysicsObject( ):SetAngles( angle )

	RenderTargetCameraProp = ent
	
end

function SWEP:TurnOnCamera( )
	self:SetHoldType( "rpg" )
	if ( SERVER ) then
		self.Owner:DrawViewModel(true)
		self.Owner:DrawWorldModel(false)
		self.Owner.cameraent = ents.Create( "ent_camera" )
		self.Owner.cameraent:SetOwner(self.Owner) 
		self.Owner.cameraent:SetParent(self.Owner)
		self.Owner.cameraent:SetPos(self.Owner:GetPos())
		self.Owner.cameraent:Spawn( )
	end
	running = true
	UpdateRenderTarget( self.Owner )
end

function SWEP:TurnOffCamera()
	running = false
	UpdateRenderTarget( nil )
	if self.Owner and self.Owner.cameraent and IsValid( self.Owner.cameraent ) then SafeRemoveEntity( self.Owner.cameraent ) end
end

function SWEP:Think()
	if running then UpdateRenderTarget( self.Owner ) end
end
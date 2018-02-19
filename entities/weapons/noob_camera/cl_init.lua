include( "shared.lua" )
include( "camerafilters.lua" )
local whitelistElements = { "CHudWeaponSelection", "CHudChat", "CHudMenu" }
local currentScreenSpace = "None"
SWEP.WasDeployed = false

local function CameraShouldDrawLocalPlayer( ply )
	if ( IsValid( ply ) ) then
		local wep = ply:GetActiveWeapon( )
		if ( IsValid( wep ) and wep:GetClass( ) == "noob_camera" and wep.ViewingSelf ) then
			return true
		end
	end
	return false
end

local function CameraRenderScreenspaceEffects( )
	if ( !currentScreenSpace or currentScreenSpace == "None" ) then return end
	if ( camFilterScreenSpaceEffects[currentScreenSpace] ) then
		camFilterScreenSpaceEffects[currentScreenSpace]( )
	end
end

local function CameraShouldDrawHUD( name )
	for index, element in ipairs ( whitelistElements ) do
		if ( name == element ) then
			return true
		end
	end
	if ( IsValid( LocalPlayer( ):GetActiveWeapon( ) ) and LocalPlayer( ):GetActiveWeapon( ):GetClass( ) ~= "noob_camera" ) then
		return
	end
    return false
end

local function PlayerSwitchToCamera( ply, oldWep, newWep )
	if ( LocalPlayer( ) == ply and newWep:GetClass( ) == "noob_camera" ) then
		hook.Add( "HUDShouldDraw", "N00BRP_CameraShouldDrawHUD_HUDShouldDraw", CameraShouldDrawHUD )
		hook.Add( "RenderScreenspaceEffects", "N00BRP_CameraRenderScreenspaceEffects_RenderScreenspaceEffects", CameraRenderScreenspaceEffects )
		newWep:CreateCSWorldModel( )
		newWep.WasDeployed = true
	end
end

function SWEP:CalcView( ply, pos, ang, fov )
	if ( IsValid( ply ) and IsValid( ply:GetActiveWeapon( ) ) and ply:GetActiveWeapon( ).ViewingSelf ) then
		local handBone = ply:LookupBone( "ValveBiped.Bip01_R_Hand" )
		local newPos = pos + ( ang:Forward( ) * 35 )
		local newAng = ang
		if ( handBone ) then
			local pos, ang = ply:GetBonePosition( handBone )
			newPos = pos + ( ang:Forward( ) * 5 ) + ( ang:Right( ) * 5 )
			newAng = ang
		end
		newAng:RotateAroundAxis( newAng:Right( ), 180 )
		return newPos, newAng, fov
	else
		return pos, ang, fov
	end
end

function SWEP:Deploy( )
	timer.Simple( 0.5, function( )
		if ( !IsValid( self ) or !IsValid( self.Owner ) ) then return end
		if ( self.WasDeployed ) then return end
		hook.Add( "PlayerSwitchWeapon", "N00BRP_PlayerSwitchToCamera_PlayerSwitchWeapon", PlayerSwitchToCamera )
		hook.Add( "HUDShouldDraw", "N00BRP_CameraShouldDrawHUD_HUDShouldDraw", CameraShouldDrawHUD )
		hook.Add( "RenderScreenspaceEffects", "N00BRP_CameraRenderScreenspaceEffects_RenderScreenspaceEffects", CameraRenderScreenspaceEffects )
		self:CreateCSWorldModel( )
		self.WasDeployed = true
	end )
end

function SWEP:Initialize( )
	hook.Add( "PlayerSwitchWeapon", "N00BRP_PlayerSwitchToCamera_PlayerSwitchWeapon", PlayerSwitchToCamera )
	hook.Add( "HUDShouldDraw", "N00BRP_CameraShouldDrawHUD_HUDShouldDraw", CameraShouldDrawHUD )
	hook.Add( "RenderScreenspaceEffects", "N00BRP_CameraRenderScreenspaceEffects_RenderScreenspaceEffects", CameraRenderScreenspaceEffects )
	self:CreateCSWorldModel( )
	self.WasDeployed = true
end

function SWEP:Reload( )
	self.nextScreenSpaceSwitch = self.nextScreenSpaceSwitch or CurTime( )
	if ( self.nextScreenSpaceSwitch < CurTime( ) ) then
		currentScreenSpace = table.GetKeys( camFilterScreenSpaceEffects )[math.random( #table.GetKeys( camFilterScreenSpaceEffects ) )]
		self.nextScreenSpaceSwitch = CurTime( ) + 1
	end
end

function SWEP:Holster( )
	self:RemoveCSWorldModel( )
	hook.Remove( "HUDShouldDraw", "N00BRP_CameraShouldDrawHUD_HUDShouldDraw" )
	hook.Remove( "RenderScreenspaceEffects", "N00BRP_CameraRenderScreenspaceEffects_RenderScreenspaceEffects" )
	self.WasDeployed = false
	currentScreenSpace = "None"
end
	
function SWEP:OnRemove( )
	self:RemoveCSWorldModel( )
	hook.Remove( "HUDShouldDraw", "N00BRP_CameraShouldDrawHUD_HUDShouldDraw" )
	hook.Remove( "RenderScreenspaceEffects", "N00BRP_CameraRenderScreenspaceEffects_RenderScreenspaceEffects" )
	hook.Remove( "PlayerSwitchWeapon", "N00BRP_PlayerSwitchToCamera_PlayerSwitchWeapon" )
	self.WasDeployed = false
	currentScreenSpace = "None"
end
	
function SWEP:CreateCSWorldModel( )
	if ( IsValid( self.csWorldModel ) ) then
		SafeRemoveEntity( self.csWorldModel )
	end
	if not ( IsValid( self.Owner ) ) then return end
	self.csWorldModel = ClientsideModel( "models/maxofs2d/camera.mdl", RENDERMODE_TRANSCOLOR )
	self.csWorldModel:SetNoDraw( true )
end

function SWEP:RemoveCSWorldModel( )
	if ( IsValid( self.csWorldModel ) ) then
		SafeRemoveEntity( self.csWorldModel )
	end
end
	
function SWEP:SecondaryAttack( )
	if ( self.NextToggleView < CurTime( ) ) then
		if ( self.ViewingSelf ) then
			self.ViewingSelf = false
			self:RemoveCSWorldModel( )
			hook.Remove( "ShouldDrawLocalPlayer", "N00BRP_CameraShouldDrawLocalPlayer_ShouldDrawLocalPlayer" )
		else
			self.ViewingSelf = true
			self:CreateCSWorldModel( )
			hook.Add( "ShouldDrawLocalPlayer", "N00BRP_CameraShouldDrawLocalPlayer_ShouldDrawLocalPlayer", CameraShouldDrawLocalPlayer )
		end
		self.NextToggleView = CurTime( ) + 2
	end
end

function SWEP:PrimaryAttack( )
	if ( self.NextPicture < CurTime( ) ) then
		self.Owner.PictureData = { }
		local picInfo = {
			format = "jpeg",
			w = ScrW( ),
			h = ScrH( ),
			quality = 50,
			x = 0,
			y = 0
		}
		local datSplitAmt = 20000
		local picData = util.Base64Encode( render.Capture( picInfo ) )
		local datLength = string.len( picData )
		local datFrags = math.ceil( datLength / datSplitAmt )
		for i = 1, datFrags do
			local splitStart = ( i * datSplitAmt ) - datSplitAmt + 1
			local splitEnd = ( i * datSplitAmt )
			if ( datLength < splitEnd ) then
				splitEnd = datLength
			end
			LocalPlayer( ).PictureData[i] = string.sub( picData, splitStart, splitEnd )
		end
		self.Owner:EmitSound( "npc/scanner/scanner_photo1.wav", 100, math.random( 80, 120 ) )
		net.Start( "N00BRP_Camera_NET" )
			net.WriteInt( ENUM_CAM_BEGINTRANSFER, 8 )
			net.WriteUInt( datFrags, 32 )
		net.SendToServer( )
		for index, data in ipairs ( LocalPlayer( ).PictureData ) do
			local compressedData = util.Compress( data )
			local datLength = string.len( compressedData )
			net.Start( "N00BRP_Camera_NET" )
				net.WriteInt( ENUM_CAM_SENDPART, 8 )
				net.WriteUInt( datLength, 32 )
				net.WriteData( compressedData, datLength )
			net.SendToServer( )
		end
		self.NextPicture = CurTime( ) + 15
	end
end

function SWEP:DrawWorldModel( )
	if not ( IsValid( self.Owner ) ) then
		self:DrawModel( )
		SafeRemoveEntity( self.csWorldModel )
		return
	end
	if not ( IsValid( self.csWorldModel ) ) then
		self:DrawModel( )
		self:CreateCSWorldModel( )
		return
	end
	if ( LocalPlayer( ) == self.Owner ) then
		self.csWorldModel:SetNoDraw( true )
		return
	end
	local posOffset = Vector( 0, 0, 0 )
	local angOffset = Angle( 0, 0, 0 )
	local handBone = self.Owner:LookupBone( "ValveBiped.Bip01_R_Hand" )
	if ( handBone ) then
		posOffset, angOffset = self.Owner:GetBonePosition( handBone )
	else
		self:DrawModel( )
		self.csWorldModel:SetNoDraw( true )
		return
	end
	if not ( self:GetHoldType( ) == "pistol" ) then
		self:DrawModel( )
		self.csWorldModel:SetNoDraw( true )
		return
	end
	posOffset = posOffset + ( angOffset:Right( ) * 4 ) + ( angOffset:Forward( ) * 2 )
	angOffset:RotateAroundAxis( angOffset:Up( ), 180 )
	angOffset:RotateAroundAxis( angOffset:Forward( ), 180 )
	self.csWorldModel:SetNoDraw( false )
	self.csWorldModel:SetAngles( angOffset )
	self.csWorldModel:SetPos( posOffset )
end
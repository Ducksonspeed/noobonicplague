local plyMeta = FindMetaTable( "Player" )
surface.CreateFont( "N00BRP_3DIndicator_SmallText", {
	font = "Arial",
	size = 48,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "N00BRP_3DIndicator_TinyBoldText", {
	font = "Arial",
	size = 24,
	weight = 750,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "N00BRP_2DIndicator_TinyBoldText", {
	font = "Arial",
	size = ScreenScale( 14 ),
	weight = 750,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "N00BRP_2DIndicator_ReallyTinyBoldText", {
	font = "Arial",
	size = ScreenScale( 8 ),
	weight = 750,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "N00BRP_2DIndicator_SegioTinyBoldText", {
	font = "Segio Light",
	size = ScreenScale( 14 ),
	weight = 700
} )

surface.CreateFont( "N00BRP_2DIndicator_SegioReallyTinyBoldText", {
	font = "Segio Bold",
	size = ScreenScale( 12 ),
	weight = 800
} )

surface.CreateFont( "N00BRP_2DIndicator_LobsterMiniText", {
	font = "Lobster",
	size = 24,
	weight = 400
} )

NOOBRP = NOOBRP or { }
NOOBRP.Notifies = NOOBRP.Notifies or { }
NOOBRP.CenterMessages = NOOBRP.CenterMessages or { }
local fallbackIcon = Material( "icon16/heart.png" )
local materialCache = { }

local function DrawNotifications( )
	local notifies = NOOBRP.Notifies or { }
	if ( #notifies > 0 ) then
		for index, notifyTbl in ipairs ( notifies ) do
			if ( notifyTbl.expireTime < CurTime( ) ) then
				table.remove( notifies, index )
				continue
			end
			local textColor = notifyTbl.textCol or Color( 255, 255, 255, 255 )
			local panelColor = notifyTbl.panelColor or Color( 45, 45, 45, 255 )
			local textFont = notifyTbl.font or "N00BRP_2DIndicator_SegioTinyBoldText"
			local notifyIcon = notifyTbl.iconPath
			if ( notifyIcon and !materialCache[notifyIcon] ) then materialCache[notifyIcon] = Material( notifyIcon )
			elseif ( notifyIcon and materialCache[notifyIcon] ) then notifyIcon = materialCache[notifyIcon] end
			notifyIcon = notifyIcon or fallbackIcon
			if not ( type( notifyIcon ) == "IMaterial" ) then notifyIcon = fallbackIcon end
			if ( notifyTbl.isRainbow ) then panelColor = util.RainbowStrobe( 2 ) end
			local notifyAlpha = ( ( notifyTbl.expireTime - CurTime( ) ) / notifyTbl.notifyLength ) * 255
			if ( notifyAlpha < 20 ) then
				table.remove( notifies, index )
				continue
			end
			textColor = Color( textColor.r, textColor.g, textColor.b, notifyAlpha )
			panelColor = Color( panelColor.r, panelColor.b, panelColor.g, notifyAlpha )
			local offsetY = ( ScrH( ) * 0.85 ) - ( ( ScrH( ) * 0.0425 ) * index )
			surface.SetFont( textFont )
			local notifyXPos = ( ScrW( ) - ( ScrW( ) * 0.175 ) )
			local txtW, txtH = surface.GetTextSize( notifyTbl.message )
			local heightMulti = 0.5
			if ( txtH >= 30 ) then heightMulti = 0.3 end
			if ( txtH < 14 ) then heightMulti = 1.5 end
			local notifyWide = txtW + 36
			notifyWide = math.Clamp( notifyWide, ScrW( ) * 0.15, ScrW( ) * 0.5 )
			if ( notifyWide > ScrW( ) * 0.15 ) then
				notifyXPos = notifyXPos - ( ( notifyWide - ScrW( ) * 0.15 ) )
			end
			local notifyTall = ScrH( ) * 0.04
			draw.RoundedBox( 0, notifyXPos, offsetY - ( ( notifyTall * 0.5 ) - 8 ), notifyWide, notifyTall, panelColor )
			draw.BlurredRect( notifyXPos, offsetY - ( ( notifyTall * 0.5 ) - 8 ), notifyWide, notifyTall, 5, 3, Color( 255, 255, 255, notifyAlpha ) )
			draw.TexturedRect( notifyXPos + 4, offsetY, 16, 16, notifyIcon, Color( 255, 255, 255, notifyAlpha ) )
			draw.SimpleText( notifyTbl.message, textFont, notifyXPos + 24, ( offsetY - ( notifyTall * 0.5 ) ) + ( txtH * heightMulti ), textColor, TEXT_ALIGN_LEFT )
		end
	end
end

local function DrawCenterScreenMessages( )
	local screenMessages = NOOBRP.CenterMessages or { }
	if ( #screenMessages > 0 ) then
		for index, mesTbl in ipairs ( screenMessages ) do
			if ( mesTbl.expireTime < CurTime( ) ) then
				table.remove( screenMessages, index )
				continue
			end
			local textColor = mesTbl.col or Color( 255, 255, 255, 255 )
			local textFont = mesTbl.font or "N00BRP_2DIndicator_SegioTinyBoldText"
			if ( mesTbl.isRainbow ) then textColor = util.RainbowStrobe( 2 ) end
			surface.SetFont( textFont )
			local txtW, txtH = surface.GetTextSize( mesTbl.message )
			local offsetY = ( ( ScrH( ) * 0.2 ) + ( ( 26 * index ) ) ) - txtH
			local textAlpha = ( ( mesTbl.expireTime - CurTime( ) ) / mesTbl.mesLength ) * 255
			if ( textAlpha < 20 ) then
				table.remove( screenMessages, index )
				continue
			end
			textColor = Color( textColor.r, textColor.g, textColor.b, textAlpha )
			draw.SimpleText( mesTbl.message, textFont, ScrW( ) * 0.5, offsetY, textColor, TEXT_ALIGN_CENTER )
		end
	end
end

local matArrow = Material( "widgets/arrow.png", "nocull alphatest smooth mips" )
local function DrawThreeDimensionalIndicators( bDrawingDepth, bDrawingSkybox )
	--if true then return false end
	if not ( IsValid( LocalPlayer( ) ) ) then return end
	local hitAng = LocalPlayer( ):GetAngles( )
	local newAng = Angle( 0, hitAng.y - 90, 90 )
	if ( !LocalPlayer( ).getDarkRPVar or !LocalPlayer( ):getDarkRPVar( "IsInitialized" ) ) then return end
	if ( LocalPlayer( ):IsWearingHat( "plant_hat" ) ) then
		for index, ent in ipairs ( ents.FindByClass( "ent_herb" ) ) do
			if not ( LocalPlayer( ):IsLineOfSightClear( ent:GetPos( ) + Vector( 0, 0, 128 ) ) ) then continue end
			local heightSin = math.abs( math.sin( CurTime( ) ) * 60 )
			local colorSin = math.abs( math.sin( CurTime( ) ) * 256 )
			render.SetMaterial( matArrow )
			render.DrawBeam( ent:GetPos( ) + Vector( 0, 0, 200 ), ent:GetPos( ) + Vector( 0, 0, 64 + heightSin ), 15, 1, 0, Color( colorSin, 175, 45 ) )
		end
	end
	npcFloatingTitleData = npcFloatingTitleData or { }
	for entIndex, title in pairs ( npcFloatingTitleData ) do
		local npcEnt = Entity( entIndex )
		if not ( IsValid( npcEnt ) ) then continue end
		if not ( LocalPlayer( ):IsLineOfSightClear( npcEnt:GetPos( ) + Vector( 0, 0, 128 ) ) ) then continue end
		if ( ( LocalPlayer( ):GetPos( ):DistToSqr( npcEnt:GetPos( ) ) * 0.1 )  > 10000 ) then continue end
		local npcAngle = npcEnt:GetAngles( )
		npcAngle:RotateAroundAxis( npcAngle:Forward( ), 90 )
		npcAngle:RotateAroundAxis( npcAngle:Right( ), -90 )
		cam.Start3D2D( npcEnt:GetPos( ) + Vector( 0, 0, 80 ), npcAngle, 0.1 )
			draw.SimpleText( title, "N00BRP_3DIndicator_SmallText", 0, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		cam.End3D2D( )
	end
	/*for index, ply in ipairs ( player.GetAll( ) ) do
		if ( ply:GetObserverMode( ) ~= OBS_MODE_NONE ) then continue end
		if not ( ply:Alive( ) ) then return end
		if not ( IsValid( ply ) ) then continue end
		if ( !ply.getDarkRPVar or !ply:getDarkRPVar( "IsInitialized" ) ) then continue end
		local entPos = ply:GetPos( )
		local attachmentID = ply:LookupAttachment( "eyes" )
		if ( attachmentID and ply:GetAttachment( attachmentID ) ) then
			entPos = ply:GetAttachment( attachmentID ).Pos
		end
		if ( IsValid( ply ) and ply:getDarkRPVar( "IsMurderer" ) and !ply:getDarkRPVar( "IsGhost" ) ) then
			cam.Start3D2D( entPos + Vector( 0, 0, 30 ), newAng, 0.25 )
				draw.SimpleText( "MURDERER", "N00BRP_3DIndicator_SmallText", 0, 0, Color( 170, 45, 45, 255 ), TEXT_ALIGN_CENTER )
			cam.End3D2D( )
		else
			LocalPlayer( ).revengeTable = LocalPlayer( ).revengeTable or { }
			if ( LocalPlayer( ).revengeTable and !LocalPlayer( ):isCP( ) ) then
				for uniqueid, amt in pairs ( LocalPlayer( ).revengeTable ) do
					if ( tonumber( ply:SafeUniqueID( ) ) == tonumber( uniqueid ) and !ply:IsGhost( ) and tonumber( LocalPlayer( ):SafeUniqueID( ) ) ~= tonumber( uniqueid ) ) then
						cam.Start3D2D( entPos + Vector( 0, 0, 28 ), newAng, 0.2 )
							draw.SimpleText( "REVENGE", "N00BRP_3DIndicator_SmallText", 0, 0, Color( 230, 126, 34, 255 ), TEXT_ALIGN_CENTER )
						cam.End3D2D( )
					end
				end
			end
		end
		if ( ply:getDarkRPVar( "wanted" ) and !ply:getDarkRPVar( "IsGhost" ) ) then
			local pulsingColor = math.GetPulsingNumber( 100, 2, 155, true )
			local pulsingSize = math.GetPulsingNumber( 0.05, 1.5, 0.15, true )
			cam.Start3D2D( entPos + Vector( 0, 0, 28 ), newAng, pulsingSize )
				draw.SimpleTextOutlined( "WANTED", "N00BRP_3DIndicator_SmallText", 0, 0, Color( 45, 45, 45, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 255, pulsingColor, pulsingColor, 255 ) )
			cam.End3D2D( )
		end
		if ( ply:getDarkRPVar( "IsPacifist" ) and !ply:getDarkRPVar( "IsGhost" ) ) then
			cam.Start3D2D( entPos + Vector( 0, 0, 16.5 ), newAng, 0.2 )
				draw.SimpleText( "PACIFIST", "N00BRP_3DIndicator_TinyBoldText", 0, -4, Color( 125, 125, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			cam.End3D2D( )
		end
	end*/
	if ( IsValid( LocalPlayer( ):GetEyeTrace( ).Entity ) ) then
		local hoveringEnt = LocalPlayer( ):GetEyeTrace( ).Entity
		if ( hoveringEnt:GetClass( ) == "prop_ragdoll" ) then
			if ( IsValid( hoveringEnt:GetOwner( ) ) and hoveringEnt:GetOwner( ):IsPlayer( ) and hoveringEnt:GetOwner( ) ~= LocalPlayer( ) ) then
				local entPos = hoveringEnt:GetPos( )
				local entOwner = hoveringEnt:GetOwner( )
				local hitAng = LocalPlayer( ):GetAngles( )
				local newAng = Angle( 0, hitAng.y - 90, 90 )
				cam.Start3D2D( entPos + Vector( 0, 0, 24 ), newAng, 0.1 )
					draw.SimpleText( entOwner:Name( ), "N00BRP_3DIndicator_TinyBoldText", 0, 0, team.GetColor( entOwner:Team( ) ), TEXT_ALIGN_CENTER )
					draw.SimpleText( "Double Tap E To Start CPR", "N00BRP_3DIndicator_TinyBoldText", 0, 18, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
					draw.SimpleText( "Hold E To Drag", "N00BRP_3DIndicator_TinyBoldText", 0, 36, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
				cam.End3D2D( )
			end
		elseif ( hoveringEnt:IsPlayer( ) and hoveringEnt:GetObserverMode( ) == OBS_MODE_NONE ) then
			/*if ( !LocalPlayer( ):getDarkRPVar( "IsGhost" ) and hoveringEnt:getDarkRPVar( "IsGhost" ) ) then return end
			local entPos = hoveringEnt:GetPos( )
			local attachmentID = hoveringEnt:LookupAttachment( "eyes" )
			if ( attachmentID ) then
				entPos = hoveringEnt:GetAttachment( attachmentID ).Pos
			end
			local hitAng = LocalPlayer( ):GetAngles( )
			local newAng = Angle( 0, hitAng.y + 270, 90 )
			cam.Start3D2D( entPos + Vector( 0, 0, 16 ), newAng, 0.15 )
				cam.IgnoreZ( true )
				if ( hoveringEnt:getDarkRPVar( "IsDisguised" ) ) then
					draw.SimpleText( hoveringEnt:Name( ), "N00BRP_3DIndicator_TinyBoldText", 0, 0, team.GetColor( hoveringEnt:getDarkRPVar( "IsDisguised" ) ), TEXT_ALIGN_CENTER )
					draw.SimpleText( team.GetName( hoveringEnt:getDarkRPVar( "IsDisguised" ) ), "N00BRP_3DIndicator_TinyBoldText", 0, 18, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
				else
					draw.SimpleText( hoveringEnt:Name( ), "N00BRP_3DIndicator_TinyBoldText", 0, 0, team.GetColor( hoveringEnt:Team( ) ), TEXT_ALIGN_CENTER )
					draw.SimpleText( team.GetName( hoveringEnt:Team( ) ), "N00BRP_3DIndicator_TinyBoldText", 0, 18, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
				end
				if ( hoveringEnt:getDarkRPVar( "Clan" ) ) then
					draw.SimpleText( "< " .. hoveringEnt:getDarkRPVar( "Clan" ) .. " >", "N00BRP_3DIndicator_TinyBoldText", 0, 36, Color( 142, 68, 173 ), TEXT_ALIGN_CENTER )
				end
				cam.IgnoreZ( false )
			cam.End3D2D( )*/
		end
	end
end
hook.Add( "PostDrawTranslucentRenderables", "N00BRP_Draw3DIndicators_PostDrawTranslucentRenderables", DrawThreeDimensionalIndicators )

function plyMeta:drawPlayerInfo( ) -- Override the standard DarkRP player info.
	return false
end

function plyMeta:drawWantedInfo( )
	return false
end

local arrowMaterial = Material( "icon16/arrow_up.png" )
local crossMaterial = Material( "icon16/cross.png" )
local drawingMap = false
local minimapDragButton = nil
local minimapShrinkButton = nil
local minimapGrowButton = nil
local mapX = 16
local mapY = 16
local mapWidth = 205
local mapHeight = 205
local mapMaxWidth = mapWidth * 1.25
local mapMaxHeight = mapHeight * 1.25
local mapMinWidth = mapWidth * 0.25
local mapMinHeight = mapHeight * 0.25

LocalPlayer( ).minimapEnabled = true

local function DrawMiniMap( )
	if not ( ValidPanel( minimapDragButton ) ) then
		minimapDragButton = vgui.Create( "DN00B_ColoredButton" )
		minimapDragButton:SetSize( 16, 16 )
		minimapDragButton:SetPos( mapX + mapWidth + 16, mapY + mapHeight )
		minimapDragButton:SetText( "" )
		minimapDragButton:SetButtonImage( "icon16/cursor.png", Color( 25, 25, 25 ), false )
		minimapDragButton.OnMousePressed = function( pnl, btn )
			timer.Create( "MinimapDragTimer", 0.05, 0, function( )
				if not ( ValidPanel( minimapDragButton) ) then
					timer.Destroy( "MinimapDragTimer" )
				end
				minimapDragButton:SetPos( gui.MouseX( ), gui.MouseY( ) )
				minimapShrinkButton:SetPos( gui.MouseX( ), gui.MouseY( ) - 24 )
				minimapGrowButton:SetPos( gui.MouseX( ), gui.MouseY( ) - 48 )
			end )
		end
		minimapDragButton.OnMouseReleased = function( pnl, btn )
			timer.Destroy( "MinimapDragTimer" )
		end
	elseif ( !ValidPanel( minimapShrinkButton ) ) then
		minimapShrinkButton = vgui.Create( "DN00B_ColoredButton" )
		minimapShrinkButton:SetSize( 16, 16 )
		minimapShrinkButton:SetPos( mapX + mapWidth + 2, mapY + mapHeight - 24 )
		minimapShrinkButton:SetText( "" )
		minimapShrinkButton:SetButtonImage( "icon16/zoom_out.png", Color( 25, 25, 25 ), false )
		minimapShrinkButton.OnMousePressed = function( pnl, btn )
			mapWidth = math.Clamp( mapWidth * 0.95, mapMinWidth, mapMaxWidth )
			mapHeight = math.Clamp( mapHeight * 0.95, mapMinHeight, mapMaxHeight )
			minimapDragButton:SetPos( mapX + mapWidth + 16, mapY + mapHeight - 24 )
			minimapShrinkButton:SetPos( mapX + mapWidth + 16, mapY + mapHeight - 48 )
			minimapGrowButton:SetPos( mapX + mapWidth + 16, mapY + mapHeight - 72 )
		end
	elseif ( !ValidPanel( minimapGrowButton ) ) then
		minimapGrowButton = vgui.Create( "DN00B_ColoredButton" )
		minimapGrowButton:SetSize( 16, 16 )
		minimapGrowButton:SetPos( mapX + mapWidth + 2, mapY + mapHeight - 48 )
		minimapGrowButton:SetText( "" )
		minimapGrowButton:SetButtonImage( "icon16/zoom_in.png", Color( 25, 25, 25 ), false )
		minimapGrowButton.OnMousePressed = function( pnl, btn )
			mapWidth = math.Clamp( mapWidth * 1.05, mapMinWidth, mapMaxHeight )
			mapHeight = math.Clamp( mapHeight * 1.05, mapMinHeight, mapMaxHeight )
			minimapDragButton:SetPos( mapX + mapWidth + 16, mapY + mapHeight - 24 )
			minimapShrinkButton:SetPos( mapX + mapWidth + 16, mapY + mapHeight - 48 )
			minimapGrowButton:SetPos( mapX + mapWidth + 16, mapY + mapHeight - 72 )
		end
	end
	if ( !tobool( GetConVarNumber( "noobrp_enableminimap" ) ) or LocalPlayer( ):IsGhost( ) ) then 
		if ( ValidPanel( minimapDragButton ) ) then
			minimapDragButton:SetVisible( false )
		end
		if ( ValidPanel( minimapShrinkButton ) ) then
			minimapShrinkButton:SetVisible( false )
		end
		if ( ValidPanel( minimapGrowButton ) ) then
			minimapGrowButton:SetVisible( false )
		end
		return 
	elseif ( tobool( GetConVarNumber( "noobrp_enableminimap" ) ) and !LocalPlayer( ):IsGhost( ) ) then
		if ( ValidPanel( minimapDragButton ) ) then
			minimapDragButton:SetVisible( true )
		end
		if ( ValidPanel( minimapShrinkButton ) ) then
			minimapShrinkButton:SetVisible( true )
		end
		if ( ValidPanel( minimapGrowButton ) ) then
			minimapGrowButton:SetVisible( true )
		end
	end
	if ( LocalPlayer( ):IsGhost( ) ) then return end
	if ( ValidPanel( minimapDragButton ) ) then
		local x, y = minimapDragButton:GetPos( )
		mapX = x - mapWidth
		mapY = y - mapHeight
	end
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawOutlinedRect( mapX, mapY, mapWidth + 1, mapHeight + 1 )
	drawingMap = true
	local traceRes = util.TraceLine( { start = LocalPlayer( ):GetPos( ), endpos = LocalPlayer( ):GetPos( ) + Vector( 0, 0, 16000 ), filter = function( ent ) return( !ent:IsVehicle( ) and !ent:IsPlayer( ) ) end } )
	local newZ = traceRes.HitPos.z - LocalPlayer( ):GetPos( ).z
	local miniMapCam = { }
	miniMapCam.angles = Angle( 90, 0, 0 )
	miniMapCam.origin = LocalPlayer( ):GetPos( ) + Vector( 0, 0, math.Clamp( newZ, 0, 300 ) )
	miniMapCam.x = mapX
	miniMapCam.y = mapY
	miniMapCam.w = mapWidth
	miniMapCam.h = mapHeight
	miniMapCam.drawhud = false
	miniMapCam.drawviewmodel = false
	render.RenderView( miniMapCam )
	drawingMap = false
	-- Crosshair
	draw.RoundedBox( 0, ScrW( ) * 0.4925, ScrH( ) * 0.5, 1, 1, Color( 255, 255, 255 ) )
	draw.RoundedBox( 0, ScrW( ) * 0.5075, ScrH( ) * 0.5, 1, 1, Color( 255, 255, 255 ) )
	draw.RoundedBox( 0, ScrW( ) * 0.5, ScrH( ) * 0.5, 1, 1, Color( 255, 255, 255 ) )
	draw.RoundedBox( 0, ScrW( ) * 0.5, ScrH( ) * 0.4925, 1, 1, Color( 255, 255, 255 ) )
	draw.RoundedBox( 0, ScrW( ) * 0.5, ScrH( ) * 0.5075, 1, 1, Color( 255, 255, 255 ) )
	LocalPlayer( ).currentWaypoints = LocalPlayer( ).currentWaypoints or { }
	for name, pos in pairs( LocalPlayer( ).currentWaypoints ) do
		local offset = LocalPlayer( ):GetPos() - pos
		offset:Rotate( Angle( 0, 180, 0 ) )
		local y = offset.x * ( 160 / ( ( 300 * 1.5 ) + ( offset.z * 1.5 ) ) )
		local x = offset.y * ( 160 / ( ( 300 * 1.5 ) + ( offset.z * 1.5 ) ) )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( crossMaterial )
		local mapDataX = { start = miniMapCam.x * 1, mid = ( miniMapCam.x + ( miniMapCam.w / 2 ) ), endpos = ( miniMapCam.x + miniMapCam.w ) - 16 }
		local mapDataY = { start = miniMapCam.y * 1, mid = ( miniMapCam.y + ( miniMapCam.h / 2 ) ), endpos = ( miniMapCam.y + miniMapCam.h ) - 16 }
		surface.DrawTexturedRect( math.Clamp( mapDataX.mid - x, mapDataX.start, mapDataX.endpos ), math.Clamp( mapDataY.mid - y, mapDataY.start, mapDataY.endpos ), 16, 16 )	
		draw.SimpleTextOutlined( name, "Default", math.Clamp( mapDataX.mid - x, mapDataX.start, mapDataX.endpos ), math.Clamp( ( mapDataY.mid - y ) - 10, mapDataY.start - 10, mapDataY.endpos - 10 ),  Color( 255, 255, 255, 255 ), 1, 0, 1, Color( 0, 0, 0, 255 ) )
	end
	for index, rollermine in ipairs( ents.FindByClass( "roller_prize" ) ) do
		local offset = LocalPlayer( ):GetPos() - rollermine:GetPos( )
		offset:Rotate( Angle( 0, 180, 0 ) )
		local y = offset.x * ( 160 / ( ( 300 * 1.5 ) + ( offset.z * 1.5 ) ) )
		local x = offset.y * ( 160 / ( ( 300 * 1.5 ) + ( offset.z * 1.5 ) ) )
		surface.SetDrawColor( 45, 45, 255, 255 )
		surface.SetMaterial( crossMaterial )
		surface.SetDrawColor( 255, 255, 255, 255 )
		local mapDataX = { start = miniMapCam.x * 1, mid = ( miniMapCam.x + ( miniMapCam.w / 2 ) ), endpos = ( miniMapCam.x + miniMapCam.w ) - 16 }
		local mapDataY = { start = miniMapCam.y * 1, mid = ( miniMapCam.y + ( miniMapCam.h / 2 ) ), endpos = ( miniMapCam.y + miniMapCam.h ) - 16 }
		surface.DrawTexturedRect( math.Clamp( mapDataX.mid - x, mapDataX.start, mapDataX.endpos ), math.Clamp( mapDataY.mid - y, mapDataY.start, mapDataY.endpos ), 16, 16 )	
		draw.SimpleTextOutlined( "Rollermine!", "Default", math.Clamp( mapDataX.mid - x, mapDataX.start, mapDataX.endpos ), math.Clamp( ( mapDataY.mid - y ) - 10, mapDataY.start - 10, mapDataY.endpos - 10 ),  Color( 255, 255, 255, 255 ), 1, 0, 1, Color( 0, 0, 0, 255 ) )
	end
	if not ( LocalPlayer( ):InVehicle( ) ) then
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( arrowMaterial )
		local posX = ( miniMapCam.x + ( miniMapCam.w / 2 ) )
		local posY = ( miniMapCam.y + ( miniMapCam.h / 2 ) )
		surface.DrawTexturedRectRotated( posX, posY, 24, 24, LocalPlayer( ):GetAngles( ).y )
	end
end

local function HideMiniMapPhysgun( ply, physgun, enabled, target, bone, hitPos )
	if ( drawingMap ) then
		return false
	end
end
hook.Add( "DrawPhysgunBeam", "HideMiniMapPhysgun", HideMiniMapPhysgun )

local function StaticWaypointsChange( var, oldVal, newVal )
	if ( var == "MinimapStaticWaypoints" ) then
		local existingWaypoints = SHNOOB_VARS:Get( "MinimapWaypoints" )
		local staticWaypoints = SHNOOB_VARS:Get( "MinimapStaticWaypoints" )
		if ( istable( LocalPlayer( ).currentWaypoints ) ) then
			for name, pos in pairs ( LocalPlayer( ).currentWaypoints ) do
				if ( !existingWaypoints[name] and !staticWaypoints[name] ) then
					LocalPlayer( ).currentWaypoints[name] = nil
				end
			end
		end
		for name, pos in pairs ( newVal ) do
			LocalPlayer( ).currentWaypoints = LocalPlayer( ).currentWaypoints or { }
			LocalPlayer( ).currentWaypoints[name] = pos
		end
	end
end
hook.Add( "OnSharedVariableChange", "N00BRP_StaticWaypointsChange_OnSharedVariableChange", StaticWaypointsChange )

local reticleMaterial = Material( "vgui/hud/xbox_reticle.vtf" )
local function DrawTwoDimensionalHUD( )
	if ( IsValid( LocalPlayer( ):GetEyeTrace( ).Entity ) ) then
		local ent = LocalPlayer( ):GetEyeTrace( ).Entity
		if ( ent:GetClass( ) == "prop_physics" ) then
			if ( IsValid( ent:CPPIGetOwner( ) ) ) then
				draw.SimpleText( "Owned by: " .. ent:CPPIGetOwner( ):Name( ), "N00BRP_2DIndicator_ReallyTinyBoldText", ScrW( ) * 0.95, ScrH( ) * 0.8, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT )
			end
		end
	end
	if ( LocalPlayer( ):Team( ) == TEAM_HITMAN and IsValid( LocalPlayer( ):getHitTarget( ) ) ) then
		local posData = ( LocalPlayer( ):getHitTarget( ):GetPos( ) + Vector( 0, 0, 50 ) ):ToScreen( )
		--if not ( posData.visible ) then return end
		surface.SetMaterial( reticleMaterial )
		surface.SetDrawColor( Color( math.abs( math.sin( CurTime( ) ) * 255 ) + 100 , 45, 45, 255 ) )
		surface.DrawTexturedRect( posData.x - ScrW( ) * 0.05, posData.y - ScrH( ) * 0.05, ScrW( ) * 0.1, ScrH( ) * 0.1 )
	end
	DrawMiniMap( )
	DrawNotifications( )
	DrawCenterScreenMessages( )
	if ( SHNOOB_VARS:Get( "PurgeEventActive" ) == true ) then
		local startPos = ScrH( ) - 50
		if ( LocalPlayer( ):IsGhost( ) ) then
			startPos = ScrH( ) - 190
		end
		draw.RoundedBox( 0, ScrW( ) * 0.5 - 115, startPos - 8, 230, 60, Color( 45, 45, 45, 175 ) )
		draw.SimpleText( "A PURGE EVENT IS IN PROGRESS", "NPGUI_PL_FLAG", ScrW( ) * 0.5, startPos, Color( 255, 45, 45 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( "Other players can kill you.", "NPGUI_PL_TAG", ScrW( ) * 0.5, startPos + ScrH( ) * 0.025, Color( 200, 45, 45 ), TEXT_ALIGN_CENTER )	
		if ( LocalPlayer( ):IsInSafeZone( ) ) then
			draw.SimpleText( "YOU ARE IN THE SAFE ZONE", "NPGUI_PL_TAG", ScrW( ) * 0.5, startPos - ScrH( ) * 0.025, Color( 45, 200, 45 ), TEXT_ALIGN_CENTER )	
		end
	end
end
hook.Add( "HUDPaint", "N00BRP_DrawTwoDimensionalHUD_HUDPaint", DrawTwoDimensionalHUD )

local function ReceiveVehicleGas( len )
	local veh = net.ReadEntity( )
	local currentGas = net.ReadUInt( 16 )
	local maxGas = net.ReadUInt( 16 )
	LocalPlayer( ).vehicleData = { veh = veh, currentGas = currentGas, maxGas = maxGas }
end
net.Receive( "N00BRP_SendVehicleGas", ReceiveVehicleGas )
surface.CreateFont( "N00BRP_PlayerReviveMenu_ButtonFont", {
	font = "Segoe UI Bold",
	size = ScreenScale( 14 ),
	weight = 600,
	blursize = 0,
} )

surface.CreateFont( "N00BRP_PlayerReviveMenu_TextFont", {
	font = "Segoe UI Bold",
	size = ScreenScale( 8 ),
	weight = 400,
	blursize = 0,
} )

surface.CreateFont( "N00BRP_PlayerReviveMenu_BoldTextFont", {
	font = "Segoe UI Bold",
	size = ScreenScale( 10 ),
	weight = 600,
	blursize = 0,
} )

PANEL = { }

function PANEL:Init()
    self:SetSize( ScrW( ) * 0.3, ScrH( ) * 0.2 )
    self:Center( )
    self:SetupButtons( )
    self.playerReviver = "Invalid Player"
   	gui.EnableScreenClicker( true )
end

function PANEL:SetupButtons( )
	local acceptButton = vgui.Create( "DN00B_ColoredButton", self )
	acceptButton:SetSize( self:GetWide( ) * 0.35, self:GetTall( ) * 0.25 )
	acceptButton:Center( )
	acceptButton:AlignLeft( ScrW( ) * 0.01 )
	acceptButton:SetText( "Accept" )
	acceptButton:SetButtonColor( Color( 51, 110, 123, 180 ) )
	acceptButton:SetTextFont( "N00BRP_PlayerReviveMenu_ButtonFont" )
	acceptButton:SetTextColor( Color( 255, 255, 255, 255 ) )
	acceptButton:SetRoundness( 4 )
	acceptButton.OnMousePressed = function( btn )
		RunConsoleCommand( "rp_acceptrevive" )
		gui.EnableScreenClicker( false )
		self:Remove( )
	end
	local denyButton = vgui.Create( "DN00B_ColoredButton", self )
	denyButton:SetSize( self:GetWide( ) * 0.35, self:GetTall( ) * 0.25 )
	denyButton:Center( )
	denyButton:AlignRight( ScrW( ) * 0.01 )
	denyButton:SetText( "Deny" )
	denyButton:SetButtonColor( Color( 51, 110, 123, 180 ) )
	denyButton:SetTextFont( "N00BRP_PlayerReviveMenu_ButtonFont" )
	denyButton:SetTextColor( Color( 255, 255, 255, 255 ) )
	denyButton:SetRoundness( 4 )
	denyButton.OnMousePressed = function( btn )
		RunConsoleCommand( "rp_denyrevive" )
		gui.EnableScreenClicker( false )
		self:Remove( )
	end
	local respawnButton = vgui.Create( "DN00B_ColoredButton", self )
	respawnButton:SetSize( self:GetWide( ) * 0.35, self:GetTall( ) * 0.25 )
	respawnButton:Center( )
	respawnButton:AlignBottom( ScrW( ) * 0.01 )
	respawnButton:SetText( "Respawn" )
	respawnButton:SetButtonColor( Color( 51, 110, 123, 180 ) )
	respawnButton:SetTextFont( "N00BRP_PlayerReviveMenu_ButtonFont" )
	respawnButton:SetTextColor( Color( 255, 255, 255, 255 ) )
	respawnButton:SetRoundness( 4 )
	respawnButton.OnMousePressed = function( btn )
		RunConsoleCommand( "rp_respawnrevive" )
		gui.EnableScreenClicker( false )
		self:Remove( )
	end
end

function PANEL:SetReviver( ply )
	if not ( IsValid( ply ) ) then
		self.playerReviver = "Unknown"
	else
		self.playerReviver = ply:Name( )
	end
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, Color( 24, 24, 24, 245 ) )
    draw.SimpleText( "You are being revived by: ", "N00BRP_PlayerReviveMenu_TextFont", w / 2, h * 0.1, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
    draw.SimpleText( self.playerReviver, "N00BRP_PlayerReviveMenu_BoldTextFont", w / 2, h * 0.175, Color( 255, 255, 255, 255), TEXT_ALIGN_CENTER )
end

vgui.Register( "N00BRP_ReviveMenu", PANEL, "Panel" )

local function ReceivePlayerReviveMenu( len )
	local actionType = net.ReadString( )
	local revivingEntity = net.ReadEntity( )
	if ( actionType == "OpenMenu" ) then
		if not ( ValidPanel( LocalPlayer( ).reviveMenu ) ) then
			LocalPlayer( ).reviveMenu = vgui.Create( "N00BRP_ReviveMenu" )
			LocalPlayer( ).reviveMenu:SetReviver( revivingEntity )
		end
	elseif ( actionType == "CloseMenu" ) then
		if ( ValidPanel( LocalPlayer( ).reviveMenu ) ) then
			LocalPlayer( ).reviveMenu:Remove( )
			gui.EnableScreenClicker( false )
		end
	end
end
net.Receive( "N00BRP_PlayerReviveMenu", ReceivePlayerReviveMenu )
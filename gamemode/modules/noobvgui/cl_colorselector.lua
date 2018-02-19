surface.CreateFont( "N00BRP_ColorSelector_SmallText", {
	font = "Lobster",
	size = ScreenScale( 12 ),
	weight = 600,
	blursize = 0,
} )

surface.CreateFont( "N00BRP_ColorSelector_LargeText", {
	font = "Lobster",
	size = ScreenScale( 15 ),
	weight = 750,
	blursize = 0,
} )

PANEL = { }

function PANEL:Init()
    self:SetSize( ScrW( ) * 0.3, ScrH( ) * 0.4 )
    self:Center( )
    self:SetupColorSelector( )
    self.confirmCommand = "unspecified_command"
    self.entityArgument = nil
    gui.EnableScreenClicker( true )
end

function PANEL:SetupColorSelector( )
	local dRGBPicker = vgui.Create( "DRGBPicker", self )
	dRGBPicker:SetSize( self:GetWide( ) * 0.8, self:GetTall( ) * 0.7 )
	dRGBPicker:Center( )
	dRGBPicker:AlignTop( self:GetTall( ) * 0.1 )
	dRGBPicker:SetRGB( Color( 255, 255, 255 ) )
	local selectColorButton = vgui.Create( "DN00B_ColoredButton", self )
	selectColorButton:SetSize( self:GetWide( ) * 0.6, self:GetTall( ) * 0.15 )
	selectColorButton:Center( )
	selectColorButton:AlignBottom( ScrH( ) * 0.015 )
	selectColorButton:SetText( "Confirm" )
	selectColorButton:SetButtonColor( Color( 26, 188, 156, 180 ) )
	selectColorButton:SetTextFont( "N00BRP_ColorSelector_LargeText" )
	selectColorButton:SetTextColor( Color( 255, 255, 255, 255 ) )
	selectColorButton:SetRoundness( 4 )
	selectColorButton.OnMousePressed = function( btn )
		local selColor = dRGBPicker:GetRGB( )
		if ( self.entityArgument ) then
			RunConsoleCommand( self.confirmCommand, selColor.r, selColor.g, selColor.b, self.entityArgument )
		else
			RunConsoleCommand( self.confirmCommand, selColor.r, selColor.g, selColor.b )
		end
		gui.EnableScreenClicker( false )
		self:Remove( )
	end
end

function PANEL:SetConfirmCommand( cmd )
	self.confirmCommand = cmd
end

function PANEL:SetEntityArgument( entIndex )
	self.entityArgument = entIndex
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 8, 0, 0, w, h, Color( 12, 102, 179, 255 ) )
    --draw.RoundedBox( 4, w * 0.3, h * 0.0225, w * 0.4, h * 0.05, Color( 255, 255, 255, 80 ) )
    draw.SimpleText( "Choose a Color", "N00BRP_ColorSelector_SmallText", w / 2, h * 0.02, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
end

vgui.Register( "N00BRP_ColorSelector", PANEL, "Panel" )

local function ReceiveColorSelector( len )
	local colorCommand = net.ReadString( )
	local extraEnt = net.ReadEntity( )
	if not ( ValidPanel( LocalPlayer( ).colorSelector ) ) then
		LocalPlayer( ).colorSelector = vgui.Create( "N00BRP_ColorSelector" )
		LocalPlayer( ).colorSelector:SetConfirmCommand( colorCommand )
		if ( IsValid( extraEnt ) ) then
			LocalPlayer( ).colorSelector:SetEntityArgument( extraEnt:EntIndex( ) )
		end
	end
end
net.Receive( "N00BRP_ColorSelector", ReceiveColorSelector )
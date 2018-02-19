surface.CreateFont( "N00BRP_PlayerColorSelector_SmallText", {
	font = "Lobster",
	size = ScreenScale( 11 ),
	weight = 600,
	blursize = 0,
} )

surface.CreateFont( "N00BRP_PlayerColorSelector_LargeText", {
	font = "Lobster",
	size = ScreenScale( 12 ),
	weight = 750,
	blursize = 0,
} )

PANEL = { }

function PANEL:Init()
    self:SetSize( ScrW( ) * 0.5, ScrH( ) * 0.6 )
    self:Center( )
    self.currentColor = Color( 255, 255, 255 )
    self:SetupColorSelector( )
    gui.EnableScreenClicker( true )
end

function PANEL:OnMousePressed( btn )
	self:Remove( )
end

function PANEL:SetupColorSelector( )
	self.modelPanel = vgui.Create( "DN00B_ModelPanelPlus", self )
	self.modelPanel:ModifySize( self:GetWide( ) * 0.5, self:GetTall( ) * 0.9 )
	self.modelPanel:Center( )
	self.modelPanel:AlignTop( self:GetTall( ) * 0.05 )
	self.modelPanel:AlignLeft( self:GetWide( ) * 0.075 )
	self.modelPanel:LoadModel( LocalPlayer( ):GetModel( ) )
	self.modelPanel:SetModelFOV( ScreenScale( 13 ) )
	self.modelPanel:SetPlayerModelColor( self.currentColor )
	self.modelPanel:EnableHoverSpinning( 1 )
	self.dRGBPicker = vgui.Create( "DRGBPicker", self )
	self.dRGBPicker:SetSize( self:GetWide( ) * 0.275, self:GetTall( ) * 0.3 )
	self.dRGBPicker:Center( )
	self.dRGBPicker:AlignTop( self:GetTall( ) * 0.1 )
	self.dRGBPicker:AlignRight( self:GetWide( ) * 0.075 )
	self.dRGBPicker:SetRGB( Color( 255, 255, 255 ) )
	local oldMousePressed = self.dRGBPicker.OnMousePressed
	self.dRGBPicker.OnMousePressed = function( pnl, btn )
		oldMousePressed( pnl, btn )
		self:SetCurrentColor( self.dRGBPicker:GetRGB( ), self.dWepRGBPicker:GetRGB( ) )
	end
	local oldMouseReleased = self.dRGBPicker.OnMouseReleased
	self.dRGBPicker.OnMouseReleased = function( pnl, btn )
		oldMouseReleased( pnl, btn )
		self:SetCurrentColor( self.dRGBPicker:GetRGB( ), self.dWepRGBPicker:GetRGB( ) )
	end
	self.dWepRGBPicker = vgui.Create( "DRGBPicker", self )
	self.dWepRGBPicker:SetSize( self:GetWide( ) * 0.275, self:GetTall( ) * 0.3 )
	self.dWepRGBPicker:Center( )
	self.dWepRGBPicker:AlignBottom( self:GetTall( ) * 0.225 )
	self.dWepRGBPicker:AlignRight( self:GetWide( ) * 0.075 )
	self.dWepRGBPicker:SetRGB( Color( 255, 255, 255 ) )
	local confirmColorButton = vgui.Create( "DN00B_ColoredButton", self )
	confirmColorButton:SetSize( self:GetWide( ) * 0.325, self:GetTall( ) * 0.05 )
	confirmColorButton:Center( )
	confirmColorButton:AlignBottom( self:GetTall( ) * 0.14 )
	confirmColorButton:AlignRight( self:GetWide( ) * 0.05 )
	confirmColorButton:SetText( "Confirm ( $1mil )" )
	confirmColorButton:SetButtonColor( Color( 26, 188, 156, 180 ) )
	confirmColorButton:SetTextFont( "N00BRP_PlayerColorSelector_LargeText" )
	confirmColorButton:SetTextColor( Color( 255, 255, 255, 255 ) )
	confirmColorButton:SetRoundness( 6 )
	confirmColorButton:SetHoverColor( Color( 26, 188, 156 ) )
	confirmColorButton.OnMousePressed = function( btn )
		local plyColor = self.dRGBPicker:GetRGB( )
		local wepColor = self.dWepRGBPicker:GetRGB( )
		RunConsoleCommand( "rp_setplayerandweaponcolor", plyColor.r, plyColor.g, plyColor.b, wepColor.r, wepColor.g, wepColor.b )
		gui.EnableScreenClicker( false )
		self:Remove( )
	end
	local cancelButton = vgui.Create( "DN00B_ColoredButton", self )
	cancelButton:SetSize( self:GetWide( ) * 0.15, self:GetTall( ) * 0.05 )
	cancelButton:Center( )
	cancelButton:AlignBottom( self:GetTall( ) * 0.06 )
	cancelButton:AlignRight( self:GetWide( ) * 0.13 )
	cancelButton:SetText( "Cancel" )
	cancelButton:SetButtonColor( Color( 26, 188, 156, 180 ) )
	cancelButton:SetTextFont( "N00BRP_PlayerColorSelector_LargeText" )
	cancelButton:SetTextColor( Color( 255, 255, 255, 255 ) )
	cancelButton:SetRoundness( 6 )
	cancelButton:SetHoverColor( Color( 26, 188, 156 ) )
	cancelButton.OnMousePressed = function( btn )
		gui.EnableScreenClicker( false )
		self:Remove( )
	end
end

function PANEL:SetCurrentColor( plyColor, wepColor )
	self.dRGBPicker:SetRGB( plyColor )
	self.dWepRGBPicker:SetRGB( wepColor )
	self.modelPanel:SetPlayerModelColor( plyColor )
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 8, 0, 0, w, h, Color( 12, 102, 179, 255 ) )
    --draw.RoundedBox( 4, w * 0.3, h * 0.0225, w * 0.4, h * 0.05, Color( 255, 255, 255, 80 ) )
    draw.SimpleText( "Select a Player Color", "N00BRP_PlayerColorSelector_SmallText", w * 0.79, h * 0.05, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
    draw.SimpleText( "Select a Weapon Color", "N00BRP_PlayerColorSelector_SmallText", w * 0.79, h * 0.425, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
end

vgui.Register( "N00BRP_PlayerColorSelector", PANEL, "Panel" )

local function ReceiveColorSelector( len )
	local plyColorTable = net.ReadTable( )
	local wepColorTable = net.ReadTable( )
	if not ( ValidPanel( LocalPlayer( ).playerColorSelector ) ) then
		LocalPlayer( ).playerColorSelector = vgui.Create( "N00BRP_PlayerColorSelector" )
		if ( istable( colorTable ) ) then
			LocalPlayer( ).playerColorSelector:SetCurrentColor( colorTable, wepColorTable )
		end
	end
end
net.Receive( "N00BRP_PlayerColorSelector", ReceiveColorSelector )
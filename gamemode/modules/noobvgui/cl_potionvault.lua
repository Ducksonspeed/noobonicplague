surface.CreateFont( "N00BRP_PotionVault_SmallText", {
	font = "Lobster",
	size = ScreenScale( 9 ),
	weight = 750,
	blursize = 0,
} )

surface.CreateFont( "N00BRP_PotionVault_BoldSmallText", {
	font = "Lobster",
	size = ScreenScale( 11 ),
	weight = 750,
	blursize = 0,
} )


PANEL = { }

function PANEL:Init()
    self:SetSize( ScrW( ) * 0.5, ScrH( ) * 0.3 )
    self:Center( )
 	self:CreateItemList( )
 	self:GenerateVaultList( )
 	self:SetTitle( "" )
 	self:ShowCloseButton( false )
 	self:MakePopup( )
 	self.currentScroll = 0
    gui.EnableScreenClicker( true )
   	local dButton = vgui.Create( "DN00B_ColoredButton", self)
	dButton:SetSize( self:GetWide( ) * 0.05, self:GetTall( ) * 0.1 )
	dButton:SetTextFont( "N00BRP_PotionVault_BoldSmallText" )
	dButton:AlignTop( self:GetTall( ) * 0.025 )
	dButton:AlignRight( self:GetWide( ) * 0.025 )
	dButton:SetText( "X" )
	dButton:SetButtonColor( Color( 27, 163, 156 ) )
	dButton:SetHoverColor( Color( 102, 204, 153 ) )
	dButton:SetTextColor( Color( 175, 45, 45 ) )
	dButton:SetRoundness( 4 )
	dButton.OnMousePressed = function( btn )
		gui.EnableScreenClicker( false )
		self:Remove( )
	end
end

function PANEL:CreateItemList( )
	self.scrollPanel = vgui.Create( "DScrollPanel", self )
	self.scrollPanel:SetSize( self:GetWide( ) * 0.95, self:GetTall( ) * 0.6 )
	self.scrollPanel:Center( )
	self.scrollPanel:AlignTop( self:GetTall( ) * 0.15 )
	local posX, posY = self.scrollPanel:GetPos( )
	posX = posX + self:GetWide( ) * 0.005
	posY = posY + self:GetTall( ) * 0.1
	self.scrollPanel:SetPos( posX, posY )
	self.itemList = vgui.Create( "DN00B_ScrollableList" )
	self.scrollPanel:AddItem( self.itemList )
	self.itemList:SetSize( self:GetWide( ) * 0.95, self:GetTall( ) * 0.6 )
	self.itemList:SetPos( 0, 0 )
	self.itemList:SetListWidthMultiplier( 1 )
	self.itemList:DrawListBackground( 2, Color( 52, 73, 94, 100 ) )
	self.itemList:SetSpaceX( 8 )
	self.itemList:SetSpaceY( 2 )
end

function PANEL:GenerateVaultList( )
	if not ( table.Count( LocalPlayer( ).PotionVaultTable ) > 0 ) then return end
	self.currentScroll = self.scrollPanel:GetVBar( ):GetScroll( )
	self.itemList:ClearItems( )
	for index, amt in pairs ( LocalPlayer( ).PotionVaultTable ) do
		local dPanelRow = self.itemList:AddElement( "DPanel" )
		dPanelRow:SetSize( self:GetWide( ), self:GetTall( ) * 0.125 )
		dPanelRow.Paint = function( pnl, w, h )
			surface.SetFont( "N00BRP_PotionVault_SmallText" )
			local txtW, txtH = surface.GetTextSize( amt )
			draw.RoundedBox( 4, 0, 0, w, h, Color( 42, 187, 155, 100 ) )
			draw.SimpleText( index, "N00BRP_PotionVault_SmallText", w * 0.02, h * 0.1, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT )
			draw.SimpleText( amt, "N00BRP_PotionVault_SmallText", w * 0.5, ( txtH * 0.4 ), Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
		end
		local dNumberWang = vgui.Create( "DNumberWang", dPanelRow )
		dNumberWang:SetSize( self:GetWide( ) * 0.1, self:GetTall( ) * 0.1 )
		dNumberWang:Center( )
		dNumberWang:AlignRight( self:GetWide( ) * 0.3)
		local dButton = vgui.Create( "DN00B_ColoredButton", dPanelRow )
		dButton:SetSize( self:GetWide( ) * 0.15, self:GetTall( ) * 0.1 )
		dButton:SetTextFont( "N00BRP_PotionVault_SmallText" )
		dButton:Center( )
		dButton:AlignRight( self:GetWide( ) * 0.1 )
		dButton:SetText( "Retrieve" )
		dButton:SetButtonColor( Color( 27, 163, 156 ) )
		dButton:SetHoverColor( Color( 102, 204, 153 ) )
		dButton:SetTextColor( Color( 255, 255, 255 ) )
		dButton.OnMousePressed = function( pnl, btn )
			net.Start( "N00BRP_PotionVault_NET" )
				net.WriteUInt( ENUM_POTIONVAULT_ATTEMPTRETRIEVE, 8 )
				net.WriteString( index )
				net.WriteUInt( math.abs( dNumberWang:GetValue( ) ), 8 )
			net.SendToServer( )
		end
	end
	if ( self.currentScroll ~= 0 and table.Count( LocalPlayer( ).PotionVaultTable ) > 4 ) then 
		self.scrollPanel:GetVBar( ):SetScroll( self.currentScroll ) 
	end
end

function PANEL:Paint( w, h )
	surface.SetFont( "N00BRP_PotionVault_SmallText" )
	local txtW, txtH = surface.GetTextSize( "Amount" )
    draw.RoundedBox( 0, 0, 0, w, h, Color( 51, 110, 123, 235 ) )
    draw.RoundedBox( 0, w * 0.45, h * 0.26, w * 0.15, table.Count( LocalPlayer( ).PotionVaultTable ) * 0.125, Color( 27, 163, 156, 255 ) )
    draw.RoundedBox( 0, w * 0.0275, h * 0.15, w * 0.95, h * 0.1, Color( 27, 163, 156, 255 ) )
    draw.SimpleText( "Potion Name", "N00BRP_PotionVault_SmallText", w * 0.05, h * 0.15, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT )
    draw.SimpleText( "Amount", "N00BRP_PotionVault_SmallText", w * 0.5275, h * 0.15, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
    draw.SimpleText( "Potion Vault", "N00BRP_PotionVault_BoldSmallText", w * 0.525, h * 0.025, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
end

vgui.Register( "N00BRP_PotionVault", PANEL, "DFrame" )
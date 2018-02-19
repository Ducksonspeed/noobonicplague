surface.CreateFont( "N00BRP_PerksMenu_TitleFont", {
	font = "Arial",
	size = ScreenScale( 16 ),
	weight = 600,
	blursize = 0,
} )

surface.CreateFont( "N00BRP_PerksMenu_DescFont", {
	font = "Arial",
	size = ScreenScale( 8 ),
	weight = 600,
	blursize = 0,
} )

PERK_TREE_MENU = nil;

PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW( ) * 0.4, ScrH( ) * 0.6 )
    self:SetTitle( "" )
    self:Center( )
    self:ShowCloseButton( false )
    gui.EnableScreenClicker( true )
 	local dCloseButton = vgui.Create( "DN00B_ColoredButton", self )
	dCloseButton:SetText( "X" )
	dCloseButton:SetTextFont( "N00BRP_PerksMenu_DescFont" )
	dCloseButton:SetTextColor( Color( 255, 255, 255, 255 ) )															
	dCloseButton:SetButtonColor( Color( 175, 45, 45, 255 ) )
	dCloseButton:SetHoverColor( Color( 205, 85, 85, 255 ) )
	dCloseButton:SetSize( self:GetWide( ) * 0.1, self:GetTall( ) * 0.04 )
	dCloseButton:OffsetFromCenter( 0, self:GetTall( ) * -0.465 )
	dCloseButton.OnMousePressed = function( btn )
		gui.EnableScreenClicker( false )
		self:Remove( )
	end
	self:CreateMainScrollPanel( )
	self:GeneratePerkTrees( )
end

function PANEL:Paint( w, h )
	local remainingPerkPoints = LocalPlayer( ):getDarkRPVar( "PlayerPerkPoints" )
	local bonusPerks = LocalPlayer( ):getDarkRPVar( "BonusPerks" )
	if ( istable( bonusPerks ) ) then
		remainingPerkPoints = remainingPerkPoints + bonusPerks.unspent or 0
	end
 	draw.RoundedBox( 4, 0, 0, w, h, Color( 25, 25, 25, 230 ) );
	draw.SimpleText( "Remaining Perk Points: " .. remainingPerkPoints, "N00BRP_PerksMenu_DescFont", w / 2, h * 0.07, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
end

function PANEL:CreateMainScrollPanel( )
	self.dMainScrollPanel = vgui.Create( "DScrollPanel", self )
	local dScrollPanel = self.dMainScrollPanel
	dScrollPanel:SetSize( self:GetWide( ) * 0.9, self:GetTall( ) * 0.85 )
	dScrollPanel:OffsetFromCenter( 0, self:GetTall( ) * 0.05 )
	dScrollPanel:ColorizeScrollbar( Color( 102, 102, 102 ), Color( 102, 102, 102 ), Color( 122, 122, 122 ), Color( 71, 71, 71 ) )
	dScrollPanel.PaintOver = function( pnl, w, h )
		for index, child in pairs ( dScrollPanel:GetChildren( )[1]:GetChildren( ) ) do
			local vXPos, vYPos = dScrollPanel.pnlCanvas:GetPos( )
			local xPos, yPos = child:GetPos( )
			draw.SimpleTextOutlined( child.Description, "N00BRP_PerksMenu_TitleFont", w / 2, ( yPos - ( dScrollPanel:GetTall( ) * 0.06 ) ) + vYPos, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 45, 45, 175, 255 ) )
		end
	end
end

function PANEL:GeneratePerkTrees( )
	local dScrollPanel = self.dMainScrollPanel
	dScrollPanel:Clear( )
	local yOffset = ( dScrollPanel:GetTall( ) * 0.0984 )
	local playerPerks = LocalPlayer( ):getDarkRPVar( "PlayerPerks" ) or { }
	for name, tree in SortedPairsByMemberValue( NOOB_PERK_TREE, "Placement", false ) do
		local dTreeScrollPanel = vgui.Create( "DN00B_ScrollableList" )
		dTreeScrollPanel:SetSize( dScrollPanel:GetWide( ) * 0.95, dScrollPanel:GetTall( ) * 0.2 )
		dTreeScrollPanel:SetPos( 0, yOffset )
		dTreeScrollPanel.Description = name
		dTreeScrollPanel:ColorizeScrollbar( Color( 102, 102, 102 ), Color( 102, 102, 102 ), Color( 122, 122, 122 ), Color( 71, 71, 71 ) )
		dScrollPanel:AddItem( dTreeScrollPanel )
		yOffset = yOffset + ( dScrollPanel:GetTall( ) * 0.2 ) + ( dScrollPanel:GetTall( ) * 0.131 )
		for index, rank in ipairs ( tree ) do
			local dIconLayout = dTreeScrollPanel:GetIconLayout( )
			local rankButton = dIconLayout:Add( "DN00B_ColoredButton" )
			rankButton:SetSize( dScrollPanel:GetWide( ) * 0.9, dScrollPanel:GetTall( ) * 0.05 )
			rankButton:SetText( rank[1] )
			rankButton:SetTextColor( Color( 255, 255, 255, 255 ) )
			rankButton:SetButtonColor( Color( 210, 77, 87 ) )
			rankButton:SetHoverColor( Color( 46, 204, 113, 255 ) )
			rankButton:SetTextFont( "N00BRP_PerksMenu_DescFont" )
			if ( playerPerks[name] and playerPerks[name] >= index ) then
				rankButton:SetButtonColor( Color( 46, 204, 113, 255 ) )
			end
			rankButton.OnMousePressed = function( btn )
				dScrollPanel.nextMousePress = dScrollPanel.nextMousePress or 0
				if not ( dScrollPanel.nextMousePress < CurTime( ) ) then return end
				dScrollPanel.nextMousePress = CurTime( ) + 1
				net.Start( "noob_playerperks" )
					net.WriteTable( { tree = name, rank = index } )
				net.SendToServer( )
				timer.Simple( 0.1, function( )
					if not ( ValidPanel( self ) ) then return end
					self:GeneratePerkTrees( )
				end )
			end
		end
	end
end
vgui.Register( "N00BRP_PerksMenu", PANEL, "DFrame" )

concommand.Add( "noob_perktree", function( pl, cmd, args )
	if ( ValidPanel( PERK_TREE_MENU ) ) then PERK_TREE_MENU:Remove(); end
	PERK_TREE_MENU = vgui.Create( "N00BRP_PerksMenu" )
end );
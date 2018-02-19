PANEL = { }

function PANEL:Init()
    self:SetSize( ScrW( ) * 0.3, ScrH( ) * 0.6 )
    self:Center( )
    self.trunkItems = { }
 	self:CreateItemList( )
 	self:GenerateList( )
 	self.vehicleIndex = nil
    gui.EnableScreenClicker( true )
    self:SetupButtons( )
end

function PANEL:SetupButtons( )
	local closeButton = vgui.Create( "DN00B_ColoredButton", self )
	closeButton:SetSize( self:GetWide( ) * 0.1, self:GetTall( ) * 0.05 )
	closeButton:AlignTop( self:GetTall( ) * 0.075 )
	closeButton:CenterHorizontal( )
	closeButton:SetText( "X" )
	closeButton:SetTextFont( "N00BRP_PlayerReviveMenu_ButtonFont" )
	closeButton:SetButtonColor( Color( 26, 188, 156, 200 ) )
	closeButton:SetTextColor( Color( 175, 45, 45 ) )
	closeButton.OnMousePressed = function( btnPnl, btn )
	 	gui.EnableScreenClicker( false )
	 	self:Remove( )
	end
	local playButton = vgui.Create( "DN00B_ColoredButton", self )
	playButton:SetSize( self:GetWide( ) * 0.2, self:GetTall( ) * 0.05 )
	playButton:SetText( "Play" )
	playButton:SetButtonColor( Color( 26, 188, 156, 200 ) )
	playButton:SetTextFont( "N00BRP_PlayerReviveMenu_ButtonFont" )
	playButton:SetTextColor( Color( 255, 255, 255, 255 ) )
	playButton:SetRoundness( 4 )
	playButton:AlignLeft( self:GetWide( ) * 0.1 )
	playButton:AlignTop( self:GetTall( ) * 0.075 )
	playButton.OnMousePressed = function( pnl, btn )
		if ( IsValid( self:GetRadioEntity( ) ) ) then
			if ( self:GetRadioEntity( ):GetClass( ) == "ent_radio" or self:GetRadioEntity( ):IsVehicle( ) ) then
				self:GetRadioEntity( ):PlayRadioPatch( )
			end
		end
		gui.EnableScreenClicker( false )
		self:Remove( )
	end
	local stopButton = vgui.Create( "DN00B_ColoredButton", self )
	stopButton:SetSize( self:GetWide( ) * 0.2, self:GetTall( ) * 0.05 )
	stopButton:SetText( "Stop" )
	stopButton:SetButtonColor( Color( 26, 188, 156, 200 ) )
	stopButton:SetTextFont( "N00BRP_PlayerReviveMenu_ButtonFont" )
	stopButton:SetTextColor( Color( 255, 255, 255, 255 ) )
	stopButton:SetRoundness( 4 )
	stopButton:AlignRight( self:GetWide( ) * 0.1 )
	stopButton:AlignTop( self:GetTall( ) * 0.075 )
	stopButton.OnMousePressed = function( pnl, btn )
		if ( IsValid( self:GetRadioEntity( ) ) ) then
			if ( self:GetRadioEntity( ):GetClass( ) == "ent_radio" or self:GetRadioEntity( ):IsVehicle( ) ) then
				self:GetRadioEntity( ):StopRadioPatch( )
			end
		end
		gui.EnableScreenClicker( false )
		self:Remove( )
	end
end

function PANEL:CreateItemList( )
	local scrollPanel = vgui.Create( "DScrollPanel", self )
	scrollPanel:SetSize( self:GetWide( ) * 0.95, self:GetTall( ) * 0.8 )
	scrollPanel:Center( )
	scrollPanel:AlignTop( self:GetTall( ) * 0.15 )
	local posX, posY = scrollPanel:GetPos( )
	posX = posX + self:GetWide( ) * 0.025
	scrollPanel:SetPos( posX, posY )
	self.itemList = vgui.Create( "DN00B_ScrollableList" )
	scrollPanel:AddItem( self.itemList )
	self.itemList:SetSize( self:GetWide( ) * 0.95, self:GetTall( ) * 0.8 )
	self.itemList:SetPos( 0, 0 )
	self.itemList:SetListWidthMultiplier( 0.95 )
	self.itemList:DrawListBackground( 2, Color( 41, 128, 185, 100 ) )
	self.itemList:SetSpaceX( 0 )
	self.itemList:SetSpaceY( 8 )
end

function PANEL:SetRadioEntity( ent )
	self.radioEntity = ent
end

function PANEL:GetRadioEntity( )
	return self.radioEntity
end

function PANEL:GenerateList( )
	if not ( ValidPanel( self.itemList ) ) then return end
	self.itemList:ClearItems( )
	for index, url in SortedPairs( SHNOOB_VARS:Get( "RadioStations" ), false ) do
		local stationButton = self.itemList:AddElement( "DN00B_ColoredButton" )
		stationButton:SetSize( self.itemList:GetWide( ), self.itemList:GetTall( ) * 0.075 )
		stationButton:SetText( index )
		stationButton:SetButtonColor( Color( 26, 188, 156, 200 ) )
		stationButton:SetTextFont( "N00BRP_PlayerReviveMenu_ButtonFont" )
		stationButton:SetTextColor( Color( 255, 255, 255, 255 ) )
		stationButton:SetRoundness( 4 )
		stationButton.OnMousePressed = function( pnl, btn )
			if ( IsValid( self:GetRadioEntity( ) ) ) then
				if ( self:GetRadioEntity( ):GetClass( ) == "ent_radio" or self:GetRadioEntity( ):IsVehicle( ) ) then
					self:GetRadioEntity( ):SetPatchStation( index )
				end
			end
			gui.EnableScreenClicker( false )
			self:Remove( )
		end
	end
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, Color( 22, 160, 133, 235 ) )
end

vgui.Register( "N00BRP_RadioMenu", PANEL, "Panel" )
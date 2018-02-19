PANEL = { }

function PANEL:Init()
    self:SetSize( ScrW( ) * 0.4, ScrH( ) * 0.2 )
    self:Center( )
    self.trunkItems = { }
 	self:CreateItemList( )
 	self.vehicleIndex = nil
    gui.EnableScreenClicker( true )
    local closeButton = vgui.Create( "DButton", self )
	closeButton:SetSize( self:GetWide( ) * 0.05, self:GetTall( ) * 0.1 )
	closeButton:AlignTop( self:GetTall( ) * 0.025 )
	closeButton:AlignRight( self:GetWide( ) * 0.005 )
	closeButton:SetText( "X" )
	closeButton:SetFont( "N00BRP_PlayerReviveMenu_BoldTextFont" )
	closeButton:SetTextColor( Color( 175, 45, 45 ) )
	closeButton.OnMousePressed = function( btnPnl, btn )
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
	self.itemList:DrawListBackground( 2, Color( 52, 73, 94, 200 ) )
	self.itemList:SetSpaceX( 8 )
	self.itemList:SetSpaceY( 2 )
end

function PANEL:OnMousePressed( )
	gui.EnableScreenClicker( false )
	self:Remove( )
end

function PANEL:ReloadList( )
	if not ( ValidPanel( self.itemList ) ) then return end
	if ( !self.trunkItems or #self.trunkItems <= 0 ) then return end
	self.itemList:ClearItems( )
	for index, ent in ipairs ( self.trunkItems ) do
		local spawnIcon = self.itemList:AddElement( "SpawnIcon" )
		spawnIcon:SetModel( ent.model )
		spawnIcon:SetToolTip( ent.class )
		spawnIcon.OnMousePressed = function( btnPanel, btn )
			if not ( self.vehicleIndex ) then return end
			RunConsoleCommand( "noob_trunkwithdraw", self.vehicleIndex, index )
		end
		spawnIcon.class = ent.class
	end
end

function PANEL:SetVehicle( index )
	self.vehicleIndex = index
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, Color( 44, 62, 80, 235 ) )
    for index, spawnIcon in ipairs ( self.itemList:GetElements( ) ) do
    	if ( spawnIcon.class and spawnIcon:IsHovered( ) ) then
    		draw.SimpleText( spawnIcon.class, "N00BRP_PlayerReviveMenu_BoldTextFont", w / 2, h * 0.025, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
    	end
    end
end

vgui.Register( "N00BRP_TrunkMenu", PANEL, "Panel" )

local function ReceiveTrunkMenu( len )
	local messageType = net.ReadString( )
	if ( messageType == "OpenMenu" ) then
		if not ( ValidPanel( LocalPlayer( ).trunkMenu ) ) then
			local vehIndex = net.ReadUInt( 32 )
			LocalPlayer( ).trunkMenu = vgui.Create( "N00BRP_TrunkMenu" )
			LocalPlayer( ).trunkMenu:SetVehicle( vehIndex )
		end
	elseif ( messageType == "ReceiveTrunkItems" ) then
		if not ( ValidPanel( LocalPlayer( ).trunkMenu ) ) then return end
		local trunkTable = net.ReadTable( )
		if ( !trunkTable or #trunkTable <= 0 ) then
			gui.EnableScreenClicker( false )
			LocalPlayer( ).trunkMenu:Remove( )
		else
			LocalPlayer( ).trunkMenu.trunkItems = trunkTable
			LocalPlayer( ).trunkMenu:ReloadList( )
		end
	end
end
net.Receive( "N00BRP_TrunkMenu", ReceiveTrunkMenu )
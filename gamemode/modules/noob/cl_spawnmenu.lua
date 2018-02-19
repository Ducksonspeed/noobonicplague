surface.CreateFont( "N00BRP_SpawnMenu_HeaderFont", {
	font = "Segoe UI",
	size = 12,
	weight = 900
}) 
surface.CreateFont( "N00BRP_SpawnMenu_SubHeaderFont", {
	font = "Segoe UI",
	size = 16,
	weight = 500
} 
)

surface.CreateFont( "NPGUI_SpawnMenu_Cat", {
	font = "Segoe UI",
	size = 14,
	weight = 900
}) 

if not ( file.IsDir( "noobonic", "DATA" ) ) then
	file.CreateDir( "noobonic" )
end

local noob_SpawnMenu = nil
local LEFT_CLICK = 107
local RIGHT_CLICK = 108

PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW( ) * 0.4, ScrH( ) - 96 )
    self:OffsetFromCenter( -64, 16 )
    self:ShowCloseButton( false )
    self:SetTitle( "" )
    self:MakePopup( )
    self:SetDraggable( false )
    LocalPlayer( ).favoriteProps = { "models/props/de_piranesi/pi_sundial.mdl", "models/props/de_train/acunit1.mdl" }
    self:GenerateCategoryButtons( )
   	self:CreateMenuLists( )
   	self:GenerateLists( )
   	self.currentCategory = nil
   	self.searchBox = vgui.Create( "DTextEntry", self )
   	local searchBox = self.searchBox
   	searchBox:SetSize( 208, 24 )
   	searchBox:AlignRight( 16 )
   	searchBox:AlignTop( 16 )
   	searchBox:SetFont( "N00BRP_SpawnMenu_HeaderFont" )
   	searchBox.OnChange = function( pnl )
   		self.searchText = searchBox:GetValue( )
   		self:GenerateLists( )
   	end
end

function PANEL:GenerateCategoryButtons( )
	local wepCatButton = vgui.Create( "DN00B_ColoredButton", self )
	wepCatButton:SetSize( 128, 32 )
	wepCatButton:SetTextAlign( TEXT_ALIGN_LEFT )
	wepCatButton:AlignLeft( 16 )
	wepCatButton:AlignTop( 16 + 24 + 8 )
	wepCatButton:SetTextColor( Color( 255, 255, 255 ) )
	wepCatButton:SetTextFont( "NPGUI_SpawnMenu_Cat" )
	--wepCatButton:SetButtonImage( "icon16/gun.png", Color( 255, 255, 255, 255 ), ScreenScale( 2 ) )
	wepCatButton:SetText( "WEAPONS" )
	wepCatButton:SetButtonColor( Color( 24, 24, 24, 200 ) )
	wepCatButton:SetHoverColor( Color( 244, 77, 73 ) )
	wepCatButton.OnMousePressed = function( pnl, btn )
		self.currentCategory = 1
		self:GenerateLists( )
		self.weaponList.scrollParent.VBar:SetScroll( 0 )
	end
	local vehCatButton = vgui.Create( "DN00B_ColoredButton", self )
	vehCatButton:SetSize( 128, 32 )
	vehCatButton:SetTextAlign( TEXT_ALIGN_LEFT )
	vehCatButton:AlignLeft( 16 )
	vehCatButton:AlignTop( 16 + 24 + 8 + 33 )
	vehCatButton:SetTextColor( Color( 255, 255, 255 ) )
	vehCatButton:SetTextFont( "NPGUI_SpawnMenu_Cat" )
	--vehCatButton:SetButtonImage( "icon16/car.png", Color( 255, 255, 255, 255 ), ScreenScale( 2 ) )
	vehCatButton:SetText( "VEHICLES" )
	vehCatButton:SetButtonColor( Color( 24, 24, 24, 200 ) )
	vehCatButton:SetHoverColor( Color( 244, 77, 73 ) )
	vehCatButton.OnMousePressed = function( pnl, btn )
		self.currentCategory = 2
		self:GenerateLists( )
		self.weaponList.scrollParent.VBar:SetScroll( 0 )
	end
	local accessoryCatButton = vgui.Create( "DN00B_ColoredButton", self )
	accessoryCatButton:SetSize( 128, 32 )
	accessoryCatButton:SetTextAlign( TEXT_ALIGN_LEFT )
	accessoryCatButton:AlignLeft( 16 )
	accessoryCatButton:AlignTop( 16 + 24 + 8 + 33 + 33 )
	accessoryCatButton:SetTextColor( Color( 255, 255, 255 ) )
	accessoryCatButton:SetTextFont( "NPGUI_SpawnMenu_Cat" )
	--accessoryCatButton:SetButtonImage( "icon16/briefcase.png", Color( 255, 255, 255, 255 ), ScreenScale( 2 ) )
	accessoryCatButton:SetText( "ACCESSORIES" )
	accessoryCatButton:SetButtonColor( Color( 24, 24, 24, 200 ) )
	accessoryCatButton:SetHoverColor( Color( 244, 77, 73 ) )
	accessoryCatButton.OnMousePressed = function( pnl, btn )
		self.currentCategory = 3
		self:GenerateLists( )
		self.weaponList.scrollParent.VBar:SetScroll( 0 )
	end
	local toolCatButton = vgui.Create( "DN00B_ColoredButton", self )
	toolCatButton:SetSize( 128, 32 )
	toolCatButton:SetTextAlign( TEXT_ALIGN_LEFT )
	toolCatButton:AlignLeft( 16 )
	toolCatButton:AlignTop( 16 + 24 + 8 + 33 + 33 + 33 )
	toolCatButton:SetTextColor( Color( 255, 255, 255 ) )
	toolCatButton:SetTextFont( "NPGUI_SpawnMenu_Cat" )
	--toolCatButton:SetButtonImage( "icon16/wrench.png", Color( 255, 255, 255, 255 ), ScreenScale( 2 ) )
	toolCatButton:SetText( "TOOLS" )
	toolCatButton:SetButtonColor( Color( 24, 24, 24, 200 ) )
	toolCatButton:SetHoverColor( Color( 244, 77, 73 ) )
	toolCatButton.OnMousePressed = function( pnl, btn )
		self.currentCategory = 4
		self:GenerateLists( )
		self.weaponList.scrollParent.VBar:SetScroll( 0 )
	end

	local clearCatButton = vgui.Create( "DN00B_ColoredButton", self )
	clearCatButton:SetSize( 128, 32 )
	clearCatButton:SetTextAlign( TEXT_ALIGN_LEFT )
	clearCatButton:AlignLeft( 16 )
	clearCatButton:AlignTop( 16 + 24 + 8 + 33 + 33 + 33 + 33 )
	clearCatButton:SetTextColor( Color( 255, 255, 255 ) )
	clearCatButton:SetTextFont( "NPGUI_SpawnMenu_Cat" )
	--clearCatButton:SetButtonImage( "icon16/arrow_rotate_clockwise.png", Color( 255, 255, 255, 255 ), ScreenScale( 2 ) )
	clearCatButton:SetText( "ALL" )
	clearCatButton:SetButtonColor( Color( 24, 24, 24, 200 ) )
	clearCatButton:SetHoverColor( Color( 244, 77, 73 ) )
	clearCatButton.OnMousePressed = function( pnl, btn )
		self.currentCategory = nil
		self:GenerateLists( )
		self.weaponList.scrollParent.VBar:SetScroll( 0 )
	end
end

function PANEL:GenerateLists( )
	self:GeneratePropList( )
   	self:GenerateFavoritesList( )
   	self:GenerateWeaponSelection( )
end

function PANEL:CreateMenuLists( )

	local yOffset = 0

	local dScrollList = vgui.Create( "DN00B_ScrollableList", self )
	local h = 33*5-1
	dScrollList:SetSize( self:GetWide( ) - 32 - 129, h )
	dScrollList:AlignRight( 16 )
	yOffset = 16 + 24 + 8
	dScrollList:AlignTop( yOffset )
	yOffset = yOffset + h + 32
	--dScrollList:OffsetFromCenter( 0, self:GetTall( ) * -0.37 )
	dScrollList:SetListWidthMultiplier( 0.99 )
	dScrollList:DrawListBackground( 0, Color( 24, 24, 24, 128 ) )
	dScrollList:ColorizeScrollbar( Color( 205, 205, 205, 64 ), Color( 205, 205, 205, 64 ), Color( 205, 205, 205, 128 ), Color( 24, 24, 24, 128 ), true, Color( 255, 255, 255, 0 ) )
	dScrollList:SetScrollParent( )
	self.weaponList = dScrollList:GetIconLayout( )

	local dScrollList = vgui.Create( "DN00B_ScrollableList", self )
	dScrollList:SetSize( self:GetWide( ) - 32, 128 )
	--dScrollList:OffsetFromCenter( 0, self:GetTall( ) * -0.135 )
	dScrollList:AlignLeft( 16 )
	dScrollList:AlignTop( yOffset )
	yOffset = yOffset + 128 + 32
	dScrollList:SetListWidthMultiplier( .98 )
	dScrollList:DrawListBackground( 0, Color( 24, 24, 24, 128 ) )
	dScrollList:ColorizeScrollbar( Color( 205, 205, 205, 64 ), Color( 205, 205, 205, 64 ), Color( 205, 205, 205, 128 ), Color( 24, 24, 24, 128 ), true, Color( 255, 255, 255, 0 ) )
	self.favPropList = dScrollList:GetIconLayout( )

	local dScrollList = vgui.Create( "DN00B_ScrollableList", self )
	dScrollList:SetSize( self:GetWide( ) - 32, self:GetTall( ) - (yOffset + 16) )
	dScrollList:AlignLeft( 16 )
	dScrollList:AlignTop( yOffset )
	dScrollList:SetListWidthMultiplier( .98 )
	dScrollList:DrawListBackground( 0, Color( 24, 24, 24, 128 ) )
	dScrollList:ColorizeScrollbar( Color( 205, 205, 205, 64 ), Color( 205, 205, 205, 64 ), Color( 205, 205, 205, 128 ), Color( 24, 24, 24, 128 ), true, Color( 255, 255, 255, 0 ) )
	self.propList = dScrollList:GetIconLayout( )

end

function PANEL:Paint( w, h )
    draw.RoundedBox( 4, 0, 0, w, h, Color( 32, 32, 32, 245 ) )
    draw.SimpleText( "SEARCH", "N00BRP_SpawnMenu_HeaderFont", self:GetWide() - 236, 21, Color( 255, 255, 255, 128 ), TEXT_ALIGN_RIGHT )
    draw.SimpleText( "ITEM SELECTION", "N00BRP_SpawnMenu_HeaderFont", 16, 21, Color( 255, 255, 255, 128 ), TEXT_ALIGN_LEFT)
    draw.SimpleText( "FAVORITE PROPS", "N00BRP_SpawnMenu_HeaderFont", 16, 222, Color( 255, 255, 255, 128 ), TEXT_ALIGN_LEFT )
    draw.SimpleText( "ALL PROPS", "N00BRP_SpawnMenu_HeaderFont", 16, 245 + 128 + 8, Color( 255, 255, 255, 128 ), TEXT_ALIGN_LEFT)
end

function PANEL:GeneratePropList( )
	local propList = self.propList
	propList:Clear( )
	local sortedTable = { }
	for index, value in pairs ( noob_ValidPropList ) do
		table.insert( sortedTable, { mdl = index, price = value } )
	end
	table.SortByMember( sortedTable, "price", true )
	for index, prop in ipairs ( sortedTable ) do
		local spawnIcon = propList:Add( "SpawnIcon" )
		spawnIcon:SetModel( prop.mdl )
		spawnIcon:SetToolTip( prop.mdl .. "\nPrice: $" .. prop.price )
		spawnIcon.OnMousePressed = function( btnPanel, btn )
			if ( btn == LEFT_CLICK ) then
				LocalPlayer( ):ConCommand( "gm_spawn " .. prop.mdl )
			elseif ( btn == RIGHT_CLICK ) then
				self:AddToFavorites( prop.mdl )
			end
		end
	end
end

function PANEL:GenerateFavoritesList( )
	local favPropList = self.favPropList
	favPropList:Clear( )
	LocalPlayer( ).favoriteProps = util.JSONToTable( file.Read( "noobonic/favoriteprops.txt", "DATA" ) or "" ) or { }
	for index, mdl in ipairs ( LocalPlayer( ).favoriteProps ) do
		local favProp = favPropList:Add( "SpawnIcon" )
		favProp:SetModel( mdl )
		favProp.OnMousePressed = function( btnPnl, btn )
			if ( btn == LEFT_CLICK ) then
				LocalPlayer( ):ConCommand( "gm_spawn " .. mdl )
			elseif ( btn == RIGHT_CLICK ) then
				self:RemoveFromFavorites( mdl )
			end
		end
	end
	
end

function PANEL:AddToFavorites( val )
	local valExists = false
	for index, mdl in ipairs ( LocalPlayer( ).favoriteProps ) do
		if ( mdl == val ) then
			valExists = true
			break
		end
	end
	if not ( valExists ) then
		table.insert( LocalPlayer( ).favoriteProps, val )
		file.Write( "noobonic/favoriteprops.txt", util.TableToJSON( LocalPlayer( ).favoriteProps ) )
	end
	self:GenerateFavoritesList( )
end

function PANEL:RemoveFromFavorites( val )
	for index, mdl in ipairs ( LocalPlayer( ).favoriteProps ) do
		if ( mdl == val ) then
			table.remove( LocalPlayer( ).favoriteProps, index )
			file.Write( "noobonic/favoriteprops.txt", util.TableToJSON( LocalPlayer( ).favoriteProps ) )
			break
		end
	end
	self:GenerateFavoritesList( )
end

function PANEL:GenerateWeaponSelection( )
	local weaponList = self.weaponList
	self.weaponList:Clear( )
	local itmAmount = 0
	if ( LocalPlayer( ):getDarkRPVar( "PermWeapons" ) ) then
		local sortedPermWeaponList = { }
		for index, wep in pairs ( LocalPlayer( ):getDarkRPVar( "PermWeapons" ) ) do
			if not ( noob_WeaponIndex:Get( wep.class ) ) then continue end
			local wepTable = noob_WeaponIndex:Get( wep.class )
			table.insert( sortedPermWeaponList, { class = wep.class, name = wepTable.name, category = wepTable.category } )
		end
		table.SortByMember( sortedPermWeaponList, "name", true )
		for index, wep in ipairs ( sortedPermWeaponList ) do
			if ( LocalPlayer( ):GetObserverMode( ) ~= OBS_MODE_NONE ) then continue end
			if not ( noob_WeaponIndex:Get( wep.class ) ) then continue end
			if ( LocalPlayer( ):IsCivilian( ) and !( noob_WeaponIndex:Get( wep.class ).citizen ) ) then continue end
			if ( LocalPlayer( ):IsCrab( ) and !( noob_WeaponIndex:Get( wep.class ).crab ) ) then continue end
			if ( LocalPlayer( ):Team( ) == TEAM_ZOMBIE && wep.class ~= "weapon_crowbar" ) then continue end
			if ( self.currentCategory and wep.category ~= self.currentCategory ) then continue end
			local searchText = self.searchText
			if ( isstring( searchText ) ) then searchText = string.lower( searchText ) end
			local wepClass, wepName = string.lower( wep.class ), string.lower( wep.name )
			if ( searchText and ( !string.find( wepClass, searchText ) and !string.find( wepName, searchText ) ) ) then continue end
			local listItem = weaponList:Add( "DN00B_ColoredButton" )
			listItem:SetSize( weaponList:GetWide( ), 32 )
			listItem:SetText( noob_WeaponIndex:Get( wep.class ).name )
			listItem:SetTextFont( "N00BRP_SpawnMenu_SubHeaderFont" )
			listItem:SetTextColor( Color( 48, 48, 48, 255 ) )
			listItem:SetButtonColor( Color( 245, 245, 245, 255 ) )
			listItem:SetHoverColor( Color( 184, 214, 231, 255 ) )
			listItem:SetTextAlign( TEXT_ALIGN_LEFT )
			listItem.OnMousePressed = function( btnPnl, btn )
				LocalPlayer( ):ConCommand( "rp_selectwep " .. wep.class )
			end
			itmAmount = itmAmount + 1
		end
	end
	if not ( LocalPlayer( ).tempWeapons ) then return end
	local sortedTempWeaponList = { }
	for index, wep in pairs ( LocalPlayer( ).tempWeapons ) do
		if not ( noob_WeaponIndex:Get( wep ) ) then continue end
		table.insert( sortedTempWeaponList, wep )
	end
	table.sort( sortedTempWeaponList, function( a, b ) return a < b end )
	for index, tempWep in ipairs ( sortedTempWeaponList ) do
		if ( LocalPlayer( ):GetObserverMode( ) ~= OBS_MODE_NONE ) then continue end
		if not ( noob_WeaponIndex:Get( tempWep ) ) then continue end
		if ( LocalPlayer( ):IsCivilian( ) and !( noob_WeaponIndex:Get( tempWep ).citizen ) ) then continue end
		if ( LocalPlayer( ):IsCrab( ) and !( noob_WeaponIndex:Get( tempWep ).crab ) ) then continue end
		if ( LocalPlayer( ):Team( ) == TEAM_ZOMBIE && tempWep ~= "weapon_crowbar" ) then continue end
		local category = noob_WeaponIndex:Get( tempWep ).category
		if ( self.currentCategory and category ~= self.currentCategory ) then continue end
		local searchText = self.searchText
		if ( isstring( searchText ) ) then searchText = string.lower( searchText ) end
		local wepClass, wepName = string.lower( tempWep ), string.lower( noob_WeaponIndex:Get( tempWep ).name )
		if ( searchText and ( !string.find( wepClass, searchText ) and !string.find( wepName, searchText ) ) ) then continue end
		local listItem = weaponList:Add( "DN00B_ColoredButton" )
		listItem:SetSize( weaponList:GetWide( ), 32 )
		listItem:SetText( noob_WeaponIndex:Get( tempWep ).name )
		listItem:SetTextFont( "N00BRP_SpawnMenu_SubHeaderFont" )
		listItem:SetTextColor( Color( 48, 48, 48, 255 ) )
		listItem:SetButtonColor( Color( 225, 225, 225, 255 ) )
		listItem:SetHoverColor( Color( 184, 214, 231, 255 ) )
		listItem:SetTextAlign( TEXT_ALIGN_LEFT )
		listItem.OnMousePressed = function( btnPnl, btn )
			LocalPlayer( ):ConCommand( "rp_selectwep " .. tempWep )
		end
		itmAmount = itmAmount + 1 
	end
	local scrollHeight = itmAmount * ( self:GetTall( ) * 0.0225 )
	if ( self.weaponList.scrollParent.VBar:GetScroll( ) > scrollHeight ) then
		self.weaponList.scrollParent.VBar:SetScroll( scrollHeight * 0.85 )
	end
end
vgui.Register( "n00b_SpawnMenu", PANEL, "DFrame" )

local function OnOpenCustomSpawnMenu( )
	timer.Simple( 0.1, function( )
		if ( ValidPanel( g_SpawnMenu ) and ValidPanel( g_SpawnMenu:GetChildren( )[3] ) ) then
			local propMenu = g_SpawnMenu:GetChildren( )[3]
			if ( propMenu:IsVisible( ) ) then
				propMenu:SetVisible( false )
			end
		end
	end )
	if ( ValidPanel( LocalPlayer( ).noob_SpawnMenu ) ) then
		if not ( LocalPlayer( ).noob_SpawnMenu:IsVisible( ) ) then
			LocalPlayer( ).noob_SpawnMenu:SetVisible( true )
			LocalPlayer( ).noob_SpawnMenu:GenerateLists( )
		else
			LocalPlayer( ).noob_SpawnMenu:SetVisible( false )
		end
	else
		LocalPlayer( ).noob_SpawnMenu = vgui.Create( "n00b_SpawnMenu" )
	end
end
hook.Add( "OnSpawnMenuOpen", "N00BRP_OnOpenCustomSpawnMenu_OnSpawnMenuOpen", OnOpenCustomSpawnMenu )

local function OnCloseCustomSpawnMenu( )
	if ( ValidPanel( LocalPlayer( ).noob_SpawnMenu ) ) then
		if ( LocalPlayer( ).noob_SpawnMenu:IsVisible( ) ) then
			--noob_SpawnMenu:SetVisible( false )
			if ( ValidPanel( LocalPlayer( ).noob_SpawnMenu.searchBox ) ) then
				LocalPlayer( ).noob_SpawnMenu.searchBox:FocusNext( )
			end
			LocalPlayer( ).noob_SpawnMenu:SetVisible( false )
		end
	end
end
hook.Add( "OnSpawnMenuClose", "N00BRP_OnCloseCustomSpawnMenu_OnSpawnMenuClose", OnCloseCustomSpawnMenu )
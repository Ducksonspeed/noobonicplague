local herbIconTable = {
  ["Burdock Root"] = { color = Color( 255, 255, 255 ), mdl = "models/props/de_inferno/largebush04.mdl" },
  ["Gingko Biloba"] = { color = Color( 255, 255, 255 ), mdl = "models/props/de_inferno/largebush03.mdl" },
  ["Valerian Root"] = { color = Color( 255, 255, 255 ), mdl = "models/props/de_inferno/largebush06.mdl" },
  ["Coral Fungus"] = { color = Color( 200, 100, 100 ), mdl = "models/props/jeezy/mushroom/mushroom.mdl" },
  ["Red Reishi"] = { color = Color( 100, 100, 200 ), mdl = "models/props/jeezy/mushroom/mushroom.mdl" },
  ["Psilocybe Cubensis"] = { color = Color( 100, 200, 100 ), mdl = "models/props/jeezy/mushroom/mushroom.mdl" }
}

PANEL = { }

function PANEL:Init()
    self:SetSize( ScrW( ) * 0.3, ScrH( ) * 0.6 )
    self:Center( )
    gui.EnableScreenClicker( true )
    self.herbWangs = { }
    self.herbIcons = { }
    self:SetupHerbIcons( )
    self:SetupButtons( )
    self:MakePopup( )
    self:SetTitle( "" )
    self:ShowCloseButton( false )
    self:SetDraggable( false )
end

function PANEL:GenerateHerbIcon( herbType, worth )
  local dHerbIcon = vgui.Create( "DN00B_ModelPanelPlus", self )
  dHerbIcon:ModifySize( self:GetWide( ) * 0.3, self:GetTall( ) * 0.125 )
  dHerbIcon:LoadModel( herbIconTable[herbType].mdl )
  dHerbIcon:SetModelFOV( 45 )
  dHerbIcon.dModelPanel:SetColor( herbIconTable[herbType].color )
  dHerbIcon:EnableHoverSpinning( 1 )
  dHerbIcon:SetHoverVariable( worth )
  local oldCursorEntered = dHerbIcon.dModelPanel.OnCursorEntered
  dHerbIcon.dModelPanel.OnCursorEntered = function( pnl )
     local currentHerbs = LocalPlayer( ).herbTable or { }
     LocalPlayer( ).dHerbsMenuHerbAmount = currentHerbs[herbType] or 0
     oldCursorEntered( pnl )
  end
  local oldCursorExited = dHerbIcon.dModelPanel.OnCursorExited
  dHerbIcon.dModelPanel.OnCursorExited = function( pnl )
     LocalPlayer( ).dHerbsMenuHerbAmount = 0
     oldCursorExited( pnl )
  end
  dHerbIcon:SetModelPanelBG( Color( 0, 118, 91, 100 ) )
  table.insert( self.herbIcons, dHerbIcon )
  return dHerbIcon
end

function PANEL:GetValueTable( )
	local valTable = { }
	for index, wang in ipairs ( self.herbWangs ) do
		local val = tonumber( wang:GetValue( ) ) or 0
		table.insert( valTable, val )
	end
	return valTable
end

function PANEL:SetupButtons( )
    local sellButton = vgui.Create( "DN00B_ColoredButton", self )
    sellButton:SetSize( self:GetWide( ) * 0.285, self:GetTall( ) * 0.05 )
    sellButton:SetText( "Sell" )
    sellButton:SetButtonColor( Color( 22, 160, 133, 180 ) )
    sellButton:SetTextFont( "N00BRP_GemsMenu_SmallButtonFont" )
    sellButton:SetTextColor( Color( 255, 255, 255, 255 ) )
    sellButton:SetRoundness( 4 )
    sellButton:AlignRight( self:GetWide( ) * 0.025 )
    sellButton:AlignTop( self:GetTall( ) * 0.07 )
    sellButton.OnMousePressed = function( pnl, btn )
       local valTbl = self:GetValueTable( )
       for index, val in ipairs( valTbl ) do
       	   RunConsoleCommand( "rp_sellherb", index, val )
       end
       self:Remove( )
    end
    local currentHerbs = LocalPlayer( ).herbTable or { }
    local herbTranslationTable = { [1] = "Burdock Root", [2] = "Gingko Biloba", [3] = "Valerian Root", [4] = "Coral Fungus", [5] = "Red Reishi", [6] = "Psilocybe Cubensis" }
    local sellAllButton = vgui.Create( "DN00B_ColoredButton", self )
    sellAllButton:SetSize( self:GetWide( ) * 0.285, self:GetTall( ) * 0.05 )
    sellAllButton:SetText( "Sell All" )
    sellAllButton:SetButtonColor( Color( 22, 160, 133, 180 ) )
    sellAllButton:SetTextFont( "N00BRP_GemsMenu_SmallButtonFont" )
    sellAllButton:SetTextColor( Color( 255, 255, 255, 255 ) )
    sellAllButton:SetRoundness( 4 )
    sellAllButton:AlignRight( self:GetWide( ) * 0.025 )
    sellAllButton:AlignTop( self:GetTall( ) * 0.14 )
    sellAllButton.OnMousePressed = function( pnl, btn )
       local valTbl = self:GetValueTable( )
       for index, val in ipairs( valTbl ) do
           local herbName = herbTranslationTable[index]
           local herbAmount = currentHerbs[herbName] or 0
           if ( herbName == "Valerian Root" or herbName == "Psilocybe Cubensis" ) then continue end
           RunConsoleCommand( "rp_sellherb", index, herbAmount )
       end
       self:Remove( )
    end
    local closeButton = vgui.Create( "DN00B_ColoredButton", self )
    closeButton:SetSize( self:GetWide( ) * 0.285, self:GetTall( ) * 0.05 )
    closeButton:SetText( "Close" )
    closeButton:SetButtonColor( Color( 22, 160, 133, 180 ) )
    closeButton:SetTextFont( "N00BRP_GemsMenu_SmallButtonFont" )
    closeButton:SetTextColor( Color( 255, 255, 255, 255 ) )
    closeButton:SetRoundness( 4 )
    closeButton:AlignRight( self:GetWide( ) * 0.025 )
    closeButton:AlignTop( self:GetTall( ) * 0.21 )
    closeButton.OnMousePressed = function( pnl, btn )
    	self:Remove( )
    end
end

function PANEL:SetupHerbIcons( )
  local leftAlign = self:GetWide( ) * 0.4
  local iconSpacing = self:GetTall( ) * 0.075
  local iconMulti = self:GetTall( ) * 0.04
  local burdockIcon = self:GenerateHerbIcon( "Burdock Root", 50 )
  burdockIcon:AlignLeft( self:GetWide( ) * 0.05 )
  burdockIcon:AlignTop( iconSpacing )
  local burdockWang = vgui.Create( "DN00B_ColoredNumberWang", self )
  burdockWang:AlignLeft( leftAlign )
  burdockWang:AlignTop( iconSpacing + iconMulti )
  table.insert( self.herbWangs, burdockWang )
  local gingkoIcon = self:GenerateHerbIcon( "Gingko Biloba", 100 )
  gingkoIcon:AlignLeft( self:GetWide( ) * 0.05 )
  gingkoIcon:AlignTop( self:GetTall( ) * 0.15 + iconSpacing )
  local gingkoWang = vgui.Create( "DN00B_ColoredNumberWang", self )
  gingkoWang:AlignLeft( leftAlign )
  gingkoWang:AlignTop( iconSpacing + ( ( self:GetTall( ) * 0.15 ) ) + iconMulti )
  table.insert( self.herbWangs, gingkoWang )
  local  valerianIcon = self:GenerateHerbIcon( "Valerian Root", 10000 )
  valerianIcon:AlignLeft( self:GetWide( ) * 0.05 )
  valerianIcon:AlignTop( self:GetTall( ) * 0.30 + iconSpacing )
  local valerianWang = vgui.Create( "DN00B_ColoredNumberWang", self )
  valerianWang:AlignLeft( leftAlign )
  valerianWang:AlignTop( iconSpacing + ( ( self:GetTall( ) * 0.15 ) * 2 ) + iconMulti )
  table.insert( self.herbWangs, valerianWang )
  local coralIcon = self:GenerateHerbIcon( "Coral Fungus", 35 )
  coralIcon:AlignLeft( self:GetWide( ) * 0.05 )
  coralIcon:AlignTop( self:GetTall( ) * 0.45 + iconSpacing )
  local coralWang = vgui.Create( "DN00B_ColoredNumberWang", self )
  coralWang:AlignLeft( leftAlign )
  coralWang:AlignTop( iconSpacing + ( ( self:GetTall( ) * 0.15 ) * 3 ) + iconMulti )
  table.insert( self.herbWangs, coralWang )
  local reishiIcon = self:GenerateHerbIcon( "Red Reishi", 85 )
  reishiIcon:AlignLeft( self:GetWide( ) * 0.05 )
  reishiIcon:AlignTop( self:GetTall( ) * 0.6 + iconSpacing )
  local reishiWang = vgui.Create( "DN00B_ColoredNumberWang", self )
  reishiWang:AlignLeft( leftAlign )
  reishiWang:AlignTop( iconSpacing + ( ( self:GetTall( ) * 0.15 ) * 4 ) + iconMulti )
  table.insert( self.herbWangs, reishiWang )
  local cubensisIcon = self:GenerateHerbIcon( "Psilocybe Cubensis", 50000 )
  cubensisIcon:AlignLeft( self:GetWide( ) * 0.05 )
  cubensisIcon:AlignTop( self:GetTall( ) * 0.75 + iconSpacing )
  local cubensisWang = vgui.Create( "DN00B_ColoredNumberWang", self )
  cubensisWang:AlignLeft( leftAlign )
  cubensisWang:AlignTop( iconSpacing + ( ( self:GetTall( ) * 0.15 ) * 5 ) + iconMulti )
  table.insert( self.herbWangs, cubensisWang )
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, Color( 44, 62, 80, 255 ) )
    local hoverVar = LocalPlayer( ).dModelPanelPlusHoverVariable
    local valTable = self:GetValueTable( )
    local HerbWorth = SHNOOB_VARS:Get( "HerbWorth" );
    local totalWorth = ( valTable[1] * HerbWorth[ 1 ] ) + ( valTable[2] * HerbWorth[ 2 ] ) + ( valTable[3] * HerbWorth[ 3 ] ) + ( valTable[4] * HerbWorth[ 4 ] ) + ( valTable[5] * HerbWorth[ 5 ] ) + ( valTable[6] * HerbWorth[ 6 ] );
    draw.SimpleText( "Total Worth", "N00BRP_GemsMenu_SmallButtonFont", w * 0.83, h * 0.67, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
    draw.RoundedBox( 4, w * 0.69, h * 0.715, w * 0.275, h * 0.035, Color( 22, 160, 133 ) )
    draw.SimpleText( "$" .. string.Comma( totalWorth ), "N00BRP_GemsMenu_BoldButtonFont", w * 0.83, h * 0.715, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
    draw.SimpleText( "Amount", "N00BRP_GemsMenu_SmallButtonFont", w * 0.83, h * 0.77, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
    draw.RoundedBox( 4, w * 0.69, h * 0.815, w * 0.275, h * 0.035, Color( 22, 160, 133 ) )
    draw.SimpleText( string.Comma( LocalPlayer( ).dHerbsMenuHerbAmount or 0 ), "N00BRP_GemsMenu_SmallButtonFont", w * 0.83, h * 0.815, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
    draw.SimpleText( "Worth", "N00BRP_GemsMenu_SmallButtonFont", w * 0.83, h * 0.88, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
    draw.RoundedBox( 4, w * 0.69, h * 0.92, w * 0.275, h * 0.035, Color( 22, 160, 133 ) )
    draw.SimpleText( "$" .. string.Comma( hoverVar or 0 ), "N00BRP_GemsMenu_BoldButtonFont", w * 0.83, h * 0.92, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
end

vgui.Register( "N00BRP_HerbsMenu", PANEL, "DFrame" )

local function PlayerHerbMenu( ply )
  if not ( ValidPanel( LocalPlayer( ).herbsMenu ) ) then
    LocalPlayer( ).herbsMenu = vgui.Create( "N00BRP_HerbsMenu" )
  else
    LocalPlayer( ).herbsMenu:Remove( )
    gui.EnableScreenClicker( false )
  end
end
concommand.Add( "rp_herbsmenu", PlayerHerbMenu )
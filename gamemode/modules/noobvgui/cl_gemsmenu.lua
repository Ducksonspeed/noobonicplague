surface.CreateFont( "N00BRP_GemsMenu_SmallButtonFont", {
  font = "Lobster",
  size = ScreenScale( 8 ),
  weight = 750,
  blursize = 0,
} )

surface.CreateFont( "N00BRP_GemsMenu_BoldButtonFont", {
  font = "Lobster",
  size = ScreenScale( 9 ),
  weight = 850,
  blursize = 0,
} )

local gemIconTable = {
  ["Rocks"] = { color = Color( 255, 255, 255 ), mat = "" },
  ["Granite"] = { color = Color( 150, 150, 150 ), mat = "" },
  ["Shale"] = { color = Color( 75, 75, 75 ), mat = "" },
  ["Emeralds"] = { color = Color( 0, 255, 0 ), mat = "models/shiny" },
  ["Rubies"] = { color = Color( 255, 0, 0 ), mat = "models/shiny" },
  ["Sapphires"] = { color = Color( 0, 0, 255 ), mat = "models/shiny" },
  ["Obsidians"] = { color = Color( 25, 25, 25 ), mat = "models/shiny" },
  ["Diamonds"] = { color = Color( 255, 255, 255, 100 ), mat = "models/shiny" }
}

PANEL = { }

function PANEL:Init()
    self:SetSize( ScrW( ) * 0.3, ScrH( ) * 0.6 )
    self:Center( )
    gui.EnableScreenClicker( true )
    self.gemWangs = { }
    self.gemIcons = { }
    self:SetupGemIcons( )
    self:SetupButtons( )
    self:MakePopup( )
    self:SetTitle( "" )
    self:ShowCloseButton( false )
    self:SetDraggable( false )
end

function PANEL:GenerateGemIcon( gemType, worth )
  local dGemIcon = vgui.Create( "DN00B_ModelPanelPlus", self )
  dGemIcon:ModifySize( self:GetWide( ) * 0.3, self:GetTall( ) * 0.1 )
  dGemIcon:LoadModel( "models/props_junk/rock001a.mdl" )
  dGemIcon:SetModelFOV( 45 )
  dGemIcon.dModelPanel:SetColor( gemIconTable[gemType].color )
  dGemIcon:SetModelMaterial( gemIconTable[gemType].mat )
  dGemIcon:EnableHoverSpinning( 1 )
  dGemIcon:SetHoverVariable( worth )
  local oldCursorEntered = dGemIcon.dModelPanel.OnCursorEntered
  dGemIcon.dModelPanel.OnCursorEntered = function( pnl )
     local currentGems = LocalPlayer( ).gemTable or { }
     LocalPlayer( ).dGemsMenuGemAmount = currentGems[gemType] or 0
     oldCursorEntered( pnl )
  end
  local oldCursorExited = dGemIcon.dModelPanel.OnCursorExited
  dGemIcon.dModelPanel.OnCursorExited = function( pnl )
     LocalPlayer( ).dGemsMenuGemAmount = 0
     oldCursorExited( pnl )
  end
  dGemIcon:SetModelPanelBG( Color( 0, 118, 91, 100 ) )
  table.insert( self.gemIcons, dGemIcon )
  return dGemIcon
end

function PANEL:GetValueTable( )
	local valTable = { }
	for index, wang in ipairs ( self.gemWangs ) do
		local val = tonumber( wang:GetValue( ) ) or 0
		table.insert( valTable, val )
	end
	return valTable
end

function PANEL:SetupButtons( )
	local combineButton = vgui.Create( "DN00B_ColoredButton", self )
    combineButton:SetSize( self:GetWide( ) * 0.285, self:GetTall( ) * 0.05 )
    combineButton:SetText( "Combine" )
    combineButton:SetButtonColor( Color( 22, 160, 133, 180 ) )
    combineButton:SetTextFont( "N00BRP_GemsMenu_SmallButtonFont" )
    combineButton:SetTextColor( Color( 255, 255, 255, 255 ) )
    combineButton:SetRoundness( 4 )
    combineButton:AlignRight( self:GetWide( ) * 0.025 )
    combineButton:AlignTop( self:GetTall( ) * 0.06 )
    combineButton.OnMousePressed = function( pnl, btn )
    	local valTbl = self:GetValueTable( )
    	RunConsoleCommand( "rp_combinegems", valTbl[1], valTbl[2], valTbl[3], valTbl[4], valTbl[5], valTbl[6], valTbl[7], valTbl[8] )
    	self:Remove( )
    end
    local sellButton = vgui.Create( "DN00B_ColoredButton", self )
    sellButton:SetSize( self:GetWide( ) * 0.285, self:GetTall( ) * 0.05 )
    sellButton:SetText( "Sell" )
    sellButton:SetButtonColor( Color( 22, 160, 133, 180 ) )
    sellButton:SetTextFont( "N00BRP_GemsMenu_SmallButtonFont" )
    sellButton:SetTextColor( Color( 255, 255, 255, 255 ) )
    sellButton:SetRoundness( 4 )
    sellButton:AlignRight( self:GetWide( ) * 0.025 )
    sellButton:AlignTop( self:GetTall( ) * 0.12 )
    sellButton.OnMousePressed = function( pnl, btn )
       local valTbl = self:GetValueTable( )
       for index, val in ipairs( valTbl ) do

       	   RunConsoleCommand( "rp_sellgem", index, val )
       end
       self:Remove( )
    end
    local currentGems = LocalPlayer( ).gemTable or { }
    local gemTranslationTable = { [1] = "Rocks", [2] = "Granite", [3] = "Shale", [4] = "Emeralds", [5] = "Rubies", [6] = "Sapphires", [7] = "Obsidians", [8] = "Diamonds" }
    local sellAllButton = vgui.Create( "DN00B_ColoredButton", self )
    sellAllButton:SetSize( self:GetWide( ) * 0.285, self:GetTall( ) * 0.05 )
    sellAllButton:SetText( "Sell All" )
    sellAllButton:SetButtonColor( Color( 22, 160, 133, 180 ) )
    sellAllButton:SetTextFont( "N00BRP_GemsMenu_SmallButtonFont" )
    sellAllButton:SetTextColor( Color( 255, 255, 255, 255 ) )
    sellAllButton:SetRoundness( 4 )
    sellAllButton:AlignRight( self:GetWide( ) * 0.025 )
    sellAllButton:AlignTop( self:GetTall( ) * 0.18 )
    sellAllButton.OnMousePressed = function( pnl, btn )
       local valTbl = self:GetValueTable( )
       for index, val in ipairs( valTbl ) do
           local gemName = gemTranslationTable[index]
           local gemCount = currentGems[gemName] or 0
           if ( gemName == "Sapphires" or gemName == "Obsidians" or gemName == "Diamonds" ) then continue end
           RunConsoleCommand( "rp_sellgem", index, gemCount )
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
    closeButton:AlignTop( self:GetTall( ) * 0.24 )
    closeButton.OnMousePressed = function( pnl, btn )
    	self:Remove( )
    end
end

function PANEL:SetupGemIcons( )
  local gemWorth = SHNOOB_VARS:Get( "GemWorth" )
  local leftAlign = self:GetWide( ) * 0.4
  local rockIcon = self:GenerateGemIcon( "Rocks", gemWorth[1] )
  rockIcon:AlignLeft( self:GetWide( ) * 0.05 )
  rockIcon:AlignTop( self:GetTall( ) * 0.025 )
  local rockWang = vgui.Create( "DN00B_ColoredNumberWang", self )
  rockWang:AlignLeft( leftAlign )
  rockWang:AlignTop( self:GetTall( ) * 0.06 )
  table.insert( self.gemWangs, rockWang )
  local graniteIcon = self:GenerateGemIcon( "Granite", gemWorth[2] )
  graniteIcon:AlignLeft( self:GetWide( ) * 0.05 )
  graniteIcon:AlignTop( self:GetTall( ) * 0.145 )
  local graniteWang = vgui.Create( "DN00B_ColoredNumberWang", self )
  graniteWang:AlignLeft( leftAlign )
  graniteWang:AlignTop( self:GetTall( ) * 0.180 )
  table.insert( self.gemWangs, graniteWang )
  local shaleIcon = self:GenerateGemIcon( "Shale", gemWorth[3] )
  shaleIcon:AlignLeft( self:GetWide( ) * 0.05 )
  shaleIcon:AlignTop( self:GetTall( ) * 0.270 )
  local shaleWang = vgui.Create( "DN00B_ColoredNumberWang", self )
  shaleWang:AlignLeft( leftAlign )
  shaleWang:AlignTop( self:GetTall( ) * 0.305 )
  table.insert( self.gemWangs, shaleWang )
  local emeraldIcon = self:GenerateGemIcon( "Emeralds", gemWorth[4] )
  emeraldIcon:AlignLeft( self:GetWide( ) * 0.05 )
  emeraldIcon:AlignTop( self:GetTall( ) * 0.395 )
  local emeraldWang = vgui.Create( "DN00B_ColoredNumberWang", self )
  emeraldWang:AlignLeft( leftAlign )
  emeraldWang:AlignTop( self:GetTall( ) * 0.430 )
  table.insert( self.gemWangs, emeraldWang )
  local rubyIcon = self:GenerateGemIcon( "Rubies", gemWorth[5] )
  rubyIcon:AlignLeft( self:GetWide( ) * 0.05 )
  rubyIcon:AlignTop( self:GetTall( ) * 0.520 )
  local rubyWang = vgui.Create( "DN00B_ColoredNumberWang", self )
  rubyWang:AlignLeft( leftAlign )
  rubyWang:AlignTop( self:GetTall( ) * 0.555 )
  table.insert( self.gemWangs, rubyWang )
  local sapphireIcon = self:GenerateGemIcon( "Sapphires", gemWorth[6] )
  sapphireIcon:AlignLeft( self:GetWide( ) * 0.05 )
  sapphireIcon:AlignTop( self:GetTall( ) * 0.645 )
  local sapphireWang = vgui.Create( "DN00B_ColoredNumberWang", self )
  sapphireWang:AlignLeft( leftAlign )
  sapphireWang:AlignTop( self:GetTall( ) * 0.680 )
  table.insert( self.gemWangs, sapphireWang )
  local obsidianIcon = self:GenerateGemIcon( "Obsidians", gemWorth[7] )
  obsidianIcon:AlignLeft( self:GetWide( ) * 0.05 )
  obsidianIcon:AlignTop( self:GetTall( ) * 0.760 )
  local obsidianWang = vgui.Create( "DN00B_ColoredNumberWang", self )
  obsidianWang:AlignLeft( leftAlign )
  obsidianWang:AlignTop( self:GetTall( ) * 0.795 )
  table.insert( self.gemWangs, obsidianWang )
  local diamondIcon = self:GenerateGemIcon( "Diamonds", gemWorth[8] )
  diamondIcon:AlignLeft( self:GetWide( ) * 0.05 )
  diamondIcon:AlignTop( self:GetTall( ) * 0.880 )
  local diamondWang = vgui.Create( "DN00B_ColoredNumberWang", self )
  diamondWang:AlignLeft( leftAlign )
  diamondWang:AlignTop( self:GetTall( ) * 0.915 )
  table.insert( self.gemWangs, diamondWang )
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, Color( 44, 62, 80, 255 ) )
    local hoverVar = LocalPlayer( ).dModelPanelPlusHoverVariable
    local valTable = self:GetValueTable( )
    local gemWorth = SHNOOB_VARS:Get( "GemWorth" )
    local totalWorth = ( valTable[1] * gemWorth[1] ) + ( valTable[2] * gemWorth[2] ) + ( valTable[3] * gemWorth[3] ) + ( valTable[4] * gemWorth[4] ) + ( valTable[5] * gemWorth[5] ) + ( valTable[6] * gemWorth[6] ) + ( valTable[7] * gemWorth[7] ) + ( valTable[8] * gemWorth[8] )
    draw.SimpleText( "Total Worth", "N00BRP_GemsMenu_SmallButtonFont", w * 0.83, h * 0.67, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
    draw.RoundedBox( 4, w * 0.69, h * 0.715, w * 0.275, h * 0.035, Color( 22, 160, 133 ) )
    draw.SimpleText( "$" .. string.Comma( totalWorth ), "N00BRP_GemsMenu_BoldButtonFont", w * 0.83, h * 0.715, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
    draw.SimpleText( "Amount", "N00BRP_GemsMenu_SmallButtonFont", w * 0.83, h * 0.77, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
    draw.RoundedBox( 4, w * 0.69, h * 0.815, w * 0.275, h * 0.035, Color( 22, 160, 133 ) )
    draw.SimpleText( string.Comma( LocalPlayer( ).dGemsMenuGemAmount or 0 ), "N00BRP_GemsMenu_SmallButtonFont", w * 0.83, h * 0.815, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
    draw.SimpleText( "Worth", "N00BRP_GemsMenu_SmallButtonFont", w * 0.83, h * 0.88, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
    draw.RoundedBox( 4, w * 0.69, h * 0.92, w * 0.275, h * 0.035, Color( 22, 160, 133 ) )
    draw.SimpleText( "$" .. string.Comma( hoverVar or 0 ), "N00BRP_GemsMenu_BoldButtonFont", w * 0.83, h * 0.92, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
end

vgui.Register( "N00BRP_GemsMenu", PANEL, "DFrame" )

local function PlayerGemsMenu( ply )
  if not ( ValidPanel( LocalPlayer( ).gemsMenu ) ) then
    LocalPlayer( ).gemsMenu = vgui.Create( "N00BRP_GemsMenu" )
  else
    LocalPlayer( ).gemsMenu:Remove( )
    gui.EnableScreenClicker( false )
  end
end
concommand.Add( "rp_gemsmenu", PlayerGemsMenu )
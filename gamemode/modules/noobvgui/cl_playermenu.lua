surface.CreateFont( "N00BRP_PlayerMenu_ButtonFont", {
	font = "Arial",
	size = ScreenScale( 16 ),
	weight = 500,
} )

surface.CreateFont( "N00BRP_PlayerMenu_LargeFont", {
	font = "Arial",
	size = ScreenScale( 22 ),
	weight = 600,
} )

surface.CreateFont( "N00BRP_PlayerMenu_MediumFont", {
	font = "Arial",
	size = ScreenScale( 20 ),
	weight = 400,
} )

surface.CreateFont( "N00BRP_PlayerMenu_SmallFont", {
	font = "Arial",
	size = ScreenScale( 18 ),
	weight = 400,
} )

surface.CreateFont( "N00BRP_PlayerMenu_TinyFont", {
	font = "Arial",
	size = ScreenScale( 11 ),
	weight = 400,
} )

surface.CreateFont( "N00BRP_PlayerMenu_SkillsFont", {
	font = "Arial",
	size = ScreenScale( 14 ),
	weight = 500,
} )

local closeButtonColor = Color( 175, 45, 45 )
local upperPanelColor = Color( 25, 25, 25 )
local leftPanelColor = Color( 25, 25, 25 )
local bottomRightPanelColor = Color( 193, 204, 202 )
local sideButtonColor = Color( 192, 204, 202 )
local mainTextColor = Color( 255, 255, 255 )
local alchemyPotionTextOutlineColor = Color( 45, 45, 175 )
local itemBGColor = Color( 82, 127, 121, 100 )
local alchemyBGColor = Color( 162, 174, 172 )
local craftButtonColor = Color( 1, 152, 117 )
local requiredLevelTextColor = Color( 175, 45, 45 )
PANEL = {}
																
function PANEL:Init()
	gui.EnableScreenClicker( true )
    self:SetSize( ScrW( ) * 0.65, ScrH( ) * 0.5 )			
    self:Center( )
    self:SetTitle( "Player Menu" )
    self:CreateOptionsList( )
    self:CreateContentFrame( )
    self:ShowCloseButton( false )
    local dCloseButton = vgui.Create( "DN00B_ColoredButton", self )
    dCloseButton:SetSize( self:GetWide( ) * 0.08, self:GetTall( ) * 0.05 )
    dCloseButton:SetText( "X" )
    dCloseButton:SetTextFont( "N00BRP_PlayerMenu_TinyFont" )
    dCloseButton:SetButtonColor( closeButtonColor )
    dCloseButton:SetTextColor( mainTextColor )
    dCloseButton:OffsetFromCenter( self:GetWide( ) * 0.44, self:GetTall( ) * -0.4 )
    dCloseButton.OnMousePressed = function( )
    	gui.EnableScreenClicker( false )
    	self:Remove( )
    end
end

function PANEL:CreateOptionsList( )
	self.dOptionList = vgui.Create( "DN00B_ScrollableList", self )
	self.dOptionList:SetSize( self:GetWide( ) * 0.2, self:GetTall( ) * 0.8 )
	self.dOptionList:OffsetFromCenter( self:GetWide( ) * -0.3975, self:GetTall( ) * 0.0999 )
	self.dOptionList:SetListWidthMultiplier( 0.99 )
	self.dOptionList:GetIconLayout( ):SetSpaceY( 1 )
	local gemsButton = self.dOptionList:AddElement( "DN00B_ColoredButton" )
		gemsButton:SetSize( self.dOptionList:GetWide( ), self.dOptionList:GetTall( ) * 0.175 )
		gemsButton:SetText( "Gems" )
		gemsButton:SetButtonColor( sideButtonColor )
		gemsButton:SetTextColor( mainTextColor )
		gemsButton:SetTextFont( "N00BRP_PlayerMenu_ButtonFont" )
		gemsButton.OnMousePressed = function( btn )
		self:OpenGemsTab( )
	end
	local herbsButton = self.dOptionList:AddElement( "DN00B_ColoredButton" )
		herbsButton:SetSize( self.dOptionList:GetWide( ), self.dOptionList:GetTall( ) * 0.175 )
		herbsButton:SetText( "Herbs" )
		herbsButton:SetButtonColor( sideButtonColor )
		herbsButton:SetTextColor( mainTextColor )
		herbsButton:SetTextFont( "N00BRP_PlayerMenu_ButtonFont" )
		herbsButton.OnMousePressed = function( btn )
		self:OpenHerbsTab( )
	end
	local alchemyButton = self.dOptionList:AddElement( "DN00B_ColoredButton" )
		alchemyButton:SetSize( self.dOptionList:GetWide( ), self.dOptionList:GetTall( ) * 0.175 )
		alchemyButton:SetText( "Alchemy" )
		alchemyButton:SetButtonColor( sideButtonColor )
		alchemyButton:SetTextColor( mainTextColor )
		alchemyButton:SetTextFont( "N00BRP_PlayerMenu_ButtonFont" )
		alchemyButton.OnMousePressed = function( btn )
		self:OpenAlchemyTab( )
	end
	local skillsButton = self.dOptionList:AddElement( "DN00B_ColoredButton" )
		skillsButton:SetSize( self.dOptionList:GetWide( ), self.dOptionList:GetTall( ) * 0.175 )
		skillsButton:SetText( "Skills" )
		skillsButton:SetButtonColor( sideButtonColor )
		skillsButton:SetTextColor( mainTextColor )
		skillsButton:SetTextFont( "N00BRP_PlayerMenu_ButtonFont" )
		skillsButton.OnMousePressed = function( btn )
		self:OpenSkillsTab( )
	end
	local commandsButton = self.dOptionList:AddElement( "DN00B_ColoredButton" )
		commandsButton:SetSize( self.dOptionList:GetWide( ), self.dOptionList:GetTall( ) * 0.175 )
		commandsButton:SetText( "Commands" )
		commandsButton:SetButtonColor( sideButtonColor )
		commandsButton:SetTextColor( mainTextColor )
		commandsButton:SetTextFont( "N00BRP_PlayerMenu_ButtonFont" )
		commandsButton.OnMousePressed = function( btn )
		self:OpenCommandsTab( )
	end
end

function PANEL:OpenCommandsTab( )
	self:ClearContentFrame( )
	local dHTML = vgui.Create( "DHTML", self.contentFrame )
	dHTML:SetSize( self.contentFrame:GetWide( ), self.contentFrame:GetTall( ) )
	dHTML:Center( )
	dHTML:OpenURL( "http://sv.noobonicplague.com/commands/index.html" )
end

function PANEL:CreateContentFrame( )
	self.contentFrame = vgui.Create( "DFrame", self )
	self.contentFrame:SetSize( self:GetWide( ) * 0.8, self:GetTall( ) * 0.79 )
	self.contentFrame:OffsetFromCenter( self:GetWide( ) * -0.167, self:GetTall( ) * -0.4 )
	self.contentFrame:ShowCloseButton( false )
	self.contentFrame:SetTitle( "" )
	self.contentFrame.Paint = function( pnl, w, h )
		local hoverVar = LocalPlayer( ).dModelPanelPlusHoverVariable
		local darkRPGems = LocalPlayer( ).gemTable or { }
		local darkRPHerbs = LocalPlayer( ).herbTable or { }
		if ( hoverVar ) then
			if ( darkRPGems[hoverVar] ) then
				draw.SimpleTextOutlined( "Amount: " .. darkRPGems[hoverVar], "N00BRP_PlayerMenu_SmallFont", w * 0.025, h * 0.8, Color( 255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 2, Color( 75, 175, 75, 255 ) )
			elseif ( darkRPHerbs[hoverVar] ) then
				draw.SimpleTextOutlined( "Amount: " .. darkRPHerbs[hoverVar], "N00BRP_PlayerMenu_SmallFont", w * 0.025, h * 0.8, Color( 255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 2, Color( 75, 175, 75, 255 ) )
			end
			draw.SimpleTextOutlined( hoverVar, "N00BRP_PlayerMenu_SmallFont", w * 0.025, h * 0.7, Color( 255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 3, Color( 75, 75, 175, 255 ) )
		end
	end
end

function PANEL:ClearContentFrame( )
	for index, child in ipairs ( self.contentFrame:GetChildren( ) ) do
		if ( ValidPanel( child ) and child:GetClassName( ) ~= "Label" ) then
			child:Remove( )
		end
	end
end

function PANEL:OpenAlchemyTab( )
	local alchemyRecipes = NOOBRP.AlchemyRecipes
	self:ClearContentFrame( )
	local dRecipeList = vgui.Create( "DN00B_ScrollableList", self.contentFrame )
	dRecipeList:SetSize( self:GetWide( ) * 0.75, self:GetTall( ) * 0.7 )
	dRecipeList:OffsetFromCenter( self:GetWide( ) * 0, self:GetTall( ) * -0.02 )
	dRecipeList:ColorizeScrollbar( Color( 102, 102, 102 ), Color( 102, 102, 102 ), Color( 122, 122, 122 ), Color( 71, 71, 71 ) )
	dRecipeList:SetListWidthMultiplier( 0.96 )
	for index, recipe in SortedPairsByMemberValue( alchemyRecipes, "levelReq", false ) do
		local recipePanel = dRecipeList:AddElement( "DPanel" )
		recipePanel:SetSize( dRecipeList:GetWide( ), dRecipeList:GetTall( ) * 0.7 )
		recipePanel.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, alchemyBGColor )
			draw.SimpleTextOutlined( index, "N00BRP_PlayerMenu_TinyFont", w / 2, h * 0.12, Color( 255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, alchemyPotionTextOutlineColor )
			draw.SimpleText( recipe.desc,"N00BRP_PlayerMenu_TinyFont", w / 2, h * 0.19, mainTextColor, TEXT_ALIGN_CENTER )
			for index, ing in ipairs ( recipe.ingredients) do
				draw.SimpleText( ing.name .. " x " .. ing.amt, "N00BRP_PlayerMenu_TinyFont", w / 2, ( h * 0.2 ) + ( index * 28 ), mainTextColor, TEXT_ALIGN_CENTER )
			end
			if ( recipe.levelReq ) then
				draw.SimpleText( "Level " .. recipe.levelReq .. " Required", "N00BRP_PlayerMenu_TinyFont", w * 0.02, h * 0.85, requiredLevelTextColor, TEXT_ALIGN_LEFT )
			end
		end
		local craftButton = vgui.Create( "DN00B_ColoredButton", recipePanel )
		craftButton:SetSize( dRecipeList:GetWide( ) * 0.4, dRecipeList:GetTall( ) * 0.085 )
		craftButton:SetText( "CRAFT" )
		craftButton:OffsetFromCenter( 0, recipePanel:GetTall( ) * 0.4 )
		craftButton:SetButtonColor( craftButtonColor )
		craftButton:SetTextColor( mainTextColor )
		craftButton:SetTextFont( "N00BRP_PlayerMenu_TinyFont" )
		craftButton.OnMousePressed = function( btn )
			RunConsoleCommand( "rp_alchemycraft", index )
		end
	end
end

function PANEL:OpenHerbsTab( )
	self:ClearContentFrame( )
	local dBurdockIcon = vgui.Create( "DN00B_ModelPanelPlus", self.contentFrame )
	dBurdockIcon:ModifySize( self:GetWide( ) * 0.15, self:GetTall( ) * 0.2 )
	dBurdockIcon:LoadModel( "models/props/de_inferno/largebush04.mdl" )
	dBurdockIcon:OffsetFromCenter( self:GetWide( ) * -0.31, self:GetTall( ) * -0.3 )
	dBurdockIcon:SetModelFOV( 45 )
	dBurdockIcon:EnableHoverSpinning( 1 )
	dBurdockIcon:SetModelPanelBG( itemBGColor )
	dBurdockIcon:SetHoverVariable( "Burdock Root" )
	local dGingkoIcon = vgui.Create( "DN00B_ModelPanelPlus", self.contentFrame )
	dGingkoIcon:ModifySize( self:GetWide( ) * 0.15, self:GetTall( ) * 0.2 )
	dGingkoIcon:LoadModel( "models/props/de_inferno/largebush03.mdl" )
	dGingkoIcon:OffsetFromCenter( self:GetWide( ) * -0.155, self:GetTall( ) * -0.3 )
	dGingkoIcon:SetModelFOV( 45 )
	dGingkoIcon:EnableHoverSpinning( 1 )
	dGingkoIcon:SetModelPanelBG( itemBGColor )
	dGingkoIcon:SetHoverVariable( "Gingko Biloba" )
	local dValerianIcon = vgui.Create( "DN00B_ModelPanelPlus", self.contentFrame )
	dValerianIcon:ModifySize( self:GetWide( ) * 0.15, self:GetTall( ) * 0.2 )
	dValerianIcon:LoadModel( "models/props/de_inferno/largebush06.mdl" )
	dValerianIcon:OffsetFromCenter( self:GetWide( ) * 0.00, self:GetTall( ) * -0.3 )
	dValerianIcon:SetModelFOV( 45 )
	dValerianIcon:EnableHoverSpinning( 1 )
	dValerianIcon:SetModelPanelBG( itemBGColor )
	dValerianIcon:SetHoverVariable( "Valerian Root" )
	local dCoralFungusIcon = vgui.Create( "DN00B_ModelPanelPlus", self.contentFrame )
	dCoralFungusIcon:ModifySize( self:GetWide( ) * 0.15, self:GetTall( ) * 0.2 )
	dCoralFungusIcon:LoadModel( "models/props/jeezy/mushroom/mushroom.mdl" )
	dCoralFungusIcon:OffsetFromCenter( self:GetWide( ) * 0.155, self:GetTall( ) * -0.3 )
	dCoralFungusIcon:SetModelFOV( 45 )
	dCoralFungusIcon.dModelPanel:SetColor( Color( 200, 100, 100 ) )
	dCoralFungusIcon:EnableHoverSpinning( 1 )
	dCoralFungusIcon:SetModelPanelBG( itemBGColor )
	dCoralFungusIcon:SetHoverVariable( "Coral Fungus" )
	local dRedReishiIcon = vgui.Create( "DN00B_ModelPanelPlus", self.contentFrame )
	dRedReishiIcon:ModifySize( self:GetWide( ) * 0.15, self:GetTall( ) * 0.2 )
	dRedReishiIcon:LoadModel( "models/props/jeezy/mushroom/mushroom.mdl" )
	dRedReishiIcon:OffsetFromCenter( self:GetWide( ) * 0.31, self:GetTall( ) * -0.3 )
	dRedReishiIcon:SetModelFOV( 45 )
	dRedReishiIcon.dModelPanel:SetColor( Color( 100, 100, 200 ) )
	dRedReishiIcon:EnableHoverSpinning( 1 )
	dRedReishiIcon:SetModelPanelBG( itemBGColor )
	dRedReishiIcon:SetHoverVariable( "Red Reishi" )
	local dCubensisIcon = vgui.Create( "DN00B_ModelPanelPlus", self.contentFrame )
	dCubensisIcon:ModifySize( self:GetWide( ) * 0.15, self:GetTall( ) * 0.2 )
	dCubensisIcon:LoadModel( "models/props/jeezy/mushroom/mushroom.mdl" )
	dCubensisIcon:OffsetFromCenter( self:GetWide( ) * 0.31, self:GetTall( ) * -0.09 )
	dCubensisIcon:SetModelFOV( 45 )
	dCubensisIcon.dModelPanel:SetColor( Color( 100, 200, 100 ) )
	dCubensisIcon:EnableHoverSpinning( 1 )
	dCubensisIcon:SetModelPanelBG( itemBGColor )
	dCubensisIcon:SetHoverVariable( "Psilocybe Cubensis" )
end

function PANEL:OpenSkillsTab( )
	self:ClearContentFrame( )
	local dScrollPanel = vgui.Create( "DScrollPanel", self.contentFrame )
	dScrollPanel:SetSize( self.contentFrame:GetWide( ) * 0.98, self.contentFrame:GetTall( ) )
	dScrollPanel:Center( )
	dScrollPanel:ColorizeScrollbar( Color( 102, 102, 102 ), Color( 102, 102, 102 ), Color( 122, 122, 122 ), Color( 71, 71, 71 ) )
	local dPanel = vgui.Create( "DPanel", dScrollPanel )
	dPanel:SetSize( dScrollPanel:GetWide( ), dScrollPanel:GetTall( ) * 0.2 )
	dPanel:OffsetFromCenter( self:GetWide( ) * 0.36, self:GetTall( ) * 1.2 )
	dPanel.Paint = function( pnl, w, h ) return false end -- This panel is only here to extend the scroll panel.
	local miningProgressBar = vgui.Create( "DProgress", dScrollPanel )
	miningProgressBar:SetPos( ScrW( ) * 0.025, ScrH( ) * 0.05 )
	miningProgressBar:SetSize( ScrW( ) * 0.2, ScrH( ) * 0.03 )
	miningProgressBar.isScrollChild = "Mining Level"
	local printingProgressBar = vgui.Create( "DProgress", dScrollPanel )
	printingProgressBar:SetPos( ScrW( ) * 0.275, ScrH( ) * 0.05 )
	printingProgressBar:SetSize( ScrW( ) * 0.2, ScrH( ) * 0.03 )
	printingProgressBar.isScrollChild = "Printing Level"
	local runningProgressBar = vgui.Create( "DProgress", dScrollPanel )
	runningProgressBar:SetPos( ScrW( ) * 0.025, ScrH( ) * 0.2 )
	runningProgressBar:SetSize( ScrW( ) * 0.2, ScrH( ) * 0.03 )
	runningProgressBar.isScrollChild = "Running Level"
	local criminalProgressBar = vgui.Create( "DProgress", dScrollPanel )
	criminalProgressBar:SetPos( ScrW( ) * 0.275, ScrH( ) * 0.2 )
	criminalProgressBar:SetSize( ScrW( ) * 0.2, ScrH( ) * 0.03 )
	criminalProgressBar.isScrollChild = "Criminal Level"
	local policeProgressBar = vgui.Create( "DProgress", dScrollPanel )
	policeProgressBar:SetPos( ScrW( ) * 0.025, ScrH( ) * 0.35 )
	policeProgressBar:SetSize( ScrW( ) * 0.2, ScrH( ) * 0.03 )
	policeProgressBar.isScrollChild = "Police Level"
	local enduranceProgressBar = vgui.Create( "DProgress", dScrollPanel )
	enduranceProgressBar:SetPos( ScrW( ) * 0.275, ScrH( ) * 0.35 )
	enduranceProgressBar:SetSize( ScrW( ) * 0.2, ScrH( ) * 0.03 )
	enduranceProgressBar.isScrollChild = "Endurance Level"
	local herbalismProgressBar = vgui.Create( "DProgress", dScrollPanel )
	herbalismProgressBar:SetPos( ScrW( ) * 0.025, ScrH( ) * 0.5 )
	herbalismProgressBar:SetSize( ScrW( ) * 0.2, ScrH( ) * 0.03 )
	herbalismProgressBar.isScrollChild = "Herbalism Level"
	local alchemyProgressBar = vgui.Create( "DProgress", dScrollPanel )
	alchemyProgressBar:SetPos( ScrW( ) * 0.275, ScrH( ) * 0.5 )
	alchemyProgressBar:SetSize( ScrW( ) * 0.2, ScrH( ) * 0.03 )
	alchemyProgressBar.isScrollChild = "Alchemy Level"
	dScrollPanel.PaintOver = function( pnl, w, h )
		for index, child in ipairs ( dScrollPanel:GetChildren( )[1]:GetChildren( ) ) do
			if ( child.isScrollChild ) then
				local childX, childY = child:GetPos( )
				local vXPos, vYPos = dScrollPanel.pnlCanvas:GetPos( )
				if ( child.isScrollChild == "Mining Level" ) then
					draw.SimpleText( child.isScrollChild, "N00BRP_PlayerMenu_SkillsFont", childX + child:GetWide( ) / 2, childY * 0.3 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
					local miningData = NOOBRP_SkillAlgorithms:CalculateMining( LocalPlayer( ) )
					local miningXP = LocalPlayer( ):getDarkRPVar( "MiningXP" ) or 0
					local previousLevel = math.Clamp(miningData["CurrentLevel"] - 1, 0, 100)
					local previousXP = math.pow(previousLevel, 2) * 560
					local percent = ( miningXP - previousXP ) / miningData["RequiredXP" ]
					miningProgressBar:SetFraction( percent )
					draw.SimpleText( "XP: " .. miningXP .. " / " .. miningData["RequiredXP"], "N00BRP_PlayerMenu_TinyFont", childX + child:GetWide( ) / 2, childY * 1.6 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
					draw.SimpleText( "Level: " .. miningData["CurrentLevel"], "N00BRP_PlayerMenu_TinyFont", childX + child:GetWide( ) / 2, childY * 2.2 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
				
				elseif ( child.isScrollChild == "Printing Level" ) then
					draw.SimpleText( child.isScrollChild, "N00BRP_PlayerMenu_SkillsFont", childX + child:GetWide( ) / 2, childY * 0.3 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
					local printingData = NOOBRP_SkillAlgorithms:CalculatePrinting( LocalPlayer( ) )
					local printingXP = LocalPlayer( ):getDarkRPVar( "PrintingXP" ) or 0
					local previousLevel = math.Clamp(printingData["CurrentLevel"] - 1, 0, 100)
					local previousXP = math.pow(previousLevel, 2) * 20
					local percent = ( printingXP - previousXP ) / printingData["RequiredXP" ]
					printingProgressBar:SetFraction( percent )
					draw.SimpleText( "XP: " .. printingXP .. " / " .. printingData["RequiredXP"], "N00BRP_PlayerMenu_TinyFont", childX + child:GetWide( ) / 2, childY * 1.6 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
					draw.SimpleText( "Level: " .. printingData["CurrentLevel"], "N00BRP_PlayerMenu_TinyFont", childX + child:GetWide( ) / 2, childY * 2.2 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
				
				elseif ( child.isScrollChild == "Running Level" ) then
					draw.SimpleText( child.isScrollChild, "N00BRP_PlayerMenu_SkillsFont", childX + child:GetWide( ) / 2, childY * 0.8 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
					local runningData = NOOBRP_SkillAlgorithms:CalculateRunning( LocalPlayer( ) )
					local runningXP = LocalPlayer( ):getDarkRPVar( "RunningXP" ) or 0
					local previousLevel = math.Clamp(runningData["CurrentLevel"] - 1, 0, 100)
					local previousXP = math.pow(previousLevel, 2) * 10000
					local percent = ( runningXP - previousXP ) / runningData["RequiredXP" ]
					runningProgressBar:SetFraction( percent )
					draw.SimpleText( "XP: " .. runningXP .. " / " .. runningData["RequiredXP"], "N00BRP_PlayerMenu_TinyFont", childX + child:GetWide( ) / 2, childY * 1.15 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
					draw.SimpleText( "Level: " .. runningData["CurrentLevel"], "N00BRP_PlayerMenu_TinyFont", childX + child:GetWide( ) / 2, childY * 1.3 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
				
				elseif ( child.isScrollChild == "Criminal Level" ) then
					draw.SimpleText( child.isScrollChild, "N00BRP_PlayerMenu_SkillsFont", childX + child:GetWide( ) / 2, childY * 0.8 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
					local criminalData = NOOBRP_SkillAlgorithms:CalculateCriminal( LocalPlayer( ) )
					local criminalXP = LocalPlayer( ):getDarkRPVar( "CriminalXP" ) or 0
					local previousLevel = math.Clamp(criminalData["CurrentLevel"] - 1, 0, 100)
					local previousXP = math.pow(previousLevel, 2) * 4
					local percent = ( criminalXP - previousXP ) / criminalData["RequiredXP" ]
					criminalProgressBar:SetFraction( percent )
					draw.SimpleText( "XP: " .. criminalXP .. " / " .. criminalData["RequiredXP"], "N00BRP_PlayerMenu_TinyFont", childX + child:GetWide( ) / 2, childY * 1.15 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
					draw.SimpleText( "Level: " .. criminalData["CurrentLevel"], "N00BRP_PlayerMenu_TinyFont", childX + child:GetWide( ) / 2, childY * 1.3 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
				
				elseif ( child.isScrollChild == "Police Level" ) then
					draw.SimpleText( child.isScrollChild, "N00BRP_PlayerMenu_SkillsFont", childX + child:GetWide( ) / 2, childY * 0.9 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
					local policeData = NOOBRP_SkillAlgorithms:CalculatePolice( LocalPlayer( ) )
					local policeXP = LocalPlayer( ):getDarkRPVar( "PoliceXP" ) or 0
					local previousLevel = math.Clamp(policeData["CurrentLevel"] - 1, 0, 100)
					local previousXP = math.pow(previousLevel, 2) * 4
					local percent = ( policeXP - previousXP ) / policeData["RequiredXP" ]
					policeProgressBar:SetFraction( percent )
					draw.SimpleText( "XP: " .. policeXP .. " / " .. policeData["RequiredXP"], "N00BRP_PlayerMenu_TinyFont", childX + child:GetWide( ) / 2, childY * 1.08 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
					draw.SimpleText( "Level: " .. policeData["CurrentLevel"], "N00BRP_PlayerMenu_TinyFont", childX + child:GetWide( ) / 2, childY * 1.16 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
				
				elseif ( child.isScrollChild == "Endurance Level" ) then
					draw.SimpleText( child.isScrollChild, "N00BRP_PlayerMenu_SkillsFont", childX + child:GetWide( ) / 2, childY * 0.9 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
					local enduranceData = NOOBRP_SkillAlgorithms:CalculateEndurance( LocalPlayer( ) )
					local enduranceXP = LocalPlayer( ):getDarkRPVar( "EnduranceXP" ) or 0
					local percent =  1 - ( ( enduranceData["RequiredXP"] - enduranceXP ) / 1440 )
					enduranceProgressBar:SetFraction( percent )
					draw.SimpleText( "XP: " .. enduranceXP .. " / " .. enduranceData["RequiredXP"], "N00BRP_PlayerMenu_TinyFont", childX + child:GetWide( ) / 2, childY * 1.08 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
					draw.SimpleText( "Level: " .. enduranceData["CurrentLevel"], "N00BRP_PlayerMenu_TinyFont", childX + child:GetWide( ) / 2, childY * 1.16 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
				
				elseif ( child.isScrollChild == "Herbalism Level" ) then
					draw.SimpleText( child.isScrollChild, "N00BRP_PlayerMenu_SkillsFont", childX + child:GetWide( ) / 2, childY * 0.94 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
					local herbalismData = NOOBRP_SkillAlgorithms:CalculateHerbalism( LocalPlayer( ) )
					local herbalismXP = LocalPlayer( ):getDarkRPVar( "HerbalismXP" ) or 0
					local previousLevel = math.Clamp(herbalismData["CurrentLevel"] - 1, 0, 100)
					local previousXP = math.pow(previousLevel, 2) * 20
					local percent = ( herbalismXP - previousXP ) / herbalismData["RequiredXP" ]
					herbalismProgressBar:SetFraction( percent )
					draw.SimpleText( "XP: " .. herbalismXP .. " / " .. herbalismData["RequiredXP"], "N00BRP_PlayerMenu_TinyFont", childX + child:GetWide( ) / 2, childY * 1.06 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
					draw.SimpleText( "Level: " .. herbalismData["CurrentLevel"], "N00BRP_PlayerMenu_TinyFont", childX + child:GetWide( ) / 2, childY * 1.12 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
				
				elseif ( child.isScrollChild == "Alchemy Level" ) then
					draw.SimpleText( child.isScrollChild, "N00BRP_PlayerMenu_SkillsFont", childX + child:GetWide( ) / 2, childY * 0.94 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
					local alchemyData = NOOBRP_SkillAlgorithms:CalculateAlchemy( LocalPlayer( ) )
					local alchemyXP = LocalPlayer( ):getDarkRPVar( "AlchemyXP" ) or 0
					local previousLevel = math.Clamp(alchemyData["CurrentLevel"] - 1, 0, 100)
					local previousXP = math.pow(previousLevel, 2) * 3
					local percent = ( alchemyXP - previousXP ) / alchemyData["RequiredXP" ]
					alchemyProgressBar:SetFraction( percent )
					draw.SimpleText( "XP: " .. alchemyXP .. " / " .. alchemyData["RequiredXP"], "N00BRP_PlayerMenu_TinyFont", childX + child:GetWide( ) / 2, childY * 1.06 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
					draw.SimpleText( "Level: " .. alchemyData["CurrentLevel"], "N00BRP_PlayerMenu_TinyFont", childX + child:GetWide( ) / 2, childY * 1.12 + vYPos, mainTextColor, TEXT_ALIGN_CENTER )
				end
			end
		end
	end
end

function PANEL:OpenGemsTab( )
	self:ClearContentFrame( )
	local dRockIcon = vgui.Create( "DN00B_ModelPanelPlus", self.contentFrame )
	dRockIcon:ModifySize( self:GetWide( ) * 0.15, self:GetTall( ) * 0.2 )
	dRockIcon:LoadModel( "models/props_junk/rock001a.mdl" )
	dRockIcon:OffsetFromCenter( self:GetWide( ) * -0.31, self:GetTall( ) * -0.3 )
	dRockIcon:SetModelFOV( 45 )
	dRockIcon:EnableHoverSpinning( 1 )
	dRockIcon:SetHoverVariable( "Rocks" )
	dRockIcon.dModelPanel.OnMousePressed = function( btn ) LocalPlayer( ):ConCommand( "dropgem Rocks" ) end
	dRockIcon:SetModelPanelBG( itemBGColor )
	local dGraniteIcon = vgui.Create( "DN00B_ModelPanelPlus", self.contentFrame )
	dGraniteIcon:ModifySize( self:GetWide( ) * 0.15, self:GetTall( ) * 0.2 )
	dGraniteIcon:LoadModel( "models/props_junk/rock001a.mdl" )
	dGraniteIcon:OffsetFromCenter( self:GetWide( ) * -0.155, self:GetTall( ) * -0.3 )
	dGraniteIcon:SetModelFOV( 45 )
	dGraniteIcon.dModelPanel:SetColor( Color( 150, 150, 150 ) )
	dGraniteIcon:EnableHoverSpinning( 1 )
	dGraniteIcon:SetHoverVariable( "Granite" )
	dGraniteIcon.dModelPanel.OnMousePressed = function( btn ) LocalPlayer( ):ConCommand( "dropgem Granite" ) end
	dGraniteIcon:SetModelPanelBG( itemBGColor )
	local dShaleIcon = vgui.Create( "DN00B_ModelPanelPlus", self.contentFrame )
	dShaleIcon:ModifySize( self:GetWide( ) * 0.15, self:GetTall( ) * 0.2 )
	dShaleIcon:LoadModel( "models/props_junk/rock001a.mdl" )
	dShaleIcon:OffsetFromCenter( self:GetWide( ) * 0, self:GetTall( ) * -0.3 )
	dShaleIcon:SetModelFOV( 45 )
	dShaleIcon.dModelPanel:SetColor( Color( 75, 75, 75 ) )
	dShaleIcon:EnableHoverSpinning( 1 )
	dShaleIcon:SetHoverVariable( "Shale" )
	dShaleIcon.dModelPanel.OnMousePressed = function( btn ) LocalPlayer( ):ConCommand( "dropgem Shale" ) end
	dShaleIcon:SetModelPanelBG( itemBGColor )
	local dEmeraldIcon = vgui.Create( "DN00B_ModelPanelPlus", self.contentFrame )
	dEmeraldIcon:ModifySize( self:GetWide( ) * 0.15, self:GetTall( ) * 0.2 )
	dEmeraldIcon:LoadModel( "models/props_junk/rock001a.mdl" )
	dEmeraldIcon:OffsetFromCenter( self:GetWide( ) * 0.1525, self:GetTall( ) * -0.3 )
	dEmeraldIcon:SetModelFOV( 45 )
	dEmeraldIcon.dModelPanel:SetColor( Color( 0, 255, 0 ) )
	dEmeraldIcon:SetModelMaterial( "models/shiny" )
	dEmeraldIcon:EnableHoverSpinning( 1 )
	dEmeraldIcon:SetHoverVariable( "Emeralds" )
	dEmeraldIcon.dModelPanel.OnMousePressed = function( btn ) LocalPlayer( ):ConCommand( "dropgem Emeralds" ) end
	dEmeraldIcon:SetModelPanelBG( itemBGColor )
	local dRubyIcon = vgui.Create( "DN00B_ModelPanelPlus", self.contentFrame )
	dRubyIcon:ModifySize( self:GetWide( ) * 0.15, self:GetTall( ) * 0.2 )
	dRubyIcon:LoadModel( "models/props_junk/rock001a.mdl" )
	dRubyIcon:OffsetFromCenter( self:GetWide( ) * 0.3025, self:GetTall( ) * -0.3 )
	dRubyIcon:SetModelFOV( 45 )
	dRubyIcon.dModelPanel:SetColor( Color( 255, 0, 0 ) )
	dRubyIcon:SetModelMaterial( "models/shiny" )
	dRubyIcon:EnableHoverSpinning( 1 )
	dRubyIcon:SetHoverVariable( "Rubies" )
	dRubyIcon.dModelPanel.OnMousePressed = function( btn ) LocalPlayer( ):ConCommand( "dropgem Rubies" ) end
	dRubyIcon:SetModelPanelBG( itemBGColor )
	local dSapphireIcon = vgui.Create( "DN00B_ModelPanelPlus", self.contentFrame )
	dSapphireIcon:ModifySize( self:GetWide( ) * 0.15, self:GetTall( ) * 0.2 )
	dSapphireIcon:LoadModel( "models/props_junk/rock001a.mdl" )
	dSapphireIcon:OffsetFromCenter( self:GetWide( ) * 0.3025, self:GetTall( ) * -0.095 )
	dSapphireIcon:SetModelFOV( 45 )
	dSapphireIcon.dModelPanel:SetColor( Color( 0, 0, 255 ) )
	dSapphireIcon:SetModelMaterial( "models/shiny" )
	dSapphireIcon:EnableHoverSpinning( 1 )
	dSapphireIcon:SetHoverVariable( "Sapphires" )
	dSapphireIcon.dModelPanel.OnMousePressed = function( btn ) LocalPlayer( ):ConCommand( "dropgem Sapphires" ) end
	dSapphireIcon:SetModelPanelBG( itemBGColor )
	local dObsidianIcon = vgui.Create( "DN00B_ModelPanelPlus", self.contentFrame )
	dObsidianIcon:ModifySize( self:GetWide( ) * 0.15, self:GetTall( ) * 0.2 )
	dObsidianIcon:LoadModel( "models/props_junk/rock001a.mdl" )
	dObsidianIcon:OffsetFromCenter( self:GetWide( ) * 0.3025, self:GetTall( ) * 0.11 )
	dObsidianIcon:SetModelFOV( 45 )
	dObsidianIcon.dModelPanel:SetColor( Color( 25, 25, 25 ) )
	dObsidianIcon:SetModelMaterial( "models/shiny" )
	dObsidianIcon:EnableHoverSpinning( 1 )
	dObsidianIcon:SetHoverVariable( "Obsidians" )
	dObsidianIcon.dModelPanel.OnMousePressed = function( btn ) LocalPlayer( ):ConCommand( "dropgem Obsidians" ) end
	dObsidianIcon:SetModelPanelBG( itemBGColor )
	local dDiamondIcon = vgui.Create( "DN00B_ModelPanelPlus", self.contentFrame )
	dDiamondIcon:ModifySize( self:GetWide( ) * 0.15, self:GetTall( ) * 0.2 )
	dDiamondIcon:LoadModel( "models/props_junk/rock001a.mdl" )
	dDiamondIcon:OffsetFromCenter( self:GetWide( ) * 0.1525, self:GetTall( ) * -.092 )
	dDiamondIcon:SetModelFOV( 45 )
	dDiamondIcon.dModelPanel:SetColor( Color( 255, 255, 255, 150 ) )
	dDiamondIcon:SetModelMaterial( "models/shiny" )
	dDiamondIcon:EnableHoverSpinning( 1 )
	dDiamondIcon:SetHoverVariable( "Diamonds" )
	dDiamondIcon.dModelPanel.OnMousePressed = function( btn ) LocalPlayer( ):ConCommand( "dropgem Diamonds" ) end
	dDiamondIcon:SetModelPanelBG( itemBGColor )
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, bottomRightPanelColor )
    draw.RoundedBox( 0, 0, 0, w * 0.2, h, leftPanelColor )
    draw.RoundedBox( 0, 0, 0, w, h * 0.2, upperPanelColor )
end

vgui.Register( "N00BRP_PlayerMenu", PANEL, "DFrame" )

local playerMenu = nil
local function OpenPlayerMenu( ply, cmd, args, fstring )
	if ( ValidPanel( playerMenu ) ) then
		playerMenu:Remove( )
		gui.EnableScreenClicker( false )
	else
		playerMenu = vgui.Create( "N00BRP_PlayerMenu" )
	end
end
concommand.Add( "rp_playermenu", OpenPlayerMenu )
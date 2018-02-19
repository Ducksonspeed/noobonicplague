surface.CreateFont( "N00BRP_CustomF4Menu_SegoeUIBold", {
	font = "Segoe UI Bold",
	size = 16,
	weight = 700,
	blursize = 0,
} )

surface.CreateFont( "N00BRP_CustomF4Menu_SegoeUIBoldLarge", {
	font = "Segoe UI Bold",
	size = 24,
	weight = 700,
	blursize = 0,
} )

surface.CreateFont( "N00BRP_CustomF4Menu_SegoeUIBoldHuge", {
	font = "Segoe UI Bold",
	size = 24,
	weight = 800,
	blursize = 0,
} )


PANEL = { }

function PANEL:Init()
    self:SetSize( ScrW( ) * 0.6, ScrH( ) * 0.7 )
    self:Center( )
   	gui.EnableScreenClicker( true )
   	self:CreateMenuBase( )
   	self:GenerateJobsTab( )
end

function PANEL:CreateMenuBase( )

	self.dContentPanel = vgui.Create( "DPanel", self )
	self.dContentPanel:SetSize( self:GetWide( ) * 0.8, self:GetTall( ) * 0.75 )
	self.dContentPanel:AlignBottom( self:GetTall( ) * 0.1 )
	self.dContentPanel:CenterHorizontal( )
	local buttonWidth = 110
	local contentPanelX, contentPanelY = self.dContentPanel:GetPos( )
	local dJobsButton = vgui.Create( "DN00B_ColoredButton", self )
	dJobsButton:SetSize( buttonWidth, 32 )
	dJobsButton:SetPos( contentPanelX, contentPanelY - 32 )
	dJobsButton:SetText( "Jobs" )
	dJobsButton:SetButtonColor( Color( 255, 255, 255 ) )
	dJobsButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dJobsButton:SetTextColor( Color( 0, 0, 0 ) )
	dJobsButton:SetRoundness( 0 )
	dJobsButton.OnMousePressed = function( pnl, btn )
		self:GenerateJobsTab( )
	end
	local dEntsAndShipmentsButton = vgui.Create( "DN00B_ColoredButton", self )
	dEntsAndShipmentsButton:SetSize( buttonWidth, 32 )
	dEntsAndShipmentsButton:SetPos( contentPanelX + buttonWidth, contentPanelY - 32 )
	dEntsAndShipmentsButton:SetText( "Entities & Shipments" )
	if ( LocalPlayer( ):Team( ) == TEAM_CARDEALER ) then
		dEntsAndShipmentsButton:SetText( "Entities & Vehicles" )
	elseif ( LocalPlayer( ):Team( ) == TEAM_COOK ) then
		dEntsAndShipmentsButton:SetText( "Entities & Food" )
	elseif ( #self:GetJobSpecificShipments( ) <= 0 ) then
		dEntsAndShipmentsButton:SetText( "Entities" )
	end
	dEntsAndShipmentsButton:SetButtonColor( Color( 255, 255, 255 ) )
	dEntsAndShipmentsButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dEntsAndShipmentsButton:SetTextColor( Color( 0, 0, 0 ) )
	dEntsAndShipmentsButton:SetRoundness( 0 )
	dEntsAndShipmentsButton.OnMousePressed = function( pnl, btn )
		self:GenerateEntityAndMiscTab( )
	end
	local dAmmoButton = vgui.Create( "DN00B_ColoredButton", self )
	dAmmoButton:SetSize( buttonWidth, 32 )
	dAmmoButton:SetPos( contentPanelX + ( buttonWidth * 2 ), contentPanelY - 32 )
	dAmmoButton:SetText( "Ammo" )
	dAmmoButton:SetButtonColor( Color( 255, 255, 255 ) )
	dAmmoButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dAmmoButton:SetTextColor( Color( 0, 0, 0 ) )
	dAmmoButton:SetRoundness( 0 )
	dAmmoButton.OnMousePressed = function( pnl, btn )
		self:GenerateAmmoTab( )
	end
	local dAchievementsButton = vgui.Create( "DN00B_ColoredButton", self )
	dAchievementsButton:SetSize( buttonWidth, 32 )
	dAchievementsButton:SetPos( contentPanelX + ( buttonWidth * 3 ), contentPanelY - 32 )
	dAchievementsButton:SetText( "Achievements" )
	dAchievementsButton:SetButtonColor( Color( 255, 255, 255 ) )
	dAchievementsButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dAchievementsButton:SetTextColor( Color( 0, 0, 0 ) )
	dAchievementsButton:SetRoundness( 0 )
	dAchievementsButton.OnMousePressed = function( pnl, btn )
		self:GenerateAchievementsTab( )
	end
	local dCloseButton = vgui.Create( "DN00B_ColoredButton", self )
	dCloseButton:SetSize( buttonWidth, 32 )
	dCloseButton:SetPos( contentPanelX + ( buttonWidth * 4 ), contentPanelY - 32 )
	dCloseButton:SetText( "Close" )
	dCloseButton:SetButtonColor( Color( 255, 255, 255 ) )
	dCloseButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dCloseButton:SetTextColor( Color( 175, 45, 45 ) )
	dCloseButton:SetRoundness( 0 )
	dCloseButton.OnMousePressed = function( pnl, btn )
		self:Remove( )
		gui.EnableScreenClicker( false )
	end
end

local completeMaterial = Material( "icon16/accept.png" )

function PANEL:ResetButtonColors( noChangePanel, buttonTable )
	for index, button in ipairs( buttonTable ) do
		if ( button == noChangePanel ) then continue end
		button:SetButtonColor( Color( 255, 255, 255 ) )
		button:SetTextColor( Color( 0, 0, 0 ) )
	end
end

function PANEL:GenerateAchievementsTab( )
	self.dContentPanel:Clear( )
	local categoryTextColor = Color( 0, 0, 0 )
	local achievementList = vgui.Create( "DN00B_ScrollableList", self.dContentPanel )
	achievementList:SetPos( self.dContentPanel:GetWide( ) * 0.05, self.dContentPanel:GetTall( ) * 0.15 )
	achievementList:SetSize( self.dContentPanel:GetWide( ) * 0.9, self.dContentPanel:GetTall( ) * 0.8 )
	achievementList.dIconLayout:SetSize( achievementList:GetWide( ), achievementList:GetTall( ) )
	
	local dSkillButton = vgui.Create( "DN00B_ColoredButton", self.dContentPanel )
	dSkillButton:SetSize( 64, 16 )
	dSkillButton:SetPos( 32, 16 )
	dSkillButton:SetText( "SKILLS" )
	dSkillButton:SetButtonColor( Color( 255, 255, 255 ) )
	dSkillButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dSkillButton:SetTextColor( categoryTextColor )
	dSkillButton:SetRoundness( 0 )
	dSkillButton.OnMousePressed = function( pnl, btn )
		self:GenerateAchievements( achievementList, ENUM_ACHIEVEMENTS_CATEGORY_SKILL, self.lastHideCompleted, self.lastHideIncompleted )
		dSkillButton:SetButtonColor( Color( 45, 45, 175, 125 ) )
		dSkillButton:SetTextColor( Color( 255, 255, 255 ) )
		self:ResetButtonColors( dSkillButton, self.buttonTable )
	end
	local dMurderButton = vgui.Create( "DN00B_ColoredButton", self.dContentPanel )
	dMurderButton:SetSize( 64, 16 )
	dMurderButton:SetPos( 98, 16 )
	dMurderButton:SetText( "MURDER" )
	dMurderButton:SetButtonColor( Color( 255, 255, 255 ) )
	dMurderButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dMurderButton:SetTextColor( categoryTextColor )
	dMurderButton:SetRoundness( 0 )
	dMurderButton.OnMousePressed = function( pnl, btn )
		self:GenerateAchievements( achievementList, ENUM_ACHIEVEMENTS_CATEGORY_MURDER, self.lastHideCompleted, self.lastHideIncompleted )
		dMurderButton:SetButtonColor( Color( 45, 45, 175, 125 ) )
		dMurderButton:SetTextColor( Color( 255, 255, 255 ) )
		self:ResetButtonColors( dMurderButton, self.buttonTable )
	end
	local dCrimeAndLawButton = vgui.Create( "DN00B_ColoredButton", self.dContentPanel )
	dCrimeAndLawButton:SetSize( 96, 16 )
	dCrimeAndLawButton:SetPos( 164, 16 )
	dCrimeAndLawButton:SetText( "CRIME & LAW" )
	dCrimeAndLawButton:SetButtonColor( Color( 255, 255, 255 ) )
	dCrimeAndLawButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dCrimeAndLawButton:SetTextColor( categoryTextColor )
	dCrimeAndLawButton:SetRoundness( 0 )
	dCrimeAndLawButton.OnMousePressed = function( pnl, btn )
		self:GenerateAchievements( achievementList, ENUM_ACHIEVEMENTS_CATEGORY_CRIMEANDLAW, self.lastHideCompleted, self.lastHideIncompleted )
		dCrimeAndLawButton:SetButtonColor( Color( 45, 45, 175, 125 ) )
		dCrimeAndLawButton:SetTextColor( Color( 255, 255, 255 ) )
		self:ResetButtonColors( dCrimeAndLawButton, self.buttonTable )
	end
	local dEventButton = vgui.Create( "DN00B_ColoredButton", self.dContentPanel )
	dEventButton:SetSize( 64, 16 )
	dEventButton:SetPos( 262, 16 )
	dEventButton:SetText( "EVENT" )
	dEventButton:SetButtonColor( Color( 255, 255, 255 ) )
	dEventButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dEventButton:SetTextColor( categoryTextColor )
	dEventButton:SetRoundness( 0 )
	dEventButton.OnMousePressed = function( pnl, btn )
		self:GenerateAchievements( achievementList, ENUM_ACHIEVEMENTS_CATEGORY_EVENT, self.lastHideCompleted, self.lastHideIncompleted )
		dEventButton:SetButtonColor( Color( 45, 45, 175, 125 ) )
		dEventButton:SetTextColor( Color( 255, 255, 255 ) )
		self:ResetButtonColors( dEventButton, self.buttonTable )
	end
	local dJobRelatedButton = vgui.Create( "DN00B_ColoredButton", self.dContentPanel )
	dJobRelatedButton:SetSize( 96, 16 )
	dJobRelatedButton:SetPos( 328, 16 )
	dJobRelatedButton:SetText( "JOB RELATED" )
	dJobRelatedButton:SetButtonColor( Color( 255, 255, 255 ) )
	dJobRelatedButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dJobRelatedButton:SetTextColor( categoryTextColor )
	dJobRelatedButton:SetRoundness( 0 )
	dJobRelatedButton.OnMousePressed = function( pnl, btn )
		self:GenerateAchievements( achievementList, ENUM_ACHIEVEMENTS_CATEGORY_JOBRELATED, self.lastHideCompleted, self.lastHideIncompleted )
		dJobRelatedButton:SetButtonColor( Color( 45, 45, 175, 125 ) )
		dJobRelatedButton:SetTextColor( Color( 255, 255, 255 ) )
		self:ResetButtonColors( dJobRelatedButton, self.buttonTable )
	end
	local dGatherAndMineButton = vgui.Create( "DN00B_ColoredButton", self.dContentPanel )
	dGatherAndMineButton:SetSize( 192, 16 )
	dGatherAndMineButton:SetPos( 32, 34 )
	dGatherAndMineButton:SetText( "GATHERING AND MINING" )
	dGatherAndMineButton:SetButtonColor( Color( 255, 255, 255 ) )
	dGatherAndMineButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dGatherAndMineButton:SetTextColor( categoryTextColor )
	dGatherAndMineButton:SetRoundness( 0 )
	dGatherAndMineButton.OnMousePressed = function( pnl, btn )
		self:GenerateAchievements( achievementList, ENUM_ACHIEVEMENTS_CATEGORY_GATHERINGANDMINING, self.lastHideCompleted, self.lastHideIncompleted )
		dGatherAndMineButton:SetButtonColor( Color( 45, 45, 175, 125 ) )
		dGatherAndMineButton:SetTextColor( Color( 255, 255, 255 ) )
		self:ResetButtonColors( dGatherAndMineButton, self.buttonTable )
	end
	local dMiscButton = vgui.Create( "DN00B_ColoredButton", self.dContentPanel )
	dMiscButton:SetSize( 64, 16 )
	dMiscButton:SetPos( 226, 34 )
	dMiscButton:SetText( "MISC" )
	dMiscButton:SetButtonColor( Color( 255, 255, 255 ) )
	dMiscButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dMiscButton:SetTextColor( categoryTextColor )
	dMiscButton:SetRoundness( 0 )
	dMiscButton.OnMousePressed = function( pnl, btn )
		self:GenerateAchievements( achievementList, ENUM_ACHIEVEMENTS_CATEGORY_MISC, self.lastHideCompleted, self.lastHideIncompleted )
		dMiscButton:SetButtonColor( Color( 45, 45, 175, 125 ) )
		dMiscButton:SetTextColor( Color( 255, 255, 255 ) )
		self:ResetButtonColors( dMiscButton, self.buttonTable )
	end
	local dAllButton = vgui.Create( "DN00B_ColoredButton", self.dContentPanel )
	dAllButton:SetSize( 64, 16 )
	dAllButton:SetPos( 360, 34 )
	dAllButton:SetText( "ALL" )
	dAllButton:SetButtonColor( Color( 45, 45, 175, 125 ) )
	dAllButton:SetTextColor( Color( 255, 255, 255 ) )
	dAllButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dAllButton:SetRoundness( 0 )
	dAllButton.OnMousePressed = function( pnl, btn )
		self:GenerateAchievements( achievementList, nil )
		dAllButton:SetButtonColor( Color( 45, 45, 175, 125 ) )
		dAllButton:SetTextColor( Color( 255, 255, 255 ) )
		self:ResetButtonColors( dAllButton, self.buttonTable )
	end

	local dHideCompleted = vgui.Create( "DN00B_ColoredButton", self.dContentPanel )
	dHideCompleted:SetSize( 128, 16 )
	dHideCompleted:SetPos( 450, 16 )
	dHideCompleted:SetText( "HIDE COMPLETED" )
	dHideCompleted:SetButtonColor( Color( 255, 255, 255 ) )
	dHideCompleted:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dHideCompleted:SetTextColor( Color( 175, 45, 45 ) )
	dHideCompleted:SetRoundness( 0 )
	dHideCompleted.OnMousePressed = function( pnl, btn )
		if ( self.lastHideIncompleted ) then return end
		self:GenerateAchievements( achievementList, self.lastCategory, !( self.lastHideCompleted ), self.lastHideIncompleted )
		if ( self.lastHideCompleted ) then
			dHideCompleted:SetText( "SHOW COMPLETED" )
			dHideCompleted:SetTextColor( Color( 45, 175, 45 ) )
		else
			dHideCompleted:SetText( "HIDE COMPLETED" )
			dHideCompleted:SetTextColor( Color( 175, 45, 45 ) )
		end
	end

	local dHideIncompleted = vgui.Create( "DN00B_ColoredButton", self.dContentPanel )
	dHideIncompleted:SetSize( 128, 16 )
	dHideIncompleted:SetPos( 450, 32 )
	dHideIncompleted:SetText( "HIDE INCOMPLETED" )
	dHideIncompleted:SetButtonColor( Color( 255, 255, 255 ) )
	dHideIncompleted:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dHideIncompleted:SetTextColor( Color( 175, 45, 45 ) )
	dHideIncompleted:SetRoundness( 0 )
	dHideIncompleted.OnMousePressed = function( pnl, btn )
		if ( self.lastHideCompleted ) then return end
		self:GenerateAchievements( achievementList, self.lastCategory, self.lastHideCompleted, !( self.lastHideIncompleted ) )
		if ( self.lastHideIncompleted ) then
			dHideIncompleted:SetText( "SHOW INCOMPLETED" )
			dHideIncompleted:SetTextColor( Color( 45, 175, 45 ) )
		else
			dHideIncompleted:SetText( "HIDE INCOMPLETED" )
			dHideIncompleted:SetTextColor( Color( 175, 45, 45 ) )
		end
	end
	self.buttonTable = { dSkillButton, dMurderButton, dCrimeAndLawButton, dEventButton, dJobRelatedButton, dMiscButton, dGatherAndMineButton, dAllButton }
	local completedAmount, achieveAmount = self:GenerateAchievements( achievementList, nil )
	local completionLabel = vgui.Create( "DLabel", self.dContentPanel )
	completionLabel:SetText( "Achievements Completed: " .. completedAmount .. " / " .. achieveAmount )
	completionLabel:SetFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	completionLabel:SetTextColor( Color( 0, 0, 0 ) )
	completionLabel:SizeToContents( )
	completionLabel:CenterHorizontal( )
	completionLabel:AlignBottom( self.dContentPanel:GetTall( ) * 0.0025 )
end

function PANEL:GenerateAchievements( achievementList, category, hideCompleted, hideIncompleted )
	self.lastCategory = category
	self.lastHideCompleted = hideCompleted
	self.lastHideIncompleted = hideIncompleted
	achievementList:ClearItems( )
	achievementList:GetVBar( ):SetScroll( 0 )
	local completedAmount = 0
	local achieveAmount = table.Count( NOOBRP.Achievements )
	for name, tbl in SortedPairsByMemberValue( NOOBRP.Achievements, "name", false ) do
		if ( category and tbl.category ~= category ) then continue end
		local isComplete = false
		local achievePanel = achievementList:AddElement( "DPanel" )
		achievePanel:SetSize( achievementList:GetWide( ), 96 )
		local nameLabel = vgui.Create( "DLabel", achievePanel )
		nameLabel:SetText( tbl.name )
		nameLabel:SetFont( "N00BRP_CustomF4Menu_SegoeUIBoldHuge" )
		nameLabel:SetTextColor( Color( 255, 255, 255 ) )
		nameLabel:SizeToContents( )
		nameLabel:SetPos( 16, 8 )
		local descLabel = vgui.Create( "DLabel", achievePanel )
		descLabel:SetText( tbl.desc )
		descLabel:SetFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
		descLabel:SetTextColor( Color( 255, 255, 255 ) )
		descLabel:SizeToContents( )
		descLabel:SetPos( 16, 32 )
		local progressLabel = vgui.Create( "DLabel", achievePanel )
		local progress = 0
		if ( LocalPlayer( ).achieveTable and LocalPlayer( ).achieveTable[ name ] ) then
			progress = LocalPlayer( ).achieveTable[ name ].progress
		end
		progressLabel:SetText( "Progress: " .. progress .. " / " .. tbl.goal )
		progressLabel:SetFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
		progressLabel:SetTextColor( Color( 255, 255, 255 ) )
		progressLabel:SizeToContents( )
		progressLabel:SetPos( 16, 48 )
		if ( tbl.rewardText ) then
			local rewardLabel = vgui.Create( "DLabel", achievePanel )
			rewardLabel:SetText( "Reward: " .. tbl.rewardText )
			rewardLabel:SetFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
			rewardLabel:SetTextColor( Color( 255, 255, 255 ) )
			rewardLabel:SizeToContents( )
			rewardLabel:SetPos( 16, 64 )
		end
		if ( LocalPlayer( ).achieveTable and LocalPlayer( ).achieveTable[ name ] and LocalPlayer( ).achieveTable[ name ].completed ) then
			isComplete = true
			completedAmount = completedAmount + 1
			if ( hideCompleted ) then achievePanel:Remove( ) end
		else
			if ( hideIncompleted ) then achievePanel:Remove( ) end
		end
		achievePanel.Paint = function( pnl, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, Color( 45, 45, 45, 225 ) )
			if ( isComplete ) then
				local nameLabelX, nameLabelY = nameLabel:GetPos( )
				nameLabelX = nameLabelX + nameLabel:GetWide( ) + 8
				surface.SetMaterial( completeMaterial )
	       		surface.SetDrawColor( Color( 255, 255, 255 ) )
	      		surface.DrawTexturedRect( nameLabelX, nameLabelY + 4, 16, 16 )
	      	end
		end
	end
	return completedAmount, achieveAmount
end

function PANEL:GenerateAmmoPreview( ammoPreviewPanel, ammoPreviewNameLabel, ammoPreviewCostLabel, ammoPreviewRoundsLabel, ammoTable )
	ammoPreviewPanel:LoadModel( ammoTable.model )
	ammoPreviewNameLabel:SetText( ammoTable.name )
	ammoPreviewNameLabel:SizeToContents( )
	ammoPreviewCostLabel:SetText( "$" .. string.Comma( ammoTable.price ) )
	if ( SHNOOB_VARS:Get( "BeastEventActive" ) == true ) then
		ammoPreviewCostLabel:SetText( "$0" )
	end
	ammoPreviewCostLabel:SizeToContents( )
	ammoPreviewRoundsLabel:SetText( "Rounds: x" .. ammoTable.amountGiven )
	ammoPreviewRoundsLabel:SizeToContents( )
end

function PANEL:GenerateAmmoTab( )
	self.dContentPanel:Clear( )
	local ammoList = vgui.Create( "DN00B_ScrollableList", self.dContentPanel )
	ammoList:SetPos( self.dContentPanel:GetWide( ) * 0.05, self.dContentPanel:GetTall( ) * 0.15 )
	ammoList:SetSize( self.dContentPanel:GetWide( ) * 0.5, self.dContentPanel:GetTall( ) * 0.3 )
	ammoList.dIconLayout:SetSize( ammoList:GetWide( ), ammoList:GetTall( ) )

	local ammoPreviewPanel = vgui.Create( "DN00B_ModelPanelPlus", self.dContentPanel )
	ammoPreviewPanel:ModifySize( self.dContentPanel:GetWide( ) * 0.35, self.dContentPanel:GetTall( ) * 0.5 )
	ammoPreviewPanel:SetPos( self.dContentPanel:GetWide( ) * 0.625, self.dContentPanel:GetTall( ) * 0.2 )
	ammoPreviewPanel:SetModelFOV( 45 )
	ammoPreviewPanel:SetModelRotation( Angle( 0, 0, 0 ) )
	local previewPanelX, previewPanelY = ammoPreviewPanel:GetPos( )
	local previewPanelW, previewPanelH = ammoPreviewPanel:GetSize( )

	local ammoPreviewNameLabel = vgui.Create( "DLabel", self.dContentPanel )
	ammoPreviewNameLabel:SetFont( "N00BRP_CustomF4Menu_SegoeUIBoldHuge" )
	ammoPreviewNameLabel:SetPos( previewPanelX, previewPanelY - self.dContentPanel:GetTall( ) * 0.15 )
	ammoPreviewNameLabel:SetTextColor( Color ( 0, 0, 0 ) )
	ammoPreviewNameLabel:SetText( "" )
	local ammoPreviewCostLabel = vgui.Create( "DLabel", self.dContentPanel )
	ammoPreviewCostLabel:SetFont( "N00BRP_CustomF4Menu_SegoeUIBoldLarge" )
	ammoPreviewCostLabel:SetPos( previewPanelX, previewPanelY - self.dContentPanel:GetTall( ) * 0.1 )
	ammoPreviewCostLabel:SetTextColor( Color( 0, 0, 0 ) )
	ammoPreviewCostLabel:SetText( "" )

	local ammoPreviewRoundsLabel = vgui.Create( "DLabel", self.dContentPanel )
	ammoPreviewRoundsLabel:SetFont( "N00BRP_CustomF4Menu_SegoeUIBoldLarge" )
	ammoPreviewRoundsLabel:SetPos( previewPanelX, previewPanelY - self.dContentPanel:GetTall( ) * 0.05 )
	ammoPreviewRoundsLabel:SetTextColor( Color( 0, 0, 0 ) )
	ammoPreviewRoundsLabel:SetText( "" )

	local dPurchaseButton = vgui.Create( "DN00B_ColoredButton", self.dContentPanel )
	dPurchaseButton:SetSize( self.dContentPanel:GetWide( ) * 0.2, 32 )
	local buttonPosX = previewPanelX + ( previewPanelW * 0.5 ) - ( ( self.dContentPanel:GetWide( ) * 0.2 ) * 0.5 )
	dPurchaseButton:SetPos( buttonPosX, previewPanelY + previewPanelH + ( self.dContentPanel:GetTall( ) * 0.085 ) )
	dPurchaseButton:SetText( "Purchase" )
	dPurchaseButton:SetButtonColor( Color( 45, 45, 45, 175 ) )
	dPurchaseButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBoldHuge" )
	dPurchaseButton:SetTextColor( Color( 255, 255, 255 ) )
	dPurchaseButton:SetRoundness( 8 )
	dPurchaseButton.OnMousePressed = function( pnl, btn )
		if not ( ammoList.currentCommand ) then return end
		LocalPlayer( ):ConCommand( "say /" .. ammoList.currentCommand )
	end

	local ammoLabel = vgui.Create( "DLabel", self.dContentPanel )
	ammoLabel:SetText( "Ammo" )
	ammoLabel:SetFont( "N00BRP_CustomF4Menu_SegoeUIBoldLarge" )
	ammoLabel:SetTextColor( Color( 0, 0, 0 ) )
	ammoLabel:SizeToContents( )
	ammoLabel:SetPos( self.dContentPanel:GetWide( ) * 0.05, self.dContentPanel:GetTall( ) * 0.05 )
	for index, ammo in ipairs ( GAMEMODE.AmmoTypes ) do
		if ( ammo.name == "Pistol ammo" ) then
			ammoList.currentCommand = "buyammo " .. ammo.ammoType
			self:GenerateAmmoPreview( ammoPreviewPanel, ammoPreviewNameLabel, ammoPreviewCostLabel, ammoPreviewRoundsLabel, ammo )
		end
		local dAmmoIcon = ammoList:AddElement( "DN00B_ModelPanelPlus" )
		dAmmoIcon:ModifySize( 96, 96 )
		dAmmoIcon:LoadModel( ammo.model )
		dAmmoIcon:SetModelFOV( 45 )
		dAmmoIcon.dModelPanel.OnMousePressed = function( pnl, btn )
			ammoList.currentCommand = "buyammo " .. ammo.ammoType
			self:GenerateAmmoPreview( ammoPreviewPanel, ammoPreviewNameLabel, ammoPreviewCostLabel, ammoPreviewRoundsLabel, ammo )
		end
	end
end

function PANEL:GetJobSpecificShipments( )
	local shipmentTable = { }
	for index, shipment in ipairs ( CustomShipments ) do
		if ( !istable( shipment.allowed ) or shipment.noship ) then
			continue
		else
			for _, allowedTeam in ipairs ( shipment.allowed ) do
				if ( LocalPlayer( ):Team( ) == allowedTeam ) then
					table.insert( shipmentTable, shipment )
					break
				end
			end
		end
	end
	return shipmentTable
end

function PANEL:GenerateEntityPreview( entityPreviewPanel, entityPreviewNameLabel, entityPreviewCostLabel, model, name, cost )
	entityPreviewPanel:LoadModel( model )
	entityPreviewNameLabel:SetText( name )
	entityPreviewNameLabel:SizeToContents( )
	entityPreviewCostLabel:SetText( "$" .. string.Comma( cost ) )
	entityPreviewCostLabel:SizeToContents( )
end

function PANEL:GenerateEntityAndMiscTab( )
	self.dContentPanel:Clear( )
	local allowedShipments = self:GetJobSpecificShipments( )
	local listWidth = self.dContentPanel:GetWide( ) * 0.5
	local entityList = vgui.Create( "DN00B_ScrollableList", self.dContentPanel )
	entityList:SetPos( self.dContentPanel:GetWide( ) * 0.05, self.dContentPanel:GetTall( ) * 0.15 )
	entityList:SetSize( listWidth, self.dContentPanel:GetTall( ) * 0.3 )
	entityList.dIconLayout:SetSize( entityList:GetWide( ), entityList:GetTall( ) )

	local entityPreviewPanel = vgui.Create( "DN00B_ModelPanelPlus", self.dContentPanel )
	entityPreviewPanel:ModifySize( self.dContentPanel:GetWide( ) * 0.35, self.dContentPanel:GetTall( ) * 0.5 )
	entityPreviewPanel:SetPos( self.dContentPanel:GetWide( ) * 0.625, self.dContentPanel:GetTall( ) * 0.14 )
	entityPreviewPanel:SetModelFOV( 45 )
	entityPreviewPanel:SetModelRotation( Angle( 0, 0, 0 ) )
	local previewPanelX, previewPanelY = entityPreviewPanel:GetPos( )
	local previewPanelW, previewPanelH = entityPreviewPanel:GetSize( )

	local entityPreviewNameLabel = vgui.Create( "DLabel", self.dContentPanel )
	entityPreviewNameLabel:SetFont( "N00BRP_CustomF4Menu_SegoeUIBoldHuge" )
	entityPreviewNameLabel:SetPos( previewPanelX, previewPanelY - self.dContentPanel:GetTall( ) * 0.1 )
	entityPreviewNameLabel:SetTextColor( Color ( 0, 0, 0 ) )
	entityPreviewNameLabel:SetText( "" )
	local entityPreviewCostLabel = vgui.Create( "DLabel", self.dContentPanel )
	entityPreviewCostLabel:SetFont( "N00BRP_CustomF4Menu_SegoeUIBoldLarge" )
	entityPreviewCostLabel:SetPos( previewPanelX, previewPanelY - self.dContentPanel:GetTall( ) * 0.05 )
	entityPreviewCostLabel:SetTextColor( Color( 0, 0, 0 ) )
	entityPreviewCostLabel:SetText( "" )

	local dPurchaseButton = vgui.Create( "DN00B_ColoredButton", self.dContentPanel )
	dPurchaseButton:SetSize( self.dContentPanel:GetWide( ) * 0.2, 32 )
	local buttonPosX = previewPanelX + ( previewPanelW * 0.5 ) - ( ( self.dContentPanel:GetWide( ) * 0.2 ) * 0.5 )
	dPurchaseButton:SetPos( buttonPosX, previewPanelY + previewPanelH + ( self.dContentPanel:GetTall( ) * 0.085 ) )
	dPurchaseButton:SetText( "Purchase" )
	dPurchaseButton:SetButtonColor( Color( 45, 45, 45, 175 ) )
	dPurchaseButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBoldHuge" )
	dPurchaseButton:SetTextColor( Color( 255, 255, 255 ) )
	dPurchaseButton:SetRoundness( 8 )
	dPurchaseButton.OnMousePressed = function( pnl, btn )
		if not ( entityList.currentCommand ) then return end
		LocalPlayer( ):ConCommand( "say /" .. entityList.currentCommand )
	end

	local entityLabel = vgui.Create( "DLabel", self.dContentPanel )
	entityLabel:SetText( "Entities" )
	entityLabel:SetFont( "N00BRP_CustomF4Menu_SegoeUIBoldLarge" )
	entityLabel:SetTextColor( Color( 0, 0, 0 ) )
	entityLabel:SizeToContents( )
	entityLabel:SetPos( self.dContentPanel:GetWide( ) * 0.05, self.dContentPanel:GetTall( ) * 0.05 )
	for index, ent in ipairs ( DarkRPEntities ) do
		if ( isfunction( ent.customCheck ) and !ent.customCheck( LocalPlayer( ) ) ) then continue end
		local shouldContinue = true
		if ( ent.allowed ) then
			shouldContinue = false
			for _, allowedTeam in ipairs ( ent.allowed ) do
				if ( LocalPlayer( ):Team( ) == allowedTeam ) then
					shouldContinue = true
					break
				end
			end
		end
		if not ( shouldContinue ) then continue end
		if ( ent.ent == "ent_radio" ) then
			self:GenerateEntityPreview( entityPreviewPanel, entityPreviewNameLabel, entityPreviewCostLabel, ent.model, ent.name, ent.price )
		end
		local dEntIcon = entityList:AddElement( "DN00B_ModelPanelPlus" )
		dEntIcon:ModifySize( 96, 96 )
		dEntIcon:LoadModel( ent.model )
		dEntIcon:SetModelFOV( 45 )
		dEntIcon.dModelPanel.OnMousePressed = function( pnl, btn )
			entityList.currentCommand = ent.cmd
			self:GenerateEntityPreview( entityPreviewPanel, entityPreviewNameLabel, entityPreviewCostLabel, ent.model, ent.name, ent.price )
		end
	end
	if ( LocalPlayer( ):Team( ) == TEAM_CARDEALER ) then
		local vehicleLabel = vgui.Create( "DLabel", self.dContentPanel )
		vehicleLabel:SetText( "Vehicles" )
		vehicleLabel:SetFont( "N00BRP_CustomF4Menu_SegoeUIBoldLarge" )
		vehicleLabel:SetTextColor( Color( 0, 0, 0 ) )
		vehicleLabel:SizeToContents( )
		vehicleLabel:SetPos( self.dContentPanel:GetWide( ) * 0.05, self.dContentPanel:GetTall( ) * 0.45 )
		local vehicleList = vgui.Create( "DN00B_ScrollableList", self.dContentPanel )
		vehicleList:SetPos( self.dContentPanel:GetWide( ) * 0.05, self.dContentPanel:GetTall( ) * 0.55 )
		vehicleList:SetSize( listWidth, self.dContentPanel:GetTall( ) * 0.4 )
		vehicleList.dIconLayout:SetSize( vehicleList:GetWide( ), vehicleList:GetTall( ) )
		for index, veh in ipairs ( CustomVehicles ) do
			local dVehIcon = vehicleList:AddElement( "DN00B_ModelPanelPlus" )
			dVehIcon:ModifySize( 96, 96 )
			dVehIcon:LoadModel( veh.model )
			dVehIcon:SetModelFOV( 45 )
			dVehIcon.dModelPanel.OnMousePressed = function( pnl, btn )
				entityList.currentCommand = "buyvehicle " .. veh.name
				self:GenerateEntityPreview( entityPreviewPanel, entityPreviewNameLabel, entityPreviewCostLabel, veh.model, veh.name, veh.price )
			end
		end
	elseif ( LocalPlayer( ):Team( ) == TEAM_COOK ) then
		local foodLabel = vgui.Create( "DLabel", self.dContentPanel )
		foodLabel:SetText( "Food" )
		foodLabel:SetFont( "N00BRP_CustomF4Menu_SegoeUIBoldLarge" )
		foodLabel:SetTextColor( Color( 0, 0, 0 ) )
		foodLabel:SizeToContents( )
		foodLabel:SetPos( self.dContentPanel:GetWide( ) * 0.05, self.dContentPanel:GetTall( ) * 0.45 )
		local foodList = vgui.Create( "DN00B_ScrollableList", self.dContentPanel )
		foodList:SetPos( self.dContentPanel:GetWide( ) * 0.05, self.dContentPanel:GetTall( ) * 0.55 )
		foodList:SetSize( listWidth, self.dContentPanel:GetTall( ) * 0.4 )
		foodList.dIconLayout:SetSize( foodList:GetWide( ), foodList:GetTall( ) )
		for index, food in ipairs ( FoodItems ) do
			local dFoodIcon = foodList:AddElement( "DN00B_ModelPanelPlus" )
			dFoodIcon:ModifySize( 96, 96 )
			dFoodIcon:LoadModel( food.model )
			dFoodIcon:SetModelFOV( 45 )
			dFoodIcon.dModelPanel.OnMousePressed = function( pnl, btn )
				entityList.currentCommand = "buyfood " .. food.name
				self:GenerateEntityPreview( entityPreviewPanel, entityPreviewNameLabel, entityPreviewCostLabel, food.model, food.name, food.price )
			end
		end
	elseif ( #allowedShipments > 0 ) then
		local shipmentLabel = vgui.Create( "DLabel", self.dContentPanel )
		shipmentLabel:SetText( "Shipments" )
		shipmentLabel:SetFont( "N00BRP_CustomF4Menu_SegoeUIBoldLarge" )
		shipmentLabel:SetTextColor( Color( 0, 0, 0 ) )
		shipmentLabel:SizeToContents( )
		shipmentLabel:SetPos( self.dContentPanel:GetWide( ) * 0.05, self.dContentPanel:GetTall( ) * 0.45 )
		local shipmentList = vgui.Create( "DN00B_ScrollableList", self.dContentPanel )
		shipmentList:SetPos( self.dContentPanel:GetWide( ) * 0.05, self.dContentPanel:GetTall( ) * 0.55 )
		shipmentList:SetSize( listWidth, self.dContentPanel:GetTall( ) * 0.4 )
		shipmentList.dIconLayout:SetSize( shipmentList:GetWide( ), shipmentList:GetTall( ) )
		for index, shipment in ipairs ( allowedShipments ) do
			local dShipmentIcon = shipmentList:AddElement( "DN00B_ModelPanelPlus" )
			dShipmentIcon:ModifySize( 96, 96 )
			dShipmentIcon:LoadModel( shipment.model )
			dShipmentIcon:SetModelFOV( 45 )
			dShipmentIcon.dModelPanel.OnMousePressed = function( pnl, btn )
				entityList.currentCommand = "buyshipment " .. shipment.name
				self:GenerateEntityPreview( entityPreviewPanel, entityPreviewNameLabel, entityPreviewCostLabel, shipment.model, shipment.name .. " Shipment x" .. shipment.amount, shipment.price )
			end
		end
	end
end

function PANEL:LoadPlayerClothing( modelPanel, mdl )
	if not ( IsValid( modelPanel ) ) then return end
	for i=0, 10 do
		modelPanel:SetSubMaterial( i, "" )
	end
	timer.Simple( 0.1, function( )
		if not ( IsValid( modelPanel ) ) then return end
		if ( string.find( string.lower( mdl ), "group01/female" ) and LocalPlayer( ).femaleClothingMaterial ) then
			modelPanel:SetSubMaterial( player.GetClothingIndex( string.lower( mdl ) ), LocalPlayer( ).femaleClothingMaterial )
		elseif ( string.find( string.lower( mdl ), "group01/male" ) and LocalPlayer( ).maleClothingMaterial ) then
			modelPanel:SetSubMaterial( player.GetClothingIndex( string.lower( mdl ) ), LocalPlayer( ).maleClothingMaterial )
		end
	end )
end

function PANEL:GenerateJobsTab( )
	self.dContentPanel:Clear( )
	local jobTitleLabel = vgui.Create( "DLabel", self.dContentPanel )
	jobTitleLabel:SetPos( self.dContentPanel:GetWide( ) * 0.65, self.dContentPanel:GetTall( ) * 0.075 )
	local jobLimitLabel = vgui.Create( "DLabel", self.dContentPanel )
	jobLimitLabel:SetPos( self.dContentPanel:GetWide( ) * 0.575, self.dContentPanel:GetTall( ) * 0.075 )
	local jobsList = vgui.Create( "DN00B_ScrollableList", self.dContentPanel )
	jobsList:SetPos( self.dContentPanel:GetWide( ) * 0.05, self.dContentPanel:GetTall( ) * 0.075 )
	jobsList:SetSize( self.dContentPanel:GetWide( ) * 0.5, self.dContentPanel:GetTall( ) * 0.85 )
	jobsList.dIconLayout:SetSize( jobsList:GetWide( ), jobsList:GetTall( ) )
	jobsList.selectedTeam = 1
	local jobListX, jobListY = jobsList:GetPos( )
	local jobListW, jobListH = jobsList:GetSize( )

	local richTextBox = vgui.Create( "RichText", self.dContentPanel )
	richTextBox:SetSize( self.dContentPanel:GetWide( ) * 0.412, self.dContentPanel:GetTall( ) * 0.2 )
	richTextBox:SetPos( jobListX + jobListW + self.dContentPanel:GetWide( ) * 0.025, self.dContentPanel:GetTall( ) * 0.125 )
	richTextBox.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 25, 25, 25, 90 ) )
		richTextBox:SetFontInternal( "N00BRP_CustomF4Menu_SegoeUIBold" )
	end
	
	local playerModelPanel = vgui.Create( "DN00B_ModelPanelPlus", self.dContentPanel )
	playerModelPanel:ModifySize( self.dContentPanel:GetWide( ) * 0.275, self.dContentPanel:GetTall( ) * 0.6 )
	playerModelPanel:SetPos( jobListX + jobListW + self.dContentPanel:GetWide( ) * 0.025, jobListY + ( jobListH / 3.25 ) )
	playerModelPanel:LoadModel( RPExtraTeams[1].model[1] )
	self:LoadPlayerClothing( playerModelPanel, RPExtraTeams[1].model[1] )
	playerModelPanel:SetModelFOV( 18 )
	playerModelPanel:SetModelRotation( Angle( 0, 45, 0 ) )
	playerModelPanel:LookAtBone( "ValveBiped.Bip01_Spine2" )
	playerModelPanel:SetRandomSequence( )
	local mPanelX, mPanelY = playerModelPanel:GetPos( )

	local dModelSelection = vgui.Create( "DN00B_ScrollableList", self.dContentPanel )
	dModelSelection:SetSize( 74, self.dContentPanel:GetTall( ) * 0.6 )
	dModelSelection.dIconLayout:SetSize( dModelSelection:GetWide( ), dModelSelection:GetTall( ) )
	dModelSelection:SetPos( jobListX + jobListW + self.dContentPanel:GetWide( ) * 0.315, jobListY + ( jobListH / 3.25 ) )
	dModelSelectionOldPaint = dModelSelection.Paint
	dModelSelection.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 45, 45, 45, 90 ) )
		dModelSelectionOldPaint( pnl, w, h )
	end
	self:GenerateModelSelection( dModelSelection, playerModelPanel, RPExtraTeams[1].model )

	jobTitleLabel:SetFont( "N00BRP_CustomF4Menu_SegoeUIBoldLarge" )
	jobLimitLabel:SetFont( "N00BRP_CustomF4Menu_SegoeUIBoldLarge" )

	self:GenerateJobLabels( jobTitleLabel, jobLimitLabel, 1, RPExtraTeams[1] )
	self:GenerateJobDescription( richTextBox, RPExtraTeams[1].description )
	
	for index, rpTeam in ipairs ( RPExtraTeams ) do
		if ( isfunction( rpTeam.customCheck ) and !rpTeam.customCheck( LocalPlayer( ) ) ) then continue end
		local shouldContinue = true
		if ( rpTeam.NeedToChangeFrom ) then
			shouldContinue = false
			if ( istable( rpTeam.NeedToChangeFrom ) ) then
				for _, changeFromTeam in ipairs ( rpTeam.NeedToChangeFrom ) do
					if ( LocalPlayer( ):Team( ) == changeFromTeam ) then
						shouldContinue = true
						break
					end
				end
			else
				if ( LocalPlayer( ):Team( ) == rpTeam.NeedToChangeFrom ) then
					shouldContinue = true
				end
			end
		end
		if not ( shouldContinue ) then continue end
		local jobModel = rpTeam.model
		if ( istable( jobModel ) ) then jobModel = jobModel[1] end
		local teamColor = rpTeam.color
		local dJobIcon = jobsList:AddElement( "DN00B_ModelPanelPlus" )
		dJobIcon:ModifySize( 96, 96 )
		dJobIcon:LoadModel( jobModel )
		if ( index == TEAM_CITIZEN ) then
			self:LoadPlayerClothing( dJobIcon, jobModel )
		end
		dJobIcon:SetModelFOV( 10 )
		dJobIcon:LookAtBone( "ValveBiped.Bip01_Head1" )
		dJobIcon:SetModelRotation( Angle( 0, 45, 0 ) )
		dJobIcon.iconRoundness = 8
		dJobIcon.backgroundColor = Color( teamColor.r, teamColor.g, teamColor.b, 125 )
		dJobIcon.dModelPanel.OnMousePressed = function( pnl, btn )
			if ( jobsList.selectedTeam == index ) then
				if ( rpTeam.vote ) then
					LocalPlayer( ):ConCommand( "say /vote" .. rpTeam.command )
				else
					LocalPlayer( ):ConCommand( "say /" .. rpTeam.command )
				end
				self:Remove( )
				gui.EnableScreenClicker( false )
			else
				jobsList.selectedTeam = index
			end
			playerModelPanel:LoadModel( jobModel )
			self:LoadPlayerClothing( playerModelPanel, jobModel )
			playerModelPanel:LookAtBone( "ValveBiped.Bip01_Spine2" )
			playerModelPanel:SetRandomSequence( )
			self:GenerateJobDescription( richTextBox, rpTeam.description )
			self:GenerateModelSelection( dModelSelection, playerModelPanel, rpTeam.model, index )
			self:GenerateJobLabels( jobTitleLabel, jobLimitLabel, index, rpTeam )
		end
	end
	local dConfirmButton = vgui.Create( "DN00B_ColoredButton", self.dContentPanel )
	dConfirmButton:SetSize( 96, 16 )
	dConfirmButton:SetPos( mPanelX + ( playerModelPanel:GetWide( ) * 0.5 ) - ( 96 / 2 ), mPanelY + ( playerModelPanel:GetTall( ) ) )
	dConfirmButton:SetText( "Confirm" )
	dConfirmButton:SetButtonColor( Color( 255, 255, 255 ) )
	dConfirmButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dConfirmButton:SetTextColor( Color( 0, 0, 0 ) )
	dConfirmButton:SetRoundness( 0 )
	dConfirmButton.OnMousePressed = function( pnl, btn )
		if ( jobsList.selectedTeam ) then
			local teamTable = RPExtraTeams[ jobsList.selectedTeam ]
			if not ( teamTable ) then return end
			if ( teamTable.vote ) then
				LocalPlayer( ):ConCommand( "say /vote" .. teamTable.command )
			else
				LocalPlayer( ):ConCommand( "say /" .. teamTable.command )
			end
			self:Remove( )
			gui.EnableScreenClicker( false )
		end
	end
end

function PANEL:GenerateJobLabels( jobTitleLabel, jobLimitLabel, index, jobTable )
	local jobLimit = jobTable.max
	if ( jobLimit == 0 ) then jobLimit = "∞" end
	local customLimitTable = SHNOOB_VARS:Get( "CustomJobLimits" )
	if ( customLimitTable[ team.GetName( ( tonumber( index ) or 0 ) ) ] ) then
		jobLimit = customLimitTable[ team.GetName( index ) ]
	end
	local teamCount = team.GetPlayers( index )
	jobLimitLabel:SetText( #teamCount .. "/" .. jobLimit )
	jobLimitLabel:SetFont( "N00BRP_CustomF4Menu_SegoeUIBoldLarge" )
	jobLimitLabel:SetTextColor( Color( 0, 0, 0 ) )
	jobLimitLabel:SizeToContents( )
	jobTitleLabel:SetText( jobTable.name )
	jobTitleLabel:SetColor( Color( 0, 0, 0 ) )
	jobTitleLabel:SizeToContents( )
	local jobLimitX, jobLimitY = jobLimitLabel:GetPos( )
	local jobLimitW, jobLimitH = jobLimitLabel:GetSize( )
	jobTitleLabel:SetPos( jobLimitX + jobLimitW + 6, jobLimitY )
	jobTitleLabel.Paint = function( pnl, w, h )
		//draw.RoundedBox( 0, 0, 0, w, h, Color( 45, 45, 45, 90 ) )
		draw.SimpleText( jobTable.name, "N00BRP_CustomF4Menu_SegoeUIBoldLarge", 0, 0, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT )
	end
end

function PANEL:GenerateJobDescription( richTextBox, jobDescription )
	richTextBox:SetText( "" )
	for index, line in ipairs ( string.Explode( "\n", jobDescription ) ) do
		local newLine = string.Replace( line, "		", "" )
		richTextBox:InsertColorChange( 255, 255, 255, 255 )
		richTextBox:AppendText( newLine .. "\n" )
	end
end

function PANEL:GenerateModelSelection( dModelSelection, playerModelPanel, modelTable, teamIndex )
	local teamIndex = teamIndex
	if not ( teamIndex and LocalPlayer( ):Team( ) == TEAM_CITIZEN ) then teamIndex = TEAM_CITIZEN end
	dModelSelection:ClearItems( )
	if not ( istable( modelTable ) ) then dModelSelection:GetVBar( ):SetVisible( false ) return end
	dModelSelection:GetVBar( ):SetVisible( true )
	for index, mdl in ipairs ( modelTable ) do
		local spawnIcon = dModelSelection:AddElement( "SpawnIcon" )
		spawnIcon:SetSize( 64, 64 )
		spawnIcon:SetModel( mdl )
		spawnIcon.OnMousePressed = function( pnl, btn )
			DarkRP.setPreferredJobModel( teamIndex, mdl )
			playerModelPanel:LoadModel( mdl )
			self:LoadPlayerClothing( playerModelPanel, mdl )
			playerModelPanel:LookAtBone( "ValveBiped.Bip01_Spine2" )
			playerModelPanel:SetRandomSequence( )
		end
	end
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, Color( 24, 24, 24, 245 ) )
end

vgui.Register( "N00BRP_CustomF4Menu", PANEL, "Panel" )

function ToggleCustomF4Menu( )
	if ( ValidPanel( LocalPlayer( ).customF4Menu ) ) then
		LocalPlayer( ).customF4Menu:Remove( )
		gui.EnableScreenClicker( false )
	else
		LocalPlayer( ).customF4Menu = vgui.Create( "N00BRP_CustomF4Menu" )
	end
end

timer.Simple( 1, function( )
	GAMEMODE.ShowSpare2 = ToggleCustomF4Menu
end )
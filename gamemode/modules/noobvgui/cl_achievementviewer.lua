PANEL = { }

function PANEL:Init()
    self:SetSize( ScrW( ) * 0.6, ScrH( ) * 0.8 )
    self:Center( )
    self:SetupBasePanels( )
   	gui.EnableScreenClicker( true )
end

function PANEL:SetViewData( ply )
	self.viewPlayerName = ply:Name( )
	self.achieveTable = ply.achieveTable
	self:GenerateAchievements( nil, nil, nil )
	self.nameLabel:SetText( ply:Name( ) .. "'s Achievements" )
	self.nameLabel:SizeToContents( )
	self.nameLabel:CenterHorizontal( )
	self.nameLabel:AlignTop( self:GetTall( ) * 0.06 )
end

local completeMaterial = Material( "icon16/accept.png" )

function PANEL:GenerateAchievements( category, hideCompleted, hideIncompleted )
	if not ( self.achieveTable ) then return end
	self.achievementList:ClearItems( )
	self.lastCategory = category
	self.lastHideCompleted = hideCompleted
	self.lastHideIncompleted = hideIncompleted
	local completedAmount = 0
	local achieveAmount = table.Count ( NOOBRP.Achievements )
	for name, tbl in SortedPairsByMemberValue( NOOBRP.Achievements, "name", false ) do
		if ( category and tbl.category ~= category ) then continue end
		local isComplete = false
		local achievePanel = self.achievementList:AddElement( "DPanel" )
		achievePanel:SetSize( self.achievementList:GetWide( ), 96 )
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
		if ( self.achieveTable and self.achieveTable[ name ] ) then
			progress = self.achieveTable[ name ].progress
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
		if ( self.achieveTable and self.achieveTable[ name ] and self.achieveTable[ name ].completed ) then
			isComplete = true
			completedAmount = completedAmount + 1
			if ( hideCompleted ) then achievePanel:Remove( ) end
		else
			if ( hideIncompleted ) then achievePanel:Remove( ) end
		end
		achievePanel.Paint = function( pnl, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, Color( 45, 45, 45, 245 ) )
			if ( isComplete ) then
				local nameLabelX, nameLabelY = nameLabel:GetPos( )
				nameLabelX = nameLabelX + nameLabel:GetWide( ) + 8
				surface.SetMaterial( completeMaterial )
	       		surface.SetDrawColor( Color( 255, 255, 255 ) )
	      		surface.DrawTexturedRect( nameLabelX, nameLabelY + 4, 16, 16 )
	      	end
		end
	end
	local completionLabel = vgui.Create( "DLabel", self )
	completionLabel:SetText( "Achievements Completed: " .. completedAmount .. " / " .. achieveAmount )
	completionLabel:SetFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	completionLabel:SetTextColor( Color( 0, 0, 0 ) )
	completionLabel:SizeToContents( )
	completionLabel:CenterHorizontal( )
	completionLabel:AlignBottom( self:GetTall( ) * 0.1 )
end

function PANEL:ResetButtonColors( noChangePanel, buttonTable )
	for index, button in ipairs( buttonTable ) do
		if ( button == noChangePanel ) then continue end
		button:SetButtonColor( Color( 255, 255, 255 ) )
		button:SetTextColor( Color( 0, 0, 0 ) )
	end
end

function PANEL:SetupBasePanels( )
	local categoryTextColor = Color( 0, 0, 0 )
	local xOffset = self:GetWide( ) * 0.1
	local yOffset = self:GetTall( ) * 0.1
	self.nameLabel = vgui.Create( "DLabel", self )
	self.nameLabel:SetText( "" )
	self.nameLabel:SetFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	self.nameLabel:SetTextColor( Color( 255, 255, 255, 255 ) )
	self.achievementList = vgui.Create( "DN00B_ScrollableList", self )
	self.achievementList:SetPos( self:GetWide( ) * 0.15, self:GetTall( ) * 0.25 )
	self.achievementList:SetSize( self:GetWide( ) * 0.7, self:GetTall( ) * 0.6 )
	self.achievementList:DrawListBackground( 0, Color( 0, 0, 0, 0 ) )
	self.achievementList.dIconLayout:SetSize( self.achievementList:GetWide( ), self.achievementList:GetTall( ) )
	local achListX, achListY = self.achievementList:GetPos( )
	local dSkillButton = vgui.Create( "DN00B_ColoredButton", self )
	dSkillButton:SetSize( 64, 16 )
	dSkillButton:SetPos( xOffset + 32, yOffset + 16 )
	dSkillButton:SetText( "SKILLS" )
	dSkillButton:SetButtonColor( Color( 255, 255, 255 ) )
	dSkillButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dSkillButton:SetTextColor( categoryTextColor )
	dSkillButton:SetRoundness( 0 )
	dSkillButton.OnMousePressed = function( pnl, btn )
		self:GenerateAchievements( ENUM_ACHIEVEMENTS_CATEGORY_SKILL, self.lastHideCompleted, self.lastHideIncompleted )
		dSkillButton:SetButtonColor( Color( 45, 45, 175, 125 ) )
		dSkillButton:SetTextColor( Color( 255, 255, 255 ) )
		self:ResetButtonColors( dSkillButton, self.buttonTable )
	end
	local dMurderButton = vgui.Create( "DN00B_ColoredButton", self )
	dMurderButton:SetSize( 64, 16 )
	dMurderButton:SetPos( xOffset + 98, yOffset + 16 )
	dMurderButton:SetText( "MURDER" )
	dMurderButton:SetButtonColor( Color( 255, 255, 255 ) )
	dMurderButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dMurderButton:SetTextColor( categoryTextColor )
	dMurderButton:SetRoundness( 0 )
	dMurderButton.OnMousePressed = function( pnl, btn )
		self:GenerateAchievements( ENUM_ACHIEVEMENTS_CATEGORY_MURDER, self.lastHideCompleted, self.lastHideIncompleted )
		dMurderButton:SetButtonColor( Color( 45, 45, 175, 125 ) )
		dMurderButton:SetTextColor( Color( 255, 255, 255 ) )
		self:ResetButtonColors( dMurderButton, self.buttonTable )
	end
	local dCrimeAndLawButton = vgui.Create( "DN00B_ColoredButton", self )
	dCrimeAndLawButton:SetSize( 96, 16 )
	dCrimeAndLawButton:SetPos( xOffset + 164, yOffset + 16 )
	dCrimeAndLawButton:SetText( "CRIME & LAW" )
	dCrimeAndLawButton:SetButtonColor( Color( 255, 255, 255 ) )
	dCrimeAndLawButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dCrimeAndLawButton:SetTextColor( categoryTextColor )
	dCrimeAndLawButton:SetRoundness( 0 )
	dCrimeAndLawButton.OnMousePressed = function( pnl, btn )
		self:GenerateAchievements( ENUM_ACHIEVEMENTS_CATEGORY_CRIMEANDLAW, self.lastHideCompleted, self.lastHideIncompleted )
		dCrimeAndLawButton:SetButtonColor( Color( 45, 45, 175, 125 ) )
		dCrimeAndLawButton:SetTextColor( Color( 255, 255, 255 ) )
		self:ResetButtonColors( dCrimeAndLawButton, self.buttonTable )
	end
	local dEventButton = vgui.Create( "DN00B_ColoredButton", self )
	dEventButton:SetSize( 64, 16 )
	dEventButton:SetPos( xOffset + 262, yOffset + 16 )
	dEventButton:SetText( "EVENT" )
	dEventButton:SetButtonColor( Color( 255, 255, 255 ) )
	dEventButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dEventButton:SetTextColor( categoryTextColor )
	dEventButton:SetRoundness( 0 )
	dEventButton.OnMousePressed = function( pnl, btn )
		self:GenerateAchievements( ENUM_ACHIEVEMENTS_CATEGORY_EVENT, self.lastHideCompleted, self.lastHideIncompleted )
		dEventButton:SetButtonColor( Color( 45, 45, 175, 125 ) )
		dEventButton:SetTextColor( Color( 255, 255, 255 ) )
		self:ResetButtonColors( dEventButton, self.buttonTable )
	end
	local dJobRelatedButton = vgui.Create( "DN00B_ColoredButton", self )
	dJobRelatedButton:SetSize( 96, 16 )
	dJobRelatedButton:SetPos( xOffset + 328, yOffset + 16 )
	dJobRelatedButton:SetText( "JOB RELATED" )
	dJobRelatedButton:SetButtonColor( Color( 255, 255, 255 ) )
	dJobRelatedButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dJobRelatedButton:SetTextColor( categoryTextColor )
	dJobRelatedButton:SetRoundness( 0 )
	dJobRelatedButton.OnMousePressed = function( pnl, btn )
		self:GenerateAchievements( ENUM_ACHIEVEMENTS_CATEGORY_JOBRELATED, self.lastHideCompleted, self.lastHideIncompleted )
		dJobRelatedButton:SetButtonColor( Color( 45, 45, 175, 125 ) )
		dJobRelatedButton:SetTextColor( Color( 255, 255, 255 ) )
		self:ResetButtonColors( dJobRelatedButton, self.buttonTable )
	end
	local dGatherAndMineButton = vgui.Create( "DN00B_ColoredButton", self )
	dGatherAndMineButton:SetSize( 192, 16 )
	dGatherAndMineButton:SetPos( xOffset + 32, yOffset + 34 )
	dGatherAndMineButton:SetText( "GATHERING AND MINING" )
	dGatherAndMineButton:SetButtonColor( Color( 255, 255, 255 ) )
	dGatherAndMineButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dGatherAndMineButton:SetTextColor( categoryTextColor )
	dGatherAndMineButton:SetRoundness( 0 )
	dGatherAndMineButton.OnMousePressed = function( pnl, btn )
		self:GenerateAchievements( ENUM_ACHIEVEMENTS_CATEGORY_GATHERINGANDMINING, self.lastHideCompleted, self.lastHideIncompleted )
		dGatherAndMineButton:SetButtonColor( Color( 45, 45, 175, 125 ) )
		dGatherAndMineButton:SetTextColor( Color( 255, 255, 255 ) )
		self:ResetButtonColors( dGatherAndMineButton, self.buttonTable )
	end
	local dMiscButton = vgui.Create( "DN00B_ColoredButton", self )
	dMiscButton:SetSize( 64, 16 )
	dMiscButton:SetPos( xOffset + 226, yOffset + 34 )
	dMiscButton:SetText( "MISC" )
	dMiscButton:SetButtonColor( Color( 255, 255, 255 ) )
	dMiscButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dMiscButton:SetTextColor( categoryTextColor )
	dMiscButton:SetRoundness( 0 )
	dMiscButton.OnMousePressed = function( pnl, btn )
		self:GenerateAchievements( ENUM_ACHIEVEMENTS_CATEGORY_MISC, self.lastHideCompleted, self.lastHideIncompleted )
		dMiscButton:SetButtonColor( Color( 45, 45, 175, 125 ) )
		dMiscButton:SetTextColor( Color( 255, 255, 255 ) )
		self:ResetButtonColors( dMiscButton, self.buttonTable )
	end
	local dAllButton = vgui.Create( "DN00B_ColoredButton", self )
	dAllButton:SetSize( 64, 16 )
	dAllButton:SetPos( xOffset + 360, yOffset + 34 )
	dAllButton:SetText( "ALL" )
	dAllButton:SetButtonColor( Color( 45, 45, 175, 125 ) )
	dAllButton:SetTextColor( Color( 255, 255, 255 ) )
	dAllButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dAllButton:SetRoundness( 0 )
	dAllButton.OnMousePressed = function( pnl, btn )
		self:GenerateAchievements( nil )
		dAllButton:SetButtonColor( Color( 45, 45, 175, 125 ) )
		dAllButton:SetTextColor( Color( 255, 255, 255 ) )
		self:ResetButtonColors( dAllButton, self.buttonTable )
	end

	local dHideCompleted = vgui.Create( "DN00B_ColoredButton", self )
	dHideCompleted:SetSize( 128, 16 )
	dHideCompleted:SetPos( xOffset + 450, yOffset + 16 )
	dHideCompleted:SetText( "HIDE COMPLETED" )
	dHideCompleted:SetButtonColor( Color( 255, 255, 255 ) )
	dHideCompleted:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dHideCompleted:SetTextColor( Color( 175, 45, 45 ) )
	dHideCompleted:SetRoundness( 0 )
	dHideCompleted.OnMousePressed = function( pnl, btn )
		if ( self.lastHideIncompleted ) then return end
		self:GenerateAchievements( self.lastCategory, !( self.lastHideCompleted ), self.lastHideIncompleted )
		if ( self.lastHideCompleted ) then
			dHideCompleted:SetText( "SHOW COMPLETED" )
			dHideCompleted:SetTextColor( Color( 45, 175, 45 ) )
		else
			dHideCompleted:SetText( "HIDE COMPLETED" )
			dHideCompleted:SetTextColor( Color( 175, 45, 45 ) )
		end
	end

	local dHideIncompleted = vgui.Create( "DN00B_ColoredButton", self )
	dHideIncompleted:SetSize( 128, 16 )
	dHideIncompleted:SetPos( xOffset + 450, yOffset + 32 )
	dHideIncompleted:SetText( "HIDE INCOMPLETED" )
	dHideIncompleted:SetButtonColor( Color( 255, 255, 255 ) )
	dHideIncompleted:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	dHideIncompleted:SetTextColor( Color( 175, 45, 45 ) )
	dHideIncompleted:SetRoundness( 0 )
	dHideIncompleted.OnMousePressed = function( pnl, btn )
		if ( self.lastHideCompleted ) then return end
		self:GenerateAchievements( self.lastCategory, self.lastHideCompleted, !( self.lastHideIncompleted ) )
		if ( self.lastHideIncompleted ) then
			dHideIncompleted:SetText( "SHOW INCOMPLETED" )
			dHideIncompleted:SetTextColor( Color( 45, 175, 45 ) )
		else
			dHideIncompleted:SetText( "HIDE INCOMPLETED" )
			dHideIncompleted:SetTextColor( Color( 175, 45, 45 ) )
		end
	end
	self.buttonTable = { dSkillButton, dMurderButton, dCrimeAndLawButton, dEventButton, dJobRelatedButton, dMiscButton, dGatherAndMineButton, dAllButton }
	local closeButton = vgui.Create( "DN00B_ColoredButton", self )
	closeButton:SetSize( 64, 16 )
	closeButton:SetPos( ( self:GetWide( ) * 0.9 ) - 64, self:GetTall( ) * 0.1 - 16 )
	closeButton:SetText( "Close" )
	closeButton:SetButtonColor( Color( 255, 255, 255, 255 ) )
	closeButton:SetTextFont( "N00BRP_CustomF4Menu_SegoeUIBold" )
	closeButton:SetTextColor( Color( 175, 45, 45, 255 ) )
	closeButton:SetRoundness( 0 )
	closeButton.OnMousePressed = function( btn )
		self:Remove( )
		gui.EnableScreenClicker( false )
	end
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, Color( 24, 24, 24, 245 ) )
    draw.RoundedBox( 0, w * 0.1, h * 0.1, w * 0.8, h * 0.8, Color( 255, 255, 255, 200 ) )
end

vgui.Register( "N00BRP_AchievementViewer", PANEL, "Panel" )
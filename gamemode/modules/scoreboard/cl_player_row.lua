-- include("player_infocard.lua")

color_white = Color(255,255,255,255)

surface.CreateFont( "ScoreboardPlayerName", {
	font = "Arial",
	size = 18,
	weight = 700,
	antialias = true,
	additive = false
} );


local texGradient = surface.GetTextureID("gui/center_gradient")
local texRatings = {}

texRatings[ 'none' ] 		= surface.GetTextureID("gui/silkicons/user")
texRatings[ 'smile' ] 		= surface.GetTextureID("gui/silkicons/emoticon_smile")
texRatings[ 'friendly' ] 	= surface.GetTextureID("gui/silkicons/group")
texRatings[ 'love' ] 		= surface.GetTextureID("gui/silkicons/heart")
texRatings[ 'artistic' ] 	= surface.GetTextureID("gui/silkicons/palette")
texRatings[ 'star' ] 		= surface.GetTextureID("gui/silkicons/star")
texRatings[ 'builder' ] 	= surface.GetTextureID("gui/silkicons/wrench")

surface.GetTextureID("gui/silkicons/emoticon_smile")
local PANEL = {}

/*---------------------------------------------------------
Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()
	if not IsValid(self.Player) then return end

	local color = team.GetColor(self.Player:Team())
	
	if ( self.Player:getDarkRPVar( "IsDisguised" ) ) then
		color = team.GetColor( self.Player:getDarkRPVar( "IsDisguised" ) )
	end
	if self.Open or self.Size != self.TargetSize then
		draw.RoundedBox(4, 0, 16, self:GetWide(), self:GetTall() - 16, color)
		draw.RoundedBox(4, 2, 16, self:GetWide()-4, self:GetTall() - 16 - 2, Color(255, 255, 255, 255))

		surface.SetTexture(texGradient)
		surface.SetDrawColor(255, 255, 255, 0)
		surface.DrawTexturedRect(2, 16, self:GetWide()-4, self:GetTall() - 16 - 2)
	end

	draw.RoundedBox(4, 0, 0, self:GetWide(), 24, color)

	surface.SetTexture(texGradient)
	surface.SetDrawColor(255, 255, 255, 0)
	surface.DrawTexturedRect(0, 0, self:GetWide(), 24)

	if ( self.texRating ) then
		surface.SetTexture(self.texRating)
		surface.SetDrawColor(200, 200, 200, 255)
		surface.DrawTexturedRect(4, 4, 16, 16)
	end

	return true
end

/*---------------------------------------------------------
Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:SetPlayer(ply)
	if not IsValid(ply) then return end
	self.Player = ply
	self.infoCard:SetPlayer(ply)
	self:UpdatePlayerData()
end

function PANEL:CheckRating(name, count)
	if not IsValid(self.Player) then return end

	if self.Player:GetNWInt("Rating."..name, 0) > count then
		count = self.Player:GetNWInt("Rating."..name, 0)
		self.texRating = texRatings[ name ]
	end

	return count
end

/*---------------------------------------------------------
Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:UpdatePlayerData()
	if not IsValid(self.Player) then return end
	local Team = LocalPlayer():Team()
	self.lblName:SetText(self.Player:Nick())
	self.lblName:SizeToContents()

	if ( self.Player:getDarkRPVar( "IsAFK" ) and not self.Player:IsAdmin() ) then
		self.lblAFK:SetText( "AFK" )
	else
		self.lblAFK:SetText( "" )
	end

	local jobName = ( self.Player.getDarkRPVar and self.Player:getDarkRPVar( "job" ) ) or "Citizen";
	if ( self.Player:getDarkRPVar( "IsDisguised" ) ) then
		jobName = RPExtraTeams[ self.Player:getDarkRPVar( "IsDisguised" ) ].name;
	end

	self.lblJob:SetText( jobName );
	self.lblJob:SizeToContents()
	self.lblPing:SetText(self.Player:Ping())
	local endur = 0;
	if ( !self.Player:IsBot() ) then
		endur = NOOBRP_SkillAlgorithms:CalculateEndurance( self.Player )[ "CurrentLevel" ];
	end
	endur = ( endur < 1 and 0 ) or endur;
	self.lblEndurance:SetText(endur)
	self.lblWarranted:SetImage("gui/silkicons/exclamation")
	self.lblVIP:SetImage("noobonic/vip")
	if self.Player:isWanted() then
		self.lblWarranted:SetVisible(true)
	else
		self.lblWarranted:SetVisible(false)
	end
	if self.Player:IsVIP() then
		self.lblVIP:SetVisible(true)
		self.lblName:SetPos(60, 3)
	else
		self.lblVIP:SetVisible(false)
		self.lblName:SetPos(24, 3)
	end

	-- Work out what icon to draw
	self.texRating = surface.GetTextureID("gui/silkicons/emoticon_smile")

	self.texRating = texRatings[ 'none' ]
	local count = 0

	count = self:CheckRating('smile', count)
	count = self:CheckRating('love', count)
	count = self:CheckRating('artistic', count)
	count = self:CheckRating('star', count)
	count = self:CheckRating('builder', count)
	count = self:CheckRating('friendly', count)
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Init()
	self.Size = 24
	self:OpenInfo(false)
	self.infoCard = vgui.Create("ScorePlayerInfoCard", self)
	self.lblName = vgui.Create("DLabel", self)
	self.lblJob = vgui.Create("DLabel", self)
	self.lblPing = vgui.Create("DLabel", self)
	self.lblEndurance = vgui.Create("DLabel", self)
	self.lblWarranted = vgui.Create("DImage", self)
	self.lblWarranted:SetSize(16,16)
	self.lblVIP = vgui.Create("DImage", self)
	self.lblVIP:SetSize(32,16)
	self.lblAFK = vgui.Create("DLabel", self)
	-- If you don't do this it'll block your clicks
	self.lblName:SetMouseInputEnabled(false)
	self.lblJob:SetMouseInputEnabled(false)
	self.lblPing:SetMouseInputEnabled(false)
	self.lblWarranted:SetMouseInputEnabled(false)
	self.lblVIP:SetMouseInputEnabled(false)
	self.lblEndurance:SetMouseInputEnabled(false)
	self.lblAFK:SetMouseInputEnabled(false)
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()
	self.lblName:SetFont("ScoreboardPlayerName")
	self.lblJob:SetFont("ScoreboardPlayerName")
	self.lblPing:SetFont("ScoreboardPlayerName")
	self.lblEndurance:SetFont("ScoreboardPlayerName")
	self.lblAFK:SetFont( "ScoreboardPlayerName" )
	self.lblAFK:SetTextColor( Color( 175, 45, 45 ) )
	self.lblName:SetFGColor(color_white)
	self.lblJob:SetFGColor(color_white)
	self.lblPing:SetFGColor(color_white)
	self.lblEndurance:SetFGColor(color_white)
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:DoClick()
	if self.Open then
		surface.PlaySound("ui/buttonclickrelease.wav")
	else
		surface.PlaySound("ui/buttonclick.wav")
	end

	self:OpenInfo(not self.Open)
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:OpenInfo(bool)
	if bool then
		self.TargetSize = 150
	else
		self.TargetSize = 24
	end

	self.Open = bool
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Think()
	if self.Size != self.TargetSize then
		self.Size = math.Approach(self.Size, self.TargetSize, (math.abs(self.Size - self.TargetSize) + 1) * 10 * FrameTime())
		self:PerformLayout()
		SCOREBOARD:InvalidateLayout()
	end

	if not self.PlayerUpdate or self.PlayerUpdate < CurTime() then
		self.PlayerUpdate = CurTime() + 0.5
		self:UpdatePlayerData()
	end
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()
	self:SetSize(self:GetWide(), self.Size)
	self.lblName:SizeToContents()
	if self.Player:IsVIP() then
		self.lblName:SetPos(60, 3)
	else
		self.lblName:SetPos(24, 3)
	end

	local COLUMN_SIZE = 50

	self.lblPing:SetPos(self:GetWide() - COLUMN_SIZE * 1, 2)
	self.lblEndurance:SetPos(self:GetWide() - (COLUMN_SIZE + 58), 2)
	self.lblJob:SetPos(self:GetWide() - COLUMN_SIZE * 7.3, 2)
	self.lblWarranted:SetPos(self:GetWide() - COLUMN_SIZE * 8.8, 5)
	self.lblVIP:SetPos(24, 4)
	self.lblAFK:SetPos( self:GetWide( ) - COLUMN_SIZE * 3.5, 2 )
	if self.Open or self.Size != self.TargetSize then
		self.infoCard:SetVisible(true)
		self.infoCard:SetPos(4, self.lblName:GetTall() + 10)
		self.infoCard:SetSize(self:GetWide() - 8, self:GetTall() - self.lblName:GetTall() - 10)
	else
		self.infoCard:SetVisible(false)
	end
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:HigherOrLower(row)
	if not IsValid(row.Player) or not IsValid(self.Player) then return false end

	if self.Player:Team() == TEAM_CONNECTING then return false end
	if row.Player:Team() == TEAM_CONNECTING then return true end

	local rowteam = row.Player:Team()
	local selfteam = self.Player:Team()
	if ( !row.Player:IsBot() and !self.Player:IsBot() ) then
		if row.Player:getDarkRPVar( "IsDisguised" ) then rowteam = row.Player:getDarkRPVar( "IsDisguised" ) end
		if self.Player:getDarkRPVar( "IsDisguised" ) then selfteam = self.Player:getDarkRPVar( "IsDisguised" ) end
	end

	if team.GetName(selfteam) == team.GetName(rowteam) then
		return team.GetName(selfteam) < team.GetName(rowteam)
	end

	return team.GetName(selfteam) < team.GetName(rowteam)
end

vgui.Register("ScorePlayerRow", PANEL, "Button")

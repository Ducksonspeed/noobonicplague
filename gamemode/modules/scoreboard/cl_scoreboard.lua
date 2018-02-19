surface.CreateFont( "Tahoma", { font = "Tahoma", size = 12, weight = 500, antialiasing = true } );

-- include("player_row.lua")
-- include("player_frame.lua")
-- SetGlobalString("servertype", "Listen") -- wtf is this even for

surface.CreateFont("ScoreboardHeader", {
	font = "Impact",
	size = 32,
	weight = 500,
	antialias = true,
	additive = false})
surface.CreateFont("ScoreboardSubtitle", {
	font = "Arial",
	size = 16,
	weight = 700,
	antialias = true,
	additive = false})
surface.CreateFont("ScoreboardText", {
	font = "Arial",
	size = 20,
	weight = 500,
	antialias = true,
	additive = false})

local texGradient = surface.GetTextureID("gui/center_gradient")

local PANEL = {}

/*---------------------------------------------------------
Name: Paint
---------------------------------------------------------*/
function PANEL:Init()
	SCOREBOARD = self

	self.Hostname = vgui.Create("DLabel", self)
	self.Hostname:SetText( "Noobonic Plague Legacy // www.NoobonicPlague.com" );

	self.Description = vgui.Create("DLabel", self)
	self.Description:SetText( "DarkRP by Rickster | Noobonic Plague by Sinavestos | Updated by Schmal, Cobra, Rocksofspades, Infamous Jeezy" );

	self.PlayerFrame = vgui.Create("PlayerFrame", self)

	self.PlayerRows = {}

	self:UpdateScoreboard()

	-- Update the scoreboard every 1 second
	timer.Create("ScoreboardUpdater", 1, 0, function() self.UpdateScoreboard(self) end)

	self.lblJob = vgui.Create("DLabel", self)
	self.lblJob:SetText("Job")

	self.lblPing = vgui.Create("DLabel", self)
	self.lblPing:SetText("Ping")
	
	self.lblWarranted = vgui.Create("DLabel", self)
	self.lblWarranted:SetText("Warranted")

	self.lblEndurance = vgui.Create("DLabel", self)
	self.lblEndurance:SetText("Endurance")
end

/*---------------------------------------------------------
Name: Paint
---------------------------------------------------------*/
function PANEL:AddPlayerRow(ply)
	local button = vgui.Create("ScorePlayerRow", self.PlayerFrame:GetCanvas())
	button:SetPlayer(ply)
	self.PlayerRows[ ply ] = button
end

/*---------------------------------------------------------
Name: Paint
---------------------------------------------------------*/
function PANEL:GetPlayerRow(ply)
	return self.PlayerRows[ ply ]
end

/*---------------------------------------------------------
Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()
	draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), Color(32, 32, 32, 200))
	surface.SetTexture(texGradient)
	surface.SetDrawColor(255, 255, 255, 0)
	surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())

	-- White Inner Box
	draw.RoundedBox(4, 4, self.Description.y - 4, self:GetWide() - 8, self:GetTall() - self.Description.y - 4, Color(230, 230, 230, 10))
	surface.SetTexture(texGradient)
	surface.SetDrawColor(255, 255, 255, 0)
	surface.DrawTexturedRect(4, self.Description.y - 4, self:GetWide() - 8, self:GetTall() - self.Description.y - 4)

	-- Sub Header
	draw.RoundedBox(4, 5, self.Description.y - 3, self:GetWide() - 10, self.Description:GetTall() + 5, Color(0, 0, 0, 200))
	surface.SetTexture(texGradient)
	surface.SetDrawColor(0, 0, 0, 0)
	surface.DrawTexturedRect(4, self.Description.y - 4, self:GetWide() - 8, self.Description:GetTall() + 8)
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()
	self:SetSize(800, ScrH() * 0.95)
	self:SetPos((ScrW() - self:GetWide()) / 2, (ScrH() - self:GetTall()) / 2)

	self.Hostname:SizeToContents()
	self.Hostname:SetPos(16, 16)

	self.Description:SizeToContents()
	self.Description:SetPos(16, 64)

	self.PlayerFrame:SetPos(5, self.Description.y + self.Description:GetTall() + 20)
	self.PlayerFrame:SetSize(self:GetWide() - 10, self:GetTall() - self.PlayerFrame.y - 10)

	local y = 0

	local PlayerSorted = {}

	for k, v in pairs(self.PlayerRows) do
		table.insert(PlayerSorted, v)
	end

	table.sort(PlayerSorted, function (a , b) return a:HigherOrLower(b) end)

	for k, v in ipairs(PlayerSorted) do
		v:SetPos(0, y)
		v:SetSize(self.PlayerFrame:GetWide(), v:GetTall())

		self.PlayerFrame:GetCanvas():SetSize(self.PlayerFrame:GetCanvas():GetWide(), y + v:GetTall())
		y = y + v:GetTall() + 1
	end


	if ( ValidPanel( self.lblPing ) ) then self.lblPing:SizeToContents() end
	if ( ValidPanel( self.lblJob ) ) then self.lblJob:SizeToContents() end
	if ( ValidPanel( self.lblWarranted ) ) then self.lblWarranted:SizeToContents() end
	if ( ValidPanel( self.lblEndurance ) ) then self.lblEndurance:SizeToContents() end

	if ( ValidPanel( self.lblPing ) ) then self.lblPing:SetPos(self:GetWide() - 50 - self.lblPing:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3) end
	if ( ValidPanel( self.lblEndurance ) ) then self.lblEndurance:SetPos(self:GetWide() - 100 - self.lblEndurance:GetWide()/2, self.PlayerFrame.y - self.lblEndurance:GetTall() - 3) end
	if ( ValidPanel( self.lblJob ) ) then self.lblJob:SetPos(self:GetWide() - 50*7 - self.lblJob:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3) end
	if ( ValidPanel( self.lblWarranted ) ) then self.lblWarranted:SetPos(self:GetWide() - 50*9 - self.lblJob:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3) end
end

/*---------------------------------------------------------
Name: ApplySchemeSettings
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()
	self.Hostname:SetFont("ScoreboardHeader")
	self.Description:SetFont("ScoreboardSubtitle")

	self.Hostname:SetFGColor(Color(255, 255, 255, 255))
	self.Description:SetFGColor(Color(255,255,255,255))

	self.lblPing:SetFont( "Tahoma" );
	self.lblEndurance:SetFont( "Tahoma" );
	self.lblJob:SetFont( "Tahoma" );
	self.lblWarranted:SetFont( "Tahoma" );

	self.lblPing:SetTextColor( Color( 200, 200, 200, 255 ) )
	self.lblEndurance:SetTextColor( Color( 200, 200, 200, 255 ) );
	self.lblJob:SetTextColor( Color( 200, 200, 200, 255 ) );
	self.lblWarranted:SetTextColor( Color( 200, 200, 200, 255 ) );
end

function PANEL:UpdateScoreboard(force)
	if not ValidPanel( self ) then return end
	if not force and not self:IsVisible() then return end

	for k, v in pairs(self.PlayerRows) do
		if not IsValid(k) then
			v:Remove()
			self.PlayerRows[ k ] = nil
		end
	end

	local PlayerList = player.GetAll()
	for id, pl in pairs(PlayerList) do
		if not self:GetPlayerRow(pl) then
			self:AddPlayerRow(pl)
		end
	end

	-- Always invalidate the layout so the order gets updated
	self:InvalidateLayout()

	local PlayerList = player.GetAll()
	for id, pl in pairs(PlayerList) do
		self:HidePlayerRow( pl );
	end
end

function PANEL:HidePlayerRow( pl )
	pl.scoreboard_hidden = ( pl:IsAdmin( ) and pl:getDarkRPVar( "AdminHidden" ) ) or false
	if ( pl.scoreboard_hidden and self:GetPlayerRow( pl ) ) then
		self.PlayerRows[ pl ]:Remove();
		self.PlayerRows[ pl ] = nil;
	elseif ( !pl.scoreboard_hidden and !self:GetPlayerRow( pl ) ) then
		self:AddPlayerRow( pl );
	end
end



vgui.Register("ScoreBoard", PANEL, "Panel")

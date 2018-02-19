-- include("admin_buttons.lua")
-- include("vote_button.lua")

surface.CreateFont( "Tahoma", { font = "Tahoma", size = 12, weight = 500, antialiasing = true } );

local PANEL = {}

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Init()
	self.InfoLabels = {}
	self.InfoLabels[ 1 ] = {}
	self.InfoLabels[ 2 ] = {}

	--self.btnKick = vgui.Create("PlayerKickButton", self)
	--self.btnBan = vgui.Create("PlayerBanButton", self)
	--self.btnPBan = vgui.Create("PlayerPermBanButton", self)

	self.btnUserID = vgui.Create( "DN00B_ColoredButton", self )
	self.btnTrade = vgui.Create( "DN00B_ColoredButton", self )
	self.btnMute = vgui.Create( "DN00B_ColoredButton", self )
	self.btnUnMute = vgui.Create( "DN00B_ColoredButton", self )
	if ( LocalPlayer( ):IsAdmin( ) ) then
		self.btnUniqueID = vgui.Create( "DN00B_ColoredButton", self )
		self.btnEntIndex = vgui.Create( "DN00B_ColoredButton", self )
	end
	self.btnPWarrant = vgui.Create("PlayerWarrantButton", self)

	self.VoteButtons = {}

	self.VoteButtons[1] = vgui.Create("SpawnMenuVoteButton", self)
	self.VoteButtons[1]:SetUp("group", "friendly", "Friendly Roleplayer!")

	self.VoteButtons[2] = vgui.Create("SpawnMenuVoteButton", self)
	self.VoteButtons[2]:SetUp("emoticon_smile", "smile", "Very Nice Roleplayer!")

	self.VoteButtons[3] = vgui.Create("SpawnMenuVoteButton", self)
	self.VoteButtons[3]:SetUp("heart", "love", "This player is Friendly!")

	self.VoteButtons[4] = vgui.Create("SpawnMenuVoteButton", self)
	self.VoteButtons[4]:SetUp("palette", "artistic", "This player is Smart!")

	self.VoteButtons[5] = vgui.Create("SpawnMenuVoteButton", self)
	self.VoteButtons[5]:SetUp("star", "star", "This player is Helpful!")

	self.VoteButtons[6] = vgui.Create("SpawnMenuVoteButton", self)
	self.VoteButtons[6]:SetUp("wrench", "builder", "This player is a tool!")
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:SetInfo(column, k, v)
	if not v or v == "" then v = "N/A" end

	if not self.InfoLabels[ column ][ k ] then
		self.InfoLabels[ column ][ k ] = {}
		self.InfoLabels[ column ][ k ].Key 		= vgui.Create("Label", self)
		self.InfoLabels[ column ][ k ].Value 	= vgui.Create("Label", self)
		self.InfoLabels[ column ][ k ].Key:SetText(k)
		self:InvalidateLayout()
	end

	self.InfoLabels[ column ][ k ].Value:SetText(v)
	return true
end

/*---------------------------------------------------------
Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:SetPlayer(ply)
	self.Player = ply
	self:UpdatePlayerData()
end

/*---------------------------------------------------------
Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:UpdatePlayerData()
	if not IsValid(self.Player) then return end
/*
	self:SetInfo(1, "Website:", self.Player:GetWebsite())
	self:SetInfo(1, "Location:", self.Player:GetLocation())
	self:SetInfo(1, "Email:", self.Player:GetEmail())
	self:SetInfo(1, "GTalk:", self.Player:GetGTalk())
	self:SetInfo(1, "MSN:", self.Player:GetMSN())
	self:SetInfo(1, "AIM:", self.Player:GetAIM())
	self:SetInfo(1, "XFire:", self.Player:GetXFire())
*/
	self:SetInfo(2, "Props:", self.Player:GetCount("props") + self.Player:GetCount("ragdolls") + self.Player:GetCount("effects"))
	self:SetInfo(2, "HoverBalls:", self.Player:GetCount("hoverballs"))
	self:SetInfo(2, "Thrusters:", self.Player:GetCount("thrusters"))
	self:SetInfo(2, "SENTs:", self.Player:GetCount("sents"))

	self:InvalidateLayout()
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()
	for _k, column in pairs(self.InfoLabels) do
		for k, v in pairs(column) do
			v.Key:SetFGColor(0, 0, 0, 100)
			v.Value:SetFGColor(0, 70, 0, 200)
		end
	end
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Think()
	if self.PlayerUpdate and self.PlayerUpdate > CurTime() then return end

	self.PlayerUpdate = CurTime() + 0.25
	self:UpdatePlayerData()
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()
	local x = 5

	for colnum, column in pairs(self.InfoLabels) do
		local y = 0
		local RightMost = 0

		for k, v in pairs(column) do
			v.Key:SetPos(x, y)
			v.Key:SizeToContents()
			v.Value:SetPos(x + 70 , y)
			v.Value:SizeToContents()
			y = y + v.Key:GetTall() + 2
			RightMost = math.max(RightMost, v.Value.x + v.Value:GetWide())
		end
		-- x = RightMost + 10
		x = x + 300
	end

	-- if not self.Player or
	-- 	self.Player == LocalPlayer() or
	-- 	not LocalPlayer():IsAdmin() then
	-- 		self.btnKick:SetVisible(false)
	-- 		self.btnBan:SetVisible(false)
	-- 		self.btnPBan:SetVisible(false)
	-- else
	-- 	self.btnKick:SetVisible(true)
	-- 	self.btnBan:SetVisible(true)
	-- 	self.btnPBan:SetVisible(true)

	-- 	self.btnKick:SetPos(self:GetWide() - 52 * 3, 90)
	-- 	self.btnKick:SetSize(48, 20)

	-- 	self.btnBan:SetPos(self:GetWide() - 52 * 2, 90)
	-- 	self.btnBan:SetSize(48, 20)

	-- 	self.btnPBan:SetPos(self:GetWide() - 52 * 1, 90)
	-- 	self.btnPBan:SetSize(48, 20)
	-- end

	if ( !IsValid( self.Player ) or !isfunction( self.Player.getDarkRPVar ) ) then return end
	self.btnUserID:SetSize( ScrW( ) * 0.05, ScrH( ) * 0.025 )
	self.btnUserID:SetPos( self:GetWide( ) - 50 * 15.5, 8 )
	self.btnUserID:SetText( "Get UserID" )
	self.btnUserID:SetTextFont( "Tahoma" )
	self.btnUserID:SetButtonColor( team.GetColor( self.Player:IsDisguised( ) or self.Player:Team( ) ) )
	self.btnUserID:SetTextColor( Color( 255, 255, 255 ) ) 
	self.btnUserID.OnMousePressed = function( pnl, btn )
		notification.AddLegacy( "Copied UserID to your Clipboard.", 1, 4 )
		SetClipboardText( self.Player:UserID( ) )
	end

	self.btnTrade:SetSize( ScrW( ) * 0.05, ScrH( ) * 0.025 )
	self.btnTrade:SetPos( self:GetWide( ) - 50 * 15.5, 34 )
	self.btnTrade:SetText( "Trade" )
	self.btnTrade:SetTextFont( "Tahoma" )
	self.btnTrade:SetButtonColor( team.GetColor( self.Player:IsDisguised( ) or self.Player:Team( ) ) )
	self.btnTrade:SetTextColor( Color( 255, 255, 255 ) ) 
	self.btnTrade.OnMousePressed = function( pnl, btn )
		LocalPlayer( ):ConCommand( "say /trade " .. self.Player:UserID( ) )
	end

	self.btnMute:SetSize( ScrW( ) * 0.05, ScrH( ) * 0.025 )
	self.btnMute:SetPos( self:GetWide( ) - 50 * 15.5, 60 )
	self.btnMute:SetText( "Mute" )
	self.btnMute:SetTextFont( "Tahoma" )
	self.btnMute:SetButtonColor( team.GetColor( self.Player:IsDisguised( ) or self.Player:Team( ) ) )
	self.btnMute:SetTextColor( Color( 255, 255, 255 ) ) 
	self.btnMute.OnMousePressed = function( pnl, btn )
		LocalPlayer( ):ConCommand( "say /mute " .. self.Player:UserID( ) )
	end

	self.btnUnMute:SetSize( ScrW( ) * 0.05, ScrH( ) * 0.025 )
	self.btnUnMute:SetPos( self:GetWide( ) - 50 * 15.5, 86 )
	self.btnUnMute:SetText( "UnMute" )
	self.btnUnMute:SetTextFont( "Tahoma" )
	self.btnUnMute:SetButtonColor( team.GetColor( self.Player:IsDisguised( ) or self.Player:Team( ) ) )
	self.btnUnMute:SetTextColor( Color( 255, 255, 255 ) ) 
	self.btnUnMute.OnMousePressed = function( pnl, btn )
		LocalPlayer( ):ConCommand( "say /unmute " .. self.Player:UserID( ) )
	end

	if ( LocalPlayer( ):IsAdmin( ) ) then
		self.btnUniqueID:SetSize( ScrW( ) * 0.075, ScrH( ) * 0.025 )
		self.btnUniqueID:SetPos( self:GetWide( ) - 50 * 14, 8 )
		self.btnUniqueID:SetText( "Get UniqueID" )
		self.btnUniqueID:SetTextFont( "Tahoma" )
		self.btnUniqueID:SetButtonColor( team.GetColor( self.Player:IsDisguised( ) or self.Player:Team( ) ) )
		self.btnUniqueID:SetTextColor( Color( 255, 255, 255 ) ) 
		self.btnUniqueID.OnMousePressed = function( pnl, btn )
			notification.AddLegacy( "Copied UniqueID to your Clipboard.", 1, 4 )
			SetClipboardText( self.Player:SafeUniqueID( ) )
		end
		self.btnEntIndex:SetSize( ScrW( ) * 0.075, ScrH( ) * 0.025 )
		self.btnEntIndex:SetPos( self:GetWide( ) - 50 * 14, 34 )
		self.btnEntIndex:SetText( "Get Entity Index" )
		self.btnEntIndex:SetTextFont( "Tahoma" )
		self.btnEntIndex:SetButtonColor( team.GetColor( self.Player:IsDisguised( ) or self.Player:Team( ) ) )
		self.btnEntIndex:SetTextColor( Color( 255, 255, 255 ) ) 
		self.btnEntIndex.OnMousePressed = function( pnl, btn )
			notification.AddLegacy( "Copied Entity Index to your Clipboard.", 1, 4 )
			SetClipboardText( self.Player:EntIndex( ) )
		end
	end

	local Team = LocalPlayer():Team()
	if self.Player ~= LocalPlayer() and ( Team == TEAM_POLICE or Team == TEAM_CHIEF or Team == TEAM_MAYOR ) then
		self.btnPWarrant:SetVisible(true)
		self.btnPWarrant:SetPos(self:GetWide() - 50 * 9.1, 90)
	else
		self.btnPWarrant:SetVisible(false)
	end

	for k, v in ipairs(self.VoteButtons) do
		v:InvalidateLayout()
		v:SetPos(self:GetWide() -  k * 25, 0)
		v:SetSize(20, 32)
	end
end

function PANEL:Paint()
	return true
end

vgui.Register("ScorePlayerInfoCard", PANEL, "Panel")

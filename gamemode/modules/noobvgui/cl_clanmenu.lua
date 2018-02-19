surface.CreateFont( "N00BRP_ClanMenu_TextFont", {
	font = "Segoe UI Bold",
	size = ScreenScale( 8 ),
	weight = 600,
	blursize = 0,
} )

surface.CreateFont( "N00BRP_ClanMenu_TitleFont", {
	font = "Segoe UI Bold",
	size = ScreenScale( 10 ),
	weight = 600,
	blursize = 0,
} )

local clanRanks = { }
clanRanks[1] = "Leader"
clanRanks[2] = "Officer"
clanRanks[0] = "Member"

local myClanTable = { }
local currentlyRetrieving = false
PANEL = { }

function PANEL:Init()
    self:SetSize( ScrW( ) * 0.4, ScrH( ) * 0.5 )
    self:Center( )
    self:SetupButtons( )
   	gui.EnableScreenClicker( true )
end

function PANEL:Paint( w, h )
	if not ( LocalPlayer( ):GetClan( ) ) then self:Remove( ) return end
    draw.RoundedBox( 0, 0, 0, w, h, Color( 24, 24, 24, 245 ) )
    draw.SimpleText( "< " .. LocalPlayer( ):GetClan( ) .. " >", "N00BRP_ClanMenu_TitleFont", w * 0.775, h * 0.1, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
    local warClan = LocalPlayer( ):getDarkRPVar( "AtWarWithClan" )
    if ( warClan ) then
    	draw.SimpleText( "At War With:", "N00BRP_ClanMenu_TextFont", w * 0.775, h * 0.445, Color( 192, 57, 43 ), TEXT_ALIGN_CENTER )
    	draw.SimpleText( "< " .. warClan .. " >", "N00BRP_ClanMenu_TextFont", w * 0.775, h * 0.485, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
    end
end

function PANEL:SetupButtons( )
	local leaveButton = vgui.Create( "DN00B_ColoredButton", self )
	leaveButton:SetText( "Leave Clan" )
	leaveButton:SetTextFont( "N00BRP_ClanMenu_TitleFont" )
	leaveButton:SetSize( self:GetWide( ) * 0.185, self:GetTall( ) * 0.075 )
	leaveButton:AlignRight( self:GetWide( ) * 0.135 )
	leaveButton:AlignTop( self:GetTall( ) * 0.175 )
	leaveButton:SetButtonColor( Color( 108, 122, 137 ) )
	leaveButton:SetTextColor( Color( 255, 255, 255 ) )
	leaveButton.OnMousePressed = function( btn )
		LocalPlayer( ):ConCommand( "rp_leaveclan" )
		self:Remove( )
	end
	local disbandButton = vgui.Create( "DN00B_ColoredButton", self )
	disbandButton:SetText( "Disband Clan" )
	disbandButton:SetTextFont( "N00BRP_ClanMenu_TitleFont" )
	disbandButton:SetSize( self:GetWide( ) * 0.185, self:GetTall( ) * 0.075 )
	disbandButton:AlignRight( self:GetWide( ) * 0.135 )
	disbandButton:AlignTop( self:GetTall( ) * 0.26 )
	disbandButton:SetButtonColor( Color( 108, 122, 137 ) )
	disbandButton:SetTextColor( Color( 255, 255, 255 ) )
	disbandButton.OnMousePressed = function( btn )
		LocalPlayer( ):ConCommand( "rp_disbandclan" )
		self:Remove( )
	end
	local ceaseWarButton = vgui.Create( "DN00B_ColoredButton", self )
	ceaseWarButton:SetText( "Cease War" )
	ceaseWarButton:SetTextFont( "N00BRP_ClanMenu_TitleFont" )
	ceaseWarButton:SetSize( self:GetWide( ) * 0.185, self:GetTall( ) * 0.075 )
	ceaseWarButton:AlignRight( self:GetWide( ) * 0.135 )
	ceaseWarButton:AlignTop( self:GetTall( ) * 0.35 )
	ceaseWarButton:SetButtonColor( Color( 108, 122, 137 ) )
	ceaseWarButton:SetTextColor( Color( 255, 255, 255 ) )
	ceaseWarButton.OnMousePressed = function( btn )
		LocalPlayer( ):ConCommand( "rp_endclanwar" )
		self:Remove( )
	end
	local closeButton = vgui.Create( "DN00B_ColoredButton", self )
	closeButton:SetText( "X" )
	closeButton:SetTextFont( "N00BRP_ClanMenu_TitleFont" )
	closeButton:SetSize( self:GetWide( ) * 0.035, self:GetTall( ) * 0.035 )
	closeButton:AlignRight( self:GetWide( ) * 0.025 )
	closeButton:AlignTop( self:GetTall( ) * 0.025 )
	closeButton:SetButtonColor( Color( 192, 57, 43 ) )
	closeButton:SetTextColor( Color( 255, 255, 255 ) )
	closeButton.OnMousePressed = function( btn )
		self:Remove( )
	end
end

function PANEL:CreateClanList( )
	self.clanScrollPanel = vgui.Create( "DScrollPanel", self )
	self.clanScrollPanel:SetSize( self:GetWide( ) * 0.55, self:GetTall( ) * 0.3 )
	self.clanScrollPanel:Center( )
	self.clanScrollPanel:AlignTop( self:GetTall( ) * 0.05 )
	self.clanScrollPanel:AlignLeft( self:GetWide( ) * 0.025 )
	local posX, posY = self.clanScrollPanel:GetPos( )
	posX = posX + self:GetWide( ) * 0.005
	posY = posY + self:GetTall( ) * 0.1
	self.clanScrollPanel:SetPos( posX, posY )
	self.clanList = vgui.Create( "DN00B_ScrollableList" )
	self.clanScrollPanel:AddItem( self.clanList )
	self.clanList:SetSize( self:GetWide( ) * 0.55, self:GetTall( ) * 0.3 )
	self.clanList:SetPos( 0, 0 )
	self.clanList:SetListWidthMultiplier( 1 )
	self.clanList:DrawListBackground( 2, Color( 25, 25, 25, 100 ) )
	self.clanList:SetSpaceX( 8 )
	self.clanList:SetSpaceY( 2 )
	local panelX, panelY = self.clanScrollPanel:GetPos( )
	local dNameLabel = vgui.Create( "DLabel", self )
	dNameLabel:SetText( "Clan Name" )
	dNameLabel:SetFont( "N00BRP_ClanMenu_TextFont" )
	dNameLabel:SizeToContents( )
	dNameLabel:SetPos( panelX + self:GetWide( ) * 0.02, panelY - self:GetTall( ) * 0.05 )
	dNameLabel:SetTextColor( Color( 255, 255, 255 ) )
	local dAmtLabel = vgui.Create( "DLabel", self )
	dAmtLabel:SetText( "Online Members" )
	dAmtLabel:SetFont( "N00BRP_ClanMenu_TextFont" )
	dAmtLabel:SizeToContents( )
	dAmtLabel:SetPos( panelX + self:GetWide( ) * 0.225, panelY - self:GetTall( ) * 0.05 )
	dAmtLabel:SetTextColor( Color( 255, 255, 255 ) )
end

function PANEL:CreateMemberList( )
	self.memberScrollPanel = vgui.Create( "DScrollPanel", self )
	self.memberScrollPanel:SetSize( self:GetWide( ) * 0.95, self:GetTall( ) * 0.3 )
	self.memberScrollPanel:Center( )
	self.memberScrollPanel:AlignTop( self:GetTall( ) * 0.5 )
	local posX, posY = self.memberScrollPanel:GetPos( )
	posX = posX + self:GetWide( ) * 0.005
	posY = posY + self:GetTall( ) * 0.1
	self.memberScrollPanel:SetPos( posX, posY )
	self.memberList = vgui.Create( "DN00B_ScrollableList" )
	self.memberScrollPanel:AddItem( self.memberList )
	self.memberList:SetSize( self:GetWide( ) * 0.95, self:GetTall( ) * 0.3 )
	self.memberList:SetPos( 0, 0 )
	self.memberList:SetListWidthMultiplier( 1 )
	self.memberList:DrawListBackground( 2, Color( 25, 25, 25, 100 ) )
	self.memberList:SetSpaceX( 8 )
	self.memberList:SetSpaceY( 2 )
	local panelX, panelY = self.memberScrollPanel:GetPos( )
	local dNameLabel = vgui.Create( "DLabel", self )
	dNameLabel:SetText( "Member Name" )
	dNameLabel:SetFont( "N00BRP_ClanMenu_TextFont" )
	dNameLabel:SizeToContents( )
	dNameLabel:SetPos( panelX + self:GetWide( ) * 0.01, panelY - self:GetTall( ) * 0.05 )
	dNameLabel:SetTextColor( Color( 255, 255, 255 ) )
	local dRankLabel = vgui.Create( "DLabel", self )
	dRankLabel:SetText( "Rank" )
	dRankLabel:SetFont( "N00BRP_ClanMenu_TextFont" )
	dRankLabel:SizeToContents( )
	dRankLabel:SetPos( panelX + self:GetWide( ) * 0.365, panelY - self:GetTall( ) * 0.05 )
	dRankLabel:SetTextColor( Color( 255, 255, 255 ) )
end

function PANEL:GenerateMemberList( )
	self.memberList:ClearItems( )
	for steamid, tbl in pairs ( myClanTable ) do
		if not ( IsValid( tbl.ply ) ) then
			myClanTable[steamid] = nil
			continue
		end
		local dMemberRow = self.memberList:AddElement( "DPanel" )
		dMemberRow:SetSize( self.memberList:GetWide( ), self.memberList:GetTall( ) * 0.135 )
		dMemberRow.Paint = function( pnl, w, h )
			--draw.RoundedBox( 0, 0, 0, w, h, team.GetColor( tbl.ply:Team( ) ) )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 108, 122, 137 ) )
		end
		local dNameLabel = vgui.Create( "DLabel", dMemberRow )
		dNameLabel:SetText( tbl.ply:Name( ) )
		dNameLabel:SetFont( "N00BRP_ClanMenu_TextFont" )
		dNameLabel:SizeToContents( )
		dNameLabel:CenterVertical( )
		dNameLabel:AlignLeft( dMemberRow:GetWide( ) * 0.0125 )
		dNameLabel:SetTextColor( Color( 255, 255, 255 ) )
		local dRankLabel = vgui.Create( "DLabel", dMemberRow )
		dRankLabel:SetText( clanRanks[ tbl.rank ] )
		dRankLabel:SetFont( "N00BRP_ClanMenu_TextFont" )
		dRankLabel:SizeToContents( )
		dRankLabel:CenterVertical( )
		dRankLabel:SetTextColor( Color( 255, 255, 255 ) )
		dRankLabel:AlignLeft( dMemberRow:GetWide( ) * 0.375 )
		local demoteButton = vgui.Create( "DN00B_ColoredButton", dMemberRow )
		demoteButton:SetText( "Demote" )
		demoteButton:SetTextFont( "N00BRP_ClanMenu_TextFont" )
		demoteButton:SetSize( dMemberRow:GetWide( ) * 0.15, dMemberRow:GetTall( ) )
		demoteButton:CenterVertical( )
		demoteButton:AlignRight( dMemberRow:GetWide( ) * 0.025 )
		demoteButton:SetButtonColor( Color( 34, 49, 63 ) )
		demoteButton:SetTextColor( Color( 255, 255, 255 ) )
		demoteButton.OnMousePressed = function( btn )
			LocalPlayer( ):ConCommand( "rp_demotetomember " .. tbl.ply:UserID( ) )
		end
		local promoteButton = vgui.Create( "DN00B_ColoredButton", dMemberRow )
		promoteButton:SetText( "Promote" )
		promoteButton:SetTextFont( "N00BRP_ClanMenu_TextFont" )
		promoteButton:SetSize( dMemberRow:GetWide( ) * 0.15, dMemberRow:GetTall( ) )
		promoteButton:CenterVertical( )
		promoteButton:AlignRight( dMemberRow:GetWide( ) * 0.185 )
		promoteButton:SetButtonColor( Color( 34, 49, 63 ) )
		promoteButton:SetTextColor( Color( 255, 255, 255 ) )
		promoteButton.OnMousePressed = function( btn )
			LocalPlayer( ):ConCommand( "rp_promotetoofficer " .. tbl.ply:UserID( ) )
		end
		local kickButton = vgui.Create( "DN00B_ColoredButton", dMemberRow )
		kickButton:SetText( "Kick" )
		kickButton:SetTextFont( "N00BRP_ClanMenu_TextFont" )
		kickButton:SetSize( dMemberRow:GetWide( ) * 0.075, dMemberRow:GetTall( ) )
		kickButton:CenterVertical( )
		kickButton:AlignRight( dMemberRow:GetWide( ) * 0.3475 )
		kickButton:SetButtonColor( Color( 34, 49, 63 ) )
		kickButton:SetTextColor( Color( 255, 255, 255 ) )
		kickButton.OnMousePressed = function( btn )
			LocalPlayer( ):ConCommand( "rp_kickfromclan " .. tbl.ply:UserID( ) )
		end
	end
end

function PANEL:GenerateClanList( )
	self.clanList:ClearItems( )
	local clanTable = { }
	for index, ply in ipairs ( player.GetAll( ) ) do
		local clan = ply:GetClan( )
		if not ( clan ) then continue end
		if not ( clanTable[ clan ] ) then
			clanTable[ clan ] = 1
		else
			clanTable[ clan ] = clanTable[ clan ] + 1
		end
	end
	for clan, plyAmt in pairs ( clanTable ) do
		local dClanRow = self.clanList:AddElement( "DPanel" )
		dClanRow:SetSize( self.clanList:GetWide( ), self.clanList:GetTall( ) * 0.2 )
		dClanRow.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 108, 122, 137 ) )
		end
		local dNameLabel = vgui.Create( "DLabel", dClanRow )
		dNameLabel:SetText( clan )
		dNameLabel:SetFont( "N00BRP_ClanMenu_TextFont" )
		dNameLabel:SetTextColor( Color( 255, 255, 255 ) )
		dNameLabel:SizeToContents( )
		dNameLabel:CenterVertical( )
		dNameLabel:AlignLeft( dClanRow:GetWide( ) * 0.02 )
		local dAmtLabel = vgui.Create( "DLabel", dClanRow )
		dAmtLabel:SetText( plyAmt )
		dAmtLabel:SetFont( "N00BRP_ClanMenu_TextFont" )
		dAmtLabel:SetTextColor( Color( 255, 255, 255 ) )
		dAmtLabel:SizeToContents( )
		dAmtLabel:CenterVertical( )
		dAmtLabel:SizeToContents( )
		dAmtLabel:AlignLeft( self.clanScrollPanel:GetWide( ) * 0.55 )
		local warButton = vgui.Create( "DN00B_ColoredButton", dClanRow )
		warButton:SetText( "Declare War" )
		warButton:SetTextFont( "N00BRP_ClanMenu_TextFont" )
		warButton:SetSize( dClanRow:GetWide( ) * 0.28, dClanRow:GetTall( ) )
		warButton:CenterVertical( )
		warButton:AlignRight( dClanRow:GetWide( ) * 0.045 )
		warButton:SetButtonColor( Color( 34, 49, 63 ) )
		warButton:SetTextColor( Color( 255, 255, 255 ) )
		warButton.OnMousePressed = function( btn )
			LocalPlayer( ):ConCommand( 'rp_startclanwar "' .. clan .. '"' )
		end
	end
end

vgui.Register( "DN00B_ClanMenu", PANEL, "Panel" )

local function ReceiveClanMenuNET( len )
	local mesType = net.ReadUInt( 8 )
	if ( mesType == ENUM_CLANMENU_BEGINSENDING and !currentlyRetrieving ) then
		myClanTable = { }
		currentlyRetrieving = true
	elseif ( mesType == ENUM_CLANMENU_ADDMEMBER and currentlyRetrieving ) then
		local plyTable = net.ReadTable( )
		if not ( IsValid( plyTable.ply ) ) then return end
		myClanTable[plyTable.ply:SteamID( )] = { ply = plyTable.ply, rank = plyTable.rank }
	elseif ( mesType == ENUM_CLANMENU_ENDSENDING and currentlyRetrieving ) then
		if ( ValidPanel( LocalPlayer( ).noob_ClanMenu ) ) then LocalPlayer( ).noob_ClanMenu:Remove( ) end
		LocalPlayer( ).noob_ClanMenu = vgui.Create( "DN00B_ClanMenu" )
		LocalPlayer( ).noob_ClanMenu:CreateMemberList( )
		LocalPlayer( ).noob_ClanMenu:CreateClanList( )
		LocalPlayer( ).noob_ClanMenu:GenerateMemberList( )
		LocalPlayer( ).noob_ClanMenu:GenerateClanList( )
		currentlyRetrieving = false
	end
end
net.Receive( "N00BRP_ClansMenu_NET", ReceiveClanMenuNET )
local PANEL = {}

/*---------------------------------------------------------
Name:
---------------------------------------------------------*/
function PANEL:DoClick()
	if not self:GetParent().Player or LocalPlayer() == self:GetParent().Player then return end

	self:DoCommand(self:GetParent().Player)
	timer.Simple(0.1, SCOREBOARD.UpdateScoreboard, SCOREBOARD)
end

/*---------------------------------------------------------
Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()
	local bgColor = Color(0,0,0,0)

	if self.Selected then
		bgColor = Color(0, 200, 255, 255)
	elseif self.Armed then
		bgColor = Color(255, 255, 0, 255)
	end

	draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), bgColor)
	draw.SimpleText(self.Text, "DefaultSmall", self:GetWide() / 2, self:GetTall() / 2, Color(0,0,0,150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	return true
end

vgui.Register("SpawnMenuAdminButton", PANEL, "Button")

/*   PlayerKickButton */

PANEL = {}
PANEL.Text = "Kick"

/*---------------------------------------------------------
Name: DoCommand
---------------------------------------------------------*/
function PANEL:DoCommand(ply)
	--LocalPlayer():ConCommand("kickid ".. ply:UserID().. " Kicked By "..LocalPlayer():Nick().."\n")
end

vgui.Register("PlayerKickButton", PANEL, "SpawnMenuAdminButton")

/*   PlayerPermBanButton */

PANEL = {}
PANEL.Text = "PermBan"

/*---------------------------------------------------------
Name: DoCommand
---------------------------------------------------------*/
function PANEL:DoCommand(ply)
	--LocalPlayer():ConCommand("banid 0 ".. self:GetParent().Player:UserID().. "\n")
	--LocalPlayer():ConCommand("kickid ".. ply:UserID().. " Permabanned By "..LocalPlayer():Nick().."\n")
end

vgui.Register("PlayerPermBanButton", PANEL, "SpawnMenuAdminButton")

/*   PlayerPermBanButton */

PANEL = {}
PANEL.Text = "1HRBan"

/*---------------------------------------------------------
Name: DoCommand
---------------------------------------------------------*/
function PANEL:DoCommand(ply)
	--LocalPlayer():ConCommand("banid 60 ".. self:GetParent().Player:UserID().. "\n")
	--LocalPlayer():ConCommand("kickid ".. ply:UserID().. " Banned for 1 hour By "..LocalPlayer():Nick().."\n")
end

vgui.Register("PlayerBanButton", PANEL, "SpawnMenuAdminButton")

PANEL = {}
PANEL.Text = "(un)Wanted"

/*---------------------------------------------------------
Name: DoCommand
---------------------------------------------------------*/
function PANEL:DoCommand(ply)
	if ply:getDarkRPVar( "wanted" ) then
		LocalPlayer():ConCommand("say /unwanted " .. tostring( ply:UserID()))
	else
		LocalPlayer():ConCommand("say /wanted " .. tostring( ply:UserID()))
	end
end

vgui.Register("PlayerWarrantButton", PANEL, "SpawnMenuAdminButton")

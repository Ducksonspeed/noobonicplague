local PANEL = {}

PANEL.VoteName = "none"
PANEL.MaterialName = "friendly"

/*---------------------------------------------------------
Name:
---------------------------------------------------------*/
function PANEL:Init()
	self.Label = vgui.Create("DLabel", self)
	self:ApplySchemeSettings()
end

/*---------------------------------------------------------
Name:
---------------------------------------------------------*/
function PANEL:DoClick()
	local ply = self:GetParent().Player
	if not IsValid(ply) or ply == LocalPlayer() then return end

	LocalPlayer():ConCommand("rp_userrate ".. ply:EntIndex().. " "..self.VoteName.."\n")
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()
	self.Label:SetFont( "Tahoma" );
	self.Label:SetTextColor( Color( 51, 51, 51, 151 ) );
	self.Label:SetMouseInputEnabled(false)
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()
	if self:GetParent().Player and IsValid(self:GetParent().Player) then
		self.Label:SetText(self:GetParent().Player:GetNWInt("Rating."..self.VoteName, 0))
	end

	self.Label:SizeToContents()
	self.Label:SetPos((self:GetWide() - self.Label:GetWide()) / 2, self:GetTall() - self.Label:GetTall())
end

/*---------------------------------------------------------
Name:
---------------------------------------------------------*/
function PANEL:SetUp(mat, votename, nicename)
	self.MaterialName = mat
	self.VoteName = votename
	self.NiceName = nicename

	self:SetToolTip( self.NiceName );
end

/*---------------------------------------------------------
Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()
	if not self.Material then
		// self.Material = surface.GetTextureID("gui/silkicons/" .. self.MaterialName .. ".vtf")
		self.Material = Material( "icon16/"..self.MaterialName..".png" );
	end

	local bgColor = Color(0,0,0,0)

	if self.Selected then
		bgColor = Color(0, 200, 255, 255)
	elseif self.Armed then
		bgColor = Color(255, 255, 0, 255)
	end

	draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), bgColor)

	local alpha = 200

	if self.Armed then alpha = 255 end

	surface.SetMaterial( self.Material );
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(self:GetWide()/2 - 8, self:GetWide()/2 - 8, 16, 16)
	return true
end

local TooltipText = nil

/*---------------------------------------------------------
Name: OnCursorEntered
---------------------------------------------------------*/
function PANEL:OnCursorEntered()
	TooltipText = self.NiceName
end

/*---------------------------------------------------------
Name: OnCursorEntered
---------------------------------------------------------*/
function PANEL:OnCursorExited()
	TooltipText = nil
end

vgui.Register("SpawnMenuVoteButton", PANEL, "Button")

local _GetTooltipText = GetTooltipText
function GetTooltipText()
	if TooltipText then return TooltipText end

	return _GetTooltipText()
end

surface.CreateFont( "N00BRP_AdminMenu_LabelFont", {
	font = "Segio Bold",
	size = ScreenScale( 6 ),
	weight = 600,
	blursize = 0,
} )

surface.CreateFont( "N00BRP_AdminMenu_SmallFont", {
	font = "Segio Light",
	size = ScreenScale( 6 ),
	weight = 600,
	blursize = 0,
} )

surface.CreateFont( "N00BRP_AdminMenu_LargeFont", {
	font = "Arial",
	size = ScreenScale( 14 ),
	weight = 600,
	blursize = 0,
} )

PANEL = { }

function PANEL:Init()
	if ( IsValid( LocalPlayer( ).noobAdminCommandMenu ) ) then
		LocalPlayer( ).noobAdminCommandMenu:Remove( )
	end
	LocalPlayer( ).noobAdminCommandMenu = self
    self:SetSize( ScrW( ) * 0.4, ScrH( ) * 0.55 )
    self:Center( )
    self:ShowCloseButton( false )
    self:SetTitle( "" )
    self:CreateCommandList( )
    self:CreateContentPanel( )
    self:RequestCommands( )
    self:MakePopup( )
    self.hidingUnusableCommands = false
    gui.EnableScreenClicker( true )
    local dShowUsableButton = vgui.Create( "DN00B_ColoredButton", self )
    dShowUsableButton:SetSize( self:GetWide( ) * 0.165, self:GetTall( ) * 0.03 )
    dShowUsableButton:OffsetFromCenter( self:GetWide( ) * 0.285, self:GetTall( ) * -0.46 )
    dShowUsableButton:SetText( "Hide No-Access" )
    dShowUsableButton:SetTextFont( "N00BRP_AdminMenu_LabelFont" )
    dShowUsableButton:SetButtonColor( Color( 210, 77, 87 ) )
    dShowUsableButton:SetTextColor( Color( 255, 255, 255, 255 ) )
    dShowUsableButton.OnMousePressed = function( btn )
    	if ( self.hidingUnusableCommands ) then
   			self:GenerateCommandList( false )
   			self.hidingUnusableCommands = false
   			dShowUsableButton:SetText( "Hide No-Access" )
   			dShowUsableButton:SetButtonColor( Color( 210, 77, 87 ) )
   		else
   			self:GenerateCommandList( true )
   			self.hidingUnusableCommands = true
   			dShowUsableButton:SetText( "Show No-Access" )
   			dShowUsableButton:SetButtonColor( Color( 77, 210, 87 ) )
   		end
   	end
    local dCloseButton = vgui.Create( "DN00B_ColoredButton", self )
    dCloseButton:SetSize( self:GetWide( ) * 0.075, self:GetTall( ) * 0.03 )
    dCloseButton:OffsetFromCenter( self:GetWide( ) * 0.435, self:GetTall( ) * -0.46 )
    dCloseButton:SetText( "X" )
    dCloseButton:SetTextFont( "N00BRP_AdminMenu_LabelFont" )
    dCloseButton:SetButtonColor( Color( 210, 77, 87 ) )
    dCloseButton:SetTextColor( Color( 255, 255, 255, 255 ) )
    dCloseButton.OnMousePressed = function( btn )
   		gui.EnableScreenClicker( false )
    	self:Remove( )
   	end
end

function PANEL:CreateCommandList( )
	self.commandList = vgui.Create( "DN00B_ScrollableList", self )
	local cmdList = self.commandList
	cmdList:SetSize( self:GetWide( ) * 0.4, self:GetTall( ) * 0.8 )
	cmdList:OffsetFromCenter( self:GetWide( ) * -0.27, 0 )
	cmdList:SetListWidthMultiplier( 0.9 )
	cmdList:ColorizeScrollbar( Color( 52, 73, 94 ), Color( 52, 73, 94 ), Color( 51, 110, 123 ), Color( 44, 62, 80 ) )
end

function PANEL:GenerateContent( name, tbl )
	self.contentPanel:Clear( )
	self.contentPanel.cmdData = tbl
	self.contentPanel.textEntries = nil
	local startHeight = self:GetTall( ) * 0.35
	if ( tbl.args > 0 ) then
		self.contentPanel.textEntries = { }
		for i = 1, tbl.args do
			local argumentTextBox = vgui.Create( "DTextEntry", self.contentPanel )
			argumentTextBox:SetSize( self:GetWide( ) * 0.3, self:GetTall( ) * 0.05 )
			argumentTextBox:OffsetFromCenter( 0, self:GetTall( ) * -0.1 + ( i * self:GetTall( ) * 0.12 ) )
			table.insert( self.contentPanel.textEntries, argumentTextBox )
		end
		startHeight = startHeight + ( tbl.args * self:GetTall( ) * 0.12 )
	end
	local executeButton = vgui.Create( "DN00B_ColoredButton", self.contentPanel )
	executeButton.notArgumentEntry = true
	executeButton:SetSize( self.contentPanel:GetWide( ) * 0.4, self.contentPanel:GetTall( ) * 0.075 )
	executeButton:SetPos( 0, startHeight )
	executeButton:CenterHorizontal( )
	executeButton:SetText( "EXECUTE" )
	executeButton:SetTextFont( "N00BRP_AdminMenu_LabelFont" )
	executeButton:SetButtonColor( Color( 27, 188, 155) )
	executeButton:SetTextColor( Color( 255, 255, 255, 255 ) )
	executeButton.OnMousePressed = function( btn )
		if ( self.contentPanel.textEntries ) then
			local builtCommand = ""
			for index, child in ipairs ( self.contentPanel:GetChildren( ) ) do
				if ( child.notArgumentEntry ) then continue end
				builtCommand = builtCommand .. '"' .. child:GetText( ) .. '" '
			end
			local finishedCommand = name .. ' ' .. builtCommand
			LocalPlayer( ):ConCommand( finishedCommand )
		else
			LocalPlayer( ):ConCommand( name )
		end
	end
end

function PANEL:CreateContentPanel( )
	self.contentScrollPanel = vgui.Create( "DScrollPanel", self )
	local contentScrollPanel = self.contentScrollPanel
	contentScrollPanel:SetSize( self:GetWide( ) * 0.5, self:GetTall( ) * 0.8 )
	contentScrollPanel:OffsetFromCenter( self:GetWide( ) * 0.22, 0 )
	self.contentPanel = vgui.Create( "DPanel" )
	local contentPanel = self.contentPanel
	contentPanel.cmdData = nil
	contentPanel:SetSize( contentScrollPanel:GetWide( ), contentScrollPanel:GetTall( ) )
	contentScrollPanel:AddItem( contentPanel )
	contentPanel.Paint = function( pnl, w, h )
		draw.RoundedBox( 4, 0, 0, w, h, Color( 34, 49, 63 ) )
		if ( contentPanel.cmdData ) then
			local datTab = contentPanel.cmdData
			local descTbl = string.Explode( "^", datTab.desc )
			for index, line in ipairs ( descTbl ) do
				draw.SimpleText( line, "N00BRP_AdminMenu_LabelFont", w * 0.5, h * 0.05 + ( 20 * index ), Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
			end
			draw.SimpleText( "Syntax:", "N00BRP_AdminMenu_LabelFont", w * 0.5, h * 0.275, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
			draw.SimpleText( datTab.syntax, "N00BRP_AdminMenu_SmallFont", w * 0.5, h * 0.325, Color( 129, 207, 224, 255 ), TEXT_ALIGN_CENTER )
		else
			draw.SimpleText( "Select a Command", "N00BRP_AdminMenu_LargeFont", w * 0.5, h * 0.15, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
			draw.SimpleText( "If the button is red,", "N00BRP_AdminMenu_LabelFont", w * 0.5, h * 0.3, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
			draw.SimpleText( "you lack access to that command.", "N00BRP_AdminMenu_LabelFont", w * 0.5, h * 0.35, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		end
		if not ( self.contentPanel.textEntries ) then return end
		local argCount = 0
		for index, child in ipairs ( self.contentPanel.textEntries ) do
			if ( child.notArgumentEntry ) then continue end
			argCount = argCount + 1
			local posX, posY = child:GetPos( )
			draw.SimpleText( "Argument #" .. argCount, "N00BRP_AdminMenu_LabelFont", w * 0.5, posY - 28, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		end
	end
end

function PANEL:GenerateCommandList( hideNoAccess )
	local cmdList = self.commandList
	cmdList:GetIconLayout( ):Clear( )
	if ( !self.storedCommands or table.Count( self.storedCommands ) == 0 ) then return end
	for index, cmd in SortedPairsByMemberValue( self.storedCommands, "syntax", false ) do
		if ( hideNoAccess and !LocalPlayer( ):CanAccess( cmd.access ) ) then continue end
		local cmdBtn = cmdList:GetIconLayout( ):Add( "DN00B_ColoredButton" )
		cmdBtn:SetSize( cmdList:GetWide( ) * 0.9, cmdList:GetTall( ) * 0.1 )
		cmdBtn:SetText( index )
		cmdBtn:SetTextColor( Color( 255, 255, 255 ) ) 
		cmdBtn:SetTextFont( "N00BRP_AdminMenu_LabelFont" )
		cmdBtn:SetRoundness( 6 )
		if ( LocalPlayer( ):CanAccess( cmd.access ) ) then
			cmdBtn:SetButtonColor( Color( 63, 195, 128 ) )
		else
			cmdBtn:SetButtonColor( Color( 214, 69, 65 ) )
		end
		cmdBtn.OnMousePressed = function( btn )
			self:GenerateContent( index, cmd )
		end
	end
end

function PANEL:AddCommand( tbl )
	self.storedCommands = self.storedCommands or { }
	if ( self.storedCommands[tbl.name] == nil ) then
		self.storedCommands[tbl.name] = {
			access = tbl.rank,
			desc = tbl.desc,
			syntax = tbl.syntax,
			args = tbl.args
		}
		self:GenerateCommandList( )
	end
end

function PANEL:RequestCommands( )
	net.Start( "noobadmin_networkcommands" )
	net.SendToServer( )
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 255 ) )
end

vgui.Register( "N00BAdmin_CommandMenu", PANEL, "DFrame" )

local function NOOB_ADMIN_ReceiveCommand( len )
	local cmdTable = net.ReadTable( )
	if ( ValidPanel( LocalPlayer( ).noobAdminCommandMenu ) ) then
		LocalPlayer( ).noobAdminCommandMenu:AddCommand( cmdTable )
	end
end
net.Receive( "noobadmin_networkcommands", NOOB_ADMIN_ReceiveCommand )

local function NOOB_ADMIN_OpenMenu( ply, cmd, args, fstring )
	if ( ValidPanel( ply.noobAdminCommandMenu ) ) then
		gui.EnableScreenClicker( false )
		ply.noobAdminCommandMenu:Remove( )
	else
		vgui.Create( "N00BAdmin_CommandMenu" )
	end
end
concommand.Add( "np_openmenu", NOOB_ADMIN_OpenMenu )
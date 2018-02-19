surface.CreateFont( "N00BRP_NotesMenu_ButtonFont", {
	font = "Segoe UI Bold",
	size = ScreenScale( 12 ),
	weight = 600,
	blursize = 0,
} )

surface.CreateFont( "N00BRP_NotesMenu_TextFont", {
	font = "Segoe UI Light",
	size = ScreenScale( 10 ),
	weight = 600,
	blursize = 0,
} )

surface.CreateFont( "N00BRP_NotesMenu_BoldTextFont", {
	font = "Segoe UI Bold",
	size = ScreenScale( 9 ),
	weight = 600,
	blursize = 0,
} )

PANEL = { }

function PANEL:Init()
    self:SetSize( ScrW( ) * 0.3, ScrH( ) * 0.2 )
    self:Center( )
    self:SetupInterface( )
    self.notesTable = { }
   	gui.EnableScreenClicker( true )
   	self:MakePopup( )
   	self.currentNoteIndex = 0
   	self:SetTitle( "" )
   	self:ShowCloseButton( false )
end

function PANEL:SetupInterface( )
	self.titleEntry = vgui.Create( "DTextEntry", self )
	self.titleEntry:SetSize( self:GetWide( ) * 0.6, self:GetTall( ) * 0.125 )
	self.titleEntry:Center( )
	self.titleEntry:AlignTop( self:GetTall( ) * 0.2 )
	self.titleEntry.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 255 ) )
		draw.SimpleText( self.titleEntry:GetText( ), "N00BRP_NotesMenu_BoldTextFont", w / 2, 0, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER )
	end
	self.titleEntry.OnChange = function( pnl )
		local caretPos = self.titleEntry:GetCaretPos( )
		self.titleEntry:SetText( self.titleEntry.defaultText )
		self.titleEntry:SetCaretPos( caretPos )
	end
	self.noteTextEntry = vgui.Create( "DTextEntry", self )
	local noteEntry = self.noteTextEntry
	noteEntry:SetSize( self:GetWide( ) * 0.6, self:GetTall( ) * 0.5 )
	noteEntry:Center( )
	noteEntry:AlignBottom( self:GetTall( ) * 0.1 )
	noteEntry:SetMultiline( true )
	noteEntry:SetFont( "N00BRP_NotesMenu_TextFont" )
	noteEntry:SetVerticalScrollbarEnabled( true )
	noteEntry.OnChange = function( pnl )
		local caretPos = noteEntry:GetCaretPos( )
		noteEntry:SetText( noteEntry.defaultText )
		noteEntry:SetCaretPos( caretPos )
	end
	local nextButton = vgui.Create( "DN00B_ColoredButton", self )
	nextButton:SetSize( self:GetWide( ) * 0.125, self:GetTall( ) * 0.135 )
	nextButton:AlignTop( ScrH( ) * 0.04 )
	nextButton:AlignRight( ScrW( ) * 0.01 )
	nextButton:SetText( "->" )
	nextButton:SetButtonColor( Color( 255, 255, 255, 255 ) )
	nextButton:SetTextFont( "N00BRP_NotesMenu_ButtonFont" )
	nextButton:SetTextColor( Color( 0, 0, 0, 255 ) )
	nextButton:SetRoundness( 2 )
	nextButton.OnMousePressed = function( btn )
		if ( self.notesTable[self.currentNoteIndex + 1] ) then
			self.currentNoteIndex = self.currentNoteIndex + 1
			self.titleEntry:SetText( self.notesTable[self.currentNoteIndex].date .. " :: " .. self.notesTable[self.currentNoteIndex].admin )
			self.titleEntry.defaultText = self.titleEntry:GetText( )
			self.noteTextEntry:SetText( self.notesTable[self.currentNoteIndex].note )
			self.noteTextEntry.defaultText = self.noteTextEntry:GetText( )
		end
	end
	local prevButton = vgui.Create( "DN00B_ColoredButton", self )
	prevButton:SetSize( self:GetWide( ) * 0.125, self:GetTall( ) * 0.135 )
	prevButton:AlignTop( ScrH( ) * 0.04 )
	prevButton:AlignLeft( ScrW( ) * 0.01 )
	prevButton:SetText( "<-" )
	prevButton:SetButtonColor( Color( 255, 255, 255, 255 ) )
	prevButton:SetTextFont( "N00BRP_NotesMenu_ButtonFont" )
	prevButton:SetTextColor( Color( 0, 0, 0, 255 ) )
	prevButton:SetRoundness( 2 )
	prevButton.OnMousePressed = function( btn )
		if ( self.notesTable[self.currentNoteIndex - 1] ) then
			self.currentNoteIndex = self.currentNoteIndex - 1
			self.titleEntry:SetText( self.notesTable[self.currentNoteIndex].date .. " :: " .. self.notesTable[self.currentNoteIndex].admin )
			self.titleEntry.defaultText = self.titleEntry:GetText( )
			self.noteTextEntry:SetText( self.notesTable[self.currentNoteIndex].note )
			self.noteTextEntry.defaultText = self.noteTextEntry:GetText( )
		end
	end
	local closeButton = vgui.Create( "DN00B_ColoredButton", self )
	closeButton:SetSize( self:GetWide( ) * 0.075, self:GetTall( ) * 0.11 )
	closeButton:AlignTop( ScrH( ) * 0.005 )
	closeButton:AlignRight( ScrW( ) * 0.01 )
	closeButton:SetText( "" )
	closeButton:SetButtonColor( Color( 125, 25, 25, 255 ) )
	closeButton:SetTextFont( "N00BRP_NotesMenu_ButtonFont" )
	closeButton:SetTextColor( Color( 255, 255, 255, 255 ) )
	closeButton:SetRoundness( 2 )
	closeButton.OnMousePressed = function( btn )
		gui.EnableScreenClicker( false )
		self:Remove( )
	end
end

function PANEL:AddEntry( noteTable )
	table.insert( self.notesTable, noteTable )
	if ( self.noteTextEntry:GetValue( ) == "" ) then
		self.titleEntry:SetText( noteTable.date .. " :: " .. noteTable.admin )
		self.titleEntry.defaultText = self.titleEntry:GetText( )
		self.noteTextEntry:SetText( noteTable.note )
		self.noteTextEntry.defaultText = self.noteTextEntry:GetText( )
		self.currentNoteIndex = #self.notesTable
	end
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, Color( 24, 24, 24, 255 ) )
end

vgui.Register( "N00BRP_NotesMenu", PANEL, "DFrame" )

local function ReceiveNotesMenu( len )
	local noteTable = net.ReadTable( )
	if not ( ValidPanel( LocalPlayer( ).adminNotesMenu ) ) then
		LocalPlayer( ).adminNotesMenu = vgui.Create( "N00BRP_NotesMenu" )
		LocalPlayer( ).adminNotesMenu:AddEntry( noteTable )
	else
		LocalPlayer( ).adminNotesMenu:AddEntry( noteTable )
	end
end
net.Receive( "N00BRP_NotesMenu", ReceiveNotesMenu )
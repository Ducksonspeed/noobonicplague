surface.CreateFont( "N00BRP_ChatBox_TextFont", {
	font = "Segoe UI Bold",
	size = 18,
	weight = 600,
	blursize = 0,
} )

PANEL = { }

function PANEL:Init()
    --self:SetSize( ScrW( ) * 0.3, ScrH( ) * 0.25 )
    self:SetSize( 512, 225 )
    self:SetPos( 0, ScrH( ) - 380 )
    self:MakePopup( )
    self.isActivated = true
    self:SetDraggable( false )
    self:SetupInterface( )
    self:SetTitle( "" )
    self:ShowCloseButton( false )
    LocalPlayer( ).noob_ChatBox = self
   	gui.EnableScreenClicker( true )
   	timer.Simple( 0, function( )
   		if not ( ValidPanel( self ) ) then return end
   		self.chatRichText:GotoTextEnd( ) 
   	end )
end

function PANEL:SetupInterface( )
	self.chatEntry = vgui.Create( "DTextEntry", self )
	self.chatEntry:SetSize( self:GetWide( ) * 0.9, self:GetTall( ) * 0.075 )
	self.chatEntry:CenterHorizontal( )
	self.chatEntry:AlignBottom( self:GetTall( ) * 0.025 )
	self.chatEntry:RequestFocus( )
	self.chatEntry:SetFont( "N00BRP_ChatBox_TextFont" )
	self.chatEntry.OnKeyCodeTyped = function( pnl, keyCode )
		if ( keyCode == KEY_ENTER ) then
			LocalPlayer( ):ConCommand( 'say "' .. self.chatEntry:GetValue( ) .. '"' )
			self.chatEntry:SetText( "" )
			self:DeactivateChatBox( )
		elseif ( keyCode == KEY_ESCAPE ) then
			self.chatEntry:SetText( "" )
			self:DeactivateChatBox( )
		end
	end
	self.chatRichText = vgui.Create( "RichText", self )
	self.chatRichText:SetSize( self:GetWide( ) * 0.9, self:GetTall( ) * 0.75 )
	self.chatRichText:Center( )
	self.chatRichText.Paint = function( pnl, w, h )
		pnl:SetFontInternal( "N00BRP_ChatBox_TextFont" );
		pnl:SetFGColor( Color( 255, 255, 255, 0 ) )
		local drawAlpha = 100
		if ( !self.isActivated and self:GetAlpha( ) == 255 ) then drawAlpha = 0 end
		draw.RoundedBox( 0, 0, 0, w, h, Color( 45, 45, 45, drawAlpha ) )
	end
	self:LoadChatBoxText( )
	self.chatRichText:GotoTextEnd( )
	self.dragChatButton = vgui.Create( "DN00B_ColoredButton", self )
	self.dragChatButton:SetSize( 16, 16 )
	self.dragChatButton:SetPos( self:GetWide( ) * 0.96, self:GetTall( ) * 0.91 )
	self.dragChatButton:SetText( "" )
	self.dragChatButton:SetButtonImage( "icon16/cursor.png", Color( 45, 45, 45), false )
	self.dragChatButton.OnMousePressed = function( )
		timer.Create( "DragChatBoxTimer", 0.05, 0, function( )
			if not ( ValidPanel( self ) ) then timer.Destroy( "DragChatBoxTimer" ) return end
			self:SetPos( ( gui.MouseX( ) - self:GetWide( ) ) + 16, ( gui.MouseY( ) - self:GetTall( ) ) + 16 )
		end )
	end
	self.dragChatButton.OnMouseReleased = function( )
		timer.Destroy( "DragChatBoxTimer" )
	end
end

function PANEL:OnMouseReleased( )
	timer.Destroy( "DragChatBoxTimer" )
end

function PANEL:DeactivateChatBox( )
	--self.chatEntry:SetVisible( false )
	self:SetMouseInputEnabled( false )
	self:SetKeyboardInputEnabled( false )
	self.chatRichText:SetVerticalScrollbarEnabled( false )
	self.isActivated = false
	self.chatRichText:Stop( )
	self.chatRichText:AlphaTo( 0, 6, 0, function( ) end )
	self:Stop( )
	self:AlphaTo( 0, 6, 0, function( ) end )
	self.chatEntry:Stop( )
	self.chatEntry:AlphaTo( 0, 6, 0, function( ) end )
	self.dragChatButton:Stop( )
	self.dragChatButton:AlphaTo( 0, 6, 0, function( ) end )
	gui.EnableScreenClicker( false )
	chat.Close( )
end

function PANEL:ActivateChatBox( )
	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( true )
	--self.chatEntry:SetVisible( true )
	self.chatEntry:Stop( )
	self.chatEntry:SetAlpha( 255 )
	self.chatEntry:RequestFocus( )
	self.isActivated = true
	self:Stop( )
	self:SetAlpha( 255 )
	self.chatRichText:Stop( )
	self.chatRichText:SetVerticalScrollbarEnabled( true )
	self.chatRichText:GotoTextEnd( )
	self.chatRichText:SetAlpha( 255 )
	self.dragChatButton:Stop( )
	self.dragChatButton:SetAlpha( 255 )
	/*self.chatRichText:AlphaTo( 255, 2, 0, function( animData, pnl ) 
		self.chatRichText:SetAlpha( 255 )
	end )*/
end

function PANEL:LoadChatBoxText( )
	LocalPlayer( ).chatBoxHistory = LocalPlayer( ).chatBoxHistory or { }
	chatHistory = LocalPlayer( ).chatBoxHistory
	for index, line in ipairs ( chatHistory ) do
		for _, val in pairs( line ) do
			if ( istable( val ) ) then
				self:ChangeTextColor( val )
			else
				self:InsertText( val )
			end
		end
		self:InsertNewLine( )
	end
	self.chatRichText:GotoTextEnd( )
end

function PANEL:ChangeTextColor( col )
	self.chatRichText:InsertColorChange( col.r, col.g, col.b, 255 )
end

function PANEL:InsertText( txt )
	if not ( self.isActivated ) then
		self:SetAlpha( 255 )
		self.chatRichText:SetAlpha( 255 )
		self.chatRichText:Stop( )
		self.chatRichText:AlphaTo( 0, 6, 0, function( ) end )
	end
	self.chatRichText:AppendText( txt )
	self.chatRichText:GotoTextEnd( )
end

function PANEL:InsertNewLine( )
	self.chatRichText:AppendText( "\n" )
	self.chatRichText:GotoTextEnd( )
end

function PANEL:OnMousePressed( btn )
end

function PANEL:Paint( w, h )
	local drawAlpha = 150
	if ( !self.isActivated and self:GetAlpha( ) == 255 ) then drawAlpha = 0 end
    draw.RoundedBox( 0, 0, 0, w, h, Color( 24, 24, 24, drawAlpha ) )
end

vgui.Register( "DN00B_ChatBox", PANEL, "DFrame" )
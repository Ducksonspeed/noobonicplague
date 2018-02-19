surface.CreateFont( "N00BRP_MOTDPanel_Text", {
	font = "Segoe UI Bold",
	size = ScreenScale( 9 ),
	weight = 500,
	blursize = 0,
} )

PANEL = { }

function PANEL:Init()
    self:SetSize( ScrW( ) * 0.66, ScrH( ) * 0.88 )
    self:Center( )
    self:MakePopup( )
   	gui.EnableScreenClicker( true )
   	self:OpenDHTML( )
   	local closeButton = vgui.Create( "DN00B_ColoredButton", self )
   	closeButton:SetSize( 128, 40 )
   	closeButton:Center( )
   	closeButton:AlignBottom( 8 )
   	closeButton:SetText( "CLOSE" )
   	closeButton:SetButtonColor( Color( 244, 77, 73 ) )
   	closeButton:SetTextFont( "N00BRP_MOTDPanel_Text" )
   	closeButton:SetTextColor( Color( 255, 255, 255 ) )
   	closeButton:SetRoundness( 2 )
   	closeButton.OnMousePressed = function( pnl, btn )
      gui.EnableScreenClicker( false )
      self:Remove( )
    end
end

function PANEL:OnMousePressed( btn )
  gui.EnableScreenClicker( false )
  self:Remove( )
end

function PANEL:OpenDHTML( )
	local dHTML = vgui.Create( "HTML", self )
	dHTML:OpenURL( "http://noobonicplague.com/motd/" )
  dHTML:SetSize( self:GetWide( ) - 16, self:GetTall( ) - 64 )
  dHTML:Center( )
  dHTML:AlignTop( 8 )
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 2, 0, 0, w, h, Color( 32, 32, 32 ) )
end

vgui.Register( "N00BRP_MOTD", PANEL, "Panel" )

local function OpenMOTD( )
	if ( ValidPanel( LocalPlayer( ).noobMOTD ) ) then
		LocalPlayer( ).noobMOTD:Remove() 
		
	else
		LocalPlayer( ).noobMOTD = vgui.Create( "N00BRP_MOTD" )
	end
end
concommand.Add( "motd", OpenMOTD )
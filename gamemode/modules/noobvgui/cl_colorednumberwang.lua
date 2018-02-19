surface.CreateFont( "N00BRP_DN00BColoredNumberWang_FallbackFont", {
  font = "Lobster",
  size = ScreenScale( 11 ),
  weight = 600,
  blursize = 0,
} )

PANEL = {}

function PANEL:Init( )
    self:SetSize( ScrW( ) * 0.075, ScrH( ) * 0.025 )
    self:SetPos( 0, 0 )
    self:SetMinMax( 1, 50000 )
    self.backgroundColor = Color( 22, 160, 133, 255 )
    self.textColor = Color( 255, 255, 255, 255 )
    self.textFont = "N00BRP_DN00BColoredNumberWang_FallbackFont"
    self.buttonBackgroundColor = Color( 255, 255, 255, 255 )
    self.textAlignment = TEXT_ALIGN_LEFT
    self.wangUpOldPaint = self.Up.Paint
    self.wangDownOldPaint = self.Down.Paint
    self.Up.Paint = function( pnl, w, h )
        draw.RoundedBox( 4, 0, 0, w, h, self.buttonBackgroundColor )
        self.wangUpOldPaint( self.Up, w, h )
    end
    self.Down.Paint = function( pnl, w, h )
        draw.RoundedBox( 4, 0, 0, w, h, self.buttonBackgroundColor )
        self.wangDownOldPaint( self.Down, w, h )
    end
end

function PANEL:Paint( w, h )
    local wangVal = self:GetValue( )
    if ( string.len( wangVal ) > 6 ) then
        wangVal = string.sub( wangVal, 1, 6 )
    end
    draw.RoundedBox( 6, 0, 0, w, h * 0.9, self.backgroundColor )
    draw.SimpleText( wangVal, self.textFont, w * 0.05, h * 0.05, self.textColor, self.textAlignment )
end

function PANEL:SetBackColor( color )
    self.backgroundColor = color
end

function PANEL:SetValueColor( color )
    self.textColor = color
end

function PANEL:SetValueFont( font )
    self.textFont = font
end

function PANEL:SetButtonBGColor( color )
    self.buttonBackgroundColor = color
end

function PANEL:SetTextAlignment( align )
    self.textAlignment = align
end

vgui.Register( "DN00B_ColoredNumberWang", PANEL, "DNumberWang" )
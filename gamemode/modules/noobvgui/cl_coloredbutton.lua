surface.CreateFont( "N00BRP_DN00BColoredButton_FallbackFont", {
	font = "Arial",
	size = ScreenScale( 6 ),
	weight = 500,
	blursize = 0,
} )

PANEL = {}

function PANEL:Init( )
	-- Setup all of the fallback values.
    self:SetSize( ScrW( ) * 0.1, ScrH( ) * 0.05 )
    self:SetPos( 0, 0 )
    self.buttonColor = Color( 255, 255, 255, 255 )
    self.hoverColor = Color( 200, 200, 200, 255 )
    self.textColor = Color( 25, 25, 25, 255 )
    self.textFont = "N00BRP_DN00BColoredButton_FallbackFont"
    self.text = "Text"
    self.cornerRndness = 0
    self.textXPosMulti = 0.5
    self.buttonMaterial = nil
    self.buttonMaterialColor = nil
    self.textAlign = TEXT_ALIGN_CENTER
    self.leftPadding = false
end

function PANEL:Paint( w, h )
	if ( self:IsHovered( ) ) then
   		draw.RoundedBox( self.cornerRndness, 0, 0, w, h, self.hoverColor )
   	else
   		draw.RoundedBox( self.cornerRndness, 0, 0, w, h, self.buttonColor )
   	end
   	surface.SetFont( self.textFont )
   	local txtW, txtH = surface.GetTextSize( self.text )
    if self.textAlign == TEXT_ALIGN_CENTER then
   	  draw.SimpleText( self.text, self.textFont, w * self.textXPosMulti, ( h / 2 ) - txtH / 2, self.textColor, TEXT_ALIGN_CENTER )
    elseif self.textAlign == TEXT_ALIGN_LEFT then
      local x = ( h / 2 ) - txtH / 2
      if self.leftPadding then x = self.leftPadding end
      draw.SimpleText( self.text, self.textFont, x, ( h / 2 ) - txtH / 2, self.textColor, TEXT_ALIGN_LEFT )
    end
    if ( self.buttonMaterial ) then
       local offset = 0
       if ( self.buttonMaterialBorder ) then
          offset = self.buttonMaterialBorder
       end
       surface.SetMaterial( self.buttonMaterial )
       surface.SetDrawColor( self.buttonMaterialColor )
       surface.DrawTexturedRect( offset, offset, w - ( offset * 2 ), h - ( offset * 2 ) )
    end
end

function PANEL:SetButtonImage( img, col, border )
    self.buttonMaterial = Material( img )
    self.buttonMaterialColor = col
    self.buttonMaterialBorder = border
end

function PANEL:ClearButtonImage( )
    self.buttonMaterial = nil
end

function PANEL:SetButtonColor( color )
	self.buttonColor = color
end

function PANEL:SetHoverColor( color )
	self.hoverColor = color
end

function PANEL:SetTextColor( color )
	self.textColor = color
end

function PANEL:SetTextFont( font )
	self.textFont = font
end

function PANEL:SetText( text )
	self.text = text
end

function PANEL:SetRoundness( amt )
	self.cornerRndness = amt
end

function PANEL:ModifyTextXPosMultiplier( multi )
	self.textXPosMulti = multi
end


function PANEL:SetTextAlign( algn )
  self.textAlign = algn
end

function PANEL:LeftPadding( num )
  self.leftPadding = num
end

vgui.Register( "DN00B_ColoredButton", PANEL, "Panel" )
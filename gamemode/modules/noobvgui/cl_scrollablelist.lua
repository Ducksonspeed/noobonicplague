local PANEL = { }

function PANEL:Init( )
    -- Setup all of the fallback values.
    self:SetSize( ScrW( ) * 0.5, ScrH( ) * 0.5 )
    self:SetPos( 0, 0 )
    self.dIconLayout = vgui.Create( "DIconLayout" )
    self:AddItem( self.dIconLayout )
    self.dIconLayout:SetSize( self:GetWide( ), self:GetTall( ) )
    self.dIconLayout:SetSpaceX( 5 )
    self.dIconLayout:SetSpaceY( 1 )
    self.drawListBackground = false
    self.oldDIconLayoutPaint = self.dIconLayout.Paint
    self.dIconLayoutBGData = { rnd = 0, color = Color( 255, 255, 255, 255 ) }
    self.dIconLayout.Paint = function( pnl, w, h )
       if ( self.drawListBackground ) then
          draw.RoundedBox( self.dIconLayoutBGData.rnd, 0, 0, w, h, self.dIconLayoutBGData.color )
       else
          self.oldDIconLayoutPaint( pnl, w, h )
       end
    end
end

function PANEL:SetScrollParent( )
   self.dIconLayout.scrollParent = self
end

function PANEL:DrawListBackground( rnd, color )
   self.drawListBackground = true
   self.dIconLayoutBGData = { rnd = rnd, color = color }
end

function PANEL:SetListWidthMultiplier( multi )
   self.dIconLayout:SetWide( self:GetWide( ) * multi )
end

function PANEL:SetSpaceX( num )
    self.dIconLayout:SetSpaceX( num )
end

function PANEL:SetSpaceY( num )
   self.dIconLayout:SetSpaceY( num )
end

function PANEL:AddElement( element )
   return self.dIconLayout:Add( element )
end

function PANEL:GetIconLayout( )
   return self.dIconLayout
end

function PANEL:ClearItems( )
   self.dIconLayout:Clear( )
end

function PANEL:GetElements( )
   return self.dIconLayout:GetChildren( ) or { }
end

vgui.Register( "DN00B_ScrollableList", PANEL, "DScrollPanel" )
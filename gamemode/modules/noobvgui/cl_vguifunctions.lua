local pnlMeta = FindMetaTable( "Panel" )
local upArrow = Material( "icon16/arrow_up.png" )
local downArrow = Material( "icon16/arrow_down.png" )
function pnlMeta:ColorizeScrollbar( upColor, downColor, gripColor, bgColor, drawArrows, arrowColor )
	if not ( self.VBar ) then return end
	self.VBar:GetChildren( )[1].Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, upColor )
		if ( drawArrows ) then
			local arrowColor = arrowColor or Color( 255, 255, 255, 255 )
			surface.SetMaterial( upArrow )
	        surface.SetDrawColor( arrowColor )
	        surface.DrawTexturedRect( 0, 0, w, h )
	    end
	end
	self.VBar:GetChildren( )[2].Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, downColor )
		if ( drawArrows ) then
			local arrowColor = arrowColor or Color( 255, 255, 255, 255 )
			surface.SetMaterial( downArrow )
	        surface.SetDrawColor( arrowColor )
	        surface.DrawTexturedRect( 0, 0, w, h )
	    end
	end
	self.VBar:GetChildren( )[3].Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, gripColor )
	end
	self.VBar.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, bgColor )
	end
end

function pnlMeta:OffsetFromCenter( x, y )
	self:Center( )
	local xPos, yPos = self:GetPos( )
	self:SetPos( xPos + x, yPos + y )
end

function draw.TextRotated( text, x, y, color, font, ang ) // Thanks based Garry's Mod Wiki.
	render.PushFilterMag( TEXFILTER.ANISOTROPIC )
	render.PushFilterMin( TEXFILTER.ANISOTROPIC )
	surface.SetFont( font )
	surface.SetTextColor( color )
	surface.SetTextPos( 0, 0 )
	local textWidth, textHeight = surface.GetTextSize( text )
	local rad = -math.rad( ang )
	local halvedPi = math.pi / 2
	x = x - ( math.sin( rad + halvedPi ) * textWidth / 2 + math.sin( rad ) * textHeight / 2 )
	y = y - ( math.cos( rad + halvedPi ) * textWidth / 2 + math.cos( rad ) * textHeight / 2 )
	local textMatrix = Matrix( )
	textMatrix:SetAngles( Angle( 0, ang, 0 ) )
	textMatrix:SetTranslation( Vector( x, y, 0 ) )
	cam.PushModelMatrix( textMatrix )
		surface.DrawText( text )
	cam.PopModelMatrix( )
	render.PopFilterMag( )
	render.PopFilterMin( )
end

function draw.TextScaled( text, x, y, font, color, scale )
	local textMatrix = Matrix( )

	textMatrix:Translate( Vector( x, y ) )
	textMatrix:Scale( Vector( scale, scale, scale ) )
	textMatrix:Translate( -Vector( x , y ) )

	cam.PushModelMatrix( textMatrix )
		surface.SetFont( font )
		surface.SetTextColor( color.r, color.g, color.b, color.a )
		local textW, textH = surface.GetTextSize( text )
		surface.SetTextPos( x - textW / 2, y )
		surface.DrawText( text )
	cam.PopModelMatrix( )	
end

function draw.TextPulsating( text, x, y, font, color, rate, minScale, maxScale )
	local realTime = RealTime( ) * rate
	
	local textMatrix = Matrix( )
	local w, h = ScrW( ), ScrH( )
	textMatrix:Translate( Vector( x, y ) )
	textMatrix:Scale( ( Vector( 1, 1, 1 ) * math.abs( math.sin( realTime / 100 ) ) ):UniformClamp( minScale, maxScale ) )
	textMatrix:Translate( -Vector( x, y ) )
	cam.PushModelMatrix( textMatrix )
		surface.SetFont( font )
		surface.SetTextColor( color.r, color.g, color.b, color.a )
		local textW, textH = surface.GetTextSize( text )
		surface.SetTextPos( x - textW / 2, y )
		surface.DrawText( text )
	cam.PopModelMatrix( )	
end
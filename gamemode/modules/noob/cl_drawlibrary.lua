local blurMaterial = Material( "pp/blurscreen" )

//Credits to Chessnut for the screen blur effect.
function draw.BlurredRect( x, y, w, h, weight, amt, col )
	local col = col or Color( 255, 255, 255, 255 )
	surface.SetDrawColor( col )
	surface.SetMaterial( blurMaterial )
	local weight = weight or 5
	for i = 1, weight do
		blurMaterial:SetFloat( "$blur", ( i / 3 ) * ( amt or 6 ) )
		blurMaterial:Recompute( )
		render.UpdateScreenEffectTexture( )
		render.SetScissorRect( x, y, x + w, y + h, true )
			surface.DrawTexturedRect( 0, 0, ScrW( ), ScrH( ) )
		render.SetScissorRect( 0, 0, 0, 0, false )
	end
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
end

function draw.TexturedRect( x, y, w, h, mat, col )
	local col = col or Color( 255, 255, 255, 255 )
	surface.SetDrawColor( col )
	surface.SetMaterial( mat )
	surface.DrawTexturedRect( x, y, w, h )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
end

function draw.HorizontalCutTexturedRect( x, y, w, h, mat, col, percent )
	render.SetScissorRect( x, y, x + ( w * percent ), y + h, true )
		draw.TexturedRect( x, y, w, h, mat, col )
	render.SetScissorRect( 0, 0, 0, 0, false )
end

function draw.TextSpecial( text, font, x, y, color, scale, ang )
	render.PushFilterMag( TEXFILTER.ANISOTROPIC )
	render.PushFilterMin( TEXFILTER.ANISOTROPIC )
	surface.SetFont( font )
	surface.SetTextColor( color )
	surface.SetTextPos( 0, 0 )
	local txtW, txtH = surface.GetTextSize( text )
	local txtMatrix = Matrix( )
	local x, y = x, y
	if ( scale and isvector( scale ) ) then
		txtMatrix:Scale( scale )
		txtW = txtW * scale[1]
		txtH = txtH * scale[2]
	elseif ( scale and isnumber( scale ) ) then
		txtMatrix:Scale( Vector( scale, scale, scale ) )
		txtW = txtW * scale
		txtH = txtH * scale
	end
	if ( scale and !ang ) then
		x, y = x - ( txtW * 0.5 ), y - ( txtH * 0.5 )
	end
	if ( ang ) then
		local rad = -math.rad( ang )
		local halvedPi = math.pi / 2
		x = x - ( math.sin( rad + halvedPi) * txtW / 2 + math.sin( rad ) * txtH / 2 )
		y = y - ( math.cos( rad + halvedPi ) * txtW / 2 + math.cos( rad ) * txtH / 2 )
		txtMatrix:SetAngles( Angle( 0, ang, 0 ) )
	end
	txtMatrix:SetTranslation( Vector( x, y, 0 ) )
	cam.PushModelMatrix( txtMatrix )
		surface.DrawText( text )
	cam.PopModelMatrix( )
	render.PopFilterMag( )
	render.PopFilterMin( )
end
surface.CreateFont( "N00BRP_ChristmasPresent_FontBold", {
	font = "Lobster",
	size = 55,
	weight = 750
} )

include( "shared.lua" )

function ENT:Draw( )
	self:DrawModel( )

	local pos = self:GetPos( )
	local ang = self:GetAngles()

	local giftPlayer = self:GetGiftPlayer( )
	if not ( IsValid( giftPlayer ) ) then
		giftPlayer = "Disconnected Player"
	else
		giftPlayer = giftPlayer:Name( )
	end

	ang:RotateAroundAxis( ang:Up(), 180 )
	ang:RotateAroundAxis( ang:Forward(), 90 )
	
	local textPosition = pos + ( ang:Up( ) * 0 ) + ( ang:Right( ) * -30 ) + ( ang:Forward( ) * 0 )
	cam.Start3D2D( textPosition, ang, 0.1 )
		draw.SimpleText( giftPlayer .. "'s Present", "N00BRP_ChristmasPresent_FontBold", 0, 0, Color( 255, 255, 255, 255), TEXT_ALIGN_CENTER  )
	cam.End3D2D()
end
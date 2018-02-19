include("shared.lua")

function ENT:Draw( )
	self:DrawModel( )

	local pos = self:GetPos( )
	local ang = self:GetAngles( )

	ang:RotateAroundAxis( ang:Up( ), 90 )
	ang:RotateAroundAxis( ang:Forward( ), 90 )
	local angYaw = LocalPlayer( ):GetAngles( ).y - 90
	cam.Start3D2D( pos + ang:Right( ) * -12, Angle( ang.p, ang.y, ang.r ), 0.02 )
		draw.SimpleText( self:GetPotionName( ), "N00BRP_MoneyPrinters_StatFontBold", 0, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	cam.End3D2D()
end
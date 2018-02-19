include("shared.lua")
function ENT:Draw( )
	self:DrawModel( )

	local pos = self:GetPos( )
	local ang = self:GetAngles()

	local owner = self:Getowning_ent( )
	owner = ( IsValid( owner ) and owner:Nick( ) ) or DarkRP.getPhrase("unknown" )

	ang:RotateAroundAxis( ang:Up(), 180 )
	ang:RotateAroundAxis( ang:Forward(), 90 )

	local textPosition = pos + ( ang:Up( ) * 8.35 ) + ( ang:Right( ) * -1 ) + ( ang:Forward( ) * -9 )
	local redShade = math.abs( math.sin( CurTime( ) * 4 ) * 100 ) + 150
	local txtColor = Color( 255, 255, 255, 255 )
	cam.Start3D2D( textPosition, ang, 0.03)
		draw.RoundedBox( 0, 0, -260, 600, 120, Color( 45, 75, 45, 255 ) )
		draw.SimpleText( "Power Remaining:", "N00BRP_MoneyPrinters_StatFont", 0, -265, txtColor, TEXT_ALIGN_LEFT )
		if ( self:GetPower( ) > 0 ) then
			draw.RoundedBoxEx( 0, 256, -252, 320, 24, Color( 170, 45, 45, 255 ) )
			draw.RoundedBoxEx( 0, 256, -252, 320 * ( self:GetPower( ) / 100 ), 24, Color( 45, 170, 45, 255 ) )
		else
			draw.SimpleText( "INSUFFICIENT POWER", "N00BRP_MoneyPrinters_StatFont", 256, -251, Color( redShade, 45, 45, 255), TEXT_ALIGN_LEFT )
		end
		draw.SimpleText( "Coolant Efficiency:", "N00BRP_MoneyPrinters_StatFont", 0, -220, txtColor, TEXT_ALIGN_LEFT )
		draw.RoundedBoxEx( 0, 256, -210, 320, 24, Color( 170, 45, 45, 255 ) )
		if ( self:GetCoolant( ) > 60 ) then
			draw.RoundedBoxEx( 0, 256, -210, 320 * ( self:GetCoolant( ) / 100 ), 24, Color( 235, 151, 78, 255 ) )
		else
			draw.RoundedBoxEx( 0, 256, -210, 320 * ( self:GetCoolant( ) / 100 ), 24, Color( redShade, 151, 78, 255 ) )
		end
		
		draw.SimpleText( "RAM:", "N00BRP_MoneyPrinters_StatFont", 0, -180, txtColor, TEXT_ALIGN_LEFT )
		draw.SimpleText( self.RAMLevelNames[ self:GetRAM( ) ], "N00BRP_MoneyPrinters_StatFont", 75, -180, Color( 188, 202, 217, 255), TEXT_ALIGN_LEFT )
		draw.RoundedBox( 0, 0, 45, 605, 120, Color( 45, 75, 45, 255 ) )
		draw.SimpleText( "Ink Remaining:", "N00BRP_MoneyPrinters_StatFont", 0, 44, txtColor, TEXT_ALIGN_LEFT )
		if ( self:GetInk( ) > 0 ) then
			draw.RoundedBoxEx( 0, 210, 50, 365, 24, Color( 170, 45, 45, 255 ) )
			draw.RoundedBoxEx( 0, 210, 50, 365 * ( self:GetInk( ) / 100 ), 24, Color( 45, 45, 170, 255 ) )
		else
			draw.SimpleText( "REFILL INK CARTRIDGES", "N00BRP_MoneyPrinters_StatFont", 210, 47, Color( redShade, 45, 45, 255), TEXT_ALIGN_LEFT )
		end
		draw.SimpleText( "Number of Cores:", "N00BRP_MoneyPrinters_StatFont", 0, 88, txtColor, TEXT_ALIGN_LEFT )
		draw.SimpleText( self:GetCPU( ), "N00BRP_MoneyPrinters_StatFontBold", 240, 78, Color( 170, 45, 45, 255), TEXT_ALIGN_LEFT )
		draw.SimpleText( "Owner: " .. owner, "N00BRP_MoneyPrinters_StatFont", 0, 128, txtColor, TEXT_ALIGN_LEFT )
	cam.End3D2D()
end
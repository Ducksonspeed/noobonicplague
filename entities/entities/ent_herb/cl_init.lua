include("shared.lua")
surface.CreateFont( "N00BRP_HerbGathering_StatusFont", {
	font = "Lobster",
	size = ScreenScale( 12 ),
	weight = 500
} )

function ENT:Draw( )
	self:DrawModel( )
end

local function DrawHarvestStatusBar( )
	LocalPlayer( ).currentGatherHerb = LocalPlayer( ).currentGatherHerb or nil
	if ( #ents.FindByClass( "ent_herb" ) <= 0 ) then return end
	if ( !IsValid( LocalPlayer( ).currentGatherHerb ) or LocalPlayer( ).currentGatherHerb:GetUsingEnt( ) ~= LocalPlayer( ) ) then
		LocalPlayer( ).currentGatherHerb = nil
		for index, herb in ipairs ( ents.FindByClass( "ent_herb" ) ) do
			if ( herb:GetUsingEnt( ) == LocalPlayer( ) ) then
				LocalPlayer( ).currentGatherHerb = herb
				break
			end
		end
	else
		local barColor = Color( 52, 152, 219 )
		local herb = LocalPlayer( ).currentGatherHerb
		if ( LocalPlayer( ):Team( ) == TEAM_HERBALIST ) then
			barColor = Color( 155, 89, 182 )
		end
		local dots = "."
		local dotSin = math.abs( math.sin( CurTime( ) * 2 ) )
		if ( dotSin < 0.3 ) then
			dots = "."
		elseif ( dotSin > 0.3 and dotSin < 0.6 ) then
			dots = ".."
		elseif ( dotSin > 0.6 ) then
			dots = "..."
		end
		local barWidth = math.Clamp( ( ScrW( ) * 0.2 ) * ( ( herb:GetFinishTime( ) - CurTime( ) ) / herb:GetHarvestLength( ) ), 10, ( ScrW( ) * 0.2 ) )
		draw.RoundedBox( 8, ScrW( ) * 0.4, ScrH( ) * 0.5, ScrW( ) * 0.2, ScrH( ) * 0.04, Color( 46, 204, 113 ) )
		draw.RoundedBox( 8, ScrW( ) * 0.4, ScrH( ) * 0.5,  barWidth, ScrH( ) * 0.04, barColor )
		draw.SimpleText( "Gathering" .. dots, "N00BRP_HerbGathering_StatusFont", ScrW( ) * 0.5, ScrH( ) * 0.502, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )	
	end
end
hook.Add( "HUDPaint", "N00BRP_DrawHarvestStatusBar_HUDPaint", DrawHarvestStatusBar )
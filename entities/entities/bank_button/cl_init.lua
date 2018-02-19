include( "shared.lua" );

hook.Add( "PreDrawHalos", "BankButtonOutline", function()
	local bank_button = ents.FindByClass( "bank_button" )[ 1 ];

	if ( IsValid( bank_button ) and bank_button:GetPos():Distance( LocalPlayer():GetPos() ) <= 120 ) then
		local sine = math.sin( CurTime() * 2 );
		halo.Add( { bank_button }, Color( sine * 255, sine * 51, sine * 51 ), 4, 4, 3 );
	end
end );

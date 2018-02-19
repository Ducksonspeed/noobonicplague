hook.Add( "PhysgunDrop", "FlingPlayer", function( pl, ent )
	if ( pl:IsSuperAdmin() and ent:IsPlayer() ) then
		ent:SetVelocity( ( ent:GetVelocity() * -1 ) + ( pl:GetAimVector() * pl.ScrollSpeed ) );
		pl.ScrollSpeed = 0;
	end
end );

hook.Add( "SetupMove", "FlingPlayer", function( pl, cmove, ccmd )
	if ( ccmd:GetMouseWheel() > 0 ) then
		pl.ScrollSpeed = ccmd:GetMouseWheel() * 1000;
	end
end );


concommand.Add( "permiteminv_refresh", function( pl, cmd, args )
	pl.WaitToRetrieve = pl.WaitToRetrieve or CurTime();
	if ( pl.WaitToRetrieve > CurTime() ) then
		pl:ChatPrint( Format( "You need to wait %s second(s) before you can refresh your weapon inventory.", tostring( math.floor( CurTime() - pl.WaitToRetrieve + 1 ) * -1 ) ) );
		return;
	end
	pl.WaitToRetrieve = CurTime() + 20;
	pl:RetrievePermWeapons();
end );


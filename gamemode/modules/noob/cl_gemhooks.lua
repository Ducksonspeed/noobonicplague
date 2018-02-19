local function RequestGemsTable( )
	net.Start( "N00BRP_PlayerGems_Net" )
	net.SendToServer( )
end
hook.Add( "InitPostEntity", "N00BRP_RequestGemsTable_InitPostEntity", RequestGemsTable )
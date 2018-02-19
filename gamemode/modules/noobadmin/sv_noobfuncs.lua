NOOB_ADMIN_BANTABLE = NOOB_ADMIN_BANTABLE or { }
NOOB_ADMIN_VIPTABLE = NOOB_ADMIN_VIPTABLE or { }
hook.Add( "NOOBRP_MySQL_Connected", "NoobAdminBansSQL", function()
	mySQLControl:CreateTable( "noobadmin_ranks", { "steamid varchar(255) UNIQUE KEY", "rank varchar(255)" } );
	mySQLControl:CreateTable( "noobadmin_bans", { "steamid varchar(255)", "time int", "reason varchar(255)", "adminname varchar(255)", "bantime int" } );
	mySQLControl:TableExists( "noobadmin_bans", function( tblCount )
		if ( #tblCount > 0 ) then
			mySQLControl:Query( "SELECT * FROM noobadmin_bans WHERE time > " .. os.time( ) .. ";", function( data )
				if ( #data > 0 ) then
					for index, dat in pairs ( data ) do
						NOOB_ADMIN_BANTABLE[dat.steamid] = { time = tonumber( dat.time ), reason = dat.reason, adminName = dat.adminname }
					end
					MsgC( Color( 150, 150, 245 ), "[NOOBADMIN] ", Color( 245, 150, 150 ), "has loaded ", Color( 255, 255, 255 ), #data, Color( 245, 150, 150 ), " bans.\n" )
				end
				mySQLControl:Query( "SELECT * FROM noobadmin_bans WHERE time = 0;", function( innerData )
					if ( #innerData > 0 ) then
						for index, dat in pairs ( innerData ) do
							NOOB_ADMIN_BANTABLE[dat.steamid] = { time = 0, reason = dat.reason, adminName = dat.adminname }
						end
						MsgC( Color( 150, 150, 245 ), "[NOOBADMIN] ", Color( 245, 150, 150 ), "has loaded ", Color( 255, 255, 255 ), #innerData, Color( 245, 150, 150 ), " permanent bans.\n" )
					end
				end )
			end )
		end
	end )
	mySQLControl:Query( "SELECT steamid FROM noobadmin_ranks WHERE rank = 'vip' OR rank = 'admin' OR rank = 'superadmin';", function( data )
		if ( #data > 0 ) then
			for index, dat in pairs ( data ) do
				NOOB_ADMIN_VIPTABLE[dat.steamid] = true
			end
		end
	end )
end );

/*timer.Create( "Noob_CheckForBans", 1, 0, function()
	mySQLControl:Query( "SELECT * FROM noobadmin_bans;", function( data ) 
		for k, v in pairs( data ) do
			if ( v.time <= 0 ) then continue; end -- game genies don't get a #chance at it nigga
			if ( v.time < os.time() ) then
				mySQLControl:Query( "DELETE FROM noobadmin_bans WHERE steamid = '"..v.steamid.."';", function( data )
					print( "unbanned "..v.steamid );
				end );
			end
		end
	end );
end );*/

/*hook.Add( "PlayerAuthed", "NoobCheckForBan", function( pl, steamid, uniqueid )
	mySQLControl:Query( "SELECT * FROM noobadmin_bans WHERE steamid = ".."'"..steamid.."';", function( data )
		if ( #data > 0 ) then
			local time_exp = ( data[ 1 ].time > 0 and ( ( data[ 1 ].time - os.time() ) / 60 ) ) or "never";
			pl:NoobKick( "You've been banned by: "..data[ 1 ].adminname, "Reason: "..data[ 1 ].reason, "Ban expires in: "..math.floor( time_exp ).." minute(s)" );
		end
	end );
end );*/

hook.Add( "CheckPassword", "NOOBRP_RejectBannedPlayers_CheckPassword", function( steam64, ipAddress, svPassword, clPassword, name )
	if ( svPassword and svPassword ~= "" and clPassword ~= svPassword ) then
		return false, "You entered the incorrect password."
	end
	local steamID = util.SteamIDFrom64( steam64 )
	if ( NOOB_ADMIN_BANTABLE[steamID] ) then
		local banInfo = NOOB_ADMIN_BANTABLE[steamID]
		if ( banInfo.time == 0 ) then
			return false, "You're permanently banned from this server.\nReason: " .. banInfo.reason .. "\nAdmin: " .. banInfo.adminName
		end
		if ( banInfo.time > os.time( ) ) then
			// Player is still banned.
			local timeLeft = string.NiceTime( banInfo.time - os.time( ) )
			return false, "You're banned from this server.\nReason: " .. banInfo.reason .. "\nTime Left: " .. timeLeft .. "\nAdmin: " .. banInfo.adminName
		else
			// Player is no longer banned.
			NOOB_ADMIN_BANTABLE[steamID] = nil
			return true
		end
	else
		local visibleMaxPlayers = tonumber( GetConVarNumber( "sv_visiblemaxplayers" ) )
		if ( #player.GetAll( ) >= visibleMaxPlayers and !NOOB_ADMIN_VIPTABLE[steamID] ) then
			return false, "You were unable to join the server, it's full."
		else
			return true
		end
	end
end )

hook.Add( "PlayerInitialSpawn", "NoobCheckForRank", function( pl )
	mySQLControl:Query( "SELECT * FROM noobadmin_ranks WHERE steamid = "..pl:EncloseSteamID()..";", function( data )
		if ( #data > 0 ) then
			pl:SetRank( data[ 1 ].rank, false );
		end
	end );
end );

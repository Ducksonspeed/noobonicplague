local ServerID = "548526b7f76a758272a7599a";

if ( !file.Exists( "gmodprime_votes.txt", "DATA" ) ) then
	file.Write( "gmodprime_votes.txt", "{\"nigger\":true}" );
end

if ( !file.Exists( "gmodprime_favorites.txt", "DATA" ) ) then
	file.Write( "gmodprime_favorites.txt", "{\"nigger\":true}" );
end

local function CheckVote( pl )
	if ( !IsValid( pl ) ) then return; end

	local s64 = pl:SteamID64();
	local sid = pl:SteamID();

	http.Fetch( "http://gmodpri.me/api/userdata/"..s64,
		function( body, len, headers, code )
			if ( body:len() == 0 ) then
				pl:ChatPrint( "No valid account found on gmodpri.me, go login and vote for our server." );
				return;
			end

			local mm = util.JSONToTable( body );
			local votes, favorites = util.JSONToTable( mm.votes ), util.JSONToTable( mm.favorites );

			if ( votes[ ServerID ] ) then
				local cvotes = util.JSONToTable( file.Read( "gmodprime_votes.txt" ) );
				if ( !cvotes[ sid ] ) then
					cvotes[ sid ] = true; // s64 doesn't work well as a number string index.. don't know how to make it escape correctly..
					file.Write( "gmodprime_votes.txt", util.TableToJSON( cvotes ) );
					pl:addMoney( 20000 );
					pl:ChatPrint( "Thanks for voting! :-)" );
				else
					pl:ChatPrint( "You already voted once. Get on an alt and do that you stupid fuck." );
				end
			else
				pl:ChatPrint( "You didn't vote for our server." );
			end

			if ( favorites[ ServerID ] ) then
				local cfaves = util.JSONToTable( file.Read( "gmodprime_favorites.txt" ) );
				if ( !cfaves[ sid ] ) then
					cfaves[ sid ] = true;
					file.Write( "gmodprime_favorites.txt", util.TableToJSON( cfaves ) );
					pl:addMoney( 20000 );
					pl:ChatPrint( "Thanks for favoriting! :-)" );
				else
					pl:ChatPrint( "You already favorited once. Get on an alt and do that you stupid fuck." );
				end
			else
				pl:ChatPrint( "You didn't favorite our server." );
			end
		end,
		function( err )
			timer.Simple( 2, function()
				CheckVote( s64 );
			end );
		end
	);
end

concommand.Add( "gmodprime_checkvote", function( pl, cmd, args )
	pl.CheckVoteWait = pl.CheckVoteWait or CurTime();

	if ( pl.CheckVoteWait > CurTime() ) then
		local wait = math.floor( ( CurTime() - pl.CheckVoteWait ) * -1 ) + 1;
		pl:ChatPrint( Format( "Please wait %s second(s) before voting again.", tostring( wait ) ) )
		return;
	end

	pl.CheckVoteWait = CurTime() + 1;

	CheckVote( pl );
end );


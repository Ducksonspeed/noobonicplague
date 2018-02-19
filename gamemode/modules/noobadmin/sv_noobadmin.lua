NOOB_ADMIN = NOOB_ADMIN or {};

local plyMeta = FindMetaTable( "Player" )
util.AddNetworkString( "update_playerrank" );
util.AddNetworkString( "noobadmin_chatcolor" );
util.AddNetworkString( "noobadmin_networkcommands" );
util.AddNetworkString( "noobadmin_alert" )
util.AddNetworkString( "N00BRP_NotesMenu")

function NOOB_ADMIN:CreateCommand( command, who_can_access, func, infoTable )
	command = "np_"..command;

	// if ( NOOB_ADMIN[ command ] != nil ) then return; end // uncomment this if you don't want cmds to refresh.

	NOOB_ADMIN[ command ] = { func = func, access = who_can_access, clientTable = infoTable };

	concommand.Add( command, function( pl, cmd_name, args )
		NOOB_ADMIN:RunCommand( pl, command, args );
	end );
end

function NOOB_ADMIN:RunCommand( pl, command, args )
	if ( NOOB_ADMIN[ command ] == nil ) then return; end
	if not ( IsValid( pl ) ) then return end
	if not ( isfunction( pl.CanAccess ) ) then return end
	if ( !pl:CanAccess( NOOB_ADMIN[ command ].access ) ) then
		pl:ChatPrint( "You do not have access to: "..command );
		return;
	end

	table.insert( args, 1, pl ); -- include the admin as well. ( so we don't have to search )

	NOOB_ADMIN[ command ].func( unpack( args ) );
end

function NOOB_ADMIN:Notification( ... )
	local tab = { ... };
	table.insert( tab, 1, "(ADMIN)" );
	local msg = string.Implode( " ", tab );
	PrintMessage( HUD_PRINTTALK, msg );
end

local colortext = 
{
	[ "r" ] = { prefix = "r", color = Color( 231, 76, 60 ) },
	[ "g" ] = { prefix = "g", color = Color( 46, 204, 113 ) },
	[ "b" ] = { prefix = "b", color = Color( 52, 152, 219 ) },
	[ "o" ] = { prefix = "o", color = Color( 230, 126, 34 ) },
	[ "y" ] = { prefix = "y", color = Color( 241, 196, 15 ) },
	[ "p" ] = { prefix = "p", color = Color( 155, 89, 182 ) },
	[ "w" ] = { prefix = "w", color = Color( 236, 240, 241 ) }
};

-- OH MY GOD THIS IS TERRIBLE. IT'S LIKE SIN REBORN.  SDASJODJNASD
hook.Add( "PlayerSay", "noobadmin_RunSayCommand", function( pl, args )
	if ( string.Left( args, 2 ) == "@ " ) then
		args = args:gsub( "@ ", "", 1 );
		if not ( pl:IsAdmin( ) ) then
			pl:ChatPrint( Format( "%s to admins: %s", pl:Name(), args ) )
		end
		for k, v in pairs( player.GetAll() ) do
			if ( v:IsAdmin( ) ) then
				v:ChatPrint( Format( "%s( %d ) to admins: %s", pl:Name(), pl:UserID( ), args ) );
			end
		end
		return "";
	elseif ( string.Left( args, 3 ) == "@@ " and pl:IsAdmin() ) then
		args = args:gsub( "@@ ", "", 1 );

		if ( colortext[ string.Left( args, 1 ) ] ) then
			local col = colortext[ string.Left( args, 1 ) ].color;

			args = args:gsub( colortext[ string.Left( args, 1 ) ].prefix.." ", "", 1 );

			net.Start( "noobadmin_chatcolor" );
				net.WriteTable( { r = col.r, g = col.g, b = col.b } );
				net.WriteString( args );
			net.Broadcast();
		else
			for k, v in pairs( player.GetAll() ) do
				v:ChatPrint( args );
			end
		end
		return "";
	elseif ( string.Left( args, 3 ) == "/@ " and pl:IsAdmin() ) then
		args = args:gsub( "/@ ", "", 1 )
		if ( string.len( args ) <= 0 ) then DarkRP.notify( pl, 1, 4, "You must enter a player's name." ) return "" end
		local endPos = string.find( args, "%s" )
		if not ( endPos ) then DarkRP.notify( pl, 1, 4, "You must enter a message." ) return "" end
		local tarPly = string.Left( args, endPos - 1 )
		args = args:gsub( tarPly, "", 1 )
		tarPly = util.FindPlayer( tarPly )
		if not ( IsValid( tarPly ) ) then DarkRP.notify( pl, 1, 4, "That player wasn't found." ) return "" end
		if ( string.len( args ) <= 0 ) then DarkRP.notify( pl, 1, 4, "You must enter a message." ) return "" end
		local message = "(ADMIN) " .. pl:Name( ) .. " to " .. tarPly:Name( ) .. ":" .. args
		tarPly:ChatPrint( message )
		for index, ply in ipairs ( player.GetAll( ) ) do
			if ( ply:IsAdmin( ) ) then
				ply:ChatPrint( message )
			end
		end
		return ""
	end
end );

function NOOB_ADMIN:SendCommandsTable( ply )
	for index, cmd in pairs ( NOOB_ADMIN ) do
		if ( type( cmd ) == "function" ) then continue end
		if not ( cmd.clientTable ) then continue end
		if not ( ply:IsAdmin( ) ) then return end
		local tbl = cmd.clientTable
		local dataTable = { name = index, rank = cmd.access, desc = tbl.desc, syntax = tbl.syntax, args = tbl.args }
		net.Start( "noobadmin_networkcommands" )
			net.WriteTable( dataTable )
		net.Send( ply )
	end
end

local function NOOB_ADMIN_RequestedCommands( len, ply )
	NOOB_ADMIN:SendCommandsTable( ply )
end
net.Receive( "noobadmin_networkcommands", NOOB_ADMIN_RequestedCommands )

local function NOOB_ADMIN_OpenMenuBind( ply )
	if not ( ply:GetEyeTrace( ).Entity ) then return end
	if not ( ply:IsAdmin( ) ) then return end
	local selEnt = ply:GetEyeTrace( ).Entity
	if ( selEnt:isDoor( ) or selEnt:IsVehicle( ) ) then
		if ( selEnt:GetPos( ):FastDist( ply:GetPos( ) ) < 2000 ) then
			return
		end
	end
	ply:ConCommand( "np_openmenu" )
end
hook.Add( "ShowTeam", "N00BRP_N00BAdminOpenMenuBind_ShowTeam", NOOB_ADMIN_OpenMenuBind )

function NOOB_ADMIN:GetNameBySteamID( steamID, callback )
	if not ( steamID ) then callback( nil ) return end
	mySQLControl:Query( "SELECT rpname FROM playerinformation JOIN darkrp_player ON playerinformation.uid = darkrp_player.uid WHERE playerinformation.steamID = " .. SQLStr( steamID ) .. ";", function( data ) 
		if ( #data < 1 ) then
			callback( nil )
		else
			callback( data[1].rpname )
		end
	end )
end

function NOOB_ADMIN:BanID( steamid, time, reason, admin )
	NOOB_ADMIN:NotifyAdmins( "(ADMIN) " .. tostring( admin ) .. " initiating ban on " .. tostring( steamid ), NP_ADMIN_ATTENTION )
	local _reason = mySQLControl:Escape( reason ); _reason = "'".._reason.."'";
	local _admin = mySQLControl:Escape( admin ); _admin = "'".._admin.."'";
	local rawID = steamid
	local steamid = "'" .. steamid .. "'"
	local _time = os.time() + math.floor( time * 60 );
	local banDate = os.time( )
	if ( NOOB_ADMIN_BANTABLE[rawID] ) then
		local banInfo = NOOB_ADMIN_BANTABLE[rawID]
		if ( banInfo.time > os.time( ) ) then
			if ( time == 0 ) then
				mySQLControl:Query( "INSERT INTO noobadmin_bans VALUES(" .. steamid .. ", " .. "0, " .. _reason .. ", " .. _admin .. ", " .. banDate .. ");", function( ) end )
				NOOB_ADMIN_BANTABLE[rawID] = { time = 0, reason = reason, adminName = admin }
			end
		else
			if ( time ~= 0 ) then
				mySQLControl:Query( "INSERT INTO noobadmin_bans VALUES(" .. steamid .. ", " .. _time .. ", " .. _reason .. ", " .. _admin .. ", " .. banDate .. ");", function( ) end )
				NOOB_ADMIN_BANTABLE[rawID] = { time = _time, reason = reason, adminName = admin }
			else
				mySQLControl:Query( "INSERT INTO noobadmin_bans VALUES(" .. steamid .. ", " .. "0, " .. _reason .. ", " .. _admin .. ", " .. banDate .. ");", function( ) end )
				NOOB_ADMIN_BANTABLE[rawID] = { time = 0, reason = reason, adminName = admin }
			end
		end
	else
		if ( time ~= 0 ) then
			mySQLControl:Query( "INSERT INTO noobadmin_bans VALUES(" .. steamid .. ", " .. _time .. ", " .. _reason .. ", " .. _admin .. ", " .. banDate .. ");", function( ) end )
			NOOB_ADMIN_BANTABLE[rawID] = { time = _time, reason = reason, adminName = admin }
		else
			mySQLControl:Query( "INSERT INTO noobadmin_bans VALUES(" .. steamid .. ", " .. "0, " .. _reason .. ", " .. _admin .. ", " .. banDate .. ");", function( ) end )
			NOOB_ADMIN_BANTABLE[rawID] = { time = 0, reason = reason, adminName = admin }
		end
	end
	for index, ply in ipairs ( player.GetAll( ) ) do
		if ( ply:SteamID( ) == rawID ) then
			ply:NoobKick( "You've been banned by: "..admin, "Reason: " .. reason, "Ban expires in: " .. time .. " minute(s)" );
			break
		end
	end
end

function NOOB_ADMIN:UnBan( steamid )
	mySQLControl:Query( "SELECT * FROM noobadmin_bans WHERE steamid = '" .. steamid .. "' ORDER BY `bantime` DESC LIMIT 1;", function( data )
		if ( #data > 0 ) then
			for index, dat in pairs ( data ) do
				local expireTime = dat.time
				if ( expireTime == 0 ) then
					mySQLControl:Query( "UPDATE noobadmin_bans SET time = -1 WHERE steamid = '" .. steamid .. "' AND time = " .. dat.time .. " AND reason = '" .. dat.reason .. "' AND adminname = '" .. dat.adminname .. "' AND bantime = " .. dat.bantime .. ";", function( ) end )
					NOOB_ADMIN_BANTABLE[steamid] = nil
				else
					mySQLControl:Query( "UPDATE noobadmin_bans SET time = " .. os.time( ) .. " WHERE steamid = '" .. steamid .. "' AND time = " .. dat.time .. " AND reason = '" .. dat.reason .. "' AND adminname = '" .. dat.adminname .. "' AND bantime = " .. dat.bantime .. ";", function( ) end )
					NOOB_ADMIN_BANTABLE[steamid] = nil
				end
			end
		end
	end )
end

function NOOB_ADMIN_StorePlayerIP(ply, cmd)
		if not ply or not IsValid(ply) then return end
		if ( ply:IsBot( ) or ply:SteamID( ) == "BOT" ) then return end
		local steam = ply:SteamID()
		local ip = ply:IPAddress()
		local p = string.find(ip, ":") - 1
		local ip_short = string.sub(ip, 1, p)

		mySQLControl:Query("SELECT * from darkrp_playerips where steam = '" .. steam .. "' and ip = '" .. ip_short .. "';", function ( data )
			if #data < 1 then
				mySQLControl:Query("INSERT INTO darkrp_playerips (steam,ip) VALUES ('" .. steam .. "', '" .. ip_short .. "');", function( ) end )
			end
		end);

	end

hook.Add("PlayerInitialSpawn", "NOOB_ADMIN_StorePlayerIP", NOOB_ADMIN_StorePlayerIP )

function NOOB_ADMIN:GetIPInfo( ip, cback )
	local cleanIP = ip
	if string.find( cleanIP, ":" ) then 
		cleanIP = string.sub( ip, 1, string.find(ip, ":") - 1)
	end
	local apiUrl = "http://ip-api.com/json/" .. cleanIP
	http.Fetch( apiUrl, function( txt )
		local result = util.JSONToTable( txt )
		local info = {}
		if not result["country"] then info = false else
			info.Country = result["country"]
			info.City = result["city"]
			info.Region = result["region"]
		end
		cback( info )
	end)
end

function NOOB_ADMIN:NotifyPlayerJoin( ply )
	NOOB_ADMIN:GetIPInfo( ply:CleanIP(), function( data )
		local msg = ply:Nick() .. " ( " .. ply:SteamID() .. " ) [ " .. ply:UserID() .. " ] has joined."
		NOOB_ADMIN:NotifyAdmins( msg, NP_ADMIN_NOTIFICATION )
		if data then msg = data.City .. ", " ..data.Region .. " (" .. data.Country .. ")" end
		NOOB_ADMIN:NotifySuperAdmins( msg, NP_ADMIN_NOTIFICATION )
		NOOB_ADMIN:GetPlayersWithSameIP( ply, function( players )

			if players then

				local plyList = ""
				local activePlayers = false
				for _, ply in pairs( players ) do
					plyList = plyList .. "\n" .. ply.Name .. " ( ".. ply.SteamID .. " )"
					if ply.Active then activePlayers = true end
				end

				local msg = ply:Nick() .. " matches address of: " .. plyList
				NOOB_ADMIN:NotifyAdmins( msg, NP_ADMIN_ATTENTION )

				if activePlayers then
					local plyList = ""
					for _,ply in pairs( players ) do
						if ply.Active then
							plyList = plyList .. "\n" .. ply.Name .. " ( ".. ply.Active .. " )"
						end
					end
					msg = "The following are active: " .. plyList
					NOOB_ADMIN:NotifyAdmins( msg, NP_ADMIN_URGENT )
				end

			end

		end)
	end)

end

local _metaply = FindMetaTable("Player")
function _metaply:CleanIP( )
	if self:IsBot() then return "0.0.0.0" end
	local ip = self:IPAddress()
	return string.sub( ip, 1, string.find(ip, ":") - 1)
end

function NOOB_ADMIN:GetPlayersWithSameIP( ply, cback )
	local ip = ply:CleanIP()
	local query = [[select player.rpname, playerinfo.ip, playerinfo.steamID from 
		(
		 select info.uid, ip.ip, info.steamID from playerinformation info
		 join darkrp_playerips ip
		 on info.steamID = ip.steam
		) as playerinfo
		join darkrp_player player
		on player.uid = playerinfo.uid
		where playerinfo.ip=]] .. "'" .. ip .. "'"
	mySQLControl:Query( query, function( data )
		if #data > 1 then
			local players = {}
			for _,result in pairs( data ) do
				if result["steamID"] != ply:SteamID() then
					local ply = {}
					ply.Name = result["rpname"]
					ply.SteamID = result["steamID"]
					ply.Active = false
					for __,pl in pairs( player.GetAll() ) do
						if ply.SteamID == pl:SteamID() then
							ply.Active = pl:UserID()
						end
					end
					table.insert( players, ply )
				end
			end
			cback( players )
		else
			cback( false )
		end
	end)
end

function NOOB_ADMIN:NotifyAdmins( msg, priority )
	net.Start( "noobadmin_alert" )
		net.WriteInt( priority, 3 )
		net.WriteString( msg )
	net.Send( NOOB_ADMIN:GetAdmins() )
	DarkRP.log( "[" .. string.upper(NP_ADMIN_ALERTS[priority].Name) .. "] :: " .. msg, NP_ADMIN_ALERTS[priority].Color )
end

function NOOB_ADMIN:GetAdmins()
	local admins = {}
	for _,ply in pairs( player.GetAll() ) do
		if ply:IsAdmin() then
			table.insert( admins, ply )
		end
	end
	return admins
end

function NOOB_ADMIN:NotifySuperAdmins( msg, priority )
	net.Start( "noobadmin_alert" )
		net.WriteInt( priority, 3 )
		net.WriteString( msg )
	net.Send( NOOB_ADMIN:GetSuperAdmins() )
	DarkRP.log( "[" .. string.upper(NP_ADMIN_ALERTS[priority].Name) .. "] :: " .. msg, NP_ADMIN_ALERTS[priority].Color )
end

function NOOB_ADMIN:GetSuperAdmins()
	local superadmins = {}
	for _,ply in pairs( player.GetAll() ) do
		if ply:IsSuperAdmin() then
			table.insert( superadmins, ply )
		end
	end
	return superadmins
end

function plyMeta:SetRank( rank, update )
	self:SetUserGroup( rank );

	net.Start( "update_playerrank" );
		net.WriteTable( { steamid = self:SteamID(), rank = rank } );
	net.Broadcast();

	if ( !update ) then return; end

	rank = mySQLControl:Escape( rank ); rank = "'"..rank.."'";
	local steamid = self:EncloseSteamID();

	mySQLControl:Query( "SELECT * FROM noobadmin_ranks WHERE steamid = "..steamid..";", function( data )
		if ( #data > 0 ) then
			mySQLControl:Query( "UPDATE noobadmin_ranks SET rank = "..rank.." WHERE steamid = "..steamid..";", function( data ) end );
		else
			mySQLControl:Query( "INSERT INTO noobadmin_ranks VALUES("..steamid..", "..rank..");", function( data ) end );
		end
	end );
end

function plyMeta:RemoveRank( )
	local steamid = self:EncloseSteamID();

	mySQLControl:Query( "SELECT * FROM noobadmin_ranks WHERE steamid = "..steamid.." LIMIT 1;", function( data )
		if ( #data > 0 ) then
			mySQLControl:Query( "DELETE FROM noobadmin_ranks WHERE steamid = "..steamid, function( data ) end );
			self:SetRank( "", false );
		end
	end );
end

function plyMeta:NoobBan( time, reason, admin )
	local _reason = mySQLControl:Escape( reason ); _reason = "'".._reason.."'";
	local _admin = mySQLControl:Escape( admin ); _admin = "'".._admin.."'";
	local steamid = self:EncloseSteamID();
	local _time = os.time() + math.floor( time * 60 );
	local banDate = os.time( )
	if ( NOOB_ADMIN_BANTABLE[self:SteamID( )] ) then
		local banInfo = NOOB_ADMIN_BANTABLE[self:SteamID( )]
		if ( banInfo.time == 0 ) then
			PrintMessage( HUD_PRINTTALK, self:SteamID( ) .. " is already banned, ban attempt has been ceased." )
			return
		end
		if ( banInfo.time > os.time( ) ) then
			if ( time ~= 0 ) then
				PrintMessage( HUD_PRINTTALK, self:SteamID( ) .. " is already banned, ban attempt has been ceased." )
				return
			else
				mySQLControl:Query( "INSERT INTO noobadmin_bans VALUES(" .. steamid .. ", " .. "0, " .. _reason .. ", " .. _admin .. ", " .. banDate .. ");", function( ) end )
				NOOB_ADMIN_BANTABLE[self:SteamID( )] = { time = 0, reason = reason, adminName = admin }
			end
		else
			if ( time ~= 0 ) then
				mySQLControl:Query( "INSERT INTO noobadmin_bans VALUES(" .. steamid .. ", " .. _time .. ", " .. _reason .. ", " .. _admin .. ", " .. banDate .. ");", function( ) end )
				NOOB_ADMIN_BANTABLE[self:SteamID( )] = { time = _time, reason = reason, adminName = admin }
			else
				mySQLControl:Query( "INSERT INTO noobadmin_bans VALUES(" .. steamid .. ", " .. "0, " .. _reason .. ", " .. _admin .. ", " .. banDate .. ");", function( ) end )
				NOOB_ADMIN_BANTABLE[self:SteamID( )] = { time = 0, reason = reason, adminName = admin }
			end
		end
	else
		if ( time ~= 0 ) then
			mySQLControl:Query( "INSERT INTO noobadmin_bans VALUES(" .. steamid .. ", " .. _time .. ", " .. _reason .. ", " .. _admin .. ", " .. banDate .. ");", function( ) end )
			NOOB_ADMIN_BANTABLE[self:SteamID( )] = { time = _time, reason = reason, adminName = admin }
		else
			mySQLControl:Query( "INSERT INTO noobadmin_bans VALUES(" .. steamid .. ", " .. "0, " .. _reason .. ", " .. _admin .. ", " .. banDate .. ");", function( ) end )
			NOOB_ADMIN_BANTABLE[self:SteamID( )] = { time = 0, reason = reason, adminName = admin }
		end
	end
	self:NoobKick( "You've been banned by: "..admin, "Reason: "..reason, "Ban expires in: "..time.." minute(s)" );
end

function plyMeta:NoobKick( ... )
	local reason = { ... };
	table.insert( reason, 1, "" );
	self:Kick( string.Implode( "\n", reason ) );
end

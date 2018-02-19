local pmeta = FindMetaTable( "Player" );

NP_ADMIN_NOTIFICATION = 1
NP_ADMIN_ATTENTION = 2
NP_ADMIN_URGENT = 3

NP_ADMIN_ALERTS = {
	[1] = {
		Name = "Notification",
		Color = Color( 123, 239, 183 ),
		Sound = false
	},
	[2] = {
		Name = "Attention",
		Color = Color( 242, 152, 56 ),
		Sound = "noob_admin/npa_attention.wav"
	},
	[3] = {
		Name = "Urgent",
		Color = Color( 242, 56, 60 ),
		Sound = "noob_admin/npa_urgent.wav"
	}
}

function pmeta:IsNeogreen( )
	return ( self:SteamID( ) == "STEAM_0:0:33770352" )
end

function pmeta:IsCobra( )
	return ( self:SteamID( ) == "STEAM_0:0:20510578" )
end

function pmeta:IsSchmal( )
	return ( self:SteamID( ) == "STEAM_0:1:36486164" )
end

function pmeta:IsRocksofspades( )
	return ( self:SteamID( ) == "STEAM_0:1:14989768" )
end

function pmeta:IsJeezy( )
	return ( self:SteamID( ) == "STEAM_0:0:16790507" )
end

function pmeta:GetRank()
	return self:GetNWString( "usergroup" );
end

function pmeta:IsSuperAdmin()
	if ( self:GetRank() == "superadmin" ) then return true; end
	return false;
end

function pmeta:IsAdmin()
	if not IsValid(self) then return false end
	if ( self:GetRank() == "superadmin" or self:GetRank() == "admin" ) then return true end
	return false;
end

function pmeta:CanAccess( rank )
	if ( self:IsSuperAdmin() ) then return true; end
	if ( self:IsAdmin() and rank == "admin" ) then return true; end
	return false;
end

function pmeta:IsVIP()
	if ( self:IsAdmin() ) then
		return true
	end
	if ( self:GetRank( ) == "vip" ) then
		return true
	else
		return false
	end
end

if ( CLIENT ) then
	net.Receive( "update_playerrank", function()
		local tab = net.ReadTable();

		for k, v in pairs( player.GetAll() ) do
			if ( v:SteamID() == tab.steamid ) then
				v:SetNWString( "usergroup", tab.rank );
			end
		end
	end );
end

function FindPlayer( val )

	local function isSteam( val )
		if isstring( val ) and string.StartWith( val, "STEAM_" ) then return true end
		return false
	end

	local function isUID( val )
		local check = tonumber( val )
		if check then
			for _,ply in pairs( player.GetAll() ) do
				if check == ply:UserID() then return ply end
			end
		end
		return false
	end

	-- USER ID

	local uid = isUID( val )
	if uid then return uid end

	-- STEAMID

	if isSteam( val ) then
		for _,ply in pairs( player.GetAll() ) do
			if IsValid(ply) and ply:SteamID() == val then return ply end
		end
	end

	-- RPNAME EXACT

	local srch = string.lower( val )

	for _,ply in pairs( player.GetAll() ) do
		if not IsValid( ply ) then continue end
		local cname = string.lower( ply:Name() )
		if cname == srch then return ply end
	end

	-- RPNAME PARTIAL

	local matches = {}
	for _,ply in pairs( player.GetAll() ) do
		if not IsValid( ply ) then continue end
		local cname = string.lower( ply:Name() )
		//print( cname )
		//print( srch )
		local result = string.find( cname, srch )
		if result then
			table.insert( matches, ply )
		end
	end

	if #matches == 1 then
		return matches[1]
	elseif #matches > 1 then
		local match = false
		for _,ply in pairs( matches ) do
			if not match then 
				match = ply
			elseif string.len( match:Name() ) > string.len( ply:Name() ) then
				match = ply
			elseif string.len( match:Name() ) == string.len( ply:Name() ) then
				match = false
				break
			end
		end
		return match
	end

	return false

end

timer.Simple( 1, function()
	DarkRP.LegacyPlayer = DarkRP.findPlayer
	DarkRP.findPlayer = FindPlayer
end)

-- debug help in case it fucks up

concommand.Add( "np_restorefind", function(ply) 
	if not ply:IsSuperAdmin() then return end
	DarkRP.findPlayer = DarkRP.LegacyPlayer
end)
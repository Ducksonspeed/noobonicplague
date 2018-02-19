local GemTableValues = {
	["rock"] = "Rocks",
	["granite"] = "Granite",
	["shale"] = "Shale",
	["emerald"] = "Emeralds",
	["ruby"] = "Rubies",
	["sapphire"] = "Sapphires",
	["obsidian"] = "Obsidians",
	["diamond"] = "Diamonds"
}
local CleanGemTableValues = {
	["Rocks"] = "rock",
	["Granite"] = "granite",
	["Shale"] = "shale",
	["Emeralds"] = "emerald",
	["Rubies"] = "ruby",
	["Sapphires"] = "sapphire",
	["Obsidians"] = "obsidian",
	["Diamonds"] = "diamond"
}

util.AddNetworkString( "N00BRP_PlayerGems_Net" )

local function ClientRequestGemsTable( len, ply )
	if ( ply.receivedGemsTable ) then return end
	ply.receivedGemsTable = true
	ply:RetrieveGems( )
end
net.Receive( "N00BRP_PlayerGems_Net", ClientRequestGemsTable )

local function PlayerDropGem( ply, cmd, args, fstring )
	if not ( args[1] ) then return end
	//if ( ply:getDarkRPVar( "IsGhost" ) ) then return end
	if ( ply:IsGhost( ) ) then return end
	if ( ply:IsTrading() or ply:IsTradeBanned() ) then return; end
	ply.droppedGems = ply.droppedGems or 0
	if ( ply.droppedGems >= 5 ) then
		DarkRP.notify( ply, 1, 4, "You must pickup some gems first." )
		return
	end
	local plyGemTable = ply.gemTable
	local arg = string.lower( args[1] )
	if not ( GemTableValues[ arg ] ) then 
		if ( CleanGemTableValues[ args[1] ] ) then
			arg = CleanGemTableValues[ args[1] ]
		else
			return
	end	end
	local gemAmt = plyGemTable[ GemTableValues[ arg ] ]
	if ( gemAmt <= 0 ) then
		DarkRP.notify( ply, 1, 4, "You lack that gem to drop." )
	else
		local tableEntry = GemTableValues[ arg ]
		ply:GiveGem( tableEntry, -1 )
		ply:DropGem( arg )
		local uppLetter = string.upper( string.GetChar( arg, 1 ) )
		local niceWord = string.SetChar( arg, 1, uppLetter )
		if ( niceWord == "Obsidian" or niceWord == "Diamond" ) then
			local mes = ply:NiceInfo( true ) .. " dropped a " .. niceWord
			NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, mes, false )
		end
		ply:ChatPrint( "You dropped a " .. niceWord .. "!" )
	end
end
concommand.Add( "dropgem", PlayerDropGem )

local function OpenGemMenu( ply, args )
	ply:ConCommand( "noob_togglegemsmenu" )
end
DarkRP.defineChatCommand( "gemsmenu", OpenGemMenu )
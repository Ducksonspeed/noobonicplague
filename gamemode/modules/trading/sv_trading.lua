// NOTE: set net_fakelag to 300-500 (check if it can store through lag as the resulting threshold)

util.AddNetworkString( "TradeSystem_Accepted_Start" );
util.AddNetworkString( "TradeSystem_Accepted_Canceled" );
util.AddNetworkString( "TradeSystem_UpdateInventory" );
util.AddNetworkString( "TradeSystem_UpdateMoney" );
util.AddNetworkString( "TradeSystem_TradeStatus" );
util.AddNetworkString( "TradeSystem_TradeFinished_ReceiveItems" );
util.AddNetworkString( "TradeSystem_ChatBoxMessage" );

local pm = FindMetaTable( "Player" );

function pm:ResetTradeCfg()
	local DelayGet = TRADING_SYSTEM.TRADE_DELAY;
	if ( self.TradeCfg and self.TradeCfg.CurrentlyTrading ) then
		self.TradeCfg.CurrentlyTrading.TradeCfg = { TradeDelay = CurTime() + DelayGet, TradeStatus = 0, TradeStatusProc = 0, CurrentlyTrading = false, RequestingTrade = false, Rdy = false, StoreItems = { Old = {}, New = {} }, MoneyTraded = { Backup = 0, Temp = 0 } };
	end

	self.TradeCfg = { TradeDelay = CurTime() + DelayGet, TradeStatus = 0, TradeStatusProc = 0, CurrentlyTrading = false, RequestingTrade = false, Rdy = false, StoreItems = { Old = {}, New = {} }, MoneyTraded = { Backup = 0, Temp = 0 } };
end

function pm:IsTrading()
	local check = false;
	if ( self.TradeCfg and self.TradeCfg.CurrentlyTrading ) then check = true; end
	return check;
end

function pm:IsTradeBanned()
	local tradeBans = SVNOOB_VARS:Get( "TradingBans", true, "table", { } )
	if ( tradeBans[self:SteamID( )] ) then
		DarkRP.notify( self, NOTIFY_ERROR, 4, "You're banned from using the Trade System." )
		return true
	end
	return false
end

function pm:TickQueueInterval()
	self.TradeCfg.QueueInterval = ( self.TradeCfg.QueueInterval and self.TradeCfg.QueueInterval + 1 ) or 1;

	if ( self.TradeCfg.QueueInterval >= 3 ) then
		if ( self.TradeCfg.CurrentlyTrading.TradeCfg.QueueInterval and self.TradeCfg.CurrentlyTrading.TradeCfg.QueueInterval >= 3 ) then
			net.Start( "TradeSystem_Accepted_Start" );
				net.WriteTable( { SteamID = self:SteamID(), Name = self:Name(), SelfInventory = self.TradeCfg.CurrentlyTrading.TradeCfg.StoreItems.Old } );
			net.Send( self.TradeCfg.CurrentlyTrading );

			net.Start( "TradeSystem_Accepted_Start" );
				net.WriteTable( { SteamID = self.TradeCfg.CurrentlyTrading:SteamID(), Name = self.TradeCfg.CurrentlyTrading:Name(), SelfInventory = self.TradeCfg.StoreItems.Old } );
			net.Send( self );

			self.TradeCfg.QueueInterval = 0;
			self.TradeCfg.CurrentlyTrading.TradeCfg.QueueInterval = 0;
		else
			self.TradeCfg.CurrentlyTrading:SetupTradeInventory();
		end
	end
end

function pm:SetupTradeInventory()
	local hmm, mmmm, uhhhh = 0, 0, 0;

	mySQLControl:Query( Format( "SELECT * FROM darkrp_gems WHERE uniqueid = '%s';", self:UniqueID() ), function( data )
		if ( #data > 0 ) then
			for a, b in pairs( data[ 1 ] ) do
				hmm = hmm + 1;
				b = tonumber( b );
				if ( a != "uniqueid" and b >= 1 ) then
					// a = a:sub( 0, 1 ):upper()..a:gsub( a:sub( 0, 1 ), "", 1 ); // JUST JOKES. SPAGHETTI CODE.
					// a = a:gsub( a:sub( a:find( " " ), a:find( " " ) + 1 ), ""..a:sub( a:find( " " ), a:find( " " ) + 1 ):upper(), 1 );
					self.TradeCfg.StoreItems.Old[ TRADING_SYSTEM.ITEM_NICEFORMAT[ "Gems" ][ a ] ] = b;
				end
				if ( hmm >= table.Count( data[ 1 ] ) ) then
					self:TickQueueInterval();
				end
			end
		else
			self:TickQueueInterval();
		end
	end );

	mySQLControl:Query( Format( "SELECT * FROM darkrp_ingredients WHERE uniqueid = '%s';", self:UniqueID() ), function( data )
		if ( #data > 0 ) then
			for a, b in pairs( data[ 1 ] ) do
				mmmm = mmmm + 1;
				b = tonumber( b );
				if ( a != "uniqueid" and b >= 1 ) then
					// a = a:sub( 0, 1 ):upper()..a:gsub( a:sub( 0, 1 ), "", 1 ); // JUST JOKES. SPAGHETTI CODE.
					self.TradeCfg.StoreItems.Old[ TRADING_SYSTEM.ITEM_NICEFORMAT[ "Ingredients" ][ a ] ] = b;
				end
				if ( mmmm >= table.Count( data[ 1 ] ) ) then
					self:TickQueueInterval();
				end
			end
		else
			self:TickQueueInterval();
		end
	end );

	/*mySQLControl:Query( Format( "SELECT * FROM darkrp_permweps WHERE steamid = '%s';", self:SteamID() ), function( data )
		if ( #data > 0 ) then
			for a, b in pairs( data ) do
				uhhhh = uhhhh + 1;
				if ( !TRADING_SYSTEM.ITEM_RESTRICTIONS[ b.class ] ) then
					self.TradeCfg.StoreItems.Old[ b.class ] = ( self.TradeCfg.StoreItems.Old[ b.class ] and self.TradeCfg.StoreItems.Old[ b.class ] + 1 ) or 1; // if stack items ever exist later on, have the stack index of the darkrpvar be the amount.
				end
				if ( uhhhh >= table.Count( data ) ) then
					self:TickQueueInterval();
				end
			end
		else
			self:TickQueueInterval();
		end
	end );*/
	self:TickQueueInterval() -- no idea

	self.TradeCfg.MoneyTraded.Backup = self:getDarkRPVar( "money" );
end

hook.Add( "PlayerInitialSpawn", "TradeSystem_SetupCfg", function( pl )
	pl:ResetTradeCfg(); // let's keep all this in a table -- more organized.
	pl.TradeCfg.TradeDelay = 0;
	pl.TradeBlacklist = {};
end );

hook.Add( "PlayerDisconnected", "TradeSystem_CancelTrade", function( pl )
	if ( pl:IsTrading() ) then
		pl.TradeCfg.CurrentlyTrading:SendLua( [[if (ValidPanel(TRADING_SYSTEM.TradeMainFrame)) then TRADING_SYSTEM.TradeMainFrame:Remove(true); end]] );
		DarkRP.notify( pl.TradeCfg.CurrentlyTrading, 1, 4, "The trader disconnected from the server." );
		pl:ResetTradeCfg();
	end
end );

/*
local function IsTradeBanned( pl )
	local tradeBans = SVNOOB_VARS:Get( "TradingBans", true, "table", { } )
	if ( tradeBans[pl:SteamID( )] ) then
		DarkRP.notify( pl, NOTIFY_ERROR, 4, "You're banned from using the Trade System." )
		return true
	end
	return false
end
*/

hook.Add( "PlayerSay", "TradeSystem_RequestTrade", function( pl, str )
	if ( TRADING_SYSTEM.ENABLED ) then
		if ( str:lower() == "/tradecancel" ) then
			if ( pl:IsTradeBanned() ) then return "" end
			if ( !pl.TradeCfg.RequestingTrade ) then 
				DarkRP.notify( pl, 1, 4, "You haven't requested a trade with anyone." );
				return "";
			end

			DarkRP.notify( pl, 1, 4, Format( "You've canceled your trade request with %s", pl.TradeCfg.RequestingTrade:Name() ) );
			DarkRP.notify( pl.TradeCfg.RequestingTrade, 1, 4, Format( "%s has canceled the trade request.", pl:Name() ) );

			pl:ResetTradeCfg();

			return "";
		elseif ( str:lower() == "/tradeaccept" ) then
			if ( pl:IsTrading() or pl.TradeCfg.TradeDelay > CurTime() ) then return ""; end
			if ( pl:IsTradeBanned() ) then return "" end
			for k, v in pairs( player.GetAll() ) do
				if ( v.TradeCfg.RequestingTrade == pl and !v:IsTrading() ) then
					v.TradeCfg.RequestingTrade = nil;
					v.TradeCfg.CurrentlyTrading = pl;
					pl.TradeCfg.CurrentlyTrading = v;

					pl:SetupTradeInventory();

					break;
				end
			end

			return "";
		elseif ( string.Left( str:lower(), 16 ) == "/tradeblacklist " ) then
			if ( pl:IsTradeBanned() ) then return "" end
			str = str:gsub( "/tradeblacklist ", "", 1 );

			// apparently pattern complements don't work correctly with .match (or .find), afaik, so we'll do this instead.
			if ( str:match( "STEAM_%d:%d:%d" ) and !ss:match( "STEAM_%d:%d:%d[%s+]" ) ) then return ""; end
			if ( pl.TradeBlacklist[ str ] ) then return ""; end

			for k, v in pairs( player.GetAll() ) do
				if ( v:SteamID() == str ) then
					pl.TradeBlacklist[ v:SteamID() ] = true;
					
					if ( v.TradeCfg.RequestingTrade == pl ) then
						v.TradeCfg.RequestingTrade = nil;
						DarkRP.notify( v, 1, 4, Format( "%s has ignored your request and has blacklisted you.", pl:Name() ) );
					end

					break;
				end
			end
			
			return "";
		elseif ( string.Left( str:lower(), 15 ) == "/tradeblremove " ) then
			if ( pl:IsTradeBanned() ) then return "" end
			str = str:gsub( "/tradeblremove ", "", 1 );

			// apparently pattern complements don't work correctly with .match (or .find), afaik, so we'll do this instead.
			if ( str:match( "STEAM_%d:%d:%d" ) and !ss:match( "STEAM_%d:%d:%d[%s+]" ) ) then return ""; end

			pl.TradeBlacklist[ str ] = nil;

			return "";
		elseif ( string.Left( str:lower(), 7 ) == "/trade " ) then
			if ( pl:IsTradeBanned() ) then return "" end
			str = str:gsub( "/trade ", "", 1 );

			if ( pl:UserID() == tonumber( str ) and !pl:IsSuperAdmin() ) then // IsSuperAdmin for testing purposes.
				DarkRP.notify( pl, 1, 4, "You can't trade with yourself." );
				return "";
			elseif ( pl.TradeCfg.TradeDelay > CurTime() ) then
				DarkRP.notify( pl, 1, 4, Format( "You need to wait %s second(s) before trading with another player.", math.floor( pl.TradeCfg.TradeDelay - CurTime() ) + 1 ) );
				return "";
			elseif ( pl.TradeCfg.RequestingTrade ) then
				DarkRP.notify( pl, 1, 4, Format( "You're already requesting a trade with %s. /tradecancel to cancel your current trade request.", pl.TradeCfg.RequestingTrade:Name() ) );
				return "";
			end

			for k, v in pairs( player.GetAll() ) do
				if ( v:UserID() == tonumber( str ) ) then
					if ( v.TradeBlacklist[ pl:SteamID() ] ) then
						DarkRP.notify( pl, 1, 4, Format( "%s has blacklisted you from trading them.", v:Name() ) );
					elseif ( v:IsTrading() ) then
						DarkRP.notify( pl, 1, 4, Format( "%s is currently trading with another player.", v:Name() ) );
					else
						pl.TradeCfg.RequestingTrade = v;
						DarkRP.notify( v, 2, 4, Format( "%s is requesting a trade. /tradeaccept (accept the trade), /tradeblacklist SteamID (always ignore his request)", pl:Name() ) );
					end

					break;
				end
			end

			return "";
		end
	end
end );

hook.Add( "PlayerDisconnect", "TradeSystem_PlayerRefreshCfg", function( pl )
	timer.Simple( 1, function() pl:ResetTradeCfg(); end );
end );

net.Receive( "TradeSystem_ChatBoxMessage", function( len, pl )
	if ( !pl:IsTrading() ) then return; end

	if ( pl.TradeCfg.MessageDelay and pl.TradeCfg.MessageDelay > CurTime() ) then return; end
	pl.TradeCfg.MessageDelay = pl.TradeCfg.MessageDelay or CurTime() + 0.5;

	net.Start( "TradeSystem_ChatBoxMessage" );
		net.WriteTable( { Name = pl:Name(), Msg = net.ReadString(), Admin = ( pl:IsSuperAdmin() and "superadmin" ) or ( pl:IsAdmin() and "admin" ) } );
	net.Send( pl.TradeCfg.CurrentlyTrading );
end );

net.Receive( "TradeSystem_Accepted_Canceled", function( len, pl )
	if ( !pl:IsTrading() ) then return; end

	pl.TradeCfg.CurrentlyTrading:SendLua( [[if (ValidPanel(TRADING_SYSTEM.TradeMainFrame)) then TRADING_SYSTEM.TradeMainFrame:Remove(true); end]] );
	DarkRP.notify( pl.TradeCfg.CurrentlyTrading, 1, 4, Format( "%s declined the trade.", pl:Name() ) );

	pl:ResetTradeCfg();
end );

net.Receive( "TradeSystem_UpdateMoney", function( len, pl )
	if ( !pl:IsTrading() ) then return; end
	if ( pl.TradeCfg.TradeStatusProc >= 1 and pl.TradeCfg.CurrentlyTrading.TradeCfg.TradeStatusProc >= 1 ) then return; end

	local amount = net.ReadInt( 32 );

	if ( !tonumber( amount ) ) then return; end

	local total = math.floor( pl.TradeCfg.MoneyTraded.Temp + amount );

	if ( pl.TradeCfg.MoneyTraded.Backup >= total and total >= 0 ) then
		pl.TradeCfg.MoneyTraded.Temp = total;

		pl.TradeCfg.CurrentlyTrading.TradeCfg.TradeStatus = 0;
		pl.TradeCfg.TradeStatus = 0;

		net.Start( "TradeSystem_TradeStatus" );
			net.WriteUInt( 4, 16 );
			net.WriteString( pl:SteamID() );
		net.Send( { pl, pl.TradeCfg.CurrentlyTrading } );

		net.Start( "TradeSystem_UpdateMoney" );
			net.WriteString( tostring( total ) );
		net.Send( pl.TradeCfg.CurrentlyTrading );
	end
end );

net.Receive( "TradeSystem_UpdateInventory", function( len, pl )
	if ( !pl:IsTrading() ) then return; end
	if ( pl.TradeCfg.TradeStatusProc >= 1 and pl.TradeCfg.CurrentlyTrading.TradeCfg.TradeStatusProc >= 1 ) then return; end

	local action = net.ReadString();
	local item = net.ReadTable();

	if ( table.Count( item ) == 2 and item.Class and item.Amount ) then
		local ok = false;
		if ( action == "send" ) then
			if ( !pl.TradeCfg.StoreItems.New[ item.Class ] or ( pl.TradeCfg.StoreItems.New[ item.Class ] > 0 and pl.TradeCfg.StoreItems.New[ item.Class ] <= TRADING_SYSTEM.MAX_SLOTS ) ) then
				if ( pl.TradeCfg.StoreItems.Old[ item.Class ] and pl.TradeCfg.StoreItems.Old[ item.Class ] >= item.Amount ) then
					if ( pl.TradeCfg.StoreItems.Old[ item.Class ] >= pl.TradeCfg.StoreItems.Old[ item.Class ] - item.Amount ) then
						pl.TradeCfg.StoreItems.Old[ item.Class ] = pl.TradeCfg.StoreItems.Old[ item.Class ] - item.Amount;
						if ( pl.TradeCfg.StoreItems.Old[ item.Class ] == 0 ) then pl.TradeCfg.StoreItems.Old[ item.Class ] = nil; end
						pl.TradeCfg.StoreItems.New[ item.Class ] = ( pl.TradeCfg.StoreItems.New[ item.Class ] and pl.TradeCfg.StoreItems.New[ item.Class ] + item.Amount ) or item.Amount;
						ok = true;
					end
				end
			end
		elseif ( action == "retrieve" ) then
			if ( pl.TradeCfg.StoreItems.New[ item.Class ] and pl.TradeCfg.StoreItems.New[ item.Class ] > pl.TradeCfg.StoreItems.New[ item.Class ] - item.Amount ) then
				pl.TradeCfg.StoreItems.New[ item.Class ] = pl.TradeCfg.StoreItems.New[ item.Class ] - item.Amount;
				if ( pl.TradeCfg.StoreItems.New[ item.Class ] == 0 ) then pl.TradeCfg.StoreItems.New[ item.Class ] = nil; end
				pl.TradeCfg.StoreItems.Old[ item.Class ] = ( pl.TradeCfg.StoreItems.Old[ item.Class ] and pl.TradeCfg.StoreItems.Old[ item.Class ] + item.Amount ) or item.Amount;
				ok = true;
			end
		end

		if ( !ok ) then return; end // they might possibly be exploiting. bypassing amount limit via clientside lua.
		
		net.Start( "TradeSystem_UpdateInventory" );
			net.WriteString( action );
			net.WriteTable( item );
		net.Send( pl.TradeCfg.CurrentlyTrading );
	end
end );

local IsGem = { Rocks = true, Granite = true, Shale = true, Emeralds = true, Rubies = true, Sapphires = true, Obsidians = true, Diamonds = true };
local IsHerb = { ["Burdock Root"] = true, ["Gingko Biloba"] = true, ["Valerian Root"] = true, ["Coral Fungus"] = true, ["Red Reishi"] = true, ["Psilocybe Cubensis"] = true };
local function GiveShit( TraderOne, TraderTwo )
	local TraderOneAmount = math.Clamp( TraderOne.Money, 0, TraderOne.Player:getDarkRPVar( "money" ) );
	if ( TraderOneAmount >= 1 ) then
		TraderOne.Player:addMoney( -TraderOneAmount );
		TraderTwo.Player:addMoney( TraderOneAmount );
	end

	local TraderTwoAmount = math.Clamp( TraderTwo.Money, 0, TraderTwo.Player:getDarkRPVar( "money" ) );
	if ( TraderTwoAmount >= 1 ) then
		TraderTwo.Player:addMoney( -TraderTwoAmount );
		TraderOne.Player:addMoney( TraderTwoAmount );
	end

	local LogOne = { Format( "[TRADE] %s (%s) traded: {", TraderOne.Player:Name(), TraderOne.Player:SteamID() ) };
	local numerical_check1 = 0;

	for class, amount in pairs( TraderOne.Items ) do
		if ( IsGem[ class ] ) then
			TraderTwo.Player:GiveGem( class, amount );
		elseif ( IsHerb[ class ] ) then
			TraderTwo.Player:GiveHerb( class, amount );
		else
			TraderTwo.Player:GivePermWeapon( class, true, amount, true );
		end
		table.insert( LogOne, Format( "[%s = %s]", class, tostring( amount ) ) );
	end
	table.insert( LogOne, Format( "[MONEY: %s]", tostring( TraderOneAmount ) ) );
	table.insert( LogOne, "}" );
	NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, string.Implode( " ", LogOne ) , true );

	local LogTwo = { Format( "[TRADE] %s (%s) traded: {", TraderTwo.Player:Name(), TraderTwo.Player:SteamID() ) };
	local numerical_check2 = 0;

	for class, amount in pairs( TraderTwo.Items ) do
		if ( IsGem[ class ] ) then
			TraderOne.Player:GiveGem( class, amount );
		elseif ( IsHerb[ class ] ) then
			TraderOne.Player:GiveHerb( class, amount );
		else
			TraderOne.Player:GivePermWeapon( class, true, amount, true );
		end
		table.insert( LogTwo, Format( "[%s = %s]", class, tostring( amount ) ) );
	end

	table.insert( LogTwo, Format( "[MONEY: %s]", tostring( TraderTwoAmount ) ) );
	table.insert( LogTwo, "}" );
	NOOB_LOGGER:Log( NOOB_LOGGING_ALERT, string.Implode( " ", LogTwo ) , true );

	timer.Simple( 5, function()
		TraderOne.Player:RetrievePermWeapons();
		TraderTwo.Player:RetrievePermWeapons();

		TraderOne.Player:ChatPrint( "Type permiteminv_refresh if your inventory hasn't auto-refreshed." );
		TraderTwo.Player:ChatPrint( "Type permiteminv_refresh if your inventory hasn't auto-refreshed." );
	end );
end
local function RemoveShit( TraderOne, TraderTwo )
	local checkmoney1 = ( TraderOne.Player:getDarkRPVar( "money" ) < 0 and 0 ) or TraderOne.Player:getDarkRPVar( "money" );
	local checkmoney2 = ( TraderTwo.Player:getDarkRPVar( "money" ) < 0 and 0 ) or TraderTwo.Player:getDarkRPVar( "money" );
	if ( checkmoney1 < TraderOne.Money ) then
		DarkRP.notify( TraderOne.Player, 1, 4, "The trade has been cancelled. You have less money than inputed in the previous trade." );
		DarkRP.notify( TraderTwo.Player, 1, 4, "The trade has been cancelled. The other user has less money than inputted in the previous trade." );
		return;
	end
	if ( checkmoney2 < TraderTwo.Money ) then
		DarkRP.notify( TraderTwo.Player, 1, 4, "The trade has been cancelled. You have less money than inputed in the previous trade." );
		DarkRP.notify( TraderOne.Player, 1, 4, "The trade has been cancelled. The other user has less money than inputted in the previous trade." );
		return;
	end

	local check1, check2 = 0, 0;
	// shitty code ofc
	if ( table.Count( TraderOne.Items ) >= 1 and table.Count( TraderTwo.Items ) >= 1 ) then
		for class, amount in pairs( TraderOne.Items ) do
			if ( IsGem[ class ] ) then
				TraderOne.Player:GiveGem( class, -amount );
			elseif ( IsHerb[ class ] ) then
				TraderOne.Player:GiveHerb( class, -amount );
			else
				TraderOne.Player:RemovePermWeapon( class, amount, true );
			end
			check1 = check1 + 1;

			if ( check1 >= table.Count( TraderOne.Items ) ) then
				for _class, _amount in pairs( TraderTwo.Items ) do
					if ( IsGem[ _class ] ) then
						TraderTwo.Player:GiveGem( _class, -_amount );
					elseif ( IsHerb[ _class ] ) then
						TraderTwo.Player:GiveHerb( _class, -_amount );
					else
						TraderTwo.Player:RemovePermWeapon( _class, _amount, true );
					end
					check2 = check2 + 1;

					if ( check2 >= table.Count( TraderTwo.Items ) ) then
						GiveShit( TraderOne, TraderTwo );
					end
				end
			end
		end
	elseif ( table.Count( TraderOne.Items ) >= 1 and table.Count( TraderTwo.Items ) < 1 ) then
		for class, amount in pairs( TraderOne.Items ) do
			if ( IsGem[ class ] ) then
				TraderOne.Player:GiveGem( class, -amount );
			elseif ( IsHerb[ class ] ) then
				TraderOne.Player:GiveHerb( class, -amount );
			else
				TraderOne.Player:RemovePermWeapon( class, amount, true );
			end
			check1 = check1 + 1;

			if ( check1 >= table.Count( TraderOne.Items ) ) then
				GiveShit( TraderOne, TraderTwo );
			end
		end
	elseif ( table.Count( TraderOne.Items ) < 1 and table.Count( TraderTwo.Items ) >= 1 ) then
		for class, amount in pairs( TraderTwo.Items ) do
			if ( IsGem[ class ] ) then
				TraderTwo.Player:GiveGem( class, -amount );
			elseif ( IsHerb[ class ] ) then
				TraderTwo.Player:GiveHerb( class, -amount );
			else
				TraderTwo.Player:RemovePermWeapon( class, amount, true );
			end
			check1 = check1 + 1;

			if ( check1 >= table.Count( TraderTwo.Items ) ) then
				GiveShit( TraderOne, TraderTwo );
			end
		end
	end
end

net.Receive( "TradeSystem_TradeFinished_ReceiveItems", function( len, pl )
	if ( !pl:IsTrading() ) then return; end

	if ( pl.TradeCfg.TradeStatusProc >= 3 and pl.TradeCfg.CurrentlyTrading.TradeCfg.TradeStatusProc >= 3 ) then
		pl.TradeCfg.Finalized = true;

		if ( pl.TradeCfg.Finalized and pl.TradeCfg.CurrentlyTrading.TradeCfg.Finalized ) then
			RemoveShit( { Player = pl, Items = pl.TradeCfg.StoreItems.New, Money = pl.TradeCfg.MoneyTraded.Temp }, { Player = pl.TradeCfg.CurrentlyTrading, Items = pl.TradeCfg.CurrentlyTrading.TradeCfg.StoreItems.New, Money = pl.TradeCfg.CurrentlyTrading.TradeCfg.MoneyTraded.Temp } );
			pl:ResetTradeCfg();
		end
	end
end );

net.Receive( "TradeSystem_TradeStatus", function( len, pl )
	if ( !pl:IsTrading() ) then return; end

	local act = net.ReadString();
	local status = 0;

	if ( act == "interrupted" ) then
		pl.TradeCfg.CurrentlyTrading.TradeCfg.TradeStatus = 0;
		pl.TradeCfg.TradeStatus = 0;

		net.Start( "TradeSystem_TradeStatus" );
			net.WriteUInt( status, 16 );
			net.WriteString( pl:SteamID() );
		net.Send( { pl, pl.TradeCfg.CurrentlyTrading } );

		return;
	end

	if ( pl.TradeCfg.TradeStatus > pl.TradeCfg.CurrentlyTrading.TradeCfg.TradeStatus ) then return; end

	pl.TradeCfg.TradeStatus = ( pl.TradeCfg.TradeStatusProc > 0 and pl.TradeCfg.TradeStatus + pl.TradeCfg.TradeStatusProc ) or 1;
	status = ( pl.TradeCfg.TradeStatus == pl.TradeCfg.CurrentlyTrading.TradeCfg.TradeStatus and pl.TradeCfg.TradeStatus ) or 0;

	local check = status;

	pl.TradeCfg.TradeStatus = ( status == pl.TradeCfg.TradeStatus and status + 1 ) or pl.TradeCfg.TradeStatus;

	if ( status == 0 ) then
		net.Start( "TradeSystem_TradeStatus" );
			net.WriteUInt( pl.TradeCfg.TradeStatus, 16 );
			net.WriteString( pl:SteamID() );
		net.Send( { pl, pl.TradeCfg.CurrentlyTrading } );
	else
		net.Start( "TradeSystem_TradeStatus" );
			net.WriteUInt( status + 1, 16 );
			net.WriteString( "" );
		net.Send( { pl, pl.TradeCfg.CurrentlyTrading } );
	end

	if ( status == check and status > 0 ) then
		pl.TradeCfg.TradeStatusProc = status + 1;
		pl.TradeCfg.CurrentlyTrading.TradeCfg.TradeStatusProc = status + 1;
		pl.TradeCfg.TradeStatus = 0;
		pl.TradeCfg.CurrentlyTrading.TradeCfg.TradeStatus = 0;
				
		if ( status == 2 ) then
			pl:SendLua( [[if (ValidPanel(TRADING_SYSTEM.TradeMainFrame)) then TRADING_SYSTEM.TradeMainFrame:Remove(true); end]] );
			pl.TradeCfg.CurrentlyTrading:SendLua( [[if (ValidPanel(TRADING_SYSTEM.TradeMainFrame)) then TRADING_SYSTEM.TradeMainFrame:Remove(true); end]] );

			net.Start( "TradeSystem_TradeFinished_ReceiveItems" );
			net.Send( { pl, pl.TradeCfg.CurrentlyTrading } );
		end
	end
end );


local function GetDefaultHostName( )
	local hostName = SVNOOB_VARS:Get( "DefaultHostName", true, "string", "Noobonic Plague | Legacy" )
	return hostName
end

local function DoublePrinterEvent( plr, cmd, args, fstring )
	if ( !IsValid( plr ) or plr:IsSuperAdmin( ) ) then
		if ( SVNOOB_VARS:Get( "MaxMoneyPrinters" ) >= 2 ) then
			if ( IsValid( plr ) ) then
				plr:ChatPrint( "The max money printers is already at or above two." )
			else
				print( "The max money printers is already at or above two." )
			end
			return
		end
		local mes = ""
		if ( IsValid( plr ) ) then
			mes = plr:NiceInfo( ) .. " has begun a Printer Event"
		else
			mes = "Console has started a Printer Event"
		end
		NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
		SVNOOB_VARS:Set( "MaxMoneyPrinters", 2 )
		//SVNOOB_VARS:Set( "MaxBasicMoneyPrinters", 2 )
		//SVNOOB_VARS:Set( "MaxAdvMoneyPrinters", 2 )
		for index, ply in ipairs ( player.GetAll( ) ) do
			DarkRP.notify( ply, 2, 4, "You may now have a total of two Money Printers." )
		end
		PrintMessage( HUD_PRINTTALK, "(EVENT) A surplus of black market money printers has arrived in the city. Citizens are permitted to purchase one extra printer for the next hour." )
		RunConsoleCommand( "hostname", GetDefaultHostName( ) .. " | Double Printer Event" )
		timer.Simple( 3000, function( )
			PrintMessage( HUD_PRINTTALK, "(EVENT) Experts say the amount of money printers are dwindling." )
		end ) 
		timer.Simple( 3600, function( )
			SVNOOB_VARS:Set( "MaxMoneyPrinters", 1 )
			--SVNOOB_VARS:Set( "MaxBasicMoneyPrinters", 1 )
			--SVNOOB_VARS:Set( "MaxAdvMoneyPrinters", 1 )
			PrintMessage( HUD_PRINTTALK, "(EVENT) The printing event has ended. You are once again limited to only one Money Printer." )
			RunConsoleCommand( "hostname", GetDefaultHostName( ) )
		end )
	end
end
concommand.Add( "np_printerevent", DoublePrinterEvent )

local function TriplePrinterEvent( plr, cmd, args, fstring )
	if ( !IsValid( plr ) or plr:IsSuperAdmin( ) ) then
		if ( SVNOOB_VARS:Get( "MaxMoneyPrinters" ) >= 3 ) then
			if ( IsValid( plr ) ) then
				plr:ChatPrint( "The max money printers is already at or above three." )
			else
				print( "The max money printers is already at or above three." )
			end
			return
		end
		local mes = ""
		if ( IsValid( plr ) ) then
			mes = plr:NiceInfo( ) .. " has begun a Triple Printer Event"
		else
			mes = "Console has started a Triple Printer Event"
		end
		NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
		SVNOOB_VARS:Set( "MaxMoneyPrinters", 3 )
		//SVNOOB_VARS:Set( "MaxBasicMoneyPrinters", 3 )
		//SVNOOB_VARS:Set( "MaxAdvMoneyPrinters", 3 )
		for index, ply in ipairs ( player.GetAll( ) ) do
			DarkRP.notify( ply, 2, 4, "You may now have a total of three Money Printers." )
		end
		PrintMessage( HUD_PRINTTALK, "(EVENT) A surplus of black market money printers has arrived in the city. Citizens are permitted to purchase two extra printers for the next hour." )
		RunConsoleCommand( "hostname", GetDefaultHostName( ) .. " | Triple Printer Event" )
		timer.Simple( 3000, function( )
			PrintMessage( HUD_PRINTTALK, "(EVENT) Experts say the amount of money printers are dwindling." )
		end ) 
		timer.Simple( 3600, function( )
			SVNOOB_VARS:Set( "MaxMoneyPrinters", 1 )
			//SVNOOB_VARS:Set( "MaxBasicMoneyPrinters", 1 )
			//SVNOOB_VARS:Set( "MaxAdvMoneyPrinters", 1 )
			PrintMessage( HUD_PRINTTALK, "(EVENT) The printing event has ended. You are once again limited to only one Money Printer." )
			RunConsoleCommand( "hostname", GetDefaultHostName( ) )
		end )
	end
end
concommand.Add( "np_tripleprinterevent", TriplePrinterEvent )

local function QuadPrinterEvent( plr, cmd, args, fstring )
	if ( !IsValid( plr ) or plr:IsSuperAdmin( ) ) then
		if ( SVNOOB_VARS:Get( "MaxMoneyPrinters" ) >= 4 ) then
			if ( IsValid( plr ) ) then
				plr:ChatPrint( "The max money printers is already at or above four." )
			else
				print( "The max money printers is already at or above four." )
			end
			return
		end
		local mes = ""
		if ( IsValid( plr ) ) then
			mes = plr:NiceInfo( ) .. " has begun a Quad Printer Event"
		else
			mes = "Console has started a Quad Printer Event"
		end
		NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
		SVNOOB_VARS:Set( "MaxMoneyPrinters", 4 )
		//SVNOOB_VARS:Set( "MaxBasicMoneyPrinters", 4 )
		//SVNOOB_VARS:Set( "MaxAdvMoneyPrinters", 4 )
		for index, ply in ipairs ( player.GetAll( ) ) do
			DarkRP.notify( ply, 2, 4, "You may now have a total of four Money Printers." )
		end
		PrintMessage( HUD_PRINTTALK, "(EVENT) A surplus of black market money printers has arrived in the city. Citizens are permitted to purchase three extra printers for the next hour." )
		RunConsoleCommand( "hostname", GetDefaultHostName( ) .. " | Quad Printer Event" )
		timer.Simple( 3000, function( )
			PrintMessage( HUD_PRINTTALK, "(EVENT) Experts say the amount of money printers are dwindling." )
		end ) 
		timer.Simple( 3600, function( )
			SVNOOB_VARS:Set( "MaxMoneyPrinters", 1 )
			--SVNOOB_VARS:Set( "MaxBasicMoneyPrinters", 1 )
			--SVNOOB_VARS:Set( "MaxAdvMoneyPrinters", 1 )
			PrintMessage( HUD_PRINTTALK, "(EVENT) The printing event has ended. You are once again limited to only one Money Printer." )
			RunConsoleCommand( "hostname", GetDefaultHostName( ) )
		end )
	end
end
concommand.Add( "np_quadprinterevent", QuadPrinterEvent )

local function MiningEvent( plr, cmd, args, fstring )
	if ( !IsValid( plr ) or plr:IsSuperAdmin( ) ) then
		if ( SVNOOB_VARS:Get( "MiningBoostActive" ) == true ) then
			if ( IsValid( plr ) ) then
				plr:ChatPrint( "A mining event is already active." )
			else
				print( "A mining event is already active." )
			end
			return
		end
		local mes = ""
		if ( IsValid( plr ) ) then
			mes = plr:NiceInfo( ) .. " has begun a Mining Event"
		else
			mes = "Console has started a Mining Event"
		end
		NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
		SVNOOB_VARS:Set( "MiningForemanLimit", 5 )
		SVNOOB_VARS:Set( "MiningBoostActive", true )
		DarkRP.notifyAll( NOTIFY_HINT, 4, "The Mining Foreman limit has been raised to five!" )
		PrintMessage( HUD_PRINTTALK, "(EVENT) A mining event has been activated. Drills are more likely to unearth a rare gem, and players are able to mine slightly faster." )
		RunConsoleCommand( "hostname", GetDefaultHostName( ) .. " | Mining Event" )
		timer.Simple( 3600, function( )
			SVNOOB_VARS:Set( "MiningForemanLimit", 2 )
			SVNOOB_VARS:Set( "MiningBoostActive", false )
			DarkRP.notifyAll( NOTIFY_HINT, 4, "The Mining Foreman limit has been lowered back to two." )
			PrintMessage( HUD_PRINTTALK, "(EVENT) The earth has been raped of its resources. Poison spews all around the drills. The Mining Foreman limit has returned to two." )
			RunConsoleCommand( "hostname", GetDefaultHostName( ) )
			local spawnedDrills = ents.FindByClass( "thumper_drill" )
			if ( table.IsValid( spawnedDrills, true ) ) then
				for index, drill in ipairs ( spawnedDrills ) do
					util.CreatePoisonSmokeCloud( drill:GetPos( ), 300 )
				end
			end
		end )
	end
end
concommand.Add( "np_miningevent", MiningEvent )

local function DoubleDrillEvent( ply, cmd, args, fstring )
	if ( !IsValid( ply ) or ply:IsSuperAdmin( ) ) then
		local drillLimit = SVNOOB_VARS:Get( "ThumperDrillLimit", true, "number", 1 )
		if ( drillLimit >= 2 ) then
			if ( IsValid( ply ) ) then
				ply:ChatPrint( "The Thumper Drill limit is already at two or more." )
			else
				print( "The Thumper Drill limit is already at two or more." )
			end
			return
		end
		local mes = ""
		if ( IsValid( ply ) ) then
			mes = ply:NiceInfo( ) .. " has begun a Double Drill Event"
		else
			mes = "Console has started a Double Drill Event"
		end
		NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
		SVNOOB_VARS:Set( "ThumperDrillLimit", 2 )
		DarkRP.notifyAll( NOTIFY_HINT, 4, "The Thumper Drill limit has been raised to two!" )
		PrintMessage( HUD_PRINTTALK, "(EVENT) The supply of Thumper Drills has skyrocketed, all Mining Foremen may now spawn two Thumper Drills." )
		RunConsoleCommand( "hostname", GetDefaultHostName( ) .. " | Double Drill Event" )
		timer.Simple( 3600, function( )
			SVNOOB_VARS:Set( "ThumperDrillLimit", 1 )
			DarkRP.notifyAll( NOTIFY_ERROR, 4, "The Thumper Drill limit has been lowered back to one." )
			PrintMessage( HUD_PRINTTALK, "(EVENT) The abundant supply of Thumper Drills has been drained, Mining Foremen may only spawn one Thumper Drill again." )
			RunConsoleCommand( "hostname", GetDefaultHostName( ) )
		end )
	end
end
concommand.Add( "np_doubledrillevent", DoubleDrillEvent )

local function PrintingXPBoostEvent( ply, cmd, args, fstring )
	if ( !IsValid( ply ) or ply:IsSuperAdmin( ) ) then
		local boostStatus = SVNOOB_VARS:Get( "PrintingXPBoostActive", true, "boolean", false )
		if ( boostStatus == true ) then
			if ( IsValid( ply ) ) then
				ply:ChatPrint( "There is already a Printing XP Boost Event active." )
			else
				print( "There is already a Printing XP Boost Event active." )
			end
			return
		end
		local mes = ""
		if ( IsValid( ply ) ) then
			mes = ply:NiceInfo( ) .. " has begun a Printing XP Boost Event"
		else
			mes = "Console has started a Printing XP Boost Event"
		end
		NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
		SVNOOB_VARS:Set( "PrintingXPBoostActive", true )
		DarkRP.notifyAll( NOTIFY_HINT, 4, "Printing XP will be boosted for the next hour!" )
		PrintMessage( HUD_PRINTTALK, "(EVENT) Being able to manage printers is currently in demand, experience is boosted for the next hour." )
		RunConsoleCommand( "hostname", GetDefaultHostName( ) .. " | Printing XP Boost" )
		timer.Simple( 3600, function( )
			SVNOOB_VARS:Set( "PrintingXPBoostActive", false )
			DarkRP.notifyAll( NOTIFY_ERROR, 4, "The Printing XP boost has ended." )
			PrintMessage( HUD_PRINTTALK, "(EVENT) The printing craze is over, the experience rate returned to normal." )
			RunConsoleCommand( "hostname", GetDefaultHostName( ) )
		end )
	end
end
concommand.Add( "np_printerxpboost", PrintingXPBoostEvent )

local function CriminalXPBoostEvent( ply, cmd, args, fstring )
	if ( !IsValid( ply ) or ply:IsSuperAdmin( ) ) then
		local boostStatus = SVNOOB_VARS:Get( "CriminalXPBoostActive", true, "boolean", false )
		if ( boostStatus == true ) then
			if ( IsValid( ply ) ) then
				ply:ChatPrint( "There is already a Criminal XP Boost Event active." )
			else
				print( "There is already a Criminal XP Boost Event active." )
			end
			return
		end
		local mes = ""
		if ( IsValid( ply ) ) then
			mes = ply:NiceInfo( ) .. " has begun a Criminal XP Boost Event"
		else
			mes = "Console has started a Criminal XP Boost Event"
		end
		NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
		SVNOOB_VARS:Set( "CriminalXPBoostActive", true )
		DarkRP.notifyAll( NOTIFY_HINT, 4, "Criminal XP will be boosted for the next hour!" )
		PrintMessage( HUD_PRINTTALK, "(EVENT) Crime rates have begun to sharply rise, now is a good time to learn a few things." )
		RunConsoleCommand( "hostname", GetDefaultHostName( ) .. " | Criminal XP Boost" )
		timer.Simple( 3600, function( )
			SVNOOB_VARS:Set( "CriminalXPBoostActive", false )
			DarkRP.notifyAll( NOTIFY_ERROR, 4, "The Criminal XP boost has ended." )
			PrintMessage( HUD_PRINTTALK, "(EVENT) The crime rates have drastically lowered." )
			RunConsoleCommand( "hostname", GetDefaultHostName( ) )
		end )
	end
end
concommand.Add( "np_criminalxpboost", CriminalXPBoostEvent )

local function PoliceXPBoostEvent( ply, cmd, args, fstring )
	if ( !IsValid( ply ) or ply:IsSuperAdmin( ) ) then
		local boostStatus = SVNOOB_VARS:Get( "PoliceXPBoostActive", true, "boolean", false )
		if ( boostStatus == true ) then
			if ( IsValid( ply ) ) then
				ply:ChatPrint( "There is already a Police XP Boost Event active." )
			else
				print( "There is already a Police XP Boost Event active." )
			end
			return
		end
		local mes = ""
		if ( IsValid( ply ) ) then
			mes = ply:NiceInfo( ) .. " has begun a Police XP Boost Event"
		else
			mes = "Console has started a Police XP Boost Event"
		end
		NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, mes, true )
		SVNOOB_VARS:Set( "PoliceXPBoostActive", true )
		DarkRP.notifyAll( NOTIFY_HINT, 4, "Police XP will be boosted for the next hour!" )
		PrintMessage( HUD_PRINTTALK, "(EVENT) The amount of Civil Protection dwindle, they are recruiting, you may want to get some training." )
		RunConsoleCommand( "hostname", GetDefaultHostName( ) .. " | Police XP Boost" )
		timer.Simple( 3600, function( )
			SVNOOB_VARS:Set( "PoliceXPBoostActive", false )
			DarkRP.notifyAll( NOTIFY_ERROR, 4, "The Police XP boost has ended." )
			PrintMessage( HUD_PRINTTALK, "(EVENT) The need for Civil Protection has declined greatly." )
			RunConsoleCommand( "hostname", GetDefaultHostName( ) )
		end )
	end
end
concommand.Add( "np_policexpboost", PoliceXPBoostEvent )
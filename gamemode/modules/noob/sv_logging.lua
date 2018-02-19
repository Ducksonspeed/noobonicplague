local logsDirectory = "noob/logs/"

local warningDirectory = logsDirectory .. "warning/"
local alertDirectory = logsDirectory .. "alert/"
local urgentDirectory = logsDirectory .. "urgent/"
local ScripterDirectory = logsDirectory.."scripter/";

local fileNameFormat = "%a-%b-%d-%y_%I%p"
local timeFormat = "[ %I:%M:%S%p ]"

file.CreateDir( "noob" )
file.CreateDir( logsDirectory )
file.CreateDir( warningDirectory )
file.CreateDir( alertDirectory )
file.CreateDir( urgentDirectory )
file.CreateDir( ScripterDirectory );

NOOB_LOGGING_WARNING = 1
NOOB_LOGGING_ALERT = 2
NOOB_LOGGING_URGENT = 3
NOOB_LOGGING_SCRIPTER = 4;

NOOB_LOGGER = { }

function NOOB_LOGGER:Log( status, message, printConsole )
	local filePath = ""
	local timeStamp = os.date( timeFormat, os.time( ) )
	if ( status == NOOB_LOGGING_WARNING ) then
		filePath = warningDirectory .. os.date( fileNameFormat, os.time( ) ) .. ".txt"
		if ( file.Exists( filePath, "DATA" ) ) then
			file.Append( filePath, timeStamp .. " " .. message .. "\n" )
		else
			file.Write( filePath, timeStamp .. " " .. message .. "\n" )
		end
		if not ( printConsole ) then return end
		print( "[WARNING] " .. timeStamp .. " " .. message )
	elseif ( status == NOOB_LOGGING_ALERT ) then
		filePath = alertDirectory .. os.date( fileNameFormat, os.time( ) ) .. ".txt"
		if ( file.Exists( filePath, "DATA" ) ) then
			file.Append( filePath, timeStamp .. " " .. message .. "\n" )
		else
			file.Write( filePath, timeStamp .. " " .. message .. "\n" )
		end
		if not ( printConsole ) then return end
		print( "[ALERT] " .. timeStamp .. " " .. message )
	elseif ( status == NOOB_LOGGING_URGENT ) then
		filePath = urgentDirectory .. os.date( fileNameFormat, os.time( ) ) .. ".txt"
		if ( file.Exists( filePath, "DATA" ) ) then
			file.Append( filePath, timeStamp .. " " .. message .. "\n" )
		else
			file.Write( filePath, timeStamp .. " " .. message .. "\n" )
		end
		if not ( printConsole ) then return end
		print( "[URGENT] " .. timeStamp .. " " .. message )
	elseif ( status == NOOB_LOGGING_SCRIPTER ) then
		filePath = ScripterDirectory .. os.date( fileNameFormat, os.time( ) ) .. ".txt"
		if ( file.Exists( filePath, "DATA" ) ) then
			file.Append( filePath, timeStamp .. " " .. message .. "\n" )
		else
			file.Write( filePath, timeStamp .. " " .. message .. "\n" )
		end
		if not ( printConsole ) then return end
		print( "[SCRIPTER] " .. timeStamp .. " " .. message )
	end
end

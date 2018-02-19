mySQLControl = { }

local queue = { }
local db = mysqloo.connect( RP_MySQLConfig.Host, RP_MySQLConfig.Username, RP_MySQLConfig.Password, RP_MySQLConfig.Database_name, RP_MySQLConfig.Database_port )

function db:onConnected()
	
	print( "Database has connected!" )
	for index, queuedQuery in pairs ( queue ) do
		print( "Running queued query: [ " .. index .. "] " )
		mySQLControl:Query( queuedQuery[1], queuedQuery[2] )
	end
	queue = { }
	hook.Call( "NOOBRP_MySQL_Connected", { } )
end

function db:onConnectionFailed( err )

	print( "Connection to database failed!" )
	print( "Error:", err )

end

db:connect()

function mySQLControl:Escape( str )
	return db:escape( str )
end

function mySQLControl:IsDatabaseConnected( )
	return ( db:status( ) ~= mysqloo.DATABASE_NOT_CONNECTED )
end

function mySQLControl:Query( query, cback )

	local query = db:query( query )
	local returnVal = nil
	function query:onSuccess( data )
		cback( data )
	end
	
	function query:onError( err, sqlText )
		if ( db:status( ) == mysqloo.DATABASE_NOT_CONNECTED ) then
			print( "Database is not connected, queueing query and reconnecting." )
			table.insert( queue, { sqlText, cback } )
			db:connect( )
			return
		end
		print( err .. " ( " .. sqlText .. " ) " )
	end

	query:start( )
end

function mySQLControl:InsertInto( tbl, valTbl )
	local builtString = " VALUES( "
	for index, val in ipairs ( valTbl ) do
		if ( index ~= #valTbl ) then
			builtString = builtString .. val .. ", "
		else
			builtString = builtString .. val .. ");"
		end
	end
	mySQLControl:Query( "INSERT INTO " .. tbl .. builtString, function( data ) 
	end )
end

function mySQLControl:TableExists( tbl, cback )
	mySQLControl:Query( "SHOW TABLES LIKE '" .. tbl .. "';", function( data ) 
		cback( data )
	end )
end

function mySQLControl:CreateTable( tbl, valTbl )
	mySQLControl:TableExists( tbl, function( data ) 
		if ( #data > 0 ) then
			print( "Table " .. tbl .. " already exists, not attempting to create." )
		else
			local builtString = " ( "
			for index, val in ipairs ( valTbl ) do
				if ( index ~= #valTbl ) then
					builtString = builtString .. val .. ", "
				else
					builtString = builtString .. val .. ");"
				end
			end
			mySQLControl:Query( "CREATE TABLE " .. tbl .. builtString, function( data ) 
			end )	
		end
	end )
end

function mySQLControl:PreciseSelectFrom( tbl, condTbl, cback )
	local builtConditions = ""
	for index, cond in ipairs ( condTbl ) do
		if ( index ~= #condTbl ) then
			builtConditions = builtConditions .. cond .. " AND "
		else
			builtConditions = builtConditions .. cond .. ";"
		end
	end
	mySQLControl:Query( "SELECT * FROM " .. tbl .. " WHERE " .. builtConditions, function( data ) 
		cback( data )
	end )
end

function mySQLControl:GrabRows( tbl, column, searchVal, cback )
	mySQLControl:Query( "SELECT * FROM " .. tbl .. " WHERE " .. column .. " = " .. searchVal .. ";", function( data )
		cback( data )
	end )
end

function mySQLControl:GrabTable( tbl, cback )
	mySQLControl:Query( "SELECT * FROM " .. tbl .. ";", function( data )
		cback( data )
	end )
end

function mySQLControl:ColumnValueExists( tbl, column, searchVal, cback )
	mySQLControl:Query( "SELECT * FROM " .. tbl .. " WHERE " .. column .. " = " .. searchVal .. " LIMIT 1;", function( data )
		cback( data )
	end )
end

function mySQLControl:GetMaxValue( tbl, column, cback )
	mySQLControl:Query( "SELECT MAX(" .. column .. ") FROM " .. tbl .. ";", function( data )
		cback( data or 0 )
	end )
end

function mySQLControl:PreciseDeleteFrom( tbl, condTbl, cback )
	local builtConditions = ""
	for index, cond in ipairs ( condTbl ) do
		if ( index ~= #condTbl ) then
			builtConditions = builtConditions .. cond .. " AND "
		else
			builtConditions = builtConditions .. cond .. ";"
		end
	end
	mySQLControl:Query( "DELETE FROM " .. tbl .. " WHERE " .. builtConditions, function( data )
		cback( data )
	end )
end

function mySQLControl:DeleteFrom( tbl, column, searchVal )
	mySQLControl:Query( "DELETE FROM " .. tbl .. " WHERE " .. column .. " = " .. searchVal .. ";", function( data )
	end )
end

function mySQLControl:UpdateRow( tbl, valTbl, condTbl )
	local builtValues = " SET "
	local builtConditions = ""
	for index, val in ipairs ( valTbl ) do
		if ( index ~= #valTbl ) then
			builtValues = builtValues .. val .. ", "
		else
			builtValues = builtValues .. val
		end
	end
	for index, cond in ipairs ( condTbl ) do
		if ( index ~= #condTbl ) then
			builtConditions = builtConditions .. cond .. " AND "
		else
			builtConditions = builtConditions .. cond .. ";"
		end
	end
	mySQLControl:Query( "UPDATE " .. tbl .. builtValues .. " WHERE " .. builtConditions, function( data ) 
	end )
end

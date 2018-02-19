if ( SERVER ) then

	util.AddNetworkString( "N00BRP_ServerErrors_NET" )
	
	local function OnServerError( isRunTimeError, sourceFile, sourceLine, errorString, stackTable )
		for index, ply in ipairs ( player.GetAll( ) ) do
			if not ( ply:IsAdmin( ) ) then continue end
			net.Start( "N00BRP_ServerErrors_NET" )
				net.WriteTable( { sourceFile = sourceFile, sourceLine = sourceLine, errorString = errorString, errorTime = os.date( "%I:%M") } )
			net.Send( ply )
		end
	end
	hook.Add( "LuaError", "N00BRP_OnServerError_LuaError", OnServerError )
else

	local errorTable = errorTable or { }
	local serverErrorMenu = nil

	local function OnReceiveServerError( len )
		local errorTbl = net.ReadTable( )
		table.insert( errorTable, errorTbl )
	end
	net.Receive( "N00BRP_ServerErrors_NET", OnReceiveServerError )

	local function OpenServerErrorMenu( )
		if not ( LocalPlayer( ):IsAdmin( ) ) then return end
		if ( ValidPanel( serverErrorMenu ) ) then serverErrorMenu:Remove( ) end
		serverErrorMenu = vgui.Create( "DFrame" )
		serverErrorMenu:SetSize( 800, 600 )
		serverErrorMenu:Center( )
		serverErrorMenu:MakePopup( )
		serverErrorMenu:SetTitle( "Server Lua Error Menu" )
		local richText = vgui.Create( "RichText", serverErrorMenu )
		richText:Dock( FILL )
		richText:SetMultiline( true )
		richText.Paint = function( self, w, h )
			self:SetFontInternal( "____s" );
			self:SetFGColor( Color( 255, 255, 255 ) )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 91, 91, 91, 150 ) )
		end
		for index, errorTbl in ipairs( errorTable ) do
			richText:InsertColorChange( 255, 255, 255, 255 )
			richText:AppendText( errorTbl.errorTime .." | File: " )
			richText:InsertColorChange( 52, 152, 219, 255 )
			richText:AppendText( errorTbl.sourceFile )
			richText:InsertColorChange( 255, 255, 255, 255 )
			richText:AppendText( " | Line: " )
			richText:InsertColorChange( 231, 76, 60, 255 )
			richText:AppendText( errorTbl.sourceLine )
			richText:InsertColorChange( 255, 255, 255, 255 )
			richText:AppendText( " | Error: " )
			richText:InsertColorChange( 26, 188, 156, 255 )
			richText:AppendText( errorTbl.errorString );
			richText:AppendText( "\n" );
		end
	end
	concommand.Add( "sv_check", OpenServerErrorMenu )
end
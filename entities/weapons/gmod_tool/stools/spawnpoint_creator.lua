TOOL.Category           = "Jeezy's Tools"
TOOL.Name               = "Spawnpoint Creator"
TOOL.Command            = nil
TOOL.ConfigName         = ""

TOOL.ClientConVar[ "class" ] = ""
TOOL.ClientConVar[ "zoffset" ] = "0"
TOOL.ClientConVar[ "randzoffset" ] = "0"
TOOL.ClientConVar[ "finalrandzoffset"] = "0"
TOOL.ClientConVar[ "filterclass" ] = ""
if ( SERVER ) then
	util.AddNetworkString( "N00B_SpawnPointCreator_ToggleSpawns" )
	util.AddNetworkString( "N00B_SpawnPointCreator_AddSpawn" )
	util.AddNetworkString( "N00B_SpawnPointCreator_RemoveSpawn" )
	local spawnTable = { }
	function TOOL:LeftClick( trace )
		if not ( self:GetOwner( ):IsSuperAdmin( ) ) then return end
		local entityClass = self:GetClientInfo( "class" )
		local zOffset = tonumber( self:GetClientInfo( "zoffset" ) ) or 0
		local randZOffset = tonumber( self:GetClientInfo( "randzoffset" ) or 0 )
		local finalRandZOffset = tonumber( self:GetClientInfo( "finalrandzoffset" ) or 0 )
		if ( randZOffset == 0 ) then
			finalRandZOffset = 0
		end
		local entTable = scripted_ents.Get( entityClass )
		if not ( entTable ) then
			DarkRP.notify( self:GetOwner( ), 1, 4, "That's an invalid scripted entity." )
		end
		local spawnPos = trace.HitPos + Vector( 0, 0, zOffset ) + Vector( 0, 0, finalRandZOffset )
		local traceRes = util.TraceLine( { start = trace.HitPos, endpos = spawnPos + Vector( 0, 0, 16 ), filter = self:GetOwner( ) } )
		if ( traceRes.HitWorld and randZOffset ~= 0 ) then spawnPos = traceRes.HitPos - Vector( 0, 0, 64 ) end
		table.insert( spawnTable, { class = entityClass, pos = spawnPos } )
		DarkRP.notify( self:GetOwner( ), 2, 4, "Created a spawn point for ".. entityClass .. " at " .. tostring( trace.HitPos + Vector( 0, 0, spawnPos ) ) .. "!" )
		net.Start( "N00B_SpawnPointCreator_AddSpawn" )
			net.WriteString( entityClass )
			net.WriteVector( spawnPos )
		net.Send( self:GetOwner( ) )
		if ( randZOffset ~= 0 ) then
			local newRandZOffset = math.random( 0, randZOffset )
			self:GetOwner( ):ConCommand( "spawnpoint_creator_finalrandzoffset " .. newRandZOffset )
		end
		return true
	end

	local function SaveSpawns( plr, cmd, args )
		if not ( plr:IsSuperAdmin( ) ) then return end
		local wep = plr:GetActiveWeapon( )
		if ( IsValid( wep ) and wep:GetClass( ) == "gmod_tool" and wep.Mode == "spawnpoint_creator" ) then
			if ( !istable( spawnTable ) or #spawnTable < 1 ) then return end
			local json = util.TableToJSON( spawnTable )
			file.Write( "noob_entspawns.txt", json )
			DarkRP.notify( plr, 1, 4, "You've saved the spawn points." )
		end
	end
	concommand.Add( "save_spawns", SaveSpawns )

	local function LoadSpawns( plr, cmd, args )
		if not ( plr:IsSuperAdmin( ) ) then return end
		local wep = plr:GetActiveWeapon( )
		if ( IsValid( wep ) and wep:GetClass( ) == "gmod_tool" and wep.Mode == "spawnpoint_creator" ) then
			local fileData = file.Read( "noob_entspawns.txt", "DATA" )
			local tbl = util.JSONToTable( fileData )
			spawnTable = tbl
			DarkRP.notify( plr, 1, 4, "You've loaded the saved spawn points." )
		end
	end
	concommand.Add( "load_spawns", LoadSpawns )

	function TOOL:RightClick( trace )
		if not ( self:GetOwner( ):IsSuperAdmin( ) ) then return end
		for index, tbl in ipairs ( spawnTable ) do
			net.Start( "N00B_SpawnPointCreator_AddSpawn" )
				net.WriteString( tbl.class )
				net.WriteVector( tbl.pos )
				net.WriteUInt( index, 32 )
			net.Send( self:GetOwner( ) )
		end
		net.Start( "N00B_SpawnPointCreator_ToggleSpawns" )
			--net.WriteTable( spawnTable )
		net.Send( self:GetOwner( ) )
	end

	function TOOL:Reload( )
		if not ( self:GetOwner( ):IsSuperAdmin( ) ) then return end
		local zOffset = tonumber( self:GetClientInfo( "zoffset" ) ) or 0
		local randZOffset = tonumber( self:GetClientInfo( "randzoffset" ) or 0 )
		local finalRandZOffset = tonumber( self:GetClientInfo( "finalrandzoffset" ) or 0 )
		if ( randZOffset == 0 ) then finalRandZOffset = 0 end
		local hitPos = self:GetOwner( ):GetEyeTrace( ).HitPos + Vector( 0, 0, zOffset ) + Vector( 0, 0, finalRandZOffset )
		local removedPoint = false
		for index, spawnPoint in pairs ( spawnTable ) do
			if ( spawnPoint.pos:Distance( hitPos ) < 64 ) then
				local filterClass = self:GetClientInfo( "spawnpoint_creator_filterclass" ) or ""
				if ( filterClass ~= "" and string.lower( filterClass ) ~= string.lower( spawnPoint.class ) ) then
					continue
				end
				removedPoint = true
				table.remove( spawnTable, index )
				net.Start( "N00B_SpawnPointCreator_RemoveSpawn" )
					net.WriteString( spawnPoint.class )
					net.WriteVector( spawnPoint.pos )
					net.WriteUInt( index, 32 )
				net.Send( self:GetOwner( ) )
				break
			end
		end
		if ( removedPoint ) then
			DarkRP.notify( self:GetOwner( ), 2, 4, "Successfully removed the closest point. You may need to retoggle your client view to see the change." )
		else
			DarkRP.notify( self:GetOwner( ), 1, 4, "No spawn points were close enough to your cursor to remove." )
		end
	end
end

if CLIENT then
	local spawnPointsVisible = false
	local spawnPointsTable = { }
	local entityColors = { }
	local randColors = { COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_ORANGE, COLOR_YELLOW, COLOR_PURPLE }
	surface.CreateFont( "N00BRP_SpawnPointCreator_SmallText", {
	font = "Tahoma",
	size = 12,
	} )
	surface.CreateFont( "N00BRP_SpawnPointCreator_SmallBoldText", {
	font = "Lobster",
	size = 16,
	weight = 750
	} )
	local function ShowSpawnCreatorSpawns( )
		if not ( IsValid( LocalPlayer( ) ) ) then return end
		if not ( IsValid( LocalPlayer( ):GetActiveWeapon( ) ) ) then return end
		if not ( LocalPlayer( ):GetActiveWeapon( ):GetClass( ) == "gmod_tool" ) then return end
		if not ( LocalPlayer( ):GetActiveWeapon( ).Mode == "spawnpoint_creator" ) then return end
		if ( spawnPointsTable and #spawnPointsTable > 0 ) then
			local filterClass = LocalPlayer( ):GetInfo( "spawnpoint_creator_filterclass", "" )
			local zOffset = tonumber( LocalPlayer( ):GetInfo( "spawnpoint_creator_zoffset", "0" ) ) or 0
			local baseRandZOffset = tonumber( LocalPlayer( ):GetInfo( "spawnpoint_creator_randzoffset", "0" ) ) or 0
			local randZOffset = tonumber( LocalPlayer( ):GetInfo( "spawnpoint_creator_finalrandzoffset", "0" ) ) or 0
			if ( baseRandZOffset == 0 ) then randZOffset = 0 end
			local cursorPos = LocalPlayer( ):GetEyeTrace( ).HitPos + Vector( 0, 0, zOffset ) + Vector( 0, 0, randZOffset )
			for index, spawnPoint in pairs ( spawnPointsTable ) do
				if ( filterClass ~= "" and string.lower( filterClass ) ~= string.lower( spawnPoint.class ) ) then
					continue
				end
				local fontType = "N00BRP_SpawnPointCreator_SmallText"
				if ( cursorPos:Distance( spawnPoint.pos ) < 64 ) then
					fontType = "N00BRP_SpawnPointCreator_SmallBoldText"
				end
				local screenData = spawnPoint.pos:ToScreen( )
				local entColor = Color( 255, 255, 255, 25 )
				if ( entityColors[spawnPoint.class] ) then
					entColor = entityColors[spawnPoint.class]
				end
				draw.SimpleText( spawnPoint.class, fontType, screenData.x, screenData.y, entColor, TEXT_ALIGN_CENTER )
			end
		end
	end

	local function ToggleSpawnPoints( len )
		--local spawnPoints = net.ReadTable( )
		--spawnPointsTable = spawnPoints
		if not ( spawnPointsVisible ) then
			spawnPointsVisible = true
			hook.Add( "HUDPaint", "N00BRP_ShowSpawnCreatorSpawns_HUDPaint", ShowSpawnCreatorSpawns )
		else
			spawnPointsVisible = false
			hook.Remove( "HUDPaint", "N00BRP_ShowSpawnCreatorSpawns_HUDPaint" )
		end
	end
	net.Receive( "N00B_SpawnPointCreator_ToggleSpawns", ToggleSpawnPoints )

	local function AddSpawnPoint( len )
		if not ( spawnPointsVisible ) then return end
		local entClass = net.ReadString( )
		local spawnPos = net.ReadVector( )
		local spawnPosID = net.ReadUInt( 32 )
		table.insert( spawnPointsTable, { class = entClass, pos = spawnPos, id = spawnPosID } )
		if ( !entityColors[ entClass ] and #randColors > 0 ) then
			local colorIndex = math.random( #randColors )
			entityColors[entClass] = randColors[colorIndex]
			table.remove( randColors, colorIndex )
		end
	end
	net.Receive( "N00B_SpawnPointCreator_AddSpawn", AddSpawnPoint )

	local function RemoveSpawnPoint( len )
		if not ( spawnPointsVisible ) then return end
		local entClass = net.ReadString( )
		local spawnPos = net.ReadVector( )
		local spawnPosID = net.ReadUInt( 32 )
		local indexToRemove = nil
		for index, spawn in ipairs ( spawnPointsTable ) do
			if ( spawn.id == spawnPosID ) then
				indexToRemove = index
				break
			end
		end
		if ( indexToRemove ) then
			table.remove( spawnPointsTable, indexToRemove )
		end
	end
	net.Receive( "N00B_SpawnPointCreator_RemoveSpawn", RemoveSpawnPoint )

	local wireFrameMat = Material( "models/wireframe" )
	local function DrawSpawnPos( )
		if not ( IsValid( LocalPlayer( ) ) ) then return end
		if not ( IsValid( LocalPlayer( ):GetActiveWeapon( ) ) ) then return end
		if not ( LocalPlayer( ):GetActiveWeapon( ):GetClass( ) == "gmod_tool" ) then return end
		if not ( LocalPlayer( ):GetActiveWeapon( ).Mode == "spawnpoint_creator" ) then return end
		local zOffset = tonumber( LocalPlayer( ):GetInfo( "spawnpoint_creator_zoffset", "0" ) ) or 0
		local baseRandZOffset = tonumber( LocalPlayer( ):GetInfo( "spawnpoint_creator_randzoffset", "0" ) ) or 0
		local randZOffset = tonumber( LocalPlayer( ):GetInfo( "spawnpoint_creator_finalrandzoffset", "0" ) ) or 0
		if ( baseRandZOffset == 0 ) then randZOffset = 0 end
		local goalPos = LocalPlayer( ):GetEyeTrace( ).HitPos + Vector( 0, 0, zOffset ) + Vector( 0, 0, randZOffset )
		if ( randZOffset ~= 0 ) then goalPos = goalPos + Vector( 0, 0, 16 ) end
		local checkHitTrace = util.TraceLine( { start = LocalPlayer( ):GetEyeTrace( ).HitPos, endpos = goalPos, filter = LocalPlayer( ) } )
		if ( checkHitTrace.HitWorld and randZOffset ~= 0 ) then
			goalPos = checkHitTrace.HitPos - Vector( 0, 0, 64 )
		end
		local lineTrace = util.TraceLine( { start = goalPos, endpos = goalPos - Vector( 0, 0, 16000 ), filter = LocalPlayer( ) } )
		render.SetMaterial( wireFrameMat )
		render.DrawSphere( goalPos, 8, 8, 8, Color( 255, 255, 255, 100 ) )
		render.DrawLine( goalPos, lineTrace.HitPos, Color( 255, 255, 255 ), true )
		render.DrawBox( lineTrace.HitPos, Angle( 0, 0, 0 ), Vector( -32, -32, -2 ), Vector( 32, 32, 2 ), Color( 255, 255, 255 ), true )
	end
	hook.Add( "PostDrawOpaqueRenderables", "N00BRP_SpawnPointCreator_DrawSpawnPos", DrawSpawnPos )

	function TOOL.BuildCPanel( CPanel )
		CPanel:AddControl( "Header", { Description = "#tool.spawnpoint_creator.desc" } )
		CPanel:AddControl( "TextBox", { Label = "#tool.spawnpoint_creator.text", Command = "spawnpoint_creator_class", MaxLenth = "20" } )
		CPanel:AddControl( "TextBox", { Label = "#tool.spawnpoint_creator.filterclass", Command = "spawnpoint_creator_filterclass", MaxLenth = "20" } )
		CPanel:AddControl( "Button", { Text = "#tool.spawnpoint_creator.savespawns", Command = "save_spawns" } )
		CPanel:AddControl( "Button", { Text = "#tool.spawnpoint_creator.loadspawns", Command = "load_spawns" } )
		CPanel:AddControl( "Slider", { Label = "#tool.spawnpoint_creator.zoffset", Command = "spawnpoint_creator_zoffset", Type = "Float", Min = -1000, Max = 1000 } )
		CPanel:AddControl( "Slider", { Label = "#tool.spawnpoint_creator.randzoffset", Command = "spawnpoint_creator_randzoffset", Type = "Float", Min = -1000, Max = 1000 } )
	end
	language.Add( "Tool.spawnpoint_creator.name", "Spawnpoint Creator" )
	language.Add( "Tool.spawnpoint_creator.desc", "Click to create a spawn point for the desired entity." )
	language.Add( "Tool.spawnpoint_creator.0", "Right click to view spawn points." )
	language.Add( "Tool.spawnpoint_creator.text", "Choose An Entity" )
	language.Add( "Tool.spawnpoint_creator.filterclass", "Filter View Class" )
	language.Add( "Tool.spawnpoint_creator.zoffset", "Z-Offset" )
	language.Add( "Tool.spawnpoint_creator.randzoffset", "Random Z-Offset" )
	language.Add( "Tool.spawnpoint_creator.savespawns", "Save Current Spawns" )
	language.Add( "Tool.spawnpoint_creator.loadspawns", "Load Saved Spawns" )
end
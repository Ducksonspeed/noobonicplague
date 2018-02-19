TOOL.Category           = "Jeezy's Tools"
TOOL.Name               = "Info Display"
TOOL.Command            = nil
TOOL.ConfigName         = ""

TOOL.ClientConVar[ "xoffset" ] = "0"
TOOL.ClientConVar[ "yoffset" ] = "0"
TOOL.ClientConVar[ "zoffset" ] = "0"
TOOL.ClientConVar[ "togglesphere" ] = "0"
TOOL.ClientConVar[ "lockpos" ] = "0"
TOOL.ClientConVar[ "copyfield" ] = ""

local function NiceVector( vec, places )
	return "Vector( " .. math.Round( vec[1], places ) .. ", " .. math.Round( vec[2], places ) .. ", " .. math.Round( vec[3], places ) .. " )"
end

local function NiceAngle( ang, places )
	return "Vector( " .. math.Round( ang[1], places ) .. ", " .. math.Round( ang[2], places ) .. ", " .. math.Round( ang[3], places ) .. " )"
end

local function CopyField( copyField, tbl )
	if ( copyField ) then
		local data = nil
		for index, val in pairs ( tbl ) do
			if ( string.lower( index ) == string.lower( copyField ) ) then
				data = { name = index, value = val }
				break
			end
		end
		if ( data ) then
			notification.AddLegacy( "Set Clipboard to " .. data.name .. "!", NOTIFY_HINT, 2 )
			local clipText = ""
			if ( isvector( data.value ) ) then
				clipText = NiceVector( data.value, 3 )
			elseif ( isangle( data.value ) ) then
				clipText = NiceAngle( data.value, 3 )
			elseif ( isnumber( data.value ) ) then
				clipText = math.Round( data.value, 3 )
			else
				clipText = value
			end
			SetClipboardText( tostring( clipText ) )
		end
	end
end

function TOOL:Think( )
	local lockPos = self:GetClientNumber( "lockpos" )
	if ( tobool( lockPos ) and !self:GetOwner( ).displayInfoToolLockedPos ) then
		local xOffset = self:GetClientNumber( "xoffset" )
		local yOffset = self:GetClientNumber( "yoffset" )
		local zOffset = self:GetClientNumber( "zoffset" )
		self:GetOwner( ).displayInfoToolLockedPos = self:GetOwner( ):GetEyeTrace( ).HitPos + Vector( xOffset, yOffset, zOffset )
	elseif ( !tobool( lockPos ) and self:GetOwner( ).displayInfoToolLockedPos ) then
		self:GetOwner( ).displayInfoToolLockedPos = nil
	end
end

if ( SERVER ) then
	util.AddNetworkString( "JZY_InfoDisplay_ReceiveEntityInfoNet" )
	function TOOL:RightClick( trace )
		if not ( SERVER ) then return end
		if not ( IsValid( trace.Entity ) ) then return end
		self.nextClick = self.nextClick or 0
		if ( self.nextClick > CurTime( ) ) then return end
		self.nextClick = CurTime( ) + 1
		net.Start( "JZY_InfoDisplay_ReceiveEntityInfoNet" )
			net.WriteEntity( trace.Entity )
			net.WriteInt( trace.Entity:MapCreationID( ), 32 )
			net.WriteEntity( self )
		net.Send( self:GetOwner( ) )
	end
else
	local wireFrameMat = Material( "models/wireframe" )
	language.Add( "Tool.info_display.name", "Info Display" )
	language.Add( "Tool.info_display.desc", "Trace Options & Tools" )
	language.Add( "Tool.info_display.0", "Left Click for Trace data; Right Click for Entity data; Reload for Player data" )
	language.Add( "Tool.info_display.xoffset", "Select X Offset" )
	language.Add( "Tool.info_display.yoffset", "Select Y Offset" )
	language.Add( "Tool.info_display.zoffset", "Select Z Offset" )
	language.Add( "Tool.info_display.togglesphere", "Render Sphere at Position" )
	language.Add( "Tool.info_display.lockpos", "Lock the Position" )
	language.Add( "Tool.info_display.copyfield", "Clipboard Field" )

	hook.Add( "PostDrawOpaqueRenderables", "JZY_InfoDisplay_PostDrawOpaqueRenderables", function( )
		local wep = LocalPlayer( ):GetActiveWeapon( )
		if ( IsValid( wep ) and wep:GetClass( ) == "gmod_tool" and wep.Mode == "info_display" ) then
			local toggleSphere = LocalPlayer( ):GetInfoNum( "info_display_togglesphere", 0 )
			local xOffset = LocalPlayer( ):GetInfoNum( "info_display_xoffset", 0 )
			local yOffset = LocalPlayer( ):GetInfoNum( "info_display_yoffset", 0 )
			local zOffset = LocalPlayer( ):GetInfoNum( "info_display_zoffset", 0 )
			if ( tobool( toggleSphere ) ) then
				local goalPos = LocalPlayer( ):GetEyeTrace( ).HitPos + Vector( xOffset, yOffset, zOffset ) 
				if ( LocalPlayer( ).displayInfoToolLockedPos ) then
					goalPos = LocalPlayer( ).displayInfoToolLockedPos
				end
				local lineTrace = util.TraceLine( { start = goalPos, endpos = goalPos - Vector( 0, 0, 16000 ), filter = LocalPlayer( ) } )
				render.SetMaterial( wireFrameMat )
				render.DrawSphere( goalPos, 8, 8, 8, Color( 255, 255, 255, 100 ) )
				render.DrawLine( goalPos, lineTrace.HitPos, Color( 255, 255, 255 ), true )
				render.DrawBox( lineTrace.HitPos, Angle( 0, 0, 0 ), Vector( -32, -32, -2 ), Vector( 32, 32, 2 ), Color( 255, 255, 255 ), true )
			end
		end
	end )

	function TOOL.BuildCPanel( CPanel )
		CPanel:AddControl( "Header", { Description = "#tool.info_display.desc" } )
		CPanel:AddControl( "Slider", { Label = "#tool.info_display.xoffset", Command = "info_display_xoffset", Type = "Float", Min = -1000, Max = 1000 } )
		CPanel:AddControl( "Slider", { Label = "#tool.info_display.yoffset", Command = "info_display_yoffset", Type = "Float", Min = -1000, Max = 1000 } )
		CPanel:AddControl( "Slider", { Label = "#tool.info_display.zoffset", Command = "info_display_zoffset", Type = "Float", Min = -1000, Max = 1000 } )
		CPanel:AddControl( "Checkbox", { Label = "#tool.info_display.togglesphere", Command = "info_display_togglesphere" } )
		CPanel:AddControl( "Checkbox", { Label = "#tool.info_display.lockpos", Command = "info_display_lockpos" } )
		CPanel:AddControl( "TextBox", { Label = "#tool.info_display.copyfield", Command = "info_display_copyfield", MaxLenth = "20" } )
	end

	function TOOL:Reload( )
		local copyField = LocalPlayer( ):GetInfo( "info_display_copyfield", "" )
		if ( copyField == "" or string.len( copyField ) == 0 ) then
			copyField = nil
		end
		self.nextClick = self.nextClick or 0
		if ( self.nextClick > CurTime( ) ) then return end
		self.nextClick = CurTime( ) + 1
		local ply = self:GetOwner( )
		local valTable = { }
		valTable["Position"] = NiceVector( ply:GetPos( ), 3 )
		valTable["Angles"] = NiceAngle( ply:GetAngles( ) , 3 )
		valTable["Model"] = ply:GetModel( )
		valTable["ModelScale"] = ply:GetModelScale( )
		valTable["Material"] = ply:GetMaterial( )
		valTable["OBBMins"] = NiceVector( ply:OBBMins( ), 3 )
		valTable["OBBMaxs"] = NiceVector( ply:OBBMaxs( ), 3 )
		valTable["ShootPos"] = NiceVector( ply:GetShootPos( ) )
		valTable["AimVector"] = NiceVector( ply:GetAimVector( ) )
		valTable["MaxHealth"] = ply:GetMaxHealth( )
		valTable["Health"] = ply:Health( )
		valTable["Materials"] = table.ToString( ply:GetMaterials( ) )
		MsgC( Color( 255, 75, 75 ), "*----------------- Player Information -----------------*\n" )
		for index, val in SortedPairs( valTable ) do
			MsgC( Color( 175, 255, 175 ), "[ " .. index .. " ] ", Color( 255, 255, 255 ), " = ", Color( 175, 175, 255 ), val, "\n" )
		end
		CopyField( copyField, valTable )
	end

	function TOOL:LeftClick( trace )
		self.nextClick = self.nextClick or 0
		if ( self.nextClick > CurTime( ) ) then return end
		self.nextClick = CurTime( ) + 1
		local ply = self:GetOwner( )
		local xOffset = self:GetClientNumber( "xoffset" )
		local yOffset = self:GetClientNumber( "yoffset" )
		local zOffset = self:GetClientNumber( "zoffset" )
		local copyField = self:GetClientInfo( "copyfield" )
		if ( copyField == "" or string.len( "copyfield" ) == 0 ) then copyField = nil end
		local traceRes = { }
		if ( xOffset ~= 0 or yOffset ~= 0 or zOffset ~= 0 ) then
			local traceData = { }
			traceData.start = ply:GetShootPos( )
			traceData.endpos = trace.HitPos + Vector( xOffset, yOffset, zOffset )
			if ( ply.displayInfoToolLockedPos ) then
				traceData.endpos = ply.displayInfoToolLockedPos
			end
			traceData.filter = { ply }
			traceRes = util.TraceLine( traceData )
		else
			if ( ply.displayInfoToolLockedPos ) then
				local traceData = { }
				traceData.start = ply:GetShootPos( )
				traceData.endpos = traceData.start + ply:GetAimVector( ) * 16000
				traceData.filter = { ply }
				traceRes = util.TraceLine( traceData )
			else
				traceRes = trace
			end
		end
		MsgC( Color( 255, 75, 75 ), "*----------------- Position Information -----------------*\n" )
		for index, val in SortedPairs( traceRes ) do
			local mes = ""
			if ( isvector( val ) ) then
				mes = NiceVector( val, 3 )
			elseif ( isangle( val ) ) then
				mes = NiceAngle( val, 3 )
			elseif ( tonumber( val ) ) then
				mes = math.Round( val, 3 )
			else
				mes = tostring( val )
			end
			MsgC( Color( 175, 255, 175 ), "[ " .. index .. " ] ", Color( 255, 255, 255 ), " = ", Color( 175, 175, 255 ), mes, "\n" )
		end
		CopyField( copyField, traceRes )
	end

	local function ReceiveEntityInfoNet( len )
		local copyField = LocalPlayer( ):GetInfo( "info_display_copyfield", "" )
		if ( copyField == "" or string.len( copyField ) == 0 ) then
			copyField = nil
		end
		local ent = net.ReadEntity( )
		local mapID = net.ReadInt( 32 ) or "nil"
		local tool = net.ReadEntity( )
		if not ( IsValid( ent ) ) then return end
		local pos = ent:GetPos( )
		local ang = ent:GetAngles( )
		local mins = ent:OBBMins( )
		local maxs = ent:OBBMaxs( )
		local mat = ent:GetMaterial( )
		local allMats = table.ToString( ent:GetMaterials( ) )
		local maxHealth = ent:GetMaxHealth( )
		local health = ent:Health( )
		local valTable = { }
		valTable["Class"] = ent:GetClass( )
		valTable["Model"] = ent:GetModel( )
		valTable["Material"] = mat
		valTable["Position"] = NiceVector( pos, 3 )
		valTable["Angles"] = NiceAngle( ang, 3)
		valTable["OBBMins"] = NiceVector( mins, 3 )
		valTable["OBBMaxs"] = NiceVector( maxs, 3 )
		valTable["MapCreationID"] = mapID
		valTable["MaxHealth"] = maxHealth
		valTable["Health"] = health
		if ( ent:GetClass( ) == "prop_physics" and ent.CPPIGetOwner ) then
			valTable["Owner"] = ent:CPPIGetOwner( )
		elseif ( ent.Getowning_ent ) then
			valTable["Owner"] = ent:Getowning_ent( )
		else
			valTable["Owner"] = nil
		end
		valTable["Materials"] = allMats
		MsgC( Color( 255, 75, 75 ), "*----------------- Entity Information -----------------*\n" )
		for index, val in SortedPairs( valTable ) do
			MsgC( Color( 175, 255, 175 ), "[ " .. index .. " ] ", Color( 255, 255, 255 ), " = ", Color( 175, 175, 255 ), val, "\n" )
		end
		CopyField( copyField, valTable )
	end
	net.Receive( "JZY_InfoDisplay_ReceiveEntityInfoNet", ReceiveEntityInfoNet )
end
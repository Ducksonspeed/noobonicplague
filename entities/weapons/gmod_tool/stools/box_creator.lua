TOOL.Category           = "Jeezy's Tools"
TOOL.Name               = "Box Creator"
TOOL.Command            = nil
TOOL.ConfigName         = ""

TOOL.ClientConVar[ "minsx" ] = "0"
TOOL.ClientConVar[ "minsy" ] = "0"
TOOL.ClientConVar[ "minsz" ] = "0"
TOOL.ClientConVar[ "maxsx" ] = "0"
TOOL.ClientConVar[ "maxsy" ] = "0"
TOOL.ClientConVar[ "maxsz" ] = "0"

local function NiceVector( vec, places )
	return "Vector( " .. math.Round( vec[1], places ) .. ", " .. math.Round( vec[2], places ) .. ", " .. math.Round( vec[3], places ) .. " )"
end

if ( CLIENT ) then
	language.Add( "Tool.box_creator.name", "Box Creator" )
	language.Add( "Tool.box_creator.desc", "Visually helps you create boxes." )
	language.Add( "Tool.box_creator.0", "Left click to set the boxes pose, choose options in menu, and reload to get the data." )
	language.Add( "Tool.box_creator.minsx", "Mins X" )
	language.Add( "Tool.box_creator.minsy", "Mins Y" )
	language.Add( "Tool.box_creator.minsz", "Mins Z" )
	language.Add( "Tool.box_creator.maxsx", "Maxs X" )
	language.Add( "Tool.box_creator.maxsy", "Maxs Y" )
	language.Add( "Tool.box_creator.maxsz", "Maxs Z" )
	language.Add( "Tool.box_creator.resetcoordinates", "Reset Coordinates" )

	local function GetBoxMins( )
		local minsX, minsY, minsZ
		minsX = LocalPlayer( ):GetInfoNum( "box_creator_minsx", 0 )
		minsY = LocalPlayer( ):GetInfoNum( "box_creator_minsy", 0 )
		minsZ = LocalPlayer( ):GetInfoNum( "box_creator_minsz", 0 )
		return Vector( minsX, minsY, minsZ )
	end
	
	local function GetBoxMaxs( )
		local maxsX, maxsY, maxsZ
		maxsX = LocalPlayer( ):GetInfoNum( "box_creator_maxsx", 0 )
		maxsY = LocalPlayer( ):GetInfoNum( "box_creator_maxsy", 0 )
		maxsZ = LocalPlayer( ):GetInfoNum( "box_creator_maxsz", 0 )
		return Vector( maxsX, maxsY, maxsZ )
	end
	
	hook.Add( "PostDrawOpaqueRenderables", "JZY_BoxCreator_PostDrawOpaqueRenderables", function( )
		local wep = LocalPlayer( ):GetActiveWeapon( )
		if ( IsValid( wep ) and wep:GetClass( ) == "gmod_tool" and wep.Mode == "box_creator" ) then
			local mins = GetBoxMins( )
			local maxs = GetBoxMaxs( )
			if ( LocalPlayer( ).boxCreatorToolBoxPos ) then
				render.DrawWireframeBox( LocalPlayer( ).boxCreatorToolBoxPos, Angle( 0, 0, 0 ), mins, maxs, Color( 255, 255, 255 ), false )
			end
		end
	end )

	local function ResetCoordinates( ply, cmd, args, fstring )
		local wep = ply:GetActiveWeapon( )
		if ( IsValid( wep ) and wep:GetClass( ) == "gmod_tool" and wep.Mode == "box_creator" ) then
			ply:ConCommand( "box_creator_minsx 0" )
			ply:ConCommand( "box_creator_minsy 0" )
			ply:ConCommand( "box_creator_minsz 0" )
			ply:ConCommand( "box_creator_maxsx 0" )
			ply:ConCommand( "box_creator_maxsy 0" )
			ply:ConCommand( "box_creator_maxsz 0" )
		end
	end
	concommand.Add( "box_creator_resetcoordinates", ResetCoordinates )

	function TOOL.BuildCPanel( CPanel )
		CPanel:AddControl( "Header", { Description = "#tool.box_creator.desc" } )
		CPanel:AddControl( "Slider", { Label = "#tool.box_creator.minsx", Command = "box_creator_minsx", Type = "Float", Min = -5000, Max = 5000 } )
		CPanel:AddControl( "Slider", { Label = "#tool.box_creator.minsy", Command = "box_creator_minsy", Type = "Float", Min = -5000, Max = 5000 } )
		CPanel:AddControl( "Slider", { Label = "#tool.box_creator.minsz", Command = "box_creator_minsz", Type = "Float", Min = -5000, Max = 5000 } )
		CPanel:AddControl( "Slider", { Label = "#tool.box_creator.maxsx", Command = "box_creator_maxsx", Type = "Float", Min = -5000, Max = 5000 } )
		CPanel:AddControl( "Slider", { Label = "#tool.box_creator.maxsy", Command = "box_creator_maxsy", Type = "Float", Min = -5000, Max = 5000 } )
		CPanel:AddControl( "Slider", { Label = "#tool.box_creator.maxsz", Command = "box_creator_maxsz", Type = "Float", Min = -5000, Max = 5000 } )
		CPanel:AddControl( "Button", { Text = "#tool.box_creator.resetcoordinates", Command = "box_creator_resetcoordinates" } )
	end

	function TOOL:Reload( )
		notification.AddLegacy( "Copied the Mins and Maxs Vectors to your clipboard.", NOTIFY_HINT, 4 )
		local clipText = NiceVector( GetBoxMins( ), 2 ) .. ", " .. NiceVector( GetBoxMaxs( ), 2 )
		SetClipboardText( clipText )
	end
	
	function TOOL:LeftClick( trace )
		self.nextClick = self.nextClick or 0
		if ( self.nextClick > CurTime( ) ) then return end
		self.nextClick = CurTime( ) + 1
		LocalPlayer( ).boxCreatorToolBoxPos = trace.HitPos
		notification.AddLegacy( "You've set the position of the Box!", NOTIFY_HINT, 4 )
	end
end
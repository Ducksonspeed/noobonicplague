ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName		= "Picture Frame"
ENT.Author			= "Jeezy"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Noobonic Plague"
ENT.NextUse = CurTime( )
ENT.DefaultImage = ""
ENT.ScriptDirectory = "http://sv.noobonicplague.com/npcamera/"

function ENT:SetupDataTables( )
	self:NetworkVar( "Entity", 0, "owning_ent" )
	self:NetworkVar( "String", 0, "FileName" )
end

if ( SERVER ) then
	AddCSLuaFile( )
	util.AddNetworkString( "N00BRP_PictureFrame_NET" )
	function ENT:Initialize( )
		self:SetModel( "models/props/de_inferno/picture1.mdl" )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType( SIMPLE_USE )
		local physObj = self:GetPhysicsObject()
		if ( IsValid( physObj ) ) then
			physObj:Wake( )
		end
		self.frameHP = 100
	end

	function ENT:OnTakeDamage( dmgInfo )
		self.frameHP = self.frameHP - dmgInfo:GetDamage( )
		if self.frameHP <= 0 then
			local effectData = EffectData()
			effectData:SetStart( self:GetPos( ) )
			effectData:SetOrigin( self:GetPos( ) )
			effectData:SetScale( 1 )
			util.Effect( "Explosion", effectData )
			self:Remove( )
		end
	end

	function ENT:Use( activator, caller, useType, value )
		self.NextUse = self.NextUse or 0
		if ( self.NextUse < CurTime( ) ) then
			-- Fuck pooling more net messages.
			net.Start( "N00BRP_PictureFrame_NET" )
				net.WriteInt( ENUM_PICFRAME_OPENMENU, 8 )
				net.WriteEntity( self )
				net.WriteEntity( activator )
			net.Send( activator )
			self.NextUse = CurTime( ) + 2
		end
	end
	
	local function PictureFrame_Receive_NET( len, ply )
		local messType = net.ReadInt( 8 )
		if ( messType == ENUM_PICFRAME_SETFILE ) then
			local picEntity = net.ReadEntity( )
			local fileName = net.ReadString( )
			picEntity:SetFileName( fileName )
			timer.Simple( 1, function( )
				if not ( IsValid( picEntity ) ) then return end
				net.Start( "N00BRP_PictureFrame_NET" )
					net.WriteInt( ENUM_PICFRAME_UPDATEIMG, 8 )
					net.WriteEntity( picEntity )
				net.Broadcast( )
			end )
		elseif( messType == ENUM_PICFRAME_DELETE ) then
			local picEntity = net.ReadEntity( )
			local fileName = net.ReadString( )
			local newName = string.Replace( fileName, "pictures/", "" )
			http.Post( picEntity.ScriptDirectory .. "delete_image.php", {
				key = "nubcake024", PlayerID = ply:SteamID64( ), FileName = newName
			}, function( ) DarkRP.notify( ply, 2, 4, "You have removed the picture." ) end, function( ) end )
		end
	end
	net.Receive( "N00BRP_PictureFrame_NET", PictureFrame_Receive_NET )
else
	surface.CreateFont( "N00BRP_PictureFrame_Text", {
		font = "Lobster",
		size = ScreenScale( 7 ),
		weight = 600
	} )
	surface.CreateFont( "N00BRP_PictureFrame_BoldText", {
		font = "Lobster",
		size = ScreenScale( 10 ),
		weight = 750
	} )
	local function PictureFrame_Receive_NET( len )
		local messType = net.ReadInt( 8 )
		if ( messType == ENUM_PICFRAME_UPDATEIMG ) then
			local picEntity = net.ReadEntity( )
			if not ( IsValid( picEntity ) ) then return end
			if ( !picEntity.GetFileName or !picEntity:GetFileName( ) or picEntity:GetFileName( ) == "" ) then return end
			picEntity:GetHTMLData( picEntity:GetFileName( ) )
		elseif ( messType == ENUM_PICFRAME_OPENMENU ) then
			local picEntity = net.ReadEntity( )
			local targetPlayer = net.ReadEntity( )
			picEntity:FetchFiles( targetPlayer )
		end
	end
	net.Receive( "N00BRP_PictureFrame_NET", PictureFrame_Receive_NET )

	function ENT:FetchFiles( ply )
		http.Fetch( self.ScriptDirectory .."/get_images.php?PlayerID=" .. ply:SteamID64( ),
		function( body, len, headers, code )
			local filePanel = vgui.Create( "DFrame" )
			filePanel:SetSize( ScrW( ) * 0.5, ScrH( ) * 0.2 )
			filePanel:Center( )
			filePanel:SetTitle( "" )
			filePanel:ShowCloseButton( false )
			filePanel.Paint = function( pnl, w, h )
				draw.RoundedBox( 4, 0, 0, w, h, Color( 44, 62, 80 ) )
			end
			local fileList = vgui.Create( "DPanelList", filePanel )
			fileList:SetSize( filePanel:GetWide( ) * 0.8, filePanel:GetTall( ) * 0.8 )
			fileList:Center( )
			fileList:AlignTop( filePanel:GetTall( ) * 0.125 )
			fileList:EnableVerticalScrollbar( true )
			local closeButton = vgui.Create( "DN00B_ColoredButton", filePanel )
			closeButton:SetSize( fileList:GetWide( ) * 0.05, fileList:GetTall( ) * 0.15 )
			closeButton:SetText( "X" )
			closeButton:AlignRight( filePanel:GetWide( ) * 0.025 )
			closeButton:AlignTop( filePanel:GetTall( ) * 0.1 )
			closeButton:SetTextFont( "N00BRP_PictureFrame_BoldText" )
			closeButton:SetRoundness( 4 )
			closeButton:SetButtonColor( Color( 52, 152, 219 ) )
			closeButton:SetTextColor( Color( 175, 75, 75 ) )
			closeButton.OnMousePressed = function( btn )
				filePanel:Remove( )
			end
			for index, pic in ipairs( util.JSONToTable( body ) ) do
				local fileRow = vgui.Create( "DPanel", fileList )
				fileRow:SetSize( fileList:GetWide( ), fileList:GetTall( ) * 0.2 )
				fileRow.Paint = function( pnl, w, h )
					local niceTitle = string.Replace( pic, "pictures/" .. LocalPlayer( ):SteamID64( ), "" )
					draw.RoundedBox( 4, 0, 0, w, h, Color( 41, 128, 185 ) )
					draw.SimpleText( niceTitle, "N00BRP_PictureFrame_Text", w * 0.04, h * 0.2, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT )
				end
				fileList:AddItem( fileRow )
				local deleteButton = vgui.Create( "DN00B_ColoredButton", fileRow )
				deleteButton:SetSize( fileList:GetWide( ) * 0.15, fileList:GetTall( ) * 0.15 )
				deleteButton:SetText( "DELETE" )
				deleteButton:AlignRight( fileList:GetWide( ) * 0.05 )
				deleteButton:SetTextFont( "N00BRP_PictureFrame_Text" )
				deleteButton:SetRoundness( 4 )
				deleteButton:SetButtonColor( Color( 52, 152, 219 ) )
				deleteButton:SetTextColor( Color( 255, 255, 255 ) )
				deleteButton.OnMousePressed = function( btn )
					net.Start( "N00BRP_PictureFrame_NET" )
						net.WriteInt( ENUM_PICFRAME_DELETE, 8 )
						net.WriteEntity( self )
						net.WriteString( pic )
					net.SendToServer( )
					filePanel:Remove( )
				end
				local setButton = vgui.Create( "DN00B_ColoredButton", fileRow )
				setButton:SetSize( fileList:GetWide( ) * 0.1, fileList:GetTall( ) * 0.15 )
				setButton:SetText( "SET" )
				setButton:AlignRight( fileList:GetWide( ) * 0.225 )
				setButton:SetTextFont( "N00BRP_PictureFrame_Text" )
				setButton:SetRoundness( 4 )
				setButton:SetButtonColor( Color( 52, 152, 219 ) )
				setButton:SetTextColor( Color( 255, 255, 255 ) )
				setButton.OnMousePressed = function( btn )
					net.Start( "N00BRP_PictureFrame_NET" )
						net.WriteInt( ENUM_PICFRAME_SETFILE, 8 )
						net.WriteEntity( self )
						net.WriteString( pic )
					net.SendToServer( )
					filePanel:Remove( )
				end
			end
		end,
		function( error )
				-- We failed. =( 
			ply:ChatPrint( "Could not pull filelist, maybe you used it too frequently?" )
		end )
	end

	function ENT:GetHTMLData( imgPath )
		if not ( ValidPanel( self.htmlPanel ) ) then return end
		http.Fetch( self.ScriptDirectory .. imgPath,
		function( body, len, headers, code )
			local newBody = string.Replace( body, 'img width="1440" height="810"', 'img width="100" height ="106"' )
			if not ( ValidPanel( self.htmlPanel ) ) then return end
			self.htmlPanel:SetHTML( newBody )
			self.htmlPanel:SetVisible( true )
		end,
		function( error )
			self.htmlPanel:SetVisible( false )
			-- We failed. =( 
		end )
	end
	function ENT:Initialize( )
		self:CheckIfDeactivate( )
	end

	function ENT:ToggleHTMLPanel( bStatus )
		if not ( bStatus ) then
			if not ( ValidPanel( self.htmlPanel ) ) then return end
			self.htmlPanel:Remove( )
		else
			if ( ValidPanel( self.htmlPanel ) ) then return end
			self.htmlPanel = vgui.Create( "DHTML" )
			self.htmlPanel:SetSize( 256, 328 )
			self.htmlPanel:SetPos( -57.5, -60 )
			self.htmlPanel:SetAlpha( 0 )
			self.htmlPanel:SetMouseInputEnabled( false )
			self:GetHTMLData( self:GetFileName( ) )
		end
	end

	function ENT:CheckIfDeactivate( )
		timer.Simple( 15, function( ) 
			if not ( IsValid( self ) ) then return end
			if ( self:GetPos( ):FastDist( LocalPlayer( ):GetPos( ) ) > 64000 ) then
				self:ToggleHTMLPanel( false )
			else
				self:ToggleHTMLPanel( true )
			end
			self:CheckIfDeactivate( )
		end )
	end
	
	function ENT:OnRemove( )
		if ( IsValid( self.htmlPanel ) ) then
			self.htmlPanel:Remove( )
		end
	end

	function ENT:Draw( flags )
		self:DrawModel( )
		if ( !self:GetFileName( ) or self:GetFileName( ) == "" ) then
			if ( IsValid( self.htmlPanel ) ) then
				self.htmlPanel:SetVisible( false )
			end
		end
		if not ValidPanel( self.htmlPanel ) then return end
		local camPos = self:GetPos( )
		local camAng = self:GetAngles( )
		camPos = camPos + ( camAng:Forward( ) * 2 )
		//camPos = camPos + ( camAng:Up( ) * 71 ) + ( camAng:Right( ) * 110.5 ) + ( camAng:Forward( ) * 2 )
		camAng:RotateAroundAxis( camAng:Right( ), 180 )
		camAng:RotateAroundAxis( camAng:Up( ), 90 )
		camAng:RotateAroundAxis( camAng:Forward( ), -90 )
    	cam.Start3D2D( camPos, camAng, 0.25 )
    		self.htmlPanel:SetPaintedManually( false )
    			self.htmlPanel:SetAlpha( 255 )
   		 		self.htmlPanel:PaintManual( )
   		 		self.htmlPanel:SetAlpha( 0 )
   		 	self.htmlPanel:SetPaintedManually( true )
    	cam.End3D2D()
	end
end
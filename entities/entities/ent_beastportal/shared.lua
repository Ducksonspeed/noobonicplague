ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName		= "Beast Portal"
ENT.Author			= "Jeezy"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Noobonic Plague"
ENT.PlayerWhitelist = { }
ENT.PortalPort = nil
ENT.TimeUntilEntry = 30
ENT.PortalCloseTime = 5 -- In minutes
if ( SERVER ) then
	AddCSLuaFile( )

	function ENT:Initialize( )
		player.SendColoredMessage( { COLOR_BLUE, "The ground below you begins to shake violently. A portal to the ", COLOR_RED, "Beast's Lair ", COLOR_BLUE, "has opened somewhere. It will close in ", COLOR_RED, "five minutes", COLOR_BLUE, "." }, player.GetAll( ) )
		//PrintMessage( HUD_PRINTTALK, "The ground below you begins to shake violenty. A portal to the Beast's Lair has opened somewhere. It will close in five minutes." )
		util.ScreenShake( Vector(0,0,0), 1000, math.random( 25, 50 ), 10, 9999999999 )
		self:SetModel( "models/hunter/plates/plate2x4.mdl" )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType( SIMPLE_USE )
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
		local physObj = self:GetPhysicsObject()
		if ( IsValid( physObj ) ) then
			physObj:Wake( )
			physObj:EnableMotion( false )
		end
		self.entryDelay = CurTime( ) + self.TimeUntilEntry
		timer.Simple( self.PortalCloseTime * 60, function( ) 
			player.SendColoredMessage( { COLOR_BLUE, "The portal to the ", COLOR_RED, " Beast's Lair ", COLOR_BLUE, " has closed." }, player.GetAll( ) )
			--PrintMessage( HUD_PRINTTALK, "The portal to the Beast's Lair has closed." )
			SafeRemoveEntity( self )
		end )
	end

	function ENT:SetupPortal( playerList, port )
		for index, ply in ipairs ( playerList ) do
			self.PlayerWhitelist[ply:SteamID( )] = true
			self.PortalPort = port
		end
	end

	function ENT:Use( ent, caller )
		if ( ent:IsPlayer( ) and self.PlayerWhitelist[ent:SteamID( )] ) then
			if not ( self.entryDelay < CurTime( ) ) then
				player.SendColoredMessage( { COLOR_RED, "You must wait another ", COLOR_GREEN, string.NiceTime( self.entryDelay - CurTime( ) ), COLOR_RED, " before entering the portal." }, ent )
			else
				local theIP = game.GetIP( )
				if not ( string.find( caller:IPAddress( ), game.GetIP( ) ) ) then -- prob will never happen again but let's check anyway
					NOOBRP = NOOBRP or { }
					theIP = NOOBRP.ServerIPAddress
				end
				if ( string.len( theIP ) <= 0 ) then
					player.SendColoredMessage( { COLOR_RED, "Error obtaining the server's IP address. ", COLOR_ORANGE, "Please contact a developer." }, ent )
					return
				end
				net.Start("N00BRP_ConnectToBeast")
					net.WriteString( theIP )
					net.WriteString( self.PortalPort )
				net.Send( ent )
			end
		end
	end
else
	local matPortal = Material( "noobonic/beast_portal_main.png", "" )
	local matSidePortal = Material( "noobonic/beast_portal_side.png", "" )
	local sideRot = 0
	local mainRot = 0
	local innerRot = 180
	function ENT:Draw( flags )
		//self:DrawModel( )
		local camPos = self:GetPos( )
		local camAng = self:GetAngles( )
		camAng.y = LocalPlayer( ):GetAngles( ).y
		camPos = camPos + ( camAng:Up( ) * -5 ) + ( camAng:Forward( ) * -35 )
		camAng:RotateAroundAxis( camAng:Right( ), 0 )
		camAng:RotateAroundAxis( camAng:Up( ), 270 )
		innerRot = innerRot + 1.5
		sideRot = sideRot + 1.5
		mainRot = mainRot + 0.8
		if ( innerRot >= 360 ) then innerRot = 0 end
		if ( sideRot >= 360 ) then sideRot = 0 end
		if ( mainRot >= 360 ) then mainRot = 0 end
		local rotWave = math.abs( math.sin( CurTime( ) * 0.5 ) * 360 )
		local x, y = math.PointOnCircle( sideRot, 300, 0, 0 )
		local x2, y2 = math.PointOnCircle( innerRot, 300, 0, 0 )
		local sizeWave = math.abs( math.sin( CurTime( ) * 1 ) * 200 ) + 256
		local cShade = math.abs( math.sin( CurTime( ) * 1 ) * 200 ) + 50
		cam.Start3D2D( camPos, camAng, 0.3 )
			surface.SetDrawColor( Color( cShade, 175, 255, 255 ) )
			surface.SetMaterial( matPortal )
			surface.DrawTexturedRectRotated( 0, 0, sizeWave, sizeWave, mainRot )
			surface.SetDrawColor( util.RainbowStrobe( 15 ) )
			surface.SetMaterial( matSidePortal )
			surface.DrawTexturedRectRotated( x, y, sizeWave * 0.25, sizeWave * 0.25, mainRot )
			surface.DrawTexturedRectRotated( x2, y2, sizeWave * 0.25, sizeWave * 0.25, mainRot )
			surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
		cam.End3D2D( )
	end
end
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName		= "Message of the Day Board"
ENT.Author			= "Jeezy"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Noobonic Plague"

if ( SERVER ) then
	AddCSLuaFile( )
	function ENT:Initialize( )
		self:SetModel( "models/hunter/plates/plate2x4.mdl" )
		self:SetMaterial( "models/props_combine/com_shield001a" )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local physObj = self:GetPhysicsObject()
		if ( IsValid( physObj ) ) then
			physObj:Wake( )
			physObj:EnableMotion( false )
		end
	end
else
	surface.CreateFont( "N00BRP_MOTDHeader", { font = "Tahoma", size = 70, weight = 750, antialiasing = true, blursize = 0 } )
	surface.CreateFont( "N00BRP_MOTDText", { font = "Hobo Std", size = 48, weight = 600, antialiasing = true, blursize = 0 } )
	function ENT:Draw( flags )
		self:DrawModel( )
		local camPos = self:GetPos( )
		local camAng = self:GetAngles( )
		camPos = camPos + ( camAng:Up( ) * -5 ) + ( camAng:Forward( ) * -35 )
		camAng:RotateAroundAxis( camAng:Right( ), 180 )
		camAng:RotateAroundAxis( camAng:Up( ), 270 )
		local motdTable = string.Explode( "^", SHNOOB_VARS:Get( "MOTD" ) )
		local rShade = math.abs( math.sin( CurTime( ) * 2 ) * 100 ) + 150
		local gShade = math.abs( math.sin( CurTime( ) * 3 ) * 100 ) + 150
		local bShade = math.abs( math.sin( CurTime( ) * 4 ) * 100 ) + 150
		cam.Start3D2D( camPos, camAng, 0.3 )
			draw.SimpleText( "Message of the Day", "N00BRP_MOTDHeader", 0, -10, Color( rShade, gShade, bShade, 255 ), TEXT_ALIGN_CENTER )
			draw.RoundedBox( 2, -280, 76, 560, 160, Color( 45, 45, 128, 100 ) )
			for index, line in ipairs ( motdTable ) do
				draw.SimpleText( line, "N00BRP_MOTDText", 0, 48 + ( 32 * index ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
			end
		cam.End3D2D( )
	end
end
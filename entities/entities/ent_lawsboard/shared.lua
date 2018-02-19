ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName		= "Mayor Laws Board"
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
		self:SetModel( "models/hunter/plates/plate3x5.mdl" )
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
	surface.CreateFont( "N00BRP_LawsHeader", { font = "Tahoma", size = 70, weight = 750, antialiasing = true, blursize = 0 } )
	surface.CreateFont( "N00BRP_LawsText", { font = "Lobster", size = 24, weight = 750, antialiasing = true, blursize = 0 } )
	function ENT:Draw( flags )
		self:DrawModel( )
		local camPos = self:GetPos( )
		local camAng = self:GetAngles( )
		camPos = camPos + ( camAng:Up( ) * -5 ) + ( camAng:Right( ) * 100 )
		camAng:RotateAroundAxis( camAng:Right( ), 180 )
		camAng:RotateAroundAxis( camAng:Up( ), 180 )
		local lawTable = SHNOOB_VARS:Get( "MayorLaws" )
		if ( type( lawTable ) ~= "table" ) then lawTable = { "Laws Not Loaded" } end
		local rShade = math.abs( math.sin( CurTime( ) * 2 ) * 100 ) + 150
		local gShade = math.abs( math.sin( CurTime( ) * 3 ) * 100 ) + 150
		local bShade = math.abs( math.sin( CurTime( ) * 4 ) * 100 ) + 150
		cam.Start3D2D( camPos, camAng, 0.3 )
			draw.SimpleText( "Evocity Laws", "N00BRP_LawsHeader", 0, -10, Color( rShade, gShade, bShade, 255 ), TEXT_ALIGN_CENTER )
			draw.RoundedBox( 2, -225, 100, 450, 600, Color( 52, 73, 94, 200 ) )
			for index, law in ipairs ( lawTable ) do
				draw.SimpleText( law, "N00BRP_LawsText", -200, 64 + ( 64 * index ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
			end
		cam.End3D2D( )
	end
end
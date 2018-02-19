ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName		= "Home Point"
ENT.Author			= "Jeezy"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Noobonic Plague"

function ENT:SetupDataTables( )
	self:NetworkVar( "String", 0, "PointName" );
end

if ( SERVER ) then
	AddCSLuaFile( )
	function ENT:Initialize( )
		self:SetModel( "models/hunter/plates/plate1x2.mdl" )
		self:SetMaterial( "models/props_combine/com_shield001a" )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local physObj = self:GetPhysicsObject()
		if ( IsValid( physObj ) ) then
			physObj:Wake( )
		end
		self:SetPointName( "Sample Name" )
	end
else
	surface.CreateFont( "N00BRP_HomePointText", { font = "Tahoma", size = 64, weight = 800, antialiasing = true, blursize = 0 } )
	surface.CreateFont( "N00BRP_HomePointNameText", { font = "Comic Sans MS", size = 48, weight = 800, antialiasing = true, blursize = 0 } )
	surface.CreateFont( "N00BRP_HomePointSmallText", { font = "Tahoma", size = 48, weight = 800, antialiasing = true, blursize = 0 } )
	function ENT:Draw( flags )
		self:DrawModel( )
		local camPos = self:GetPos( )
		local camAng = self:GetAngles( )
		camPos = camPos + ( camAng:Up( ) * -1.6 ) + ( camAng:Forward( ) * -35 )
		camAng:RotateAroundAxis( camAng:Right( ), 180 )
		camAng:RotateAroundAxis( camAng:Up( ), 270 )
		local IntersectRayWithPlane = util.IntersectRayWithPlane
		local pInter = IntersectRayWithPlane( EyePos( ), EyeAngles( ):Forward( ), camPos, camAng:Up( ) )
		if ( pInter ) then
			pInter = WorldToLocal( pInter, EyeAngles( ), camPos, camAng )
			pInter:Mul( 5.05 )
		end
		local hitNormal = LocalPlayer( ):GetEyeTrace( ).HitNormal
		local camUp = camAng:Up( )
		local camNormal = Angle( math.Round( camUp[1], 3 ), math.Round( camUp[2], 3 ), math.Round( camUp[3], 3 ) )
		local plyNormal = Angle( math.Round( hitNormal[1], 3 ), math.Round( hitNormal[2], 3 ), math.Round( hitNormal[3], 3 ) )
		cam.Start3D2D( camPos, camAng, 0.2 )
			local buttonColor = Color( 100, 45, 45, 150 )
			if ( pInter and ( pInter.x > -100 and pInter.x < 100 and pInter.y < -190 and pInter.y > -270 ) and camNormal == plyNormal and LocalPlayer( ):GetPos( ):FastDist( self:GetPos( ) ) < 450 ) then
				buttonColor = Color( 45, 100, 45, 150 )
			end
			draw.SimpleText( "Home Point", "N00BRP_HomePointText", 0, 64, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
			draw.SimpleText( self:GetPointName( ),"N00BRP_HomePointNameText", 0, 126, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
			draw.RoundedBox( 2, -225, 64, 450, 220, Color( 100, 100, 155, 100 ) )

			draw.RoundedBox( 16, -100, 190, 200, 80, buttonColor )
			draw.SimpleText( "SET", "N00BRP_HomePointSmallText", 0, 205, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
		cam.End3D2D( )
	end
end
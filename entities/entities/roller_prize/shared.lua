ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Rollermine Prize"
ENT.Author = "Jeezy"
ENT.Spawnable = false
ENT.ModelTable = { "models/roller.mdl", "models/roller_spikes.mdl" }
ENT.ColorTable = { Color( 45, 45, 255 ), Color( 45, 255, 45 ), Color( 255, 45, 45 ) }

if ( SERVER ) then
	AddCSLuaFile( )
	function ENT:Initialize( )
		self:SetModel( self.ModelTable[ math.random( #self.ModelTable ) ] )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( self.ColorTable[ math.random( #self.ColorTable ) ] )
		local physObj = self:GetPhysicsObject( )
		if physObj:IsValid( ) then
			physObj:Wake( )
		end
	end

	function ENT:SetWorth( amt )
		self.prizeAmount = amt
	end

	function ENT:GetWorth( amt )
		return self.prizeAmount or 0
	end
	
	function ENT:GetNearestPlayer( )
		local entTable = ents.FindInBox( ClampWorldVector( self:GetPos( ) - Vector( 128, 128, 128 ) ), ClampWorldVector( self:GetPos( ) + Vector( 128, 128, 128 ) ) )
		if ( table.IsValid( entTable, true ) ) then
			local plyTable = { }
			for index, ent in ipairs ( entTable ) do
				if ( IsValid( ent ) and ent:IsPlayer( ) and !ent:IsGhost( ) and ent:GetObserverMode( ) == OBS_MODE_NONE ) then
					table.insert( plyTable, { ply = ent, dist = self:GetPos( ):DistToSqr( ent:GetPos( ) ) } )
				end
			end
			if ( table.IsValid( plyTable, true ) ) then
				table.SortByMember( plyTable, "dist", true )
				return plyTable[1].ply
			else
				return nil
			end
		else
			return nil
		end
	end

else
	function ENT:Draw( )
		self:DrawModel( )
	end
end
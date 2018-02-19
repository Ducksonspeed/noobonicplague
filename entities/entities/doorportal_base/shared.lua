AddCSLuaFile( )
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Door Portal"
ENT.Author = "Jeezy"
ENT.Spawnable = false
ENT.FallbackSound = "physics/plastic/plastic_barrel_impact_hard3.wav"
ENT.FallbackModel = "models/props/cs_italy/it_doora.mdl"
ENT.WhitelistedEnts = {
	["basic_money_printer"] = true,
	["adv_money_printer"] = true,
	["plague_canister"] = true,
	["quest_item"] = true,
	["roller_prize"] = true,
	["present"] = true
}
if ( SERVER ) then
	function ENT:Initialize( )
		self:SetModel( self.Model or self.FallbackModel )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetTrigger( true )
		util.PrecacheSound( self.TouchSound or self.FallbackSound )
		local physObj = self:GetPhysicsObject( )
		if ( physObj:IsValid( ) ) then
			physObj:Wake( )
			physObj:EnableMotion( false )
		end
	end

	function ENT:StartTouch( ent )
		if ( ent:IsPlayer( ) or self.WhitelistedEnts[ ent:GetClass( ) ] ) then
			local exitPoint = self.ExitPoint or self:GetPos( )
			ent:SetPos( exitPoint )
			ent:EmitSound( self.TouchSound, 75, math.random( 75, 125 ) )
		end
	end
end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local PotionFunctions = NOOBRP.PotionFunctions

local PotionCategories = NOOBRP.PotionCategories

ENT.DefaultPotionCooldown = 30

function ENT:Initialize()
	self:SetModel( "models/props/jeezy/potions/potion01.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetSkin( math.random( 0, 2 ) )
	self:SetModelScale( 0.5, 0 )
	local phys = self:GetPhysicsObject()
	phys:Wake()
	self.PotionType = nil
end

function ENT:CheckPotionCooldown( caller )
	caller.PotionCooldowns = caller.PotionCooldowns or { }
	local typeEnum = PotionCategories[ self.PotionType ]
	if ( caller.PotionCooldowns[ typeEnum ] and caller.PotionCooldowns[ typeEnum ] > CurTime( ) ) then
		local remainTime = string.NiceTime( caller.PotionCooldowns[ typeEnum ] - CurTime( ) )
		DarkRP.notify( caller, 1, 4, "You must wait another " .. remainTime .. " before consuming another potion of that type." )
		return true
	else
		caller.PotionCooldowns[ typeEnum ] = caller.PotionCooldowns[ typeEnum ] or 0
		caller.PotionCooldowns[ typeEnum ] = CurTime( ) + self.DefaultPotionCooldown
		return false
	end
end

function ENT:Use( activator, caller )
	if not ( self.PotionType ) then
		self.PotionType = self:GetPotionName( )
	end
	self.nextPotionUse = self.nextPotionUse or CurTime( )
	if ( self.nextPotionUse > CurTime( ) ) then return end
	self.nextPotionUse = CurTime( ) + 1
	if not ( self.PotionType ) then self:Remove( ) return end
	if not ( PotionFunctions[ self.PotionType ] ) then self:Remove( ) return end
	if ( self:CheckPotionCooldown( caller ) ) then return end
	PotionFunctions[ self.PotionType ]( activator, self )
	SafeRemoveEntity( self )
end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.RandomColors = { Color( 192, 57, 43 ), Color( 38, 166, 91 ), Color( 65, 131, 215 ) }

function ENT:Initialize()
	self:SetModel( "models/surelyiscool/present.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	phys:Wake( )
	self:SetGiftPlayer( player.GetAll( )[ math.random( #player.GetAll( ) ) ] )
	local notAFKTable = { }
	for index, ply in ipairs ( player.GetAll( ) ) do
		if ( !ply.isMarkedAFK ) then
			table.insert( notAFKTable, ply )
		end
	end
	if ( istable( notAFKTable ) and #notAFKTable > 0 ) then
		self:SetGiftPlayer( notAFKTable[ math.random( #notAFKTable ) ] )
	end
	self:SetColor( self.RandomColors[ math.random( #self.RandomColors ) ] )
end

function ENT:Use( activator, caller )
	if not ( IsValid( self:GetGiftPlayer( ) ) ) then
		SafeRemoveEntity( self )
		return
	end
	if ( activator == self:GetGiftPlayer( ) ) then
		local holdingPly = self.gravHoldingPlayer
		if ( holdingPly == activator ) then return end
		if not ( activator:HasWeaponStored( "antlers" ) ) then
			if not ( IsValid( holdingPly )  ) then
				PrintMessage( HUD_PRINTTALK, activator:Name( ) .. " has opened their present and were rewarded Antlers! Merry Christmas!" )
				activator:GivePermWeapon( "antlers" )
			else
				if ( holdingPly:HasWeaponStored( "antlers" ) ) then
					activator:GivePermWeapon( "antlers" )
					holdingPly:addMoney( 10000 )
					PrintMessage( HUD_PRINTTALK, holdingPly:Name( ) .. " has delivered " .. activator:Name( ) .. "'s' present, " .. activator:Name( ) .. " received Antlers, " .. holdingPly:Name( ) .. " received $10,000! Merry Christmas!" )
				else
					activator:GivePermWeapon( "antlers" )
					holdingPly:GivePermWeapon( "antlers" )
					PrintMessage( HUD_PRINTTALK, holdingPly:Name( ) .. " has delivered " .. activator:Name( ) .. "'s' present, they were both rewarded Antlers! Merry Christmas!" )
				end
			end
		else
			if not ( IsValid( holdingPly ) ) then
				PrintMessage( HUD_PRINTTALK, activator:Name( ) .. " has opened their present and were rewarded $10,000! Merry Christmas!" )
				activator:addMoney( 10000 )
			else
				if ( holdingPly:HasWeaponStored( "antlers" ) ) then
					activator:addMoney( 10000 )
					holdingPly:addMoney( 10000 )
					PrintMessage( HUD_PRINTTALK, holdingPly:Name( ) .. " has delivered " .. activator:Name( ) .. "'s' present, they both received $10,000! Merry Christmas!" )
				else
					activator:addMoney( 10000 )
					holdingPly:GivePermWeapon( "antlers" )
					PrintMessage( HUD_PRINTTALK, holdingPly:Name( ) .. " has delivered " .. activator:Name( ) .. "'s' present, " .. holdingPly:Name( ) .. " received Antlers, " .. activator:Name( ) .. " received $10,000! Merry Christmas!" )
				end
			end
		end 
		SafeRemoveEntity( self )
	end
end
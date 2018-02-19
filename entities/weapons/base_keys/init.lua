AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

local plyMeta = FindMetaTable( "Player" )

function SWEP:Deploy()
	self.Owner:DrawViewModel( false )
	self.Owner:DrawWorldModel( false )
end


function SWEP:SpawnCar( )
	if ( game.GetMap( ) == "lair_of_the_Beast8" ) then
		self.Owner:ErrorNotify( "You cannot use your vehicles here!" )
		return
	end
	if not self.SpecifiedVehicle then return false end -- if the base itself is used

	if self.Owner:isArrested( ) then return false end

	if ( self.Owner:ReachedVehicleLimit( ) ) then
		return
	end

	local spawnPos, spawnAng = self.Owner:GetVehicleSpawnPos( )

	if not spawnPos or not spawnAng then return false end
	
	local vehicleData = util.FindVehicleData( self.SpecifiedVehicle )
	if not ( vehicleData ) then return end
	if self.Owner:HasPermaVehicleSpawned( vehicleData.Class, vehicleData.Model ) then -- check if that perma car already exists
		DarkRP.notify( self.Owner, 1, 4, "Your " .. self.SpecifiedVehicle .. " is already spawned." )
		return
	end
	local carStatus, goalTime = self.Owner:IsVehicleOnCooldown( self.SpecifiedVehicle )
	if ( carStatus ) then
		goalTime = string.NiceTime( tonumber( goalTime ) - CurTime( ) )
		DarkRP.notify( self.Owner, 1, 4, "You cannot spawn a " .. self.SpecifiedVehicle .. " for another " .. goalTime .. "!" )
		return
	end
	self.Owner:SetVehicleCooldown( self.SpecifiedVehicle, 600 )

	local spawnedVehicle = noob_VehicleIndex:SpawnVehicle( self.SpecifiedVehicle, spawnPos, spawnAng )
	spawnedVehicle:keysOwn( self.Owner )
	spawnedVehicle:keysLock( )
	spawnedVehicle.isPermaVehicle = self.Owner
	self.Owner:SetVehicleCount( self.Owner:GetVehicleCount( ) + 1 )
end

function plyMeta:GetVehicleSpawnPos( )
	local trace = { }
	trace.start = self:EyePos( )
	trace.endpos = trace.start + self:GetAimVector() * 85
	trace.filter = self
	local tr = util.TraceLine(trace)

	local trace = { }
	trace.start = tr.HitPos
	trace.endpos = tr.HitPos + Vector(0, 0, 1)
	trace.filter = self
	trace.mins = Vector(-150, -150, 0)
	trace.maxs = Vector(150, 150, 100)
	local tr2 = util.TraceHull( trace )
	if tr2.Hit then
		DarkRP.notify( self, 1, 4, "No room for your car here.")
		--ply.Vehicles = ply.Vehicles - 1
		return false
	end

	local Angles = self:GetAngles()
	Angles.p = 0
	Angles.y = Angles.y + 180
	Angles.r = 0

	return tr.HitPos, Angles
end
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName		= "Valet Button"
ENT.Author			= "Jeezy"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

if not ( SERVER ) then return end
AddCSLuaFile( )

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	self:SetModel( "models/xqm/button3.mdl" )
	self.currentSearching = false
end

function ENT:Use( ply, caller )
	if not ( ply:IsPlayer( ) ) then return end
	local entIndex = self:EntIndex( )
	if not ( self.currentlySearching ) then
		local allVehicles = noob_VehicleIndex:GetTrackedVehicles( )
		if ( allVehicles and istable( allVehicles ) and #allVehicles > 0 ) then
			self.currentlySearching = true
			self.currentSeeker = ply
			ply:PrintMessage( HUD_PRINTCENTER, "The Valet is now searching for your vehicle." )
			local searchTime = tonumber( SVNOOB_VARS:Get( "ValetSearchTime" ) ) or 30
			timer.Create( self:EntIndex( ) .. ":ValetSearchDelay", searchTime, 1, function( )
				if ( !IsValid( self ) or !IsValid( ply ) ) then return end
				self.currentlySearching = false
				self.currentSeeker = nil
				local foundVehicle = false
				for index, vehicle in ipairs ( allVehicles ) do
					if not ( IsValid( vehicle ) ) then continue end
					if ( vehicle:getDoorOwner( ) == ply ) then
						foundVehicle = vehicle
						break
					end
				end
				if ( foundVehicle ) then
					foundVehicle.playerLastUsed = foundVehicle.playerLastUsed or CurTime( )
					if ( foundVehicle.playerLastUsed > ( CurTime( ) - 300 ) ) then
						ply:PrintMessage( HUD_PRINTCENTER, "Your vehicle cannot be returned.\nIt has recently been used." )
						return
					elseif ( IsValid( foundVehicle:GetDriver( ) ) ) then
						local vehDriver = foundVehicle:GetDriver( )
						if ( vehDriver:getDarkRPVar( "wanted" ) ) then
							PrintMessage( HUD_PRINTCENTER, vehDriver:Name( ) .. " the fugitive has stolen " .. ply:Name( ) .. "'s vehicle!" )
						else
							vehDriver:SetWanted( 300, "was wanted for stealing " .. ply:Name( ) .. "'s vehicle!" )
						end
						return
					elseif ( !self:IsSpaceFree( foundVehicle ) ) then
						ply:PrintMessage( HUD_PRINTCENTER, "You're vehicle wasn't brought because the space was occupied." )
						return
					end
					self:BringVehicle( foundVehicle )
				else
					ply:PrintMessage( HUD_PRINTTALK, "No vehicle owned by you could be found." )
				end
			end )
		else
			ply:PrintMessage( HUD_PRINTCENTER, "There are no vehicles spawned." )
		end
	else
		if ( self.currentSeeker == ply ) then
			ply:PrintMessage( HUD_PRINTCENTER, "You canceled your Valet request." )
			self.currentlySearching = false
			self.currentSeeker = nil
			timer.Destroy( self:EntIndex( ) .. ":ValetSearchDelay" )
		else
			ply:PrintMessage( HUD_PRINTCENTER, "The Valet is currently being used." )
		end
	end
end

function ENT:BringVehicle( veh )
	local currentHealth = veh:GetEntityHealth( )
	local currentGas = veh.gasRemaining
	local currentColor = veh:GetColor( )
	local currentSkin = veh:GetSkin( )
	local vehName = veh.vehicleName
	local vehOwner = veh:getDoorOwner( )
	if ( IsValid( veh ) ) then veh:Destroy( ) end
	local spawnPos = self:GetPos( ) + ( self:GetUp( ) * 200 )
	local spawnAng = self:GetUp( ):Angle( )
	local spawnedVehicle = noob_VehicleIndex:SpawnVehicle( vehName, spawnPos, spawnAng )
	if not ( spawnedVehicle ) then 
		return -- Not sure why it'd reach this point?
	end
	spawnedVehicle:SetEntityHealth( currentHealth )
	spawnedVehicle.gasRemaining = currentGas
	spawnedVehicle:SetRenderMode( RENDERMODE_TRANSCOLOR )
	spawnedVehicle:SetColor( currentColor )
	spawnedVehicle:SetSkin( currentSkin )
	spawnedVehicle:keysOwn( vehOwner )
	spawnedVehicle:keysLock( )
end

function ENT:IsSpaceFree( veh )
	local traceData = { }
	if ( !veh or !IsValid( veh ) ) then
		traceData.mins = Vector( -256, -256, -256 )
		traceData.maxs = Vector( 256, 256, 256 )
	else
		traceData.mins = veh:OBBMins( )
		traceData.maxs = veh:OBBMaxs( )
	end
	traceData.start = self:GetPos( ) + ( self:GetUp( ) * 200 )
	traceData.endpos = traceData.start
	local traceRes = util.TraceHull( traceData )
	return !traceRes.Hit
end
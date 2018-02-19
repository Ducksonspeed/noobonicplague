ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Gas Tank"
ENT.Author = "Jeezy"
ENT.Spawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "owning_ent")
end

if ( SERVER ) then
	AddCSLuaFile( )
	local vehMeta = FindMetaTable( "Vehicle" )

	function vehMeta:IsGasDraining( )
		return ( timer.Exists( self:EntIndex( ) .. ":GasDraining" ) )
	end
	
	function vehMeta:SendCurrentGas( ply, maxGas )
		net.Start( "N00BRP_SendVehicleGas" )
			net.WriteEntity( self )
			net.WriteUInt( self.gasRemaining, 16 )
			net.WriteUInt( maxGas, 16 )
		net.Send( ply )
	end

	function vehMeta:CeaseGasDrain( )
		if ( timer.Exists( self:EntIndex( ) .. ":GasDraining" ) ) then
			timer.Destroy( self:EntIndex( ) .. ":GasDraining" )
		end
	end
	
	function vehMeta:InitiateGasDrain( )
		local vehIndex = self:EntIndex( )
		local maxGas = noob_VehicleIndex:Get( self:GetModel( ) ).maxGas
		if not ( self.gasRemaining ) then
			self.gasRemaining = maxGas
		end
		if ( self.gasRemaining <= 0 ) then return end
		timer.Create( vehIndex .. ":GasDraining", SVNOOB_VARS:Get( "VehicleGasDrainRate", true, "number", 4 ), 0, function( )
			if not ( IsValid( self ) ) then
				timer.Destroy( vehIndex .. ":GasDraining" )
				return
			end
			self.gasRemaining = self.gasRemaining - 1
			if ( self.gasRemaining == 0 ) then
				self:Fire( "TurnOff", "", 0 )
				timer.Destroy( vehIndex .. ":GasDraining" )
			end
			if ( IsValid( self:GetDriver( ) ) ) then
				self:SendCurrentGas( self:GetDriver( ), maxGas )
			end
		end )
	end
	
	function ENT:Initialize( )
		self:SetModel( "models/props_junk/gascan001a.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		local phys = self:GetPhysicsObject( )
		phys:Wake( )
		self.entHealth = 100
	end

	function ENT:FindNearbyEntities( range )
		local vectorRange = Vector( range, range, range )
		local boxMins = self:ClampWorldVector( self:GetPos( ) - vectorRange )
		local boxMaxs = self:ClampWorldVector( self:GetPos( ) + vectorRange )
		local nearbyEnts = ents.FindInBox( boxMins, boxMaxs )
		return nearbyEnts
	end
	
	function ENT:OnTakeDamage( dmgInfo )
		self.entHealth = self.entHealth - dmgInfo:GetDamage( )
		if ( self.entHealth < 0 ) then
			local nearbyEnts = self:FindNearbyEntities( 512 )
			if ( nearbyEnts and istable( nearbyEnts ) ) then
				for index, ent in ipairs ( nearbyEnts ) do
					if ( ent:GetClass( ) == "prop_physics" ) then
						if ( ent:IsPlayer( ) and ent:IsGhost( ) ) then continue end
						ent:Ignite( 15 )
						timer.Simple( 16, function( )
							if not ( IsValid( ent ) ) then return end
							ent:Extinguish( )
						end )
					end
				end
			end
			SafeRemoveEntity( self )
		end
	end

	function ENT:AttemptFillup( ply, veh )
		local vehData = noob_VehicleIndex:Get( veh:GetModel( ) )
		veh.gasRemaining = veh.gasRemaining or vehData.maxGas
		local currentGas = veh.gasRemaining or vehData.maxGas
		if ( veh.gasRemaining < vehData.maxGas ) then
			local isDead = ( veh.gasRemaining <= 0 )
			local gasBoost = math.random( 25, 75 )
			local newGas = math.Clamp( veh.gasRemaining + gasBoost, 0, vehData.maxGas )
			veh.gasRemaining = newGas
			if ( isDead ) then
				veh:Fire( "TurnOn", "", 0 )
				if ( IsValid( veh:GetDriver( ) ) ) then
					if not ( veh:IsGasDraining( ) ) then
						veh:InitiateGasDrain( )
					end
				end
			end
			if ( newGas > ( vehData.maxGas * 0.95 ) ) then
				DarkRP.notify( ply, 2, 4, "You completely refilled the gas tank." )
			else
				DarkRP.notify( ply, 2, 4, "You partially refilled the gas tank." )
			end
			veh:SendCurrentGas( ply, vehData.maxGas )
			SafeRemoveEntity( self )
		else
			DarkRP.notify( ply, 1, 4, "That vehicle already has a full gas tank." )
		end
	end
	
	function ENT:Use( ply )
		local nearbyEnts = self:FindNearbyEntities( 512 )
		local distanceTable = { }
		if ( nearbyEnts and istable( nearbyEnts ) ) then
			for index, ent in ipairs ( nearbyEnts ) do
				if ( ent:IsVehicle( ) and noob_VehicleIndex:Get( ent:GetModel( ) ) ) then
					table.insert( distanceTable, { veh = ent, dist = ply:GetPos( ):FastDist( ent:GetPos( ) ) } )
				end
			end
		end
		if ( distanceTable and #distanceTable > 1 ) then
			table.SortByMember( distanceTable, "dist", true )
			local veh = distanceTable[1].veh
			self:AttemptFillup( ply, veh )
		elseif ( distanceTable and #distanceTable == 1 ) then
			local veh = distanceTable[1].veh
			self:AttemptFillup( ply, veh )
		end
	end

	function ENT:ClampWorldVector( vec )
		vec.x = math.Clamp( vec.x , -16380, 16380 )
		vec.y = math.Clamp( vec.y , -16380, 16380 )
		vec.z = math.Clamp( vec.z , -16380, 16380 )
		return vec
	end
else
	function ENT:Draw( )
		self:DrawModel( )
	end
end
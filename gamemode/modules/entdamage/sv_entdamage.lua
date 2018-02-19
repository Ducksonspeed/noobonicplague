local emeta = FindMetaTable( "Entity" );

util.AddNetworkString( "entity_health_text" );

function emeta:SetEntityHealth( amount )
	self.EntHealth = amount;
	self:SetHealth( amount )
end

function emeta:GetEntityHealth()
	return self.EntHealth;
end

function emeta:IsGodded()
	return self.EntGodmode;
end

function emeta:SetGodmode( bool )
	-- make sure when you're creating world props to make them godded!
	self.EntGodmode = bool;
end

function emeta:Destroy( )
	if ( self:IsVehicle( ) ) then
		if ( self:isKeysOwned( ) and IsValid( self:getDoorOwner( ) ) ) then
			local owningEnt = self:getDoorOwner( )
			owningEnt:SetVehicleCount( owningEnt:GetVehicleCount( ) - 1 )
		end
	end
	local pos = self:GetPos( );
	local magnitude = 0
	if ( SVNOOB_VARS:Get( "ExplosiveProps", true, "table", { ["models/props_c17/oildrum001_explosive.mdl" ] = true } )[self:GetModel( )] ) then
		magnitude = SVNOOB_VARS:Get( "ExplosiveMagnitude", true, "number", 125 )
	end
	util.CreateExplosion( pos, magnitude )
	SafeRemoveEntity( self )
end

function emeta:EntitySetDamage( amt, attacker )
	if ( self:IsGodded() ) then return; end
	if ( self.isGem ) then return end
	local damageReceiver = self
	local fallbackMaxHealth = 10000
	/*if ( self:GetParent( ):IsVehicle( ) ) then
		damageReceiver = self:GetParent( )
	end*/
	local entHealth = damageReceiver:GetEntityHealth( ) or fallbackMaxHealth -- Fallback value
	if ( entHealth - amt < 1 ) then damageReceiver:Destroy(); return; end

	local damage = math.floor( entHealth - amt );
	if ( IsValid( attacker ) and attacker:IsPlayer() ) then
		net.Start( "entity_health_text" );
			net.WriteString( damage );
		net.Send( attacker );
	end
	local maxHealth = self.EntityMaxHealth or fallbackMaxHealth
	if ( self.currentColor ) then
		local colorModR = self.currentColor.r * ( entHealth / maxHealth )
		local colorModG = self.currentColor.g * ( entHealth /  maxHealth )
		local colorModB = self.currentColor.b * ( entHealth / maxHealth )
		self:SetColor( Color( colorModR, colorModG, colorModB ) )
	else
		local colorMod = 255 * ( entHealth / maxHealth ) -- Fallback value used, EntityMaxHealth doesn't always appear to exist.
		self:SetColor( Color( colorMod, colorMod, colorMod ) )
	end
	damageReceiver:SetEntityHealth( damage );
	if ( maxHealth * 0.10 > damageReceiver:GetEntityHealth( ) ) then
		damageReceiver:Ignite( )
	end
end

local ent_whitelist =
{
	[ "prop_physics" ] 			= { health = math.random( 200, 500 ) },
	[ "prop_vehicle_jeep" ] 	= { health = 5000 },
	[ "prop_vehicle_airboat"] 	= { health = 5000 },
};

local function ScaleMeleeDamage( wep, dmgInfo, ent )
	local meleeDamageMultiTable = SVNOOB_VARS:Get( "MeleeWeaponMultipliers", true )
	if ( IsValid( wep ) and IsValid( ent ) ) then
		if ( meleeDamageMultiTable[ wep:GetClass( ) ] ) then
			if ( ent:IsPlayer( ) ) then
				dmgInfo:ScaleDamage( meleeDamageMultiTable[ wep:GetClass( ) ].ply )
			elseif ( ent:IsVehicle( ) ) then
				dmgInfo:ScaleDamage( meleeDamageMultiTable[ wep:GetClass( ) ].veh )
			elseif ( ent:GetClass( ) == "prop_physics" ) then
				dmgInfo:ScaleDamage( meleeDamageMultiTable[ wep:GetClass( ) ].prop )
			end
			--print( wep:GetClass( ) .. " : " .. ent:GetClass( ) .. " : " .. dmgInfo:GetDamage( ) )
		end
	end
end

hook.Add( "EntityTakeDamage", "EntityDamaging", function( target, dmginfo ) // Some really hacky shit going on here, but it works better than before.
	if ( target:IsPlayer( ) and target:InVehicle( ) ) then
		if ( dmginfo:GetDamage( ) > 10 ) then
			dmginfo:ScaleDamage( 0.01 )
		end
	end
	if ( target:IsPlayer() ) then return; end
	if ( dmginfo:IsFallDamage() ) then return; end
	if ( target:GetClass( ) == "prop_physics" or target:IsVehicle( ) ) then
		local attacker = dmginfo:GetAttacker( )
		if ( dmginfo:GetAttacker( ):IsPlayer( ) and IsValid( dmginfo:GetAttacker( ):GetActiveWeapon( ) ) ) then
			ScaleMeleeDamage( dmginfo:GetAttacker( ):GetActiveWeapon( ), dmginfo, target )
			dmginfo:GetAttacker( ):ScaleEntityDamage( target, dmginfo )
		end
		if ( target:IsVehicle( ) and IsValid( attacker ) and attacker:IsPlayer( ) ) then
			local oldDamage = dmginfo:GetDamage( )
			if ( dmginfo:GetDamage ( ) > 10 ) then dmginfo:ScaleDamage( 0.25 ) end
			if ( dmginfo:GetDamage( ) < 1 ) then dmginfo:ScaleDamage( 250 ) end
			if ( table.IsValid( target.passengerSeats, true ) ) then
				for index, seat in ipairs ( target.passengerSeats ) do
				if ( IsValid( seat ) and seat:IsVehicle( ) and IsValid( seat:GetDriver( ) ) and seat:GetDriver( ):InVehicle( ) ) then -- Looks dumb but just seeing if it fixes a problem.
						seat:GetDriver( ):TakeDamage( dmginfo:GetDamage( ), attacker, attacker:GetActiveWeapon( ) )
					end
				end
			end
			local dealtDamage = dmginfo:GetDamage( )
			if ( IsValid( target:GetDriver( ) ) and target:GetDriver( ):InVehicle( ) ) then
				local ply =  target:GetDriver( )
				ply:SetHealth( math.Clamp( ply:Health( ) - dealtDamage, 0, ply:GetMaxHealth( ) ) )
				if ( ply:Health( ) <= 0 ) then
					ply:TakeDamage( 1, attacker, attacker:GetActiveWeapon( ) )
				end
			end
			dmginfo:SetDamage( oldDamage )
		end
		target:EntitySetDamage( dmginfo:GetDamage(), dmginfo:GetAttacker() );
		if ( target:GetClass( ) == "prop_physics" and dmginfo:GetAttacker( ):IsVehicle( ) ) then
			dmginfo:GetAttacker( ):EntitySetDamage( dmginfo:GetDamage( ), target )
		end
	end
end );

hook.Add( "OnEntityCreated", "EntitySetHealth", function( ent )
	if ( ent:GetClass( ) == "prop_physics" ) then
		ent:SetGodmode( true )
		ent:Fire( "SetHealth", 10000, 0 )
		util.ExecuteDelayedFunction( ent, 0.1, function( ent )
			ent:SetGodmode( false )
			local propCost = noob_ValidPropList[ent:GetModel( )]
			if ( propCost ) then
				local hp = propCost * 10
				if ( ent:GetModel( ) == "models/props_c17/oildrum001_explosive.mdl" ) then
					hp = 1000
				end
				ent:SetEntityHealth( hp )
				ent.EntityMaxHealth = hp
				ent:SetMaxHealth( hp )
				ent:Fire( "SetHealth", hp * 2, 0 )
			else
				local hp = ent_whitelist[ ent:GetClass( ) ].health
				ent:SetEntityHealth( hp )
				ent.EntityMaxHealth = hp
				ent:Fire( "SetHealth", hp * 2, 0 )
			end
		end, ent )
	elseif ( ent:IsVehicle( ) ) then
		timer.Simple( 0.5, function( )
			if not ( IsValid( ent ) ) then return end
			local vehData = noob_VehicleIndex:Get( ent:GetModel( ) )
			if ( vehData ) then
				ent:SetEntityHealth( vehData.health )
				ent.EntityMaxHealth = vehData.health
				ent:SetMaxHealth( vehData.health )
			else
				ent:SetEntityHealth( 3000 )
				ent.EntityMaxHealth = 3000

			end
		end )
	end
	ent:SetRenderMode( RENDERMODE_TRANSCOLOR )
end );

ENUM_POTION_SPEED = 1
ENUM_POTION_HEALING = 2
ENUM_POTION_GRAVITY = 3
ENUM_POTION_SIZE = 4
ENUM_POTION_DISORIENT = 5
ENUM_POTION_DISEASE = 6
ENUM_POTION_CURE = 7
ENUM_POTION_DEFENSE = 8
ENUM_POTION_KNOCKBACK = 9
ENUM_POTION_STARVE = 10
ENUM_POTION_PARALYSIS = 11
ENUM_POTION_IGNITE = 12
ENUM_POTION_EXPLODE = 13

NOOBRP = NOOBRP or { }
NOOBRP.PotionFunctions = { }
local plyMeta = FindMetaTable( "Player" )

function plyMeta:AddPotionTimer( name, duration, reps, func )
	local name = name
	if ( IsEntity( name ) ) then
		if ( name.GetPotionName ) then
			name = name:GetPotionName( )
		else
			name = name.PotionName
		end
	end
	self.potionEffectTimers = self.potionEffectTimers or { }
	self.potionEffectTimers[ name ] = func
	timer.Create( name .. ":" .. self:EntIndex( ), duration, reps, function( )
		if not ( IsValid( self ) ) then return end
		func( self )
		self.potionEffectTimers[name] = nil
	end )
end

function plyMeta:RemovePotionTimers( )
	self.potionEffectTimers = self.potionEffectTimers or { }
	PrintTable( self.potionEffectTimers )
	for index, potionFunc in pairs ( self.potionEffectTimers ) do
		timer.Destroy( index .. ":" .. self:EntIndex( ) )
		potionFunc( self )
		self.potionEffectTimers[index] = nil
	end
end

NOOBRP.PotionFunctions[ "Minor Speed Potion" ] = function( ply, ent )
	ply:BoostRunSpeed( 1.5 )
	ply:ChatPrint( "You feel a bit more agile." )
	ply:AddPotionTimer( ent, 10, 1, function( ply )
		if not ( IsValid( ply ) ) then return end
		ply:ApplyMovementSpeed( )
		ply:ChatPrint( "Your speed has diminished." )
	end )
end

NOOBRP.PotionFunctions[ "Weak Healing Potion" ] = function( ply )
	if ( ply:Team( ) == TEAM_ZOMBIE ) then return end
	ply:SetHealth( math.Clamp( ply:Health( ) + ( ply:GetMaxHealth( ) * 0.2 ), 0, ply:GetMaxHealth( ) ) )
	ply:ChatPrint( "You feel a bit better." )
end

NOOBRP.PotionFunctions[ "Weak Low Gravity Potion" ] = function( ply, ent )
	ply:SetGravity( 0.45 )
	ply:ChatPrint( "You feel much lighter..." )
	ply:AddPotionTimer( ent, math.random( 5, 10 ), 1, function( ply )
		if not ( IsValid( ply ) ) then return end
		if ( ply:IsGhost( ) ) then return end
		ply:SetGravity( 1 )
		ply:ChatPrint( "You feel rather heavy again." )
	end )
end

NOOBRP.PotionFunctions[ "Disease Curing Potion" ] = function( ply )
	if ( timer.Exists( ply:EntIndex( ) .. ":InfectedTimer" ) ) then
		timer.Destroy( ply:EntIndex( ) .. ":InfectedTimer" )
		ply:ChatPrint( "You feel much better, you have been cured of disease." )
	else
		ply:ChatPrint( "You drank the potion but you feel no different." )
	end
end

NOOBRP.PotionFunctions[ "Poison Curing Potion" ] = function( ply )
	if ( ply:IsPoisoned( )  ) then
		ply:CurePoison( )
		ply:ChatPrint( "You feel your terrible sickness drift away." )
	else
		ply:ChatPrint( "You drank the potion but feel the same." )
	end
end

NOOBRP.PotionFunctions[ "Lesser Slowing Potion" ] = function( ply, ent )
	ply:BoostRunSpeed( 0.5 )
	ply:ChatPrint( "You feel slowed down quite a bit." )
	ply:AddPotionTimer( ent, 10, 1, function( ply )
		if not ( IsValid( ply ) ) then return end
		ply:ApplyMovementSpeed( )
		ply:ChatPrint( "Your speed has returned to normal." )
	end )
end

NOOBRP.PotionFunctions[ "Unstable Hormone Potion" ] = function( ply, ent )
	ply.defensePotionFunc = function( dmgInfo )
		dmgInfo:ScaleDamage( 0.25 )
	end
	ply:ChatPrint( "Suddenly you feel filled with strength." )
	ply:AddPotionTimer( ent, 5, 1, function( ply )
		if not ( IsValid( ply ) ) then return end
		ply.defensePotionFunc = nil
		ply:ChatPrint( "You begin to crash and lose strength." )
	end )
end

NOOBRP.PotionFunctions[ "Weak Knockback Potion" ] = function( ply, ent )
	if not ( IsValid( ent:GetPhysicsObject( ) ) ) then return end
	local entVelocity = ent:GetPhysicsObject( ):GetVelocity( )
	local currentVelocity = ply:GetVelocity( )
	local newVelocity = currentVelocity + ( entVelocity * 5 )
	ply:SetVelocity( newVelocity )
	ply:ChatPrint( "A strong force knocks you back." )
end

NOOBRP.PotionFunctions[ "Weak Restoration Potion" ] = function( ply, ent )
	if ( ply:Team( ) == TEAM_ZOMBIE ) then return end
	local timerName = ply:EntIndex( ) .. ":WeakRestorationPotion"
	ply:AddPotionTimer( ent, 2, 5, function( ply )
		if not ( IsValid( ply ) ) then timer.Destroy( timerName ) return end
		if ( ply:IsGhost( ) ) then timer.Destroy( timerName ) return end
		local randomHealth = math.random( ply:GetMaxHealth( ) * 0.1, ply:GetMaxHealth( ) * 0.3 )
		ply:SetHealth( math.Clamp( ply:Health( ) + randomHealth, 0, ply:GetMaxHealth( ) ) )
	end )
	ply:ChatPrint( "You begin to gradually feel better." )
end

NOOBRP.PotionFunctions[ "Lesser Healing Potion" ] = function( ply )
	if ( ply:Team( ) == TEAM_ZOMBIE ) then return end
	if ( ply:Health( ) == ply:GetMaxHealth( ) ) then
		ply:ChatPrint( "You drink the potion but feel no effects" )
		return
	end
	local healthReward = ply:GetMaxHealth( ) * 0.45
	local newHealth = math.Clamp( ply:Health( ) + healthReward, 0, ply:GetMaxHealth( ) )
	ply:SetHealth( newHealth )
	ply:ChatPrint( "You drink the potion and feel refreshed." )
end

NOOBRP.PotionFunctions[ "Lesser Speed Potion" ] = function( ply, ent )
	ply:BoostRunSpeed( 1.5 )
	ply:ChatPrint( "You feel fairly agile." )
	ply:AddPotionTimer( ent, 20, 1, function( ply )
		if not ( IsValid( ply ) ) then return end
		ply:ApplyMovementSpeed( )
		ply:ChatPrint( "You begin to feel exhausted." )
	end )
end

NOOBRP.PotionFunctions[ "Slight Growth Potion" ] = function( ply, ent )
	if ( ply:Team( ) == TEAM_CRAB ) then ply:ChatPrint( "The potion seems to have no effect, other than making you sick." ) return end
	ply:SetModelScale( 1.3, 1 )
	ply:ScaleViewOffset( 1.3 )
	ply:ScaleHull( 1.3 )
	ply:ChatPrint( "You start to grow slightly larger." )
	ply:AddPotionTimer( ent, math.random( 7, 14 ), 1, function( ply )
		if ( !IsValid( ply ) or ply:IsGhost( ) ) then return end
		ply:SetModelScale( 1, 0 )
		ply:ResetViewOffset( )
		ply:ScaleHull( nil, true )
		ply:ChatPrint( "You return to your original size." )
	end )
end

NOOBRP.PotionFunctions[ "Slight Shrinking Potion" ] = function( ply, ent )
	if ( ply:Team( ) == TEAM_CRAB ) then ply:ChatPrint( "The potion seems to have no effect, other than making you sick." ) return end
	ply:SetModelScale( 0.7, 1 )
	ply:ScaleViewOffset( 0.7 )
	ply:ScaleHull( 0.7 )
	ply:ChatPrint( "You feel yourself beginning to shrink." )
	ply:AddPotionTimer( ent, math.random( 7, 14 ), 1, function( ply )
		if ( !IsValid( ply ) or ply:IsGhost( ) ) then return end
		ply:SetModelScale( 1, 0 )
		ply:ResetViewOffset( )
		ply:ScaleHull( nil, true )
		ply:ChatPrint( "You return to your original size." )
	end )
end


NOOBRP.PotionFunctions[ "Decent Starvation Potion" ] = function( ply )
	local starveAmount = math.random( 25, 45 )
	local newHunger = math.Clamp( ply:getDarkRPVar( "Energy" ) - starveAmount, 0, 100 )
	ply:setSelfDarkRPVar( "Energy", newHunger )
	ply:ChatPrint( "You feel your stomach grumble, you're very hungry." )
end

NOOBRP.PotionFunctions[ "Ironskin Potion" ] = function( ply, ent )
	ply.defensePotionFunc = function( dmgInfo )
		dmgInfo:ScaleDamage( 0.65 )
	end
	ply:ChatPrint( "You begin to feel fairly strong." )
	ply:AddPotionTimer( ent, 10, 1, function( ply )
		if not ( IsValid( ply ) ) then return end
		ply.defensePotionFunc = nil
		ply:ChatPrint( "Your strength begins to fade." )
	end )
end

NOOBRP.PotionFunctions[ "Skull Growth Potion" ] = function( ply, ent )
	if ( ply:Team( ) == TEAM_CRAB ) then ply:ChatPrint( "The potion seems to have no effect, other than making you sick." ) return end
	local headBone = ply:LookupBone( "ValveBiped.Bip01_Head1" )
	if not ( headBone ) then ply:ChatPrint( "The potion seems to have no effects." ) return end
	local curBoneScale = ply:GetManipulateBoneScale( headBone )
	if ( math.floor( curBoneScale[1] ) ~= 1 or math.floor( curBoneScale[2] ) ~= 1 or math.floor( curBoneScale[3] ) ~= 1 ) then
		ply:ChatPrint( "Your head is already enlarged." )
		return
	end
	ply:ChatPrint( "You feel your skull expand." )
	ply:ManipulateBoneScale( headBone, Vector( 2, 2, 2 ) )
	ply:AddPotionTimer( ent, 60, 1, function( ply )
		if ( !IsValid( ply ) ) then return end
		ply:ManipulateBoneScale( headBone, Vector( 1, 1, 1 ) )
		ply:ChatPrint( "Your skull begins to contract." )
	end )
end

NOOBRP.PotionFunctions[ "Mellow Vision Blurring Potion" ] = function( ply, ent )
	ply:EnableVisionBlur( true )
	ply:ChatPrint( "It becomes hard to focus." )
	ply:AddPotionTimer( ent, math.random( 7, 14 ), 1, function( ply )
		if ( !IsValid( ply ) ) then return end
		ply:EnableVisionBlur( false )
		ply:ChatPrint( "You can see clearly again." )
	end )
end

NOOBRP.PotionFunctions[ "Toxic Contagious Disease Potion"] = function( ply )
	ply:ChatPrint( "You question your sanity considering to consume this potion." )
	ply:InfectPlayer( ply )
end

NOOBRP.PotionFunctions[ "Permanent Shrink Potion" ] = function( ply )
	ply:ChatPrint( "You feel really fucking small." )
	ply:EmitSound( "weapons/physcannon/energy_disintegrate4.wav" )
	ply:SetModelScale( 0.2, 0 )
	ply:ScaleViewOffset( 0.2 )
	ply:ScaleHull( 0.2 )
	ply:ApplyMovementSpeed( )
end

NOOBRP.PotionFunctions[ "Greater Speed Potion" ] = function( ply, ent )
	ply:BoostRunSpeed( 1.5 )
	ply:ChatPrint( "You begin to feel extremely energized." )
	ply:AddPotionTimer( ent, 28, 1, function( ply )
		if not ( IsValid( ply ) ) then return end
		ply:ApplyMovementSpeed( )
		ply:ChatPrint( "Your speed has returned to normal." )
	end )
end

NOOBRP.PotionFunctions[ "Disorientating Potion" ] = function( ply, ent )
	ply:DisorientPlayer( math.random( 4, 10 ) )
	ply:ChatPrint( "You suddenly become very confused." )
	local entIndex = ply:EntIndex( )
	ply:AddPotionTimer( ent, math.random( 7, 14 ), 1, function( ply )
		timer.Remove( "N00BRP_DisorientPlayer_" .. entIndex )
		if ( !IsValid( ply ) ) then return end
		ply:ChatPrint( "You no longer feel confused." )
	end )
end

NOOBRP.PotionFunctions[ "Paralysis Potion" ] = function( ply, ent )
	ply:ParalyzePlayer( math.random( 5, 10 ), nil )
	ply:ChatPrint( "You lose all feeling in your body." )
end

NOOBRP.PotionFunctions[ "Decent Inferno Potion" ] = function( ply, ent )
	local igniteTimer = math.random( 5, 15 )
	ply:Ignite( igniteTimer )
	ply:ChatPrint( "You feel intense pain as your whole body goes up into flames." )
	local entIndex = ply:EntIndex( )
	ply:AddPotionTimer( ent, igniteTimer + 1, 1, function( ply )
		if ( !IsValid( ply ) ) then return end
		ply:Extinguish( )
		ply:ChatPrint( "The pain begins to fade." )
	end )
end

NOOBRP.PotionFunctions[ "Volatile Combustion Potion" ] = function( ply, ent )
	ply:ChatPrint( "All of a sudden everything goes black." )
	local envExplode = ents.Create( "env_explosion" );
	envExplode:SetKeyValue( "iMagnitude", tostring( 100 ) )
	envExplode:SetPos( ply:GetPos( ) )
	envExplode:Spawn( )
	envExplode:Activate( )
	envExplode:Fire( "Explode", 0, 0 )
end

NOOBRP.PotionCategories = {
	["Minor Speed Potion"] = ENUM_POTION_SPEED,
	["Weak Healing Potion"] = ENUM_POTION_HEALING,
	["Weak Low Gravity Potion" ] = ENUM_POTION_GRAVITY,
	["Slight Growth Potion"] = ENUM_POTION_SIZE,
	["Slight Shrinking Potion"] = ENUM_POTION_SIZE,
	["Skull Growth Potion"] = ENUM_POTION_SIZE,
	["Mellow Vision Blurring Potion"] = ENUM_POTION_DISORIENT,
	["Toxic Contagious Disease Potion"] = ENUM_POTION_DISEASE,
	["Disease Curing Potion"] = ENUM_POTION_CURE,
	["Unstable Hormone Potion"] = ENUM_POTION_DEFENSE,
	["Ironskin Potion"] = ENUM_POTION_DEFENSE,
	["Lesser Healing Potion"] = ENUM_POTION_HEALING,
	["Lesser Speed Potion"] = ENUM_POTION_SPEED,
	["Permanent Shrink Potion"] = ENUM_POTION_SIZE,
	["Weak Knockback Potion"] = ENUM_POTION_KNOCKBACK,
	["Lesser Slowing Potion"] = ENUM_POTION_SPEED,
	["Weak Restoration Potion"] = ENUM_POTION_HEALING,
	["Decent Starvation Potion"] = ENUM_POTION_STARVE,
	["Poison Curing Potion"] = ENUM_POTION_CURE,
	["Disorientating Potion"] = ENUM_POTION_DISORIENT,
	["Paralysis Potion"] = ENUM_POTION_PARALYSIS,
	["Decent Inferno Potion"] = ENUM_POTION_IGNITE,
	["Volatile Combustion Potion"] = ENUM_POTION_EXPLODE,
	["Greater Speed Potion"] = ENUM_POTION_SPEED
}
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Soul Orb"
ENT.Author = "Jeezy"
ENT.Spawnable = false

if ( SERVER ) then
	AddCSLuaFile( )
	function ENT:Initialize( )
		self:SetModel( "models/hunter/misc/sphere075x075.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup( COLLISION_GROUP_WORLD )
		self:SetMaterial( "models/props_combine/portalball001_sheet" )
		self:DrawShadow( false )
		local phys = self:GetPhysicsObject( )
		if phys:IsValid( ) then
			phys:Wake( )
			phys:EnableMotion( false )
		end
		timer.Simple( math.random( 60, 120 ), function( )
			if ( IsValid( self ) ) then
				SafeRemoveEntity( self )
			end
		end )
	end

	function ENT:ActivateOrb( ply )
		local timeLeft = timer.TimeLeft( ply:EntIndex( ) .. ":RespawnTimer" )
		local soulOrbStrength = tonumber( SVNOOB_VARS:Get( "SoulOrbStrength" ) ) or 60
		if ( soulOrbStrength > timeLeft ) then
			hook.Call( "OnPlayerUseSoulOrb", { }, ply )
			ply:EnableGhostMode( false )
			SafeRemoveEntity( self )
		else
			hook.Call( "OnPlayerUseSoulOrb", { }, ply )
			local finalTime = timeLeft - soulOrbStrength
			local playerCorpse = ply.playerCorpse
			
			//ply:SetNetworkedInt( "RespawnTime", CurTime( ) + finalTime )
			//ply:setDarkRPVar( "RespawnTime", CurTime( ) + finalTime )
			timer.Adjust( ply:EntIndex( ) .. ":RespawnTimer", finalTime, 1, function( )
				if not ( IsValid( ply ) ) then
					SafeRemoveEntity( playerCorpse )
					return
				end
				ply.spawnPosOverride = nil
				ply:EnableGhostMode( false )
			end )
			SafeRemoveEntity( self )
		end
	end

	local function ReachForOrb( ply, key )
		if ( key == IN_USE and ply:IsGhost( ) ) then
			local traceRes = ply:RangeEyeTrace( 256 )
			if ( IsValid( traceRes.Entity ) and traceRes.Entity:GetClass( ) == "soul_orb" ) then
				traceRes.Entity:ActivateOrb( ply )
			end
		end
	end
	hook.Add( "KeyPress", "N00BRP_ReachForOrb_KeyPress", ReachForOrb )
else
	function ENT:Draw( )
		if ( LocalPlayer( ):IsGhost( ) or ( LocalPlayer( ):IsWearingHat( { "top_hat", "uncommon_top_hat", "rare_top_hat" } ) ) ) then
			self:DrawModel( )
		end
	end
end
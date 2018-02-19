ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Crab Hill"
ENT.Author = "Sinavestos : Edited by Jeezy"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "owning_ent")
	self:NetworkVar("Float", 0, "Value")
end

if ( SERVER ) then
	AddCSLuaFile( )
	/*local gemTypes = {
		[3] = { color = Color( 100, 100, 100 ), material = "", name = "shale" },
		[4] = { color = Color( 0, 255, 0 ), material = "models/shiny", name = "emerald" },
		[5] = { color = Color( 255, 0, 0 ), material = "models/shiny", name = "ruby" },
		[6] = { color = Color( 0, 0, 255 ), material = "models/shiny", name = "sapphire" },
		[7] = { color = Color( 25, 25, 25 ), material = "models/shiny", name = "obsidian" }
	}*/
	function ENT:Initialize( )
		self:SetModel( "models/props_wasteland/antlionhill.mdl" )
		self:SetSolid( SOLID_BBOX )
		self:SetCollisionBounds( Vector( -14.47904, -17.59288, -0.73963 ), Vector( 13.44682, 15.90983, 54.28711 ) )
		self:PhysicsInitBox( Vector( -14.47904, -17.59288, -0.73963 ), Vector( 13.44682, 15.90983, 54.28711 ) )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		local phys = self:GetPhysicsObject( )
		if phys:IsValid( ) then phys:Wake( ) end
		self.sparking = false
		self.damage = 100
		self.stored = 0
		self.IsMoneyPrinter = true
		self:SetModelScale( 0.1, 0 )
		timer.Simple( math.random( 100, 300 ), function( )
			if ( IsValid( self ) ) then
				self:AddToStored( )
			end
		end )
	end

	function ENT:PhysicsCollide( dat, phys )
		phys:EnableMotion( false )
	end

	function ENT:OnTakeDamage( dmg )
		if self.burningup then return end

		self.damage = self.damage - dmg:GetDamage( )
		if self.damage <= 0 then
			self:Destruct()
			SafeRemoveEntity( self )
		end
	end

	function ENT:Destruct( )
		local vPoint = self:GetPos( )
		local effectdata = EffectData( )
		effectdata:SetStart( vPoint )
		effectdata:SetOrigin( vPoint )
		effectdata:SetScale( 1 )
		util.Effect( "Explosion", effectdata )
		DarkRP.notify( self:Getowning_ent( ), 1, 4, "Your crab hill has been destroyed." )
		SafeRemoveEntity( self )
	end

	local function PrintMore( ent )
		if ( IsValid( ent ) ) then
			ent.sparking = true
			timer.Simple( 3, function( )
				if not ( IsValid( ent ) ) then return end
				ent:AddToStored( ) 
			end )
		end
	end

	function ENT:AddToStored( )
		if not ( IsValid( self ) ) then return end
		if ( self:IsOnFire( ) ) then return end
		if ( math.random( 1, 22 ) == 3 ) then 
			local blowUpTime = math.random( 15, 20 )
			self:Ignite( blowUpTime )
			timer.Simple( blowUpTime, function( )
				if not ( IsValid( self ) ) then return end
				self:Destruct( )
			end )
		end
		local amount = tonumber( SVNOOB_VARS:Get( "CrabHillPrintAmt" ) ) or 250
		local mins = ClampWorldVector( self:GetPos( ) - Vector( 256, 256, 256 ) )
		local maxs = ClampWorldVector( self:GetPos( ) + Vector( 256, 256, 256 ) )
		local nearbyEnts = ents.FindInBox( mins, maxs )
		local hillCount = 0
		local crabQueen = SVNOOB_VARS:Get( "CrabQueen" )
		if ( nearbyEnts and #nearbyEnts > 0 ) then
			for index, ent in ipairs( nearbyEnts ) do
				if ( IsValid( ent ) and ent:GetClass() == "crab_hill" ) then 
					hillCount = hillCount + 1 
				end
				//if ( IsValid( ent ) and ent:IsPlayer() and ent:Alive() and !ent:getDarkRPVar( "IsGhost" ) and ent == crabQueen ) then
				if ( IsValid( ent ) and ent:IsPlayer() and ent:Alive() and !ent:IsGhost( ) and ent == crabQueen ) then
					if ( math.random( 1, 3 ) == 3 ) then
						local gType = nil
						local roll = math.Rand( 0, 100 )
						if ( roll < 40 ) then 
							gType = "shale"
						else 
							gType = "emerald"
						end
						if ( roll > 83 ) then 
							gType = "ruby"
						end
						if ( roll > 95 ) then 
							gType = "sapphire"
						end
						if ( roll > 99.8 ) then 
							gType = "obsidian"
						end
						if not ( gType ) then 
							gType = "shale"
						end
						local pos = Vector( 0, 0, 40 ) + self:GetPos( )
						local spawnedGem = ents.Create( "ent_gem" )
						spawnedGem:SetGemType( gType )
						spawnedGem:SetPos( pos )
						spawnedGem:Spawn( )
						/*local spawnedGem = ents.Create( "prop_physics" )
						spawnedGem:SetModel( "models/props_junk/rock001a.mdl" )
						spawnedGem:SetPos( pos )
						spawnedGem:Spawn( )
						spawnedGem:Activate( )
						spawnedGem.gemType = gemTypes[gtype].name
						spawnedGem.isGem = true
						spawnedGem:SetRenderMode( RENDERMODE_TRANSALPHA )
						spawnedGem:SetColor( gemTypes[gtype].color )
						spawnedGem:SetMaterial( gemTypes[gtype].material )
						timer.Simple( 1, function( )
							if not ( IsValid( spawnedGem ) ) then return end
							spawnedGem:SetGodmode( true )
						end )
						timer.Simple( 300, function( )
							if not ( IsValid( spawnedGem ) ) then return end
							SafeRemoveEntity( spawnedGem )
						end )*/
					end
				end
			end
		end
		self.stored = self.stored + ( amount * hillCount * 0.5 )
		self:Getowning_ent( ):ChatPrint("(HILL) Crab hill has gained $" .. ( amount * hillCount * 0.5 ) .. ". Currently has stored: $" .. self.stored .. "." )
		self.sparking = false
		timer.Simple( math.random( 100, 300 ), function( )
			if not ( IsValid( self ) ) then return end
			PrintMore( self )
		end )
	end
	function ENT:Use( activator, caller )
		if ( IsValid( activator ) and activator:IsPlayer( ) ) then
			self:CreateMoneyBag( )
		end
	end
	function ENT:OnRemove( )
		if ( IsValid( self ) ) then 
			self:CreateMoneyBag( ) 
		end
	end
	function ENT:CreateMoneyBag( )
		if not ( IsValid( self ) ) then return end
		if ( self.stored == 0 ) then return end
		local moneybag = DarkRP.createMoneyBag( self:GetPos( ) + Vector( 15, 0, 15 ), self.stored )
		self.stored = 0
	end
else
	function ENT:Initialize( )
		self:SetModelScale( 0.1, 0 )
	end

	function ENT:Draw()
		self:DrawModel( )
	end

	function ENT:Think( )
	end
end
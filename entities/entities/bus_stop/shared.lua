AddCSLuaFile( )
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Bus Stop"
ENT.Author = "Jeezy"
ENT.Spawnable = true
ENT.TimerPrefix = "N00BRP_BusStop_AttemptStop_"

function ENT:SetupDataTables( )
	self:NetworkVar( "Bool", 0, "IsUsable" )
end

if ( SERVER ) then

	function ENT:Initialize()
		self:SetModel( "models/hunter/plates/plate2x3.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetNotSolid( true )
		self:SetTrigger( true )
		self:SetNoDraw( true )
		local physObj = self:GetPhysicsObject( )
		if ( physObj:IsValid( ) ) then
			physObj:Wake( )
			physObj:EnableMotion( false )
		end
		self:SetIsUsable( true )
		self.sceneChildren = { }
		self:SpawnScene( )
		self.stoppingEnt = nil
	end

	function ENT:SpawnScene( )
		local pos, ang = self:GetPos( ), self:GetAngles( )
		local benchOne = ents.Create( "prop_physics" )
		benchOne:SetPos( pos + ( ang:Forward( ) * 50 ) + ( ang:Right( ) * -105 ) )
		benchOne:SetAngles( ang + Angle( 0, 90, 0 ) )
		benchOne:SetModel( "models/props/de_inferno/bench_wood.mdl" )
		benchOne:Spawn( )
		benchOne:Activate( )
		benchOne:SetParent( self )
		benchOne.ignoreEarthquakes = true
		table.insert( self.sceneChildren, benchOne )
		local physObj = benchOne:GetPhysicsObject( )
		if ( physObj:IsValid( ) ) then
			physObj:Wake( )
			physObj:EnableMotion( false )
		end
		--benchOne:SetGodmode( true )
		local benchTwo = ents.Create( "prop_physics" )
		benchTwo:SetPos( pos + ( ang:Forward( ) * -50 ) + ( ang:Right( ) * -105 ) )
		benchTwo:SetAngles( ang + Angle( 0, 90, 0 ) )
		benchTwo:SetModel( "models/props/de_inferno/bench_wood.mdl" )
		benchTwo:Spawn( )
		benchTwo:Activate( )
		benchTwo:SetParent( self )
		benchTwo.ignoreEarthquakes = true
		table.insert( self.sceneChildren, benchTwo )
		physObj = benchTwo:GetPhysicsObject( )
		if ( physObj:IsValid( ) ) then
			physObj:Wake( )
			physObj:EnableMotion( false )
		end
		--benchTwo:SetGodmode( true )
		/*local signProp = ents.Create( "prop_physics" )
		signProp:SetPos( pos + ( ang:Forward( ) * -115 ) + ( ang:Right( ) * -105 ) )
		signProp:SetAngles( ang + Angle( 0, -90, 0 ) )
		signProp:SetModel( "models/props/de_overpass/playground_sign.mdl" )
		signProp:Spawn( )
		signProp:Activate( )
		signProp:SetParent( self )
		signProp.ignoreEarthquakes = true
		table.insert( self.sceneChildren, signProp )
		physObj = signProp:GetPhysicsObject( )
		if ( physObj:IsValid( ) ) then
			physObj:Wake( )
			physObj:EnableMotion( false )
		end*/
		--signProp:SetGodmode( true )
		timer.Simple( 1, function( )
			if ( !IsValid( benchOne ) or !IsValid( benchTwo ) ) then return end
			benchOne:SetGodmode( true )
			benchTwo:SetGodmode( true )
			--signProp:SetGodmode( true )
		end )
	end
	
	function ENT:OnRemove( )
		for index, child in ipairs ( self.sceneChildren ) do
			if ( IsValid( child ) ) then
				SafeRemoveEntity( child )
			end
		end
	end

	function ENT:StartTouch( ent )
		local stopTick = 0
		if not ( timer.Exists( self.TimerPrefix .. self:EntIndex( ) ) ) then
			if not ( self:GetIsUsable( ) ) then return end
			if not ( ent:IsVehicle( ) ) then return end
			if not ( IsValid( ent:GetDriver( ) ) ) then return end
			if ( self.stoppingEnt and self.stoppingEnt ~= ent ) then return end
			if not ( ent:GetDriver( ):Team( ) ~= TEAM_BUSDRIVER ) then return end
			if ( !ent:IsBus() ) then return; end
			// if not ( ent:GetModel( ) == "models/tdmcars/bus.mdl" ) then return end
			self.stoppingEnt = ent
			local entIndex = self:EntIndex( )
			timer.Create( self.TimerPrefix .. entIndex, 1, 5, function( )
				if not ( IsValid( self ) ) then
					timer.Destroy( self.TimerPrefix .. entIndex )
					return
				end
				if ( !IsValid( ent ) or !IsValid( ent:GetDriver( ) ) or !IsValid( self.stoppingEnt ) or ent:GetDriver( ):Team( ) ~= TEAM_BUSDRIVER or ent:GetModel( ) ~= "models/tdmcars/bus.mdl" ) then 
					timer.Destroy( self.TimerPrefix .. entIndex )
					self.stoppingEnt = nil
					return 
				end
				stopTick = stopTick + 1
				if ( stopTick >= 5 ) then
					local plyDriver = self.stoppingEnt:GetDriver( )
					local cashReward = math.random( 250, 750 )
					DarkRP.notify( plyDriver, 2, 4, "You've gained $" .. cashReward .. " for stopping at a Bus Stop!" )
					self:SetIsUsable( false )
					self.stoppingEnt = nil
					timer.Simple( 300, function( )
						if not ( IsValid( self ) ) then return end
						self:SetIsUsable( true )
					end )
				end
			end )
		end
	end

	function ENT:EndTouch( ent )
		if not ( self:GetIsUsable( ) ) then return end
		if not ( ent:IsVehicle( ) ) then return end
		if not ( ent.stoppingEnt == ent ) then return end
		if ( timer.Exists( self.TimerPrefix .. self:EntIndex( ) ) ) then
			timer.Destroy( self.TimerPrefix .. self:EntIndex( ) )
			self.stoppingEnt = nil
		end
	end
else
	function ENT:Draw( )
		self:DrawModel( )
	end

	local function DrawBusStopHalos( )
		local busStops = ents.FindByClass( "bus_stop" )
		local validStops = { }
		if ( !busStops or #busStops <= 0 ) then return end
		for index, ent in ipairs ( busStops ) do
			if not ( LocalPlayer( ):Team( ) == TEAM_BUSDRIVER ) then continue end
			if not ( LocalPlayer( ):IsLineOfSightClear( ent:GetPos( ) ) ) then continue end
			if not ( ent:GetIsUsable( ) ) then continue end
			table.insert( validStops, ent )
		end
		halo.Add( validStops, Color( 125, 175, 125 ), 3, 3, 2 )
	end
	hook.Add( "PreDrawHalos", "N00BRP_DrawBusStopHalos_PreDrawHalos", DrawBusStopHalos )
end
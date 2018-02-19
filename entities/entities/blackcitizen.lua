// not complete -- mainly for testing purposes and laughs.

if ( SERVER ) then
	AddCSLuaFile();
	util.AddNetworkString( "beast_effects" );
end

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= false;
ENT.AdminSpawnable  = false;

function ENT:Initialize()
	self.loco:SetDesiredSpeed( 300 );
	
	self:SetModel( "models/Humans/Group01/Male_01.mdl" );
	self:SetModelScale( 2, 0 );
	self:ManipulateBoneScale( 6, Vector( 2, 2, 2 ) );

	self:SetHealth( 300 );
	self:SetPos( self:GetPos() + Vector( 0, 0, 40 ) );

	self:SetCollisionGroup( COLLISION_GROUP_WEAPON );

	self.HasInit = true;
end

function ENT:InRange( pos, distance )
	if ( self:GetPos():Distance( pos ) <= distance ) then
		return true;
	end
	return false;
end

function ENT:CreateEffect( tab )
	net.Start( "beast_effects" );
		net.WriteTable( tab );
	net.Broadcast();
end

function ENT:FindAPlayer()
	local pl = false;

	for k, v in pairs( player.GetAll() ) do
		if ( v:Alive() and self:InRange( v:GetPos(), 1000 ) ) then
			-- local zpos = v:GetPos().z - self.Entity:GetPos().z;
			-- if ( zpos <= 0 and zpos > -5 ) then
				if ( math.random( 1, 5 ) <= 2 ) then
					pl = v;
					break;
				end
			-- end
		end
	end

	return pl;
end

local damage_table = {};
local highest_damage = { first = { damagedone = 0 }, second = { damagedone = 0 } };

-- this is pretty messy..
local function checkmostdamageobsidians( tab )
	if ( tab.player != highest_damage.first.player ) then
		if ( v.damagedone > highest_damage.first.damagedone ) then
			highest_damage.first.damagedone = v.damagedone;
			highest_damage.first.player = v.player;
		end
	end
end
local function checkmostdamagediamond( tab )
	if ( tab.damagedone > highest_damage.first.damagedone ) then
		highest_damage.first.damagedone = tab.damagedone;
		highest_damage.first.player = tab.player;
	end

	if ( tab == #damage_table ) then
		for k, v in pairs( damage_table ) do
			checkmostdamageobsidians( damage_table[ k ] );
		end
	end
end

function ENT:OnInjured( dmginfo )
	if ( dmginfo:GetAttacker():IsPlayer() ) then
		local dmg = math.floor( dmginfo:GetDamage() );

		if ( damage_table[ dmginfo:GetAttacker():SteamID() ] == nil ) then
			damage_table[ dmginfo:GetAttacker():SteamID() ] = { damagedone = dmg, player = dmginfo:GetAttacker() };
		else
			damage_table[ dmginfo:GetAttacker():SteamID() ].damagedone = damage_table[ dmginfo:GetAttacker():SteamID() ].damagedone + dmg;
		end
	end
	
	return false;
end

function ENT:OnKilled()
	local pos = self:GetPos();
	
	self:Remove();

	local ragdoll = ents.Create( "prop_ragdoll" );
	ragdoll:SetModel( "models/Humans/Group01/Male_01.mdl" );
	ragdoll:SetPos( pos );
	ragdoll:Spawn();
	ragdoll:SetCollisionGroup( COLLISION_GROUP_DEBRIS );

	timer.Simple( 20, function()
		if ( IsValid( ragdoll ) ) then
			ragdoll:Remove();
		end
	end );

	for k, v in pairs( damage_table ) do
		if ( IsValid( v.player ) ) then
			v.player:ChatPrint( "You did "..v.damagedone.." damage to the beast." );
			checkmostdamagediamond( damage_table[ k ] );
		else
			table.remove( damage_table, k );
		end
	end

	timer.Simple( 1, function()
		PrintMessage( HUD_PRINTTALK, "(BEAST) "..highest_damage.first.player:Nick().." won the beast, dealing "..highest_damage.first.damagedone.." damage to the Beast!" );

		highest_damage = { first = { damagedone = 0 }, second = { damagedone = 0 } };
		damage_table = {};

		timer.Simple( 2, function()
			for k, v in pairs( player.GetAll() ) do
				if ( v:SteamID() == "STEAM_0:0:46908953" ) then
					PrintMessage( HUD_PRINTTALK, "(BEAST) And now a moment of silence for Michaelb211 to go outside for the first time ever." );
				end
			end
		end );
	end );
end

function ENT:Teleport( pl )
	if ( !pl ) then return; end

	self:SetPos( pl:GetPos() );

	/*
	local exp = ents.Create( "env_explosion" );
	exp:SetPos( pl:GetPos() );
	exp:SetOwner( self );
	exp:Spawn();
	exp:SetKeyValue( "iMagnitude", "400" );
	exp:Fire( "Explode", 0, 0 );
	*/
end

function ENT:PerformAnim( animation, speed )
	self:SetSequence( animation );
	self:SetPlaybackRate( speed );
end

function ENT:PerformBeastTask()
	local rand = math.random( 1, 3 );
	local wait = 0.5;

	self.DoingStuff = true;

	if ( rand == 1 ) then
		wait = 3;

		local ranpl = self:FindAPlayer();
		if ( !ranpl ) then
			self:PerformBeastTask();
		else
			self:Teleport( ranpl );
		end
	elseif ( rand == 2 ) then
		wait = 2;
		self:PerformAnim( "droprope3", 2 );

		for k, v in pairs( ents.FindByClass( "prop_physics" ) ) do
			if ( self:InRange( v:GetPos(), 800 ) ) then v:Destroy(); end
		end

		for k, v in pairs( ents.FindByClass( "prop_vehicle_*" ) ) do
			if ( self:InRange( v:GetPos(), 800 ) ) then v:Destroy(); end
		end
	else
		wait = 1.3;
		self:PerformAnim( "throwitem", 1 );
		for i = 1, 12 do
			self:CreateEffect( {
				name = "particles/smokey", pos = Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) ) * 50, 
				velocity = Vector( 0, 0, 0 ), startsize = 50, dietime = 4, color = Color( 91, 91, 255 ) 
			} );
		end
	end

	coroutine.wait( wait );
	self.DoingStuff = false;
end

function ENT:RunBehaviour()
	while ( !self.DoingStuff ) do
		local rand = math.random( 1, 10 );
		local enemy = self:FindAPlayer();

		if ( rand <= 5 ) then
			if ( !self.HasInit ) then
				self:PerformAnim( "run_all_panicked", 1 );

				if ( enemy ) then
					enemy:ChatPrint( "beast now chasing you" );
					self:MoveToPos( enemy:GetPos() );
				else
					self:MoveToPos( self:GetPos() + ( Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * math.random( 400, 600 ) ) );
				end
			else
				self:StartActivity( ACT_RUN );
				self.HasInit = false;
			end
		else
			self:PerformBeastTask();
		end

		if ( math.random( 1, 10 ) <= 3 ) then
			self:EmitSound( "vo/npc/male01/vanswer0"..math.random( 1, 9 )..".wav" );
		end

		self:StartActivity( ACT_IDLE );
		coroutine.wait( 1 );
		coroutine.yield();
	end
end

if ( CLIENT ) then
	net.Receive( "beast_effects", function()
		local efx = net.ReadTable();
		local beast = ents.FindByClass( "beast" )[ 1 ]; // there should only be 1 beast anyways.
		local efxpos = beast:GetPos() + Vector( 0, 0, 90 );

		local pem = ParticleEmitter( efxpos + efx.pos );
		local part = pem:Add( efx.name, efxpos + efx.pos );
		
		if ( part ) then
			if ( efx.color ) then part:SetColor( efx.color.r, efx.color.g, efx.color.b ); else part:SetColor( 255, 255, 255 ); end
			part:SetVelocity( efx.velocity or Vector( math.Rand( -5, 5 ), math.Rand( -5, 5 ), math.Rand( -5, 5 ) ) * 100 );
			part:SetStartAlpha( efx.startalpha or 255 );
			part:SetEndAlpha( efx.endalpha or 0 );
			part:SetStartSize( efx.startsize or 15 );
			part:SetEndSize( efx.endsize or 15 );
			part:SetDieTime( efx.dietime or 3 );
			part:SetRoll( efx.roll or 0 );
		end
	end );
end

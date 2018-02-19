AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );

include( "shared.lua" );

function ENT:Initialize()
	self:SetModel( "models/xqm/button3.mdl" );
	self:PhysicsInit( SOLID_NONE );
	self:SetMoveType( MOVETYPE_NONE );
	self:SetSolid( SOLID_VPHYSICS );
	self:SetUseType( SIMPLE_USE );
	self.nextRobbery = 0
	-- self:Freeze( true );
end

function ENT:DestroyProps( )
	local boxMins = Vector( -6353, -8014, 100 )
	local boxMaxs = Vector( -6964, -7266, 424 )
	local nearbyEnts = ents.FindInBox( boxMins, boxMaxs )
	if ( nearbyEnts and istable( nearbyEnts ) and #nearbyEnts > 0 ) then
		for index, ent in ipairs ( nearbyEnts ) do
			if ( ent:GetClass( ) == "prop_physics" and !ent:IsGodded( ) ) then
				ent:Destroy( )
			end
		end
	end
end

whitelist_bankents = { "spawned_shipment", "spawned_weapon", "food", "ent_alchemypotion" };

function ENT:SpawnItems( robber, steamid )
	local itemspawnpos = self:GetPos() + Vector( 0, 0, 10 );

	mySQLControl:Query( "SELECT * FROM darkrp_bankitems WHERE steamid = "..string.Enclose( steamid ).." ORDER BY RAND() LIMIT 10;", function( data )
		for k, v in pairs( data ) do
			if ( !table.HasValue( whitelist_bankents, v.class ) ) then continue; end

			local robbedent = ents.Create( v.class );

			if ( v.class == "spawned_shipment" ) then
				for a, b in pairs( CustomShipments ) do
					if ( v.content == b.entity ) then
						robbedent:SetContents( a, tonumber( v.count ) );
					end
				end
			elseif ( v.class == "spawned_weapon" ) then
				robbedent:SetWeaponClass( v.content );
				robbedent:SetModel( v.model )
				robbedent:Setamount( 1 )
				-- robbedent:Setcount( tonumber( v.count ) );
			elseif ( v.class == "food" ) then
				robbedent:Setowning_ent( robber )
			elseif ( v.class == "ent_alchemypotion" ) then
				robbedent:SetPotionName( v.content )
				robbedent:Setowning_ent( robber )
			end

			robbedent.ShareGravgun = true;
			robbedent.nodupe = true;

			-- robbedent:Setowning_ent( robber );
			robbedent:SetModel( v.model );
			robbedent:SetPos( itemspawnpos );
			robbedent:Spawn();
			timer.Simple( 300, function( )
				if not ( IsValid( robbedent ) ) then return end
				SafeRemoveEntity( robbedent )
			end )
		end

		PrintMessage( HUD_PRINTTALK, robber:Nick().." has robbed the bank and stole items from "..data[ 1 ].name.."! \n       (Thank God for insurance.)" );

		hook.Call( "OnPlayerRobbedBank", { }, robber )
		if ( math.random( 1, 50 ) <= 4 ) then
			mySQLControl:Query( "SELECT * FROM darkrp_gems WHERE steamid = "..string.Enclose( steamid )..";", function( data )
				if ( #data > 0 ) then
					local niceobby = ents.Create( "prop_physics" );
					niceobby:SetModel( "models/props_junk/rock001a.mdl" );
					niceobby:SetColor( Color( 0, 0, 0 ) );
					niceobby:SetMaterial( "models/shiny" );
					niceobby:SetPos( itemspawnpos );
					niceobby.isGem = true
					niceobby.gemType = "obsidian";
					niceobby:Spawn()
					niceobby:Activate();

					PrintMessage( HUD_PRINTTALK, robber:Nick().." has also robbed an Obsidian from "..data[ 1 ].name.."!\n       (Thank God for insurance.)" );
				end
			end );
		end
	end );
end

function ENT:StopRobbery( giveitems, setCooldown )
	self.GetRobber.StartedRobbery = false;
	self.IsBeingRobbed = false;

	self.BankAlarm:Stop();
	timer.Remove("BankRobberyWanted");
	timer.Remove( "N00BRP_BankRobberyTimer" );

	local robber = self.GetRobber;
	if ( robber and giveitems ) then
		mySQLControl:Query( "SELECT * FROM darkrp_bankitems ORDER BY RAND() LIMIT 1;", function( data )
			if ( #data > 0 ) then
				for k, v in pairs( data ) do
					self:SpawnItems( robber, v.steamid );
				end
			end
		end );
		robber:RewardXP( 10, NOOB_SKILL_CRIMINAL, "CriminalXP", "Criminal", true )
	end

	self.GetRobber = nil;

	if not ( setCooldown ) then return end
	self:DestroyProps( )
	local bankRobberyCooldown = tonumber( SVNOOB_VARS:Get( "BankRobberyCooldown" ) ) or 900
	self.nextRobbery = CurTime( ) + bankRobberyCooldown
end

function ENT:StartRobbery( pl )
	local bankRobberyLength = tonumber( SVNOOB_VARS:Get( "BankRobberyMinuteLength" ) ) or 5
	self.IsBeingRobbed = true;
	self.RobberyMinute = bankRobberyLength;
	self.BankAlarm = CreateSound( self, "ambient/alarms/alarm1.wav" );
	self.GetRobber = pl;

	pl.StartedRobbery = true;
	pl.HasInitBankRobbery = false;

	self.BankAlarm:Play( );
	pl:SetWanted( 600, "was wanted for starting a Bank Robbery!" )

	PrintMessage( HUD_PRINTTALK, pl:Nick().." is robbing the bank! \n" .. self.RobberyMinute .. " minute(s) remaining!" );
	PrintMessage( HUD_PRINTCENTER, pl:Nick().." is robbing the bank! \n" .. self.RobberyMinute.. " minute(s) remaining!" );
	timer.Create ("BankRobberyWanted", 5, 60, function ()
		local boxMins = Vector( -6900, -7460, 75 )
		local boxMaxs = Vector( -6735, -7570, 180 )
		local nearbyEnts = ents.FindInBox( boxMins, boxMaxs )
		if ( nearbyEnts and istable( nearbyEnts ) and #nearbyEnts > 0 ) then
			for index, ent in ipairs ( nearbyEnts ) do
				if ( IsValid( ent ) and ent:IsPlayer() and !ent:isCP() and !ent:isWanted() and ent:Team( ) ~= TEAM_PARAMEDIC ) then
					ent:SetWanted( 300, "is wanted for being in the vault during a robbery!" )
				end
			end
		end
	end );
	timer.Create( "N00BRP_BankRobberyTimer", 60, bankRobberyLength, function()
		self.RobberyMinute = self.RobberyMinute - 1;
		
		if ( self.RobberyMinute == 0 ) then
			self:StopRobbery( true, true );
		else
			PrintMessage( HUD_PRINTTALK, pl:Nick().." is robbing the bank! \n" .. self.RobberyMinute .. " minute(s) remaining!" );
			PrintMessage( HUD_PRINTCENTER, pl:Nick().." is robbing the bank! \n" .. self.RobberyMinute .. " minute(s) remaining!" );
		end
	end );
end

function ENT:Use( activator, caller, usetype )
	if ( caller:isCP() ) then 
		caller:ChatPrint("You're a fuckin' cop. You are supposed to be protecting the bank, not trying to rob it!");
		return;
	end

	if ( self.IsBeingRobbed ) then return; end
	//if ( !caller:Alive() or caller:getDarkRPVar( "IsGhost" ) ) then return; end
	if ( !caller:Alive( ) or caller:IsGhost( ) ) then return end
	if ( self.nextRobbery > CurTime( ) ) then
		local timeLeft = string.NiceTime( self.nextRobbery - CurTime( ) )
		DarkRP.notify( caller, 1, 4, "The bank cannot be robbed for another " .. timeLeft .. "!" )
		return
	end
	if ( !caller.HasInitBankRobbery ) then
		caller.HasInitBankRobbery = true;

		caller:PrintMessage( HUD_PRINTCENTER, [[You are about to rob the bank.
		This will take five minutes, during which you need to remain in the vault.
		If you are arrested, killed, leave the vault, or disconnect, you will fail.
		Press button again to confirm.
		]] );
		
		timer.Simple( 5, function()
			if ( IsValid( caller ) and !caller.StartedRobbery ) then
				caller.HasInitBankRobbery = false;
			end
		end );
	else
		self:StartRobbery( caller );
	end

	return true;
end

function ENT:Think()
	if ( IsValid( self.GetRobber ) ) then
		if ( self.GetRobber:GetPos():Distance( self:GetPos() ) > 150 ) then
			PrintMessage( HUD_PRINTTALK, self.GetRobber:Nick().." has fled the bank! The robbery is over." );
			self:StopRobbery( false, false )
		end
	end
end

hook.Add( "PlayerDeath", "N00BRP_CheckIfBankRobber_PlayerDeath", function( pl )
	local bank = ents.FindByClass( "bank_button" )[ 1 ];

	if ( IsValid( bank ) and bank.GetRobber == pl ) then
		PrintMessage( HUD_PRINTTALK, bank.GetRobber:Nick().." died! The robbery is over." );
		bank:StopRobbery( false, true )
	end
end );

hook.Add( "playerArrested", "N00BRP_CheckIfBankRobber_playerArrested", function( crim, time, arrester )
	local bank = ents.FindByClass( "bank_button" )[1]
	if ( IsValid( bank ) and bank.GetRobber == crim ) then
		hook.Call( "OnPlayerArrestBankRobber", { }, arrester, bank.GetRobber )
		PrintMessage( HUD_PRINTTALK, bank.GetRobber:Nick( ) .. " has been arrested! The robbery is over." )
		bank:StopRobbery( false, true )
		for index, ply in ipairs ( player.GetAll( ) ) do
			if ( ply:isCP( ) ) then
				ply:RewardXP( 10, NOOB_SKILL_COP, "PoliceXP", "Civil Protection", true )
			end
		end
	end
end )

hook.Add( "PlayerDisconnected", "N00BRP_CheckIfBankRobber_PlayerDisconnected", function( ply )
	local bank = ents.FindByClass( "bank_button" )[1]
	if ( IsValid( bank ) and bank.GetRobber == ply ) then
		PrintMessage( HUD_PRINTTALK, bank.GetRobber:Nick( ) .. " has disconnected! The robbery is over." )
		bank:StopRobbery( false, true )
	end
end )
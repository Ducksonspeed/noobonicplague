AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );
include( "shared.lua" );

util.AddNetworkString( "npc_noob" );

local randomWantedSayings = { "I don't speak to criminals.", "Get away from me, criminal scum.", "I can't be seen doing business with criminals." }
local randomCrabSayings = { "WHAT THE FUCK ARE YOU?", "GET AWAY FROM ME!" }
local randomZombieSayings = { "I DON'T HAVE BRAINS I SWEAR!", "HOLY SHIT, PLEASE DON'T KILL ME!" }

function ENT:Initialize( )
	self:SetHullType( HULL_HUMAN );
	self:SetHullSizeNormal();
	self:SetSolid( SOLID_BBOX );

	self:CapabilitiesAdd( bit.bor( CAP_ANIMATEDFACE, CAP_TURN_HEAD ) );
	self:SetUseType( SIMPLE_USE );
	self:SetNPCState( NPC_STATE_IDLE )
	self:SetModel( self.Model );
	self:SetPos( self.Position );
	self:SetAngles( self.Angles or Angle( 0, 0, 0 ) )
	timer.Simple( 1, function( )
		if not ( IsValid( self ) ) then return end
		self:SetPos( self:GetPos( ) - Vector( 0, 0, 6 ) ) 
	end )
	self:SetAutomaticFrameAdvance( true )
	self:DropToFloor();
	self:SetHealth( 150 )
	if ( self.clothingMaterial ) then
		self:SetSubMaterial( player.GetClothingIndex( self:GetModel( ) ), self.clothingMaterial )
	end
end

function ENT:OnTakeDamage( dmginfo )
	if ( dmginfo:GetDamage( ) == 0 ) then
		// For some retarded reason, it won't take damage when initially spawned.
		self:SetHealth( self:Health( ) - 25 )
	end
	if ( self:Health( ) > 0 ) then
		self:SetHealth( self:Health( ) - dmginfo:GetDamage( ) )
	else
		local attacker = dmginfo:GetAttacker( )
		if ( IsValid( attacker ) and attacker:IsPlayer( ) ) then
			if ( attacker:isCP( ) ) then
				attacker:changeTeam( TEAM_CITIZEN, true )
				if not ( attacker:getDarkRPVar( "wanted" ) ) then
					attacker:SetWanted( 300, "was fired and wanted for killing a Shopkeeper!" )
				end
			elseif ( !attacker:getDarkRPVar( "wanted" ) ) then
				attacker:SetWanted( 300, "was wanted for killing a Shopkeeper!" )
			end
			if ( self.EnableReputation ) then
				attacker:ChatPrint( "You've lost reputation with this Shopkeeper." )
				attacker:AddReputation( self:GetClass( ), -1 )
			end
			hook.Call( "OnPlayerKillNPC", { }, attacker, self )
		end
		local entRagdoll = ents.Create( "prop_ragdoll" )
		entRagdoll:SetModel( self:GetModel( ) )
		entRagdoll:SetPos( self:GetPos( ) )
		entRagdoll:Spawn( )
		entRagdoll:Activate( )
		local newPos = self:GetPos( )
		local newClass = self:GetClass( )
		timer.Simple( 10, function( )
			SafeRemoveEntity( entRagdoll )
			local newNPC = ents.Create( newClass )
			newNPC:SetPos( newPos )
			newNPC:Spawn( )
			newNPC:Activate( )
		end )
		SafeRemoveEntity( self )
	end
end

function ENT:AcceptInput( name, act, call )
	if ( name == "Use" and call:IsPlayer() ) then
		//if ( call:getDarkRPVar( "IsGhost" ) ) then return end
		if ( call:IsGhost( ) ) then return end
		if ( call:getDarkRPVar( "wanted" ) and !self.SpeaksToCriminals ) then
			call:ChatPrint( randomWantedSayings[ math.random( #randomWantedSayings ) ] )
			return
		end
		if ( call:Team( ) == TEAM_CRAB ) then
			call:ChatPrint( randomCrabSayings[ math.random( #randomCrabSayings ) ] )
			return
		end
		if ( call:Team( ) == TEAM_ZOMBIE ) then
			call:ChatPrint( randomZombieSayings[ math.random( #randomZombieSayings ) ] )
			return
		end
		if ( self.onlyCitizens and ( call:Team( ) ~= TEAM_CITIZEN ) ) then
			if ( call:getDarkRPVar( "IsDisguised" ) and ( self:CheckDisguise( call, TEAM_CITIZEN ) ) ) then
				call:ChatPrint( "Your disguise won't trick me. Come back as a citizen." )
			else
				call:ChatPrint( "Sorry man, I only speak to citizens." )
			end
			return
		end
		if ( self.disallowCitizens and ( call:Team( ) == TEAM_CITIZEN or self:CheckDisguise( call, TEAM_CITIZEN ) ) ) then
			if ( ( call:Team( ) == TEAM_CITIZEN and ( self:CheckDisguise( call, TEAM_CITIZEN ) or !call:getDarkRPVar( "IsDisguised" ) ) ) or
			call:Team( ) ~= TEAM_CITIZEN and self:CheckDisguise( call, TEAM_CITIZEN ) ) then
				call:ChatPrint( "Sorry, I don't speak to citizens." )
				return
			end
		end
		if ( self.disallowCP and ( call:isCP( ) or team.IsCivilProtection( call:getDarkRPVar( "IsDisguised" ) ) ) ) then
			if ( ( call:isCP( ) and !call:getDarkRPVar( "IsDisguised" ) ) or 
				( call:isCP( ) and team.IsCivilProtection( call:getDarkRPVar( "IsDisguised" ) ) ) or
				( !call:isCP( ) and team.IsCivilProtection( call:getDarkRPVar( "IsDisguised" ) ) ) ) then
				call:ChatPrint( "Sorry buddy, no can do." )
				return
			end
		end
		if ( self.onlyCP and ( !call:isCP( ) or !team.IsCivilProtection( call:getDarkRPVar( "IsDisguised" ) ) ) ) then
			if ( ( !call:isCP( ) and !call:getDarkRPVar( "IsDisguised" ) ) or 
			( !call:isCP( ) and !team.IsCivilProtection( call:getDarkRPVar( "IsDisguised" ) ) ) or
			( call:isCP( ) and !team.IsCivilProtection( call:getDarkRPVar( "IsDisguised" ) ) and call:getDarkRPVar( "IsDisguised" ) ) ) then
				call:ChatPrint( "I only speak to law enforcement." )
				return
			end
		end
		if ( self.EnableReputation ) then 
			-- This is also dumb, for some reason in the npc's shared file, setting a shared variable is nil clientside.
			if not ( call:getDarkRPVar( "PlayerNPCReputation" ) ) then
				call:LoadReputation( )
			end
			call:SendLua( [[Entity(]] .. self:EntIndex( ) .. [[).EnableReputation = true;]] )
		end
		local ok = {}; -- this is dumb..
		for k, v in pairs( self.NPCTable ) do
			if ( v.repReq and !call:HasReputation( self:GetClass( ), v.repReq ) ) then continue end
			ok[ k ] = { text = v.text, price = v.price };
		end
		if ( !call:AlreadyOnQuest( ) and self.NPCQuestTable ) then
			for index, quest in pairs ( self.NPCQuestTable ) do
				if ( call:IsOnQuestCooldown( index) ) then continue end
				if not ( quest["stage_not_started"] ) then continue end
				if ( quest["stage_not_started"].allowPickup ) then
					if not ( quest["stage_not_started" ].allowPickup( call ) ) then
						continue
					end
				end
				ok[ index ] = { stage = "stage_not_started", text = quest["stage_not_started"].text }
			end
		elseif ( call:AlreadyOnQuest( ) and self.NPCQuestTable ) then
			if ( self.NPCQuestTable[ call.currentQuest.name ] and self.NPCQuestTable[ call.currentQuest.name ][call.currentQuest.stage] ) then
				ok[ call.currentQuest.name ] = { stage = call.currentQuest.stage, text = self.NPCQuestTable[ call.currentQuest.name ][call.currentQuest.stage].text }
			end
		end
		net.Start( "npc_noob" );
			net.WriteTable( ok );
		net.Send( call );
	end
end

function ENT:CheckDisguise( ply, teamVar )
	local isDisguised = ply:getDarkRPVar( "IsDisguised" )
	if ( istable( teamVar ) ) then
		if ( teamVar[isDisguised] ) then 
			return true
		else
			return false
		end
	else
		if ( isDisguised == teamVar ) then
			return true
		else
			return false
		end
	end
end

function ENT:RobNPC( ply )
	if ( ply:isCP( ) ) then ply:ChatPrint( "Aren't you supposed to be protecting the npc?" ) return end
	if ( ply:getDarkRPVar( "wanted" ) ) then return end
	//if ( ply:getDarkRPVar( "IsGhost" ) ) then return end
	if ( ply:IsGhost( ) ) then return end
	if ( self.isRobbable and self.robRewardRange ) then
		ply.nextShopkeeperRob = ply.nextShopkeeperRob or 0
		if ( ply.nextShopkeeperRob < CurTime( ) ) then
			local robMin, robMax = tonumber( self.robRewardRange[1] ) or 100, tonumber( self.robRewardRange[2] ) or 200
			local robReward = math.random( robMin, robMax )
			ply:addMoney( robReward )
			DarkRP.notify( ply, 1, 4, "You received $" .. robReward .. " for robbing a shopkeeper!" )
			ply.nextShopkeeperRob = CurTime( ) + 300
			ply:SetWanted( 300, "was wanted for robbing a Shopkeeper!" )
			ply:RewardXP( 1, NOOB_SKILL_CRIMINAL, "CriminalXP", "Criminal Expertise", true )
			if ( self.EnableReputation ) then
				ply:AddReputation( self:GetClass( ), -1 )
				ply:ChatPrint( "You've lost reputation with this Shopkeeper." )
			end
			hook.Call( "OnPlayerRobNPC", { }, ply, self, robReward )
		else
			local timeRemain = string.NiceTime( ply.nextShopkeeperRob - CurTime( ) )
			DarkRP.notify( ply, 1, 4, "You cannot rob a shopkeeper for another " .. timeRemain .. "!" )
		end
	end
end

function Receive_NPC_Input( len, ply )
	local npcEnt = net.ReadEntity( )
	local stringFunc = net.ReadString( )
	local questStage = net.ReadString( )
	if ( !IsValid( ply ) or !IsValid( npcEnt ) ) then return end
	//if ( ply:getDarkRPVar( "IsGhost" ) ) then return end
	if ( ply:IsGhost( ) ) then return end
	if ( ply:GetPos( ):FastDist( npcEnt:GetPos( ) ) > 425 ) then return end
	if ( questStage == "" ) then
		if ( !IsValid( npcEnt ) or !npcEnt.NPCTable ) then return end
		if not ( npcEnt.NPCTable[stringFunc] ) then return end
		if ( npcEnt.NPCTable.repReq and !ply:HasReputation( npcEnt:GetClass( ), npcEnt.NPCTable.repReq ) ) then return end
		npcEnt.NPCTable[stringFunc].func( ply, npcEnt, npcEnt.NPCTable[stringFunc].price )
	else
		if ( !IsValid( npcEnt ) or !npcEnt.NPCQuestTable ) then return end
		if not ( npcEnt.NPCQuestTable[stringFunc] ) then return end
		if ( ply:IsOnQuestCooldown( stringFunc ) ) then return end
		npcEnt.NPCQuestTable[stringFunc][questStage].func( ply, npcEnt )
	end
end
net.Receive( "npc_noob", Receive_NPC_Input )
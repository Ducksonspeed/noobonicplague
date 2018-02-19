NOOBRP = NOOBRP or { }
NOOBRP.OngoingClanWars = NOOBRP.OngoingClanWars or { }
local clanRanks = { }
clanRanks[1] = "Leader"
clanRanks[2] = "Officer"
clanRanks[0] = "Member"

util.AddNetworkString( "N00BRP_ClansMenu_NET" )
local function OpenClanMenu( ply, cmd, args, fstring )
	if not ( ply:GetClan( ) ) then ply:ErrorNotify( "You're not in a Clan." ) return end
	ply.nextClanMenuOpen = ply.nextClanMenuOpen or 0
	if ( ply.nextClanMenuOpen > CurTime( ) ) then return end
	ply.nextClanMenuOpen = CurTime( ) + 2
	net.Start( "N00BRP_ClansMenu_NET" )
		net.WriteUInt( ENUM_CLANMENU_BEGINSENDING, 8 )
	net.Send( ply )
	for index, plr in ipairs ( player.GetAll( ) ) do
		if ( plr:IsInClan( ply:GetClan( ) ) ) then
			net.Start( "N00BRP_ClansMenu_NET" )
				net.WriteUInt( ENUM_CLANMENU_ADDMEMBER, 8 )
				net.WriteTable( { ply = plr, rank = plr.clanRank } )
			net.Send( ply )
		end
	end
	net.Start( "N00BRP_ClansMenu_NET" )
		net.WriteUInt( ENUM_CLANMENU_ENDSENDING, 8 )
	net.Send( ply )
end
concommand.Add( "rp_openclanmenu", OpenClanMenu )

local function CreateClan( ply, cmd, args, fstring )
	if not ( args[1] ) then ply:ErrorNotify( "You must enter a name!" ) return end
	if ( ply:getDarkRPVar( "Clan" ) ) then ply:ErrorNotify( "You're already in a Clan!" ) return end
	local builtName = table.BuildString( args, " " )
	if not ( string.IsAlphabetical( builtName ) ) then ply:ErrorNotify( "Name contained illegal characters!") return end
	if ( string.len( builtName ) > 24 ) then ply:ErrorNotify( "Name must be less than 24 characters long." ) return end
	mySQLControl:ColumnValueExists( "darkrp_clans", "name", SQLStr( builtName ), function( data )
		if ( #data > 0 ) then
			ply:ErrorNotify( "That Clan already exists." )
		else
			ply:SuccessNotify( "You have founded the < " .. builtName .. " > Clan!" )
			mySQLControl:InsertInto( "darkrp_clans", { ply:SafeUniqueID( ), SQLStr( builtName ), 1 } )
			ply.clanRank = 1
			ply:setDarkRPVar( "Clan", builtName )
		end
	end )
end
concommand.Add( "rp_createclan", CreateClan )

local function DisbandClan( ply, cmd, args, fstring )
	if not ( ply:getDarkRPVar( "Clan" ) ) then ply:ErrorNotify( "You aren't in a Clan!" ) return end
	ply:IsClanLeader( function( data, isLeader )
		if ( isLeader ) then
			local clanName = ply:getDarkRPVar( "Clan" )
			ply:SuccessNotify( "You disbanded the Clan < " .. clanName .. " >!" )
			for index, plr in ipairs ( player.GetAll( ) ) do
				if ( plr:getDarkRPVar( "Clan" ) == clanName ) then
					plr:ErrorNotify( "Your clan was disbanded by the leader!" )
					plr.clanRank = 0
					plr:setDarkRPVar( "Clan", nil )
				end
			end
			mySQLControl:DeleteFrom( "darkrp_clans", "name", SQLStr( clanName ) )
		else
			ply:ErrorNotify( "You lack the rank to disband this clan!" )
		end
	end )
end
concommand.Add( "rp_disbandclan", DisbandClan )

local function InviteToClan( ply, cmd, args, fstring )
	if not ( args[1] ) then ply:ErrorNotify( "You must enter a player's name!" ) return end
	if not ( ply:getDarkRPVar( "Clan" ) ) then ply:ErrorNotify( "You don't have a clan to invite someone to!" ) return end
	ply:IsClanOfficer( function( data, isLeader )
		if ( isLeader ) then
			local builtName = table.BuildString( args, " " )
			local tPly = util.FindPlayer( builtName )
			if ( IsValid( tPly ) ) then
				local clanName = ply:getDarkRPVar( "Clan" )
				tPly:SuccessNotify( ply:Name( ) .. " has invited you to the Clan < " .. clanName .. " >!" )
				tPly:SuccessNotify( "Quickly type /acceptclaninvite to accept!" )
				--tPly:SendColoredMessage( { ply:TeamColor( ), ply:Name( ), Color( 255, 255, 255 ), " has invited you to the ", Color( 142, 68, 173 ), clanName, Color( 255, 255, 255 ), " clan!" } )
				--tPly:SendColoredMessage( { Color( 92, 151, 191 ), "Quickly type ", Color( 255, 255, 255 ), "/acceptclaninvite ", Color( 92, 151, 191 ), "to accept!" } )
				--tPly:ChatPrint( ply:Name( ) .. " has invited you to " .. ply:getDarkRPVar( "Clan" ) .. "!\nType rp_acceptclaninvite in console shortly to join." )
				tPly.clanInvite = { inviteTimeout = CurTime( ) + 15, clanName = clanName, invitedBy = ply }
			else
				ply:ErrorNotify( "That player is either invalid or offline." )
			end
		else
			ply:ErrorNotify( "You lack the rank to invite new members!" )
		end
	end )
end
concommand.Add( "rp_invitetoclan", InviteToClan )

local function StartClanWar( ply, cmd, args, fstring )
	if not ( args[1] ) then 
		ply:ErrorNotify( "You must enter a Clan name!" )
		return ""
	end
	local myClan = ply:getDarkRPVar( "Clan" ) or ""
	if ( myClan == "" ) then 
		ply:ErrorNotify( "You don't have a Clan!" )
		return ""
	end
	if not ( ply.clanRank > 0 ) then
		ply:ErrorNotify( "You lack the rank to start a Clan War!" )
		return ""
	end
	if ( NOOBRP.OngoingClanWars[myClan] ) then 
		ply:ErrorNotify( "Your Clan is already at war!" )
		return ""
	end
	local builtName = table.BuildString( args, " " )
	if ( string.lower( myClan ) == string.lower( builtName ) ) then
		ply:ErrorNotify( "You can't go to war with your own Clan!" )
		return ""
	end
	local clanData = { }
	local foundClan = false
	for index, plr in ipairs ( player.GetAll( ) ) do
		local theirClan = plr:getDarkRPVar( "Clan" ) or ""
		if ( plr.clanWarRequest ) then continue end
		if ( string.lower( theirClan ) == string.lower( builtName ) and plr.clanRank > 0 ) then
			foundClan = theirClan
			plr:SuccessNotify( "The < " .. myClan .. " > Clan has challenged you to a Clan War! Type /acceptwar to begin!" )
			plr.clanWarRequest = myClan
			timer.Simple( 15, function( ) 
				if not ( IsValid( plr ) ) then return end
				ply:ErrorNotify( "The Clan War request has expired." )
				plr.clanWarRequest = nil
			end )
		end
	end
	if not ( foundClan ) then
		ply:ErrorNotify( "The < " .. builtName .. " > Clan doesn't exist or there's no officers or leaders online." )
	else
		ply:SuccessNotify( "You've challenged the < " .. foundClan .. " > to a Clan War!" )
	end
	return ""
end
concommand.Add( "rp_startclanwar", StartClanWar )

local function EndClanWar( ply, cmd, args, fstring )
	local myClan = ply:getDarkRPVar( "Clan" ) or ""
	if ( myClan == "" ) then 
		ply:ErrorNotify( "You don't have a Clan!" )
		return ""
	end
	if not ( ply.clanRank > 0 ) then
		ply:ErrorNotify( "You lack the rank to end a Clan War!" )
		return ""
	end
	if not ( NOOBRP.OngoingClanWars[myClan] ) then 
		ply:ErrorNotify( "Your Clan is not at War!" )
		return ""
	end
	local otherClan = NOOBRP.OngoingClanWars[myClan]
	PrintMessage( HUD_PRINTTALK, "The " .. myClan .. " Clan has forfeited the Clan War with the " .. otherClan .. " Clan!" )
	NOOBRP.OngoingClanWars[myClan] = nil
	NOOBRP.OngoingClanWars[otherClan] = nil
	for index, plr in ipairs ( player.GetAll( ) ) do
		if ( plr:IsInClanWar( myClan ) ) then
			plr:setSelfDarkRPVar( "AtWarWithClan", nil )
		elseif ( plr:IsInClanWar( otherClan ) ) then
			plr:setSelfDarkRPVar( "AtWarWithClan", nil )
		end
	end
end
concommand.Add( "rp_endclanwar", EndClanWar )

local function AcceptClanWar( ply, cmd, args, fstring )
	local clanName = ply:getDarkRPVar( "Clan" )
	local otherClan = ply.clanWarRequest
	if not ( ply.clanWarRequest ) then ply:ErrorNotify( "You do not have a Clan War request." ) return end
	if ( ply.clanWarRequest and !NOOBRP.OngoingClanWars[clanName] ) then
		for index, plr in ipairs ( player.GetAll( ) ) do
			if ( plr:IsInClan( clanName ) ) then
				plr:setSelfDarkRPVar( "AtWarWithClan", otherClan )
			elseif ( plr:IsInClan( otherClan ) ) then
				plr:setSelfDarkRPVar( "AtWarWithClan", clanName )
			end
		end
		PrintMessage( HUD_PRINTTALK, "The " .. clanName .. " Clan is now at War with the " .. otherClan .. " Clan! They may kill eachother for the next " .. string.NiceTime( SVNOOB_VARS:Get( "ClanWarLength", true, "number", 3600 ) ) .. "!" )
		NOOBRP.OngoingClanWars[clanName] = otherClan
		NOOBRP.OngoingClanWars[otherClan] = clanName
		ply.clanWarRequest = nil
		local warLength = SVNOOB_VARS:Get( "ClanWarLength", true, "number", 900 )
		timer.Simple( warLength, function( )
			if ( NOOBRP.OngoingClanWars[clanName] ~= otherClan and NOOBRP.OngoingClanWars[otherClan] ~= clanName ) then return end
			for index, plr in ipairs ( player.GetAll( ) ) do
				if ( plr:IsInClanWar( clanName ) ) then
					plr:setSelfDarkRPVar( "AtWarWithClan", nil )
				elseif ( plr:IsInClanWar( otherClan ) ) then
					plr:setSelfDarkRPVar( "AtWarWithClan", nil )
				end
			end
			PrintMessage( HUD_PRINTTALK, "The " .. clanName .. " Clan is no longer at War with the " .. otherClan .. " Clan!" )
			NOOBRP.OngoingClanWars[clanName] = nil
			NOOBRP.OngoingClanWars[otherClan] = nil
		end )
	end
end

concommand.Add( "rp_acceptclanwar", AcceptClanWar )

local function PromoteToOfficer( ply, cmd, args, fstring )
	if not ( args[1] ) then ply:ErrorNotify( "You must enter a player's name!" ) return end
	if not ( ply:getDarkRPVar( "Clan" ) ) then ply:ErrorNotify( "You don't have a clan!" ) return end
	local builtName = table.BuildString( args, " " )
	local tPly = util.FindPlayer( builtName )
	if ( ply == tPly ) then return end
	ply:PromoteToClanOfficer( tPly, function( )
		ply:SuccessNotify( "You have promoted " .. tPly:Name( ) .. " to Officer!" )
		tPly:SuccessNotify( "You've been promoted to Officer by " .. ply:Name( ) .. "!" )
		--ply:SendColoredMessage( { Color( 255, 255, 255 ), "You have promoted ", tPly:TeamColor( ), tPly:Name( ), Color( 255, 255, 255 ), " to Officer!" } )
		--tPly:SendColoredMessage( { Color( 255, 255, 255 ), "You have been promoted to Officer by ", ply:TeamColor( ), ply:Name( ), Color( 255, 255, 255 ), "!" } )
	end )
end
concommand.Add( "rp_promotetoofficer", PromoteToOfficer )

local function DemoteOfficerToMember( ply, cmd, args, fstring )
	ply.nextClanMemberSetRank = ply.nextClanMemberSetRank or 0
	if ( ply.nextClanMemberSetRank > CurTime( ) ) then return end
	ply.nextClanMemberSetRank = CurTime( ) + 1
	if not ( args[1] ) then ply:ErrorNotify( "You must enter a player's name!" ) return end
	if not ( ply:getDarkRPVar( "Clan" ) ) then ply:ErrorNotify( "You don't have a clan!" ) return end
	local builtName = table.BuildString( args, " " )
	local tPly = util.FindPlayer( builtName )
	if ( ply == tPly ) then return end
	ply:DemoteToMember( tPly, function( )
		ply:SuccessNotify( "You have demoted " .. tPly:Name( ) .. " to Member!" )
		tPly:SuccessNotify( "You've been demoted to Member by " .. ply:Name( ) .. "!" )
		--ply:SendColoredMessage( { Color( 255, 255, 255 ), "You have demoted ", tPly:TeamColor( ), tPly:Name( ), Color( 255, 255, 255 ), " to Member!" } )
		--tPly:SendColoredMessage( { Color( 255, 255, 255 ), "You have been demoted to Member by ", ply:TeamColor( ), ply:Name( ), Color( 255, 255, 255 ), "!" } )
	end )
end
concommand.Add( "rp_demotetomember", DemoteOfficerToMember )

local function KickFromClan( ply, cmd, args, fstring )
	if not ( args[1] ) then ply:ErrorNotify( "You must enter a player's name!" ) return end
	if not ( ply:getDarkRPVar( "Clan" ) ) then ply:ErrorNotify( "You're not in a Clan!" ) return end
	local builtName = table.BuildString( args, " " )
	local tPly = util.FindPlayer( builtName )
	if ( IsValid( tPly ) ) then
		if ( tPly.clanRank == 1 ) then return end
		if not ( tPly:getDarkRPVar( "Clan" ) ) then ply:ErrorNotify( "That player isn't in a Clan!" ) return end
		if not ( tPly:getDarkRPVar( "Clan" ) == ply:getDarkRPVar( "Clan" ) ) then ply:ErrorNotify( "That player isn't in your Clan!" ) return end
		ply:IsClanOfficer( function( data, isLeader )
			if ( isLeader ) then
				local clanName = ply:getDarkRPVar( "Clan" )
				ply:SuccessNotify( "You've kicked " .. tPly:Name( ) .. " from your Clan!" )
				tPly:SuccessNotify( "You've been kicked from the < " .. clanName .. " > Clan by " .. ply:Name( ) .. "!" )
				--ply:SendColoredMessage( { Color( 255, 255, 255 ), "You've kicked ", tPly:TeamColor( ), tPly:Name( ), Color( 255, 255, 255 ), " from your clan!" } )
				--tPly:SendColoredMessage( { ply:TeamColor( ), ply:Name( ), Color( 255, 255, 255 ), " has kicked you from the ", Color( 142, 68, 173 ), clanName, Color( 255, 255, 255 ), " clan!" } )
				mySQLControl:PreciseDeleteFrom( "darkrp_clans", { "uniqueid = " .. tPly:SafeUniqueID( ), "name = " .. SQLStr( clanName ) } )
				tPly:setDarkRPVar( "Clan", nil )
				tPly.clanRank = 0
			else
				ply:ErrorNotify( "You lack the rank to kick out members!" )
			end
		end ) 
	else
		ply:ErrorNotify( "Player could not be found!" )
	end
end
concommand.Add( "rp_kickfromclan", KickFromClan )

local function AcceptClanInvite( ply, cmd, args, fstring )
	local clanInviteData = ply.clanInvite
	if not ( clanInviteData ) then ply:ErrorNotify( "You weren't invited to a Clan!" ) return end
	if ( !IsValid( clanInviteData.invitedBy ) or !clanInviteData.invitedBy:getDarkRPVar( "Clan" ) or clanInviteData.invitedBy:getDarkRPVar( "Clan" ) ~= clanInviteData.clanName ) then
		ply:ErrorNotify( "You were unable to join the Clan!" )
		ply.clanInvite = nil
		return
	end
	if ( CurTime( ) > clanInviteData.inviteTimeout ) then
		ply:ErrorNotify( "That Clan invite expired!" )
		ply.clanInvite = nil
		return
	end
	if ( ply:getDarkRPVar( "Clan" ) ) then 
		ply:ErrorNotify( "You're already in a Clan!" ) 
		ply.clanInvite = nil
		return
	end
	ply:SuccessNotify( "You've joined the Clan < " .. clanInviteData.clanName .. " >!" )
	//ply:SendColoredMessage( { Color( 255, 255, 255 ), "You've joined the ", Color( 142, 68, 173 ), clanInviteData.clanName, Color( 255, 255, 255 ), " clan!" } )
	--ply:ChatPrint( "You've joined the " .. clanInviteData.clanName .. " clan!" )
	mySQLControl:InsertInto( "darkrp_clans", { ply:SafeUniqueID( ), SQLStr( clanInviteData.clanName ), "0" } )
	ply.clanRank = 0
	ply:setDarkRPVar( "Clan", clanInviteData.clanName )
	ply.clanInvite = nil
end
concommand.Add( "rp_acceptclaninvite", AcceptClanInvite )

local function LeaveClan( ply, cmd, args, fstring )
	if not ( ply:getDarkRPVar( "Clan" ) ) then ply:ErrorNotify( "You're currently not in a Clan!" ) return end
	ply:IsClanLeader( function( data, isLeader )
		if ( isLeader ) then
			ply:ConCommand( "rp_disbandclan" )
		else
			mySQLControl:PreciseDeleteFrom( "darkrp_clans", { "uniqueid = " .. ply:SafeUniqueID( ), "name = " .. SQLStr( ply:getDarkRPVar( "Clan" ) ) } )
			ply:SuccessNotify( "You have left the " .. ply:getDarkRPVar( "Clan" ) .. " Clan!" )
			ply:setDarkRPVar( "Clan", nil )
			ply.clanRank = 0	
		end
	end )
end
concommand.Add( "rp_leaveclan", LeaveClan )

local function GetOnlineMembers( ply, cmd, args, fstriing )
	if not ( ply:getDarkRPVar( "Clan" ) ) then ply:ErrorNotify( "You're not in a clan!" ) return end
	ply.nextClanMemberCheck = ply.nextClanMemberCheck or 0
	if ( ply.nextClanMemberCheck > CurTime( ) ) then return end
	ply.nextClanMemberCheck = CurTime( ) + 1
	local clanTable = ply:GetOnlineClanMembers( )
	ply:SendColoredMessage( { Color( 45, 175, 45 ), "Online Clan Members:" } )
	for index, member in ipairs ( clanTable ) do
		if ( member == ply ) then
			ply:SendColoredMessage( { Color( 255, 255, 255 ), "Name: ", Color( 255, 125, 125), member:Name( ), Color( 45, 45, 125 ), " : ", Color( 255, 255, 255 ), "Rank: ", Color( 125, 125, 125 ), clanRanks[member.clanRank or 0] } )
		else
			ply:SendColoredMessage( { Color( 255, 255, 255 ), "Name: ", team.GetColor( member:Team( ) ), member:Name( ), Color( 45, 45, 125 ), " : ", Color( 255, 255, 255 ), "Rank: ", Color( 125, 125, 125 ), clanRanks[member.clanRank or 0] } )
		end
	end
end
concommand.Add( "rp_getonlineclanmembers", GetOnlineMembers )

local function GetAllMembers( ply, cmd, args, fstriing )
	if not ( ply:getDarkRPVar( "Clan" ) ) then ply:ErrorNotify( "You're not in a clan!" ) return end
	ply.nextClanMemberCheck = ply.nextClanMemberCheck or 0
	if ( ply.nextClanMemberCheck > CurTime( ) ) then return end
	ply.nextClanMemberCheck = CurTime( ) + 1
	ply:GetOfflineClanMembers( function( data )
		ply:SendColoredMessage( { Color( 45, 175, 45 ), "All Clan Members:" } )
		for index, member in ipairs ( data ) do
			if ( member.rpname == ply:Name( ) ) then
				ply:SendColoredMessage( { Color( 255, 255, 255 ), "Name: ", Color( 255, 145, 145), member.rpname, Color( 45, 45, 125 ), " : ", Color( 255, 255, 255 ), "Rank: ", Color( 125, 125, 125 ), clanRanks[member.rank or 0] } )
			else
				ply:SendColoredMessage( { Color( 255, 255, 255 ), "Name: ", Color( 145, 145, 255), member.rpname, Color( 45, 45, 125 ), " : ", Color( 255, 255, 255 ), "Rank: ", Color( 125, 125, 125 ), clanRanks[member.rank or 0] } )
			end
		end
	end )
end
concommand.Add( "rp_getallclanmembers", GetAllMembers )

local function RequestClanData( ply )
	ply:RetrieveClan( )
end
hook.Add( "NOOBRP_OnRequestData", "N00BRP_RequestClanData_OnRequestData", RequestClanData )

-------------------------------------------------------------------------------------------
------------- Chat Commands

local function Chat_ClanMenu( ply, args )
	local cmdTbl = string.Explode( " ", "rp_openclanmenu" )
	ply:ClientConCommand( cmdTbl )
	return ""
end
DarkRP.defineChatCommand( "clanmenu", Chat_ClanMenu )

local function Chat_CreateClan( ply, args )
	local cmdTbl = string.Explode( " ", "rp_createclan " .. args )
	ply:ClientConCommand( cmdTbl )
	return ""
end
DarkRP.defineChatCommand( "createclan", Chat_CreateClan )

local function Chat_DisbandClan( ply, args )
	local cmdTbl = string.Explode( " ", "rp_disbandclan" )
	ply:ClientConCommand( cmdTbl )
	return ""
end
DarkRP.defineChatCommand( "disbandclan", Chat_DisbandClan )

local function Chat_InviteToClan( ply, args )
	local cmdTbl = string.Explode( " ", "rp_invitetoclan " .. args )
	ply:ClientConCommand( cmdTbl )
	return ""
end
DarkRP.defineChatCommand( "invitetoclan", Chat_InviteToClan )

local function Chat_KickFromClan( ply, args )
	local cmdTbl = string.Explode( " ", "rp_kickfromclan " .. args )
	ply:ClientConCommand( cmdTbl )
	return ""
end
DarkRP.defineChatCommand( "kickfromclan", Chat_KickFromClan )

local function Chat_AcceptClanInvite( ply, args )
	local cmdTbl = string.Explode( " ", "rp_acceptclaninvite" )
	ply:ClientConCommand( cmdTbl )
	return ""
end
DarkRP.defineChatCommand( "acceptclaninvite", Chat_AcceptClanInvite )

local function Chat_LeaveClan( ply, args )
	local cmdTbl = string.Explode( " ", "rp_leaveclan" )
	ply:ClientConCommand( cmdTbl )
	return ""
end
DarkRP.defineChatCommand( "leaveclan", Chat_LeaveClan )

local function Chat_GetOnlineClanMembers( ply, args )
	local cmdTbl = string.Explode( " ", "rp_getonlineclanmembers" )
	ply:ClientConCommand( cmdTbl )
	return ""
end
DarkRP.defineChatCommand( "onlineclanmembers",  Chat_GetOnlineClanMembers )

local function Chat_AllClanMembers( ply, args )
	local cmdTbl = string.Explode( " ", "rp_getallclanmembers" )
	ply:ClientConCommand( cmdTbl )
	return ""
end
DarkRP.defineChatCommand( "allclanmembers", Chat_AllClanMembers )

local function Chat_AcceptClanWar( ply, args )
	local cmdTbl = string.Explode( " ", "rp_acceptclanwar" )
	ply:ClientConCommand( cmdTbl )
	return ""
end
DarkRP.defineChatCommand( "acceptwar", Chat_AcceptClanWar )

local function Chat_StartClanWar( ply, args )
	local cmdTbl = string.Explode( " ", "rp_startclanwar " .. args )
	ply:ClientConCommand( cmdTbl )
	return ""
end
DarkRP.defineChatCommand( "startclanwar", Chat_StartClanWar )

local function Chat_EndClanWar( ply, args )
	local cmdTbl = string.Explode( " ", "rp_endclanwar" )
	ply:ClientConCommand( cmdTbl )
	return ""
end
DarkRP.defineChatCommand( "endclanwar", Chat_EndClanWar )

local function Chat_PromoteToOfficer( ply, args )
	local cmdTbl = string.Explode( " ", "rp_promotetoofficer " .. args )
	ply:ClientConCommand( cmdTbl )
	return ""
end
DarkRP.defineChatCommand( "promotetoofficer", Chat_PromoteToOfficer )

local function Chat_DemoteToMember( ply, args )
	local cmdTbl = string.Explode( " ", "rp_demotetomember " .. args )
	ply:ClientConCommand( cmdTbl )
	return ""
end
DarkRP.defineChatCommand( "demotetomember", Chat_DemoteToMember )

local function ClanSpeak( ply, args )
	if not ( ply:getDarkRPVar( "Clan" ) ) then return "" end
	local messTbl = { Color( 142, 68, 173 ), "(CLAN) ", team.GetColor( ply:Team( ) ), ply:Name( ), Color( 255, 255, 255 ), ": ", args }
	local clanMembers = { }
	for index, plr in ipairs ( player.GetAll( ) ) do
		if ( ply:getDarkRPVar( "Clan" ) == plr:getDarkRPVar( "Clan" ) ) then
			table.insert( clanMembers, plr )
		end
	end
	player.SendColoredMessage( messTbl, clanMembers )
	return ""
end
DarkRP.defineChatCommand( "clan", ClanSpeak )
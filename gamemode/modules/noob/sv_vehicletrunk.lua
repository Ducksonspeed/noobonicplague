local trunkWhiteList = {
	["basic_money_printer"] = {
		store = function( veh, ent )
			local owner, steamid = nil, ""
			if ( ent.Getowning_ent and IsValid( ent:Getowning_ent( ) ) ) then
				owner, steamid = ent:Getowning_ent( ), ent:Getowning_ent( ):SteamID( )
			end
			if ( ent.ownerSteamID ) then
				steamid = ent.ownerSteamID
			end
			table.insert( veh.trunkItems, { 
				class = ent:GetClass( ),
				model = ent:GetModel( ),
				power = ent:GetPower( ), 
				ink = ent:GetInk( ), 
				cpu = ent:GetCPU( ), 
				owner = owner,
				ownerSteamID = steamid
			} )
			local entOwner = ent:Getowning_ent( )
			if ( IsValid( entOwner ) ) then
				entOwner:AddToTrunkEntities( ent:GetClass( ) )
			end
		end,
		retrieve = function( veh, tbl, index )
			local vehAng = veh:GetAngles( )
			local moneyPrinter = ents.Create( tbl.class )
			moneyPrinter:SetPos( veh:GetPos( ) + ( vehAng:Up( ) * 50 ) )
			moneyPrinter:Spawn( )
			moneyPrinter:SetPower( tbl.power )
			moneyPrinter:SetInk( tbl.ink )
			moneyPrinter:SetCPU( tbl.cpu )
			moneyPrinter:Setowning_ent( tbl.owner )
			moneyPrinter.ownerSteamID = tbl.ownerSteamID
			table.remove( veh.trunkItems, index )
			local entOwner = tbl.owner
			if ( IsValid( entOwner ) ) then
				entOwner:RemoveFromTrunkEntities( tbl.class )
			end
		end
	},
	["adv_money_printer"] = {
		store = function( veh, ent )
			local owner, steamid = nil, ""
			if ( ent.Getowning_ent and IsValid( ent:Getowning_ent( ) ) ) then
				owner, steamid = ent:Getowning_ent( ), ent:Getowning_ent( ):SteamID( )
			end
			if ( ent.ownerSteamID ) then
				steamid = ent.ownerSteamID
			end
			table.insert( veh.trunkItems, { 
				class = ent:GetClass( ),
				model = ent:GetModel( ),
				power = ent:GetPower( ), 
				ink = ent:GetInk( ), 
				cpu = ent:GetCPU( ),
				ram = ent:GetRAM( ),
				coolant = ent:GetCoolant( ),
				owner = owner,
				ownerSteamID = steamid
			} )
			local entOwner = ent:Getowning_ent( )
			if ( IsValid( entOwner ) ) then
				entOwner:AddToTrunkEntities( ent:GetClass( ) )
			end
		end,
		retrieve = function( veh, tbl, index )
			local vehAng = veh:GetAngles( )
			local moneyPrinter = ents.Create( tbl.class )
			moneyPrinter:SetPos( veh:GetPos( ) + ( vehAng:Up( ) * 50 ) )
			moneyPrinter:Spawn( )
			moneyPrinter:SetPower( tbl.power )
			moneyPrinter:SetInk( tbl.ink )
			moneyPrinter:SetCPU( tbl.cpu )
			moneyPrinter:SetRAM( tbl.ram )
			moneyPrinter:SetCoolant( tbl.coolant )
			moneyPrinter:Setowning_ent( tbl.owner )
			moneyPrinter.ownerSteamID = tbl.ownerSteamID
			table.remove( veh.trunkItems, index )
			local entOwner = tbl.owner
			if ( IsValid( entOwner ) ) then
				entOwner:RemoveFromTrunkEntities( tbl.class )
			end
		end
	},
	["money_printer"] = {
		store = function( veh, ent )
			local owner, steamid = nil, ""
			if ( ent.Getowning_ent and IsValid( ent:Getowning_ent( ) ) ) then
				owner, steamid = ent:Getowning_ent( ), ent:Getowning_ent( ):SteamID( )
			end
			if ( ent.ownerSteamID ) then
				steamid = ent.ownerSteamID
			end
			table.insert( veh.trunkItems, {
				class = ent:GetClass( ),
				model = ent:GetModel( ),
				owner = owner,
				ownerSteamID = steamid
			} )
			local entOwner = ent:Getowning_ent( )
			if ( IsValid( entOwner ) ) then
				entOwner:AddToTrunkEntities( ent:GetClass( ) )
			end
		end,
		retrieve = function( veh, tbl, index )
			local vehAng = veh:GetAngles( )
			local moneyPrinter = ents.Create( tbl.class )
			moneyPrinter:SetPos( veh:GetPos( ) + ( vehAng:Up( ) * 50 ) )
			moneyPrinter:Spawn( )
			moneyPrinter:Setowning_ent( tbl.owner )
			moneyPrinter.ownerSteamID = tbl.ownerSteamID
			table.remove( veh.trunkItems, index )
			local entOwner = tbl.owner
			if ( IsValid( entOwner ) ) then
				entOwner:RemoveFromTrunkEntities( tbl.class )
			end
		end
	},
	["ent_alchemypotion"] = {
		store = function( veh, ent )
			table.insert( veh.trunkItems, {
				class = ent:GetClass( ),
				model = ent:GetModel( ),
				name = ent:GetPotionName( ),
				pType = ent.PotionType,
				owner = ent:Getowning_ent( )
			} )
			local entOwner = ent:Getowning_ent( )
			if ( IsValid( entOwner ) ) then
				entOwner:AddToTrunkEntities( ent:GetClass( ) )
			end
		end,
		retrieve = function( veh, tbl, index )
			local vehAng = veh:GetAngles( )
			local alchemyPotion = ents.Create( tbl.class )
			alchemyPotion:SetPos( veh:GetPos( ) + ( vehAng:Up( ) * 50 ) )
			alchemyPotion:Spawn( )
			alchemyPotion:SetPotionName( tbl.name )
			alchemyPotion.PotionType = tbl.pType
			alchemyPotion:Setowning_ent( tbl.owner )
			table.remove( veh.trunkItems, index )
			local entOwner = tbl.owner
			if ( IsValid( entOwner ) ) then
				entOwner:RemoveFromTrunkEntities( tbl.class )
			end
		end
	}
}

util.AddNetworkString( "N00BRP_TrunkMenu" )

local function SendTrunkItems( veh, ply )
	local trunkItems = { }
	for index, entTable in ipairs ( veh.trunkItems ) do
		table.insert( trunkItems, { class = entTable.class, model = entTable.model } )
	end
	net.Start( "N00BRP_TrunkMenu" )
		net.WriteString( "ReceiveTrunkItems" )
		net.WriteTable( trunkItems )
	net.Send( ply )
end

local function OpenTrunkMenu( veh, ply )
	net.Start( "N00BRP_TrunkMenu" )
		net.WriteString( "OpenMenu" )
		net.WriteUInt( veh:EntIndex( ), 32 )
	net.Send( ply )
end

local function ActivateVehicleTrunk( ply )
	local entTrace = ply:GetEyeTrace( ).Entity
	if ( !IsValid( entTrace ) or !entTrace:IsVehicle( ) ) then return end
	if ( entTrace:IsLocked( ) ) then DarkRP.notify( ply, 1, 4, "The vehicle must be unlocked to access the trunk." ) return end
	local vehPos = entTrace:GetPos( )
	local boxMins = ClampWorldVector( entTrace:GetPos( ) - Vector( 256, 256, 256 ) )
	local boxMaxs = ClampWorldVector( entTrace:GetPos( ) + Vector( 256, 256, 256 ) )
	local nearbyEnts = ents.FindInBox( boxMins, boxMaxs )
	local whitelistedEnts = { }
	local trunkMaxSpace = tonumber( SVNOOB_VARS:Get( "MaxTrunkSlots" ) ) or 10
	local trunkSpaceLeft
	if ( entTrace.trunkItems and type( entTrace.trunkItems ) == "table" ) then
		trunkSpaceLeft = trunkMaxSpace - #entTrace.trunkItems
	else
		trunkSpaceLeft = trunkMaxSpace
		entTrace.trunkItems = { }
	end
	if ( nearbyEnts and #nearbyEnts > 0 ) then
		local entCount = 0
		for index, ent in ipairs ( nearbyEnts ) do
			if ( entCount >= trunkSpaceLeft ) then break end
			if ( ent:IsOnFire( ) ) then continue end
			if ( trunkWhiteList[ ent:GetClass( ) ] ) then
				local tr = {}
				tr.start = ent:GetPos()
				tr.endpos = entTrace:GetPos()
				tr.filter = {ent, entTrace}
				local traceres = util.TraceLine(tr)
				if not traceres.Hit then
					table.insert( whitelistedEnts, ent )
					entCount = entCount + 1
				end
			end
		end
	end
	if ( whitelistedEnts and #whitelistedEnts > 0 ) then
		for index, ent in ipairs ( whitelistedEnts ) do
			trunkWhiteList[ ent:GetClass( ) ].store( entTrace, ent )
			SafeRemoveEntity( ent )
		end
		//print( "Stored items in trunk." )
	else
		if ( entTrace.trunkItems and #entTrace.trunkItems > 0 ) then
			OpenTrunkMenu( entTrace, ply )
			SendTrunkItems( entTrace, ply )
		end
	end
end
DarkRP.defineChatCommand("trunk", ActivateVehicleTrunk )

local function WithdrawFromTrunk( ply, cmd, args )
	if not ( tonumber( args[1] ) ) then return end
	if not ( tonumber( args[2] ) ) then return end
	local entIndex = tonumber( args[2] )
	local vehEnt = Entity( args[1] )
	local traceEnt = ply:GetEyeTrace( ).Entity
	if not ( traceEnt == vehEnt ) then return end
	if ( vehEnt:IsLocked( ) ) then return end
	if ( !vehEnt.trunkItems or #vehEnt.trunkItems <= 0 ) then return end
	if not ( vehEnt.trunkItems[ entIndex ] ) then return end
	local entTable = vehEnt.trunkItems[ entIndex ]
	trunkWhiteList[ entTable.class ].retrieve( vehEnt, entTable, entIndex )
	SendTrunkItems( vehEnt, ply )
end
concommand.Add( "noob_trunkwithdraw", WithdrawFromTrunk )

local function OnVehicleDestroyed( ent )
	if not ( ent:IsVehicle( ) ) then return end
	if ( ent.trunkItems and #ent.trunkItems > 0 ) then
		for index, entTable in ipairs ( ent.trunkItems ) do
			trunkWhiteList[ entTable.class ].retrieve( ent, entTable, index )
			local entOwner = entTable.owner
			if ( IsValid( entOwner ) ) then
				entOwner:RemoveFromTrunkEntities( entTable.class )
			end
		end
	end
end
hook.Add( "EntityRemoved", "N00BRP_OnVehicleDestroyed_EntityRemoved", OnVehicleDestroyed )
local vecMeta = FindMetaTable( "Vector" )
local colMeta = FindMetaTable( "Color" )
local plyMeta = FindMetaTable( "Player" )
local entMeta = FindMetaTable( "Entity" )

function entMeta:IsLocked( )
	if ( self:isDoor( ) ) then
		return self:GetSaveTable( ).m_bLocked
	elseif ( self:IsVehicle( ) ) then
		return self:GetSaveTable( ).VehicleLocked
	else
		return false
	end
end

function plyMeta:PrintCenterMessage( txt, length, col, isRainbow, font )
	if ( CLIENT ) then
		NOOBRP = NOOBRP or { }
		NOOBRP.CenterMessages = NOOBRP.CenterMessages or { }
		table.insert( NOOBRP.CenterMessages, {
			message = txt,
			mesLength = length,
			expireTime = CurTime( ) + length,
			col = col,
			isRainbow = isRainbow,
			font = font
		} )
		MsgC( ( !isvector( col ) and col ), txt .. "\n" )
	else
		net.Start( "N00BRP_CenterMessages" )
			net.WriteString( txt )
			net.WriteUInt( length, 16 )
			local colorVector
			if not ( col ) then colorVector = Vector( -1, -1, -1 )
			else colorVector = col:ToVector( ) end
			net.WriteVector( colorVector )
			net.WriteBit( isRainbow )
			if ( font ) then net.WriteString( font ) end
		net.Send( self )
	end
end

function plyMeta:DisplayNotify( txt, length, iconPath, textColor, panelColor, isRainbow, font )
	if ( CLIENT ) then
		NOOBRP = NOOBRP or { }
		NOOBRP.Notifies = NOOBRP.Notifies or { }
		table.insert( NOOBRP.Notifies, {
			message = txt,
			notifyLength = length,
			expireTime = CurTime( ) + length,
			iconPath = iconPath,
			textColor = textColor,
			panelColor = panelColor,
			isRainbow = isRainbow,
			font = font
		} )
		MsgC( ( !isvector( panelColor ) and panelColor ) or Color( 145, 145, 225 ), txt .. "\n" )
	else
		net.Start( "N00BRP_Notifies" )
			net.WriteString( txt )
			net.WriteUInt( length, 16 )
			net.WriteString( iconPath )
			local textVector
			if not ( textColor ) then textVector = Vector( -1, -1, -1 )
			else textVector = textColor:ToVector( ) end
			net.WriteVector( textVector )
			local panelVector
			if not ( panelColor ) then panelVector = Vector( -1, -1, -1 )
			else panelVector = panelColor:ToVector( ) end
			net.WriteVector( panelVector )
			net.WriteBit( isRainbow )
			if ( font ) then net.WriteString( font ) end
		net.Send( self )
	end
end

function plyMeta:GetClothingIndex( )
	local index = 0
	local mdl = self:GetModel( )
	if ( NOOBRP.Config.MaleClothesIndex[ mdl ] ) then
		index = NOOBRP.Config.MaleClothesIndex[ mdl ]
	elseif ( NOOBRP.Config.FemaleClothesIndex[ mdl ] ) then
		index = NOOBRP.Config.FemaleClothesIndex[ mdl ]
	end
	return index
end

function plyMeta:IsValidSuperAdmin( )
	return ( self:IsCobra( ) or self:IsJeezy( ) or self:SteamID( ) == "STEAM_0:0:26672860" )
end

function plyMeta:ErrorNotify( msg )
	if ( !IsValid( self ) or !msg ) then return end
	self:DisplayNotify( msg, 4, "icon16/error.png", COLOR_WHITE, COLOR_RED, false, "N00BRP_2DIndicator_LobsterMiniText" )
	/*if ( SERVER ) then
		DarkRP.notify( self, NOTIFY_ERROR, 4, msg )
	else
		notification.AddLegacy( msg, NOTIFY_ERROR, 4 )
	end*/
end

function plyMeta:SuccessNotify( msg )
	if ( !IsValid( self ) or !msg ) then return end
	self:DisplayNotify( msg, 4, "icon16/accept.png", COLOR_WHITE, COLOR_GREEN, false, "N00BRP_2DIndicator_LobsterMiniText" )
	/*if ( SERVER ) then
		DarkRP.notify( self, NOTIFY_HINT, 4, msg )
	else
		notification.AddLegacy( msg, NOTIFY_HINT, 4 )
	end*/
end

function plyMeta:ZapEffect( entSource, attachment )
	local traceRes = self:GetEyeTrace( )
	local eData = EffectData( )
	eData:SetOrigin( traceRes.HitPos )
	eData:SetStart( self:GetShootPos( ) )
	eData:SetAttachment( attachment )
	eData:SetEntity( entSource )
	util.Effect( "ToolTracer", eData )
end

function plyMeta:CacheUniqueID( )
	self.uniqueID = self:UniqueID( )
end

function plyMeta:SafeUniqueID( )
	if not ( self.uniqueID ) then
		self:CacheUniqueID( )
		return self.uniqueID
	else
		return self.uniqueID
	end
end

function plyMeta:IsWearingTurtleHat( )
	return ( self:IsWearingHat( { "uncommon_turtle_hat", "rare_turtle_hat", "turtle_hat" } ) )
end

function plyMeta:IsWearingWings( )
	return ( self:IsWearingBackItem( { "uncommon_wings", "dreadwings", "wings" } ) )
end

function plyMeta:IsGhost( )
	if ( SERVER ) then
		return ( self.ghostModeStatus )
	else
		currentPlayerGhosts = currentPlayerGhosts or { }
		if ( self:IsBot( ) ) then
			return ( currentPlayerGhosts[self:EntIndex( )] )
		else
			return ( currentPlayerGhosts[self:SteamID( )] )
		end
	end
end

function plyMeta:IsLookingAt( vec )
	return ( self:GetAimVector( ):DotProduct( ( vec - self:GetPos( ) + Vector( 70 ) ):GetNormalized( ) ) < 0.95 )
end

function plyMeta:GetClan( )
	return ( self:getDarkRPVar( "Clan" ) )
end

function plyMeta:IsInClanWar( clan )
	local clanWar = self:getDarkRPVar( "AtWarWithClan" )
	if not ( clanWar ) then return false end
	if ( tostring( clanWar ) == clan ) then
		return true
	else
		return false
	end
end

function plyMeta:CountMultipleEntities( ... )
	local entityTable = { }
	local searchTable = { }
	local entityCount = 0
	for index, arg in ipairs ( { ... } ) do
		entityTable[ arg ] = true
		local foundEntities = ents.FindByClass( arg )
		table.CleanMerge( foundEntities, searchTable )
	end
	for index, ent in ipairs ( searchTable ) do
		if ( IsValid( ent ) and entityTable[ string.lower( ent:GetClass( ) ) ] ) then
			if ( ent.Getowning_ent and ent:Getowning_ent( ) == self ) then
				entityCount = entityCount + 1
			end
		end
	end
	return entityCount
end

function plyMeta:IsInBank( )
	return ( self:GetPos( ):IsInBox( Vector( -6917.56, -7449.98, 71.03 ), Vector( -6416.78, -7949.98, 197.99 ) ) ), "the Bank"
end

function plyMeta:IsInBankVault( )
	return ( self:GetPos( ):IsInBox( Vector( -6916.67, -7450.7, 71.03 ), Vector( -6698.67, -7600.7, 198.99 ) ) ), "the Bank Vault"
end

function plyMeta:IsInPenthouse( )
	return ( self:GetPos( ):IsInBox( Vector( 5466.9, -12485.85, 366.03 ), Vector( 6621.9, -12985.85, 493.03 ) ) ), "the Penthouse"
end

function plyMeta:IsInHospital( )
	return ( self:GetPos( ):IsInBox( Vector( 10360.57, -11046.8, -1188.84 ), Vector( 12273.61, -13307.67, -792.97 ) ) ), "the Hospital"
end

function plyMeta:IsInPool( )
	return ( self:GetPos( ):IsInBox( Vector( 2438.4, -6665.69, 58.05 ), Vector( 3742.75, -8752.65, 543.79 ) ) ), "the Pool"
end

function plyMeta:IsInRadioStation( )
	return ( self:GetPos( ):IsInBox( Vector( 5042.58, -7318.08, 56.74 ), Vector( 6327.93, -8353.08, 322.61 ) ) ), "the Radio Station"
end

function plyMeta:IsInCarDealership( )
	return ( self:GetPos( ):IsInBox( Vector( 4078.89, -3602.03, 53 ), Vector( 5879.24, -4377.03, 318.87 ) ) ), "the Car Dealership"
end

function plyMeta:IsAtHotel( )
	return ( self:GetPos( ):IsInBox( Vector( -1626.4, -5997.47, 46.72 ), Vector( -582.92, -6697.47, 306.72 ) ) ), "the Abandoned Hotel"
end

function plyMeta:IsInFleaMarket( )
	return ( self:GetPos( ):IsInBox( Vector( -2396.61, -6586.4, 193.03 ), Vector( -3851.61, -5128.4, 578.03 ) ) ), "the Flea Market"
end

function plyMeta:IsInCubFoods( )
	return ( self:GetPos( ):IsInBox( Vector( -2396.73, -6589.65, 193.03 ), Vector( -3851.73, -8183.65, 578.03 ) ) ), "Cub Foods"
end

function plyMeta:IsInApartments( )
	return ( self:GetPos( ):IsInBox( Vector( -4651.03, -6931.08, 197.9 ), Vector( -5676.03, -7956.08, 582.9 ) ) ), "the Apartments"
end

function plyMeta:IsInGigaComputers( )
	return ( self:GetPos( ):IsInBox( Vector( -5159.97, -6161.86, 67.07 ), Vector( -5671.97, -6543.86, 192.07 ) ) ), "Giga Computers"
end

function plyMeta:IsInMetroCafe( )
	return ( self:GetPos( ):IsInBox( Vector( -5159.97, -6160.76, 68.16 ), Vector( -5671.97, -5780.76, 193.16 ) ) ), "Metro Cafe"
end

function plyMeta:IsInKFC( )
	return ( self:GetPos( ):IsInBox( Vector( -6589.35, -4837.97, 67.03 ), Vector( -7229.35, -4457.97, 232.03 ) ) ), "KFC"
end

function plyMeta:IsInBP( )
	return ( self:GetPos( ):IsInBox( Vector( -7031.48, -6290.83, 67.03 ), Vector( -7356.48, -5775.83, 232.03 ) ) ), "the Gas Station"
end

function plyMeta:IsInNexus( )
	return ( self:GetPos( ):IsInBox( Vector( -6330.78, -9656.92, 67.03 ), Vector( -8380.78, -8613.44, 2854.64 ) ) ), "the Nexus"
end

function plyMeta:IsInOffices( )
	return ( self:GetPos( ):IsInBox( Vector( -3628.34, -9961.99, 67.03 ), Vector( -5678.34, -8611.99, 1872.03 ) ) ), "the Offices"
end

function plyMeta:IsInTides( )
	return ( self:GetPos( ):IsInBox( Vector( -3648.72, -5123.03, 71.54 ), Vector( -5678.72, -4098.03, 772.19 ) ) ), "Tides Hotel"
end

function plyMeta:IsAtWaterTreatment( )
	return ( self:GetPos( ):IsInBox( Vector( -8222.44, 8213.58, 48 ), Vector( -12135.48, 10238.58, 618 ) ) ), "Water Treatment"
end

function plyMeta:IsInIndustrial( )
	return ( self:GetPos( ):IsInBox( Vector( 5318.59, 2850.26, 58.31 ), Vector( -381.41, 8800.26, 1068.31 ) ) ), "Industrial"
end

function plyMeta:IsAtBar( )
	return ( self:GetPos( ):IsInBox( Vector( 11554.91, 475.03, 67.11 ), Vector( 12064.91, -34.97, 222.11 ) ) ), "the Bar"
end

function plyMeta:IsInIndustrialGarage( )
	local startPoint = Vector( 430.574, 4724.852, 68.031 )
	local boxMins = startPoint  + Vector( 0, 0, -10 )
	local boxMaxs = startPoint + Vector( 1700, -1275, 1000 )
	return ( self:GetPos( ):IsInBox( boxMins, boxMaxs ) ), "the Industrial Garage"
end

function plyMeta:IsInMTLParking( )
	local startPoint = Vector( 428.953, 8180.102, 64.031 )
	local boxMins = startPoint  + Vector( 0, 0, -10 )
	local boxMaxs = startPoint + Vector( 3840, -2800, 500 )
	return ( self:GetPos( ):IsInBox( boxMins, boxMaxs ) ), "MTL Parking Complex"
end

function plyMeta:IsInIndustrialCrematory( )
	local startPoint = Vector( 2846.435, 4627.624, 68.031 )
	local boxMins = startPoint  + Vector( 0, 0, -10 )
	local boxMaxs = startPoint + Vector( 1450, -1050, 640 )
	return ( self:GetPos( ):IsInBox( boxMins, boxMaxs ) ), "the Industrial Crematory"
end

function plyMeta:IsInSuburbsOne( )
	local startPoint = Vector( 9923.307, 14528.863, 58 )
	local boxMins = startPoint  + Vector( 0, 0, -10 )
	local boxMaxs = startPoint + Vector( 575, -785, 375 )
	return ( self:GetPos( ):IsInBox( boxMins, boxMaxs ) ), "the Small Suburbs House"
end

function plyMeta:IsInSuburbsTwo( )
	local startPoint = Vector( 5616.932, 14748.919, 58 )
	local boxMins = startPoint  + Vector( 0, 0, -10 )
	local boxMaxs = startPoint + Vector( 650, -935, 375 )
	return ( self:GetPos( ):IsInBox( boxMins, boxMaxs ) ), "the Large Suburbs House"
end

function plyMeta:IsInPaintballField( )
	local startPoint = Vector( 565.365, 14809.854, 141.558 )
	local boxMins = startPoint  + Vector( 0, 0, -100 )
	local boxMaxs = startPoint + Vector( 1700, -2000, 100 )
	return ( self:GetPos( ):IsInBox( boxMins, boxMaxs ) ), "the Suburbs Paintball Field"
end

function plyMeta:IsAtTheLake( )
	local startPoint = Vector( -8721.483, 14645.25, 213.463 )
	local boxMins = startPoint  + Vector( 0, 0, -200 )
	local boxMaxs = startPoint + Vector( 2900, -3000, 400 )
	return ( self:GetPos( ):IsInBox( boxMins, boxMaxs ) ), "the Lake"
end

function plyMeta:IsInTheSuburbs( )
	local startPoint = Vector( -9434.521, 15211.826, 324.795 )
	local boxMins = startPoint  + Vector( 0, 0, -200 )
	local boxMaxs = startPoint + Vector( 22250, -3800, 380 )
	return ( self:GetPos( ):IsInBox( boxMins, boxMaxs ) ), "the Suburbs"
end

function plyMeta:IsInAbandondedHouse( )
	local startPoint = Vector( -3392.776, 385.972, 62.653 )
	local boxMins = startPoint + Vector( 0, 0, -10 )
	local boxMaxs = startPoint + Vector( 1040, -530, 380 )
	return ( self:GetPos( ):IsInBox( boxMins, boxMaxs ) ), "the Abandonded House"
end

function plyMeta:IsInLargeGeneralShop( )
	local startPoint = Vector( -5597.442, -6257.218, 204.031 )
	local boxMins = startPoint  + Vector( 0, 0, -5 )
	local boxMaxs = startPoint + Vector( 950, -680, 140 )
	return ( self:GetPos( ):IsInBox( boxMins, boxMaxs ) ), "the Large General Shop"
end

function plyMeta:IsInSmallGeneralShop( )
	local startPoint = Vector( -5599.23, -5782.958, 204.031 )
	local boxMins = startPoint + Vector( 0, 0, -5 )
	local boxMaxs = startPoint + Vector( 950, -350, 140 )
	return ( self:GetPos( ):IsInBox( boxMins, boxMaxs ) ), "the Small General Shop"
end

function plyMeta:IsInSmallDisplayRoom( )
	local startPoint = Vector( -5670.339, -6549.018, 72.031 )
	local boxMins = startPoint  + Vector( 0, 0, -5 )
	local boxMaxs = startPoint + Vector( 510, -380, 140 )
	return ( self:GetPos( ):IsInBox( boxMins, boxMaxs ) ), "the Small Showroom"
end

function plyMeta:IsInSlumsApartments( )
	local startPoint = Vector( -9618.787, -8479.522, 136.031 )
	local boxMins = startPoint  + Vector( 0, 0, -5 )
	local boxMaxs = startPoint + Vector( 510, -1138, 140 )
	return ( self:GetPos( ):IsInBox( boxMins, boxMaxs ) ), "the Slums Apartments"
end

function plyMeta:IsInSlumsLoft( )
	local startPoint = Vector( -8301.462, -9826.701, 72.031 )
	local boxMins = startPoint  + Vector( 0, 0, -5 )
	local boxMaxs = startPoint + Vector( 565, -1025, 300 )
	return ( self:GetPos( ):IsInBox( boxMins, boxMaxs ) ), "the Slums Loft"
end

function plyMeta:IsInMechanicsGarage( )
	local startPoint = Vector( -9617.985, -9630.101, 72.031 )
	local boxMins = startPoint  + Vector( 0, 0, -5 )
	local boxMaxs = startPoint + Vector( 630, -800, 170 )
	return ( self:GetPos( ):IsInBox( boxMins, boxMaxs ) ), "the Mechanic's Garage"
end

function plyMeta:IsInNexusGarage( )
	local startPoint = Vector( -8753.724, -7920.068, -375.969 )
	local boxMins = startPoint  + Vector( 0, 0, -5 )
	local boxMaxs = startPoint + Vector( 2370, -1800, 410 )
	return ( self:GetPos( ):IsInBox( boxMins, boxMaxs ) ), "the Nexus Garage"
end

function plyMeta:IsInNexusLabs( )
	local startPoint = Vector( -7893.071, -7685.803, -2215.969 )
	local boxMins = startPoint  + Vector( 0, 0, -5 )
	local boxMaxs = startPoint + Vector( 1480, -1050, 1750 )
	return ( self:GetPos( ):IsInBox( boxMins, boxMaxs ) ), "the Nexus Labs"
end

function plyMeta:IsInSafeZone( )
	return ( self:GetPos( ):IsInBox( Vector( -3398.41, 382.161, 50.513 ), Vector( -2372.031, -125.736, 316.794 ) ) ), "the Safe Zone"
end

local locationFuncTable = { plyMeta.IsInBank, plyMeta.IsInBankVault, plyMeta.IsInPenthouse, plyMeta.IsInHospital, plyMeta.IsInPool,
plyMeta.IsInRadioStation, plyMeta.IsInCarDealership, plyMeta.IsAtHotel, plyMeta.IsInFleaMarket, plyMeta.IsInCubFoods, plyMeta.IsInGigaComputers,
plyMeta.IsInApartments, plyMeta.IsInMetroCafe, plyMeta.IsInKFC, plyMeta.IsInBP, plyMeta.IsInNexus, plyMeta.IsInOffices, plyMeta.IsInTides,
plyMeta.IsAtWaterTreatment, plyMeta.IsInIndustrialGarage, plyMeta.IsInMTLParking, plyMeta.IsInIndustrialCrematory, plyMeta.IsInIndustrial, plyMeta.IsAtBar,
plyMeta.IsInSuburbsOne, plyMeta.IsInSuburbsTwo, plyMeta.IsInPaintballField, plyMeta.IsAtTheLake, plyMeta.IsInTheSuburbs, plyMeta.IsInAbandondedHouse, plyMeta.IsInSmallGeneralShop,
plyMeta.IsInLargeGeneralShop, plyMeta.IsInSmallDisplayRoom, plyMeta.IsInSlumsApartments, plyMeta.IsInSlumsLoft, plyMeta.IsInMechanicsGarage, plyMeta.IsInNexusLabs,
plyMeta.IsInNexusGarage }

function plyMeta:LookFor( )
	local foundArea = nil
	for index, func in ipairs ( locationFuncTable ) do
		local wasFound, stringName = func( self )
		if ( wasFound ) then 
			foundArea = stringName 
			break 
		end
	end
	return foundArea
end

function plyMeta:IsTrespassingInNexus( )
	local boxTable = { }
	boxTable[1] = { Vector( -6624.007, -9603.702, 72.031 ), Vector( -7253.969, -9368.02, 191.541 ) } -- Behind Desk
	boxTable[2] = { Vector( -6891.461, -9550.33, -127.969 ), Vector( -7274.873, -9494.468, 199.969 ) } -- Staircase
	boxTable[3] = { Vector( -7270.628, -9357.974, 56.031 ), Vector( -7100.031, -9259.006, 2740.397 ) } -- Elevator Shaft
	boxTable[4] = { Vector( -8376.86, -8612.969, 502.785 ), Vector( -6349.18, -9683.432, 2868.031 ) } -- Upper Floors
	boxTable[5] = { Vector( -8049.944, -9649.224, -135.969 ), Vector( -6401.886, -8667.837, 55.969 ) } -- Garage #1
	boxTable[6] = { Vector( -8747.014, -9474.969, -135.826 ), Vector( -7442.058, -7921.168, 55.969 ) } -- Garage #2
	boxTable[7] = { Vector( -8718.902, -9450.942, -375.969 ), Vector( -7439.578, -7922.983, -144.031 ) } -- Garage #3
	boxTable[8] = { Vector( -6469.544, -7691.455, -2191.969 ), Vector( -8721.359, -9437.6, -375.969 ) } -- Nexus Labs
	return ( self:GetPos( ):IsInBoxes( boxTable ) )
end

function plyMeta:IsWearingHat( class )
	local isWearing = false
	local currentHat = self:getDarkRPVar( "HatClass" ) or ""
	if ( isstring( class ) ) then
		if ( currentHat == class ) then
			isWearing = true
		end
	elseif ( istable( class ) ) then
		for index, hat in pairs ( class ) do
			if ( currentHat == hat ) then
				isWearing = true
				break
			end
		end
	end
	return isWearing
end

function plyMeta:IsWearingBackItem( class )
	local isWearing = false
	local currentBackItem = self:getDarkRPVar( "BackItemClass" ) or ""
	if ( isstring( class ) ) then
		if ( currentBackItem == class ) then
			isWearing = true
		end
	elseif ( istable( class ) ) then
		for index, backItem in pairs ( class ) do
			if ( currentBackItem == backItem ) then
				isWearing = true
				break
			end
		end
	end
	return isWearing
end

function plyMeta:IsDisguised( )
	return ( self:getDarkRPVar( "IsDisguised" ) or false )
end

function plyMeta:WearingDisguise( teamVar )
	local disguise = self:getDarkRPVar( "IsDisguised" )
	if not ( disguise ) then return false end
	if ( istable( teamVar ) ) then
		if ( teamVar[ disguise ] ) then
			return true
		else
			return false
		end
	else
		return ( disguise == teamVar )
	end
end

function plyMeta:SearchForOwnedEntities( )
	local entityWhitelist = SVNOOB_VARS:Get( "PersistentEntityWhitelist" ) or { }
	for index, whitelistedEnt in ipairs ( entityWhitelist ) do
		local entTable = ents.FindByClass( whitelistedEnt )
		if ( entTable and #entTable > 0 ) then
			for index, ent in ipairs ( entTable ) do
				if ( ent.ownerSteamID == self:SteamID( ) ) then
					ent:Setowning_ent( self )
				end
			end
		end
	end
	for index, veh in ipairs ( noob_VehicleIndex.spawnedVehicles ) do
		if ( !veh.trunkItems or #veh.trunkItems <= 0 ) then continue end
		for index, ent in ipairs ( veh.trunkItems ) do
			for index, whitelistedEnt in ipairs ( entityWhitelist ) do
				if ( ent.class == whitelistedEnt and ent.ownerSteamID == self:SteamID( ) ) then
					ent.owner = self
				end
			end
		end
	end
	for index, ply in ipairs ( player.GetAll( ) ) do
		if ( istable( ply.printerBackpack ) and #ply.printerBackpack > 0 ) then
			for index, entTable in ipairs ( ply.printerBackpack ) do
				if ( entTable.ownerSteamID == self:SteamID( ) ) then
					entTable.owner = self
				end
			end
		end
	end
end

function math.PointOnCircle( ang, radius, offsetX, offsetY )
	local ang = math.rad( ang )
	local x = math.cos( ang ) * radius + offsetX
	local y = math.sin( ang ) * radius + offsetY
	return x, y
end

function string.Enclose( str )
	return "'" .. str .. "'"
end

function string.IsAlphabetical( str )
	if ( string.find( str, "%c") or string.find( str, "%d") or string.find( str, "%p" ) ) then
		return false
	else
		return true
	end
end

function player.FindByNick( nick )
	for index, ply in ipairs ( player.GetAll( ) ) do
		if ( string.find( string.lower( ply:Name( ) ), string.lower( nick ) ) ) then
			return ply
		end
	end
	return nil
end

function player.SendColoredMessage( messTable, plyTable )
	net.Start( "N00BRP_Miscellaneous_NET" )
		net.WriteInt( ENUM_MISC_NET_COLOREDMESSAGE, 8 )
		net.WriteTable( messTable )
	net.Send( plyTable )
end

function player.GetClothingIndex( mdl )
	local index = 0
	if ( NOOBRP.Config.MaleClothesIndex[ string.lower( mdl ) ] ) then
		index = NOOBRP.Config.MaleClothesIndex[ string.lower( mdl ) ]
	elseif ( NOOBRP.Config.FemaleClothesIndex[ string.lower( mdl ) ] ) then
		index = NOOBRP.Config.FemaleClothesIndex[ string.lower( mdl ) ]
	end
	return index
end


function table.BuildString( tbl, sep )
	local builtString = ""
	for index, val in ipairs ( tbl ) do
		if ( #tbl <= index ) then
			builtString = builtString .. val
		else
			builtString = builtString .. val .. sep
		end
	end
	return builtString
end

function table.CleanMerge( sourceTbl, destinationTbl )
	local returnTable = destinationTbl
	for index, var in ipairs ( sourceTbl ) do
		table.insert( returnTable, var )
	end
	return returnTable
end

function table.IsValid( tbl, notEmpty, strIndexes )
	if not ( strIndexes ) then
		if ( notEmpty ) then
			return ( tbl and istable( tbl ) and #tbl > 0 )
		end
	else
		if ( notEmpty ) then
			return ( tbl and istable( tbl ) and table.Count( tbl ) > 0 )
		end
	end
	return ( tbl and istable( tbl ) )
end

function vecMeta:ToColor( )
	return( Color( self.x * 255, self.y * 255, self.z * 255, 255 ) )
end

function vecMeta:FastDist( goalPos )
	local max = self:DistToSqr( goalPos )
	return math.Clamp( max * 0.05, 0, max )
end

function vecMeta:Clamp( xMin, yMin, zMin, xMax, yMax, zMax )
	local xMin = xMin or 0
	local yMin = yMin or 0
	local zMin = zMin or 0
	local xMax = xMax or 1
	local yMax = yMax or 1
	local zMax = zMax or 1
	local clampedX = math.Clamp( self[1], xMin, xMax )
	local clampedY = math.Clamp( self[2], yMin, yMax )
	local clampedZ = math.Clamp( self[3], zMin, zMax )
	return ( Vector( clampedX, clampedY, clampedZ ) )
end

function vecMeta:UniformClamp( min, max )
	local clampedX = math.Clamp( self[1], min, max )
	local clampedY = math.Clamp( self[2], min, max )
	local clampedZ = math.Clamp( self[3], min, max )
	return ( Vector( clampedX, clampedY, clampedZ ) )
end

function util.CreateSmokeClouds( effectData, pos, destructTime )
	local smokeEffect = ents.Create( "env_smoketrail" )
	smokeEffect:SetKeyValue( "startsize", effectData.startSize or "130" )
	smokeEffect:SetKeyValue( "endsize", effectData.endSize or "30" )
	smokeEffect:SetKeyValue( "spawnradius", effectData.spawnRadius or "70" )
	smokeEffect:SetKeyValue( "minspeed", effectData.minSpeed or "0.1" )
	smokeEffect:SetKeyValue( "maxspeed", effectData.maxSpeed or "1" )
	smokeEffect:SetKeyValue( "startcolor", effectData.startColor or "255 255 255" )
	smokeEffect:SetKeyValue( "endcolor", effectData.endColor or "0 0 0" )
	smokeEffect:SetKeyValue( "opacity", effectData.opacity or "1" )
	smokeEffect:SetKeyValue( "spawnrate", effectData.spawnRate or "10" )
	smokeEffect:SetKeyValue( "lifetime", effectData.lifeTime or "4" )
	smokeEffect:SetPos( pos )
	smokeEffect:Spawn( )
	timer.Simple( destructTime or 0.1, function( )
		smokeEffect:Fire( "kill", "", 1 )
	end )
end

function util.CreateParticleEffect( pos, partAmt, partSprite, partData )
	net.Start( "N00BRP_Miscellaneous_NET" )
		net.WriteUInt( ENUM_MISC_NET_PARTICLES, 8 )
		net.WriteVector( pos )
		net.WriteUInt( partAmt, 16 )
		net.WriteString( partSprite )
		net.WriteTable( partData )
	net.Broadcast( )
end

function util.CreatePoisonSmokeCloud( pos, len )
	local effectData = { }
	effectData.startSize = 300
	effectData.endSize = 225
	effectData.startColor = "45, 125, 45"
	effectData.endColor = "25, 75, 25"
	util.CreateSmokeClouds( effectData, pos, len )
	local checkReps = math.Round( len / 3 )
	for i = 1, checkReps, 1 do
		timer.Simple( 3 * i, function( )
			local nearbyEnts = ents.FindInBox( pos - Vector( 96, 96, 96 ), pos + Vector( 96, 96, 96 ) )
			if ( nearbyEnts and istable( nearbyEnts ) and #nearbyEnts > 0 ) then
				for index, ent in ipairs ( nearbyEnts ) do
					if ( ent:IsPlayer( ) and !ent:IsPoisoned( ) and !ent:IsGhost( ) and !ent:IsWearingHat( "beast_hat" ) ) then
						ent:Poison( )
					end
				end
			end
		end )
	end
end

function team.IsCivilProtection( reqTeam )
	local cpTeams = GAMEMODE.CivilProtection or { }
	local isCP = false
	if ( cpTeams == { } ) then return isCP end
	for index, rpTeam in pairs ( cpTeams ) do
		if ( index == reqTeam ) then
			isCP = true
			break
		end
	end
	return isCP
end

function math.GetPulsingNumber( multi, speed, base, abs )
	if ( abs ) then
		return ( math.abs( math.sin( CurTime( ) * speed ) * multi ) ) + base
	else
		return ( math.sin( CurTime( ) * speed ) * multi ) + base
	end
end

// Credit goes to the individual who posted this.
// http://stackoverflow.com/a/7186820
function table.pack( ... )
	return { n = select( "#", ... ), ... }
end

// Arguments for this function go like this:
// util.ExecuteDelayedFunction( obj, delay, func, varargs )
// The varargs being the arguments for the function.
function util.ExecuteDelayedFunction( ... )
	local arg = table.pack( ... )
	local args = { }
	timer.Simple( arg[2], function( )
		if not ( IsValid( arg[1] ) ) then return end
		for i = 4, #arg do
			table.insert( args, arg[i] )
		end
		arg[3]( unpack( args ) )
	end )
end

// Kinda pointless helper function, thought I may add onto it later.
function math.RandomChance( max )
	return ( math.random( 1, max ) == 1 )
end

function util.BeginPortalEffect( origin, magnitude, scale, radius, normal, followEnt, hookName, timedRemoval )
	hook.Add( "Think", "N00BRP_PortalEffectThink_" .. hookName, function( )
		local effectData = EffectData( )
		effectData:SetOrigin( origin )
		effectData:SetMagnitude( magnitude )
		effectData:SetScale( scale )
		effectData:SetRadius( radius )
		effectData:SetNormal( normal )
		if ( IsValid( followEnt ) ) then
			effectData:SetOrigin( followEnt:GetPos( ) )
		end
		util.Effect( "AR2Explosion", effectData )
	end )
	if ( timedRemoval and tonumber( timedRemoval ) ) then
		timer.Create( "N00BRP_PortalEffectThinkDestroy_" .. hookName, timedRemoval, 1, function( )
			hook.Remove( "Think", "N00BRP_PortalEffectThink_" .. hookName )
		end )
	end
end

function util.EndPortalEffect( hookName )
	hook.Remove( "Think", "N00BRP_PortalEffectThink_" .. hookName )
end

function util.RainbowStrobe( freq, hue, sat, val )
	local freq = ( freq or 1 ) * 10
	local hue = hue or 360
	local sat = sat or 1
	local val = val or 1
	return ( HSVToColor( ( RealTime() * freq ) % hue, sat, val ) )
end

function util.FindVehicleData( name )
	for index, veh in pairs ( list.Get( "Vehicles" ) ) do
		if ( veh.Name and veh.Name == name ) then
			return veh
		end
	end
	return false
end

function vecMeta:IsInBox( mins, maxs )
	OrderVectors( mins, maxs )
	return self:WithinAABox( mins, maxs )
end

function vecMeta:IsInBoxes( boxTable )
	if ( !boxTable or !istable( boxTable ) ) then return false end
	local isInBox = false
	for index, box in ipairs ( boxTable ) do
		if ( self:IsInBox( box[1], box[2] ) ) then
			isInBox = true
			break
		end
	end
	return isInBox
end

function colMeta:ToVector( )
	return Vector( self.r / 255, self.g / 255, self.b / 255 )
end

function util.CheckCustomEntLimit( class, ply, gvar, niceName )
	local entities = ents.FindByClass( class )
	local myCount = 0
	if ( #entities > 0 ) then
		for index, ent in ipairs ( entities ) do
			if ( ent:Getowning_ent() == ply ) then
				myCount = myCount + 1
			end
		end
	end
	myCount = myCount + ply:GetTrunkEntityClassAmount( class )
	myCount = myCount + ply:GetBackpackEntityClassAmount( class )
	if ( myCount >= SVNOOB_VARS:Get( gvar ) ) then
		DarkRP.notify( ply, 1, 4, "You hit the " .. niceName .. " limit!" )
		return true
	else
		return false
	end
end

function util.FindPlayer( val  ) // Finds players by their UserID first unlike DarkRP.findPlayer
	local plyAttempt = false;
	for index, ply in pairs( player.GetAll() ) do
		if ( tonumber( val ) == ply:UserID() or tonumber( val ) == ply:SafeUniqueID( ) 
			or val == ply:SteamID( ) or val == ply:getDarkRPVar( "rpname" )
			or ply:getDarkRPVar( "rpname" ):lower( ):find( val:lower( ) ) ) then
			plyAttempt = ply
			break
		end
	end
	return plyAttempt
end

function util.CreateExplosion( pos, magnitude )
	if ( magnitude == 0 ) then
		local effectData = EffectData( )
		effectData:SetStart( pos )
		effectData:SetOrigin( pos )
		effectData:SetScale( 1 )
		util.Effect( "Explosion", effectData )
	else
		local envExplosion = ents.Create( "env_explosion" )
		envExplosion:SetKeyValue( "iMagnitude", magnitude )
		envExplosion:SetPos( pos )
		envExplosion:Spawn( )
		envExplosion:Activate( )
		envExplosion:Fire( "Explode", 0, 0 )
		timer.Simple( 0.1, function( )
			if ( IsValid( envExplosion ) ) then
				SafeRemoveEntity( envExplosion )
			end
		end )
	end
end

function game.GetIP( ) -- Credit to samm5506 :: http://facepunch.com/showthread.php?t=1332285&p=43136356&viewfull=1#post43136356
	local hostip = GetConVarString( "hostip" ) -- GetConVarNumber is inaccurate
	hostip = tonumber( hostip )

	local ip = {}
	ip[ 1 ] = bit.rshift( bit.band( hostip, 0xFF000000 ), 24 )
	ip[ 2 ] = bit.rshift( bit.band( hostip, 0x00FF0000 ), 16 )
	ip[ 3 ] = bit.rshift( bit.band( hostip, 0x0000FF00 ), 8 )
	ip[ 4 ] = bit.band( hostip, 0x000000FF )

	return table.concat( ip, "." )
end
ENUM_MISC_NET_COLOREDMESSAGE = 1
ENUM_MISC_NET_PLAYSOUND = 2
ENUM_MISC_NET_CONCOMMAND = 3

NOOBRP.ServerIPAddress = "108.61.9.83"
currentPlayerGhosts = currentPlayerGhosts or { }
npcFloatingTitleData = npcFloatingTitleData or { }

if ( SERVER ) then
	util.AddNetworkString( "N00BRP_Miscellaneous_NET" )
	util.AddNetworkString( "N00BRP_Revenge_NET" )
	util.AddNetworkString( "N00BRP_Gems_NET" )
	util.AddNetworkString( "N00BRP_Herbs_NET" )
	util.AddNetworkString( "N00BRP_TempWeapons_NET" )
	util.AddNetworkString( "N00BRP_Titles_NET" )
	util.AddNetworkString( "N00BRP_ConnectToBeast" )
	util.AddNetworkString( "N00BRP_SetPlayerClothing" )
	util.AddNetworkString( "N00BRP_RespawnTimer" )
	util.AddNetworkString( "N00BRP_GhostModeToggle" )
	util.AddNetworkString( "N00BRP_NPCTitles" )
	util.AddNetworkString( "N00BRP_Notifies" )
	util.AddNetworkString( "N00BRP_CenterMessages" )
else

	local function Net_Notifies( len )
		local txt = net.ReadString( )
		local len = net.ReadUInt( 16 )
		local iconPath = net.ReadString( )
		local textColor = net.ReadVector( )
		if ( textColor == Vector( -1, -1, -1 ) ) then textColor = nil
		else textColor = textColor:ToColor( ) end
		local panelColor = net.ReadVector( )
		if ( panelColor == Vector( -1, -1, -1 ) ) then panelColor = nil
		else panelColor = panelColor:ToColor( ) end
		local isRainbow = tobool( net.ReadBit( ) )
		local font = net.ReadString( )
		if ( IsValid( LocalPlayer( ) ) ) then
			LocalPlayer( ):DisplayNotify( txt, len, iconPath, textColor, panelColor, isRainbow, font )
		end
	end
	net.Receive( "N00BRP_Notifies", Net_Notifies )

	local function Net_CenterMessages( len )
		local txt = net.ReadString( )
		local len = net.ReadUInt( 16 )
		local col = net.ReadVector( )
		if ( col == Vector( -1, -1, -1 ) ) then col = nil
		else col = col:ToColor( ) end
		local isRainbow = tobool( net.ReadBit( ) )
		local font = net.ReadString( )
		if ( IsValid( LocalPlayer( ) ) ) then
			LocalPlayer( ):PrintCenterMessage( txt, len, col, isRainbow, font )
		end
	end
	net.Receive( "N00BRP_CenterMessages", Net_CenterMessages )

	local function Net_GetNPCTitle( len )
		local entIndex = net.ReadUInt( 32 )
		local title = net.ReadString( )
		npcFloatingTitleData[entIndex] = title
	end
	net.Receive( "N00BRP_NPCTitles", Net_GetNPCTitle )

	local function Net_SetRespawnTimer( len )
		local ply = net.ReadEntity( )
		local spawnTime = net.ReadUInt( 16 )
		ply.respawnTime = CurTime( ) + spawnTime
	end
	net.Receive( "N00BRP_RespawnTimer", Net_SetRespawnTimer )

	local function Net_GhostModeToggle( len )
		local ply = net.ReadEntity( )
		local ghostMode = net.ReadBool( )
		if not ( IsValid( ply ) ) then return end
		if ( isfunction( ply.IsBot ) and ply:IsBot( ) ) then
			currentPlayerGhosts[ply:EntIndex( )] = ghostMode
		else
			currentPlayerGhosts[ply:SteamID( )] = ghostMode
		end
	end
	net.Receive( "N00BRP_GhostModeToggle", Net_GhostModeToggle )

	local function Net_SetPlayerClothing( len )
		local maleMaterial = net.ReadString( )
		local femaleMaterial = net.ReadString( )
		LocalPlayer( ).maleClothingMaterial = maleMaterial
		LocalPlayer( ).femaleClothingMaterial = femaleMaterial
	end
	net.Receive( "N00BRP_SetPlayerClothing", Net_SetPlayerClothing )

	local function Net_SetViewOffset( len )
		local newOffset = net.ReadVector( )
		local newOffsetDucked = net.ReadVector( )
		if ( LocalPlayer( ).SetViewOffset and LocalPlayer( ).SetViewOffsetDucked ) then
			LocalPlayer( ):SetViewOffset( newOffset )
			LocalPlayer( ):SetViewOffsetDucked( newOffsetDucked )
		end
	end
	net.Receive( "N00BRP_SetViewOffset", Net_SetViewOffset )

	local function Net_SetHull( len )
		local resetHull = tobool( net.ReadBit( ) )
		local hullMins = net.ReadVector( )
		local hullMaxs = net.ReadVector( )
		if ( resetHull ) then
			if ( LocalPlayer( ).ResetHull ) then
				LocalPlayer( ):ResetHull( )
			end
		else
			if ( LocalPlayer( ).SetHull and LocalPlayer( ).SetHullDuck ) then
				LocalPlayer( ):SetHull( hullMins, hullMaxs )
				LocalPlayer( ):SetHullDuck( hullMins, Vector( hullMaxs.x, hullMaxs.y, ( hullMaxs.z / 2 ) ) )
			end
		end
	end
	net.Receive( "N00BRP_SetHull", Net_SetHull )

	local function Net_Miscellaneous( len )
		local mesType = net.ReadInt( 8 )
		if ( mesType == ENUM_MISC_NET_COLOREDMESSAGE ) then
			local messTable = net.ReadTable( )
			chat.AddText( unpack( messTable ) )
		elseif ( mesType == ENUM_MISC_NET_PLAYSOUND ) then
			
		elseif ( mesType == ENUM_MISC_NET_CONCOMMAND ) then
			local cmdTbl = net.ReadTable( )
			local cmdString = table.BuildString( cmdTbl, " " )
			LocalPlayer( ):ConCommand( cmdString )
		elseif ( mesType == ENUM_MISC_NET_PARTICLES ) then
			local pos = net.ReadVector( )
			local partAmt = net.ReadUInt( 16 ) or 10
			local partSprite = net.ReadString( )
			local partData = net.ReadTable( )
			local partEmitter = ParticleEmitter(pos)
			local color = partData.color or Color( 255, 255, 255, 255 )
			local velocity = partData.velocity or Vector( 0, 0, 0 )
			local dieTime = partData.dieTime or 0.5
			local lifeTime = partData.lifeTime or 0
			local startSize = partData.startSize or 10
			local endSize = partData.endSize or 0
			local shouldCollide = partData.shouldCollide or false
			local gravity = partData.gravity or Vector( 0, 0, 0 )
			local randomStartSize = partData.randomStartSize or { startSize, startSize }
			local randomEndSize = partData.randomEndSize or { endSize, endSize }
			local randomVelocity = partData.randomVelocity or { Vector( 0, 0, 0 ), Vector( 0, 0, 0 ) }
			local angle = partData.angle or Angle( 0, 0, 0 )
			local randomAngle = partData.randomAngle or { Angle( 0, 0, 0 ), Angle( 0, 0, 0 ) }
			local rollDelta = partData.rollDelta or 0
			local randomColor = partData.randomColor or { Color( 0, 0, 0, 0 ), Color( 0, 0, 0, 0 ) }
			local randomVelocityMulti = partData.randomVelocityMulti or { Vector( 1, 1, 1 ), Vector( 1, 1, 1 ) }
			local particleDelay = partData.particleDelay or 0
			local emitterRunTime = particleDelay * partAmt
			local followEntity = partData.followEntity or nil
			local followEntitySpeed = partData.followEntitySpeed or 1
			local followEntityOffset = partData.followEntityOffset or Vector( 0, 0, 0 )
			for i=1, partAmt do
				timer.Simple( particleDelay * i, function( )
					local part = partEmitter:Add( partSprite, pos )
					if ( part ) then
						part:SetColor( color.r + math.random( randomColor[1].r, randomColor[2].r ), color.g + math.random( randomColor[1].g, randomColor[2].g ), color.b + math.random( randomColor[1].b, randomColor[2].b ), color.a + math.random( randomColor[1].a, randomColor[2].a ) )
						//part:SetColor( Color( color.r + math.random( randomColor[1].r, randomColor[2].r ), color.g + math.random( randomColor[1].g, randomColor[2].g ), color.b + math.random( randomColor[1].b, randomColor[2].b ), color.a + math.random( randomColor[1].a, randomColor[2].a ) ) )
						local randomVelocity = Vector( math.random( randomVelocity[1].x, randomVelocity[2].x ), math.random( randomVelocity[1].y, randomVelocity[2].y ) , math.random( randomVelocity[1].z, randomVelocity[2].z )  )
						part:SetVelocity( velocity + randomVelocity )
						part:SetVelocity( part:GetVelocity( ) * Vector( math.random( randomVelocityMulti[1].x, randomVelocityMulti[2].x ), math.random( randomVelocityMulti[1].y, randomVelocityMulti[2].y ) , math.random( randomVelocityMulti[1].z, randomVelocityMulti[2].z ) ) )
						part:SetDieTime( dieTime )
						part:SetLifeTime( lifeTime )
						part:SetStartSize( startSize + math.random( randomStartSize[1], randomStartSize[2] ) )
						part:SetEndSize( endSize + math.random( randomEndSize[1], randomEndSize[2] ) )
						part:SetCollide( shouldCollide )
						part:SetGravity( gravity )
						part:SetAngles( angle + Angle( math.random( randomAngle[1][1], randomAngle[2][1] ), math.random( randomAngle[1][2], randomAngle[2][2] ), math.random( randomAngle[1][3], randomAngle[2][3] ) ) )
						part:SetRollDelta( rollDelta )
						if ( IsValid( followEntity ) ) then
							part:SetNextThink( 0.5 )
							part:SetThinkFunction( function( particle )
								if ( IsValid( followEntity ) ) then
									particle:SetVelocity( ( ( ( followEntity:GetPos( ) + followEntityOffset ) - part:GetPos( ) ) + randomVelocity ) * followEntitySpeed )
									particle:SetNextThink( 0.5 )
								end
							end )
						end
					end
				end )
			end
			timer.Simple( emitterRunTime, function( )
				if ( IsValid( partEmitter ) ) then partEmitter:Finish( ) end
			end )
		end
	end
	net.Receive( "N00BRP_Miscellaneous_NET", Net_Miscellaneous )

	local function Net_Revenge( len )
		local mesType = net.ReadUInt( 8 )
		local playerID = net.ReadUInt( 32 )
		LocalPlayer( ).revengeTable = LocalPlayer( ).revengeTable or { }
		if ( mesType == ENUM_REVENGE_SENDREVENGE ) then
			local killAmt = net.ReadUInt( 16 )
			LocalPlayer( ).revengeTable[playerID] = killAmt 
		elseif ( mesType == ENUM_REVENGE_REMOVEREVENGE ) then
			LocalPlayer( ).revengeTable[playerID] = nil
		elseif ( mesType == ENUM_REVENGE_INCREMENTREVENGE ) then
			LocalPlayer( ).revengeTable[playerID] = ( LocalPlayer( ).revengeTable[playerID] or 0 ) + 1
		end
	end
	net.Receive( "N00BRP_Revenge_NET", Net_Revenge )

	local function Net_Gems( len )
		local gemName = net.ReadString( )
		local gemAmount = net.ReadUInt( 32 )
		LocalPlayer( ).gemTable = LocalPlayer( ).gemTable or { }
		LocalPlayer( ).gemTable[gemName] = gemAmount
	end
	net.Receive( "N00BRP_Gems_NET", Net_Gems )

	local function Net_Herbs( len )
		local herbName = net.ReadString( )
		local herbAmount = net.ReadUInt( 32 )
		LocalPlayer( ).herbTable = LocalPlayer( ).herbTable or { }
		LocalPlayer( ).herbTable[herbName] = herbAmount
	end
	net.Receive( "N00BRP_Herbs_NET", Net_Herbs )

	local function Net_TempWeapons( len )
		local mesType = net.ReadUInt( 8 )
		if ( !IsValid( LocalPlayer( ) ) ) then 
			return 
		end
		LocalPlayer( ).tempWeapons = LocalPlayer( ).tempWeapons or { }
		if ( mesType == ENUM_TEMPWEPS_ADDWEP ) then
			local wepClass = net.ReadString( )
			table.insert( LocalPlayer( ).tempWeapons, wepClass )
		elseif ( mesType == ENUM_TEMPWEPS_REMOVEWEP ) then
			local wepClass = net.ReadString( )
			for index, wep in ipairs ( LocalPlayer( ).tempWeapons ) do
				if ( wep == wepClass ) then
					table.remove( LocalPlayer( ).tempWeapons, index )
					break
				end
			end
		elseif ( mesType == ENUM_TEMPWEPS_CLEARWEPS ) then
			LocalPlayer( ).tempWeapons = { }
		end
	end
	net.Receive( "N00BRP_TempWeapons_NET", Net_TempWeapons )

	local function Net_Titles( len )
		local mesType = net.ReadUInt( 8 )
		if ( mesType == ENUM_TITLES_BEGINSEND ) then
			if ( LocalPlayer( ).isReceivingTitles ) then return end
			LocalPlayer( ).titlesTable = { }
			LocalPlayer( ).isReceivingTitles = true
		elseif ( mesType == ENUM_TITLES_SENDTITLE ) then
			table.insert( LocalPlayer( ).titlesTable, net.ReadUInt( 8 ) )
		elseif ( mesType == ENUM_TITLES_ENDSEND ) then
			LocalPlayer( ).isReceivingTitles = false
		end
	end
	net.Receive( "N00BRP_Titles_NET", Net_Titles )
	
	local function ConnectToBeast( len )
		local ip = net.ReadString( ) 
		local port = net.ReadString( )
		LocalPlayer( ):ConCommand( "connect " .. ip .. ":" .. port )
	end
	net.Receive( "N00BRP_ConnectToBeast", ConnectToBeast )
end
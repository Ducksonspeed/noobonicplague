ENUM_POTIONVAULT_BEGINSENDING = 1
ENUM_POTIONVAULT_SENDPOTION = 2
ENUM_POTIONVAULT_ENDSENDING = 3
ENUM_POTIONVAULT_REQUESTVAULT = 4
ENUM_POTIONVAULT_UPDATECOUNT = 5
ENUM_POTIONVAULT_ATTEMPTRETRIEVE = 6
ENUM_POTIONVAULT_OPENMENU = 7

if ( SERVER ) then
	util.AddNetworkString( "N00BRP_PotionVault_NET" )
	NOOBRP = NOOBRP or { }
	NOOBRP.PotionIndex = { }
	
	function NOOBRP.GeneratePotionIndex( )
		local selectQuery = [[
			SELECT COUNT(*) AS amount, potionid
			FROM darkrp_potionindex
			WHERE potionname = %s;
		]]
		local insertQuery = [[
			INSERT INTO darkrp_potionindex 
			( potionname ) VALUES ( %s );
		]]
		local idSelectQuery = [[
			SELECT potionid
			FROM darkrp_potionindex
			WHERE potionname = %s
			LIMIT 1;
		]]
		mySQLControl:Query( "SHOW TABLES LIKE 'darkrp_potionindex';", function( dat )
			if ( #dat < 1 ) then
				MsgC( Color( 255, 175, 175 ), "Failed to scan and create the potion index, table doesn't exist." )
				return
			else
				local potionAmount = table.Count( NOOBRP.PotionFunctions )
				for index, potion in pairs ( NOOBRP.PotionFunctions ) do
					mySQLControl:Query( Format( selectQuery, SQLStr( index ) ), function( data )
						if ( #data < 1 or tonumber( data[1].amount ) < 1 ) then
							mySQLControl:Query( Format( insertQuery, SQLStr( index ) ), function( )
								MsgC( Color( 175, 175, 255 ), "Inserting " .. index .. " into the potion index.\n" )
								mySQLControl:Query( Format( idSelectQuery, SQLStr( index ) ), function( data )
									if ( #data > 0 ) then
										NOOBRP.PotionIndex[ index ] = data[1].potionid
									end 
								end )
							end )
						else
							NOOBRP.PotionIndex[ index ] = data[1].potionid
							MsgC( Color( 175, 175, 255 ), "Found " .. index .. " within the potion index.\n" )
						end
					end )
				end
			end
		end )
	end
	
	local plyMeta = FindMetaTable( "Player" )

	function plyMeta:RetrievePotionVault( )
		self.shouldSkipPotionVaultRetrieval = self.shouldSkipPotionVaultRetrieval or false
		if ( self.shouldSkipPotionVaultRetrieval ) then
			net.Start( "N00BRP_PotionVault_NET" )
				net.WriteUInt( ENUM_POTIONVAULT_OPENMENU, 8 )
			net.Send( self )
		else
			local retrievalQuery = [[ 
				SELECT potionname, amt, darkrp_potionvault.potionid 
				FROM darkrp_potionvault JOIN darkrp_potionindex
				ON darkrp_potionvault.potionid = darkrp_potionindex.potionid
				WHERE uniqueid = %u; 
			]]
			mySQLControl:Query( Format( retrievalQuery, self:SafeUniqueID( ) ) , function( data ) 
				net.Start( "N00BRP_PotionVault_NET" )
					net.WriteUInt( ENUM_POTIONVAULT_BEGINSENDING, 8 )
				net.Send( self )
				self.sendingPotionVault = true
				for index, dat in ipairs ( data ) do
					net.Start( "N00BRP_PotionVault_NET" )
						net.WriteUInt( ENUM_POTIONVAULT_SENDPOTION, 8 )
						net.WriteString( dat.potionname )
						net.WriteUInt( dat.amt, 16 )
					net.Send( self )
				end
				net.Start( "N00BRP_PotionVault_NET" )
					net.WriteUInt( ENUM_POTIONVAULT_ENDSENDING, 8 )
				net.Send( self )
				self.sendingPotionVault = false
				self.shouldSkipPotionVaultRetrieval = true
			end )
		end
	end

	function plyMeta:UpdatePotionCount( name, amt )
		self.shouldSkipPotionVaultRetrieval = false
		net.Start( "N00BRP_PotionVAult_NET" )
			net.WriteUInt( ENUM_POTIONVAULT_UPDATECOUNT, 8 )
			net.WriteString( name )
			net.WriteInt( amt, 16 )
		net.Send( self )
	end
	
	function plyMeta:StorePotionInVault( id, amt )
		local amt = math.abs( amt )
		local id = id
		if ( isstring( id ) ) then
			id = NOOBRP.PotionIndex[ id ]
		end
		local checkQuery = [[ 
			SELECT COUNT(*) AS amount, amt
			FROM darkrp_potionvault
			WHERE uniqueid = %u 
			AND potionid = %i;
		]]
		local insertQuery = [[
			INSERT INTO darkrp_potionvault
			VALUES ( %u, %i, %i );
		]]
		local updateQuery = [[
			UPDATE darkrp_potionvault
			SET amt = amt + %i
			WHERE uniqueid = %u
			AND potionid = %i;
		]]
		if not ( tonumber( id ) ) then return end
		mySQLControl:Query( Format( checkQuery, self:SafeUniqueID( ), id ), function( data )
			local potionName = table.KeyFromValue( NOOBRP.PotionIndex, id )
			if ( #data < 1 or tonumber( data[1].amount ) < 1 ) then
				mySQLControl:Query( Format( insertQuery, self:SafeUniqueID( ), id, amt ), function( ) end )
				self:UpdatePotionCount( potionName, amt )
			else
				mySQLControl:Query( Format( updateQuery, amt, self:SafeUniqueID( ), id ), function( )  end )
				self:UpdatePotionCount( potionName, data[1].amt + amt )
			end
		end )
	end

	function plyMeta:RemovePotionFromVault( id, amt, cback )
		local amt = math.abs( amt )
		if ( isstring( id ) ) then
			id = NOOBRP.PotionIndex[ id ]
		end
		local checkQuery = [[
			SELECT COUNT(*) AS amount, amt
			FROM darkrp_potionvault
			WHERE uniqueid = %u
			AND potionid = %i;
		]]
		local deleteQuery = [[
			DELETE FROM darkrp_potionvault
			WHERE uniqueid = %u
			AND potionid = %i;
		]]
		local updateQuery = [[
			UPDATE darkrp_potionvault
			SET amt = amt - %i
			WHERE uniqueid = %u
			AND potionid = %i;
		]]
		mySQLControl:Query( Format( checkQuery, self:SafeUniqueID( ), id ), function( data )
			if ( #data > 0 and tonumber( data[1].amount ) > 0 ) then
				local amt = amt
				local hasSpace, spaceLeft = self:HasPocketSpacesLeft( amt )
				if not ( hasSpace ) then
					amt = spaceLeft
					if ( amt == 0 ) then DarkRP.notify( self, 1, 4, "You have no more space in your pocket." ) end
				end
				local potionName = table.KeyFromValue( NOOBRP.PotionIndex, id )
				if ( tonumber( data[1].amt ) - amt <= 0 ) then
					local amountRetrieved = amt - math.abs( tonumber( data[1].amt ) - amt )
					mySQLControl:Query( Format( deleteQuery, self:SafeUniqueID( ), id ), function( ) cback( amountRetrieved, potionName ) end )
					self:UpdatePotionCount( potionName, 0 )
				else
					mySQLControl:Query( Format( updateQuery, amt, self:SafeUniqueID( ), id ), function( ) cback( amt, potionName ) end )
					self:UpdatePotionCount( potionName, data[1].amt - amt )
				end
			end
		end )
	end

	local function AttemptPotionStore( ply, key )
		local traceEnt = ply:RangeEyeTrace( 120, { ply } ).Entity
		if ( key == IN_RELOAD and ply:KeyDown( IN_DUCK ) ) then
			if ( IsValid( traceEnt ) and traceEnt:GetClass( ) == "ent_alchemypotion" ) then
				if not ( traceEnt:GetPotionName( ) ) then return end
				ply:StorePotionInVault( traceEnt:GetPotionName( ), 1 )
				DarkRP.notify( ply, 1, 4, "You've stored a " .. traceEnt:GetPotionName( ) .. " in your Potion Vault!" )
				SafeRemoveEntity( traceEnt )
			end
		end
		if ( key == IN_USE and ply:KeyDown( IN_DUCK ) and ( IsValid( ply:GetActiveWeapon( ) ) and ply:GetActiveWeapon( ):GetClass( ) == "potionlauncher" ) ) then
			ply:ConCommand( "rp_potionvault" )
		end
	end
	hook.Add( "KeyPress", "N00BRP_AttemptPotionStore_KeyPress", AttemptPotionStore )

	local function Receive_PotionVault_NET( len, ply )
		local messType = net.ReadUInt( 8 )
		if ( messType == ENUM_POTIONVAULT_REQUESTVAULT ) then
			if not ( ply.sendingPotionVault ) then
				ply:RetrievePotionVault( )
			end
		elseif ( messType == ENUM_POTIONVAULT_ATTEMPTRETRIEVE ) then
			local potionName = net.ReadString( )
			local potionAmount = net.ReadUInt( 8 )
			ply:RemovePotionFromVault( potionName, potionAmount, function( amountRetrieved, potionName )
				DarkRP.notify( ply, 1, 4, "You've stored " .. potionName .. " x" .. amountRetrieved .. " in your pocket!" )
				for i = 1, amountRetrieved do
					local potion = ents.Create( "ent_alchemypotion" )
					potion.PotionType = potionName
					potion:SetPotionName( potionName )
					potion:SetPos( ply:GetPos( ) )
					potion:Spawn( )
					ply:PocketEntity( potion )
				end
			end )
		end
	end
	net.Receive( "N00BRP_PotionVault_NET", Receive_PotionVault_NET )
else
	local function Receive_PotionVault_NET( len )
		local messType = net.ReadUInt( 8 )
		if ( messType == ENUM_POTIONVAULT_BEGINSENDING ) then
			LocalPlayer( ).PotionVaultTable = { }
			LocalPlayer( ).sendingPotionVault = true
		elseif ( messType == ENUM_POTIONVAULT_SENDPOTION ) then
			local potionName = net.ReadString( )
			local potionAmount = net.ReadUInt( 16 )
			LocalPlayer( ).PotionVaultTable = LocalPlayer( ).PotionVaultTable or { }
			LocalPlayer( ).PotionVaultTable[ potionName ] = potionAmount
		elseif ( messType == ENUM_POTIONVAULT_ENDSENDING ) then
			LocalPlayer( ).sendingPotionVault = false
			if not ( ValidPanel( LocalPlayer( ).PotionVaultMenu ) ) then
				LocalPlayer( ).PotionVaultMenu = vgui.Create( "N00BRP_PotionVault" )
			end
		elseif ( messType == ENUM_POTIONVAULT_UPDATECOUNT ) then
			local potionName = net.ReadString( )
			local potionAmount = net.ReadInt( 16 )
			if not ( LocalPlayer( ).PotionVaultTable ) then return end
			if not ( LocalPlayer( ).PotionVaultTable[potionName] ) then return end
			if ( potionAmount == 0 ) then
				LocalPlayer( ).PotionVaultTable[potionName] = nil
			else
				LocalPlayer( ).PotionVaultTable[potionName] = potionAmount
			end
			if ( ValidPanel( LocalPlayer( ).PotionVaultMenu ) ) then
				if ( table.Count( LocalPlayer( ).PotionVaultTable ) > 0 ) then
					LocalPlayer( ).PotionVaultMenu:GenerateVaultList( )
				else
					LocalPlayer( ).PotionVaultMenu.itemList:ClearItems( )
				end
			end
		elseif ( messType == ENUM_POTIONVAULT_OPENMENU ) then
			if not ( ValidPanel( LocalPlayer( ).PotionVaultMenu ) ) then
				LocalPlayer( ).PotionVaultMenu = vgui.Create( "N00BRP_PotionVault" )
			else
				LocalPlayer( ).PotionVaultMenu:Remove( )
			end
		end
	end
	net.Receive( "N00BRP_PotionVault_NET", Receive_PotionVault_NET )

	local function OpenPotionVault( ply, cmd, args, fstring )
		if not ( ply.sendingPotionVault ) then
			net.Start( "N00BRP_PotionVault_NET" )
				net.WriteUInt( ENUM_POTIONVAULT_REQUESTVAULT, 8 )
			net.SendToServer( )
		end
	end
	concommand.Add( "rp_potionvault", OpenPotionVault )
end
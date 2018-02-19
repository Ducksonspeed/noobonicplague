if ( SERVER ) then
	util.AddNetworkString( "N00BRP_BankItems_NET" )
	local function RequestBankData( ply )
		ply:LoadBankTable( function( ) end )
	end
	hook.Add( "NOOBRP_OnRequestData", "N00BRP_RequestBankData_OnRequestData", RequestBankData )
	local function WithdrawItem( ply, cmd, args, fstring )
		ply.canWithdrawItem = ply.canWithdrawItem or true
		if not ( ply.canWithdrawItem ) then return end
		ply.nextWithdraw = ply.nextWithdraw or CurTime( )
		if ( ply.nextWithdraw > CurTime( ) ) then
			DarkRP.notify( ply, 1, 4, "You must wait " .. string.NiceTime( ply.nextWithdraw - CurTime( ) ) .. " until you can withdraw again." )
			return
		else
			ply.nextWithdraw = CurTime( ) + 2
		end
		ply.canWithdrawItem = false
		ply:RetrieveBankItem( tonumber( args[1] ), function( dataRef )
			if ( dataRef ) then
				local max = RPExtraTeams[ply:Team( )].maxpocket or GAMEMODE.Config.pocketitems
				if ( table.Count(ply.darkRPPocket or { } ) >= max ) then
					DarkRP.notify( ply, 1, 4, "You cannot fit anymore items in your pocket." )
					ply:GetOccupiedBankSlots( function( amt )
						local maxBankSlots = SVNOOB_VARS:Get( "MaxBankSlots" )
						if ( tonumber( amt ) < maxBankSlots ) then
							ply:StoreBankItem( dataRef.class, dataRef.model, dataRef.content, dataRef.count, function( )
								ply:LoadBankTable( function( ) 
									ply:RefreshPocketAndBank( )
									ply.canWithdrawItem = true
								end )
							end )
						end
					end )
				else
					ply:LoadBankTable( function( )
						if ( dataRef.class == "spawned_shipment" ) then
							local shipment = ents.Create( "spawned_shipment" )
							shipment:SetPos( ply:GetEyeTrace( ).HitPos )
							shipment.contents = { }
							for index, ship in ipairs ( CustomShipments ) do
								if ( ship.entity == dataRef.content ) then
									shipment:Setcontents( index )
									shipment:Setcount( dataRef.count )
									break
								end 
							end
							shipment:Spawn( )
							ply:addPocketItem( shipment )
						elseif ( dataRef.class == "spawned_weapon" ) then
							local wep = ents.Create( "spawned_weapon" )
							wep:SetPos( ply:GetEyeTrace( ).HitPos )
							wep:Setamount( 1 )
							wep:SetWeaponClass( dataRef.content )
							wep:SetModel( dataRef.model )
							wep:Spawn( )
							ply:addPocketItem( wep )
						elseif ( dataRef.class == "ent_alchemypotion" ) then
							local potion = ents.Create( "ent_alchemypotion" )
							potion:SetPotionName( dataRef.content )
							potion:Spawn( )
							ply:addPocketItem( potion )
						elseif ( dataRef.class == "food" ) then
							local food = ents.Create( "food" )
							food:SetModel( dataRef.model )
							food:Spawn( )
							ply:addPocketItem( food )
						elseif ( dataRef.class == "spawned_food" ) then
							local spawnedFood = ents.Create( "spawned_food" )
							spawnedFood:SetModel( dataRef.model )
							spawnedFood.FoodEnergy = dataRef.content
							spawnedFood:Spawn( )
							ply:addPocketItem( spawnedFood )
						elseif ( dataRef.class == "gas_can" ) then
							local gasCan = ents.Create( "gas_can" )
							gasCan:SetModel( dataRef.model )
							gasCan:Spawn( )
							ply:addPocketItem( gasCan )
						end
						net.Start( "N00BRP_BankItems_NET" )
							net.WriteUInt( ENUM_BANKITEMS_REMOVEITEM, 8 )
							net.WriteUInt( tonumber( args[1] ), 32 )
						net.Send( ply )
						ply.canWithdrawItem = true
						ply:RefreshPocketAndBank( )
					end )
				end
			else
				ply.canWithdrawItem = true
				ply:ChatPrint( "That item is invalid. You cannot withdraw it. Try Closing and reopening the window." )
			end
		end )
	end
	concommand.Add( "rp_withdrawitem", WithdrawItem )

	local function ToggleBankWindow( ply, args )
		ply:ConCommand( "rp_togglebank" )
	end
	DarkRP.defineChatCommand("viewbank", ToggleBankWindow )

	local function OnPocketItemAdded( ply, ent, tbl )
		if ( ent:GetClass( ) == "spawned_shipment" ) then
			local contentInfo = CustomShipments[ent:Getcontents() or ""]
			local entity = nil
			if not ( contentInfo ) then
				entity = "swb_glock18"
			else
				entity = contentInfo.entity
			end
			tbl.gunEntity = entity
		end
	end
	hook.Add( "onPocketItemAdded", "N00BRP_OnPocketItemAdded_onPocketItemAdded", OnPocketItemAdded )
else
	surface.CreateFont( "N00BRP_BankMenu_HeaderFont", {
		font = "Lobster",
		size = ScreenScale( 12 ),
		weight = 600
	} )
	surface.CreateFont( "N00BRP_BankMenu_TextFont", {
		font = "Lobster",
		size = ScreenScale( 16 ),
		weight = 600
	} )
	surface.CreateFont( "N00BRP_BankMenu_ButtonFont", {
		font = "Lobster",
		size = ScreenScale( 7 ),
		weight = 600
	} )
	PANEL = {}
	function PANEL:Init()
	    self:SetSize( ScrW( ) * 0.5, ScrH( ) * 0.25 )
	    self:Center( )
	    self:ShowCloseButton( false )
	    self:SetTitle( "" )
	    self:MakePopup( )
	   	self:CreateBankMenu( )
	 	self:GenerateBankItems( )
	 	self:GeneratePocketItems( )
	 	gui.EnableScreenClicker( true )
	 	local closeButton = vgui.Create( "DN00B_ColoredButton", self )
	 	closeButton:SetSize( self:GetWide( ) * 0.05, self:GetTall( ) * 0.1 )
	 	closeButton:SetPos( self:GetWide( ) * 0.92, self:GetTall( ) * 0.175 )
	 	closeButton:SetText( "X" )
	 	closeButton:SetTextFont( "N00BRP_BankMenu_TextFont" )
	 	closeButton:SetTextColor( Color( 175, 45, 45 ) )
	 	closeButton:SetButtonColor( Color( 52, 73, 94 ) )
	 	closeButton:SetHoverColor( Color( 41, 128, 185, 175 ) )
	 	closeButton.OnMousePressed = function( btnPnl, btn )
	 		gui.EnableScreenClicker( false )
	 		self:Remove( )
	 	end
	 	local refreshButton = vgui.Create( "DN00B_ColoredButton", self )
	 	refreshButton:SetSize( self:GetWide( ) * 0.09, self:GetTall( ) * 0.1 )
	 	refreshButton:SetPos( self:GetWide( ) * 0.9, self:GetTall( ) * 0.05 )
	 	refreshButton:SetText( "Refresh" )
	 	refreshButton:SetTextFont( "N00BRP_BankMenu_ButtonFont" )
	 	refreshButton:SetTextColor( Color( 45, 175, 45 ) )
	 	refreshButton:SetButtonColor( Color( 52, 73, 94 ) )
	 	refreshButton:SetHoverColor( Color( 41, 128, 185, 175 ) )
	 	refreshButton.OnMousePressed = function( btnPnl, btn )
	 		self:GenerateBankItems( )
	 		self:GeneratePocketItems( )
	 	end
	end
	function PANEL:Paint( w, h )
		draw.RoundedBox( 8, 0, 0, w, h, Color( 44, 62, 80, 230 ) )
		draw.SimpleText( "Bank Inventory", "N00BRP_BankMenu_HeaderFont", w / 2, h * 0.022, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( "Pocket Inventory", "N00BRP_BankMenu_HeaderFont", w / 2, h * 0.482, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end
	function PANEL:CreateBankMenu( )
		local scrollPanel = vgui.Create( "DScrollPanel", self )
		scrollPanel:SetSize( self:GetWide( ) * 0.8, self:GetTall( ) * 0.335 )
		scrollPanel:Center( )
		local posX, posY = scrollPanel:GetPos( )
		scrollPanel:SetPos( posX, posY - self:GetTall( ) * 0.175 )
		local bankList = vgui.Create( "DIconLayout" )
		scrollPanel:AddItem( bankList )
		bankList:SetSize( scrollPanel:GetWide( ), scrollPanel:GetTall( ) )
		bankList:SetPos( 0, 0 )
		bankList:SetSpaceX( 2 )
		bankList:SetSpaceY( 2 )
		bankList.oldPaint = bankList.Paint
		bankList.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 25, 25, 25, 175 ) )
			bankList.oldPaint( pnl, w, h )
		end
		self.bankList = bankList
		local scrollPanel = vgui.Create( "DScrollPanel", self )
		scrollPanel:SetSize( self:GetWide( ) * 0.8, self:GetTall( ) * 0.335 )
		scrollPanel:Center( )
		local posX, posY = scrollPanel:GetPos( )
		scrollPanel:SetPos( posX, posY + ( self:GetTall( ) * 0.25 ) )
		local pocketList = vgui.Create( "DIconLayout" )
		scrollPanel:AddItem( pocketList )
		pocketList:SetSize( scrollPanel:GetWide( ), scrollPanel:GetTall( ) )
		pocketList:SetPos( 0, 0 )
		pocketList:SetSpaceX( 2 )
		pocketList:SetSpaceY( 2 )
		pocketList.oldPaint = pocketList.Paint
		pocketList.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 25, 25, 25, 175 )) 
			pocketList.oldPaint( pnl, w, h )
		end
		self.pocketList = pocketList
	end
	function PANEL:GenerateBankItems( )
		local bankList = self.bankList
		bankList:Clear( )
		for index, item in pairs ( LocalPlayer( ).bankItems or { } ) do
			local spawnIcon = bankList:Add( "SpawnIcon" )
			spawnIcon:SetModel( item.model )
			spawnIcon:SetToolTip( "Amount: " .. tonumber( item.count ) .. "\nContent: " .. item.content )
			if ( item.class == "ent_alchemypotion" ) then spawnIcon:SetToolTip( item.content ) end
			if ( item.class == "spawned_food" ) then spawnIcon:SetToolTip( "Model: " .. item.model .. "\nClass: " .. item.class ) end
			if ( item.class == "gas_can" ) then spawnIcon:SetToolTip( "Gas Can" ) end
			spawnIcon.OnMousePressed = function( btnPanel, btn )
				LocalPlayer( ):ConCommand( "rp_withdrawitem " .. index )
				/*timer.Simple( 0.5, function( ) if not ( IsValid( self ) ) then return end self:GenerateBankItems( ) end )
				timer.Simple( 0.5, function( ) if not ( IsValid( self ) ) then return end self:GeneratePocketItems( ) end )*/
			end
		end
	end
	function PANEL:GeneratePocketItems( )
		local pocketList = self.pocketList
		pocketList:Clear( )
		for index, item in pairs ( LocalPlayer( ):getPocketItems( ) ) do
			local spawnIcon = pocketList:Add( "SpawnIcon" )
			spawnIcon:SetModel( item.model )
			if ( item.class == "spawned_shipment" ) then
				spawnIcon:SetToolTip( "Amount: " .. item.itmCount .. "\nClass: " .. item.class )
			elseif ( item.class == "spawned_weapon" ) then
				spawnIcon:SetToolTip( "Weapon: " .. item.wepClass .. "\nClass: " .. item.class )
			elseif ( item.class == "ent_alchemypotion" ) then
				spawnIcon:SetToolTip( item.name )
			elseif ( item.class == "spawned_food" ) then
				spawnIcon:SetToolTip( "Model: " .. item.model .. "\nClass: " .. item.class )
			elseif ( item.class == "gas_can" ) then
				spawnIcon:SetToolTip( "Gas Can" )
			end
			spawnIcon.OnMousePressed = function( btnPanel, btn )
				net.Start( "DarkRP_storePocketItem" )
					net.WriteFloat( index )
				net.SendToServer( )
				/*timer.Simple( 0.5, function( ) if not ( IsValid( self ) ) then return end self:GeneratePocketItems( ) end )
				timer.Simple( 0.5, function( ) if not ( IsValid( self ) ) then return end self:GenerateBankItems( ) end )*/
			end
		end
	end
	vgui.Register( "n00b_BankMenu", PANEL, "DFrame" )

	local function BankItems_Net( len )
		LocalPlayer( ).bankItems = LocalPlayer( ).bankItems or { }
		local mesType = net.ReadUInt( 8 )
		if ( mesType == ENUM_BANKITEMS_ADDITEM ) then
			local itemClass = net.ReadString( )
			local itemModel = net.ReadString( )
			local itemContent = net.ReadString( )
			local itemCount = net.ReadUInt( 16 )
			local itemID = net.ReadUInt( 32 )
			LocalPlayer( ).bankItems[itemID] = { class = itemClass, model = itemModel, content = itemContent, count = itemCount }
		elseif ( mesType == ENUM_BANKITEMS_REMOVEITEM ) then
			local itemID = net.ReadUInt( 32 )
			LocalPlayer( ).bankItems[itemID] = nil
		end
	end
	net.Receive( "N00BRP_BankItems_NET", BankItems_Net )

	local function ToggleBankPanel( )
		if not ( IsValid( LocalPlayer( ).bankMenu ) ) then
			LocalPlayer( ).bankMenu = vgui.Create( "n00b_BankMenu" )
		else
			gui.EnableScreenClicker( false )
			LocalPlayer( ).bankMenu:Remove( )
		end
	end
	concommand.Add( "rp_togglebank", ToggleBankPanel )
end
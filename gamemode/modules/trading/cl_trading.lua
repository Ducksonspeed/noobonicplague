surface.CreateFont( "TradeSystem_Tahoma", { font = "Tahoma", size = 13, weight = 400, antialiasing = true } );
surface.CreateFont( "TradeSystem_Notification", { font = "Tahoma", size = 12, weight = 800, antialiasing = true } );
surface.CreateFont( "SchmalSansMS", { font = "Comic Sans MS", size = 21, weight = 800, antialiasing = true } );

local GemTypeTab =
{
	[ "Rocks" ] = { GemColor = Color( 255, 255, 255 ), NiceName = "Rocks" },
	[ "Granite" ] = { GemColor = Color( 160, 160, 160 ), NiceName = "Granite" },
	[ "Shale" ] = { GemColor = Color( 100, 100, 100 ), NiceName = "Shale" },
	[ "Emeralds" ] = { GemColor = Color( 0, 255, 0 ), GemMaterial = "models/shiny", NiceName = "Emeralds" },
	[ "Rubies" ] = { GemColor = Color( 255, 0, 0 ), GemMaterial = "models/shiny", NiceName = "Rubies" },
	[ "Sapphires" ] = { GemColor = Color( 0, 0, 255 ), GemMaterial = "models/shiny", NiceName = "Sapphires" },
	[ "Obsidians" ] = { GemColor = Color( 0, 0, 0 ), GemMaterial = "models/shiny", NiceName = "Obsidians" },
	[ "Diamonds" ] = { GemColor = Color( 255, 255, 255, 150 ), GemMaterial = "models/shiny", NiceName = "Diamonds" },
};

local HerbTypeTab = 
{
	["Burdock Root"] = { herbColor = Color( 255, 255, 255 ), herbModel = "models/props/de_inferno/largebush04.mdl" },
	["Gingko Biloba"] = { herbColor = Color( 255, 255, 255 ), herbModel = "models/props/de_inferno/largebush03.mdl" },
	["Valerian Root"] = { herbColor = Color( 255, 255, 255 ), herbModel = "models/props/de_inferno/largebush06.mdl" },
	["Coral Fungus"] = { herbColor = Color( 200, 100, 100 ), herbModel = "models/props/jeezy/mushroom/mushroom.mdl" },
	["Red Reishi"] = { herbColor = Color( 100, 100, 200 ), herbModel = "models/props/jeezy/mushroom/mushroom.mdl" },
	["Psilocybe Cubensis"] = { herbColor = Color( 100, 200, 100 ), herbModel = "models/props/jeezy/mushroom/mushroom.mdl" }
};

local function ItemCheck( ItemClass )
	// ItemClass = ItemClass:lower();

	local ItemReturn = {}; // we don't want to send the whole visual table. majority of the indexes in the table are useless.
	local visual = weapons.Get( ItemClass ) or scripted_ents.Get( ItemClass );
	if ( visual ) then visual.PrintName = ItemClass; end

	if ( !visual ) then
		if ( GemTypeTab[ ItemClass ] ) then
			visual = { WorldModel = "models/props_junk/rock001a.mdl", PrintName = GemTypeTab[ ItemClass ].NiceName, Material = GemTypeTab[ ItemClass ].GemMaterial or "", Color = GemTypeTab[ ItemClass ].GemColor };
		elseif ( HerbTypeTab[ ItemClass ] ) then
			visual = { WorldModel = HerbTypeTab[ ItemClass ].herbModel, PrintName = ItemClass, Material = "", Color = HerbTypeTab[ ItemClass ].herbColor };
		end
	end

	visual = visual or {};

	ItemReturn.PrintName = visual.PrintName or ItemClass;
	ItemReturn.WorldModel = visual.WorldModel or "models/props_lab/jar01a.mdl";
	ItemReturn.Material = visual.Material or "";

	if ( GemTypeTab[ ItemClass ] or HerbTypeTab[ ItemClass ] ) then
		ItemReturn.ModelColor = visual.Color;
		ItemReturn.Color = Color( 131, 131, 131 );
	else
		ItemReturn.ModelColor = Color( 255, 255, 255 );
		ItemReturn.Color = visual.Color or Color( 131, 131, 131 );
	end

	return ItemReturn;
end

function TRADING_SYSTEM:SetupVGUI( TraderTab, InventoryTab )
	TRADING_SYSTEM.TradeMainFrame = vgui.Create( "DFrame" );
	TRADING_SYSTEM.TradeMainFrame:SetTitle( Format( "Trading with %s [%s]", TraderTab.Name, TraderTab.SteamID ) );
	TRADING_SYSTEM.TradeMainFrame:SetSize( 800, 600 );
	TRADING_SYSTEM.TradeMainFrame:Center();
	TRADING_SYSTEM.TradeMainFrame:MakePopup();
	TRADING_SYSTEM.TradeMainFrame.Labels = { MoneyTraded = 0, MoneyTradedOther = 0 };
	TRADING_SYSTEM.TradeMainFrame.Paint = function( self, w, h )
		draw.RoundedBox( 4, 0, 0, w, h, Color( 108, 111, 114 ) );

		draw.DrawText( "Money traded (you): "..DarkRP.formatMoney( self.Labels.MoneyTraded ), "chatfont", 500, 295, color_white );
		draw.DrawText( "Money traded (other): "..DarkRP.formatMoney( self.Labels.MoneyTradedOther ), "chatfont", 500, 575, color_white );		
	end
	
	TRADING_SYSTEM.TradeMainFrame.RemoveOld = TRADING_SYSTEM.TradeMainFrame.Remove;

	function TRADING_SYSTEM.TradeMainFrame:Remove( bNotCanceled )
		self:RemoveOld();

		if ( bNotCanceled ) then return; end
		
		net.Start( "TradeSystem_Accepted_Canceled" );
		net.SendToServer();
	end

	TRADING_SYSTEM.TradeNotifyPanel = vgui.Create( "DPanel", TRADING_SYSTEM.TradeMainFrame )
	TRADING_SYSTEM.TradeNotifyPanel:SetPos( 15, 27 );
	TRADING_SYSTEM.TradeNotifyPanel:SetSize( 450, 20 );

	TRADING_SYSTEM.TradeNotifyPanel.NewNotify = { 
		Delay = 0,
		Sequence = 0,
		Current = Format( "You are trading with %s [%s]", TraderTab.Name, TraderTab.SteamID ),
		Notifications = { "Make sure you're trading the right person.", "Use - sign to deduct a certain amount of money that you've offered in the trade.", "Double check if anything is missing/incorrect.", "You are held responsible for trading your own items." }
	};

	if ( TRADING_SYSTEM.MAX_SLOTS > 0 ) then
		table.insert( TRADING_SYSTEM.TradeNotifyPanel.NewNotify.Notifications, Format( "Currently, the max amount of items you can trade is: %d", TRADING_SYSTEM.MAX_SLOTS ) );
	end

	TRADING_SYSTEM.TradeNotifyPanel.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 91, 91, 91 ) );

		surface.SetDrawColor( Color( 255, 255, 255 ) );
		surface.SetMaterial( Material( "icon16/information.png" ) );
		surface.DrawTexturedRect( 2, 2, 16, 16 );

		if ( self.NewNotify.Delay < CurTime() ) then
			self.NewNotify.Delay = CurTime() + 5;
			self.NewNotify.Sequence = ( self.NewNotify.Sequence == #self.NewNotify.Notifications and 1 ) or self.NewNotify.Sequence + 1;
			self.NewNotify.Current = self.NewNotify.Notifications[ self.NewNotify.Sequence ];
		end

		draw.DrawText( self.NewNotify.Current, "TradeSystem_Notification", 20, 2, color_white );
	end

	TRADING_SYSTEM.StatusButton = vgui.Create( "DButton", TRADING_SYSTEM.TradeMainFrame );
	TRADING_SYSTEM.StatusButton:SetText( "Accept (will not finish trade)" );
	TRADING_SYSTEM.StatusButton:SetSize( 150, 20 );
	TRADING_SYSTEM.StatusButton:SetPos( 10, 570 );
	TRADING_SYSTEM.StatusButton.DoClick = function( self )
		net.Start( "TradeSystem_TradeStatus" );
		net.SendToServer();
	end

	TRADING_SYSTEM.StatusText = vgui.Create( "DLabel", TRADING_SYSTEM.TradeMainFrame );
	TRADING_SYSTEM.StatusText:SetSize( 320, 30 );
	TRADING_SYSTEM.StatusText:SetPos( 180, 575 );
	TRADING_SYSTEM.StatusText:SetColor( Color( 255, 0, 0 ) );
	TRADING_SYSTEM.StatusText:SetText( "" );
	TRADING_SYSTEM.StatusText.Text = "";
	TRADING_SYSTEM.StatusText.Paint = function( self, w, h )
		draw.DrawText( self.Text, "TradeSystem_Tahoma", 0, 0, Color( 231, 221, 151 ) );
	end

	TRADING_SYSTEM.ChatBox = vgui.Create( "RichText", TRADING_SYSTEM.TradeMainFrame );
	TRADING_SYSTEM.ChatBox:SetPos( 20, 360 );
	TRADING_SYSTEM.ChatBox:SetSize( 420, 180 );
	TRADING_SYSTEM.ChatBox.Paint = function( self, w, h )
		self:SetFontInternal( "SchmalSansMS" );
		draw.RoundedBox( 0, 0, 0, w, h, Color( 91, 91, 91 ) );
	end
	
	function TRADING_SYSTEM.ChatBox:AddMessage( _Msg )
		self:InsertColorChange( 127, 159, 255, 255 );
		self:AppendText( _Msg.Name );

		if ( _Msg.Admin ) then
			local rank = ( _Msg.Admin == "superadmin" and Color( 191, 51, 51 ) ) or ( _Msg.Admin == "admin" and Color( 51, 151, 51 ) );
			self:InsertColorChange( rank.r, rank.g, rank.b, 255 );
			self:AppendText( "(ADMIN)" );
		end

		self:InsertColorChange( 255, 255, 255, 255 );
		self:AppendText( ": ".._Msg.Msg.."\n" );
		// self:GotoTextEnd();
	end

	TRADING_SYSTEM.ChatBox_TextEntry = vgui.Create( "DTextEntry", TRADING_SYSTEM.TradeMainFrame );
	TRADING_SYSTEM.ChatBox_TextEntry:SetPos( 20, 545 );
	TRADING_SYSTEM.ChatBox_TextEntry:SetSize( TRADING_SYSTEM.ChatBox:GetWide() - 5, 20 );
	// TRADING_SYSTEM.ChatBox_TextEntry:SetAllowNonAsciiCharacters( false );

	local chat_delay = 0;

	TRADING_SYSTEM.ChatBox_TextEntry.OnEnter = function( self )
		if ( self:GetValue():len() > 100 or chat_delay > CurTime() ) then 
			self:RequestFocus(); 
			return;
		end

		chat_delay = CurTime() + 0.5;

		TRADING_SYSTEM.ChatBox:AddMessage( { Name = LocalPlayer():Name(), Msg = self:GetValue(), Admin = ( LocalPlayer():IsSuperAdmin() and "superadmin" ) or ( LocalPlayer():IsAdmin() and "admin" ) } );

		net.Start( "TradeSystem_ChatBoxMessage" );
			net.WriteString( self:GetValue() );
		net.SendToServer();

		self:SetText( "" );
		self:RequestFocus();
	end

	TRADING_SYSTEM.TradeFrame_TradeSlotTrader = vgui.Create( "ItemSlotFrame", TRADING_SYSTEM.TradeMainFrame );
	TRADING_SYSTEM.TradeFrame_TradeSlotTrader:SetPos( 470, 320 );
	TRADING_SYSTEM.TradeFrame_TradeSlotTrader:SetSizeNew( 320, 250 );
	TRADING_SYSTEM.TradeFrame_TradeSlotTrader.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, color_black );
		draw.RoundedBox( 0, 1, 1, w - 2, h - 2, Color( 91, 91, 91 ) );
	end

	function TRADING_SYSTEM.TradeFrame_TradeSlotTrader.SlotList:SlotItem( ItemTab, action )
		self.GetItems = self.GetItems or {};
		self.GetItems[ ItemTab.Class ] = self.GetItems[ ItemTab.Class ] or { Amount = 0 };

		if ( action == "retrieve" ) then // remove item from slot
			self.GetItems[ ItemTab.Class ].Amount = self.GetItems[ ItemTab.Class ].Amount - ItemTab.Amount;

			if ( self.GetItems[ ItemTab.Class ].Amount < 1 ) then
				self.GetItems[ ItemTab.Class ].ItemPanel:Remove();
				self.GetItems[ ItemTab.Class ] = nil;
				return;
			end
		elseif ( action == "send" ) then // add item to slot
			self.GetItems[ ItemTab.Class ].Amount = self.GetItems[ ItemTab.Class ].Amount + ItemTab.Amount;
		end

		if ( self.GetItems[ ItemTab.Class ].ItemPanel ) then return; end

		local visual = ItemCheck( ItemTab.Class );

		self.GetItems[ ItemTab.Class ].ItemPanel = self:Add( "DPanel" );
		self.GetItems[ ItemTab.Class ].ItemPanel:SetSize( 100, 100 );
		self.GetItems[ ItemTab.Class ].ItemPanel:SetText( "" );
		self.GetItems[ ItemTab.Class ].ItemPanel:SetCursor( "arrow" );
		self.GetItems[ ItemTab.Class ].ItemPanel:SetToolTip( ItemTab.Class );
		self.GetItems[ ItemTab.Class ].ItemPanel.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( visual.Color.r + 51, visual.Color.g + 51, visual.Color.b + 51 ) );
			draw.RoundedBox( 0, 1, 1, w - 2, h - 2, visual.Color );

			draw.DrawText( visual.PrintName, "TradeSystem_Tahoma", 4, 2, color_white );
			draw.DrawText( self:GetParent().GetItems[ ItemTab.Class ].Amount, "TradeSystem_Tahoma", self:GetWide() - 15, self:GetTall() - 20, color_white, TEXT_ALIGN_CENTER );
		end

		local ModelPanel = vgui.Create( "DModelPanel", self.GetItems[ ItemTab.Class ].ItemPanel );
		ModelPanel:SetMouseInputEnabled( false );
		ModelPanel:SetModel( visual.WorldModel );
		ModelPanel:Dock( FILL );

		ModelPanel.Entity:SetMaterial( visual.Material );
		ModelPanel:SetColor( visual.ModelColor );

		ModelPanel:SetAmbientLight( Color( 255, 255, 255 ) );

		local vec = Vector( 0.7, 0.7, 0.6 );
		local mins, maxs = ModelPanel.Entity:GetRenderBounds();
		ModelPanel:SetCamPos( mins:Distance( maxs ) * vec );
		ModelPanel:SetLookAt( ( maxs + mins ) / 2 );

		ModelPanel.LayoutEntity = function( self ) end
	end

	local swap_delay = 0;

	TRADING_SYSTEM.TradeFrame_TradeSlotSelf = vgui.Create( "ItemSlotFrame", TRADING_SYSTEM.TradeMainFrame );
	TRADING_SYSTEM.TradeFrame_TradeSlotSelf:SetPos( 470, 40 );
	TRADING_SYSTEM.TradeFrame_TradeSlotSelf:SetSizeNew( 320, 250 );
	TRADING_SYSTEM.TradeFrame_TradeSlotSelf.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, color_black );
		draw.RoundedBox( 0, 1, 1, w - 2, h - 2, Color( 91, 91, 91 ) );
	end

	function TRADING_SYSTEM.TradeFrame_TradeSlotSelf.SlotList:AddItem( ItemTab )
		self.GetItems = self.GetItems or {};
		self.GetItems[ ItemTab.Class ] = self.GetItems[ ItemTab.Class ] or { Amount = 0, Init = nil };
		self.GetItems[ ItemTab.Class ].Amount = self.GetItems[ ItemTab.Class ].Amount + ItemTab.Amount;

		if ( table.Count( self.GetItems ) > TRADING_SYSTEM.MAX_SLOTS ) then return; end
		if ( self.GetItems[ ItemTab.Class ].Init ) then return; end

		self.GetItems[ ItemTab.Class ].Init = true;

		local visual = ItemCheck( ItemTab.Class );

		local ItemPanel = self:Add( "DButton" );
		ItemPanel:SetSize( 100, 100 );
		ItemPanel:SetText( "" );
		ItemPanel:SetCursor( "arrow" );
		ItemPanel:SetToolTip( ItemTab.Class );
		ItemPanel.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( visual.Color.r + 51, visual.Color.g + 51, visual.Color.b + 51 ) );
			draw.RoundedBox( 0, 1, 1, w - 2, h - 2, visual.Color );

			draw.DrawText( visual.PrintName, "TradeSystem_Tahoma", 4, 2, color_white );
			draw.DrawText( self:GetParent().GetItems[ ItemTab.Class ].Amount, "TradeSystem_Tahoma", self:GetWide() - 15, self:GetTall() - 20, color_white, TEXT_ALIGN_CENTER );
		end
		ItemPanel.DoClick = function( self )
			if ( TRADING_SYSTEM.TradeMainFrame.Confirmed ) then return; end
			if ( swap_delay > CurTime() ) then return; end

			swap_delay = CurTime() + 0.5;

			local _itemtab = { Class = ItemTab.Class, Amount = 1 };

			net.Start( "TradeSystem_UpdateInventory" );
				net.WriteString( "retrieve" );
				net.WriteTable( _itemtab );
			net.SendToServer();

			net.Start( "TradeSystem_TradeStatus" );
				net.WriteString( "interrupted" );
			net.SendToServer();

			TRADING_SYSTEM.TradeFrame_Inventory.SlotList:AddItem( _itemtab );

			if ( self:GetParent().GetItems[ ItemTab.Class ].Amount > 1 ) then
				self:GetParent().GetItems[ ItemTab.Class ].Amount = self:GetParent().GetItems[ ItemTab.Class ].Amount - 1;
			else
				self:GetParent().GetItems[ ItemTab.Class ] = nil;
				self:Remove();
			end
		end
		ItemPanel.DoRightClick = function( self )
			if ( TRADING_SYSTEM.TradeMainFrame.Confirmed ) then return; end
			if ( swap_delay > CurTime() ) then return; end

			local _itemtab = { Class = ItemTab.Class, Amount = 1 };

			local amountframe = vgui.Create( "DFrame" );
			amountframe:Center();
			amountframe:SetSize( 200, 200 );
			// amountframe:SetTitle( Format( "Insert amount of (%s) to remove from the trade.", ItemTab.Class ) );
			amountframe:MakePopup();

			local confirm = vgui.Create( "DButton", amountframe );
			confirm:SetText( "Confirm" );
			confirm:SetSize( 100, 20 );
			confirm:SetPos( 30, 80 );
			confirm.amount = 0;
			confirm.DoClick = function( self )
				if ( !ValidPanel( ItemPanel ) or !tonumber( self.amount ) or self.amount <= 0 ) then return; end
				self.amount = math.floor( self.amount );
				if ( TRADING_SYSTEM.TradeFrame_TradeSlotSelf.SlotList.GetItems[ ItemTab.Class ].Amount < confirm.amount ) then return; end

				swap_delay = CurTime() + 0.5;

				local _itemtab = { Class = ItemTab.Class, Amount = self.amount };

				net.Start( "TradeSystem_UpdateInventory" );
					net.WriteString( "retrieve" );
					net.WriteTable( _itemtab );
				net.SendToServer();

				net.Start( "TradeSystem_TradeStatus" );
					net.WriteString( "interrupted" );
				net.SendToServer();

				TRADING_SYSTEM.TradeFrame_Inventory.SlotList:AddItem( _itemtab );

				if ( TRADING_SYSTEM.TradeFrame_TradeSlotSelf.SlotList.GetItems[ ItemTab.Class ].Amount > confirm.amount ) then
					TRADING_SYSTEM.TradeFrame_TradeSlotSelf.SlotList.GetItems[ ItemTab.Class ].Amount = TRADING_SYSTEM.TradeFrame_TradeSlotSelf.SlotList.GetItems[ ItemTab.Class ].Amount - confirm.amount;
				else
					TRADING_SYSTEM.TradeFrame_TradeSlotSelf.SlotList.GetItems[ ItemTab.Class ] = nil;
					amountframe:Remove();
					ItemPanel:Remove();
				end
			end

			local numwang = vgui.Create( "DNumberWang", amountframe );
			numwang:SetPos( 30, 40 );
			numwang:SetMinMax( 1, self:GetParent().GetItems[ ItemTab.Class ].Amount );
			numwang:SizeToContents();
			numwang.OnValueChanged = function( value )
				confirm.amount = value:GetValue();
			end
		end

		local ModelPanel = vgui.Create( "DModelPanel", ItemPanel );
		ModelPanel:SetMouseInputEnabled( false );
		ModelPanel:SetModel( visual.WorldModel );
		ModelPanel:Dock( FILL );

		ModelPanel.Entity:SetMaterial( visual.Material );
		ModelPanel:SetColor( visual.ModelColor );

		ModelPanel:SetAmbientLight( Color( 255, 255, 255 ) );

		local vec = Vector( 0.7, 0.7, 0.6 );
		local mins, maxs = ModelPanel.Entity:GetRenderBounds();
		ModelPanel:SetCamPos( mins:Distance( maxs ) * vec );
		ModelPanel:SetLookAt( ( maxs + mins ) / 2 );

		ModelPanel.LayoutEntity = function( self ) end
	end

	TRADING_SYSTEM.TradeFrame_MoneyEntry = vgui.Create( "DTextEntry", TRADING_SYSTEM.TradeMainFrame );
	TRADING_SYSTEM.TradeFrame_MoneyEntry:SetPos( 470, 15 );
	TRADING_SYSTEM.TradeFrame_MoneyEntry:SetSize( 200, 20 );
	TRADING_SYSTEM.TradeFrame_MoneyEntry:SetText( "Insert Amount of Money Here" );
	TRADING_SYSTEM.TradeFrame_MoneyEntry.ClearOut = false;
	TRADING_SYSTEM.TradeFrame_MoneyEntry.OnGetFocus = function( self )
		if ( !self.ClearOut ) then
			self.ClearOut = true;
			self:SetText( "" );
		end
	end
	TRADING_SYSTEM.TradeFrame_MoneyEntry.OnEnter = function( self )
		if ( TRADING_SYSTEM.TradeMainFrame.Confirmed ) then return; end
		
		local amount = tonumber( self:GetValue() );

		if ( !amount ) then return; end

		local total = math.floor( TRADING_SYSTEM.TradeMainFrame.Labels.MoneyTraded + amount );

		if ( LocalPlayer():getDarkRPVar( "money" ) >= total and total >= 0 ) then
			TRADING_SYSTEM.TradeMainFrame.Labels.MoneyTraded = total;

			net.Start( "TradeSystem_UpdateMoney" );
				net.WriteInt( amount, 32 );
			net.SendToServer();
		end
	end

	TRADING_SYSTEM.TradeFrame_Inventory = vgui.Create( "ItemSlotFrame", TRADING_SYSTEM.TradeMainFrame );
	TRADING_SYSTEM.TradeFrame_Inventory:SetPos( 15, 50 );
	TRADING_SYSTEM.TradeFrame_Inventory:SetSizeNew( 425, 300 );
	TRADING_SYSTEM.TradeFrame_Inventory.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, color_black );
		draw.RoundedBox( 0, 1, 1, w - 2, h - 2, Color( 51, 51, 51 ) );
	end

	function TRADING_SYSTEM.TradeFrame_Inventory.SlotList:AddItem( ItemTab )
		self.GetItems = self.GetItems or {};
		self.GetItems[ ItemTab.Class ] = self.GetItems[ ItemTab.Class ] or { Amount = 0, Init = nil };
		self.GetItems[ ItemTab.Class ].Amount = self.GetItems[ ItemTab.Class ].Amount + ItemTab.Amount;

		if ( self.GetItems[ ItemTab.Class ].Init ) then return; end

		self.GetItems[ ItemTab.Class ].Init = true;

		local visual = ItemCheck( ItemTab.Class );

		local ItemPanel = self:Add( "DButton" );
		ItemPanel:SetSize( 100, 100 );
		ItemPanel:SetText( "" );
		ItemPanel:SetCursor( "arrow" );
		ItemPanel:SetToolTip( ItemTab.Class );
		ItemPanel.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( visual.Color.r + 51, visual.Color.g + 51, visual.Color.b + 51 ) );
			draw.RoundedBox( 0, 1, 1, w - 2, h - 2, visual.Color );

			draw.DrawText( visual.PrintName, "TradeSystem_Tahoma", 4, 2, color_white );
			draw.DrawText( self:GetParent().GetItems[ ItemTab.Class ].Amount, "TradeSystem_Tahoma", self:GetWide() - 15, self:GetTall() - 20, color_white, TEXT_ALIGN_CENTER );
		end
		ItemPanel.DoClick = function( self )
			if ( TRADING_SYSTEM.TradeMainFrame.Confirmed ) then return; end
			if ( swap_delay > CurTime() ) then return; end
			
			if ( TRADING_SYSTEM.TradeFrame_TradeSlotSelf.SlotList.GetItems and table.Count( TRADING_SYSTEM.TradeFrame_TradeSlotSelf.SlotList.GetItems ) >= TRADING_SYSTEM.MAX_SLOTS ) then
				if ( !TRADING_SYSTEM.TradeFrame_TradeSlotSelf.SlotList.GetItems[ ItemTab.Class ] ) then return; end
			end

			swap_delay = CurTime() + 0.5;

			local _itemtab = { Class = ItemTab.Class, Amount = 1 };

			net.Start( "TradeSystem_UpdateInventory" );
				net.WriteString( "send" );
				net.WriteTable( _itemtab );
			net.SendToServer();

			net.Start( "TradeSystem_TradeStatus" );
				net.WriteString( "interrupted" );
			net.SendToServer();

			TRADING_SYSTEM.TradeFrame_TradeSlotSelf.SlotList:AddItem( _itemtab );

			if ( self:GetParent().GetItems[ ItemTab.Class ].Amount > 1 ) then
				self:GetParent().GetItems[ ItemTab.Class ].Amount = self:GetParent().GetItems[ ItemTab.Class ].Amount - 1;
			else
				self:GetParent().GetItems[ ItemTab.Class ] = nil;
				self:Remove();
			end
		end
		ItemPanel.DoRightClick = function( self )
			if ( TRADING_SYSTEM.TradeMainFrame.Confirmed ) then return; end
			if ( swap_delay > CurTime() ) then return; end

			if ( TRADING_SYSTEM.TradeFrame_TradeSlotSelf.SlotList.GetItems and table.Count( TRADING_SYSTEM.TradeFrame_TradeSlotSelf.SlotList.GetItems ) >= TRADING_SYSTEM.MAX_SLOTS ) then
				if ( !TRADING_SYSTEM.TradeFrame_TradeSlotSelf.SlotList.GetItems[ ItemTab.Class ] ) then return; end
			end

			local _itemtab = { Class = ItemTab.Class, Amount = 1 };

			local amountframe = vgui.Create( "DFrame" );
			amountframe:Center();
			amountframe:SetSize( 200, 200 );
			// amountframe:SetTitle( Format( "Insert amount of (%s) to remove from the trade.", ItemTab.Class ) );
			amountframe:MakePopup();

			local confirm = vgui.Create( "DButton", amountframe );
			confirm:SetText( "Confirm" );
			confirm:SetSize( 100, 20 );
			confirm:SetPos( 30, 80 );
			confirm.amount = 0;
			confirm.DoClick = function( self )
				if ( !ValidPanel( ItemPanel ) or !tonumber( self.amount ) or self.amount <= 0 ) then return; end
				self.amount = math.floor( self.amount );
				if ( TRADING_SYSTEM.TradeFrame_Inventory.SlotList.GetItems[ ItemTab.Class ].Amount < self.amount ) then return; end

				swap_delay = CurTime() + 0.5;

				local _itemtab = { Class = ItemTab.Class, Amount = self.amount };

				net.Start( "TradeSystem_UpdateInventory" );
					net.WriteString( "send" );
					net.WriteTable( _itemtab );
				net.SendToServer();

				net.Start( "TradeSystem_TradeStatus" );
					net.WriteString( "interrupted" );
				net.SendToServer();

				TRADING_SYSTEM.TradeFrame_TradeSlotSelf.SlotList:AddItem( _itemtab );

				if ( TRADING_SYSTEM.TradeFrame_Inventory.SlotList.GetItems[ ItemTab.Class ].Amount > self.amount ) then
					TRADING_SYSTEM.TradeFrame_Inventory.SlotList.GetItems[ ItemTab.Class ].Amount = TRADING_SYSTEM.TradeFrame_Inventory.SlotList.GetItems[ ItemTab.Class ].Amount - self.amount;
				else
					TRADING_SYSTEM.TradeFrame_Inventory.SlotList.GetItems[ ItemTab.Class ] = nil;
					amountframe:Remove();
					ItemPanel:Remove();
				end
			end

			local numwang = vgui.Create( "DNumberWang", amountframe );
			numwang:SetPos( 30, 40 );
			numwang:SetMinMax( 1, self:GetParent().GetItems[ ItemTab.Class ].Amount );
			numwang:SizeToContents();
			numwang.OnValueChanged = function( value )
				confirm.amount = value:GetValue();
			end
		end

		local ModelPanel = vgui.Create( "DModelPanel", ItemPanel );
		ModelPanel:SetMouseInputEnabled( false );
		ModelPanel:SetModel( visual.WorldModel );
		ModelPanel:Dock( FILL );

		ModelPanel.Entity:SetMaterial( visual.Material );
		ModelPanel:SetColor( visual.ModelColor );

		ModelPanel:SetAmbientLight( Color( 255, 255, 255 ) );

		local vec = Vector( 0.7, 0.7, 0.6 );
		local mins, maxs = ModelPanel.Entity:GetRenderBounds();
		ModelPanel:SetCamPos( mins:Distance( maxs ) * vec );
		ModelPanel:SetLookAt( ( maxs + mins ) / 2 );

		ModelPanel.LayoutEntity = function( self ) end
	end

	for k, v in pairs( InventoryTab ) do
		TRADING_SYSTEM.TradeFrame_Inventory.SlotList:AddItem( { Class = k, Amount = v or 1 } );
	end
end

net.Receive( "TradeSystem_Accepted_Start", function()
	local trader = net.ReadTable();
	TRADING_SYSTEM:SetupVGUI( trader, trader.SelfInventory );
end );

net.Receive( "TradeSystem_ChatBoxMessage", function()
	if ( !ValidPanel( TRADING_SYSTEM.TradeMainFrame ) ) then return; end
	TRADING_SYSTEM.ChatBox:AddMessage( net.ReadTable() );
end );

net.Receive( "TradeSystem_UpdateMoney", function()
	if ( !ValidPanel( TRADING_SYSTEM.TradeMainFrame ) ) then return; end
	TRADING_SYSTEM.TradeMainFrame.Labels.MoneyTradedOther = tonumber( net.ReadString() );
end );

net.Receive( "TradeSystem_UpdateInventory", function()
	if ( !ValidPanel( TRADING_SYSTEM.TradeMainFrame ) ) then return; end

	local action = net.ReadString();
	local item = net.ReadTable();

	TRADING_SYSTEM.TradeFrame_TradeSlotTrader.SlotList:SlotItem( item, action );
end );

net.Receive( "TradeSystem_TradeStatus", function()
	if ( !ValidPanel( TRADING_SYSTEM.TradeMainFrame ) ) then return; end
	
	local status = net.ReadUInt( 16 );
	local who = net.ReadString();

	if ( status == 0 ) then
		if ( LocalPlayer():SteamID() != who ) then
			TRADING_SYSTEM.StatusText.Text = "Status: The player has removed/added an item to the trade list.";
		else
			TRADING_SYSTEM.StatusText.Text = "Status: You've removed/added an item to the trade list.";
		end

		TRADING_SYSTEM.TradeMainFrame.Confirmed = false;
	elseif ( status == 1 ) then
		if ( LocalPlayer():SteamID() == who ) then
			TRADING_SYSTEM.StatusText.Text = "Status: Waiting for other player.";
		else
			TRADING_SYSTEM.StatusText.Text = "Status: Other player has accepted.";
		end
	elseif ( status == 2 ) then
		// the server has a double check just to make sure they've confirmed -- no point in modifying these variables.
		if ( who == "" ) then
			TRADING_SYSTEM.TradeMainFrame.Confirmed = true;

			TRADING_SYSTEM.StatusButton:SetText( "Confirm" );
			TRADING_SYSTEM.StatusText.Text = "";
		else
			if ( LocalPlayer():SteamID() == who ) then
				TRADING_SYSTEM.StatusText.Text = "Status: Waiting for other player.";
			else
				TRADING_SYSTEM.StatusText.Text = "Status: Other player has confirmed.";
			end
		end
	elseif ( status == 4 ) then
		if ( LocalPlayer():SteamID() != who ) then
			TRADING_SYSTEM.StatusText.Text = "Status: The player has deducted/added money to the trade.";
		else
			TRADING_SYSTEM.StatusText.Text = "Status: You've deducted/added money to the trade.";
		end

		TRADING_SYSTEM.TradeMainFrame.Confirmed = false;
	end
end );

net.Receive( "TradeSystem_TradeFinished_ReceiveItems", function()
	net.Start( "TradeSystem_TradeFinished_ReceiveItems" );
	net.SendToServer();
end );


include( "shared.lua" );
surface.CreateFont( "N00BRP_NPCDerma_MediumFont", {
	font = "Segoe UI Bold",
	size = ScreenScale( 8 ),
	weight = 600
} )

local function create_panel( ent, tab )
	if ( !ent:IsNPC() ) then return; end
	//if ( LocalPlayer( ):getDarkRPVar( "IsGhost" ) ) then return end
	if ( LocalPlayer( ):IsGhost( ) ) then return end
	local repTable = LocalPlayer( ):getDarkRPVar( "PlayerNPCReputation" )
	local playerRep = 0
	if ( repTable and repTable[ent:GetClass( )] ) then 
		playerRep = repTable[ent:GetClass( )] 
	end
	local dFrame = vgui.Create( "DFrame" )
	dFrame:SetSize( ScrW( ) * 0.3, ScrH( ) * 0.4 )
	dFrame:Center( )
	dFrame:MakePopup( )
	dFrame.Paint = function( pnl, w, h )
		draw.RoundedBoxEx( 0, 0, 0, w, h, Color( 25, 25, 25, 230 ) )
		if ( ent.EnableReputation ) then
			draw.SimpleText( "Reputation: " .. playerRep, "N00BRP_NPCDerma_MediumFont", w * 0.1, h * 0.025, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
		end
	end
	dFrame:SetTitle( "" )
	dFrame:ShowCloseButton( false )
	dFrame:SetDraggable( false )
	local dScrollList = vgui.Create( "DN00B_ScrollableList", dFrame )
	dScrollList:SetSize( dFrame:GetWide( ) * 0.8, dFrame:GetTall( ) * 0.8 )
	dScrollList:Center( )
	local dCloseButton = vgui.Create( "DN00B_ColoredButton", dFrame )
	dCloseButton:SetSize( dFrame:GetWide( ) * 0.1, dFrame:GetTall( ) * 0.06 )
	dCloseButton:OffsetFromCenter( dFrame:GetWide( ) * 0.35, -( dFrame:GetTall( ) * 0.45 ) )
	dCloseButton:SetText( "X" )
	dCloseButton:SetTextFont( "N00BRP_NPCDerma_MediumFont" )
	dCloseButton:SetButtonColor( Color( 175, 45, 45, 255 ) )
	dCloseButton:SetHoverColor( Color( 175, 125, 125, 255 ) )
	dCloseButton:SetTextColor( Color( 255, 255, 255, 255 ) )
	dCloseButton.OnMousePressed = function( btn )
		dFrame:Remove( )
	end
	for index, opt in SortedPairs( tab ) do
		if ( opt.stage ) then continue end
		local dButton = dScrollList:AddElement( "DN00B_ColoredButton" )
		dButton:SetSize( dFrame:GetWide( ), dFrame:GetTall( ) * 0.1 )
		dButton:SetText( opt.text )
		if ( opt.price ) then
			if ( LocalPlayer( ):IsVIP( ) ) then opt.price = opt.price / 2 end
			opt.price = tostring( opt.price )
			local numLength = string.len( opt.price )
			local shortPrice = ""
			local nicePrice = "$"
			if ( numLength == 8 ) then
				shortPrice = string.Left( opt.price, 4 )
				nicePrice = nicePrice .. string.Left( shortPrice, 2 )
				if ( string.GetChar( shortPrice, 3 ) ~= "0" or string.GetChar( shortPrice, 4 ) ~= "0" ) then
					nicePrice = nicePrice .. "." .. string.GetChar( shortPrice, 3 ) .. string.GetChar( shortPrice, 4 )
				end
				nicePrice = nicePrice .. "mil"
			elseif ( numLength == 7 ) then
				shortPrice = string.Left( opt.price, 3 )
				if ( string.GetChar( shortPrice, 2 ) ~= "0" or string.GetChar( shortPrice, 3 ) ~= "0" ) then
					nicePrice = nicePrice .. string.Left( shortPrice, 1 ) .. "." .. string.Right( shortPrice, 2 )
				else
					nicePrice = nicePrice .. string.Left( shortPrice, 1 )
				end
				nicePrice = nicePrice .. "mil"
			elseif ( numLength == 6 ) then
				shortPrice = string.Left( opt.price, 3 )
				nicePrice = nicePrice .. shortPrice
				if ( string.GetChar( opt.price, 4 ) ~= "0" ) then
					nicePrice = nicePrice .. "." .. string.GetChar( opt.price, 4 )
				end
				nicePrice = nicePrice .. "k"
			elseif ( numLength == 5 ) then
				shortPrice = string.Left( opt.price, 2 )
				nicePrice = nicePrice .. shortPrice
				if ( string.GetChar( opt.price, 3 ) ~= "0" ) then
					nicePrice = nicePrice .. "." .. string.GetChar( opt.price, 3 )
				end
				nicePrice = nicePrice .. "k"
			else
				nicePrice = nicePrice .. opt.price
			end
			dButton:SetText( opt.text .. " -> " .. nicePrice )
		end
		dButton:SetButtonColor( Color( 52, 152, 219, 255 ) )
		dButton:SetHoverColor( Color( 102, 202, 219, 255 ) )
		dButton:SetTextFont( "N00BRP_NPCDerma_MediumFont" )
		dButton:SetTextColor( Color( 255, 255, 255, 255 ) )
		dButton:ModifyTextXPosMultiplier( 0.4 ) // Not sure why this is necessary, otherwise text position is off.
		dButton.OnMousePressed = function( btn )
			net.Start( "npc_noob" )
				net.WriteEntity( ent )
				net.WriteString( index )
			net.SendToServer( )
			dFrame:Remove( )
		end
	end
	for index, opt in pairs ( tab ) do
		if not ( opt.stage ) then continue end
		local dButton = dScrollList:AddElement( "DN00B_ColoredButton" )
		dButton:SetSize( dFrame:GetWide( ), dFrame:GetTall( ) * 0.1 )
		dButton:SetText( opt.text )
		dButton:SetButtonColor( Color( 26, 188, 156, 255 ) )
		dButton:SetHoverColor( Color( 56, 188, 186, 255 ) )
		dButton:SetTextFont( "N00BRP_NPCDerma_MediumFont" )
		dButton:SetTextColor( Color( 255, 255, 255, 255 ) )
		dButton:ModifyTextXPosMultiplier( 0.4 )
		dButton.OnMousePressed = function( btn )
			net.Start( "npc_noob" )
				net.WriteEntity( ent )
				net.WriteString( index )
				net.WriteString( opt.stage )
			net.SendToServer( )
			dFrame:Remove( )
		end
	end
end

net.Receive( "npc_noob", function()
	create_panel( LocalPlayer():GetEyeTrace().Entity, net.ReadTable() );
end );

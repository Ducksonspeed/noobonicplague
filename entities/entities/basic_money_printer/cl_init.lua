include("shared.lua")
surface.CreateFont( "N00BRP_MoneyPrinters_DermaFont", {
	font = "Tahoma",
	size = ScreenScale( 12 ),
	weight = 600
} )

surface.CreateFont( "N00BRP_MoneyPrinters_StatFont", {
	font = "Tahoma",
	size = 36,
	weight = 500
} )
surface.CreateFont( "N00BRP_MoneyPrinters_StatFontBold", {
	font = "Tahoma",
	size = 55,
	weight = 750
} )

function ENT:Draw( )
	self:DrawModel( )

	local pos = self:GetPos( )
	local ang = self:GetAngles()

	local owner = self:Getowning_ent( )
	owner = ( IsValid( owner ) and owner:Nick( ) ) or DarkRP.getPhrase("unknown" )

	ang:RotateAroundAxis( ang:Up(), 90 )
	ang:RotateAroundAxis( ang:Forward(), 90 )

	local textPosition = pos + ( ang:Up( ) * 8.15 ) + ( ang:Right( ) * -1.75 ) + ( ang:Forward( ) * -9.5 )
	local redShade = math.abs( math.sin( CurTime( ) * 4 ) * 100 ) + 150
	cam.Start3D2D( textPosition, ang, 0.02)
		draw.SimpleText( "Power Remaining:", "N00BRP_MoneyPrinters_StatFont", 0, 0, Color( 255, 255, 255, 255), TEXT_ALIGN_LEFT )
		if ( self:GetPower( ) > 0 ) then
			draw.RoundedBoxEx( 0, 256, 13, 600, 24, Color( 170, 45, 45, 255 ) )
			draw.RoundedBoxEx( 0, 256, 13, 600 * ( self:GetPower( ) / 100 ), 24, Color( 45, 170, 45, 255 ) )
		else
			draw.SimpleText( "INSUFFICIENT POWER", "N00BRP_MoneyPrinters_StatFont", 256, 5, Color( redShade, 45, 45, 255), TEXT_ALIGN_LEFT )
		end
		draw.SimpleText( "Ink Remaining:", "N00BRP_MoneyPrinters_StatFont", 0, 44, Color( 255, 255, 255, 255), TEXT_ALIGN_LEFT )
		if ( self:GetInk( ) > 0 ) then
			draw.RoundedBoxEx( 0, 210, 50, 600, 24, Color( 170, 45, 45, 255 ) )
			draw.RoundedBoxEx( 0, 210, 50, 600 * ( self:GetInk( ) / 100 ), 24, Color( 45, 45, 170, 255 ) )
		else
			draw.SimpleText( "REFILL INK CARTRIDGES", "N00BRP_MoneyPrinters_StatFont", 210, 47, Color( redShade, 45, 45, 255), TEXT_ALIGN_LEFT )
		end
		draw.SimpleText( "Number of Cores:", "N00BRP_MoneyPrinters_StatFont", 0, 88, Color( 255, 255, 255, 255), TEXT_ALIGN_LEFT )
		draw.SimpleText( self:GetCPU( ), "N00BRP_MoneyPrinters_StatFontBold", 240, 82.5, Color( 170, 45, 45, 255), TEXT_ALIGN_LEFT )
		draw.SimpleText( "Owner: " .. owner, "N00BRP_MoneyPrinters_StatFont", 0, 128, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
	cam.End3D2D()
end

local function Open_Options_Menu( len )
	local mesType = net.ReadInt( 8 )
	local printEnt = net.ReadEntity( )
	local isAdv = ( printEnt:GetClass( ) == "adv_money_printer" )
	if ( mesType == printEnt.OPEN_CLIENT_MENU ) then
		local printerOptionsPanel = vgui.Create( "DPanel" )
		local pwrBtnOffset, inkBtnOffset, cpuBtnOffset = 0, 0, 0
		if ( isAdv ) then
			printerOptionsPanel:SetSize( ScrW( ) / 4, ScrH( ) / 2 )
			pwrBtnOffset, inkBtnOffset, cpuBtnOffset = -( ScrH( ) * 0.14 ), -( ScrH( ) * 0.07 ), 0
		else
			printerOptionsPanel:SetSize( ScrW( ) / 4, ScrH( ) / 3 )
			pwrBtnOffset, inkBtnOffset, cpuBtnOffset = -( ScrH( ) * 0.083 ), 0, ScrH( ) * 0.083
		end
		printerOptionsPanel:Center( )
		printerOptionsPanel:MakePopup( )
		printerOptionsPanel.Paint = function( self, w, h )
			draw.RoundedBoxEx( 4, 0, 0, w, h, Color( 45, 45, 45, 225 ) )
			draw.RoundedBoxEx( 4, w*0.075, h*0.075, w*0.85, h*0.85, Color( 255, 255, 255, 245 ) )
			draw.SimpleText( "Printer Management", "N00BRP_MoneyPrinters_DermaFont", w / 2, h * 0.075, Color( 45, 45, 45, 255 ), TEXT_ALIGN_CENTER )
			if ( printerOptionsPanel.hoverCost ) then
				local posAdditive = 0
				if ( isAdv ) then
					posAdditive = 0.015
				end
				draw.RoundedBoxEx( 4, w * 0.25, h * 0.84, w * 0.5, h * 0.06, Color( 25, 25, 25, 225 ) )
				draw.SimpleText( "$" .. printerOptionsPanel.hoverCost, "N00BRP_MoneyPrinters_DermaFont", w / 2, h * ( 0.83 + posAdditive ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
			end
		end
		printerOptionsPanel.hoverCost = nil
		printerOptionsPanel.Think = function( )
			if not ( IsValid( printEnt ) ) then
				printerOptionsPanel:Remove( )
			end
		end
		local addPowerBtn = vgui.Create( "DButton", printerOptionsPanel )
		addPowerBtn:SetSize( ScrW( ) / 6, ScrH( ) / 24 )
		addPowerBtn:Center( )
		local pPosX, pPosY = addPowerBtn:GetPos( )
		addPowerBtn:SetPos( pPosX, pPosY + pwrBtnOffset )
		addPowerBtn:SetText( "Replenish Power" )
		addPowerBtn:SetFont( "N00BRP_MoneyPrinters_DermaFont" )
		addPowerBtn.OnCursorEntered = function( )
			printerOptionsPanel.hoverCost = ( 100 - ( 100 * ( printEnt:GetPower( ) / 100 ) ) ) * printEnt.POWER_COST_MULTI
		end
		addPowerBtn.OnCursorExited = function( )
			printerOptionsPanel.hoverCost = nil
		end
		addPowerBtn.OnMousePressed = function( btn )
			net.Start( "N00BRP_MoneyPrinters_Options" )
				net.WriteInt( printEnt.REPLENISH_POWER, 8 )
				net.WriteEntity( printEnt )
			net.SendToServer( )
		end
		local refillInkBtn = vgui.Create( "DButton", printerOptionsPanel )
		refillInkBtn:SetSize( ScrW( ) / 6, ScrH( ) / 24 )
		refillInkBtn:Center( )
		local iPosX, iPosY = refillInkBtn:GetPos( )
		refillInkBtn:SetPos( iPosX, iPosY + inkBtnOffset )
		refillInkBtn:SetText( "Refill Ink" )
		refillInkBtn:SetFont( "N00BRP_MoneyPrinters_DermaFont" )
		refillInkBtn.OnCursorEntered = function( )
			printerOptionsPanel.hoverCost = ( 100 - ( 100 * ( printEnt:GetInk( ) / 100 ) ) ) * printEnt.INK_COST_MULTI
		end
		refillInkBtn.OnCursorExited = function( )
			printerOptionsPanel.hoverCost = nil
		end
		refillInkBtn.OnMousePressed = function( btn )
			net.Start( "N00BRP_MoneyPrinters_Options" )
				net.WriteInt( printEnt.REFILL_INK, 8 )
				net.WriteEntity( printEnt )
			net.SendToServer( )
		end
		local upgradeCPUBtn = vgui.Create( "DButton", printerOptionsPanel )
		upgradeCPUBtn:SetSize( ScrW( ) / 6, ScrH( ) / 24 )
		upgradeCPUBtn:Center( )
		local cPosX, cPosY = upgradeCPUBtn:GetPos( )
		upgradeCPUBtn:SetPos( cPosX, cPosY + cpuBtnOffset )
		upgradeCPUBtn:SetText( "Upgrade CPU" )
		upgradeCPUBtn:SetFont( "N00BRP_MoneyPrinters_DermaFont" )
		upgradeCPUBtn.OnCursorEntered = function( )
			printerOptionsPanel.hoverCost = printEnt:GetCPU( ) * printEnt.CPU_COST_MULTI
		end
		upgradeCPUBtn.OnCursorExited = function( )
			printerOptionsPanel.hoverCost = nil
		end
		upgradeCPUBtn.OnMousePressed = function( btn )
			net.Start( "N00BRP_MoneyPrinters_Options" )
				net.WriteInt( printEnt.UPGRADE_CPU, 8 )
				net.WriteEntity( printEnt )
			net.SendToServer( )
		end
		local closeBtn = vgui.Create( "DButton", printerOptionsPanel )
		closeBtn:SetSize( ScrW( ) * 0.02, printerOptionsPanel:GetTall( ) * 0.05 )
		closeBtn:SetPos( printerOptionsPanel:GetWide( ) * 0.85, printerOptionsPanel:GetTall( ) * 0.075 )
		closeBtn:SetTextColor( Color( 170, 45, 45, 255 ) )
		closeBtn:SetText( "X" )
		closeBtn.OnMousePressed = function( btn )
			printerOptionsPanel:Remove( )
		end
		if ( isAdv ) then
			local restoreCoolantBtn = vgui.Create( "DButton", printerOptionsPanel )
			restoreCoolantBtn:SetSize( ScrW( ) / 6, ScrH( ) / 24 )
			restoreCoolantBtn:Center( )
			local coPosX, coPosY = restoreCoolantBtn:GetPos( )
			restoreCoolantBtn:SetPos( coPosX, coPosY + ( ScrH( ) * 0.07 ) )
			restoreCoolantBtn:SetText( "Restore Coolant" )
			restoreCoolantBtn:SetFont( "N00BRP_MoneyPrinters_DermaFont" )
			restoreCoolantBtn.OnCursorEntered = function( )
				printerOptionsPanel.hoverCost = ( 100 - ( 100 * ( printEnt:GetCoolant( ) / 100 ) ) ) * printEnt.COOLANT_COST_MULTI
			end
			restoreCoolantBtn.OnCursorExited = function( )
				printerOptionsPanel.hoverCost = nil
			end
			restoreCoolantBtn.OnMousePressed = function( btn )
				net.Start( "N00BRP_MoneyPrinters_Options" )
					net.WriteInt( printEnt.RESTORE_COOLANT, 8 )
					net.WriteEntity( printEnt )
				net.SendToServer( )
			end
			local upgradeRAMBtn = vgui.Create( "DButton", printerOptionsPanel )
			upgradeRAMBtn:SetSize( ScrW( ) / 6, ScrH( ) / 24 )
			upgradeRAMBtn:Center( )
			local rPosX, rPosY = upgradeRAMBtn:GetPos( )
			upgradeRAMBtn:SetPos( rPosX, rPosY + ( ScrH( ) * 0.14 ) )
			upgradeRAMBtn:SetText( "Upgrade RAM" )
			upgradeRAMBtn:SetFont( "N00BRP_MoneyPrinters_DermaFont" )
			upgradeRAMBtn.OnCursorEntered = function( )
				printerOptionsPanel.hoverCost = printEnt:GetRAM( ) * printEnt.RAM_COST_MULTI
			end
			upgradeRAMBtn.OnCursorExited = function( )
				printerOptionsPanel.hoverCost = nil
			end
			upgradeRAMBtn.OnMousePressed = function( btn )
				net.Start( "N00BRP_MoneyPrinters_Options" )
					net.WriteInt( printEnt.UPGRADE_RAM, 8 )
					net.WriteEntity( printEnt )
				net.SendToServer( )
			end
		end
	end
end
net.Receive( "N00BRP_MoneyPrinters_Options", Open_Options_Menu )
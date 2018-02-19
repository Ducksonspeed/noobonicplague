hook.Add( "ChatText", "NoobDisconnectMessageRemove", function( index, name, text, msg )
	if ( msg == "joinleave" ) then
		if ( text:lower():find( "disconnected by user" ) ) then return false; end
		return true;
	end
end );

net.Receive( "noobadmin_chatcolor", function()
	chat.AddText( net.ReadTable(), net.ReadString() );
end );

surface.CreateFont( "NPGUI_ESPLABEL_PRIMARY", {
	font = "Segoe UI Bold",
	size = 20,
	weight = 900,
} )

surface.CreateFont( "NPGUI_ESPLABEL_PRIMARY_S", {
	font = "Segoe UI Bold",
	size = 20,
	weight = 900,
	blursize = 4
} )

local function DrawInfoText( txt, x, y, col )
	draw.DrawText( txt, "NPGUI_ESPLABEL_PRIMARY_S", x, y + 1, Color(0,0,0,255), TEXT_ALIGN_CENTER )
	draw.DrawText( txt, "NPGUI_ESPLABEL_PRIMARY", x, y, col, TEXT_ALIGN_CENTER )
end

local function SpectateESPPaint( )
	if ( LocalPlayer( ):GetObserverMode( ) == OBS_MODE_NONE ) then return end
	if not ( LocalPlayer( ):getDarkRPVar( "SpectateESP" ) ) then return end
	for index, ply in ipairs ( player.GetAll( ) ) do
		local textPos = ply:GetPos( )
		local textAng = ply:GetAngles( )
		local attachment = ply:LookupAttachment( "eyes" )
		local attachBone = ply:LookupBone( "ValveBiped.Bip01_Head1" )
		if ( attachment ) then
			local angPos = ply:GetAttachment( attachment )
			textPos, textAng =  angPos.Pos, angPos.Ang
		elseif ( attachBone ) then
			textPos, textAng = ply:GetBonePosition( attachBone )
		end
		local dist = LocalPlayer( ):GetPos( ):FastDist( ply:GetPos( ) )
		local namePos = ( textPos + Vector( 0, 0, 8 ) ):ToScreen( )
		DrawInfoText( ply:Name( ), namePos.x, namePos.y, team.GetColor( ply:Team( ) ) )
		if ( dist > 5000 ) then continue end
		local healthPos = ( textPos + Vector( 0, 0, 12 ) ):ToScreen( )
		DrawInfoText( ply:Health( ) .. "/" .. ply:GetMaxHealth( ), healthPos.x, healthPos.y, Color( 125, 175, 125 ) )
		local armorPos = ( textPos + Vector( 0, 0, 16 ) ):ToScreen( )
		DrawInfoText( ply:Armor( ) .. "/" .. 200, armorPos.x, armorPos.y, Color( 125, 125, 175 ) )
		if ( IsValid( ply:GetActiveWeapon( ) ) ) then
			local wepPos = ( textPos + Vector( 0, 0, 20 ) ):ToScreen( )
			DrawInfoText( ply:GetActiveWeapon( ):GetClass( ), wepPos.x, wepPos.y, Color( 175, 125, 125 ) )
		end
	end
end
hook.Add( "HUDPaint", "N00BRP_SpectateESPPaint_HUDPaint", SpectateESPPaint )

local function NoobAdminAlert( msg, priority )
	if ( !IsValid( LocalPlayer( ) ) or !isfunction( LocalPlayer( ).PrintMessage ) ) then return end
	if not ( LocalPlayer():SteamID() == "STEAM_0:0:33770352" ) and not ( LocalPlayer():SteamID() == "STEAM_0:0:20510578" ) then
		if NP_ADMIN_ALERTS[priority]["Sound"] then
			surface.PlaySound( NP_ADMIN_ALERTS[priority]["Sound"] )
		end
	end
	chat.AddText( NP_ADMIN_ALERTS[priority]["Color"], msg )
	
	if priority == NP_ADMIN_ATTENTION then
		LocalPlayer():PrintMessage( HUD_PRINTCENTER, msg )
	end
	if priority == NP_ADMIN_URGENT then
		LocalPlayer():PrintMessage( HUD_PRINTCENTER, msg )
		system.FlashWindow()
	end
end

net.Receive( "noobadmin_alert", function()
	local priority = net.ReadInt( 3 )
	local msg = net.ReadString()
	NoobAdminAlert( msg, priority )
end)
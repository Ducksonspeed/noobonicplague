--local ghostMaterial = "models/shadertest/shader3"
local invisMaterial = "models/effects/vol_light001"

surface.CreateFont( "NPGUI_DEATH_H1_S", {
	font = "Segoe UI Bold",
	size = ScreenScale( 10 ),
	weight = 500,
	blursize = 5,
	antialiasing = true
} )

surface.CreateFont( "NPGUI_DEATH_H1", {
	font = "Segoe UI Bold",
	size = ScreenScale( 10 ),
	weight = 500,
	blursize = 0,
	antialiasing = true
} )

surface.CreateFont( "NPGUI_DEATH_H2_S", {
	font = "Segoe UI Bold",
	size = ScreenScale( 8 ),
	weight = 500,
	blursize = 4,
	antialiasing = true
} )

surface.CreateFont( "NPGUI_DEATH_H2", {
	font = "Segoe UI Bold",
	size = ScreenScale( 8 ),
	weight = 500,
	blursize = 0,
	antialiasing = true
} )

surface.CreateFont( "N00BRP_GhostHUDIndicator_MediumText", {
	font = "Segoe UI",
	size = ScreenScale( 12 ),
	weight = 500,
	blursize = 0,
	antialiasing = true
} )

surface.CreateFont( "N00BRP_GhostHUDIndicator_MediumTextBlur", { 
	font = "Segoe UI", 
	size = ScreenScale( 12 ), 
	weight = 500, 
	antialiasing = true,
	blursize = 4
} )

local function DrawGhostHUD( )
	if ( LocalPlayer( ):IsGhost( ) ) then
	--if ( LocalPlayer( ):getDarkRPVar( "IsGhost" ) ) then
		//local timeToRespawn = LocalPlayer( ):GetNetworkedInt( "RespawnTime" )
		local timeToRespawn = LocalPlayer( ).respawnTime or 0
		if ( !timeToRespawn or timeToRespawn < CurTime( ) ) then return end
		//timeToRespawn = string.NiceTime( math.Clamp( LocalPlayer( ):GetNetworkedInt( "RespawnTime" ) - CurTime( ), 0, 3600 ) )
		timeToRespawn = string.NiceTime( math.Clamp( timeToRespawn - CurTime( ), 0, 3600 ) )
		timeToRespawn = string.upper( timeToRespawn )
		local deathLnOne = "YOU ARE DEAD"
		local deathLnTwo = "CONVINCE SOMEONE TO REVIVE YOU"
		local deathLnThree = "RESPAWN IN " .. timeToRespawn
		draw.SimpleText( deathLnOne, "NPGUI_DEATH_H1_S", ScrW( ) / 2, ScrH( ) - 128, Color( 255, 60, 0, 128 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( deathLnTwo, "NPGUI_DEATH_H2_S", ScrW( ) / 2, ScrH() - 92, Color( 255, 163, 0, 128 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( deathLnThree, "NPGUI_DEATH_H1_S", ScrW( ) / 2, ScrH() - 60, Color( 0, 172, 255, 128 ), TEXT_ALIGN_CENTER )		
		local greenShade = math.abs( math.sin( CurTime( ) * 4 ) * 100 ) + 150
		local redShade = math.abs( math.sin( CurTime( ) * 2 ) * 100 ) + 150
		draw.SimpleText( deathLnOne, "NPGUI_DEATH_H1", ScrW( ) / 2, ScrH( ) - 128, Color( 255, 149, 124, redShade ), TEXT_ALIGN_CENTER )
		draw.SimpleText( deathLnTwo, "NPGUI_DEATH_H2", ScrW( ) / 2, ScrH() - 92, Color( 255, 213, 139, greenShade ), TEXT_ALIGN_CENTER )
		draw.SimpleText( deathLnThree, "NPGUI_DEATH_H1", ScrW( ) / 2, ScrH() - 60, Color( 224, 245, 255, 255 ), TEXT_ALIGN_CENTER )
	end
end
hook.Add( "HUDPaint", "N00BRP_DrawGhostHUD_HUDPaint", DrawGhostHUD )

local function HidePlayerGhosts( ply )
	LocalPlayer( ):SetRenderMode( RENDERMODE_TRANSALPHA );
	ply:SetRenderMode( RENDERMODE_TRANSALPHA );
	--if ( LocalPlayer( ):getDarkRPVar( "IsGhost" ) ) then
	//if ( LocalPlayer( ):GetNetworkedBool( "IsGhost" ) ) then
	if ( LocalPlayer( ):IsGhost( ) or LocalPlayer():getDarkRPVar("IsStealthed") ) then
		hook.Call( "N00BRP_ModifyPlayerColor", { }, LocalPlayer( ), Color( 255, 255, 255, 100 ) )
		--if ( ply:getDarkRPVar( "IsGhost" ) ) then
		//if ( ply:GetNetworkedBool( "IsGhost" ) ) then
		if ( ply:IsGhost( ) ) then
			hook.Call( "N00BRP_ModifyPlayerColor", { }, ply, Color( 255, 255, 255, 100 ) )
		else
			hook.Call( "N00BRP_ModifyPlayerColor", { }, ply, Color( 255, 255, 255, 255 ) )
		end
	else
		hook.Call( "N00BRP_ModifyPlayerColor", { }, LocalPlayer( ), Color( 255, 255, 255, 255 ) )
		//if ( ply:GetNetworkedBool( "IsGhost" ) ) then
		if ( ply:IsGhost( ) or ply:getDarkRPVar("IsStealthed") ) then
		--if ( ply:getDarkRPVar( "IsGhost" ) ) then
			hook.Call( "N00BRP_ModifyPlayerColor", { }, ply, Color( 255, 255, 255, 0 ) )
		else
			hook.Call( "N00BRP_ModifyPlayerColor", { }, ply, Color( 255, 255, 255, 255 ) )
		end
	end
end
hook.Add( "PostPlayerDraw", "N00BRP_HidePlayerGhosts_PostPlayerDraw", HidePlayerGhosts )


local function RenderGhostScreenspace( )
	local tab =
	{
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = 0,
		["$pp_colour_contrast"] = 0.35,
		["$pp_colour_colour"] = 0,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	}
	--if ( LocalPlayer( ):getDarkRPVar( "IsGhost" ) ) then
	//if ( LocalPlayer( ):GetNetworkedBool( "IsGhost" ) ) then
	if ( LocalPlayer( ):IsGhost( ) ) then
		local toyTownDisabled = tobool( tonumber( GetConVarNumber( "noobrp_disableghosttoytown" ) or 1 ) )
		DrawColorModify( tab )
		if not ( toyTownDisabled ) then
			DrawToyTown( 4,	 ScrH( ) )
		end
	end
end
hook.Add( "RenderScreenspaceEffects", "N00BRP_RenderGhostScreenspace_RenderScreenspaceEffects", RenderGhostScreenspace )

local function ToggleGhostCollision( len )
	local collisionEntity = net.ReadEntity( )
	local toggleCollision = net.ReadBit( )
	if ( IsValid( collisionEntity ) ) then
		toggleCollision = tobool( toggleCollision )
		if ( toggleCollision ) then
			collisionEntity:SetNotSolid( false )
			collisionEntity:SetCollisionGroup( COLLISION_GROUP_PLAYER )
		else
			collisionEntity:SetNotSolid( true )
			collisionEntity:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
		end
	end
end
net.Receive( "N00BRP_GhostMode_ToggleCollision", ToggleGhostCollision )
SWEP.PrintName = "Spy Kit"
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Author = "Sinavestos : Rewritten By Jeezy"
SWEP.Instructions = "Left click to choose disguise, right click to remove disguise"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	= "rpg"
SWEP.ViewModel = "models/weapons/cstrike/c_pist_p228.mdl"
SWEP.WorldModel = "models/weapons/w_package.mdl"

SWEP.Spawnable = false
SWEP.AdminSpawnable = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.FrameVisible = false
SWEP.OnceReload = false
SWEP.DisguiseCooldown = 90
SWEP.DisguiseLength = 75
SWEP.Disguises = { TEAM_CITIZEN, TEAM_POLICE, TEAM_GANG, TEAM_PARAMEDIC, TEAM_SPECIALIST, TEAM_BARTENDER, TEAM_CRAB }

if ( SERVER ) then
	AddCSLuaFile( )
	local function TriggerDisguise( ply, cmd, args, fstring )
		local activeWeapon = ply:GetActiveWeapon( )
		if ( !IsValid( activeWeapon ) or activeWeapon:GetClass( ) ~= "spy_kit" ) then return end
		if not ( tonumber( args[1] ) ) then return end
		activeWeapon:ExecuteDisguise( args[1] )
	end
	concommand.Add( "_N00BRP-TriggerDisguise", TriggerDisguise )
else
	surface.CreateFont( "N00BRP_DisguiseKit_HUDFont", {
		font = "Tahoma",
		size = ScreenScale( 16 ),
		weight = 550
    } )
    surface.CreateFont( "N00BRP_DisguiseKit_DermaFont", {
		font = "Tahoma",
		size = ScreenScale( 14 ),
		weight = 550
    } )
end
function SWEP:Initialize()
	self:SetHoldType( "normal" )
	self:SetNextDisguise( CurTime( ) )
end

function SWEP:Deploy( )
	if not IsValid ( self.Owner ) then return end
	self.Owner:DrawViewModel( false )
end

function SWEP:Holster( wep )
	self.Owner:DrawViewModel( true )
	return true
end

function SWEP:OnRemove( )
	if not IsValid ( self.Owner ) then return end
	self.Owner:DrawViewModel( true )
end

function SWEP:SetupDataTables( )
	self:NetworkVar( "Int", 0, "NextDisguise" )
	self:NetworkVar( "Int", 1, "DisguiseLength" )
end

function SWEP:PrimaryAttack( )
	self:SetNextPrimaryFire( CurTime( ) + 1 )
	self:SetWeaponHoldType( "pistol" )
	timer.Simple( 0.2, function( ) 
		if ( IsValid( self ) ) then 
			self:SetHoldType( "normal" ) 
		end 
	end )
	if ( self:GetNextDisguise( ) > CurTime( ) ) then
		self:Notify( self.Owner, 1, 4, "You cannot disguise for another " .. string.NiceTime( self:GetNextDisguise( ) - CurTime( ) ) .. "." )
	else
		if ( CLIENT ) then self:ToggleDermaMenu( ) end
	end
end

function SWEP:Notify( ply, icon, length, message )
	if ( SERVER ) then
		DarkRP.notify( ply, icon, length, message )
	end
end

function SWEP:ExecuteDisguise( var )
	if ( self.Owner:IsDisguised( ) ) then
		self:Notify( self.Owner, 1, 4, "You're already disguised." )
		return
	elseif ( self:GetNextDisguise( ) > CurTime( ) ) then
		self:Notify( self.Owner, 1, 4, "You cannot disguise for another " .. string.NiceTime( self:GetNextDisguise( ) - CurTime( ) ) .. "." )
		return
	elseif ( !self:ValidDisguise( var ) ) then
		self:Notify( self.Owner, 1, 4, "That was an invalid disguise." )
		return
	end
	self.Owner:SetDisguised( tonumber( var ) )
	self:SetNextDisguise( CurTime( ) + self.DisguiseCooldown )
	self:SetDisguiseLength( CurTime( ) + self.DisguiseLength )
	local ownerRef = self.Owner
	timer.Create( ownerRef:EntIndex( ) .. ":DisguiseTimer", self.DisguiseLength, 1, function( )
		if ( !IsValid( ownerRef ) ) then return end
		ownerRef:SetDisguised( nil, true )
	end )
end

function SWEP:ValidDisguise( var )
	for index, disguise in ipairs ( self.Disguises ) do
		if ( tonumber( var ) == tonumber( disguise ) ) then

			return true
		end
	end
	return false
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire( CurTime( ) + 1 )
	self:SetHoldType( "pistol" )
	timer.Simple( 0.2, function( ) 
		if ( IsValid( self ) ) then
			self:SetHoldType("normal") 
		end 
	end )
	if not ( SERVER ) then return end
	if ( self.Owner:IsDisguised( ) ) then
		self.Owner:SetDisguised( nil, true )
	else
		self:Notify( self.Owner, 1, 4, "You're not disguised at the moment." )
	end
end

function SWEP:DrawHUD( )
	if ( LocalPlayer( ):IsDisguised( ) and self:GetDisguiseLength( ) > CurTime( ) ) then
		local redShade = math.abs( math.sin( CurTime( ) * 3 ) * 100 ) + 150
		draw.SimpleText( "Disguise Duration", "N00BRP_DisguiseKit_HUDFont", ScrW( ), ScrH( ) * 0.93, Color( redShade, 255, 255, 255 ), TEXT_ALIGN_RIGHT )
		draw.SimpleText( string.NiceTime( self:GetDisguiseLength( ) - CurTime( ) ), "N00BRP_DisguiseKit_HUDFont", ScrW( ), ScrH( ) * 0.96, Color( redShade, 255, 255, 255 ), TEXT_ALIGN_RIGHT )
	end
end

function SWEP:ToggleDermaMenu( )

	if ( IsValid ( self.disguisePanel ) ) then return end

	local disguisePanel = vgui.Create( "DFrame" )
	disguisePanel:SetSize( ScrW( ) * 0.275, ScrH( ) * 0.2 )
	disguisePanel:Center( )
	disguisePanel:SetDraggable( false )
	disguisePanel:ShowCloseButton( false )
	disguisePanel:SetTitle( "" )
	disguisePanel:MakePopup( )
	disguisePanel.Paint = function( pnl, w, h )
		draw.RoundedBox( 8, 0, 0, w, h, Color( 5, 5, 5, 225 ) )
		draw.RoundedBox( 8, w * 0.1, h * 0.1, w * 0.8, h * 0.8, Color( 255, 255, 255, 200 ) )
	end
	local modelScrollPanel = vgui.Create( "DScrollPanel", disguisePanel )
	modelScrollPanel:SetSize( disguisePanel:GetWide( ) * 0.6, disguisePanel:GetTall( ) * 0.7 )
	modelScrollPanel:Center( )
	modelScrollPanel:SetPadding( 25 )
	--local oldModelScrollPanelPaint = modelScrollPanel.Paint
	/*modelScrollPanel.Paint = function( pnl, w, h )
		draw.RoundedBox( 8, 0, 0, w, h, Color( 175, 175, 175, 150 ) )
		return oldModelScrollPanelPaint( pnl, w, h )
	end*/
	local modelList = vgui.Create( "DIconLayout" )
	modelScrollPanel:AddItem( modelList )
	modelList:SetSize( disguisePanel:GetWide( ) * 0.7, disguisePanel:GetTall( ) * 0.7 )
	modelList:SetPos( 0, 0 )
	modelList:SetSpaceX( 5 )
	modelList:SetSpaceY( 5 )

	for index, disguise in ipairs ( self.Disguises ) do
		local disguiseIcon = modelList:Add( "SpawnIcon" )
		local modelVar = RPExtraTeams[ disguise ].model
		local chosenModel = ""
		if ( type( modelVar ) == "table" ) then
			chosenModel = modelVar[ math.random( #modelVar ) ]
		else
			chosenModel = modelVar
		end
		local disguiseIconOldPaint = disguiseIcon.Paint
		disguiseIcon.Paint = function( pnl, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, Color( 25, 25, 25, 225 ) )
			return disguiseIconOldPaint( pnl, w, h )
		end
		disguiseIcon:SetTooltip( team.GetName( disguise ) )
		disguiseIcon:SetModel( chosenModel )
		disguiseIcon.OnMousePressed = function( btnPnl, btn )
			LocalPlayer( ):ConCommand( "_N00BRP-TriggerDisguise " .. disguise )
			disguisePanel:Close( )
		end
	end
	local closeButton = vgui.Create( "DN00B_ColoredButton", disguisePanel )
	closeButton:SetSize( disguisePanel:GetWide( ) * 0.10, disguisePanel:GetTall( ) * 0.125 )
	closeButton:AlignRight( disguisePanel:GetWide( ) * 0.095 )
	closeButton:AlignTop( disguisePanel:GetTall( ) * 0.095 )
	closeButton:SetText( "X" )
	closeButton:SetTextFont( "N00BRP_DisguiseKit_DermaFont" )
	closeButton:SetButtonColor( Color( 25, 25, 25 ) )
	closeButton:SetTextColor( Color( 231, 76, 60 ) )
	closeButton:SetRoundness( 4 )
	closeButton:SetHoverColor( Color( 45, 175, 45 ) )
	closeButton.OnMousePressed = function( btnPnl, btn )
		disguisePanel:Close( )
	end
	/*local closeButton = vgui.Create( "DButton", disguisePanel )
	closeButton:SetSize( disguisePanel:GetWide( ) * 0.125, disguisePanel:GetTall( ) * 0.15 )
	closeButton:SetPos( disguisePanel:GetWide( ) * 0.86, disguisePanel:GetTall( ) * 0.175 )
	closeButton:SetText( "X" )
	closeButton:SetFont( "N00BRP_DisguiseKit_HUDFont" )
	closeButton:SetTextColor( Color( 175, 45, 45 ) )
	closeButton.OnMousePressed = function( btnPnl, btn )
		disguisePanel:Remove( )
	end*/

	self.disguisePanel = disguisePanel
end
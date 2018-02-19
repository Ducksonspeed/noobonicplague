include( "shared.lua" )

SWEP.PrintName			= "Potion Launcher"			
SWEP.Author				= "Jeezy"

SWEP.Slot				= 1
SWEP.SlotPos			= 4
SWEP.WepIconBounceRate = 2
SWEP.WepIconBounceOffset = 14
surface.CreateFont( "N00BRP_PotionLauncherIcon", { font = "HalfLife2", size = ScreenScale( 64 ), weight = 750, antialiasing = true, blursize = 0 } )
surface.CreateFont( "N00BRP_PotionLauncherBlur", { font = "HalfLife2", size = ScreenScale( 64 ), weight = 750, antialiasing = true, blursize = 4 } )
surface.CreateFont( "N00BRP_PotionLauncherText", {
	font = "Lobster",
	size = ScreenScale( 8 ),
	weight = 600
} )

surface.CreateFont( "N00BRP_PotionLauncherTextSmall", {
	font = "Lobster",
	size = ScreenScale( 6 ),
	weight = 600
} )

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	local iconPos = { x = x + wide / 2, y = y }
	local txtBounce = math.abs( math.sin( CurTime( ) * self.WepIconBounceRate ) ) * self.WepIconBounceOffset
	for i = 1, 5 do
		draw.SimpleText( "l", "N00BRP_PotionLauncherBlur", iconPos.x, iconPos.y + txtBounce, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER )
	end
	draw.SimpleText( "l", "N00BRP_PotionLauncherIcon", iconPos.x, iconPos.y + txtBounce, Color( 45, 45, 255, 255 ), TEXT_ALIGN_CENTER )
end

function SWEP:Deploy( )
	self.potionSelectorOpen = false
	self.selectedPotion = ""
	self:SendSelectedPotion( )
end

function SWEP:Initialize( )
	timer.Simple( 0.1, function( ) -- Like serverside, it appears the owner isn't valid right away.
		if ( self and self:IsValid( ) and self.Owner and self.Owner:IsValid( ) ) then
			self.clientsideModels = { }
			self:AddClientsideModels( )	
		end
	end )
end

function SWEP:OnRemove( )
	if not ( istable( self.clientsideModels ) ) then return end
	for index, mdl in ipairs ( self.clientsideModels ) do
		SafeRemoveEntity( mdl )
	end
	self.clientsideModels = { }
end

function SWEP:AddClientsideModels( )
	local potionEntity = ClientsideModel( "models/props/jeezy/potions/potion01.mdl" )
	local potionEntityMatrix = Matrix()
	potionEntityMatrix:Scale( Vector( 0.35, 0.35, 0.35 ) )
	potionEntity:EnableMatrix( "RenderMultiply", potionEntityMatrix )
	potionEntity:SetParent( self.Owner:GetViewModel( ) )
	potionEntity.vmPosOffset = Vector( 0, -3.75, 7 )
	potionEntity.vmAngOffset = Angle( 75, 280, 105 )
	potionEntity.wmPosOffset = Vector( 5, 0.3, -7.8 )
	potionEntity.wmAngOffset = Angle( 80, -1.532, 180 )
	potionEntity.vmBone = "Base"
	potionEntity.wmBone = "ValveBiped.Bip01_R_Hand"
	potionEntity.entSkin = 0
	potionEntity:SetNoDraw( true )
	table.insert( self.clientsideModels, potionEntity )
	local sideBeam = ClientsideModel( "models/props_combine/combine_fence01a.mdl" )
	local sideBeamMatrix = Matrix()
	sideBeamMatrix:Scale( Vector( 0.1, 0.1, 0.1 ) )
	sideBeam:EnableMatrix( "RenderMultiply", sideBeamMatrix )
	sideBeam:SetParent( self.Owner:GetViewModel( ) )
	sideBeam.vmPosOffset = Vector( 0, -1, 0 )
	sideBeam.vmAngOffset = Angle( 0, 65, 2 )
	sideBeam.wmPosOffset = Vector( 10.9, 0.5, -6.8 )
	sideBeam.wmAngOffset = Angle( -101.7, -180, -178.831 )
	sideBeam.vmBone = "Base"
	sideBeam.wmBone = "ValveBiped.Bip01_R_Hand"
	sideBeam:SetNoDraw( true )
	table.insert( self.clientsideModels, sideBeam )
end
function SWEP:ViewModelDrawn( vm )
	if ( self.clientsideModels ) then
		for index, mdl in ipairs ( self.clientsideModels ) do
			local boneID = vm:LookupBone( mdl.vmBone )
			if ( boneID ) then
				local vmPos, vmAngles = vm:GetBonePosition( boneID )
				local pos = mdl.vmPosOffset
				local ang = mdl.vmAngOffset
				mdl:SetPos( vmPos  + ( vmAngles:Forward( ) * pos.x ) + ( vmAngles:Right( ) * pos.y ) + ( vmAngles:Up( ) * pos.z ) )
				vmAngles:RotateAroundAxis( vmAngles:Right( ), ang.p )
				vmAngles:RotateAroundAxis( vmAngles:Up( ), ang.y )
				vmAngles:RotateAroundAxis( vmAngles:Forward( ), ang.r )
				mdl:SetAngles( vmAngles )	
				if ( mdl.entSkin ) then
					mdl:SetSkin( self:GetPotionSkin( ) )
				end			
				mdl:DrawModel( )
			end
		end
	end
	if ( self:GetIsFiring( ) and system.HasFocus( ) ) then
		local partData = EffectData( )
		local shootOffset = ( self.Owner:EyeAngles( ):Forward( ) * 40 + self.Owner:EyeAngles( ):Up( ) * -5 + self.Owner:EyeAngles( ):Right( ) * 5 )
		partData:SetStart( vm:GetPos( ) + shootOffset )
		partData:SetOrigin( vm:GetPos( ) + shootOffset )
		partData:SetScale( 2 )
		util.Effect( "PotionLauncherMuzzleBurst", partData )
	end
end

function SWEP:PreDrawViewModel ( )
	Material( "models/weapons/v_irifle/v_irifle" ):SetVector( "$color2", Vector( 0.4, 0.4, 0.9 ) )
end

function SWEP:PostDrawViewModel( )
	Material( "models/weapons/v_irifle/v_irifle" ):SetVector( "$color2", Vector( 1, 1, 1 ) )
end

function SWEP:DrawWorldModel( )
	render.SetColorModulation( 0.4, 0.4, 0.9 )
	self:DrawModel( )
	render.SetColorModulation( 1, 1, 1 )
	if ( self.clientsideModels ) then
		for index, mdl in ipairs ( self.clientsideModels ) do
			local boneID = self.Owner:LookupBone( mdl.wmBone )
			if ( boneID ) then
				local wmPos, wmAngles = self.Owner:GetBonePosition( boneID )
				local pos = mdl.wmPosOffset
				local ang = mdl.wmAngOffset
				mdl:SetPos( wmPos + ( wmAngles:Forward( ) * pos.x ) + ( wmAngles:Right( ) * pos.y ) + ( wmAngles:Up( ) * pos.z ) )
				wmAngles:RotateAroundAxis( wmAngles:Right( ), ang.p )
				wmAngles:RotateAroundAxis( wmAngles:Up( ), ang.y )
				wmAngles:RotateAroundAxis( wmAngles:Forward( ), ang.r )
				mdl:SetAngles( wmAngles )
				if ( mdl.entSkin ) then
					mdl:SetSkin( self:GetPotionSkin( ) )
				end
				mdl:DrawModel( )
			end
		end
	end
	if ( self:GetIsFiring( ) and system.HasFocus( ) ) then
		local partData = EffectData( )
		local shootOffset = ( self.Owner:EyeAngles( ):Forward( ) * 40 + self.Owner:EyeAngles( ):Up( ) * -15 + self.Owner:EyeAngles( ):Right( ) * 10 )
		partData:SetStart( self.Owner:GetShootPos( ) + shootOffset )
		partData:SetOrigin( self.Owner:GetShootPos( ) + shootOffset )
		partData:SetScale( 2 )
		util.Effect( "PotionLauncherMuzzleBurst", partData )
	end
end

function SWEP:DrawHUD( )
	if not ( self.potionSelectorOpen ) then
		draw.RoundedBox( 4, ScrW( ) * 0.785, ScrH( ) * 0.94, ScrW( ) * 0.195, ScrH( ) * 0.03, Color( 192, 57, 43, 145 ) )
		draw.SimpleText( "Press 'R' To Open Potion Selector", "N00BRP_PotionLauncherText", ScrW( ) * 0.795, ScrH( ) * 0.943, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT )
		return 
	end
	local potionName = ""
	local potionAmt = 0
	self.currentPotions = self.currentPotions or { }
	self.potionSelectPos = self.potionSelectPos or 0
	potionName, potionAmt = self:GetSelectedPotion( )
	if not ( potionName ) then
		draw.RoundedBox( 4, ScrW( ) * 0.775, ScrH( ) * 0.94, ScrW( ) * 0.21, ScrH( ) * 0.03, Color( 192, 57, 43, 145 ) )
		draw.SimpleText( "There Are No Potions In Your Pocket", "N00BRP_PotionLauncherText", ScrW( ) * 0.785, ScrH( ) * 0.943, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT )
		return
	end
	surface.SetFont( "N00BRP_PotionLauncherText" )
	local titleWide, titleHeight = surface.GetTextSize( "Name" )
	local headerHeight = ScrH( ) * 0.01 + titleHeight
	draw.RoundedBox( 4, ScrW( ) * 0.7, ScrH( ) * 0.88, ScrW( ) * 0.29, headerHeight, Color( 26, 188, 156, 145 ) )
	draw.RoundedBox( 4, ScrW( ) * 0.7, ( ScrH( ) * 0.88 ) + headerHeight, ScrW( ) * 0.29, ScrH( ) * 0.04, Color( 22, 160, 133, 145 ) )
	draw.RoundedBox( 4, ScrW( ) * 0.93, ScrH( ) * 0.88, ScrW( ) * 0.06, ( ScrH( ) * 0.04 ) + headerHeight, Color( 41, 128, 185, 100 ) )
	draw.SimpleText( "Potion Name", "N00BRP_PotionLauncherText", ScrW( ) * 0.71, ( ScrH( ) * 0.875 ) + headerHeight - titleHeight, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT )
	draw.SimpleText( "Amount", "N00BRP_PotionLauncherText", ScrW( ) * 0.98, ( ScrH( ) * 0.875 ) + headerHeight - titleHeight, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT )
	draw.SimpleText( potionName, "N00BRP_PotionLauncherText", ScrW( ) * 0.71, ScrH( ) * 0.92, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT )
	draw.SimpleText( potionAmt, "N00BRP_PotionLauncherText", ScrW( ) * 0.96, ScrH( ) * 0.92, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
	local nextPotion = self:GetFollowingPotion( false )
	if not ( nextPotion ) then return end
	draw.RoundedBox( 4, ScrW( ) * 0.7, ScrH( ) * 0.88 - headerHeight, ScrW( ) * 0.17, ScrH( ) * 0.03, Color( 52, 152, 219, 145 ) )
	draw.SimpleText( "Right Click To Switch To Next Potion", "N00BRP_PotionLauncherTextSmall", ScrW( ) * 0.71, ScrH( ) * 0.885 - headerHeight, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT )
	draw.RoundedBox( 4, ScrW( ) * 0.7, ( ScrH( ) * 0.92 ) + headerHeight, ScrW( ) * 0.23, ScrH( ) * 0.04, Color( 39, 174, 96, 145 ) )
	draw.SimpleText( "Next: " .. tostring( nextPotion ), "N00BRP_PotionLauncherText", ScrW( ) * 0.71, ScrH( ) * 0.96, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT )
end

function SWEP:SecondaryAttack( )
	self.nextPotionSwitch = self.nextPotionSwitch or 0
	if ( self.nextPotionSwitch > CurTime( ) ) then return end
	self.nextPotionSwitch = CurTime( ) + 1
	self.potionSelectPos = self.potionSelectPos or 0
	self.potionSelectPos = self.potionSelectPos + 1
	self.currentPotions = self.currentPotions or { }
	if ( self.potionSelectPos > ( table.Count( self.currentPotions ) - 1 ) ) then
		self.potionSelectPos = 0
	end
	local potionName, potionAmt = self:GetSelectedPotion( )
	self.selectedPotion = potionName
	self:SendSelectedPotion( )
end

function SWEP:SendSelectedPotion( )
	if ( self.selectedPotion ) then
		net.Start( "N00BRP_PotionLauncherNET" )
			net.WriteString( self.selectedPotion )
		net.SendToServer( )
	end 
end

function SWEP:GetSelectedPotion( )
	local potionName, potionAmt = nil, nil
	local curPos = 0
	for index, potion in pairs ( self.currentPotions ) do
		if ( self.potionSelectPos == curPos ) then
			potionName = potion.name
			potionAmt = potion.amt
			break
		end
		curPos = curPos + 1
	end
	return potionName, potionAmt
end

function SWEP:GetFollowingPotion( )
	local potionName = nil
	local curPos = 0
	local goalPos = self.potionSelectPos + 1
	if ( goalPos > table.Count( self.currentPotions ) - 1 ) then
		goalPos = 0
	end
	for index, potion in pairs ( self.currentPotions ) do
		if ( goalPos == curPos ) then
			if ( potion.name ~= self.selectedPotion ) then
				potionName = potion.name
				break
			end
		end
		curPos = curPos + 1
	end
	return potionName
end

function SWEP:Reload( )
	self.nextPotionMenuOpen = self.nextPotionMenuOpen or 0
	if ( self.nextPotionMenuOpen > CurTime( ) ) then return end
	self.nextPotionMenuOpen = CurTime( ) + 1
	if ( self.potionSelectorOpen ) then
		self.potionSelectorOpen = false
	else
		self.potionSelectorOpen = true
		self:GeneratePotionList( )
		timer.Simple( 0.1, function( )
		local potionName, potionAmt = self:GetSelectedPotion( )
		self.selectedPotion = potionName
		self:SendSelectedPotion( ) end )
	end
end

function SWEP:PrimaryAttack( )
	self.nextPotionFire = self.nextPotionFire or 0
	if ( self.nextPotionFire > CurTime( ) ) then return end
	self.nextPotionFire = CurTime( ) + 1
	timer.Simple( 0.1, function( )
		if not ( IsValid( self ) ) then return end
		self:GeneratePotionList( )
		self:SelectPotionPos( )
	end )
end

function SWEP:SelectPotionPos( )
	local curPos = 0
	self.currentPotions = self.currentPotions or { }
	if not ( self.selectedPotion ) then return end
	local foundPotion = false
	for index, potion in pairs ( self.currentPotions ) do
		if ( index == self.selectedPotion ) then
			foundPotion = curPos
			break
		end
		curPos = curPos + 1
	end
	if not ( foundPotion ) then
		self.potionSelectPos = 0
		self.selectedPotion = self:GetSelectedPotion( )
		self:SendSelectedPotion( )
	else
		self.potionSelectPos = curPos
	end
end

function SWEP:GeneratePotionList( )
	self.currentPotions = { }
	for index, item in pairs ( LocalPlayer( ):getPocketItems( ) ) do
		if ( item.class == "ent_alchemypotion" ) then
			self.currentPotions[item.name] = self.currentPotions[item.name] or { name = item.name, amt = 0 }
			self.currentPotions[item.name].amt = self.currentPotions[item.name].amt + 1
		end
	end
end
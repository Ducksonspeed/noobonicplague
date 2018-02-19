local hatModels = { }
local backItemModels = { }

local function EnableLocalPlayerItemVisibility( ply )
	if ( ply == LocalPlayer( ) ) then
		if ( !ply:ShouldDrawLocalPlayer( ) and ply:GetViewEntity( ):GetClass( ) ~= "gmod_cameraprop" ) then
			return false
		else
			if ( ply:GetObserverMode( ) ~= OBS_MODE_NONE ) then
				return false
			else
				return true
			end
		end
		if ( ply:GetObserverMode( ) ~= OBS_MODE_NONE ) then
			return false
		end
	else
		if ( ply:GetObserverMode( ) ~= OBS_MODE_NONE ) then
			return false
		else
			return true
		end
	end
end

local function PositionClientsideEntity( ply, ent, entData )
	local pos, ang = ply:GetPos( ), ply:GetAngles( )
	if ( entData.AttachmentType == ENUM_HAT_BONE ) then
		local attachBone = ply:LookupBone( entData.ParentName )
		if ( attachBone ) then
			pos, ang = ply:GetBonePosition( attachBone )
		end
	elseif ( entData.AttachmentType == ENUM_HAT_ATTACHMENT ) then
		local attachment = ply:LookupAttachment( entData.ParentName )
		if ( attachment ) then
			local AngPos = ply:GetAttachment( attachment )
			pos, ang = AngPos.Pos, AngPos.Ang
		end
	end
	local upOffset = ang:Up( ) * entData.UpOffset or 0
	local rightOffset = ang:Right( ) * entData.RightOffset or 0
	local forwardOffset = ang:Forward( ) * entData.ForwardOffset or 0
	local pitchOffset = entData.PitchOffset or 0
	local yawOffset = entData.YawOffset or 0
	local rollOffset = entData.RollOffset or 0
	local modelScale = entData.ModelScale or 1
	local modelColor = entData.ModelColor or Color( 255, 255, 255, 255 )
	local modelMaterial = entData.ModelMaterial or ""
	local modelSkin = entData.Skin or 0
	if ( entData.ModelAdjustments or entData.ModelAdjustmentsWildcard ) then
		local adjTbl = nil
		if ( entData.ModelAdjustments ) then
			adjTbl = entData.ModelAdjustments[ team.GetName( ply:Team( ) ) ]
		end
		if not ( adjTbl ) then
			if ( entData.ModelAdjustmentsWildcard ) then
				for index, wildcard in pairs ( entData.ModelAdjustmentsWildcard ) do
					if ( string.find( string.lower( ply:GetModel( ) ), index ) ) then
						adjTbl = entData.ModelAdjustmentsWildcard[ index ]
						break
					end
				end
			end
		end
		if ( adjTbl ) then
			upOffset = ang:Up( ) * ( adjTbl.UpOffset or 0 )
			rightOffset = ang:Right( ) * ( adjTbl.RightOffset or 0 )
			forwardOffset = ang:Forward( ) * ( adjTbl.ForwardOffset or 0 )
			modelScale = adjTbl.ModelScale or 1
		end
	end

	if ( ply:getDarkRPVar( "IsStealthed" ) ) then
		render.SetBlend( 0 )
	else
		render.SetBlend( 1 )
	end
	ent:SetModelScale( modelScale, 0 )
	render.SetColorModulation( modelColor.r/255, modelColor.g/255, modelColor.b/255 )
	ent:SetMaterial( modelMaterial )
	ent:SetSkin( modelSkin )
	ang:RotateAroundAxis( ang:Right( ), pitchOffset )
	ang:RotateAroundAxis( ang:Up( ), yawOffset )
	ang:RotateAroundAxis( ang:Forward( ), rollOffset )

	ent:SetPos( pos + upOffset + rightOffset + forwardOffset )

	ent:SetAngles( ang )
end

local function DrawClientsideHats( )
	for index, ply in ipairs ( player.GetAll( ) ) do
		if ( ply:getDarkRPVar( "HatClass" ) ) then
			local posData = NOOBRP.Config.HatData[ ply:getDarkRPVar( "HatClass" ) ]
			if not ( IsValid( ply.clHat ) ) then
				ply.clHat = ClientsideModel( posData.Model, RENDERGROUP_BOTH )
				ply.clHat:SetRenderMode( RENDERMODE_TRANSCOLOR )
				ply.clHat.OwningEnt = ply
				ply.clHat.Class = posData.Class
				ply.clHat:SetParent( ply )
				ply.clHat:SetNoDraw( true )
				table.insert( hatModels, ply.clHat )
			else
				local HatData = posData
				if ( ply.clHat.Class ~= HatData.Class ) then
					local didRemove = table.RemoveByValue( hatModels, ply.clHat )
					SafeRemoveEntity( ply.clHat )
					return
				end
				PositionClientsideEntity( ply, ply.clHat, HatData )
				local shouldDraw = EnableLocalPlayerItemVisibility( ply )
				//if ( shouldDraw and !ply:getDarkRPVar( "IsGhost" ) ) then
				if ( shouldDraw and !ply:IsGhost( ) ) then
					ply.clHat:DrawModel( )
				end
			end
		elseif ( !ply:getDarkRPVar( "HatClass" ) and IsValid( ply.clHat ) ) then
			SafeRemoveEntity( ply.clHat )
		end
		if ( ply:getDarkRPVar( "BackItemClass" ) ) then
			local posData = NOOBRP.Config.BackItemData[ ply:getDarkRPVar( "BackItemClass" ) ]
			if not ( IsValid( ply.clBackItem ) ) then
				ply.clBackItem = ClientsideModel( posData.Model, RENDERGROUP_BOTH )
				ply.clBackItem:SetRenderMode( RENDERMODE_TRANSCOLOR )
				ply.clBackItem.OwningEnt = ply
				ply.clBackItem.Class = posData.Class
				ply.clBackItem:SetParent( ply )
				ply.clBackItem:SetNoDraw( true )
				table.insert( backItemModels, ply.clBackItem )
			else
				local BackItemData = posData
				if ( ply.clBackItem.Class ~= BackItemData.Class ) then
					local didRemove = table.RemoveByValue( backItemModels, ply.clBackItem )
					SafeRemoveEntity( ply.clBackItem )
					return
				end
				PositionClientsideEntity( ply, ply.clBackItem, posData )
				local shouldDraw = EnableLocalPlayerItemVisibility( ply )
				//if ( shouldDraw and !ply:getDarkRPVar( "IsGhost" ) ) then
				if ( shouldDraw and !ply:IsGhost( ) ) then
					ply.clBackItem:DrawModel( )
					if ( isfunction( BackItemData.ItemFunc ) ) then
						BackItemData.ItemFunc( ply, ply.clBackItem )
					end
				end
			end
		elseif ( !ply:getDarkRPVar( "BackItemClass" ) and IsValid( ply.clBackItem ) ) then
			SafeRemoveEntity( ply.clBackItem )
		end
	end
	for index, hat in ipairs ( hatModels ) do
		if not ( IsValid( hat.OwningEnt ) ) then
			SafeRemoveEntity( hat )
			table.remove( hatModels, index )
		end
	end
	for index, backItem in ipairs ( backItemModels ) do
		if not ( IsValid( backItem.OwningEnt ) ) then
			SafeRemoveEntity( backItem )
			table.remove( backItemModels, index )
		end
	end
end
hook.Add( "PostDrawOpaqueRenderables", "N00BRP_DrawClientsideHats_PostDrawOpaqueRenderables", DrawClientsideHats )

local function ModifyPlayerColor( ply, color )
	if ( ply:getDarkRPVar( "IsStealthed" ) ) then
		ply:SetMaterial( "models/effects/vol_light001" )
		if ( IsValid( ply:GetActiveWeapon( ) ) ) then
			ply:GetActiveWeapon( ):SetNoDraw( true )
		end
		return
	else
		ply:SetMaterial( "" )
		if ( IsValid( ply:GetActiveWeapon( ) ) ) then
			ply:GetActiveWeapon( ):SetNoDraw( false )
		end
	end
	local colorMod = ply:getDarkRPVar( "PlayerColorMod" )
	ply:SetRenderMode( RENDERMODE_TRANSCOLOR )
	//if ( ply:GetNetworkedBool( "IsGhost" ) ) then
	if ( ply:IsGhost( ) ) then
		ply:SetColor( color )
		return
	elseif ( colorMod ) then
		ply:SetColor( Color( colorMod.r, colorMod.g, colorMod.b, colorMod.a ) )
		return
	end
	/*if ( ply:GetNetworkedBool( "NoDrawPlayer" ) == true or ply:GetObserverMode( ) ~= OBS_MODE_NONE ) then
		ply:SetColor( Color( 0, 0, 0, 0 ) )
		return
	end*/
	ply:SetColor( color )
end
hook.Add( "N00BRP_ModifyPlayerColor", "N00BRP_ModifyPlayerColor_ModifyPlayerColor", ModifyPlayerColor )

local function ThirdPersonView( ply, pos, angles, fov )
	local thirdPersonEnabled = tobool( tonumber( GetConVarNumber( "noobrp_thirdperson" ) or 0 ) )
	local view = {}
	if ( ply:InVehicle( ) ) then return end
	if ( IsValid( ply:GetActiveWeapon( ) ) and ply:GetActiveWeapon( ):GetClass( ) == "noob_camera" ) then return end
	if ( ply:IsWearingHat( "golden_beast_hat" ) and ply.isViewingEventMeter and game.GetMap( ) ~= "lair_of_the_Beast8" and ply:Alive( ) and !ply:IsGhost( ) ) then
		local eventMeter = ents.FindByClass( "event_meter" )[1]
		view.origin = eventMeter:GetPos( ) + eventMeter:GetAngles( ):Up( ) * 80 + eventMeter:GetAngles( ):Right( ) * 25
		return view
	end
	if ( thirdPersonEnabled ) then
		local camPos = pos - ( angles:Forward( ) * 100 )
		local traceData = { }
		traceData.start = pos
		traceData.endpos = camPos
		traceData.filter = self
		local traceRes = util.TraceLine( traceData )
		if ( traceRes.Hit ) then camPos = traceRes.HitPos end
		view.origin = camPos
		view.angles = angles
		view.fov = fov
		return view
	end
end
hook.Add( "CalcView", "N00BRP_ThirdPersonView_CalcView", ThirdPersonView )

local function DrawLocalPlayer( ply )
	local thirdPersonEnabled = tobool( tonumber( GetConVarNumber( "noobrp_thirdperson" ) or 1 ) )
	if ( IsValid( ply:GetActiveWeapon( ) ) and ply:GetActiveWeapon( ):GetClass( ) == "noob_camera" ) then 
		if ( ply:GetActiveWeapon( ):GetHoldType( ) == "pistol" ) then
			return true
		else
			return ( thirdPersonEnabled )
		end
	end
	if ( thirdPersonEnabled ) then
		return true
	else
		return false
	end
end
hook.Add( "ShouldDrawLocalPlayer", "N00BRP_ThirdPersonView_ShouldDrawLocalPlayer", DrawLocalPlayer )

local function OnClientInitialized( )
	if ( game.GetMap( ) == "lair_of_the_Beast8" ) then
		chat.AddText( COLOR_RED, "YOU HAVE AWOKEN THE BEAST FROM HIS SLUMBER, PREPARE YOURSELF!" )
	else
		timer.Create( "N00BRP_AreaEnterChecker", 5, 0, function( )
			local foundArea = LocalPlayer( ):LookFor( )
			if ( foundArea ) then
				if ( LocalPlayer( ).lastEnteredArea == foundArea ) then return end
				chat.AddText( Color( 175, 175, 255 ), "You have arrived at " .. foundArea .. "!" )
				LocalPlayer( ).lastEnteredArea = foundArea
			else
				LocalPlayer( ).lastEnteredArea = nil
			end
		end )
	end
end
hook.Add( "InitPostEntity", "N00BRP_OnClientInitialized_InitPostEntity", OnClientInitialized )
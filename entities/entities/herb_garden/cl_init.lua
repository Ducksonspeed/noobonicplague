include( "shared.lua" )
surface.CreateFont( "N00BRP_HerbGarden_ButtonFont", {
	font = "Lobster",
	size = ScreenScale( 10 ),
	weight = 600,
	blursize = 0,
} )
surface.CreateFont( "N00BRP_HerbGarden_BoldSmallFont", {
	font = "Lobster",
	size = ScreenScale( 8 ),
	weight = 750,
	blursize = 0,
} )
surface.CreateFont( "N00BRP_HerbGarden_SmallFont", {
	font = "Lobster",
	size = ScreenScale( 6 ),
	weight = 750,
	blursize = 0,
} )

ENT.GrowthTable = {
	[1] = Vector( 0.1, 0.1, 0.6 ),
	[2] = Vector( 0.12, 0.12, 0.8 ),
	[3] = Vector( 0.12, 0.12, 1.1 ),
	[4] = Vector( 0.12, 0.12, 1.5 )
}

ENT.GrowthNames = {
	[0] = "Not Planted",
	[1] = "Sprouting",
	[2] = "Halfway Grown",
	[3] = "Nearly Grown",
	[4] = "Fully Grown"
}

function ENT:Initialize( )
	local planterMatrix = Matrix( )
	planterMatrix:Scale( Vector( 1, 1.5, 1 ) )
	self:EnableMatrix( "RenderMultiply", planterMatrix )
end

function ENT:OnRemove( )
	SafeRemoveEntity( self.clModelPlantOne )
	SafeRemoveEntity( self.clModelPlantTwo )
	SafeRemoveEntity( self.clModelPlantThree )
	SafeRemoveEntity( self.clModelPlantFour )
end

function ENT:RandomModel( )
	return "models/props/de_inferno/largebush0" .. tostring( math.random( 3, 6 ) ) .. ".mdl"
end

function ENT:Draw( )
	self:DrawModel( )
	local pos = self:GetPos( )
	local ang = self:GetAngles( )

	if ( !self.Getowning_ent or !self.GetPlantOneStage or !self.GetPlantTwoStage  or !self.GetPlantThreeStage or !self.GetPlantFourStage ) then
		return
	end
	local owner = self:Getowning_ent( )
	if ( IsValid( owner ) ) then 
		owner = owner:Name( )
	else
		owner = "Unknown"
	end

	local textPosition = pos + ( ang:Up( ) * 8.25 ) + ( ang:Right( ) * -18 ) + ( ang:Forward( ) * -11 )
	local textAngs = ang
	textAngs:RotateAroundAxis( ang:Forward( ), 90 )
	textAngs:RotateAroundAxis( ang:Right( ), 90 )
	cam.Start3D2D( textPosition, textAngs, 0.15 )
		draw.SimpleText( owner .. "'s Planter", "N00BRP_MoneyPrinters_StatFont", 0, 0, Color( 255, 255, 255, 255), TEXT_ALIGN_LEFT )
	cam.End3D2D( )
	local plantHydrationTable = string.Explode( ";", self:GetPlantsHydration( ) )
	local plantOneHydration = ( plantHydrationTable[1] / 100 ) * 175
	local plantTwoHydration = ( plantHydrationTable[2] / 100 ) * 175
	local plantThreeHydration = ( plantHydrationTable[3] / 100 ) * 175
	local plantFourHydration = ( plantHydrationTable[4] / 100 ) * 175
	local plantOnePos = pos + ( ang:Forward( ) * -40 )
	local plantTwoPos = pos + ( ang:Forward( ) * -15 )
	local plantThreePos = pos + ( ang:Forward( ) * 15 )
	local plantFourPos = pos + ( ang:Forward( ) * 40  )
	local plantGreen = ( math.abs( math.sin( CurTime( ) * 0.5 ) ) * 75 ) + 75
	local growthSinWave = Vector( 0, 0, math.sin( CurTime( ) ) * 0.05 )
	if ( !IsValid( self.clModelPlantOne ) ) then
		self.clModelPlantOne = ClientsideModel( self:RandomModel( ), RENDERGROUP_BOTH )
		self.clModelPlantOne:SetPos( plantOnePos )
		self.clModelPlantOne:SetParent( self )
	else
		if ( !self:GetPlantOneStage( ) or self:GetPlantOneStage( ) == 0 ) then
			self.clModelPlantOne:SetNoDraw( true )
		elseif ( self:GetPlantOneStage( ) > 0 ) then
			self.clModelPlantOne:SetNoDraw( false )
			self.clModelPlantOne:SetColor( Color( plantOneHydration, plantGreen, plantOneHydration ) )
			local plantMatrix = Matrix( )
			plantMatrix:Scale( self.GrowthTable[ self:GetPlantOneStage( ) ] + growthSinWave )
			self.clModelPlantOne:EnableMatrix( "RenderMultiply", plantMatrix )
		end
	end
	if ( !IsValid( self.clModelPlantTwo ) ) then
		self.clModelPlantTwo = ClientsideModel( self:RandomModel( ), RENDERGROUP_BOTH )
		self.clModelPlantTwo:SetPos( plantTwoPos )
		self.clModelPlantTwo:SetParent( self )
	else
		if ( !self:GetPlantTwoStage( ) or self:GetPlantTwoStage( ) == 0 ) then
			self.clModelPlantTwo:SetNoDraw( true )
		elseif ( self:GetPlantTwoStage( ) > 0 ) then
			self.clModelPlantTwo:SetNoDraw( false )
			self.clModelPlantTwo:SetColor( Color( plantTwoHydration, plantGreen, plantTwoHydration ) )
			local plantMatrix = Matrix( )
			plantMatrix:Scale( self.GrowthTable[ self:GetPlantTwoStage( ) ] + -growthSinWave )
			self.clModelPlantTwo:EnableMatrix( "RenderMultiply", plantMatrix )
		end
	end
	if ( !IsValid( self.clModelPlantThree ) ) then
		self.clModelPlantThree = ClientsideModel( self:RandomModel( ), RENDERGROUP_BOTH )
		self.clModelPlantThree:SetPos( plantThreePos )
		self.clModelPlantThree:SetParent( self )
	else
		if ( !self:GetPlantThreeStage( ) or self:GetPlantThreeStage( ) == 0 ) then
			self.clModelPlantThree:SetNoDraw( true )
		elseif ( self:GetPlantThreeStage( ) > 0 ) then
			self.clModelPlantThree:SetNoDraw( false )
			self.clModelPlantThree:SetColor( Color( plantThreeHydration, plantGreen, plantThreeHydration ) )
			local plantMatrix = Matrix( )
			plantMatrix:Scale( self.GrowthTable[ self:GetPlantThreeStage( ) ] + growthSinWave )
			self.clModelPlantThree:EnableMatrix( "RenderMultiply", plantMatrix )
		end
	end
	if ( !IsValid( self.clModelPlantFour ) ) then
		self.clModelPlantFour = ClientsideModel( self:RandomModel( ), RENDERGROUP_BOTH )
		self.clModelPlantFour:SetPos( plantFourPos )
		self.clModelPlantFour:SetParent( self )
	else
		if ( !self:GetPlantFourStage( ) or self:GetPlantFourStage( ) == 0 ) then
			self.clModelPlantFour:SetNoDraw( true )
		elseif ( self:GetPlantFourStage( ) > 0 ) then
			self.clModelPlantFour:SetNoDraw( false )
			self.clModelPlantFour:SetColor( Color( plantFourHydration, plantGreen, plantFourHydration ) )
			local plantMatrix = Matrix( )
			plantMatrix:Scale( self.GrowthTable[ self:GetPlantFourStage( ) ] + -growthSinWave )
			self.clModelPlantFour:EnableMatrix( "RenderMultiply", plantMatrix )
		end
	end
end

function ENT:SendPlantHerb( index )
	net.Start( "N00BRP_HerbGarden_NET" )
		net.WriteUInt( self.PLANT_HERB, 8 )
		net.WriteEntity( self )
		net.WriteUInt( index, 8 )
	net.SendToServer( )
end

function ENT:SendHarvestPlant( index )
	net.Start( "N00BRP_HerbGarden_NET" )
		net.WriteUInt( self.HARVEST_HERB, 8 )
		net.WriteEntity( self )
		net.WriteUInt( index, 8 )
	net.SendToServer( )
end

function ENT:SendWaterPlant( index )
	net.Start( "N00BRP_HerbGarden_NET" )
		net.WriteUInt( self.WATER_HERB, 8 )
		net.WriteEntity( self )
		net.WriteUInt( index, 8 )
	net.SendToServer( )
end

function ENT:OpenGardenMenu( gardenEntity )
	local dPanel = vgui.Create( "DPanel" )
	dPanel.gardenEntity = gardenEntity
	dPanel:SetSize( ScrW( ) * 0.4, ScrH( ) * 0.25 )
	dPanel:Center( )
	dPanel.hoverCost = nil
	gui.EnableScreenClicker( true )
	local hydrationString = "100;100;100;100"
	local plantOneGrowth, plantTwoGrowth, plantThreeGrowth, plantFourGroth = 0, 0, 0, 0
	local growthNameTable = { }
	if ( IsValid( dPanel.gardenEntity ) ) then
		local gardenEnt = dPanel.gardenEntity
		hydrationString = gardenEnt:GetPlantsHydration( )
		plantOneGrowth, plantTwoGrowth, plantThreeGrowth, plantFourGrowth = gardenEnt:GetPlantOneStage( ), gardenEnt:GetPlantTwoStage( ), gardenEnt:GetPlantThreeStage( ), gardenEnt:GetPlantFourStage( )
		growthNameTable = gardenEnt.GrowthNames
	end
	local hydrationTable = string.Explode( ";", hydrationString )
	dPanel.Paint = function( pnl, w, h )
		draw.RoundedBox( 4, 0, 0, w, h, Color( 22, 160, 133, 255 ) )
		draw.RoundedBox( 4, w * 0.16, h * 0.06, w * 0.68, h * 0.3, Color( 52, 73, 94, 200 ) )
		draw.RoundedBox( 4, w * 0.16, h * 0.38, w * 0.68, h * 0.55, Color( 52, 73, 94, 200 ) )
		draw.SimpleText( "Plant One", "N00BRP_HerbGarden_BoldSmallFont", w * 0.25, h * 0.05, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( "Hydration:", "N00BRP_HerbGarden_BoldSmallFont", w * 0.25, h * 0.11, Color( 46, 204, 113 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( hydrationTable[1] .. "/100", "N00BRP_HerbGarden_SmallFont", w * 0.25, h * 0.17, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( "Status:", "N00BRP_HerbGarden_BoldSmallFont", w * 0.25, h * 0.22, Color( 52, 152, 219 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( growthNameTable[plantOneGrowth] or "Invalid", "N00BRP_HerbGarden_SmallFont", w * 0.25, h * 0.29, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )

		draw.SimpleText( "Plant Two", "N00BRP_HerbGarden_BoldSmallFont", w * 0.41, h * 0.05, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( "Hydration:", "N00BRP_HerbGarden_BoldSmallFont", w * 0.41, h * 0.11, Color( 46, 204, 113 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( hydrationTable[2] .. "/100", "N00BRP_HerbGarden_SmallFont", w * 0.41, h * 0.17, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( "Status:", "N00BRP_HerbGarden_BoldSmallFont", w * 0.41, h * 0.22, Color( 52, 152, 219 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( growthNameTable[plantTwoGrowth] or "Invalid", "N00BRP_HerbGarden_SmallFont", w * 0.41, h * 0.29, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
		
		draw.SimpleText( "Plant Three", "N00BRP_HerbGarden_BoldSmallFont", w * 0.58, h * 0.05, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( "Hydration:", "N00BRP_HerbGarden_BoldSmallFont", w * 0.58, h * 0.11, Color( 46, 204, 113 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( hydrationTable[3] .. "/100", "N00BRP_HerbGarden_SmallFont", w * 0.58, h * 0.17, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( "Status:", "N00BRP_HerbGarden_BoldSmallFont", w * 0.58, h * 0.22, Color( 52, 152, 219 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( growthNameTable[plantThreeGrowth] or "Invalid", "N00BRP_HerbGarden_SmallFont", w * 0.58, h * 0.29, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
		
		draw.SimpleText( "Plant Four", "N00BRP_HerbGarden_BoldSmallFont", w * 0.75, h * 0.05, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( "Hydration:", "N00BRP_HerbGarden_BoldSmallFont", w * 0.75, h * 0.11, Color( 46, 204, 113 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( hydrationTable[4] .. "/100", "N00BRP_HerbGarden_SmallFont", w * 0.75, h * 0.17, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( "Status:", "N00BRP_HerbGarden_BoldSmallFont", w * 0.75, h * 0.22, Color( 52, 152, 219 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( growthNameTable[plantFourGrowth] or "Invalid", "N00BRP_HerbGarden_SmallFont", w * 0.75, h * 0.29, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
		if ( dPanel.hoverCost ) then
			draw.RoundedBox( 2, w * 0.85, h * 0.82, w * 0.14, h * 0.1, Color( 52, 73, 94, 200 ) )
			draw.SimpleText( "Cost", "N00BRP_HerbGarden_BoldSmallFont", w * 0.92, h * 0.75, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
			draw.SimpleText( "$" .. string.Comma( dPanel.hoverCost ), "N00BRP_HerbGarden_BoldSmallFont", w * 0.92, h * 0.83, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
		end
	end
	
	local actualIndexTable = { [1] = 4, [2] = 3, [3] = 2, [4] = 1 }
	for i = 1, 4 do
		local plantButton = vgui.Create( "DN00B_ColoredButton", dPanel )
		plantButton:SetSize( dPanel:GetWide( ) * 0.15, dPanel:GetTall( ) * 0.075 )
		plantButton:AlignTop( dPanel:GetTall( ) * 0.4 )
		plantButton:AlignRight( ( dPanel:GetWide( ) * 0.17 ) * i )
		plantButton:SetText( "Plant" )
		plantButton:SetTextFont( "N00BRP_HerbGarden_ButtonFont" )
		plantButton:SetButtonColor( Color( 26, 188, 156, 200 ) )
		plantButton:SetTextColor( Color( 255, 255, 255 ) )
		plantButton:SetRoundness( 4 )
		plantButton.OnMousePressed = function( btnPnl, btn )
		 	if ( IsValid( dPanel.gardenEntity ) and dPanel.gardenEntity:GetClass( ) == "herb_garden" ) then
		 		dPanel.gardenEntity:SendPlantHerb( actualIndexTable[i] )
		 		timer.Simple( 0.1, function( )
		 			if ( !ValidPanel( dPanel ) or !IsValid( dPanel.gardenEntity ) ) then return end
			 		local gardenEnt = dPanel.gardenEntity
			 		dPanel:Remove( )
			 		gardenEnt:OpenGardenMenu( gardenEnt )
			 	end )
		 	end
		end
		plantButton.OnCursorEntered = function( pnl, btn )
			local cost = 1000
			if ( IsValid( dPanel.gardenEntity ) ) then
				cost = dPanel.gardenEntity.PlantHerbCost
			end
			dPanel.hoverCost = cost
		end
		plantButton.OnCursorExited = function( pnl, btn )
			dPanel.hoverCost = nil
		end
		local harvestButton = vgui.Create( "DN00B_ColoredButton", dPanel )
		harvestButton:SetSize( dPanel:GetWide( ) * 0.15, dPanel:GetTall( ) * 0.075 )
		harvestButton:AlignTop( dPanel:GetTall( ) * 0.6 )
		harvestButton:AlignRight( ( dPanel:GetWide( ) * 0.17 ) * i )
		harvestButton:SetText( "Harvest" )
		harvestButton:SetTextFont( "N00BRP_HerbGarden_ButtonFont" )
		harvestButton:SetButtonColor( Color( 26, 188, 156, 200 ) )
		harvestButton:SetTextColor( Color( 255, 255, 255 ) )
		harvestButton:SetRoundness( 4 )
		harvestButton.OnMousePressed = function( btnPnl, btn )
		 	if ( IsValid( dPanel.gardenEntity ) and dPanel.gardenEntity:GetClass( ) == "herb_garden" ) then
		 		dPanel.gardenEntity:SendHarvestPlant( actualIndexTable[i] )
		 		timer.Simple( 0.1, function( )
		 			if ( !ValidPanel( dPanel ) or !IsValid( dPanel.gardenEntity ) ) then return end
			 		local gardenEnt = dPanel.gardenEntity
			 		dPanel:Remove( )
			 		gardenEnt:OpenGardenMenu( gardenEnt )
			 	end )
		 	end
		end
		local waterButton = vgui.Create( "DN00B_ColoredButton", dPanel )
		waterButton:SetSize( dPanel:GetWide( ) * 0.15, dPanel:GetTall( ) * 0.075 )
		waterButton:AlignTop( dPanel:GetTall( ) * 0.8 )
		waterButton:AlignRight( ( dPanel:GetWide( ) * 0.17 ) * i )
		waterButton:SetText( "Water" )
		waterButton:SetTextFont( "N00BRP_HerbGarden_ButtonFont" )
		waterButton:SetButtonColor( Color( 26, 188, 156, 200 ) )
		waterButton:SetTextColor( Color( 255, 255, 255 ) )
		waterButton:SetRoundness( 4 )
		waterButton.OnMousePressed = function( btnPnl, btn )
		 	if ( IsValid( dPanel.gardenEntity ) and dPanel.gardenEntity:GetClass( ) == "herb_garden" ) then
		 		dPanel.gardenEntity:SendWaterPlant( actualIndexTable[i] )
		 		timer.Simple( 0.1, function( )
		 			if ( !ValidPanel( dPanel ) or !IsValid( dPanel.gardenEntity ) ) then return end
			 		local gardenEnt = dPanel.gardenEntity
			 		dPanel:Remove( )
			 		gardenEnt:OpenGardenMenu( gardenEnt )
			 	end )
		 	end
		end
		waterButton.OnCursorEntered = function( pnl, btn )
			local multi = 10
			if ( IsValid( dPanel.gardenEntity ) ) then
				multi = dPanel.gardenEntity.WaterCostMultiplier
			end
			dPanel.hoverCost = ( 100 - tonumber( hydrationTable[ actualIndexTable[i] ] ) ) * multi
		end
		waterButton.OnCursorExited = function( pnl, btn )
			dPanel.hoverCost = nil
		end
	end

	local closeButton = vgui.Create( "DN00B_ColoredButton", dPanel )
	closeButton:SetSize( dPanel:GetWide( ) * 0.075, dPanel:GetTall( ) * 0.075 )
	closeButton:AlignTop( dPanel:GetTall( ) * 0.075 )
	closeButton:AlignRight( dPanel:GetWide( ) * 0.035 )
	closeButton:SetText( "X" )
	closeButton:SetTextFont( "N00BRP_HerbGarden_ButtonFont" )
	closeButton:SetButtonColor( Color( 26, 188, 156, 200 ) )
	closeButton:SetTextColor( Color( 175, 45, 45 ) )
	closeButton:SetRoundness( 4 )
	closeButton.OnMousePressed = function( btnPnl, btn )
	 	gui.EnableScreenClicker( false )
	 	dPanel:Remove( )
	end
	return dPanel
end

local function ReceiveHerbGardenNET( len )
	local messType = net.ReadUInt( 8 )
	local gardenEntity = net.ReadEntity( )
	if ( !IsValid( gardenEntity ) or gardenEntity:GetClass( ) ~= "herb_garden" ) then return end
	if ( messType == gardenEntity.OPEN_MENU ) then
		if not ( ValidPanel( LocalPlayer( ).herbGardenMenu ) ) then
			LocalPlayer( ).herbGardenMenu = gardenEntity:OpenGardenMenu( gardenEntity )
		end
	end
end
net.Receive( "N00BRP_HerbGarden_NET", ReceiveHerbGardenNET )
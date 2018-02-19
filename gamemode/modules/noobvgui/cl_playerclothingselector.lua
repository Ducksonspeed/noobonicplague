surface.CreateFont( "N00BRP_PlayerColorSelector_SmallText", {
	font = "Lobster",
	size = ScreenScale( 11 ),
	weight = 600,
	blursize = 0,
} )

surface.CreateFont( "N00BRP_PlayerColorSelector_LargeText", {
	font = "Lobster",
	size = ScreenScale( 12 ),
	weight = 750,
	blursize = 0,
} )

surface.CreateFont( "N00BRP_PlayerClothingSelector_LargeText", {
	font = "Lobster",
	size = 72,
	weight = 800,
	blursize = 0,
} )

PANEL = { }
local maleClothingTable = nil
local femaleClothingTable = nil
local currentIndex = 1
function PANEL:Init()
	maleClothingTable = maleClothingTable or table.GetKeys( NOOBRP.Config.MaleClothing )
	femaleClothingTable = femaleClothingTable or table.GetKeys( NOOBRP.Config.FemaleClothing )
	currentIndex = 1
    self:SetSize( ScrW( ) * 0.5, ScrH( ) * 0.6 )
    self:Center( )
    self.currentColor = Color( 255, 255, 255 )
    self:SetupClothingSelector( )
    gui.EnableScreenClicker( true )
end

function PANEL:SetupClothingSelector( )
	self.modelPanel = vgui.Create( "DN00B_ModelPanelPlus", self )
	self.modelPanel:ModifySize( self:GetWide( ) * 0.5, self:GetTall( ) * 0.9 )
	self.modelPanel:Center( )
	self.modelPanel:AlignTop( self:GetTall( ) * 0.05 )
	self.modelPanel:AlignLeft( self:GetWide( ) * 0.275 )
	self.modelPanel:LoadModel( LocalPlayer( ):GetModel( ) )
	self.modelPanel:SetModelFOV( ScreenScale( 15 ) )
	self.modelPanel:SetPlayerModelColor( self.currentColor )
	self.modelPanel:EnableHoverSpinning( 1 )
	self.modelPanel:SetModelPanelBG( Color( 255, 255, 255, 0 ) )
	if ( string.find( LocalPlayer( ):GetModel( ), "female" ) ) then
		self.modelPanel:SetSubMaterial( LocalPlayer( ):GetClothingIndex( ), femaleClothingTable[currentIndex] )
	else
		self.modelPanel:SetSubMaterial( LocalPlayer( ):GetClothingIndex( ), maleClothingTable[currentIndex] )
	end
	local nextButton = vgui.Create( "DN00B_ColoredButton", self )
	nextButton:SetSize( self:GetWide( ) * 0.15, self:GetTall( ) * 0.1 )
	nextButton:Center( )
	nextButton:AlignBottom( self:GetTall( ) * 0.45 )
	nextButton:AlignRight( self:GetWide( ) * 0.025 )
	nextButton:SetText( ">>" )
	nextButton:SetButtonColor( Color( 45, 45, 45, 0 ) )
	nextButton:SetTextFont( "N00BRP_PlayerClothingSelector_LargeText" )
	nextButton:SetTextColor( Color( 255, 255, 255, 255 ) )
	nextButton:SetRoundness( 6 )
	nextButton:SetHoverColor( Color( 26, 188, 156 ) )
	nextButton.OnMousePressed = function( btn )
		if ( string.find( LocalPlayer( ):GetModel( ), "female" ) ) then
			if ( currentIndex == #femaleClothingTable ) then
				currentIndex = 1
			else
				currentIndex = currentIndex + 1
			end
			self.modelPanel:SetSubMaterial( LocalPlayer( ):GetClothingIndex( ), femaleClothingTable[currentIndex] )
		else
			if ( currentIndex == #maleClothingTable ) then
				currentIndex = 1
			else
				currentIndex = currentIndex + 1
			end
			self.modelPanel:SetSubMaterial( LocalPlayer( ):GetClothingIndex( ), maleClothingTable[currentIndex] )
			print( maleClothingTable[currentIndex]  )
		end
	end
	local backButton = vgui.Create( "DN00B_ColoredButton", self )
	backButton:SetSize( self:GetWide( ) * 0.15, self:GetTall( ) * 0.1 )
	backButton:Center( )
	backButton:AlignBottom( self:GetTall( ) * 0.45 )
	backButton:AlignRight( self:GetWide( ) * 0.825 )
	backButton:SetText( "<<" )
	backButton:SetButtonColor( Color( 45, 45, 45, 0 ) )
	backButton:SetTextFont( "N00BRP_PlayerClothingSelector_LargeText" )
	backButton:SetTextColor( Color( 255, 255, 255, 255 ) )
	backButton:SetRoundness( 6 )
	backButton:SetHoverColor( Color( 26, 188, 156 ) )
	backButton.OnMousePressed = function( btn )
		if ( string.find( LocalPlayer( ):GetModel( ), "female" ) ) then
			if ( currentIndex == 1 ) then
				currentIndex = #femaleClothingTable
			else
				currentIndex = currentIndex - 1
			end
			self.modelPanel:SetSubMaterial( LocalPlayer( ):GetClothingIndex( ), femaleClothingTable[currentIndex] )
		else
			if ( currentIndex == 1 ) then
				currentIndex = #maleClothingTable
			else
				currentIndex = currentIndex - 1
			end
			self.modelPanel:SetSubMaterial( LocalPlayer( ):GetClothingIndex( ), maleClothingTable[currentIndex] )
		end
	end
	local confirmColorButton = vgui.Create( "DN00B_ColoredButton", self )
	confirmColorButton:SetSize( self:GetWide( ) * 0.325, self:GetTall( ) * 0.05 )
	confirmColorButton:Center( )
	confirmColorButton:AlignBottom( self:GetTall( ) * 0.035 )
	confirmColorButton:AlignRight( self:GetWide( ) * 0.2 )
	confirmColorButton:SetText( "Purchase ( $100 )" )
	confirmColorButton:SetButtonColor( Color( 255, 255, 255, 255 ) )
	confirmColorButton:SetTextFont( "N00BRP_PlayerColorSelector_LargeText" )
	confirmColorButton:SetTextColor( Color( 45, 45, 45, 255 ) )
	confirmColorButton:SetRoundness( 6 )
	confirmColorButton:SetHoverColor( Color( 26, 188, 156 ) )
	confirmColorButton.OnMousePressed = function( btn )
		local clothingString = ""
		if ( string.find( LocalPlayer( ):GetModel( ), "female" ) ) then
			clothingString = femaleClothingTable[currentIndex]
		else
			clothingString = maleClothingTable[currentIndex]
		end
		RunConsoleCommand( "rp_purchaseclothing", clothingString )
		gui.EnableScreenClicker( false )
		self:Remove( )
	end
	local cancelButton = vgui.Create( "DN00B_ColoredButton", self )
	cancelButton:SetSize( self:GetWide( ) * 0.26, self:GetTall( ) * 0.05 )
	cancelButton:Center( )
	cancelButton:AlignBottom( self:GetTall( ) * 0.035 )
	cancelButton:AlignRight( self:GetWide( ) * 0.535 )
	cancelButton:SetText( "Cancel" )
	cancelButton:SetButtonColor( Color( 255, 255, 255, 255 ) )
	cancelButton:SetTextFont( "N00BRP_PlayerColorSelector_LargeText" )
	cancelButton:SetTextColor( Color( 45, 45, 45, 255 ) )
	cancelButton:SetRoundness( 6 )
	cancelButton:SetHoverColor( Color( 26, 188, 156 ) )
	cancelButton.OnMousePressed = function( btn )
		gui.EnableScreenClicker( false )
		self:Remove( )
	end
end

function PANEL:SetCurrentColor( plyColor, wepColor )
	self.dRGBPicker:SetRGB( plyColor )
	self.dWepRGBPicker:SetRGB( wepColor )
	self.modelPanel:SetPlayerModelColor( plyColor )
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 8, 0, 0, w, h, Color( 45, 45, 45, 255 ) )
    draw.RoundedBox( 8, w * 0.2, h * 0.1, w * 0.6, h * 0.8, Color( 255, 255, 255, 255 ) )
end

vgui.Register( "N00BRP_PlayerClothingSelector", PANEL, "Panel" )

local function OpenClothingMenu( len )
	vgui.Create( "N00BRP_PlayerClothingSelector" )
end
net.Receive( "N00BRP_PlayerClothingMenu", OpenClothingMenu )
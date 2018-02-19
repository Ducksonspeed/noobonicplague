local defaultAnimations = { "idle_all_01", "menu_walk" }
PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW( ) * 0.3, ScrH( ) * 0.3 )
    self:CreateDModelPanel( )
    self.modelColor = Color( 255, 255, 255, 255 )
    self.modelMaterial = nil
    self.offsetX, self.offsetY, self.offsetZ = 0, 0, 0
    self.rotatingData = nil
    self.hoverSpinningEnabled = false
    self.hoverVariable = nil
    self.backgroundColor = Color( 25, 25, 25, 100 )
    self.iconRoundness = 0
    self.subMaterials = nil
end

function PANEL:SetHoverVariable( var )
	self.hoverVariable = var
end

function PANEL:EnableHoverSpinning( rate )
	self.dModelPanel.OnCursorEntered = function( )
		if ( self.hoverVariable ) then
			LocalPlayer( ).dModelPanelPlusHoverVariable = self.hoverVariable
		end
		self:SetRotatingData( rate )
	end
	self.dModelPanel.OnCursorExited = function( )
		if ( self.hoverVariable ) then
			LocalPlayer( ).dModelPanelPlusHoverVariable = nil
		end
		self:SetRotatingData( 0 )
	end
end

function PANEL:SetModelPanelBG( color )
	self.backgroundColor = color
end

function PANEL:SetModelFOV( amt )
	self.dModelPanel:SetFOV( amt )
end

function PANEL:SetRotatingData( rate )
	self.rotatingData = rate
end

function PANEL:SetModelColor( color )
	self.modelColor = color
end

function PANEL:SetModelMaterial( mat )
	self.modelMaterial = mat
end

function PANEL:SetModelOffset( x, y, z )
	self.offsetX, self.offsetY, self.offsetZ = x, y, z
end

function PANEL:SetModelRotation( angle )
	self.modelRotation = angle
end

function PANEL:SetSubMaterial( index, mat )
	self.subMaterials = self.subMaterials or { }
	self.subMaterials[index] = mat
end

function PANEL:SetRandomSequence( )
	self.currentAnim = defaultAnimations[ math.random( #defaultAnimations ) ]
	local animList = list.Get( "PlayerOptionsAnimations" )
	local niceName = player_manager.TranslateToPlayerModelName( self.dModelPanel.Entity:GetModel( ) )
	if ( animList[ niceName ] ) then
		local extraAnim = animList[ niceName ][ math.random( #animList[ niceName ] ) ]
		local newAnimTable = table.Copy( defaultAnimations )
		table.insert( newAnimTable, extraAnim )
		self.currentAnim = newAnimTable[ math.random( #newAnimTable ) ]
	end
	self.isSequenceLoaded = false
end

function PANEL:LoadModel( mdl )
	self.dModelPanel:SetModel( mdl )
	self:CalculateModelView( )
	self.dModelPanel.LayoutEntity = function( )
		self.dModelPanel:RunAnimation( )
		if ( self.modelMaterial ) then
			self.dModelPanel.Entity:SetMaterial( self.modelMaterial )
		end
		self.dModelPanel.Entity:SetColor( self.modelColor )
		self.dModelPanel.Entity:SetPos( Vector( self.offsetX, self.offsetY, self.offsetZ ) )
		if ( self.subMaterials ) then
			for index, mat in pairs( self.subMaterials ) do
				self.dModelPanel.Entity:SetSubMaterial( index, mat )
			end
		end
		if ( !self.isSequenceLoaded and self.currentAnim ) then
			local sequence = self.dModelPanel.Entity:LookupSequence( self.currentAnim )
			self.dModelPanel.Entity:SetSequence( sequence )
			self.dModelPanel.Entity:ResetSequence( sequence )
			self.isSequenceLoaded = true
		end
		if ( self.modelRotation ) then
			self.dModelPanel.Entity:SetAngles( self.modelRotation )
		end
		if ( self.rotatingData ) then
			local entAngs = self.dModelPanel.Entity:GetAngles( )
			entAngs:RotateAroundAxis( entAngs:Up( ), math.sin( CurTime( ) ) * self.rotatingData )
			self.dModelPanel.Entity:SetAngles( entAngs )
		end
	end
end 

function PANEL:SetPlayerModelColor( color )
	if not ( IsValid( self.dModelPanel.Entity ) ) then return end
	self.dModelPanel.Entity.GetPlayerColor = function( ) 
		return ( Vector( color.r / 255, color.g / 255, color.b / 255 ) )
	end 
end

function PANEL:CreateDModelPanel( )
	self.dModelPanel = vgui.Create( "DModelPanel", self )
	self.dModelPanel:SetSize( self:GetWide( ), self:GetTall( ) )
	self.dModelPanel:Center( )
end

function PANEL:CalculateModelView( x, y, z, div )
	local xMult, yMult, zMult = x or 0.75, y or 0.75, z or 0.5
	local boundsDiv = div or 2
	local renderMins, renderMaxs = self.dModelPanel.Entity:GetRenderBounds( )
	self.dModelPanel:SetCamPos( renderMins:Distance( renderMaxs ) * Vector( xMult, yMult, zMult ) )
	self.dModelPanel:SetLookAt( ( renderMaxs + renderMins ) / boundsDiv )
end

function PANEL:LookAtBone( bone, fallBackX, fallBackY, fallBackZ )
	local fBackX, fBackY, fBackZ = fallBackX or 30, fallBackY or 10, fallBackZ or 75
	local bonePos = self.dModelPanel.Entity:GetBonePosition( self.dModelPanel.Entity:LookupBone( bone ) )
	if ( bonePos ) then
		self.dModelPanel:SetLookAt( bonePos )
	else
		self.dModelPanel:SetCamPos( Vector( fBackX, fBackY, fBackZ ) )
	end
end

function PANEL:SetEntityEyeTarget( vecX, vecY, vecZ )
	local vX, vY, vZ = vecX or 20, vecY or 0, vecZ or 65
end

function PANEL:ModifySize( w, h )
	self:SetSize( w, h )
	self.dModelPanel:SetSize( w, h )
	self.dModelPanel:Center( )
end

function PANEL:Paint( w, h )
    draw.RoundedBox( self.iconRoundness, 0, 0, w, h, self.backgroundColor )
end

vgui.Register( "DN00B_ModelPanelPlus", PANEL, "Panel" )
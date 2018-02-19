include( "shared.lua" )
ENT.RandomFFTColors = { Color( 26, 188, 156 ), Color( 52, 152, 219 ), Color( 155, 89, 182 ), Color( 241, 196, 15 ), Color( 230, 126, 34 ) }

function ENT:Initialize( )
	if ( self:GetIsPlaying( ) ) then
		self:PlayRadioURL( )
	end
end

function ENT:Draw( )
	self:DrawModel( )
	if ( IsValid( self.radioSoundPatch ) ) then
		local fftTable = { }
		self.radioSoundPatch:FFT( fftTable, FFT_256 )
		local Pos = self:GetPos( )
		local Ang = self:GetAngles( )
		Ang:RotateAroundAxis(Ang:Right(), 90 )
		Ang:RotateAroundAxis(Ang:Up(), 90 )
		local col = self.fftColor or Color( 45, 255, 45 )
		cam.Start3D2D( Pos + Ang:Up() * 2.4 + Ang:Forward( ) * -6 + Ang:Right( ) * 1, Ang, 0.01 )
			for index, level in ipairs ( fftTable ) do
				draw.RoundedBox( 2, ( index * 8 ) + ( index ), 0, 6, math.Clamp( ( 6000 * level ), 4, 600 ), col )
			end
		cam.End3D2D()
	end
end

function ENT:OnRemove( )
	self:StopPlayingRadio( )
	self.radioSoundPatch = nil
end

function ENT:PlayRadioURL( )
	if ( tobool( tonumber( GetConVarNumber( "noobrp_disableradiostreams" ) or 0 ) ) ) then return end
	self.fftColor = self.RandomFFTColors[ math.random( #self.RandomFFTColors ) ]
	if ( self.radioSoundPatch ) then
		self.radioSoundPatch:Stop( )
		self.radioSoundPatch = nil
	end
	if ( !self.radioSoundPatch and self:GetRadioStation( ) and self:GetRadioStation( ) ~= "" ) then
		sound.PlayURL ( self:GetRadioStation( ), "3d", function( station )
		if ( IsValid( self ) and IsValid( station ) ) then
				station:SetPos( self:GetPos( ) )
				station:Play( )
				self.radioSoundPatch = station
				LocalPlayer( ).radioStations = LocalPlayer( ).radioStations or { }
				table.insert( LocalPlayer( ).radioStations, station )
			else
				if ( IsValid( self ) and self:Getowning_ent( ) == LocalPlayer( ) ) then
					notification.AddLegacy( "Failed to load the radio's radio station.", NOTIFY_ERROR, 4 )
				else
					LocalPlayer( ):PrintMessage( HUD_PRINTCONSOLE, "Failed to load the radio's radio station.\n" )
				end
			end
		end )
	end
	local entIndex = self:EntIndex( )
	if ( timer.Exists( entIndex .. ":RadioPatchAdjustment" ) ) then timer.Destroy( entIndex .. ":RadioPatchAdjustment" ) end
	timer.Create( entIndex .. ":RadioPatchAdjustment", 1, 0, function( )
		if not ( IsValid( self ) ) then timer.Destroy( entIndex .. ":RadioPatchAdjustment" ) end
		if ( IsValid( self.radioSoundPatch ) ) then
			self.radioSoundPatch:SetPos( self:GetPos( ) )
			if ( system.HasFocus( ) ) then
				self.radioSoundPatch:SetVolume( 1 )
			else
				self.radioSoundPatch:SetVolume( 0 )
			end
		end
	end )
end

function ENT:StopPlayingRadio(  )
	if ( IsValid( self.radioSoundPatch ) ) then
		self.radioSoundPatch:Stop( )
		if ( timer.Exists( self:EntIndex( ) .. ":RadioPatchAdjustment" ) ) then 
			timer.Destroy( self:EntIndex( ) .. ":RadioPatchAdjustment" ) 
		end
	end
end

function ENT:SetPatchStation( station )
	net.Start( "N00BRP_RadioEntity_NET" )
		net.WriteUInt( self.SetStation, 8 )
		net.WriteEntity( self )
		net.WriteString( station )
	net.SendToServer( )
end

function ENT:PlayRadioPatch( )
	net.Start( "N00BRP_RadioEntity_NET" )
		net.WriteUInt( self.PlayRadio, 8 )
		net.WriteEntity( self )
	net.SendToServer( )
end

function ENT:StopRadioPatch( )
	net.Start( "N00BRP_RadioEntity_NET" )
		net.WriteUInt( self.StopRadio, 8 )
		net.WriteEntity( self )
	net.SendToServer( )
end

local nextNetMessage = 0
local function ReceiveRadioNET( len )
	if ( nextNetMessage > CurTime( ) ) then return end
	nextNetMessage = CurTime( ) + 2
	local messType = net.ReadUInt( 8 )
	local radioEnt = Entity( net.ReadUInt( 32 ) )
	if ( !IsValid( radioEnt ) or radioEnt:GetClass( ) ~= "ent_radio" ) then return end
	if ( messType == radioEnt.RadioMenu ) then
		if not ( ValidPanel( LocalPlayer( ).radioStationMenu ) ) then
			LocalPlayer( ).radioStationMenu = vgui.Create( "N00BRP_RadioMenu" )
			LocalPlayer( ).radioStationMenu:SetRadioEntity( radioEnt )
		end
	elseif ( messType == radioEnt.PlayRadio ) then
		radioEnt:PlayRadioURL( )
	elseif ( messType == radioEnt.StopRadio ) then
		radioEnt:StopPlayingRadio( )
	end
end
net.Receive( "N00BRP_RadioEntity_NET", ReceiveRadioNET )
local vehMeta = FindMetaTable( "Vehicle" )
local plyMeta = FindMetaTable( "Player" )
local SET_STATION = 1
local PLAY_RADIO = 2
local STOP_RADIO = 3
local RADIO_MENU = 4

if ( SERVER ) then
	util.AddNetworkString( "N00BRP_VehicleRadio_NET" )
	function vehMeta:SetRadioStation( station, ply )
		if ( !ply and IsValid( self ) and IsValid( self:GetDriver( ) ) ) then
			DarkRP.notify( self:GetDriver( ), 0, 4, "You've changed the radio station to: " .. station )
		end
		self.vehicleRadioStation = station
		self.vehicleRadioPlaying = true
		net.Start( "N00BRP_VehicleRadio_NET" )
			net.WriteUInt( SET_STATION, 8 )
			net.WriteUInt( self:EntIndex( ), 32 )
			net.WriteString( station )
		if ( ply ) then
			net.Send( ply )
		else
			net.Send( player.GetAll( ) )
		end
	end

	function vehMeta:PlayRadio( )
		if ( self.vehicleRadioPlaying ) then return end
		if ( IsValid( self ) and IsValid( self:GetDriver( ) ) ) then
			DarkRP.notify( self:GetDriver( ), 0, 4, "You turned on the radio." )
		end
		self.vehicleRadioPlaying = true
		net.Start( "N00BRP_VehicleRadio_NET" )
			net.WriteUInt( PLAY_RADIO, 8 )
			net.WriteUInt( self:EntIndex( ), 32 )
		net.Send( player.GetAll( ) )
	end
	
	function vehMeta:StopRadio( )
		if not ( self.vehicleRadioPlaying ) then return end
		if ( IsValid( self ) and IsValid( self:GetDriver( ) ) ) then
			DarkRP.notify( self:GetDriver( ), 0, 4, "You turned off the radio." )
		end
		self.vehicleRadioPlaying = false
		net.Start( "N00BRP_VehicleRadio_NET" )
			net.WriteUInt( STOP_RADIO, 8 )
			net.WriteUInt( self:EntIndex( ), 32 )
		net.Send( player.GetAll( ) )
	end

	local function IntializeVehicleRadios( ply )
		if ( istable( noob_VehicleIndex.spawnedVehicles ) and #noob_VehicleIndex.spawnedVehicles > 0 ) then
			for index, veh in ipairs ( noob_VehicleIndex.spawnedVehicles ) do
				if ( veh.vehicleRadioPlaying ) then
					veh:SetRadioStation( veh.vehicleRadioStation, ply )
				end
			end
		end
	end
	hook.Add( "NOOBRP_OnRequestData", "N00BRP_IntializeVehicleRadios_OnRequestData", IntializeVehicleRadios )

	local function OnVehicleRadioOpen( ply, keyCode )
		if ( keyCode == IN_RELOAD and ply:KeyDown( IN_SPEED ) ) then
			if ( IsValid( ply:GetVehicle( ) ) and IsValid( ply:GetVehicle( ):GetDriver( ) ) ) then
				if ( ply:GetVehicle( ):GetDriver( ) == ply and ply:GetVehicle( ):GetClass( ) ~= "prop_vehicle_prisoner_pod" ) then
					ply.nextVehicleRadioMenu = ply.nextVehicleRadioMenu or 0
					if ( ply.nextVehicleRadioMenu > CurTime( ) ) then return end
					ply.nextVehicleRadioMenu = CurTime( ) + 1
					net.Start( "N00BRP_VehicleRadio_NET" )
						net.WriteUInt( RADIO_MENU, 8 )
						net.WriteUInt( ply:GetVehicle( ):EntIndex( ), 32 )
					net.Send( ply )
				end
			end
		end
	end
	hook.Add( "KeyPress", "N00BRP_OnVehicleRadioOpen_KeyPress", OnVehicleRadioOpen )

	local function ReceiveRadioNET( len, ply )
		local messType = net.ReadUInt( 8 )
		local entRadio = net.ReadEntity( )
		if ( !IsValid( entRadio ) or !entRadio:IsVehicle( ) or entRadio:GetDriver( ) ~= ply or entRadio:GetClass( ) == "prop_vehicle_prisoner_pod" ) then
			return
		end
		if ( messType == SET_STATION ) then
			local station = net.ReadString( )
			if not ( SHNOOB_VARS:Get( "RadioStations" )[ station ] ) then return end
			entRadio:SetRadioStation( station )
		elseif ( messType == PLAY_RADIO ) then
			entRadio:PlayRadio( )
		elseif ( messType == STOP_RADIO ) then
			entRadio:StopRadio( )
		end
	end
	net.Receive( "N00BRP_VehicleRadio_NET", ReceiveRadioNET )
else
	function vehMeta:PlayRadioURL( )
		if ( tobool( tonumber( GetConVarNumber( "noobrp_disableradiostreams" ) or 0 ) ) ) then return end
		if ( self.radioSoundPatch ) then
			self.radioSoundPatch:Stop( )
			self.radioSoundPatch = nil
		end
		if ( !self.radioSoundPatch and self.radioStationURL and self.radioStationURL ~= "" ) then
			sound.PlayURL( self.radioStationURL, "3d", function( station )
			if ( IsValid( self ) and IsValid( station ) ) then
					station:SetPos( self:GetPos( ) )
					station:Play( )
					station:Set3DFadeDistance( 256, 0 )
					self.radioSoundPatch = station
					LocalPlayer( ).radioStations = LocalPlayer( ).radioStations or { }
					table.insert( LocalPlayer( ).radioStations, station )
				else
					if ( IsValid( self ) and self:IsVehicle( ) and self.GetDriver and LocalPlayer( ) == self:GetDriver( ) ) then
						notification.AddLegacy( "Failed to load the radio's radio station.", NOTIFY_ERROR, 4 )
					else
						LocalPlayer( ):PrintMessage( HUD_PRINTCONSOLE, "Failed to load the radio's radio station.\n" )
					end
				end
			end )
		end
		local entIndex = self:EntIndex( )
		if ( timer.Exists( entIndex .. ":RadioPatchAdjustment" ) ) then timer.Destroy( entIndex .. ":RadioPatchAdjustment" ) end
		timer.Create( entIndex .. ":RadioPatchAdjustment", 0.1, 0, function( )
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

	function vehMeta:StopPlayingRadio( )
		if ( IsValid( self.radioSoundPatch ) ) then
			self.radioSoundPatch:Stop( )
			timer.Remove( self:EntIndex( ) .. ":RadioPatchAdjustment" )
		end
	end
	
	function vehMeta:SetPatchStation( station )
		net.Start( "N00BRP_VehicleRadio_NET" )
			net.WriteUInt( SET_STATION, 8 )
			net.WriteEntity( self )
			net.WriteString( station )
		net.SendToServer( )
	end

	function vehMeta:PlayRadioPatch( )
		net.Start( "N00BRP_VehicleRadio_NET" )
			net.WriteUInt( PLAY_RADIO, 8 )
			net.WriteEntity( self )
		net.SendToServer( )
	end

	function vehMeta:StopRadioPatch( )
		net.Start( "N00BRP_VehicleRadio_NET" )
			net.WriteUInt( STOP_RADIO, 8 )
			net.WriteEntity( self )
		net.SendToServer( )
	end

	local function ReceiveRadioNET( len )
		local messType = net.ReadUInt( 8 )
		local radioEnt = Entity( net.ReadUInt( 32 ) )
		if ( !IsValid( radioEnt ) or !radioEnt:IsVehicle( ) ) then return end
		if ( messType == RADIO_MENU ) then
			if not ( ValidPanel( LocalPlayer( ).radioStationMenu ) ) then
				LocalPlayer( ).radioStationMenu = vgui.Create( "N00BRP_RadioMenu" )
				LocalPlayer( ).radioStationMenu:SetRadioEntity( radioEnt )
			end
		elseif ( messType == SET_STATION ) then
			if not ( SHNOOB_VARS:Get( "RadioStations", true ) ) then return end
			radioEnt.radioStationURL = SHNOOB_VARS:Get("RadioStations")[ tostring( net.ReadString( ) ) ]
			radioEnt:PlayRadioURL( )
		elseif ( messType == PLAY_RADIO ) then
			radioEnt:PlayRadioURL( )
		elseif ( messType == STOP_RADIO ) then
			radioEnt:StopPlayingRadio( )
		end
	end
	net.Receive( "N00BRP_VehicleRadio_NET", ReceiveRadioNET )

	local function OnVehicleRemoved( ent )
		if ( ent:GetClass( ) == "player" and ent == LocalPlayer( ) ) then
			for index, ent in ipairs ( ents.GetAll( ) ) do
				if ( IsValid( ent.radioSoundPatch ) ) then
					ent.radioSoundPatch:Stop( )
					ent.radioSoundPatch = nil
				end
			end
		end
		if ( ent:IsVehicle( ) and ent.radioSoundPatch ) then
			if ( IsValid( ent.radioSoundPatch ) ) then ent.radioSoundPatch:Stop( ) end
			ent.radioSoundPatch = nil
		end
	end
	hook.Add( "EntityRemoved", "N00BRP_OnVehicleRemoved_EntityRemoved", OnVehicleRemoved )
end

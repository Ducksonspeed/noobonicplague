ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName		= "Cardealer Event Meter"
ENT.Author			= "Jeezy"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Noobonic Plague"
ENT.MaximumProgress = 14400
ENT.RequiredPushes = 3

ENT.PossibleEvents = { }
ENT.PossibleEvents[ 1 ] = { name = "Police XP Boost", command = "np_policexpboost", minProg = ENT.MaximumProgress * 0.3, maxProg = ENT.MaximumProgress * 0.6, eventCheck = function( ) if ( SVNOOB_VARS:Get( "PoliceXPBoostActive" )  == true ) then return true else return false end end }
ENT.PossibleEvents[ 2 ] = { name = "Criminal XP Boost", command = "np_criminalxpboost", minProg = ENT.MaximumProgress * 0.6, maxProg = ENT.MaximumProgress * 1, eventCheck = function( ) if ( SVNOOB_VARS:Get( "CriminalXPBoostActive" )  == true ) then return true else return false end end  }
ENT.PossibleEvents[ 3 ] = { name = "Printing XP Boost", command = "np_printerxpboost", minProg = ENT.MaximumProgress * 1, maxProg = ENT.MaximumProgress * 1, eventCheck = function( ) if ( SVNOOB_VARS:Get( "PrintingXPBoostActive" )  == true ) then return true else return false end end  }
ENT.MeterLocation = "CarDealer"

function ENT:SetupDataTables( )
	self:NetworkVar( "Int", 0, "Progress" )
end

if ( SERVER ) then
	AddCSLuaFile( )
	function ENT:Initialize( )
		self:SetModel( "models/maxofs2d/button_02.mdl" )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local physObj = self:GetPhysicsObject()
		if ( IsValid( physObj ) ) then
			physObj:Wake( )
			physObj:EnableMotion( false )
		end
		local eventMeterMulti = SVNOOB_VARS:Get( "EventMeterMulti" )
		timer.Simple( 20, function( )
			if ( IsValid( self ) ) then
				self:DoTick( )
			end
		end )
		mySQLControl:Query( "SELECT progress FROM darkrp_eventmeters WHERE location = '" .. self.MeterLocation .. "';", function( data )
			if ( #data > 0 ) then
				local meterProgress = data[1].progress
				self:SetProgress( meterProgress )
			else
				mySQLControl:Query( "INSERT INTO darkrp_eventmeters VALUES ('" .. self.MeterLocation .. "', 0 );", function( ) end )
			end
			local saveInterval = tonumber( SVNOOB_VARS:Get( "EventMeterSaveDataInterval" ) ) or 300
			timer.Create( self:EntIndex( ) .. ":EventMeterDataTimer", saveInterval, 0, function( )
				mySQLControl:Query( "UPDATE darkrp_eventmeters SET progress = " .. self:GetProgress( ) .. " WHERE location = '" .. self.MeterLocation .. "';", function( ) end )
				MsgC( Color( 45, 175, 45 ), "Saving " .. self.MeterLocation .. " Event Meter progress.\n" )
			end )
		end )
	end

	function ENT:DoTick( )
		local eventMeterMulti = SVNOOB_VARS:Get( "EventMeterMulti", true, "number", 1 )
		local eventMeterTickRate = SVNOOB_VARS:Get( "EventMeterTickRate", true, "number", 90 )
		self:SetProgress( math.Clamp( self:GetProgress( ) + ( #player.GetAll( ) * eventMeterMulti ), 0, self.MaximumProgress ) )
		timer.Simple( eventMeterTickRate, function( )
			if ( IsValid( self ) ) then
				self:DoTick( )
			end
		end )
	end

	local function ResetButtonPushes( entIndex, timerName )
		local meterEnt = Entity( entIndex )
		if ( IsValid( meterEnt ) ) then
			meterEnt.playerButtonPushes = { }
			meterEnt.pushAmount = 0
		end
		if ( timer.Exists( timerName ) ) then
			timer.Destroy( timerName )
		end
	end

	function ENT:Use( ply )
		local isAnEvent = nil
		for index, event in ipairs ( self.PossibleEvents ) do
			local currentProgress = self:GetProgress( )
			if ( currentProgress == self.MaximumProgress ) then
				isAnEvent = #self.PossibleEvents
				break
			end
			if ( ( currentProgress > event.minProg and currentProgress <= event.maxProg ) ) then
				isAnEvent = index
				break
			end
		end
		if ( isAnEvent ) then
			if not ( self.PossibleEvents[isAnEvent].eventCheck( ) ) then
				self.playerButtonPushes = self.playerButtonPushes or { }
				self.pushAmount = self.pushAmount or 0
				local entIndex = self:EntIndex( )
				local timerName = "N00BRP_CardealerEventMeter_ButtonPushFade:" .. entIndex
				if not ( self.playerButtonPushes[ ply:SteamID( ) ] ) then
					self.playerButtonPushes[ ply:SteamID( ) ] = CurTime( )
					self.pushAmount = self.pushAmount + 1
					
					if ( timer.Exists( timerName ) ) then
						timer.Adjust( timerName, 15, 1, function( ) ResetButtonPushes( entIndex, timerName ) end )
					else
						timer.Create( timerName, 15, 1, function( ) ResetButtonPushes( entIndex, timerName ) end )
					end
				end
				if ( self.pushAmount >= self.RequiredPushes ) then
					RunConsoleCommand( self.PossibleEvents[isAnEvent].command )
					self:SetProgress( 0 )
					ResetButtonPushes( entIndex, timerName )
				else
					local reqAmt = self.RequiredPushes - self.pushAmount
					ply.nextEventMeterButtonNotify = ply.nextEventMeterButtonNotify or 0
					if ( CurTime( ) > ply.nextEventMeterButtonNotify ) then
						DarkRP.notify( ply, 1, 4, reqAmt .. " more people need to press the button to activate the event." )
						ply.nextEventMeterButtonNotify = CurTime( ) + 2
					end
				end
			end
		end
	end
else
	--surface.CreateFont( "N00BRP_EventHeader", { font = "Tahoma", size = 48, weight = 750, antialiasing = true, blursize = 0 } )
	--surface.CreateFont( "N00BRP_SmallHeader", { font = "Tahoma", size = 24, weight = 750, antialiasing = true, blursize = 0 } )

	function ENT:Initialize( )
		local minRenderBounds, maxRenderBounds = self:GetRenderBounds( )
		minRenderBounds:Mul( 5 )
		maxRenderBounds:Mul( 5 )
		self:SetRenderBounds( minRenderBounds, maxRenderBounds )
	end
	
	function ENT:Draw( flags )
		self:DrawModel( )
		local camPos = self:GetPos( )
		local camAng = self:GetAngles( )
		camPos = camPos + ( camAng:Up( ) * 2 ) + ( camAng:Right( ) * 60 ) + ( camAng:Forward( ) * 00)
		camAng:RotateAroundAxis( camAng:Right( ), 0 )
		camAng:RotateAroundAxis( camAng:Up( ), 0 )
		local rShade = math.abs( math.sin( CurTime( ) * 2 ) * 100 ) + 150
		local gShade = math.abs( math.sin( CurTime( ) * 3 ) * 100 ) + 150
		local bShade = math.abs( math.sin( CurTime( ) * 4 ) * 100 ) + 150
		local progress = math.Clamp( ( self:GetProgress( ) / self.MaximumProgress ) * 120, 5, 120 ) 
		cam.Start3D2D( camPos, camAng, 0.5 )
			draw.RoundedBox( 2, -10, -90, 20, 125, Color( 255, 255, 255, 255 ) )
			draw.RoundedBox( 2, -8, -88, 16, progress, Color( 45, 175, 45, 255 ) )
		cam.End3D2D( )
		camAng:RotateAroundAxis( camAng:Up( ), 180 )
		cam.Start3D2D( camPos, camAng, 0.3 )
			draw.SimpleText( "", "N00BRP_EventHeader", 0, -100, Color( rShade, gShade, bShade, 255 ), TEXT_ALIGN_CENTER )
			local currentEvent = "None"
			for index, event in ipairs ( self.PossibleEvents ) do
				if ( ( self:GetProgress( ) > event.minProg and self:GetProgress( ) <= event.maxProg ) or self:GetProgress( ) == self.MaximumProgress ) then
					currentEvent = event.name
				end
			end
			draw.SimpleText( "Current Event: " .. currentEvent, "N00BRP_SmallHeader", 0, -100, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		cam.End3D2D( )
	end
end
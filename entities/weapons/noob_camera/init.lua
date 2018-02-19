AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("camerafilters.lua")
include("shared.lua")
local scriptDirectory = "http://sv.noobonicplague.com/npcamera/"
local maxPictures = 10
util.AddNetworkString( "N00BRP_Camera_NET" )

local function Receive_Camera_NET( len, ply )
	local messType = net.ReadInt( 8 )
	if ( messType == ENUM_CAM_BEGINTRANSFER ) then
		ply.PictureData = { }
		ply.PicturePartCount = 0
		ply.PicturePartLength = net.ReadUInt( 32 )
	elseif ( messType == ENUM_CAM_SENDPART ) then
		local datLength = net.ReadUInt( 32 )
		local compressedData = net.ReadData( datLength )
		local deCompressedData = util.Decompress( compressedData )
		table.insert( ply.PictureData, deCompressedData )
		ply.PicturePartCount = ply.PicturePartCount + 1
		if ( ply.PicturePartLength == ply.PicturePartCount ) then
			http.Fetch( scriptDirectory .."/get_images.php?PlayerID=" .. ply:SteamID64( ) .."&Mode=Count",
			function( body, len, headers, code )
				if ( ( tonumber( body ) or 0 ) >= maxPictures ) then
					DarkRP.notify( ply, 2, 4, "You've reached the maximum pictures, go delete some." )
					return
				end
				DarkRP.notify( ply, 2, 4, "Your picture has been uploaded." )
				local completePicture = table.concat( ply.PictureData )
				local data = { ["key"] = "n00b!" }
				data.filename = ply:SteamID64( ) .. os.date( "(%a%b%d_%I-%M-%S%p)" )
				data.imgdata = [[ <img width="1440" height="810" src="data:image/jpeg;base64, ]] .. completePicture .. [["/> ]]
				http.Post( scriptDirectory .. "image_upload.php", data, function( ) print("Successfully posted image.") end, function( ) print("Failed to post image.") end )
			end,
			function( error )
				DarkRP.notify( ply, 2, 4, "Unable to get picture amount, please contact a Developer." )
			end )
		end
	end
end
net.Receive( "N00BRP_Camera_NET", Receive_Camera_NET )

function SWEP:SecondaryAttack( )
	if ( self.NextToggleView < CurTime( ) ) then
		if ( self.ViewingSelf ) then
			self.ViewingSelf = false
			self:SetHoldType( "camera" )
		else
			self.ViewingSelf = true
			self:SetHoldType( "pistol" )
		end
		self.NextToggleView = CurTime( ) + 2
	end
end

function SWEP:Deploy( )
	timer.Simple( 0.5, function ( ) 
		if ( !IsValid( self ) or !IsValid( self.Owner ) or !IsValid( self.Owner:GetActiveWeapon( ) ) ) then return end
		if ( self.Owner:GetActiveWeapon( ) ~= "noob_camera" ) then return end
		BroadcastLua( "Entity(" .. self:EntIndex( ) .. "):Deploy( )" )
	end )
end
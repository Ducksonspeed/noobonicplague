ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName		= "Goomba Stomp"
ENT.Author			= "Sinavestos : Edited by Jeezy"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

if ( SERVER ) then
	AddCSLuaFile( )
	function ENT:Initialize( )
		timer.Simple( 1, function( )
			if ( IsValid( self ) ) then
				SafeRemoveEntity( self )
			end
		end )
	end
else
	killicon.AddAlias( "goombastomp", "default" )
	function ENT:Draw( flags )
		return false
	end
end
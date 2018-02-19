ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName		= "Aids"
ENT.Author			= "Jeezy"
ENT.Contact			= ""
ENT.Purpose			= "Damage inflictor for the dart gun."
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
	killicon.AddAlias( "aids", "default" )
	function ENT:Draw( flags )
		return false
	end
end
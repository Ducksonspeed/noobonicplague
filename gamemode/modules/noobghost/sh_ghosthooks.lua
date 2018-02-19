function GM:ShouldCollide( entOne, entTwo )
	if ( ( entOne:IsPlayer( ) and entTwo:GetClass( ) == "prop_vehicle_prisoner_pod" ) or ( entTwo:IsPlayer( ) and entOne:GetClass( ) == "prop_vehicle_prisoner_pod" ) ) then
		return false
	end
	if ( entOne:IsPlayer( ) and ( entTwo:IsPlayer( ) and !entTwo:Alive( ) ) ) then
		return false
	end
	if ( entTwo:IsPlayer( ) and ( entOne:IsPlayer( ) and !entOne:Alive( ) ) ) then
		return false
	end
	if ( entOne:IsVehicle( ) and entTwo.isFadingDoor ) then
		return false
	end
	if ( entTwo:IsVehicle( ) and entOne.isFadingDoor ) then
		return false
	end
	if ( entOne:IsPlayer( ) and entTwo:IsPlayer( ) ) then
		//if ( entOne:getDarkRPVar( "IsGhost" ) or entTwo:getDarkRPVar( "IsGhost" ) ) then
		if ( entOne:IsGhost( ) or entTwo:IsGhost( ) ) then
			return false
		end
	elseif ( entOne:IsPlayer( ) and entTwo:IsVehicle( ) ) then
		//if ( entOne:getDarkRPVar( "IsGhost" ) ) then
		if ( entOne:IsGhost( ) ) then
			return false
		end
	elseif ( entTwo:IsPlayer( ) and entOne:IsVehicle( ) ) then
		//if ( entTwo:getDarkRPVar( "IsGhost" ) ) then
		if ( entTwo:IsGhost( ) ) then
			return false
		end
	elseif ( entOne:IsPlayer( ) and entOne:IsGhost( ) and entTwo:IsNPC( ) ) then
		return false
	elseif ( entTwo:IsPlayer( ) and entTwo:IsGhost( ) and entOne:IsNPC( ) ) then
		return false
	elseif ( entOne:IsPlayer( ) and entOne:IsGhost( ) and entTwo:GetClass( ) == "func_tracktrain" ) then
		return false
	end
	return true
end
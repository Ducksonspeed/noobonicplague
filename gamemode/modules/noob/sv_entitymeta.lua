local meta = FindMetaTable( "Entity" );

function meta:IsBus()
	if ( self:GetClass():find( "jeep" ) and self:GetModel() == "models/tdmcars/bus.mdl" ) then
		return true;
	end
end


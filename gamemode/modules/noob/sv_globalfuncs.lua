function ClampWorldVector(vec)
	vec.x = math.Clamp( vec.x , -16380, 16380 )
	vec.y = math.Clamp( vec.y , -16380, 16380 )
	vec.z = math.Clamp( vec.z , -16380, 16380 )
	return vec
end

function SpawnShipmentEntity( ent, pos )
	local shipmentEntity = ents.Create( "spawned_shipment" )
	for index, data in pairs( CustomShipments ) do
		if ( ent == data.entity ) then
			shipmentEntity:SetContents( index, data.amount )
		end
	end
	shipmentEntity.ShareGravgun = true
	shipmentEntity.nodupe = true

	-- shipmentEntity:Setowning_ent( robber );
	shipmentEntity:SetModel( "models/Items/item_item_crate.mdl" )
	shipmentEntity:SetPos( pos )
	shipmentEntity:Spawn( )
	return shipmentEntity
end

function BroadcastColoredMessage( messTbl )
	net.Start( "N00BRP_Miscellaneous_NET" )
		net.WriteInt( ENUM_MISC_NET_COLOREDMESSAGE, 8 )
		net.WriteTable( messTbl )
	net.Broadcast( )
end
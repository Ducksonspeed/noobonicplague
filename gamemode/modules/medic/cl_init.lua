
local flatline_icon = Material( "noobonic/ems/player_flatline.png", "unlitgeneric" )
local medical_icon = Material( "noobonic/ems/player_medical.png", "unlitgeneric" )

function DrawParamedicOverlay()

	if not ( LocalPlayer and LocalPlayer():Team() == TEAM_PARAMEDIC and ply:Alive() ) then return end

	local function DrawFlatline( rag, ply )
		if not ( IsValid( rag ) and IsValid( ply ) and not ply:isWanted() and not ply:getDarkRPVar( "IsMurderer" ) ) then return end
		local pos = (rag:GetPos() + Vector( 0, 0, 30 )):ToScreen()
		local useTime = 120
		//local time = ply:GetNetworkedInt( "RespawnTime" )
		local time = ply.respawnTime
		if time then
			local timeLeft = time - CurTime()
			useTime = math.Clamp( timeLeft, 0, 60 )
		end
		local drawColor = HSVToColor( useTime, .74, 1 )
		surface.SetMaterial( flatline_icon )
		surface.SetDrawColor( drawColor )
		surface.DrawTexturedRect( pos.x, pos.y, 64, 64 )
	end

	local function DrawMedicalCall( ply )
		if not IsValid( ply ) or not ply:Alive() then return end
		surface.SetMaterial( medical_icon )
		surface.SetDrawColor( 255, 100, 50, 255)
		surface.DrawTexturedRect( 0, 0, 64, 64 )
	end

	local function ScanBodies()
		for _,ent in pairs( ents.GetAll() ) do
			if IsValid( ent ) and ent:GetClass() == "prop_ragdoll" and IsValid( ent:GetOwner() ) and ent:GetOwner():IsPlayer() then
				DrawFlatline( ent, ent:GetOwner() )
			end
		end
	end

	local function ScanMedicalVictims()
		for _,ply in pairs( player.GetAll() ) do
			if ply:getDarkRPVar( "MedicalEmergency" ) then
				DrawMedicalCall( ply )
			end
		end
	end

	ScanBodies()
	-- ScanMedicalVictims()

end
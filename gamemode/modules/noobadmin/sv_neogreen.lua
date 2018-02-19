/*function IsNeogreen( ply )
	if not ply or not ply:IsValid() or not ply:IsPlayer() then return false end
	if ply:SteamID() == "STEAM_0:0:33770352" then return true end
	return false
end*/

// There's a better way to do this.
/*local function NeogreenWorthless( ply )
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if not IsNeogreen(ply) then return end
	if not ply.niggereened then
		for k,v in pairs(ents.FindInSphere(ply:GetPos(), 15)) do
			if v:GetClass() == "prop_physics" and v:GetModel() == "models/props/cs_assault/pylon.mdl" then
				ply:SetGravity(10000000)
				ply:SendLua("LocalPlayer():SetGravity(10000000)")
				ply.niggereened = true
				break
			end
		end
	else
		local exp = ents.Create( "env_explosion" )
        exp:SetPos( ply:GetPos() )
        exp:Spawn()
        exp:SetKeyValue( "iMagnitude", "0" )
        exp:Fire( "Explode", 0, 0 )
        ply:ConCommand("say \"/y I'M A WORTHLESS FUCK\"")
        timer.Simple(4, function()
	    	ply.niggereened = false
	    end)
	end
	
end
hook.Add("OnPlayerHitGround", "NeogreenWorthless", NeogreenWorthless)*/
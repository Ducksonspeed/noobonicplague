ENT.Type = "anim"  
ENT.Base = "base_gmodentity"

if ( SERVER ) then

	AddCSLuaFile( )

	function ENT:Initialize()   
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE )
		self:SetCollisionGroup( COLLISION_GROUP_WORLD )
		self:DrawShadow(false)
		self:SetModel( "models/arleitiss/riotshield/shield.mdl" )
	end

	function ENT:OnRemove()
		if ( IsValid( self:GetOwner( ) ) ) then
			self:GetOwner( ).equippedRiotShield = false
		end
	end

end

if not ( CLIENT ) then return end

function ENT:Draw() 
	if not ( IsValid( self:GetOwner( ) ) ) then return end
    local handBone = self:GetOwner( ):LookupBone( "ValveBiped.Bip01_R_Hand" )  
    if ( handBone ) then  
        local pos, ang = self:GetOwner( ):GetBonePosition( handBone )
			
        local upOffset = ang:Up( ) * 35.00
        local rightOffset = ang:Right( ) * 0.95  
        local forwardOffset = ang:Forward( ) * 6.00
  
        local pitchOffset = -180.00
        local yawOffset = 0.00
        local rollOffset = 0.00

        ang:RotateAroundAxis( ang:Forward( ), pitchOffset )  
        ang:RotateAroundAxis( ang:Right( ), yawOffset )  
        ang:RotateAroundAxis( ang:Up( ), rollOffset )  
			
        self:SetPos( pos + upOffset + rightOffset + forwardOffset )  
        self:SetAngles( ang )  
    end 

	if ( self:GetOwner( ) == LocalPlayer( ) ) then
		if ( self:GetOwner( ):GetObserverMode( ) ~= OBS_MODE_NONE ) then return end
		if ( LocalPlayer( ):ShouldDrawLocalPlayer( ) or LocalPlayer( ):GetViewEntity( ):GetClass( ) == "gmod_cameraprop" ) then
			self:DrawModel( )
		end
	else
		self:DrawModel( )
	end
end  
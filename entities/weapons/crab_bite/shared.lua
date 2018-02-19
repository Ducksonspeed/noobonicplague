AddCSLuaFile( )
SWEP.PrintName = "Crab Bite"
SWEP.Slot = 2
SWEP.SlotPos = 4
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Author = "Sinavestos - Revamped by Jeezy"
SWEP.Instructions = "Left click to chew, right click to shriek as the Queen."
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.WorldModel	= ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "rpg"

SWEP.Spawnable = false
SWEP.AdminSpawnable = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.FrameVisible = false
SWEP.OnceReload = false

function SWEP:Initialize()
	self:SetHoldType( "normal" )
	util.PrecacheSound( "npc/headcrab/headbite.wav" )
	util.PrecacheSound( "npc/headcrab/alert1.wav" )
	util.PrecacheSound( "npc/fast_zombie/fz_scream1.wav" )
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime( ) + 2 )
	self:SetHoldType( "pistol" )
	timer.Simple(0.2, function( ) 
		if ( IsValid( self ) ) then
			self:SetHoldType("normal") 
		end 
	end )
	if ( SERVER ) then
		if not ( self.Owner:Team( ) == TEAM_CRAB ) then return end
		local traceData = { }
		traceData.start = self.Owner:GetShootPos( )
		traceData.endpos = traceData.start + self.Owner:GetAimVector() * 80
		traceData.filter = { self.Owner }
		local traceRes = util.TraceLine( traceData )
		if traceRes.Entity and IsValid( traceRes.Entity ) and traceRes.Entity:IsPlayer() then
			traceRes.Entity:TakeDamage( math.floor( ( self.Owner:GetModelScale( ) + 1 ) * math.random( 2, 6 ) ), self.Owner, self )
			self.Owner:EmitSound( "npc/headcrab/headbite.wav" )
			local hungerGain = math.Clamp( self.Owner:getDarkRPVar( "Energy" ) + math.random( 1, 10 ), 0, 100 )
			self.Owner:setSelfDarkRPVar( "Energy", hungerGain )
		else
			self.Owner:EmitSound( "npc/headcrab/alert1.wav" )
		end
	end
end

function SWEP:Deploy()
	return true
end


function SWEP:SecondaryAttack( )
	if not ( SERVER ) then return true end
	local crabQueen = SVNOOB_VARS:Get( "CrabQueen" )
	if ( crabQueen ~= self.Owner ) then return end
	self.Owner.nextCrabQueenShriek = self.Owner.nextCrabQueenShriek or 0
	if ( self.Owner.nextCrabQueenShriek < CurTime( ) ) then
		local crabShriekCooldown = SVNOOB_VARS:Get( "CrabShriekCooldown", true, "number", 120 )
		self.Owner.nextCrabQueenShriek = CurTime( ) + crabShriekCooldown	
		self.Owner:EmitSound( "npc/fast_zombie/fz_scream1.wav", 100, 100 )
		local boxMins = ClampWorldVector( self.Owner:GetPos( ) - Vector( 256, 256, 256 ) )
		local boxMaxs = ClampWorldVector( self.Owner:GetPos( ) + Vector( 256, 256, 256 ) )
		local nearbyEnts = ents.FindInBox( boxMins, boxMaxs )
		for index, ent in ipairs ( nearbyEnts ) do
			if not ( ent:IsPlayer( ) ) then continue end
			if ( ent:Team( ) == TEAM_CRAB ) then continue end
			if ( ent.isDisorientated ) then continue end
			ent:DisorientPlayer( math.random( 5, 12 ) )
		end
	else
		local remainTime = string.NiceTime( self.Owner.nextCrabQueenShriek - CurTime( ) )
		DarkRP.notify( self.Owner, 1, 4, "You cannot shriek for another " .. remainTime .. "!" )
	end
end


function SWEP:Reload()
end

function SWEP:DrawWorldModel() end

function SWEP:PreDrawViewModel(vm)
	return true
end

function SWEP:Holster()
	if not SERVER then return true end

	self.Owner:DrawViewModel(true)
	self.Owner:DrawWorldModel(true)

	return true
end

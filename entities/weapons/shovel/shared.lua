SWEP.PrintName = "Shovel"
SWEP.Author = "Sinavestos : Rewritten By Jeezy"
SWEP.Category = "Noobonic Plague"
SWEP.Instructions = "Go towards a rock wall and left click."
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.Slot = 0
SWEP.SlotPos = 5
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.HoldType = "melee"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.NextShovelSwing = 0

SWEP.ViewModel = "models/weapons/v_shovel.mdl"
SWEP.WorldModel = "models/weapons/w_shovel.mdl"

SWEP.HitAir = Sound( "weapons/iceaxe/iceaxe_swing1.wav" )
SWEP.HitSolidOne = Sound( "weapons/crowbar/crowbar_impact1.wav" )
SWEP.HitSolidTwo = Sound( "weapons/crowbar/crowbar_impact2.wav" )

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
SWEP.DefaultShovelCooldown = 1
SWEP.MiningCutOffHeight = 110

SWEP.Animations = {
   ACT_VM_PRIMARYATTACK_1,
   ACT_VM_PRIMARYATTACK_2,
   ACT_VM_PRIMARYATTACK_3,
   ACT_VM_PRIMARYATTACK_4,
   ACT_VM_PRIMARYATTACK_5
}

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
	util.PrecacheSound( self.HitAir )
	util.PrecacheSound( self.HitSolidOne )
	util.PrecacheSound( self.HitSolidTwo )
end

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_IDLE )
	return true
end

function SWEP:PrimaryAttack()
	if CurTime() < self.NextShovelSwing then return end

	self:SendWeaponAnim( self.Animations[ math.random( #self.Animations ) ] )
	timer.Simple( 0.5, function( )
		if not IsValid( self ) then return end
		self:SendWeaponAnim( ACT_VM_IDLE )
	end )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Owner:EmitSound( self.HitAir, 40, 100 )
	local levelData = NOOBRP_SkillAlgorithms:CalculateMining( self.Owner )
	local shovelCooldown = math.Clamp( self.DefaultShovelCooldown - ( levelData["CurrentLevel"] * 0.003 ), 0.1, 1 )
	self.NextShovelSwing = CurTime( ) + shovelCooldown
	self:SetNextPrimaryFire( CurTime( ) + shovelCooldown )
	if not ( SERVER ) then return end
	local traceRes = self.Owner:RangeEyeTrace( 96, { self } )
	local hitMound = ( traceRes.MatType == 67 and traceRes.HitTexture == "**studio**" )
	local hitGround = ( traceRes.MatType == 68 and traceRes.HitTexture == "**displacement**" )
	if traceRes.MatType == 67 and traceRes.HitTexture == "**displacement**" and game.GetMap() == "lair_of_the_Beast8" then
		hitGround = true
		self.MiningCutOffHeight = -1000
	end
	if traceRes.MatType == 68 and traceRes.HitTexture == "**studio**" and game.GetMap() == "lair_of_the_Beast8" then
		hitMound = true
		self.MiningCutOffHeight = -1000
	end
	local hitBeastMound = ( IsValid( traceRes.Entity ) and traceRes.Entity:GetClass( ) == "beast_mound" )
	if game.GetMap() == "rp_evocity_v2d_updated" then
		if ( traceRes.HitPos:IsInBox( Vector( 2438, -8745, 64 ), Vector( 3734, -6684, 543 ) ) ) then return end -- Pool
		if ( traceRes.HitPos:IsInBox( Vector( -5778, -5183, 128 ), Vector( -3709, -4096, 933 ) ) ) then return end -- Tides
		if ( traceRes.HitPos:IsInBox( Vector( 5383, -12354, 253 ), Vector( 6787, -13324, 668 ) ) ) then return end -- Penthouse
		if ( traceRes.HitPos:IsInBox( Vector( -5767, -9682, 128 ), Vector( -3706, -8913, 1799 ) ) ) then return end -- Office Buildings
		if ( traceRes.HitPos:IsInBox( Vector( 5521, 14313, 70 ), Vector( 6389, 13704, 634 ) ) ) then return; end -- Subs 2 ( blinds )
		if ( self.Owner:IsInTides( ) ) then return end -- The above check for tides doesn't seem to do the trick.
	end
	if ( ( traceRes.HitWorld and traceRes.HitPos.z > self.MiningCutOffHeight and ( hitMound or hitGround ) 
		and traceRes.HitNormal[3] < 0.7 ) or  hitBeastMound ) then
		if ( !hitMound and hitGround and !hitBeastMound ) then
			if ( tobool( math.random( 0, 1 ) ) ) then
				self.Owner:EmitSound( self.HitSolidOne, 30, 90 )
			else
				self.Owner:EmitSound( self.HitSolidTwo, 30, 90 )
			end
		end
	else
		return
	end
	local rndChance = math.Rand( 0, 100 )
	local gemType = 0
	local tableEntry = ""
	local gemChances = { }
	local isBeastMound = ( IsValid( traceRes.Entity ) and traceRes.Entity:GetClass( ) == "beast_mound" )
	if traceRes.MatType == 68 and traceRes.HitTexture == "**studio**" and game.GetMap() == "lair_of_the_Beast8" then isBeastMound = true end
	if ( SVNOOB_VARS:Get( "MiningBoostActive", true, "boolean", false ) == true or isBeastMound ) then
		gemChances = SVNOOB_VARS:Get( "MiningEventShovelRates", true ) 	// Maybe we can add in different drop rates later.
	else
		gemChances = SVNOOB_VARS:Get( "NormalShovelRates", true )
	end
	if ( !gemChances or !istable( gemChances ) or #gemChances < 1 ) then
		local errorMsg = "Fatal error occured for the Shovel, gem chances table is invalid."
		ErrorNoHalt( errorMsg )
		NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, "[ERROR] " .. errorMsg, true )
	end

	local gemType = 0
	if ( rndChance < gemChances[1].chanceMax and rndChance > gemChances[1].chanceMin ) then
		gemType = 1
		tableEntry = "Rocks"
	elseif ( rndChance < gemChances[2].chanceMax and rndChance > gemChances[2].chanceMin ) then
		gemType = 2
		tableEntry = "Granite"
	elseif ( rndChance < gemChances[3].chanceMax and rndChance > gemChances[3].chanceMin ) then
		gemType = 3
		tableEntry = "Shale"
	elseif ( rndChance < gemChances[4].chanceMax and rndChance > gemChances[4].chanceMin ) then
		gemType = 4
		tableEntry = "Emeralds"
	elseif ( rndChance < gemChances[5].chanceMax and rndChance > gemChances[5].chanceMin ) then
		gemType = 5
		tableEntry = "Rubies"
	elseif ( rndChance < gemChances[6].chanceMax and rndChance > gemChances[6].chanceMin ) then
		gemType = 6
		tableEntry = "Sapphires"
	elseif ( rndChance < gemChances[7].chanceMax and rndChance > gemChances[7].chanceMin ) then
		gemType = 7
		tableEntry = "Obsidians"
	elseif ( rndChance < gemChances[8].chanceMax and rndChance > gemChances[8].chanceMin ) then
		gemType = 8
		tableEntry = "Diamonds"
	end
	
	if ( gemType > 0 and gemChances[gemType] ) then
		self.Owner:ChatPrint( "You unearth a " .. gemChances[gemType].name .. "!" )
		self.Owner:RewardXP( gemType, NOOB_SKILL_MINING, "MiningXP", "Mining", false )
		self.Owner:GiveGem( tableEntry, 1 )
		hook.Call( "OnPlayerUnearthGem", { }, self.Owner, gemType )
		/*local gemTable = self.Owner:getDarkRPVar( "Gems" )
		gemTable[tableEntry] = gemTable[tableEntry] + 1
		self.Owner:setDarkRPVar( "Gems", gemTable )
		self.Owner:StoreGems( )*/
	end
end

SWEP.PrintName = "Taser"
SWEP.Author = "Jeezy"
SWEP.Purpose = ""
SWEP.Instructions = "Left click to tase the player. Right click to disable Jetpacks."
SWEP.Contact = ""

SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.Weight = 2
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Category = "Noobonic Plague"

SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= ""

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= ""
SWEP.TaserCooldown = 20
SWEP.TaserFireSound = "weapons/stunstick/spark1.wav"
SWEP.WepIconBounceRate = 6
SWEP.WepIconBounceOffset = 4

if ( SERVER ) then

	local function BlockSuicide( ply )
		if ( IsValid( ply ) and ply.isTasered ) then
			DarkRP.notify( ply, 1, 4, "You cannot suicide while tased!" )
			return false
		end
	end

	function SWEP:PrimaryAttack( )
		self.nextTase = self.nextTase or CurTime( )
		if ( self.nextTase > CurTime( ) ) then
			local taseDelay = string.NiceTime( math.Round( self.nextTase - CurTime( ) ) )
			DarkRP.notify( self.Owner, 1, 4, "Your taser is recharging.. " .. taseDelay .. " left!" )
			return
		end
		local policeData = { }
		local rangeBonus = 0
		local levelMulti = SVNOOB_VARS:Get( "TaserLevelMulti", true, "number", 4 )
		local baseRange = SVNOOB_VARS:Get( "TaserBaseRange", true, "number", 225 )
		if not ( self.Owner:IsBot( ) ) then
			policeData = NOOBRP_SkillAlgorithms:CalculatePolice( self.Owner )
			rangeBonus = ( ( policeData["CurrentLevel"] / 3 or 0 ) * levelMulti )
		end
		rangeBonus = baseRange + rangeBonus
		self.Owner:LagCompensation( true )
		local traceRes = self.Owner:RangeEyeTrace( rangeBonus, { self } )
		self.Owner:LagCompensation( false )
		if ( !IsValid( traceRes.Entity ) ) then return end
		if ( traceRes.Entity:GetClass( ) == "prop_physics" and traceRes.Entity:GetCollisionGroup( ) == COLLISION_GROUP_WEAPON ) then
			local distLeft = rangeBonus * ( 1 - traceRes.Fraction )
			local traceData = { }
			traceData.start = traceRes.HitPos
			traceData.endpos = traceData.start + self.Owner:GetAimVector( ) * distLeft
			traceData.filter = { self.Owner, traceRes.Entity, self }
			self.Owner:LagCompensation( true )
			local propTraceRes = util.TraceLine( traceData )
			self.Owner:LagCompensation( false )
			if ( IsValid( propTraceRes.Entity ) and propTraceRes.Entity:IsPlayer( ) ) then
				traceRes = propTraceRes
			end
		end

		if ( !traceRes.Entity:IsPlayer( ) ) then return end
		local traceEnt = traceRes.Entity
		//if ( traceEnt:getDarkRPVar( "IsGhost" ) ) then return end
		if ( traceEnt:IsGhost( ) ) then return end
		if ( traceEnt:Team( ) == TEAM_ZOMBIE ) then
			DarkRP.notify( self.Owner, 1, 4, "The taser has no effect!" )
			return
		end
		if (self.Owner:IsShrunk()) then 
			self.Owner:ChatPrint( "Settle down, tazers are for grown ups." )
			return
		end
		if not ( traceEnt:getDarkRPVar( "wanted" ) ) then
			DarkRP.notify( self.Owner, 1, 4, "You may only tase individuals who're wanted!" )
			return
		end
		if ( traceEnt:IsWearingHat( { "turtle_hat", "uncommon_turtle_hat", "rare_turtle_hat" } ) ) then
			DarkRP.notify( self.Owner, 1, 4, "The taser doesn't seem to have an effect." )
			return
		end
		self.nextTase = CurTime( ) + self.TaserCooldown
		self.Owner:EmitSound( self.TaserFireSound )
		if ( self.Owner:IsPacifist( ) ) then
			self.Owner:RevokePacifism( )
		end
		traceEnt:ParalyzePlayer( 10, self.Owner )
	end

	function SWEP:FireZapBolt( )
		local hitEntity = self.Owner:GetEyeTrace( ).Entity
		if ( IsValid( hitEntity ) and hitEntity:IsPlayer( ) ) then
			if ( hitEntity:IsWearingBackItem( "jetpack" ) ) then
				hitEntity:ErrorNotify( self.Owner:Nick( ) .. " has blown out your Jetpack!" )
				hitEntity:UnequipBackItem( )
				hitEntity.nextJetpackEquip = CurTime( ) + 5
			end
		end
	end
else

	surface.CreateFont( "N00BRP_TaserIcon", { font = "HalfLife2", size = ScreenScale( 64 ), weight = 750, antialiasing = true, blursize = 0 } )
	surface.CreateFont( "N00BRP_TaserBlur", { font = "HalfLife2", size = ScreenScale( 64 ), weight = 750, antialiasing = true, blursize = 4 } )
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		local iconPos = { x = x + wide / 2, y = y }
		local txtBounce = math.abs( math.sin( CurTime( ) * self.WepIconBounceRate ) ) * self.WepIconBounceOffset
		for i = 1, 5 do
			draw.SimpleText( "d", "N00BRP_TaserBlur", iconPos.x, iconPos.y + txtBounce, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER )
		end
		draw.SimpleText( "d", "N00BRP_TaserIcon", iconPos.x, iconPos.y + txtBounce, Color( 45, 45, 255, 255 ), TEXT_ALIGN_CENTER )
	end

end

function SWEP:Initialize( )
	util.PrecacheSound( self.TaserFireSound )
	self:SetHoldType( "pistol" )
end

function SWEP:SecondaryAttack( )
	self:SetNextSecondaryFire( CurTime( ) + 1 )
	self.nextZapBoltFire = self.nextZapBoltFire or 0
	if ( self.nextZapBoltFire < CurTime( ) ) then
		self.Owner:ZapEffect( self, 1 )
		if ( SERVER ) then
			self:FireZapBolt( )
			self.Owner:EmitSound( "weapons/gauss/fire1.wav" )
		end
		self.nextZapBoltFire = CurTime( ) + 5
	else
		if ( SERVER ) then
			self.Owner:ErrorNotify( "You cannot zap for another " .. string.NiceTime( self.nextZapBoltFire - CurTime( ) ) )
		end
	end
end
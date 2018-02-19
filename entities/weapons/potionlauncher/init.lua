AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )
util.AddNetworkString( "N00BRP_PotionLauncherNET" )
SWEP.PotionFireCooldown = 1
SWEP.SelectedPotion = nil

function SWEP:Initialize( )
	self:SetPotionSkin( math.random( 0, 2 ) )
end

function SWEP:PrimaryAttack( )
	self.nextPotionFire = self.nextPotionFire or 0
	if ( self.nextPotionFire > CurTime( ) ) then return end
	self.nextPotionFire = CurTime( ) + self.PotionFireCooldown
	if ( self.SelectedPotion and self.Owner:HasPotionInPocket( self.SelectedPotion ) ) then
		self.Owner:RemovePotionFromPocket( self.SelectedPotion )
	else
		return
	end
	local potion = ents.Create( "fired_alchemypotion" )
	if not ( IsValid( potion ) ) then return end
	local shootPos = self.Owner:GetShootPos( )
	local shootAng = self.Owner:EyeAngles( )
	local posOffset = shootPos + ( shootAng:Right( ) * 10 )
	potion:SetPos( posOffset + ( self.Owner:GetAimVector( ) * 48 ) )
	local potionAng = self.Owner:GetAngles( )
	potionAng:RotateAroundAxis( potionAng:Right( ), -110 )
	potionAng:RotateAroundAxis( potionAng:Forward( ), 0 )
	potion:SetAngles( potionAng )
	potion.PotionName = self.SelectedPotion
	potion:Spawn( )
	potion.OwningEnt = self.Owner
	local physObj = potion:GetPhysicsObject( )
	if not ( IsValid( physObj ) ) then return end
	local velDir = self.Owner:GetAimVector( )
	local potionVel = ( velDir * 3000 ) + ( VectorRand( ) * 10 )
	physObj:ApplyForceCenter( potionVel )
	self.Owner:EmitSound( "ambient/levels/labs/electric_explosion5.wav", 35, math.random( 100, 150 ) )
	self:SetIsFiring( true )
	timer.Simple( 0.1, function( ) self:SetIsFiring( false ) end )
end

local function OnPotionReceived( len, ply )
	local potionName = net.ReadString( )
	local actWep = ply:GetActiveWeapon( )
	if ( IsValid( actWep ) and actWep:GetClass( ) == "potionlauncher" ) then
		actWep.SelectedPotion = nil
		if ( NOOBRP.PotionFunctions[potionName] ) then
			actWep.SelectedPotion = potionName
		end
	end
end
net.Receive( "N00BRP_PotionLauncherNET", OnPotionReceived )
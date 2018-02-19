AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.SeizeReward = 950


function ENT:Initialize()
	self:SetModel("models/props/jeezy/moneyprinters/money_printer02.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	phys:Wake()
	self:SetPower( 100 )
	self:SetInk( 100 )
	self:SetCoolant( 100 )
	self:SetCPU( 1 )
	self:SetRAM( 1 )
	self.sparking = false
	self.damage = 100
	self.IsMoneyPrinter = true
	if IsValid(self.Owner) then self.uid = self.Owner:UniqueID() end
	
	local printSpeed = self:GetPrintSpeed( )
	local powerDrainRate = SVNOOB_VARS:Get( "PrinterPowerDrainRate" )
	timer.Simple( math.random( printSpeed[1], printSpeed[2] ), function( ) 
		if not ( IsValid( self ) ) then return end
		self:PrintMore( )
	end )
	timer.Simple( math.random( powerDrainRate.min, powerDrainRate.max ), function( )
		if not ( IsValid( self ) ) then return end
		self:DrainCoolant( )
		self:DrainPower( )
	end )
	self.sound = CreateSound(self, Sound("ambient/levels/labs/equipment_printer_loop1.wav"))
	self.sound:SetSoundLevel(52)
	self.sound:ChangeVolume( 0.1, 0 )
	self.sound:PlayEx(1, 100)
	self:DoCoreBoost( )
end

function ENT:DoCoreBoost( )
	local owningEnt = self:Getowning_ent( )
	if not ( IsValid( owningEnt ) ) then return end
	local maxCores = SVNOOB_VARS:Get( "PrinterMaxCores", true, "number", 5 )
	local printingData = NOOBRP_SkillAlgorithms:CalculatePrinting( owningEnt )
	local cpuBonus = math.Clamp( self:GetCPU( ) + math.floor( printingData["CurrentLevel"] / 10 ), 1, maxCores )
	self:SetCPU( cpuBonus )
end

function ENT:Use( activator, caller, useType, val )
	self.nextUse = self.nextUse or CurTime( )
	if ( self.nextUse <= CurTime( ) and activator:KeyDown( IN_RELOAD ) ) then
		net.Start( "N00BRP_MoneyPrinters_Options" )
			net.WriteInt( self.OPEN_CLIENT_MENU, 8 )
			net.WriteEntity( self )
		net.Send( activator )
		self.nextUse = CurTime( ) + 1
	end
end

function ENT:OnTakeDamage(dmg)
	local attacker = dmg:GetAttacker( )
	if ( IsValid( attacker ) and attacker:IsPlayer( ) ) then
		if ( attacker:IsShrunk( ) ) then
			return
		end
	end
	
	if self.burningup then return end

	self.damage = (self.damage or 100) - dmg:GetDamage()
	if self.damage <= 0 then
		local rnd = math.random(1, 10)
		local uid = self.uid
		if rnd < 3 then
			self:BurstIntoFlames()
		else
			self:Destruct()
			self:Remove()
		end
		if IsValid(attacker) and attacker:IsPlayer() and attacker:isCP() then
			if not NOOBRP.PoliceRaids[attacker:UniqueID()] then NOOBRP.PoliceRaids[attacker:UniqueID()] = {} end
			for k,v in pairs(NOOBRP.PoliceRaids[attacker:UniqueID()]) do
				if v.victim == uid then
					if (CurTime() - v.t) > 600 then
						table.remove(NOOBRP.PoliceRaids[attacker:UniqueID()], k)
					else
						return
					end
				end
			end
			attacker:RewardXP( 2, NOOB_SKILL_COP, "PoliceXP", "Civil Protection", true )
			if not NOOBRP.PoliceRaids[attacker:UniqueID()] then NOOBRP.PoliceRaids[attacker:UniqueID()] = {} end
			table.insert(NOOBRP.PoliceRaids[attacker:UniqueID()], {victim = uid, t = CurTime()})
		end
	end
end


function ENT:Think()

	if self:WaterLevel() > 0 then
		self:Destruct()
		self:Remove()
		return
	end

	if not self.sparking then return end
	if ( self:IsOnFire( ) ) then return end

	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetMagnitude(1)
	effectdata:SetScale(1)
	effectdata:SetRadius(2)
	util.Effect("Sparks", effectdata)
end

function ENT:OnRemove()
	if self.sound then
		self.sound:Stop()
	end
end

function ENT:Destruct()
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)
	DarkRP.notify(self:Getowning_ent(), 1, 4, DarkRP.getPhrase("money_printer_exploded"))
end

function ENT:BurstIntoFlames( notOverheating )
	if not ( notOverheating ) then
		local stopBurst = hook.Run("moneyPrinterCatchFire", self)
		if stopBurst == true then return end

		DarkRP.notify(self:Getowning_ent(), 0, 4, DarkRP.getPhrase("money_printer_overheating") )
	end
	self.burningup = true
	local burntime = math.random(8, 18)
	self:Ignite(burntime, 0)
	timer.Simple(burntime, function( ) 
		if not ( IsValid( self ) ) then return end
		self:Fireball( ) 
	end)
end

function ENT:Fireball()
	if not self:IsOnFire() then self.burningup = false return end
	local dist = math.random(20, 280) -- Explosion radius
	self:Destruct()
	for k, v in pairs(ents.FindInSphere(self:GetPos(), dist)) do
		--if not v:IsPlayer() and not v:IsWeapon() and v:GetClass() ~= "predicted_viewmodel" and not v.IsMoneyPrinter then
		if not v:IsPlayer() and not v:IsWeapon() and v:GetClass() ~= "predicted_viewmodel" then
			if ( v.IsMoneyPrinter and v ~= self ) then
				local rndChance = math.random( 2 )
				if ( rndChance == 1 ) then
					v:Destruct( )
					SafeRemoveEntity( v )
				else
					v:BurstIntoFlames( true )
				end
			else
				v:Ignite(math.random(5, 22), 0)
			end
		elseif v:IsPlayer() then
			local distance = v:GetPos():Distance(self:GetPos())
			v:TakeDamage(distance / dist * 100, self, self)
		end
	end
	self:Remove()
end

function ENT:DrainCoolant( )
	local coolantLossAmt = SVNOOB_VARS:Get( "PrinterCoolantDrainAmt" )
	local coolantDrain = math.random( coolantLossAmt.min, coolantLossAmt.max )
	coolantDrain = math.Clamp( self:GetCoolant( ) - coolantDrain, 0, 100 )
	self:SetCoolant( coolantDrain )
end

function ENT:DrainPower( )
	local powerDrainRate = SVNOOB_VARS:Get( "PrinterPowerDrainRate" )
	local powerDrainAmt = SVNOOB_VARS:Get( "PrinterPowerDrainAmt" )
	local powerDrain = math.random( powerDrainAmt.min, powerDrainAmt.max )
	powerDrain = math.Clamp( self:GetPower( ) - powerDrain, 0, 100 )
	self:SetPower( powerDrain )
	timer.Simple( math.random( powerDrainRate.min, powerDrainRate.max ), function( )
		if not ( IsValid( self ) ) then return end
		self:DrainPower( )
		self:DrainCoolant( )
	end )
end

function ENT:DrainInk( )
	local inkLossAmt = SVNOOB_VARS:Get( "PrinterInkDrainAmt" )
	local inkDrain = math.random( inkLossAmt.min, inkLossAmt.max )
	inkDrain = math.Clamp( self:GetInk( ) - inkDrain, 0, 100 )
	self:SetInk( inkDrain )
end

function ENT:PrintMore( )
	if ( self:GetPower( ) <= 0 or self:GetInk( ) <= 0 ) then
		local printSpeeds = self:GetPrintSpeed( )
		self:EmitSound( "npc/combine_soldier/gear3.wav", 75, math.random( 50, 75 ) )
		timer.Simple( math.random( printSpeeds[1], printSpeeds[2] ), function( )
		if not ( IsValid( self ) ) then return end
			self:DrainCoolant( )
			self:PrintMore( )
		end )
		return
	end
	self.sparking = true
	timer.Simple( 3, function( )
		if not ( IsValid( self ) ) then return end
		self:DrainCoolant( )
		self:DrainInk( )
		self:CreateMoneybag( )
	end )
end

function ENT:CreateMoneybag()
	if not IsValid( self ) or self:IsOnFire( ) then return end

	local MoneyPos = self:GetPos()
	local nearbyEntities = ents.FindInBox( ClampWorldVector( self:GetPos( ) - Vector( 256, 256, 256 ) ), ClampWorldVector( self:GetPos( ) + Vector( 256, 256, 256 ) ) ) 
	local visiblePlayers = { }
	local count = 0
	local amount = 0
	for index, ent in ipairs ( nearbyEntities ) do
		if ( string.find( string.lower( ent:GetClass( ) ), "printer" ) ) then
			count = count + 1
		end
	end
	if ( count > 8 ) then
		amount = math.random( 200, 1000 )
	else
		local advXPReward = SVNOOB_VARS:Get( "AdvPrinterXPReward", true, "number", 4 )
		for index, ent in ipairs ( nearbyEntities ) do
			if ( ent:IsPlayer( ) ) then
				if not ( ent:isCP( ) ) and not ( ent:IsGhost( ) ) then
					table.insert( visiblePlayers, { ply = ent, xp = ent:getDarkRPVar( "PrintingXP" ) } )
					ent:RewardXP( advXPReward, NOOB_SKILL_PRINTING, "PrintingXP", "Printing", false )
					ent:UpdateLastCriminalAction( )
				end
			end
		end
		local printBonus = 0
		local baseCPUBonus = SVNOOB_VARS:Get( "PrinterBaseCPUBonus", true, "table", { min = 50, max = 200 } )
		local levelBonus = SVNOOB_VARS:Get( "PrinterLevelPrintBonus", true, "number", 200 )
		local cpuBonus =  math.random( baseCPUBonus.min, baseCPUBonus.max ) * ( self:GetCPU( ) )
		if ( #visiblePlayers > 0 ) then
			table.SortByMember( visiblePlayers, "xp" )
			local printingData = NOOBRP_SkillAlgorithms:CalculatePrinting( visiblePlayers[1].ply )
			printBonus = ( levelBonus * printingData["CurrentLevel"] )
		end
		amount = ( GAMEMODE.Config.mprintamount ~= 0 and GAMEMODE.Config.mprintamount or 250 ) + printBonus + cpuBonus
	end
	if GAMEMODE.Config.printeroverheat then
		local overheatPercent = SVNOOB_VARS:Get( "AdvPrinterOverheatPoint", true, "number", 45 )
		overHeatPercent = math.Clamp( overheatPercent, 10, 90 )
		local chanceToOverheat = SVNOOB_VARS:Get( "AdvPrinterOverheatChance", true, "number", 10 )
		chanceToOverheat = math.Clamp( chanceToOverheat, 2, overheatPercent )
		if ( self:GetCoolant( ) < overheatPercent ) then
			local maxChance = math.Clamp( math.Round( self:GetCoolant( ) / chanceToOverheat ), 1, 100 )
			local overheatChance = math.random( 1, maxChance )
			if ( overheatChance == 1 ) then
				self:BurstIntoFlames( )
			end
		end
	end

	local moneybag = DarkRP.createMoneyBag( Vector( MoneyPos.x + 15, MoneyPos.y, MoneyPos.z + 15 ), amount )
	self.sparking = false
	local printSpeeds = self:GetPrintSpeed( )
	timer.Simple( math.random( printSpeeds[1], printSpeeds[2] ), function( )
		if not ( IsValid( self ) ) then return end
		self:PrintMore( )
	end )
end
function ENT:GetPrintSpeed( )
	local baseSpeeds = SVNOOB_VARS:Get( "PrinterPrintSpeed" )
	local ramBoostMulti = SVNOOB_VARS:Get( "PrinterRAMBoostMulti" )
	local minSpeed = math.Clamp( baseSpeeds.min - ( self:GetRAM( ) * ramBoostMulti ), 5, 1440 )
	local maxSpeed = math.Clamp( baseSpeeds.max - ( self:GetRAM( ) * ramBoostMulti ), minSpeed + 1, 1440 )
	return { minSpeed, maxSpeed }
end

function ENT:CanSeePrinter( ply )
	local traceRes = ply:RangeEyeTrace( 80 )
	if ( IsValid( traceRes.Entity ) and traceRes.Entity == self ) then
		return true
	else
		DarkRP.notify( ply, 1, 4, "You must be in range and looking at the printer." )
		return false
	end
end

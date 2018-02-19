AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString( "N00BRP_MoneyPrinters_Options" )

ENT.SeizeReward = 450
NOOBRP.PoliceRaids = {}

function ENT:Initialize()
	self:SetModel("models/props/jeezy/moneyprinters/basic_money_printer.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	phys:Wake()

	self.sparking = false
	self.damage = 100
	self.IsMoneyPrinter = true
	self:SetPower( 100 )
	self:SetInk( 100 )
	self:SetCPU( 1 )
	if IsValid(self.Owner) then self.uid = self.Owner:UniqueID() end
	local printSpeeds = SVNOOB_VARS:Get( "PrinterPrintSpeed", true, "table", { min = 120, max = 300 } )
	local powerDrainRate = SVNOOB_VARS:Get( "PrinterPowerDrainRate", true, "table", { min = 5, max = 12 } )
	timer.Simple( math.random( printSpeeds.min, printSpeeds.max ), function( ) 
		if not ( IsValid( self ) ) then return end
		self:PrintMore( )
	end )
	timer.Simple( math.random( powerDrainRate.min, powerDrainRate.max ), function( )
		if not ( IsValid( self ) ) then return end
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
			attacker:RewardXP( 1, NOOB_SKILL_COP, "PoliceXP", "Civil Protection", true )
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
	end )
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

function ENT:DrainPower( )
	local powerDrainRate = SVNOOB_VARS:Get( "PrinterPowerDrainRate" )
	local powerDrainAmt = SVNOOB_VARS:Get( "PrinterPowerDrainAmt" )
	local powerDrain = math.random( powerDrainAmt.min, powerDrainAmt.max )
	powerDrain = math.Clamp( self:GetPower( ) - powerDrain, 0, 100 )
	self:SetPower( powerDrain )
	timer.Simple( math.random( powerDrainRate.min, powerDrainRate.max ), function( )
		if not ( IsValid( self ) ) then return end
		self:DrainPower( ) 
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
		local printSpeeds = SVNOOB_VARS:Get( "PrinterPrintSpeed" )
		self:EmitSound( "npc/combine_soldier/gear3.wav", 100, math.random( 50, 75 ) )
		timer.Simple( math.random( printSpeeds.min, printSpeeds.max ), function( )
		if not ( IsValid( self ) ) then return end
			self:PrintMore( )
		end )
		return
	end
	self.sparking = true
	timer.Simple( 3, function( )
		if not ( IsValid( self ) ) then return end
		self:DrainInk( )
		self:CreateMoneybag( )
	end )
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
		amount = math.random( 1, 1000 )
	else
		local basicXPReward = SVNOOB_VARS:Get( "BasicPrinterXPReward", true, "number", 2 )
		for index, ent in ipairs ( nearbyEntities ) do
			if ( ent:IsPlayer( ) ) then
				if not ( ent:isCP( ) ) and not ( ent:IsGhost( ) ) then
					table.insert( visiblePlayers, { ply = ent, xp = ent:getDarkRPVar( "PrintingXP" ) } )
					ent:RewardXP( basicXPReward, NOOB_SKILL_PRINTING, "PrintingXP", "Printing", false )
					ent:UpdateLastCriminalAction( )
				end
			end
		end
		local printBonus = 0
		local baseCPUBonus = SVNOOB_VARS:Get( "PrinterBaseCPUBonus" )
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
		local overheatchance
		if ( GAMEMODE.Config.printeroverheatchance <= 3 ) then
			overheatchance = 22
		else
			overheatchance = GAMEMODE.Config.printeroverheatchance or 22
		end
		if ( math.random( 1, overheatchance ) == 3 ) then self:BurstIntoFlames( ) end
	end

	local moneybag = DarkRP.createMoneyBag( Vector( MoneyPos.x + 15, MoneyPos.y, MoneyPos.z + 15 ), amount )
	self.sparking = false
	local printSpeeds = SVNOOB_VARS:Get( "PrinterPrintSpeed" )
	timer.Simple( math.random( printSpeeds.min, printSpeeds.max ), function( )
		if not ( IsValid( self ) ) then return end
		self:PrintMore( )
	end )
end

local function On_Receive_Printer_NET( len, ply )
	if not ply.lastPrinterNet then ply.lastPrinterNet = 0 end
	if (CurTime() - ply.lastPrinterNet) < 1 then return end
	ply.lastPrinterNet = CurTime()
	local mesType = net.ReadInt( 8 )
	local printEnt = net.ReadEntity( )
	if not IsValid(printEnt) then return end
	local successMessage = nil
	local errorMessage = nil
	if ( mesType == printEnt.REPLENISH_POWER ) then
		if ( printEnt:CanSeePrinter( ply ) ) then
			local powerCost = ( 100 - ( 100 * ( printEnt:GetPower( ) / 100 ) ) ) * printEnt.POWER_COST_MULTI
			if ( ply:canAfford( powerCost ) ) then
				ply:addMoney( -powerCost )
				successMessage = "You paid $" .. powerCost .. " to restore the printer's power."
				printEnt:SetPower( 100 )
			else
				errorMessage = "You cannot afford $" .. powerCost .. " to restore your printer's power."
			end
		end
	elseif ( mesType == printEnt.REFILL_INK ) then
		if ( printEnt:CanSeePrinter( ply ) ) then
			local inkCost = ( 100 - ( 100 * ( printEnt:GetInk( ) / 100 ) ) ) * printEnt.INK_COST_MULTI
			if ( ply:canAfford( inkCost ) ) then
				ply:addMoney( -inkCost )
				successMessage = "You paid $" .. inkCost .. " to refill the printer's ink."
				printEnt:SetInk( 100 )
			else
				errorMessage = "You cannot afford $" .. inkCost .. " to refill the printer's ink."
			end
		end
	elseif ( mesType == printEnt.UPGRADE_CPU ) then
		if ( printEnt:CanSeePrinter( ply ) ) then
			local cpuCost = printEnt:GetCPU( ) * printEnt.CPU_COST_MULTI
			if ( ply:canAfford( cpuCost ) ) then
				local maxCores = SVNOOB_VARS:Get( "PrinterMaxCores" )
				if printEnt:GetClass( ) == "adv_money_printer" then maxCores = maxCores + 1 end
				if ( printEnt:GetCPU( ) >= maxCores ) then
					errorMessage = "That printer's CPU cannot be upgraded anymore."
				else
					ply:addMoney( -cpuCost )
					successMessage = "You paid $" .. cpuCost .. " to upgrade the printer's CPU."
					printEnt:SetCPU( printEnt:GetCPU( ) + 1 )
				end
			else
				errorMessage = "You cannot afford $" .. cpuCost .. " to upgrade the printer's CPU."
			end
		end
	end
		if ( printEnt:GetClass( ) == "adv_money_printer" ) then
			if ( mesType == printEnt.RESTORE_COOLANT ) then
				if ( printEnt:CanSeePrinter( ply ) ) then
					local coolantCost = ( 100 - ( 100 * ( printEnt:GetCoolant( ) / 100 ) ) ) * printEnt.COOLANT_COST_MULTI
					if ( ply:canAfford( coolantCost ) ) then
						ply:addMoney( -coolantCost )
						successMessage = "You paid $" .. coolantCost .. " to restore the printer's coolant."
						printEnt:SetCoolant( 100 )
					else
						errorMessage = "You cannot afford $" .. coolantCost .. " to restore the printer's coolant."
					end
				end
			elseif ( mesType == printEnt.UPGRADE_RAM ) then
				if ( printEnt:CanSeePrinter( ply ) ) then
					local ramCost = printEnt:GetRAM( ) * printEnt.RAM_COST_MULTI
					if ( ply:canAfford( ramCost ) ) then
						local maxRAM = #printEnt.RAMLevelNames
						if ( printEnt:GetRAM( ) >= maxRAM ) then
							errorMessage = "That printer's RAM cannot be upgraded anymore."
						else
							ply:addMoney( -ramCost )
							successMessage = "You paid $" .. ramCost .. " to upgrade the printer's RAM."
							printEnt:SetRAM( printEnt:GetRAM( ) + 1 )
						end
					else
					errorMessage = "You cannot afford $" .. ramCost .. " to upgrade the printer's RAM."
				end
			end
		end
	end
	if ( successMessage ) then
		DarkRP.notify( ply, 2, 4, successMessage )
	elseif ( errorMessage ) then
		DarkRP.notify( ply, 1, 4, errorMessage )
	end
end
net.Receive( "N00BRP_MoneyPrinters_Options", On_Receive_Printer_NET )
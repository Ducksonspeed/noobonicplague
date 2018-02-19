util.AddNetworkString( "N00BRP_PlayerSkill_Net" )
-- Important Enums
NOOB_SKILL_MINING = "darkrp_miningxp"
NOOB_SKILL_COP = "darkrp_policexp"
NOOB_SKILL_RUNNING = "darkrp_runningxp"
NOOB_SKILL_CRIMINAL = "darkrp_criminalxp"
NOOB_SKILL_PRINTING = "darkrp_printingxp"
NOOB_SKILL_ENDURANCE = "darkrp_endurancexp"

NOOB_SKILLFUNCTIONS = NOOB_SKILLFUNCTIONS or { }
NOOB_SKILLFUNCTIONS[NOOB_SKILL_MINING] = NOOBRP_SkillAlgorithms.CalculateMining
NOOB_SKILLFUNCTIONS[NOOB_SKILL_COP] = NOOBRP_SkillAlgorithms.CalculatePolice
NOOB_SKILLFUNCTIONS[NOOB_SKILL_RUNNING] = NOOBRP_SkillAlgorithms.CalculateRunning
NOOB_SKILLFUNCTIONS[NOOB_SKILL_CRIMINAL] = NOOBRP_SkillAlgorithms.CalculateCriminal
NOOB_SKILLFUNCTIONS[NOOB_SKILL_PRINTING] = NOOBRP_SkillAlgorithms.CalculatePrinting
NOOB_SKILLFUNCTIONS[NOOB_SKILL_ENDURANCE] = NOOBRP_SkillAlgorithms.CalculateEndurance

NOOB_SKILLCAPES = NOOB_SKILLCAPES or { }
NOOB_SKILLCAPES[NOOB_SKILL_MINING] = "mining_skill_cape"
NOOB_SKILLCAPES[NOOB_SKILL_COP] = "police_skill_cape"
NOOB_SKILLCAPES[NOOB_SKILL_RUNNING] = "running_skill_cape"
NOOB_SKILLCAPES[NOOB_SKILL_CRIMINAL] = "criminal_skill_cape"
NOOB_SKILLCAPES[NOOB_SKILL_PRINTING] = "printing_skill_cape"

local enduranceBoost = 5

local function ClientRequestSkillTables( len, ply )
	if ( ply.receivedSkillTables ) then return end
	ply.receivedSkillTables = true
	ply:RetrieveSkill( NOOB_SKILL_MINING, "MiningXP" )
	ply:RetrieveSkill( NOOB_SKILL_COP, "PoliceXP" )
	ply:RetrieveSkill( NOOB_SKILL_RUNNING, "RunningXP" )
	ply:RetrieveSkill( NOOB_SKILL_CRIMINAL, "CriminalXP" )
	ply:RetrieveSkill( NOOB_SKILL_PRINTING, "PrintingXP" )
	ply:RetrieveSkill( NOOB_SKILL_ENDURANCE, "EnduranceXP", function( ) 
		if not ( ply.retrievedBonusHealth ) then
			timer.Simple( 1, function( )
			ply:ApplyBonusHealth( 100 ) 
			ply.retrievedBonusHealth = true
			end )
		end
	end )
end
net.Receive( "N00BRP_PlayerSkill_Net", ClientRequestSkillTables )

local function TriggerRunningXPGain( ply, keyCode )
	if ( keyCode == IN_FORWARD and !ply:InVehicle( ) and ply:GetObserverMode( ) == OBS_MODE_NONE ) then
		ply.runningStartTime = ply.runningStartTime or 0
		if ( ply.runningStartTime == 0 ) then
			ply.runningStartTime = CurTime( )
		end
	end
end

hook.Add( "KeyPress", "N00BRP_TriggerRunningXPGain_KeyPress", TriggerRunningXPGain )

local function GiveRunningXPGain( ply, keyCode )
	if ( keyCode == IN_FORWARD ) then
		//if ( ply:getDarkRPVar( "IsGhost" ) ) then
		if ( ply:IsGhost( ) ) then
			ply.runningStartTime = 0
			return
		end
		if ( ply.runningStartTime and ply.runningStartTime ~= 0 and !ply.IsInVehicle ) then
			local xpGain = math.Round( ( CurTime( ) - ply.runningStartTime ) * 4 )
			ply.runningStartTime = 0
			ply:RewardXP( xpGain, NOOB_SKILL_RUNNING, "RunningXP", "Running", false )
		end
	end
end
hook.Add( "KeyRelease", "N00BRP_TriggerRunningXPGain_KeyReleased", GiveRunningXPGain )

local function BeginEnduranceTimer( ply )
	if ( ply:IsBot( ) ) then return end
	local entIndex = ply:EntIndex( )
	timer.Create( entIndex .. ":EnduranceGainTimer", 60, 0, function( )
		if not ( IsValid( ply ) ) then
			timer.Destroy( entIndex .. ":EnduranceGainTimer" )
			return
		end
		if not ( ply:getDarkRPVar( "EnduranceXP" ) ) then return end
		ply:RewardXP( 1, NOOB_SKILL_ENDURANCE, "EnduranceXP", "Endurance", false )
	end )
	local itemDropInterval = SVNOOB_VARS:Get( "ItemDropInterval", true, "number", 300 )
	timer.Create( entIndex .. ":ItemDropTimer", itemDropInterval, 0, function( )
		if not ( IsValid( ply ) ) then
			timer.Destroy( entIndex .. ":ItemDropTimer" )
			return
		end
		ply:RollForItemDrop( )
	end )
end
hook.Add( "NOOBRP_OnRequestData", "N00BRP_BeginEnduranceTimer_OnRequestData", BeginEnduranceTimer )

local function OpenSkillMenu( ply, args )
	ply:ConCommand( "noob_toggleskillsmenu" )
end
DarkRP.defineChatCommand( "skillmenu", OpenSkillMenu )
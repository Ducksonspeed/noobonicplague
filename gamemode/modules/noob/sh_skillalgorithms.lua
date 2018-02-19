NOOBRP_SkillAlgorithms = { }

function NOOBRP_SkillAlgorithms:CalculateMining( ply )
	local xp = ply:getDarkRPVar( "MiningXP" ) or 0
	if ( xp ) then
		local currentLevel = math.floor(math.sqrt(xp/560))
		if ( tostring( currentLevel ) == "-inf" ) then currentLevel = 0 end
		local nextLevel = currentLevel + 1
		local requiredXP = (math.pow(nextLevel, 2) * 560) 
	return { ["CurrentLevel"] = currentLevel, ["RequiredXP"] = requiredXP }
	else
		return { ["CurrentLevel"] = 0 }
	end
end

function NOOBRP_SkillAlgorithms:CalculateRunning( ply )
	local xp = ply:getDarkRPVar( "RunningXP" ) or 0
	if ( xp ) then
		local currentLevel = math.floor(math.sqrt(xp/10000))	
		if ( tostring( currentLevel ) == "-inf" ) then currentLevel = 0 end
		local nextLevel = currentLevel + 1
		local requiredXP = math.Round((math.pow(nextLevel, 2) * 10000) )
		return { ["CurrentLevel"] = currentLevel, ["RequiredXP"] = requiredXP }
	else
		return { ["CurrentLevel"] = 0 }
	end
end
function NOOBRP_SkillAlgorithms:CalculateEndurance( ply )
	local xp = ply:getDarkRPVar( "EnduranceXP" ) or 0
	if ( xp ) then
		local currentLevel = math.floor( xp / 1440 )
		local requiredXP = ( 1440 * math.ceil( xp / 1440 ) )
		return { ["CurrentLevel"] = currentLevel, ["RequiredXP"] = requiredXP }
	else
		return { ["CurrentLevel"] = 0 };
	end
end

function NOOBRP_SkillAlgorithms:CalculatePolice( ply )
	local xp = ply:getDarkRPVar( "PoliceXP" ) or 0
	if ( xp ) then
		local currentLevel = math.floor(math.sqrt(xp/4))
		if ( tostring( currentLevel ) == "-inf" ) then currentLevel = 0 end
		local nextLevel = currentLevel + 1
		local requiredXP = math.Round((math.pow(nextLevel, 2) * 4) )
	return { ["CurrentLevel"] = currentLevel, ["RequiredXP"] = requiredXP }
	else
		return { ["CurrentLevel"] = 0 }
	end
end

function NOOBRP_SkillAlgorithms:CalculateCriminal( ply )
	local xp = ply:getDarkRPVar( "CriminalXP" ) or 0
	if ( xp ) then
		local currentLevel = math.floor(math.sqrt(xp/4))
		if ( tostring( currentLevel ) == "-inf" ) then currentLevel = 0 end
		local nextLevel = currentLevel + 1
		local requiredXP = math.Round((math.pow(nextLevel, 2) * 4) )
	return { ["CurrentLevel"] = currentLevel, ["RequiredXP"] = requiredXP }
	else
		return { ["CurrentLevel"] = 0 }
	end
end

function NOOBRP_SkillAlgorithms:CalculatePrinting( ply )
	local xp = ply:getDarkRPVar( "PrintingXP" ) or 0
	if ( xp ) then
		local currentLevel = math.floor(math.sqrt(xp/20))
		if ( tostring( currentLevel ) == "-inf" ) then currentLevel = 0 end
		local nextLevel = currentLevel + 1
		local requiredXP = math.Round((math.pow(nextLevel, 2) * 20) )
	return { ["CurrentLevel"] = currentLevel, ["RequiredXP"] = requiredXP }
	else
		return { ["CurrentLevel"] = 0 }
	end
end


function NOOBRP_SkillAlgorithms:CalculateHerbalism( ply )
	local xp = ply:getDarkRPVar( "HerbalismXP" ) or 0
	if ( xp ) then
		local currentLevel = math.floor(math.sqrt(xp/20))
		if ( tostring( currentLevel ) == "-inf" ) then currentLevel = 0 end
		local nextLevel = currentLevel + 1
		local requiredXP = math.Round((math.pow(nextLevel, 2) * 20) )
	return { ["CurrentLevel"] = currentLevel, ["RequiredXP"] = requiredXP }
	else
		return { ["CurrentLevel"] = 0 }
	end
end

function NOOBRP_SkillAlgorithms:CalculateAlchemy( ply )
	local xp = ply:getDarkRPVar( "AlchemyXP" ) or 0
	if ( xp ) then
		local currentLevel = math.floor(math.sqrt(xp/3))
		if ( tostring( currentLevel ) == "-inf" ) then currentLevel = 0 end
		local nextLevel = currentLevel + 1
		local requiredXP = math.Round((math.pow(nextLevel, 2) * 3 ) )
	return { ["CurrentLevel"] = currentLevel, ["RequiredXP"] = requiredXP }
	else
		return { ["CurrentLevel"] = 0 }
	end
end
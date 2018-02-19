local ingredientsTableValues = {
	["burdockroot"] = "Burdock Root",
	["gingkobiloba"] = "Gingko Biloba",
	["valerianroot"] = "Valerian Root",
	["coralfungus"] = "Coral Fungus",
	["redreishi"] = "Red Reishi",
	["psilocybecubensis"] = "Psilocybe Cubensis"
}

NOOB_SKILL_HERBALISM = "darkrp_herbalism"
NOOB_SKILL_ALCHEMY = "darkrp_alchemy"

NOOB_SKILLFUNCTIONS = NOOB_SKILLFUNCTIONS or { }
NOOB_SKILLFUNCTIONS[NOOB_SKILL_HERBALISM] = NOOBRP_SkillAlgorithms.CalculateHerbalism
NOOB_SKILLFUNCTIONS[NOOB_SKILL_ALCHEMY] = NOOBRP_SkillAlgorithms.CalculateAlchemy

NOOB_SKILLCAPES = NOOB_SKILLCAPES or { }
NOOB_SKILLCAPES[NOOB_SKILL_HERBALISM] = "herbalism_skill_cape"
NOOB_SKILLCAPES[NOOB_SKILL_ALCHEMY] = "alchemy_skill_cape"

if ( SERVER ) then
	local function RequestIngredientData( ply )
		ply:RetrieveIngredients( )
		ply:RetrieveSkill( NOOB_SKILL_HERBALISM, "HerbalismXP" )
		ply:RetrieveSkill( NOOB_SKILL_ALCHEMY, "AlchemyXP" )
	end
	hook.Add( "NOOBRP_OnRequestData", "N00BRP_RequestIngredientData_OnRequestData", RequestIngredientData )

	local function AttemptAlchemyCraft( ply, cmd, args, fstring )
		if not ( args[1] ) then return end
		local AlchemyRecipes = NOOBRP.AlchemyRecipes
		if not ( AlchemyRecipes[ args[1] ] ) then return end
		if ( ply:isArrested( ) ) then return end
		if ( ply:IsGhost( ) ) then return end
		local ingredientData = ply:getDarkRPVar( "Ingredients" )
		local alchData = AlchemyRecipes[ args[1] ]
		local canCraft = true
		local failReason = ""
		local currentLevel = ( tonumber( NOOBRP_SkillAlgorithms:CalculateAlchemy( ply )["CurrentLevel"] ) or 0 )
		if not ( alchData ) then
			DarkRP.notify( ply, 1, 4, "That recipe doesn't exist!" )
			return
		end
		local requiredIngredients = { }
		for index, ingredient in ipairs ( alchData.ingredients ) do
			requiredIngredients[ingredient.name] = ingredient.amt
		end
		if not ( ply:HasHerbs( requiredIngredients ) ) then
			DarkRP.notify( ply, 1, 4, "You lack the ingredients to craft that Potion!" )
			return
		end
		if not ( currentLevel >= alchData.levelReq ) then
			DarkRP.notify( ply, 1, 4, "You must be Alchemy Level " .. alchData.levelReq .. " to craft that!" )
			return
		end
		if ( util.CheckCustomEntLimit( "ent_alchemypotion", ply, "AlchemyPotionLimit", "Alchemy Potion" ) ) then return end
		ply:TakeHerbs( requiredIngredients )
		local potionAmount = 1
		if ( currentLevel > 50 ) then
			potionAmount = math.random( 1, 2 )
		end
		ply:ChatPrint( "You successfully crafted x" .. potionAmount .. " " .. args[1] .. "(s)!" )
		for i=1, potionAmount do
			local craftedPotion = ents.Create( "ent_alchemypotion" )
			craftedPotion:Setowning_ent( ply )
			craftedPotion:SetPos( ply:RangeEyeTrace( 80 ).HitPos )
			craftedPotion:Spawn( )
			craftedPotion:SetPotionName( args[1] ) 
			craftedPotion.PotionType = args[1]
		end
		ply:RewardXP( AlchemyRecipes[ args[1] ].xp, NOOB_SKILL_ALCHEMY, "AlchemyXP", "Alchemy", true )
		hook.Call( "OnPlayerCraftPotion", { }, ply, args[1], potionAmount )
	end
	concommand.Add( "rp_alchemycraft", AttemptAlchemyCraft )
end
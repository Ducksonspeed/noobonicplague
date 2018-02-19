ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Herb Garden"
ENT.Author = "Jeezy"
ENT.Spawnable = false
ENT.OPEN_MENU = 1
ENT.WATER_HERB = 2
ENT.HARVEST_HERB = 3
ENT.PLANT_HERB = 4
ENT.WaterCostMultiplier = 10
ENT.PlantHerbCost = 1000

function ENT:SetupDataTables( )
	self:NetworkVar( "Entity", 0, "owning_ent" )
	self:NetworkVar( "Int", 0, "PlantOneStage" )
	self:NetworkVar( "Int", 1, "PlantTwoStage" )
	self:NetworkVar( "Int", 2, "PlantThreeStage" )
	self:NetworkVar( "Int", 3, "PlantFourStage" )
	self:NetworkVar( "String", 0, "PlantsHydration" )
end
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Radio"
ENT.Author = "Jeezy"
ENT.Spawnable = false
ENT.RadioMenu = 1
ENT.PlayRadio = 2
ENT.StopRadio = 3
ENT.SetStation = 4

function ENT:SetupDataTables( )
	self:NetworkVar( "String", 0, "RadioStation" )
	self:NetworkVar( "Bool", 0, "IsPlaying" )
	self:NetworkVar( "Entity", 0, "owning_ent" )
end
local function RequestSkillTables( )
	net.Start( "N00BRP_PlayerSkill_Net" )
	net.SendToServer( )
end
hook.Add( "InitPostEntity", "N00BRP_RequestSkillTables_InitPostEntity", RequestSkillTables )
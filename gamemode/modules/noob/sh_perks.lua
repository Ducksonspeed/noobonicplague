NOOB_PERK_TREE =
{
	["Offensive Perks"] =
	{
		["Placement"] = 1,
		[1] = { "+5% Damage -5% Defense", func = function( dmgInfo ) dmgInfo:ScaleDamage( 1.05 )  end },
		[2] = { "+10% Damage -10% Defense", func = function( dmgInfo ) dmgInfo:ScaleDamage( 1.10 )  end },
		[3] = { "+15% Damage -15% Defense", func = function( dmgInfo ) dmgInfo:ScaleDamage( 1.15 )  end },
		[4]	= { "+20% Damage -20% Defense", func = function( dmgInfo ) dmgInfo:ScaleDamage( 1.20 )  end },
		[5] = { "Access To rp_teamattack" }
	},
	["Defensive Perks"] =
	{
		["Placement"] = 2,
		[1] = { "+5% Defense -5% Damage", func = function( dmgInfo ) dmgInfo:ScaleDamage( 0.95 ) end },
		[2] = { "+10% Defense -10% Damage", func = function( dmgInfo ) dmgInfo:ScaleDamage( 0.90 ) end },
		[3] = { "+15% Defense -15% Damage", func = function( dmgInfo ) dmgInfo:ScaleDamage( 0.85 ) end },
		[4] = { "+20% Defense -20% Damage", func = function( dmgInfo ) dmgInfo:ScaleDamage( 0.8 ) end },
		[5] = { "Access to rp_teamdefense" },
	},
	["Healing Perks"] =
	{
		["Placement"] = 3,
		[1] = { "+10% Healing Rate" },
		[2] = { "+20% Healing Rate" },
		[3] = { "+50% Healing Rate" },
		[4] = { "Access to rp_healall" },
		[5] = { "Instant Ressurection" }
	},
	[ "Lockpicking Perks" ] = 
	{
		["Placement"] = 4,
		[1] = { "+10% Lockpicking Speed" },
		[2] = { "+20% Lockpicking Speed" },
		[3] = { "+30% Lockpicking Speed" },
		[4] = { "+40% Lockpicking Speed" },
		[5] = { "Lockpick Instantly" }
	},
	["Running Speed Perks"] =
	{
		["Placement"] = 5,
		[1] = { "+5% Running Speed", percent = 1.05 },
		[2] = { "+10% Running Speed", percent = 1.1 },
		[3] = { "+15% Running Speed", percent = 1.15 },
		[4] = { "+20% Running Speed", percent = 1.2 },
		[5] = { "Access to rp_teamsprint" }
	},
	["Stealth Perks"] =
	{
		["Placement"] = 6,
		[1] = { "Access to rp_stealth", time = 5 },
		[2] = { "7 Second Stealth Length", time = 7 },
		[3] = { "9 Second Stealth Length", time = 9 },
		[4] = { "12 Second Stealth Length", time = 12 },
		[5] = { "14 Second Stealth Length", time = 14 }
	}
}

if ( SERVER ) then
	if not ( file.IsDir( "noob", "DATA" ) ) then file.CreateDir( "noob" ) end
	if not ( file.IsDir( "noob/playerperks", "DATA" ) ) then file.CreateDir( "noob/playerperks" ) end
	local function RetrievePerkPoints( ply )
		ply:RetrievePerkPoints( )
	end
	hook.Add( "NOOBRP_OnRequestData", "N00BRP_RetrievePerkPoints_OnRequestData", RetrievePerkPoints )
end
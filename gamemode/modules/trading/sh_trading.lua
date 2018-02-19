TRADING_SYSTEM = {};

if ( SERVER ) then
	// seconds, default: 5 [SERVER]
	TRADING_SYSTEM.TRADE_DELAY = 30;

	// enable the trade system? disable if urgent.
	TRADING_SYSTEM.ENABLED = true;

	TRADING_SYSTEM.ITEM_RESTRICTIONS =
	{
		[ "beast_hat" ] = true,
		[ "cp_mask" ] = true,
		[ "dart_gun" ] = true,
		[ "weapon_crowbar" ] = true,
		[ "towel_hat" ] = true,
		[ "gold_towel_hat" ] = true,
		[ "potionlauncher" ] = true,
		[ "lasersmg" ] = true,
		[ "mining_skill_cape" ] = true,
		[ "running_skill_cape" ] = true,
		[ "printing_skill_cape" ] = true,
		[ "police_skill_cape" ] = true,
		[ "criminal_skill_cape" ] = true,
		[ "alchemy_skill_cape" ] = true,
		[ "herbalism_skill_cape" ] = true
	};

	TRADING_SYSTEM.ITEM_NICEFORMAT =
	{
		[ "Gems" ] =
		{
			[ "rocks" ] = "Rocks",
			[ "granite" ] = "Granite",
			[ "shale" ] = "Shale",
			[ "emeralds" ] = "Emeralds",
			[ "rubies" ] = "Rubies",
			[ "sapphires" ] = "Sapphires",
			[ "obsidians" ] = "Obsidians",
			[ "diamonds" ] = "Diamonds"
		},
		[ "Ingredients" ] =
		{
			[ "burdockroot" ] = "Burdock Root",
			[ "gingkobiloba" ] = "Gingko Biloba",
			[ "valerianroot" ] = "Valerian Root",
			[ "coralfungus" ] = "Coral Fungus",
			[ "redreishi" ] = "Red Reishi",
			[ "psilocybecubensis" ] = "Psilocybe Cubensis"
		}
	};
end

// how many individual items are they able to trade? [SHARED]
TRADING_SYSTEM.MAX_SLOTS = 30;


local PERMWEPS_REQUESTALL = 1
local PERMWEPS_SENDWEP = 2
local CAT_WEAPON = 1
local CAT_VEHICLE = 2
local CAT_ACCESSORY = 3
local CAT_TOOL = 4

noob_WeaponIndex = { }
local plyMeta = FindMetaTable( "Player" )

if ( SERVER ) then
	util.AddNetworkString( "N00BRP_PermWeapons_NET" )
	local function Receive_PermWeapon_NET( len, ply )
		if ( ply.requestedPermWeapons ) then return end
		ply.requestedPermWeapons = true
		local mesType = net.ReadInt( 8 )
		if ( mesType == PERMWEPS_REQUESTALL ) then
			timer.Simple( 1, function( )
				ply:RetrievePermWeapons( )
			end )
		end
	end
	net.Receive( "N00BRP_PermWeapons_NET", Receive_PermWeapon_NET )

	local function Select_Weapon( ply, cmd, args, fstring )
		local validWep = noob_WeaponIndex:Get( args[1] )
		if not ( validWep ) then return end
		if not ( ply:HasWeaponStored( args[1] ) ) then return end
		local wepTable = weapons.Get( args[1] )
		if ( ply:IsPermaDisabled( args[1] ) ) then return end
		if ( istable( wepTable ) and isfunction( wepTable.CanEquip ) and !wepTable.CanEquip( ply ) ) then return end
		if ( ply:Team( ) == TEAM_ZOMBIE and args[1] ~= "weapon_crowbar" ) then return end
		if ( ply:IsCivilian( ) and !( validWep.citizen ) ) then return end
		if ( ply:IsCrab( ) and !( validWep.crab ) ) then return end
		if ( ply:GetObserverMode( ) ~= OBS_MODE_NONE ) then return end
		//if ( ply:GetBodyPartInjured( ENUM_INJURIES_ARMS ) and !ply.aboutToGhost and !ply:getDarkRPVar( "IsGhost" ) ) then
		if ( ply:GetBodyPartInjured( ENUM_INJURIES_ARMS ) and !ply.aboutToGhost and !ply:IsGhost( ) ) then
			DarkRP.notify( ply, 1, 4, "Your arms are in too much pain to equip a weapon." )
			return
		end
		if ( ply.isTasered ) then
			--DarkRP.notify( ply, 1, 4, "You're too dizzy to equip a weapon." )
			return
		end
		if ( ply.cantEquipWeapons ) then
			DarkRP.notify( ply, 1, 4, "You're too dizzy to equip a weapon." )
			return
		end
		if ( ply:HasWeapon( args[1] ) ) then
			ply:SelectWeapon( args[1] )
		else
			ply:Give( args[1], true )
			ply:SelectWeapon( args[1] )
		end
	end
	concommand.Add( "rp_selectwep", Select_Weapon )
else
	local function RequestPermanentWeapons( )
		net.Start( "N00BRP_PermWeapons_NET" )
			net.WriteInt( PERMWEPS_REQUESTALL, 8 )
		net.SendToServer( )
	end
	hook.Add( "InitPostEntity", "N00BRP_RequestPermanentWeapons_InitPostEntity", RequestPermanentWeapons )
end

function noob_WeaponIndex:Add( class, niceName, cat, civilianWep, crabWep )
	noob_WeaponIndex[ class ] = { name = niceName, category = cat, citizen = civilianWep, crab = crabWep }
end

function noob_WeaponIndex:Get( class )
	return noob_WeaponIndex[ class ]
end

function plyMeta:IsCivilian( )
	local civilianJobs = { TEAM_CITIZEN, TEAM_PARAMEDIC, TEAM_FOREMAN, TEAM_SCIENTIST, TEAM_CONSTRUCTION, TEAM_CAMERAMAN, TEAM_TIDES, TEAM_HERBALIST }
	for index, job in ipairs ( civilianJobs ) do
		if ( self:Team( ) == job ) then
			return true
		end
	end
	return false
end

function plyMeta:IsCrab( )
	return ( self:Team( ) == TEAM_CRAB )
end

noob_WeaponIndex:Add( "arrest_stick", "Arrest Baton", CAT_TOOL, false, false )
noob_WeaponIndex:Add( "chopshop_tool", "Chopshop Tool", CAT_TOOL, false, false )
noob_WeaponIndex:Add( "door_ram", "Battering Ram", CAT_TOOL, false, false )
noob_WeaponIndex:Add( "gmod_tool", "Tool Gun", CAT_TOOL, true, false )
noob_WeaponIndex:Add( "lockpick", "Lockpick", CAT_TOOL, false, false )
noob_WeaponIndex:Add( "med_kit", "Medic Kit", CAT_TOOL, true, false )
noob_WeaponIndex:Add( "stunstick", "Stun Baton", CAT_TOOL, false, false )
noob_WeaponIndex:Add( "taser", "Taser", CAT_TOOL, false, false )
noob_WeaponIndex:Add( "backpack", "Backpack", CAT_TOOL, true, false )
noob_WeaponIndex:Add( "unarrest_stick", "Unarrest Baton", CAT_TOOL, false, false )
noob_WeaponIndex:Add( "weapon_keypadchecker", "Keypad Checker", CAT_TOOL, true, false )
noob_WeaponIndex:Add( "weaponchecker", "Weapon Checker", CAT_TOOL, false, false )
noob_WeaponIndex:Add( "gmod_camera", "Camera", CAT_TOOL, true, true )
noob_WeaponIndex:Add( "spy_kit", "Disguise Kit", CAT_TOOL, true, false )
noob_WeaponIndex:Add( "news_camera", "Broadcasting Camera", CAT_TOOL, true, false )
noob_WeaponIndex:Add( "vip_lockpick", "VIP Lockpick", CAT_TOOL, true, false )
noob_WeaponIndex:Add( "jetpack", "Jetpack", CAT_ACCESSORY, true, true )
noob_WeaponIndex:Add( "skull_hat", "Oldfag Skull Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "skull_hat_2011", "Skull Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "top_hat", "Top Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "uncommon_top_hat", "Uncommon Top Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "rare_top_hat", "Rare Top Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "bandana", "Bandana", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "gas_mask", "Gas Mask", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "plant_hat", "Plant Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "towel_hat", "Towel Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "donut_towel_hat", "Donut's Towel Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "fsdyn_towel_hat", "FS DYN3STY's Towel Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "antlers", "Antlers", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "gold_towel_hat", "Golden Towel Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "turtle_hat", "Turtle Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "uncommon_turtle_hat", "Uncommon Turtle Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "rare_turtle_hat", "Rare Turtle Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "traffic_hat", "Traffic Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "uncommon_traffic_hat", "Uncommon Traffic Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "rare_traffic_hat", "Rare Traffic Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "hamburger_hat", "Hamburger Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "santa_hat", "Santa Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "beast_hat", "Beast Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "golden_beast_hat", "Golden Beast Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "soccer_hat", "Soccer Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "occupy_hat", "Occupy Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "boot_hat", "Boot Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "cp_mask", "Civil Protection Mask", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "surgical_mask", "Surgical Mask", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "rare_surgical_mask", "Rare Surgical Mask", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "vehicle_hat", "Vehicle Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "meat_hook", "Meat Hook", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "blue_cape", "Blue Cape", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "candy_cane", "Candy Cane", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "giant_banana", "Giant Banana", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "pikachu_hat", "Pikachu Hat", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "wings", "Wings", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "running_skill_cape", "Running Skill Cape", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "mining_skill_cape", "Mining Skill Cape", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "printing_skill_cape", "Printing Skill Cape", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "police_skill_cape", "Police Skill Cape", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "criminal_skill_cape", "Criminal Skill Cape", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "herbalism_skill_cape", "Herbalism Skill Cape", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "alchemy_skill_cape", "Alchemy Skill Cape", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "split_cape", "Split Cape", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "dreadwings", "Dreadwings", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "uncommon_wings", "Uncommon Wings", CAT_ACCESSORY, true, false )
noob_WeaponIndex:Add( "carjacker", "Carjacker", CAT_TOOL, false, false )
noob_WeaponIndex:Add( "noob_camera", "Personal Camera", CAT_TOOL, true, true )
noob_WeaponIndex:Add( "grappling_hook", "Grappling Hook", CAT_TOOL, true, false )
noob_WeaponIndex:Add( "radar_gun", "Radar Gun", CAT_TOOL, false, false )
noob_WeaponIndex:Add( "teleporter", "Teleporter", CAT_TOOL, true, false )
noob_WeaponIndex:Add( "repair_tool", "Repair Tool", CAT_TOOL, true, false )
noob_WeaponIndex:Add( "p50_keys", "Peel P50 Keys", CAT_VEHICLE, true, true )
noob_WeaponIndex:Add( "airboat_keys", "Airboat Keys", CAT_VEHICLE, true, false )
noob_WeaponIndex:Add( "rv_keys", "Recreation Vehicle Keys", CAT_VEHICLE, true, false )
noob_WeaponIndex:Add( "koenigsegg_keys", "Koenigsegg CCX", CAT_VEHICLE, true, false )
noob_WeaponIndex:Add( "jeep_keys", "Jeep Keys", CAT_VEHICLE, true, false )
noob_WeaponIndex:Add( "mclaren_keys", "McLaren MP4-12C Keys", CAT_VEHICLE, true, false )
noob_WeaponIndex:Add( "lexus_keys", "Lexus LF-A Keys", CAT_VEHICLE, true, false )
noob_WeaponIndex:Add( "mustang_keys", "Ford Mustang Boss Keys", CAT_VEHICLE, true, false )
noob_WeaponIndex:Add( "elcamino_keys", "El Camino Keys", CAT_VEHICLE, true, false )
noob_WeaponIndex:Add( "supercab_keys", "Supercab Keys", CAT_VEHICLE, true, false )
noob_WeaponIndex:Add( "policeinterceptor_keys", "Police Interceptor Keys", CAT_VEHICLE, true, false )
noob_WeaponIndex:Add( "bus_keys", "Evo City Bus Keys", CAT_VEHICLE, true, false )
noob_WeaponIndex:Add( "ambulance_keys", "Ambulance Keys", CAT_VEHICLE, true, false )
noob_WeaponIndex:Add( "taurus_keys", "Ford Taurus Keys", CAT_VEHICLE, true, false )
noob_WeaponIndex:Add( "smart_keys", "Smart ForTwo Keys", CAT_VEHICLE, true, false )
noob_WeaponIndex:Add( "quadbike_keys", "Quadbike Keys", CAT_VEHICLE, true, false )
noob_WeaponIndex:Add( "lambo_keys", "Lamborghini Keys", CAT_VEHICLE, true, false )
noob_WeaponIndex:Add( "crab_bite", "Crab Bite", CAT_WEAPON, false, true )
noob_WeaponIndex:Add( "frag_grenade", "Frag Grenade", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "weapon_ar2", "AR2", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "weapon_ak472", "AK47", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "weapon_deagle2", "Deagle", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "weapon_fiveseven2", "Five-Seven", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "weapon_glock2", "Glock", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "weapon_mac102", "Mac-10", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "dart_gun", "Dart Gun", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "ls_sniper", "Silenced Sniper", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "shovel", "Shovel", CAT_WEAPON, true, false )
noob_WeaponIndex:Add( "uncommon_shovel", "Uncommon Shovel", CAT_WEAPON, true, false )
noob_WeaponIndex:Add( "shrink_ray", "Shrink Ray", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "lasersmg", "Laser SMG", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "riot_shield", "Riot Shield", CAT_WEAPON, true, false )
noob_WeaponIndex:Add( "defibrillator", "Defibrillator", CAT_WEAPON, true, false )
noob_WeaponIndex:Add( "disorientator", "Disorientator", CAT_WEAPON, true, false )
noob_WeaponIndex:Add( "weapon_m42", "M4", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "weapon_mp52", "MP5", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "weapon_p2282", "P228", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "weapon_pumpshotgun2", "Pump Shotgun", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "weapon_rpg", "Rocket Launcher", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "weapon_bugbait", "Bug Bait", CAT_WEAPON, true, false )
noob_WeaponIndex:Add( "weapon_crowbar", "Crowbar", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "potionlauncher", "Potion Launcher", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_uncommon_awp", "Uncommon AWP", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_uncommon_m4a1", "Uncommon M4A1", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_uncommon_m249", "Uncommon M249 SAW", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_uncommon_ump", "Uncommon UMP", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_uncommon_galil", "Uncommon Galil", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_uncommon_357", "Uncommon .357", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_357", ".357 Revolver", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_ak47", "AK47", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_rare_ak47", "Rare AK47", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_aug", "Steyr AUG", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_uncommon_aug", "Uncommon Steyr AUG", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_awp", "AWP", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_rare_awp", "Rare AWP", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_deagle", "Desert Eagle", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_famas", "FAMAS F1", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_fiveseven", "Five-Seven", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_g3sg1", "G3SG1", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_galil", "Galil", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_glock18", "Glock-18", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_knife", "Combat Knife", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_rare_knife", "Rare Combat Knife", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_m3super90", "M3 Super 90", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_uncommon_m3super90", "Uncommon M3 Super 90", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_m4a1", "M4A1", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_m249", "M249 SAW", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_mac10", "Mac-10", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_mp5", "MP5", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_uncommon_mp5", "Uncommon MP5", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_p90", "P90", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_p228", "P228", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_scout", "Scout", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_sg550", "SG550", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_sg552", "SG552", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_tmp", "TMP", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_uncommon_tmp", "Uncommon TMP", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_ump", "UMP", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_usp", "USP", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_rare_usp", "Rare USP", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_xm1014", "XM1014", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_rare_mac10", "Rare Mac-10", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_rare_famas", "Rare FAMAS F1", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_rare_deagle", "Rare Desert Eagle", CAT_WEAPON, false, false )
noob_WeaponIndex:Add( "swb_rare_p90", "Rare P90", CAT_WEAPON, false, false )
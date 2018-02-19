ENT.Base 	= "npc_noob_base";

ENT.Model 	 = "models/humans/group01/male_01.mdl";

ENT.Position = Vector( -5711.203, -7533.494, 120.031 )
ENT.Angles = Angle( 0, 180, 0 )
ENT.EnableReputation = false
ENT.isRobbable = true
ENT.robRewardRange = { 500, 1500 }
ENT.onlyCitizens = true
ENT.clothingMaterial = "models/humans/male/players_sheet_shinyleatherjacket"
ENT.FloatingTitle = "Clothing Store"

util.AddNetworkString( "N00BRP_PlayerClothingMenu" )

if ( SERVER ) then
	ENT.NPCTable = 
	{
		[ "ply_buy_clothing"] =
		{
			text = "Purchase Clothing",
			func = function( pl, npcEnt )
				net.Start( "N00BRP_PlayerClothingMenu" )
				net.Send( pl )
			end
		},
		[ "rob_me" ] =
		{
			text = "Hand over the goods, bud.",
			func = function( pl, ent )
				if ( ent.isRobbable and ent.RobNPC ) then
					ent:RobNPC( pl )
				end
			end
		}
	}
end

local gemTypes = {
	["rock"] = {
		color = Color( 255, 255, 255, 255 )
	},
	["granite"] = {
		color = Color( 160, 160, 160, 255 )
	},
	["shale"] = {
		color = Color( 100, 100, 100, 255 )
	},
	["emerald"] = {
		color = Color( 0, 255, 0, 255 ),
		mat = "models/shiny"
	},
	["ruby"] = {
		color = Color( 255, 0, 0, 255 ),
		mat = "models/shiny"
	},
	["sapphire"] = {
		color = Color( 0, 0, 255, 255 ),
		mat = "models/shiny"
	},
	["obsidian"] = {
		color = Color( 0, 0, 0, 255 ),
		mat = "models/shiny"
	},
	["diamond"] = {
		color = Color( 255, 255, 255, 150 ),
		mat = "models/shiny"
	}
}

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.GemType = "Rock"
ENT.OwningPlayer = nil

function ENT:Initialize( )
	self:SetModel( "models/props_junk/rock001a.mdl" ) 
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
    self.weldTable = { }
	local phys = self:GetPhysicsObject( )
	if ( phys:IsValid( ) ) then phys:Wake( ) end
	timer.Simple( SVNOOB_VARS:Get( "GemDespawnTimer" ), function( )
		if not ( IsValid( self ) ) then return end
		SafeRemoveEntity( self )
	end )
end

function ENT:SetGemType( gType )
	self.GemType = gType
	local gemColor, gemMat = gemTypes[string.lower(gType)].color, gemTypes[string.lower(gType)].mat or ""
	self:SetColor( gemColor )
	self:SetMaterial( gemMat )
end

function ENT:SetGemOwner( ply )
	self.OwningPlayer = ply
end

function ENT:Use( activator, caller )
	if ( activator:IsGhost( ) ) then return end
	if self.droppedFrom and IsValid(self.droppedFrom) and self.droppedFrom ~= activator then return end
	local uppLetter = string.upper( string.GetChar( self.GemType, 1 ) )
	local niceWord = string.SetChar( self.GemType, 1, uppLetter )
	activator:ChatPrint( "You've picked up a " .. niceWord .. "!" )
	local tableIndex = niceWord
	if ( niceWord == "Sapphire" ) then
		tableIndex = "Sapphires"
	elseif ( niceWord == "Ruby" ) then
		tableIndex = "Rubies"
	elseif ( niceWord ~= "Granite" and niceWord ~= "Shale" ) then
		tableIndex = tableIndex .. "s"
	end
	activator:GiveGem( tableIndex, 1 )
	SafeRemoveEntity( self )
end

function ENT:StartTouch( ent )
	if ( game.GetMap( ) ~= "rp_evocity_v2d_updated" ) then return end
	if ( IsValid( ent ) and ent:GetClass( ) == "ent_gem" and self.GemType == "obsidian" and ent.GemType == "obsidian" ) then -- fixes issue w/ 2 sets of welded obbies joining
		constraint.Weld( self, ent, 0, 0, 0, true, false ) -- nocollide welds, looks the same, less overhead i think
		local resultTable = { }
		constraint.GetAllConstrainedEntities( ent, resultTable )
		if ( table.Count( resultTable ) == SVNOOB_VARS:Get( "BeastLairObsidianReq", true, "number", 5 ) ) then
			local gemOwners = { }
			local uniqueGemOwners = { }
			local ownerCount = 0
			local ownerString = ""
			for index, gem in pairs ( resultTable ) do
				if ( IsValid( gem.OwningPlayer ) ) then
					if not ( uniqueGemOwners[ gem.OwningPlayer:SteamID( ) ] ) then
						ownerCount = ownerCount + 1
						uniqueGemOwners[ gem.OwningPlayer:SteamID( ) ] = true
					end
					table.insert( gemOwners, gem.OwningPlayer )
					ownerString = ownerString .. gem.OwningPlayer:NiceInfo( ) .. ", "
				end
				if ( index ~= self ) then
					SafeRemoveEntity( index )
				end
			end
			NOOB_LOGGER:Log( NOOB_LOGGING_URGENT, "( " .. ownerString .. " ) Combined Obsidians to make a Beast Portal" , true )
			local port = SpawnBeastLair( gemOwners )
			local beastPortal = ents.Create( "ent_beastportal" )
			beastPortal:SetupPortal( gemOwners, port )
			beastPortal:SetPos( self:GetPos( ) + Vector( 0, 0, 100 ) )
			beastPortal:SetAngles( Angle( 90, 0, 0 ) )
			beastPortal:Spawn( )
			mySQLControl:Query( "INSERT INTO darkrp_beastlairs ( port, spawnTime, spawnDate, playerAmt ) VALUES ( " .. port .. ", " .. os.time( ) .. ", " .. SQLStr( os.date( "%x" ) ) .. ", " .. ownerCount .. ");", function( ) end )
			hook.Call( "OnBeastPortalOpened", { }, gemOwners, beastPortal )
			SafeRemoveEntity( self )
		end
	end
end

function ENT:OnRemove()
	if ( IsValid( self.OwningPlayer ) ) then
		self.OwningPlayer.droppedGems = math.Clamp( self.OwningPlayer.droppedGems - 1, 0, 5 )
	end
end
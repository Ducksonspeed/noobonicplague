local RatingUseTable = { }
/*--------------------------------------------------------- 
Name: Make the table if it doesn't exist 
---------------------------------------------------------*/ 
if ( !sql.TableExists( "ratings" ) ) then 

	sql.Query( "CREATE TABLE IF NOT EXISTS ratings ( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, target INTEGER, rater INTEGER, rating INTEGER );" ) 
	sql.Query( "CREATE INDEX IDX_RATINGS_TARGET ON ratings ( target DESC )" ) 
	Msg("SQL: Created ratings table!\n") 
	 
end 


/*--------------------------------------------------------- 
Name: ValidRatings - only these ratings are valid! 
---------------------------------------------------------*/ 
local ValidRatings = { "friendly", "smile", "love", "artistic", "star", "builder" } 

local function GetRatingID( name )
	for k, v in pairs( ValidRatings ) do 
		if ( name == v ) then return k end 
	end 
	 
	return false
end 


/*--------------------------------------------------------- 
Name: Update the player's networkvars based on the DB 
---------------------------------------------------------*/ 
local function UpdatePlayerRatings( ply ) 

	local result = sql.Query( "SELECT rating, count(*) as cnt FROM ratings WHERE target = "..ply:UniqueID().." GROUP BY rating " ) 
	 
	if ( !result ) then return end 
	 
	for id, row in pairs( result ) do 
	 
		ply:SetNetworkedInt( "Rating."..ValidRatings[ tonumber( row['rating'] ) ], tonumber( row['cnt'] ) ) 
	 
	end 

end 
	 
/*--------------------------------------------------------- 
Name: CCRateUser 
---------------------------------------------------------*/ 
local function CCRateUser( player, command, arguments ) 
	local Rater 	= player 
	local Target 	= Entity( tonumber( arguments[1] ) ) 
	local Rating	= arguments[2]
	local _Notify 	= ( Rating == "builder" and "tool" ) or Rating;
	 
	-- Don't rate non players 
	if ( !Target:IsPlayer() ) then return end 
	 
	-- Don't rate self 
	if ( Rater == Target ) then return end 
	 
	local RatingID = GetRatingID( Rating ) 
	local RaterID = Rater:UniqueID() 
	local TargetID = Target:UniqueID() 
	 
	-- Rating isn't valid 
	if (!RatingID) then return end 
	 
	-- Prevent rating spam
	if not ( RatingUseTable[Rater:SteamID( )] ) then RatingUseTable[Rater:SteamID( )] = { } end
	if ( RatingUseTable[Rater:SteamID( )][Target:SteamID( )] ) then
		DarkRP.notify( Rater, 1, 4, "You are temporarily no longer able to rate " .. Target:Nick( ) .. "!" )
		return
	end
	-- When was the last time this player rated this player 
	-- Only let them rate each other evre 60 seconds 
	Target.RatingTimers = Target.RatingTimers or {} 
	if ( Target.RatingTimers[ RaterID ] && Target.RatingTimers[ RaterID ] > CurTime() - 60 ) then 
	 
		DarkRP.notify(Rater, 1, 4, "Please wait before rating ".. Target:Nick() .." again.\n" ); 
		return 
	end 
	
	RatingUseTable[Rater:SteamID( )][Target:SteamID( )] = true
	Target.RatingTimers[ RaterID ] = CurTime() 

	DarkRP.notify(Target, 1, 4, Rater:Nick().. " has given you a ".._Notify ); 
		 
	-- Let the rater know that their vote was counted 
	DarkRP.notify(Rater, 2, 4,  "You have rated ".. Target:Nick() .." a ".._Notify.."!\n" ); 
	 
	sql.Query( "INSERT INTO ratings ( target, rater, rating ) VALUES ( "..TargetID..", "..RaterID..", "..RatingID.." )" ) 

	-- We changed something so update the networked vars 
	UpdatePlayerRatings( Target ) 
	 
end 

concommand.Add( "rp_userrate", CCRateUser ) 


/*--------------------------------------------------------- 
When the player joins the server we  
need to restore the NetworkedInt's 
---------------------------------------------------------*/ 
local function PlayerRatingsRestore( ply ) 

	UpdatePlayerRatings( ply ) 

end 
hook.Add( "PlayerInitialSpawn", "PlayerRatingsRestore", PlayerRatingsRestore )

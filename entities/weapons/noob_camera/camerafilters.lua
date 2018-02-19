camFilterScreenSpaceEffects = { }
camFilterScreenSpaceEffects["Cartoon"] = function( )
	local modTbl = {
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = -0.04,
		["$pp_colour_contrast"] = 1.35,
		["$pp_colour_colour"] = 5,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	}
	DrawColorModify( modTbl )
	DrawSobel( 0.5 )
end

camFilterScreenSpaceEffects["BlackAndWhite"] = function( )
	local modTbl =	{
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = 0,
		["$pp_colour_contrast"] = 0.35,
		["$pp_colour_colour"] = 0,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	}
	DrawColorModify( modTbl )
	DrawToyTown( 4,	ScrH( ) )
end

camFilterScreenSpaceEffects["Bloom"] = function( )
	DrawBloom( 0.65, 2, 9, 9, 1, 1, 1, 1, 1 )
end

camFilterScreenSpaceEffects["Patternize"] = function( )
	DrawTexturize( 1, Material( "pp/texturize/pattern1.png" ) )
end

camFilterScreenSpaceEffects["Rainbowize"] = function( )
	DrawTexturize( 1, Material( "pp/texturize/rainbow.png" ) )
end

camFilterScreenSpaceEffects["Yellowize"] = function( )
	DrawTexturize( 0, Material( "pp/texturize/squaredo.png" ) )
end

camFilterScreenSpaceEffects["None"] = function( )
end
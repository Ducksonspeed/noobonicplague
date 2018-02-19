surface.CreateFont( "momsspaghettiisready", { font = "Tahoma", size = 36, weight = 500, antialiasing = true } );
surface.CreateFont( "momsspaghettiisready_blur", { font = "Tahoma", size = 36, weight = 500, antialiasing = true, blursize = 3 } );

local hp = {};

net.Receive( "entity_health_text", function()
	hp = {};
	hp.text = net.ReadString()
	hp.delay = CurTime() + 1;
end );

hook.Add( "HUDPaint", "entity_health_text", function()
	if ( hp.text == nil ) then return; end

	for i = 1, 5 do
		draw.DrawText( "Health: "..hp.text, "momsspaghettiisready_blur", ScrW() / 2.2, ScrH() / 4, Color( 151, 51, 51 ) );
	end

	draw.DrawText( "Health: "..hp.text, "momsspaghettiisready", ScrW() / 2.2, ScrH() / 4, Color( 255, 91, 91 ) );

	if ( hp.delay < CurTime() ) then hp = {}; end
end );

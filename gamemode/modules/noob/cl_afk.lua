local Timer_Simple = timer.Simple;
local System_HasFocus = system.HasFocus;

local Net = { Start = net.Start, WriteBit = net.WriteBit, SendToServer = net.SendToServer };

local function CryAboutIt( delay )
	Timer_Simple( delay, function()
		Net.Start( "AFKCheckFocus" );
			Net.WriteBit( System_HasFocus() );
		Net.SendToServer();

		CryAboutIt( math.random( 3, 6 ) );
	end );
end

// CryAboutIt();


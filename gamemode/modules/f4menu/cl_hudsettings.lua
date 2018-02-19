local PANEL = {};

local DefaultVars = {
	Job1 = Color( 255, 255, 255, 255 ),
	Job2 = Color( 96, 154, 219, 255 ),
	salary1 = Color( 255, 255, 255, 170 ),
	salary2 = Color( 0, 168, 30, 255 ),
	Healthbackground = Color( 0, 0, 0, 255 ),
	Healthforeground = Color( 111, 37, 37, 255 ),
	HealthText = Color( 255, 255, 255, 255 ),
	background = Color( 37, 36, 36, 244 )
}
local SettingsCVar =
{
	background = { val = 4 },
	Healthbackground = { val = 4 },
	Healthforeground = { val = 4 },
	HealthText = { val = 4 },
	Job1 = { val = 4, text = "(shadow)" },
	Job2 = { val = 4 },
	salary1 = { val = 4, text = "(shadow)" },
	salary2 = { val = 4 },
	/*
	HungerBackground = { val = 4 },
	HungerForeground = { val = 4 },
	StarvingText = { val = 4 },
	FoodEatenBackground = { val = 3 },
	FoodEatenForeground = { val = 3 }
	*/
};

function PANEL:ConstructPanel( Type )
	local Title = vgui.Create( "DLabel", self );
	Title:SetPos( 5, 5 );
	Title:SetFont( "Roboto Light" );
	Title:SetText( Format( "%s %s", Type, SettingsCVar[ Type ].text or "" ) );
	Title:SetSize( 200, 20 );

	local ColorPalette = vgui.Create( "DColorMixer", self );
	ColorPalette:SetPos( 40, 40 );
	ColorPalette:SetSize( 300, 200 );

	ColorPalette.ValueChanged = function( self, _Color )
		for i = 1, SettingsCVar[ Type ].val do
			local hm = { [ 1 ] = _Color.r, [ 2 ] = _Color.g, [ 3 ] = _Color.b, [ 4 ] = _Color.a };
			local Check = tostring( Type..i );
			if ( GetConVar( Check ) != hm[ i ] ) then
				RunConsoleCommand( Check, tostring( hm[ i ] ) );
			end
		end
	end

	local defaultButton = vgui.Create( "DButton", self )
	defaultButton:SetSize( self:GetWide( ) * 0.3, self:GetTall( ) * 0.1 )
	--defaultButton:AlignLeft( self:GetWide( ) * 0.1 )
	defaultButton:Center( )
	defaultButton:AlignBottom( self:GetTall( ) * 0.2 )
	defaultButton:SetText( "Default" )
	defaultButton:SetFont( "Roboto Light" )
	defaultButton.OnMousePressed = function( pnl, btn )
		for i = 1, SettingsCVar[ Type ].val do
			local hm = { [1] = DefaultVars[ Type ].r, [2] = DefaultVars[ Type ].g, [3] = DefaultVars[ Type ].b, [4] = DefaultVars[ Type ].a }
			local Check = tostring( Type .. i )
			if ( GetConVar( Check ) != hm[i] ) then
				RunConsoleCommand( Check, tostring( hm[i] ) )
			end 
		end
	end
	/*local Later = vgui.Create( "DLabel", self );
	Later:SetPos( 40, 300 );
	Later:SetText( "Will add other stuff later.." );
	Later:SizeToContents();*/
end

function PANEL:Init()
	// self.BaseClass.Init( self );
end

vgui.Register( "F4MenuHUDSetting", PANEL, "DPanel" );


PANEL = {};

function PANEL:Init()
	local Scroller = vgui.Create( "DScrollPanel", self );
	Scroller:SetPos( 2, 2 );
	Scroller:SetSize( self:GetParent():GetWide() - 360, self:GetParent():GetTall() - 300 );

	local List = vgui.Create( "DIconLayout", Scroller );
	List:SetSize( Scroller:GetWide(), Scroller:GetTall() );
	List:SetPos( 5, 5 );
	List:SetSpaceX( 6 );
	List:SetSpaceY( 6 );

	for k, v in pairs( SettingsCVar ) do
		local pan = vgui.Create( "F4MenuHUDSetting" );
		List:Add( pan );
		pan:SetSize( 400, 400 );
		pan:ConstructPanel( k );
		pan.Paint = function( self, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, Color( 51, 51, 51 ) )
		end
	end
end

vgui.Register( "F4MenuHUD", PANEL, "Panel" );



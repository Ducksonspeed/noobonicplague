/*
	-> hud idea:
		- save img png to .txt file and check if they have it if they join again/rejoin
			-- or convar as string would be best ( since convars save [ have the save FLAG ] )
		- maybe have icons on the bottom for something: abilities, afk, etc?
		- positioning of elements: bars & text -> through derma panel
*/

local example_templates =
{
	"http://i.gyazo.com/17662f47f3d5e41f9c829481bc166808.png",
	"http://i.gyazo.com/52d85139ced77570035d15201dae3801.png",
	-- "http://i.gyazo.com/1c465f76c8c870a3b0c5b5b25013e249.png",
	"http://i.gyazo.com/831aae55f39e81316773ba477c499300.png",
	"http://i.gyazo.com/19c97ab2fdbf4b7aafc1e8fc5eb14ef2.png",
	"http://i.gyazo.com/6b336ed542e9571c181a43cf27fd1a09.png",
	-- "http://im.ezgif.com/tmp/gif_600x200_8f78e2.gif",
};

surface.CreateFont( "___Tahoma", { font = "Tahoma", size = 24, weight = 800, antialiasing = true } );
surface.CreateFont( "___Tahoma_Blur", { font = "Tahoma", size = 24, weight = 800, antialiasing = true, blursize = 3 } );

CreateClientConVar( "imghud_healthcol_r", "255", true, true );
CreateClientConVar( "imghud_healthcol_g", "51", true, true );
CreateClientConVar( "imghud_healthcol_b", "51", true, true );
CreateClientConVar( "imghud_healthcol_a", "100", true, true );

CreateClientConVar( "imghud_armorcol_r", "121", true, true );
CreateClientConVar( "imghud_armorcol_g", "121", true, true );
CreateClientConVar( "imghud_armorcol_b", "255", true, true );
CreateClientConVar( "imghud_armorcol_a", "100", true, true );

CreateClientConVar( "imghud_moncol_r", "51", true, true );
CreateClientConVar( "imghud_moncol_g", "131", true, true );
CreateClientConVar( "imghud_moncol_b", "51", true, true );
CreateClientConVar( "imghud_moncol_a", "255", true, true );

if ( _IMGHUD and ValidPanel( _IMGHUD.Panel ) ) then
	_IMGHUD.Panel:Remove();
end

_IMGHUD = {};

/*
_IMGHUD.TextConvar 			= CreateClientConVar( "imghud_text", "0", true, true );
_IMGHUD.HealthBarConvar 	= CreateClientConVar( "imghud_healthbar", "0", true, true );
_IMGHUD.ArmorBarConvar 		= CreateClientConVar( "imghud_armorbar", "0", true, true );
*/

local function CreateHud()
	_IMGHUD.Panel = vgui.Create( "DHTML" );
	_IMGHUD.Panel:SetSize( 600, 200 );
	_IMGHUD.Panel:SetPos( ScreenScale( 30 ), ScrH() / 1.4 );

	_IMGHUD.Panel:OpenURL( example_templates[ 5 ] );

	_IMGHUD.panel_elements_tab = 
	{
		[ "text" ] =
		{
			salarytext	= { text = "Salary", x = 10, y = 20, color = Color( 51, 200, 51 ), prevcolor = nil },
			moneytext 	= { text = "Money", x = 10, y = 60, color = Color( 51, 200, 51 ), prevcolor = nil },
		},
		[ "bars" ] =
		{
			healthbar 	= { text = "Health", x = 10, y = 100 },
			armorbar 	= { text = "Armor", x = 10, y = 140 },
		}
	};

	_IMGHUD.panel_elements = {};

	local gn = GetConVarNumber;
	local mncol = "imghud_moncol_";

	for a, b in pairs( _IMGHUD.panel_elements_tab ) do
		if ( a == "text" ) then
			_IMGHUD.panel_elements.text_panel = vgui.Create( "DPanel", _IMGHUD.Panel );
			_IMGHUD.panel_elements.text_panel:SetPos( 0, 0 );
			_IMGHUD.panel_elements.text_panel:SetSize( _IMGHUD.Panel:GetWide(), _IMGHUD.Panel:GetTall() );
			_IMGHUD.panel_elements.text_panel.Paint = function( self, w, h )
				for k, v in pairs( b ) do
					if ( v.prevcolor and self:GetColor() != v.prevcolor ) then
						self:SetColor( Color( gn( mncol.."r" ), gn( mncol.."g" ), gn( mncol.."b" ), gn( mncol.."a" ) ) );
						v.prevcolor = v.color;
					end

					for i = 1, 7 do
						draw.DrawText( v.text..": $"..LocalPlayer():getDarkRPVar( v.text:lower() ), "___Tahoma_Blur", v.x, v.y, color_black );
					end

					draw.DrawText( v.text..": $"..LocalPlayer():getDarkRPVar( v.text:lower() ), "___Tahoma", v.x, v.y, Color( gn( mncol.."r" ), gn( mncol.."g" ), gn( mncol.."b" ), gn( mncol.."a" ) ) );
				end
			end
		elseif ( a == "bars" ) then
			for k, v in pairs( b ) do
				_IMGHUD.panel_elements[ k ] = vgui.Create( "DPanel", _IMGHUD.Panel );
				_IMGHUD.panel_elements[ k ]:SetPos( v.x, v.y );
				_IMGHUD.panel_elements[ k ]:SetSize( 580, 25 );

				_IMGHUD.panel_elements[ k ].Paint = function( self, w, h )
					local hmm = ( k == "healthbar" and LocalPlayer():Health() ) or ( k == "armorbar" and LocalPlayer():Armor() );
					local hparm = math.Clamp( hmm * 6, 1, self:GetWide() );
					local which = ( k == "healthbar" and "imghud_healthcol_" ) or ( k == "armorbar" and "imghud_armorcol_" );

					draw.RoundedBox( 4, 0, 0, self:GetWide(), h, Color( gn( which.."r" ) - 91, gn( which.."g" ) - 91, gn( which.."b" ) - 91, gn( which.."a" ) ) );
					draw.RoundedBox( 4, 0, 0, hparm, h, Color( gn( which.."r" ), gn( which.."g" ), gn( which.."b" ), gn( which.."a" ) ) );
					
					for i = 1, 7 do
						draw.DrawText( hmm, "___Tahoma_Blur", 275, 0, color_black );
					end

					draw.DrawText( hmm, "___Tahoma", 275, 0, Color( 200, 200, 200 ) );
				end
			end
		end
	end
end

hook.Add( "InitPostEntity", "DrawTheDamnHud", function()
	timer.Simple( 2, function()
		CreateHud();
	end );
end );

concommand.Add( "imghud_seturl", function( pl, cmd, args )
	if ( example_templates[ tonumber( args[ 1 ] ) ] == nil ) then return; end
	_IMGHUD.Panel:OpenURL( example_templates[ tonumber( args[ 1 ] ) ] );
end );

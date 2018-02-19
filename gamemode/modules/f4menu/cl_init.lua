local f4Frame

/*---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------*/
function DarkRP.openF4Menu()
	if f4Frame then
		f4Frame:Show()
		f4Frame:InvalidateLayout()
	else
		f4Frame = vgui.Create("F4MenuFrame")
		f4Frame:generateTabs()
	end
end

function DarkRP.closeF4Menu()
	if f4Frame then
		f4Frame:Remove( )
	end
end

function DarkRP.toggleF4Menu()
	if not ValidPanel(f4Frame) or not f4Frame:IsVisible() then
		--DarkRP.openF4Menu()
		f4Frame = vgui.Create("F4MenuFrame")
		f4Frame:generateTabs()
	else
		f4Frame:Remove( )
		--DarkRP.closeF4Menu()
	end
end

GM.ShowSpare2 = DarkRP.toggleF4Menu

function DarkRP.getF4MenuPanel()
	return f4Frame
end

function DarkRP.addF4MenuTab(name, panel)
	if not f4Frame then error("DarkRP.addF4MenuTab called at the wrong time. Please call in the F4MenuTabs hook.") end

	return f4Frame:createTab(name, panel)
end

function DarkRP.removeF4MenuTab(name)
	if not f4Frame then error("DarkRP.addF4MenuTab called at the wrong time. Please call in the F4MenuTabs hook.") end

	f4Frame:removeTab(name)
end

function DarkRP.switchTabOrder(tab1, tab2)
	if not f4Frame then error("DarkRP.addF4MenuTab called at the wrong time. Please call in the F4MenuTabs hook.") end

	f4Frame:switchTabOrder(tab1, tab2)
end


/*---------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------*/
function DarkRP.hooks.F4MenuTabs()
	DarkRP.addF4MenuTab(DarkRP.getPhrase("jobs"), vgui.Create("F4MenuJobs"))
	DarkRP.addF4MenuTab(DarkRP.getPhrase("F4entities"), vgui.Create("F4MenuEntities"))

	/*local shipments = fn.Filter(fn.Compose{fn.Not, fn.Curry(fn.GetValue, 2)("noship")}, CustomShipments)
	if #shipments > 0 then
		DarkRP.addF4MenuTab(DarkRP.getPhrase("shipments"), vgui.Create("F4MenuShipments"))
	end*/

	/*local guns = fn.Filter(fn.Curry(fn.GetValue, 2)("seperate"), CustomShipments)
	if #guns > 0 then
		DarkRP.addF4MenuTab(DarkRP.getPhrase("F4guns"), vgui.Create("F4MenuGuns"))
	end*/

	if #GAMEMODE.AmmoTypes > 0 then
		DarkRP.addF4MenuTab(DarkRP.getPhrase("F4ammo"), vgui.Create("F4MenuAmmo"))
	end

	/*if #CustomVehicles > 0 then
		DarkRP.addF4MenuTab(DarkRP.getPhrase("F4vehicles"), vgui.Create("F4MenuVehicles"))
	end*/

	// DarkRP.addF4MenuTab( "HUD", vgui.Create( "F4MenuHUD" ) );
end

hook.Add("DarkRPVarChanged", "RefreshF4Menu", function(ply, varname)
	if ply ~= LocalPlayer() or varname ~= "money" or not ValidPanel(f4Frame) or not f4Frame:IsVisible() then return end

	f4Frame:InvalidateLayout()
end)

/*---------------------------------------------------------------------------
Fonts
---------------------------------------------------------------------------*/
surface.CreateFont("Roboto Light", { -- font is not found otherwise
		size = 19,
		weight = 300,
		antialias = true,
		shadow = false,
		font = "Roboto Light"})

surface.CreateFont("F4MenuFont01", {
		size = 23,
		weight = 400,
		antialias = true,
		shadow = false,
		font = "Roboto Light"})

surface.CreateFont("F4MenuFont02", {
		size = 30,
		weight = 800,
		antialias = true,
		shadow = false,
		font = "Roboto Light"})

hook.Add("F4MenuTabs", "N00BRP_F4MenuTabs_CustomSetup", function( )
	if ( LocalPlayer( ):Team( ) == TEAM_COOK ) then
		cookTab = DarkRP.addF4MenuTab(DarkRP.getPhrase("food"), vgui.Create("F4MenuFood"))
	end
	if ( LocalPlayer( ):Team( ) == TEAM_CARDEALER ) then
		DarkRP.addF4MenuTab(DarkRP.getPhrase("F4vehicles"), vgui.Create("F4MenuVehicles"))
	end
	if ( LocalPlayer( ):Team( ) == TEAM_BMARKET or LocalPlayer( ):Team( ) == TEAM_GUN or LocalPlayer( ):Team( ) == TEAM_HACKER ) then
		DarkRP.addF4MenuTab(DarkRP.getPhrase("shipments"), vgui.Create("F4MenuShipments"))
	end
end )

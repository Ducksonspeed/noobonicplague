/*---------------------------------------------------------------------------
HUD ConVars
---------------------------------------------------------------------------*/
local ConVars = {}
local HUDWidth
local HUDHeight

local Color = Color
local CurTime = CurTime
local cvars = cvars
local DarkRP = DarkRP
local draw = draw
local GetConVar = GetConVar
local hook = hook
local IsValid = IsValid
local Lerp = Lerp
local localplayer
local math = math
local pairs = pairs
local ScrW, ScrH = ScrW, ScrH
local SortedPairs = SortedPairs
local string = string
local surface = surface
local table = table
local timer = timer
local tostring = tostring
local plyMeta = FindMetaTable("Player")

local colors = {}
colors.black = Color(0, 0, 0, 255)
colors.blue = Color(0, 0, 255, 255)
colors.brightred = Color(200, 30, 30, 255)
colors.darkred = Color(0, 0, 70, 100)
colors.darkblack = Color(0, 0, 0, 200)
colors.gray1 = Color(0, 0, 0, 155)
colors.gray2 = Color(51, 58, 51,100)
colors.red = Color(255, 0, 0, 255)
colors.white = Color(255, 255, 255, 255)
colors.white1 = Color(255, 255, 255, 200)

PHOTON_HUD_Y = ScrH() - 268

local function ReloadConVars()
	ConVars = {
		background = {0,0,0,100},
		Healthbackground = {0,0,0,200},
		Healthforeground = {140,0,0,180},
		HealthText = {255,255,255,200},
		Job1 = {0,0,150,200},
		Job2 = {0,0,0,255},
		salary1 = {0,150,0,200},
		salary2 = {0,0,0,255}
	}

	for name, Colour in pairs(ConVars) do
		ConVars[name] = {}
		for num, rgb in SortedPairs(Colour) do
			local CVar = GetConVar(name..num) or CreateClientConVar(name..num, rgb, true, false)
			table.insert(ConVars[name], CVar:GetInt())

			if not cvars.GetConVarCallbacks(name..num, false) then
				cvars.AddChangeCallback(name..num, function() timer.Simple(0,ReloadConVars) end)
			end
		end
		ConVars[name] = Color(unpack(ConVars[name]))
	end


	HUDWidth = (GetConVar("HudW") or  CreateClientConVar("HudW", 240, true, false)):GetInt()
	HUDHeight = (GetConVar("HudH") or CreateClientConVar("HudH", 115, true, false)):GetInt()

	if not cvars.GetConVarCallbacks("HudW", false) and not cvars.GetConVarCallbacks("HudH", false) then
		cvars.AddChangeCallback("HudW", function() timer.Simple(0,ReloadConVars) end)
		cvars.AddChangeCallback("HudH", function() timer.Simple(0,ReloadConVars) end)
	end
end
ReloadConVars()

local Scrw, Scrh, RelativeX, RelativeY
/*---------------------------------------------------------------------------
HUD Seperate Elements
---------------------------------------------------------------------------*/
local Health = 0
local function DrawHealth()
	local myHealth = localplayer:Health()
	if ( LocalPlayer( ):IsGhost( ) ) then
		myHealth = 0
	end
	Health = math.min(100, (Health == myHealth and Health) or Lerp(0.1, Health, myHealth))

	local DrawHealth = math.Min(Health / GAMEMODE.Config.startinghealth, 1)
	local rounded = math.Round(3*DrawHealth)
	local Border = math.Min(6, rounded * rounded)
	-- draw.RoundedBox(Border, RelativeX + 4, RelativeY - 30, HUDWidth - 8, 20, ConVars.Healthbackground)
	-- draw.RoundedBox(Border, RelativeX + 5, RelativeY - 29, (HUDWidth - 9) * DrawHealth, 18, ConVars.Healthforeground)

	draw.DrawNonParsedText(math.Max(0, math.Round(myHealth)), "DarkRPHUD2", RelativeX + 4 + (HUDWidth - 8)/2, RelativeY - 32, ConVars.HealthText, 1)

	-- Armor
	local armor = localplayer:Armor()
	if ( LocalPlayer( ):IsGhost( ) ) then
		armor = 0
	end
	if armor ~= 0 then
		draw.RoundedBox(2, RelativeX + 4, RelativeY - 15, (HUDWidth - 8) * armor / 100, 5, colors.blue)
	end
end

local salaryText, JobWalletText
local function DrawInfo()
	if ( !RPExtraTeams or !RPExtraTeams[LocalPlayer( ):Team( )] or !RPExtraTeams[LocalPlayer( ):Team( )].salary ) then return end
	salaryText = salaryText or DarkRP.getPhrase("salary", DarkRP.formatMoney(RPExtraTeams[LocalPlayer( ):Team( )].salary), "")

	JobWalletText = JobWalletText or string.format("%s\n%s",
		DarkRP.getPhrase("job", localplayer:getDarkRPVar("job") or ""),
		DarkRP.getPhrase("wallet", DarkRP.formatMoney(localplayer:getDarkRPVar("money")), "")
	)

	draw.DrawNonParsedText(salaryText, "DarkRPHUD2", RelativeX + 5, RelativeY - HUDHeight + 6, ConVars.salary1, 0)
	draw.DrawNonParsedText(salaryText, "DarkRPHUD2", RelativeX + 4, RelativeY - HUDHeight + 5, ConVars.salary2, 0)

	surface.SetFont("DarkRPHUD2")
	local w, h = surface.GetTextSize(salaryText)

	draw.DrawNonParsedText(JobWalletText, "DarkRPHUD2", RelativeX + 5, RelativeY - HUDHeight + h + 6, ConVars.Job1, 0)
	draw.DrawNonParsedText(JobWalletText, "DarkRPHUD2", RelativeX + 4, RelativeY - HUDHeight + h + 5, ConVars.Job2, 0)
end

local Page = Material("icon16/page_white_text.png")
local function GunLicense()
	if localplayer:getDarkRPVar("HasGunlicense") then
		surface.SetMaterial(Page)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(RelativeX + HUDWidth, Scrh - 34, 32, 32)
	end
end

local agendaText
local function Agenda()
	local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_Agenda")
	if shouldDraw == false then return end

	local agenda = localplayer:getAgendaTable()
	if not agenda then return end
	agendaText = agendaText or DarkRP.textWrap((localplayer:getDarkRPVar("agenda") or ""):gsub("//", "\n"):gsub("\\n", "\n"), "DarkRPHUD1", 440)

	draw.RoundedBox(10, 10, 10, 460, 110, colors.gray1)
	draw.RoundedBox(10, 12, 12, 456, 106, colors.gray2)
	draw.RoundedBox(10, 12, 12, 456, 20, colors.darkred)

	draw.DrawNonParsedText(agenda.Title, "DarkRPHUD1", 30, 12, colors.red, 0)
	draw.DrawNonParsedText(agendaText, "DarkRPHUD1", 30, 35, colors.white, 0)
end

hook.Add("DarkRPVarChanged", "agendaHUD", function(ply, var, _, new)
	if ply ~= localplayer then return end
	if var == "agenda" and new then
		agendaText = DarkRP.textWrap(new:gsub("//", "\n"):gsub("\\n", "\n"), "DarkRPHUD1", 440)
	else
		agendaText = nil
	end

	if var == "salary" then
		salaryText = DarkRP.getPhrase("salary", DarkRP.formatMoney(new), "")
	end

	if var == "job" or var == "money" then
		JobWalletText = string.format("%s\n%s",
			DarkRP.getPhrase("job", var == "job" and new or localplayer:getDarkRPVar("job") or ""),
			DarkRP.getPhrase("wallet", var == "money" and DarkRP.formatMoney(new) or DarkRP.formatMoney(localplayer:getDarkRPVar("money")), "")
		)
	end
end)

local VoiceChatTexture = surface.GetTextureID("voice/icntlk_pl")
local function DrawVoiceChat()
	if localplayer.DRPIsTalking then
		local chbxX, chboxY = chat.GetChatBoxPos()

		local Rotating = math.sin(CurTime()*3)
		local backwards = 0
		if Rotating < 0 then
			Rotating = 1-(1+Rotating)
			backwards = 180
		end
		surface.SetTexture(VoiceChatTexture)
		surface.SetDrawColor(ConVars.Healthforeground)
		surface.DrawTexturedRectRotated(Scrw - 100, chboxY, Rotating*96, 96, backwards)
	end
end

local function LockDown()
	local chbxX, chboxY = chat.GetChatBoxPos()
	if ( SHNOOB_VARS:Get( "IsLockdown" ) == true ) then
		local cin = (math.sin(CurTime()) + 1) / 2
		local chatBoxSize = math.floor(Scrh / 4)
		draw.DrawNonParsedText(DarkRP.getPhrase("lockdown_started"), "ScoreboardSubtitle", chbxX, chboxY + chatBoxSize, Color(cin * 255, 0, 255 - (cin * 255), 255), TEXT_ALIGN_LEFT)
	end
end

local Arrested = function() end

usermessage.Hook("GotArrested", function(msg)
	local StartArrested = CurTime()
	local ArrestedUntil = msg:ReadFloat()

	Arrested = function()
		if CurTime() - StartArrested <= ArrestedUntil and localplayer:getDarkRPVar("Arrested") then
		draw.DrawNonParsedText(DarkRP.getPhrase("youre_arrested", math.ceil(ArrestedUntil - (CurTime() - StartArrested))), "DarkRPHUD1", ScrW()/2, ScrH() - ScrH()/12, colors.white, 1)
		elseif not localplayer:getDarkRPVar("Arrested") then
			Arrested = function() end
		end
	end
end)

local AdminTell = function() end

usermessage.Hook("AdminTell", function(msg)
	timer.Destroy("DarkRP_AdminTell")
	local Message = msg:ReadString()

	AdminTell = function()
		draw.RoundedBox(4, 10, 10, ScrW() - 20, 110, colors.darkblack)
		draw.DrawNonParsedText(DarkRP.getPhrase("listen_up"), "GModToolName", ScrW() / 2 + 10, 10, colors.white, 1)
		draw.DrawNonParsedText(Message, "ChatFont", ScrW() / 2 + 10, 90, colors.brightred, 1)
	end

	timer.Create("DarkRP_AdminTell", 10, 1, function()
		AdminTell = function() end
	end)
end)

/*---------------------------------------------------------------------------
Drawing the HUD elements such as Health etc.
---------------------------------------------------------------------------*/
local function DrawHUD()
	localplayer = localplayer and IsValid(localplayer) and localplayer or LocalPlayer()
	if not IsValid(localplayer) then return end

	local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_HUD")
	if shouldDraw == false then return end

	Scrw, Scrh = ScrW(), ScrH()
	RelativeX, RelativeY = 0, Scrh

	shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_LocalPlayerHUD")
	shouldDraw = shouldDraw ~= false and (GAMEMODE.BaseClass.HUDShouldDraw(GAMEMODE, "DarkRP_LocalPlayerHUD") ~= false)
	if shouldDraw then
		/*
			Background
			IF YOU FUCKING ENABLE ANY OF THESE YOU WILL GET FUCKING REVOKED FOR LIFE
			draw.RoundedBox(6, 0, Scrh - HUDHeight, HUDWidth, HUDHeight, ConVars.background)
			DrawHealth()
			DrawInfo()
			GunLicense()
			NOOBONIC PLAGUE HUD MADE BY PROFESSIONALS YOU FUCKS
			Listen you dumb fucker, use forward slashes for comments. Thanks.
		*/
		npGUI:PlayerHUD()
		DrawParamedicOverlay()
	end
	Agenda()
	DrawVoiceChat()
	LockDown()

	Arrested()
	AdminTell()
end

/*---------------------------------------------------------------------------
Entity HUDPaint things
---------------------------------------------------------------------------*/
-- Draw a player's name, health and/or job above the head
-- This syntax allows for easy overriding
plyMeta.drawPlayerInfo = plyMeta.drawPlayerInfo or function(self)
	if true then return end
	local pos = self:EyePos()

	pos.z = pos.z + 10 -- The position we want is a bit above the position of the eyes
	pos = pos:ToScreen()
	if not self:getDarkRPVar("wanted") then
		-- Move the text up a few pixels to compensate for the height of the text
		pos.y = pos.y - 50
	end

	if GAMEMODE.Config.showname then
		local nick, plyTeam = self:Nick(), self:Team()
		draw.DrawNonParsedText(nick, "DarkRPHUD2", pos.x + 1, pos.y + 1, colors.black, 1)
		draw.DrawNonParsedText(nick, "DarkRPHUD2", pos.x, pos.y, RPExtraTeams[plyTeam] and RPExtraTeams[plyTeam].color or team.GetColor(plyTeam) , 1)
	end

	if GAMEMODE.Config.showhealth then
		local health = DarkRP.getPhrase("health", self:Health())
		draw.DrawNonParsedText(health, "DarkRPHUD2", pos.x + 1, pos.y + 21, colors.black, 1)
		draw.DrawNonParsedText(health, "DarkRPHUD2", pos.x, pos.y + 20, colors.white1, 1)
	end

	if GAMEMODE.Config.showjob then
		local teamname = self:getDarkRPVar("job") or team.GetName(self:Team())
		draw.DrawNonParsedText(teamname, "DarkRPHUD2", pos.x + 1, pos.y + 41, colors.black, 1)
		draw.DrawNonParsedText(teamname, "DarkRPHUD2", pos.x, pos.y + 40, colors.white1, 1)
	end

	if self:getDarkRPVar("HasGunlicense") then
		surface.SetMaterial(Page)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(pos.x-16, pos.y + 60, 32, 32)
	end
end

-- Draw wanted information above a player's head
-- This syntax allows for easy overriding
plyMeta.drawWantedInfo = plyMeta.drawWantedInfo or function(self)
	if not self:Alive() then return end

	if ( self:GetObserverMode() != OBS_MODE_NONE ) then return; end

	local pos = self:EyePos()
	if not pos:isInSight({localplayer, self}) then return end

	pos.z = pos.z + 10
	pos = pos:ToScreen()

	if GAMEMODE.Config.showname then
		draw.DrawNonParsedText(self:Nick(), "DarkRPHUD2", pos.x + 1, pos.y + 1, colors.black, 1)
		draw.DrawNonParsedText(self:Nick(), "DarkRPHUD2", pos.x, pos.y, team.GetColor(self:Team()), 1)
	end

	local wantedText = "Wanted by Police!" -- DarkRP.getPhrase("wanted", tostring(self:getDarkRPVar("wantedReason")))

	draw.DrawNonParsedText(wantedText, "DarkRPHUD2", pos.x, pos.y - 20, colors.white1, 1)
	draw.DrawNonParsedText(wantedText, "DarkRPHUD2", pos.x + 1, pos.y - 21, colors.red, 1)
end

/*---------------------------------------------------------------------------
The Entity display: draw HUD information about entities
---------------------------------------------------------------------------*/
local function DrawEntityDisplay()
	local shouldDraw, players = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_EntityDisplay")
	if shouldDraw == false then return end

	local shootPos = localplayer:GetShootPos()
	local aimVec = localplayer:GetAimVector()

	local tr = LocalPlayer():GetEyeTrace()

	for k, ply in pairs(players or player.GetAll()) do

		local hisPos = ply:GetShootPos()
		if not ply:Alive() then continue end

		local active = false
		if tr.Entity and IsValid(tr.Entity) and ply == tr.Entity then active = true end

		-- if GAMEMODE.Config.globalshow then
		-- 	--ply:drawPlayerInfo()
		-- -- Draw when you're (almost) looking at him
		-- elseif hisPos:DistToSqr(shootPos) < 160000 then
		-- 	local pos = hisPos - shootPos
		-- 	local unitPos = pos:GetNormalized()
		-- 	if unitPos:Dot(aimVec) > 0.95 then
		-- 		local trace = util.QuickTrace(shootPos, pos, localplayer)
		-- 		if trace.Hit and trace.Entity ~= ply then return end
		-- 		if trace.Hit and trace.Entity == ply then active = true end
		-- 	end
		-- end

		npGUI:DrawPlayerInfo( ply, active )

	end

	local tr = localplayer:GetEyeTrace()

	if IsValid(tr.Entity) and tr.Entity:isKeysOwnable() and tr.Entity:GetPos():Distance(localplayer:GetPos()) < 200 then
		tr.Entity:drawOwnableInfo()
	end
end

/*---------------------------------------------------------------------------
Drawing death notices
---------------------------------------------------------------------------*/
function GM:DrawDeathNotice(x, y)
	if not GAMEMODE.Config.showdeaths then return end
	self.BaseClass:DrawDeathNotice(x, y)
end

/*---------------------------------------------------------------------------
Display notifications
---------------------------------------------------------------------------*/
local function DisplayNotify(msg)
	local txt = msg:ReadString()
	GAMEMODE:AddNotify(txt, msg:ReadShort(), msg:ReadLong())
	--surface.PlaySound("buttons/lightswitch2.wav")
	surface.PlaySound( "ambient/water/drip"..math.random(1, 4)..".wav" )
	-- Log to client console
	print(txt)
end
usermessage.Hook("_Notify", DisplayNotify)

/*---------------------------------------------------------------------------
Remove some elements from the HUD in favour of the DarkRP HUD
---------------------------------------------------------------------------*/
function GM:HUDShouldDraw(name)
	if name == "CHudHealth" or
		name == "CHudBattery" or
		name == "CHudSuitPower" or
		(HelpToggled and name == "CHudChat") then
			return false
	else
		return true
	end
end

/*---------------------------------------------------------------------------
Disable players' names popping up when looking at them
---------------------------------------------------------------------------*/
function GM:HUDDrawTargetID()
    return false
end

/*---------------------------------------------------------------------------
Actual HUDPaint hook
---------------------------------------------------------------------------*/
function GM:HUDPaint()
	DrawHUD()
	DrawEntityDisplay()

	self.BaseClass:HUDPaint()
end

-- DARKRP FUCKING :SetUnDuckSpeed()

surface.CreateFont( "NPGUI_LABEL_PRIMARY", {
	font = "Segoe UI Bold",
	size = 11,
	weight = 900,
} )

surface.CreateFont( "NPGUI_LABEL_PRIMARY_S", {
	font = "Segoe UI Bold",
	size = 11,
	weight = 900,
	blursize = 4
} )

surface.CreateFont( "NPGUI_HEALTH", {
	font = "Segoe UI Bold",
	size = 32,
	weight = 900,
} )

surface.CreateFont( "NPGUI_HEALTH_S", {
	font = "Segoe UI Bold",
	size = 32,
	weight = 900,
	blursize = 4
} )

surface.CreateFont( "NPGUI_STAT_SECONDARY", {
	font = "Segoe UI Bold",
	size = 24,
	weight = 900,
} )

surface.CreateFont( "NPGUI_STAT_SECONDARY_S", {
	font = "Segoe UI Bold",
	size = 24,
	weight = 900,
	blursize = 4
} )

surface.CreateFont( "NPGUI_DATA_JOB", {
	font = "Segoe UI Light",
	size = 24,
	weight = 100,
} )

surface.CreateFont( "NPGUI_DATA_JOB_S", {
	font = "Segoe UI Light",
	size = 24,
	weight = 100,
	blursize = 4
} )

surface.CreateFont( "NPGUI_SPDLMT_LBL", {
	font = "Arial Black",
	size = 10,
	weight = 500,
	antialias = true
} )

surface.CreateFont( "NPGUI_SPDLMT", {
	font = "Segoe UI Bold",
	size = 28,
	weight = 900,
} )


npGUI = {}

local Health = 0
local salaryText
function npGUI:PlayerHUD()

	local function statusColor( num )
		return HSVToColor( num, .47, 1 )
	end

	local bX = 0
	local bY = ScrH() - 152
	local rX = bX
	local rY = bY

	-- params
	local dataHeight = 96

	local statAwidth = 80
	local statBwidth = math.floor( (256 - statAwidth) / 2 ) - 1

	-- Backgrounds

		-- Data base
		draw.RoundedBoxEx( 4, rX, rY, 256, dataHeight, Color( 24, 24, 24, 128 ), false, true, false, false )
		-- Data labels
		draw.RoundedBox( 0, rX, rY, 64, dataHeight, Color( 16, 16, 16, 64) )
		-- Status
		draw.RoundedBoxEx( 4, rX, rY + dataHeight, 256, 56, Color( 24, 24, 24, 245 ), false, false, false, false )

	-- Labels
		local yInc = 26
		rX = rX + 56
		rY = rY + 16
		-- Data labels
		draw.DrawText( "JOB", "NPGUI_LABEL_PRIMARY_S", rX, rY + 1, Color(0,0,0,255), TEXT_ALIGN_RIGHT )
		draw.DrawText( "JOB", "NPGUI_LABEL_PRIMARY", rX, rY, Color(255,255,255,255), TEXT_ALIGN_RIGHT )

		rY = rY + yInc
		draw.DrawText( "SALARY", "NPGUI_LABEL_PRIMARY_S", rX, rY + 1, Color(0,0,0,255), TEXT_ALIGN_RIGHT )
		draw.DrawText( "SALARY", "NPGUI_LABEL_PRIMARY", rX, rY, Color(255,255,255,255), TEXT_ALIGN_RIGHT )

		rY = rY + yInc
		draw.DrawText( "MONEY", "NPGUI_LABEL_PRIMARY_S", rX, rY + 1, Color(0,0,0,255), TEXT_ALIGN_RIGHT )
		draw.DrawText( "MONEY", "NPGUI_LABEL_PRIMARY", rX, rY, Color(255,255,255,255), TEXT_ALIGN_RIGHT )
		
		--status labels
		rY = bY + dataHeight + 42
		rX = statAwidth / 2
		draw.DrawText( "HEALTH", "NPGUI_LABEL_PRIMARY_S", rX, rY + 1, Color(0,0,0,255), TEXT_ALIGN_CENTER )
		draw.DrawText( "HEALTH", "NPGUI_LABEL_PRIMARY", rX, rY, Color(255,255,255,25), TEXT_ALIGN_CENTER )

		rX = statAwidth + ( statBwidth / 2 )
		draw.DrawText( "ARMOR", "NPGUI_LABEL_PRIMARY_S", rX, rY + 1, Color(0,0,0,255), TEXT_ALIGN_CENTER )
		draw.DrawText( "ARMOR", "NPGUI_LABEL_PRIMARY", rX, rY, Color(255,255,255,25), TEXT_ALIGN_CENTER )

		rX = statAwidth + statBwidth + ( statBwidth / 2 )
		draw.DrawText( "HUNGER", "NPGUI_LABEL_PRIMARY_S", rX, rY + 1, Color(0,0,0,255), TEXT_ALIGN_CENTER )
		draw.DrawText( "HUNGER", "NPGUI_LABEL_PRIMARY", rX, rY, Color(255,255,255,25), TEXT_ALIGN_CENTER )

		rY = bY + dataHeight + 8
		rX = statAwidth / 2
		local myHealth = localplayer:Health()
		if ( LocalPlayer( ):IsGhost( ) ) then
			myHealth = 0
		end
		Health = math.min(100, (Health == myHealth and Health) or Lerp(0.1, Health, myHealth))

		local DrawHealth = math.Min(Health / GAMEMODE.Config.startinghealth, 1)
		local rounded = math.Round(3*DrawHealth)
		local Border = math.Min(6, rounded * rounded)
		-- draw.RoundedBox(Border, RelativeX + 4, RelativeY - 30, HUDWidth - 8, 20, ConVars.Healthbackground)
		-- draw.RoundedBox(Border, RelativeX + 5, RelativeY - 29, (HUDWidth - 9) * DrawHealth, 18, ConVars.Healthforeground)

		--draw.DrawNonParsedText(math.Max(0, math.Round(myHealth)), "DarkRPHUD2", RelativeX + 4 + (HUDWidth - 8)/2, RelativeY - 32, ConVars.HealthText, 1)

		-- Armor
		local armor = localplayer:Armor()
		if ( LocalPlayer( ):IsGhost( ) ) then
			armor = 0
		end
		if armor ~= 0 then
			--draw.RoundedBox(2, RelativeX + 4, RelativeY - 15, (HUDWidth - 8) * armor / 100, 5, colors.blue)
		end

		draw.DrawText( math.Max(0, math.Round(myHealth)), "NPGUI_HEALTH_S", rX, rY + 1, Color(0,0,0,255), TEXT_ALIGN_CENTER )
		draw.DrawText( math.Max(0, math.Round(myHealth)), "NPGUI_HEALTH", rX, rY, Color(255,255,255,255), TEXT_ALIGN_CENTER )

		rX = statAwidth + ( statBwidth / 2 )
		rY = bY + dataHeight + 14
		draw.DrawText( armor, "NPGUI_STAT_SECONDARY_S", rX, rY + 1, Color(0,0,0,255), TEXT_ALIGN_CENTER )
		draw.DrawText( armor, "NPGUI_STAT_SECONDARY", rX, rY, Color(255,255,255,255), TEXT_ALIGN_CENTER )

		local energy = math.ceil(LocalPlayer():getDarkRPVar("Energy") or 0)
		if ( LocalPlayer( ):IsGhost( ) ) then
			energy = 0
		end

		rX = statAwidth + statBwidth + ( statBwidth / 2 )
		rY = bY + dataHeight + 14
		draw.DrawText( energy, "NPGUI_STAT_SECONDARY_S", rX, rY + 1, Color(0,0,0,255), TEXT_ALIGN_CENTER )
		draw.DrawText( energy, "NPGUI_STAT_SECONDARY", rX, rY, Color(255,255,255,255), TEXT_ALIGN_CENTER )

		-- stats bar
		rY = bY + dataHeight + 1
		rX = 0
		draw.RoundedBox( 0, rX, rY, statAwidth, 2, statusColor(myHealth))

		rY = bY + dataHeight + 1
		rX = statAwidth + 1
		draw.RoundedBox( 0, rX, rY, statBwidth, 1, statusColor(armor))

		rY = bY + dataHeight + 1
		rX = statAwidth + statBwidth + 2
		draw.RoundedBox( 0, rX, rY, statBwidth, 1, statusColor(energy))

		-- job
		rX = bX + 70
		rY = bY + 10
		local teamColor = team.GetColor(LocalPlayer():Team())
		local teamname = LocalPlayer():getDarkRPVar("job") or team.GetName(LocalPlayer():Team()) or ""
		draw.DrawText( teamname, "NPGUI_DATA_JOB_S", rX, rY, ColorAlpha(teamColor, 128), TEXT_ALIGN_LEFT )
		draw.DrawText( teamname, "NPGUI_DATA_JOB_S", rX, rY, ColorAlpha(teamColor, 128), TEXT_ALIGN_LEFT )
		draw.DrawText( teamname, "NPGUI_DATA_JOB_S", rX, rY, ColorAlpha(teamColor, 128), TEXT_ALIGN_LEFT )
		draw.DrawText( teamname, "NPGUI_DATA_JOB", rX, rY, Color(255,255,255,200), TEXT_ALIGN_LEFT )

		-- job
		rY = bY + 10 + 26
		if ( RPExtraTeams[LocalPlayer( ):Team( )] ) then
			salaryText = DarkRP.formatMoney(RPExtraTeams[LocalPlayer( ):Team( )].salary) or ""
			draw.DrawText( salaryText, "NPGUI_STAT_SECONDARY_S", rX, rY, Color(140,255,0,64), TEXT_ALIGN_LEFT )
			draw.DrawText( salaryText, "NPGUI_STAT_SECONDARY", rX, rY, Color(227,255,193,255), TEXT_ALIGN_LEFT )
		end

		rY = bY + 10 + 25 + 26
		local money = DarkRP.formatMoney(LocalPlayer():getDarkRPVar("money"))
		draw.DrawText( money, "NPGUI_DATA_JOB_S", rX, rY + 1, Color(0,0,0,255), TEXT_ALIGN_LEFT )
		draw.DrawText( money, "NPGUI_DATA_JOB", rX, rY, Color(255,255,255,255), TEXT_ALIGN_LEFT )


		if ( LocalPlayer( ):InVehicle( ) ) then
		if ( LocalPlayer( ).vehicleData ) then
			if ( LocalPlayer( ).vehicleData.veh == LocalPlayer( ):GetVehicle( ) ) then
				local car = LocalPlayer():GetVehicle()
				local speedLimit = GetGlobalInt( "N00BRP_SpeedLimit" )
				local currentGas = LocalPlayer( ).vehicleData.currentGas or 100
				local maxGas = LocalPlayer( ).vehicleData.maxGas or 100
				local gasDisplay = math.floor(( currentGas / maxGas ) * ( 100 ))
				local currentSpeed = math.floor( (LocalPlayer( ):GetVehicle( ):GetVelocity( ):Length( ) * (15/352) ) )
				local displayHealth = math.Round( (car:Health() / car:GetMaxHealth()) * 100 )


				local rX = ScrW() - ( 256 )
				local rY = bY + 8

				local bW = 40
				local bH = 56

				local function drawSpeedLimit()
					rX = ScrW() - bW - 16
					rY = rY + 16
					draw.RoundedBox( 4, rX, rY, bW, bH, Color( 255, 255, 255, 225 ) ) -- base
					rX = rX + 1
					rY = rY + 1
					bW = bW - 2
					bH = bH - 2
					draw.RoundedBox( 4, rX, rY, bW, bH, Color( 48, 48, 48, 255 ) ) -- outline
					rX = rX + 1
					rY = rY + 1
					bW = bW - 2
					bH = bH - 2
					draw.RoundedBox( 4, rX, rY, bW, bH, Color( 255, 255, 255, 225 ) ) -- inside

					draw.DrawText( "SPEED\nLIMIT", "NPGUI_SPDLMT_LBL", rX + (bW/2), rY + 4, Color(48,48,48,255), TEXT_ALIGN_CENTER ) -- label
					draw.DrawText( speedLimit, "NPGUI_SPDLMT", rX + (bW/2), rY + 22, Color(48,48,48,255), TEXT_ALIGN_CENTER ) -- speed

				end

				if speedLimit and (speedLimit > 0) then drawSpeedLimit() end

				local function carInfo()

					local bH = 56
					local bW = 256
					local rX = ScrW() - ( 256 )
					local rY = ScrH() - 56

					-- base
					draw.RoundedBoxEx( 4, rX, rY, bW, bH, Color( 24, 24, 24, 245 ), false, false, false, false )

					rY = ScrH() - 14
					rX = rX + statAwidth / 2
					draw.DrawText( "SPEED", "NPGUI_LABEL_PRIMARY_S", rX, rY + 1, Color(0,0,0,255), TEXT_ALIGN_CENTER )
					draw.DrawText( "SPEED", "NPGUI_LABEL_PRIMARY", rX, rY, Color(255,255,255,25), TEXT_ALIGN_CENTER )

					rYb = ScrH() - 56 + 8
					draw.DrawText( currentSpeed, "NPGUI_HEALTH_S", rX, rYb + 1, Color(0,0,0,255), TEXT_ALIGN_CENTER )
					draw.DrawText( currentSpeed, "NPGUI_HEALTH", rX, rYb, Color(255,255,255,255), TEXT_ALIGN_CENTER )

					rX = rX + (statAwidth / 2) + ( statBwidth / 2 )
					draw.DrawText( "FUEL", "NPGUI_LABEL_PRIMARY_S", rX, rY + 1, Color(0,0,0,255), TEXT_ALIGN_CENTER )
					draw.DrawText( "FUEL", "NPGUI_LABEL_PRIMARY", rX, rY, Color(255,255,255,25), TEXT_ALIGN_CENTER )

					rYb = rYb + 7
					draw.DrawText( gasDisplay, "NPGUI_STAT_SECONDARY_S", rX, rYb + 1, Color(0,0,0,255), TEXT_ALIGN_CENTER )
					draw.DrawText( gasDisplay, "NPGUI_STAT_SECONDARY", rX, rYb, Color(255,255,255,255), TEXT_ALIGN_CENTER )

					rX = rX + statBwidth
					draw.DrawText( "HEALTH", "NPGUI_LABEL_PRIMARY_S", rX, rY + 1, Color(0,0,0,255), TEXT_ALIGN_CENTER )
					draw.DrawText( "HEALTH", "NPGUI_LABEL_PRIMARY", rX, rY, Color(255,255,255,25), TEXT_ALIGN_CENTER )
					draw.DrawText( displayHealth, "NPGUI_STAT_SECONDARY_S", rX, rYb + 1, Color(0,0,0,255), TEXT_ALIGN_CENTER )
					draw.DrawText( displayHealth, "NPGUI_STAT_SECONDARY", rX, rYb, Color(255,255,255,255), TEXT_ALIGN_CENTER )

					-- stats bar
					rY = ScrH() - 56 + 1
					rX = ScrW() - ( 256 )
					local speedColor = statusColor( 100 )
					if speedLimit and (speedLimit > 0) then speedColor = statusColor( 100 - math.Clamp( math.Round( (currentSpeed/speedLimit) * 100 ), 0, 100 ) ) end
					draw.RoundedBoxEx( 0, rX, rY, statAwidth, 2, speedColor, true, false, false, true )

					rX = rX + statAwidth + 1
					draw.RoundedBox( 0, rX, rY, statBwidth, 1, statusColor(gasDisplay))

					rX = rX + statBwidth + 1
					draw.RoundedBox( 0, rX, rY, statBwidth, 1, statusColor(displayHealth))

				end

				carInfo()

			end
		end
	end

end

-- Revenge/murderer tags

surface.CreateFont( "NPGUI_PL_FLAG", {
	font = "Segoe UI",
	size = 18,
	weight = 900,
} )

surface.CreateFont( "NPGUI_PL_FLAG_S", {
	font = "Segoe UI",
	size = 18,
	weight = 900,
	blursize = 4
} )

-- Pacifist/wanted tags

surface.CreateFont( "NPGUI_PL_TAG", {
	font = "Segoe UI",
	size = 18,
	weight = 900,
} )

surface.CreateFont( "NPGUI_PL_TAG_S", {
	font = "Segoe UI",
	size = 18,
	weight = 900,
	blursize = 4
} )

-- Name

surface.CreateFont( "NPGUI_PL_NAME", {
	font = "Segoe UI",
	size = 24,
	weight = 900,
} )

surface.CreateFont( "NPGUI_PL_NAME_S", {
	font = "Segoe UI",
	size = 24,
	weight = 900,
	blursize = 4
} )

-- HP

surface.CreateFont( "NPGUI_PL_HP", {
	font = "Segoe UI Bold",
	size = 14,
	weight = 900,
} )

surface.CreateFont( "NPGUI_PL_HP_S", {
	font = "Segoe UI Bold",
	size = 14,
	weight = 900,
	blursize = 4
} )

-- Job

surface.CreateFont( "NPGUI_PL_JOB", {
	font = "Segoe UI",
	size = 18,
	weight = 100,
} )

surface.CreateFont( "NPGUI_PL_JOB_S", {
	font = "Segoe UI",
	size = 18,
	weight = 100,
	blursize = 4
} )

-- Job

surface.CreateFont( "NPGUI_PL_CLAN", {
	font = "Segoe UI",
	size = 18,
	weight = 100,
} )

surface.CreateFont( "NPGUI_PL_CLAN_S", {
	font = "Segoe UI",
	size = 18,
	weight = 100,
	blursize = 4
} )

function npGUI:DrawPlayerInfo( ply, active )

	if 
		not IsValid( ply ) 
		or ply:GetObserverMode() != OBS_MODE_NONE
		or not ply:IsPlayer()
		or not ply:Alive()
		or not ply.getDarkRPVar
		or not ply:getDarkRPVar( "IsInitialized" )
		or ply:IsGhost( )
		//or ply:getDarkRPVar( "IsGhost" )
	then return end

	local center_y_height = 28

	local pos = ply:EyePos()
	pos.z = pos.z + 14

	local drawPos = pos:ToScreen()
	local yIndex = 0

	local function drawClanWarTag( )
		local width = 70
		local height = 24
		local x = drawPos.x
		local y = drawPos.y - yIndex

		local text = "AT WAR"
		local font = "NPGUI_PL_TAG"
		local shadow = font .. "_S"

		local sColor = Color( 0, 144, 255, 255 )
		local tColor = Color( 232, 245, 255, 255 )

		draw.RoundedBox( 2, (x - (width / 2) ), (y - 3), width, height, Color( 150, 40, 27, 128 ) )
		draw.DrawText( text, shadow, x, y, sColor, TEXT_ALIGN_CENTER )
		draw.DrawText( text, font, x, y, tColor, TEXT_ALIGN_CENTER )

		yIndex = yIndex + center_y_height

	end
	
	local function drawPacifistTag()

		local width = 70
		local height = 24

		local x = drawPos.x
		local y = drawPos.y - yIndex

		local text = "PACIFIST"
		local font = "NPGUI_PL_TAG"
		local shadow = font .. "_S"

		local sColor = Color( 0, 144, 255, 255 )
		local tColor = Color( 232, 245, 255, 255 )

		draw.RoundedBox( 2, (x - (width / 2) ), (y - 3), width, height, Color( 43, 139, 213, 128 ) )
		draw.DrawText( text, shadow, x, y, sColor, TEXT_ALIGN_CENTER )
		draw.DrawText( text, font, x, y, tColor, TEXT_ALIGN_CENTER )

		yIndex = yIndex + center_y_height

	end
	
	local function drawWantedTag()

		local width = 70
		local height = 24

		local x = drawPos.x
		local y = drawPos.y - yIndex

		local text = "WANTED"
		local font = "NPGUI_PL_TAG"
		local shadow = font .. "_S"

		local sColor = Color( 255, 0, 0, 255 )
		local tColor = Color( 255, 255, 255, 255 )

		local alpha = math.abs( math.sin( CurTime() * 3 ) * 255 )

		draw.RoundedBox( 2, (x - (width / 2) ), (y - 3), width, height, Color( 230, 66, 66, alpha ) )
		draw.DrawText( text, shadow, x, y, sColor, TEXT_ALIGN_CENTER )
		draw.DrawText( text, font, x, y, tColor, TEXT_ALIGN_CENTER )

		yIndex = yIndex + center_y_height

	end

	local function drawRevengeTag()

		local x = drawPos.x
		local y = drawPos.y - yIndex + 2

		local text = "REVENGE"
		local font = "NPGUI_PL_FLAG"
		local shadow = font .. "_S"

		local sColor = Color( 255, 71, 0, 255 )
		local tColor = Color( 255, 199, 177, 255 )

		draw.DrawText( text, shadow, x, y, sColor, TEXT_ALIGN_CENTER )
		draw.DrawText( text, font, x, y, tColor, TEXT_ALIGN_CENTER )

		yIndex = yIndex + ( center_y_height - 4 )

	end
	
	local function drawMurdererTag()

		local x = drawPos.x
		local y = drawPos.y - yIndex + 2

		local text = "MURDERER"
		local font = "NPGUI_PL_FLAG"
		local shadow = font .. "_S"

		local sColor = Color( 255, 0, 0, 255 )
		local tColor = Color( 255, 177, 177, 255 )

		draw.DrawText( text, shadow, x, y, sColor, TEXT_ALIGN_CENTER )
		draw.DrawText( text, font, x, y, tColor, TEXT_ALIGN_CENTER )

		yIndex = yIndex + center_y_height

	end

	local function drawBaseInfo()

		local x = ScrW() / 2
		local y = ( ScrH() / 2 ) + 32

		local text = ply:Name()
		local font = "NPGUI_PL_NAME"
		local shadow = font .. "_S"

		local sColor = Color( 0, 0, 0, 255 )
		local tColor = Color( 255, 255, 255, 255 )

		draw.DrawText( text, shadow, x, y + 1, sColor, TEXT_ALIGN_CENTER )
		draw.DrawText( text, font, x, y, tColor, TEXT_ALIGN_CENTER )

		y = y + 22

		text = math.Clamp( math.Round( ply:Health() ), 0, 99999 ) 
		font = "NPGUI_PL_HP"
		shadow = font .. "_S"

		sColor = HSVToColor( math.Clamp( text, 0, 255 ), .67, 1 )
		tColor = Color( 255, 255, 255, 128 )

		draw.DrawText( text .. " HP", shadow, x, y + 1, sColor, TEXT_ALIGN_CENTER )
		draw.DrawText( text .. " HP", font, x, y, tColor, TEXT_ALIGN_CENTER )

		y = y + 14

		text = team.GetName( ply:getDarkRPVar( "IsDisguised" ) or ply:Team( ) )
		font = "NPGUI_PL_JOB"
		shadow = font .. "_S"

		sColor = team.GetColor( ply:Team() )
		tColor = Color( 255, 255, 255, 128 )

		if ply:getDarkRPVar( "IsDisguised" ) then
			sColor = team.GetColor( ply:getDarkRPVar( "IsDisguised" ) )
			if isstring( ply:getDarkRPVar( "IsDisguised" ) ) then
				text = ply:getDarkRPVar( "IsDisguised" )
			end
		end

		draw.DrawText( text, shadow, x, y, sColor, TEXT_ALIGN_CENTER )
		draw.DrawText( text, font, x, y, tColor, TEXT_ALIGN_CENTER )

		y = y + 16

		local function drawClanTag()
			if ply:getDarkRPVar( "Clan" ) then
				
				text = "<" .. ply:getDarkRPVar( "Clan" ) .. ">"
				font = "NPGUI_PL_CLAN"
				shadow = font .. "_S"

				sColor = Color( 0, 0, 0, 255 )
				tColor = Color( 255, 255, 255, 128 )

				draw.DrawText( text, shadow, x, y + 1, sColor, TEXT_ALIGN_CENTER )
				draw.DrawText( text, font, x, y, tColor, TEXT_ALIGN_CENTER )

			end
		end

		drawClanTag()

	end

	--local traceRes = util.TraceLine( { start = LocalPlayer( ):EyePos( ), endpos = ply:EyePos( ), filter = LocalPlayer( ) } )
	if LocalPlayer():IsLineOfSightClear( ply:GetPos() + Vector( 0, 0, 64 ) ) then
	--if ( traceRes.Entity == ply ) then
		if ( ply:getDarkRPVar( "IsPacifist" ) and LocalPlayer( ):GetPos( ):FastDist( ply:GetPos( ) ) < 10000 ) then drawPacifistTag() end
		if ply:getDarkRPVar( "wanted" ) then drawWantedTag() end
		if not LocalPlayer():isCP() then
			if istable(LocalPlayer().revengeTable) and LocalPlayer().revengeTable[tonumber(ply:SafeUniqueID())] then
				drawRevengeTag()
			end
		end
		if ( LocalPlayer( ):IsInClanWar( ply:GetClan( ) ) and LocalPlayer( ):GetPos( ):FastDist( ply:GetPos( ) ) < 20000 ) then
			drawClanWarTag( )
		end
	end

	if ply:getDarkRPVar( "IsMurderer" ) then drawMurdererTag( ) end

	if active then drawBaseInfo() end

end
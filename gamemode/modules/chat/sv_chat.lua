function DarkRP.defineChatCommand(cmd, callback)
	cmd = string.lower(cmd)
	local detour = function(ply, arg, ...)
		if ply.DarkRPUnInitialized then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("data_not_loaded_one"))
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("data_not_loaded_two"))
			return ""
		end
		return callback(ply, arg, ...)
	end

	local chatcommands = DarkRP.getChatCommands()

	chatcommands[cmd] = chatcommands[cmd] or {}
	chatcommands[cmd].callback = detour
	chatcommands[cmd].command = chatcommands[cmd].command or cmd
end


local function RP_PlayerChat(ply, text)
	DarkRP.log(ply:Nick().." ("..ply:SteamID().."): "..text )
	local chatcommands = DarkRP.getChatCommands()
	local callback = ""
	local DoSayFunc
	local tblCmd = fn.Compose{ -- Extract the chat command
		DarkRP.getChatCommand,
		string.lower,
		fn.Curry(fn.Flip(string.sub), 2)(2), -- extract prefix
		fn.Curry(fn.GetValue, 2)(1), -- Get the first word
		fn.Curry(string.Explode, 2)(' ') -- split by spaces
	}(text)

	if string.sub(text, 1, 1) == GAMEMODE.Config.chatCommandPrefix and tblCmd then
		callback, DoSayFunc = tblCmd.callback(ply, string.sub(text, string.len(tblCmd.command) + 3, string.len(text)))
		if callback == "" then
			return "", "", DoSayFunc;
		end
		text = string.sub(text, string.len(tblCmd.command) + 3, string.len(text))
	end

	if callback ~= "" then
		callback = callback or "" .. " "
	end

	return text, callback, DoSayFunc;
end

local function RP_ActualDoSay(ply, text, callback)
	callback = callback or ""
	if text == "" then return "" end
	local col = team.GetColor(ply:Team())
	local col2 = Color(255,255,255,255)
	if ( ply:getDarkRPVar( "IsDisguised" ) ) then
		col = team.GetColor( ply:getDarkRPVar( "IsDisguised" ) )
	end
	if not ply:Alive() then
		col2 = Color(255,200,200,255)
		col = col2
	end

	if GAMEMODE.Config.alltalk then
		for k,v in pairs(player.GetAll()) do
			DarkRP.talkToPerson(v, col, callback..ply:Name(), col2, text, ply)
		end
	else
		DarkRP.talkToRange(ply, callback..ply:Name(), text, 250)
	end
	return ""
end

local ttsLocalChatConVar = CreateConVar( "N00BRP_TTSLocalChat", "0", FCVAR_ARCHIVE, "Whether all local chat goes through TTS." )
local function WasLocalChat( text )
	if ( ( string.sub( text, 1, 3 ) == "/pm" ) or ( string.sub( text, 1, 3 ) == "/cr" ) or ( string.sub( text, 1, 7 ) == "/advert" ) or
		( string.sub( text, 1, 5 ) == "/clan" ) or ( string.sub( text, 1, 5 ) == "/news" ) or ( string.sub( text, 1, 2 ) == "/g" ) or
		( string.sub( text, 1, 2 ) == "@ " ) or ( string.sub( text, 1, 2 ) == "@@" ) or ( string.sub( text, 1, 2 ) == "//" ) or 
		( string.sub( text, 1, 4 ) == "/ooc" ) or ( string.sub( text, 1, 1 ) == "/" ) ) then
		return false
	else
		return true
	end
end

GM.OldChatHooks = GM.OldChatHooks or {}
function GM:PlayerSay(ply, text, teamonly, dead, override) -- We will make the old hooks run AFTER DarkRP's playersay has been run.
	//if ( ply:getDarkRPVar( "IsGhost" ) ) then
	if ( ply:IsGhost( ) ) then
		if ( string.sub( text, 1, 3 ) == "/pm" ) then
			DarkRP.notify( ply, 1, 4, "You cannot pm while dead!" )
			return ""
		elseif ( string.sub( text, 1, 3 ) == "/cr" ) then
			DarkRP.notify( ply, 1, 4, "You cannot call Civil Protection while dead!" )
			return ""
		elseif ( string.sub( text, 1, 7 ) == "/advert" ) then
			DarkRP.notify( ply, 1, 4, "You cannot advert while dead!" )
			return ""
		elseif ( string.sub( text, 1, 5 ) == "/clan" ) then
			DarkRP.notify( ply, 1, 4, "You cannot talk to clan members while dead!" )
			return ""
		elseif ( string.sub( text, 1, 5 ) == "/news" ) then
			DarkRP.notify( ply, 1, 4, "You cannot broadcast news while dead!" )
			return ""
		elseif ( string.sub( text, 1, 2 ) == "/g" ) then
			DarkRP.notify( ply, 1, 4, "You cannot use group chat while dead!" )
			return ""
		elseif ( string.sub( text, 1, 8 ) == "/buyfood" ) then
			DarkRP.notify( ply, 1, 4, "You cannot buy food while dead!" )
			return ""
		elseif ( string.sub( text, 1, 7 ) == "/wanted" ) then
			DarkRP.notify( ply, 1, 4, "You cannot set someone wanted while dead!" )
			return ""
		end
	elseif ( ply.isChatBanned ) then
		if not ( string.sub( text, 1, 2 ) == "@ " ) then
			DarkRP.notify( ply, NOTIFY_ERROR, 4, "You can only speak to admins while chat-banned." )
			return ""
		end
	elseif ( ply.isAdminChatBanned ) then
		if ( string.sub( text, 1, 2 ) == "@ " ) then
			DarkRP.notify( ply, NOTIFY_ERROR, 4, "You cannot speak to admins currently. Stop spamming admin chat." )
			return ""
		end
	end
	if ( ttsLocalChatConVar:GetBool( ) and WasLocalChat( text ) ) then
		net.Start( "N00BRP_TextToSpeech" )
			net.WriteEntity( ply )
			net.WriteString( string.Replace( text, " ", "+" ) )
		net.Broadcast( )
	end
	local text2 = (not teamonly and "" or "/g ") .. text
	local callback

	for k,v in pairs(self.OldChatHooks) do
		if type(v) ~= "function" then continue end

		if type(k) == "Entity" or type(k) == "Player" then
			text2 = v(k, ply, text, teamonly, dead) or text2
		else
			text2 = v(ply, text, teamonly, dead) or text2
		end
	end

	text2, callback, DoSayFunc = RP_PlayerChat(ply, text2)
	if tostring(text2) == " " then text2, callback = callback, text2 end

	if game.IsDedicated() then
		ServerLog("\""..ply:Nick().."<"..ply:UserID()..">" .."<"..ply:SteamID()..">".."<"..team.GetName(ply:Team())..">\" say \""..text.. "\"\n" .. "\n")
	end

	if DoSayFunc then DoSayFunc(text2) return "" end
	RP_ActualDoSay(ply, text2, callback)

	hook.Call("PostPlayerSay", nil, ply, text2, teamonly, dead)
	return ""
end

local function ReplaceChatHooks()
	if not hook.GetTable().PlayerSay then return end
	for k,v in pairs(hook.GetTable().PlayerSay) do -- Remove all PlayerSay hooks, they all interfere with DarkRP's PlayerSay
		GAMEMODE.OldChatHooks[k] = v
		hook.Remove("PlayerSay", k)
	end
	for a,b in pairs(GAMEMODE.OldChatHooks) do
		if type(b) ~= "function" then
			GAMEMODE.OldChatHooks[a] = nil
		end
	end

	table.sort(GAMEMODE.OldChatHooks, function(a, b)
		if type(a) == "string" and type(b) == "string" then
			return a > b
		end

		return true
	end)

	-- give warnings for undeclared chat commands
	local warning = fn.Compose{ErrorNoHalt, fn.Curry(string.format, 2)("Chat command \"%s\" is defined but not declared!\n")}
	fn.ForEach(warning, DarkRP.getIncompleteChatCommands())
end
hook.Add("InitPostEntity", "RemoveChatHooks", ReplaceChatHooks)

local function ConCommand(ply, _, args)
	if not args[1] then return end

	local cmd = string.lower(args[1])
	local arg = table.concat(args, ' ', 2)
	local tbl = DarkRP.getChatCommand(cmd)
	local time = CurTime()

	if not tbl then return end

	ply.DrpCommandDelays = ply.DrpCommandDelays or {}

	if tbl.delay and ply.DrpCommandDelays[cmd] and ply.DrpCommandDelays[cmd] > time - tbl.delay then
		return
	end

	ply.DrpCommandDelays[cmd] = time

	tbl.callback(ply, arg)
end
concommand.Add("darkrp", ConCommand)

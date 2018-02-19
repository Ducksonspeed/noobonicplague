--if ( true ) then return end

if ( CLIENT ) then
	
	if not ( tobool( GetConVarNumber( "noobrp_enablecustomchatbox" ) ) ) then return end
	-- This isn't necessary with the hooks below.
	/*local function AddPlayerMessageToChatbox( ply, strText, teamOnly, isDead )
		if ( ValidPanel( LocalPlayer( ).noob_ChatBox ) ) then
			local chatBox = LocalPlayer( ).noob_ChatBox
			chatBox:ChangeTextColor( team.GetColor( ply:Team( ) ) )
			chatBox:InsertText( ply:Name( ) )
			chatBox:ChangeTextColor( Color( 255, 255, 255 ) )
			chatBox:InsertText( ": " .. strText )
			chatBox:InsertNewLine( )
			--LocalPlayer( ).noob_ChatBox.chatRichText:AppendText( strText )
			--LocalPlayer( ).noob_ChatBox.chatRichText:AppendText( "\n" )
		end
	end
	hook.Add( "OnPlayerChat", "N00BRP_AddPlayerMessageToChatbox_OnPlayerChat", AddPlayerMessageToChatbox )*/

	local function AddMessageToChatbox( index, name, text, typ )
		LocalPlayer( ).chatBoxHistory = LocalPlayer( ).chatBoxHistory or { }
		if not ( LocalPlayer( ).chatBoxHistory ) then return end
		table.insert( LocalPlayer( ).chatBoxHistory, { text } )
		if ( IsValid( LocalPlayer( ).noob_ChatBox ) ) then
			LocalPlayer( ).noob_ChatBox:ChangeTextColor( Color( 89, 171, 227, 255 ) )
			LocalPlayer( ).noob_ChatBox:InsertText( text )
			LocalPlayer( ).noob_ChatBox:InsertNewLine( )
			/*LocalPlayer( ).noob_ChatBox.chatRichText:AppendText( text )
			LocalPlayer( ).noob_ChatBox.chatRichText:AppendText( "\n" )*/
			--return false
		end
	end
	hook.Add( "ChatText", "N00BRP_AddMessageToChatbox_ChatText", AddMessageToChatbox )

	local function OnStartChat( isTeamChat )
		if ( IsValid( LocalPlayer( ).noob_ChatBox ) ) then
			LocalPlayer( ).noob_ChatBox:ActivateChatBox( )
		else
			LocalPlayer( ).noob_ChatBox = vgui.Create( "DN00B_ChatBox" )
		end
		return true
	end
	hook.Add( "StartChat", "N00BRP_OnStartChat_StartChat", OnStartChat )

	local function OnFinishChat( )
		if ( IsValid( LocalPlayer( ).noob_ChatBox ) and LocalPlayer( ).noob_ChatBox.isActivated ) then
			LocalPlayer( ).noob_ChatBox:DeactivateChatBox( )
		end
	end
	hook.Add( "FinishChat", "N00BRP_OnFinishChat_FinishChat", OnFinishChat )

	function chat.AddText( ... )
		local chatBox = LocalPlayer( ).noob_ChatBox
		LocalPlayer( ).chatBoxHistory = LocalPlayer( ).chatBoxHistory or { }
		if not ( LocalPlayer( ).chatBoxHistory ) then return end
		table.insert( LocalPlayer( ).chatBoxHistory, { ... } )
		local tab = { ... }
		table.insert( tab, "\n" )
		MsgC( unpack( tab ) )
		if ( ValidPanel( LocalPlayer( ).noob_ChatBox ) ) then
			for index, arg in pairs ( { ... } ) do
				if ( istable( arg ) ) then
					chatBox:ChangeTextColor( arg )
				else
					chatBox:InsertText( arg )
				end
			end
			chatBox:InsertNewLine( )
		end
	end

	local function OnPlayerStartVoice( ply )
		ply.isUsingVoice = true
	end
	hook.Add( "PlayerStartVoice", "N00BRP_OnPlayerStartVoice_PlayerStartVoice", OnPlayerStartVoice )

	local function OnPlayerEndVoice( ply )
		ply.isUsingVoice = false
	end
	hook.Add( "PlayerEndVoice", "N00BRP_OnPlayerEndVoice_PlayerEndVoice", OnPlayerEndVoice )

	function DrawChatListeners( )
		if ( ValidPanel( LocalPlayer( ).noob_ChatBox ) ) then
			local chatBox = LocalPlayer( ).noob_ChatBox
			local chatBoxX, chatBoxY = chatBox:GetPos( )
			if ( chatBox.isActivated or LocalPlayer( ).isUsingVoice ) then
				local listenPlayers = { }
				if ( string.sub( chatBox.chatEntry:GetValue( ), 1, 3 ) == "/pm" ) then
					local selPlayer = string.Explode( " ", chatBox.chatEntry:GetValue( ) )
					selPlayer = FindPlayer( tostring( selPlayer[2] ) )
					if ( IsValid( selPlayer ) ) then table.insert( listenPlayers, selPlayer ) end
				else
					local listenRange = 250
					if ( string.sub( chatBox.chatEntry:GetValue( ), 1, 2 ) == "/w" ) then listenRange = 90 end
					if ( string.sub( chatBox.chatEntry:GetValue( ), 1, 2 ) == "/y" ) then listenRange = 550 end
					if ( LocalPlayer( ).isUsingVoice ) then listenRange = 550 end
					for index, ply in ipairs ( player.GetAll( ) ) do
						if ( LocalPlayer( ) == ply ) then continue end
						if ( ply:GetObserverMode( ) ~= OBS_MODE_NONE ) then continue end
						if ( ply:IsGhost( ) ) then continue end
						if ( LocalPlayer( ):GetPos( ):Distance( ply:GetPos( ) ) < listenRange ) then
							table.insert( listenPlayers, ply )
						end
					end
				end
				for index, ply in ipairs ( listenPlayers ) do
					draw.SimpleText( ply:Name( ), "N00BRP_ChatBox_TextFont", chatBoxX + 16, chatBoxY - ( index * 16 ), Color( 255, 255, 255 ), TEXT_ALIGN_LEFT )
				end
				if ( #listenPlayers == 0 ) then
					draw.SimpleText( "Nobody can hear you.", "N00BRP_ChatBox_TextFont", chatBoxX + 16, chatBoxY - ( ( #listenPlayers + 1 ) * 16 ), Color( 175, 45, 45 ), TEXT_ALIGN_LEFT )
				else
					draw.SimpleText( "Players who can hear you:", "N00BRP_ChatBox_TextFont", chatBoxX + 16, chatBoxY - ( ( #listenPlayers + 1 ) * 16 ), Color( 45, 175, 45 ), TEXT_ALIGN_LEFT )
				end
			end
		end
	end
	hook.Add( "HUDPaint", "N00BRP_DrawChatListeners_HUDPaint", DrawChatListeners )
end
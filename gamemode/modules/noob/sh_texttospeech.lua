if ( SERVER ) then
	util.AddNetworkString( "N00BRP_TextToSpeech" )
else
	local function OnTextToSpeechSuccess( ply, patch )
		if ( ply.cTextSpeechPatch ) then
			timer.Destroy( ply:EntIndex( ) .. ":TextToSpeech" )
			ply.cTextSpeechPatch:Stop( )
			ply.cTextSpeechPatch = nil
		end
		ply.cTextSpeechPatch = patch
		patch:SetPos( ply:GetPos( ) )
		patch:Play( )
		patch:Set3DFadeDistance( 256, 0 )
		local lifeTime = 0
		local entIndex = ply:EntIndex( )
		timer.Create( entIndex .. ":TextToSpeech", 1, 20, function( )
			lifeTime = lifeTime + 1
			if not ( IsValid( ply ) ) then
				patch:Stop( )
				patch = nil
				timer.Destroy( entIndex .. ":TextToSpeech" )
				return
			end
			if ( patch ) then
				patch:SetPos( ply:GetPos( ) )
				if ( system.HasFocus( ) ) then
					patch:SetVolume( 1 )
				else
					patch:SetVolume( 0 )
				end
				if ( lifeTime >= 19 ) then
				    patch:Stop( )
				    patch = nil
				    timer.Destroy( entIndex .. ":TextToSpeech" )
				end
			end
		end )
	end
	local function ReceiveTextToSpeech( len )
		local ply = net.ReadEntity( )
		local text = net.ReadString( )
		text = string.Replace( text, " ", "+" )
		local finalText = "http://tts.peniscorp.com/speak.lua?" .. text
		if not ( IsValid ( ply ) ) then return end
		if not ( isstring( finalText ) ) then return end
		if ( ply:GetPos( ):Distance( LocalPlayer( ):GetPos( ) ) > 1000 ) then return end
		if not ( IsValid( ply ) ) then return end
		local ttsDisabled = tobool( tonumber( GetConVarNumber( "noobrp_disabletts" ) or 0 ) )
		if ( ttsDisabled ) then return end
		/*http.Fetch( finalText, 
			function( body, len, headers, code )*/
			    sound.PlayURL( finalText, "3d", function( patch )
			    	if ( IsValid( patch ) ) then
			    		OnTextToSpeechSuccess( ply, patch )
			    	else
			    		timer.Simple( 1, function( ) -- Retry once...
			    			if not ( IsValid( ply ) ) then return end
			    			sound.PlayURL( finalText, "3d", function( patchTwo )
				    			if ( IsValid( patchTwo ) ) then
				    				OnTextToSpeechSuccess( ply, patchTwo )
				    			end
				    		end )
			    		end )
			    	end
			    end )
			/*end, 
			function( error )
				-- Could not fetch.
			end
		)*/
	end
	net.Receive( "N00BRP_TextToSpeech", ReceiveTextToSpeech )
end
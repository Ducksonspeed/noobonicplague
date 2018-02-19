/*---------------------------------------------------------------------------
Log a message to console
---------------------------------------------------------------------------*/
local function AdminLog(um)
	local colour = Color(um:ReadShort(), um:ReadShort(), um:ReadShort())
	local text = um:ReadString() .. "\n"
	MsgC(Color(0,250,154), "[NP] ")
	MsgC(colour, DarkRP.deLocalise(text))
end
usermessage.Hook("DRPLogMsg", AdminLog)

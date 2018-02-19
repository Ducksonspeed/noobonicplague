local PANEL = {};

function PANEL:Init()
	self.SlotList = vgui.Create( "DIconLayout", self );
	self.SlotList:SetPos( 2, 2 );
	self.SlotList:SetSpaceX( 2 );
	self.SlotList:SetSpaceY( 2 );
end

function PANEL:SetSizeNew( w, h )
	self:SetSize( w, h );
	self.SlotList:SetSize( w, h - 10 );
end

derma.DefineControl( "ItemSlotFrame", "Frame with slots for trading", PANEL, "DScrollPanel" );


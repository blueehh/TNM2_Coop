//=============================================================================
// CoopSaveMenuWindow
// The Nameless Mod 2.0 - Co-op Mod by bluehh (TM)
//
// In-game Co-op Save Campaign window with 4 selectable Save Slots (Slot 1..4).
//=============================================================================
class CoopSaveMenuWindow extends ToolWindow;

var TextWindow lblHeader;
var TextWindow lblStatus;
var CoopSlotButtonWindow btnSlots[4];
var ToolButtonWindow btnSave;
var ToolButtonWindow btnCancel;
var int selectedSlot;

event InitWindow()
{
	local int i;

	Super.InitWindow();

	SetSize(360, 236);
	SetTitle("Save Co-op Campaign");

	class'CoopSaveSlotManager'.static.EnsureInitialized();
	selectedSlot = class'CoopSaveSlotManager'.static.GetActiveSlot();

	lblHeader = CreateToolLabel(18, 30, "Select a Co-op Save Slot, then click Save:");
	if (lblHeader != None)
		lblHeader.SetTextColorRGB(20, 35, 60);

	for (i = 0; i < 4; i++)
	{
		btnSlots[i] = CoopSlotButtonWindow(winContainer.NewChild(Class'CoopSlotButtonWindow'));
		if (btnSlots[i] != None)
		{
			btnSlots[i].SetPos(18, 52 + (i * 28));
			btnSlots[i].SetSize(324, 24);
		}
	}

	lblStatus = CreateToolLabel(18, 170, "Selected: Slot " $ (selectedSlot + 1));
	if (lblStatus != None)
		lblStatus.SetTextColorRGB(20, 90, 40);

	btnSave   = CreateToolButton(170, 196, "|&Save");
	btnCancel = CreateToolButton(262, 196, "|&Cancel");

	RefreshSlots();
}

function RefreshSlots()
{
	local int i;
	local bool bHasData;
	local string labelStr;

	for (i = 0; i < 4; i++)
	{
		bHasData = class'CoopSaveSlotManager'.static.HasSlotSave(i);
		labelStr = class'CoopSaveSlotManager'.static.GetSlotButtonLabel(i, (i == selectedSlot), False);
		if (btnSlots[i] != None)
			btnSlots[i].SetSlotInfo(i, labelStr, (i == selectedSlot), bHasData);
	}
}

function bool ButtonActivated(Window buttonPressed)
{
	local int i;
	local Trestkon T;

	T = Trestkon(player);

	for (i = 0; i < 4; i++)
	{
		if (buttonPressed == btnSlots[i])
		{
			selectedSlot = i;
			class'CoopSaveSlotManager'.static.SetActiveSlot(selectedSlot);
			if (lblStatus != None)
				lblStatus.SetText("Selected: Slot " $ (selectedSlot + 1));
			RefreshSlots();
			return True;
		}
	}

	if (buttonPressed == btnSave)
	{
		class'CoopSaveSlotManager'.static.SetActiveSlot(selectedSlot);
		if (T != None)
			T.CoopSave();
		class'CoopSaveSlotManager'.static.CopyActiveSessionToSlot(selectedSlot);
		RefreshSlots();
		if (lblStatus != None)
			lblStatus.SetText("SAVED TO SLOT " $ (selectedSlot + 1) $ "!");
		return True;
	}

	if (buttonPressed == btnCancel)
	{
		if (root != None)
			root.PopWindow();
		return True;
	}

	return Super.ButtonActivated(buttonPressed);
}

defaultproperties
{
}

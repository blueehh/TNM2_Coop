//=============================================================================
// CoopLoadMenuWindow
// The Nameless Mod 2.0 - Co-op Mod by bluehh (TM)
//
// In-game Co-op Load Campaign window with 4 selectable Save Slots (Slot 1..4).
//=============================================================================
class CoopLoadMenuWindow extends ToolWindow;

var TextWindow lblHeader;
var TextWindow lblStatus;
var CoopSlotButtonWindow btnSlots[4];
var ToolButtonWindow btnLoad;
var ToolButtonWindow btnCancel;
var int selectedSlot;

event InitWindow()
{
	local int i;

	Super.InitWindow();

	SetSize(360, 236);
	SetTitle("Load Co-op Campaign");

	class'CoopSaveSlotManager'.static.EnsureInitialized();
	selectedSlot = class'CoopSaveSlotManager'.static.GetActiveSlot();

	lblHeader = CreateToolLabel(18, 30, "Select a Co-op Save Slot to Load:");
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
		lblStatus.SetTextColorRGB(20, 45, 90);

	btnLoad   = CreateToolButton(170, 196, "|&Load");
	btnCancel = CreateToolButton(262, 196, "|&Cancel");

	RefreshSlots();
}

function RefreshSlots()
{
	local int i;
	local bool bHasData, bSelectedHasData;
	local string labelStr;

	for (i = 0; i < 4; i++)
	{
		bHasData = class'CoopSaveSlotManager'.static.HasSlotSave(i);
		labelStr = class'CoopSaveSlotManager'.static.GetSlotButtonLabel(i, (i == selectedSlot), False);
		if (btnSlots[i] != None)
			btnSlots[i].SetSlotInfo(i, labelStr, (i == selectedSlot), bHasData);
	}

	bSelectedHasData = class'CoopSaveSlotManager'.static.HasSlotSave(selectedSlot);
	if (btnLoad != None)
		btnLoad.SetSensitivity(bSelectedHasData);
	if (lblStatus != None)
	{
		if (bSelectedHasData)
			lblStatus.SetText("Ready to load Slot " $ (selectedSlot + 1) $ ": " $ class'CoopSaveSlotManager'.static.GetSlotMapURL(selectedSlot));
		else
			lblStatus.SetText("Slot " $ (selectedSlot + 1) $ " is empty.");
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
			RefreshSlots();
			return True;
		}
	}

	if (buttonPressed == btnLoad)
	{
		if (class'CoopSaveSlotManager'.static.LoadSlotIntoActiveSession(selectedSlot))
		{
			if (root != None)
				root.ClearWindowStack();
			if (T != None)
				T.CoopContinue();
		}
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

//=============================================================================
// CoopMultiplayerMenuWindow
// The Nameless Mod 2.0 - Co-op Mod by bluehh (TM)
//
// Main Menu & In-Game Co-op Multiplayer Window:
//   - Top:    Player Name input + clear Active Name confirmation banner
//   - Middle: Full-width clickable Server IP input box + OS Clipboard Paste
//   - Bottom: Red HOST box (HOST -> NEW / LOAD + 4 clickable Save Slot buttons)
//             & Blue JOIN box (with non-softlocking CoopConnectingWindow)
//   - Footer: Character Skin selector, bluehh (TM) credit, and Back button
//=============================================================================
class CoopMultiplayerMenuWindow extends ToolWindow;

var TextWindow lblActiveNameBanner;
var TextWindow lblNamePrompt;
var TextWindow lblNameHint;
var CoopClipboardEditWindow editPlayerName;
var ToolButtonWindow btnApplyName;

var TextWindow lblIPHeader;
var CoopClipboardEditWindow editServerIP;
var ToolButtonWindow btnPasteIP;

var TextWindow lblHostTitle;
var TextWindow lblSlotsHeader;
var ToolButtonWindow btnHostMain;
var ToolButtonWindow btnHostNew;
var ToolButtonWindow btnHostLoad;
var CoopSlotButtonWindow btnSaveSlots[4];

var TextWindow lblJoinTitle;
var TextWindow lblJoinSub;
var TextWindow lblConnectStatus;
var ToolButtonWindow btnJoinServer;

var ToolButtonWindow btnCharSkin;
var TextWindow lblModCredit;
var ToolButtonWindow btnClose;

var bool bHostSubMenuOpen;
var int selectedSlot;

function CoopClipboardEditWindow CreateCoopEditBox(int posX, int posY, int boxWidth, int boxHeight, int maxChars, bool bIPField)
{
	local ToolBorderWindow winBorder;
	local Window winInner;
	local ClipWindow editClip;
	local CoopClipboardEditWindow newEdit;

	winBorder = ToolBorderWindow(winContainer.NewChild(Class'ToolBorderWindow'));
	winBorder.SetPos(posX, posY);
	winBorder.SetSize(boxWidth, boxHeight);
	winBorder.SetBackground(Texture'Solid');
	winBorder.SetTileColorRGB(255, 255, 255);

	winInner = winBorder.NewChild(Class'Window');
	winInner.SetWindowAlignments(HALIGN_Full, VALIGN_Full);
	winInner.SetBackground(Texture'Solid');
	winInner.SetTileColorRGB(255, 255, 255);

	// ForceChildSize(True, True) ensures the EditWindow always spans the ENTIRE
	// box width & height (stock CreateToolEditWindow passed False for width,
	// shrinking the clickable area to 0px when empty or ~45px for "127.0.0.1"!)
	editClip = ClipWindow(winInner.NewChild(Class'ClipWindow'));
	editClip.ForceChildSize(True, True);
	editClip.SetWindowAlignments(HALIGN_Full, VALIGN_Full);

	newEdit = CoopClipboardEditWindow(editClip.NewChild(Class'CoopClipboardEditWindow'));
	newEdit.bIsIPField = bIPField;
	newEdit.SetMaxSize(maxChars);
	newEdit.EnableEditing(True);
	newEdit.EnableSingleLineEditing(True);
	newEdit.SetSensitivity(True);
	newEdit.SetSelectability(True);

	return newEdit;
}

event InitWindow()
{
	local Trestkon T;
	local String curName, curIP, prevErr;
	local int i;

	Super.InitWindow();

	SetSize(410, 344);
	SetTitle("Multiplayer (Co-op)");

	if (root != None)
		root.ShowCursor(True);

	class'CoopSaveSlotManager'.static.EnsureInitialized();
	selectedSlot = class'CoopSaveSlotManager'.static.GetActiveSlot();

	T = Trestkon(player);
	if (T != None)
	{
		curName = T.GetLocalCoopPlayerName();
		curIP   = T.GetCoopLastServerIP();
		prevErr = T.coopLastConnectError;
		T.coopLastConnectError = "";
	}
	if (curName == "")
		curName = "Player";
	if (curIP == "")
		curIP = "127.0.0.1";

	// 1. TOP SECTION: Active Name Display Banner + Name Input (Y=26..96)
	lblActiveNameBanner = CreateToolLabel(24, 32, "ACTIVE PLAYER NAME:  [ " $ curName $ " ]  (SAVED)");
	if (lblActiveNameBanner != None)
		lblActiveNameBanner.SetTextColorRGB(110, 245, 160);

	lblNamePrompt = CreateToolLabel(18, 60, "Type Name:");
	editPlayerName = CreateCoopEditBox(90, 56, 214, 22, 24, False);
	if (editPlayerName != None)
		editPlayerName.SetText(curName);

	btnApplyName = CreateToolButton(312, 55, "|&Set Name");

	lblNameHint = CreateToolLabel(18, 82, "Inventory, ammo, health & skills are saved under this name.");
	if (lblNameHint != None)
		lblNameHint.SetTextColorRGB(30, 45, 70);

	// 2. MIDDLE SECTION: Full-Width Clickable Server IP Box + Paste Button (Y=100..136)
	lblIPHeader = CreateToolLabel(24, 112, "Server IP:");
	if (lblIPHeader != None)
		lblIPHeader.SetTextColorRGB(220, 235, 255);

	editServerIP = CreateCoopEditBox(90, 107, 214, 22, 64, True);
	if (editServerIP != None)
		editServerIP.SetText(curIP);

	btnPasteIP = CreateToolButton(312, 107, "|&Paste");

	// 3. BOTTOM SECTION: Left RED Box (HOST + Save Slots) & Right BLUE Box (JOIN) (Y=144..298)
	lblHostTitle = CreateToolLabel(44, 150, "HOST CO-OP SERVER");
	if (lblHostTitle != None)
		lblHostTitle.SetTextColorRGB(255, 195, 195);

	btnHostMain = CreateToolButton(68, 168, "|&HOST");
	btnHostNew  = CreateToolButton(26, 168, "|&NEW");
	btnHostLoad = CreateToolButton(112, 168, "|&LOAD");

	lblSlotsHeader = CreateToolLabel(24, 194, "Select Save Slot (Click Slot):");
	if (lblSlotsHeader != None)
		lblSlotsHeader.SetTextColorRGB(245, 210, 210);

	for (i = 0; i < 4; i++)
	{
		btnSaveSlots[i] = CoopSlotButtonWindow(winContainer.NewChild(Class'CoopSlotButtonWindow'));
		if (btnSaveSlots[i] != None)
		{
			btnSaveSlots[i].SetPos(24, 210 + (i * 20));
			btnSaveSlots[i].SetSize(168, 18);
		}
	}

	lblJoinTitle = CreateToolLabel(248, 150, "JOIN CO-OP SERVER");
	if (lblJoinTitle != None)
		lblJoinTitle.SetTextColorRGB(190, 220, 255);

	btnJoinServer = CreateToolButton(264, 188, "|&JOIN");

	lblJoinSub = CreateToolLabel(226, 220, "Ctrl+V or Paste IP, then JOIN");
	if (lblJoinSub != None)
		lblJoinSub.SetTextColorRGB(185, 210, 245);

	lblConnectStatus = CreateToolLabel(218, 244, "");
	if (lblConnectStatus != None)
	{
		lblConnectStatus.SetSize(168, 46);
		lblConnectStatus.SetWordWrap(True);
		lblConnectStatus.SetTextColorRGB(255, 130, 120);
		if (prevErr != "")
			lblConnectStatus.SetText(prevErr);
	}

	// 4. FOOTER BUTTONS & MOD ATTRIBUTION
	btnCharSkin = CreateToolButton(16, 306, "Character |&Skin");
	lblModCredit = CreateToolLabel(102, 311, "TNM 2.0 Co-op  |  bluehh (TM)");
	if (lblModCredit != None)
	{
		lblModCredit.SetSize(206, 14);
		lblModCredit.SetTextAlignments(HALIGN_Center, VALIGN_Center);
		lblModCredit.SetTextColorRGB(50, 65, 90);
	}
	btnClose    = CreateToolButton(314, 306, "|&Back");

	bHostSubMenuOpen = False;
	RefreshHostButtons();

	// Focus the Server IP box immediately so typing or Ctrl+V works right away
	if (editServerIP != None)
	{
		SetFocusWindow(editServerIP);
		editServerIP.MoveInsertionPoint(MOVEINSERT_EndOfLine);
		editServerIP.SetSelectedArea(0, Len(curIP));
	}
}

function OnConnectAborted(String reason)
{
	if (root != None)
		root.ShowCursor(True);
	if (lblConnectStatus != None)
		lblConnectStatus.SetText(reason);
	if (editServerIP != None)
	{
		SetFocusWindow(editServerIP);
		editServerIP.MoveInsertionPoint(MOVEINSERT_EndOfLine);
		editServerIP.SetSelectedArea(0, Len(editServerIP.GetText()));
	}
}

event bool MouseButtonPressed(float pointX, float pointY, EInputKey button, int numClicks)
{
	if (button == IK_LeftMouse)
	{
		if (editPlayerName != None && pointX >= 88 && pointX <= 306 && pointY >= 54 && pointY <= 82)
		{
			SetFocusWindow(editPlayerName);
			return True;
		}
		if (editServerIP != None && pointX >= 88 && pointX <= 306 && pointY >= 104 && pointY <= 134)
		{
			SetFocusWindow(editServerIP);
			return True;
		}
	}
	return Super.MouseButtonPressed(pointX, pointY, button, numClicks);
}

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	local Window curFocus;

	if (key == IK_Escape)
	{
		ApplyCurrentPlayerName();
		ApplyCurrentServerIP();
		if (root != None)
			root.PopWindow();
		return True;
	}

	if (key == IK_Enter)
	{
		curFocus = GetFocusWindow();
		if (curFocus == editPlayerName)
		{
			ApplyCurrentPlayerName();
			return True;
		}
		if (curFocus == editServerIP)
		{
			StartJoinCurrentIP();
			return True;
		}
	}

	return Super.VirtualKeyPressed(key, bRepeat);
}

function RefreshHostButtons()
{
	local int i;
	local bool bSelectedHasSave, bSlotHasData;
	local string slotText;

	for (i = 0; i < 4; i++)
	{
		bSlotHasData = class'CoopSaveSlotManager'.static.HasSlotSave(i);
		slotText = class'CoopSaveSlotManager'.static.GetSlotButtonLabel(i, (i == selectedSlot), True);
		if (btnSaveSlots[i] != None)
			btnSaveSlots[i].SetSlotInfo(i, slotText, (i == selectedSlot), bSlotHasData);
	}

	bSelectedHasSave = class'CoopSaveSlotManager'.static.HasSlotSave(selectedSlot);

	if (bHostSubMenuOpen)
	{
		if (lblHostTitle != None)
			lblHostTitle.SetText("HOST (SLOT " $ (selectedSlot + 1) $ " SELECTED)");
		if (btnHostMain != None)
			btnHostMain.Hide();
		if (btnHostNew != None)
			btnHostNew.Show();
		if (btnHostLoad != None)
		{
			btnHostLoad.Show();
			btnHostLoad.SetSensitivity(bSelectedHasSave);
		}
	}
	else
	{
		if (lblHostTitle != None)
			lblHostTitle.SetText("HOST CO-OP SERVER");
		if (btnHostMain != None)
			btnHostMain.Show();
		if (btnHostNew != None)
			btnHostNew.Hide();
		if (btnHostLoad != None)
			btnHostLoad.Hide();
	}
}

event DrawWindow(GC gc)
{
	local Color cFill, cBorder;

	Super.DrawWindow(gc);

	gc.SetStyle(DSTY_Normal);

	// 1. Top Active Name Status Banner Box (16, 26, 378, 24)
	cFill.R = 10; cFill.G = 28; cFill.B = 20;
	gc.SetTileColor(cFill);
	gc.DrawPattern(16, 26, 378, 24, 0, 0, Texture'Solid');
	cBorder.R = 60; cBorder.G = 215; cBorder.B = 120;
	gc.SetTileColor(cBorder);
	gc.DrawBox(16, 26, 378, 24, 0, 0, 1, Texture'Solid');

	// 2. Middle Compact Server IP Box (16, 100, 378, 36)
	cFill.R = 14; cFill.G = 18; cFill.B = 26;
	gc.SetTileColor(cFill);
	gc.DrawPattern(16, 100, 378, 36, 0, 0, Texture'Solid');
	cBorder.R = 40; cBorder.G = 45; cBorder.B = 55;
	gc.SetTileColor(cBorder);
	gc.DrawBox(16, 100, 378, 36, 0, 0, 2, Texture'Solid');

	// 3. Bottom-Left RED HOST Box (16, 144, 184, 152)
	cFill.R = 48; cFill.G = 12; cFill.B = 14;
	gc.SetTileColor(cFill);
	gc.DrawPattern(16, 144, 184, 152, 0, 0, Texture'Solid');
	cBorder.R = 235; cBorder.G = 45; cBorder.B = 45;
	gc.SetTileColor(cBorder);
	gc.DrawBox(16, 144, 184, 152, 0, 0, 2, Texture'Solid');

	// 4. Bottom-Right BLUE JOIN Box (210, 144, 184, 152)
	cFill.R = 12; cFill.G = 26; cFill.B = 58;
	gc.SetTileColor(cFill);
	gc.DrawPattern(210, 144, 184, 152, 0, 0, Texture'Solid');
	cBorder.R = 55; cBorder.G = 125; cBorder.B = 255;
	gc.SetTileColor(cBorder);
	gc.DrawBox(210, 144, 184, 152, 0, 0, 2, Texture'Solid');
}

function String TrimWhitespace(String s)
{
	while (Len(s) > 0 && Left(s, 1) == " ")
		s = Mid(s, 1);
	while (Len(s) > 0 && Right(s, 1) == " ")
		s = Left(s, Len(s) - 1);
	return s;
}

function String ApplyCurrentPlayerName()
{
	local Trestkon T;
	local String typedName;

	T = Trestkon(player);
	if (editPlayerName != None)
		typedName = editPlayerName.CleanClipboardString(editPlayerName.GetText());

	if (typedName == "")
	{
		if (T != None)
			typedName = T.GetLocalCoopPlayerName();
		if (typedName == "")
			typedName = "Player";
	}

	if (T != None)
		T.SetCoopPlayerName(typedName);

	if (lblActiveNameBanner != None)
	{
		lblActiveNameBanner.SetText("ACTIVE PLAYER NAME:  [ " $ typedName $ " ]  (APPLIED & SAVED!)");
		lblActiveNameBanner.SetTextColorRGB(110, 255, 150);
	}

	return typedName;
}

function String ApplyCurrentServerIP()
{
	local Trestkon T;
	local String typedIP;

	T = Trestkon(player);
	if (editServerIP != None)
		typedIP = editServerIP.CleanClipboardString(editServerIP.GetText());

	if (typedIP != "" && T != None)
		T.SetCoopLastServerIP(typedIP);

	return typedIP;
}

function StartJoinCurrentIP()
{
	local Trestkon T;
	local String chosenName, chosenIP;

	T = Trestkon(player);
	chosenName = ApplyCurrentPlayerName();
	chosenIP   = ApplyCurrentServerIP();

	if (chosenIP == "")
	{
		if (lblConnectStatus != None)
			lblConnectStatus.SetText("Please enter or paste a Server IP first.");
		if (editServerIP != None)
			SetFocusWindow(editServerIP);
		return;
	}

	if (lblConnectStatus != None)
		lblConnectStatus.SetText("");

	// Keep tnmMenuMain + CoopMultiplayerMenuWindow on the stack beneath
	// CoopConnectingWindow so Cancel / Timeout pops straight back here!
	if (T != None)
		T.JoinCoop(chosenIP);
}

function bool ButtonActivated(Window buttonPressed)
{
	local Trestkon T;
	local String chosenName;
	local int i;

	T = Trestkon(player);

	for (i = 0; i < 4; i++)
	{
		if (buttonPressed == btnSaveSlots[i])
		{
			selectedSlot = i;
			class'CoopSaveSlotManager'.static.SetActiveSlot(selectedSlot);
			RefreshHostButtons();
			return True;
		}
	}

	if (buttonPressed == btnApplyName)
	{
		ApplyCurrentPlayerName();
		return True;
	}

	if (buttonPressed == btnPasteIP)
	{
		if (editServerIP != None)
		{
			SetFocusWindow(editServerIP);
			if (editServerIP.PasteFromOSClipboard(True))
			{
				ApplyCurrentServerIP();
				if (lblConnectStatus != None)
					lblConnectStatus.SetText("");
			}
			else if (lblConnectStatus != None)
			{
				lblConnectStatus.SetText("Clipboard is empty.");
			}
		}
		return True;
	}

	if (buttonPressed == btnHostMain)
	{
		ApplyCurrentPlayerName();
		bHostSubMenuOpen = True;
		RefreshHostButtons();
		return True;
	}

	if (buttonPressed == btnHostNew)
	{
		chosenName = ApplyCurrentPlayerName();
		class'CoopSaveSlotManager'.static.SetActiveSlot(selectedSlot);
		class'CoopSaveSlotManager'.static.ClearSlot(selectedSlot);
		class'tnmGameInfo'.static.ClearCoopSessionDefaults();
		if (root != None)
			root.ClearWindowStack();
		if (T != None)
			T.HostCoop(T.strStartMap);
		return True;
	}

	if (buttonPressed == btnHostLoad)
	{
		chosenName = ApplyCurrentPlayerName();
		if (class'CoopSaveSlotManager'.static.LoadSlotIntoActiveSession(selectedSlot))
		{
			if (T != None)
				T.CoopContinue();
		}
		return True;
	}

	if (buttonPressed == btnJoinServer)
	{
		StartJoinCurrentIP();
		return True;
	}

	if (buttonPressed == btnCharSkin)
	{
		ApplyCurrentPlayerName();
		if (root != None)
			root.InvokeMenuScreen(Class'NarcissusWindow', True);
		return True;
	}

	if (buttonPressed == btnClose)
	{
		ApplyCurrentPlayerName();
		ApplyCurrentServerIP();
		if (root != None)
			root.PopWindow();
		return True;
	}

	return Super.ButtonActivated(buttonPressed);
}

defaultproperties
{
	ScreenType=ST_MenuScreen
}

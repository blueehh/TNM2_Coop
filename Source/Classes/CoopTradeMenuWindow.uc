//=============================================================================
// CoopTradeMenuWindow
// The Nameless Mod 2.0 - Co-op Mod by bluehh (TM)
//
// Split 2-button context bar & player-list popup inside PersonaScreenInventory:
//   - Left Button:  "Give Item..." (or "Drop Ammo" when Ammunition panel is open)
//   - Right Button: "Give Ammo..." (gives 1 clip/box of selected ammo or weapon ammo)
// Also makes each Ammo icon & row in the Ammunition panel clickable/selectable
// without covering winInfo (so "Show Ammo Descriptions" and scrolling work natively).
//=============================================================================
class CoopTradeMenuWindow extends Window;

var PersonaScreenInventory invScreen;
var PersonaButtonBarWindow winBar;
var PersonaActionButtonWindow btnTradeToggle;
var PersonaActionButtonWindow btnTradeAmmo;
var Window winPopup;
var PersonaNormalTextWindow txtHeader;
var PersonaActionButtonWindow btnPlayerSlot[4];
var Trestkon slotTargets[4];
var bool bPopupOpen;
var bool bTradingAmmo;

var DeusExAmmo selectedAmmo;
var int lastTotalAmmoRounds;
var int lastDisplayedCredits;
var String lastLeftLabel;
var String lastRightLabel;

event InitWindow()
{
	local int i;

	Super.InitWindow();

	invScreen = PersonaScreenInventory(GetParent().GetParent());
	if (invScreen == None)
		invScreen = PersonaScreenInventory(GetParent());

	// Strictly occupies ONLY the 22px button bar (Y=261..283) when popup is closed
	// so winInfo (Y=17..235) is never covered or blocked!
	SetPos(335, 261);
	SetSize(241, 22);

	winBar = PersonaButtonBarWindow(NewChild(Class'PersonaButtonBarWindow'));
	winBar.SetPos(0, 0);
	winBar.SetWidth(241);

	// Note: PersonaButtonBarWindow places GetTopChild() on the LEFT and GetLowerSibling() on the RIGHT.
	// Creating btnTradeAmmo first and btnTradeToggle second places:
	//   Left:  btnTradeToggle ("Give Item..." / "Drop Ammo")
	//   Right: btnTradeAmmo   ("Give Ammo...")
	btnTradeAmmo = PersonaActionButtonWindow(winBar.NewChild(Class'PersonaActionButtonWindow'));
	btnTradeAmmo.SetButtonText("Give |&Ammo...");
	btnTradeAmmo.SetSensitivity(False);
	lastRightLabel = "Give |&Ammo...";

	btnTradeToggle = PersonaActionButtonWindow(winBar.NewChild(Class'PersonaActionButtonWindow'));
	btnTradeToggle.SetButtonText("|&Give Item...");
	btnTradeToggle.SetSensitivity(False);
	lastLeftLabel = "|&Give Item...";

	winPopup = NewChild(Class'Window');
	winPopup.SetPos(0, 0);
	winPopup.SetSize(241, 114);
	winPopup.Hide();

	txtHeader = PersonaNormalTextWindow(winPopup.NewChild(Class'PersonaNormalTextWindow'));
	txtHeader.SetPos(6, 4);
	txtHeader.SetSize(228, 16);
	txtHeader.SetText("Select Player to Give Item (<= 5m):");

	for (i = 0; i < 4; i++)
	{
		btnPlayerSlot[i] = PersonaActionButtonWindow(winPopup.NewChild(Class'PersonaActionButtonWindow'));
		btnPlayerSlot[i].SetPos(4, 22 + (i * 21));
		btnPlayerSlot[i].SetWidth(233);
		btnPlayerSlot[i].Hide();
	}

	bPopupOpen = False;
	bTradingAmmo = False;
	lastTotalAmmoRounds = -1;
	lastDisplayedCredits = -1;
	bTickEnabled = True;
}

function SetPopupState(bool bOpen)
{
	bPopupOpen = bOpen;
	if (bOpen)
	{
		SetPos(335, 145);
		SetSize(241, 138);
		if (winBar != None)
			winBar.SetPos(0, 116);
		if (winPopup != None)
		{
			winPopup.SetPos(0, 0);
			winPopup.Show();
		}
		Raise();
	}
	else
	{
		if (winPopup != None)
			winPopup.Hide();
		SetPos(335, 261);
		SetSize(241, 22);
		if (winBar != None)
			winBar.SetPos(0, 0);
	}
}

event DrawWindow(GC gc)
{
	local Color borderCol;

	if (bPopupOpen && winPopup != None && winPopup.IsVisible())
	{
		borderCol.R = 12; borderCol.G = 16; borderCol.B = 24;
		gc.SetStyle(DSTY_Normal);
		gc.SetTileColor(borderCol);
		gc.DrawPattern(0, 0, 241, 114, 0, 0, Texture'Solid');
		borderCol.R = 100; borderCol.G = 200; borderCol.B = 255;
		gc.SetTileColor(borderCol);
		gc.DrawBox(0, 0, 241, 114, 0, 0, 1, Texture'Solid');
	}
	Super.DrawWindow(gc);
}

function bool IsAmmoCrateSelected()
{
	if (invScreen == None)
		return False;

	if (invScreen.selectedItem != None)
	{
		if (invScreen.winAmmo != None && invScreen.selectedItem.GetParent() == invScreen.winAmmo)
			return True;
		if (PersonaItemDetailButton(invScreen.selectedItem) != None &&
			PersonaItemDetailButton(invScreen.selectedItem).icon == Class'AmmoShell'.Default.LargeIcon)
			return True;
	}

	if (invScreen.winInfo != None && invScreen.winInfo.winTitle != None &&
		invScreen.winInfo.winTitle.GetText() == invScreen.AmmoTitleLabel)
		return True;

	return False;
}

function int ComputeTotalAmmoRounds(Trestkon myPlayer)
{
	local Inventory inv;
	local int total;

	if (myPlayer == None)
		return 0;

	for (inv = myPlayer.Inventory; inv != None; inv = inv.Inventory)
	{
		if (DeusExAmmo(inv) != None && DeusExAmmo(inv).bShowInfo)
			total += Max(0, DeusExAmmo(inv).AmmoAmount);
	}
	return total;
}

function ToggleWindow EnsureChildToggle(Window parentWin, DeusExAmmo ammoObj)
{
	local Window c;
	local ToggleWindow tog;

	if (parentWin == None)
		return None;

	for (c = parentWin.GetTopChild(); c != None; c = c.GetLowerSibling())
	{
		if (ToggleWindow(c) != None)
		{
			tog = ToggleWindow(c);
			break;
		}
	}

	if (tog == None)
		tog = ToggleWindow(parentWin.NewChild(Class'ToggleWindow'));

	if (tog != None)
	{
		tog.SetPos(0, 0);
		tog.SetSize(FMax(42.0, parentWin.width), FMax(37.0, parentWin.height));
		tog.SetClientObject(ammoObj);
	}
	return tog;
}

function UpdateAmmoRowButtons(Trestkon myPlayer, bool bAmmoPanelOpen)
{
	local Window w, topC, botC, subW, iconWin;
	local PersonaNormalTextWindow textWin;
	local ToggleWindow togIcon, togText;
	local bool bForward, bIsSelected;
	local Inventory inv;
	local DeusExAmmo nextAmmo, firstNonZeroAmmo, firstAnyAmmo;

	if (!bAmmoPanelOpen || myPlayer == None || invScreen == None || invScreen.winInfo == None || invScreen.winInfo.winTile == None)
		return;

	topC = invScreen.winInfo.winTile.GetTopChild();
	botC = invScreen.winInfo.winTile.GetBottomChild();
	if (topC == None)
	{
		selectedAmmo = None;
		return;
	}

	bForward = (topC.y <= botC.y);
	if (bForward)
		w = topC;
	else
		w = botC;

	inv = myPlayer.Inventory;

	// First pass: check if any ammo row's ToggleWindow was clicked this frame
	while (w != None)
	{
		if (w.IsA('AlignWindow'))
		{
			nextAmmo = None;
			while (inv != None)
			{
				if (DeusExAmmo(inv) != None && DeusExAmmo(inv).bShowInfo)
				{
					nextAmmo = DeusExAmmo(inv);
					inv = inv.Inventory;
					break;
				}
				inv = inv.Inventory;
			}

			if (nextAmmo != None)
			{
				if (firstAnyAmmo == None)
					firstAnyAmmo = nextAmmo;
				if (firstNonZeroAmmo == None && nextAmmo.AmmoAmount > 0)
					firstNonZeroAmmo = nextAmmo;

				iconWin = None;
				textWin = None;
				for (subW = w.GetTopChild(); subW != None; subW = subW.GetLowerSibling())
				{
					if (PersonaNormalTextWindow(subW) != None)
						textWin = PersonaNormalTextWindow(subW);
					else if (!subW.IsA('ToggleWindow'))
						iconWin = subW;
				}

				togIcon = EnsureChildToggle(iconWin, nextAmmo);
				togText = EnsureChildToggle(textWin, nextAmmo);

				if ((togIcon != None && togIcon.GetToggle()) || (togText != None && togText.GetToggle()))
				{
					selectedAmmo = nextAmmo;
					if (togIcon != None)
						togIcon.SetToggle(False);
					if (togText != None)
						togText.SetToggle(False);
				}
			}
		}

		if (bForward)
			w = w.GetLowerSibling();
		else
			w = w.GetHigherSibling();
	}

	// Ensure selectedAmmo is valid
	if (selectedAmmo != None && (selectedAmmo.bDeleteMe || selectedAmmo.Owner != myPlayer))
		selectedAmmo = None;
	if (selectedAmmo == None)
	{
		if (firstNonZeroAmmo != None)
			selectedAmmo = firstNonZeroAmmo;
		else
			selectedAmmo = firstAnyAmmo;
	}

	// Second pass: apply visual highlight to the selected ammo row (icon + text)
	if (bForward)
		w = topC;
	else
		w = botC;
	inv = myPlayer.Inventory;

	while (w != None)
	{
		if (w.IsA('AlignWindow'))
		{
			nextAmmo = None;
			while (inv != None)
			{
				if (DeusExAmmo(inv) != None && DeusExAmmo(inv).bShowInfo)
				{
					nextAmmo = DeusExAmmo(inv);
					inv = inv.Inventory;
					break;
				}
				inv = inv.Inventory;
			}

			if (nextAmmo != None)
			{
				bIsSelected = (nextAmmo == selectedAmmo);
				iconWin = None;
				textWin = None;
				for (subW = w.GetTopChild(); subW != None; subW = subW.GetLowerSibling())
				{
					if (PersonaNormalTextWindow(subW) != None)
						textWin = PersonaNormalTextWindow(subW);
					else if (!subW.IsA('ToggleWindow'))
						iconWin = subW;
				}

				togIcon = EnsureChildToggle(iconWin, nextAmmo);
				if (togIcon != None)
				{
					if (bIsSelected)
					{
						togIcon.SetBackground(Texture'Solid');
						togIcon.SetBackgroundStyle(DSTY_Translucent);
						togIcon.SetTileColorRGB(45, 95, 140);
					}
					else
					{
						togIcon.SetBackground(None);
					}
				}

				if (textWin != None)
				{
					if (bIsSelected)
						textWin.SetTextColorRGB(130, 235, 255);
					else
						textWin.SetTextColorRGB(170, 185, 205);
				}
			}
		}

		if (bForward)
			w = w.GetLowerSibling();
		else
			w = w.GetHigherSibling();
	}
}

function DeusExAmmo GetActiveAmmoItem(Trestkon myPlayer, Inventory selItem, bool bAmmoPanelOpen)
{
	local Class<Ammo> selAmmoClass;
	local DeusExWeapon weap;
	local DeusExAmmo foundAmmo;

	if (myPlayer == None)
		return None;

	if (bAmmoPanelOpen)
		return selectedAmmo;

	if (DeusExAmmo(selItem) != None)
		return DeusExAmmo(selItem);

	weap = DeusExWeapon(selItem);
	if (weap != None)
	{
		if (invScreen != None && invScreen.winInfo != None)
		{
			selAmmoClass = myPlayer.CoopGetLoadedAmmoButton(invScreen.winInfo);
			if (selAmmoClass != None)
			{
				foundAmmo = DeusExAmmo(myPlayer.FindInventoryType(selAmmoClass));
				if (foundAmmo != None && foundAmmo.AmmoAmount > 0)
					return foundAmmo;
			}
		}
		if (weap.AmmoType != None && DeusExAmmo(weap.AmmoType) != None)
			return DeusExAmmo(weap.AmmoType);
	}

	return None;
}

function Tick(float deltaTime)
{
	local Trestkon myPlayer;
	local Inventory selItem;
	local DeusExAmmo activeAmmo;
	local bool bAmmoPanelOpen, bCanLeftAction, bCanGiveAmmo, bPopupValid;
	local int curAmmoRounds;
	local String newLeftLabel;

	if (invScreen == None)
	{
		invScreen = PersonaScreenInventory(GetParent());
		if (invScreen == None && GetParent() != None)
			invScreen = PersonaScreenInventory(GetParent().GetParent());
	}

	myPlayer = Trestkon(GetPlayerPawn());
	bAmmoPanelOpen = IsAmmoCrateSelected();
	selItem = GetSelectedInventoryItem();

	// Keep Credits display live-updated for shared Co-op credits
	if (myPlayer != None && invScreen != None && invScreen.winCredits != None)
	{
		if (myPlayer.Credits != lastDisplayedCredits)
		{
			lastDisplayedCredits = myPlayer.Credits;
			invScreen.winCredits.SetCredits(myPlayer.Credits);
		}
	}

	// Auto-refresh Ammunition panel or Weapon info when ammo counts replicate/change
	curAmmoRounds = ComputeTotalAmmoRounds(myPlayer);
	if (lastTotalAmmoRounds != -1 && curAmmoRounds != lastTotalAmmoRounds && invScreen != None)
	{
		if (bAmmoPanelOpen)
			invScreen.UpdateAmmoDisplay();
		else if (DeusExWeapon(selItem) != None && invScreen.winInfo != None)
		{
			selItem.UpdateInfo(invScreen.winInfo);
			invScreen.EnableButtons();
		}
	}
	lastTotalAmmoRounds = curAmmoRounds;

	UpdateAmmoRowButtons(myPlayer, bAmmoPanelOpen);
	activeAmmo = GetActiveAmmoItem(myPlayer, selItem, bAmmoPanelOpen);
	bCanGiveAmmo = (activeAmmo != None && activeAmmo.AmmoAmount > 0);

	if (bAmmoPanelOpen)
	{
		newLeftLabel = "|&Drop Ammo";
		bCanLeftAction = bCanGiveAmmo;
	}
	else
	{
		newLeftLabel = "|&Give Item...";
		bCanLeftAction = (selItem != None && !selItem.IsA('NanoKeyRing') && !selItem.IsA('Fists'));
	}

	if (btnTradeToggle != None)
	{
		if (newLeftLabel != lastLeftLabel)
		{
			btnTradeToggle.SetButtonText(newLeftLabel);
			lastLeftLabel = newLeftLabel;
		}
		btnTradeToggle.SetSensitivity(bCanLeftAction);
	}

	if (btnTradeAmmo != None)
	{
		btnTradeAmmo.SetSensitivity(bCanGiveAmmo);
	}

	if (bTradingAmmo)
		bPopupValid = bCanGiveAmmo;
	else
		bPopupValid = (!bAmmoPanelOpen && bCanLeftAction);

	if (!bPopupValid && bPopupOpen)
	{
		SetPopupState(False);
	}
	else if (bPopupOpen)
	{
		RefreshPlayerSlots();
	}
}

function Inventory GetSelectedInventoryItem()
{
	local Inventory inv;

	if (invScreen == None)
		return None;

	if (invScreen.selectedItem != None)
	{
		inv = Inventory(invScreen.selectedItem.GetClientObject());
		if (inv != None)
			return inv;
	}

	if (invScreen.selectedSlot != None)
	{
		inv = Inventory(invScreen.selectedSlot.GetClientObject());
		if (inv != None)
			return inv;
	}

	return None;
}

function RefreshPlayerSlots()
{
	local Trestkon myPlayer, otherP;
	local int slotIdx, distMeters;
	local float distUU;
	local String btnLabel;

	myPlayer = Trestkon(GetPlayerPawn());
	if (myPlayer == None)
		return;

	slotIdx = 0;
	foreach myPlayer.AllActors(class'Trestkon', otherP)
	{
		if (otherP != myPlayer && slotIdx < 4)
		{
			slotTargets[slotIdx] = otherP;
			distUU = VSize(otherP.Location - myPlayer.Location);
			distMeters = int(distUU / 52.5);
			btnLabel = otherP.GetCoopPlayerName() $ " (" $ distMeters $ "m)";
			if (otherP.IsInState('Dying'))
				btnLabel = btnLabel $ " [DEAD]";
			else if (distUU > 265.0)
				btnLabel = btnLabel $ " [TOO FAR]";

			btnPlayerSlot[slotIdx].SetButtonText(btnLabel);
			btnPlayerSlot[slotIdx].SetSensitivity(!otherP.IsInState('Dying') && distUU <= 265.0);
			btnPlayerSlot[slotIdx].Show();
			slotIdx++;
		}
	}

	if (slotIdx == 0)
	{
		slotTargets[0] = None;
		btnPlayerSlot[0].SetButtonText("No other players found");
		btnPlayerSlot[0].SetSensitivity(False);
		btnPlayerSlot[0].Show();
		slotIdx = 1;
	}

	while (slotIdx < 4)
	{
		slotTargets[slotIdx] = None;
		btnPlayerSlot[slotIdx].Hide();
		slotIdx++;
	}
}

function bool ButtonActivated(Window buttonPressed)
{
	local int i;
	local Trestkon myPlayer;
	local Inventory selItem;
	local DeusExAmmo activeAmmo;
	local bool bAmmoPanelOpen;

	myPlayer = Trestkon(GetPlayerPawn());
	bAmmoPanelOpen = IsAmmoCrateSelected();

	// 1. Left Button: "Drop Ammo" (when Ammunition panel is open) OR "Give Item..."
	if (buttonPressed == btnTradeToggle)
	{
		if (bAmmoPanelOpen)
		{
			if (myPlayer != None && selectedAmmo != None && selectedAmmo.AmmoAmount > 0)
			{
				myPlayer.ServerCoopDropAmmo(selectedAmmo);
				if (invScreen != None)
					invScreen.UpdateAmmoDisplay();
			}
			return True;
		}

		if (bPopupOpen && !bTradingAmmo)
		{
			SetPopupState(False);
		}
		else
		{
			bTradingAmmo = False;
			if (txtHeader != None)
				txtHeader.SetText("Select Player to Give Item (<= 5m):");
			RefreshPlayerSlots();
			SetPopupState(True);
		}
		return True;
	}

	// 2. Right Button: "Give Ammo..."
	if (buttonPressed == btnTradeAmmo)
	{
		if (bPopupOpen && bTradingAmmo)
		{
			SetPopupState(False);
		}
		else
		{
			bTradingAmmo = True;
			if (txtHeader != None)
				txtHeader.SetText("Select Player to Give Ammo (<= 5m):");
			RefreshPlayerSlots();
			SetPopupState(True);
		}
		return True;
	}

	// 3. Player Slot clicked in Popup
	for (i = 0; i < 4; i++)
	{
		if (buttonPressed == btnPlayerSlot[i] && slotTargets[i] != None)
		{
			selItem = GetSelectedInventoryItem();
			if (myPlayer != None)
			{
				if (bTradingAmmo)
				{
					activeAmmo = GetActiveAmmoItem(myPlayer, selItem, bAmmoPanelOpen);
					if (activeAmmo != None && activeAmmo.AmmoAmount > 0)
					{
						myPlayer.ServerCoopTradeAmmo(activeAmmo, slotTargets[i]);
						SetPopupState(False);
						if (invScreen != None && bAmmoPanelOpen)
							invScreen.UpdateAmmoDisplay();
					}
				}
				else if (selItem != None)
				{
					myPlayer.ServerCoopTradeItem(selItem, slotTargets[i]);
					SetPopupState(False);
					if (invScreen != None)
					{
						invScreen.SelectInventory(None);
						invScreen.SignalRefresh();
					}
				}
			}
			return True;
		}
	}

	return Super.ButtonActivated(buttonPressed);
}

defaultproperties
{
}

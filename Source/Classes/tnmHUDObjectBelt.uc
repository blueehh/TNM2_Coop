//=============================================================================
// HUDObjectBelt
//=============================================================================
class tnmHUDObjectBelt extends HUDObjectBelt;

var Texture ExtraTexBorder[3];
var HUDobjectslot newobjects[12];

event InitWindow()
{
    Super(HUDBaseWindow).InitWindow();

    // Hardcoded size, baby!
    if (player != None && Trestkon(Player).bEnlargedBelt)
    {
        SetSize(645, 69);
    }
    else
    {
        SetSize(541, 69);
    }

    CreateSlots();
    CreateNanoKeySlot();

    PopulateBelt();
}

// ----------------------------------------------------------------------
// CreateSlots()
//
// Creates the Slots 
// ----------------------------------------------------------------------
/*
function CreateSlots()
{
	local int i;
	local RadioBoxWindow winRadio;

	// Radio window used to contain newobjects so they can be selected
	// with the mouse on the inventory screen.

	winRadio = RadioBoxWindow(NewChild(Class'RadioBoxWindow'));
	winRadio.SetSize(504, 54);
	winRadio.SetPos(10, 6);
	winRadio.bOneCheck = False;
	winSlots = TileWindow(winRadio.NewChild(Class'TileWindow'));
	winSlots.SetMargins(0, 0);
	winSlots.SetMinorSpacing(0);
	winSlots.SetOrder(ORDER_LeftThenUp);

	for (i=0; i<10; i++)
	{
		newobjects[i] = HUDobjectslot(winSlots.NewChild(Class'tnmHUDobjectslot'));
		newobjects[i].SetObjectNumber(i);
		newobjects[i].Lower();

		// Last item is a little shorter
		if ( i == 0 )
			newobjects[i].SetWidth(44);
	}
	newobjects[0].Lower();

}*/

// ----------------------------------------------------------------------
// AddObjectToBelt()
// ----------------------------------------------------------------------

function bool AddObjectToBelt(Inventory newItem, int pos, bool bOverride)
{
	local int  i;
    local int FirstPos;
	local bool retval;

	retval = true;

	if (newItem != None && ((newItem.IsA('WeaponFists')) || (newItem.IsA('WeaponMPFists'))))
		return False;
		
	if (TNMWeapon(newItem) != None && TNMWeapon(newItem).lastBeltPos > 0 && pos < 1)
		Pos = TNMWeapon(newItem).lastBeltPos;
	
	if ((newItem != None ) && (newItem.Icon != None))
	{
		// If this is the NanoKeyRing, force it into slot 0
		if (newItem.IsA('NanoKeyRing'))
		{
			ClearPosition(0);
			pos = 0;
		}

		if (  (!IsValidPos(pos)) || 
            (  (Player.Level.NetMode != NM_Standalone) && 
               (Player.bBeltIsMPInventory) && 
               (!newItem.TestMPBeltSpot(pos)) ) )
		{
			FirstPos = 1;
			if ((Player.Level.NetMode != NM_Standalone) && (Player.bBeltIsMPInventory))
				FirstPos = 0;
			for (i=FirstPos; IsValidPos(i); i++)
			{
				if ((newobjects[i].GetItem() == None) && ( (Player.Level.NetMode == NM_Standalone) || (!Player.bBeltIsMPInventory) || (newItem.TestMPBeltSpot(i))))
				{
					break;
				}
			}
			if (!IsValidPos(i))
			{
				if (bOverride)
					pos = 1;
			}
			else
			{
				pos = i;
			}
		}

		if (IsValidPos(pos))
		{
			// If there's already an object here, remove it
			if ( newobjects[pos].GetItem() != None )
				RemoveObjectFromBelt(newobjects[pos].GetItem());

			newobjects[pos].SetItem(newItem);
		}
		else
		{
			retval = false;
		}
	}
	else
		retval = false;

	// The inventory item needs to know it's in the object
	// belt, as well as the location inside the belt.  This is used
	// when traveling to a new map.
	if ((retVal) && (Player.Role == ROLE_Authority))
	{
		if ((!newItem.IsA('WeaponFists')) || (!newItem.IsA('WeaponMPFists')))
		{
			newItem.bInObjectBelt = True;
			newItem.beltPos = pos;
		}
		else
		{
			newItem.bInObjectBelt = False;
			newItem.beltPos = -1;
		}
	}

	UpdateInHand();

	return (retval);
}

function RemoveObjectFromBelt(Inventory item)
{
	local int i;
	local int StartPos;

	StartPos = 1;
	if ( (Player != None) && (Player.Level.NetMode != NM_Standalone) && (Player.bBeltIsMPInventory) )
		StartPos = 0;

	for (i=StartPos; IsValidPos(i); i++)
	{
		if (newobjects[i].GetItem() == item)
		{
			newobjects[i].SetItem(None);
			item.bInObjectBelt = False;
			item.beltPos = -1;
			if (TNMWeapon(item) != None)
				TNMWeapon(item).lastBeltPos = -1;

			break;
		}
	}
}

// ----------------------------------------------------------------------
// PopulateBelt()
//
// Looks through the player's inventory and rebuilds the object belt
// based on the inventory items.  This needs to be done after a load
// game
// ----------------------------------------------------------------------

function PopulateBelt()
{
	local Inventory anItem;
	local HUDObjectBelt belt;
	local DeusExPlayer player;

	// Get a pointer to the player
	player = DeusExPlayer(DeusExRootWindow(GetRootWindow()).parentPawn);
	if (player == None)
		return;

	CreateNanoKeySlot();

	for (anItem=player.Inventory; anItem!=None; anItem=anItem.Inventory)
		if ((anItem.bInObjectBelt) && (!anItem.IsA('WeaponMPFists')))
			AddObjectToBelt(anItem, anItem.beltPos, True);
		else
			continue;
}

// ----------------------------------------------------------------------
// CreateSlots()
//
// Creates the Slots
// ----------------------------------------------------------------------

function CreateSlots()
{
    local int i;
    local RadioBoxWindow winRadio;

    // Radio window used to contain newobjects so they can be selected
    // with the mouse on the inventory screen.

    winRadio = RadioBoxWindow(NewChild(Class'RadioBoxWindow'));
    if (player != None && Trestkon(Player).bEnlargedBelt)
        winRadio.SetSize(606, 54);
    else
        winRadio.SetSize(504, 54);
    winRadio.SetPos(10, 6);
    winRadio.bOneCheck = False;

    winSlots = TileWindow(winRadio.NewChild(Class'TileWindow'));
    winSlots.SetMargins(0, 0);
    winSlots.SetMinorSpacing(0);
    winSlots.SetOrder(ORDER_LeftThenUp);

    if (player != None && Trestkon(Player).bEnlargedBelt)
    {
        for (i=0; i<ArrayCount(newobjects); i++)
        {
            newobjects[i] = tnmHUDobjectslot(winSlots.NewChild(Class'tnmHUDobjectslot'));
            newobjects[i].SetObjectNumber(i);
            newobjects[i].Lower();

            // Last item is a little shorter
            if ( i == 0 )
                newobjects[i].SetWidth(44);
        }
    }
    else
    {
        for (i=0; i<(ArrayCount(newobjects) - 2); i++)
        {
            newobjects[i] = tnmHUDobjectslot(winSlots.NewChild(Class'tnmHUDobjectslot'));
            newobjects[i].SetObjectNumber(i);
            newobjects[i].Lower();

            // Last item is a little shorter
            if ( i == 0 )
                newobjects[i].SetWidth(44);
        }
    }

    newobjects[0].Lower();

}

// ----------------------------------------------------------------------
// DrawBackground()
// ----------------------------------------------------------------------

function DrawBackground(GC gc)
{
    local Color newBackground;

    gc.SetStyle(backgroundDrawStyle);

    if (( player != None ) && (player.Level.NetMode != NM_Standalone) && ( player.bBuySkills ))
    {
        newBackground.r = colBackground.r / 2;
        newBackground.g = colBackground.g / 2;
        newBackground.b = colBackground.b / 2;
        gc.SetTileColor(newBackground);
    }
    else
        gc.SetTileColor(colBackground);

    gc.DrawTexture(  2, 6, 9, 54, 0, 0, texBackgroundLeft);

    if (player != None && Trestkon(Player).bEnlargedBelt)
        gc.DrawTexture(616, 6, 8, 54, 0, 0, texBackgroundRight);
    else
        gc.DrawTexture(514, 6, 8, 54, 0, 0, texBackgroundRight);
}

function DrawBorder(GC gc)
{
    local Color newCol;

    if (bDrawBorder)
    {
        gc.SetStyle(borderDrawStyle);
        if (( player != None ) && ( player.bBuySkills ))
        {
            newCol.r = colBorder.r / 2;
            newCol.g = colBorder.g / 2;
            newCol.b = colBorder.b / 2;
            gc.SetTileColor(newCol);
        }
        else
            gc.SetTileColor(colBorder);

        if (player != None && Trestkon(Player).bEnlargedBelt)
        {
            gc.DrawTexture(  0, 0, 256, 69, 0, 0, ExtraTexBorder[0]);
            gc.DrawTexture(256, 0, 256, 69, 0, 0, ExtraTexBorder[1]);
            gc.DrawTexture(512, 0, 133, 69, 0, 0, ExtraTexBorder[2]);
        }
        else
        {
            gc.DrawTexture(  0, 0, 256, 69, 0, 0, texBorder[0]);
            gc.DrawTexture(256, 0, 256, 69, 0, 0, texBorder[1]);
            gc.DrawTexture(512, 0,  29, 69, 0, 0, texBorder[2]);
        }
    }
}

// ----------------------------------------------------------------------
// UpdateInHand()
//
// Called when the player's "inHand" variable changes
// ----------------------------------------------------------------------

function UpdateInHand()
{
    local int slotIndex;

    // highlight the slot and unhighlight the other slots
    if ((player != None) && (!bInteractive))
    {
        if (player != None && Trestkon(Player).bEnlargedBelt)
        {
            for (slotIndex=0; slotIndex<ArrayCount(newobjects); slotIndex++)
            {
                // Highlight the object in the player's hand
                if ((player.inHand != None) && (newobjects[slotIndex].item == player.inHand))
                    newobjects[slotIndex].HighlightSelect(True);
                else
                    newobjects[slotIndex].HighlightSelect(False);

                if ((player.inHandPending != None) && //(player.inHandPending != player.inHand) &&
                    (newobjects[slotIndex].item == player.inHandPending))
                    newobjects[slotIndex].SetToggle(true);
                else
                    newobjects[slotIndex].SetToggle(false);
            }
        }
        else
        {
            for (slotIndex=0; slotIndex<(ArrayCount(newobjects) - 2); slotIndex++)
            {
                // Highlight the object in the player's hand
                if ((player.inHand != None) && (newobjects[slotIndex].item == player.inHand))
                    newobjects[slotIndex].HighlightSelect(True);
                else
                    newobjects[slotIndex].HighlightSelect(False);

                if ((player.inHandPending != None) && //(player.inHandPending != player.inHand) &&
                    (newobjects[slotIndex].item == player.inHandPending))
                    newobjects[slotIndex].SetToggle(true);
                else
                    newobjects[slotIndex].SetToggle(false);
            }
        }
    }
}

// ----------------------------------------------------------------------
// IsValidPos()
// ----------------------------------------------------------------------

function bool IsValidPos(int pos)
{
    // Don't allow NanoKeySlot to be used
    if (player != None && Trestkon(Player).bEnlargedBelt)
    {
        if ((pos >= 0) && (pos < ArrayCount(newobjects)))
            return true;
        else
            return false;
    }
    else
    {
        if ((pos >= 0) && (pos < (ArrayCount(newobjects) - 2)))
            return true;
        else
            return false;
    }
}

function ClearBelt()
{
    local int beltPos;

    if (player != None && Trestkon(Player).bEnlargedBelt)
    {
        for(beltPos=0; beltPos<ArrayCount(newobjects); beltPos++)
            ClearPosition(beltPos);
    }
    else
    {
        for(beltPos=0; beltPos<(ArrayCount(newobjects) - 2); beltPos++)
            ClearPosition(beltPos);
    }
}

// ----------------------------------------------------------------------
// AssignWinInv()
// ----------------------------------------------------------------------

function AssignWinInv(PersonaScreenInventory newWinInventory)
{
    local Int slotIndex;

    // Update the individual slots
    if (player != None && Trestkon(Player).bEnlargedBelt)
    {
        for (slotIndex=0; slotIndex<ArrayCount(newobjects); slotIndex++)
        {
            newobjects[slotIndex].AssignWinInv(newWinInventory);
        }
    }
    else
    {
        for (slotIndex=0; slotIndex<(ArrayCount(newobjects) - 2); slotIndex++)
        {
            newobjects[slotIndex].AssignWinInv(newWinInventory);
        }
    }

    UpdateInHand();
}

// ----------------------------------------------------------------------
// ClearPosition()
// ----------------------------------------------------------------------

function ClearPosition(int pos)
{
    if (IsValidPos(pos))
        newobjects[pos].SetItem(None);
}

// ----------------------------------------------------------------------
// CreateNanoKeySlot()
//
// The last object slot contains the NanoKeyRing, which lets the user
// easily open doors for which they have the code (Know the code!)
// ----------------------------------------------------------------------

function CreateNanoKeySlot()
{
    if (player != None)
    {
        if (player.KeyRing != None)
        {
            newobjects[KeyRingSlot].SetItem(player.KeyRing);
            newobjects[KeyRingSlot].AllowDragging(False);
        }
    }
}

// ----------------------------------------------------------------------
// UpdateObjectText()
// ----------------------------------------------------------------------

function UpdateObjectText(int pos)
{
    // First find the object
    if (IsValidPos(pos))
        newobjects[pos].UpdateItemText();
}

// ----------------------------------------------------------------------
// GetObjectFromBelt()
// ----------------------------------------------------------------------

function Inventory GetObjectFromBelt(int pos)
{
    if (IsValidPos(pos))
        return (newobjects[pos].GetItem());
    else
        return (None);
}

defaultproperties
{
     ExtraTexBorder(0)=Texture'DeusExUI.UserInterface.HUDObjectBeltBorder_1'
     ExtraTexBorder(1)=Texture'TNM.UserInterface.TNMHUDObjectBeltBorder_2'
     ExtraTexBorder(2)=Texture'TNM.UserInterface.TNMHUDObjectBeltBorder_3'
}

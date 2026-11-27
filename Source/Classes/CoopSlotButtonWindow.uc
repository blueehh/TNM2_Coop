//=============================================================================
// CoopSlotButtonWindow
// The Nameless Mod 2.0 - Co-op Mod by bluehh (TM)
//
// Custom-sized clickable button used for selecting Co-op Save Slots (Slot 1..4)
// and custom-width UI actions without ToolButtonWindow's fixed 80px texture limit.
//=============================================================================
class CoopSlotButtonWindow extends ButtonWindow;

var String btnText;
var bool bSlotSelected;
var bool bHasSaveData;
var int slotIndex;

event InitWindow()
{
	Super.InitWindow();
}

function SetSlotInfo(int idx, String textStr, bool bSelected, bool bHasData)
{
	slotIndex = idx;
	btnText = textStr;
	bSlotSelected = bSelected;
	bHasSaveData = bHasData;
}

event DrawWindow(GC gc)
{
	local Color cFill, cBorder, cText;

	Super.DrawWindow(gc);

	gc.SetStyle(DSTY_Normal);

	if (bSlotSelected)
	{
		cFill.R = 45; cFill.G = 85; cFill.B = 55;
		cBorder.R = 110; cBorder.G = 245; cBorder.B = 140;
		cText.R = 255; cText.G = 255; cText.B = 255;
	}
	else if (bButtonPressed)
	{
		cFill.R = 50; cFill.G = 55; cFill.B = 75;
		cBorder.R = 180; cBorder.G = 200; cBorder.B = 240;
		cText.R = 255; cText.G = 255; cText.B = 255;
	}
	else
	{
		cFill.R = 24; cFill.G = 26; cFill.B = 36;
		cBorder.R = 110; cBorder.G = 120; cBorder.B = 145;
		if (bHasSaveData)
		{
			cText.R = 220; cText.G = 230; cText.B = 245;
		}
		else
		{
			cText.R = 150; cText.G = 160; cText.B = 175;
		}
	}

	gc.SetTileColor(cFill);
	gc.DrawPattern(0, 0, width, height, 0, 0, Texture'Solid');

	gc.SetTileColor(cBorder);
	gc.DrawBox(0, 0, width, height, 0, 0, 1, Texture'Solid');

	gc.SetFont(Font'FontMenuSmall_DS');
	gc.SetTextColor(cText);
	gc.SetHorizontalAlignment(HALIGN_Left);
	gc.SetVerticalAlignment(VALIGN_Center);
	gc.EnableWordWrap(False);
	gc.DrawText(6, 0, width - 10, height, btnText);
}

defaultproperties
{
}

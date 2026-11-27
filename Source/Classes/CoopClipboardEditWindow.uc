//=============================================================================
// CoopClipboardEditWindow
// The Nameless Mod 2.0 - Co-op Mod by bluehh (TM)
//
// Single-line ToolEditWindow subclass that:
//   - Works with the real Windows OS clipboard via PlayerPawn.PasteFromClipboard
//     and PlayerPawn.CopyToClipboard (Extension.dll's native EditWindow.Paste()
//     only reads an internal in-game TextBuffer and ignores the OS clipboard).
//   - Supports Ctrl+V / Shift+Insert (paste), Ctrl+C / Ctrl+Insert (copy),
//     Ctrl+X / Shift+Delete (cut), and Ctrl+A (select all).
//   - Prevents Enter from inserting newline characters into single-line fields.
//=============================================================================
class CoopClipboardEditWindow extends ToolEditWindow;

var bool bIsIPField;

event InitWindow()
{
	Super.InitWindow();

	EnableEditing(True);
	EnableSingleLineEditing(True);
	SetSensitivity(True);
	SetSelectability(True);
	SetFilter("");
}

function String CleanClipboardString(String raw)
{
	local String outStr, ch;
	local int i, qIdx;

	outStr = "";
	for (i = 0; i < Len(raw); i++)
	{
		ch = Mid(raw, i, 1);
		if (ch == Chr(13) || ch == Chr(10) || ch == Chr(9))
		{
			if (bIsIPField)
				continue;
			ch = " ";
		}
		outStr = outStr $ ch;
	}

	while (Len(outStr) > 0 && Left(outStr, 1) == " ")
		outStr = Mid(outStr, 1);
	while (Len(outStr) > 0 && Right(outStr, 1) == " ")
		outStr = Left(outStr, Len(outStr) - 1);

	if (bIsIPField)
	{
		if (Left(Caps(outStr), 9) == "DEUSEX://")
			outStr = Mid(outStr, 9);
		else if (Left(Caps(outStr), 9) == "UNREAL://")
			outStr = Mid(outStr, 9);

		qIdx = InStr(outStr, "/");
		if (qIdx != -1)
			outStr = Left(outStr, qIdx);
		qIdx = InStr(outStr, "?");
		if (qIdx != -1)
			outStr = Left(outStr, qIdx);
	}

	if (maxSize > 0 && Len(outStr) > maxSize)
		outStr = Left(outStr, maxSize);

	return outStr;
}

function bool PasteFromOSClipboard(optional bool bReplaceAll)
{
	local PlayerPawn P;
	local String clip;
	local int selStart, selCount;

	P = GetPlayerPawn();
	if (P == None)
		return False;

	clip = CleanClipboardString(P.PasteFromClipboard());
	if (clip == "")
		return False;

	if (bReplaceAll)
	{
		SetText(clip);
		MoveInsertionPoint(MOVEINSERT_EndOfLine);
		SetTextChangedFlag(True);
		return True;
	}

	GetSelectedArea(selStart, selCount);
	if (selCount > 0)
		DeleteChar(False, True);

	InsertText(clip, True);
	return True;
}

function CopySelectionToOSClipboard(bool bCut)
{
	local PlayerPawn P;
	local String fullText, subText;
	local int selStart, selCount;

	P = GetPlayerPawn();
	if (P == None)
		return;

	fullText = GetText();
	GetSelectedArea(selStart, selCount);
	if (selCount > 0)
		subText = Mid(fullText, selStart, selCount);
	else
		subText = fullText;

	if (subText != "")
		P.CopyToClipboard(subText);

	if (bCut && selCount > 0)
		DeleteChar(False, True);
}

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	local bool bCtrl, bShift;

	if (!IsEditingEnabled())
		return Super.VirtualKeyPressed(key, bRepeat);

	bCtrl  = IsKeyDown(IK_Ctrl) || IsKeyDown(IK_LControl) || IsKeyDown(IK_RControl);
	bShift = IsKeyDown(IK_Shift) || IsKeyDown(IK_LShift) || IsKeyDown(IK_RShift);

	if ((bCtrl && key == IK_V) || (bShift && key == IK_Insert))
	{
		if (PasteFromOSClipboard(False))
			PlayEditSound(typeSound);
		return True;
	}

	if ((bCtrl && key == IK_C) || (bCtrl && key == IK_Insert))
	{
		CopySelectionToOSClipboard(False);
		PlayEditSound(moveSound);
		return True;
	}

	if ((bCtrl && key == IK_X) || (bShift && key == IK_Delete))
	{
		CopySelectionToOSClipboard(True);
		PlayEditSound(deleteSound);
		return True;
	}

	if (bCtrl && key == IK_A)
	{
		SetSelectedArea(0, Len(GetText()));
		PlayEditSound(moveSound);
		return True;
	}

	if (key == IK_Enter)
		return False;

	return Super.VirtualKeyPressed(key, bRepeat);
}

defaultproperties
{
}

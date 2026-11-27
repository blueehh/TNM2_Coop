//=============================================================================
// CoopConnectingWindow
// The Nameless Mod 2.0 - Co-op Mod by bluehh (TM)
//
// Modal Co-op connection progress dialog that replaces stock DeusEx's
// cursorless MultiplayerMessageWin during `open <IP>` attempts:
//   - Keeps mouse cursor visible and provides a clickable Cancel button.
//   - Supports Esc / F10 / Close button to cancel immediately.
//   - Auto-detects instant DNS/socket failures and 12-second timeouts, issuing
//     CANCEL and returning cleanly to CoopMultiplayerMenuWindow (never softlocks).
//=============================================================================
class CoopConnectingWindow extends ToolWindow;

var TextWindow lblTargetIP;
var TextWindow lblStatus;
var TextWindow lblHint;
var ToolButtonWindow btnCancelConnect;

var String targetIP;
var float elapsedConnectTime;
var float maxConnectTimeout;
var bool bAborted;

event InitWindow()
{
	local Trestkon T;

	Super.InitWindow();

	bTickEnabled = True;
	maxConnectTimeout = 12.0;
	elapsedConnectTime = 0.0;
	bAborted = False;

	SetSize(380, 168);
	SetTitle("Connecting to Co-op Server");

	if (root != None)
		root.ShowCursor(True);

	T = Trestkon(player);
	if (T != None && T.coopConnectingIP != "")
		targetIP = T.coopConnectingIP;
	else if (player != None && player.ProgressMessage[1] != "" && InStr(player.ProgressMessage[1], "<?int?") == -1)
		targetIP = player.ProgressMessage[1];
	else
		targetIP = "Server";

	lblTargetIP = CreateToolLabel(22, 36, "Target Server:  " $ targetIP);
	if (lblTargetIP != None)
		lblTargetIP.SetTextColorRGB(185, 225, 255);

	lblStatus = CreateToolLabel(22, 64, "Contacting server... (0s / 12s)");
	if (lblStatus != None)
		lblStatus.SetTextColorRGB(235, 240, 250);

	lblHint = CreateToolLabel(22, 90, "Press ESC or click Cancel to abort.");
	if (lblHint != None)
		lblHint.SetTextColorRGB(165, 180, 205);

	btnCancelConnect = CreateToolButton(150, 124, "|&Cancel");
}

event DrawWindow(GC gc)
{
	local Color cFill, cBorder;

	Super.DrawWindow(gc);

	gc.SetStyle(DSTY_Normal);
	cFill.R = 14; cFill.G = 22; cFill.B = 38;
	gc.SetTileColor(cFill);
	gc.DrawPattern(14, 28, 352, 84, 0, 0, Texture'Solid');
	cBorder.R = 65; cBorder.G = 135; cBorder.B = 245;
	gc.SetTileColor(cBorder);
	gc.DrawBox(14, 28, 352, 84, 0, 0, 1, Texture'Solid');
}

event Tick(float deltaSeconds)
{
	local String failDetail;
	local int secs;

	if (bAborted || player == None)
		return;

	if (root != None)
		root.ShowCursor(True);

	// If we already connected as a client, close this overlay immediately
	if (player.Level.NetMode == NM_Client)
	{
		bAborted = True;
		player.ProgressTimeOut = 0;
		if (Trestkon(player) != None)
			Trestkon(player).bCoopPendingConnect = False;
		if (root != None)
			root.ClearWindowStack();
		return;
	}

	elapsedConnectTime += deltaSeconds;

	// If the engine aborted GPendingLevel (e.g. invalid IP / DNS failure / refused),
	// LevelAction drops out of LEVACT_Connecting back to LEVACT_None while still standalone.
	if (elapsedConnectTime > 0.6 && player.Level.LevelAction != LEVACT_Connecting && player.Level.NetMode == NM_Standalone)
	{
		failDetail = "";
		if (player.ProgressMessage[1] != "" && InStr(player.ProgressMessage[1], "<?int?") == -1 && InStr(Caps(player.ProgressMessage[1]), Caps(targetIP)) == -1)
			failDetail = player.ProgressMessage[1];
		else if (player.ProgressMessage[0] != "" && InStr(player.ProgressMessage[0], "<?int?") == -1 && InStr(Caps(player.ProgressMessage[0]), "CONNECTING") == -1)
			failDetail = player.ProgressMessage[0];

		if (failDetail != "")
			AbortConnect("Failed (" $ targetIP $ "): " $ failDetail);
		else
			AbortConnect("Could not connect to " $ targetIP $ " (invalid or unreachable IP).");
		return;
	}

	if (elapsedConnectTime >= maxConnectTimeout)
	{
		AbortConnect("Timed out connecting to " $ targetIP $ " (no response).");
		return;
	}

	player.ProgressTimeOut = player.Level.TimeSeconds + 2.0;
	secs = int(elapsedConnectTime);
	if (lblStatus != None)
		lblStatus.SetText("Waiting for server response... (" $ secs $ "s / " $ int(maxConnectTimeout) $ "s)");
}

function AbortConnect(String reason)
{
	local Trestkon T;

	if (bAborted)
		return;
	bAborted = True;

	T = Trestkon(player);
	if (player != None)
	{
		player.ConsoleCommand("CANCEL");
		player.ProgressTimeOut = 0;
		player.ClearProgressMessages();
	}
	if (T != None)
	{
		T.bCoopPendingConnect = False;
		T.coopLastConnectError = reason;
	}

	if (root != None)
	{
		root.PopWindow(True);
		root.ShowCursor(True);

		if (root.GetTopWindow() == None && root.AtIntroMap() && T != None)
		{
			T.ShowMainMenu();
			root.InvokeMenuScreen(Class'CoopMultiplayerMenuWindow', True);
		}
		else if (CoopMultiplayerMenuWindow(root.GetTopWindow()) != None)
		{
			CoopMultiplayerMenuWindow(root.GetTopWindow()).OnConnectAborted(reason);
		}
	}
}

function bool ButtonActivated(Window buttonPressed)
{
	if (buttonPressed == btnCancelConnect || (winTitleBar != None && buttonPressed == winTitleBar.btnClose))
	{
		AbortConnect("Connection cancelled.");
		return True;
	}
	return Super.ButtonActivated(buttonPressed);
}

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	if (key == IK_Escape || key == IK_F10)
	{
		AbortConnect("Connection cancelled.");
		return True;
	}
	return Super.VirtualKeyPressed(key, bRepeat);
}

defaultproperties
{
	ScreenType=ST_MenuScreen
}

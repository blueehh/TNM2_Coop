//=============================================================================
// CoopMainMenuHookWindow
// The Nameless Mod 2.0 - Co-op Mod by bluehh (TM)
//
// Persistent Main Menu / Pause Menu UI injector:
//  1) Acts as a lightweight root watcher on DeusExRootWindow (bTickEnabled=True)
//     so whenever tnmMenuMain is on top (even after PopWindow while paused),
//     it ensures the "Multiplayer" button is injected.
//  2) Acts as the injected button container inside tnmMenuMain.winClient.
//=============================================================================
class CoopMainMenuHookWindow extends Window;

var MenuUIMenuButtonWindow btnMultiplayer;
var bool bIsRootWatcher;

function SetupAsRootWatcher()
{
	bIsRootWatcher = True;
	bTickEnabled = True;
	SetPos(0, 0);
	SetSize(1, 1);
	SetSensitivity(False);
}

function SetupButton(Class<MenuUIMenuButtonWindow> btnClass, int btnWidth)
{
	if (btnMultiplayer != None)
		return;

	if (btnClass == None)
		btnClass = Class'MenuUIMenuButtonWindow';

	btnMultiplayer = MenuUIMenuButtonWindow(NewChild(btnClass));
	if (btnMultiplayer != None)
	{
		btnMultiplayer.SetPos(0, 0);
		btnMultiplayer.SetWidth(btnWidth);
		btnMultiplayer.SetButtonText("Multiplayer");
		btnMultiplayer.SetSensitivity(True);
	}
}

event Tick(float deltaSeconds)
{
	CheckMainMenuHook();
}

event DrawWindow(GC gc)
{
	Super.DrawWindow(gc);
	CheckMainMenuHook();
}

function CheckMainMenuHook()
{
	local DeusExRootWindow root;
	local Trestkon P;

	if (!bIsRootWatcher)
		return;

	root = DeusExRootWindow(GetRootWindow());
	if (root != None && MenuUIMenuWindow(root.GetTopWindow()) != None && root.GetTopWindow().IsA('tnmMenuMain'))
	{
		P = Trestkon(GetPlayerPawn());
		if (P != None)
			P.InjectCoopMainMenuButton(MenuUIMenuWindow(root.GetTopWindow()));
	}
}

function bool ButtonActivated(Window buttonPressed)
{
	local DeusExRootWindow root;

	if (buttonPressed == btnMultiplayer)
	{
		root = DeusExRootWindow(GetRootWindow());
		if (root != None)
			root.InvokeMenuScreen(Class'CoopMultiplayerMenuWindow', True);
		return True;
	}

	return Super.ButtonActivated(buttonPressed);
}

defaultproperties
{
}

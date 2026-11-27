//=============================================================================
// CoopChatDisplayWindow
// The Nameless Mod 2.0 - Co-op Mod by bluehh (TM)
//
// Non-interactive HUD anchor attached to DeusExHUD that manages and positions
// CoopChatPanelWindow above the lower-left Ammo HUD panel, tracks live Talk /
// TeamTalk typing state, and keeps player chat visible even during InfoLinks.
//=============================================================================
class CoopChatDisplayWindow extends Window;

var CoopChatPanelWindow chatPanel;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------
event InitWindow()
{
	Super.InitWindow();

	SetWindowAlignments(HALIGN_Full, VALIGN_Full);
	SetSensitivity(False);
	bTickEnabled = True;

	chatPanel = CoopChatPanelWindow(NewChild(Class'CoopChatPanelWindow'));
	if (chatPanel != None)
		chatPanel.Hide();

	AskParentForReconfigure();
}

// ----------------------------------------------------------------------
// AddChatMessage()
// ----------------------------------------------------------------------
function AddChatMessage(String senderName, String chatBody, bool bFromSelf)
{
	local PlayerPawn PP;
	local float nowSec;

	if (chatPanel == None)
		return;

	PP = GetPlayerPawn();
	if (PP != None && PP.Level != None)
		nowSec = PP.Level.TimeSeconds;

	chatPanel.PushMessage(senderName, chatBody, bFromSelf, nowSec);
	chatPanel.Show();
}

// ----------------------------------------------------------------------
// UpdateTypingState()
// Detects stock UE1 Talk ('T') and TeamTalk ('Y') console typing states
// so the native HUD chat feed pops open immediately with a live input row.
// ----------------------------------------------------------------------
function UpdateTypingState(PlayerPawn PP)
{
	local Console C;
	local String rawTyped, upperTyped;

	if (chatPanel == None)
		return;

	chatPanel.bTypingActive = False;
	chatPanel.bTypingTeam   = False;
	chatPanel.liveTypedText = "";

	if (PP == None || PP.Player == None || PP.Player.Console == None)
		return;

	C = PP.Player.Console;
	if (!C.IsInState('Typing'))
		return;

	rawTyped   = C.TypedStr;
	upperTyped = Caps(rawTyped);

	if (Left(upperTyped, 4) == "SAY ")
	{
		chatPanel.bTypingActive = True;
		chatPanel.bTypingTeam   = False;
		chatPanel.liveTypedText = Mid(rawTyped, 4);
	}
	else if (Left(upperTyped, 8) == "TEAMSAY ")
	{
		chatPanel.bTypingActive = True;
		chatPanel.bTypingTeam   = True;
		chatPanel.liveTypedText = Mid(rawTyped, 8);
	}
}

// ----------------------------------------------------------------------
// Tick()
// ----------------------------------------------------------------------
event Tick(float deltaSeconds)
{
	local PlayerPawn PP;
	local float nowSec;

	if (chatPanel == None)
		return;

	PP = GetPlayerPawn();
	if (PP != None && PP.Level != None)
		nowSec = PP.Level.TimeSeconds;

	UpdateTypingState(PP);

	if (!chatPanel.bTypingActive && chatPanel.chatHoldTimer > 0.0)
		chatPanel.chatHoldTimer = FMax(0.0, chatPanel.chatHoldTimer - deltaSeconds);

	if (chatPanel.ShouldDisplayPanel(nowSec))
	{
		if (!chatPanel.IsVisible())
			chatPanel.Show();
	}
	else
	{
		if (chatPanel.IsVisible())
			chatPanel.Hide();
	}
}

// ----------------------------------------------------------------------
// DrawWindow()
// Dynamically sizes & positions chatPanel right above HUDAmmoDisplay on
// the lower-left HUD, avoiding overlap with Hit/Compass or ConWindows.
// ----------------------------------------------------------------------
event DrawWindow(GC gc)
{
	local DeusExRootWindow root;
	local PlayerPawn PP;
	local float nowSec, panelW, panelH, posX, posY, bottomAnchor, minTopY;

	if (chatPanel != None && chatPanel.IsVisible())
	{
		PP = GetPlayerPawn();
		if (PP != None && PP.Level != None)
			nowSec = PP.Level.TimeSeconds;

		panelW = FClamp(width * 0.34, 240.0, 330.0);
		panelH = chatPanel.ComputeDesiredHeight(gc, panelW, nowSec);

		posX = 4.0;
		bottomAnchor = height - 84.0;
		minTopY = 152.0;

		root = DeusExRootWindow(GetRootWindow());
		if (root != None && root.hud != None)
		{
			if (root.hud.ammo != None && root.hud.ammo.IsVisible())
				bottomAnchor = height - root.hud.ammo.height - 8.0;
			else
				bottomAnchor = height - 12.0;

			// If a narrow 4:3 screen has an active bottom-center convo/bark box that
			// reaches near the left column, float the chat box cleanly above it.
			if (root.hud.conWindow != None && root.hud.conWindow.IsVisible() && root.hud.conWindow.x < (posX + panelW + 8.0))
				bottomAnchor = FMin(bottomAnchor, root.hud.conWindow.y - 6.0);
			if (root.hud.barkDisplay != None && root.hud.barkDisplay.IsVisible() && root.hud.barkDisplay.x < (posX + panelW + 8.0))
				bottomAnchor = FMin(bottomAnchor, root.hud.barkDisplay.y - 6.0);
		}

		posY = FMax(minTopY, bottomAnchor - panelH);
		chatPanel.ConfigureChild(posX, posY, panelW, panelH);
	}

	Super.DrawWindow(gc);
}

defaultproperties
{
}

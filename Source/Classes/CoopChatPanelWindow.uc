//=============================================================================
// CoopChatPanelWindow
// The Nameless Mod 2.0 - Co-op Mod by bluehh (TM)
//
// Native Deus Ex / TNM HUD chat panel extending HUDSharedBorderWindow so it
// inherits the game's authentic 9-slice beveled HUD borders (texBorders),
// translucent inner fill (texBackgrounds), LogIcon badge, and live HUD Color
// Theme (TNM Blue, PDX, WorldCorp, Gold, Cyan, etc.).
//=============================================================================
class CoopChatPanelWindow extends HUDSharedBorderWindow;

const MAX_CHAT_HISTORY = 6;

var Window     winIcon;
var TextWindow winHeader;
var Window     winDivider;

var String historySender[6];
var String historyText[6];
var byte   historyIsSelf[6];
var float  historyTimestamp[6];
var int    historyCount;

var bool   bTypingActive;
var bool   bTypingTeam;
var String liveTypedText;
var float  chatHoldTimer;
var float  messageLifetime;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------
event InitWindow()
{
	Super.InitWindow();

	SetSensitivity(False);
	messageLifetime = 12.0;
	chatHoldTimer   = 0.0;
	historyCount    = 0;

	CreateNativeControls();
	StyleChanged();
}

// ----------------------------------------------------------------------
// CreateNativeControls()
// Builds the authentic Deus Ex HUD header icon, title text, and 1px rule
// matching HUDLogDisplay and HUDInfoLinkDisplay.
// ----------------------------------------------------------------------
function CreateNativeControls()
{
	winIcon = NewChild(Class'Window');
	winIcon.SetPos(12, topMargin + 2);
	winIcon.SetSize(16, 16);
	winIcon.SetBackgroundStyle(DSTY_Masked);
	winIcon.SetBackground(Texture'LogIcon');
	winIcon.SetSensitivity(False);

	winHeader = TextWindow(NewChild(Class'TextWindow'));
	winHeader.SetPos(32, topMargin + 2);
	winHeader.SetSize(200, 14);
	winHeader.SetTextMargins(0, 0);
	winHeader.SetTextAlignments(HALIGN_Left, VALIGN_Center);
	winHeader.SetFont(Font'FontMenuHeaders_DS');
	winHeader.SetText("CO-OP COMMS");
	winHeader.SetSensitivity(False);

	winDivider = NewChild(Class'Window');
	winDivider.SetPos(12, topMargin + 19);
	winDivider.SetSize(240, 1);
	winDivider.SetBackgroundStyle(DSTY_Normal);
	winDivider.SetBackground(Texture'Solid');
	winDivider.SetSensitivity(False);
}

// ----------------------------------------------------------------------
// StyleChanged()
// Syncs icon, header, and divider colors whenever the player switches HUD
// color themes or border translucency settings.
// ----------------------------------------------------------------------
event StyleChanged()
{
	Super.StyleChanged();

	if (winIcon != None)
		winIcon.SetTileColor(colHeaderText);
	if (winHeader != None)
		winHeader.SetTextColor(colHeaderText);
	if (winDivider != None)
		winDivider.SetTileColor(colBorder);
}

// ----------------------------------------------------------------------
// PushMessage()
// Appends a chat message into the rolling 6-message buffer and wakes the
// HUD panel for messageLifetime seconds.
// ----------------------------------------------------------------------
function PushMessage(String senderName, String chatBody, bool bFromSelf, float nowSeconds)
{
	local int i;

	if (chatBody == "")
		return;
	if (senderName == "")
		senderName = "Player";

	if (historyCount >= MAX_CHAT_HISTORY)
	{
		for (i = 0; i < MAX_CHAT_HISTORY - 1; i++)
		{
			historySender[i]    = historySender[i + 1];
			historyText[i]      = historyText[i + 1];
			historyIsSelf[i]    = historyIsSelf[i + 1];
			historyTimestamp[i] = historyTimestamp[i + 1];
		}
		historyCount = MAX_CHAT_HISTORY - 1;
	}

	historySender[historyCount]    = senderName;
	historyText[historyCount]      = chatBody;
	if (bFromSelf)
		historyIsSelf[historyCount] = 1;
	else
		historyIsSelf[historyCount] = 0;
	historyTimestamp[historyCount] = nowSeconds;
	historyCount++;

	chatHoldTimer = messageLifetime;
}

// ----------------------------------------------------------------------
// ComputeDesiredHeight()
// Measures wrapped message rows + optional live typing prompt so the
// 9-slice HUDSharedBorderWindow frame wraps the active chat tightly.
// ----------------------------------------------------------------------
function float ComputeDesiredHeight(GC gc, float panelWidth, float nowSeconds)
{
	local int i;
	local float innerW, rowW, rowH, totalH;
	local String fullLine;

	if (winDivider != None)
		winDivider.SetSize(FMax(64.0, panelWidth - 24.0), 1.0);
	if (winHeader != None)
		winHeader.SetSize(FMax(64.0, panelWidth - 44.0), 14.0);

	innerW = FMax(100.0, panelWidth - 26.0);
	totalH = topMargin + 24.0;

	gc.SetFont(Font'FontMenuSmall_DS');
	gc.EnableWordWrap(True);

	for (i = 0; i < historyCount; i++)
	{
		if (!bTypingActive && (nowSeconds - historyTimestamp[i]) > messageLifetime)
			continue;

		fullLine = historySender[i] $ ": " $ historyText[i];
		gc.GetTextExtent(innerW, rowW, rowH, fullLine);
		totalH += FMax(13.0, rowH) + 3.0;
	}

	if (bTypingActive)
	{
		fullLine = "> Say: " $ liveTypedText $ "_";
		gc.GetTextExtent(innerW, rowW, rowH, fullLine);
		totalH += FMax(14.0, rowH) + 8.0;
	}

	totalH += FMax(8.0, bottomMargin);
	return FMax(float(minHeight), totalH);
}

// ----------------------------------------------------------------------
// ShouldDisplayPanel()
// ----------------------------------------------------------------------
function bool ShouldDisplayPanel(float nowSeconds)
{
	local int i;

	if (bTypingActive)
		return True;
	if (chatHoldTimer <= 0.0)
		return False;

	for (i = 0; i < historyCount; i++)
	{
		if ((nowSeconds - historyTimestamp[i]) <= messageLifetime)
			return True;
	}
	return False;
}

// ----------------------------------------------------------------------
// DrawWindow()
// Renders the native 9-slice HUD border/background via Super, followed by
// color-coded [Sender]: Message lines and optional live typing prompt.
// ----------------------------------------------------------------------
event DrawWindow(GC gc)
{
	local int i;
	local float nowSeconds, curY, innerX, innerW, prefixW, prefixH, lineW, lineH;
	local String prefixStr, fullLine, promptPrefix, cursorChar;
	local Color cSender, cBody, cRule;

	// Refresh theme colors smoothly in case HUD theme changed
	StyleChanged();
	Super.DrawWindow(gc);

	if (player != None && player.Level != None)
		nowSeconds = player.Level.TimeSeconds;

	innerX = 13.0;
	innerW = FMax(100.0, width - 26.0);
	curY   = topMargin + 24.0;

	// Boost body text readability while preserving the player's HUD theme tint
	cBody.R = Max(225, int(colText.R));
	cBody.G = Max(230, int(colText.G));
	cBody.B = Max(235, int(colText.B));

	gc.SetStyle(DSTY_Normal);
	gc.SetFont(Font'FontMenuSmall_DS');
	gc.SetAlignments(HALIGN_Left, VALIGN_Top);

	for (i = 0; i < historyCount; i++)
	{
		if (!bTypingActive && (nowSeconds - historyTimestamp[i]) > messageLifetime)
			continue;

		prefixStr = historySender[i] $ ": ";
		fullLine  = prefixStr $ historyText[i];

		gc.EnableWordWrap(True);
		gc.GetTextExtent(innerW, lineW, lineH, fullLine);

		// Draw full wrapped line in crisp body color first, then overdraw the
		// sender prefix in a distinct Co-op highlight color for instant clarity
		gc.SetTextColor(cBody);
		gc.DrawText(innerX, curY, innerW, lineH + 2.0, fullLine);

		if (historyIsSelf[i] != 0)
		{
			cSender.R = 125; cSender.G = 255; cSender.B = 165;
		}
		else
		{
			cSender.R = 95;  cSender.G = 225; cSender.B = 255;
		}
		gc.EnableWordWrap(False);
		gc.GetTextExtent(0, prefixW, prefixH, prefixStr);
		gc.SetTextColor(cSender);
		gc.DrawText(innerX, curY, FMin(innerW, prefixW + 2.0), prefixH + 2.0, prefixStr);

		curY += FMax(13.0, lineH) + 3.0;
	}

	if (bTypingActive)
	{
		curY += 2.0;
		cRule = colBorder;
		gc.SetTileColor(cRule);
		gc.DrawPattern(innerX, curY, innerW, 1.0, 0, 0, Texture'Solid');
		curY += 5.0;

		if ((int(nowSeconds * 2.5) % 2) == 0)
			cursorChar = "_";
		else
			cursorChar = " ";

		if (bTypingTeam)
			promptPrefix = "> Team: ";
		else
			promptPrefix = "> Say: ";

		fullLine = promptPrefix $ liveTypedText $ cursorChar;
		gc.EnableWordWrap(True);
		gc.GetTextExtent(innerW, lineW, lineH, fullLine);

		gc.SetTextColor(cBody);
		gc.DrawText(innerX, curY, innerW, lineH + 2.0, fullLine);

		gc.EnableWordWrap(False);
		gc.GetTextExtent(0, prefixW, prefixH, promptPrefix);
		gc.SetTextColor(colHeaderText);
		gc.DrawText(innerX, curY, FMin(innerW, prefixW + 2.0), prefixH + 2.0, promptPrefix);
	}
}

defaultproperties
{
	minHeight=44
	topMargin=7
	bottomMargin=7
}

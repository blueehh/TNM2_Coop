class MessageSelfDestroy extends MenuUIMessageBoxWindow;

event InitWindow()
{
	local string savedMap;

	Super.InitWindow();
	if (player != None && player.Level.NetMode != NM_Standalone)
	{
		savedMap = class'tnmGameInfo'.default.SavedCurrentURL;
		if (savedMap == "" && player.GetLevelInfo() != None)
			savedMap = player.GetLevelInfo().mapName;
		SetTitle("Load Co-op Game");
		SetMessageText("Co-op Save Slot 1: " $ savedMap $ chr(10) $ chr(10) $ "Load this Co-op save now?");
		SetMode(0);
		SetNotifyWindow(Self);
	}
}

event bool BoxOptionSelected(Window Box, int ButtonNumber)
{
	if (Box == Self && player != None && player.Level.NetMode != NM_Standalone)
	{
		if (ButtonNumber == 0)
		{
			if (root != None)
				root.ClearWindowStack();
			if (Trestkon(player) != None)
				Trestkon(player).CoopContinue();
			return True;
		}
		if (root != None)
			root.PopWindow();
		return True;
	}
	return False;
}

function PostResult( int buttonNumber )
{
	super.PostResult(buttonNumber);
	if (root != None)
		root.PopWindow();
}

defaultproperties
{
}

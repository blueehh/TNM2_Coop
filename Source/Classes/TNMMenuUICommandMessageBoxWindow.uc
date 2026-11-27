//=============================================================================
// TNMMenuUICommandMessageBoxWindow
//=============================================================================
class TNMMenuUICommandMessageBoxWindow extends MenuUIMessageBoxWindow;

var String ConsoleCommands[16];

event InitWindow()
{
    local string savedMap;

    Super.InitWindow();
    if (player != None && player.Level.NetMode != NM_Standalone && ConsoleCommands[0] == "")
    {
        if (Trestkon(player) != None)
            Trestkon(player).CoopSave();
        savedMap = class'tnmGameInfo'.default.SavedCurrentURL;
        if (savedMap == "" && player.GetLevelInfo() != None)
            savedMap = player.GetLevelInfo().mapName;
        if (player.GetLevelInfo() != None && player.GetLevelInfo().mapName != "")
            savedMap = player.GetLevelInfo().mapName;
        SetTitle("Co-op Game Saved");
        SetMessageText("Saved Co-op Campaign to Slot 1:" $ chr(10) $ savedMap);
        SetMode(1);
        SetNotifyWindow(Self);
    }
}

// ----------------------------------------------------------------------
// BoxOptionSelected()
// ----------------------------------------------------------------------
event bool BoxOptionSelected(Window Box, int ButtonNumber)
{
    local int i;

    log(Self $ "BoxOptionSelected(" $ Box $ ", " $ ButtonNumber $ ")", 'DevRF');

    if (player != None && player.Level.NetMode != NM_Standalone && ConsoleCommands[0] == "")
    {
        if (DeusExRootWindow(GetRootWindow()) != None)
            DeusExRootWindow(GetRootWindow()).ClearWindowStack();
        return True;
    }

    if (Box == Self)
    {
        if (ButtonNumber == 0)
        {
            for (i=0; i < ArrayCount(ConsoleCommands); i++)
            {
                if (ConsoleCommands[i] != "")
                    Player.ConsoleCommand(ConsoleCommands[i]);
            }
        }
    }

    // Destroy the msgbox and config window.
    DeusExRootWindow(GetRootWindow()).PopWindow();
    return True;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
}

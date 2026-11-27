class tnmmissionstealth extends tnmmissionscript;

var float failTime;
var float winTime;
var localized string beatPar, overPar;
var deusexmover EndMov;
var bool bParTimeBeat;
var SkyZoneInfo SkyBoxInfo;

function firstframe()
{
    local TNMTimer Timer;
    local bool bCreateTimer;
    local bool bTimeCountUp;
    local DeusExMover M;
    local Inventory item, nextItem, anItem;
    local Skill aSkill;
	local securitycamera cam;
	local TNMPawn SP;
	local SkyZoneInfo sky;
	
	Super.FirstFrame();

    bCreateTimer = (!flags.GetBool('bChallengeTimerCreated'));
    Player.ServerSetSloMo(1);
	
	foreach AllActors(class'SkyZoneInfo', sky)
	{
		if (Sky.Tag == 'Stealth9SkyZoneInfo')
			SkyBoxInfo = Sky;
		break;
	}
	
	if (bCreateTimer)
    {
        Timer = Spawn( class'TNMTimer', ,, Player.Location, Rot(16384,0,0));

        if (Timer != None)
        {
			bTimeCountUp = True;

            // RevJCDentonMale(Player).RevChallengeSystem.bLookForTimer = True;

            if (bTimeCountUp)
            {
                Timer.bCountDown = False;
				switch (localURL)
				{
					case "95_STEALTH1":
						switch(Trestkon(Player).stealthDifficulty)
						{
							case 1:
								if (Trestkon(player).stealth1ParTimeNormal != 0 && Trestkon(player).stealth1ParTimeNormal < Trestkon(player).default.stealth1ParTimeNormal)
									Timer.parTime = Trestkon(player).stealth1ParTimeNormal;
								else
									Timer.parTime = Trestkon(player).default.stealth1ParTimeNormal;
								break;
							case 2:
								if (Trestkon(player).stealth1ParTimeHard != 0 && Trestkon(player).stealth1ParTimeHard < Trestkon(player).default.stealth1ParTimeHard)
									Timer.parTime = Trestkon(player).stealth1ParTimeHard;
								else
									Timer.parTime = Trestkon(player).default.stealth1ParTimeHard;
								break;
							case 0:
							default:
								if (Trestkon(player).stealth1ParTimeEasy != 0 && Trestkon(player).stealth1ParTimeEasy < Trestkon(player).default.stealth1ParTimeEasy)
									Timer.parTime = Trestkon(player).stealth1ParTimeEasy;
								else
									Timer.parTime = Trestkon(player).default.stealth1ParTimeEasy;
								break;
						}
						Timer.limitTime = 70;
						break;
					case "95_STEALTH2":
						switch(Trestkon(Player).stealthDifficulty)
						{
							case 1:
								if (Trestkon(player).stealth2ParTimeNormal != 0 && Trestkon(player).stealth2ParTimeNormal < Trestkon(player).default.stealth2ParTimeNormal)
									Timer.parTime = Trestkon(player).stealth2ParTimeNormal;
								else
									Timer.parTime = Trestkon(player).default.stealth2ParTimeNormal;
								break;
							case 2:
								if (Trestkon(player).stealth2ParTimeHard != 0 && Trestkon(player).stealth2ParTimeHard < Trestkon(player).default.stealth2ParTimeHard)
									Timer.parTime = Trestkon(player).stealth2ParTimeHard;
								else
									Timer.parTime = Trestkon(player).default.stealth2ParTimeHard;
								break;
							case 0:
							default:
								if (Trestkon(player).stealth2ParTimeEasy != 0 && Trestkon(player).stealth2ParTimeEasy < Trestkon(player).default.stealth2ParTimeEasy)
									Timer.parTime = Trestkon(player).stealth2ParTimeEasy;
								else
									Timer.parTime = Trestkon(player).default.stealth2ParTimeEasy;
								break;
						}
						Timer.limitTime = 90;
						break;
					case "95_STEALTH3":
						switch(Trestkon(Player).stealthDifficulty)
						{
							case 1:
								if (Trestkon(player).stealth3ParTimeNormal != 0 && Trestkon(player).stealth3ParTimeNormal < Trestkon(player).default.stealth3ParTimeNormal)
									Timer.parTime = Trestkon(player).stealth3ParTimeNormal;
								else
									Timer.parTime = Trestkon(player).default.stealth3ParTimeNormal;
								break;
							case 2:
								if (Trestkon(player).stealth3ParTimeHard != 0 && Trestkon(player).stealth3ParTimeHard < Trestkon(player).default.stealth3ParTimeHard)
									Timer.parTime = Trestkon(player).stealth3ParTimeHard;
								else
									Timer.parTime = Trestkon(player).default.stealth3ParTimeHard;
								break;
							case 0:
							default:
								if (Trestkon(player).stealth3ParTimeEasy != 0 && Trestkon(player).stealth3ParTimeEasy < Trestkon(player).default.stealth3ParTimeEasy)
									Timer.parTime = Trestkon(player).stealth3ParTimeEasy;
								else
									Timer.parTime = Trestkon(player).default.stealth3ParTimeEasy;
								break;
						}
						Timer.limitTime = 150;
						break;
					case "95_STEALTH4":	
						switch(Trestkon(Player).stealthDifficulty)
						{
							case 1:
								if (Trestkon(player).stealth4ParTimeNormal != 0 && Trestkon(player).stealth4ParTimeNormal < Trestkon(player).default.stealth4ParTimeNormal)
									Timer.parTime = Trestkon(player).stealth4ParTimeNormal;
								else
									Timer.parTime = Trestkon(player).default.stealth4ParTimeNormal;
								break;
							case 2:
								if (Trestkon(player).stealth4ParTimeHard != 0 && Trestkon(player).stealth4ParTimeHard < Trestkon(player).default.stealth4ParTimeHard)
									Timer.parTime = Trestkon(player).stealth4ParTimeHard;
								else
									Timer.parTime = Trestkon(player).default.stealth4ParTimeHard;
								break;
							case 0:
							default:
								if (Trestkon(player).stealth4ParTimeEasy != 0 && Trestkon(player).stealth4ParTimeEasy < Trestkon(player).default.stealth4ParTimeEasy)
									Timer.parTime = Trestkon(player).stealth4ParTimeEasy;
								else
									Timer.parTime = Trestkon(player).default.stealth4ParTimeEasy;
								break;
						}
						Timer.limitTime = 150;
						break;
					case "95_STEALTH5":
						switch(Trestkon(Player).stealthDifficulty)
						{
							case 1:
								if (Trestkon(player).stealth5ParTimeNormal != 0 && Trestkon(player).stealth5ParTimeNormal < Trestkon(player).default.stealth5ParTimeNormal)
									Timer.parTime = Trestkon(player).stealth5ParTimeNormal;
								else
									Timer.parTime = Trestkon(player).default.stealth5ParTimeNormal;
								break;
							case 2:
								if (Trestkon(player).stealth5ParTimeHard != 0 && Trestkon(player).stealth5ParTimeHard < Trestkon(player).default.stealth5ParTimeHard)
									Timer.parTime = Trestkon(player).stealth5ParTimeHard;
								else
									Timer.parTime = Trestkon(player).default.stealth5ParTimeHard;
								break;
							case 0:
							default:
								if (Trestkon(player).stealth5ParTimeEasy != 0 && Trestkon(player).stealth5ParTimeEasy < Trestkon(player).default.stealth5ParTimeEasy)
									Timer.parTime = Trestkon(player).stealth5ParTimeEasy;
								else
									Timer.parTime = Trestkon(player).default.stealth5ParTimeEasy;
								break;
						}
						Timer.limitTime = 120;
						break;
					case "95_STEALTH6":
						switch(Trestkon(Player).stealthDifficulty)
						{
							case 1:
								if (Trestkon(player).stealth6ParTimeNormal != 0 && Trestkon(player).stealth6ParTimeNormal < Trestkon(player).default.stealth6ParTimeNormal)
									Timer.parTime = Trestkon(player).stealth6ParTimeNormal;
								else
									Timer.parTime = Trestkon(player).default.stealth6ParTimeNormal;
								break;
							case 2:
								if (Trestkon(player).stealth6ParTimeHard != 0 && Trestkon(player).stealth6ParTimeHard < Trestkon(player).default.stealth6ParTimeHard)
									Timer.parTime = Trestkon(player).stealth6ParTimeHard;
								else
									Timer.parTime = Trestkon(player).default.stealth6ParTimeHard;
								break;
							case 0:
							default:
								if (Trestkon(player).stealth6ParTimeEasy != 0 && Trestkon(player).stealth6ParTimeEasy < Trestkon(player).default.stealth6ParTimeEasy)
									Timer.parTime = Trestkon(player).stealth6ParTimeEasy;
								else
									Timer.parTime = Trestkon(player).default.stealth6ParTimeEasy;
								break;
						}
						Timer.limitTime = 60;
						break;
					case "95_STEALTH7":
						switch(Trestkon(Player).stealthDifficulty)
						{
							case 1:
								if (Trestkon(player).stealth7ParTimeNormal != 0 && Trestkon(player).stealth7ParTimeNormal < Trestkon(player).default.stealth7ParTimeNormal)
									Timer.parTime = Trestkon(player).stealth7ParTimeNormal;
								else
									Timer.parTime = Trestkon(player).default.stealth7ParTimeNormal;
								break;
							case 2:
								if (Trestkon(player).stealth7ParTimeHard != 0 && Trestkon(player).stealth7ParTimeHard < Trestkon(player).default.stealth7ParTimeHard)
									Timer.parTime = Trestkon(player).stealth7ParTimeHard;
								else
									Timer.parTime = Trestkon(player).default.stealth7ParTimeHard;
								break;
							case 0:
							Default:
								if (Trestkon(player).stealth7ParTimeEasy != 0 && Trestkon(player).stealth7ParTimeEasy < Trestkon(player).default.stealth7ParTimeEasy)
									Timer.parTime = Trestkon(player).stealth7ParTimeEasy;
								else
									Timer.parTime = Trestkon(player).default.stealth7ParTimeEasy;
								break;
						}
						Timer.limitTime = 120;
						break;
					case "95_STEALTH8":
						switch(Trestkon(Player).stealthDifficulty)
						{
							case 1:
								if (Trestkon(player).stealth8ParTimeNormal != 0 && Trestkon(player).stealth8ParTimeNormal < Trestkon(player).default.stealth8ParTimeNormal)
									Timer.parTime = Trestkon(player).stealth8ParTimeNormal;
								else
									Timer.parTime = Trestkon(player).default.stealth8ParTimeNormal;
								break;
							case 2:
								if (Trestkon(player).stealth8ParTimeHard != 0 && Trestkon(player).stealth8ParTimeHard < Trestkon(player).default.stealth8ParTimeHard)
									Timer.parTime = Trestkon(player).stealth8ParTimeHard;
								else
									Timer.parTime = Trestkon(player).default.stealth8ParTimeHard;
								break;
							case 0:
							Default:
								if (Trestkon(player).stealth8ParTimeEasy != 0 && Trestkon(player).stealth8ParTimeEasy < Trestkon(player).default.stealth8ParTimeEasy)
									Timer.parTime = Trestkon(player).stealth8ParTimeEasy;
								else
									Timer.parTime = Trestkon(player).default.stealth8ParTimeEasy;
								break;
						}
						Timer.limitTime = 200;
						break;
					case "95_STEALTH9":
						switch(Trestkon(Player).stealthDifficulty)
						{
							case 1:
								if (Trestkon(player).stealth9ParTimeNormal != 0 && Trestkon(player).stealth9ParTimeNormal < Trestkon(player).default.stealth9ParTimeNormal)
									Timer.parTime = Trestkon(player).stealth9ParTimeNormal;
								else
									Timer.parTime = Trestkon(player).default.stealth9ParTimeNormal;
								break;
							case 2:
								if (Trestkon(player).stealth9ParTimeHard != 0 && Trestkon(player).stealth9ParTimeHard < Trestkon(player).default.stealth9ParTimeHard)
									Timer.parTime = Trestkon(player).stealth9ParTimeHard;
								else
									Timer.parTime = Trestkon(player).default.stealth9ParTimeHard;
								break;
							case 0:
							Default:
								if (Trestkon(player).stealth9ParTimeEasy != 0 && Trestkon(player).stealth9ParTimeEasy < Trestkon(player).default.stealth9ParTimeEasy)
									Timer.parTime = Trestkon(player).stealth9ParTimeEasy;
								else
									Timer.parTime = Trestkon(player).default.stealth9ParTimeEasy;
								break;
						}
						Timer.limitTime = 300;
						break;
					default:
						Timer.parTime = 200;
						Timer.limitTime = 300;
				}
				Timer.criticalTime = Timer.limitTime * 0.9;
                Timer.Message = Timer.strTimer;
            }

            Timer.Trigger(Player, Player);
            flags.SetBool('bChallengeTimerCreated', True,, 100);
        }
	
		foreach AllActors(class'DeusExMover', M)
		{
			if (M.Tag == 'EndMover')
			{
				EndMov = M;
				break;
			}
		}
    }
	
	foreach AllActors(class'SecurityCamera', cam)
	{
		switch (Trestkon(player).stealthDifficulty)
		{
			case 0:
				cam.triggerDelay = 2;
				cam.memorytime = 5;
				break;
			case 1:
				cam.triggerDelay = 1;
				cam.memorytime = 10;
				break;
			case 2:
			default:
				cam.triggerDelay = 0;
				cam.swingperiod = cam.swingperiod / 2;
				break;
		}
	}
	
	foreach AllActors(class'TNMPawn', SP)
	{
		switch (Trestkon(player).stealthDifficulty)
		{
			case 2:
				SP.bExtraSuspicious=True;
				SP.VisibilityThreshold = SP.VisibilityThreshold / 2;
				break;
		}
	}
}


function InitStateMachine()
{
    local DeusExLevelInfo info;

    Player = DeusExPlayer(GetPlayerPawn());

    foreach AllActors(class'DeusExLevelInfo', info)
        dxInfo = info;

    if (Player != None)
    {
        flags = Player.FlagBase;

        // Get the mission number by extracting it from the
        // DeusExLevelInfo and then delete any expired flags.
        //
        // Also set the default mission expiration so flags
        // expire in the next mission unless explicitly set
        // differently when the flag is created.

        if (flags != None)
        {
            // Don't delete expired flags if we just loaded
            // a savegame
            if (flags.GetBool('PlayerTraveling'))
                flags.DeleteExpiredFlags(dxInfo.MissionNumber);

            flags.SetDefaultExpiration(dxInfo.MissionNumber + 1);

            localURL = Caps(dxInfo.mapName);
			flags.SetBool('PlayerTraveling', True, True, 0); // hack
			
			if (right(localURL, 5) == "_2009")
				localURL = Left(localURL, Len(localURL)-5);

            log("**** InitStateMachine() -"@player@"started mission state machine for"@localURL);
        }
        else
        {
            log("**** InitStateMachine() - flagBase not set - mission state machine NOT initialized!");
        }
    }
    else
    {
        log("**** InitStateMachine() - player not set - mission state machine NOT initialized!");
    }
}

function HandleGameEvent(name scriptFunction)
{
	switch ( scriptfunction)
	{
		case 'ResetLevel'		: ResetLevel(); break;
		case 'ResetLevelTime'	: ResetLevelTime(); break;
		case 'CompleteLevel'	: CompleteLevel(); break;
	}
}

// Bad completion - fail
function ResetLevel()
{
	local tnmtimer atimer;
	if (winTime == 0 && failTime == 0 && flags != None && !flags.GetBool('PlayerTraveling'))
	{	
		tnmhud(DeusExRootWindow(Player.rootWindow).hud).InvaderEnterMessage("", 2);	
		failTime = Level.TimeSeconds;
		StealthEnded(failTime, true);
		foreach allactors(class'tnmtimer', atimer)
		{
            atimer.Trigger(Player, Player);
		}
	}
}

function ResetLevelTime()
{
	local tnmtimer atimer;
	if (winTime == 0 && failTime == 0 && flags != None && !flags.GetBool('PlayerTraveling'))
	{	
		tnmhud(DeusExRootWindow(Player.rootWindow).hud).InvaderEnterMessage("", 3);	
		failTime = Level.TimeSeconds;
		StealthEnded(failTime, true);
		foreach allactors(class'tnmtimer', atimer)
		{
            atimer.Trigger(Player, Player);
		}
	}
}

// Harder mode
function PlayerDetected(name StateType, optional ScriptedPawn Triggerer)
{
	local tnmtimer atimer;
	if (Trestkon(player).stealthDifficulty > 0)
	{
		if (winTime == 0 && failTime == 0 && flags != None && !flags.GetBool('PlayerTraveling'))
		{	
			tnmhud(DeusExRootWindow(Player.rootWindow).hud).InvaderEnterMessage("", 4);	
			failTime = Level.TimeSeconds;
			StealthEnded(failTime, true);
			foreach allactors(class'tnmtimer', atimer)
			{
				atimer.Trigger(Player, Player);
			}
		}
	}
}

// Good completion
function CompleteLevel()
{
	local tnmtimer atimer;
	if (winTime == 0 && failTime == 0 && flags != None && !flags.GetBool('PlayerTraveling'))
	{
		winTime = Level.TimeSeconds;
		StealthEnded(winTime);
		foreach allactors(class'tnmtimer', atimer)
		{
            atimer.Trigger(Player, Player);
			if (atimer.time < atimer.partime)
			{
				Player.ClientMessage(beatPar);				
				Player.PlaySound(Sound'tnmLogSkillPoints');
				bParTimeBeat = True;
				switch (localURL)
				{					
					case "95_STEALTH1":
						switch(Trestkon(Player).stealthDifficulty)
						{
							case 0:
								Trestkon(Player).stealth1ParTimeEasy = atimer.time;
								break;
							case 1:
								Trestkon(Player).stealth1ParTimeNormal = atimer.time;
								break;
							case 2:
								Trestkon(Player).stealth1ParTimeHard = atimer.time;
								break;
							Default:
								Trestkon(Player).stealth1ParTimeEasy = atimer.time;
								break;
						}
						break;
					case "95_STEALTH2":
						switch(Trestkon(Player).stealthDifficulty)
						{
							case 0:
								Trestkon(Player).stealth2ParTimeEasy = atimer.time;
								break;
							case 1:
								Trestkon(Player).stealth2ParTimeNormal = atimer.time;
								break;
							case 2:
								Trestkon(Player).stealth2ParTimeHard = atimer.time;
								break;
							Default:
								Trestkon(Player).stealth2ParTimeEasy = atimer.time;
								break;
						}
						break;
					case "95_STEALTH3":
						switch(Trestkon(Player).stealthDifficulty)
						{
							case 0:
								Trestkon(Player).stealth3ParTimeEasy = atimer.time;
								break;
							case 1:
								Trestkon(Player).stealth3ParTimeNormal = atimer.time;
								break;
							case 2:
								Trestkon(Player).stealth3ParTimeHard = atimer.time;
								break;
							Default:
								Trestkon(Player).stealth3ParTimeEasy = atimer.time;
								break;
						}
						break;
					case "95_STEALTH4":
						switch(Trestkon(Player).stealthDifficulty)
						{
							case 0:
								Trestkon(Player).stealth4ParTimeEasy = atimer.time;
								break;
							case 1:
								Trestkon(Player).stealth4ParTimeNormal = atimer.time;
								break;
							case 2:
								Trestkon(Player).stealth4ParTimeHard = atimer.time;
								break;
							Default:
								Trestkon(Player).stealth4ParTimeEasy = atimer.time;
								break;
						}
						break;
					case "95_STEALTH5":
						switch(Trestkon(Player).stealthDifficulty)
						{
							case 0:
								Trestkon(Player).stealth5ParTimeEasy = atimer.time;
								break;
							case 1:
								Trestkon(Player).stealth5ParTimeNormal = atimer.time;
								break;
							case 2:
								Trestkon(Player).stealth5ParTimeHard = atimer.time;
								break;
							Default:
								Trestkon(Player).stealth5ParTimeEasy = atimer.time;
								break;
						}
						break;
					case "95_STEALTH6":
						switch(Trestkon(Player).stealthDifficulty)
						{
							case 0:
								Trestkon(Player).stealth6ParTimeEasy = atimer.time;
								break;
							case 1:
								Trestkon(Player).stealth6ParTimeNormal = atimer.time;
								break;
							case 2:
								Trestkon(Player).stealth6ParTimeHard = atimer.time;
								break;
							Default:
								Trestkon(Player).stealth6ParTimeEasy = atimer.time;
								break;
						}
						break;
					case "95_STEALTH7":
						switch(Trestkon(Player).stealthDifficulty)
						{
							case 0:
								Trestkon(Player).stealth7ParTimeEasy = atimer.time;
								break;
							case 1:
								Trestkon(Player).stealth7ParTimeNormal = atimer.time;
								break;
							case 2:
								Trestkon(Player).stealth7ParTimeHard = atimer.time;
								break;
							Default:
								Trestkon(Player).stealth7ParTimeEasy = atimer.time;
								break;
						}
						break;
					case "95_STEALTH8":
						switch(Trestkon(Player).stealthDifficulty)
						{
							case 0:
								Trestkon(Player).stealth8ParTimeEasy = atimer.time;
								break;
							case 1:
								Trestkon(Player).stealth8ParTimeNormal = atimer.time;
								break;
							case 2:
								Trestkon(Player).stealth8ParTimeHard = atimer.time;
								break;
							Default:
								Trestkon(Player).stealth8ParTimeEasy = atimer.time;
								break;
						}
						break;
					case "95_STEALTH9":
						switch(Trestkon(Player).stealthDifficulty)
						{
							case 0:
								Trestkon(Player).stealth9ParTimeEasy = atimer.time;
								break;
							case 1:
								Trestkon(Player).stealth9ParTimeNormal = atimer.time;
								break;
							case 2:
								Trestkon(Player).stealth9ParTimeHard = atimer.time;
								break;
							Default:
								Trestkon(Player).stealth9ParTimeEasy = atimer.time;
								break;
						}
						break;
				}
				Player.SaveConfig();
			}
			else
			{
				Player.ClientMessage(sprintf(overPar, ConvertTime(atimer.time - atimer.partime)));
			}
		}
	}
}

function Tick(float deltatime)
{
	local vector loc; 
	local int i;
	
	Super.Tick(deltaTime);
	
	if (winTime != 0 && EndMov != None)
	{
		loc = EndMov.Location;
		loc.z -= 1.2;
		EndMov.SetLocation(loc);
		EndMov.RotationRate.Yaw = EndMov.RotationRate.Yaw * 1.03;
	}
	if (SkyBoxInfo != None)
	{
		SkyBoxInfo.DesiredRotation.Yaw = SkyBoxInfo.DesiredRotation.Yaw % 65536;
		SkyBoxInfo.DesiredRotation.Pitch = SkyBoxInfo.DesiredRotation.Pitch % 65536;
		SkyBoxInfo.DesiredRotation.Roll = SkyBoxInfo.DesiredRotation.Roll % 65536;
		if (SkyBoxInfo.Rotation == SkyBoxInfo.DesiredRotation)
		{
			i = Rand(3);
			switch(i)
			{
				case 0:
					SkyBoxInfo.DesiredRotation.Yaw += 16384;
					break;
				case 1:
					SkyBoxInfo.DesiredRotation.Pitch += 16384;
					break;
				case 2:
					SkyBoxInfo.DesiredRotation.Roll += 16384;
					break;
			}
		}
	}
}

function Timer()
{
	Super.Timer();
	
	if (winTime == 0 && failTime != 0 && Level.TimeSeconds >= failTime + 2)
	{
		flags.SetBool('PlayerTraveling', True, True, 0);
        flags.SetBool('bChallengeTimerCreated', False,, 100);
        flags.SetBool('StealthComplete', False,, 100);
        flags.DeleteFlag('StealthCompleteTime', FLAG_Float);
		Player.bBehindView = False;
		DeusExRootWindow(Player.rootWindow).UpdateHud();
		Player.RestartLevel();
	}
	else if (winTime != 0 && Level.TimeSeconds >= winTime + 3)
	{
		flags.SetBool('PlayerTraveling', True, True, 0);
        flags.SetBool('bChallengeTimerCreated', False,, 100);
        flags.SetBool('StealthComplete', False,, 100);
        flags.DeleteFlag('StealthCompleteTime', FLAG_Float);
		Player.bBehindView = False;
		DeusExRootWindow(Player.rootWindow).UpdateHud();
		if (Trestkon(player).bLoopStealthUntilPB && !bParTimeBeat)
			Player.RestartLevel();
		else
		{
			switch (localURL)
			{
				case "95_STEALTH1": Player.ClientTravel( "95_Stealth2", TRAVEL_Relative, true ); break;
				case "95_STEALTH2": Player.ClientTravel( "95_Stealth3", TRAVEL_Relative, true ); break;
				case "95_STEALTH3": Player.ClientTravel( "95_Stealth4", TRAVEL_Relative, true ); break;
				case "95_STEALTH4": Player.ClientTravel( "95_Stealth5", TRAVEL_Relative, true ); break;
				case "95_STEALTH5": Player.ClientTravel( "95_Stealth6", TRAVEL_Relative, true ); break;
				case "95_STEALTH6": Player.ClientTravel( "95_Stealth7", TRAVEL_Relative, true ); break;
				case "95_STEALTH7": Player.ClientTravel( "95_Stealth8", TRAVEL_Relative, true ); break;
				case "95_STEALTH8": Player.ClientTravel( "95_Stealth9", TRAVEL_Relative, true ); break;
				case "95_STEALTH9": Player.ClientTravel( "95_Stealth1", TRAVEL_Relative, true ); break;
				default:
					Player.RestartLevel();
			}
		}
	}
}

function PlayerKilled(pawn killed, pawn killer)
{
	local tnmtimer atimer;
	if (winTime == 0 && failTime == 0 && flags != None && !flags.GetBool('PlayerTraveling'))
	{	
		// tnmhud(DeusExRootWindow(Player.rootWindow).hud).InvaderEnterMessage("", 2);	
		failTime = Level.TimeSeconds;
		if (player.region.zone != None && player.region.zone.damagetype == 'Atmospheric') // Cinematic death
			failTime += 4.25;
		foreach allactors(class'tnmtimer', atimer)
		{
            atimer.Trigger(Player, Player);
		}
	}
}

function string ConvertTime(float time)
{
    local string str;
    local int mins;
    local float secs;
	
    mins = time / 60;
    secs = time % 60;

    // if (mins < 10)
        // str = "0";
    // str = str $ mins $ ":";
    // if (secs < 10)
        // str = str $ "0";
    // str = str $ secs;
	
	if (mins > 0)
		str = mins $ "m, ";
	if (int(secs) > 0)
		str = str $ int(secs) $ "s, ";
	str = str $ int((secs % 1) * 1000) $ "ms";
	
	return str;
}

function StealthEnded(float time, optional bool bFail)
{
	local beam be;
	
	flags.SetBool('StealthComplete', True, True, 0);
	flags.SetFloat('StealthCompleteTime', time, True, 0);
	Player.bBehindView = True;
	Player.GoToState('StealthCinematic');
	Player.Velocity = Vect(0,0,0);
	Player.Acceleration = Velocity * -1;
	if (bFail)
		Player.LoopAnim('RubEyes', 1);
	else
	{
		if (FRand() <= 0.5 || !Player.HasAnim('Idle12H'))
			Player.LoopAnim('Idle1', 1);
		else
			Player.LoopAnim('Idle12H', 1);
	}
	if (!bFail)
	{
		be = Spawn(class'Beam',,, Player.Location);
		be.LightSaturation=255;
		be.LightEffect = LE_Disco;
	}
}

defaultproperties
{
     beatPar="Par time beat!"
     overPar="%s over par!"
     checkTime=0.250000
     RemoteRole=ROLE_DumbProxy
}

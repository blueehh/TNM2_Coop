class tnmmissioncombat extends tnmmissionscript;

var float failTime;
var float winTime;
var localized string beatPar, overPar, remainingtargets;
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
		if (Sky.Tag == 'Combat9SkyZoneInfo')
			SkyBoxInfo = Sky;
		break;
	}
	
	if (bCreateTimer)
    {
        Timer = Spawn( class'TNMTimer', ,, Player.Location, Rot(16384,0,0));

        if (Timer != None)
        {
			bTimeCountUp = True;

            if (bTimeCountUp)
            {
                Timer.bCountDown = False;
				switch (localURL)
				{
					case "95_COMBAT1":
						switch(Trestkon(Player).combatMinigameDifficulty)
						{
							case 1:
								if (Trestkon(player).combat1ParTimeNormal != 0 && Trestkon(player).combat1ParTimeNormal < Trestkon(player).default.combat1ParTimeNormal)
									Timer.parTime = Trestkon(player).combat1ParTimeNormal;
								else
									Timer.parTime = Trestkon(player).default.combat1ParTimeNormal;
								break;
							case 2:
								if (Trestkon(player).combat1ParTimeHard != 0 && Trestkon(player).combat1ParTimeHard < Trestkon(player).default.combat1ParTimeHard)
									Timer.parTime = Trestkon(player).combat1ParTimeHard;
								else
									Timer.parTime = Trestkon(player).default.combat1ParTimeHard;
								break;
							case 0:
							default:
								if (Trestkon(player).combat1ParTimeEasy != 0 && Trestkon(player).combat1ParTimeEasy < Trestkon(player).default.combat1ParTimeEasy)
									Timer.parTime = Trestkon(player).combat1ParTimeEasy;
								else
									Timer.parTime = Trestkon(player).default.combat1ParTimeEasy;
								break;
						}
						Timer.limitTime = 70;
						break;
					case "95_COMBAT2":
						switch(Trestkon(Player).combatMinigameDifficulty)
						{
							case 1:
								if (Trestkon(player).combat2ParTimeNormal != 0 && Trestkon(player).combat2ParTimeNormal < Trestkon(player).default.combat2ParTimeNormal)
									Timer.parTime = Trestkon(player).combat2ParTimeNormal;
								else
									Timer.parTime = Trestkon(player).default.combat2ParTimeNormal;
								break;
							case 2:
								if (Trestkon(player).combat2ParTimeHard != 0 && Trestkon(player).combat2ParTimeHard < Trestkon(player).default.combat2ParTimeHard)
									Timer.parTime = Trestkon(player).combat2ParTimeHard;
								else
									Timer.parTime = Trestkon(player).default.combat2ParTimeHard;
								break;
							case 0:
							default:
								if (Trestkon(player).combat2ParTimeEasy != 0 && Trestkon(player).combat2ParTimeEasy < Trestkon(player).default.combat2ParTimeEasy)
									Timer.parTime = Trestkon(player).combat2ParTimeEasy;
								else
									Timer.parTime = Trestkon(player).default.combat2ParTimeEasy;
								break;
						}
						Timer.limitTime = 90;
						break;
					case "95_COMBAT3":
						switch(Trestkon(Player).combatMinigameDifficulty)
						{
							case 1:
								if (Trestkon(player).combat3ParTimeNormal != 0 && Trestkon(player).combat3ParTimeNormal < Trestkon(player).default.combat3ParTimeNormal)
									Timer.parTime = Trestkon(player).combat3ParTimeNormal;
								else
									Timer.parTime = Trestkon(player).default.combat3ParTimeNormal;
								break;
							case 2:
								if (Trestkon(player).combat3ParTimeHard != 0 && Trestkon(player).combat3ParTimeHard < Trestkon(player).default.combat3ParTimeHard)
									Timer.parTime = Trestkon(player).combat3ParTimeHard;
								else
									Timer.parTime = Trestkon(player).default.combat3ParTimeHard;
								break;
							case 0:
							default:
								if (Trestkon(player).combat3ParTimeEasy != 0 && Trestkon(player).combat3ParTimeEasy < Trestkon(player).default.combat3ParTimeEasy)
									Timer.parTime = Trestkon(player).combat3ParTimeEasy;
								else
									Timer.parTime = Trestkon(player).default.combat3ParTimeEasy;
								break;
						}
						Timer.limitTime = 150;
						break;
					case "95_COMBAT4":	
						switch(Trestkon(Player).combatMinigameDifficulty)
						{
							case 1:
								if (Trestkon(player).combat4ParTimeNormal != 0 && Trestkon(player).combat4ParTimeNormal < Trestkon(player).default.combat4ParTimeNormal)
									Timer.parTime = Trestkon(player).combat4ParTimeNormal;
								else
									Timer.parTime = Trestkon(player).default.combat4ParTimeNormal;
								break;
							case 2:
								if (Trestkon(player).combat4ParTimeHard != 0 && Trestkon(player).combat4ParTimeHard < Trestkon(player).default.combat4ParTimeHard)
									Timer.parTime = Trestkon(player).combat4ParTimeHard;
								else
									Timer.parTime = Trestkon(player).default.combat4ParTimeHard;
								break;
							case 0:
							default:
								if (Trestkon(player).combat4ParTimeEasy != 0 && Trestkon(player).combat4ParTimeEasy < Trestkon(player).default.combat4ParTimeEasy)
									Timer.parTime = Trestkon(player).combat4ParTimeEasy;
								else
									Timer.parTime = Trestkon(player).default.combat4ParTimeEasy;
								break;
						}
						Timer.limitTime = 150;
						break;
					case "95_COMBAT5":
						switch(Trestkon(Player).combatMinigameDifficulty)
						{
							case 1:
								if (Trestkon(player).combat5ParTimeNormal != 0 && Trestkon(player).combat5ParTimeNormal < Trestkon(player).default.combat5ParTimeNormal)
									Timer.parTime = Trestkon(player).combat5ParTimeNormal;
								else
									Timer.parTime = Trestkon(player).default.combat5ParTimeNormal;
								break;
							case 2:
								if (Trestkon(player).combat5ParTimeHard != 0 && Trestkon(player).combat5ParTimeHard < Trestkon(player).default.combat5ParTimeHard)
									Timer.parTime = Trestkon(player).combat5ParTimeHard;
								else
									Timer.parTime = Trestkon(player).default.combat5ParTimeHard;
								break;
							case 0:
							default:
								if (Trestkon(player).combat5ParTimeEasy != 0 && Trestkon(player).combat5ParTimeEasy < Trestkon(player).default.combat5ParTimeEasy)
									Timer.parTime = Trestkon(player).combat5ParTimeEasy;
								else
									Timer.parTime = Trestkon(player).default.combat5ParTimeEasy;
								break;
						}
						Timer.limitTime = 120;
						break;
					case "95_COMBAT6":
						switch(Trestkon(Player).combatMinigameDifficulty)
						{
							case 1:
								if (Trestkon(player).combat6ParTimeNormal != 0 && Trestkon(player).combat6ParTimeNormal < Trestkon(player).default.combat6ParTimeNormal)
									Timer.parTime = Trestkon(player).combat6ParTimeNormal;
								else
									Timer.parTime = Trestkon(player).default.combat6ParTimeNormal;
								break;
							case 2:
								if (Trestkon(player).combat6ParTimeHard != 0 && Trestkon(player).combat6ParTimeHard < Trestkon(player).default.combat6ParTimeHard)
									Timer.parTime = Trestkon(player).combat6ParTimeHard;
								else
									Timer.parTime = Trestkon(player).default.combat6ParTimeHard;
								break;
							case 0:
							default:
								if (Trestkon(player).combat6ParTimeEasy != 0 && Trestkon(player).combat6ParTimeEasy < Trestkon(player).default.combat6ParTimeEasy)
									Timer.parTime = Trestkon(player).combat6ParTimeEasy;
								else
									Timer.parTime = Trestkon(player).default.combat6ParTimeEasy;
								break;
						}
						Timer.limitTime = 60;
						break;
					case "95_COMBAT7":
						switch(Trestkon(Player).combatMinigameDifficulty)
						{
							case 1:
								if (Trestkon(player).combat7ParTimeNormal != 0 && Trestkon(player).combat7ParTimeNormal < Trestkon(player).default.combat7ParTimeNormal)
									Timer.parTime = Trestkon(player).combat7ParTimeNormal;
								else
									Timer.parTime = Trestkon(player).default.combat7ParTimeNormal;
								break;
							case 2:
								if (Trestkon(player).combat7ParTimeHard != 0 && Trestkon(player).combat7ParTimeHard < Trestkon(player).default.combat7ParTimeHard)
									Timer.parTime = Trestkon(player).combat7ParTimeHard;
								else
									Timer.parTime = Trestkon(player).default.combat7ParTimeHard;
								break;
							case 0:
							Default:
								if (Trestkon(player).combat7ParTimeEasy != 0 && Trestkon(player).combat7ParTimeEasy < Trestkon(player).default.combat7ParTimeEasy)
									Timer.parTime = Trestkon(player).combat7ParTimeEasy;
								else
									Timer.parTime = Trestkon(player).default.combat7ParTimeEasy;
								break;
						}
						Timer.limitTime = 120;
						break;
					case "95_COMBAT8":
						switch(Trestkon(Player).combatMinigameDifficulty)
						{
							case 1:
								if (Trestkon(player).combat8ParTimeNormal != 0 && Trestkon(player).combat8ParTimeNormal < Trestkon(player).default.combat8ParTimeNormal)
									Timer.parTime = Trestkon(player).combat8ParTimeNormal;
								else
									Timer.parTime = Trestkon(player).default.combat8ParTimeNormal;
								break;
							case 2:
								if (Trestkon(player).combat8ParTimeHard != 0 && Trestkon(player).combat8ParTimeHard < Trestkon(player).default.combat8ParTimeHard)
									Timer.parTime = Trestkon(player).combat8ParTimeHard;
								else
									Timer.parTime = Trestkon(player).default.combat8ParTimeHard;
								break;
							case 0:
							Default:
								if (Trestkon(player).combat8ParTimeEasy != 0 && Trestkon(player).combat8ParTimeEasy < Trestkon(player).default.combat8ParTimeEasy)
									Timer.parTime = Trestkon(player).combat8ParTimeEasy;
								else
									Timer.parTime = Trestkon(player).default.combat8ParTimeEasy;
								break;
						}
						Timer.limitTime = 200;
						break;
					case "95_COMBAT9":
						switch(Trestkon(Player).combatMinigameDifficulty)
						{
							case 1:
								if (Trestkon(player).combat9ParTimeNormal != 0 && Trestkon(player).combat9ParTimeNormal < Trestkon(player).default.combat9ParTimeNormal)
									Timer.parTime = Trestkon(player).combat9ParTimeNormal;
								else
									Timer.parTime = Trestkon(player).default.combat9ParTimeNormal;
								break;
							case 2:
								if (Trestkon(player).combat9ParTimeHard != 0 && Trestkon(player).combat9ParTimeHard < Trestkon(player).default.combat9ParTimeHard)
									Timer.parTime = Trestkon(player).combat9ParTimeHard;
								else
									Timer.parTime = Trestkon(player).default.combat9ParTimeHard;
								break;
							case 0:
							Default:
								if (Trestkon(player).combat9ParTimeEasy != 0 && Trestkon(player).combat9ParTimeEasy < Trestkon(player).default.combat9ParTimeEasy)
									Timer.parTime = Trestkon(player).combat9ParTimeEasy;
								else
									Timer.parTime = Trestkon(player).default.combat9ParTimeEasy;
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
		switch (Trestkon(player).combatMinigameDifficulty)
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
		switch (Trestkon(player).combatMinigameDifficulty)
		{
			case 2:
				SP.bExtraSuspicious=True;
				SP.VisibilityThreshold = SP.VisibilityThreshold / 2;
				break;
		}
	}
	
	switch (Trestkon(Player).combatMinigameDifficulty)
	{
		case 2:	// Hard
			if (Player.SkillSystem != None)
			{
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillWeaponRifle');
				if (aSkill != None)
					aSkill.CurrentLevel = 2;
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillWeaponPistol');
				if (aSkill != None)
					aSkill.CurrentLevel = 2;
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillWeaponHeavy');
				if (aSkill != None)
					aSkill.CurrentLevel = 2;
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillWeaponLowTech');
				if (aSkill != None)
					aSkill.CurrentLevel = 2;
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillWeaponFists');
				if (aSkill != None)
					aSkill.CurrentLevel = 2;
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillDemolition');
				if (aSkill != None)
					aSkill.CurrentLevel = 2;
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillComputer');
				if (aSkill != None)
					aSkill.CurrentLevel = 2;
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillLockpicking');
				if (aSkill != None)
					aSkill.CurrentLevel = 2;
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillTech');
				if (aSkill != None)
					aSkill.CurrentLevel = 2;
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillMedicine');
				if (aSkill != None)
					aSkill.CurrentLevel = 2;
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillEnviro');
				if (aSkill != None)
					aSkill.CurrentLevel = 2;
			}
			break;
		default:
			if (Player.SkillSystem != None)
			{
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillWeaponRifle');
				if (aSkill != None)
					aSkill.CurrentLevel = 3;
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillWeaponPistol');
				if (aSkill != None)
					aSkill.CurrentLevel = 3;
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillWeaponHeavy');
				if (aSkill != None)
					aSkill.CurrentLevel = 3;
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillWeaponLowTech');
				if (aSkill != None)
					aSkill.CurrentLevel = 3;
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillWeaponFists');
				if (aSkill != None)
					aSkill.CurrentLevel = 3;
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillDemolition');
				if (aSkill != None)
					aSkill.CurrentLevel = 3;
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillComputer');
				if (aSkill != None)
					aSkill.CurrentLevel = 3;
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillLockpicking');
				if (aSkill != None)
					aSkill.CurrentLevel = 3;
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillTech');
				if (aSkill != None)
					aSkill.CurrentLevel = 3;
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillMedicine');
				if (aSkill != None)
					aSkill.CurrentLevel = 3;
				aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillEnviro');
				if (aSkill != None)
					aSkill.CurrentLevel = 3;
			}
			break;
	}
	
	switch (localURL)
	{
		case "95_COMBAT1":
			DoChallenge1FirstFrame();
			break;
		case "95_COMBAT2":
			DoChallenge2FirstFrame();
			break;
		case "95_COMBAT3":
			DoChallenge3FirstFrame();
			break;
		case "95_COMBAT4":
			DoChallenge4FirstFrame();
			break;
		case "95_COMBAT5":
			DoChallenge5FirstFrame();
			break;
		case "95_COMBAT6":
			DoChallenge6FirstFrame();
			break;
		case "95_COMBAT7":
			DoChallenge7FirstFrame();
			break;
		case "95_COMBAT8":
			DoChallenge8FirstFrame();
			break;
	}

    Player.SkillPointsTotal = 0;
    Player.SkillPointsAvail = 0;
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
		CombatEnded(failTime, true);
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
		CombatEnded(failTime, true);
		foreach allactors(class'tnmtimer', atimer)
		{
            atimer.Trigger(Player, Player);
		}
	}
}

// Harder mode
/*
function PlayerDetected(name StateType, optional ScriptedPawn Triggerer)
{
	local tnmtimer atimer;
	if (Trestkon(player).combatMinigameDifficulty > 0)
	{
		if (winTime == 0 && failTime == 0 && flags != None && !flags.GetBool('PlayerTraveling'))
		{	
			tnmhud(DeusExRootWindow(Player.rootWindow).hud).InvaderEnterMessage("", 4);	
			failTime = Level.TimeSeconds;
			CombatEnded(failTime, true);
			foreach allactors(class'tnmtimer', atimer)
			{
				atimer.Trigger(Player, Player);
			}
		}
	}
}*/

// Good completion
function CompleteLevel()
{
	local tnmtimer atimer;
	if (winTime == 0 && failTime == 0 && flags != None && !flags.GetBool('PlayerTraveling'))
	{
		winTime = Level.TimeSeconds;
		CombatEnded(winTime);
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
					case "95_COMBAT1":
						switch(Trestkon(Player).combatMinigameDifficulty)
						{
							case 0:
								Trestkon(Player).combat1ParTimeEasy = atimer.time;
								break;
							case 1:
								Trestkon(Player).combat1ParTimeNormal = atimer.time;
								break;
							case 2:
								Trestkon(Player).combat1ParTimeHard = atimer.time;
								break;
							Default:
								Trestkon(Player).combat1ParTimeEasy = atimer.time;
								break;
						}
						break;
					case "95_COMBAT2":
						switch(Trestkon(Player).combatMinigameDifficulty)
						{
							case 0:
								Trestkon(Player).combat2ParTimeEasy = atimer.time;
								break;
							case 1:
								Trestkon(Player).combat2ParTimeNormal = atimer.time;
								break;
							case 2:
								Trestkon(Player).combat2ParTimeHard = atimer.time;
								break;
							Default:
								Trestkon(Player).combat2ParTimeEasy = atimer.time;
								break;
						}
						break;
					case "95_COMBAT3":
						switch(Trestkon(Player).combatMinigameDifficulty)
						{
							case 0:
								Trestkon(Player).combat3ParTimeEasy = atimer.time;
								break;
							case 1:
								Trestkon(Player).combat3ParTimeNormal = atimer.time;
								break;
							case 2:
								Trestkon(Player).combat3ParTimeHard = atimer.time;
								break;
							Default:
								Trestkon(Player).combat3ParTimeEasy = atimer.time;
								break;
						}
						break;
					case "95_COMBAT4":
						switch(Trestkon(Player).combatMinigameDifficulty)
						{
							case 0:
								Trestkon(Player).combat4ParTimeEasy = atimer.time;
								break;
							case 1:
								Trestkon(Player).combat4ParTimeNormal = atimer.time;
								break;
							case 2:
								Trestkon(Player).combat4ParTimeHard = atimer.time;
								break;
							Default:
								Trestkon(Player).combat4ParTimeEasy = atimer.time;
								break;
						}
						break;
					case "95_COMBAT5":
						switch(Trestkon(Player).combatMinigameDifficulty)
						{
							case 0:
								Trestkon(Player).combat5ParTimeEasy = atimer.time;
								break;
							case 1:
								Trestkon(Player).combat5ParTimeNormal = atimer.time;
								break;
							case 2:
								Trestkon(Player).combat5ParTimeHard = atimer.time;
								break;
							Default:
								Trestkon(Player).combat5ParTimeEasy = atimer.time;
								break;
						}
						break;
					case "95_COMBAT6":
						switch(Trestkon(Player).combatMinigameDifficulty)
						{
							case 0:
								Trestkon(Player).combat6ParTimeEasy = atimer.time;
								break;
							case 1:
								Trestkon(Player).combat6ParTimeNormal = atimer.time;
								break;
							case 2:
								Trestkon(Player).combat6ParTimeHard = atimer.time;
								break;
							Default:
								Trestkon(Player).combat6ParTimeEasy = atimer.time;
								break;
						}
						break;
					case "95_COMBAT7":
						switch(Trestkon(Player).combatMinigameDifficulty)
						{
							case 0:
								Trestkon(Player).combat7ParTimeEasy = atimer.time;
								break;
							case 1:
								Trestkon(Player).combat7ParTimeNormal = atimer.time;
								break;
							case 2:
								Trestkon(Player).combat7ParTimeHard = atimer.time;
								break;
							Default:
								Trestkon(Player).combat7ParTimeEasy = atimer.time;
								break;
						}
						break;
					case "95_COMBAT8":
						switch(Trestkon(Player).combatMinigameDifficulty)
						{
							case 0:
								Trestkon(Player).combat8ParTimeEasy = atimer.time;
								break;
							case 1:
								Trestkon(Player).combat8ParTimeNormal = atimer.time;
								break;
							case 2:
								Trestkon(Player).combat8ParTimeHard = atimer.time;
								break;
							Default:
								Trestkon(Player).combat8ParTimeEasy = atimer.time;
								break;
						}
						break;
					case "95_COMBAT9":
						switch(Trestkon(Player).combatMinigameDifficulty)
						{
							case 0:
								Trestkon(Player).combat9ParTimeEasy = atimer.time;
								break;
							case 1:
								Trestkon(Player).combat9ParTimeNormal = atimer.time;
								break;
							case 2:
								Trestkon(Player).combat9ParTimeHard = atimer.time;
								break;
							Default:
								Trestkon(Player).combat9ParTimeEasy = atimer.time;
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
        flags.SetBool('CombatComplete', False,, 100);
        flags.DeleteFlag('CombatCompleteTime', FLAG_Float);
		Player.bBehindView = False;
		DeusExRootWindow(Player.rootWindow).UpdateHud();
		Player.RestartLevel();
	}
	else if (winTime != 0 && Level.TimeSeconds >= winTime + 3)
	{
		flags.SetBool('PlayerTraveling', True, True, 0);
        flags.SetBool('bChallengeTimerCreated', False,, 100);
        flags.SetBool('CombatComplete', False,, 100);
        flags.DeleteFlag('CombatCompleteTime', FLAG_Float);
		Player.bBehindView = False;
		DeusExRootWindow(Player.rootWindow).UpdateHud();
		if (Trestkon(player).bLoopStealthUntilPB && !bParTimeBeat)
			Player.RestartLevel();
		else
		{
			switch (localURL)
			{
				case "95_COMBAT1": Player.ClientTravel( "95_Combat2", TRAVEL_Relative, false ); break;
				case "95_COMBAT2": Player.ClientTravel( "95_Combat3", TRAVEL_Relative, false ); break;
				case "95_COMBAT3": Player.ClientTravel( "95_Combat4", TRAVEL_Relative, false ); break;
				case "95_COMBAT4": Player.ClientTravel( "95_Combat5", TRAVEL_Relative, false ); break;
				case "95_COMBAT5": Player.ClientTravel( "95_Combat6", TRAVEL_Relative, false ); break;
				case "95_COMBAT6": Player.ClientTravel( "95_Combat7", TRAVEL_Relative, false ); break;
				case "95_COMBAT7": Player.ClientTravel( "95_Combat8", TRAVEL_Relative, false ); break;
				// case "95_COMBAT8": Player.ClientTravel( "95_Combat9", TRAVEL_Relative, false ); break;
				case "95_COMBAT8": Player.ClientTravel( "95_Combat1", TRAVEL_Relative, false ); break;
				case "95_COMBAT9": Player.ClientTravel( "95_Combat1", TRAVEL_Relative, false ); break;
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

	
	if (mins > 0)
		str = mins $ "m, ";
	if (int(secs) > 0)
		str = str $ int(secs) $ "s, ";
	str = str $ int((secs % 1) * 1000) $ "ms";
	
	return str;
}

function CombatEnded(float time, optional bool bFail)
{
	local beam be;
	
	flags.SetBool('CombatComplete', True, True, 0);
	flags.SetFloat('CombatCompleteTime', time, True, 0);
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

function PawnKilled(pawn killed, pawn killer)
{
	local Pawn curPawn;
	local int i;
	
	if (killed == Player)
		return;
		
	i=0;
	for (curPawn=Level.PawnList; curPawn != None; curPawn=curPawn.nextPawn)
	{
		if (ScriptedPawn(curPawn) != None && curPawn.Health > 0 && !curPawn.IsInState('Dying') && ScriptedPawn(curPawn).bInWorld)
		{
			i++;
		}
	}
	if (i == 0)
		CompleteLevel();
	else
		Player.ClientMessage(sprintf(remainingtargets, i));
}

function DoChallenge1FirstFrame()
{
    local Skill aSkill;
    local Inventory item, nextItem, anItem;
    local ScriptedPawn curPawn;

    anItem = Spawn(class<Ammo>(DynamicLoadObject("TNMItems.Ammo45",class'Class')));
    Ammo(anItem).AmmoAmount=80;
    anItem.Frob(Player, None);
    anItem = Spawn(class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponDoubleGuns",class'Class')));
    if (TNMWeapon(anItem) != None)
        TNMWeapon(anItem).bItemRefusalOverride = True;
    anItem.Frob(Player, None);
    anItem.bInObjectBelt = True;
	Player.PutInHand(anItem);
	Player.SetInHandPending(anItem);
}

function DoChallenge2FirstFrame()
{
    local Skill aSkill;
    local Inventory item, nextItem, anItem;
    local ScriptedPawn curPawn;

    anItem = Spawn(class'Ammo762mm');
    Ammo(anItem).AmmoAmount=240;
    anItem.Frob(Player, None);
    anItem = Spawn(class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMAssaultGun",class'Class')));
    if (TNMWeapon(anItem) != None)
        TNMWeapon(anItem).bItemRefusalOverride = True;
    anItem.Frob(Player, None);
    anItem.bInObjectBelt = True;
	Player.PutInHand(anItem);
	Player.SetInHandPending(anItem);
}

function DoChallenge3FirstFrame()
{
    local Skill aSkill;
    local Inventory item, nextItem, anItem;
    local Pawn curPawn;

    anItem = Spawn(class'Ammo3006');
    Ammo(anItem).AmmoAmount=60;
    anItem.Frob(Player, None);
    anItem = Spawn(class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMRifle",class'Class')));
    if (TNMWeapon(anItem) != None)
        TNMWeapon(anItem).bItemRefusalOverride = True;
    anItem.Frob(Player, None);
    anItem.bInObjectBelt = True;
	Player.PutInHand(anItem);
	Player.SetInHandPending(anItem);
	
	for (curPawn=Level.PawnList; curPawn != None; curPawn=curPawn.nextPawn)
	{
		if (ScriptedPawn(curPawn) != None)
		{
			ScriptedPawn(curPawn).bHasCloak = False;
			curPawn.Health = 2;
			curPawn.HealthHead = 2;
			curPawn.HealthTorso = 2;
		}
	}
	switch (Trestkon(Player).combatMinigameDifficulty)
	{
		case 2:	// Hard
			aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillWeaponRifle');
			if (aSkill != None)
				aSkill.CurrentLevel = 1;
			break;
	}
}

function DoChallenge4FirstFrame()
{
    local Skill aSkill;
    local Inventory item, nextItem, anItem;
    local ScriptedPawn curPawn;

    anItem = Spawn(class'AmmoLAM');
    Ammo(anItem).AmmoAmount=2;
    anItem.Frob(Player, None);
    anItem = Spawn(class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMLAM",class'Class')));
    if (TNMWeapon(anItem) != None)
        TNMWeapon(anItem).bItemRefusalOverride = True;
    anItem.Frob(Player, None);
    anItem.bInObjectBelt = True;
	Player.PutInHand(anItem);
	Player.SetInHandPending(anItem);
}

function DoChallenge5FirstFrame()
{
    local Skill aSkill;
    local Inventory item, nextItem, anItem;
    local ScriptedPawn curPawn;

    // anItem = Spawn(class'AmmoLAM');
    // Ammo(anItem).AmmoAmount=2;
    // anItem.Frob(Player, None);
    anItem = Spawn(class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMNanosword",class'Class')));
    if (TNMWeapon(anItem) != None)
        TNMWeapon(anItem).bItemRefusalOverride = True;
    anItem.Frob(Player, None);
    anItem.bInObjectBelt = True;
	Player.PutInHand(anItem);
	Player.SetInHandPending(anItem);
}

function DoChallenge6FirstFrame()
{
    local Skill aSkill;
    local Inventory item, nextItem, anItem;
    local ScriptedPawn curPawn;

    anItem = Spawn(class'AmmoRocket');
    Ammo(anItem).AmmoAmount=2;
    anItem.Frob(Player, None);
    anItem = Spawn(class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMGEPGun",class'Class')));
    if (TNMWeapon(anItem) != None)
        TNMWeapon(anItem).bItemRefusalOverride = True;
    anItem.Frob(Player, None);
    anItem.bInObjectBelt = True;
	Player.PutInHand(anItem);
	Player.SetInHandPending(anItem);
}

function DoChallenge7FirstFrame()
{
}

function DoChallenge8FirstFrame()
{
    local Skill aSkill;
    local Inventory item, nextItem, anItem;
    local ScriptedPawn curPawn;

    anItem = Spawn(class'AmmoSabot');
    Ammo(anItem).AmmoAmount=24;
    anItem.Frob(Player, None);
    anItem = Spawn(class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMAssaultShotgun",class'Class')));
    if (TNMWeapon(anItem) != None)
	{
        TNMWeapon(anItem).bItemRefusalOverride = True;
	}
    anItem.Frob(Player, None);
    anItem.bInObjectBelt = True;
    if (TNMWeapon(anItem) != None)
	{
		TNMWeapon(anItem).LoadAmmo(1);
	}
	Player.PutInHand(anItem);
	Player.SetInHandPending(anItem);
}

defaultproperties
{
     beatPar="Par time beat!"
     overPar="%s over par!"
     remainingtargets="Remaining targets: %d"
     checkTime=0.250000
     RemoteRole=ROLE_DumbProxy
}

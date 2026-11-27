//=============================================================================
// SkillWeaponPistol.
//=============================================================================
class TNMSkillWeaponPistol extends SkillWeaponPistol;

simulated function PreBeginPlay()
{
	local DeusExLevelInfo info;
	
	Super(Skill).PreBeginPlay();

	//== Y|y: we only want to bump this up to Trained when starting a new game
	if ( True )
	{
		//== Y|y: this will detect if we're doing it from one of the intro (non-cinematic) maps
		foreach AllActors(class'DeusExLevelInfo', info)
		{
			if(info.MissionNumber < 0)
				CurrentLevel = 1;
		}

		//== Y|y: This detects if the player is starting a new game during an existing one
		if(DeusExPlayer(GetPlayerPawn()) != None)
			if(DeusExPlayer(GetPlayerPawn()).bShowMenu)
				CurrentLevel = 1;
	}

	if ( False && Level.NetMode != NM_Standalone )
	{
		cost[0] = mpCost1;
		cost[1] = mpCost2;
		cost[2] = mpCost3;
		LevelValues[0] = mpLevel0;
		LevelValues[1] = mpLevel1;
		LevelValues[2] = mpLevel2;
		LevelValues[3] = mpLevel3;
	}
}

defaultproperties
{
}

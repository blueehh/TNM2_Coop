class tnmaugmentationmanager extends augmentationmanager;

var float coopAugRestoreTimer;

simulated function int NumAugsActive()
{
	local Augmentation anAug;
	local int count;

	if (player == None)
		return 0;

	count = 0;
	anAug = FirstAug;
	while(anAug != None)
	{
		if (anAug.bHasIt && anAug.bIsActive && !anAug.bAlwaysActive)
			count++;

		anAug = anAug.next;
	}

	return count;
}

function Augmentation GetAugFromKey(int keynum)
{
	local Augmentation anAug;

	if ((keyNum < 0) || (keyNum > 9))
		return none;
	anAug = FirstAug;
	while(anAug != None)
	{
		if ((anAug.HotKeyNum - 3 == keyNum) && (anAug.bHasIt))
			break;
		anAug = anAug.next;
	}
	return anAug;
}

function DeactivateAll()
{
	local Augmentation anAug;

	anAug = FirstAug;
	while(anAug != None)
	{
		if (anAug.bIsActive && anAug.GetEnergyRate() != 0 )
			anAug.Deactivate();
		anAug = anAug.next;
	}
}

simulated function Float CalcEnergyUse(float deltaTime)
{
	local float energyUse;
	local Augmentation anAug;
	local Augmentation PowerAug;

	energyUse = 0;

	anAug = FirstAug;
	while(anAug != None)
	{
		if (anAug.IsA('AugPower'))
			PowerAug = anAug;
		if (anAug.bHasIt && anAug.bIsActive)
		{
			energyUse += ((anAug.GetEnergyRate()/60) * deltaTime);
		}
		anAug = anAug.next;
	}

	//Power aug is now always active
	if (PowerAug != none)				
		energyUse *= PowerAug.LevelValues[PowerAug.CurrentLevel];
		
	// log(energyUse);

	return energyUse;
}

//modified these to use classischildof:

simulated function Augmentation FindAugmentation(Class<Augmentation> findClass)
{
	local Augmentation anAug;

	anAug = FirstAug;
	while(anAug != None)
	{
		if (ClassIsChildOf(anAug.Class, findClass))
			break;

		anAug = anAug.next;
	}

	return anAug;
}

simulated function float GetAugLevelValue(class<Augmentation> AugClass)
{
	local Augmentation anAug;
	local float retval;

	retval = 0;

	anAug = FirstAug;
	while(anAug != None)
	{
		if (ClassIsChildOf(anAug.Class, augClass))
		{
			if (anAug.bHasIt && anAug.bIsActive)
				return anAug.LevelValues[anAug.CurrentLevel];
			else
				return -1.0;
		}

		anAug = anAug.next;
	}

	return -1.0;
}

simulated function int GetClassLevel(class<Augmentation> augClass)
{
	local Augmentation anAug;

	anAug = FirstAug;
	while(anAug != None)
	{
		if (ClassIsChildOf(anAug.Class, augClass))
		{
			if (anAug.bHasIt && anAug.bIsActive)
				return anAug.CurrentLevel;
			else
				return -1;
		}

		anAug = anAug.next;
	}

	return -1;
}

// ----------------------------------------------------------------------
// GivePlayerAugmentation()
// ----------------------------------------------------------------------

function Augmentation GivePlayerAugmentation(Class<Augmentation> giveClass)
{
	local Augmentation anAug;

	// Checks to see if the player already has it.  If so, we want to 
	// increase the level
	anAug = FindAugmentation(giveClass);

	if (anAug == None)
		return None;		// shouldn't happen, but you never know!

	if (anAug.bHasIt)
	{
		anAug.IncLevel();
		return anAug;
	}

	if (AreSlotsFull(anAug))
	{
		Player.ClientMessage(AugLocationFull);
		return anAug;
	}

	anAug.bHasIt = True;

	if (anAug.bAlwaysActive)
	{
		// Changed to allow EMP shield to instantly be upgraded by synthetic heart when installed
		anAug.Activate();
		//anAug.bIsActive = True;
		//anAug.GotoState('Active');
	}
	else
	{
		anAug.bIsActive = False;
	}


	Player.ClientMessage(Sprintf(anAug.AugNowHaveAtLevel, anAug.AugmentationName, anAug.CurrentLevel + 1));

	// Manage our AugLocs[] array
	AugLocs[anAug.AugmentationLocation].augCount++;
	
	// Assign hot key to new aug 
	// (must be after before augCount is incremented!)
	anAug.HotKeyNum = AugLocs[anAug.AugmentationLocation].augCount + AugLocs[anAug.AugmentationLocation].KeyBase;

	if ((!anAug.bAlwaysActive) && (Player.bHUDShowAllAugs))
	    Player.AddAugmentationDisplay(anAug);
		
	if (anAug.Owner != None)
	{
		anAug.AttachTag = Owner.Name;
		anAug.SetPhysics(PHYS_Trailer);
	}

	return anAug;
}

simulated function RestoreSinglePlayerAugStats()
{
	local Augmentation anAug;

	anAug = FirstAug;
	while (anAug != None)
	{
		anAug.EnergyRate = anAug.Default.EnergyRate;
		anAug.AugmentationLocation = anAug.Default.AugmentationLocation;
		anAug.LevelValues[0] = anAug.Default.LevelValues[0];
		anAug.LevelValues[1] = anAug.Default.LevelValues[1];
		anAug.LevelValues[2] = anAug.Default.LevelValues[2];
		anAug.LevelValues[3] = anAug.Default.LevelValues[3];
		if (Role == ROLE_Authority)
			anAug.SetOwner(Self);
		anAug = anAug.next;
	}
}

function CreateAugmentations(DeusExPlayer newPlayer)
{
	Super.CreateAugmentations(newPlayer);
	RestoreSinglePlayerAugStats();
}

function SetPlayer(DeusExPlayer newPlayer)
{
	Super.SetPlayer(newPlayer);
	RestoreSinglePlayerAugStats();
}

simulated event PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	RestoreSinglePlayerAugStats();
}

// Augmentations replicate after the manager, and each one's simulated
// PreBeginPlay swaps in its mp* level value on the client (AugSpeed level 4 is
// 2.0 instead of 1.8). LevelValues aren't replicated, so keep resetting them or
// the client predicts a different run speed than the server simulates.
simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (Role < ROLE_Authority)
	{
		coopAugRestoreTimer -= DeltaTime;
		if (coopAugRestoreTimer <= 0)
		{
			coopAugRestoreTimer = 1.0;
			RestoreSinglePlayerAugStats();
		}
	}
}

// ----------------------------------------------------------------------
// ActivateAugByKey()
// ----------------------------------------------------------------------

function bool ActivateAugByKey(int keyNum)
{	
	local Augmentation anAug;
	local bool bActivated;

	bActivated = False;

	if ((keyNum < 0) || (keyNum > 9))
		return False;

	anAug = FirstAug;
	while(anAug != None)
	{
		if ((anAug.HotKeyNum - 3 == keyNum) && (anAug.bHasIt))
			break;

		anAug = anAug.next;
	}

	if (anAug == None && Player != None)
	{
		player.ClientMessage(NoAugInSlot);
	}
	else if (Player != None)
	{
		// Toggle
		if (anAug.bIsActive)
			anAug.Deactivate();
		else if (Player.IsInState('Dying'))
		{
		}
		else if (Player.Energy == 0 && anAug.GetEnergyRate() > 0)
		{
			//G-Flex: mostly copied this from DeusExPlayer.ActivateAugmentation()
			//G-Flex: we can probably delete it from there
			Player.ClientMessage(Player.EnergyDepleted);
			Player.PlaySound(anAug.DeactivateSound, SLOT_None);
		}
		else
			anAug.Activate();
		//G-Flex: I don't think the return value ever actually does anything
		bActivated = True;
	}

	return bActivated;
}

// Smoke39 - I've added extra indentation to the augs that were already changed here
// (i.e., the ones that aren't just the DX aug with my aug can upgrade tweak)

defaultproperties
{
     augClasses(0)=Class'TNM.tnmpcAugSpeed'
     augClasses(1)=Class'TNM.tnmpcAugTarget'
     augClasses(2)=Class'TNM.tnmpcAugCloak'
     augClasses(3)=Class'TNM.tnmpcAugBallistic'
     augClasses(4)=Class'TNM.tnmpcAugRadarTrans'
     augClasses(5)=Class'TNM.tnmpcAugShield'
     augClasses(6)=Class'TNM.tnmpcAugEnviro'
     augClasses(7)=Class'TNM.tnmpcAugEMP'
     augClasses(8)=Class'TNM.tnmpcAugCombat'
     augClasses(9)=Class'TNM.tnmpcAugHealing'
     augClasses(10)=Class'TNM.tnmpcAugStealth'
     augClasses(12)=Class'TNM.tnmAugLight'
     augClasses(13)=Class'TNM.tnmpcAugMuscle'
     augClasses(14)=Class'TNM.tnmpcAugVision'
     augClasses(15)=Class'TNM.tnmpcAugDrone'
     augClasses(16)=Class'TNM.tnmpcAugDefense'
     augClasses(17)=Class'TNM.AugBot'
     augClasses(18)=Class'TNM.AugPM'
     augClasses(19)=Class'TNM.tnmpcAugHeartLung'
     augClasses(20)=Class'TNM.tnmpcAugPower'
     augClasses(21)=Class'TNM.tnmpcAugAqualung'
     augClasses(22)=Class'TNM.AugAimbot'
     defaultAugs(0)=Class'TNM.tnmAugLight'
     defaultAugs(2)=Class'TNM.AugPM'
}

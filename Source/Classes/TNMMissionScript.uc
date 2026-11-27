class TNMMissionScript extends MissionScript;

var float wait;
var int trafficlighttimer;

var int PDXFloor1AggressiveKills;
var int GoatCityAggressiveKills;
var int LlamaTempleAggressiveKills;
var int DXOAggressiveKills;
var int FCAggressiveKills;

var name CountExclusions[32];

var bool bNeedToCount;

var() localized string trestkonMissingMsg;
var() localized string trestkonMissingTitle;
var localized string strTetris, strPong, strBreakout, strLightsOut;


function fade( float fadetime, actor target, bool fadein)
{
	local fader f;
	f=Spawn(Class'fader');
	f.SetBase(target);
	f.Start(fadetime, target, fadein);
}

function DecrementTimers()
{
}

function HandleTimers()
{
}

function DecrementTimer(name timerstartedname, name timername)
{
	local int old;
	if (flags != none)
	{
		if (flags.GetBool(timerstartedname))
		{
			old = flags.GetInt(timername);
			if (old > 0)
			{
				flags.SetInt(timername,old - 1,,);
			}
		}
	}
}

function DeleteTimer(name timerstartedname, name timername)
{
	flags.DeleteFlag(timerstartedname, FLAG_Bool);
	flags.DeleteFlag(timername, FLAG_Int);
}

function AddTimer(name timerstartedname, name timername, int seconds)
{
	if (!flags.GetBool(timerstartedname))
	{
		flags.SetBool(timerstartedname, true,,);
		flags.SetInt(timername,seconds,,);
	}
}

function bool IsTimerDone(name timerstartedname, name timername)
{
	if (flags != none)
	{
		if (flags.GetBool(timerstartedname))
		{
			return flags.GetInt(timername) <= 0;
		}
		else
			return false;
	}
}

function PlayerDetected(name StateType, optional ScriptedPawn Triggerer)
{
}

function HandleGameEvent(name scriptFunction)
{
	//child classes should overwrite this.
	//They will contain a case statement that works out which function to call.
	//Upon finding the function they should call it and then return
	//If the function cannot be handled this super function should be called which
	//will log the error

	//Function not found in script

	switch ( scriptFunction )
	{
		case 'PlayOutroTrack': PlayOutroTrack(); break;
		default: Log("Function '" $ scriptFunction $ "' could not be found in mission script");
	}
}

function PlayOutroTrack()
{
    local tnmoggmusicmanager ogg;
    foreach allactors(class'tnmoggmusicmanager', ogg)
    {
        ogg.bPlayOutro = true;
    }
}

function SetupExclusions()
{
}

function int Killed()
{
	return ExpectedLiving(localURL) - CountLiving(localURL);
}

function Name SafeStringToName(string S)
{
	local Name oldTag, result;

	if (S == "")
		return '';
	if (Trestkon(Player) != None)
		return Trestkon(Player).SafeStringToName(S);
	if (Player != None && Player.rootWindow != None)
		return Player.rootWindow.StringToName(S);
	oldTag = Tag;
	Tag = '';
	SetPropertyText("Tag", S);
	result = Tag;
	Tag = oldTag;
	return result;
}

function bool PlayerHasItem(Name itemType)
{
	local Inventory item, nextItem, lastItem;
	local Pawn P;
	local DeusExPlayer checkPlayer;

	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		checkPlayer = DeusExPlayer(P);
		if (checkPlayer != None && checkPlayer.Inventory != None)
		{
			item = checkPlayer.Inventory;
			nextItem = item.Inventory;
			lastItem = item;

			do
			{
				if ((item != None) && item.IsA(itemType))
					return true;

				item = nextItem;

				if (item != None)
					nextItem = item.Inventory;
			}
			until ((item == None) || (item == lastItem));
		}
	}

	return false;
}

function int ExpectedLiving(string location)
{
	local name flagname;
	flagname = SafeStringToName(location $ "_StartCount");
	return flags.getint(flagname);
}

function int CountLiving(string location)
{
	local name flagname;
 	if ( player != none && flags != None) //if the player is none forget it.
	{
		flagname = SafeStringToName(location $ "_Count");
		if (localURL ~= location)
		{
			SetupExclusions();
			flags.SetInt(flagname, CountCareLiving(), ,26);
		}
		return flags.getint(flagname);
	}
	else
	{
		return 999999;
	}
}

function int DoInitialCount()
{
	local name flagname;
	local int count;
	
	flagname = SafeStringToName(localurl $ "_StartCount");
	if ( flags.getint(flagname) != 0 )
	{
		count = flags.getint(flagname);
	}
	else
	{
		count = CountLiving(localurl);
		flags.SetInt(flagname, count, , 26);
	}

	return count;
}

function int CountCareLiving()
{
	local TNMPawn p;
	local TNMCarcass c;
	local tnmpovcorpse povc;
	local int count;
	local int i;
	local bool b;

	count = 0;
	foreach AllActors(class'TNMPawn', p) // Should this count instate dying? Maybe not because bStunned isn't set yet?
	{
		b = true;

		for ( i=0; i < ArrayCount(CountExclusions) && CountExclusions[i] != ''; i++)
		{
			if ( CountExclusions[i] == p.Tag )
				b = false;
		}

		if ( b )
		{
			if ( p.IsA('tnmAnimal') )
				b = false;
		}

		if ( b )
		{
			switch ( trestkon(player).PawnDifficulty )
			{
				case 0: b = P.bDifficulty0;break;
				case 1: b = P.bDifficulty1;break;
				case 2: b = P.bDifficulty2;break;
				case 3: b = P.bDifficulty3;break;
			}
		}

		if ( b )
		{
			count++;
		}
	}
	foreach AllActors(class'TNMCarcass', c)
	{
		b = true;
		for ( i=0; i < ArrayCount(CountExclusions) && CountExclusions[i] != ''; i++)
		{
			if (c.Tag == CountExclusions[i])
				b = false;
		}
		if ( b )
		{
			if (c.bNotDead)
				count++;
			else if (c.KillerBindName != "JCDenton" && c.KillerBindName != "") // Pre-placed carcasses shouldn't count, right?
				count++;
			else if (c.bAnimalCarcass)
				count++;
		}
	}
	foreach AllActors(class'tnmPovCorpse', povc)
	{
		b = true;
		for ( i=0; i < ArrayCount(CountExclusions) && CountExclusions[i] != ''; i++)
		{
			if (povc.Tag == CountExclusions[i])
				b = false;
		}
		if ( b )
		{
			if (povc.bNotDead)
				count++;
			else if (povc.KillerBindName != "JCDenton")
				count++;
		}
	}
	return count;
}

function KnockOut(TNMPawn p)
{
	p.HealthTorso = 0;
	p.Health = 0;
	p.bStunned = True;
	p.TakeDamage(1, p, p.Location, vect(0,0,0), 'KnockedOut');
}

function OpenDoor(deusexmover m)
{
	m.GotoState( 'TriggerControl',  );
	m.trigger(self,none);
	m.bLocked = false;
}

function SealDoor(name door)
{
	local deusexmover m;
	foreach allactors(class'deusexmover', m, door)
	{
		if (m.keynum != 0)
		{
			m.GotoState( 'TriggerToggle',  );
			m.trigger(self,none);
		}
		m.bLocked = true;
		m.bPickable = false;
		m.bBreakable = false;
		m.bFrobbable = false;
		m.PostBeginPlay();
	}
}

function SkillAward(int skillPointsAdded, string awardMessage)
{
	local Pawn P;
	local Trestkon T;

	if (Level.NetMode != NM_Standalone)
	{
		for (P = Level.PawnList; P != None; P = P.NextPawn)
		{
			T = Trestkon(P);
			if (T != None)
			{
				T.SkillPointsAdd(skillPointsAdded);
				T.ClientMessage(awardMessage);
			}
		}
	}
	else if (player != None)
	{
		player.SkillPointsAdd(skillPointsAdded);
		player.ClientMessage(awardMessage);
	}
}

function FirstFrame()
{
	local deusexrootwindow root;
	local window warning;
	local name flagName;
	local TNMPawn P;
	local int i, j;
	local TNMWeapon ourWeapon;
	local Actor anActor;
	local Seat aSeat;
	local DeusExDecoration aDeco;
	local ThrownProjectile aMine;
	local TNMRobot bots;
	local SecurityCamera aCam;
	local DeusExMover M;

	if (!player.isA('trestkon'))
	{
		Log("TNM Player class not being used. Please Reinstall");
		root = DeusExRootWindow(player.rootWindow);
		if (root != none)
		{
			warning = MessageBox(trestkonMissingTitle,trestkonMissingMsg , 1, True, none);
		}
	}

	flags.DeleteFlag('PlayerTraveling', FLAG_Bool);

	if (Level.NetMode != NM_Standalone)
		RestoreCoopMapState();

	// Check to see which NPCs should be dead from prevous missions
	foreach AllActors(class'TNMPawn', P)
	{
		if (P.bImportant)
		{
			flagName = SafeStringToName(P.BindName$"_Dead");
			if (flags.GetBool(flagName))
			{
				if (p.BindName == "Kylie" && dxinfo.missionnumber == 24)
					p.SwitchToKilledSkin();
				else
					P.Destroy();
			}
		}
	}

	// Fix return on encroach movers with default tag affecting all other movers with same tag
	foreach AllActors(class'DeusExMover', M)
	{
		if (M.Tag == M.Class.Name)
		{
			M.ReturnGroup = '';
			M.Leader = M;
			M.Follower = None;
		}
	}
	
	foreach AllActors(class'ThrownProjectile', aMine)
		if (aMine.IsA('TripProj') && aMine.Owner == None)
			aMine.bStuck = True; // Allow frobbing
	
	// Prevent cameras from going into stasis
	foreach AllActors(class'SecurityCamera', aCam)
		aCam.Default.bStasis = False;
	
	// Fix WHRedCouch sitPoints
	foreach AllActors(class'Seat', aSeat)
	{
		if (WHRedCouch(aSeat) != None)
		{
			aSeat.SitPoint[0].Y = -6.5;
			aSeat.SitPoint[1].Y = -6.5;
		}
	}

	// print the mission startup text only once per map
	if (dxInfo != None && dxInfo.MissionNumber >= 0)
	{
		flagName = SafeStringToName("M"$Caps(dxInfo.mapName)$"_StartupText");
		if (!flags.GetBool(flagName) && (dxInfo.startupMessage[0] != ""))
		{
			if (DeusExRootWindow(Player.rootWindow) != None && DeusExRootWindow(Player.rootWindow).hud != None && DeusExRootWindow(Player.rootWindow).hud.startDisplay != None)
			{
				for (i=0; i<ArrayCount(dxInfo.startupMessage); i++)
					DeusExRootWindow(Player.rootWindow).hud.startDisplay.AddMessage(dxInfo.startupMessage[i]);
				DeusExRootWindow(Player.rootWindow).hud.startDisplay.StartMessage();
			}
			flags.SetBool(flagName, True);
		}

		flagName = SafeStringToName("M"$dxInfo.MissionNumber$"MissionStart");
		if (!flags.GetBool(flagName))
		{
			// Remove completed Primary goals and all Secondary goals
			Player.ResetGoals();

			// Remove any Conversation History.
			Player.ResetConversationHistory();

			// Set this flag so we only get in here once per mission.
			flags.SetBool(flagName, True);
		}
	}

	bNeedToCount = true;
	
	ourWeapon = TNMWeapon(Player.Weapon);
	
	if (ourWeapon != None && ourWeapon.bWasLasing)
	{
		if (dxInfo.MissionNumber != 25)
			ourWeapon.LaserOn();
		ourWeapon.bWasLasing = False;
	}
	
	root = DeusExRootWindow(Player.rootWindow);
	
	// Transcended - Autosave
	if((Trestkon(Player).bUseAutosave/* > 0*/) && dxInfo != None && !(player.IsInState('Dying')) && !(player.IsInState('Paralyzed')) && !(player.IsInState('Interpolating')) && !(player.IsInState('Conversation')) && player.dataLinkPlay == None && Level.Netmode == NM_Standalone && dxInfo.MissionNumber > 0 && dxInfo.MissionNumber < 98 && !flags.GetBool(Player.rootWindow.StringToName(dxInfo.MapName $ '_AutoSaveCreated')) && root != None && root.GetTopWindow() == None)
	{
		flags.SetBool(Player.rootWindow.StringToName(dxInfo.MapName $ '_AutoSaveCreated') , True, True, 0);
		Spawn(Class'tnmAutosave');
	}
	
	// Animated bot treads
	foreach AllActors (class'TNMRobot', bots)
	{
		if (bots.bHasTreads)
		{
			if (bots.ScriptedTexID == -1)
			{
				j++;
				bots.ScriptedTexID = j;
				bots.SetTreads();
			}
			else
				j = bots.ScriptedTexID;
		}
	}
	
	// Fix bBlockSight
	foreach AllActors(class'DeusExDecoration', aDeco)
	{
		if (aDeco.IsA('ClothesRack') || aDeco.IsA('VendingMachine') || aDeco.IsA('AutoTurret') || aDeco.IsA('Cart') || aDeco.IsA('HKBuddha') || aDeco.IsA('IncenseBurner') || aDeco.IsA('SignFloor') || aDeco.IsA('WaterCooler') || aDeco.IsA('WaterFountain') || aDeco.IsA('WHCabinet') || aDeco.IsA('HKTukTuk') || aDeco.IsA('Van') || aDeco.IsA('Mailbox') || aDeco.IsA('NYEagleStatue') || aDeco.IsA('Bushes1') || aDeco.IsA('Bushes2') || aDeco.IsA('Bushes3') || aDeco.IsA('ChairLeather') || aDeco.IsA('CouchLeather') || aDeco.IsA('TrashBag') || aDeco.IsA('TrashBag2') || aDeco.IsA('TrashCan1') || aDeco.IsA('TrashCan2') || aDeco.IsA('TrashCan3') || aDeco.IsA('TrashCan4') || aDeco.IsA('Plant1') || aDeco.IsA('Plant2'))
			aDeco.bBlockSight = True;
			
		if (aDeco.IsA('Plant1') || aDeco.IsA('Plant2') || aDeco.IsA('Plant3') || aDeco.IsA('HKBirdCage') || aDeco.IsA('HKChair') || aDeco.IsA('HKCouch') || aDeco.IsA('HKHangingLantern') || aDeco.IsA('HKHangingLantern2') || aDeco.IsA('HKIncenseBurner') || aDeco.IsA('HKMarketTable') || aDeco.IsA('HKTable') || aDeco.IsA('WHTableBlue') || aDeco.IsA('WHRedOvalTable') || aDeco.IsA('WHRedLampTable') || aDeco.IsA('WHRedEagleTable') || aDeco.IsA('WHRedCouch') || aDeco.IsA('WHPiano') || aDeco.IsA('WHEndTableLibrary') || aDeco.IsA('WHDeskOvalOffice') || aDeco.IsA('WHDeskLibrarySmall') || aDeco.IsA('WHChairPink') || aDeco.IsA('WHChairOvalOffice') || aDeco.IsA('WHChairDining') || aDeco.IsA('WHCabinet') || aDeco.IsA('WHBookstandLibrary') || aDeco.IsA('WHBenchLibrary') || aDeco.IsA('WHBenchEast') || aDeco.IsA('Mailbox') || aDeco.IsA('Flowers') || aDeco.IsA('Cushion') || aDeco.IsA('Pillow') || aDeco.IsA('Flagpole') || aDeco.IsA('CouchLeather') || aDeco.IsA('ChairLeather') || aDeco.IsA('OfficeChair') || aDeco.IsA('ClothesRack') || aDeco.IsA('CoffeeTable') || aDeco.IsA('Chair1'))
			aDeco.bFlammable = True;
			
		if (aDeco.IsA('Tree'))
			if (Tree(aDeco).soundFreq == Tree(aDeco).Default.soundFreq )
				Tree(aDeco).soundFreq = 0.02;
			
		aDeco.bCanTeleport = True; // DXI ruins
	}
	
	/*
	// Split the map into two
	foreach AllActors(class'Actor', anActor)
	{
		if (MapExit(anActor) != None)
		{
			if (MapExit(anActor).DestMap ~= "22_FCSLUMS")
			{
				if (flags.GetBool('ALLIED_PDX'))
					MapExit(anActor).DestMap = "22_FCSLUMS_PDX";
				else if (flags.GetBool('ALLIED_WC'))
					MapExit(anActor).DestMap = "22_FCSLUMS_WC";
			}
		}
		else if (Teleporter(anActor) != None)
		{
			if (Teleporter(anActor).URL ~= "22_FCSLUMS")
			{
				if (flags.GetBool('ALLIED_PDX'))
					Teleporter(anActor).URL = "22_FCSLUMS_PDX";
				else if (flags.GetBool('ALLIED_WC'))
					Teleporter(anActor).URL = "22_FCSLUMS_WC";
			}
		}
	}
	*/
}

//fixes a FirstFrame delay
function Tick(float dt)
{
	if ( bNeedToCount )
	{
		if (trestkon(player).bFiltered)
		{
			DoInitialCount();
			bNeedToCount = false;
		}
	}

	if(wait<0)
		return;
	wait-=dt;
	if(wait<0)
		super.Timer();
}

function Timer()
{
	local int i;
	local DeusExRootWindow 	root;
	local ScriptedTextureGSTVOn TVController;
	local scaledsprite lightsprite;
	local vector newLoc;
	
//	super.Timer();

	if (localURL == "TNM")
	{
		trafficlighttimer++;
		foreach AllActors(class'ScaledSprite', lightsprite, 'TrafficLightSprite')
		{
			if ((trafficlighttimer % 60) == 58)
			{
				newLoc = LightSprite.Location;
				switch (LightSprite.LightHue)
				{
					case 0:
						LightSprite.LightHue = 50;
						NewLoc.Z -= 17;
						break;
					case 101:
						LightSprite.LightHue = 51;
						NewLoc.Z += 17;
						break;						
				}
				LightSprite.Texture = Texture'DeusExDeco.Skins.AlarmLightTex8';
				LightSprite.DrawScale = 1.75;
				LightSprite.SetLocation(newLoc);
			}
			else if ((trafficlighttimer % 60) == 0)
			{
				newLoc = LightSprite.Location;
				switch (LightSprite.LightHue)
				{
					case 50:
						LightSprite.LightHue = 101;
						LightSprite.Texture = Texture'DeusExDeco.Skins.AlarmLightTex4';
						LightSprite.DrawScale = 1.25;
						NewLoc.Z -= 17;
						break;
					case 51:
						LightSprite.LightHue = 0;
						LightSprite.Texture = Texture'DeusExDeco.Skins.AlarmLightTex2';
						LightSprite.DrawScale = 2.00;
						NewLoc.Z += 17;
						break;
				}
				LightSprite.SetLocation(newLoc);
			}
		}
	}
	else if (localURL == "TWEENANIMTEST")
	{
		SetTimer(0.1, True);
		if (flags.GetBool('TweenAnimTest_GreaselAnims'))
		{
			for (i=0; i<8; i++)
			{
				switch(i)
				{
					case 0:
						Player.ViewModelLoop(i, 'Walk');
						Player.ViewModelBlendPlay(i+1, 'BreatheLight');
						break;
					case 1:
						Player.ViewModelLoop(i+1, 'DeathFront');
						Player.ViewModelBlendPlay(i+1, 'Run');
						break;
					case 2:
						Player.ViewModelLoop(i+1, 'DeathFront');
						Player.ViewModelBlendPlay(i+1, 'Attack');
						break;
					case 3:
						Player.ViewModelLoop(i+1, 'Tread');
						Player.ViewModelBlendPlay(i+1, 'WaterAttack');
						break;
					case 4:
						Player.ViewModelLoop(i+1, 'Eat');
						break;
					case 5:
						Player.ViewModelLoop(i+1, 'Tread');
						Player.ViewModelBlendPlay(i+1, 'Eat');
						break;
					case 6:
						Player.ViewModelLoop(i+1, 'Run');
						Player.ViewModelBlendPlay(i+1, 'Eat');
						break;
					case 7:
						Player.ViewModelLoop(i+1, 'Run');
						Player.ViewModelBlendPlay(i+1, 'Attack');
						break;
				}
			}
			flags.SetBool('TweenAnimTest_GreaselAnims', False);
		}
		if (flags.GetBool('TweenAnimTest_Greasel'))
		{
			Player.ViewModelDestroy(0);
			for (i=0; i<8; i++)
			{
				Player.ViewModelAdd(i+1, "Greasel");
				if (Player.ViewModelActor[i] != None)
				{
					Player.ViewModelActor[i].SetLocation(GetSpawnPoint(Player.rootWindow.StringToName("Spawn"$i+1)).Location);
					Player.ViewModelActor[i].SetRotation(GetSpawnPoint(Player.rootWindow.StringToName("Spawn"$i+1)).Rotation);
				}
			}
			flags.SetBool('TweenAnimTest_Greasel', False);
			flags.SetBool('TweenAnimTest_GreaselAnims', True);
		}
		
		if (flags.GetBool('TweenAnimTest_DobermanAnims'))
		{
			for (i=0; i<8; i++)
			{
				switch(i)
				{
					case 0:
						Player.ViewModelLoop(i, 'Run');
						Player.ViewModelBlendPlay(i+1, 'Attack');
						break;
					case 1:
						Player.ViewModelLoop(i+1, 'Attack');
						Player.ViewModelBlendPlay(i+1, 'Run');
						break;
					case 2:
						Player.ViewModelLoop(i+1, 'Run');
						Player.ViewModelBlendPlay(i+1, 'BreatheLight');
						break;
					case 3:
						Player.ViewModelLoop(i+1, 'BreatheLight');
						Player.ViewModelBlendPlay(i+1, 'Run');
						break;
					case 4:
						Player.ViewModelLoop(i+1, 'Run');
						Player.ViewModelBlendPlay(i+1, 'Bark');
						break;
					case 5:
						Player.ViewModelLoop(i+1, 'Bark');
						Player.ViewModelBlendPlay(i+1, 'Run');
						break;
					case 6:
						Player.ViewModelLoop(i+1, 'Run');
						Player.ViewModelBlendPlay(i+1, 'DeathFront');
						break;
					case 7:
						Player.ViewModelLoop(i+1, 'DeathFront');
						Player.ViewModelBlendPlay(i+1, 'Run');
						break;
				}
			}
			flags.SetBool('TweenAnimTest_DobermanAnims', False);
		}
		if (flags.GetBool('TweenAnimTest_Doberman'))
		{
			Player.ViewModelDestroy(0);
			for (i=0; i<8; i++)
			{
				Player.ViewModelAdd(i+1, "Doberman");
				if (Player.ViewModelActor[i] != None)
				{
					Player.ViewModelActor[i].SetLocation(GetSpawnPoint(Player.rootWindow.StringToName("Spawn"$i+1)).Location);
					Player.ViewModelActor[i].SetRotation(GetSpawnPoint(Player.rootWindow.StringToName("Spawn"$i+1)).Rotation);
				}
			}
			flags.SetBool('TweenAnimTest_Doberman', False);
			flags.SetBool('TweenAnimTest_DobermanAnims', True);
		}
		
		if (flags.GetBool('TweenAnimTest_KarkianAnims'))
		{
			for (i=0; i<8; i++)
			{
				switch(i)
				{
					case 0:
						Player.ViewModelLoop(i, 'Run');
						Player.ViewModelBlendPlay(i+1, 'Attack');
						break;
					case 1:
						Player.ViewModelLoop(i+1, 'Attack');
						Player.ViewModelBlendPlay(i+1, 'Run');
						break;
					case 2:
						Player.ViewModelLoop(i+1, 'Run');
						Player.ViewModelBlendPlay(i+1, 'BreatheLight');
						break;
					case 3:
						Player.ViewModelLoop(i+1, 'BreatheLight');
						Player.ViewModelBlendPlay(i+1, 'Run');
						break;
					case 4:
						Player.ViewModelLoop(i+1, 'Tread');
						Player.ViewModelBlendPlay(i+1, 'Roar');
						break;
					case 5:
						Player.ViewModelLoop(i+1, 'Roar');
						Player.ViewModelBlendPlay(i+1, 'Tread');
						break;
					case 6:
						Player.ViewModelLoop(i+1, 'Run');
						Player.ViewModelBlendPlay(i+1, 'Roar');
						break;
					case 7:
						Player.ViewModelLoop(i+1, 'Roar');
						Player.ViewModelBlendPlay(i+1, 'Run');
						break;
				}
			}
			flags.SetBool('TweenAnimTest_KarkianAnims', False);
		}
		if (flags.GetBool('TweenAnimTest_Karkian'))
		{
			Player.ViewModelDestroy(0);
			for (i=0; i<8; i++)
			{
				Player.ViewModelAdd(i+1, "KarkianBaby");
				if (Player.ViewModelActor[i] != None)
				{
					Player.ViewModelActor[i].SetLocation(GetSpawnPoint(Player.rootWindow.StringToName("Spawn"$i+1)).Location);
					Player.ViewModelActor[i].SetRotation(GetSpawnPoint(Player.rootWindow.StringToName("Spawn"$i+1)).Rotation);
				}
			}
			flags.SetBool('TweenAnimTest_Karkian', False);
			flags.SetBool('TweenAnimTest_KarkianAnims', True);
		}
		
		if (flags.GetBool('TweenAnimTest_HumanAnims'))
		{
			for (i=0; i<8; i++)
			{
				switch(i)
				{
					case 0:
						Player.ViewModelLoop(i, 'CrouchShoot');
						Player.ViewModelBlendPlay(i+1, 'RunShoot2H');
						break;
					case 1:
						Player.ViewModelLoop(i+1, 'RunShoot2H');
						Player.ViewModelBlendPlay(i+1, 'CrouchShoot');
						break;
					case 2:
						Player.ViewModelLoop(i+1, 'Run');
						Player.ViewModelBlendPlay(i+1, 'RubEyes');
						break;
					case 3:
						Player.ViewModelLoop(i+1, 'RubEyes');
						Player.ViewModelBlendPlay(i+1, 'Run');
						break;
					case 4:
						Player.ViewModelLoop(i+1, 'Dance');
						Player.ViewModelBlendPlay(i+1, 'Panic');
						break;
					case 5:
						Player.ViewModelLoop(i+1, 'Panic');
						Player.ViewModelBlendPlay(i+1, 'Dance');
						break;
					case 6:
						Player.ViewModelLoop(i+1, 'Walk');
						Player.ViewModelBlendPlay(i+1, 'Shocked');
						break;
					case 7:
						Player.ViewModelLoop(i+1, 'Shocked');
						Player.ViewModelBlendPlay(i+1, 'Walk');
						break;
				}
			}
			flags.SetBool('TweenAnimTest_HumanAnims', False);
		}
		if (flags.GetBool('TweenAnimTest_Human'))
		{
			Player.ViewModelDestroy(0);
			for (i=0; i<8; i++)
			{
				Player.ViewModelAdd(i+1, "SecretService");
				if (Player.ViewModelActor[i] != None)
				{
					Player.ViewModelActor[i].SetLocation(GetSpawnPoint(Player.rootWindow.StringToName("Spawn"$i+1)).Location);
					Player.ViewModelActor[i].SetRotation(GetSpawnPoint(Player.rootWindow.StringToName("Spawn"$i+1)).Rotation);
				}
			}
			flags.SetBool('TweenAnimTest_Human', False);
			flags.SetBool('TweenAnimTest_HumanAnims', True);
		}
	}
	
	if (localURL == "95_COMPUTERROOM")
	{
		foreach AllActors(class'ScriptedTextureGSTVOn', TVController)
		{
			TVController.TextSmall[0] = "/n";
			TVController.TextSmall[0] = TVController.TextSmall[0] $ sprintf("~" @ strTetris, Trestkon(Player).GameHighScoreTetris) $ "/n";
			TVController.TextSmall[0] = TVController.TextSmall[0] $ sprintf("~" @ strPong, Trestkon(Player).GameHighScorePong) $ "/n";
			TVController.TextSmall[0] = TVController.TextSmall[0] $ sprintf("~" @ strBreakout, Trestkon(Player).GameHighScoreBreakout) $ "/n";
			TVController.TextSmall[0] = TVController.TextSmall[0] $ sprintf("~" @ strLightsOut, Trestkon(Player).GameHighScoreLightsOut);
			// TVController.TextLarge[1] = TVController.TextLarge[0];
			// TVController.TextSmall[1] = TVController.TextSmall[0];
		}
	}
	
	DecrementTimers();
	HandleTimers();
	
	root = DeusExRootWindow(Player.rootWindow);
	
	// Transcended - Autosave
	if((Trestkon(Player).bUseAutosave/* > 0*/) && dxInfo != None && !(player.IsInState('Dying')) && !(player.IsInState('Paralyzed')) && !(player.IsInState('Interpolating')) && !(player.IsInState('Conversation')) && player.dataLinkPlay == None && Level.Netmode == NM_Standalone && dxInfo.MissionNumber > 0 && dxInfo.MissionNumber < 98 && !flags.GetBool(Player.rootWindow.StringToName(dxInfo.MapName $ '_AutoSaveCreated')) && root != None && root.GetTopWindow() == None)
	{
		flags.SetBool(Player.rootWindow.StringToName(dxInfo.MapName $ '_AutoSaveCreated') , True, True, 0);
		Spawn(Class'tnmAutosave');
	}
}

function MenuUIMessageBoxWindow MessageBox
	( 
	String msgTitle,
	String msgText, 
	int msgBoxMode, 
	bool hideCurrentScreen,
	Window winParent
	)	
{
	local MenuUIMessageBoxWindow msgBox;
	local DeusExRootWindow root;

	root = DeusExRootWindow(player.rootWindow);

	msgBox = MenuUIMessageBoxWindow(root.PushWindow(Class'MessageSelfDestroy', hideCurrentScreen ));
	msgBox.SetTitle(msgTitle);
	msgBox.SetMessageText(msgText);
	msgBox.SetMode(msgBoxMode);
	msgBox.SetNotifyWindow(winParent);

	return msgBox;
}


function PreTravel()
{
	local FollowingSound aSound;
	
	if (Player == None)
		Player = DeusExPlayer(GetPlayerPawn());
	if (flags == None && Player != None)
		flags = Player.FlagBase;

	if (Level.NetMode != NM_Standalone)
		SaveCoopMapState();

	CountLiving(localURL);
	if ( player != none )
		trestkon(player).LastMap = localURL;
	foreach AllActors(class'FollowingSound', aSound)
		aSound.Destroy();
	super.PreTravel();
	SetTimer(0.0, False);
	flags = None;
	Player = None;
	dxInfo = None;
}

function SaveCoopMapState()
{
	local int expMission, mvrState, camState, keptInvCount, keptDecoCount, it;
	local Name visitFlag, keepFlag, mvrFlag, mvrStrFlag, hackFlag, camFlag, pawnFlag, compFlag, vendFlag, iterFlag;
	local string sFlag, prefixKeep, prefixComp, prefixPawn;
	local Inventory inv;
	local Containers cont;
	local DeusExDecoration deco;
	local Trigger trig;
	local DeusExMover M;
	local HackableDevices H;
	local SecurityCamera C;
	local TNMPawn P;
	local tnmComputers comp;
	local string vendUsesStr;

	if (Player == None)
		Player = DeusExPlayer(GetPlayerPawn());
	if (flags == None && Player != None)
		flags = Player.FlagBase;

	if (flags == None || localURL == "")
		return;

	expMission = 0;

	prefixKeep = Caps("CS_Keep_" $ localURL $ "_");
	prefixComp = Caps("CS_Comp_" $ localURL $ "_");
	prefixPawn = Caps("CS_Pawn_" $ localURL $ "_");
	it = flags.CreateIterator(FLAG_Bool);
	while (flags.GetNextFlagName(it, iterFlag))
	{
		sFlag = Caps(string(iterFlag));
		if (Left(sFlag, Len(prefixKeep)) == prefixKeep || Left(sFlag, Len(prefixComp)) == prefixComp || Left(sFlag, Len(prefixPawn)) == prefixPawn)
			flags.SetBool(iterFlag, False, True, expMission);
	}
	flags.DestroyIterator(it);

	visitFlag = SafeStringToName("CS_Vis_" $ localURL);
	flags.SetBool(visitFlag, True, True, expMission);

	foreach AllActors(class'Inventory', inv)
	{
		if (!inv.bDeleteMe && inv.Owner == None && !inv.bCarriedItem && !inv.bHidden && !inv.IsInState('Sleeping'))
		{
			keepFlag = SafeStringToName("CS_Keep_" $ localURL $ "_" $ inv.Name);
			flags.SetBool(keepFlag, True, True, expMission);
			keptInvCount++;
		}
	}

	foreach AllActors(class'Containers', cont)
	{
		if (!cont.bDeleteMe && !cont.bHidden)
		{
			keepFlag = SafeStringToName("CS_Keep_" $ localURL $ "_" $ cont.Name);
			flags.SetBool(keepFlag, True, True, expMission);
			keptDecoCount++;
		}
	}

	foreach AllActors(class'DeusExDecoration', deco)
	{
		if (!deco.bDeleteMe && !deco.bInvincible && !deco.IsA('Containers') && !deco.bHidden)
		{
			keepFlag = SafeStringToName("CS_Keep_" $ localURL $ "_" $ deco.Name);
			flags.SetBool(keepFlag, True, True, expMission);
			keptDecoCount++;
		}
	}

	foreach AllActors(class'tnmComputers', comp)
	{
		if (!comp.bDeleteMe)
		{
			if (comp.bInWorld)
			{
				compFlag = SafeStringToName("CS_Comp_" $ localURL $ "_" $ comp.Name);
				flags.SetBool(compFlag, True, True, expMission);
			}
			vendUsesStr = comp.GetPropertyText("numUses");
			if (vendUsesStr != "")
			{
				vendFlag = SafeStringToName("CS_Vend_" $ localURL $ "_" $ comp.Name);
				flags.SetInt(vendFlag, int(vendUsesStr) + 1000, True, expMission);
			}
		}
	}

	foreach AllActors(class'Trigger', trig)
	{
		if (!trig.bDeleteMe && trig.bTriggerOnceOnly && trig.bCollideActors)
		{
			keepFlag = SafeStringToName("CS_Keep_" $ localURL $ "_" $ trig.Name);
			flags.SetBool(keepFlag, True, True, expMission);
		}
	}

	foreach AllActors(class'DeusExMover', M)
	{
		mvrState = 64;
		if (M.bLocked)     mvrState = mvrState | 1;
		if (M.bPickable)   mvrState = mvrState | 2;
		if (M.bFrobbable)  mvrState = mvrState | 4;
		if (M.bHighlight)  mvrState = mvrState | 8;
		if (M.bDestroyed)  mvrState = mvrState | 16;
		if (M.KeyNum != 0) mvrState = mvrState | 32;

		mvrFlag = SafeStringToName("CS_Mvr_" $ localURL $ "_" $ M.Name);
		flags.SetInt(mvrFlag, mvrState, True, expMission);

		if (M.bLocked && M.bPickable)
		{
			mvrStrFlag = SafeStringToName("CS_MvrS_" $ localURL $ "_" $ M.Name);
			flags.SetFloat(mvrStrFlag, M.lockStrength, True, expMission);
		}
	}

	foreach AllActors(class'HackableDevices', H)
	{
		if (H.hackStrength == 0.0)
		{
			hackFlag = SafeStringToName("CS_Hack_" $ localURL $ "_" $ H.Name);
			flags.SetBool(hackFlag, True, True, expMission);
		}
	}

	foreach AllActors(class'SecurityCamera', C)
	{
		camState = 4;
		if (C.bActive)  camState = camState | 1;
		if (C.bNoAlarm) camState = camState | 2;
		camFlag = SafeStringToName("CS_Cam_" $ localURL $ "_" $ C.Name);
		flags.SetInt(camFlag, camState, True, expMission);
	}

	foreach AllActors(class'TNMPawn', P)
	{
		if (!P.bDeleteMe && P.bInWorld && P.Health > 0 && !P.IsInState('Dying'))
		{
			pawnFlag = SafeStringToName("CS_Pawn_" $ localURL $ "_" $ P.Name);
			flags.SetBool(pawnFlag, True, True, expMission);
		}
	}

	log("CoopMod: Saved map state for " $ localURL $ " (keptInv=" $ keptInvCount $ ", keptDeco=" $ keptDecoCount $ ")");
}

function RestoreCoopMapState()
{
	local bool bVisited;
	local Name visitFlag, keepFlag, mvrFlag, mvrStrFlag, hackFlag, camFlag, pawnFlag, compFlag, vendFlag;
	local Inventory inv;
	local Containers cont;
	local DeusExDecoration deco;
	local Trigger trig;
	local DeusExMover M;
	local HackableDevices H;
	local SecurityCamera C;
	local TNMPawn P;
	local tnmComputers comp;
	local int mvrState, camState, vendVal, removedInvCount, removedDecoCount;

	if (flags == None || localURL == "")
		return;

	visitFlag = SafeStringToName("CS_Vis_" $ localURL);
	bVisited = flags.GetBool(visitFlag);
	if (!bVisited)
		return;

	foreach AllActors(class'Inventory', inv)
	{
		if (inv.Owner == None && !inv.bCarriedItem && (!inv.bHidden || inv.IsInState('Sleeping')))
		{
			keepFlag = SafeStringToName("CS_Keep_" $ localURL $ "_" $ inv.Name);
			if (!flags.GetBool(keepFlag))
			{
				inv.Destroy();
				removedInvCount++;
			}
		}
	}

	foreach AllActors(class'Containers', cont)
	{
		if (!cont.bHidden)
		{
			keepFlag = SafeStringToName("CS_Keep_" $ localURL $ "_" $ cont.Name);
			if (!flags.GetBool(keepFlag))
			{
				cont.Contents = None;
				cont.Content2 = None;
				cont.Content3 = None;
				cont.Destroy();
				removedDecoCount++;
			}
		}
	}

	foreach AllActors(class'DeusExDecoration', deco)
	{
		if (!deco.bInvincible && !deco.IsA('Containers') && !deco.bHidden)
		{
			keepFlag = SafeStringToName("CS_Keep_" $ localURL $ "_" $ deco.Name);
			if (!flags.GetBool(keepFlag))
			{
				deco.Destroy();
				removedDecoCount++;
			}
		}
	}

	foreach AllActors(class'tnmComputers', comp)
	{
		compFlag = SafeStringToName("CS_Comp_" $ localURL $ "_" $ comp.Name);
		if (comp.bInWorld)
		{
			if (!flags.GetBool(compFlag))
				comp.LeaveWorld();
		}
		else
		{
			if (flags.GetBool(compFlag))
				comp.EnterWorld();
		}
		vendFlag = SafeStringToName("CS_Vend_" $ localURL $ "_" $ comp.Name);
		vendVal = flags.GetInt(vendFlag);
		if (vendVal >= 1000)
			comp.SetPropertyText("numUses", string(vendVal - 1000));
	}

	foreach AllActors(class'Trigger', trig)
	{
		if (trig.bTriggerOnceOnly)
		{
			keepFlag = SafeStringToName("CS_Keep_" $ localURL $ "_" $ trig.Name);
			if (!flags.GetBool(keepFlag))
				trig.SetCollision(False, False, False);
		}
	}

	foreach AllActors(class'DeusExMover', M)
	{
		mvrFlag = SafeStringToName("CS_Mvr_" $ localURL $ "_" $ M.Name);
		mvrState = flags.GetInt(mvrFlag);
		if ((mvrState & 64) != 0)
		{
			M.bLocked = ((mvrState & 1) != 0);
			M.bPickable = ((mvrState & 2) != 0);
			M.bFrobbable = ((mvrState & 4) != 0);
			M.bHighlight = ((mvrState & 8) != 0);
			if (!M.bLocked)
			{
				M.lockStrength = 0.0;
			}
			else
			{
				mvrStrFlag = SafeStringToName("CS_MvrS_" $ localURL $ "_" $ M.Name);
				if (flags.CheckFlag(mvrStrFlag, FLAG_Float))
					M.lockStrength = flags.GetFloat(mvrStrFlag);
			}
			if ((mvrState & 16) != 0 && !M.bDestroyed)
			{
				M.bDestroyed = True;
				M.bLocked = False;
				M.SetCollision(False, False, False);
				M.bProjTarget = False;
				M.InterpolateTo(2, 0.0);
			}
		}
	}

	foreach AllActors(class'HackableDevices', H)
	{
		hackFlag = SafeStringToName("CS_Hack_" $ localURL $ "_" $ H.Name);
		if (flags.GetBool(hackFlag))
		{
			H.hackStrength = 0.0;
			H.bHackable = True;
		}
	}

	foreach AllActors(class'SecurityCamera', C)
	{
		camFlag = SafeStringToName("CS_Cam_" $ localURL $ "_" $ C.Name);
		camState = flags.GetInt(camFlag);
		if ((camState & 4) != 0)
		{
			C.bActive = ((camState & 1) != 0);
			C.bNoAlarm = ((camState & 2) != 0);
		}
	}

	foreach AllActors(class'TNMPawn', P)
	{
		pawnFlag = SafeStringToName("CS_Pawn_" $ localURL $ "_" $ P.Name);
		if (flags.GetBool(SafeStringToName(P.BindName $ "_Dead")) || flags.GetBool(SafeStringToName(P.BindName $ "_Unconscious")))
		{
			if (P.bInWorld)
				P.LeaveWorld();
			flags.DeleteFlag(pawnFlag, FLAG_Bool);
		}
		else if (P.bInWorld)
		{
			if (flags.GetBool(pawnFlag))
				flags.DeleteFlag(pawnFlag, FLAG_Bool);
			else
				P.LeaveWorld();
		}
		else
		{
			if (flags.GetBool(pawnFlag))
			{
				flags.DeleteFlag(pawnFlag, FLAG_Bool);
				P.EnterWorld();
			}
		}
	}

	if (tnmGameInfo(Level.Game) != None)
		tnmGameInfo(Level.Game).SyncCoopState();

	log("CoopMod: Restored map state for " $ localURL $ " (removedInv=" $ removedInvCount $ ", removedDeco=" $ removedDecoCount $ ")");
}

//there may be a way of reading this so I'll chuck this in a funciton in case I find it
function string LastMap()
{
	if (right(trestkon(player).LastMap, 5) == "_2009")
		trestkon(player).LastMap = Left(trestkon(player).LastMap, Len(trestkon(player).LastMap)-5);
	return trestkon(player).LastMap;
}

function SendPM(string PM)
{
	Player.StartDataLinkTransmission(PM);
}

function inventory GiveItemTo(string itemName, TNMPawn reciever)
{
	local class<inventory> item;
	local inventory inv;

	item = class<inventory>(DynamicLoadObject(itemName, class'class',));

	inv = Spawn(item,reciever,,reciever.location,reciever.rotation);

	if (inv != None)
	{
		inv.InitialState='Idle2';
		inv.GiveTo(reciever);
		inv.SetBase(reciever);
	}
}

function inventory SpawnItemAt(string itemName, name SpawnLocationTag, optional name NewTag)
{
	local vector loc;
	local rotator rot;
	local actor a;
	local class<inventory> item;
	local bool bFoundPoint;
	
	bFoundPoint = False;

	foreach allactors(class'actor',a,SpawnLocationTag)
	{
		loc = a.location;
		rot = a.rotation;
		bFoundPoint = True;
		break;
	}
	
	if (!bFoundPoint)
		return None;

	item = class<inventory>(DynamicLoadObject(itemName, class'class',));
	
	if (item == None)
		return None;
	
	return Spawn(item,,NewTag,loc,rot);
}

function Actor SpawnActorAt(string actorName, name SpawnLocationTag)
{
	local vector loc;
	local rotator rot;
	local actor a;
	local class<actor> actor;
	local bool bFoundPoint;
	
	bFoundPoint = False;

	foreach allactors(class'actor',a,SpawnLocationTag)
	{
		loc = a.location;
		rot = a.rotation;
		bFoundPoint = True;
		break;
	}
	
	if (!bFoundPoint)
		return None;

	actor = class<actor>(DynamicLoadObject(actorName, class'class',));
	
	if (actor == None)
		return None;
	
	return Spawn(actor,,,loc,rot);
}

//more or less copied from goaladdtrigger
function AddGoal(name goalName, string goalText, bool bPrimaryGoal, bool bGoalCompleted)
{
	local DeusExGoal goal;
	local Pawn P;
	local Trestkon T;

	if (Level.NetMode != NM_Standalone)
	{
		for (P = Level.PawnList; P != None; P = P.NextPawn)
		{
			T = Trestkon(P);
			if (T != None)
			{
				goal = T.AddGoal(goalName, bPrimaryGoal);
				if ( bGoalCompleted )
					T.GoalCompleted(goalName);
				if (goal != None)
					goal.SetText(goalText);
				if (NetConnection(T.Player) != None)
					T.ClientSyncGoal(goalName, bPrimaryGoal, goalText, bGoalCompleted);
			}
		}
	}
	else if (player != None)
	{
		goal = player.AddGoal(goalName, bPrimaryGoal);
		if ( bGoalCompleted )
			player.GoalCompleted(goalName);	
		goal.SetText(goalText);
	}
}

function KillPawn(TNMPawn p)
{
	p.HealthTorso = 0;
	p.Health = 0;
	p.bStunned = false;
	p.TakeDamage(1, p, p.Location, vect(0,0,0), 'shot');
}

function PawnKilled(pawn killed, pawn killer)
{
}

function PlayerKilled(pawn killed, pawn killer)
{
}

simulated function bool DisplayNews(string filename)
{
	return true;
}



// ----------------------------------------------------------------------------
// PawnsEnterWorld()
// 
// Makes ScriptedPawns enter the world. bSingle parameter is used if the
// function should return after first occurance (used for optimisation).
// ----------------------------------------------------------------------------
function PawnsEnterWorld(Class<ScriptedPawn> PawnClass, optional Name PawnTag, optional bool bSingle)
{
	// PawnList variant.
	local Pawn curPawn;

	// Used to spot class loading errors (maybe remove later).
	if (PawnClass == None)
	{
		Warn("PawnClass = None");
		return;
	}

	for (curPawn=Level.PawnList; curPawn!=None; curPawn=curPawn.NextPawn)
		if (ClassIsChildOf(curPawn.Class,PawnClass) && (PawnTag == '' || (PawnTag != '' && curPawn.Tag == PawnTag)))
		{
			ScriptedPawn(curPawn).EnterWorld();
			if (bSingle)
				break;
		}
}

// ----------------------------------------------------------------------------
// PawnsLeaveWorld()
// 
// Makes ScriptedPawns leave the world. bSingle parameter is used if the
// function should return after first occurance (used for optimisation).
// ----------------------------------------------------------------------------
function PawnsLeaveWorld(Class<ScriptedPawn> PawnClass, optional Name PawnTag, optional bool bSingle)
{
	local Pawn curPawn;

	// Used to spot class loading errors (maybe remove later).
	if (PawnClass == None)
	{
		Warn("PawnClass = None");
		return;
	}

	for (curPawn=Level.PawnList; curPawn!=None; curPawn=curPawn.NextPawn)
		if (ClassIsChildOf(curPawn.Class,PawnClass) && (PawnTag == '' || (PawnTag != '' && curPawn.Tag == PawnTag)))
		{
			ScriptedPawn(curPawn).LeaveWorld();
			if(bSingle)
				break;
		}
}

// ----------------------------------------------------------------------------
// VehiclesEnterWorld()
// 
// Makes Vehicles enter the world. bSingle parameter is used if the
// function should return after first occurance (used for optimisation).
// ----------------------------------------------------------------------------
/*function VehiclesEnterWorld(Class<Vehicles> VehiclesClass, optional Name DecorationTag, optional bool bSingle)
{
	local Actor vehicle;

	// Used to spot class loading errors (maybe remove later).
	if (VehiclesClass == None)
	{
		Warn("VehiclesClass = None");
		return;
	}
	
	foreach AllActors(VehiclesClass, vehicle, DecorationTag)
	{
		vehicle.EnterWorld();
		if (bSingle)
			break;
	}
}*/

// ----------------------------------------------------------------------------
// VehiclesLeaveWorld()
// 
// Makes Vehicles leave the world. bSingle parameter is used if the
// function should return after first occurance (used for optimisation).
// ----------------------------------------------------------------------------
/*function VehiclesLeaveWorld(Class<Vehicles> VehiclesClass, optional Name DecorationTag, optional bool bSingle)
{
	local Actor vehicle;

	// Used to spot class loading errors (maybe remove later).
	if (VehiclesClass == None)
	{
		Warn("VehiclesClass = None");
		return;
	}

	foreach AllActors(VehiclesClass, vehicle, DecorationTag)
	{
		vehicle.LeaveWorld();
		if (bSingle)
			break;
	}
}*/

// ----------------------------------------------------------------------------
// ActorsExist()
// 
// Checks for at least one occurance of Actor belonging to ActorClass and the optional ActorTag.
// Optional parameter to count first game only actors (ie not NGP actors).
// ----------------------------------------------------------------------------
function bool ActorsExist(Class<Actor> ActorClass, optional Name ActorTag, optional bool bOnlyCountFirstGameActors)
{
	local Actor a;

	if (ActorClass == None )
	{
		Warn("ActorClass = None");
		return False;
	}
	
	foreach AllActors(ActorClass, a, ActorTag)
		if (!a.bDeleteMe)
			if (!bOnlyCountFirstGameActors || (bOnlyCountFirstGameActors && a.bNetSpecial))
				return True;
	
	return False;
}

function bool ActorsExist_FirstGameOnly(Class<Actor> ActorClass, optional Name ActorTag)
{
	return ActorsExist(ActorClass, ActorTag, True);
}

// ----------------------------------------------------------------------------
// PawnsExist()
// 
// Checks for at least one occurance of Pawn belonging to PawnClass and the optional PawnTag.
// Optional parameter to count first game only pawns (ie not NGP pawns).
// ----------------------------------------------------------------------------
function bool PawnsExist(Class<ScriptedPawn> PawnClass, optional Name PawnTag, optional bool bOnlyCountFirstGamePawns)
{
	local Pawn curPawn;

	if (PawnClass == None)
	{
		Warn("PawnClass = None");
		return False;
	}
	
	for (curPawn=Level.PawnList; curPawn!=None; curPawn=curPawn.NextPawn)
		if (!curPawn.bDeleteMe && ClassIsChildOf(curPawn.Class,PawnClass) && (PawnTag == '' || (PawnTag != '' && curPawn.Tag == PawnTag)))
			if (!bOnlyCountFirstGamePawns || (bOnlyCountFirstGamePawns && curPawn.bNetSpecial))
				return True;

	return False;
}

function bool PawnsExist_FirstGameOnly(Class<ScriptedPawn> PawnClass, optional Name PawnTag)
{
	return PawnsExist(PawnClass, PawnTag, True);
}

// ----------------------------------------------------------------------------
// RobotsExist()
// 
// Checks for at least one occurance of Robot belonging to RobotClass and the optional RobotTag.
// Optional parameter to count first game only robots (ie not NGP robots).
// Optional parameter to only count bots that are alive (don't count disabled).
// ----------------------------------------------------------------------------
function bool RobotsExist(Class<Robot> RobotClass, optional Name RobotTag, optional bool bOnlyCountFirstGameRobots, optional bool bOnlyCountAliveBots)
{
	local Robot robot;
	local Pawn curPawn;

	if (RobotClass == None)
	{
		Warn("RobotClass = None");
		return False;
	}

	for (curPawn=Level.PawnList; curPawn!=None; curPawn=curPawn.NextPawn)
	{
		robot = Robot(curPawn);
		if (robot != None && !robot.bDeleteMe && ClassIsChildOf(Robot.Class, RobotClass) && (RobotTag == '' || (RobotTag != '' && robot.Tag == RobotTag)))
			if (!bOnlyCountFirstGameRobots || (bOnlyCountFirstGameRobots && robot.bNetSpecial))
				if(!bOnlyCountAliveBots || (bOnlyCountAliveBots && robot.EMPHitPoints > 0))
					return True;
	}
	
	return False;
}

function bool RobotsExist_AliveFirstGameOnly(Class<Robot> RobotClass, optional Name RobotTag)
{
	return RobotsExist(RobotClass, RobotTag, True, True);
}

// ----------------------------------------------------------------------------
// MoversExist()
// 
// Checks for at least one occurance of the mover belonging to MoverClass and the optional MoverClass.
// Optional parameter only counts !bDestroyed movers.
// ----------------------------------------------------------------------------
function bool MoversExist(Class<DeusExMover> MoverClass, optional Name MoverTag, optional bool bOnlyCountIntact)
{
	local Actor A;
	local DeusExMover M;

	//Compiler bug: If trying to use a DeusExMover as loop variable it doesn't compile even though it should.
	foreach AllActors(MoverClass, A, MoverTag)
	{
		M = DeusExMover(A);
		if (!bOnlyCountIntact || (bOnlyCountIntact && !M.bDestroyed))
			return True;
	}
	
	return False;
}

// ----------------------------------------------------------------------------
// DestroyActors()
// 
// Destroys all Actors of class ActorClass with optional ActorTag.
// ----------------------------------------------------------------------------
function DestroyActors(Class<Actor> ActorClass, optional Name ActorTag, optional bool bSingle)
{
	local Actor a;

	// Used to spot class loading errors (maybe remove later).
	if (ActorClass == None)
	{
		Warn("ActorClass = None");
		return;
	}

	foreach AllActors(ActorClass, a, ActorTag)
	{
		a.Event = '';
		a.Destroy();
		if (bSingle)
			break;
	}
}

// ----------------------------------------------------------------------------
// DestroyPawns()
// 
// Destroys all Pawns of class PawnClass with optional PawnTag.
// ----------------------------------------------------------------------------
function DestroyPawns(Class<ScriptedPawn> PawnClass, optional Name PawnTag, optional bool bSingle)
{
	local Pawn curPawn;

	// Used to class spot loading errors (maybe remove later).
	if (PawnClass == None)
	{
		Warn("PawnClass = None");
		return;
	}
	
	for (curPawn=Level.PawnList; curPawn!=None; curPawn=curPawn.NextPawn)
		if (ClassIsChildOf(curPawn.Class,PawnClass) && (PawnTag == '' || (PawnTag != '' && curPawn.Tag == PawnTag)))
		{
			curPawn.Event = '';
			curPawn.Destroy();
			if(bSingle)
				break;
		}
}

// ----------------------------------------------------------------------------
// BlowUpMovers()
// 
// Blows up all Movers of a certain class with an optional tag.
// ----------------------------------------------------------------------------
function BlowUpMovers(Class<DeusExMover> MoverClass, optional Name MoverTag)
{
	local Actor A;

	//Compiler bug: If trying to use a DeusExMover as loop variable it doesn't compile even though it should.
	foreach AllActors(MoverClass, A, MoverTag)
		DeusExMover(A).BlowItUp(None);
}

// ----------------------------------------------------------------------------
// TeleportPawn()
// 
// Teleports a pawn to a patrol point (or spawn point if no patrol point is found) with the specified tag and gives the pawn orders.
// Optional parameter to pick a random point that matches the tag and not the first one, optional parameter to also set the point as home base.
// ----------------------------------------------------------------------------
function TeleportPawn(ScriptedPawn pawn, name patrolTag, name orders, optional bool bRandom, optional bool bRotate, optional bool bSetHomeBase)
{
	local NavigationPoint point;
	local SpawnPoint SP;
	local PatrolPoint PP;

	if (pawn != None)
	{
		// point = GetPatrolPoint(patrolTag, bRandom);
		foreach AllActors(class'PatrolPoint', PP, patrolTag)
		{
			point = PP;
			break;
		}
		
		//If we found no patrol point, search for a spawnpoint with the same tag.
		if (point == None)
		{
			// point = GetSpawnPoint(patrolTag, bRandom);
			foreach AllActors(class'SpawnPoint', SP, patrolTag)
			{
				point = SP;
				break;
			}
		}
		
		if (point != None)
		{
			pawn.SetLocation(point.Location);
			if (bRotate)
				pawn.SetRotation(point.Rotation);
			pawn.SetOrders(orders,, True);
			if (bSetHomeBase)
				pawn.SetHomeBase(point.Location, point.Rotation);
		}
	}
}

// ----------------------------------------------------------------------------
// DestroyAllNPCInventory()
// 
// Destroy all inventory of the passed in pawn.
// ----------------------------------------------------------------------------
function DestroyAllNPCInventory(Pawn curPawn)
{
	local Inventory item;
	
	for(item = curPawn.Inventory; item != None; item = item.Inventory)
	{
		if(item.Owner == player)
			break; //== We have somehow stumbled into the player's inventory. Abort!

		curPawn.DeleteInventory(item);
		item.Destroy();
	}
}

function InitStateMachine()
{
    local DeusExLevelInfo info;
    local Pawn P;

    Player = DeusExPlayer(GetPlayerPawn());
    if (Player == None)
    {
        for (P = Level.PawnList; P != None; P = P.NextPawn)
        {
            if (DeusExPlayer(P) != None)
            {
                Player = DeusExPlayer(P);
                break;
            }
        }
    }

    foreach AllActors(class'DeusExLevelInfo', info)
        dxInfo = info;

    if (Player != None)
    {
        if (Level.NetMode != NM_Standalone && tnmGameInfo(Level.Game) != None)
            tnmGameInfo(Level.Game).RestoreCoopSessionFromDefaults(Trestkon(Player));

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
			
			// log("localURL"@localURL);
			if (right(localURL, 5) == "_2009")
				localURL = Left(localURL, Len(localURL)-5);
			// log("localURL"@localURL);

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

defaultproperties
{
     Wait=0.150000
     trestkonMissingMsg="Correct player class not detected. Please reinstall."
     trestkonMissingTitle="Trestkon Missing"
     strTetris="Tetris: %d"
     strPong="Pong: %d"
     strBreakout="Breakout: %d"
     strLightsOut="Lights out: %d"
     RemoteRole=ROLE_SimulatedProxy
     bAlwaysRelevant=True
}

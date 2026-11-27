class tnmMission25 extends TNMMissionScript;

var localized string endgameQuote[10];
var float endgameDelays[5];
var byte savedSoundVolume;

function StartConversationByName(Name conName, Actor conOwner, optional bool bAvoidState, optional bool bForcePlay)
{
	local bool bsuccess;
	bsuccess = player.StartConversationByName(conName, conOwner, bAvoidState, bForcePlay);
	if (!bsuccess)
		Log("Failed to play conversation");
}

// ----------------------------------------------------------------------
// FirstFrame()
// 
// Stuff to check at first frame
// ----------------------------------------------------------------------
function FirstFrame()
{
	local tnmcamerapoint cp;
	local TNMPawn p;
	local navigationpoint n;
	local Dispatcher D;
	local trestkon t;
	local DXOgg music;
	local string track;
	local povcorpse povc;

	Super.FirstFrame();

	t=trestkon(getplayerpawn());
	
	Player.DeactivateAllAugs();
	
	// No weapon lasers
	if (t != None)
	{
		if (DeusExWeapon(t.InHand) != None)
			DeusExWeapon(t.InHand).LaserOff();
		// t.SetInHandPending(None);
		// t.SetInHand(None);
	}

	if (localURL == "25_TNMTRAINING")
	{
		// zero the player's skill points
		Player.SkillPointsTotal = 0;
		Player.SkillPointsAvail = 0;
		foreach allactors(class'tnmcamerapoint',cp,'tnmCameraPoint')
			cp.Trigger(none,none);
	}
	// else
	// {
		// savedSoundVolume = SoundVolume;
		// SoundVolume = 32;
		// Player.SetInstantSoundVolume(SoundVolume);
	// }


	if ( left( localURL, 10 ) ~= "TNMENDGAME")
	{
		t.bUnlockedSword=true;
		t.saveconfig();
		
		foreach AllActors(class'Trestkon', t)
		{
			povc = povcorpse(t.inHand);
			if ( povc != none )
			{
				t.PutInHand(none);
				povc.Destroy();
			}
		}
	}

	if (localURL == "TNMINTRO")
	{
		// Trigger the intro cutscene immediately
		if (!flags.GetBool('MS_Intro_Played'))
		{
			foreach allactors(Class'tnmCameraPoint',cp,'Seq01')
			{
				cp.Trigger(none,none);
			}

			Flags.SetBool('MS_Intro_Played',true,,);
		}
	}
	if (localURL == "TNMENDGAME01")
	{
		// Trigger the cutscene immediately
		foreach allactors(Class'tnmCameraPoint',cp,'ScaraCam')
			cp.Trigger(none,none);

		// Spawn Trestkon on the space station
		foreach allactors(class'navigationpoint',n,'TrestkonSpawn1')
		{
			p=Spawn(class'Treskton',,'TrestkonSS',n.Location,n.Rotation);
			p.SetOrders('Standing',,);
			p.Bindname = "TrestkonSS";
			p.bUseLipsyncHack = true;
			p.ConBindEvents();
			p.walkAnimMult=0.750000;
			p.GroundSpeed=180.000000;
		}

		//Spawn Trestkon in the corporate sector
		foreach allactors(class'navigationpoint',n,'TrestkonSpawn2')
		{
			p=Spawn(class'Treskton',,'Trestkon',n.Location,n.Rotation);
			p.bUseLipsyncHack = true;
			p.SetOrders('Standing',,);
			p.walkAnimMult=0.750000;
			p.GroundSpeed=180.000000;
		}

		// Position DXO depending on whether or not TRM is dead
		if (flags.GetBool('TRM_Dead') || !flags.GetBool('TRM_Done'))
		{
			foreach allactors(class'TNMPawn',p,'DXOGuysMeeting')
				p.EnterWorld();
		}
		else
		{
			foreach allactors(class'TNMPawn',p,)
			{
				if ((p.Tag == 'DXOGuysLeaving') || (p.Tag == 'Compudoc'))
					p.EnterWorld();
			}
		}
		
		t.bUnlockedTrack88 = true;
		t.bUnlockedTrack89 = true;
		t.SaveConfig();
	}
	if (localURL == "TNMENDGAME02")
	{
		// Trigger the cutscene immediately
		foreach allactors(Class'tnmCameraPoint',cp,'PDXHQCam01')
			cp.Trigger(none,none);

		// Position people depending on whether or not Scara was banned in M24
		if (flags.GetBool('Scara_Banned'))
		{
			// Remove Scara, first of all
			foreach allactors(class'TNMPawn',p,'ScaraKing')
				p.LeaveWorld();

			// Make Trestkon appear at the front
			foreach allactors(class'navigationpoint',n,'WC03')
			{
				p=Spawn(class'Treskton',,'treskton',n.Location,n.Rotation);
				p.bUseLipsyncHack = true;
				p.SetOrders('Standing',,);
				p.walkAnimMult=0.750000;
				p.GroundSpeed=180.000000;
			}

			// Make That Guy appear in the back
			foreach allactors(class'TNMPawn',p,'ThatGuy')
				p.EnterWorld();
		}
		else
		{
			// Make Trestkon appear in the back
			foreach allactors(class'navigationpoint',n,'TrestkonSpawn')
			{
				p=Spawn(class'Treskton',,'treskton',n.Location,n.Rotation);
				p.bUseLipsyncHack = true;
				p.SetOrders('Standing',,);
				p.walkAnimMult=0.750000;
				p.GroundSpeed=180.000000;
			}

			// Make That Guy appear next to ZeroPresence
			foreach allactors(class'TNMPawn',p,'ThatGuy_Prop')
				p.EnterWorld();
		}

		// Set a single flag to denote Kylie's presence to keep the convo relatively clean!
		if (flags.GetBool('Kylie_Dislike')||flags.GetBool('Kylie_Unconscious')||flags.GetBool('Kylie_Dead'))
			Flags.SetBool('Kylie_NotPresent',true,,);

		// If Ryan has been banned, remove him from the map (makes sense, no?)
		if (flags.GetBool('Ryan_Banned'))
		{
			foreach allactors(class'TNMPawn',p,'Ryan')
				p.LeaveWorld();
		}

		if(!flags.GetBool('Scara_Banned'))
		{
			if(!flags.GetBool('Kylie_NotPresent'))
			{
				track = "TNMEndgame02a.ogg";
				if (Trestkon(player).bAltSoundtrack)
					track = "TNMEndgame02aAlt.ogg";
			}
			else
			{
				track = "TNMEndgame02b.ogg";
			}
		}
		else
		{
			if(!flags.GetBool('Kylie_NotPresent'))
			{
				track = "TNMEndgame02c.ogg";
			}
			else
			{
				track = "TNMEndgame02d.ogg";
			}
		}
		
		t.bUnlockedTrack90 = true;
		t.bUnlockedTrack91 = true;
		t.bUnlockedTrack92 = true;
		t.bUnlockedTrack93 = true;
		t.bUnlockedTrack94 = true;
		t.SaveConfig();

		music=Spawn(class'DXOgg');
		music.setcurrentOgg(track, "Blank.ogg", 0.0, MTRAN_Instant);
	}
	if (localURL == "TNMENDGAME03")
	{
		// Make Trestkon appear on the space station for the Narc ending
		if(flags.GetBool('ENDING_Narc'))
		{
			foreach allactors(class'navigationpoint',n,'NarcTrestkonPoint01')
			{
				p=Spawn(class'Treskton',,'TrestkonNarc',n.Location,n.Rotation);
				p.bUseLipsyncHack = true;
				p.SetOrders('Standing',,);
				p.bUnlit = True;
				p.walkAnimMult=0.750000;
				p.GroundSpeed=180.000000;
			}
		}

		// Trigger the cutscene immediately
		if(flags.GetBool('ENDING_Narc'))
		{
			t.bUnlockedBulletTime=true;
			t.saveconfig();

			foreach allactors(Class'tnmCameraPoint',cp,'Narc01Cam')
				cp.Trigger(none,none);

			// For the Narcissus ending, also trigger the first convo
			foreach allactors(class'TNMPawn',p,'TrestkonNarc')
				break;
			StartConversationByName('NarcEndgame01', p, False, True);
		}
		else
		{
			foreach allactors(Class'Dispatcher',D,'SSBlowup1')
				D.Trigger(none,none);
				
			t.bUnlockedTrack95 = true;
			t.bUnlockedTrack96 = true;
			t.SaveConfig();
		}

		// Make Trestkon appear for the ABI ending
		foreach allactors(class'navigationpoint',n,'TrestkonSpawn')
		{
			p=Spawn(class'Treskton',,'TrestkonRyan',n.Location,n.Rotation);
			p.bUseLipsyncHack = true;
			p.SetOrders('Standing',,);
			p.walkAnimMult=0.750000;
			p.GroundSpeed=180.000000;
		}

		// Make Trestkon appear in Downtown for the Narc ending
		foreach allactors(class'navigationpoint',n,'NarcTrestkonPointDT')
		{
			p=Spawn(class'Treskton',,'CircleTrestkon',n.Location,n.Rotation);
			p.bUseLipsyncHack = true;
			p.SetOrders('Standing',,);
			p.walkAnimMult=0.750000;
			p.GroundSpeed=180.000000;

			// Set Trestkon's bindname to TresktonDT
			p.Bindname = "TresktonDT";
			p.ConBindEvents();
		}

		// Remove Kevo if the player is WC-aligned
		if (flags.GetBool('ALLIED_WC'))
		{
			foreach allactors(Class'TNMPawn',p,'Kevo')
				p.LeaveWorld();
		}
		// Remove Midashand if the player is PDX-aligned
		else
		{
			foreach allactors(Class'TNMPawn',p,'Midashand')
				p.LeaveWorld();
		}
	}
	if (localURL == "TNMDENOUEMENT")
	{
	
		// Trigger the cutscene immediately
		foreach allactors(Class'tnmCameraPoint',cp,'Cam00')
			cp.Trigger(none,none);

		// Remove the patrons of Sol's in the WC ending if Alpha is dead
		if (flags.GetBool('ALLIED_WC') && flags.GetBool('AlphaOperator_Dead'))
		{
			foreach allactors(class'TNMPawn',p,'SolsPatron')
				p.LeaveWorld();
		}

		// If Ryan has been banned, remove him from the map (makes sense, no?)
		if (flags.GetBool('Ryan_Banned'))
		{
			foreach allactors(class'TNMPawn',p,'Ryan')
				p.LeaveWorld();
		}

		// If Yardbomb is dead or was advised to sell...
		if (flags.GetBool('ALLIED_WC') && (flags.GetBool('Yardbomb_AdvisedToSell') || flags.GetBool('Yardbomb_Dead')))
		{
			// Remove Yardbomb if he's still alive
			if (!flags.GetBool('Yardbomb_Dead'))
			{
				foreach allactors(class'TNMPawn',p,'Yardbomb')
					p.LeaveWorld();
			}

			// Spawn the WC people
			foreach allactors(class'TNMPawn',p,'VoodooWCGuys')
				p.EnterWorld();
		}

		// Remove the goats (including OiNutter) if all cult leaders are dead
		if (flags.GetBool('Athena_Dead') && flags.GetBool('Beefman_Dead') && flags.GetBool('DarkTemplar_Dead') && flags.GetBool('Abomination_Dead'))
		{
			foreach allactors(class'TNMPawn',p,)
			{
				if ((p.Tag == 'Goats')||(p.Tag == 'OiNutter'))
					p.LeaveWorld();
			}
		}

		// Spawn Kylie in ZP's office
		if (flags.GetBool('ALLIED_WC') && flags.GetBool('Kylie_Dislike') && !flags.GetBool('Kylie_Dead'))
		{
			foreach allactors(class'TNMPawn',p,'Kylie_ZP')
				p.EnterWorld();
		}

		// Spawn Trestkon in the Partyzone
		foreach allactors(class'navigationpoint',n,'TrestkonSpawn_Partyzone')
		{
			p=Spawn(class'Treskton',,'TrestkonPZ',n.Location,n.Rotation);
			p.SetOrders('Standing',,);
			p.walkAnimMult=0.750000;
			p.GroundSpeed=180.000000;
		}

		// Spawn Trestkon in Scara's office
		foreach allactors(class'navigationpoint',n,'TrestkonSpawn_Scara')
		{
			p=Spawn(class'Treskton',,'TrestkonWC',n.Location,n.Rotation);
			p.SetOrders('Sitting','ScaraChair',);
			p.walkAnimMult=0.750000;
			p.GroundSpeed=180.000000;
		}

		// Spawn Trestkon by the sunset in the final scene
		foreach allactors(class'navigationpoint',n,'TrestkonSpawn_Final')
		{
			p=Spawn(class'Treskton',,'Trestkon',n.Location,n.Rotation);
			p.SetOrders('Standing',,);
			p.walkAnimMult=0.750000;
			p.GroundSpeed=180.000000;
		}
	}
}

// ----------------------------------------------------------------------
// PreTravel()
// 
// Set flags upon exit of a certain map
// ----------------------------------------------------------------------

function PreTravel()
{
	// SoundVolume = savedSoundVolume;

	// if ( player != none && savedSoundVolume != 0)
		// Player.SetInstantSoundVolume(SoundVolume);

	Super.PreTravel();
}

// ----------------------------------------------------------------------
// Timer()
//
// Main state machine for the mission
// ----------------------------------------------------------------------

function Timer()
{
	local int count;
	local TNMPawn p;
	local Lamp3 l;

	local WeaponMolBottle mol;

	local Augmentation aug;
	local trash trash;

	Super.Timer();

	if (localURL == "25_TNMTRAINING")
	{
		// WORST. SOLUTION. EVER! ...stupid ConEdit.
		Flags.SetBool('PM_Phas_DrinkWine_Played',false,,);

		// Play a PM when the security guard is knocked out
		count = 0;
		foreach allactors(class'TNMPawn',p,'CameraDummy')
			count++;
		if (count == 0)
		{
			SendPM("PM_Phas_Tut10");
		}

		// Play a PM when the fist dummy is knocked out
		count = 0;
		foreach allactors(class'TNMPawn',p,'FistDummy')
			count++;
		if (count == 0)
		{
			SendPM("PM_Phas_Tut12");
		}

		//First time the player gets a molotov cocktail, play the PM
		foreach allactors(class'WeaponMolBottle', mol, )
		{
			if ( mol.Owner == player)
				SendPM("PM_Phas_Tut15");
		}

		if(player!=None)
			aug=player.AugmentationSystem.FirstAug;

		while(aug!=None)
		{
			if(aug.IsA('AugLight') && aug.CurrentLevel==1)
				SendPM("PM_Phas_Tut19");

			if((aug.IsA('AugCombat') || aug.IsA('AugMuscle')) && aug.CurrentLevel==1)
				SendPM("PM_Phas_Tut20");

			aug=aug.next;
		}
	}
	else if (localURL == "TNMINTRO")
	{
		// Increase lifespan of paper to prevent despawning
		foreach allactors(Class'Trash',trash)
		{
			trash.TimerRate = 300;
		}
	}
}

// ----------------------------------------------------------------------
// TRAINING FUNCTIONS
//
// Callback functions for the training mission
// ----------------------------------------------------------------------

function ActivateCamera()
{
	local SecurityCamera c;
	//Activate the security Camera
	foreach AllActors(class'SecurityCamera',c,'TrainingCamera')
	{
		c.bNoAlarm=False;
		c.bActive=true;
	}
}

function MaxComputers()
{
	local Skill aSkill;
	// max out the computers skill
	if (Player.SkillSystem != None)
	{
		aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillComputer');
		if (aSkill != None)
			aSkill.CurrentLevel = 3;
	}
}

function UpgradeDemolitions()
{
	local Skill aSkill;
	// Upgrade the demolition skill to level 2
	if (Player.SkillSystem != None)
	{
		aSkill = Player.SkillSystem.GetSkillFromClass(class'tnmSkillDemolition');
		if (aSkill != None)
			aSkill.CurrentLevel = 1;
	}
}

function MaxDemolitions()
{
	local Skill aSkill;
	// max out the demolitions skill
	if (Player.SkillSystem != None)
	{
		aSkill = Player.SkillSystem.GetSkillFromClass(class'tnmSkillDemolition');
		if (aSkill != None)
			aSkill.CurrentLevel = 3;
	}
}

function MaxFists()
{
	local Skill aSkill;
	// max out the fists skill
	if (Player.SkillSystem != None)
	{
		aSkill = Player.SkillSystem.GetSkillFromClass(class'SkillWeaponFists');
		if (aSkill != None)
			aSkill.CurrentLevel = 3;
	}
}

function GiveTargettingAug()
{
	local Augmentation aug;

	player.AugmentationSystem.GivePlayerAugmentation(class'tnmpcAugTarget');

	aug=player.AugmentationSystem.FirstAug;
	while(aug!=None)
	{
		if(aug.IsA('AugTarget'))
		{
			aug.CurrentLevel=aug.MaxLevel;
			break;
		}
		aug=aug.next;
	}
}

function HidePhas()
{
	local TNMPawn Phas;
	foreach AllActors(class'TNMPawn', Phas, 'HoloPhas')
		Phas.LeaveWorld();
}

function UnHidePhas()
{
	local TNMPawn Phas;
	foreach AllActors(class'TNMPawn', Phas, 'HoloPhas')
		Phas.EnterWorld();
}

function RemoveAllInventory()
{
	local Inventory item, nextItem, lastItem;

	if (Player.Inventory != None)
	{
		item = Player.Inventory;
		nextItem = item.Inventory;
		lastItem = item;

		do
		{
			if (!item.IsA('weaponfists') && (item != None) && item.bDisplayableInv || item.IsA('Ammo'))
			{
				// make sure everything is turned off
				if (item.IsA('DeusExWeapon'))
				{
					DeusExWeapon(item).ScopeOff();
					DeusExWeapon(item).LaserOff();
				}
				if (item.IsA('DeusExPickup'))
				{
					if (DeusExPickup(item).bActive)
						DeusExPickup(item).Activate();
				}

   			if (item.IsA('ChargedPickup'))
					Player.RemoveChargedDisplay(ChargedPickup(item));

				Player.DeleteInventory(item);
				item.Destroy();
				item = Player.Inventory;
			}
			else
				item = nextItem;

			if (item != None)
				nextItem = item.Inventory;
		}
		until ((item == None) || (item == lastItem));
	}
}

function SendMoreWine()
{
	local inventory inv;
	local ExplosionLight light;
	local int i;
	local Rotator rot;
	local SphereEffect sphere;
	local ExplosionSmall expeffect;
	
	inv = SpawnItemAt("TNMitems.WineBottleTrigger", 'SpawnMoreWine');
	if (inv != None)
	{
		// draw a pretty explosion
		light = Spawn(class'ExplosionLight',,, inv.Location);
		if (light != None)
		{
			light.size = 8;
			light.LightHue = 128;
			light.LightSaturation = 96;
			light.LightEffect = LE_Shell;
		}

		// draw a cool light sphere
		sphere = Spawn(class'SphereEffect',,, inv.Location);
		if (sphere != None)
		{
			sphere.size = inv.CollisionRadius;
		}
	}
}

// ----------------------------------------------------------------------
// INTRO FUNCTIONS
//
// Callback functions for the intro cinematic
// ----------------------------------------------------------------------

function BanPawn(TNMPawn p)
{
	local BanInfo ban;
	ban=Spawn(Class'BanInfo');
	ban.StartBan(p);
}

function BanFighters()
{
	local TNMPawn screwed;
	foreach AllActors(Class'TNMPawn',screwed,'LlamaFighter')
		BanPawn(screwed);
	foreach AllActors(Class'TNMPawn',screwed,'GoatFighter')
		BanPawn(screwed);
}

function DDAppear()
{
	local TNMPawn p;

	// Make DD appear and move to his waypoint
	foreach allactors(class'TNMPawn',p,'DD')
	{
		p.EnterWorld();
		p.PlaySound(Sound'CloakDown', SLOT_Interact, 0.85, ,768,1.0);
		p.SetOrders('Patrolling','DDWaypoint01');
	}
}

function DDEquipSword()
{
	local TNMPawn dd;
	
	foreach allactors(class'TNMPawn',dd,'DD')
	{
		dd.bKeepWeaponDrawn=true;
		//dd.SetupWeapon(true,true);
		dd.SetWeapon(weapon(dd.Inventory));
	}
}

function DDEnterAlley()
{
	local TNMPawn dd;
	
	foreach allactors(class'TNMPawn',dd,'DD')
		dd.SetOrders('Patrolling','DDAlleyWaypoint',true);
}

function DDVanish()
{
	local TNMPawn dd;
	
	foreach allactors(class'TNMPawn',dd,'DD')
		dd.LeaveWorld();
}

function PlayIntro1()
{
	local TNMPawn dd;
	foreach allactors(class'TNMPawn',dd,'DD')
		break;
	StartConversationByName('Intro1', dd, False, True);
}

function PlayIntro2()
{
	local TNMPawn dd;
	foreach allactors(class'TNMPawn',dd,'DD')
		break;
	StartConversationByName('Intro2', dd, False, True);
}

function PlayIntro3()
{
	local TNMPawn dd;
	foreach allactors(class'TNMPawn',dd,'DD')
		break;
	StartConversationByName('Intro3', dd, False, True);
}

function PlayIntro4()
{
	local WHPhone WHP;
	local TAD TAD;
	foreach allactors(class'WHPhone',WHP,'PhasTAD')
		break;
	StartConversationByName('Intro4', WHP, False, True);
}

function PlayIntro5()
{
	local TNMPawn slicer;
	foreach allactors(class'TNMPawn',slicer,'Slicer')
		break;
	StartConversationByName('Intro5', slicer, False, True);
}

function PlayIntro6()
{
	local TNMPawn scara;
	foreach allactors(class'TNMPawn',scara,'ScaraKing')
		break;
	StartConversationByName('Intro6', scara, False, True);
}

function ArmThugs()
{
	local TNMPawn thug;
	foreach AllActors(class'TNMPawn',thug,'CheckpointThugs')
	{
		thug.bKeepWeaponDrawn=true;
		thug.SetupWeapon(true,true);
	}
}

function ClearCheckpoint()
{
	local TNMPawn p;
	local Vehicles V;

	foreach AllActors(class'TNMPawn',p,)
	{
		if ((p.Tag == 'CheckpointBusinessman') || (p.Tag == 'CheckpointThugs') || (p.Tag == 'CheckpointBystanders'))
			p.LeaveWorld();
	}

	foreach AllActors(class'Vehicles',V,)
	{
		if (V.Tag == 'CheckpointCars')
			V.LeaveWorld();
	}
}

function SpawnCultWar()
{
	local TNMPawn p;
	local TNMCarcass c;

	foreach allactors(class'TNMPawn',p,)
	{
		if ((p.Tag == 'Llamas') || (p.Tag == 'Goats'))
			p.EnterWorld();
	}

	foreach allactors(class'TNMCarcass',c,'CultCorpses')
		c.EnterWorld();
}

function KashueLeave()
{
	local TNMPawn p;

	// Spawn a copy of Kashue and move him to his waypoint
	foreach allactors(class'TNMPawn',p,'KashueLeaving')
	{
		p.EnterWorld();
		p.SetOrders('Patrolling','KKWaypoint',true);
	}
}

function TrestkonAppear()
{
	local navigationpoint n;
	local TNMPawn p;

	// Make Trestkon appear and move to his waypoint
	foreach allactors(class'navigationpoint',n,'TrestkonSpawn') // THIS IS NOT A TYPO!
	{
		p=Spawn(class'Treskton',,,n.Location,n.Rotation);
		p.SetOrders('Patrolling','TrestkonWaypoint',true);
		p.walkAnimMult=0.750000;
		p.GroundSpeed=180.000000;
	}
}

function EndIntro()
{
	Trestkon(GetPlayerPawn()).PostIntro();
}

// ----------------------------------------------------------------------
// ENDGAME FUNCTIONS
//
// Callback functions for the endgame cinematics
// ----------------------------------------------------------------------

function PrintEndgameQuote(int num)
{
	local int i;
	local DeusExRootWindow root;
	local HUDMissionStartTextDisplay quoteDisplay;

	root = DeusExRootWindow(Player.rootWindow);
	if (root != None)
	{
		quoteDisplay = HUDMissionStartTextDisplay(root.NewChild(Class'HUDMissionStartTextDisplay', True));
		if (quoteDisplay != None)
		{
			quoteDisplay.displayTime = endgameDelays[num];
			quoteDisplay.SetWindowAlignments(HALIGN_Center, VALIGN_Center);

			for (i=0; i<2; i++)
				quoteDisplay.AddMessage(endgameQuote[2*num+i]);

			quoteDisplay.StartMessage();
		}
	}
}

function RollCredits()
{
	local DeusExRootWindow root;
	local tnmCredits winCredits;

	root = DeusExRootWindow(player.rootWindow);

	if (root != None)
	{
		winCredits = tnmcredits(root.InvokeMenuScreen(Class'tnmcredits', false));
		winCredits.SetLoadIntro(true);
	}
}

// ----------------------------------------------------------------------
// PDX
// ----------------------------------------------------------------------

function BanScaraFX(TNMPawn p)
{
	local BanInfo ban;
	ban=Spawn(Class'BanInfo');
	ban.StartBan(p);
}

function PlayPDXEndgame01()
{
	local TNMPawn p;
	foreach allactors(class'TNMPawn',p,'ScaraHidden')
		break;
	player.StartConversationByName('PDXEndgame01', p, False, True);

	foreach AllActors(class'TNMPawn',p,'ScaraKing')
		break;
	p.GotoState('ScaraBan');
	
	if (Trestkon(GetPlayerPawn()) != None)
		Trestkon(GetPlayerPawn()).SetAchievement("achEndingPDX");
}

function BanScara()
{
	local TNMPawn p;
	// Apply the special Scara ban effect
	foreach AllActors(Class'TNMPawn',p,'ScaraKing')
		BanScaraFX(p);
}

function PlayPDXEndgame02()
{
	local TNMPawn p;
	foreach allactors(class'TNMPawn',p,'TrestkonSS')
		break;
	player.StartConversationByName('PDXEndgame02', p, False, True);
}

function TrestkonMoveUp()
{
	local TNMPawn t;	
	foreach allactors(class'TNMPawn',t,'Trestkon')
		t.SetOrders('Patrolling','TrestkonDestination',true);
}

function PlayPDXEndgame03()
{
	local TNMPawn p;
	foreach allactors(class'TNMPawn',p,'Phasmatis')
		break;
	player.StartConversationByName('PDXEndgame03', p, False, True);
}

function TRMAppear()
{
	local TNMPawn p;

	// Make TRM appear and move to his waypoint
	foreach allactors(class'TNMPawn',p,'TRM')
	{
		p.EnterWorld();
		p.SetOrders('Patrolling','TRMPosition',true);
	}
}

function DXOLightsOut()
{
	local lightbulb l;
	local triggerlight t;

	foreach allactors(class'lightbulb', l, 'DXOBulb')
	{
		l.LightType=LT_None;
		l.bUnlit=False;
	}

	foreach allactors(class'triggerlight', t, 'DXOLight')
	{
		t.bCorona=False;
		t.Trigger(None,None);
	}
}

function BanWCThugs()
{
	local TNMPawn p;

	// Apply the ban effect from the intro to all the WC fighters in the slums
	// Note: I left the BanPawn function up there
	foreach AllActors(Class'TNMPawn',p,'SlumFighter3')
		BanPawn(p);
}

function DDSlumsAppear()
{
	local TNMPawn p;	
	foreach allactors(class'TNMPawn',p,'dd')
	{
		p.EnterWorld();
		p.SetOrders('Patrolling','DDPosition',true);
	}
}

// ----------------------------------------------------------------------
// WC
// ----------------------------------------------------------------------

function PlayWCEndgame01()
{
	local TNMPawn r;
	foreach allactors(class'TNMPawn',r,'Phasmatis')
		break;
	StartConversationByName('WCEndgame01', r, False, True);
	
	if (Trestkon(GetPlayerPawn()) != None)
		Trestkon(GetPlayerPawn()).SetAchievement("achEndingWC");
}

function PlayWCEndgame02()
{
	local TNMPawn p;

	if (flags.GetBool('Scara_Banned'))
	{
		foreach allactors(class'TNMPawn',p,'ThatGuy')
			break;
		StartConversationByName('WCEndgame04', p, False, True);
	}
	else
	{
		foreach allactors(class'TNMPawn',p,'ScaraKing')
			break;
		StartConversationByName('WCEndgame02', p, False, True);
	}
}

function KylieAppear()
{
	local TNMPawn p;

	// Make Kylie appear and move to her waypoint
	foreach allactors(class'TNMPawn',p,'Kylie')
	{
		p.EnterWorld();

		// Kylie's waypoint is determined by whether Scara was banned or not
		if (flags.GetBool('Scara_Banned'))
		{
			p.SetOrders('Patrolling','WC02',true);
		}
		else
		{
			p.SetOrders('Patrolling','WC01',true);
		}
	}
}

function PlayWCEndgameKylie()
{
	local TNMPawn p;

	if (flags.GetBool('Scara_Banned'))
	{
		foreach allactors(class'TNMPawn',p,'Kylie')
			break;
		StartConversationByName('WCEndgame05', p, False, True);
	}
	else
	{
		foreach allactors(class'TNMPawn',p,'Kylie')
			break;
		StartConversationByName('WCEndgame03', p, False, True);
		foreach allactors(class'TNMPawn',p,'ScaraKing')
		{
			p.bIsSpeaking = False;
		}
	}
}

function ScaraLeave()
{
	local TNMPawn p;
	
	foreach allactors(class'TNMPawn',p,)
	{
		if ((p.Tag == 'ScaraKing')||(p.Tag == 'ZeroPresence')||(p.Tag == 'ThatGuy_Prop'))
			p.SetOrders('Leaving','WCLeavePoint',true);
	}
}

function ThatGuyAndZPLeave()
{
	local TNMPawn p;
	
	foreach allactors(class'TNMPawn',p,)
	{
		if ((p.Tag == 'ThatGuy')||(p.Tag == 'ZeroPresence'))
			p.SetOrders('Leaving','WCLeavePoint',true);
	}
}

// ----------------------------------------------------------------------
// ABI
// ----------------------------------------------------------------------

function ShuttleSeq02Appear()
{
	local Vehicles V;
	foreach allactors(class'Vehicles',V,'ShuttleSeq02')
		V.EnterWorld();
}

function ShuttleReturnAppear()
{
	local Vehicles V;
	local TNMCarcass C;
	foreach allactors(class'Vehicles',V,'ShuttleReturn')
		V.EnterWorld();
	foreach allactors(class'TNMCarcass',C)
	{
		if (C.Tag == 'SpaceAlienCarc')
			C.EnterWorld();
		if (C.Tag == 'KylieCarcass' && !flags.GetBool('Kylie_Dead_M24') && !flags.GetBool('Kylie_Deleted'))
			C.EnterWorld();
	}
}

function TrestkonLeaveShuttle()
{
	local TNMPawn t;	
	foreach allactors(class'TNMPawn',t,'TrestkonRyan')
		t.SetOrders('Patrolling','TrestkonRyanPosition',true);
}

function PlayABIEndgame01()
{
	local TNMPawn r;
	foreach allactors(class'TNMPawn',r,'Ryan')
		break;
	StartConversationByName('ABIEndgame01', r, False, True);
	
	if (Trestkon(GetPlayerPawn()) != None)
		Trestkon(GetPlayerPawn()).SetAchievement("achEndingABI");
}

function PlayABIEndgame02()
{
	local TNMPawn r;
	foreach allactors(class'TNMPawn',r,'Ryan')
		break;
	StartConversationByName('ABIEndgame02', r, False, True);	
}

function TrestkonLeaveABI()
{
	local TNMPawn t;	
	foreach allactors(class'TNMPawn',t,'TrestkonRyan')
		t.SetOrders('Patrolling','TrestkonLeavePoint',true);
}

// ----------------------------------------------------------------------
// Narc
// ----------------------------------------------------------------------

function TrestWalkToPoint02()
{
	local TNMPawn t;	
	foreach allactors(class'TNMPawn',t,'TrestkonNarc')
		t.SetOrders('Patrolling','NarcTrestkonPoint02',true);
}

function PlayNarcEndgame02()
{
	local TNMPawn t;
	foreach allactors(class'TNMPawn',t,'TrestkonNarc')
		break;
	StartConversationByName('NarcEndgame02', t, False, True);
	
	if (Trestkon(GetPlayerPawn()) != None)
		Trestkon(GetPlayerPawn()).SetAchievement("achEndingNarc");
}

function TrestWalkToPoint03()
{
	local TNMPawn t;	
	foreach allactors(class'TNMPawn',t,'TrestkonNarc')
		t.SetOrders('Patrolling','NarcTrestkonPoint03',true);
}

function PlayNarcEndgame03()
{
	local TNMPawn t;
	foreach allactors(class'TNMPawn',t,'TrestkonNarc')
		break;
	StartConversationByName('NarcEndgame03', t, False, True);
}

function TrestWalkToPoint04()
{
	local TNMPawn t;	
	foreach allactors(class'TNMPawn',t,'TrestkonNarc')
		t.SetOrders('Patrolling','NarcTrestkonPoint04',true);
}

function PlayNarcEndgame04()
{
	local TNMPawn t;
	foreach allactors(class'TNMPawn',t,'TrestkonNarc')
		break;
	StartConversationByName('NarcEndgame04', t, False, True);
}

function FadeInAliens()
{
	local TNMPawn p;
	foreach allactors(class'TNMPawn',p)
		if(p.isa('alien'))
		{
			p.EnterWorld();
			fade(5,p,true);
		}
}

function SlowDown1()
{
	trestkon(player).slomoandpitch(0.5);
}

function SlowDown2()
{
	trestkon(player).slomoandpitch(0.25);
}

function NormalSpeed()
{
	trestkon(player).slomoandpitch(1.0);
}

function PlayNarcEndgame05()
{
	local TNMPawn t;
	foreach allactors(class'TNMPawn',t,'CircleTrestkon')
		break;
	StartConversationByName('NarcEndgame05', t, False, True);
}

function FadeOutTrestkon()
{
	local treskton t;
	foreach allactors(class'treskton',t,'CircleTrestkon')
		fade(2.0,t,false);
}

// ----------------------------------------------------------------------
// Denouement
// ----------------------------------------------------------------------

function PlayDenouement()
{
	local TNMPawn n;
	foreach allactors(class'TNMPawn',n,'Narcissus')
		break;
	player.StartConversationByName('01_Sols', n, False, True);
}

function SpawnGwog()
{
	local TNMPawn p;

	foreach allactors(class'TNMPawn',p,'Beeblequix')
	{
		p.multiskins[6]=Texture'pinkmasktex';
		
		// Then fade him out
		fade(2, p, FALSE);
	}

	foreach allactors(class'TNMPawn',p,'Pattie')
	{		
		// Then fade him out
		fade(2, p, FALSE);
	}

	foreach allactors(class'TNMPawn',p,'Gwog')
	{
		p.EnterWorld();
		fade(2, p, TRUE);
	}
}

function PlayDenouementEnd()
{
	local TNMPawn n;
	foreach allactors(class'TNMPawn',n,'Narcissus')
		break;
	player.StartConversationByName('17_Final', n, False, True);
}

// ----------------------------------------------------------------------
// CALLBACK SWITCH
// ----------------------------------------------------------------------

function HandleGameEvent(name scriptFunction)
{
//	Log("scriptfunction", scriptfunction);
	switch ( scriptfunction)
	{
		// Training
		case 'ActivateCamera' 		: ActivateCamera(); 			break;
		case 'MaxComputers' 		: MaxComputers(); 				break;
		case 'UpgradeDemolitions' 	: UpgradeDemolitions(); 		break;
		case 'MaxDemolitions' 		: MaxDemolitions(); 			break;
		case 'MaxFists' 			: MaxFists(); 					break;
		case 'GiveTargettingAug' 	: GiveTargettingAug(); 			break;
		case 'HidePhas' 			: HidePhas(); 					break;
		case 'UnHidePhas' 			: UnHidePhas(); 				break;
		case 'RemoveAllInventory' 	: RemoveAllInventory(); 		break;
		case 'SendMoreWine'			: SendMoreWine(); 				break;
		// Intro
		case 'BanFighters'			: BanFighters(); 				break;
		case 'DDAppear'				: DDAppear(); 					break;
		case 'DDEquipSword'			: DDEquipSword(); 				break;
		case 'DDEnterAlley'			: DDEnterAlley(); 				break;
		case 'DDVanish'				: DDVanish(); 					break;
		case 'PlayIntro1'			: PlayIntro1(); 				break;
		case 'PlayIntro2'			: PlayIntro2(); 				break;
		case 'PlayIntro3'			: PlayIntro3(); 				break;
		case 'PlayIntro4'			: PlayIntro4(); 				break;
		case 'PlayIntro5'			: PlayIntro5(); 				break;
		case 'PlayIntro6'			: PlayIntro6(); 				break;
		case 'ArmThugs'				: ArmThugs(); 					break;
		case 'ClearCheckpoint'		: ClearCheckpoint(); 			break;
		case 'SpawnCultWar'			: SpawnCultWar(); 				break;
		case 'KashueLeave'			: KashueLeave(); 				break;
		case 'TrestkonAppear'		: TrestkonAppear(); 			break;
		case 'EndIntro'				: EndIntro(); 					break;
		// Endgames
		case 'PrintEndgameQuoteABI'	: PrintEndgameQuote(0); 		break;
		case 'PrintEndgameQuoteWC1'	: PrintEndgameQuote(1); 		break;
		case 'PrintEndgameQuoteWC2'	: PrintEndgameQuote(2); 		break;
		case 'PrintEndgameQuotePDX'	: PrintEndgameQuote(3); 		break;
		case 'PrintEndgameQuoteNARC': PrintEndgameQuote(4); 		break;
		case 'RollCredits'			: RollCredits(); 				break;
		// PDX
		case 'PlayPDXEndgame01'		: PlayPDXEndgame01(); 			break;
		case 'BanScara'				: BanScara(); 					break;
		case 'PlayPDXEndgame02'		: PlayPDXEndgame02(); 			break;
		case 'TrestkonMoveUp'		: TrestkonMoveUp(); 			break;
		case 'PlayPDXEndgame03'		: PlayPDXEndgame03(); 			break;
		case 'TRMAppear'			: TRMAppear(); 					break;
		case 'DXOLightsOut'			: DXOLightsOut(); 				break;
		case 'BanWCThugs'			: BanWCThugs(); 				break;
		case 'DDSlumsAppear'		: DDSlumsAppear(); 				break;
		// WC
		case 'PlayWCEndgame01'		: PlayWCEndgame01(); 			break;
		case 'PlayWCEndgame02'		: PlayWCEndgame02(); 			break;
		case 'KylieAppear'			: KylieAppear(); 				break;
		case 'PlayWCEndgameKylie'	: PlayWCEndgameKylie(); 		break;
		case 'ScaraLeave'			: ScaraLeave(); 				break;
		case 'ThatGuyAndZPLeave'	: ThatGuyAndZPLeave(); 			break;
		// ABI
		case 'ShuttleSeq02Appear'	: ShuttleSeq02Appear(); 		break;
		case 'ShuttleReturnAppear'	: ShuttleReturnAppear(); 		break;
		case 'TrestkonLeaveShuttle'	: TrestkonLeaveShuttle(); 		break;
		case 'PlayABIEndgame01'		: PlayABIEndgame01(); 			break;
		case 'PlayABIEndgame02'		: PlayABIEndgame02(); 			break;
		case 'TrestkonLeaveABI'		: TrestkonLeaveABI(); 			break;
		// Narcissus
		case 'TrestWalkToPoint02'	: TrestWalkToPoint02(); 		break;
		case 'PlayNarcEndgame02'	: PlayNarcEndgame02(); 			break;
		case 'TrestWalkToPoint03'	: TrestWalkToPoint03(); 		break;
		case 'PlayNarcEndgame03'	: PlayNarcEndgame03(); 			break;
		case 'TrestWalkToPoint04'	: TrestWalkToPoint04(); 		break;
		case 'PlayNarcEndgame04'	: PlayNarcEndgame04(); 			break;
		case 'FadeInAliens'			: FadeInAliens(); 				break;
		case 'SlowDown1'			: SlowDown1(); 					break;
		case 'SlowDown2'			: SlowDown2(); 					break;
		case 'NormalSpeed'			: NormalSpeed(); 				break;
		case 'PlayNarcEndgame05'	: PlayNarcEndgame05(); 			break;
		case 'FadeOutTrestkon'		: FadeOutTrestkon(); 			break;
		case 'FadeInCircle'			: Spawn(class'NarcFadeInInfo'); break;
		// Denouement
		case 'PlayDenouement'		: PlayDenouement(); 			break;
		case 'SpawnGwog'			: SpawnGwog(); 					break;
		case 'PlayDenouementEnd'	: PlayDenouementEnd(); 			break;
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     endgameQuote(0)="EXISTENCE IS RANDOM. HAS NO PATTERN SAVE WHAT WE IMAGINE AFTER STARING AT IT FOR TOO LONG. NO MEANING SAVE WHAT WE CHOOSE TO IMPOSE."
     endgameQuote(1)="    -- ALAN MOORE"
     endgameQuote(2)="HERE'S TO LOWERING CASKETS OF OLD FRIENDS, CHOICE AND CONSEQUENCE - WE'LL BIRTH A NEW DAY WITH THE DEATH OF AN OLD AND START OVER."
     endgameQuote(3)="    -- ATREYU"
     endgameQuote(4)="CONSCIENCE IS BUT A WORD THAT COWARDS USE, DEVISED AT FIRST TO KEEP THE STRONG IN AWE."
     endgameQuote(5)="    -- WILLIAM SHAKESPEARE"
     endgameQuote(6)="IN A TRUE STATE OF NATURE, INDEED, ALL MEN ARE BORN EQUAL, BUT THEY CANNOT CONTINUE IN THIS EQUALITY... THEY RECOVER IT ONLY BY THE PROTECTION OF LAWS."
     endgameQuote(7)="    -- CHARLES DE MONTESQUIEU"
     endgameQuote(8)="NO REASON TO GET EXCITED, THE THIEF HE KINDLY SPOKE. THERE ARE MANY HERE AMONG US WHO FEEL THAT LIFE IS BUT A JOKE."
     endgameQuote(9)="    -- BOB DYLAN"
     endgameDelays(0)=13.000000
     endgameDelays(1)=12.500000
     endgameDelays(2)=10.000000
     endgameDelays(3)=15.500000
     endgameDelays(4)=11.000000
     RemoteRole=ROLE_DumbProxy
}

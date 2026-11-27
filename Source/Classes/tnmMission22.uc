class tnmMission22 extends tnmMission20and22;

var inventory launcher;

var localized string strAccompliceAward, strEscapeGoal, strSurvivalAward, strBuggedGoal;
var localized string strBombersGoal, strMysteryGoal, strMysteryGoal2, strAYBABTUAward;
var localized string strPJDead, strAlphaDead, strAlphaDead2, strAlphaDead3, strAlphaUnconscious;
var localized string strBombersDead, strBombersDead2, strWinqumanDead, strWinqumanUnconscious;
var localized string strWolfyDead, strWolfyDeadEarly, strMarathonAward, strSurviveGoal;
var localized string strVavrekDead, strVavrekRobbed, strAirControlAward, strPosterAward;
var localized string strZPDeadPostAward, strZPDeadPreAward, strZPUnconPostAward, strZPUnconPreAward;
var localized string strMessengerAward, strAssassinAward, strAthenaDead;
var localized string strTemplarDead1, strTemplarDead2, strTemplarKnockedOut1, strTemplarKnockedOut2;
var localized string strBeefmanDead1, strBeefmanDead2, strBeefmanKnockedOut1, strBeefmanKnockedOut2;
var localized string strTRMDead, strRescueAward, strRealZPQuest, strKevoDead, strDebuggingAward, strAlphaDefeated;

var inventory RegistrationUCspawn;
var inventory RegistrationSecretUCspawnA;
var inventory RegistrationSecretUCspawnB;

struct sUCData
{
	var name				spawnTag;
	var class<ScriptedPawn>	spawnClass;
	var name				Tag;
	var name				orderTag;
	var int					count;
	var float				lastKilledTime; // Isn't this an issue for transient MS?
};

var sUCData spawnData[3];

function SlumHologramDisappear()
{
	local TNMPawn p;

	foreach allactors(class'TNMPawn',p,)
		if ((p.tag == 'KylieHolocom')||
		    (p.tag == 'ZeroHolocom')||
		    (p.tag == 'PhasmatisHolocom')||
		    (p.tag == 'SlicerHolocom'))
		{
			p.LeaveWorld();
		}
}

function TortureKnockConvo()
{
	local actor a;
	local Pawn P;
	local Trestkon T;
	local bool bHasKevoBody;

	if (!flags.GetBool('AJ_ComeIn_Played') && flags.GetBool('QR_MAIN_KidnapKevo') && !flags.GetBool('Kevo_Dead'))
	{
		bHasKevoBody = False;
		for (P = Level.PawnList; P != None; P = P.NextPawn)
		{
			T = Trestkon(P);
			if (T != None && T.inHand != None && T.inHand.IsA('tnmpovcorpse') && tnmpovcorpse(T.inHand).givenbindname == "Kevo")
			{
				bHasKevoBody = True;
				break;
			}
		}

		if (bHasKevoBody)
		{
			foreach allactors(class'actor', a, 'TortureKnock_Body')
				a.trigger(none,player);
		}
		else
		{
			foreach allactors(class'actor', a, 'TortureKnock_NoBody')
				a.trigger(none,player);
		}
	}	
}

function AJChangeClothes()
{
	local TNMPawn p;
	local tnmpovcorpse povc;
	local TNMCarcass carc;
	local actor a;
	local Pawn Pw;
	local Trestkon T;

	foreach allactors(class'TNMPawn',p,'AJ')
	{
		p.Multiskins[0] = Texture(DynamicLoadObject("TNMCharacters.Skins.AJTex0_2", class'Texture'));
		p.Multiskins[2] = Texture(DynamicLoadObject("TNMCharacters.Skins.AJTex1", class'Texture'));
		p.Multiskins[3] = Texture(DynamicLoadObject("TNMCharacters.Skins.AJTex0_2", class'Texture'));
		p.Multiskins[4] = Texture(DynamicLoadObject("TNMCharacters.Skins.AJTex0_2", class'Texture'));
	}

	for (Pw = Level.PawnList; Pw != None; Pw = Pw.NextPawn)
	{
		T = Trestkon(Pw);
		if (T != None)
		{
			povc = tnmpovcorpse(T.inHand);
			if (povc != None)
			{
				T.PutInHand(None);
				povc.Destroy();
			}
		}
	}

	foreach allactors(class'TNMCarcass', carc, 'KevoCarcass')
	{
		carc.EnterWorld();
		carc.ItemName = "Dead Body (Kevo)";
	}
	
	Trestkon(Player).SetAchievement("achKevoCapture");
}

function OpenTortureRoom()
{
	local KnockableMover K;
	foreach AllActors(class'KnockableMover', K, 'TortureRoomDoors')
		OpenDoor(K);
}

function EvacuateTemplae()
{
	local TNMPawn p;

	if (flags.GetBool('QR_SUB_LureThePriest'))
	{
		foreach allactors(class'TNMPawn',p,)
		{
			if (p.Tag == 'OiNutter' || p.Tag == 'FleeingGoatFemale' || p.Tag == 'OiBodyguard1' || p.Tag == 'OiBodyguard2')
				p.EnterWorld();
			else if (p.Tag == 'ZeroPresence')
			{
				p.bKeepWeaponDrawn=true;
				p.SetupWeapon(true, true);
			}
		}
	}
}

function ShootOiNutter()
{
	local TNMPawn p, z;

	if (!flags.GetBool('Zero_Dead') && !flags.GetBool('Zero_Unconscious'))
	{
		foreach allactors(class'TNMPawn',z,'ZeroPresence')
		{
			// z.LookAtActor(p, true, true, true, 0, 1);
			z.PlayAnim('Shoot2H', 3.0, 0.05);
			z.PlaySound(Sound'DeusExSounds.Weapons.RifleFire', SLOT_None, 1.5, True, 65535); // Global sound), should be silenced but whatever
		}
		foreach allactors(class'TNMPawn',p,'OiNutter')
		{
			p.HealthHead = 0;
			p.Health = 0;
			p.bStunned = false;
			p.TakeDamage(1, p, p.Location, vect(-10,0,25), 'shot'); // Headshot = collision height(35.625000) * 0,7
		}

		// Give the player some skillpoints
		if (!flags.GetBool('PM_Zero_ShotOi_Played')) // Need a check for nightmare mode
			SkillAward(200, strAccompliceAward);

		// Send a PM from ZeroPresence when it's done
		SendPM("PM_Zero_ShotOi");
	}
}

function LandedChopperAppear()
{
	local BlackHelicopter B;
	foreach allactors(class'BlackHelicopter',B,'BlackChopper02')
		B.EnterWorld();
}

function CarCrash()
{
	// The pox upon the fact that both HovercarCrash.uc and TNMVehicles.uc are in TNMDeco!!
	local Vehicles V;
	local TNMPawn p;
	local TNMRobot r;
	local CaroneElevator CE;
	local TNMDecoration D;
	local securitycamera cam;

	// Make the wreck appear
	foreach allactors(class'Vehicles',V,'HovercarCrash')
		V.EnterWorld();

	flags.SetBool('MS_MoveLobbyGuards', true, , 23);

	// If the player has picked up an ID card, void the sucker
	if (flags.GetBool('HAS_ATCIDCard') && !flags.GetBool('MS_ATCVoidID'))
	{
		// Make all the guards hostile again if the player fucks up
		foreach AllActors(class'TNMPawn',p,)
			if (p.Tag == 'ATCGuard' || p.Tag == 'ATCGuardAlert1' || p.Tag == 'ATCGuardAlert2' || p.Tag == 'ATCGuardAlert3' || p.Tag == 'ATCGuardAlert4' || p.Tag == 'ShackGuard')
				p.ChangeAlly('Player',-1.000000,true);
		foreach allactors(class'TNMRobot',r,'ATCBot')
			r.ChangeAlly('Player',-1.000000,true);
		foreach allactors(class'securitycamera', cam, )
			cam.memoryTime=cam.default.memoryTime;

		flags.SetBool('MS_ATCVoidID',true,,23);
	}
	Trestkon(GetPlayerPawn()).SetAchievement("achHovercar");
}

function DTDropItems()
{
	local navigationpoint n;
	local actor a;
	foreach allactors(class'navigationpoint',n,'DTDropItemPoint')
		break;
	a=spawn(class'WeaponModAccuracy',,,n.location);
	if(!flags.GetBool('DT_NoRoom_Accuracy'))
		spawn(class'WeaponModSilencer',,,a.location+vect(2.0,0,0)*a.collisionradius);
	if(!flags.GetBool('DT_NoRoom_Silencer') && !flags.GetBool('DT_NoRoom_Accuracy'))
		spawn(class'AugmentationUpgradeCannister',,,a.location+vect(-2.0,0,0)*a.collisionradius);
}

function DTHologramAppear()
{
	local TNMPawn p;
	foreach allactors(class'TNMPawn', p, 'DTHologram')
		p.EnterWorld();		
}

function DTHologramDisappear()
{
	local TNMPawn p;
	foreach allactors(class'TNMPawn', p, 'DTHologram')
		p.LeaveWorld();		
}

function MelkShutOff()
{
	local particlegenerator melksource;
	//shut off the flow
	foreach AllActors(class'particlegenerator',melksource,'MelkSource')
		melksource.Destroy();

	//Possible bark from athena

	flags.SetBool('MS_MelkShutOff',true,,23);
}

function RespawnAthena(class<TNMPawn> athenaclass, vector deathlocation)
{
	local TNMCarcass c;
	local FleshFragment f;
	local NavigationPoint n;
	local vector spawnlocation;
	local rotator spawnrotation;
	local particlegenerator melksource;
	local int i;
	local rotator rot;
	local athenarespawninfo spawner;

	if (!flags.GetBool('MS_MelkShutOff'))
	{
		spawner=Spawn(Class'AthenaRespawnInfo'); //handle her respawning
		spawner.athena_spawn_class=athenaclass;
		
		/* // Seemingly broken in 1.0 (spawns in a wall) and looks weird in 2.0
		foreach allactors(class'NavigationPoint', n, 'MelkPool')
		{
			spawnlocation = n.location;
			spawnrotation = n.rotation;
			break;
		}
		
		foreach AllActors(class'particlegenerator',melksource,'MelkSource')
			melksource.Destroy();

		rot.pitch = 1000;
		for (i = 0; i < 10; i++)
		{
			rot.yaw = 65535 * i / 10;
			melksource = spawn(class'particlegenerator', ,'MelkSource', spawnlocation + vect(1,0,0) >> rot, rot);
			melksource.particleTexture = texture'SnowFlake';
			melksource.particleLifeSpan = 10;
			melksource.bGravity = true;
			melksource.LifeSpan=4.5;
		}*/
	}
	else
		Trestkon(player).SetAchievement("achAthena");
}

function SetEnvironment()
{
	local TNMInformationDevices inf;
	local TNMPawn p;
	// Determine which bulletins to spawn
	if (flags.GetBool('Killer_PDX') || flags.GetBool('Killer_FC'))
	{
		foreach allactors(class'TNMInformationDevices',inf,'KillerBulletin')
			inf.EnterWorld();
		// Remove some of the random citizens if the player is a killer
		foreach allactors(class'TNMPawn',p,'GenericPawn')
			p.LeaveWorld(); //todo: use correct tag
	}
	else if (flags.GetBool('ALLIED_WC'))
	{
		foreach allactors (class'TNMInformationDevices',inf, 'WCBulletin')
			inf.EnterWorld();
	}
	else
	{
		foreach allactors (class'TNMInformationDevices',inf, 'PDXBulletin')
			inf.EnterWorld();
	}
}

// ----------------------------------------------------------------------
// FirstFrame()
// 
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
	local inventory inv;
	local TNMPawn p;
	local TNMRobot r;
	local TNMCarcass c;
	local Containers cont;
	local TNMInformationDevices inf;
	local int kills;
	local deusexmover M;
	local triggerlight l;
	local ParticleGenerator S; // S for Smoke because p is already taken >_<
	local WarpZoneInfo W;
	local AmbientSoundTriggered A;
	local securitycamera cam;
	local int i,check;
	local Actor tmp;
	local CouchLeather CL;
	local BlackHelicopter H;
	local keypad kp;
	local TNMDecoration deco;
	local DeusExDecoration dxDeco;
	local Seat burntDeco;
	local DeusExWeapon urKnife;

	Super.FirstFrame();

	if (localURL == "22_FCDOWNTOWN")
	{
		SetEnvironment();
		SetupPortal('FC_Current_Booth','FC_Current_Booth_Sound');

		if (flags.GetBool('ALLIED_WC'))
		{
			// Remove the whole Sol's Bar thing
			foreach AllActors(Class'Actor',tmp,'SolsWitness')
				tmp.Destroy();
			foreach AllActors(Class'Actor',tmp,'SolsFireWall')
				tmp.Destroy();
			foreach AllActors(Class'Actor',tmp,'AlphaOperator')
				tmp.Destroy();
			foreach AllActors(Class'Actor',tmp,'SolsPlot')
				tmp.Destroy();
			foreach AllActors(Class'Actor',tmp,'SolBomber')
				tmp.Destroy();
			foreach AllActors(Class'Actor',tmp,'BomberVan')
				tmp.Destroy();

			SealDoor('SolsDoor');
			SealDoor('SolsBackDoor');

			// And make all the firewalls hostile
			foreach AllActors(class'TNMPawn',p,'Firewall')
				p.ChangeAlly('Player', -1.000000, true);

			// ...and the PDX bots
			foreach AllActors(class'TNMRobot',r,'MilitaryBotPDX')
				r.ChangeAlly('Player', -1.000000, true);
			foreach AllActors(class'TNMRobot',r,'SecurityBot2PDX')
				r.ChangeAlly('Player', -1.000000, true);
		}

		// Spawn Pimp-Jojo if the player did the DXO side-mission (unless PJ is knocked out or dead)
		if (flags.GetBool('QC_SUB_Bugging') && !flags.GetBool('PJ_Dead') && !flags.GetBool('PJ_Unconscious'))
		{
			foreach allactors(class'TNMPawn', p, 'PimpJojo')
				p.EnterWorld();

			// Also send a PM with directions from PJ
			SendPM("PM_PJ_Directions");
		}

		// Award skillpoints for escaping the slums and complete the objective
		if (!flags.GetBool('MS_EscapeSlums_AwardGiven'))
		{
			AddGoal('EscapeSlums', strEscapeGoal, true, true);
			SkillAward(1000, strSurvivalAward);
			flags.SetBool('MS_EscapeSlums_AwardGiven',true,,23);
		}

		// Handle the awards for the goat templae mission
		if ((LastMap() ~= "22_GoatCity") && flags.GetBool('QC_CULT_KillAthena') && !flags.GetBool('KillCount_GoatCityDone'))
		{
			kills = flags.GetInt('KillCount_GoatCity') + flags.GetInt('KillCount_GoatTemplae1') + flags.GetInt('KillCount_GoatTemplae2');
	
//			// Award Massacre Award 
//			//if (kills >= GoatCityLiving22 + GoatTemplae1Living22 + GoatTemplae2Living22)
//			//	SkillAward(200, "Massacre Award");

			// todo - readd me :(
			// Identify the player as a killer
			//if (kills >= (GoatCityLiving22 + GoatTemplae1Living22 + GoatTemplae2Living22) / 5) //5 is a placeholder
			//	flags.SetBool('Killer_Goats', TRUE, , 23);

//			// Award Pacifist Award
//			if (kills <= 1) //Athena
//				SkillAward(200, "Pacifist Award");

			flags.SetBool('KillCount_GoatCityDone' , TRUE, ,23);
		}

		// Handle the awards for the llama temple mission
		if ((LastMap() == "22_LlamaTemple") && flags.GetBool('QC_CULT_KillBeefman') && !flags.GetBool('KillCount_LlamaTempleDone'))
		{
			kills = flags.GetInt('KillCount_LlamaTemple');

//			// Award Massacre Award 
//			//if (kills >= LlamaTempleLiving22)
//			//	SkillAward(200, "Massacre Award");

			// todo - readd me :(
			// Identify the player as a killer
			//if (kills >= LlamaTempleLiving22 / 5) //5 is a placeholder
			//	flags.SetBool('Killer_Llamas', TRUE, , 23);

//			// Award Pacifist Award
//			if (kills <= 1) // Beefman
//				SkillAward(200, "Pacifist Award");

			flags.SetBool('KillCount_LlamaTempleDone' , TRUE, ,23);
		}

		if(flags.GetBool('NVShackerPet_Abom') && !flags.GetBool('MS_NVShackerPetEntered'))
		{
			foreach AllActors(class'TNMRobot',r,'NVShackerPet')
				r.EnterWorld();

			flags.SetBool('MS_NVShackerPetEntered',true,,23);
		}
	}
	else if (localURL == "22_FCCORPORATE")
	{
		SetEnvironment();
		SetupPortal('FC_Current_Booth','FC_Current_Booth_Sound');

		if (flags.GetBool('ALLIED_PDX'))
		{
			// Make all the WC people hostile
			foreach AllActors(class'TNMPawn',p,)
			{
				if ((p.Tag == 'WCSecurity')||
				    (p.Tag == 'WCCommando')||
				    (p.Tag == 'WCThug')||
				    (p.Tag == 'WCIDAgent')||
				    (p.Tag == 'PDXHQAttackGroup')||
				    (p.Tag == 'OldHQAttackGroup')||
				    (p.Tag == 'Checkpoint1AttackGroup')||
				    (p.Tag == 'Checkpoint2AttackGroup'))
					p.ChangeAlly('Player', -1.000000, true);
			}

			// Make all the WC bots hostile
			foreach AllActors(class'TNMRobot',r,)
			{
				if ((r.Tag == 'SecurityBot2WC')||
					(r.Tag == 'WCHQPatrolBot')||
				    (r.Tag == 'MilitaryBotWC')||
				    (r.Tag == 'PDXHQAttackGroup') || r.Tag == 'SecurityBot3WC')
					r.ChangeAlly('Player', -1.000000, true);
			}
			
			// Make all the firewalls friendly
			foreach AllActors(class'TNMPawn',p,)
			{
				if ((p.Tag == 'Firewall')||
				    (p.Tag == 'FireWall2'))
					p.ChangeAlly('Player', 1.000000, true);
			}

			// Make all the PDX bots friendly
			foreach AllActors(class'TNMRobot',r,)
			{
				if ((r.Tag == 'SecurityBot2PDX')||
				    (r.Tag == 'MilitaryBotPDX') || r.Tag == 'SecurityBot3PDX')
					r.ChangeAlly('Player', 1.000000, true);
			}
		}
		else if (flags.GetBool('ALLIED_WC'))
		{
			// Make all the WC people friendly
			foreach AllActors(class'TNMPawn',p,)
			{
				if ((p.Tag == 'WCSecurity')||
				    (p.Tag == 'WCCommando')||
				    (p.Tag == 'WCThug')||
				    (p.Tag == 'WCIDAgent')||
				    (p.Tag == 'PDXHQAttackGroup')||
				    (p.Tag == 'OldHQAttackGroup')||
				    (p.Tag == 'Checkpoint1AttackGroup')||
				    (p.Tag == 'Checkpoint2AttackGroup'))
					p.ChangeAlly('Player', 1.000000, true);
			}

			// Make all the WC bots friendly
			foreach AllActors(class'TNMRobot',r,)
			{
				if ((r.Tag == 'SecurityBot2WC')||
					(r.Tag == 'WCHQPatrolBot')||
				    (r.Tag == 'MilitaryBotWC')||
				    (r.Tag == 'PDXHQAttackGroup') || r.Tag == 'SecurityBot3WC')
					r.ChangeAlly('Player', 1.000000, true);
			}
			
			// Make all the firewalls hostile
			foreach AllActors(class'TNMPawn',p,)
			{
				if ((p.Tag == 'Firewall')||
				    (p.Tag == 'FireWall2'))
					p.ChangeAlly('Player', -1.000000, true);
			}

			// Make all the PDX bots hostile
			foreach AllActors(class'TNMRobot',r,)
			{
				if ((r.Tag == 'SecurityBot2PDX')||
				    (r.Tag == 'MilitaryBotPDX') || r.Tag == 'SecurityBot3PDX')
					r.ChangeAlly('Player', -1.000000, true);
			}

			// Lock the PDX HQ securely
			SealDoor('PDXHQDoors');
			SealDoor('PDXSideDoor1');
			SealDoor('PDXSideDoor2');
		}

		// Spawn Raving's thugs if the player has stolen from him (but only if either Raving or Andreus is still alive) 
		if (flags.GetBool('StoleFromWeaponShop') && (!flags.GetBool('Raving_Dead') || !flags.GetBool('Andreus_Dead')))
			foreach allactors(class'TNMPawn',p,'RavingThug')
				p.EnterWorld();

		// Award skillpoints for escaping the slums and complete the objective
		if (!flags.GetBool('MS_EscapeSlums_AwardGiven'))
		{
			AddGoal('EscapeSlums', strEscapeGoal, true, true);
			SkillAward(1000, strSurvivalAward);
			flags.SetBool('MS_EscapeSlums_AwardGiven',true,,23);
		}

//		if (!flags.GetBool('MS_ZPGoatPortalZoneEntTriggered'));
//		foreach allactors( class'warpzoneinfo', w, 'ZPGoatPortalZoneEnt')
//		{
//			w.Trigger(none, none);
//			flags.SetBool('MS_ZPGoatPortalZoneEntTriggered', true, ,23);
//		}

		// Send an invite from Wolfy
		SendPM("PM_WolfySummons");

		// After you've received your first mission
		if (flags.GetBool('QR_MAIN_FreeKevo') || flags.GetBool('QR_MAIN_KidnapKevo'))
		{
			if (flags.GetBool('ALLIED_CULT_GOAT') && !flags.GetBool('QR_CULT_KillBeefman') && !flags.GetBool('QC_CULT_KillBeefman')) // Can be completed without being received
				SendPM("PM_DT_QuestSummon");
			else if (flags.GetBool('ALLIED_CULT_LLAMA') && !flags.GetBool('QR_CULT_KillAthena') && !flags.GetBool('QC_CULT_KillAthena'))
				SendPM("PM_Abom_QuestSummon");
		}
		
		if (flags.GetBool('HelpRealZP_DeviceAttached') && !flags.GetBool('MS_RealZP_Transmitter'))
		{
			foreach AllActors(class'DeusExMover',m,'DatablockSwitch')
			{
				m.bFrobbable=True;
				m.bHighlight=True;
				break;
			}
			flags.SetBool('MS_RealZP_Transmitter',true,,23);
		}
	}
	else if (localURL == "22_FCCORPSEWERS")
	{
		if (flags.GetBool('ALLIED_WC'))
		{
			// Lock the PDX HQ securely
			SealDoor('PDXDoor');
		}
		if (flags.GetBool('ALLIED_PDX'))
		{
			foreach allactors(class'TNMPawn',p,)
				if (p.IsA('WCScubaDiver'))
					P.ChangeAlly('Player', -1.0, true);
		}
		// Disable the cameras if you've got Black ICE to turn them off
		if (flags.GetBool('WCHQ_CamerasOffline'))
		{
			foreach allactors(class'securitycamera',cam,)
				cam.bActive = false;
		}
	}
	else if (localURL == "22_SOLSBAR")
	{
		foreach AllActors(class'Seat', burntDeco)
		{
			if (burntDeco.IsA('CouchLeatherBlue') || burntDeco.IsA('BarChair'))
			{
				if (burntDeco.IsA('BarChair'))
					burntDeco.SetPropertyText("SkinColor", "SC_Burnt");
				else if (burntDeco.IsA('CouchLeatherBlue'))
					burntDeco.SetPropertyText("SkinColor", "SC_BlueBurnt");
				burntDeco.TravelPostAccept();
			}
		}
	}
	else if (localURL == "22_FCSLUMS" || localURL == "22_FCSLUMS_PDX" || localURL == "22_FCSLUMS_WC")
	{
		SetEnvironment();
		SetupPortal('FC_Current_Booth','FC_Current_Booth_Sound');

		/*
		   NB! These EnterWorld and LeaveWorld functions are set up so if you're WC-aligned, 
		   the firewalls and the milbot at the checkpoint will not be removed when you return 
		   to capture Kevo-Sama. This is on purpose!
		*/

		// Spawn WC Thugs or Firewalls and a holocom depending on player alliance
		if (!flags.GetBool('MS_SlumEnemiesSpawned'))
		{
			if (flags.GetBool('ALLIED_PDX'))
			{
				// Generic enemies
				foreach allactors(class'TNMCarcass',c,'WCCarcass')
					c.EnterWorld();
				
				foreach allactors(class'DeusExDecoration',dxDeco)
				{
					if (dxDeco.Tag == 'WCCube' || dxDeco.Tag == 'WCSecurityComp')
						dxDeco.Destroy();
				}

				foreach allactors(class'TNMPawn',p,)
					if ((p.tag == 'WCThug')||
					    (p.tag == 'WCCommando')||
					    (p.tag == 'WCKeyHolder'))
					{
						p.EnterWorld();
					}

				foreach allactors(class'TNMRobot',r,)
					if ((r.tag == 'SecurityBot2WC') || (r.tag == 'MilitaryBotWC') || r.Tag == 'SecurityBot3WC')
						r.EnterWorld();

				// Holocom: Spawn Kylie if ZP is dead except if he was killed before DXI or Kylie is also dead
				if (flags.GetBool('Zero_Dead') && !flags.GetBool('Zero_Dead_M20') && !flags.GetBool('Kylie_Dead'))
				{
					foreach allactors(class'TNMPawn',p,'KylieHolocom')
						p.EnterWorld();
				}
				else if (!flags.GetBool('Zero_Dead')) // otherwise, spawn ZP
				{
					if (player.inhand != none && player.inhand.isA( 'tnmpovcorpse' ) && tnmpovcorpse(player.inhand).givenbindname == "Zero")
					{
					}
					else
						foreach allactors(class'TNMPawn',p,'ZeroHolocom')
							p.EnterWorld();
				}

				// Make sure the game remembers if ZP was killed in DXI (for denouement)
				if (flags.GetBool('Zero_Dead') && !flags.GetBool('Zero_Dead_M20'))
					flags.SetBool('Zero_Dead_DXI',true,,0);
			}
			if (flags.GetBool('ALLIED_WC'))
			{
				foreach allactors(class'DeusExMover',M,'FactionFlipper')
					M.Trigger(None,None);
			
				// Generic enemies
				foreach allactors(class'TNMCarcass',c,'FireWallCarcass')
					c.EnterWorld();

				foreach allactors(class'TNMPawn',p,)
					if ((p.tag == 'Firewall')||
					    (p.tag == 'CheckpointFirewall')||
					    (p.tag == 'CSISniper')||
					    (p.tag == 'PDXKeyHolder'))
					{
						p.EnterWorld();
					}
				
				foreach allactors(class'DeusExDecoration',dxDeco)
				{
					if (dxDeco.Tag == 'PDXCube' || dxDeco.Tag == 'PDXSecurityComp')
						dxDeco.Destroy();
				}

				foreach allactors(class'TNMRobot',r,)
					if ((r.tag == 'SecurityBot2PDX') || (r.tag == 'MilitaryBotPDX') || r.Tag == 'SecurityBot3PDX')
						r.EnterWorld();

				// Holocom: Spawn Phas if Slicer is dead except if he was killed before DXI
				if (flags.GetBool('Slicer_Dead') && !flags.GetBool('Slicer_Dead_M20'))
				{
					foreach allactors(class'TNMPawn',p,'PhasmatisHolocom')
						p.EnterWorld();
				}
				else if (!flags.GetBool('Slicer_Dead') && !flags.GetBool('Slicer_Dead_M20')) // otherwise, spawn 
				{
					if (player.inhand != none && player.inhand.isA( 'tnmpovcorpse' ) && tnmpovcorpse(player.inhand).givenbindname == "Slicer")
					{
					}
					else
						foreach allactors(class'TNMPawn',p,'SlicerHolocom')
							p.EnterWorld();
				}
			}
			flags.SetBool('MS_SlumEnemiesSpawned', True,, 23);
			if (Trestkon(player).ATMAccountManager != None)
			{
				// ATMAccountManager.UserList[0].balance=500; // Player's account
				Trestkon(player).ATMAccountManager.UserList[1].balance+=260*FRand();
				Trestkon(player).ATMAccountManager.UserList[2].balance+=140*FRand();
				Trestkon(player).ATMAccountManager.UserList[3].balance+=75*FRand();
				Trestkon(player).ATMAccountManager.UserList[4].balance+=410*FRand();
				Trestkon(player).ATMAccountManager.UserList[5].balance+=280*FRand();
				Trestkon(player).ATMAccountManager.UserList[6].balance+=100*FRand();
				Trestkon(player).ATMAccountManager.UserList[7].balance+=235*FRand();
				Trestkon(player).ATMAccountManager.UserList[8].balance+=220*FRand();
			}
		}

		// Re-add the Bugging quest (secondary goals are auto-deleted between missions)
		if (flags.GetBool('QC_SUB_Bugging') && !flags.GetBool('PJ_Dead') && !flags.GetBool('PJ_Unconscious') && !flags.GetBool('MS_BuggingUpdated'))
		{
			AddGoal('Bugging', strBuggedGoal, FALSE, FALSE);
			SendPM("PM_PJ_Reward");
			flags.SetBool('MS_BuggingUpdated',true,,23);
		}

		// Remove the holocom and the WC Thugs or Firewalls when the player is back for Kevo or Vavrek
		if (!flags.GetBool('MS_SlumEnemiesRemoved') && (flags.GetBool('QR_MAIN_FreeKevo') || flags.GetBool('QR_MAIN_KidnapKevo')))
		{
			if (!flags.GetBool('Yardbomb_AdvisedToSell') && !flags.GetBool('Yardbomb_Dead'))
			{
				foreach allactors(class'deusexmover',m, 'VoodooShopDoor')
					m.bLocked = false;
			}

			foreach allactors(class'TNMPawn',p,)
				if ((p.tag == 'KylieHolocom')||
				    (p.tag == 'ZeroHolocom')||
				    (p.tag == 'PhasmatisHolocom')||
				    (p.tag == 'SlicerHolocom'))
				{
					p.LeaveWorld();
				}

			foreach allactors(class'TNMPawn',p,'AlleyBums')
				p.EnterWorld();

			if (flags.GetBool('ALLIED_PDX'))
			{
				foreach allactors(class'TNMCarcass',c,'WCCarcass')
					c.LeaveWorld();

				foreach allactors(class'TNMPawn',p,)
					if ((p.tag == 'WCThug')||
					    (p.tag == 'WCCommando')||
					    (p.tag == 'WCKeyHolder'))
					{
						p.LeaveWorld();
					}

				foreach allactors(class'TNMRobot',r,)
					if ((r.tag == 'SecurityBot2WC') || (r.tag == 'MilitaryBotWC') || r.Tag == 'SecurityBot3WC')
						if (!r.IsInState('Disabled'))
							r.LeaveWorld();
			}
			if (flags.GetBool('ALLIED_WC'))
			{
				foreach allactors(class'TNMCarcass',c,'FireWallCarcass')
					c.LeaveWorld();

				foreach allactors(class'TNMPawn',p,)
					if ((p.tag == 'Firewall')||
					    (p.tag == 'CSISniper')||
					    (p.tag == 'PDXKeyHolder'))
					{
						p.LeaveWorld();
					}

				foreach allactors(class'TNMRobot',r)
				{
					if (r.Tag == 'SecurityBot2PDX' || r.Tag == 'SecurityBot3PDX')
						if (!r.IsInState('Disabled'))
							r.LeaveWorld();
				}
			}

			foreach allactors(class'Containers',cont,)
			{
				if ((cont.tag == 'SubwayExplosives1')||(cont.tag == 'SubwayExplosives2'))
					cont.Destroy();
			}

			flags.SetBool('MS_SlumEnemiesRemoved', True,, 23);
		}

		// Put a big ol' WC logo over the Voodoo Shop sign if the player advised Yardie to sell 
		if (flags.GetBool('Yardbomb_AdvisedToSell'))
		{
			foreach AllActors(class'DeusExMover', M, 'VoodooShopDoor')
				M.bLocked = true;

			foreach AllActors(class'DeusExMover', M, 'VoodooShopWCSign')
				OpenDoor(M);

			foreach AllActors(class'TriggerLight', l, 'VoodooShopSignLight')
				l.Destroy();
		}

		// When it is time to kidnap Kevo...
		if (flags.GetBool('QR_MAIN_KidnapKevo'))
		{
			// ...unlock the garage doors to the torture chamber
			foreach AllActors(class'DeusExMover', M, 'TortureRoomDoors')
			{
				M.bFrobbable = true;
				M.bHighlight = true;
			}

			// ...and spawn Kevo himself
			foreach allactors(class'TNMPawn',p,'Kevo')
			{
				p.EnterWorld();
				p.bEmitCarcass=false;
			}
		}

		// Change the chopper bindname and disable the keypad when you return after freeing Kevo
		if (flags.GetBool('Kevo_Free') && !flags.GetBool('Kevo_Dead') && !flags.GetBool('Kevo_Unconscious') && flags.GetBool('Kashue_MeetingDone'))	// Require going to the meeting to know where you're going
		{
			foreach allactors(Class'BlackHelicopter', H, 'ROFLCopter')
			{
				H.FamiliarName = "Kevo-sama";
				H.UnfamiliarName = "Kevo-sama";
				H.ConBindEvents();
			}

			foreach allactors(Class'Keypad', kp, 'HelipadKeypad')
			{
				kp.hackStrength=0;
				kp.bHackable=true; // Required to say "bypassed" instead of "inf"
			}
		}
		
		if (flags.GetBool('ALLIED_PDX'))
		{
			foreach allactors(class'TNMPawn',p)
			{
				if (p.Tag == 'AJ' || p.Tag == 'AJThug' || p.Tag == 'AJCommando')
					p.LeaveWorld();
			}
		}

		// If you return after killing Kevo
		if (flags.GetBool('ALLIED_PDX') && (flags.GetBool('Kevo_Dead') || flags.GetBool('Kevo_Unconscious')) && !flags.GetBool('MS_DoneKevoDeath'))
		{
			// Unlock the keypad
			foreach allactors(Class'Keypad', kp, 'HelipadKeypad')
			{
				kp.hackStrength=0;
				kp.bHackable=true; // Required to say "bypassed" instead of "inf"
			}

			// Make sure the player gets the right convo from the chopper
			foreach allactors(class'BlackHelicopter',H,'ROFLCopter')
			{
				H.Bindname = "ROFLCopter";
				H.FamiliarName = "ROFLCopter";
				H.ConBindEvents();
			}

			flags.SetBool('MS_DoneKevoDeath',true,,23);
			AddGoal('FreeThePilot', strKevoDead, false, true);
		}

		// Spawn Vavrek when you need to rescue Kevo from DXO
		if (flags.GetBool('QR_MAIN_FreeKevo'))
		{
			foreach allactors(class'TNMPawn',p,'Vavrek')
				p.EnterWorld();
		}

		// If the player returns to the slums after completing all of the ATC, remove the chopper and Midashand
		if (flags.GetBool('MS_MidasIncoming') || flags.GetBool('MS_MidasTimerStarted'))
		{
			foreach allactors(Class'BlackHelicopter',H,'ROFLCopter')
				H.LeaveWorld();

			foreach allactors(class'TNMPawn', p)
			{
				if ((p.Tag == 'Midashand') || (p.Tag == 'Midashand_Subway'))
					p.LeaveWorld();
			}
		}
		
		// Move Midashand to chopper if returning from the ATC
		if (flags.GetBool('MS_ChopperLockdownOff') && !flags.GetBool('Midashand_Dead') && !flags.GetBool('MS_MidasIncoming') && !flags.GetBool('MS_MidasTimerStarted'))
		{
			foreach allactors(class'TNMPawn', p)
			{
				if ((p.Tag == 'Midashand_Subway'))
					p.LeaveWorld();
				else if (p.Tag == 'Midashand')
					p.EnterWorld();					
			}
		}
	}
	else if (localURL == "22_WCFLOOR1")
	{
		// Make Kylie appear when the player is looking for ZP
		if (flags.GetBool('QR_SUB_FindZP'))
			foreach allactors(Class'TNMPawn',p,'Kylie')
				p.EnterWorld();

		// If the player's PDX-aligned, make Scara's secret elevator door vanish
		if (flags.GetBool('ALLIED_PDX'))
		{
			foreach allactors(Class'deusexmover',M,'ScaraElevatorSecretDoor')
			{
				M.bFrobbable = false;
				M.bHighlight = false;
			}
		}
	}
	else if (localURL == "22_WCFLOOR4")
	{
		// If the player's PDX-aligned, make Scara's office unenterable
		if (flags.GetBool('ALLIED_PDX'))
		{
			foreach allactors(Class'deusexmover',M,'Scara_Office_Door')
			{
				M.bLocked = true;
				M.bPickable = false;
			}

			foreach allactors(Class'keypad',kp,'Scara_Office_Keypad')
			{
				kp.hackstrength=1.0;
				kp.bHackable = false;
			}
		}
		else
		{
			if(!flags.GetBool('MS_ScaraSecretDoorOpened'))
			{
				foreach allactors(class'deusexmover',m,'ScaraSecretDoor')
					m.trigger(none,none);
				flags.setbool('MS_ScaraSecretDoorOpened',true,,23);
			}
		}
	}
	else if (localURL == "22_WCSUBLEVEL")
	{
		// Check if NVShacker should be there
		if (flags.GetBool('NVShacker_WC') && !flags.GetBool('MS_NVS_Placed'))
		{
			foreach AllActors(class'TNMCarcass',c,'NVShackerCarcass')
				c.EnterWorld();

			foreach AllActors(class'TNMInformationDevices',inf)
			{
				if(inf.tag=='PrisonRegistry01')
					inf.LeaveWorld();
				else if(inf.tag=='PrisonRegistry02')
					inf.EnterWorld();
			}

			foreach AllActors(class'inventory',inv,'NVSGun')
				inv.bHidden=false;

			foreach AllActors(class'DeusExMover',m,'SublevelPrisonCellDoor02')
				OpenDoor(m);

			if(flags.GetBool('NVShackerPet_NVS'))
			{
				foreach AllActors(class'TNMCarcass',c,'NVShackerPetVictim')
					c.EnterWorld();

				foreach AllActors(class'TNMRobot',r,'NVShackerPet')
					r.EnterWorld();
			}

			flags.SetBool('MS_NVS_Placed',true,,23);
		}

		// Check if the player made it past the exploding wall in M20
		if (flags.GetBool('MS_SublevelDestroyedWall'))
		{
			// Remove the dead scientist...
			foreach AllActors(class'TNMCarcass', c, 'WallExplosionCarcass')
				c.LeaveWorld();

			// ...and his notepad
			foreach allactors(class'TNMInformationDevices',inf,'WallExplosionNoteBook')
				inf.LeaveWorld();

			// Re-destroy the wall
			foreach AllActors(class'deusexmover', M)
			{
				if (M.Tag == 'BreakableWall')
					M.BlowItUp(none);
			}

			// Remove the explosives
			foreach AllActors(class'Containers', cont)
			{
				if (cont.Tag == 'CrateExplosiveMed')
					cont.Destroy();
			}

			foreach AllActors(class'TNMCarcass', c)
			{
				if (c.Tag == 'ThomasBarnes')
					c.LeaveWorld();

				else if (c.Tag == 'ThomasBarnes_Lab')
					c.EnterWorld();
			}

			// Replace the previous datacube at Thomas' cell with his file
			foreach allactors(class'TNMInformationDevices',inf,)
			{
				if (inf.Tag == 'Datacube12')
					inf.LeaveWorld();
				else if (inf.Tag == 'Datacube03')
					inf.EnterWorld();
			}
		}

		// If the player is PDX-aligned, remove ZP's datacube
		if (flags.GetBool('ALLIED_PDX'))
		{
			foreach allactors(class'TNMInformationDevices',inf,'ZPDataCube')
				inf.LeaveWorld();
		}

		// Enable the Black ICE virus upload button if the mission wasn't handled in M20
		if (flags.GetBool('QR_SUB_BlackICE') && !flags.GetBool('QC_SUB_BlackICE'))
			flags.SetBool('BlackICEVirusUploadable',true,,23);
	}
	else if (localURL == "22_GOATCITY")
	{
		// Spawn ZeroPresence when the player has received the mission to find him 
		if (flags.GetBool('QR_SUB_FindZP') && !flags.GetBool('QC_SUB_FindZP'))
			foreach allactors(class'TNMPawn',p,'ZeroPresence')
				p.EnterWorld();

		// Disable the melk fountains if the player sabotaged them in M20
		if (flags.GetBool('QC_CULT_DrainTheMelk') && !flags.GetBool('MS_GoatFountainsOff'))
		{
			foreach allactors(class'TNMDecoration', deco, )
			{
				// Destroy the valves
				if ( deco.Tag == 'MelkValve1' || deco.Tag == 'MelkValve2' )
				{
					deco.Destroy();
				}
				// Turn off the fountains
				if ( deco.Tag == 'MelkFountain1' || deco.Tag == 'MelkFountain2' )
				{
					deco.Trigger(none, none);
				}
			}

			foreach allactors(class'AmbientSoundTriggered', A, )
			{
				// Replace the rushing water sound with a water pool sound
				if ( A.Tag == 'MelkFountain1' || A.Tag == 'MelkFountain2' )
				{
					A.Trigger(none, none);
				}
			}

			flags.SetBool('MS_GoatFountainsOff',true,,23);
		}

		// If the player killed Athena in the fight room, set her normal death flag too
		if (flags.GetBool('Athena_Fight_Dead'))
			flags.SetBool('Athena_Dead',true,,0);
	}
	else if (localURL == "22_GOATTEMPLAE")
	{
		// If the player did the last quest...
		if (flags.GetBool('QC_CULT_DestroyTheTablets'))
		{
			foreach allactors(class'TNMPawn',p,)
			{
				// Spawn DT and friendly Athena in the templae
				if ((p.Tag == 'DarkTemplar') || (p.Tag == 'Athena'))
					p.EnterWorld();

				// Remove hostile Athena
				if (p.Tag == 'Athena_Fight')
					p.LeaveWorld();

				// Make the guards friendly
				if (p.Tag == 'InnerTemplaeGuards')
					p.ChangeAlly('Player', 1.0, true);

				if (p.Tag == 'TemplaeSecurityRoomGuard')
					p.ChangeAlly('Player', 1.0, true);
			}

			// Deactivate the security cameras in the inner Templae
			foreach allactors(class'securitycamera', cam, )
			{
				if ((cam.tag == 'TemplaeSecRoomCam') ||
				    (cam.tag == 'TemplaeStairsCam2') ||
				    (cam.tag == 'TemplaeStairsCam1'))
				cam.bNoAlarm = true;
			}
		}

		// If the player didn't do the last quest, spawn DT in the courtyard
		if (!flags.GetBool('QC_CULT_DestroyTheTablets'))
			foreach allactors(class'TNMPawn',p,'DarkTemplar_Courtyard')
				p.EnterWorld();
	}
	else if (localURL == "22_LLAMATEMPLE")
	{
		// Make Hobbes hostile if he was knocked out in M20
		if (flags.GetBool('Hobbes_Unconscious'))
		{
			foreach allactors(class'TNMPawn',p,'Hobbes')
				P.ChangeAlly('Player', -1.0, true);
		}
		// Cut out Abom's text about the 2nd if he died on the 1st
		if (flags.GetBool('Abomination_Dead_M20'))
		{
			foreach allactors(class'TNMInformationDevices',inf,'AbomStuff')
				inf.textTag[0]='22_Notepad08';
		}
		
		if (!flags.GetBool('MS_Beefman_Unconscious') && flags.GetBool('Beefman_Unconscious'))
		{
			SendPM("PM_Beefman_KnockoutRevenge");
			flags.SetBool('MS_Beefman_Unconscious', True,, 23);
		}
	}
	else if (localURL == "22_WEAPONSHOP")
	{
		// Handle unlocking the fireblade
		if (trestkon(player) != none)
		{
			if (trestkon(player).bunlockedSword)
			{
				flags.SetBool('UNLOCKED_FlameBlade', True,, 23);

				if (!flags.GetBool('MS_GivenFireBlade'))
				{
					foreach allactors(class'TNMPawn', p, 'Raving')
					{
						GiveItemTo("tnmitems.weaponfireblade",p);
					}
					flags.SetBool('MS_GivenFireBlade', True,, 23);
				}
			}
		}

		if (flags.GetBool('StoleFromWeaponShop'))
		{
			// Make Andreus run up to the player if you've stolen from the shop
			foreach allactors(class'TNMPawn',p,'Andreus')
				P.SetOrders('WaitingFor','');

			// Make Raving mad if you show your face after stealing from his shop
			foreach allactors(class'TNMPawn',p,'RavingNutter')
				P.ChangeAlly('Player', -1.0, true);
		}
	}
	else if (localURL == "22_VOODOOSHOP")
	{
		SetupPortal('VoodooShop1','FC_Current_Booth_Sound');
		SetupPortal('VoodooShop2','FC_Current_Booth_Sound');
		SetupPortal('VoodooShop3','FC_Current_Booth_Sound');

		// Change the lock if Yardbomb was advised to sell the shop
		if (flags.GetBool('Yardbomb_AdvisedToSell'))
		{
			foreach allactors(class'deusexmover',m, 'PortalDoor')
				m.KeyIDNeeded = 'betchadonthavethiskey';
		}

		// Make Yardbomb hostile if the player knocked him out in M20
		if (flags.GetBool('Yardbomb_Unconscious'))
		{
			foreach allactors(class'TNMPawn', p, 'Yardbomb')
				p.ChangeAlly('Player', -1.000000, true);
		}
	}
	else if (localURL == "22_ATC")
	{
		// Send a PM with a sattelite picture
		SendPM("PM_TG_EnterATC");

		// Make the car smoke inactive to begin with (WHY THE HELL DOESN'T bInActive DO ANYTHING!?)
		// Disabled because bInActive seems to have decided to work again
		// I also realized the desk was being broken by the office guy, so I made it a door :P
		/*if (!flags.GetBool('MS_DisabledCarSmoke'))
		{
			foreach AllActors(class'ParticleGenerator', S, 'BustedCar_Smoke')
				S.Trigger(Self, Player);

			// Okay this isn't exactly smoke, but I have to stop that desk from breaking on its own!!
			foreach AllActors(class'deusexmover', M, 'CarCrashDesk')
				M.bBreakable = true;

			flags.SetBool('MS_DisabledCarSmoke', True,, 23);
		}*/

		// Make the barricade couch go away for the moment
		foreach AllActors(class'CouchLeather', CL, 'Couch_LobbyBarricade2')
		{
			CL.bHidden = true;
			CL.SetCollision(false,false,false);
		}
	}
	else if (localURL == "22_PDXHQ01")
	{
		// Check if NVShacker should be there
		if (flags.GetBool('NVShacker_PDX') && !flags.GetBool('MS_NVS_Placed'))
		{
			foreach AllActors(class'TNMPawn',p,'NVShackerLobby')
				p.EnterWorld();

			if(flags.GetBool('NVShackerPet_NVS'))
				foreach AllActors(class'TNMRobot',r,'NVShackerPet')
					r.EnterWorld();

			flags.SetBool('MS_NVS_Placed',true,,23);
		}

		// Replace the old newspaper with Slicer's new article if Slicer was saved
		if (flags.GetBool('Slicer_SetFree'))
		{
			foreach AllActors(class'TNMInformationDevices',inf)
			{
				if(inf.tag=='SlicerNewspaper_Old')
					inf.LeaveWorld();
				else if(inf.tag=='SlicerNewspaper_New')
					inf.EnterWorld();
			}
			
			if (flags.GetBool('Slicer_GaveKnife') && !flags.GetBool('M22_SlicerKnifeSpawned'))
			{
				SpawnItemAt("TNMItems.WeaponTNMCombatKnife", 'SlicerKnife');
				flags.SetBool('M22_SlicerKnifeSpawned', true,, 23);
			}
		}

		if (!Flags.GetBool('Evil_Done')&&!Flags.GetBool('MS_Evil_Done_Done'))
		{
			foreach allactors( class'TNMPawn' ,p , 'Evil')
			{
				GiveItemTo("deusex.augmentationupgradecannister", p);
				GiveItemTo("deusex.BioelectricCell", p);
				GiveItemTo("deusex.BioelectricCell", p);
				GiveItemTo("deusex.BioelectricCell", p);
			}
			Flags.SetBool('MS_Evil_Done_Done', true, , 23);
		}

		if (!flags.GetBool('MS_PDXMovePostBriefing1_Done') && flags.GetBool('QR_MAIN_FreeKevo') && (LastMap() != "22_PDXHQ02"))
		{
			foreach allactors( class'TNMPawn' ,p , )
			{
				if (p.Tag == 'Evil' || p.Tag == 'Phasmatis')
					p.EnterWorld();
				if (flags.GetBool('NVShacker_PDX'))
				{
					if (p.Tag=='NVShacker')
						p.EnterWorld();
					else if (p.Tag=='NVShackerLobby')
						p.LeaveWorld();
				}
			}

			SpawnItemAt("TNM.WeaponFireStaff" , 'FirestaffSpawnPoint');
			SendPM("PM_Evil_ReturnStaff");

			Flags.SetBool('MS_PDXMovePostBriefing1_Done', true, , 23);
		}
	}
	else if (localURL == "22_PDXHQ02")
	{
		if (flags.GetBool('MS_PDXMovePostBriefing1_Done') && !flags.GetBool('MS_PDXMovePostBriefing2_Done'))
		{
			foreach allactors( class'TNMPawn' ,p , )
			{
				if (p.Tag == 'Evil' || p.Tag == 'Phasmatis')
					p.LeaveWorld();
			}
			Flags.SetBool('MS_PDXMovePostBriefing2_Done', true, , 23);
		}
		if (trestkon(player).bunlockedSword)
		{
			foreach AllActors(class'DeusExMover', M, 'NGHatch')
			{
				M.bHighlight=True;
				M.bFrobbable=True;
			}
		}
	}
	else if (localURL == "22_FCREGISTRATION")
	{
		if (!flags.GetBool('MS_RegistrationBreakableWalls'))
		{
			// Needs to be done post-level load to not reset DoorStrength.
			foreach AllActors(class'DeusExMover', M, 'TurretGenerator1')
			{
				M.bBreakable = False;
			}		
			foreach AllActors(class'DeusExMover', M, 'TurretGenerator2')
			{
				M.bBreakable = False;
			}
			
			foreach AllActors(class'DeusExMover', M, 'SpydroneSpawner1')
			{
				M.bBreakable = False;
			}		
			foreach AllActors(class'DeusExMover', M, 'SpydroneSpawner2')
			{
				M.bBreakable = False;
			}	
			Flags.SetBool('MS_RegistrationBreakableWalls', true, , 23);
		}
	}

	//handle the elevator hatch and keypad persistance
	if (left(localURL,5) == "22_WC")
	{
		if(flags.CheckFlag('WC_ElevatorHatch_Strength',flags.EFlagType.FLAG_Float))
		{
			foreach AllActors(Class'DeusExMover',m,'SublevelKeypadHatch')
			{
				m.lockstrength=flags.GetFloat('WC_ElevatorHatch_Strength');
				if(m.lockstrength==0.0)
					m.bLocked=false;

				if(flags.GetBool('WC_ElevatorHatch_Open'))
				{
					if(m.keynum==0)
					{
						//the delay lets it interpolate first then
						//properly 'move' later to do collision
						m.InterpolateTo(1,0);
						m.DelayTime=0.1;
						m.GotoState('TriggerToggle','Open');

					}
				}
				else
				{
					if(m.keynum==1)
					{
						m.InterpolateTo(0,0);
						m.DelayTime=0.1;
						m.GotoState('TriggerToggle','Close');
					}
				}
			}

			foreach AllActors(Class'Keypad',kp,'SublevelKeypad')
			{
				kp.hackstrength=flags.GetFloat('WC_ElevatorKeypad');
			}
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
	local TNMPawn p;	
	local int count;
	local deusexmover m;
	local keypad kp;
	local DeusExMover Mover;

	if (localURL == "22_DXO")
	{
		// Remove Kevo when he's released 
		if (flags.GetBool('Kevo_Free'))
			foreach allactors(class'TNMPawn',p,'Kevo')
				p.LeaveWorld();
	}
	else if (localURL == "22_FCCORPORATE")
	{
		// Remove real ZP once quest received
		if (flags.GetBool('QR_Sub_HelpRealZP'))
			foreach allactors(class'TNMPawn',p,'ZeroPresenceNormal')
				p.LeaveWorld();
	}
	else if (localURL == "22_GOATCITY")
	{
		// Remove ZeroPresence when his mission is done 
		if (flags.GetBool('QC_SUB_LureThePriest'))
			foreach allactors(class'TNMPawn',p,'ZeroPresence')
				p.LeaveWorld();
	}
	else if (localURL == "22_PDXHQ01")
	{
		foreach AllActors(class'DeusExMover', Mover)
		{
			if (Mover.Tag == 'ElevatorDoors')
			{
				Mover.InterpolateTo(0,0);  // Instantly go back to closed position
				Mover.Enable( 'Trigger' ); // Allow us to instantly reopen it.
			}
		}
	}
	else if (localURL == "22_PDXHQ02")
	{
		foreach AllActors(class'DeusExMover', Mover)
		{
			if (Mover.Tag == 'ElevatorDoors')
			{
				Mover.InterpolateTo(0,0);  // Instantly go back to closed position
				Mover.Enable( 'Trigger' ); // Allow us to instantly reopen it.
			}
		}
	}
	else if (localURL == "22_WCFLOOR1")
	{
		foreach AllActors(class'DeusExMover', Mover)
		{
			if (Mover.Tag == 'PElevator_Doors0' || Mover.Tag == 'elevator_door')
			{
				Mover.InterpolateTo(0,0);  // Instantly go back to closed position
				Mover.Enable( 'Trigger' ); // Allow us to instantly reopen it.
			}
		}
	}
	else if (localURL == "22_WCFLOOR2")
	{
		foreach AllActors(class'DeusExMover', Mover)
		{
			if (Mover.Tag == 'elevator_door')
			{
				Mover.InterpolateTo(0,0);  // Instantly go back to closed position
				Mover.Enable( 'Trigger' ); // Allow us to instantly reopen it.
			}
		}
	}
	else if (localURL == "22_WCFLOOR3")
	{
		foreach AllActors(class'DeusExMover', Mover)
		{
			if (Mover.Tag == 'elevator_door')
			{
				Mover.InterpolateTo(0,0);  // Instantly go back to closed position
				Mover.Enable( 'Trigger' ); // Allow us to instantly reopen it.
			}
		}
	}
	else if (localURL == "22_WCFLOOR4")
	{
		foreach AllActors(class'DeusExMover', Mover)
		{
			if (Mover.Tag == 'elevator_door')
			{
				Mover.InterpolateTo(0,0);  // Instantly go back to closed position
				Mover.Enable( 'Trigger' ); // Allow us to instantly reopen it.
			}
		}
	}
	else if (localURL == "22_WCSUBLEVEL")
	{
		foreach AllActors(class'DeusExMover', Mover)
		{
			if (Mover.Tag == 'elevator_door')
			{
				Mover.InterpolateTo(0,0);  // Instantly go back to closed position
				Mover.Enable( 'Trigger' ); // Allow us to instantly reopen it.
			}
		}
	}

	//handle the elevator hatch and keypad persistance
	if (left(localURL,5) == "22_WC")
	{
		foreach AllActors(Class'DeusExMover',m,'SublevelKeypadHatch')
		{
			flags.SetFloat('WC_ElevatorHatch_Strength',m.lockstrength,,23);
			flags.SetBool('WC_ElevatorHatch_Open',m.keynum==1,,23);
		}

		foreach AllActors(Class'Keypad',kp,'SublevelKeypad')
			flags.SetFloat('WC_ElevatorKeypad',kp.hackstrength,,23);
	}


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
	local pawn pawn;
	local TNMPawn p;
	local TNMRobot r;
	local TNMCarcass c;
	local deusexmover M;
	local BlackHelicopter B;
	local Vehicles V;
	local Dispatcher D;
	local bool bDoTorture;
	local AmbientSoundTriggered S;
	local Containers Con;
	local actor a;
	local datavaultimage image;
	local securitycamera cam;
	local MapExit exit;
	local SpawnPoint SP, SP2;
	local ScriptedPawn ScriptedP;
	local int i, j;
	local SphereEffect sphere;
	local ElectricityEmitter elec;
	local Vector loc;
	local inventory inv;
	local inventory UCSpawnee;
	local decoration aCrate;

	Super.timer();
		
	// Moved out as unconscious Beefman can be dragged out of the temple
	// Award skillpoints if Beefman is killed as part of the mission
	if (flags.GetBool('Beefman_Dead') && flags.GetBool('QR_CULT_KillBeefman') && !flags.GetBool('QC_CULT_KillBeefman'))
	{
		SkillAward(750, strAssassinAward);
		AddGoal('KillBeefman', "You have assassinated Beefman. Return to the Goats to claim your reward.", FALSE, FALSE);
		flags.SetBool('QC_CULT_KillBeefman',true,,0);
	}
	//Close the Kill Athena goal when killing Beefman.
	if ((flags.GetBool('Beefman_Dead') || flags.GetBool('Beefman_Unconscious')) && flags.GetBool('ALLIED_CULT_LLAMA') && !flags.GetBool('QC_CULT_KillAthena') && !flags.GetBool('MS_AthenaGoalClose'))
	{
		if (flags.GetBool('QR_CULT_KillAthena'))
		{
			if (flags.GetBool('Beefman_Dead'))
			{
				AddGoal('KillAthena', strBeefmanDead1, false, true);
				flags.SetBool('MS_AthenaGoalClose', TRUE, ,23);
			}
			else
			{
				AddGoal('KillAthena', strBeefmanKnockedOut1, false, true);
				flags.SetBool('MS_AthenaGoalClose', TRUE, ,23);
			}
		}
		else
		{
			if (flags.GetBool('Beefman_Dead'))
			{
				AddGoal('KillAthena', strBeefmanDead2, false, true);
				flags.SetBool('MS_AthenaGoalClose', TRUE, ,23);
			}
			else
			{
				AddGoal('KillAthena', strBeefmanKnockedOut2, false, true);
				flags.SetBool('MS_AthenaGoalClose', TRUE, ,23);
			}
		}
	}

	if (localURL == "22_FCDOWNTOWN")
	{
		if (!flags.GetBool('MS_achFanFic2') && flags.GetBool('Chris_Menu_Priory_Played') && flags.GetBool('WaltonSimons_Greeting_Played'))
		{
			Trestkon(player).SetAchievement("achFanFic2");
			flags.SetBool('MS_achFanFic2', True,, 24);
		}
		
		// Handle the completion of the Sol quest 
		if(!flags.GetBool('QC_SUB_KillBombers') && !flags.GetBool('ALLIED_WC'))
		{
			count = 0;
			foreach allactors(class'TNMPawn',p,'SolBomber')
				count++;

			if (count == 0)
			{
				flags.SetBool('QC_SUB_KillBombers', TRUE, ,0);  

				// Update the goal
				if(flags.GetBool('QR_SUB_KillBombers') && !flags.GetBool('AlphaOperator_Dead') && !flags.GetBool('AlphaOperator_Unconscious'))
				{
					AddGoal('SolBombing', strBombersGoal, false, false);
					SkillAward(500, strAYBABTUAward);
				}
				else if(flags.GetBool('SolBombers_Played') && !flags.GetBool('AlphaOperator_Dead') && !flags.GetBool('AlphaOperator_Unconscious'))
				{
					AddGoal('SolBombing', strMysteryGoal, false, false);
					SkillAward(500, strAYBABTUAward);
				}
				else if(!flags.GetBool('ALLIED_WC') && !flags.GetBool('AlphaOperator_Dead') && !flags.GetBool('AlphaOperator_Unconscious'))
				{
					AddGoal('SolBombing', strMysteryGoal2, false, false);
					SkillAward(500, strAYBABTUAward);
				}
				Trestkon(player).SetAchievement("achSolsBombers");
			}
		}

		// Close PJ's goals if you take him out
		if((flags.GetBool('PJ_Dead') || flags.GetBool('PJ_Unconscious')) && !flags.GetBool('PJ_GaveReward'))
		{
			AddGoal('Bugging', strPJDead, false, true);
			flags.SetBool('PJ_GaveReward', TRUE, ,23);
		}

		// 
		if((flags.GetBool('PJ_Dead') || flags.GetBool('PJ_Unconscious')) && !flags.GetBool('MSPJ_Dead') && !flags.GetBool('PJ_Dead_Early'))
		{
			Trestkon(player).SetAchievement("achPimpJojo");
			flags.SetBool('MSPJ_Dead', TRUE, ,23);			
		}
		
		//Close the Sol quest again if you knock down or kill AO
		if ((flags.GetBool('AlphaOperator_Dead') || flags.GetBool('AlphaOperator_Unconscious')) && flags.GetBool('ALLIED_PDX') && (flags.GetBool('QC_SUB_KillBombers') || flags.GetBool('QR_SUB_KillBombers')) && !flags.GetBool('MS_AlphaGoalClose'))
		{
			if (flags.GetBool('QR_SUB_KillBombers') && flags.GetBool('QC_SUB_KillBombers'))
			{
				if (flags.GetBool('AlphaOperator_Dead'))
				{
					AddGoal('SolBombing', strAlphaDead, false, true);
					flags.SetBool('MS_AlphaGoalClose', TRUE, ,23);
				}
				else
				{
					AddGoal('SolBombing', strBombersDead, false, true);
					flags.SetBool('MS_AlphaGoalClose', TRUE, ,23);
				}
			}
			else if (flags.GetBool('QR_SUB_KillBombers') && !flags.GetBool('QC_SUB_KillBombers'))
			{
				if (flags.GetBool('AlphaOperator_Dead'))
				{
					AddGoal('SolBombing', strAlphaDead2, false, true);
					flags.SetBool('MS_AlphaGoalClose', TRUE, ,23);
				}
				else
				{
					AddGoal('SolBombing', strBombersDead2, false, true);
					flags.SetBool('MS_AlphaGoalClose', TRUE, ,23);
				}
			}
			else
			{
				if (flags.GetBool('AlphaOperator_Dead'))
				{
					AddGoal('SolBombing', strAlphaDead3, false, true);
					flags.SetBool('MS_AlphaGoalClose', TRUE, ,23);
				}
				else
				{
					AddGoal('SolBombing', strAlphaUnconscious, false, true);
					flags.SetBool('MS_AlphaGoalClose', TRUE, ,23);
				}
			}
		}
	}
	else if (localURL == "22_SOLSBAR")
	{
		//Close Winqumans interview goal if you take him down before completing it.
		if ((flags.GetBool('Winquman_Dead') || flags.GetBool('Winquman_Unconscious')) && flags.GetBool('Winquman2_Played') && !flags.GetBool('Winquman3_Played') && !flags.GetBool('MS_WinqumanGoalClose'))
		{
			if (flags.GetBool('Winquman_Dead'))
			{
				AddGoal('QuestionWitnesses', strWinqumanDead, false, true);
				flags.SetBool('MS_WinqumanGoalClose', TRUE, ,23);
			}
			else
			{
				AddGoal('QuestionWitnesses', strWinqumanUnconscious, false, true);
				flags.SetBool('MS_WinqumanGoalClose', TRUE, ,23);
			}
		}
		
		if (flags.GetBool('AlphaOperator_Unconscious_M20') && flags.GetBool('Jackie_Unconscious_M20') && flags.GetBool('Winquman1_Played') && !flags.GetBool('MS_Winquman1_Played'))
		{
			Trestkon(Player).SetAchievement("achSolsBombBoth");
			flags.SetBool('MS_Winquman1_Played',true,,23);
		}
	}
	else if (localURL == "22_FCCORPORATE")
	{
		// Close Wolfy's side mission if you kill or knock him out
		if (!flags.GetBool('Wolfy_GaveReward') && !flags.GetBool('Wolfy_KilledGuard') && (flags.GetBool('Wolfy_Dead') || flags.GetBool('Wolfy_Unconscious')) && !flags.GetBool('MS_ClosedWolfyMission'))
		{
			if(flags.GetBool('QR_SUB_DXEditing'))
			{
				AddGoal('DXEditing', strWolfyDead, false, true);
				flags.SetBool('MS_ClosedWolfyMission', TRUE, ,23);
			}
			else
			{
				AddGoal('DXEditing', strWolfyDeadEarly, false, true);
				flags.SetBool('MS_ClosedWolfyMission', TRUE, ,23);
			}
		}
		
		
		if ((flags.GetBool('ZeroReal_Dead') || flags.GetBool('ZeroReal_Unconscious')) && !flags.GetBool('MS_ZPGoalRemoved'))
		{
			if (player != none)
			{
				// player.GoalCompleted('HelpRealZP');
				AddGoal('HelpRealZP', strRealZPQuest, false, true);
				flags.SetBool('MS_ZPGoalRemoved',true,,0);
			}
		}
	}
	else if (localURL == "22_FCSLUMS")
	{
		// Remove Midashand if he's about to take off
		if (flags.GetBool('Midas_TakingOff'))
		{			
			Trestkon(Player).SetAchievement("achATCNoLZ");
			foreach allactors(class'TNMPawn',p,'Midashand')
				p.LeaveWorld();
		}
				
		// foreach allactors(class'MapExit',exit,)
			// if (exit.DestMap ~= "23_ABIExterior")
				// exit.DestMap = "23_ABIApproach";

		// Set some flags if the player gets any hostages killed
		count = 0;
		foreach allactors(class'TNMPawn',p,)
			if (p.Tag == 'Hostage1' || p.Tag == 'Hostage2' || p.Tag == 'Hostage3')
				count++;
		foreach allactors(class'TNMCarcass',c)
			if ((c.Tag == 'Hostage1' || c.Tag == 'Hostage2' || c.Tag == 'Hostage3') && c.bNotDead)
				count++;

		if (count == 0)
			flags.SetBool('Slums_AllHostagesDead', TRUE, ,23);
		else if (count < 3)
			flags.SetBool('Slums_SomeHostagesDead', TRUE, ,23);

		// If the player frags Madmax and Fender
		if ((flags.GetBool('Fender2k1_Dead') || flags.GetBool('Fender2k1_Unconscious')) &&
		    (flags.GetBool('Madmax_Dead') || flags.GetBool('Madmax_Unconscious')))
		{
			SendPM("PM_KillDXO");
		}
		
		if (flags.GetBool('PM_KillDXO_Played') && !flags.GetBool('MS_PM_KillDXO_Played'))
		{
			if (flags.GetBool('Slums_AllHostagesDead'))
				Trestkon(Player).SetAchievement("achHostageVeryLethal");
			else
				Trestkon(Player).SetAchievement("achHostageLethal");
			flags.SetBool('MS_PM_KillDXO_Played',true,,23);
		}
		
		if (flags.GetBool('PM_Fender_Leaving_Played') && !flags.GetBool('MS_PM_Fender_Leaving_Played'))
		{
			Trestkon(Player).SetAchievement("achHostagePeaceful");
			flags.SetBool('PM_Fender_Leaving_Played',true,,23);
		}

		// When the player restores power to the subway...
		if (flags.GetBool('QC_SUB_SubwayPower') && !flags.GetBool('MS_SubwayCleared'))
		{
			// Delete some of the subway explosives unless both Fender and Madmax are dead or unconscious
			if (!(flags.GetBool('Fender2k1_Dead') || flags.GetBool('Fender2k1_Unconscious')) ||
			    !(flags.GetBool('Madmax_Dead') || flags.GetBool('Madmax_Unconscious')))
			{
				foreach allactors(class'Containers',Con,'SubwayExplosives1')
					Con.Destroy();
			}

			foreach allactors(class'TNMPawn',p,)
			{
				// ...remove Fender2k1 and Madmax
				if (p.Tag == 'Fender2k1' || p.Tag == 'Madmax')
					p.LeaveWorld();

				// ...and move the hostages up into the streets
				// Removed for apparently causing crashes
//				if (p.Tag == 'Hostage1')
//				{
//					p.OrderTag='Hostage1Point';
//					TeleportPawn(p, 'Hostage1Point', 'Patrolling',false,true);
//				}
//				else if (p.Tag == 'Hostage2')
//				{
//					p.OrderTag='Hostage2Point';
//					TeleportPawn(p, 'Hostage2Point', 'Patrolling',false,true);
//				}
//				else if (p.Tag == 'Hostage3')
//				{
//					p.OrderTag='Hostage3Point';
//					TeleportPawn(p, 'Hostage3Point', 'Patrolling',false,true);
//				}
			}
	
			if (!flags.GetBool('Negotiations_Played'))
				Trestkon(Player).SetAchievement("achHostageNotMet");
			flags.SetBool('MS_SubwayCleared',true,,23);
			SendPM("PM_SubwayPowerRestored");
		}

		if (flags.GetBool('Kevo_PlacedOnSlab') && !flags.GetBool('MS_KevoInvincible'))
		{
			foreach AllActors( Class<TNMCarcass>(DynamicLoadObject("TNMCharacters.KevoCarcass", Class'Class')), a)
			{
				TNMCarcass(a).bInvincible = true;
			}

			flags.SetBool('MS_KevoInvincible', TRUE, ,23);
		}

		if (flags.GetBool('AJ_Ready'))
		{
			bDoTorture=true;
			foreach AllActors(class'Pawn', pawn)
			{
				// Run the torture sequence when AJ is the only remaining pawn in the room
				if(pawn.Tag != 'AJ' && pawn.Region.Zone.Tag=='TortureRoom')
				{
					bDoTorture=false;
					break;
				}
			}
			if(bDoTorture)
			{
				// Close the doors
				SealDoor('TortureRoomDoors');

				// Initiate torture sequence by means of a dispatcher
				foreach AllActors(class'Dispatcher', D, 'TortureSequenceDispatcher')
					D.Trigger(Self, Player);

				// Make sure this only happens once
				flags.SetBool('AJ_Ready', false);
			}
		}

		// Send directions when the player knocks out Kevo
		if (flags.GetBool('QR_MAIN_KidnapKevo') && flags.GetBool('Kevo_Unconscious'))
			SendPM("PM_TG_KnockedOutKevo");

		// Award some skillpoints for getting the necessary information out of Kevo
		if (flags.GetBool('QC_MAIN_KidnapKevo') && !flags.GetBool('MS_KidnapKevo_AwardGiven'))
		{
			SkillAward(250, strMarathonAward);
			flags.SetBool('MS_KidnapKevo_AwardGiven',true,,23);
		}

		// Handle "Plan B" when the player foolishly kills Kevo-sama or AJ
		if (flags.GetBool('QR_MAIN_KidnapKevo') && !flags.GetBool('MS_PreparedDemolition'))
		{
			if (flags.GetBool('Kevo_Dead') && !flags.GetBool('AJ_TortureDone'))
			{
				// Close the doors to the torture chamber again
				// TODO: Make sure the player isn't actually in there...
				SealDoor('TortureRoomDoors');

				// Send the player a PM to tell him the demo crew is inbound
				SendPM("PM_TG_KilledKevo");

				// Spawn the demo guys (their orders make them move)
				foreach allactors(class'TNMPawn',p,'DemolitionMan')
					p.EnterWorld();
				foreach allactors(class'TNMPawn',p,'DemolitionSquad')
					p.EnterWorld();

				// Make the gate destructible
				foreach AllActors(class'DeusExMover', M, 'HelipadGate')
					M.bBreakable = true;

				flags.SetBool('MS_PreparedDemolition',true,,23);
				Trestkon(Player).SetAchievement("achKevoKill");
			}
			else if ((flags.GetBool('AJ_Dead') || flags.GetBool('AJ_Unconscious')) && flags.GetBool('AJ_TortureDone'))
			{
				// Send the player a PM to tell him he's a prick
				SendPM("PM_TG_KilledAJPostTorture");
			}
			else if (flags.GetBool('AJ_Dead') || flags.GetBool('AJ_Unconscious'))
			{
				// Send the player a PM to tell him the demo crew is inbound
				SendPM("PM_TG_KilledAJ");

				// Spawn the demo guys (their orders make them move)
				foreach allactors(class'TNMPawn',p,'DemolitionMan')
					p.EnterWorld();
				foreach allactors(class'TNMPawn',p,'DemolitionSquad')
					p.EnterWorld();

				// Make the gate destructible
				foreach AllActors(class'DeusExMover', M, 'HelipadGate')
					M.bBreakable = true;

				flags.SetBool('MS_PreparedDemolition',true,,23);
			}
		}

		// Spawn the attacking Firewalls when the gate has been blown up
		if (flags.GetBool('MS_PreparedDemolition') && !flags.GetBool('MS_SpawnedDemoInterceptors'))
		{
			// We're checking if it's gone so all this'll happen if the player blows it too
			foreach allactors(class'DeusExMover',M,'HelipadGate')
				if (M.bDestroyed)
				{
					foreach allactors(class'TNMPawn',p,'DemolitionInterceptors')
						p.EnterWorld();

					AddGoal('KidnapKevo', strSurviveGoal, true, false);

					flags.SetBool('MS_SpawnedDemoInterceptors',true,,23);
				}
		}

		// Spawn Midashand in the subway once the attacking firewalls are gone
		if (flags.GetBool('MS_SpawnedDemoInterceptors') && !(flags.GetBool('MS_MidasIncoming') || flags.GetBool('MS_ChopperLockdownOff') || flags.GetBool('MS_MidasTimerStarted')))
		{
			count = 0;
			foreach allactors(class'TNMPawn',p,'DemolitionInterceptors')
				count++;

			if (count == 0)
			{
				foreach allactors(class'TNMPawn',p,'Midashand_Subway')
					p.EnterWorld();

				SendPM("PM_TG_InterceptorsGone");
			}
		}

		// Spawn Midashand when the player gets the info out of Kevo
		if (flags.GetBool('QC_MAIN_KidnapKevo') && !(flags.GetBool('MS_MidasIncoming') || flags.GetBool('MS_MidasTimerStarted')) && !flags.GetBool('Midas_TakingOff'))
			foreach allactors(class'TNMPawn',p,'Midashand')
				p.EnterWorld();

		// Scold the player if he kills the demolition man and tell the fucker he can do it himself then
		if (flags.GetBool('DemolitionMan_Dead') && !flags.GetBool('MS_SpawnedDemoInterceptors') && !flags.GetBool('MS_DemoMan_Dead'))
		{
			SendPM("PM_TG_KilledDemoMan");
			// Spawn a LAM so the player will always have something to blow up the gate with
			SpawnItemAt("DeusEx.WeaponLAM" , 'LAMSpawnPoint');
			flags.SetBool('MS_DemoMan_Dead',true,,23);
			Trestkon(Player).SetAchievement("achSolo");
		}

		if (flags.GetBool('Midashand_Dead') && !flags.GetBool('MS_DoneMidasDeath'))
		{
			// Tell the player to fly his own damn helicopter if he kills Midas
			SendPM("PM_TG_KilledMidas");

			// Then make sure he gets the right convo if he triggers it
			foreach allactors(class'BlackHelicopter',B,'ROFLCopter')
			{
				B.Bindname = "ROFLCopter";
				B.FamiliarName = "ROFLCopter";
				B.ConBindEvents();
			}
			foreach AllActors(class'DeusExMover', M, 'ATCSewers')
				M.bLocked = false;

			flags.SetBool('MS_DoneMidasDeath',true,,23);
			Trestkon(Player).SetAchievement("achPilot");
		}

		// Update the player's goal if Vavrek dies
		if (flags.GetBool('Vavrek_Dead') && !flags.GetBool('Vavrek_TOLD_Kidnapping') && !flags.GetBool('MS_VavrekDeadGoalUpdated'))
		{
			AddGoal('FreeThePilot', strVavrekDead, false, false);
			flags.SetBool('MS_VavrekDeadGoalUpdated',true,,23);
		}

		// Update the player's goal further when the player finds Vavrek's note
		if ( !flags.GetBool('Vavrek_TOLD_Kidnapping') )
		{
			image = player.FirstImage;
			while(image != None)
			{
				if (image.IsA('TNMDV_NoteVavrek'))
				{
					flags.SetBool('Vavrek_TOLD_Kidnapping',true,,23);
					AddGoal( 'FreeThePilot', strVavrekRobbed , false, false);
				}
				image = image.NextImage;
			}			
		}

		// Autosave at the start of the mission
		if (!flags.GetBool('Autosaved_Day2'))
		{
			trestkon(getplayerpawn()).autosave(true, 22);
			// if (trestkon(getplayerpawn()).autosave(true))
				// flags.SetBool('Autosaved_Day2',true,,23);
		}
	}
	else if (localURL == "22_WCFLOOR1")
	{
		// Send an angry PM from Scara if the player kills Kylie
		if (flags.getbool('ALLIED_WC') && flags.getbool('Kylie_Dead') && !flags.getbool('Kylie_Dead_M20') && !flags.getbool('Scara_TOLD_KylieKill'))
			SendPM("PM_Scara_KilledKylie");
	}
	else if (localURL == "22_ATC")
	{
		LobbyGuards();
				
		// foreach allactors(class'MapExit',exit,)
			// if (exit.DestMap ~= "23_ABIExterior")
				// exit.DestMap = "23_ABIApproach";

		// Check if all the guards who would investigate the car crash are still alive
		count = 0;
		foreach allactors(class'TNMPawn',p,)
			if (p.Tag == 'ATCGuardAlert1' || p.Tag == 'ATCGuardAlert2' || p.Tag == 'ATCGuardAlert3' || p.Tag == 'ATCGuardAlert4')
				count++;

		if (count == 0)
		{
			// If they're all dead, prevent That Guy from warning the player after the crash
			flags.SetBool('ATC_AlertGuardsDead',true,,23);
		}

		// Make all the guards neutral if the player picks up the ID card 
		if (flags.GetBool('HAS_ATCIDCard') && !flags.GetBool('MS_DoneID') && !flags.GetBool('MS_MoveLobbyGuards'))
		{
			SendPM("PM_TG_GotID");

			foreach allactors(class'TNMPawn',p,)
				if (p.Tag == 'ATCGuard' || p.Tag == 'ATCGuardAlert1' || p.Tag == 'ATCGuardAlert2' || p.Tag == 'ATCGuardAlert3' || p.Tag == 'ATCGuardAlert4' || p.Tag == 'ShackGuard')
					p.ChangeAlly('Player',0.000000,false);
			foreach allactors(class'TNMRobot',r,'ATCBot')
				r.ChangeAlly('Player',0.000000,false);
			foreach allactors(class'securitycamera', cam, )
				cam.memoryTime=0.0;

			flags.SetBool('MS_DoneID',true,,23);
		}

		// Check how many guards are left alive
		count = 0;
		foreach allactors(class'TNMPawn',p,)
			if (p.Tag == 'ATCGuard' || p.Tag == 'ATCGuardAlert1' || p.Tag == 'ATCGuardAlert2' || p.Tag == 'ATCGuardAlert3' || p.Tag == 'ATCGuardAlert4' || p.Tag == 'ShackGuard')
				count++;

		// Only count robots who aren't disabled
		foreach allactors(class'TNMRobot',r,'ATCBot')
			if (!r.IsInState('Disabled'))
				count++;

		// Only do the following is Midashand is NOT dead!
		if (!flags.GetBool('Midashand_Dead'))
		{
			// Complete the Clear LZ goal if the player neutralizes everybody before lifting the lockdown
			if ((count == 0) && !flags.GetBool('MS_ChopperLockdownOff'))
				SendPM("PM_Midas_ClearedLZ");

			// Once the lockdown is off, call upon Midas depending on whether any enemies remain
			if (flags.GetBool('MS_ChopperLockdownOff') && !flags.GetBool('MS_MidasWaiting') && !flags.GetBool('MS_MidasIncoming') && !flags.GetBool('MS_MidasTimerStarted'))
			{
				if (count == 0)
				{
					// Award some skillpoints for completing the mission
					SkillAward(750, strAirControlAward);

					SendPM("PM_Midas_LockOff_LZClear");

					// 30 second delay for added realism
					AddTimer('TimerStarted_SpawnMidasChopper','Timer_SpawnMidasChopper', 30);

					flags.SetBool('MS_MidasTimerStarted',true,,23);
				}
				else
				{
					SendPM("PM_Midas_LockOff_LZHot");
					flags.SetBool('MS_MidasWaiting',true,,23);
				}
			}

			// If the lockdown is off, call Midas in when the player neutralizes the last guard
			if (flags.GetBool('MS_ChopperLockdownOff') && flags.GetBool('MS_MidasWaiting') && !flags.GetBool('MS_MidasIncoming'))
			{
				if (count == 0)
				{
					// Award some skillpoints for completing the mission
					SkillAward(750, strAirControlAward);

					SendPM("PM_Midas_TouchingDown");

					// Make the chopper appear
					foreach allactors(class'Vehicles',V,'BlackHelicopter01')
						V.EnterWorld();

					// Begin the interpolation
					foreach AllActors(class'Dispatcher', D, 'LandingDispatcher')
						D.Trigger(Self, Player);

					flags.SetBool('MS_MidasIncoming',true,,23);
				}
			}
		}
		else // If Midashand IS dead, do this instead:
		{
			// Inform the player what a giant murderous psychopath he is (since we were counting anyway)
			if (count == 0)
				SendPM("PM_TG_ATCKilledEveryone");

			// Once the lockdown is off, tell the player to go back to the chopper
			if (flags.GetBool('MS_ChopperLockdownOff') && flags.GetBool('Midashand_Dead'))
				SendPM("PM_TG_LockOff");
		}
	}
	else if (localURL == "22_DXEDITING")
	{
		// Award some skillpoints when the player picks up the sheep poster
		if (PlayerHasItem('PosterTube') && !flags.GetBool('MS_SheepPoster_AwardGiven') &&
		    !flags.GetBool('Wolfy_KilledGuard') && !flags.GetBool('Wolfy_Dead') && !flags.GetBool('Wolfy_Unconscious'))
		{
			SkillAward(250, strPosterAward);
			flags.SetBool('MS_SheepPoster_AwardGiven',true,,23);
			Trestkon(player).SetAchievement("achDXE");
		}

		// Abort the mission if the player kills somebody 
		if (Killed() > 0)
			SendPM("PM_Wolfy_KilledGuard");
	}
	else if (localURL == "22_GOATCITY")
	{
		// Close the relevant goals if the player kills ZP
		if (flags.GetBool('Zero_Dead') && !flags.GetBool('MS_FindZP_Closed') && !flags.GetBool('ALLIED_PDX'))
		{
			if (flags.GetBool('MS_FindZP_AwardGiven'))
			{
				AddGoal('FindZP', strZPDeadPostAward, FALSE, TRUE);
			}
			else
			{
				AddGoal('FindZP', strZPDeadPreAward, FALSE, TRUE);
			}

			flags.SetBool('MS_FindZP_Closed',true,,23);
		}

		// Close the relevant goals if the player knocks out ZP
		if (flags.GetBool('Zero_Unconscious') && !flags.GetBool('MS_FindZP_Closed') && !flags.GetBool('ALLIED_PDX'))
		{
			if (flags.GetBool('MS_FindZP_AwardGiven'))
			{
				AddGoal('FindZP', strZPUnconPostAward, FALSE, TRUE);
			}
			else
			{
				AddGoal('FindZP', strZPUnconPreAward, FALSE, TRUE);
			}

			flags.SetBool('MS_FindZP_Closed',true,,23);
		}

		// Award skillpoints if ZP agrees to report back to Scara
		if (flags.GetBool('QC_SUB_LureThePriest') && !flags.GetBool('MS_FindZP_AwardGiven'))
		{
			SkillAward(300, strMessengerAward);
			flags.SetBool('MS_FindZP_AwardGiven',true,,23);
		}

		// Send a debriefing PM from Scara when ZP has agreed to return
		if (flags.GetBool('QC_SUB_FindZP'))
			SendPM("PM_Scara_FoundZP");
	}
	else if (localURL == "22_GOATTEMPLAE")
	{
		// Award skillpoints if Athena is killed as part of the mission
		if (flags.GetBool('Athena_Fight_Dead') && flags.GetBool('QR_CULT_KillAthena') && flags.GetBool('MS_MelkShutOff') && !flags.GetBool('QC_CULT_KillAthena'))
		{
			SkillAward(750, strAssassinAward);
			AddGoal('KillAthena', strAthenaDead, FALSE, FALSE);
			flags.SetBool('QC_CULT_KillAthena',true,,0);
		}
		//Close the Kill Beefman goal when killing Dark Templar.
		if ((flags.GetBool('DarkTemplar_Dead') || flags.GetBool('DarkTemplar_Unconscious')) && flags.GetBool('ALLIED_CULT_GOAT') && !flags.GetBool('QC_CULT_KillBeefman') && !flags.GetBool('MS_BeefmanGoalClose'))
		{
			if (flags.GetBool('QR_CULT_KillBeefman'))
			{
				if (flags.GetBool('DarkTemplar_Dead'))
				{
					AddGoal('KillBeefman', strTemplarDead1, false, true);
					flags.SetBool('MS_BeefmanGoalClose', TRUE, ,23);
				}
				else
				{
					AddGoal('KillBeefman', strTemplarKnockedOut1, false, true);
					flags.SetBool('MS_BeefmanGoalClose', TRUE, ,23);
				}
			}
			else
			{
				if (flags.GetBool('DarkTemplar_Dead'))
				{
					AddGoal('KillBeefman', strTemplarDead2, false, true);
					flags.SetBool('MS_BeefmanGoalClose', TRUE, ,23);
				}
				else
				{
					AddGoal('KillBeefman', strTemplarKnockedOut2, false, true);
					flags.SetBool('MS_BeefmanGoalClose', TRUE, ,23);
				}
			}
		}
		
		if (flags.GetBool('DTHologram_Played') && !flags.GetBool('MS_DTHologram_Played'))
		{
			Trestkon(Player).SetAchievement("achAthenaRoom");
			flags.SetBool('MS_DTHologram_Played',true,,23);
		}
	}
	else if (localURL == "22_DXO")
	{
		// If anybody dies, make everybody hostile (it's sort of cheating, but so be it)
		if (flags.GetBool('TRM_Dead')||flags.GetBool('Compudoc_Dead')||flags.GetBool('Illuminati_Dead')||flags.GetBool('Mole_Dead'))
		{
			foreach AllActors(class'TNMPawn',p,)
			{
				if((p.Tag == 'TRM')||(p.Tag == 'Compudoc')||(p.Tag == 'Illuminati')||(p.Tag == 'Mole'))
					p.ChangeAlly('Player', -1.000000, true);
			}
		}

		// Update the goal if the player kills TRM
		if (!flags.GetBool('ALLIED_WC') && flags.GetBool('TRM_Dead') && !flags.GetBool('Kevo_Free') && !flags.GetBool('MS_TRMDeathGoalUpdated'))
		{
			AddGoal('FreeThePilot', strTRMDead, false, false);
			flags.SetBool('MS_TRMDeathGoalUpdated',true,,23);
		}

		// Award skillpoints for freeing Kevo
		if (flags.GetBool('Kevo_Free') && !flags.GetBool('MS_FreeThePilot_AwardGiven'))
		{
			SkillAward(1000, strRescueAward);
			flags.SetBool('MS_FreeThePilot_AwardGiven',true,,23);
		}

		// Send a PM if the player stupidly kills or knocks out Kevo-sama
		if (!flags.GetBool('ALLIED_WC') && flags.GetBool('Kevo_Dead') || flags.GetBool('Kevo_Unconscious'))
		{
			SendPM("PM_Evil_KillKevo");
			
			if (flags.GetBool('Kevo_Dead'))
				Trestkon(Player).SetAchievement("achKevoKill");
		}

		// Send a new PM when the player picks up the autopilot codes
		if ( !flags.GetBool('MS_AutopilotCodes_Done') )
		{
			image = player.FirstImage;
			while(image != None)
			{
				if (image.IsA('TNMDV_AutopilotCodes'))
				{
					flags.SetBool('MS_AutopilotCodes_Done',true,,23);
					flags.SetBool('TrestkonFlying',true,,24);
					SendPM("PM_Evil_GotAutoPilotCodes");
					Trestkon(Player).SetAchievement("achPilot");
				}
				image = image.NextImage;
			}
			
		}
	}
	else if (localURL == "22_PHASAPARTMENT")
	{
		if (!flags.GetBool('Citadel_LavaRaised') && !flags.GetBool('Citadel_FirstRandomize'))
		{
			CitadelRandomize();
			flags.SetBool('Citadel_FirstRandomize',true,,24);
		}
		if (flags.GetBool('Citadel_LavaRaised') && !flags.GetBool('Citadel_SecondRandomize'))
		{
			CitadelRandomize();
			flags.SetBool('Citadel_SecondRandomize',true,,24);
		}
		
		if (flags.GetBool('ALLIED_WC'))
		{
			// Make all the PDX people hostile
			foreach AllActors(class'TNMPawn',p,)
			{
				if ((p.Tag == 'Firewall')||
				    (p.Tag == 'Cop1')||
				    (p.Tag == 'PhasecGuards')||
				    (p.Tag == 'PhasecBasementGuard'))
					p.ChangeAlly('Player', -1.000000, true);
			}
		}
		
		i = 0;
		if (!flags.GetBool('GiantGreaselCrateDone'))
		{
			foreach AllActors(class'Decoration', aCrate)
			{
				if (aCrate.Tag == 'GiantGreaselCrate')
					i++;	
			}
		}
		if (i == 0)
		{
			if (!flags.GetBool('GiantGreaselCrateDone'))
			{
				flags.SetBool('GiantGreaselCrateDone',true,,24);
				
				foreach AllActors(class'Decoration', aCrate)
				{
					if (aCrate.Tag == 'StoneGreasel')
					{
						aCrate.SetCollision(False, False, False);
						p = Spawn(class<TNMPawn>(DynamicLoadObject("TNMCharacters.StoneGreasel",class'Class')), None,, aCrate.Location, aCrate.Rotation);
						if (p != None)
						{
							p.AnimSequence=aCrate.AnimSequence;
							p.AnimFrame=aCrate.AnimFrame;
							p.SetEnemy(Player);
						}
						aCrate.bHidden = True;
						aCrate.Destroy();
					}
				}
			}
			if (!flags.GetBool('GiantGreaselDone'))
			{
				foreach AllActors(class'Decoration', aCrate)
				{
					if (aCrate.Tag == 'GiantGreasel' && aCrate.LastRendered() > 1)
					{
						aCrate.AnimSequence = 'HitFront';
						flags.SetBool('GiantGreaselDone',true,,24);
					}
				}
			}
		}
	}
	else if (localURL == "22_CITADEL")
	{
		if (flags.GetBool('Citadel_LavaRaised'))
			CitadelExplosionEffects(True);
	}
	else if (localURL == "22_FCREGISTRATION")
	{
		UCSpawnee = None;
		
		foreach AllActors(class'Inventory', inv, 'RegistrationUCspawnee')
		{	
			// Allow additional spawns while item is in inv
			if (inv.Owner == None)
				UCSpawnee = inv;
		}
		
		if (UCSpawnee == None && !flags.GetBool('TimerStarted_RegistrationUCItem7'))
			StartSpawningRegistrationUCItem();
	
		if (flags.GetBool('Alpha_Phase1'))
		{
			count = 0;
			foreach AllActors(class'TNMPawn',p,'AlphaFirewallBoys1')
			{
				count++;
			}
			foreach AllActors(class'TNMPawn',p,'AlphaFirewallBoys2')
			{
				count++;
			}
			if (count == 0)
			{
				// Alpha phase 2
				flags.SetBool('Alpha_Phase1',false,,23);
				// flags.SetBool('Alpha_Phase2',true,,23);
				// AlphaPhase2Start();
				AlphaPhase2Break();
			}
		}
		if (flags.GetBool('Alpha_Phase2'))
		{		
			// Dynamically load classes from child packages
			if (spawnData[0].SpawnClass == None)
				spawnData[0].SpawnClass = class<ScriptedPawn>(DynamicLoadObject("TNMCharacters.SpydronePawn",class'Class'));
			if (spawnData[1].SpawnClass == None)
				spawnData[1].SpawnClass = class<ScriptedPawn>(DynamicLoadObject("TNMCharacters.SpydronePawn",class'Class'));
			if (spawnData[2].SpawnClass == None)
				spawnData[2].SpawnClass = class<ScriptedPawn>(DynamicLoadObject("TNMCharacters.FireWallAlpha",class'Class'));
				
			// Kill disabled robots
			foreach AllActors(class'ScriptedPawn', ScriptedP)
				for (i=0; i<ArrayCount(spawnData); i++)
					if ((ScriptedP.Class == spawnData[i].spawnClass) && (ScriptedP.Tag == spawnData[i].Tag))
						if (Robot(ScriptedP) != None && ScriptedP.IsInState('Disabled'))
							ScriptedP.TakeDamage(ScriptedP.Health, None, ScriptedP.Location, vect(0,0,0), 'Exploded');
						
			// count the number of monsters that are still alive
			foreach AllActors(class'ScriptedPawn', ScriptedP)
				for (i=0; i<ArrayCount(spawnData); i++)
					if ((ScriptedP.Class == spawnData[i].spawnClass) && (ScriptedP.Tag == spawnData[i].Tag))
						spawnData[i].count++;

			// check to see when the last one was killed and set the time correctly
			for (i=0; i<ArrayCount(spawnData); i++)
				if ((spawnData[i].count == 0) && (spawnData[i].lastKilledTime == -1))
					spawnData[i].lastKilledTime = Level.TimeSeconds;
					
			for (i=0; i<ArrayCount(spawnData); i++)
			{
				if ((spawnData[i].count == 0) && (Level.TimeSeconds - spawnData[i].lastKilledTime > 10))
				{
					// Can't use GetSpawnPoint because Biomod/Shifter make the game crash.
					// SP = GetSpawnPoint(spawnData[i].spawnTag);
					foreach AllActors(class'SpawnPoint', SP, spawnData[i].spawnTag)
					{
						// SP2 = SP;
						if (FRand() < 0.5)
							break;
					}
					if (SP != None)
					{
						// spawn the actual monster
						ScriptedP = None;
						// spawn the actual monster
						if (i == 0 && flags.GetBool('DroneSpawner1_Destroyed'))
							{}
						else if (i == 1 && flags.GetBool('DroneSpawner2_Destroyed'))
							{}
						else
							ScriptedP = Spawn(spawnData[i].spawnClass, None, spawnData[i].Tag, SP.Location, SP.Rotation);
						if (ScriptedP != None)	// Transcended - Only do this per success, rather than per attempt
						{
							ScriptedP.InitializePawn();
							// ScriptedP.SetOrders('Patrolling', spawnData[i].orderTag);
							ScriptedP.SetOrders('Attacking', );
							ScriptedP.ChangeAlly('Player', -1, True);
							ScriptedP.ChangeAlly('FireWalls', 1, True);
							ScriptedP.bKeepWeaponDrawn = True;
							ScriptedP.bAlwaysPatrol = True;
							// if (tnmPawn(ScriptedP) != None)
								// tnmPawn(ScriptedP).bExtraSuspicious = True; // Turn head while walking
							spawnData[i].lastKilledTime = -1;
							
							// draw some light effects
							Spawn(class'ExplosionLight',,, SP.Location);
							Spawn(class'EllipseEffect',,, SP.Location);
							sphere = Spawn(class'SphereEffect',,, SP.Location);
							if (sphere != None)
								sphere.size = 4.0;

							// draw some electricity effects
							for (j=0; j<4; j++)
							{
								loc = vect(0,0,0);
								loc.Z = 32.0 + 32.0 * j;
								elec = Spawn(class'ElectricityEmitter',,, SP.Location + loc, rot(16384,0,0));
								if (elec != None)
								{
									elec.damageAmount = 0.0;
									elec.LifeSpan = 1.0;
									elec.randomAngle = 32768.0;
								}
							}

							// play a sound
							SP.PlaySound(sound'Spark1', SLOT_None, 2.0,, 2048.0, 2.0);
						}
					}
				}

				// reset the count for the next pass
				spawnData[i].count = 0;
			}
			
			foreach AllActors(class'ScriptedPawn', ScriptedP, 'FirewallAlpha')
			{
				SP = None;
				foreach AllActors(class'SpawnPoint', SP, 'AlphaSpawnPoint')
				{
					if (FRand() < 0.5)
						break;
				}
				// Fail to teleport
				if (FRand() < 0.9)
					SP = None;
				if (FRand() < 2) // Cut mechanic
					SP = None;
				if (SP != None)
				{
					if (ScriptedP.SetLocation(SP.Location))
					{
						ScriptedP.SetRotation(SP.Rotation);
						ScriptedP.SetRotation(Rotator(Player.Location - SP.Location));
							
						// draw some light effects
						Spawn(class'ExplosionLight',,, ScriptedP.Location);
						Spawn(class'EllipseEffect',,, ScriptedP.Location);
						sphere = Spawn(class'SphereEffect',,, ScriptedP.Location);
						if (sphere != None)
							sphere.size = 4.0;
						ScriptedP.PlaySound(sound'Spark1', SLOT_None, 2.0,, 2048.0, 2.0);
					}
				}
				ScriptedP.ChangeAlly('Player', -1, True);
				ScriptedP.ChangeAlly('FireWalls', 1, True);
				ScriptedP.SetOrders('Attacking', );
			}
			
			if (flags.GetBool('DroneSpawner1_Destroyed') && flags.GetBool('DroneSpawner2_Destroyed'))
			{
				flags.SetBool('Alpha_Phase2',false,,23);
				// flags.SetBool('Alpha_Phase3',true,,23);
				// AlphaPhase3Start();
				AlphaPhase3Break();
			}
		}
		if (flags.GetBool('Alpha_Phase3'))
		{
			if (flags.GetBool('Turret1Disable') && (flags.GetBool('Turret2DisableEarly') || flags.GetBool('Turret2Disable')))
			{
				flags.SetBool('Alpha_Phase3',false,,23);
				AlphaPhase4Break();
			}
		}
		if (flags.GetBool('Alpha_Phase3') || flags.GetBool('Alpha_Phase4'))
		{		
			// Dynamically load classes from child packages
			if (spawnData[0].SpawnClass == None)
				spawnData[0].SpawnClass = class<ScriptedPawn>(DynamicLoadObject("TNMCharacters.SpydronePawn",class'Class'));
			if (spawnData[1].SpawnClass == None)
				spawnData[1].SpawnClass = class<ScriptedPawn>(DynamicLoadObject("TNMCharacters.SpydronePawn",class'Class'));
			if (spawnData[2].SpawnClass == None)
				spawnData[2].SpawnClass = class<ScriptedPawn>(DynamicLoadObject("TNMCharacters.FireWallAlpha",class'Class'));
				
			// Kill disabled robots
			foreach AllActors(class'ScriptedPawn', ScriptedP)
				for (i=0; i<ArrayCount(spawnData); i++)
					if ((ScriptedP.Class == spawnData[i].spawnClass) && (ScriptedP.Tag == spawnData[i].Tag))
						if (Robot(ScriptedP) != None && ScriptedP.IsInState('Disabled'))
							ScriptedP.TakeDamage(ScriptedP.Health, None, ScriptedP.Location, vect(0,0,0), 'Exploded');
						
			// count the number of monsters that are still alive
			foreach AllActors(class'ScriptedPawn', ScriptedP)
				for (i=0; i<ArrayCount(spawnData); i++)
					if ((ScriptedP.Class == spawnData[i].spawnClass) && (ScriptedP.Tag == spawnData[i].Tag))
						spawnData[i].count++;

			// check to see when the last one was killed and set the time correctly
			for (i=0; i<ArrayCount(spawnData); i++)
				if ((spawnData[i].count == 0) && (spawnData[i].lastKilledTime == -1))
					spawnData[i].lastKilledTime = Level.TimeSeconds;
			
			foreach AllActors(class'ScriptedPawn', ScriptedP, 'FirewallAlpha')
			{
				SP = None;
				foreach AllActors(class'SpawnPoint', SP, 'AlphaSpawnPoint')
				{
					if (FRand() < 0.8)
						break;
				}
				// Fail to teleport
				if (flags.GetBool('Alpha_Phase3') && FRand() < 0.2)
					SP = None;
				if (/*flags.GetBool('Alpha_Phase3') && */FRand() < 2) // Cut mechanic
					SP = None;
				if (SP != None)
				{
					if (ScriptedP.SetLocation(SP.Location))
					{
						ScriptedP.SetRotation(SP.Rotation);
						ScriptedP.SetRotation(Rotator(Player.Location - SP.Location));
							
						// draw some light effects
						Spawn(class'ExplosionLight',,, ScriptedP.Location);
						Spawn(class'EllipseEffect',,, ScriptedP.Location);
						sphere = Spawn(class'SphereEffect',,, ScriptedP.Location);
						if (sphere != None)
							sphere.size = 4.0;
						ScriptedP.PlaySound(sound'Spark1', SLOT_None, 2.0,, 2048.0, 2.0);
					}
				}
				ScriptedP.ChangeAlly('Player', -1, True);
				ScriptedP.ChangeAlly('FireWalls', 1, True);
				ScriptedP.SetOrders('Attacking', );
			}
					
			for (i=0; i<ArrayCount(spawnData); i++)
			{
				if ((spawnData[i].count == 0) && (Level.TimeSeconds - spawnData[i].lastKilledTime > 10))
				{
					// Can't use GetSpawnPoint because Biomod/Shifter make the game crash.
					// SP = GetSpawnPoint(spawnData[i].spawnTag);
					foreach AllActors(class'SpawnPoint', SP, spawnData[i].spawnTag)
					{
						// SP2 = SP;
						if (FRand() < 0.5)
							break;
					}
					if (SP != None)
					{
						ScriptedP = None;
						// spawn the actual monster
						if (i == 0 && flags.GetBool('DroneSpawner1_Destroyed'))
							{}
						else if (i == 1 && flags.GetBool('DroneSpawner2_Destroyed'))
							{}
						else
							ScriptedP = Spawn(spawnData[i].spawnClass, None, spawnData[i].Tag, SP.Location, SP.Rotation);
						if (ScriptedP != None)	// Transcended - Only do this per success, rather than per attempt
						{
							ScriptedP.InitializePawn();
							// ScriptedP.SetOrders('Patrolling', spawnData[i].orderTag);
							ScriptedP.SetOrders('Attacking', );
							ScriptedP.ChangeAlly('Player', -1, True);
							ScriptedP.ChangeAlly('FireWalls', 1, True);
							ScriptedP.bKeepWeaponDrawn = True;
							ScriptedP.bAlwaysPatrol = True;
							// if (tnmPawn(ScriptedP) != None)
								// tnmPawn(ScriptedP).bExtraSuspicious = True; // Turn head while walking
							spawnData[i].lastKilledTime = -1;
							
							// draw some light effects
							Spawn(class'ExplosionLight',,, SP.Location);
							Spawn(class'EllipseEffect',,, SP.Location);
							sphere = Spawn(class'SphereEffect',,, SP.Location);
							if (sphere != None)
								sphere.size = 4.0;

							// draw some electricity effects
							for (j=0; j<4; j++)
							{
								loc = vect(0,0,0);
								loc.Z = 32.0 + 32.0 * j;
								elec = Spawn(class'ElectricityEmitter',,, SP.Location + loc, rot(16384,0,0));
								if (elec != None)
								{
									elec.damageAmount = 0.0;
									elec.LifeSpan = 1.0;
									elec.randomAngle = 32768.0;
								}
							}

							// play a sound
							SP.PlaySound(sound'Spark1', SLOT_None, 2.0,, 2048.0, 2.0);
						}
					}
				}

				// reset the count for the next pass
				spawnData[i].count = 0;
			}
		}
		if (flags.GetBool('LoyalFirewall_Dead'))
		{
			SendPM("PM_Firewall_CharlieDead");
		}
	}
	else if (localURL == "22_WCSUBLEVEL")
	{
		// Allow the player to spawn the Quad Launcher after inserting both the plans and the codes
		if (flags.GetBool('Quad_PlansInserted') && flags.GetBool('Quad_CodesInserted'))
			flags.SetBool('Quad_ReadyToSpawn',true,,23);
		
		// Create the Quad Launcher when the time is right
		if (flags.GetBool('MS_SpawnQuadLauncher'))
		{
			flags.DeleteFlag('HAS_QuadLauncherPlans', FLAG_Bool);
			flags.DeleteFlag('HAS_ConstructionCodes', FLAG_Bool);
			flags.DeleteFlag('Quad_PlansInserted', FLAG_Bool);
			flags.DeleteFlag('Quad_CodesInserted', FLAG_Bool);
			flags.DeleteFlag('Quad_ReadyToSpawn', FLAG_Bool);
			flags.DeleteFlag('MS_SpawnQuadLauncher', FLAG_Bool);

			StartSpawningQuadLauncher();
		}
	}
}

function PlayerDetected(name StateType, optional ScriptedPawn Triggerer)
{
	// *Ahem* Let's try that again, defining the proper vars this time! Thanks Smoke - Jonas
	local TNMPawn p;
	local TNMRobot r;
	local securitycamera cam;

	if ((localURL == "22_GOATCITY")||
	   (localURL == "22_GOATTEMPLAE"))
	{
		//killing Athena:
		if (flags.GetBool('QR_CULT_KillAthena') && !flags.GetBool('Beefman_LastQuestDone'))
		{
			flags.SetBool('NS_KillAthena',true,,23);
		}
	}
	else if (localURL == "22_LLAMATEMPLE")
	{
		//killing Beefman:
		if (flags.GetBool('QR_CULT_KillBeefman') && !flags.GetBool('DT_LastQuestDone'))
		{
			flags.SetBool('NS_KillBeefman',true,,23);
		}
	}
	else if (localURL == "22_DXO")
	{
		// Activate the security cameras if you cause trouble
		foreach allactors(class'securitycamera', cam, )
		{
			if ((cam.tag == 'HubRoomCam') ||
			    (cam.tag == 'ArmouryCam') ||
			    (cam.tag == 'BarrackCam'))
			cam.bNoAlarm = false;
		}
	}
	else if (localURL == "22_ATC")
	{
		// W00T, I found a use for this function other than bonuses!
		if (flags.GetBool('HAS_ATCIDCard') && !flags.GetBool('MS_ATCVoidID') && !flags.GetBool('MS_MoveLobbyGuards'))
		{
			if (Triggerer != None && Triggerer.IsA('GenericCSI'))
			{
				SendPM("PM_TG_VoidID");

				// Make all the guards hostile again if the player fucks up
				foreach allactors(class'TNMPawn',p,)
					if (p.Tag == 'ATCGuard' || p.Tag == 'ATCGuardAlert1' || p.Tag == 'ATCGuardAlert2' || p.Tag == 'ATCGuardAlert3' || p.Tag == 'ATCGuardAlert4' || p.Tag == 'ShackGuard')
						p.ChangeAlly('Player',-1.000000,true);
				foreach allactors(class'TNMRobot',r,'ATCBot')
					r.ChangeAlly('Player',-1.000000,true);
				foreach allactors(class'securitycamera', cam, )
					cam.memoryTime=cam.default.memoryTime;

				flags.SetBool('MS_ATCVoidID',true,,23);
			}
		}
	}
	else if (LocalURL == "22_WCSUBLEVEL")
	{
		//destroying Black ICE:
		if (flags.GetBool('QR_SUB_BlackICE') && !flags.GetBool('Evil_Done'))
		{
			flags.SetBool('NS_BlackICE',true,,23);
		}
	}
}

function LobbyGuards()
{
	local TNMPawn p;
	local CouchLeather C;

	// Make some guards barricade the lobby unless they're all dead
	if (flags.GetBool('MS_MoveLobbyGuards') && !flags.GetBool('ATC_AlertGuardsDead') && !flags.GetBool('MS_MovedLobbyGuards'))
	{
		foreach allactors(class'TNMPawn',p,)
		{
			if (p.Tag == 'ATCGuardAlert1')
			{
				p.OrderTag='LobbyPoint01';
				TeleportPawn(p, 'LobbyPoint01', 'Patrolling',false,true);
			}
			else if (p.Tag == 'ATCGuardAlert2')
			{
				p.OrderTag='LobbyPoint02';
				TeleportPawn(p, 'LobbyPoint02', 'Patrolling',false,true);
			}
			else if (p.Tag == 'ATCGuardAlert3')
			{
				p.OrderTag='LobbyPoint03';
				TeleportPawn(p, 'LobbyPoint03', 'Patrolling',false,true);
			}
			else if (p.Tag == 'ATCGuardAlert4')
			{
				p.OrderTag='LobbyPoint04';
				TeleportPawn(p, 'LobbyPoint04', 'Patrolling',false,true);
			}
		}

		// Move the couch to form a crude barricade
		foreach AllActors(class'CouchLeather', C,)
		{
			if (C.Tag == 'Couch_LobbyBarricade1')
			{
				C.bHidden = true;
				C.SetCollision(false,false,false);
			}
			else if (C.Tag == 'Couch_LobbyBarricade2')
			{
				C.bHidden = false;
				C.SetCollision(true,true,true);
			}
		}

		flags.SetBool('MS_MovedLobbyGuards', true, , 23);
	}
}

function SpawnMidasChopper()
{
	local vehicles v;
	local dispatcher d;

	// Make the chopper appear
	foreach allactors(class'Vehicles',V,'BlackHelicopter01')
		V.EnterWorld();

	// Begin the interpolation
	foreach AllActors(class'Dispatcher', D, 'LandingDispatcher')
		D.Trigger(Self, Player);

	flags.SetBool('MS_MidasIncoming',true,,23);
}

function HandleGameEvent(name scriptFunction)
{
	switch (scriptfunction)
	{
		case 'SlumHologramDisappear'	: SlumHologramDisappear(); 	break;
		case 'AJChangeClothes'			: AJChangeClothes(); 		break;
		case 'OpenTortureRoom'			: OpenTortureRoom(); 		break;
		case 'EvacuateTemplae'			: EvacuateTemplae(); 		break;
		case 'ShootOiNutter'			: ShootOiNutter(); 			break;
		case 'LandedChopperAppear'		: LandedChopperAppear();	break;
		case 'CarCrash'					: CarCrash();			 	break;
		case 'DTHologramAppear'			: DTHologramAppear(); 		break;
		case 'DTHologramDisappear'		: DTHologramDisappear(); 	break;
		case 'TortureKnockConvo'		: TortureKnockConvo(); 		break;
		case 'DTDropItems'				: DTDropItems(); 			break;
		case 'KillShieldDoor'			: KillShieldDoor(); 		break;
		case 'ParadronesEnter'			: ParadronesEnter(); 		break;
		case 'HideMidasHand'			: HideMidasHand(); 			break;
		case 'OrderGuardsToApartment'	: OrderGuardsToApartment(); break;
		case 'AthenaTVOpen'				: AthenaTVOpen(); 			break;
		case 'AthenaTVClose'			: AthenaTVClose(); 			break;
		case 'CitadelRaiseLava'			: CitadelRaiseLava();		break;
		case 'AlphaPhase1Start'			: AlphaPhase1Start();		break;
		case 'AlphaPhase2Start'			: AlphaPhase2Start();		break;
		case 'AlphaPhase3Start'			: AlphaPhase3Start();		break;
		case 'AlphaPhase4Start'			: AlphaPhase4Start();		break;
		case 'AlphaStopGenerator1'		: AlphaStopGenerator(1);	break;
		case 'AlphaStopGenerator2'		: AlphaStopGenerator(2);	break;
		case 'AlphaStopGenerator3'		: AlphaStopGenerator(3);	break;
		case 'FirewallAlphaKillphrased'	: AlphaKillphrased();		break;
		case 'CounterPuzzle1'			: CounterPuzzle(1);			break;
		case 'CounterPuzzle2'			: CounterPuzzle(2);			break;
		case 'CounterPuzzle3'			: CounterPuzzle(3);			break;
		case 'CounterPuzzle4'			: CounterPuzzle(4);			break;
		case 'OverloadFirewalls1'		: OverloadFirewalls('AlphaFirewallBoys1');		break;
		case 'OverloadFirewalls2'		: OverloadFirewalls('AlphaFirewallBoys2');		break;
		case 'FirewallBeacon'			: StartSpawningRegistrationSecretUCItem();		break;
		default: super.HandleGameEvent(scriptFunction);
	}
}

function OverloadFirewalls(name target)
{
	local pawn curpawn;
	
	for (curPawn=Level.PawnList; curPawn!=None; curPawn=curPawn.NextPawn)
	{
		if (curpawn.tag == target)
			curpawn.TakeDamage(curpawn.Health * 2,none,vect(0,0,0),vect(0,0,0),'EMP');
	}
}

function CounterPuzzle(int i)
{	
	local int j;
	local DeusExMover M;
	
	j =	flags.GetInt('CounterPuzzle');
	
	if (i == j + 1)
		flags.SetInt('CounterPuzzle', i, True, 23);
	else
		flags.SetInt('CounterPuzzle', 0, True, 23);
	
	j =	flags.GetInt('CounterPuzzle');
	
	if (j >= 4)
	{
		foreach AllActors(class'DeusExMover', M, 'SecretMover')
		{
			M.Trigger(None,None);
		}
	}	
	else
	{
		foreach AllActors(class'DeusExMover', M, 'CounterLever')
		{
			if (M.KeyNum != 0)
				M.Trigger(None,None);
		}
	}
}

function AthenaTVOpen()
{
	local Decoration tv;
	
	foreach AllActors(class'Decoration', tv, 'TVSwitch')
	{
		tv.Event = 'TVClose';
		break;
	}
}

function AthenaTVClose()
{
	local Decoration tv;
	
	foreach AllActors(class'Decoration', tv, 'TVSwitch')
	{
		tv.Event = 'TVOpen';
		break;
	}
}

function OrderGuardsToApartment()
{
	local Pawn curPawn;
	
	for (curPawn=Level.PawnList; curPawn!=None; curPawn=curPawn.NextPawn)
	{
		if (TNMPawn(curPawn) != None && curPawn.Tag == 'InnerTemplaeGuards')
		{
			TNMPawn(curPawn).bShouldGuardPoints = True;
			TNMPawn(curPawn).guardRadius = 100000;
			TNMPawn(curPawn).guardChance = 1;
			TNMPawn(curPawn).GoToState('Guarding');
		}
	}
}

function HideMidasHand()
{
	local Pawn curPawn;
	
	for (curPawn=Level.PawnList; curPawn!=None; curPawn=curPawn.NextPawn)
	{
		if (curPawn.IsA('Midashand'))
			ScriptedPawn(curPawn).LeaveWorld();
	}
}

function ParadronesEnter()
{
	local Vehicles v;
	
	foreach AllActors(class'Vehicles', v)
	{
		if (v.IsA('ParadropDrone'))
			v.EnterWorld();
	}
}

function KillShieldDoor()
{
	local Mover M;
	
	foreach AllActors(class'Mover', M, 'Specimen1Shield')
	{
		// M.Destroy();
		M.InterpolateTo(4,0);
	}
}

function CitadelRaiseLava()
{
	local DeusExMover M;
	local ZoneInfo Z;
	local ScriptedPawn S;
	local TNMDecoration liftfire;
	
	foreach AllActors(class'DeusExMover', M, 'MainRoomRaise')
	{
		// M.Destroy();
		M.InterpolateTo(1,0);
	}
	foreach AllActors(class'DeusExMover', M, 'FirstEntranceRaise')
	{
		// M.Destroy();
		M.InterpolateTo(1,0);
	}
	foreach AllActors(class'DeusExMover', M, 'FloatingRock')
	{
		// M.Destroy();
		M.bBreakable=true;
		M.ExplodeSound1=None;
		M.ExplodeSound2=None;
		M.FragmentClass=None;
		M.takedamage(100,none,vect(0,0,0),vect(0,0,0),'Shot');
	}
	foreach AllActors(class'ScriptedPawn', S, 'ConvoFanatic')
	{
		S.LeaveWorld();
	}
	foreach AllActors(class'ScriptedPawn', S, 'CivFanatic')
	{
		S.LeaveWorld();
	}
	foreach AllActors(class'ScriptedPawn', S, 'DXIFanaticBoss')
	{
		S.EnterWorld();
	}
	foreach AllActors(class'ZoneInfo', Z, 'RaisedLavaZone')
	{
		Z.bPainZone = True;
		Z.ZoneVelocity.Z = -10;
		Z.ZoneTerminalVelocity = 20;
		Z.ViewFog.X = 1;
		Z.ViewFog.Y = 0.3;
		Z.ViewFlash.X = -0.95;
		Z.AmbientBrightness=64;
		Z.AmbientHue=25;
		Z.AmbientSaturation=100;
	}
	foreach AllActors(class'TNMDecoration', liftfire, 'Firestarter')
	{
		if (liftfire.Region.Zone.Tag == 'RaisedLavaZone')
			liftfire.Trigger(None,None);
	}

	flags.SetBool('Citadel_LavaRaised', true, , 23);
}

function AlphaPhase1Start()
{
	local DeusExMover M;
	local ScriptedPawn S;
	local ControlPanel C;
	
	foreach AllActors(class'DeusExMover', M, 'FireWallDoor1')
	{
		M.Trigger(None,None);
	}	
	foreach AllActors(class'DeusExMover', M, 'FireWallDoor2')
	{
		M.Trigger(None,None);
	}
	
	foreach AllActors(class'ScriptedPawn', S, 'AlphaFirewallBoys1')
	{
		S.EnterWorld();
	}
	
	foreach AllActors(class'ScriptedPawn', S, 'AlphaFirewallBoys2')
	{
		S.EnterWorld();
	}
	
	foreach AllActors(class'ControlPanel', C, 'SpydroneControlPanels')
	{
		C.SetCollisionSize( 0, 0 );
	}

	flags.SetBool('Alpha_Phase1', true, , 23);
}

function AlphaPhase2Break()
{
	local ScriptedPawn ScriptedP;
	local SpawnPoint SP;
	local int count, i, j;
	local SphereEffect sphere;
	local ElectricityEmitter elec;
	local Vector loc;
	
	count = 0;
	foreach AllActors(class'ScriptedPawn', ScriptedP, 'FirewallAlpha')
	{
		count++;
		SP = None;
		foreach AllActors(class'SpawnPoint', SP, 'AlphaMasterSpawnPoint')
		{
			// if (FRand() < 0.5)
				break;
		}
		if (SP != None)
		{
			if (ScriptedP.SetLocation(SP.Location))
			{
				ScriptedP.SetRotation(SP.Rotation);
				ScriptedP.SetRotation(Rotator(Player.Location - SP.Location));
					
				// draw some light effects
				// Spawn(class'ExplosionLight',,, ScriptedP.Location);
				// Spawn(class'EllipseEffect',,, ScriptedP.Location);
				// sphere = Spawn(class'SphereEffect',,, ScriptedP.Location);
				// if (sphere != None)
					// sphere.size = 4.0;
				// ScriptedP.PlaySound(sound'Spark1', SLOT_None, 2.0,, 2048.0, 2.0);
			}
		}
		ScriptedP.ChangeAlly('Player', 0, True);
		// ScriptedP.ChangeAlly('FireWalls', 1, True);
		// ScriptedP.SetOrders('Attacking', );
	}
	
	// for (i=0; i<ArrayCount(spawnData); i++)
		// if ((spawnData[i].count == 0) && (spawnData[i].lastKilledTime == -1))
			// spawnData[i].lastKilledTime = Level.TimeSeconds - 8;
						
	// count the number of monsters that are still alive
	foreach AllActors(class'ScriptedPawn', ScriptedP)
		for (i=0; i<ArrayCount(spawnData); i++)
			if ((ScriptedP.Class == spawnData[i].spawnClass) && (ScriptedP.Tag == spawnData[i].Tag))
				spawnData[i].count++;
	if (count == 0)
	{	
		for (i=2; i<ArrayCount(spawnData); i++)
		{
			if (spawnData[2].SpawnClass == None)
				spawnData[2].SpawnClass = class<ScriptedPawn>(DynamicLoadObject("TNMCharacters.FireWallAlpha",class'Class'));
			if ((spawnData[i].count == 0)/* && (Level.TimeSeconds - spawnData[i].lastKilledTime > 10)*/)
			{
				// Can't use GetSpawnPoint because Biomod/Shifter make the game crash.
				// SP = GetSpawnPoint(spawnData[i].spawnTag);
				foreach AllActors(class'SpawnPoint', SP, 'AlphaMasterSpawnPoint')
				{
					// SP2 = SP;
					// if (FRand() < 0.5)
						break;
				}
				if (SP != None)
				{
					ScriptedP = None;
					// spawn the actual monster
					if (i == 0 && flags.GetBool('DroneSpawner1_Destroyed'))
						{}
					else if (i == 1 && flags.GetBool('DroneSpawner2_Destroyed'))
						{}
					else
						ScriptedP = Spawn(spawnData[i].spawnClass, None, spawnData[i].Tag, SP.Location, SP.Rotation);
					if (ScriptedP != None)	// Transcended - Only do this per success, rather than per attempt
					{
						ScriptedP.InitializePawn();
						// ScriptedP.SetOrders('Patrolling', spawnData[i].orderTag);
						ScriptedP.SetOrders('Attacking', );
						ScriptedP.ChangeAlly('Player', -1, True);
						ScriptedP.ChangeAlly('FireWalls', 1, True);
						ScriptedP.bKeepWeaponDrawn = True;
						ScriptedP.bAlwaysPatrol = True;
						// if (tnmPawn(ScriptedP) != None)
							// tnmPawn(ScriptedP).bExtraSuspicious = True; // Turn head while walking
						spawnData[i].lastKilledTime = -1;
						
						// draw some light effects
						Spawn(class'ExplosionLight',,, SP.Location);
						Spawn(class'EllipseEffect',,, SP.Location);
						sphere = Spawn(class'SphereEffect',,, SP.Location);
						if (sphere != None)
							sphere.size = 4.0;

						// draw some electricity effects
						for (j=0; j<4; j++)
						{
							loc = vect(0,0,0);
							loc.Z = 32.0 + 32.0 * j;
							elec = Spawn(class'ElectricityEmitter',,, SP.Location + loc, rot(16384,0,0));
							if (elec != None)
							{
								elec.damageAmount = 0.0;
								elec.LifeSpan = 1.0;
								elec.randomAngle = 32768.0;
							}
						}

						// play a sound
						SP.PlaySound(sound'Spark1', SLOT_None, 2.0,, 2048.0, 2.0);
					}
				}
			}

			// reset the count for the next pass
			spawnData[i].count = 0;
		}
	}
	SendPM("PM_Firewall_Phase2");
}

function AlphaPhase2Start()
{
	local DeusExMover M;
	local ScriptedPawn S;
	local int i;
	local ControlPanel C;
	local ScriptedPawn ScriptedP;
	local SpawnPoint SP, SP2;
	local SphereEffect sphere;
	local ElectricityEmitter elec;
	local Vector loc;
	local AlarmLight AL;
	
	foreach AllActors(class'ScriptedPawn', ScriptedP, 'FirewallAlpha')
	{
		SP = None;
		foreach AllActors(class'SpawnPoint', SP, 'AlphaSpawnPoint')
		{
			SP2 = SP;
			if (FRand() < 0.5)
				break;
		}
		if (SP == None)
			SP = SP2;
		if (SP != None)
		{
			if (ScriptedP.SetLocation(SP.Location))
			{
				ScriptedP.SetRotation(SP.Rotation);
				ScriptedP.SetRotation(Rotator(Player.Location - SP.Location));
					
				// draw some light effects
				Spawn(class'ExplosionLight',,, ScriptedP.Location);
				Spawn(class'EllipseEffect',,, ScriptedP.Location);
				sphere = Spawn(class'SphereEffect',,, ScriptedP.Location);
				if (sphere != None)
					sphere.size = 4.0;
				ScriptedP.PlaySound(sound'Spark1', SLOT_None, 2.0,, 2048.0, 2.0);
			}
		}
		ScriptedP.ChangeAlly('Player', -1, True);
		ScriptedP.ChangeAlly('FireWalls', 1, True);
		ScriptedP.SetOrders('Attacking', );
	}
	
	foreach AllActors(class'DeusExMover', M, 'SpydroneSpawner1')
	{
		M.bBreakable = True;
	}		
	foreach AllActors(class'DeusExMover', M, 'SpydroneSpawner2')
	{
		M.bBreakable = True;
	}	
	
	foreach AllActors(class'DeusExMover', M, 'SpydroneDoor1')
	{
		M.Trigger(None,None);
	}
	foreach AllActors(class'DeusExMover', M, 'SpydroneDoor2')
	{
		M.Trigger(None,None);
	}
	foreach AllActors(class'AlarmLight', AL, 'AlarmLightSD')
	{
		AL.Trigger(None,None);
	}
	
	foreach AllActors(class'ControlPanel', C, 'SpydroneControlPanels')
	{
		C.SetCollisionSize( C.Default.collisionradius, C.Default.collisionheight );
	}

	flags.SetBool('Alpha_Phase2', true, , 23);
	
	for (i=0; i<ArrayCount(spawnData)-1; i++)
		if ((spawnData[i].count == 0) && (spawnData[i].lastKilledTime == -1))
			spawnData[i].lastKilledTime = Level.TimeSeconds - 8;
}

function AlphaPhase3Break()
{
	local ScriptedPawn ScriptedP;
	local SpawnPoint SP;
	local int count, i, j;
	local SphereEffect sphere;
	local ElectricityEmitter elec;
	local Vector loc;
	local AlarmLight AL;
	
	foreach AllActors(class'ScriptedPawn', ScriptedP, 'FirewallAlpha')
	{
		count++;
		SP = None;
		foreach AllActors(class'SpawnPoint', SP, 'AlphaMasterSpawnPoint')
		{
			// if (FRand() < 0.5)
				break;
		}
		if (SP != None)
		{
			if (ScriptedP.SetLocation(SP.Location))
			{
				ScriptedP.SetRotation(SP.Rotation);
				ScriptedP.SetRotation(Rotator(Player.Location - SP.Location));
					
				// draw some light effects
				Spawn(class'ExplosionLight',,, ScriptedP.Location);
				Spawn(class'EllipseEffect',,, ScriptedP.Location);
				sphere = Spawn(class'SphereEffect',,, ScriptedP.Location);
				if (sphere != None)
					sphere.size = 4.0;
				ScriptedP.PlaySound(sound'Spark1', SLOT_None, 2.0,, 2048.0, 2.0);
			}
		}
		ScriptedP.ChangeAlly('Player', 0, True);
		// ScriptedP.ChangeAlly('FireWalls', 1, True);
		// ScriptedP.SetOrders('Attacking', );
	}
	
	// for (i=0; i<ArrayCount(spawnData); i++)
		// if ((spawnData[i].count == 0) && (spawnData[i].lastKilledTime == -1))
			// spawnData[i].lastKilledTime = Level.TimeSeconds - 8;
						
	// count the number of monsters that are still alive
	foreach AllActors(class'ScriptedPawn', ScriptedP)
		for (i=0; i<ArrayCount(spawnData); i++)
			if ((ScriptedP.Class == spawnData[i].spawnClass) && (ScriptedP.Tag == spawnData[i].Tag))
				spawnData[i].count++;
	if (count == 0)
	{	
		for (i=2; i<ArrayCount(spawnData); i++)
		{
			if (spawnData[2].SpawnClass == None)
				spawnData[2].SpawnClass = class<ScriptedPawn>(DynamicLoadObject("TNMCharacters.FireWallAlpha",class'Class'));
			if ((spawnData[i].count == 0)/* && (Level.TimeSeconds - spawnData[i].lastKilledTime > 10)*/)
			{
				// Can't use GetSpawnPoint because Biomod/Shifter make the game crash.
				// SP = GetSpawnPoint(spawnData[i].spawnTag);
				foreach AllActors(class'SpawnPoint', SP, 'AlphaMasterSpawnPoint')
				{
					// SP2 = SP;
					// if (FRand() < 0.5)
						break;
				}
				if (SP != None)
				{
					ScriptedP = None;
					// spawn the actual monster
					if (i == 0 && flags.GetBool('DroneSpawner1_Destroyed'))
						{}
					else if (i == 1 && flags.GetBool('DroneSpawner2_Destroyed'))
						{}
					else
						ScriptedP = Spawn(spawnData[i].spawnClass, None, spawnData[i].Tag, SP.Location, SP.Rotation);
					if (ScriptedP != None)	// Transcended - Only do this per success, rather than per attempt
					{
						ScriptedP.InitializePawn();
						// ScriptedP.SetOrders('Patrolling', spawnData[i].orderTag);
						ScriptedP.SetOrders('Attacking', );
						ScriptedP.ChangeAlly('Player', -1, True);
						ScriptedP.ChangeAlly('FireWalls', 1, True);
						ScriptedP.bKeepWeaponDrawn = True;
						ScriptedP.bAlwaysPatrol = True;
						// if (tnmPawn(ScriptedP) != None)
							// tnmPawn(ScriptedP).bExtraSuspicious = True; // Turn head while walking
						spawnData[i].lastKilledTime = -1;
						
						// draw some light effects
						Spawn(class'ExplosionLight',,, SP.Location);
						Spawn(class'EllipseEffect',,, SP.Location);
						sphere = Spawn(class'SphereEffect',,, SP.Location);
						if (sphere != None)
							sphere.size = 4.0;

						// draw some electricity effects
						for (j=0; j<4; j++)
						{
							loc = vect(0,0,0);
							loc.Z = 32.0 + 32.0 * j;
							elec = Spawn(class'ElectricityEmitter',,, SP.Location + loc, rot(16384,0,0));
							if (elec != None)
							{
								elec.damageAmount = 0.0;
								elec.LifeSpan = 1.0;
								elec.randomAngle = 32768.0;
							}
						}

						// play a sound
						SP.PlaySound(sound'Spark1', SLOT_None, 2.0,, 2048.0, 2.0);
					}
				}
			}

			// reset the count for the next pass
			spawnData[i].count = 0;
		}
	}
	foreach AllActors(class'AlarmLight', AL, 'AlarmLightSD')
	{
		AL.Untrigger(None,None);
	}
	SendPM("PM_Firewall_Phase3");
}

function AlphaPhase3Start()
{
	local DeusExMover M;
	local ScriptedPawn S;
	local int i;
	local ScriptedPawn ScriptedP;
	local SpawnPoint SP, SP2;
	local SphereEffect sphere;
	local ElectricityEmitter elec;
	local Vector loc;
	local AlarmLight AL;
	
	foreach AllActors(class'ScriptedPawn', ScriptedP, 'FirewallAlpha')
	{
		SP = None;
		foreach AllActors(class'SpawnPoint', SP, 'AlphaSpawnPoint')
		{
			SP2 = SP;
			if (FRand() < 0.5)
				break;
		}
		if (SP == None)
			SP = SP2;
		if (SP != None)
		{
			if (ScriptedP.SetLocation(SP.Location))
			{
				ScriptedP.SetRotation(SP.Rotation);
				ScriptedP.SetRotation(Rotator(Player.Location - SP.Location));
					
				// draw some light effects
				Spawn(class'ExplosionLight',,, ScriptedP.Location);
				Spawn(class'EllipseEffect',,, ScriptedP.Location);
				sphere = Spawn(class'SphereEffect',,, ScriptedP.Location);
				if (sphere != None)
					sphere.size = 4.0;
				ScriptedP.PlaySound(sound'Spark1', SLOT_None, 2.0,, 2048.0, 2.0);
			}
		}
		ScriptedP.ChangeAlly('Player', -1, True);
		ScriptedP.ChangeAlly('FireWalls', 1, True);
		ScriptedP.SetOrders('Attacking', );
	}
	
	foreach AllActors(class'DeusExMover', M, 'TurretGenerator1')
	{
		M.bBreakable = True;
	}		
	foreach AllActors(class'DeusExMover', M, 'TurretGenerator2')
	{
		M.bBreakable = True;
	}
	foreach AllActors(class'DeusExMover', M, 'MoveCover')
	{
		M.Trigger(None,None);
	}	/*
	
	foreach AllActors(class'DeusExMover', M, 'SpydroneDoor1')
	{
		M.Trigger(None,None);
	}
	foreach AllActors(class'DeusExMover', M, 'SpydroneDoor2')
	{
		M.Trigger(None,None);
	}
	foreach AllActors(class'DeusExMover', M, 'RespawnGen1')
	{
		M.Trigger(None,None);
	}
	foreach AllActors(class'DeusExMover', M, 'RespawnGen2')
	{
		M.Trigger(None,None);
	}*/
	foreach AllActors(class'DeusExMover', M, 'AlphaTurret1')
	{
		M.Trigger(None,None);
	}
	foreach AllActors(class'DeusExMover', M, 'AlphaTurret1Turret')
	{
		M.Trigger(None,None);
	}
	foreach AllActors(class'DeusExMover', M, 'RespawnGen1')
	{
		M.Trigger(None,None);
	}
	foreach AllActors(class'DeusExMover', M, 'RespawnGen2')
	{
		M.Trigger(None,None);
	}
	foreach AllActors(class'DeusExMover', M, 'RespawnGen3')
	{
		M.Trigger(None,None);
	}
	
	// Control panel usage
	if (!flags.GetBool('Turret2DisableEarly'))
	{
		foreach AllActors(class'DeusExMover', M, 'AlphaTurret2')
		{
			M.Trigger(None,None);
		}
		foreach AllActors(class'DeusExMover', M, 'AlphaTurret2Turret')
		{
			M.Trigger(None,None);
		}
	}
	
	foreach AllActors(class'DeusExMover', M, 'TurretGeneratorWall1')
	{
		M.Trigger(None,None);
	}
	foreach AllActors(class'DeusExMover', M, 'TurretGeneratorWall2')
	{
		M.Trigger(None,None);
	}
	foreach AllActors(class'AlarmLight', AL, 'AlarmLightTR')
	{
		AL.Trigger(None,None);
	}
	
	// for (i=0; i<ArrayCount(spawnData); i++)
		// if ((spawnData[i].count == 0) && (spawnData[i].lastKilledTime == -1))
			// spawnData[i].lastKilledTime = Level.TimeSeconds - 8;

	flags.SetBool('Alpha_Phase3', true, , 23);
}

function AlphaPhase4Break()
{
	local ScriptedPawn ScriptedP;
	local SpawnPoint SP;
	local int count, i, j;
	local SphereEffect sphere;
	local ElectricityEmitter elec;
	local Vector loc;
	local AlarmLight AL;
	
	foreach AllActors(class'AlarmLight', AL, 'AlarmLightTR')
	{
		AL.Untrigger(None,None);
	}
	
	foreach AllActors(class'ScriptedPawn', ScriptedP, 'FirewallAlpha')
	{
		count++;
		SP = None;
		foreach AllActors(class'SpawnPoint', SP, 'AlphaMasterSpawnPoint')
		{
			// if (FRand() < 0.5)
				break;
		}
		if (SP != None)
		{
			if (ScriptedP.SetLocation(SP.Location))
			{
				ScriptedP.SetRotation(SP.Rotation);
				ScriptedP.SetRotation(Rotator(Player.Location - SP.Location));
					
				// draw some light effects
				Spawn(class'ExplosionLight',,, ScriptedP.Location);
				Spawn(class'EllipseEffect',,, ScriptedP.Location);
				sphere = Spawn(class'SphereEffect',,, ScriptedP.Location);
				if (sphere != None)
					sphere.size = 4.0;
				ScriptedP.PlaySound(sound'Spark1', SLOT_None, 2.0,, 2048.0, 2.0);
			}
		}
		ScriptedP.ChangeAlly('Player', 0, True);
		// ScriptedP.ChangeAlly('FireWalls', 1, True);
		// ScriptedP.SetOrders('Attacking', );
	}
	
	// for (i=0; i<ArrayCount(spawnData); i++)
		// if ((spawnData[i].count == 0) && (spawnData[i].lastKilledTime == -1))
			// spawnData[i].lastKilledTime = Level.TimeSeconds - 8;	
						
	// count the number of monsters that are still alive
	foreach AllActors(class'ScriptedPawn', ScriptedP)
		for (i=0; i<ArrayCount(spawnData); i++)
			if ((ScriptedP.Class == spawnData[i].spawnClass) && (ScriptedP.Tag == spawnData[i].Tag))
				spawnData[i].count++;
	if (count == 0)
	{	
		for (i=2; i<ArrayCount(spawnData); i++)
		{
			if (spawnData[2].SpawnClass == None)
				spawnData[2].SpawnClass = class<ScriptedPawn>(DynamicLoadObject("TNMCharacters.FireWallAlpha",class'Class'));
			if ((spawnData[i].count == 0)/* && (Level.TimeSeconds - spawnData[i].lastKilledTime > 10)*/)
			{
				// Can't use GetSpawnPoint because Biomod/Shifter make the game crash.
				// SP = GetSpawnPoint(spawnData[i].spawnTag);
				foreach AllActors(class'SpawnPoint', SP, 'AlphaMasterSpawnPoint')
				{
					// SP2 = SP;
					// if (FRand() < 0.5)
						break;
				}
				if (SP != None)
				{
					ScriptedP = None;
					// spawn the actual monster
					if (i == 0 && flags.GetBool('DroneSpawner1_Destroyed'))
						{}
					else if (i == 1 && flags.GetBool('DroneSpawner2_Destroyed'))
						{}
					else
						ScriptedP = Spawn(spawnData[i].spawnClass, None, spawnData[i].Tag, SP.Location, SP.Rotation);
					if (ScriptedP != None)	// Transcended - Only do this per success, rather than per attempt
					{
						ScriptedP.InitializePawn();
						// ScriptedP.SetOrders('Patrolling', spawnData[i].orderTag);
						ScriptedP.SetOrders('Attacking', );
						ScriptedP.ChangeAlly('Player', -1, True);
						ScriptedP.ChangeAlly('FireWalls', 1, True);
						ScriptedP.bKeepWeaponDrawn = True;
						ScriptedP.bAlwaysPatrol = True;
						// if (tnmPawn(ScriptedP) != None)
							// tnmPawn(ScriptedP).bExtraSuspicious = True; // Turn head while walking
						spawnData[i].lastKilledTime = -1;
						
						// draw some light effects
						Spawn(class'ExplosionLight',,, SP.Location);
						Spawn(class'EllipseEffect',,, SP.Location);
						sphere = Spawn(class'SphereEffect',,, SP.Location);
						if (sphere != None)
							sphere.size = 4.0;

						// draw some electricity effects
						for (j=0; j<4; j++)
						{
							loc = vect(0,0,0);
							loc.Z = 32.0 + 32.0 * j;
							elec = Spawn(class'ElectricityEmitter',,, SP.Location + loc, rot(16384,0,0));
							if (elec != None)
							{
								elec.damageAmount = 0.0;
								elec.LifeSpan = 1.0;
								elec.randomAngle = 32768.0;
							}
						}

						// play a sound
						SP.PlaySound(sound'Spark1', SLOT_None, 2.0,, 2048.0, 2.0);
					}
				}
			}

			// reset the count for the next pass
			spawnData[i].count = 0;
		}
	}
	SendPM("PM_Firewall_Phase4");
}

function AlphaPhase4Start()
{
	local DeusExMover M;
	local ScriptedPawn S;
	local int i;
	local ScriptedPawn ScriptedP;
	local SpawnPoint SP, SP2;
	local SphereEffect sphere;
	local ElectricityEmitter elec;
	local Vector loc;
	local AlarmLight AL;
	local ParticleGenerator PG;
	
	foreach AllActors(class'ScriptedPawn', ScriptedP, 'FirewallAlpha')
	{
		SP = None;
		foreach AllActors(class'SpawnPoint', SP, 'AlphaSpawnPoint')
		{
			SP2 = SP;
			if (FRand() < 0.5)
				break;
		}
		if (SP == None)
			SP = SP2;
		if (SP != None)
		{
			if (ScriptedP.SetLocation(SP.Location))
			{
				ScriptedP.SetRotation(SP.Rotation);
				ScriptedP.SetRotation(Rotator(Player.Location - SP.Location));
					
				// draw some light effects
				Spawn(class'ExplosionLight',,, ScriptedP.Location);
				Spawn(class'EllipseEffect',,, ScriptedP.Location);
				sphere = Spawn(class'SphereEffect',,, ScriptedP.Location);
				if (sphere != None)
					sphere.size = 4.0;
				ScriptedP.PlaySound(sound'Spark1', SLOT_None, 2.0,, 2048.0, 2.0);
			}
		}
		ScriptedP.ChangeAlly('Player', -1, True);
		ScriptedP.ChangeAlly('FireWalls', 1, True);
		ScriptedP.SetOrders('Attacking', );
	}
	foreach AllActors(class'DeusExMover', M, 'VentingMovers1')
	{
		M.Trigger(None,None);
	}
	foreach AllActors(class'DeusExMover', M, 'VentingMovers2')
	{
		M.Trigger(None,None);
	}
	foreach AllActors(class'DeusExMover', M, 'VentingMovers3')
	{
		M.Trigger(None,None);
	}
	foreach AllActors(class'ParticleGenerator', PG, 'VentSteam1')
	{
		PG.Trigger(None,None);
	}
	foreach AllActors(class'ParticleGenerator', PG, 'VentSteam2')
	{
		PG.Trigger(None,None);
	}
	foreach AllActors(class'ParticleGenerator', PG, 'VentSteam3')
	{
		PG.Trigger(None,None);
	}
	foreach AllActors(class'AlarmLight', AL, 'AlarmLight1')
	{
		AL.Trigger(None,None);
	}
	foreach AllActors(class'AlarmLight', AL, 'AlarmLight2')
	{
		AL.Trigger(None,None);
	}
	foreach AllActors(class'AlarmLight', AL, 'AlarmLight3')
	{
		AL.Trigger(None,None);
	}

	flags.SetBool('Alpha_Phase4', true, , 23);
}

function AlphaStopGenerator(int i)
{
	local DeusExMover M;
	local ScriptedPawn ScriptedP;
	local AlarmLight AL;
	local int count, j;
	local SpawnPoint SP;
	local SphereEffect sphere;
	local ElectricityEmitter elec;
	local Vector loc;
	local ParticleGenerator PG;
	
	switch (i)
	{
		case 1:
			if (!flags.GetBool('Alpha_GeneratorDisabled1'))
			{
				foreach AllActors(class'DeusExMover', M, 'RespawnGen1')
				{
					M.Trigger(None,None);
				}
				foreach AllActors(class'AlarmLight', AL, 'AlarmLight1')
				{
					AL.Untrigger(None,None);
				}
				foreach AllActors(class'DeusExMover', M, 'VentingMovers1')
				{
					M.Trigger(None,None);
				}
				foreach AllActors(class'ParticleGenerator', PG, 'VentSteam1')
				{
					PG.Trigger(None,None);
				}
			}
			flags.SetBool('Alpha_GeneratorDisabled1', true, , 23);
			break;
		case 2:
			if (!flags.GetBool('Alpha_GeneratorDisabled2'))
			{
				foreach AllActors(class'DeusExMover', M, 'RespawnGen2')
				{
					M.Trigger(None,None);
				}
				foreach AllActors(class'AlarmLight', AL, 'AlarmLight2')
				{
					AL.Untrigger(None,None);
				}
				foreach AllActors(class'DeusExMover', M, 'VentingMovers2')
				{
					M.Trigger(None,None);
				}
				foreach AllActors(class'ParticleGenerator', PG, 'VentSteam2')
				{
					PG.Trigger(None,None);
				}
			}
			flags.SetBool('Alpha_GeneratorDisabled2', true, , 23);
			break;
		case 3:
			if (!flags.GetBool('Alpha_GeneratorDisabled3'))
			{
				foreach AllActors(class'DeusExMover', M, 'RespawnGen3')
				{
					M.Trigger(None,None);
				}
				foreach AllActors(class'AlarmLight', AL, 'AlarmLight3')
				{
					AL.Untrigger(None,None);
				}
				foreach AllActors(class'DeusExMover', M, 'VentingMovers3')
				{
					M.Trigger(None,None);
				}
				foreach AllActors(class'ParticleGenerator', PG, 'VentSteam3')
				{
					PG.Trigger(None,None);
				}
			}
			flags.SetBool('Alpha_GeneratorDisabled3', true, , 23);
			break;
	}
	
	if (flags.GetBool('Alpha_GeneratorDisabled1') && flags.GetBool('Alpha_GeneratorDisabled2') && flags.GetBool('Alpha_GeneratorDisabled3') && !flags.GetBool('Alpha_Defeated') )
	{
		flags.SetBool('Alpha_Phase3', false, , 23);
		flags.SetBool('Alpha_Phase4', false, , 23);
		flags.SetBool('Alpha_Defeated', true, , 23);
		foreach AllActors(class'DeusExMover', M, 'FinishDoorUnlock')
		{
			M.Trigger(None,None);
		}
		AddGoal('FirewallAlpha', strAlphaDefeated, true, true);
		SkillAward(500, strDebuggingAward);
		SendPM("PM_Firewall_Death");
	
		foreach AllActors(class'ScriptedPawn', ScriptedP, 'FirewallAlpha')
		{
			count++;
		}
		if (count == 0)
		{
			// Can't use GetSpawnPoint because Biomod/Shifter make the game crash.
			// SP = GetSpawnPoint(spawnData[i].spawnTag);
			foreach AllActors(class'SpawnPoint', SP, 'AlphaMasterSpawnPoint')
			{
				// SP2 = SP;
				// if (FRand() < 0.5)
					break;
			}
			if (SP != None)
			{
				ScriptedP = None;
				ScriptedP = Spawn(class<ScriptedPawn>(DynamicLoadObject("TNMCharacters.FireWallAlpha",class'Class')), None, 'FirewallAlpha', SP.Location, SP.Rotation);
				if (ScriptedP != None)	// Transcended - Only do this per success, rather than per attempt
				{
					ScriptedP.InitializePawn();
					// ScriptedP.SetOrders('Patrolling', spawnData[i].orderTag);
					// ScriptedP.SetOrders('Attacking', );
					// ScriptedP.ChangeAlly('Player', -1, True);
					ScriptedP.ChangeAlly('FireWalls', 1, True);
					ScriptedP.bKeepWeaponDrawn = True;
					ScriptedP.bAlwaysPatrol = True;
					
					// draw some light effects
					Spawn(class'ExplosionLight',,, SP.Location);
					Spawn(class'EllipseEffect',,, SP.Location);
					sphere = Spawn(class'SphereEffect',,, SP.Location);
					if (sphere != None)
						sphere.size = 4.0;

					// draw some electricity effects
					for (j=0; j<4; j++)
					{
						loc = vect(0,0,0);
						loc.Z = 32.0 + 32.0 * j;
						elec = Spawn(class'ElectricityEmitter',,, SP.Location + loc, rot(16384,0,0));
						if (elec != None)
						{
							elec.damageAmount = 0.0;
							elec.LifeSpan = 1.0;
							elec.randomAngle = 32768.0;
						}
					}

					// play a sound
					SP.PlaySound(sound'Spark1', SLOT_None, 2.0,, 2048.0, 2.0);
					
					ScriptedP.GoToState('AlphaFirewallDeathLong');
				}
			}
		}
		else
		{
			foreach AllActors(class'ScriptedPawn', ScriptedP, 'FirewallAlpha')
			{
				// ScriptedP.TakeDamage(ScriptedP.Health * 2, None, ScriptedP.Location, vect(0,0,0), 'EMP');
				ScriptedP.GoToState('AlphaFirewallDeathLong');
			}
		}
	
		foreach AllActors(class'ScriptedPawn', ScriptedP, 'FriendlyFirewall')
		{
			ScriptedP.LeaveWorld();
		}
	}
}

function AlphaKillphrased()
{
	local DeusExMover M;
	local ScriptedPawn ScriptedP;
	
	foreach AllActors(class'ScriptedPawn', ScriptedP, 'FirewallAlpha')
	{
		ScriptedP.GoToState('AlphaFirewallDeath');
	}
	foreach AllActors(class'DeusExMover', M, 'FinishDoorUnlock')
	{
		M.Trigger(None,None);
	}
	flags.SetBool('Alpha_Defeated', true, , 23);
	AddGoal('FirewallAlpha', strAlphaDefeated, true, true);
	SkillAward(500, strDebuggingAward);

	foreach AllActors(class'ScriptedPawn', ScriptedP, 'FriendlyFirewall')
	{
		ScriptedP.LeaveWorld();
	}
}

function DecrementTimers()
{
	DecrementTimer('TimerStarted_SpawnMidasChopper','Timer_SpawnMidasChopper');
	DecrementTimer('TimerStarted_RegistrationUCItem7','Timer_RegistrationUCItem7');
	DecrementTimer('TimerStarted_RegistrationUCItem14','Timer_RegistrationUCItem14');
	DecrementTimer('TimerStarted_RegistrationUCItem17','Timer_RegistrationUCItem17');
	DecrementTimer('TimerStarted_RegistrationUCItem22','Timer_RegistrationUCItem22');
	DecrementTimer('TimerStarted_RegistrationSecretUCItem7','Timer_RegistrationSecretUCItem7');
	DecrementTimer('TimerStarted_RegistrationSecretUCItem14','Timer_RegistrationSecretUCItem14');
	DecrementTimer('TimerStarted_RegistrationSecretUCItem17','Timer_RegistrationSecretUCItem17');
	DecrementTimer('TimerStarted_RegistrationSecretUCItem22','Timer_RegistrationSecretUCItem22');
}

function HandleTimers()
{
	if ( IsTimerDone('TimerStarted_SpawnMidasChopper','Timer_SpawnMidasChopper') )
	{
		if (!flags.GetBool('MS_MidasIncoming'))
			SpawnMidasChopper();
	}
	if ( IsTimerDone('TimerStarted_RegistrationUCItem7','Timer_RegistrationUCItem7') )
	{
		DeleteTimer('TimerStarted_RegistrationUCItem7','Timer_RegistrationUCItem7');
		DoBang();
		SpawnRegistrationUCItem();
		Electricity();
		DamageTrigger();
		PlayConstruct();
		Satellites();
	}

	if ( IsTimerDone('TimerStarted_RegistrationUCItem14','Timer_RegistrationUCItem14') )
	{
		DeleteTimer('TimerStarted_RegistrationUCItem14','Timer_RegistrationUCItem14');
		SolidifyRegistrationUCItem();
	}

	if ( IsTimerDone('TimerStarted_RegistrationUCItem17','Timer_RegistrationUCItem17') )
	{
		DeleteTimer('TimerStarted_RegistrationUCItem17','Timer_RegistrationUCItem17');
		// Satellites();
	}

	if ( IsTimerDone('TimerStarted_RegistrationUCItem22','Timer_RegistrationUCItem22') )
	{
		DeleteTimer('TimerStarted_RegistrationUCItem22','Timer_RegistrationUCItem22');
		DropRegistrationUCItem();
		ElectricityOff();
		DamageTrigger();
	}
	
	if ( IsTimerDone('TimerStarted_RegistrationSecretUCItem7','Timer_RegistrationSecretUCItem7') )
	{
		DeleteTimer('TimerStarted_RegistrationSecretUCItem7','Timer_RegistrationSecretUCItem7');
		DoSecretBang();
		SpawnRegistrationSecretUCItem();
		Electricity();
		DamageTrigger();
		PlaySecretConstruct();
		SecretSatellites();
	}

	if ( IsTimerDone('TimerStarted_RegistrationSecretUCItem14','Timer_RegistrationSecretUCItem14') )
	{
		DeleteTimer('TimerStarted_RegistrationSecretUCItem14','Timer_RegistrationSecretUCItem14');
		SolidifyRegistrationSecretUCItem();
	}

	if ( IsTimerDone('TimerStarted_RegistrationSecretUCItem17','Timer_RegistrationSecretUCItem17') )
	{
		DeleteTimer('TimerStarted_RegistrationSecretUCItem17','Timer_RegistrationSecretUCItem17');
		// Satellites();
	}

	if ( IsTimerDone('TimerStarted_RegistrationSecretUCItem22','Timer_RegistrationSecretUCItem22') )
	{
		DeleteTimer('TimerStarted_RegistrationSecretUCItem22','Timer_RegistrationSecretUCItem22');
		DropRegistrationSecretUCItem();
		ElectricityOff();
		DamageTrigger();
	}
	
	
	// Quad launcher day 2
	if ( IsTimerDone('TimerStarted_Quad7','Timer_Quad7') )
	{
		DeleteTimer('TimerStarted_Quad7','Timer_Quad7');
		QuadDoBang();
		SpawnLauncher();
		Electricity();
		DamageTrigger();
		QuadPlayConstruct();
	}

	if ( IsTimerDone('TimerStarted_Quad14','Timer_Quad14') )
	{
		DeleteTimer('TimerStarted_Quad14','Timer_Quad14');
		SolidifyLauncher();
	}

	if ( IsTimerDone('TimerStarted_Quad17','Timer_Quad17') )
	{
		DeleteTimer('TimerStarted_Quad17','Timer_Quad17');
		QuadSatellites();
	}

	if ( IsTimerDone('TimerStarted_Quad22','Timer_Quad22') )
	{
		DeleteTimer('TimerStarted_Quad22','Timer_Quad22');
		DropLauncher();
		ElectricityOff();
		DamageTrigger();
	}
}

function SetupExclusions()
{
	CountExclusions[0]='Dazza'; // Make the DXE mission not fail when Dazza leaves if you trigger the alarm
	CountExclusions[1]='DXEGameSpawnee'; // Robots summoned by the DXE game
	CountExclusions[2]='CivFanatic'; // 
	CountExclusions[3]='ConvoFanatic'; // 
	CountExclusions[4]='FrogCorpse'; // 
	CountExclusions[4]='DXIFanaticBoss'; // 
}
function CitadelExplosionEffects(bool bFragments)
{
	local float shakeTime, shakeRoll, shakeVert;
	local float size, explosionFreq;
	local int i;
	local Vector bobble, loc, endloc, HitLocation, HitNormal;
	local Actor HitActor;
	local HangingDecoration deco;
	// local Cart cart;
	local Barrel1 Barrel;
	local Rockchip frag;
	local LavaBubble frag2;
	local float volume;
	local DeusExMover segment;

	if (bFragments)
		explosionFreq = 0.33;
	else
		explosionFreq = 0.33;

	if (FRand() < explosionFreq)
	{
        foreach player.RadiusActors(Class'DeusExMover', segment, 768)
        {
			if (segment.Tag == 'BreakableSegment' && FRand() < 0.8)
			{
				segment.bBreakable=True;
                segment.BlowItUp(player);
			}
        }
		
		// pick a random explosion size and modify everything accordingly
		size = FRand();
		shakeTime = 0.5 + size;
		shakeRoll = 512.0 + 1024.0 * size;
		shakeVert = 8.0 + 16.0 * size;
		
		volume = 2.0;
		if (Player.IsInState('ConversatFion'))
			volume = 0.5;

		// play a sound
		if (size < 0.2)
			Player.PlaySound(Sound'SmallExplosion1', SLOT_None, volume,, 16384);
		else if (size < 0.4)
			Player.PlaySound(Sound'MediumExplosion1', SLOT_None, volume,, 16384);
		else if (size < 0.6)
			Player.PlaySound(Sound'MediumExplosion2', SLOT_None, volume,, 16384);
		else if (size < 0.8)
			Player.PlaySound(Sound'LargeExplosion1', SLOT_None, volume,, 16384);
		else
			Player.PlaySound(Sound'LargeExplosion2', SLOT_None, volume,, 16384);

		// shake the view
		Player.ShakeView(shakeTime, shakeRoll, shakeVert);

		// bobble the player around
		bobble = vect(300.0,300.0,200.0) + 500.0 * size * VRand();
		if (Player.IsInState('PlayerWalking') && Player.Physics != PHYS_Falling)
		{
			if (DeusExRootWindow(Player.rootWindow).hud.info != None && !DeusExRootWindow(Player.rootWindow).hud.info.bIsVisible)
				Player.Velocity += bobble;
		}

		// make all the hanging decorations sway randomly
		foreach AllActors(class'HangingDecoration', deco)
		{
			deco.CalculateHit(deco.Location + 10.0 * FRand() * VRand(), 0.5 * bobble);
			deco.bSwaying = True;
		}

		foreach AllActors(class'Barrel1', Barrel)
		{
			if (Barrel.bExplosive && Barrel.DistanceFromPlayer > Barrel.ExplosionRadius && Barrel.DistanceFromPlayer < Barrel.ExplosionRadius * 2)
				Barrel.TakeDamage(2, None, barrel.Location, vect(0,0,0), 'shot');
		}

		// make all the carts move randomly
		// foreach AllActors(class'Cart', cart)
			// cart.StartRolling(vect(100.0,100.0,0.0) + 200.0 * size * VRand());

		// have random metal fragments fall from the ceiling
		if (bFragments)
		{
			for (i=0; i<Int(size*20.0); i++)
			{
				loc = Player.Location + 256.0 * VRand();
				loc.Z = Player.Location.Z;
				endloc = loc;
				endloc.Z += 1024.0;
				HitActor = Trace(HitLocation, HitNormal, endloc, loc, False);
				if (HitActor == None)
					HitLocation = endloc;
				frag = Spawn(class'Rockchip',,, HitLocation);
				if (frag != None)
				{
					frag.CalcVelocity(vect(20000,0,0),256);
					frag.DrawScale = 0.5 + 2.0 * FRand();
					if (FRand() < 0.25)
						frag.bSmoking = True;
				}
				if (FRand() < 0.25)
				{
					frag2 = Spawn(class'LavaBubble',,, HitLocation);
					if (frag2 != None)
					{
						frag2.Velocity = VRand()*(256+FRand()*150.0+100.0 + VSize(Vect(22222,0,0))/80);
						frag2.DrawScale = 0.5 + 2.0 * FRand();
					}
				}
			}
		}
	}

	// make sure the player's zone has an alarm ambient sound
	// if (Player.HeadRegion.Zone != None)
	// {
		// Player.HeadRegion.Zone.AmbientSound = sound'Klaxon';
		// Player.HeadRegion.Zone.SoundRadius = 255;
		// Player.HeadRegion.Zone.SoundVolume = 255;
	// }
}

exec function CitadelRandomize()
{
	local WarpZoneInfo w;
	local int i;
	/*
	i = Rand(4);
	i += 65;
	
	if (!flags.GetBool('Citadel_LavaRaised'))
		flags.SetInt('CitadelRandomization', i, True, 23);
		
	if (flags.GetBool('Citadel_LavaRaised'))
	{
		while (i == flags.GetInt('CitadelRandomization'))
		{
			i = Rand(4);
			i += 65;
		}
	}
	
	ForEach AllActors(class'WarpZoneInfo', W)
	{
		
		if (W.Tag == 'CitadelEntrance')
		{
			W.OtherSideURL = "CitadelEntrance" $ Chr(i);
			W.ForceGenerate();
		}
		else if (W.Tag == 'CitadelExit')
		{
			W.OtherSideURL = "CitadelExit" $ Chr(i);
			W.ForceGenerate();
		}
	}*/
	
	i = Rand(2);
	i += 65;	
	
	ForEach AllActors(class'WarpZoneInfo', W)
	{
		if (W.ThisTag == 'Citadel1')
		{
			W.OtherSideURL = "Citadel1" $ Chr(i);
			W.ForceGenerate();
		}
		if (W.ThisTag == 'Citadel5')
		{
			W.OtherSideURL = "Citadel5" $ Chr(i);
			W.ForceGenerate();
		}
	}
	
	i = Rand(4);
	i += 65;
	
	if (!flags.GetBool('Citadel_LavaRaised'))
		flags.SetInt('CitadelRandomization', i, True, 23);
		
	if (flags.GetBool('Citadel_LavaRaised'))
	{
		while (i == flags.GetInt('CitadelRandomization'))
		{
			i = Rand(4);
			i += 65;
		}
	}
	
	ForEach AllActors(class'WarpZoneInfo', W)
	{
		if (W.ThisTag == 'Citadel2')
		{
			W.OtherSideURL = "Citadel2" $ Chr(i);
			W.ForceGenerate();
		}
		if (W.ThisTag == 'Citadel3')
		{
			W.OtherSideURL = "Citadel3" $ Chr(i);
			W.ForceGenerate();
		}
	}
	
	i = 65;
	if (FRand() >= 0.95)
		i++;
	ForEach AllActors(class'WarpZoneInfo', W)
	{
		if (W.ThisTag == 'Citadel4')
		{
			W.OtherSideURL = "Citadel4" $ Chr(i);
			W.ForceGenerate();
		}
	}
}

function SolidifyRegistrationUCItem()
{
	if(RegistrationUCspawn!=None && RegistrationUCspawn.Owner == None)
		RegistrationUCspawn.SetDefaultDisplayProperties();
//	RegistrationUCspawn.bBlockActors = true;
//	RegistrationUCspawn.bCollideActors = true;
}

function DropRegistrationUCItem()
{
	local actor a;

	if(RegistrationUCspawn==None)
	{
		foreach AllActors(Class'Actor',a,'AlphaEMPGrenSpawn')
			break;

		foreach AllActors(Class'Inventory',RegistrationUCspawn)
		{
			if(RegistrationUCspawn.IsA('WeaponQdRocket') && RegistrationUCspawn.Location == a.Location)
				break;
			RegistrationUCspawn=None;
		}
	}

	if(RegistrationUCspawn!=None && RegistrationUCspawn.Owner == None)
		RegistrationUCspawn.SetPhysics(PHYS_Falling);
}

function Satellites()
{
	local actor a;
	foreach allactors( class'actor', a, 'RegistrationSattGenerators')
		a.trigger(none, none);
}

function Electricity()
{
	local actor a;
	foreach allactors( class'actor', a, 'UCElectricityEmitter')
		a.trigger(none, none);
}

function ElectricityOff()
{
	local actor a;
	foreach allactors( class'actor', a, 'UCElectricityEmitter')
		a.untrigger(none, none);
}

function DoBang()
{
	local actor a;
	foreach allactors( class'actor', a , 'AlphaEMPGrenSpawn')
		Bang(a.location);
}

function Bang(vector location)
{
	local ExplosionLight light;
	local int i;
	local Rotator rot;
	local SphereEffect sphere;
	local ExplosionSmall expeffect;

	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, Location);
	if (light != None)
	{
		light.size = 8;
		light.LightHue = 128;
		light.LightSaturation = 96;
		light.LightEffect = LE_Shell;
	}

	// draw a cool light sphere
	sphere = Spawn(class'SphereEffect',,, Location);
	if (sphere != None)
	{
		sphere.size = 768.0 / 32.0;
	}
}

function StartSpawningRegistrationUCItem()
{
	Satellites();
	PlayWarmup();
	AddTimer('TimerStarted_RegistrationUCItem7','Timer_RegistrationUCItem7',7);
	AddTimer('TimerStarted_RegistrationUCItem14','Timer_RegistrationUCItem14',14);
	AddTimer('TimerStarted_RegistrationUCItem17','Timer_RegistrationUCItem17',17);
	AddTimer('TimerStarted_RegistrationUCItem22','Timer_RegistrationUCItem22',22);
}

function PlayWarmup()
{
	local actor a;
	foreach allactors( class'actor', a , 'AlphaEMPGrenSpawn')
		a.PlaySound(Sound'TNMSounds.OneShot.UCWarmup',SLOT_None,1.0);
}

function PlayConstruct()
{
	local actor a;
	foreach allactors( class'actor', a , 'AlphaEMPGrenSpawn')
		a.PlaySound(Sound'TNMSounds.OneShot.UCConstruct',SLOT_None,1.0);
}

function SpawnRegistrationUCItem()
{
	local rotator rot;
	rot.Pitch = -16384;
	rot.Yaw = 12288;
	RegistrationUCspawn = SpawnItemAt(GetRegistrationSpawnClass(),'AlphaEMPGrenSpawn', 'RegistrationUCspawnee');
	RegistrationUCspawn.SetDisplayProperties(STY_Translucent,texture, true, false);
//	RegistrationUCspawn.bBlockActors = False;
//	RegistrationUCspawn.bCollideActors = False;
	RegistrationUCspawn.SetPhysics(PHYS_None);
	// RegistrationUCspawn.SetRotation(rot);
}

function string GetRegistrationSpawnClass()
{
	local DeusExWeapon i;
	local inventory inv;
	local int count;
	local Ammo PossibleAmmo;
	local string spawnname;
	
	// If the player has no LAMs and none are availble to pick up spawn one
	foreach AllActors(class'DeusExWeapon', i)
	{
		if (i.IsA('WeaponTNMLAM'))
			count++;
	}
	
	if (count == 0)
		spawnname = "TNMItems.WeaponTNMLAM";
	
	// If the player has a LAM give them ammo they don't have
	if (spawnname == "")
	{
		for ( inv = player.inventory ; inv != none ; inv = inv.inventory)
		{
			if (DeusExWeapon(inv) != None && !inv.IsA('WeaponFireExting')) // Should probably check for grenades/PS20s too
			{
				if(DeusExWeapon(inv).AmmoNames[0] != None)
					PossibleAmmo = Ammo(Player.FindInventoryType(DeusExWeapon(inv).AmmoNames[0]));
				else
					PossibleAmmo = Ammo(Player.FindInventoryType(DeusExWeapon(inv).AmmoName));
				
				if (PossibleAmmo != None && PossibleAmmo.AmmoAmount == 0 && AmmoNone(PossibleAmmo) == None)
					spawnname = string(PossibleAmmo.Class);
			}
		}
	}
	
	// Player has ammo and a grenade
	if (spawnname == "")
		spawnname = "TNMItems.PlasticCoffee";
	
	// log("Registration spawnee:" @ spawnname);

	return spawnname;
}

function DamageTrigger()
{
	local actor a;
	foreach allactors( class'actor', a, 'UCDamageTrigger')
		a.trigger(none, none);
}



function SolidifyRegistrationSecretUCItem()
{
	if(RegistrationSecretUCspawnA!=None && RegistrationSecretUCspawnA.Owner == None)
		RegistrationSecretUCspawnA.SetDefaultDisplayProperties();
	if(RegistrationSecretUCspawnB!=None && RegistrationSecretUCspawnB.Owner == None)
		RegistrationSecretUCspawnB.SetDefaultDisplayProperties();
}

function DropRegistrationSecretUCItem()
{
	local actor a;

	if(RegistrationSecretUCspawnA!=None && RegistrationSecretUCspawnA.Owner == None)
		RegistrationSecretUCspawnA.SetPhysics(PHYS_Falling);

	if(RegistrationSecretUCspawnB!=None && RegistrationSecretUCspawnB.Owner == None)
		RegistrationSecretUCspawnB.SetPhysics(PHYS_Falling);
}

function SecretSatellites()
{
	local actor a;
	foreach allactors( class'actor', a, 'RegistrationSattGeneratorsA')
		a.trigger(none, none);
	foreach allactors( class'actor', a, 'RegistrationSattGeneratorsB')
		a.trigger(none, none);
}

function DoSecretBang()
{
	local actor a;
	foreach allactors( class'actor', a , 'RegistrationSattGeneratorsA')
		Bang(a.location);
	foreach allactors( class'actor', a , 'RegistrationSattGeneratorsB')
		Bang(a.location);
}

function StartSpawningRegistrationSecretUCItem()
{
	SecretSatellites();
	PlaySecretWarmup();
	AddTimer('TimerStarted_RegistrationSecretUCItem7','Timer_RegistrationSecretUCItem7',7);
	AddTimer('TimerStarted_RegistrationSecretUCItem14','Timer_RegistrationSecretUCItem14',14);
	AddTimer('TimerStarted_RegistrationSecretUCItem17','Timer_RegistrationSecretUCItem17',17);
	AddTimer('TimerStarted_RegistrationSecretUCItem22','Timer_RegistrationSecretUCItem22',22);
}

function PlaySecretWarmup()
{
	local actor a;
	foreach allactors( class'actor', a , 'FirewallUCA')
		a.PlaySound(Sound'TNMSounds.OneShot.UCWarmup',SLOT_None,1.0);
	foreach allactors( class'actor', a , 'FirewallUCB')
		a.PlaySound(Sound'TNMSounds.OneShot.UCWarmup',SLOT_None,1.0);
}

function PlaySecretConstruct()
{
	local actor a;
	foreach allactors( class'actor', a , 'FirewallUCA')
		a.PlaySound(Sound'TNMSounds.OneShot.UCConstruct',SLOT_None,1.0);
	foreach allactors( class'actor', a , 'FirewallUCB')
		a.PlaySound(Sound'TNMSounds.OneShot.UCConstruct',SLOT_None,1.0);
}

function SpawnRegistrationSecretUCItem()
{
	local rotator rot;
	rot.Pitch = -16384;
	rot.Yaw = 12288;
	
	// Invincible Trestkon firewall if you read the source code datacube in M20.
	if (flags.GetBool('NARC_Source'))
	{
		RegistrationSecretUCspawnA = SpawnItemAt("TNMItems.WeaponFirewallBeacon",'FirewallUCA',);
		RegistrationSecretUCspawnA.SetDisplayProperties(STY_Translucent,texture, true, false);
		RegistrationSecretUCspawnA.SetPhysics(PHYS_None);
		RegistrationSecretUCspawnB = SpawnItemAt("TNMItems.WeaponFirewallBeacon",'FirewallUCB',);
		RegistrationSecretUCspawnB.SetDisplayProperties(STY_Translucent,texture, true, false);
		RegistrationSecretUCspawnB.SetPhysics(PHYS_None);
	}	
	else
	{
		RegistrationSecretUCspawnA = SpawnItemAt("TNMItems.WeaponFirewallBeaconAlt",'FirewallUCA',);
		RegistrationSecretUCspawnA.SetDisplayProperties(STY_Translucent,texture, true, false);
		RegistrationSecretUCspawnA.SetPhysics(PHYS_None);
		RegistrationSecretUCspawnB = SpawnItemAt("TNMItems.WeaponFirewallBeaconAlt",'FirewallUCB',);
		RegistrationSecretUCspawnB.SetDisplayProperties(STY_Translucent,texture, true, false);
		RegistrationSecretUCspawnB.SetPhysics(PHYS_None);
	}
}


function StartSpawningQuadLauncher()
{
	QuadSatellites();
	QuadPlayWarmup();
	AddTimer('TimerStarted_Quad7','Timer_Quad7',7);
	AddTimer('TimerStarted_Quad14','Timer_Quad14',14);
	AddTimer('TimerStarted_Quad17','Timer_Quad17',17);
	AddTimer('TimerStarted_Quad22','Timer_Quad22',22);
}

function QuadPlayWarmup()
{
	local actor a;
	foreach allactors( class'actor', a , 'QuadLauncherSpawnPoint')
		a.PlaySound(Sound'TNMSounds.OneShot.UCWarmup',SLOT_None,1.0);
}

function QuadPlayConstruct()
{
	local actor a;
	foreach allactors( class'actor', a , 'QuadLauncherSpawnPoint')
		a.PlaySound(Sound'TNMSounds.OneShot.UCConstruct',SLOT_None,1.0);
}

function SpawnLauncher()
{
	local rotator rot;
	rot.Pitch = -16384;
	rot.Yaw = 12288;

	launcher = SpawnItemAt("TNMItems.WeaponQdRocket",'QuadLauncherSpawnPoint');
	launcher.SetDisplayProperties(STY_Translucent,texture, true, false);
//	launcher.bBlockActors = False;
//	launcher.bCollideActors = False;
	launcher.SetPhysics(PHYS_None);
	launcher.SetRotation(rot);
	Trestkon(Player).SetAchievement("achQuadRocket");
}

function SolidifyLauncher()
{
	if(launcher!=None && launcher.Owner == None)
		launcher.SetDefaultDisplayProperties();
//	launcher.bBlockActors = true;
//	launcher.bCollideActors = true;
}

function DropLauncher()
{
	local actor a;

	if(launcher==None)
	{
		foreach AllActors(Class'Actor',a,'QuadLauncherSpawnPoint')
			break;

		foreach AllActors(Class'Inventory',launcher)
		{
			if(launcher.IsA('WeaponQdRocket') && launcher.Location == a.Location)
				break;
			launcher=None;
		}
	}

	if(launcher!=None && launcher.Owner == None)
		launcher.SetPhysics(PHYS_Falling);
}

function QuadSatellites()
{
	local actor a;
	foreach allactors( class'actor', a, 'SatelliteGenerators')
		a.trigger(none, none);
}

function QuadDoBang()
{
	local actor a;
	foreach allactors( class'actor', a , 'QuadLauncherSpawnPoint')
		Bang(a.location);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     strAccompliceAward="Accomplice Award"
     strEscapeGoal="You have escaped the Slum district alive, now it's time to report back to base."
     strSurvivalAward="Surviving the Slums Award"
     strBuggedGoal="Having placed the spyware device on the old DXI servers, all you need to do now is return to Pimp Jojo to receive your reward."
     strBombersGoal="You have disposed of the men who bombed Sol's Bar. Alpha will appreciate this news."
     strMysteryGoal="You have disposed of some thugs, maybe you should check with Alpha to see what they were talking about."
     strMysteryGoal2="You have disposed of some thugs, maybe you should check around to see if anyone is offering a reward for this endeavour."
     strAYBABTUAward="FOR GREAT JUSTICE! Award"
     strPJDead="Pimp-Jojo is no longer in any state to complain if you help yourself to some of his items."
     strAlphaDead="After going through the effort of killing the bombers of Sol's Bar, you killed Alpha Operator. What did you do that for?"
     strAlphaDead2="You decided it was much easier to kill Alpha Operator than finding and killing the bombers."
     strAlphaDead3="You'll never find out exactly what the bombers did now that you killed Alpha Operator."
     strAlphaUnconscious="It will be unlikely that you discover the true purpose of the bombing with Alpha knocked out."
     strBombersDead="After helping Alpha with finding and killing the bombers, you helped give him a headache too."
     strBombersDead2="You decided not to search for the bombers of Sol's bar, and let Alpha know in the rudest way possible. He probably won't be pleased when he wakes up."
     strWinqumanDead="Apparently questioning witnesses was beneath you, so you killed Winquman."
     strWinqumanUnconscious="It will be difficult to tell Winquman the results of your investigation, what with him being unconscious and all."
     strWolfyDead="You should probably kiss those 2000 credits from Wolfy goodbye."
     strWolfyDeadEarly="Now you will never find out what mission Wolfy wanted to give you."
     strMarathonAward="Marathon Man Award"
     strSurviveGoal="The helipad gate is blown, now you just have to fend off the firewalls until Midashand gets here."
     strVavrekDead="Vavrek has tragically passed away. Perhaps you should search his body for clues."
     strVavrekRobbed="A note you found on Vavrek says Kevo-sama was kidnapped by DXO. Apparently their HQ is somewhere near Sol's. The note suggested Jackie may have a lead."
     strAirControlAward="Do-It-Yourself Air Control Award"
     strPosterAward="Poster Boy Award"
     strZPDeadPostAward="You killed ZP, but not before you got Scara's reward. Good thinking."
     strZPDeadPreAward="You killed ZP. You probably shouldn't tell Scara."
     strZPUnconPostAward="You knocked out ZP, but - wisely - not before you got Scara's reward."
     strZPUnconPreAward="ZP will soon wake up with quite the headache, but you probably shouldn't count on that reward from Scara."
     strMessengerAward="Don't Shoot the Messenger Award"
     strAssassinAward="Assassination Award"
     strAthenaDead="You have assassinated Athena. Return to the Llamas to claim your reward."
     strTemplarDead1="You decided to kill the wrong cult leader. You probably had a reason for it."
     strTemplarDead2="Did something happen down in DXI? Instead of listening to Dark Templar's proposal, you simply killed him."
     strTemplarKnockedOut1="Not interested in killing Beefman, you knocked Dark Templar down instead."
     strTemplarKnockedOut2="You will never know what Dark Templar wanted you to do because you decided to knock him out. You probably had your reasons."
     strBeefmanDead1="You decided to kill the wrong cult leader. You probably had a reason for it."
     strBeefmanDead2="You decided you'd much rather shoot Beefman than talk to him again."
     strBeefmanKnockedOut1="Unsure about the dangers waiting for you in the Goat Templae, you decided to knock down Beefman and call it a day."
     strBeefmanKnockedOut2="Unwilling to listen to Beefman a second longer, you decided to give him a strong headache instead."
     strTRMDead="You've killed TRM. Now it's time to free Kevo-sama."
     strRescueAward="Search and Rescue Award"
     strRealZPQuest="You'll never know what kind of reward the person claiming to be ZeroPresence could've got you."
     strKevoDead="Kevo-Sama is dead, take his flight codes and fly the helicopter yourself."
     strDebuggingAward="Debugger Award"
     strAlphaDefeated="The Alpha firewall has been defeated and is no longer a threat to ForumCity."
     spawnData(0)=(SpawnTag=SpydroneSpawn1,Tag=SpydroneSpawnee1,OrderTag=GSFPPA1,lastKilledTime=-1.000000)
     spawnData(1)=(SpawnTag=SpydroneSpawn2,Tag=SpydroneSpawnee2,OrderTag=GSFPPB1,lastKilledTime=-1.000000)
     spawnData(2)=(SpawnTag=AlphaSpawnPoint,Tag=FirewallAlpha,OrderTag=GSFPPC1,lastKilledTime=-1.000000)
     RemoteRole=ROLE_DumbProxy
}

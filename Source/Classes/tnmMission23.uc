class tnmMission23 extends TNMMissionScript;

#EXEC OBJ LOAD FILE=MoverSFX

var inventory abigamespawn;

var localized string strGoalChopper, strProgressAward, strProgressAwardDuo, strProgressAwardTrio;
var localized string strPyromanicAward, strBlackmailAward, strFriendAward, strHaoDead, strWolfGuyDead, strWolfGuyComplete, strWolfGuyMidway, strKillTreskStart, strKillTresk, strKillTreskDone, strTresktonAward;
// Following is transient but shouldn't matter
var int cerbTimer;	// Firing
var int cerbCounter;// Rotating harmlessly

// Fucking cutscenes! FUCKING CONVERSATION SYSTEM!
function StartConversationByName(Name conName, Actor conOwner, optional bool bAvoidState, optional bool bForcePlay)
{
	local bool bsuccess;
	bsuccess = player.StartConversationByName(conName, conOwner, bAvoidState, bForcePlay);
	if (!bsuccess)
		Log("Failed to play conversation");
}

function NVSPet_Charge(bool bHunting)
{
	local TNMRobot r;
	foreach allactors(class'TNMRobot',r)
		if(r.isa('nvshackerpet'))
			r.setpropertytext("bHunting",""$bHunting);
}

// Spawn the landed chopper and send the player a message after the intro
function LandedChopperAppear()
{
	local BlackHelicopter B;
	local containers c;
	local Spawnpoint SP;
	local PrecipitationZone precip;
	
	// foreach AllActors(class'Containers', C, 'SAMRocketCollision')
	// {
		// c.Destroy();
	// }
	foreach allactors(class'BlackHelicopter',B,)
	{
		if (B.Tag == 'ROFLCopterLanding' || B.Tag == 'IntroChopper1PilotScene3')
			B.Destroy();
		else if (B.Tag == 'ROFLCopter')
			B.EnterWorld();
	}

	SendPM("PM_InitialMessage");
	flags.SetBool('MS_ABIIntro_Done', True,, 24);
	foreach AllActors(class'Spawnpoint', SP, 'PlayerStart')
	{
		Player.SetLocation(SP.Location);		
		foreach AllActors(class'PrecipitationZone', precip)
		{
			if (precip.PrecipGen != None)
				precip.PrecipGen.Target = Player;
		}
		break;
	}
}

// Spawn the chopper wreck and send the player a message after the intro
function SpawnChopperWreck()
{
	local Vehicles V;
	local containers c;
	local Spawnpoint SP;
	local PrecipitationZone precip;
	
	// foreach AllActors(class'Containers', C, 'SAMRocketCollision')
	// {
		// c.Destroy();
	// }
	
	foreach allactors(class'Vehicles',V,)
	{
		if (V.Tag == 'ROFLCopterCrashing')
			V.Destroy();
		else if (V.Tag == 'ROFLCopterCrashed')
		{
			V.PlaySound(Sound'MediumExplosion1', SLOT_Talk, 0.75, True, 250000);
			V.EnterWorld();
		}
	}

	// Reduce the player's health by 75% but to a minimum of 10 in head and torso (and remove a leg and an arm)
	player = deusexplayer(getplayerpawn());
	Player.HealthHead = Max( 0.25 * Player.HealthHead, 10);
	Player.HealthTorso = Max( 0.25 * Player.HealthTorso, 10);
	Player.HealthLegLeft = 0.25 * Player.HealthLegLeft;
	Player.HealthLegRight = 0;
	Player.HealthArmLeft = 0;
	Player.HealthArmRight = 0.25 * Player.HealthArmRight;
	Player.GenerateTotalHealth();

	// Complete the goal from M22
	AddGoal('FlyTheChopper', strGoalChopper , true, true);
	flags.SetBool('MS_ABIIntro_Done', True,, 24);
	foreach AllActors(class'Spawnpoint', SP, 'PlayerStart')
	{
		Player.SetLocation(SP.Location);
		foreach AllActors(class'PrecipitationZone', precip)
		{
			// if (PrecipitationZone(Player.Region.Zone) == precip)
			if (precip.PrecipGen != None)
				precip.PrecipGen.Target = Player;
		}
		break;
	}
}

// Exploderate the helicopter with a function ripped straight from Area51 (mwahahah)
function ChopperSplode()
{
	local int count, i;
	local SphereEffect sphere;
	local MetalFragment frag;
	local AnimatedSprite explo;
	local Vector loc;
	local BlackHelicopter B;

	// Spawn the explosions and lots of debris
	foreach AllActors(class'BlackHelicopter', B, 'ROFLCopterCrashing')
	{
		// Large explosion sprites
		for (i=0; i<20; i++)
		{
			loc = B.Location + VRand() * B.CollisionHeight;
			if (FRand() < 0.25)
				explo = Spawn(class'ExplosionMedium',,, loc);
			else
				explo = Spawn(class'ExplosionLarge',,, loc);

				if (explo != None)
				explo.animSpeed += 0.4 * FRand();
		}

		// Metal fragments
		for (i=0; i<20; i++)
		{
			loc = B.Location + VRand() * B.CollisionHeight;
			frag = Spawn(class'MetalFragment',,, loc);
			if (frag != None)
			{
				frag.CalcVelocity(vect(40000,0,0),512);
				frag.DrawScale = 5.0 + 2.0 * FRand();
				frag.Skin = B.GetMeshTexture();
				frag.LifeSpan = 30.000000;
				if (FRand() < 0.5)
					frag.bSmoking = True;
			}
		}

		// Light sphere
		sphere = Spawn(class'SphereEffect',,, loc);
		if (sphere != None)
			sphere.size = 32.0;

		// Sound
		Player.PlaySound(Sound'LargeExplosion2', SLOT_None, 2.0,, 16384);
		// replaced with CutsceneShakeTrigger: Player.ShakeView(1.0, 1024.0, 32.0);
		B.Destroy();
		break;
	}

	// Make the wrecked chopper appear
	SpawnChopperWreck();
}

// Spawn the Firestaff if Midas drops it on the ground
function MidasDropStaff()
{
	SpawnItemAt("TNM.WeaponFireStaff" , 'FirestaffSpawnPoint');
}

// Make the hatch unusable because movers don't attach well to each other
function DockHatchDisable()
{
	local DeusExMover M;

	foreach allactors(Class'DeusExMover',M,'DockControlHatch')
	{
		M.bHighlight=false;
		M.bFrobbable=false;
	}
}

// ----------------------------------------------------------------------
// FirstFrame()
// 
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
	local tnmCameraPoint cam;
	local BlackHelicopter B;
	// local deusexplayer Player;
	local TNMPawn p;
	local TNMCarcass c;
	local Inventory item, nextItem;
	local SpawnPoint SP;
	local inventory inv;
	local tnmComputers comp;
	local int r;
	local string value;
	local keypad k;
	local TNMRobot bot;
	local deusexmover M;
	local TNMWeapon slicerKatana, roboRocket;
	local class<TNMWeapon> slicerKatanaClass;
	local SecurityCamera camera;
	local Actor act;
	local ProjectileSpawnPoint SAM;
	local HackableDevices hd;
	local DeusExPickup i;

	Super.FirstFrame();

	if (localURL == "23_ABIAPPROACH")
	{
		// Trigger the intro cutscene immediately
		if (!flags.GetBool('MS_ABIIntro_Played'))
		{
			// Different interpolation path when Trestkon's flying
			if (flags.GetBool('TrestkonFlying'))
			{
				foreach allactors(Class'BlackHelicopter',B)
				{
					if (B.Tag == 'IntroChopper1PilotScene3')
						B.Event = 'Scene2Pilot1PathTrest';
					else if (B.Tag == 'IntroChopper1PilotScene1')
						B.Event = 'Scene1Pilot1PathTrest';
				}
				foreach AllActors(class'ProjectileSpawnPoint', SAM, 'SAMRocketSpawn')
				{
					SAM.bProjectileHoming = True;
					SAM.ProjectileDamageMult = 0;
					// SAM.ProjectileSpeedMult = 7;
					SAM.ProjectileClass = class'TNM.RocketSAM';
				}
			}
			foreach allactors(Class'Actor',act,'Pilot1Scene1Disp')
			{
				act.Trigger(none,Player);
			}
			foreach allactors(Class'tnmCameraPoint',cam,'ABIIntroCam')
			{
				cam.Trigger(none,none);
			}			

			Flags.SetBool('MS_ABIIntro_Played',true, ,24);

			if(flags.GetBool('ALLIED_WC') && flags.GetBool('NVShackerPet_Unconscious') && !flags.GetBool('NVShackerPet_Dead'))
			{
				foreach AllActors(class'TNMRobot',bot,'NVShackerPet_WC')
				{
					bot.EnterWorld();
					bot.Tag='NVShackerPet';
				}
				flags.SetBool('NVShackerPet_ABI_WC',true,,24);
				flags.SetBool('NVShackerPet_Unconscious',false,,24);
				Trestkon(player).SetAchievement("achA2Reprogram");
			}

			if(flags.GetBool('ALLIED_PDX') && flags.GetBool('NVShacker_PDX') && flags.GetBool('NVShackerPet_Unconscious') && !flags.GetBool('NVShackerPet_Dead') && !flags.GetBool('NVShacker_Dead') && !flags.GetBool('NVShacker_Unconscious'))
			{
				foreach AllActors(class'TNMRobot',bot,'NVShackerPet_PDX')
				{
					bot.EnterWorld();
					bot.Tag='NVShackerPet';
				}
				flags.SetBool('NVShackerPet_ABI_PDX',true,,24);
				flags.SetBool('NVShackerPet_Unconscious',false,,24);
				Trestkon(player).SetAchievement("achA2Reprogram");
			}
		}

		// Change the chopper's conversation names if the player is WC-aligned - copied from TNMBindNameTrigger
		if (flags.GetBool('ALLIED_WC'))
		{
			foreach allactors(Class'BlackHelicopter',B,'ROFLCopter')
			{
				B.Bindname = "Midashand";
				B.FamiliarName = "Midashand";
				B.UnfamiliarName = "Midashand";
				B.ConBindEvents();

				// Tell conplay to kill anything using our old bindname
				player = DeusExPlayer(GetPlayerPawn());

				if ((player != None) && (player.conPlay != None))
				{
					player.conPlay.ActorDestroyed(B);
				}
			}
		}

		foreach AllActors(class'TNMWeapon', roboRocket)
		{
			if (roboRocket.IsA('WeaponTNMRobotRocket'))
				roboRocket.ShotTime = 0.4;
		}
	}
	else if (localURL == "23_ABIEXTERIOR")
	{
		// 1.0 map support
		// Trigger the intro cutscene immediately
		if (!flags.GetBool('MS_ABIIntro_Played'))
		{
			foreach allactors(Class'tnmCameraPoint',cam,'ABIIntroCam')
			{
				cam.Trigger(none,none);
			}

			Flags.SetBool('MS_ABIIntro_Played',true, ,24);

			if(flags.GetBool('ALLIED_WC') && flags.GetBool('NVShackerPet_Unconscious'))
			{
				foreach AllActors(class'tnmrobot',bot,'NVShackerPet_WC')
				{
					bot.EnterWorld();
					bot.Tag='NVShackerPet';
				}
				flags.SetBool('NVShackerPet_ABI_WC',true,,24);
				flags.SetBool('NVShackerPet_Unconscious',false,,24);
				Trestkon(player).SetAchievement("achA2Reprogram");
			}

			if(flags.GetBool('ALLIED_PDX') && flags.GetBool('NVShacker_PDX') && flags.GetBool('NVShackerPet_Unconscious'))
			{
				foreach AllActors(class'tnmrobot',bot,'NVShackerPet_PDX')
				{
					bot.EnterWorld();
					bot.Tag='NVShackerPet';
				}
				flags.SetBool('NVShackerPet_ABI_PDX',true,,24);
				flags.SetBool('NVShackerPet_Unconscious',false,,24);
				Trestkon(player).SetAchievement("achA2Reprogram");
			}

			// Change the chopper's conversation names if the player is WC-aligned - copied from TNMBindNameTrigger
			if (flags.GetBool('ALLIED_WC'))
			{
				foreach allactors(Class'BlackHelicopter',B,'ROFLCopter')
				{
					B.Bindname = "Midashand";
					B.FamiliarName = "Midashand";
					B.UnfamiliarName = "Midashand";
					B.ConBindEvents();

					// Tell conplay to kill anything using our old bindname
					player = DeusExPlayer(GetPlayerPawn());

					if ((player != None) && (player.conPlay != None))
					{
						player.conPlay.ActorDestroyed(B);
					}
				}
			}
		}
		
		// Spawn Ricemanu if the player is WorldCorp-aligned 
		if (flags.GetBool('ALLIED_WC'))
		{
			foreach allactors(class'TNMPawn',p,'ricemanu')
				p.EnterWorld();
		}
		// Remove Rice's laptop if the player is PDX-aligned
		else
		{
			foreach allactors(class'tnmComputers',comp,'RiceLaptop')
				comp.Destroy();
		}

		// Spawn Ricemanu's attackers after the attack occurs and give him some more health to survive longer
		if (flags.GetBool('QR_SUB_HelpRice'))
		{
			foreach allactors(class'TNMPawn',p,'RiceAttackers')
				p.EnterWorld();
			foreach allactors(class'TNMCarcass',c,'RiceAttackers')
				c.EnterWorld();

			foreach allactors(class'TNMPawn',p,'ricemanu')
			{
				p.HealthHead = Max(100, p.HealthHead);
				p.HealthTorso =  Max(200, p.HealthTorso);
				p.HealthLegLeft =  Max(125, p.HealthLegLeft);
				p.HealthLegRight =  Max(100, p.HealthLegRight);
				p.HealthArmLeft =  Max(250, p.HealthArmLeft);
				p.HealthArmRight =  Max(175, p.HealthArmRight);
				p.GenerateTotalHealth();

				// Make him stop crouching
				p.SetOrders('Standing',);
			}
		}

		// Remove Hao if he's been set free
		if (flags.GetBool('QC_SUB_FreeHao'))
		{
			foreach AllActors(Class'TNMPawn',p,'Hao')
				p.LeaveWorld();
		}
	}
	else if (localURL == "23_ABIINTERIOR")
	{
		// Randomize the code for the keypad to the archives
		r = Rand(5);

		switch ( r )
		{
			case 4: value = "1086"; break;
			case 3: value = "8569"; break;
			case 2: value = "5961"; break;
			case 1: value = "7674"; break;
			case 0: value = "3302"; break;
			default: value = "3302"; break;
		}
		foreach allactors(class'keypad',k, 'Archives_Keypad')
		{
			if (k.validcode == "1234")
				k.validCode = value;
		}

		// Send an update from Kashue or Scara
		SendPM("PM_EnterOffices");

		// Award some skillpoints for getting this far
		if (!flags.GetBool('MS_EnterOffices_AwardGiven'))
		{
			SkillAward(500, strProgressAward);
			flags.SetBool('MS_EnterOffices_AwardGiven',true,,24);
		}
	}
	else if (localURL == "23_ABIRUINS")
	{
		// Send an update from Kashue or Scara
		SendPM("PM_EnterRuins");
		
		if (!flags.GetBool('PM_EnterOffices_Played'))
			Trestkon(player).SetAchievement("achRuinsFast");

		// Award some skillpoints for getting this far
		if (!flags.GetBool('MS_ReachRuins_AwardGiven'))
		{
			SkillAward(500, strProgressAwardDuo);
			flags.SetBool('MS_ReachRuins_AwardGiven',true,,24);
		}

		// Determine whether to spawn ZP plus henchmen, Slicer, or none of the above 
		if (flags.GetBool('ALLIED_PDX'))
		{
			if (!flags.GetBool('Zero_Dead'))
			{
				foreach allactors(class'TNMPawn',p,)
				{
					if ((p.tag == 'ZeroPresence') || (p.tag == 'ZPHenchman'))
						p.EnterWorld();

					if (p.tag == 'ChapelGuard')
						p.LeaveWorld();
				}
				// Remove the corpses of Ricemanu's patrol because ZP was there to help them
				foreach allactors(class'TNMCarcass',c,'RicePlatoonCorpse')
				{
					c.LeaveWorld();
				}
				Flags.SetBool('ABIBossFight',true, ,24);
			}
		}
		else if (flags.GetBool('ALLIED_WC'))
		{
			if (!flags.GetBool('Slicer_Dead'))
			{
				foreach allactors(class'TNMPawn',p,)
				{
					if ((p.tag == 'Slicer') || (p.tag == 'SlicerHenchman'))
					{
						p.EnterWorld();
						
						// Swap Slicer's standard katana for his own if the player didn't take it.
						if (p.Tag == 'Slicer' && !flags.GetBool('HAS_SlicerKatana'))
						{
							slicerKatanaClass = class<TNMWeapon>( DynamicLoadObject( "TNMItems.WeaponKatanaSlicer", class'Class' ) );
							slicerKatana = Spawn( slicerKatanaClass,,,);
							if ( slicerKatana == None )
								Log("Failed to spawn class:"@slicerKatanaClass);
							else
							{
								for ( inv = p.inventory ; inv != none ; inv = inv.inventory)
								{
									if (String(inv.Class.Name) == "WeaponKatana")
									{
										inv.Destroy();
										break;
									}
								}
								slicerKatana.InitialState='Idle2';
								slicerKatana.GiveTo(p);
								slicerKatana.SetBase(p);
								p.SetupWeapon(true);
							}
						}
					}

					if (p.tag == 'ChapelGuard')
						p.LeaveWorld();
				}
				flags.SetBool('ABIBossFight', True,, 24);
			}
		}
		
		// From DXI MCR
		if (!flags.GetBool('fixedbots_Dead') && flags.GetBool('fixedbots_Disabled'))
		{
			// Reference point
			// foreach AllActors(class'HackableDevices', hd)
			// {
				// if (hd.Event == 'VaultAlarmLightDispatcher')
					// break;
			// }
			// if (hd != None)
			// {
				// If bot was disabled, place it in the place it was in M21.
				foreach AllActors(class'TNMRobot', bot, 'fixedbot')
				{
					bot.EMPHitpoints = 0;
					bot.GoToState('Disabled');
					bot.SetLocation(flags.GetVector('fixedbots_Location') + bot.HomeLoc);
					bot.SetRotation(flags.GetRotator('fixedbots_Rotation') + Rotator(bot.HomeRot));
				}
			// }
		}

		// THE FOLLOWING IS FOR WHEN THE PLAYER IS CAPTURED BY ZP OR SLICER

		if (flags.GetBool('MS_PlayerCaptured') && !flags.GetBool('MS_CaptureComplete'))
		{
			// Set the player to 25 health
			player = deusexplayer(getplayerpawn());
			Player.HealthHead = 25;
			Player.HealthTorso = 25;
			Player.HealthLegLeft = 25;
			Player.HealthLegRight = 25;
			Player.HealthArmLeft = 25;
			Player.HealthArmRight = 25;
			Player.GenerateTotalHealth();

			// Steal the player's inventory
			if (Player.Inventory != None)
			{
				item      = Player.Inventory;
				nextItem  = None;

				foreach AllActors(class'SpawnPoint', SP, 'player_inv')
				{
					// Find the next item we can process.
					while((item != None) && (item.IsA('NanoKeyRing') || (!item.bDisplayableInv)))
						item = item.Inventory;

					if (item != None)
					{
						if (TNMWeapon(item) != None)
							r = TNMWeapon(item).beltPos;
						nextItem = item.Inventory;
						Player.DeleteInventory(item);

						item.DropFrom(SP.Location);

						// restore any ammo amounts for a weapon to default
						if (item.IsA('Weapon') && !item.IsA('WeaponMine') && !item.IsA('WeaponPlasmaNade') && !item.IsA('WeaponTNMEMPGrenade') && !item.IsA('WeaponTNMGasGrenade') && !item.IsA('WeaponTNMLAM') && !item.IsA('WeaponTNMNanoVirusGrenade') && !item.IsA('WeaponTripBomb') && !item.IsA('WeaponMolBottle') && !item.IsA('WeaponFirewallBeacon') && (Weapon(item).AmmoType != None))
							Weapon(item).PickupAmmoCount = Weapon(item).Default.PickupAmmoCount;
						if (TNMWeapon(item) != None)
							TNMWeapon(item).lastBeltPos = r;	
						r = -1;
					}
					
					if (nextItem == None)
						break;	
					else
						item = nextItem;
				}
			}

			// Destroy the stuff in the dungeon armoury if the player hasn't picked it up
			foreach allactors(class'inventory',inv,'DungeonStorageBoon')
			{
				inv.Destroy();
			}

			// Remove the ABI guards...
			foreach allactors(class'TNMPawn',p,'DungeonGuard_ABI')
				p.LeaveWorld();

			foreach allactors(class'TNMCarcass',c,)
			{
				// ...or their corpses...
				if (c.tag == 'DungeonGuard_ABI')
					c.LeaveWorld();
				// ...and spawn their corpses somewhere else
				if (c.tag =='ABIDungeonGuardCorpse')
					c.EnterWorld();
			}

			// Spawn the proper guards
			if (flags.GetBool('ALLIED_PDX'))
			{
				foreach allactors(class'TNMPawn',p,)
				{
					// Spawn the WC prison guards
					if ((p.tag == 'DungeonGuard_WC')||(p.tag == 'CellGuard_WC'))
						p.EnterWorld();
					// Destroy the PDX guards so the convotrigger works
					if ((p.tag == 'DungeonGuard_PDX')||(p.tag == 'CellGuard_PDX'))
						p.Destroy();
					// Remove ZP
					if ((p.tag =='ZeroPresence')||(p.tag == 'ZPHenchman'))
						p.LeaveWorld();
				}

				//  In case ZP was killed or knocked out in the fight, remove his body
				foreach allactors(class'TNMCarcass',c,'ZeroPresence')
					c.LeaveWorld();
			}
			else if (flags.GetBool('ALLIED_WC'))
			{
				foreach allactors(class'TNMPawn',p,)
				{
					// Spawn the prison guards
					if ((p.tag == 'DungeonGuard_PDX')||(p.tag == 'CellGuard_PDX'))
						p.EnterWorld();
					// Destroy the WC guards so the convotrigger works
					if ((p.tag == 'DungeonGuard_WC')||(p.tag == 'CellGuard_WC'))
						p.Destroy();
					// Remove Slicer
					if ((p.tag =='Slicer')||(p.tag == 'SlicerHenchman'))
						p.LeaveWorld();
				}

				//  In case Slicer was killed or knocked out in the fight, remove his body
				foreach allactors(class'TNMCarcass',c,'Slicer')
					c.LeaveWorld();
			}

			// Make the cell door highlight and frobbable
			foreach allactors(class'deusexmover', M, 'CellDoor')
			{
				M.bFrobbable = true;
				M.bHighlight = true;
			}

			sendPM("PM_PrisonCell");
			
			flags.SetBool('MS_CaptureComplete',true,,24);
		}
	}
	else if (localURL == "23_ABILABS")
	{
		// Send an update from Kashue or Scara
		SendPM("PM_EnterLabs");

		// Award some skillpoints for getting this far
		if (!flags.GetBool('MS_FindLabs_AwardGiven'))
		{
			SkillAward(750, strProgressAwardTrio);
			flags.SetBool('MS_FindLabs_AwardGiven',true,,24);
		}

		// Turn all WC personnel friendly if the player is WC-aligned 
		if (Flags.GetBool('Allied_WC'))
		{
			foreach allactors(class'TNMPawn',p,)
				if ((p.tag == 'WCCommando')||
					(p.tag == 'WCCommando02')||
					(p.tag == 'OfficeHallWC')||
					(p.tag == 'CubiclesWC')||
					(p.tag == 'ResearchHallWC')||
					(p.tag == 'Commando01')||
					(p.tag == 'Commando02')||
					(p.tag == 'Commando03')||
					(p.tag == 'Commando04')||
					(p.tag == 'Commando05')||
					(p.tag == 'LoadingBayWC')||
					(p.tag == 'MIB')||
					(p.IsA('WCCommando')))
					p.ChangeAlly('Player', 1.000000, false);

			foreach allactors(class'TNMRobot',bot,)
				if ((bot.tag == 'OfficeHallWC')||
					(bot.tag == 'LoadingBayWC')||
					(bot.tag == 'SecurityBot2WC')||
					(bot.tag == 'SecurityBot3WC')||
					(bot.IsA('SecurityBot2WC')))
					bot.ChangeAlly('Player', 1.000000, false);
					
			foreach allactors(class'SecurityCamera', camera, 'LoadingBayCamera')
				camera.bNoAlarm = True;
		}
	}
	else if (localURL == "23_SLIPGATE")
	{
		foreach allactors( class'DeusExPickup', i, 'SurvivorSet' )
		{
			i.bHidden = true;
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
	local DeusExMover Mover;
	local BlackHelicopter B;
	
	if (localURL == "23_ABIRUINS")
	{
		foreach AllActors(class'DeusExMover', Mover)
		{
			if (Mover.Tag == 'OuterDoor00')
			{
				Mover.InterpolateTo(0,0);  // Instantly go back to closed position
				Mover.Enable( 'Trigger' ); // Allow us to instantly reopen it.
			}
		}
	}
	else if (localURL == "23_ABILABS")
	{
		foreach AllActors(class'DeusExMover', Mover)
		{
			if (Mover.Tag == 'OuterDoor00')
			{
				Mover.InterpolateTo(0,0);  // Instantly go back to closed position
				Mover.Enable( 'Trigger' ); // Allow us to instantly reopen it.
			}
		}
	}
	else if (localURL == "23_ABIAPPROACH")
	{
		foreach allactors(class'BlackHelicopter',B,)
		{
			if (B.Tag == 'ROFLCopter')
				B.LeaveWorld();
		}
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
	local TNMPawn p;
	local TNMRobot r;
	local robot rob;
	local pawn playerkiller;
	local actor act;
	local bool found;
	local securitycamera cam;
	local BeamTrigger B;
	local StaringMover cerb, SAM;
	local PrecipitationZone precip;
	local TrestkonDummy dummy;
	local DeusExMover M;
	local WarpZoneInfo warp;
	local Treskton Tresk;
	local actor a;

	super.Timer();

	if (localURL == "23_ABIINTERIOR")
	{
		// Handle completion of Scara's side mission
		if (flags.GetBool('ALLIED_WC') && !flags.GetBool('PM_ScaraTorchArchive_Played') && !flags.GetBool('MS_GatherInfo_AwardGiven'))
		{
			foreach AllActors(Class'Actor',act,'FireStarter')
			{
				found=true;
				break;
			}
			if(!found)
			{
				SendPM("PM_ScaraTorchArchive");
				SkillAward(500, strPyromanicAward);
				flags.SetBool('MS_GatherInfo_AwardGiven',true,,24);
			}
		}

		// Award skillpoints for completion of Kashue's side mission
		if (flags.GetBool('ALLIED_PDX') && flags.GetBool('QC_SUB_FindABIBuildingPlans') && flags.GetBool('QC_SUB_FindABIEvidence') && !flags.GetBool('MS_GatherInfo_AwardGiven'))
		{
			SkillAward(500, strBlackmailAward);
			flags.SetBool('MS_GatherInfo_AwardGiven',true,,24);
		}
	}
	else if (localURL == "23_ABIAPPROACH")
	{
		if (PrecipitationZone(Player.Region.Zone) != None)
		{
			if (Trestkon(player).TCam != None)
			{
				PrecipitationZone(Player.Region.Zone).PrecipGen.Target = Trestkon(player).TCam;	// Set the snow to spawn at the camera
				PrecipitationZone(Player.Region.Zone).PrecipGen.Height = 0;						// Lower the spawn height to not have a delay
				Player.bDetectable = False;													// For AI
				if (!flags.GetBool('MS_ABIIntro_Done'))
				{
					Player.SetLocation(Trestkon(player).TCam.Location);						// Move the player so sound works
					Player.SetPhysics(PHYS_Interpolating);
					foreach AllActors(class'PrecipitationZone', precip)						// Because SetLocation bypasses ActorLeave/Enter
					{
						if (PrecipitationZone(Player.Region.Zone) != precip)
							if (precip.PrecipGen != None)
								precip.PrecipGen.TurnOff();
					}
				}
			}
			else
			{
				if (flags.GetBool('MS_ABIIntro_Done') && !flags.GetBool('MS_ABISnowReset'))
				{
					PrecipitationZone(Player.Region.Zone).PrecipGen.Target = player;
					PrecipitationZone(Player.Region.Zone).PrecipGen.Height = PrecipitationZone(Region.Zone).PrecipGen.Default.Height;
					Player.bDetectable = True;
					flags.SetBool('MS_ABISnowReset', True,, 24);
					Player.SetPhysics(PHYS_Falling);
				}
			}
		}
		
		if (!flags.GetBool('SnowWolvesDead'))
		{
			count = 0;
			foreach allactors(class'TNMPawn',p, 'SnowWolfThreat')
			{
				if (p.IsA('SnowWolf'))
				{
					count++;
					break;
				}
			}
			if (count == 0)
			{
				flags.SetBool('SnowWolvesDead',true,,24);
				if (!flags.GetBool('MS_WolfGuy_GoalClosed') && flags.GetBool('QR_SUB_SnowWolves'))
					AddGoal( 'SnowWolves', strWolfGuyMidway , false, false);
			}
		}
		
		// If WolfGuy dies, complete the goal for his mission if the player got it
		if (flags.GetBool('WolfGuy_Dead') && flags.GetBool('QR_SUB_SnowWolves') && !flags.GetBool('QC_SUB_SnowWolves') && !flags.GetBool('MS_WolfGuy_GoalClosed'))
		{
			AddGoal( 'SnowWolves', strWolfGuyDead , false, true);
			flags.SetBool('MS_WolfGuy_GoalClosed',true,,24);
		}
		
		if (flags.GetBool('QC_SUB_SnowWolves') && !flags.GetBool('MS_WolfGuy_VoucherAdded'))
		{
			player.flagbase.SetInt('ABI_VoucherUses', player.flagbase.GetInt('ABI_VoucherUses')+1, True, 25); // Replace 2nd value with number of voucher uses the player gets
			AddGoal( 'SnowWolves', strWolfGuyComplete , false, true);
			flags.SetBool('MS_WolfGuy_VoucherAdded',true,,24);
		}
		
		if (cerbTimer == 0 && (flags.GetBool('ABIOnBridge') || flags.GetBool('ABIOnBridge2') || flags.GetBool('ABIOnBridge3')) && Player.bDetectable && !flags.GetBool('ABIArtyGuy_Dead') && !flags.GetBool('ABIArtyGuy_Unconscious'))
		{
			if (flags.GetBool('ABIOnBridge'))
				CerbFireBridge();
			else if (flags.GetBool('ABIOnBridge2'))
				CerbFireBridge2();
			else if (flags.GetBool('ABIOnBridge3'))
				CerbFireBridge3();
			cerbTimer++;
		}
		else if (cerbTimer != 0)
		{
			cerbTimer++;
			if (cerbTimer >= 10)
				cerbTimer = 0;
		}
		
		foreach allactors( class'StaringMover', SAM, 'IdleSAM')
		{
			if (SAM.Rotation == SAM.DesiredRotation)
			{
				if (cerbCounter == 0)
				{
					SAM.AmbientSound = None;
					// SAM.PlaySound(Sound'MoverSFX.Pneumatic1Close');
				}
				cerbCounter++;
			}
				
			if (cerbCounter >= 3)
			{
				// SAM.AmbientSound = Sound'MoverSFX.Pneumatic1Move';
				SAM.DesiredRotation.Yaw = 23000 + Rand(14000);
				if (SAM.ChildMover != None)
				{
					SAM.ChildMover.DesiredRotation = SAM.DesiredRotation;
					// SAM.ChildMover.DesiredRotation.Pitch = 4096 - Rand(4096);
				}
				cerbCounter = 0;
			}
		}

		// Autosave at the start of the mission
		if (!flags.GetBool('Autosaved_ABI'))
		{
			trestkon(getplayerpawn()).autosave(true, 23);
			// if (trestkon(getplayerpawn()).autosave(true))
				// flags.SetBool('Autosaved_ABI',true,,24);
		}
	}
	else if (localURL == "23_ABIEXTERIOR")
	{
		found = false;
		foreach allactors( class'BeamTrigger', B, 'FactoryLasers')
		{
			found = true;
		}
		if ( !found )
			flags.SetBool('Hao_LasersDisabled', True,,24);
			
		
		foreach allactors( class'StaringMover', Cerb, 'Cerberus')
		{
			if (Cerb.Rotation == Cerb.DesiredRotation)
			{
				if (cerbCounter == 0)
				{
					cerb.AmbientSound = None;
					cerb.PlaySound(Sound'MoverSFX.Pneumatic1Close');
				}
				cerbCounter++;
			}
				
			if (cerbCounter >= 3)
			{
				cerb.AmbientSound = Sound'MoverSFX.Pneumatic1Move';
				Cerb.DesiredRotation.Yaw = Rand(32767) + Rand(32767); // Rand is limited to 2^15
				if (Cerb.ChildMover != None)
				{
					Cerb.ChildMover.DesiredRotation = Cerb.DesiredRotation;
					Cerb.ChildMover.DesiredRotation.Pitch = 4096 - Rand(4096);
				}
				cerbCounter = 0;
			}
		}

		// Award some skillpoints for saving Hao
		if (flags.GetBool('QC_SUB_FreeHao') && !flags.GetBool('MS_FreeHao_AwardGiven'))
		{
			SkillAward(250, strFriendAward);
			flags.SetBool('MS_FreeHao_AwardGiven',true,,24);
			Trestkon(player).SetAchievement("achHao");
		}

		// Play a datalink message if Ricemanu is killed 
		if (flags.GetBool('Ricemanu_Dead') && flags.GetBool('QR_SUB_HelpRice'))
			SendPM("PM_RiceDies");

		// If Hao dies, complete the goal for Hao's mission if the player got it
		if (flags.GetBool('Hao_Dead') && flags.GetBool('QR_SUB_FreeHao') && !flags.GetBool('QC_SUB_FreeHao') && !flags.GetBool('MS_Hao_GoalClosed'))
		{
			AddGoal( 'FreeHao', strHaoDead , false, true);
			flags.SetBool('MS_Hao_GoalClosed',true,,24);
		}

		cam=None; //just to be explicit

		//check if the three cameras are destroyed or off
		foreach AllActors(class'securitycamera',cam,'FactoryMainDoorCam')
		{
			if(!cam.bActive)
				cam=None;
			break;
		}

		if(cam==None)
			foreach AllActors(class'securitycamera',cam,'FactoryMainRoomCam')
			{
				if(!cam.bActive)
					cam=None;
				break;
			}

		if(cam==None)
			foreach AllActors(class'securitycamera',cam,'FactoryTunnelCam')
			{
				if(!cam.bActive)
					cam=None;
				break;
			}

		flags.SetBool('Hao_CamerasDisabled',cam==None,,24);

		// Autosave at the start of the mission
		// if (!flags.GetBool('Autosaved_ABI'))
		// {
			// trestkon(getplayerpawn()).autosave(true, 23);
			// // if (trestkon(getplayerpawn()).autosave(true))
				// // flags.SetBool('Autosaved_ABI',true,,24);
		// }
	}
	else if (localURL == "23_ABIRUINS")
	{
		playerkiller = tnmgameinfo(level.game).playerkiller;

		// If ZP or Slicer kills the player, move the player to the prison cell and set the up the captivity sequence
		if (Player.IsInState('Dying') && flags.GetBool('MS_ABIBossTauntSent') && !flags.GetBool('MS_PlayerCaptured') && playerkiller != None)
		{
			if ((playerkiller.Tag == 'ZeroPresence') ||
			    (playerkiller.Tag == 'ZPHenchman') ||
			    (playerkiller.Tag == 'Slicer') ||
			    (playerkiller.Tag == 'SlicerHenchman'))
			{
				flags.SetBool('MS_PlayerCaptured', True,, 0);
				if (flags.GetBool('ALLIED_PDX'))
					Trestkon(player).SetAchievement("achZPCapture");
				else
					Trestkon(player).SetAchievement("achSlicerCapture");

				Level.Game.SendPlayer(Player, "23_ABIRuins#PlayerCellSpawnPoint");
			}
		}
		
		if ((flags.GetBool('Treskton_Dead') || flags.GetBool('Treskton_Unconscious')) && (flags.GetBool('TresktonMirror1_Dead') || flags.GetBool('TresktonMirror1_Unconscious')) && (flags.GetBool('TresktonMirror2_Dead') || flags.GetBool('TresktonMirror2_Unconscious')) && (flags.GetBool('TresktonMirror3_Dead') || flags.GetBool('TresktonMirror3_Unconscious')) && !flags.GetBool('MS_MirrorTresksKilled'))
		{
			foreach AllActors(class'TrestkonDummy', dummy)
			{
				// dummy.bInvincible = False;
				dummy.Destroy();
			}
			
			foreach AllActors(class'DeusExMover', M, 'TresktShield')
			{
				M.InterpolateTo(1,0);  // Instantly go to 2nd keyframe.
			}
	
			foreach AllActors(class'Treskton', Tresk, 'TreskReal')
			{
				Tresk.EnterWorld();
				Tresk.InitializeInventory();
				Tresk.TNMPAM.activateaugs(true,true);
			}
			AddGoal('KillTresk', strKillTresk, false, false);
			
			flags.SetBool('MS_MirrorTresksKilled', True,, 24);
		}
		
		if (flags.GetBool('MS_MirrorTresksKilled') && flags.GetBool('TresktonReal_Dead') && !flags.GetBool('MS_MirrorDummyKilled'))
		{
			// count=0;
			// foreach AllActors(class'TrestkonDummy', dummy)
			// {
				// count++;
			// }
			// if (count == 0)
			// {
				flags.SetBool('MS_MirrorDummyKilled', True,, 24);
				Trestkon(player).SetAchievement("achTreskton");
				// Player.ClientMessage("Quest complete");
				SkillAward(250, strTresktonAward);
				AddGoal('KillTresk', strKillTreskDone, false, true);
				foreach AllActors(class'WarpZoneInfo', warp, 'TreskPortal')
				{
					warp.Trigger(None, None);
				}
			
				foreach AllActors(class'DeusExMover', M, 'RealmLockShield')
				{
					M.InterpolateTo(0,0);
				}
			// }
		}
	}
	else if (localURL == "23_ABILABS")
	{
		// 
		if (!flags.GetBool('ALLIED_Ryan') && (flags.GetBool('Ryan_Dead') || flags.GetBool('Hitman_Dead')))
		{
			foreach allactors( class'actor', a, 'RyanGoHostile')
				a.trigger(none, none);
			foreach allactors( class'actor', a, 'HitmenGoHostile')
				a.trigger(none, none);
		}
		
		// Turn all ABI personnel neutral if the player allies himself with Ryan 
		if (flags.GetBool('ALLIED_Ryan'))
		{
			foreach allactors(class'TNMPawn',p,)
			{
				if ((p.tag == 'ABIEliteGuard')||
					(p.tag == 'OfficeHallABI')||
					(p.tag == 'CubiclesABI')||
					(p.tag == 'LoadingBayABI'))
					p.ChangeAlly('Player', 0.000000, true);
			}

			foreach allactors(class'TNMRobot',r,)
			{
				if ((r.tag == 'OfficeHallABI')||
					(r.tag == 'LoadingBayABI')||
					(r.tag == 'ResearchHallABI')||
					(r.tag == 'SecurityBot2ABI')||
					(r.tag == 'MilitaryBotABI' ))
					r.ChangeAlly('Player', 0.000000, true);
			}

			foreach allactors(class'robot',rob,)
			{
				if ((rob.tag == 'SpiderBot')||
					(rob.tag == 'VentSpiderBot'))
					rob.ChangeAlly('Player', 0.000000, true);
			}
		}

		// Make note if the player manages to clear out the loading bay 
		if (flags.GetBool('Allied_WC') && !flags.GetBool('ClearedLoadingBay'))
		{
			count = 0;
			foreach allactors(class'TNMPawn',p,)
			{
				if ((p.tag == 'LoadingBayABI'))
				{
					count++;
					break;
				}
			}
			
			foreach allactors(class'TNMRobot',r,)
			{
				if ((r.tag == 'LoadingBayABI'))
				{
					if (!r.IsInState('Disabled'))
						count++;
					break;
				}
			}
			if (count == 0)
				SendPM("PM_ScaraClearLoadingBay");
		}
		
		// Create the ABI game item when the time is right
		if (flags.GetBool('MS_SpawnABIGameItem'))
		{
			flags.DeleteFlag('MS_SpawnABIGameItem', FLAG_Bool);

			StartSpawningABIGameItem();
		}
		
		if (!flags.GetBool('MS_achSlicerGhost') && flags.GetBool('Allied_WC') && !flags.GetBool('Slicer_Dead'))
		{
			Trestkon(player).SetAchievement("achSlicerGhost");
			flags.SetBool('MS_achSlicerGhost', True,, 24);
		}
		else if (!flags.GetBool('MS_achZPGhost') && flags.GetBool('Allied_PDX') && !flags.GetBool('Zero_Dead'))
		{
			Trestkon(player).SetAchievement("achZPGhost");
			flags.SetBool('MS_achZPGhost', True,, 24);
		}
		
		if (!flags.GetBool('MS_AchKillWCID') && flags.GetBool('AgentBrown_Dead') && flags.GetBool('AgentJones_Dead') && flags.GetBool('WCIDAgent_Dead')) // Final is Smith in ABI Labs
		{	
			Trestkon(player).SetAchievement("achWCID");
			flags.SetBool('MS_AchKillWCID', True,, 24);
		}
		
		if (!flags.GetBool('MS_AchABIStealth') && flags.GetBool('ABIShuttle_ReadyToLaunch') && !flags.GetBool('KilledABI'))
		{	
			Trestkon(player).SetAchievement("achABIStealth");
			flags.SetBool('MS_AchABIStealth', True,, 24);
		}
	}
}

// Spawn Treskton when the player frobs the mirror
function MirrorImage()
{
	local treskton t;
	local navigationpoint n;

	if (!flags.GetBool('MS_SpawnedTreskton'))
	{
		foreach allactors(class'navigationpoint',n,'TresktonSpawn')
			break;

		t=spawn(class'treskton',,,n.location,n.rotation);
		t.orders='Standing';
		t.tag='Treskton';
		fade(3.0,t,true);

		flags.SetBool('MS_SpawnedTreskton', True,, 24);
	}
}

function CheckRiceStatus()
{
	local trigger t;
	if(flags.GetBool('ALLIED_WC') && flags.GetBool('QR_SUB_HelpRice') && !flags.GetBool('QC_SUB_HelpRice'))
	{
		foreach allactors(class'trigger', t, 'PMFoundPassword')
		{
			t.destroy();
		}
	}
}

function RotateCineCerb()
{
	local StaringMover cerb;
	
	foreach allactors( class'StaringMover', Cerb, 'CerberusCine')
	{
		Cerb.DesiredRotation = Rot(0,0,0);
		Cerb.SoundRadius=255;
		cerb.AmbientSound = Sound'MoverSFX.Pneumatic1Move';
	}
	
	foreach allactors( class'StaringMover', Cerb, 'CerbBarrel')
	{
		Cerb.DesiredRotation = Rot(0,0,0);
	}
	
	// Player.PlaySound(Sound'TNMSounds.OneShot.ABIIntroCerb', SLOT_Talk, 0.75, True, 250000);
}

function AimCineCerb()
{
	local StaringMover cerb;
	local Dispatcher   disp;
	
	foreach allactors( class'StaringMover', Cerb, 'CerbBarrel')
	{
		Cerb.DesiredRotation = Rot(5000,0,0);
	}
	
	foreach allactors( class'Dispatcher', disp, 'CerbFireDispatch')
	{
		disp.Trigger(Player, Player);
	}
}

function FireCineCerb()
{
	local ProjectileSpawnPoint Cerb;
	local StaringMover cerb2;
	
	foreach AllActors(class'ProjectileSpawnPoint', Cerb, 'CineCerbSpawn')
	{
		Cerb.FireProjectile();
		// Player.PlaySound(sound'Plasma_Shot', SLOT_None, 5.0, True, 65535); // Global sound
	}
	
	foreach allactors( class'StaringMover', Cerb2, 'CerberusCine')
	{
		cerb.AmbientSound = None;
	}
}

function SAMFire()
{
	local ProjectileSpawnPoint SAM;
	
	foreach AllActors(class'ProjectileSpawnPoint', SAM, 'SAMRocketSpawn')
	{
		SAM.FireProjectile();
		Player.PlaySound(sound'RocketIgnite', SLOT_None, 5.0, True, 65535); // Global sound
	}
}

function CerbFire()
{
	local SpawnPoint SP;
	
	foreach AllActors(class'SpawnPoint', SP, 'CerbProjSpawn')
	{
		Spawn(Class'CerberusProjectile', None, , SP.Location, SP.Rotation);
	}
}

function CerbFire2()
{
	local SpawnPoint SP;
	
	foreach AllActors(class'SpawnPoint', SP, 'CerbProjSpawn2')
	{
		Spawn(Class'CerberusProjectile', None, , SP.Location, SP.Rotation);
	}
}

function CerbFireBridge()
{
	local SpawnPoint SP;
	local int i;
	
	foreach AllActors(class'SpawnPoint', SP, 'CerbProjSpawnBridge')
	{
		if (i == 0)
			SP.PlaySound(sound'Plasma_Shot', SLOT_None, 5.0, True, 65535); // Global sound
		i++;
		Spawn(Class'CerberusProjectile', None, , SP.Location, SP.Rotation);
	}
}

function CerbFireBridge2()
{
	local SpawnPoint SP;
	local int i;
	
	foreach AllActors(class'SpawnPoint', SP, 'CerbProjSpawnBridge2')
	{
		if (i == 0)
			SP.PlaySound(sound'Plasma_Shot', SLOT_None, 5.0, True, 65535); // Global sound
		i++;
		Spawn(Class'CerberusProjectile', None, , SP.Location, SP.Rotation);
	}
}

function CerbFireBridge3()
{
	local SpawnPoint SP;
	local int i;
	
	foreach AllActors(class'SpawnPoint', SP, 'CerbProjSpawnBridge3')
	{
		if (i == 0)
			SP.PlaySound(sound'Plasma_Shot', SLOT_None, 5.0, True, 65535); // Global sound
		i++;
		Spawn(Class'CerberusProjectile', None, , SP.Location, SP.Rotation);
	}
}

function SpawnMirrorTresk1()
{
	local PatrolPoint SP;
	local Treskton Tresk;/*
	
	foreach AllActors(class'PatrolPoint', SP, 'Window1Spawn')
	{
		Tresk = Spawn(Class'Treskton', None, , SP.Location, SP.Rotation);
		// Tresk.SetOrders('RunningTo', 'Window2Point', True);
		Tresk.bMirrorPawn = True;
		Tresk.Orders = 'RunPatrolling';
		Tresk.OrderTag = 'Window1Point';
		Tresk.bImportant = True;
		Tresk.BindName = "TresktonMirror1";
		Tresk.ConBindEvents();
		// Tresk.InitializePawn(); //give inventory & alliances
		Tresk.SetAlliance('Tresk');
		Tresk.ChangeAlly('Player',-1,true);
		Tresk.ChangeAlly('MirrorPawns',1,true);
		Tresk.SetDistress(false);
		Tresk.ResetReactions();
		Tresk.ResetDestLoc();
	}*/
	
	foreach AllActors(class'Treskton', Tresk, 'Tresk1')
	{
		Tresk.EnterWorld();
		Tresk.InitializeInventory();
		Tresk.TNMPAM.activateaugs(true,true);
	}
}

function SpawnMirrorTresk2()
{
	local PatrolPoint SP;
	local Treskton Tresk;/*
	
	foreach AllActors(class'PatrolPoint', SP, 'Window2Spawn')
	{
		Tresk = Spawn(Class'Treskton', None, , SP.Location, SP.Rotation);
		// Tresk.SetOrders('RunningTo', 'Window2Point', True);
		Tresk.Orders = 'RunPatrolling';
		Tresk.OrderTag = 'Window2Point';
		Tresk.bImportant = True;
		Tresk.BindName = "TresktonMirror2";
		Tresk.ConBindEvents();
		// Tresk.InitializePawn(); //give inventory & alliances
		Tresk.SetAlliance('Tresk');
		Tresk.ChangeAlly('Player',-1,true);
		Tresk.ChangeAlly('MirrorPawns',1,true);
		Tresk.SetDistress(false);
		Tresk.ResetReactions();
		Tresk.ResetDestLoc();
	}*/
	
	foreach AllActors(class'Treskton', Tresk, 'Tresk2')
	{
		Tresk.EnterWorld();
		Tresk.InitializeInventory();
		Tresk.TNMPAM.activateaugs(true,true);
	}
}

function SpawnMirrorTresk3()
{
	local PatrolPoint SP;
	local Treskton Tresk;/*
	
	foreach AllActors(class'PatrolPoint', SP, 'Window3Spawn')
	{
		Tresk = Spawn(Class'Treskton', None, , SP.Location, SP.Rotation);
		// Tresk.SetOrders('RunningTo', 'Window2Point', True);
		Tresk.Orders = 'RunPatrolling';
		Tresk.OrderTag = 'Window3Point';
		Tresk.bImportant = True;
		Tresk.BindName = "TresktonMirror3";
		Tresk.ConBindEvents();
		// Tresk.InitializePawn(); //give inventory & alliances
		Tresk.SetAlliance('Tresk');
		Tresk.ChangeAlly('Player',-1,true);
		Tresk.ChangeAlly('MirrorPawns',1,true);
		Tresk.SetDistress(false);
		Tresk.ResetReactions();
		Tresk.ResetDestLoc();
	}*/
	
	foreach AllActors(class'Treskton', Tresk, 'Tresk3')
	{
		Tresk.EnterWorld();
		Tresk.InitializeInventory(); // Update with player's current inventory.
		Tresk.TNMPAM.activateaugs(true,true);
	}
}

function TreskAppear()
{
	local Treskton Tresk;
	
	foreach AllActors(class'Treskton', Tresk, 'TreskInitial')
	{
		Tresk.EnterWorld();
		Tresk.InitializeInventory(); // Update with player's current inventory.
		// No augs activated here because cloak
	}
	AddGoal('KillTresk', strKillTreskStart, false, false);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function HandleGameEvent(name scriptFunction)
{
	switch ( scriptFunction )
	{
		case 'LandedChopperAppear'	: LandedChopperAppear();	break;
		case 'ChopperSplode'		: ChopperSplode();			break;
		case 'SpawnChopperWreck'	: SpawnChopperWreck();		break;
		case 'MidasDropStaff'		: MidasDropStaff();			break;
		case 'DockHatchDisable'		: DockHatchDisable();		break;
		case 'NVSPet_Charge'		: NVSPet_Charge(true);		break;
		case 'NVSPet_DeCharge'		: NVSPet_Charge(false);		break;
		case 'MirrorImage'			: MirrorImage();			break;
		case 'CheckRiceStatus'		: CheckRiceStatus();		break;
		case 'RotateCineCerb'		: RotateCineCerb();			break;
		case 'AimCineCerb'			: AimCineCerb();			break;
		case 'FireCineCerb'			: FireCineCerb();			break;
		case 'SAMFire'				: SAMFire();				break;
		case 'CerbFire'				: CerbFire();				break;
		case 'CerbFire2'			: CerbFire2();				break;
		case 'WarpZoneRandomize'	: WarpZoneRandomize();		break;
		case 'SpawnMirrorTresk1'	: SpawnMirrorTresk1();		break;
		case 'SpawnMirrorTresk2'	: SpawnMirrorTresk2();		break;
		case 'SpawnMirrorTresk3'	: SpawnMirrorTresk3();		break;
		case 'TreskAppear'			: TreskAppear();			break;
		case 'RevealPowerups'		: RevealPowerups();			break;
		case 'GrayAmbush'			: GrayAmbush();				break;
		case 'ReverseMusic'			: ReverseMusic();			break;
		case 'UnReverseMusic'		: UnReverseMusic();			break;
		default: super.HandleGameEvent(scriptFunction);
	}
}

function WarpZoneRandomize()
{
	local WarpZoneInfo warp;
	local int rng;
	
	foreach AllActors(class'WarpZoneInfo', warp, 'RoomEntry')
	{
		rng = Rand(4);
		
		switch(rng)
		{
			case 0:
				Warp.OtherSideURL = "Room1";
				break;
			case 1:
				Warp.OtherSideURL = "Room2";
				break;
			case 2:
				Warp.OtherSideURL = "Room3";
				break;
			case 3:
				Warp.OtherSideURL = "None";
				break;
		}
		Warp.ForceGenerate();
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function PlayerDetected(name StateType, optional ScriptedPawn Triggerer)
{
	if (flags == None)
		return;
	//Stealth check
	if (LocalURL == "23_ABIEXTERIOR")
		flags.SetBool('NS_ABIExterior',true,,24);
	else if (LocalURL == "23_ABIINTERIOR")
		flags.SetBool('NS_ABIInterior',true,,24);
	else if (LocalURL == "23_ABIRUINS")
		flags.SetBool('NS_ABIRuins',true,,24);
	else if (LocalURL == "23_ABILABS")
		flags.SetBool('NS_ABILabs',true,,24);
}



function StartSpawningABIGameItem()
{
	Satellites();
	PlayWarmup();
	AddTimer('TimerStarted_ABIGameItem7','Timer_ABIGameItem7',7);
	AddTimer('TimerStarted_ABIGameItem14','Timer_ABIGameItem14',14);
	AddTimer('TimerStarted_ABIGameItem17','Timer_ABIGameItem17',17);
	AddTimer('TimerStarted_ABIGameItem22','Timer_ABIGameItem22',22);
}

function PlayWarmup()
{
	local actor a;
	foreach allactors( class'actor', a , 'ABIGunSpawn')
		a.PlaySound(Sound'TNMSounds.OneShot.UCWarmup',SLOT_None,1.0);
}

function PlayConstruct()
{
	local actor a;
	foreach allactors( class'actor', a , 'ABIGunSpawn')
		a.PlaySound(Sound'TNMSounds.OneShot.UCConstruct',SLOT_None,1.0);
}

function SpawnABIGameItem()
{
	local rotator rot;
	rot.Pitch = -16384;
	rot.Yaw = 12288;
	abigamespawn = SpawnItemAt(Trestkon(Player).GetPropertyText("ABISpawnItem"),'ABIGunSpawn');
	abigamespawn.SetDisplayProperties(STY_Translucent,texture, true, false);
//	abigamespawn.bBlockActors = False;
//	abigamespawn.bCollideActors = False;
	abigamespawn.SetPhysics(PHYS_None);
	// abigamespawn.SetRotation(rot);
	if (TNMWeapon(abigamespawn) != None)
	{
		TNMWeapon(abigamespawn).legendarychance = 1.5;
		TNMWeapon(abigamespawn).Attributes1 = 0;
		TNMWeapon(abigamespawn).Attributes2 = 0;
		TNMWeapon(abigamespawn).bAttributeapplied = false;
	}
}

function DamageTrigger()
{
	local actor a;
	foreach allactors( class'actor', a, 'UCDamageTrigger')
		a.trigger(none, none);
}

function SolidifyABIGameItem()
{
	if(abigamespawn!=None && abigamespawn.Owner == None)
		abigamespawn.SetDefaultDisplayProperties();
//	abigamespawn.bBlockActors = true;
//	abigamespawn.bCollideActors = true;
}

function DropABIGameItem()
{
	local actor a;

	if(abigamespawn==None)
	{
		foreach AllActors(Class'Actor',a,'ABIGunSpawn')
			break;

		foreach AllActors(Class'Inventory',abigamespawn)
		{
			if(/*abigamespawn.IsA('WeaponQdRocket') && */abigamespawn.Location == a.Location)
				break;
			abigamespawn=None;
		}
	}

	if(abigamespawn!=None && abigamespawn.Owner == None)
		abigamespawn.SetPhysics(PHYS_Falling);
}

function Satellites()
{
	local actor a;
	foreach allactors( class'actor', a, 'ABISattGenerators')
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
	foreach allactors( class'actor', a , 'ABIGunSpawn')
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

function DecrementTimers()
{
	DecrementTimer('TimerStarted_ABIGameItem7','Timer_ABIGameItem7');
	DecrementTimer('TimerStarted_ABIGameItem14','Timer_ABIGameItem14');
	DecrementTimer('TimerStarted_ABIGameItem17','Timer_ABIGameItem17');
	DecrementTimer('TimerStarted_ABIGameItem22','Timer_ABIGameItem22');
}

function HandleTimers()
{
	if ( IsTimerDone('TimerStarted_ABIGameItem7','Timer_ABIGameItem7') )
	{
		DeleteTimer('TimerStarted_ABIGameItem7','Timer_ABIGameItem7');
		DoBang();
		SpawnABIGameItem();
		Electricity();
		DamageTrigger();
		PlayConstruct();
	}

	if ( IsTimerDone('TimerStarted_ABIGameItem14','Timer_ABIGameItem14') )
	{
		DeleteTimer('TimerStarted_ABIGameItem14','Timer_ABIGameItem14');
		SolidifyABIGameItem();
	}

	if ( IsTimerDone('TimerStarted_ABIGameItem17','Timer_ABIGameItem17') )
	{
		DeleteTimer('TimerStarted_ABIGameItem17','Timer_ABIGameItem17');
		Satellites();
	}

	if ( IsTimerDone('TimerStarted_ABIGameItem22','Timer_ABIGameItem22') )
	{
		DeleteTimer('TimerStarted_ABIGameItem22','Timer_ABIGameItem22');
		DropABIGameItem();
		ElectricityOff();
		DamageTrigger();
	}
}

function PawnKilled(pawn killed, pawn killer)
{	
	if (ScriptedPawn(killed) != None && Trestkon(killer) != None)
	{		
		if (!scriptedpawn(killed).bStunned && killed.IsA('GenericABI'))
			flags.SetBool('KilledABI', true,,25);
	}
	
	Super.PawnKilled(killed, killer);
}

function RevealPowerups()
{
	local TNMDecoration a;
	local ScriptedPawn p;
	local TNMCarcass carc;
	local DeusExPickup i;
	
	foreach allactors( class'TNMDecoration', a )
	{
		if (a.IsA('QuadDamage') || a.IsA('RingofShadows'))
		{
			a.SetCollision( True, True, True );
			a.bHidden = False;			
			Bang(a.location);
			a.PlaySound(Sound'TNMSounds.OneShot.Splode05',SLOT_None,1.0,,2048);
		}
	}
	
	foreach allactors( class'ScriptedPawn', p, 'SurvivorSet' )
	{
		p.EnterWorld();
	}
	
	foreach allactors( class'TNMCarcass', carc, 'SurvivorSet' )
	{
		carc.EnterWorld();
	}
	
	foreach allactors( class'DeusExPickup', i, 'SurvivorSet' )
	{
		i.bHidden = False;
	}
}

function GrayAmbush()
{
	local ScriptedPawn a;
	foreach allactors( class'ScriptedPawn', a, 'AmbushGrays' )
	{
		a.EnterWorld();
	}
}

function ReverseMusic()
{
    local tnmoggmusicmanager ogg;
    foreach allactors(class'tnmoggmusicmanager', ogg)
    {
		if (!ogg.bReversed)
		{
			ogg.AmbientIntroOggFile="ABI_Underground_Ambient_Intro_Reverse.ogg";
			ogg.AmbientOggFile="ABI_Underground_Ambient_Reverse.ogg";
			ogg.CombatOggFile="ABI_Underground_Combat_Reverse.ogg";
			ogg.ConversationOggFile="ABI_Underground_Convo_Reverse.ogg";
			ogg.DeathOggFile="ABI_Underground_Death_Reverse.ogg";
			ogg.SyncSetCurrentOgg("ABI_Underground_Ambient_Intro_Reverse.ogg", "ABI_Underground_Ambient_Reverse.ogg", 0.0, MTRAN_FastFade);
		}
        ogg.bReversed = true;
    }
}

function UnReverseMusic()
{
    local tnmoggmusicmanager ogg;
    foreach allactors(class'tnmoggmusicmanager', ogg)
    {
        if (ogg.bReversed)
		{
			ogg.AmbientIntroOggFile="ABI_Underground_Ambient_Intro.ogg";
			ogg.AmbientOggFile="ABI_Underground_Ambient.ogg";
			ogg.CombatOggFile="ABI_Underground_Combat.ogg";
			ogg.ConversationOggFile="ABI_Underground_Convo.ogg";
			ogg.DeathOggFile="ABI_Underground_Death.ogg";
			ogg.SyncSetCurrentOgg("ABI_Underground_Ambient_Intro.ogg", "ABI_Underground_Ambient.ogg", 0.0, MTRAN_FastFade);
		}
		ogg.bReversed = false;
    }
}

defaultproperties
{
     strGoalChopper="You have (sort of) landed Kevo's chopper after its autopilot flew you to ABI."
     strProgressAward="Progress Bonus"
     strProgressAwardDuo="Another Progress Bonus!"
     strProgressAwardTrio="Yet Another Progress Bonus!!"
     strPyromanicAward="Pyromaniac of the Year Award"
     strBlackmailAward="Incriminating Info Award"
     strFriendAward="Friend to the Little People Award"
     strHaoDead="Hao is now free in an altogether more existential meaning of the word than he probably expected."
     strWolfGuyDead="The ABI guard is dead and you may never know what he had planned to give you."
     strWolfGuyComplete="You killed the snow wolves for the guard and received a voucher in return."
     strWolfGuyMidway="The wolves are cleared, inform the ABI guard."
     strKillTreskStart="You're stuck within Treskton's realm, destroy his mirror links to the other world."
     strKillTresk="With Treskton's alternate exits destroyed, now you just have to kill the source."
     strKillTreskDone="Treskton is vanquished from this realm and his own, with no risk of him taking your place."
     strTresktonAward="Mirror Mirror Award"
     RemoteRole=ROLE_DumbProxy
}

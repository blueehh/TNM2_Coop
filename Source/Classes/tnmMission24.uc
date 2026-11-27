//=============================================================================
// Mission24.
//=============================================================================
class tnmMission24 extends TNMMissionScript;

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

//you can't save during a conversation so the serialization isn't a problem
var tnmFire debuggerFire;

var localized string strDeusAward, strEffortAward;
var localized string strGeneral, strPhaser, strStalker, strIrradiator, strPlanetsider;

var int KlaxonID;
var SkyZoneInfo SkyBox;
var int lastYaw, yawCounter;

function Tick(float deltatime)
{
	if (SkyBox == None)
	{
		foreach AllActors (class'SkyZoneInfo', SkyBox)
			break;
	}
	
	Super.Tick(deltatime);
	
	// Increase skybox rotation rate to allow it to rotate on high FPS. (A framerate higher than the rotationrate prevents it from rotating)
	if (SkyBox != None)
	{
		if (lastYaw != -1)
		{
			if (lastYaw == SkyBox.Rotation.Yaw)
			{
				yawCounter++;
				if (yawCounter >= 30)
				{
					SkyBox.RotationRate.Yaw++;
					// yawCounter = 0;
				}
			}
			else
				yawCounter = 0;
		}
		
		lastYaw = SkyBox.Rotation.Yaw;
	}
}

function TrestAblaze()
{
	if (debuggerFire == None)
		debuggerFire = spawn(class'tnmFire', getplayerpawn());
}

function TrestPutOut()
{
	if (debuggerFire != None)
		debuggerFire.destroy();
}

function FirewallIFF()
{
	local ScriptedPawn SP;
	
	foreach AllActors(class'ScriptedPawn', SP, 'GSFirewallSpawnee3')
	{
		SP.ChangeAlly('Player', 1, True);
		SP.ChangeAlly('GameSpy', -1, True);
	}
}

function FirewallIFFLeet()
{
	local ScriptedPawn SP;
	
	foreach AllActors(class'ScriptedPawn', SP, 'GSFirewallSpawnee1')
	{
		SP.ChangeAlly('Player', 1, True);
		SP.ChangeAlly('GameSpy', -1, True);
	}
	
	foreach AllActors(class'ScriptedPawn', SP, 'GSFirewallSpawnee2')
	{
		SP.ChangeAlly('Player', 1, True);
		SP.ChangeAlly('GameSpy', -1, True);
	}
}

function checkNarcissusEnding()
{
	local int count;
	//check pc game time played too
	local float maxTimePlayed;
	local int gameIndex;
	local Trestkon t;
	local name scoreflag;

	count += int(flags.getbool('NARC_Source'));		// Downtown day 1
	count += int(flags.getbool('NARC_Tresk'));		// ABI Ruins
	count += int(flags.getbool('NARC_Kashue'));		// Corp day 1
	count += int(flags.getbool('NARC_Phas'));		// Phas Apartment
	count += int(flags.getbool('NARC_IRC'));		// DXI HQ
	count += int(flags.getbool('NARC_Testers'));	// WC HQ Floor 3
	count += int(flags.getbool('NARC_NoCult'));		// Goat City
	count += int(flags.getbool('NARC_Sewers'));		// Corp sewers
	count += int(flags.getbool('NARC_Despots'));	// Despot's
	flags.setbool('MS_NarcissusEndingAvailable', count >= 3,,25);

	t=trestkon(getplayerpawn());
	flags.setbool('bUnlockedBulletTime', t.bUnlockedBulletTime,,25);
	maxTimePlayed = t.mostPlayedGame().timePlayed;
	gameIndex = t.mostPlayedGame().gameId;

	switch(gameIndex)
	{
		case 0:
			scoreflag='GAMEFAV_Tetris';
			break;
		case 1:
			scoreflag='GAMEFAV_Pong';
			break;
		case 2:
			scoreflag='GAMEFAV_Breakout';
			break;
		case 3:
			scoreflag='GAMEFAV_LightsOut';
			break;
		case 4:
			scoreflag='GAMEFAV_TextGame';
			break;
	}

	if(scoreflag!='')
	{
		flags.setbool(scoreflag, true, , 25);
	}
}

function WoundJonasEgo()
{
	local DeusExRootWindow root;

	root = DeusExRootWindow(player.rootWindow);
	root.InvokeMenuScreen(Class'NarcissusWindow', false);
}

function SpawnDockedShuttle()
{
	local Vehicles V;
	local DeusExMover M;
	local Dispatcher D;

	// Spawn the space shuttle in the docking bay after the intro cutscene
	foreach allactors(class'Vehicles',V,'ABISpaceShip')
		V.EnterWorld();

	// Make sure the docking one is gone (in case we're skipping)
	foreach allactors(class'Vehicles',V,'ABIShuttleDocking')
		V.LeaveWorld();

	// Make sure the outer docking door is closed (again, in case we're skipping)
	foreach allactors(class'DeusExMover', M, 'DockDoor2Outer')
	{
		M.InterpolateTo(0,0);
		M.DelayTime=0.1;
		M.GotoState('TriggerToggle','Close');
	}

	// Open the inner docking bay doors after 3 seconds
	foreach AllActors(class'Dispatcher', D, 'FirstEntryDispatcher')
		D.Trigger(Self, Player);
}

// Give the player the Space Station map and send the PM
function DownloadSchematics()
{
	local DataVaultImage image1, image2, image3, image4;
	local class<DataVaultImage> imageclass1, imageclass2, imageclass3, imageclass4;

	imageclass1 = class<DataVaultImage>(DynamicLoadObject( "TNMDataVault.TNMDV_SS04" , class'class' ));
	imageclass2 = class<DataVaultImage>(DynamicLoadObject( "TNMDataVault.TNMDV_SS01" , class'class' ));
	imageclass3 = class<DataVaultImage>(DynamicLoadObject( "TNMDataVault.TNMDV_SS02" , class'class' ));
	imageclass4 = class<DataVaultImage>(DynamicLoadObject( "TNMDataVault.TNMDV_SS03" , class'class' ));

	image4 = spawn( imageclass4 );
	image4.frob(player, none);
	image3 = spawn( imageclass3 );
	image3.frob(player, none);
	image2 = spawn( imageclass2 );
	image2.frob(player, none);
	image1 = spawn( imageclass1 );
	image1.frob(player, none);

	flags.SetBool('QC_MAIN_DownloadSchematics',true,,);

	if (flags.GetBool('ALLIED_WC'))
		SendPM("PM_Scara_GotSchematics");
	else
		SendPM("PM_Kashue_GotSchematics");
}

// Toggle the air in the airlock and close/open the proper doors
function EngineeringAirlock(name airlock, name dis1, name dis2)
{
	local DeusExMover M;
	local Dispatcher D;

	// Toggle the doors in the correct order (Christ on a bike...)
	foreach allactors(class'DeusExMover', M, airlock)
	{
		if (M.keynum != 0)
		{
			// This dispatcher closes the outer door first, then opens the inner
			foreach AllActors(Class'Dispatcher', D, dis1)
				D.Trigger(Self, Player);
		}
		else
		{
			// This dispatcher closes the inner door first, then opens the outer
			foreach AllActors(Class'Dispatcher', D, dis2)
				D.Trigger(Self, Player);
		}
	}
}

// Toggle the air in the airlock and close/open the proper doors
function NewEngineeringAirlock(name airlockOpen, name airlockClose)
{
	local DeusExMover M;
	local Dispatcher D;

	// Toggle the doors in the correct order (Christ on a bike...)
	foreach allactors(class'DeusExMover', M)
	{
		if (M.Tag == airlockOpen && M.keynum == 0)
		{
			M.Trigger(None, None);
		}
		else if (M.Tag == airlockClose)
		{
			M.InterpolateTo(0,0.25);  // Instantly go back to closed position
			M.Enable( 'Trigger' ); // Allow us to instantly reopen it.
		}
	}	
}

// Toggle the air in the airlock and close/open the proper doors
function NewEngineeringAirlockCycle(name airlockOpen, name airlockClose, name dis1, name dis2)
{
	local DeusExMover M;
	local Dispatcher D;
	local bool bCycle1;
	
	if (flags.GetBool('M24_InAirlock'))
		return;
	
	flags.SetBool('M24_InAirlock',true,,25);

	foreach allactors(class'DeusExMover', M)
	{
		if (M.Tag == airlockOpen && M.keynum != 0)
		{
			bCycle1 = True;
			M.Trigger(None, None);
			break;
		}
	}	
	if (bCycle1)
	{
		foreach AllActors(Class'Dispatcher', D, dis1)
			D.Trigger(Self, Player);
	}
	else
	{
		foreach allactors(class'DeusExMover', M)
		{
			if (M.Tag == airlockClose && M.keynum != 0)
			{
				M.Trigger(None, None);
				break;
			}
		}
		foreach AllActors(Class'Dispatcher', D, dis2)
			D.Trigger(Self, Player);
	}
}


// Enable the oxygen in the cylinder and airlocks when the player turns both valves
function EnableAirPumps()
{
	local tnmzoneinfo Z;
	local oxygenzonetrigger O;

	foreach AllActors(class'oxygenzonetrigger',O)
	{
		// switch(O.tag) // ???
		// {
			// case 'EngineeringAirlock1Oxygen':
			// case 'EngineeringAirlock2Oxygen':
			// case 'EngineeringAirlock3Oxygen':
			// case 'EngineeringAirlock4Oxygen':
			// case 'EngineeringAirlock5Oxygen':
			// case 'EngineeringAirlock6Oxygen':
				O.Destroy();
		// }
	}

	foreach AllActors(class'tnmzoneinfo',Z)
	{
		// switch(Z.tag)
		// {
			// case 'EngineeringAirlock1':
			// case 'EngineeringAirlock2':
			// case 'EngineeringAirlock3':
			// case 'EngineeringAirlock4':
			// case 'EngineeringAirlock5':
			// case 'EngineeringAirlock6':
			// case 'GravCylinderZone':
				Z.bNoOxygen=false;
		// }
	}

	// Set a flag so we know what's up
	flags.SetBool('MS_SSAirPumpsEnabled',true,,25);
}

// Disable the LEET security bot as per an EMP grenade
function LEETRobotsDie()
{
	local Robot R;
	foreach AllActors(class'Robot',R,'LEETRobot')
		R.TakeDamage(1000, R, R.Location, vect(0,0,0), 'EMP');
}

// Disable the four annie plant spider-bots as per an EMP grenade
function AnnieSpiderbotsDie()
{
	local Robot S;
	foreach AllActors(class'Robot',S,'AnnieFarmSpiderBots')
		S.TakeDamage(1000, S, S.Location, vect(0,0,0), 'EMP');
}

// Disable the APG security bot as per an EMP grenade
function APGSecBotDie()
{
	local Robot R;
	foreach AllActors(class'Robot',R,'APGSecBot')
		R.TakeDamage(1000, R, R.Location, vect(0,0,0), 'EMP');
}

// Replace the briefing holograms with the GS logo
function HoloDisappear()
{
	local TNMPawn p;
	local TNMDecoration D;

	foreach AllActors(class'TNMPawn', p,)
	{
		if ((p.Tag == 'Scara_Hologram') || (p.Tag == 'KK_Hologram1'))
			p.LeaveWorld();
	}

	foreach AllActors(class'TNMDecoration', D, 'GSLogo1')
		D.bHidden = False;
}

// Replace KK's hologram with the GS logo
function KKDisappear()
{
	local TNMPawn p;
	local TNMDecoration D;

	foreach AllActors(class'TNMPawn', p,)
	{
		if ((p.Tag == 'KK_Hologram2')||(p.Tag == 'KK_Hologram'))
			p.LeaveWorld();
	}

	foreach AllActors(class'TNMDecoration', D,)
	{
		if ((D.Tag == 'GSLogo2')||(D.Tag == 'GSLogo3'))
			D.bHidden = False;
	}
}

// Replace Scara's hologram with the GS logo
function ScaraDisappear()
{
	local TNMPawn p;
	local TNMDecoration D;

	foreach AllActors(class'TNMPawn', p, 'Scara_Hologram')
		p.LeaveWorld();

	foreach AllActors(class'TNMDecoration', D, 'GSLogo3')
		D.bHidden = False;
}


// ----------------------------------------------------------------------
// FirstFrame()
// 
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
	local tnmCameraPoint cam;
	local Dispatcher D;
	local DeusExMover M;
	local TNMPawn p;
	local TNMRobot r;
	local TNMCarcass c;
	local Vehicles V;
	local SecurityCamera S;
	local TNMInformationDevices I;
	local LightSwitch L;
	local tnmComputerAPGPuzzle APG;
	local AugmentationUpgradeCannister U;
	local bool kyliekilled;
	local Computers ROFL;

	Super.FirstFrame();

	// If the player enters any other map after rescuing Diablo on SS02, send Kashue's PM
	if ((localURL != "24_SPACESTATION02") && flags.GetBool('MS_DDSafe'))
	{
		flags.SetBool('MS_DDSafe',false,,0);
		SendPM("PM_Kashue_DDSafe");
	}

	if (localURL == "24_SPACESTATION01")
	{
		checkNarcissusEnding();

		// Trigger the intro cutscene immediately
		if (!flags.GetBool('MS_SSIntro_Played'))
		{
			foreach allactors(Class'tnmCameraPoint',cam,'ShuttleIntroSequence')
			{
				cam.Trigger(none,none);
			}
			
			// Actual coward
			foreach AllActors(class'TNMPawn', p,)
			{
				if (p.Tag == 'Fargo')
					p.MinHealth = p.Health;
			}

			Flags.SetBool('MS_SSIntro_Played',true, ,25);
		}

		// Spawn KK or Scara for the briefing depending on alliance
		if (flags.GetBool('ALLIED_WC') && !flags.GetBool('Scara_Briefing_Played'))
		{
			foreach AllActors(class'TNMPawn', p, 'Scara_Hologram')
				p.EnterWorld();
		}
		else if (flags.GetBool('ALLIED_PDX') && !flags.GetBool('Kashue_Briefing_Played'))
		{
			foreach AllActors(class'TNMPawn', p, 'KK_Hologram1')
				p.EnterWorld();
		}

		// Spawn Kylie in the Interface room for the PDX ending
		if (!flags.GetBool('MS_SpawnedKylie') && !flags.GetBool('Kylie_Deleted') && flags.GetBool('QC_MAIN_DisableAnniePlants') && !flags.GetBool('QC_MAIN_DestroyLEETs'))
		{
			// First, spawn Kylie's ride
			foreach AllActors(class'Vehicles', V, 'KylieShuttle')
				V.EnterWorld();

			// Remove the aliens in and around the interface room...
			foreach AllActors(class'TNMPawn', p, 'InterfaceRoomAliens')
				p.LeaveWorld();

			// ...and the robots
			foreach AllActors(class'TNMRobot', r, 'InterfaceRoomBots')
				r.LeaveWorld();

			// Spawn the corpses of fallen aliens
			foreach AllActors(class'TNMCarcass', c, 'InterfaceRoomCorpses')
				c.EnterWorld();

			// And finally... spawn Kylie!
			if (flags.GetBool('Kylie_Dead'))
			{
				foreach AllActors(class'TNMPawn', p, 'Kylie_Dead')
					p.EnterWorld();					
				// flags.SetBool('Kylie_StillAlive', true,, 0); // Used for ABI ending.
			}
			else
				foreach AllActors(class'TNMPawn', p, 'Kylie')
					p.EnterWorld();

			// And turn off the camera so it doesn't get annoying
			foreach AllActors(class'SecurityCamera', S, 'AIModuleCam03')
				S.bActive = False;

			flags.SetBool('MS_SpawnedKylie', true,, 25);
		}

		// Spawn Kylie in the hangar for the ABI ending
		if (!flags.GetBool('MS_SpawnedKylie') && !flags.GetBool('Kylie_Deleted') && flags.GetBool('QC_MAIN_DestroyLEETs'))
		{
			// First, spawn Kylie's ride
			foreach AllActors(class'Vehicles', V, 'KylieShuttle')
				V.EnterWorld();

			foreach AllActors(class'DeusExMover', M,)
			{
				// Open the hangar with Kylie's shuttle
				if ((M.Tag == 'DockDoor1') && (M.keynum != 1))
				{
					foreach AllActors(class'Dispatcher', D, 'DockDoor1Dispatcher')
						D.Trigger(Self, Player);
				}
				// Close the hangar with the player's shuttle
				if ((M.Tag == 'DockDoor2') && (M.keynum != 0))
				{
					foreach AllActors(class'Dispatcher', D, 'DockDoor2Dispatcher')
						D.Trigger(Self, Player);
				}
			}

			// Remove the aliens in and around the hangar plus Fargo
			foreach AllActors(class'TNMPawn', p,)
			{
				if ((p.Tag == 'DockingAlien') || (p.Tag == 'HangarGuard01') || (p.Tag == 'Fargo'))
					p.LeaveWorld();
			}

			// ...and the robots
			foreach AllActors(class'TNMRobot', r, 'DockingBots')
				r.LeaveWorld();

			// Spawn the corpses of fallen aliens
			foreach AllActors(class'TNMCarcass', c, 'DockingCorpses')
				c.EnterWorld();

			// And finally... spawn Kylie!
			
			if (flags.GetBool('Kylie_Dead'))
			{
				foreach AllActors(class'TNMPawn', p, 'Kylie_Dock_Dead')
					p.EnterWorld();
				// flags.SetBool('Kylie_StillAlive', true,, 0); // Used for ABI ending.
			}
			else if (!flags.GetBool('Kylie_Dead'))
				foreach AllActors(class'TNMPawn', p, 'Kylie_Dock')
					p.EnterWorld();

			flags.SetBool('MS_SpawnedKylie', true,, 25);
		}

		// Change the shuttle's familiarname to reflect DD is speaking if DD was saved
		if (flags.GetBool('QC_MAIN_DestroyLEETs') && flags.GetBool('DD_Safe'))
		{
			foreach allactors(class'Vehicles', V, 'ABISpaceShip')
			{
				V.FamiliarName = "Deus Diablo";
				V.UnfamiliarName = "Deus Diablo";
				V.ConBindEvents();
			}
		}

		// Spawn DD at the docking hologram if the station is exploding and the player hasn't met him yet
		if (flags.GetBool('MS_TurbinesStopped') && !flags.GetBool('DeusDiablo_PDX_Played') && !flags.GetBool('DeusDiablo_WC_Played') && !flags.GetBool('DeusDiablo_Exploding_Played') && !flags.GetBool('DeusDiablo_Dead') && !flags.GetBool('DeusDiablo_Unconscious'))
		{
			foreach allactors(class'TNMPawn', p, 'DD')
				p.EnterWorld();
		}
	}
	else if (localURL == "24_SPACESTATION02")
	{
		// If the player works for WC
		if (flags.GetBool('ALLIED_WC'))
		{
			// Make the notepad with the ID for the Narcissus terminal appear
			// Commented out for obsolescence - notepad is now always present
//			foreach allactors(class'TNMInformationDevices', I, 'DDNotepad')
//				I.EnterWorld();

			// And remove Deus Diablo
			foreach allactors(class'TNMPawn', p, 'DD')
				p.LeaveWorld();
		}
		// If the player works for PDX
		if (flags.GetBool('ALLIED_PDX'))
		{
			// Turn on the light in DD's apartment ^_^
			foreach allactors(class'LightSwitch', L, 'DDLivingRoomTrigger')
				L.Trigger(none,none);
		}
		// If the space station is exploding (THEN WHAT ARE YOU DOING ON LEVEL 2 YOU IDIOT!?)
		if (flags.GetBool('MS_TurbinesStopped'))
		{
			// Remove Deus Diablo
			foreach allactors(class'TNMPawn', p, 'DD')
				p.LeaveWorld();
		}
	}
	else if (localURL == "24_SPACESTATION03")
	{
		// Open one door for each airlock to begin with
		if (!flags.GetBool('MS_SSAirlockDoorsSetup'))
		{
			foreach allactors(class'DeusExMover', M)
			{
				if ((M.tag == 'EngineeringAirlock1Door2') || (M.tag == 'EngineeringAirlock2Door1') ||
				    (M.tag == 'EngineeringAirlock3Door1') || (M.tag == 'EngineeringAirlock4Door1') ||
				    (M.tag == 'EngineeringAirlock5Door1') || (M.tag == 'EngineeringAirlock6Door1'))
					M.trigger(none,none);
			}

			flags.SetBool('MS_SSAirlockDoorsSetup',true,,25);
		}

		// Set the flag to make the LEET terminal hackable or unhackable
		if (flags.GetBool('QR_MAIN_DestroyLEETs') && !flags.GetBool('Ryan_Banned'))
		{
			flags.SetBool('CanDestroyLEETs', true,, 25);
		}
		else
		{
			flags.SetBool('CanDestroyLEETs', false,, 25);
		}

		// Replace all the aliens in the APG room with Deus Diablo if the player is WC-aligned
		if (!flags.GetBool('MS_SpawnedDD') && flags.GetBool('QR_MAIN_ActivateAPGs'))
		{
			// Remove all the aliens guarding the APG's...
			foreach AllActors(class'TNMPawn', p, 'APGAlien')
				p.LeaveWorld();

			// ...and the robot
			foreach AllActors(class'TNMRobot', r, 'APGSecBot')
				r.LeaveWorld();

			// Instead, spawn Deus Diablo!
			foreach AllActors(class'TNMPawn', p, 'DD')
				p.EnterWorld();

			// And turn off the camera so it doesn't get annoying
			foreach AllActors(class'SecurityCamera', S, 'APGCamera')
				S.bActive = False;

			flags.SetBool('MS_SpawnedDD', true,, 25);
		}

		// Delete the APG computer entity and the Annie Plant aug upgrade if the player is PDX-aligned
		if (flags.GetBool('ALLIED_PDX'))
		{
			foreach allactors(class'tnmComputerAPGPuzzle',APG,'APGComputer')
				APG.Destroy();
			foreach allactors(class'AugmentationUpgradeCannister',U,'AugUpgrade_WC')
				U.Destroy();
		}
		// Else, destroy the APG aug upgrade
		else
		{
			foreach allactors(class'AugmentationUpgradeCannister',U,'AugUpgrade_PDX')
				U.Destroy();
		}
	}
	else if (localURL == "24_SPACESTATION04")
	{
		// Make sure you can't ban Ryan if he's dead or if you've already rigged the station to explode
		if(!flags.GetBool('ryan_unbannable'))
			flags.SetBool('Ryan_Unbannable',flags.GetBool('Ryan_Dead') || flags.GetBool('MS_TurbinesStopped'),,25);

		if (flags.GetBool('QR_MAIN_TNM') && !flags.GetBool('MS_DebuggerRoom_Open'))
		{
			foreach allactors(class'DeusExMover',M,'DebuggerRoomHider')
				m.trigger(m,getplayerpawn());

			flags.SetBool('MS_DebuggerRoom_Open', true,,0);
		}
		
		// Disable ROFL console usage during PDX gameplay to prevent spoiling WC's ending.
		if (flags.GetBool('ALLIED_PDX') && !flags.GetBool('MS_RemoveROFLConsole'))
		{
			foreach AllActors(class'Computers', ROFL, 'ROFLConsole')
			{
				ROFL.SetCollision(False,False,False);
			}
			flags.SetBool('MS_RemoveROFLConsole', true,,0);
		}
		
		// Remove all the aliens guarding the APG's...
		// foreach AllActors(class'TNMPawn', p)
			// if (p.BindName == "Silverdawn")
				// p.Default.Fatness = 140;
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
	local DeusExMover Mover;

	// If the player leaves the level with DD on tow or while DD is leaving, complete the goal
	if (flags != None && ((flags.GetBool('DD_Following') || flags.GetBool('DD_Moving')) && !flags.GetBool('QC_MAIN_FindDD')))
	{
		foreach AllActors(class'TNMPawn',p,'DD')
			p.LeaveWorld();

		flags.SetBool('MS_DDSafe', true,, 0);
	}
		
	if (localURL == "24_SPACESTATION01")
	{
		foreach AllActors(class'DeusExMover', Mover)
		{
			if (Mover.Tag == 'ElevatorDoors_Outer' || Mover.Tag == 'ElevatorDoors_Inner')
			{
				Mover.InterpolateTo(0,0);  // Instantly go back to closed position
				Mover.Enable( 'Trigger' ); // Allow us to instantly reopen it.
			}
		}
	}
	else if (localURL == "24_SPACESTATION02")
	{
		foreach AllActors(class'DeusExMover', Mover)
		{
			if (Mover.Tag == 'ElevatorDoors_Outer' || Mover.Tag == 'ElevatorDoors_Inner')
			{
				Mover.InterpolateTo(0,0);  // Instantly go back to closed position
				Mover.Enable( 'Trigger' ); // Allow us to instantly reopen it.
			}
		}
	}
	else if (localURL == "24_SPACESTATION03")
	{
		foreach AllActors(class'DeusExMover', Mover)
		{
			if (Mover.Tag == 'ElevatorDoors_Outer' || Mover.Tag == 'ElevatorDoors_Inner')
			{
				Mover.InterpolateTo(0,0);  // Instantly go back to closed position
				Mover.Enable( 'Trigger' ); // Allow us to instantly reopen it.
			}
		}
	}
	else if (localURL == "24_SPACESTATION04")
	{
		foreach AllActors(class'DeusExMover', Mover)
		{
			if (Mover.Tag == 'ElevatorDoors_Outer' || Mover.Tag == 'ElevatorDoors_Inner')
			{
				Mover.InterpolateTo(0,0);  // Instantly go back to closed position
				Mover.Enable( 'Trigger' ); // Allow us to instantly reopen it.
			}
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
	local int count, i, j;
	local tnmzoneinfo Z;
	local Trigger T;
	local TNMPawn p;
	local Fan1 F;
	local DeusExMover M;
	local TNMDecoration D;
	local TNMRobot r;
	local ScriptedPawn pawn;
	local SpawnPoint SP;
	local SphereEffect sphere;
	local ElectricityEmitter elec;
	local Vector loc;
	local ScriptedTextureGSTVOn TVController;
	local int numAlien, numPhaser, numStalker, numIrradiator, numPlanetsider;
	local LaserEmitter lasers;
	local DeusExMover SolarFin;
	local int SolarSpan, NGPVouchers;
	local bool ABI_BoughtVisor, ABI_BoughtGlasses, ABI_BoughtCoat, ABI_BoughtCoatPDX, ABI_BoughtCoatWC, ABI_BoughtCoatGoat, ABI_BoughtCoatLlama, ABI_BoughtCoatShortBlack, ABI_BoughtCoatShortTrest, ABI_BoughtCoatDXI, ABI_BoughtCoatGold, ABI_BoughtCoatGS, ABI_BoughtCoatBum, ABI_BoughtVestMJ12, ABI_BoughtVestJC, ABI_BoughtSunglasses, ABI_BoughtAviators, ABI_BoughtVaporwave;

	Super.Timer();

	if (localURL == "24_SPACESTATION01")
	{
		count = 0;
		// Count the doors of the decompression hallway
		foreach AllActors(class'DeusExMover',M,'DecompressionHallwayDoor')
			if(!M.bDestroyed)
				count++;

		// If there are less than two...
		if (count != 2)
		{
			// ...check whether the decompression has been activated
			foreach AllActors(class'tnmzoneinfo', Z, 'DecompressionHallwayZone')
			{
				// If so, deactivate it
				if (Z.bNoOxygen == True)
				{
					foreach allactors(class'trigger', t, 'DecompressionHallwayOxygenTrigger')
						t.trigger(none,none);
				}
				else // If not, make sure it can't be activated
				{
					foreach AllActors(class'Trigger', T, 'DecompressionHallwayTrigger')
						T.Destroy();
				}
			}
		}

		// Spawn KK for final briefing (PDX) or some light antagonism (WC)
		if (!flags.GetBool('MS_SpawnedKKHologram') &&
			(
			(flags.GetBool('ALLIED_PDX') && flags.GetBool('QC_MAIN_DisableAILocks')) || 
		   	(flags.GetBool('ALLIED_WC')  && flags.GetBool('QC_MAIN_NarcissusLoop'))
			)
		   )
		{
			foreach AllActors(class'TNMDecoration', D, 'GSLogo2')
				D.bHidden = True;

			foreach AllActors(class'TNMPawn', p, 'KK_Hologram2')
				p.EnterWorld();

			flags.SetBool('MS_SpawnedKKHologram', true,, 25);
		}

		// Remove Narcissus when the player disables the AI locks
		if (flags.GetBool('QC_MAIN_DisableAILocks') || flags.GetBool('QC_MAIN_NarcissusLoop'))
		{
			foreach AllActors(class'TNMDecoration', D, 'NarcissusLogo')
				D.Destroy();
		}

		// Autosave at the start of the mission
		if (!flags.GetBool('Autosaved_GameSpy'))
		{
			trestkon(getplayerpawn()).autosave(true, 24);
			// if (trestkon(getplayerpawn()).autosave(true))
				// flags.SetBool('Autosaved_GameSpy',true,,25);
		}
		
		// check for UC respawing
		
		// Dynamically load classes from child packages
		if (spawnData[0].SpawnClass == None)
			spawnData[0].SpawnClass = class<ScriptedPawn>(DynamicLoadObject("TNMCharacters.FirewallGS",class'Class'));
		if (spawnData[1].SpawnClass == None)
			spawnData[1].SpawnClass = class<ScriptedPawn>(DynamicLoadObject("TNMCharacters.FirewallGS",class'Class'));
		if (spawnData[2].SpawnClass == None)
			spawnData[2].SpawnClass = class<ScriptedPawn>(DynamicLoadObject("TNMCharacters.FirewallGS",class'Class'));
			
		// count the number of monsters that are still alive
		foreach AllActors(class'ScriptedPawn', pawn)
			for (i=0; i<ArrayCount(spawnData); i++)
				if ((pawn.Class == spawnData[i].spawnClass) && (pawn.Tag == spawnData[i].Tag))
					spawnData[i].count++;

		// check to see when the last one was killed and set the time correctly
		for (i=0; i<ArrayCount(spawnData); i++)
			if ((spawnData[i].count == 0) && (spawnData[i].lastKilledTime == -1))
				spawnData[i].lastKilledTime = Level.TimeSeconds;

		// spawn any monsters which have been missing for 20 seconds
		for (i=0; i<ArrayCount(spawnData); i++)
		{
			if ((spawnData[i].count == 0) && (Level.TimeSeconds - spawnData[i].lastKilledTime > 20))
			{
				// Can't use GetSpawnPoint because Biomod/Shifter make the game crash.
				// SP = GetSpawnPoint(spawnData[i].spawnTag);
				foreach AllActors(class'SpawnPoint', SP, spawnData[i].spawnTag)
				{
					break;
				}
				if (SP != None)
				{
					// spawn the actual monster
					pawn = Spawn(spawnData[i].spawnClass, None, spawnData[i].Tag, SP.Location, SP.Rotation);
					if (pawn != None)	// Transcended - Only do this per success, rather than per attempt
					{
						pawn.InitializePawn();
						pawn.SetOrders('Patrolling', spawnData[i].orderTag);
						pawn.ChangeAlly('Player', -1, True);
						pawn.ChangeAlly('GameSpy', 1, True);
						pawn.bKeepWeaponDrawn = True;
						pawn.bAlwaysPatrol = True;
						if (tnmPawn(pawn) != None)
							tnmPawn(pawn).bExtraSuspicious = True; // Turn head while walking
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
		
		if (!flags.GetBool('MS_M24Lasers'))
		{
			foreach AllActors(class'LaserEmitter', lasers)
			{
				// Fargo
				if (lasers.bBlueBeam)
				{
					lasers.SoundRadius = 6;
					lasers.SoundVolume = 32;
					flags.SetBool('MS_M24Lasers',true,,25);
				}
			}
		}
		
		// NG+ New Game Plus
		if (flags.GetBool('MS_StartNewGamePlus') && flags.GetBool('Narcissus_Greeting_Played') && !Player.IsInState('Conversation'))
		{			
			NGPVouchers = flags.GetInt('ABI_VoucherUses');	
			ABI_BoughtVisor = flags.GetBool('ABI_BoughtVisor');	
			ABI_BoughtGlasses = flags.GetBool('ABI_BoughtGlasses');	
			ABI_BoughtCoat = flags.GetBool('ABI_BoughtGlasses');	
			ABI_BoughtCoatPDX = flags.GetBool('ABI_BoughtCoatPDX');	
			ABI_BoughtCoatWC = flags.GetBool('ABI_BoughtCoatWC');	
			ABI_BoughtCoatGoat = flags.GetBool('ABI_BoughtCoatGoat');	
			ABI_BoughtCoatLlama = flags.GetBool('ABI_BoughtCoatLlama');	
			ABI_BoughtCoatShortBlack = flags.GetBool('ABI_BoughtCoatShortBlack');	
			ABI_BoughtCoatShortTrest = flags.GetBool('ABI_BoughtCoatShortTrest');	
			ABI_BoughtCoatDXI = flags.GetBool('ABI_BoughtCoatDXI');	
			ABI_BoughtCoatGold = flags.GetBool('ABI_BoughtCoatGold');	
			ABI_BoughtCoatGS = flags.GetBool('ABI_BoughtCoatGS');	
			ABI_BoughtCoatBum = flags.GetBool('ABI_BoughtCoatBum');	
			ABI_BoughtVestMJ12 = flags.GetBool('ABI_BoughtVestMJ12');	
			ABI_BoughtVestJC = flags.GetBool('ABI_BoughtVestJC');	
			ABI_BoughtSunglasses = flags.GetBool('ABI_BoughtSunglasses');	
			ABI_BoughtAviators = flags.GetBool('ABI_BoughtAviators');	
			ABI_BoughtVaporwave = flags.GetBool('ABI_BoughtVaporwave');	
		
			if (DeusExRootWindow(Player.rootWindow) != None)
				DeusExRootWindow(Player.rootWindow).ResetFlags();
				
			flags.SetInt('ABI_VoucherUses', NGPVouchers, True, 0);
			flags.SetBool('ABI_BoughtVisor', ABI_BoughtVisor,, 0);
			flags.SetBool('ABI_BoughtGlasses', ABI_BoughtGlasses,, 0);
			flags.SetBool('ABI_BoughtCoat', ABI_BoughtCoat,, 0);
			flags.SetBool('ABI_BoughtCoatWC', ABI_BoughtCoatWC,, 0);
			flags.SetBool('ABI_BoughtCoatGoat', ABI_BoughtCoatGoat,, 0);
			flags.SetBool('ABI_BoughtCoatLlama', ABI_BoughtCoatLlama,, 0);
			flags.SetBool('ABI_BoughtCoatShortBlack', ABI_BoughtCoatShortBlack,, 0);
			flags.SetBool('ABI_BoughtCoatShortTrest', ABI_BoughtCoatShortTrest,, 0);
			flags.SetBool('ABI_BoughtCoatGS', ABI_BoughtCoatGS,, 0);
			flags.SetBool('ABI_BoughtCoatBum', ABI_BoughtCoatBum,, 0);
			flags.SetBool('ABI_BoughtVestMJ12', ABI_BoughtVestMJ12,, 0);
			flags.SetBool('ABI_BoughtVestJC', ABI_BoughtVestJC,, 0);
			flags.SetBool('ABI_BoughtSunglasses', ABI_BoughtSunglasses,, 0);
			flags.SetBool('ABI_BoughtAviators', ABI_BoughtAviators,, 0);
			flags.SetBool('ABI_BoughtVaporwave', ABI_BoughtVaporwave,, 0);

			// clear the notes and the goals
			// DeleteAllNotes();
			Player.DeleteAllGoals();

			// Nuke the history
			Player.ResetConversationHistory();
			
			Player.ClearLog();
			
			Level.Game.SendPlayer(Player, Player.strStartMap);
		}
	}
	if (localURL == "24_SPACESTATION02")
	{
		count = 0;
		// If DD makes it out, award some skillpoints and send the PM
		if (flags.GetBool('DeusDiablo_PDX_Played') && !flags.GetBool('QC_MAIN_FindDD') && !flags.GetBool('DeusDiablo_Dead'))
		{
			foreach allactors(class'TNMPawn',p,'DD')
				count++;

			if (count == 0)
			{
				flags.SetBool('QC_MAIN_FindDD',true,,0);
				SkillAward(500, strDeusAward);
				SendPM("PM_Kashue_DDSafe");
			}
		}

		// If DD dies during the rescue, DESPAIR! But have some skillpoints anyway :P
		if (flags.GetBool('DeusDiablo_Dead') && flags.GetBool('QR_MAIN_FindDD') && !flags.GetBool('QC_MAIN_FindDD') && !flags.GetBool('MS_FindDD_AwardGiven'))
		{
			SkillAward(500, strEffortAward);
			SendPM("PM_Kashue_DDDead");
			flags.SetBool('MS_FindDD_AwardGiven',true,,25);
		}

		// Award some skillpoints when you've failed to find Deus Diablo (a bit counter-intuitive, but yeah)
		if (flags.GetBool('QC_Main_KillDD') && !flags.GetBool('MS_KillDD_AwardGiven'))
		{
			SkillAward(500, strEffortAward);
			flags.SetBool('MS_KillDD_AwardGiven',true,,25);
		}
		
		foreach AllActors(class'ScriptedTextureGSTVOn', TVController)
		{
			foreach AllActors(class'TNMPawn',p)
			{
				if (p.bInWorld)
				{
					if (P.IsA('Alien'))
						numAlien++;
					else if (P.IsA('Phaser'))
						numPhaser++;
					else if (P.IsA('Stalker'))
						numStalker++;
					else if (P.IsA('Irradiator'))
						numIrradiator++;
					else if (!P.IsA('Robot'))
						numPlanetsider++;
				}
			}
			if (!player.IsInState('Dying'))
				numPlanetsider++;
			TVController.TextSmall[1] = sprintf(strGeneral, numAlien) $ "/n";
			TVController.TextSmall[1] = TVController.TextSmall[1] $ sprintf(strPhaser, numPhaser) $ "/n";
			TVController.TextSmall[1] = TVController.TextSmall[1] $ sprintf(strStalker, numStalker) $ "/n";
			TVController.TextSmall[1] = TVController.TextSmall[1] $ sprintf(strIrradiator, numIrradiator) $ "/n";
			TVController.TextSmall[1] = TVController.TextSmall[1] $ sprintf(strPlanetsider, numPlanetsider);
		}
	}
	if (localURL == "24_SPACESTATION03")
	{
		// Spawn Scara for final briefing (WC) or some light antagonism (PDX or Ryan)
		if (!flags.GetBool('MS_SpawnedScaraHologram') &&
			(
			(flags.GetBool('ALLIED_WC') && (flags.GetBool('QC_MAIN_ActivateAPGs') || flags.GetBool('QC_MAIN_DestroyLEETs'))) ||
			(flags.GetBool('ALLIED_PDX') && flags.GetBool('QC_MAIN_DisableAnniePlants') && !flags.GetBool('QC_MAIN_DestroyLEETs'))
			)
		   )
		{
			foreach AllActors(class'TNMDecoration', D, 'GSLogo3')
				D.bHidden = True;

			foreach AllActors(class'TNMPawn', p, 'Scara_Hologram')
				p.EnterWorld();

			flags.SetBool('MS_SpawnedScaraHologram', true,, 25);
		}

		// Spawn KK for some antagonism if you're doing the Ryan ending
		if (flags.GetBool('ALLIED_PDX') && flags.GetBool('QC_MAIN_DestroyLEETs') && !flags.GetBool('Kashue_RyanEnding_Played'))
		{
			foreach AllActors(class'TNMDecoration', D, 'GSLogo3')
				D.bHidden = True;

			// Make sure Scara isn't there already (he would be if you activate the APG's before you rig the LEETs)
			foreach AllActors(class'TNMPawn', p, 'Scara_Hologram')
				p.LeaveWorld();

			foreach AllActors(class'TNMPawn', p, 'KK_Hologram')
				p.EnterWorld();
		}

		// Remove DD in the WC storyline if you rig the LEETs to blow up
		if (flags.GetBool('MS_TurbinesStopped'))
		{
			foreach AllActors(class'TNMPawn', p, 'dd')
				p.LeaveWorld();
		}
		
		// check for UC respawing
		
		// Dynamically load classes from child packages
		if (spawnData[0].SpawnClass == None)
			spawnData[0].SpawnClass = class<ScriptedPawn>(DynamicLoadObject("TNMCharacters.FirewallGS",class'Class'));
		if (spawnData[1].SpawnClass == None)
			spawnData[1].SpawnClass = class<ScriptedPawn>(DynamicLoadObject("TNMCharacters.FirewallGS",class'Class'));
		if (spawnData[2].SpawnClass == None)
			spawnData[2].SpawnClass = class<ScriptedPawn>(DynamicLoadObject("TNMCharacters.FirewallGS",class'Class'));
			
		// count the number of monsters that are still alive
		foreach AllActors(class'ScriptedPawn', pawn)
			for (i=0; i<ArrayCount(spawnData); i++)
				if ((pawn.Class == spawnData[i].spawnClass) && (pawn.Tag == spawnData[i].Tag))
					spawnData[i].count++;

		// check to see when the last one was killed and set the time correctly
		for (i=0; i<ArrayCount(spawnData); i++)
			if ((spawnData[i].count == 0) && (spawnData[i].lastKilledTime == -1))
				spawnData[i].lastKilledTime = Level.TimeSeconds;

		// spawn any monsters which have been missing for 20 seconds
		for (i=0; i<ArrayCount(spawnData); i++)
		{
			if ((spawnData[i].count == 0) && (Level.TimeSeconds - spawnData[i].lastKilledTime > 20))
			{
				// Can't use GetSpawnPoint because Biomod/Shifter make the game crash.
				// SP = GetSpawnPoint(spawnData[i].spawnTag);
				foreach AllActors(class'SpawnPoint', SP, spawnData[i].spawnTag)
				{
					break;
				}
				if (SP != None)
				{
					// spawn the actual monster
					pawn = Spawn(spawnData[i].spawnClass, None, spawnData[i].Tag, SP.Location, SP.Rotation);
					if (pawn != None)	// Transcended - Only do this per success, rather than per attempt
					{
						pawn.InitializePawn();
						pawn.SetOrders('Patrolling', spawnData[i].orderTag);
						if (i == 2 && flags.GetBool('M24_03_InvertIFF'))
						{
							pawn.ChangeAlly('Player', 1, True);
							pawn.ChangeAlly('GameSpy', -1, True);
						}
						else if (i < 2 && flags.GetBool('M24_03_InvertIFFLeet'))
						{
							pawn.ChangeAlly('Player', 1, True);
							pawn.ChangeAlly('GameSpy', -1, True);
						}
						else
						{
							pawn.ChangeAlly('Player', -1, True);
							pawn.ChangeAlly('GameSpy', 1, True);
						}
						pawn.bKeepWeaponDrawn = True;
						pawn.bAlwaysPatrol = True;
						if (tnmPawn(pawn) != None)
							tnmPawn(pawn).bExtraSuspicious = True; // Turn head while walking
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
		
		foreach allactors( class'DeusExMover', SolarFin, 'SolarPanel')
		{
			if (SolarFin.Rotation.Pitch == SolarFin.DesiredRotation.Pitch)
			{
				SolarSpan = 8192;
				if (SolarFin.DesiredRotation.Pitch == 0)
				{
					if (FRand() <= 0.5)
						SolarFin.DesiredRotation.Pitch = SolarSpan;
					else
						SolarFin.DesiredRotation.Pitch = 65536-SolarSpan;
				}
				else
				{
					if (SolarFin.DesiredRotation.Pitch == SolarSpan)
						SolarFin.DesiredRotation.Pitch = 65536-SolarSpan;
					else
						SolarFin.DesiredRotation.Pitch = SolarSpan;
				}
				// SolarFin.DesiredRotation.Pitch = ((SolarFin.DesiredRotation.Pitch + (65536-SolarSpan)) % 65536) + SolarSpan;
				// if (SolarFin.DesiredRotation.Pitch == SolarSpan)
					// SolarFin.DesiredRotation.Pitch -= (65536-SolarSpan-SolarSpan);
			}
		}
	}

	// --------------------------------------------------------------
	// ENDINGS
	// --------------------------------------------------------------

	//
	// WorldCorp Ending: Destroy PDX
	//

	//
	// PDX Ending: Ban Scara and Betty
	//

	//
	// Ryan Ending: Overheat the LEETs
	//

	// Check to see if the player has shutdown the LEET fans
	if (flags.GetBool('MS_TurbinesStopped'))
	{
		// If so, cry "HAVOC!" and let loose the hounds of... uh, chaos!
		ShipExplosionEffects(True);

		// The fans will stop rotating
		foreach AllActors(class'Fan1', F)
			F.SetPhysics(PHYS_None);
			
		foreach AllActors(class'TNMDecoration', D)
		{
			if (D.IsA('LEETFans'))
				D.SetPhysics(PHYS_None);
		}
	}

	//
	// Narcissus Ending: Break the game
	//
}


// SpaceShip Explosion effects for the LEET Ending
function ShipExplosionEffects(bool bFragments)
{
	local float shakeTime, shakeRoll, shakeVert;
	local float size, explosionFreq, amount;
	local int i;
	local Vector bobble, loc, endloc, HitLocation, HitNormal;
	local Actor HitActor;
	local BreakableGlass window;
	local HangingDecoration deco;
	local Cart cart;
	local MetalFragment frag;

	if (bFragments)
		explosionFreq = 0.33;
	else
		explosionFreq = 0.1;

	if (FRand() < explosionFreq)
	{
		// pick a random explosion size and modify everything accordingly
		size = FRand();
		shakeTime = 0.5 + size;
		shakeRoll = 512.0 + 1024.0 * size;
		shakeVert = 8.0 + 16.0 * size;

		// play a sound
		if (size < 0.2)
			Player.PlaySound(Sound'SmallExplosion1', SLOT_None, 2.0,, 16384);
		else if (size < 0.4)
			Player.PlaySound(Sound'MediumExplosion1', SLOT_None, 2.0,, 16384);
		else if (size < 0.6)
			Player.PlaySound(Sound'MediumExplosion2', SLOT_None, 2.0,, 16384);
		else if (size < 0.8)
			Player.PlaySound(Sound'LargeExplosion1', SLOT_None, 2.0,, 16384);
		else
			Player.PlaySound(Sound'LargeExplosion2', SLOT_None, 2.0,, 16384);

		// shake the view
		Player.ShakeView(shakeTime, shakeRoll, shakeVert);

		// bobble the player around
		bobble = vect(300.0,300.0,200.0) + 500.0 * size * VRand();
		if ( !player.IsInState('Conversation') )
		{
			if (Player.IsInState('PlayerWalking') && Player.Physics != PHYS_Falling)
				Player.Velocity += bobble;
		}

		// make all the hanging decorations sway randomly
		foreach AllActors(class'HangingDecoration', deco)
		{
			deco.CalculateHit(deco.Location + 10.0 * FRand() * VRand(), 0.5 * bobble);
			deco.bSwaying = True;
		}

		// make all the carts move randomly
		foreach AllActors(class'Cart', cart)
			cart.StartRolling(vect(100.0,100.0,0.0) + 200.0 * size * VRand());

		amount = FRand();
		
		//Bjorn: Destroy glass windows randomly around the player.
		foreach player.RadiusActors(Class'BreakableGlass', window, 300)
		{
			//Only blow up windows that's on the same "level" as the player (a shame to blow out stuff the player can't see).
			if (Abs(player.location.Z - window.location.Z) < 100)
			{
				window.BlowItUp(player);
				amount -= 0.33;
			}
			
			if (amount <= 0.34)
				break;
			else if (amount <= 0.67)
				amount -= 0.33;
		}

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
				frag = Spawn(class'MetalFragment',,, HitLocation);
				if (frag != None)
				{
					frag.CalcVelocity(vect(20000,0,0),256);
					frag.DrawScale = 0.5 + 2.0 * FRand();
					if (FRand() < 0.25)
						frag.bSmoking = True;
				}
			}
		}
	}

	//Bjorn: If we have no Klaxon ID we haven't started the sound yet. The sound and the ID resets on travel.
	if (KlaxonID == 0)
		KlaxonID = player.PlaySound(Sound'Klaxon', SLOT_None, 1.0,, 16384);

	// make sure the player's zone has an alarm ambient sound
	// if (Player.HeadRegion.Zone != None)
	// {
		// Player.HeadRegion.Zone.AmbientSound = sound'Klaxon';
		// Player.HeadRegion.Zone.SoundRadius = 255;
		// Player.HeadRegion.Zone.SoundVolume = 255;
	// }
}

function PlayGSSound()
{
	if (bool(Rand(2)))
		Player.PlaySound(Sound'TNMSounds.OneShot.GSWelcomeMale', SLOT_Talk, 12.0, True);
	else
		Player.PlaySound(Sound'TNMSounds.OneShot.GSWelcomeFemale', SLOT_Talk, 12.0, True);
}

function PawnKilled(pawn killed, pawn killer)
{
	// local bool bUnconscious;
	
	if (flags == None || Killed == None)
		return;
	
	// Allow A2 to get into fights
	if (Killed.IsA('Kylie'))
		flags.SetBool('Kylie_Dead_M24', true,, 0);
	
	Super.PawnKilled(killed, killer);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function HandleGameEvent(name scriptFunction)
{
	switch ( scriptFunction )
	{
		case 'SpawnDockedShuttle':	SpawnDockedShuttle(); 	break;
		case 'DownloadSchematics':	DownloadSchematics(); 	break;
		case 'EngineeringAirlock1':	EngineeringAirlock('EngineeringAirlock1Door1', 'EngineeringAirlock1Dispatcher1', 'EngineeringAirlock1Dispatcher2'); 	break;
		case 'EngineeringAirlock2':	EngineeringAirlock('EngineeringAirlock2Door1', 'EngineeringAirlock2Dispatcher1', 'EngineeringAirlock2Dispatcher2'); 	break;
		case 'EngineeringAirlock3':	EngineeringAirlock('EngineeringAirlock3Door1', 'EngineeringAirlock3Dispatcher1', 'EngineeringAirlock3Dispatcher2'); 	break;
		case 'EngineeringAirlock4':	EngineeringAirlock('EngineeringAirlock4Door1', 'EngineeringAirlock4Dispatcher1', 'EngineeringAirlock4Dispatcher2'); 	break;
		case 'EngineeringAirlock5':	EngineeringAirlock('EngineeringAirlock5Door1', 'EngineeringAirlock5Dispatcher1', 'EngineeringAirlock5Dispatcher2'); 	break;
		case 'EngineeringAirlock6':	EngineeringAirlock('EngineeringAirlock6Door1', 'EngineeringAirlock6Dispatcher1', 'EngineeringAirlock6Dispatcher2'); 	break;
		case 'EnableAirPumps':		EnableAirPumps(); 		break;
		case 'LEETRobotsDie':		LEETRobotsDie(); 		break;
		case 'AnnieSpiderbotsDie':	AnnieSpiderbotsDie(); 	break;
		case 'APGSecBotDie':		APGSecBotDie(); 		break;
		case 'HoloDisappear':		HoloDisappear();		break;
		case 'KKDisappear':			KKDisappear();			break;
		case 'ScaraDisappear':		ScaraDisappear();		break;
		case 'BreakTheGame':		WoundJonasEgo();		break;
		case 'TrestAblaze':			TrestAblaze();			break;
		case 'TrestPutOut':			TrestPutOut();			break;
		case 'EngineeringAirlock1Entry':	NewEngineeringAirlock('NewEngineeringAirlock1Door1', 'NewEngineeringAirlock1Door2'); 	break;
		case 'EngineeringAirlock1Exit':		NewEngineeringAirlock('NewEngineeringAirlock1Door2', 'NewEngineeringAirlock1Door1'); 	break;
		case 'EngineeringAirlock1Cycle':	NewEngineeringAirlockCycle('NewEngineeringAirlock1Door1', 'NewEngineeringAirlock1Door2', 'EngineeringAirlock1CycleIn', 'EngineeringAirlock1CycleOut'); 	break;
		case 'EngineeringAirlock2Entry':	NewEngineeringAirlock('NewEngineeringAirlock2Door1', 'NewEngineeringAirlock2Door2'); 	break;
		case 'EngineeringAirlock2Exit':		NewEngineeringAirlock('NewEngineeringAirlock2Door2', 'NewEngineeringAirlock2Door1'); 	break;
		case 'EngineeringAirlock2Cycle':	NewEngineeringAirlockCycle('NewEngineeringAirlock2Door1', 'NewEngineeringAirlock2Door2', 'EngineeringAirlock2CycleIn', 'EngineeringAirlock2CycleOut'); 	break;
		case 'EngineeringAirlock3Entry':	NewEngineeringAirlock('NewEngineeringAirlock3Door1', 'NewEngineeringAirlock3Door2'); 	break;
		case 'EngineeringAirlock3Exit':		NewEngineeringAirlock('NewEngineeringAirlock3Door2', 'NewEngineeringAirlock3Door1'); 	break;
		case 'EngineeringAirlock3Cycle':	NewEngineeringAirlockCycle('NewEngineeringAirlock3Door1', 'NewEngineeringAirlock3Door2', 'EngineeringAirlock3CycleIn', 'EngineeringAirlock3CycleOut'); 	break;
		case 'EngineeringAirlock4Entry':	NewEngineeringAirlock('NewEngineeringAirlock4Door1', 'NewEngineeringAirlock4Door2'); 	break;
		case 'EngineeringAirlock4Exit':		NewEngineeringAirlock('NewEngineeringAirlock4Door2', 'NewEngineeringAirlock4Door1'); 	break;
		case 'EngineeringAirlock4Cycle':	NewEngineeringAirlockCycle('NewEngineeringAirlock4Door1', 'NewEngineeringAirlock4Door2', 'EngineeringAirlock4CycleIn', 'EngineeringAirlock4CycleOut'); 	break;
		case 'EngineeringAirlock5Entry':	NewEngineeringAirlock('NewEngineeringAirlock5Door1', 'NewEngineeringAirlock5Door2'); 	break;
		case 'EngineeringAirlock5Exit':		NewEngineeringAirlock('NewEngineeringAirlock5Door2', 'NewEngineeringAirlock5Door1'); 	break;
		case 'EngineeringAirlock5Cycle':	NewEngineeringAirlockCycle('NewEngineeringAirlock5Door1', 'NewEngineeringAirlock5Door2', 'EngineeringAirlock5CycleIn', 'EngineeringAirlock5CycleOut'); 	break;
		case 'EngineeringAirlock6Entry':	NewEngineeringAirlock('NewEngineeringAirlock6Door1', 'NewEngineeringAirlock6Door2'); 	break;
		case 'EngineeringAirlock6Exit':		NewEngineeringAirlock('NewEngineeringAirlock6Door2', 'NewEngineeringAirlock6Door1'); 	break;
		case 'EngineeringAirlock6Cycle':	NewEngineeringAirlockCycle('NewEngineeringAirlock6Door1', 'NewEngineeringAirlock6Door2', 'EngineeringAirlock6CycleIn', 'EngineeringAirlock6CycleOut'); 	break;
		case 'M24_FirewallIFF':		FirewallIFF(); 			break;
		case 'M24_FirewallIFFLeet':	FirewallIFFLeet(); 		break;
		case 'PlayGSSound':			PlayGSSound(); 			break;
		default: 			super.HandleGameEvent(scriptFunction);
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function PlayerDetected(name StateType, optional ScriptedPawn Triggerer)
{
	if (flags == None)
		return;
		
	//Stealth check
	if (LocalURL == "24_SPACESTATION01")
		flags.SetBool('NS_SpaceStation01',true,,25);
	else if (LocalURL == "24_SPACESTATION02")
		flags.SetBool('NS_SpaceStation02',true,,25);
	else if (LocalURL == "24_SPACESTATION03")
		flags.SetBool('NS_SpaceStation03',true,,25);
	else if (LocalURL == "24_SPACESTATION04")
		flags.SetBool('NS_SpaceStation04',true,,25);
}

defaultproperties
{
     spawnData(0)=(SpawnTag=GSFirewallS1,Tag=GSFirewallSpawnee1,OrderTag=GSFPPA1,lastKilledTime=-1.000000)
     spawnData(1)=(SpawnTag=GSFirewallS2,Tag=GSFirewallSpawnee2,OrderTag=GSFPPB1,lastKilledTime=-1.000000)
     spawnData(2)=(SpawnTag=GSFirewallS3,Tag=GSFirewallSpawnee3,OrderTag=GSFPPC1,lastKilledTime=-1.000000)
     strDeusAward="Deus Has Left The Building! Award"
     strEffortAward="A For Effort Award"
     strGeneral="General Crew: %s"
     strPhaser="Phaser: %s"
     strStalker="Stalker: %s"
     strIrradiator="Irradiator: %s"
     strPlanetsider="Planetsider: %s"
     lastYaw=-1
     RemoteRole=ROLE_DumbProxy
}

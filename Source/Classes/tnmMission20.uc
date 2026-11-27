class tnmMission20 extends tnmMission20and22;

#exec OBJ LOAD FILE=TNMSounds

var bool bDontResetAlliances;
var inventory launcher;

var localized string strNSCKey, strGoalDrainTheMelk1, strGoalDrainTheMelk2, strSabotageAward;
var localized string strLlamaKey, strPassword, strDXIKey;
var localized string strGoalN00Bz, strGoalAbom, strGoalSewerRetrieval;
var localized string strGoalServerComplex, strGoalShadowCode;
var localized string strPiggyBank, strSubPass, strSubPassNVS;
var localized string strKunioDead, strKunioUnconscious, strFirewallDead, strFirewallUnconscious;
var localized string strAbomDead, strAbomUnconscious, strJimmyDead, strJimmyUnconscious;
var localized string strAbomDead2, strAbomUnconscious2, strDarkTemplar, strBeefmanDead;
var localized string strYardbombDead, strVoodooAward, strDarkTemplarDead, strDarkTemplarUnconscious;
var localized string strDarkTemplarRobbed, strShadowCode, strShowGoOnAward;
var localized string strDragonSlayerAward, strRescueSilver, strRejectionAward, strJimDead, strWrenchAward, strInvestigationAward;



function SetupExclusions()
{
	local int i;

	super.SetupExclusions();
	// for (i = 0; i < 32; i++)
	// {
		// if ( CountExclusions[i] == '' )
		// {
			// CountExclusions[i] = 'ZeroPresence';
			// break;
		// }
	// }
	CountExclusions[0] = 'ZeroPresence';
	CountExclusions[1] = 'WCSpy';
}

function StartConversationByName(Name conName, Actor conOwner, optional bool bAvoidState, optional bool bForcePlay)
{
	local bool bsuccess;
	bsuccess = player.StartConversationByName(conName, conOwner, bAvoidState, bForcePlay);
	if (!bsuccess)
		Log("Failed to play conversation");
}

function SDFindPatrol()
{
	local TNMPawn Silver;
	local Pawn curPawn;
	local PatrolPoint PPoint, bestPoint;
	local float possibleDistance, bestDistance;
	
	for (curPawn=Level.PawnList; curPawn!=None; curPawn=curPawn.NextPawn)
	{
		if (curPawn.IsA('SD'))
		{
			Silver = TNMPawn(curPawn);
			break;
		}
	}
	// log("Silver:" @ Silver);
	
	bestDistance = 9999999;
	
	forEach AllActors(class'PatrolPoint', PPoint)
	{
		if (Silver == None)
			break;
		if (PPoint.Tag == 'SDRunPoint5' || PPoint.Tag == 'SDRunPoint4' || PPoint.Tag == 'SDRunPoint3' || PPoint.Tag == 'SDRunPoint2' || PPoint.Tag == 'SDRunPoint1' || PPoint.Tag == 'SDRunPoint0')
		{
			possibleDistance = VSize(Silver.Location - PPoint.Location);
			// log("possibleDistance:" @ possibleDistance @ PPoint);
			if (possibleDistance < bestDistance)
			{
				bestDistance = possibleDistance;
				bestPoint = PPoint;
			}
		}
	}
	// log("bestPoint:" @ bestPoint);
	
	if (bestPoint != None && Silver != None)
		Silver.SetOrders('RunningTo', bestPoint.Tag);
}

function AbomOneliner02()
{
	local TNMPawn p;
	foreach allactors(class'TNMPawn',p,'Abomnation')
		break;
	StartConversationByName('AbomKilledBG', p, False, True);
}

function AbomCutsceneEscape()
{
	local TNMPawn p;
	foreach allactors(class'TNMPawn',p,'AbomBG')
		p.LeaveWorld();
}

function GiveNSCKey()
{
	local NanoKey key;
	local Pawn P;
	local Trestkon T;

	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		T = Trestkon(P);
		if (T != None)
		{
			key = Spawn(Class'NanoKey');
			if (key != None)
			{
				key.KeyID = 'NSCKey';
				key.Description = strNSCKey;
				key.GiveTo(T);
			}
		}
	}
}

function GhandCatchFire()
{
	local TNMPawn p;
	foreach AllActors(Class'TNMPawn',p,'Ghand')
		p.CatchFire();
		
	if (Trestkon(GetPlayerPawn()) != None)
		Trestkon(GetPlayerPawn()).SetAchievement("achGhand");
}

function PDXMark(name nav, name guard, name window, string pmfail, string pmdead, string pmsuccess)
{
	local TNMPawn p;
	local deusexmover m;
	local navigationpoint n;
	local vector displacement;

	foreach allactors(class'navigationpoint',n,nav)
		break;

	foreach allactors(class'TNMPawn',p,guard)
		break;

	if ( p != none && !p.IsInState('Dying'))
	{
		displacement = p.location-n.location;
		displacement.z = 0;

		if ( vsize(displacement) < 128)
		{
			p.HealthHead = 0;
			p.Health = 0;
			p.bStunned = false;
			p.TakeDamage(1, p, p.Location, vect(-10,0,25), 'shot'); // Headshot = collision height(35.625000) * 0,7

			foreach allactors(class'deusexmover',m,window)
				m.BlowItUp(None);

			// Send a PM from ZeroPresence
			SendPM(pmsuccess);
		}
		else
			SendPM(pmfail);
	}
	else
	{
		SendPM(pmdead);
	}
}

function PDXMark1()
{
	// Abort if Zero is dead, unconscious or the mission is done
	if(flags.GetBool('Zero_Dead')) return;
	if(flags.GetBool('Zero_Unconscious')) return;
	if(flags.GetBool('QC_MAIN_GetNewsscript')) return;

	PDXMark('GP_Mark1', 'DXAGuard_Mark1', 'PDXWindow_Mark1', "PM_Zero_PDXMark1_Failed", "PM_Zero_PDXMark1_Dead", "PM_Zero_PDXMark1");
}

function PDXMark2()
{
	// Abort if Zero is dead, unconscious or the mission is done
	if(flags.GetBool('Zero_Dead')) return;
	if(flags.GetBool('Zero_Unconscious')) return;
	if(flags.GetBool('QC_MAIN_GetNewsscript')) return;

	PDXMark('GP_Mark2', 'DXAGuard_Mark2', 'PDXWindow_Mark2', "PM_Zero_PDXMark2_Failed", "PM_Zero_PDXMark2_Dead", "PM_Zero_PDXMark2");
}

function PDXMark3()
{
	local TNMPawn p1, p2;
	local deusexmover m;
	local navigationpoint n1, n2;
	local vector displacement1, displacement2;
	local dispatcher dispatcher;

	// Abort if Zero is dead, unconscious or the mission is done
	if(flags.GetBool('Zero_Dead')) return;
	if(flags.GetBool('Zero_Unconscious')) return;
	if(flags.GetBool('QC_MAIN_GetNewsscript')) return;

	foreach allactors(class'navigationpoint',n1,'GP_Mark3')
		break;

	foreach allactors(class'TNMPawn',p1,'DXAGuard_Mark3')
		break;

	foreach allactors(class'navigationpoint',n2,'GP_Mark4')
		break;

	foreach allactors(class'TNMPawn',p2,'DXAGuard_Mark4')
		break;

	if ( p1 != none && !p1.IsInState('Dying') && p2 != none && !p2.IsInState('Dying'))
	{
		displacement1 = p1.location-n1.location;
		displacement1.z = 0;

		displacement2 = p2.location-n2.location;
		displacement2.z = 0;

		if ( vsize(displacement1) < 128 && vsize(displacement2) < 128)
		{
			p1.HealthHead = 0;
			p1.Health = 0;
			p1.bStunned = false;
			p1.TakeDamage(1, p1, p1.Location, vect(-10,0,25), 'shot'); // Headshot = collision height(35.625000) * 0,7

			foreach allactors(class'deusexmover',m,'PDXWindow_Mark3')
				m.BlowItUp(None);

			foreach allactors(class'dispatcher', dispatcher, 'MSMark4Delay')
				dispatcher.trigger(none,none);
		}
		else
			SendPM("PM_Zero_PDXMark3and4_Failed");
	}
	else
	{
		SendPM("PM_Zero_PDXMark3and4_Dead");
	}
}

function PDXMark4()
{
	local TNMPawn p2;
	local deusexmover m;

	// Abort if Zero is dead, unconscious or the mission is done
	if(flags.GetBool('Zero_Dead')) return;
	if(flags.GetBool('Zero_Unconscious')) return;
	if(flags.GetBool('QC_MAIN_GetNewsscript')) return;

	foreach allactors(class'TNMPawn',p2,'DXAGuard_Mark4')
		break;

	if (p2 != none && !p2.IsInState('Dying'))
	{
			p2.HealthHead = 0;
			p2.Health = 0;
			p2.bStunned = false;
			p2.TakeDamage(1, p2, p2.Location, vect(-10,0,25), 'shot'); // Headshot = collision height(35.625000) * 0,7

			foreach allactors(class'deusexmover',m,'PDXWindow_Mark4')
				m.BlowItUp(None);

			// Send a PM from ZeroPresence
			SendPM("PM_Zero_PDXMark3and4");
	}
}


function BackOutTunnel()
{
	local TNMPawn p;
	 // If the player hasn't been detected, make the guards neutral again
	if (!flags.GetBool('Shawn_PissedOffGuards'))
	{
		foreach allactors(class'TNMPawn',p,'PhasecGuards')
		{
			P.ChangeAlly('Player', 0.0, true);
		}
		foreach allactors(class'TNMPawn',p,'Cop1')
		{
			P.ChangeAlly('Player', 0.0, true);
		}
	}
}

function BullseyeCheck()
{
	local Trigger t;
	local Pawn P;
	local Trestkon Trest;

	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		Trest = Trestkon(P);
		if (Trest != None && Trest.Location.X > 5880 && Trest.Location.X < 6855 && Trest.Location.Y > 11192 && Trest.Location.Y < 11911)
		{
			foreach AllActors(Class'Trigger', t, 'BullseyeAward')
				t.Trigger(Self, Trest);
			break;
		}
	}
}

function DestroyedValve()
{
	local int valvesdestroyed;
	valvesdestroyed = flags.GetInt('MS_ValvesDestroyed');

	if (valvesdestroyed == 0)
	{
		SendPM("PM_Abom_FirstValve");
		AddGoal('DrainTheMelk', strGoalDrainTheMelk1, FALSE, FALSE);
	}
	else if (valvesdestroyed == 1)
	{
		SendPM("PM_Abom_SecondValve");
		AddGoal('DrainTheMelk', strGoalDrainTheMelk2, FALSE, FALSE);
		SkillAward(500,strSabotageAward);
		flags.SetBool('GoatValvesDestroyed', true, , 23);
	
		if (Trestkon(GetPlayerPawn()) != None)
			Trestkon(GetPlayerPawn()).SetAchievement("achMelkValves");
	}

	flags.SetInt('MS_ValvesDestroyed',valvesdestroyed + 1, , 21);
}

function TurnMelkValve1()
{
	local TNMDecoration d;
	foreach allactors( class'TNMDecoration',d,'MelkValve1')
	{
		d.bInvincible = false;
	}
}

function TurnMelkValve2()
{
	local TNMDecoration d;
	foreach allactors( class'TNMDecoration',d,'MelkValve2')
	{
		d.bInvincible = false;
	}
}

function PhasTakeInventory()
{
	local Inventory item, nextItem, lastItem;
	local Vector loc;
	local actor a;
	local Rotator rot;
	local int i;
	
	Player.PutInHand(None);
	Player.SetInHand(None);
	Player.SetInHandPending(None);
	Player.PendingWeapon = None;
	Player.UpdateInHand();
	if (Player.conPlay != None)
		Player.conPlay.SetInHand(None);

	foreach AllActors(class'Inventory', item)
	{
		if (item.owner == None && item.instigator == player && item.bDisplayableInv && !item.IsA('NanoKeyRing') && !item.IsA('NanoKey'))
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

			// if (item.IsA('ChargedPickup'))
				// Player.RemoveChargedDisplay(ChargedPickup(item));
				
			// Player.DeleteInventory(item);
			
			foreach allactors(class'actor', a, 'itemdump')
				break;
			item.AttachTag = '';
			
			loc = a.location;
			loc += 64.0 * vrand() * vect(1,1,0); //don't go in the ground or anything
			if ( item.SetLocation(loc) )
			{
				item.SetPhysics(PHYS_Falling);
				if (Weapon(item) != None)
					Weapon(item).bMuzzleFlash = 0;
				item.RespawnTime = 0.0; //don't respawn
				item.RemoteRole = ROLE_DumbProxy;
				item.BecomePickup();
				item.NetPriority = 2.5;
				item.bCollideWorld = true;
				item.Inventory = None;
				item.GotoState('PickUp', 'Dropped');
			}
			// item.DropFrom(loc);
			rot.Yaw = Rand(32767) + Rand(32767); // Rand is limited to 2^15
			item.SetRotation(rot);			
		}
	}

	if (Player.Inventory != None)
	{
		item = Player.Inventory;
		nextItem = item.Inventory;
		lastItem = item;

		do
		{
			if ((item != None) && item.bDisplayableInv && !item.IsA('NanoKeyRing') && !item.IsA('NanoKey'))
			{
				if (TNMWeapon(item) != None)
					i = TNMWeapon(item).beltPos;
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

				foreach allactors(class'actor', a, 'itemdump')
					break;
				item.AttachTag = '';
				
				loc = a.location;
				loc += 64.0 * vrand() * vect(1,1,0); //don't go in the ground or anything
				item.SetPhysics(PHYS_Falling);
				item.DropFrom(loc);
				rot.Yaw = Rand(32767) + Rand(32767); // Rand is limited to 2^15
				item.SetRotation(rot);
			}
			if (TNMWeapon(item) != None)
				TNMWeapon(item).lastBeltPos = i;			

			item = nextItem;

			if (item != None)
				nextItem = item.Inventory;
		}
		until ((item == None) || (item == lastItem));
	}
}

function PhasLockDoor()
{
	local TNMPawn p;

	// Prevent the player from re-entering after trying to kill Phasmatis
	SealDoor('PhasAptDoor');

	// Remove Phasmatis so the player can't trick him into opening the apartment door
	foreach Allactors(class'TNMPawn',p,'Phasmatis')
		p.LeaveWorld();
}

function OSCElevator_To_OSC()
{
	local ElevatorMover E;
	local Dispatcher D;

	// Set the elevator off if it's in starting position
	foreach allactors(class'ElevatorMover', E, 'OSCMainElevator')
	{
		if (E.keynum == 0)
		{
			// Dispatcher is definitely the easiest way to do a 6 sec delay
			foreach allactors(class'Dispatcher', D, 'OSCMainElevator_Dispatcher')
				D.Trigger(Self, Player);
		}
	}
}

function OSCElevator_To_NSC()
{
	local ElevatorMover E;
	local Dispatcher D;

	// Set the elevator off if it's in starting position and SC has been removed
	foreach allactors(class'ElevatorMover', E, 'OSCMainElevator')
	{
		if ((E.keynum == 1) && flags.GetBool('QC_MAIN_ShadowCode'))
		{
			// Dispatcher is definitely the easiest way to do a 6 sec delay
			foreach allactors(class'Dispatcher', D, 'OSCMainElevator_Dispatcher')
				D.Trigger(Self, Player);
		}
	}
}

function DXIHologramDisappear()
{
	local TNMPawn p;
	foreach allactors(class'TNMPawn', p,)
	{
		if ((p.Tag == 'ScaraHologram') || (p.Tag == 'KKHologram'))
			p.LeaveWorld();
	}
}

// ----------------------------------------------------------------------
// FirstFrame()
// 
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
	local TNMPawn p;
	local TNMRobot r;
	local deusexmover M;
	local securitycamera c;
	local TNMInformationDevices id;
	local TNMCarcass carc;
	local trigger t;
	local NanoKey n;
	local tnmatm atm;
	local actor a;
	local ZoneInfo Z;
	local WarpZoneInfo W;
	local AmbientSoundTriggered S;
	local sequencetrigger seq;
	local keypad kp;
	local TNMDecoration d;
	local GoalAddTrigger g;
	local ThrownProjectile aMine;
	local bool bKillCoat;
	local ABICoatBag coat;
	local int i;

	Super.FirstFrame();

	if(len(localURL)>=len("20_WCFLOOR") && left(localURL,len("20_WCFLOOR")) ~= "20_WCFLOOR")
	{
		// Make the bots angry if you rescue SD or kill Scara (SD_Escaped expires in mission 21)
		if ((flags.GetBool('SD_Escaped') && !flags.GetBool('Silver_Dead')) || flags.GetBool('ALLIED_PDX') || flags.GetBool('Scara_Dead'))
		{
			foreach allactors(class'TNMPawn',p)
			{
				if (!P.IsA('SD'))
					p.ChangeAlly('Player',-1.000000,true);
			}

			foreach allactors(class'securitycamera',c,)
				c.bNoAlarm = false;
		}
	}

	// Record the fact that sols should be closed
	if (localURL != "20_SOLSBAR" && localURL != "20_FCDOWNTOWN")
	{
		if (CountLiving("20_SOLSBAR") < ExpectedLiving("20_SOLSBAR"))
			Flags.SetBool('MS_CloseSols', true,, 21);
	}

	//Record the fact that party zone should be closed
	if (localURL != "20_PARTYZONE" && localURL != "20_FCCORPORATE")
	{
		if (CountLiving("20_PARTYZONE") < ExpectedLiving("20_PARTYZONE"))
			Flags.SetBool('MS_ClosePartyZone', true,, 21);
	}
	/*
	if (localURL == "20_WCHOTEL")
	{
		flags.SetBool('HotelJammerDestroyed', false,, 21);
	}*/

	if (localURL == "20_PHASAPARTMENT")
	{
		// Remove Phas and lock his apartment door after the spyware mission (he goes to PDX)
		if (flags.GetBool('QC_MAIN_WCSpyware') && !flags.GetBool('MS_PhasDoorClosed'))
		{
			foreach Allactors(class'deusexmover',M,'PhasAptDoor')
			{
				if (m.keynum != 0)
				{
					m.GotoState( 'TriggerToggle',  );
					m.trigger(self,none);
				}
				M.bLocked=True;
			}
			
			foreach Allactors(class'TNMPawn',p,'Phasmatis')
				p.LeaveWorld();
				
			flags.SetBool('MS_PhasDoorClosed',true,,21);
		}
		
		// Award the gold coat for all achievements
		for (i = 0; i < ArrayCount(class'TNMAchievementManager'.default.varAchievementsCAT1); i++)
		{
			if (!bool(Player.GetPropertyText(class'TNMAchievementManager'.default.varAchievementsCAT1[i])))
			{
				bKillCoat = True;
				break;
			}
		}
		if (!bKillCoat)
		{
			for (i = 0; i < ArrayCount(class'TNMAchievementManager'.default.varAchievementsCAT2); i++)
			{
				if (!bool(Player.GetPropertyText(class'TNMAchievementManager'.default.varAchievementsCAT2[i])))
				{
					bKillCoat = True;
					break;
				}
			}
		}
		if (!bKillCoat)
		{
			for (i = 0; i < ArrayCount(class'TNMAchievementManager'.default.varAchievementsCAT3); i++)
			{
				if (!bool(Player.GetPropertyText(class'TNMAchievementManager'.default.varAchievementsCAT3[i])))
				{
					bKillCoat = True;
					break;
				}
			}
		}
		if (!bKillCoat)
		{
			for (i = 0; i < ArrayCount(class'TNMAchievementManager'.default.varAchievementsCAT4); i++)
			{
				if (!bool(Player.GetPropertyText(class'TNMAchievementManager'.default.varAchievementsCAT4[i])))
				{
					bKillCoat = True;
					break;
				}
			}
		}
		if (!bKillCoat)
		{
			for (i = 0; i < ArrayCount(class'TNMAchievementManager'.default.varAchievementsCAT5); i++)
			{
				if (!bool(Player.GetPropertyText(class'TNMAchievementManager'.default.varAchievementsCAT5[i])))
				{
					bKillCoat = True;
					break;
				}
			}
		}
		if (!bKillCoat)
		{
			for (i = 0; i < ArrayCount(class'TNMAchievementManager'.default.varAchievementsCAT6); i++)
			{
				if (!bool(Player.GetPropertyText(class'TNMAchievementManager'.default.varAchievementsCAT6[i])))
				{
					bKillCoat = True;
					break;
				}
			}
		}/*
		if (!bKillCoat)
		{
			for (i = 0; i < ArrayCount(class'TNMAchievementManager'.default.varAchievementsCAT7); i++)
			{
				if (!bool(Player.GetPropertyText(class'TNMAchievementManager'.default.varAchievementsCAT7[i])))
				{
					bKillCoat = True;
					break;
				}
			}
		}
		if (!bKillCoat)
		{
			for (i = 0; i < ArrayCount(class'TNMAchievementManager'.default.varAchievementsCAT8); i++)
			{
				if (!bool(Player.GetPropertyText(class'TNMAchievementManager'.default.varAchievementsCAT8[i])))
				{
					bKillCoat = True;
					break;
				}
			}
		}*/
		if (!bKillCoat)
		{
			for (i = 0; i < ArrayCount(class'TNMAchievementManager'.default.varAchievementsCAT9); i++)
			{
				if (!bool(Player.GetPropertyText(class'TNMAchievementManager'.default.varAchievementsCAT9[i])))
				{
					bKillCoat = True;
					break;
				}
			}
		}
		if (bKillCoat)
		{
			foreach AllActors(class'ABICoatBag', coat)
			{
				coat.bHidden=True;
				coat.Destroy();
			}
		}

		// Make sure Phas is friendly if Scara sends you to kill  him (a little backwards, yes)
		if (flags.GetBool('QR_MAIN_KillPhas') && !flags.GetBool('QC_MAIN_KillPhas'))
		{
			foreach AllActors(class'TNMPawn',p,'Phasmatis')
				p.ChangeAlly('Player', 1.000000, false);
		}

		//place the datacube for the NVShacker quest in the world
		/*if(flags.GetBool('QR_SUB_SubwayMoneyAlt') && !flags.GetBool('MS_NVSDatacube_Placed'))
		{
			foreach AllActors(class'TNMInformationDevices',id,'NVShackerDatacube')
				id.EnterWorld();
			flags.SetBool('MS_NVSDatacube_Placed',true,,21);
		}*/
	}
	else if (localURL == "20_LLAMATEMPLE")
	{
		if (!flags.GetBool('Silver_Dead') && !flags.GetBool('MS_SilverInTemple'))
			flags.SetBool('MS_SilverInTemple',true,,21);

		// Spawn the key to the tunnel door and make the door pickable when the player has the quest or becomes allied to the Llamas
		if (((flags.GetBool('QR_CULT_DestroyTheTablets') && !flags.GetBool('DarkTemplar_Dead') && !flags.GetBool('DarkTemplar_Unconscious')) || flags.GetBool('ALLIED_CULT_LLAMA')) && !flags.GetBool('MS_SpawnedLlamaKey'))
		{
			n = NanoKey(SpawnItemAt("DeusEx.NanoKey", 'TunnelKeySpawn'));
			n.Description=strLlamaKey;
			n.ItemName=strPassword;
			n.KeyID = 'LlamaTunnelDoorKey';
			foreach allactors(class'deusexmover',M,'LlamaTunnelDoor')
				M.bPickable = true;
			flags.SetBool('MS_SpawnedLlamaKey',true,,21);
		}
	}
	else if (localURL == "20_PDXHQ01")
	{
		// Move King Kashue to Evil's office after the spyware mission
		if (flags.GetBool('QC_MAIN_WCSpyware') && !flags.GetBool('QR_MAIN_ShadowCode'))
		    foreach AllActors( class'TNMPawn',p,'KingKashue_Evil')
			p.EnterWorld();

		// Move King Kashue back after the server complex
		if (flags.GetBool('QC_MAIN_ShadowCode') && !flags.GetBool('QR_MAIN_Firestaff'))
		    foreach AllActors( class'TNMPawn',p,'KingKashue_Evil')
			p.LeaveWorld();

		// Spawn a new aug and some equipment for the player when he's completed WCSpyware
		if (flags.GetBool('QC_MAIN_WCSpyware') && !flags.GetBool('MS_20_SpawnedWCSpywareReward'))
		{
			flags.SetBool('MS_20_SpawnedWCSpywareReward',true,,21);

			SpawnItemAt("TNMItems.AugCannisterSS", 'JonasAugSpawn');
			SpawnItemAt("DeusEx.Medkit" , 'WinqSpawn1');
			SpawnItemAt("TNMItems.Ammo45" , 'WinqSpawn2');
			SpawnItemAt("DeusEx.WeaponModRange" , 'WinqSpawn3');
		}

		// Spawn some stuff for the player in the armoury for the firestaff mission
		if (flags.GetBool('QC_MAIN_ShadowCode') && !flags.GetBool('MS_SpawnedShit'))
		{
			flags.SetBool('MS_SpawnedShit', true, , 21);

			SpawnItemAt("TNMItems.WeaponFatRifle" , 'FatRifleSpawn');
			SpawnItemAt("DeusEx.Lockpick" , 'WinqSpawn1');
			SpawnItemAt("DeusEx.BioelectricCell" , 'WinqSpawn2');
			SpawnItemAt("TNMItems.AmmoFatRifle" , 'WinqSpawn3');
		}

		// For the WC mission, spawn the PHAT-Rifle and send a PM about it from TG
		if (flags.GetBool('HAS_Newsscript') && !flags.GetBool('MS_SpawnedShit'))
		{
			flags.SetBool('MS_SpawnedShit', true, , 21);

			SpawnItemAt("TNMItems.WeaponFatRifle" , 'FatRifleSpawn');
			SpawnItemAt("TNMItems.AmmoFatRifle" , 'WinqSpawn3');

			SendPM("PM_TG_PHATRifle");
		}

		// Close the aug container if it's open
		foreach AllActors(class'deusexmover',m,'AugContainerField')
		{
			if (m.keynum == 1)
			{
				m.GotoState( 'TriggerControl', );
				m.untrigger(self,none);
			}
		}
	}
	else if (localURL == "20_PDXHQ02")
	{
		// When the player needs to find Despot...
		if (flags.GetBool('HAS_Newsscript'))
		{
			// Make the datacube with Despot's password appear
			foreach allactors(class'TNMInformationDevices',id,'DespotOfficeDatacube')
				id.EnterWorld();

			// And spawn four more guards
			foreach Allactors(class'TNMPawn',p,)
			{
				if ((p.Tag == 'DXAGuard_Mark1')||(p.Tag == 'DXAGuard_Mark2')||(p.Tag == 'DXAGuard_Mark3')||(p.Tag == 'DXAGuard_Mark4'))
					p.EnterWorld();
			}
		}

		// Move King Kashue to Evil's office and make Phas appear in KK's office after the spyware mission
		if (flags.GetBool('QC_MAIN_WCSpyware'))
		{
			if (!flags.GetBool('QC_MAIN_ShadowCode'))
				foreach Allactors(class'TNMPawn',p,'KingKashue')
					p.LeaveWorld();

			foreach Allactors(class'TNMPawn',p,'Phasmatis')
				p.EnterWorld();
		}

		if(flags.GetBool('QC_MAIN_ShadowCode'))
		{
			n=Spawn(Class'NanoKey',,,Location);
			n.InitialState='Idle2';
			n.KeyID='DXIYardGate';
			n.Description=strDXIKey;
			foreach Allactors(class'TNMPawn',p,'KingKashue')
			{
				n.GiveTo(p);
				n.SetBase(p);
				break;
			}
		}

		// Move King Kashue back after the server complex
		if (flags.GetBool('QC_MAIN_ShadowCode') && !flags.GetBool('QR_MAIN_Firestaff'))
			foreach Allactors(class'TNMPawn',p,'KingKashue')
				p.EnterWorld();
				
		if (trestkon(player).bunlockedSword)
		{
			foreach AllActors(class'DeusExMover', M, 'NGHatch')
			{
				M.bHighlight=True;
				M.bFrobbable=True;
			}
		}
	}
	else if (localURL == "20_DESPOT")
	{
		// Count bodies
		if (!flags.GetBool('KillCount_PDXDone'))
		{
//			if (flags.GetInt('KillCount_PDXFloor1') + flags.GetInt('KillCount_PDXFloor2')
//			    == ExpectedLiving("20_PDXHQ01") + ExpectedLiving("20_PDXHQ01"))
//			{
//				SkillAward(200,"Massacre Award");
//			}

			if (flags.GetInt('KillCount_PDXFloor1') + flags.GetInt('KillCount_PDXFloor2') > PDXFloor1AggressiveKills)
			{
				flags.SetBool('Killer_PDX',true,,23);
			}

//			if ((flags.GetInt('KillCount_PDXFloor1') == 0)&& //gogo short circuit evaluation
//			    (flags.GetInt('KillCount_PDXFloor2') == 0))
//			{
//				SkillAward(200,"Pacifist Award");
//			}

			flags.SetBool('KillCount_PDXDone',true,,23);
		}
	}
	else if (localURL == "20_FCDOWNTOWN")
	{
		SetupPortal('FC_Current_Booth','FC_Current_Booth_Sound');

		//Close sols if the player caused trouble there
		if ( flags.GetBool('MS_CloseSols'))
		{
			SealDoor('SolsDoor');

			// Remove the drunk girl at the door
			foreach allactors(class'TNMPawn',p,'GPFemale5')
			{
				if (p.BindName == "DowntownFemale04")
					p.LeaveWorld();
			}
		}

		// Clean up after the first mission
		if (((LastMap() == "20_FCCORPORATE") || (LastMap() == "20_FCSLUMS") || (LastMap() == "20_VOODOOSHOP")) && !flags.GetBool('MS_DTCleanup_Done'))
		{
			// Disable all the mission convos for the firewall agent
			foreach allactors(class'TNMPawn',p , )
			{
				if (p.BindName == "DowntownFirewall")
				{
					p.BindName = "Firewall";
					p.ConBindEvents();
				}
			}

			if (flags.GetBool('QC_SUB_N00Bz'))
			{
				if (flags.GetBool('Master_Kale_Dead') || flags.GetBool('N00Bz_Dead'))
					foreach allactors(class'TNMPawn',p, 'N00BFirewalls')
						p.EnterWorld();
				if (!flags.GetBool('Master_Kale_Dead'))
					foreach allactors(class'TNMPawn',p, 'Master_Kale')
						p.LeaveWorld();
				if (!flags.GetBool('N00Bz_Dead'))
					foreach allactors(class'TNMPawn',p, 'N00B')
						p.LeaveWorld();
			}
			else
			{
			        if (!flags.GetBool('N00Bz_Dead'))
					foreach allactors(class'TNMPawn', p, 'N00B')
						KillPawn(p);
			        if (!flags.GetBool('Master_Kale_Dead'))
					foreach allactors(class'TNMPawn',p, 'Master_Kale')
						KillPawn(p);
				foreach allactors(class'TNMPawn', p, 'N00BFirewalls')
					p.EnterWorld();

				if (flags.GetBool('QR_SUB_N00Bz'))
					AddGoal('N00Bz', strGoalN00Bz, FALSE, TRUE);
			}

			// Remove the body of the Llama hostage
			foreach allactors(class'TNMCarcass',carc, 'LlamaHostage')
	        		carc.LeaveWorld();

			// ...and close the goal
			if (!flags.GetBool('QC_SUB_LlamaRescue'))
			{
				flags.SetBool('LlamaHostage_Dead',true,,21);

				if (flags.GetBool('QR_SUB_LlamaRescue'))
					AddGoal('LlamaRescue', strGoalAbom, FALSE, TRUE);
			}

			// ...and remove the kidnappers
			foreach allactors(class'TNMPawn',p, 'GoatKidnapper')
				p.LeaveWorld();

			// ...and remove the goal add trigger
			foreach allactors(class'GoalAddTrigger',g, 'LlamaHostageGoalUpdate')
				g.Destroy();

			//Fix the ATM
//			foreach allactors(class'tnmatm',atm,)
//			{
//				atm.bOutOfOrder = false;
//				atm.UpdateOutOfOrder();
//			}								

			flags.SetBool('MS_DTCleanup_Done',true,,21);
		}

		// Make Kylie appear before the DXO mission
		if (flags.GetBool('QR_MAIN_GetNewsscript') && !flags.GetBool('Kylie_TOLD_Despot') && !flags.GetBool('Kylie_Unconscious'))
		{
			foreach allactors(class'TNMPawn',p, 'Kylie')
				p.EnterWorld();
		}

		// Make Kylie disappear again if the player pisses her off a second time
		if (flags.GetBool('Kylie_TOLD_DXO') && flags.GetBool('Kylie_Dislike'))
		{
			foreach allactors(class'TNMPawn',p, 'Kylie')
				p.LeaveWorld();
		}

		// Enable the player to open the portal to Goat City when he learns of its location
		if (flags.Getbool('DT_TOLD_GoatCity'))
			foreach AllActors(class'deusexmover', M, 'GoatPortalWall')
			{
				M.bFrobbable = true;
				M.bHighlight = true;
			}

		// Handle the awards for the goat city mission
		if ((LastMap() == "20_GOATCITY") && flags.GetBool('QC_CULT_DrainTheMelk') && !flags.GetBool('KillCount_GoatCityDone'))
		{
//			// Award Massacre Award
//			// if (flags.GetInt('KillCount_GoatCity') == GoatCityLiving)
//			//	SkillAward(200,"Massacre Award");

//			// Award Pacifist Award
//			if (flags.GetInt('KillCount_GoatCity') == 0)
//				SkillAward(200,"Pacifist Award");

//			// Award Stealth Award
//			//    when player hasn't been spotted
//				SkillAward(300,"Stealth Award"); // This is in addition to the Pacifist Award or Massacre Award

    			flags.SetBool('KillCount_GoatCityDone',true,,21);
		}
		// Handle the awards for the llama temple mission
		else if ((LastMap() == "20_LLAMATEMPLE") && flags.GetBool('QC_CULT_DestroyTheTablets') && !flags.GetBool('KillCount_LlamaTempleDone'))
		{
//			// Award Massacre Award
//			//if (flags.GetInt('KillCount_LlamaTemple') == LlamaTempleLiving)
//			//	SkillAward(200,"Massacre Award");

//    			// Award Pacifist Award
//			if (flags.GetInt('KillCount_LlamaTemple') == 0)
//				SkillAward(200,"Pacifist Award");

//			// Award Stealth Award
//			// when player hasn't been spotted
//				SkillAward(300, "Stealth Award"); // This is in addition to the Pacifist Award or Massacre Award

			flags.SetBool('KillCount_LlamaTempleDone',true,,21);
		}
	}
	else if (localURL == "20_FCCORPORATE")
	{
		SetupPortal('FC_Current_Booth','FC_Current_Booth_Sound');

		// Close the PartyZone if anybody there has been killed
		if ( flags.GetBool('MS_ClosePartyZone'))
		{
			SealDoor('PartyZoneDoor');
			foreach allactors( class'TNMPawn', p, 'Shaina')
				p.LeaveWorld();
		}

		// Send a PM from Scara if you went to the Slums first
		if (flags.GetBool('Scara_VisitedSlumsEarly'))
		    SendPM("PM_Scara_SlumsEarly");

		// Send a PM from Phas about the N00Bz mission
		if (flags.GetBool('QC_SUB_N00Bz'))
		    SendPM("PM_Phas_N00BzDebriefing");

		// Send an ominous PM from Scara after the spyware mission
		if (flags.GetBool('QC_MAIN_WCSpyware'))
		    SendPM("PM_Scara_PostSpywareThreat");

		// Make ZP appear before the PDX mission for WC
		if (flags.GetBool('HAS_Newsscript') && !flags.GetBool('QC_MAIN_GetNewsscript') && !flags.GetBool('Zero_Dead') && !flags.GetBool('Zero_Unconscious'))
		{
			foreach allactors(class'TNMPawn', p, 'ZeroPresence')
				p.EnterWorld();
		}

		// Open the doors to Despot's apartment if that's where you're coming from
		if (LastMap() == "20_DESPOT")
		{
			foreach allactors(class'deusexmover', m, 'DespotMover')
				OpenDoor(m);

			foreach allactors(class'trigger', t, 'DespotMoverTrigger')
				t.bInitiallyActive = true;

			// Make sure ZP is gone after the mission (just in case you never talked to him)
			foreach allactors(class'TNMPawn', p, 'ZeroPresence')
				p.LeaveWorld();
		}

		// Make Kaigen and the WC bots hostile if you're PDX- aligned
		if (flags.GetBool('ALLIED_PDX') || flags.GetBool('SD_Escaped') || flags.GetBool('Scara_Dead'))
		{
			foreach allactors(class'TNMPawn',p)
			{			
				if (p.Tag == 'FireWall2')
					p.ChangeAlly('Player',1.000000,true);
				else if (p.IsA('WCSecurity'))
					p.ChangeAlly('Player',-1.000000,true);
			}

			foreach allactors(class'TNMRobot',r)
			{
				if (r.Tag == 'WCHQPatrolBot')
					r.ChangeAlly('Player',-1.000000,true);
				else if (r.Tag == 'SecurityBot2PDX' || r.Tag == 'MilitaryBotPDX' || r.Tag == 'SecurityBot2PDXHQ')
					r.ChangeAlly('Player',1.000000,true);
			}
		}
		
		if (flags.GetBool('ALLIED_WC') && class'tnmconplay'.static.g_FlagSet('Killed_20_PDXHQ01_and_20_PDXHQ02_0', player))
		{	
			foreach allactors(class'TNMRobot',r)
			{
				if (r.Tag == 'SecurityBot2PDXHQ')
					r.ChangeAlly('Player',-1.000000,true);
			}
		}

		// Handle the awards for the WCHQ mission
		if (((LastMap() == "20_WCFLOOR1") || (LastMap() == "20_WCFLOOR2")) &&
		    flags.GetBool('QC_MAIN_WCSpyware') && !flags.GetBool('KillCount_WCHQDone'))
		{
//			// Award Massacre Award
//			//if (flags.GetInt('KillCount_WCFloor1') + flags.GetInt('KillCount_WCFloor2')
//			//   + flags.GetInt('KillCount_WCFloor3')
//			//    == WCFloor1Living + WCFloor2Living + WCFloor3Living)
//			//	SkillAward(200,"Massacre Award");

//			// Award Pacifist Award
//			if (flags.GetInt('KillCount_WCFloor1') + flags.GetInt('KillCount_WCFloor2')
//			    + flags.GetInt('KillCount_WCFloor3') == 0)
//				SkillAward(200,"Pacifist Award");

//			// Award Stealth Award
//			//when player hasn't been spotted
//				SkillAward(300,"Stealth Award"); // This is in addition to the Pacifist Award or Massacre Award

			flags.SetBool('KillCount_WCHQDone',true,,23);
		}
	}
	else if (localURL == "20_FCSLUMS")
	{
		SetupPortal('FC_Current_Booth','FC_Current_Booth_Sound');

		// Send a PM from Phasmatis if you haven't visited PDX or WC yet
		if (!flags.GetBool('QC_VisitFaction') && !flags.GetBool('QC_MAIN_SaveSD'))
		    SendPM("PM_Phas_SlumsEarly");

		// When it's time to go to DXI...
		if (flags.GetBool('QR_MAIN_Firestaff') && !flags.GetBool('MS_DXIPrepared'))
		{
			// Make Pimp-Jojo and one of the holograms appear
		        foreach AllActors( class'TNMPawn',p,)
			{
				// PJ has dialogue for WC but his whole point is that the quest
				// is a test to see if PDX Trest would help DXO against GS so it
				// doesn't make sense for WC player, especially since they likely
				// killed the rest of DXO when stealing the script
				if ((p.Tag == 'PimpJojo') && flags.GetBool('ALLIED_PDX'))
					p.EnterWorld();
				else if ((p.Tag == 'ScaraHologram') && flags.GetBool('ALLIED_PDX'))
					p.EnterWorld();
				else if ((p.Tag == 'KKHologram') && flags.GetBool('ALLIED_WC'))
					p.EnterWorld();
			}

			// Remove the mechanic
			foreach allactors(class'TNMPawn',p,'SiloMechanic')
				p.LeaveWorld();

			// Spawn the datacube at the silos
			foreach allactors(class'TNMInformationDevices',id,'SiloMechanicDatacube')
				id.EnterWorld();

			// Open the gate to the excavation site
			foreach allactors(class'deusexmover',m,'SiloGate')
				OpenDoor(m);

			flags.SetBool('MS_DXIPrepared',true,,21);
		}
	}
	else if (localURL == "20_WEAPONSHOP")
	{
		if (flags.GetBool('HotelMissionComplete') && !flags.GetBool('MS_HooverSpawned'))
		{
			foreach allactors(class'TNMRobot',r)
			{
				if (r.Tag == 'HooverContact')
					r.EnterWorld();
				else if (r.Tag == 'TransientBot')
					r.LeaveWorld();
			}
			flags.SetBool('MS_HooverSpawned',true,,21);
		}
		// A punishment for betrayal
		if (flags.GetBool('PM_Hoover_TurnIn_Played') && !flags.GetBool('MS_Hoover_TurnIn'))
		{
			foreach allactors(class'actor',a,'HooverCredits')
			{
				a.Destroy();
			}
			flags.SetBool('MS_Hoover_TurnIn',true,,21);
		}
	}
	else if (localURL == "20_SOLSBAR")
	{
		// Remove Kylie and make sure ZP is gone before the DXO mission
		if (flags.GetBool('QR_MAIN_GetNewsscript'))
		{
			if(flags.GetBool('Kylie_Dead') || flags.GetBool('Kylie_Unconscious'))
			{
				foreach allactors(class'keypad',kp,'DXOKeypad')
				{
					kp.hackstrength=0.0;
					kp.bHackable=true;
				}
				flags.SetBool('DXOSpy',true,,21);
			}

			foreach allactors(class'TNMPawn',p,)
			{
				if ((p.Tag == 'Kylie')||(p.Tag == 'ZeroPresence'))
					p.LeaveWorld();
			}
		}

		// Handle the awards for the DXO mission
		if ((LastMap() == "20_DXO") && flags.GetBool('HAS_Newsscript') && !flags.GetBool('KillCount_DXODone'))
		{
//			// Award Massacre Award
//			//if (flags.GetInt('KillCount_DXO') == DXOLiving)
//			//	SkillAward(200,"Massacre Award");

			// Identify the player as a killer
			if (flags.GetInt('KillCount_DXO') >= DXOAggressiveKills)
				flags.SetBool('Killer_DXO',true,,23);

//			// Award Pacifist Award
//			if (flags.GetInt('KillCount_DXO') == 0)
//				SkillAward(200,"Pacifist Award");

//			// Award Stealth Award
//			//when player hasn't been spotted
//				SkillAward(300,"Stealth Award"); // This is in addition to the Pacifist Award or Massacre Award

			flags.SetBool('KillCount_DXODone',true,,21);
		}

		// Make the gambler appear once the player has the subway pass
		if (flags.GetBool('HAS_SubwayPass') && !flags.GetBool('MS_SolsTrouble') && !flags.GetBool('MS_CloseSols'))
			foreach allactors(class'TNMPawn',p,'Gambler')
				p.EnterWorld();

		// If the player pissed Kylie off during the DXO briefing, make her leave
		if (flags.GetBool('Kylie_Dislike'))
			foreach allactors(class'TNMPawn',p,'Kylie')
				p.LeaveWorld();
	}
	else if (localURL == "20_VOODOOSHOP")
	{
		// SetupPortal('VoodooShop1','FC_Current_Booth_Sound');
		// SetupPortal('VoodooShop2','FC_Current_Booth_Sound');
		// SetupPortal('VoodooShop3','FC_Current_Booth_Sound');

		// Spawn DT when he wants to meet the player
		if (flags.GetBool('QR_CULT_FindTheGoats') && !flags.Getbool('DT_TOLD_GoatCity'))
			foreach allactors(class'TNMPawn',p,'DarkTemplar_VoodooShop')
				p.EnterWorld();

		// Make sure Dark Templar disappears after telling you where Goat City is
		if (flags.GetBool('DT_TOLD_GoatCity'))
		{
			foreach allactors(class'TNMPawn', p, 'DarkTemplar_VoodooShop')
				p.LeaveWorld();

//			foreach allactors(class'TNMCarcass', carc, 'DarkTemplar_VoodooShop')
//				carc.LeaveWorld();
		}

		// Make sure WC Guy disappears after the overheard
		if (flags.GetBool('YardbombOverheard_Played'))
		{
			foreach allactors(class'TNMPawn', p, 'WCGuy')
				p.LeaveWorld();
		}
	}
	else if (localURL == "20_GOATCITY")
	{
		if(!flags.GetBool('MS_GoatCityGoalsSet'))
		{
			if(flags.GetBool('QR_MAIN_StealPassword'))
			{
				AddGoal('ServerComplex',strGoalServerComplex,true,false);			
			}

			if(flags.GetBool('QR_MAIN_ShadowCode'))
			{
				AddGoal('ShadowCode',strGoalShadowCode, true, false);
			}
			flags.SetBool('MS_GoatCityGoalsSet',true,,21);
		}
		// Make sure DT appears when he's supposed to and says the right things
		if (flags.GetBool('QC_CULT_GetThePlans'))
		{
			foreach allactors(class'TNMPawn',p,'DarkTemplar')
				p.EnterWorld();
			flags.SetBool('DT_IsInGoatCity',True,,21);
		}
		// Make DT disappear into the Templae after the server complex mission
		if (flags.GetBool('QC_MAIN_ShadowCode') || flags.GetBool('QC_MAIN_StealPassword'))
		{
			foreach allactors(class'TNMPawn',p,'DarkTemplar')
				p.LeaveWorld();

			foreach allactors(class'TNMCarcass',carc,'DarkTemplar')
				carc.LeaveWorld();
		}

		// Make the valves highlight and frobbable when you get the mission (it's cheap but FUCK IT)
		if (flags.GetBool('QR_CULT_DrainTheMelk') && !flags.GetBool('Beefman_Dead') && !flags.GetBool('Beefman_Unconscious'))
		{
			foreach allactors(class'TNMDecoration',D)
			{
				if ((D.Tag == 'MelkValve1') || (D.Tag == 'MelkValve2'))
				{
					D.bFrobbable = True;
					D.bHighlight = True;
				}
			}
		}
	}
	else if (localURL == "20_GOATTEMPLAE")
	{
		// Make sure DT appears when he's supposed to
		if ((flags.GetBool('QC_MAIN_ShadowCode') || flags.GetBool('QC_MAIN_StealPassword')) && !flags.GetBool('DarkTemplar_Dead'))
		{
			foreach allactors(class'TNMPawn',p,'DarkTemplar')
				p.EnterWorld();

			flags.SetBool('DarkTemplar_Unconscious',false,,0);
		}
	}
	else if ((localURL == "20_WCFLOOR1")||(localURL == "20_WCFLOOR2")||(localURL == "20_WCFLOOR3"))
	{
		// Send an introductory message from That Guy once you've joined WC
		if (flags.GetBool('ALLIED_WC'))
			SendPM("PM_TG_Introduction");

		// Send a message from Evil with some maps and another objective
		if (flags.GetBool('QR_MAIN_WCSpyware'))
			SendPM("PM_Evil_Spyware");

		// Disable the cameras if you've got Black ICE to turn them off
		if (flags.GetBool('WCHQ_CamerasOffline'))
		{
			foreach allactors(class'securitycamera',c,)
				c.bActive = false;
		}
	}
	else if (localURL == "20_WCFLOOR4")
	{
		// Spawn a new aug for the player when he's completed GetNewsscript
		if (flags.GetBool('QC_MAIN_GetNewsscript') && !flags.GetBool('MS_20_SpawnedAugGetNewsscript'))
		{
			flags.SetBool('MS_20_SpawnedAugGetNewsscript',true,,21);
			SpawnItemAt("TNMItems.AugCannisterSS",'FireplaceAugSpawn');
		}

		// Close the fireplace safe if it's open
		foreach AllActors(class'deusexmover',m,'Fireplace_Safe')
		{
			if (m.keynum == 2)
			{
				foreach allactors(class'actor',a,'Fireplace_Events')
					a.Trigger(none,none);
			}
		}

		// Disable the cameras if you've got Black ICE to turn them off
		if (flags.GetBool('WCHQ_CamerasOffline'))
		{
			foreach allactors(class'securitycamera',c,)
				c.bActive = false;
		}

		if (flags.GetBool('QC_MAIN_StealPassword'))
		{
			n=Spawn(Class'NanoKey',,,Location);
			n.InitialState='Idle2';
			n.KeyID='DXIYardGate';
			n.Description=strDXIKey;
			foreach Allactors(class'TNMPawn',p,'ScaraKing')
			{
				n.GiveTo(p);
				n.SetBase(p);
				break;
			}
		}
	}
	else if (localURL == "20_WCSUBLEVEL") //WTF FUCKING CAPS SENSITIVE
	{
		// Handle all the stuff that's supposed to happen if Slicer escapes on his own
		if (flags.GetBool('QC_MAIN_KillPhas'))
		{

			foreach AllActors(class'TNMPawn', p, 'slicer')
				p.LeaveWorld();

			foreach AllActors(class'DeusExMover', M, 'SlicerCellDoor')
			{
				M.bLocked = False;
				M.lockStrength = 0.0;
			}

			if (!flags.GetBool('WCPrisonGuard_Dead'))
			{
				foreach allactors(class'TNMPawn',p,'WCPrisonGuard')
					p.LeaveWorld();
				foreach allactors(class'TNMCarcass',carc,'WCPrisonGuardCorpse')
					carc.EnterWorld();
			}				
		}

		// Disable the cameras if you've got Black ICE to turn them off
		if (flags.GetBool('WCHQ_CamerasOffline'))
		{
			foreach allactors(class'securitycamera',c,)
				c.bActive = false;
		}
	}
	else if (localURL == "20_NSC")
	{
		// -------------------------------------------
		// Conclude the cult missions (ARGH MY BRAIN!)
		// -------------------------------------------
		if (flags.GetBool('DT_GaveFakePlans') && flags.GetBool('QC_CULT_FindTheGoats'))
		{
			flags.SetBool('ALLIED_CULT_GOAT',false,,0);

			if (!flags.GetBool('DarkTemplar_Dead') && !flags.GetBool('DarkTemplar_Unconscious'))
			{
				flags.SetBool('DT_Pissed',true,,23);
				SendPM("PM_CULT_FakePlans_Leak");
			}
		}
		if (flags.GetBool('DT_GaveFakePlans') && !flags.GetBool('QC_CULT_FindTheGoats'))
		{
			flags.SetBool('ALLIED_CULT_GOAT',false,,0);
			flags.SetBool('ALLIED_CULT_LLAMA',false,,0);

			if (!((flags.GetBool('Abomination_Dead')||flags.GetBool('Abomination_Unconscious')) &&
			      (flags.GetBool('DarkTemplar_Dead')||flags.GetBool('DarkTemplar_Unconscious'))))
			{
				SendPM("PM_CULT_FakePlans_NoLeak");
			}
		}
		if (flags.GetBool('DT_GaveRealPlans') && flags.GetBool('QC_CULT_FindTheGoats'))
		{
			flags.SetBool('ALLIED_CULT_GOAT',false,,0);
			flags.SetBool('ALLIED_CULT_LLAMA',false,,0);

			if (!((flags.GetBool('Abomination_Dead')||flags.GetBool('Abomination_Unconscious')) &&
			      (flags.GetBool('DarkTemplar_Dead')||flags.GetBool('DarkTemplar_Unconscious'))))
			{
				SendPM("PM_CULT_RealPlans_Leak");
			}
		}
		if (flags.GetBool('DT_GaveRealPlans') && !flags.GetBool('QC_CULT_FindTheGoats'))
		{
			flags.SetBool('ALLIED_CULT_LLAMA',false,,0);

			if (!flags.GetBool('Abomination_Dead') && !flags.GetBool('Abomination_Unconscious'))
			{
				flags.SetBool('Abom_Pissed',true,,23);
				SendPM("PM_CULT_RealPlans_NoLeak");
			}
		}

		if (flags.GetBool('ALLIED_PDX'))
		{
			if (!flags.GetBool('QC_MAIN_ShadowCode'))
			{
				// Spawn ManInBlack in the lobby, remove the patrolling firewall from the top floor
				foreach Allactors(class'TNMPawn',p,)
				{
					if (p.Tag == 'MiB_Lobby')
						p.EnterWorld();
					else if (p.Tag == 'UpperLobbyPatrollers')
						p.LeaveWorld();
				}

				// Seal the irrelevant (WC-specific) parts of the complex
				foreach allactors(class'deusexmover', M)
				{
					if ((M.Tag == 'LobbyDoors02') || (M.Tag == 'ServerRoomsABDoors') || (M.Tag == 'ServerRoomCDoors1'))
					{
						M.GotoState( 'TriggerControl',  );
						M.trigger(self,none);
						M.bLocked = true;
					}
				}
			}
			else
			{
				// Remove ManInBlack in the lobby after ShadowCode has been deleted
				foreach Allactors(class'TNMPawn',p,)
				{
					if (p.Tag == 'MiB_Lobby')
						p.LeaveWorld();
				}
			}
		}
		if (flags.GetBool('ALLIED_WC'))
		{
			// Spawn ManInBlack in the mainframe room
			foreach Allactors(class'TNMPawn',p,'MiB_Mainframe')
				p.EnterWorld();

			// Make everybody but Jim, Eric, and Thomas Good hostile
			foreach Allactors(class'TNMPawn',p,)
			{
				if ((p.Tag != 'Jim') && (p.Tag != 'Eric') && (p.Tag != 'ThomasGood'))
					p.ChangeAlly('Player', -1.000000, true);
			}
			foreach Allactors(class'TNMRobot',r,'SecurityBot3PDX')
				r.ChangeAlly('Player', -1.000000, true);

			// Activate the security cameras
			foreach Allactors(class'securitycamera',c,)
				c.bNoAlarm = False;
		}

		// Set the elevator off immediately if you come in from OSC
		if (LastMap() == "20_OSC01")
		{
			foreach allactors(class'sequencetrigger', seq, 'OSCMainElevator_Seq00')
				seq.Trigger(Self, Player);
		}
	}
	else if (localURL == "20_OSC01")
	{
		// Set the elevator off immediately if you come in from NSC
		if (LastMap() == "20_NSC")
		{
			foreach allactors(class'sequencetrigger', seq, 'OSCMainElevator_Seq01')
				seq.Trigger(Self, Player);
		}

		// Unlock the door from the OSC04 stairs when ShadowCode is done for
		if (flags.GetBool('QC_MAIN_ShadowCode'))
		{
			foreach allactors(class'DeusExMover', M, 'OSC04Door')
				M.bLocked=False;
		}
		
		if (!flags.GetBool('20_MineOwnerSetup'))
		{
			foreach AllActors(class'ThrownProjectile', aMine, 'YeahRIP')
				break;
				
			if (aMine != None)
			{
				foreach AllActors(class'TNMPawn', P, 'MineOwner')
				{
					aMine.SetOwner(P);
					break;
				}
			}
			flags.SetBool('20_MineOwnerSetup', True,, 21);
		}
	}
	else if (localURL == "20_DXO")
	{
		if(flags.GetBool('DXOSpy'))
		{
			foreach allactors(class'TNMCarcass',carc,'WCSpy')
				carc.EnterWorld();
			foreach allactors(class'TNMInformationDevices',id,'WCSpyConfession')
				id.EnterWorld();
		}
		
		if (flags.GetBool('QR_MAIN_GetNewsscript'))
		{
			SendPM("PM_TG_DXO");
		}
	}

	//handle the elevator hatch and keypad persistance
	if (left(localURL,5) == "20_WC")
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
	else if (localURL == "20_FCCORPSEWERS")
	{
		// Disable the cameras if you've got Black ICE to turn them off
		if (flags.GetBool('WCHQ_CamerasOffline'))
		{
			foreach allactors(class'securitycamera',c,)
				c.bActive = false;
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
	local deusexmover m;
	local int i, result;
	local Actor tmp;
	local Inventory inv;
	local FlagBase f;
	local TNMPawn p;
	local keypad kp;
	local DeusExMover Mover;
	
	if (flags == none)
		flags = deusexplayer(getplayerpawn()).flagbase;

	if (localURL == "20_FCDOWNTOWN")
	{
		// Set a flag to make Bulletin29 appear if the player has broken into a shop
		if (flags.GetBool('BreakAndEnter'))
			flags.SetBool('MS_BreakAndEnter',true,,21);
	}
	else if (localURL == "20_SOLSBAR")
	{
		// This is a player-centric delay in posting the bulletin about trouble in the bar
		if (flags.GetBool('MS_SolsTrouble'))
			flags.SetBool('MS_SolsTrouble_Post',true,,23);
	}
	else if (localURL == "20_FCCORPORATE")
	{
		// Make ZP disappear after you've talked to him
		if (flags.GetBool('ZeroPDXMission_Played'))
		{
			foreach allactors(class'TNMPawn', p, 'ZeroPresence')
				p.LeaveWorld();
		}
	}
	else if (localURL == "20_WCFLOOR1")
	{
		// Make Silver Dragon go away after he's been freed
		if (flags.GetBool('QC_MAIN_SaveSD'))
		{
			foreach allactors(class'TNMPawn', p, 'SD')
				p.LeaveWorld();
		}
		foreach AllActors(class'DeusExMover', Mover)
		{
			if (Mover.Tag == 'PElevator_Doors0' || Mover.Tag == 'elevator_door')
			{
				Mover.InterpolateTo(0,0);  // Instantly go back to closed position
				Mover.Enable( 'Trigger' ); // Allow us to instantly reopen it.
			}
		}
	}
	else if (localURL == "20_WCFLOOR2")
	{
		// Make Evil send the player some floor plans of WC
		// if (flags.GetBool('QR_MAIN_WCSpyware'))
			// SendPM("PM_Evil_Spyware");
		foreach AllActors(class'DeusExMover', Mover)
		{
			if (Mover.Tag == 'elevator_door')
			{
				Mover.InterpolateTo(0,0);  // Instantly go back to closed position
				Mover.Enable( 'Trigger' ); // Allow us to instantly reopen it.
			}
		}
	}
	else if (localURL == "20_WCFLOOR3")
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
	else if (localURL == "20_WCFLOOR4")
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
	else if (localURL == "20_WCSUBLEVEL")
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
	else if (localURL == "20_GOATCITY")
	{
		foreach AllActors(class'DeusExMover', Mover)
		{
			if (Mover.Tag == 'NSCElevator_Left' || Mover.Tag == 'NSCElevator_Right')
			{
				Mover.InterpolateTo(0,0);  // Instantly go back to closed position
				Mover.Enable( 'Trigger' ); // Allow us to instantly reopen it.
			}
		}
	}
	else if (localURL == "20_NSC")
	{
		foreach AllActors(class'DeusExMover', Mover)
		{
			if (Mover.Tag == 'NSCElevator_Left' || Mover.Tag == 'NSCElevator_Right')
			{
				Mover.InterpolateTo(0,0);  // Instantly go back to closed position
				Mover.Enable( 'Trigger' ); // Allow us to instantly reopen it.
			}
		}
	}
	else if (localURL == "20_PDXHQ01")
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
	else if (localURL == "20_PDXHQ02")
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
	else if (localURL == "20_DESPOT")
	{
		foreach AllActors(class'DeusExMover', Mover, 'FinalEffectBlock')
		{
			Mover.InterpolateTo(0,0);  // Instantly go back to closed position
		}
		foreach AllActors(class'DeusExMover', Mover, 'EscapeDoor')
		{
			Mover.InterpolateTo(1,0);  // Instantly go to 2nd keyframe.
		}
		foreach AllActors(class'DeusExMover', Mover, 'DropHatch')
		{
			Mover.InterpolateTo(1,0);  // Instantly go to 2nd keyframe.
		}
	}

	//handle the elevator hatch and keypad persistance
	if (left(localURL,5) == "20_WC")
	{
		foreach AllActors(Class'DeusExMover',m,'SublevelKeypadHatch')
		{
			flags.SetFloat('WC_ElevatorHatch_Strength',m.lockstrength,,21);
			flags.SetBool('WC_ElevatorHatch_Open',m.keynum==1,,21);
		}

		foreach AllActors(Class'Keypad',kp,'SublevelKeypad')
			flags.SetFloat('WC_ElevatorKeypad',kp.hackstrength,,21);
	}

	Super.PreTravel();
}

function DecrementTimers()
{
	DecrementTimer('TimerStarted_MeetPhasPM','Timer_MeetPhasPM');
	DecrementTimer('TimerStarted_MeetDTPM','Timer_MeetDTPM');
	DecrementTimer('TimerStarted_Quad7','Timer_Quad7');
	DecrementTimer('TimerStarted_Quad14','Timer_Quad14');
	DecrementTimer('TimerStarted_Quad17','Timer_Quad17');
	DecrementTimer('TimerStarted_Quad22','Timer_Quad22');
}

function HandleTimers()
{
	// And after a while, play the first PM from Phasmatis
	if ( IsTimerDone('TimerStarted_MeetPhasPM','Timer_MeetPhasPM') )
	{
		if (localURL == "20_FCDOWNTOWN")
		{
			if (trestkon(player).credits < 1000)	// NG+ check
				SendPM("PM_Phas_Subway");
		}
	}

	// And after a while, play the PM from DT
	if ( IsTimerDone('TimerStarted_MeetDTPM','Timer_MeetDTPM') )
	{
		if (((localURL == "20_FCDOWNTOWN") || (localURL == "20_FCCORPORATE") || (localURL == "20_FCSLUMS")) && !flags.Getbool('DT_TOLD_GoatCity'))
		{
			if ((flags.GetBool('QR_MAIN_ShadowCode') || flags.GetBool('QR_MAIN_StealPassword')) && flags.GetBool('Abomination_Dead')) // Not _Unconscious, use the regular PM for that
			{
				if (flags.GetBool('QR_CULT_GetThePlans'))
				{
					SendPM("PM_DT_AbortMission");
				}
				else
				{
					SendPM("PM_DT_AbomDead");
				}
			}
			else
			{
				SendPM("PM_DT_MeetMe");
			}
		}
	}

	if ( IsTimerDone('TimerStarted_Quad7','Timer_Quad7') )
	{
		DeleteTimer('TimerStarted_Quad7','Timer_Quad7');
		DoBang();
		SpawnLauncher();
		Electricity();
		DamageTrigger();
		PlayConstruct();
	}

	if ( IsTimerDone('TimerStarted_Quad14','Timer_Quad14') )
	{
		DeleteTimer('TimerStarted_Quad14','Timer_Quad14');
		SolidifyLauncher();
	}

	if ( IsTimerDone('TimerStarted_Quad17','Timer_Quad17') )
	{
		DeleteTimer('TimerStarted_Quad17','Timer_Quad17');
		Satellites();
	}

	if ( IsTimerDone('TimerStarted_Quad22','Timer_Quad22') )
	{
		DeleteTimer('TimerStarted_Quad22','Timer_Quad22');
		DropLauncher();
		ElectricityOff();
		DamageTrigger();
	}
}

// ----------------------------------------------------------------------
// Timer()
//
// Main state machine for the mission
// ----------------------------------------------------------------------

function Timer()
{
	local TNMPawn p;
	local int count;
	local TNMCarcass c;
	local securitycamera s;
	local deusexmover m;
	local datavaultimage image;
	local ambientsound barsound;
	local ZoneInfo aZone;
	local Vector newGravity;
	local InertialMover aFan;
	local float gravityMult;
	local Dispatcher dispatch;
	local int flagIterator;
	local Name flagName;
	local bool bPendingDrop;
	local Inventory sewerActor;
	local int tempValue;
	local SpawnPoint point;
	local Vector spawnLoc;
	local Trigger aTrigger;
	local Teleporter tele;
	local HackableDevices box;
	local Multitool tool;
	local bool bFound;			
	local Pawn curPawn;

	Super.timer();

	if (flags == none)
		flags = deusexplayer(getplayerpawn()).flagbase;

	// Handle the completion of the subway pass mission
	if (player != none && trestkon(player).credits >= 1000 && !flags.GetBool('QC_MAIN_SubwayMoney'))
	{
		if ((localURL == "20_FCDOWNTOWN") || (localURL == "20_SOLSBAR"))
		{
			if (!flags.GetBool('QR_MAIN_SubwayMoney'))
				sendPM("PM_Phas_SubwayEarly"); // NG+?
			else
				sendPM("PM_Phas_TestCompleted");
			SkillAward(1000, strPiggyBank);
			flags.SetBool('QC_MAIN_SubwayMoney',true,,0);
		}
	}
	
	if (localURL == "20_WCHOTEL")
	{/*
		if ((flags.GetBool('HotelMissionComplete') || flags.GetBool('Bogie_Deleted')) && !flags.GetBool('MS_BogieGoalRemoved'))
		{
			if (player != none)
			{
				player.GoalCompleted('BogieMission');
				flags.SetBool('MS_BogieGoalRemoved',true,,0);
			}
		}*/
		
		if ((flags.GetBool('Bogie_Dead') || flags.GetBool('Bogie_Unconscious')) && !flags.GetBool('MS_BogieGoal'))
		{
			foreach allactors(class'Dispatcher', dispatch, 'BogieLabDispatcher')
			{
				dispatch.Trigger(Player,Player);
			}
			flags.SetBool('MS_BogieGoal',true,,0);
		}
	}

	// Give Trestkon an alternative way to get the pass, in case he fucks up (or is extra explorative)
	if(player != none && trestkon(player).creditsearned >= 1500 && !flags.GetBool('HAS_SubwayPass'))
	{
		if((localURL == "20_FCDOWNTOWN") || (localURL == "20_SOLSBAR"))
			SendPM("PM_Scara_SubwayMoneyAlt");
	}
	else if (player != none && trestkon(player).creditsearned >= 250 && !flags.GetBool('HAS_SubwayPass'))	// If the player *REALLY* screws up there's only 980 credits to be had, give them a free pass at this point
	{
		if((!flags.GetBool('QC_SUB_SymDisc00') && !flags.GetBool('QC_SUB_SymDisc01') && !flags.GetBool('QC_SUB_SymDisc02')) && (flags.GetBool('Kunio_Dead') || flags.GetBool('Kunio_Unconscious')))
		{
			if ((!flags.GetBool('QC_SUB_N00Bz')) && (flags.GetBool('DowntownFirewall_Dead') || flags.GetBool('DowntownFirewall_Unconscious')))
			{
				if ((!flags.GetBool('QC_SUB_JimmyHeirloom')) && (flags.GetBool('jimmycracker_Dead') || flags.GetBool('jimmycracker_Unconscious')))
				{
					if ((!flags.GetBool('QC_SUB_LlamaRescue')) && (flags.GetBool('Abomination_Dead') || flags.GetBool('Abomination_Unconscious')))
					{
						if((localURL == "20_FCDOWNTOWN") || (localURL == "20_SOLSBAR"))
							SendPM("PM_Scara_SubwayMoneyAlt");
					}
				}
			}
		}
	}

	// Send an angry PM from Scara if the player kills Kylie
	if ((localURL == "20_FCDOWNTOWN") || (localURL == "20_SOLSBAR"))
	{
		if (flags.getbool('ALLIED_WC') && flags.getbool('Kylie_Dead') && !flags.getbool('Scara_TOLD_KylieKill'))
		{
			SendPM("PM_Scara_KilledKylie");
			flags.SetBool('Kylie_Dead_M20',true,,23);
			Trestkon(player).SetAchievement("achTeamkill");
		}
	}

	if (localURL == "20_FCDOWNTOWN")
	{
		if (!flags.GetBool('MS_achFanFic1') && flags.GetBool('Chris_Greetings_Played') && flags.GetBool('WaltonSimons_Greeting_Played'))
		{
			Trestkon(player).SetAchievement("achFanFic1");
			flags.SetBool('MS_achFanFic1', True,, 24);
		}
		
		if ( flags.getbool('Abom1_Played') || (flags.getbool('Abomination_Dead') && flags.getbool('Abom_SDSituationResolved')))
			foreach allactors(class'deusexmover', m, 'LlamaTempleDoors')
				m.bLocked=False;

		// After a while, play the first PM from Phasmatis
		AddTimer('TimerStarted_MeetPhasPM','Timer_MeetPhasPM', 10);

		// And after a while, play the PM from DT
		if (flags.GetBool('QR_CULT_FindTheGoats') || (flags.GetBool('Beefman_Dead') || flags.GetBool('Beefman_Unconscious') || flags.GetBool('CheckedBeefmanTurretsDrop')) || ((flags.GetBool('QR_MAIN_ShadowCode') || flags.GetBool('QR_MAIN_StealPassword')) && (flags.GetBool('Abomination_Dead') || flags.GetBool('Abomination_Unconscious'))))
			AddTimer('TimerStarted_MeetDTPM','Timer_MeetDTPM', 10);

		//Set a flag when all N00Bz are killed
		if ( !flags.GetBool('N00Bz_Dead') )
		{
			count = 0;
			foreach allactors(class'TNMPawn',p,'N00B')
			{
				count++;
				break;
			}
			if (count == 0)
			{
				foreach allactors(class'TNMCarcass',c,'N00B')
					if (c.bNotDead)
					{
						count++;
						break;
					}
					if (count == 0)
					{
						flags.SetBool('N00Bz_Dead',true,,21);
						if (!flags.GetBool('Master_Kale_Dead') && !flags.GetBool('Kale_InCustody'))
							SendPM("PM_Firewall_KilledGang");
					}
			}
		}

		if (flags.GetBool('N00Bz_Dead'))
		{
			if ( flags.GetBool('Master_Kale_Dead') )
				SendPM("PM_Firewall_KilledEveryone");
			else if ( flags.GetBool('Kale_InCustody') )
				SendPM("PM_Firewall_ArrestedKilled");
		}
		
		if (flags.GetBool('Master_Kale_Unconscious'))
			SendPM("PM_Firewall_KaleKnockout");

		foreach allactors(class'TNMCarcass',c,'N00B')
			if (c.bNotDead)
				SendPM("PM_Firewall_N00BKnockout");
			
		// FAIL the various missions if the player kills or knocks out the quest giver
		if ((flags.GetBool('QR_SUB_SymDisc01') || flags.GetBool('QR_SUB_SymDisc02')) && 
		    !flags.GetBool('QC_SUB_SymDisc00') && !flags.GetBool('QC_SUB_SymDisc01') && !flags.GetBool('QC_SUB_SymDisc02'))
		{
			if (flags.GetBool('Kunio_Dead'))
			{
				AddGoal('FindTheFloppy', strKunioDead, FALSE, TRUE);
				flags.SetBool('QC_SUB_SymDisc00',true,,21);
			}

			if (flags.GetBool('Kunio_Unconscious'))
			{
				AddGoal('FindTheFloppy', strKunioUnconscious, FALSE, TRUE);
				flags.SetBool('QC_SUB_SymDisc00',true,,21);
			}
		}
		if (flags.GetBool('QR_SUB_N00Bz') && !flags.GetBool('QC_SUB_N00Bz'))
		{
			if (flags.GetBool('DowntownFirewall_Dead'))
			{
				AddGoal('N00Bz', strFirewallDead, FALSE, TRUE);
				flags.SetBool('QC_SUB_N00Bz',true,,21);
			}

			if (flags.GetBool('DowntownFirewall_Unconscious'))
			{
				AddGoal('N00Bz', strFirewallUnconscious, FALSE, TRUE);
				flags.SetBool('QC_SUB_N00Bz',true,,21);
			}
		}
		if (flags.GetBool('QR_SUB_JimmyHeirloom') && !flags.GetBool('QC_SUB_JimmyHeirloom'))
		{
			if (flags.GetBool('jimmycracker_Dead'))
			{
				AddGoal('JimmyHeirloom', strJimmyDead, FALSE, TRUE);
				flags.SetBool('QC_SUB_JimmyHeirloom',true,,21);
			}

			if (flags.GetBool('jimmycracker_Unconscious'))
			{
				AddGoal('JimmyHeirloom', strJimmyUnconscious, FALSE, TRUE);
				flags.SetBool('QC_SUB_JimmyHeirloom',true,,21);
			}
		}
		if (flags.GetBool('QR_SUB_LlamaRescue') && !flags.GetBool('QC_SUB_LlamaRescue'))
		{
			if (flags.GetBool('Abomination_Dead'))
			{
				AddGoal('LlamaRescue', strAbomDead, FALSE, TRUE);
				flags.SetBool('QC_SUB_LlamaRescue',true,,21);
			}

			if (flags.GetBool('Abomination_Unconscious'))
			{
				AddGoal('LlamaRescue', strAbomUnconscious, FALSE, TRUE);
				flags.SetBool('QC_SUB_LlamaRescue',true,,21);
			}
		}

		// Close the Goat City goal if the player kills Abom
		if (flags.GetBool('QR_CULT_FindTheGoats') && !flags.GetBool('QC_CULT_FindTheGoats') && !flags.GetBool('MS_ClosedGoal_GoatCity'))
		{
			if (flags.GetBool('Abomination_Dead'))
			{
				AddGoal('FindTheGoats', strAbomDead2, FALSE, TRUE);

				if (flags.GetBool('QR_CULT_GetThePlans') && !flags.GetBool('QC_CULT_GetThePlans') && !flags.GetBool('DarkTemplar_Dead'))
					AddGoal('GetThePlans', strDarkTemplar, FALSE, FALSE);

				flags.SetBool('MS_ClosedGoal_GoatCity',true,,21);
			}
			else if (flags.GetBool('Abomination_Unconscious'))
			{
				AddGoal('FindTheGoats', strAbomUnconscious2, FALSE, TRUE);

				flags.SetBool('MS_ClosedGoal_GoatCity',true,,21);
			}
		}

		if(flags.GetBool('NVShacker_DatacubeUsed') && !flags.GetBool('HAS_NVShackerProgram') && !flags.GetBool('HAS_SubwayPass')
			&& (flags.GetBool('AlphaOperator_Unconscious') || flags.GetBool('AlphaOperator_Dead')))
		{
			SendPM("PM_NVS_MissedFloppy");
		}

		if(flags.GetBool('NVShacker_DatacubeUsed') && flags.GetBool('HAS_NVShackerProgram')
			 && !flags.GetBool('MS_NVShackerEvaluated') && !flags.GetBool('HAS_SubwayPass'))
		{
//			flags.SetBool('Killer_SolsBar',(flags.GetInt('20_SOLSBAR_COUNT')<flags.GetInt('20_SOLSBAR_STARTCOUNT')),,21);
			SendPM("PM_NVS_Evaluation");
//			flags.SetBool('MS_NVShackerEvaluated',true,,21);
		}

		if(flags.GetBool('NVShacker_DatacubeUsed') && flags.GetBool('HAS_SubwayPass'))
			SendPM("PM_NVS_GotPass");

		if(flags.GetBool('QR_SUB_SubwayMoneyAlt') && flags.GetBool('HAS_SubwayPass') && !flags.GetBool('MS_NVShackerDone'))
		{
			flags.SetBool('NVShacker_DatacubeErased',true,,21);
			if(!flags.GetBool('QC_SUB_SubwayMoneyAlt'))
				AddGoal('SubwayMoneyAlt',strSubPass,false,true);
			else
				AddGoal('SubwayMoneyAlt',strSubPassNVS,false,true);
			flags.SetBool('MS_NVShackerDone',true,,21);
		}
	}
	else if ((localURL == "20_FCCORPORATE") || (localURL == "20_FCSLUMS"))
	{
		// Autosave if this is the first time the player is leaving the Downtown sector
		if (!flags.GetBool('Autosaved_Downtown'))
		{
			trestkon(getplayerpawn()).autosave(true, 20);
			// if (trestkon(getplayerpawn()).autosave(true))
				// flags.SetBool('Autosaved_Downtown',true,,21);
		}
		
		if (flags.GetBool('ZPDev_Played') && !flags.GetBool('MS_PostZPDev'))
		{
			for (curPawn=Level.PawnList; curPawn!=None; curPawn=curPawn.NextPawn)
			{
				if (curPawn.BindName == "ZPDev" || curPawn.BindName == "Hawk")
				{
					ScriptedPawn(curPawn).LeaveWorld();
				}
			}
			flags.SetBool('MS_PostZPDev',true,,21);
		}
	}
	else if (localURL == "20_LLAMATEMPLE")
	{
		// Fail Beefman's mission if the player kills him after receiving it
		if ((flags.GetBool('Beefman_Dead')||flags.GetBool('Beefman_Unconscious')) && flags.GetBool('QR_CULT_DrainTheMelk') && !flags.GetBool('QC_CULT_DrainTheMelk') && !flags.GetBool('MS_DrainTheMelkFailed'))
		{
			AddGoal('DrainTheMelk',strBeefmanDead, FALSE, TRUE);
			flags.SetBool('MS_DrainTheMelkFailed',true,,21);
		}
	}
	else if (localURL == "20_VOODOOSHOP")
	{
		// Close Yardbomb's mission if you kill him after getting it but before completing it
		if ((flags.GetBool('Yardbomb_Dead')||flags.GetBool('Yardbomb_Unconscious')) &&
		     flags.GetBool('QR_SUB_VoodooStuff') && !flags.GetBool('QC_SUB_VoodooStuff') && !flags.GetBool('MS_VoodooStuffFailed'))
		{
			AddGoal( 'VoodooStuff', strYardbombDead , false, true);
			flags.SetBool('MS_VoodooStuffFailed',true,,21);
		}
		
		if ((flags.GetBool('Yardbomb_Dead')||flags.GetBool('Yardbomb_Unconscious')) &&
		!flags.GetBool('QC_SUB_VoodooStuff') && !flags.GetBool('MS_VoodooStuffFailed2'))
		{
			// Disable the actual teleporters
			foreach AllActors(class'Teleporter', tele, 'VoodooTele')
				Tele.bEnabled = False;
			flags.SetBool('MS_VoodooStuffFailed2',true,,21);
		}
		
		// 
		if (flags.GetBool('YardbombGreetings_Played') && !flags.GetBool('MS_YardbombAchievement'))
		{
			if (flags.GetBool('Yardbomb_AdvisedToSell'))
				Trestkon(Player).SetAchievement("achYardbombSell");
			else
				Trestkon(Player).SetAchievement("achYardbombStay");
			flags.SetBool('MS_YardbombAchievement',true,,21);
		}

		//  Dish out some skillpoints when you've completed the voodoo shop quest
		if (flags.GetBool('QC_SUB_VoodooStuff') && !flags.GetBool('MS_VoodooStuff_AwardGiven'))
		{
			SkillAward(200, strVoodooAward);
			flags.SetBool('MS_VoodooStuff_AwardGiven',true,,21);
			
			SetupPortal('VoodooShop1','FC_Current_Booth_Sound');
			SetupPortal('VoodooShop2','FC_Current_Booth_Sound');
			SetupPortal('VoodooShop3','FC_Current_Booth_Sound');
		}

		// Award some skillpoints when DT has divulged the location of Goat City
		if (flags.GetBool('DT_TOLD_GoatCity') && !flags.GetBool('MS_GoatCity_AwardGiven'))
		{
			SkillAward(250, strInvestigationAward);
			flags.SetBool('MS_GoatCity_AwardGiven',true,,21);
		}

		// Fail DT's mission if the player incapacitates him after receiving it
		if ((flags.GetBool('DarkTemplar_Dead')||flags.GetBool('DarkTemplar_Unconscious')) && flags.GetBool('QR_CULT_GetThePlans') && !flags.GetBool('QC_CULT_GetThePlans') && !flags.GetBool('MS_ClosedDTGoal'))
		{
			AddGoal( 'GetThePlans', strDarkTemplarDead , false, true);
			flags.SetBool('MS_ClosedDTGoal',true,,21);
		}
		// Close the MeetDT goal if the player incapacitates him before talking to him
		else if ((flags.GetBool('DarkTemplar_Dead')||flags.GetBool('DarkTemplar_Unconscious')) && !flags.GetBool('DT_AbomDead_Played') && !flags.GetBool('DT1_Played') && !flags.GetBool('MS_ClosedDTGoal'))
		{
			AddGoal( 'MeetDT', strDarkTemplarUnconscious , false, true);
			flags.SetBool('MS_ClosedDTGoal',true,,21);
		}

		// Update the player's goal when the player finds DT's photo
		if ( !flags.GetBool('DT_TOLD_GoatCity') )
		{
			image = player.FirstImage;
			while(image != None)
			{
				if (image.IsA('TNMDV_GoatPortal'))
				{
					flags.SetBool('DT_TOLD_GoatCity',true,,21);

					if (!flags.GetBool('Abomination_Dead') && !flags.GetBool('Abomination_Unconscious'))
						AddGoal( 'FindTheGoats', strDarkTemplarRobbed , false, false);

					if (flags.GetBool('QR_MAIN_ShadowCode'))
						AddGoal( 'ShadowCode', strShadowCode , true, false);
				}
				image = image.NextImage;
			}
		}
	}
	else if ((localURL == "20_GOATCITY") || (localURL == "20_GOATTEMPLAE"))
	{
		// Fail the Llama tablets mission if the player kills DT after receiving it
		if ((flags.GetBool('DarkTemplar_Dead')||flags.GetBool('DarkTemplar_Unconscious')) && flags.GetBool('QR_CULT_DestroyTheTablets') && !flags.GetBool('QC_CULT_DestroyTheTablets') && !flags.GetBool('MS_DestroyTheTablets_Failed'))
		{
			AddGoal('DestroyTheTablets', strDarkTemplarDead , false, true);
			flags.SetBool('MS_DestroyTheTablets_Failed',true,,21);
		}
	}
	else if (localURL == "20_FCCORPSEWERS")
	{
		if(!flags.GetBool('PM_PostDDL_Played'))
		{
			// Send the player a message from his Datalink Monkey after getting the map from DDL
			image = player.FirstImage;
			while(image != None)
			{
				if (image.IsA('TNMDV_QuadSchematics'))
				{
					SendPM("PM_PostDDL");
				}
				image = image.NextImage;
			}
		}
		
		if (flags.GetBool('MS_FlushedItem') && !flags.GetBool('MS_FlushedItemTriggers'))
		{
			forEach AllActors(class'Trigger', aTrigger, 'FlushTriggers')
				aTrigger.SetCollision(True,False,False);
			flags.SetBool('MS_FlushedItemTriggers',True,,23);
		}
		
		// If something has been flushed, push out one per second (prevent collision issues)
		if (flags.GetBool('FlushedItem'))
		{
			bPendingDrop = True;
			flagIterator = flags.CreateIterator();
			while(flags.GetNextFlagName(flagIterator, flagName))
			{
				// Can't use GetSpawnPoint because Biomod/Shifter make the game crash.
				// point = GetSpawnPoint('SpewPipe', False);
				foreach AllActors(class'SpawnPoint', point, 'SpewPipe')
				{
					break;
				}
				if (Left(string(flagName),11) == "SewerFlush_")
				{
					tempValue = flags.GetInt(flagName);
					bPendingDrop = True;
					if (point != None)
						spawnLoc = point.Location;
					else
						spawnLoc = Vect(-8352,-3277,-886); // if no point (old save) fudge it.
					sewerActor = Spawn(class<inventory>(class'tnmUtil'.static.LookupClass(Mid(string(flagName),11))),,,spawnLoc, Rotator(VRand()));
					if (sewerActor != None)
					{
						// Spew out randomly
						sewerActor.Velocity.X = FRand() * 40;
						sewerActor.Velocity.Y = FRand() * 400;
						if (Credits(sewerActor) != None) 			// Special case, combine all credits into one large one
						{
							Credits(sewerActor).numCredits = tempValue;
							flags.SetInt(flagName, 0, True, 23);
						}
						else if (Ammo(sewerActor) != None) 		// Special case, combine all ammo type into one large one,
						{
							Ammo(sewerActor).AmmoAmount = tempValue;
							flags.SetInt(flagName, 0, True, 23);
						}
						else if (DeusExWeapon(sewerActor) != None && DeusExWeapon(sewerActor).AmmoName != None && DeusExWeapon(sewerActor).AmmoName != Class'AmmoNone' && String(DeusExWeapon(sewerActor).AmmoName.Default.PickupViewMesh) == "DeusExItems.TestBox") // Special case, this is for grenades, throwing knives
						{
							DeusExWeapon(sewerActor).PickupAmmoCount = tempValue;
							if (DeusExWeapon(sewerActor).PickupAmmoCount > DeusExWeapon(sewerActor).AmmoName.Default.MaxAmmo)
								DeusExWeapon(sewerActor).PickupAmmoCount = DeusExWeapon(sewerActor).AmmoName.Default.MaxAmmo;
							flags.SetInt(flagName, 0, True, 23);
						}
						else
							flags.SetInt(flagName, tempValue-1, True, 23);
					}
					if (flags.GetInt(flagName) <= 0)
						flags.DeleteFlag(flagName, FLAG_Int);
					break;
				}
			}
			flags.DestroyIterator(flagIterator);
			if (!bPendingDrop)
				flags.SetBool('FlushedItem', False,,23);
		}
	}
	else if (localURL == "20_PARTYZONE")
	{
		// Dish out some skillpoints when you've completed grubs biocell quest
		/*
		if (flags.GetBool('QC_SUB_FetchBiocells') && !flags.GetBool('MS_FetchBiocells_AwardGiven'))
		{
			SkillAward(300, strShowGoOnAward);
			flags.SetBool('MS_FetchBiocells_AwardGiven',true,,21);
		}*/

		// Gradually turn down the ambient bar sound if you kill people until it's gone
		foreach allactors(class'AmbientSound', barsound, 'BarSound')
		{
			count = 0;
			foreach allactors(class'TNMPawn', p, )
			{
				if (p.Tag == 'GPBusinesswoman2' ||
				p.Tag == 'GabrielSyme' ||
				p.Tag == 'PZPatron1' ||
				p.Tag == 'PZPatron2' ||
				p.Tag == 'GPMale2' ||
				p.Tag == 'Dazza' ||
				p.Tag == 'PZScientistFemale' ||
				p.Tag == 'PZScientistMale' ||
				p.Tag == 'Equiverse' ||
				p.Tag == 'Pointman' ||
				p.Tag == 'Businessman05' ||
				p.Tag == 'Businessman06' )
					count++;
			}
			if ( ExpectedLiving(localURL) != 0 )
			{				
				barsound.SoundVolume = byte( Clamp((128.0 * (count - 4)) / 12, 0, 128) );
			}
		}
	}
	else if (localURL == "20_WCFLOOR1")
	{
		// Send the player an angry message from Kashue if he kills SD
		if (flags.GetBool('Silver_Dead') && !flags.GetBool('QC_MAIN_SaveSD') && !flags.GetBool('SD_KilledAnyway') && !flags.GetBool('QC_MAIN_KillSD'))
		{
			SendPM("PM_KilledSD");
			SkillAward(750, strDragonSlayerAward);
			flags.SetBool('QC_MAIN_KillSD',true,,0);
		}

		// Send the player an angry message from Scara if he saves SD (fucked if you do, fucked if you don't :P)
		if (flags.GetBool('QC_MAIN_SaveSD') && !flags.GetBool('MS_SavedSD_AwardGiven'))
		{
			SendPM("PM_SavedSD");
			SkillAward(750, strRescueSilver);
			flags.SetBool('MS_SavedSD_AwardGiven',true,,21);
		}

		// Reset the necessary flags and send a PM from both if the player kills SD after saving him
		if (flags.GetBool('QC_MAIN_SaveSD') && flags.GetBool('Silver_Dead') && !flags.GetBool('MS_SilverInTemple'))
			SendPM("PM_SavedThenKilledSD");
	}
	else if ((localURL == "20_WCFLOOR2") || (localURL == "20_WCFLOOR3"))
	{
		// Handle the completion of both objectives in the WC Spyware mission
		if (flags.GetBool('WCHQ_SpywarePlaced') && flags.GetBool('WCHQ_ESFDisabled'))
			SendPM("PM_Evil_SpywareQC");

		// Disable the cameras if you've got Black ICE to turn them off
		if (flags.GetBool('WCHQ_CamerasOffline'))
		{
			foreach allactors(class'securitycamera',s,)
				s.bActive = false;
		}
		
		// Anti-softlock
		if (!flags.GetBool('WCHQ_SpywarePlaced'))
		{
			foreach AllActors(class'HackableDevices', box)
			{
				if (box.IsA('Blackbox'))
				{
					if (!PlayerHasItem('Multitool') && player.Credits < 250)
					{
						foreach AllActors(class'Multitool', tool, 'SoftlockMultitool')
							bFound = True;
						if (!bFound)
							SpawnItemAt("DeusEx.Multitool", 'MultitoolSpawn', 'SoftlockMultitool');
						// flags.SetBool('MS_SpareMultitoolPlaced',true,,21);
					}
					break;
				}
			}
		}
	}
	else if (localURL == "20_WCFLOOR4")
	{
		// Send a PM from That Guy with the PDX virus
		if (flags.GetBool('QR_SUB_PDXVirus'))
			SendPM("PM_TG_PDXVirus");
	}
	else if (localURL == "20_WCSUBLEVEL")
	{
		// Allow the player to spawn the Quad Launcher after inserting both the plans and the codes
		if (flags.GetBool('Quad_PlansInserted') && flags.GetBool('Quad_CodesInserted'))
			flags.SetBool('Quad_ReadyToSpawn',true,,21);
		
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
	else if (localURL == "20_DESPOT")
	{
		if (flags.GetBool('Despot01_Played') && !flags.GetBool('QC_MAIN_GetNewsscript') && flags.GetBool('ALLIED_WC'))
		{
			SkillAward(500, strRejectionAward);
			flags.SetBool('QC_MAIN_GetNewsscript',true,,0);
		}
	}
	else if (localURL == "20_NSC")
	{
		// Send a PM from That Guy if you kill or knock out Jim and close his goal if you got it. Yes, it mentions killing if you haven't talked to him yet, but it's better than getting stuck.
		//Btw, the one after talking just mentions being "not nice", which fits with knocking out too. And will be more likely to be heard than the one before. -Hassat
		if (flags.GetBool('Jim_Dead') || flags.GetBool('Jim_Unconscious'))
		{
			SendPM("PM_TG_KilledJim");

			if (flags.GetBool('QR_SUB_JimsSalary') && !flags.GetBool('Jim_QuestOver'))
			{
				AddGoal('JimsSalary', strJimDead , false, true);
				flags.SetBool('QR_SUB_JimsSalary',false,,21);
			}
		}
	}
	else if (localURL == "20_OSC04")
	{
		// Unlock the exit when the player has uploaded SC
		if (flags.GetBool('QC_MAIN_ShadowCode') && !flags.GetBool('MS_OSC4_ExitOpened'))
		{
			foreach AllActors(class'DeusExMover', M, 'EXITDoor')
			{
				M.bLocked = False;
				M.Trigger(None, None);
			}
			flags.SetBool('MS_OSC4_ExitOpened',true,,21);
		}
	}
	else if (localURL == "20_PHASAPARTMENT")
	{
		if(flags.GetBool('QR_SUB_SubwayMoneyAlt') && !flags.GetBool('HAS_SubwayPass'))
		{
			SendPM("PM_NVS_DatacubeDirections");
			if(!flags.GetBool('Shawn_Datacube_Played') && (flags.GetBool('ShawnPA_Dead') || flags.GetBool('ShawnPA_Unconscious')))
			{
				SendPM("PM_NVS_NoReceptionist");
			}
		}

		if(!flags.GetBool('NVShacker_CanUploadProgram'))
		{
			if(flags.GetBool('NVShacker_DatacubeUsed') && flags.GetBool('HAS_NVShackerProgram') && !flags.GetBool('Has_SubwayPass'))
				flags.SetBool('NVShacker_CanUploadProgram',true,,21);
		}

		if(flags.GetBool('QC_SUB_SubwayMoneyAlt'))
			SendPM("PM_NVS_UploadedProgram");
	}
	else if (localURL == "20_SOLSBAR")
	{
		if(flags.GetBool('HAS_NVShackerProgram') && flags.GetBool('NVShacker_DatacubeUsed') && !flags.GetBool('HAS_SubwayPass') && !flags.GetBool('PM_NVS_UploadedProgram_Played'))
			SendPM("PM_NVS_PickedUpProgram");
	}
}

function StartSpawningQuadLauncher()
{
	Satellites();
	PlayWarmup();
	AddTimer('TimerStarted_Quad7','Timer_Quad7',7);
	AddTimer('TimerStarted_Quad14','Timer_Quad14',14);
	AddTimer('TimerStarted_Quad17','Timer_Quad17',17);
	AddTimer('TimerStarted_Quad22','Timer_Quad22',22);
}

function PlayWarmup()
{
	local actor a;
	foreach allactors( class'actor', a , 'QuadLauncherSpawnPoint')
		a.PlaySound(Sound'TNMSounds.OneShot.UCWarmup',SLOT_None,1.0);
}

function PlayConstruct()
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

function DamageTrigger()
{
	local actor a;
	foreach allactors( class'actor', a, 'UCDamageTrigger')
		a.trigger(none, none);
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

function Satellites()
{
	local actor a;
	foreach allactors( class'actor', a, 'SatelliteGenerators')
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
	foreach allactors( class'actor', a , 'QuadLauncherSpawnPoint')
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

function PlayNVSMessage()
{
	local computers c;

	foreach allactors(class'computers',c,'NVShackerDatacube')
		player.StartConversationByName('LaptopBriefing',c);
}

function HandleGameEvent(name scriptFunction)
{
	switch ( scriptFunction )
	{
		case 'SDFindPatrol'				: SDFindPatrol();			break;
		case 'AbomOneliner02'			: AbomOneliner02();			break;
		case 'AbomCutsceneEscape'		: AbomCutsceneEscape();		break;
		case 'GiveNSCKey'				: GiveNSCKey();				break;
		case 'GhandCatchFire'			: GhandCatchFire();			break;
		case 'PDXMark1'					: PDXMark1();				break;
		case 'PDXMark2'					: PDXMark2();				break;
		case 'PDXMark3'					: PDXMark3();				break;
		case 'PDXMark4'					: PDXMark4();				break;
		case 'IRCKick'					: IRCKick();				break;
		case 'BackOutTunnel'			: BackOutTunnel();			break;
		// case 'BullseyeCheck'			: BullseyeCheck();			break;
		case 'PhasTakeInventory'		: PhasTakeInventory();		break;
		case 'PhasLockDoor'				: PhasLockDoor();			break;
		case 'TurnMelkValve1'			: TurnMelkValve1();			break;
		case 'TurnMelkValve2'			: TurnMelkValve2();			break;
		case 'DestroyedValve'			: DestroyedValve();			break;
		case 'OSCElevator_To_OSC'		: OSCElevator_To_OSC();		break;
		case 'OSCElevator_To_NSC'		: OSCElevator_To_NSC();		break;
		case 'DXIHologramDisappear'		: DXIHologramDisappear();	break;
		case 'PlayNVSMessage'			: PlayNVSMessage();			break;
		case 'LlamaGuardInvul'			: LlamaGuardInvul();		break;
		case 'KaleDropBody'				: KaleDropBody();			break;
		case 'FlushStart'				: FlushStart();				break;
		case 'FlushStop'				: FlushStop();				break;/*
		case 'OSC02Fan'					: OSC02Fan();				break;*/
		case 'WrenchAward'				: WrenchAward();			break;
		case 'SummonDevs'				: SummonDevs();				break;
		default: super.HandleGameEvent(scriptFunction);
	}
}

function SummonDevs()
{
	local Pawn curPawn;
	
	for (curPawn=Level.PawnList; curPawn!=None; curPawn=curPawn.NextPawn)
	{
		if (curPawn.BindName == "ZPDev" || curPawn.BindName == "Hawk")
		{
			ScriptedPawn(curPawn).EnterWorld();
		}
	}
	
	for (curPawn=Level.PawnList; curPawn!=None; curPawn=curPawn.NextPawn)
	{
		if (curPawn.BindName == "ZPDev")
		{
			player.StartConversationByName('ZPDev', curPawn);
			break;
		}
	}
}

function IRCKick()
{
	if (Trestkon(GetPlayerPawn()).irc_link != None && FRand() < 0.8)
		Trestkon(GetPlayerPawn()).irc_link.ServerQuit(QR_Despot);
}

function FlushStart()
{
	local zoneinfo aZone;
	local Inventory anActor;
	
	forEach AllActors(class'ZoneInfo', aZone, 'SuccZone')
	{
		aZone.ZoneVelocity.Y = -1000;
		aZone.ZoneVelocity.Z = 1;
		aZone.AmbientSound = Sound'DeusExSounds.Weapons.WPApproach';
		aZone.SoundRadius = 255;
		
		forEach AllActors(class'Inventory', anActor)
		{
			if (anActor.Owner == None && anActor.Region.Zone == aZone)
			{
				anActor.SetCollisionSize(0,0);
				anActor.SetPhysics(PHYS_Falling);
				anActor.LandSound = None;
			}
		}
		break;
	}
}

function FlushStop()
{
	local zoneinfo aZone;
	local Inventory anActor;
	local int i, tempValue;
	
	i = 0;
	
	forEach AllActors(class'ZoneInfo', aZone)
	{
		if (aZone.Tag == 'SuccZone')
		{
			aZone.ZoneVelocity.Y = aZone.Default.ZoneVelocity.Y;
			aZone.ZoneVelocity.Z = aZone.Default.ZoneVelocity.Z;
			aZone.AmbientSound = aZone.Default.AmbientSound;
			aZone.SoundRadius = 0;
		}
		
		if (aZone.Tag == 'DepositZone')
		{
			forEach AllActors(class'Inventory', anActor)
			{
				if (anActor.Owner == None && anActor.Region.Zone == aZone)
				{
					i++;
					tempValue = flags.GetInt(Player.rootWindow.StringToName("SewerFlush_"$string(anActor.Class.Name)));
					if (Credits(anActor) != None) 			// Special case, combine all credits into one large one
						flags.SetInt(Player.rootWindow.StringToName("SewerFlush_"$string(anActor.Class.Name)), tempValue+Credits(anActor).numCredits, True, 23);
					else if (Ammo(anActor) != None) 		// Special case, combine all ammo type into one large one
						flags.SetInt(Player.rootWindow.StringToName("SewerFlush_"$string(anActor.Class.Name)), tempValue+Ammo(anActor).AmmoAmount, True, 23);
					else if (DeusExPickup(anActor) != None) // Special case, split one actor of 20 pickups into 20 actors
						flags.SetInt(Player.rootWindow.StringToName("SewerFlush_"$string(anActor.Class.Name)), tempValue+DeusExPickup(anActor).NumCopies, True, 23);
					else if (DeusExWeapon(anActor) != None && DeusExWeapon(anActor).AmmoType != None && AmmoNone(DeusExWeapon(anActor).AmmoType) == None && String(DeusExWeapon(anActor).AmmoType.PickupViewMesh) == "DeusExItems.TestBox") // Special case, this is for grenades, throwing knives
						flags.SetInt(Player.rootWindow.StringToName("SewerFlush_"$string(anActor.Class.Name)), tempValue+DeusExWeapon(anActor).PickupAmmoCount, True, 23);
					else
						flags.SetInt(Player.rootWindow.StringToName("SewerFlush_"$string(anActor.Class.Name)), tempValue+1, True, 23);
						
					// I'm not going to support flushing modded weapons, maybe Hoover can tell you off if you do.
					if (DeusExWeapon(anActor) != None)
					{
						if (DeusExWeapon(anActor).ModBaseAccuracy != 0 || DeusExWeapon(anActor).ModReloadCount != 0 || DeusExWeapon(anActor).ModAccurateRange != 0 || DeusExWeapon(anActor).ModReloadTime != 0 || DeusExWeapon(anActor).ModRecoilStrength != 0 || DeusExWeapon(anActor).bHasScope != DeusExWeapon(anActor).Default.bHasScope || DeusExWeapon(anActor).bHasLaser != DeusExWeapon(anActor).Default.bHasLaser || DeusExWeapon(anActor).bHasSilencer != DeusExWeapon(anActor).Default.bHasSilencer)
							flags.SetBool('FlushedModdedWeapon',true,,23);
					}
					anActor.Destroy(); // Delete to prevent duplication.
				}
			}
		}
	}
	
	if (i > 0)
	{
		SendPM("PM_Hoover_FlushedItems");
		Trestkon(GetPlayerPawn()).SetAchievement("achFlush");
		if (!flags.GetBool('MS_FlushedItem'))
			AddGoal('SewerFlushRetrieval', strGoalSewerRetrieval, FALSE, FALSE);
		flags.SetBool('FlushedItem',true,,23);
		flags.SetBool('MS_FlushedItem',true,,23);
	}
}

function PlayerDetected(name StateType, optional ScriptedPawn Triggerer)
{
	if (flags == None)
		return;

	if (LocalURL == "20_PHASAPARTMENT" && StateType != 'Seeking')
	{
		// Once the player is detected the guards will stay aggressive in Phas' apartment.
		// ...and the receptionist will comment on the situation
		flags.SetBool('Shawn_PissedOffGuards',true,,21);
	}
	//Stealth award - stealth award no longer awarded but keeping this flag in case it is used for other things.
	else if ((LocalURL == "20_WCFLOOR1")||
		(LocalURL == "20_WCFLOOR2")||
		(LocalURL == "20_WCFLOOR3")||
		(LocalURL == "20_WCFLOOR4"))
	{
		//planting some spyware:
		if (flags.GetBool('QR_MAIN_WCSpyware') && !flags.GetBool('QR_MAIN_ShadowCode'))
		{
			flags.SetBool('NS_WCSpyware',true,,21);
		}
	}
	else if (LocalURL == "20_WCSUBLEVEL")
	{
		//destroying Black ICE:
		if (flags.GetBool('QR_SUB_BlackICE') && !flags.GetBool('Evil_Done'))
		{
			flags.SetBool('NS_BlackICE',true,,21);
		}
	}
	else if (LocalURL == "20_DXO")
	{
		//stealing the news script:
		if (flags.GetBool('QR_MAIN_GetNewsscript') && !flags.GetBool('QR_MAIN_KillPhas'))
		{
			flags.SetBool('NS_GetNewsscript',true,,21);
		}
	}
	else if ((localURL == "20_PDXHQ01")||
		(localURL == "20_PDXHQ02"))
	{
		//stealing the news script:
		//(yes we're checking seperately; we need to know if he was seen in PDXHQ for the bulletins)
		if (flags.GetBool('QR_MAIN_GetNewsscript') && !flags.GetBool('QR_MAIN_KillPhas'))
		{
			flags.SetBool('NS_GetNewsscript',true,,23);
			flags.SetBool('NS_PDXHQ',true,,23);
		}
	}
	else if (localURL == "20_GOATCITY")
	{
		//destroying the melk fountains:
		if (flags.GetBool('QR_CULT_DrainTheMelk') && !flags.GetBool('Beefman_LastQuestDone'))
		{
			flags.SetBool('NS_DrainTheMelk',true,,21);
		}
	}
	else if (localURL == "20_LLAMATEMPLE")
	{
		//destroying the tablets:
		if (flags.GetBool('QR_CULT_DestroyTheTablets') && !flags.GetBool('DT_LastQuestDone'))
		{
			flags.SetBool('NS_DestroyTheTablets',true,,21);
		}
	}
	// Set flags for the bulletin computers
	else if (localURL == "20_SOLSBAR")
	{
		flags.SetBool('MS_SolsTrouble',true,,23);
	}
	else if (localURL == "20_PARTYZONE")
	{
		flags.SetBool('MS_PartyzoneTrouble',true,,23);
	}
}

function LlamaGuardInvul()
{
	local Trestkon trest;
	
	trest = Trestkon(GetPlayerPawn());
	
	if (trest != None && TNMPOVCorpse(trest.InHand) != None && TNMPOVCorpse(trest.inhand).GivenBindName == "LlamaHostage")
		trest.DropItem();
}

function KaleDropBody()
{
	local Trestkon trest;
	
	trest = Trestkon(GetPlayerPawn());
	
	if (trest != None && TNMPOVCorpse(trest.InHand) != None && TNMPOVCorpse(trest.inhand).GivenBindName == "Master_Kale")
		trest.DropItem();
}
/*
function OSC02Fan()
{
	local ZoneInfo aZone;
	local Vector newGravity;
	local InertialMover aFan;
	
	forEach AllActors(class'InertialMover', aFan, 'Fan1')
	{
		if (aFan.bDestroyed)
			flags.SetBool('OSC02Fan_On',true,,21);
		
		if (!flags.GetBool('OSC02Fan_On'))
		{
			aFan.DesiredRotationRate.Roll = 100000;
			aFan.AmbientSound=Sound'Ambient.Ambient.FanLarge';
			// Log("Fan on");
		}
		else
		{
			aFan.DesiredRotationRate.Roll = 0;
			aFan.AmbientSound=None;
			// Log("Fan off");
		}
	}
	
	if (!flags.GetBool('OSC02Fan_On'))
		flags.SetBool('OSC02Fan_On',true,,21);
	else
		flags.SetBool('OSC02Fan_On',false,,21);
		
	// Log(flags.GetBool('OSC02Fan_On'));
}*/

function WrenchAward()
{
	SkillAward(25, strWrenchAward);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     strNSCKey="Password to the PDX Server Complex in Goat City"
     strGoalDrainTheMelk1="You've destroyed the first valve. Now to get the other one..."
     strGoalDrainTheMelk2="You've destroyed the melk fountains in Goat City. Return to Beefman for your reward."
     strSabotageAward="Sabotage Award"
     strLlamaKey="Llamarian tunnels password"
     strPassword="Password"
     strDXIKey="DXI excavation site gate password"
     strGoalN00Bz="You gathered enough money for the subway pass without having to handle the N00Bz gang."
     strGoalAbom="You ended up ignoring Abomination's mission to rescue the hostage."
     strGoalSewerRetrieval="Good job at flushing your stuff down the drain. Look for them in the sewers."
     strGoalServerComplex="Break into the Forum City server complex and download the admin password from the mainframe. The complex is behind the 00n Mart."
     strGoalShadowCode="Find the entrance to the server complex somewhere in Goat City. The entrance to the complex is behind the 00n Mart."
     strPiggyBank="Breaking the Piggy Bank Bonus"
     strSubPass="You bought a pass, you no longer need a free one."
     strSubPassNVS="You have received a free pass with NVShacker's help."
     strKunioDead="You opted to kill Kunio, which was the sensible choice, to be sure."
     strKunioUnconscious="You have rendered Kunio unconscious, and may take what you please from him."
     strFirewallDead="Having killed the Firewall agent in charge of the N00Bz operation, you won't get any money from him."
     strFirewallUnconscious="The Firewall agent is unlikely to give you any money now that you have knocked him out."
     strAbomDead="You have slain Abomination."
     strAbomUnconscious="Rather than paying you for rescuing the captured warrior, Abomination is likely to be really mad at you when he comes around."
     strJimmyDead="jimmycracker will have a really hard time paying you now."
     strJimmyUnconscious="Having knocked out jimmycracker for no good reason, you won't get any money from him."
     strAbomDead2="Since you've killed Abomination, it is unlikely that the llama cult will welcome you into their ranks."
     strAbomUnconscious2="You've chosen to render Abomination unconscious rather than complete his mission."
     strDarkTemplar="Return to Dark Templar and inform him of your victory over Abomination."
     strBeefmanDead="Having attacked Beefman, it's safe to say you're now in bad standing with the followers of Lamar."
     strYardbombDead="To gain access-- oh. Never mind then."
     strVoodooAward="Who do? YOU DO! Award"
     strDarkTemplarDead="Considering Dark Templar's current state, you can probably write off that mission he gave you."
     strDarkTemplarUnconscious="You did meet Dark Templar as he asked. What happened afterwards was your own idea."
     strDarkTemplarRobbed="A photo you found on DT reveals that the entrance to Goat City is in the south-west corner of the Downtown district. You should return to Abomination and tell him what you've learned."
     strShadowCode="Now that you know how to enter Goat City, go there and find the entrance to the PDX server complex."
     strShowGoOnAward="The Show Must Go On Award"
     strDragonSlayerAward="Dragonslayer Award"
     strRescueSilver="Rescuing the Dragon in Distress Award"
     strRejectionAward="Rejection Consolation Prize"
     strJimDead="It seems unlikely that Jim will give you anything if you raise his salary now."
     strWrenchAward="FEMA Violation Bonus"
     strInvestigationAward="Investigation Award"
     RemoteRole=ROLE_DumbProxy
}

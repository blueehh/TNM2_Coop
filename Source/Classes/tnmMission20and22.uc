class tnmMission20and22 extends TNMMissionScript;

//the persistent level info stuff has undergone a few revisions but now it should be
//stable and useful. -Nick 8/18/07

//thse vars are just stored as default values, the transient nature of missionscripts doesn't matter for them
//entries: 32-2 for signed bit... range up to 2^31-1
//NOTE: the same level can be used more than once with different flags for more than 30 tags (!)
struct PersistentLevelInfo
{
	var() Name flag_name;		//flag to store the items in
	var() string level_save;	//level in m20 that does the item check and stores the flag
	var() string level_load;	//level in m22 that checks the flag and destroys the appropriate actors
	var() Name tags[30];		//tags of various actors to check in pretravel for level_save
};
var() PersistentLevelInfo persistent_levels[13];

var localized string strJimmyNoPay, strHasSubPass, strPJDead, strPJUnconscious;

function SetupPortal(name portaltag, name soundtag)
{
	local bool bEnable;
	local warpzoneinfo w;
	local ambientsoundtriggered a;

	bEnable = flags.GetBool('QC_SUB_VoodooStuff') &&
		( (dxInfo.missionNumber == 20) || 
		(flags.GetBool('QR_MAIN_FreeKevo') && !flags.GetBool('Yardbomb_Dead')) || 
		(flags.GetBool('QR_MAIN_KidnapKevo') && !flags.GetBool('Yardbomb_Dead')) );
		
	if (dxInfo.missionNumber == 22 && flags.GetBool('Yardbomb_AdvisedToSell'))
		return;

	//deusexplayer(getplayerpawn()).clientmessage("portalling");

	// If voodoo shop quest has been completed, activate the portal
	if (bEnable)
	{
		Trestkon(Player).SetAchievement("achTeleporters");
		foreach AllActors(class'WarpZoneInfo',W,portaltag)
		{
			if (w.OtherSideURL ~= string(w.ThisTag))
				W.Trigger(Self, Player);
		}
		foreach AllActors(class'AmbientSoundTriggered',A,soundtag)
		{
			if (A.bActive == false)
			{
				A.bAlreadyHit = false;
				A.Trigger(Self, Player);
			}
		}
	}
	// If the voodoo shop quest hasn't been completed, deactivate the portal
	else
	{
		//It turns out that is not simple to do so they just start disabled
		//On the assumption that you would not want to disable once they've
		//been enabled.
	}
}

function SetupPortals()
{
	SetupPortal('FC_Current_Booth','FC_Current_Booth_Sound');
}

function PDXHQMurder()
{
	local TNMPawn p;
	local deusexdecoration turret;
	local button1 btn;
	local trigger t;
	local bool bFoundKashue;
	local actor a;
	local teleporter porter;
	local mapexit me;

	if ( Flags.GetBool('MS_KashueKilling') )
		return;
	Flags.SetBool('MS_KashueKilling', true, ,23);

	bFoundKashue = false;
	foreach allactors(class'TNMPawn',p,)
	{
		if ((P.Tag == 'KingKashue_Evil')||(P.Tag == 'KingKashue'))
		{
			if (p.binWorld)
			{
				p.LeaveWorld();
				bFoundKashue = true;
			}
		}
	}

	if ( !bFoundKashue )
	{
		SendPM("PM_Kashue_KilledFriend");
	}

	Trestkon(player).CantSave = True;

	foreach allactors(class'TNMPawn',p,)
	{
		if ((P.Tag == 'Krissy')||
		    (P.Tag == 'Evil')||
		    (P.Tag == 'Jonas')||
		    (P.Tag == 'Winquman'))
			P.ChangeAlly('Player',-1.000000,true);
		else if (P.Tag == 'KingKashue_Attack')
			p.EnterWorld();
	}
	SealDoor('PDXMainDoor');
	SealDoor('PDXSewerGrate');
	SealDoor('StaircaseDoor');

	foreach allactors(class'teleporter', porter, )
	{
		porter.bEnabled = false;
		// Log("Disabled a teleporter");
	}
	foreach allactors(class'mapexit', me, )
	{
		me.DestMap = "";
		// Log("Disabled a mapexit");
	}

//	foreach allactors(class'actor',a)
//		if(a.isa('teleporter') || a.isa('mapexit'))
//			a.destroy();
	foreach allactors(class'trigger',t,)
	{
		if (t.Tag == 'Exit1Trigger')
			t.Destroy();
		else if (t.Tag == 'Exit2Trigger')
			t.Destroy();
	}
	foreach allactors(class'button1',btn,'ElevatorInnerButton')
	{
		btn.Event='';
		btn.buttonSound1=Sound'DeusExSounds.Generic.Buzz1';
	}
}

function PawnKilled(pawn killed, pawn killer)
{
	local bool bUnconscious;
	local tnmregex rx;
	
	rx=new(None) class'tnmRegEx';
	
	if (flags == None || Killed == None || rx == None)
		return;
	
	// Allow A2 to get into fights
	if (PlayerPawn(Killer) == None)
		return;
	
	if(!flags.GetBool('ALLIED_WC') && !flags.GetBool('MS_PDX_Murderer'))
	{
		if(rx.regex_match(localURL, "2\\d_PDXHQ0(\\d)"))
		{
			if (ScriptedPawn(Killed) != None)
				bUnconscious=scriptedpawn(killed).bStunned;
			// log(""$killed@"was killed -- bUnconscious:"@bUnconscious);
			if ( !killed.isa('NBDRat') && !Killed.IsA('TNMCat') && !Killed.IsA('Invader') && TNMRobot(Killed) == None && TNMPawn(Killed) != None )
			{
				if(!bUnconscious || !killed.isa('Jonas'))
				{
					flags.SetBool('PDX_Dead',!bUnconscious,,21);
					PDXHQMurder();
				}
				else if (killed.IsA('Jonas'))
				{
					SendPM("PM_Evil_JonasKnockout");
				}
			}
		}
	}
}

function DDHologramAppear()
{
	local TNMPawn p;
	foreach allactors(class'TNMPawn', p,)
	{
		if (p.Tag == 'DDHologram')
			p.EnterWorld();
	}
}

function DDHologramDisappear()
{
	local TNMPawn p;
	foreach allactors(class'TNMPawn', p,)
	{
		if (p.Tag == 'DDHologram')
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
	local keypad k;
	local deusexmover m;
	local securitycamera c;
	local TNMPawn p;
	local TNMCarcass carc;
	local TNMRobot r;
	local actor tmp;
	local int count, check, lvl;
	local int i;
	local TNMInformationDevices id;
	local ZoneInfo z;
	local patrolpoint pp;
	local Computers news;
	local tnmTextureSwapController swapper;

	Super.FirstFrame();

	//log("first-frame persistent items check...");
	//log("looking for:"@localURL);

	//Check for and remove items destroyed or taken in M20

	GetPersistentLevelData();

	for(lvl=0;lvl<arraycount(persistent_levels);lvl++)
	{
		if(persistent_levels[lvl].level_load!=localURL && persistent_levels[lvl].level_save!=localURL)
			continue;

		check=flags.GetInt(persistent_levels[lvl].flag_name);
		for(i=0; i<30 && persistent_levels[lvl].tags[i]!=''; i++)
			if((check&(0x01<<i))!=0)//{log("actor"@persistent_levels[lvl].tags[i]@"-- DESTROY");
				foreach AllActors(Class'Actor', tmp, persistent_levels[lvl].tags[i])
				{
					if ( !tmp.IsA('Inventory') || !inventory(tmp).bCarriedItem )
					{
						if(tmp.IsA('Containers'))
							Containers(tmp).Contents=None;
						tmp.Destroy();
					}
				}//} else log("actor"@persistent_levels[lvl].tags[i]@"-- KEEP");
	}
	
	if (flags.GetBool('ALLIED_CULT_LLAMA') || flags.GetBool('DT_Pissed') || flags.GetBool('DarkTemplar_Dead') || flags.GetBool('Athena_Dead'))
	{
		flags.SetBool('HOSTILE_CULT_GOAT', true,,25);	// Needs to be set before entering level (GoatCity music)
	}

	if ( localURL == "20_SOLSBAR" /*|| localURL == "22_SOLSBAR"*/ )
	{
		if( flags.GetBool('MS_CloseSols') )
		{
			foreach allactors(class'TNMPawn', p, )
			{
				if ( p.Tag == 'Jackie' )
				{
					foreach allactors(class'patrolpoint', pp, 'JackieAlertedPoint')
					{
						p.SetLocation(pp.location);
						p.Orders = 'Wandering';
						p.OrderTag = 'JackieAlertedPoint';
						p.FollowOrders();
						p.ChangeAlly('Player', -1, true, true);
					}
				}
				else if ( p.Tag == 'AlphaOperator' )
				{
					foreach allactors(class'patrolpoint', pp, 'AOOfficePoint')
					{
						p.SetLocation(pp.location);
						p.Orders = 'Sitting';
						p.OrderTag = 'AOOfficeChair';
						p.bPlayIdle = False;
						p.FollowOrders();
						p.ChangeAlly('Player', -1, true, true);
					}
				}
				else
				{
					p.LeaveWorld();
				}

				foreach allactors(class'TNMCarcass', carc, )
				{
					carc.LeaveWorld();
				}
			}
		}
	}
	else if ((localURL == "20_WCFLOOR1") ||(localURL == "20_WCFLOOR2")||
	    (localURL == "20_WCFLOOR3") ||(localURL == "20_WCFLOOR4")||
	    (localURL == "22_WCFLOOR1") ||(localURL == "22_WCFLOOR4")||
	    (localURL == "20_WCSUBLEVEL")||(localURL == "22_WCSUBLEVEL"))
	{
		//Fix the elevator for the different levels
		if (flags.GetBool('WCHQ_SublevelKeypad_Open'))
		{
			foreach Allactors(class'keypad',k,'SublevelKeypad')
			{
				k.hackStrength = 0.0;
				k.bHackable=true; // Required to say "bypassed" instead of "inf"
			}
		}
		if (flags.GetBool('WCHQ_SublevelKeypadHatch_Open'))
			foreach Allactors(class'deusexmover',m,'SublevelKeypadHatch')
				m.bLocked = False;

		// Disable the cameras if you've got Black ICE to turn them off
		if (flags.GetBool('WCHQ_CamerasOffline'))
		{
			foreach allactors(class'securitycamera',c,)
				c.bActive = false;
		}

		if ((localURL == "20_WCSUBLEVEL")||(localURL == "22_WCSUBLEVEL"))
		{
			// Make That Guy friendly if the player is WC-allied
			if (flags.GetBool('ALLIED_WC'))
				foreach allactors(class'TNMPawn',p,'ThatGuy')
					p.ChangeAlly('Player',1.000000,false);
		}
		else
		{
			// Piss everybody off if you rescue SD or kill Scara (just to be extra safe)
			if ((flags.GetBool('QC_MAIN_SaveSD') && !flags.GetBool('Silver_Dead')) || flags.GetBool('ALLIED_PDX') || flags.GetBool('Scara_Dead'))
			{
				foreach allactors(class'TNMPawn',p,)
				{
					if ((p.Tag == 'WCSecurity')||(p.Tag == 'WCSecurity01')||(p.Tag == 'WCCommando')||(p.Tag == 'ScaraGuard')||(p.Tag == 'ScaraKing')||(p.Tag == 'Bob')||(p.Tag == 'Albert'))
						p.ChangeAlly('Player',-1.000000,true);
				}
				foreach allactors(class'TNMRobot',r,) // Medbots and repair bots aren't TNMRobots, so this should be fine // They are now!
				{
					if (!r.IsA('TNM_Medbot') && !r.IsA('TNM_RepairBot'))
						r.ChangeAlly('Player',-1.000000,true);
				}
				foreach allactors(class'securitycamera',c,)
					c.bNoAlarm = false;
			}
		}
	}
	else if ((localURL == "20_PDXHQ01") || (localURL == "22_PDXHQ01"))
	{
		// Change alliances if the player works for WorldCorp
		if (flags.GetBool('ALLIED_WC'))
		{
			foreach AllActors(class'securitycamera',c,)
				if ((c.Tag == 'Lobbycamera')||(c.Tag == 'LabEntrancecamera')||(c.Tag == 'Elevatorcamera')||
				    (c.Tag == 'ArmouryCamera')||(c.Tag == 'YardCamera01')||(c.Tag == 'YardCamera02'))
					c.bNoAlarm=False;

			foreach AllActors(class'TNMPawn',p,)
			{
				if ((p.Tag == 'Krissy')||
					(p.Tag == 'Evil')||
					(p.Tag == 'Slicer')||
					(p.Tag == 'Winquman')||
					(p.Tag == 'DXAGuard')||
					(p.Tag == 'DXAGuardLight')||
					(p.Tag == 'FireWall2')||
					(p.Tag == 'GPRentACop') ||
					(p.Tag == 'DXACop'))
				{
					p.ChangeAlly('Player', -1.000000, true);
				}
			}
		}

	}
	else if ((localURL == "20_PDXHQ02") || (localURL == "22_PDXHQ02"))
	{
		// Change alliances if the player works for WorldCorp
		if (flags.GetBool('ALLIED_WC'))
		{
			foreach AllActors(class'TNMPawn',p,)
			{
				if (p.Tag == 'KingKashue')
					p.LeaveWorld();
				else if (p.Tag =='KingKashue_Patrolling')
					p.EnterWorld();
				else if ((p.Tag == 'Krissy')||
					(p.Tag == 'Evil')||
					(p.Tag == 'Slicer')||
					(p.Tag == 'Winquman')||
					(p.Tag == 'DXAGuard')||
					(p.Tag == 'DXAGuardLight')||
					(p.Tag == 'FireWall2')||
					(p.Tag == 'Phasmatis'))
				{
					p.ChangeAlly('Player', -1.000000, true);
				}
			}
			foreach AllActors(class'securitycamera',c,)
			{
				if ((c.Tag == 'Elevatorcamera')||
				    (c.Tag == 'LeisureRoomcamera')||
				    (c.Tag == 'GhandOfficecamera'))
					c.bNoAlarm = False;
			}
			foreach allactors(class'TNMRobot',r,'SecurityBot2PDX')
			{
				r.ChangeAlly('Player', -1.000000, true);
			}
		}
	}
	else if ((localURL == "20_FCDOWNTOWN") || (localURL == "22_FCDOWNTOWN"))
	{
		// Make Abom and his guards hostile (1) if the player is allied to the Goats or (2) if he betrayed Abom or (3) if Beefman is dead or was knocked out in M20 or (4) if he's caused a ruckus in the temple
		if (flags.GetBool('ALLIED_CULT_GOAT') || flags.GetBool('Abom_Pissed') || flags.GetBool('Beefman_Dead') || flags.GetBool('Beefman_Unconscious') || flags.GetBool('CheckedBeefmanTurretsDrop'))
			foreach AllActors(class'TNMPawn',p,)
				if ((p.Tag == 'Abomnation') || (p.Tag == 'LlamaGuard') || (p.Tag == 'TunnelGuard') || (p.Tag == 'Hobbes') || (p.Tag == 'SD'))
					p.ChangeAlly('Player',-1.000000,true);
		
		// Destroy history for new players
		if (trestkon(player) != none)
		{
			if (!trestkon(player).bunlockedSword)
			{
				foreach AllActors(class'Computers',news,'DXHistoryBulletins')
				{
					news.Destroy();
				}
			}
		}


		// Close the Fan-Fic Store if the player has killed or knocked out Walton or Chris
		if (flags.GetBool('Chris_Dead')||flags.GetBool('Chris_Unconscious')||
		    flags.GetBool('Walton_Dead')||flags.GetBool('Walton_Unconscious'))
		{
			// Remove all pawns in the shop
			foreach AllActors(class'TNMPawn',p,)
			{
				if ((p.Tag == 'Walton')||(p.Tag == 'Chris')||(p.Tag == 'jimmycracker')||(p.Tag == 'FanFicCustomer'))
					p.LeaveWorld();
			}

			//Close jimmy goal if still open (day 20)
			if (flags.GetBool('QR_SUB_JimmyHeirloom') && !flags.GetBool('QC_SUB_JimmyHeirloom'))
			{
				AddGoal('JimmyHeirloom', strJimmyNoPay, FALSE, TRUE);
				flags.SetBool('QC_SUB_JimmyHeirloom',true,,21);
			}
			
			// Remove all carcii in the shop
			foreach AllActors(Class'ZoneInfo',z,'FanFicShopZone')
			{
				// ZoneActors is unreliable.
				// foreach z.ZoneActors(class'TNMCarcass',carc)
				foreach AllActors(class'TNMCarcass',carc)
					if (carc.Region.Zone == z)
						carc.LeaveWorld();
			}

			// Close and lock the door
			foreach allactors(class'deusexmover', m, 'FanFicStoreDoor')
			{
				if (m.keynum != 0)
				{
					m.GotoState( 'TriggerControl',  );
					m.untrigger(self,none);
				}
				if (m.lockstrength != 0.0)
					m.bLocked = true;
				m.bIsDoor = False;
			}

			// Spawn a notice depending on whether somebody has died
			if (flags.GetBool('Chris_Dead')||flags.GetBool('Walton_Dead'))
			{
				foreach AllActors(class'TNMInformationDevices',id,'FanFicNotice_Death')
				{
					id.bHidden = False;
					id.SetCollision(true,true);
				}
			}
			else
			{
				foreach AllActors(class'TNMInformationDevices',id,'FanFicNotice_Knockout')
				{
					id.bHidden = False;
					id.SetCollision(true,true);
				}
			}
			
			Trestkon(player).SetAchievement("achFanFicClosed");
		}
		else
		{
			// Otherwise, move Walton randomly around the Fan Fic Shop
			// :( removed due to horrible pathing issues.
			//foreach AllActors(class'TNMPawn',p,'Walton')
			//{	
			//	if (FRand() < 0.5)
			//	{
			//		TeleportPawn(p, 'WaltonUpstairs', 'Wandering');
			//		flags.SetBool('Walton_Upstairs',true,,23);
			//	}
			//	else
			//	{
			//		TeleportPawn(p, 'WaltonDownstairs', 'Wandering');
			//		flags.SetBool('Walton_Upstairs',false,,23);
			//	}
			//}
		}

		// Spawn random Llama attackers if you're Goat-aligned
		if (flags.GetBool('ALLIED_CULT_GOAT'))
		{
			foreach allactors(class'TNMPawn',p,)
			{
				if (p.tag == 'AttackGroup_Llama01' ||
				    p.Tag == 'AttackGroup_Llama02' ||
				    p.Tag == 'AttackGroup_Llama03')
				{
					if (p.bInWorld)
						count++;
				}
				if (count < 2)
				{
					foreach allactors(class'TNMPawn',p,)
					{
						if (p.Tag == 'AttackGroup_Llama01' ||
						    p.Tag == 'AttackGroup_Llama02' ||
						    p.Tag == 'AttackGroup_Llama03')
						{
							p.EnterWorld();
						}
					}
				}
			}
		}

		// Spawn random Goat attackers if you're Llama-aligned
		if (flags.GetBool('ALLIED_CULT_LLAMA'))
		{
			foreach allactors(class'TNMPawn',p,)
			{
				if (p.tag == 'AttackGroup_goat01' ||
				    p.Tag == 'AttackGroup_goat02' ||
				    p.Tag == 'AttackGroup_goat03')
				{
					if (p.bInWorld)
						count++;
				}
				if (count < 2)
				{
					foreach allactors(class'TNMPawn',p,)
					{
						if (p.Tag == 'AttackGroup_goat01' ||
						    p.Tag == 'AttackGroup_goat02' ||
						    p.Tag == 'AttackGroup_goat03')
						{
							p.EnterWorld();
						}
					}
				}
			}
		}
	}
	else if ((localURL == "20_FCCORPORATE") || (localURL == "22_FCCORPORATE"))
	{
		// Lock the PDX doors when player is WC aligned
		if (flags.GetBool('ALLIED_WC'))
			foreach Allactors(class'deusexmover',m,'PDXHQDoors')
				m.bLocked = true;				
		
		// Close Raving's Weapon Shop if the player has killed both Raving and Andreus
		if (flags.GetBool('Andreus_Dead') && flags.GetBool('Raving_Dead') && LastMap() != "20_WEAPONSHOP" && LastMap() != "22_WEAPONSHOP")
			foreach allactors(class'deusexmover',m,'WeaponShopDoor')
			{
				flags.SetBool('WeaponShop_Locked',true,,23);
				if (m.keynum != 0)
				{
					m.GotoState( 'TriggerToggle',  );
					m.trigger(self,none);
				}
				if (m.lockstrength != 0.0)
					m.bLocked = true;
			}
	}
	else if ((localURL == "20_FCSLUMS") || (localURL == "22_FCSLUMS" || localURL == "22_FCSLUMS_WC" || localURL == "22_FCSLUMS_PDX"))
	{
		// Close the Voodoo Shop if the player has killed Yardbomb
		if (flags.GetBool('Yardbomb_Dead'))
			foreach allactors(class'deusexmover',m,'VoodooShopDoor')
				m.bLocked = true;
	}
	else if ((localURL == "20_WEAPONSHOP") || (localURL == "22_WEAPONSHOP"))
	{
		// Make sure that Raving and some thugs attack the player if he returns after killing or knocking out Andreus or knocking out Raving before DXI
		if ((flags.GetBool('Andreus_Dead')||flags.GetBool('Andreus_Unconscious')||flags.GetBool('Andreus_Unconscious_M20')||flags.GetBool('Raving_Unconscious_M20'))
		  &&!flags.GetBool('Raving_Dead')&&!flags.GetBool('Raving_Unconscious'))
		{
			foreach allactors(class'TNMPawn',p,)
			{
				if (p.Tag == 'RavingNutter')
					p.LeaveWorld();
				if (p.Tag == 'Raving_Angry')
					p.EnterWorld();
				if (p.Tag == 'RavingThug')
					p.EnterWorld();

			}
			flags.SetBool('WeaponShop_Hostile',true,,21);
		}
		// Make sure that Andreus attacks the player if he returns after killing Raving or if Andreus was knocked out before DXI
		else if ((flags.GetBool('Raving_Dead')||flags.GetBool('Andreus_Unconscious_M20'))
		       &&!flags.GetBool('Andreus_Dead')&&!flags.GetBool('Andreus_Unconscious'))
		{
			foreach allactors(class'TNMPawn',p,)
			{
				if (p.Tag == 'Andreus')
					p.LeaveWorld();
				if (p.Tag == 'Andreus_Angry')
					p.EnterWorld();

			}
			flags.SetBool('WeaponShop_Hostile',true,,21);
		}
		
		// If the shop's been locked and declared a crime scene, fill with firewalls.
		if (flags.GetBool('WeaponShop_Locked') && !flags.GetBool('MS_WeaponShop_Firewalls'))
		{
			foreach allactors(class'TNMPawn',p,'CrimeSceneFirewalls')
			{
				p.EnterWorld();
			}
			flags.SetBool('MS_WeaponShop_Firewalls',true,,DXInfo.missionNumber+1);
		}
	}
	else if ((localURL == "20_GOATCITY") || (localURL == "22_GOATCITY") ||
		 (localURL == "20_GOATTEMPLAE") || (localURL == "22_GOATTEMPLAE"))
	{
		// Make everybody hostile (1) if the player is allied to the Llamas or (2) if he betrayed Dark Templar or (3) if DT or Athena are dead
		if (flags.GetBool('ALLIED_CULT_LLAMA') || flags.GetBool('DT_Pissed') || flags.GetBool('DarkTemplar_Dead') || flags.GetBool('Athena_Dead'))
		{
			foreach allactors(class'TNMPawn',p,)
			{
				if (!p.IsA('ZeroPresence'))
					p.ChangeAlly('Player',-1.000000,true);
			}
			
			// Duplicated in Trestkon for loading
			// Swap out the Goat City screens with wanted posters
			foreach AllActors(class'tnmTextureSwapController', swapper)
			{
				swapper.secondaryTexture = texture(DynamicLoadObject("TNM_Support_Tex.Signs.TrestkonWanted"$Player.PlayerSkin, class'texture' ));
				swapper.bSwapped = False; // Textures reset between level transitions?
				swapper.Trigger(None, None);
			}
		}
			
		if (flags.GetBool('ALLIED_PDX'))
		{
			foreach allactors(class'TNMCarcass',carc,'PDXScubaDiverCarcass')
			{
				carc.Destroy();
			}
		}
		else if (flags.GetBool('ALLIED_WC'))
		{
			foreach allactors(class'TNMCarcass',carc,'WCScubaDiverCarcass')
			{
				carc.Destroy();
			}
		}
	
		if (flags.GetBool('ALLIED_PDX'))
		{
			foreach allactors(class'TNMPawn',p,)
			{
				if (p.IsA('PDXScubaDiver'))
				{
					p.LeaveWorld();
				}
			}
		}	
		else if (flags.GetBool('ALLIED_WC'))
		{
			foreach allactors(class'TNMPawn',p,)
			{
				if (p.IsA('WCScubaDiver'))
				{
					p.LeaveWorld();
				}
			}
		}
	}
	else if ((localURL == "20_LLAMATEMPLE") || (localURL == "22_LLAMATEMPLE"))
	{
		// Make Silver appear when the player has helped him escape from WC
		if (flags.GetBool('QC_MAIN_SaveSD'))
			foreach allactors(class'TNMPawn',p,'Silver')
				p.EnterWorld();

		// Make everybody hostile (1) if the player is allied to the Goats or (2) if he betrayed Abom or (3) if Beefman is dead
		if (flags.GetBool('ALLIED_CULT_GOAT') || flags.GetBool('Abom_Pissed') || flags.GetBool('Beefman_Dead') || flags.GetBool('Beefman_Unconscious'))
		{
			foreach AllActors(class'TNMPawn',p,)
				p.ChangeAlly('Player',-1.000000,true);
			foreach allactors(class'securitycamera',c,)
				c.bNoAlarm = false;
		}
		else if (localURL == "22_LLAMATEMPLE")
			foreach allactors(class'TNMPawn',p,'Silver')
				p.LeaveWorld();
	}
}


// ----------------------------------------------------------------------
// PreTravel()
// 
// Set flags upon exit of a certain map
// ----------------------------------------------------------------------

function PreTravel()
{
	local keypad k;
	local deusexmover m, Mover;
	local int i, lvl, result;
	local Actor tmp;
	local Inventory inv;
	local FlagBase f;
	
	f=deusexplayer(GetPlayerPawn()).flagBase;

	//log("pre-travel persistent items check...");
	//log("looking for:"@localURL);

	//check for items that have been taken/destroyed by the player and store as a flag for m22

	GetPersistentLevelData();

	for(lvl=0;lvl<arraycount(persistent_levels);lvl++)
	{
		//log("checking:"@persistent_levels[lvl].level_save);
		if(persistent_levels[lvl].level_save!=localURL)
			continue;
		//log("accepted...");

		result=0;
		for(i=0; i<30 && persistent_levels[lvl].tags[i]!=''; i++)
		{
			tmp=None;
			foreach AllActors(Class'Actor', tmp, persistent_levels[lvl].tags[i])
			{
				if(Inventory(tmp) != None)
				{
					if (Inventory(tmp).Owner != None && Inventory(tmp).Owner.IsA('DeusExPlayer'))
						tmp = None;
				}
				else if(Trigger(tmp) != None && !tmp.bCollideActors)	
					tmp=None;
				break;
			}
			if(tmp==None)
				result = result | (2**i);

			//if(tmp==None)
			//	log("actor"@persistent_levels[lvl].tags[i]@"-- DESTROY");
			//else
			//	log("actor"@persistent_levels[lvl].tags[i]@"-- KEEP");
		}
		//log("flag result:"@result);
		f.SetInt(persistent_levels[lvl].flag_name, result, true, 23);
	}

	if ((localURL == "20_WCFLOOR1") ||(localURL == "20_WCFLOOR2")||
	    (localURL == "20_WCFLOOR3") ||(localURL == "20_WCFLOOR4")||
	    (localURL == "22_WCFLOOR1") ||(localURL == "22_WCFLOOR4")||
	    (localURL == "20_WCSUBLEVEL")||(localURL == "22_WCSUBLEVEL"))
	{
		foreach Allactors(class'keypad',k,'SublevelKeypad')
			if (k.hackStrength == 0.0)
				f.SetBool('WCHQ_SublevelKeypad_Open', k.hackStrength == 0.0,, 23);
		foreach Allactors(class'deusexmover',m,'SublevelKeypadHatch')
			if (m.bLocked == False)
				f.SetBool('WCHQ_SublevelKeypadHatch_Open', m.bLocked,, 23);
	}
	else if ((localURL == "20_GOATCITY") || (localURL == "22_GOATCITY"))
	{
		// Reset the player skin if he's picked up the disguise
		if (f.GetBool('HAS_GoatDisguise'))
		{
			// log("Has disguise");
			if (deusexplayer(getplayerpawn()).PlayerSkin > 12)
			{
				deusexplayer(getplayerpawn()).MultiSkins[3] = texture(DynamicLoadObject("TNMCharacters.Skins.GoatTex4", class'texture' ));
				deusexplayer(getplayerpawn()).MultiSkins[5] = texture(DynamicLoadObject("TNMCharacters.Skins.GoatTex1", class'texture' ));
			}
			else
			{
				deusexplayer(getplayerpawn()).MultiSkins[1] = texture(DynamicLoadObject("TNMCharacters.Skins.GoatTex3", class'texture' ));
				deusexplayer(getplayerpawn()).MultiSkins[2] = texture(DynamicLoadObject("TNMCharacters.Skins.GoatTex4", class'texture' ));
				deusexplayer(getplayerpawn()).MultiSkins[4] = texture(DynamicLoadObject("TNMCharacters.Skins.GoatTex2", class'texture' ));
				deusexplayer(getplayerpawn()).MultiSkins[5] = texture(DynamicLoadObject("TNMCharacters.Skins.GoatTex3", class'texture' ));
			}
		}
	}
	
	if (localURL == "20_WCFLOOR1")
	{
		foreach AllActors(class'DeusExMover', Mover)
		{
			if (Mover.Tag == 'PElevator_Doors0')
			{
				Mover.InterpolateTo(0,0);  // Instantly go back to closed position
				Mover.Enable( 'Trigger' ); // Allow us to instantly reopen it.
			}
		}
	}
	else if (localURL == "20_WCFLOOR2")
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

	Super.PreTravel();
}


// ----------------------------------------------------------------------
// Timer()
//
// Main state machine for the mission
// ----------------------------------------------------------------------

function Timer()
{
	local tnmweapon Dguns;
	local deusexmover m;
	local TNMPawn p;
	local trigger t;
	local inventory inv;
	local securitycamera c;
	local deusexdecoration turret;
	local MapExit me;
	local Teleporter tp;
	local button1 btn;

	Super.timer();

	//The player killed Scara and is forever doomed.
	if (flags.GetBool('Scara_Dead'))
	{
		foreach allactors(class'MapExit', me)
			me.DestMap = "20_WCFloor4#Narcissus";
		foreach allactors(class'Teleporter', tp)
			tp.URL = "Narcissus";
	}

	//give the double guns the silencer
	if (flags.GetBool('BOUGHT_Andreus_PistolSilencers'))  
		foreach AllActors(class'tnmweapon', Dguns) 
			Dguns.MakeSilenceVis();

	if (!flags.GetBool('CheckedSubwayPass'))
	{
		for ( inv = player.inventory ; inv != none ; inv = inv.inventory)
		{
			if ( inv.IsA('SubwayPass') )
			{
				AddGoal('SubwayMoney', strHasSubPass, true, true);
				flags.SetBool('CheckedSubwayPass',true,true,23);
				break;
			}
		}
	}

	// Fail PJ's mission if you knock him out or kill him
	if ((localURL == "20_FCSLUMS") || (localURL == "22_FCDOWNTOWN"))
	{
		if ((localURL == "20_FCSLUMS") && (flags.GetBool('PJ_Dead') || (flags.GetBool('PJ_Unconscious'))))
			flags.SetBool('PJ_Dead_Early',true,,23);
		if (flags.GetBool('QR_SUB_Bugging') && !flags.GetBool('QC_SUB_Bugging'))
		{
			if (flags.GetBool('PJ_Dead'))
			{
				AddGoal('Bugging', strPJDead, FALSE, TRUE);
				flags.SetBool('QC_SUB_Bugging',true,,23);
			}
			else if (flags.GetBool('PJ_Unconscious'))
			{
				AddGoal('Bugging', strPJUnconscious, FALSE, TRUE);
				flags.SetBool('QC_SUB_Bugging',true,,23);
			}
		}
	}

	if ((localURL == "20_GOATCITY") || (localURL == "22_GOATCITY"))
	{/*
		// Change the player's skin and make everybody friendly if he picks up a disguise
		if (flags.GetBool('HAS_GoatDisguise') && !flags.GetBool('MS_VoidGoatDisguise'))
		{
			foreach allactors(class'TNMPawn',p,)
				p.ChangeAlly('Player',1.000000,false);

			// TODO: Actually change the skin, lol
		}*/
	}

	if(localURL ~= "20_LlamaTemple" || localURL ~= "22_LlamaTemple")
	{
		if(!flags.GetBool('CheckedBeefmanTurretsDrop'))
		{
			foreach AllActors(Class'TNMPawn',p,'Beefman')
			{
				if(int(p.GetPawnAllianceType(GetPlayerPawn()))==2)
				{
					foreach AllActors(Class'DeusExMover',m,'BeefmanTurretHatches')
						m.Trigger(None,None);
					foreach AllActors(Class'DeusExMover',m,'BeefmanForceField')
						m.Trigger(None,None);

					if(IsA('tnmMission20'))
					{
						flags.SetBool('CheckedBeefmanTurretsDrop',true,true,21);
						flags.SetBool('CheckBeefmanTurretsDie',true,true,21);
					}
					else
					{
						flags.SetBool('CheckedBeefmanTurretsDrop',true,true,23);
						flags.SetBool('CheckBeefmanTurretsDie',true,true,23);
					}
				}
				break;
			}
		}

		if(flags.GetBool('CheckBeefmanTurretsDie'))
		{
			foreach AllActors(Class'DeusExDecoration',turret,'BeefmanTurret')
				break;

			if(turret==None)
			{
				foreach AllActors(Class'TNMPawn',p,'Beefman')
				{
					p.ChangeAlly('Player',- 1.0, true);
					break;
				}

				foreach AllActors(Class'DeusExMover',m,'BeefmanForceField')
					m.Trigger(None,None);

				if(IsA('tnmMission20'))
					flags.SetBool('CheckBeefmanTurretsDie',false,true,21);
				else
					flags.SetBool('CheckBeefmanTurretsDie',false,true,23);
			}
		}
	}

	if ((localURL == "20_PDXHQ01") || (localURL == "22_PDXHQ01"))
	{
		if (flags.GetBool('ALLIED_WC'))
		{
			if (localURL != "22_PDXHQ01" && flags.GetBool('QR_SUB_PDXVirus') && flags.GetBool('Evil_Dead'))
				SendPM("PM_Scara_EvilDead");
		}
		if(!flags.GetBool('ALLIED_WC') && !flags.GetBool('MS_PDX_Murderer'))
		{
			//knocked out then killed jonas, jerk
			if(flags.GetBool('Jonas_Dead'))
			{
				flags.SetBool('PDX_Dead',true,,21);
				PDXHQMurder();
			}
		}
	}
	if ((localURL == "20_WCFLOOR4") ||(localURL == "22_WCFLOOR4"))
	{
		// Make sure the player can't save after killing Scara (lest he be stuck)
		if (flags.GetBool('Scara_Dead'))
		{
			Trestkon(player).CantSave = True;

			// And make everybody hostile!
			//Todo - this is hardly everyone
			foreach allactors(class'securitycamera',c,)
				c.bNoAlarm = false;
		}
	}
}

function PlayerDetected(name StateType, optional ScriptedPawn Triggerer)
{
	local TNMPawn p;

	/* Looks like this was never finished
	if ((localURL == "20_GOATCITY") || (localURL == "22_GOATCITY") || (localURL == "20_GOATTEMPLAE") || (localURL == "22_GOATTEMPLAE"))
	{
		// Revert everything if the player blows his cover
		if (flags.GetBool('HAS_GoatDisguise') && !flags.GetBool('MS_VoidGoatDisguise'))
		{
			SendPM("PM_Abom_VoidDisguise");

			// Make all the guards hostile again
			foreach allactors(class'TNMPawn',p,)
				p.ChangeAlly('Player',-1.000000,true);

			flags.SetBool('MS_VoidGoatDisguise',true,,23);
		}
	}*/

	if ((localURL ~= "20_WCSublevel") || (localURL ~= "22_WCSublevel"))
		if (flags.GetBool('QR_SUB_BlackICE') && !flags.GetBool('Evil_Done'))
			flags.SetBool('NS_BlackICE',true);
}


// ----------------------------------------------------------------------
// Handle the public bulletin computers
// ----------------------------------------------------------------------

simulated function bool DisplayNews(string filename)
{
	if (flags == None)
	{
		if (Player == None)
			Player = DeusExPlayer(GetPlayerPawn());
		if (Player != None)
			flags = Player.FlagBase;
		if (flags == None)
			return true;
	}
	// NOTE: Bulletin01 will always show up.
	//       Bulletin02, Bulletin13, and Bulletin28 are only mission-dependent and thus controlled by the menu files.

	// MISSION-INDEPENDENT

	// Raving Nutter Murdered
	if ((filename == "Bulletin17") && !flags.GetBool('Raving_Dead'))
		return false;

	// Yardbomb Killed
	if ((filename == "Bulletin18") && !flags.GetBool('Yardbomb_Dead'))
		return false;

	// Chris the Cynic Murdered
	if ((filename == "Bulletin19") && !flags.GetBool('Chris_Dead'))
		return false;

	// Dark Templar Killed
	if ((filename == "Bulletin20") && !flags.GetBool('DarkTemplar_Dead'))
		return false;

	// Abomination Killed
	if ((filename == "Bulletin21") && !flags.GetBool('Abomination_Dead'))
		return false;

	// MISSION 20
	// The Recent Abduction
	if ((filename == "Bulletin03") && (flags.GetBool('ALLIED_PDX') || flags.GetBool('ALLIED_WC')))
		return false;

	// Trestkon to Lead Investigation
	if ((filename == "Bulletin04") && !flags.GetBool('ALLIED_PDX'))
		return false;

	// Trestkon Rejects Aiding Investigation
	if ((filename == "Bulletin05") && !flags.GetBool('ALLIED_WC'))
		return false;

	// Cult Conflict Peaks
	if ((filename == "Bulletin06") && !(flags.GetBool('QR_MAIN_StealPassword') || flags.GetBool('QR_MAIN_ShadowCode')))
		return false;

	// N00Bz Gang Defeated (all killed)
	if ((filename == "Bulletin07") && (!flags.GetBool('QC_SUB_N00Bz') || !flags.GetBool('N00Bz_Dead')))
		return false;

	// N00Bz Gang Disbanded (N00Bz alive)
	if ((filename == "Bulletin08") && (!flags.GetBool('QC_SUB_N00Bz') || flags.GetBool('N00Bz_Dead')))
		return false;

	// N00Bz Gang Defeated (Firewalls handled it)
	if ((filename == "Bulletin09") && (!flags.GetBool('MS_DTCleanup_Done') || flags.GetBool('QC_SUB_N00Bz')))
		return false;

	// Fight at the Partyzone
	if ((filename == "Bulletin14") && !flags.GetBool('MS_PartyzoneTrouble'))
		return false;

	// Fight in Sol's Bar
	if ((filename == "Bulletin15") && (!flags.GetBool('MS_SolsTrouble_Post') || flags.GetBool('AlphaOperator_Dead')))
		return false;

	// Fight in Sol's Bar (and AO dead)
	if ((filename == "Bulletin16") && (!flags.GetBool('MS_SolsTrouble_Post') || !flags.GetBool('AlphaOperator_Dead')))
		return false;

	// Police Investigating Downtown Burglary
	if ((filename == "Bulletin29") && (!flags.GetBool('MS_DTCleanup_Done') || !flags.GetBool('MS_BreakAndEnter')))
		return false;

	// MISSION 22
	// Investigation Update
	if ((filename == "Bulletin10") && !flags.GetBool('ALLIED_PDX'))
		return false;

	// Trestkon Involved With WC Inc.
	if ((filename == "Bulletin11") && !flags.GetBool('ALLIED_WC'))
		return false;

	// Trestkon Suspected of Murder
	if ((filename == "Bulletin12") && class'tnmconplay'.static.g_FlagSet('Killed_20_FCDowntown_and_20_FCCorporate_and_20_FCSlums_20', player))
		return false;

	// Athena Assassinated
	if ((filename == "Bulletin22") && !flags.GetBool('Athena_Dead') && !flags.GetBool('Athena_Fight_Dead'))
		return false;

	// Beefman Assassinated
	if ((filename == "Bulletin23") && !flags.GetBool('Beefman_Dead'))
		return false;

	// Sol's Bar Bombed
	if ((filename == "Bulletin24") && (!flags.GetBool('ALLIED_PDX') || flags.GetBool('AlphaOperator_Dead')))
		return false;

	// Sol's Bar Bombed (and AO dead)
	if ((filename == "Bulletin25") && (!flags.GetBool('ALLIED_PDX') || !flags.GetBool('AlphaOperator_Dead')))
		return false;

	// DXO base found under Sol's Bar
	if ((filename == "Bulletin26") && (!flags.GetBool('ALLIED_WC') || flags.GetBool('MS_SolsTrouble_Post')))
		return false;

	// DXO base found under Sol's Bar (and trouble reported)
	if ((filename == "Bulletin27") && (!flags.GetBool('ALLIED_WC') || !flags.GetBool('MS_SolsTrouble_Post')))
		return false;

	// DXO Cleared of all Charges
	if ((filename == "Bulletin30") && !flags.GetBool('Kashue5_Played'))
		return false;

	// DXO Neutralized
	if ((filename == "Bulletin31") && (!flags.GetBool('Kashue4Bad_Played') || flags.GetBool('Kevo_Dead')))
		return false;

	// DXO Neutralized (Kevo dead)
	if ((filename == "Bulletin32") && (!flags.GetBool('Kashue4Bad_Played') || !flags.GetBool('Kevo_Dead')))
		return false;

	// PDX Headquarters Attacked!
	if ((filename == "Bulletin33") && (!flags.GetBool('QC_MAIN_GetNewsscript') || !class'tnmconplay'.static.g_FlagSet('Killed_20_PDXHQ01_and_20_PDXHQ02_0', player) || !flags.GetBool('NS_PDXHQ')))
		return false;

	// PDX Headquarters Attacked! (casualties)
	if ((filename == "Bulletin34") && (!flags.GetBool('QC_MAIN_GetNewsscript') || class'tnmconplay'.static.g_FlagSet('Killed_20_PDXHQ01_and_20_PDXHQ02_0', player) || !flags.GetBool('NS_PDXHQ')))
		return false;

	// PDX Headquarters Attacked! (casualties + ghosted)
	if ((filename == "Bulletin35") && (!flags.GetBool('QC_MAIN_GetNewsscript') || class'tnmconplay'.static.g_FlagSet('Killed_20_PDXHQ01_and_20_PDXHQ02_0', player) || flags.GetBool('NS_PDXHQ')))
		return false;

	return true;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

//initially I used defaultproperties but they can't handle arrays within structs
function AddLevelInfo(out int index, out int tag, Name flag, string level)
{
	//log("creating persistent level data"@"["$index$"]");
	//log("level:"@level);
	//log("flag:"@flag);
	tag=0;
	persistent_levels[index].flag_name=flag;
	persistent_levels[index].level_save="20_"$level;	
	persistent_levels[index++].level_load="22_"$level;
}

function AddLevelTag(int lvl, out int index, Name tag)
{
	persistent_levels[lvl-1].tags[index++]=tag;
}

function GetPersistentLevelData()
{
	local int lvl,tag;

	//log("persistent level data creation started...");

	AddLevelInfo(lvl, tag, 'PersistentLevel_GoatTemplae_1',"GOATTEMPLAE");
	AddLevelTag(lvl, tag, 'TemplaeSkillAwardAOM');
	AddLevelTag(lvl, tag, 'TemplaeSkillAwardCave');
	AddLevelTag(lvl, tag, 'TemplaeAug');
	AddLevelTag(lvl, tag, 'TemplaeRebreatherCrate');

	AddLevelInfo(lvl, tag, 'PersistentLevel_WCSublevel_1',"WCSUBLEVEL");
	AddLevelTag(lvl, tag, 'SublevelAug');
	AddLevelTag(lvl, tag, 'SublevelAugUpgrade');
	AddLevelTag(lvl, tag, 'SublevelModRange');
	AddLevelTag(lvl, tag, 'SublevelModRecoil');
	AddLevelTag(lvl, tag, 'SublevelJumpShotgun');
	AddLevelTag(lvl, tag, 'SublevelJumpShell1');
	AddLevelTag(lvl, tag, 'SublevelJumpShell2');
	AddLevelTag(lvl, tag, 'SublevelJumpSA');
	AddLevelTag(lvl, tag, 'SublevelExplosionSA');
	AddLevelTag(lvl, tag, 'SublevelUCSA');
	AddLevelTag(lvl, tag, 'SublevelPrisonKey');
	AddLevelTag(lvl, tag, 'SublevelGasroomMedkit');
	AddLevelTag(lvl, tag, 'SublevelGasroomCrate');
	AddLevelTag(lvl, tag, 'KylieCredits');
	AddLevelTag(lvl, tag, 'ZPPistol');
	AddLevelTag(lvl, tag, 'SublevelLAMCrate');
	AddLevelTag(lvl, tag, 'FistPickupStun');
	AddLevelTag(lvl, tag, 'SublevelAugUpgradeZP');

	AddLevelInfo(lvl, tag, 'PersistentLevel_WCFloor4_1',"WCFLOOR4");
	AddLevelTag(lvl, tag, 'WC4Upgrade');

	AddLevelInfo(lvl, tag, 'PersistentLevel_FCDowntown_1',"FCDOWNTOWN");
	AddLevelTag(lvl, tag, 'DowntownApollo_SkillAward');
	AddLevelTag(lvl, tag, 'DowntownCanals_SkillAward');
	AddLevelTag(lvl, tag, 'DowntownCanals_Lockpick1');
	AddLevelTag(lvl, tag, 'DowntownCanals_Lockpick2');
	AddLevelTag(lvl, tag, 'DowntownCanals_ReloadMod');
	AddLevelTag(lvl, tag, 'DowntownCanals_Liquor');
	AddLevelTag(lvl, tag, 'DowntownAlley_MedKit');
	AddLevelTag(lvl, tag, 'DowntownAlley_RecoilMod');
	AddLevelTag(lvl, tag, 'DowntownAlley_Sabot');
	AddLevelTag(lvl, tag, 'DowntownShip_Shotgun');
	AddLevelTag(lvl, tag, 'DowntownShip_LAM1');
	AddLevelTag(lvl, tag, 'DowntownShip_LAM2');

	AddLevelInfo(lvl, tag, 'PersistentLevel_WeaponShop_1',"WEAPONSHOP");
	AddLevelTag(lvl, tag, 'FistPickupLethal');
	// AddLevelTag(lvl, tag, 'Locker_SkillAward');
	// AddLevelTag(lvl, tag, 'Locker_GoalComplete');
	AddLevelTag(lvl, tag, 'Locker_Aug');
	AddLevelTag(lvl, tag, 'Locker_Credits');
	AddLevelTag(lvl, tag, 'Locker_EMPGrenade');
	AddLevelTag(lvl, tag, 'Locker_Ammo45');
	AddLevelTag(lvl, tag, 'Locker_BECell1');
	AddLevelTag(lvl, tag, 'Locker_BECell2');
	AddLevelTag(lvl, tag, 'WeaponDoubleGuns');
	AddLevelTag(lvl, tag, 'Locker_Pistol');
	AddLevelTag(lvl, tag, 'Locker_10mm1');
	AddLevelTag(lvl, tag, 'Locker_10mm2');
	AddLevelTag(lvl, tag, 'Locker_GasGren1');
	AddLevelTag(lvl, tag, 'Locker_GasGren2');
	AddLevelTag(lvl, tag, 'Locker_GasGren3');
	AddLevelTag(lvl, tag, 'Locker_Blowdart1');
	AddLevelTag(lvl, tag, 'Locker_Blowdart2');
	AddLevelTag(lvl, tag, 'Locker_20mm1');
	AddLevelTag(lvl, tag, 'Locker_20mm2');
	AddLevelTag(lvl, tag, 'Locker_EMPGrenade2');
	AddLevelTag(lvl, tag, 'Locker_Shell');
	AddLevelTag(lvl, tag, 'Locker_Scramble');
	AddLevelTag(lvl, tag, 'Locker_3006');
	AddLevelTag(lvl, tag, 'Locker_Mine');
	AddLevelTag(lvl, tag, 'Locker_Plasma');
	AddLevelTag(lvl, tag, 'Locker_Prod');
	AddLevelTag(lvl, tag, 'Locker_ProdBattery');
	AddLevelTag(lvl, tag, 'Locker_Pepper1');
	AddLevelTag(lvl, tag, 'Locker_Pepper2');
	AddLevelTag(lvl, tag, 'Locker_Darts');
	AddLevelTag(lvl, tag, 'Locker_Taser');

	AddLevelInfo(lvl, tag, 'PersistentLevel_Slums_1',"FCSLUMS");
	AddLevelTag(lvl, tag, 'YardbombAptAward');
	AddLevelTag(lvl, tag, 'FistPickupShock');
	AddLevelTag(lvl, tag, 'ElevatorLiquorBottle');
	AddLevelTag(lvl, tag, 'ElevatorVialCrack1');
	AddLevelTag(lvl, tag, 'ElevatorVialCrack2');
	AddLevelTag(lvl, tag, 'SewerCrate1');
	AddLevelTag(lvl, tag, 'SewerCrate2');
	AddLevelTag(lvl, tag, 'SewerFlare1');
	AddLevelTag(lvl, tag, 'SewerFlare2');

	AddLevelInfo(lvl, tag, 'PersistentLevel_DXO_1',"DXO");

	AddLevelInfo(lvl, tag, 'PersistentLevel_FCCorporate_1',"FCCORPORATE");

	AddLevelInfo(lvl, tag, 'PersistentLevel_PDXHQ01_1',"PDXHQ01");

	AddLevelInfo(lvl, tag, 'PersistentLevel_PDXHQ02_1',"PDXHQ02");
	AddLevelTag(lvl, tag, 'FistPickupBan');

	AddLevelInfo(lvl, tag, 'PersistentLevel_GoatCity_1',"GOATCITY");
	AddLevelTag(lvl, tag, 'SkillAward_Rock');
	AddLevelTag(lvl, tag, 'SkillAward_Cellar');
	AddLevelTag(lvl, tag, 'SkillAward_SpyRoom');
	AddLevelTag(lvl, tag, 'GoatCityTrapdoorKey');

	AddLevelInfo(lvl, tag, 'PersistentLevel_FCCorpSewers_1',"FCCORPSEWERS");
	AddLevelTag(lvl, tag, 'ItemCrate01');
	AddLevelTag(lvl, tag, 'ItemCrate02');
	AddLevelTag(lvl, tag, 'ItemCrate03');
	AddLevelTag(lvl, tag, 'ItemCrate04');
	AddLevelTag(lvl, tag, 'ItemCrate05');
	AddLevelTag(lvl, tag, 'ItemCrate06');
	AddLevelTag(lvl, tag, 'ItemCrate07');
	AddLevelTag(lvl, tag, 'ItemCrate08');
	AddLevelTag(lvl, tag, 'ItemCrate09');
	AddLevelTag(lvl, tag, 'Molotov01');
	AddLevelTag(lvl, tag, 'Molotov02');
	AddLevelTag(lvl, tag, 'LAM01');
	AddLevelTag(lvl, tag, 'SniperRifle01');
	AddLevelTag(lvl, tag, 'SniperAmmo01');
	AddLevelTag(lvl, tag, 'Multitool01');

	AddLevelInfo(lvl, tag, 'PersistentLevel_VoodooShop_1',"VOODOOSHOP");
	AddLevelTag(lvl, tag, 'WeaponKatanaRonin');
	AddLevelTag(lvl, tag, 'WeaponBlowPipe');

	//log("persistent level data creation finished...");
}

function KillTrestkon()
{
	local trestkon t;
	local int RNG;
	local Spawnpoint SP;
	local ScriptedPawn P;
	local Rotator rot;
	local Vector loc;
	local AutoTurret at;
	local bool bFound;
	
	t = trestkon(getplayerpawn());
	if ( t != none )
	{
		t.bEntityDeath = True;
		
		foreach AllActors(class'Spawnpoint', SP, 'NarcSpawnPoints')
		{
			bFound = True;
			break;
		}
		if (bFound)
			RNG = Rand(14);
		else
			RNG = Rand(3);
		switch (RNG)
		{
			case 0:
				t.HealthTorso = 0;
				t.Health = 0;
				t.TakeDamage(1, t, t.Location, vect(0,0,0), 'shot');
				break;
			case 1:
				t.TakeDamage(1, t, t.Location, vect(0,0,0), 'flamed');
				t.HealthTorso = 0;
				t.Health = 0;
				t.TakeDamage(1, t, t.Location, vect(0,0,0), 'flamed');
				break;
			case 2:
				t.TakeDamage(1000, t, t.Location, vect(0,0,0), 'exploded');
				break;
			case 3:
				foreach AllActors(class'Spawnpoint', SP, 'NarcSpawnPoints')
				{
					Rot = Rotator(t.Location - SP.Location);
					// SP.SetRotation(Rot);
					Spawn(Class'RocketLAW',,,SP.Location,Rot);
				}
				break;
			case 4:
				foreach AllActors(class'Spawnpoint', SP, 'NarcSpawnPoints')
				{
					Rot = Rotator(t.Location - SP.Location);
					// SP.SetRotation(Rot);
					Spawn(Class'RocketWP',,,SP.Location,Rot);
				}
				break;
			case 5:
				foreach AllActors(class'Spawnpoint', SP, 'NarcSpawnPoints')
				{
					Rot = Rotator(t.Location - SP.Location);
					// SP.SetRotation(Rot);
					P = ScriptedPawn(Spawn(class<actor>(DynamicLoadObject("TNMCharacters.TNMGreasel",class'Class')),,,SP.Location,Rot));
					P.bInvincible = True;
					P.SetAlliance('Narcissus');
					P.ChangeAlly('Player', -1.0, true);
					P.SetEnemy(t);
					// P.GoToState('Attacking');
				}
				break;
			case 6:
				foreach AllActors(class'Spawnpoint', SP, 'NarcSpawnPoints')
				{
					Rot = Rotator(t.Location - SP.Location);
					// SP.SetRotation(Rot);
					P = ScriptedPawn(Spawn(class<actor>(DynamicLoadObject("TNMCharacters.MelkyGreasel",class'Class')),,,SP.Location,Rot));
					P.bInvincible = True;
					P.SetAlliance('Narcissus');
					P.ChangeAlly('Player', -1.0, true);
					P.SetEnemy(t);
					// P.GoToState('Attacking');
				}
				break;
			case 7:
				foreach AllActors(class'Spawnpoint', SP, 'NarcSpawnPoints')
				{
					Rot = Rotator(t.Location - SP.Location);
					// SP.SetRotation(Rot);
					P = ScriptedPawn(Spawn(class<actor>(DynamicLoadObject("TNMCharacters.RedGreasel",class'Class')),,,SP.Location,Rot));
					P.bInvincible = True;
					P.SetAlliance('Narcissus');
					P.ChangeAlly('Player', -1.0, true);
					P.SetEnemy(t);
					// P.GoToState('Attacking');
				}
				break;
			case 8:
				foreach AllActors(class'Spawnpoint', SP, 'NarcSpawnPoints')
				{
					Rot = Rotator(t.Location - SP.Location);
					Spawn(class<actor>(DynamicLoadObject("TNMItems.PlasmaProj",class'Class')),,,SP.Location,Rot);
				}
				break;
			case 9:
				foreach AllActors(class'Spawnpoint', SP, 'NarcSpawnPoints')
				{
					Rot = Rotator(t.Location - SP.Location);
					// SP.SetRotation(Rot);
					P = ScriptedPawn(Spawn(class<actor>(DynamicLoadObject("TNMCharacters.Abomnation",class'Class')),,,SP.Location,Rot));
					P.bInvincible = True;
					P.SetAlliance('Narcissus');
					P.ChangeAlly('Player', -1.0, true);
					P.SetEnemy(t);
					// P.GoToState('Attacking');
				}
				break;
			case 10:
				foreach AllActors(class'Spawnpoint', SP, 'NarcSpawnPoints')
				{
					Rot = Rotator(t.Location - SP.Location);
					// SP.SetRotation(Rot);
					P = ScriptedPawn(Spawn(class<actor>(DynamicLoadObject("TNMCharacters.Ghand",class'Class')),,,SP.Location,Rot));
					P.bInvincible = True;
					P.SetAlliance('Narcissus');
					P.ChangeAlly('Player', -1.0, true);
					P.SetEnemy(t);
					// P.GoToState('Attacking');
				}
				break;
			case 11:
				t.HealthHead = 0;
				t.Health = 0;
				loc = t.Location;
				loc.Z += 100;
				Spawn(Class'WHPiano',,,loc,);
				t.TakeDamage(1, t, t.Location, vect(0,0,0), 'crushed');
				t.PlaySound(sound'Piano1', SLOT_Misc,,, 256);
				break;
			case 12:
				foreach AllActors(class'Spawnpoint', SP, 'NarcSpawnPoints')
				{
					at = Spawn(Class'AutoTurret',,,SP.Location,Rot);
					at.maxRange = 2048;
					at.SetPhysics(PHYS_Falling);
				}
				break;
			case 13:
				foreach AllActors(class'Spawnpoint', SP, 'NarcSpawnPoints')
				{
					Rot = Rotator(t.Location - SP.Location);
					// SP.SetRotation(Rot);
					P = Spawn(Class'Treskton',,,SP.Location,Rot);
					P.bInvincible = True;
					P.SetAlliance('Narcissus');
					P.ChangeAlly('Player', -1.0, true);
					P.SetEnemy(t);
					// P.GoToState('Attacking');
				}
				break;
		}
			
		t.SetAchievement("achNarcWC");
	}
}

function VoodooCalloutKatana()
{
	local keypad2 keypad;
	
	foreach AllActors(class'Keypad2', keypad)
	{
		if (keypad.Event == 'Swordcase' && keypad.hackStrength > 0)
			SendPM("PM_Narc_Yardbomb");
	}
}

function VoodooCalloutBlowpipe()
{
	local keypad2 keypad;
	
	foreach AllActors(class'Keypad2', keypad)
	{
		if (keypad.Event == 'BlowpipeCase' && keypad.hackStrength > 0)
			SendPM("PM_Narc_Yardbomb");
	}
}

function HandleGameEvent(name scriptFunction)
{
	switch ( scriptFunction )
	{
		case 'KillTrestkon':
			KillTrestkon();
			break;
		case 'DDHologramAppear':
			DDHologramAppear();
			break;
		case 'DDHologramDisappear':
			DDHologramDisappear();
			break;
		case 'VoodooCalloutBlowpipe':
			VoodooCalloutBlowpipe();
			break;
		case 'VoodooCalloutKatana':
			VoodooCalloutKatana();
			break;
		default: super.HandleGameEvent(scriptFunction);
	}
}

defaultproperties
{
     strJimmyNoPay="jimmycracker will have a really hard time paying you now."
     strHasSubPass="You have obtained a day pass to the subway system."
     strPJDead="You have killed Pimp-Jojo. Presumably you had a good reason."
     strPJUnconscious="Pimp-Jojo is seeing stars. You've probably seen the last of him."
}

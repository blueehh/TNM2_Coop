class tnmMission21 extends TNMMissionScript;

var localized string strGoalThreadsClosed, strEpicAward, strGoalBug;

//var float statictime;

// ----------------------------------------------------------------------
// FirstFrame()
// 
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
	local TNMPawn p;
	local trigger t;
	local actor a;
	local TNMInformationDevices cube;

	// settimer(10.0,true);
	Super.FirstFrame();

	MaybeRemoveSlicerAndZP();

	if (localURL == "21_DXI_FRONTEND")
	{
		// Make sure all of this M20 left-over stuff only happens once
		if (!flags.GetBool('Mission20Cleanup_Done'))
		{
			foreach AllActors(class'trigger', t, 'StartMissionCinematic')
			{
				t.trigger(player,player);
			}

			// Handle awards from the mission 20 city maps
			if (!flags.GetBool('KillCount_Mission20Done'))
			{
				// Identify the player as an asshole
				if (flags.GetInt('KillCount_FCDowntown') +
				    flags.GetInt('KillCount_FCCorporate') +
				    flags.GetInt('KillCount_FCSlums')
				    >= FCAggressiveKills)
					flags.SetBool('Killer_FC',true,,23);
			}

			// Re-add the Bugging quest (secondary goals are auto-deleted between missions)
			if (flags.GetBool('QR_SUB_Bugging'))
				AddGoal('Bugging', strGoalBug, FALSE, FALSE);

			// Remember that the player knocked Alpha out in M20
			if (flags.GetBool('AlphaOperator_Unconscious'))
			{
				flags.SetBool('AlphaOperator_Unconscious_M20',true,,23);
				if(!flags.GetBool('ALLIED_WC'))
					flags.SetBool('AlphaOperator_Dead',true,,0); // Alpha is killed in the bombing
				flags.DeleteFlag('AlphaOperator_Unconscious', FLAG_Bool);
			}

			// Remember that the player knocked Jackie out in M20
			if (flags.GetBool('Jackie_Unconscious'))
			{
				flags.SetBool('Jackie_Unconscious_M20',true,,23);
				if(!flags.GetBool('ALLIED_WC'))
					flags.SetBool('Jackie_Dead',true,,0); // Jackie is killed in the bombing
				flags.DeleteFlag('Jackie_Unconscious', FLAG_Bool);
			}

			// Remember that the player killed Abomination in M20
			if (flags.GetBool('Abomination_Dead'))
				flags.SetBool('Abomination_Dead_M20',true,,23);

			// Remember that the player knocked Jonas out in M20
			if (flags.GetBool('Jonas_Unconscious'))
			{
				flags.SetBool('Jonas_Unconscious_M20',true,,23);
				flags.DeleteFlag('Jonas_Unconscious', FLAG_Bool);
			}

			// Remember that the player knocked Raving out in M20
			if (flags.GetBool('Raving_Unconscious'))
			{
				flags.SetBool('Raving_Unconscious_M20',true,,23);
				flags.DeleteFlag('Raving_Unconscious', FLAG_Bool);
			}

			// Remember that the player knocked Andreus out in M20
			if (flags.GetBool('Andreus_Unconscious'))
			{
				flags.SetBool('Andreus_Unconscious_M20',true,,23);
				flags.DeleteFlag('Andreus_Unconscious', FLAG_Bool);
			}

			// Remember that the player knocked Kylie out in M20
			if (flags.GetBool('Kylie_Unconscious'))
			{
				flags.SetBool('Kylie_Unconscious_M20',true,,24);
				flags.DeleteFlag('Kylie_Unconscious', FLAG_Bool);
			}

			// Remember that the player killed Slicer in the WC Sublevel
			if (flags.GetBool('Slicer_Dead') && !flags.GetBool('Slicer_Dead_M20'))
				flags.SetBool('Slicer_Dead_M20',true,,23);

			// Remember that the player killed ZeroPresence in the Bar
			if (flags.GetBool('Zero_Dead') && !flags.GetBool('Zero_Dead_M20'))
				flags.SetBool('Zero_Dead_M20',true,,23);

			// Handle a bunch of NVS stuff
			if (flags.GetBool('NVShacker_Unconscious'))
			{
				flags.SetBool('NVShacker_Unconscious_M20',true,,23);
				flags.DeleteFlag('NVShacker_Unconscious', FLAG_Bool);
			}

			if (flags.GetBool('NVShackerPet_Unconscious'))
			{
				flags.SetBool('NVShackerPet_Unconscious_M20',true,,23);
				flags.DeleteFlag('NVShackerPet_Unconscious', FLAG_Bool);
			}

			if (flags.GetBool('NVShackerPet_Dead'))
			{
				flags.SetBool('NVShackerPet_Dead_M20',true,,23);
				flags.DeleteFlag('NVShackerPet_Dead', FLAG_Bool);
				//there's a convo reason for deleting this
				//it won't have any of its placement flags set if Dead_M20 is true though
				//so there shouldn't be a sudden resurrection of the bot bug
			}

			// Determine where NVS ends up (if anywhere)
			// (note: if his pet betrayed him and he lived we're still treating him like he's
			// dead because he presumably fled)
			if (!flags.GetBool('NVShacker_Dead') && !flags.GetBool('NVShackerPet_Betrayed'))
			{
				if (flags.GetBool('QC_SUB_SubwayMoneyAlt') || flags.GetBool('NVShacker_Unhappy'))
					flags.SetBool('NVShacker_WC',true,,24);
				else
					flags.SetBool('NVShacker_PDX',true,,24);
			}

			// Determine where A2 ends up
			if (!flags.GetBool('NVShackerPet_Dead_M20'))
			{
				if(flags.GetBool('NVShackerPet_Unconscious_M20') && 
				   (flags.GetBool('NVShacker_Dead') || flags.GetBool('NVShackerPet_Betrayed')))
					flags.SetBool('NVShackerPet_Dead_M20',true,,0); //nvs didn't fix it
				else if(!flags.GetBool('MET_NVShacker') || flags.GetBool('NVShackerPet_Talked') ||
				        flags.GetBool('Abomination_Dead'))
					flags.SetBool('NVShackerPet_NVS',true,,24);
				else
					flags.SetBool('NVShackerPet_Abom',true,,24);
			}

			flags.SetBool('Mission20Cleanup_Done',true,,22);
		}

		// When the lift has been activated, turn on a light and an ambient sound
		if (flags.GetBool('DXI_ElevatorActive'))
			foreach allactors( class'actor', a , 'LiftActiveFX')
				a.Trigger(none,none);
	}
	if (localURL == "21_DXI_MCR")
	{
		if (flags.GetBool('ALLIED_PDX'))
		{
			foreach AllActors(class'TNMPawn', p, 'ZeroPresence')
			{
				p.enterworld();
			}	
		}
		if (flags.GetBool('ALLIED_WC'))
		{
			foreach AllActors(class'TNMPawn', p, 'Slicer')
			{
				p.enterworld();
			}	
		}
		
		
		if ((flags.GetBool('Beeblequix_Dead') || flags.GetBool('Beeblequix_Unconscious')) && !flags.GetBool('Beeble_Greeting_Played'))
		{
			
			foreach AllActors(class'TNMInformationDevices', cube, 'SoftlockDatacube')
			{
				cube.enterworld();
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
	local HackableDevices hd;
	local TNMRobot p;
	
	// Used for Treskton's area
	if (localURL == "21_DXI_MCR")
	{	
		// Anchor point
		// foreach AllActors(class'HackableDevices', hd)
		// {
			// if (hd.Event == 'VaultAlarmLightDispatcher')
				// break;
		// }
		// if (hd != None)
		// {
			foreach AllActors(class'TNMRobot', p, 'fixedbot')
			{
				flags.SetVector('fixedbots_Location', p.Location-p.HomeLoc,, 25);
				flags.SetRotator('fixedbots_Rotation', p.Rotation-Rotator(p.HomeRot),, 25);
			}
		// }
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
	local TNMPawn p;
	local DeusExMover M;

	Super.timer();

	/* REMOVED for being super super annoying
	if (flags.GetBool('BEEBLE_GotHUDCodes'))
	{
		trestkon(player).showstatic(false);
		statictime -= 10;
		if (statictime <= 0)
		{
			statictime = 60 + (Frand() * 240);
			trestkon(player).showstatic(true);
		}		
	}
	*/

	// Autosave at the start of the mission
	if (!flags.GetBool('Autosaved_DXI'))
	{
		trestkon(getplayerpawn()).autosave(true, 21);
		// if (trestkon(getplayerpawn()).autosave(true))
			// flags.SetBool('Autosaved_DXI',true,,22);
	}

	// These pertain to a certain set of easter eggs
	if (flags.GetBool('Jonas_SecretConvo_Played'))
	{
		foreach AllActors(class'TNMPawn', p)
			if(p.IsA('Jonas'))
				p.leaveworld();
	}
	if (flags.GetBool('Phasmatis_SecretConvo_Played'))
	{
		foreach AllActors(class'TNMPawn', p)
			if(p.IsA('Phasmatis'))
				p.leaveworld();
	}
	if (flags.GetBool('Winquman_SecretConvo_Played'))
	{
		foreach AllActors(class'TNMPawn', p)
			if(p.IsA('Winquman'))
				p.leaveworld();
	}

	if (localURL == "21_DXI_MCR")
	{
		// Send an angry PM from Kylie if you kill or knock out ZeroPresence
		if ((flags.GetBool('Zero_Dead') || flags.GetBool('Zero_Unconscious')) && !flags.GetBool('Zero_Dead_M20'))
			SendPM("PM_Kylie_ZP");
		/*
		if (flags.GetBool('MS_GotStaff') && !flags.GetBool('MS_DXI_HolosInWorld'))
		{
			foreach AllActors(class'TNMPawn', p)
			{
				if (flags.GetBool('ALLIED_PDX'))
				{
					if(p.Tag == 'ZeroPresenceHolo')
					{
						p.EnterWorld();
						flags.SetBool('MS_DXI_HolosInWorld', true, , 22);
						break;
					}
				}
				else
				{
					if(p.Tag == 'SlicerHolo')
					{
						p.EnterWorld();
						flags.SetBool('MS_DXI_HolosInWorld', true, , 22);
						break;
					}
				}
			}
		}*/
			
		if ((flags.GetBool('Zero_PreBossFight_Played') || flags.GetBool('Slicer_PreBossFight_Played') || flags.GetBool('Slicer_Unconscious') || flags.GetBool('Slicer_Dead') || flags.GetBool('Zero_Dead') || flags.GetBool('Zero_Unconscious') || flags.GetBool('MS_GotStaff')) && !flags.GetBool('MS_DXI_HolosLeftWorld'))
		{
			foreach AllActors(class'TNMPawn', p)
			{
				if(p.Tag == 'ZeroPresenceHolo')
				{
					p.LeaveWorld();
					if (flags.GetBool('ALLIED_PDX'))
					{
						flags.SetBool('MS_DXI_HolosLeftWorld', true, , 22);
						break;
					}
				}
				if(p.Tag == 'SlicerHolo')
				{
					p.LeaveWorld();
					if (flags.GetBool('ALLIED_WC'))
					{
						flags.SetBool('MS_DXI_HolosLeftWorld', true, , 22);
						break;
					}
				}
			}
		}

		if (!flags.GetBool('MS_GotStaff'))
		{
			if(PlayerHasItem('weaponfirestaff'))
			{
				SkillAward(2000,strEpicAward);
				SendPM("PM_MAIN_GotStaff");
				flags.SetBool('MS_GotStaff', true, , 22);
			}
		}
	}
	if (localURL == "21_DXI_RUINS")
	{
		if ((flags.GetBool('ThreadProtector01_Dead') || flags.GetBool('ThreadProtector01_Unconscious')) && 
		    (flags.GetBool('ThreadProtector02_Dead') || flags.GetBool('ThreadProtector02_Unconscious')) && 
		    (flags.GetBool('ThreadProtector03_Dead') || flags.GetBool('ThreadProtector03_Unconscious')))
		{
			foreach AllActors(class'DeusExMover', M, 'ThreadsFacilityFissure')
				M.TakeDamage(999999, player, vect(0,0,0),vect(0,0,0), 'exploded');

			flags.SetBool('DXI_ThreadsClosed', true, , 22);
			AddGoal('DestroyThreads', strGoalThreadsClosed, TRUE, TRUE);
			SendPM("PM_MAIN_ThreadsClosed");

			flags.DeleteFlag('ThreadProtector01_Dead', FLAG_Bool);
			flags.DeleteFlag('ThreadProtector02_Dead', FLAG_Bool);
			flags.DeleteFlag('ThreadProtector03_Dead', FLAG_Bool);
			flags.DeleteFlag('ThreadProtector01_Unconscious', FLAG_Bool);
			flags.DeleteFlag('ThreadProtector02_Unconscious', FLAG_Bool);
			flags.DeleteFlag('ThreadProtector03_Unconscious', FLAG_Bool);
			
			Trestkon(player).SetAchievement("achThreads");
		}
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function BuzzAppear()
{
	local TNMPawn p;
	foreach allactors(class'TNMPawn', p, 'Buzz')
		p.EnterWorld();		
}

function BuzzDisappear()
{
	local TNMPawn p;
	foreach allactors(class'TNMPawn', p, 'Buzz')
		p.LeaveWorld();		
}

function RoninAppear()
{
	local TNMPawn p;
	foreach allactors(class'TNMPawn', p, 'Ronin')
		p.EnterWorld();		
}

function RoninDisappear()
{
	local TNMPawn p;
	foreach allactors(class'TNMPawn', p, 'Ronin')
		p.LeaveWorld();
}

function GwogDisableCollision()
{
	local TNMPawn p;
	foreach AllActors(Class'TNMPawn',p,'Gwog')
	{
		p.SetCollision(false,false,false);
		p.bCollideWorld=false;
	}

	// Remember that Gwog was spooked (for the denouement)
	flags.SetBool('Gwog_Spooked',true,,);
}

function StaticBurst()
{
	// Transmit a burst of static to the player
	if(flags != None && flags.GetBool('BEEBLE_GotHUDCodes') && !flags.GetBool('Beeblequix_Dead'))
		trestkon(player).ShowStatic(true, 2);
}

function BeebleStatic()
{
	// Transmit a shorter burst of static to the player
	if(flags != None && flags.GetBool('BEEBLE_GotHUDCodes') && !flags.GetBool('Beeblequix_Dead'))
		trestkon(player).ShowStatic(true, 0.5);
}

function FuckJonasRightUpTheAss()
{
	local ProjectileGenerator g;

	flags.SetBool('DXIHQ_VentingEnabled',!flags.GetBool('DXIHQ_VentingEnabled'),,22);

	if(flags != None && flags.GetBool('DXIHQ_GasEnabled'))
	{
		if(flags.GetBool('DXIHQ_VentingEnabled'))
		{
			foreach AllActors(class'ProjectileGenerator',g,'CompRoomGas')
				if(g.bSpewing)
					g.Trigger(None,None);
		}
		else
		{
			foreach AllActors(class'ProjectileGenerator',g,'CompRoomGas')
				if(!g.bSpewing)
					g.Trigger(None,None);
		}
	}
}

function CeilingExplode()
{
	local DeusExMover M;
	foreach allactors(class'DeusExMover', M, 'CeilingExplodeMover')
	{
		M.bBreakable=true;
		M.takedamage(100,none,vect(0,0,0),vect(0,0,0),'Shot');
	}
}

function PostCollapse()
{
	local BlockPlayer pb;
	local DeusExMover M;
	local povcorpse corpse;
	local Pawn P;
	local Trestkon T;
	local Vector collapseLoc;
	local bool bHasCollapseLoc;

	foreach allactors(class'BlockPlayer', pb, 'TunnelBlocker')
	{
		pb.SetCollision( true, ,  );
		if (!bHasCollapseLoc)
		{
			collapseLoc = pb.Location;
			bHasCollapseLoc = True;
		}
	}

	foreach allactors(class'DeusExMover', M, 'ThreadConsole')
	{
		M.bBreakable=true;
		if (!bHasCollapseLoc)
		{
			collapseLoc = M.Location;
			bHasCollapseLoc = True;
		}
	}

	flags.SetBool('MS_TunnelCollapsed', true, , 22);

	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		T = Trestkon(P);
		if (T != None)
		{
			if (!bHasCollapseLoc || VSize(T.Location - collapseLoc) < 1600.0)
			{
				T.LastPainSound = Level.TimeSeconds;
				T.TakeDamage(T.HealthHead * 0.25, none, T.Location + T.CollisionHeight * vect(0,0,1), vect(0,0,-1), 'crushed');
			}

			corpse = povcorpse(T.InHand);
			if (corpse != None)
			{
				T.DropItem();
				if (corpse.CarcassName == 'Zero')
					flags.SetBool('Zero_Dead', true);
				if (corpse.CarcassName == 'Slicer')
					flags.SetBool('Slicer_Dead', true);
				corpse.Destroy();
			}
		}
	}

	MaybeRemoveSlicerAndZP();
}

function MaybeRemoveSlicerAndZP()
{
	local TNMCarcass carc;
	if (flags != None && flags.GetBool('MS_TunnelCollapsed') )
	{
		foreach allactors(class'TNMCarcass', carc, )
		{
			if ( carc.bNotDead )
			{
				if ( carc.CarcassName == 'Zero' || carc.CarcassName == 'Slicer')
				{
					carc.Destroy();
				}
			}
		}
	}
}

function ThreadsHacked()
{
	local TNMPawn p;
	local CrateExplosiveSmall C;
	local DeusExMover M;

	// Remove the protectors
	foreach AllActors(class'TNMPawn', p,)
	{
		if ((p.Tag == 'ThreadProtector01') || (p.Tag == 'ThreadProtector02') || (p.Tag == 'ThreadProtector03'))
			p.Destroy();
	}

	// Enable the elevators
	flags.SetBool('DXI_ThreadsClosed', true,, 22);

	// Blow up the consoles
	foreach AllActors(class'CrateExplosiveSmall', C, 'ThreadsSelfDestruct')
		C.Trigger(None,None);

	// Open up the exit
	foreach allactors(class'DeusExMover', M, 'ThreadsFacilityFissure')
		M.takedamage(999999,none,vect(0,0,0),vect(0,0,0),'Shot');

	// Send the PM
	SendPM("PM_MAIN_ThreadsClosed");
	
	if (Trestkon(GetPlayerPawn()) != None)
		Trestkon(GetPlayerPawn()).SetAchievement("achProgram");
}

function BeebleOneLiner()
{
	if (flags != None && flags.GetBool('BEEBLE_GotHUDCodes'))
	{
		SendPM("PM_Beeble_OneLiner01");
		SendPM("PM_Beeble_OneLiner02");
		SendPM("PM_Beeble_OneLiner03");
		SendPM("PM_Beeble_OneLiner04");
		SendPM("PM_Beeble_OneLiner05");
	}
}

function BeebleRant()
{
	if (flags != None && flags.GetBool('BEEBLE_GotHUDCodes'))
	{
		SendPM("PM_Beeble_Rant01");
		SendPM("PM_Beeble_Rant02");
		SendPM("PM_Beeble_Rant03");
		SendPM("PM_Beeble_Rant04");
		SendPM("PM_Beeble_Rant05");
		SendPM("PM_Beeble_Rant06");
		SendPM("PM_Beeble_Rant07");
		SendPM("PM_Beeble_Rant08");
		SendPM("PM_Beeble_Rant09");
		SendPM("PM_Beeble_Rant10");
	}
}

function DXIBSP1()
{
	local Teleporter Tele;
	local ScaledSprite bspGfx;
	
	if (!flags.GetBool('MS_DXIBSP1'))
	{
		foreach AllActors(class'Teleporter', tele, 'BSP1')
		{
			tele.bEnabled = False;
		}
		foreach AllActors(class'ScaledSprite', bspGfx, 'BSP1')
		{
			bspGfx.bHidden = True;
		}
		flags.SetBool('MS_DXIBSP1', true, , 22);
	}
}

function DXIBSP2()
{
	local Teleporter Tele;
	local ScaledSprite bspGfx;
	
	if (!flags.GetBool('MS_DXIBSP2'))
	{
		foreach AllActors(class'Teleporter', tele, 'BSP2')
		{
			tele.bEnabled = False;
		}
		foreach AllActors(class'ScaledSprite', bspGfx, 'BSP2')
		{
			bspGfx.bHidden = True;
		}
		flags.SetBool('MS_DXIBSP2', true, , 22);
	}
}

function DXIBSP3()
{
	local Teleporter Tele;
	local ScaledSprite bspGfx;
	
	if (!flags.GetBool('MS_DXIBSP3'))
	{
		foreach AllActors(class'Teleporter', tele, 'BSP3')
		{
			tele.bEnabled = False;
		}
		foreach AllActors(class'ScaledSprite', bspGfx, 'BSP3')
		{
			bspGfx.bHidden = True;
		}
		flags.SetBool('MS_DXIBSP3', true, , 22);
	}
}

function DXIBSP4()
{
	local Teleporter Tele;
	local ScaledSprite bspGfx;
	
	if (!flags.GetBool('MS_DXIBSP4'))
	{
		foreach AllActors(class'Teleporter', tele, 'BSP4')
		{
			tele.bEnabled = False;
		}
		foreach AllActors(class'ScaledSprite', bspGfx, 'BSP4')
		{
			bspGfx.bHidden = True;
		}
		flags.SetBool('MS_DXIBSP4', true, , 22);
	}
}

function HandleGameEvent(name scriptFunction)
{
	switch ( scriptFunction )
	{
		case 'BuzzAppear': BuzzAppear(); break;
		case 'BuzzDisappear': BuzzDisappear(); break;
		case 'RoninAppear': RoninAppear(); break;
		case 'RoninDisappear': RoninDisappear(); break;
		case 'GwogDisableCollision': GwogDisableCollision(); break;
		case 'StaticBurst': StaticBurst(); break;
		case 'BeebleStatic': BeebleStatic(); break;
		case 'ToggleVents': FuckJonasRightUpTheAss(); break; //I'm not bitter any more but it still stays
		case 'CeilingExplode': CeilingExplode(); break;
		case 'PostCollapse': PostCollapse(); break;
		case 'ThreadsHacked': ThreadsHacked(); break;
		case 'BeebleOneLiner': BeebleOneLiner(); break;
		case 'BeebleRant': BeebleRant(); break;
		case 'DXIBSP1': DXIBSP1(); break;
		case 'DXIBSP2': DXIBSP2(); break;
		case 'DXIBSP3': DXIBSP3(); break;
		case 'DXIBSP4': DXIBSP4(); break;
	}
}

defaultproperties
{
     strGoalThreadsClosed="You have closed all the old threads of DXI."
     strEpicAward="Epic Achievement Award!"
     strGoalBug="Find the server room in DXI and place a spyware device on one of the servers."
     RemoteRole=ROLE_DumbProxy
}

//=============================================================================
// TNMThrownProjectile.
//=============================================================================
class TNMThrownProjectile extends ThrownProjectile;

var bool bHeatSource;

auto simulated state Flying
{
	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local DeusExPlayer player;
		local Pawn curPawn;
		local float dist;
					
		Player = Trestkon(GetPlayerPawn());
		
		// any player's quad damage, not just the host's
		if (Trestkon(Owner) != None && Trestkon(Owner).bQuadDamage)
			damage *= 4;

		// flash the screen white based on how far away the explosion is
	
		//== Y|y: we need to do this really complicated to make it work in both single and multiplayer, and to work with EVERYONE's grenades
		//==  Thanks to Lork for pointing out that this was a problem
		if(Level.NetMode == NM_Standalone)
			curPawn = GetPlayerPawn();
		else if (( Level.NetMode == NM_DedicatedServer) || ( Level.NetMode == NM_ListenServer))
			curPawn = Level.PawnList;
			
		while(curPawn != None)
		{
			player = DeusExPlayer(curPawn);
			
			dist = Abs(VSize(curPawn.Location - Location));

			// if you are at the same location, blind the player
			if (dist ~= 0)
				dist = 10.0;
			else
				dist = 0.5 * FClamp(blastRadius/dist, 0.0, 8.0);
				// dist = 2.0 * FClamp(blastRadius/dist, 0.0, 4.0);

			if (Player != None)
			{
				if (damageType == 'EMP')
					player.ClientFlash(dist, vect(1,200,1000) * dist);
				else if (damageType == 'TearGas')
					player.ClientFlash(dist, vect(1,1000,100) * dist);
				else
					player.ClientFlash(dist, vect(1000,1000,900) * dist);
			}

			if(Level.NetMode == NM_Standalone) //== Only one player in singleplayer, so halt the loop
				curPawn = None;
			else //== Cycle through all the remaining players in Multiplayer
				curPawn = curPawn.nextPawn;
		}

		if (Role == ROLE_Authority && Level.NetMode != NM_Standalone && tnmGameInfo(Level.Game) != None)
			tnmGameInfo(Level.Game).BroadcastCoopExplosionFX(HitLocation, blastRadius, damageType);

		//DEUS_EX AMSD Only do visual effects if client or if destroyed via damage (since the client can't detect that)
		if ((Level.NetMode != NM_DedicatedServer) || (Role < ROLE_Authority) || bDamaged)
		{
			if (Role < ROLE_Authority && Trestkon(GetPlayerPawn()) != None)
				Trestkon(GetPlayerPawn()).RecordLocalCoopBlast(HitLocation);
			SpawnEffects(HitLocation, HitNormal, None);
			DrawExplosionEffects(HitLocation, HitNormal);
		}

		if ((damageType=='TearGas') && (Role==ROLE_Authority))
			SpawnTearGas();

		PlayImpactSound();
		if (Role < ROLE_Authority && ImpactSound != None)
			PlaySound(ImpactSound, SLOT_None, 2.0,, FMax(blastRadius * 16.0, 1600.0));

		if ( AISoundLevel > 0.0 && Role == ROLE_Authority )
			AISendEvent('LoudNoise', EAITYPE_Audio, 2.0, AISoundLevel*blastRadius*16);

		GotoState('Exploding');
	}
	
	simulated function HitWall (vector HitNormal, actor HitWall)
	{
		local Rotator rot;
		local float   volume;
		local DeusExPlayer player;
	
		player = DeusExPlayer(GetPlayerPawn());
	
		speed = VSize(Velocity);
		
		//G-Flex: try to damage the NPC if it's not a robot
		if (HitWall != None && (HitWall.IsA('ScriptedPawn')) && !(HitWall.IsA('Robot')) && (speed > 400))
			ScriptedPawn(HitWall).TakeDamage(speed / 200.00, Instigator, location, 0.1 * Mass * Velocity, 'impact');
		
		// Grenades detonate on contact with enemies at master demolitions
		if (((IsA('EMPGrenade') || IsA('NanoVirusGrenade') || IsA('GasGrenade') || IsA('LAM')) || (IsA('TNMEMPGrenade') || IsA('TNMNanoVirusGrenade') || IsA('TNMGasGrenade') || IsA('TNMLAM'))) && (HitWall != None && HitWall.IsA('ScriptedPawn')))
		{
			if (Player != None && Player.SkillSystem.GetSkillLevel(class'SkillDemolition') == 3)
			{
				if (HitWall.Mass >= 20 && Owner != None && Owner == Player)
				{
					Explode(Location, Vector(Rotation));
				}
			}
		}
		
		// Hawk - Allow grenades to break windows or weak doors
		if (HitWall != None && (HitWall.IsA('DeusExMover')) && (speed > 400))
		{
			if (((DeusExMover(HitWall).IsA('BreakableGlass')) || (DeusExMover(HitWall).minDamageThreshold <= 10)) && (DeusExMover(HitWall).bBreakable))
				DeusExMover(HitWall).TakeDamage(speed / 50.00, Instigator, location, 0.1 * Mass * Velocity, 'Exploded');
		}
		
		//G-Flex: try to alert NPCs a bit more
		if (AISoundLevel > 0.0)
		{
			//G-Flex: having both does not seem to work well
			//AISendEvent('LoudNoise', EAITYPE_Audio, volume, AISoundLevel*256);
			AISendEvent('Projectile', EAITYPE_Audio, volume, AISoundLevel*256);
		}
		
		// Hawk - Do not bounce if crashing through a window		
		if (HitWall != None && ((HitWall.IsA('DeusExMover')) && (speed > 400)) && (((DeusExMover(HitWall).IsA('BreakableGlass')) || (DeusExMover(HitWall).minDamageThreshold <= 10)) && (DeusExMover(HitWall).bBreakable)))
		{
			return;
		}
		else
		{
			Velocity = Elasticity*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
			if (bFirstHit && speed<400) 
				bFirstHit=False;
			RotationRate = RotRand(True);
			if ( (speed < 60) && (HitNormal.Z > 0.7) )
			{
				volume = 0.5+FRand()*0.5;
				PlaySound(MiscSound, SLOT_None, volume,, 512, 0.85+FRand()*0.3);
						// I know this is a little cheesy, but certain grenade types should
				// not alert AIs unless they are really really close - CNN
				//if (AISoundLevel > 0.0)
				//	AISendEvent('LoudNoise', EAITYPE_Audio, volume, AISoundLevel*256);
				SetPhysics(PHYS_None, HitWall);
				if (Physics == PHYS_None)
				{
					rot = Rotator(HitNormal);
					rot.Yaw = Rand(32767) + Rand(32767); // Rand is limited to 2^15
					SetRotation(rot);
					bBounce = False;
					bStuck = True;
				}
			}
			else If (speed > 50) 
			{
				PlaySound(MiscSound, SLOT_None, 0.5+FRand()*0.5,, 512, 0.85+FRand()*0.3);
			}
		}
	}
}

simulated function TakeDamage(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name damageType)
{
	if (DamageType == 'HalonGas')
		return;
		
	Super.TakeDamage(Damage, instigatedBy, HitLocation, Momentum, damageType);
}

state Exploding
{
	ignores ProcessTouch, HitWall, Explode;

	simulated function Timer()
	{
		gradualHurtCounter++;
		if (Role == ROLE_Authority && gradualHurtCounter <= gradualHurtSteps)
			DamageRing();

		// Keep hidden actor alive ~0.7s past HurtRadius on server so 250ms-500ms
		// clients always receive bDoExplode / ClientPlayExplosionFX cleanly.
		if (Level.NetMode != NM_Standalone && Role == ROLE_Authority)
		{
			if (gradualHurtCounter >= gradualHurtSteps + 14)
				Destroy();
		}
		else if (gradualHurtCounter >= gradualHurtSteps)
		{
			if (Role == ROLE_Authority || RemoteRole == ROLE_None)
				Destroy();
		}
	}
}

simulated function Tick(float deltaTime)
{
	local ScriptedPawn P;
	local DeusExPlayer Player;
	local Vector dist;
	local float blinkRate, proxRelevance;
	local TNMAugmentation TNMA;

	time += deltaTime;

	if (Role == ROLE_Authority)
	{
		Super(DeusExProjectile).Tick(deltaTime);

		if (bDisabled)
			return;

		if ((Owner == None) && ((Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer)) && !bStuck)
		{
			bDisabled = True;
			team = -1;
		}

		// Co-op proximity mines: pre-placed mines trigger on any player; player-planted
		// mines trigger on enemy ScriptedPawns and NEVER blow up your Co-op teammate!
		if (bProximityTriggered && bArmed)
		{
			proxCheckTime += deltaTime;

			if (skillTime != 0)
			{
				if (time > fuseLength && (skillTime % 0.3 > 0.22))
					PlayBeepSound(1600, 2.0, 3.0);
			}

			if (skillTime > 0)
				skillTime -= deltaTime;

			if (skillTime < 0)
			{
				bDoExplode = True;
				bArmed = False;
			}

			proxRelevance = 0.20;
			if (proxCheckTime > proxRelevance)
			{
				proxCheckTime = 0;
				if (Owner == None)
				{
					foreach RadiusActors(class'DeusExPlayer', Player, proxRadius * 4)
					{
						dist = Player.Location - Location;
						if (VSize(dist) < proxRadius && skillTime == 0)
						{
							skillTime = FClamp(-20.0 * Player.SkillSystem.GetSkillLevelValue(class'SkillDemolition'), 1.0, 10.0);
							PlayBeepSound(1600, 2.0, 3.0);
						}
					}
				}
				else
				{
					foreach RadiusActors(class'ScriptedPawn', P, proxRadius * 4)
					{
						if ((P != None) && (P.Mass >= 40) && (P.Health > 0))
						{
							TNMA = None;
							if (TNMPawn(P) != None && TNMPawn(P).TNMPAM != None)
							{
								TNMA = TNMPawn(P).TNMPAM.findaug(class'TNMAugRadarTrans');
								if ((TNMA != None) && (!TNMA.bisactive))
									TNMA = None;
							}
							if (P != Owner && TNMA == None)
							{
								dist = P.Location - Location;
								if (VSize(dist) < proxRadius && skillTime == 0)
								{
									skillTime = 1.0;
									PlayBeepSound(1600, 2.0, 3.0);
								}
							}
						}
					}
				}
			}
		}

		beepTime += deltaTime;
		if (fuseLength - time <= 0.75)
			blinkRate = 0.1;
		else if (fuseLength - time <= fuseLength * 0.5)
			blinkRate = 0.3;
		else
			blinkRate = 0.5;

		if (time < fuseLength && beepTime > blinkRate)
		{
			beepTime = 0;
			PlayBeepSound(1280, 1.0, 0.5);
		}
	}
	else
	{
		// Client-side local fuse beep prediction: crisp, zero-jitter warning beeps at 250ms+!
		Super(DeusExProjectile).Tick(deltaTime);

		if (!bDisabled && !IsInState('Exploding') && fuseLength > 0.0)
		{
			beepTime += deltaTime;
			if (fuseLength - time <= 0.75)
				blinkRate = 0.1;
			else if (fuseLength - time <= fuseLength * 0.5)
				blinkRate = 0.3;
			else
				blinkRate = 0.5;

			if (time < fuseLength && beepTime > blinkRate)
			{
				beepTime = 0;
				PlaySound(sound'Beep4', SLOT_None, 1.2,, 1280, 1.0);
			}
			else if (!bProximityTriggered && time >= fuseLength + 0.08)
			{
				Explode(Location, Vector(Rotation));
				return;
			}
		}
	}

	if (bDoExplode)
		Explode(Location, Vector(Rotation));
}

/*
simulated function Tick(float deltaTime)
{
    local ScriptedPawn P;
    local DeusExPlayer Player;
    local Vector dist, HitLocation, HitNormal;
    local float blinkRate, mult, skillDiff;
    local float proxRelevance;
    local Pawn curPawn;
    local bool pass;
    local Actor HitActor;
	local TNMAugmentation TNMA;

    time += deltaTime;

    if ( Role == ROLE_Authority )
    {
        Super(DeusExProjectile).Tick(deltaTime);

        if (bDisabled)
            return;

        if ( (Owner == None) && ((Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer)) )
        {
            // Owner has logged out
            bDisabled = True;
            team = -1;
        }

        if (( Owner != None ) && (DeusExPlayer(Owner) != None ))
        {
            if ( TeamDMGame(DeusExPlayer(Owner).DXGame) != None)
            {
                // If they switched sides disable the grenade
                if ( DeusExPlayer(Owner).PlayerReplicationInfo.team != team )
                {
                    bDisabled = True;
                    team = -1;
                }
            }
        }

        // check for proximity
        if (bProximityTriggered)
        {
            if (bArmed)
            {
                proxCheckTime += deltaTime;

                // beep based on skill
                if (skillTime != 0)
                {
                    if (time > fuseLength)
                    {
                        if (skillTime % 0.3 > 0.25)
                            PlayBeepSound( 1280, 2.0, 3.0 );
                    }
                }

                // if we have been triggered, count down based on skill
                if (skillTime > 0)
                    skillTime -= deltaTime;

                // explode if time < 0
                if (skillTime < 0)
                {
                    bDoExplode = True;
                    bArmed = False;
                }
                // DC - new ugly way of doing it - old way was "if (proxCheckTime > 0.25)"
                // new way: weight the check frequency based on distance from player
                proxRelevance=DistanceFromPlayer/2000.0;  // at 500 units it behaves as it did before
                if (proxRelevance<0.25)
                    proxRelevance=0.25;               // low bound 1/4
                else if (proxRelevance>10.0)
                    proxRelevance=20.0;               // high bound 30
                else
                    proxRelevance=proxRelevance*2;    // out past 1.0s, double the timing
                if (proxCheckTime>proxRelevance)
                {
                    proxCheckTime = 0;

                    // pre-placed explosives are only prox triggered by the player
                    if (Owner == None)
                    {
                        foreach RadiusActors(class'DeusExPlayer', Player, proxRadius*4)
                        {
                            // the owner won't set it off, either
                            if (Player != Owner)
                            {
                                dist = Player.Location - Location;
                                if (VSize(dist) < proxRadius)
                                    if (skillTime == 0)
                                        skillTime = FClamp(-20.0 * Player.SkillSystem.GetSkillLevelValue(class'SkillDemolition'), 1.0, 10.0);
                            }
                        }
                    }
                    else
                    {
                        // If in multiplayer, check other players
                        if (( Level.NetMode == NM_DedicatedServer) || ( Level.NetMode == NM_ListenServer))
                        {
                            curPawn = Level.PawnList;

                            while ( curPawn != None )
                            {
                                pass = False;

                                if ( curPawn.IsA('DeusExPlayer') )
                                {
                                    Player = DeusExPlayer( curPawn );

                                    // Pass on owner
                                    if ( Player == Owner )
                                        pass = True;
                                    // Pass on team member
                                    else if (TeamDMGame(player.DXGame) != None && (team == player.PlayerReplicationInfo.team) )
                                        pass = True;
                                    // Pass if radar transparency on
                                    else if ( Player.AugmentationSystem.GetClassLevel( class'AugRadarTrans' ) == 3 )
                                        pass = True;

                                    // Finally, make sure we can see them (no exploding through thin walls)
                                    if ( !pass )
                                    {
                                        // Only players we can see : changed this to Trace from FastTrace so doors are included
                                        HitActor = Trace( HitLocation, HitNormal, Player.Location, Location, True );
                                        if (( HitActor == None ) || (DeusExPlayer(HitActor) == Player))
                                        {
                                        }
                                        else
                                            pass = True;
                                    }

                                    if ( !pass )
                                    {
                                        dist = Player.Location - Location;
                                        if ( VSize(dist) < proxRadius )
                                        {
                                            if (skillTime == 0)
                                            {
                                                skillDiff = -skillAtSet + Player.SkillSystem.GetSkillLevelValue(class'SkillDemolition');
                                                if ( skillDiff >= 0.0 ) // Scale goes 1.0, 1.6, 2.8, 4.0
                                                    skillTime = FClamp( 1.0 + skillDiff * 6.0, 1.0, 2.5 );
                                                else    // Scale goes 1.0, 1.4, 2.2, 3.0
                                                    skillTime = FClamp( 1.0 + (-Player.SkillSystem.GetSkillLevelValue(class'SkillDemolition') * 4.0), 1.0, 3.0 );
                                            }
                                        }
                                    }
                                }
                                curPawn = curPawn.nextPawn;
                            }
                        }
                        else    // Only have scripted pawns set off proximity grenades in single player
                        {
                            foreach RadiusActors(class'ScriptedPawn', P, proxRadius*4)
                            {
                                // only "heavy" pawns will set this off
                                if ((P != None) && (P.Mass >= 40))
                                {
									if (TNMPawn(P) != None)
									{
										if (TNMPawn(P).TNMPAM != None)
										{
											TNMA = TNMPawn(P).TNMPAM.findaug(class'TNMAugRadarTrans');
											log("1"@TNMA);
											if ((TNMA != none) && (!TNMA.bisactive))
												TNMA = None;
										}
									}
									log("2"@TNMA);
                                    // the owner won't set it off, either
                                    if (P != Owner && TNMA == None)
                                    {
                                        dist = P.Location - Location;
                                        if (VSize(dist) < proxRadius)
                                            if (skillTime == 0)
                                                skillTime = 1.0;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // beep faster as the time expires
        beepTime += deltaTime;

        if (fuseLength - time <= 0.75)
            blinkRate = 0.1;
        else if (fuseLength - time <= fuseLength * 0.5)
            blinkRate = 0.3;
        else
            blinkRate = 0.5;

        if (time < fuseLength)
        {
            if (beepTime > blinkRate)
            {
                beepTime = 0;
                PlayBeepSound( 1280, 1.0, 0.5 );
            }
        }
    }
    if ( bDoExplode )   // Keep the simulated chain going
        Explode(Location, Vector(Rotation));
}*/

defaultproperties
{
}

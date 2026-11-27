class tnmprojectile extends deusexprojectile;

var sound hitfleshsound;
var sound hitwoodsound;
var sound hitmetalsound;
var sound hitothersound;

var bool bHitFakeBackdrop;
var TNMWeapon ownerWeapon; 	// What weapon created us?
var int  NumKills;			  //How many kills has this projectile got?

var bool Att_Pinpoint;
var bool Att_Incendiary;
var bool Att_Penetrative;
var bool Att_Irritating;
var bool Att_Gaseous;
var bool Att_Lamar;
var bool Att_00n;
var bool Att_Narcissian;
var bool Att_Hunter;
var bool Att_Technophobic;
var bool Att_LowTech;
var bool Att_Junkie;
var bool Att_Quaking;
var bool Att_Immolative;
var bool Att_Embiggening;
var bool Att_Phreaking;
var bool Att_Messy;

function PlayHitwallSound(vector Hitnormal, actor Other)
{
	local name surfacetype;
	
	if (Owner != None)
	{
		if (DeusExDecoration(Other) != None)
			Owner.PlayOwnedSound(hitothersound, SLOT_None,,, 1024);
		else if (Pawn(Other) != None || Carcass(Other) != None)
			Owner.PlayOwnedSound(hitfleshsound, SLOT_None,,, 1024);
		else if (BreakableGlass(Other) != None)
			Owner.PlayOwnedSound(sound'GlassHit1', SLOT_None,,, 1024);
		else 
		{
			surfacetype = GetWallMaterial(Location, HitNormal);
			if (surfacetype  == 'Glass')
				Owner.PlayOwnedSound(sound'BulletProofHit', SLOT_None,,, 1024);
			else if (surfacetype == 'wood')
				Owner.PlayOwnedSound(hitwoodsound, SLOT_None,,, 1024);
			else if (surfacetype == 'metal')
				Owner.PlayOwnedSound(hitmetalsound, SLOT_None,,, 1024);
			else
				Owner.PlayOwnedSound(hitothersound, SLOT_None,,, 1024);
		}
	}
	else
	{
		if (DeusExDecoration(Other) != None)
			PlaySound(hitothersound, SLOT_None,,, 1024);
		else if (Pawn(Other) != None || Carcass(Other) != None)
			PlaySound(hitfleshsound, SLOT_None,,, 1024);
		else if (BreakableGlass(Other) != None)
			PlaySound(sound'GlassHit1', SLOT_None,,, 1024);
		else 
		{
			surfacetype = GetWallMaterial(Location, HitNormal);
			if (surfacetype  == 'Glass')
				PlaySound(sound'BulletProofHit', SLOT_None,,, 1024);
			else if (surfacetype == 'wood')
				PlaySound(hitwoodsound, SLOT_None,,, 1024);
			else if (surfacetype == 'metal')
				PlaySound(hitmetalsound, SLOT_None,,, 1024);
			else
				PlaySound(hitothersound, SLOT_None,,, 1024);
		}
	}
}

simulated function Tick(float deltaTime)
{
	local float dist, size;
	local Rotator dir;
	local vector TargetLocation; 
	local vector vel;
	local vector NormalHeading;
	local vector NormalDesiredHeading;
	local float HeadingDiffDot;
	local vector zerovec;
   
	Super.Tick(deltaTime);

	if (bTracking && (Target != None) && (Level.Netmode == NM_Standalone))
	{
		if (Target != None && Pawn(Target) != None)
		{
			if (!FastTrace(Target.Location, Location))
			{
				TargetLocation = Target.Location;
				TargetLocation.Z += Pawn(Target).BaseEyeHeight;
				LastSeenLoc = TargetLocation;
				dir = Rotator(TargetLocation - Location);
				dir.Roll = 0;

				if (Level.Netmode != NM_Standalone)
				{
					NormalHeading = Normal(Vector(Rotation));
					NormalDesiredHeading = Normal(TargetLocation - Location);
					HeadingDiffDot = NormalHeading Dot NormalDesiredHeading;
				}

				// set our new rotation
				bRotateToDesired = True;
				DesiredRotation = dir;

				// move us in the new direction that we are facing
				size = VSize(Velocity);
				vel = Normal(Vector(Rotation));

				if (Level.NetMode != NM_Standalone)
					size = FMax(HeadingDiffDot,0.4) * Speed;
				Velocity = vel * size;
			}
		}
	}
}


function name GetWallMaterial(vector HitLocation, vector HitNormal)
{
	local vector EndTrace, StartTrace;
	local actor target;
	local int texFlags;
	local name texName, texGroup;

	StartTrace = HitLocation + HitNormal*16;		// make sure we start far enough out
	EndTrace = HitLocation - HitNormal;

	foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, StartTrace, HitNormal, EndTrace)
		if ((target == Level) || target.IsA('Mover'))
			break;

	return texGroup;
}

auto simulated state Flying
{
	simulated function HitWall (vector HitNormal, actor HitWall)
	{
		// Destroy us if we hit a FakeBackdrop
		if (!bHitFakeBackdrop)
			CheckIfHitFakeBackDrop();
		
		if (bHitFakeBackdrop)
		{
			Destroy();
			return;
		}
	
		super.hitwall(hitnormal,hitwall);
		playhitwallsound(hitnormal, hitwall);
	}

	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if (bStuck)
			return;

		if ((Other != instigator) && (DeusExProjectile(Other) == None) &&
			(Other != Owner))
		{
			damagee = Other;
			Explode(HitLocation, Normal(HitLocation-damagee.Location));

		         // DEUS_EX AMSD Spawn blood server side only
		         if (Role == ROLE_Authority)
			{
		            if (damagee.IsA('scriptedPawn') && !damagee.IsA('Robot') && bBlood && scriptedpawn(damagee).bCanBleed)
		               SpawnBlood(HitLocation, Normal(HitLocation-damagee.Location));
			}
		}
	}
	
	
	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local bool bDestroy;
		local float rad;
		local inventory inv;
		local bool bFoundMinicrossbow;
		local Trestkon Player;

		// Reduce damage on nano exploded projectiles
		if ((bAggressiveExploded) && (Level.NetMode != NM_Standalone))
			Damage = Damage/6;

		bDestroy = false;
					
		Player = Trestkon(GetPlayerPawn());
		
		// any player's quad damage, not just the host's
		if (Trestkon(Owner) != None && Trestkon(Owner).bQuadDamage)
			damage *= 4;

		if (bExplodes)
		{
			if (Role == ROLE_Authority && Level.NetMode != NM_Standalone && tnmGameInfo(Level.Game) != None)
				tnmGameInfo(Level.Game).BroadcastCoopExplosionFX(HitLocation, blastRadius, damageType);

			//DEUS_EX AMSD Don't draw effects on dedicated server
			if ((Level.NetMode != NM_DedicatedServer) || (Role < ROLE_Authority))
			{
				if (Role < ROLE_Authority && Player != None)
					Player.RecordLocalCoopBlast(HitLocation);
				DrawExplosionEffects(HitLocation, HitNormal);
			}

			if (Role < ROLE_Authority && ImpactSound != None)
				PlaySound(ImpactSound, SLOT_None, 2.0,, FMax(blastRadius * 12.0, 1400.0));

			GotoState('Exploding');
		}
		else
		{
			// Server side only
			if ( Role == ROLE_Authority )
			{
				if ((damagee != None)/* && (Tracer(Self) == None)*/) // Don't even attempt damage with a tracer
				{
					if ( Level.NetMode != NM_Standalone )
					{
						if ( damagee.IsA('DeusExPlayer') )
							DeusExPlayer(damagee).myProjKiller = Self;
					}
					
					if (Pawn(Owner) != None)
					{
						if (Att_Pinpoint)
							damagee.TakeDamage(1, Pawn(Owner), HitLocation, MomentumTransfer*Normal(Velocity), 'headstun');
						damagee.TakeDamage(Damage, Pawn(Owner), HitLocation, MomentumTransfer*Normal(Velocity), damageType);
					}
					else
					{
						if (Att_Pinpoint)
							damagee.TakeDamage(1, None, HitLocation, MomentumTransfer*Normal(Velocity), 'headstun');
						damagee.TakeDamage(Damage, None, HitLocation, MomentumTransfer*Normal(Velocity), damageType);
					}
					
					// if (DamageType == 'Flamed' && RevPawnHook(damagee) != None)
						// RevPawnHook(damagee).BurnerWeapon = ownerWeapon;
					
					if (ScriptedPawn(damagee) != None && ScriptedPawn(damagee).Health <= 0 && Owner == Player)
					{
						if (Class.Name == 'FoonProj' && damagee.IsA('GenericLlama'))
							Trestkon(Owner).SetAchievement("achCultWeapon");
						else if (Class.Name == 'SporkProj' && damagee.IsA('GenericGoat'))
							Trestkon(Owner).SetAchievement("achCultWeapon");
					}
					
					if (DamageType == 'Flamed' && TNMPawn(damagee) != None)
						TNMPawn(damagee).BurnerWeapon = ownerWeapon;

					if (TNMPawn(damagee) != None && TNMPawn(damagee).Health <= 0 && !TNMPawn(damagee).bDeathCounted/* && !TNMPawn(damagee).bInsignificant*/)
					{
						NumKills++;
						if (ownerWeapon != None)
							ownerWeapon.NumKills++;
						// if (Trestkon(Owner) != None)
							// Trestkon(Owner).numKills++;
						// else if (TNMPawn(Owner) != None)
							// TNMPawn(Owner).numKills++;
						TNMPawn(damagee).bDeathCounted = True;
					}
				}
			}
			if (!bStuck)
				bDestroy = true;
		}

		rad = Max(blastRadius*24, 1024);

		// This needs to be outside the simulated call chain
		PlayImpactSound();

		//DEUS_EX AMSD Only do these server side
		if (Role == ROLE_Authority)
		{
			if (ImpactSound != None)
			{
				AISendEvent('LoudNoise', EAITYPE_Audio, 2.0, blastRadius*24);
				if (bExplodes)
				   AISendEvent('WeaponFire', EAITYPE_Audio, 2.0, blastRadius*5);
			}
		}
		
		if (bDestroy)
			Destroy();
	}
}

//G-Flex: edited to spawn crack type effects on movers
simulated function SpawnEffects(Vector HitLocation, Vector HitNormal, Actor Other)
{
	local incinerator fire;
	local vector loc;
		
	// Don't do anything if we hit a FakeBackdrop
	if (!bHitFakeBackdrop)
		CheckIfHitFakeBackDrop();
	
	if (bHitFakeBackdrop)
		return;
		
	Super.SpawnEffects(HitLocation, HitNormal, Other);
	
	if (Att_Incendiary)
	{
		loc = HitLocation + Hitnormal;
		fire = spawn(class'incinerator', ownerWeapon.Owner,, loc);
		if (fire != None)
		{
			fire.Velocity=vect(0,0,0);
			fire.Acceleration=vect(0,0,0);
			fire.DrawScale=FRand() * 0.5 + 2.0;
			fire.LifeSpan=FRand() * 10 + 30;
			if ( Level.NetMode !=NM_Standalone )
				fire.bFloating=False;
			else
				fire.bFloating=True;
			fire.Instigator=Instigator;
		}
	}
}

simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
	
	// Don't do anything if we hit a FakeBackdrop
	if (!bHitFakeBackdrop)
		CheckIfHitFakeBackDrop();
	
	if (bHitFakeBackdrop)
		return;
		
	Super.DrawExplosionEffects(HitLocation, HitNormal);
}



function CheckIfHitFakeBackDrop()
{	
	local vector StartTrace, EndTrace, HitLocation2, HitNormal2;
	local actor target;
	local int texFlags;
	local name texName, texGroup;
	
	StartTrace = Location;
	EndTrace = Location + 500 * vector(Rotation);
	if (IsA('TNMShuriken'))	// Shurikens rotate while in the air, so use their velocity instead. This might work for all classes, but the old method works so I don't want to risk it
		EndTrace = Location + 500 * Velocity;
	
	foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, HitLocation2, HitNormal2, EndTrace, StartTrace)
	{
		if ((target.DrawType == DT_None) || target.bHidden)
		{
			// do nothing - keep on tracing
		}
		else if ((target == Level) || target.IsA('Mover'))
		{
			break;
		}
		else
		{
			break;
		}
	}
	
	// 0x00000080 is the PF_FakeBackdrop flag from UnObj.h
	if ((texFlags & 0x00000080) != 0)
		bHitFakeBackdrop = True;
		
	return;
}

state Exploding
{
	ignores ProcessTouch, HitWall, Explode;

	function DamageRing()
	{
		local Pawn apawn;
		local float damageRadius;
		local Vector dist;
		local Human PlayerPawn;

		if ( Level.NetMode != NM_Standalone )
		{
			damageRadius = (blastRadius / gradualHurtSteps) * gradualHurtCounter;

			for ( apawn = Level.PawnList; apawn != None; apawn = apawn.nextPawn )
			{
				if ( apawn.IsA('DeusExPlayer') )
				{
					dist = apawn.Location - Location;
					if ( VSize(dist) < damageRadius )
					{
						if ( gradualHurtCounter <= 2 )
						{
							if ( apawn.FastTrace( apawn.Location, Location ))
								DeusExPlayer(apawn).myProjKiller = Self;
						}
						else
							DeusExPlayer(apawn).myProjKiller = Self;
					}
				}
			}
		}
		
		PlayerPawn = Human(GetPlayerPawn());
	  //DEUS_EX AMSD Ignore Line of Sight on the lowest radius check, only in multiplayer
		if (Att_Penetrative)
			TNMHurtRadius
			(
				(2 * Damage) / gradualHurtSteps,
				(blastRadius / gradualHurtSteps) * gradualHurtCounter,
				damageType,
				MomentumTransfer / gradualHurtSteps,
				Location,
				true
			);
		else
			TNMHurtRadius
			(
				(2 * Damage) / gradualHurtSteps,
				(blastRadius / gradualHurtSteps) * gradualHurtCounter,
				damageType,
				MomentumTransfer / gradualHurtSteps,
				Location,
				(((gradualHurtCounter <= 2) && (Level.NetMode != NM_Standalone)))
			);
			
		if (Att_Irritating)
			SpawnTearGas();
		else if (Att_Gaseous)
			SpawnPoisonGas();
	}

	simulated function Timer()
	{
		gradualHurtCounter++;
		if (Role == ROLE_Authority && gradualHurtCounter <= gradualHurtSteps)
			DamageRing();

		// In Co-op, keep the hidden exploding actor alive ~0.7s past HurtRadius so
		// actor-channel destruction does not beat replication at 250ms-500ms ping.
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


function SpawnTearGas()
{
	local Vector loc;
	local TearGas gas;
	local int i;

	if ( Role < ROLE_Authority )
		return;

	for (i=0; i<blastRadius/36/gradualHurtSteps; i++)
	{
		if (FRand() < 0.9)
		{
			loc = Location;
			loc.X += FRand() * blastRadius - blastRadius * 0.5;
			loc.Y += FRand() * blastRadius - blastRadius * 0.5;
			loc.Z += 32;
			gas = spawn(class'TearGas', None,, loc);
			if (gas != None)
			{
				gas.Velocity = vect(0,0,0);
				gas.Acceleration = vect(0,0,0);
				gas.DrawScale = FRand() * 0.5 + 2.0;
				gas.LifeSpan = FRand() * 10 + 30;
				if ( Level.NetMode != NM_Standalone )
					gas.bFloating = False;
				else
					gas.bFloating = True;
				gas.Instigator = Instigator;
			}
		}
	}
}


function SpawnPoisonGas()
{
	local Vector loc;
	local PoisonGas gas;
	local int i;

	if ( Role < ROLE_Authority )
		return;

	for (i=0; i<blastRadius/36/gradualHurtSteps; i++)
	{
		if (FRand() < 0.9)
		{
			loc = Location;
			loc.X += FRand() * blastRadius - blastRadius * 0.5;
			loc.Y += FRand() * blastRadius - blastRadius * 0.5;
			loc.Z += 32;
			gas = spawn(class'PoisonGas', None,, loc);
			if (gas != None)
			{
				gas.Velocity = vect(0,0,0);
				gas.Acceleration = vect(0,0,0);
				gas.DrawScale = FRand() * 0.5 + 2.0;
				gas.LifeSpan = FRand() * 10 + 30;
				if ( Level.NetMode != NM_Standalone )
					gas.bFloating = False;
				else
					gas.bFloating = True;
				gas.Instigator = Instigator;
			}
		}
	}
}

function TNMHurtRadius( float DamageAmount, float DamageRadius, name DamageName, float Momentum, vector HitLocation, optional bool bIgnoreLOS )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	// DEUS_EX CNN
	local Mover M;
	local Trestkon Player;
	
	local int challengeCount;
	local string challengeString;
	
	if( bHurtEntry )
		return;

	bHurtEntry = true;
	Player = Trestkon(GetPlayerPawn());
	if (!bIgnoreLOS)
	{
		foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
		{
			if( Victims != self )
			{
				dir = Victims.Location - HitLocation;
				dist = FMax(1,VSize(dir));
				dir = dir/dist; 
				damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
				if ((Att_Lamar || Att_Narcissian) && (Victims.IsA('GenericGoat') || Victims.IsA('Athena') || Victims.IsA('DarkTemplar')) )
					damageScale += 1;
				if ((Att_00n || Att_Narcissian) && (Victims.IsA('GenericLlama') || Victims.IsA('Beefman') || Victims.IsA('Abomnation') || Victims.IsA('SD')) ) // skip Hobbes
					damageScale += 1;
				if ((Att_Hunter) && (Victims.IsA('TNMGreasel') || Victims.IsA('RedGreasel') || Victims.IsA('TNMKarkian') || Victims.IsA('TNMGray')) ) // skip SD
					damageScale += 1;
				if ((Att_Technophobic) && (Victims.IsA('Robot')) )
					damageScale += 1;
				if ((Att_LowTech) && (TNMPawn(Victims) != None && TNMPawn(Victims).bAugmented) )
					damageScale += 1;
				if (OwnerWeapon != None && (Att_Junkie) && DeusExPlayer(OwnerWeapon.Owner) != None && DeusExPlayer(OwnerWeapon.Owner).DrugEffectTimer > 0 )
					damageScale += 1;
				
				if (Att_Quaking && Victims == Owner)
				{
					Victims.TakeDamage
					(
						0,
						Instigator, 
						Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
						(damageScale * Momentum * dir),
						'RocketJump'
					);
				}
				else
				{
					Victims.TakeDamage
					(
						damageScale * DamageAmount,
						Instigator, 
						Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
						(damageScale * Momentum * dir),
						DamageName
					);
				}
				
				if (Att_Immolative)
				{
					Victims.TakeDamage
					(
						1,
						Instigator, 
						Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
						(damageScale * Momentum * dir),
						'Flamed'
					);
				}
				else if (Att_Embiggening)
				{
					Victims.TakeDamage
					(
						damageScale * DamageAmount,
						Instigator, 
						Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
						(damageScale * Momentum * dir),
						'Fat'
					);
				}
				else if (Att_Phreaking && Victims != None && Victims.IsA('HackableDevices'))
				{
					Victims.TakeDamage(
						damageScale * DamageAmount,
						Instigator, 
						Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
						(damageScale * Momentum * dir),
						'EMP'
					);
				}
			
				if (Victims != None && Victims.IsA('ScriptedPawn'))
				{
					if (ScriptedPawn(Victims).Health <= 0)
					{
						if (Att_Messy)
							ScriptedPawn(Victims).Health = -200;
					}
					
					if (DamageType == 'Flamed' && TNMPawn(Victims) != None)
						TNMPawn(Victims).BurnerWeapon = ownerWeapon;

					if (TNMPawn(Victims) != None && TNMPawn(Victims).Health <= 0 && !TNMPawn(Victims).bDeathCounted/* && !TNMPawn(Victims).bInsignificant*/)
					{
						NumKills++;
						if (ownerWeapon != None)
							ownerWeapon.NumKills++;
						// if (Trestkon(Owner) != None)
							// Trestkon(Owner).numKills++;
						// else if (TNMPawn(Owner) != None)
							// TNMPawn(Owner).numKills++;
						TNMPawn(Victims).bDeathCounted = True;
					}
				}
			}
		}
	}
	else
	{
		foreach RadiusActors(class 'Actor', Victims, DamageRadius, HitLocation )
		{
			if( Victims != self )
			{
				dir = Victims.Location - HitLocation;
				dist = FMax(1,VSize(dir));
				dir = dir/dist; 
				damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
				Victims.TakeDamage
				(
					damageScale * DamageAmount,
					Instigator, 
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					(damageScale * Momentum * dir),
					DamageName
				);
			
				if (Victims != None && Victims.IsA('ScriptedPawn'))
				{
					if (ScriptedPawn(Victims).Health <= 0)
					{
						if (Att_Messy)
							ScriptedPawn(Victims).Health = -200;
					}
					
					if (DamageType == 'Flamed' && TNMPawn(Victims) != None && ownerWeapon != None)
						TNMPawn(Victims).BurnerWeapon = ownerWeapon;

					if (TNMPawn(Victims) != None && TNMPawn(Victims).Health <= 0 && !TNMPawn(Victims).bDeathCounted/* && !TNMPawn(Victims).bInsignificant*/)
					{
						NumKills++;
						if (ownerWeapon != None)
							ownerWeapon.NumKills++;
						// if (Trestkon(Owner) != None)
							// Trestkon(Owner).numKills++;
						// else if (TNMPawn(Owner) != None)
							// TNMPawn(Owner).numKills++;
						TNMPawn(Victims).bDeathCounted = True;
					}
				}
			} 
		}
	}

	//
	// DEUS_EX - CNN - damage the movers, also
	//
	foreach RadiusActors(class 'Mover', M, DamageRadius, HitLocation)
	{
		if( M != self )
		{
			dir = M.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist; 
			damageScale = 1 - FMax(0,(dist - M.CollisionRadius)/DamageRadius);
			M.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator, 
				M.Location - 0.5 * (M.CollisionHeight + M.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageName
			);
		} 
	}

	bHurtEntry = false;
}

defaultproperties
{
}

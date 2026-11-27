//=============================================================================
// AutoTurret.
//
// A fake turret to be spawned by a grenade
//=============================================================================
class tnmFakeLaserAutoTurret extends tnmLaserAutoTurret;

function Fire()
{
	local Vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z, loc;
	local Rotator rot;
	local Actor hit;
	local ShellCasing shell;
	local Spark spark;
	local Pawn attacker;

	if (!gun.IsAnimating())
		gun.LoopAnim('Fire');

	// CNN - give turrets infinite ammo
//	if (ammoAmount > 0)
//	{
//		ammoAmount--;
		GetAxes(gun.Rotation, X, Y, Z);
		StartTrace = gun.Location;
		EndTrace = StartTrace + gunAccuracy * (FRand()-0.5)*Y*1000 + gunAccuracy * (FRand()-0.5)*Z*1000 ;
		EndTrace += 10000 * X;
		hit = Trace(HitLocation, HitNormal, EndTrace, StartTrace, True);
		
		MakeNoise(1.0);
		PlaySound(sound'TNM.Weapons.FakeTurret', SLOT_None, 2.0,,maxRange,0.75);
		AISendEvent('LoudNoise', EAITYPE_Audio);

		// muzzle flash
		gun.LightType = LT_Steady;
		SetTimer(0.1, False);
	
		if (emitter != None)
			emitter.destroy();
		loc = gun.Location;
		loc.Z += 2.5;
		loc.Z += -5.0; // ceiling
		emitter = Spawn(class'TracerEmitter', Self,,loc,gun.Rotation);
		if (emitter != None)
		{
			zapTimer = laserDuration;
			emitter.SetLocation(loc);
			emitter.SetRotation(gun.Rotation);
			emitter.SetBlueBeam();
			emitter.TurnOn();
			emitter.SetBase(Owner);
			emitter.AmbientSound = None;
			// emitter.Proxy.Drawscale = LaserDrawscale;
		}

		if (hit != None)
		{
			// spawn a little spark and make a ricochet sound if we hit something
			spark = spawn(class'Spark',,,HitLocation+HitNormal, Rotator(HitNormal));

			if (spark != None)
			{
				spark.DrawScale = 0.05;
				PlayHitSound(spark, hit);
			}

			attacker = None;
			if ((curTarget == hit) && !curTarget.IsA('PlayerPawn'))
				attacker = GetPlayerPawn();
			if (Level.NetMode != NM_Standalone)
				attacker = safetarget;
			if ( hit.IsA('DeusExPlayer') && ( Level.NetMode != NM_Standalone ))
				DeusExPlayer(hit).myTurretKiller = Self;
			// hit.TakeDamage(gunDamage, attacker, HitLocation, 1000.0*X, 'AutoShot');
			hit.TakeDamage(gunDamage, attacker, HitLocation, 1000.0*X, 'Burned');

			if (hit.IsA('Pawn') && !hit.IsA('Robot'))
				SpawnBlood(HitLocation, HitNormal);
			else if ((hit == Level) || hit.IsA('Mover'))
				SpawnEffects(HitLocation, HitNormal, hit);
		}
//	}
//	else
//	{
//		PlaySound(sound'DryFire', SLOT_None);
//	}
}

function PreBeginPlay()
{
	local Vector v1, v2;
	local class<AutoTurretGun> gunClass;
	local Rotator rot;

	Super(DeusExDecoration).PreBeginPlay();

	gunClass = class'tnmFakeLaserAutoTurretGun';

	rot = Rotation;
	rot.Pitch = 0;
	rot.Roll = 0;
	origRot = rot;
	if (!bDeleteMe)
		gun = Spawn(gunClass, Self,, Location, rot);
	if (gun != None)
	{
		v1.X = 0;
		v1.Y = 0;
		v1.Z = CollisionHeight + gun.Default.CollisionHeight;
		v2 = v1 >> Rotation;
		v2 += Location;
		gun.SetLocation(v2);
		gun.SetBase(Self);
	}

	// set up the alarm listeners
	AISetEventCallback('Alarm', 'AlarmHeard');

	if ( Level.NetMode != NM_Standalone )
	{
		maxRange = mpTurretRange;
		gunDamage = mpTurretDamage;
		bInvincible = True;
		bDisabled = !bActive;
	}
}


function Tick(float deltaTime)
{
	local Pawn pawn;
	local ScriptedPawn sp;
	local DeusExDecoration deco;
	local float near;
	local Rotator destRot;
	local bool bSwitched;
	local Human aplayer;

	Super(DeusExDecoration).Tick(deltaTime);

	bSwitched = False;

	if ( bSwitching )
	{
		UpdateSwitch();
		return;
	}

	// Make sure everything is valid and account for when players leave or switch teams
	if ( !bDisabled && (Level.NetMode != NM_Standalone) )
	{
		if ( safeTarget == None )
		{
			bDisabled = True;
			bComputerReset = False;
		}
		else
		{
			if ( DeusExPlayer(safeTarget) != None )
			{
				if ((TeamDMGame(DeusExPlayer(safeTarget).DXGame) != None) && (DeusExPlayer(safeTarget).PlayerReplicationInfo.team != team))
					bSwitched = True;
				else if ((DeathMatchGame(DeusExPlayer(safeTarget).DXGame) != None ) && (DeusExPlayer(safeTarget).PlayerReplicationInfo.PlayerID != team))
					bSwitched = True;
				
				if ( bSwitched )
				{
					bDisabled = True;
					safeTarget = None;
					bComputerReset = False;
				}
			}
		}
	}
	if ( bDisabled && (Level.NetMode != NM_Standalone) )
	{
		team = -1;
		safeTarget = None;
		if ( !bComputerReset )
		{
			gun.ResetComputerAlignment();
			bComputerReset = True;
		}
	}

	if (bConfused)
		bConfused = False;
	if (bConfused)
	{
		confusionTimer += deltaTime;

		// pick a random facing
		if (confusionTimer % 0.25 > 0.2)
		{
			gun.DesiredRotation.Pitch = origRot.Pitch + (pitchLimit / 2 - Rand(pitchLimit));
			gun.DesiredRotation.Yaw = Rand(32767) + Rand(32767); // Rand is limited to 2^15
		}
		if (confusionTimer > confusionDuration)
		{
			bConfused = False;
			confusionTimer = 0;
			confusionDuration = Default.confusionDuration;
		}
	}

	if (bActive && !bDisabled)
	{
		curTarget = None;

		if ( !bConfused )
		{
			// if we've been EMP'ed, act confused
			if ((Level.NetMode != NM_Standalone) && (Role == ROLE_Authority))
			{
				// DEUS_EX AMSD If in multiplayer, get the multiplayer target.

				if (TargetRefreshTime < 0)
					TargetRefreshTime = 0;
         
				TargetRefreshTime = TargetRefreshTime + deltaTime;

				if (TargetRefreshTime >= 0.3)
				{
					TargetRefreshTime = 0;
					curTarget = AcquireMultiplayerTarget();
					if (( curTarget != prevTarget ) && ( curTarget == None ))
							PlaySound(Sound'TurretUnlocked', SLOT_Interact, 1.0,, maxRange );
					prevtarget = curtarget;
				}
				else
				{
					curTarget = prevtarget;
				}
			}
			else
			{
				//
				// Logic table for turrets
				//
				// bTrackPlayersOnly		bTrackPawnsOnly		Should Attack
				// 			T						X				Allies
				//			F						T				Enemies
				//			F						F				Everything
				//
         
				// Attack allies and neutrals
				if (bTrackPlayersOnly || (!bTrackPlayersOnly && !bTrackPawnsOnly))
				{
					foreach gun.VisibleActors(class'Pawn', pawn, maxRange, gun.Location)
					{
						if (pawn.bDetectable && !pawn.bIgnore)
						{
							aplayer = Human(pawn);
							
							// If the player's RadarTrans aug is off, the turret can see him
							if (aplayer != None/* && !aplayer.bRadarCloaked*/)
							{
								curTarget = pawn;
								break;
							}
							else if (pawn.IsA('ScriptedPawn') && (ScriptedPawn(pawn).GetPawnAllianceType(GetPlayerPawn()) != ALLIANCE_Hostile) && (pawn.Mass > 2)) // Exclude rats, flies, fish, etc
							{
								curTarget = pawn;
								break;
							}
						}
					}
				}
         
				if (!bTrackPlayersOnly)
				{
					// Attack everything
					if (!bTrackPawnsOnly)
					{
						foreach gun.VisibleActors(class'DeusExDecoration', deco, maxRange, gun.Location)
						{
							if (!deco.IsA('ElectronicDevices') && !deco.IsA('AutoTurret') &&
								!deco.bInvincible && deco.bDetectable && !deco.bIgnore)
							{
								curTarget = deco;
								break;
							}
						}
					}
            
					// Attack enemies
					foreach gun.VisibleActors(class'ScriptedPawn', sp, maxRange, gun.Location)
					{
						if (sp.bDetectable && !sp.bIgnore && (sp.GetPawnAllianceType(GetPlayerPawn()) == ALLIANCE_Hostile))
						{
							curTarget = sp;
							break;
						}
					}
				}
			}

			// if we have a target, rotate to face it
			if (curTarget != None)
			{
				destRot = Rotator(curTarget.Location - gun.Location);
				gun.DesiredRotation = destRot;
				near = pitchLimit / 2;
				gun.DesiredRotation.Pitch = FClamp(gun.DesiredRotation.Pitch, origRot.Pitch - near, origRot.Pitch + near);
			}
			// else
				// gun.DesiredRotation = origRot;
		}
	}
	else
	{
		// if ( !bConfused )
			// gun.DesiredRotation = origRot;
	}

	near = (Abs(gun.Rotation.Pitch - gun.DesiredRotation.Pitch)) % 65536;
	near += (Abs(gun.Rotation.Yaw - gun.DesiredRotation.Yaw)) % 65536;

	if (bActive && !bDisabled)
	{
		// play an alert sound and light up
		// if ((curTarget != None) && (curTarget != LastTarget))
			// PlaySound(Sound'Beep6',,,, 1280);

		// if we're aiming close enough to our target
		if (curTarget != None)
		{
			gun.MultiSkins[1] = Texture'RedLightTex';
			// if ((near < 4096) && (((Abs(gun.Rotation.Pitch - destRot.Pitch)) % 65536) < 8192))
			// {
				if (fireTimer > fireRate)
				{
					Fire();
					fireTimer = 0;
				}
			// }
		}
		else
		{
			if (gun.IsAnimating())
				gun.PlayAnim('Still', 10.0, 0.001);

			if (bConfused)
				gun.MultiSkins[1] = Texture'YellowLightTex';
			else
				gun.MultiSkins[1] = Texture'GreenLightTex';
		}

		fireTimer += deltaTime;
		LastTarget = curTarget;
	}
	else
	{
		if (gun.IsAnimating())
			gun.PlayAnim('Still', 10.0, 0.001);
		gun.MultiSkins[1] = None;
	}

	// make noise if we're still moving
	if (near > 64)
	{
		// gun.AmbientSound = Sound'AutoTurretMove';
		if (bConfused)
			gun.SoundPitch = 128;
		else
			gun.SoundPitch = 64;
	}
	else
		gun.AmbientSound = None;
		
	if (Lifespan <= 4)
		ScaleGlow=LifeSpan/4;
}


auto state Active
{
	function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
	{		
		if ((DamageType == 'EMP')/* && (DemoLevel > -0.50)*/)
		{
			return;
		}

		Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
	}
}

defaultproperties
{
     maxRange=2048
     fireRate=2.500000
     gunAccuracy=0.000000
     gunDamage=24
     pitchLimit=65536.000000
     bInvincible=True
     LifeSpan=11.000000
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=FireTexture'TNM_Core_Tex.Effects.IrradiatorTurret'
     DrawScale=0.500000
     AmbientSound=Sound'TNMSounds.Ambient.GoatPortal'
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}

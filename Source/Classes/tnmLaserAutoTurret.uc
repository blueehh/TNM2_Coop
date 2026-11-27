//=============================================================================
// AutoTurret.
//=============================================================================
class tnmLaserAutoTurret extends AutoTurret;

var float zapTimer;
var() float laserDuration;
var() float laserDrawscale;
var LaserEmitter emitter;

// turn off the muzzle flash
simulated function Timer()
{
	gun.LightType = LT_None;
	gun.MultiSkins[2] = None;
	gun.MultiSkins[3] = None;
}
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
		PlaySound(sound'TNM.Weapons.LaserFire', SLOT_None, 2.0);
		AISendEvent('LoudNoise', EAITYPE_Audio);

		// muzzle flash
		gun.LightType = LT_Steady;
		SetTimer(0.1, False);
	
		if (emitter != None)
			emitter.destroy();
		loc = gun.Location;
		loc.Z += 2.5;
		loc.Z += -5.0; // ceiling
		emitter = Spawn(class'LaserEmitter', Self,,loc,gun.Rotation);
		if (emitter != None)
		{
			zapTimer = laserDuration;
			emitter.SetLocation(loc);
			emitter.SetRotation(gun.Rotation);
			emitter.SetBlueBeam();
			emitter.TurnOn();
			emitter.SetBase(Owner);
			emitter.AmbientSound = None;
			emitter.Proxy.Drawscale = LaserDrawscale;
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

function PlayHitSound(actor destActor, Actor hitActor)
{/*
	local float rnd;
	local sound snd;

	rnd = FRand();

	if (rnd < 0.25)
		snd = sound'Ricochet1';
	else if (rnd < 0.5)
		snd = sound'Ricochet2';
	else if (rnd < 0.75)
		snd = sound'Ricochet3';
	else
		snd = sound'Ricochet4';

	// play a different ricochet sound if the object isn't damaged by normal bullets
	if (hitActor != None) 
	{
		if (hitActor.IsA('DeusExDecoration') && (DeusExDecoration(hitActor).minDamageThreshold > 10))
			snd = sound'ArmorRicochet';
		else if (hitActor.IsA('Robot'))
			snd = sound'ArmorRicochet';
	}

	if (destActor != None)
		destActor.PlaySound(snd, SLOT_None,,, 1024, 1.1 - 0.2*FRand());*/
}

function PreBeginPlay()
{
	local Vector v1, v2;
	local class<AutoTurretGun> gunClass;
	local Rotator rot;

	Super(DeusExDecoration).PreBeginPlay();

	gunClass = class'tnmLaserAutoTurretGun';

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

simulated function texture GetMuzzleTex()
{	
	return None;
}


function Tick(float deltaTime)
{
	Super.Tick(deltaTime);
	
	if (zapTimer > 0)
	{
		zapTimer -= deltaTime;

		// update the rotation of the emitter
		if (emitter != None)
			emitter.SetRotation(gun.Rotation);

		// turn off the electricity after the timer has expired
	}

	if (zapTimer <= 0)
	{
		zapTimer = 0;
		if (emitter != none)
			emitter.TurnOff();
	}
}

simulated function SpawnEffects(Vector HitLocation, Vector HitNormal, Actor Other)
{
	local SmokeTrail puff;
	local int i;
	local BulletHole hole;
	local Rotator rot;

   if (FRand() < 0.5)
	{
		puff = spawn(class'SmokeTrail',,,HitLocation+HitNormal, Rotator(HitNormal));
		if (puff != None)
		{
			puff.DrawScale *= 0.3;
			puff.OrigScale = puff.DrawScale;
			puff.LifeSpan = 0.25;
			puff.OrigLifeSpan = puff.LifeSpan;
		}
	}/*

	if (!Other.IsA('BreakableGlass'))
		for (i=0; i<2; i++)
			if (FRand() < 0.8)
				spawn(class'Rockchip',,,HitLocation+HitNormal);

	hole = spawn(class'BulletHole', Other,, HitLocation, Rotator(HitNormal));

	// should we crack glass?
	if (GetWallMaterial(HitLocation, HitNormal) == 'Glass')
	{
		if(Mesh != Default.Mesh)
		{
			hole.Texture = HoleTex;
			hole.DrawScale = 0.00625;
			hole.drawscale *= 1.0 + frand()*0.2;
		}
		else
		{
			if (FRand() < 0.5)
				hole.Texture = Texture'FlatFXTex29';
			else
				hole.Texture = Texture'FlatFXTex30';

			hole.DrawScale = 0.1;
		}
		hole.ReattachDecal();
	}*/
}

function Destroyed()
{	
	if (emitter != None)
		emitter.destroy();
	Super.Destroyed();
}

defaultproperties
{
     laserDuration=0.200000
     laserDrawscale=1.000000
     gunAccuracy=1.000000
     Skin=Texture'TNM.Skins.LaserAutoTurretBaseTex1'
     bCollideActors=False
     bCollideWorld=False
}

//=============================================================================
// NapalmGlop
//=============================================================================
class LavaBubble extends tnmProjectile;

#exec OBJ LOAD FILE=Effects

var vector SurfaceNormal;
var sound impactsound, miscsound, cracklesound;
var bool bOnGround; //don't know if we need this anymore...
var bool bCheckedSurface;
var bool bSpewing;
var bool bIgnited;
var bool bBlinking;
var bool bUnderwater;
var bool bExploded;
var bool bOnThing;
var int numBlobs;
var float fuselength;
var int fuseseconds;
var float wallTime;
var float BaseOffset;
var mesh randmesh[3];
var Particlegenerator fusegen, firegen;

function PreBeginPlay()
{
    Mesh=randmesh[rand(3)];
    Super(DeusExProjectile).PreBeginPlay();
}

function PostBeginPlay()
{
	LightType=LT_None;
	Style=Sty_Translucent;
	WatchYourDrawScale();
	Damage *= NumBlobs;
	time= 0.00;
	fuseSeconds=FuseLength;
	Super(DeusExProjectile).PostbeginPlay();
}

function timer()
{
	Super(DeusExProjectile).Timer();
}

simulated function Tick(float deltaTime)
{
	local float blinkRate;

	time += deltatime;

	Super(DeusExProjectile).Tick(deltaTime);

	fuseSeconds=fuseLength;
	fuseLength=fuseLength - deltaTime;
	// if ((fuseLength <= 0.0) && !bExploded)
	// {
		// Explode(Location, vector(rotation));
		// bExploded=true;
	// }

	// do stuff as the time expires
	if ((fuseLength - time <=  0.1) && !bIgnited)
	{
		LightType=LT_Steady;
		bUnlit=true;
		blinkrate = 0.1;
		if(fuseGen != none)
		{
			fusegen.particleDrawScale = 0.2;
			fusegen.checkTime = 0.05;
			fusegen.ejectSpeed = 50.0;
			fusegen.bAmbientSound = true;
			fuseGen.AmbientSound = cracklesound;
		}
	   firegen = spawn(Class'ParticleGenerator',Self,,Location + SurfaceNormal*1.5);
	   if(firegen != none)
		{
			fireGen.RemoteRole = ROLE_None;
			fireGen.particleTexture = Texture'Effects.Fire.Fireball1';
			fireGen.particleDrawScale = 0.1;
			fireGen.checkTime = 0.01;
			fireGen.riseRate = 0.0;
			fireGen.ejectSpeed = 1.0;
			fireGen.particleLifeSpan = 0.1;
			fireGen.bRandomEject = True;
			fireGen.SetBase(Self);
		}
		bIgnited=true;
		bBlinking=true;
		//Multiskins[0]=Texture'Effects.Fire.OnFire_J';
	}
	else if ((fuseLength - time <= default.fuseLength * 0.75) && !bSpewing)
	{
		LightType=LT_Flicker;
		SpawnNapalmEffects();
	}
	else
	{
		LightType=LT_None;
		Style=Sty_Translucent;
	}

	if ((Level.NetMode == NM_Standalone) || (Role < ROLE_Authority) || (Level.NetMode == NM_ListenServer))
	{
		if(bBlinking)
		{
			if (Abs((fuseLength - time)) % blinkRate > blinkRate * 0.5)
				ScaleGlow = 1.00;
			else
				ScaleGlow = 3.00;
		}
	}
}

function WatchYourDrawScale()
{
	Drawscale=(numBlobs+3)*0.1;
}

function SpawnNapalmEffects()
{
	if(bUnderwater) //don't smoke underwater
		return;

	fuseGen = Spawn(class'ParticleGenerator', Self,,Location + SurfaceNormal*2);
	if (fuseGen != None)
	{
		fuseGen.particleTexture = Texture'Effects.Smoke.SmokePuff1';
		fuseGen.particleDrawScale = 0.1;
		fuseGen.checkTime = 0.1;
		fuseGen.riseRate = 20.0;
		fuseGen.ejectSpeed = 20.0;
		fuseGen.particleLifeSpan = 2.0;
		fuseGen.bRandomEject = True;
		fuseGen.SetBase(Self);
		fuseGen.RemoteRole = ROLE_None;
		bSpewing=true;
	}
}

function ExtinguishSmoke()
{
	if(fuseGen != none)
		fuseGen.DelayedDestroy();
	if(fireGen != none)
		firegen.DelayedDestroy();
}

simulated function Destroyed()
{
	if (fuseGen != None)
		fuseGen.DelayedDestroy();
	if(fireGen != none)
		firegen.DelayedDestroy();

	Super(DeusExProjectile).Destroyed();
}

function drawexplosioneffects(vector HitLocation, vector HitNormal)
{
}

state OnSurface
{
	function ProcessTouch (Actor Other, vector HitLocation)
	{
		fuselength=fuselength*0.25; //if you brush up against it, better start running...
	}

	simulated function CheckSurface()
	{

	}
}

singular function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, vector momentum, name damageType )
{
}


simulated function SetWall(vector HitNormal, Actor Wall)
{
	local vector TraceNorm, TraceLoc, Extent;
	local actor HitActor;
	local rotator RandRot;

	SurfaceNormal = HitNormal;
	RandRot = rotator(HitNormal);
	RandRot.Roll = Frand()*65536;
    RandRot.Yaw = Frand()*65536;
    RandRot.Pitch = Frand()*65536;
	SetRotation(RandRot);
	if ( Mover(Wall) != None )
		SetBase(Wall);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	// if(base != none)
		// SpawnEffects(HitLocation, HitNormal, Base);
	// else
		// SpawnEffects(HitLocation, HitNormal, None);

	// DrawExplosionEffects(HitLocation, HitNormal);

	// PlayImpactSound();

	// AISendEvent('LoudNoise', EAITYPE_Audio, 2.0, blastRadius*16);

	GotoState('Exploding');
}
//
// Exploding state
//
state Exploding
{
	ignores ProcessTouch, HitWall, Explode;

	function DamageRing()
	{
	}

	function Timer()
	{
		Destroy();
	}

Begin:
	Destroy();
}

auto state Flying
{
	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		SpawnEffects(HitLocation, HitNormal, None);
		DrawExplosionEffects(HitLocation, HitNormal);

		PlayImpactSound();

		AISendEvent('LoudNoise', EAITYPE_Audio, 2.0, blastRadius*16);

		GotoState('Exploding');
	}

	function ProcessTouch (Actor Other, vector HitLocation)
	{
		Destroy();
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		Destroy();
	}

	simulated function ZoneChange( Zoneinfo NewZone )
	{
		local waterring w;

		if (NewZone.bWaterZone) 
			Destroy();
	}
	simulated function BeginState()
	{
	}
}

defaultproperties
{
     ImpactSound=Sound'DeusExSounds.Player.BodyHit'
     MiscSound=Sound'DeusExSounds.Weapons.GasGrenadeExplode'
     numBlobs=7
     fuseLength=4.000000
     randmesh(0)=LodMesh'DeusExItems.FleshFragment1'
     randmesh(1)=LodMesh'DeusExItems.FleshFragment2'
     randmesh(2)=LodMesh'DeusExItems.FleshFragment3'
     bExplodes=True
     DamageType=Flamed
     bIgnoresNanoDefense=True
     speed=800.000000
     MaxSpeed=1500.000000
     MomentumTransfer=20000
     bCanTeleport=True
     LifeSpan=12.000000
     Skin=WaveTexture'TNM_Core_Tex.Effects.LiquidHotMagma'
     Mesh=LodMesh'DeusExItems.FleshFragment1'
     CollisionRadius=2.000000
     CollisionHeight=2.000000
     bProjTarget=True
     LightType=LT_Steady
     LightEffect=LE_FireWaver
     LightBrightness=70
     LightHue=32
     LightSaturation=100
     LightRadius=3
     bBounce=True
     Buoyancy=170.000000
}

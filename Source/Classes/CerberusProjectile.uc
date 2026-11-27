//=============================================================================
// CerberusProjectile.
//=============================================================================
class CerberusProjectile extends TNMProjectile;

var ParticleGenerator smokeGen;

function PostBeginPlay()
{
	Super.PostBeginPlay();

   if (Level.NetMode == NM_DedicatedServer)
      return;
   
   SpawnSmokeEffects();
}

simulated function PostNetBeginPlay()
{
   Super.PostNetBeginPlay();
   
   if (Role != ROLE_Authority)
      SpawnSmokeEffects();
}

simulated function SpawnSmokeEffects()
{
	smokeGen = Spawn(class'ParticleGenerator', Self);
	if (smokeGen != None)
	{
		smokeGen.particleTexture = Texture'Effects.Smoke.SmokePuff1';
		smokeGen.particleDrawScale = 0.3;
		smokeGen.checkTime = 0.02;
		smokeGen.riseRate = 8.0;
		smokeGen.ejectSpeed = 0.0;
		smokeGen.particleLifeSpan = 2.0;
		smokeGen.bRandomEject = True;
		smokeGen.SetBase(Self);
		smokeGen.RemoteRole = ROLE_None;
	}
}

simulated function Destroyed()
{
	if (smokeGen != None)
		smokeGen.DelayedDestroy();

	Super.Destroyed();
}

simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
	local ShockRing ring;
	local SphereEffect sphere;
	local ExplosionLight light;
	local AnimatedSprite expeffect;
		
	// Don't do anything if we hit a FakeBackdrop
	// if (!bHitFakeBackdrop)
		// CheckIfHitFakeBackDrop();
	
	// if (bHitFakeBackdrop)
		// return;

	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, HitLocation);
	if (light != None)
		light.RemoteRole = ROLE_None;

	if (blastRadius < 128)
	{
		expeffect = Spawn(class'ExplosionSmall',,, HitLocation);
		light.size = 2;
	}
	else if (blastRadius < 256)
	{
		expeffect = Spawn(class'ExplosionMedium',,, HitLocation);
		light.size = 4;
	}
	else
	{
		expeffect = Spawn(class'ExplosionLarge',,, HitLocation);
		light.size = 8;
	}

	if (expeffect != None)
	{
		expeffect.RemoteRole = ROLE_None;
		expeffect.Texture = Texture'FlatFXTex37';
	}

	// draw a pretty shock ring
	// For nano defense we are doing something else.
	if ((!bAggressiveExploded) || (Level.NetMode == NM_Standalone))
	{
		ring = Spawn(class'ShockRing',,, HitLocation, rot(16384,0,0));
		if (ring != None)
		{
			ring.RemoteRole = ROLE_None;
			ring.size = blastRadius / 32.0;
			ring.Skin = Texture'RedLightTex';
		}
		ring = Spawn(class'ShockRing',,, HitLocation, rot(0,0,0));
		if (ring != None)
		{
			ring.RemoteRole = ROLE_None;
			ring.size = blastRadius / 32.0;
			ring.Skin = Texture'RedLightTex';
		}
		ring = Spawn(class'ShockRing',,, HitLocation, rot(0,16384,0));
		if (ring != None)
		{
			ring.RemoteRole = ROLE_None;
			ring.size = blastRadius / 32.0;
			ring.Skin = Texture'RedLightTex';
		}
	}
	else
	{
		sphere = Spawn(class'SphereEffect',,, HitLocation, rot(16384,0,0));
		if (sphere != None)
		{
			sphere.RemoteRole = ROLE_None;
			sphere.size = blastRadius / 32.0;
			sphere.Skin = Texture'RedLightTex';
		}
		sphere = Spawn(class'SphereEffect',,, HitLocation, rot(0,0,0));
		if (sphere != None)
		{
			sphere.RemoteRole = ROLE_None;
			sphere.size = blastRadius / 32.0;
			sphere.Skin = Texture'RedLightTex';
		}
		sphere = Spawn(class'SphereEffect',,, HitLocation, rot(0,16384,0));
		if (sphere != None)
		{
			sphere.RemoteRole = ROLE_None;
			sphere.size = blastRadius / 32.0;
			sphere.Skin = Texture'RedLightTex';
		}
	}
}

defaultproperties
{
     bExplodes=True
     bBlood=True
     bDebris=True
     blastRadius=512.000000
     DamageType=exploded
     maxRange=800
     ItemName="HE 20mm Shell"
     ItemArticle="a"
     speed=1000.000000
     MaxSpeed=1000.000000
     Damage=150.000000
     MomentumTransfer=40000
     SpawnSound=Sound'DeusExSounds.Weapons.AssaultGunFire20mm'
     ImpactSound=Sound'DeusExSounds.Weapons.PlasmaRifleHit'
     ExplosionDecal=Class'DeusEx.ScorchMark'
     Skin=Texture'DeusExDeco.Skins.AlarmLightTex3'
     Mesh=LodMesh'DeusExItems.PlasmaBolt'
     DrawScale=3.000000
}

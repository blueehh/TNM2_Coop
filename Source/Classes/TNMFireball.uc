//=============================================================================
// Fireball.
// Smoke39 - new, fancier flamer projectile
//=============================================================================
class TNMFireball extends TNMProjectile;

var TNMFireballSmoke smoke;
var bool bSpawnedInWater;

#exec OBJ LOAD FILE=Effects

simulated function Tick(float deltaTime)
{
	DrawScale += deltaTime*4;
	SetCollisionSize( DrawScale*12, DrawScale*12 );
	LightRadius = Clamp(6 * (1 - DrawScale * 0.5), 0, 6);
	// LightRadius is a byte and I worry that it underflows
	if (LightRadius > 6)
		LightRadius = 0;

	if ( LifeSpan <= 0.2 )
	{
		ScaleGlow = LifeSpan * 5;
		DrawScale += deltaTime;
		Velocity.Z += 50*deltaTime;
		if ( smoke != None )
		{
			smoke.Velocity = Velocity / 1.5;
			smoke.LifeSpan = 0.75 + FRand()*0.75;
			smoke.origLifeSpan = smoke.LifeSpan;
			smoke.bRelinquished = true;
			smoke = None;
		}
	}
	else
	{
		if ( smoke == None )
			smoke = Spawn( class'TNMFireballSmoke' );

		smoke.setLocation( Location - vect(0,0,0.7)*CollisionHeight );
		smoke.LifeSpan = 3;
		smoke.ScaleGlow = Default.LifeSpan - LifeSpan;
		smoke.DrawScale = 1.5 * DrawScale;
	}
	Super.Tick(deltaTime);
}

function ZoneChange(ZoneInfo NewZone)
{
	local SmokeTrail p;

	Super.ZoneChange(NewZone);

	// fade out quick, slow down, don't hurt people, hiss, make smoke
	if ( NewZone.bWaterZone )
	{
		LifeSpan = FMin( 0.15, LifeSpan );
		Velocity /= 4;
		SetCollision(false);
		PlaySound( Sound'MedicalHiss',,/*volume*/,,/*radius*/, /*pitch*/ );

		if ( !bSpawnedInWater )
		{
			if ( smoke != none )
			{
				smoke.Destroy();
				smoke = None;
			}

			p = Spawn( class'SmokeTrail' );
			if ( p != None )
			{
				p.Velocity.Z = 35 + FRand()*30;
				p.OrigVel = p.Velocity;
				p.DrawScale = DrawScale * 1.5;
				p.OrigScale = p.DrawScale;
				p.LifeSpan = 1.0 + FRand();
				p.OrigLifeSpan = p.LifeSpan;
			}
		}
	}
}

// so we won't spawn extinguishing steam if we were spawned underwater
// which should never really be an issue since the weapon won't let you fire underwater...
simulated function PreBeginPlay()
{
	if ( Region.Zone.bWaterZone )
		bSpawnedInWater = true;

	Super.PreBeginPlay();
}

// slide along walls
auto simulated state Flying
{
	simulated function HitWall( vector HitNormal, actor Wall )
	{
		Velocity = 0.75 * ( (Velocity dot HitNormal) * HitNormal * (-1.0) + Velocity );
		Velocity += 65*HitNormal;  // accomodate for the enlargement of the flame
		Super.HitWall(HitNormal, Wall);
	}
}

// just in case (normally it'll be relinquished to do it's own thing
// and set to None before this gets called from LifeSpan running out)
function Destroyed()
{
	if ( smoke != None )
		smoke.Destroy();

	Super.Destroyed();
}

// For hitting walls, draw fire on them
simulated function SpawnEffects(Vector HitLocation, Vector HitNormal, Actor Other)
{
	local TNMFireChild f;
	local int i;
	local vector loc;
	
	Super.SpawnEffects(HitLocation, HitNormal, Other);
	
	if (Level.NetMode != NM_Standalone)
		return;

	if (!bHitFakeBackdrop)
	{
		for (i=0; i<2; i++)
		{
			loc.X = 0.9*CollisionRadius * (1.0-2.0*FRand());
			loc.Y = 0.9*CollisionRadius * (1.0-2.0*FRand());
			loc.Z = 0.9*CollisionHeight * (1.0-2.0*FRand());
			loc += Location;
			f = Spawn(class'TNMFireChild', Other,, loc);
			if (f != None)
			{
				f.DrawScale = (FRand() + 1.0) / 4;
				f.LifeSpan =  5 + Rand(10) + FRand(); // 5-15
				f.Texture=FireTexture'Effects.Fire.flame_b';
					
				// turn off the sound and lights for all but the first one
				if (i > 0)
				{
					f.AmbientSound = None;
					f.LightType = LT_None;
				}
					
				// turn on/off extra fire and smoke
				if (FRand() < 0.9)
					f.smokeGen.Destroy();
				if (FRand() < 0.25)
					f.AddFire(1.5);
			}
		}
	}
}

defaultproperties
{
     DamageType=Flamed
     AccurateRange=750
     maxRange=750
     bIgnoresNanoDefense=True
     ItemName="Fireball"
     ItemArticle="a"
     speed=1200.000000
     MaxSpeed=1200.000000
     Damage=1.000000
     MomentumTransfer=500
     ExplosionDecal=Class'DeusEx.BurnMark'
     LifeSpan=0.750000
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'DeusExItems.Skins.FlatFXTex11'
     DrawScale=0.030000
     bUnlit=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=200
     LightHue=16
     LightSaturation=32
     LightRadius=6
     bBounce=True
}

//=============================================================================
// HalonGas.
//=============================================================================
class tnmHalonGas extends Cloud;

#exec OBJ LOAD FILE=Effects

var TNMFireballSmoke smoke;
var float suffocationradius;

simulated function Tick(float deltaTime)
{
	local trestkon player;

	//Copied from FireBall.uc
    local float value;
	local float sizeMult;

	// don't Super.Tick() becuase we don't want gravity to affect the stream
	time += deltaTime;

	value = 1.0+time;
	if (MinDrawScale > 0)
		sizeMult = MaxDrawScale/MinDrawScale;
	else
		sizeMult = 1;

	DrawScale = (-sizeMult/(value*value) + (sizeMult+1))*MinDrawScale;
	ScaleGlow = Default.ScaleGlow/(value*value*value);
	//Copied from FireBall.uc


    //Copied from TNMFireBall.uc
    DrawScale += deltaTime*4;
	SetCollisionSize( DrawScale*12, DrawScale*12 );

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
	//Copied from TNMFireBall.uc

	// every player in range suffocates, not just the host
	foreach RadiusActors(class'Trestkon', player, suffocationradius)
		player.halongastimer = 0.5;
}


// slide along walls = Copied from TNMFireball
auto simulated state Flying
{
	simulated function HitWall( vector HitNormal, actor Wall )
	{
		Velocity = 0.75 * ( (Velocity dot HitNormal) * HitNormal * (-1.0) + Velocity );
		Velocity += 65*HitNormal;  // accomodate for the enlargement of the flame
	}
	function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if (ScriptedPawn(Other) == None || Owner != ScriptedPawn(Other))
			Other.TakeDamage( Damage, Instigator,  vect(0,0,0), vect(0,0,0), damageType );
	}
}

function ZoneChange(ZoneInfo NewZone)
{
	Super.ZoneChange(NewZone);

	// If the fireball enters water, extingish it
	if (NewZone.bWaterZone)
		Destroy();
}

defaultproperties
{
     suffocationradius=100.000000
     DamageType=HalonGas
     AccurateRange=320
     maxRange=320
     maxDrawScale=2.000000
     ItemName="Halon Gas"
     speed=500.000000
     MaxSpeed=500.000000
     Damage=0.000000
     MomentumTransfer=300
     Texture=FireTexture'Effects.Smoke.SmokePuff1'
}

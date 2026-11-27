//=============================================================================
// Fireball.
// Smoke39 - new, fancier flamer projectile
//=============================================================================
class SDFireball extends TNMFireball;

simulated function Tick(float deltaTime)
{
	DrawScale += deltaTime*4;
	SetCollisionSize( DrawScale*12, DrawScale*12 );
	// LightRadius = Clamp(6 * (1 - DrawScale * 0.5), 0, 6);
	// // LightRadius is a byte and I worry that it underflows
	// if (LightRadius > 6)
		// LightRadius = 0;

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
}

// For hitting walls, draw fire on them
simulated function SpawnEffects(Vector HitLocation, Vector HitNormal, Actor Other)
{
	local TNMFireChild f;
	local int i;
	local vector loc;
	
	Super(TNMProjectile).SpawnEffects(HitLocation, HitNormal, Other);
	
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
			f = Spawn(class'SDFireChild', Other,, loc);
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
     LightType=LT_None
     LightEffect=LE_None
}

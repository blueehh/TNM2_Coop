//=============================================================================
// MolotovProj.
//=============================================================================
class MolotovProj extends TNMThrownProjectile;

#exec OBJ LOAD FILE=Effects

var class<Fragment> fragType;		// fragments created when pickup is destroyed
var float	mpBlastRadius;
var float	mpProxRadius;
var float	mpLAMDamage;
var float	mpFuselength;

simulated function BreakItSmashIt(class<fragment> FragType, float size)
{
	 local int i;
	 local DeusExFragment s;

	 for (i=0; i<Int(size); i++)
	 {
	      s = DeusExFragment(Spawn(FragType, Owner));
	      if (s != None)
		  {
		      s.Instigator = Instigator;
		      s.CalcVelocity(Velocity,0);
		      s.DrawScale = ((FRand() * 0.05) + 0.05) * size;
		      s.Skin = GetMeshTexture();

			  // play a good breaking sound for the first fragment
		      if (i == 0)
			     s.PlaySound(sound'GlassBreakSmall', SLOT_None,,, 768);
		   }
      }

	  Destroy();
}

auto simulated state Flying
{

	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		/*local ShockRing ring;
		local DeusExPlayer player;
		local float dist;


		// flash the screen white based on how far away the explosion is
		//		player = DeusExPlayer(GetPlayerPawn());
		//		MBCODE: Reference projectile owner to get player
		//		because sever fails to get it the old way
		player = DeusExPlayer(Owner);


		dist = Abs(VSize(player.Location - Location));

		// if you are at the same location, blind the player
		if (dist ~= 0)
			dist = 10.0;
		else
			dist = 2.0 * FClamp(blastRadius/dist, 0.0, 4.0);

		if (damageType == 'EMP')
			player.ClientFlash(dist, vect(0,200,1000));
		else if (damageType == 'TearGas')
			player.ClientFlash(dist, vect(0,1000,100));
		else
			player.ClientFlash(dist, vect(1000,1000,900));

      //DEUS_EX AMSD Only do visual effects if client or if destroyed via damage (since the client can't detect that)
      if ((Level.NetMode != NM_DedicatedServer) || (Role < ROLE_Authority) || bDamaged)
      {
         SpawnEffects(HitLocation, HitNormal, None);
         DrawExplosionEffects(HitLocation, HitNormal);
      }

		if ((damageType=='TearGas') && (Role==ROLE_Authority))
			SpawnTearGas();

		PlayImpactSound();

		if ( AISoundLevel > 0.0 )
			AISendEvent('LoudNoise', EAITYPE_Audio, 2.0, AISoundLevel*blastRadius*16);

		GotoState('Exploding');*/
		HitWall(vector(Rotation),None);
	}
	simulated function HitWall (vector HitNormal, actor HitWall)
	{
		local Rotator rot;
		local float   volume;
		local int i;
	    local DeusExFragment s;
	    local Vector loc;
	    local incinerator gas;
		local tnmzoneinfo z;
		local waterdrop waterSpawn;

		if ( Role < ROLE_Authority )
		return;

        BreakItSmashIt(fragType, (CollisionRadius + CollisionHeight) / 2);
		
		z=tnmzoneinfo(region.zone);
		
		// If broken in an area with no oxygen, just spawn water
		if (z != None && z.bNoOxygen)
		{
			for (i=0; i<10; i++)
			{
				if (FRand() < 0.9 || i==1)
				{
					loc=Location;
					loc.X +=FRand() * 128 - 128 * 0.5;
					loc.Y +=FRand() * 128 - 128 * 0.5;
					loc.Z -=CollisionHeight;
					waterSpawn = spawn(Class'WaterDrop', None,, loc);
					if (waterSpawn !=None)
					{
						waterSpawn.Velocity=VRand() * 32;
						waterSpawn.Acceleration=waterSpawn.Velocity;
					}
				}
			}
		}
		else
		{
			for (i=0; i<10; i++)
			{
				if (FRand() < 0.9 || i==1)
				{
					loc=Location;
					loc.X +=FRand() * 128 - 128 * 0.5;
					loc.Y +=FRand() * 128 - 128 * 0.5;
					if (i != 1) // Spawn at least one at the hit location if hitting the ceiling
						loc.Z +=32;
					gas=spawn(class'incinerator', None,, loc);
					if (gas !=None)
					{
						gas.Velocity=vect(0,0,0);
						gas.Acceleration=vect(0,0,0);
						gas.DrawScale=FRand() * 0.5 + 2.0;
						gas.LifeSpan=FRand() * 10 + 30;
						if ( Level.NetMode !=NM_Standalone )
							gas.bFloating=False;
						else
							gas.bFloating=True;
						gas.Instigator=Instigator;
					}
				}
			}
		}

	    Velocity = Elasticity*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
		speed = VSize(Velocity);
		if (bFirstHit && speed<400)
			bFirstHit=False;
		RotationRate = RotRand(True);
		if ( (speed < 60) && (HitNormal.Z > 0.7) )
		{
			volume = 0.5+FRand()*0.5;
			PlaySound(MiscSound, SLOT_None, volume,, 512, 0.85+FRand()*0.3);

			// I know this is a little cheesy, but certain grenade types should
			// not alert AIs unless they are really really close - CNN
			if (AISoundLevel > 0.0)
				AISendEvent('LoudNoise', EAITYPE_Audio, volume, AISoundLevel*256);
            SetPhysics(PHYS_None, HitWall);
			if (Physics == PHYS_None)
			{
				rot = Rotator(HitNormal);
				rot.Roll = Rand(32767) + Rand(32767); // Rand is limited to 2^15
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


//Multiplayer Crap.
simulated function PreBeginPlay()
{
    Super.PreBeginPlay();

	if ( Level.NetMode != NM_Standalone )
	{
		blastRadius=mpBlastRadius;
		proxRadius=mpProxRadius;
		Damage=mpLAMDamage;
		fuseLength=mpFuselength;
		bIgnoresNanoDefense=True;
	}
}

// Molotovs shouldn't beep.
function PlayBeepSound( float Range, float Pitch, float volume )
{
}

defaultproperties
{
     FragType=Class'DeusEx.GlassFragment'
     mpBlastRadius=512.000000
     mpProxRadius=128.000000
     mpLAMDamage=500.000000
     proxRadius=128.000000
     blastRadius=384.000000
     bIgnoresNanoDefense=True
     ItemName="Molotov Cocktail Bottle"
     speed=1000.000000
     MaxSpeed=1000.000000
     Damage=50.000000
     MomentumTransfer=50000
     ImpactSound=Sound'DeusExSounds.Weapons.LAMExplode'
     ExplosionDecal=Class'DeusEx.ScorchMark'
     LifeSpan=0.000000
     Texture=Texture'TNM.Skins.MoloBottleTex1'
     Mesh=LodMesh'TNM.MolBottleProj'
     DrawScale=0.500000
     CollisionRadius=4.300000
     CollisionHeight=10.800000
     Mass=5.000000
     Buoyancy=2.000000
}

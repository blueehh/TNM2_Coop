//=============================================================================
// WeaponFireStaff.
//=============================================================================
class WeaponFireStaff extends TNMWeapon;

#exec OBJ LOAD FILE=Effects

var int BurnTime, BurnDamage;

var int		mpBurnTime;
var int		mpBurnDamage;

// Muzzle Flash Stuff
// called from the mesh NOTIFY Copied from DeusexWeapons.uc and modified...
simulated function SwapMuzzleFlashTexture()
{
     if (!bHasMuzzleFlash)
     return;
     if (FRand() < 0.5)
         MultiSkins[4] = Texture'Effects.liquid.Virus_SFX';
     else
         MultiSkins[4] = Texture'Effects.liquid.Virus_SFX';

     MuzzleFlashLight();
     SetTimer(0.1, False);
}

simulated function EraseMuzzleFlashTexture1()
{
     MultiSkins[4] = None;
}

simulated function Timer()
{
     EraseMuzzleFlashTexture1();
}

simulated function MuzzleFlashLight()
{
     local Vector offset, X, Y, Z;
     local Effects flash;

      if (!bHasMuzzleFlash)
          return;

     if ((flash != None) && !flash.bDeleteMe)
          flash.LifeSpan = flash.Default.LifeSpan;
     else
     {
          GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
          offset = Owner.Location;
          offset += X * Owner.CollisionRadius * 2;
          flash = spawn(class'Muzzleflash',,, offset);
          if (flash != None)
               flash.SetBase(Owner);
     }
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a deathmatch game, then override defaults
	if ( IsDeathmatchStats() )
	{
      HitDamage = mpHitDamage;
      BaseAccuracy=mpBaseAccuracy;
      ReloadTime = mpReloadTime;
      AccurateRange = mpAccurateRange;
      MaxRange = mpMaxRange;
      ReloadCount = mpReloadCount;
      BurnTime = mpBurnTime;
      BurnDamage = mpBurnDamage;
      PickupAmmoCount = mpReloadCount;
	}
}

function GiveTo(Pawn Other)
{	
	local Trestkon player;

	Super.GiveTo(Other);
	
	player = Trestkon(Other);
	
	if (player != None)
		player.SetAchievement("achFirestaff");
}


//
// When the Staff is Reloading
//
state Reload
{
      function BeginState()
      {
           Super.BeginState();
//         playsound(sound'Soundfile'); //You'll have to #exec import the sound if you want one, I thought it would be good if
                                        //if the player mutters some magical words when it reloads, but it's up to you
           LightType = LT_Flicker;
           LightEffect = LE_NonIncidence;
       }
}


//
// When the Staff is Idle
//
state Idle
{
     function BeginState()
     {
          Super.BeginState();
          LightType = LT_Steady;
     }
}


//
// When the Staff is down
//
state DownWeapon
{
     function BeginState()
     {
          Super.BeginState();
          LightType = LT_None;
     }
}


//
// When the Staff is picked up
//
auto state Pickup
{
     function EndState()
     {
          Super.EndState();
          LightType = LT_None;
     }
}

simulated function renderoverlays(Canvas canvas)
{
	if (DeusExPlayer(Owner) != None)
	{		
		Multiskins[1] = GetCloakTexture();
		Multiskins[2] = GetCloakTexture();
		Multiskins[3] = GetCloakTexture();
		Multiskins[5] = Getweaponhandtex();	
		
		Super.RenderOverlays(canvas);
		
		Multiskins[1] = None;
		Multiskins[2] = None;
		Multiskins[3] = None;
		Multiskins[5] = None;
	}
}

defaultproperties
{
     burnTime=30
     BurnDamage=5
     mpBurnTime=15
     mpBurnDamage=2
     bUniqueWeapon=True
     bNoMetal=True
     possibleAttributes(0)=Att_Lubricated
     possibleAttributes(1)=Att_Desperate
     possibleAttributes(2)=Att_Luminous
     possibleAttributes(3)=Att_Rapid
     possibleAttributes(4)=Att_Resourceful
     possibleAttributes(5)=Att_Enlarged
     possibleAttributes(6)=Att_Fleeting
     possibleAttributes(7)=Att_Swift
     possibleAttributes(8)=Att_Incendiary
     possibleAttributes(9)=Att_Shrunken
     legendaryChance=1.000000
     LowAmmoWaterMark=50
     GoverningSkill=Class'DeusEx.SkillWeaponRifle'
     NoiseLevel=0.050000
     EnemyEffective=ENMEFF_Organic
     EnviroEffective=ENVEFF_Air
     Concealability=CONC_Visual
     bAutomatic=True
     ShotTime=0.100000
     reloadTime=5.000000
     HitDamage=0
     maxRange=960
     AccurateRange=960
     BaseAccuracy=0.900000
     ScopeFOV=25
     mpReloadTime=3.000000
     mpHitDamage=20
     mpBaseAccuracy=0.200000
     mpAccurateRange=1200
     mpMaxRange=1200
     mpReloadCount=2
     AmmoName=Class'TNM.AmmoManaPotion'
     ReloadCount=100
     PickupAmmoCount=100
     FireOffset=(Y=10.000000,Z=10.000000)
     ProjectileClass=Class'TNM.TNMFireball'
     shakemag=20.000000
     FireSound=Sound'TNM.Weapons.FireStaffFire'
     CockingSound=Sound'TNM.Weapons.FireStaffReload'
     SelectSound=Sound'DeusExSounds.Weapons.CrowbarSelect'
     Misc1Sound=None
     InventoryGroup=28
     bAmbientGlow=True
     ItemName="Firestaff"
     ItemArticle="the"
     PlayerViewOffset=(X=18.000000,Y=-10.000000,Z=-14.500000)
     PlayerViewMesh=LodMesh'TNM.DeusStaff'
     PickupViewMesh=LodMesh'TNM.DeusStaffPickup'
     PickupViewScale=1.300000
     ThirdPersonMesh=LodMesh'TNM.DeusStaff3rd'
     ThirdPersonScale=0.900000
     Icon=Texture'TNM.Skins.BeltIconStaff'
     largeIcon=Texture'TNM.Skins.LargeIconStaff'
     largeIconWidth=205
     largeIconHeight=36
     invSlotsX=4
     Description="UNIQUE WEAPON:|nThis is the legendary Firestaff, which you retrieved from its protected container in the ancient moderator control room in the ruins of Deus Ex Incarnate, where it was actually enjoying itself quite a bit. What the heck were you thinking? Did you care to just ask the staff if it wanted to be removed? NO! Heartless bastard."
     beltDescription="FIRESTAFF"
     Mesh=LodMesh'TNM.DeusStaffPickup'
     AmbientGlow=255
     CollisionRadius=9.000000
     CollisionHeight=4.000000
     LightType=LT_Steady
     LightEffect=LE_WateryShimmer
     LightBrightness=255
     LightHue=176
     LightSaturation=20
     LightRadius=4
}

//=============================================================================
// TNMWeapon.
//=============================================================================
class TNMWeapon extends DeusExWeapon
	abstract;

//var(shopping) bool bstolen;
//replaced with bSplashDamage
//var(shopping) int cost;
//replaced with armorabsorption

var() int amplitude;
var bool bRadishHover;
var bool busefiremode;
var string firemode;
var string belttext;
var bool bItemRefusalOverride;
var bool bUniqueWeapon;
var travel int katanaLevel;

var sound bruhSound;

var() sound hitfleshsound;
var() sound hitwoodsound;
var() sound hitmetalsound;
var() sound hitothersound;
var() sound deselectsound;
var() sound firesilencedsound;
var() sound altfiresilencedsound;
var() sound AltFireSoundReal;

var texture ScopeTexture01;
var texture ScopeTexture02;
var texture ScopeTexture03;
var texture ScopeTexture04;

//var bool bHasUberScope;
var int targetDistance;
var int lastBeltPos;

var bool bNoMetal;

enum EScopeType
{
	EScopeType_Normal,
	EScopeType_HighTech,
	EScopeType_Red,
	EScopeType_Custom
};

var EScopeType ScopeType;

// Smoke39 - bloody weapon variables
var() bool bGetsBloody;		// typically, melee weapons will have this set to true
var travel float Bloodiness;	// how bloody the weapon currently is

var bool bReloadAnimHack;

var class<Inventory> ModelClass; //for hdtp compatability

var float LockonSoundRate;

//laser stuff: actually far far more effort that was really worth it

var float laserupdatetime, laserupdatetimer;
var float laserupdatetime2, laserupdatetimer2;

var bool bLasingNew;
var bool bCountLaser1, bCountLaser2;
var bool buselaser1;

var vector newlaservec;
var vector lastlaservec;
var vector futurelaservec;

var travel bool bWasLasing; // were we lasing? (used during map transitions)

var Rotator placeNormal;						// used for prox. mine placement // Was Vector

var localized string msgNeedOxygen;
var localized string CaptionFiring, CaptionDryFire, CaptionReloadStart, CaptionReloadEnd;
var localized string itemNameShort;
var localized string strKills;
var localized string strKnockouts;

var bool bSoundEffectPending; // Play hit sound effect only on first hit.

var bool bOverwritePlayerViewMesh, bOverwritePickupViewMesh, bOverwriteThirdPersonMesh;
var Trestkon TempPlayer;
var TNMOggMusicManager ogg;
var LegendaryFX legendaryEffect;
var() travel int numKills; //How many kills has this weapon got?

var enum EAttribute
{
	Att_None,
	Att_Lubricated,
	Att_Ruthless,
	Att_Directed,
	Att_Zoomed,
	Att_Silenced,
	Att_Puncturing,
	Att_ArmorPiercing,
	Att_Painful,
	Att_Blinding,
	Att_Paralyzing,
	Att_Phreaking,
	Att_Desperate,
	Att_Junkie,
	Att_Assassin,
	Att_Valiant,
	Att_Quaking,
	Att_Venomous,
	Att_Technophobic,
	Att_Frying,
	Att_Lamar,
	Att_00n,
	Att_Narcissian,
	Att_Luminous,
	Att_Penetrative,
	Att_Rapid,
	Att_Embiggening,
	Att_Explosive,
	Att_DoubleBarreled,
	Att_Wild,
	Att_Energized,
	Att_Messy,
	Att_Lucky,
	Att_Resourceful,
	Att_Leeching,
	Att_Precise,
	Att_Enlarged,
	Att_Augmented,
	Att_LowTech,
	Att_Dismantling,
	Att_Focused,
	Att_Intense,
	Att_Long,
	Att_Fleeting,
	Att_Swift,
	Att_Incendiary,
	Att_Docile,
	Att_Pinpoint,
	Att_Gaseous,
	Att_Irritating,
	Att_Panicked,
	Att_Shrunken,
	Att_Lightened,
	Att_Crazed,
	Att_Environmental,
	Att_Hunter,
	Att_Immolative,
	Att_Tracking,
	Att_Faithful
} AttributeList;

var travel EAttribute Attribute;
var travel int Attributes1;
var travel int Attributes2;
var EAttribute possibleAttributes[59];
var localized string AttributeName[59];
var localized string AttributeDesc[59];
var() float legendaryChance;
var travel bool bAttributeApplied;
var travel bool bAttributeReapply;
var travel string legendaryNames;
var localized string strTitlePrefix[7];
var travel int legendaryCount;

//WCCC: Paranoid reload additions. Yay.
var bool bLoadAmmoFudge;
var class<Ammo> LastAmmoType;

replication
{
	// attributes change movement (Att_Fleeting, Att_Quaking) and the inventory
	// description, so the owning client needs them to predict and display correctly
	reliable if ((Role == ROLE_Authority) && (bNetOwner))
		Attribute, Attributes1, Attributes2;

	// Co-op 250ms-500ms lag-compensated combat RPCs (client -> server)
	reliable if (Role < ROLE_Authority)
		ServerCoopTraceHit, ServerCoopSpawnProjectile, ServerCoopSyncWallPlace;
}

//HDTP weapon hands
function texture GetWeaponHandTex()
{
	// Cloak gets priority
	if (PlayerCloakDetected()) 
	{
		ScaleGlow = 0.05;
		Style = STY_Translucent;
		return Texture'WhiteStatic';
	}
	
	// If not cloaked, reset.
	AmbientGlow = Default.AmbientGlow;
	ScaleGlow = Default.ScaleGlow;
	Style = Default.Style;
	
	// return texture'TNM.Skins.Hands';
	return texture'TNM.Skins.JWeaponFists1';
}

function texture GetCloakTexture()
{	
	// local texture tex;
	
	// Cloak gets priority
	if (PlayerCloakDetected()) 
	{
		ScaleGlow = 0.05;
		Style = STY_Translucent;
		return Texture'WhiteStatic';
	}
	
	// If not cloaked, reset.
	AmbientGlow = Default.AmbientGlow;
	ScaleGlow = Default.ScaleGlow;
	Style = Default.Style;
	
	return None;
}

//WCCC, 3/16/19: Make sure the new 20mm and Rocket equivalents update sounds properly.
//Luckily, this seems to be one stop shopping.

//
// functions to change ammo types
//
function bool LoadAmmo(int ammoNum)
{
	local class<Ammo> newAmmoClass;
	local Ammo newAmmo;
	local Pawn P;

	if ((ammoNum < 0) || (ammoNum > 2))
		return False;

	//WCCC, 9/24/24: We were witnessed as having been ran as god intended.
	bLoadAmmoFudge = true;

	P = Pawn(Owner);

	// sorry, only pawns can have weapons
	if (P == None)
		return False;

	newAmmoClass = AmmoNames[ammoNum];

	if (newAmmoClass != None)
	{
		if (newAmmoClass != AmmoName)
		{
			newAmmo = Ammo(P.FindInventoryType(newAmmoClass));
			if (newAmmo == None)
			{
				P.ClientMessage(Sprintf(msgOutOf, newAmmoClass.Default.ItemName));
				return False;
			}
			
			if (ScriptedPawn(Owner) == None || Trestkon(Owner) == None || !Trestkon(Owner).bParanoidReload)
			{
				ClipCount = ReloadCount;
			}
			
			// if we don't have a projectile for this ammo type, then set instant hit
			if (ProjectileNames[ammoNum] == None)
			{
				bInstantHit = True;
				bAutomatic = Default.bAutomatic;
				if (HasAttribute(Att_Wild))
					bAutomatic = True;
				ShotTime = Default.ShotTime;
				if (HasAttribute(Att_Rapid))
					ShotTime = Default.ShotTime * 0.55;
				if ( IsDeathmatchStats() )
				{
					if (HasReloadMod())
						ReloadTime = mpReloadTime * (1.0+ModReloadTime);
					else
						ReloadTime = mpReloadTime;
				}
				else
				{
					if (HasReloadMod())
						ReloadTime = Default.ReloadTime * (1.0+ModReloadTime);
					else
						ReloadTime = Default.ReloadTime;
				}
				FireSound = Default.FireSound;
				ProjectileClass = None;
			}
			else
			{
				// otherwise, set us to fire projectiles
				bInstantHit = False;
				bAutomatic = False;
				// ShotTime = 1.0;
				// if (HasReloadMod())
					// ReloadTime = 2.0 * (1.0+ModReloadTime);
				// else
					// ReloadTime = 2.0;
				ShotTime = Default.ShotTime;
				if (HasAttribute(Att_Rapid))
					ShotTime = Default.ShotTime * 0.55;
				if ( IsDeathmatchStats() )
				{
					if (HasReloadMod())
						ReloadTime = mpReloadTime * (1.0+ModReloadTime);
					else
						ReloadTime = mpReloadTime;
				}
				else
				{
					if (HasReloadMod())
						ReloadTime = Default.ReloadTime * (1.0+ModReloadTime);
					else
						ReloadTime = Default.ReloadTime;
				}
				//FireSound = None;		// handled by the projectile
				//G-Flex: set to default FireSound instead, which *should* be None
				//G-Flex: because projectile sounds are handled by the projectile itself
				//G-Flex: except for ones that fire multiple projectiles at once (e.g. flamethrower, plasma rifle)
				//G-Flex: but use no sound at all for ones that would have an inappropriate bullet-shooting noise
				if (Default.bInstantHit)
					FireSound = None;
				else
					FireSound = Default.FireSound;
				ProjectileClass = ProjectileNames[ammoNum];
				ProjectileSpeed = ProjectileClass.Default.Speed;
			}

			AmmoName = newAmmoClass;
			AmmoType = newAmmo;

			// AlexB had a new sound for 20mm but there's no mechanism for playing alternate sounds per ammo type
			// Same for WP rocket
			//-----------
			//WCCC, 3/16/19: NOTE: Due to package order and division, we have to use .IsA for references.
			// if ( Ammo20mm(newAmmo) != None || newAmmo.IsA('AmmoTNM20mm') || newAmmo.IsA('AmmoSpiderCannister') )
				// FireSound=Sound'AssaultGunFire20mm';
			// else if ( AmmoRocketWP(newAmmo) != None || newAmmo.IsA('AmmoTNMRocketWP') )
				// FireSound=Sound'GEPGunFireWP';
			// else if ( AmmoRocket(newAmmo) != None || newAmmo.IsA('AmmoTNMRocket') || newAmmo.IsA('AmmoEMPRocket') )
				// FireSound=Sound'GEPGunFire';

			if ( Level.NetMode != NM_Standalone )
				SetClientAmmoParams( bInstantHit, bAutomatic, ShotTime, FireSound, ProjectileClass, ProjectileSpeed );

			// Notify the object belt of the new ammo
			if (DeusExPlayer(P) != None)
				DeusExPlayer(P).UpdateBeltText(Self);

			ReloadAmmo();

			P.ClientMessage(Sprintf(msgNowHas, ItemName, newAmmoClass.Default.ItemName));
			return True;
		}
		else
		{
			P.ClientMessage(Sprintf(MsgAlreadyHas, ItemName, newAmmoClass.Default.ItemName));
		}
	}

	return False;
}

//WCCC, 3/16/19: Fix single item names by calling a nasty little hook here.
function TravelPostAccept()
{
	local bool bAmmoWasNull;
	local int i;
	
	if (AmmoType == None) 
		bAmmoWasNull = true;
	
	Super.TravelPostAccept();
	
	if ((bAmmoWasNull) && (TNMAmmo(AmmoType) != None)) 
		TNMAmmo(AmmoType).TNMAmmoFrobbed(Owner, None);

	if (!bInstantHit)
	{
		if (ProjectileClass != None)
			ProjectileSpeed = ProjectileClass.Default.speed;

		// make sure the projectile info matches the actual AmmoType
		// since we can't "var travel class" (AmmoName and ProjectileClass)
		if (AmmoType != None)
		{
			//G-Flex: set to default FireSound instead, which should be None
			//G-Flex: because projectile sounds are handled by the projectile itself
			if (Default.bInstantHit)
				FireSound = None;
			else
				FireSound = Default.FireSound;
			for (i=0; i<ArrayCount(AmmoNames); i++)
			{
				if (AmmoNames[i] == AmmoName)
				{
					ProjectileClass = ProjectileNames[i];
					break;
				}
			}
		}
	}
	
	// Make the object follow us, for AmbientSound mainly
	if (Owner != None)
	{
		AttachTag = Owner.Name;
		SetPhysics(PHYS_Trailer);
		SetLocation(Owner.Location);
	}
}

function GiveTo(Pawn Other)
{
	Super.GiveTo(Other);
	
	// Make the object follow us, for AmbientSound mainly
	if (Owner != None)
	{
		AttachTag = Owner.Name;
		SetPhysics(PHYS_Trailer);
		SetLocation(Owner.Location);
	}
}

//WCCC, 3/16/19: Same as above.
function GiveAmmo( Pawn Other )
{
	local bool bAmmoWasNull;
	
	if (AmmoType == None) bAmmoWasNull = true;
	
	Super.GiveAmmo(Other);
	
	if ((bAmmoWasNull) && (TNMAmmo(AmmoType) != None)) TNMAmmo(AmmoType).TNMAmmoFrobbed(Other, None);
}

//laser functions
//
// copied from Weapon.uc so we can add range information
//
simulated function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local Rotator rot;
	local actor Other;
	local float dist, alpha, degrade;
	local int i, numSlugs;
	local float volume, radius;
	
	local Actor BackOther;
	local Vector BackHitLocation, BackHitNormal;
	
	// make noise if we are not silenced
	if (!bHasSilencer && !bHandToHand)
	{
		GetAIVolume(volume, radius);
		if (Owner != None)
		{
			Owner.AISendEvent('WeaponFire', EAITYPE_Audio, volume, radius);
			Owner.AISendEvent('LoudNoise', EAITYPE_Audio, volume, radius);
			if (!Owner.IsA('PlayerPawn'))
				Owner.AISendEvent('Distress', EAITYPE_Audio, volume, radius);
		}
	}

	if (Pawn(Owner) != None)
		GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	StartTrace = ComputeProjectileStart(X, Y, Z);
	if (Pawn(Owner) != None)
		AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);

	// check to see if we are a shotgun-type weapon
	if (AreaOfEffect == AOE_Cone || katanaLevel >= 5)
	{
		if (AmmoType != None && AmmoNone(AmmoType) != None)
			numSlugs = 3;	// Melee
		else
			numSlugs = 5;	// Shotgun
	}
	else
		numSlugs = 1;

	// if there is a scope, but the player isn't using it, decrease the accuracy
	// so there is an advantage to using the scope
	//if (bHasScope && !bZoomed && !bLasing)
	//	Accuracy += 0.2;
	// if the laser sight is on, make this shot dead on
	// also, if the scope is on, zero the accuracy so the shake makes the shot inaccurate
	if (bLasing || bZoomed)
		Accuracy = 0.0;

	//G-Flex: sabot always hits the same spot
	//G-Flex: damage MUST be compensated for elsewhere!
	if ((AmmoType != None) && AmmoType.IsA('AmmoSabot'))
		numSlugs = 1;
		
	bSoundEffectPending = True;

	for (i=0; i<numSlugs; i++)
	{
		// If we have multiple slugs, then lower our accuracy a bit after the first slug so the slugs DON'T all go to the same place
		if ((i > 0) && !(bHandToHand))
			if (Accuracy < MinSpreadAcc)
				Accuracy = MinSpreadAcc;

		// Let handtohand weapons have a better swing
		if ((bHandToHand) && (NumSlugs > 1) && (Level.NetMode != NM_Standalone))
		{
			StartTrace = ComputeProjectileStart(X,Y,Z);
			StartTrace = StartTrace + (numSlugs/2 - i) * SwingOffset;
		}

		if(!bLasing || Emitter == none)
		{
			EndTrace = StartTrace + Accuracy * (FRand()-0.5)*Y*1000 + Accuracy * (FRand()-0.5)*Z*1000 ;
			EndTrace += (FMax(1024.0, MaxRange) * vector(AdjustedAim));
		}
		else //we take it direct from  the emitter
		{
			StartTrace = emitter.Location;
			endtrace = starttrace + vector(emitter.Rotation)*FMax(1024.0, MaxRange);
		}

		if (Pawn(Owner) != None)
			Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);

		// randomly draw a tracer for relevant ammo types
		// don't draw tracers if we're zoomed in with a scope - looks stupid
		// DEUS_EX AMSD In multiplayer, draw tracers all the time.
		if ( ((Level.NetMode == NM_Standalone) && (!bZoomed && (numSlugs == 1) && (FRand() < 0.5))) ||
		   ((Level.NetMode != NM_Standalone) && (Role == ROLE_Authority) && (numSlugs == 1)) )
		{
			if ((AmmoName == Class'Ammo10mm') || (AmmoName == Class'Ammo3006') ||
				(AmmoName == Class'Ammo762mm'))
			{
				if (VSize(HitLocation - StartTrace) > 250)
				{
					rot = Rotator(EndTrace - StartTrace);
					if ((Level.NetMode != NM_Standalone) && (IsA('WeaponRifle') || IsA('WeaponTNMRifle')))
						Spawn(class'SniperTracer',,, StartTrace + 96 * Vector(rot), rot);
					else
						Spawn(class'Tracer',,, StartTrace + 96 * Vector(rot), rot);
				}
			}
		}
		
		//WCCC, 8/27/24: Mini fix for melee being shit.
		if ((bHandToHand) && (Other == Level) && (Trestkon(Owner) != None) && (Trestkon(Owner).LastMoverFrobTarget != None))
		{
			Other = Trestkon(Owner).LastMoverFrobTarget;
		}
		
		// check our range
		dist = Abs(VSize(HitLocation - Owner.Location));

		if (dist <= AccurateRange)		// we hit just fine
		{
			ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
			if ((Level.NetMode == NM_Client) && (Role < ROLE_Authority) && !UsesServerSideFire() && (DeusExPlayer(Owner) == DeusExPlayer(GetPlayerPawn())))
				ServerCoopTraceHit(Other, (Other == Level), HitLocation, HitNormal, vector(AdjustedAim), StartTrace, (i == 0));
		}
		else if (dist <= MaxRange)
		{
			// simulate gravity by lowering the bullet's hit point
			// based on the owner's distance from the ground
			alpha = (dist - AccurateRange) / (MaxRange - AccurateRange);
			degrade = 0.5 * Square(alpha);
			HitLocation.Z += degrade * (Owner.Location.Z - Owner.CollisionHeight);
			ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
			if ((Level.NetMode == NM_Client) && (Role < ROLE_Authority) && !UsesServerSideFire() && (DeusExPlayer(Owner) == DeusExPlayer(GetPlayerPawn())))
				ServerCoopTraceHit(Other, (Other == Level), HitLocation, HitNormal, vector(AdjustedAim), StartTrace, (i == 0));
		}
		bSoundEffectPending = False;
		
		//WCCC, 8/27/24: Fix for guns not damaging stuff, now respecting the gun's accuracy and what it hit in doing so.
		if ((Other == Level) && (!bHandToHand))
		{
	  		//Do a second trace from the back, and see if we hit a mover we previously did not.
			//This is basically psuedo-penetration, purely for damaging doors 1 time and 1 time only.
	   		BackOther = Trace(BackHitLocation, BackHitNormal, HitLocation, HitLocation + HitNormal + 8 * X, False);
			
			if (Mover(BackOther) != None)
			{
				ProcessTraceHit(BackOther, BackHitLocation, BackHitNormal, X, Y, Z);
				if ((Level.NetMode == NM_Client) && (Role < ROLE_Authority) && !UsesServerSideFire() && (DeusExPlayer(Owner) == DeusExPlayer(GetPlayerPawn())))
					ServerCoopTraceHit(BackOther, False, BackHitLocation, BackHitNormal, X, StartTrace, False);
			}
		}
	}

	// otherwise we don't hit the target at all
}

// Subclasses in TNMItems.u whose TraceFire/ProjectileFire/ProcessTraceHit is non-simulated
// or whose Fire() always executes TraceFire/ProjectileFire on the server
simulated function bool UsesServerSideFire()
{
	return (IsA('WeaponBlowPipe') || IsA('WeaponGibinator') || IsA('WeaponConcussion') || IsA('WeaponLaser') || IsA('WeaponDoubleGuns') || IsA('WeaponNapalmLauncher'));
}

simulated function bool IsCoopReplicatedProjectile()
{
	return (bCanTrack || IsA('WeaponShuriken') || IsA('WeaponTNMShuriken') || IsA('WeaponMiniCrossbow') || IsA('WeaponTNMMiniCrossbow') || IsA('WeaponLAM') || IsA('WeaponEMPGrenade') || IsA('WeaponGasGrenade') || IsA('WeaponNanoVirusGrenade') || IsA('WeaponTNMLAM') || IsA('WeaponTNMEMPGrenade') || IsA('WeaponTNMGasGrenade') || IsA('WeaponTNMNanoVirusGrenade') || IsA('WeaponMine') || IsA('WeaponPlasmaNade') || IsA('WeaponTripBomb') || IsA('WeaponMolBottle') || IsA('WeaponThrowSpork') || IsA('WeaponThrowFoon'));
}

// Co-op high-ping lag compensation: applies client-traced hitscan/melee hits on the server
function ServerCoopTraceHit(Actor HitActor, bool bHitLevel, Vector HitLocation, Vector HitNormal, Vector AimDir, Vector StartTrace, bool bFirstSlug)
{
	local Actor Other;
	local Vector X, Y, Z, FallbackLoc, FallbackNorm;
	local Rotator rot;
	local float volume, radius, maxAllowedDist;

	if ((Role != ROLE_Authority) || (Owner == None) || (Pawn(Owner) == None))
		return;

	GetAxes(Rotator(AimDir), X, Y, Z);

	if (bFirstSlug)
	{
		if (!bHasSilencer && !bHandToHand)
		{
			GetAIVolume(volume, radius);
			Owner.AISendEvent('WeaponFire', EAITYPE_Audio, volume, radius);
			Owner.AISendEvent('LoudNoise', EAITYPE_Audio, volume, radius);
		}

		if ((AreaOfEffect != AOE_Cone) && (katanaLevel < 5))
		{
			if ((AmmoName == Class'Ammo10mm') || (AmmoName == Class'Ammo3006') || (AmmoName == Class'Ammo762mm'))
			{
				if (VSize(HitLocation - StartTrace) > 250)
				{
					rot = Rotator(HitLocation - StartTrace);
					if (IsA('WeaponRifle') || IsA('WeaponTNMRifle'))
						Spawn(class'SniperTracer',,, StartTrace + 96 * Vector(rot), rot);
					else
						Spawn(class'Tracer',,, StartTrace + 96 * Vector(rot), rot);
				}
			}
		}
	}

	if (bHitLevel)
		Other = Level;
	else if (HitActor != None)
		Other = HitActor;
	else
	{
		Other = Pawn(Owner).TraceShot(FallbackLoc, FallbackNorm, HitLocation + AimDir * 64.0, StartTrace);
		if (Other != None)
		{
			HitLocation = FallbackLoc;
			HitNormal = FallbackNorm;
		}
	}

	if (Other == None)
		return;

	// Generous range check (+1024 units) to tolerate up to 500ms+ movement latency
	maxAllowedDist = FMax(AccurateRange, MaxRange) + 1024.0;
	if (VSize(HitLocation - Owner.Location) > maxAllowedDist)
		return;

	bSoundEffectPending = bFirstSlug;
	ProcessTraceHit(Other, HitLocation, HitNormal, AimDir, Y, Z);
	bSoundEffectPending = False;
}

function ServerCoopSyncWallPlace(bool bClientNearWall, Vector clientPlaceLoc, Rotator clientPlaceNorm, Mover clientPlaceMover)
{
	if ((Role != ROLE_Authority) || (Owner == None))
		return;
	if (VSize(clientPlaceLoc - Owner.Location) <= 512.0)
	{
		bNearWall = bClientNearWall;
		placeLocation = clientPlaceLoc;
		placeNormal = clientPlaceNorm;
		placeMover = clientPlaceMover;
	}
}

function PreBeginPlay()
{
	Super.PreBeginPlay();

	CheckWeaponSkins();
}

function RollForLegendary()
{
	local int i, attributeCount;
	local DeusExLevelInfo info;
	local string TitlePrefix;

	if (bAttributeApplied)
		return;
		
	if (!HasAttribute(Att_None))
		return;
		
	while (FRand() <= legendaryChance)
	{		
		legendaryChance = legendaryChance / 2;
		for (i=0;i<ArrayCount(possibleAttributes);i++)
		{
			// log(Self @ i @ possibleAttributes[i] @ AttributeName[possibleAttributes[i]-1]);
			if (possibleAttributes[i] != Att_None)
				attributeCount++;
			else
				break;
		}
		
		if (attributeCount > 0)
			Attribute = possibleAttributes[Rand(attributeCount)];
		info = GetLevelInfo();
		
		// If we're past Day 2, don't roll an anti-cult weapon
		if (Attribute != Att_None && info != None && info.MissionNumber > 22 && (Attribute == Att_Narcissian || Attribute == Att_Lamar || Attribute == Att_00n))
		{
			i = 0;
			while ((Attribute == Att_None || Attribute == Att_Narcissian || Attribute == Att_Lamar || Attribute == Att_00n) && i < 1000)
			{
				// log(Name @ "has Attribute" @ AttributeName[Attribute]);
				Attribute = possibleAttributes[Rand(attributeCount)];
				i++;
				// log(Name @ "now has Attribute" @ AttributeName[Attribute] $ ", attempts:" @ i);
			}
		}
		
		// If we already have this attribute, roll a new one
		if (HasAttribute(Attribute))
		{
			i = 0;
			while ((Attribute == Att_None || HasAttribute(Attribute)) && i < 100)
			{
				Attribute = possibleAttributes[Rand(attributeCount)];
				i++;
			}
		}
		if (Attribute < 31)
			Attributes1 = Attributes1 | (0x01<<Attribute);
		else if (Attribute < 62)
			Attributes2 = Attributes2 | (0x01<<Attribute-31);
		if (Attribute != Att_None)
		{
			// itemName = "Legendary" @ Default.ItemName;
			legendaryNames = AttributeName[Attribute] @ legendaryNames;
			// itemName = "Legendary" @ AttributeName[Attribute] @ Default.ItemName;
			legendaryCount++;
			if (legendaryCount > ArrayCount(strTitlePrefix))
				itemName = strTitlePrefix[ArrayCount(strTitlePrefix)] @ legendaryNames $ Default.ItemName;
			else
				itemName = strTitlePrefix[legendaryCount] @ legendaryNames $ Default.ItemName;
			
			if (TNMPawn(Owner) != None)
			{
				if (!TNMPawn(Owner).bLegendary)
					TNMPawn(Owner).SetCollisionSize(Owner.CollisionRadius, Owner.CollisionHeight + 2.25);
				TNMPawn(Owner).DrawScale += 0.1;
				TNMPawn(Owner).SetCollisionSize(Owner.CollisionRadius, Owner.CollisionHeight * 1.1);
				TNMPawn(Owner).BaseEyeHeight *= 1.1;
				TNMPawn(Owner).BaseAccuracy -= 0.1;
				TNMPawn(Owner).MinHealth = 0;
				TNMPawn(Owner).bExtraSuspicious = true;
				if (!TNMPawn(Owner).bLegendary)
				{
					TNMPawn(Owner).StoredFamiliarName = TNMPawn(Owner).FamiliarName;
					TNMPawn(Owner).StoredUnfamiliarName = TNMPawn(Owner).UnfamiliarName;
				}
				TNMPawn(Owner).bLegendary = true;
				TNMPawn(Owner).LegendaryCount++;
				if (TNMPawn(Owner).bCustomBarkPitch)
					TNMPawn(Owner).barkPitch -= 0.1;
				TNMPawn(Owner).bFearHacking = False;
				TNMPawn(Owner).bFearWeapon = False;
				TNMPawn(Owner).bFearShot = False;
				TNMPawn(Owner).bFearInjury = False;
				TNMPawn(Owner).bFearIndirectInjury = False;
				TNMPawn(Owner).bFearCarcass = False;
				TNMPawn(Owner).bFearDistress = False;
				TNMPawn(Owner).bFearAlarm = False;
				TNMPawn(Owner).bFearProjectiles = False;
				TNMPawn(Owner).MaxProvocations = 0;
				TNMPawn(Owner).UpdateReactionCallbacks();
				if (/*!TNMPawn(Owner).bLegendary && */(Owner.IsA('GenericAggressive') || Owner.IsA('GenericCivilian')))
				{
					switch (TNMPawn(Owner).LegendaryCount)
					{
						case 0:
						case 1:
							TitlePrefix = TNMPawn(Owner).strTitlePrefix[0];
							break;
						case 2:
							TitlePrefix = TNMPawn(Owner).strTitlePrefix[1];
							break;
						case 3:
							TitlePrefix = TNMPawn(Owner).strTitlePrefix[2];
							break;
						case 4:
							TitlePrefix = TNMPawn(Owner).strTitlePrefix[3];
							break;
						case 5:
							TitlePrefix = TNMPawn(Owner).strTitlePrefix[4];
							break;
						case 6:
							TitlePrefix = TNMPawn(Owner).strTitlePrefix[5];
							break;
						default:
							TitlePrefix = TNMPawn(Owner).strTitlePrefix[6];
							break;
					}
					TNMPawn(Owner).FamiliarName = TitlePrefix @ TNMPawn(Owner).StoredFamiliarName;
					TNMPawn(Owner).UnfamiliarName = TitlePrefix @ TNMPawn(Owner).StoredUnfamiliarName;
					// TNMPawn(Owner).SetCollisionSize(Owner.CollisionRadius, Owner.CollisionHeight + 2.25);
				}
				else/* if (!TNMPawn(Owner).bLegendary)*/
				{
					switch (TNMPawn(Owner).LegendaryCount)
					{
						case 0:
						case 1:
							TitlePrefix = TNMPawn(Owner).strTitlePrefixImportant[0];
							if (FRand() < 0.15)
								TitlePrefix = TNMPawn(Owner).strTitlePrefixImportantRare[0];
							break;
						case 2:
							TitlePrefix = TNMPawn(Owner).strTitlePrefixImportant[1];
							if (FRand() < 0.15)
								TitlePrefix = TNMPawn(Owner).strTitlePrefixImportantRare[1];
							break;
						case 3:
							TitlePrefix = TNMPawn(Owner).strTitlePrefixImportant[2];
							if (FRand() < 0.15)
								TitlePrefix = TNMPawn(Owner).strTitlePrefixImportantRare[2];
							break;
						case 4:
							TitlePrefix = TNMPawn(Owner).strTitlePrefixImportant[3];
							if (FRand() < 0.15)
								TitlePrefix = TNMPawn(Owner).strTitlePrefixImportantRare[3];
							break;
						case 5:
							TitlePrefix = TNMPawn(Owner).strTitlePrefixImportant[4];
							if (FRand() < 0.15)
								TitlePrefix = TNMPawn(Owner).strTitlePrefixImportantRare[4];
							break;
						case 6:
							TitlePrefix = TNMPawn(Owner).strTitlePrefixImportant[5];
							if (FRand() < 0.15)
								TitlePrefix = TNMPawn(Owner).strTitlePrefixImportantRare[5];
							break;
						case 7:
							TitlePrefix = TNMPawn(Owner).strTitlePrefixImportant[6];
							if (FRand() < 0.15)
								TitlePrefix = TNMPawn(Owner).strTitlePrefixImportantRare[6];
							break;
						default:
							TitlePrefix = TNMPawn(Owner).strTitlePrefixImportant[7];
							if (FRand() < 0.15)
								TitlePrefix = TNMPawn(Owner).strTitlePrefixImportantRare[7];
							break;
					}
					TNMPawn(Owner).FamiliarName = TitlePrefix @ TNMPawn(Owner).StoredFamiliarName;
					TNMPawn(Owner).UnfamiliarName = TitlePrefix @ TNMPawn(Owner).StoredUnfamiliarName;
					// TNMPawn(Owner).SetCollisionSize(Owner.CollisionRadius, Owner.CollisionHeight + 2.25);
				}
			}
		}
	}
}

function ApplyAttribute()
{
	local int i;
	local int diff;
	
	if (bAttributeApplied && !bAttributeReapply)
		return;
		
	if (HasAttribute(Att_None))
		return;
		
	if (HasAttribute(Att_Tracking))
	{
		 bCanTrack=True;
		 LockTime=0.500000;
		 LockedSound=Sound'DeusExSounds.Weapons.GEPGunLock';
		 TrackingSound=Sound'DeusExSounds.Weapons.GEPGunTrack';
		bAttributeReapply = True;
	}
	if (HasAttribute(Att_Lightened))
	{
		Mass = Default.Mass * 0.5;
		bAttributeReapply = True;
	}
	if (HasAttribute(Att_Directed))
	{
		bHasLaser = True;
	}
	if (HasAttribute(Att_Zoomed))
	{
		bHasScope = True;
	}
	if (HasAttribute(Att_Silenced))
	{
		bHasSilencer = True;
	}
	if (HasAttribute(Att_Quaking))
	{
		if (Trestkon(Owner) != None)
			FireOffset.Y = (Default.FireOffset.Y * -1) - 5;
		bAttributeReapply = True;
	}
	if (HasAttribute(Att_Environmental))
	{
		EnviroEffective = ENVEFF_All;
		bAttributeReapply = True;
	}
	if (HasAttribute(Att_Shrunken))
	{
		if (InvSlotsX > 1)
			InvSlotsX = Default.InvSlotsX - 1;
		if (InvSlotsX == 1)
			largeIcon = icon;
		if (IsA('WeaponBlowPipe'))
			largeIconWidth = 52;
		else if (IsA('WeaponBlackBox'))
			largeIconWidth = 42;
		else if (IsA('WeaponFoon'))
			largeIconWidth = 42;
		else if (IsA('WeaponSpork'))
			largeIconWidth = 42;
		else if (IsA('WeaponSporkGolden'))
			largeIconWidth = 42;
		else if (IsA('WeaponTNMCrowbar'))
			largeIconWidth = 42;
		else if (IsA('WeaponGibinator'))
		{
			largeIconWidth = 32;
			largeIconHeight = 24;
		}
		else if (IsA('WeaponDoubleGuns'))
		{
			largeIconWidth = 42;
			largeIconHeight = 32;
		}
		else if (IsA('WeaponUniqueKylie'))
		{
			largeIconWidth = 42;
			largeIconHeight = 42;
		}
		else if (IsA('WeaponTNMAssaultGun'))
		{
			largeIconWidth = 42;
			largeIconHeight = 42;
		}
		else if (IsA('WeaponTNMAssaultShotgun'))
		{
			largeIconWidth = 42;
			largeIconHeight = 42;
		}
		bAttributeReapply = True;
	}
	if (HasAttribute(Att_Wild))
	{
		bAutomatic = True;
		bAttributeReapply = True;
	}
	if (HasAttribute(Att_Panicked))
	{
		if (ogg == none)
		{
			foreach allactors(class'TNMOggMusicManager',ogg,)
			{
				break;
			}
		}
		if (ogg != None && Trestkon(Owner) != None && ogg.MusicMode == MUS_Combat)
			ShotTime = Default.ShotTime * 0.55;
		else if (ScriptedPawn(Owner) != None && ScriptedPawn(Owner).IsInState('Attacking'))
			ShotTime = Default.ShotTime * 0.55;
		else
			ShotTime = Default.ShotTime;
		bAttributeReapply = True;
	}
	if (HasAttribute(Att_Rapid))
	{
		ShotTime = Default.ShotTime * 0.55;
		bAttributeReapply = True;
	}
	if (HasAttribute(Att_Long))
	{
		AccurateRange = Default.AccurateRange;
		AccurateRange *= 1.5;
		MaxRange = Default.MaxRange;
		MaxRange *= 1.5;
	}
	if (HasAttribute(Att_Docile))
	{
		if (ModRecoilStrength > -0.5)
		{
			RecoilStrength = 0;
			ModRecoilStrength = -0.5;
		}
	}
	if (HasAttribute(Att_Lubricated))
	{
		for (i=0; i<5; i++)
		{
			if (ModReloadTime > -0.5)
			{
			ReloadTime    += (Default.ReloadTime * -0.1);
			if (ReloadTime < 0.0)
				ReloadTime = 0.0;
			ModReloadTime += -0.1;
			}
		}
	}
	if (HasAttribute(Att_Precise))
	{
		for (i=0; i<5; i++)
		{	
			if (ModBaseAccuracy < 0.5)
			{			
				if (BaseAccuracy == 0.0)
					BaseAccuracy    -= 0.1;
				else
					BaseAccuracy    -= (Default.BaseAccuracy * 0.1);
				ModBaseAccuracy += 0.1;
			}
		}
	}
	if (HasAttribute(Att_Enlarged))
	{
		for (i=0; i<5; i++)
		{
			if (ModReloadCount < 0.5)
			{
				diff = Float(Default.ReloadCount) * 0.1;

				// make sure we add at least one
				if (diff < 1)
					diff = 1;
					
				if (diff + ReloadCount > 255)	// Flamethrowers overflow
					diff = 255 - ReloadCount;
					
				ReloadCount += diff;
				ModReloadCount += 0.1;
			}
		}
	}
}

simulated function bool HasMaxClipMod()
{
	return (ModReloadCount >= 0.5);
}

function bool HandlePickupQuery(Inventory Item)
{
	local DeusExWeapon W;
	local DeusExPlayer player;
	local bool bResult;
	local class<Ammo> defAmmoClass;
	local Ammo defAmmo;
	local tnmGameInfo coopGame;
	local bool bCoopStayPickup;
	// make sure that if you pick up a modded weapon that you
	// already have, you get the mods
	W = DeusExWeapon(Item);

	// Co-op: world weapons stay (bCoopWeaponMode) so each player can take one.
	// Weapon.HandlePickupQuery leaves a stay pickup in the world, and the ammo
	// below was added in netgames regardless, so walking over it again refilled
	// ammo forever. Each player gets a given pickup once (see SpawnCopy).
	coopGame = tnmGameInfo(Level.Game);
	if ((W != None) && (coopGame != None) && (Level.NetMode != NM_Standalone))
		bCoopStayPickup = W.bWeaponStay && !W.bHeldItem && !W.bTossedOut;
	if (bCoopStayPickup && (W.Class == Class) && coopGame.CoopStayPickupTakenBy(W, Pawn(Owner)))
		return true;

	if ((W != None) && (W.Class == Class))
	{
		//== We should be able to use multiple copies of single-use weapons
		if(W.PickupAmmoCount == 0 && W.ReloadCount == 0 && W.AmmoName != None)
		{
			return false; //== Returning false makes it so it'll search for another slot to store a second copy of the weapon
		}
	}	
	
	// if (TNMWeapon(W) != None && TNMWeapon(W).Attribute != Att_None && TNMWeapon(W).Attribute != Attribute)
		// return false;
	
	if (TNMWeapon(W) != None && !TNMWeapon(W).HasAttribute(Att_None))
		return false;
	
	if ((W != None) && (W.Class == Class)/* && (TNMWeapon(W) == None || TNMWeapon(W).HasAttribute(Attribute))*/)
	{
		if (W.ModBaseAccuracy > ModBaseAccuracy)
			ModBaseAccuracy = W.ModBaseAccuracy;
		if (W.ModReloadCount > ModReloadCount)
			ModReloadCount = W.ModReloadCount;
		if (W.ModAccurateRange > ModAccurateRange)
			ModAccurateRange = W.ModAccurateRange;

		// these are negative
		if (W.ModReloadTime < ModReloadTime)
			ModReloadTime = W.ModReloadTime;
		if (W.ModRecoilStrength < ModRecoilStrength)
			ModRecoilStrength = W.ModRecoilStrength;

		if (W.bHasLaser)
			bHasLaser = True;
		if (W.bHasSilencer)
			bHasSilencer = True;
		if (W.bHasScope)
			bHasScope = True;

		// copy the actual stats as well
		if (W.ReloadCount > ReloadCount)
			ReloadCount = W.ReloadCount;
		if (W.AccurateRange > AccurateRange)
			AccurateRange = W.AccurateRange;
		//G-Flex: also maxrange now that the mod affects it
		if (W.MaxRange > MaxRange)
			MaxRange = W.MaxRange;

		// these are negative
		if (W.BaseAccuracy < BaseAccuracy)
			BaseAccuracy = W.BaseAccuracy;
		if (W.ReloadTime < ReloadTime)
			ReloadTime = W.ReloadTime;
		if (W.RecoilStrength < RecoilStrength)
			RecoilStrength = W.RecoilStrength;

		// if (W.Quality > Quality)
			// Quality = W.Quality;
		if (TNMWeapon(W) != None)
			NumKills += TNMWeapon(W).NumKills;
	}
	player = DeusExPlayer(Owner);

	if (Item.Class == Class/* && (TNMWeapon(W) == None || TNMWeapon(W).HasAttribute(Attribute)*/)
	{
		if (!( (Weapon(item).bWeaponStay && (Level.NetMode == NM_Standalone)) && (!Weapon(item).bHeldItem || Weapon(item).bTossedOut)))
		{
			// Only add ammo of the default type
			// There was an easy way to get 32 20mm shells, buy picking up another assault rifle with 20mm ammo selected
			if ( AmmoType != None )
			{
				// Add to default ammo only
				if ( AmmoNames[0] == None )
					defAmmoClass = AmmoName;
				else
					defAmmoClass = AmmoNames[0];

				defAmmo = Ammo(player.FindInventoryType(defAmmoClass));
				defAmmo.AddAmmo( Weapon(Item).PickupAmmoCount );

				if ( Level.NetMode != NM_Standalone )
				{
					if (( player != None ) && ( player.InHand != None ))
					{
						if ( DeusExWeapon(item).class == DeusExWeapon(player.InHand).class )
							ReadyToFire();
					}
				}
			}
		}
	}

	if ((W != None) && (W.Class == Class) && (coopGame != None) && (Level.NetMode != NM_Standalone) && W.bWeaponStay)
	{
		if (bCoopStayPickup)
			coopGame.CoopNoteStayPickupTaken(W, Pawn(Owner));
		else if (W.bTossedOut)
			W.SetRespawn();	// a dropped weapon is one item, not a stay pickup
	}

	bResult = Super(Weapon).HandlePickupQuery(Item);

	// Notify the object belt of the new ammo
	if (player != None)
		player.UpdateBeltText(Self);

	return bResult;
}

// Co-op: Weapon.SpawnCopy hands out a copy and leaves a stay pickup in the
// world. Record who took it (it goes away once every player has one); a
// dropped weapon is consumed by whoever picks it up.
function inventory SpawnCopy(pawn Other)
{
	local Inventory Copy;
	local bool bStayPickup, bTossedStay;

	bStayPickup = bWeaponStay && !bHeldItem && !bTossedOut;
	bTossedStay = bWeaponStay && bTossedOut;

	Copy = Super.SpawnCopy(Other);

	if ((Copy != self) && (Level.NetMode != NM_Standalone) && (tnmGameInfo(Level.Game) != None))
	{
		if (bStayPickup)
			tnmGameInfo(Level.Game).CoopNoteStayPickupTaken(self, Other);
		else if (bTossedStay)
			SetRespawn();
	}
	return Copy;
}

function DropFrom(vector StartLocation)
{
	checkweaponskins();

	super.dropfrom(startlocation);
}

Function CheckWeaponSkins()
{
//empty placeholder :p
}

// True only in real deathmatch games. DeusExWeapon swaps in mp* stats whenever
// NetMode != NM_Standalone, which also hit co-op (tnmGameInfo is not a DeusExMPGame).
simulated function bool IsDeathmatchStats()
{
	if (Level.NetMode == NM_Standalone)
		return False;
	if (Level.Game != None)
		return Level.Game.IsA('DeusExMPGame');
	return (DeusExPlayer(Owner) != None) && (DeusExPlayer(Owner).DXGame != None);
}

function PostBeginPlay()
{
	// DeusExWeapon.PostBeginPlay triples PickupAmmoCount in netgames
	if ((Level.NetMode != NM_Standalone) && !IsDeathmatchStats())
		bNeedToSetMPPickupAmmo = False;

	super.PostBeginPlay();

	//the blood will automatically show itself when the weapon is bloody and not in first person
	Spawn(Class'tnmWeaponBlood1',Self);
	Spawn(Class'tnmWeaponBlood2',Self);

	if(ModelClass==None)
		return;
	class'tnmUtil'.static.AttemptReplaceModel(Self,ModelClass);
	class'tnmUtil'.static.AttemptReplaceInventoryModel(Self,ModelClass, bOverwritePlayerViewMesh, bOverwritePickupViewMesh, bOverwriteThirdPersonMesh);
}

function DrawAdditionalScope(GC gc, int width, int height)
{
}

// Smoke39 - draw blood on the weapon
simulated event RenderOverlays( canvas Canvas )
{
	local rotator NewRot;
	local Rotator DrawRotation;
	local bool bPlayerOwner;
	local int Hand;
	local PlayerPawn PlayerOwner;
	local vector loc;
	/*
	if (bLasing && Emitter != None)
	{
		if (PlayerPawn(Owner) != None)
		{
			loc = Owner.Location;
			// loc = Location;
			loc.Z += Pawn(Owner).BaseEyeHeight;
			DrawRotation = Rotator(emitter.spot[0].location - loc);
			// DrawRotation = Emitter.Rotation;
			DrawRotation.Roll = Pawn(Owner).ViewRotation.Roll;
			if ( PlayerPawn(Owner).Handedness == 0 )
				DrawRotation.Roll = -2 * DrawRotation.Roll;
			else
				DrawRotation.Roll = DrawRotation.Roll * PlayerPawn(Owner).Handedness;
		}
		else
			DrawRotation = Owner.Rotation;

		SetRotation(DrawRotation);
	}
	else
	{*/
		NewRot = Pawn(Owner).ViewRotation;

		if ( Hand == 0 )
			newRot.Roll = -2 * Default.Rotation.Roll;
		else
			newRot.Roll = Default.Rotation.Roll * Hand;

		setRotation(newRot);
	// }

	// Super.RenderOverlays( Canvas );
	// Below is a copy of the Super
	if ( bHideWeapon || (Owner == None) )
		return;

	PlayerOwner = PlayerPawn(Owner);

	if ( PlayerOwner != None )
	{
		if ( PlayerOwner.DesiredFOV != PlayerOwner.DefaultFOV )
			return;
		bPlayerOwner = true;
		Hand = PlayerOwner.Handedness;

		if (  (Level.NetMode == NM_Client) && (Hand == 2) )
		{
			bHideWeapon = true;
			return;
		}
	}

	if ( !bPlayerOwner || (PlayerOwner.Player == None) )
		Pawn(Owner).WalkBob = vect(0,0,0);

	if ( (bMuzzleFlash > 0) && bDrawMuzzleFlash && Level.bHighDetailMode && (MFTexture != None) )
	{
		MuzzleScale = Default.MuzzleScale * Canvas.ClipX/640.0;
		if ( !bSetFlashTime )
		{
			bSetFlashTime = true;
			FlashTime = Level.TimeSeconds + FlashLength;
		}
		else if ( FlashTime < Level.TimeSeconds )
			bMuzzleFlash = 0;
		if ( bMuzzleFlash > 0 )
		{
			if ( Hand == 0 )
				Canvas.SetPos(Canvas.ClipX/2 - 0.5 * MuzzleScale * FlashS + Canvas.ClipX * (-0.2 * Default.FireOffset.Y * FlashO), Canvas.ClipY/2 - 0.5 * MuzzleScale * FlashS + Canvas.ClipY * (FlashY + FlashC));
			else
				Canvas.SetPos(Canvas.ClipX/2 - 0.5 * MuzzleScale * FlashS + Canvas.ClipX * (Hand * Default.FireOffset.Y * FlashO), Canvas.ClipY/2 - 0.5 * MuzzleScale * FlashS + Canvas.ClipY * FlashY);

			Canvas.Style = 3;
			Canvas.DrawIcon(MFTexture, MuzzleScale);
			Canvas.Style = 1;
		}
	}
	else
		bSetFlashTime = false;

	SetLocation( Owner.Location + CalcDrawOffset() );
	if (Trestkon(Owner) != None && Owner.Level.NetMode == NM_Client && !DeusExPlayer(Owner).bBehindView)
		SetLocation( Location + Trestkon(Owner).coopVisualSmoothOffset );
	
	Canvas.DrawActor(self, false);
	
	if (legendaryEffect != None)
	{
		legendaryEffect.SetLocation( Location );
		legendaryEffect.SetRotation( Rotation );
		Canvas.DrawActor(legendaryEffect, false);
	}

	if ( Bloodiness < 2 )
		return;
		
	// Hide blood while cloaked
	if (PlayerCloakDetected())
		return;

	Style = STY_Modulated;
	Texture = Texture'BlackMaskTex';  // foil any enviromap bits

	MultiSkins[0] = Texture'FlatFXTex2';
	MultiSkins[1] = Texture'FlatFXTex2';
	MultiSkins[2] = Texture'FlatFXTex2';

	if ( Bloodiness > 4 )
	{
		MultiSkins[0] = Texture'FlatFXTex3';
		MultiSkins[1] = Texture'FlatFXTex3';
		MultiSkins[2] = Texture'FlatFXTex3';
	}
	Canvas.DrawActor(self, false);

	Style = Default.Style;
	Texture = Default.Texture;
	MultiSkins[0] = Default.MultiSkins[0];
	MultiSkins[1] = Default.MultiSkins[1];
	MultiSkins[2] = Default.MultiSkins[2];
	
	if (Bloodiness > 0 && Rand(500) == 1)
	{
		if (PrecipitationZone(Region.Zone) != None)
			Bloodiness -= 1;
	}
}



function ServerHandleNotify( bool bInstantHit, class<projectile> ProjClass, float ProjSpeed, bool bWarn )
{
	// Remote clients send lag-compensated ServerCoopTraceHit / ServerCoopSpawnProjectile directly
	if ((Level.NetMode != NM_Standalone) && !UsesServerSideFire() && (Owner != None) && Owner.IsA('DeusExPlayer') && !DeusExPlayer(Owner).PlayerIsListenClient())
		return;

	if (bInstantHit)
		TraceFire(0.0);
	else
		ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
}

simulated function SimGenerateBullet()
{
	if ( Role < ROLE_Authority )
	{
		if (((ClipCount < ReloadCount) && (SimClipCount < ReloadCount)) || (ReloadCount == 0))
		{
			if ((ReloadCount == 0) && (AmmoType != None) && (AmmoType.AmmoAmount <= 0) && !AmmoType.IsA('AmmoNone'))
			{
				GotoState('SimFinishFire');
				return;
			}
			if ( AmmoType != None )
				AmmoType.SimUseAmmo();

			if ( bInstantHit )
				TraceFire(currentAccuracy);
			else
				ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);

			if (ReloadCount > 0)
				SimClipCount++;

			if ( !Self.IsA('WeaponFlamethrower') )
				ServerGenerateBullet();
		}
		else
			GotoState('SimFinishFire');
	}
}

function ServerGotoFinishFire()
{
	bClientReady = True;
	GotoState('FinishFire');
}

function ServerDoneReloading()
{
	ClipCount = 0;
	bClientReady = True;
}

function GenerateBullet()
{
	local bool bRemoteClient;

	bRemoteClient = ((Level.NetMode != NM_Standalone) && !UsesServerSideFire() && (Owner != None) && Owner.IsA('DeusExPlayer') && !DeusExPlayer(Owner).PlayerIsListenClient());

	if ((ReloadCount == 0) || (HasAttribute(Att_Resourceful) && FRand() <= 0.10) || (AmmoType != None && AmmoType.UseAmmo(1)))
	{
		if (!bRemoteClient || bFlameOn)
		{
			if ( bInstantHit )
				TraceFire(currentAccuracy);
			else
				ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
		}
		ClipCount++;
	}
	else
		GotoState('FinishFire');
}

//
// HandToHandAttack
// called by the MESH NOTIFY for the H2H weapons
//
simulated function HandToHandAttack()
{
	local bool bOwnerIsPlayerPawn;

	if (bOwnerWillNotify)
		return;

	// The controlling animator should be the one to do the tracefire and projfire
	if ( Level.NetMode != NM_Standalone && ScriptedPawn(Owner) == None )
	{
		bOwnerIsPlayerPawn = (DeusExPlayer(Owner) == DeusExPlayer(GetPlayerPawn()));

		if (( Role < ROLE_Authority ) && bOwnerIsPlayerPawn )
			ServerHandleNotify( bInstantHit, ProjectileClass, ProjectileSpeed, bWarnTarget );
		else if ( !bOwnerIsPlayerPawn )
			return;
	}

	if (ScriptedPawn(Owner) != None)
		ScriptedPawn(Owner).SetAttackAngle();

	if (bInstantHit)
		TraceFire(0.0);
	else
	{
		if (ProjectileAltFire(ProjectileClass, ProjectileSpeed, bWarnTarget) != None)
			if (ReloadCount > 0)
				AmmoType.UseAmmo(1);
	}

	// if we are a thrown weapon and we run out of ammo, destroy the weapon
	if ( bHandToHand && (ReloadCount > 0) && (SimAmmoAmount <= 0))
	{
		DestroyOnFinish();
		if ( Role < ROLE_Authority )
		{
			ServerGotoFinishFire();
			GotoState('SimQuickFinish');
		}
	}
}

//
// from Weapon.uc - modified so we can have the accuracy in TraceFire
//
function Fire(float Value)
{
	local float sndVolume;
	local bool bListenClient;
	local tnmzoneinfo z;

	bListenClient = (Owner.IsA('DeusExPlayer') && DeusExPlayer(Owner).PlayerIsListenClient());

	sndVolume = TransientSoundVolume;

	if ( Level.NetMode != NM_Standalone )  // Turn up the sounds a bit in mulitplayer
	{
		sndVolume = TransientSoundVolume * 2.0;
		if ( Owner.IsA('DeusExPlayer') && ((DeusExPlayer(Owner).NintendoImmunityTimeLeft > 0.01) || (!bClientReady && (!bListenClient)) ))
		{
			if (DeusExPlayer(Owner) != None)
				DeusExPlayer(Owner).bJustFired = False;
			bReadyToFire = True;
			bPointing = False;
			bFiring = False;
			return;
		}
	}
	// check for surrounding environment
	if ((EnviroEffective == ENVEFF_Air) || (EnviroEffective == ENVEFF_Vacuum) || (EnviroEffective == ENVEFF_AirVacuum))
	{
		if (Region.Zone.bWaterZone)
		{
			if (Pawn(Owner) != None)
			{
				Pawn(Owner).ClientMessage(msgNotWorking);
				if (!bHandToHand)
					PlaySimSound( Misc1Sound, SLOT_None, sndVolume, 1024 );		// play dry fire sound
			}
			GotoState('Idle');
			return;
		}
	}
	
	z=tnmzoneinfo(region.zone);
		
	// Implement Vacuum checks
	if (z != None && z.bNoOxygen)
	{
		if (EnviroEffective == ENVEFF_Air || EnviroEffective == ENVEFF_Water || EnviroEffective == ENVEFF_AirWater )
		{			
			if (Pawn(Owner) != None)
			{
				Pawn(Owner).ClientMessage(msgNeedOxygen);
				if (!bHandToHand)
					PlaySimSound( Misc1Sound, SLOT_None, sndVolume, 1024 );		// play dry fire sound
			}
			GotoState('Idle');
			return;
		}
	}

	if (bHandToHand)
	{		
		// Moved to HandToHandAttack to only happen if the grenade correctly spawns
		if (( Level.NetMode != NM_Standalone ) && !bListenClient )
			if (ReloadCount > 0)
				AmmoType.UseAmmo(1);
		
		if (( Level.NetMode != NM_Standalone ) && !bListenClient )
			bClientReady = False;
		bReadyToFire = False;
		GotoState('NormalFire');
		bPointing=True;
		if ( Owner.IsA('PlayerPawn') )
			PlayerPawn(Owner).PlayFiring();
		PlaySelectiveFiring();
		PlayFiringSound();
	}
	// if we are a single-use weapon, then our ReloadCount is 0 and we don't use ammo
	else if ((ClipCount < ReloadCount) || (ReloadCount == 0))
	{
		if ((ReloadCount == 0) || (HasAttribute(Att_Resourceful) && FRand() <= 0.10) || AmmoType.UseAmmo(1))
		{
			if (( Level.NetMode != NM_Standalone ) && !bListenClient )
				bClientReady = False;

			ClipCount++;
			bFiring = True;
			bReadyToFire = False;
			GotoState('NormalFire');
			if (( Level.NetMode == NM_Standalone ) || ( Owner.IsA('DeusExPlayer') && DeusExPlayer(Owner).PlayerIsListenClient()) )
			{
				//G-Flex: lower standing timer a bit per shot (or burst)
				if (Owner.IsA('DeusExPlayer'))
					StandingTimer = FMax(0.00,StandingTimer - FMax(0.00,(recoilStrength + GetWeaponSkill() * 2.0)) * 2.0);
				if ( PlayerPawn(Owner) != None )		// shake us based on accuracy
					PlayerPawn(Owner).ShakeView(ShakeTime, currentAccuracy * ShakeMag + ShakeMag, currentAccuracy * ShakeVert);
			}
			bPointing=True;
			if (( Level.NetMode == NM_Standalone ) || bListenClient || !Owner.IsA('DeusExPlayer') || UsesServerSideFire())
			{
				if ( bInstantHit )
					TraceFire(currentAccuracy);
				else
					ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
			}

			if ( Owner.IsA('PlayerPawn') )
				PlayerPawn(Owner).PlayFiring();
			// Don't play firing anim for 20mm
			if ( Ammo20mm(AmmoType) == None && (AmmoType == None || (AmmoType != None && !AmmoType.IsA('AmmoTNM20mm'))))
				PlaySelectiveFiring();
			PlayFiringSound();
			if ( Owner.bHidden )
				CheckVisibility();
				
			ClosedCaptions("FIRING");
		}
		else
		{
			PlaySimSound( Misc1Sound, SLOT_None, sndVolume, 1024 );		// play dry fire sound
			ClosedCaptions("DRYFIRE");
		}
	}
	else
	{
		PlaySimSound( Misc1Sound, SLOT_None, sndVolume, 1024 );		// play dry fire sound
		ClosedCaptions("DRYFIRE");
	}

	// Update ammo count on object belt
	if (DeusExPlayer(Owner) != None)
		DeusExPlayer(Owner).UpdateBeltText(Self);
		
	
	if (Trestkon(Owner) != None && Trestkon(Owner).bPlatformer && Trestkon(Owner).rh != None && Trestkon(Owner).Weapon == Self)
	{
		if (AmmoType != None && AmmoType != Class'AmmoNone' && AmmoName != Class'AmmoNone')
			Trestkon(Owner).rh.ShowRadishWeaponMessage(ItemName, string(AmmoType.AmmoAmount));
		else
			Trestkon(Owner).rh.ShowRadishWeaponMessage(ItemName, "INF");
	}
}

//
// ClientFire - Attempts to play the firing anim, sounds, and trace fire hits for instant weapons immediately
//				on the client.  The server may have a different interpretation of what actually happen, but this at least
//				cuts down on preceived lag.
//
simulated function bool ClientFire( float value )
{
	local bool bWaitOnAnim;
	local vector shake;

	// check for surrounding environment
	if ((EnviroEffective == ENVEFF_Air) || (EnviroEffective == ENVEFF_Vacuum) || (EnviroEffective == ENVEFF_AirVacuum))
	{
		if (Region.Zone.bWaterZone)
		{
			if (Pawn(Owner) != None)
			{
				Pawn(Owner).ClientMessage(msgNotWorking);
				if (!bHandToHand)
					PlaySimSound( Misc1Sound, SLOT_None, TransientSoundVolume * 2.0, 1024 );
			}
			return false;
		}
	}

	if ( !bLooping ) // Wait on animations when not looping
	{
		bWaitOnAnim = ( IsAnimating() && ((AnimSequence == 'Select') || (AnimSequence == 'Shoot') || (AnimSequence == 'ReloadBegin') || (AnimSequence == 'Reload') || (AnimSequence == 'ReloadEnd') || (AnimSequence == 'Down')));
	}
	else
	{
		bWaitOnAnim = False;
		bLooping = False;
	}

	if ( (Owner.IsA('DeusExPlayer') && (DeusExPlayer(Owner).NintendoImmunityTimeLeft > 0.01)) ||
		  (!bClientReadyToFire) || bInProcess || bWaitOnAnim )
	{
		DeusExPlayer(Owner).bJustFired = False;
		bPointing = False;
		bFiring = False;
		return false;
	}

	if (bHandToHand && (ProjectileClass != None) && (!IsA('WeaponShuriken') && !IsA('WeaponTNMShuriken')))
		ServerCoopSyncWallPlace(bNearWall, placeLocation, placeNormal, placeMover);

	if ( !IsA('WeaponFlamethrower') )
		ServerForceFire();

	if (bHandToHand)
	{
		SimAmmoAmount = AmmoType.AmmoAmount - 1;

		bClientReadyToFire = False;
		bInProcess = True;
		GotoState('ClientFiring');
		bPointing = True;
		if ( PlayerPawn(Owner) != None )
			PlayerPawn(Owner).PlayFiring();
		if (bNearWall && HasAnim('Place'))
			PlayAnim('Place',, 0.1);
		else
		{
			PlaySelectiveFiring();
			PlayFiringSound();
		}
	}
	else if (((ClipCount < ReloadCount) && (SimClipCount < ReloadCount)) || (ReloadCount == 0))
	{
		if ((ReloadCount == 0) || (AmmoType.AmmoAmount > 0))
		{
			if ((HasAttribute(Att_Resourceful) && FRand() <= 0.10) || Attribute != Att_Resourceful)
			{
				if (SimClipCount < ClipCount)
					SimClipCount = ClipCount;
				SimClipCount++;

				if ( AmmoType != None )
					AmmoType.SimUseAmmo();
			}

			bFiring = True;
			bPointing = True;
			bClientReadyToFire = False;
			bInProcess = True;
			GotoState('ClientFiring');
			if ( PlayerPawn(Owner) != None )
			{
				shake.X = 0.0;
				shake.Y = 100.0 * (ShakeTime*0.5);
				shake.Z = 100.0 * -(currentAccuracy * ShakeVert);
				PlayerPawn(Owner).ClientShake( shake );
				PlayerPawn(Owner).PlayFiring();
			}
			// Don't play firing anim for 20mm
			if ( Ammo20mm(AmmoType) == None && (AmmoType == None || (AmmoType != None && !AmmoType.IsA('AmmoTNM20mm'))))
				PlaySelectiveFiring();
			PlayFiringSound();

			if ( bInstantHit &&  ( Ammo20mm(AmmoType) == None && (AmmoType == None || (AmmoType != None && !AmmoType.IsA('AmmoTNM20mm')))))
				TraceFire(currentAccuracy);
			else
			{
				if ( !bFlameOn && IsA('WeaponFlamethrower'))
				{
					bFlameOn = True;
					StartFlame();
				}
				ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
			}
		}
		else
		{
			if ( Owner.IsA('DeusExPlayer') && DeusExPlayer(Owner).bAutoReload )
			{
				if ( MustReload() && CanReload() )
				{
					bClientReadyToFire = False;
					bInProcess = False;
					if ((AmmoType.AmmoAmount == 0) && (AmmoName != AmmoNames[0]))
						CycleAmmo();

					ReloadAmmo();
				}
			}
			PlaySimSound( Misc1Sound, SLOT_None, TransientSoundVolume * 2.0, 1024 );		// play dry fire sound
		}
	}
	else
	{
		if ( Owner.IsA('DeusExPlayer') && DeusExPlayer(Owner).bAutoReload )
		{
			if ( MustReload() && CanReload() )
			{
				bClientReadyToFire = False;
				bInProcess = False;
				if ((AmmoType.AmmoAmount == 0) && (AmmoName != AmmoNames[0]))
					CycleAmmo();
				ReloadAmmo();
			}
		}
		PlaySimSound( Misc1Sound, SLOT_None, TransientSoundVolume * 2.0, 1024 );		// play dry fire sound
	}
	return true;
}

//
// scope, laser, and targetting updates are done here
//
simulated function Tick(float deltaTime)
{
	local vector loc, point, offset;
	local rotator rota, defrot;
	local vector X, Y, Z, endtrace;
	local float beepspeed, recoil, mod, mod2, origmod;
	local DeusExPlayer player;
	local Actor RealTarget;
	local Pawn pawn;

	// Smoke39 - slowly rinse off blood while underwater
	if ( Bloodiness > 0 && region.zone.bWaterZone )
		Bloodiness = FMax( Bloodiness - deltatime/4, 0 );
	
	player = DeusExPlayer(Owner);
	pawn = Pawn(Owner);

	super(weapon).Tick(deltaTime);
	
	//WCCC, 9/24/24: Fix for alt ammo weapons.
	if (LastAmmoType == None && AmmoType != None)
		LastAmmoType = AmmoType.Class;
	
	if (TempPlayer == None)
		TempPlayer = Trestkon(GetPlayerPawn());
	
	if (!bAttributeApplied)
	{	
		if (TempPlayer != None && TempPlayer.bLegendaryMode)
		{
			RollForLegendary();
			ApplyAttribute();
					
			bAttributeApplied = True;
		}
	}
	else if (bAttributeReapply)
	{
		if (TempPlayer != None)
			ApplyAttribute();
	}
	
	if (!HasAttribute(Att_None) && legendaryEffect == None && !bDeleteMe)
		legendaryEffect = Spawn(Class'LegendaryFX',Self);
	
	if (legendaryEffect != None)
	{
		ApplyLegendaryEffect();
	}
	if (bRadishHover)
	{
		if (Owner == None)
			PrePivot.Z = CollisionHeight + (amplitude * Sin((Level.TimeSeconds % 360) * 2));
		else
			PrePivot = Default.PrePivot;
	}

	if (player != None)
	{
		if (Trestkon(player) == None || !Trestkon(player).bPlatformer)
		{
			// reduce the recoil based on skill
			recoil = recoilStrength + GetWeaponSkill() * 2.0;
			if (recoil < 0.0)
				recoil = 0.0;

			if (!bAutomatic)
			{
				// simulate recoil while firing
				if (bFiring && IsAnimating() && (AnimSequence == 'Shoot') && (recoil > 0.0) && (AnimFrame >= 0) && (AnimFrame < 0.2))
				{
					player.ViewRotation.Yaw += (deltaTime * 12.5) * (Rand(4096) - 2048) * (recoil * 0.8);
					player.ViewRotation.Pitch += (deltaTime * 12.5) * (Rand(4096) + 4096) * (recoil * 0.8);
					if ((player.ViewRotation.Pitch > 16384) && (player.ViewRotation.Pitch < 32768))
						player.ViewRotation.Pitch = 16384;
						
					//player.ViewRotation.Yaw += deltaTime * ShakeYaw * recoil * (Rand(8192) - 4096);
				}
				else if (bFiring && IsAnimating() && (AnimSequence == 'Shoot') && (recoil > 0.0) && (AnimFrame >= 0.2) && (AnimFrame < 0.4))
				{
					player.ViewRotation.Yaw += (deltaTime * 1) * (Rand(4096) - 2048) * (recoil * 1.2);
					player.ViewRotation.Pitch += (deltaTime * 1) * (Rand(4096) + 4096) * (recoil * 1.2);
					if ((player.ViewRotation.Pitch > 16384) && (player.ViewRotation.Pitch < 32768))
						player.ViewRotation.Pitch = 16384;
						
					//player.ViewRotation.Yaw += deltaTime * ShakeYaw * recoil * (Rand(8192) - 4096);
				}
			}
			else
			{
				// simulate recoil while firing
				if (bFiring && IsAnimating() && (AnimSequence == 'Shoot') && (recoil > 0.0))
				{
					player.ViewRotation.Yaw += deltaTime * (Rand(4096) - 2048) * recoil;
					player.ViewRotation.Pitch += deltaTime * (Rand(4096) + 4096) * recoil;
					if ((player.ViewRotation.Pitch > 16384) && (player.ViewRotation.Pitch < 32768))
						player.ViewRotation.Pitch = 16384;
				}
			}
		}
	}

	// don't do any of this if this weapon isn't currently in use
	if (pawn == None)
	{
		LockMode = LOCK_None;
		MaintainLockTimer = 0;
		LockTarget = None;
		LockTimer = 0;
		return;
	}

	if (pawn.Weapon != self)
	{
		LockMode = LOCK_None;
		MaintainLockTimer = 0;
		LockTarget = None;
		LockTimer = 0;
		return;
	}

	// all this should only happen IF you have ammo loaded
	if (ClipCount < ReloadCount)
	{
		// check for LAM or other placed mine placement
		if (bHandToHand && (ProjectileClass != None) && (!IsA('WeaponShuriken') && !IsA('WeaponTNMShuriken')))
		{
			if (NearWallCheck())
			{
				if (( Level.NetMode != NM_Standalone ) && IsAnimating() && (AnimSequence == 'Select'))
				{
				}
				else
				{
					if (!bNearWall || (AnimSequence == 'Select'))
					{
						if (HasAnim('PlaceBegin'))
							PlayAnim('PlaceBegin',, 0.1);
						bNearWall = True;
					}
				}
			}
			else
			{
				if (bNearWall)
				{
					if (HasAnim('PlaceEnd'))
						PlayAnim('PlaceEnd',, 0.1);
					bNearWall = False;
				}
			}
		}

		SoundTimer += deltaTime;

		if ( (Level.Netmode == NM_Standalone) || ( (Player != None) && (Player.PlayerIsClient()) ) )
		{
			if (bCanTrack)
			{
				Target = AcquireTarget();
				RealTarget = Target;

				// calculate the range
				if (Target != None)
					TargetRange = Abs(VSize(Target.Location - Location));

				// update our timers
				//SoundTimer += deltaTime;
				MaintainLockTimer -= deltaTime;

				// check target and range info to see what our mode is
				if ((Target == None) || IsInState('Reload'))
				{
					if (MaintainLockTimer <= 0)
					{
						SetLockMode(LOCK_None);
						MaintainLockTimer = 0;
						LockTarget = None;
					}
					else if (LockMode == LOCK_Locked)
					{
						Target = LockTarget;
					}
				}
				else if ((Target != LockTarget) && (Target.IsA('Pawn')) && (LockMode == LOCK_Locked))
				{
					SetLockMode(LOCK_None);
					LockTarget = None;
				}
				else if (!Target.IsA('Pawn'))
				{
					if (MaintainLockTimer <=0 )
					{
						SetLockMode(LOCK_Invalid);
					}
				}
				else if ( (Target.IsA('DeusExPlayer')) && (Target.Style == STY_Translucent) )
				{
					//DEUS_EX AMSD Don't allow locks on cloaked targets.
					SetLockMode(LOCK_Invalid);
				}
				else if ( (Target.IsA('DeusExPlayer')) && Player != None && (Player.DXGame.IsA('TeamDMGame')) && (TeamDMGame(Player.DXGame).ArePlayersAllied(Player,DeusExPlayer(Target))) )
				{
					//DEUS_EX AMSD Don't allow locks on allies.
					SetLockMode(LOCK_Invalid);
				}
				else
				{
					if (TargetRange > MaxRange)
					{
						SetLockMode(LOCK_Range);
					}
					else
					{
						// change LockTime based on skill
						// -0.7 = max skill
						// DEUS_EX AMSD Only do weaponskill check here when first checking.
						if (LockTimer == 0)
						{
							LockTime = FMax(Default.LockTime + 3.0 * GetWeaponSkill(), 0.0);
							if ((Level.Netmode != NM_Standalone) && (LockTime < 0.25))
								LockTime = 0.25;
						}

						LockTimer += deltaTime;
						if (LockTimer >= LockTime)
						{
							SetLockMode(LOCK_Locked);
						}
						else
						{
							SetLockMode(LOCK_Acquire);
						}
					}
				}

				// act on the lock mode
				switch (LockMode)
				{
					case LOCK_None:
						TargetMessage = msgNone;
						LockTimer -= deltaTime;
						break;

					case LOCK_Invalid:
						TargetMessage = msgLockInvalid;
						LockTimer -= deltaTime;
						break;

					case LOCK_Range:
						TargetMessage = msgLockRange @ Int(TargetRange/16) @ msgRangeUnit;
						LockTimer -= deltaTime;
						break;

					case LOCK_Acquire:
						TargetMessage = msgLockAcquire @ Left(String(LockTime-LockTimer), 4) @ msgTimeUnit;
						beepspeed = FClamp((LockTime - LockTimer) / Default.LockTime, 0.2, 1.0);
						if (SoundTimer > beepspeed)
						{
							Owner.PlaySound(TrackingSound, SLOT_None);
							SoundTimer = 0;
						}
						break;

					case LOCK_Locked:
						// If maintaining a lock, or getting a new one, increment maintainlocktimer
						if ((RealTarget != None) && ((RealTarget == LockTarget) || (LockTarget == None)))
						{
							if (Level.NetMode != NM_Standalone)
								MaintainLockTimer = default.MaintainLockTimer;
							else
								MaintainLockTimer = 0;
							LockTarget = Target;
						}
						TargetMessage = msgLockLocked @ Int(TargetRange/16) @ msgRangeUnit;
						// DEUS_EX AMSD Moved out so server can play it so that client knows for sure when locked.
						/*if (SoundTimer > 0.1)
						{
						Owner.PlaySound(LockedSound, SLOT_None);
						SoundTimer = 0;
						}*/
						break;
				}
			}
			else
			{
				LockMode = LOCK_None;
				TargetMessage = msgNone;
				LockTimer = 0;
				MaintainLockTimer = 0;
				LockTarget = None;
			}

			if (LockTimer < 0)
				LockTimer = 0;
		}
	}
	else
	{
		LockMode = LOCK_None;
		TargetMessage=msgNone;
		MaintainLockTimer = 0;
		LockTarget = None;
		LockTimer = 0;
	}

	if ((LockMode == LOCK_Locked) && (SoundTimer > LockonSoundRate) && (Role == ROLE_Authority))
	{
		PlayLockSound();
		SoundTimer = 0;
	}

	currentAccuracy = CalculateAccuracy();

	// if were standing still, increase the timer
	if (VSize(Owner.Velocity) < 10)
	{
		// standingTimer += deltaTime;
		if((standingTimer < 8.0) && !IsInState('Reload'))
			standingTimer += (1.20 * deltaTime);
	}
	else	// otherwise, decrease it slowly based on velocity
		standingTimer = FMax(0, standingTimer - 0.02*deltaTime*VSize(Owner.Velocity));
		// standingTimer = FMax(0, standingTimer - 0.03*deltaTime*VSize(Owner.Velocity));

	if (bLasing || bZoomed)
	{
		// shake our view to simulate poor aiming
		if (ShakeTimer > 0.25)
		{
			ShakeYaw = currentAccuracy * (Rand(4096) - 2048);
			ShakePitch = currentAccuracy * (Rand(4096) - 2048);
			ShakeTimer -= 0.25;
		}

		ShakeTimer += deltaTime;

		if ((player != None) && bZoomed)
		{
			player.ViewRotation.Yaw += deltaTime * ShakeYaw;
			player.ViewRotation.Pitch += deltaTime * ShakePitch;
		}

		if (bLasing && (Emitter != None))
		{
			loc = calcLaserOffset();
			Emitter.SetLocation(loc);


			if(bZoomed) //skip all this shit
			{
				lastlaservec = vect(10,0,0);
				newlaservec = vect(10,0,0);
				futurelaservec = vect(10,0,0);
				Emitter.Setrotation(pawn(owner).viewrotation);
			}

			else
			{
				if(!bLasingNew)
				{
					bLasingNew = true;
					if (ScriptedPawn(Owner) != None)
						Emitter.Setrotation(pawn(owner).rotation);
					else
						Emitter.Setrotation(pawn(owner).viewrotation);

					lastlaservec = vect(10,0,0);
					newlaservec = vect(10,0,0);
					futurelaservec = vect(10,0,0); //will be sorted out soon enough
					bCountlaser1 = true;
					buselaser1 = true;
					bCountlaser2 = false;
					laserupdatetimer = 0;
					laserupdatetime = 0;
					laserupdatetimer2 = 0;
					laserupdatetime2 = 0;
				}
				else  //we've established shit
				{
					//try for something a little innovative

					//and for the record, this is about the extent of my fucking trig POWA
					//so if you don't like it: FUCK YOU


					//we cycle from laser1's start to finish, transfer across to laser2's finish using
					//laser1's current vect as start, then go from laser1's final to laser2's final
					//then transfer across to laser1's new finish using laser2's current vect as start
					//and so on

					//.....in theory

					if(bCountlaser1 && buselaser1)
					{
						mod2 = laserupdatetime/laserupdatetimer;

						//mod2 = GetLaserVect(mod);


						offset = lastlaservec * mod2;
						offset += newlaservec * (1-mod2);


						if(bCountlaser2)
						{

							mod2 = laserupdatetime2/laserupdatetimer2;

							//mod2 = GetLaserVect(mod);


							offset = normal(offset)*mod2;
							offset += futurelaservec * (1-mod2);
							//offset = normal(offset);
						}
					}
					else if(bCountlaser2) //if laser1 is not counting, then everything's been shifted
					{
						mod2 = laserupdatetime2/laserupdatetimer2;

						//mod2 = GetLaserVect(mod);


						offset = lastlaservec * mod2;
						offset += newlaservec * (1-mod2);

						if(bCountlaser1)
						{
							mod2 = laserupdatetime/laserupdatetimer;

							//mod2 = GetLaserVect(mod);


							offset = normal(offset)*mod2;
							offset += futurelaservec * (1-mod2);
							//offset = normal(offset);
						}
					}

					//translate to worldspace

					offset = offset >> pawn(owner).ViewRotation;
					rota = rotator(offset);
					//add a touch of random jiggle
					rota.Yaw += Rand(5) - 2;
					rota.Pitch += Rand(5) - 2;
					Emitter.Setrotation(rotator(offset));
				}

				if(bCountlaser1)
				{
					laserupdatetime -= deltatime;

					if(laserupdatetimer > 0 && laserupdatetime/laserupdatetimer < 0.2 && !bCountlaser2)
					{
						bCountlaser2 = true;
						//pawn(owner).ClientMessage("2 count!");
					}

					if(laserupdatetime <= 0)
					{
						laserupdatetime = 0.2 + 0.4*frand();
						laserupdatetimer = laserupdatetime;

						point = GetNewLaserDir();

						if(newlaservec == vect(10,0,0))
						{
							newlaservec = point;
						}
						else   //cycle them all
						{
							bCountlaser1 = false;
							//pawn(owner).ClientMessage("1 count stop!");
							buselaser1 = false;
							lastlaservec = newlaservec;
							newlaservec = futurelaservec;
							futurelaservec = point;
						}
					}
				}
				if(bCountlaser2)
				{
					laserupdatetime2 -= deltatime;

					if(laserupdatetimer2 > 0 && laserupdatetime2/laserupdatetimer2 < 0.2 && !bCountlaser1)
					{
						bCountlaser1 = true;
						//pawn(owner).ClientMessage("1 count!");
					}

					if(laserupdatetime2 <= 0)
					{
						laserupdatetime2 = 0.2 + 0.4*frand();
						laserupdatetimer2 = laserupdatetime2;

						point = GetNewLaserDir();

						if(futurelaservec == vect(10,0,0)) //we haven't established yet
						{
							futurelaservec = point;
						}
						else //keep cycling
						{
							bCountlaser2 = false;
							//pawn(owner).ClientMessage("2 count stop!");
							buselaser1 = true;
							lastlaservec = newlaservec;
							newlaservec = futurelaservec;
							futurelaservec = point;
						}
					}
				}
			}
		}
	}
}


function vector GetNewLaserDir()
{
	local vector X,Y,Z, endtrace, point;

	X = vect(1,0,0);
	Y = vect(0,1,0);
	Z = vect(0,0,1);

	EndTrace = currentaccuracy * (FRand()-0.5)*Y*1000 + currentaccuracy * (FRand()-0.5)*Z*1000 ;
	EndTrace += FMax(1024.0, MaxRange)*X;
	point = normal(endtrace);

	return point;
}


function laseroff()
{
	super.LaserOff();
	bLasingnew = false;
}

function Vector CalcLaserOffset()
{

	local vector Offset, X, Y, Z, OffsetInit;
	local scriptedpawn P;

	if(scriptedPawn(owner) != none)
	{
		//hrmm..I'd really rather the pawn's weapon kinda pointed at the pawn's target, rather than his view rotation..
		//well, we'll see how this works for now, I guess
		// Offset = Owner.Location + CalcDrawOffset();
		Offset = Owner.Location;
		Offset.Z += Pawn(Owner).BaseEyeHeight;

	}
	else if(playerPawn(Owner) != none)
	{
		Offset = Owner.Location;
		Offset.Z += Pawn(Owner).BaseEyeHeight;
	}
	else
		Offset = location;

	return offset;

}

simulated function MakeSilenceVis();

simulated function PlayFiringSound()
{
	if (bruhSound != None)
	{
		if (bHasSilencer)
			PlaySimSound( bruhSound, SLOT_None, TransientSoundVolume / 2, 512 );
		else
			PlaySimSound( bruhSound, SLOT_None, TransientSoundVolume, 2048 );
	}
	else
	{
		if (bHasSilencer)
			PlaySimSound( FireSilencedSound, SLOT_None, TransientSoundVolume, 2048 );
		else
		{
			// The sniper rifle sound is heard to it's range in multiplayer
			if ( ( Level.NetMode != NM_Standalone ) &&  IsA('WeaponTNMRifle') )	
				PlaySimSound( FireSound, SLOT_None, TransientSoundVolume, class'WeaponRifle'.Default.mpMaxRange );
			else if (IsA('WeaponTNMRifle'))
				PlaySimSound( FireSound, SLOT_None, TransientSoundVolume, 4096 );
			else
				PlaySimSound( FireSound, SLOT_None, TransientSoundVolume, 2048 );
		}
	}
}

function LaserOn()
{
	if (bHasLaser && !bLasing)
	{
		// if we don't have an emitter, then spawn one
		// otherwise, just turn it on
		if (Emitter == None)
		{
			Emitter = Spawn(class'TNMGenericLaserEmitter', Self, , Location, Pawn(Owner).ViewRotation);
			if (Emitter != None)
			{
				Emitter.SetHiddenBeam(True);
				Emitter.AmbientSound = None;
				Emitter.TurnOn();
			}
		}
		else
			Emitter.TurnOn();

		bLasing = True;
		// ResetShake();
	}
}

// Smoke39 - wipe off some blood
function BringUp()
{
	Bloodiness = FMax( Bloodiness-1, 0 );	
	CheckWeaponSkins();
	Super.BringUp();

	// Y|yukichigai
	// activate the laser on draw, if this weapon has one
	if (bHasLaser)
		LaserOn();
}

function bool PutDown()
{
	// Y|yukichigai
	// If it's not deactivated as the weapon goes down, it's possible to get a
	//  "ghost" laser that's not attached to anything if it's not finished before
	//  the level changes.
	if(bHasLaser)
		LaserOff();
	return Super.PutDown();
}

state Idle
{
	function BeginState()
	{
		Super.BeginState();
		if (HasAttribute(Att_Luminous))
		{
			LightBrightness=224;
			LightHue=160;
			LightSaturation=255;
			LightRadius=8;
			LightType = LT_Steady;
		}
	}
}

state DownWeapon
{
ignores Fire, AltFire;

	function bool PutDown()
	{
		// alert NPCs that I'm putting away my gun
		AIEndEvent('WeaponDrawn', EAITYPE_Visual);
		return Super.PutDown();
	}
	
	function BeginState()
	{
		Super.BeginState();
		LightType = LT_None;
	}

Begin:
	ScopeOff();
	LaserOff();
	Owner.PlaySound(deselectsound, SLOT_None,,, 1024);

	if (( Level.NetMode == NM_DedicatedServer ) || ((Level.NetMode == NM_ListenServer) && Owner.IsA('DeusExPlayer') && !DeusExPlayer(Owner).PlayerIsListenClient()))
		ClientDownWeapon();

	TweenDown();
	FinishAnim();

	if ( Level.NetMode != NM_Standalone )
	{
		ClipCount = 0;	// Auto-reload in multiplayer (when putting away)
	}
	bOnlyOwnerSee = false;
	if (Pawn(Owner) != None)
		Pawn(Owner).ChangedWeapon();
}

function name WeaponDamageType()
{
	local name damageType;
	
	damageType = Super.WeaponDamageType();
	
	if (HasAttribute(Att_ArmorPiercing) && damageType == 'Shot')
		damageType = 'AutoShot';
	else if (HasAttribute(Att_Puncturing) && damageType == 'Shot')
		damageType = 'Sabot';

	return (damageType);
}

//
//	SpawnEffects - Spawns the effects like it did in single player
//
function SpawnEffects(Vector HitLocation, Vector HitNormal, Actor Other, float Damage)
{
	local TNMTraceHitSpawner hitspawner;
	local Name damageType;

	damageType = WeaponDamageType();

	if (bPenetrating)
	{
		if (bHandToHand)
		{
			hitspawner = Spawn(class'TNMTraceHitHandSpawner',Other,,HitLocation,Rotator(HitNormal));
		}
		else
		{
			hitspawner = Spawn(class'TNMTraceHitSpawner',Other,,HitLocation,Rotator(HitNormal));
		}
	}
	else
	{
		if (bHandToHand)
		{
			hitspawner = Spawn(class'TNMTraceHitHandNonPenSpawner',Other,,HitLocation,Rotator(HitNormal));
		}
		else
		{
			hitspawner = Spawn(class'TNMTraceHitNonPenSpawner',Other,,HitLocation,Rotator(HitNormal));
		}
	}
	if (hitSpawner != None)
	{
		hitspawner.HitDamage = Damage;
		hitSpawner.damageType = damageType;
	}
	spawneffectsounds(hitlocation,hitnormal,other,damage);
}

simulated function SpawnEffectSounds( Vector HitLocation, Vector HitNormal, Actor Other, float Damage )
{
	local name surfacetype;
	if (bHandToHand)
	{
		// if we are hand to hand, play an appropriate sound
		if (Other.IsA('DeusExDecoration'))
			Owner.PlayOwnedSound(hitothersound, SLOT_None,,, 1024);
		else if (Other.IsA('Pawn') || Other.IsA('carcass'))
			Owner.PlayOwnedSound(hitfleshsound, SLOT_None,,, 1024);
		else if (Other.IsA('BreakableGlass'))
			Owner.PlayOwnedSound(sound'GlassHit1', SLOT_None,,, 1024);
		else 
		{
			surfacetype = GetWallMaterial(HitLocation, HitNormal);
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
}

state pickup //removed auto
{
	function Landed(Vector HitNormal)
	{
        local rotator newRot;
		
		Super.Landed(HitNormal);
		
        newRot = Rotation;
        newRot.roll = 0;
        SetRotation(newRot);
	}
	
	function Frob(Actor Other, Inventory frobWith)
	{
		local actor A;
		local Pawn P;
		super.frob(other,frobwith);

		P = Pawn(other);
		if (Event != '')
			foreach AllActors(class 'Actor', A, Event)
				A.Trigger(Self, P);
		SetPhysics(PHYS_Interpolating);
		Velocity = vect(0,0,0);	// Prevent items with momentum from falling out of world.
	}
	function EndState()
	{
		Super.EndState();
		LightType = LT_None;
	}
}

//
// copied from Weapon.uc
//
simulated function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Vector Start, X, Y, Z;
	local DeusExProjectile proj;
	local float mult, speedMult, rangeMult, multcap;
	local float volume, radius;
	local int i, numProj;
	local Pawn aPawn;

	// tnmpcaugcombat increases our speed (distance) if hand to hand
	mult = 1.0;
	speedMult = 1.000;
	if (bHandToHand)
	{	
		if (DeusExPlayer(Owner) != None)
		{
			speedMult = DeusExPlayer(Owner).AugmentationSystem.GetAugLevelValue(class'AugCombat');
			if (speedMult == -1.0)
				speedMult = 1.0;
			else
			{
				if ( !(IsA('WeaponLAM') || IsA('WeaponEMPGrenade') || IsA('WeaponGasGrenade') || IsA('WeaponTNMLAM') || IsA('WeaponTNMEMPGrenade') || IsA('WeaponTNMGasGrenade') || IsA('WeaponMine') || IsA('WeaponPlasmaNade') || IsA('WeaponTripBomb') || IsA('WeaponMolBottle')))
					mult = speedMult;
				speedMult = (1.00 + speedMult) / 2.00;
			}
			speedMult += -1.0 * GetWeaponSkill();
		}
		else if (TNMPawn(Owner) != None)
		{
			if (TNMPawn(owner).TNMPAM != none)
				speedMult = (TNMPawn(Owner).tnmpam.getcombatvalue());
			if (speedMult == -1.0)
				speedMult = 1.0;
			else
			{
				if ( !(IsA('WeaponLAM') || IsA('WeaponEMPGrenade') || IsA('WeaponGasGrenade') || IsA('WeaponTNMLAM') || IsA('WeaponTNMEMPGrenade') || IsA('WeaponTNMGasGrenade') || IsA('WeaponMine') || IsA('WeaponPlasmaNade') || IsA('WeaponTripBomb') || IsA('WeaponMolBottle')))
					mult = speedMult;
				speedMult = (1.00 + speedMult) / 2.00;
			}
		}
	}
	rangeMult = speedMult;

	//G-Flex: range mod previously did nothing for projectiles
	//G-Flex: the game says range mods work on plasma rifles/flamethrowers, so let's make it so
	//G-Flex: fireballs in particular need to go faster to go further, which makes sense
	//G-Flex: don't do as much for the minicrossbow or whatever else
	if (HasRangeMod())
	{
		rangeMult += ModAccurateRange;
		if (IsA('WeaponTNMPlasmaRifle') || IsA('WeaponTNMFlamethrower') || IsA('WeaponFireStaff'))
			speedMult += ModAccurateRange;
	}
	
	ProjSpeed *= speedMult;

	// skill also affects our damage
	// GetWeaponSkill returns 0.0 to -0.7 (max skill/aug)
	mult += -2.0 * GetWeaponSkill();
			
	if (HasAttribute(Att_Lucky) && FRand() <= 0.1)
	{
		mult *= 3.0;
		Owner.PlaySound(Sound'TNM.CriticalHit', SLOT_Misc);
	}
	if (HasAttribute(Att_Desperate) && Owner != None)
	{
		multcap = Pawn(Owner).Default.Health / Pawn(Owner).Health;
		multcap = Clamp(multcap, 1, 5);
		mult *= multcap;
	}

	// make noise if we are not silenced
	if (!bHasSilencer && !bHandToHand)
	{
		GetAIVolume(volume, radius);
		Owner.AISendEvent('WeaponFire', EAITYPE_Audio, volume, radius);
		Owner.AISendEvent('LoudNoise', EAITYPE_Audio, volume, radius);
		if (!Owner.IsA('PlayerPawn'))
			Owner.AISendEvent('Distress', EAITYPE_Audio, volume, radius);
	}

	// should we shoot multiple projectiles in a spread?
	if (AreaOfEffect == AOE_Cone || katanaLevel >= 5)
		numProj = 3;
	else
		numProj = 1;
		
	if (HasAttribute(Att_DoubleBarreled))
		numProj++;

	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	Start = ComputeProjectileStart(X, Y, Z);

	for (i=0; i<numProj; i++)
	{
		// If we have multiple slugs, then lower our accuracy a bit after the first slug so the slugs DON'T all go to the same place
		if ((i > 0) && IsDeathmatchStats())
			if (currentAccuracy < MinProjSpreadAcc)
				currentAccuracy = MinProjSpreadAcc;

		AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
		AdjustedAim.Yaw += currentAccuracy * (Rand(1024) - 512);
		AdjustedAim.Pitch += currentAccuracy * (Rand(1024) - 512);


		if (( Level.NetMode == NM_Standalone ) || ( Owner.IsA('DeusExPlayer') && DeusExPlayer(Owner).PlayerIsListenClient()) )
		{
			proj = DeusExProjectile(Spawn(ProjClass, Owner,, Start, AdjustedAim));
			if (proj != None)
			{
				//  increases our damage as well
				proj.Damage *= mult;					
				if (TNMProjectile(proj) != None)
					TNMProjectile(proj).ownerWeapon = Self;
				if (i > 0) // Prevent duplicating darts
					proj.spawnAmmoClass = None;
				
				//G-Flex: actually use the new projectile speed (ProjSpeed / proj.Default.Speed)
				proj.Speed *= speedMult;
				proj.MaxSpeed *= speedMult;
				proj.Velocity *= speedMult;
				//G-Flex: travel further since we're faster
				proj.MaxRange *= rangeMult;
				proj.AccurateRange *= rangeMult;

				// send the targetting information to the projectile
				if (bCanTrack && (LockTarget != None) && (LockMode == LOCK_Locked))
				{
					proj.Target = LockTarget;
					proj.bTracking = True;
					if (HasAttribute(Att_Tracking))
					{
						proj.RotationRate.Pitch = 32768;
						proj.RotationRate.Yaw = 32768;
						proj.AccurateRange = 24000;
						proj.MaxRange = 24000;
						proj.bFixedRotationDir = False;
					}
				}
				if (HasAttribute(Att_Intense))
				{
					proj.blastRadius *= 2;
				}
				if (HasAttribute(Att_Swift))
				{
					proj.Speed *= 2;
					proj.MaxSpeed *= 2;
				}
				if (TNMProjectile(proj) != None)
				{
					if (HasAttribute(Att_Pinpoint))
						TNMProjectile(proj).Att_Pinpoint = True;
					if (HasAttribute(Att_Incendiary))
						TNMProjectile(proj).Att_Incendiary = True;
					if (HasAttribute(Att_Penetrative))
						TNMProjectile(proj).Att_Penetrative = True;
					if (HasAttribute(Att_Irritating))
						TNMProjectile(proj).Att_Irritating = True;
					if (HasAttribute(Att_Gaseous))
						TNMProjectile(proj).Att_Gaseous = True;
					if (HasAttribute(Att_Lamar))
						TNMProjectile(proj).Att_Lamar = True;
					if (HasAttribute(Att_00n))
						TNMProjectile(proj).Att_00n = True;
					if (HasAttribute(Att_Narcissian))
						TNMProjectile(proj).Att_Narcissian = True;
					if (HasAttribute(Att_Hunter))
						TNMProjectile(proj).Att_Hunter = True;
					if (HasAttribute(Att_Technophobic))
						TNMProjectile(proj).Att_Technophobic = True;
					if (HasAttribute(Att_LowTech))
						TNMProjectile(proj).Att_LowTech = True;
					if (HasAttribute(Att_Junkie))
						TNMProjectile(proj).Att_Junkie = True;
					if (HasAttribute(Att_Quaking))
						TNMProjectile(proj).Att_Quaking = True;
					if (HasAttribute(Att_Immolative))
						TNMProjectile(proj).Att_Immolative = True;
					if (HasAttribute(Att_Embiggening))
						TNMProjectile(proj).Att_Embiggening = True;
					if (HasAttribute(Att_Phreaking))
						TNMProjectile(proj).Att_Phreaking = True;
					if (HasAttribute(Att_Messy))
						TNMProjectile(proj).Att_Messy = True;
				}
			}
		}
		else
		{
			if (( Role == ROLE_Authority ) || (DeusExPlayer(Owner) == DeusExPlayer(GetPlayerPawn())) )
			{
				if ((Role < ROLE_Authority) && !UsesServerSideFire() && (DeusExPlayer(Owner) == DeusExPlayer(GetPlayerPawn())))
					ServerCoopSpawnProjectile(ProjClass, Start, AdjustedAim, (i == 0), (i > 0));

				// Do it the old fashioned way if it can track, or if we are a projectile that we could pick up again
				if ( IsCoopReplicatedProjectile() )
				{
					if ( Role == ROLE_Authority )
					{
						proj = DeusExProjectile(Spawn(ProjClass, Owner,, Start, AdjustedAim));
						if (proj != None)
						{
							ConfigureServerProjectile(proj, mult, speedMult, rangeMult, (i > 0));
						}
					}
				}
				else
				{
					proj = DeusExProjectile(Spawn(ProjClass, Owner,, Start, AdjustedAim));
					if (proj != None)
					{
						if (TNMProjectile(proj) != None)
							TNMProjectile(proj).ownerWeapon = Self;
						proj.RemoteRole = ROLE_None;
						// tnmpcaugcombat increases our damage as well
						if ( Role == ROLE_Authority )
						{
							ConfigureServerProjectile(proj, mult, speedMult, rangeMult, (i > 0));
							proj.RemoteRole = ROLE_None;
						}
						else
						{
							proj.Damage = 0;
							proj.Speed *= speedMult;
							proj.MaxSpeed *= speedMult;
							proj.Velocity *= speedMult;
							proj.MaxRange *= rangeMult;
							proj.AccurateRange *= rangeMult;
							if (HasAttribute(Att_Swift))
							{
								proj.Speed *= 2;
								proj.MaxSpeed *= 2;
								proj.Velocity *= 2;
							}
						}
					}
					if ( Role == ROLE_Authority )
					{
						for ( aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.nextPawn )
						{
							if ( aPawn.IsA('DeusExPlayer') && ( DeusExPlayer(aPawn) != DeusExPlayer(Owner) ))
								DeusExPlayer(aPawn).ClientSpawnProjectile( ProjClass, Owner, Start, AdjustedAim );
						}
					}
				}
			}
		}

	}
	return proj;
}

function ConfigureServerProjectile(DeusExProjectile proj, float mult, float speedMult, float rangeMult, bool bExtraSlug)
{
	if (proj == None)
		return;

	proj.Damage *= mult;
	if (TNMProjectile(proj) != None)
		TNMProjectile(proj).ownerWeapon = Self;
	if (bExtraSlug)
		proj.spawnAmmoClass = None;

	proj.Speed *= speedMult;
	proj.MaxSpeed *= speedMult;
	proj.Velocity *= speedMult;
	proj.MaxRange *= rangeMult;
	proj.AccurateRange *= rangeMult;

	if (bCanTrack && (LockTarget != None) && (LockMode == LOCK_Locked))
	{
		proj.Target = LockTarget;
		proj.bTracking = True;
		if (HasAttribute(Att_Tracking))
		{
			proj.RotationRate.Pitch = 32768;
			proj.RotationRate.Yaw = 32768;
			proj.AccurateRange = 24000;
			proj.MaxRange = 24000;
			proj.bFixedRotationDir = False;
		}
	}
	if (HasAttribute(Att_Intense))
		proj.blastRadius *= 2;
	if (HasAttribute(Att_Swift))
	{
		proj.Speed *= 2;
		proj.MaxSpeed *= 2;
		proj.Velocity *= 2;
	}
	if (TNMProjectile(proj) != None)
	{
		if (HasAttribute(Att_Pinpoint))
			TNMProjectile(proj).Att_Pinpoint = True;
		if (HasAttribute(Att_Incendiary))
			TNMProjectile(proj).Att_Incendiary = True;
		if (HasAttribute(Att_Penetrative))
			TNMProjectile(proj).Att_Penetrative = True;
		if (HasAttribute(Att_Irritating))
			TNMProjectile(proj).Att_Irritating = True;
		if (HasAttribute(Att_Gaseous))
			TNMProjectile(proj).Att_Gaseous = True;
		if (HasAttribute(Att_Lamar))
			TNMProjectile(proj).Att_Lamar = True;
		if (HasAttribute(Att_00n))
			TNMProjectile(proj).Att_00n = True;
		if (HasAttribute(Att_Narcissian))
			TNMProjectile(proj).Att_Narcissian = True;
		if (HasAttribute(Att_Hunter))
			TNMProjectile(proj).Att_Hunter = True;
		if (HasAttribute(Att_Technophobic))
			TNMProjectile(proj).Att_Technophobic = True;
		if (HasAttribute(Att_LowTech))
			TNMProjectile(proj).Att_LowTech = True;
		if (HasAttribute(Att_Junkie))
			TNMProjectile(proj).Att_Junkie = True;
		if (HasAttribute(Att_Quaking))
			TNMProjectile(proj).Att_Quaking = True;
		if (HasAttribute(Att_Immolative))
			TNMProjectile(proj).Att_Immolative = True;
		if (HasAttribute(Att_Embiggening))
			TNMProjectile(proj).Att_Embiggening = True;
		if (HasAttribute(Att_Phreaking))
			TNMProjectile(proj).Att_Phreaking = True;
		if (HasAttribute(Att_Messy))
			TNMProjectile(proj).Att_Messy = True;
	}
	if (IsA('WeaponEMPGrenade') || IsA('WeaponNanoVirusGrenade') || IsA('WeaponTNMEMPGrenade'))
	{
		if (proj.HasAnim('Open'))
			proj.PlayAnim('Open');
	}
}

function ServerCoopSpawnProjectile(class<projectile> ProjClass, Vector ClientStart, Rotator ClientAim, bool bFirstProj, bool bExtraSlug)
{
	local DeusExProjectile proj;
	local float mult, speedMult, rangeMult, multcap, volume, radius;
	local Vector X, Y, Z, Start;
	local Pawn aPawn;

	if ((Role != ROLE_Authority) || (Owner == None) || (Pawn(Owner) == None) || (ProjClass == None))
		return;

	mult = 1.0;
	speedMult = 1.000;
	if (bHandToHand)
	{
		if (DeusExPlayer(Owner) != None)
		{
			speedMult = DeusExPlayer(Owner).AugmentationSystem.GetAugLevelValue(class'AugCombat');
			if (speedMult == -1.0)
				speedMult = 1.0;
			else
			{
				if ( !(IsA('WeaponLAM') || IsA('WeaponEMPGrenade') || IsA('WeaponGasGrenade') || IsA('WeaponTNMLAM') || IsA('WeaponTNMEMPGrenade') || IsA('WeaponTNMGasGrenade') || IsA('WeaponMine') || IsA('WeaponPlasmaNade') || IsA('WeaponTripBomb') || IsA('WeaponMolBottle')))
					mult = speedMult;
				speedMult = (1.00 + speedMult) / 2.00;
			}
			speedMult += -1.0 * GetWeaponSkill();
		}
	}
	rangeMult = speedMult;

	if (HasRangeMod())
	{
		rangeMult += ModAccurateRange;
		if (IsA('WeaponTNMPlasmaRifle') || IsA('WeaponTNMFlamethrower') || IsA('WeaponFireStaff'))
			speedMult += ModAccurateRange;
	}

	mult += -2.0 * GetWeaponSkill();
	if (HasAttribute(Att_Lucky) && FRand() <= 0.1)
	{
		mult *= 3.0;
		Owner.PlaySound(Sound'TNM.CriticalHit', SLOT_Misc);
	}
	if (HasAttribute(Att_Desperate) && Pawn(Owner).Health > 0)
	{
		multcap = Pawn(Owner).Default.Health / Pawn(Owner).Health;
		multcap = Clamp(multcap, 1, 5);
		mult *= multcap;
	}

	if (bFirstProj && !bHasSilencer && !bHandToHand)
	{
		GetAIVolume(volume, radius);
		Owner.AISendEvent('WeaponFire', EAITYPE_Audio, volume, radius);
		Owner.AISendEvent('LoudNoise', EAITYPE_Audio, volume, radius);
	}

	Start = ClientStart;
	if (VSize(Start - Owner.Location) > 600.0)
	{
		GetAxes(ClientAim, X, Y, Z);
		Start = ComputeProjectileStart(X, Y, Z);
	}

	if ( IsCoopReplicatedProjectile() )
	{
		proj = DeusExProjectile(Spawn(ProjClass, Owner,, Start, ClientAim));
		if (proj != None)
			ConfigureServerProjectile(proj, mult, speedMult, rangeMult, bExtraSlug);
	}
	else
	{
		proj = DeusExProjectile(Spawn(ProjClass, Owner,, Start, ClientAim));
		if (proj != None)
		{
			ConfigureServerProjectile(proj, mult, speedMult, rangeMult, bExtraSlug);
			proj.RemoteRole = ROLE_None;
		}
		for ( aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.nextPawn )
		{
			if ( aPawn.IsA('DeusExPlayer') && ( DeusExPlayer(aPawn) != DeusExPlayer(Owner) ))
				DeusExPlayer(aPawn).ClientSpawnProjectile( ProjClass, Owner, Start, ClientAim );
		}
	}
}
simulated function Projectile ProjectileAltFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Vector Start, X, Y, Z;
	local DeusExProjectile proj;
	local float mult;
	local float volume, radius;
	local int i, numProj;
	local Pawn aPawn;

	// tnmpcaugcombat increases our speed (distance) if hand to hand
	mult = 1.0;
	if (bHandToHand)
	{
		if (DeusExPlayer(Owner) != None)
			mult = DeusExPlayer(Owner).AugmentationSystem.GetAugLevelValue(class'tnmpcaugcombat');
		else if (TNMPawn(Owner) != None)
			if (TNMPawn(owner).TNMPAM != none)
				mult = (TNMPawn(Owner).tnmpam.getcombatvalue());
		if (mult == -1.0)
			mult = 1.0;
		ProjSpeed *= mult;
	}

	// skill also affects our damage
	// GetWeaponSkill returns 0.0 to -0.7 (max skill/aug)
	mult += -2.0 * GetWeaponSkill();

	// make noise if we are not silenced
	if (!bHasSilencer && !bHandToHand)
	{
		GetAIVolume(volume, radius);
		Owner.AISendEvent('WeaponFire', EAITYPE_Audio, volume, radius);
		Owner.AISendEvent('LoudNoise', EAITYPE_Audio, volume, radius);
		if (!Owner.IsA('PlayerPawn'))
			Owner.AISendEvent('Distress', EAITYPE_Audio, volume, radius);
	}

	// should we shoot multiple projectiles in a spread?
	if (AreaOfEffect == AOE_Cone || katanaLevel >= 5)
		numProj = 3;
	else
		numProj = 1;

	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	Start = ComputeProjectileStart(X, Y, Z);

	for (i=0; i<numProj; i++)
	{
		// If we have multiple slugs, then lower our accuracy a bit after the first slug so the slugs DON'T all go to the same place
		if ((i > 0) && IsDeathmatchStats())
			if (currentAccuracy < MinProjSpreadAcc)
				currentAccuracy = MinProjSpreadAcc;

		AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
		AdjustedAim.Yaw += currentAccuracy * (Rand(1024) - 512);
		AdjustedAim.Pitch += currentAccuracy * (Rand(1024) - 512);


		if (( Level.NetMode == NM_Standalone ) || ( Owner.IsA('DeusExPlayer') && DeusExPlayer(Owner).PlayerIsListenClient()) )
		{
			proj = DeusExProjectile(Spawn(ProjClass, Owner,, Start, AdjustedAim));
			if (proj != None)
			{
				//  increases our damage as well
				proj.Damage *= mult;

				// send the targetting information to the projectile
				if (bCanTrack && (LockTarget != None) && (LockMode == LOCK_Locked))
				{
					proj.Target = LockTarget;
					proj.bTracking = True;
				}
			}
		}
		else
		{
			if (( Role == ROLE_Authority ) || (DeusExPlayer(Owner) == DeusExPlayer(GetPlayerPawn())) )
			{
				if ((Role < ROLE_Authority) && !UsesServerSideFire() && (DeusExPlayer(Owner) == DeusExPlayer(GetPlayerPawn())))
					ServerCoopSpawnProjectile(ProjClass, Start, AdjustedAim, (i == 0), (i > 0));

				// Do it the old fashioned way if it can track, or if we are a projectile that we could pick up again
				if ( IsCoopReplicatedProjectile() )
				{
					if ( Role == ROLE_Authority )
					{
						proj = DeusExProjectile(Spawn(ProjClass, Owner,, Start, AdjustedAim));
						if (proj != None)
						{
							ConfigureServerProjectile(proj, mult, 1.0, 1.0, (i > 0));
						}
					}
				}
				else
				{
					proj = DeusExProjectile(Spawn(ProjClass, Owner,, Start, AdjustedAim));
					if (proj != None)
					{
						proj.RemoteRole = ROLE_None;
						// tnmpcaugcombat increases our damage as well
						if ( Role == ROLE_Authority )
						{
							ConfigureServerProjectile(proj, mult, 1.0, 1.0, (i > 0));
							proj.RemoteRole = ROLE_None;
						}
						else
							proj.Damage = 0;
					}
					if ( Role == ROLE_Authority )
					{
						for ( aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.nextPawn )
						{
							if ( aPawn.IsA('DeusExPlayer') && ( DeusExPlayer(aPawn) != DeusExPlayer(Owner) ))
								DeusExPlayer(aPawn).ClientSpawnProjectile( ProjClass, Owner, Start, AdjustedAim );
						}
					}
				}
			}
		}

	}
	
	return proj;
}


simulated function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local float        mult;
	local name         damageType;
	local DeusExPlayer dxPlayer;
	local bool 			bWasBurning;
	local incinerator	fire;
	local vector 		loc;
	local SphereEffect sphere;
	local ShockRing ring;
	local float			multcap;		

	if (Other != None)
	{
		// tnmpcaugcombat increases our damage if hand to hand
		mult = 1.0;
		if (bHandToHand)
		{
			if (DeusExPlayer(Owner) != None)
				mult = DeusExPlayer(Owner).AugmentationSystem.GetAugLevelValue(class'tnmpcaugcombat');
			else if (TNMPawn(Owner) != None)
				if (TNMPawn(owner).TNMPAM != none)
					mult = (TNMPawn(Owner).tnmpam.getcombatvalue());
			if (mult == -1.0)
				mult = 1.0;
		}

		// skill also affects our damage
		// GetWeaponSkill returns 0.0 to -0.7 (max skill/aug)
		mult += -2.0 * GetWeaponSkill();

		//G-Flex: compensate for sabot at the end
		if ((AmmoType != None) && AmmoType.IsA('AmmoSabot'))
			mult *= 5.000;
			
		if (Trestkon(Owner) != None && Trestkon(Owner).bQuadDamage)
			mult *= 4.0;
			
		if (Trestkon(Owner) != None && Trestkon(Owner).bDoubleDamage)
			mult *= 2.0;
			
		if (HasAttribute(Att_Lucky) && FRand() <= 0.1)
		{
			mult *= 3.0;
			Owner.PlaySound(Sound'TNM.CriticalHit', SLOT_Misc);
		}
			
		if (HasAttribute(Att_Desperate) && Owner != None)
		{
			multcap = Pawn(Owner).Default.Health / Pawn(Owner).Health;
			multcap = Clamp(multcap, 1, 5);
			mult *= multcap;
		}

		// Determine damage type
		damageType = WeaponDamageType();

		if (Other != None)
		{
			if (Other.bOwned)
			{
				dxPlayer = DeusExPlayer(Owner);
				if (dxPlayer != None)
					dxPlayer.AISendEvent('Futz', EAITYPE_Visual);
			}
			
			if (IsA('WeaponFists') && DamageType == 'FistEMP' && (Other.IsA('HackableDevices') || Other.IsA('AutoTurret')))
				DamageType = 'EMP';
			if (DamageType == 'EMP' && AutoTurretGun(Other) != None) // EMP fist turrets
				ProcessTraceHit(Other.Owner, Other.Owner.Location, Other.Owner.Location, X, Y, Z);
				
			if ( Role == ROLE_Authority && HasAttribute(Att_Incendiary))
			{
				loc = HitLocation + HitNormal;
				fire = spawn(class'incinerator', Owner,, loc);
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
			else if ( Role == ROLE_Authority && HasAttribute(Att_Explosive))
			{
				sphere = Spawn(class'SphereEffect',,, HitLocation);
				if (sphere != None)
					sphere.size = FMin(HitDamage * mult * 1.75, 25 * mult * 1.75) / 32.0;
				ring = Spawn(class'ShockRing',,, HitLocation, Rotator(HitNormal));
				if (ring != None)
				{
					ring.RemoteRole = ROLE_None;
					ring.size = FMin(HitDamage * mult * 1.75, 25 * mult * 1.75) / 32.0;
				}
				TNMHurtRadius(HitDamage * mult * 5.0, FMin(HitDamage * mult * 1.75, 25 * mult * 1.75), 'Exploded', HitDamage*mult*1000.0, HitLocation);
			}
		}

		if ((Other == Level) || (Other.IsA('Mover')))
		{
			if ( Role == ROLE_Authority && HasAttribute(Att_Dismantling))
				Other.TakeDamage(HitDamage * mult * 5, Pawn(Owner), HitLocation, 1000.0*X, damageType);
			else if ( Role == ROLE_Authority )
				Other.TakeDamage(HitDamage * mult, Pawn(Owner), HitLocation, 1000.0*X, damageType);

			SelectiveSpawnEffects( HitLocation, HitNormal, Other, HitDamage * mult);
		}
		else if ((Other != self) && (Other != Owner))
		{
			if ( Role == ROLE_Authority && HasAttribute(Att_Pinpoint))
				Other.TakeDamage(1, Pawn(Owner), HitLocation, 1000.0*X, 'headstun');
		
			if ( Role == ROLE_Authority && (HasAttribute(Att_Lamar) || HasAttribute(Att_Narcissian)) && (Other.IsA('GenericGoat') || Other.IsA('Athena') || Other.IsA('DarkTemplar')) )
				Other.TakeDamage(HitDamage * mult * 2, Pawn(Owner), HitLocation, 1000.0*X, damageType);
			else if ( Role == ROLE_Authority && (HasAttribute(Att_00n) || HasAttribute(Att_Narcissian)) && (Other.IsA('GenericLlama') || Other.IsA('Beefman') || Other.IsA('Abomnation') || Other.IsA('SD')) ) // skip Hobbes
				Other.TakeDamage(HitDamage * mult * 2, Pawn(Owner), HitLocation, 1000.0*X, damageType);				
			else if ( Role == ROLE_Authority && (HasAttribute(Att_Hunter)) && (Other.IsA('TNMGreasel') || Other.IsA('RedGreasel') || Other.IsA('TNMKarkian') || Other.IsA('TNMGray')) )
				Other.TakeDamage(HitDamage * mult * 2, Pawn(Owner), HitLocation, 1000.0*X, damageType);		
			else if ( Role == ROLE_Authority && (HasAttribute(Att_Technophobic)) && (Other.IsA('Robot')) )
				Other.TakeDamage(HitDamage * mult * 2, Pawn(Owner), HitLocation, 1000.0*X, damageType);		
			else if ( Role == ROLE_Authority && (HasAttribute(Att_LowTech)) && (TNMPawn(Other) != None && TNMPawn(Other).bAugmented) )
				Other.TakeDamage(HitDamage * mult * 2, Pawn(Owner), HitLocation, 1000.0*X, damageType);				
			else if ( Role == ROLE_Authority && (HasAttribute(Att_Junkie)) && (DeusExPlayer(Owner) != None && DeusExPlayer(Owner).DrugEffectTimer > 0) )
				Other.TakeDamage(HitDamage * mult * 2, Pawn(Owner), HitLocation, 1000.0*X, damageType);			
			else if ( Role == ROLE_Authority && (HasAttribute(Att_Augmented)) && (DeusExPlayer(Owner) != None) )
				Other.TakeDamage(HitDamage * mult * (1 + (DeusExPlayer(Owner).AugmentationSystem.NumAugsActive() * 0.2)), Pawn(Owner), HitLocation, 1000.0*X, damageType);				
			else if ( Role == ROLE_Authority )
				Other.TakeDamage(HitDamage * mult, Pawn(Owner), HitLocation, 1000.0*X, damageType);
				
			if ( Role == ROLE_Authority && HasAttribute(Att_Crazed) && Robot(Other) != None)
				Other.TakeDamage(HitDamage * mult * 10, Pawn(Owner), HitLocation, 1000.0*X, 'NanoVirus');	
			else if ( Role == ROLE_Authority && HasAttribute(Att_Frying) && Robot(Other) != None)
				Other.TakeDamage(HitDamage * mult, Pawn(Owner), HitLocation, 1000.0*X, 'EMP');		
			else if ( Role == ROLE_Authority && HasAttribute(Att_Blinding))
				Other.TakeDamage(HitDamage * mult, Pawn(Owner), HitLocation, 1000.0*X, 'TearGas');		
			else if ( Role == ROLE_Authority && HasAttribute(Att_Paralyzing))
				Other.TakeDamage(HitDamage * mult, Pawn(Owner), HitLocation, 1000.0*X, 'Stunned');	
			else if ( Role == ROLE_Authority && HasAttribute(Att_Embiggening))
				Other.TakeDamage(HitDamage * mult, Pawn(Owner), HitLocation, 1000.0*X, 'Fat');		
			else if ( Role == ROLE_Authority && HasAttribute(Att_Venomous))
				Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, 1000.0*X, 'Poison');		
			else if ( Role == ROLE_Authority && HasAttribute(Att_Leeching) && DeusExPlayer(Owner) != None && ScriptedPawn(Other) != None && ScriptedPawn(Other).Health <= 0)
				DeusExPlayer(Owner).HealPlayer(/*Max(HitDamage / 5, 1)*/HitDamage, false);
			else if ( Role == ROLE_Authority && HasAttribute(Att_Energized) && DeusExPlayer(Owner) != None && ScriptedPawn(Other) != None && ScriptedPawn(Other).Health <= 0)
				DeusExPlayer(Owner).ChargePlayer(5);
			else if ( Role == ROLE_Authority && HasAttribute(Att_Phreaking) && HackableDevices(Other) != None)
				Other.TakeDamage(HitDamage * mult, Pawn(Owner), HitLocation, 1000.0*X, 'EMP');	
			else if ( Role == ROLE_Authority && HasAttribute(Att_Painful) && ScriptedPawn(Other) != None)
				ScriptedPawn(Other).TakeHitTimer = 0;
			else if ( Role == ROLE_Authority && HasAttribute(Att_Immolative) && (ScriptedPawn(Other) != None || PlayerPawn(Other) != None))
			{
				if (ScriptedPawn(Other) != None)
					bWasBurning = ScriptedPawn(Other).bOnFire;
				Other.TakeDamage(1, Pawn(Owner), HitLocation, 1000.0*X, 'Flamed');	
				if (ScriptedPawn(Other) != None)
				{
					if (ScriptedPawn(Other).bOnFire && !bWasBurning)
						ScriptedPawn(Other).burnTimer += ScriptedPawn(Other).burnTimer * 0.8;
				}
			}
			if (HasAttribute(Att_Messy) && ScriptedPawn(Other) != None && ScriptedPawn(Other).Health <= 0)
				ScriptedPawn(Other).Health = -200;

			//if (bHandToHand) //Lork: Enable spawn effects for ranged weapons so we can hear the missing armor ricochet sound
				SelectiveSpawnEffects( HitLocation, HitNormal, Other, HitDamage * mult);
				
			if (Trestkon(Owner) != None && Trestkon(Owner).bQuadDamage && ScriptedPawn(Other) != None)
				Owner.PlaySound(Sound'TNM.BulletTimeStart', SLOT_Misc);

			// Smoke39 - become bloody if appropriate
			if ((Other.IsA('scriptedPawn')) && (!Other.IsA('Robot')) && (scriptedpawn(other).bCanBleed) && !Other.IsInState('StunnedTemporal'))
			{
				if ( bPenetrating )
				{
					SpawnBlood(HitLocation, HitNormal);
					if ( bGetsBloody )
						Bloodiness = FMin( Bloodiness + 1, 8 );
				}
				else if ( bGetsBloody )
					Bloodiness = FMin( Bloodiness + 0.5, 8 );
			}
			else if ( Other.IsA('Carcass') && bGetsBloody )
			{
				if ( bPenetrating )
					Bloodiness = FMin( Bloodiness + 1, 8 );
				else
					Bloodiness = FMin( Bloodiness + 0.5, 8 );
			}
		}
	}

	if (DeusExMPGame(Level.Game) != None)
	{
		if (DeusExPlayer(Other) != None)
			DeusExMPGame(Level.Game).TrackWeapon(self,HitDamage * mult);
		else
			DeusExMPGame(Level.Game).TrackWeapon(self,0);
	}

	if ((TNMPawn(Other) != None && TNMPawn(Other).Health <= 0 && !TNMPawn(Other).bDeathCounted/* && !TNMPawn(Other).bInsignificant*/) || (Trestkon(Other) != None && Trestkon(Other).Health <= 0))
	{
		numKills++;
		// if (Trestkon(Owner) != None)
			// Trestkon(Owner).numKills++;
		// else if (TNMPawn(Owner) != None)
			// TNMPawn(Owner).numKills++;
		if (TNMPawn(Other) != None)
			TNMPawn(Other).bDeathCounted = True;
		
		if (HasAttribute(Att_Faithful) && numKills <= 50 && numKills % 10 == 0)
		{
			katanaLevel++;
			if (Trestkon(Owner) != None)
				Trestkon(Owner).ClientMessage("Weapon level increased!");
			PlaySound(Sound'TNM.Weapons.FirestaffReload');
		}	
	}
}



// ----------------------------------------------------------------------
// UpdateInfo()
// ----------------------------------------------------------------------

simulated function bool UpdateInfo(Object winObject)
{
	local PersonaInventoryInfoWindow winInfo;
	local string str;
	local int i, dmg, basedmg;
	local float mod;
	local bool bHasAmmo;
	local bool bAmmoAvailable;
	local class<DeusExAmmo> ammoClass;
	local Pawn P;
	local Ammo weaponAmmo;
	local int  ammoAmount;
	
	//G-Flex: storing this makes the DTS change easier to manage here
	local int numSlugs;
	
	local name nameQuality;
	local string strTitle;
	local Color itemColor;

	P = Pawn(Owner);
	if (P == None)
		return False;

	winInfo = PersonaInventoryInfoWindow(winObject);
	if (winInfo == None)
		return False;
		
	strTitle = legendaryNames;

	// winInfo.winTitle.SelectedItem = Self;
	// winInfo.SetTitle(itemName, nameQuality, strTitle);
	if (strTitle != "" && itemNameShort != "")
		winInfo.SetTitle(strTitle $ Default.itemNameShort);
	else
		winInfo.SetTitle(strTitle $ Default.itemName);
	winInfo.SetText(msgInfoWeaponStats);
	winInfo.AddLine();
	if (!HasAttribute(Att_None))
	{
		itemColor = GetAttributeColor();
		winInfo.winTitle.SetTextColor(itemColor);
	}
	else if (bUniqueWeapon)
	{
		itemColor.R = 165;
		itemColor.G = 15;
		itemColor.B = 121;
		winInfo.winTitle.SetTextColor(itemColor);
	}
	else
		winInfo.winTitle.SetTextColor(winInfo.colText);

	// Create the ammo buttons.  Start with the AmmoNames[] array,
	// which is used for weapons that can use more than one 
	// type of ammo.

	if (AmmoNames[0] != None)
	{
		for (i=0; i<ArrayCount(AmmoNames); i++)
		{
			if (AmmoNames[i] != None) 
			{
				// Check to make sure the player has this ammo type
				// *and* that the ammo isn't empty
				weaponAmmo = Ammo(P.FindInventoryType(AmmoNames[i]));

				if (weaponAmmo != None)
				{
					ammoAmount = weaponAmmo.AmmoAmount;
					bHasAmmo = (weaponAmmo.AmmoAmount > 0);
				}
				else
				{
					ammoAmount = 0;
					bHasAmmo = False;
				}

				winInfo.AddAmmo(AmmoNames[i], bHasAmmo, ammoAmount);
				bAmmoAvailable = True;

				if (AmmoNames[i] == AmmoName)
				{
					winInfo.SetLoaded(AmmoName);
					ammoClass = class<DeusExAmmo>(AmmoName);
				}
			}
		}
	}
	else
	{
		// Now peer at the AmmoName variable, but only if the AmmoNames[] 
		// array is empty
		if ((AmmoName != class'AmmoNone') && (!bHandToHand) && (ReloadCount != 0))
		{	
			weaponAmmo = Ammo(P.FindInventoryType(AmmoName));

			if (weaponAmmo != None)
			{
				ammoAmount = weaponAmmo.AmmoAmount;
				bHasAmmo = (weaponAmmo.AmmoAmount > 0);
			}
			else
			{
				ammoAmount = 0;
				bHasAmmo = False;
			}

			winInfo.AddAmmo(AmmoName, bHasAmmo, ammoAmount);
			winInfo.SetLoaded(AmmoName);
			ammoClass = class<DeusExAmmo>(AmmoName);
			bAmmoAvailable = True;
		}
	}

	// Only draw another line if we actually displayed ammo.
	if (bAmmoAvailable)
		winInfo.AddLine();	

	// Ammo loaded
	if ((AmmoName != class'AmmoNone') && (!bHandToHand) && (ReloadCount != 0))
		winInfo.AddAmmoLoadedItem(msgInfoAmmoLoaded, AmmoType.itemName);

	// ammo info
	if ((AmmoName == class'AmmoNone') || bHandToHand || (ReloadCount == 0))
		str = msgInfoNA;
	else
		str = AmmoName.Default.ItemName;
	for (i=0; i<ArrayCount(AmmoNames); i++)
		if ((AmmoNames[i] != None) && (AmmoNames[i] != AmmoName))
			str = str $ "|n" $ AmmoNames[i].Default.ItemName;

	winInfo.AddAmmoTypesItem(msgInfoAmmo, str);

	// base damage
	//G-Flex: account for change to number of DTS "slugs"
	//G-Flex: also clean up the code a bit in light of this
	// if (bInstantHit && Ammo20mm(AmmoType) == None && numInstantProjectiles != 0) 
		// numSlugs = numInstantProjectiles;
	// else if ((!bInstantHit || Ammo20mm(AmmoType) != None) && numProjectiles != 0) 
		// numSlugs = numProjectiles;
	/*else*/ if (AreaOfEffect == AOE_Cone || katanaLevel >= 5)
	{
		if (bInstantHit)
		{
			if (String(Class.Name) == "WeaponNanoSword")
				numSlugs = 2;
			else
			{
				if (AmmoType != None && AmmoNone(AmmoType) != None)
					numSlugs = 3;	// Melee
				else
					numSlugs = 5;	// Shotgun
			}
		}
		else
		{
			if (IsA('WeaponPlasmaRifle'))
				numSlugs = 2;
			else
				numSlugs = 3;
		}
	}
	else
	{
		numSlugs = 1;
	}
	
	if (IsDeathmatchStats())
	{
		/*
		if (ProjectileClass != None)
			basedmg = Class<DeusExProjectile>(ProjectileClass).Default.mpDamage; // * numSlugs;
		else
		*/
			basedmg = Default.mpHitDamage; // * numSlugs;
	}
	else
	{
		if (ProjectileClass != None)
			basedmg = ProjectileClass.Default.Damage; // * numSlugs;
		else
			basedmg = Default.HitDamage; // * numSlugs;
	}
	
	if (AmmoType.IsA('AmmoSabot'))
	{
		basedmg *= 5; // Compensate for the sabot damage
		numSlugs = 1;
	}

	str = String(basedmg);
	
	//G-Flex: display the correct damage bonus
	if (IsDeathmatchStats())
		dmg = Default.mpHitDamage * numSlugs;
	else
	{
		if (ProjectileClass != None)
			dmg = ProjectileClass.Default.Damage * numSlugs;
		else
			dmg = Default.HitDamage * numSlugs;
	}
	
	if (AmmoType.IsA('AmmoSabot'))
	{
		dmg *= 5; // Compensate for the sabot damage
	}
	
	mod = 1.0 - (2.0 * GetWeaponSkill());
	if (mod != 1.0)
	{
		str = str @ BuildPercentString(mod - 1.0);
		if (NumSlugs > 1 && !AmmoType.IsA('AmmoSabot')) // Sabot forces it to one slug
			str = str @ "(x" $ String(numSlugs) $ ")";
		str = str @ "=" @ FormatFloatString(dmg * mod, 1.0);
	}
	else/* if (str != String(basedmg))*/
	{
		if (NumSlugs > 1 && !AmmoType.IsA('AmmoSabot')) // Sabot forces it to one slug
		{
			str = str @ "(x" $ String(numSlugs) $ ")";
			str = str @ "=" @ String(dmg);
		}
	}

	winInfo.AddInfoItem(msgInfoDamage, str, (mod != 1.0));

	// clip size
	if ((Default.ReloadCount == 0) || bHandToHand)
		str = msgInfoNA;
	else
	{
		if ( IsDeathmatchStats() )
		{
			// if ((AmmoType != class'AmmoNone') && (!bHandToHand) && (mpReloadCount != 0))
			// {
				// if (mpReloadCount == 1)
					// str = Default.mpReloadCount @ Caps(DeusExAmmo(AmmoType).AmmoRoundNameLongSing);
				// else
					// str = Default.mpReloadCount @ Caps(DeusExAmmo(AmmoType).AmmoRoundNameLong);
			// }
			// else
				str = Default.mpReloadCount @ msgInfoRounds;
		}
		else
		{
			// if ((AmmoType != class'AmmoNone') && (!bHandToHand) && (ReloadCount != 0))
			// {
				// if (ReloadCount == 1)
					// str = Min(Default.ReloadCount, AmmoType.MaxAmmo) @ Caps(DeusExAmmo(AmmoType).AmmoRoundNameLongSing); // Display the smaller value, as the clip size for the elite rifle is bigger than the max ammo for 20mm.
				// else
					// str = Min(Default.ReloadCount, AmmoType.MaxAmmo) @ Caps(DeusExAmmo(AmmoType).AmmoRoundNameLong);
			// }
			// else
				str = Default.ReloadCount @ msgInfoRounds;
		}
	}

	if (HasClipMod())
	{
		str = str @ "(+" $ ReloadCount - Default.ReloadCount $ ")";
		// str = str @ BuildPercentString(ModReloadCount);
		// if ((AmmoType != class'AmmoNone') && (!bHandToHand) && (ReloadCount != 0))
			// str = str @ "=" @ Min(ReloadCount, AmmoType.MaxAmmo) @ Caps(DeusExAmmo(AmmoType).AmmoRoundNameLong);
		// else
			str = str @ "=" @ ReloadCount @ msgInfoRounds;
	}

	winInfo.AddInfoItem(msgInfoClip, str, HasClipMod());

	// rate of fire
	if ((Default.ReloadCount == 0) || bHandToHand)
	{
		str = msgInfoNA;
	}
	else
	{
		if (bAutomatic)
			str = msgInfoAuto;
		else
			str = msgInfoSingle;

		// if ((AmmoType != class'AmmoNone') && (!bHandToHand) && (ReloadCount != 0))
			// str = str $ "," @ FormatFloatString(1.0/Default.ShotTime, 0.1) @ Caps(DeusExAmmo(AmmoType).AmmoRoundNameShort)$msgInfoPerSec;
		// else
			str = str $ "," @ FormatFloatString(1.0 / /*Default.*/ShotTime, 0.1) @ msgInfoRoundsPerSec;
	}
	winInfo.AddInfoItem(msgInfoROF, str, ShotTime != Default.ShotTime);

	// reload time
	if ((Default.ReloadCount == 0) || bHandToHand)
		str = msgInfoNA;
	else
	{
		if (IsDeathmatchStats() )
			str = FormatFloatString(Default.mpReloadTime, 0.1) @ msgTimeUnit;
		else
			str = FormatFloatString(Default.ReloadTime, 0.1) @ msgTimeUnit;
	}

	if (HasReloadMod() || (GetWeaponSkill() < 0.0 && str != msgInfoNA))
	{
		str = str @ BuildPercentString(ModReloadTime + (GetWeaponSkill() * ReloadTime/Default.ReloadTime));
		str = str @ "=" @ FormatFloatString(ReloadTime * (1.0 + GetWeaponSkill()), 0.1) @ msgTimeUnit;
	}

	winInfo.AddInfoItem(msgInfoReload, str, (HasReloadMod() || (GetWeaponSkill() < 0.0 && (Default.ReloadCount > 0 && !bHandToHand))));

	// recoil
	str = FormatFloatString(Default.recoilStrength, 0.01);
	if (HasRecoilMod() || (GetWeaponSkill() < 0.0 && Default.recoilStrength > 0.0))
	{
		str = str @ BuildPercentString(ModRecoilStrength + (GetWeaponSkill() * 2.0 * recoilStrength/Default.recoilStrength));
		str = str @ "=" @ FormatRecoilString(recoilStrength * (1.0 + (GetWeaponSkill() * 2.0)), 0.1);
	}

	winInfo.AddInfoItem(msgInfoRecoil, str, (HasRecoilMod() || (GetWeaponSkill() < 0.0 && Default.recoilStrength > 0.0)));

	// base accuracy (2.0 = 0%, 0.0 = 100%)
	if ( IsDeathmatchStats() )
	{
		str = Int((2.0 - Default.mpBaseAccuracy)*50.0) $ "%";
		mod = (Default.mpBaseAccuracy - (BaseAccuracy + GetWeaponSkill())) * 0.5;
		if (mod != 0.0)
		{
			str = str @ BuildPercentString(mod);
			str = str @ "=" @ Min(100, Int(100.0*mod+(2.0 - Default.mpBaseAccuracy)*50.0)) $ "%";
		}
	}
	else
	{
		str = Int((2.0 - Default.BaseAccuracy)*50.0) $ "%";
		mod = (Default.BaseAccuracy - (BaseAccuracy + GetWeaponSkill())) * 0.5;
		if (mod != 0.0)
		{
			str = str @ BuildPercentString(mod);
			str = str @ "=" @ Min(100, Int(100.0*mod+(2.0 - Default.BaseAccuracy)*50.0)) $ "%";
		}
	}
	winInfo.AddInfoItem(msgInfoAccuracy, str, (mod != 0.0));

	// accurate range
	if (bHandToHand)
		str = msgInfoNA;
	else
	{
		if ( IsDeathmatchStats() )
			str = FormatFloatString(Default.mpAccurateRange/16.0, 1.0) @ msgRangeUnit;
		else
			str = FormatFloatString(Default.AccurateRange/16.0, 1.0) @ msgRangeUnit;
	}

	if (HasRangeMod())
	{
		str = str @ BuildPercentString(ModAccurateRange);
		str = str @ "=" @ FormatFloatString(AccurateRange/16.0, 1.0) @ msgRangeUnit;
	}
	winInfo.AddInfoItem(msgInfoAccRange, str, HasRangeMod());

	// max range
	if (bHandToHand)
		str = msgInfoNA;
	else
	{
		if ( IsDeathmatchStats() )
			str = FormatFloatString(Default.mpMaxRange/16.0, 1.0) @ msgRangeUnit;
		else
			str = FormatFloatString(Default.MaxRange/16.0, 1.0) @ msgRangeUnit;
	}
	//G-Flex: now affected by mod
	if (HasRangeMod() && !bInstantHit)
	{
		str = str @ BuildPercentString(ModAccurateRange);
		str = str @ "=" @ FormatFloatString(MaxRange*(1+ModAccurateRange)/16.0, 1.0) @ msgRangeUnit; // Range mod doesn't affect this for instant hit weapons but does for projectiles. Doing it this way as the mod is a vanilla class.
	}
	winInfo.AddInfoItem(msgInfoMaxRange, str, HasRangeMod() && !bInstantHit);

	// kills
	if ((!HasAttribute(Att_None)/* || (Human(P) != None && Human(P).bWeaponKillStats)*/) && !IsHarmless())
	{
		if (IsNonLethal())
			winInfo.AddInfoItem(strKnockouts, FormatFloatString(numKills, 1.0));
		else
			winInfo.AddInfoItem(strKills, FormatFloatString(numKills, 1.0));
	}

	// mass
	// winInfo.AddInfoItem(msgInfoMass, FormatFloatString(/*Default.*/Mass, 1.0) @ msgMassUnit);
	
	str = FormatFloatString(Default.Mass, 1.0);
	mod = -1 + (Mass / Default.Mass);
	if (mod != 0.0)
	{
		str = str @ BuildPercentString(mod);
		str = str @ "=" @ int(Mass) @ msgMassUnit;
		winInfo.AddInfoItem(msgInfoMass, str, Mass != Default.Mass);
	}
	else
	{
		winInfo.AddInfoItem(msgInfoMass, str @ msgMassUnit);
	}

	// laser mod
	if (bCanHaveLaser)
	{
		if (bHasLaser)
			str = msgInfoYes;
		else
			str = msgInfoNo;
	}
	else
	{
		str = msgInfoNA;
	}
	winInfo.AddInfoItem(msgInfoLaser, str, bCanHaveLaser && bHasLaser && (Default.bHasLaser != bHasLaser));

	// scope mod
	if (bCanHaveScope)
	{
		if (bHasScope)
			str = msgInfoYes;
		else
			str = msgInfoNo;
	}
	else
	{
		str = msgInfoNA;
	}
	winInfo.AddInfoItem(msgInfoScope, str, bCanHaveScope && bHasScope && (Default.bHasScope != bHasScope));

	// silencer mod
	if (bCanHaveSilencer)
	{
		if (bHasSilencer)
			str = msgInfoYes;
		else
			str = msgInfoNo;
	}
	else
	{
		str = msgInfoNA;
	}
	winInfo.AddInfoItem(msgInfoSilencer, str, bCanHaveSilencer && bHasSilencer && (Default.bHasSilencer != bHasSilencer));

	// Governing Skill
	if (GoverningSkill != None)
		winInfo.AddInfoItem(msgInfoSkill, GoverningSkill.default.SkillName);

	if (!HasAttribute(Att_None))
	{
		for (i=1;i<ArrayCount(possibleAttributes);i++)
		{
			if (HasAttributeInt(i))
			{
				winInfo.AddLine();
				winInfo.SetText(AttributeName[i] $ ":");
				if (i == 58)
					winInfo.SetText(sprintf(AttributeDesc[i], katanaLevel));
				else
					winInfo.SetText(AttributeDesc[i]);
			}
		}
	}

	winInfo.AddLine();
	winInfo.SetText(Description);

	// If this weapon has ammo info, display it here
	if (ammoClass != None)
	{
		winInfo.AddLine();
		winInfo.AddAmmoDescription(ammoClass.Default.ItemName $ "|n" $ ammoClass.Default.description);
	}

	return True;
}

// ----------------------------------------------------------------------
// FormatRecoilString()
// The value is already lower than 1 so you don't need to do much formatting
// ----------------------------------------------------------------------

simulated function String FormatRecoilString(float value, float precision)
{
	local string str, str2;

	if (precision == 0.0)
		return "ERR";

	// build integer part
	str = String(Int(value));

	// build decimal part
	if (precision < 1.0)
	{
		value -= Int(value);
		str2 = String(((0.5 * precision) + value * (1.0 / precision)));
		str = str $ "." $ str2;
	}
	if (value < 1)
	{
		if (value == 0.0)
			return Left(String(value), 3); // 0.0
		else
		{
			if (Mid(String(value), 5, 1) == "0")
				return Left(String(value), 4); // 0.12
			else
				return Left(String(value), 5); // 0.123
		}
	}
	else 
		return str; // 1.234?
}

//
// used to place a grenade on the wall
//
function PlaceGrenade()
{
	local ThrownProjectile gren;
	local float dmgX;

	gren = ThrownProjectile(spawn(ProjectileClass, Owner,, placeLocation, placeNormal));
	if (gren != None)
	{
		AmmoType.UseAmmo(1);
		if ( AmmoType.AmmoAmount <= 0 )
			bDestroyOnFinish = True;

		if (gren.HasAnim('Open'))
			gren.PlayAnim('Open');
		gren.PlaySound(gren.MiscSound, SLOT_None, 0.5+FRand()*0.5,, 512, 0.85+FRand()*0.3);
		gren.SetPhysics(PHYS_None);
		gren.bBounce = False;
		gren.bProximityTriggered = True;
		gren.bStuck = True;
		if (placeMover != None)
			gren.SetBase(placeMover);
			
		// if (TNMProjectile(gren) != None)
			// TNMProjectile(gren).ownerWeapon = Self;

		// up the damage based on the skill
		// returned value from GetWeaponSkill is negative, so negate it to make it positive
		// dmgX value ranges from 1.0 to 2.4 (max demo skill and max target aug)
		dmgX = -2.0 * GetWeaponSkill() + 1.0;
		gren.Damage *= dmgX;

		// Update ammo count on object belt
		if (DeusExPlayer(Owner) != None)
			DeusExPlayer(Owner).UpdateBeltText(Self);
	}
}

simulated function ScopeToggle()
{
	//G-Flex: toggle the scope unless we're reloading
	//G-Flex: if reloading, toggle whether it comes back
	if (bHasScope && (Owner != None) && Owner.IsA('DeusExPlayer'))
	{
		if (IsInState('Reload') || IsInState('DownWeapon'))
		{
			bWasZoomed = !bWasZoomed;
		}
		else
		{
			if (bZoomed)
				ScopeOff();
			else
				ScopeOn();
		}
	}
}

function bool PlayerCloakDetected()
{
	local Augmentation TAug;

	if (Trestkon(Owner) == None) 
		return false;

	return Trestkon(Owner).bCloaked;
}

function bool PlayerTransDetected()
{
	local Augmentation TAug;

	if (Trestkon(Owner) == None) 
		return false;

	return Trestkon(Owner).bRadarCloaked;
}

//
// Used to determine if we are near (and facing) a wall for placing LAMs, etc.
//
simulated function bool NearWallCheck()
{
	local Vector StartTrace, EndTrace, HitLocation, HitNormal;
	local Actor HitActor;

	// Scripted pawns can't place LAMs
	if (ScriptedPawn(Owner) != None)
		return False;

	// Don't let players place grenades when they have something highlighted
	if ( Level.NetMode != NM_Standalone )
	{
		if ( Owner.IsA('DeusExPlayer') && (DeusExPlayer(Owner).frobTarget != None) )
		{
			if ( DeusExPlayer(Owner).IsFrobbable( DeusExPlayer(Owner).frobTarget ) )
				return False;
		}
	}

	// trace out one foot in front of the pawn
	StartTrace = Owner.Location;
	if (IsA('WeaponMine'))
		EndTrace = StartTrace + Vector(Pawn(Owner).ViewRotation) * 64; // Was 32, increased to place grenades on floor
	else
		EndTrace = StartTrace + Vector(Pawn(Owner).ViewRotation) * 36; // Was 32, increased to place grenades on floor

	StartTrace.Z += Pawn(Owner).BaseEyeHeight;
	EndTrace.Z += Pawn(Owner).BaseEyeHeight;

	HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace);
	if (((HitActor == Level) || ((HitActor != None) && HitActor.IsA('Mover'))) && ((IsA('WeaponMine') && (HitNormal.Z ~= 1)) || !IsA('WeaponMine')))
	{
		placeLocation = HitLocation;
		placeNormal = Rotator(HitNormal);
		// If on a flat surface, rotate to the player's view.
		if ((placeNormal.Pitch > 14000 && placeNormal.Pitch < 18000) || (placeNormal.Pitch < -14000 && placeNormal.Pitch > -18000))
		{
			placeNormal.Yaw = Owner.Rotation.Yaw;
			placeNormal.Roll = 32768;
		}
		placeMover = Mover(HitActor);
		
		//WCCC, 8/27/24: Backup trick for fixing when mover hits return level. Sticks better.
		if ((HitActor == Level) && (Trestkon(Owner) != None) && (Trestkon(Owner).LastMoverFrobTarget != None))
		{
			PlaceMover = Trestkon(Owner).LastMoverFrobTarget;
		}
		return True;
	}

	return False;
}

state NormalFire
{
	function AnimEnd()
	{
		if (bAutomatic || (AmmoType != None && AmmoType.IsA('AmmoNone')))
		{
			if (Trestkon(Owner) != None && Trestkon(Owner).bPlatformer && (ReloadCount > 0) && (AmmoType.AmmoAmount <= 0))
			{
				bWasZoomed = False;
				if(bZoomed)
					ScopeOff();
				if(bHasLaser)
					LaserOff();
				Destroy();
				return;
			}
			if ((Pawn(Owner) != None) && (Pawn(Owner).bFire != 0) && (AmmoType.AmmoAmount > 0 || (AmmoType != None && AmmoType.IsA('AmmoNone'))))
			{
				if (PlayerPawn(Owner) != None)
					Global.Fire(0);
				else
					GotoState('FinishFire');
			}
			else
				GotoState('FinishFire');
		}
		else
		{
			// if we are a thrown weapon and we run out of ammo, destroy the weapon
			if (bHandToHand && (ReloadCount > 0) && (AmmoType.AmmoAmount <= 0))
			{
				bWasZoomed = False;
				if(bZoomed)
					ScopeOff();
				if(bHasLaser)
					LaserOff();
				Destroy();
				return;
			}
		}
		
		if (Trestkon(Owner) != None && Trestkon(Owner).bPlatformer && (ReloadCount > 0) && (AmmoType.AmmoAmount <= 0))
		{
			bWasZoomed = False;
			if(bZoomed)
				ScopeOff();
			if(bHasLaser)
				LaserOff();
			Destroy();
			return;
		}
	}
	function float GetShotTime()
	{
		local float mult, sTime;

		if (ScriptedPawn(Owner) != None)
		{
			mult = 1.0;			
			if (bHandToHand)
			{
				if (TNMPawn(owner) != none && TNMPawn(owner).TNMPAM != none)
					mult = (TNMPawn(Owner).tnmpam.getcombatvalue());
				if (mult == -1.0)
					mult = 1.0;
			}
			sTime = ShotTime * (ScriptedPawn(Owner).BaseAccuracy*2+1);
			if (TNMPawn(Owner) != None)
			{
				if (TNMPawn(Owner).localPlayer != None)
				{
					if (TNMPawn(Owner).localPlayer.bNightmareMode)
						sTime = ShotTime / 2;
				}
				else
					TNMPawn(Owner).GetPlayer();
			}
			sTime = sTime / mult;
			return sTime;
		}
		else
		{
			// tnmpcaugcombat decreases shot time
			mult = 1.0;
			if (bHandToHand)
			{
				if (DeusExPlayer(Owner) != None)
					mult = DeusExPlayer(Owner).AugmentationSystem.GetAugLevelValue(class'tnmpcaugcombat');
				else if (TNMPawn(Owner) != None)
				if (mult == -1.0)
					mult = 1.0;
			}
			sTime = ShotTime / mult;
			return (sTime);
		}
	}

Begin:
	if ((ClipCount >= ReloadCount) && (ReloadCount != 0))
	{
		// Account for recoil during last shot (don't immediately stop animating and leave state)
		while(IsAnimating() && AnimFrame < 0.4)
			Sleep(0.01);
		if (!bAutomatic)
		{
			bFiring = False;
			FinishAnim();
		}

		if (Owner != None)
		{
			if (Owner.IsA('DeusExPlayer'))
			{
				bFiring = False;

				// should we autoreload?
				if (DeusExPlayer(Owner).bAutoReload)
				{
					// auto switch ammo if we're out of ammo and
					// we're not using the primary ammo
					if ((!busefiremode) && (AmmoType.AmmoAmount == 0) && (AmmoName != AmmoNames[0]))
						CycleAmmo();
					ReloadAmmo();
				}
				else
				{
					if (bHasMuzzleFlash)
						EraseMuzzleFlashTexture();
					GotoState('Idle');
				}
			}
			else if (Owner.IsA('ScriptedPawn'))
			{
				bFiring = False;
				ReloadAmmo();
			}
		}
		else
		{
			if (bHasMuzzleFlash)
				EraseMuzzleFlashTexture();
			GotoState('Idle');
		}
	}
	if ( bAutomatic && (( Level.NetMode == NM_DedicatedServer ) || ((Level.NetMode == NM_ListenServer) && Owner.IsA('DeusExPlayer') && !DeusExPlayer(Owner).PlayerIsListenClient())))
		GotoState('Idle');

	Sleep(GetShotTime());
	if (bAutomatic)
	{
		GenerateBullet();	// In multiplayer bullets are generated by the client which will let the server know when
		Goto('Begin');
	}
	bFiring = False;
	FinishAnim();

	// if ReloadCount is 0 and we're not hand to hand, then this is a
	// single-use weapon so destroy it after firing once
	if ((ReloadCount == 0) && !bHandToHand)
	{
		if (DeusExPlayer(Owner) != None)
			DeusExPlayer(Owner).RemoveItemFromSlot(Self);   // remove it from the inventory grid
		
		bWasZoomed = False;
		if(bZoomed)
			ScopeOff();
		if(bHasLaser)
			LaserOff();
		
		Destroy();
	}
	ReadyToFire();
Done:
	bFiring = False;
	Finish();
}

state FinishFire
{
Begin:
	bFiring = False;
	if ( bDestroyOnFinish )
	{
		bWasZoomed = False;
		if(bZoomed)
			ScopeOff();
		if(bHasLaser)
			LaserOff();
		
		Destroy();		
	}
	else
		Finish();
}

simulated state ClientFiring
{
	simulated function AnimEnd()
	{
		bInProcess = False;

		if (bAutomatic || (AmmoType != None && AmmoType.IsA('AmmoNone')))
		{
			if ((Pawn(Owner).bFire != 0) && (AmmoType.AmmoAmount > 0 || (AmmoType != None && AmmoType.IsA('AmmoNone'))))
			{
				if (PlayerPawn(Owner) != None)
					ClientReFire(0);
				else
					GotoState('SimFinishFire');
			}
			else
				GotoState('SimFinishFire');
		}
	}
	simulated function float GetSimShotTime()
	{
		local float mult, sTime;

		if (ScriptedPawn(Owner) != None)
			return ShotTime * (ScriptedPawn(Owner).BaseAccuracy*2+1);
		else
		{
			// tnmpcaugcombat decreases shot time
			mult = 1.0;
			if (bHandToHand)
			{
				if (DeusExPlayer(Owner) != None)
					mult = DeusExPlayer(Owner).AugmentationSystem.GetAugLevelValue(class'tnmpcaugcombat');
				else if (TNMPawn(Owner) != None)
					if (TNMPawn(owner).TNMPAM != none)
						mult = (TNMPawn(Owner).tnmpam.getcombatvalue());
				if (mult == -1.0)
					mult = 1.0;
			}
			sTime = ShotTime / mult;
			return (sTime);
		}
	}
Begin:
	if (((ClipCount >= ReloadCount) || (SimClipCount >= ReloadCount)) && (ReloadCount != 0))
	{
		if (!bAutomatic)
		{
			bFiring = False;
			FinishAnim();
		}
		if (Owner != None)
		{
			if (Owner.IsA('DeusExPlayer'))
			{
				bFiring = False;
				if (DeusExPlayer(Owner).bAutoReload)
				{
					bClientReadyToFire = False;
					bInProcess = False;
					if ((!busefiremode) && (AmmoType.AmmoAmount == 0) && (AmmoName != AmmoNames[0]))
						CycleAmmo();
					ReloadAmmo();
					GotoState('SimQuickFinish');
				}
				else
				{
					if (bHasMuzzleFlash)
						EraseMuzzleFlashTexture();
					IdleFunction();
					GotoState('SimQuickFinish');
				}
			}
			else if (Owner.IsA('ScriptedPawn'))
			{
				bFiring = False;
			}
		}
		else
		{
			if (bHasMuzzleFlash)
				EraseMuzzleFlashTexture();
			IdleFunction();
			GotoState('SimQuickFinish');
		}
	}
	Sleep(GetSimShotTime());
	if (bAutomatic)
	{
		SimGenerateBullet();
		Goto('Begin');
	}
	bFiring = False;
	FinishAnim();
	bInProcess = False;
Done:
	bInProcess = False;
	bFiring = False;
	SimFinish();
}

simulated function SimFinish()
{
	ServerGotoFinishFire();

	bInProcess = False;
	bFiring = False;

	if ( bFlameOn )
	{
		StopFlame();
		bFlameOn = False;
	}

	if (bHasMuzzleFlash)
		EraseMuzzleFlashTexture();

	if ( Owner != None && Owner.IsA('DeusExPlayer') && DeusExPlayer(Owner).bAutoReload )
	{
		if ( ((SimClipCount >= ReloadCount) || (ClipCount >= ReloadCount)) && CanReload() && (ReloadCount != 0) )
		{
			SimClipCount = 0;
			bClientReadyToFire = False;
			bInProcess = False;
			if ((AmmoType.AmmoAmount == 0) && (AmmoName != AmmoNames[0]))
				CycleAmmo();
			ReloadAmmo();
			return;
		}
	}

	// Unlock local client firing immediately after local ShotTime + FinishAnim
	// so 250ms-500ms RTT does not jam semi-auto or melee clicks
	bClientReadyToFire = True;

	if (Pawn(Owner) == None)
	{
		GotoState('SimIdle');
		return;
	}
	if ( PlayerPawn(Owner) == None )
	{
		if ( (Pawn(Owner).bFire != 0) && (FRand() < RefireRate) )
			ClientReFire(0);
		else
			GotoState('SimIdle');
		return;
	}
	if ( Pawn(Owner).bFire != 0 )
		ClientReFire(0);
	else
		GotoState('SimIdle');
}

simulated state SimReload
{
ignores Fire, AltFire, ClientFire, ClientReFire;

	simulated function float GetSimReloadTime()
	{
		local float val;

		val = ReloadTime;

		if (ScriptedPawn(Owner) != None)
		{
			val = ReloadTime * (ScriptedPawn(Owner).BaseAccuracy*2+1);
		}
		else if (DeusExPlayer(Owner) != None)
		{
			val = GetWeaponSkill();
			val = ReloadTime + (val*ReloadTime);
		}
		return val;
	}
Begin:
	if ( bWasInFiring )
	{
		if (bHasMuzzleFlash)
			EraseMuzzleFlashTexture();
		FinishAnim();
	}
	bInProcess = False;
	bFiring = False;

	bWasZoomed = bZoomed;
	if (bWasZoomed)
		ScopeOff();

	Owner.PlaySound(CockingSound, SLOT_None,,, 1024);
	if (HasAnim('ReloadBegin'))
		PlayAnim('ReloadBegin');
	FinishAnim();
	if (HasAnim('Reload'))
		LoopAnim('Reload');
	Sleep(GetSimReloadTime());
	Owner.PlaySound(AltFireSound, SLOT_None,,, 1024);
	ServerDoneReloading();
	SimClipCount = 0;
	ClipCount = 0;
	if (HasAnim('ReloadEnd'))
		PlayAnim('ReloadEnd');
	FinishAnim();

	if (bWasZoomed)
		ScopeOn();

	bClientReadyToFire = True;
	bInProcess = False;
	GotoState('SimIdle');
}




state FlameThrowerOn
{
	function float GetShotTime()
	{
		local float mult, sTime;

		if (ScriptedPawn(Owner) != None)
			return ShotTime * (ScriptedPawn(Owner).BaseAccuracy*2+1);
		else
		{
			// tnmpcaugcombat decreases shot time
			mult = 1.0;
			if (bHandToHand)
			{
				if (DeusExPlayer(Owner) != None)
					mult = DeusExPlayer(Owner).AugmentationSystem.GetAugLevelValue(class'tnmpcaugcombat');
				else if (TNMPawn(Owner) != None)
					if (TNMPawn(owner).TNMPAM != none)
						mult = (TNMPawn(Owner).tnmpam.getcombatvalue());
				if (mult == -1.0)
					mult = 1.0;
			}
			sTime = ShotTime * mult;
			return (sTime);
		}
	}
Begin:
	if ( (DeusExPlayer(Owner).Health > 0) && bFlameOn && (ClipCount < ReloadCount))
	{
		if (( flameShotCount == 0 ) && (Owner != None))
		{
			PlayerPawn(Owner).PlayFiring();
			PlaySelectiveFiring();
			PlayFiringSound();
			flameShotCount = 6;
		}
		else
			flameShotCount--;

		Sleep( GetShotTime() );
		GenerateBullet();
		goto('Begin');
	}
Done:
	bFlameOn = False;
	GotoState('FinishFire');
}

state Reload
{
ignores Fire, AltFire;

    function float GetReloadTime()
    {
        local float val;

        val = ReloadTime;

        if (ScriptedPawn(Owner) != None)
        {
            val = ReloadTime * (ScriptedPawn(Owner).BaseAccuracy*2+1);
			if (TNMPawn(Owner) != None)
			{
				if (TNMPawn(Owner).localPlayer != None)
				{
					if (TNMPawn(Owner).localPlayer.bNightmareMode)
						val = ReloadTime / 3;
				}
				else
					TNMPawn(Owner).GetPlayer();
			}
        }
        else if (DeusExPlayer(Owner) != None)
        {
            // check for skill use if we are the player
            val = GetWeaponSkill();
            val = ReloadTime + (val*ReloadTime);
        }

        return val;
    }

Begin:
	FinishAnim();

	// only reload if we have ammo left
	if (AmmoType.AmmoAmount > 0)
	{
		if (( Level.NetMode == NM_DedicatedServer ) || ((Level.NetMode == NM_ListenServer) && Owner.IsA('DeusExPlayer') && !DeusExPlayer(Owner).PlayerIsListenClient()))
		{
			ClientReload();
			Sleep(GetReloadTime());
			ReadyClientToFire( True );
		}
		else
		{
			bWasZoomed = bZoomed;
			if (bWasZoomed)
				ScopeOff();

			if(!bReloadAnimHack)
				Owner.PlaySound(CockingSound, SLOT_None,,, 1024);		// CockingSound is reloadbegin
			else
				Owner.PlaySound(CockingSound, SLOT_None,,, 1024, Default.ReloadTime/GetReloadTime());		// CockingSound is reloadbegin
			if(!bReloadAnimHack && HasAnim('ReloadBegin'))
				PlayAnim('ReloadBegin');
			NotifyOwner(True);
			ClosedCaptions("RELOADSTART");
			FinishAnim();
			if(!bReloadAnimHack  && HasAnim('Reload'))
				LoopAnim('Reload');
			else if (HasAnim('Reload'))
				PlayAnim('Reload',Default.ReloadTime/GetReloadTime());
			if (PlayerPawn(Owner) != None)
				NotifyOwner(True); // Redo anim for players
			Sleep(GetReloadTime());
			if(!bReloadAnimHack)
				Owner.PlaySound(AltFireSound, SLOT_None,,, 1024);		// AltFireSound is reloadend
			else
				Owner.PlaySound(AltFireSound, SLOT_None,,, 1024, Default.ReloadTime/GetReloadTime());		// AltFireSound is reloadend
			if(!bReloadAnimHack && HasAnim('ReloadEnd'))
				PlayAnim('ReloadEnd');
			ClosedCaptions("RELOADEND");
			FinishAnim();
			NotifyOwner(False);

			if (bWasZoomed)
				ScopeOn();

			ClipCount = 0;
		}
	}
	GotoState('Idle');
}

simulated function SawedOffCockSound()
{
	if ((AmmoType.AmmoAmount >= 0) && (IsA('WeaponTNMSawedOffShotgun')))
		Owner.PlaySound(SelectSound, SLOT_None,,, 1024);
}

function ClosedCaptions(string captionState)
{
	local Trestkon pp;
	
	return;
	
	pp = Trestkon(GetPlayerPawn());
	
	if (pp != None && (pp.bSubtitles))
	{
		switch (caps(captionState))
		{
			case "FIRING":
				DeusExRootWindow(pp.rootWindow).hud.barkDisplay.AddBark(CaptionFiring, 1.5, Self);
				break;
			case "DRYFIRE":
				DeusExRootWindow(pp.rootWindow).hud.barkDisplay.AddBark(CaptionDryFire, 1.5, Self);
				break;
			case "RELOADSTART":
				DeusExRootWindow(pp.rootWindow).hud.barkDisplay.AddBark(CaptionReloadStart, 1.5, Self);
				break;
			case "RELOADEND":
				DeusExRootWindow(pp.rootWindow).hud.barkDisplay.AddBark(CaptionReloadEnd, 1.5, Self);
				break;
		}
	}
}

simulated function PlayIdleAnim()
{
	local float rnd;

	if (bZoomed || bNearWall)
		return;
		
	// Don't overwrite current idle anim
	if (IsAnimating())
		return;
		
	// Don't overwrite current idle anim
	if (AnimSequence == 'KarateRaised')
		return;

	rnd = FRand();

	if (rnd < 0.1)
	{
		if (HasAnim('Idle1'))
			PlayAnim('Idle1',,0.1);
	}
	else if (rnd < 0.2)
	{
		if (HasAnim('Idle2'))
			PlayAnim('Idle2',,0.1);
	}
	else if (rnd < 0.3)
	{
		if (HasAnim('Idle3'))
			PlayAnim('Idle3',,0.1);
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
				
				Victims.TakeDamage
				(
					damageScale * DamageAmount,
					Instigator, 
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					(damageScale * Momentum * dir),
					DamageName
				);
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

function ApplyLegendaryEffect()
{
	legendaryEffect.bHidden = bHidden;
	legendaryEffect.Mesh = Mesh;
	legendaryEffect.DrawScale = DrawScale;
	
	if(
	HasAttribute(Att_Desperate) ||
	HasAttribute(Att_Valiant) ||
	HasAttribute(Att_00n) ||
	HasAttribute(Att_Ruthless) ||
	HasAttribute(Att_Venomous) ||
	HasAttribute(Att_DoubleBarreled) ||	
	HasAttribute(Att_Lamar) ||	
	HasAttribute(Att_Junkie) ||
	HasAttribute(Att_Explosive) ||
	HasAttribute(Att_Hunter) ||
	HasAttribute(Att_LowTech) ||
	HasAttribute(Att_Augmented) ||
	HasAttribute(Att_Technophobic) ||
	HasAttribute(Att_Narcissian) ||
	HasAttribute(Att_Lucky) ||
	HasAttribute(Att_Pinpoint) ||
	HasAttribute(Att_ArmorPiercing) ||
	HasAttribute(Att_Assassin) ||
	HasAttribute(Att_Embiggening) ||
	HasAttribute(Att_Focused) ||
	HasAttribute(Att_Faithful))
	{
		legendaryEffect.Texture = legendaryEffect.TexDamage;
	}
	else if(
	HasAttribute(Att_Fleeting) ||
	HasAttribute(Att_Luminous))
	{
		legendaryEffect.Texture = legendaryEffect.TexPassive;
	}
	else if(
	HasAttribute(Att_Crazed) ||
	HasAttribute(Att_Environmental) ||
	HasAttribute(Att_Leeching) ||
	HasAttribute(Att_Messy) ||
	HasAttribute(Att_Gaseous) ||
	HasAttribute(Att_Irritating) ||
	HasAttribute(Att_Frying) ||
	HasAttribute(Att_Quaking) ||
	HasAttribute(Att_Tracking) ||
	HasAttribute(Att_Paralyzing) ||
	HasAttribute(Att_Intense) ||
	HasAttribute(Att_Swift) ||
	HasAttribute(Att_Resourceful) ||
	HasAttribute(Att_Puncturing) ||
	HasAttribute(Att_Phreaking) ||
	HasAttribute(Att_Penetrative) ||
	HasAttribute(Att_Panicked) ||
	HasAttribute(Att_Painful) ||
	HasAttribute(Att_Immolative) ||
	HasAttribute(Att_Incendiary) ||
	HasAttribute(Att_Blinding) ||
	HasAttribute(Att_Dismantling) ||
	HasAttribute(Att_Energized))
	{
		legendaryEffect.Texture = legendaryEffect.TexUtility;
	}
	else if(
	HasAttribute(Att_Directed) ||
	HasAttribute(Att_Long) ||
	HasAttribute(Att_Docile) ||
	HasAttribute(Att_Lightened) ||
	HasAttribute(Att_Zoomed) ||
	HasAttribute(Att_Wild) ||
	HasAttribute(Att_Lubricated) ||
	HasAttribute(Att_Shrunken) ||
	HasAttribute(Att_Silenced) ||
	HasAttribute(Att_Rapid) ||
	HasAttribute(Att_Precise) ||
	HasAttribute(Att_Enlarged))
	{
		legendaryEffect.Texture = legendaryEffect.TexStats;
	}
	else
	{
		legendaryEffect.Texture = legendaryEffect.Texture;
	}
	legendaryEffect.Skin = legendaryEffect.Texture;
	// legendaryEffect.MultiSkins[0] = legendaryEffect.Texture;
	// legendaryEffect.MultiSkins[1] = legendaryEffect.Texture;
	// legendaryEffect.MultiSkins[2] = legendaryEffect.Texture;
	// legendaryEffect.MultiSkins[3] = legendaryEffect.Texture;
	// legendaryEffect.MultiSkins[4] = legendaryEffect.Texture;
	// legendaryEffect.MultiSkins[5] = legendaryEffect.Texture;
	// legendaryEffect.MultiSkins[6] = legendaryEffect.Texture;
	// legendaryEffect.MultiSkins[7] = legendaryEffect.Texture;
}

simulated function Destroyed()
{
	if (legendaryEffect != None)
		legendaryEffect.Destroy();

	Super.Destroyed();
}



function bool IsLethal()
{
	local name dType;
	local bool bLethal;

	dType = WeaponDamageType();

	switch(dType)
	{
		case 'Stunned':
		case 'KnockedOut':
		case 'Poison':
		case 'PoisonEffect':
			bLethal = False;
			break;
		default:
			bLethal = True;
			break;
	}

	return bLethal;
}

function bool IsNonLethal()
{
	local name dType;
	local bool bLethal;

	dType = WeaponDamageType();

	switch(dType)
	{
		case 'Stunned':
		case 'KnockedOut':
		case 'Poison':
		case 'PoisonEffect':
			bLethal = True;
			break;
		default:
			bLethal = False;
			break;
	}

	return bLethal;
}

function bool IsBurner()
{
	local name dType;
	local bool bBurner;

	dType = WeaponDamageType();

	switch(dType)
	{
		case 'Flared':
		case 'Burned':
		case 'Flamed':
			bBurner = True;
			break;
		default:
			bBurner = False;
			break;
	}

	return bBurner;
}

function bool IsHarmless()
{
	local name dType;
	local bool bHarmless;

	if (ProjectileClass != None)
		bHarmless = (ProjectileClass.Default.Damage <= 0);
	else
		bHarmless = (HitDamage <= 0);

	if (!bHarmless)
	{
		dType = WeaponDamageType();

		switch(dType)
		{
			case 'TearGas':
			case 'HalonGas':
			// case 'EMP': // Sorta
			case 'NanoVirus':
				bHarmless = True;
				break;
		}
	}

	return bHarmless;
}

function color GetAttributeColor()
{
	local color itemColor;
	
	if(
	HasAttribute(Att_Desperate) ||
	HasAttribute(Att_Valiant) ||
	HasAttribute(Att_00n) ||
	HasAttribute(Att_Ruthless) ||
	HasAttribute(Att_Venomous) ||
	HasAttribute(Att_DoubleBarreled) ||	
	HasAttribute(Att_Lamar) ||	
	HasAttribute(Att_Junkie) ||
	HasAttribute(Att_Explosive) ||
	HasAttribute(Att_Hunter) ||
	HasAttribute(Att_LowTech) ||
	HasAttribute(Att_Augmented) ||
	HasAttribute(Att_Technophobic) ||
	HasAttribute(Att_Narcissian) ||
	HasAttribute(Att_Lucky) ||
	HasAttribute(Att_Pinpoint) ||
	HasAttribute(Att_ArmorPiercing) ||
	HasAttribute(Att_Assassin) ||
	HasAttribute(Att_Embiggening) ||
	HasAttribute(Att_Focused) ||
	HasAttribute(Att_Faithful))
	{
		itemColor.R = 170;
		itemColor.G = 0;
		itemColor.B = 0;
	}
	else if(
	HasAttribute(Att_Fleeting) ||
	HasAttribute(Att_Luminous))
	{
		itemColor.R = 56;
		itemColor.G = 243;
		itemColor.B = 171;
	}
	else if(
	HasAttribute(Att_Crazed) ||
	HasAttribute(Att_Environmental) ||
	HasAttribute(Att_Leeching) ||
	HasAttribute(Att_Messy) ||
	HasAttribute(Att_Gaseous) ||
	HasAttribute(Att_Irritating) ||
	HasAttribute(Att_Frying) ||
	HasAttribute(Att_Quaking) ||
	HasAttribute(Att_Tracking) ||
	HasAttribute(Att_Paralyzing) ||
	HasAttribute(Att_Intense) ||
	HasAttribute(Att_Swift) ||
	HasAttribute(Att_Resourceful) ||
	HasAttribute(Att_Puncturing) ||
	HasAttribute(Att_Phreaking) ||
	HasAttribute(Att_Penetrative) ||
	HasAttribute(Att_Panicked) ||
	HasAttribute(Att_Painful) ||
	HasAttribute(Att_Immolative) ||
	HasAttribute(Att_Incendiary) ||
	HasAttribute(Att_Blinding) ||
	HasAttribute(Att_Dismantling) ||
	HasAttribute(Att_Energized))
	{
		itemColor.R = 112;
		itemColor.G = 176;
		itemColor.B = 74;
	}
	else if(
	HasAttribute(Att_Directed) ||
	HasAttribute(Att_Long) ||
	HasAttribute(Att_Docile) ||
	HasAttribute(Att_Lightened) ||
	HasAttribute(Att_Zoomed) ||
	HasAttribute(Att_Wild) ||
	HasAttribute(Att_Lubricated) ||
	HasAttribute(Att_Shrunken) ||
	HasAttribute(Att_Silenced) ||
	HasAttribute(Att_Rapid) ||
	HasAttribute(Att_Precise) ||
	HasAttribute(Att_Enlarged))
	{
		itemColor.R = 207;
		itemColor.G = 106;
		itemColor.B = 50;
	}
	else
	{
		itemColor.R = 134;
		itemColor.G = 80;
		itemColor.B = 172;
	}
	return itemColor;
}


// calculate the accuracy for this weapon and the owner's damage
simulated function float CalculateAccuracy()
{
    local float accuracy;   // 0 is dead on, 1 is pretty far off
    local float tempacc, div;
    local float weaponSkill; // so we don't keep looking it up (slower).
    local int HealthArmRight, HealthArmLeft, HealthHead;
    local int BestArmRight, BestArmLeft, BestHead;
    local bool checkit;
    local DeusExPlayer player;

    accuracy = BaseAccuracy;        // start with the weapon's base accuracy
    weaponSkill = GetWeaponSkill();

    player = DeusExPlayer(Owner);

    if (player != None)
    {
        // check the player's skill
        // 0.0 = dead on, 1.0 = way off
        accuracy += weaponSkill;

        // get the health values for the player
        HealthArmRight = player.HealthArmRight;
        HealthArmLeft  = player.HealthArmLeft;
        HealthHead     = player.HealthHead;
        BestArmRight   = player.Default.HealthArmRight;
        BestArmLeft    = player.Default.HealthArmLeft;
        BestHead       = player.Default.HealthHead;
        checkit = True;
    }
    else if (ScriptedPawn(Owner) != None)
    {
        // update the weapon's accuracy with the ScriptedPawn's BaseAccuracy
        // (BaseAccuracy uses higher values for less accuracy, hence we add)
        accuracy += ScriptedPawn(Owner).BaseAccuracy;
        accuracy += weaponSkill;

        // get the health values for the NPC
        HealthArmRight = ScriptedPawn(Owner).HealthArmRight;
        HealthArmLeft  = ScriptedPawn(Owner).HealthArmLeft;
        HealthHead     = ScriptedPawn(Owner).HealthHead;
        BestArmRight   = ScriptedPawn(Owner).Default.HealthArmRight;
        BestArmLeft    = ScriptedPawn(Owner).Default.HealthArmLeft;
        BestHead       = ScriptedPawn(Owner).Default.HealthHead;
        checkit = True;
    }
    else
        checkit = False;

    // Disabled accuracy mods based on health in multiplayer
    if ( IsDeathmatchStats() )
        checkit = False;

    if (checkit)
    {
        if (HealthArmRight < 1)
            accuracy += 0.5;
        else if (HealthArmRight < BestArmRight * 0.34)
            accuracy += 0.2;
        else if (HealthArmRight < BestArmRight * 0.67)
            accuracy += 0.1;

        if (HealthArmLeft < 1)
            accuracy += 0.5;
        else if (HealthArmLeft < BestArmLeft * 0.34)
            accuracy += 0.2;
        else if (HealthArmLeft < BestArmLeft * 0.67)
            accuracy += 0.1;

        if (HealthHead < BestHead * 0.67)
            accuracy += 0.1;
    }

    // increase accuracy (decrease value) if we haven't been moving for awhile
    // this only works for the player, because NPCs don't need any more aiming help!
    if (player != None)
    {
        tempacc = accuracy;
        if (standingTimer > 0)
        {
            // higher skill makes standing bonus greater
            div = Max(15.0 + 29.0 * weaponSkill, 0.0);
            accuracy -= FClamp(standingTimer/div, 0.0, 0.6);

            // don't go too low
            if ((accuracy < 0.1) && (tempacc > 0.1))
                accuracy = 0.1;
        }
    }

    // make sure we don't go negative
    if (accuracy < 0.0)
        accuracy = 0.0;

    if (IsDeathmatchStats())
        if (accuracy < MinWeaponAcc)
            accuracy = MinWeaponAcc;

    return accuracy;
}

simulated function float GetWeaponSkill()
{
    local DeusExPlayer player;
    local float value;
	local TNMAugmentation TNMA;

    value = 0;

    if ( Owner != None )
    {
        player = DeusExPlayer(Owner);
        if (player != None)
        {
            if ((player.AugmentationSystem != None ) && ( player.SkillSystem != None ))
            {
                // get the target augmentation
                value = player.AugmentationSystem.GetAugLevelValue(class'AugTarget');
                if (value == -1.0)
                    value = 0;

                // get the skill
                value += player.SkillSystem.GetSkillLevelValue(GoverningSkill);
                // value += -0.25 * katanaLevel;
                value += -0.34 * katanaLevel;
            }
			/*
			if (WeaponFists(Self) != None)
			{
				switch(WeaponFists(Self).fisttype)
				{
					case FT_normal: 
						break;
					case FT_spiked: 
						value += -0.250000;
						break;
					case FT_shock: 
						break;
					case FT_stun : 
						value += 0.250000;
						break;
					case FT_ban : 
						value += -0.500000;
						break;
				}
			}*/
        }
		else if (TNMPawn(Owner) != None)
		{
			if (TNMPawn(Owner).TNMPAM != None)
			{
				TNMA = TNMPawn(Owner).TNMPAM.findaug(class'TNMAugTarget');
				if ((TNMA != none) && (TNMA.bisactive))
					value += TNMA.Value;
				TNMA = TNMPawn(Owner).TNMPAM.findaug(class'TNMAugHeartLung');
				if ((TNMA != none) && (TNMA.bisactive))
					value += TNMA.Value;
			}
			if (Treskton(Owner) != None)
				value += -0.25; // arbitrary advanced skill for Treskton.
			if (Trestkon(GetPlayerPawn()).bNightmareMode)
				value += -0.125;
		}
    }
    return value;
}

function bool Facelift(bool bOn)
{
}

function PostPostBeginPlay()
{
	Super.PostPostBeginPlay();
	
	if (Trestkon(GetPlayerPawn()) != None)
		Facelift(Trestkon(GetPlayerPawn()).bHDTPWeapons);
}

//WCCC: Adding this shit on the bottom.
function ReloadAmmo()
{
	local bool bMagFull;
	
	// single use or hand to hand weapon if ReloadCount == 0
	if (ReloadCount == 0)
	{
		if (Pawn(Owner) != None)
			Pawn(Owner).ClientMessage(msgCannotBeReloaded);
		return;
	}
	if (AmmoType == None)
		return;
	
	bMagFull = (ClipCount <= 0 || (ReloadCount-ClipCount) >= AmmoType.AmmoAmount);
	if (LastAmmoType != AmmoType.Class || (Trestkon(Owner) != None && Trestkon(Owner).bParanoidReload))
	{
		bMagFull = false;
	}
	
	if (!IsInState('Reload'))
	{
		if (bMagFull) return;
		
		TweenAnim('Still', 0.1);
		GotoState('Reload');
	}
	
	LastAmmoType = AmmoType.Class;
}

function LoadAmmoType(Ammo ammo)
{
	local int i;
	
	if (ammo != None)
	{
		for (i=0; i<3; i++)
		{
			if (AmmoNames[i] == ammo.Class)
			{
				//MADDERS, 7/24/21: Check that LoadAmmo was ran as god intended.
				bLoadAmmoFudge = false;
				if (LoadAmmo(i))
				{
					if (!bLoadAmmoFudge)
					{
						if (ScriptedPawn(Owner) == None || Trestkon(Owner) == None || !Trestkon(Owner).bParanoidReload)
						{
							ClipCount = ReloadCount;
						}
						ReloadAmmo();
					}
				}
			}
		}
	}
}

function DeusExLevelInfo GetLevelInfo()
{
    local DeusExLevelInfo info;

    foreach AllActors(class'DeusExLevelInfo', info)
        break;

    return info;
}

function bool HasAttribute(EAttribute testAttribute)
{
	if (testAttribute == Att_None)
	{
		if (Attributes2 >= 1)
			return False;
		else if (Attributes1 > 1)
			return False;
		return true;
	}
	if (testAttribute < 31)
		return (Attributes1 & (0x01<<testAttribute)) > 0;
	else
		return (Attributes2 & (0x01<<testAttribute-31)) > 0;
	return (Attribute == testAttribute);
}

simulated function SetCoopSavedAttributes(byte AttrByte, int A1, int A2)
{
	Attributes1 = A1;
	Attributes2 = A2;
	switch (AttrByte)
	{
		case 0:  Attribute = Att_None; break;
		case 1:  Attribute = Att_Lubricated; break;
		case 2:  Attribute = Att_Ruthless; break;
		case 3:  Attribute = Att_Directed; break;
		case 4:  Attribute = Att_Zoomed; break;
		case 5:  Attribute = Att_Silenced; break;
		case 6:  Attribute = Att_Puncturing; break;
		case 7:  Attribute = Att_ArmorPiercing; break;
		case 8:  Attribute = Att_Painful; break;
		case 9:  Attribute = Att_Blinding; break;
		case 10: Attribute = Att_Paralyzing; break;
		case 11: Attribute = Att_Phreaking; break;
		case 12: Attribute = Att_Desperate; break;
		case 13: Attribute = Att_Junkie; break;
		case 14: Attribute = Att_Assassin; break;
		case 15: Attribute = Att_Valiant; break;
		case 16: Attribute = Att_Quaking; break;
		case 17: Attribute = Att_Venomous; break;
		case 18: Attribute = Att_Technophobic; break;
		case 19: Attribute = Att_Frying; break;
		case 20: Attribute = Att_Lamar; break;
		case 21: Attribute = Att_00n; break;
		case 22: Attribute = Att_Narcissian; break;
		case 23: Attribute = Att_Luminous; break;
		case 24: Attribute = Att_Penetrative; break;
		case 25: Attribute = Att_Rapid; break;
		case 26: Attribute = Att_Embiggening; break;
		case 27: Attribute = Att_Explosive; break;
		case 28: Attribute = Att_DoubleBarreled; break;
		case 29: Attribute = Att_Wild; break;
		case 30: Attribute = Att_Energized; break;
		case 31: Attribute = Att_Messy; break;
		case 32: Attribute = Att_Lucky; break;
		case 33: Attribute = Att_Resourceful; break;
		case 34: Attribute = Att_Leeching; break;
		case 35: Attribute = Att_Precise; break;
		case 36: Attribute = Att_Enlarged; break;
		case 37: Attribute = Att_Augmented; break;
		case 38: Attribute = Att_LowTech; break;
		case 39: Attribute = Att_Dismantling; break;
		case 40: Attribute = Att_Focused; break;
		case 41: Attribute = Att_Intense; break;
		case 42: Attribute = Att_Long; break;
		case 43: Attribute = Att_Fleeting; break;
		case 44: Attribute = Att_Swift; break;
		case 45: Attribute = Att_Incendiary; break;
		case 46: Attribute = Att_Docile; break;
		case 47: Attribute = Att_Pinpoint; break;
		case 48: Attribute = Att_Gaseous; break;
		case 49: Attribute = Att_Irritating; break;
		case 50: Attribute = Att_Panicked; break;
		case 51: Attribute = Att_Shrunken; break;
		case 52: Attribute = Att_Lightened; break;
		case 53: Attribute = Att_Crazed; break;
		case 54: Attribute = Att_Environmental; break;
		case 55: Attribute = Att_Hunter; break;
		case 56: Attribute = Att_Immolative; break;
		case 57: Attribute = Att_Tracking; break;
		case 58: Attribute = Att_Faithful; break;
		default: Attribute = Att_None; break;
	}
}

function bool HasAttributeInt(int testAttribute)
{
	if (testAttribute == 0)
	{
		if (Attributes2 >= 1)
			return False;
		else if (Attributes1 > 1)
			return False;
		return true;
	}
	if (testAttribute < 31)
		return (Attributes1 & (0x01<<testAttribute)) > 0;
	else
		return (Attributes2 & (0x01<<testAttribute-31)) > 0;
	return (Attribute == testAttribute);
}

defaultproperties
{
     Amplitude=10
     LockonSoundRate=0.100000
     msgNeedOxygen="This weapon doesn't work in a vacuum"
     CaptionFiring="(Firing)"
     CaptionDryFire="(Dry-Fire)"
     CaptionReloadStart="(Reload-Starts)"
     CaptionReloadEnd="(Reload-Ends)"
     strKills="Kills: "
     strKnockouts="Knock-outs: "
     AttributeName(1)="Lubricated"
     AttributeName(2)="Ruthless"
     AttributeName(3)="Directed"
     AttributeName(4)="Zoomed"
     AttributeName(5)="Silenced"
     AttributeName(6)="Puncturing"
     AttributeName(7)="Armor Piercing"
     AttributeName(8)="Painful"
     AttributeName(9)="Blinding"
     AttributeName(10)="Paralyzing"
     AttributeName(11)="Phreaking"
     AttributeName(12)="Desperate"
     AttributeName(13)="Junkie's"
     AttributeName(14)="Assassin's"
     AttributeName(15)="Valiant"
     AttributeName(16)="Quaking"
     AttributeName(17)="Venomous"
     AttributeName(18)="Technophobic"
     AttributeName(19)="Frying"
     AttributeName(20)="Lamar's"
     AttributeName(21)="00n's"
     AttributeName(22)="Narcissian"
     AttributeName(23)="Luminous"
     AttributeName(24)="Penetrative"
     AttributeName(25)="Rapid"
     AttributeName(26)="Embiggening"
     AttributeName(27)="Explosive"
     AttributeName(28)="Double Barreled"
     AttributeName(29)="Wild"
     AttributeName(30)="Energized"
     AttributeName(31)="Messy"
     AttributeName(32)="Lucky"
     AttributeName(33)="Resourceful"
     AttributeName(34)="Leeching"
     AttributeName(35)="Precise"
     AttributeName(36)="Enlarged"
     AttributeName(37)="Augmented"
     AttributeName(38)="Low-Tech"
     AttributeName(39)="Dismantling"
     AttributeName(40)="Focused"
     AttributeName(41)="Intense"
     AttributeName(42)="Long"
     AttributeName(43)="Fleeting"
     AttributeName(44)="Swift"
     AttributeName(45)="Incendiary"
     AttributeName(46)="Docile"
     AttributeName(47)="Pinpoint"
     AttributeName(48)="Gaseous"
     AttributeName(49)="Irritating"
     AttributeName(50)="Panicked"
     AttributeName(51)="Shrunken"
     AttributeName(52)="Lightened"
     AttributeName(53)="Crazed"
     AttributeName(54)="Environmental"
     AttributeName(55)="Hunter's"
     AttributeName(56)="Immolative"
     AttributeName(57)="Tracking"
     AttributeName(58)="Faithful"
     AttributeDesc(1)="~ Reloads faster."
     AttributeDesc(2)="~ Body shots do increased damage."
     AttributeDesc(3)="~ Built in laser-sight."
     AttributeDesc(4)="~ Built in scope."
     AttributeDesc(5)="~ Built in silencer."
     AttributeDesc(6)="~ Damage bypasses damage thresholds against cameras, turrets, and alarm panels."
     AttributeDesc(7)="~ Damage bypasses damage reduction against robots."
     AttributeDesc(8)="~ Staggers enemies on consecutive hits."
     AttributeDesc(9)="~ Has a chance to blind enemies on hit."
     AttributeDesc(10)="~ Has a chance to stun enemies on hit."
     AttributeDesc(11)="~ Confuses cameras, turrets, and alarm panels."
     AttributeDesc(12)="~ Damage increases as user's health decreases."
     AttributeDesc(13)="~ Damage increases while drunk or drugged."
     AttributeDesc(14)="~ Increased damage when behind target."
     AttributeDesc(15)="~ Increased damage when in front of target."
     AttributeDesc(16)="~ No self-damage.|n~ Self-damage causes knockback.|n~ Reduced fall damage while equipped.|n~ Increased air control while equipped."
     AttributeDesc(17)="~ Deals poison damage over time."
     AttributeDesc(18)="~ Increased damage to robots."
     AttributeDesc(19)="~ Deals EMP damage to robots."
     AttributeDesc(20)="~ Increased damage against Goat cult members."
     AttributeDesc(21)="~ Increased damage against Llama cult members."
     AttributeDesc(22)="~ Increased damage against cult members."
     AttributeDesc(23)="~ Provides light when equipped.|n~ Enemies can see user easier in light."
     AttributeDesc(24)="~ Explosions penetrate walls."
     AttributeDesc(25)="~ Faster rate of fire."
     AttributeDesc(26)="~ Damage radiates enemies."
     AttributeDesc(27)="~ Fires explosive rounds."
     AttributeDesc(28)="~ Fires extra projectiles."
     AttributeDesc(29)="~ Fully automatic."
     AttributeDesc(30)="~ User gains bio-energy on kill."
     AttributeDesc(31)="~ Gibs killed targets."
     AttributeDesc(32)="~ Has a chance to critical hit for increased damage."
     AttributeDesc(33)="~ Has a chance to not consume ammo."
     AttributeDesc(34)="~ User heals on kill."
     AttributeDesc(35)="~ Increased accuracy."
     AttributeDesc(36)="~ Increased magazine size."
     AttributeDesc(37)="~ Active augmentations increase damage."
     AttributeDesc(38)="~ Increased damage against augmented enemies."
     AttributeDesc(39)="~ Increased damage against doors."
     AttributeDesc(40)="~ Increased damage while crouched."
     AttributeDesc(41)="~ Increased explosion radius."
     AttributeDesc(42)="~ Increased range."
     AttributeDesc(43)="~ User moves faster while equipped."
     AttributeDesc(44)="~ Projectiles move faster."
     AttributeDesc(45)="~ Ignites the area where it hits."
     AttributeDesc(46)="~ No recoil."
     AttributeDesc(47)="~ Headshots instantly knockout."
     AttributeDesc(48)="~ Emits poison gas where it hits."
     AttributeDesc(49)="~ Emits tear gas where it hits."
     AttributeDesc(50)="~ Rate of fire increases while in combat."
     AttributeDesc(51)="~ Reduced inventory size."
     AttributeDesc(52)="~ Reduced weight."
     AttributeDesc(53)="~ Scrambles robots."
     AttributeDesc(54)="~ Works in air, water, and in vacuums."
     AttributeDesc(55)="~ Increased damage to transgenics."
     AttributeDesc(56)="~ Briefly ignites targets."
     AttributeDesc(57)="~ Projectile homes."
     AttributeDesc(58)="~ Weapon level: %d/5."
     legendaryChance=0.200000
     strTitlePrefix(0)="Legendary"
     strTitlePrefix(1)="Exotic"
     strTitlePrefix(2)="Unreal"
     strTitlePrefix(3)="Mythical"
     strTitlePrefix(4)="Fabled"
     strTitlePrefix(5)="Impossible"
     strTitlePrefix(6)="Inconcievable"
     AIRating=1000.000000
}

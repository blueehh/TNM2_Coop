//=============================================================================
// WeaponFists.
//=============================================================================
class WeaponFists extends TNMWeapon;

var travel bool bhasspiked;
var travel bool bhasshock;
var travel bool bhasstun;
var travel bool bhasban;
var bool bkaratechop;

var localized string strFistEquipped[5];

enum EFistType {
  FT_normal,
  FT_spiked,
  FT_shock,
  FT_stun,
  FT_ban};

var travel Efisttype fisttype;

replication
{
	reliable if ((Role == ROLE_Authority) && (bNetOwner))
		fisttype, bhasspiked, bhasshock, bhasstun, bhasban;
}

simulated function byte getfistType()
{
	return fisttype;
}

simulated function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	super.ProcessTraceHit(Other, HitLocation, HitNormal, X, Y, Z);
	
	if (DeusExPlayer(Owner) != None && DeusExPlayer(Owner).FrobTarget != None)
	{
		if (Button1(DeusExPlayer(Owner).FrobTarget) != None || Switch1(DeusExPlayer(Owner).FrobTarget) != None || Switch2(DeusExPlayer(Owner).FrobTarget) != None || Lightswitch(DeusExPlayer(Owner).FrobTarget) != None || (DeusExPlayer(Owner).FrobTarget).IsA('TNMRedButton') || (DeusExPlayer(Owner).FrobTarget).IsA('TNMGreyButton') || (DeusExPlayer(Owner).FrobTarget).IsA('WCButton'))
			DeusExPlayer(Owner).DoFrob(Owner, Self);
	}
}

simulated function PlaySelectiveFiring()
{
	if(bKarateChop)
	{
		PlayAnim('KarateChop',,0.1);
		return;
	}
	else if ((FRand() <= 0.01 || getfistType() == 4) && DeusExPlayer(Owner) != None && DeusExPlayer(Owner).FrobTarget != None && Pawn(DeusExPlayer(Owner).FrobTarget) != None)
	{
		PlayAnim('ProdAttack',,0.1);
		return;
	}
	else if (DeusExPlayer(Owner) != None && DeusExPlayer(Owner).FrobTarget != None && (Button1(DeusExPlayer(Owner).FrobTarget) != None || Switch1(DeusExPlayer(Owner).FrobTarget) != None || Switch2(DeusExPlayer(Owner).FrobTarget) != None || Lightswitch(DeusExPlayer(Owner).FrobTarget) != None || (DeusExPlayer(Owner).FrobTarget).IsA('TNMRedButton') || (DeusExPlayer(Owner).FrobTarget).IsA('TNMGreyButton') || (DeusExPlayer(Owner).FrobTarget).IsA('WCButton')))
	{
		PlayAnim('ProdAttack',,0.1);
		return;
	}

	super.PlaySelectiveFiring();
}

simulated function Tick(float deltaTime)
{
	local ScriptedPawn pawn;
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z, offset;
	local actor Other;
	local float dist;
	local bool bHead;
	local float offsetZ,offsetY;

	super.Tick(deltaTime);

	//make sure proper fist mesh is selected post travel or replication
	SetFistType(fisttype);

	if(pawn(owner)==None)
		return;
		
	// Force lethal damage for pawns
	if (ScriptedPawn(owner) != None)
		setfisttype(1);

	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	StartTrace = ComputeProjectileStart(X, Y, Z);
	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);

	EndTrace = StartTrace + (FMax(1024.0, MaxRange) * vector(AdjustedAim));
      
	Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
	dist = Abs(VSize(HitLocation - Owner.Location));
	if (dist <= AccurateRange)
	{
		X=vector(adjustedaim);
		pawn=ScriptedPawn(Other);
		
		if(pawn!=None)
		{
			offset = (hitLocation - pawn.Location) << pawn.Rotation;
			offsetZ = pawn.CollisionHeight * 0.7;
			offsetY = pawn.CollisionRadius * 0.3;

			if(offset.z>offsetZ)
				if((Abs(offset.x) < offsetY) || (Abs(offset.y) < offsetY))
					if(offset.x<0)
						bHead=true;
		}

		if(!bHead && bKarateChop && AnimSequence != 'Attack' && AnimSequence != 'Attack2' && AnimSequence != 'Attack3' && AnimSequence != 'KarateChop' && AnimSequence != 'ProdAttack')
		{
			bKarateChop=false;
			TweenAnim('Still',0.3);
		}
		else if (bHead && !bKarateChop && AnimSequence != 'Attack' && AnimSequence != 'Attack2' && AnimSequence != 'Attack3' && AnimSequence != 'KarateChop' && AnimSequence != 'ProdAttack')
		{
			bKarateChop=true;
			PlayAnim('KarateRaised',,0.2);
		}	
	}
}

simulated function setfisttype(byte ft)
{
	//why aren't enums interchangable with integers?
	//--
	//if anyone's interested (yay fan looking through the code) it's because they're byte values
	//you can still explicitly cast them to int eg int(ft) -shax
	switch(ft)
	{
		case 0 : 
			fisttype = FT_normal;
			playerviewmesh = LodMesh'WeaponFists';
			mesh = LodMesh'WeaponFists';
			break;
		case 1 : 
			fisttype = FT_spiked;
			playerviewmesh = LodMesh'WeaponFistsspike';
			mesh = LodMesh'WeaponFistsspike';
			break;
		case 2 : 
			fisttype = FT_shock;
			playerviewmesh = LodMesh'WeaponFistsshock';
			mesh = LodMesh'WeaponFistsshock';
			break;
		case 3 : 
			fisttype = FT_stun;
			playerviewmesh = LodMesh'WeaponFistsstun';
			mesh = LodMesh'WeaponFistsstun';
			break;
		case 4 : 
			fisttype = FT_ban;
			playerviewmesh = LodMesh'WeaponFistsBan';
			mesh = LodMesh'WeaponFistsBan';
			break;
	}
}

function givefisttype(byte ft)
{
	switch(ft)
	{
		case 1 : bhasspiked = true;
			break;
		case 2 : bhasshock = true;
			break;
		case 3 : bhasstun = true;
			break;
		case 4 : bhasban = true;
			break;
	}
	
	if (bHasSpiked && bHasShock && bHasStun && Trestkon(Owner) != None)
		Trestkon(Owner).SetAchievement("achGloves");
}

simulated function SpawnEffectSounds( Vector HitLocation, Vector HitNormal, Actor Other, float Damage )
{
	if (bHandToHand)
	{
		// if we are hand to hand, play an appropriate sound
		if (Other.IsA('Pawn')|| Other.IsA('carcass')) //added to make carci make a squelching sound instead of a metalic sound.
			Owner.PlayOwnedSound(Misc1Sound, SLOT_None,,, 1024);
		else if (Other.IsA('DeusExDecoration'))
			Owner.PlayOwnedSound(Misc3Sound, SLOT_None,,, 1024);
		else if (Other.IsA('BreakableGlass'))
			Owner.PlayOwnedSound(sound'GlassHit1', SLOT_None,,, 1024);
		else if (GetWallMaterial(HitLocation, HitNormal) == 'Glass')
			Owner.PlayOwnedSound(sound'BulletProofHit', SLOT_None,,, 1024);
		else
			Owner.PlayOwnedSound(Misc2Sound, SLOT_None,,, 1024);
	}
}

simulated function UpdateFistDamage()
{
	switch(fisttype)
	{
		case FT_normal: 
			HitDamage = default.HitDamage;
			break;
		case FT_spiked: 
			HitDamage = default.HitDamage * 1.5;
			break;
		case FT_shock: 
			HitDamage = default.HitDamage;
			break;
		case FT_stun : 
			HitDamage = default.HitDamage / 2;
			break;
		case FT_ban : 
			HitDamage = default.HitDamage * 3;
			break;
	}
}

simulated function HandToHandAttack()
{
	UpdateFistDamage();
	Super.HandToHandAttack();
}

function name WeaponDamageType()
{
	UpdateFistDamage();

	if ((Trestkon(Owner) != None && Trestkon(Owner).bInstagibFists) || (Trestkon(GetPlayerPawn()) != None && Trestkon(GetPlayerPawn()).bInstagibFists))
		return 'Gibbed';

	StunDuration = 0;

	switch(fisttype)
	{
		case FT_normal:
			bPenetrating=True;
			return 'KnockedOut';
		case FT_spiked:
			bPenetrating=True;
			return 'Shot';
		case FT_shock:
			bPenetrating=False;
			return 'FistEMP';
		case FT_stun:
			StunDuration=4.0;
			bPenetrating=False;
			// return 'Stunned';
			return 'FistStunned';
		case FT_ban:
			bPenetrating=False;
			return 'Banned';
	}
}

function PlaySelect()
{
	if (Mesh != None)
		Super.PlaySelect();
}
/*
auto state Pickup
{
    function BeginState()
	{
		Super.BeginState();
		
		if (owner == None)
			Destroy();
	}
}*/

function CycleAmmo()
{
	local byte i;
	
	if (Trestkon(owner) == None)
		return;
	
	i = getfistType();
	do
	{
		i++;
		if (i > 4)
			i = 0;
		if (Trestkon(owner).CanSelectFist(i))
		{
			switch(i)
			{
				case 0:
					setfisttype(i);
					Trestkon(owner).ClientMessage(strFistEquipped[int(i)]);
					break;
				case 1:
					if (bhasspiked)
					{
						setfisttype(i);
						Trestkon(owner).ClientMessage(strFistEquipped[int(i)]);
					}
					break;
				case 2:
					if (bhasshock)
					{
						setfisttype(i);
						Trestkon(owner).ClientMessage(strFistEquipped[int(i)]);
					}
					break;
				case 3:
					if (bhasstun)
					{
						setfisttype(i);
						Trestkon(owner).ClientMessage(strFistEquipped[int(i)]);
					}
					break;
				case 4:
					if (bhasban)
					{
						setfisttype(i);
						Trestkon(owner).ClientMessage(strFistEquipped[int(i)]);
					}
					break;
			}
			if (i == fisttype)
				break;
		}
	} until (i == getfistType());
}

simulated function renderoverlays(Canvas canvas)
{
	if (DeusExPlayer(Owner) != None)
	{		
		if (!PlayerCloakDetected())
		{/*
			switch(fisttype)
			{
				case FT_normal: */
					Multiskins[1] = None;/*
					break;
				case FT_spiked: 
					Multiskins[1] = Texture'spikeFists1';
					break;
				case FT_shock: 
					Multiskins[1] = Texture'shockFists1';
					break;
				case FT_stun : 
					Multiskins[1] = Texture'stunFists1';
					break;
			}*/
			AmbientGlow = Default.AmbientGlow;
			ScaleGlow = Default.ScaleGlow;
			Style = Default.Style;
		}
		else
			Multiskins[1] = Getweaponhandtex();	
		
		Super.RenderOverlays(canvas);
		
		Multiskins[1] = None;
	}
}

defaultproperties
{
     strFistEquipped(0)="No gloves equipped"
     strFistEquipped(1)="Lethal Gloves equipped."
     strFistEquipped(2)="EMP Gloves equipped."
     strFistEquipped(3)="Stun-Gloves equipped."
     strFistEquipped(4)="Ban Gloves equipped."
     bUniqueWeapon=True
     bNoMetal=True
     LowAmmoWaterMark=0
     GoverningSkill=Class'TNM.SkillWeaponFists'
     NoiseLevel=0.020000
     EnemyEffective=ENMEFF_Organic
     reloadTime=0.000000
     HitDamage=5
     maxRange=80
     AccurateRange=80
     BaseAccuracy=1.000000
     StunDuration=5.000000
     bHasMuzzleFlash=False
     bHandToHand=True
     bFallbackWeapon=True
     bNativeAttack=True
     bEmitWeaponDrawn=False
     bUseAsDrawnWeapon=False
     mpHitDamage=20
     mpBaseAccuracy=0.200000
     mpAccurateRange=1200
     mpMaxRange=80
     AmmoName=Class'DeusEx.AmmoNone'
     ReloadCount=0
     bInstantHit=True
     FireOffset=(X=22.000000,Y=-10.000000,Z=14.000000)
     shakemag=20.000000
     FireSound=Sound'TNM.Weapons.FistsFire'
     SelectSound=Sound'DeusExSounds.Weapons.CrowbarSelect'
     Misc1Sound=Sound'TNM.Weapons.HitFlesh'
     Misc2Sound=Sound'TNM.Weapons.HitMetal'
     Misc3Sound=Sound'TNM.Weapons.HitWood'
     InventoryGroup=31
     bDisplayableInv=False
     ItemName="Bare Hands"
     ItemArticle="your"
     PlayerViewOffset=(X=28.000000,Y=-10.000000,Z=-11.500000)
     PlayerViewScale=0.700000
     Icon=Texture'TNM.Skins.BeltIconFist'
     largeIcon=Texture'TNM.Skins.LargeIconFist'
     largeIconWidth=36
     largeIconHeight=36
     Description="UNIQUE WEAPON:|nThe ACME(R) Techno-Steel Stun-Gloves(TM) are especially crafted to fit anybody perfectly. They are made of a very light composite steel-variety which allows maximum impact power while ensuring minimum encumbrance. Their unique shape allows you to stun anyone you punch while wearing these gloves for a short period of time.|n|nNB. Now available with special synth-fur padding! Order now, and get a free candy bar for free, with no extra cost!"
     beltDescription="GLOVES"
     CollisionRadius=9.000000
     CollisionHeight=4.000000
}

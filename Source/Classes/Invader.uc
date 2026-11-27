class Invader extends TNMPawn;

enum EClassStyle
{
	Class_Mimic,	// Player's inventory
	Class_Pistol,	// Pistol
	Class_Heavy,	// GEP gun, quad rocket
	Class_Rifle,	// PHAT rifle, pump shotgun
	Class_Demo,		// LAM, gas grenade, vortex grenade
	Class_Melee,	// Dragon's tooth, gibinator
	Class_Nonlethal,// Pepper gun, baton, gas grenades
	Class_Fire,		// Napalm launcher, molotovs, fireblade
	Class_Throwing,	// Throwing knives
	Class_EMP,		// EMP grenades, EMP pistol, EMP rockets
	Class_Sniper,	// ZP's rifle
	Class_Assault,	// Assault rifle
	Class_Shotgun,	// Assault shotgun, pump shotgun
	Class_LAW,		// LAW
	Class_Stealth,	// Stealth pistol, silenced Trestkon's
	Class_Katana,	// Katana
	Class_Darts,	// Mini-crossbow, blowpipe
	Class_Plasma	// Plasma rifle, PS20s
};

var bool bNoBonus;
var bool skinset;
var bool nameset;
var string names[40];
var EClassStyle ClassStyle;

function PostPostBeginPlay()
{
	local trestkon player;
	local int i;

	Super.PostPostBeginPlay();

	player = Trestkon(GetPlayerPawn());
	// foreach AllActors(class'trestkon', player)
		// break;
	SetSkin(player);
	SetCollision(True, True, True);
	while (!nameset)
	{
		i = Rand(ArrayCount(names));
		if (names[i] != "")
		{
			UnfamiliarName = Default.UnfamiliarName @ names[i];
			FamiliarName = Default.FamiliarName @ names[i];
			nameset = True;
		}
	}
	if (player != None)
		tnmhud(DeusExRootWindow(Player.rootWindow).hud).InvaderEnterMessage(names[i]);
}

function EnterWorld()
{
	Super.EnterWorld();
	SetSkin(Trestkon(GetPlayerPawn()));
}

//Used to dynamically load the assault rifle from tnmitems
function InitializeInventory()
{
	local inventory Copy;
	local inventory inv;
	local Inventory item, nextItem;
	local trestkon player;
	local int i;
	
	InitialInventory[7].Inventory = Class'TNM.WeaponFists';
	
	switch(Rand(18))
	{
		case 0:  ClassStyle = Class_Mimic; break;
		case 1:  ClassStyle = Class_Pistol; break;
		case 2:  ClassStyle = Class_Heavy; break;
		case 3:  ClassStyle = Class_Rifle; break;
		case 4:  ClassStyle = Class_Demo; break;
		case 5:  ClassStyle = Class_Melee; break;
		case 6:  ClassStyle = Class_Nonlethal; break;
		case 7:  ClassStyle = Class_Fire; break;
		case 8:  ClassStyle = Class_Throwing; break;
		case 9:  ClassStyle = Class_EMP; break;
		case 10:  ClassStyle = Class_Sniper; break;
		case 11:  ClassStyle = Class_Assault; break;
		case 12:  ClassStyle = Class_Shotgun; break;
		case 13:  ClassStyle = Class_LAW; break;
		case 14:  ClassStyle = Class_Stealth; break;
		case 15:  ClassStyle = Class_Katana; break;
		case 16:  ClassStyle = Class_Darts; break;
		case 17:  ClassStyle = Class_Plasma; break;
	}
	
	switch(ClassStyle)
	{
		case Class_Mimic:
			break;
		case Class_Pistol:
			InitialInventory[0].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMPistol",class'Class'));
			InitialInventory[1].Inventory = Class'DeusEx.Ammo10mm';
			InitialInventory[1].Count = 60;
			break;
		case Class_Heavy:
			InitialInventory[0].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMGEPGun",class'Class'));
			InitialInventory[1].Inventory = Class'DeusEx.AmmoRocket';
			InitialInventory[1].Count = 60;
			InitialInventory[2].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponQdRocket",class'Class'));
			InitialInventory[3].Inventory = class<DeusExAmmo>(DynamicLoadObject("TNMItems.AmmoQdRocket",class'Class'));
			InitialInventory[3].Count = 60;
			break;
		case Class_Rifle:
			InitialInventory[0].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponFatRifle",class'Class'));
			InitialInventory[1].Inventory = class<DeusExAmmo>(DynamicLoadObject("TNMItems.AmmoFatRifle",class'Class'));
			InitialInventory[1].Count = 60;
			InitialInventory[2].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponShotgun",class'Class'));
			InitialInventory[3].Inventory = class<DeusExAmmo>(DynamicLoadObject("TNMItems.AmmoSlug",class'Class'));
			InitialInventory[3].Count = 60;
			break;
		case Class_Demo:
			InitialInventory[0].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponPlasmanade",class'Class'));
			InitialInventory[1].Inventory = class<DeusExAmmo>(DynamicLoadObject("TNMItems.WeaponTNMLAM",class'Class'));
			InitialInventory[1].Count = 60;
			InitialInventory[2].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMGasGrenade",class'Class'));
			InitialInventory[2].Count = 60;
			break;
		case Class_Melee:
			InitialInventory[0].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMNanoSword",class'Class'));
			InitialInventory[1].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponGibinator",class'Class'));
			InitialInventory[2].Inventory = class<DeusExAmmo>(DynamicLoadObject("TNMItems.AmmoGibBattery",class'Class'));
			InitialInventory[2].Count = 60;
			break;
		case Class_Nonlethal:
			InitialInventory[0].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMPepperGun",class'Class'));
			InitialInventory[1].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMBaton",class'Class'));
			InitialInventory[2].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMGasGrenade",class'Class'));
			InitialInventory[2].Count = 60;
			break;
		case Class_Fire:
			InitialInventory[0].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponNapalmLauncher",class'Class'));
			InitialInventory[1].Inventory = class<DeusExAmmo>(DynamicLoadObject("TNMItems.AmmoNapalmL",class'Class'));
			InitialInventory[1].Count = 60;
			InitialInventory[2].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponFireBlade",class'Class'));
			InitialInventory[3].Inventory = Class'TNM.WeaponMolBottle';
			InitialInventory[3].Count = 60;
			break;
		case Class_Throwing:
			InitialInventory[0].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMShuriken",class'Class'));
			InitialInventory[0].Count = 60;
			InitialInventory[1].Inventory = Class'DeusEx.AmmoShuriken';
			InitialInventory[1].Count = 60;
			break;
		case Class_EMP:
			InitialInventory[0].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponLaser",class'Class'));
			InitialInventory[1].Inventory = class<DeusExAmmo>(DynamicLoadObject("TNMItems.AmmoLaserBattery",class'Class'));
			InitialInventory[1].Count = 60;
			InitialInventory[2].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponQdRocket",class'Class'));
			InitialInventory[3].Inventory = class<DeusExAmmo>(DynamicLoadObject("TNMItems.AmmoEMPRocket",class'Class'));
			InitialInventory[3].Count = 60;
			InitialInventory[4].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMEMPGrenade",class'Class'));
			InitialInventory[4].Count = 60;
			bSmartWeapons = True;
			break;
		case Class_Sniper:
			InitialInventory[0].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponUniqueZP",class'Class'));
			InitialInventory[1].Inventory = Class'DeusEx.Ammo3006';
			InitialInventory[1].Count = 60;
			InitialInventory[2].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponSporkGolden",class'Class'));
			break;
		case Class_Assault:
			InitialInventory[0].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMAssaultGun",class'Class'));
			InitialInventory[1].Inventory = Class'DeusEx.Ammo762mm';
			InitialInventory[1].Count = 60;
			InitialInventory[2].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponSporkGolden",class'Class'));
			break;
		case Class_Shotgun:
			InitialInventory[0].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMAssaultShotgun",class'Class'));
			InitialInventory[1].Inventory = Class'DeusEx.AmmoShell';
			InitialInventory[1].Count = 60;
			InitialInventory[2].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponShotgun",class'Class'));
			InitialInventory[3].Inventory = class<DeusExAmmo>(DynamicLoadObject("TNMItems.AmmoSlug",class'Class'));
			InitialInventory[3].Count = 60;
			InitialInventory[4].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponSporkGolden",class'Class'));
			break;
		case Class_LAW:
			InitialInventory[0].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMLAW",class'Class'));
			InitialInventory[0].Count = 3;
			InitialInventory[1].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponKatana",class'Class'));
			break;
		case Class_Stealth:
			InitialInventory[0].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponUniqueAO",class'Class'));
			InitialInventory[1].Inventory = Class'DeusEx.Ammo10mm';
			InitialInventory[1].Count = 60;
			InitialInventory[2].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponDoubleGuns",class'Class'));
			InitialInventory[3].Inventory = class<DeusExAmmo>(DynamicLoadObject("TNMItems.Ammo45",class'Class'));
			InitialInventory[3].Count = 60;
			InitialInventory[4].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponSporkGolden",class'Class'));
			break;
			break;
		case Class_Katana:
			InitialInventory[0].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponKatana",class'Class'));
			break;
		case Class_Darts:
			InitialInventory[0].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMMiniCrossbow",class'Class'));
			InitialInventory[1].Inventory = Class'DeusEx.AmmoDartPoison';
			InitialInventory[1].Count = 60;
			InitialInventory[2].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponBlowPipe",class'Class'));
			InitialInventory[3].Inventory = class<DeusExAmmo>(DynamicLoadObject("TNMItems.AmmoBlowDart",class'Class'));
			InitialInventory[3].Count = 60;
			InitialInventory[4].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponSporkGolden",class'Class'));
			break;
		case Class_Plasma:
			InitialInventory[0].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMPlasmaRifle",class'Class'));
			InitialInventory[1].Inventory = Class'DeusEx.AmmoPlasma';
			InitialInventory[1].Count = 60;
			InitialInventory[2].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMHideAGun",class'Class'));
			InitialInventory[3].Inventory = class<DeusExAmmo>(DynamicLoadObject("TNMItems.AmmoPS20",class'Class'));
			InitialInventory[3].Count = 60;
			InitialInventory[4].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponSporkGolden",class'Class'));
			break;
	}
	
	super.InitializeInventory();

	foreach AllActors(class'trestkon', player)
		break;
	/*	
	if (player == none)
	{	
		InitialInventory[0].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMAssaultGun",class'Class'));
		InitialInventory[2].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMRifle",class'Class'));
		InitialInventory[4].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMPistol",class'Class'));
		InitialInventory[6].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMNanoSword",class'Class'));
		return;
	}*/

	if (ClassStyle == Class_Mimic)
	{
		for(item = Player.Inventory; item != None; item = nextItem)
		{
			if (item == none)
				break;
			nextItem = item.Inventory;
			if ((DeusExWeapon(item) != None || DeusExAmmo(item) != None) && !item.IsA('WeaponFists') && !item.IsA('WeaponMine'))
			{
				// Prevent duplicates (Weapon spawns ammo then ammo copied)
				if (FindInventoryType(item.Class) == None)
				{
					Copy = spawn(item.Class,Self,,,rot(0,0,0));
					if (Copy == None)
						break;
					Copy.Tag           = item.Tag;
					Copy.Event         = item.Event;

					// Copy.bHeldItem = true;
					Copy.InitialState='Idle2';
					Copy.GiveTo( Self );
					Copy.SetBase(Self);
					
					if (DeusExWeapon(item) != None)
					{
						DeusExWeapon(Copy).bHasSilencer = DeusExWeapon(item).bHasSilencer;
						DeusExWeapon(Copy).bHasLaser = DeusExWeapon(item).bHasLaser;
						DeusExWeapon(Copy).bHasScope = DeusExWeapon(item).bHasScope;
					}
					
					if (DeusExAmmo(Copy) != None)
						DeusExAmmo(Copy).AmmoAmount += DeusExAmmo(item).AmmoAmount;
					
					if (DeusExWeapon(Copy) != None && (DeusExWeapon(Copy).AmmoType == None) && (DeusExWeapon(Copy).AmmoName != None) &&
					(DeusExWeapon(Copy).AmmoName != Class'AmmoNone'))
					{
						DeusExWeapon(Copy).AmmoType = Ammo(FindInventoryType(DeusExWeapon(Copy).AmmoName));
						if (DeusExWeapon(Copy).AmmoType == None)
						{
							DeusExWeapon(Copy).AmmoType = spawn(DeusExWeapon(Copy).AmmoName);
							DeusExWeapon(Copy).AmmoType.InitialState='Idle2';
							DeusExWeapon(Copy).AmmoType.GiveTo(Self);
							DeusExWeapon(Copy).AmmoType.SetBase(Self);
						}
					}
				}
			}
			Copy = None;
		}
	}
	
	for(inv=inventory; inv!=none; inv=inv.inventory)
	{
		inv.Style = Style;
		for (i=0;i<8;i++)
		{
			// if (inv.MultiSkins[i] != Texture'DeusExItems.Skins.BlackMaskTex' && inv.MultiSkins[i] != Texture'DeusExItems.Skins.PinkMaskTex')
			inv.MultiSkins[i] = FireTexture'Effects.Liquid.Virus_SFX';
		}
		if (DeusExWeapon(inv) != None && DeusExWeapon(inv).bHasMuzzleFlash)
		{
			if (inv.IsA('WeaponFireStaff'))
				DeusExWeapon(inv).MultiSkins[4] = None;
			else if (inv.IsA('WeaponDoubleGuns'))
			{
				DeusExWeapon(inv).MultiSkins[5] = None;
				DeusExWeapon(inv).MultiSkins[7] = None;
			}
			else if (inv.IsA('WeaponFatRifle'))
			{
				DeusExWeapon(inv).MultiSkins[6] = None;
				DeusExWeapon(inv).MultiSkins[7] = None;
			}
			else if (inv.IsA('WeaponGibinator'))
				DeusExWeapon(inv).MultiSkins[3] = None;
			else if (inv.IsA('WeaponLaser'))
				DeusExWeapon(inv).MultiSkins[6] = None;
			else if (inv.IsA('WeaponNapalmLauncher'))
				DeusExWeapon(inv).MultiSkins[6] = None;
			else if (inv.IsA('WeaponShotgun'))
				DeusExWeapon(inv).MultiSkins[1] = None;
			else
				DeusExWeapon(inv).MultiSkins[2] = None;
			DeusExWeapon(inv).bHasMuzzleFlash = False;
		}	
	}
}

// ----------------------------------------------------------------------
// SetSkin()
// ----------------------------------------------------------------------

function SetSkin(DeusExPlayer player)
{
	local int i;

	if (!skinset)
	{
		if (player != None)
		{/*
			Mesh=player.Mesh;

			// if ( player.playerskin < 12 )
				// walkanimmult=0.562161;

			if (Mesh == LodMesh'TNM.GM_Trenchkon')
			{
				MultiSkins[3]=Texture'DeusExItems.Skins.BlackMaskTex';
				MultiSkins[4]=FireTexture'Effects.Liquid.Virus_SFX';
			}*/
			if (Rand(2) == 0)
			{
				MultiSkins[0]=Texture'TNM.Skins.InvaderMJ12Tex3_A00';
				MultiSkins[1]=Texture'TNM.Skins.InvaderMJ12Tex1_A00';
				MultiSkins[2]=Texture'TNM.Skins.InvaderMJ12Tex2_A00';
				MultiSkins[3]=Texture'TNM.Skins.InvaderMJ12Mask_A00';
				MultiSkins[4]=Texture'TNM.Skins.InvaderMJ12Mask_A00';
				MultiSkins[5]=Texture'TNM.Skins.InvaderMJ12Tex3_A00';
				MultiSkins[6]=Texture'TNM.Skins.InvaderMJ12Tex3_A00';
				MultiSkins[7]=Texture'TNM.Skins.InvaderMJ12Tex3_A00';
			}
			else
			{
				Mesh=player.Mesh;

				if (Mesh == LodMesh'TNM.GM_Trenchkon')
				{
					Multiskins[0] = Texture'tnm.Skins.InvaderTrestkonTex0_A00';
					Multiskins[1] = Texture'tnm.Skins.InvaderTrestkonTrenchTex2_A00';
					Multiskins[2] = Texture'tnm.Skins.InvaderTrestkonTrenchTex3_A00';
					Multiskins[3] = Texture'DeusExItems.Skins.PinkMaskTex';
					Multiskins[4] = Texture'tnm.Skins.InvaderTrestkonTrenchTex1_A00';
					Multiskins[5] = Texture'tnm.Skins.InvaderTrestkonTrenchTex2_A00';
					Multiskins[6] = Texture'DeusExItems.Skins.PinkMaskTex';
					Multiskins[7] = Texture'DeusExItems.Skins.PinkMaskTex';
				}
				else
				{
					Multiskins[0] = Texture'TNM.Skins.InvaderTrestkonTex0_A00';
					Multiskins[1] = Texture'TNM.Skins.InvaderTrestkonTex2_A00';
					Multiskins[2] = Texture'TNM.Skins.InvaderTrestkonTex1_A00';
					Multiskins[3] = Texture'TNM.Skins.InvaderTrestkonTex0_A00';
					Multiskins[4] = Texture'DeusExItems.Skins.PinkMaskTex';
					Multiskins[5] = Texture'DeusExItems.Skins.PinkMaskTex';
					Multiskins[6] = Texture'DeusExItems.Skins.PinkMaskTex';
					Multiskins[7] = Texture'DeusExItems.Skins.PinkMaskTex';
				}
			}
		}
	}
}

function ResetSkinStyle()
{
	local int i;
	local playerpawn player;

	player = getplayerpawn();

	for (i=0;i<8;i++)
		MultiSkins[i] = player.Multiskins[i];
	Skin      = Default.Skin;
	ScaleGlow = Default.ScaleGlow;
	Style     = Default.Style;
}

state Dying
{
	function BeginState()
	{
		local Inventory item, nextItem;
		local ParticleGenerator gen;

		if (Inventory != None)
		{
			do
			{
				item = Inventory;
				nextItem = item.Inventory;
				DeleteInventory(item);
				item.Destroy();
				item = nextItem;
			}
			until (item == None);
		}
		Super.BeginState();
		
		gen = spawn(Class'particlegenerator',,,,Rot(16384,0,0));
		
		if (gen != None)
		{
			gen.Lifespan = 3;
			gen.bFade = True;
			gen.bGravity = True;
			gen.bRandomEject = True;
			gen.particleTexture = FireTexture'Effects.Laser.LaserSpot1';
			gen.numPerSpawn = 10;
			gen.ejectSpeed = 200;
			// gen.Frequency = 0.2;
		}
	}
	
	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);
	
		Fatness--;
	}
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
	if (Trestkon(Killer) != None && !bNoBonus)
		Trestkon(Killer).SkillPointsAdd(50);
	super.Died(killer, damagetype, hitlocation);
}

function PlayAttack()
{
	if (Region.Zone.bWaterZone)
		PlayAnimPivot('Tread',,,GetSwimPivot());
	else
	{
		if (bUseSecondaryAttack)
			PlayAnimPivot('AttackSide', 3);
		else
			PlayAnimPivot('Attack', 3);
	}
}

function Pawn CheckCycle()
{
	local float attackPeriod;
	local float maxAttackPeriod;
	local float sustainPeriod;
	local float decayPeriod;
	local float minCutoff;
	local Pawn  cycleEnemy;

	attackPeriod    = 0.5;
	maxAttackPeriod = 4.5;
	sustainPeriod   = 3.0;
	decayPeriod     = 4.0;

	minCutoff = attackPeriod/maxAttackPeriod;

	cycleEnemy = None;

	if (CycleCumulative <= 0)  // no enemies seen during this cycle
	{
		CycleTimer -= CyclePeriod;
		if (CycleTimer <= 0)
		{
			CycleTimer = 0;
			EnemyReadiness -= CyclePeriod/decayPeriod;
			if (EnemyReadiness < 0)
				EnemyReadiness = 0;
		}
	}
	else  // I saw somebody!
	{
		CycleTimer = sustainPeriod;
		CycleCumulative *= 20;  // hack
		if (CycleCumulative < minCutoff)
			CycleCumulative = minCutoff;
		else if (CycleCumulative > 1.0)
			CycleCumulative = 1.0;
		EnemyReadiness += CycleCumulative*CyclePeriod/attackPeriod;
		if (EnemyReadiness >= 1.0)
		{
			EnemyReadiness = 1.0;
			if (IsValidEnemy(CycleCandidate))
				cycleEnemy = CycleCandidate;
		}
		else if (EnemyReadiness >= SightPercentage)
			if (IsValidEnemy(CycleCandidate))
				HandleSighting(CycleCandidate);
	}
	CycleCumulative = 0;
	CyclePeriod     = 0;
	CycleCandidate  = None;
	CycleDistance   = 0;

	return (cycleEnemy);

}

function PlayTakeHitSound(int Damage, name damageType, int Mult)
{
	local Sound hitSound;
	local float volume;

	if (Level.TimeSeconds - LastPainSound < 0.25)
		return;
	if (Damage <= 0)
		return;

	LastPainSound = Level.TimeSeconds;

	if (Damage <= 30)
		hitSound = HitSound1;
	else
		hitSound = HitSound2;
	volume = FMax(Mult*TransientSoundVolume, Mult*2.0);

	SetDistressTimer();
	PlaySound(hitSound, SLOT_Pain, volume*2,,, RandomPitch() / 1.5);
	if ((hitSound != None) && bEmitDistress)
		AISendEvent('Distress', EAITYPE_Audio, volume);
}

function bool ShouldDropWeapon()
{
	return false;
}

defaultproperties
{
     names(0)="Board Guest 1952161"
     names(1)="Bean Fanatic"
     names(2)="Invisible War's Greatest Fan"
     names(3)="Maneater Mildred"
     names(4)="On-Topic Productions"
     names(5)="Creighton The Wanderer"
     names(6)="Plin Plin Plon"
     names(7)="Nick Pauseback"
     names(8)="War Crimes 9000"
     names(9)="Sergeant McQuaid"
     names(10)="Bell Keeper"
     names(11)="Frozen Hell Fanboy"
     names(12)="TNM's Second Fan"
     names(13)="Narcissus Themself"
     names(14)="Knight Hunter"
     names(15)="Kwah"
     names(16)="Jimbo"
     names(17)="ABI Hitman"
     names(18)="Radish Eater"
     names(19)="Crystal Melk Snorter"
     names(20)="Neglected Datacube"
     names(21)="IRC Idler"
     names(22)="BSP Victim"
     names(23)="PlanetCNC Commando"
     names(24)="Frogery"
     names(25)="The Named Mod"
     names(26)="The Nameless Moderator"
     names(27)="Leetspeak Hater"
     names(28)="Pwner"
     names(29)="Nameless Usurper"
     names(30)="TNM 3.0"
     names(31)="DX Denton"
     names(32)="the Other TNM Player"
     names(33)="PlanetQuake Escapee"
     names(34)="Mad Ingram"
     names(35)="A Chocolate Clock"
     names(36)="Lioon Reza"
     names(37)="Deck Gun"
     names(38)="Jester Thomas"
     names(39)="The Orange One"
     bCanUseFists=True
     bAlarmCarcass=True
     bAlarmBot=True
     bAlarmFire=True
     bAlarmLostPlayer=True
     bAlarmKilledPlayer=True
     AugHealthLimit=400.000000
     bCustomBarkPitch=True
     barkPitchMin=0.900000
     barkPitchMax=1.100000
     bShouldGuardPoints=True
     MinHealth=0.000000
     WalkingSpeed=0.213333
     bHateIndirectInjury=True
     bHateDistress=True
     bFearProjectiles=True
     bEmitDistress=False
     SurprisePeriod=0.250000
     InitialInventory(1)=(Inventory=Class'DeusEx.Ammo10mm',Count=6)
     BurnPeriod=7.000000
     walkAnimMult=1.000000
     AccelRate=2048.000000
     AirControl=1.000000
     Health=200
     HitSound1=Sound'DeusExSounds.Animal.KarkianIdle'
     HitSound2=Sound'DeusExSounds.Animal.KarkianIdle'
     Die=Sound'DeusExSounds.Animal.KarkianIdle'
     HealthHead=200
     HealthTorso=200
     HealthLegLeft=200
     HealthLegRight=200
     HealthArmLeft=200
     HealthArmRight=200
     VisibilityThreshold=0.000250
     Alliance=Invader
     bStasis=False
     Style=STY_Translucent
     Texture=Texture'DeusExItems.Skins.PinkMaskTex'
     Mesh=LodMesh'MPCharacters.mp_jumpsuit'
     ScaleGlow=0.750000
     AmbientGlow=25
     MultiSkins(0)=Texture'DeusExDeco.Skins.AlarmUnitTex2'
     MultiSkins(1)=FireTexture'Effects.liquid.Virus_SFX'
     MultiSkins(2)=FireTexture'Effects.liquid.Virus_SFX'
     MultiSkins(3)=FireTexture'Effects.liquid.Virus_SFX'
     MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(5)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(6)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     RotationRate=(Pitch=3072,Yaw=65000,Roll=2048)
     BindName="Invader"
     BarkBindName="Invader"
     FamiliarName="Rogue Entity"
     UnfamiliarName="Rogue Entity"
}

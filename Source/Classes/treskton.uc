class treskton extends TNMPawn;

struct AugPair
{
	var class<Augmentation> PlayerAug;
	var class<tnmaugmentation> PawnAug;
};

var AugPair Augpairs[15];
var bool skinset;

function PostPostBeginPlay()
{
	local trestkon player;

	Super.PostPostBeginPlay();

	player = Trestkon(GetPlayerPawn());
	// foreach AllActors(class'trestkon', player)
		// break;
	SetSkin(player);
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
	local Inventory item, nextItem;
	local trestkon player;
	
	InitialInventory[7].Inventory = Class'TNM.WeaponFists';
	
	super.InitializeInventory();

	foreach AllActors(class'trestkon', player)
		break;
		
	if (player == none)
	{	
		InitialInventory[0].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMAssaultGun",class'Class'));
		InitialInventory[2].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMRifle",class'Class'));
		InitialInventory[4].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMPistol",class'Class'));
		InitialInventory[6].Inventory = class<tnmweapon>(DynamicLoadObject("TNMItems.WeaponTNMNanoSword",class'Class'));
		return;
	}

	for(item = Player.Inventory; item != None; item = nextItem)
	{
		if (item == none)
			break;
		nextItem = item.Inventory;
		if ((DeusExWeapon(item) != None || DeusExAmmo(item) != None) && !item.IsA('WeaponFists') && !item.IsA('WeaponMine'))
		{
			// Ignore grenades, too unreliable
			if (DeusExWeapon(item) != None && DeusExWeapon(item).bHandToHand && DeusExWeapon(item).AmmoName != Class'AmmoNone')
			{
			}
			// Prevent duplicates (Weapon spawns ammo then ammo copied)
			else if (FindInventoryType(item.Class) == None)
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
					DeusExWeapon(Copy).ModReloadTime = -0.5;
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
				if (TNMWeapon(Copy) != None)
				{
					TNMWeapon(Copy).bAttributeApplied = True;
					TNMWeapon(Copy).Attribute = TNMWeapon(Item).Attribute;
					TNMWeapon(Copy).katanaLevel = TNMWeapon(Item).katanaLevel;
				}
			}
		}
		Copy = None;
	}
}

// ----------------------------------------------------------------------
// SetSkin()
// ----------------------------------------------------------------------

function SetSkin(DeusExPlayer player)
{
	local int i;
	local int numaugs;

	if (!skinset)
	{
		numaugs = 0;
		if (player != None)
		{
			Mesh=player.Mesh;

			// if ( player.playerskin < 12 )
				// walkanimmult=0.562161;

			for (i=0;i<8;i++)
				MultiSkins[i] = player.Multiskins[i];
		}

		for (i=0;i<ArrayCount(AugPairs);i++)
		{
			if(player != None && player.AugmentationSystem.FindAugmentation(AugPairs[i].PlayerAug) != none && player.AugmentationSystem.FindAugmentation(AugPairs[i].PlayerAug).bHasIt)
			{
				Augs[numaugs] = AugPairs[i].PawnAug;
				numaugs++;
			}
		}
		
		if(bAugmented)
		{
			if (TNMPAM != none)
				TNMPAM.destroy();
			TNMPAM = none;
			TNMPAM = Spawn(class'TNMPawnAugManager', Self);
			if (TNMPAM != none)
			{
				TNMPAM.setbase(self);
				TNMPAM.CreateAugmentations(Self);
				TNMPAM.activateaugs();
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

		if (Inventory != None)
		{
			do
			{
				item = Inventory;
				nextItem = item.Inventory;
				if (DeusExWeapon(item) != None)
					DeusExWeapon(item).LaserOff();
				DeleteInventory(item);
				item.Destroy();
				item = nextItem;
			}
			until (item == None);
		}
		Super.BeginState();
	}
}

function Died(pawn Killer, name damageType, vector HitLocation)
{/*
	if (Trestkon(Killer) != None)
		Trestkon(Killer).SetAchievement("achTreskton");*/
	super.Died(killer, damagetype, hitlocation);
}

function Reloading(DeusExWeapon reloadWeapon, float reloadTime)
{
    local DeusExPlayer pp;

    pp = DeusExPlayer(GetPlayerPawn());
	SwitchToBestWeapon();

    if (reloadWeapon == Weapon)
        ReloadTimer = reloadTime;
}

function DropWeapon()
{
	local DeusExWeapon dxWeapon;
	local Weapon       oldWeapon;

	if (Weapon != None)
	{
		dxWeapon = DeusExWeapon(Weapon);
		if ((dxWeapon == None) || !dxWeapon.bNativeAttack)
		{
			oldWeapon = Weapon;
			if (DeusExWeapon(oldWeapon) != None)
				DeusExWeapon(oldWeapon).LaserOff();
			DeleteInventory(oldWeapon);
			oldWeapon.Destroy();
			SetWeapon(None);
		}
	}
}

defaultproperties
{
     Augpairs(0)=(PlayerAug=Class'TNM.tnmpcAugCombat',PawnAug=Class'TNM.tnmnpcAugCombat')
     Augpairs(1)=(PlayerAug=Class'DeusEx.AugBallistic',PawnAug=Class'TNM.tnmAugBallistic')
     Augpairs(2)=(PlayerAug=Class'DeusEx.AugCloak',PawnAug=Class'TNM.tnmAugCloakcombat')
     Augpairs(3)=(PlayerAug=Class'DeusEx.AugDefense',PawnAug=Class'TNM.tnmAugDefense')
     Augpairs(4)=(PlayerAug=Class'DeusEx.AugEMP',PawnAug=Class'TNM.tnmAugEMP')
     Augpairs(5)=(PlayerAug=Class'DeusEx.AugEnviro',PawnAug=Class'TNM.tnmAugEnviro')
     Augpairs(6)=(PlayerAug=Class'DeusEx.AugHealing',PawnAug=Class'TNM.tnmAugHealing')
     Augpairs(7)=(PlayerAug=Class'DeusEx.AugRadarTrans',PawnAug=Class'TNM.tnmAugRadarTrans')
     Augpairs(8)=(PlayerAug=Class'DeusEx.AugShield',PawnAug=Class'TNM.tnmAugShield')
     Augpairs(9)=(PlayerAug=Class'DeusEx.AugSpeed',PawnAug=Class'TNM.tnmAugSpeed')
     Augpairs(10)=(PlayerAug=Class'DeusEx.AugStealth',PawnAug=Class'TNM.tnmAugStealth')
     Augpairs(11)=(PlayerAug=Class'DeusEx.AugTarget',PawnAug=Class'TNM.tnmAugTarget')
     Augpairs(12)=(PlayerAug=Class'DeusEx.AugVision',PawnAug=Class'TNM.tnmAugVision')
     Augpairs(13)=(PlayerAug=Class'DeusEx.AugDrone',PawnAug=Class'TNM.tnmAugDrone')
     Augpairs(14)=(PlayerAug=Class'DeusEx.AugHeartLung',PawnAug=Class'TNM.tnmAugHeartLung')
     AugHealthLimit=400.000000
     bAugmented=True
     MinHealth=0.000000
     CarcassType=Class'TNM.tresktonCarcass'
     WalkingSpeed=0.213333
     InitialInventory(1)=(Inventory=Class'DeusEx.Ammo10mm',Count=6)
     BurnPeriod=7.000000
     walkAnimMult=1.000000
     AccelRate=2048.000000
     AirControl=1.000000
     Health=500
     HealthHead=750
     HealthTorso=500
     HealthLegLeft=500
     HealthLegRight=500
     HealthArmLeft=500
     HealthArmRight=500
     Texture=Texture'DeusExItems.Skins.PinkMaskTex'
     Mesh=LodMesh'MPCharacters.mp_jumpsuit'
     MultiSkins(0)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(1)=Texture'TNM.Skins.TrestkonTex2'
     MultiSkins(2)=Texture'TNM.Skins.TrestkonTex1'
     MultiSkins(3)=Texture'TNM.Skins.TrestkonTex0'
     MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(5)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(6)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     RotationRate=(Pitch=3072,Yaw=65000,Roll=2048)
     BindName="Treskton"
     BarkBindName="Treskton"
     FamiliarName="Treskton"
     UnfamiliarName="Treskton"
}

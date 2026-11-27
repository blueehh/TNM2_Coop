//=============================================================================
// WeaponMolBottle.
//=============================================================================
class WeaponMolBottle extends TNMWeapon;

#exec OBJ LOAD FILE=Effects

var float firetime;

simulated function MakeFireVis()
{
	if (GetCloakTexture() == None)
		MultiSkins[2] = Texture'LabelTexBurn';
	MultiSkins[3] = Texture'effects.fire.flame_b';
	MultiSkins[6] = Texture'effects.fire.fireball1';
	firetime = 0.0;
}

simulated function Tick(float deltatime)
{
	if (firetime < 0.8)
	{
		firetime += deltatime;
		if (firetime >= 0.8)
		{
			HandToHandAttack();
			if (GetCloakTexture() == None)
				MultiSkins[2] = Texture'LabelTex';
			MultiSkins[3] = Texture'BlackMaskTex';
			MultiSkins[6] = Texture'BlackMaskTex';
		}
	}
	
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
	
	if (Attribute != Att_None && legendaryEffect == None)
		legendaryEffect = Spawn(Class'LegendaryFX',Self);
	
	if (legendaryEffect != None)
	{
		ApplyLegendaryEffect();
	}
}

simulated function renderoverlays(Canvas canvas)
{
	if (DeusExPlayer(Owner) != None)
	{		
		if (GetCloakTexture() != None)
			Texture = GetCloakTexture();
		else
			Texture = Default.Texture;
		Multiskins[1] = GetCloakTexture();
		if (GetCloakTexture() != None)
			Multiskins[2] = GetCloakTexture();
		else
		{
			if (firetime >= 0.8)
				MultiSkins[2] = Texture'LabelTex';
			else
				MultiSkins[2] = Texture'LabelTexBurn';
		}
		Multiskins[4] = GetCloakTexture();
		Multiskins[5] = Getweaponhandtex();	
		
		Super.RenderOverlays(canvas);
		
		Texture = Default.Texture;
		Multiskins[1] = None;
		Multiskins[2] = None;
		Multiskins[4] = None;
		Multiskins[5] = None;
	}
}

defaultproperties
{
     fireTime=0.800000
     bNoMetal=True
     LowAmmoWaterMark=2
     GoverningSkill=Class'DeusEx.SkillDemolition'
     EnviroEffective=ENVEFF_Air
     Concealability=CONC_All
     ShotTime=0.300000
     reloadTime=0.100000
     HitDamage=50
     maxRange=750
     AccurateRange=750
     BaseAccuracy=1.000000
     bHasMuzzleFlash=False
     bHandToHand=True
     bUseAsDrawnWeapon=False
     AIMinRange=128.000000
     AITimeLimit=3.500000
     AIFireDelay=5.000000
     bNeedToSetMPPickupAmmo=False
     mpReloadTime=0.100000
     mpHitDamage=50
     mpBaseAccuracy=1.000000
     mpAccurateRange=2400
     mpMaxRange=2400
     AmmoName=Class'TNM.AmmoMolotov'
     ReloadCount=1
     PickupAmmoCount=1
     FireOffset=(Y=10.000000,Z=20.000000)
     ProjectileClass=Class'TNM.MolotovProj'
     shakemag=50.000000
     FireSound=Sound'TNM.Weapons.MolFire'
     SelectSound=Sound'DeusExSounds.Weapons.HideAGunSelect'
     InventoryGroup=25
     ItemName="Molotov Cocktail"
     PlayerViewOffset=(X=24.000000,Y=-15.000000,Z=-17.000000)
     PlayerViewMesh=LodMesh'TNM.MolBottle'
     PlayerViewScale=0.600000
     PickupViewMesh=LodMesh'TNM.MolBottlePickup'
     PickupViewScale=0.500000
     ThirdPersonMesh=LodMesh'TNM.MolBottleThird'
     ThirdPersonScale=0.400000
     Icon=Texture'TNM.Skins.BeltIconMolotov'
     largeIcon=Texture'TNM.Skins.LargeIconMolotov'
     largeIconWidth=35
     largeIconHeight=45
     Description="This is an old beer bottle full of a highly flammable combination of household chemicals. When the bottle breaks while the cloth is lit, the chemicals will come into contact with the flames and subsequently erupt into infernal death. Anybody caught in the blast is likely to be set on fire, as is anybody stupid enough to move through the flames. Not to be served chilled."
     beltDescription="MOLOTOV"
     Texture=Texture'TNM.Skins.MoloBottleTex1'
     Mesh=LodMesh'TNM.MolBottlePickup'
     DrawScale=0.500000
     CollisionRadius=3.800000
     CollisionHeight=11.500000
     Mass=5.000000
     Buoyancy=2.000000
}

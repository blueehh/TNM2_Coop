class TNMCarcass extends deusexcarcass;

var() bool bUnconscious;
var() bool bBloodPool;

var() bool bInWorld;
var vector worldposition;
var bool bWorldCollideActors;
var bool bWorldBlockActors;
var bool bWorldBlockPlayers;

var float health;
var string givenname;
var string givenbindname;
var bool binwater;
var float drowntime;
var bool bInit;

var() bool bImportant;

var float BloodOffset;
var tnmBloodPool pool;

// Smoke39
var() bool bAmbientFlaming;	// sets self on fire upon entering the player's view if true
var bool bSearched;		// to let us be picked up after being searched even if we still have stuff

var() float BurnTime;
var bool bSeen;

var bool bAtmosphericDeath;
var bool bDontTransferFlame;
var localized string strPass;
var float Fat;
var RespawnInfo associatedRespawnInfo;

// ----------------------------------------------------------------------
// EnterWorld()
// ----------------------------------------------------------------------

function EnterWorld()
{
	PutInWorld(true);
}


// ----------------------------------------------------------------------
// LeaveWorld()
// ----------------------------------------------------------------------

function LeaveWorld()
{
	PutInWorld(false);
}


// ----------------------------------------------------------------------
// PutInWorld()
// ----------------------------------------------------------------------

function PutInWorld(bool bEnter)
{
	if (bInWorld && !bEnter)
	{
		bInWorld            = false;
		//GotoState('Idle');
		bHidden             = true;
		bDetectable         = false;
		WorldPosition       = Location;
		bWorldCollideActors = bCollideActors;
		bWorldBlockActors   = bBlockActors;
		bWorldBlockPlayers  = bBlockPlayers;
		SetCollision(false, false, false);
		bCollideWorld       = false;
		SetPhysics(PHYS_None);
		SetLocation(Location+vect(0,0,20000));  // move it out of the way
	}
	else if (!bInWorld && bEnter)
	{
		bInWorld    = true;
		bHidden     = Default.bHidden;
		bDetectable = Default.bDetectable;
		SetLocation(WorldPosition);
		SetCollision(bWorldCollideActors, bWorldBlockActors, bWorldBlockPlayers);
		bCollideWorld = true;
		SetPhysics(PHYS_falling);
	}
}

// ----------------------------------------------------------------------
// PostBeginPlay()
// ----------------------------------------------------------------------

function PostBeginPlay()
{
	local int i, j;
	local Inventory inv;

	bCollideWorld = true;

	// Use the carcass name by default
	CarcassName = Name;

	// Add initial inventory items
	for (i=0; i<8; i++)
	{
		if ((InitialInventory[i].inventory != None) && (InitialInventory[i].count > 0))
		{
			for (j=0; j<InitialInventory[i].count; j++)
			{
				inv = spawn(InitialInventory[i].inventory, self);
				if (inv != None)
				{
					inv.bHidden = True;
					inv.SetPhysics(PHYS_None);
					AddInventory(inv);
				}
			}
		}
	}

	// use the correct mesh
	if (Region.Zone.bWaterZone || SpaceZoneInfo(Region.Zone) != None)
	{
		Mesh = Mesh3;
		bNotDead = False;		// you will die in water every time
	}

	// if (bAnimalCarcass)
		// itemName = msgAnimalCarcass;

	if (IsA('GenericScubaDiverCarcass') && bNotDead)
		AmbientSound = Sound'RebreatherLoop';

	MaxDamage = 0.8*Mass;
	SetScaleGlow();

	SetTimer(30.0, False);

	Super(Carcass).PostBeginPlay();
	
	if (!bInWorld) //copied from scriptedpawn. Blame them.
	{
		bInWorld = true;
		LeaveWorld();
	}

	// Smoke39 - if we should burn ambiently, set the timer to check if the player's around
	if ( bAmbientFlaming )
		SetTimer( 0.125, false );
}

function PostPostBeginPlay()
{
	super.PostPostBeginPlay();
	
	if (bInit)
		return;
	
	if(GivenName=="")
	{
		bNotDead=bUnconscious;
		GivenName=FamiliarName;
		GivenBindName=BindName;
		initagain();
	}

	if (IsA('GenericScubaDiverCarcass') && bNotDead)
		AmbientSound = Sound'RebreatherLoop';
	bInit = True;
}

// Smoke39 - be set on fire once the player sees us
function Timer()
{
	local Trestkon T;
	local TNMFire f;

	if ( bAmbientFlaming )
	{
		//TODO investigate more efficient way of doing this
		//last draw time or isrelevant.
		//Probably not necessary since fire doesn't seem to be causing much slow down
//		foreach VisibleCollidingActors( class'Trestkon', T )
//		{
			f = Spawn( class'TNMFire', self );
//			break;
//		}

		if ( f != None )
		{
			f.LifeSpan = 0;
//			f.LifeSpan = 20;
//			bAmbientFlaming = false;
		}
		else
			SetTimer( 0.125, false );
	}
	else
		Super.Timer();	// this makes flies
}

function ExtinguishFire()
{
	local TNMFire f;

	bAmbientFlaming = False;
	SetTimer(0, False);

	foreach BasedActors(class'TNMFire', f)
		f.Destroy();
}

function ChunkUp(int Damage)
{
	local int i;
	local float size;
	local Vector loc;
	local FleshFragment chunk;
	local bool bValidItem;
	local float gibstrength;
	local inventory item, nextItem;

	// gib the carcass
	size = (CollisionRadius + CollisionHeight) / 2;
	if (size > 10.0)
	{
		for (i=0; i<size/4.0; i++)
		{
			loc.X = (1-2*FRand()) * CollisionRadius;
			loc.Y = (1-2*FRand()) * CollisionRadius;
			loc.Z = (1-2*FRand()) * CollisionHeight;
			loc += Location;
			chunk = spawn(class'FleshFragment', None,, loc);
			if (chunk != None)
			{
				chunk.DrawScale = size / 25;
				chunk.SetCollisionSize(chunk.CollisionRadius / chunk.DrawScale, chunk.CollisionHeight / chunk.DrawScale);
				chunk.bFixedRotationDir = True;
				chunk.RotationRate = RotRand(False);
			}
		}
	}

	//ddl's inventory drop code
	gibstrength = fclamp(damage, 10, 30);

	if(inventory != none && !bAnimalCarcass)
	{
		do
		{
			item = Inventory;
			nextItem = item.Inventory;
			bValidItem = true;

			loc.X = (1-2*FRand()) * CollisionRadius;
			loc.Y = (1-2*FRand()) * CollisionRadius;
			loc.Z = (1-2*FRand()) * CollisionHeight;
			loc += Location;

	                DeleteInventory(item);

			if((DeusExWeapon(item) != None) && (DeusExWeapon(item).bNativeAttack))
				bValidItem = false;
			else if(Ammo(item) != none)
				bValidItem = false;

			if(!bValidItem)
				Item.Destroy();
			else
				FlingItem(item, gibstrength*10, loc);

			item = nextItem;
		}
		until (item == None)
	}

	Super(Carcass).ChunkUp(Damage);
	
	if (associatedRespawnInfo != None)
	{
		associatedRespawnInfo.associatedCarcass = None;
		associatedRespawnInfo.LifeSpan = 1;
	}
}

function float ShieldDamage(name damageType)
{
	// handle special damage types
	if ((damageType == 'Stunned' || damageType == 'StunnedTaser')
	 || (damageType == 'KnockedOut') 
	 || (damageType == 'PoisonGas') 
	 || (damageType == 'PoisonEffect') 
	 || (damageType == 'Poison') 
	 || (damagetype == 'EMP')
	 || (damagetype == 'headstun')
	 || (damagetype == 'TearGas')
	 || (damagetype == 'FistStunned')
	 || (damagetype == 'FistEMP')
	 || (damagetype == 'Crushed'))
		return 0.0;
	else
		return 1.0;
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitLocation, Vector momentum, name damageType)
{
	local deusexplayer player;
	local name flagname;
	local int TotalFat; //needed to avoid integer overflow for fatness calculation
	local string temp;

	if (damageType == 'HalonGas')
		ExtinguishFire();

	else if (damageType == 'Flamed' && !bAmbientFlaming)
	{
		bAmbientFlaming = True;
		SetTimer( 0.125, false );
	}
		
	else if (DamageType == 'Fat')
	{
		TotalFat = (Damage);
		TotalFat = Fatness + (TotalFat / 2);
		if (TotalFat > 255)
			Takedamage(1000, InstigatedBy, HitLocation, Momentum, 'exploded');	// Reduced due to proportional blood spawned			
		else
			Fatness = TotalFat;
		return;
	}

	health -= shielddamage(damagetype) * damage;
	if (health <= 0 && bNotDead)
	{
		bGenerateFlies = default.bgenerateflies;
		bNotDead = false;
		initagain();
		if (bImportant)
		{
			player = deusexplayer(instigatedBy);
			if (player == None)
				player = deusexplayer(getplayerpawn());
			if (Trestkon(player) != None)
			{
				flagName = Trestkon(player).SafeStringToName(givenBindName$"_Unconscious");
				player.flagBase.DeleteFlag(flagName, FLAG_Bool);
				flagname = Trestkon(player).SafeStringToName(givenBindName$"_Dead");
				player.flagBase.SetBool(flagName, True);
				player.flagBase.SetExpiration(flagName, FLAG_Bool, 0);
			}
			
			if (instigatedBy == player && givenname != "" && Trestkon(player) != None && Trestkon(player).irc_link != None)
			{
				temp = givenname;
				temp = temp $ "!";
				Trestkon(Player).irc_link.SendChannelAction(Trestkon(Player).irc_link.DefaultChannel,"killed a defenceless"@temp);
			}
		}
		if (IsA('TNMWiBCarcass') || IsA('TNMMiBCarcass'))
		{
			Explode();
			Destroy();
		}
		AmbientSound = None;
	}
	
	// Allow gibbing from fall damage.
	if (damageType == 'fell')
		damageType = 'Shot';
	
	super.takedamage(damage,instigatedby,hitlocation,momentum,damagetype);
}

function Explode()
{
	local SphereEffect sphere;
	local ScorchMark s;
	local ExplosionLight light;
	local int i;
	local float explosionDamage;
	local float explosionRadius;

	explosionDamage = 100;
	explosionRadius = 256;

	// alert NPCs that I'm exploding
	AISendEvent('LoudNoise', EAITYPE_Audio, , explosionRadius*16);
	PlaySound(Sound'LargeExplosion1', SLOT_None,,, explosionRadius*16);

	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, Location);
	if (light != None)
		light.size = 4;

	Spawn(class'ExplosionSmall',,, Location + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionMedium',,, Location + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionMedium',,, Location + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionLarge',,, Location + 2*VRand()*CollisionRadius);

	sphere = Spawn(class'SphereEffect',,, Location);
	if (sphere != None)
		sphere.size = explosionRadius / 32.0;

	// spawn a mark
	s = spawn(class'ScorchMark', Base,, Location-vect(0,0,1)*CollisionHeight, Rotation+rot(16384,0,0));
	if (s != None)
	{
		s.DrawScale = FClamp(explosionDamage/30, 0.1, 3.0);
		s.ReattachDecal();
	}

	// spawn some rocks and flesh fragments
	for (i=0; i<explosionDamage/6; i++)
	{
		if (FRand() < 0.3)
			spawn(class'Rockchip',,,Location);
		else
			spawn(class'FleshFragment',,,Location);
	}


	HurtRadius(explosionDamage, explosionRadius, 'Exploded', explosionDamage*100, Location);
}


// ----------------------------------------------------------------------
// InitFor()
// ----------------------------------------------------------------------

function InitFor(Actor Other)
{
	if (Other != None)
	{
		if (ScriptedPawn(Other) != None)
		{
			givenname = ScriptedPawn(Other).FamiliarName;
			givenbindname = scriptedpawn(other).bindname;
		}

		// set as unconscious or add the pawns name to the description
		// if (!bAnimalCarcass)
		// {
			if (bNotDead)
				itemName = msgNotDead;
			if (Other.IsA('ScriptedPawn'))
				itemName = itemName $ " (" $ ScriptedPawn(Other).FamiliarName $ ")";
			FamiliarName = itemName; // Required for DeusExPlayer.GetDisplayName
		// }

		Mass           = Other.Mass;
		Buoyancy       = Mass * 1.2;
		MaxDamage      = 0.8*Mass;
		if (ScriptedPawn(Other) != None)
			if (ScriptedPawn(Other).bBurnedToDeath)
				CumulativeDamage = MaxDamage-1;

		SetScaleGlow();

		// Will this carcass spawn flies?
		if (bAnimalCarcass && !bNotDead)
		{
			itemName = msgAnimalCarcass;
			if (Other.IsA('ScriptedPawn'))
				itemName = itemName $ " (" $ ScriptedPawn(Other).FamiliarName $ ")";
			if (FRand() < 0.2)
				bGenerateFlies = true;
		}
		else if (!Other.IsA('Robot') && !bNotDead)
		{
			if (FRand() < 0.1)
				bGenerateFlies = true;
		}

		if (Other.AnimSequence == 'DeathFront')
			Mesh = Mesh2;

		// set the instigator and tag information
		if (Other.Instigator != None)
		{
			KillerBindName = Other.Instigator.BindName;
			KillerAlliance = Other.Instigator.Alliance;
		}
		else
		{
			KillerBindName = Other.BindName;
			KillerAlliance = '';
		}
		Tag = Other.Tag;
		Alliance = Pawn(Other).Alliance;

		if (IsA('GenericScubaDiverCarcass') && bNotDead)
			AmbientSound = Sound'RebreatherLoop';
		CarcassName = Other.Name;
	}
}

function initagain()
{
	// if (!bAnimalCarcass)
	// {
		if (bNotDead)
			itemName = msgNotDead;
		else if (bAnimalCarcass)
			itemName = msgAnimalCarcass;
		else
			itemname = default.itemname;

		if (givenname!="")
			itemName = itemName $ " (" $ givenname $ ")";
		FamiliarName = itemName; // Required for DeusExPlayer.GetDisplayName
	// }
	if (IsA('GenericScubaDiverCarcass') && bNotDead)
		AmbientSound = Sound'RebreatherLoop';
}


// ----------------------------------------------------------------------
// ZoneChange()
// ----------------------------------------------------------------------

function ZoneChange(ZoneInfo NewZone)
{
	binwater = NewZone.bWaterZone;
	if (binwater)
		ExtinguishFire();
	Super.ZoneChange(NewZone);
}


function Tick(float deltaSeconds)
{
	local bool decrementburntimer;
	local TNMFire f;

	decrementburntimer = false;

	if ( lastrendertime > 0 ) //Not sure if its by design or a coincidence but -10 means never rendered so this checks that theyve been rendered.
		bSeen = true;

	Super.Tick(deltaSeconds);
	
	fat += deltaSeconds;
	if (fat >=0.5 && bNotDead)
	{
		fat = 0.0;
		if (fatness > default.fatness) //not sure if this will take the default fatness of TNMPawn or the class that is inheriting this method.
			fatness -= 1;
	}
	
	if (binwater || (TNMZoneInfo(Region.Zone) != None && TNMZoneInfo(Region.Zone).bNoOxygen))
	{
		// Athena needs to not have her scaleglow updated in order to respawn
		if (!IsA('AthenaCarcass') && !IsA('GenericScubaDiverCarcass'))
			drowntime -= deltaseconds;
		if (drowntime <= 0)
		{
			drowntime=default.drowntime;
			TakeDamage(5, None, Location, vect(0,0,0), 'Drowned');
		}
	}
	if (bAmbientFlaming)
	{
		foreach BasedActors(class'TNMFire', f)
			decrementburntimer = true;
	}
	else
		decrementburntimer = true;	

	if (decrementburntimer && bSeen)
		burntime -= deltaSeconds;

	if (burntime <= 0)
	{
		ExtinguishFire();
		bGenerateFlies = default.bGenerateFlies;
	}
	else
	{
		bGenerateFlies = false;
	}
	// if falling from space death
	if (bAtmosphericDeath)
		DrawScale *= 0.99;
}

// ----------------------------------------------------------------------
// Frob()
//
// search the body for inventory items and give them to the frobber
// ----------------------------------------------------------------------

function Frob(Actor Frobber, Inventory frobWith)
{
	local Inventory item, nextItem, startItem, tempitem, inv;
	local Pawn P;
	local DeusExWeapon W;
	local bool bFoundSomething;
	local DeusExPlayer player;
	local ammo AmmoType;
	local bool bPickedItemUp;
	local tnmPOVCorpse corpse;
	local DeusExPickup invItem;
	local int itemCount;
	local int i;
	local TNMFire f;
	local float stack_z;
	local bool bItemWasRefused;
	local vector loc;
	local Trestkon DeadTrest;
	local MedKit ReviveMed;

	// Smoke39 - don't frob flaming stuff, moron! XO
	foreach BasedActors( class'TNMFire', f )
	{
		Frobber.TakeDamage( 1 /*enough to set the jerk on fire*/, None, Location, vect(0,0,0), 'Flamed' );
		return;
	}

//log("DeusExCarcass::Frob()--------------------------------");

	// Can we assume only the *PLAYER* would actually be frobbing carci?
	player = DeusExPlayer(Frobber);

	// No doublefrobbing in multiplayer.
	if (bQueuedDestroy)
		return;

	// if we've already been searched (or are a co-op player carcass), let the player pick us up
	if (AttemptPickup(Frobber))
		return;

	bFoundSomething = False;
	bSearchMsgPrinted = False;
	P = Pawn(Frobber);
	if (P != None)
	{
		// Make sure the "Received Items" display is cleared
      // DEUS_EX AMSD Don't bother displaying in multiplayer.  For propagation
      // reasons it is a lot more of a hassle than it is worth.
		if ( (player != None) && (Level.NetMode == NM_Standalone) )
			DeusExRootWindow(player.rootWindow).hud.receivedItems.RemoveItems();

		if (Inventory != None && !bSearched)
		{
			item = Inventory;
			startItem = item;

			do
			{
//				log("===>DeusExCarcass:item="$item );

				nextItem = item.Inventory;

				bPickedItemUp = False;

				if (associatedRespawnInfo != None && item.IsA('DeusExPickup') && !item.IsA('FloppyDisk') && !item.IsA('Nanokey'))
				{
					// DeleteInventory(item);
					// item.Destroy();
					item = None;
				}
				if (item != None)
				{
					if (item.IsA('Ammo'))
					{
						// Only let the player pick up ammo that's already in a weapon
						DeleteInventory(item);
						item.Destroy();
						item = None;
					}
					else if ( (item.IsA('DeusExWeapon')) )
					{
					   // Any weapons have their ammo set to a random number of rounds (1-4)
					   // unless it's a grenade, in which case we only want to dole out one.
					   // DEUS_EX AMSD In multiplayer, give everything away.
					   W = DeusExWeapon(item);
				   
						// Grenades and LAMs always pickup 1
						if (W.IsA('WeaponNanoVirusGrenade') || 
						W.IsA('WeaponGasGrenade') || 
						W.IsA('WeaponEMPGrenade') ||
						W.IsA('WeaponMine') ||
						W.IsA('WeaponPlasmanade') ||
						W.IsA('WeaponTNMEMPGrenade') ||
						W.IsA('WeaponTNMGasGrenade') ||
						W.IsA('WeaponTNMNanoVirusGrenade') ||
						W.IsA('WeaponTripBomb') ||
						W.IsA('WeaponTripBomb') ||
						W.IsA('WeaponTNMLAM') ||
						W.IsA('WeaponLAM') ||
						W.IsA('WeaponBlackBox'))
							W.PickupAmmoCount = 1;
						else if (W.IsA('WeaponNapalmLauncher'))
							W.PickUpAmmoCount = W.PickUpAmmoCount / 5;
						else
						{
							if (W.Default.PickupAmmoCount == 0)
								W.PickupAmmoCount = 0;
							else if (W.Default.PickupAmmoCount <= 8)
								W.PickupAmmoCount = Rand(4) + 1;
							else
								W.PickupAmmoCount = 1 + Rand(W.Default.PickupAmmoCount) / 2;
						}
					}
				}
				
				if (item != None)
				{
					bFoundSomething = True;

					if (item.IsA('NanoKey'))
					{
						if (player != None)
						{
							player.PickupNanoKey(NanoKey(item));
							Nanokey(item).beltDescription = strPass;
							AddReceivedItem(player, item, 1);
							DeleteInventory(item);
							item.Destroy();
							item = None;
						}
						bPickedItemUp = True;
					}
					else if (item.IsA('Credits'))		// I hate special cases
					{
						if (player != None)
						{
							AddReceivedItem(player, item, Credits(item).numCredits);
							player.Credits += Credits(item).numCredits;
							P.ClientMessage(Sprintf(Credits(item).msgCreditsAdded, Credits(item).numCredits));
							DeleteInventory(item);
							item.Destroy();
							item = None;
						}
						bPickedItemUp = True;
					}
					else if (item.IsA('DeusExWeapon'))   // I *really* hate special cases
					{
						// Okay, check to see if the player already has this weapon.  If so,
						// then just give the ammo and not the weapon.  Otherwise give
						// the weapon normally. 
						W = DeusExWeapon(player.FindInventoryType(item.Class));

						// If the player already has this item in his inventory, piece of cake,
						// we just give him the ammo.  However, if the Weapon is *not* in the 
						// player's inventory, first check to see if there's room for it.  If so,
						// then we'll give it to him normally.  If there's *NO* room, then we 
						// want to give the player the AMMO only (as if the player already had 
						// the weapon).

						if ((W != None) || ((W == None) && (!player.FindInventorySlot(item, True))))
						{
							// Don't bother with this is there's no ammo
							if ((Weapon(item).AmmoType != None) && (Weapon(item).AmmoType.AmmoAmount > 0))
							{
								AmmoType = Ammo(player.FindInventoryType(Weapon(item).AmmoName));

								if ((AmmoType != None) && (AmmoType.AmmoAmount < AmmoType.MaxAmmo))
								{
									AmmoType.AddAmmo(Weapon(item).PickupAmmoCount);
									AddReceivedItem(player, AmmoType, Weapon(item).PickupAmmoCount);
                           
									// Update the ammo display on the object belt
									player.UpdateAmmoBeltText(AmmoType);

									// if this is an illegal ammo type, use the weapon name to print the message
									if (AmmoType.PickupViewMesh == Mesh'TestBox')
										P.ClientMessage(item.PickupMessage @ item.itemArticle @ item.itemName, 'Pickup');
									else
										P.ClientMessage(AmmoType.PickupMessage @ AmmoType.itemArticle @ AmmoType.itemName @ "("$Weapon(item).PickupAmmoCount$")", 'Pickup');

									// Mark it as 0 to prevent it from being added twice
									Weapon(item).AmmoType.AmmoAmount = 0;
								}
							}

							// Print a message "Cannot pickup blah blah blah" if inventory is full
							// and the player can't pickup this weapon, so the player at least knows
							// if he empties some inventory he can get something potentially cooler
							// than he already has. 
							if (W == None && (!player.FindInventorySlot(item, True)))
							{
								bItemWasRefused = False;
								if(Trestkon(P).GetItemRefusalSetting(item))
								{
									if (item != None && item.IsA('DeusExWeapon'))
										P.ClientMessage(Sprintf(Trestkon(P).ItemRefusedString, DeusExWeapon(item).itemName));
									else if (item != None && item.IsA('DeusExPickup'))
										P.ClientMessage(Sprintf(Trestkon(P).ItemRefusedString, DeusExPickup(item).itemName));
										
									DeleteInventory(item);
									loc = location;
									loc.X = location.X + FRand() * CollisionRadius;
									loc.Y = location.Y + FRand() * CollisionRadius;
									item.DropFrom(loc);
								}
								else
								{
									P.ClientMessage(Sprintf(Player.InventoryFull, item.itemName, item.invSlotsX, item.invSlotsY));
									if(item != None)
									{
										DeleteInventory(item);
										loc = location;
										loc.X = location.X + FRand() * CollisionRadius;
										loc.Y = location.Y + FRand() * CollisionRadius;
										item.DropFrom(loc);
									}
								}
							}
							
							if (TNMWeapon(item) != None && TNMWeapon(item).Attribute != Att_None)
							{
								DeleteInventory(item);
								loc = location;
								loc.X = location.X + FRand() * CollisionRadius;
								loc.Y = location.Y + FRand() * CollisionRadius;
								item.DropFrom(loc);
							}
							else
							{
								// Only destroy the weapon if the player already has it.
								if ((W != None) && (item != None))
								{
									// Destroy the weapon, baby!
									DeleteInventory(item);
									item.Destroy();
									item = None;
								}
							}

							bPickedItemUp = True;
						}
					}
					else if (item.IsA('DeusExAmmo'))
					{
						if (DeusExAmmo(item).AmmoAmount == 0)
							bPickedItemUp = True;
					}

					if (!bPickedItemUp && item != None)
					{
						// Special case if this is a DeusExPickup(), it can have multiple copies
						// and the player already has it.

						if ((item.IsA('DeusExPickup')) && (DeusExPickup(item).bCanHaveMultipleCopies) && (player.FindInventoryType(item.class) != None))
						{
							invItem   = DeusExPickup(player.FindInventoryType(item.class));
							itemCount = DeusExPickup(item).numCopies;

							// Make sure the player doesn't have too many copies
							if ((invItem.MaxCopies > 0) && (DeusExPickup(item).numCopies + invItem.numCopies > invItem.MaxCopies))
							{	
								// Give the player the max #
								if ((invItem.MaxCopies - invItem.numCopies) > 0)
								{
									itemCount = (invItem.MaxCopies - invItem.numCopies);
									DeusExPickup(item).numCopies -= itemCount;
									invItem.numCopies = invItem.MaxCopies;
									P.ClientMessage(invItem.PickupMessage @ invItem.itemArticle @ invItem.itemName, 'Pickup');
									AddReceivedItem(player, invItem, itemCount);
								}
								else
								{
									P.ClientMessage(Sprintf(msgCannotPickup, invItem.itemName));
									DeleteInventory(item);
									stack_z+=4.0;
									item.DropFrom(Location+vect(0,0,1)*stack_z+VRand()*CollisionRadius*vect(1,1,0));									
								}
							}
							else
							{
								invItem.numCopies += itemCount;
								DeleteInventory(item);
								P.ClientMessage(invItem.PickupMessage @ invItem.itemArticle @ invItem.itemName, 'Pickup');
								AddReceivedItem(player, invItem, itemCount);
							}
						}
						else if (item.IsA('DeusExPickup'))
						{
							if(Trestkon(P).GetItemRefusalSetting(item))
							{
								if (item != None && item.IsA('DeusExWeapon'))
									P.ClientMessage(Sprintf(Trestkon(P).ItemRefusedString, DeusExWeapon(item).itemName));
								else if (item != None && item.IsA('DeusExPickup'))
									P.ClientMessage(Sprintf(Trestkon(P).ItemRefusedString, DeusExPickup(item).itemName));
									
								DeleteInventory(item);
								loc = location;
								loc.X = location.X + FRand() * CollisionRadius;
								loc.Y = location.Y + FRand() * CollisionRadius;
								item.DropFrom(loc);
							}
							else if (!player.FindInventorySlot(item, True))
							{
								P.ClientMessage(Sprintf(Trestkon(P).InventoryFull, item.itemName, item.invSlotsX, item.invSlotsY));
								
								if(item != None)
								{
									DeleteInventory(item);
									loc = location;
									loc.X = location.X + FRand() * CollisionRadius;
									loc.Y = location.Y + FRand() * CollisionRadius;
									item.DropFrom(loc);
								}
							}
							else
							{							
								// check if the pawn is allowed to pick this up
								if ((P.Inventory == None) || (Level.Game.PickupQuery(P, item)))
								{
									DeusExPlayer(P).FrobTarget = item;
									if (DeusExPlayer(P).HandleItemPickup(Item) != False)
									{
									   DeleteInventory(item);

									   // DEUS_EX AMSD Belt info isn't always getting cleaned up.  Clean it up.
									   item.bInObjectBelt=False;
									   item.BeltPos=-1;
												
									   item.SpawnCopy(P);

										// Show the item received in the ReceivedItems window and also 
										// display a line in the Log
										AddReceivedItem(player, item, 1);
										
										P.ClientMessage(Item.PickupMessage @ Item.itemArticle @ Item.itemName, 'Pickup');
										PlaySound(Item.PickupSound);
									}
								}
							}
						}
						else
						{
							// if (!player.FindInventorySlot(item, True))
							// {
								// P.ClientMessage(Sprintf(Trestkon(P).InventoryFull, item.itemName, item.invSlotsX, item.invSlotsY));
								// DeleteInventory(item);
								// stack_z+=4.0;
								// item.DropFrom(Location+vect(0,0,1)*stack_z+VRand()*CollisionRadius*vect(1,1,0));
							// }
							// check if the pawn is allowed to pick this up
							/*else*/ if ((P.Inventory == None) || (Level.Game.PickupQuery(P, item)))
							{
								DeusExPlayer(P).FrobTarget = item;
								if (DeusExPlayer(P).HandleItemPickup(Item) != False)
								{
								   DeleteInventory(item);

								   // DEUS_EX AMSD Belt info isn't always getting cleaned up.  Clean it up.
								   item.bInObjectBelt=False;
								   item.BeltPos=-1;
											
								   item.SpawnCopy(P);

									// Show the item received in the ReceivedItems window and also 
									// display a line in the Log
									AddReceivedItem(player, item, 1);
									
									P.ClientMessage(Item.PickupMessage @ Item.itemArticle @ Item.itemName, 'Pickup');
									PlaySound(Item.PickupSound);
								}
							}
							else
							{								
								DeleteInventory(item);
								item.Destroy();
								item = None;
							}
						}
					}
				}

				item = nextItem;
			}
			until ((item == None) || (item == startItem));
		}

//log("  bFoundSomething = " $ bFoundSomething);
	}

    if ( !bFoundSomething || bSearched)
    {
		//G-Flex: try to pick up the body again
		if (AttemptPickup(Frobber))
			return;
		P.ClientMessage(msgEmpty);
	}


    // Smoke39 - record that we've been searched
    bSearched = true;

	if (False && (player != None) && (Level.Netmode != NM_Standalone))
	{
		player.ClientMessage(Sprintf(msgRecharged, 25));

		PlaySound(sound'BioElectricHiss', SLOT_None,,, 256);

		player.Energy += 25;
		if (player.Energy > player.EnergyMax)
			player.Energy = player.EnergyMax;
	}

//no idea why this is even there in their code	Super.Frob(Frobber, frobWith);

	if (False && (Level.Netmode != NM_Standalone) && (Player != None))   
	{
		bQueuedDestroy = true;
		Destroy();	  
	}
}

// ----------------------------------------------------------------------
// AttemptPickup()
//
// G-Flex: tries to pick up the corpse
// ----------------------------------------------------------------------

function bool AttemptPickup(Actor Frobber)
{
	local tnmPOVCorpse corpse;
	local DeusExPlayer player;
	local int i;
	
	player = DeusExPlayer(Frobber);
	
	// don't pick up animal carcii
	// DEUS_EX AMSD Since we don't have animations for carrying corpses, and since it has no real use in multiplayer,
	// and since the PutInHand propagation doesn't just work, this is work we don't need to do.
	// Were you to do it, you'd need to check the respawning issue, destroy the POVcorpse it creates and point to the
	// one in inventory (like I did when giving the player starting inventory).
	// Co-op (tnmGameInfo) allows it: the server spawns the POVCorpse and PutInHand replicates like any item.
	if (bPlayerCarcass && player != None && ((Level.NetMode == NM_Standalone) || (tnmGameInfo(Level.Game) != None)))
	{
		if (player.inHand != None)
		{
			player.SetInHandPending(None);
			player.SetInHand(None);
			player.Weapon = None;
		}
		player.FrobTarget = Self;
		player.GrabDecoration();
		return player.CarriedDecoration == Self;
	}

	if ((!bAnimalCarcass) && (Inventory == None) && (player != None) && (player.inHand == None) && ((Level.NetMode == NM_Standalone) || (tnmGameInfo(Level.Game) != None)))
	{
		if (!bInvincible && associatedRespawnInfo == None)
		{
			corpse = Spawn(class'tnmPOVCorpse');
			if (corpse != None)
			{
				// destroy the actual carcass and put the fake one
				// in the player's hands
				corpse.carcClassString = String(Class);
				corpse.KillerAlliance = KillerAlliance;
				corpse.KillerBindName = KillerBindName;
				corpse.Alliance = Alliance;
				corpse.bNotDead = bNotDead;
				corpse.bEmitCarcass = bEmitCarcass;
				corpse.CumulativeDamage = CumulativeDamage;
				corpse.MaxDamage = MaxDamage;
				corpse.CorpseItemName = itemName;
				corpse.CarcassName = CarcassName;
				corpse.Frob(player, None);
				corpse.SetBase(player);
				corpse.health = health;
				corpse.givenname = givenname;
				corpse.givenbindname = givenbindname;
				corpse.bImportant = bImportant;
				corpse.InheritedTag = Tag;
				for (i = 0;i<8;i++)
				{
					if (Multiskins[i] != None)
						corpse.InheritedMultiSkinsStr[i] = ""$Multiskins[i];
				}
				if (Skin != None)
					corpse.InheritedSkinStr = ""$Skin;
				if (Texture != None)
					corpse.InheritedTextureStr = ""$Texture;
				corpse.bCheckSkins=true;

				if (IsA('GenericScubaDiverCarcass') && corpse.bNotDead)
					corpse.AmbientSound = Sound'RebreatherLoop';
				player.PutInHand(corpse);
				bQueuedDestroy=True;
				if ( pool != none)
					pool.bStopExpanding = true;
				Destroy();
				return true;
			}
		}
	}
	else if ((bAnimalCarcass) && (Inventory == None) && (player != None) && (player.inHand == None) && ((Level.NetMode == NM_Standalone) || (tnmGameInfo(Level.Game) != None))) // Pick up animal carcasses like a prop
	{
		if (associatedRespawnInfo == None)
			Player.GrabDecoration();
		return Player.CarriedDecoration == Self;
	}
	
	return false;
}

function Landed(vector HitNormal)
{
	local Vector HitNorm;
	local vector traceLoc;
	local vector trace1, trace2;
	local vector temp;
	local rotator rot, rot2;	
	local TNMFire f;
		
	super.Landed(HitNormal);
		
	if (!Region.Zone.bWaterZone)
	{
		// Rotate carcass on ramp - pitch
		temp = vect(0,0,0);
		temp.X = 1;
		temp.Z = CollisionHeight * 2;
		traceLoc = temp >> Rotation;
		traceLoc = traceLoc + Location;
		Trace(trace1, HitNorm, traceLoc - vect(0,0,100), traceLoc,,);
		
		temp = vect(0,0,0);
		temp.X = -1;
		temp.Z = CollisionHeight * 2;
		traceLoc = temp >> Rotation;
		traceLoc = traceLoc + Location;
		Trace(trace2, HitNorm, traceLoc - vect(0,0,100), traceLoc,,);
		
		rot = Rotator(trace1 - trace2);
		if (Abs(rot.Pitch) < 8192 || Abs(rot.Pitch) > 65536 - 8192)
		{					
			// Rotate carcass on ramp - roll
			temp = vect(0,0,0);
			temp.Y = 1;
			temp.Z = CollisionHeight * 2;
			traceLoc = temp >> Rotation;
			traceLoc = traceLoc + Location;
			Trace(trace1, HitNorm, traceLoc - vect(0,0,100), traceLoc,,);
			
			temp = vect(0,0,0);
			temp.Y = -1;
			temp.Z = CollisionHeight * 2;
			traceLoc = temp >> Rotation;
			traceLoc = traceLoc + Location;
			Trace(trace2, HitNorm, traceLoc - vect(0,0,100), traceLoc,,);
			
			rot2 = Rotator(trace2 - trace1);
			rot.Roll = rot2.Pitch;
				
			if (Abs(rot.roll) < 8192 || Abs(rot.roll) > 65536 - 8192)
			{
				SetRotation(rot);
				
				// Offset model
				Trace(trace1, HitNorm, Location - vect(0,0,100), traceLoc,,);
				temp = vect(0,0,0);
				temp.X = CollisionRadius;
				trace2 = temp >> Rotation;
				trace2 = trace2 + Location;
				if (FastTrace(trace2, trace1)) // Prevent on stairs
					PrePivot.Z = VSize(trace1 - Location) * -1 + CollisionHeight + 2;
			}
		}
	}

	foreach BasedActors(class'TNMFire', f)
	{
		f.SetRotation(Rotation);
		f.PrePivot = PrePivot;
		f.PrePivot += vect(0,0,20);
	}
	
	// if (Velocity.Z < -420*2)
		// TakeDamage(21, none, Location, velocity, 'fell');
	if (Velocity.Z < -700)
		TakeDamage(-0.14 * (Velocity.Z + 700), None, Location, Velocity, 'fell');
}

//more (slightly modified) ddl inventory dropping stuff
static function FlingItem(inventory item, float str, vector loc)
{
	local vector dir;
	local InfoDeviceFragment Frag;

	dir = vrand();
	dir.Z += 1;
//	dir = dir >> rotation;

	if(datavaultimage(item) != none)
	{
		Frag = item.spawn(class'InfoDeviceFragment',,,loc,rotrand());

		if(frag != none)
		{
			frag.ImageClass = datavaultimage(item).Class;
			frag.bFixedrotationdir = true;
			frag.rotationrate = rotrand(false);
			frag.velocity = dir * str * 2 * (1 + frand()) / 5;
		}
		item.destroy();
		return;
	}

	if(!item.SetLocation(loc))
	{
	    item.Destroy();
	    return;
	}
	if(item.IsA('Weapon')) //do weap specific stuff, I guess
	{
		if (item.IsA('WeaponTNMLaserGun') || item.IsA('WeaponThrownCredits'))
		{
			item.Destroy();
			return;
		}
		weapon(item).AIRating = weapon(item).default.AIrating;
		weapon(item).bMuzzleFlash = 0;
		if (Weapon(item).AmmoType != None)
		{
			if (Weapon(item).AmmoType.PickupViewMesh == LodMesh'DeusExItems.TestBox') //'nades etc pickup 1
			{
				if(weapon(item).Ammotype.Class == Class'Deusex.AmmoNone') //swords, knives, etc
				{
					weapon(item).PickUpAmmoCount = 0;
					weapon(item).Ammotype.AmmoAmount = 0; //just in case?
				}
				else
				{
					weapon(item).PickupAmmoCount = 1; //Weapon(item).AmmoType.AmmoAmount;
    					Weapon(item).AmmoType.AmmoAmount = 0;
    					if(frand() > str * 0.001)
	    				{
	    					FlingProjectile(weapon(item),str,loc);
	    					item.Destroy();
							return;
					}
				}
			}
			else
				Weapon(item).PickupAmmoCount = rand(weapon(item).default.PickupAmmoCount) + 1;
		}
	}
	item.SetPhysics(PHYS_Falling);
	item.RemoteRole = ROLE_DumbProxy;
	item.NetPriority = 2.5;
	item.BecomePickup();
	item.bCollideWorld = true;
	item.GotoState('PickUp', 'Dropped');
	if (Nanokey(item) == None)
		item.Velocity = dir * str * 2 * (1 + frand());
	item.bFixedRotationDir = True;
	item.RotationRate = rotrand(true);
}

static function FlingProjectile(weapon weap, float str, vector loc)
{
	local projectile proj;
	local vector dir;

	if(weap.ProjectileClass == none)
		return;

	proj = weap.Spawn(weap.ProjectileClass,,,loc,rotator(vrand()));
	if(proj != none)
	{
		dir = vrand();
		dir.Z += 1;
		proj.Velocity = dir * str * 2 * (1 + frand());
		proj.bFixedRotationDir = True;
		proj.RotationRate = rotrand(true);
	}
}

//end ddl stuff

auto state Dead
{
	function HandleLanding()
	{
		local Vector HitLocation, HitNormal, EndTrace;
		local Actor hit;
		local vector offset;

		if (!bNotDead)
		{
			// trace down about 20 feet if we're not in water
			if (!Region.Zone.bWaterZone)
			{
				EndTrace = Location - vect(0,0,320);
				hit = Trace(HitLocation, HitNormal, EndTrace, Location, False);
				if (!bBloodPool || ((DeusExMPGame(Level.Game) != None) && (!DeusExMPGame(Level.Game).bSpawnEffects)))
				{
				   pool = None;
				}
				else
				{
					if ( Mesh == Mesh2 )
						offset.X = -BloodOffset;
					else
						offset.X = BloodOffset;
					offset.Y = 0;
					offset.Z = 0;
					offset = offset >> Rotation;
					pool = spawn(class'tnmBloodPool',,, HitLocation+HitNormal + offset , Rotator(HitNormal));
				}
				if (pool != None)
					pool.maxDrawScale = CollisionRadius / 40.0;
			}

			// alert NPCs that I'm food
			AIStartEvent('Food', EAITYPE_Visual);
		}

		// by default, the collision radius is small so there won't be as
		// many problems spawning carcii
		// expand the collision radius back to where it's supposed to be
		// don't change animal carcass collisions
		if (!bAnimalCarcass)
			SetCollisionSize(40.0, Default.CollisionHeight);

		// alert NPCs that I'm really disgusting
		if (bEmitCarcass)
			AIStartEvent('Carcass', EAITYPE_Visual);
	}

Begin:
	while (Physics == PHYS_Falling)
	{
		Sleep(1.0);
	}
	HandleLanding();
}		

//This carcass should never have been spawned in the first place so remove its blood decal.
function CleanBlood()
{
	if (pool != None)
		pool.Destroy();
}


function AddReceivedItem(DeusExPlayer player, Inventory item, int count)
{
	local DeusExWeapon w;
	local Inventory altAmmo;

	if (!bSearchMsgPrinted)
	{
		player.ClientMessage(msgSearching);
		bSearchMsgPrinted = True;
	}

	//G-Flex: see if we can make the proper ammo, credit, etc. amounts display
	//DeusExRootWindow(player.rootWindow).hud.receivedItems.AddItem(item, 1);
	DeusExRootWindow(player.rootWindow).hud.receivedItems.AddItem(item, count);

	// Make sure the object belt is updated
	if (item.IsA('Ammo'))
		player.UpdateAmmoBeltText(Ammo(item));
	else
		player.UpdateBeltText(item);

	// Deny 20mm and WP rockets off of bodies in multiplayer
	if ( Level.NetMode != NM_Standalone )
	{
		if ( item.IsA('WeaponAssaultGun') || item.IsA('WeaponGEPGun') )
		{
			w = DeusExWeapon(player.FindInventoryType(item.Class));
			if (( Ammo20mm(w.AmmoType) != None ) || ( AmmoRocketWP(w.AmmoType) != None ))
			{
				altAmmo = Spawn( w.AmmoNames[0] );
				DeusExAmmo(altAmmo).AmmoAmount = w.PickupAmmoCount;
				altAmmo.Frob(player,None);
				altAmmo.Destroy();
				w.AmmoType.Destroy();
				w.LoadAmmo( 0 );
			}
		}
	}
}

defaultproperties
{
     bBloodPool=True
     bInWorld=True
     Health=20.000000
     drowntime=2.000000
     BloodOffset=-20.000000
     burnTime=60.000000
     strPass="PASS"
     bEmitCarcass=True
}

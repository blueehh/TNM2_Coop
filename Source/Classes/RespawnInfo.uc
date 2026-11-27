class RespawnInfo extends TNMPawn;

var TNMCarcass associatedCarcass;
var class<TNMPawn> associatedPawn;

function Respawn()
{
	local int i;
	local TNMPawn ReplacementPawn;
	local inventory inv;
	
	if (associatedPawn != None && associatedCarcass != None && !bDeleteMe)
	{
		ReplacementPawn = Spawn( associatedPawn, Owner, Tag, Location, Rotation );
		
		if (ReplacementPawn != None)
		{
			Spawn(class'ExplosionLight',,, Location);
			Spawn(class'EllipseEffect',,, Location);
			ReplacementPawn.SetCollisionSize( associatedPawn.Default.CollisionRadius, associatedPawn.Default.CollisionHeight );
			ReplacementPawn.bCollideWorld = false;
			ReplacementPawn.SetLocation( Location );
			ReplacementPawn.SetRotation( Rotation );
			ReplacementPawn.bCollideWorld = bCollideWorld;
			
			ReplacementPawn.AmbientSound = AmbientSound;
			ReplacementPawn.SoundRadius  = SoundRadius;
			ReplacementPawn.SoundVolume  = SoundVolume;

			ReplacementPawn.SmellClass = SmellClass;
			ReplacementPawn.Tag = Tag;
			ReplacementPawn.Event = Event;

			ReplacementPawn.SightRadius = SightRadius;
			ReplacementPawn.PeripheralVision = PeripheralVision;
			ReplacementPawn.HearingThreshold = HearingThreshold;
			ReplacementPawn.AttitudeToPlayer = AttitudeToPlayer;
			ReplacementPawn.Intelligence = Intelligence;
			ReplacementPawn.AIHorizontalFov = AIHorizontalFov;
			ReplacementPawn.AspectRatio = AspectRatio;
			ReplacementPawn.AngularResolution = AngularResolution;
			ReplacementPawn.VisibilityThreshold = VisibilityThreshold;
			ReplacementPawn.SmellThreshold = SmellThreshold;
			ReplacementPawn.RandomWandering = RandomWandering;
			ReplacementPawn.bKeepWeaponDrawn = bKeepWeaponDrawn;
			ReplacementPawn.bShowPain = bShowPain;
			ReplacementPawn.bCanSit = bCanSit;
			ReplacementPawn.bAlwaysPatrol = bAlwaysPatrol;
			ReplacementPawn.bPlayIdle = bPlayIdle;
			ReplacementPawn.bLeaveAfterFleeing = bLeaveAfterFleeing;
			ReplacementPawn.bLikesNeutral = bLikesNeutral;
			ReplacementPawn.bUseFirstSeatOnly = bUseFirstSeatOnly;
			ReplacementPawn.bCower = bCower;
			ReplacementPawn.bEmitDistress = bEmitDistress;
			ReplacementPawn.RaiseAlarm = RaiseAlarm;
			ReplacementPawn.MaxProvocations = MaxProvocations;
			ReplacementPawn.EnemyTimeout = EnemyTimeout;
			ReplacementPawn.bHokeyPokey = bHokeyPokey;
			ReplacementPawn.bTickVisibleOnly = bTickVisibleOnly;
			ReplacementPawn.Skill = Skill;

			// var(Alliances)
			ReplacementPawn.Alliance = Alliance;

			for (i = 0; i< 8; i++)
			{
				ReplacementPawn.InitialAlliances[i].AllianceName = InitialAlliances[i].AllianceName;
				ReplacementPawn.InitialAlliances[i].AllianceLevel = InitialAlliances[i].AllianceLevel;
				ReplacementPawn.InitialAlliances[i].bPermanent = InitialAlliances[i].bPermanent;
			}

			// var(Combat) (some parts)
			ReplacementPawn.CombatStyle = CombatStyle;
			ReplacementPawn.bAvoidAim = bAvoidAim;
			ReplacementPawn.bDefendHome = bDefendHome;

			// var(Fears)
			ReplacementPawn.bFearHacking = bFearHacking;
			ReplacementPawn.bFearWeapon = bFearWeapon;
			ReplacementPawn.bFearShot = bFearShot;
			ReplacementPawn.bFearInjury = bFearInjury;
			ReplacementPawn.bFearIndirectInjury = bFearIndirectInjury;
			ReplacementPawn.bFearCarcass = bFearCarcass;
			ReplacementPawn.bFearDistress = bFearDistress;
			ReplacementPawn.bFearAlarm = bFearAlarm;
			ReplacementPawn.bFearProjectiles = bFearProjectiles;


			// var(Inventory)
			// delete old inventory
			for ( Inv = Inventory; Inv != None; Inv = Inv.Inventory )
				Inv.Destroy();

			// copy InitialInventory
			for (i = 0; i < 8; i++)
			{
				// reset
				ReplacementPawn.InitialInventory[i].Inventory = None;
				ReplacementPawn.InitialInventory[i].Count = 0;

				ReplacementPawn.InitialInventory[i].Inventory	= InitialInventory[i].Inventory;
				ReplacementPawn.InitialInventory[i].Count		= InitialInventory[i].Count;
			}
			for (i = 0; i < 8; i++)
			{
				ReplacementPawn.MultiSkins[i] = MultiSkins[i];
			}

			// var(Orders)
			ReplacementPawn.Orders = Orders;
			ReplacementPawn.OrderTag = OrderTag;
			ReplacementPawn.HomeTag = HomeTag;
			ReplacementPawn.HomeExtent = HomeExtent;
			ReplacementPawn.AlarmTag = AlarmTag;
			ReplacementPawn.SharedAlarmTag = SharedAlarmTag;
			ReplacementPawn.bFixedStart = bFixedStart;

			// var(Pawn) (some parts)
			// ReplacementPawn.Health = Health;
			ReplacementPawn.ReducedDamageType = ReducedDamageType;
			ReplacementPawn.ReducedDamagePct = ReducedDamagePct;
			// ReplacementPawn.HealthHead = HealthHead;
			// ReplacementPawn.HealthTorso = HealthTorso;
			// ReplacementPawn.HealthLegLeft = HealthLegLeft;
			// ReplacementPawn.HealthLegRight = HealthLegRight;
			// ReplacementPawn.HealthArmLeft = HealthArmLeft;
			// ReplacementPawn.HealthArmRight = HealthArmRight;

			// var(Reactions)
			ReplacementPawn.bReactFutz = bReactFutz;
			ReplacementPawn.bReactPresence = bReactPresence;
			ReplacementPawn.bReactLoudNoise = bReactLoudNoise;
			ReplacementPawn.bReactAlarm = bReactAlarm;
			ReplacementPawn.bReactShot = bReactShot;
			ReplacementPawn.bReactCarcass = bReactCarcass;
			ReplacementPawn.bReactDistress = bReactDistress;
			ReplacementPawn.bReactProjectiles = bReactProjectiles;

			// var(ScriptedPawn) (some parts)
			ReplacementPawn.bImportant = bImportant;
			ReplacementPawn.bInvincible = bInvincible;
			ReplacementPawn.bInWorld = bInWorld;

			// var(Stimuli)
			ReplacementPawn.bHateHacking = bHateHacking;
			ReplacementPawn.bHateWeapon = bHateWeapon;
			ReplacementPawn.bHateShot = bHateShot;
			ReplacementPawn.bHateInjury = bHateInjury;
			ReplacementPawn.bHateIndirectInjury = bHateIndirectInjury;
			ReplacementPawn.bHateCarcass = bHateCarcass;
			ReplacementPawn.bHateDistress = bHateDistress;
			
			ReplacementPawn.BindName = BindName;
			ReplacementPawn.BarkBindName = BarkBindName;
			
			ReplacementPawn.ConBindEvents();
			ReplacementPawn.InitializePawn();
			if (associatedCarcass != None)
				associatedCarcass.Destroy();
			Destroy();
		}
	}
}

function Tick(float deltaTime)
{
	if (LifeSpan < 5)
		Respawn();
}

function spawnbreathgen()
{
}

defaultproperties
{
     bHidden=True
     bStasis=False
     bForceStasis=False
     LifeSpan=30.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideActors=False
     bBlockActors=False
}

//=============================================================================
// TNMRobot.
//=============================================================================
class TNMRobot extends Robot
	abstract;

var bool bishoverbot;
var() bool dominatable;
var() bool bDisabled;
var() bool bRevertOrders;

var int i,j; //can be used as local int
var float temporalness;
var BanEffect 		ban_fx;


var float RebootTimer;

// SecurityBot3 exclusive
var bool bHasTreads;
var ScriptedTexture TreadTexture;
var int TreadOffset, ScriptedTexID;

var localized string strPassword, strPass;


//WCCC, 3/17/19: "Let me guess... Experimental?" "Very."
//-------------------
//When set to 0.0 (default), these don't run.
//When set to any other level, multiply effective height by the value in question.
//These apply to both sending footstep noise, and receiving noise in general.
//For optimization, it's recommended to keep these defaulted to 0.0.
//--------------------
//Both receive and send sound can be altered by setting ReceiveNoiseHeightTolerance and
//SendNoiseHeightTolerance. At 0 or less, the values do nothing. At 1.0, output is normal.
//Any value less than 1.0 will act as a divisor for how much height is accounted for.
//
//Example: If 1000 distance is present and 200 units of it is height, with a divisor of 0.5, let's
//do the math. 200 / 0.5 = 400. 1000 - 200 + 400 = 1200. Resulting in 83% output at said conditions.
//
//My honest to god advice: Play with the setting, and see what works. Use this math formula
//to sketch some examples in a ballpark fashion. 

var(TNMExperimental) float ReceiveNoiseHeightTolerance;
var(TNMExperimental) float SendNoiseHeightTolerance;

//Less experimental, but this is our footstep sending range.
//In vanilla, this defaults to 768 and 2048, respectively.
var() float FootstepProjectRadius;
var() float FootstepProjectMaxRadius;

var bool bPlatformer;
var int xAxis;
var int yAxis;
var() bool bRadishCinematic;

//<FIREWALL VARS>
	var bool bFirewall;
	var bool bFading;
	var float FadeTime;
//</FIREWALL VARS>

//WCCC, 3/17/19: Scale things based on the factor in question, and height differences between other and us.
// ----------------------------------------------------------------------
// Co-op: stock ScriptedPawn resolves "the player" to GetPlayerPawn() (always
// the host on a listen server) when noticing beams, blaming hacks/decoration
// events and picking an untagged order target. Use the relevant player.
// ----------------------------------------------------------------------

function Pawn CoopPlayerFor(Actor A)
{
	if ((Level.NetMode != NM_Standalone) && (tnmGameInfo(Level.Game) != None))
		return tnmGameInfo(Level.Game).CoopClosestPlayer(A);
	return GetPlayerPawn();
}

function bool CheckBeamPresence(float deltaSeconds)
{
	local DeusExPlayer player;
	local Beam beamActor;

	if (Level.NetMode == NM_Standalone)
		return Super.CheckBeamPresence(deltaSeconds);

	// any player's beam, and no LastRendered() gate (that is the host's view)
	if (bReactPresence && bLookingForEnemy && (BeamCheckTimer <= 0))
	{
		BeamCheckTimer = 1.0;
		foreach RadiusActors(Class'Beam', beamActor, 1200)
		{
			player = DeusExPlayer(beamActor.Owner);
			if ((player == None) || !IsValidEnemy(player))
				continue;
			if ((beamActor.LightType == LT_None) || (beamActor.LightBrightness <= 32))
				continue;
			if ((VSize(beamActor.Location - Location) < (beamActor.LightRadius+1)*25) ||
			    ((AICanSee(beamActor, , false, true, false, false) > 0) && FastTrace(beamActor.Location, Location+vect(0,0,1)*BaseEyeHeight)))
			{
				HandleSighting(player);
				break;
			}
		}
	}
	return False;
}

function HandleHacking(Name event, EAIEventState state, XAIParams params)
{
	local Pawn pawnActor;

	if (Level.NetMode == NM_Standalone)
	{
		Super.HandleHacking(event, state, params);
		return;
	}

	if (state == EAISTATE_Begin || state == EAISTATE_Pulse)
	{
		// the hacked device sends the event; blame the player at it
		if (params.bestActor != None)
			pawnActor = CoopPlayerFor(params.bestActor);
		else
			pawnActor = CoopPlayerFor(self);
		if (pawnActor != None)
		{
			if (bHateHacking)
				IncreaseAgitation(pawnActor, 1.0);
			if (bFearHacking)
				IncreaseFear(pawnActor, 0.51);
			if (SetEnemy(pawnActor))
			{
				SetDistressTimer();
				HandleEnemy();
			}
			else if (bFearHacking && IsFearful())
			{
				SetDistressTimer();
				SetEnemy(pawnActor, , true);
				GotoState('Fleeing');
			}
			else
				ReactToFutz();
		}
	}
}

function Pawn InstigatorToPawn(Actor eventActor)
{
	local Pawn pawnActor;

	if (Level.NetMode == NM_Standalone)
		return Super.InstigatorToPawn(eventActor);

	if (Inventory(eventActor) != None)
	{
		if (Inventory(eventActor).Owner != None)
			eventActor = Inventory(eventActor).Owner;
	}
	else if (DeusExDecoration(eventActor) != None)
		eventActor = CoopPlayerFor(eventActor);		// stock: GetPlayerPawn()
	else if (DeusExProjectile(eventActor) != None)
		eventActor = eventActor.Instigator;

	pawnActor = Pawn(eventActor);
	if (pawnActor == self)
		pawnActor = None;

	return pawnActor;
}

function Actor FindTaggedActor(Name actorTag, optional bool bRandom, optional Class<Actor> tagClass)
{
	// stock: no tag means GetPlayerPawn()
	if ((actorTag == '') && (Level.NetMode != NM_Standalone))
		return CoopPlayerFor(self);
	return Super.FindTaggedActor(actorTag, bRandom, tagClass);
}

function float ScaleSoundByHeight(float Factor, Pawn Other)
{
	local float RetVal;
	local Vector OLoc, SLoc;
	local float GetDist, ODist, HeightDist;
	
	if (Other == None || Factor <= 0) return 1.0;
	
	OLoc = Other.Location - (vect(0,0,1) * (Other.CollisionHeight/2));
	SLoc = Location - (vect(0,0,1) * (CollisionHeight/2));
	
	GetDist = VSize(OLoc - SLoc);
	HeightDist = Abs(OLoc.Z - SLoc.Z);
	ODist = GetDist - HeightDist;
	HeightDist /= Factor;
	ODist += HeightDist;
	
	//NOTES: The more height we're comprised of, the more we treat like there's distance between us and sender.
	//More factor also equates to easier desensitization.
	RetVal = GetDist / ODist;
	
	return RetVal;
}

// ----------------------------------------------------------------------
// LoudNoiseScore()
// ----------------------------------------------------------------------

function float LoudNoiseScore(actor receiver, actor sender, float score)
{
	local Pawn pawnSender;
	
	// Cull events received from friends
	pawnSender = Pawn(sender);
	if (pawnSender == None)
		pawnSender = sender.Instigator;
	if (pawnSender == None)
		score = 0;
	else if (!IsValidEnemy(pawnSender))
		score = 0;
	
	//WCCC, 3/17/19: Experimental noise reception, relative to height. Spicy.
	else if ((PawnSender != None) && (ReceiveNoiseHeightTolerance > 0))
	{
		Score *= ScaleSoundByHeight(ReceiveNoiseHeightTolerance, PawnSender);
	}
	
	return score;
}


// ----------------------------------------------------------------------
// PlayFootStep()
//
// Plays footstep sounds based on the texture group
// (yes, I know this looks nasty -- I'll have to figure out a cleaner way to do this)
// ----------------------------------------------------------------------
// WCCC, 3/17/19: Copied and pasted for modifications relating to experimental stuff.

function PlayFootStep()
{
	local Sound stepSound;
	local float rnd;
	local name mat;
	local float speedFactor, massFactor;
	local float volume, pitch, range;
	local float radius, maxRadius, PlayRadius, PlayRange; //NOTE: Play radius + Range are hacks for sound vs emission range.
	local float volumeMultiplier;

	local DeusExPlayer dxPlayer;
	local float shakeRadius, shakeMagnitude;
	local float playerDist;

	rnd = FRand();
	mat = GetFloorMaterial();

	volumeMultiplier = 1.0;
	if (WalkSound == None)
	{
		if (FootRegion.Zone.bWaterZone)
		{
			if (rnd < 0.33)
				stepSound = Sound'WaterStep1';
			else if (rnd < 0.66)
				stepSound = Sound'WaterStep2';
			else
				stepSound = Sound'WaterStep3';
		}
		else
		{
			switch(mat)
			{
				case 'Carpet':
				case 'Textile':
				case 'Paper':
				case 'Charts':
				case 'WallDeco':
					volumeMultiplier = 0.7;
					if (rnd < 0.25)
						stepSound = Sound'CarpetStep1';
					else if (rnd < 0.5)
						stepSound = Sound'CarpetStep2';
					else if (rnd < 0.75)
						stepSound = Sound'CarpetStep3';
					else
						stepSound = Sound'CarpetStep4';
					break;

				case 'Foliage':
				case 'Earth':
					volumeMultiplier = 0.6;
					if (rnd < 0.25)
						stepSound = Sound'GrassStep1';
					else if (rnd < 0.5)
						stepSound = Sound'GrassStep2';
					else if (rnd < 0.75)
						stepSound = Sound'GrassStep3';
					else
						stepSound = Sound'GrassStep4';
					break;
				case 'MuffledMetal':
					volumeMultiplier = 0.50;
					if (rnd < 0.25)
						stepSound = Sound'MetalStep1';
					else if (rnd < 0.5)
						stepSound = Sound'MetalStep2';
					else if (rnd < 0.75)
						stepSound = Sound'MetalStep3';
					else
						stepSound = Sound'MetalStep4';
					break;

				case 'Metal':
				case 'Server':
				case 'Ladder':
				case 'SpaceStation':
					volumeMultiplier = 1.0;
					if (rnd < 0.25)
						stepSound = Sound'MetalStep1';
					else if (rnd < 0.5)
						stepSound = Sound'MetalStep2';
					else if (rnd < 0.75)
						stepSound = Sound'MetalStep3';
					else
						stepSound = Sound'MetalStep4';
					break;

				case 'Ceramic':
				case 'Glass':
				case 'Tiles':
					volumeMultiplier = 0.7;
					if (rnd < 0.25)
						stepSound = Sound'TileStep1';
					else if (rnd < 0.5)
						stepSound = Sound'TileStep2';
					else if (rnd < 0.75)
						stepSound = Sound'TileStep3';
					else
						stepSound = Sound'TileStep4';
					break;

				case 'Wood':
				case 'Books':
					volumeMultiplier = 0.7;
					if (rnd < 0.25)
						stepSound = Sound'WoodStep1';
					else if (rnd < 0.5)
						stepSound = Sound'WoodStep2';
					else if (rnd < 0.75)
						stepSound = Sound'WoodStep3';
					else
						stepSound = Sound'WoodStep4';
					break;

				case 'Brick':
				case 'Concrete':
				case 'Stone':
				case 'Stucco':
				default:
					volumeMultiplier = 0.7;
					if (rnd < 0.25)
						stepSound = Sound'StoneStep1';
					else if (rnd < 0.5)
						stepSound = Sound'StoneStep2';
					else if (rnd < 0.75)
						stepSound = Sound'StoneStep3';
					else
						stepSound = Sound'StoneStep4';
					break;
			}
		}
	}
	else
		stepSound = WalkSound;

	// compute sound volume, range and pitch, based on mass and speed
	speedFactor = VSize(Velocity)/120.0;
	massFactor  = Mass/150.0;
	
	radius      = FootStepProjectRadius; //WCCC, 3/17/19: Defaults to 768, for reference.
	PlayRadius = Radius;
	//WCCC, 3/17/19: Experimental noise reception, relative to height. Spicy.
	if ((GetPlayerPawn() != None) && (SendNoiseHeightTolerance > 0))
	{
		PlayRadius *= ScaleSoundByHeight(SendNoiseHeightTolerance, GetPlayerPawn());
	}
	
	maxRadius   = FootstepProjectMaxRadius; //Secondary note: Defaults to 2048.
//	volume      = (speedFactor+0.2)*massFactor;
//	volume      = (speedFactor+0.7)*massFactor;
	volume      = massFactor*1.5;
	
	range       = radius * volume;
	PlayRange   = PlayRadius * Volume;
	pitch       = (volume+0.5);
	volume      = 1.0;
	
	range       = FClamp(range, 0.01, maxRadius);
	PlayRange   = FClamp(PlayRange, 0.01, maxRadius);
	pitch       = FClamp(pitch, 1.0, 1.5);
	
	// play the sound and send an AI event
	PlaySound(stepSound, SLOT_Interact, volume, , PlayRange, pitch);
	AISendEvent('LoudNoise', EAITYPE_Audio, volume*volumeMultiplier, range*volumeMultiplier);
	
	// Shake the camera when heavy things tread
	if (Mass > 400)
	{
		dxPlayer = DeusExPlayer(GetPlayerPawn());
		if (dxPlayer != None)
		{
			playerDist = DistanceFromPlayer;
			shakeRadius = FClamp((Mass-400)/600, 0, 1.0) * (PlayRange*0.5); //NOTE: Scale this by height, too, since it's player-side only.
			shakeMagnitude = FClamp((Mass-400)/1600, 0, 1.0);
			shakeMagnitude = FClamp(1.0-(playerDist/shakeRadius), 0, 1.0) * shakeMagnitude;
			if (shakeMagnitude > 0)
				dxPlayer.JoltView(shakeMagnitude);
		}
	}
}


function PreBeginPlay()
{
	local bool bAlreadyAdded;
	local Pawn Pawn;
		
	// Copied in and tweaked Pawn's and ScriptedPawn's PreBeginPlay.
	
	// Bjorn: Add Pawn to PawnList (on client) if not already in the list (crashes if added twice).
	bAlreadyAdded = False;
	for ( Pawn=Level.PawnList; Pawn!=None; Pawn=Pawn.NextPawn )
	{
		if ( Pawn==Self )
		{
			bAlreadyAdded = true;
			break;
		}
	}	
	if ( !bAlreadyAdded )
	{
		AddPawn();
	
		//Skip Pawn's and ScriptdPawn's PreBeginPlay and do Actor's directly since we are overriding.
		Super(Actor).PreBeginPlay();
		
		if ( bDeleteMe )
			return;

		// Added angular size computation - DEUS_EX STM
		MinAngularSize = tan(AngularResolution*0.5*Pi/180.0);
		MinAngularSize *= MinAngularSize;

		// Set instigator to self.
		Instigator = Self;
		DesiredRotation = Rotation;
		SightCounter = 0.2 * FRand();  //offset randomly 
		if ( Level.Game != None )
			Skill += Level.Game.Difficulty; 
		Skill = FClamp(Skill, 0, 3);
		PreSetMovement();
		
		if ( DrawScale != Default.Drawscale )
		{
			SetCollisionSize(CollisionRadius*DrawScale/Default.DrawScale, CollisionHeight*DrawScale/Default.DrawScale);
			Health = Health * DrawScale/Default.DrawScale;
		}

		if (bIsPlayer && Role == ROLE_Authority)
		{
			if (PlayerReplicationInfoClass != None)
				PlayerReplicationInfo = Spawn(PlayerReplicationInfoClass, Self,,vect(0,0,0),rot(0,0,0));
			else
				PlayerReplicationInfo = Spawn(class'PlayerReplicationInfo', Self,,vect(0,0,0),rot(0,0,0));
			InitPlayerReplicationInfo();
		}

		// Bjorn: Removed BaseEyeHeight code that ScriptedPawn had to undo.
		if (!bIsPlayer) 
		{
			if (Fatness == 0) //vary monster fatness slightly if at default
				Fatness = 120 + Rand(8) + Rand(8);
		}

		if ( menuname == "" )
			menuname = GetItemName(string(class));

		if (SelectionMesh == "")
			SelectionMesh = string(Mesh);

		// create our shadow
		CreateShadow();

		// Set our alliance
		SetAlliance(Alliance);

		// Set up callbacks
		UpdateReactionCallbacks();
	}
}

function bool CanConverse()
{
	return !IsInState('Disabled') && super.CanConverse();
}

function PlayEnabled()
{
}

function InitializePawn()
{
	super.InitializePawn();
	if(bDisabled)
		GotoState('Disabled');
}

state Disabled
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		if(EMPHitPoints>0)
			bDisabled=false;
	}
	
	function BeginState()
	{
		local name flagName;
		local Trestkon player;
		
		if (EMPHitPoints <= 0 && bImportant)
		{
			player=Trestkon(GetPlayerPawn());
			flagName = player.rootWindow.StringToName(BindName$"_Disabled");
			player.flagBase.SetBool(flagName, True);
			player.flagBase.SetExpiration(flagName, FLAG_Bool, 0);
		}
		if (bFirewall)
			GoToState('FirewallDeath');
		else
			Super.BeginState();
			
		player = Trestkon(GetPlayerPawn());

		if (player != None)
		{
			// Abort any conversation we may have been having with the NPC
			if (bInConversation)
				player.AbortConversation();

			// Abort any barks we may have been playing
			if (player.BarkManager != None)
				player.BarkManager.ScriptedPawnDied(Self);
		}
		SetEnemy(None,,true);
	}

Begin:
	bDisabled=true;
	Acceleration=vect(0,0,0);
	DesiredRotation=Rotation;
	PlayDisabled();

Disabled:
	if(!bDisabled)
	{
		PlayEnabled();
		FinishAnim();
		SetOrders('Standing',,true);
	}
	Sleep(0.25);
	Goto('Disabled');
}

state Rebooting
{
	ignores bump, frob, reacttoinjury;
	function BeginState()
	{
		StandUp();
		BlockReactions(true);
		bCanConverse = False;
		SeekPawn = None;
	}
	function EndState()
	{
		ResetReactions();
		bCanConverse = True;
	}

Begin:
	Acceleration=vect(0,0,0);
	DesiredRotation=Rotation;
	PlayDisabled();

Rebooting:
}

function becomedominated(trestkon dominator)
{
alliance = 'player';
gotostate('dominated');
}

state dominated
{
ignores all;
	function AnimEnd()
	{
		PlayWaiting();
	}

	function BeginState()
	{
		StandUp();
		SetEnemy(None, EnemyLastSeen, true);
		Disable('AnimEnd');
		bCanJump = false;
		SetupWeapon(false);
		SetDistress(false);
		SeekPawn = None;
		EnableCheckDestLoc(false);
	}

	function EndState()
	{
		local int i;
		bAcceptBump = True;

		EnableCheckDestLoc(false);

		// Clear out our list of last visited points
		for (i=0; i<ArrayCount(lastPoints); i++)
			lastPoints[i] = None;

		if (JumpZ > 0)
			bCanJump = true;
	}

//			MoveTo(destLoc, GetWalkingSpeed());
begin:
	Acceleration = vect(0, 0, 0);
}

function bool IsPrimaryDamageType(name damageType)
{
	local bool bPrimary;

	switch (damageType)
	{
		case 'Exploded':
		case 'TearGas':
		case 'HalonGas':
		case 'PoisonGas':
		case 'PoisonEffect':
		case 'Radiation':
		case 'Drowned':
		case 'NanoVirus':
		case 'RocketJump':
			bPrimary = false;
			break;

		case 'Stunned':
		case 'StunnedTaser':
		case 'KnockedOut':
		case 'Burned':
		case 'Flamed':
		case 'Poison':
		case 'Shot':
		case 'Sabot':
		case 'EMP':
		case 'FistEMP':
		default:
			bPrimary = true;
			break;
	}

	return (bPrimary);
}

// ----------------------------------------------------------------------
// FilterDamageType()
// ----------------------------------------------------------------------

function bool FilterDamageType(Pawn instigatedBy, Vector hitLocation,
                               Vector offset, Name damageType)
{
	// Special cases for certain damage types
	if (damageType == 'HalonGas')
		if (bOnFire)
			ExtinguishFire();

	if (damageType == 'EMP' || damageType == 'FistEMP')
	{
		return true;
	}

	return true;
}

function bool IgnoreDamageType(Name damageType)
{
	if (damageType == 'Fat')
		return True;
	else if (Super.IgnoreDamageType(damageType))
		return True;
	else
		return False;
}

function TakeDamageBase(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType, bool bPlayAnim)
{
	local float actualDamage;
	local int oldEMPHitPoints;

	if(damageType=='FistEMP')
	{
		damageType='EMP';
		Damage*=2.5;
	}

	if ( bInvincible )
		return;
	
	if (DamageType == 'Temporal')
	{
		if (!bInvincible)
		{
			if (Damage > 0)
			{
				Momentum = Vect(0,0,0);
				temporalness += damage;
				Damage = 0;
			}
		}
	}

	super.TakeDamageBase(Damage, instigatedBy, hitlocation, momentum, damageType, bplayanim);

	// enough EMP damage shuts down the robot
	if (damageType == 'EMP')
	{
		ReactToInjury(instigatedBy, damageType, HITLOC_None);
	}
	
}

// ----------------------------------------------------------------------
// state Seeking
//
// Look for enemies in the area
// ----------------------------------------------------------------------

State Seeking
{
	function SetFall()
	{
		StartFalling('Seeking', 'ContinueSeek');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Global.HitWall(HitNormal, Wall);
		CheckOpenDoor(HitNormal, Wall);
	}

	function bool GetNextLocation(out vector nextLoc)
	{
		local float   dist;
		local rotator rotation;
		local bool    bDone;
		local float   seekDistance;
		local Actor   hitActor;
		local vector  HitLocation, HitNormal;
		local vector  diffVect;
		local bool    bLOS;

		if (bSeekLocation)
		{
			if (SeekType == SEEKTYPE_Guess)
				seekDistance = (200+FClamp(GroundSpeed*EnemyLastSeen*0.5, 0, 1000));
			else
				seekDistance = 300;
		}
		else
			seekDistance = 60;

		dist  = VSize(Location-destLoc);
		bDone = false;
		bLOS  = false;

		if (dist < seekDistance)
		{
			bLOS = true;
			foreach TraceVisibleActors(Class'Actor', hitActor, hitLocation, hitNormal,
			                           destLoc, Location+vect(0,0,1)*BaseEyeHeight)
			{
				if (hitActor != self)
				{
					if (hitActor == Level)
						bLOS = false;
					else if (IsPointInCylinder(hitActor, destLoc, 16, 16))
						break;
					else if (hitActor.bBlockSight && !hitActor.bHidden)
						bLOS = false;
				}
				if (!bLOS)
					break;
			}
		}

		if (!bLOS)
		{
			if (PointReachable(destLoc))
			{
				rotation = Rotator(destLoc - Location);
				if (seekDistance == 0)
					nextLoc = destLoc;
				else if (!AIDirectionReachable(destLoc, rotation.Yaw, rotation.Pitch, 0, seekDistance, nextLoc))
					bDone = true;
				if (!bDone && bDefendHome && !IsNearHome(nextLoc))
					bDone = true;
				if (!bDone)  // hack, because Unreal's movement code SUCKS
				{
					diffVect = nextLoc - Location;
					if (Physics == PHYS_Walking)
						diffVect *= vect(1,1,0);
					if (VSize(diffVect) < 20)
						bDone = true;
					else if (IsPointInCylinder(self, nextLoc, 10, 10))
						bDone = true;
				}
			}
			else
			{
				MoveTarget = FindPathTo(destLoc);
				if (MoveTarget == None)
					bDone = true;
				else if (bDefendHome && !IsNearHome(MoveTarget.Location))
					bDone = true;
				else
					nextLoc = MoveTarget.Location;
			}
		}
		else
			bDone = true;

		return (!bDone);
	}

	function bool PickDestination()
	{
		local bool bValid;

		bValid = false;
		if (/*(EnemyLastSeen <= 25.0) &&*/ (SeekLevel > 0))
		{
			if (bSeekLocation)
			{
				bValid  = true;
				destLoc = LastSeenPos;
			}
			else
			{
				bValid = AIPickRandomDestination(130, 250, 0, 0, 0, 0, 2, 1.0, destLoc);
				if (!bValid)
				{
					bValid  = true;
					destLoc = Location + VRand()*50;
				}
				else
					destLoc += vect(0,0,1)*BaseEyeHeight;
			}
		}

		return (bValid);
	}

	function NavigationPoint GetOvershootDestination(float randomness, optional float focus)
	{
		local NavigationPoint navPoint, bestPoint;
		local float           distance;
		local float           score, bestScore;
		local int             yaw;
		local rotator         rot;
		local float           yawCutoff;

		if (focus <= 0)
			focus = 0.6;

		yawCutoff = int(32768*focus);
		bestPoint = None;
		bestScore = 0;

		foreach ReachablePathnodes(Class'NavigationPoint', navPoint, None, distance)
		{
			if (distance < 1)
				distance = 1;
			rot = Rotator(navPoint.Location-Location);
			yaw = rot.Yaw + (16384*randomness);
			yaw = (yaw-Rotation.Yaw) & 0xFFFF;
			if (yaw > 32767)
				yaw  -= 65536;
			yaw = abs(yaw);
			if (yaw <= yawCutoff)
			{
				score = yaw/distance;
				if ((bestPoint == None) || (score < bestScore))
				{
					bestPoint = navPoint;
					bestScore = score;
				}
			}
		}

		return bestPoint;
	}

	function Tick(float deltaSeconds)
	{
		animTimer[1] += deltaSeconds;
		Global.Tick(deltaSeconds);
		UpdateActorVisibility(Enemy, deltaSeconds, 1.0, true);
	}

	function HandleLoudNoise(Name event, EAIEventState state, XAIParams params)
	{
		local Actor bestActor;
		local Pawn  instigator;

		if (state == EAISTATE_Begin || state == EAISTATE_Pulse)
		{
			bestActor = params.bestActor;
			if ((bestActor != None) && (EnemyLastSeen > 2.0))
			{
				instigator = Pawn(bestActor);
				if (instigator == None)
					instigator = bestActor.Instigator;
				if (instigator != None)
				{
					if (IsValidEnemy(instigator))
					{
						SetSeekLocation(instigator, bestActor.Location, SEEKTYPE_Sound);
						destLoc = LastSeenPos;
						if (bInterruptSeek)
							GotoState('Seeking', 'GoToLocation');
					}
				}
			}
		}
	}

	function HandleSighting(Pawn pawnSighted)
	{
		if ((EnemyLastSeen > 2.0) && IsValidEnemy(pawnSighted))
		{
			SetSeekLocation(pawnSighted, pawnSighted.Location, SEEKTYPE_Sight);
			destLoc = LastSeenPos;
			if (bInterruptSeek)
				GotoState('Seeking', 'GoToLocation');
		}
	}

	function BeginState()
	{
		StandUp();
		Disable('AnimEnd');
		destLoc = LastSeenPos;
		SetReactions(true, true, false, true, true, true, true, true, true, false, true, true);
		bCanConverse = False;
		bStasis = False;
		SetupWeapon(true);
		SetDistress(false);
		bInterruptSeek = false;
		EnableCheckDestLoc(false);
	}

	function EndState()
	{
		EnableCheckDestLoc(false);
		Enable('AnimEnd');
		ResetReactions();
		bCanConverse = True;
		bStasis = True;
		StopBlendAnims();
		SeekLevel = 0;
	}

Begin:
	WaitForLanding();
	PlayWaiting();
	if ((Weapon != None) && bKeepWeaponDrawn && (Weapon.CockingSound != None) && !bSeekPostCombat)
		PlaySound(Weapon.CockingSound, SLOT_None,,, 1024);
	Acceleration = vect(0,0,0);
	if (!PickDestination())
		Goto('DoneSeek');

GoToLocation:
	bInterruptSeek = true;
	Acceleration = vect(0,0,0);

	if ((DeusExWeapon(Weapon) != None) && DeusExWeapon(Weapon).CanReload() && !Weapon.IsInState('Reload'))
		DeusExWeapon(Weapon).ReloadAmmo();

	if (bSeekPostCombat)
		PlayPostAttackSearchingSound();
	else if (SeekType == SEEKTYPE_Sound)
		PlayPreAttackSearchingSound();
	else if (SeekType == SEEKTYPE_Sight)
	{
		if (ReactionLevel > 0.5)
			PlayPreAttackSightingSound();
	}
	else if ((SeekType == SEEKTYPE_Carcass) && bSeekLocation)
		PlayCarcassSound();

	StopBlendAnims();

	if ((SeekType == SEEKTYPE_Sight) && bSeekLocation)
		Goto('TurnToLocation');

	EnableCheckDestLoc(true);
	while (GetNextLocation(useLoc))
	{
		if (ShouldPlayWalk(useLoc))
			PlayRunning();
		MoveTo(useLoc, MaxDesiredSpeed);
		CheckDestLoc(useLoc);
	}
	EnableCheckDestLoc(false);

	if ((SeekType == SEEKTYPE_Guess) && bSeekLocation)
	{
		MoveTarget = GetOvershootDestination(0.5);
		if (MoveTarget != None)
		{
			if (ShouldPlayWalk(MoveTarget.Location))
				PlayRunning();
			MoveToward(MoveTarget, MaxDesiredSpeed);
		}

		if (AIPickRandomDestination(CollisionRadius*2, 200+FRand()*200, Rotation.Yaw, 0.75, Rotation.Pitch, 0.75, 2,
		                            0.4, useLoc))
		{
			if (ShouldPlayWalk(useLoc))
				PlayRunning();
			MoveTo(useLoc, MaxDesiredSpeed);
		}
	}

TurnToLocation:
	Acceleration = vect(0,0,0);
	PlayTurning();
	if ((SeekType == SEEKTYPE_Guess) && bSeekLocation)
		destLoc = Location + Vector(Rotation+(rot(0,1,0)*(Rand(16384)-8192)))*1000;
	if (bCanTurnHead)
	{
		Sleep(0);  // needed to turn head
		LookAtVector(destLoc, true, false, true);
		TurnTo(Vector(DesiredRotation)*1000+Location);
	}
	else
		TurnTo(destLoc);
	bSeekLocation = false;
	bInterruptSeek = false;

	PlayWaiting();
	Sleep(FRand()*1.5+3.0);

LookAround:
	if (bCanTurnHead)
	{
		if (FRand() < 0.5)
		{
			if (!bSeekLocation)
			{
				PlayTurnHead(LOOK_Left, 1.0, 1.0);
				Sleep(1.0);
			}
			if (!bSeekLocation)
			{
				PlayTurnHead(LOOK_Forward, 1.0, 1.0);
				Sleep(0.5);
			}
			if (!bSeekLocation)
			{
				PlayTurnHead(LOOK_Right, 1.0, 1.0);
				Sleep(1.0);
			}
		}
		else
		{
			if (!bSeekLocation)
			{
				PlayTurnHead(LOOK_Right, 1.0, 1.0);
				Sleep(1.0);
			}
			if (!bSeekLocation)
			{
				PlayTurnHead(LOOK_Forward, 1.0, 1.0);
				Sleep(0.5);
			}
			if (!bSeekLocation)
			{
				PlayTurnHead(LOOK_Left, 1.0, 1.0);
				Sleep(1.0);
			}
		}
		PlayTurnHead(LOOK_Forward, 1.0, 1.0);
		Sleep(0.5);
		StopBlendAnims();
	}
	else
	{
		if (!bSeekLocation)
			Sleep(1.0);
	}

FindAnotherPlace:
	SeekLevel--;
	if (PickDestination())
		Goto('GoToLocation');

DoneSeek:
	if (bSeekPostCombat)
		PlayTargetLostSound();
	else
		PlaySearchGiveUpSound();
	bSeekPostCombat = false;
	SeekPawn = None;


	if (Orders != 'Seeking' && bRevertOrders)//This line was changed to remove the revert to previous orders
		FollowOrders();
	else
		GotoState('Wandering');

ContinueSeek:
ContinueFromDoor:
	FinishAnim();
	Goto('FindAnotherPlace');

}

State Attacking
{
	function ReactToInjury(Pawn instigatedBy, Name damageType, EHitLocation hitPos)
	{
		local Pawn oldEnemy;
		local bool bHateThisInjury;
		local bool bFearThisInjury;

		if ((health > 0) && (bLookingForInjury || bLookingForIndirectInjury))
		{
			oldEnemy = Enemy;

			bHateThisInjury = ShouldReactToInjuryType(damageType, bHateInjury, bHateIndirectInjury);
			bFearThisInjury = ShouldReactToInjuryType(damageType, bFearInjury, bFearIndirectInjury);

			if (bHateThisInjury)
				IncreaseAgitation(instigatedBy, 1.0);
			if (bFearThisInjury)
				IncreaseFear(instigatedBy, 2.0);

			if (ReadyForNewEnemy())
				SetEnemy(instigatedBy);

			if (ShouldFlee())
			{
				SetDistressTimer();
				PlayCriticalDamageSound();
				if (RaiseAlarm == RAISEALARM_BeforeFleeing)
					SetNextState('Alerting');
				else
					SetNextState('Fleeing');
			}
			else
			{
				SetDistressTimer();
				if (oldEnemy != Enemy)
					PlayNewTargetSound();
				SetNextState('Attacking', 'ContinueAttack');
			}
			GotoDisabledState(damageType, hitPos);
		}
	}

	function SetFall()
	{
		StartFalling('Attacking', 'ContinueAttack');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Global.HitWall(HitNormal, Wall);
		CheckOpenDoor(HitNormal, Wall);
	}

	function Reloading(DeusExWeapon reloadWeapon, float reloadTime)
	{
		Global.Reloading(reloadWeapon, reloadTime);
		if (bReadyToReload)
			if (IsWeaponReloading())
				if (!IsHandToHand())
					TweenToShoot(0);
	}

	function EDestinationType PickDestination()
	{
		local vector               distVect;
		local vector               tempVect;
		local rotator              enemyDir;
		local float                magnitude;
		local float                calcMagnitude;
		local int                  iterations;
		local EDestinationType     destType;
		local NearbyProjectileList projList;

		destPoint = None;
		destLoc   = vect(0, 0, 0);
		destType  = DEST_Failure;

		if (enemy == None)
			return (destType);

		if (bCrouching && (CrouchTimer > 0))
			destType = DEST_SameLocation;

		if (destType == DEST_Failure)
		{
			if (AICanShoot(enemy, true, false, 0.025) || ActorReachable(enemy))
			{
				destType = ComputeBestFiringPosition(tempVect);
				if (destType == DEST_NewLocation)
					destLoc = tempVect;
			}
		}

		if (destType == DEST_Failure)
		{
			MoveTarget = FindPathToward(enemy);
			if (MoveTarget != None)
			{
				if (!bDefendHome || IsNearHome(MoveTarget.Location))
				{
					if (bAvoidHarm)
						GetProjectileList(projList, MoveTarget.Location);
					if (!bAvoidHarm || !IsLocationDangerous(projList, MoveTarget.Location))
					{
						destPoint = MoveTarget;
						destType  = DEST_NewLocation;
					}
				}
			}
		}

		// Default behavior, so they don't just stand there...
		if (destType == DEST_Failure)
		{
			enemyDir = Rotator(Enemy.Location - Location);
			if (AIPickRandomDestination(60, 150,
			                            enemyDir.Yaw, 0.5, enemyDir.Pitch, 0.5, 
			                            2, FRand()*0.4+0.35, tempVect))
			{
				if (!bDefendHome || IsNearHome(tempVect))
				{
					destType = DEST_NewLocation;
					destLoc  = tempVect;
				}
			}
		}

		return (destType);
	}

	function bool FireIfClearShot()
	{
		local DeusExWeapon dxWeapon;

		dxWeapon = DeusExWeapon(Weapon);
		if (dxWeapon != None)
		{
			if ((dxWeapon.AIFireDelay > 0) && (FireTimer > 0))
				return false;
			else if (AICanShoot(enemy, true, true, 0.025))
			{
				Weapon.Fire(0);
				FireTimer = dxWeapon.AIFireDelay;
				return true;
			}
			else
				return false;
		}
		else
			return false;
	}

	function CheckAttack(bool bPlaySound)
	{
		local bool bCriticalDamage;
		local bool bOutOfAmmo;
		local Pawn oldEnemy;
		local bool bAllianceSwitch;

		oldEnemy = enemy;

		bAllianceSwitch = false;
		if (!IsValidEnemy(enemy))
		{
			if (IsValidEnemy(enemy, false))
				bAllianceSwitch = true;
			SetEnemy(None, 0, true);
		}

		if (enemy == None)
		{
			if (Orders == 'Attacking')
			{
				FindOrderActor();
				SetEnemy(Pawn(OrderActor), 0, true);
			}
		}
		if (ReadyForNewEnemy())
			FindBestEnemy(false);
		if (enemy == None)
		{
			Enemy = oldEnemy;  // hack
			if (bPlaySound)
			{
				if (bAllianceSwitch)
					PlayAllianceFriendlySound();
				else
					PlayAreaSecureSound();
			}
			Enemy = None;
			if (Orders != 'Attacking' && bRevertOrders)//This line was changed to remove the revert to previous orders
				FollowOrders();
			else
				GotoState('Wandering');
			return;
		}

		SwitchToBestWeapon();
		if (bCrouching && (CrouchTimer <= 0) && !ShouldCrouch())
		{
			EndCrouch();
			TweenToShoot(0.15);
		}
		bCriticalDamage = False;
		bOutOfAmmo      = False;
		if (ShouldFlee())
			bCriticalDamage = True;
		else if (Weapon == None)
			bOutOfAmmo = True;
		else if (Weapon.ReloadCount > 0)
		{
			if (Weapon.AmmoType == None)
				bOutOfAmmo = True;
			else if (Weapon.AmmoType.AmmoAmount < 1)
				bOutOfAmmo = True;
		}
		if (bCriticalDamage || bOutOfAmmo)
		{
			if (bPlaySound)
			{
				if (bCriticalDamage)
					PlayCriticalDamageSound();
				else if (bOutOfAmmo)
					PlayOutOfAmmoSound();
			}
			if (RaiseAlarm == RAISEALARM_BeforeFleeing)
				GotoState('Alerting');
			else
				GotoState('Fleeing');
		}
		else if (bPlaySound && (oldEnemy != Enemy))
			PlayNewTargetSound();
	}

	function Tick(float deltaSeconds)
	{
		local bool   bCanSee;
		local float  yaw;
		local vector lastLocation;
		local Pawn   lastEnemy;
		local float  surpriseTime;

		Global.Tick(deltaSeconds);
		if (CrouchTimer > 0)
		{
			CrouchTimer -= deltaSeconds;
			if (CrouchTimer < 0)
				CrouchTimer = 0;
		}
		EnemyTimer += deltaSeconds;
		UpdateActorVisibility(Enemy, deltaSeconds, 1.0, false);
		if ((Enemy != None) && HasEnemyTimedOut())
		{
			lastLocation = Enemy.Location;
			lastEnemy    = Enemy;
			FindBestEnemy(true);
			if (Enemy == None)
			{
				SetSeekLocation(lastEnemy, lastLocation, SEEKTYPE_Guess, true);
				GotoState('Seeking');
			}
		}
		else if (bCanFire && (Enemy != None))
		{
			ViewRotation = Rotator(Enemy.Location-Location);
			if (bFacingTarget)
				FireIfClearShot();
			else if (!bMustFaceTarget)
			{
				yaw = (ViewRotation.Yaw-Rotation.Yaw) & 0xFFFF;
				if (yaw >= 32768)
					yaw -= 65536;
				yaw = Abs(yaw)*360/32768;  // 0-180 x 2
				if (yaw <= FireAngle)
					FireIfClearShot();
			}
		}
		//UpdateReactionLevel(true, deltaSeconds);
	}

	function bool IsHandToHand()
	{
		if (Weapon != None)
		{
			if (DeusExWeapon(Weapon) != None)
			{
				if (DeusExWeapon(Weapon).bHandToHand)
					return true;
				else
					return false;
			}
			else
				return false;
		}
		else
			return false;
	}

	function bool ReadyForWeapon()
	{
		local bool bReady;

		bReady = false;
		if (DeusExWeapon(weapon) != None)
		{
			if (DeusExWeapon(weapon).bReadyToFire)
				if (!IsWeaponReloading())
					bReady = true;
		}
		if (!bReady)
			if (enemy == None)
				bReady = true;
		if (!bReady)
			if (!AICanShoot(enemy, true, false, 0.025))
				bReady = true;

		return (bReady);
	}

	function bool ShouldCrouch()
	{
		if (bCanCrouch && !Region.Zone.bWaterZone && !IsHandToHand() &&
		    ((enemy != None) && (VSize(enemy.Location-Location) > 300)) &&
		    ((DeusExWeapon(Weapon) == None) || DeusExWeapon(Weapon).bUseWhileCrouched))
			return true;
		else
			return false;
	}

	function StartCrouch()
	{
		if (!bCrouching)
		{
			bCrouching = true;
			SetBasedPawnSize(CollisionRadius, GetCrouchHeight());
			CrouchTimer = 1.0+FRand()*0.5;
		}
	}

	function EndCrouch()
	{
		if (bCrouching)
		{
			bCrouching = false;
			ResetBasedPawnSize();
		}
	}

	function BeginState()
	{
		StandUp();

		// hack
		if (MaxRange < MinRange+10)
			MaxRange = MinRange+10;
		bCanFire      = false;
		bFacingTarget = false;

		SwitchToBestWeapon();

		//EnemyLastSeen = 0;
		BlockReactions();
		bCanConverse = False;
		bAttacking = True;
		bStasis = False;
		SetDistress(true);

		CrouchTimer = 0;
		EnableCheckDestLoc(false);
	}

	function EndState()
	{
		EnableCheckDestLoc(false);
		bCanFire      = false;
		bFacingTarget = false;

		ResetReactions();
		bCanConverse = True;
		bAttacking = False;
		bStasis = True;
		bReadyToReload = false;

		EndCrouch();
	}

Begin:
	if (Enemy == None)
		GotoState('Seeking');
	//EnemyLastSeen = 0;
	CheckAttack(false);

Surprise:
	if ((1.0-ReactionLevel)*SurprisePeriod < 0.25)
		Goto('BeginAttack');
	Acceleration=vect(0,0,0);
	PlaySurpriseSound();
	PlayWaiting();
	while (ReactionLevel < 1.0)
	{
		TurnToward(Enemy);
		Sleep(0);
	}

BeginAttack:
	EnemyReadiness = 1.0;
	ReactionLevel  = 1.0;
	if (PlayerAgitationTimer > 0)
		PlayAllianceHostileSound();
	else
		PlayTargetAcquiredSound();
	if (PlayBeginAttack())
	{
		Acceleration = vect(0,0,0);
		TurnToward(enemy);
		FinishAnim();
	}

RunToRange:
	bCanFire       = false;
	bFacingTarget  = false;
	bReadyToReload = false;
	EndCrouch();
	if (Physics == PHYS_Falling)
		TweenToRunning(0.05);
	WaitForLanding();
	if (!IsWeaponReloading() || bCrouching)
	{
		if (ShouldPlayTurn(Enemy.Location))
			PlayTurning();
		TurnToward(enemy);
	}
	else
		Sleep(0);
	bCanFire = true;
	while (PickDestination() == DEST_NewLocation)
	{
		if (bCanStrafe && ShouldStrafe())
		{
			PlayRunningAndFiring();
			if (destPoint != None)
				StrafeFacing(destPoint.Location, enemy);
			else
				StrafeFacing(destLoc, enemy);
			bFacingTarget = true;
		}
		else
		{
			bFacingTarget = false;
			PlayRunning();
			if (destPoint != None)
				MoveToward(destPoint, MaxDesiredSpeed);
			else
				MoveTo(destLoc, MaxDesiredSpeed);
		}
		CheckAttack(true);
	}

Fire:
	bCanFire      = false;
	bFacingTarget = false;
	Acceleration = vect(0, 0, 0);

	SwitchToBestWeapon();
	if (FRand() > 0.5)
		bUseSecondaryAttack = true;
	else
		bUseSecondaryAttack = false;
	if (IsHandToHand())
		TweenToAttack(0.15);
	else if (ShouldCrouch() && (FRand() < CrouchRate))
	{
		TweenToCrouchShoot(0.15);
		FinishAnim();
		StartCrouch();
	}
	else
		TweenToShoot(0.15);
	if (!IsWeaponReloading() || bCrouching)
		TurnToward(enemy);
	FinishAnim();
	bReadyToReload = true;

ContinueFire:
	while (!ReadyForWeapon())
	{
		if (PickDestination() != DEST_SameLocation)
			Goto('RunToRange');
		CheckAttack(true);
		if (!IsWeaponReloading() || bCrouching)
			TurnToward(enemy);
		else
			Sleep(0);
	}
	CheckAttack(true);
	if (!FireIfClearShot())
		Goto('ContinueAttack');
	bReadyToReload = false;
	if (bCrouching)
		PlayCrouchShoot();
	else if (IsHandToHand())
		PlayAttack();
	else
		PlayShoot();
	FinishAnim();
	if (FRand() > 0.5)
		bUseSecondaryAttack = true;
	else
		bUseSecondaryAttack = false;
	bReadyToReload = true;
	if (!IsHandToHand())
	{
		if (bCrouching)
			TweenToCrouchShoot(0);
		else
			TweenToShoot(0);
	}
	CheckAttack(true);
	if (PickDestination() != DEST_NewLocation)
	{
		if (!IsWeaponReloading() || bCrouching)
			TurnToward(enemy);
		else
			Sleep(0);
		Goto('ContinueFire');
	}
	Goto('RunToRange');

ContinueAttack:
ContinueFromDoor:
	CheckAttack(true);
	if (PickDestination() != DEST_NewLocation)
		Goto('Fire');
	else
		Goto('RunToRange');

}

State Patrolling
{
Begin:
	destPoint = None;

Patrol:
	//Disable('Bump');
	WaitForLanding();
	PickDestination();

Moving:
	// Move from pathnode to pathnode until we get where we're going
	if (destPoint != None)
	{
		if (!IsPointInCylinder(self, destPoint.Location, 16-CollisionRadius))
		{
			EnableCheckDestLoc(true);
			MoveTarget = FindPathToward(destPoint);

			if ( MoveTarget == none)
			{
				Log("TNMRobot Failed to return to patrol");
				GotoState('Wandering');
			}

			while (MoveTarget != None)
			{
				if (ShouldPlayWalk(MoveTarget.Location))
					PlayWalking();
				MoveToward(MoveTarget, GetWalkingSpeed());
				CheckDestLoc(MoveTarget.Location, true);
				if (MoveTarget == destPoint)
					break;
				MoveTarget = FindPathToward(destPoint);
			}
			EnableCheckDestLoc(false);
		}
	}
	else
	{
		Goto('Patrol');
	}

Pausing:
	if (!bAlwaysPatrol)
		bStasis = true;
	Acceleration = vect(0, 0, 0);

	// Turn in the direction dictated by the WanderPoint, or a random direction
	if (PatrolPoint(destPoint) != None)
	{
		if ((PatrolPoint(destPoint).pausetime > 0) || (PatrolPoint(destPoint).NextPatrolPoint == None))
		{
			if (ShouldPlayTurn(Location + PatrolPoint(destPoint).lookdir))
				PlayTurning();
			TurnTo(Location + PatrolPoint(destPoint).lookdir);
			Enable('AnimEnd');
			TweenToWaiting(0.2);
			PlayScanningSound();
			//Enable('Bump');
			sleepTime = PatrolPoint(destPoint).pausetime * ((-0.9*restlessness) + 1);
			Sleep(sleepTime);
			Disable('AnimEnd');
			//Disable('Bump');
			FinishAnim();
		}
	}

	Goto('Patrol');

ContinuePatrol:
ContinueFromDoor:
	FinishAnim();
	PlayWalking();
	Goto('Moving');

}

//
// lip synching support - DEUS_EX CNN
//
function LipSynch(float deltaTime)
{
	local name animseq;
	local float rnd;
	local float tweentime;

	// update the animation timers that we are using
	animTimer[0] += deltaTime;
	animTimer[1] += deltaTime;
	animTimer[2] += deltaTime;

	if (bIsSpeaking)
	{
		// if our framerate is high enough (>20fps), tween the lips smoothly
		if (Level.TimeSeconds - animTimer[3]  < 0.05)
			tweentime = 0.1;
		else
			tweentime = 0.0;

		// the last animTimer slot is used to check framerate
		animTimer[3] = Level.TimeSeconds;

		if (nextPhoneme == "A")
			animseq = 'MouthA';
		else if (nextPhoneme == "E")
			animseq = 'MouthE';
		else if (nextPhoneme == "F")
			animseq = 'MouthF';
		else if (nextPhoneme == "M")
			animseq = 'MouthM';
		else if (nextPhoneme == "O")
			animseq = 'MouthO';
		else if (nextPhoneme == "T")
			animseq = 'MouthT';
		else if (nextPhoneme == "U")
			animseq = 'MouthU';
		else if (nextPhoneme == "X")
			animseq = 'MouthClosed';

		if (animseq != '' && HasAnim(animseq))
		{
			if (lastPhoneme != nextPhoneme)
			{
				lastPhoneme = nextPhoneme;
				TweenBlendAnim(animseq, tweentime);
			}
		}
	}
	else if (bWasSpeaking)
	{
		bWasSpeaking = False;
		if (HasAnim('MouthClosed'))
			TweenBlendAnim('MouthClosed', tweentime);
	}

	// blink randomly
	if (animTimer[0] > 2.0)
	{
		animTimer[0] = 0;
		if ((FRand() < 0.4  || IsInState('RubbingEyes')) && HasAnim('Blink'))
			PlayBlendAnim('Blink', 1.0, 0.1, 1);
	}

	LoopHeadConvoAnim();
	LoopBaseConvoAnim();
}

function LoopBaseConvoAnim()
{
	local float rnd;

	rnd = FRand();

	// move arms randomly
	if (bIsSpeaking)
	{
		if (animTimer[2] > 2.5)
		{
			animTimer[2] = 0;
			if (rnd < 0.1 && HasAnim('GestureLeft'))
				PlayAnim('GestureLeft', 0.35, 0.4);
			else if (rnd < 0.2 && HasAnim('GestureRight'))
				PlayAnim('GestureRight', 0.35, 0.4);
			else if (rnd < 0.3 && HasAnim('GestureBoth'))
				PlayAnim('GestureBoth', 0.35, 0.4);
		}
	}

	// if we're not playing an animation, loop the breathe
	if (!IsAnimating() && HasAnim('BreatheLight'))
		LoopAnim('BreatheLight',, 0.4);
}

// ----------------------------------------------------------------------
// AISafeToShoot()
// ----------------------------------------------------------------------

function bool AISafeToShoot(out Actor hitActor, vector traceEnd, vector traceStart,
                            optional vector extent, optional bool bIgnoreLevel)
{
	local Actor            traceActor;
	local Vector           hitLocation;
	local Vector           hitNormal;
	local Pawn             tracePawn;
	local DeusExDecoration traceDecoration;
	local DeusExMover      traceMover;
	local bool             bSafe;

	// Future improvement:
	// Ideally, this should use the ammo type to determine how many shots
	// it will take to destroy an obstruction, and call it unsafe if it takes
	// more than x shots.  Also, if the ammo is explosive, and the
	// obstruction is too close, it should never be safe...

	bSafe    = true;
	hitActor = None;

	foreach TraceActors(Class'Actor', traceActor, hitLocation, hitNormal,
	                    traceEnd, traceStart, extent)
	{		
		if (hitActor == None)
			hitActor = traceActor;
		if (traceActor == Level)
		{
			if (!bIgnoreLevel)
				bSafe = false;
			break;
		}
		tracePawn = Pawn(traceActor);
		if (tracePawn != None)
		{
			if (tracePawn != self)
			{
				if (GetPawnAllianceType(tracePawn) != ALLIANCE_Hostile)
				{
					if (Robot(tracePawn) == None || (Robot(tracePawn) != None && Robot(tracePawn).EMPHitPoints > 0)) // Don't care about disabled robots being used as shields.
						bSafe = false;
				}
				break;
			}
		}
		traceDecoration = DeusExDecoration(traceActor);
		if (traceDecoration != None)
		{
			if ((traceDecoration.bExplosive && (VSize(traceDecoration.Location - Location) < (traceDecoration.explosionRadius))) || traceDecoration.bInvincible)
			{
				bSafe = false;
				break;
			}
			// if ((traceDecoration.HitPoints > 20) || (traceDecoration.minDamageThreshold > 4))  // hack
			// {
				// bSafe = false;
				// break;
			// }
			else if (DeusExWeapon(Weapon) == None)
			{
				bSafe = false;
				break;
			}
			else if (DeusExWeapon(Weapon).ProjectileClass != None && ((DeusExWeapon(Weapon).ProjectileClass.Default.Damage) < traceDecoration.minDamageThreshold))
			{
				bSafe = false;
				break;
			}
			else if (DeusExWeapon(Weapon) != None && ((DeusExWeapon(Weapon).Default.HitDamage) < traceDecoration.minDamageThreshold))
			{
				bSafe = false;
				break;
			}
			else  // hack
				break;
		}
		traceMover = DeusExMover(traceActor);
		if (traceMover != None)
		{
			if (!traceMover.bBreakable)
			{
				bSafe = false;
				break;
			}
			else if (DeusExWeapon(Weapon) == None)
			{
				bSafe = false;
				break;
			}
			else if (DeusExWeapon(Weapon).ProjectileClass != None && ((DeusExWeapon(Weapon).ProjectileClass.Default.Damage * 0.75) < traceMover.minDamageThreshold))
			{
				bSafe = false;
				break;
			}
			else if (DeusExWeapon(Weapon) != None && ((DeusExWeapon(Weapon).Default.HitDamage * 0.75) < traceMover.minDamageThreshold))
			{
				bSafe = false;
				break;
			}
			else  // hack
				break;
		}
		if (Inventory(traceActor) != None)
		{
			bSafe = false;
			break;
		}
	}

	return (bSafe);
}

// ----------------------------------------------------------------------
// AICanShoot()
// ----------------------------------------------------------------------

function bool AICanShoot(pawn target, bool bLeadTarget, bool bCheckReadiness,
                         optional float throwAccuracy, optional bool bDiscountMinRange)
{
	local DeusExWeapon dxWeapon;
	local Vector X, Y, Z;
	local Vector projStart, projEnd;
	local float  tempMinRange, tempMaxRange;
	local float  temp;
	local float  dist;
	local float  extraDist;
	local actor  hitActor;
	local Vector hitLocation, hitNormal;
	local Vector extent;
	local bool   bIsThrown;
	local float  elevation;
	local bool   bSafe;

	if (target == None)
		return false;
	if (target.bIgnore)
		return false;

	dxWeapon = DeusExWeapon(Weapon);
	if (dxWeapon == None)
		return false;
	if (bCheckReadiness && !dxWeapon.bReadyToFire)
		return false;

	if (dxWeapon.ReloadCount > 0)
	{
		if (dxWeapon.AmmoType == None)
			return false;
		if (dxWeapon.AmmoType.AmmoAmount <= 0)
			return false;
	}

	if (FireElevation > 0)
	{
		elevation = FireElevation + (CollisionHeight+target.CollisionHeight);
		if (elevation < 10)
			elevation = 10;
		if (Abs(Location.Z-target.Location.Z) > elevation)
			return false;
	}
	bIsThrown = IsThrownWeapon(dxWeapon);

	extraDist = target.CollisionRadius;
	//extraDist = 0;

	GetPawnWeaponRanges(self, tempMinRange, tempMaxRange, temp);
	
	if (bDiscountMinRange)
		tempMinRange = 0;

	if (tempMinRange >= tempMaxRange)
		return false;

	ViewRotation = Rotation;
	GetAxes(ViewRotation, X, Y, Z);
	projStart = dxWeapon.ComputeProjectileStart(X, Y, Z);
	if (bLeadTarget && !dxWeapon.bInstantHit && (dxWeapon.ProjectileSpeed > 0))
	{
		if (bIsThrown)
		{
			// compute target's position 1.5 seconds in the future
			projEnd = target.Location + (target.Velocity*1.5);
		}
		else
		{
			// projEnd = target.Location + (target.Velocity*dist/dxWeapon.ProjectileSpeed);
			if (!ComputeTargetLead(target, projStart, dxWeapon.ProjectileSpeed,
			                       5.0, projEnd))
				return false;
		}
	}
	else
		projEnd = target.Location;

	if (bIsThrown)
		projEnd += vect(0,0,-1)*(target.CollisionHeight-5);

	dist = VSize(projEnd - Location);
	if (dist < 0)
		dist = 0;

	if ((dist < tempMinRange) || (dist-extraDist > tempMaxRange))
		return false;

	if (!bIsThrown)
	{
		bSafe = FastTrace(target.Location, projStart);
		if (!bSafe)
			bSafe = AISafeToShoot(hitActor, target.Location, projStart);
		if (!bSafe && target.bIsPlayer)  // players only... hack
		{
			projEnd += vect(0,0,1)*target.BaseEyeHeight;
			//bSafe = FastTrace(target.Location + vect(0,0,1)*target.BaseEyeHeight, projStart);
			bSafe = AISafeToShoot(hitActor, target.Location + vect(0,0,1)*target.BaseEyeHeight, projStart);
		}
		if (!bSafe)
			return false;
	}

	if (dxWeapon.bInstantHit)
		return (AISafeToShoot(hitActor, projEnd, projStart, , true));
	else
	{
		extent.X = dxWeapon.ProjectileClass.default.CollisionRadius;
		extent.Y = dxWeapon.ProjectileClass.default.CollisionRadius;
		extent.Z = dxWeapon.ProjectileClass.default.CollisionHeight;
		if (bIsThrown && (throwAccuracy > 0))
			return (AISafeToThrow(projEnd, projStart, throwAccuracy,
			                      extent));
		else
			return (AISafeToShoot(hitActor, projEnd, projStart, extent*3));
	}
}

function SupportActor(Actor standingActor)
{
	local vector newVelocity;
	local float  angle;
	local float  zVelocity;
	local float  baseMass;
	local float  standingMass;
	local vector damagePoint;
	local float  damage;
	local string localURL;
	local DeusExLevelInfo dxInfo;

	foreach AllActors(class'DeusExLevelInfo', dxInfo)
		break;
	
	if (dxInfo != None)
		localURL = Caps(dxInfo.mapName);
		
	if (dxInfo == None || (localURL == "PLATFORM_01" || localURL == "PLATFORM_02") || bPlatformer)
	{
		TakeDamage(1000, Self, Location + vect(0,0,1)*(CollisionHeight-1), 0.2*standingActor.Velocity, 'stomped');
		// SetCollisionSize(CollisionRadius / 4, CollisionHeight / 4);
		SetCollision( False, False, False );
		newVelocity += standingActor.Velocity;
		newVelocity.Z = 500;
		standingActor.Velocity = newVelocity;
		standingActor.SetPhysics(PHYS_Falling);
	}
	else
	{
		standingMass = FMax(1, standingActor.Mass);
		baseMass     = FMax(1, Mass);
		if ((Physics == PHYS_Swimming) && Region.Zone.bWaterZone)
		{
			newVelocity = standingActor.Velocity;
			newVelocity *= 0.5*standingMass/baseMass;
			AddVelocity(newVelocity);
		}
		else
		{
			zVelocity    = standingActor.Velocity.Z;
			damagePoint  = Location + vect(0,0,1)*(CollisionHeight-1);
			damage       = (1 - (standingMass/baseMass) * (zVelocity/100));

			// Have we been stomped?
			if ((zVelocity*standingMass < -7500) && (damage > 0) && WillTakeStompDamage(standingActor))
				TakeDamage(damage, standingActor.Instigator, damagePoint, 0.2*standingActor.Velocity, 'stomped');
		}

		// Bounce the actor off the pawn
		angle = FRand()*Pi*2;
		newVelocity.X = cos(angle);
		newVelocity.Y = sin(angle);
		newVelocity.Z = 0;
		newVelocity *= FRand()*25 + 25;
		newVelocity += standingActor.Velocity;
		newVelocity.Z = 50;
		standingActor.Velocity = newVelocity;
		standingActor.SetPhysics(PHYS_Falling);
	}
}


function tick(float deltatime)
{
	local float pct, mod;
	local vector NewVect;

	Super.Tick(deltaTime);

   // DEUS_EX AMSD All the MP robots have massive numbers of EMP hitpoints, not equal to the default.  In multiplayer, at least, only do this if
   // they are DAMAGED.
	if ((Default.EMPHitPoints != EMPHitPoints) && (EMPHitPoints != 0) && ((EMPHitPoints < Default.EMPHitPoints)))
	{
		pct = (Default.EMPHitPoints - EMPHitPoints) / Default.EMPHitPoints;
		mod = pct * (1.0 - (2.0 * FRand()));
		DesiredSpeed = MaxDesiredSpeed + (mod * MaxDesiredSpeed * 0.5);
		SoundPitch = Default.SoundPitch + (mod * 8.0);
	}

	if (CrazedTimer > 0)
	{
		CrazedTimer -= deltaTime;
		if (CrazedTimer < 0)
		{
			CrazedTimer = 0;
			RebootTimer = 5;
		}
	}
	
	if (RebootTimer > 0 && !IsInState('Dying'))
	{
		if (EMPHitPoints > 0)
			GotoState('Rebooting');
	
		RebootTimer -= deltaTime;
		if (RebootTimer < 0)
		{
			RebootTimer = 0;
			if (EMPHitPoints > 0)
				FollowOrders();
		}
	}

	if (CrazedTimer > 0)
		bReverseAlliances = true;
	else
		bReverseAlliances = false;
	
	if (bPlatformer)
	{
		NewVect = Location;
		NewVect.Y = yAxis;
		SetLocation(NewVect);
	}
}

// ----------------------------------------------------------------------
// state Dying - copied
// ----------------------------------------------------------------------

state FirewallDeath
{
	ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, Timer, TakeDamage;

	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);

		if (bfading)
		{
			fadetime += deltaTime;
			if (Style != STY_Translucent)
				Style = STY_Translucent;
			ScaleGlow = default.scaleglow * (3 - fadetime) / 3;
			drawscale = default.drawscale * (3 - fadetime) / 3;
			SetCollisionSize(Default.CollisionRadius * DrawScale, Default.CollisionHeight * DrawScale);
		}
		
		// LipSynchBarks(deltaTime);
	}

	function BeginState()
	{
		// if(breathgen != none)
			// breathgen.DelayedDestroy();

		EnableCheckDestLoc(false);
		StandUp();

		// don't do that stupid timer thing in Pawn.uc
		AIClearEventCallback('Futz');
		AIClearEventCallback('MegaFutz');
		AIClearEventCallback('Player');
		AIClearEventCallback('WeaponDrawn');
		AIClearEventCallback('LoudNoise');
		AIClearEventCallback('WeaponFire');
		AIClearEventCallback('Carcass');
		AIClearEventCallback('Distress');

		bInterruptState = false;
		BlockReactions(true);
		bCanConverse = False;
		bStasis = False;
		SetDistress(true);
		DeathTimer = 0;
	}

Begin:
	Acceleration = vect(0, 0, 0);
	PlayDisabled();
	Sleep(3);
	Frag(Rand(5)+5);
	for (i=0;i<8;i++)
		multiskins[i] = Texture(DynamicLoadObject("Extras.Matrix_A00", class'Texture'));
	// DropItems();
	Sleep(2);
	bFading = true;
	KillShadow();
	bHasShadow = False;
	//fade
	Sleep(3);
	Destroy();
}

function Frag(int NumFrags)
{
	local int i;
	local DeusExFragment s;
	local vector v;

	for (i=0 ; i<NumFrags ; i++)
	{
		v = location;
		v.z += (frand()*2 - 1) * collisionheight;
		v.y += (frand()*2 - 1) * collisionradius;
		v.x += (frand()*2 - 1) * collisionradius;

		s = Spawn(class'metalfragment', self,,v);
		if (s != None)
		{
			s.CalcVelocity(v,0);
			s.DrawScale = Frand() +1;
			s.Skin = multiskins[Rand(4)];
		}
	}
}

// SecurityBot3 exclusive
function SetTreads()
{	
	if (ScriptedTexID != -1 && TreadTexture == None)
		TreadTexture = ScriptedTexture(DynamicLoadObject("RevisionScriptedTex.ScriptedBotTex" $ string(ScriptedTexID), class'ScriptedTexture', True)); // Huzzah each bot needs its own unique texture...
	if (TreadTexture != None)
		TreadTexture.NotifyActor = Self;
	if (TreadTexture != None)	// Up to 10 treads
		MultiSkins[1] = TreadTexture;
	else
		MultiSkins[1] = Skin;
}

function PlayDying(name damageType, vector hitLoc)
{
	local Vector X, Y, Z;
	local float dotp;

//	ClientMessage("PlayDying()");
	if (Region.Zone.bWaterZone && HasAnim('WaterDeath'))
		PlayAnimPivot('WaterDeath',, 0.1);
	else if (bSitting)  // if sitting, always fall forward
		PlayAnimPivot('DeathFront',, 0.1);
	else
	{
		GetAxes(Rotation, X, Y, Z);
		dotp = (Location - HitLoc) dot X;

		// die from the correct side
		if (dotp < 0.0)		// shot from the front, fall back
			PlayAnimPivot('DeathBack',, 0.1);
		else				// shot from the back, fall front
			PlayAnimPivot('DeathFront',, 0.1);
	}
	
	PlayDyingSound();
}

function GotoDisabledState(name damageType, EHitLocation hitPos)
{
	if (!bCollideActors && !bBlockActors && !bBlockPlayers)
		return;
	else if (damageType == 'Temporal')
		GotoState('StunnedTemporal');
	else if (!IgnoreDamageType(damageType) && CanShowPain())
		TakeHit(hitPos);
	else
		GotoNextState();
}

// ----------------------------------------------------------------------
// state Stunned
//
// React to being stunned.
// ----------------------------------------------------------------------
state StunnedTemporal
{
	ignores seeplayer, hearnoise, bump, hitwall, stopwaiting, ReactToInjury, SpurtBlood, AddVelocity;

	// function ReactToInjury(Pawn instigatedBy, Name damageType, EHitLocation hitPos)
	// {
		// if ((damageType != 'TearGas') && (damageType != 'HalonGas') && (damageType != 'Stunned'))
			// Global.ReactToInjury(instigatedBy, damageType, hitPos);
	// }

	function SetFall()
	{
		StartFalling(NextState, NextLabel);
	}

	function AnimEnd()
	{
		PlayWaiting();
	}

	function BeginState()
	{
		StandUp();
		Disable('AnimEnd');
		bInterruptState = false;
		BlockReactions();
		bCanConverse = False;
		bStasis = False;
		SetupWeapon(false);
		SetDistress(true);
		bStunned = True;
		bInTransientState = true;
		EnableCheckDestLoc(false);
		SetSkinStyle(STY_Translucent);
		// GetPlayer();
		if (ban_fx == None)
		{
			ban_fx=Spawn(Class'TemporalEffect',self);
			ban_fx.ScaleGlow=0.07;
			ban_fx.AmbientSound=Sound'TNMSounds.Ambient.GoatPortal';
		}
	}

	function EndState()
	{
		EnableCheckDestLoc(false);
		bInterruptState = true;
		ResetReactions();
		bCanConverse = True;
		bStasis = True;

		// if we're dead, don't reset the flag
		if (Health > 0)
			bStunned = False;
		bInTransientState = false;
		ResetSkinStyle();
		ScaleGlow = Default.ScaleGlow;
		if (ban_fx != None)
			ban_fx.Destroy();
	}
	
	function Tick(float deltaTime)
	{
		local name flagName;
		local bool bValidItem;
		local inventory item, nextItem;
		local Vector loc;
	
		Global.Tick(deltaTime);
		
		// LipSynchBarks(deltaTime);
		
		ScaleGlow = 1 - (temporalness / (Health * 2));		
	
		if (ScaleGlow <= 0)
		{
			if (bImportant)
			{
				flagName = DeusExPlayer(GetPlayerPawn()).rootWindow.StringToName(BindName$"_Dead");
				DeusExPlayer(GetPlayerPawn()).flagBase.SetBool(flagName, True);

				// make sure the flag never expires
				DeusExPlayer(GetPlayerPawn()).flagBase.SetExpiration(flagName, FLAG_Bool, 0);
			}
			Killed(DeusExPlayer(GetPlayerPawn()), Self, 'Banned');
			PlaySound(sound'TNMSounds.OneShot.IntroBan', SLOT_None,0.5,, 1280);
			if (ban_fx != None)
			{
				ban_fx.Destroy();
				ban_fx=None; //should happen anyways, just in case with garbage collection
			}

			if(inventory != none)
			{
				do
				{
					item = Inventory;
					nextItem = item.Inventory;
					// bValidItem = true;
					bValidItem = false;

					loc.X = (1-2*FRand()) * CollisionRadius;
					loc.Y = (1-2*FRand()) * CollisionRadius;
					loc.Z = (1-2*FRand()) * CollisionHeight;
					loc += Location;

					DeleteInventory(item);
					
					if (Nanokey(item) != None)
					{
						Nanokey(item).ItemName = strPassword;
						Nanokey(item).beltDescription = strPass;
					}

					if((DeusExWeapon(item) != None) && (DeusExWeapon(item).bNativeAttack))
						bValidItem = false;
					else if(Ammo(item) != none)
						bValidItem = false;
					
					if (DeusExWeapon(item) != None)
					{
						if (DeusExWeapon(item).bLasing)
							DeusExWeapon(item).LaserOff();
					}
						
					if (Nanokey(item) != None)
						bValidItem = True;
					else if (DatavaultImage(item) != None)
						bValidItem = True;

					if(!bValidItem)
						Item.Destroy();
					else
						class'TNMCarcass'.static.FlingItem(item, 300, loc);

					item = nextItem;
				}
				until (item == None)
			}
			Destroy();
		}
	}

Begin:
	Acceleration = vect(0, 0, 0);
	// PlayStunned();
	AnimRate = 0;
	while (temporalness > 0)
	{
		temporalness -= 1;
		Sleep(0.25);
	}
	if (EMPHitPoints <= 0)
		GoToState('Disabled');
	if (HasNextState())
		GotoNextState();
	else
		GotoState('Wandering');
}

defaultproperties
{
     dominatable=True
     bRevertOrders=True
     ScriptedTexID=-1
     strPassword="Password"
     strPass="Pass"
     FootstepProjectRadius=768.000000
     FootstepProjectMaxRadius=2048.000000
     bCanOpenDoors=False
}

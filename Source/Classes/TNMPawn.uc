//=============================================================================
// TNMPawn.
//=============================================================================
class TNMPawn extends ScriptedPawn
	abstract;

var int i,j; //can be used as local int
var sound bruhSound;

var() bool bSmartWeapons;
var() bool bEmitCarcass; //prevents people from freaking out when the carcass is spawned, for missionscript purposes

var() bool bCanUseFists;
var() bool bMirrorPawn;

var float idleSitTime;
var float temporalness;
var BanEffect 		ban_fx;

//<ALARM VARS>
	enum EAlarmReason  {
		AR_None,			//includes alarm before attack and before flee
		AR_FoundCarcass,
		AR_DisabledBot,
		AR_SecurityAlert,
		AR_Fire,
		AR_LostPlayer,
		AR_KilledPlayer,
	};

	var() bool bRestoreOrders;
	var name originalOrders;
	var name originalOrderTag;

	var(AlarmTrigger) bool bAlarmCarcass;
	var(AlarmTrigger) bool bAlarmBot;
	var(AlarmTrigger) bool bAlarmSecurity;
	var(AlarmTrigger) bool bAlarmFire;
	var(AlarmTrigger) bool bAlarmLostPlayer;
	var(AlarmTrigger) bool bAlarmKilledPlayer;
	var Ealarmreason alarmreason;

	//WCCC, 5/11/19: Used for better bAlarmLostPlayer behavior.
	var bool bVisualContactSeeking;

//</ALARM VARS>

//<DAMAGE VARS>
	var float Fat;
	var bool bImmuneToGib;
//</DAMAGE VARS>

//<FIREWALL VARS>
	var bool bFirewall;
	var bool bFading;
	var float FadeTime;
//</FIREWALL VARS>

//<AUG VARS>
	var(TNMPawnaugs) float AugHealthLimit;
	var(TNMPawnaugs) bool bAugmented;
	var TNMPawnaugmanager TNMPAM; //whooo achronyms
	var(TNMPawnaugs) float Energy;
	var(TNMPawnaugs) class<tnmaugmentation> Augs[14];
	var float stealthmodifier;
	var bool bvisionactive;
//</AUG VARS>

//<THEFT VARS>
	var(Reactions) bool bReactTheft;
//</THEFT VARS>

//formation vars
var int 		formationDesiredDistance;
var int 		formationDesiredYaw;
var int 		formationInitialYaw;
var Name		formationPatrolTag;
//var FormationController formationcontroller;
var int			formationID;

var string augstring;
var float stuntime;

var bool bHelmeted;

var bool bHateBreakAndEnter;

//DDL breath moisture code
var particlegenerator breathgen;
var float breathtimer;
var float breathtime;
var() float breathSize;
var() bool bVisibleBreath;
var bool bBreathDesynced;
var() bool bUseLipsyncHack;
var bool bLipsyncHackActive;

//WCCC, 3/24/19: Hack for fat not getting amplified lethal. Spicy.
var bool bTempFatFlag;

var float timewithouto2;

var float remainingSleepTime;
var float firewallDeathAnimSpeed;

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

var() bool bLookAtPlayer;			// Do we look at the player as they get near (10ft)?
var() bool bLookingReset;			// Have we been told to look forward?
var() float playerLastSeenTimer;	// When was the last time we saw the player?
var() float lookCheckTime;			// Internal, for performance
var() float lookingAtPlayerTime;	// How long have we been looking at the player?
var() pawn lookAtTarget;			// If unable to look at the player, look at this person instead

var() float dripRate;
var() float waterDripCounter;
	
var      Pawn     Burner;         // person who initiated Burned damage
var bool bDeathCounted; 		// Have I just been killed
var TNMWeapon BurnerWeapon;	// What weapon set me on fire?
var bool bPlatformer;
var int xAxis;
var int yAxis;
var() bool bRadishCinematic;

var Trestkon localPlayer;

var float footprintoffset;
var name FloorTexture;
var bool bWalkingOnSnow;
var bool bWalkingBackwards;

var() bool bCustomBarkPitch;
var() float barkPitch;
var() float barkPitchMin;
var() float barkPitchMax;
var bool bPitchSet;

var localized string strPassword, strPass;

var(Guarding) bool bShouldGuardPoints;	// Should this pawn go to GuardPoints after seeking?
var(Guarding) float guardChance;		// Chance this pawn will go to guardpoints (0.0-1.0)
var(Guarding) float guardRadius;		// Radius to check for guardpoints.

var ScriptedPawn aDrone;
var float droneTimer;
var() float droneRespawnTime;
var() string droneClass;

var bool bMotionBlur;
var float blurPeriod;
var float blurTime;

var() bool bExtraSuspicious;		// Look around while patrolling?
var() float patrolLookTimer;

var bool bPendingAugOnSound, bPendingAugOffSound;

var() bool bPatrolIdleSound;
var string StoredFamiliarName, StoredUnfamiliarName;
var bool bLegendary;
var int LegendaryCount;
var localized string strTitlePrefix[8];
var localized string strTitlePrefixImportant[8];
var localized string strTitlePrefixImportantRare[8];

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

function float GetDefaultCollisionHeight()
{
	local int i;
	local float newHeight;
	
	if (bLegendary && LegendaryCount > 0)
	{
		newHeight = Default.CollisionHeight;
		for (i=0; i<LegendaryCount; i++)
			newHeight = newHeight * 1.1;
		return (newHeight-4.5);
	}
    return (Default.CollisionHeight-4.5);
}


// ----------------------------------------------------------------------
// GetCrouchHeight()
// ----------------------------------------------------------------------

function float GetCrouchHeight()
{
	local int i;
	local float newHeight;
	
	if (bLegendary && LegendaryCount > 0)
	{
		newHeight = Default.CollisionHeight;
		for (i=0; i<LegendaryCount; i++)
			newHeight = newHeight * 1.1;
		return (newHeight*0.65);
	}
	else
		return (Default.CollisionHeight*0.65);
}

function GetPlayer() 
{
	local Pawn P;
	local Trestkon T, BestT;
	local float dist, bestDist;

	if (Level.NetMode != NM_Standalone)
	{
		bestDist = 9999999.0;
		for (P = Level.PawnList; P != None; P = P.NextPawn)
		{
			T = Trestkon(P);
			if (T != None && T.Health > 0 && !T.IsInState('Dying'))
			{
				dist = VSize(T.Location - Location);
				if (BestT == None || dist < bestDist)
				{
					BestT = T;
					bestDist = dist;
				}
			}
		}
		if (BestT != None)
		{
			localPlayer = BestT;
			return;
		}
	}

    if (localPlayer != None)         
		return; 
	localPlayer = Trestkon(GetPlayerPawn());
}

// ----------------------------------------------------------------------
// DripWater()
// ----------------------------------------------------------------------

singular function DripWater(float deltaTime)
{
	local float  dripPeriod;
	local float  adjustedRate;
	local vector waterVector;
	local vector vel;
	local rotator SpawnRotation;
	
	// if ((DeusExMPGame(Level.Game) != None) && (!DeusExMPGame(Level.Game).bSpawnEffects))
	// {
		// dripRate = 0;
		// waterDripCounter = 0;
		// return;
	// }
	
	// Copied from ScriptedPawn::Tick()
	dripRate = FClamp(dripRate, 0.0, 15.0);
	if (dripRate > 0)
	{
		adjustedRate = 1;
		dripPeriod = adjustedRate / FClamp(VSize(Velocity)/512.0, 5, 10);
		waterDripCounter += deltaTime;
		while (waterDripCounter >= dripPeriod)
		{
			vel = 0.1*Velocity;
			vel.Z = 0;
			
			SpawnRotation = rot(0,0,0);
			SpawnRotation.Pitch = 49152;
		
			waterVector = VRand() * (CollisionRadius * 0.8);
			// if (VSize(Velocity) > 8)
				// spawn(Class'WaterDrop',Self,,waterVector+Location,rotator(Velocity-vel));
			// else
				spawn(Class'WaterDrop',Self,,waterVector+Location, SpawnRotation);
			waterDripCounter -= dripPeriod;
		}
		dripRate -= deltaTime;
	}
	
	if (dripRate <= 0)
	{
		dripRate   		 = 0;
		waterDripCounter = 0;
	}
}

//WCCC, 3/17/19: Scale things based on the factor in question, and height differences between other and us.
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


//Copied here from Pawn to check for missing lip synching animations
function LipSynch(float deltaTime)
{
	local name animseq;
	local float rnd;
	local float tweentime;
	local tnmconplay cp;

	// update the animation timers that we are using
	animTimer[0] += deltaTime;
	animTimer[1] += deltaTime;
	animTimer[2] += deltaTime;

	if (bIsSpeaking)
	{
		// log(nextPhoneme, name);
		// if our framerate is high enough (>20fps), tween the lips smoothly
		if (Level.TimeSeconds - animTimer[3]  < 0.05)
			tweentime = 0.25; // Was 0.1
		else
			tweentime = 0.0;

		// the last animTimer slot is used to check framerate
		animTimer[3] = Level.TimeSeconds;

		//log(nextPhoneme$" "$bUseLipsyncHack,name);
		/*
		if(bLipsyncHackActive || (nextPhoneme == "" && bUseLipsyncHack))
		{
			bLipsyncHackActive = true;
			switch(rand(8))
			{
			case 0:
				nextPhoneme="A";
				break;
			case 1:
				nextPhoneme="E";
				break;
			case 2:
				nextPhoneme="F";
				break;
			case 3:
				nextPhoneme="M";
				break;
			case 4:
				nextPhoneme="O";
				break;
			case 5:
				nextPhoneme="T";
				break;
			case 6:
				nextPhoneme="U";
				break;
			case 7:
				nextPhoneme="X";
				break;
			}
		}*/

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

		if (animseq != '')
		{
			if (lastPhoneme != nextPhoneme)
			{
				lastPhoneme = nextPhoneme;
				if (HasAnim(animseq))
					TweenBlendAnim(animseq, tweentime);
			}
		}
	}
	else if (bWasSpeaking)
	{
		bWasSpeaking = False;
		if ( HasAnim('MouthClosed') )
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

//Copied here from Pawn to check for missing lip synching animations
function LipSynchBarks(float deltaTime)
{
	local name animseq;
	local float rnd;
	local float tweentime;
	local tnmconplay cp;

	// Stunned pawns have no control and shouldn't be lipsynced.
	if (IsInState('Stunned') || IsInState('StunnedTaser'))
		return;
	
	// update the animation timers that we are using
	animTimer[0] += deltaTime;
	animTimer[1] += deltaTime;
	animTimer[2] += deltaTime;

	if (bIsSpeaking)
	{
		//log(nextPhoneme, name);
		// if our framerate is high enough (>20fps), tween the lips smoothly
		if (Level.TimeSeconds - animTimer[3]  < 0.05)
			tweentime = 0.25; // Was 0.1
		else
			tweentime = 0.0;

		// the last animTimer slot is used to check framerate
		animTimer[3] = Level.TimeSeconds;

		//log(nextPhoneme$" "$bUseLipsyncHack,name);
		if(bLipsyncHackActive || (nextPhoneme == "" && bUseLipsyncHack))
		{
			bLipsyncHackActive = true;
			switch(rand(8))
			{
			case 0:
				nextPhoneme="A";
				break;
			case 1:
				nextPhoneme="E";
				break;
			case 2:
				nextPhoneme="F";
				break;
			case 3:
				nextPhoneme="M";
				break;
			case 4:
				nextPhoneme="O";
				break;
			case 5:
				nextPhoneme="T";
				break;
			case 6:
				nextPhoneme="U";
				break;
			case 7:
				nextPhoneme="X";
				break;
			}
		}

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

		if (animseq != '')
		{
			if (lastPhoneme != nextPhoneme)
			{
				lastPhoneme = nextPhoneme;
				if (HasAnim(animseq))
					TweenBlendAnim(animseq, tweentime);
			}
		}
	}
	else if (bWasSpeaking)
	{
		bWasSpeaking = False;
		if ( HasAnim('MouthClosed') )
			TweenBlendAnim('MouthClosed', tweentime);
	}

	// blink randomly
	if (animTimer[0] > 2.0)
	{
		animTimer[0] = 0;
		if ((FRand() < 0.4  || IsInState('RubbingEyes')) && HasAnim('Blink'))
			PlayBlendAnim('Blink', 1.0, 0.1, 1);
	}
}

function bool GetCarcassData(actor sender, out Name killer, out Name alliance,
							 out Name CarcassName, optional bool bCheckName)
{
	local trestkon  dxPlayer;
	local DeusExCarcass carcass;
	local POVCorpse     corpseItem;
	local bool          bCares;
	local bool          bValid;

	alliance = '';
	killer   = '';

	bValid   = false;
	dxPlayer = trestkon(sender);
	carcass  = DeusExCarcass(sender);
	if (dxPlayer != None)
	{
		if (dxplayer.bBreakAndEnter && bHateBreakAndEnter) //hello major hack
		{
			killer      = 'Player';
			return true; //treat the player as if hes carrying a corpse
		}
		else
		{
			corpseItem = POVCorpse(dxPlayer.inHand);
			if (corpseItem != None)
			{
				if (corpseItem.bEmitCarcass)
				{
					alliance    = corpseItem.Alliance;
					killer      = corpseItem.KillerAlliance;
					CarcassName = corpseItem.CarcassName;
					bValid      = true;
				}
			}
		}
	}
	else if (carcass != None)
	{
		if (carcass.bEmitCarcass)
		{
			alliance    = carcass.Alliance;
			killer      = carcass.KillerAlliance;
			CarcassName = carcass.CarcassName;
			bValid      = true;
		}
	}

	bCares = false;
	if (bValid && (!bCheckName || !HaveSeenCarcass(CarcassName)))
	{
		if (bFearCarcass)
			bCares = true;
		else
		{
			if (GetAllianceType(alliance) == ALLIANCE_Friendly)
			{
				if (bHateCarcass)
					bCares = true;
				else if (bReactCarcass)
				{
					if (GetAllianceType(killer) == ALLIANCE_Hostile)
						bCares = true;
				}
			}
		}
	}

	return bCares;
}

function UpdateReactionCallbacks()
{
	if (bReactTheft)
	{
		AISetEventCallback('Theft', 'HandleTheft', , false, false, false, false);
	}
	else
	{
		AISetEventCallback('Theft', 'HandleFutz', , false, false, false, false);
	}
	super.UpdateReactionCallbacks();
}

function SetSkinStyle(ERenderStyle newStyle, optional texture newTex, optional float newScaleGlow)
{
	local int i;

	super.SetSkinStyle(newstyle,newTex,newScaleGlow);

	if(newStyle!=STY_Translucent || newTex==None)
		return;

	//yay reusable code
	if	(Mesh==LodMesh'GM_DressShirt_B')
	{
		MultiSkins[4]=Texture'BlackMaskTex';
	}
	else if	(Mesh==LodMesh'GM_DressShirt')
	{
		MultiSkins[6]=Texture'BlackMaskTex';
		MultiSkins[7]=Texture'BlackMaskTex';
	}
	else if	(Mesh==LodMesh'GM_Jumpsuit' || Mesh==LodMesh'mp_jumpsuit')
	{
		MultiSkins[5]=Texture'BlackMaskTex';
	}
	else if	(Mesh==LodMesh'GM_DressShirt_F')
	{
		MultiSkins[6]=Texture'BlackMaskTex';
		MultiSkins[7]=Texture'BlackMaskTex';
	}
	else if	(Mesh==LodMesh'GM_DressShirt_S')
	{
		MultiSkins[6]=Texture'BlackMaskTex';
		MultiSkins[7]=Texture'BlackMaskTex';
	}
	else if	(Mesh==LodMesh'GM_Suit')
	{
		MultiSkins[5]=Texture'BlackMaskTex';
		MultiSkins[6]=Texture'BlackMaskTex';
	}
	else if	(Mesh==LodMesh'GM_Trench')
	{
		MultiSkins[6]=Texture'BlackMaskTex';
		MultiSkins[7]=Texture'BlackMaskTex';
	}
	else if	(Mesh==LodMesh'GM_Trench_F')
	{
		MultiSkins[6]=Texture'BlackMaskTex';
		MultiSkins[7]=Texture'BlackMaskTex';
	}
	else if	(Mesh==LodMesh'GFM_TShirtPants')
	{
		MultiSkins[3]=Texture'BlackMaskTex';
		MultiSkins[4]=Texture'BlackMaskTex';
	}
	else if	(Mesh==LodMesh'GFM_SuitSkirt_F')
	{
		MultiSkins[6]=Texture'BlackMaskTex';
		MultiSkins[7]=Texture'BlackMaskTex';
	}
	else if	(Mesh==LodMesh'GFM_SuitSkirt')
	{
		MultiSkins[6]=Texture'BlackMaskTex';
		MultiSkins[7]=Texture'BlackMaskTex';
	}
	else if	(Mesh==LodMesh'GFM_Trench')
	{
		MultiSkins[6]=Texture'BlackMaskTex';
		MultiSkins[7]=Texture'BlackMaskTex';
	}
	else if	(Mesh==LodMesh'GFM_Dress')
	{
		//no glasses
	}
	else if	(Mesh==LodMesh'GMK_DressShirt_F')
	{
		MultiSkins[6]=Texture'BlackMaskTex';
		MultiSkins[7]=Texture'BlackMaskTex';
	}
	else if	(Mesh==LodMesh'GMK_DressShirt')
	{
		MultiSkins[6]=Texture'BlackMaskTex';
		MultiSkins[7]=Texture'BlackMaskTex';
	}
}

function float GetCowerHeight()
{
	return (Default.CollisionHeight*0.75);
}

function PlayCowerBegin()
{
	super.PlayCowerBegin();
	SetBasedPawnSize(CollisionRadius, GetCowerHeight());
}

function PlayCowerEnd()
{
	super.PlayCowerEnd();
	ResetBasedPawnSize();
}

function HandleTheft(Name event, EAIEventState state, XAIParams params)
{
	if (state == EAISTATE_Begin || state == EAISTATE_Pulse)
		ReactToTheft();  // only players can steal
}

function ReactToTheft()
{
	if (bReactTheft && (FutzTimer <= 0) && !bDistressed) //put it on thesame timer as futzes
	{
		FutzTimer = 2.0;
		PlayTheftSound();
	}
}

function PlayTheftSound()
{
	local DeusExPlayer dxPlayer;
	local Name         conName;
	local string conNameString;

	dxPlayer = DeusExPlayer(GetPlayerPawn());
	if (dxPlayer != None)
	{
		if (dxPlayer.barkManager != None)
		{
			if (BarkBindName == "")
				conNameString = BindName $ "_Bark";
			else
				conNameString = BarkBindName $ "_Bark";

			conNameString = conNameString $ "Theft";

			// Take the string name and convert it to a name
			conName = DeusExRootWindow(dxPlayer.RootWindow).StringToName(conNameString);

			dxPlayer.StartConversationByName(conName, self, !bInterruptState);
		}
	}
}

simulated function Destroyed()
{
	local ScriptedPawn childPawn;
	
	if(breathgen != none)
		breathgen.delayeddestroy();
	
	// Kill all summoned spydrones when dying
	if (bAugmented && Role == ROLE_Authority)
	{
		// aDroneClass = class<ScriptedPawn>(DynamicLoadObject(droneClass, class'ScriptedPawn'));
		// if (adroneClass != None)
		// {
			foreach AllActors(class'ScriptedPawn', childPawn)
			{
				if (childPawn.Owner == Self/* && childPawn.IsA(localPlayer.rootWindow.StringToName(DroneClass))*/)
				{
					if (Robot(childPawn) != None)
						childPawn.TakeDamage(Robot(childPawn).EMPHitPoints, childPawn, childPawn.Location, vect(0,0,0), 'EMP');
					else
						childPawn.TakeDamage(childPawn.Health, childPawn, childPawn.Location, vect(0,0,0), 'tantalus');
				}
			}
		// }
	}

	super.Destroyed();
	KillShadow(); //shadows were being left behind when filtering out pawns for difficulty settings
}

function FollowOrders(optional bool bDefer) //for Formation state -shacker
{
	if(Orders=='Formation')
	{
		FindOrderActor();
		if (bDefer)  // hack
			SetState(Orders);
		else
			GotoState(Orders);
	}
	else
		super.FollowOrders(bDefer);
}

function float GetAugScoreModifier(deusexplayer enemyplayer, class<Augmentation> aug)
{
	local float result;
	result = enemyPlayer.AugmentationSystem.GetAugLevelValue(aug);
	if (result == -1)
		return 0;
	else
	{
		result = 100 *  result;
		return result;
	}
}

function bool SwitchToBestWeapon()
{
	local Inventory    inv;
	local DeusExWeapon curWeapon;
	local float        score;
	local DeusExWeapon dxWeapon;
	local DeusExWeapon bestWeapon;
	local float        bestScore;
	local int          fallbackLevel;
	local int          curFallbackLevel;
	local bool         bBlockSpecial;
	local bool         bValid;
	local bool         bWinner;
	local float        minRange, accRange;
	local float        range, centerRange;
	local float        cutoffRange;
	local float        enemyRange;
	local float        minEnemy, accEnemy, maxEnemy;
	local ScriptedPawn enemyPawn;
	local TNMPawn      tpawn;
	local Robot        enemyRobot;
	local DeusExPlayer enemyPlayer;
	local float        enemyRadius;
	local bool         bEnemySet;
	local int          loopCount, i;  // hack - check for infinite inventory
	local Inventory    loopInv;       // hack - check for infinite inventory
	local Ammo PossibleAmmo;

	if (bInConversation)
		return false;

	if (ShouldDropWeapon())
	{
		DropWeapon();
		return false;
	}

	bBlockSpecial = false;
	dxWeapon = DeusExWeapon(Weapon);
	if (dxWeapon != None)
	{
		if (dxWeapon.AITimeLimit > 0)
		{
			if (SpecialTimer <= 0)
			{
				bBlockSpecial = true;
				FireTimer = dxWeapon.AIFireDelay;
			}
		}
	}

	bestWeapon      = None;
	bestScore       = 0;
	fallbackLevel   = 0;
	inv             = Inventory;

	bEnemySet   = false;
	minEnemy    = 0;
	accEnemy    = 0;
	enemyRange  = 400;  // default
	enemyRadius = 0;
	enemyPawn   = None;
	enemyRobot  = None;
	if (Enemy != None)
	{
		bEnemySet   = true;
		enemyRange  = VSize(Enemy.Location - Location);
		enemyRadius = Enemy.CollisionRadius;
		if (DeusExWeapon(Enemy.Weapon) != None)
			DeusExWeapon(Enemy.Weapon).GetWeaponRanges(minEnemy, accEnemy, maxEnemy);
		enemyPawn   = ScriptedPawn(Enemy);
		enemyRobot  = Robot(Enemy);
		enemyPlayer = DeusExPlayer(Enemy);
	}

	loopCount = 0;
	for ( inv = Inventory; inv != None; inv = inv.Inventory)
	{
		// THIS IS A MAJOR HACK!!!
		loopCount++;
		if (loopCount == 9999)
		{
			log("********** RUNAWAY LOOP IN SWITCHTOBESTWEAPON ("$self$") **********");
			loopInv = Inventory;
			i = 0;
			while (loopInv != None)
			{
				i++;
				if (i > 300)
					break;
				log("   Inventory "$i$" - "$loopInv);
				loopInv = loopInv.Inventory;
			}
		}

		curWeapon = DeusExWeapon(inv);
		if (curWeapon != None)
		{
			bValid = true;
			if (curWeapon.ReloadCount > 0)
			{
				if (curWeapon.AmmoType == None)
					bValid = false;
				else if (curWeapon.AmmoType.IsA('AmmoNapalmL'))	// Specifically requires at least 2
				{
					if (curWeapon.AmmoType.AmmoAmount < 2)
						bValid = false;
				}
				else if (curWeapon.AmmoType.AmmoAmount < 1)
					bValid = false;
				// else
				// {
				if (!bValid)
					for (i=0; i<ArrayCount(curWeapon.AmmoNames); i++)
					{
						if (curWeapon.AmmoNames[i] != None)
							PossibleAmmo = Ammo(FindInventoryType(curWeapon.AmmoNames[i]));
						
						if (PossibleAmmo != None && PossibleAmmo.AmmoAmount > 0)
						{
							bValid = true;
							curWeapon.LoadAmmo(i);
							break;
						}
					}
				// }
			}

			// if ( curWeapon.beltDescription == "SPYWARE" )
			if ( curWeapon.IsA('WeaponBlackBox'))
				bValid = false;

			// Ensure we can actually use this weapon here
			if (bValid)
			{
				// lifted from DeusExWeapon...
				if ((curWeapon.EnviroEffective == ENVEFF_Air) || (curWeapon.EnviroEffective == ENVEFF_Vacuum) ||
				    (curWeapon.EnviroEffective == ENVEFF_AirVacuum))
					if (curWeapon.Region.Zone.bWaterZone)
						bValid = false;
						
				if (curWeapon.EnviroEffective == ENVEFF_Air || curWeapon.EnviroEffective == ENVEFF_Water || curWeapon.EnviroEffective == ENVEFF_AirWater )
					if (tnmzoneinfo(region.zone) != None && tnmzoneinfo(region.zone).bNoOxygen)
						bValid = false;
			}

			if (bValid)
			{
				GetWeaponBestRange(curWeapon, minRange, accRange);
				cutoffRange = minRange+(CollisionRadius+enemyRadius);
				range = (accRange - minRange) * 0.5;
				centerRange = minRange + range;
				if (range < 50)
					range = 50;
				if (enemyRange < centerRange)
					score = (centerRange - enemyRange)/range;
				else
					score = (enemyRange - centerRange)/range;
				if ((minRange >= minEnemy) && (accRange <= accEnemy))
					score += 0.5;  // arbitrary
				if ((cutoffRange >= enemyRange-CollisionRadius) && (cutoffRange >= 256)) // do not use long-range weapons on short-range targets
					score += 10000;

				curFallbackLevel = 3;
				if (curWeapon.bFallbackWeapon && !bUseFallbackWeapons)
					curFallbackLevel = 2;
				if (!bEnemySet && !curWeapon.bUseAsDrawnWeapon)
					curFallbackLevel = 1;
				if ((curWeapon.AIFireDelay > 0) && (FireTimer > 0))
					curFallbackLevel = 0;
				if (bBlockSpecial && (curWeapon.AITimeLimit > 0) && (SpecialTimer <= 0))
					curFallbackLevel = 0;

				// Adjust score based on opponent and damage type.
				// All damage types are listed here, even the ones that aren't used by weapons... :)
				// (hacky...)


				if (enemyPlayer != none)
				{
					if(!curWeapon.bInstantHit && curWeapon.ProjectileClass != None)
					{
						if (!class<deusexprojectile>(curWeapon.ProjectileClass).default.bIgnoresNanoDefense)
						{
							score += enemyPlayer.AugmentationSystem.GetAugLevelValue(class'AugDefense');
						}
					}
				}
				if (curWeapon.MustReload())
					score += 2;

				switch (curWeapon.WeaponDamageType())
				{
					case 'Shocked':
						if(bSmartWeapons)
							if (enemyPlayer != none)
								score += GetAugScoreModifier( enemyplayer, class'AugShield' );
						break;
					case 'Exploded':
						// Massive explosions are always good
						score -= 0.2;
						if(bSmartWeapons)
							if (enemyPlayer != none)
								score += GetAugScoreModifier( enemyplayer, class'AugShield' );
						break;

					case 'Stunned':
						if (enemyPawn != None)
						{
							if (enemyPawn.bStunned)
								score += 1000;
							else
								score -= 1.5;
						}
						if (enemyPlayer != None)
							score += 10;
						break;

					case 'TearGas':
						if (enemyPawn != None)
						{
							if (enemyPawn.bStunned)
								//score += 1000;
								bValid = false;
							else
								score -= 5.0;
						}
						if (enemyRobot != None)
							//score += 10000;
							bValid = false;
						else if (Enemy != None && enemy.IsA('TNMAnimal'))
							bValid = false;
						else if (Enemy != None && enemy.IsA('GenericAlien'))
							bValid = false;
						break;
						
					case 'KnockedOut':
						if (enemyRobot != None)
							//score += 10000;
							bValid = false;
						break;

					case 'HalonGas':
						if (enemyPawn != None)
						{
							if (enemyPawn.bStunned)
								//score += 1000;
								bValid = false;
							else if (enemyPawn.bOnFire)
								//score += 10000;
								bValid = false;
							else
								score -= 3.0;
						}
						if (enemyRobot != None)
							//score += 10000;
							bValid = false;
						else if (Enemy != None && enemy.IsA('TNMAnimal'))
							bValid = false;
						else if (Enemy != None && enemy.IsA('GenericAlien'))
							bValid = false;
						if (enemyPlayer != None)
						{
							if (enemyPlayer.bOnFire)
								bValid = false;
							else
								score += 30.0;
						}
						break;

					case 'PoisonGas':
					case 'Poison':
					case 'PoisonEffect':
					case 'Radiation':
						if (enemyRobot != None)
							//score += 10000;
							bValid = false;
						break;
					case 'HeadStun':
						if (enemyRobot != None)
							//score += 10000;
							bValid = false;
						else if (Enemy != None && enemy.IsA('TNMAnimal'))
							bValid = false;
						break;

					case 'Burned':
					case 'Flamed':
						if(bSmartWeapons)
						{
							if (enemyPlayer != none)
								score += GetAugScoreModifier( enemyplayer, class'AugShield' );
						}
						if (enemyPawn != None && (enemyPawn.IsA('Alien') || enemyPawn.IsA('Irradiator')) && !curWeapon.IsA('WeaponFireBlade'))
							bValid = false;
						if (enemyRobot != None)
							score += 0.5;
						break;

					case 'AutoShot':
					case 'Shot':
						if(bSmartWeapons)
							if (enemyPlayer != none)
								score += GetAugScoreModifier( enemyplayer, class'AugBallistic' );
						if (enemyRobot != None)
							score += 0.5;
						break;

					case 'Sabot':
						if (enemyRobot != None)
							score -= 0.5;
						break;

					case 'EMP':
						bValid = false;
						if(bSmartWeapons)
						{
							if (enemyPlayer != none)
							{
								score += GetAugScoreModifier( enemyplayer, class'AugEMP' );
								bValid = true;
							}
						}

						if (enemyRobot != None)
						{
							score -= 5.0;
							bValid = true;
						}

						if (enemypawn != none)
						{
							tpawn = TNMPawn(enemypawn);
							if (tpawn != none)
							{
								if (tpawn.bFirewall || (tpawn.bAugmented && tpawn.energy > 0))
								{
									score -= 5.0;
									bValid = true;
								}
							}
						}

						break;
					case 'NanoVirus':
						if (enemyRobot != None)
							score -= 5.0;
						else
							//score += 10000;
							bValid = false;
						break;
					case 'Temporal':
						if (enemypawn != None && enemyPawn.IsInState('StunnedTemporal'))	// The only weapon that can deal damage in this state
							score -= 10000.0;
						else if (enemyplayer != None && enemyplayer.IsInState('StunnedTemporal')) // Functional but less fun to be stunned for 200 ammos worth
							score += Trestkon(enemyPlayer).temporalness;
						break;

					case 'Drowned':
					default:
						break;
				}

				// Special case for current weapon
				if ((curWeapon == Weapon) && (WeaponTimer < 10.0))
				{
					// If we last changed weapons less than five seconds ago,
					// keep this weapon
					if (WeaponTimer < 5.0)
						score = -10;

					// If between five and ten seconds, use a sliding scale
					else
						score -= (10.0 - WeaponTimer)/5.0;
				}

				// Throw a little randomness into the computation...
				else
				{
					score += FRand()*0.1 - 0.05;

					//not sure why this would be required.
					if (score < 0)
						score = 0;
				}

				if (bValid)
				{
					// ugly
					if (bestWeapon == None)
						bWinner = true;
					else if (curFallbackLevel > fallbackLevel)
						bWinner = true;
					else if (curFallbackLevel < fallbackLevel)
						bWinner = false;
					else if (bestScore > score)
						bWinner = true;
					else
						bWinner = false;
					if (bWinner)
					{
						bestScore     = score;
						bestWeapon    = curWeapon;
						fallbackLevel = curFallbackLevel;
					}
				}
			}
		}
	}

	// If we're changing weapons, reset the weapon timers
	if (Weapon != bestWeapon)
	{
		if (!bEnemySet)
			WeaponTimer = 10;  // hack
		else
			WeaponTimer = 0;

		ReloadTimer = 0;

		if (bestWeapon != None)
		{
			if (bestWeapon.AITimeLimit > 0)
				SpecialTimer = bestWeapon.AITimeLimit;

			//Added to play the out of ammo bark
			if (Weapon != none)
			{
				if (Weapon.ReloadCount > 0)
				{
					if ( bestWeapon.bHandToHand )
					{
						if (Weapon.AmmoType == None)
							PlayOutOfAmmoSound();
						else if (Weapon.AmmoType.AmmoAmount < 1)
							PlayOutOfAmmoSound();
					}
				}
			}
		}
	}

	SetWeapon(bestWeapon);

	return false;
}

function SwitchToKilledSkin()
{
}

function TakeDamageBase(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType,
						bool bPlayAnim)
{
	if (damagetype =='HalonGas')
		if (bOnFire)
			ExtinguishFire();
			
	if ((DamageType == 'Flamed') && !bOnFire)
	{
		if (instigatedBy != None)
			Burner = instigatedBy;
		// CatchFire();
	}
	
	// Prevent blood
	// if(DamageType == 'FistStunned')
		// damageType = 'Stunned';
	if (DamageType == 'Temporal')
	{
		if (!bInvincible)
		{
			if (Damage > 0)
			{
				Momentum = Vect(0,0,0);
			}
		}
	}

	super.TakeDamageBase(Damage, instigatedBy, hitlocation, momentum, damageType, bPlayAnim);
}

function PlayTakeHitSound(int Damage, name damageType, int Mult)
{
	if (IsInState('Burning') && damageType == 'Burned')
		return;
	else
		Super.PlayTakeHitSound(Damage, damageType, Mult);
}

function PlayerDetected(name StateType)
{
	local tnmmissionscript scr;
	
	// Only trigger from the player from now on.
	if (DeusExPlayer(Enemy) == None)
		return;
	
	foreach allactors(class'tnmmissionscript',scr)
	{
		scr.PlayerDetected(StateType, Self);
		break;
	}
}

// ScriptedPawn States

state Standing
{
	ignores EnemyNotVisible;

	function Tick(float deltaTime)
	{
		animTimer[1] += deltaTime;
		Global.Tick(deltaTime);
		LipSynchBarks(deltaTime);
	}
	
	function BeginState()
	{
		local string localURL;
		local DeusExLevelInfo dxInfo;
		
		Super.BeginState();

		foreach AllActors(class'DeusExLevelInfo', dxInfo)
			break;
		
		if (dxInfo != None)
			localURL = Caps(dxInfo.mapName);
			
		if (localURL == "23_ABIEXTERIOR" || localURL == "23_ABIEXTERIOR_2009")
		{
			if(!bBreathDesynced && AnimSequence == 'BreatheLight' || AnimSequence == 'BreatheLight2H' || AnimSequence == 'SitBreathe')
				AnimFrame = FRand();
			bBreathDesynced = True;
		}
	}
}

state Dancing
{
	ignores EnemyNotVisible;

	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);
		
		LipSynchBarks(deltaTime);
	}
}

state Sitting
{
	ignores EnemyNotVisible;

	function Tick(float deltaTime)
	{
		local vector endPos;
		local vector newPos;
		local float  delta;

		Global.Tick(deltaTime);
		
		LipSynchBarks(deltaTime);

		if (bSitInterpolation && (SeatActor != None))
		{
			endPos = SitPosition(SeatActor, SeatSlot);
			if ((deltaTime < remainingSitTime) && (remainingSitTime > 0))
			{
				delta = deltaTime/remainingSitTime;
				newPos = (endPos-Location)*delta + Location;
				remainingSitTime -= deltaTime;
			}
			else
			{
				remainingSitTime = 0;
				bSitInterpolation = false;
				newPos = endPos;
				Acceleration = vect(0,0,0);
				Velocity = vect(0,0,0);
				SetBase(SeatActor);
				bSitting = true;
			}
			SetLocation(newPos);
			DesiredRotation = SeatActor.Rotation+Rot(0, -16384, 0);
		}
		
		if (bSitting && bPlayIdle)
		{
			idleSitTime += deltaTime;
			
			if (idleSitTime >= 15)
			{
				if (FRand() > 0.3)
					PlayIdleSound();
					
				idleSitTime = 0;
			}
		}
	}
}

state Wandering
{
	ignores EnemyNotVisible;

	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);

		LipSynchBarks(deltaTime);
	}
}



state Crouching
{
	ignores EnemyNotVisible;

	function AnimEnd()
	{
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Global.HitWall(HitNormal, Wall);
	}

	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);
		
		LipSynchBarks(deltaTime);
	}

	function BeginState()
	{
		local actor focus;

		StandUp();
		SetEnemy(None, EnemyLastSeen, true);
		bCanJump = false;

		bStasis = False;

		SetupWeapon(false);
		SetDistress(false);
		SeekPawn = None;
		EnableCheckDestLoc(false);

		foreach allactors(class'actor',focus,OrderTag)
			break;

		LookAtActor(focus, true, true, true, 0, 0.5);
		if (ShouldCrouch())
			StartCrouch();
	}

	function EndState()
	{
		EnableCheckDestLoc(false);
		bAcceptBump = True;

		if (JumpZ > 0)
			bCanJump = true;
		bStasis = True;

		StopBlendAnims();
		EndCrouch();
	}

	function bool ShouldCrouch()
	{
		if (bCanCrouch && !Region.Zone.bWaterZone)
			return true;
		else
			return false;
	}
	
	function float GetCrouchHeight()
	{
		return (Default.CollisionHeight*0.60);
	}

	function StartCrouch()
	{
		if (!bCrouching)
		{
			bCrouching = true;
			SetBasedPawnSize(CollisionRadius, GetCrouchHeight());
//			PlayDuck();
			PlayAnim('Crouch');
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

Begin:
	WaitForLanding();
	Acceleration=vect(0,0,0);

	bStasis = True;
}



// ----------------------------------------------------------------------
// GotoDisabledState()
// ----------------------------------------------------------------------

function GotoDisabledState(name damageType, EHitLocation hitPos)
{
	if (!bCollideActors && !bBlockActors && !bBlockPlayers)
		return;
	else if ((damageType == 'TearGas') || (damageType == 'HalonGas'))
		GotoState('RubbingEyes');
	else if (damageType == 'Stunned')
	{
		stuntime = 15;
		GotoState('Stunned');
	}
	else if (damageType == 'Temporal')
	{
		GotoState('StunnedTemporal');
	}
	else if (damageType == 'FistStunned')
	{
		stuntime = 4;
		GotoState('Stunned');
	}
	else if (damageType == 'StunnedTaser')
	{
		stuntime = 5;
		GotoState('StunnedTaser');
	}
	else if (IsInState('RubbingEyes') && (damageType == 'Poison' || damageType == 'PoisonEffect'))
		return;
	else if (IsInState('Burning') && damageType == 'Burned')
		return;
	else if (CanShowPain())
		TakeHit(hitPos);
	else
		GotoNextState();
}

// ----------------------------------------------------------------------
// state Stunned
//
// React to being stunned.
// ----------------------------------------------------------------------
state Stunned
{
	ignores seeplayer, hearnoise, bump, hitwall, stopwaiting;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
	{
		//WCCC 3/16/19: Weird fix for TakeDamage not being called conventionally.
		//"If it's dumb, but it works, it ain't dumb."
		//---------
		//EDIT: Moving this to the experimental ProxyTakeDamage function. Yay.
		//EMPDamage(damage,instigatedby,hitlocation,momentum,damagetype);
		if (!ProxyTakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType))
		{
			TakeDamageBase(Damage, instigatedBy, hitlocation, momentum, damageType, false);
			ProxyAugDeathCheck();
		}
	}

	function ReactToInjury(Pawn instigatedBy, Name damageType, EHitLocation hitPos)
	{
		if ((damageType != 'TearGas') && (damageType != 'HalonGas') && (damageType != 'Stunned'))
			Global.ReactToInjury(instigatedBy, damageType, hitPos);
	}

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
	}
	
	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);
		
		LipSynchBarks(deltaTime);
	}

Begin:
	Acceleration = vect(0, 0, 0);
	PlayStunned();
	Sleep(stuntime);
	if (HasNextState())
		GotoNextState();
	else
		GotoState('Wandering');
}

// ----------------------------------------------------------------------
// state Stunned
//
// React to being stunned.
// ----------------------------------------------------------------------
state StunnedTemporal
{
	ignores seeplayer, hearnoise, bump, hitwall, stopwaiting, ReactToInjury, SpurtBlood, AddVelocity;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
	{
		//WCCC 3/16/19: Weird fix for TakeDamage not being called conventionally.
		//"If it's dumb, but it works, it ain't dumb."
		//---------
		//EDIT: Moving this to the experimental ProxyTakeDamage function. Yay.
		//EMPDamage(damage,instigatedby,hitlocation,momentum,damagetype);
		if (damagetype == 'Temporal')
			if (!ProxyTakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType))
			{
				TakeDamageBase(Damage, instigatedBy, hitlocation, momentum, damageType, false);
				ProxyAugDeathCheck();
			}
	}

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
		GetPlayer();
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
				flagName = localplayer.rootWindow.StringToName(BindName$"_Dead");
				localplayer.flagBase.SetBool(flagName, True);

				// make sure the flag never expires
				localplayer.flagBase.SetExpiration(flagName, FLAG_Bool, 0);
			}
			Killed(localplayer, Self, 'Banned');
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
	if (HasNextState())
		GotoNextState();
	else
		GotoState('Wandering');
}

state AvoidingProjectiles
{
	ignores EnemyNotVisible;

	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);

		LipSynchBarks(deltaTime);
	}
}

state AvoidingPawn
{
	ignores EnemyNotVisible;

	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);

		LipSynchBarks(deltaTime);
	}
}

state BackingOff
{
	ignores EnemyNotVisible;

	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);

		LipSynchBarks(deltaTime);
	}
}

state OpeningDoor
{
	ignores EnemyNotVisible;

	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);

		LipSynchBarks(deltaTime);
	}
}

state TakingHit
{
	ignores seeplayer, hearnoise, bump, hitwall, reacttoinjury;

	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);
	
		LipSynchBarks(deltaTime);
	}
}

state Dying
{
	ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, Timer, TakeDamage;
	
	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);
	
		LipSynchBarks(deltaTime);
	}
	
Begin:
	if (Mass > Buoyancy && !FootRegion.Zone.bWaterZone && HeadRegion.Zone.bWaterZone)
		WaitForLanding();
	MoveFallingBody();

	DesiredRotation.Pitch = 0;
	DesiredRotation.Roll  = 0;

	// if we don't gib, then wait for the animation to finish
	if ((Health > -100) && !IsA('Robot') && !IsA('Bird') && !IsA('TNMRat'))
		FinishAnim();

	if (DeusExWeapon(Weapon) != None)
	{
		if (DeusExWeapon(Weapon).bLasing)
			DeusExWeapon(Weapon).LaserOff();
	}

	SetWeapon(None);

	bHidden = True;

	Acceleration = vect(0,0,0);
	SpawnCarcass();
	Destroy();
}

state FallingState
{
	ignores Bump, Hitwall, WarnTarget, ReactToInjury;

	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);
	
		LipSynchBarks(deltaTime);
	}
}

// ----------------------------------------------------------------------
// state RubbingEyes
//
// React to evil things like pepper spray.
// ----------------------------------------------------------------------
state RubbingEyes
{
	ignores seeplayer, hearnoise, bump, hitwall, stopwaiting;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
	{
		//WCCC 3/16/19: Weird fix for TakeDamage not being called conventionally.
		//"If it's dumb, but it works, it ain't dumb."
		//---------
		//EDIT: Moving this to the experimental ProxyTakeDamage function. Yay.
		//EMPDamage(damage,instigatedby,hitlocation,momentum,damagetype);
		if (!ProxyTakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType))
		{
			TakeDamageBase(Damage, instigatedBy, hitlocation, momentum, damageType, false);
			ProxyAugDeathCheck();
		}
	}

	function ReactToInjury(Pawn instigatedBy, Name damageType, EHitLocation hitPos)
	{
		if ((damageType != 'TearGas') && (damageType != 'HalonGas')/* && (damageType != 'Stunned')*/)
			Global.ReactToInjury(instigatedBy, damageType, hitPos);
	}

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
//		LastPainTime = Level.TimeSeconds;
//		LastPainAnim = AnimSequence;
		bInterruptState = false;
		BlockReactions();
		bCanConverse = False;
		bStasis = False;
		SetupWeapon(false, true);
		SetDistress(true);
		bStunned = True;
		bInTransientState = true;
		EnableCheckDestLoc(false);
		SetBasedPawnSize(CollisionRadius, CollisionHeight * 0.85);
	}

	function EndState()
	{
		EnableCheckDestLoc(false);
		bInterruptState = true;
		ResetReactions();
		bCanConverse = True;
		bStasis = True;
		if (Health > 0)
			bStunned = False;
		bInTransientState = false;
		ResetBasedPawnSize();
	}
	
	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);
	
		LipSynchBarks(deltaTime);
	}

Begin:
	Acceleration = vect(0, 0, 0);
	PlayTearGasSound();

RubEyes:
	PlayRubbingEyesStart();
	FinishAnim();
	PlayRubbingEyes();
	Sleep(15);
	PlayRubbingEyesEnd();
	FinishAnim();
	if (HasNextState())
		GotoNextState();
	else
		GotoState('Wandering');
}

// ----------------------------------------------------------------------
// PlayRubbingEyesStart()
// ----------------------------------------------------------------------

function PlayRubbingEyesStart()
{
	StopBlendAnims();
	Super.PlayRubbingEyesStart();
}

function PostBeginPlay()
{
	local string localURL;
	local DeusExLevelInfo dxInfo;

	foreach AllActors(class'DeusExLevelInfo', dxInfo)
		break;
	
	if (dxInfo != None)
		localURL = Caps(dxInfo.mapName);
	
	Super.PostBeginPlay();
	
	// if (Animal(Self) != None || Robot(Self) != None)
	if (Mesh == None || !HasAnim('HeadLeft'))
		bLookAtPlayer = False;
		
	GetPlayer();

	// change the sounds for chicks
	if (bIsFemale)
	{
		HitSound1 = Sound'FemalePainMedium';
		HitSound2 = Sound'FemalePainLarge';
		Die = Sound'FemaleDeath';
	}

	//added
	if (baugmented)
	{
		if (TNMPAM !=none)
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
	//added		
	if (localURL == "23_ABIEXTERIOR" || localURL == "23_ABIEXTERIOR_2009" || localURL == "23_ABIAPPROACH" || localURL == "95_STEALTH7")
		bVisibleBreath = True;

	//DDL breath stuff
	if (bInWorld && bVisibleBreath && breathgen == none && !HeadRegion.Zone.bWaterZone)
	{
		if (SnowZone(Region.Zone) != None)
			spawnBreathgen();
	}
	
	if (bCustomBarkPitch && !bPitchSet)
	{
		barkPitch = barkPitchMin + (FRand() * (barkPitchMax-barkPitchMin));
		bPitchSet = True;
	}
	
	// Handle holograms
	if ((Style != STY_Masked) && (Style != STY_Normal))
	{
		bFearHacking		= False;
		bFearWeapon			= False;
		bFearShot			= False;
		bFearInjury			= False;
		bFearIndirectInjury	= False;
		bFearCarcass		= False;
		bFearDistress		= False;
		bFearAlarm			= False;
		bFearProjectiles	= False;
	}
		
	if (bMirrorPawn)
	{
		Style = STY_Translucent;
		// Because holograms
		SetSkinStyle(Style, None);
		SetCollision(True, True, True);
		KillShadow();
		bHasShadow = False;
		bCanBleed = False;
	}
}


// ----------------------------------------------------------------------
// HandleDamage()
// ----------------------------------------------------------------------

function EHitLocation HandleDamage(int actualDamage, Vector hitLocation, Vector offset, name damageType)
{
	local EHitLocation hitPos;
	local float        headOffsetZ, headOffsetY, armOffset;

	// calculate our hit extents
	headOffsetZ = CollisionHeight * 0.7;
	headOffsetY = CollisionRadius * 0.3;
	armOffset   = CollisionRadius * 0.35;

	if ( bHelmeted )
	{
		if (offset.z > CollisionHeight * 0.7)
		{
			if (damagetype == 'knockedout')
				actualDamage *= 0.25;
			else if (damagetype == 'headstun')
				actualDamage *= 0;
		}
	}

	if (actualDamage > 0)
	{
		if (offset.z > headOffsetZ)
		{
			if(damagetype=='headstun')
			{
				healthhead = 1;
				damagetype = 'knockedout';
				if (Instigator != None)
					TakeDamage( 50, Instigator, hitlocation, vect(0,0,0),'knockedout');
				else
					TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');
				if (Trestkon(GetPlayerPawn()) != None)
					Trestkon(GetPlayerPawn()).SetAchievement("achRice"); // Assume player
			}
		}
	}

	hitPos = HITLOC_None;

	if (actualDamage > 0)
	{
		//== Y|y: Kinda hacky, but we don't want to actually damage invincible pawns, just play the animations
		// if(bInvincible || bAnimOnly) // Just want the animation without hurting them
		if(bInvincible)
			actualDamage = 0;

		if (offset.z > headOffsetZ)		// head
		{
			// narrow the head region
			if ((Abs(offset.x) < headOffsetY) || (Abs(offset.y) < headOffsetY))
			{
				// don't allow headshots with stunning weapons
				//G-Flex: Original code made stunning headshots do half damage of other stunning shots.
				//G-Flex: This was dumb because it encouraged hitting people in the torso for KOs.
				if ((damageType == 'Stunned') || (damageType == 'KnockedOut') || (damageType == 'Stomped'))
					HealthHead -= actualDamage * 3;
				else if (damageType == 'Poison')
					HealthHead -= actualDamage * 8;
				else
					HealthHead -= actualDamage * 8;
				if (offset.x < 0.0)
					hitPos = HITLOC_HeadBack;
				else
					hitPos = HITLOC_HeadFront;
			}
			else  // sides of head treated as torso
			{
				HealthTorso -= actualDamage * 2;
				if (offset.x < 0.0)
					hitPos = HITLOC_TorsoBack;
				else
					hitPos = HITLOC_TorsoFront;
			}
		}
		else if (offset.z < 0.0)	// legs
		{
			if (offset.y > 0.0)
			{
				HealthLegRight -= actualDamage * 2;
				if (offset.x < 0.0)
					hitPos = HITLOC_RightLegBack;
				else
					hitPos = HITLOC_RightLegFront;
			}
			else
			{
				HealthLegLeft -= actualDamage * 2;
				if (offset.x < 0.0)
					hitPos = HITLOC_LeftLegBack;
				else
					hitPos = HITLOC_LeftLegFront;
			}

 			// if this part is already dead, damage the adjacent part
			if ((HealthLegRight < 0) && (HealthLegLeft > 0))
			{
				HealthLegLeft += HealthLegRight;
				HealthLegRight = 0;
			}
			else if ((HealthLegLeft < 0) && (HealthLegRight > 0))
			{
				HealthLegRight += HealthLegLeft;
				HealthLegLeft = 0;
			}

			if (HealthLegLeft < 0)
			{
				HealthTorso += HealthLegLeft;
				HealthLegLeft = 0;
			}
			if (HealthLegRight < 0)
			{
				HealthTorso += HealthLegRight;
				HealthLegRight = 0;
			}
		}
		else						// arms and torso
		{
			if (offset.y > armOffset)
			{
				HealthArmRight -= actualDamage * 2;
				if (offset.x < 0.0)
					hitPos = HITLOC_RightArmBack;
				else
					hitPos = HITLOC_RightArmFront;
			}
			else if (offset.y < -armOffset)
			{
				HealthArmLeft -= actualDamage * 2;
				if (offset.x < 0.0)
					hitPos = HITLOC_LeftArmBack;
				else
					hitPos = HITLOC_LeftArmFront;
			}
			else
			{
				HealthTorso -= actualDamage * 2;
				if (offset.x < 0.0)
					hitPos = HITLOC_TorsoBack;
				else
					hitPos = HITLOC_TorsoFront;
			}

			// if this part is already dead, damage the adjacent part
			if (HealthArmLeft < 0)
			{
				HealthTorso += HealthArmLeft;
				HealthArmLeft = 0;
			}
			if (HealthArmRight < 0)
			{
				HealthTorso += HealthArmRight;
				HealthArmRight = 0;
			}
		}
	}

	GenerateTotalHealth();

	return hitPos;
}



function bool WillTakeStompDamage(actor stomper)
{
	// This blows chunks!
	if (stomper.IsA('PlayerPawn') && (GetPawnAllianceType(Pawn(stomper)) != ALLIANCE_Hostile))
		return false;
	else
		return true;
}


function tick(float deltatime)
{
	local vector NewVect;
	local MotionBlurEffect blur;
	local int i;
	local TNMAugmentation TNMA;
	
	fat += deltatime;
	if (fat >=0.5)
	{
		fat = 0.0;
		if (fatness > default.fatness) //not sure if this will take the default fatness of TNMPawn or the class that is inheriting this method.
			fatness -= 1;
	}

	//DDL breath stuff
	if(breathgen != none)
	{
		Updatebreathgen(deltatime);
	}

	if ( tnmzoneinfo(HeadRegion.Zone) != None && tnmzoneinfo(HeadRegion.Zone).bNoOxygen )
	{
		timewithouto2 += deltatime;
		if ( timewithouto2 > 30 )
		{
			TakeDamage(5, None, Location, vect(0,0,0), 'Drowned'); 
			timewithouto2 -= 1;
		}
	}

	// LastRendered() is the host's view; in co-op also require that no player can see us
	if (bDisappear && (InStasis() || (LastRendered() > 5.0)) && ((Level.NetMode == NM_Standalone) || !PlayerCanSeeMe()))
	{
		LeaveWorld();
		return;
	}

	if (Physics == PHYS_Swimming)
	{
		dripRate += deltaTime*2;
				
		if (dripRate >= 15)
			dripRate = 15.0;
	}
	else if (dripRate > 0)
		DripWater(deltaTime);
	
	GetPlayer();
	
	if (localPlayer != None && localPlayer.bNightmareMode)
		MaxDesiredSpeed = 1.5;
	
	if (bLookAtPlayer)
	{
		playerLastSeenTimer += deltaTime;
		lookCheckTime += deltaTime;
		
		// Performance
		if (lookCheckTime > 0.25)
		{
			lookCheckTime = 0;
			
			// Only look at the player if we're not busy in a conversation or dealing with an enemy. 
			// Look at them if in fleeing or alerting state because then they're the enemy.
			// Look at them while attacking but not seeking, otherwise our head stays turned during attacks
			if (ConversationActor == None && (Enemy == None || IsInState('Fleeing') || IsInState('Alerting') || IsInState('Attacking')) && !IsInState('Burning') && !IsInState('RubbingEyes') && !IsInState('Stunned'))
			{
				// Can we see the player
				if (localPlayer != None && !localPlayer.IsInState('Cinematic') && !localPlayer.IsInState('Interpolating') &&
				(VSize(localPlayer.Location-Location) <= 320) && 
				AICanSee(localPlayer,, True, True, True, True) > 0 && 
				((!IsInState('Conversation') && !IsInState('FirstPersonConversation')) || IsInState('Fleeing') || IsInState('Alerting') || IsInState('Attacking')))
				{
					if (lookingAtPlayerTime < 3)
						LookAtActor(localPlayer, false, true, true, 0, 1);
					bLookingReset = False;
					playerLastSeenTimer = 0;
					lookingAtPlayerTime += deltaTime + 0.25; // Compensate for lookCheckTime
				}
				else if (lookAtTarget != None && 
				(VSize(lookAtTarget.Location-Location) <= 320) && 
				AICanSee(lookAtTarget,, True, True, True, True) > 0 && 
				((GetPawnAllianceType(lookAtTarget) != ALLIANCE_Hostile && !IsInState('Conversation') && !IsInState('FirstPersonConversation')) || IsInState('Fleeing') || IsInState('Alerting') || IsInState('Attacking')))
				{
					if (lookingAtPlayerTime < 3)
						LookAtActor(lookAtTarget, false, true, true, 0, 1);
					bLookingReset = False;
					playerLastSeenTimer = 0;
					lookingAtPlayerTime += deltaTime + 0.25; // Compensate for lookCheckTime
				}
				
				if (lookingAtPlayerTime >= 3 && !bLookingReset) // Look at the player for three seconds, awkwardly look away for two seconds.			
				{
					PlayTurnHead(LOOK_Forward, 1.0, 1.0);
					bLookingReset = True;
					if (lookingAtPlayerTime >= 5 + FRand())
						lookingAtPlayerTime = 0;
				}
				else if ((playerLastSeenTimer > FRand() + 0.5) && !bLookingReset) // Lost sight of the player, look forward after 0.5-1.5 seconds
				{
					PlayTurnHead(LOOK_Forward, 1.0, 1.0);
					bLookingReset = True;
				}	
			}
		}
	}

	if (Level.NetMode != NM_Standalone)
		bTickVisibleOnly = False;

	super.tick(deltatime);
	
	if (TNMPAM!=none)
		TNMPAM.activateaugs();
		
	if (bPlatformer)
	{
		NewVect = Location;
		NewVect.Y = yAxis;
		SetLocation(NewVect);
	}
	
	if (bPendingAugOnSound)
	{
		PlaySound(Sound'DeusExSounds.Augmentation.AugActivate', SLOT_None);
		bPendingAugOnSound=False;
	}
	if (bPendingAugOffSound)
	{
		PlaySound(Sound'DeusExSounds.Augmentation.AugDeactivate', SLOT_None);
		bPendingAugOffSound=False;
	}
	
	if (bMotionBlur)
	{
		blurTime += deltaTime;
	
		if (blurTime > blurPeriod)
		{
			if (VSize(Velocity) > 300)
			{
				blur = Spawn(class'MotionBlurEffect',,, Location);
				if (blur != None)
				{
					blur.Mesh = Mesh;
					blur.AnimFrame = AnimFrame;
					// blur.AnimRate = 0;
					blur.AnimSequence = AnimSequence;
					blur.bAnimLoop=True;
					blur.Skin = Skin;
					blur.Texture = Texture;
					blur.Fatness = Fatness;
					for(i = 0; i < 8; i++)
					{
						blur.MultiSkins[i] = MultiSkins[i];
					}
					// Glasses
					if (Mesh == LodMesh'DeusExCharacters.GM_Suit' || Mesh == LodMesh'DeusExCharacters.GM_DressShirt_B' || Mesh == LodMesh'DeusExCharacters.GM_Jumpsuit' || IsA('UberAlles'))
						blur.MultiSkins[5] = Texture'BlackMaskTex';
					else if (Mesh == LodMesh'DeusExCharacters.GFM_TShirtPants')
						blur.MultiSkins[3] = Texture'BlackMaskTex';
					else
						blur.MultiSkins[6] = Texture'BlackMaskTex';
						
					blur.OrigGlow = ScaleGlow;
				}
			}
			
			blurTime = 0;
		}
	}
}

state Conversation
{
	function Tick(float deltaTime)
	{
		Super.Tick(deltaTime);
		
		if (Pawn(ConversationActor) != None)
			lookAtTarget = Pawn(ConversationActor);
	}
}

state FirstPersonConversation
{
	function Tick(float deltaTime)
	{
		Super.Tick(deltaTime);
		
		if (Pawn(ConversationActor) != None)
			lookAtTarget = Pawn(ConversationActor);
	}
}




// ----------------------------------------------------------------------
// state Guarding
//
// Stand at a guard point for a length of time before returning to old orders.
// ----------------------------------------------------------------------

State Guarding
{
	function SetFall()
	{
		StartFalling('Patrolling', 'ContinuePatrol');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Global.HitWall(HitNormal, Wall);
		CheckOpenDoor(HitNormal, Wall);
	}

	function AnimEnd()
	{
		PlayWaiting();
	}

	function RevGuardPoint PickStartPoint()
	{
		local NavigationPoint nav;
		local RevGuardPoint     curNav;
		local float           curDist;
		local RevGuardPoint     closestNav;
		local float           closestDist;

		closestNav  = None;
		if (guardRadius >= 0)
			closestDist = guardRadius;
		else
			closestDist = 1800; // Max distance

		foreach AllActors(class'RevGuardPoint', curNav)
		{
			if (curNav.currentGuard == None)
			{
				curDist = VSize(Location - curNav.Location);
				curDist /= curNav.weightMultiplier;
				if (closestDist > curDist)
				{
					closestDist = curDist;
					closestNav = curNav;
				}
			}
		}
		/*
		nav = Level.NavigationPointList;
		while (nav != None)
		{
			nav.visitedWeight = 0;
			nav = nav.nextNavigationPoint;
		}

		closestNav  = None;
		closestDist = 100000;
		nav = Level.NavigationPointList;
		while (nav != None)
		{
			curNav = PatrolPoint(nav);
			if (curNav != None && curNav.Tag == OrderTag)
			{
				while (curNav != None)
				{
					if (curNav.visitedWeight != 0)  // been here before
						break;
					curDist = VSize(Location - curNav.Location);
					if (closestNav == None || closestDist > curDist)
					{
						closestNav  = curNav;
						closestDist = curDist;
					}
					curNav.visitedWeight = 1;
					curNav = curNav.NextPatrolPoint;
				}
			}
			nav = nav.nextNavigationPoint;
		}*/

		return (closestNav);
	}

	function PickDestination()
	{
		local RevGuardPoint aPoint;
		
		destPoint = PickStartPoint();
		if (destPoint == None)  // can't go anywhere...
			GotoState('Guarding', 'Done');
		else
		{
			foreach AllActors(class'RevGuardPoint', aPoint)
			{
				if (aPoint.currentGuard == Self)
					aPoint.currentGuard = None;
			}
			RevGuardPoint(destPoint).currentGuard = Self; // Reserve this spot as ours
		}
	}

	function BeginState()
	{
		StandUp();
		SetEnemy(None, EnemyLastSeen, true);
		Disable('AnimEnd');
		SetupWeapon(false);
		SetDistress(false);
		bStasis = false;
		SeekPawn = None;
		EnableCheckDestLoc(false);
	}

	function EndState()
	{
		EnableCheckDestLoc(false);
		Enable('AnimEnd');
		bStasis = true;
	}

	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);

		LipSynchBarks(deltaTime);
	}

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
			// HX_HAN: Experimental workaround for runaway loop with Teleportes and PatrolPoints.
			if ( MoveTarget==None )
			{
				if (ShouldPlayWalk(destPoint.Location))
					PlayRunning();
				MoveToward(destPoint, MaxDesiredSpeed);	
			}
			else
			{
				while (MoveTarget != None)
				{
					if (ShouldPlayWalk(MoveTarget.Location))
						PlayRunning();
					MoveToward(MoveTarget, MaxDesiredSpeed);
					CheckDestLoc(MoveTarget.Location, true);
					if (MoveTarget == destPoint)
						break;
					MoveTarget = FindPathToward(destPoint);
				}
			}
			EnableCheckDestLoc(false);
		}
	}
	else
		Goto('Patrol');

Pausing:
	if (!bAlwaysPatrol)
		bStasis = true;
	Acceleration = vect(0, 0, 0);
	bKeepWeaponDrawn = true;
	SetupWeapon(true);

	// Turn in the direction dictated by the WanderPoint, or a random direction
	if (RevGuardPoint(destPoint) != None)
	{
		RevGuardPoint(destPoint).currentGuard = Self;
		if (RevGuardPoint(destPoint).pausetime > 0)
		{
			if (ShouldPlayTurn(Location + RevGuardPoint(destPoint).lookdir))
				PlayTurning();
			TurnTo(Location + RevGuardPoint(destPoint).lookdir);
			Enable('AnimEnd');
			TweenToWaiting(0.2);
			PlayScanningSound();
			//Enable('Bump');
			sleepTime = RevGuardPoint(destPoint).pausetime * ((-0.9*restlessness) + 1);
			Sleep(sleepTime);
			remainingSleepTime = sleepTime;
			while (remainingSleepTime > 0)
			{
				Sleep(Min(10, remainingSleepTime));
				remainingSleepTime -= Min(10, remainingSleepTime);
				if (bCanTurnHead)
				{
					if (FRand() < 0.5)
					{
						if (!bSeekLocation)
						{
							PlayTurnHead(LOOK_Left, 1.0, 1.0);
							Sleep(1.0);
							remainingSleepTime -= 1.00;
						}
						if (!bSeekLocation)
						{
							PlayTurnHead(LOOK_Forward, 1.0, 1.0);
							Sleep(0.5);
							remainingSleepTime -= 0.50;
						}
						if (!bSeekLocation)
						{
							PlayTurnHead(LOOK_Right, 1.0, 1.0);
							Sleep(1.0);
							remainingSleepTime -= 1.00;
						}
					}
					else
					{
						if (!bSeekLocation)
						{
							PlayTurnHead(LOOK_Right, 1.0, 1.0);
							Sleep(1.0);
							remainingSleepTime -= 1.00;
						}
						if (!bSeekLocation)
						{
							PlayTurnHead(LOOK_Forward, 1.0, 1.0);
							Sleep(0.5);
							remainingSleepTime -= 0.50;
						}
						if (!bSeekLocation)
						{
							PlayTurnHead(LOOK_Left, 1.0, 1.0);
							Sleep(1.0);
							remainingSleepTime -= 1.00;
						}
					}
					PlayTurnHead(LOOK_Forward, 1.0, 1.0);
					Sleep(0.5);
					remainingSleepTime -= 0.50;
					StopBlendAnims();
				}
			}
			Disable('AnimEnd');
			//Disable('Bump');
			FinishAnim();
		}
	}
	Goto('Done');

ContinuePatrol:
ContinueFromDoor:
	FinishAnim();
	PlayWalking();
	Goto('Moving');
	
Done:
	if (RevGuardPoint(destPoint) != None)
		RevGuardPoint(destPoint).currentGuard = None;
	if (Orders != 'Guarding')
		FollowOrders();
	else
		GotoState('Wandering');
}

//WCCC, 3/24/19: Use this function to simulate all the uggo that comes with TakeDamage in our stunned states. Yuck.
function bool ProxyTakeDamage(out int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, out name DamageType)
{
	local bool Ret;
	local int TotalFat; //needed to avoid integer overflow for fatness calculation
	local TNMAugmentation TNMA;
	
	if (DamageType == 'Uberexploded')
		DamageType = 'exploded';
	
	if(DamageType == 'FistStunned' && !IsA('TNMAnimal'))
		Damage = 1;
	
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
	
	if (DamageType == 'Fat')
	{
		if (!bInvincible)
		{
			if (Damage > 0)
			{
				if (bAugmented && (TNMPAM != none))
				{
					TNMA = TNMPAM.FindAug(class'TNMAugShield');
					if ((TNMA != none) && (TNMA.bIsActive))
					{
						Damage = Damage * TNMA.Value;
						AugDamage(0, InstigatedBy, HitLocation, Momentum, DamageType);
					}
				}
				
				//WCCC, 3/24/19: Funny story. Fat isn't scaled by stun/rear headshots.
				//This is really awkward when people die of phat rifle to the head. Scale it halfway now.
				//Use shot to circumvent giving fat damage increased lethality as well.
				TotalFat = (Damage + ModifyDamage(Damage, InstigatedBy, HitLocation, (HitLocation - Location) << Rotation, 'Shot'));
				TotalFat = Fatness + (TotalFat / 2);
				if (TotalFat > 255)
				{
					Takedamage(10000, InstigatedBy, HitLocation, Momentum, 'exploded');
					if (Trestkon(InstigatedBy) != None)
						Trestkon(InstigatedBy).SetAchievement("achPHAT");
				}
				else
				{
					//WCCC, 3/24/19: Not proud of it, but it works with the damage type and context. Piss.
					bTempFatFlag = True;
					TakeDamage(1, InstigatedBy, HitLocation, Momentum, 'shot');
					bTempFatFlag = False;
					Fatness = TotalFat;
				}
			}
		}
		Ret = True;
	}
	else if ((DamageType == 'gibbed') && (!bImmuneToGib))
	{
		TakeDamage(10000, InstigatedBy, HitLocation, Momentum, 'exploded');
		Ret = True;
	}
	else if (DamageType == 'nogib')
	{
		Health = 0;
		TakeDamage(1, InstigatedBy, HitLocation, Momentum, 'shot');
		Ret = True;
	}
	else if (DamageType == 'FistEMP')
	{
		TakeDamage(Damage*2.5, InstigatedBy, HitLocation, Momentum, 'EMP');
		TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, 'KnockedOut');
		Ret = True;
	}
	else
	{
		if ((bAugmented) && (TNMPAM != none))
			AugDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
		else
			EMPDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
	}
	
	if (Health <= 0)
	{
		if (TNMPAM != none)
		{
			TNMPAM.DeactivateAll();
			TNMPAM.Destroy();
			TNMPAM = None;
			Ret = True;
		}
	}
	else if ((bAugmented) && (TNMPAM != none) && (Health <= AugHealthLimit))
			TNMPAM.ActivateAugs(True, False);	//Health,Combat
			
	return ret;
}

//WCCC, 3/24/19: Double check this, since TakeDamage is ran differently. Weird.
function ProxyAugDeathCheck()
{
	if (Health <= 0)
	{
		if (TNMPAM != none)
		{
			TNMPAM.DeactivateAll();
			TNMPAM.Destroy();
			TNMPAM = None;
		}
	}
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
{
	local int totalFat; //needed to avoid integer overflow for fatness calculation
	local tnmaugmentation TNMA;	
	local int i, j;
	local Fragment frag;

	if (damagetype == 'Uberexploded')
		damagetype = 'exploded';

	if(DamageType == 'FistStunned' && !IsA('TNMAnimal'))
		Damage = 1;
	
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
		
	if (damagetype == 'Fat')
	{
		if (!binvincible)
		{
			if (damage > 0)
			{
				if (baugmented && (TNMPAM != none))
				{
					TNMA = TNMPAM.findaug(class'tnmAugShield');
					if ((TNMA != none) && (TNMA.bisactive))
					{
						damage = damage * TNMA.value;
						augdamage(0,instigatedby,hitlocation,momentum,damagetype);
					}
				}
				
				//WCCC, 3/24/19: Funny story. Fat isn't scaled by stun/rear headshots. Scale it halfway now.
				//This is really awkward when people die of phat rifle to the head. Scale it halfway now.
				//Use shot to circumvent giving fat damage increased lethality as well.
				TotalFat = (Damage + ModifyDamage(Damage, InstigatedBy, HitLocation, (HitLocation - Location) << Rotation, 'Shot'));
				TotalFat = Fatness + (TotalFat / 2);
				if (TotalFat > 255)
				{
					Takedamage(10000, InstigatedBy, HitLocation, Momentum, 'exploded');
					if (Trestkon(InstigatedBy) != None)
						Trestkon(InstigatedBy).SetAchievement("achPHAT");
				}
				else
				{
					//WCCC, 3/24/19: Not proud of it, but it works with the damage type and context. Piss.
					bTempFatFlag = True;
					takedamage(1,instigatedby, hitlocation, momentum, 'shot');
					bTempFatFlag = False;
					fatness = totalfat;
				}
			}
		}
	}
	else if (damagetype == 'gibbed')
	{
		if (!bimmunetogib)
			takedamage(10000,instigatedby,hitlocation,momentum,'exploded');
	}
	else if (damagetype == 'nogib')
	{
		health = 0;
		takedamage(1,instigatedby,hitlocation,momentum,'shot');
	}
	else if (damagetype == 'FistEMP')
	{
		takedamage(damage*2.5,instigatedby,hitlocation,momentum,'EMP');
		takedamage(damage,instigatedby,hitlocation,momentum,'KnockedOut');
	}
	else
	{
		if (baugmented && (TNMPAM != none))
			augdamage(damage,instigatedby,hitlocation,momentum,damagetype);
		else
			empdamage(damage,instigatedby,hitlocation,momentum,damagetype);
	}


	if (health <=0)
	{
		if (TNMPAM != none)
		{
			TNMPAM.deactivateall();
			TNMPAM.destroy();
			TNMPAM = none;
		}
		
		if (bMirrorPawn)
		{
			// spawn some fragments and make a sound
			j = 10;
			for (i=0; i<j; i++)
			{
				frag = Spawn(Class'DeusEx.GlassFragment',,, Location + 16 * VRand());
				if (frag != None)
				{
					frag.Instigator = Self;

					// make the last fragment just drop down so we have something to attach the sound to
					if (i == j - 1)
						frag.Velocity = vect(0,0,0);
					else
						frag.CalcVelocity(VRand(), 16);

					// frag.DrawScale = FragmentScale;
					// if (FragmentTexture != None)
						// frag.Skin = FragmentTexture;
					// if (bFragmentTranslucent)
						frag.Style = STY_Translucent;
					// if (bFragmentUnlit)
						// frag.bUnlit = True;
				}
			}
			Destroy();
		}
	}
	else if (baugmented && (TNMPAM != none) && (health <= aughealthlimit))
		TNMPAM.activateaugs(true,false);	//health,combat
}

function empdamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
	super.takedamage(damage,instigatedby,hitlocation,momentum,damagetype);
	
	if (damagetype == 'emp')
	{
		if(baugmented)
		{
			energy -= damage;
			if (energy <= 0)
				TNMPAM.deactivateall();
		}
		if (bfirewall)
		{
			if (health <= 0)
			{
				if (Trestkon(instigatedBy) != None)
					Trestkon(instigatedBy).SetAchievement("achFirewall");
				firewallexplosion();
			}
		}
	}
}

function float ModifyDamage(int Damage, Pawn instigatedBy, Vector hitLocation,
							Vector offset, Name damageType)
{
	local int   actualDamage;
	local float headOffsetZ, headOffsetY, armOffset;

	actualDamage = Damage;

	// calculate our hit extents
	headOffsetZ = CollisionHeight * 0.7;
	headOffsetY = CollisionRadius * 0.3;
	armOffset   = CollisionRadius * 0.35;// if the pawn is stunned, damage is 4X
	/*if (bStunned)
		actualDamage *= 4;

	// if the pawn is hit from behind at point-blank range, he is killed instantly
	else if (offset.x < 0)
		if ((instigatedBy != None) && (VSize(instigatedBy.Location - Location) < 64))
			actualDamage  *= 10;*/
			
	if (offset.x < 0 && instigatedBy != None && TNMWeapon(instigatedBy.Weapon) != None && TNMWeapon(instigatedBy.Weapon).Attribute == Att_Assassin)
		actualDamage *= 2;
	else if (offset.x > 0 && instigatedBy != None && TNMWeapon(instigatedBy.Weapon) != None && TNMWeapon(instigatedBy.Weapon).Attribute == Att_Valiant)
		actualDamage *= 2;
	else if (offset.Z < headOffsetZ && instigatedBy != None && TNMWeapon(instigatedBy.Weapon) != None && TNMWeapon(instigatedBy.Weapon).Attribute == Att_Ruthless)
		actualDamage *= 2;
	else if (DeusExPlayer(instigatedBy) != None && TNMWeapon(instigatedBy.Weapon) != None && TNMWeapon(instigatedBy.Weapon).Attribute == Att_Focused && (DeusExPlayer(instigatedBy).bIsCrouching || DeusExPlayer(instigatedBy).bForceDuck))
		actualDamage *= 2;
			
	if (((damageType == 'EMP') && !bfirewall) || damageType != 'EMP')
	{
		//G-Flex: now you get point-blank attack bonus if enemy is stunned 
		//G-Flex: sneak attack bonus now *7.0 instead of *10
		//G-Flex: knockout weapons e.g. baton work better in these situations, baton does its old default damage
		//G-Flex: don't do sneak attack/stun bonus damage for explosions, poison, etc. (some handled below this)
		if (((damageType != 'Exploded') && (damageType != 'PoisonGas') && (damageType != 'HalonGas') &&
			(damageType != 'Radiation') && (damageType != 'Poison') && (damageType != 'fell') && (damageType != 'Stomped') && (damageType != 'PoisonEffect')) && (!bTempFatFlag) && (DamageType != 'Fat'))
		{
			if (((instigatedBy != None) && (VSize(instigatedBy.Location - Location) < 96)) && ((bStunned) || (offset.x < 0)))
			{
				actualDamage *= 7.0;
				if (damageType == 'KnockedOut')
					actualDamage *= 1.400;
			}
			//G-Flex: smaller damage boost to other damage while stunned since they can't properly defend
			else if (bStunned)
				actualDamage *= 2.0;
			//G-Flex: half bonus for flamethrowers and such
			//G-Flex: sneak attacking with a flamethrower is a little silly after all
			if (damageType == 'Flamed')
				actualdamage = (actualDamage + (2*Damage)) / 3.000;
		}
		// if the pawn is hit from behind at point-blank range, he is killed instantly
		else if (offset.x < 0)
			if ((instigatedBy != None) && (VSize(instigatedBy.Location - Location) < 64) && (!bTempFatFlag) && (DamageType != 'Fat'))
				actualDamage  *= 10;
	}

	actualDamage = Level.Game.ReduceDamage(actualDamage, DamageType, self, instigatedBy);
	
	if (bLegendary)
	{
		// actualDamage *= 0.8;
		actualDamage = actualDamage / ((Loge(LegendaryCount)+1.5) * 1.1);
		if (Damage > 0 && actualDamage <= 0)
			actualDamage = 1;
	}	

	if (ReducedDamageType == 'All') //God mode
		actualDamage = 0;
	else if (Inventory != None) //then check if carrying armor
		actualDamage = Inventory.ReduceDamage(actualDamage, DamageType, HitLocation);

	// gas, EMP and nanovirus do no damage
	if (damageType == 'TearGas' || damageType == 'NanoVirus')
		actualDamage = 0;
	if ((damageType == 'EMP') && !bfirewall)
		actualdamage = 0;

	return actualDamage;

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

	if (damageType == 'EMP')
	{
		return ((bfirewall) || (baugmented));
	}

	return true;

}


// ----------------------------------------------------------------------
// ShouldReactToInjuryType()
// ----------------------------------------------------------------------

function bool ShouldReactToInjuryType(name damageType,
									  bool bHatePrimary, bool bHateSecondary)
{
	local bool bIsPrimary;

	bIsPrimary = IsPrimaryDamageType(damageType);
	if ((bHatePrimary && bIsPrimary)||(bHateSecondary && !bIsPrimary))
		return true;
	else
		return false;
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
		case 'EMP':
			bPrimary = bFirewall || bAugmented;
			break;
		case 'FistStunned':
		case 'Stunned':
		case 'KnockedOut':
		case 'Burned':
		case 'Flamed':
		case 'Poison':
		case 'Shot':
		case 'Sabot':
		case 'Fat':
		default:
			bPrimary = true;
			break;
	}

	return (bPrimary);
}

function firewallexplosion()
{
	gotostate('firewalldeath');//place holder. for now!!!
}

function augdamage( int damage, pawn instigatedby, vector hitlocation, vector momentum, name damagetype)
{
	local int newdamage;
	local tnmaugmentation TNMA;

	newdamage = damage;

	if ((damageType == 'Shot') || (damageType == 'AutoShot') || (damageType == 'Sabot'))
	{
		TNMA = TNMPAM.findaug(class'tnmAugBallistic');
		if ((TNMA != none) && (TNMA.bisactive))
		{
			newDamage *= TNMA.value;
			Spawn(Class'BallisticShieldFX',Self);
		}
	}

	else if (damageType == 'EMP')
	{

		TNMA = TNMPAM.findaug(class'tnmAugEMP');
		if ((TNMA != none) && (TNMA.bisactive))
		{
			newDamage *= TNMA.value;
			Spawn(Class'EMPShieldFX',Self);
		}
	}

	else if ((damageType == 'Burned') || (damageType == 'Flamed') ||
		(damageType == 'Exploded') || (damageType == 'Shocked') ||
		(damageType == 'Fat'))
	{
		TNMA = TNMPAM.findaug(class'tnmAugShield');
		if ((TNMA != none) && (TNMA.bisactive))
		{
			newDamage *= TNMA.value;
			Spawn(Class'EnergyShieldFX',Self);
		}
	}
	else if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'Radiation') ||
		(damageType == 'HalonGas')  || (damageType == 'PoisonEffect') || (damageType == 'Poison'))
	{
		TNMA = TNMPAM.findaug(class'tnmAugEnviro');
		if ((TNMA != none) && (TNMA.bisactive))
		{
			newDamage *= TNMA.value;
			
			//WCCC, 3/16/19: Fix for enviro NPC's being immune to halon gas that would extinguish them.
			//Weird fix, but okay.
			if ((damageType == 'HalonGas') && (bOnFire)) 
				ExtinguishFire();
			
			if((damageType=='TearGas'||damageType=='HalonGas') && newdamage==0)
				damageType='PoisonGas'; //don't rub your eyes!
			Spawn(Class'EnviroShieldFX',Self);
		}
	}

//	if (bDrawShield && damage > newdamage)
//		drawshield();

	if ((newdamage < 1) && (newdamage > 0))
		newdamage = 1;

	empdamage(newdamage,instigatedby,hitlocation,momentum,damagetype);
}


State Attacking
{
	function BeginState()
	{
		// Only get detected if they've been attacking for half a second, give the player a breathing period.
		if (EnemyTimer > 0.5)
			PlayerDetected(GetStateName());

		if (baugmented && (TNMPAM != none))
			TNMPAM.activateaugs(false,true);	//health,combat

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
		if (baugmented && (TNMPAM != none))
			TNMPAM.DeactivateAll();
		//TNMPAM.activateaugs(false,false);	//health,combat
		//NOT WORKING? Worked out why. Goes into fleeing if doesn't have weapon.
		//Don't really need to have fleeing since it's a fair assumption that anyone
		//with a combat activated aug will have a weapon but it's probably best to be sure.

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
	
	function CheckAttack(bool bPlaySound)
	{
		local bool bCriticalDamage;
		local bool bOutOfAmmo;
		local Pawn oldEnemy;
		local bool bAllianceSwitch;
		local Weapon aWeapon;
		local int i;
		local class<actor> aDroneClass;
		local vector loc;
		local tnmaugmentation TNMA;
		local SphereEffect sphere;
		local inventory inv;
		local bool bWeaponFound;
		
		// Super.CheckAttack(bPlaySound);
		
		oldEnemy = enemy;

		bAllianceSwitch = false;
		if (!IsValidEnemy(enemy))
		{
			if (IsValidEnemy(Enemy, False) && (Robot(Enemy) == None || !Robot(Enemy).IsInState('Disabled')))
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
			if (Orders != 'Attacking')
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
			else if (Weapon.AmmoType.IsA('AmmoNapalmL') && Weapon.AmmoType.AmmoAmount < 2)	// Specifically requires at least 2
				bOutOfAmmo = True;
			else if (Weapon.AmmoType.AmmoAmount < 1)
				bOutOfAmmo = True;
		}
		else if (Weapon.AmmoName == Class'AmmoNone') // Transcended - Added
			PlayOutOfAmmoSound();
			
		if (bOutOfAmmo)
		{
			if (bCanUseFists)
			{
				for ( inv = Inventory; inv != None; inv = inv.Inventory)
				{
					if (Weapon(inv) != None && ((Weapon(inv).AmmoName != None && Weapon(inv).AmmoName != Class'AmmoNone') || (Weapon(inv).AmmoType != None && Weapon(inv).AmmoType.AmmoAmount >= 1)))
						bWeaponFound = True;
				}
				
				if (!bWeaponFound)
				{
					aWeapon = spawn(class'TNM.WeaponFists', Self);

					if (aWeapon != None)
					{
						aWeapon.InitialState='Idle2';
						aWeapon.GiveTo(Self);
						aWeapon.SetBase(Self);
						SetWeapon(aWeapon);
						bOutOfAmmo = False;
						PlayOutOfAmmoSound();
					}					
				}
			}
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
		
		if (TNMPAM != None)
		{
			TNMA = TNMPAM.findaug(class'tnmAugDrone');
			
			if (Enemy != None && Energy > 0 && droneTimer <= 0 && TNMA != None)
			{
				aDroneClass = class<Actor>(DynamicLoadObject(droneClass, class'Class'));
				loc = (2.0 + class'SpyDrone'.Default.CollisionRadius + CollisionRadius) * Vector(Rotation);
				loc.Z = BaseEyeHeight;
				loc += Location;
				if (aDroneClass != None)
					aDrone = ScriptedPawn(Spawn(aDroneClass,self,,loc));
				if (aDrone != None)
				{
					PlayAnimPivot('Attack');
					aDrone.SetAlliance(Alliance);
					for (i=0; i<ArrayCount(AlliancesEx); i++)
						if (AlliancesEx[i].AllianceName != '')
							if (AlliancesEx[i].AllianceLevel >= 0)
								aDrone.ChangeAlly(AlliancesEx[i].AllianceName, AlliancesEx[i].AgitationLevel * -1, AlliancesEx[i].bPermanent);
							else							
								aDrone.ChangeAlly(AlliancesEx[i].AllianceName, AlliancesEx[i].AllianceLevel, AlliancesEx[i].bPermanent);
					aDrone.SetEnemy(Enemy);
					droneTimer = droneRespawnTime;
					// draw some light effects
					Spawn(class'ExplosionLight',,, aDrone.Location);
					sphere = Spawn(class'SphereEffect',,, aDrone.Location);
					if (sphere != None)
						sphere.size = 1.0;
				}
			}
		}
	}
	
	function Tick(float deltaTime)
	{
		Super.Tick(deltaTime);
		
		droneTimer -= deltaTime;
		
		if (droneTimer < 0)
			droneTimer = 0;
	
		LipSynchBarks(deltaTime);
	}
}

State Fleeing
{
	function BeginState()
	{
		PlayerDetected(GetStateName());
		StandUp();
		Disable('AnimEnd');
		//Disable('Bump');
		BlockReactions();
		if (!bCower)
			bCanConverse = False;
		bStasis = False;
		SetupWeapon(false, true);
		SetDistress(true);
		EnemyReadiness = 1.0;
		//ReactionLevel  = 1.0;
		SeekPawn = None;
		EnableCheckDestLoc(false);
		// if (baugmented && (TNMPAM != none) && (health <= aughealthlimit))
			// TNMPAM.activateaugs(true,true);	//health,combat
		// else if (bAugmented && TNMPAM != None)
			// TNMPAM.activateaugs(false,true);	//health,combat
	}

	function EndState()
	{
		EnableCheckDestLoc(false);
		Enable('AnimEnd');
		//Enable('Bump');
		ResetReactions();
		if (!bCower)
			bCanConverse = True;
		bStasis = True;
		ResetBasedPawnSize(); //in case the cowering gets interupted
	}

	function FinishFleeing()
	{
		if (bLeaveAfterFleeing || !bRestoreOrders)
			GotoState('Wandering');
		else
			FollowOrders();
	}
}

// ----------------------------------------------------------------------
// PlayFootStep()
//
// Plays footstep sounds based on the texture group
// (yes, I know this looks nasty -- I'll have to figure out a cleaner way to do this)
// ----------------------------------------------------------------------

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

				case 'Landscape': //ie snow

		//				if (bWalkingOnSnow)				    
		//				{
						SpawnFootprint();

						//I wish there were some way to import sounds into an array so I
						//could do this as an iteration :(
						if (rnd < 0.1)
							stepSound = Sound'snowstep1';
						else if (rnd < 0.2)
							stepSound = Sound'snowstep2';
						else if (rnd < 0.3)
							stepSound = Sound'snowstep3';
						else if (rnd < 0.4)
							stepSound = Sound'snowstep4';
						else if (rnd < 0.5)
							stepSound = Sound'snowstep5';
						else if (rnd < 0.6)
							stepSound = Sound'snowstep6';
						else if (rnd < 0.7)
							stepSound = Sound'snowstep7';
						else if (rnd < 0.8)
							stepSound = Sound'snowstep8';
						else if (rnd < 0.9)
							stepSound = Sound'snowstep9';
						else
							stepSound = Sound'snowstep10';
		//				}
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
	
	if (bruhSound != None)
		stepSound = bruhSound;
	
	// play the sound and send an AI event
	PlaySound(stepSound, SLOT_Interact, volume * stealthmodifier, , PlayRange, pitch);
	AISendEvent('LoudNoise', EAITYPE_Audio, volume*volumeMultiplier * stealthmodifier, range*volumeMultiplier);
	
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


// ----------------------------------------------------------------------
// ComputeActorVisibility()
// ----------------------------------------------------------------------

function float ComputeActorVisibility(actor seeActor)
{
	local deusexplayer player;
	player = deusexplayer(seeactor);

	if (RespawnInfo(seeActor) != None)
		return 0.0;
	if (Robot(seeActor) != None && seeActor.IsInState('Disabled'))
		return 0.0;
	if (bvisionactive)
		return 1.0;
	else
		return super.computeactorvisibility(seeactor);
}


function ZoneChange(ZoneInfo newZone)
{
	if (!bInWorld)
		return;

	if(!Newzone.bWaterZone && bVisibleBreath && breathgen == none)
	{
		spawnBreathgen();
	}
	else if((newzone.bWaterZone || !bVisibleBreath) && breathgen != none)
	{
		breathgen.DelayedDestroy();
	}
	
	// if (newZone.bWaterZone)
		// SetBasedPawnSize(Default.CollisionRadius, Default.CollisionHeight * 0.65);
	// else if (Region.Zone.bWaterZone && !newZone.bWaterZone)
		// ResetBasedPawnSize();
	
	if (newZone != None && MelkZone(newZone) != None)
		StopPoison();

	super.ZoneChange(newzone);
}

function HeadZoneChange(ZoneInfo newZone)
{
	if (!bInWorld)
		return;

	if(!Newzone.bWaterZone && bVisibleBreath && breathgen == none)
	{
		spawnBreathgen();
	}
	else if((newzone.bWaterZone || !bVisibleBreath) && breathgen != none)
	{
		breathgen.DelayedDestroy();
	}
	super.HeadZoneChange(newzone);
}

function vector getBreathOffset()
{
	local vector loc;

	if(bIsFemale)
	{
		loc.X += CollisionRadius * 0.15;
		loc.Z += BaseEyeHeight*0.9;
	}
	else if (IsA('SnowWolf') || IsA('Wolfy'))
	{
		loc.X += collisionradius * 0.9;
		loc.Z += BaseEyeHeight*0.91;
	}
	else if (IsA('TNMAnimal') || IsA('SD'))
	{
		loc.X += collisionradius;
		loc.Z += BaseEyeHeight*0.91;
	}
	else if (IsA('Despot'))
	{
		loc.X += collisionradius * 0.95;
		loc.Z += BaseEyeHeight*0.91;
	}
	else
	{
		loc.X += collisionradius * 0.5;
		loc.Z += BaseEyeHeight*0.91;
	}
	if (IsInState('Crouching'))
	{
		loc.X += CollisionRadius * 0.5;
		loc.Z -= CollisionHeight * 0.15;
	}
	loc = loc >> rotation;
	loc += location;
	return loc;
}

function spawnbreathgen()
{
	local vector loc;

	loc = getBreathOffset();

	breathgen = spawn(Class'particlegenerator',self,,loc,rotation);
	if(breathgen != none)
	{
		breathgen.particleTexture=texture'effects.smoke.smokepuff1';
		breathgen.checkTime = 0.1;
		breathgen.riseRate = 3.0;
		breathgen.ejectSpeed = 12.5 * DrawScale;
		breathgen.bRandomEject = true;
		breathgen.particleLifeSpan = 0.5;
		breathgen.SetBase(self);
		breathgen.particleDrawScale = 0.1 * DrawScale * breathSize;
	}
	if(AnimSequence == 'BreatheLight' || AnimSequence == 'BreatheLight2H' || AnimSequence == 'SitBreathe')
	{
		//about halfway through is full inhale
		breathtimer = breathtime * animframe;
	}
	else
		breathtimer = frand() * breathtime;
}

function updatebreathgen(float dt)
{
	local float mod;
	local int temp;
	local vector loc;

	loc = getBreathOffset();

	breathgen.SetLocation(loc);
	breathgen.setrotation(rotation);

	if(IsInState('Dying'))
	{
		breathgen.UnTrigger(self,self);
		return;
	}

	if(IsInState('StunnedTemporal'))
	{
		breathgen.UnTrigger(self,self);
		return;
	}

	breathtimer += dt;

	if(breathtimer > breathtime)
		breathtimer = 0.0;

	if((breathtimer < breathtime * 0.5 || breathtimer > breathtime * 0.9) && breathgen.bSpewing && !bIsSpeaking)
	{
		breathgen.UnTrigger(self,self);
	}
	else
	{
		if(breathtimer < breathtime * 0.75)
		{
			mod = (breathtimer - (breathtime * 0.5))/(breathtime * 0.25);
		}
		else
		{
			mod = (breathtime - breathtimer)/(breathtime * 0.15);
		}
		if(mod < 0 && !bIsSpeaking)
		{
			breathgen.UnTrigger(self,self);
			mod = 0;
		}
		else
		{
			if(!breathgen.bSpewing)
				breathgen.Trigger(self,self);
			// breathgen.ejectSpeed = (12.5 * mod) + ((VSize(Velocity)) + 1); // Looks better without bRandomEject
			breathgen.ejectSpeed = 12.5 * Abs(mod);
		}
	}
}

// ----------------------------------------------------------------------
// PlayAnimPivot()
// ----------------------------------------------------------------------

function PlayAnimPivot(name Sequence, optional float Rate, optional float TweenTime,
					   optional vector NewPrePivot)
{
	local bool bAdjustBreath;

	if (Rate == 0)
	{
		if(sequence == 'BreatheLight' || sequence == 'BreatheLight2H' || sequence == 'SitBreathe')
			bAdjustBreath = true;

		Rate = 1.0;
	}
	if (TweenTime == 0)
		TweenTime = 0.1;
	if (HasAnim(Sequence))
		PlayAnim(Sequence, Rate, TweenTime);
	if(bAdjustbreath && breathgen != none)
		breathtimer = breathtime * animframe;  //synch up breathing
	PrePivotTime    = TweenTime;
	DesiredPrePivot = NewPrePivot + PrePivotOffset;
	if (PrePivotTime <= 0)
		PrePivot = DesiredPrePivot;
}

// ----------------------------------------------------------------------
// TweenAnimPivot()
// ----------------------------------------------------------------------

function TweenAnimPivot(name Sequence, float TweenTime,
						optional vector NewPrePivot)
{
	if (TweenTime == 0)
		TweenTime = 0.1;
	if (HasAnim(Sequence))
		TweenAnim(Sequence, TweenTime);
	if(breathgen != none && (sequence == 'BreatheLight' || sequence == 'BreatheLight2H' || sequence == 'SitBreathe'))
 		breathtimer = breathtime * animframe;  //synch up breathing
	PrePivotTime    = TweenTime;
	DesiredPrePivot = NewPrePivot + PrePivotOffset;
	if (PrePivotTime <= 0)
		PrePivot = DesiredPrePivot;
}


// ----------------------------------------------------------------------
// LoopAnimPivot()
// ----------------------------------------------------------------------

function LoopAnimPivot(name Sequence, optional float Rate, optional float TweenTime, optional float MinRate,
					   optional vector NewPrePivot)
{
	local bool bAdjustBreath;

	if (Rate == 0)
	{
		if(sequence == 'BreatheLight' || sequence == 'BreatheLight2H' || sequence == 'SitBreathe')
			bAdjustBreath = true;
		Rate = 1.0;
	}
	if (TweenTime == 0)
		TweenTime = 0.1;
	if (Mesh != None && HasAnim(Sequence))
		LoopAnim(Sequence, Rate, TweenTime, MinRate);
	if(bAdjustbreath && breathgen != none)
		breathtimer = breathtime * animframe;  //synch up breathing
	PrePivotTime    = TweenTime;
	DesiredPrePivot = NewPrePivot + PrePivotOffset;
	if (PrePivotTime <= 0)
		PrePivot = DesiredPrePivot;
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
		
		LipSynchBarks(deltaTime);
	}

	function BeginState()
	{
		if(breathgen != none)
			breathgen.DelayedDestroy();

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
	Playfirewalldeathanims();
	Sleep(3);
	Frag(Rand(5)+5);
	for (i=0;i<8;i++)
		multiskins[i] = Texture(DynamicLoadObject("Extras.Matrix_A00", class'Texture'));
	DropItems();
	Sleep(2);
	bFading = true;
	KillShadow();
	bHasShadow = False;
	//fade
	Sleep(3);
	Destroy();
}


// ----------------------------------------------------------------------
// state Dying - copied
// ----------------------------------------------------------------------

state StunnedTaser
{
	ignores SeePlayer, EnemyNotVisible, HearNoise, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Timer, stopwaiting;

	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);
		
		LipSynchBarks(deltaTime);
	}

	function BeginState()
	{
		EnableCheckDestLoc(false);
		StandUp();

		bInterruptState = false;
		BlockReactions(true);
		bCanConverse = False;
		bStasis = False;
		SetDistress(true);
		// DeathTimer = 0;
	}

	function EndState()
	{
		EnableCheckDestLoc(false);
		bInterruptState = true;
		ResetReactions();
		bCanConverse = True;
		bStasis = False;
		SetDistress(true);
		// DeathTimer = 0;
	}

Begin:
	Acceleration = vect(0, 0, 0);
	Playfirewalldeathanims();
	Sleep(3);
	// if (Trestkon(Instigator) != None)
		Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players
	TakeDamage(200, Instigator, Location, vect(0,0,0), 'Stunned');
	GotoNextState();
}

function Playfirewalldeathanims()
{
	if (HasAnim('Shocked'))
		LoopAnimPivot('Shocked');
/*
	FinishAnim();
	PlayAnim('HitTorso', 2.0, 0.1);
	FinishAnim();
	PlayAnim('HitHead', 2.0, 0.1);
	FinishAnim();
	PlayAnim('HitTorsoBack', 2.0, 0.1);
	FinishAnim();
	PlayAnim('HitHeadBack', 2.0, 0.1);
	FinishAnim();
	PlayAnim('HitHead', 3.0, 0.1);
	FinishAnim();
	PlayAnim('HitHeadBack', 3.0, 0.1);
	FinishAnim();
	PlayAnim('HitHead', 5.0, 0.1);
	FinishAnim();
	PlayAnim('HitHeadBack', 5.0, 0.1);
	FinishAnim();
*/
}



function Explode(optional vector HitLocation)
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
		s.DrawScale = FClamp(explosionRadius/76.8, 0.1, 3.0);
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


// ----------------------------------------------------------------------
// state Dying - copied
// ----------------------------------------------------------------------

state AlphaFirewallDeath
{
	ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, Timer, TakeDamage;

	function BeginState()
	{
		if(breathgen != none)
			breathgen.DelayedDestroy();

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
	Sleep(3);
	Acceleration = vect(0, 0, 0);
	FinishAnim();
	for (i=0;i<3;i++)
	{
		PlayAnim('HitTorso', 2.0, 0.1);
		FinishAnim();
		PlayAnim('HitHead', 2.0, 0.1);
		FinishAnim();
		PlayAnim('HitTorsoBack', 2.0, 0.1);
		FinishAnim();
		PlayAnim('HitHeadBack', 2.0, 0.1);
		FinishAnim();
		PlayAnim('HitHead', 3.0, 0.1);
		FinishAnim();
		PlayAnim('HitHeadBack', 3.0, 0.1);
		FinishAnim();
		PlayAnim('HitTorsoBack', 5.0, 0.1);
		FinishAnim();
		PlayAnim('HitHeadBack', 5.0, 0.1);
		FinishAnim();
	}
	// Sleep(3);
	Frag(Rand(5)+5);
	for (i=0;i<8;i++)
		multiskins[i] = Texture(DynamicLoadObject("Extras.Matrix_A00", class'Texture'));
	DropItems();
	FinishAnim();
	while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))
	{
		PlayAnim('HitTorso', 2.0, 0.1);
		FinishAnim();
		PlayAnim('HitHead', 2.0, 0.1);
		FinishAnim();
		PlayAnim('HitTorsoBack', 2.0, 0.1);
		FinishAnim();
		PlayAnim('HitHeadBack', 2.0, 0.1);
		FinishAnim();
		PlayAnim('HitHead', 3.0, 0.1);
		FinishAnim();
		PlayAnim('HitHeadBack', 3.0, 0.1);
		FinishAnim();
		PlayAnim('HitHead', 5.0, 0.1);
		FinishAnim();
		PlayAnim('HitHeadBack', 5.0, 0.1);
		FinishAnim();
	}
	Explode();
	Destroy();	
}

// ----------------------------------------------------------------------
// state Dying - copied
// ----------------------------------------------------------------------

state AlphaFirewallDeathLong
{
	ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, Timer, TakeDamage;

	function BeginState()
	{
		if(breathgen != none)
			breathgen.DelayedDestroy();

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
	FinishAnim();
	PlayAnim('HitTorso', 2.0, 0.1);
	FinishAnim();
	PlayAnim('HitHead', 2.0, 0.1);
	FinishAnim();
	PlayAnim('HitTorsoBack', 2.0, 0.1);
	FinishAnim();
	PlayAnim('HitHeadBack', 2.0, 0.1);
	FinishAnim();
	PlayAnim('HitHead', 3.0, 0.1);
	FinishAnim();
	PlayAnim('HitHeadBack', 3.0, 0.1);
	FinishAnim();
	PlayAnim('HitHead', 5.0, 0.1);
	FinishAnim();
	PlayAnim('HitHeadBack', 5.0, 0.1);
	FinishAnim();
	PlayAnim('HitTorso', 2.0, 0.1);
	FinishAnim();
	PlayAnim('HitHead', 2.0, 0.1);
	FinishAnim();
	PlayAnim('HitTorsoBack', 2.0, 0.1);
	FinishAnim();
	PlayAnim('HitHeadBack', 2.0, 0.1);
	FinishAnim();
	PlayAnim('HitHead', 3.0, 0.1);
	FinishAnim();
	PlayAnim('HitHeadBack', 3.0, 0.1);
	FinishAnim();
	PlayAnim('HitHead', 5.0, 0.1);
	FinishAnim();
	PlayAnim('HitHeadBack', 5.0, 0.1);
	FinishAnim();
	// Sleep(3);
	Frag(Rand(5)+5);
	for (i=0;i<8;i++)
		multiskins[i] = Texture(DynamicLoadObject("Extras.Matrix_A00", class'Texture'));
	DropItems();
	while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))
	{
		switch (Rand(4))
		{
			case 0:
				PlayAnim('HitTorso', 2.0+firewallDeathAnimSpeed, 0.1);
				FinishAnim();
				break;
			case 1:
				PlayAnim('HitHead', 2.0+firewallDeathAnimSpeed, 0.1);
				FinishAnim();
				break;
			case 2:
				PlayAnim('HitTorsoBack', 2.0+firewallDeathAnimSpeed, 0.1);
				FinishAnim();
				break;
			case 3:
				PlayAnim('HitHeadBack', 2.0+firewallDeathAnimSpeed, 0.1);
				FinishAnim();
				break;
		}
		firewallDeathAnimSpeed += 0.2;
	}
	Explode();
	Destroy();
}

//=======================================================================//
//Alarm AI                                                               //
//=======================================================================//

function cameraalarm()
{
if (bAlarmSecurity)
	ALARM(AR_SecurityAlert);
}

function ALARM(EAlarmReason reason)
{
	//debug output
//	switch ( reason )
//	{
//		case AR_None: 	trestkon(GetPlayerPawn()).DebugMessage("Pawn triggering alarm because: AR_None"); break;
//		case AR_FoundCarcass: 	trestkon(GetPlayerPawn()).DebugMessage("Pawn triggering alarm because: AR_FoundCarcass"); break;
//		case AR_DisabledBot: 	trestkon(GetPlayerPawn()).DebugMessage("Pawn triggering alarm because: AR_DisabledBot"); break;
//		case AR_SecurityAlert: 	trestkon(GetPlayerPawn()).DebugMessage("Pawn triggering alarm because: AR_SecurityAlert"); break;
//		case AR_Fire: 	trestkon(GetPlayerPawn()).DebugMessage("Pawn triggering alarm because: AR_Fire"); break;
//		case AR_LostPlayer: 	trestkon(GetPlayerPawn()).DebugMessage("Pawn triggering alarm because: AR_LostPlayer"); break;
//		case AR_KilledPlayer: 	trestkon(GetPlayerPawn()).DebugMessage("Pawn triggering alarm because: AR_KilledPlayer"); break;
//	}

	if (IsValidEnemy(Enemy) || IsValidEnemy(SeekPawn) || IsValidEnemy(localPlayer) || IsValidEnemy(GetPlayerPawn())) //thanks Chris Rosenkreutz
	{
		alarmreason = reason;
		SetOrders('Alerting');
	}
}

//horrible way of doing it but the function gets called at the perfect time so it's
// better than copying the whole seeking state
//need give up search as well!!
function PlayAreaSecureSound()
{
	local DeusExPlayer dxPlayer;

	// Should we do a player check here?

	dxPlayer = DeusExPlayer(Enemy);
	if (dxPlayer == None)
		dxPlayer = DeusExPlayer(GetPlayerPawn());
	if ((dxPlayer != None) && (Enemy == dxPlayer))
	{
		dxPlayer.StartAIBarkConversation(self, BM_AreaSecure);
		if(bAlarmKilledPlayer)
			ALARM(AR_KilledPlayer);
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

	function Tick(float deltaTime)
	{
		animTimer[1] += deltaTime;
		Global.Tick(deltaTime);
		UpdateActorVisibility(Enemy, deltaTime, 1.0, true);
		LipSynchBarks(deltaTime);
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
			bVisualContactSeeking = True;
			
			SetSeekLocation(pawnSighted, pawnSighted.Location, SEEKTYPE_Sight);
			destLoc = LastSeenPos;
			if (bInterruptSeek)
				GotoState('Seeking', 'GoToLocation');
		}
	}

	function BeginState()
	{
		PlayerDetected(GetStateName());
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
		//Reset this for obvious reasons.
		bVisualContactSeeking = false;
		
		EnableCheckDestLoc(false);
		Enable('AnimEnd');
		ResetReactions();
		bCanConverse = True;
		bStasis = True;
		StopBlendAnims();
		if (NextLabel != 'ContinueFromDoor' && NextState != 'Seeking') // Don't stop while falling or opening doors
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
//will have to change this somewhat.
	if (bSeekPostCombat)
	{
		// if (bAlarmLostPlayer) // ZP hated this
			// ALARM(AR_LostPlayer);
		PlayTargetLostSound();
	}
	else
	{
		// if ((bAlarmLostPlayer) && (bVisualContactSeeking)) // ZP hated this
			// ALARM(AR_LostPlayer);
		PlaySearchGiveUpSound();
	}
	if (SeekType == SEEKTYPE_Carcass)
		if(bAlarmCarcass)
			ALARM(AR_FoundCarcass);

	bSeekPostCombat = false;
	SeekPawn = None;
	if (bShouldGuardPoints && FRand() <= guardChance)
	{
		GoToState('Guarding');
	}
	else
	{
		if (Orders != 'Seeking')
			FollowOrders();
		else
			restoreorders(); // this could be an improvement on the old code? GotoState('Wandering');
	}

ContinueSeek:
ContinueFromDoor:
	FinishAnim();
	Goto('FindAnotherPlace');

}

state GoingTo
{
	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);

		LipSynchBarks(deltaTime);
	}	
}

state RunningTo
{
	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);

		LipSynchBarks(deltaTime);
	}	
}


State RunPatrolling extends Patrolling
{
	function float GetWalkingSpeed()
	{
		// if (Physics == PHYS_Swimming)
			return MaxDesiredSpeed;
		// else
			// return WalkingSpeed;
	}

	function PlayWalking()
	{
		PlayRunning();
	}
}

state Following
{
	function Tick(float deltaTime)
	{
		Super.Tick(deltaTime);
		
		LipSynchBarks(deltaTime);
	}
}

//copied from state Following

state Formation
{
	function SetFall()
	{
		StartFalling('Formation', 'ContinueFollow');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Global.HitWall(HitNormal, Wall);
		CheckOpenDoor(HitNormal, Wall);
	}

	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);
		
		LipSynchBarks(deltaTime);

		if (BackpedalTimer >= 0)
			BackpedalTimer += deltaTime;

		animTimer[1] += deltaTime;
		if ((Physics == PHYS_Walking) && (orderActor != None))
		{
			if (Acceleration == vect(0,0,0))
				LookAtActor(orderActor, true, true, true, 0, 0.25);
			else
				PlayTurnHead(LOOK_Forward, 1.0, 0.25);
		}
	}

	function PickDestination()
	{
		local float   dist;
		local int     dir;
		local rotator rot;

		if ( orderActor != none )
		{
			destLoc   = vect(0, 0, 0);
			rot = rot(0,0,0);

			rot.Yaw=(65536+formationDesiredYaw+orderActor.Rotation.Yaw-formationInitialYaw)%65536;
			destLoc = OrderActor.Location+Vector(rot/*+OrderActor.Rotation*/)*formationDesiredDistance;
			dist = VSize(Location-destLoc);
			if (dist > 75)
			{
				MoveTarget = FindPathTo(destLoc);
				if (MoveTarget != None)
					destPoint = MoveTarget;
			}
			else
			{
				if ( destPoint != none )
					destPoint.SetLocation(destLoc);
			}
		}
		BackpedalTimer = -1;
	}

	function BeginState()
	{
		StandUp();
		bStasis = False;
		SetupWeapon(false);
		SetDistress(false);
		BackpedalTimer = -1;
		SeekPawn = None;
		EnableCheckDestLoc(true);
	}

	function EndState()
	{
		EnableCheckDestLoc(false);
		bAcceptBump = False;
		bStasis = True;
		StopBlendAnims();
	}

	function FindLeader()
	{
		local TNMPawn p;
		OrderActor = none;
		foreach AllActors(Class'TNMPawn', p)
		{
			if(p.Orders == 'Patrolling' && p.OrderTag == formationPatrolTag)
			{
//				deusexplayer(GetPlayerPawn()).DebugMessage("Got One");
				OrderActor = p;
				return;
			}
		}
	}

	function FindController()
	{
/*		local FormationController fc;
		foreach (Allactors(class'FormationController', c, OrderTag)
		{
			formationController = fc;
			break;
		}
*/
	}


Begin:
	FindController();

	if(formationDesiredDistance==0)
	{
		if (orderActor == None)
			GotoState('Standing');
		formationDesiredDistance=VSize(Location-OrderActor.Location);
		formationDesiredYaw=Rotator(Location-OrderActor.Location).Yaw;
		formationInitialYaw=OrderActor.Rotation.Yaw;
		formationPatrolTag=ScriptedPawn(OrderActor).OrderTag;
		Acceleration = vect(0, 0, 0);
		destPoint = None;
	}

GetFormation:
	if(OrderActor==None || !ScriptedPawn(OrderActor).IsInState('Patrolling'))
	{
		sleep(FRand()*3.0);
		FindLeader();
		if(OrderActor == None)
		{
			Orders='Patrolling';
			OrderTag=formationPatrolTag;
			GotoState('Patrolling');
		}
	}
	PickDestination();

Follow:
	if (destPoint != None && !IsPointInCylinder(self, destLoc, 16-CollisionRadius))
	{
		EnableCheckDestLoc(true);
		MoveTarget = FindPathToward(destPoint);
		if(VSize(Location-destLoc)<250)
		{
			if(ShouldPlayWalk(destLoc))
				PlayWalking();
			MoveTo(destLoc, GetWalkingSpeed());
		}
		else
		{
			PlayRunning();
			MoveTo(destLoc, MaxDesiredSpeed);
		}

		CheckDestLoc(destLoc, true);
		EnableCheckDestLoc(false);
	}

Wait:
	//PlayTurning();
	//TurnToward(orderActor);
	PlayWaiting();

WaitLoop:
	Acceleration=vect(0,0,0);
	Sleep(0.0);
	Goto('GetFormation');

ContinueFollow:
ContinueFromDoor:
	Acceleration=vect(0,0,0);
	Goto('GetFormation');

}

// ----------------------------------------------------------------------
// state Alerting
//
// Warn other NPCs that an enemy is about
// ----------------------------------------------------------------------

State Alerting
{
	function SetFall()
	{
		StartFalling('Alerting', 'ContinueAlert');
	}

	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);
		
		LipSynchBarks(deltaTime);
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Global.HitWall(HitNormal, Wall);
		CheckOpenDoor(HitNormal, Wall);
	}

	function Bump(actor bumper)
	{
		if (bAcceptBump)
		{
			if (bumper == AlarmActor)
			{
				bAcceptBump = False;
				GotoState('Alerting', 'SoundAlarm');
			}
		}

		// Handle conversations, if need be
		Global.Bump(bumper);
	}

	function bool IsAlarmReady(Actor actorAlarm)
	{
		local bool      bReady;
		local AlarmUnit alarm;

		bReady = false;
		alarm = AlarmUnit(actorAlarm);
		if ((alarm != None) && !alarm.bDeleteMe)
			if (!alarm.bActive)
				if ((alarm.associatedPawn == None) ||
				    (alarm.associatedPawn == self))
					bReady = true;

		return bReady;
	}

	function TriggerAlarm()
	{
		if ((AlarmActor != None) && !AlarmActor.bDeleteMe)
		{
			if (AlarmActor.hackStrength > 0)  // make sure the alarm hasn't been hacked
				AlarmActor.Trigger(self, Enemy);
		}
	}

	function bool IsAlarmInRange(AlarmUnit alarm)
	{
		local bool bInRange;

		bInRange = false;
		if ((alarm != None) && !alarm.bDeleteMe)
			if ((VSize((alarm.Location-Location)*vect(1,1,0)) <
			     (CollisionRadius+alarm.CollisionRadius+24)) &&
			    (Abs(alarm.Location.Z-Location.Z) < (CollisionHeight+alarm.CollisionHeight)))
				bInRange = true;

		return (bInRange);
	}

	function vector FindAlarmPosition(Actor alarm)
	{
		local vector alarmPos;

		alarmPos = alarm.Location;
		alarmPos += vector(alarm.Rotation.Yaw*rot(0,1,0))*(CollisionRadius+alarm.CollisionRadius);

		return (alarmPos);
	}

	function bool GetNextAlarmPoint(AlarmUnit alarm)
	{
		local vector alarmPoint;
		local bool   bValid;

		destPoint = None;
		destLoc   = vect(0,0,0);
		bValid    = false;

		if ((alarm != None) && !alarm.bDeleteMe)
		{
			alarmPoint = FindAlarmPosition(alarm);
			if (PointReachable(alarmPoint))
			{
				destLoc = alarmPoint;
				bValid = true;
			}
			else
			{
				MoveTarget = FindPathTo(alarmPoint);
				if (MoveTarget != None)
				{
					destPoint = MoveTarget;
					bValid = true;
				}
			}
		}

		return (bValid);
	}

	function AlarmUnit FindTarget()
	{
		local ScriptedPawn pawnAlly;
		local AlarmUnit    alarm;
		local float        dist;
		local AlarmUnit    bestAlarm;
		local float        bestDist;

		bestAlarm = None;

		// Do we have any allies on this level?
//		foreach AllActors(Class'ScriptedPawn', pawnAlly)
//			if (GetPawnAllianceType(pawnAlly) == ALLIANCE_Friendly)
//				break;

		// Yes, so look for an alarm box that isn't active...
//		if (pawnAlly != None)
//		{
			foreach RadiusActors(Class'AlarmUnit', alarm, 2400)
			{
				if (GetAllianceType(alarm.Alliance) != ALLIANCE_Hostile)
				{
					dist = VSize((Location-alarm.Location)*vect(1,1,2));  // use squished sphere
					if ((bestAlarm == None) || (dist < bestDist))
					{
						bestAlarm = alarm;
						bestDist  = dist;
					}
				}
			}


			// Is the nearest alarm already going off?  And can we reach it?
			if (!IsAlarmReady(bestAlarm) || !GetNextAlarmPoint(bestAlarm))
				bestAlarm = None;
//		}

		// Return our target alarm box
		return (bestAlarm);
	}

	function bool PickDestination()
	{
		local bool      bDest;
		local AlarmUnit alarm;

		// Init
		destPoint = None;
		destLoc   = vect(0, 0, 0);
		bDest     = false;

		// Find an alarm we can trigger
		alarm = FindTarget();
		if (alarm != None)
		{
			// Find a way to get there
			AlarmActor = alarm;
			alarm.associatedPawn = self;
			bDest = true;  // if alarm != none, we've already computed the route to the alarm
		}

		// Return TRUE if we were successful
		return (bDest);
	}

	function BeginState()
	{
		PlayerDetected(GetStateName());
		StandUp();
		//Disable('AnimEnd');
		bAcceptBump = False;
		bCanConverse = False;
		AlarmActor = None;
		bStasis = False;
		BlockReactions();
		SetupWeapon(false);
		SetDistress(false);
		EnemyReadiness = 1.0;
		ReactionLevel  = 1.0;
		EnableCheckDestLoc(false);
	}

	function EndState()
	{
		EnableCheckDestLoc(false);
		ResetReactions();
		bAcceptBump = False;
		//Enable('AnimEnd');
		bCanConverse = True;
		if (AlarmActor != None)
			if (AlarmActor.associatedPawn == self)
				AlarmActor.associatedPawn = None;
		AlarmActor = None;
		bStasis = True;
	}

Begin:
//	if ((Enemy == None) && (alarmreason == AR_none))
//		GotoState('Seeking');

	//EnemyLastSeen = 0;

	destPoint = None;

//	if ((RaiseAlarm == RAISEALARM_Never)&&(alarmreason ==AR_none))
//		GotoState('Fleeing');

	if (AlarmTimer > 0)
		PlayGoingForAlarmSound();

Alert:
	if (AlarmTimer > 0)
		Goto('Done');

	WaitForLanding();
	if (!PickDestination())
		Goto('Done');

Moving:
	// Can we go somewhere?
	bAcceptBump = True;
	EnableCheckDestLoc(true);
	while (true)
	{
		if (destPoint != None)
		{
			if (ShouldPlayWalk(MoveTarget.Location))
				PlayRunning();
			MoveToward(MoveTarget, MaxDesiredSpeed);
			CheckDestLoc(MoveTarget.Location, true);
		}
		else
		{
			if (ShouldPlayWalk(destLoc))
				PlayRunning();
			MoveTo(destLoc, MaxDesiredSpeed);
			CheckDestLoc(destLoc);
		}
		if (IsAlarmInRange(AlarmActor))
			break;
		else if (!GetNextAlarmPoint(AlarmActor))
			break;
	}
	EnableCheckDestLoc(false);

SoundAlarm:
	Acceleration=vect(0,0,0);
	bAcceptBump = False;
	if (IsAlarmInRange(AlarmActor))
	{
		TurnToward(AlarmActor);
		PlayPushing();
		FinishAnim();
		TriggerAlarm();
	}

Done:
	bAcceptBump = False;

	switch( alarmreason )
	{
		case AR_foundCarcass:
		case AR_DisabledBot:
		case AR_securityAlert:
		case AR_fire:
		case AR_lostplayer:
		case AR_killedplayer:
			alarmreason = AR_None;
			restoreorders();
			break;
		case AR_None:
		default:
			alarmreason = AR_None; //not sure if this needs to go before every gotostate or not and I'm too lazy to find out.
			if (RaiseAlarm == RAISEALARM_BeforeAttacking)
				GotoState('Attacking');
			else
				GotoState('Fleeing');
			break;
	};
ContinueAlert:
ContinueFromDoor:
	Goto('Alert');

}

state Shadowing
{
	function Tick(float deltaTime)
	{
		local bool  bMove;
		local float deltaValue;

		Global.Tick(deltaTime);

		LipSynchBarks(deltaTime);
		
		deltaValue = deltaTime;

		// If we're running, and we can see our target, STOP RUNNING!
		if (bRunningStealthy)
		{
			UpdateActorVisibility(orderActor, deltaValue, 0.0, false);
			deltaValue = 0;
			if (EnemyLastSeen <= 0)
			{
				bRunningStealthy = False;
				PlayWalking();
				DesiredSpeed = GetWalkingSpeed();
			}
		}

		// Are we stopped?
		if (bPausing)
		{
			// Can we see our target?
			bMove = False;
			UpdateActorVisibility(orderActor, deltaValue, 0.5, false);
			deltaValue = 0;

			// No -- move toward him!
			if (EnemyLastSeen > 0.5)
				bMove = True;

			// We can see him, and we're staring...
			else if (bStaring)
			{
				// ...can he see us staring at him?
				if ((Pawn(orderActor) != None) &&
				    (Pawn(orderActor).AICanSee(self, , false, true, false, false) > 0))
					bMove = True;  // Time to look inconspicuous
			}

			// Move if we need to
			if (bMove)
			{
				if (bStaring)
					GotoState('Shadowing', 'StopStaring');
				else
					GotoState('Shadowing', 'StopPausing');
				bPausing = False;
				bStaring = False;
			}
		}
	}

}

// ----------------------------------------------------------------------
// CheckCarcassPresence()
// ----------------------------------------------------------------------

function bool CheckCarcassPresence(float deltaTime)
{

	local DeusExDecoration deco;
	local TNMRobot bot;
	local float         maxDecoDist;
	local int superfluousinteger;
	local float visibility;

	if(isinstate('alerting'))
		return false; //I don't even know why this function is a bool

	maxDecoDist = 1200;
	if (CarcassCheckTimer <= 0)
	{
		/* huge slowdown
		deco = none;
		foreach CycleActors(Class'deusexdecoration', deco, superfluousinteger)
		{
			if (deco.Physics != PHYS_Falling)
			{
				if (VSize(deco.Location-Location) < maxDecoDist)
				{
					if(deco.IsInState('Burning'))
					{
						visibility = AICanSee(deco, ComputeActorVisibility(deco), true, true, true, true);
						if (visibility > 0)
							if(bAlarmFire)
								ALARM(AR_Fire);
					}
				}
			}
		}
		*/
		if (bLookingForCarcass)
		{
			bot = none;
			foreach CycleActors(Class'TNMRobot', bot, superfluousinteger)
			{
				if (bot.Physics != PHYS_Falling)
				{
					if (VSize(bot.Location-Location) < maxDecoDist)
					{
						if(bot.IsInState('Disabled') && bot.EMPHitPoints <= 0)
						{
							if (GetAllianceType(bot.alliance) == ALLIANCE_Friendly )
							{
								visibility = AICanSee(bot, ComputeActorVisibility(bot), true, true, true, true);
								if (visibility > 0)
									if(bAlarmBot)
										ALARM(AR_foundcarcass); //AR_DisabledBot);
							}
						}
					}
				}
			}
		}
	}
	if (Level.NetMode != NM_Standalone)
		CoopCheckCarcassPresence(deltaTime);
	else
		super.CheckCarcassPresence(deltaTime);
}

// ----------------------------------------------------------------------
// Co-op: stock CheckCarcassPresence with every player instead of the host.
// It only looked at GetPlayerPawn() for a player carrying a body (which is
// also how trespassing is detected, see GetCarcassData), and blamed
// GetPlayerPawn() for anything the 'Player' alliance did. A client could
// trespass unnoticed, and a host trespass was pinned on the host.
// ----------------------------------------------------------------------

function CoopCheckCarcassPresence(float deltaSeconds)
{
	local Actor         carcass;
	local Name          CarcassName;
	local int           lastCycle;
	local DeusExCarcass body;
	local Pawn          P;
	local DeusExPlayer  player;
	local float         visibility;
	local Name          KillerAlliance;
	local Name          killedAlliance;
	local Name          tmpKiller, tmpKilled, tmpName;
	local Pawn          killer;
	local Pawn          bestKiller;
	local float         dist;
	local float         bestDist;
	local float         maxCarcassDist;
	local int           maxCarcassCount;

	if (bFearCarcass && !bHateCarcass && !bReactCarcass)  // Major hack!
		maxCarcassCount = 1;
	else
		maxCarcassCount = ArrayCount(Carcasses);

	if ((bHateCarcass || bReactCarcass || bFearCarcass) && (NumCarcasses < maxCarcassCount))
	{
		maxCarcassDist = 1200;
		if (CarcassCheckTimer <= 0)
		{
			CarcassCheckTimer = 0.1;
			carcass           = None;
			lastCycle         = BodyIndex;
			foreach CycleActors(Class'DeusExCarcass', body, BodyIndex)
			{
				if (body.Physics != PHYS_Falling)
				{
					if (VSize(body.Location-Location) < maxCarcassDist)
					{
						if (GetCarcassData(body, KillerAlliance, killedAlliance, CarcassName, true))
						{
							visibility = AICanSee(body, ComputeActorVisibility(body), true, true, true, true);
							if (visibility > 0)
								carcass = body;
							break;
						}
					}
				}
			}
			if (lastCycle >= BodyIndex)
			{
				if (carcass == None)
				{
					// stock: GetPlayerPawn() only. Take the nearest player seen.
					bestDist = 0;
					foreach RadiusActors(Class'DeusExPlayer', player, maxCarcassDist)
					{
						P = player;
						dist = VSize(P.Location-Location);
						if ((carcass != None) && (dist >= bestDist))
							continue;
						if (GetCarcassData(P, tmpKiller, tmpKilled, tmpName, true))
						{
							visibility = AICanSee(P, ComputeActorVisibility(P), true, true, true, true);
							if (visibility > 0)
							{
								carcass        = P;
								bestDist       = dist;
								KillerAlliance = tmpKiller;
								killedAlliance = tmpKilled;
								CarcassName    = tmpName;
							}
						}
					}
				}
			}
			if (carcass != None)
			{
				CarcassTimer = 120;
				AddCarcass(CarcassName);
				if (bLookingForCarcass)
				{
					if (KillerAlliance == 'Player')
					{
						// the player seen (trespassing or carrying a body), else
						// the player nearest the body; stock: GetPlayerPawn()
						if (DeusExPlayer(carcass) != None)
							killer = Pawn(carcass);
						else
							killer = CoopPlayerFor(carcass);
					}
					else
					{
						bestKiller = None;
						bestDist   = 0;
						foreach AllActors(Class'Pawn', killer)  // hack
						{
							if (killer.Alliance == KillerAlliance)
							{
								dist = VSize(killer.Location - Location);
								if ((bestKiller == None) || (bestDist > dist))
								{
									bestKiller = killer;
									bestDist   = dist;
								}
							}
						}
						killer = bestKiller;
					}
					if (bHateCarcass)
					{
						PotentialEnemyAlliance = KillerAlliance;
						PotentialEnemyTimer    = 15.0;
						bNoNegativeAlliances   = false;
					}
					if (bFearCarcass)
						IncreaseFear(killer, 2.0);

					if (bFearCarcass && IsFearful() && !IsValidEnemy(killer))
					{
						SetDistressTimer();
						SetEnemy(killer, , true);
						GotoState('Fleeing');
					}
					else
					{
						SetDistressTimer();
						SetSeekLocation(killer, carcass.Location, SEEKTYPE_Carcass);
						HandleEnemy();
					}
				}
			}
		}
	}
}

// Co-op: is P a player this NPC objects to because of where they are?
function bool CoopIsTrespasser(Pawn P)
{
	return bHateBreakAndEnter && (Trestkon(P) != None) && Trestkon(P).bBreakAndEnter;
}

// Co-op: any player currently trespassing in this NPC's eyes.
function bool CoopAnyTrespasser()
{
	local Pawn P;

	if (!bHateBreakAndEnter)
		return False;
	for (P = Level.PawnList; P != None; P = P.NextPawn)
		if (CoopIsTrespasser(P))
			return True;
	return False;
}

function restoreorders()
{
	if ( bRestoreOrders )
	{
		orders = originalorders;
		ordertag = originalordertag;
		FollowOrders();
	}
	else
	{
		GotoState('Wandering');
	}
}


function PreBeginPlay()
{
	local bool bAlreadyAdded;
	local Pawn Pawn;
		
	if ( bRestoreOrders )
	{
		originalOrders = orders;
		originalOrderTag = ordertag;
	}

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
	
		//Skip Pawn's and ScriptedPawn's PreBeginPlay and do Actor's directly since we are overriding.
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

// Smoke39 - implementing new on-fire effect
function CatchFire()
{
	local Fire f;
	local int i;
	local vector loc;
	local TNMAugmentation TNMA;

	if (bOnFire || Region.Zone.bWaterZone || (BurnPeriod <= 0) || bInvincible)
		return;	
		
	// Don't catch fire if using shield aug, like vanilla.
	if (bAugmented && (TNMPAM != none))
	{
		TNMPAM.ActivateAugs(False,True);
		TNMA = TNMPAM.FindAug(class'TNMAugShield');
		if ((TNMA != none) && (TNMA.bIsActive))
			return;
	}

	bOnFire = True;
	burnTimer = 0;

	EnableCloak(false);
	// big ugly block replaced with this line
	Spawn(class'TNMFire', self);
	SetTimer(1.0, True);
}

// // do not extinguish fire on death
// function UpdateFire()
// {
	// HealthTorso -= 5;
	// GenerateTotalHealth();
	// if (Health <= 0)
	// {
		// TakeDamage(10, None, Location, vect(0,0,0), 'Burned');
// //		ExtinguishFire();
	// }
// }

function UpdateFire()
{
	// continually burn and do damage
	if (IsA('Robot'))
	{
		//HealthTorso -= 1;
		if (Burner != None)
			TakeDamage(1, Burner, Location, vect(0,0,0), 'Burned');
		else
			TakeDamage(1, None, Location, vect(0,0,0), 'Burned');
	}
	else
	{
		//HealthTorso -= 5;
		if (Burner != None)
			TakeDamage(3, Burner, Location, vect(0,0,0), 'Burned');
		else
			TakeDamage(3, None, Location, vect(0,0,0), 'Burned');
	}
	// GenerateTotalHealth();
	if (Health <= 0)
	{
		if (Burner != None)
			TakeDamage(10, Burner, Location, vect(0,0,0), 'Burned');
		else
			TakeDamage(10, None, Location, vect(0,0,0), 'Burned');
		if (BurnerWeapon != None && !bDeathCounted)
			BurnerWeapon.numKills++;
		bDeathCounted = True;
		ExtinguishFire();
	}
}

function ExtinguishFire()
{
	local TNMFire f;

	bOnFire = False;
	burnTimer = 0;
	SetTimer(0, False);
	Burner = None;

	foreach BasedActors(class'TNMFire', f)
		f.Destroy();
}

function PlayDying(name damageType, vector hitLoc)
{
	local Vector X, Y, Z;
	local float dotp;
	
	StopBlendAnims();

	if (Region.Zone.bWaterZone)
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

	// don't scream if we are stunned
	if (bStunned)
	{	
		if (bIsFemale)
			PlaySound(Sound'FemaleUnconscious', SLOT_Pain,,,, RandomPitch());
		else
			PlaySound(Sound'MaleUnconscious', SLOT_Pain,,,, RandomPitch());
	}
	else
	{
		PlayDyingSound();
	}
}

// do not extinguish fire on death
function Died( pawn Killer, name damageType, vector HitLocation )
{
	local DeusExPlayer player;
	local name flagName;
	local string temp;
	local ScriptedPawn childPawn;
	local class<ScriptedPawn> aDroneClass;

	// Set a flag when NPCs die so we can possibly check it later
	player = DeusExPlayer(GetPlayerPawn());

//	ExtinguishFire();

	// set the instigator to be the killer
	Instigator = Killer;

	if (player != None)
	{
		// Abort any conversation we may have been having with the NPC
		if (bInConversation)
			player.AbortConversation();

		// Abort any barks we may have been playing
		if (player.BarkManager != None)
			player.BarkManager.ScriptedPawnDied(Self);
	}
	
	// Fuck it, 100% chance of Firewall death effect in these circumstances.
	if (bFirewall && damageType == 'EMP')
	{
		if (Trestkon(Killer) != None)
			Trestkon(Killer).SetAchievement("achFirewall");
		FirewallExplosion();
		return;
	}
	
	if (damagetype == 'Banned')
	{
		BanPawn();
		return;
	}

	//set bStunned ourselves so it can be read prior to Died
	//WCCC, 3/28/19: Patch for tear gas causing death. Thanks, 10 HP board guest.
	bStunned = ((damageType == 'Stunned' || damageType == 'StunnedTaser') || (damageType == 'KnockedOut') ||
	           (damageType == 'Poison') || (damageType == 'PoisonEffect') || (damageType == 'TearGas') || (damageType == 'FistStunned') || (damageType == 'headstun') || (damageType == 'FistEMP'));
	
	// Kill people who are on fire, since they keep burning
	if (bOnFire)
		bstunned = False;
	
	Super(Pawn).Died(Killer, damageType, HitLocation); 

	if (player != None)
	{
		if (Killer != None && Killer.IsA('TNMSpiderbot') && Killer.Owner != None && Trestkon(Killer.Owner) != None)
			Trestkon(player).SetAchievement("achSpider");
		
		if (bImportant)
		{
			if (bStunned)
				flagName = player.rootWindow.StringToName(BindName$"_Unconscious");
			else
				flagName = player.rootWindow.StringToName(BindName$"_Dead");

			player.flagBase.SetBool(flagName, True);
			// make sure the flag never expires
			player.flagBase.SetExpiration(flagName, FLAG_Bool, 0);
			
			if (Killer != None && Killer == Player && Trestkon(Player) != None && Trestkon(Player).irc_link != None && Trestkon(Player).bIRCImportantKillInfo)
			{
				temp = FamiliarName;
				temp = temp $ "!";
				if (!bStunned && HitLocation.z > Location.Z + (CollisionHeight * 0.7))
						temp = temp @ "(Headshot!)";
				if (bStunned)
					Trestkon(Player).irc_link.SendChannelAction(Trestkon(Player).irc_link.DefaultChannel,"knocked out"@temp);
				else
					Trestkon(Player).irc_link.SendChannelAction(Trestkon(Player).irc_link.DefaultChannel,"killed"@temp);
			}
		}
		
		if (Trestkon(Killer) != None)
		{
			if (Trestkon(Killer).InHand != None)
			{
				if (Trestkon(Killer).InHand.IsA('WeaponDaiKatana'))
					Trestkon(Killer).SetAchievement("achDaikatana");
				else if (Trestkon(Killer).InHand.IsA('WeaponHammer') || Trestkon(Killer).InHand.IsA('WeaponUniqueNVS') || Trestkon(Killer).InHand.IsA('WeaponScrewDriver') || Trestkon(Killer).InHand.IsA('WeaponWrench'))
					Trestkon(Killer).SetAchievement("achToolKill");
				else if (Trestkon(Killer).InHand.IsA('WeaponFists'))
					Trestkon(Killer).SetAchievement("achFists");
				if (Trestkon(Killer).InHand.IsA('WeaponUniqueNVS') && IsA('NVSHacker'))
					Trestkon(Killer).SetAchievement("achUniqueKill");
				else if (Trestkon(Killer).InHand.IsA('WeaponUniqueKylie') && IsA('Kylie'))
					Trestkon(Killer).SetAchievement("achUniqueKill");
				else if (Trestkon(Killer).InHand.IsA('WeaponUniqueZP') && (IsA('ZeroPresence') || IsA('ZeroPresenceNormal')))
					Trestkon(Killer).SetAchievement("achUniqueKill");
				else if (Trestkon(Killer).InHand.IsA('WeaponUniqueAO') && IsA('AlphaOperator'))
					Trestkon(Killer).SetAchievement("achUniqueKill");
				else if (Trestkon(Killer).InHand.IsA('WeaponKatanaSlicer') && IsA('Slicer'))
					Trestkon(Killer).SetAchievement("achUniqueKill");
			}
		}
		
		if (Killer != None && Killer == Player && Trestkon(Player) != None && Trestkon(Player).bQuadDamage)
			Health = -10000;
	}
	
	// Kill all summoned spydrones when dying
	if (bAugmented)
	{
		// aDroneClass = class<ScriptedPawn>(DynamicLoadObject(droneClass, class'ScriptedPawn'));
		// if (adroneClass != None)
		// {
			foreach AllActors(class'ScriptedPawn', childPawn)
			{
				if (childPawn.Owner == Self/* && childPawn.IsA(localPlayer.rootWindow.StringToName(DroneClass))*/)
				{
					if (Robot(childPawn) != None)
						childPawn.TakeDamage(Robot(childPawn).EMPHitPoints, childPawn, childPawn.Location, vect(0,0,0), 'EMP');
					else
						childPawn.TakeDamage(childPawn.Health, childPawn, childPawn.Location, vect(0,0,0), 'tantalus');
				}
			}
		// }
	}
}

function Carcass SpawnCarcass()
{
	local TNMCarcass carc;
	local TNMFire f;
	local Flame f2;
	local int i, j;
	local Fragment frag;
	local RespawnInfo RI;
	
	if (bMirrorPawn)
	{
		// spawn some fragments and make a sound
		j = 10;
		for (i=0; i<j; i++)
		{
			frag = Spawn(Class'DeusEx.GlassFragment',,, Location + 16 * VRand());
			if (frag != None)
			{
				frag.Instigator = Self;

				// make the last fragment just drop down so we have something to attach the sound to
				if (i == j - 1)
					frag.Velocity = vect(0,0,0);
				else
					frag.CalcVelocity(VRand(), 16);

				// frag.DrawScale = FragmentScale;
				// if (FragmentTexture != None)
					// frag.Skin = FragmentTexture;
				// if (bFragmentTranslucent)
					frag.Style = STY_Translucent;
				// if (bFragmentUnlit)
					// frag.bUnlit = True;
			}
		}
		return None;
	}

	carc = TNMCarcass(Super.SpawnCarcass()); //its assumed that the carcass will be a TNMCarcass

	if(carc==None) //gibbed
		DropItems();

	// transfer our fire to our carcass
	if ( carc != None )
	{
		foreach BasedActors(class'TNMFire', f)
		{
			if (carc.bDontTransferFlame)
				f.Destroy();
			else
			{
				f.SetOwner(carc);
				f.SetBase(carc);
				f.Mesh = carc.Mesh;
			}
		}

		//prevent some accesssed nones
		foreach AllActors(class'Flame', f2)
		{
			if(f2.Owner==Self)
			{
				if ( carc.bDontTransferFlame )
					f2.Destroy();
				else
					f2.SetOwner(carc);
			}
		}

		carc.bImportant = bImportant;
		carc.bEmitCarcass=bEmitCarcass;
		carc.DrawScale = DrawScale;
		// carc.SetCollisionSize(carc.CollisionRadius * carc.DrawScale, carc.CollisionHeight * carc.DrawScale);
		carc.Mass *= carc.DrawScale;
		carc.Fatness = Fatness;
		
		// For allying with WC, Athena has her own respawn mechanic, Treskton seems to crash the game, Kevo to grab his body to interrogation
		if (Trestkon(GetPlayerPawn()).bNightmareMode && !IsA('SD') && !IsA('Athena') && !IsA('Treskton') && !IsA('Kevo'))
			RI = Spawn(class'RespawnInfo',, Tag, Location, Rotation );
		if (RI != None)
		{
			RI.GoToState('Paralyzed');
			RI.associatedPawn = Class;
			RI.associatedCarcass = carc;
			carc.associatedRespawnInfo = RI;
			
			
			RI.Mesh = Mesh;
			RI.SetCollisionSize( CollisionRadius, CollisionHeight );
			RI.bCollideWorld = false;
			RI.SetLocation( Location );
			RI.SetRotation( Rotation );
			RI.bCollideWorld = bCollideWorld;
			
			RI.AmbientSound = AmbientSound;
			RI.SoundRadius  = SoundRadius;
			RI.SoundVolume  = SoundVolume;

			RI.SmellClass = SmellClass;
			RI.Tag = Tag;
			RI.Event = Event;

			RI.SightRadius = SightRadius;
			RI.PeripheralVision = PeripheralVision;
			RI.HearingThreshold = HearingThreshold;
			RI.AttitudeToPlayer = AttitudeToPlayer;
			RI.Intelligence = Intelligence;
			RI.AIHorizontalFov = AIHorizontalFov;
			RI.AspectRatio = AspectRatio;
			RI.AngularResolution = AngularResolution;
			RI.VisibilityThreshold = VisibilityThreshold;
			RI.SmellThreshold = SmellThreshold;
			RI.RandomWandering = RandomWandering;
			RI.bKeepWeaponDrawn = bKeepWeaponDrawn;
			RI.bShowPain = bShowPain;
			RI.bCanSit = bCanSit;
			RI.bAlwaysPatrol = bAlwaysPatrol;
			RI.bPlayIdle = bPlayIdle;
			RI.bLeaveAfterFleeing = bLeaveAfterFleeing;
			RI.bLikesNeutral = bLikesNeutral;
			RI.bUseFirstSeatOnly = bUseFirstSeatOnly;
			RI.bCower = bCower;
			RI.bEmitDistress = bEmitDistress;
			RI.RaiseAlarm = RaiseAlarm;
			RI.MaxProvocations = MaxProvocations;
			RI.EnemyTimeout = EnemyTimeout;
			RI.bHokeyPokey = bHokeyPokey;
			RI.bTickVisibleOnly = bTickVisibleOnly;
			RI.Skill = Skill;

			// var(Alliances)
			RI.Alliance = Alliance;

			for (i = 0; i< 8; i++)
			{
				RI.InitialAlliances[i].AllianceName = InitialAlliances[i].AllianceName;
				RI.InitialAlliances[i].AllianceLevel = InitialAlliances[i].AllianceLevel;
				RI.InitialAlliances[i].bPermanent = InitialAlliances[i].bPermanent;
				RI.MultiSkins[i] = MultiSkins[i];
			}

			// var(Combat) (some parts)
			RI.CombatStyle = CombatStyle;
			RI.bAvoidAim = bAvoidAim;
			RI.bDefendHome = bDefendHome;

			// var(Fears)
			RI.bFearHacking = bFearHacking;
			RI.bFearWeapon = bFearWeapon;
			RI.bFearShot = bFearShot;
			RI.bFearInjury = bFearInjury;
			RI.bFearIndirectInjury = bFearIndirectInjury;
			RI.bFearCarcass = bFearCarcass;
			RI.bFearDistress = bFearDistress;
			RI.bFearAlarm = bFearAlarm;
			RI.bFearProjectiles = bFearProjectiles;

			// copy InitialInventory
			for (i = 0; i < 8; i++)
			{
				// reset
				RI.InitialInventory[i].Inventory = None;
				RI.InitialInventory[i].Count = 0;

				RI.InitialInventory[i].Inventory	= InitialInventory[i].Inventory;
				RI.InitialInventory[i].Count		= InitialInventory[i].Count;
			}

			// var(Orders)
			RI.Orders = Orders;
			RI.OrderTag = OrderTag;
			RI.HomeTag = HomeTag;
			RI.HomeExtent = HomeExtent;
			RI.AlarmTag = AlarmTag;
			RI.SharedAlarmTag = SharedAlarmTag;
			RI.bFixedStart = bFixedStart;
			
			RI.ReducedDamageType = ReducedDamageType;
			RI.ReducedDamagePct = ReducedDamagePct;

			RI.bReactFutz = bReactFutz;
			RI.bReactPresence = bReactPresence;
			RI.bReactLoudNoise = bReactLoudNoise;
			RI.bReactAlarm = bReactAlarm;
			RI.bReactShot = bReactShot;
			RI.bReactCarcass = bReactCarcass;
			RI.bReactDistress = bReactDistress;
			RI.bReactProjectiles = bReactProjectiles;

			// var(ScriptedPawn) (some parts)
			RI.bImportant = bImportant;
			RI.bInvincible = bInvincible;
			RI.bInWorld = bInWorld;

			// var(Stimuli)
			RI.bHateHacking = bHateHacking;
			RI.bHateWeapon = bHateWeapon;
			RI.bHateShot = bHateShot;
			RI.bHateInjury = bHateInjury;
			RI.bHateIndirectInjury = bHateIndirectInjury;
			RI.bHateCarcass = bHateCarcass;
			RI.bHateDistress = bHateDistress;
			
			RI.BindName = BindName;
			RI.BarkBindName = BarkBindName;
			
			RI.Lifespan = RI.Default.Lifespan + Rand(11);
		}
	}
	if (carc != None && Region.Zone != None && Region.Zone.DamageType == 'Atmospheric')
	{
		carc.bAtmosphericDeath = True;
		carc.Mesh = carc.Mesh3;
	}

	return carc;
}

function DropItems()
{
	local bool bValidItem;
	local inventory item, nextItem;
	local Vector loc;

	if(inventory != none)
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

			if(!bValidItem)
				Item.Destroy();
			else
				class'TNMCarcass'.static.FlingItem(item, 300, loc);

			item = nextItem;
		}
		until (item == None)
	}
}

function SetWeapon(Weapon newWeapon)
{
	local Ammo PossibleAmmo;
	local int i;
	
	Super.SetWeapon(newWeapon);
	
	if (Weapon != None && Weapon.ReloadCount > 0 && DeusExWeapon(Weapon) != None)
	{
		//for (i=0; i<ArrayCount(DeusExWeapon(Weapon).AmmoNames); i++)
		for (i=(ArrayCount(DeusExWeapon(Weapon).AmmoNames) - 1); i > 0; i--)
		{
			if (DeusExWeapon(Weapon).AmmoNames[i] != None)
			{
				PossibleAmmo = Ammo(FindInventoryType(DeusExWeapon(Weapon).AmmoNames[i]));
				
				if (PossibleAmmo != None/* && !PossibleAmmo.IsA('Ammo20mm') && !PossibleAmmo.IsA('AmmoTNM20mm')*/)
				{
					if (PossibleAmmo.AmmoAmount > 0 && DeusExWeapon(Weapon).AmmoType != PossibleAmmo)
					{
						DeusExWeapon(Weapon).LoadAmmo(i);
						break;
					}
				}
			}
		}
	
		if (DeusExWeapon(Weapon).AmmoName != None && DeusExWeapon(Weapon).AmmoName.IsA('Ammo20mm') || DeusExWeapon(Weapon).AmmoName.IsA('AmmoTNM20mm'))
			DeusExWeapon(Weapon).bInstantHit = False;
		else if (DeusExWeapon(Weapon).AmmoName != None && DeusExWeapon(Weapon).AmmoName.IsA('Ammo762mm'))
			DeusExWeapon(Weapon).bInstantHit = DeusExWeapon(Weapon).Default.bInstantHit;
	}
}

// ----------------------------------------------------------------------
// IsProjectileDangerous()
// ----------------------------------------------------------------------

function bool IsProjectileDangerous(DeusExProjectile projectile)
{
	local bool bEvil;
	
	// Tracers never hurt
	if (Tracer(projectile) != None)
		return False;
	else if (SniperTracer(projectile) != None)
		return False;
	
	if (IgnoreDamageType(projectile.DamageType))
		return False;
	else if (!FilterDamageType(Self, Vect(0,0,0), Vect(0,0,0), Projectile.damageType))
		return False;
	// else if (ModifyDamage(Projectile.Damage, Self, Vect(0,0,0), Vect(0,0,0), Projectile.damageType) == 0.0)
		// return False;
	else if (ShieldDamage(projectile.damageType) <= 0.1)
		return False;
	
	if (projectile.IsA('Cloud'))
		bEvil = true;
	else if (projectile.IsA('ThrownProjectile'))
	{
		if (projectile.IsA('SpyBot'))
			bEvil = false;
		else if ((ThrownProjectile(projectile) != None) && (ThrownProjectile(projectile).bProximityTriggered))
		{
			bEvil = false;
		}
		else
			bEvil = true;
	}
	else
		bEvil = false;

	return (bEvil);

}

function bool IgnoreDamageType(Name damageType)
{
}

State Leaving
{
	function BeginState()
	{
		bTransient = False;
		bDisappear = True; //let's try to get LeaveWorld called instead
		GotoState('Patrolling');
	}

Begin:
	// shouldn't ever reach this point
}

function InitializeInventory()
{
	local int i;
	local flagbase flags;
	local trestkon t;
	local bool bCanUseSlugs, bHasSlugs, bFoundEmpty;
	local int buckshotSlot, buckshotCount;
	
	t=trestkon(getplayerpawn());
	flags=t.flagBase;
	for(i=0;i<8;i++)
	{
		if(initialinventory[i].inventory==none)
			break;
		if(flags.getbool(t.rootwindow.stringtoname("GOT_"$initialinventory[i].inventory.name)))
			initialinventory[i].inventory=class<tnmuniqueweapon>(initialinventory[i].inventory).default.genericVersion;
	}
	
	// 2009 support
	for(i=0;i<8;i++)
	{
		if(initialinventory[i].inventory != None && class<DeusExWeapon>(initialinventory[i].inventory) != None && class<DeusExWeapon>(initialinventory[i].inventory).Default.AmmoName.Default.Class.Name == 'AmmoSlug')
		{
			bCanUseSlugs = true;
			break;
		}
	}
	for(i=0;i<8;i++)
	{
		if(initialinventory[i].inventory != None && initialinventory[i].inventory.Class.Name == 'AmmoSlug')
		{
			bHasSlugs = true;
			break;
		}
	}
	
	// WeaponShotgun now uses AmmoSlug instead of AmmoShell
	if (bCanUseSlugs && !bHasSlugs)
	{
		for(i=0;i<8;i++)
		{
			if(initialinventory[i].inventory != None && class<AmmoShell>(initialinventory[i].inventory) != None)
			{
				buckshotSlot = i;
				buckshotCount = initialinventory[i].count;
				break;
			}
		}
		
		// Find an empty slot for slug rounds
		for(i=0;i<8;i++)
		{
			if(initialinventory[i].inventory == None)
			{
				if (buckshotCount == 0)
					buckshotCount += Rand(10)+3;
				initialinventory[i].inventory = class<DeusExAmmo>(DynamicLoadObject("TNMItems.AmmoSlug",class'Class'));
				initialinventory[i].count = buckshotCount;
				bFoundEmpty = True;
				break;
			}
		}
		
		// If no empty slot, replace AmmoShell (assume AmmoShell exists)
		if (!bFoundEmpty)
		{
			initialinventory[buckshotSlot].inventory = class<DeusExAmmo>(DynamicLoadObject("TNMItems.AmmoSlug",class'Class'));
		}
	}
	super.InitializeInventory();
}

state Burning
{
	function BeginState()
	{
		StandUp();
		BlockReactions();
		bCanConverse = False;
		SetupWeapon(false, true);
		bStasis = False;
		SetDistress(true);
		EnemyLastSeen = 0;
		SeekPawn = None;
		EnableCheckDestLoc(false);
	}
	
	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);
		LipSynchBarks(deltaTime);
	}
	
	function Landed(vector HitNormal)
	{
		local float landVol, minJumpZ;
		local vector legLocation;

		minJumpZ = FMax(JumpZ, 150.0);

		if ( (Velocity.Z < -0.8 * minJumpZ) || bUpAndOut)
		{
			PlayLanded(Velocity.Z);
			if (Velocity.Z < -700)
			{
				legLocation = Location + vect(-1,0,-1);			// damage left leg
				TakeDamage(-0.14 * (Velocity.Z + 700), Self, legLocation, vect(0,0,0), 'fell');
				legLocation = Location + vect(1,0,-1);			// damage right leg
				TakeDamage(-0.14 * (Velocity.Z + 700), Self, legLocation, vect(0,0,0), 'fell');
				legLocation = Location + vect(0,0,1);			// damage torso
				TakeDamage(-0.04 * (Velocity.Z + 700), Self, legLocation, vect(0,0,0), 'fell');
			}
			landVol = Velocity.Z/JumpZ;
			landVol = 0.005 * Mass * FMin(5, landVol * landVol);
			if ( !FootRegion.Zone.bWaterZone )
				PlaySound(Land, SLOT_Interact, FMin(20, landVol));
		}

		else if ( Velocity.Z < -0.8 * JumpZ )
			PlayLanded(Velocity.Z);
	}

Begin:
	if (!bOnFire)
		Goto('Done');
	PlayOnFireSound();

NewEnemy:
	Acceleration = vect(0, 0, 0);

Run:
	if (!bOnFire)
		Goto('Done');
	PlayPanicRunning();
	PickDestination();
	if (destPoint != None)
	{
		MoveToward(MoveTarget, MaxDesiredSpeed);
		while ((MoveTarget != None) && (MoveTarget != destPoint))
		{
			MoveTarget = FindPathToward(destPoint);
			if (MoveTarget != None)
				MoveToward(MoveTarget, MaxDesiredSpeed);
		}
	}
	else
		MoveTo(destLoc, MaxDesiredSpeed);

	Goto('Run');

Done:
	if (IsValidEnemy(Enemy))
		GotoState('HandlingEnemy', 'Begin');
	else
		FollowOrders();

ContinueBurn:
ContinueFromDoor:
	Goto('Run');
}

State Patrolling
{
	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);

		LipSynchBarks(deltaTime);
		
		patrolLookTimer += deltaTime;
		
		if (bCanTurnHead && bExtraSuspicious)
		{
			if (patrolLookTimer > 13.0)
			{
				PlayTurnHead(LOOK_Right, 1.0, 1.0);
				patrolLookTimer = 0;
			}
			else if (patrolLookTimer > 7.0)
				PlayTurnHead(LOOK_Forward, 1.0, 1.0);
			else if (patrolLookTimer > 3.0)
				PlayTurnHead(LOOK_Left, 1.0, 1.0);
		}
	}
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
				Log("TNMPawn Failed to return to patrol");
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
			// if (PatrolPoint(destPoint).PatrolAnim != '' && HasAnim(PatrolPoint(destPoint).PatrolAnim))
				// PlayAnim(PatrolPoint(destPoint).PatrolAnim);
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

// Fix to prevent bInWorld=False Pawns to fall out of the world.
event FellOutOfWorld()
{
	// HX_NOTE: EVIL HACK!
	if ( !bInWorld )
	{
		Log( "Saved " $ Self $ " from falling out of the world." );

		SetLocation( WorldPosition + vect(0,0,20000) );
		SetPhysics(PHYS_None);
	}
	else
		Super.FellOutOfWorld();
}

function LoopBaseConvoAnim()
{
	local float rnd;
	
	// Special case for sitting
	if (bSitting)
	{
		if (!IsAnimating())
			PlaySitting();
	}

	// Special case for dancing
	else if (bDancing)
	{
		if (!IsAnimating())
			PlayDancing();
	}
	else
	{
		rnd = FRand();

		// move arms randomly
		if (bIsSpeaking && (AnimSequence == 'BreatheLight' || AnimSequence == 'BreatheLight2H' || AnimSequence == 'SitBreathe' || AnimSequence == '')) // Do not overwrite custom anims (ConEventAnimation)
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
		{
			// if (dxWeapon.ProjectileClass != None && dxWeapon.ProjectileClass.Default.Class.Name == 'TNMPlasmaBolt' && dist <= 1024)
			if (dxWeapon.ProjectileClass != None && dxWeapon.ProjectileClass.Default.Class.Name == 'TNMPlasmaBolt' && dist <= 128)
				return true;
			else
				return false;
		}
	}

	if (dxWeapon.bInstantHit)
		return (AISafeToShoot(hitActor, projEnd, projStart, , true));
	else
	{
		if (dxWeapon.ProjectileClass != None)
		{
			extent.X = dxWeapon.ProjectileClass.default.CollisionRadius;
			extent.Y = dxWeapon.ProjectileClass.default.CollisionRadius;
			extent.Z = dxWeapon.ProjectileClass.default.CollisionHeight;
		}
		if (bIsThrown && (throwAccuracy > 0))
			return (AISafeToThrow(projEnd, projStart, throwAccuracy, extent));
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


// ----------------------------------------------------------------------
// SetEnemy()
// ----------------------------------------------------------------------

function bool SetEnemy(Pawn newEnemy, optional float newSeenTime,
                       optional bool bForce)
{
	if (TNMRobot(newEnemy) != None && TNMRobot(newEnemy).EMPHitPoints <= 0)
		return False;
	if (RespawnInfo(newEnemy) != None)
		return False;

	return Super.SetEnemy(newEnemy, newSeenTime, bForce);
}

function name GetFloorMaterial()
{
	local vector EndTrace, HitLocation, HitNormal;
	local actor target;
	local int texFlags;
	local name texName, texGroup;
	local bool bFound;

	// trace down to our feet
	EndTrace = Location - CollisionHeight * 2 * vect(0,0,1);

	foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, HitLocation, HitNormal, EndTrace)
	{
		if ((target == Level) || target.IsA('Mover'))
		{
			bFound=true;
			FloorTexture=texName;
			break;
		}
	}

	if(!bFound)
		return 'Default';

	//todo - Well they're called Helisnow, snow1, snow1b, snow2, snow3, snow4, snow5, snow7, and snow8
	bWalkingOnSnow = (FloorTexture == 'snow1')||
			 (FloorTexture == 'snow1b')||
			 (FloorTexture == 'snow2')||
			 (FloorTexture == 'snow3')||
			 (FloorTexture == 'snow4')||
			 (FloorTexture == 'snow5')||
			 (FloorTexture == 'snow7')||
			 (FloorTexture == 'snow8')||
			 (FloorTexture == 'Wall_B_Bot')||
			 (FloorTexture == 'Wall_B_Cen')||
			 (FloorTexture == 'Wall_B_CenB')||
			 (FloorTexture == 'Wall_B_Left')||
			 (FloorTexture == 'Wall_B_Right')||
			 (FloorTexture == 'Wall_B_Top')||
			 (FloorTexture == 'Snow7_Bot')||
			 (FloorTexture == 'snow7_FadeBotLeft')||
			 (FloorTexture == 'snow7_FadeBotRight')||
			 (FloorTexture == 'snow7_FadeLeft')||
			 (FloorTexture == 'snow7_FadeRight')||
			 (FloorTexture == 'snow7_FadeTopLeft')||
			 (FloorTexture == 'snow7_FadeTopRight')||
			 (FloorTexture == 'Snow7_Left')||
			 (FloorTexture == 'Snow7_Right')||
			 (FloorTexture == 'Snow7_TB')||
			 (FloorTexture == 'Snow7_Top')||
			 (FloorTexture == 'Helisnow');
	return texGroup;
}

function SpawnFootprint()
{
	local Vector HitLocation, HitNormal, EndTrace;
	local vector X,Y,Z;
	local Actor hit;
	local tnmshoeprint D;
	local vector start;
	local vector direction;
	
	if (IsA('TNMAnimal'))
		return;

	if (bWalkingOnSnow)
	{
		footprintoffset *= -1.0;

		GetAxes(Rotation,X,Y,Z);

		start = Location + footprintoffset * Y;

		EndTrace = start - 320*vect(0,0,1);
		hit = Trace(HitLocation, HitNormal, EndTrace, start, False);
		D = spawn(Class'TNMShoePrint',,, HitLocation+HitNormal, Rotator(HitNormal));

		if ( D != none)
		{
			D.bLeftFoot = (footprintoffset < 0);
			D.Refresh();

			if ( bWalkingBackwards )
				direction = -vector(rotation);
			else
				direction = vector(rotation);

			D.ReattachDecal(direction);
		}
	}
}

function PlayDyingSound()
{
	if (bruhSound != None)
		PlaySound(bruhSound, SLOT_Pain, 3.0 ,,, RandomPitch());
	else if ((IsA('BoardGuest1') || IsA('BoardGuest2')) && !Region.Zone.bWaterZone)
	{
		PlaySound(Die, SLOT_Pain,,,, RandomPitch() * 1.5);
		Die = None;
		Super.PlayDyingSound();
	}
	else
		Super.PlayDyingSound();
}

function bool IsSeatValid(Actor checkActor)
{
	local PlayerPawn player;
	local Seat       checkSeat;

	checkSeat = Seat(checkActor);
	if (checkSeat == None)
		return false;
	else if (checkSeat.bDeleteMe)
		return false;
	else if (!bSitAnywhere && (VSize(checkSeat.Location-checkSeat.InitialPosition) > 70))
		return false;
	else if (checkSeat.IsInState('Burning')) // New
		return false;
	else
	{
		player = GetPlayerPawn();
		if (player != None)
		{
			if (player.CarriedDecoration == checkSeat)
				return false;
		}
		return true;
	}
}
/* Unsure of this
function EndConversation()
{
	Super.EndConversation();
	
	bIsSpeaking = False;
	lookAtTarget = None;
}*/

function ChangeAlly(Name newAlly, optional float allyLevel, optional bool bPermanent, optional bool bHonorPermanence)
{
	local int i;

	// Members of the same alliance will ALWAYS be friendly to each other
	if (newAlly == Alliance)
	{
		allyLevel  = 1;
		bPermanent = true;
	}

	if (bHonorPermanence)
	{
		for (i=0; i<16; i++)
			if (AlliancesEx[i].AllianceName == newAlly)
				if (AlliancesEx[i].bPermanent)
					break;
		if (i < 16)
			return;
	}

	if (allyLevel < -1)
		allyLevel = -1;
	if (allyLevel > 1)
		allyLevel = 1;

	for (i=0; i<16; i++)
		if ((AlliancesEx[i].AllianceName == newAlly) || (AlliancesEx[i].AllianceName == ''))
			break;

	if (i >= 16)
		for (i=15; i>0; i--)
			AlliancesEx[i] = AlliancesEx[i-1];

	AlliancesEx[i].AllianceName         = newAlly;
	AlliancesEx[i].AllianceLevel        = allyLevel;
	AlliancesEx[i].AgitationLevel       = 0;
	AlliancesEx[i].bPermanent           = bPermanent;

	bAlliancesChanged    = True;
	bNoNegativeAlliances = False;
	
	GetPlayer();
	
	if (localPlayer.bNightmareMode)
	{
		InitialAlliances[i].AllianceName = newAlly;
		InitialAlliances[i].AllianceLevel = allyLevel;
		InitialAlliances[i].bPermanent = bPermanent;
	}
}

singular function SetupInvader()
{	
	GiveRandomInventory();
	
	bInvincible = False;
	ChangeAlly('Player', -1, True);
	
	ConBindEvents();
	InitializePawn();
}

function GiveRandomInventory()
{
	local int RNG;
	
	RNG = Rand(15);
		
	if (!IsA('Animal') && !IsA('ABICommando')  && !IsA('GenericAlien') && !IsA('Robot') && (!bIsFemale || IsA('SuperWiB')) && (Mesh != LodMesh'DeusExCharacters.GM_DressShirt_S' && Mesh != LodMesh'DeusExCharacters.GM_DressShirt_F' && Mesh != LodMesh'DeusExCharacters.GM_Trench_F' && Mesh != LodMesh'DeusExCharacters.GM_Scubasuit'))
	{
		InitialInventory[0].Inventory = None;	// Remove the assault rifles from UNATCO and MJ12
		InitialInventory[0].Count = 1;
		
		if (RNG == 0)
		{
			InitialInventory[1].Inventory = None;
			InitialInventory[1].Count = 0;
		}
		else if (RNG == 1)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMPistol", 			class'Inventory', True));
			InitialInventory[1].Count = 1;
			InitialInventory[0].Inventory = Class'DeusEx.Ammo10mm';
			InitialInventory[0].Count = 50;
		}
		else if (RNG == 2)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMStealthPistol", 			class'Class', True));
			InitialInventory[1].Count = 1;
			InitialInventory[0].Inventory = Class'DeusEx.Ammo10mm';
			InitialInventory[0].Count = 50;
		}
		else if (RNG == 3)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMSawedOffShotgun", 			class'Class', True));
			InitialInventory[1].Count = 1;
			InitialInventory[0].Inventory = Class'DeusEx.AmmoShell';
			InitialInventory[0].Count = 50;
		}
		else if (RNG == 4)
		{
			if (IsA('GenericLlama'))
			{
				InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponThrowSpork", 			class'Class', True));
				InitialInventory[1].Count = 3;
			}
			else if (IsA('GenericGoat'))
			{
				InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponThrowFoon", 			class'Class', True));
				InitialInventory[1].Count = 3;
			}
			else
			{
				InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMShuriken", 			class'Class', True));
				InitialInventory[1].Count = 3;
			}
		}
		else if (RNG == 5)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMHideAGun", 			class'Class', True));
			InitialInventory[1].Count = 5;
		}
		else if (RNG == 6)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMProd", 			class'Class', True));
			InitialInventory[1].Count = 1;
			InitialInventory[0].Inventory = Class'DeusEx.AmmoBattery';
			InitialInventory[0].Count = 50;
		}
		else if (RNG == 7)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMAssaultGun", 			class'Class', True));
			InitialInventory[1].Count = 1;
			InitialInventory[0].Inventory = Class'DeusEx.Ammo762mm';
			InitialInventory[0].Count = 50;
		}
		else if (RNG == 8)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMAssaultShotGun", 			class'Class', True));
			InitialInventory[1].Count = 1;
			InitialInventory[0].Inventory = Class'DeusEx.AmmoShell';
			InitialInventory[0].Count = 50;
		}
		else if (RNG == 9)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMMiniCrossbow", 			class'Class', True));
			InitialInventory[1].Count = 1;
			InitialInventory[0].Inventory = Class'DeusEx.AmmoDartFlare';
			InitialInventory[0].Count = 50;
		}
		else if (RNG == 10)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMRifle", 			class'Class', True));
			InitialInventory[1].Count = 1;
			InitialInventory[0].Inventory = Class'DeusEx.Ammo3006';
			InitialInventory[0].Count = 50;
		}
		else if (RNG == 11)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMGEPGun", 			class'Class', True));
			InitialInventory[1].Count = 1;
			InitialInventory[0].Inventory = Class'DeusEx.AmmoRocket';
			InitialInventory[0].Count = 50;
		}
		else if (RNG == 12)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMFlamethrower", 			class'Class', True));
			InitialInventory[1].Count = 1;
			InitialInventory[0].Inventory = Class'DeusEx.AmmoNapalm';
			InitialInventory[0].Count = 50;
		}
		else if (RNG == 13)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMPlasmaRifle", 			class'Class', True));
			InitialInventory[1].Count = 1;
		}
		else if (RNG == 14)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponFireExting", 			class'Class', True));
			InitialInventory[1].Count = 1;
		}
	}
	else if (bIsFemale || (Mesh == LodMesh'DeusExCharacters.GM_DressShirt_S' || Mesh == LodMesh'DeusExCharacters.GM_DressShirt_F' || Mesh == LodMesh'DeusExCharacters.GM_Trench_F' || Mesh == LodMesh'DeusExCharacters.GM_Scubasuit'))
	{
		if (RNG == 0)
		{
			InitialInventory[1].Inventory = None;
			InitialInventory[1].Count = 0;
		}
		else if (RNG == 1)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMPistol", 			class'Class', True));
			InitialInventory[1].Count = 1;
			InitialInventory[0].Inventory = Class'DeusEx.Ammo10mm';
			InitialInventory[0].Count = 50;
		}
		else if (RNG == 2)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMStealthPistol", 			class'Class', True));
			InitialInventory[1].Count = 1;
			InitialInventory[0].Inventory = Class'DeusEx.Ammo10mm';
			InitialInventory[0].Count = 50;
		}
		else if (RNG == 3)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMSawedOffShotgun", 			class'Class', True));
			InitialInventory[1].Count = 1;
			InitialInventory[0].Inventory = Class'DeusEx.AmmoShell';
			InitialInventory[0].Count = 50;
		}
		else if (RNG == 4)
		{
			if (IsA('GenericLlama'))
			{
				InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponThrowSpork", 			class'Class', True));
				InitialInventory[1].Count = 3;
			}
			else if (IsA('GenericGoat'))
			{
				InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponThrowFoon", 			class'Class', True));
				InitialInventory[1].Count = 3;
			}
			else
			{
				InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMShuriken", 			class'Class', True));
				InitialInventory[1].Count = 3;
			}
		}
		else if (RNG == 5)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMHideAGun", 			class'Class', True));
			InitialInventory[1].Count = 1;
		}
		else if (RNG == 6)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMProd", 			class'Class', True));
			InitialInventory[1].Count = 1;
		}
		else if (RNG == 7)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMMiniCrossbow", 			class'Class', True));
			InitialInventory[1].Count = 1;
		}
		else if (RNG == 8)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMSawedOffShotgun", 			class'Class', True));
			InitialInventory[1].Count = 1;
			InitialInventory[0].Inventory = Class'DeusEx.AmmoShell';
			InitialInventory[0].Count = 50;
		}
		else if (RNG == 9)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMMiniCrossbow", 			class'Class', True));
			InitialInventory[1].Count = 1;
		}
		else if (RNG == 10)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMHideAGun", 			class'Class', True));
			InitialInventory[1].Count = 5;
		}
		else if (RNG == 11)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMSawedOffShotgun", 			class'Class', True));
			InitialInventory[1].Count = 1;
			InitialInventory[0].Inventory = Class'DeusEx.AmmoShell';
			InitialInventory[0].Count = 50;
		}
		else if (RNG == 12)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMPistol", 			class'Class', True));
			InitialInventory[1].Count = 1;
			InitialInventory[0].Inventory = Class'DeusEx.Ammo10mm';
			InitialInventory[0].Count = 50;
		}
		else if (RNG == 13)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMSawedOffShotgun", 			class'Class', True));
			InitialInventory[1].Count = 1;
			InitialInventory[0].Inventory = Class'DeusEx.AmmoShell';
			InitialInventory[0].Count = 50;
		}
		else if (RNG == 14)
		{
			InitialInventory[1].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponFireExting", 			class'Class', True));
			InitialInventory[1].Count = 1;
		}
	}
	
	if (IsA('SecurityBot4'))
	{
		InitialInventory[1].Inventory = Class'DeusEx.WeaponRobotMachinegun';
		InitialInventory[1].Count = 1;
		InitialInventory[0].Inventory = Class'DeusEx.Ammo762mm';
		InitialInventory[0].Count = 50;
	}
	
	if (IsA('TriadLumPath'))
	{
		InitialInventory[1].Inventory = None;
		InitialInventory[1].Count = 0;
	}
	
	if (!IsA('Animal') && !IsA('ABICommando') && !IsA('GenericAlien') && !IsA('Robot'))
	{
		RNG = Rand(8);
		
		if (IsA('GenericLlama'))
		{
			InitialInventory[2].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponSpork", 			class'Class', True));
			InitialInventory[2].Count = 1;
		}
		else if (IsA('GenericGoat'))
		{
			InitialInventory[2].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponFoon", 			class'Class', True));
			InitialInventory[2].Count = 1;
		}
		else if (RNG == 0)
		{
			InitialInventory[2].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMBaton", 			class'Class', True));
			InitialInventory[2].Count = 1;
		}
		else if (RNG == 1)
		{
			InitialInventory[2].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMCombatKnife", 			class'Class', True));
			InitialInventory[2].Count = 1;
		}
		else if (RNG == 2)
		{
			InitialInventory[2].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMCrowbar", 			class'Class', True));
			InitialInventory[2].Count = 1;
		}
		else if (RNG == 3)
		{
			InitialInventory[2].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMSword", 			class'Class', True));
			InitialInventory[2].Count = 1;
		}
		else if (RNG == 4)
		{
			InitialInventory[2].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMNanosword", 			class'Class', True));
			InitialInventory[2].Count = 1;
		}
		else if (RNG == 5)
		{
			InitialInventory[2].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponWrench", 			class'Class', True));
			InitialInventory[2].Count = 1;
		}
		else if (RNG == 6)
		{
			InitialInventory[2].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponScrewDriver", 			class'Class', True));
			InitialInventory[2].Count = 1;
		}
		else if (RNG == 7)
		{
			InitialInventory[2].Inventory = Class<Inventory>(DynamicLoadObject("TNMItems.WeaponHammer", 			class'Class', True));
			InitialInventory[2].Count = 1;
		}
	}
	
	SetupWeapon(true);
}

function StartPoison(int Damage, Pawn newPoisoner)
{
	if (MelkZone(Region.Zone) == None)
		Super.StartPoison(Damage, newPoisoner);
}

function AdjustJump();
function MoveFallingBody();
function Vector FocusDirection();
function FindBackupPoint();
function bool DoorEncroaches();
function bool PickDestination();
function EDestinationType PickDestinationAttacking(); //BARF! Thanks Ion.
function float DistanceToTarget();
function AlarmUnit FindTarget();
function bool GetNextAlarmPoint(AlarmUnit alarm);
function vector FindAlarmPosition(Actor alarm);
function bool IsAlarmInRange(AlarmUnit alarm);
function TriggerAlarm();
function bool IsAlarmReady(Actor actorAlarm);
function EndCrouch();
function StartCrouch();
function bool ShouldCrouch();
function bool ReadyForWeapon();
function bool IsHandToHand();
function CheckAttack(bool bPlaySound);
function bool FireIfClearShot();
function bool InSeat(out vector newLoc);
function FinishFleeing();
function NavigationPoint GetOvershootDestination(float randomness, optional float focus);
function bool GetNextLocation(out vector nextLoc);
function PatrolPoint PickStartPoint();
function bool GoHome();
function FollowSeatFallbackOrders();
function FindBestSeat();
function int FindBestSlot(Seat seatActor, out float slotDist);
function bool IsIntersectingSeat();
function vector GetDestinationPosition(Seat seatActor, optional float extraDist);
function Vector SitPosition(Seat seatActor, int slot);

// Hack to play idle sounds since he always patrols.
function PlayScanningSound()
{
	if (bPatrolIdleSound)
		PlayIdleSound();
	else
		Super.PlayScanningSound();
}


function bool HandleTurn(actor Other)
{
	local bool             bHandle;
	local bool             bHackState;
	local DeusExDecoration dxDecoration;
	local ScriptedPawn     scrPawn;

	// THIS ENTIRE SECTION IS A MASSIVE HACK TO GET AROUND PATHFINDING PROBLEMS
	// WHEN AN OBSTACLE COMPLETELY BLOCKS AN NPC'S PATH...

	bHandle    = true;
	bHackState = false;
	if (bEnableCheckDest)
	{
		dxDecoration = DeusExDecoration(Other);
		scrPawn      = ScriptedPawn(Other);
		if (DestAttempts >= 2)
		{
			if (dxDecoration != None)
			{
				if (!dxDecoration.bInvincible && !dxDecoration.bExplosive)
				{
					dxDecoration.HitPoints = 0;
					dxDecoration.TakeDamage(1, self, dxDecoration.Location, vect(0,0,0), 'Kick');
					bHandle = false;
				}
				else if (dxDecoration.bInvincible && dxDecoration.bPushable && DestAttempts < 3 && !IsA('TNMAnimal'))
				{
					dxDecoration.SetPhysics(PHYS_Falling);
					// dxDecoration.Velocity.X = GroundSpeed;
					// dxDecoration.Velocity.Y = GroundSpeed;
					dxDecoration.Velocity = Velocity * 1.1;
					dxDecoration.Velocity.Z = JumpZ * 3;
				}
				else if (DestAttempts >= 3)
				{
					bHackState = true;
					bHandle    = false;
				}
			}
			else if (scrPawn != None)
			{
				if (DestAttempts >= 3)
				{
					if (scrPawn.GetStateName() != 'BackingOff')
					{
						bHackState = true;
						bHandle    = false;
					}
				}
			}
		}
		else if (dxDecoration != None && dxDecoration.bInvincible && dxDecoration.bPushable /* && DestAttempts < 3*/)
		{
			dxDecoration.SetPhysics(PHYS_Falling);
			dxDecoration.Velocity = Velocity * 1.5;
			dxDecoration.Velocity.Z = JumpZ * 3;
		}/*
		else if (dxDecoration.bExplosive)
		{
			dxDecoration.SetPhysics(PHYS_Falling);
			dxDecoration.Velocity = (GetPlayerPawn().Location - dxDecoration.Location);
			// dxDecoration.Velocity.X *= GroundSpeed;
			// dxDecoration.Velocity.Y *= GroundSpeed;
			dxDecoration.Velocity.Z = JumpZ * 3;
			dxDecoration.HitPoints = 0;
			// dxDecoration.GoToState('Burning');
		}*/

		if (bHackState)
			BackOff();
	}

	return (bHandle);
}

function BanPawn()
{
	local BanInfo ban;
	local bool bValidItem;
	local inventory item, nextItem;
	local Vector loc;
	local name flagName;
	local Human player;
	
	player = Human(GetPlayerPawn());

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
	
	if (bImportant)
	{
		flagName = player.rootWindow.StringToName(BindName$"_Dead");
		player.flagBase.SetBool(flagName, True);

		// make sure the flag never expires
		player.flagBase.SetExpiration(flagName, FLAG_Bool, 0);
	}
	Killed(player, Self, 'Banned');
	
	ban=Spawn(Class'BanInfo');
	ban.StartBan(Self);
}

function PlayPreAttackSearchingSound()
{
	local DeusExPlayer dxPlayer;

	dxPlayer = DeusExPlayer(SeekPawn);
	if (dxPlayer != None)
		dxPlayer.StartAIBarkConversation(self, BM_PreAttackSearching);
}

function PlayPreAttackSightingSound()
{
	local DeusExPlayer dxPlayer;

	dxPlayer = DeusExPlayer(SeekPawn);
	if (dxPlayer != None)
		dxPlayer.StartAIBarkConversation(self, BM_PreAttackSighting);
}

function PlayPostAttackSearchingSound()
{
	local DeusExPlayer dxPlayer;

	dxPlayer = DeusExPlayer(SeekPawn);
	if (dxPlayer != None)
		dxPlayer.StartAIBarkConversation(self, BM_PostAttackSearching);
}

function PlayTargetLostSound()
{
	local DeusExPlayer dxPlayer;

	dxPlayer = DeusExPlayer(SeekPawn);
	if (dxPlayer != None)
		dxPlayer.StartAIBarkConversation(self, BM_TargetLost);
}

function PlaySearchGiveUpSound()
{
	local DeusExPlayer dxPlayer;

	dxPlayer = DeusExPlayer(SeekPawn);
	if (dxPlayer != None)
		dxPlayer.StartAIBarkConversation(self, BM_SearchGiveUp);
}

function PlayGoingForAlarmSound()
{
	local DeusExPlayer dxPlayer;

	dxPlayer = DeusExPlayer(Enemy);
	if (dxPlayer != None)
		dxPlayer.StartAIBarkConversation(self, BM_GoingForAlarm);
}

function PlayCriticalDamageSound()
{
	local DeusExPlayer dxPlayer;

	dxPlayer = DeusExPlayer(Enemy);
	if (dxPlayer != None)
		dxPlayer.StartAIBarkConversation(self, BM_CriticalDamage);
}

function PlayCarcassSound()
{
	local DeusExPlayer dxPlayer;

	dxPlayer = DeusExPlayer(SeekPawn);
	if (dxPlayer != None)
		dxPlayer.StartAIBarkConversation(self, BM_Gore);
}

function PlaySurpriseSound()
{
	local DeusExPlayer dxPlayer;

	dxPlayer = DeusExPlayer(Enemy);
	if (dxPlayer != None)
		dxPlayer.StartAIBarkConversation(self, BM_Surprise);
}

function PlayAllianceHostileSound()
{
	local DeusExPlayer dxPlayer;

	dxPlayer = DeusExPlayer(Enemy);
	if (dxPlayer != None)
		dxPlayer.StartAIBarkConversation(self, BM_AllianceHostile);
}

function PlayAllianceFriendlySound()
{
	local DeusExPlayer dxPlayer;

	dxPlayer = DeusExPlayer(Enemy);
	if (dxPlayer != None)
		dxPlayer.StartAIBarkConversation(self, BM_AllianceFriendly);
}

function PlayTargetAcquiredSound()
{
	local DeusExPlayer dxPlayer;
	
	if (BarkBindName ~= "LoyalFirewall") // Hack
	{
		dxPlayer = DeusExPlayer(Enemy);
		if (dxPlayer == None)
			dxPlayer = DeusExPlayer(GetPlayerPawn());
		if (dxPlayer != None)
			dxPlayer.StartAIBarkConversation(self, BM_TargetAcquired);
	}
	else
	{
		dxPlayer = DeusExPlayer(Enemy);
		if (dxPlayer != None)
			dxPlayer.StartAIBarkConversation(self, BM_TargetAcquired);
		else
			Super.PlayTargetAcquiredSound();
	}
}

function PlayNewTargetSound()
{
	local DeusExPlayer dxPlayer;
	if (BarkBindName ~= "LoyalFirewall") // Hack
	{
		dxPlayer = DeusExPlayer(Enemy);
		if (dxPlayer == None)
			dxPlayer = DeusExPlayer(GetPlayerPawn());
		if (dxPlayer != None)
			dxPlayer.StartAIBarkConversation(self, BM_TargetAcquired);
	}
	else
		Super.PlayNewTargetSound();
}


function rotator AdjustAim(float projSpeed, vector projStart, int aimerror, bool leadTarget, bool warnTarget)
{
    local rotator     FireRotation;
    local vector      FireSpot;
    local actor       HitActor;
    local vector      HitLocation, HitNormal;
    local vector      vectorArray[3];
    local vector      tempVector;
    local int         i;
    local int         swap;
    local Rotator     rot;
    local bool        bIsThrown;
    local DeusExMover dxMover;
    local actor       Target;  // evil fix -- STM
    local DeusExDecoration ExplosiveTarget;

    bIsThrown = IsThrownWeapon(DeusExWeapon(Weapon));

// took this line out for evil fix...
//  if ( Target == None )

    Target = Enemy;
    if ( Target == None )
        return Rotation;
    if ( !Target.bIsPawn )
        return rotator(Target.Location - Location);
	foreach RadiusActors(class'DeusExDecoration', ExplosiveTarget, 2000, Target.Location) // Find explosive decorations around the player.
	{
		if (ExplosiveTarget.bExplosive && !ExplosiveTarget.IsA('Van') && !ExplosiveTarget.bHidden && !ExplosiveTarget.bInvincible && (AICanSee(ExplosiveTarget, 1.0, false, false, false, true) > 0) && ExplosiveTarget.PlayerCanSeeMe()) // Is there an explosive that both we and the target have direct LOS to?
		{
			if (VSize(ExplosiveTarget.Location - Location) > (ExplosiveTarget.explosionRadius)) // Are we safe?
			{
				if (VSize(ExplosiveTarget.Location - Target.Location) <= (ExplosiveTarget.explosionRadius)) // Are they not safe?
				{
					Target = ExplosiveTarget;   // Let's shoot that explosive instead!
					break;
				}
			}
		}
	}

    FireSpot = Target.Location;
    if (leadTarget && (projSpeed > 0))
    {
        if (bIsThrown)
        {
            // compute target's position 1.5 seconds in the future
            FireSpot = target.Location + (target.Velocity*1.5);
        }
        else
        {
            //FireSpot += (Target.Velocity * VSize(Target.Location - ProjStart)/projSpeed);
            ComputeTargetLead(Pawn(Target), ProjStart, projSpeed, 20.0, FireSpot);
        }
    }

    if (bIsThrown)
    {
        vectorArray[0] = FireSpot - vect(0,0,1)*(Target.CollisionHeight-5);  // floor
        vectorArray[1] = vectorArray[0] + Vector(rot(0,1,0)*Rand(65536))*CollisionRadius*1.2;
        vectorArray[2] = vectorArray[0] + Vector(rot(0,1,0)*Rand(65536))*CollisionRadius*1.2;

        for (i=0; i<3; i++)
        {
            if (AISafeToThrow(vectorArray[i], ProjStart, 0.025))
                break;
        }
        if (i < 3)
        {
            FireSpot = vectorArray[i];
            FireRotation = ViewRotation;
        }
        else
            FireRotation = Rotator(FireSpot - ProjStart);
    }
    else
    {
        dxMover = DeusExMover(Target.Base);
        if ((dxMover != None) && dxMover.bBreakable)
        {
            tempVector = Normal((Location-Target.Location)*vect(1,1,0))*(Target.CollisionRadius*1.01) -
                         vect(0,0,1)*(Target.CollisionHeight*1.01);
            vectorArray[0] = FireSpot + tempVector;
        }
        else if (Weapon != None && DeusExWeapon(weapon).WeaponDamageType() == 'headstun')
            vectorArray[0] = FireSpot + vect(0,0,1)*(Target.CollisionHeight*0.85);    // head
        else if (bAimForHead)
            vectorArray[0] = FireSpot + vect(0,0,1)*(Target.CollisionHeight*0.85);    // head
        else if (RespawnInfo(Target) != None)
            vectorArray[0] = FireSpot + vect(0,0,-1)*(Target.CollisionHeight);    // head
        else
            vectorArray[0] = FireSpot + vect(0,0,1)*((FRand()*2-1)*Target.CollisionHeight);
        vectorArray[1] = FireSpot + vect(0,0,1)*((FRand()*2-1)*Target.CollisionHeight);
        vectorArray[2] = FireSpot + vect(0,0,1)*((FRand()*2-1)*Target.CollisionHeight);

        for (i=0; i<3; i++)
        {
            if (AISafeToShoot(HitActor, vectorArray[i], ProjStart))
                break;
        }
        if (i < 3)
            FireSpot = vectorArray[i];

        FireRotation = Rotator(FireSpot - ProjStart);
    }

    if (warnTarget && Pawn(Target) != None)
        Pawn(Target).WarnTarget(self, projSpeed, vector(FireRotation));

    FireRotation.Yaw = FireRotation.Yaw & 65535;
    if ( (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) > 8192)
        && (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) < 57343) )
    {
        if ( (FireRotation.Yaw > Rotation.Yaw + 32768) ||
            ((FireRotation.Yaw < Rotation.Yaw) && (FireRotation.Yaw > Rotation.Yaw - 32768)) )
            FireRotation.Yaw = Rotation.Yaw - 8192;
        else
            FireRotation.Yaw = Rotation.Yaw + 8192;
    }
    viewRotation = FireRotation;
    return FireRotation;
}


function bool CheckEnemyPresence(float deltaSeconds,
                                 bool bCheckPlayer, bool bCheckOther)
{
    local int          i;
    local int          count;
    local int          checked;
    local Pawn         candidate;
    local float        candidateDist;
    local DeusExPlayer playerCandidate;
    local bool         bCanSee;
    local int          lastCycle;
    local float        visibility;
    local Pawn         cycleEnemy;
    local bool         bValid;
    local bool         bPlayer;
    local float        surpriseTime;
    local bool         bValidEnemy;
    local bool         bPotentialEnemy;
    local bool         bCheck;

    bValid  = false;
    bCanSee = false;
    if (bReactPresence && bLookingForEnemy && !bNoNegativeAlliances)
    {
        if (PotentialEnemyAlliance != '')
            bCheck = true;
        else if (Alliance == 'Player')
            bCheck = true;
        else
        {
            for (i=0; i<16; i++)
                if ((AlliancesEx[i].AllianceLevel < 0) || (AlliancesEx[i].AgitationLevel >= 1.0))
                    break;
            if (i < 16)
                bCheck = true;
        }

        if (bCheck)
        {
            bValid       = true;
            CyclePeriod += deltaSeconds;
            count        = 0;
            checked      = 0;
            lastCycle    = CycleIndex;
            foreach CycleActors(Class'Pawn', candidate, CycleIndex)
            {
                bPlayer = PlayerPawn(candidate) != None;
                if (bPlayer && Level.NetMode != NM_Standalone)
                    continue;
                bPotentialEnemy = false;
                bValidEnemy = IsValidEnemy(candidate);
                if (!bValidEnemy && (PotentialEnemyTimer > 0))
                    if (PotentialEnemyAlliance == candidate.Alliance)
                        bPotentialEnemy = true;
				if (Alliance == 'Player' && ScriptedPawn(candidate) != None && ScriptedPawn(candidate).GetPawnAllianceType(Self) == ALLIANCE_Hostile)
					bPotentialEnemy = true;
                if (bValidEnemy || bPotentialEnemy)
                {
                    count++;
                    if ((bPlayer && bCheckPlayer) || (!bPlayer && bCheckOther))
                    {
                        visibility = AICanSee(candidate, ComputeActorVisibility(candidate), true, true, true, true);
                        if (visibility > 0)
                        {
                            if (bPotentialEnemy)  // We can see the potential enemy; ergo, we hate him
                            {
                                IncreaseAgitation(candidate, 1.0);
                                PotentialEnemyAlliance = '';
                                PotentialEnemyTimer    = 0;
                                bValidEnemy = IsValidEnemy(candidate);
                            }
                            if (bValidEnemy)
                            {
                                visibility += VisibilityThreshold;
                                candidateDist = VSize(Location-candidate.Location);
                                if ((CycleCandidate == None) || (CycleDistance > candidateDist))
                                {
                                    CycleCandidate = candidate;
                                    CycleDistance  = candidateDist;
                                }
                                if (!bPlayer)
                                    CycleCumulative += 100000;  // a bit of a hack...
                                else
                                    CycleCumulative += visibility;
                            }
                        }
                    }
                    if (count >= 1)
                        break;
                }
                checked++;
                if (checked > 20)  // hacky hardcoded number
                    break;
            }
            if (Level.NetMode != NM_Standalone && bCheckPlayer)
            {
                for (candidate = Level.PawnList; candidate != None; candidate = candidate.NextPawn)
                {
                    if (PlayerPawn(candidate) == None)
                        continue;
                    bPotentialEnemy = false;
                    bValidEnemy = IsValidEnemy(candidate);
                    if (!bValidEnemy && (PotentialEnemyTimer > 0))
                        if (PotentialEnemyAlliance == candidate.Alliance)
                            bPotentialEnemy = true;
                    // a trespass grudge is confirmed only by seeing a trespasser
                    if (bPotentialEnemy && !CoopIsTrespasser(candidate) && CoopAnyTrespasser())
                        bPotentialEnemy = false;
                    if (bValidEnemy || bPotentialEnemy)
                    {
                        visibility = AICanSee(candidate, ComputeActorVisibility(candidate), true, true, true, true);
                        if (visibility > 0)
                        {
                            if (bPotentialEnemy)
                            {
                                IncreaseAgitation(candidate, 1.0);
                                PotentialEnemyAlliance = '';
                                PotentialEnemyTimer    = 0;
                                bValidEnemy = IsValidEnemy(candidate);
                            }
                            if (bValidEnemy)
                            {
                                visibility += VisibilityThreshold;
                                candidateDist = VSize(Location-candidate.Location);
                                if ((CycleCandidate == None) || (CycleDistance > candidateDist))
                                {
                                    CycleCandidate = candidate;
                                    CycleDistance  = candidateDist;
                                }
                                CycleCumulative += visibility;
                            }
                        }
                    }
                }
            }
            if (lastCycle >= CycleIndex || (Level.NetMode != NM_Standalone && CycleCumulative > 0))  // have we cycled through all actors?
            {
                cycleEnemy = CheckCycle();
                if (cycleEnemy != None)
                {
                    SetDistressTimer();
                    SetEnemy(cycleEnemy, 0, true);
                    bCanSee = true;
                }
            }
        }
        else
            bNoNegativeAlliances = True;
    }

    // Handle surprise levels...
    UpdateReactionLevel((EnemyReadiness>0)||(GetStateName()=='Seeking')||bDistressed, deltaSeconds);

    if (!bValid)
    {
        CycleCumulative = 0;
        CyclePeriod     = 0;
        CycleCandidate  = None;
        CycleDistance   = 0;
        CycleTimer      = 0;
    }

    return (bCanSee);
}

// ----------------------------------------------------------------------
// DrawShield()
// ----------------------------------------------------------------------

function DrawShield()
{
	local EllipseFX shield;

	shield = Spawn(class'EllipseFX', Self,, Location, Rotation);
	if (shield != None)
		shield.SetBase(Self);
}

function Bool HasTwoHandedWeapon()
{
	if ((Weapon != None) && (Weapon.IsA('WeaponTemporal')))
		return True;
	else
		return Super.HasTwoHandedWeapon();
}


function CheckEnemyParams(Pawn checkPawn,
                          out Pawn bestPawn, out int bestThreatLevel, out float bestDist)
{
    local ScriptedPawn sPawn;
    local bool         bReplace;
    local float        dist;
    local int          threatLevel;
    local bool         bValid;

    bValid = IsValidEnemy(checkPawn);
    if (bValid && (Enemy != checkPawn))
    {
        // Honor cloaking, radar transparency, and other augs if this guy isn't our current enemy
        if (ComputeActorVisibility(checkPawn) < 0.1)
            bValid = false;
    }

    if (bValid)
    {
        sPawn = ScriptedPawn(checkPawn);

        dist = VSize(checkPawn.Location - Location);
        if (checkPawn.IsA('Robot'))
            dist *= 0.5;  // arbitrary
        if (Enemy == checkPawn)
            dist *= 0.75;  // arbitrary

        if (sPawn != None)
        {
            if (sPawn.GetStateName() == 'StunnedTemporal')
				threatLevel = 3;
            else if (sPawn.bAttacking)
            {
                if (sPawn.Enemy == self)
                    threatLevel = 2;
                else
                    threatLevel = 1;
            }
            else if (sPawn.GetStateName() == 'Alerting')
                threatLevel = 3;
            else if ((sPawn.GetStateName() == 'Fleeing') || (sPawn.GetStateName() == 'Burning'))
                threatLevel = 0;
            else if (sPawn.Weapon != None)
                threatLevel = 1;
            else
                threatLevel = 0;
        }
        else  // player
        {
            if (checkPawn.Weapon != None)
                threatLevel = 2;
            else
                threatLevel = 1;
        }

        bReplace = false;
        if (bestPawn == None)
            bReplace = true;
        else if (bestThreatLevel < threatLevel)
            bReplace = true;
        else if (bestDist > dist)
            bReplace = true;

        if (bReplace)
        {
            if ((Enemy == checkPawn) || (AICanSee(checkPawn, , false, false, true, true) > 0))
            {
                bestPawn        = checkPawn;
                bestThreatLevel = threatLevel;
                bestDist        = dist;
            }
        }
    }
}

function AddVelocity( vector NewVelocity)
{
	if (NewVelocity == Vect(0,0,0))
		return;
	Super.AddVelocity(NewVelocity);
}

defaultproperties
{
     bEmitCarcass=True
     bRestoreOrders=True
     originalOrders=Wandering
     AugHealthLimit=-999999.000000
     Energy=150.000000
     stealthmodifier=1.000000
     breathtime=2.000000
     breathSize=1.000000
     FootstepProjectRadius=768.000000
     FootstepProjectMaxRadius=2048.000000
     bLookAtPlayer=True
     footprintoffset=8.000000
     barkPitch=1.000000
     barkPitchMin=1.000000
     barkPitchMax=1.000000
     strPassword="Password"
     strPass="Pass"
     guardChance=0.100000
     guardRadius=1800.000000
     droneRespawnTime=30.000000
     droneClass="TNMCharacters.SpydronePawn"
     blurPeriod=0.050000
     strTitlePrefix(0)="Distinguished"
     strTitlePrefix(1)="Legendary"
     strTitlePrefix(2)="Unreal"
     strTitlePrefix(3)="Mythical"
     strTitlePrefix(4)="Fabled"
     strTitlePrefix(5)="Immortal"
     strTitlePrefix(6)="Impossible"
     strTitlePrefix(7)="Inconceivable"
     strTitlePrefixImportant(0)="The Distinguished"
     strTitlePrefixImportant(1)="The Legendary"
     strTitlePrefixImportant(2)="The Unreal"
     strTitlePrefixImportant(3)="The Mythical"
     strTitlePrefixImportant(4)="The Fabled"
     strTitlePrefixImportant(5)="The Immortal"
     strTitlePrefixImportant(6)="The Impossible"
     strTitlePrefixImportant(7)="The Inconceivable"
     strTitlePrefixImportantRare(0)="The Absolutely Distinguished,"
     strTitlePrefixImportantRare(1)="The Absolute Legend,"
     strTitlePrefixImportantRare(2)="The Absolutely Unreal"
     strTitlePrefixImportantRare(3)="The Absolute, Mythical,"
     strTitlePrefixImportantRare(4)="The Absolutely Fabled"
     strTitlePrefixImportantRare(5)="The Absolute Immortal"
     strTitlePrefixImportantRare(6)="The Absolutely Impossible"
     strTitlePrefixImportantRare(7)="The Absolutely Inconceivable"
     BaseAccuracy=0.200000
     maxRange=1000.000000
     MinHealth=20.000000
     bPlayIdle=True
     bCanCrouch=True
     bSprint=True
     CrouchRate=1.000000
     SprintRate=1.000000
     bHateCarcass=True
     bReactFutz=True
     bReactLoudNoise=True
     bReactAlarm=True
     bReactShot=True
     bReactCarcass=True
     bReactDistress=True
     EnemyTimeout=5.000000
     bCanTurnHead=True
     WaterSpeed=80.000000
     AirSpeed=160.000000
     AccelRate=500.000000
     BaseEyeHeight=40.000000
     UnderWaterTime=20.000000
     AttitudeToPlayer=ATTITUDE_Ignore
     HitSound1=Sound'DeusExSounds.Player.MalePainSmall'
     HitSound2=Sound'DeusExSounds.Player.MalePainMedium'
     Die=Sound'DeusExSounds.Player.MaleDeath'
     VisibilityThreshold=0.010000
     AnimSequence=BreatheLight
     DrawType=DT_Mesh
     Mass=150.000000
     Buoyancy=155.000000
     BindName="HumanMilitary"
}

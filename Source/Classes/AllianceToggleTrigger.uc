class AllianceToggleTrigger extends Trigger;

struct InitialAllianceInfo  {
	var() Name  AllianceName;
	var() float AllianceLevel;
	var() bool  bPermanent;
};

var(AllianceEnabled) name Alliance_Enabled;
var(AllianceEnabled) InitialAllianceInfo Alliances_Enabled[8];
var(AllianceDisabled) name Alliance_Disabled;
var(AllianceDisabled) InitialAllianceInfo Alliances_Disabled[8];

//
// Set an NPCs alliances
//

function Trigger(Actor Other, Pawn Instigator)
{
	if (SetAlliancesOn())
	{
		Super.Trigger(Other, Instigator);
		if (bTriggerOnceOnly)
			Destroy();
	}
}

function UnTrigger(Actor Other, Pawn Instigator)
{
	if (SetAlliancesOff())
	{
		Super.Trigger(Other, Instigator);
		if (bTriggerOnceOnly)
			Destroy();
	}
}

singular function Touch(Actor Other)
{
	if (!IsRelevant(Other))
		return;

	if (SetAlliancesOn(Other))
		if (bTriggerOnceOnly)
			Destroy();
}

singular function UnTouch(Actor Other)
{
	if (!IsRelevant(Other))
		return;

	if (SetAlliancesOff(Other))
		if (bTriggerOnceOnly)
			Destroy();
}

// Toucher is the player walking in or out. Triggered by an event (no toucher),
// the change applies to every player. In co-op the trespass flag used to be set
// on the host only, whoever walked in.
function bool SetAlliancesOn(optional Actor Toucher)
{
	local TNMPawn P;
	local Pawn aPawn;
	local int i;

	// find the target NPC to set alliances
	if (Event != '')
		foreach AllActors (class'TNMPawn', P, Event)
			P.bHateBreakAndEnter = true;

	if (Trestkon(Toucher) != None)
		Trestkon(Toucher).bBreakAndEnter = true;
	else
		for (aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.NextPawn)
			if (Trestkon(aPawn) != None)
				Trestkon(aPawn).bBreakAndEnter = true;

	return True;
}

function bool SetAlliancesOff(optional Actor Toucher)
{
	local TNMPawn P;
	local Pawn aPawn;
	local Trestkon T;
	local int i;

	if (Trestkon(Toucher) != None)
	{
		Trestkon(Toucher).bBreakAndEnter = false;

		// someone else is still trespassing, keep the NPCs hostile to them
		foreach TouchingActors(class'Trestkon', T)
			if (T != Toucher)
				return True;
	}
	else
	{
		for (aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.NextPawn)
			if (Trestkon(aPawn) != None)
				Trestkon(aPawn).bBreakAndEnter = false;
	}

	// find the target NPC to set alliances
	if (Event != '')
		foreach AllActors (class'TNMPawn', P, Event)
			P.bHateBreakAndEnter = false;

	return True;
}

defaultproperties
{
     CollisionRadius=96.000000
}

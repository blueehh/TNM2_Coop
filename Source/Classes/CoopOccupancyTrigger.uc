//=============================================================================
// CoopOccupancyTrigger
// The Nameless Mod 2.0 - Co-op Mod by bluehh (TM)
//
// Co-op replacement for plain Triggers that drive TriggerToggle/TriggerControl/
// TriggerPound movers (tnmGameInfo.CoopReplaceTriggers). Engine Trigger fires on
// every toucher and untriggers when any toucher leaves, so with two players a
// toggle door opened and closed again, and a hold-open door closed on the
// partner still standing in it. This one only fires for the first one in and
// only releases when the last one leaves.
//=============================================================================
class CoopOccupancyTrigger extends Trigger;

function int OtherOccupants(Actor Other)
{
	local Actor A;
	local int Count;

	foreach TouchingActors(class'Actor', A)
		if ((A != Other) && IsRelevant(A))
			Count++;
	return Count;
}

function Touch(Actor Other)
{
	if (IsRelevant(Other) && (OtherOccupants(Other) > 0))
		return;
	Super.Touch(Other);
}

function UnTouch(Actor Other)
{
	if (IsRelevant(Other) && (OtherOccupants(Other) > 0))
		return;
	Super.UnTouch(Other);
}

defaultproperties
{
}

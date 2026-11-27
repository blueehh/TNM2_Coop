//=============================================================================
// CoopSkillAwardTrigger
// The Nameless Mod 2.0 - Co-op Mod by bluehh (TM)
//
// Co-op replacement for map SkillAwardTriggers (tnmGameInfo.CoopReplaceTriggers).
// The stock trigger pays only the toucher/instigator and is once-only, so the
// other player never got the points. This one pays every player.
//=============================================================================
class CoopSkillAwardTrigger extends SkillAwardTrigger;

function AwardAllPlayers()
{
	local Pawn P;

	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		if (DeusExPlayer(P) != None)
		{
			DeusExPlayer(P).SkillPointsAdd(skillPointsAdded);
			DeusExPlayer(P).ClientMessage(awardMessage);
		}
	}
}

function Trigger(Actor Other, Pawn Instigator)
{
	Super(Trigger).Trigger(Other, Instigator);

	if (DeusExPlayer(Instigator) != None)
		AwardAllPlayers();
}

function Touch(Actor Other)
{
	Super(Trigger).Touch(Other);

	if (IsRelevant(Other) && (DeusExPlayer(Other) != None))
		AwardAllPlayers();
}

defaultproperties
{
}

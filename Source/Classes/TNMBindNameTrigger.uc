Class TNMBindnameTrigger extends trigger;

var() string NewBindname;
var() bool bCheck;
var() string CheckBindName;

function trigger(actor other, pawn instigator)
{
	local ScriptedPawn P;
	local deusexplayer Player;

	foreach allactors(Class'ScriptedPawn', P, event)
	{
		if(!bCheck || P.Bindname == CheckBindName)
		{
			P.Bindname = NewBindName;
			P.ConBindEvents();

			//possibly we need to tell conplay to kill anything using our old bindname
			// (every player's conversation; was the host's only)
			foreach AllActors(class'DeusExPlayer', player)
				if (player.conPlay != None)
					player.conPlay.ActorDestroyed(P);
		}
	}

	super.trigger(other, instigator);
}

defaultproperties
{
     bCollideActors=False
}

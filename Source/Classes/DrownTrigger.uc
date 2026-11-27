class DrownTrigger extends Trigger;

var DeusExPlayer player;
var float dmgtimer;
var bool bEnabled;

function Tick(float deltaTime)
{
	if(player==None)
		player=Trestkon(GetPlayerPawn());

	if(bEnabled)
	{
		dmgtimer+=deltaTime;

		if(dmgtimer>1.0)
		{
			player.TakeDamage(10,None,vect(0,0,0),vect(0,0,0),'Drowned');
			dmgtimer=0;
		}
	}
}

function Trigger(Actor Other, Pawn Instigator)
{
	if(bEnabled)
		return;

	// drown whoever set this off; fall back to the host
	if (Trestkon(Instigator) != None)
		player = Trestkon(Instigator);
	if(player==None)
		player=Trestkon(GetPlayerPawn());

	bEnabled=true;
}

defaultproperties
{
}

class tnmComputerAPGPuzzle extends tnmComputers
	abstract;

var() name solve_event;
var() name perfect_solve_event;
var() name inefficient_solve_event;
var int attempt_count;
var bool solved;
var bool enabled;

var localized string strGeneratorsOffline, strGeneratorsOnline;

event Trigger( Actor Other, Pawn EventInstigator )
{
	if(!enabled)
		enabled=true;
}

function Frob(Actor Frobber, Inventory frobWith)
{
	if(!solved)
	{
		if(!enabled)
			DeusExPlayer(Frobber).ClientMessage(strGeneratorsOffline);
		else
			super.Frob(Frobber,frobWith);
		return;
	}
	DeusExPlayer(Frobber).ClientMessage(strGeneratorsOnline);
}

defaultproperties
{
     strGeneratorsOffline="Missing generator connection detected. Please connect all generators before proceeding."
     strGeneratorsOnline="All generators are online and linked up."
     bCanBeBase=True
     ItemName="Generator Control Terminal"
     RemoteRole=ROLE_DumbProxy
     CollisionRadius=17.750000
     CollisionHeight=17.600000
     BindName="ComputerAPGPuzzle"
     terminalTypeStr="TNMGUI.NetworkTerminalAPGPuzzle"
}

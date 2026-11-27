//=============================================================================
// tnmComputers.
//=============================================================================
class tnmComputers extends Computers;

//game stuff -Shacker
enum TNM2DGameType
{
TNM2D_None,
TNM2D_Pong,
TNM2D_Tetris,
TNM2D_Breakout,
TNM2D_LightsOut,
TNM2D_TextGame,
TNM2D_IRC,
TNM2D_FakeIRC,
TNM2D_DXIGame,
TNM2D_DXEGame,
TNM2D_ABIGame,
TNM2D_HTTP,
TNM2D_RushHour,
TNM2D_Whois,
TNM2D_Clicker
};
var() bool bHasGames;
var() TNM2DGameType games[5];
//end game stuff

var() name AttachedPrinter;

var() bool bBlackIce;
var() bool bNarcissus;
var() name NarcissusFlag;
var() bool bUsable;

var string terminalTypeStr;

struct sSpecialOptionflag
{
	var() name SpecialOptionFlag;
	var() bool bDesiredValue;
	var() bool bVisibleInactive;
};

struct sSpecialOptionlogout
{
	var() bool bLogout;
};

var(Computers) localized sSpecialOptionflag specialOptionflags[4];
var(Computers) sSpecialOptionlogout specialOptionLogout[4];

enum EComputerNodesNEW
{
CN_WCNet,
CN_WCID, //WC Intelligence Department,
CN_PDXNet,
CN_DXO, //DeusEx.org,
CN_MelkNett, //MelkNett(TM),
CN_DXI, //Deus Ex Incarnate,
CN_ABI, //Aunt Betty Industries,
CN_BettyTech,
CN_GameSpy,
CN_DXE, // DXEditing
CN_BOS, // BlueOS (non-networked)
CN_QuickStop, //From Deusex
CN_Llama,
CN_Ion 
};

var() EComputerNodesNEW ComputerNodeNEW;

var localized string strComputerBusy;

var() bool bInWorld;
var vector worldposition;
var bool bWorldCollideActors;
var bool bWorldBlockActors;
var bool bWorldBlockPlayers;

var string		accountPasswords[8];
var int lastSkillLevel;
var() class<MenuUINormalLargeTextWindow> defaultWebPage;

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
		// SetPhysics(PHYS_falling);
	}
}

simulated event PreBeginPlay()
{
	local int i;
	
	if(terminalTypeStr!="")
		terminalType=class<NetworkTerminal>(DynamicLoadObject(terminalTypeStr, class'Class'));
		
	if (!bHasGames)
	{
		for (i=0; i < arraycount(games); i++)
		{
			if (games[i] > 0)
			{
				log(Self @ "has games but bHasGames isn't set!");
				break;
			}
		}
	}
}

simulated event PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if (terminalType == None && terminalTypeStr != "")
		terminalType = class<NetworkTerminal>(DynamicLoadObject(terminalTypeStr, class'Class'));
}

// ----------------------------------------------------------------------
// PostBeginPlay()
// ----------------------------------------------------------------------

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (!bInWorld)
	{
		bInWorld = true;
		LeaveWorld();
	}
}

simulated function int NumUsers()
{
	local int i;

	for (i=0; i<ArrayCount(userList); i++)
		if (userList[i].userName == "")
			break;

	return i;
}

simulated function string GetUserName(int userIndex)
{
	if ((userIndex >= 0) && (userIndex < ArrayCount(userList)))
		return userList[userIndex].userName;

	return "ERR";
}

simulated function string GetPassword(int userIndex)
{
	if ((userIndex >= 0) && (userIndex < ArrayCount(userList)))
		return userList[userIndex].password;

	return "ERR";
}

simulated function int GetAccessLevel(int userIndex)
{
	if ((userIndex >= 0) && (userIndex < ArrayCount(userList)))
		return Int(userList[userIndex].accessLevel);

	return 0;
}

simulated function printer GetPrinter()
{
	local printer p;
	if(AttachedPrinter=='')
		return None;
	foreach AllActors(class'printer', p , AttachedPrinter)
		break;
	return p;
}

// ----------------------------------------------------------------------
// GetNodeName()
// ----------------------------------------------------------------------

simulated function String GetNodeName()
{
	return nodeInfo[Int(ComputerNodeNEW)].nodeName;
}

// ----------------------------------------------------------------------
// GetNodeDesc()
// ----------------------------------------------------------------------

simulated function String GetNodeDesc()
{
	return nodeInfo[Int(ComputerNodeNEW)].nodeDesc;
}

// ----------------------------------------------------------------------
// GetNodeAddress()
// ----------------------------------------------------------------------

simulated function String GetNodeAddress()
{
	return nodeInfo[Int(ComputerNodeNEW)].nodeAddress;
}

// ----------------------------------------------------------------------
// GetNodeTexture()
// ----------------------------------------------------------------------

simulated function Texture GetNodeTexture()
{
	return nodeInfo[Int(ComputerNodeNEW)].nodeTexture;
}


// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

simulated function clean()
{
	if (termwindow != None && termwindow.winComputer != None && (termwindow.winComputer.winStatus != None) && (termwindow.winComputer.compOwner != None) && (termwindow.winComputer.compOwner.IsA('Computers')))
		termwindow.winComputer.winStatus.SetText(tnmComputers(termwindow.winComputer.compOwner).GetNodeAddress());
}

function SpawnProduct(int index, DeusExPlayer frobber)
{
}

function CloseOut()
{
	termwindow = None;
	if (curFrobber != None)
	{
		GotoState('Off');
	}
}

function Frob(Actor Frobber, Inventory frobWith)
{
	if(!bUsable)
	{
		Trestkon(Frobber).ClientMessage(strComputerBusy);
		return;
	}

	if (curFrobber != None && (curFrobber.bDeleteMe || curFrobber.ActiveComputer != Self))
	{
		curFrobber = None;
		termwindow = None;
		bOn = False;
		GotoState('Off');
	}

	super.Frob(Frobber,frobWith);
}

state On
{
	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);

		if (bOn)
		{
			if ((termwindow == None) && (Level.NetMode == NM_Standalone))
			{
				GotoState('Off');
			}            
			if (curFrobber == None)
			{
				GotoState('Off');
			}
			else if (VSize(curFrobber.Location - Location) > 1500)
			{
				log("Disabling computer "$Self$" because user "$curFrobber$" was too far away");
				//Probably should be "GotoState('Off')" instead, but no good way to test, so I'll leave it alone.
				curFrobber = None;
			}
		}
	}

Begin:
	if (!bOn)
	{
		AdditionalActivation(curFrobber);
		if (HasAnim('Activate'))
		{
			bAnimating = True;
			if (IsA('MyComputerSecurity'))
				PlayAnim('Activate', 3.0);
			else
				PlayAnim('Activate');
			FinishAnim();
		}
		bOn = True;
		bAnimating = False;
		ChangePlayerVisibility(False);
		TryInvoke();
	}
}

auto state Off
{
Begin:
	if (bOn)
	{
		AdditionalDeactivation(curFrobber);
		ChangePlayerVisibility(True);
		if (Mesh != None && HasAnim('Deactivate'))
		{
			bAnimating = True;
			if (IsA('MyComputerSecurity'))
				PlayAnim('Deactivate', 3.0);
			else
				PlayAnim('Deactivate');
			FinishAnim();
		}
		bOn = False;
		bAnimating = False;
		if (bLockedOut)
			BeginAlarm();

		// Resume any datalinks that may have started while we were 
		// in the computers (don't want them to start until we pop back out)
		ResumeDataLinks();
		curFrobber = None;
	}
}

defaultproperties
{
     bUsable=True
     specialOptionflags(0)=(bDesiredValue=True)
     specialOptionflags(1)=(bDesiredValue=True)
     specialOptionflags(2)=(bDesiredValue=True)
     specialOptionflags(3)=(bDesiredValue=True)
     strComputerBusy="This machine is being used by someone else."
     bInWorld=True
     TextPackage="tnmText"
     NodeInfo(0)=(nodeName="WCNet",nodeDesc="WCNet",nodeAddress="Narcissus:GlobalNode:GameSpy//WCNET//NODE.34@778/Login",nodeTexture=Texture'TNM.Nodes.NodeWC')
     NodeInfo(1)=(nodeName="WCID",nodeDesc="WC Intelligence Department",nodeAddress="Narcissus:GlobalNode:GameSpy//WCNET//NODE.34@778/Login",nodeTexture=Texture'TNM.Nodes.NodeWCID')
     NodeInfo(2)=(nodeName="PDXNet",nodeDesc="PDXNet",nodeAddress="Narcissus:GlobalNode:GameSpy//PDXNET//NODE.65@435/Login",nodeTexture=Texture'TNM.Nodes.NodePDX')
     NodeInfo(3)=(nodeName="DeusEx.org",nodeDesc="DeusEx.org",nodeAddress="Narcissus:GlobalNode:GameSpy//DXO//NODE.13@468/Login",nodeTexture=Texture'TNM.Nodes.NodeDXO')
     NodeInfo(4)=(nodeName="MelkNett(TM)",nodeDesc="MelkNett(TM)",nodeAddress="Narcissus:GlobalNode:GameSpy//MELKNET//NODE.78@793/Login",nodeTexture=Texture'TNM.Nodes.Nodemelknett')
     NodeInfo(5)=(nodeName="Deus Ex Incarnate",nodeDesc="Deus Ex Incarnate",nodeAddress="Narcissus:GlobalNode:GameSpy//DXI//NODE.44@156/Login",nodeTexture=Texture'TNM.Nodes.NodeDXI')
     NodeInfo(6)=(nodeName="Aunt Betty Industries",nodeDesc="Aunt Betty Industries",nodeAddress="Narcissus:GlobalNode:GameSpy//ABI//NODE.69@235/Login",nodeTexture=Texture'TNM.Nodes.NodeABI')
     NodeInfo(7)=(nodeName="Aunt Betty Technologies",nodeDesc="Aunt Betty Technologies",nodeAddress="Narcissus:GlobalNode:GameSpy//ABI//NODE.69@235/Login",nodeTexture=Texture'TNM.Nodes.NodeBettyTech')
     NodeInfo(8)=(nodeName="GameSpy",nodeDesc="GameSpy",nodeAddress="Narcissus:GlobalNode:GameSpy//GS//NODE.22@756/Login",nodeTexture=Texture'TNM.Nodes.NodeGS')
     NodeInfo(9)=(nodeName="DXEditing",nodeDesc="DXEditing",nodeAddress="Narcissus:GlobalNode:GameSpy//DXE//NODE.89@274/Login",nodeTexture=Texture'TNM.Nodes.NodeDXE')
     NodeInfo(10)=(nodeName="BlueOS",nodeDesc="Local Machine (no network detected)",nodeAddress="LocalMachine//system/bluekernel/interface/Login",nodeTexture=Texture'TNM.Nodes.NodeBOS')
     NodeInfo(11)=(nodeName="Quick Stop",nodeDesc="Quick Stop",nodeAddress="Narcissus:GlobalNode:GameSpy//QUICKSTOP//NODE.77@081/Login",nodeTexture=Texture'DeusExUI.UserInterface.ComputerLogonLogoQuickStop')
     NodeInfo(12)=(nodeName="Lamar's Grace",nodeDesc="Holy Llama Security",nodeAddress="Narcissus:GlobalNode:GameSpy//LlamaSEC//NODE.79@007/Login",nodeTexture=Texture'TNM.Nodes.NodeLlama')
     NodeInfo(13)=(nodeName="Ion Storm",nodeDesc="Ion Storm Offices",nodeAddress="Narcissus:GlobalNode:GameSpy//IonStorm//NODE.00@451/Login",nodeTexture=Texture'TNM.Nodes.NodeIS')
     bNoDelete=True
     RemoteRole=ROLE_SimulatedProxy
}

//=============================================================================
// MyComputerSecurity.
//=============================================================================
class MyComputerSecurity extends tnmComputers;

struct sViewInfo
{
	var() localized string	titleString;
	var() name				cameraTag;
	var() name				turretTag;
	var() name				doorTag;
};

var() sViewInfo Views[3];
/*
function PostPostBeginPlay()
{
	local int i;
	local name tag;
	local SecurityCamera camera;
	local AutoTurret turret;
	local DeusExMover door;
	
	for (i=0;i<3;i++)
	{
		camera = None;
		tag = Views[i].cameraTag;
		if (tag != '')
		{
			foreach AllActors(class'SecurityCamera', camera, tag)
			{
				break;
			}
		}
		if (tag != '' && camera == None)
		{
			Log(Self @ "has cameratag" @ Views[i].cameraTag @ "but camera could not be found!");
		}

		turret = None;
		tag = Views[i].turretTag;
		if (tag != '')
			foreach AllActors(class'AutoTurret', turret, tag)
			{
				break;
			}
		if (tag != '' && turret == None)
		{
			Log(Self @ "has turretTag" @ Views[i].turretTag @ "but turret could not be found!");
		}

		door = None;
		tag = Views[i].doorTag;
		if (tag != '')
			foreach AllActors(class'DeusExMover', door, tag)
			{
				break;
			}
		if (tag != '' && door == None)
		{
			Log(Self @ "has doorTag" @ Views[i].doorTag @ "but door could not be found!");
		}
	}
}
*/

defaultproperties
{
     lockoutDelay=120.000000
     UserList(0)=(userName="SECURITY",Password="SECURITY")
     ItemName="Security Computer Terminal"
     RemoteRole=ROLE_DumbProxy
     Mesh=LodMesh'DeusExDeco.ComputerSecurity'
     SoundRadius=8
     SoundVolume=255
     SoundPitch=96
     AmbientSound=Sound'DeusExSounds.Generic.SecurityL'
     CollisionRadius=11.590000
     CollisionHeight=10.100000
     BindName="ComputerSecurity"
     terminalTypeStr="TNMGUI.tnmNetworkTerminalSecurity"
     Physics=PHYS_None
     bCollideWorld=False
}

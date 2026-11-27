//=============================================================================
// YuukaReviveTotem
// The Nameless Mod 2.0 - Co-op Mod by bluehh (TM)
//
// Co-op downed teammate beacon, direct frob-to-revive totem, and YuukaPlushMesh
// 3D mesh/texture asset importer.
//=============================================================================
class YuukaReviveTotem extends DeusExDecoration;

#ForceExec TEXTURE IMPORT NAME=YuukaPlushTex0 FILE=Textures\Skins\YuukaPlushTex0.pcx GROUP=Skins
#ForceExec TEXTURE IMPORT NAME=YuukaPlushTex1 FILE=Textures\Skins\YuukaPlushTex1.pcx GROUP=Skins
#ForceExec TEXTURE IMPORT NAME=YuukaPlushTex2 FILE=Textures\Skins\YuukaPlushTex2.pcx GROUP=Skins
#ForceExec TEXTURE IMPORT NAME=YuukaPlushTex3 FILE=Textures\Skins\YuukaPlushTex3.pcx GROUP=Skins
#ForceExec TEXTURE IMPORT NAME=YuukaPlushTex4 FILE=Textures\Skins\YuukaPlushTex4.pcx GROUP=Skins
#ForceExec TEXTURE IMPORT NAME=YuukaPlushTex5 FILE=Textures\Skins\YuukaPlushTex5.pcx GROUP=Skins
#ForceExec TEXTURE IMPORT NAME=YuukaPlushTex6 FILE=Textures\Skins\YuukaPlushTex6.pcx GROUP=Skins
#ForceExec TEXTURE IMPORT NAME=YuukaPlushTex7 FILE=Textures\Skins\YuukaPlushTex7.pcx GROUP=Skins

#ForceExec MESH IMPORT MESH=YuukaPlushMesh ANIVFILE=Models\YuukaPlush_a.3d DATAFILE=Models\YuukaPlush_d.3d MLOD=0
#ForceExec MESH ORIGIN MESH=YuukaPlushMesh X=0 Y=0 Z=0 YAW=0
#ForceExec MESH SEQUENCE MESH=YuukaPlushMesh SEQ=All     STARTFRAME=0 NUMFRAMES=2
#ForceExec MESH SEQUENCE MESH=YuukaPlushMesh SEQ=Still   STARTFRAME=0 NUMFRAMES=1
#ForceExec MESH SEQUENCE MESH=YuukaPlushMesh SEQ=Squeeze STARTFRAME=0 NUMFRAMES=2 RATE=4.0
#ForceExec MESH SEQUENCE MESH=YuukaPlushMesh SEQ=Attack  STARTFRAME=0 NUMFRAMES=2 RATE=4.0
#ForceExec MESH SEQUENCE MESH=YuukaPlushMesh SEQ=Shoot   STARTFRAME=0 NUMFRAMES=2 RATE=4.0
#ForceExec MESH SEQUENCE MESH=YuukaPlushMesh SEQ=Select  STARTFRAME=0 NUMFRAMES=2 RATE=4.0
#ForceExec MESH SEQUENCE MESH=YuukaPlushMesh SEQ=Down    STARTFRAME=0 NUMFRAMES=1
#ForceExec MESH SEQUENCE MESH=YuukaPlushMesh SEQ=Idle1   STARTFRAME=0 NUMFRAMES=1
#ForceExec MESH SEQUENCE MESH=YuukaPlushMesh SEQ=Idle2   STARTFRAME=0 NUMFRAMES=1
#ForceExec MESH SEQUENCE MESH=YuukaPlushMesh SEQ=Idle3   STARTFRAME=0 NUMFRAMES=1

#ForceExec MESHMAP NEW MESHMAP=YuukaPlushMesh MESH=YuukaPlushMesh
#ForceExec MESHMAP SCALE MESHMAP=YuukaPlushMesh X=0.00390625 Y=0.00390625 Z=0.00390625
#ForceExec MESHMAP SETTEXTURE MESHMAP=YuukaPlushMesh NUM=0 TEXTURE=YuukaPlushTex0
#ForceExec MESHMAP SETTEXTURE MESHMAP=YuukaPlushMesh NUM=1 TEXTURE=YuukaPlushTex1
#ForceExec MESHMAP SETTEXTURE MESHMAP=YuukaPlushMesh NUM=2 TEXTURE=YuukaPlushTex2
#ForceExec MESHMAP SETTEXTURE MESHMAP=YuukaPlushMesh NUM=3 TEXTURE=YuukaPlushTex3
#ForceExec MESHMAP SETTEXTURE MESHMAP=YuukaPlushMesh NUM=4 TEXTURE=YuukaPlushTex4
#ForceExec MESHMAP SETTEXTURE MESHMAP=YuukaPlushMesh NUM=5 TEXTURE=YuukaPlushTex5
#ForceExec MESHMAP SETTEXTURE MESHMAP=YuukaPlushMesh NUM=6 TEXTURE=YuukaPlushTex6
#ForceExec MESHMAP SETTEXTURE MESHMAP=YuukaPlushMesh NUM=7 TEXTURE=YuukaPlushTex7

var Carcass LinkedCarcass;
var trestkon LinkedPlayer;
var float BobTime;

replication
{
    reliable if (Role == ROLE_Authority)
        LinkedCarcass, LinkedPlayer;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    LoopAnim('Squeeze', 1.0, 0.1);
}

simulated event Tick(float deltaTime)
{
    local rotator R;
    local vector TargetLoc;

    Super.Tick(deltaTime);

    if (Role == ROLE_Authority)
    {
        if ((LinkedCarcass == None || LinkedCarcass.bDeleteMe) &&
            (LinkedPlayer == None || !LinkedPlayer.IsInState('Dying')))
        {
            Destroy();
            return;
        }
    }

    BobTime += deltaTime;
    R = Rotation;
    R.Yaw += int(18000.0 * deltaTime);
    SetRotation(R);

    if (LinkedCarcass != None && !LinkedCarcass.bDeleteMe)
    {
        TargetLoc = LinkedCarcass.Location + vect(0, 0, 32);
        TargetLoc.Z += Sin(BobTime * 3.5) * 3.0;
        SetLocation(TargetLoc);
    }
}

function Frob(Actor Frobber, Inventory frobWith)
{
    local trestkon P, DeadP;
    local MedKit med;

    P = trestkon(Frobber);
    if (P == None)
        return;

    // If the frobber is currently carrying the body, Right-Clicking drops the body!
    if (LinkedCarcass != None && P.CarriedDecoration == LinkedCarcass)
    {
        P.DropDecoration();
        return;
    }

    DeadP = LinkedPlayer;
    if (DeadP == None || !DeadP.IsInState('Dying'))
    {
        foreach AllActors(class'trestkon', DeadP)
        {
            if (DeadP != P && DeadP.IsInState('Dying'))
                break;
        }
    }

    if (DeadP != None && DeadP.IsInState('Dying'))
    {
        med = MedKit(P.FindInventoryType(class'MedKit'));
        if (med != None)
        {
            P.CoopReviveTeammate(DeadP, LinkedCarcass);
            med.NumCopies--;
            if (med.NumCopies <= 0)
            {
                if (P.inHand == med)
                    P.PutInHand(None);
                P.RemoveObjectFromBelt(med);
                P.DeleteInventory(med);
                med.Destroy();
            }
            Destroy();
            return;
        }
        else
        {
            PlaySound(Sound'TNM.CoopPingSound', SLOT_None, 0.60, , 512.0);
            P.ClientMessage("You need a Medkit to revive " $ DeadP.GetCoopPlayerName() $ "!");
            return;
        }
    }

    if (LinkedCarcass != None && !LinkedCarcass.bDeleteMe)
        LinkedCarcass.Frob(Frobber, frobWith);
}

defaultproperties
{
     ItemName="Yuuka Revive Totem (Right-Click with Medkit to Revive)"
     bInvincible=True
     bPushable=False
     bCanBeBase=False
     Physics=PHYS_None
     DrawType=DT_Mesh
     Mesh=Mesh'TNM.YuukaPlushMesh'
     DrawScale=1.150000
     bUnlit=True
     RemoteRole=ROLE_SimulatedProxy
     bAlwaysRelevant=True
     CollisionRadius=18.000000
     CollisionHeight=18.000000
     bCollideActors=True
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     MultiSkins(0)=Texture'TNM.Skins.YuukaPlushTex0'
     MultiSkins(1)=Texture'TNM.Skins.YuukaPlushTex1'
     MultiSkins(2)=Texture'TNM.Skins.YuukaPlushTex2'
     MultiSkins(3)=Texture'TNM.Skins.YuukaPlushTex3'
     MultiSkins(4)=Texture'TNM.Skins.YuukaPlushTex4'
     MultiSkins(5)=Texture'TNM.Skins.YuukaPlushTex5'
     MultiSkins(6)=Texture'TNM.Skins.YuukaPlushTex6'
     MultiSkins(7)=Texture'TNM.Skins.YuukaPlushTex7'
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=140
     LightHue=155
     LightSaturation=80
     LightRadius=5
}

//=============================================================================
// YuukaHeadCompanion
// The Nameless Mod 2.0 - Co-op Mod by bluehh (TM)
//
// Mini 3D Yuuka Plush head-mounted companion hat rendered on third-person pawns.
//=============================================================================
class YuukaHeadCompanion extends Actor;

var float BobTime;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    LoopAnim('Squeeze', 0.8, 0.1);
}

simulated event Tick(float deltaTime)
{
    local vector HeadLoc;
    local rotator HeadRot;
    local PlayerPawn PP;

    Super.Tick(deltaTime);

    if (Owner == None || Owner.bDeleteMe)
    {
        if (Role == ROLE_Authority)
            Destroy();
        return;
    }

    if (Owner.IsInState('Dying') || Owner.bHidden)
    {
        bHidden = True;
        return;
    }

    bHidden = False;
    PP = PlayerPawn(Owner);
    if (PP != None)
        bOwnerNoSee = !PP.bBehindView;

    BobTime += deltaTime;
    HeadLoc = Owner.Location;
    HeadLoc.Z += Owner.CollisionHeight + 4.0 + Sin(BobTime * 3.0) * 0.75;
    SetLocation(HeadLoc);

    HeadRot = Owner.Rotation;
    HeadRot.Pitch = 0;
    HeadRot.Roll = 0;
    SetRotation(HeadRot);
}

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=Mesh'TNM.YuukaPlushMesh'
     DrawScale=0.450000
     bUnlit=True
     Physics=PHYS_None
     RemoteRole=ROLE_SimulatedProxy
     bAlwaysRelevant=True
     bOwnerNoSee=True
     bCollideActors=False
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
}

//=============================================================================
// YuukaPingMarker
// The Nameless Mod 2.0 - Co-op Mod by bluehh (TM)
//
// 3D Yuuka Plush world ping beacon spawned when a player triggers CoopPing.
//=============================================================================
class YuukaPingMarker extends Actor;

var vector BaseLocation;
var float BobTime;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    BaseLocation = Location + vect(0, 0, 14);
    SetLocation(BaseLocation);
    PlayAnim('Squeeze', 2.0, 0.1);
}

simulated event Tick(float deltaTime)
{
    local rotator R;
    local vector NewLoc;

    Super.Tick(deltaTime);

    BobTime += deltaTime;
    R = Rotation;
    R.Yaw += int(24000.0 * deltaTime);
    SetRotation(R);

    NewLoc = BaseLocation;
    NewLoc.Z += Sin(BobTime * 4.0) * 4.0;
    SetLocation(NewLoc);

    if (!IsAnimating())
        LoopAnim('Squeeze', 1.2, 0.1);
}

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=Mesh'TNM.YuukaPlushMesh'
     DrawScale=0.850000
     bUnlit=True
     LifeSpan=7.000000
     RemoteRole=ROLE_SimulatedProxy
     bNetTemporary=False
     bAlwaysRelevant=True
     Physics=PHYS_None
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
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=128
     LightHue=155
     LightSaturation=90
     LightRadius=4
}

//=============================================================================
// CoopTurretSafeTarget
// The Nameless Mod 2.0 - Co-op Mod by bluehh (TM)
//
// Placeholder AutoTurret.safeTarget for co-op (see tnmGameInfo.CoopUpdateTurrets).
// AutoTurret.Tick disables any turret without a safeTarget in netgames. This
// pawn is never added to the PawnList, can't be seen, hit or targeted, and is
// not a valid enemy (no health, bIgnore) when turrets pass it as the attacker.
//=============================================================================
class CoopTurretSafeTarget extends Pawn;

event PreBeginPlay()
{
}

event PostBeginPlay()
{
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
}

defaultproperties
{
     Health=0
     bHidden=True
     bDetectable=False
     bIgnore=True
     Visibility=0
     Physics=PHYS_None
     RemoteRole=ROLE_None
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}

//=============================================================================
// CoopExplosionLight
// The Nameless Mod 2.0 - Co-op Mod by bluehh (TM)
//
// Client-safe simulated dynamic explosion flash light (stock ExplosionLight's
// Timer() is non-simulated so it never ticks or fades on NM_Client).
//=============================================================================
class CoopExplosionLight extends ExplosionLight;

simulated function Timer()
{
	if (size > 0)
	{
		LightRadius = Clamp(size, 1, 16);
		size = -1;
	}

	LightRadius--;
	if (LightRadius < 1)
		Destroy();
}

defaultproperties
{
	RemoteRole=ROLE_None
}

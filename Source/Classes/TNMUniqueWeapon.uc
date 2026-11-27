//=============================================================================
// TNMUniqueWeapon.
//=============================================================================
class TNMUniqueWeapon extends TNMWeapon
	abstract;

var() int AccuracyMods;
var() int ClipMods;
var() int ReloadMods;
var() int RecoilMods;
var() int RangeMods;
var class<inventory> genericVersion;

function prebeginplay()
{
	local int i;
	super.prebeginplay();

	for ( i = AccuracyMods ; i > 0; i--)
	{
		addmod( class'weaponmodaccuracy');
	}


	for ( i = ClipMods ; i > 0; i--)
	{
		addmod( class'weaponmodclip');
	}


	for ( i = ReloadMods ; i > 0; i--)
	{
		addmod( class'weaponmodreload');
	}


	for ( i = RecoilMods ; i > 0; i--)
	{
		addmod( class'weaponmodrecoil');
	}


	for ( i = RangeMods ; i > 0; i--)
	{
		addmod( class'weaponmodrange');
	}
}

function addmod( class<weaponmod> mod )
{
	local WeaponMod wm;

	wm = spawn(mod, self);

	wm.ApplyMod(self);
        wm.DestroyMod();
}

function GiveTo( pawn Other )
{
	local trestkon t;
	t=trestkon(other);
	if(t!=none)
	{
		t.flagbase.setbool(t.rootwindow.stringtoname("GOT_"$class.name),true,,0);
	}
	super.giveto(other);
}

defaultproperties
{
}

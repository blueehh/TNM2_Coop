class tnmmissionbonus extends tnmmissionscript;

function ShowCheatList()
{
	local DeusExRootWindow root;

	root = DeusExRootWindow(player.rootWindow);

	if (root != None)
		root.InvokeMenuScreen(Class'CheatListWindow', false);
		
	trestkon(getplayerpawn()).bUnlockedTrack121 = true;
	trestkon(getplayerpawn()).bUnlockedTrack123 = true;
	trestkon(getplayerpawn()).SaveConfig();
}

function firstframe()
{
	local PlayerStart PS;
	local Inventory Inv;
	
    super.firstframe();
	foreach AllActors(class'PlayerStart', PS)
	{
		Trestkon(GetPlayerPawn()).xAxis = PS.Location.X;
		Trestkon(GetPlayerPawn()).yAxis = PS.Location.Y;
	}
    trestkon(getplayerpawn()).platform(true);
		
	trestkon(getplayerpawn()).bUnlockedTrack97 = true;
	trestkon(getplayerpawn()).bUnlockedTrack98 = true;
	trestkon(getplayerpawn()).SetPropertyText(localURL $ "_Unlocked", "True");
	trestkon(getplayerpawn()).SaveConfig();
	
	foreach AllActors(class'Inventory', inv)
	{
		if (TNMWeapon(inv) != None)
		{
			if (TNMWeapon(inv).Owner == None)
			{
				// Inv.SetLocation(Inv.OldLocation);
				// Inv.SetPhysics(PHYS_None);
				Inv.Velocity = Vect(0,0,0);
				TNMWeapon(inv).bRadishHover = True;
				Inv.SetPhysics(PHYS_Rotating);
				Inv.bFixedRotationDir = True;
				Inv.RotationRate.Yaw = 32768;
				Inv.bUnlit = True;
				Inv.AmbientGlow = 255;
			}
		}
		else if (Ammo(inv) != None)
		{
			if (Ammo(inv).Owner == None)
			{
				// Inv.SetLocation(Inv.OldLocation);
				// Inv.SetPhysics(PHYS_None);
				Inv.Velocity = Vect(0,0,0);
				Inv.SetPhysics(PHYS_Rotating);
				Inv.bFixedRotationDir = True;
				Inv.RotationRate.Yaw = 32768;
				Inv.bUnlit = True;
				Inv.AmbientGlow = 255;
			}
		}
	}
}

function HandleGameEvent(name scriptFunction)
{
	switch ( scriptfunction)
	{
		// Platform game
		case 'ShowCheatList'		: ShowCheatList(); break;
	}
}

defaultproperties
{
     RemoteRole=ROLE_DumbProxy
}

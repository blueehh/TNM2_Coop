//=============================================================================
// TrestkonCarcass.
// auth: aUnt beTty
//=============================================================================
class TrestkonCarcass extends TNMCarcass;

var bool bBloodHead;

// ----------------------------------------------------------------------
// PostPostBeginPlay()
// ----------------------------------------------------------------------

function PostPostBeginPlay()
{
	local trestkon player, p;
	local float bestDist, d;
	local YuukaReviveTotem totem;

	Super.PostPostBeginPlay();

	bestDist = 999999.0;
	foreach AllActors(class'trestkon', p)
	{
		d = VSize(p.Location - Location);
		if (player == None || d < bestDist)
		{
			player = p;
			bestDist = d;
		}
	}

	if (player != None)
	{
		bBloodHead = player.bInsaneDeath;
		SetSkin(player);
	}

	if (Level.NetMode != NM_Standalone)
	{
		totem = Spawn(class'YuukaReviveTotem', Self, , Location + vect(0, 0, 26), Rotation);
		if (totem != None)
		{
			totem.LinkedCarcass = Self;
			totem.LinkedPlayer = player;
		}
	}
}

// ----------------------------------------------------------------------
// SetSkin()
// ----------------------------------------------------------------------

simulated function SetSkin(DeusExPlayer player)
{
	local int i;
	local String meshName;
	local LodMesh customCarc, customCarcB, customCarcC;

	if (player != None)
	{
		if (player.Mesh == LodMesh'TNM.GM_Trenchkon' || player.playerSkin >= 18)
		{
			Mesh2 = LodMesh'tnm.GM_Trenchkon_CarcassB';
			Mesh3 = LodMesh'tnm.GM_Trenchkon_CarcassC';
			Mesh  = LodMesh'tnm.GM_Trenchkon_Carcass';
		}
		else if (player.Mesh != None && player.Mesh != LodMesh'TNM.GM_Trestkon_Jumpsuit')
		{
			meshName = String(player.Mesh.Name);
			customCarc  = LodMesh(DynamicLoadObject("DeusExCharacters." $ meshName $ "_Carcass", class'LodMesh'));
			customCarcB = LodMesh(DynamicLoadObject("DeusExCharacters." $ meshName $ "_CarcassB", class'LodMesh'));
			customCarcC = LodMesh(DynamicLoadObject("DeusExCharacters." $ meshName $ "_CarcassC", class'LodMesh'));
			if (customCarc != None)
			{
				Mesh  = customCarc;
				if (customCarcB != None)
					Mesh2 = customCarcB;
				else
					Mesh2 = customCarc;
				if (customCarcC != None)
					Mesh3 = customCarcC;
				else
					Mesh3 = customCarc;
			}
		}

		if (player.AnimSequence == 'DeathFront')
			Mesh = Mesh2;

		// use the correct mesh
		if (Region.Zone.bWaterZone)
			Mesh = Mesh3;

		Skin = player.Skin;
		Texture = player.Texture;
		for (i=0;i<8;i++)
			MultiSkins[i] = player.Multiskins[i];
	}
}

//just to move the blood splat up to his head
auto state Dead
{
	function HandleLanding()
	{
		local Vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
		local Actor hit;
		local BloodPool pool;

		if (!bNotDead)
		{
			// trace down about 20 feet if we're not in water
			if (!Region.Zone.bWaterZone)
			{
				StartTrace = Location;

				if(bBloodHead)
				{
					GetAxes(Rotation,X,Y,Z);
					StartTrace += X * CollisionRadius;
				}
				
				EndTrace = StartTrace - vect(0,0,320);
				hit = Trace(HitLocation, HitNormal, EndTrace, StartTrace, False);
				pool = spawn(class'BloodPool',,, HitLocation+HitNormal, Rotator(HitNormal));
				if (pool != None)
				{
					if(bBloodHead)
						pool.maxDrawScale = CollisionRadius / 40.0 * 0.25;
					else
						pool.maxDrawScale = CollisionRadius / 40.0;
				}
			}

			// alert NPCs that I'm food
			AIStartEvent('Food', EAITYPE_Visual);
		}

		// by default, the collision radius is small so there won't be as
		// many problems spawning carcii
		// expand the collision radius back to where it's supposed to be
		// don't change animal carcass collisions
		if (!bAnimalCarcass)
			SetCollisionSize(40.0, Default.CollisionHeight);

		// alert NPCs that I'm really disgusting
		if (bEmitCarcass)
			AIStartEvent('Carcass', EAITYPE_Visual);
	}
}

defaultproperties
{
     Mesh2=LodMesh'TNM.GM_Trestkon_Jumpsuit_CarcassB'
     Mesh3=LodMesh'TNM.GM_Trestkon_Jumpsuit_CarcassC'
     Texture=Texture'DeusExItems.Skins.PinkMaskTex'
     Mesh=LodMesh'TNM.GM_Trestkon_Jumpsuit_Carcass'
     MultiSkins(0)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(1)=Texture'TNM.Skins.TrestkonTex2'
     MultiSkins(2)=Texture'TNM.Skins.TrestkonTex1'
     MultiSkins(3)=Texture'TNM.Skins.TrestkonTex0'
     MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(5)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(6)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
     CollisionRadius=44.000000
     CollisionHeight=7.700000
     bAlwaysRelevant=True
}

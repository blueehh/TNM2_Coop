class TresktonCarcass extends TNMCarcass;

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
		SetSkin(player);

	totem = Spawn(class'YuukaReviveTotem', Self, , Location + vect(0, 0, 26), Rotation);
	if (totem != None)
	{
		totem.LinkedCarcass = Self;
		totem.LinkedPlayer = player;
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

		Skin = player.Skin;
		Texture = player.Texture;
		for (i=0;i<8;i++)
			MultiSkins[i] = player.Multiskins[i];
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
}

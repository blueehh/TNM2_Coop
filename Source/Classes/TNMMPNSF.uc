//=============================================================================
// MPNSF
//=============================================================================
class TNMMPNSF extends Trestkon;

// ----------------------------------------------------------------------
// TravelPostAccept()
// ----------------------------------------------------------------------

event TravelPostAccept()
{
	local DeusExLevelInfo info;

	Super.TravelPostAccept();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     CarcassType=Class'DeusEx.TerroristCarcass'
     Mesh=LodMesh'MPCharacters.mp_jumpsuit'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.TerroristTex0'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.TerroristTex2'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.TerroristTex1'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.TerroristTex0'
     MultiSkins(4)=Texture'DeusExCharacters.Skins.TerroristTex0'
     MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(6)=Texture'DeusExCharacters.Skins.GogglesTex1'
}

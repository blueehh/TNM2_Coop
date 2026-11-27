class tnmWeaponBlood extends Effects
	abstract;

var float bloodAmt;

function Tick(float deltaTime)
{
	super.Tick(deltaTime);

	if(Owner==None)
	{
		Destroy();
		return;
	}

	if(Mesh!=Owner.Mesh)
	{
		Mesh = Owner.Mesh;
		DrawScale = Owner.DrawScale + 0.01;
	}


	if(PrePivot!=Owner.PrePivot)
		PrePivot=Owner.PrePivot;

	bHidden=
		TNMWeapon(Owner)==None ||
		Mesh==TNMWeapon(Owner).PlayerViewMesh ||
		TNMWeapon(Owner).Bloodiness<bloodAmt;
}

simulated function PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay();

	if (Owner == None)
		return;

	Mesh = Owner.Mesh;
	DrawScale = Owner.DrawScale + 0.01;

	for(i=0;i<8;i++)
		MultiSkins[i]=Texture;
		
	if (Owner.IsA('WeaponFireBlade'))
		MultiSkins[3] = Texture'PinkMaskTex';

//	Texture=Owner.Texture;
	bTrailerSameRotation = true;
	bAnimByOwner = true;

	SetBase(Owner);
}

defaultproperties
{
     bHidden=True
     bTravel=True
     Physics=PHYS_Trailer
     DrawType=DT_Mesh
     Style=STY_Modulated
     ScaleGlow=0.700000
     bUnlit=True
}

//=============================================================================
// SkillManager
//=============================================================================
class tnmSkillManager extends SkillManager
	;//intrinsic;

simulated function Skill GetSkillFromClass(class SkillClass)
{
	local Skill aSkill;

	aSkill = FirstSkill;
	while(aSkill != None)
	{
		if ((aSkill.Class == SkillClass) || ClassIsChildOf( aSkill.Class, SkillClass ))
			break;

		aSkill = aSkill.next;
	}

	return aSkill;
}


simulated function float GetSkillLevelValue(class SkillClass)
{
	if (skillclass == class'skillswimming')
		return 1.500000;
	else
		return super.GetSkillLevelValue(skillclass);
}

simulated function RestoreSinglePlayerSkillStats()
{
	local Skill aSkill;

	aSkill = FirstSkill;
	while (aSkill != None)
	{
		aSkill.SkillName = aSkill.Default.SkillName;
		aSkill.Cost[0] = aSkill.Default.Cost[0];
		aSkill.Cost[1] = aSkill.Default.Cost[1];
		aSkill.Cost[2] = aSkill.Default.Cost[2];
		aSkill.LevelValues[0] = aSkill.Default.LevelValues[0];
		aSkill.LevelValues[1] = aSkill.Default.LevelValues[1];
		aSkill.LevelValues[2] = aSkill.Default.LevelValues[2];
		aSkill.LevelValues[3] = aSkill.Default.LevelValues[3];
		if (Role == ROLE_Authority)
			aSkill.SetOwner(Self);
		aSkill = aSkill.next;
	}
}

function CreateSkills(DeusExPlayer newPlayer)
{
	Super.CreateSkills(newPlayer);
	RestoreSinglePlayerSkillStats();
}

function SetPlayer(DeusExPlayer newPlayer)
{
	Super.SetPlayer(newPlayer);
	RestoreSinglePlayerSkillStats();
}

simulated event PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	RestoreSinglePlayerSkillStats();
}

defaultproperties
{
     skillClasses(1)=Class'TNM.TNMSkillWeaponPistol'
     skillClasses(4)=Class'TNM.tnmSkillDemolition'
     skillClasses(5)=Class'TNM.SkillWeaponFists'
     skillClasses(6)=Class'DeusEx.SkillEnviro'
     skillClasses(7)=Class'DeusEx.SkillLockpicking'
     skillClasses(8)=Class'DeusEx.SkillTech'
     skillClasses(9)=Class'TNM.TNMSkillMedicine'
     skillClasses(10)=Class'DeusEx.SkillComputer'
}

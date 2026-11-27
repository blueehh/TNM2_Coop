class SkillWeaponFists extends Skill;

var int mpCost1;
var int mpCost2;
var int mpCost3;
var float mpLevel0;
var float mpLevel1;
var float mpLevel2;
var float mpLevel3;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( False && Level.NetMode != NM_Standalone )
	{
		cost[0] = mpCost1;
		cost[1] = mpCost2;
		cost[2] = mpCost3;
		LevelValues[0] = mpLevel0;
		LevelValues[1] = mpLevel1;
		LevelValues[2] = mpLevel2;
		LevelValues[3] = mpLevel3;
	}
}

defaultproperties
{
     mpCost1=1000
     mpCost2=1000
     mpCost3=1000
     mpLevel1=-0.100000
     mpLevel2=-0.300000
     mpLevel3=-0.500000
     SkillName="Weapons: Fists"
     Description="The ability to utilize your own hands as lethal weapons. An agent who masters this discipline could theoretically take on several heavily armed opponents unarmed.|n|nUNTRAINED: An agent knows how to take care of himself in a fair fight.|n|nTRAINED: Accuracy, damage, and rate of attack all increase slightly, and an agent knows how to use basic fist upgrades.|n|nADVANCED: Accuracy, damage, and rate of attack all increase moderately, and an agent knows how to use more advanced fist upgrades.|n|nMASTER: An agent can render most opponents unconscious or dead with a single blow and knows how to use the most complicated fist upgrades."
     SkillIcon=Texture'TNM.SkillIconFists'
     cost(0)=900
     cost(1)=1800
     cost(2)=3000
     LevelValues(1)=-0.100000
     LevelValues(2)=-0.250000
     LevelValues(3)=-0.500000
}

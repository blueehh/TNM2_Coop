//=============================================================================
// CoopSaveSlotManager
// The Nameless Mod 2.0 - Co-op Mod by bluehh (TM)
//
// Manages 4 independent Co-op Campaign Save Slots (Slot 1..4) in TNMCoopSlots.ini,
// including map URL, mission flags, goals, notes, NanoKeys, shared credits, and
// 4 host-held named player profiles (weapons, loaded ammo, mods, skills, augs).
//=============================================================================
class CoopSaveSlotManager extends Info config(TNMCoopSlots);

var config int ActiveSlotIndex;
var config byte SlotHasSave[4];
var config string SlotCurrentURL[4];
var config string SlotLastMap[4];
var config int SlotHostCredits[4];
var config int SlotClientCredits[4];

// Up to 1024 bools per slot * 4 slots = 4096
var config int SlotBoolCount[4];
var config string SlotBoolNames[4096];
var config byte SlotBoolVals[4096];
var config int SlotBoolExps[4096];

// Up to 128 bytes per slot * 4 slots = 512
var config int SlotByteCount[4];
var config string SlotByteNames[512];
var config byte SlotByteVals[512];
var config int SlotByteExps[512];

// Up to 512 ints per slot * 4 slots = 2048
var config int SlotIntCount[4];
var config string SlotIntNames[2048];
var config int SlotIntVals[2048];
var config int SlotIntExps[2048];

// Up to 128 floats per slot * 4 slots = 512
var config int SlotFloatCount[4];
var config string SlotFloatNames[512];
var config float SlotFloatVals[512];
var config int SlotFloatExps[512];

// Up to 128 names per slot * 4 slots = 512
var config int SlotNameCount[4];
var config string SlotNameNames[512];
var config string SlotNameVals[512];
var config int SlotNameExps[512];

// Up to 64 goals/notes/keys per slot * 4 slots = 256
var config int SlotGoalCount[4];
var config string SlotGoalNames[256];
var config byte SlotGoalPrimary[256];
var config byte SlotGoalCompleted[256];
var config string SlotGoalText[256];

var config int SlotNoteCount[4];
var config string SlotNoteText[256];
var config byte SlotNoteUser[256];
var config string SlotNoteTag[256];

var config int SlotKeyCount[4];
var config string SlotKeyIDs[256];
var config string SlotKeyDescs[256];

// Host/Client fallback loadouts per slot (4 slots)
var config int SlotHostInvTotal[4];
var config string SlotHostInvClass[256];
var config int SlotHostInvCount[256];
var config string SlotHostInvExtra[256];
var config int SlotClientInvTotal[4];
var config string SlotClientInvClass[256];
var config int SlotClientInvCount[256];
var config string SlotClientInvExtra[256];
var config int SlotHostSkillLevels[128];
var config int SlotClientSkillLevels[128];
var config int SlotHostAugLevels[128];
var config int SlotClientAugLevels[128];
var config int SlotHostStats[40];
var config int SlotClientStats[40];
var config vector SlotHostLocation[4];
var config rotator SlotHostRotation[4];
var config vector SlotClientLocation[4];
var config rotator SlotClientRotation[4];

// 4 Named Player Profiles per slot * 4 slots = 16 profiles
var config string SlotProfileNames[16];
var config int SlotProfileInvTotal[16];
var config string SlotProfileInvClass[1024];
var config int SlotProfileInvCount[1024];
var config string SlotProfileInvExtra[1024];
var config int SlotProfileSkillLevels[512];
var config int SlotProfileAugLevels[512];
var config int SlotProfileStats[160];
var config vector SlotProfileLocation[16];
var config rotator SlotProfileRotation[16];
var config string SlotProfileMap[16];

static function EnsureInitialized()
{
	if (default.ActiveSlotIndex < 0 || default.ActiveSlotIndex > 3)
		default.ActiveSlotIndex = 0;

	// If Slot 1 is empty but TNMCoopSave.ini already has a saved session, migrate it into Slot 1
	if (default.SlotHasSave[0] == 0 && class'tnmGameInfo'.default.bHasCoopSession && class'tnmGameInfo'.default.SavedCurrentURL != "")
	{
		CopyActiveSessionToSlot(0);
	}
}

static function int GetActiveSlot()
{
	EnsureInitialized();
	return default.ActiveSlotIndex;
}

static function SetActiveSlot(int slotIdx)
{
	if (slotIdx < 0 || slotIdx > 3)
		return;
	default.ActiveSlotIndex = slotIdx;
	StaticSaveConfig();
}

static function bool HasSlotSave(int slotIdx)
{
	EnsureInitialized();
	if (slotIdx < 0 || slotIdx > 3)
		return False;
	return (default.SlotHasSave[slotIdx] != 0 && default.SlotCurrentURL[slotIdx] != "");
}

static function string GetSlotMapURL(int slotIdx)
{
	EnsureInitialized();
	if (slotIdx < 0 || slotIdx > 3)
		return "";
	if (default.SlotHasSave[slotIdx] != 0)
		return default.SlotCurrentURL[slotIdx];
	return "";
}

static function string GetSlotButtonLabel(int slotIdx, bool bSelected, optional bool bShort)
{
	local string prefix, mapStr, namesStr;
	local int p, pBase;

	EnsureInitialized();
	if (bSelected)
		prefix = "> Slot " $ (slotIdx + 1) $ ": ";
	else
		prefix = "  Slot " $ (slotIdx + 1) $ ": ";

	if (default.SlotHasSave[slotIdx] == 0 || default.SlotCurrentURL[slotIdx] == "")
		return prefix $ "[Empty]";

	mapStr = default.SlotCurrentURL[slotIdx];
	if (bShort)
		return prefix $ mapStr;

	pBase = slotIdx * 4;
	for (p = 0; p < 4; p++)
	{
		if (default.SlotProfileNames[pBase + p] != "")
		{
			if (namesStr != "")
				namesStr = namesStr $ ", ";
			namesStr = namesStr $ default.SlotProfileNames[pBase + p];
		}
	}
	if (namesStr != "")
		return prefix $ mapStr $ " (" $ namesStr $ ")";
	return prefix $ mapStr;
}

static function ClearSlot(int slotIdx)
{
	local int p, pBase;

	if (slotIdx < 0 || slotIdx > 3)
		return;

	default.SlotHasSave[slotIdx] = 0;
	default.SlotCurrentURL[slotIdx] = "";
	default.SlotLastMap[slotIdx] = "";
	default.SlotBoolCount[slotIdx] = 0;
	default.SlotByteCount[slotIdx] = 0;
	default.SlotIntCount[slotIdx] = 0;
	default.SlotFloatCount[slotIdx] = 0;
	default.SlotNameCount[slotIdx] = 0;
	default.SlotGoalCount[slotIdx] = 0;
	default.SlotNoteCount[slotIdx] = 0;
	default.SlotKeyCount[slotIdx] = 0;
	default.SlotHostInvTotal[slotIdx] = 0;
	default.SlotClientInvTotal[slotIdx] = 0;

	pBase = slotIdx * 4;
	for (p = 0; p < 4; p++)
	{
		default.SlotProfileNames[pBase + p] = "";
		default.SlotProfileInvTotal[pBase + p] = 0;
	}
	StaticSaveConfig();
}

static function CopyActiveSessionToSlot(int slotIdx)
{
	local int i, p, count;
	local int bBase, byBase, inBase, flBase, nmBase, gBase, invBase, skBase, stBase;
	local int pSlotIdx, profInvBase, profSkBase, profStBase, srcInvBase, srcSkBase, srcStBase;
	local string s1, s2, s3, s4;
	local byte b1, b2;
	local int i1, i2, i3, i4;
	local float f1;
	local vector vLoc;
	local rotator rRot;

	if (slotIdx < 0 || slotIdx > 3)
		return;

	default.ActiveSlotIndex = slotIdx;
	default.SlotHasSave[slotIdx] = 1;
	default.SlotCurrentURL[slotIdx] = class'tnmGameInfo'.default.SavedCurrentURL;
	default.SlotLastMap[slotIdx] = class'tnmGameInfo'.default.SavedLastMap;
	default.SlotHostCredits[slotIdx] = class'tnmGameInfo'.default.SavedHostCredits;
	default.SlotClientCredits[slotIdx] = class'tnmGameInfo'.default.SavedClientCredits;

	// Bools (max 1024 per slot)
	bBase = slotIdx * 1024;
	count = Min(1024, class'tnmGameInfo'.default.SavedBoolCount);
	default.SlotBoolCount[slotIdx] = count;
	for (i = 0; i < count; i++)
	{
		class'tnmGameInfo'.static.GetActiveBoolEntry(i, s1, b1, i1);
		default.SlotBoolNames[bBase + i] = s1;
		default.SlotBoolVals[bBase + i] = b1;
		default.SlotBoolExps[bBase + i] = i1;
	}

	// Bytes (max 128 per slot)
	byBase = slotIdx * 128;
	count = Min(128, class'tnmGameInfo'.default.SavedByteCount);
	default.SlotByteCount[slotIdx] = count;
	for (i = 0; i < count; i++)
	{
		class'tnmGameInfo'.static.GetActiveByteEntry(i, s1, b1, i1);
		default.SlotByteNames[byBase + i] = s1;
		default.SlotByteVals[byBase + i] = b1;
		default.SlotByteExps[byBase + i] = i1;
	}

	// Ints (max 512 per slot)
	inBase = slotIdx * 512;
	count = Min(512, class'tnmGameInfo'.default.SavedIntCount);
	default.SlotIntCount[slotIdx] = count;
	for (i = 0; i < count; i++)
	{
		class'tnmGameInfo'.static.GetActiveIntEntry(i, s1, i1, i2);
		default.SlotIntNames[inBase + i] = s1;
		default.SlotIntVals[inBase + i] = i1;
		default.SlotIntExps[inBase + i] = i2;
	}

	// Floats (max 128 per slot)
	flBase = slotIdx * 128;
	count = Min(128, class'tnmGameInfo'.default.SavedFloatCount);
	default.SlotFloatCount[slotIdx] = count;
	for (i = 0; i < count; i++)
	{
		class'tnmGameInfo'.static.GetActiveFloatEntry(i, s1, f1, i1);
		default.SlotFloatNames[flBase + i] = s1;
		default.SlotFloatVals[flBase + i] = f1;
		default.SlotFloatExps[flBase + i] = i1;
	}

	// Names (max 128 per slot)
	nmBase = slotIdx * 128;
	count = Min(128, class'tnmGameInfo'.default.SavedNameCount);
	default.SlotNameCount[slotIdx] = count;
	for (i = 0; i < count; i++)
	{
		class'tnmGameInfo'.static.GetActiveNameEntry(i, s1, s2, i1);
		default.SlotNameNames[nmBase + i] = s1;
		default.SlotNameVals[nmBase + i] = s2;
		default.SlotNameExps[nmBase + i] = i1;
	}

	// Goals, Notes, Keys (max 64 per slot)
	gBase = slotIdx * 64;
	count = Min(64, class'tnmGameInfo'.default.SavedGoalCount);
	default.SlotGoalCount[slotIdx] = count;
	for (i = 0; i < count; i++)
	{
		class'tnmGameInfo'.static.GetActiveGoalEntry(i, s1, b1, b2, s2);
		default.SlotGoalNames[gBase + i] = s1;
		default.SlotGoalPrimary[gBase + i] = b1;
		default.SlotGoalCompleted[gBase + i] = b2;
		default.SlotGoalText[gBase + i] = s2;
	}

	count = Min(64, class'tnmGameInfo'.default.SavedNoteCount);
	default.SlotNoteCount[slotIdx] = count;
	for (i = 0; i < count; i++)
	{
		class'tnmGameInfo'.static.GetActiveNoteEntry(i, s1, b1, s2);
		default.SlotNoteText[gBase + i] = s1;
		default.SlotNoteUser[gBase + i] = b1;
		default.SlotNoteTag[gBase + i] = s2;
	}

	count = Min(64, class'tnmGameInfo'.default.SavedKeyCount);
	default.SlotKeyCount[slotIdx] = count;
	for (i = 0; i < count; i++)
	{
		class'tnmGameInfo'.static.GetActiveKeyEntry(i, s1, s2);
		default.SlotKeyIDs[gBase + i] = s1;
		default.SlotKeyDescs[gBase + i] = s2;
	}

	// Host & Client fallback loadouts
	invBase = slotIdx * 64;
	skBase = slotIdx * 32;
	stBase = slotIdx * 10;
	default.SlotHostInvTotal[slotIdx] = class'tnmGameInfo'.default.SavedHostInvTotal;
	default.SlotClientInvTotal[slotIdx] = class'tnmGameInfo'.default.SavedClientInvTotal;
	for (i = 0; i < 64; i++)
	{
		class'tnmGameInfo'.static.GetActiveInvEntry(i, s1, i1, s2, i2);
		class'tnmGameInfo'.static.GetActiveInvExtraEntry(i, s3, s4);
		default.SlotHostInvClass[invBase + i] = s1;
		default.SlotHostInvCount[invBase + i] = i1;
		default.SlotHostInvExtra[invBase + i] = s3;
		default.SlotClientInvClass[invBase + i] = s2;
		default.SlotClientInvCount[invBase + i] = i2;
		default.SlotClientInvExtra[invBase + i] = s4;
	}
	for (i = 0; i < 32; i++)
	{
		class'tnmGameInfo'.static.GetActiveSkillAugEntry(i, i1, i2, i3, i4);
		default.SlotHostSkillLevels[skBase + i] = i1;
		default.SlotClientSkillLevels[skBase + i] = i2;
		default.SlotHostAugLevels[skBase + i] = i3;
		default.SlotClientAugLevels[skBase + i] = i4;
	}
	for (i = 0; i < 10; i++)
	{
		class'tnmGameInfo'.static.GetActiveStatEntry(i, i1, i2);
		default.SlotHostStats[stBase + i] = i1;
		default.SlotClientStats[stBase + i] = i2;
	}
	default.SlotHostLocation[slotIdx] = class'tnmGameInfo'.default.SavedHostLocation;
	default.SlotHostRotation[slotIdx] = class'tnmGameInfo'.default.SavedHostRotation;
	default.SlotClientLocation[slotIdx] = class'tnmGameInfo'.default.SavedClientLocation;
	default.SlotClientRotation[slotIdx] = class'tnmGameInfo'.default.SavedClientRotation;

	// Named Player Profiles (4 per slot)
	for (p = 0; p < 4; p++)
	{
		pSlotIdx = slotIdx * 4 + p;
		class'tnmGameInfo'.static.GetActiveProfileMeta(p, s1, i1, vLoc, rRot, s2);
		default.SlotProfileNames[pSlotIdx] = s1;
		default.SlotProfileInvTotal[pSlotIdx] = i1;
		default.SlotProfileLocation[pSlotIdx] = vLoc;
		default.SlotProfileRotation[pSlotIdx] = rRot;
		default.SlotProfileMap[pSlotIdx] = s2;

		profInvBase = pSlotIdx * 64;
		srcInvBase  = p * 64;
		for (i = 0; i < 64; i++)
		{
			class'tnmGameInfo'.static.GetActiveProfileInv(srcInvBase + i, s1, i1);
			s3 = class'tnmGameInfo'.static.GetActiveProfileInvExtra(srcInvBase + i);
			default.SlotProfileInvClass[profInvBase + i] = s1;
			default.SlotProfileInvCount[profInvBase + i] = i1;
			default.SlotProfileInvExtra[profInvBase + i] = s3;
		}

		profSkBase = pSlotIdx * 32;
		srcSkBase  = p * 32;
		for (i = 0; i < 32; i++)
		{
			class'tnmGameInfo'.static.GetActiveProfileSkillAug(srcSkBase + i, i1, i2);
			default.SlotProfileSkillLevels[profSkBase + i] = i1;
			default.SlotProfileAugLevels[profSkBase + i] = i2;
		}

		profStBase = pSlotIdx * 10;
		srcStBase  = p * 10;
		for (i = 0; i < 10; i++)
		{
			class'tnmGameInfo'.static.GetActiveProfileStat(srcStBase + i, i1);
			default.SlotProfileStats[profStBase + i] = i1;
		}
	}

	StaticSaveConfig();
}

static function bool LoadSlotIntoActiveSession(int slotIdx)
{
	local int i, p, count;
	local int bBase, byBase, inBase, flBase, nmBase, gBase, invBase, skBase, stBase;
	local int pSlotIdx, profInvBase, profSkBase, profStBase, dstInvBase, dstSkBase, dstStBase;

	EnsureInitialized();
	if (slotIdx < 0 || slotIdx > 3)
		return False;
	if (default.SlotHasSave[slotIdx] == 0 || default.SlotCurrentURL[slotIdx] == "")
		return False;

	default.ActiveSlotIndex = slotIdx;
	StaticSaveConfig();

	class'tnmGameInfo'.default.bHasCoopSession = True;
	class'tnmGameInfo'.default.bHasActiveTravelSession = True;
	class'tnmGameInfo'.default.bForceRestoreLoadout = True;
	class'tnmGameInfo'.default.bRestoreSavedPositions = True;
	class'tnmGameInfo'.default.SavedCurrentURL = default.SlotCurrentURL[slotIdx];
	class'tnmGameInfo'.default.SavedLastMap = default.SlotLastMap[slotIdx];
	class'tnmGameInfo'.default.SavedHostCredits = default.SlotHostCredits[slotIdx];
	class'tnmGameInfo'.default.SavedClientCredits = default.SlotClientCredits[slotIdx];

	// Bools
	bBase = slotIdx * 1024;
	count = Min(1024, default.SlotBoolCount[slotIdx]);
	class'tnmGameInfo'.default.SavedBoolCount = count;
	for (i = 0; i < count; i++)
	{
		class'tnmGameInfo'.static.SetActiveBoolEntry(i, default.SlotBoolNames[bBase + i], default.SlotBoolVals[bBase + i], default.SlotBoolExps[bBase + i]);
	}

	// Bytes
	byBase = slotIdx * 128;
	count = Min(128, default.SlotByteCount[slotIdx]);
	class'tnmGameInfo'.default.SavedByteCount = count;
	for (i = 0; i < count; i++)
	{
		class'tnmGameInfo'.static.SetActiveByteEntry(i, default.SlotByteNames[byBase + i], default.SlotByteVals[byBase + i], default.SlotByteExps[byBase + i]);
	}

	// Ints
	inBase = slotIdx * 512;
	count = Min(512, default.SlotIntCount[slotIdx]);
	class'tnmGameInfo'.default.SavedIntCount = count;
	for (i = 0; i < count; i++)
	{
		class'tnmGameInfo'.static.SetActiveIntEntry(i, default.SlotIntNames[inBase + i], default.SlotIntVals[inBase + i], default.SlotIntExps[inBase + i]);
	}

	// Floats
	flBase = slotIdx * 128;
	count = Min(128, default.SlotFloatCount[slotIdx]);
	class'tnmGameInfo'.default.SavedFloatCount = count;
	for (i = 0; i < count; i++)
	{
		class'tnmGameInfo'.static.SetActiveFloatEntry(i, default.SlotFloatNames[flBase + i], default.SlotFloatVals[flBase + i], default.SlotFloatExps[flBase + i]);
	}

	// Names
	nmBase = slotIdx * 128;
	count = Min(128, default.SlotNameCount[slotIdx]);
	class'tnmGameInfo'.default.SavedNameCount = count;
	for (i = 0; i < count; i++)
	{
		class'tnmGameInfo'.static.SetActiveNameEntry(i, default.SlotNameNames[nmBase + i], default.SlotNameVals[nmBase + i], default.SlotNameExps[nmBase + i]);
	}

	// Goals, Notes, Keys
	gBase = slotIdx * 64;
	count = Min(64, default.SlotGoalCount[slotIdx]);
	class'tnmGameInfo'.default.SavedGoalCount = count;
	for (i = 0; i < count; i++)
	{
		class'tnmGameInfo'.static.SetActiveGoalEntry(i, default.SlotGoalNames[gBase + i], default.SlotGoalPrimary[gBase + i], default.SlotGoalCompleted[gBase + i], default.SlotGoalText[gBase + i]);
	}

	count = Min(64, default.SlotNoteCount[slotIdx]);
	class'tnmGameInfo'.default.SavedNoteCount = count;
	for (i = 0; i < count; i++)
	{
		class'tnmGameInfo'.static.SetActiveNoteEntry(i, default.SlotNoteText[gBase + i], default.SlotNoteUser[gBase + i], default.SlotNoteTag[gBase + i]);
	}

	count = Min(64, default.SlotKeyCount[slotIdx]);
	class'tnmGameInfo'.default.SavedKeyCount = count;
	for (i = 0; i < count; i++)
	{
		class'tnmGameInfo'.static.SetActiveKeyEntry(i, default.SlotKeyIDs[gBase + i], default.SlotKeyDescs[gBase + i]);
	}

	// Host & Client fallback loadouts
	invBase = slotIdx * 64;
	skBase = slotIdx * 32;
	stBase = slotIdx * 10;
	class'tnmGameInfo'.default.SavedHostInvTotal = default.SlotHostInvTotal[slotIdx];
	class'tnmGameInfo'.default.SavedClientInvTotal = default.SlotClientInvTotal[slotIdx];
	for (i = 0; i < 64; i++)
	{
		class'tnmGameInfo'.static.SetActiveInvEntry(i, default.SlotHostInvClass[invBase + i], default.SlotHostInvCount[invBase + i], default.SlotClientInvClass[invBase + i], default.SlotClientInvCount[invBase + i]);
		class'tnmGameInfo'.static.SetActiveInvExtraEntry(i, default.SlotHostInvExtra[invBase + i], default.SlotClientInvExtra[invBase + i]);
	}
	for (i = 0; i < 32; i++)
	{
		class'tnmGameInfo'.static.SetActiveSkillAugEntry(i, default.SlotHostSkillLevels[skBase + i], default.SlotClientSkillLevels[skBase + i], default.SlotHostAugLevels[skBase + i], default.SlotClientAugLevels[skBase + i]);
	}
	for (i = 0; i < 10; i++)
	{
		class'tnmGameInfo'.static.SetActiveStatEntry(i, default.SlotHostStats[stBase + i], default.SlotClientStats[stBase + i]);
	}
	class'tnmGameInfo'.default.SavedHostLocation = default.SlotHostLocation[slotIdx];
	class'tnmGameInfo'.default.SavedHostRotation = default.SlotHostRotation[slotIdx];
	class'tnmGameInfo'.default.SavedClientLocation = default.SlotClientLocation[slotIdx];
	class'tnmGameInfo'.default.SavedClientRotation = default.SlotClientRotation[slotIdx];

	// Named Player Profiles (4 per slot)
	for (p = 0; p < 4; p++)
	{
		pSlotIdx = slotIdx * 4 + p;
		class'tnmGameInfo'.static.SetActiveProfileMeta(p, default.SlotProfileNames[pSlotIdx], default.SlotProfileInvTotal[pSlotIdx], default.SlotProfileLocation[pSlotIdx], default.SlotProfileRotation[pSlotIdx], default.SlotProfileMap[pSlotIdx]);

		profInvBase = pSlotIdx * 64;
		dstInvBase  = p * 64;
		for (i = 0; i < 64; i++)
		{
			class'tnmGameInfo'.static.SetActiveProfileInv(dstInvBase + i, default.SlotProfileInvClass[profInvBase + i], default.SlotProfileInvCount[profInvBase + i]);
			class'tnmGameInfo'.static.SetActiveProfileInvExtra(dstInvBase + i, default.SlotProfileInvExtra[profInvBase + i]);
		}

		profSkBase = pSlotIdx * 32;
		dstSkBase  = p * 32;
		for (i = 0; i < 32; i++)
		{
			class'tnmGameInfo'.static.SetActiveProfileSkillAug(dstSkBase + i, default.SlotProfileSkillLevels[profSkBase + i], default.SlotProfileAugLevels[profSkBase + i]);
		}

		profStBase = pSlotIdx * 10;
		dstStBase  = p * 10;
		for (i = 0; i < 10; i++)
		{
			class'tnmGameInfo'.static.SetActiveProfileStat(dstStBase + i, default.SlotProfileStats[profStBase + i]);
		}
	}

	class'tnmGameInfo'.static.StaticSaveConfig();
	return True;
}

defaultproperties
{
}

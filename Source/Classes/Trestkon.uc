//=============================================================================
// Trestkon
// Original TNM 2.0 PlayerPawn by Off Topic Productions
// Co-op Campaign Networking, HUD, Profiles & High-Ping Prediction by bluehh (TM)
//=============================================================================
class trestkon extends Human config(user);

// How do you do, fellow Source Code readers.

//If you're reading this, good luck.
//ahahaha owned joo with teh secret message - that guy;
//protip: get your string of profanities at our oft
//nonsensical code queued up now -nvshacker

const TNM_VERSION_STRING = " - BUILD 261013";
const ACHIEVEMENTS_ENABLED = true;

CONST REVISION_VERSION_MAJOR = 2;
CONST REVISION_VERSION_MINOR = 6;
CONST REVISION_VERSION_BUILD = 1;
CONST REVISION_VERSION_REVISION = 0;

enum ECoatType
{
   CT_Default,
   CT_PDX,
   CT_WC,
   CT_Goat,
   CT_Llama,
   CT_ShortBlack,
   CT_ShortTrest,
   CT_DXI,
   CT_Gold,
   CT_GS,
   CT_Bum
};

var() travel ECoatType CoatType;

enum EVestType
{
   VT_Default,
   VT_JC,
   VT_MJ12
};

var() travel EVestType VestType;

enum EEyeType
{
   ET_Default,
   ET_Sunglasses,
   ET_Vaporwave,
   ET_Aviators
};

var() travel EEyeType EyeType;

enum EBootType
{
   BT_Default,
   BT_Boots1,
   BT_Boots2,
   BT_Boots3,
   BT_Boots4,
   BT_Boots5,
   BT_Boots6,
   BT_Boots7,
   BT_Boots8,
   BT_Boots9
};

var() travel EBootType BootType;
 
var() travel TNMATMAccountManager ATMAccountManager;

var globalconfig int CurrentUpgradeVersionMajor,CurrentUpgradeVersionMinor, CurrentUpgradeVersionBuild, CurrentUpgradeVersionRevision;

var bool CantSave;
var bool CanLoad;
var bool bJustTraveled;
var transient bool bAutosave;

var() config int MaximumAutosaves;
var() config int BackupSaveInterval;
var() config bool bLoadingQuotes;
//var() config bool bNoUIFix;
var sound bruhSound;

var globalconfig bool bAltSoundtrack;
var globalconfig int  QuickSaveNumber;
var(DXTSettings) globalconfig /*int*/ bool bUseAutosave;
var(DXTSettings) globalconfig bool 		bAllowSavesDuringInfolinks;
var(DXTSettings) globalconfig bool 		bEpilepsyReduction;		// Disable flashing lights?
var(DXTSettings) globalconfig bool 		bAltKeypad; 			// Use a numpad keypad instead of a phone one? 
var(DXTSettings) globalconfig bool		bAltSpyDroneView;		// True = Spydrone window is Player's view while player's view is the spydrone. False = original way.
// var(DXTSettings) globalconfig bool		bNoAugIdleHumSound;		// Do augmentations play their idle hum sound when active?
var(DXTSettings) globalconfig bool 		bRealTimeUI;			// Is any UI in real time instead of paused?
var(DXTSettings) globalconfig bool  	bEnlargedBelt;			// Increase the object belt from 10 slots to 12?
var(TNMSettings) globalconfig bool		bParanoidReload;		//Allow us to reload with a full mag. Otherwise, don't. Default: on.
var(TNMSettings) globalconfig bool		bPasswordManager;		//
var(TNMSettings) globalconfig bool		bKeycodeManager;		//
var(TNMSettings) globalconfig bool		bLoopStealthUntilPB;	//
var(TNMSettings) globalconfig bool		bRifleTracers;			//
var(TNMSettings) globalconfig bool		bInvasionsEnabled;		//
var(TNMSettings) globalconfig int		CustomUIScale;		//Should be 1x or 2x. Default 1x.

var() globalconfig bool		bCommentaryNodes;			// Enable commentary nodes around the map?
var() globalconfig bool		bLargeFont;			// Enable commentary nodes around the map?
var() globalconfig bool		bHDTPWeapons;		

var bool bBreakAndEnter; //Indicates that the player is somewhere he shouldn't be

var DeusExLevelInfo mapinfo;
var NorthMarker marker;
var TrestkonDummyABI ABIDummy;

//DDL breath moisture code
var particlegenerator breathgen;
var float breathtimer;
var float breathtime;
var() float breathSize;
var() bool bVisibleBreath;

var bool bStunned;
var bool bEntityDeath;
var(TNM2IRC) travel bool bUsingIRC;
var(TNM2IRC) travel string lastNick, lastServer, lastChannel;
var(TNM2IRC) globalconfig bool bAutoIRC;
var(TNM2IRC) globalconfig string autoIRCNick;
var(TNM2IRC) globalconfig bool bIRCLocationInfo, bIRCDeathInfo, bIRCImportantKillInfo;
var(TNM2IRC) globalconfig bool bAllowIRCExecutions;

var(Achievements) globalconfig bool achFirestaff, achNoobsKill, achNoobsExpose, achNoobsSave, achKunioKun, achJimmycracker, achShadowCode, achBeebleTalk, achBeebleKill, achProgram, achThreads, achBossEarlyKill, achDDKill, achSlicerDXIKill, achSlicerDXIKnockOut, achSlicerABIKill, achSlicerGhost, achSlicerCapture, achZPDXIKill, achZPDXIKnockout, achZPABIKill, achZPGhost, achZPCapture, achKevoSave, achDXOKill, achKevoCapture, achKevoKill, achSolo, achPilot, achTeleporters, achTablets, achBeefman, achMelkValves, achAthena, achAbomination, achDarkTemplar, achEndingPDX, achEndingWC, achEndingABI, achEndingNarc, achA2Prison, achA2Reprogram, achRealZP, achBogieReport, achBogieScramble, achKylieScramble, achResurrection, achTeamkill, achBlackICE, achDXE, achYardbombSell, achYardbombStay, achHao, achRyanKill, achRyanBan, achGrub, achSilver, achSewer, achQuotes, achTester, achPhasTV, achRavingSteal, achDoppel, achNarcWC, achJonasThreaten, achFanFicClosed, achFanFic1, achFanFic2, achQuadRocket, achWCID, achJonasKnockOut, achNVSKill, achNVSKnockOut, achFlush, achGoatAug, achHovercar, achApocalypse, achGhand, achPimpJojo, achABIStealth, achTreskton, achGaryMonroe, achZPApp, achHawkApp, achSluggoApp, achBreakout, achTetris, achLightsOut, achPong, achTheNamelessAdventure, achAIPuzzle, achIRC, achATM, achNews, achVending, achCultWeapon, achUniqueKill, achToolKill, achDaikatana, achPHAT, achRice, achFists, achTaser, achKatana, achPistols, achFireblade, achVortex, achGibinator, achNapalm, achBlowpipe, achSpork, achNVSScrewdriver, achMolotov, achSpider, achEMP, achMelk, achLollerskates, achGloves, achGreasel, achAvatar, achRickRoll, achAccessClearance, achOneEgg, achAllEggs, achFirewall, achFirestaffSpace, achNoCult, achHostagePeaceful, achHostageLethal, achHostageVeryLethal, achHostageNotMet, achSolsBombers, achSolsBombBoth, achATCNoLZ, achAthenaRoom, achRuinsFast, achLGun, achSpiderColony, achMoonlightBlade, achTemporal;
var(Achievements) globalconfig bool bRevealAchievements;
var(Achievements) globalconfig bool bAchievementNotifications;
var(Accessories) globalconfig bool bUnlockedAccessoryCoatPDX, bUnlockedAccessoryCoatWC, bUnlockedAccessoryCoatGoat, bUnlockedAccessoryCoatLlama, bUnlockedAccessoryCoatShortBlack, bUnlockedAccessoryCoatShortTrest, bUnlockedAccessoryCoatDXI, bUnlockedAccessoryCoatGold, bUnlockedAccessoryCoatGS, bUnlockedAccessoryCoatBum;
var(Accessories) globalconfig bool bUnlockedAccessoryBlackSunglasses, bUnlockedAccessoryVaporwaveVisor, bUnlockedAccessoryMJ12Vest, bUnlockedAccessoryJCVest, bUnlockedAccessoryAviators;

var localized string strClaw, strBite, strGraySpit, strSwipe, strGreaselSpit, strKarkian, strCommandoGun, strCommandoRocket, strRobotGun, strRobotRocket, strSpiderbot, strAchievement;

var(Music) globalconfig bool bUnlockedTrack0, // ABI Surface Ambience
bUnlockedTrack1, // ABI Surface Combat
bUnlockedTrack2, // ABI Surface Convo
bUnlockedTrack3, // ABI Surface Death
bUnlockedTrack4, // ABI Underground Ambience
bUnlockedTrack5, // ABI Underground Combat
bUnlockedTrack6, // ABI Underground Convo
bUnlockedTrack7, // ABI Underground Death
bUnlockedTrack8, // Despot Ambience
bUnlockedTrack9, // Despot Ambience (CD)
bUnlockedTrack10, // Despot Combat
bUnlockedTrack11, // Despot Combat (CD)
bUnlockedTrack12, // DXI Caverns Ambience
bUnlockedTrack13, // DXI Caverns Death
bUnlockedTrack14, // DXI MCR Ambience
bUnlockedTrack15, // DXI MCR Combat
bUnlockedTrack16, // DXI MCR Convo
bUnlockedTrack17, // DXI MCR Death
bUnlockedTrack18, // DXI Ruins Ambience
bUnlockedTrack19, // DXI Ruins Combat
bUnlockedTrack20, // DXI Ruins Combat (CD)
bUnlockedTrack21, // DXI Ruins Convo
bUnlockedTrack22, // DXI Ruins Death
bUnlockedTrack23, // DXO Hideout Ambience
bUnlockedTrack24, // DXO Hideout Ambience (CD)
bUnlockedTrack25, // DXO Hideout Combat
bUnlockedTrack26, // DXO Hideout Convo
bUnlockedTrack27, // DXO Hideout Death
bUnlockedTrack28, // Corporate District Ambience
bUnlockedTrack29, // Corporate District Ambience (CD)
bUnlockedTrack30, // Corporate District Ambience (Hostile)
bUnlockedTrack31, // Corporate District Combat
bUnlockedTrack32, // Corporate District Conversation
bUnlockedTrack33, // Corporate District Death
bUnlockedTrack34, // Corporate Sewers Ambience
bUnlockedTrack35, // Central District Ambience
bUnlockedTrack36, // Central District Combat
bUnlockedTrack37, // Central District Convo
bUnlockedTrack38, // Central District Death
bUnlockedTrack39, // West Residence District Ambience
bUnlockedTrack40, // West Residence District Ambience (Hostile)
bUnlockedTrack41, // West Residence District Convo
bUnlockedTrack42, // West Residence District Death
bUnlockedTrack43, // West Residence District Outro
bUnlockedTrack44, // West Residence District Sewers Ambience
bUnlockedTrack45, // Goat City Ambience
bUnlockedTrack46, // Goat City Ambience (CD)
bUnlockedTrack47, // Goat City Ambience (Hostile)
bUnlockedTrack48, // Goat City Ambience (Hostile - CD)
bUnlockedTrack49, // Goat City Combat
bUnlockedTrack50, // Goat City Convo
bUnlockedTrack51, // Goat City Death
bUnlockedTrack52, // Intro Theme
bUnlockedTrack53, // Llama Temple Ambience
bUnlockedTrack54, // Llama Temple Combat
bUnlockedTrack55, // Llama Temple Convo
bUnlockedTrack56, // Llama Temple Death
bUnlockedTrack57, // New Server Complex Ambience
bUnlockedTrack58, // New Server Complex Combat
bUnlockedTrack59, // New Server Complex Convo
bUnlockedTrack60, // New Server Complex Death
bUnlockedTrack61, // Old Server Complex Ambience
bUnlockedTrack62, // Old Server Complex Combat
bUnlockedTrack63, // Old Server Complex Death
bUnlockedTrack64, // PartyZone Ambience
bUnlockedTrack65, // PDX HQ Ambience
bUnlockedTrack66, // PDX HQ Ambience (CD)
bUnlockedTrack67, // PDX HQ Ambience (Hostile)
bUnlockedTrack68, // PDX HQ Ambience (Hostile - CD)
bUnlockedTrack69, // PDX HQ Combat
bUnlockedTrack70, // PDX HQ Combat (CD)
bUnlockedTrack71, // PDX HQ Convo
bUnlockedTrack72, // PDX HQ Convo (CD)
bUnlockedTrack73, // PDX HQ Death
bUnlockedTrack74, // Sol's Bar Ambience
bUnlockedTrack75, // Sol's Bar Ambience (CD)
bUnlockedTrack76, // Sol's Bar Ambience (Destroyed)
bUnlockedTrack77, // Sol's Bar Combat
bUnlockedTrack78, // Sol's Bar Death
bUnlockedTrack79, // Space Station Ambience
bUnlockedTrack80, // Space Station Combat
bUnlockedTrack81, // Space Station Combat (CD)
bUnlockedTrack82, // Space Station Convo
bUnlockedTrack83, // Space Station Death
bUnlockedTrack84, // West Residence District Combat
bUnlockedTrack85, // The Nameless Theme
bUnlockedTrack86, // The Nameless Theme (CD)
bUnlockedTrack87, // The Nameless Credits
bUnlockedTrack88, // PDX Ending (TRM Dead)
bUnlockedTrack89, // PDX Ending (TRM Alive)
bUnlockedTrack90, // WC Ending (With Kylie)
bUnlockedTrack91, // WC Ending (With Kylie - CD)
bUnlockedTrack92, // WC Ending (Sans Kylie,
bUnlockedTrack93, // WC Ending (With Kylie, Sans Scara)
bUnlockedTrack94, // WC Ending (Sans Kylie, Sans Scara)
bUnlockedTrack95, // ABI Ending
bUnlockedTrack96, // ABI Ending (CD)
bUnlockedTrack97, // Radish Adventure Ambience
bUnlockedTrack98, // Radish Adventure Death
bUnlockedTrack99, // Voodoo Shop Ambience
bUnlockedTrack100, // Voodoo Shop Death
bUnlockedTrack101, // WorldCorp HQ Ambience
bUnlockedTrack102, // WorldCorp HQ Ambience (CD)
bUnlockedTrack103, // WorldCorp HQ Ambience (Hostile)
bUnlockedTrack104, // WorldCorp HQ Combat
bUnlockedTrack105, // WorldCorp HQ Convo
bUnlockedTrack106, // WorldCorp HQ Convo (CD)
bUnlockedTrack107, // WorldCorp HQ Death
bUnlockedTrack108, // WorldCorp HQ Sub-level Ambience
bUnlockedTrack109, // Stereo - The Beginning of the End (A51)
bUnlockedTrack110, // Stereo - Hong Kong Canal Combat
bUnlockedTrack111, // Stereo - Corporate x PDX HQ (Combat)
bUnlockedTrack112, // DXI Citadel Ambience
bUnlockedTrack113, // DXI Citadel Combat
bUnlockedTrack114, // DXI Citadel Conversation
bUnlockedTrack115, // DXI Citadel Death
bUnlockedTrack116, // Registration Ambience
bUnlockedTrack117, // Registration Alpha Fight
bUnlockedTrack118, // Registration Conversation
bUnlockedTrack119, // Registration Combat
bUnlockedTrack120, // Registration Death
bUnlockedTrack121, // Radish Kingdom
bUnlockedTrack122, // Nevermore
bUnlockedTrack123; // Radish Cove

var(StealthMinigame) globalconfig int stealthDifficulty;
var(StealthMinigame) globalconfig float	stealth1ParTimeEasy,
stealth2ParTimeEasy,
stealth3ParTimeEasy,
stealth4ParTimeEasy,
stealth5ParTimeEasy,
stealth6ParTimeEasy,
stealth7ParTimeEasy,
stealth8ParTimeEasy,
stealth9ParTimeEasy;
var(StealthMinigame) globalconfig float	stealth1ParTimeNormal,
stealth2ParTimeNormal,
stealth3ParTimeNormal,
stealth4ParTimeNormal,
stealth5ParTimeNormal,
stealth6ParTimeNormal,
stealth7ParTimeNormal,
stealth8ParTimeNormal,
stealth9ParTimeNormal;
var(StealthMinigame) globalconfig float	stealth1ParTimeHard,
stealth2ParTimeHard,
stealth3ParTimeHard,
stealth4ParTimeHard,
stealth5ParTimeHard,
stealth6ParTimeHard,
stealth7ParTimeHard,
stealth8ParTimeHard,
stealth9ParTimeHard;
var(CombatMinigame) globalconfig int combatMinigameDifficulty;
var(CombatMinigame) globalconfig float	combat1ParTimeEasy,
combat2ParTimeEasy,
combat3ParTimeEasy,
combat4ParTimeEasy,
combat5ParTimeEasy,
combat6ParTimeEasy,
combat7ParTimeEasy,
combat8ParTimeEasy,
combat9ParTimeEasy;
var(CombatMinigame) globalconfig float	combat1ParTimeNormal,
combat2ParTimeNormal,
combat3ParTimeNormal,
combat4ParTimeNormal,
combat5ParTimeNormal,
combat6ParTimeNormal,
combat7ParTimeNormal,
combat8ParTimeNormal,
combat9ParTimeNormal;
var(CombatMinigame) globalconfig float	combat1ParTimeHard,
combat2ParTimeHard,
combat3ParTimeHard,
combat4ParTimeHard,
combat5ParTimeHard,
combat6ParTimeHard,
combat7ParTimeHard,
combat8ParTimeHard,
combat9ParTimeHard;

var vector lastStepNormal;
var float temporalness;

//<SHOPPING VARS>
	var string tooexpensive;
	var bool bconfirmpurchase;
	var localized string querypurchasewindowtitle;
	var localized string querypurchasewindowtext;
	var localized string purchasedmessage;
	var localized string notpurchasedmessage;
	var localized string cantpurchasemessage;
	var name weaponshopopenevent;
	var int weaponshopcost;
	var creditreader weaponshopreader;
//</SHOPPING VARS>

//<PLATFORM VARS>
	var travel bool bplatformer;
	var bool bYAxis;
	var bool bReverseControls;
	var bool bbackwards;
	var int xAxis;	// float?
	var int yAxis;
	var travel int lives;
	var travel int radishHealth;
	var travel int radishCounter;
	var radishhud rh;
	
	// immunity
	var float	RadishImmunityTime;
	var float	RadishImmunityTimeLeft;
	var int	RadishImmunityFlickerTimer;
	var bool		bRadishImmunity;
	const			RadishDelay = 3.0;
//</PLATFORM VARS>

//<INSANE VARS>
	var bool binsane;
	var bool binsanedeath;

	var vector insanedest;
	var bool bRuleofThirds;

	var transient Window insanewindow;

	var float insanedeathtimer;

	var float rollincrement;
	var float rollincrementincrement;
	var float newroll;

	var float scopefov;
	var float newfov;
	var float fovincrement;
	var float fovincrementincrement;
//</INSANE VARS>

//<CHEATS>
	var bool bRearView;
	var bool bRearViewRendering;
	var bool bAustralian;
	var bool bdespot;
	var bool bunrealistic;
	var bool binstagibfists;
	var string strstartintromap, strstartmapunrealistic;
	var int flySpeed;
	var CommandBuffer buf;
	var travel string buf_contents[1024]; //todo kill this pre-release
	var config bool bDebug;
//</CHEATS>

//<FOR BEEBLEQUIX>
	var float yawchange;
	var float pitchchange;
	var float zoomchange;
	var float zchange;
	var bool bbeeblequixview;
//</FOR BEEBLEQUIX>

//<CINEMATICS>
	var bool bLetterBox;
	var window LetterBox;
	var trestkonCam TCam;
	var bool bCinematic;
	var bool bCinematicInterruptMusic;
	var bool bEscapeSkip;
	var bool bOldBehindView;
	var tnmcamerapoint CurrentCam;
//</CINEMATICS>

//<FIST STUFF>
	var travel weaponfists playerfists;
	var float LastInHandTimer; //WCCC, 6/17/19: It's fist related. Trust me.
//</FIST STUFF>

//<OAT STUFF>
	var travel int LastBrowsedAugPage, LastBrowsedAug; //OAT, 1/12/24: By popular demand.
//</OAT STUFF>

//<BOT DOMINATION STUFF>
	var TNMRobot dominatedbot;
	var bool bdominatingbot;
//</BOT DOMINATION STUFF>

//<EASTER EGG STUFF>
	var() config int eggs;
	var globalconfig bool bEggVisible;

	var() config bool bUnlockedSword;
	var bool bGotSword;

	var() config bool bUnlockedBulletTime;
//</EASTER EGG STUFF>

//<MISSION SCRIPT STUFF>
	var travel string LastMap;
//</MISSION SCRIPT STUFF>

//<BLACK ICE STUFF>
	var string blackiceDL;
//</BLACK ICE STUFF>

//<STATIC STUFF>
	var int StaticSoundID;
	var float StaticTime;
//</STATIC STUFF>

//<SKATES>
	var travel bool bSkating;
	var travel float skatespeed;
//</SKATES>

//<FootPrints>
	var float footprintoffset;
	var name FloorTexture;
	var bool bWalkingOnSnow;
	var bool bWalkingBackwards;
//</FootPrints>

//<GasMask>
	var bool bGasMask;
	var float BreatheTime;
	var int BreatheSoundID;
//</GasMask>

//<Molotovs>
var localized string molotovMsgNoRoom;

var float defaultBurnTime, defaultBurnTimeMP;

var localized string ItemRefusedString;

//bullet time vars -shax
var input byte bBulletTimePressed;
var bool bInBulletTime;
var BulletTimeManager BTManager;
//end bullet time vars

var globalconfig bool bPasswordCracking;

var float melkEffectTimer;
var travel string ABISpawnItem;

//var transient bool bHackHackHackNoPopWindow;

//pc game data -shax
struct tnmPCGscore
{
	var() string alias;
	var() int score;
};

struct tnmPCGdata
{
	var() tnmPCGscore scores[10];
	var() bool bHasScores;
	var() float timeplayed;
	var() string title;
	var() string scoretype;
};

struct tnmPCGtimePlayed
{
	var() int gameId;
	var() float timePlayed;
};

const PCG_TETRIS	=0;
const PCG_PONG		=1;
const PCG_BREAKOUT	=2;
const PCG_LIGHTSOUT	=3;
const PCG_TEXT		=4;

var travel tnmPCGdata PCGameData[5];

var globalconfig int GameHighScoreTetris; // Was travel
var globalconfig int GameHighScorePong;
var globalconfig int GameHighScoreBreakout;
var globalconfig int GameHighScoreLightsOut; //number of times solved

var travel float GameTimePlayedTetris;
var travel float GameTimePlayedPong;
var travel float GameTimePlayedBreakout;
var travel float GameTimePlayedLightsOut;
var travel float GameTimePlayedText;
//end pc game data

//m20 credits monitoring vars -shax
var travel int CreditsEarned; //total credits made, used for the nvshacker quest in m20
var travel int CreditsPrev; //value of credits last frame, to detect change
//end m20 credits monitoring vars

//irc link -shax
var travel tnmPassiveIRCLink irc_link;

//fake irc check -shax
var travel bool bFakeIRCSeen;

var RandomEventInfoLink randoms;

//var config bool bWeatherDisabled;

//var bool bhasvisor,bhascoat; I dont think these are ever used

// Smoke39 - new jump bob stuff
var bool bMustJump;
var float jumpBob;

// DDL difficulty filter vars

var travel int PawnDifficulty;
var travel float PawnHealth;
var travel int ItemDifficulty;
var travel bool bLegendaryMode;
var travel bool bNightmareMode;
var travel bool b2009Maps;

var bool bFiltered;

var bool blogView;
var transient tnmLog logView_log;

var bool bNoOxygen;
var float halongastimer;

var travel bool bQuadDamage;
var travel float quadDamageTimer;

var travel bool bDoubleDamage;
// var float duoDamageTimer;

var travel bool bRingOfShadow;
var travel float shadowRingTimer;

//<MP CHARACTER VARS>
//MPCR = MultiPlayer CharacteR

var config bool bMPCR_DeusDiabloUnlocked;
var config bool bMPCR_KylieGriffinUnlocked;
var config bool bMPCR_EndarUnlocked;
var config bool bMPCR_RealZeroPresenceUnlocked;
var config bool bMPCR_FirewallUnlocked;
var config bool bMPCR_FirewallAlphaUnlocked;
var config bool bMPCR_TheRenegadeMasterUnlocked;
var config bool bMPCR_MadMaxUnlocked;
var config bool bMPCR_MoleUnlocked;
var config bool bMPCR_WaltonSimonsUnlocked;
var config bool bMPCR_ChrisUnlocked;
var config bool bMPCR_BogieUnlocked;

var localized string strEscapeSkip, strBackupSave, strAutoSave, strTryBuy;
var localized string strNoMolotovMaterials, strNoMolotovSkill, strNoMolotovWine;
var localized string strGoalUpdated, strFireStaffDrop, strLockerPassword, strAccountPin;

//<MP CHARACTER VARS>

// little cheat secret

var bool bBogieMode;

var() float dripRate;
var() float waterDripCounter;

var() travel bool bCloaked, bRadarCloaked;
var localized string TooHotToLift;

//8/27/24: Misc fix for sticking grenades on shit.
var Mover LastMoverFrobTarget;

// Item Refusal Bools
var(ItemRefusal) globalconfig bool bRefuseWeaponAssaultGun, bRefuseWeaponAssaultShotgun, bRefuseWeaponBaton, bRefuseWeaponCombatKnife, bRefuseWeaponCrowbar, bRefuseWeaponEMPGrenade, bRefuseWeaponFlamethrower, bRefuseWeaponGasGrenade, bRefuseWeaponGEPGun, bRefuseWeaponHideAGun, bRefuseWeaponLAM, bRefuseWeaponLAW, bRefuseWeaponMiniCrossbow, bRefuseWeaponNanoSword, bRefuseWeaponNanoVirusGrenade, bRefuseWeaponPepperGun, bRefuseWeaponPistol, bRefuseWeaponPlasmaRifle, bRefuseWeaponProd, bRefuseWeaponRifle, bRefuseWeaponSawedOffShotgun, bRefuseWeaponShuriken, bRefuseWeaponStealthPistol, bRefuseWeaponSword;

var(ItemRefusal) globalconfig bool bRefuseWeaponMod;

var(ItemRefusal) globalconfig bool bRefuseAugmentationCannister, bRefuseAugmentationUpgradeCannister, bRefuseBinoculars, bRefuseBioelectricCell, bRefuseCandybar, bRefuseCigarettes, bRefuseFireExtinguisher, bRefuseFlare, bRefuseLiquor40oz, bRefuseLiquorBottle, bRefuseMedKit, bRefuseSodacan, bRefuseSoyFood, bRefuseVialAmbrosia, bRefuseVialCrack, bRefuseWineBottle;

var(ItemRefusal) globalconfig bool bRefuseMultitool, bRefuseLockpick;

var(ItemRefusal) globalconfig bool bRefuseAdaptiveArmor, bRefuseBallisticArmor, bRefuseHazMatSuit, bRefuseRebreather, bRefuseTechGoggles;

var(ItemRefusal) globalconfig bool bRefuseWeaponBlackBox, bRefuseWeaponBlowPipe, bRefuseWeaponDoubleGuns, bRefuseWeaponFatRifle, bRefuseWeaponFireBlade, bRefuseWeaponFoon, bRefuseWeaponGibinator, bRefuseWeaponHammer, bRefuseWeaponKatana, bRefuseWeaponLaser, bRefuseWeaponMine, bRefuseWeaponNapalmLauncher, bRefuseWeaponPlasmaNade, bRefuseWeaponQdRocket, bRefuseWeaponScrewDriver, bRefuseWeaponShotgun, bRefuseWeaponSpork, bRefuseWeaponTripBomb, bRefuseWeaponWrench, bRefuseWeaponMolBottle, bRefuseWeaponThrowSpork, bRefuseWeaponThrowFoon;

var(ItemRefusal) globalconfig bool bRefuseBeans, bRefuseChemicalBottle, bRefuseKetchupBar, bRefusePlasticCoffee, bRefuseRedBiocell, bRefuseLollerSkates, bRefuseMelk, bRefuseGasMask;

var localized string msgKeyLocked, msgKeyUnlocked, msgNoNanoKey, CountRemainingString, CanCarryOnlyOneBinocs;

var globalconfig float RainMultiplier;

var(Radish) globalconfig bool Platform_01_Unlocked, Platform_02_Unlocked, Platform_RadishKingdom_Unlocked, Platform_RadishRamparts_Unlocked, Platform_RadishCove_Unlocked;

// Items without item refusal:
// DogBlood, FistPickup, FloppyDisk, GoatDisguise, KarkianSnot, NosferatusTeeth, PaintingTube, PosterTube, UraniumStick, VirusDisk, Credits2000, WineBottleTrigger, WeaponLAWSpent, WeaponYAAAARRGHPistol

// Items with shared item refusal:
// WeaponFoon/WeaponThrowFoon
// WeaponSpork/WeaponSporkGolden/WeaponThrowSpork
// WeaponFireExting/FireExtinguisher
// WeaponKatana/WeaponKatanaRonin/WeaponKatanaSlicer/WeaponDaikatana
// Each unique weapon with its base model



var Name tempConvertedName;
var bool bClientUIInitialized;
var float subtitleClearTimer;
var float infolinkClearTimer;
var string lastClientInfoLinkSpeaker;
var string lastClientInfoLinkSpeech;
var Trestkon pendingCoopInitiator;
var bool bClientInThirdPersonConvo;
var bool bWasClientInThirdPersonConvo;
var Actor clientConvoTarget;
var vector clientConvoTargetLoc;
var bool bClientHasConChoices;
var int clientConChoiceCount;
var int clientSelectedConChoice;
var string clientConChoices[10];
var float lastConChoiceConfirmTime;
var int lastSyncedCredits;
var bool bCoopCreditsInit;
var int lastKnownCredits;
var int lastServerAugLevelSum;
var int lastClientAugLevelSum;
var int lastSentMovePrefs;
var bool bSentMovePrefs;
var int coopWeaponSyncIndex;

// last device/NPC state sent to this player's client (tnmGameInfo.SyncCoopState)
var Name coopDevName[128];
var int coopDevSig[128];
var float coopDevTime[128];
var config int coopCharacterModel;
var config int coopSavedCustomPreset;
var String coopPlayerName;
var config String coopLastServerIP;
var config bool bCoopYuukaHat;
var bool bCoopNamedProfileRestored;
var String lastRestoredProfileName;
var YuukaPingMarker activePingMarker;
var YuukaHeadCompanion activeYuukaHat;
var bool bCoopPingBindChecked;
var float activePingTime;
var float activePingDuration;
var Vector activePingLoc;
var Actor activePingActor;
var String activePingLabel;
var String activePingOwnerName;
var byte activePingType;
var Actor coopSpectateTarget;
var bool bCoopInHealthScreenHeal;
var vector coopPreAdjustLoc;
var bool bCoopHadPreAdjustLoc;
var vector coopVisualSmoothOffset;
var TNMOggMusicManager cachedClientOgg;
var bool bCoopPendingConnect;
var String coopConnectingIP;
var String coopLastConnectError;
var int coopClientTalkSoundID;
var vector coopLastClientBlastLoc;
var float coopLastClientBlastTime;

//
// network replication
//
replication
{
    // server to client
    reliable if ((Role == ROLE_Authority) && (bNetOwner))
        playerfists, bClientInThirdPersonConvo, clientConvoTarget, clientConvoTargetLoc, bSkating;
    reliable if (Role == ROLE_Authority)
        coopCharacterModel, coopPlayerName, bCoopYuukaHat, coopSpectateTarget;
    // Functions: no bNetOwner here. It is only meaningful while variables are
    // being replicated; at call time it can be stale, and the call then runs on
    // the server instead of being sent (seen with ClientPlayOgg). Client
    // functions only ever go to the owning connection anyway.
    reliable if (Role == ROLE_Authority)
        ClientSyncBoolFlag, ClientSyncGoal, ClientSyncNote, ClientPlayDataLink,
        ClientShowSubtitle, ClientHideSubtitle, ClientPlayOgg,
        ClientSyncMoverState, ClientSyncHackableState, ClientAddBark, ClientPrepareTravel,
        ClientReceiveCoopPing, ClientCoopRevived,
        ClientOpenCoopKeypad, ClientPlayConAudio, ClientPlayExplosionFX, ClientPlayBurningTelegraph,
        ClientReceiveCoopChat;
    unreliable if (Role == ROLE_Authority)
        ClientSyncWeaponMods;
	reliable if (Role < ROLE_Authority)
		FloorTexture, footprintoffset, bWalkingOnSnow, bWalkingBackwards,
		  SelectFists, Give, kill, StartSkates, StopSkates, ignite, douse,
		  SpawnFootprint, bMustJump, jumpBob, ServerSyncBoolFlag, clientSelectedConChoice,
		  CoopSave, CoopContinue, ServerSetMovementPrefs,
		  ServerSetCoopModel, ServerSetCoopName, ServerCoopPing, ServerCoopTradeItem,
		  ServerCoopTradeAmmo, ServerCoopDropAmmo,
		  ServerSetYuukaHat, ServerCycleDeadSpectate, ServerMedkitYuuka1;
}

// ----------------------------------------------------------------------
// Co-op movement prefs
//
// HandleWalking() runs on the server for remote players (MoveAutonomous), but
// bAlwaysRun/bToggleCrouch are globalconfig and bToggleWalk is flipped by a
// client-only exec, so the server used the host's settings and simulated the
// client walking/crouching differently than the client predicted.
// ----------------------------------------------------------------------

simulated function CoopSendMovementPrefs()
{
	local int prefs;

	if (bAlwaysRun)
		prefs = prefs | 1;
	if (bToggleCrouch)
		prefs = prefs | 2;
	if (bToggleWalk)
		prefs = prefs | 4;

	if (bSentMovePrefs && (prefs == lastSentMovePrefs))
		return;

	bSentMovePrefs = True;
	lastSentMovePrefs = prefs;
	ServerSetMovementPrefs(bAlwaysRun, bToggleCrouch, bToggleWalk);
}

function ServerSetMovementPrefs(bool bNewAlwaysRun, bool bNewToggleCrouch, bool bNewToggleWalk)
{
	if ((Level.NetMode == NM_Standalone) || (Viewport(Player) != None))
		return;

	bAlwaysRun = bNewAlwaysRun;
	bToggleWalk = bNewToggleWalk;
	// Do NOT enable bToggleCrouch on the server's remote pawn: the client's
	// HandleWalking() already resolves bCrouchOn into bDuck before ReplicateMove
	// records SavedMove.bDuck, so NewbDuck in ServerMove is already post-toggle.
	bToggleCrouch = False;
	bCrouchOn = False;
	bWasCrouchOn = False;
}

function HandleWalking()
{
	local bool bSavedToggleCrouch;

	if (((Role == ROLE_Authority) && (Level.NetMode != NM_Standalone) && (Viewport(Player) == None)) || bUpdating)
	{
		bSavedToggleCrouch = bToggleCrouch;
		bToggleCrouch = False;
		Super.HandleWalking();
		bToggleCrouch = bSavedToggleCrouch;
		bIsCrouching = (bDuck != 0);
		return;
	}

	Super.HandleWalking();
}

function ReplicateMove
(
	float DeltaTime,
	vector NewAccel,
	eDodgeDir DodgeMove,
	rotator DeltaRot
)
{
	local SavedMove NewMove, OldMove, LastMove;
	local byte ClientRoll;
	local float OldTimeDelta, TotalTime, NetMoveDelta;
	local int OldAccel;
	local vector BuildAccel, AccelNorm, prevloc, prevvelocity;
	local float AdjPCol, SavedRadius;
	local pawn SavedPawn, P;
	local vector Dist;
	local bool HighVelocityDelta;

	HighVelocityDelta = false;
	if ( PendingMove != None )
	{
		PendingMove.TimeStamp = Level.TimeSeconds;
		if ( VSize(NewAccel) > 3072 )
			NewAccel = 3072 * Normal(NewAccel);
		TotalTime = PendingMove.Delta + DeltaTime;
		PendingMove.Acceleration = (DeltaTime * NewAccel + PendingMove.Delta * PendingMove.Acceleration)/TotalTime;

		if ( PendingMove.DodgeMove == DODGE_None )
			PendingMove.DodgeMove = DodgeMove;
		PendingMove.bRun = (bRun > 0);
		PendingMove.bDuck = (bDuck > 0);
		PendingMove.bPressedJump = bPressedJump || PendingMove.bPressedJump;
		PendingMove.bFire = PendingMove.bFire || bJustFired || (bFire != 0);
		PendingMove.bForceFire = PendingMove.bForceFire || bJustFired;
		PendingMove.bAltFire = PendingMove.bAltFire || bJustAltFired || (bAltFire != 0);
		PendingMove.bForceAltFire = PendingMove.bForceAltFire || bJustFired;
		PendingMove.Delta = TotalTime;
	}
	if ( SavedMoves != None )
	{
		NewMove = SavedMoves;
		AccelNorm = Normal(NewAccel);
		while ( NewMove.NextMove != None )
		{
			if ( NewMove.bPressedJump || ((NewMove.DodgeMove != Dodge_NONE) && (NewMove.DodgeMove < 5))
				|| ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
				OldMove = NewMove;
			NewMove = NewMove.NextMove;
		}
		if ( NewMove.bPressedJump || ((NewMove.DodgeMove != Dodge_NONE) && (NewMove.DodgeMove < 5))
			|| ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
			OldMove = NewMove;
	}

	LastMove = NewMove;
	NewMove = GetFreeMove();
	NewMove.Delta = DeltaTime;
	if ( VSize(NewAccel) > 3072 )
		NewAccel = 3072 * Normal(NewAccel);
	NewMove.Acceleration = NewAccel;

	NewMove.DodgeMove = DodgeMove;
	NewMove.TimeStamp = Level.TimeSeconds;
	NewMove.bRun = (bRun > 0);
	NewMove.bDuck = (bDuck > 0);
	NewMove.bPressedJump = bPressedJump;
	NewMove.bFire = (bJustFired || (bFire != 0));
	NewMove.bForceFire = bJustFired;
	NewMove.bAltFire = (bJustAltFired || (bAltFire != 0));
	NewMove.bForceAltFire = bJustAltFired;
	if ( Weapon != None )
		Weapon.bPointing = ((bFire != 0) || (bAltFire != 0));
	bJustFired = false;
	bJustAltFired = false;

	if ( PlayerReplicationInfo != None )
	{
		for (P = Level.PawnList; P != None; P = P.NextPawn)
		{
			if ( (P != self) && (P.Velocity != vect(0,0,0)) && P.bBlockPlayers )
			{
				Dist = P.Location - Location;
				AdjPCol = 0.0004 * PlayerReplicationInfo.Ping * ((P.Velocity - Velocity) Dot Normal(Dist));
				if ( VSize(Dist) < AdjPCol + P.CollisionRadius + CollisionRadius + NewMove.Delta * GroundSpeed * (Normal(Velocity) Dot Normal(Dist)) )
				{
					SavedPawn = P;
					SavedRadius = P.CollisionRadius;
					Dist.Z = 0;
					P.SetCollisionSize(FClamp(AdjPCol + P.CollisionRadius, 0.5 * P.CollisionRadius, VSize(Dist) - CollisionRadius - P.CollisionRadius), P.CollisionHeight);
					break;
				}
			}
		}
	}

	prevloc = Location;
	prevvelocity = Velocity;
	ProcessMove(NewMove.Delta, NewMove.Acceleration, NewMove.DodgeMove, DeltaRot * (NewMove.Delta / DeltaTime));
	AutonomousPhysics(NewMove.Delta);
	HighVelocityDelta = VelocityChanged(prevvelocity, Velocity);

	if ( SavedPawn != None )
		SavedPawn.SetCollisionSize(SavedRadius, SavedPawn.CollisionHeight);

	if ( PendingMove == None )
		PendingMove = NewMove;
	else
	{
		NewMove.NextMove = FreeMoves;
		FreeMoves = NewMove;
		FreeMoves.Clear();
		NewMove = PendingMove;
	}

	if ( Player != None )
		NetMoveDelta = FMax(64.0/Player.CurrentNetSpeed, 0.011);
	else
		NetMoveDelta = 0.011;

	if (!PendingMove.bForceFire && !PendingMove.bForceAltFire && !PendingMove.bPressedJump && !(Physics == PHYS_Falling) && (Player != None))
	{
		if ((VSize(Velocity) < 5.0) && (!HighVelocityDelta))
			NetMoveDelta = FMax(NetMoveDelta, Player.StaticUpdateInterval);
		else if (!HighVelocityDelta)
			NetMoveDelta = FMax(NetMoveDelta, Player.DynamicUpdateInterval);
	}

	if (ClientUpdateTime < (-1 * NetMoveDelta))
		ClientUpdateTime = 0;

	if ( !PendingMove.bForceFire && !PendingMove.bForceAltFire && !PendingMove.bPressedJump
		&& (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
	{
		return;
	}
	else if ( (ClientUpdateTime < 0) && (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
		return;
	else
	{
		ClientUpdateTime = PendingMove.Delta - NetMoveDelta;

		if ( SavedMoves == None )
			SavedMoves = PendingMove;
		else
			LastMove.NextMove = PendingMove;
		PendingMove = None;
	}

	if ( OldMove != None )
	{
		OldTimeDelta = FMin(255, (Level.TimeSeconds - OldMove.TimeStamp) * 500);
		BuildAccel = 0.05 * OldMove.Acceleration + vect(0.5, 0.5, 0.5);
		OldAccel = (CompressAccel(BuildAccel.X) << 23)
					+ (CompressAccel(BuildAccel.Y) << 15)
					+ (CompressAccel(BuildAccel.Z) << 7);
		if ( OldMove.bRun )
			OldAccel += 64;
		if ( OldMove.bDuck )
			OldAccel += 32;
		if ( OldMove.bPressedJump )
			OldAccel += 16;
		OldAccel += OldMove.DodgeMove;
	}

	ClientRoll = (Rotation.Roll >> 8) & 255;
	if ( NewMove.bPressedJump )
		bJumpStatus = !bJumpStatus;
	ServerMove
	(
		NewMove.TimeStamp,
		NewMove.Acceleration * 10,
		Location,
		NewMove.bRun,
		NewMove.bDuck,
		bJumpStatus,
		NewMove.bFire,
		NewMove.bAltFire,
		NewMove.bForceFire,
		NewMove.bForceAltFire,
		NewMove.DodgeMove,
		ClientRoll,
		(32767 & (ViewRotation.Pitch/2)) * 32768 + (32767 & (ViewRotation.Yaw/2)),
		OldTimeDelta,
		OldAccel
	);
}

function ServerMove
(
	float TimeStamp,
	vector InAccel,
	vector ClientLoc,
	bool NewbRun,
	bool NewbDuck,
	bool NewbJumpStatus,
	bool bFired,
	bool bAltFired,
	bool bForceFire,
	bool bForceAltFire,
	eDodgeDir DodgeMove,
	byte ClientRoll,
	int View,
	optional byte OldTimeDelta,
	optional int OldAccel
)
{
	local float DeltaTime, clientErr, OldTimeStamp, errThreshold;
	local rotator DeltaRot, Rot;
	local vector Accel, LocDiff;
	local int maxPitch, ViewPitch, ViewYaw;
	local actor OldBase;
	local bool NewbPressedJump, OldbRun, OldbDuck;
	local eDodgeDir OldDodgeMove;

	// If this move is outdated, discard it.
	if ( CurrentTimeStamp >= TimeStamp )
		return;

	// if OldTimeDelta corresponds to a lost packet, process it first
	if ( OldTimeDelta != 0 )
	{
		OldTimeStamp = TimeStamp - float(OldTimeDelta)/500 - 0.001;
		if ( CurrentTimeStamp < OldTimeStamp - 0.001 )
		{
			// split out components of lost move (approx)
			Accel.X = OldAccel >>> 23;
			if ( Accel.X > 127 )
				Accel.X = -1 * (Accel.X - 128);
			Accel.Y = (OldAccel >>> 15) & 255;
			if ( Accel.Y > 127 )
				Accel.Y = -1 * (Accel.Y - 128);
			Accel.Z = (OldAccel >>> 7) & 255;
			if ( Accel.Z > 127 )
				Accel.Z = -1 * (Accel.Z - 128);
			Accel *= 20;

			OldbRun = ( (OldAccel & 64) != 0 );
			OldbDuck = ( (OldAccel & 32) != 0 );
			NewbPressedJump = ( (OldAccel & 16) != 0 );
			if ( NewbPressedJump )
				bJumpStatus = NewbJumpStatus;

			switch (OldAccel & 7)
			{
				case 0:
					OldDodgeMove = DODGE_None;
					break;
				case 1:
					OldDodgeMove = DODGE_Left;
					break;
				case 2:
					OldDodgeMove = DODGE_Right;
					break;
				case 3:
					OldDodgeMove = DODGE_Forward;
					break;
				case 4:
					OldDodgeMove = DODGE_Back;
					break;
			}
			MoveAutonomous(OldTimeStamp - CurrentTimeStamp, OldbRun, OldbDuck, NewbPressedJump, OldDodgeMove, Accel, rot(0,0,0));
			CurrentTimeStamp = OldTimeStamp;
		}
	}

	// View components
	ViewPitch = View/32768;
	ViewYaw = 2 * (View - 32768 * ViewPitch);
	ViewPitch *= 2;
	// Make acceleration.
	Accel = InAccel/10;

	NewbPressedJump = (bJumpStatus != NewbJumpStatus);
	bJumpStatus = NewbJumpStatus;

	// handle firing and alt-firing
	if ( bFired )
	{
		if ( bForceFire && (Weapon != None) )
			Weapon.ForceFire();
		else if ( bFire == 0 )
			Fire(0);
		bFire = 1;
	}
	else
		bFire = 0;

	if ( bAltFired )
	{
		if ( bForceAltFire && (Weapon != None) )
			Weapon.ForceAltFire();
		else if ( bAltFire == 0 )
			AltFire(0);
		bAltFire = 1;
	}
	else
		bAltFire = 0;

	// Save move parameters.
	DeltaTime = TimeStamp - CurrentTimeStamp;
	if ( ServerTimeStamp > 0 )
	{
		// Relax TimeMargin in co-op so high-ping packet bursts never zero out DeltaTime
		TimeMargin += DeltaTime - 1.05 * (Level.TimeSeconds - ServerTimeStamp);
		if ( TimeMargin < -1.0 )
			TimeMargin = -1.0;
		if ( TimeMargin > 2.5 )
		{
			TimeMargin -= DeltaTime;
			DeltaTime = 0;
		}
	}

	CurrentTimeStamp = TimeStamp;
	ServerTimeStamp = Level.TimeSeconds;
	Rot.Roll = 256 * ClientRoll;
	Rot.Yaw = ViewYaw;
	if ( (Physics == PHYS_Swimming) || (Physics == PHYS_Flying) )
		maxPitch = 2;
	else
		maxPitch = 1;
	if ( (ViewPitch > maxPitch * RotationRate.Pitch) && (ViewPitch < 65536 - maxPitch * RotationRate.Pitch) )
	{
		if (ViewPitch < 32768)
			Rot.Pitch = maxPitch * RotationRate.Pitch;
		else
			Rot.Pitch = 65536 - maxPitch * RotationRate.Pitch;
	}
	else
		Rot.Pitch = ViewPitch;

	if ( Level.NetMode != NM_Standalone )
		Rot.Pitch = 0;

	DeltaRot = (Rotation - Rot);
	ViewRotation.Pitch = ViewPitch;
	ViewRotation.Yaw = ViewYaw;
	ViewRotation.Roll = 0;
	SetRotation(Rot);

	OldBase = Base;

	// Perform actual movement.
	if ( (Level.Pauser == "") && (DeltaTime > 0) )
		MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbPressedJump, DodgeMove, Accel, DeltaRot);

	// Compute actual positional error (never force a blind ClientErr=10000 snap every 2s)
	if ( (Level.TimeSeconds - LastUpdateTime > 180.0/Player.CurrentNetSpeed) || (Level.TimeSeconds - LastUpdateTime > 0.25) )
	{
		LocDiff = Location - ClientLoc;
		clientErr = LocDiff Dot LocDiff;
	}

	if ( Level.TimeSeconds - LastUpdateTime > 2.0 )
		errThreshold = 9.0;
	else
		errThreshold = 25.0;

	if ( (clientErr > errThreshold) || (OldBase != Base) )
	{
		if ( Mover(Base) != None )
			ClientLoc = Location - Base.Location;
		else
			ClientLoc = Location;
		LastUpdateTime = Level.TimeSeconds;
		ClientAdjustPosition
		(
			TimeStamp,
			GetStateName(),
			Physics,
			ClientLoc.X,
			ClientLoc.Y,
			ClientLoc.Z,
			Velocity.X,
			Velocity.Y,
			Velocity.Z,
			Base
		);
	}
	MultiplayerTick(DeltaTime);
}

function ClientAdjustPosition
(
	float TimeStamp,
	name newState,
	EPhysics newPhysics,
	float NewLocX,
	float NewLocY,
	float NewLocZ,
	float NewVelX,
	float NewVelY,
	float NewVelZ,
	Actor NewBase
)
{
	if ( CurrentTimeStamp > TimeStamp )
		return;

	if ( !bUpdatePosition && !bCoopHadPreAdjustLoc )
	{
		coopPreAdjustLoc = Location;
		bCoopHadPreAdjustLoc = True;
	}

	Super.ClientAdjustPosition(TimeStamp, newState, newPhysics, NewLocX, NewLocY, NewLocZ, NewVelX, NewVelY, NewVelZ, NewBase);
}

function ClientUpdatePosition()
{
	local SavedMove CurrentMove;
	local int realbRun, realbDuck;
	local bool bRealJump;
	local float AdjPCol, SavedRadius, TotalTime, ErrDist;
	local pawn SavedPawn, P;
	local vector Dist, ErrDiff;

	bUpdatePosition = false;
	realbRun = bRun;
	realbDuck = bDuck;
	bRealJump = bPressedJump;
	CurrentMove = SavedMoves;
	bUpdating = true;
	while ( CurrentMove != None )
	{
		if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
		{
			SavedMoves = CurrentMove.NextMove;
			CurrentMove.NextMove = FreeMoves;
			FreeMoves = CurrentMove;
			FreeMoves.Clear();
			CurrentMove = SavedMoves;
		}
		else
		{
			if ( (TotalTime > 0) && (PlayerReplicationInfo != None) )
			{
				for (P = Level.PawnList; P != None; P = P.NextPawn)
				{
					if ( (P != self) && (P.Velocity != vect(0,0,0)) && P.bBlockPlayers )
					{
						Dist = P.Location - Location;
						AdjPCol = 0.0004 * PlayerReplicationInfo.Ping * ((P.Velocity - Velocity) Dot Normal(Dist));
						if ( VSize(Dist) < AdjPCol + P.CollisionRadius + CollisionRadius + CurrentMove.Delta * GroundSpeed * (Normal(Velocity) Dot Normal(Dist)) )
						{
							SavedPawn = P;
							SavedRadius = P.CollisionRadius;
							Dist.Z = 0;
							P.SetCollisionSize(FClamp(AdjPCol + P.CollisionRadius, 0.5 * P.CollisionRadius, VSize(Dist) - CollisionRadius - P.CollisionRadius), P.CollisionHeight);
							break;
						}
					}
				}
			}
			TotalTime += CurrentMove.Delta;
			MoveAutonomous(CurrentMove.Delta, CurrentMove.bRun, CurrentMove.bDuck, CurrentMove.bPressedJump, CurrentMove.DodgeMove, CurrentMove.Acceleration, rot(0,0,0));
			CurrentMove = CurrentMove.NextMove;
			if ( SavedPawn != None )
			{
				SavedPawn.SetCollisionSize(SavedRadius, SavedPawn.CollisionHeight);
				SavedPawn = None;
			}
		}
	}

	// Replay PendingMove WITHOUT destroying it so ReplicateMove still appends it to SavedMoves!
	if ( PendingMove != None )
	{
		if ( PendingMove.TimeStamp <= CurrentTimeStamp )
		{
			PendingMove.NextMove = FreeMoves;
			FreeMoves = PendingMove;
			FreeMoves.Clear();
			PendingMove = None;
		}
		else
		{
			MoveAutonomous(PendingMove.Delta, PendingMove.bRun, PendingMove.bDuck, PendingMove.bPressedJump, PendingMove.DodgeMove, PendingMove.Acceleration, rot(0,0,0));
		}
	}

	bUpdating = false;
	bDuck = realbDuck;
	bRun = realbRun;
	bPressedJump = bRealJump;

	// Pure visual camera/viewmodel smoothing: keep Location 100% authoritative so
	// future ServerMove packets accumulate zero artificial error, while gliding the
	// camera + first-person weapon smoothly over ~120ms.
	if ( bCoopHadPreAdjustLoc )
	{
		bCoopHadPreAdjustLoc = False;
		ErrDiff = coopPreAdjustLoc - Location;
		ErrDist = VSize(ErrDiff);
		if ( (ErrDist > 0.05) && (ErrDist < 48.0) )
		{
			coopVisualSmoothOffset += ErrDiff;
			if ( VSize(coopVisualSmoothOffset) > 36.0 )
				coopVisualSmoothOffset = Normal(coopVisualSmoothOffset) * 36.0;
		}
		else if ( ErrDist >= 48.0 )
		{
			coopVisualSmoothOffset = vect(0, 0, 0);
		}
	}
}

// ----------------------------------------------------------------------
// Co-op movement speed
//
// DeusExPlayer.ProcessMove/GetCurrentGroundSpeed switch to deathmatch rules
// whenever NetMode != NM_Standalone (no leg damage slowdown, no backpedal
// penalty, DM heavy weapon formula and GEP turn rate). Re-apply the
// singleplayer rules on both client and server so prediction matches.
// ----------------------------------------------------------------------

function CoopApplySinglePlayerGroundSpeed(vector newAccel)
{
	local float defSpeed, newSpeed;
	local rotator flatRot;
	local vector carcLookDir;

	defSpeed = GetCurrentGroundSpeed();
	newSpeed = defSpeed;

	if (HealthLegLeft < 1)
		newSpeed -= (defSpeed/2) * 0.25;
	else if (HealthLegLeft < 34)
		newSpeed -= (defSpeed/2) * 0.15;
	else if (HealthLegLeft < 67)
		newSpeed -= (defSpeed/2) * 0.10;

	if (HealthLegRight < 1)
		newSpeed -= (defSpeed/2) * 0.25;
	else if (HealthLegRight < 34)
		newSpeed -= (defSpeed/2) * 0.15;
	else if (HealthLegRight < 67)
		newSpeed -= (defSpeed/2) * 0.10;

	if (HealthTorso < 67)
		newSpeed -= (defSpeed/2) * 0.05;

	if ((HealthLegLeft < 1) && (HealthLegRight < 1))
	{
		newSpeed = defSpeed * 0.8;
		bIsWalking = True;
		bForceDuck = True;
	}
	else if (bIsCrouching || bForceDuck)
		bIsWalking = True;

	if (CarriedDecoration != None)
	{
		if (CarriedDecoration.IsA('DeusExCarcass'))
		{
			newSpeed -= 60.0;
			if (Role == ROLE_Authority)
			{
				carcLookDir = Vector(Rotation);
				carcLookDir.Z = 0;
				if (VSize(carcLookDir) > 0.001)
					carcLookDir = Normal(carcLookDir);
				CarriedDecoration.bCollideWorld = False;
				CarriedDecoration.SetCollision(False, False, False);
				CarriedDecoration.SetLocation(Location + vect(0, 0, -8) + 32.0 * carcLookDir);
				CarriedDecoration.SetRotation(Rotation);
				CarriedDecoration.SetBase(Self);
			}
		}
		else
			newSpeed -= CarriedDecoration.Mass * 2;
	}
	else if ((DeusExWeapon(Weapon) != None) && (Weapon.Mass > 30) && (DeusExWeapon(Weapon).GetWeaponSkill() > -0.25))
	{
		bIsWalking = True;
		newSpeed = defSpeed;
	}
	else if ((inHand != None) && inHand.IsA('POVCorpse'))
		newSpeed -= inHand.Mass * 3;

	TurnRateAdjuster = 1.0;

	if ((newSpeed <= defSpeed / 3) && !bForceDuck)
	{
		bIsWalking = True;
		newSpeed = defSpeed;
	}

	// Note: Do NOT apply a Rotation-based backpedal 0.65 multiplier in netplay!
	// SavedMove does not store Rotation.Yaw, so replaying SavedMoves in
	// ClientUpdatePosition while turning/strafing evaluates (newAccel Dot vector(Rotation))
	// against the client's current yaw instead of the historical yaw, causing 35% speed
	// mismatches and rubberbanding (same reason DeusExPlayer disables it in netplay).
	if ((aForward < 0) && (Level.NetMode == NM_Standalone))
		newSpeed *= 0.65;

	GroundSpeed = FMax(newSpeed, 100);
}

// ----------------------------------------------------------------------
// Co-op weapon mod stats
//
// Weapon mod results (scope, clip size, recoil, accuracy, range, reload time)
// are not replicated by DeusExWeapon, so the client's inventory screen, scope
// toggle and crosshair used stale values. Push the held weapon plus one other
// weapon per call (called once a second from tnmGameInfo.SyncCoopState).
// ----------------------------------------------------------------------

// ----------------------------------------------------------------------
// CoopDeviceChanged()
//
// SyncCoopState used to resend every mover/hackable/NPC-alliance state near
// the client once a second whether it changed or not (~29 reliable RPCs a
// second in busy maps). Returns true when the state differs from what this
// client was last sent, or every 10 seconds as a keepalive.
// ----------------------------------------------------------------------

function bool CoopDeviceChanged(Name devName, int sig)
{
	local int i, slot;

	slot = -1;
	for (i = 0; i < ArrayCount(coopDevName); i++)
	{
		if (coopDevName[i] == devName)
		{
			if ((coopDevSig[i] == sig) && (Level.TimeSeconds - coopDevTime[i] < 10.0))
				return False;
			coopDevSig[i] = sig;
			coopDevTime[i] = Level.TimeSeconds;
			return True;
		}
		if ((slot == -1) && (coopDevName[i] == ''))
			slot = i;
	}

	if (slot == -1)
	{
		// full: reuse the entry sent longest ago
		slot = 0;
		for (i = 1; i < ArrayCount(coopDevName); i++)
			if (coopDevTime[i] < coopDevTime[slot])
				slot = i;
	}
	coopDevName[slot] = devName;
	coopDevSig[slot] = sig;
	coopDevTime[slot] = Level.TimeSeconds;
	return True;
}

function CoopSyncWeaponMods()
{
	local Inventory Inv;
	local DeusExWeapon W;
	local int i;

	if (DeusExWeapon(Weapon) != None)
		CoopSendWeaponMods(DeusExWeapon(Weapon));

	for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if ((DeusExWeapon(Inv) != None) && (Inv != Weapon))
		{
			if (i == coopWeaponSyncIndex)
			{
				W = DeusExWeapon(Inv);
				break;
			}
			i++;
		}
	}

	if (W != None)
	{
		CoopSendWeaponMods(W);
		coopWeaponSyncIndex++;
	}
	else
		coopWeaponSyncIndex = 0;
}

function CoopSendWeaponMods(DeusExWeapon W)
{
	local byte modFlags, ammoIdx, attrByte;
	local int katLvl, a1, a2, k;
	local TNMWeapon TW;

	if (W == None)
		return;

	if (W.bHasScope)    modFlags = modFlags | 1;
	if (W.bHasLaser)    modFlags = modFlags | 2;
	if (W.bHasSilencer) modFlags = modFlags | 4;
	if (W.bAutomatic)   modFlags = modFlags | 8;

	ammoIdx = 255;
	for (k = 0; k < 3; k++)
	{
		if (W.AmmoNames[k] != None && ((W.AmmoType != None && W.AmmoType.Class == W.AmmoNames[k]) || W.AmmoName == W.AmmoNames[k]))
		{
			ammoIdx = byte(k);
			break;
		}
	}

	TW = TNMWeapon(W);
	if (TW != None)
	{
		katLvl   = TW.katanaLevel;
		attrByte = TW.Attribute;
		a1       = TW.Attributes1;
		a2       = TW.Attributes2;
	}

	ClientSyncWeaponMods(W, modFlags, ammoIdx, W.ReloadCount, W.recoilStrength, W.BaseAccuracy, W.AccurateRange, W.ReloadTime, byte(Clamp(katLvl, 0, 255)), attrByte, a1, a2);
}

simulated function ClientSyncWeaponMods(DeusExWeapon W, byte NewModFlags, byte NewAmmoIdx, byte NewReloadCount, float NewRecoil, float NewBaseAccuracy, int NewAccurateRange, float NewReloadTime, byte NewKatanaLvl, byte NewAttrByte, int NewAttr1, int NewAttr2)
{
	local TNMWeapon TW;

	if ((W == None) || (Role == ROLE_Authority))
		return;

	W.bHasScope    = ((NewModFlags & 1) != 0);
	W.bHasLaser    = ((NewModFlags & 2) != 0);
	W.bHasSilencer = ((NewModFlags & 4) != 0);
	W.bAutomatic   = ((NewModFlags & 8) != 0);
	W.ReloadCount = NewReloadCount;
	W.recoilStrength = NewRecoil;
	W.BaseAccuracy = NewBaseAccuracy;
	W.AccurateRange = NewAccurateRange;
	W.ReloadTime = NewReloadTime;

	if (NewAmmoIdx < 3 && W.AmmoNames[NewAmmoIdx] != None)
	{
		W.AmmoName = W.AmmoNames[NewAmmoIdx];
		if (W.ProjectileNames[NewAmmoIdx] == None)
		{
			W.bInstantHit = True;
			W.FireSound = W.Default.FireSound;
			W.ProjectileClass = None;
		}
		else
		{
			W.bInstantHit = False;
			W.FireSound = None;
			W.ProjectileClass = W.ProjectileNames[NewAmmoIdx];
			W.ProjectileSpeed = W.ProjectileClass.Default.Speed;
		}
	}
	else if (W.AmmoType != None)
	{
		W.AmmoName = W.AmmoType.Class;
	}

	TW = TNMWeapon(W);
	if (TW != None)
	{
		TW.katanaLevel = NewKatanaLvl;
		TW.SetCoopSavedAttributes(NewAttrByte, NewAttr1, NewAttr2);
	}
}

// Server-side belt tracking for remote clients (whose rootWindow is None on the server)
function ClearPosition(int pos)
{
	local Inventory inv;

	if (DeusExRootWindow(rootWindow) != None)
	{
		Super.ClearPosition(pos);
		return;
	}

	for (inv = Inventory; inv != None; inv = inv.Inventory)
	{
		if (inv.bInObjectBelt && inv.beltPos == pos)
		{
			inv.bInObjectBelt = False;
			inv.beltPos = -1;
		}
	}
}

function ClearBelt()
{
	local Inventory inv;

	if (DeusExRootWindow(rootWindow) != None)
	{
		Super.ClearBelt();
		return;
	}

	for (inv = Inventory; inv != None; inv = inv.Inventory)
	{
		if (inv.bInObjectBelt && !inv.IsA('NanoKeyRing'))
		{
			inv.bInObjectBelt = False;
			inv.beltPos = -1;
		}
	}
}

function RemoveObjectFromBelt(Inventory item)
{
	if (DeusExRootWindow(rootWindow) != None)
	{
		Super.RemoveObjectFromBelt(item);
		return;
	}

	if (item != None)
	{
		item.bInObjectBelt = False;
		item.beltPos = -1;
	}
}

function AddObjectToBelt(Inventory item, int pos, bool bOverride)
{
	local Inventory inv;
	local int i, maxSlot;
	local bool bTaken;

	if (DeusExRootWindow(rootWindow) != None)
	{
		Super.AddObjectToBelt(item, pos, bOverride);
		return;
	}

	if (item == None || item.Icon == None)
		return;

	if (item.IsA('NanoKeyRing'))
	{
		ClearPosition(0);
		item.bInObjectBelt = True;
		item.beltPos = 0;
		return;
	}

	maxSlot = 9;
	if (bEnlargedBelt)
		maxSlot = 11;

	if (pos < 1 || pos > maxSlot)
	{
		pos = -1;
		for (i = 1; i <= maxSlot; i++)
		{
			bTaken = False;
			for (inv = Inventory; inv != None; inv = inv.Inventory)
			{
				if (inv != item && inv.bInObjectBelt && inv.beltPos == i)
				{
					bTaken = True;
					break;
				}
			}
			if (!bTaken)
			{
				pos = i;
				break;
			}
		}
		if (pos == -1 && bOverride)
			pos = 1;
	}

	if (pos >= 1 && pos <= maxSlot)
	{
		for (inv = Inventory; inv != None; inv = inv.Inventory)
		{
			if (inv != item && inv.bInObjectBelt && inv.beltPos == pos)
			{
				inv.bInObjectBelt = False;
				inv.beltPos = -1;
			}
		}
		item.bInObjectBelt = True;
		item.beltPos = pos;
	}
}

// ----------------------------------------------------------------------
// CreateNanoKeyInfo()
//
// Keys are copied between players every second in co-op. new(Self) binds the
// key's Outer to this pawn, which is destroyed on travel and trips
// "Removed!=0" (UnObj.cpp) on exit.
// ----------------------------------------------------------------------

function NanoKeyInfo CreateNanoKeyInfo()
{
	if (Level.NetMode != NM_Standalone)
		return new(None) Class'NanoKeyInfo';
	return Super.CreateNanoKeyInfo();
}

simulated function ClientPrepareTravel()
{
	local TNMOggMusicManager ogg;
	local String localName;

	if (Viewport(Player) != None)
	{
		localName = GetLocalCoopPlayerName();
		if (localName != "")
			UpdateURL("Name", class'CoopLocalPrefs'.static.EncodeURLName(localName), True);
	}

	if (Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;
	foreach AllActors(class'TNMOggMusicManager', ogg)
	{
		ogg.CoopNativeStop();
	}
	if (DeusExRootWindow(rootWindow) != None)
		DeusExRootWindow(rootWindow).ClearWindowStack();
}

simulated function ClientAddBark(string speech, float duration, Actor barkActor, string fallbackName)
{
	local DeusExRootWindow root;
	local string savedUnfamiliar;

	if (Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;

	root = DeusExRootWindow(rootWindow);
	if (root != None && root.hud != None && root.hud.barkDisplay != None && speech != "")
	{
		if (barkActor != None)
		{
			root.hud.barkDisplay.AddBark(speech, duration, barkActor);
		}
		else
		{
			savedUnfamiliar = UnfamiliarName;
			if (fallbackName != "")
				UnfamiliarName = fallbackName;
			else
				UnfamiliarName = "NPC";
			root.hud.barkDisplay.AddBark(speech, duration, Self);
			UnfamiliarName = savedUnfamiliar;
		}
	}
}

function CheckServerAugCanConsumption()
{
	local Augmentation anAug;
	local AugmentationUpgradeCannister augCan;
	local int curSum, diff, i;

	if (Role < ROLE_Authority || NetConnection(Player) == None || AugmentationSystem == None)
		return;

	curSum = 0;
	for (anAug = AugmentationSystem.FirstAug; anAug != None; anAug = anAug.next)
	{
		if (anAug.bHasIt)
			curSum += (anAug.CurrentLevel + 1);
	}

	if (lastServerAugLevelSum > 0 && curSum > lastServerAugLevelSum)
	{
		diff = curSum - lastServerAugLevelSum;
		for (i = 0; i < diff; i++)
		{
			augCan = AugmentationUpgradeCannister(FindInventoryType(class'AugmentationUpgradeCannister'));
			if (augCan != None)
				augCan.UseOnce();
		}
	}
	lastServerAugLevelSum = curSum;
}

simulated function Name SafeStringToName(string S)
{
	if (S == "")
		return '';
	if (rootWindow != None)
		return rootWindow.StringToName(S);
	tempConvertedName = '';
	SetPropertyText("tempConvertedName", S);
	return tempConvertedName;
}

simulated function ClientSyncBoolFlag(Name flagName, bool bVal)
{
	local string sFlag;

	sFlag = string(flagName);
	if (Left(sFlag, 12) == "CoopCredits_")
	{
		Credits = int(Mid(sFlag, 12));
		return;
	}
	if (flagBase != None)
		flagBase.SetBool(flagName, bVal);
}

function ServerSyncBoolFlag(Name flagName, bool bVal)
{
	local Trestkon HostPlayer;
	local int choiceIdx, vendIdx, cost;
	local string sFlag;
	local Inventory anItem;

	sFlag = string(flagName);
	if (Left(sFlag, 12) == "CoopVendBuy_")
	{
		vendIdx = int(Mid(sFlag, 12));
		if (tnmComputers(ActiveComputer) != None)
		{
			cost = int(ActiveComputer.GetPropertyText("Cost"));
			if (cost <= 0)
				cost = 2;
			anItem = FindInventoryType(Class<Inventory>(DynamicLoadObject("TNMItems.vendvoucher", class'Class')));
			if (anItem != None && anItem.GetPropertyText("NumCopies") != "")
			{
				anItem.SetPropertyText("NumCopies", string(int(anItem.GetPropertyText("NumCopies")) - 1));
				if (int(anItem.GetPropertyText("NumCopies")) <= 0)
					DeleteInventory(anItem);
			}
			else
			{
				Credits = Max(0, Credits - cost);
				lastSyncedCredits = -1;
			}
			tnmComputers(ActiveComputer).SpawnProduct(vendIdx, Self);
		}
		return;
	}
	if (Left(sFlag, 13) == "CoopFistType_")
	{
		setfisttype(int(Mid(sFlag, 13)));
		return;
	}

	choiceIdx = -1;
	switch (flagName)
	{
		case 'CoopConChoice_0': choiceIdx = 0; break;
		case 'CoopConChoice_1': choiceIdx = 1; break;
		case 'CoopConChoice_2': choiceIdx = 2; break;
		case 'CoopConChoice_3': choiceIdx = 3; break;
		case 'CoopConChoice_4': choiceIdx = 4; break;
		case 'CoopConChoice_5': choiceIdx = 5; break;
		case 'CoopConChoice_6': choiceIdx = 6; break;
		case 'CoopConChoice_7': choiceIdx = 7; break;
		case 'CoopConChoice_8': choiceIdx = 8; break;
		case 'CoopConChoice_9': choiceIdx = 9; break;
		case 'CoopConNext':     choiceIdx = 99; break;
	}

	if (choiceIdx >= 0)
	{
		HostPlayer = Trestkon(GetPlayerPawn());
		if (choiceIdx == 99)
		{
			if (HostPlayer != None && tnmconplay(HostPlayer.conPlay) != None)
				tnmconplay(HostPlayer.conPlay).AdvanceCoopSpeech();
			else if (tnmconplay(conPlay) != None)
				tnmconplay(conPlay).AdvanceCoopSpeech();
		}
		else
		{
			if (HostPlayer != None && tnmconplay(HostPlayer.conPlay) != None)
				tnmconplay(HostPlayer.conPlay).SelectCoopChoice(choiceIdx);
			else if (tnmconplay(conPlay) != None)
				tnmconplay(conPlay).SelectCoopChoice(choiceIdx);
		}
		return;
	}

	if (flagBase != None)
		flagBase.SetBool(flagName, bVal);

	HostPlayer = Trestkon(GetPlayerPawn());
	if (HostPlayer != None && HostPlayer != Self && HostPlayer.flagBase != None)
		HostPlayer.flagBase.SetBool(flagName, bVal);
}

simulated function RefreshClientConChoicesDisplay()
{
	local DeusExRootWindow root;
	local HUDConWindowFirst conWin;
	local int i;
	local string lineStr, fullStr;

	if (clientConChoiceCount <= 0)
		return;

	fullStr = "";
	for (i = 0; i < clientConChoiceCount; i++)
	{
		if (i == clientSelectedConChoice)
			lineStr = "> [" $ (i + 1) $ "] " $ clientConChoices[i];
		else
			lineStr = "  [" $ (i + 1) $ "] " $ clientConChoices[i];
		if (fullStr != "")
			fullStr = fullStr $ chr(10);
		fullStr = fullStr $ lineStr;
	}

	root = DeusExRootWindow(rootWindow);
	if (root != None && root.hud != None)
	{
		conWin = root.hud.conWindow;
		if (conWin == None)
			conWin = root.hud.CreateConWindowFirst();
		if (conWin != None)
		{
			conWin.Show();
			conWin.Clear();
			conWin.DisplayName("Select Dialogue (1-" $ clientConChoiceCount $ ", Scroll + Click/Frob)");
			conWin.DisplayText(fullStr, None);
			return;
		}
	}
	ClientMessage(fullStr);
}

simulated function ConfirmClientConChoice(int idx)
{
	local DeusExRootWindow root;

	if (!bClientHasConChoices || idx < 0 || idx >= clientConChoiceCount)
		return;
	bClientHasConChoices = False;
	clientConChoiceCount = 0;
	subtitleClearTimer = 0.0;
	lastConChoiceConfirmTime = Level.TimeSeconds;
	root = DeusExRootWindow(rootWindow);
	if (root != None && root.hud != None && root.hud.conWindow != None)
	{
		root.hud.conWindow.Clear();
		root.hud.conWindow.Hide();
		root.hud.conWindow.Destroy();
		root.hud.conWindow = None;
	}
	switch (idx)
	{
		case 0: ServerSyncBoolFlag('CoopConChoice_0', True); break;
		case 1: ServerSyncBoolFlag('CoopConChoice_1', True); break;
		case 2: ServerSyncBoolFlag('CoopConChoice_2', True); break;
		case 3: ServerSyncBoolFlag('CoopConChoice_3', True); break;
		case 4: ServerSyncBoolFlag('CoopConChoice_4', True); break;
		case 5: ServerSyncBoolFlag('CoopConChoice_5', True); break;
		case 6: ServerSyncBoolFlag('CoopConChoice_6', True); break;
		case 7: ServerSyncBoolFlag('CoopConChoice_7', True); break;
		case 8: ServerSyncBoolFlag('CoopConChoice_8', True); break;
		case 9: ServerSyncBoolFlag('CoopConChoice_9', True); break;
	}
}

simulated function ClientShowSubtitle(string speakerName, string speech, bool bContinued)
{
	local DeusExRootWindow root;
	local HUDConWindowFirst conWin;
	local HUDInfoLinkDisplay dl;
	local string rem, part1, part2, portrait;
	local int pPos, idx;

	if (Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;

	root = DeusExRootWindow(rootWindow);

	if (Left(speakerName, 10) == "[Choices]|")
	{
		bClientHasConChoices = True;
		clientSelectedConChoice = 0;
		clientConChoiceCount = 0;
		subtitleClearTimer = 9999.0;
		rem = speech;
		while (rem != "" && clientConChoiceCount < 10)
		{
			pPos = InStr(rem, "|");
			if (pPos != -1)
			{
				clientConChoices[clientConChoiceCount] = Left(rem, pPos);
				rem = Mid(rem, pPos + 1);
			}
			else
			{
				clientConChoices[clientConChoiceCount] = rem;
				rem = "";
			}
			clientConChoiceCount++;
		}
		RefreshClientConChoicesDisplay();
		return;
	}

	if (speakerName == "[EndInfoLink]")
	{
		infolinkClearTimer = 0.0;
		lastClientInfoLinkSpeaker = "";
		lastClientInfoLinkSpeech = "";
		if (root != None && root.hud != None && root.hud.infolink != None)
			root.hud.DestroyInfoLinkWindow();
		return;
	}

	if (Left(speakerName, 15) == "[InfoLinkSync]|")
	{
		infolinkClearTimer = FMax(infolinkClearTimer, 8.0);
		if (root != None && root.hud != None && root.hud.infolink != None && lastClientInfoLinkSpeaker == Mid(speakerName, 15) && lastClientInfoLinkSpeech == speech)
			return;
		speakerName = "[InfoLink]|" $ Mid(speakerName, 15);
		bContinued = False;
	}

	if (Left(speakerName, 11) == "[InfoLink]|")
	{
		infolinkClearTimer = FMax(12.0, float(Len(speech)) * 0.10 + 5.0);
		rem = Mid(speakerName, 11);
		pPos = InStr(rem, "|");
		if (pPos != -1)
		{
			part1 = Left(rem, pPos);
			rem = Mid(rem, pPos + 1);
			pPos = InStr(rem, "|");
			if (pPos != -1)
			{
				part2 = Left(rem, pPos);
				portrait = Mid(rem, pPos + 1);
			}
			else
			{
				part2 = rem;
				portrait = "";
			}
		}
		else
		{
			part1 = rem;
			part2 = "";
			portrait = "";
		}

		lastClientInfoLinkSpeaker = part1;
		lastClientInfoLinkSpeech = speech;
		class'tnmdatalinkplay'.static.GetInfoLinkSpeakerInfo(part1, part2, portrait);

		if (root != None && root.hud != None)
		{
			if (!bContinued && root.hud.infolink != None)
				root.hud.DestroyInfoLinkWindow();
			dl = root.hud.infolink;
			if (dl == None)
				dl = root.hud.CreateInfoLinkWindow();
			if (dl != None)
			{
				dl.ShowDatalinkIcon(False);
				dl.ShowTextCursor(True);
				if (bContinued)
				{
					dl.AppendText(speech);
				}
				else
				{
					dl.ClearScreen();
					dl.SetSpeaker(part1, part2);
					if (portrait != "" && tnmhudinfolinkdisplay(dl) != None)
					{
						tnmhudinfolinkdisplay(dl).tnmsetportrait(Texture(DynamicLoadObject(portrait, class'Texture')));
						dl.ShowPortrait();
						dl.winText.SetPos(94, 36);
						dl.winText.SetTextSize(42, 6);
						dl.winName.SetSize(293, 15);
						dl.winName.SetPos(94, 15);
						dl.winLine.SetSize(293, 1);
						dl.winLine.SetPos(94, 32);
					}
					else
					{
						dl.winName.SetSize(367, 15);
						dl.winName.SetPos(20, 15);
						dl.winLine.SetSize(367, 1);
						dl.winLine.SetPos(20, 32);
						dl.winText.SetPos(20, 36);
						dl.winText.SetTextSize(52, 6);
					}
					dl.DisplayText(speech);
				}
				return;
			}
		}
		speakerName = part2;
	}

	bClientHasConChoices = False;
	clientConChoiceCount = 0;
	subtitleClearTimer = FMax(5.0, float(Len(speech)) * 0.08 + 2.5);

	if (root != None && root.hud != None)
	{
		conWin = root.hud.conWindow;
		if (conWin == None)
			conWin = root.hud.CreateConWindowFirst();
		if (conWin != None)
		{
			conWin.Show();
			if (bContinued)
			{
				conWin.AppendText(speech);
			}
			else
			{
				conWin.Clear();
				conWin.DisplayName(speakerName);
				conWin.DisplayText(speech, None);
			}
			return;
		}
	}
	ClientMessage(speakerName $ ": " $ speech);
}

simulated function ClientHideSubtitle()
{
	local DeusExRootWindow root;

	if (Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;

	bClientHasConChoices = False;
	clientConChoiceCount = 0;
	subtitleClearTimer = 0.0;
	root = DeusExRootWindow(rootWindow);
	if (root != None && root.hud != None)
	{
		if (root.hud.conWindow != None)
		{
			root.hud.conWindow.Clear();
			root.hud.conWindow.Hide();
			root.hud.conWindow.Destroy();
			root.hud.conWindow = None;
		}
	}
}

simulated function ClientSyncGoal(Name goalName, bool bPrimaryGoal, string goalText, bool bCompleted)
{
	local DeusExGoal goal;

	goal = FindGoal(goalName);
	if (goal == None)
	{
		goal = AddGoal(goalName, bPrimaryGoal);
		if (goal != None)
			goal.SetText(goalText);
	}
	else if (goalText != "" && goal.text == "")
	{
		goal.SetText(goalText);
	}

	if (bCompleted && goal != None && !goal.IsCompleted())
		GoalCompleted(goalName);
}

simulated function ClientSyncNote(string noteText, bool bUserNote, Name textTag)
{
	local DeusExNote note;

	if (textTag != '' && GetNote(textTag) != None)
		return;

	note = FirstNote;
	while (note != None)
	{
		if (note.text == noteText)
			return;
		note = note.next;
	}

	note = AddNote(noteText, bUserNote, True);
	if (note != None && textTag != '')
		note.SetTextTag(textTag);
}

simulated function ClientPlayDataLink(string datalinkName)
{
	if (Role < ROLE_Authority)
	{
		if (flagBase != None)
			flagBase.SetBool(SafeStringToName(datalinkName $ "_Played"), False);
	}
}

simulated function ClientPlayConAudio(string soundPath, bool bIsTalkSlot, bool bStopPrevTalk)
{
	local Sound snd;

	if (Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;

	if (bStopPrevTalk && coopClientTalkSoundID != 0)
	{
		StopSound(coopClientTalkSoundID);
		coopClientTalkSoundID = 0;
	}

	if (soundPath == "")
		return;

	snd = Sound(DynamicLoadObject(soundPath, class'Sound', True));
	if (snd != None)
	{
		if (bIsTalkSlot)
			coopClientTalkSoundID = PlaySound(snd, SLOT_Talk, 2.0, False, 65536.0, 1.0);
		else
			PlaySound(snd, SLOT_None, 2.0, False, 65536.0, 1.0);
	}
}

function OpenCoopKeypad(Keypad KPad, bool bHacked)
{
	if (KPad == None)
		return;

	KPad.keypadwindow = None;
	if (DeusExRootWindow(rootWindow) != None)
		KPad.ActivateKeypadWindow(Self, bHacked);
	else if (NetConnection(Player) != None)
		ClientOpenCoopKeypad(KPad, KPad.Name, bHacked, KPad.validCode, KPad.bToggleLock, KPad.Event, KPad.FailEvent);
}

simulated function ClientOpenCoopKeypad(Keypad KPad, Name kpadName, bool bHacked, string repValidCode, bool bRepToggleLock, Name repEvent, Name repFailEvent)
{
	local Keypad foundKP;

	if (Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;

	if (KPad == None && kpadName != '')
	{
		foreach AllActors(class'Keypad', foundKP)
		{
			if (foundKP.Name == kpadName)
			{
				KPad = foundKP;
				break;
			}
		}
	}

	if (KPad == None)
		return;

	KPad.validCode = repValidCode;
	KPad.bToggleLock = bRepToggleLock;
	KPad.Event = repEvent;
	KPad.FailEvent = repFailEvent;
	KPad.keypadwindow = None;
	KPad.ActivateKeypadWindow(Self, bHacked);
}

function KeypadToggleLocks(Keypad KPad)
{
	local DeusExMover M;
	local Pawn P;
	local Trestkon T;
	local int packedFlags;

	if (KPad == None)
		return;

	Super.KeypadToggleLocks(KPad);

	if (Level.NetMode != NM_Standalone && KPad.Event != '')
	{
		foreach AllActors(class'DeusExMover', M, KPad.Event)
		{
			if (!M.bLocked)
				M.lockStrength = 0.0;
			packedFlags = 0;
			if (M.bLocked)    packedFlags = packedFlags | 1;
			if (M.bPickable)  packedFlags = packedFlags | 2;
			if (M.bBreakable) packedFlags = packedFlags | 4;
			if (M.bFrobbable) packedFlags = packedFlags | 8;
			if (M.bHighlight) packedFlags = packedFlags | 16;
			if (M.bDestroyed) packedFlags = packedFlags | 32;
			for (P = Level.PawnList; P != None; P = P.NextPawn)
			{
				T = Trestkon(P);
				if (T != None && NetConnection(T.Player) != None)
					T.ClientSyncMoverState(M.Name, packedFlags, M.lockStrength, M.doorStrength);
			}
		}
	}
}

function KeypadRunEvents(Keypad KPad, bool bSuccess)
{
	if (KPad == None)
		return;
	Super.KeypadRunEvents(KPad, bSuccess);
	if (tnmGameInfo(Level.Game) != None)
		tnmGameInfo(Level.Game).CoopRequestFlagMerge();
}

function KeypadRunUntriggers(Keypad KPad)
{
	if (KPad == None)
		return;
	Super.KeypadRunUntriggers(KPad);
	if (tnmGameInfo(Level.Game) != None)
		tnmGameInfo(Level.Game).CoopRequestFlagMerge();
}

simulated function RecordLocalCoopBlast(vector HitLoc)
{
	coopLastClientBlastLoc = HitLoc;
	coopLastClientBlastTime = Level.TimeSeconds;
}

simulated function ClientPlayExplosionFX(vector HitLoc, float BlastRad, name DmgType)
{
	local ShockRing ring;
	local CoopExplosionLight light;
	local AnimatedSprite expeffect;
	local ScorchMark mark;
	local Sound boomSnd;
	local float dist, flashScale;
	local int i;

	if (Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;

	BlastRad = FMax(BlastRad, 96.0);

	// 1. Always play crisp local explosion sound right at HitLoc so 250ms channel teardown never drops audio
	if (DmgType == 'EMP')
		boomSnd = Sound(DynamicLoadObject("DeusExSounds.Weapons.EMPGrenadeExplode", class'Sound', True));
	else if (DmgType == 'TearGas' || DmgType == 'PoisonGas' || DmgType == 'NanoVirus')
		boomSnd = Sound(DynamicLoadObject("DeusExSounds.Weapons.GasGrenadeExplode", class'Sound', True));
	else if (BlastRad <= 140.0)
		boomSnd = Sound'SmallExplosion1';
	else
		boomSnd = Sound'LargeExplosion1';

	// Screen flash feedback scaled by distance
	dist = VSize(Location - HitLoc);
	if (dist < BlastRad * 3.0)
	{
		if (dist < 16.0)
			flashScale = 4.0;
		else
			flashScale = 0.5 * FClamp(BlastRad / dist, 0.0, 6.0);

		if (DmgType == 'EMP')
			ClientFlash(flashScale, vect(1, 200, 1000) * flashScale);
		else if (DmgType == 'TearGas' || DmgType == 'PoisonGas')
			ClientFlash(flashScale, vect(1, 1000, 100) * flashScale);
		else
			ClientFlash(flashScale, vect(1000, 1000, 900) * flashScale);
	}

	// Skip duplicate visual sprites if client already drew this blast locally within 0.45s
	if (coopLastClientBlastTime > 0.0 && (Level.TimeSeconds - coopLastClientBlastTime) < 0.45 && VSize(HitLoc - coopLastClientBlastLoc) < 128.0)
		return;

	coopLastClientBlastLoc = HitLoc;
	coopLastClientBlastTime = Level.TimeSeconds;

	light = Spawn(class'CoopExplosionLight',,, HitLoc);
	if (light != None)
	{
		light.RemoteRole = ROLE_None;
		if (DmgType == 'EMP')
		{
			light.size = 6;
			light.LightHue = 170;
			light.LightSaturation = 64;
		}
		else if (BlastRad < 128.0)
			light.size = 3;
		else if (BlastRad < 256.0)
			light.size = 5;
		else
			light.size = 9;
	}

	if (DmgType != 'EMP' && DmgType != 'TearGas')
	{
		if (BlastRad < 128.0)
			expeffect = Spawn(class'ExplosionSmall',,, HitLoc);
		else if (BlastRad < 256.0)
			expeffect = Spawn(class'ExplosionMedium',,, HitLoc);
		else
			expeffect = Spawn(class'ExplosionLarge',,, HitLoc);

		if (expeffect != None)
		{
			expeffect.RemoteRole = ROLE_None;
			if (boomSnd != None)
				expeffect.PlaySound(boomSnd, SLOT_None, 2.0,, FMax(BlastRad * 16.0, 1600.0));
		}
	}
	else if (light != None && boomSnd != None)
	{
		light.PlaySound(boomSnd, SLOT_None, 2.0,, FMax(BlastRad * 16.0, 1600.0));
	}

	for (i = 0; i < 3; i++)
	{
		if (i == 0)
			ring = Spawn(class'ShockRing',,, HitLoc, rot(16384, 0, 0));
		else if (i == 1)
			ring = Spawn(class'ShockRing',,, HitLoc, rot(0, 0, 0));
		else
			ring = Spawn(class'ShockRing',,, HitLoc, rot(0, 16384, 0));

		if (ring != None)
		{
			ring.RemoteRole = ROLE_None;
			ring.size = FMax(2.0, BlastRad / 32.0);
			if (ring.size > 5.0)
				ring.Skin = Texture'FlatFXTex43';
		}
	}

	mark = Spawn(class'ScorchMark',,, HitLoc, rot(16384, 0, 0));
	if (mark != None)
	{
		mark.RemoteRole = ROLE_None;
		mark.DrawScale = FClamp(BlastRad / 128.0, 0.5, 2.5);
		mark.ReattachDecal();
	}
}

simulated function ClientPlayBurningTelegraph(vector BurnLoc)
{
	local ParticleGenerator gen;
	local CoopExplosionLight warnLight;

	if (Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;

	gen = Spawn(class'ParticleGenerator',,, BurnLoc + vect(0, 0, 12), rot(16384, 0, 0));
	if (gen != None)
	{
		gen.RemoteRole = ROLE_None;
		gen.LifeSpan = 3.5;
		gen.checkTime = 0.08;
		gen.particleDrawScale = 0.6;
		gen.bRandomEject = True;
		gen.ejectSpeed = 24.0;
		gen.bGravity = False;
		gen.bParticlesUnlit = True;
		gen.frequency = 0.9;
		gen.riseRate = 35.0;
		gen.particleLifeSpan = 0.7;
		gen.particleTexture = Texture'Effects.Fire.Fireball1';
		gen.PlaySound(Sound'Spark2', SLOT_None, 2.0,, 1400.0);
	}

	warnLight = Spawn(class'CoopExplosionLight',,, BurnLoc + vect(0, 0, 16));
	if (warnLight != None)
	{
		warnLight.RemoteRole = ROLE_None;
		warnLight.size = 5;
		warnLight.LightHue = 20;
		warnLight.LightSaturation = 64;
	}
}

simulated function ClientPlayOgg(string introTrack, string loopTrack, bool bIsStereo)
{
	local TNMOggMusicManager ogg, otherOgg;

	if (Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;

	foreach AllActors(class'TNMOggMusicManager', ogg)
		break;

	if (ogg == None)
		ogg = Spawn(class'TNMOggMusicManager');

	if (ogg != None)
	{
		if (loopTrack != "" && (ogg.ClientLastLoopOgg != loopTrack || ogg.ClientLastIntroOgg != introTrack))
		{
			foreach AllActors(class'TNMOggMusicManager', otherOgg)
			{
				otherOgg.Role = ROLE_SimulatedProxy;
				otherOgg.binited = True;
				otherOgg.bShouldPlayStereo = bIsStereo;
				otherOgg.bPlayingStereo = bIsStereo;
				if (bIsStereo)
					otherOgg.stereoTrack = loopTrack;
				else
					otherOgg.stereoTrack = "";
				otherOgg.RepActiveIntroOgg = introTrack;
				otherOgg.RepActiveLoopOgg = loopTrack;
				otherOgg.ClientLastIntroOgg = introTrack;
				otherOgg.ClientLastLoopOgg = loopTrack;
				otherOgg.AmbientIntroOggFile = introTrack;
				otherOgg.AmbientOggFile = loopTrack;
			}
			ogg.CoopNativeSetCurrentOgg(introTrack, loopTrack, 0, MTRAN_Instant);
			ogg.CoopNativeGetPosition();
			log("CoopMod ClientPlayOgg: intro=" $ introTrack $ " loop=" $ loopTrack $ " stereo=" $ bIsStereo $ " ogg=" $ ogg);
		}
		else
		{
			// the stream can still be empty if an earlier call landed while the
			// manager was a proxy; restart it rather than stay silent
			if ((loopTrack != "") && (ogg.CoopNativeNextLoop() == ""))
				ogg.CoopNativeSetCurrentOgg(introTrack, loopTrack, 0, MTRAN_Instant);
			ogg.CoopNativeGetPosition();
		}
	}
}

simulated function ClientSyncMoverState(Name moverName, int packedFlags, float newLockStrength, float newDoorStrength)
{
	local DeusExMover M;

	if (Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;

	foreach AllActors(class'DeusExMover', M)
	{
		if (M.Name == moverName)
		{
			M.bLocked = ((packedFlags & 1) != 0);
			M.bPickable = ((packedFlags & 2) != 0);
			M.bBreakable = ((packedFlags & 4) != 0);
			M.bFrobbable = ((packedFlags & 8) != 0);
			M.bHighlight = ((packedFlags & 16) != 0);
			M.lockStrength = newLockStrength;
			M.doorStrength = newDoorStrength;
			if ((packedFlags & 32) != 0 && !M.bDestroyed)
			{
				M.bDestroyed = True;
				M.SetCollision(False, False, False);
				M.bProjTarget = False;
			}
			break;
		}
	}
}

simulated function bool SetBasedPawnSize(float newRadius, float newHeight)
{
	local float  oldRadius, oldHeight;
	local bool   bSuccess;
	local vector centerDelta, lookDir, upDir;
	local float  deltaEyeHeight;
	local Decoration savedDeco;

	if (!bPlatformer && (bIsCrouching || bForceDuck) && newHeight == 30.0)
		newHeight = 16.0;

	if (newRadius < 0)
		newRadius = 0;
	if (newHeight < 0)
		newHeight = 0;

	oldRadius = CollisionRadius;
	oldHeight = CollisionHeight;

	if ( Level.NetMode == NM_Standalone )
	{
		if ((oldRadius == newRadius) && (oldHeight == newHeight))
			return true;
	}

	centerDelta    = vect(0, 0, 1)*(newHeight-oldHeight);
	deltaEyeHeight = GetDefaultCollisionHeight() - Default.BaseEyeHeight;

	if ( Level.NetMode != NM_Standalone )
	{
		if ((oldRadius == newRadius) && (oldHeight == newHeight) && (BaseEyeHeight == newHeight - deltaEyeHeight))
			return true;
	}

	if (CarriedDecoration != None)
		savedDeco = CarriedDecoration;

	bSuccess = false;
	if ((newHeight <= CollisionHeight) && (newRadius <= CollisionRadius))  // shrink
	{
		SetCollisionSize(newRadius, newHeight);
		if (Move(centerDelta))
			bSuccess = true;
		else
			SetCollisionSize(oldRadius, oldHeight);
	}
	else
	{
		if (Move(centerDelta))
		{
			SetCollisionSize(newRadius, newHeight);
			bSuccess = true;
		}
	}

	if (bSuccess)
	{
		if (savedDeco != None)
		{
			savedDeco.SetPhysics(PHYS_None);
			savedDeco.SetBase(Self);
			savedDeco.SetCollision(False, False, False);

			lookDir = Vector(Rotation);
			lookDir.Z = 0;
			upDir = vect(0,0,0);
			upDir.Z = CollisionHeight / 2;
			savedDeco.SetLocation(Location + upDir + (0.5 * CollisionRadius + CarriedDecoration.CollisionRadius) * lookDir);
		}

		PrePivot        -= centerDelta;
		BaseEyeHeight   = newHeight - deltaEyeHeight;
		EyeHeight       -= centerDelta.Z;
	}
	return (bSuccess);
}

simulated function ClientSyncHackableState(Name deviceName, int packedFlags, float newHackStrength)
{
	local HackableDevices H;
	local ScriptedPawn SP;

	if (Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;

	if (newHackStrength < 0.0)
	{
		foreach AllActors(class'ScriptedPawn', SP)
		{
			if (SP.Name == deviceName)
			{
				if (!SP.bInitialized)
				{
					SP.InitializeAlliances();
					if (SP.Alliance != '')
						SP.ChangeAlly(SP.Alliance, 1.0, True);
					SP.bInitialized = True;
				}
				if (packedFlags == 2)
					SP.ChangeAlly('Player', -1.0, True);
				else if (packedFlags == 0)
					SP.ChangeAlly('Player', 1.0, True);
				else
					SP.ChangeAlly('Player', 0.0, True);
				break;
			}
		}
		return;
	}

	foreach AllActors(class'HackableDevices', H)
	{
		if (H.Name == deviceName)
		{
			H.bHackable = ((packedFlags & 1) != 0);
			H.bHighlight = ((packedFlags & 4) != 0);
			H.hackStrength = newHackStrength;
			break;
		}
	}
}

// ----------------------------------------------------------------------
// Shared co-op credit pool (update 17_r). Called every tick from
// tnmGameInfo.CoopSyncSharedCreditsAll (it used to run once a second, which
// let both players spend the same credits within that second) and from
// SyncFromPlayer.
// ----------------------------------------------------------------------

function CoopSyncSharedCredits(Trestkon Src)
{
	local int creditDelta, sharedCredits;
	local Trestkon OtherP;

	if (Src == None || Src == Self)
		return;

	// Shared Co-op Credits Pool: initialize new joiners to the team balance and propagate any credit gains/spending
	if (!Src.bCoopCreditsInit && !bCoopCreditsInit)
	{
		sharedCredits = Max(Src.Credits, Credits);
		Src.Credits = sharedCredits;
		Src.lastKnownCredits = sharedCredits;
		Src.bCoopCreditsInit = True;
		Credits = sharedCredits;
		lastKnownCredits = sharedCredits;
		bCoopCreditsInit = True;
	}
	else if (!Src.bCoopCreditsInit)
	{
		Src.Credits = Credits;
		Src.lastKnownCredits = Credits;
		Src.bCoopCreditsInit = True;
	}
	else if (!bCoopCreditsInit)
	{
		Credits = Src.Credits;
		lastKnownCredits = Src.Credits;
		bCoopCreditsInit = True;
	}

	if (Src.Credits != Src.lastKnownCredits)
	{
		creditDelta = Src.Credits - Src.lastKnownCredits;
		Src.lastKnownCredits = Src.Credits;
		foreach AllActors(class'Trestkon', OtherP)
		{
			if (OtherP != Src)
			{
				OtherP.Credits = Max(0, OtherP.Credits + creditDelta);
				OtherP.lastKnownCredits = OtherP.Credits;
				OtherP.bCoopCreditsInit = True;
			}
		}
	}
	if (Credits != lastKnownCredits)
	{
		creditDelta = Credits - lastKnownCredits;
		lastKnownCredits = Credits;
		foreach AllActors(class'Trestkon', OtherP)
		{
			if (OtherP != Self)
			{
				OtherP.Credits = Max(0, OtherP.Credits + creditDelta);
				OtherP.lastKnownCredits = OtherP.Credits;
				OtherP.bCoopCreditsInit = True;
			}
		}
	}
}

function SyncFromPlayer(Trestkon Src)
{
	local int it;
	local Name flagName;
	local bool bVal;
	local int iVal;
	local Name nVal;
	local DeusExGoal srcGoal, dstGoal;
	local DeusExNote srcNote, dstNote;
	local bool bFoundNote;
	local NanoKeyInfo srcKey;
	local int rpcCount;

	if (Src == None || Src == Self)
		return;

	CoopSyncSharedCredits(Src);

	// tnmGameInfo.CoopMergeFlags() handles flags (including flags cleared back
	// to False) once its baseline exists; this one-way copy is only a fallback.
	if (Src.flagBase != None && flagBase != None && (tnmGameInfo(Level.Game) == None || !tnmGameInfo(Level.Game).bCoopFlagMergeActive))
	{
		it = Src.flagBase.CreateIterator(FLAG_Bool);
		while (Src.flagBase.GetNextFlagName(it, flagName))
		{
			if (flagName == 'PlayerTraveling' || Left(String(flagName), 3) == "CS_")
				continue;
			bVal = Src.flagBase.GetBool(flagName);
			if (bVal && !flagBase.GetBool(flagName))
			{
				if (NetConnection(Player) != None && rpcCount >= 3)
					break;
				flagBase.SetBool(flagName, True, True, Src.flagBase.GetExpiration(flagName, FLAG_Bool));
				if (NetConnection(Player) != None)
				{
					ClientSyncBoolFlag(flagName, True);
					rpcCount++;
				}
			}
		}
		Src.flagBase.DestroyIterator(it);

		it = Src.flagBase.CreateIterator(FLAG_Int);
		while (Src.flagBase.GetNextFlagName(it, flagName))
		{
			if (flagName == 'SKTemp_SkillPointsAvail' || flagName == 'SKTemp_SkillPointsTotal' || Left(String(flagName), 3) == "CS_")
				continue;
			iVal = Src.flagBase.GetInt(flagName);
			if (iVal != 0 && flagBase.GetInt(flagName) != iVal)
				flagBase.SetInt(flagName, iVal, True, Src.flagBase.GetExpiration(flagName, FLAG_Int));
		}
		Src.flagBase.DestroyIterator(it);

		it = Src.flagBase.CreateIterator(FLAG_Name);
		while (Src.flagBase.GetNextFlagName(it, flagName))
		{
			nVal = Src.flagBase.GetName(flagName);
			if (nVal != '' && flagBase.GetName(flagName) == '')
				flagBase.SetName(flagName, nVal, True, Src.flagBase.GetExpiration(flagName, FLAG_Name));
		}
		Src.flagBase.DestroyIterator(it);
	}

	srcGoal = Src.FirstGoal;
	while (srcGoal != None)
	{
		dstGoal = FindGoal(srcGoal.goalName);
		if (dstGoal == None)
		{
			if (NetConnection(Player) != None && rpcCount >= 8)
				break;
			dstGoal = AddGoal(srcGoal.goalName, srcGoal.bPrimaryGoal);
			if (dstGoal != None)
				dstGoal.SetText(srcGoal.text);
			if (srcGoal.bCompleted && dstGoal != None)
				dstGoal.SetCompleted();
			if (NetConnection(Player) != None)
			{
				ClientSyncGoal(srcGoal.goalName, srcGoal.bPrimaryGoal, Left(srcGoal.text, 200), srcGoal.bCompleted);
				rpcCount++;
			}
		}
		else
		{
			if (srcGoal.text != "" && dstGoal.text == "")
				dstGoal.SetText(srcGoal.text);
			if (srcGoal.bCompleted && !dstGoal.bCompleted)
			{
				if (NetConnection(Player) != None && rpcCount >= 8)
					break;
				GoalCompleted(srcGoal.goalName);
				if (NetConnection(Player) != None)
				{
					ClientSyncGoal(srcGoal.goalName, srcGoal.bPrimaryGoal, Left(srcGoal.text, 200), True);
					rpcCount++;
				}
			}
		}
		srcGoal = srcGoal.next;
	}

	srcNote = Src.FirstNote;
	while (srcNote != None)
	{
		bFoundNote = False;
		if (srcNote.textTag != '' && GetNote(srcNote.textTag) != None)
			bFoundNote = True;
		else
		{
			dstNote = FirstNote;
			while (dstNote != None)
			{
				if (dstNote.text == srcNote.text)
				{
					bFoundNote = True;
					break;
				}
				dstNote = dstNote.next;
			}
		}
		if (!bFoundNote && srcNote.text != "")
		{
			if (NetConnection(Player) != None && rpcCount >= 8)
				break;
			dstNote = AddNote(srcNote.text, srcNote.bUserNote, True);
			if (dstNote != None && srcNote.textTag != '')
				dstNote.SetTextTag(srcNote.textTag);
			if (NetConnection(Player) != None)
			{
				ClientSyncNote(Left(srcNote.text, 200), srcNote.bUserNote, srcNote.textTag);
				rpcCount++;
			}
		}
		srcNote = srcNote.next;
	}

	if (Src.KeyRing != None && KeyRing != None)
	{
		srcKey = Src.KeyList;
		while (srcKey != None)
		{
			if (!KeyRing.HasKey(srcKey.KeyID))
			{
				KeyRing.GiveKey(srcKey.KeyID, srcKey.Description);
				if ((Role == ROLE_Authority) && (Level.NetMode != NM_Standalone))
					KeyRing.GiveClientKey(srcKey.KeyID, srcKey.Description);
			}
			srcKey = srcKey.NextKey;
		}
	}

	if (NetConnection(Player) != None && Credits != lastSyncedCredits && rpcCount < 8)
	{
		lastSyncedCredits = Credits;
		ClientSyncBoolFlag(SafeStringToName("CoopCredits_" $ Credits), True);
	}
}

function InitCoopStartingGear()
{
	local Inventory anItem;
	local class<DataVaultImage> mapClass;

	if (PlayerFists == None || PlayerFists.Owner != Self)
	{
		if (FindInventoryType(class'WeaponFists') != None)
		{
			PlayerFists = WeaponFists(FindInventoryType(class'WeaponFists'));
			PlayerFists.SetOwner(Self);
			PlayerFists.bInObjectBelt = False;
			PlayerFists.BeltPos = -1;
		}
		else
		{
			anItem = Spawn(class'WeaponFists');
			if (anItem != None)
			{
				anItem.Icon = None;
				anItem.Frob(Self, None);
				anItem.Icon = anItem.Default.Icon;
			}
			PlayerFists = WeaponFists(FindInventoryType(class'WeaponFists'));
			if (PlayerFists != None)
			{
				PlayerFists.SetOwner(Self);
				PlayerFists.bInObjectBelt = False;
				PlayerFists.BeltPos = -1;
			}
		}
	}

	if (KeyRing == None)
		CreateKeyRing();

	if (KeyRing != None && !KeyRing.HasKey('TrestkonsRavingLocker'))
	{
		KeyRing.GiveKey('TrestkonsRavingLocker', strLockerPassword);
		if ((Role == ROLE_Authority) && (Level.NetMode != NM_Standalone))
			KeyRing.GiveClientKey('TrestkonsRavingLocker', strLockerPassword);
	}

	if (FirstImage == None)
	{
		mapClass = class<DataVaultImage>(DynamicLoadObject("TNMDataVault.TNMDV_DowntownMap", class'Class'));
		if (mapClass != None)
		{
			anItem = Spawn(mapClass);
			if (anItem != None)
				anItem.Frob(Self, None);
		}
	}

	if (FirstNote == None && strAccountPin != "")
		NoteAdd(strAccountPin);

	InitPCGames();
}

function SaveSkillPoints()
{
	if (flagBase != None)
	{
		flagBase.SetInt('SKTemp_SkillPointsAvail', SkillPointsAvail, True);
		flagBase.SetInt('SKTemp_SkillPointsTotal', SkillPointsTotal, True);
	}
}

function RestoreSkillPoints()
{
	if (flagBase != None)
	{
		if (flagBase.CheckFlag('SKTemp_SkillPointsAvail', FLAG_Int))
			SkillPointsAvail = flagBase.GetInt('SKTemp_SkillPointsAvail');
		if (flagBase.CheckFlag('SKTemp_SkillPointsTotal', FLAG_Int))
			SkillPointsTotal = flagBase.GetInt('SKTemp_SkillPointsTotal');
	}
}

simulated function ClientReStart()
{
	Super.ClientReStart();
	ShowHud(True);
	if (DeusExRootWindow(rootWindow) != None && DeusExRootWindow(rootWindow).hud != None && DeusExRootWindow(rootWindow).hud.belt != None)
		DeusExRootWindow(rootWindow).hud.belt.PopulateBelt();
}

exec function HostCoop(optional string map)
{
	local string urlName, travelURL;
	local int hashPos;

	if (map == "")
	{
		if (GetLevelInfo() != None && Caps(GetLevelInfo().mapName) != "TNMONLY" && Caps(GetLevelInfo().mapName) != "DXONLY" && Caps(GetLevelInfo().mapName) != "TNMINTRO")
			map = GetLevelInfo().mapName;
		else
			map = strStartMap;
	}
	urlName = class'CoopLocalPrefs'.static.EncodeURLName(GetLocalCoopPlayerName());
	UpdateURL("Name", urlName, True);
	PreTravel();
	hashPos = InStr(map, "#");
	if (hashPos != -1)
		travelURL = Left(map, hashPos) $ "?Name=" $ urlName $ "?Game=TNM.tnmGameInfo?Listen" $ Mid(map, hashPos);
	else
		travelURL = map $ "?Name=" $ urlName $ "?Game=TNM.tnmGameInfo?Listen";
	ClientTravel(travelURL, TRAVEL_Relative, True);
}

exec function JoinCoop(string IP)
{
	local DeusExRootWindow root;
	local string urlName, connectURL;

	if (IP == "")
		return;

	urlName = class'CoopLocalPrefs'.static.EncodeURLName(GetLocalCoopPlayerName());
	UpdateURL("Name", urlName, True);

	coopConnectingIP = IP;
	coopLastConnectError = "";
	bCoopPendingConnect = True;
	ProgressMessage[0] = "Connecting to Co-op Server...";
	ProgressMessage[1] = IP $ "  (as " $ GetLocalCoopPlayerName() $ ")";
	SetProgressTime(14.0);

	root = DeusExRootWindow(rootWindow);
	if (root != None && CoopConnectingWindow(root.GetTopWindow()) == None)
		root.PushWindow(Class'CoopConnectingWindow', True, True);

	if (InStr(Caps(IP), "?NAME=") != -1)
		connectURL = IP;
	else
		connectURL = IP $ "?Name=" $ urlName;

	ConsoleCommand("open " $ connectURL);
}

exec function CoopSave()
{
	local Pawn P;
	local Trestkon T;

	if (Role < ROLE_Authority)
		return;

	if (tnmGameInfo(Level.Game) != None)
	{
		tnmGameInfo(Level.Game).SyncCoopState();
		tnmGameInfo(Level.Game).SaveCoopSessionToDefaults();
		for (P = Level.PawnList; P != None; P = P.NextPawn)
		{
			T = Trestkon(P);
			if (T != None)
				T.ClientMessage("Co-op Campaign Saved!");
		}
	}
}

exec function CoopContinue()
{
	local string savedURL;
	local Pawn P;
	local Trestkon T;

	if (Role < ROLE_Authority)
		return;

	if (!class'tnmGameInfo'.default.bHasCoopSession || class'tnmGameInfo'.default.SavedCurrentURL == "")
	{
		for (P = Level.PawnList; P != None; P = P.NextPawn)
		{
			T = Trestkon(P);
			if (T != None)
				T.ClientMessage("No saved Co-op campaign found in TNMCoopSave.ini.");
		}
		return;
	}

	savedURL = class'tnmGameInfo'.default.SavedCurrentURL;
	class'tnmGameInfo'.default.bHasActiveTravelSession = True;
	class'tnmGameInfo'.default.bForceRestoreLoadout = True;
	class'tnmGameInfo'.default.bRestoreSavedPositions = True;
	if (tnmGameInfo(Level.Game) != None)
		tnmGameInfo(Level.Game).bSavedThisTravel = True;
	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		T = Trestkon(P);
		if (T != None)
		{
			T.ClientMessage("Loading saved Co-op campaign (" $ savedURL $ ")...");
			if (NetConnection(T.Player) != None)
				T.ClientPrepareTravel();
			else if (DeusExRootWindow(T.rootWindow) != None)
				DeusExRootWindow(T.rootWindow).ClearWindowStack();
		}
	}
	if (Level.NetMode != NM_Standalone)
		Level.ServerTravel(savedURL, False);
	else
	{
		UpdateURL("Name", class'CoopLocalPrefs'.static.EncodeURLName(GetLocalCoopPlayerName()), True);
		if (InStr(savedURL, "#") != -1)
			ClientTravel(Left(savedURL, InStr(savedURL, "#")) $ "?Name=" $ class'CoopLocalPrefs'.static.EncodeURLName(GetLocalCoopPlayerName()) $ "?Game=TNM.tnmGameInfo?Listen" $ Mid(savedURL, InStr(savedURL, "#")), TRAVEL_Relative, False);
		else
			ClientTravel(savedURL $ "?Name=" $ class'CoopLocalPrefs'.static.EncodeURLName(GetLocalCoopPlayerName()) $ "?Game=TNM.tnmGameInfo?Listen", TRAVEL_Relative, False);
	}
}

// exec function MeshTest()
// {
	// local vector spawnLoc;
	
	// spawnLoc = Location;
	// spawnLoc.Z += 30;
	
	// spawn(Class'TNM.PumpShotgunMesh',,, spawnLoc);
// }

exec function ActivateAugmentation(int num)
{
	local Augmentation anAug;
	local int count, wantedSlot, slotIndex;
	local bool bFound;

	if (RestrictInput())
		return;

	if (Energy == 0)
	{
		anAug = tnmaugmentationmanager(AugmentationSystem).GetAugFromKey(num);

		if ( anAug == none )
		{
		}
		else if ( anAug.GetEnergyRate() == 0 )
		{
		}
		else
		{
			ClientMessage(EnergyDepleted);
			PlaySound(AugmentationSystem.FirstAug.DeactivateSound, SLOT_None);
			return;
		}
	}

	if (AugmentationSystem != None)
		AugmentationSystem.ActivateAugByKey(num);
}

function tnmPCGtimePlayed mostPlayedGame()
{
	local float maxTimePlayed;
	local int gameIndex;
	local int i;
	local tnmPCGtimePlayed ret;

	gameindex=-1;
	for(i=0;i<5;i++)
	{
		if(pcgamedata[i].timeplayed>maxTimePlayed)
		{
			maxTimePlayed = pcgamedata[i].timeplayed;
			gameIndex = i;
		}
	}

	ret.gameId=gameindex;
	ret.timePlayed=maxTimePlayed;
	return ret;
}

function setlives(int l)
{
   lives = l;
   radishHealth = 2;
   rh.SetLives(lives);
   rh.SetHealth(radishHealth);
}

//To be used as a marker within logs
exec function LogShit()
{
  Log("LogShit Called", 'marker');
}

function string CurrentMap()
{
	local deusexlevelinfo info;

	foreach AllActors(class'DeusExLevelInfo', info)
		break;

	return Caps(info.mapName);
}

function PickedUpRadish()
{
	radishCounter++;
	
	// if (radishHealth < 2 && radishCounter % 10)
	if (radishCounter % 100 == 0)
	{
		setlives(lives + 1);
		// radishHealth++;
		// if (rh != None)
			// rh.SetHealth(radishHealth);
		// radishCounter = 0;
	}
	if (rh != None)
		rh.SetRadishes(radishCounter);
}

function DisplayInteruptMessage(Canvas c)
{
	local float w,h;
	local string str;
	
	str = strEscapeSkip;

	c.Font=Font'SmallFont';
	c.StrLen(str,w,h);
	c.curx=c.sizex-w*1.2;
	c.cury=h*1.2;
	c.DrawText(str);
}

//prebegin play actor replacement/modification stuff -Nick
function PreBeginPlay()
{
	local FireExtinguisher exting;
	local WeaponLAW law;
	local DeusExWeapon wep;
	local DeusExMover M;

//	CU_Info = Spawn(Class'CharacterUnlockInfo', Self);
	
	super.PreBeginPlay();

	foreach AllActors(Class'WeaponLAW', law)
		ReplaceActor(law, class<Actor>(DynamicLoadObject("TNMItems.WeaponTNMLAW",class'Class')));

	foreach AllActors(Class'FireExtinguisher', exting)
		ReplaceActor(exting, class<Actor>(DynamicLoadObject("TNMitems.WeaponFireExting",class'Class')));

	foreach AllActors(Class'DeusExMover', M)
	{
		M.msgKeyLocked=msgKeyLocked;
		M.msgKeyUnlocked=msgKeyUnlocked;
		M.msgNoNanoKey=msgNoNanoKey;
	}

	BTManager = Spawn(class'BulletTimeManager',Self);
	BTManager.ModifyWeapons();
}

//shamelessly stolen from Chronos
function ReplaceActor(Actor oldActor, class<Actor> newActorClass)
{
	local Actor newActor;
	newActor = Spawn(newActorClass,oldActor.Owner, oldActor.Tag,  oldActor.Location,oldActor.Rotation);
	newActor.SetCollisionSize(oldActor.CollisionRadius, oldActor.CollisionHeight);
	newActor.SetPhysics(oldActor.Physics);
	oldActor.Destroy();
}

exec function ToggleScope()
{
	local DeusExWeapon W;
	local tnmCrosshair c;	
	local Inventory Binocs;
    local Inventory Inv;

	W = DeusExWeapon(Weapon);

	super.ToggleScope();

	if(W==None)
	{		
		Binocs = FindInventoryType(Class'DeusEx.Binoculars');
		if ( Binocs != None )
		{
			PutInHand(Binocs);
			Binocs.Activate();
			return;
		}
	}

	if(W==None)
	{		
		for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
		{
			if ( Inv.IsA('TNMBinoculars') )
			{
				Binocs = Inv;
				break;
			}
		}
		if ( Binocs != None )
		{
			PutInHand(Binocs);
			Binocs.Activate();
		}
		return;
	}

	c = tnmcrosshair(deusexrootwindow(rootWindow).hud.cross);
	c.SetScoping(w.bZoomed);
}

function DebugMessage(string message)
{
	if(!bDebug) return;
	clientmessage(message);
}

//biggest hack ever: bascially I didn't want to replace the playertick event in every state
//so I've instead overridden a function that is called from all (most) of them.

//edited: I wasn't sure if this was going to get consistently called or not so I had
//the bullet time manager call tick for us

//WCCC 3/16/19: Whoever made this is a national hero. Playertick is a royal pain.

//event UpdateWarrenEMPField(float deltatime)
simulated function TrestkonTick(float deltatime)
{
	local int credits_diff;
	local class<ChargedPickup> cp;
	local MotionBlurEffect blur;
	local PrecipitationZone pZone;
	local int i;

//	super.UpdateWarrenEMPField(deltatime);

	if (Region.Zone != None)
	{
		pZone = PrecipitationZone(Region.Zone);
		if (pZone != None && (pZone.NoiseMult > 1 || pZone.NoiseVolume > 160))
		{
			pZone.NoiseMult = 1;
			pZone.NoiseVolume = 160;
			if (pZone.FSound[0] != None)
				pZone.FSound[0].SoundVolume = 160;
			for (i = 1; i < 4; i++)
			{
				if (pZone.FSound[i] != None)
				{
					pZone.FSound[i].Destroy();
					pZone.FSound[i] = None;
				}
			}
		}
	}

	if (Level.NetMode == NM_Client)
	{
		CoopSendMovementPrefs();
		if (coopVisualSmoothOffset != vect(0, 0, 0))
		{
			coopVisualSmoothOffset *= FMax(0.0, 1.0 - deltatime * 14.0);
			if (VSize(coopVisualSmoothOffset) < 0.05)
				coopVisualSmoothOffset = vect(0, 0, 0);
		}
	}

	if (Role == ROLE_Authority && bClientInThirdPersonConvo)
	{
		if (ConversationActor != None)
		{
			clientConvoTarget = ConversationActor;
			clientConvoTargetLoc = ConversationActor.Location;
			LookAtActor(ConversationActor, true, true, true, 0, 0.5);
			SetRotation(DesiredRotation);
		}
		else if (clientConvoTarget != None)
		{
			clientConvoTargetLoc = clientConvoTarget.Location;
			LookAtActor(clientConvoTarget, true, true, true, 0, 0.5);
			SetRotation(DesiredRotation);
		}
		Velocity = vect(0, 0, 0);
		Acceleration = vect(0, 0, 0);
	}
	else if (Level.NetMode == NM_Client)
	{
		if (bClientInThirdPersonConvo)
		{
			bWasClientInThirdPersonConvo = True;
			Velocity = vect(0, 0, 0);
			Acceleration = vect(0, 0, 0);
		}
		else if (bWasClientInThirdPersonConvo)
		{
			bWasClientInThirdPersonConvo = False;
			bBehindView = False;
		}
	}

	CanLoad = true;
	if(bJustTraveled && !bAutosave)
	{
		//AutoSave(true);		
	}
	bJustTraveled = false;
	if (!IsInState('PlayerSwimming'))
		DripWater(deltaTime);
	
	//WCCC, 6/17/19: Fix for fists and inhand stuff being dumb.
	if ((InHand == None) && (InHandPending == None))
	{
		if (LastInHandTimer > 0) LastInHandTimer -= deltaTime;
	}
	else
	{
		//Last time the duration was too short, and had variable reliability due to the fact that
		//tick is tied to framerate. Gotta love UE sometimes.
		//This time, do some overkill to ditch this crap. 15 FPS minimum for acceptable performance.
		LastInHandTimer = 0.25;
	}
	if ( halongastimer > 0 )
	{
		if ( !bNoOxygen )
		{
			swimDuration = UnderWaterTime;
			swimTimer = swimDuration;
		}

		bNoOxygen = true;
		halongastimer -= deltatime;
		halongastimer = FMax(0, halongastimer);
	}
	
	if (bQuadDamage)
	{
		quadDamageTimer += deltatime;
		ClientFlash(0.01, vect(0, 0, 10));
		if (quadDamageTimer > 30)
		{
			quadDamageTimer = 0;
			bQuadDamage = False;
		}
	}
	
	if (bRingOfShadow)
	{
		shadowRingTimer += deltatime;
		ClientFlash(0.01, vect(5, 5, 5));
		if (shadowRingTimer > 30)
		{
			shadowRingTimer = 0;
			bRingOfShadow = False;
		}
	}

	if (bNoOxygen)
	{
		// update our swimming info
		swimTimer -= deltaTime;
		swimTimer = FMax(0, swimTimer);
	
		if ( Role == ROLE_Authority )
		{
			if (swimTimer > 0)
				PainTime = swimTimer;
		}
	}

	//DDL breath stuff
	if(breathgen != none && bVisibleBreath)
	{
		Updatebreathgen(deltatime);
	}
	else if (bVisibleBreath)
		spawnbreathgen();

	if ( halongastimer == 0 )
	{
		if ( !HeadRegion.Zone.isa('tnmzoneinfo') || !tnmzoneinfo(HeadRegion.Zone).bNoOxygen )
			GotOxygen();
	}

	//monitor player's credits
	credits_diff=Credits-CreditsPrev;
	if(credits_diff>0)
		CreditsEarned+=credits_diff;
	CreditsPrev=Credits;

	//tick down the static
	if ( statictime > 0)
	{
		statictime -= deltatime;
		if ( statictime <= 0)
		{
			showstatic(false);
			showstaticdamage(false);
		}
	}
	
	if ( bRadishImmunity )
	{
		/*
		blur = Spawn(class'MotionBlurEffect',,, Location);
		if (blur != None)
		{
			blur.Mesh = Mesh;
			blur.AnimFrame = AnimFrame;
			// blur.AnimRate = 0;
			blur.AnimSequence = AnimSequence;
			blur.bAnimLoop=True;
			blur.Skin = Skin;
			blur.Texture = Texture;
			for(i = 0; i < 8; i++)
			{
				blur.MultiSkins[i] = MultiSkins[i];
			}
			
			blur.OrigGlow = ScaleGlow;
			blur.Prepivot = Prepivot;
		}*/
		RadishImmunityFlickerTimer++;
		if (RadishImmunityFlickerTimer >= 4)
		{
			bHidden = !bHidden;
			RadishImmunityFlickerTimer = 0;
		}
	}
	if ( bRadishImmunity )
	{
		RadishImmunityTimeLeft = RadishImmunityTime - Level.Timeseconds;
		if ( Level.Timeseconds > RadishImmunityTime )
			RadishImmunityEffect( false );
	}
}

// ----------------------------------------------------------------------
// NintendoImmunityEffect()
// ----------------------------------------------------------------------
function RadishImmunityEffect( bool on )
{
	bRadishImmunity = on;

	if (bRadishImmunity)
	{
 		RadishImmunityTime = Level.Timeseconds + RadishDelay;
		RadishImmunityTimeLeft = RadishDelay;
	}
	else
	{
		RadishImmunityTimeLeft = 0.0;
		bHidden = False;
		RadishImmunityFlickerTimer = 0;
	}
}

event PainTimer()
{
	local float depth;

	//log("Pain Timer");
	if ( (Health < 0) || (Level.NetMode == NM_Client) )
		return;
		
	if ( bNoOxygen )
	{
		// DEUS_EX CNN - make drowning damage happen from center
		TakeDamage(5, None, Location, vect(0,0,0), 'Drowned'); 
		if ( Health > 0 )
			PainTime = 2.0;
	}
	else
		super.PainTimer();	
}

function GotOxygen()
{
	if ( bnooxygen && halongastimer == 0 )
	{
		DebugMessage("just got oxygen");
		if ((PainTime > 0) && (PainTime < 8) )
			Gasp();
		bNoOxygen = false;
	}
}

event HeadZoneChange(ZoneInfo newHeadZone)
{
	local float mult, augLevel;
	
	local tnmzoneinfo newzone;
	// local tnmzoneinfo oldzone;

	newzone = tnmzoneinfo(newheadzone);
	// oldzone = tnmzoneinfo(HeadRegion.Zone);

	if ( (newzone != none) && newzone.bNoOxygen)
	{
		if (!bNoOxygen)
		{
			// Contain air if using a hazmat suit
			if (!UsingChargedPickup(class'HazMatSuit'))
			{
				bNoOxygen = true;
				// make sure we're not crouching when we start swimming
				mult = SkillSystem.GetSkillLevelValue(class'SkillSwimming');
				swimDuration = UnderWaterTime * mult;
				swimTimer = swimDuration;
			}
		}
		class'tnmSoundModifier'.static.On();
		class'tnmSoundModifier'.static.SetVolumeMultiplier(0.00);
		// class'tnmSoundModifier'.static.SetRadiusMultiplier(0.01);
	}
	else
	{
		class'tnmSoundModifier'.static.ResetVolumeMultiplier();
		// class'tnmSoundModifier'.static.ResetRadiusMultiplier();
		if (BTManager != None && !BTManager.IsInState('Enabled'))
			class'tnmSoundModifier'.static.Off();
		GotOxygen();
	}

	if(newZone != None && !Newzone.bWaterZone && bVisibleBreath && breathgen == none)
	{
		spawnBreathgen();
	}
	else if(((newZone != None && newzone.bWaterZone) || !bVisibleBreath) && breathgen != none)
	{
		breathgen.DelayedDestroy();
	}

	Super.HeadZoneChange(newHeadZone);
}

event Destroyed()
{
	local tnmConPlay cp;

	if (BTManager != None)
	{
		BTManager.Destroy();
		BTManager = None;
	}
	if (conPlay != None)
	{
		conPlay.TerminateConversation();
		conPlay = None;
	}
	if (dataLinkPlay != None)
	{
		dataLinkPlay.AbortAndSaveHistory();
		dataLinkPlay = None;
	}
	foreach AllActors(class'tnmConPlay', cp)
	{
		if (cp.con != None)
			cp.con.ClearBindEvents();
		cp.ActorDestroyed(Self);
	}
	if (rootWindow != None)
		rootWindow.Destroy();
	super.Destroyed();
	if(logView_log!=None)
	{
		logView_log.fClose();
		logView_log=None;
	}
}

exec function LogView(optional string label)
{
	if (!bCheatsEnabled)
		return;

	blogview = true;
	if(logView_log==None)
	{
		logView_log=new (None) Class'tnmLog';
		logView_log.fOpen("logview.log");
	}
	//logView_log.fLog("Logging camera view");
	if(label!="")
		logView_log.fLog("LABEL:"@label);
}

function string GetRandomEventLabel(ConEventRandomLabel event)
{
	local RandomEventInfoLink result;
	local int i;

	if (randoms == none)
	{
		result = new() class'RandomEventInfoLink';
		result.conversation = event.Conversation.conname;
		result.label = event.label;
		randoms = result;
		result.size = event.GetLabelCount();
//		for ( i = 0; i < result.size; i++)
//			result.indicies[i] = i;
		return result.GetLabel(event);
	}
	else
	{
		result = randoms.GetLink(event);
		return result.GetLabel(event);
	}
}

exec function EndCinematic()
{
	if (bCinematic)
	{
		if (CurrentCam != none)
		{
			CurrentCam.GotoState('Idle', 'Wait');
			CurrentCam.Interupt();
		}
	}
}

exec function Bang()
{
	local ExplosionLight light;
	local int i;
	local Rotator rot;
	local SphereEffect sphere;
   	local ExplosionSmall expeffect;

	if (!bCheatsEnabled)
		return;

	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, Location);
	if (light != None)
	{
		light.size = 8;
		light.LightHue = 128;
		light.LightSaturation = 96;
		light.LightEffect = LE_Shell;
	}

	// draw a cool light sphere
	sphere = Spawn(class'SphereEffect',,, Location);
	if (sphere != None)
   {
		sphere.size = 768.0 / 32.0;
   }

}

//and let combatdifficulty work as normal for now..

//yes: this below stuff is pretty bad from an 'elegance' perspective, but it works ok
//and means you can keep all your current settings. Huzzah. -DDL

function timer()
{
    if(bFiltered)
        super.timer();

    else
    {
	//note to self: the pawndifficulty defaults to whatever the normal amount is now for testing -shax
        if(PawnDifficulty != 199) //it's been set by the travel vars! Hooray!
        {
            FilterPawns();
            FilterItems();
            bFiltered = true;
            settimer(0.0, false);
        }
    }
}

function FilterPawns()
{
    // local TNMPawn P;
    local ScriptedPawn P;

    // foreach AllActors(Class'TNMPawn', P)
    foreach AllActors(Class'ScriptedPawn', P)
    {
        if(     (PawnDifficulty == 0 && !P.bDifficulty0)
            ||  (PawnDifficulty == 1 && !P.bDifficulty1)
            ||  (PawnDifficulty == 2 && !P.bDifficulty2)
            ||  (PawnDifficulty == 3 && !P.bDifficulty3))
            {
                //log("Destroying Pawn"@P.Name$", with pawndifficulty of"@String(Pawndifficulty));
                P.KillShadow();
                P.Destroy();
            }
    }
}

function FilterItems()
{
    local inventory Inv;
    local containers c;

    foreach AllActors(Class'Inventory', Inv)
    {
        if(     (ItemDifficulty == 0 && !Inv.bDifficulty0)
            ||  (ItemDifficulty == 1 && !Inv.bDifficulty1)
            ||  (ItemDifficulty == 2 && !Inv.bDifficulty2)
            ||  (ItemDifficulty == 3 && !Inv.bDifficulty3))
            {
                log("Destroying Inventory"@Inv.Name$", with Itemdifficulty of"@String(Itemdifficulty));
                Inv.Destroy();
            }
    }

    foreach allactors(class'containers', c)
    {
        if(     (ItemDifficulty == 0 && !c.bDifficulty0)
            ||  (ItemDifficulty == 1 && !c.bDifficulty1)
            ||  (ItemDifficulty == 2 && !c.bDifficulty2)
            ||  (ItemDifficulty == 3 && !c.bDifficulty3))
            {
		//log("Destroying Container"@c.Name$", with Itemdifficulty of"@String(Itemdifficulty));
		c.numThings = 0;
		c.bGenerateTrash = false;		
                c.Destroy();
            }
    }
}

exec function GetState()
{
	ClientMessage(GetStateName());
	ClientMessage(bcinematic);
}

function PickupNanoKey(NanoKey newKey)
{
	local Pawn P;
	local Trestkon T;

	if (KeyRing != None)
	{
		KeyRing.GiveKey(newKey.KeyID, newKey.Description);
		if ((Role == ROLE_Authority) && (Level.NetMode != NM_Standalone))
			KeyRing.GiveClientKey(newKey.KeyID, newKey.Description);
	}
	if (newkey.isA('SubwayPass'))
		flagbase.SetBool('HAS_SubwayPass',true,,23);
	else
		ClientMessage(Sprintf(AddedNanoKey, newKey.Description));

	if (Level.NetMode != NM_Standalone)
	{
		for (P = Level.PawnList; P != None; P = P.NextPawn)
		{
			T = Trestkon(P);
			if (T != None && T != Self && T.KeyRing != None && !T.KeyRing.HasKey(newKey.KeyID))
			{
				T.KeyRing.GiveKey(newKey.KeyID, newKey.Description);
				if (Role == ROLE_Authority)
					T.KeyRing.GiveClientKey(newKey.KeyID, newKey.Description);
				if (newkey.isA('SubwayPass') && T.flagbase != None)
					T.flagbase.SetBool('HAS_SubwayPass',true,,23);
				else
					T.ClientMessage(Sprintf(AddedNanoKey, newKey.Description));
			}
		}
	}
}

function bool HandleItemPickup(Actor FrobTarget, optional bool bSearchOnly)
{
	local bool result;
	local bool bCanPickup;
	local bool bSlotSearchNeeded;
	local Inventory foundItem;
	local Inventory Inv;

	bSlotSearchNeeded = True;
	bCanPickup = True;

	// Special checks for objects that do not require phsyical inventory
	// in order to be picked up:
	// 
	// - NanoKeys
	// - DataVaultImages
	// - Credits
	
	// Why not just check for bDisableInv?
	if ((FrobTarget.IsA('DataVaultImage')) || (FrobTarget.IsA('NanoKey')) || (FrobTarget.IsA('Credits')) || (FrobTarget.IsA('PosterTube')) || (FrobTarget.IsA('TNMBinoculars')))
	{
		if ((FrobTarget.IsA('TNMBinoculars') && (FindInventoryType(FrobTarget.Class) != None)))
		{
			ClientMessage(Sprintf(CanCarryOnlyOneBinocs, DeusExPickup(FrobTarget).itemName));
			bCanPickup = False;
		}
		else
			bSlotSearchNeeded = False;
	}
	else if (FrobTarget.IsA('DeusExPickup'))
	{
		// If an object of this type already exists in the player's inventory *AND*
		// the object is stackable, then we don't need to search.

		if ((FindInventoryType(FrobTarget.Class) != None) && (FrobTarget.IsA('Binoculars') || FrobTarget.IsA('TNMBinoculars')))
		{
			ClientMessage(Sprintf(CanCarryOnlyOneBinocs, DeusExPickup(FrobTarget).itemName));
			bCanPickup = False;
		}
		else if ((FindInventoryType(FrobTarget.Class) != None) && (DeusExPickup(FrobTarget).bCanHaveMultipleCopies))
			bSlotSearchNeeded = False;
		else if (!bool(FrobTarget.GetPropertyText("bItemRefusalOverride")))
		{
			if(GetItemRefusalSetting(DeusExPickUp(FrobTarget)))
			{
				ClientMessage(Sprintf(ItemRefusedString, DeusExPickup(FrobTarget).itemName));
				// DeusExPickup(FrobTarget).bItemRefusalOverride = True;
				FrobTarget.SetPropertyText("bItemRefusalOverride", "True");
				bCanPickup = False;
			}
		}
	}
	else 
	{
		// If this isn't ammo or a weapon that we already have, 
		// check if there's enough room in the player's inventory
		// to hold this item.

		foundItem = GetWeaponOrAmmo(Inventory(FrobTarget));

		if (foundItem != None)
		{
			bSlotSearchNeeded = False;

			// if this is an ammo, and we're full of it, abort the pickup
			if (foundItem.IsA('Ammo'))
			{
				if (Ammo(foundItem).AmmoAmount >= Ammo(foundItem).MaxAmmo)
				{
					ClientMessage(TooMuchAmmo);
					bCanPickup = False;
				}
			}

			// If this is a grenade or LAM (what a pain in the ass) then also check
			// to make sure we don't have too many grenades already
			else if (foundItem.IsA('WeaponEMPGrenade') || 
			         foundItem.IsA('WeaponGasGrenade') || 
				 foundItem.IsA('WeaponNanoVirusGrenade') || 
				 foundItem.IsA('WeaponLAM') ||
				 foundItem.IsA('WeaponTNMEMPGrenade') || 
			     foundItem.IsA('WeaponTNMGasGrenade') || 
				 foundItem.IsA('WeaponTNMNanoVirusGrenade') ||
				 foundItem.IsA('WeaponTNMLAM') || 
				 foundItem.IsA('WeaponTripBomb') ||
				 foundItem.IsA('WeaponPlasmaNade') ||
				 foundItem.IsA('WeaponFirewallBeacon') ||	// Conflicts with WeaponAnimalContainer
				 foundItem.IsA('WeaponMine') || 
				 foundItem.IsA('WeaponTNMHideAGun') ||
				 foundItem.IsA('weaponmolbottle'))
			{
				if (DeusExWeapon(foundItem).AmmoType.AmmoAmount >= DeusExWeapon(foundItem).AmmoType.MaxAmmo)
				{
					ClientMessage(TooMuchAmmo);
					bCanPickup = False;
				}
			}


			// Otherwise, if this is a single-use weapon, prevent the player
			// from picking up

			// else if (foundItem.IsA('Weapon'))
			else if (Weapon(foundItem) != None && foundItem.Class == FrobTarget.Class && (TNMWeapon(foundItem) == None || TNMWeapon(foundItem).Attribute == TNMWeapon(FrobTarget).Attribute))
			{
				// If these fields are set as checked, then this is a 
				// single use weapon, and if we already have one in our 
				// inventory another cannot be picked up (puke). 

				bCanPickup = ! ( (Weapon(foundItem).ReloadCount == 0) && 
				                 (Weapon(foundItem).PickupAmmoCount == 0) && 
				                 (Weapon(foundItem).AmmoName != None) );

				if (!bCanPickup)
					ClientMessage(Sprintf(CanCarryOnlyOne, foundItem.itemName));
			}
			else if (TNMWeapon(FrobTarget) != None || TNMWeapon(FrobTarget).Attribute != Att_None)
			{
				bSlotSearchNeeded = True;
				for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
				{
					if ( Inv.class == FrobTarget.Class && TNMWeapon(FrobTarget).Attribute == TNMWeapon(Inv).Attribute )
					{
						bSlotSearchNeeded = False;
						break;
					}
				}
			}
		}
		else if (!bool(FrobTarget.GetPropertyText("bItemRefusalOverride")))
		{
			if(DeusExWeapon(FrobTarget) != None && GetItemRefusalSetting(DeusExWeapon(FrobTarget)))
			{
				ClientMessage(Sprintf(ItemRefusedString, DeusExWeapon(FrobTarget).itemName));
				// DeusExWeapon(FrobTarget).bItemRefusalOverride = True;
				FrobTarget.SetPropertyText("bItemRefusalOverride", "True");
				bCanPickup = False;
			}
		}
	}
	
	if (bSlotSearchNeeded && bCanPickup)
	{
		if (FindInventorySlot(Inventory(FrobTarget), bSearchOnly) == False)
		{
			if (WeaponFireStaff(FrobTarget) != None && !flagbase.GetBool('Firestaff_Decrypted'))
				SetAchievement("achFirestaffSpace");
			ClientMessage(Sprintf(InventoryFull, Inventory(FrobTarget).itemName, Inventory(FrobTarget).invSlotsX, Inventory(FrobTarget).invSlotsY));
			bCanPickup = False;
			ServerConditionalNotifyMsg( MPMSG_DropItem );
		}
	}
	
	if (bCanPickup)
	{
		if ( (Level.NetMode != NM_Standalone) && (FrobTarget.IsA('DeusExWeapon') || FrobTarget.IsA('DeusExAmmo')) )
			PlaySound(sound'WeaponPickup', SLOT_Interact, 0.5+FRand()*0.25, , 256, 0.95+FRand()*0.1);
		DoFrob(Self, inHand);

		// This is bad. We need to reset the number so restocking works
		if ( (Level.NetMode != NM_Standalone) && FrobTarget != None && FrobTarget.bHidden )
		{
			if ( FrobTarget.IsA('DeusExWeapon') && (DeusExWeapon(FrobTarget).PickupAmmoCount == 0) && (DeusExWeapon(FrobTarget).Default.PickupAmmoCount > 0) )
			{
				DeusExWeapon(FrobTarget).PickupAmmoCount = DeusExWeapon(FrobTarget).Default.PickupAmmoCount;
			}
		}
	}

	return bCanPickup;
}

//replace stealing items bark
function DoFrob(Actor Frobber, Inventory frobWith)
{
	local DeusExRootWindow root;
	local Ammo ammo;
	local Inventory item;
	local Actor A;

	// make sure nothing is based on us if we're an inventory
	if (Inventory(FrobTarget) != None)
		foreach FrobTarget.BasedActors(class'Actor', A)
			A.SetBase(None);

	// Co-op Keypad fix: stock DeusEx.Keypad.HackAction() returns early when
	// Level.NetMode != NM_Standalone without opening HUDKeypadWindow!
	// When frobbing a keypad empty-handed (not Multitool-hacking), open the keypad UI
	// for either Host or Client and sync lock/event callbacks cleanly.
	if (Level.NetMode != NM_Standalone && FrobTarget != None && FrobTarget.IsA('Keypad') && frobWith == None)
	{
		if (Keypad(FrobTarget).bHacking)
		{
			if (Keypad(FrobTarget).msgHacking != "")
				ClientMessage(Keypad(FrobTarget).msgHacking);
			return;
		}
		OpenCoopKeypad(Keypad(FrobTarget), (Keypad(FrobTarget).hackStrength == 0.0));
		PlayPickupAnim(FrobTarget.Location);
		return;
	}

	if (FrobTarget != None)
		FrobTarget.Frob(Frobber, frobWith);
	
	if (bruhSound != None)
		PlaySound(bruhSound, SLOT_None, 0.5, true, 1200, 2.0 - 0.2*FRand());

	// if the object destroyed itself, get out
	if (FrobTarget == None)
		return;

	// if the inventory item aborted it's own pickup, get out
	if (FrobTarget.IsA('Inventory') && (FrobTarget.Owner != Self))
		return;

	// alert NPCs that I'm messing with stuff
	if (FrobTarget.bOwned)
	{
		FrobTarget.AISendEvent('Theft', EAITYPE_Visual);
		AISendEvent('Theft', EAITYPE_Visual);
	}

	// play an animation
	if (Mover(FrobTarget) != None)
		PlayPickupAnim(Location); // Do the normal PushButton animation, not Pickup
	else
		PlayPickupAnim(FrobTarget.Location);

	// set the base so the inventory follows us around correctly
	if (Inventory(FrobTarget) != None)
	{
		FrobTarget.SetBase(Frobber);
		FrobTarget.SetPhysics(PHYS_Interpolating);
		FrobTarget.Velocity = vect(0,0,0);	// Prevent items with momentum from falling out of world.
	}
}

function Inventory FindInventoryType( class DesiredClass )
{
	local Inventory Inv;

	//DDL Altered:
	//Classischildof check meant that both rockets and rocketWP used ammorocketwp if found, and so on for other ammo with child classes

	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )   
		if ( Inv.class == DesiredClass || (!Inv.isa('Ammo') && ClassIsChildOf(Inv.Class, DesiredClass)))
			return Inv;
	return None;
} 

function int MakeMolotov( deusexpickup chemicals )
{
	local winebottle w;
	local int requiredchemicals;
	local weaponmolbottle molotov;
	local DeusExRootWindow root;
	local PersonaScreenInventory winInv;
	local bool bDelayPop;

	//Check that we have enough bottles for our current skill
	if (skillsystem.GetSkillLevel(class'SkillDemolition') >= 3)
	{
		requiredchemicals = 2;
	}
	else if (skillsystem.GetSkillLevel(class'SkillDemolition') >= 2)
	{
		requiredchemicals = 3;
	}
	else if (skillsystem.GetSkillLevel(class'SkillDemolition') >= 1)
	{
		requiredchemicals = 4;
	}
	else
	{
		ClientMessage(strNoMolotovSkill);
		return 0;
	}
	if (chemicals.NumCopies < requiredchemicals)
	{
		ClientMessage(strNoMolotovMaterials);
		return 0;
	}

	//Check that we have a wine bottle we can use
	w = winebottle(FindInventoryType( class'winebottle' ));
	if (w == none)
	{
		ClientMessage(strNoMolotovWine);
		return 0;
	}

	//check that we have room for a molotov cocktail and put one in our inventory if we do
	molotov = spawn(class'weaponmolbottle');
	// InventoryFull=molotovMsgNoRoom; //can anyone say hack
	// if (HandleItemPickup(molotov, false) == False)
	// {
		// molotov.destroy();
		// InventoryFull=default.InventoryFull;
		// return 0;
	// }
	// InventoryFull=default.InventoryFull;


	//update all items involved
	if (molotov == None)
		return 0;
	if (FindInventoryType( class'weaponmolbottle' ) == None)
		bDelayPop = True;
	w.UseOnce();
	FrobTarget = molotov;
	ParseRightClick();
	// molotov.Frob(Self,None);

	//Update the belt - bug #578
	DeusExRootWindow(rootWindow).hud.belt.PopulateBelt();
	
	SetAchievement("achMolotov");
	
	// root = DeusExRootWindow(rootWindow);

	// if (root != None)
	// {
		// // If the inventory screen is active, we need to send notification
		// // that the item is being removed
		// winInv = PersonaScreenInventory(root.GetTopWindow());
		// if (winInv != None)
		// {
			// winInv.SignalRefresh();
			// if (bDelayPop)
			// {
				// winInv.RefreshInventoryItemButtons();
				// winInv.CleanBelt();
			// }
		// }
	// }

	return requiredchemicals;
}

function bool CanMakeMolotov( deusexpickup chemicals )
{
	local winebottle w;
	local int requiredchemicals;
	local weaponmolbottle molotov;
	local PersonaScreenInventory psi;

	//Check that we have enough bottles for our current skill
	if (skillsystem.GetSkillLevel(class'SkillDemolition') >= 3)
	{
		requiredchemicals = 2;
	}
	else if (skillsystem.GetSkillLevel(class'SkillDemolition') >= 2)
	{
		requiredchemicals = 3;
	}
	else if (skillsystem.GetSkillLevel(class'SkillDemolition') >= 1)
	{
		requiredchemicals = 4;
	}
	else
	{
		return false;
	}
	if (chemicals.NumCopies < requiredchemicals)
	{
		return false;
	}

	//Check that we have a wine bottle we can use
	w = winebottle(FindInventoryType( class'winebottle' ));
	if (w == none)
	{
		return false;
	}
/*
	//check that we have room for a molotov cocktail and put one in our inventory if we do
	molotov = spawn(class'weaponmolbottle');
	molotov.PickupAmmoCount = 0;
	
	if (HandleItemPickup(molotov, true) == False)
	{
		molotov.destroy();
		RepairInventory();
		return false;
	}
	if (molotov != None)
		molotov.destroy();
		RepairInventory();*/
	
	return true;
}

exec function ListActors()
{
	local actor a;
	foreach allactors(class'actor',a,)
		Log(a.name);
}

function GameDirectory GetSaveGameDirectory()
{
	local GameDirectory saveDir;

	// Create our Map Directory class
	saveDir = CreateGameDirectoryObject();
	saveDir.SetDirType(saveDir.EGameDirectoryTypes.GD_SaveGames);
	saveDir.GetGameDirectory();

	return saveDir;
}

function int DeltaTime(DeusExSaveInfo info)
{
	local int dt;
	dt = class'tnmTime'.static.GetMinute() - info.Minute;
	dt += (class'tnmTime'.static.GetHour() - info.Hour) * 60;
	dt += (class'tnmTime'.static.GetDate() - info.Day) * 60 * 24;
	return dt;
}

exec function bool AutoSave(optional bool bForce, optional int chapter)
{
	local DeusExLevelInfo levelInfo;
	local string mapName, saveName;
	local DeusExSaveInfo saveInfo;
	local bool bRecentSave;
	local int max, i, deleteIndex, autosaveCount;
	local GameDirectory saveFolder;
		
	if (saveTime < 10)
	{
		switch(chapter)
		{
			case 20:
				flagbase.SetBool('Autosaved_Downtown',true,,21);
				break;
			case 21:
				flagbase.SetBool('Autosaved_DXI',true,,22);
				break;
			case 22:
				flagbase.SetBool('Autosaved_Day2',true,,23);
				break;
			case 23:
				flagbase.SetBool('Autosaved_ABI',true,,24);
				break;
			case 24:
				flagbase.SetBool('Autosaved_GameSpy',true,,25);
				break;
			Default:
				break;
		}
		return True;
	}

	if (!IsSaveAllowed())
	   return False;

	if(!bForce && MaximumAutosaves == 0)
		return False;
		
	if (dataLinkPlay != None)
		return False;

	deleteIndex = -1;

	foreach AllActors(class'DeusExLevelInfo', levelInfo)
		mapName = levelInfo.MissionLocation;

	max = 0;

	saveFolder = GetSaveGameDirectory();   
	if(!bForce)
	{
		saveName = strBackupSave;		
	}
	else
	{
		saveName = strAutoSave;
	}

	for(i=0;i<saveFolder.GetDirCount();i++)
	{		
		saveInfo = saveFolder.GetSaveInfoFromDirectoryIndex(i);
		if(saveInfo != none)
		{
			if(!bForce && left(saveInfo.Description,len(saveName))~=saveName)
			{
				// if(MaximumAutosaves>=0 && ++autosaveCount>=MaximumAutosaves && deleteIndex==-1)
					// deleteIndex=saveInfo.DirectoryIndex;
				if(DeltaTime(saveInfo)<BackupSaveInterval //if the month or year has changed, we're going to go ahead and just make a new save
					&& saveInfo.Month == class'tnmTime'.static.GetMonth()
					&& saveInfo.Year == class'tnmTime'.static.GetYear())
				{
					bRecentSave = true;
				}
			}
			if(saveInfo.DirectoryIndex > max)
				max = saveInfo.DirectoryIndex;
			saveFolder.DeleteSaveInfo(saveInfo);
		}
	}

	if(!bRecentSave || bForce)
	{
		switch(chapter)
		{
			case 20:
				flagbase.SetBool('Autosaved_Downtown',true,,21);
				break;
			case 21:
				flagbase.SetBool('Autosaved_DXI',true,,22);
				break;
			case 22:
				flagbase.SetBool('Autosaved_Day2',true,,23);
				break;
			case 23:
				flagbase.SetBool('Autosaved_ABI',true,,24);
				break;
			case 24:
				flagbase.SetBool('Autosaved_GameSpy',true,,25);
				break;
			Default:
				break;
		}
		// if(deleteIndex != -1)
			// ConsoleCommand("deletegame"@deleteIndex);

		bAutosave = bForce;
		CanLoad = false;
		if(mapName != "")
			mapName = saveName@"-"@mapName;
		else
			mapName = saveName;	
		if (dataLinkPlay != None && bAllowSavesDuringInfolinks) 
			dataLinkPlay.AbortAndSaveHistory();
		SaveGame(max+1, mapName);
		CanLoad = true;
		bAutosave = false;
	}

	CriticalDelete(saveFolder);
	
	return True;
}

function bool IsSaveAllowed()
{
	local DeusExLevelInfo info;

	info = GetLevelInfo();

	// Don't allow saving if:
	//
	// 1) The player is dead
	// 2) We're on the logo map
	// 4) We're interpolating (playing outtro)
	// 3) A datalink is playing	
    // 4) We're in a multiplayer game
	// 5) Something has set CantSave

	if (CantSave)
	   return false;

	if (((info != None) && (info.MissionNumber < 0)) || 
	   ((IsInState('Dying')) || (IsInState('Paralyzed')) || (IsInState('Interpolating'))) || 
	   (dataLinkPlay != None && !bAllowSavesDuringInfolinks) || (dataLinkPlay != None && dataLinkPlay.bStartTransmission) || (Level.Netmode != NM_Standalone) || 
	   bPlatformer || 	// radish adventure
	   ((info != None) && (info.MissionNumber == 95))) // Stealth missions
	{
	   return false;
	}

	return true;
}

exec function QuickSave()
{
	local int QuickSaveNum;
	
	if (!IsSaveAllowed())
	   return;

	CanLoad = false;
	
	if (dataLinkPlay != None && bAllowSavesDuringInfolinks) 
		dataLinkPlay.AbortAndSaveHistory();

	QuickSaveNum = int(ConsoleCommand("get Trestkon QuickSaveNumber"));
	
	// Save up to three copies of the quicksave.
	// As -1 is the quicksave by default this will be used, however since -3 is already used for AutoSave other values will be used.
	// 0: this is our first time quicksaving, save to -1.
	// -1: First save
	// -5: Second save
	// -6: Third save
	switch(QuickSaveNum)
	{
		case 0:
			ConsoleCommand("set Trestkon QuickSaveNumber " $ -1);
			SaveGame(-6, QuickSaveGameTitle @ "(0)");
			break;
			
		case -1:
			ConsoleCommand("set Trestkon QuickSaveNumber " $ -5);
			SaveGame(QuickSaveNum, QuickSaveGameTitle @ "(1)");
			break;
			
		case -5:
			ConsoleCommand("set Trestkon QuickSaveNumber " $ -6);
			SaveGame(QuickSaveNum, QuickSaveGameTitle @ "(2)");
			break;
			
		case -6:
			ConsoleCommand("set Trestkon QuickSaveNumber " $ -1);
			SaveGame(QuickSaveNum, QuickSaveGameTitle @ "(3)");
			break;
	}

	// SaveGame(-1, QuickSaveGameTitle);

	CanLoad = true;

	AutoSave(false);
}

// ----------------------------------------------------------------------
// QuickLoad()
// ----------------------------------------------------------------------

exec function QuickLoad()
{
	local DeusExLevelInfo info;

	//Don't allow in multiplayer.
	if (Level.Netmode != NM_Standalone || bPlatformer)
		return;

	if (!CanLoad)
		return;

	if ( IsInState('Dying') )
	{
		QuickLoadConfirmed();
		return;
	}

	foreach AllActors(class'DeusExLevelInfo', info)
	{	
		if ( Caps(Info.mapName) == "TNMONLY" || Caps(Info.mapName) == "TNMONLY_2009" || Caps(Info.mapName) == "TNM" || Caps(Info.mapName) == "TNM_2009" )
		{
			//don't bother asking for confirmation if the player is in the menu maps
			QuickLoadConfirmed();
		}
		else
		{
			if (DeusExRootWindow(rootWindow) != None)
				DeusExRootWindow(rootWindow).ConfirmQuickLoad();
		}
		break;
	}
}

function QuickLoadConfirmed()
{	
	if (Level.Netmode != NM_Standalone)
		return;
		
	// Transient, always deleted
	if (irc_link != None)
		irc_link.ServerQuit(QR_Loading);
	
	consolecommand("open tnmloadsave");
}

function bool CheckFlagRefs( ConFlagRef flagRef )
{
	local ConFlagRef currentRef;

	// Loop through our list of FlagRef's, checking the value of each.
	// If we hit a bad match, then we'll stop right away since there's
	// no point of continuing.

	currentRef = flagRef;

	// These must return false, returning true will ignore ALL other flag checks.
	while( currentRef != None )
	{
		if ( currentRef.flagName == 'drunk')
		{
			if (drugEffectTimer <= 0.0)
				return false;
		}
		// return currentRef.value == (drugEffectTimer > 0.0);

		else if ( currentRef.flagName == 'HAS_MasterKaleCorpse' )
		{
			if (inhand != none && inhand.isA( 'tnmpovcorpse' ) && tnmpovcorpse(inhand).givenbindname == "Master_Kale")
			{
			}
			else
				return false;
		}

		else if ( flagBase.GetBool(currentRef.flagName) != currentRef.value )
			return False;

		currentRef = currentRef.nextFlagRef;
	}
	
	// If we made it this far, then the flags check out.
	return True;
}

function bool DXReduceDamage(int Damage, name damageType, vector hitLocation, out int adjustedDamage, bool bCheckOnly)
{
	local float newDamage;
	local float augLevel, skillLevel;
	local float pct;
	local HazMatSuit suit;
	local BallisticArmor armor;
	local bool bReduced;
	local bool bFlashed;
	local gasmask mask;

	bReduced = False;
	newDamage = Float(Damage);

	if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'Radiation') ||
		(damageType == 'HalonGas')  || (damageType == 'PoisonEffect') || (damageType == 'Poison'))
	{
		if (AugmentationSystem != None)
			augLevel = AugmentationSystem.GetAugLevelValue(class'AugEnviro');

		if (augLevel >= 0.0)
		{
			newDamage *= augLevel;
			ClientFlash(0.01, vect(0, 80, 0));
			bFlashed=true;
		}

		// get rid of poison if we're maxed out
		if (newDamage ~= 0.0)
		{
			StopPoison();
			drugEffectTimer -= 4;	// stop the drunk effect
			if (drugEffectTimer < 0)
				drugEffectTimer = 0;
		}
		/*
		if (UsingChargedPickup(class'HazMatSuit'))
		{
			skillLevel = SkillSystem.GetSkillLevelValue(class'SkillEnviro');
			newDamage *= 0.75 * skillLevel;
		}*/
	}

	if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'Radiation') ||
		(damageType == 'HalonGas')  || (damageType == 'PoisonEffect') || (damageType == 'Poison') ||
		(damageType == 'Flamed') || (damageType == 'EMP') || (damageType == 'Shocked') || (damageType == 'Burned')) //Damage types that it was supposed to protect you from, but didn't
	{
		if (UsingChargedPickup(class'HazMatSuit'))
		{
			skillLevel = SkillSystem.GetSkillLevelValue(class'SkillEnviro');
			newDamage *= 0.75 * skillLevel;
		}
	}

	if ((damageType == 'Shot') || (damageType == 'Sabot') || (damageType == 'Exploded') || (damageType == 'AutoShot'))
	{
		if (UsingChargedPickup(class'BallisticArmor'))
		{
			skillLevel = SkillSystem.GetSkillLevelValue(class'SkillEnviro');
			newDamage *= 0.5 * skillLevel;
		}
	}

	if (damageType == 'HalonGas')
	{
		DebugMessage("Took halon damage");
		HalonGastimer = 0.5;
		if (bOnFire && !bCheckOnly)
			ExtinguishFire();
		adjusteddamage = 0;
		return true;
	}

	if ((damageType == 'Shot') || (damageType == 'AutoShot') || (damageType == 'Sabot'))
	{
		if (AugmentationSystem != None)
			augLevel = AugmentationSystem.GetAugLevelValue(class'AugBallistic');

		if (augLevel >= 0.0)
		{
			newDamage *= augLevel;
			ClientFlash(0.01, vect(60, 60, 0));
			bFlashed=true;
		}
	}

	if (damageType == 'EMP')
	{
		if (AugmentationSystem != None)
			augLevel = AugmentationSystem.GetAugLevelValue(class'AugEMP');

		if (augLevel >= 0.0)
		{
			newDamage *= augLevel;
			ClientFlash(0.03, vect(90, 0, 90));
			bFlashed=true;
		}
	}

	if ((damageType == 'Burned') || (damageType == 'Flamed') ||
		(damageType == 'Exploded') || (damageType == 'Shocked'))
	{
		if (AugmentationSystem != None)
			augLevel = AugmentationSystem.GetAugLevelValue(class'AugShield');

		if (augLevel >= 0.0)
		{
			newDamage *= augLevel;
			ClientFlash(0.01, vect(60, 30, 0));
			bFlashed=true;
			DrawEnergyShield();
		}
	}

	if (newDamage < Damage)
	{
		if (!bCheckOnly)
		{
			pct = 1.0 - (newDamage / Float(Damage));
			SetDamagePercent(pct);
			if (!bFlashed)
				ClientFlash(0.01, vect(25, 25, 25));
		}
		bReduced = True;
	}/* ?? This breaks EMP shield (spiderbot deals EMP and shocked damage, which would cancel the aug)
	else
	{
		if (!bCheckOnly)
			SetDamagePercent(0.0);
	}*/

	if ((damageType == 'Shot') || (damageType == 'AutoShot') || (damageType == 'Sabot') || (damageType == 'StunnedTaser'))
	{
		newDamage *= CombatDifficulty;

		// always take at least one point of damage
		if ((newDamage <= 1) && (Damage > 0))
			newDamage = 1;
	}

	adjustedDamage = Int(newDamage);

	if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'HalonGas'))
	{
		if (UsingChargedPickup(class'GasMask'))
		{
			//skillLevel = SkillSystem.GetSkillLevelValue(class'SkillEnviro');
			//newDamage *= 0.75 * skillLevel;
			adjustedDamage = 0.0;
			breduced = true;
		}
	}

	return breduced;
}

function PlayDXTakeDamageHit(float Damage, vector HitLocation, name damageType, vector Momentum, bool DamageReduced)
{
	local float rnd;

	//Don't do anything, damage-wise, if wearing a gasmask.
	if (UsingChargedPickup(class'GasMask'))
	{
		if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'HalonGas'))
			return;
	}

   PlayHit(Damage,HitLocation,damageType,Momentum);

	// if we actually took the full damage, flash the screen and play the sound
   // DEUS_EX AMSD DXReduceDamage is slow.  Pass in the result from earlier.
	if (!DamageReduced) 
	{
		if ( (damage > 0) || (ReducedDamageType == 'All') )
		{
			// No client flash on plasma bolts in multiplayer
			if (( Level.NetMode != NM_Standalone ) && ( myProjKiller != None ) && (PlasmaBolt(myProjKiller)!=None) )
			{
			}
			else
			{
				rnd = FClamp(Damage, 20, 100);
				if (damageType == 'Burned')
					ClientFlash(rnd * 0.001, vect(200,100,100));
				else if (damageType == 'Flamed')
					ClientFlash(rnd * 0.002, vect(200,100,100));
				else if (damageType == 'Radiation')
					ClientFlash(rnd * 0.002, vect(100,100,0));
				else if (damageType == 'PoisonGas')
					ClientFlash(rnd * 0.002, vect(50,150,0));
				else if (damageType == 'TearGas')
					ClientFlash(rnd * 0.002, vect(150,150,0));
				else if (damageType == 'Drowned')
					ClientFlash(rnd * 0.002, vect(0,100,200));
				else if (damageType == 'EMP')
					ClientFlash(rnd * 0.002, vect(0,200,200));
				else 
					ClientFlash(rnd * 0.002, vect(50,0,0));
			}
			ShakeView(0.15 + 0.002 * Damage, Damage * 30, 0.3 * Damage); 
		}
	}
}

function AddChargedDisplay(ChargedPickup item)
{
	if (item.isA('gasmask'))
		tnmhud(deusexrootwindow(rootwindow).hud).mask.ActivateView(80, true);

	super.AddChargedDisplay(item);
}

function RemoveChargedDisplay(ChargedPickup item)
{
	if (item.isA('gasmask'))
	{
		// Don't hide the GUI if we have another one on
		if (!UsingChargedPickup(class'gasmask'))
			tnmhud(deusexrootwindow(rootwindow).hud).mask.DeactivateView();
	}
	if (item.isA('HazMatSuit'))
	{
		// Update that we're no longer wearing a suit and potentially can't breathe
		if (!UsingChargedPickup(class'HazMatSuit'))
			HeadZoneChange(HeadRegion.Zone);
	}

	super.RemoveChargedDisplay(item);
}

function name GetFloorMaterial()
{
	local vector EndTrace, HitLocation, HitNormal;
	local actor target;
	local int texFlags;
	local name texName, texGroup;
	local bool bFound;

	// trace down to our feet
	EndTrace = Location - CollisionHeight * 2 * vect(0,0,1);

	foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, HitLocation, HitNormal, EndTrace)
	{
		if ((target == Level) || target.IsA('Mover'))
		{
			bFound=true;
			FloorTexture=texName;
			break;
		}
	}

	// if(!bFound)
		// return 'Default';

	//todo - Well they're called Helisnow, snow1, snow1b, snow2, snow3, snow4, snow5, snow7, and snow8
	bWalkingOnSnow = (FloorTexture == 'snow1')||
			 (FloorTexture == 'snow1b')||
			 (FloorTexture == 'snow2')||
			 (FloorTexture == 'snow3')||
			 (FloorTexture == 'snow4')||
			 (FloorTexture == 'snow5')||
			 (FloorTexture == 'snow7')||
			 (FloorTexture == 'snow8')||
			 (FloorTexture == 'Wall_B_Bot')||
			 (FloorTexture == 'Wall_B_Cen')||
			 (FloorTexture == 'Wall_B_CenB')||
			 (FloorTexture == 'Wall_B_Left')||
			 (FloorTexture == 'Wall_B_Right')||
			 (FloorTexture == 'Wall_B_Top')||
			 (FloorTexture == 'Snow7_Bot')||
			 (FloorTexture == 'snow7_FadeBotLeft')||
			 (FloorTexture == 'snow7_FadeBotRight')||
			 (FloorTexture == 'snow7_FadeLeft')||
			 (FloorTexture == 'snow7_FadeRight')||
			 (FloorTexture == 'snow7_FadeTopLeft')||
			 (FloorTexture == 'snow7_FadeTopRight')||
			 (FloorTexture == 'Snow7_Left')||
			 (FloorTexture == 'Snow7_Right')||
			 (FloorTexture == 'Snow7_TB')||
			 (FloorTexture == 'Snow7_Top')||
			 (FloorTexture == 'Helisnow');
	return texGroup;
}

function SpawnFootprint()
{
	local Vector HitLocation, HitNormal, EndTrace;
	local vector X,Y,Z;
	local Actor hit;
	local tnmshoeprint D;
	local vector start;
	local vector direction;

	if (bWalkingOnSnow)
	{
		footprintoffset *= -1.0;

		GetAxes(ViewRotation,X,Y,Z);

		start = Location + footprintoffset * Y;

		EndTrace = start - 320*vect(0,0,1);
		hit = Trace(HitLocation, HitNormal, EndTrace, start, False);
		D = spawn(Class'TNMShoePrint',,, HitLocation+HitNormal, Rotator(HitNormal));

		if ( D != none)
		{
			D.bLeftFoot = (footprintoffset < 0);
			D.Refresh();

			if ( bWalkingBackwards )
				direction = -vector(rotation);
			else
				direction = vector(rotation);

			D.ReattachDecal(direction);
		}
	}
}

// ----------------------------------------------------------------------
// PlayFootStep()
// copied from deusexplayer to allow for new surface sounds
// ----------------------------------------------------------------------

simulated function PlayFootStep()
{
	local Sound stepSound;
	local float rnd;
	local float speedFactor, massFactor;
	local float volume, pitch, range;
	local float aiVolume, aiRange;
	local float radius, mult;
	local float volumeMul;
	local DeusExPlayer pp;
	local bool bOtherPlayer;
	local precipitationzone pz;

	if (bcinematic)
		return;

	// Only do this on ourself, since this takes into account aug stealth and such
	if ( Level.NetMode != NM_StandAlone )
		pp = DeusExPlayer( GetPlayerPawn() );

	if ( pp != Self )
		bOtherPlayer = True;
	else
		bOtherPlayer = False;

	rnd = FRand();

	volumeMul = 1.0;	
	StepSound = FootStepSound( Volume, VolumeMul );
	
	// Rain masks sound
	if (Region.Zone != None && Region.Zone.IsA('PrecipitationZone'))
		VolumeMul *= 0.85;

	// compute sound volume, range and pitch, based on mass and speed
	if (IsInState('PlayerSwimming') || (Physics == PHYS_Swimming))
		speedFactor = WaterSpeed/180.0;
	else
		speedFactor = VSize(Velocity)/180.0;

	massFactor  = Mass/150.0;
	radius      = 375.0;
	volume      = (speedFactor+0.2) * massFactor;
	range       = radius * volume;
	pitch       = (volume+0.5);
	volume      = FClamp(volume, 0, 1.0) * 0.5;		// Hack to compensate for increased footstep volume.
	range       = FClamp(range, 0.01, radius*4);
	pitch       = FClamp(pitch, 1.0, 1.5);

	// AugStealth decreases our footstep volume
	volume *= RunSilentValue;
	aiVolume = volume * VolumeMul;
	aiRange = range * VolumeMul;
	
	if (bruhSound != None)
		stepSound = bruhSound;

	if ( Level.NetMode == NM_Standalone )
	{
		// HX_HAN: Slightly vary playback volume.
		PlaySound( StepSound, SLOT_Interact, Volume*(0.9+0.2*FRand()), ,Range, Pitch );
	}
	else	// special case for multiplayer
	{
		if ( !bIsWalking )
		{
			// Tone down player's own footsteps
			if ( !bOtherPlayer )
			{
				volume *= 0.33;
				PlaySound(stepSound, SLOT_Interact, volume, , range, pitch);
			}
			else // Exagerate other players sounds (range slightly greater than distance you see with vision aug)
			{
				volume *= 2.0;
				range = (class'AugVision'.Default.mpAugValue * 1.2);
				volume = FClamp(volume, 0, 1.0);
				PlaySound(stepSound, SLOT_Interact, volume, , range, pitch);
			}
		}
	}
	AISendEvent('LoudNoise', EAITYPE_Audio, aiVolume, aiRange);
}

// ----------------------------------------------------------------------
// FootStepSound()
//
// Tries to figure out which footstep sound to use.
//
// Potential Additional Footstep Sounds:
//	* MoverSFX.StallDoorClose
//  * DeusExSounds.KarkianFootstep
//  * DeusExSounds.GreaselFootstep
//  * DeusExSounds.GrayFootstep
// ----------------------------------------------------------------------
simulated function Sound FootStepSound( out float Volume, out float VolumeMul )
{
	local vector EndTrace, HitLocation, HitNormal;
	local actor target;
	local int texFlags;
	local name texName, texGroup;
	local Texture      Tex;
	local Mover        Mover;
	local DeusExDecoration Decoration;
	local DeusExCarcass    Carcass;
	local float        Rnd;

	Volume	  = 1.0;
	VolumeMul = 1.0;

	// Handle Water
	if ( IsInState('PlayerSwimming') || Physics == PHYS_Swimming )
		return SwimmingStepSound( Volume, VolumeMul );
	if ( FootRegion.Zone.bWaterZone )
		return WaterStepSound( Volume, VolumeMul );
	if (PrecipitationZone(FootRegion.Zone) != None
			&& SnowZone(FootRegion.Zone) == None
			&& PrecipitationZone(FootRegion.Zone).PrecipGen != None 
			&& PrecipitationZone(FootRegion.Zone).PrecipGen.bWeatherEnabled
			&& PrecipitationZone(FootRegion.Zone).PrecipGen.bOn
		)
		return WaterSplashSound( volume, VolumeMul );

	// trace down to our feet
	EndTrace = Location - CollisionHeight * 2 * vect(0,0,1);

	foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, HitLocation, HitNormal, EndTrace)
	{
		// Vanilla behaviour for Level Geometry.
		if ( target == Level )
			return TextureGroupStepSound( Volume, VolumeMul, Tex, TexGroup );

		// Choose Decoration FootStepSound based on FragType.
		Decoration = DeusExDecoration(target);
		if ( Decoration != None )
			return DecorationStepSound( Volume, VolumeMul, Decoration );

		// Carcass.
		Carcass = DeusExCarcass(target);
		if ( Carcass != None )
			return CarcassStepSound( Volume, VolumeMul, Carcass );

		// Not yet supported.
		// Mover = Mover(target);
		// if ( Mover != None )
			// ;
	}
	return FallbackStepSound( Volume, VolumeMul );
}

// ----------------------------------------------------------------------
// GetWallMaterial()
//
// gets the name of the texture group that we are facing
// Overridden to used fixed TraceTexture.
// ----------------------------------------------------------------------
function name GetWallMaterial(out vector wallNormal)
{
	local vector EndTrace, HitLocation, HitNormal;
	local actor target;
	local int texFlags, grabDist;
	local name texName, texGroup;

	// if we are falling, then increase our grabbing distance
	if (Physics == PHYS_Falling)
		grabDist = 3.0;
	else
		grabDist = 1.5;

	// trace out in front of us
	EndTrace = Location + (Vector(Rotation) * CollisionRadius * grabDist);

 	foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, HitLocation, HitNormal, EndTrace)
	{
		if ((target == Level) || target.IsA('Mover'))
			break;
	}

	wallNormal = HitNormal;

	return texGroup;
}

// ----------------------------------------------------------------------
// TextureGroupStepSound()
//
// Used for Bsp based footsteps.
// ----------------------------------------------------------------------
simulated function Sound TextureGroupStepSound( out float Volume, out float VolumeMul, Texture Texture, Name TextureGroup )
{
	local float Rnd;

	// Set Volume and VolumeMul first.
	switch ( TextureGroup )
	{
		case 'Metal':
		case 'Ladder':
			VolumeMul = 1.0;
			break;
		case 'Foliage':
		case 'Earth':
			VolumeMul = 0.6;
			break;
		default:
			VolumeMul = 0.7;
			break;
	}

	// Use Texture.FootstepSound if available.
	if ( Texture != None  && Texture.FootstepSound != None )
		return Texture.FootstepSound;

	Rnd = FRand();
	
	// Because I screwed up on group name
	if (
	 (FloorTexture == 'Wall_B_Bot')||
	 (FloorTexture == 'Wall_B_Cen')||
	 (FloorTexture == 'Wall_B_CenB')||
	 (FloorTexture == 'Wall_B_Left')||
	 (FloorTexture == 'Wall_B_Right')||
	 (FloorTexture == 'Wall_B_Top')||
	 (FloorTexture == 'Snow7_Bot')||
	 (FloorTexture == 'snow7_FadeBotLeft')||
	 (FloorTexture == 'snow7_FadeBotRight')||
	 (FloorTexture == 'snow7_FadeLeft')||
	 (FloorTexture == 'snow7_FadeRight')||
	 (FloorTexture == 'snow7_FadeTopLeft')||
	 (FloorTexture == 'snow7_FadeTopRight')||
	 (FloorTexture == 'Snow7_Left')||
	 (FloorTexture == 'Snow7_Right')||
	 (FloorTexture == 'Snow7_TB')||
	 (FloorTexture == 'Snow7_Top'))
	{
		if (rnd < 0.1)
			return Sound'snowstep1';
		else if (rnd < 0.2)
			return Sound'snowstep2';
		else if (rnd < 0.3)
			return Sound'snowstep3';
		else if (rnd < 0.4)
			return Sound'snowstep4';
		else if (rnd < 0.5)
			return Sound'snowstep5';
		else if (rnd < 0.6)
			return Sound'snowstep6';
		else if (rnd < 0.7)
			return Sound'snowstep7';
		else if (rnd < 0.8)
			return Sound'snowstep8';
		else if (rnd < 0.9)
			return Sound'snowstep9';
		else
			return Sound'snowstep10';
	}
	
	switch(TextureGroup)
	{
		case 'Carpet':
		case 'Textile':
		case 'Paper':
		case 'Charts':
		case 'WallDeco':
			VolumeMul = 0.7;
			if (rnd < 0.25)
				return Sound'CarpetStep1';
			else if (rnd < 0.5)
				return Sound'CarpetStep2';
			else if (rnd < 0.75)
				return Sound'CarpetStep3';
			else
				return Sound'CarpetStep4';
			break;

		case 'Foliage':
		case 'Earth':
			VolumeMul = 0.6;
			if (rnd < 0.25)
				return Sound'GrassStep1';
			else if (rnd < 0.5)
				return Sound'GrassStep2';
			else if (rnd < 0.75)
				return Sound'GrassStep3';
			else
				return Sound'GrassStep4';
			break;

		case 'Metal':
		case 'Server':
		case 'Ladder':
		case 'SpaceStation':
			VolumeMul = 1.0;
			if (rnd < 0.25)
				return Sound'MetalStep1';
			else if (rnd < 0.5)
				return Sound'MetalStep2';
			else if (rnd < 0.75)
				return Sound'MetalStep3';
			else
				return Sound'MetalStep4';
			break;

		case 'MuffledMetal': // Metal but quiet so it doesn't travel vertically
			VolumeMul = 0.50;
			if (rnd < 0.25)
				return Sound'MetalStep1';
			else if (rnd < 0.5)
				return Sound'MetalStep2';
			else if (rnd < 0.75)
				return Sound'MetalStep3';
			else
				return Sound'MetalStep4';
			break;

		case 'Ceramic':
		case 'Glass':
		case 'Tiles':
			VolumeMul = 0.7;
			if (rnd < 0.25)
				return Sound'TileStep1';
			else if (rnd < 0.5)
				return Sound'TileStep2';
			else if (rnd < 0.75)
				return Sound'TileStep3';
			else
				return Sound'TileStep4';
			break;

		case 'Wood':
		case 'Books':
			VolumeMul = 0.7;
			if (rnd < 0.25)
				return Sound'WoodStep1';
			else if (rnd < 0.5)
				return Sound'WoodStep2';
			else if (rnd < 0.75)
				return Sound'WoodStep3';
			else
				return Sound'WoodStep4';
			break;

		case 'Landscape': //ie snow
			VolumeMul = 0.6;

//				if (bWalkingOnSnow)				    
//				{
				SpawnFootprint();

				//I wish there were some way to import sounds into an array so I
				//could do this as an iteration :(
				if (rnd < 0.1)
					return Sound'snowstep1';
				else if (rnd < 0.2)
					return Sound'snowstep2';
				else if (rnd < 0.3)
					return Sound'snowstep3';
				else if (rnd < 0.4)
					return Sound'snowstep4';
				else if (rnd < 0.5)
					return Sound'snowstep5';
				else if (rnd < 0.6)
					return Sound'snowstep6';
				else if (rnd < 0.7)
					return Sound'snowstep7';
				else if (rnd < 0.8)
					return Sound'snowstep8';
				else if (rnd < 0.9)
					return Sound'snowstep9';
				else
					return Sound'snowstep10';
//				}
			break;

		case 'Brick':
		case 'Concrete':
		case 'Stone':
		case 'Stucco':
		default:
			VolumeMul = 0.7;
			if (rnd < 0.25)
				return Sound'StoneStep1';
			else if (rnd < 0.5)
				return Sound'StoneStep2';
			else if (rnd < 0.75)
				return Sound'StoneStep3';
			else
				return Sound'StoneStep4';
			break;
	}
}

// ----------------------------------------------------------------------
// CarcassStepSound()
//
// StepSound for walking over carcass.
// ----------------------------------------------------------------------
simulated function Sound CarcassStepSound( out float Volume, out float VolumeMul, DeusExCarcass Carcass )
{
	VolumeMul = 0.5;
	Volume    = 0.5;
	return Sound'KarkianFootstep';
}

// ----------------------------------------------------------------------
// DecorationStepSound()
//
// StepSound for walking over carcass.
// ----------------------------------------------------------------------
simulated function Sound DecorationStepSound( out float Volume, out float VolumeMul, DeusExDecoration Decoration )
{
	if ( Decoration.FragType == None )
	{
		Log( Decoration@"has empty FragType. Report this as a Bug." );
		return Sound'TouchTone11';
	}
	switch ( Decoration.FragType.Name )
	{
		case 'GlassFragment':		return TextureGroupStepSound( Volume, VolumeMul, None, 'Glass' );
		case 'MetalFragment':		return TextureGroupStepSound( Volume, VolumeMul, None, 'Metal' );
		case 'PaperFragment':
			VolumeMul = 0.3;
			Volume    = 1.2;
			return TextureGroupStepSound( Volume, VolumeMul, None, 'Tiles' );
			// return Sound'StallDoorClose';
		case 'InfoDeviceFragment':
		case 'PlasticFragment':	return TextureGroupStepSound( Volume, VolumeMul, None, 'Plastic' );
		case 'WoodFragment':		return TextureGroupStepSound( Volume, VolumeMul, None, 'Wood' );
		case 'Rockchip':				return TextureGroupStepSound( Volume, VolumeMul, None, 'Stone' );
		case 'FleshFragment':
			VolumeMul = 0.5;
			Volume    = 0.5;
			return Sound'KarkianFootstep';
		case 'GrassFragment': return TextureGroupStepSound( Volume, VolumeMul, None, 'Foliage' );
		default:
			Log( "Unhandled FragType="$Decoration.FragType.Name$" in GetFootStepGroup() Report this as a Bug." );
			return Sound'TouchTone5';
	}
}

// ----------------------------------------------------------------------
// FallbackStepSound()
// ----------------------------------------------------------------------
simulated function Sound FallbackStepSound( out float Volume, out float VolumeMul )
{
	return TextureGroupStepSound( Volume, VolumeMul, None, 'Brick' );
}

// ----------------------------------------------------------------------
// SwimmingStepSound()
// ----------------------------------------------------------------------
simulated function Sound SwimmingStepSound( out float Volume, out float VolumeMul )
{
	VolumeMul = 0.5;
	if (FRand() < 0.5)
		return Sound'Swimming';
	else
		return Sound'Treading';
}

// ----------------------------------------------------------------------
// WaterStepSound()
// ----------------------------------------------------------------------
simulated function Sound WaterStepSound( out float Volume, out float VolumeMul )
{
	local float Rnd;
	VolumeMul = 1.0;
	Rnd = FRand();
	if (Rnd < 0.33)
		return Sound'WaterStep1';
	if (Rnd < 0.66)
		return Sound'WaterStep2';
	else
		return Sound'WaterStep3';
}

// ----------------------------------------------------------------------
// WaterStepSound()
// ----------------------------------------------------------------------
simulated function Sound WaterSplashSound( out float Volume, out float VolumeMul )
{
	local float Rnd;
	VolumeMul = 1.0;
	Rnd = FRand();
	if (rnd < 0.25)
		return Sound'splashStep1';
	else if (rnd < 0.50)
		return Sound'splashStep2';
	else if ( rnd < 0.75)
		return Sound'splashStep3';
	else
		return Sound'splashStep4';
}

//-----------------------------------------------------------------------

	function DeusExGoal AddGoal( Name goalName, bool bPrimaryGoal )
	{
		local DeusExGoal newGoal;

		// First check to see if this goal already exists.  If so, we'll just
		// return it.  Otherwise create a new goal

		newGoal = FindGoal( goalName );
		

		if ( newGoal == None )
		{
			newGoal = new(None) Class'DeusExGoal';
			newGoal.SetName( goalName );

			// Insert goal at the Top so goals are displayed in
			// Newest order first.
			if (FirstGoal == None)
				LastGoal  = newGoal;
			else
				newGoal.next = FirstGoal;
	
			FirstGoal    = newGoal;
	
			newGoal.SetPrimaryGoal( bPrimaryGoal );
	
			ClientMessage(GoalAdded);
			if (DeusExRootWindow(rootWindow) != None && DeusExRootWindow(rootWindow).hud != None && DeusExRootWindow(rootWindow).hud.msgLog != None)
				DeusExRootWindow(rootWindow).hud.msgLog.PlayLogSound(Sound'tnmLogGoalAdded');
		}
		else
		{
			ClientMessage(strGoalUpdated);
			if (DeusExRootWindow(rootWindow) != None && DeusExRootWindow(rootWindow).hud != None && DeusExRootWindow(rootWindow).hud.msgLog != None)
				DeusExRootWindow(rootWindow).hud.msgLog.PlayLogSound(Sound'tnmLogGoalAdded');
		}
	
		return newGoal;
	}
	function GoalCompleted( Name goalName )
	{
		local DeusExGoal goal;

		// Loop through all the goals until we hit the one we're
		// looking for.
		goal = FindGoal( goalName );

		if ( goal != None )
		{
			// Only mark a goal as completed once!
			if (!goal.IsCompleted())
			{
				goal.SetCompleted();
				if (DeusExRootWindow(rootWindow) != None && DeusExRootWindow(rootWindow).hud != None && DeusExRootWindow(rootWindow).hud.msgLog != None)
					DeusExRootWindow(rootWindow).hud.msgLog.PlayLogSound(Sound'tnmLogGoalCompleted');
		
				// Let the player know
				if ( goal.bPrimaryGoal )
					ClientMessage(PrimaryGoalCompleted);
				else
					ClientMessage(SecondaryGoalCompleted);
			}
		}
	}
	function DeusExNote AddNote( optional String strNote, optional Bool bUserNote, optional bool bShowInLog )
	{
		local DeusExNote newNote;

		newNote = new(None) Class'DeusExNote';

		newNote.text = strNote;
		newNote.SetUserNote( bUserNote );

		// Insert this new note at the top of the notes list
		if (FirstNote == None)
			LastNote  = newNote;
		else
			newNote.next = FirstNote;

		FirstNote = newNote;

		// Optionally show the note in the log
		if ( bShowInLog )
		{
			ClientMessage(NoteAdded);
			if (DeusExRootWindow(rootWindow) != None && DeusExRootWindow(rootWindow).hud != None && DeusExRootWindow(rootWindow).hud.msgLog != None)
				DeusExRootWindow(rootWindow).hud.msgLog.PlayLogSound(Sound'tnmLogNoteAdded');
		}

		return newNote;
	}

	function SkillPointsAdd(int numPoints)
	{
		if (numPoints > 0)
		{
			SkillPointsAvail += numPoints;
			SkillPointsTotal += numPoints;

			ClientMessage(Sprintf(SkillPointsAward, numPoints));
			if ((DeusExRootWindow(rootWindow) != None) &&
			    (DeusExRootWindow(rootWindow).hud != None) &&
				(DeusExRootWindow(rootWindow).hud.msgLog != None))
			{
				DeusExRootWindow(rootWindow).hud.msgLog.PlayLogSound(Sound'tnmLogSkillPoints');
			}
		}
	}
//-------------------------------------------------------------------------------------

exec function ToggleEggDisplay()
{
	local DeusExRootWindow root;

	bEggVisible = !bEggVisible && (counteggs()>0);

	root = DeusExRootWindow(rootWindow);
	if (root != None)
		root.UpdateHud();
}

/*exec*/ function addegg(int ID)
{
	if (ID <= 0 || ID > 16)
		return;
	if(eggs<0)
		eggs=19734;
	eggs = ((eggs ^ 19734) | (1 << (ID - 1))) ^ 19734;
	Saveconfig(); //untested //lags
}

function eggAchievement()
{
	SetAchievement("achOneEgg");
	if (eggs == 45801)
		SetAchievement("achAllEggs");
}

exec function bool hasegg(int ID)
{
	if(eggs<0)
		eggs=19734;
	return (((eggs ^ 19734) >> (ID-1)) & 1) == 1;
//	return (((1 << (ID - 1)) ^ 19734) & 19734) > 0;
}

function int counteggs()
{
	local int NumEggs;
	local int curEggs;
	NumEggs = 0;
	for(curEggs = (eggs ^ 19734); curEggs > 0; curEggs = curEggs >> 1)
	{
	    if((curEggs & 1) != 0)
        	NumEggs++;
	}
	return Numeggs;
}

exec function geteggcount()
{
	clientmessage(counteggs());
}

// ----------------------------------------------------------------------
// UpdatePlayerSkin()
// ----------------------------------------------------------------------

function UpdatePlayerSkin()
{
	local trestkoncarcass tc;
	local treskton tresk;

	// JC Denton Carcass
	foreach AllActors(class'TrestkonCarcass', tc)
		break;

	if (tc != None)
		tc.SetSkin(Self);

	foreach AllActors(class'treskton', tresk)
		tresk.SetSkin(Self);
}

function PreTravel()
{
	local tnmTextureController tc;
	local TNMScriptedTextureController stc;
	local TNMWeapon ourWeapon;
	local tnmtimer atimer;
	local Inventory item, nextItem, lastItem;

	if (bPlatformer && Inventory != None)
	{
		item = Inventory;
		nextItem = item.Inventory;
		lastItem = item;

		do
		{
			if (!item.IsA('weaponfists') && (item != None) && item.bDisplayableInv || item.IsA('Ammo'))
			{
				// make sure everything is turned off
				if (item.IsA('DeusExWeapon'))
				{
					DeusExWeapon(item).ScopeOff();
					DeusExWeapon(item).LaserOff();
				}
				if (item.IsA('DeusExPickup'))
				{
					if (DeusExPickup(item).bActive)
						DeusExPickup(item).Activate();
				}

   			if (item.IsA('ChargedPickup'))
					RemoveChargedDisplay(ChargedPickup(item));

				DeleteInventory(item);
				item.Destroy();
				item = Inventory;
			}
			else
				item = nextItem;

			if (item != None)
				nextItem = item.Inventory;
		}
		until ((item == None) || (item == lastItem));
	}

	// Super.PreTravel();
		
	if (Viewport(Player) != None)
		ResetKeyboard();

	if (Level.NetMode != NM_Standalone && DeusExRootWindow(rootWindow) != None)
		DeusExRootWindow(rootWindow).ClearWindowStack();
	
	if (flagBase != None)
		flagBase.SetBool('PlayerTraveling', True, True, 0);

	SaveSkillPoints();

	if (dataLinkPlay != None)
		dataLinkPlay.AbortAndSaveHistory();

	// If the player is burning (Fire! Fire!), extinguish him
	// before the map transition.  This is done to fix stuff 
	// that's fucked up.
	ExtinguishFire();

	drugEffectTimer = 0;

	foreach AllActors(class'tnmTextureController',tc)
		tc.slavetexture.notifyactor=none;

	foreach AllActors(class'TNMScriptedTextureController',stc)
		ScriptedTexture(stc.ScriptedTexture).notifyactor=none;

	if(buf!=none)
	{
		buf.ToString(self);
	}
	
	//Bjorn: Turn off the laser on the weapon before traveling to prevent lots of laser dots in the maps.
	ourWeapon = TNMWeapon(Weapon);
	
	if (ourWeapon != None && ourWeapon.bLasing)
	{
		ourWeapon.bWasLasing = ourWeapon.bLasing;
		ourWeapon.LaserOff();
	}
	
	// Transient, always deleted
	if (irc_link != None)
		irc_link.ServerQuit(QR_LevelTrans);
		
	FrobTarget = None;

    // if ( DeusExRootWindow(rootWindow) != None && TNMHUD(DeusExRootWindow(rootWindow).hud) != None && TNMHUD(DeusExRootWindow(rootWindow).hud).newtimer != None )
       // TNMHUD(DeusExRootWindow(rootWindow).hud).newtimer.Destroy();

    foreach AllActors(class'TNMTimer', atimer)
	{
		atimer.Destroy();
	}
}

simulated event TravelPostAccept()
{
	local DeusExLevelInfo info;
	local bool bhasvisor;
	local bool bhasglasses;
	local bool bhascoat;
	local int tempskin;
	local flagbase flags;
	local tnmTextureController tc;
	local TNMScriptedTextureController stc;
	local int i;
	local DeusExLevelInfo dxInfo;
	local string localURL;
	
	local inventory anItem; //Used for fists spawning.

	if (Level.NetMode != NM_Standalone && tnmGameInfo(Level.Game) != None)
		tnmGameInfo(Level.Game).RestoreCoopSessionFromDefaults(Self);

	Super.TravelPostAccept();
	
	//WCCC, 12/7/24: Thanks to a special somebody, this is our replacement for a certain render fix.
	//Shoutout to the wonderful Aizome 8086 for doing the R&D behind how to do something similar.
	class'tnmUnlitFix'.Static.PatchUnlitSurfaces();
	
	if (AugmentationSystem != None)
	{
		AugmentationSystem.SetPlayer(Self);
		AugmentationSystem.SetOwner(Self);
		if (AugmentationSystem.NumAugsActive() == 0)
			AmbientSound = None;
	}
	if (SkillSystem != None)
	{
		SkillSystem.SetPlayer(Self);
		SkillSystem.SetOwner(Self);
	}
		
    if(bCrouchOn && bToggleCrouch && FlagBase != None && !FlagBase.GetBool('PlayerTraveling')) 
	{
        bWasCrouchOn = false;
        bDuck = 1;
    }
		
	GlobalFacelift(bHDTPWeapons);

	foreach AllActors(class'tnmTextureController',tc)
		tc.beginplay();

	foreach AllActors(class'TNMScriptedTextureController',stc)
		stc.beginplay();

	foreach AllActors(class'DeusExLevelInfo', dxInfo)
		break;
	
	if (dxInfo != None)
		localURL = Caps(dxInfo.mapName);

	if (localURL == "23_ABIEXTERIOR" || localURL == "23_ABIEXTERIOR_2009" || localURL == "23_ABIAPPROACH")
		bVisibleBreath=True;

	
	//WCCC 3/16/19: Implement a failsafe for not spawning with player fists.
	//NOTE: Due to how initialization is processed, do this on a delay. Ew.
	if (FindInventoryType(class'WeaponFists') == None)
	{
		anitem = Spawn(class'weaponfists');
		//NOTE: Belt status is *incredibly* stubborn, so just use this as a loophole.
		//I hate it. I love it. I dunno anymore.
		anitem.Icon = None;
		anitem.Frob(self, none);
		anitem.Icon = anItem.Default.Icon;
	}
	if (PlayerFists == None || PlayerFists.Owner != Self)
	{
		PlayerFists = WeaponFists(FindInventoryType(class'WeaponFists'));
		if (PlayerFists != None)
		{
			PlayerFists.SetOwner(Self);
			PlayerFists.bInObjectBelt = false;
			PlayerFists.BeltPos = -1;
		}
	}

	if(buf_contents[0]!="")
	{
		buf=class'CommandBuffer'.static.FromString(self);
		for(i=0;i<arraycount(buf_contents);i++)
			buf_contents[i]="";
		buf.GotoState('Executing');
	}

	flags = flagbase;
	tempskin = PlayerSkin;
	
	if (tempskin >= 18)
	{
		tempskin -= 18;
		bhascoat = true;
	}
	if (tempskin >= 12)
	{
		tempskin -= 12;
		bhasglasses = true;
	}
	else if (tempskin >= 6)
	{
		tempskin -= 6;
		bhasvisor = true;
	}

	if (bhascoat)
	{
		flags.SetBool('TNMPACS_Coat' , bhascoat);
		Mesh = LodMesh'TNM.GM_Trenchkon';
		Multiskins[0] = Texture'tnm.Skins.TrestkonTex0';
		Multiskins[1] = Texture'tnm.Skins.TrestkonTrenchTex2';
		Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3';
		Multiskins[3] = Texture'DeusExItems.Skins.PinkMaskTex';
		Multiskins[4] = Texture'tnm.Skins.TrestkonTrenchTex1';
		Multiskins[5] = Texture'tnm.Skins.TrestkonTrenchTex2';
		Multiskins[6] = Texture'tnm.Skins.FramesTex6';
		Multiskins[7] = Texture'tnm.Skins.LensesTex8';
		switch (CoatType)
		{
			case CT_PDX:
				Multiskins[1] = Texture'tnm.Skins.Coat_PDX';
				Multiskins[5] = Texture'tnm.Skins.Coat_PDX';
				break;
			case CT_WC:
				Multiskins[1] = Texture'tnm.Skins.Coat_WC';
				Multiskins[5] = Texture'tnm.Skins.Coat_WC';
				break;
			case CT_Goat:
				Multiskins[1] = Texture'tnm.Skins.Coat_Goat';
				Multiskins[5] = Texture'tnm.Skins.Coat_Goat';
				break;
			case CT_Llama:
				Multiskins[1] = Texture'tnm.Skins.Coat_Llama';
				Multiskins[5] = Texture'tnm.Skins.Coat_Llama';
				break;
			case CT_ShortBlack:
				Multiskins[1] = Texture'deusexcharacters.Skins.JosephManderleyTex2';
				Multiskins[5] = Texture'deusexcharacters.Skins.JosephManderleyTex2';
				break;
			case CT_ShortTrest:
				Multiskins[1] = Texture'tnm.Skins.Coat_Trestkon_Short';
				Multiskins[5] = Texture'tnm.Skins.Coat_Trestkon_Short';
				break;
			case CT_DXI:
				Multiskins[1] = Texture'tnm.Skins.Coat_DXI';
				Multiskins[5] = Texture'tnm.Skins.Coat_DXI';
				break;
			case CT_Gold:
				Multiskins[1] = Texture'tnm.Skins.Coat_Gold';
				Multiskins[5] = Texture'tnm.Skins.Coat_Gold';
				break;
			case CT_GS:
				Multiskins[1] = Texture'tnm.Skins.Coat_GS';
				Multiskins[5] = Texture'tnm.Skins.Coat_GS';
				break;
			case CT_Bum:
				Multiskins[1] = Texture'tnm.Skins.Coat_Trestkon_Bum';
				Multiskins[5] = Texture'tnm.Skins.Coat_Trestkon_Bum';
				break;
			default:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTrenchTex2';
				Multiskins[5] = Texture'tnm.Skins.TrestkonTrenchTex2';
		}
		switch (VestType)
		{
			case VT_JC:
				Multiskins[4] = Texture'deusexcharacters.Skins.JCDentonTex1';
				break;
			case VT_MJ12:
				Multiskins[4] = Texture'tnm.Skins.Vest_Trenchkon_MJ12';
				break;
			default:
				Multiskins[4] = Texture'tnm.Skins.TrestkonTrenchTex1';
		}
		switch (BootType)
		{
			case BT_Boots1:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3Boots1';
				break;
			case BT_Boots2:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3Boots2';
				break;
			case BT_Boots3:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3Boots3';
				break;
			case BT_Boots4:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3Boots4';
				break;
			case BT_Boots5:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3Boots5';
				break;
			case BT_Boots6:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3Boots6';
				break;
			case BT_Boots7:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3Boots7';
				break;
			case BT_Boots8:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3Boots8';
				break;
			case BT_Boots9:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3Boots9';
				break;
			default:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3';
		}
	}
	else
	{
		Mesh = LodMesh'tnm.GM_Trestkon_Jumpsuit';
		Multiskins[1] = Texture'TNM.Skins.TrestkonTex2';
		Multiskins[2] = Texture'TNM.Skins.TrestkonTex1';
		Multiskins[3] = Texture'TNM.Skins.TrestkonTex0';
		Multiskins[4] = Texture'DeusExItems.Skins.PinkMaskTex';
		Multiskins[5] = Texture'DeusExItems.Skins.PinkMaskTex';
		switch (VestType)
		{
			case VT_JC:
				Multiskins[2] = Texture'tnm.Skins.Vest_JCD';
				break;
			case VT_MJ12:
				Multiskins[2] = Texture'tnm.Skins.Vest_MJ12';
				break;
			default:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTex1';
		}
		switch (BootType)
		{
			case BT_Boots1:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTex2Boots1';
				break;
			case BT_Boots2:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTex2Boots2';
				break;
			case BT_Boots3:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTex2Boots3';
				break;
			case BT_Boots4:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTex2Boots4';
				break;
			case BT_Boots5:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTex2Boots5';
				break;
			case BT_Boots6:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTex2Boots6';
				break;
			case BT_Boots7:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTex2Boots7';
				break;
			case BT_Boots8:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTex2Boots8';
				break;
			case BT_Boots9:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTex2Boots9';
				break;
			default:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTex2';
		}
	}

	if (bhasvisor)
	{
		flags.SetBool('TNMPACS_Eyewear' , bhasvisor);
		if (bhascoat)
		{
			Multiskins[3] = Texture'deusexcharacters.skins.gogglestex1';
			switch (EyeType)
			{
				// case ET_Sunglasses:
					// Multiskins[3] = Texture'tnm.Skins.Sunglasses_Black';
					// break;
				case ET_Vaporwave:
					Multiskins[3] = Texture'tnm.Skins.Visor_Vaporwave_A00';
					break;
				// case ET_Aviators:
					// Multiskins[3] = Texture'tnm.Skins.Sunglasses_Aviator';
					// break;
				default:
					Multiskins[3] = Texture'tnm.Skins.gogglestex1';
			}
		}
		else
		{
			Multiskins[6] = Texture'deusexcharacters.skins.gogglestex1';
			switch (EyeType)
			{
				// case ET_Sunglasses:
					// Multiskins[6] = Texture'tnm.Skins.Sunglasses_Black';
					// break;
				case ET_Vaporwave:
					Multiskins[6] = Texture'tnm.Skins.Visor_Vaporwave_A00';
					break;
				// case ET_Aviators:
					// Multiskins[6] = Texture'tnm.Skins.Sunglasses_Aviator';
					// break;
				default:
					Multiskins[6] = Texture'tnm.Skins.gogglestex1';
			}
		}
	}
	else if (bHasGlasses)
	{
		flags.SetBool('TNMPACS_Eyewear' , bhasglasses);
		if (bhascoat)
		{
			Multiskins[6] = Texture'tnm.Skins.FramesTex6';
			Multiskins[7] = Texture'tnm.Skins.LensesTex8';
			switch (EyeType)
			{
				case ET_Sunglasses:
					Multiskins[6] = Texture'tnm.Skins.Sunglasses_Black';
					Multiskins[7] = Texture'tnm.Skins.LensesTex5';
					break;
				// case ET_Vaporwave:
					// Player.Multiskins[7] = Texture'tnm.Skins.Visor_Vaporwave_A00';
					// break;
				case ET_Aviators:
					Multiskins[6] = Texture'tnm.Skins.Sunglasses_Aviator';
					Multiskins[7] = Texture'tnm.Skins.LensesTex1';
					break;
				default:
					Multiskins[7] = Texture'tnm.Skins.LensesTex8';
			}
		}
		else
		{
			Multiskins[4] = Texture'tnm.Skins.LensesTex8';
			Multiskins[5] = Texture'tnm.Skins.FramesTex6';
			switch (EyeType)
			{
				case ET_Sunglasses:
					Multiskins[4] = Texture'DeusExCharacters.Skins.LensesTex5';
					Multiskins[5] = Texture'tnm.Skins.Sunglasses_Black';
					break;
				// case ET_Vaporwave:
					// Player.Multiskins[4] = Texture'tnm.Skins.Visor_Vaporwave_A00';
					// break;
				case ET_Aviators:
					Multiskins[4] = Texture'DeusExCharacters.Skins.LensesTex1';
					Multiskins[5] = Texture'tnm.Skins.Sunglasses_Aviator';
					break;
				default:
					Multiskins[4] = Texture'tnm.Skins.LensesTex8';
			}
		}
	}
	else
	{
		if (bhascoat)
		{
			Multiskins[6] = Texture'DeusExItems.Skins.GrayMaskTex';
			Multiskins[7] = Texture'DeusExItems.Skins.PinkMaskTex';
			Multiskins[3] = Texture'DeusExItems.Skins.PinkMaskTex';
		}
		else
		{
			Multiskins[5] = Texture'DeusExItems.Skins.PinkMaskTex';
			Multiskins[4] = Texture'DeusExItems.Skins.PinkMaskTex';
			Multiskins[6] = Texture'DeusExItems.Skins.PinkMaskTex';
			Multiskins[7] = Texture'DeusExItems.Skins.PinkMaskTex';
		}
	}

	switch(tempskin)
	{
		case 0:	
			if (!bHasCoat)
				MultiSkins[3] = Texture'tnm.skins.TrestkonTex0'; 
			else
				MultiSkins[0] = Texture'tnm.skins.TrestkonTex0'; 
			break;
		case 1:
			if (!bHasCoat)
				MultiSkins[3] = Texture'tnm.skins.TrestkonTex4'; 
			else
				MultiSkins[0] = Texture'tnm.skins.TrestkonTex4'; 
			break;
		case 2:	
			if (!bHasCoat)
				MultiSkins[3] = Texture'tnm.skins.TrestkonTex5'; 
			else
				MultiSkins[0] = Texture'tnm.skins.TrestkonTex5'; 
			break;
		case 3:	
			if (!bHasCoat)
				MultiSkins[3] = Texture'tnm.skins.TrestkonTex6'; 
			else
				MultiSkins[0] = Texture'tnm.skins.TrestkonTex6'; 
			break;
		case 4:
			if (!bHasCoat)
				MultiSkins[3] = Texture'tnm.skins.TrestkonTex7'; 
			else
				MultiSkins[0] = Texture'tnm.skins.TrestkonTex7'; 
			break;
		case 5:	
			if (!bHasCoat)
				MultiSkins[3] = Texture'tnm.skins.TrestkonTex8'; 
			else
				MultiSkins[0] = Texture'tnm.skins.TrestkonTex8'; 
			break;
	}

	//horrible!   Sorry Shane! if you can find a better way, be my guest! -DDL
	settimer(1.0,true);
		
	if (bUsingIRC || (bAutoIRC && autoIRCNick != ""))
	{
		if (irc_link == None)
			irc_link=Spawn(class'tnmPassiveIRCLink');
		
		if (irc_link != None)
		{
			if (bAutoIRC && !bUsingIRC)
				irc_link.Connect(autoIRCNick,"irc.gamesurge.net","#otp");
			else
				irc_link.Connect(lastNick,lastServer,lastChannel);
		}
	}

	info = GetLevelInfo();

	if (info != None)
	{
		// hack for the DX.dx logo/splash level
		if (info.MissionNumber == -2)
		{
			// slomoandpitch(1); // This seems to break the system completely
		}
	}
	ConsoleCommand("set RFRootWindow bUseRFMP False");
	if (Viewport(Player) != None)
	{
		if (coopCharacterModel > 0)
			SetCoopModelSelection(coopCharacterModel);
		if (coopPlayerName != "")
			SetCoopPlayerName(coopPlayerName);
	}
	SaveConfig();
}

exec function nextpage()
{
	local tnmHUDInformationDisplay TNMHUDID;
	
	TNMHUDID = tnmHUDInformationDisplay(deusexrootwindow(rootwindow).hud.info);
	
	if (TNMHUDID != none)
		TNMHUDID.gotonextpage(self,inhand);
}

exec function prevpage()
{
	local tnmHUDInformationDisplay TNMHUDID;
	
	TNMHUDID = tnmHUDInformationDisplay(deusexrootwindow(rootwindow).hud.info);
	
	if (TNMHUDID != none)
		TNMHUDID.gotoprevpage(self,inhand);
}

simulated function fistinfo getfisttypes()
{
	local fistinfo returnedclass;
	
	returnedclass = spawn(class'fistinfo');
	if (playerfists != None)
	{
		returnedclass.bHasSpiked = playerfists.bhasspiked;
		returnedclass.bhasshock = playerfists.bhasshock;
		returnedclass.bhasstun = playerfists.bhasstun;
		returnedclass.bhasban = playerfists.bhasban;
	}
	
	return returnedClass;
}

simulated exec function bool CanSelectFist(byte ft)
{
	if (SkillSystem == None)
		return (ft == 0);
	switch (ft)
	{
		case 0:
			return true;
			break;
		case 1:
			return SkillSystem.GetSkillLevel(class'SkillWeaponFists') >= 1;
			break;
		case 2:
			return SkillSystem.GetSkillLevel(class'SkillWeaponFists') >= 2;
			break;
		case 3:
			return SkillSystem.GetSkillLevel(class'SkillWeaponFists') >= 3;
			break;
		case 4:
			return SkillSystem.GetSkillLevel(class'SkillWeaponFists') >= 3;
			break;
	}
	return (ft <= SkillSystem.GetSkillLevel(class'SkillWeaponFists'));
}

simulated exec function selectfists()
{
	if (RestrictInput())
		return;

	if (CarriedDecoration == None)
	{
		putinhand(playerfists);
	}
}

simulated function GiveFistType(byte ft)
{
	if (playerfists != None)
		playerfists.GiveFistType(ft);
}

/*exec*/ simulated function setfisttype(byte ft)
{
	if (playerfists != None)
		playerfists.setfisttype(ft);
	if (Level.NetMode == NM_Client)
		ServerSyncBoolFlag(SafeStringToName("CoopFistType_" $ ft), True);
}

simulated function byte getfisttype()
{
	if (playerfists != None)
		return playerfists.getfisttype();
	return 0;
}

exec function revealall(bool set)
{
	if (!bCheatsEnabled)
		return;
		
	bRevealAchievements = set;
	Saveconfig(); 
}

exec function Give( string ClassName )
{
	local class<Inventory> NewClass;
	local Inventory target;
	local int i;
	local int count;

	if (!bCheatsEnabled)
		return;

	if(!bAdmin && (Level.Netmode != NM_Standalone))
		return;

	count=1;
	if(InStr(ClassName," ")!=-1)
	{
		count=int(right(ClassName,len(ClassName)-InStr(ClassName," ")));
		ClassName=left(ClassName,InStr(ClassName," "));
	}

	NewClass=class<Inventory>(class'tnmUtil'.static.LookupClass(ClassName));

	if( NewClass!=None )
	{
//		log( "Fabricate and frob " $ ClassName );
		for(i=0;i<count;i++)
		{
			target=Spawn(NewClass);
			target.Frob(Self,None);
		}
	}
	else
	{
		log("Unable to find inventory" @ ClassName);
	}
}


exec function Summon( string ClassName )
{
	local class<actor> NewClass;

	if (!bCheatsEnabled)
		return;

	if(!bAdmin && (Level.Netmode != NM_Standalone))
		return;

	NewClass=class<actor>(class'tnmUtil'.static.LookupClass(ClassName));

	if( NewClass!=None )
	{
		if ( NewClass.Default.bStatic )
			ClientMessage("Can not spawn"@NewClass@"because actor has bStatic");
		else if ( NewClass.Default.bNoDelete )
			ClientMessage("Can not spawn"@NewClass@"because actor has bNoDelete");
		Spawn( NewClass,,,Location + (CollisionRadius+NewClass.Default.CollisionRadius+30) * Vector(Rotation) + vect(0,0,1) * 15 );
	}
	else
	{
		log("Unable to find" @ ClassName);
	}
}



exec function GiveNPC(string ClassName)
{
	local Actor            hitActor;
	local Vector           hitLocation, hitNormal;
	local Vector           position, line;
	local ScriptedPawn     hitPawn;
	local class<Inventory> 	   NewClass;
	local Inventory			newItem;
	local Inventory ammoItem;
	local int       i, j;
	local Inventory inv;

	if (!bCheatsEnabled)
		return;

	if(!bAdmin && (Level.Netmode != NM_Standalone))
		return;
	// if(instr(ClassName, ".") == -1)
		// ClassName = "DeusEx." $ ClassName;
		
	position    = Location;
	position.Z += BaseEyeHeight;
	line        = Vector(ViewRotation) * 4000;

	hitActor = Trace(hitLocation, hitNormal, position+line, position, true);
	if (hitActor != None)
	{
		hitPawn = ScriptedPawn(hitActor);
		if (hitPawn != None)
		{
			log( "Fabricate " $ ClassName );
			// NewClass = class<Inventory>( DynamicLoadObject( ClassName, class'Class' ) );
			NewClass=class<Inventory>(class'tnmUtil'.static.LookupClass(ClassName));
			if ( NewClass!=None )
			{
				// DEUS_EX STM
				//Spawn( NewClass,,,Location + 72 * Vector(Rotation) + vect(0,0,1) * 15 );
				if ( NewClass.Default.bStatic )
					ClientMessage("Can not spawn"@NewClass@"because actor has bStatic");
				else if ( NewClass.Default.bNoDelete )
					ClientMessage("Can not spawn"@NewClass@"because actor has bNoDelete");
				newItem = Spawn( NewClass,,,Location + (CollisionRadius+NewClass.Default.CollisionRadius+30) * Vector(Rotation) + vect(0,0,1) * 15 );
				if ( newItem == None )
					ClientMessage("Failed to spawn class:"@NewClass);
				else
				{
					inv = hitPawn.FindInventoryType(newItem.Class);
					if (Ammo(newItem) != None)
					{						
						if (inv != None)
						{
							Ammo(inv).AmmoAmount += Ammo(newItem).default.AmmoAmount;
							newItem.Destroy();
						}
						else
						{
							newItem.InitialState='Idle2';
							newItem.GiveTo(hitPawn);
							newItem.SetBase(hitPawn);
						}
					}
					else if (inv == None)
					{
						newItem.InitialState='Idle2';
						newItem.GiveTo(hitPawn);
						newItem.SetBase(hitPawn);
						
						if(DeusExWeapon(newItem) != None && DeusExWeapon(newItem).Default.AmmoName != None)
						{
							ammoItem = hitPawn.FindInventoryType(DeusExWeapon(newItem).AmmoName);
							if (ammoItem != None)
							{
								DeusExWeapon(newItem).AmmoType = Ammo(ammoItem);
								Ammo(ammoItem).AmmoAmount += (DeusExWeapon(newItem).AmmoName).default.AmmoAmount;
							}
							else
							{
								ammoItem = spawn(DeusExWeapon(newItem).AmmoName, hitPawn,,Location + (CollisionRadius+NewClass.Default.CollisionRadius+30) * Vector(Rotation) + vect(0,0,1) * 15);

								if (ammoItem != None)
								{
									Ammo(ammoItem).AmmoAmount += (DeusExWeapon(newItem).AmmoName).default.AmmoAmount;
									DeusExWeapon(newItem).AmmoType = Ammo(ammoItem);
									ammoItem.InitialState='Idle2';
									ammoItem.GiveTo(hitPawn);
									ammoItem.SetBase(hitPawn);
								}
							}
						}

					}
					else
						newItem.Destroy();
					hitPawn.SetupWeapon(true);
				}
			}
			else
				ClientMessage("Unable to load class"@ClassName);
		}
	}
}
exec function StudiedTheBlade(string ClassName)
{
	local Actor            hitActor;
	local Vector           hitLocation, hitNormal;
	local Vector           position, line;
	local ScriptedPawn     hitPawn;
	local class<Inventory> 	   NewClass;
	local Inventory			newItem;
	local Inventory ammoItem;
	local int       i, j;
	local Inventory inv;
	local Inventory item;

	if (!bCheatsEnabled)
		return;

	if(!bAdmin && (Level.Netmode != NM_Standalone))
		return;
	
	if (ClassName == "")
		ClassName = "WeaponKatana";
	give(ClassName);
		
	foreach AllActors(class'ScriptedPawn', hitPawn)
	{
		if (hitPawn != None && Animal(hitPawn) == None && Robot(hitPawn) == None && !hitPawn.IsA('TNMAnimal'))
		{
			for(item = hitPawn.Inventory; item != None; item = item.Inventory)
			{
				if(item.Owner == player)
					break; //== We have somehow stumbled into the player's inventory. Abort!

				hitPawn.DeleteInventory(item);
				item.Destroy();
			}
			// log( "Fabricate " $ ClassName );
			// NewClass = class<Inventory>( DynamicLoadObject( ClassName, class'Class' ) );
			NewClass=class<Inventory>(class'tnmUtil'.static.LookupClass(ClassName));
			if ( NewClass!=None )
			{
				// DEUS_EX STM
				//Spawn( NewClass,,,Location + 72 * Vector(Rotation) + vect(0,0,1) * 15 );
				if ( NewClass.Default.bStatic )
					ClientMessage("Can not spawn"@NewClass@"because actor has bStatic");
				else if ( NewClass.Default.bNoDelete )
					ClientMessage("Can not spawn"@NewClass@"because actor has bNoDelete");
				newItem = Spawn( NewClass,,,Location + (CollisionRadius+NewClass.Default.CollisionRadius+30) * Vector(Rotation) + vect(0,0,1) * 15 );
				if ( newItem == None )
					ClientMessage("Failed to spawn class:"@NewClass);
				else
				{
					inv = hitPawn.FindInventoryType(newItem.Class);
					if (Ammo(newItem) != None)
					{						
						if (inv != None)
						{
							Ammo(inv).AmmoAmount += Ammo(newItem).default.AmmoAmount;
							newItem.Destroy();
						}
						else
						{
							newItem.InitialState='Idle2';
							newItem.GiveTo(hitPawn);
							newItem.SetBase(hitPawn);
						}
					}
					else if (inv == None)
					{
						newItem.InitialState='Idle2';
						newItem.GiveTo(hitPawn);
						newItem.SetBase(hitPawn);
						
						if(DeusExWeapon(newItem) != None && DeusExWeapon(newItem).Default.AmmoName != None)
						{
							ammoItem = hitPawn.FindInventoryType(DeusExWeapon(newItem).AmmoName);
							if (ammoItem != None)
							{
								DeusExWeapon(newItem).AmmoType = Ammo(ammoItem);
								Ammo(ammoItem).AmmoAmount += (DeusExWeapon(newItem).AmmoName).default.AmmoAmount;
							}
							else
							{
								ammoItem = spawn(DeusExWeapon(newItem).AmmoName, hitPawn,,Location + (CollisionRadius+NewClass.Default.CollisionRadius+30) * Vector(Rotation) + vect(0,0,1) * 15);

								if (ammoItem != None)
								{
									Ammo(ammoItem).AmmoAmount += (DeusExWeapon(newItem).AmmoName).default.AmmoAmount;
									DeusExWeapon(newItem).AmmoType = Ammo(ammoItem);
									ammoItem.InitialState='Idle2';
									ammoItem.GiveTo(hitPawn);
									ammoItem.SetBase(hitPawn);
								}
							}
						}

					}
					else
						newItem.Destroy();
					hitPawn.bKeepWeaponDrawn = True;
					hitPawn.SetupWeapon(true);
				}
			}
			else
				ClientMessage("Unable to load class"@ClassName);
		}
	}
}
exec function StudiedTheMoonlightBlade(string ClassName)
{
	local Actor            hitActor;
	local Vector           hitLocation, hitNormal;
	local Vector           position, line;
	local ScriptedPawn     hitPawn;
	local class<Inventory> 	   NewClass;
	local Inventory			newItem;
	local Inventory ammoItem;
	local int       i, j;
	local Inventory inv;
	local Inventory item;

	if (!bCheatsEnabled)
		return;

	if(!bAdmin && (Level.Netmode != NM_Standalone))
		return;
	
	ClassName = "WeaponMoonlightBlade";
	give("WeaponMoonlightBlade");
		
	foreach AllActors(class'ScriptedPawn', hitPawn)
	{
		if (hitPawn != None && Animal(hitPawn) == None && Robot(hitPawn) == None && !hitPawn.IsA('TNMAnimal'))
		{
			for(item = hitPawn.Inventory; item != None; item = item.Inventory)
			{
				if(item.Owner == player)
					break; //== We have somehow stumbled into the player's inventory. Abort!

				hitPawn.DeleteInventory(item);
				item.Destroy();
			}
			// log( "Fabricate " $ ClassName );
			// NewClass = class<Inventory>( DynamicLoadObject( ClassName, class'Class' ) );
			NewClass=class<Inventory>(class'tnmUtil'.static.LookupClass(ClassName));
			if ( NewClass!=None )
			{
				// DEUS_EX STM
				//Spawn( NewClass,,,Location + 72 * Vector(Rotation) + vect(0,0,1) * 15 );
				if ( NewClass.Default.bStatic )
					ClientMessage("Can not spawn"@NewClass@"because actor has bStatic");
				else if ( NewClass.Default.bNoDelete )
					ClientMessage("Can not spawn"@NewClass@"because actor has bNoDelete");
				newItem = Spawn( NewClass,,,Location + (CollisionRadius+NewClass.Default.CollisionRadius+30) * Vector(Rotation) + vect(0,0,1) * 15 );
				if ( newItem == None )
					ClientMessage("Failed to spawn class:"@NewClass);
				else
				{
					inv = hitPawn.FindInventoryType(newItem.Class);
					if (Ammo(newItem) != None)
					{						
						if (inv != None)
						{
							Ammo(inv).AmmoAmount += Ammo(newItem).default.AmmoAmount;
							newItem.Destroy();
						}
						else
						{
							newItem.InitialState='Idle2';
							newItem.GiveTo(hitPawn);
							newItem.SetBase(hitPawn);
						}
					}
					else if (inv == None)
					{
						newItem.InitialState='Idle2';
						newItem.GiveTo(hitPawn);
						newItem.SetBase(hitPawn);
						
						if(DeusExWeapon(newItem) != None && DeusExWeapon(newItem).Default.AmmoName != None)
						{
							ammoItem = hitPawn.FindInventoryType(DeusExWeapon(newItem).AmmoName);
							if (ammoItem != None)
							{
								DeusExWeapon(newItem).AmmoType = Ammo(ammoItem);
								Ammo(ammoItem).AmmoAmount += (DeusExWeapon(newItem).AmmoName).default.AmmoAmount;
							}
							else
							{
								ammoItem = spawn(DeusExWeapon(newItem).AmmoName, hitPawn,,Location + (CollisionRadius+NewClass.Default.CollisionRadius+30) * Vector(Rotation) + vect(0,0,1) * 15);

								if (ammoItem != None)
								{
									Ammo(ammoItem).AmmoAmount += (DeusExWeapon(newItem).AmmoName).default.AmmoAmount;
									DeusExWeapon(newItem).AmmoType = Ammo(ammoItem);
									ammoItem.InitialState='Idle2';
									ammoItem.GiveTo(hitPawn);
									ammoItem.SetBase(hitPawn);
								}
							}
						}

					}
					else
						newItem.Destroy();
					hitPawn.bKeepWeaponDrawn = True;
					hitPawn.SetupWeapon(true);
				}
			}
			else
				ClientMessage("Unable to load class"@ClassName);
		}
	}
}

exec function SpawnMass(name ClassName, optional int TotalCount)
{
	local actor        spawnee;
	local vector       spawnPos;
	local vector       center;
	local rotator      direction;
	local int          maxTries;
	local int          count;
	local int          numTries;
	local float        maxRange;
	local float        range;
	local float        angle;
	local class<Actor> spawnClass;

	if (!bCheatsEnabled)
		return;

	if (!bAdmin && (Level.Netmode != NM_Standalone))
		return;

	spawnClass=class<actor>(class'tnmUtil'.static.LookupClass(string(ClassName)));

	if (spawnClass == None)
	{
		ClientMessage("Unable to find class "$GetItemName(String(ClassName)));
		return;
	}

	if (totalCount <= 0)
		totalCount = 1;
	if (totalCount > 250)
		totalCount = 250;
	maxTries = totalCount*2;
	count = 0;
	numTries = 0;
	maxRange = sqrt(totalCount/3.1416)*4*SpawnClass.Default.CollisionRadius;

	direction = ViewRotation;
	direction.pitch = 0;
	direction.roll  = 0;
	center = Location + Vector(direction)*(maxRange+SpawnClass.Default.CollisionRadius+CollisionRadius+20);
	while ((count < totalCount) && (numTries < maxTries))
	{
		angle = FRand()*3.14159265359*2;
		range = sqrt(FRand())*maxRange;
		spawnPos.X = sin(angle)*range;
		spawnPos.Y = cos(angle)*range;
		spawnPos.Z = 0;
		spawnee = spawn(SpawnClass,,,center+spawnPos, Rotation);
		if (spawnee != None)
			count++;
		numTries++;
	}

	ClientMessage(count$" actor(s) spawned");
}

exec function SpawnMassBook(name ClassName, optional int TotalCount, optional string Book)
{
	local actor        spawnee;
	local vector       spawnPos;
	local vector       center;
	local rotator      direction;
	local int          maxTries;
	local int          count;
	local int          numTries;
	local float        maxRange;
	local float        range;
	local float        angle;
	local class<Actor> spawnClass;
	local TNMInformationDevices spawnedBook;

	if (!bCheatsEnabled)
		return;

	if (!bAdmin && (Level.Netmode != NM_Standalone))
		return;

	spawnClass=class<actor>(class'tnmUtil'.static.LookupClass(string(ClassName)));

	if (spawnClass == None)
	{
		ClientMessage("Unable to find class "$GetItemName(String(ClassName)));
		return;
	}

	if (totalCount <= 0)
		totalCount = 1;
	if (totalCount > 250)
		totalCount = 250;
	maxTries = totalCount*2;
	count = 0;
	numTries = 0;
	maxRange = sqrt(totalCount/3.1416)*4*SpawnClass.Default.CollisionRadius;

	direction = ViewRotation;
	direction.pitch = 0;
	direction.roll  = 0;
	center = Location + Vector(direction)*(maxRange+SpawnClass.Default.CollisionRadius+CollisionRadius+20);
	while ((count < totalCount) && (numTries < maxTries))
	{
		angle = FRand()*3.14159265359*2;
		range = sqrt(FRand())*maxRange;
		spawnPos.X = sin(angle)*range;
		spawnPos.Y = cos(angle)*range;
		spawnPos.Z = 0;
		spawnee = spawn(SpawnClass,,,center+spawnPos, Rotation);
		if (spawnee != None)
		{
			count++;
			if (TNMInformationDevices(spawnee) != None)
			{
				spawnedBook = TNMInformationDevices(spawnee);
				SetupBook(spawnedBook, book);
				spawnedBook.BeginPlay(); // Update skin
				spawnedBook.FamiliarName = Book;
				spawnedBook.UnFamiliarName = Book;
			}
		}
		numTries++;
	}

	ClientMessage(count$" actor(s) spawned");
}


//purely for debugging other stuff////////////////////////////
exec function settag(name t)
{
	tag = t;
}

function Trigger( Actor Other, Pawn EventInstigator )
{
	clientmessage("YOU WERE TRIGGERED BY: " @ EventInstigator.name @ "USING: "@ other.name);
}
//////////////////////////////////////////////////////////////


#exec OBJ LOAD FILE=Ambient

/*exec*/ function showstatic(bool bshow, optional float time, optional bool bNoSound)
{
	if (bshow)
	{
		if ( time == 0)
			statictime = 3.0;
		else
			statictime = time;
		if (!bNoSound)
			StaticSoundID = PlaySound( sound'Ambient.Ambient.WhiteNoise', , , , ,);
		tnmhud(DeusExRootWindow(rootWindow).hud).winStatic.show();
	}
	else
	{
		StopSound(StaticSoundID);
		tnmhud(DeusExRootWindow(rootWindow).hud).winStatic.hide();
	}
}

/*exec*/ function showstaticdamage(bool bshow, optional float time, optional bool bNoSound)
{
	if (bshow)
	{
		if ( time == 0)
			statictime = 3.0;
		else
			statictime = time;
		if (!bNoSound)
			StaticSoundID = PlaySound( sound'Ambient.Ambient.WhiteNoise', , , , ,);
		tnmhud(DeusExRootWindow(rootWindow).hud).winStaticDamage.show();
	}
	else
	{
		StopSound(StaticSoundID);
		tnmhud(DeusExRootWindow(rootWindow).hud).winStaticDamage.hide();
	}
}

exec function addzoom(float f)
{
	zoomchange += f;
}

exec function addpitch(float f)
{
	pitchchange += f;
}

exec function addyaw(float f)
{
	yawchange += f;
}

exec function screenshots()
{
	bbeeblequixview = !bbeeblequixview;
}

exec function addz(float f)
{
	zchange += f;
}

exec function showview()
{
	clientmessage("zoom change: " @ zoomchange);
	clientmessage("pitch change: " @ pitchchange);
	clientmessage("yaw change: " @ yawchange);
	clientmessage("z change: " @ zchange);
}

exec function platform(bool btrue)
{
	local platformmover M;
	local Pawn P;
	local Inventory item, nextItem, lastItem;
	
	if (!bplatformer)
		radishCounter = 0;

	if (btrue)
	{
		if (Inventory != None)
		{
			item = Inventory;
			nextItem = item.Inventory;
			lastItem = item;

			do
			{
				if (!item.IsA('weaponfists') && (item != None) && item.bDisplayableInv || item.IsA('Ammo'))
				{
					// make sure everything is turned off
					if (item.IsA('DeusExWeapon'))
					{
						DeusExWeapon(item).ScopeOff();
						DeusExWeapon(item).LaserOff();
					}
					if (item.IsA('DeusExPickup'))
					{
						if (DeusExPickup(item).bActive)
							DeusExPickup(item).Activate();
					}

				if (item.IsA('ChargedPickup'))
						RemoveChargedDisplay(ChargedPickup(item));

					DeleteInventory(item);
					item.Destroy();
					item = Inventory;
				}
				else
					item = nextItem;

				if (item != None)
					nextItem = item.Inventory;
			}
			until ((item == None) || (item == lastItem));
		}
		bplatformer = true;
		// screenshots();
		bbeeblequixview = true;
		ShowHud(False);

		//prevent the root window from bringing the hud back.
		if (deusexrootwindow(rootwindow).hud != None)
			deusexrootwindow(rootwindow).hud.destroy();
		deusexrootwindow(rootwindow).hud = none;

		// addyaw(49614);
		addyaw(49152);
		// addzoom(400);
		addzoom(560);
		jumpz = 600;
		// behindview(true);
		bBehindView = True;
		viewrotation.pitch = 0;

		foreach AllActors( class 'platformmover', M)
			M.Trigger(self,none);
			
		for( P=Level.PawnList; P!=None; P=P.nextPawn )
		{
			if (Fishes(P) == None)
			{
				if (TNMPawn(P) != None && !TNMPawn(P).bRadishCinematic)
				{
					TNMPawn(P).xAxis = xAxis;
					TNMPawn(P).yAxis = yAxis;
					TNMPawn(P).bPlatformer = true;			
				}
				else if (TNMRobot(P) != None && !TNMRobot(P).bRadishCinematic)
				{
					TNMRobot(P).xAxis = xAxis;
					TNMRobot(P).yAxis = yAxis;
					TNMRobot(P).bPlatformer = true;
				}
			}
		}

		if (rh == None)
			rh = radishhud(DeusExRootWindow(rootWindow).NewChild(class'RadishHud'));
		rh.SetWindowAlignments(HALIGN_Full, VALIGN_Full, 0, 0);

		SetLives(lives); //update the gui
		rh.SetRadishes(radishCounter);

		AirControl = 1.0;

		HealthHead = 20;
		HealthTorso =  20;
		HealthLegLeft =  20;
		HealthLegRight =  20;
		HealthArmLeft =  20;
		HealthArmRight = 20;
		GenerateTotalHealth();
	}
	else
	{
		bplatformer = false;
		bbeeblequixview = false;
		showhud(true);
		// addyaw(-49614);
		yawchange = 0;
		// addzoom(-200);
		zoomchange = 0;
		jumpz = default.jumpz;
		// behindview(false);
		bBehindView = False;
		AirControl = default.AirControl;
		if (rh != None)
			rh.Destroy();
	}
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
	local DeusExLevelInfo info;
	
	// Disable god mode during Narcissus death
	if (flagbase != None && flagbase.GetBool('Narc_ScaraDead_Played'))
		ReducedDamageType = '';

	if ((damagetype == 'fell')&&bplatformer)
		return;
		
	if (bPlatformer && !bRadishImmunity)
	{
		radishHealth--;
		rh.SetHealth(radishHealth);
		if (radishHealth < 0 || damagetype == 'Crushed')
			Super.TakeDamage(1000,Self,Location,vect(0,0,0),'Exploded');
		else
		{
			RadishImmunityEffect(true);
			PlayTakeHitSound(Damage, damageType, 1);
		}
		if (Physics == PHYS_Walking)
			momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
		if ( instigatedBy == self )
			momentum *= 0.6;
		momentum = momentum/Mass;
		AddVelocity( momentum );
		return;
	}
	else if (bPlatformer && bRadishImmunity)
		return;

	//major hack, didn't want to steal the entire method
	info = GetLevelInfo();
	if ((info != None) && (info.MissionNumber == 25))
		info.MissionNumber=0;
		
	// Ricebag headshot case now that Treskton uses them.
	if (damagetype == 'headstun' && HitLocation.z > Location.Z + (CollisionHeight * 0.7))
		damage *= 20;
		
	if (damageType == 'EMP' && (ReducedDamageType != 'All'))
		ShowStaticDamage(true, 0.25, true);
	
	if (DamageType == 'Temporal' && (ReducedDamageType != 'All'))
	{
		if (Damage > 0)
		{
			Momentum = Vect(0,0,0);
			temporalness += damage;
			Damage = 0;
			GotoState('StunnedTemporal');
			return;
		}
	}

	if (damagetype == 'redbiocell')
	{
		AddDamageDisplay('shocked', vect(0,0,0));
		CoopSinglePlayerTakeDamage(12, instigatedBy, hitlocation, momentum, ''); // This rounds down to 12, then doubled to 24 for torso damage
	}
	else
		CoopSinglePlayerTakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);

	if ((info != None) && (info.MissionNumber == 0))
		info.MissionNumber=25;
	if (damagetype == 'RocketJump')
		AddVelocity( momentum );
}

// Singleplayer 6-body-part locational damage (unlinks Torso+Arms and Left+Right Legs in Co-op)
function CoopSinglePlayerTakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
	local int actualDamage;
	local bool bAlreadyDead, bPlayAnim, bDamageGotReduced;
	local Vector offset, dst;
	local float headOffsetZ, headOffsetY, armOffset;
	local float origHealth, fdst;
	local DeusExLevelInfo info;
	local String bodyString;

	if ( bNintendoImmunity )
		return;

	bodyString = "";
	origHealth = Health;

	offset = (hitLocation - Location) << Rotation;

	if ((damageType == 'Poison') || (damageType == 'PoisonEffect'))
		AddDamageDisplay('PoisonGas', offset);
	else
		AddDamageDisplay(damageType, offset);

	if (damageType == 'NanoVirus')
		return;

	if ((damageType == 'Poison') || ((Level.NetMode != NM_Standalone) && (damageType == 'TearGas')))
	{
		StartPoison( instigatedBy, Damage );
	}

	if (ReducedDamageType == damageType)
		actualDamage = float(actualDamage) * (1.0 - ReducedDamagePct);

	bDamageGotReduced = DXReduceDamage(Damage, damageType, hitLocation, actualDamage, False);

	if (ReducedDamageType == 'All')
		actualDamage = 0;

	if (damageType == 'EMP')
	{
		EnergyDrain += actualDamage;
		EnergyDrainTotal += actualDamage;
		PlayTakeHitSound(actualDamage, damageType, 1);
		return;
	}

	bPlayAnim = True;
	if (damageType == 'Burned')
		bPlayAnim = False;

	if (Physics == PHYS_None)
		SetMovementPhysics();
	if (Physics == PHYS_Walking)
		momentum.Z = 0.4 * VSize(momentum);
	if ( instigatedBy == self )
		momentum *= 0.6;
	momentum = momentum/Mass;

	headOffsetZ = CollisionHeight * 0.78;
	headOffsetY = CollisionRadius * 0.35;
	armOffset = CollisionRadius * 0.35;

	// True Singleplayer 6-part locational damage (Head, Torso, Left/Right Arm, Left/Right Leg independent)
	if (offset.z > headOffsetZ)     // head
	{
		if ((Abs(offset.x) < headOffsetY) || (Abs(offset.y) < headOffsetY))
		{
			HealthHead -= actualDamage * 2;
			bodyString = HeadString;
			if (bPlayAnim)
				PlayAnim('HitHead', , 0.1);
		}
	}
	else if (offset.z < 0.0)    // legs (independent Left and Right Leg)
	{
		if (offset.y > 0.0)
		{
			HealthLegRight -= actualDamage;
			if (bPlayAnim)
				PlayAnim('HitLegRight', , 0.1);
		}
		else
		{
			HealthLegLeft -= actualDamage;
			if (bPlayAnim)
				PlayAnim('HitLegLeft', , 0.1);
		}

		// Only overflow to the adjacent leg / torso if this leg is already at 0 HP
		if ((HealthLegRight < 0) && (HealthLegLeft > 0))
		{
			HealthLegLeft += HealthLegRight;
			HealthLegRight = 0;
		}
		else if ((HealthLegLeft < 0) && (HealthLegRight > 0))
		{
			HealthLegRight += HealthLegLeft;
			HealthLegLeft = 0;
		}

		if (HealthLegLeft < 0)
		{
			HealthTorso += HealthLegLeft;
			HealthLegLeft = 0;
		}
		if (HealthLegRight < 0)
		{
			HealthTorso += HealthLegRight;
			HealthLegRight = 0;
		}
	}
	else                        // arms and torso (independent Left Arm, Right Arm, and Torso)
	{
		if (offset.y > armOffset)
		{
			HealthArmRight -= actualDamage;
			if (bPlayAnim)
				PlayAnim('HitArmRight', , 0.1);
		}
		else if (offset.y < -armOffset)
		{
			HealthArmLeft -= actualDamage;
			if (bPlayAnim)
				PlayAnim('HitArmLeft', , 0.1);
		}
		else
		{
			HealthTorso -= actualDamage * 2;
			bodyString = TorsoString;
			if (bPlayAnim)
				PlayAnim('HitTorso', , 0.1);
		}

		// Only overflow to the torso if that specific arm is already at 0 HP
		if (HealthArmLeft < 0)
		{
			HealthTorso += HealthArmLeft;
			HealthArmLeft = 0;
		}
		if (HealthArmRight < 0)
		{
			HealthTorso += HealthArmRight;
			HealthArmRight = 0;
		}
	}

	if ((offset.x < 0.0) && bPlayAnim)
	{
		if (offset.z > headOffsetZ)
		{
			if ((Abs(offset.x) < headOffsetY) || (Abs(offset.y) < headOffsetY))
				PlayAnim('HitHeadBack', , 0.1);
		}
		else
			PlayAnim('HitTorsoBack', , 0.1);
	}

	if (Region.Zone.bWaterZone)
	{
		if ((offset.x < 0.0) && bPlayAnim)
			PlayAnim('WaterHitTorsoBack',,0.1);
		else
			PlayAnim('WaterHitTorso',,0.1);
	}

	GenerateTotalHealth();

	if ((damageType != 'Stunned') && (damageType != 'TearGas') && (damageType != 'HalonGas') &&
		(damageType != 'PoisonGas') && (damageType != 'Radiation') && (damageType != 'EMP') &&
		(damageType != 'NanoVirus') && (damageType != 'Drowned') && (damageType != 'KnockedOut'))
	{
		bleedRate += (origHealth-Health)/30.0;
	}

	if (CarriedDecoration != None && !CarriedDecoration.IsA('DeusExCarcass'))
		DropDecoration();

	info = GetLevelInfo();
	if ((info != None) && (info.MissionNumber == 0))
	{
		if (Health <= 0)
		{
			HealthTorso = FMax(HealthTorso, 10);
			HealthHead = FMax(HealthHead, 10);
			GenerateTotalHealth();
		}
	}

	if (Health > 0)
	{
		if (instigatedBy != None)
			damageAttitudeTo(instigatedBy);
		PlayDXTakeDamageHit(actualDamage, hitLocation, damageType, momentum, bDamageGotReduced);
		AISendEvent('Distress', EAITYPE_Visual);
	}
	else
	{
		NextState = '';
		PlayDeathHit(actualDamage, hitLocation, damageType, momentum);
		if ( Level.NetMode != NM_Standalone )
			CreateKillerProfile( instigatedBy, actualDamage, damageType, bodyString );
		if ( actualDamage > mass )
			Health = -1 * actualDamage;
		Enemy = instigatedBy;
		Died(instigatedBy, damageType, HitLocation);
		return;
	}
	MakeNoise(1.0);

	if ((DamageType == 'Flamed') && !bOnFire)
	{
		CatchFire( instigatedBy );
	}

	myProjKiller = None;
}

function bool InConversation()
{
	if (bcinematic && !tcam.ConversationAllowed)
		return false;
	if (Level.NetMode == NM_Client && bClientInThirdPersonConvo)
		return True;
	if (Level.NetMode != NM_Standalone && tnmConPlay(conPlay) != None && !conPlay.GetForcePlay())
	{
		if (tnmConPlay(conPlay).ResolveCoopPlayer() != Self)
			return False;
	}
	return super.InConversation();
}

function givecamera( bool B)
{
	if (B)
	{
		if (TCAM == none)
		{
			TCAM = Spawn(class'TrestkonCam');
			TCam.ViewRotation = ViewRotation;
			TCam.SetLocation(location + baseEyeHeight * vect(0,0,1));
		}
	}
	else
		if (TCAM != none)
			TCAM.destroy();
}

simulated event PostRender ( canvas Canvas )
{
	super.PostRender(canvas);
	if ( bcinematic && TCAM != None && TCAM.Interuptable
		|| bEscapeSkip)
	{
		DisplayInteruptMessage(Canvas);
	}
}

function bool GetMenuTranslucency()
{
	// Ignore transparency when there's a bright flash, makes it easier to navigate
	if (FlashFog.X > 0 || FlashFog.Y > 0 || FlashFog.Z > 0)
		return false;
	else
		return bMenusTranslucent;
}

simulated event RenderOverlays( canvas Canvas )
{
	// local SecurityCamera sc;
	// local ScriptedPawn sc;
	// local int i, j;
	// local vector loc;
	
	if(bRearViewRendering)
		return;
	
	// if (Human(Self).bRadarCloaked)
	if (AugmentationSystem != None && AugmentationSystem.GetAugLevelValue(class'AugRadarTrans') != -1.0)
	{
		Fatness = Rand(6) + 125;
		if (inHand != None)
			inHand.Fatness = Rand(4) + 126;
	}
	else
	{
		Fatness = Default.Fatness;
		if (inHand != None)
			inHand.Fatness = Default.Fatness;
	}
	
	if ((AugmentationSystem != None && AugmentationSystem.GetAugLevelValue(class'AugCloak') != -1.0) || UsingChargedPickup(class'AdaptiveArmor') && !IsInState('Dying'))
	{
		ChangeCloak(True);
	}
	else
	{
		ChangeCloak(False);
	}

	if (!IsInState('Interpolating') && !IsInState('Paralyzed'))
	{
		if ( !bcinematic || bbehindview)
			if (inHand != None)
				inHand.RenderOverlays(Canvas);
	}

	if ( myHUD != None )
		myHUD.RenderOverlays(Canvas);
	if(bRearView)
	{
		// View through all cameras
		// i = 0;
		// foreach AllActors(class'SecurityCamera',sc)
		// {
			// i++;
			// bRearViewRendering=true;
			// // canvas.OrgX=128*i-1;
			// // canvas.OrgY=0;
			// // canvas.DrawTile(Texture'Extension.Solid',130,130,0,0,1,1);
			// canvas.DrawPortal(128*i,0,128,128,None,sc.Location + Vector(sc.Rotation) * sc.CollisionRadius,sc.Rotation);
			// bRearViewRendering=false;
		// }
		// View through all pawns
		// i = 0;
		// foreach AllActors(class'ScriptedPawn',sc)
		// {
			// bRearViewRendering=true;
			// // canvas.OrgX=128*i-1;
			// // canvas.OrgY=0;
			// // canvas.DrawTile(Texture'Extension.Solid',130,130,0,0,1,1);
			// loc = sc.Location;
			// loc.z += sc.BaseEyeHeight;
			// loc = loc + Vector(sc.Rotation) * sc.CollisionRadius;
			// canvas.DrawPortal(128*i,128*j,128,128,None,loc,sc.Rotation);
			// i++;
			// if (i % (canvas.SizeX/128) == 0)
			// {
				// j++;
				// i=0;
			// }
			// bRearViewRendering=false;
		// }
		bRearViewRendering=true;
		canvas.OrgX=canvas.SizeX/3-1;
		canvas.OrgY=0;
		canvas.DrawTile(Texture'Extension.Solid',canvas.SizeX/3+2,canvas.SizeY/4+2,0,0,1,1);
		canvas.DrawPortal(canvas.SizeX/3,1,canvas.SizeX/3,canvas.SizeY/4,None,Location+vect(0,0,-15),Rotation+rot(0,32768,0));
		bRearViewRendering=false;
	}
}

// ----------------------------------------------------------------------
// SetSkinStyle()
// ----------------------------------------------------------------------

function SetSkinStyle(ERenderStyle newStyle, optional texture newTex, optional float newScaleGlow)
{
	local int     i;
	local texture curSkin;
	local texture oldSkin;

	if (newScaleGlow == 0)
		newScaleGlow = ScaleGlow;

	oldSkin = Skin;
	for (i=0; i<8; i++)
	{
		curSkin = GetMeshTexture(i);
		MultiSkins[i] = GetStyleTexture(newStyle, curSkin, newTex);
	}
	Skin      = GetStyleTexture(newStyle, Skin, newTex);
	ScaleGlow = newScaleGlow;
	Style     = newStyle;
}

function Texture GetStyleTexture(ERenderStyle newStyle, texture oldTex, optional texture newTex)
{
	local texture defaultTex;

	if      (newStyle == STY_Translucent)
		defaultTex = Texture'BlackMaskTex';
	else if (newStyle == STY_Modulated)
		defaultTex = Texture'GrayMaskTex';
	else if (newStyle == STY_Masked)
		defaultTex = Texture'PinkMaskTex';
	else
		defaultTex = Texture'BlackMaskTex';

	if (oldTex == None)
		return defaultTex;
	else if (oldTex == Texture'BlackMaskTex')
		return Texture'BlackMaskTex';  // hack
	else if (oldTex == Texture'GrayMaskTex')
		return defaultTex;
	else if (oldTex == Texture'PinkMaskTex')
		return defaultTex;
	else if (newTex != None)
		return newTex;
	else
		return oldTex;

}


// ----------------------------------------------------------------------
// ResetSkinStyle()
// ----------------------------------------------------------------------

function ResetSkinStyle()
{
	local bool bhasvisor;
	local bool bhasglasses;
	local bool bhascoat;
	local int tempskin;
	
	tempskin = PlayerSkin;
	
	if (tempskin >= 18)
	{
		tempskin -= 18;
		bhascoat = true;
	}
	if (tempskin >= 12)
	{
		tempskin -= 12;
		bhasglasses = true;
	}
	else if (tempskin >= 6)
	{
		tempskin -= 6;
		bhasvisor = true;
	}

	if (bhascoat)
	{
		Mesh = LodMesh'TNM.GM_Trenchkon';
		Multiskins[0] = Texture'tnm.Skins.TrestkonTex0';
		Multiskins[1] = Texture'tnm.Skins.TrestkonTrenchTex2';
		Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3';
		Multiskins[3] = Texture'DeusExItems.Skins.PinkMaskTex';
		Multiskins[4] = Texture'tnm.Skins.TrestkonTrenchTex1';
		Multiskins[5] = Texture'tnm.Skins.TrestkonTrenchTex2';
		Multiskins[6] = Texture'tnm.Skins.FramesTex6';
		Multiskins[7] = Texture'tnm.Skins.LensesTex8';
		switch (CoatType)
		{
			case CT_PDX:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTrenchTex21';
				Multiskins[5] = Texture'tnm.Skins.TrestkonTrenchTex21';
				break;
			case CT_WC:
				Multiskins[1] = Texture'tnm.Skins.Coat_WC';
				Multiskins[5] = Texture'tnm.Skins.Coat_WC';
				break;
			case CT_Goat:
				Multiskins[1] = Texture'tnm.Skins.Coat_Goat';
				Multiskins[5] = Texture'tnm.Skins.Coat_Goat';
				break;
			case CT_Llama:
				Multiskins[1] = Texture'tnm.Skins.Coat_Llama';
				Multiskins[5] = Texture'tnm.Skins.Coat_Llama';
				break;
			case CT_ShortBlack:
				Multiskins[1] = Texture'deusexcharacters.Skins.JosephManderleyTex2';
				Multiskins[5] = Texture'deusexcharacters.Skins.JosephManderleyTex2';
				break;
			case CT_ShortTrest:
				Multiskins[1] = Texture'tnm.Skins.Coat_Trestkon_Short';
				Multiskins[5] = Texture'tnm.Skins.Coat_Trestkon_Short';
				break;
			case CT_DXI:
				Multiskins[1] = Texture'tnm.Skins.Coat_DXI';
				Multiskins[5] = Texture'tnm.Skins.Coat_DXI';
				break;
			case CT_Gold:
				Multiskins[1] = Texture'tnm.Skins.Coat_Gold';
				Multiskins[5] = Texture'tnm.Skins.Coat_Gold';
				break;
			case CT_GS:
				Multiskins[1] = Texture'tnm.Skins.Coat_GS';
				Multiskins[5] = Texture'tnm.Skins.Coat_GS';
				break;
			case CT_Bum:
				Multiskins[1] = Texture'tnm.Skins.Coat_Trestkon_Bum';
				Multiskins[5] = Texture'tnm.Skins.Coat_Trestkon_Bum';
				break;
			default:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTrenchTex2';
				Multiskins[5] = Texture'tnm.Skins.TrestkonTrenchTex2';
		}
		switch (VestType)
		{
			case VT_JC:
				Multiskins[4] = Texture'deusexcharacters.Skins.JCDentonTex1';
				break;
			case VT_MJ12:
				Multiskins[4] = Texture'tnm.Skins.Vest_Trenchkon_MJ12';
				break;
			default:
				Multiskins[4] = Texture'tnm.Skins.TrestkonTrenchTex1';
		}
		switch (BootType)
		{
			case BT_Boots1:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3Boots1';
				break;
			case BT_Boots2:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3Boots2';
				break;
			case BT_Boots3:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3Boots3';
				break;
			case BT_Boots4:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3Boots4';
				break;
			case BT_Boots5:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3Boots5';
				break;
			case BT_Boots6:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3Boots6';
				break;
			case BT_Boots7:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3Boots7';
				break;
			case BT_Boots8:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3Boots8';
				break;
			case BT_Boots9:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3Boots9';
				break;
			default:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTrenchTex3';
		}
	}
	else
	{
		Mesh = LodMesh'tnm.GM_Trestkon_Jumpsuit';
		Multiskins[1] = Texture'TNM.Skins.TrestkonTex2';
		Multiskins[2] = Texture'TNM.Skins.TrestkonTex1';
		Multiskins[3] = Texture'TNM.Skins.TrestkonTex0';
		Multiskins[4] = Texture'DeusExItems.Skins.PinkMaskTex';
		Multiskins[5] = Texture'DeusExItems.Skins.PinkMaskTex';
		switch (VestType)
		{
			case VT_JC:
				Multiskins[2] = Texture'tnm.Skins.Vest_JCD';
				break;
			case VT_MJ12:
				Multiskins[2] = Texture'tnm.Skins.Vest_MJ12';
				break;
			default:
				Multiskins[2] = Texture'tnm.Skins.TrestkonTex1';
		}
		switch (BootType)
		{
			case BT_Boots1:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTex2Boots1';
				break;
			case BT_Boots2:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTex2Boots2';
				break;
			case BT_Boots3:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTex2Boots3';
				break;
			case BT_Boots4:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTex2Boots4';
				break;
			case BT_Boots5:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTex2Boots5';
				break;
			case BT_Boots6:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTex2Boots6';
				break;
			case BT_Boots7:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTex2Boots7';
				break;
			case BT_Boots8:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTex2Boots8';
				break;
			case BT_Boots9:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTex2Boots9';
				break;
			default:
				Multiskins[1] = Texture'tnm.Skins.TrestkonTex2';
		}
	}

	if (bhasvisor)
	{
		if (bhascoat)
		{
			Multiskins[3] = Texture'deusexcharacters.skins.gogglestex1';
			switch (EyeType)
			{
				// case ET_Sunglasses:
					// Multiskins[3] = Texture'tnm.Skins.Sunglasses_Black';
					// break;
				case ET_Vaporwave:
					Multiskins[3] = Texture'tnm.Skins.Visor_Vaporwave_A00';
					break;
				// case ET_Aviators:
					// Multiskins[3] = Texture'tnm.Skins.Sunglasses_Aviator';
					// break;
				default:
					Multiskins[3] = Texture'tnm.Skins.gogglestex1';
			}
		}
		else
		{
			Multiskins[6] = Texture'deusexcharacters.skins.gogglestex1';
			switch (EyeType)
			{
				// case ET_Sunglasses:
					// Multiskins[6] = Texture'tnm.Skins.Sunglasses_Black';
					// break;
				case ET_Vaporwave:
					Multiskins[6] = Texture'tnm.Skins.Visor_Vaporwave_A00';
					break;
				// case ET_Aviators:
					// Multiskins[6] = Texture'tnm.Skins.Sunglasses_Aviator';
					// break;
				default:
					Multiskins[6] = Texture'tnm.Skins.gogglestex1';
			}
		}
	}
	else if (bHasGlasses)
	{
		if (bhascoat)
		{
			Multiskins[6] = Texture'tnm.Skins.FramesTex6';
			Multiskins[7] = Texture'tnm.Skins.LensesTex8';
			switch (EyeType)
			{
				case ET_Sunglasses:
					Multiskins[6] = Texture'tnm.Skins.Sunglasses_Black';
					Multiskins[7] = Texture'tnm.Skins.LensesTex5';
					break;
				// case ET_Vaporwave:
					// Player.Multiskins[7] = Texture'tnm.Skins.Visor_Vaporwave_A00';
					// break;
				case ET_Aviators:
					Multiskins[6] = Texture'tnm.Skins.Sunglasses_Aviator';
					Multiskins[7] = Texture'tnm.Skins.LensesTex1';
					break;
				default:
					Multiskins[7] = Texture'tnm.Skins.LensesTex8';
			}
		}
		else
		{
			Multiskins[4] = Texture'tnm.Skins.LensesTex8';
			Multiskins[5] = Texture'tnm.Skins.FramesTex6';
			switch (EyeType)
			{
				case ET_Sunglasses:
					Multiskins[4] = Texture'DeusExCharacters.Skins.LensesTex5';
					Multiskins[5] = Texture'tnm.Skins.Sunglasses_Black';
					break;
				// case ET_Vaporwave:
					// Player.Multiskins[4] = Texture'tnm.Skins.Visor_Vaporwave_A00';
					// break;
				case ET_Aviators:
					Multiskins[4] = Texture'DeusExCharacters.Skins.LensesTex1';
					Multiskins[5] = Texture'tnm.Skins.Sunglasses_Aviator';
					break;
				default:
					Multiskins[4] = Texture'tnm.Skins.LensesTex8';
			}
		}
	}
	else
	{
		if (bhascoat)
		{
			// Multiskins[6] = Texture'DeusExItems.Skins.GrayMaskTex';
			Multiskins[6] = Texture'DeusExItems.Skins.PinkMaskTex';
			Multiskins[7] = Texture'DeusExItems.Skins.PinkMaskTex';
			Multiskins[3] = Texture'DeusExItems.Skins.PinkMaskTex';
		}
		else
		{
			Multiskins[5] = Texture'DeusExItems.Skins.PinkMaskTex';
			Multiskins[4] = Texture'DeusExItems.Skins.PinkMaskTex';
			Multiskins[6] = Texture'DeusExItems.Skins.PinkMaskTex';
			Multiskins[7] = Texture'DeusExItems.Skins.PinkMaskTex';
		}
	}

	switch(tempskin)
	{
		case 0:	
			if (!bHasCoat)
				MultiSkins[3] = Texture'tnm.skins.TrestkonTex0'; 
			else
				MultiSkins[0] = Texture'tnm.skins.TrestkonTex0'; 
			break;
		case 1:
			if (!bHasCoat)
				MultiSkins[3] = Texture'tnm.skins.TrestkonTex4'; 
			else
				MultiSkins[0] = Texture'tnm.skins.TrestkonTex4'; 
			break;
		case 2:	
			if (!bHasCoat)
				MultiSkins[3] = Texture'tnm.skins.TrestkonTex5'; 
			else
				MultiSkins[0] = Texture'tnm.skins.TrestkonTex5'; 
			break;
		case 3:	
			if (!bHasCoat)
				MultiSkins[3] = Texture'tnm.skins.TrestkonTex6'; 
			else
				MultiSkins[0] = Texture'tnm.skins.TrestkonTex6'; 
			break;
		case 4:
			if (!bHasCoat)
				MultiSkins[3] = Texture'tnm.skins.TrestkonTex7'; 
			else
				MultiSkins[0] = Texture'tnm.skins.TrestkonTex7'; 
			break;
		case 5:	
			if (!bHasCoat)
				MultiSkins[3] = Texture'tnm.skins.TrestkonTex8'; 
			else
				MultiSkins[0] = Texture'tnm.skins.TrestkonTex8'; 
			break;
	}
	Skin      = Default.Skin;
	ScaleGlow = Default.ScaleGlow;
	Style     = Default.Style;
	if (coopCharacterModel > 0)
		ApplyCoopModel(coopCharacterModel);
}

function MakeTranslucent(bool Translucent, optional bool KeepTextures)
{
	local bool bhasvisor;
	local bool bhasglasses;
	local bool bhascoat;
	local int tempskin;
	
	if (Translucent)
	{
		if (KeepTextures)
			Style = STY_Translucent;
		else
			SetSkinStyle(STY_Translucent, Texture'WhiteStatic', 0.025);
			
		tempskin = PlayerSkin;
		
		if (tempskin >= 18)
		{
			tempskin -= 18;
			bhascoat = true;
		}
		if (tempskin >= 12)
		{
			tempskin -= 12;
			bhasglasses = true;
		}
		else if (tempskin >= 6)
		{
			tempskin -= 6;
			bhasvisor = true;
		}
		
		if (bhasvisor)
		{
			if (bhascoat)
			{
				MultiSkins[3] = Texture'BlackMaskTex';
			}
			else
			{
				MultiSkins[6] = Texture'BlackMaskTex';
			}
		}
		else if (bHasGlasses)
		{
			if (bhascoat)
			{
				MultiSkins[6] = Texture'BlackMaskTex';
				MultiSkins[7] = Texture'BlackMaskTex';
			}
			else
			{
				MultiSkins[4] = Texture'BlackMaskTex';
				MultiSkins[5] = Texture'BlackMaskTex';
				MultiSkins[6] = Texture'PinkMaskTex';
			}
		}
	}
	else
	{
		ResetSkinStyle();
	}
}

function ChangeCloak(bool bTurningOn)
{	
	if (bTurningOn && !bCloaked)
	{
		bCloaked = True;
		
		// if (inHand != None && inHand.IsA('DeusExWeapon'))
			// ServerConditionalNotifyMsg( MPMSG_NoCloakWeapon );
	
		PlaySound(Sound'CloakUp', SLOT_Interact, 0.85, ,768,1.0);
		MakeTranslucent(True, False);
		KillShadow();
	}
	else if (!bTurningOn && bCloaked)
	{
		bCloaked = False;
		
		PlaySound(Sound'CloakDown', SLOT_Interact, 0.85, ,768,1.0);
		MakeTranslucent(False, False);
		CreateShadow();
	}
}

function startCinematic(bool B, bool bShowPlayer, bool bChangeState, optional bool bKeepMusic)
{
	if (B)
	{
		if (CurrentCam != none)
		{
			CurrentCam.GoToSleep();
		}
		else
		{
			bOldBehindView = bbehindview;
		}

		bbehindView = bShowPlayer;
		if (!bShowPlayer)
			KillShadow();
		if ( bChangeState && !IsInState('Cinematic'))
			GotoState('Cinematic');
	}
	else if (!B&&bCinematic)
	{
		bbehindview = bOldBehindView;
		if ( bChangeState && IsInState('Cinematic'))
			GotoState('PlayerWalking');
	}

	bcinematic = B;
	bCinematicInterruptMusic = !bKeepMusic;
	GiveCamera(B);
}

state Conversation
{
	function endstate()
	{
		Super.endstate();
		
		// Killing someone to end the convo prematurely
		if (bCinematic)
		{
			bOldBehindView = false;
			startcinematic(false, false, false);
			showhud(true);
		}
	}
}


state Cinematic
{
	ignores all;
	
	function ProcessMove ( float DeltaTime, vector newAccel, eDodgeDir DodgeMove, rotator DeltaRot){}
	event PlayerTick(float deltaTime){}

	function bool RestrictInput()
	{
		return true;
	}

	function beginstate()
	{
		showhud(false);
	}
	function endstate()
	{
		showhud(true);
	}
}

state StealthCinematic extends Cinematic
{
	ignores all;
	
	function ProcessMove ( float DeltaTime, vector newAccel, eDodgeDir DodgeMove, rotator DeltaRot){}
	event PlayerTick(float deltaTime){}
	function PlayLanded(float impactVel){}
	function ShowMainMenu(){}
	
	function BeginState()
	{
		DeusExRootWindow(rootWindow).hud.belt.SetVisibility(false);
		DeusExRootWindow(rootWindow).hud.hit.SetVisibility(false);
		DeusExRootWindow(rootWindow).hud.ammo.SetVisibility(false);
		DeusExRootWindow(rootWindow).hud.activeItems.SetVisibility(false);
		DeusExRootWindow(rootWindow).hud.damageDisplay.SetVisibility(false);
		DeusExRootWindow(rootWindow).hud.compass.SetVisibility(false);
		TNMHud(DeusExRootWindow(rootWindow).hud).cross.SetCrosshair(false);
		if (TNMHud(DeusExRootWindow(rootWindow).hud) != None)
			TNMHud(DeusExRootWindow(rootWindow).hud).eggWin.Show(false);
		if (Weapon != None)
			DeusExWeapon(Weapon).ScopeOff();
	}
}

state StunnedTemporal
{
	ignores all;
	
	function ProcessMove ( float DeltaTime, vector newAccel, eDodgeDir DodgeMove, rotator DeltaRot){}
	event PlayerTick(float deltaTime){}
	function PlayLanded(float impactVel){}

Begin:
	Acceleration = vect(0, 0, 0);
	// PlayStunned();
	AnimRate = 0;
	while (temporalness > 0)
	{
		temporalness -= 1.25;
		statictime = temporalness;
		// ShowStaticDamage(true, 0.1, true);
		showstatic(true, 0.1, true);
		Sleep(0.1);
	}
	if (NextState == '')
		GotoState('PlayerWalking');
	else
		GotoState(NextState);
}

// ----------------------------------------------------------------------
// PlayerCalcView()
// ----------------------------------------------------------------------
event PlayerCalcView( out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local rotator rot;
	local vector targetLoc, dirToTarget, sideDir, midPoint, desiredCamLoc, hitLoc, hitNorm;
	
	if (bCinematic)
	{
		ViewActor = TCam;
		if ( TCam.ViewTarget != none )
		{			
			CameraRotation = Rotator(TCam.ViewTarget.Location - TCam.Location);
		}
		else
		{
			if (TCam.Physics == PHYS_Interpolating)
				CameraRotation = TCam.Rotation;
			else
				CameraRotation = TCam.ViewRotation;
		}
		CameraLocation = TCam.Location;
	}
	else if (Level.NetMode == NM_Client && bClientInThirdPersonConvo && (clientConvoTarget != None || clientConvoTargetLoc != vect(0, 0, 0)))
	{
		bBehindView = True;
		ViewActor = Self;
		if (clientConvoTarget != None)
			targetLoc = clientConvoTarget.Location;
		else
			targetLoc = clientConvoTargetLoc;
		dirToTarget = targetLoc - Location;
		dirToTarget.Z = 0;
		if (VSize(dirToTarget) < 1.0)
			dirToTarget = Vector(Rotation);
		else
			dirToTarget = Normal(dirToTarget);
		sideDir = dirToTarget Cross vect(0, 0, 1);
		midPoint = 0.5 * (Location + targetLoc) + vect(0, 0, 1) * (EyeHeight * 0.6);
		desiredCamLoc = midPoint - dirToTarget * 70.0 + sideDir * 95.0 + vect(0, 0, 22.0);
		if (Trace(hitLoc, hitNorm, desiredCamLoc, midPoint, False) != None)
			desiredCamLoc = hitLoc + hitNorm * 12.0;
		CameraLocation = desiredCamLoc;
		CameraRotation = Rotator(midPoint - CameraLocation);
	}
	else if (flagBase != None && flagbase.GetBool('StealthComplete'))
	{
		CameraLocation = Location;
		// CameraLocation.Z += 512;
		// CameraLocation.X += 512;
		CameraLocation.Z += FMin(512,(Level.TimeSeconds - flagbase.GetFloat('StealthCompleteTime')) * 512);
		CameraLocation.X += FMin(512,(Level.TimeSeconds - flagbase.GetFloat('StealthCompleteTime')) * 512);
		CameraRotation = Rotator(Location - CameraLocation);
		rot = Rotator(CameraLocation - Location);
		ViewRotation = rot;
		rot.Pitch = 0;
		rot.Roll = 0;
		SetRotation(rot);
		// CameraRotation.Pitch += 8192;
	}
	else if (flagBase != None && flagbase.GetBool('CombatComplete'))
	{
		CameraLocation = Location;
		// CameraLocation.Z += 512;
		// CameraLocation.X += 512;
		CameraLocation.Z += FMin(512,(Level.TimeSeconds - flagbase.GetFloat('CombatCompleteTime')) * 512);
		CameraLocation.X += FMin(512,(Level.TimeSeconds - flagbase.GetFloat('CombatCompleteTime')) * 512);
		CameraRotation = Rotator(Location - CameraLocation);
		rot = Rotator(CameraLocation - Location);
		ViewRotation = rot;
		rot.Pitch = 0;
		rot.Roll = 0;
		SetRotation(rot);
		// CameraRotation.Pitch += 8192;
	}
	else
	{
		if (!bbeeblequixview)
		{
			// bleh
			// check for spy drone and freeze player's view
			if (bSpyDroneActive)
			{
				if (aDrone != None)
				{
					// First-person view.			
					if (bAltSpyDroneView) // Spydrone is big view, player view is small window.
					{
						CameraLocation = aDrone.Location;
						CameraRotation = aDrone.Rotation;
						bBehindView = True;	// Required to make JC appear in the main view.
					}
					else
						super.PlayerCalcView(ViewActor, CameraLocation, CameraRotation);
				}
				else
					super.PlayerCalcView(ViewActor, CameraLocation, CameraRotation);
			}
			else
				super.PlayerCalcView(ViewActor, CameraLocation, CameraRotation);
		}
		else
		{
			ViewActor = Self;
			CameraRotation = ViewRotation;
			camerarotation.pitch += pitchchange;
			camerarotation.yaw += yawchange;

			CameraLocation = Location;
			CameraLocation.Z += EyeHeight;
			CameraLocation.z += zchange;
			cameralocation -= zoomchange * vector(camerarotation);
		}
		if ((Level.NetMode == NM_Client) && (ViewActor == Self) && !bBehindView)
			CameraLocation += coopVisualSmoothOffset;
	}

	if (blogview)
	{
		logView_log.fLog("Camera Location:");
		logView_log.fLog(CameraLocation);
		logView_log.fLog("Camera Rotation:");
		logView_log.fLog(CameraRotation);
		logView_log.fLog("--------");
		blogview = false;
	}
}

//insane
function calcroll()
{
	if ( newroll > default.newroll )
		rollincrement -= rollincrementincrement;
	else if ( newroll < default.newroll )
		rollincrement += rollincrementincrement;
	newroll += rollincrement;
}

function calcfov()
{
	if ( newfov > default.newfov )		
		fovincrement -= fovincrementincrement;
	else if ( newfov < default.newfov )
		fovincrement += fovincrementincrement;
	newfov += fovincrement;
}

// ----------------------------------------------------------------------
// DrugEffects()
// ----------------------------------------------------------------------

#exec obj load file=TNM_Misc_Tex

simulated function DrugEffects(float deltaTime)
{
	local float mult, fov;
	local Rotator rot;
	local DeusExRootWindow root;
	local int i;

	root = DeusExRootWindow(rootWindow);

	// random wandering and swaying when drugged
	if ((drugEffectTimer > 0) ||(binsane) || (melkEffectTimer > 0))
	{
		if(binsane)
			calcroll();

		if (melkEffectTimer>3 && (root != None) && (root.hud != None))
		{
			if (root.hud.background == None)
			{
				root.hud.SetBackgroundStyle(DSTY_Normal);
				root.hud.SetBackground(Texture'TNM_Core_Tex.Effects.CalmMelk');
				root.hud.SetBackgroundSmoothing(True);
				root.hud.SetBackgroundStretching(True);
				root.hud.SetBackgroundStyle(DSTY_Translucent);
			}
		}
		else if (melkEffectTimer>0 && (root != None) && (root.hud != None))
		{
			// if (root.hud.background == None)
			// {
				root.hud.SetBackgroundStyle(DSTY_Normal);
				root.hud.SetBackground(Texture'TNM_Core_Tex.Effects.CalmMelk');
				root.hud.SetBackgroundSmoothing(True);
				root.hud.SetBackgroundStretching(True);
				root.hud.SetBackgroundStyle(DSTY_Modulated);
			// }
		}
		else if (drugEffectTimer>0 && (root != None) && (root.hud != None))
		{
			if (root.hud.background == None)
			{
				root.hud.SetBackground(Texture'DrunkFX');
				root.hud.SetBackgroundSmoothing(True);
				root.hud.SetBackgroundStretching(True);
				root.hud.SetBackgroundStyle(DSTY_Modulated);
			}
		}

		if (binsane && (rootwindow != None) && insanewindow==None)
		{
			insanewindow=deusexrootwindow(rootWindow).hud.NewChild(Class'Window');
			for(i=0;i<10000;i++)
				insanewindow.lower(); //go to bottom
			insanewindow.SetWindowAlignments(HALIGN_Full, VALIGN_Full);
			insanewindow.SetBackground(Texture'TNM_Misc_Tex.Misc.SCAnim_A00');
			insanewindow.SetBackgroundSmoothing(True);
			insanewindow.SetBackgroundStretching(True);
			insanewindow.SetBackgroundStyle(DSTY_Modulated);
			//Texture'TNM_Core_Tex.InfoPortraits.Info_ShadowCode'
		}

		mult = FClamp(drugEffectTimer / 10.0, 0.0, 3.0);
		rot.Pitch = 1024.0 * Cos(Level.TimeSeconds * mult) * deltaTime * mult;
		rot.Yaw = 1024.0 * Sin(Level.TimeSeconds * mult) * deltaTime * mult;
		rot.Roll = 0;

		rot.Pitch = FClamp(rot.Pitch, -4096, 4096);
		rot.Yaw = FClamp(rot.Yaw, -4096, 4096);

		ViewRotation += rot;

		if(drugEffectTimer>0)
		{
			fov = Default.DesiredFOV - drugEffectTimer + Rand(2);
			fov = FClamp(fov, 30, Default.DesiredFOV);
			DesiredFOV = fov;
		}

		else if(bInsane)
		{
			fov = Default.DesiredFOV;
			fov = FClamp(fov, 30, Default.DesiredFOV);
			DesiredFOV = fov;
		}

		// if (binsane)
		// {
			// calcfov();
			// DesiredFOV = newfov/10;
			// if(drugEffectTimer>0)
				// DesiredFOV+=fov-Default.DesiredFOV;
			// DefaultFOV = DesiredFOV;
		// }

		DesiredFOV+=scopefov;

		drugEffectTimer -= deltaTime;
		if (drugEffectTimer < 0)
			drugEffectTimer = 0;

		melkEffectTimer -= deltaTime;
		if (melkEffectTimer < 0)
			melkEffectTimer = 0;
	}

	if(!bInsane)
	{
		if (insanewindow!=None)
		{
			insanewindow.Hide();
			insanewindow.DisableWindow();
			insanewindow=None;
			newroll = 0;
			rollincrement=0;
			DefaultFOV=Default.DefaultFOV;
			DesiredFOV=DefaultFOV;
			newfov = DefaultFOV*10;
			fovincrement=0;
			DrugEffects(0);
		}
	}

	if(drugEffectTimer<=0 && melkEffectTimer <=0)
	{
		if ((root != None) && (root.hud != None))
		{
			if (root.hud.background != None)
			{
				root.hud.SetBackground(None);
				root.hud.SetBackgroundStyle(DSTY_Normal);
				DesiredFOV = Default.DesiredFOV;
				DrugEffects(0);
			}
		}
	}
}


simulated function MoveDominatedBot( float DeltaTime, Vector loc )
{
	// if the wanted velocity is zero, apply drag so we slow down gradually
	if (VSize(loc) == 0)
	{
		if (dominatedbot.bishoverbot)
			dominatedbot.Velocity = dominatedbot.velocity * 0.9 + deltaTime * Sin(Level.TimeSeconds * 2.0) * vect(0,0,1);
	}
	else
	{
		if (dominatedbot.bishoverbot)
			dominatedbot.Velocity += deltaTime * dominatedbot.airSpeed * loc + deltaTime * Sin(Level.TimeSeconds * 2.0) * vect(0,0,1);
		else
			dominatedbot.velocity += deltaTime * dominatedbot.getwalkingspeed() * loc;
	}
}

/*exec*/ function StartSkates()
{
	bSkating = true;
	ExtinguishFire();
}

/*exec*/ function StopSkates()
{
	bSkating = false;
}

function float GetCurrentGroundSpeed()
{
	local float speed, augValue;

	if (bSkating)
		speed = Default.GroundSpeed * 17;
	else if (Level.NetMode == NM_Standalone)
		speed = super.GetCurrentGroundSpeed();
	else if (AugmentationSystem == None)
		speed = Default.GroundSpeed;	// super returns 0 here, which crawls the client until augs replicate
	else
	{
		// singleplayer formula; super uses Human.mpGroundSpeed in netgames
		augValue = AugmentationSystem.GetAugLevelValue(class'AugSpeed');
		if (augValue == -1.0)
			augValue = 1.0;
		speed = Default.GroundSpeed * augValue;
	}

	return speed;
}

state CheatFlying
{
ignores SeePlayer, HearNoise, Bump, TakeDamage, PlayFootStep;

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		Acceleration = Normal(NewAccel);
		Velocity = Normal(NewAccel) * flySpeed;
		AutonomousPhysics(DeltaTime);
	}

	event PlayerTick( float DeltaTime )
	{
		//Super.PlayerTick( DeltaTime );
		// Reset FrobTarget so we don't fly around with
		// something remaining highlighted.
		//FrobTarget = None;
		//UpdateInHand();
		
		if ( bUpdatePosition )
			ClientUpdatePosition();
		
		RefreshSystems(deltaTime);
		DrugEffects(deltaTime);
		HighlightCenterObject();
		UpdateDynamicMusic(deltaTime);
		MultiplayerTick(deltaTime);
		FrobTime += deltaTime;
		CheckActiveConversationRadius();
		CheckActorDistances();
		UpdateTimePlayed(deltaTime);
		
		PlayerMove(DeltaTime);
	}
}

state PlayerWalking
{
	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local EDodgeDir OldDodge;
		local eDodgeDir DodgeMove;
		local rotator OldRotation;
		local float Speed2D;
		local bool	bSaveJump;
		local name AnimGroupName;
		local class<ChargedPickup> cp;

		local rotator rot;

		GetAxes(Rotation,X,Y,Z);

		if (bplatformer)
		{
			if (aforward > 0) // W/S support for up down 
				DoJump();
			
				// bDuck = byte(aforward < 0);
			if (bbackwards)
				astrafe *= -1;
			if (bReverseControls)
				astrafe *= -1;
			if (astrafe<0)
			{
				bbackwards = !bbackwards;
				viewrotation.yaw += 65536/2;
				addyaw(65536/2);
			}
			aturn = 0;
			aforward = astrafe;
			astrafe  = 0;
			aLookup  = 0;
		}
		else
		{
			aForward *= 0.4;
			aStrafe  *= 0.4;
			aLookup  *= 0.24;
			aTurn    *= 0.24;
		}

		if (vector(Rotation) dot vector(ViewRotation) < 0.0)
			bWalkingBackwards = true;
		if (vector(Rotation) dot vector(ViewRotation) > 0.0)
			bWalkingBackwards = false;

		//I fail at unreal engine QQ
		if (bSkating)
		{
			cp = class<ChargedPickup>(DynamicLoadObject("TNMItems.LollerSkates",class'Class'));
			if (!UsingChargedPickup(cp))
				StopSkates();
		}

		if (!bSkating)
		{
			// Update acceleration.
			NewAccel = aForward*X + aStrafe*Y;
			NewAccel.Z = 0;
			// Check for Dodge move
			if ( DodgeDir == DODGE_Active )
				DodgeMove = DODGE_Active;
			else
				DodgeMove = DODGE_None;

			if (DodgeClickTime > 0.0)
			{
				if ( DodgeDir < DODGE_Active )
				{
					OldDodge = DodgeDir;
					DodgeDir = DODGE_None;
					if (bEdgeForward && bWasForward)
						DodgeDir = DODGE_Forward;
					if (bEdgeBack && bWasBack)
						DodgeDir = DODGE_Back;
					if (bEdgeLeft && bWasLeft)
						DodgeDir = DODGE_Left;
					if (bEdgeRight && bWasRight)
						DodgeDir = DODGE_Right;
					if ( DodgeDir == DODGE_None)
						DodgeDir = OldDodge;
					else if ( DodgeDir != OldDodge )
						DodgeClickTimer = DodgeClickTime + 0.5 * DeltaTime;
					else
						DodgeMove = DodgeDir;
				}

				if (DodgeDir == DODGE_Done)
				{
					DodgeClickTimer -= DeltaTime;
					if (DodgeClickTimer < -0.35)
					{
						DodgeDir = DODGE_None;
						DodgeClickTimer = DodgeClickTime;
					}
				}
				else if ((DodgeDir != DODGE_None) && (DodgeDir != DODGE_Active))
				{
					DodgeClickTimer -= DeltaTime;
					if (DodgeClickTimer < 0)
					{
						DodgeDir = DODGE_None;
						DodgeClickTimer = DodgeClickTime;
					}
				}
			}

			AnimGroupName = GetAnimGroup(AnimSequence);
			if ( (Physics == PHYS_Walking) && (AnimGroupName != 'Dodge') )
			{
				//if walking, look up/down stairs - unless player is rotating view
				if ( !bKeyboardLook && (bLook == 0) )
				{
					if ( bLookUpStairs )
						ViewRotation.Pitch = FindStairRotation(deltaTime);
					else if ( bCenterView )
					{
						ViewRotation.Pitch = ViewRotation.Pitch & 65535;
						if (ViewRotation.Pitch > 32768)
							ViewRotation.Pitch -= 65536;
						ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
						if ( Abs(ViewRotation.Pitch) < 1000 )
							ViewRotation.Pitch = 0;
					}
				}

				Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
				//add bobbing when walking
				if ( !bShowMenu )
					CheckBob(DeltaTime, Speed2D, Y);

			}
			else if ( !bShowMenu )
			{
				BobTime = 0;
				WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
			}
		}
		else //skating
		{
			//can't slow down so...
			//SkateSpeed = FMax(SkateSpeed * 0.1 / (DeltaTime + 1), aForward*0.05);
			SkateSpeed = FMax(SkateSpeed, aForward*0.65);

			NewAccel = X * skatespeed;
			NewAccel.Z = 0;
			aTurn *= 0.2;
		}

		// Update rotation.
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);

		if ( bPressedJump && (AnimGroupName == 'Dodge') )
		{
			bSaveJump = true;
			bPressedJump = false;
		}
		else
			bSaveJump = false;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DodgeMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DodgeMove, OldRotation - Rotation);
		bPressedJump = bSaveJump;
	}


	// lets us affect the player's movement
	function ProcessMove ( float DeltaTime, vector newAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
		local vector loc, NewVect;
		
		if (bdominatingbot)
		{
			if ( dominatedbot != None )
			{
				// put away whatever is in our hand
				if (inHand != None)
					PutInHand(None);

				// make the drone's rotation match the player's view
				dominatedbot.SetRotation(ViewRotation);

				// move the drone
				if (dominatedbot.bishoverbot)
					loc = Normal((aup * vect(0,0,1) + aForward * vect(1,0,0) + aStrafe * vect(0,1,0)) >> ViewRotation);
				else
					loc = Normal((aForward * vect(1,0,0) + aStrafe * vect(0,1,0)) >> ViewRotation);

				// opportunity for client to translate movement to server
				MoveDOMinatedBot( DeltaTime, loc );

				// freeze the player
				Velocity = vect(0,0,0);
			}
			return;
		}

		// if the spy drone augmentation is active
		if (bSpyDroneActive)
		{
			if ( aDrone != None )
			{
				// put away whatever is in our hand
				if (inHand != None)
					PutInHand(None);

				// make the drone's rotation match the player's view
				aDrone.SetRotation(ViewRotation);

				// move the drone
				loc = Normal((aUp * vect(0,0,1) + aForward * vect(1,0,0) + aStrafe * vect(0,1,0)) >> ViewRotation);

				// opportunity for client to translate movement to server
				MoveDrone( DeltaTime, loc );

				//Velocity = vect(0,0,0);
				//G-Flex: stop player from accelerating instead of freezing them completely
				//G-Flex: this preserves swim bob/floating especially
				Acceleration = vect(0,0,0);
			}
			return;
		}

		Super.ProcessMove(DeltaTime, newAccel, DodgeMove, DeltaRot);

		if ((Level.NetMode != NM_Standalone) && !bSkating)
			CoopApplySinglePlayerGroundSpeed(newAccel);

		if (TNMWeapon(Weapon) != None && TNMWeapon(Weapon).Attribute == Att_Fleeting)
			GroundSpeed *= 1.2;
		
		if (bPlatformer)
		{ 
			// crouching makes you four feet tall
			if (bIsCrouching || bForceDuck)
				SetBasedPawnSize(Default.CollisionRadius, 30.0);
			NewVect = Location;
			if (!bYAxis)
				NewVect.Y = yAxis;
			if (bYAxis)
				NewVect.X = xAxis;
			SetLocation(NewVect);
		}
		else if (altergravzone(Region.Zone) == None)
		{
			if (TNMWeapon(Weapon) != None && TNMWeapon(Weapon).Attribute == Att_Quaking)
				AirControl = Default.AirControl * 4;
			else
				AirControl = default.AirControl;
		}

		if (IsLeaning())
		{
			if ( PlayerIsClient() || (Level.NetMode == NM_Standalone) )
				if (!bAustralian)
					ViewRotation.Roll = curLeanDist * 20 + newroll;
				else
					ViewRotation.Roll = curLeanDist * 20 + 65536/2 + newroll;

			if (!bIsCrouching && !bForceDuck)
				SetBasedPawnSize(CollisionRadius, GetDefaultCollisionHeight() - Abs(curLeanDist) / 3.0);
		}
		else
			if(baustralian)
				viewrotation.roll = 65536/2 + newroll;
			else
				viewrotation.roll = newroll;
				
		// Crouching can move our region into a waterzone without triggering a zonechange
        if (Region.Zone != None && Region.Zone.bWaterZone)
        {
            setPhysics(PHYS_Swimming);
            GotoState('PlayerSwimming');
        }
	}

	/*event PlayerTick(float deltaTime)
	{
		local int i;
		log("---BEGIN---",'PlayerTick');log("DB #"$i++,'PlayerTick');
		RefreshSystems(deltaTime);log("DB #"$i++,'PlayerTick');

		DrugEffects(deltaTime);log("DB #"$i++,'PlayerTick');
		Bleed(deltaTime);log("DB #"$i++,'PlayerTick');
		HighlightCenterObject();log("DB #"$i++,'PlayerTick');

		UpdateDynamicMusic(deltaTime);log("DB #"$i++,'PlayerTick');
		UpdateWarrenEMPField(deltaTime);log("DB #"$i++,'PlayerTick');
	        MultiplayerTick(deltaTime);log("DB #"$i++,'PlayerTick');
		FrobTime += deltaTime;log("DB #"$i++,'PlayerTick');

		// save some texture info
		FloorMaterial = GetFloorMaterial();log("DB #"$i++,'PlayerTick');
		WallMaterial = GetWallMaterial(WallNormal);log("DB #"$i++,'PlayerTick');

		// Check if player has walked outside a first-person convo.
		CheckActiveConversationRadius();log("DB #"$i++,'PlayerTick');

		// Check if all the people involved in a conversation are 
		// still within a reasonable radius.
		CheckActorDistances();log("DB #"$i++,'PlayerTick');

		// Update Time Played
		UpdateTimePlayed(deltaTime);log("DB #"$i++,'PlayerTick');

		if ( bUpdatePosition ){
			log("bupdateposition",'PlayerTick');ClientUpdatePosition();log("DB #"$i++,'PlayerTick');}

		PlayerMove(DeltaTime);log("DB #"$i++,'PlayerTick');log("---END---",'PlayerTick');
	}*/
}

state PlayerSwimming
{
	event PlayerTick(float deltaTime)
	{
		Super.PlayerTick(deltaTime);
			
		dripRate += deltaTime*2;
			
		if (dripRate >= 15)
			dripRate = 15.0;
	}

    function PlayerMove(float DeltaTime)
    {
        local rotator oldRotation;
        local vector X,Y,Z, NewAccel;
        local float Speed2D;

        GetAxes(ViewRotation,X,Y,Z);

		if (bplatformer)
		{
			if (aforward != 0)	// W/S support for up down 
				aUp = aforward;
			if (bbackwards)
				astrafe *= -1;
			if (bReverseControls)
				astrafe *= -1;
			if (astrafe<0)
			{
				bbackwards = !bbackwards;
				viewrotation.yaw += 65536/2;
				addyaw(65536/2);
			}
			aturn = 0;
			aforward = astrafe;
			astrafe  = 0;
			aLookup  = 0;
		}
		else
		{
			aForward *= 0.2;
			aStrafe  *= 0.1;
			aLookup  *= 0.24;
			aTurn    *= 0.24;
			aUp      *= 0.1;
		}

        NewAccel = aForward*X + aStrafe*Y + aUp*vect(0,0,1);

        //add bobbing when swimming
        if ( !bShowMenu )
        {
            Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
            WalkBob = Y * Bob *  0.5 * Speed2D * sin(4.0 * Level.TimeSeconds);
            WalkBob.Z = Bob * 1.5 * Speed2D * sin(8.0 * Level.TimeSeconds);
        }

        // Update rotation.
        oldRotation = Rotation;
        UpdateRotation(DeltaTime, 2);

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, NewAccel, DODGE_None, OldRotation - Rotation);
        else
            ProcessMove(DeltaTime, NewAccel, DODGE_None, OldRotation - Rotation);
        bPressedJump = false;
    }

    function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
    {
        local vector X,Y,Z, Temp;
		local vector loc, NewVect;

        // if the spy drone augmentation is active
        if (bSpyDroneActive)
        {
            if ( aDrone != None )
            {
                // put away whatever is in our hand
                if (inHand != None)
                    PutInHand(None);

                // make the drone's rotation match the player's view
                aDrone.SetRotation(ViewRotation);

                // move the drone
                loc = Normal((aUp * vect(0,0,1) + aForward * vect(1,0,0) + aStrafe * vect(0,1,0)) >> ViewRotation);

                // opportunity for client to translate movement to server
                MoveDrone( DeltaTime, loc );

                // freeze the player
                //Velocity = vect(0,0,0);
                //G-Flex: stop player from accelerating instead of freezing them completely
                //G-Flex: this preserves swim bob/floating especially
                Acceleration = vect(0,0,0);
            }
            return;
        }

        // singleplayer swim speed; DeusExPlayer uses Human.mpWaterSpeed (and an
        // Aqualung speed bonus) in netgames
        if ((Level.NetMode != NM_Standalone) && (SkillSystem != None))
            WaterSpeed = Default.WaterSpeed * SkillSystem.GetSkillLevelValue(class'SkillSwimming');

        GetAxes(ViewRotation,X,Y,Z);
        Acceleration = NewAccel;

        SwimAnimUpdate( (X Dot Acceleration) <= 0 );

        // DEUS_EX CNN - changed water jump to require positive Z accel. AND at least a 22.5 degree pitch
//      bUpAndOut = ((X Dot Acceleration) > 0) && ((Acceleration.Z > 0) || (ViewRotation.Pitch > 2048));
		if (bplatformer)
			bUpAndOut = ((X Dot Acceleration) > 0) && (Acceleration.Z > 0);
		else
			bUpAndOut = ((X Dot Acceleration) > 0) && (Acceleration.Z > 0) && (ViewRotation.Pitch > 4096);
        if ( bUpAndOut && !Region.Zone.bWaterZone && CheckWaterJump(Temp) ) //check for waterjump
        {
            velocity.Z = 330 + 2 * CollisionRadius; //set here so physics uses this for remainder of tick
            PlayDuck();
            GotoState('PlayerWalking');
        }
		
		if (bPlatformer)
		{ 
			// crouching makes you four feet tall
			if (bIsCrouching || bForceDuck)
				SetBasedPawnSize(Default.CollisionRadius, 30.0);
			NewVect = Location;
			if (!bYAxis)
				NewVect.Y = yAxis;
			if (bYAxis)
				NewVect.X = xAxis;
			SetLocation(NewVect);
		}
    }
}

simulated function InvokeUIScreen(Class<DeusExBaseWindow> windowClass)
{
	local DeusExRootWindow root;

	if (RestrictInput())
		return;

	root = DeusExRootWindow(rootWindow);
	if (root != None)
		root.InvokeUIScreen(windowClass);
}

simulated exec function ShowInventoryWindow()
{
	if (RestrictInput())
		return;

	if ((Level.NetMode != NM_Standalone) && (bBeltIsMPInventory))
	{
		ClientMessage("Inventory screen disabled in multiplayer");
		return;
	}

	InvokeUIScreen(Class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.tnmPersonaScreenInventory", class'Class')) );
}


// ----------------------------------------------------------------------
// ShowSkillsWindow()
// ----------------------------------------------------------------------

simulated exec function ShowSkillsWindow()
{
	if (RestrictInput())
		return;

	if ((Level.NetMode != NM_Standalone) && (bBeltIsMPInventory))
	{
	ClientMessage("Skills screen disabled in multiplayer");
	return;
	}

	InvokeUIScreen(Class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.tnmPersonaScreenSkills", class'Class')) );
}

// ----------------------------------------------------------------------
// ShowHealthWindow()
// ----------------------------------------------------------------------

simulated exec function ShowHealthWindow()
{
   if (RestrictInput())
      return;

   if ((Level.NetMode != NM_Standalone) && (bBeltIsMPInventory))
   {
      ClientMessage("Health screen disabled in multiplayer");
      return;
   }

   InvokeUIScreen(Class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.tnmPersonaScreenHealth", class'Class')) );
}

// ----------------------------------------------------------------------
// ShowImagesWindow()
// ----------------------------------------------------------------------

simulated exec function ShowImagesWindow()
{
	if (RestrictInput())
		return;

   if ((Level.NetMode != NM_Standalone) && (bBeltIsMPInventory))
   {
      ClientMessage("Images screen disabled in multiplayer");
      return;
   }

   InvokeUIScreen(Class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.tnmPersonaScreenImages", class'Class')) );
}

// ----------------------------------------------------------------------
// ShowConversationsWindow()
// ----------------------------------------------------------------------

simulated exec function ShowConversationsWindow()
{
	if (RestrictInput())
		return;

   if ((Level.NetMode != NM_Standalone) && (bBeltIsMPInventory))
   {
      ClientMessage("Conversations screen disabled in multiplayer");
      return;
   }

   InvokeUIScreen(Class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.tnmPersonaScreenConversations", class'Class')) );
}

// ----------------------------------------------------------------------
// ShowAugmentationsWindow()
// ----------------------------------------------------------------------

simulated exec function ShowAugmentationsWindow()
{
	if (RestrictInput())
		return;

   if ((Level.NetMode != NM_Standalone) && (bBeltIsMPInventory))
   {
      ClientMessage("Augmentations screen disabled in multiplayer");
      return;
   }

   InvokeUIScreen(Class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.tnmPersonaScreenAugmentations", class'Class')) );
}

// ----------------------------------------------------------------------
// ShowGoalsWindow()
// ----------------------------------------------------------------------

simulated exec function ShowGoalsWindow()
{
	if (RestrictInput())
		return;

   if ((Level.NetMode != NM_Standalone) && (bBeltIsMPInventory))
   {
      ClientMessage("Goals screen disabled in multiplayer");
      return;
   }

   InvokeUIScreen(Class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.tnmPersonaScreenGoals", class'Class')) );
}

// ----------------------------------------------------------------------
// ShowLogsWindow()
// ----------------------------------------------------------------------

simulated exec function ShowLogsWindow()
{
	if (RestrictInput())
		return;

   if ((Level.NetMode != NM_Standalone) && (bBeltIsMPInventory))
   {
      ClientMessage("Logs screen disabled in multiplayer");
      return;
   }

   InvokeUIScreen(Class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.tnmPersonaScreenLogs", class'Class')) );
}

// ----------------------------------------------------------------------
// CreateKeyRing()
// ----------------------------------------------------------------------

function CreateKeyRing()
{
	local inventory anItem;
	local inventory nextItem;

	if (KeyRing == None)
	{
		KeyRing = Spawn(class'tnmNanoKeyRing', Self);
		KeyRing.InitialState='Idle2';
		KeyRing.GiveTo(Self);
		KeyRing.SetBase(Self);
	}

}

//irc commands
function ClientMessageIRC(string msg)
{
	if(DeusExRootWindow(rootWindow) == None || DeusExRootWindow(rootWindow).hud == None || !DeusExRootWindow(rootWindow).hud.bIsVisible)
	{
		Player.Console.AddString(msg);
		AddLog(msg);
		return;
	}

	DeusExRootWindow(rootWindow).hud.msgLog.SetLogTimeout(4.0 + GetLogTimeout());
	ClientMessage(msg, 'IRC');
	DeusExRootWindow(rootWindow).hud.msgLog.SetLogTimeout(GetLogTimeout());	
}

exec function irc(string info)
{
	local string nick,server,channel;
	local int i;
	
	if (info ~= "quit" || info ~= "exit")
	{
		ircquit();
		return;
	}

	if(irc_link!=None)
	{
		irc_link.DestroyLink();
		irc_link=None;
	}
	
	if (info == "" && TruePlayerName != Default.TruePlayerName)
		info = TruePlayerName;

	i=InStr(info," ");
	if(i!=-1)
	{
		nick=left(info,i);
		info=mid(info,i+1);
		i=InStr(info," ");
		server=left(info,i);
		channel=mid(info,i+1);
	}
	else
	{
		nick=info;
		server="irc.gamesurge.net";
		channel="#otp";
	}
	
	lastNick=nick;
	lastServer=server;
	lastChannel=channel;

	irc_link=Spawn(class'tnmPassiveIRCLink');
	
	if (irc_link != None)
	{
		irc_link.Connect(nick,server,channel);
		bUsingIRC = True;		
	}
}

exec function ircconnect(string info)
{
	irc(info);
}

exec function IRCSay(string text)
{
	if(irc_link!=None)
	{
		irc_link.SendChannelText(irc_link.DefaultChannel,text);
	}
}

exec function Say(string text)
{
	if (Level.NetMode != NM_Standalone)
	{
		BroadcastCoopChatMessage(text);
		return;
	}
	if(irc_link!=None)
	{
		irc_link.SendChannelText(irc_link.DefaultChannel,text);
		return;
	}
	super.Say(text);
//	ClientMessage("not connected to irc!");
}

exec function TeamSay(string Msg)
{
	if (Level.NetMode != NM_Standalone)
	{
		BroadcastCoopChatMessage(Msg);
		return;
	}
	Super.TeamSay(Msg);
}

function BroadcastCoopChatMessage(string rawText)
{
	local Pawn P;
	local Trestkon T;
	local string cleanMsg, sender;

	cleanMsg = class'CoopLocalPrefs'.static.TrimText(rawText);
	if (cleanMsg == "")
		return;

	sender = GetCoopPlayerName();
	log("CoopChat> " $ sender $ ": " $ cleanMsg);

	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		T = Trestkon(P);
		if (T != None)
			T.ClientReceiveCoopChat(sender, cleanMsg, (T == Self));
	}
}

simulated function ClientReceiveCoopChat(string senderName, string chatBody, bool bFromSelf)
{
	local DeusExRootWindow root;
	local Window w;
	local CoopChatDisplayWindow chatWin;

	if (Role == ROLE_Authority && Viewport(Player) == None)
		return;

	// Save into Persona F1/F2 Log history as well
	AddLog("[CHAT] " $ senderName $ ": " $ chatBody);

	EnsureCoopHUDWindows();
	root = DeusExRootWindow(rootWindow);
	if (root != None && root.hud != None)
	{
		for (w = root.hud.GetTopChild(); w != None; w = w.GetLowerSibling())
		{
			if (CoopChatDisplayWindow(w) != None)
			{
				chatWin = CoopChatDisplayWindow(w);
				break;
			}
		}
		if (chatWin != None)
			chatWin.AddChatMessage(senderName, chatBody, bFromSelf);
	}

	if (bFromSelf)
		PlaySound(Sound'TNM.CoopChatSound', SLOT_None, 0.55, False, 65536.0, 1.0);
	else
		PlaySound(Sound'TNM.CoopChatSound', SLOT_None, 0.65, False, 65536.0, 1.0);
}

exec function ircquit()
{
	if(irc_link!=none)
	{
		bUsingIRC = False;
		irc_link.DestroyLink();
		irc_link=None;
	}
}

exec function ircdisconnect()
{
	ircquit();
}

exec function ircexit()
{
	ircquit();
}

//------------------------------------------------------------------------------
//tnm cheats
//------------------------------------------------------------------------------

exec function go()
{
	log(buf);
	if (buf != None)
		buf.GotoState('Executing');
}

exec function buffer(string cmd)
{
	if (!bCheatsEnabled)
		return;
	
	if(buf==none)
		buf=spawn(class'CommandBuffer',Self);
	buf.queue(cmd);
}

exec function froba(name n)
{
	local actor a;

	if (!bCheatsEnabled)
		return;
	
	foreach allactors(class'actor',a)
	{
		if(a.name==n)
		{
			a.frob(self,none);
			break;
		}
	}
}

exec function tracename()
{
	local Actor       hitActor;
	local Vector      hitLocation, hitNormal;
	local Vector      position, line;

	// if (!bCheatsEnabled)
		// return;

	position    = Location;
	position.Z += BaseEyeHeight;
	line        = Vector(ViewRotation) * 4000;

	hitActor = Trace(hitLocation, hitNormal, position+line, position, true);
	log(hitActor.name);
}

exec function mycoords(optional string info)
{
	local string text;
	text = "" $ location;
	if(info != "")
		text = text $ ":" @ info;
	log(text, 'coords');
	log(viewrotation, 'rotation');
}

exec function rotateto(string r)
{
	local string l;
	local int s;
	local rotator rot;

	//parse x y z out of the string
	r = (new(None) class'tnmRegex').str_replace(r,","," ");
	s = instr(r, " ");
	l = left(r, s);
	rot.pitch = float(l);
	r = right(r, len(r) - s - 1);
	s = instr(r, " ");
	l = left(r, s);
	rot.yaw =  float(l);
	r = right(r, len(r) - s - 1);
	rot.roll = float(r);
	viewrotation=rot;
}

exec function kill(name n)
{
	local actor a;

	if (!bCheatsEnabled)
		return;
	
	foreach allactors(class'actor',a)
	{
		if(a.name==n)
		{
			a.destroy();
			break;
		}
	}
}

exec function hateme(name t)
{
	local ScriptedPawn p;

	if (!bCheatsEnabled)
		return;
	
	foreach allactors(class'ScriptedPawn', p, t)
	{
		p.ChangeAlly('Player', -1, true, false);
	}
}

exec function loveme(name t)
{
	local ScriptedPawn p;

	if (!bCheatsEnabled)
		return;
	
	foreach allactors(class'ScriptedPawn', p, t)
	{
		p.ChangeAlly('Player', 1, true, false);
	}
}

exec function teleport(string r)
{
	local string l;
	local int s;
	local vector n;

	if (!bCheatsEnabled)
		return;

	//parse x y z out of the string
	r = (new(None) class'tnmRegex').str_replace(r,","," ");
	s = instr(r, " ");
	l = left(r, s);
	n.x = float(l);
	r = right(r, len(r) - s - 1);
	s = instr(r, " ");
	l = left(r, s);
	n.y =  float(l);
	r = right(r, len(r) - s - 1);
	n.z = float(r);
	setlocation(n);
}

exec function setflyspeed(int speed)
{
	flyspeed = speed;
}

exec function setbool(name flagname, optional string val)
{
	local bool b;

	if (!bCheatsEnabled)
		return;
	
	if(val=="")
		b=true;
	else
		b=bool(val);
	flagBase.setbool(flagname,b);
}

exec function dumpflags(optional string filename)
{
	local tnmlog l;

	if(!bCheatsEnabled)
		return;

	l=new (None) Class'tnmLog';
	if(filename!="")
		l.fOpen("flagdump_"$filename$".log");
	else
		l.fOpen("flagdump.log");

	class'FlagDump'.static.dumpflags(l,flagbase);

	l.fClose();
}

//balance info stuff, bloated but useful

function bool IsFiltered(Actor a, int d)
{
	switch(d)
	{
	case 0:
		return !a.bDifficulty0;
	case 1:
		return !a.bDifficulty1;
	case 2:
		return !a.bDifficulty2;
	case 3:
		return !a.bDifficulty3;
	}

	return false; //this should never happen
}

function DumpFilteredBalanceInfo(tnmlog dump, int level)
{
	local int i;
	local name n;
	local containers c;

	local name ammo_names[1024];
	local int ammo_counts[1024];
	local int ammo_len;
	local ammo a;

	local name weapon_names[1024];
	local int weapon_counts[1024];
	local int weapon_len;
	local weapon w;

	local name pickup_names[1024];
	local int pickup_counts[1024];
	local int pickup_len;
	local deusexpickup p;

	//these are just the categories I'm sorting everything into
	//not very performance-oriented code, obviously =p

	foreach AllActors(class'Ammo',a)
	{
		if(a.owner!=None || IsFiltered(a,level))
			continue;
		n=a.class.name;
		for(i=0;i<ammo_len;i++)
			if(ammo_names[i]==n)
				break;
		if(i==ammo_len)
			ammo_names[ammo_len++]=n;
		ammo_counts[i]++;
	}

	foreach AllActors(class'Weapon',w)
	{
		if(w.owner!=None || IsFiltered(w,level))
			continue;
		n=w.class.name;
		for(i=0;i<weapon_len;i++)
			if(weapon_names[i]==n)
				break;
		if(i==weapon_len)
			weapon_names[weapon_len++]=n;
		weapon_counts[i]++;
	}

	foreach AllActors(class'DeusExPickup',p)
	{
		if(p.owner!=None || IsFiltered(p,level))
			continue;
		n=p.class.name;
		for(i=0;i<pickup_len;i++)
			if(pickup_names[i]==n)
				break;
		if(i==pickup_len)
			pickup_names[pickup_len++]=n;
		pickup_counts[i]++;
	}

	foreach AllActors(class'Containers',c)
	{
		if(ClassIsChildOf(c.contents,class'Ammo'))
		{
			n=c.contents.name;
			for(i=0;i<ammo_len;i++)
				if(ammo_names[i]==n)
					break;
			if(i==ammo_len)
				ammo_names[ammo_len++]=n;
			ammo_counts[i]+=c.numThings;
		}

		if(ClassIsChildOf(c.contents,class'Weapon'))
		{
			n=c.contents.name;
			for(i=0;i<weapon_len;i++)
				if(weapon_names[i]==n)
					break;
			if(i==weapon_len)
				weapon_names[weapon_len++]=n;
			weapon_counts[i]+=c.numThings;
		}

		if(ClassIsChildOf(c.contents,class'DeusExPickup'))
		{
			n=c.contents.name;
			for(i=0;i<pickup_len;i++)
				if(pickup_names[i]==n)
					break;
			if(i==pickup_len)
				pickup_names[pickup_len++]=n;
			pickup_counts[i]+=c.numThings;
		}
	}

	dump.fLog("------DIFFICULTY"@level$"------");

	dump.fLog("---AMMO COUNTS---");
	for(i=0;i<ammo_len;i++)
		dump.fLog(String(ammo_names[i])$":"@ammo_counts[i]);

	dump.fLog("---WEAPON COUNTS---");
	for(i=0;i<weapon_len;i++)
		dump.fLog(String(weapon_names[i])$":"@weapon_counts[i]);

	dump.fLog("---PICKUP COUNTS---");
	for(i=0;i<pickup_len;i++)
		dump.fLog(String(pickup_names[i])$":"@pickup_counts[i]);
}

exec function dumpbalanceinfo()
{
	local string level_name;
	local string file_name;
	local tnmlog dump;

	level_name=Left(Level.GetLocalURL(),InStr(Level.GetLocalURL(),"?"));
	if(InStr(caps(level_name),".DX")!=-1)
		level_name=Left(level_name,InStr(caps(level_name),".DX"));
	file_name=level_name$"_balance.log";

	dump=new(None) class'tnmLog';
	dump.fOpen(file_name);
	dump.fLog("---------"$caps(level_name)@"BALANCE INFO---------");

	DumpFilteredBalanceInfo(dump,0);
	DumpFilteredBalanceInfo(dump,1);
	DumpFilteredBalanceInfo(dump,2);
	DumpFilteredBalanceInfo(dump,3);

	dump.fClose();

//	criticaldelete(dump);

	Player.Console.AddString("Dumped balance info to"@file_name$"...");
}

//end balance info stuff

//enable letterboxing for cutscene framing
exec function showletterbox(bool bOn)
{
	if(bOn && !bLetterbox)
	{
		if (letterbox == None)
			letterbox=DeusExRootWindow(rootWindow).NewChild(class'TNMCinematicWindow');
	}
	else if(!bOn && bLetterbox)
	{
		if (letterbox != None)
			letterbox.hide();
	}
	bLetterBox=bOn;
}

//srep (+ 1 2 3) evaluates to 6
exec function srep(string expr)
{
	if(!bCheatsEnabled)
		return;
	Player.Console.AddString(class'tnmLisp'.static.Execute(expr));
}

//based on some dude in the comments section of the news post
exec function chemman()
{
	if(!bCheatsEnabled)
		return;
	CatchFire(Self);
	ClientMessage("You wanted a reference in-game and instead you just got set on fire. Sorry about that.");
}

//travel to the given map, easier than opening the legend menu
exec function travel(string map)
{
	// if(!(right(map,3)~=".dx"))
		// map=map$".dx";
	ClientTravel(map, TRAVEL_Relative, True);
}

//based on the mscallbacktrigger
exec function mscallback(Name ScriptFunction)
{
	local tnmmissionscript scr;

	if (!bCheatsEnabled)
		return;

	foreach allactors(class'tnmmissionscript',scr)
		break;
	if (scr != none)
		scr.HandleGameEvent(ScriptFunction);
	else
		Log("Mission script does not exist");
}

exec function thevoicesaretellingmethings()
{
	if (!bCheatsEnabled)
		return;

	HealthHead=0;
	TakeDamage(0,None,vect(0,0,0),vect(0,0,0),'Insane');
}

exec function brucelee()
{
	if (!bCheatsEnabled)
		return;

	binstagibfists=!binstagibfists;
}

function slomoandpitch(float speed)
{
	class'tnmSoundModifier'.static.On();
	class'tnmSoundModifier'.static.SetPitchMultiplier(speed*0.75+0.25);
	Level.Game.GameSpeed = speed;
	Level.Game.Level.TimeDilation = speed;
	Level.Game.SetTimer(speed, true);
}

exec function lagmonster(float speed)
{
	if (!bCheatsEnabled)
		return;

	slomoandpitch(speed);
}

exec function installwindows()
{
	local TNMComputers comp;
	local ElectronicDevices cash;

	if (!bCheatsEnabled)
		return;

	foreach AllActors(class'TNMComputers',comp)
		if(comp.IsA('TNMMonitor_FS')/* || comp.IsA('TNMLaptopOpen')*/)
			if(rand(2)==1)
				comp.multiskins[2]=Texture(DynamicLoadObject("TNM_Misc_Tex.Misc.BSOD1",class'Texture'));
			else
				comp.multiskins[2]=Texture(DynamicLoadObject("TNM_Misc_Tex.Misc.BSOD2",class'Texture'));

	foreach AllActors(class'ElectronicDevices',cash)
		if(cash.IsA('CashRegister')/* || comp.IsA('TNMLaptopOpen')*/)
			if(rand(2)==1)
			{
				cash.multiskins[3]=Texture(DynamicLoadObject("TNM_Misc_Tex.Misc.BSOD1",class'Texture'));
				cash.multiskins[4]=Texture(DynamicLoadObject("TNM_Misc_Tex.Misc.BSOD1",class'Texture'));
			}
			else
			{
				cash.multiskins[4]=Texture(DynamicLoadObject("TNM_Misc_Tex.Misc.BSOD2",class'Texture'));
				cash.multiskins[3]=Texture(DynamicLoadObject("TNM_Misc_Tex.Misc.BSOD2",class'Texture'));
			}
}

exec function quotes()
{
	bLoadingQuotes = !bLoadingQuotes;
	SaveConfig();
}

exec function burnbabyburn()
{
	local Actor       hitActor;
	local Vector      hitLocation, hitNormal;
	local Vector      position, line;

	if (!bCheatsEnabled)
		return;

	position    = Location;
	position.Z += BaseEyeHeight;
	line        = Vector(ViewRotation) * 4000;

	hitActor = Trace(hitLocation, hitNormal, position+line, position, true);
	if(hitActor!=None)
		Spawn(class'TNMFire', hitActor);
}

exec function rearviewmirror()
{
	if (!bCheatsEnabled)
		return;

	bRearView=!bRearView;
}

exec function iseein2d()
{
	local NetworkTerminal term;

	if (!bCheatsEnabled)
		return;

	term=NetworkTerminal(deusexrootwindow(rootwindow).PushWindow(class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.tnm2DtestNetworkTerminal",class'Class')), True));
	term.ShowFirstScreen();
}

exec function phasrox()
{
	if (!bCheatsEnabled)
		return;

	deusexrootwindow(rootwindow).PushWindow(class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.tnmsummonwindow",class'Class')), True);
}

exec function australianoutback()
{
	if (!bCheatsEnabled)
		return;

	ViewRotation.Roll += 65535/2;
	bAustralian = !bAustralian;
}

exec function miniatureworld()
{
	local actor A;

	if (!bCheatsEnabled)
		return;

	ForEach AllActors(class 'Actor', A)
	{
		A.drawscale *= 0.1;
	}
}

exec function Iamdespot()
{
	if (!bCheatsEnabled)
		return;

	bdespot = true;
}

function float CalculatePlayerVisibility(ScriptedPawn P)
{
	if (bdespot)
		return 0;
	else if (bRingOfShadow)
		return 0;
	else
		return super.CalculatePlayerVisibility(P);
}

exec function IamGwog()
{
	local bool oldbool;
	
	if (!bCheatsEnabled)
		return;

	oldbool = bcheatsenabled;
	bcheatsenabled = true;
	consolecommand("god");
	bcheatsenabled = oldbool;
}

exec function iamSpyGuy()
{
	local bool oldbool;
	
	if (!bCheatsEnabled)
		return;
		
	oldbool = bcheatsenabled;
	bcheatsenabled = true;
	consolecommand("fly");
	consolecommand("ghost");
	bcheatsenabled = oldbool;
}

exec function bignoggin()
{
	clientmessage("Is that an insult?");
}

exec function fonkey()
{
	local ghandsummoned g;

	if (!bCheatsEnabled)
		return;

	g = spawn(class'ghandsummoned',,,Location + (CollisionRadius+class'ghandsummoned'.Default.CollisionRadius+30) * Vector(Rotation) + vect(0,0,1) * 15 );
	g.groundspeed = 1000000;
	g.AccelRate = 5000;
	g.TakeDamage(1,self,vect(0,0,0),vect(0,0,0), 'flamed');
}

exec function iamscarab()
{
	if (!bCheatsEnabled)
		return;

	credits = 100000;
}

exec function iamjonas()
{
	local scriptedpawn s;
	local int i;
	foreach AllActors(class'ScriptedPawn',s)
	{
		s.Mesh=LodMesh'DeusExCharacters.Cat';
		s.SetCollisionSize(17.f*s.drawscale,11.3f*s.drawscale);
		s.WalkingSpeed=0.111111;
		s.GroundSpeed=180;
		s.skin=none;
		s.texture=none;
		for(i=0;i<8;i++)
			s.multiskins[i]=none;
	}
}

exec function iamtrestkon()
{
	local FadeTextWindow winFade;
	local Color colText;

	if (!bCheatsEnabled)
		return;

	coltext.r = 200;
	coltext.g = 0;
	coltext.b = 255;
	winFade = FadeTextWindow(rootwindow.NewChild(Class'FadeTextWindow'));
	winFade.SetText("Joo R a purple radish");
	winFade.SetPos(Max(0, Rand(rootwindow.width) - winFade.Width), Rand(rootwindow.height)-winFade.Height);
	winFade.SetTextColor(colText);
}

// Kills everybody on the map
exec function massban()
{
	local TNMPawn p;
	local TNMRobot r;

	if (!bCheatsEnabled)
		return;

	ForEach AllActors(class 'TNMPawn', p)
	{
		p.HealthTorso = 0;
		p.Health = 0;
		p.bStunned = false;
		p.TakeDamage(1, p, p.Location, vect(0,0,0), 'shot');
	}

	ForEach AllActors(class 'TNMRobot', r)
	{
		r.HealthTorso = 0;
		r.Health = 0;
		r.bStunned = false;
		r.TakeDamage(1, r, r.Location, vect(0,0,0), 'shot');
	}
}

exec function iambogie()
{
	local TNMPawn p;
	
	if (!bCheatsEnabled)
		return;
		
	ForEach AllActors (class 'TNMPawn', p)
	{
		if (p != None)
		{
			p.Mesh=LODMesh'DeusExCharacters.GM_Trench';
			p.MultiSkins[0]=Texture(DynamicLoadObject("TNMCharacters.Skins.BogieTex0", class'Texture'));
			p.MultiSkins[1]=Texture(DynamicLoadObject("TNMCharacters.Skins.BogieTex2", class'Texture'));
			p.MultiSkins[2]=Texture(DynamicLoadObject("TNMCharacters.Skins.BogieTex3", class'Texture'));
			p.MultiSkins[3]=Texture(DynamicLoadObject("TNMCharacters.Skins.BogieTex0", class'Texture'));
			p.MultiSkins[4]=Texture(DynamicLoadObject("TNMCharacters.Skins.BogieTex1", class'Texture'));
			p.MultiSkins[5]=Texture(DynamicLoadObject("TNMCharacters.Skins.BogieTex2", class'Texture'));
			p.MultiSkins[6]=Texture'DeusExCharacters.Skins.GrayMaskTex';
			p.MultiSkins[7]=Texture'DeusExCharacters.Skins.BlackMaskTex';
			p.ChangeAlly('Player', -1, true, false);
			p.UnfamiliarName="Bogie?";
			p.FamiliarName="Bogie!";
			
			ClientMessage("Are you _really_ Bogie?");
			
			bBogieMode=True;
		}
		
		else
		{
			ClientMessage("So you really are Bogie!");
			bBogieMode=False;
		}
	}
}

// Coded by Jonas to make difficulty testing easier
exec function equipme()
{
	local Skill aSkill;

	if (!bCheatsEnabled)
		return;

	// Weapons
	give("weapontnmprod");
	give("weapondoubleguns");
	give("weapontnmassaultgun");
	give("weaponuniquezp");
	give("weapontnmlam");
	give("weapontnmlam");
	give("weapontnmgasgrenade");
	give("weapontnmgasgrenade");
	give("weapontnmempgrenade");
	give("weapontnmempgrenade");
	// Ammo
	give("ammobattery");
	give("ammobattery");
	give("ammobattery");
	give("ammobattery");
	give("ammobattery");
	give("ammobattery");
	give("ammo45");
	give("ammo45");
	give("ammo45");
	give("ammo45");
	give("ammo45");
	give("ammo45");
	give("ammo762mm");
	give("ammo762mm");
	give("ammo762mm");
	give("ammo762mm");
	give("ammo762mm");
	give("ammo762mm");
	give("ammo3006");
	give("ammo3006");
	give("ammo3006");
	// Equipment
	give("multitool");
	give("multitool");
	give("multitool");
	give("multitool");
	give("multitool");
	give("lockpick");
	give("lockpick");
	give("lockpick");
	give("weaponmodsilencer");
	// Powerups
	give("medkit");
	give("medkit");
	give("medkit");
	give("bioelectriccell");
	give("bioelectriccell");
	give("bioelectriccell");
	give("bioelectriccell");
	give("bioelectriccell");

	// Set the skills to something reasonable
	if (SkillSystem != None)
	{
		// Set Computers to Advanced
		aSkill = SkillSystem.GetSkillFromClass(class'SkillComputer');
		if (aSkill != None)
			aSkill.CurrentLevel = 2;

		// Set Rifles to Advanced
		aSkill = SkillSystem.GetSkillFromClass(class'SkillWeaponRifle');
		if (aSkill != None)
			aSkill.CurrentLevel = 2;

		// Set Fists to Trained
		aSkill = SkillSystem.GetSkillFromClass(class'SkillWeaponFists');
		if (aSkill != None)
			aSkill.CurrentLevel = 1;

		// Set Electronics to Trained
		aSkill = SkillSystem.GetSkillFromClass(class'SkillTech');
		if (aSkill != None)
			aSkill.CurrentLevel = 1;

		// Set Lockpicking to Trained
		aSkill = SkillSystem.GetSkillFromClass(class'SkillLockpicking');
		if (aSkill != None)
			aSkill.CurrentLevel = 1;
	}
}

exec function ZPDebug()
{
	if (!bCheatsEnabled)
		return;

	Augadd(class'tnmpcAugCloak');
	Augadd(class'tnmpcAugRadarTrans');
	Augadd(class'tnmpcAugBallistic');
	Augadd(class'tnmpcAugSpeed');
	give("WeaponUniqueZP");
	give("WeaponTNMPistol");
	give("WeaponTNMSawedOffShotgun");
	AllAmmo();
	AllAugs();
	Energy = 1000000;
	AllWeapons();
	AllSkills();
	// MyVisionIsAugmented();
}

exec function displaytext(int x,int y,string text, float LiveTime, float FadeTime, color Color)
{
	local creditsTextWindow winFade;

	// Always display text otherwise it doesn't appear in training (the one thing this was made for?)
	// if (!bCheatsEnabled)
		// return;

	winFade = creditsTextWindow(rootwindow.NewChild(Class'creditsTextWindow'));
	winFade.Init( rootwindow.width/2 + x, rootwindow.height/2 + y, text, LiveTime, FadeTime, Color);
}

function displayimg(int x,int y,Texture tex[2], float LiveTime, float FadeTime)
{
	local creditsImageWindow winFade;

	winFade = creditsImageWindow(rootwindow.NewChild(Class'creditsImageWindow'));
	winFade.Init( rootwindow.width/2 - 256 + x, rootwindow.height/2 - 128 + y, tex[0], LiveTime, FadeTime);
	winFade = creditsImageWindow(rootwindow.NewChild(Class'creditsImageWindow'));
	winFade.Init( rootwindow.width/2 + x, rootwindow.height/2 - 128 + y, tex[1], LiveTime, FadeTime);
}

//to help jonas line up interpolation points -shax
exec function logpos(name tag)
{
	local Actor a;
	local string str;
	local int i;

	if (!bCheatsEnabled)
		return;

	foreach AllActors(Class'Actor',a,tag)
	{
		str="#"$++i@"actor"@tag$"'s location ="@a.Location;
		log(str);
		ClientMessage(str);
	}
}

//------------------------------------------------------------------------------
//that guy's shopping functions
//------------------------------------------------------------------------------

function tryBuy( creditreader reader, bool bHacked)
{
	local actor a;

	weaponshopreader = reader;		

	if (reader.bBought)
		ClientMessage(strTryBuy);
	else
	{
		if ( bHacked )
		{
			if (flagbase.GetBool('WeaponShopAlarmDisabled'))
				reader.Bought();
			else
				reader.Hacked();
		}
		else
		{
			querypurchase();
		}
	}
}

function bool querypurchase()
{
	local deusexrootwindow root;
	root = deusexrootwindow(rootWindow);	
	tnmhud(root.hud).querypurchasewindow = root.MessageBox(querypurchasewindowtitle, sprintf(querypurchasewindowtext,weaponshopreader.cost), 0, False, root.hud);
}


function purchaseitems(int buttonResult)
{
	local Inventory item;
	local mover A;

	if (buttonResult == 0) // chose yes
	{
		if ( credits >= weaponshopreader.cost )
		{
			clientmessage(sprintf(purchasedmessage, weaponshopreader.cost));
			credits -= weaponshopreader.cost;
			weaponshopreader.Bought();
		}
		else
		{
			clientmessage(sprintf(cantpurchasemessage, weaponshopreader.cost));
		}
	}
	else
	{
		clientmessage(notpurchasedmessage);
	}
}


/////////////////////////END OF SHOPPING FUNCTIONS//////////////////////

// ----------------------------------------------------------------------
// DropItem()
//
// throws an item where you are currently looking
// or places it on your currently highlighted object
// if None is passed in, it drops what's inHand
// ----------------------------------------------------------------------

exec function bool DropItem(optional Inventory inv, optional bool bDrop)
{
	local Inventory item;
	local Inventory previousItemInHand;
	local Vector X, Y, Z, dropVect;
	local float size, mult;
	local DeusExCarcass carc;
	local class<DeusExCarcass> carcClass;
	local bool bDropped;
	local bool bRemovedFromSlots;
	local int  itemPosX, itemPosY;
	local int i;

	bDropped = True;

	if (RestrictInput())
		return False;
	
	//Dropping inHand, make it normal.
	if (inv == None && inHand != None)
	{
		inHand.Style = Default.Style;
		inHand.AmbientGlow = Default.AmbientGlow;
		inHand.ScaleGlow = Default.ScaleGlow;
		inHand.Style = Default.Style;
	}

	if (inv == None)
	{
		previousItemInHand = inHand;
		item = inHand;
	}
	else
	{
		item = inv;
	}

	if (item != None)
	{
		GetAxes(Rotation, X, Y, Z);
		dropVect = Location + (CollisionRadius + 2*item.CollisionRadius) * X;
		dropVect.Z += BaseEyeHeight;

		// check to see if we're blocked by terrain
		if (!FastTrace(dropVect))
		{
			ClientMessage(CannotDropHere);
			return False;
		}

		// don't drop it if it's in a strange state
		if (item.IsA('DeusExWeapon'))
		{
			if (!DeusExWeapon(item).IsInState('Idle') && !DeusExWeapon(item).IsInState('Idle2') &&
				!DeusExWeapon(item).IsInState('DownWeapon') && !DeusExWeapon(item).IsInState('Reload'))
			{
				return False;
			}
			else		// make sure the scope/laser are turned off
			{
				DeusExWeapon(item).ScopeOff();
				DeusExWeapon(item).LaserOff();
			}
		}

		// Don't allow active ChargedPickups to be dropped
		if ((item.IsA('ChargedPickup')) && (ChargedPickup(item).IsActive()))
        	{
			return False;
	        }

		// don't let us throw away the nanokeyring
		if (item.IsA('NanoKeyRing'))
        	{
			return False;
	        }
		if (item.IsA('weaponfists'))
		{
			return False;
		}
		if (item.IsA('WeaponFireStaff'))
		{
			if (flagbase.GetBool('QR_MAIN_Firestaff') && !flagbase.GetBool('Firestaff_Decrypted'))
			{
				ClientMessage(strFireStaffDrop);
				return False;
			}
		}


		// take it out of our hand
		if (item == inHand)
			PutInHand(None);

		// handle throwing pickups that stack
		if (item.IsA('DeusExPickup'))
		{
			// turn it off if it is on
			if (DeusExPickup(item).bActive)
				DeusExPickup(item).Activate();

			DeusExPickup(item).NumCopies--;
			UpdateBeltText(item);

			if (DeusExPickup(item).NumCopies > 0)
			{
				// put it back in our hand, but only if it was in our
				// hand originally!!!
				if (previousItemInHand == item)
					PutInHand(previousItemInHand);

				item = Spawn(item.Class, Owner);
			}
			else
			{
				// Keep track of this so we can undo it
				// if necessary
				bRemovedFromSlots = True;
				itemPosX = item.invPosX;
				itemPosY = item.invPosY;

				// Remove it from the inventory slot grid
				RemoveItemFromSlot(item);

				// make sure we have one copy to throw!
				DeusExPickup(item).NumCopies = 1;
			}
		}
		else
		{
			// Keep track of this so we can undo it
			// if necessary
			bRemovedFromSlots = True;
			itemPosX = item.invPosX;
			itemPosY = item.invPosY;

			// Remove it from the inventory slot grid
			RemoveItemFromSlot(item);
		}

		// if we are highlighting something, try to place the object on the target
		if ((FrobTarget != None) && !item.IsA('POVCorpse'))
		{
			item.Velocity = vect(0,0,0);

			// play the correct anim
			PlayPickupAnim(FrobTarget.Location);

			// try to drop the object about one foot above the target
			size = FrobTarget.CollisionRadius - item.CollisionRadius * 2;
			dropVect.X = size/2 - FRand() * size;
			dropVect.Y = size/2 - FRand() * size;
			dropVect.Z = FrobTarget.CollisionHeight + item.CollisionHeight + 16;
			if (FastTrace(dropVect))
			{
				item.DropFrom(FrobTarget.Location + dropVect);
			}
			else
			{
				ClientMessage(CannotDropHere);
				bDropped = False;
			}
		}
		else
		{
			// throw velocity is based on augmentation
			if (AugmentationSystem != None)
			{
				mult = AugmentationSystem.GetAugLevelValue(class'AugMuscle');
				if (mult == -1.0)
					mult = 1.0;
			}

			if (bDrop)
			{
				item.Velocity = VRand() * 30;

				// play the correct anim
				PlayPickupAnim(item.Location);
			}
			else
			{
				item.Velocity = Vector(ViewRotation) * mult * 300 + vect(0,0,220) + 40 * VRand();

				// play a throw anim
				PlayAnim('Attack',,0.1);
			}

			GetAxes(ViewRotation, X, Y, Z);
			dropVect = Location + 0.8 * CollisionRadius * X;
			dropVect.Z += BaseEyeHeight;

			// if we are a corpse, spawn the actual carcass
			if (item.IsA('POVCorpse'))
			{
				if (POVCorpse(item).carcClassString != "")
				{
					carcClass = class<DeusExCarcass>(DynamicLoadObject(POVCorpse(item).carcClassString, class'Class'));
					if (carcClass != None)
					{
						carc = Spawn(carcClass);
						if (carc != None)
						{
							carc.Mesh = carc.Mesh2;
							carc.KillerAlliance = POVCorpse(item).KillerAlliance;
							carc.KillerBindName = POVCorpse(item).KillerBindName;
							carc.Alliance = POVCorpse(item).Alliance;
							carc.bNotDead = POVCorpse(item).bNotDead;
							carc.bEmitCarcass = POVCorpse(item).bEmitCarcass;
							carc.CumulativeDamage = POVCorpse(item).CumulativeDamage;
							carc.MaxDamage = POVCorpse(item).MaxDamage;
							carc.itemName = POVCorpse(item).CorpseItemName;
							carc.CarcassName = POVCorpse(item).CarcassName;
							carc.Velocity = item.Velocity * 0.5;
							item.Velocity = vect(0,0,0);
							carc.bHidden = False;
							carc.SetPhysics(PHYS_Falling);
							carc.SetScaleGlow();
							if (carc.IsA('GenericScubaDiverCarcass') && carc.bNotDead)
								carc.AmbientSound = Sound'RebreatherLoop';
							if (tnmPOVcorpse(item) != None)
								carc.tag = tnmPOVcorpse(item).InheritedTag;
							if (TNMCarcass(carc) != None && tnmPOVcorpse(item) != None)
							{
								TNMCarcass(carc).givenname = tnmPOVcorpse(item).givenname;
								TNMCarcass(carc).givenbindname = tnmPOVcorpse(item).givenbindname;
								TNMCarcass(carc).health = tnmPOVcorpse(item).health;
								TNMCarcass(carc).bImportant = tnmPOVcorpse(item).bImportant;
							}
							if (tnmPOVcorpse(item) != None)
								for ( i=0;i<8;i++)
									carc.multiskins[i] = tnmPOVcorpse(item).InheritedMultiskins[i];
	
							if (TNMCarcass(carc) != None)
							{							
								if (flagBase != None && flagBase.GetBool('QC_SUB_LlamaRescue') && TNMCarcass(carc).GivenBindName == "LlamaHostage")
								{
									carc.bInvincible = True;
									carc.bHighlight = False;
									carc.Velocity = vect(0,0,0);
								}
								else if (flagBase != None && flagBase.GetBool('Kale_DropBody') && TNMCarcass(carc).GivenBindName == "Master_Kale")
								{
									carc.bInvincible = True;
									carc.bHighlight = False;
									carc.Velocity = vect(0,0,0);
								}
							}
							
							if (carc.SetLocation(dropVect))
							{
								// must circumvent PutInHand() since it won't allow
								// things in hand when you're carrying a corpse
								SetInHandPending(None);
								item.Destroy();
								item = None;
							}
							else
							{
								carc.bHidden = True;
								if (TNMCarcass(carc) != None)
									TNMCarcass(carc).CleanBlood();
								carc.Destroy(); //no idea why this wasn't being done.
							}
						}
					}
				}
			}
			else
			{
				if (FastTrace(dropVect))
				{
					item.DropFrom(dropVect);
					item.bFixedRotationDir = True;
					item.RotationRate.Pitch = (32768 - Rand(32767) - Rand(32767)) * 4.0; // Rand is limited to 2^15
					item.RotationRate.Yaw = (32768 - Rand(32767) - Rand(32767)) * 4.0; // Rand is limited to 2^15
				}
			}
		}

		// if we failed to drop it, put it back inHand
		if (item != None)
		{
			if (((inHand == None) || (inHandPending == None)) && (item.Physics != PHYS_Falling))
			{
				PutInHand(item);
				ClientMessage(CannotDropHere);
				bDropped = False;
			}
			else
			{
				item.Instigator = Self;
			}
		}
	}
	else if (CarriedDecoration != None)
	{
		DropDecoration();

		// play a throw anim
		PlayAnim('Attack',,0.1);
	}

	// If the drop failed and we removed the item from the inventory
	// grid, then we need to stick it back where it came from so
	// the inventory doesn't get fucked up.

	if ((bRemovedFromSlots) && (item != None) && (!bDropped))
	{
        //DEUS_EX AMSD Use the function call for this, helps multiplayer
        PlaceItemInSlot(item, itemPosX, itemPosY);
	}	
		
	//If dropped, make it normal again.
	if (bDropped)
		if (inv != None)
			inv.Style = Default.Style;

	return bDropped;
}

// ----------------------------------------------------------------------
// CreateThemeManager()
// ----------------------------------------------------------------------

simulated function CreateColorThemeManager()
{
	if (ThemeManager == None)
	{
		ThemeManager = Spawn(Class'ColorThemeManager', Self);

		// Add all default themes.

		// Menus
		ThemeManager.AddTheme(class<ColorThemeMenu>(DynamicLoadObject("TNMGUI.ColorThemeMenu_TNM",class'Class')));
		ThemeManager.AddTheme(class<ColorThemeMenu>(DynamicLoadObject("TNMGUI.ColorThemeMenu_WorldCorp",class'Class')));
		ThemeManager.AddTheme(class<ColorThemeMenu>(DynamicLoadObject("TNMGUI.ColorThemeMenu_RevisionBlue",class'Class')));
		ThemeManager.AddTheme(class<ColorThemeMenu>(DynamicLoadObject("TNMGUI.ColorThemeMenu_RevisionSlate",class'Class')));
		ThemeManager.AddTheme(class<ColorThemeMenu>(DynamicLoadObject("TNMGUI.ColorThemeMenu_DeusExDefault",class'Class')));
		ThemeManager.AddTheme(Class'ColorThemeMenu_Default');
		ThemeManager.AddTheme(Class'ColorThemeMenu_BlueAndGold');
		ThemeManager.AddTheme(Class'ColorThemeMenu_CoolGreen');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Cops');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Cyan');
		ThemeManager.AddTheme(Class'ColorThemeMenu_DesertStorm');
		ThemeManager.AddTheme(Class'ColorThemeMenu_DriedBlood');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Dusk');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Earth');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Green');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Grey');
		ThemeManager.AddTheme(Class'ColorThemeMenu_IonStorm');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Lava');
		ThemeManager.AddTheme(Class'ColorThemeMenu_NightVision');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Ninja');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Olive');
		ThemeManager.AddTheme(Class'ColorThemeMenu_PaleGreen');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Pastel');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Plasma');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Primaries');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Purple');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Red');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Seawater');
		ThemeManager.AddTheme(Class'ColorThemeMenu_SoylentGreen');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Starlight');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Steel');
		ThemeManager.AddTheme(Class'ColorThemeMenu_SteelGreen');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Superhero');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Terminator');
		ThemeManager.AddTheme(Class'ColorThemeMenu_Violet');

		// HUD
		ThemeManager.AddTheme(class<ColorThemeHUD>(DynamicLoadObject("TNMGUI.ColorThemeHUD_TNM",class'Class')));
		ThemeManager.AddTheme(class<ColorThemeHUD>(DynamicLoadObject("TNMGUI.ColorThemeHUD_WorldCorp",class'Class')));
		ThemeManager.AddTheme(class<ColorThemeHUD>(DynamicLoadObject("TNMGUI.ColorThemeHUD_PDX",class'Class')));
		ThemeManager.AddTheme(class<ColorThemeHUD>(DynamicLoadObject("TNMGUI.ColorThemeHUD_RevisionBlue",class'Class')));
		ThemeManager.AddTheme(class<ColorThemeHUD>(DynamicLoadObject("TNMGUI.ColorThemeHUD_RevisionSlate",class'Class')));
		ThemeManager.AddTheme(class<ColorThemeHUD>(DynamicLoadObject("TNMGUI.ColorThemeHUD_DeusExDefault",class'Class')));
		ThemeManager.AddTheme(Class'ColorThemeHUD_Default');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Amber');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Cops');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Cyan');
		ThemeManager.AddTheme(Class'ColorThemeHUD_DarkBlue');
		ThemeManager.AddTheme(Class'ColorThemeHUD_DesertStorm');
		ThemeManager.AddTheme(Class'ColorThemeHUD_DriedBlood');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Dusk');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Grey');
		ThemeManager.AddTheme(Class'ColorThemeHUD_IonStorm');
		ThemeManager.AddTheme(Class'ColorThemeHUD_NightVision');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Ninja');
		ThemeManager.AddTheme(Class'ColorThemeHUD_PaleGreen');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Pastel');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Plasma');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Primaries');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Purple');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Red');
		ThemeManager.AddTheme(Class'ColorThemeHUD_SoylentGreen');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Starlight');
		ThemeManager.AddTheme(Class'ColorThemeHUD_SteelGreen');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Superhero');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Terminator');
		ThemeManager.AddTheme(Class'ColorThemeHUD_Violet');
	}
}

function InitializeSubSystems()
{	
	// Spawn the BarkManager
	if (BarkManager == None)
		BarkManager = Spawn(class'TNMBarkManager', Self);

	// Spawn the Color Manager
	CreateColorThemeManager();
	ThemeManager.SetOwner(self);

	// install the augmentation system if not found
	if (AugmentationSystem == None)
	{
		AugmentationSystem = Spawn(class'tnmAugmentationManager', Self);
		AugmentationSystem.CreateAugmentations(Self);
		AugmentationSystem.AddDefaultAugmentations();
		AugmentationSystem.SetOwner(Self);
	}
	else
	{
		AugmentationSystem.SetPlayer(Self);
        AugmentationSystem.SetOwner(Self);
	}

	// install the skill system if not found
	if (SkillSystem == None)
	{
		SkillSystem = Spawn(class'tnmSkillManager', Self);
		SkillSystem.CreateSkills(Self);
		SkillSystem.SetOwner(Self);
	}
	else
	{
		SkillSystem.SetPlayer(Self);
		SkillSystem.SetOwner(Self);
	}

	CreateATMAccountManager();
	if (ATMAccountManager != None)
		ATMAccountManager.SetOwner(Self);

   	if (Level.Netmode == NM_Standalone || !bBeltIsMPInventory)
   	{
      	// Give the player a keyring
      	CreateKeyRing();
	}
}

simulated function EnsureClientUI()
{
	local deusexrootwindow root;
	local tnmscopeview scope;
	local LevelInfo entryLvl;
	local Trestkon entryPawn;
	local PrecipitationNode precipNode;

	bJustTraveled = False;
	bBeltIsMPInventory = False;

	if (Outer.Name == 'Entry' || Viewport(Player) == None)
	{
		if (rootWindow != None)
			rootWindow.Destroy();
		return;
	}

	entryLvl = GetEntryLevel();
	if (entryLvl != None && entryLvl != Level)
	{
		foreach entryLvl.AllActors(class'Trestkon', entryPawn)
		{
			if (entryPawn != Self)
			{
				if (entryPawn.rootWindow != None)
					entryPawn.rootWindow.Destroy();
				entryPawn.Destroy();
			}
		}
	}

	foreach AllActors(class'Trestkon', entryPawn)
	{
		if (entryPawn != Self && entryPawn.rootWindow != None)
			entryPawn.rootWindow.Destroy();
	}

	if (rootWindow == None)
		InitRootWindow();

	root = deusexrootwindow(rootWindow);
	if (root == None)
		return;

	if (ThemeManager == None)
	{
		CreateColorThemeManager();
		if (ThemeManager != None)
			ThemeManager.SetOwner(Self);
	}
	if (ThemeManager != None)
	{
		if (ThemeManager.GetCurrentHUDColorTheme() == None)
		{
			ThemeManager.SetHUDThemeByName(HUDThemeName);
			if (ThemeManager.GetCurrentHUDColorTheme() == None)
				ThemeManager.SetHUDThemeByName("TNM");
		}
		if (ThemeManager.GetCurrentMenuColorTheme() == None)
		{
			ThemeManager.SetMenuThemeByName(MenuThemeName);
			if (ThemeManager.GetCurrentMenuColorTheme() == None)
				ThemeManager.SetMenuThemeByName("TNM");
		}
	}

	if (!bClientUIInitialized || tnmHUD(root.hud) == None)
	{
		bClientUIInitialized = True;

		//change menus
		root.DataVaultFunctions[0].winClass=Class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.tnmPersonaScreenInventory", class'Class'));
		root.DataVaultFunctions[1].winClass=Class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.tnmPersonaScreenHealth", class'Class'));
		root.DataVaultFunctions[2].winClass=Class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.tnmPersonaScreenAugmentations", class'Class'));
		root.DataVaultFunctions[3].winClass=Class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.tnmPersonaScreenSkills", class'Class'));
		root.DataVaultFunctions[4].winClass=Class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.tnmPersonaScreenGoals", class'Class'));
		root.DataVaultFunctions[5].winClass=Class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.tnmPersonaScreenConversations", class'Class'));
		root.DataVaultFunctions[6].winClass=Class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.tnmPersonaScreenImages", class'Class'));
		root.DataVaultFunctions[7].winClass=Class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.tnmPersonaScreenLogs", class'Class'));

		//change hud
		if (root.hud != None)
			root.hud.destroy();
		root.hud = deusexHUD(root.NewChild(Class'tnmHUD'));
		root.hud.UpdateSettings(self);
		root.hud.SetWindowAlignments(HALIGN_Full, VALIGN_Full, 0, 0);

		//change scope
		if (root.scopeview != None)
			root.scopeview.destroy();
		root.scopeview = deusexscopeview(root.NewChild(class'tnm.tnmscopeview', False));
		scope = tnmscopeview(root.scopeview);
		if (scope == none)
			LOG("Scope window missing");
		else
		{
			scope.SetWindowAlignments(HALIGN_Full, VALIGN_Full, 0, 0);
			scope.Lower();
		}

		root.ChangeStyle();
		ShowHud(True);
		root.UpdateHud();
		if (root.hud != None && root.hud.belt != None)
			root.hud.belt.PopulateBelt();
		if (Level.NetMode == NM_Client)
		{
			foreach AllActors(class'PrecipitationNode', precipNode)
			{
				if (precipNode.ControllingZone == None && precipNode.GetStateName() != 'broken')
					precipNode.GotoState('broken');
			}
		}
		log("CoopMod UI Initialized for " $ Self $ " (NetMode=" $ Level.NetMode $ ", hud=" $ root.hud $ ", HUDTheme=" $ ThemeManager.GetCurrentHUDColorTheme() $ ")");
	}
}

simulated function PostNetBeginPlay()
{
	if (ThemeManager == None)
	{
		CreateColorThemeManager();
		if (ThemeManager != None)
			ThemeManager.SetOwner(Self);
	}
	Super.PostNetBeginPlay();
	if (ThemeManager != None)
	{
		ThemeManager.SetHUDThemeByName(HUDThemeName);
		ThemeManager.SetMenuThemeByName(MenuThemeName);
	}
	bJustTraveled = False;
	bBeltIsMPInventory = False;
	EnsureClientUI();
}

simulated event PreRender(Canvas Canvas)
{
	if (rootWindow == None || Outer.Name == 'Entry')
	{
		Super(PlayerPawn).PreRender(Canvas);
		return;
	}
	Super.PreRender(Canvas);
}

simulated event PostRenderFlash(Canvas Canvas)
{
	if (rootWindow == None || Outer.Name == 'Entry')
	{
		Super(PlayerPawn).PostRenderFlash(Canvas);
		return;
	}
	Super.PostRenderFlash(Canvas);
}

simulated function possess()
{
	local deusexrootwindow root;

	bJustTraveled = False;
	bBeltIsMPInventory = False;
	Song = None;

	if (Outer.Name == 'Entry' || Viewport(Player) == None)
	{
		if (rootWindow != None)
			rootWindow.Destroy();
		Super(PlayerPawn).Possess();
		Song = None;
		ClientSetMusic(None, 0, 255, MTRAN_Instant);
		return;
	}

	super.possess();
	Song = None;
	ClientSetMusic(None, 0, 255, MTRAN_Instant);
	EnsureClientUI();
	root = deusexrootwindow(rootwindow);
	if (root != None)
	{
		root.ChangeStyle();
		ShowHud(True);
		root.UpdateHud();
	}
	if (Viewport(Player) != None)
		EnsureCoopHUDWindows();
}

simulated function ShowProgress()
{
	local DeusExRootWindow root;

	if (bCoopPendingConnect || Level.LevelAction == LEVACT_Connecting)
	{
		root = DeusExRootWindow(rootWindow);
		if (root != None && CoopConnectingWindow(root.GetTopWindow()) == None)
			root.PushWindow(Class'CoopConnectingWindow', True, True);
		return;
	}

	if (Level.NetMode != NM_Standalone)
	{
		if (Level.NetMode == NM_Client && rootWindow != None)
			rootWindow.Destroy();
		return;
	}
	Super.ShowProgress();
}

exec function StartNewGame(string map)
{
	local Inventory item, nextItem;

	class'tnmGameInfo'.static.ClearCoopSessionDefaults();
	
	if (DeusExRootWindow(rootWindow) != None)
		DeusExRootWindow(rootWindow).ClearWindowStack();

	// Set a flag designating that we're traveling,
	// so MissionScript can check and not call FirstFrame() for this map.
	flagBase.SetBool('PlayerTraveling', True, True, 0);

	if(KeyRing != None)
		KeyRing.RemoveAllKeys();

	for(item = Inventory; item != None; item = nextItem)
	{
		nextItem = item.Inventory;
		item.Destroy();
	}
	
	if (Left(map, 2) == "97")
	{
		ResetPlayer(True);
		SkillSystem.ResetSkills();
		
		// Only glitches when the player is dead, let's make them technically not.
		if (IsInState('Dying')) 
			GotoState('PlayerWalking');
	}
	else
	{
		SaveSkillPoints();
		ResetPlayer();
	}
	
	DeleteSaveGameFiles();

	bStartingNewGame = True;
	platform(false);
	
	// Transient, always deleted
	if (irc_link != None)
		irc_link.ServerQuit(QR_Loading);

	// Send the player to the specified map!
	if (Map == "")
		Level.Game.SendPlayer(Self, strStartMap);		// TODO: Must be stored somewhere!
	else
		Level.Game.SendPlayer(Self, Map);
}

// ----------------------------------------------------------------------
// PostIntro()
// ----------------------------------------------------------------------

function PostIntro()
{
	if (bStartNewGameAfterIntro)
	{
		bStartNewGameAfterIntro = False;
		StartNewgame(strStartMap);
	}
	else
	{
		// Transient, always deleted
		if (irc_link != None)
			irc_link.ServerQuit(QR_Loading);
		Level.Game.SendPlayer(Self, "tnmonly");
	}
}

//Technically does the same thing as postintro when called during an outro but for the sake of correct naming
function PostOutro()
{
	//called from showmainmenu and AbortCinematicConvo() in tnmConWindowActive
	local tnmmission25 script;
	
	if ( left(CurrentMap(), 10) ~= "tnmendgame" )
	{
		foreach allactors(class'tnmmission25', script)
			break;
		script.RollCredits();
		if ( conPlay != none ) //it seems like conPlay sometimes exists and sometimes doesn't so added this to prevent accessed none warnings
		{
			conPlay.StopSpeech();
			conplay.Destroy(); //Huge hack but I have no idea how the conversation is even still running
		}
		CurrentCam.EndCinematic();
		// SetInstantSoundVolume(0); //todo - see if this will cause problems
	}
	else if ( CurrentMap() ~= "TNMDenouement" || CurrentMap() ~= "TNMDenouement_2009" )
	{
		// Transient, always deleted
		if (irc_link != None)
			irc_link.ServerQuit(QR_Loading);
		Level.Game.SendPlayer(Self, "tnmonly");
	}
	else
	{
		// Transient, always deleted
		if (irc_link != None)
			irc_link.ServerQuit(QR_Loading);
		Level.Game.SendPlayer(Self, "tnmdenouement");
	}
}

// ----------------------------------------------------------------------
// RestrictInput()
// ----------------------------------------------------------------------

simulated function bool RestrictInput()
{
	local DeusExLevelInfo info;

	info = GetLevelInfo();

	if ( (Level.NetMode == NM_Standalone) && bJustTraveled )
		return true;

	if(info!=none && (info.mapname~="tnmdenouement" || left(info.mapname,10)~="tnmendgame"))
		return true;
		
	if (flagBase != None && flagbase.GetBool('StealthComplete'))
		return true;

	return (IsInState('Interpolating') || (conPlay != None && !conPlay.con.bFirstPerson));
}

// ----------------------------------------------------------------------
// ShowMainMenu()
// ----------------------------------------------------------------------

simulated exec function ShowMainMenu()
{
	local DeusExRootWindow root;
	local DeusExLevelInfo info;
	local MissionEndgame Script;

	if (bIgnoreNextShowMenu)
	{
		bIgnoreNextShowMenu = False;
		return;
	}

	info = GetLevelInfo();

	// Special case baby!
	//
	// If the Intro map is loaded and we get here, that means the player
	// pressed Escape and we want to either A) start a new game
	// or B) return to the dx.dx screen.  Either way we're going to
	// abort the Intro by doing this.
	//
	// If this is one of the Endgames (which have a mission # of 99)
	// then we also want to call the Endgame's "FinishCinematic"
	// function

	// force the texture caches to flush
	ConsoleCommand("FLUSH");

	if ((info != None) && (info.MapName ~= "tnmintro" || info.MapName ~= "tnmintro_2009"))
	{
		bIgnoreNextShowMenu = True;
		PostIntro();
	}
	else if ( bCinematic && TCAM != None && TCAM.Interuptable)
	{
		Endcinematic();
		return;
	}
	else if (info!=none && (info.mapname~="TNMDenouement" || info.mapname~="TNMDenouement_2009" || left(info.mapname,10)~="tnmendgame"))
	{
		bIgnoreNextShowMenu = True;
//		Level.Game.SendPlayer(Self, "tnmonly");
		PostOutro();
	}
	else if ((info != None) && (info.MissionNumber == 99))
	{
		foreach AllActors(class'MissionEndgame', Script)
			break;

		if (Script != None)
			Script.FinishCinematic();
	}
	else
	{
		root = DeusExRootWindow(rootWindow);
		if (root != None)
		{
			if ( Info != None && (Caps(Info.mapName) == "TNMONLY" || Caps(Info.mapName) == "TNMONLY_2009" || Caps(Info.mapName) == "TNM" || Caps(Info.mapName) == "TNM_2009") )
			{
				root.InvokeMenu(Class<DeusExBaseWindow>(dynamicloadobject("TNMGUI.tnmMenuMain", class'class')));
				InjectCoopMainMenuButton(MenuUIMenuWindow(root.GetTopWindow()));
			}
			else
			{
				root.InvokeMenu(Class<DeusExBaseWindow>(dynamicloadobject("TNMGUI.tnmMenuMainInGame", class'class')));
				if (MenuUIMenuWindow(root.GetTopWindow()) != None && MenuUIMenuWindow(root.GetTopWindow()).winButtons[4] != None)
				{
					MenuUIMenuWindow(root.GetTopWindow()).winButtons[4].SetButtonText("Character Model");
					MenuUIMenuWindow(root.GetTopWindow()).winButtons[4].SetSensitivity(True);
					MenuUIMenuWindow(root.GetTopWindow()).buttonDefaults[4].action = MA_MenuScreen;
					MenuUIMenuWindow(root.GetTopWindow()).buttonDefaults[4].invoke = Class'NarcissusWindow';
				}
				if (Level.NetMode != NM_Standalone && MenuUIMenuWindow(root.GetTopWindow()) != None)
				{
					if (MenuUIMenuWindow(root.GetTopWindow()).winButtons[1] != None)
					{
						MenuUIMenuWindow(root.GetTopWindow()).winButtons[1].SetSensitivity(True);
						MenuUIMenuWindow(root.GetTopWindow()).buttonDefaults[1].action = MA_MenuScreen;
						MenuUIMenuWindow(root.GetTopWindow()).buttonDefaults[1].invoke = Class'CoopSaveMenuWindow';
					}
					if (MenuUIMenuWindow(root.GetTopWindow()).winButtons[2] != None)
					{
						MenuUIMenuWindow(root.GetTopWindow()).winButtons[2].SetSensitivity(True);
						MenuUIMenuWindow(root.GetTopWindow()).buttonDefaults[2].action = MA_MenuScreen;
						MenuUIMenuWindow(root.GetTopWindow()).buttonDefaults[2].invoke = Class'CoopLoadMenuWindow';
					}
				}
			}
		}
	}
}


exec function showhoverbot()
{
	local deusexrootwindow root;

	if (!bCheatsEnabled)
		return;

	root = DeusExRootWindow(rootWindow);
	ConsoleCommand("ShowClass "$"tnm.hoverbot");
	if (root != None)
		if (root.actorDisplay != None)
		{
			root.actorDisplay.ShowState(true);
			root.actorDisplay.ShowCylinder(true);
		}
}


// ----------------------------------------------------------------------
// StartTrainingMission()
// ----------------------------------------------------------------------

function StartTrainingMission()
{
	if (DeusExRootWindow(rootWindow) != None)
		DeusExRootWindow(rootWindow).ClearWindowStack();

	// Make sure the player isn't asked to do this more than
	// once if prompted on the main menu.
	if (!bAskedToTrain)
	{
		bAskedToTrain = True;
		SaveConfig();
	}
		
	// If we already have an account manager and are going to training, then kill it because we need a new one
	if (ATMAccountManager != None)
		ATMAccountManager.Destroy();
	ATMAccountManager = None;

	SkillSystem.ResetSkills();
	ResetPlayer(True);
	DeleteSaveGameFiles();
	bStartingNewGame = True;
	// Transient, always deleted
	if (irc_link != None)
		irc_link.ServerQuit(QR_Loading);
	Level.Game.SendPlayer(Self, "25_TNMTraining");
}


exec function Fire(optional float F)
{
	local tnmzoneinfo z;
	if (Level.NetMode == NM_Client)
	{
		if (bClientHasConChoices && clientConChoiceCount > 0)
		{
			ConfirmClientConChoice(clientSelectedConChoice);
			return;
		}
		if (Level.TimeSeconds - lastConChoiceConfirmTime < 0.35)
			return;
	}
	z = tnmzoneinfo(headregion.zone);
	if ((z != none)&&(z.bnofirezone == true))
		clientmessage(z.nofiremessage);
	else
		super.fire(F);
		
	if (bPlatformer && rh != None && Weapon != None)
	{
		if (TNMWeapon(Weapon).AmmoType != None && TNMWeapon(Weapon).AmmoType != Class'AmmoNone' && TNMWeapon(Weapon).AmmoName != Class'AmmoNone')
			rh.ShowRadishWeaponMessage(TNMWeapon(Weapon).ItemName, string(TNMWeapon(Weapon).AmmoType.AmmoAmount));
		else
			rh.ShowRadishWeaponMessage(TNMWeapon(Weapon).ItemName, "INF");
	}

//	Endcinematic();
}

// ----------------------------------------------------------------------
// ShowIntro()
// ----------------------------------------------------------------------

function ShowIntro(optional bool bStartNewGame)
{
	if (DeusExRootWindow(rootWindow) != None)
		DeusExRootWindow(rootWindow).ClearWindowStack();

//	SkillSystem.ResetSkills(); //woops shouldn't do this
	ResetPlayer(False);
	DeleteSaveGameFiles();
	bStartingNewGame = True;
	Platform(False);

	bStartNewGameAfterIntro = bStartNewGame;
		
	// Only glitches when the player is dead, let's make them technically not.
	if (IsInState('Dying')) 
		GotoState('PlayerWalking');
	// Transient, always deleted
	if (irc_link != None)
		irc_link.ServerQuit(QR_Loading);

	if (bunrealistic)
		Level.Game.SendPlayer(Self, strstartmapunrealistic);
	else
		Level.Game.SendPlayer(Self, strstartintromap);
}

// ----------------------------------------------------------------------
// StartDataLinkTransmission()
//
// Locates and starts the DataLink passed in
// ----------------------------------------------------------------------

function Bool StartDataLinkTransmission(
	String datalinkName,
	Optional DataLinkTrigger datalinkTrigger)
{
	local Conversation activeDataLink;
	local bool bDataLinkPlaySpawned;
	local Pawn P;
	local Trestkon T, HostPlayer;

	// Don't allow DataLinks to start if we're in PlayersOnly mode
	if ( Level.bPlayersOnly )
		return False;

	if((flagBase != None && flagBase.GetBool(SafeStringToName(datalinkName $ "_Played"))) || flagBase == None)
		return false;

	if (Level.NetMode != NM_Standalone && Role == ROLE_Authority && DeusExRootWindow(rootWindow) == None)
	{
		ClientPlayDataLink(datalinkName);
		HostPlayer = Trestkon(GetPlayerPawn());
		if (HostPlayer != None && HostPlayer != Self)
			return HostPlayer.StartDataLinkTransmission(datalinkName, datalinkTrigger);
		return True;
	}

	activeDataLink = GetActiveDataLink(datalinkName);

	if ( activeDataLink != None )
	{
		// Search to see if there's an active DataLinkPlay object 
		// before creating one

		if ( dataLinkPlay == None )
		{
			datalinkPlay = Spawn(class'tnmDataLinkPlay');
			bDataLinkPlaySpawned = True;
		}

		// Call SetConversation(), which returns
		if (datalinkPlay.SetConversation(activeDataLink))
		{
			datalinkPlay.SetTrigger(datalinkTrigger);

			if (datalinkPlay.StartConversation(Self))
			{
				if (Level.NetMode != NM_Standalone && Role == ROLE_Authority)
				{
					for (P = Level.PawnList; P != None; P = P.NextPawn)
					{
						T = Trestkon(P);
						if (T != None && T != Self && NetConnection(T.Player) != None)
							T.ClientPlayDataLink(datalinkName);
					}
				}
				return True;
			}
			else
			{
				// Datalink must already be playing, or in queue
				if (bDataLinkPlaySpawned)
				{
					datalinkPlay.Destroy();
					datalinkPlay = None;
				}

				return False;
			}
		}
		else
		{
			// Datalink must already be playing, or in queue
			if (bDataLinkPlaySpawned)
			{
				datalinkPlay.Destroy();
				datalinkPlay = None;
			}
			return False;
		}
	}
	else
	{
		return False;
	}
}

function EndConversation()
{
	local DeusExLevelInfo info;
	local Pawn P;
	local Trestkon T;

	if (Level.NetMode != NM_Standalone)
	{
		for (P = Level.PawnList; P != None; P = P.NextPawn)
		{
			T = Trestkon(P);
			if (T != None)
			{
				if (T.bClientInThirdPersonConvo)
				{
					T.bClientInThirdPersonConvo = False;
					T.clientConvoTarget = None;
					T.ConversationActor = None;
					T.MakePlayerIgnored(False);
				}
				if (NetConnection(T.Player) != None)
					T.ClientHideSubtitle();
			}
		}
	}

	Super(PlayerPawnExt).EndConversation();

	// If we're in a bForcePlay (cinematic) conversation,
	// force the CinematicWindow to be displayd
	// NO NO NO -Nick
	if (/*(conPlay != None) && (conPlay.GetForcePlay())*/bLetterBox)
	{
		if (DeusExRootWindow(rootWindow) != None)
			DeusExRootWindow(rootWindow).NewChild(class'TNMCinematicWindow');
	}

	conPlay = None;

	// Check to see if we need to resume any DataLinks that may have
	// been aborted when we started this conversation
	ResumeDataLinks();

	StopBlendAnims();

	// We might already be dead at this point (someone drop a LAM before
	// entering the conversation?) so we want to make sure the player
	// doesn't suddenly jump into a non-DEATH state.
	//
	// Also make sure the player is actually in the Conversation state
	// before attempting to kick him out of it.

	if ((Health > 0) && ((IsInState('Conversation')) || (IsInState('FirstPersonConversation')) || (NextState == 'Interpolating')))
	{
		if (NextState == '')
			GotoState('PlayerWalking');
		else
			GotoState(NextState);
	}
}

function bool StartAIBarkConversation(Actor conOwner, EBarkModes barkMode)
{
	local Trestkon HostPlayer;

	if (Level.NetMode != NM_Standalone && Role == ROLE_Authority && DeusExRootWindow(rootWindow) == None)
	{
		HostPlayer = Trestkon(GetPlayerPawn());
		if (HostPlayer != None && HostPlayer != Self)
			return HostPlayer.StartAIBarkConversation(conOwner, barkMode);
		return False;
	}
	return Super.StartAIBarkConversation(conOwner, barkMode);
}

function bool CheckConversationInvokeRadius(Actor invokeActor, Conversation con)
{
	local Pawn P;
	local Trestkon T;
	local int invokeRadius;

	if (invokeActor == None || con == None)
		return False;

	if (Level.NetMode != NM_Standalone)
	{
		if (con.radiusDistance == 0)
			invokeRadius = 300;
		else
			invokeRadius = con.radiusDistance;

		for (P = Level.PawnList; P != None; P = P.NextPawn)
		{
			T = Trestkon(P);
			if (T != None && T.Health > 0 && VSize(T.Location - invokeActor.Location) <= invokeRadius)
				return True;
		}
		return False;
	}

	return Super.CheckConversationInvokeRadius(invokeActor, con);
}

function Conversation GetActiveConversation( Actor invokeActor, EInvokeMethod invokeMethod )
{
	local ConListItem conListItem;
	local Conversation con;
	local Name flagName;
	local bool bAbortConversation;

	if ((invokeActor == None) || (flagBase == None))
		return None;

	bAbortConversation = True;

	if ((invokeActor.LastConEndTime != 0) && 
		((Level.TimeSeconds - invokeActor.LastConEndTime) < 1.0))
		return None;

	conListItem = ConListItem(invokeActor.ConListItems);

	while ( conListItem != None )
	{
		con = conListItem.con;

		bAbortConversation = False;

		if (Left(con.conName, Len(con.conOwnerName) + 5) == (con.conOwnerName $ "_Bark"))
			bAbortConversation = True;

		if (!bAbortConversation)
		{
			switch( invokeMethod )
			{
				case IM_Bump:
				case IM_Frob:
					bAbortConversation = !(con.bInvokeFrob || con.bInvokeBump);
					break;

				case IM_Sight:
					bAbortConversation = !con.bInvokeSight;
					break;

				case IM_Radius:
					if ( con.bInvokeRadius )
					{
						bAbortConversation = !CheckConversationInvokeRadius(invokeActor, con);

						if ((!bAbortConversation) && 
						    ((Level.TimeSeconds - lastThirdPersonConvoTime) < 10) && 
						    (lastThirdPersonConvoActor == invokeActor))
							bAbortConversation = True;
						
						if ((!bAbortConversation) && (con.lastPlayedTime > 0))
							bAbortConversation = ((Level.TimeSeconds - con.lastPlayedTime) < 10);

						if ((!bAbortConversation) &&
						    ((Level.TimeSeconds - lastFirstPersonConvoTime) < 5) && 
							(lastFirstPersonConvoActor == invokeActor))
							bAbortConversation = True;
					}
					else
					{
						bAbortConversation = True;
					}
					break;

				case IM_Other:
				default:
					break;
			}
		}

		if (!bAbortConversation && Level.NetMode == NM_Standalone)
		{
			bAbortConversation = !CheckConversationHeightDifference(invokeActor, 20);
			
			if (bAbortConversation)
				bAbortConversation = !CanActorSeePlayer(invokeActor);
		}

		if (( !bAbortConversation ) && ( con.bDisplayOnce ))
		{
			flagName = SafeStringToName(con.conName $ "_Played");		
			bAbortConversation = (flagBase.GetBool(flagName) == True);
		}

		if ( !bAbortConversation )
		{
			bAbortConversation = !CheckFlagRefs(con.flagRefList);
		}

		if ( !bAbortConversation )
			break;
	
		conListItem = conListItem.next;
	}

	if (bAbortConversation)
		return None;
	else
		return con;
}

function CheckActiveConversationRadius()
{
	local int checkRadius;
	local Pawn P;
	local Trestkon T;
	local bool bAnyInRange;

	if ((conPlay != None) && (!conPlay.GetForcePlay()) && (conPlay.ConversationStarted()) && (conPlay.displayMode == DM_FirstPerson) && (conPlay.StartActor != None))
	{
		if (conPlay.con.bInvokeRadius) 
			checkRadius = (2 * conPlay.con.radiusDistance) + 100;
		else
			checkRadius = 600;

		checkRadius += conPlay.StartActor.CollisionRadius;

		if (Level.NetMode != NM_Standalone)
		{
			for (P = Level.PawnList; P != None; P = P.NextPawn)
			{
				T = Trestkon(P);
				if (T != None && VSize(conPlay.startActor.Location - T.Location) <= checkRadius)
				{
					bAnyInRange = True;
					break;
				}
			}
			if (!bAnyInRange)
				conPlay.TerminateConversation(True);
		}
		else if (VSize(conPlay.startActor.Location - Location) > checkRadius)
		{
			conPlay.TerminateConversation(True);
		}
	}
}

function bool CheckActorDistances()
{
	local Trestkon activePlayer;

	if (Level.NetMode != NM_Standalone)
	{
		if ((conPlay != None) && (!conPlay.GetForcePlay()) && (conPlay.ConversationStarted()) && (conPlay.displayMode == DM_ThirdPerson) && (conPlay.startActor != None))
		{
			if (tnmConPlay(conPlay) != None)
				activePlayer = tnmConPlay(conPlay).ResolveCoopPlayer();
			if (activePlayer != None && VSize(activePlayer.Location - conPlay.startActor.Location) > 550.0)
				conPlay.TerminateConversation(True);
		}
		return True;
	}
	return Super.CheckActorDistances();
}

function bool StartConversationByByteMethod(Actor invokeActor, byte invokeMethodByte, optional Conversation con, optional bool bAvoidState, optional bool bForcePlay)
{
	switch (invokeMethodByte)
	{
		case 0: return StartConversation(invokeActor, IM_Other, con, bAvoidState, bForcePlay);
		case 1: return StartConversation(invokeActor, IM_Frob, con, bAvoidState, bForcePlay);
		case 2: return StartConversation(invokeActor, IM_Radius, con, bAvoidState, bForcePlay);
		case 3: return StartConversation(invokeActor, IM_Sight, con, bAvoidState, bForcePlay);
		case 4: return StartConversation(invokeActor, IM_Bump, con, bAvoidState, bForcePlay);
		default: return StartConversation(invokeActor, IM_Named, con, bAvoidState, bForcePlay);
	}
}

function bool StartConversation(
	Actor invokeActor,
	EInvokeMethod invokeMethod,
	optional Conversation con,
	optional bool bAvoidState,
	optional bool bForcePlay
	)
{

	local DeusExRootWindow root;
	local Trestkon HostPlayer, T, BestT;
	local float bestDist, d;

	if (Level.NetMode == NM_Client)
		return False;

	root = DeusExRootWindow(rootWindow);
	if ((root == None || Viewport(Player) == None) && Level.NetMode != NM_Standalone && Role == ROLE_Authority)
	{
		HostPlayer = Trestkon(GetPlayerPawn());
		if (HostPlayer != None && HostPlayer != Self)
		{
			if (HostPlayer.flagBase != None && flagBase != None)
			{
				SyncFromPlayer(HostPlayer);
				HostPlayer.SyncFromPlayer(Self);
			}
			BindName = "JCDenton";
			if (con == None)
			{
				if (!bForcePlay && invokeActor != None && invokeActor.conListItems == None)
					return False;
				if (!bForcePlay && ScriptedPawn(invokeActor) != None && !ScriptedPawn(invokeActor).CanConverse())
					return False;
				if ((bForcePlay || invokeMethod == IM_Named) && invokeActor != None && invokeActor.LastConEndTime != 0 && (Level.TimeSeconds - invokeActor.LastConEndTime) < 1.0)
					invokeActor.LastConEndTime = 0;
				con = GetActiveConversation(invokeActor, invokeMethod);
			}
			if (con == None)
				return False;
			if (!con.bFirstPerson || invokeMethod == IM_Frob || invokeMethod == IM_Named)
			{
				if (invokeActor != None)
					con.radiusDistance = FMax(con.radiusDistance, VSize(HostPlayer.Location - invokeActor.Location) + 2000);
			}
			if (!con.bFirstPerson && DeusExRootWindow(HostPlayer.rootWindow) != None && DeusExRootWindow(HostPlayer.rootWindow).WindowStackCount() > 0)
				DeusExRootWindow(HostPlayer.rootWindow).ClearWindowStack();
			HostPlayer.pendingCoopInitiator = Self;
			if (HostPlayer.StartConversation(invokeActor, invokeMethod, con, bAvoidState, bForcePlay))
			{
				HostPlayer.pendingCoopInitiator = None;
				if (tnmConPlay(HostPlayer.conPlay) != None)
					tnmConPlay(HostPlayer.conPlay).coopInitiator = Self;
				if (con != None && invokeActor != None && (!con.bFirstPerson || invokeMethod == IM_Frob || invokeMethod == IM_Named))
					con.radiusDistance = FMax(con.radiusDistance, VSize(HostPlayer.Location - invokeActor.Location) + 2000);
				return True;
			}
			HostPlayer.pendingCoopInitiator = None;
			return False;
		}
		return False;
	}

	if (Level.NetMode != NM_Standalone)
	{
		bSubtitles = True;
		foreach AllActors(class'Trestkon', T)
		{
			if (T != Self)
				T.BindName = "Partner";
		}
		BindName = "JCDenton";
	}

	// First check to see the actor has any conversations or if for some
	// other reason we're unable to start a conversation (typically if
	// we're alread in a conversation or there's a UI screen visible)


	if ((!bForcePlay) && ((invokeActor.conListItems == None) || ((Level.NetMode == NM_Standalone) && (!CanStartConversation())) || ((Level.NetMode != NM_Standalone) && (IsInState('Dying') || (conPlay != None && (!conPlay.CanInterrupt() || !conPlay.con.bFirstPerson)) || (root != None && !root.CanStartConversation())))))
		return False;


	// Make sure the other actor can converse
	if ((!bForcePlay) && ((ScriptedPawn(invokeActor) != None) && (!ScriptedPawn(invokeActor).CanConverse())))
		return False;


	// If we have a conversation passed in, use it.  Otherwise check to see
	// if the passed in actor actually has a valid conversation that can be
	// started.

	if ( con == None )
	{
		if ((bForcePlay || invokeMethod == IM_Named) && invokeActor != None && invokeActor.LastConEndTime != 0 && (Level.TimeSeconds - invokeActor.LastConEndTime) < 1.0)
			invokeActor.LastConEndTime = 0;
		con = GetActiveConversation(invokeActor, invokeMethod);
	}

	// If we have a conversation, put the actor into "Conversation Mode".
	// Otherwise just return false.
	//
	// TO DO: Scan through the conversation and put *ALL* actors involved
	//       in the conversation into the "Conversation" state??

	if ( con != None )
	{
		if( (!bForcePlay) && !con.bFirstPerson && (bOnFire || UsingChargedPickup(class'GasMask')) )
			return false;

		// Check to see if this conversation is already playing.  If so,
		// then don't start it again.  This prevents a multi-bark conversation
		// from being abused.
		if ((conPlay != None) && (conPlay.con == con))
			return False;

		// Now check to see if there's a conversation playing that is owned
		// by the InvokeActor *and* the player has a speaking part *and*
		// it's a first-person convo, in which case we want to abort here.
		if (((conPlay != None) && (conPlay.invokeActor == invokeActor)) &&
		    (conPlay.con.bFirstPerson) &&
			(conPlay.con.IsSpeakingActor(Self)))
			return False;

		// Check if the person we're trying to start the conversation
		// with is a Foe and this is a Third-Person conversation.
		// If so, ABORT!
		if ((!bForcePlay) && ((!con.bFirstPerson) && (ScriptedPawn(invokeActor) != None) && (ScriptedPawn(invokeActor).GetPawnAllianceType(Self) == ALLIANCE_Hostile)))
			return False;


		// If the player is involved in this conversation, make sure the
		// scriptedpawn even WANTS to converse with the player.
		//
		// I have put a hack in here, if "con.bCanBeInterrupted"
		// (which is no longer used as intended) is set, then don't
		// call the ScriptedPawn::CanConverseWithPlayer() function

		if ((!bForcePlay) && ((con.IsSpeakingActor(Self)) && (!con.bCanBeInterrupted) && (ScriptedPawn(invokeActor) != None) && (!ScriptedPawn(invokeActor).CanConverseWithPlayer(Self))))
			return False;

		// Hack alert!  If this is a Bark conversation (as denoted by the
		// conversation name, since we don't have a field in ConEdit),
		// then force this conversation to be first-person
		if (Left(con.conName, Len(con.conOwnerName) + 5) == (con.conOwnerName $ "_Bark"))
			con.bFirstPerson = True;

		// Make sure the player isn't ducking.  If the player can't rise
		// to start a third-person conversation (blocked by geometry) then
		// immediately abort the conversation, as this can create all
		// sorts of complications (such as the player standing through
		// geometry!!)

		if ((Level.NetMode == NM_Standalone) && (!con.bFirstPerson) && (ResetBasedPawnSize() == False))
			return False;

		// If ConPlay exists, end the current conversation playing
		if (conPlay != None)
		{
			// If we're already playing a third-person conversation, don't interrupt with
			// another *radius* induced conversation (frobbing is okay, though).
			if ((conPlay.con != None) && (conPlay.con.bFirstPerson) && (invokeMethod == IM_Radius))
				return False;

			if (Level.NetMode != NM_Standalone && conPlay.con != None && !conPlay.con.bFirstPerson && (bForcePlay || invokeMethod == IM_Named) && tnmGameInfo(Level.Game) != None)
			{
				if (pendingCoopInitiator != None && !pendingCoopInitiator.bDeleteMe)
					tnmGameInfo(Level.Game).QueueDeferredConversation(invokeActor, 5, con, bAvoidState, bForcePlay, pendingCoopInitiator);
				else
					tnmGameInfo(Level.Game).QueueDeferredConversation(invokeActor, 5, con, bAvoidState, bForcePlay, Self);
				pendingCoopInitiator = None;
				return True;
			}

			conPlay.InterruptConversation();
			conPlay.TerminateConversation();
		}

		// If this is a first-person conversation _and_ a DataLink is already
		// playing, then abort.  We don't want to give the user any more
		// distractions while a DL is playing, since they're pretty important.
		if ( dataLinkPlay != None )
		{
			if (con.bFirstPerson && invokeMethod == IM_Radius)
				return False;
			else
				dataLinkPlay.AbortAndSaveHistory();
		}

		// Found an active conversation, so start it
		conPlay = Spawn(class'tnmConPlay');
		if (tnmConPlay(conPlay) != None)
		{
			if (pendingCoopInitiator != None && !pendingCoopInitiator.bDeleteMe)
			{
				tnmConPlay(conPlay).coopInitiator = pendingCoopInitiator;
				pendingCoopInitiator = None;
			}
			else if (Level.NetMode != NM_Standalone && invokeMethod != IM_Frob && invokeActor != None)
			{
				bestDist = 9999999.0;
				BestT = None;
				foreach AllActors(class'Trestkon', T)
				{
					if (!T.bDeleteMe && T.Health > 0 && T.Player != None)
					{
						d = VSize(T.Location - invokeActor.Location);
						if (d < bestDist)
						{
							bestDist = d;
							BestT = T;
						}
					}
				}
				if (BestT != None)
					tnmConPlay(conPlay).coopInitiator = BestT;
				else
					tnmConPlay(conPlay).coopInitiator = Self;
			}
			else
			{
				tnmConPlay(conPlay).coopInitiator = Self;
			}
		}
		conPlay.SetStartActor(invokeActor);
		conPlay.SetConversation(con);
		conPlay.SetForcePlay(bForcePlay);
		conPlay.SetInitialRadius(VSize(Location - invokeActor.Location));

		// If this conversation was invoked with IM_Named, then save away
		// the current radius so we don't abort until we get outside
		// of this radius + 100.
		if ((invokeMethod == IM_Named) || (invokeMethod == IM_Frob))
		{
			conPlay.SetOriginalRadius(con.radiusDistance);
			if (Level.NetMode != NM_Standalone)
				con.radiusDistance = FMax(con.radiusDistance, VSize(invokeActor.Location - Location) + 2000);
			else
				con.radiusDistance = VSize(invokeActor.Location - Location);
		}

		// If the invoking actor is a ScriptedPawn, then force this person
		// into the conversation state
		if (/*(!bForcePlay) &&*/ (ScriptedPawn(invokeActor) != None ))
			ScriptedPawn(invokeActor).EnterConversationState(con.bFirstPerson, bAvoidState);

		// Do the same if this is a DeusExDecoration
		if (/*(!bForcePlay) &&*/ (DeusExDecoration(invokeActor) != None ))
			DeusExDecoration(invokeActor).EnterConversationState(con.bFirstPerson, bAvoidState);

		// If this is a third-person convo, we're pretty much going to
		// pause the game.  If this is a first-person convo, then just
		// keep on going..
		//
		// If this is a third-person convo *AND* 'bForcePlay' == True,
		// then use first-person mode, as we're playing an intro/endgame
		// sequence and we can't have the player in the convo state (bad bad bad!)

		if ((!con.bFirstPerson) && (!bForcePlay) && (Level.NetMode == NM_Standalone || tnmConPlay(conPlay) == None || tnmConPlay(conPlay).ResolveCoopPlayer() == Self))
		{
			GotoState('Conversation');
		}
		else
		{
			if (!conPlay.StartConversation(Self, invokeActor, bForcePlay))
			{
				AbortConversation(True);
			}
		}

		return True;
	}
	else
	{
		return False;
	}
}

simulated function InvokeComputerScreen(Computers computerToActivate, float CompHackTime, float ServerLevelTime)
{
	local NetworkTerminal termwindow;
	local DeusExRootWindow root;
   
	if (computerToActivate == None)
		return;

	computerToActivate.LastHackTime = CompHackTime + (Level.TimeSeconds - ServerLevelTime);

	ActiveComputer = ComputerToActivate;

	//only allow for clients or standalone
	if ((Level.NetMode != NM_Standalone) && (!PlayerIsClient()))
	{
		ActiveComputer = None;
		CloseComputerScreen(computerToActivate);
		return;
	}

	root = DeusExRootWindow(rootWindow);
	if (root != None)
	{
		if (computerToActivate.terminalType == None && tnmComputers(computerToActivate) != None && tnmComputers(computerToActivate).terminalTypeStr != "")
			computerToActivate.terminalType = class<NetworkTerminal>(DynamicLoadObject(tnmComputers(computerToActivate).terminalTypeStr, class'Class'));
		if (computerToActivate.terminalType == None)
		{
			if (computerToActivate.IsA('ComputerPublic'))
				computerToActivate.terminalType = class<NetworkTerminal>(DynamicLoadObject("TNMGUI.tnmNetworkTerminalPublic", class'Class'));
			else if (computerToActivate.IsA('ComputerSecurity'))
				computerToActivate.terminalType = class<NetworkTerminal>(DynamicLoadObject("TNMGUI.tnmNetworkTerminalSecurity", class'Class'));
			else
				computerToActivate.terminalType = class<NetworkTerminal>(DynamicLoadObject("TNMGUI.tnmNetworkTerminalPersonal", class'Class'));
		}
		termwindow = NetworkTerminal(root.InvokeUIScreen(computerToActivate.terminalType, True));
		if (termwindow != None)
		{
			computerToActivate.termwindow = termwindow;
			termWindow.SetCompOwner(computerToActivate);
			// If multiplayer, start hacking if there are no users
			if (False && (Level.NetMode != NM_Standalone) && (!termWindow.bHacked) && (computerToActivate.NumUsers() == 0) &&
			(termWindow.winHack != None) && (termWindow.winHack.btnHack != None))
			{
				termWindow.winHack.StartHack();
				termWindow.winHack.btnHack.SetSensitivity(False);
				termWindow.FirstScreen=None;
			}
			termWindow.ShowFirstScreen();
		}
	}
	if ((termWindow == None)  || (root == None))
	{
		CloseComputerScreen(computerToActivate);
		ActiveComputer = None;
	}

	if (tnmcomputers(computerToActivate) != None)
		tnmcomputers(computertoactivate).clean();
}

simulated function ResetPlayer(optional bool bTraining)
{
	local inventory anItem;
	local inventory nextItem;
	local int skill_tmp;

	if(!bTraining)
		skill_tmp=SkillPointsAvail;

	flagbase.DeleteAllFlags();
	
	// Reset the ATMAccountManager
	if (ATMAccountManager != None)
	{
		ATMAccountManager.Destroy();
		ATMAccountManager = None;
	}
	
	// Make sure we don't get stuck in this glitched state.
	if (POVCorpse(inhand) != None)
		POVCorpse(inhand).Destroy();

	ResetPlayerToDefaults();

	// Reset Augmentations
	if (AugmentationSystem != None)
	{
		AugmentationSystem.ResetAugmentations();
		AugmentationSystem.Destroy();
		AugmentationSystem = None;
	}
	
	// Reset credits total when starting a new game
	CreditsEarned = 0;
	CreditsPrev = 0;

	if(!bTraining)
	{
		SkillPointsAvail=skill_tmp;
		anItem = Spawn(class<DataVaultImage>(DynamicLoadObject("TNMDataVault.TNMDV_DowntownMap",class'Class')));
		anItem.frob(Self,None);
		anItem = Spawn(class'nanokey');
		nanokey(anitem).KeyID = 'TrestkonsRavingLocker';
		nanokey(anitem).Description = strLockerPassword;
		anItem.Frob(Self, None);
		anItem.bInObjectBelt = True;
		NoteAdd( strAccountPin );
	}
	
	//WCCC 3/16/19: Avoid duplicates with the new failsafe for player fists.
	if (PlayerFists == None || PlayerFists.Owner != Self)
	{
		anitem = Spawn(class'weaponfists');
		playerfists = weaponfists(anitem);
		anitem.Frob(self, none);
		anitem.binobjectbelt = false;
		anitem.BeltPos = -1;
	}
	
	lives = Default.Lives;
	radishHealth = 2;
	radishCounter = 0;
	
	InitPCGames();	
}

// ----------------------------------------------------------------------
// ResetPlayerToDefaults()
//
// Resets all travel variables to their defaults
// ----------------------------------------------------------------------

function ResetPlayerToDefaults()
{
	local inventory anItem;
	local inventory nextItem;

   // reset the image linked list
	FirstImage = None;

	if (DeusExRootWindow(rootWindow) != None && Level.NetMode == NM_StandAlone)
		DeusExRootWindow(rootWindow).ResetFlags();

	// Remove all the keys from the keyring before
	// it gets destroyed
	if (KeyRing != None)
	{
		KeyRing.RemoveAllKeys();
		if ((Role == ROLE_Authority) && (Level.NetMode != NM_Standalone))
		{
			KeyRing.ClientRemoveAllKeys();
		}
		KeyRing = None;
	}

	while(Inventory != None)
	{
		anItem = Inventory;
		DeleteInventory(anItem);
		anItem.Destroy();
	}

	// Clear object belt
	if (DeusExRootWindow(rootWindow) != None)
		DeusExRootWindow(rootWindow).hud.belt.ClearBelt();

	// clear the notes and the goals
	DeleteAllNotes();
	DeleteAllGoals();

	// Nuke the history
	ResetConversationHistory();

	// Other defaults
	Credits = Default.Credits;
	Energy  = Default.Energy;
	SkillPointsTotal = Default.SkillPointsTotal;
	SkillPointsAvail = Default.SkillPointsAvail;

	//G-Flex: reset drug timer
	DrugEffectTimer = 0;

	SetInHandPending(None);
	SetInHand(None);

	bInHandTransition = False;

	RestoreAllHealth();
	ClearLog();

	// Reset save count/time
	saveCount = 0;
	saveTime  = 0.0;
	
	dripRate = 0;
	waterDripCounter = 0;

	// Reinitialize all subsystems we've just nuked
	InitializeSubSystems();

	// Give starting inventory.
	if (False && Level.Netmode != NM_Standalone)
	{
		NintendoImmunityEffect( True );
		GiveInitialInventory();
	}
}


// Smoke39 - let us fade!
exec function FadeToBlack( float fadeDuration, optional bool bNoActuallyWhite )
{
	if (DeusExRootWindow(rootWindow) != None && tnmhud( DeusExRootWindow(rootWindow).hud ) != None)
	{
		tnmhud( DeusExRootWindow(rootWindow).hud ).fade.bWhite=bNoActuallyWhite;
		tnmhud( DeusExRootWindow(rootWindow).hud ).fade.StartFade( -fadeDuration );
	}
}

exec function FadeFromBlack( float fadeDuration, optional bool bNoActuallyWhite )
{
	if (DeusExRootWindow(rootWindow) != None && tnmhud( DeusExRootWindow(rootWindow).hud ) != None)
	{
		tnmhud( DeusExRootWindow(rootWindow).hud ).fade.bWhite=bNoActuallyWhite;
		tnmhud( DeusExRootWindow(rootWindow).hud ).fade.StartFade( fadeDuration );
	}
}

// Smoke39 - implementing new on-fire effects, made execable for testing
function CatchFire( Pawn burner )
{
	local Fire f;
	local int i;
	local vector loc;

	myBurner = burner;

	burnTimer = 0;

	if (bOnFire || Region.Zone.bWaterZone)
		return;

	bOnFire = True;
	burnTimer = 0;
	// big nasty block replaced with this line
	Spawn(class'TNMFire',self);
	SetTimer(1.0, True);
}

function ExtinguishFire()
{
	local TNMFire f;

	bOnFire = False;
	burnTimer = 0;
	SetTimer(0, False);

	// Based actors isn't based, breaks on lean
	// foreach BasedActors(class'TNMFire', f)
		// f.Destroy();

	foreach AllActors(class'TNMFire', f)
		if (f.Owner == Self)
			f.Destroy();
}

// for testing the above
exec function ignite()
{
	if (!bCheatsEnabled)
		return;

	CatchFire(self);
}

exec function douse()
{
	if (!bCheatsEnabled)
		return;

	ExtinguishFire();
}

// Smoke39 - new jump and bob stuff
function CheckBob( float DeltaTime, float Speed2D, vector Y )
{
	local float newSwimPitch, newSwimYaw;
	local rotator newSwimOffset;

	if ( Speed2D < 10 || Physics != PHYS_Walking )
		BobTime += 0.2 * DeltaTime;
	else
		BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);
	WalkBob = Y * 0.65 * Bob * Speed2D * sin(6 * BobTime);
	AppliedBob = AppliedBob * (1 - FMin(1, 16 * deltatime));

	if ( LandBob < -0.01 )
	{
		AppliedBob += FMin(1, 16 * deltatime) * LandBob;
		LandBob *= (1 - 8*Deltatime);
	}

	// Smoke39 - new jump stuff
	if ( jumpBob < -0.01 )
	{
		AppliedBob += FMin( 1, 16*DeltaTime ) * jumpBob;
		jumpBob *= 1 - 8*DeltaTime;

		if ( jumpBob > -10 && bMustJump )
		{
			if ( Physics == PHYS_Walking )
				Super.DoJump();

			bMustJump = false;
		}
	}

	if ( Speed2D < 10 || Physics != PHYS_Walking )
		WalkBob.Z = AppliedBob;// + Bob * 30 * sin(12 * BobTime);  <- Unreal "breathe" effect
	else
		WalkBob.Z = AppliedBob + Bob * Speed2D * sin(12 * BobTime);

}
/*
function Landed( vector HitNormal )
{
	SpawnFootprint();
	SpawnFootprint();
	LandBob = FMax(-50, 0.06 * Velocity.Z);
	Super.Landed(HitNormal);
}
*/
function DoJump( optional float F )
{
	if ( CarriedDecoration != None && CarriedDecoration.Mass > 20 )
		return;
	else if ( bForceDuck || IsLeaning() )
		return;
	else if ( Physics != PHYS_Walking || bMustJump )
		return;

	if(rand(2)==0)
		PlaySound(Sound'Jump01', SLOT_None, 0.5, true, 1200, 1.0 - 0.2*FRand() );
	else
		PlaySound(Sound'Jump02', SLOT_None, 0.5, true, 1200, 1.0 - 0.2*FRand() );

	if ( TrackMover(Base) != None )
	{
		Velocity.X += Base.Velocity.X;
		Velocity.Y += Base.Velocity.Y;
	}
	if ( bIsCrouching || bPlatformer )
		Super.DoJump();
	else
	{	
		if (Level.NetMode != NM_StandAlone)
			Super.DoJump();
		else
		{
			bMustJump = true;
			jumpBob = -20;
		}
	}
}

// not quite as fancy as changing CalcDrawOffset() in the item, but
// this way we don't have to subclass every fucking item :)
function bool AddInventory(inventory item)
{
    local bool retval;
    local DeusExRootWindow root;

    retval = super(PlayerPawnExt).AddInventory(item);

    // Force the object be added to the object belt
    // unless it's ammo
    //
    // Don't add Ammo and don't add Images!

    if ((item != None) && (!item.IsA('Ammo')) && (!item.IsA('DataVaultImage')) && (!item.IsA('Credits')) && (!item.IsA('PosterTube')) && (!item.IsA('TNMBinoculars')))
    {
        if (retval && (item.invPosX == -1 || item.invPosY == -1))
            FindInventorySlot(item);

        root = DeusExRootWindow(rootWindow);

        if ( item.bInObjectBelt )
        {
            if (root != None)
            {
                root.hud.belt.AddObjectToBelt(item, item.beltPos, True);
            }
        }

        if (retval)
        {
            if (root != None)
            {
                root.AddInventory(item);
            }
        }
    }
	if ( retval )
		item.BobDamping = 1.2;

    return (retval);
}

function Gasp()
{
	if(rand(2)==0)
		PlaySound(sound'Gasp01', SLOT_Pain,,,, RandomPitch());
	else
		PlaySound(sound'Gasp02', SLOT_Pain,,,, RandomPitch());
}

function PlayDyingSound()
{
}

function PlayTrestkonDyingSound(name damageType, vector hitLoc)
{
	local sound snd;

	if (Region.Zone.bWaterZone)
		snd=Sound'WaterDeath';
	else if (damageType == 'Exploded' || damageType == 'Flamed' || damageType == 'Burned')
	{
		if(rand(2)==0)
			snd=Sound'DeathExplode01';
		else
			snd=Sound'DeathExplode02';
	}
	else if (damageType == 'Shot' || damageType == 'Autoshot' || damageType == 'Sabot')
	{
		switch(rand(3))
		{
		case 0:
			snd=Sound'DeathShot01';
			break;
		case 1:
			snd=Sound'DeathShot02';
			break;
		case 2:
			snd=Sound'DeathShot03';
			break;
		}
	}
	else if (damageType == 'TearGas' || damageType == 'HalonGas' || damageType == 'PoisonGas' || damageType == 'KnockedOut' || damageType == 'Poison' || damageType == 'PoisonEffect' || damageType == 'Stunned' || damageType == 'StunnedTaser' || damageType == 'headstun')
	{
		switch(rand(3))
		{
		case 0:
			snd=Sound'Unconscious01';
			break;
		case 1:
			snd=Sound'Unconscious02';
			break;
		case 2:
			snd=Sound'Unconscious03';
			break;
		}
		bStunned = True;
	}
	else
	{
		switch(rand(3))
		{
		case 0:
			snd=Sound'DeathMelee01';
			break;
		case 1:
			snd=Sound'DeathMelee02';
			break;
		case 2:
			snd=Sound'DeathMelee03';
			break;
		}
	}

	PlaySound(snd, SLOT_Pain,,,, RandomPitch());
}

function PlayTakeHitSound(int Damage, name damageType, int Mult)
{
	local float rnd;
	local sound snd;

	if ( Level.TimeSeconds - LastPainSound < FRand() + 0.5)
		return;

	LastPainSound = Level.TimeSeconds;

	if (damageType == 'Fell')
	{
		switch(rand(4))
		{
		case 0:
			snd=Sound'Grunt01';
			break;
		case 1:
			snd=Sound'Grunt02';
			break;
		case 2:
			snd=Sound'Grunt03';
			break;
		case 3:
			snd=Sound'Grunt04';
			break;
		}
		PlaySound(snd, SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
	}
	else if (Region.Zone.bWaterZone)
	{
		if (damageType == 'Drowned')
		{
			if (FRand() < 0.8)
			{
				switch(rand(4))
				{
				case 0:
					snd=Sound'Drowning01';
					break;
				case 1:
					snd=Sound'Drowning02';
					break;
				case 2:
					snd=Sound'Drowning03';
					break;
				case 3:
					snd=Sound'Drowning04';
					break;
				}
				PlaySound(snd, SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
			}
		}
		else
		{
			if(rand(2)==0)
				snd=Sound'PainSmall01';
			else
				snd=Sound'PainSmall02';
			PlaySound(snd, SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
		}
	}
	else
	{
		if ((damageType == 'TearGas') || (damageType == 'HalonGas') || (damageType == 'PoisonGas'))
		{
			switch(rand(3))
			{
			case 0:
				snd=Sound'Cough01';
				break;
			case 1:
				snd=Sound'Cough02';
				break;
			case 2:
				snd=Sound'Cough03';
				break;
			}
			PlaySound(snd, SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
		}
		else
		{
			damage/=combatdifficulty;
			if(damage<4)
			{
				if(rand(2)==0)
					snd=Sound'PainSmall01';
				else
					snd=Sound'PainSmall02';
			}
			else if(damage<10)
			{
				if(rand(2)==0)
					snd=Sound'PainSmall01';
				else
					snd=Sound'PainSmall02';
			}
			else
			{
				switch(rand(4))
				{
				case 0:
					snd=Sound'PainLarge01';
					break;
				case 1:
					snd=Sound'PainLarge02';
					break;
				case 2:
					snd=Sound'PainLarge03';
					break;
				case 3:
					snd=Sound'PainLarge04';
					break;
				}
			}
			PlaySound(snd, SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
		}
		AISendEvent('LoudNoise', EAITYPE_Audio, FMax(Mult * TransientSoundVolume, Mult * 2.0));
	}
}

function PlayDying(name damageType, vector hitLoc)
{
	if(damageType=='Insane')
	{
		bInsaneDeath=true; //let the dying state handle animation if this is the special insane death
		return;
	}

	PlayTrestkonDyingSound(damageType,hitLoc);
	
	if(damageType=='Vacuum' || damageType=='Atmospheric' || (Region.Zone != None && Region.Zone.DamageType == 'Atmospheric'))
	{
		PlayAnim('WaterDeath',,0.1);
		return;
	}
	super.PlayDying(damageType,hitLoc);
}

/*struct tnmPCGscore
{
	var() string alias;
	var() int score;
};

struct tnmPCGdata
{
	var() tnmPCGscore scores[10];
	var() bool bHasScores;
	var() float timeplayed;
	var() string title;
	var() string scoretype;
};*/

function SetPCGame(out tnmPCGdata pcg, string title, bool bHasScores, optional string scoretype,  optional string scores)
{
	local int i;
	local string alias,score;
	local bool bscore;

	pcg.title=title;
	pcg.timeplayed=0.f;
	pcg.bHasScores=bHasScores;

	if(bHasScores)
	{
		pcg.scoretype=scoretype;
		while(len(scores)>0)
		{
			if(left(scores,1)==":")
				bscore=true;
			else if(left(scores,1)==";")
			{
				pcg.scores[i].alias=alias;
				pcg.scores[i++].score=int(score);
//				log("alias:"@alias@"score:"@score,'TNMPCG');
				alias="";
				score="";
				bscore=false;
			}
			else if(bscore)
				score=score$left(scores,1);
			else
				alias=alias$left(scores,1);

			scores=right(scores,len(scores)-1);
		}
	}
}

//adds to a game's timeplayed since games can't access PCGameData directly
function AddGameTimePlayed(string game, float amt)
{
	local int i;
	switch(game)
	{
	case "TETRIS":
		i=PCG_TETRIS;
		break;
	case "PONG":
		i=PCG_PONG;
		break;
	case "BREAKOUT":
		i=PCG_BREAKOUT;
		break;
	case "LIGHTSOUT":
		i=PCG_LIGHTSOUT;
		break;
	case "TEXT":
		i=PCG_TEXT;
		break;
	default:
		log("invalid game",'AddGameTimePlayed');
		return;
	}
	PCGameData[i].timeplayed+=amt;
}

//sets the default pcgameinfo scores and game titles
function InitPCGames()
{
	SetPCGame(PCGameData[PCG_TETRIS],"Tetris",true,"High Scores",
					"NARCISSUS:20000;LBLOCK:10000;THATGUY:5000;CUBE:4096;"$
					"BOREDGUEST:3500;FUB:2250;MATER_KALE:1800;OINUTTER:1000;"$
					"SQUARE:256;|-|4X0|-:-1;");
	SetPCGame(PCGameData[PCG_PONG],"Pong",true,"High Scores (Survival Mode)",
					"NARCISSUS:500;ALPHA:200;NVSHACKER:150;SNIPA_MASTA:100;"$
					"SPACEMAN:75;FOX:50;FEMALE_PATRON:25;BOARD_GUEST:15;"$
					"BUSINESSMAN:5;|-|4X0|-:-1;");
	SetPCGame(PCGameData[PCG_BREAKOUT],"Breakout",true,"High Scores (No passcodes used)",
					"NARCISSUS:25000;TANGO:17500;BUSTER:12500;STELLA:10000;"$
					"THEODORE:8000;CHELSEA:5000;LITTER_BOX:3000;CATNIP:2000;"$
					"JONAS:1000;|-|4X0|-:-1;");
	SetPCGame(PCGameData[PCG_LIGHTSOUT],"Lights Out",true,"Most Times Completed",
					"NARCISSUS:150;SAM:100;BEEBLEQUIX:90;FUSE_BOX:75;"$
					"JIMBO:60;GELO:50;JOHN:40;DANIEL:25;I4:1;|-|4X0|-:-1;");
	SetPCGame(PCGameData[PCG_TEXT],"The Nameless Text Adventure",false);
}

//modified to handle the insanedeath, the fading to black and load the right main menu map
state Dying
{
	function PlayerMove( float DeltaTime )
	{
		if (bplatformer)
		{
			aturn = 0;
			aforward = 0;
			astrafe  = 0;
			aLookup  = 0;
			
			//G-Flex: stop player from accelerating instead of freezing them completely
			//G-Flex: this preserves swim bob/floating especially
			Acceleration = vect(0,0,0);
		}
		super.playermove(deltatime);
	}

	event PlayerTick(float deltaTime)
	{
		local Rotator rot, rot2;
		local float dist;

		if(insanedeathtimer != 0.0 && Level.TimeSeconds - insanedeathtimer <= 5.0)
		{
			rot=Rotation;
			rot2=Rotator(insaneDest-Location);
			dist=(rot2.yaw-rot.yaw)*1.5*deltaTime;
			if(abs(dist)>65536*1.5*deltaTime)
				dist=abs(dist)/dist*65536*1.5*deltaTime;
			rot.yaw=rot.yaw+dist;
			SetRotation(rot);
		}
		ShowHud(False);	// Don't show the HUD if dead (i.e. if closing the main menu).

		if (Role == ROLE_Authority && Level.NetMode != NM_Standalone)
		{
			if (coopSpectateTarget != None && coopSpectateTarget.bDeleteMe)
				coopSpectateTarget = None;
			if (coopSpectateTarget != None)
				ViewTarget = coopSpectateTarget;
			else if (MoveTarget != None && !MoveTarget.bDeleteMe)
				ViewTarget = MoveTarget;
		}

		super.PlayerTick(deltaTime);
	}

	function PickDestination()
	{
		local float           magnitude;
		/*local float           distribution;
		local int             yaw, pitch;
		local Rotator         rotDest;

		rotDest=RotRand(false)*0.25+Rotation*0.75;
		yaw = rotDest.Yaw;
		pitch = 0;
		distribution = 0.5;*/

		magnitude = 300*(FRand()*0.4+0.8);  // 400, +/-20%
		if (!AIPickRandomDestination(100, magnitude, 0, 0, 0, 0, 4, FRand()*0.4+0.35, insaneDest))
			insaneDest = Location+(VRand()*150);  // we give up
	}

	function PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation)
	{
		local vector ViewVect, HitLocation, HitNormal, whiteVec, ViewLoc, BaseBodyLoc;
		local float ViewDist;
		local actor HitActor;
		local float time;

		ViewActor = Self;
		if (Level.NetMode != NM_Standalone && coopSpectateTarget != None && !coopSpectateTarget.bDeleteMe)
		{
			InstantFog   = vect(0,0,0);
			InstantFlash = 0;
			ViewFlash(1.0);
			ViewLoc = coopSpectateTarget.Location + vect(0, 0, 56);
			CameraRotation = ViewRotation;
			ViewDist = 110.0;
			HitActor = Trace(HitLocation, HitNormal,
					ViewLoc - ViewDist * vector(CameraRotation), coopSpectateTarget.Location, false, vect(12,12,2));
			if (HitActor != None)
				CameraLocation = HitLocation;
			else
				CameraLocation = ViewLoc - ViewDist * vector(CameraRotation);
			return;
		}

		if (Level.NetMode != NM_Standalone)
			BaseBodyLoc = GetCoopDeadBodyViewLoc();
		else
			BaseBodyLoc = Location;

		if ( bHidden && bplatformer )
		{
			CameraRotation = ViewRotation;
			camerarotation.pitch += pitchchange;
			camerarotation.yaw += yawchange;

			CameraLocation = Location;
			CameraLocation.Z += EyeHeight;
			CameraLocation.z += zchange;
			cameralocation -= zoomchange * vector(camerarotation);

			time = Level.TimeSeconds - FrobTime;

			if ( time > 16.0 )
			{
				setlives(lives - 1);
				// Transient, always deleted
				if (irc_link != None)
					irc_link.ServerQuit(QR_Loading);
				
				if ( lives < 0)
					ConsoleCommand("OPEN TNMOnly");
				else
					RestartLevel();
					// Level.Game.SendPlayer(Self, "platform_01");
			}
		}
		else if (bHidden || bInsaneDeath)
		{
			// spiral up and around carcass and fade to white in five seconds
			time = Level.TimeSeconds - FrobTime;

			if ( ((myKiller != None) && (killProfile != None) && (!killProfile.bKilledSelf)) ||
				  ((killProfile != None) && killProfile.bValid && (!killProfile.bKilledSelf)))
			{
				if ( killProfile.bValid && killProfile.bTurretKilled )
					ViewVect = killProfile.killerLoc - BaseBodyLoc;
				else if ( killProfile.bValid && killProfile.bProximityKilled )
					ViewVect = killProfile.killerLoc - BaseBodyLoc;
				else if (( !killProfile.bKilledSelf ) && ( myKiller != None ))
					ViewVect = myKiller.Location - BaseBodyLoc;
				CameraLocation = BaseBodyLoc;
				CameraRotation = Rotator(ViewVect);
			}
			else if (time < 8.0 || bInsaneDeath && time < 16.0)
			{
				if(bInsaneDeath) //fade to white then black
				{
					whiteVec.X = time / 16.0;
					whiteVec.Y = time / 16.0;
					whiteVec.Z = time / 16.0;
				}
				else //fade to black
				{
					whiteVec.X = -time / 16.0;
					whiteVec.Y = -time / 16.0;
					whiteVec.Z = -time / 16.0;
				}
				CameraRotation.Pitch = -16384;
				CameraRotation.Yaw = (time * 8192.0) % 65536;
				if(bInsaneDeath)
				{
					ViewDist = 32 + time * 16;
					InstantFlash = 0.5;
				}
				else
				{
					ViewDist = 32 + time * 32;
					InstantFlash = -0.5;
				}
				InstantFog = whiteVec;
				ViewFlash(1.0);
				// make sure we don't go through the ceiling
				ViewVect = vect(0,0,1);
				ViewLoc = BaseBodyLoc;
				if (bInsaneDeath)
					ViewLoc.Z += EyeHeight;
				HitActor = Trace(HitLocation, HitNormal, ViewLoc + ViewDist * ViewVect, ViewLoc);
				if ( HitActor != None )
					CameraLocation = HitLocation;
				else
					CameraLocation = ViewLoc + ViewDist * ViewVect;
			}
			else
			{
				// Don't fade to black in multiplayer
				if  ( Level.NetMode == NM_Standalone )
				{
					if(bInsaneDeath)
					{
						whiteVec.X = FMax(1.0 - (time-16.0) / 8.0, -1.0);
						whiteVec.Y = FMax(1.0 - (time-16.0) / 8.0, -1.0);
						whiteVec.Z = FMax(1.0 - (time-16.0) / 8.0, -1.0);
					}
					else
					{
						whiteVec.X = FMax(-time / 16.0, -1.0);
						whiteVec.Y = FMax(-time / 16.0, -1.0);
						whiteVec.Z = FMax(-time / 16.0, -1.0);
					}
					CameraRotation.Pitch = -16384;
					CameraRotation.Yaw = (time * 8192.0) % 65536;
					ViewDist = 32 + 8.0 * 32;
					InstantFog = whiteVec;
					InstantFlash = whiteVec.X;
					ViewFlash(1.0);

					// start the splash screen after a bit
					// only if we don't have a menu open
					if ( whiteVec == vect(-1.0,-1.0,-1.0) )
					{
						if ( (MenuUIWindow(DeusExRootWindow(rootWindow).GetTopWindow()) == None) &&
							(ToolWindow(DeusExRootWindow(rootWindow).GetTopWindow()) == None) )
						{
							// Transient, always deleted
							if (irc_link != None)
								irc_link.ServerQuit(QR_Loading);
							// Smoke39 - don't load DXONLY anymore! XO
							ConsoleCommand("OPEN TNMOnly");
						}
					}
				}
				else
				{
					CameraRotation = ViewRotation;
				}
				// make sure we don't go through the ceiling
				ViewVect = vect(0,0,1);
				HitActor = Trace(HitLocation, HitNormal, BaseBodyLoc + ViewDist * ViewVect, BaseBodyLoc);
				if ( HitActor != None )
					CameraLocation = HitLocation;
				else
					CameraLocation = BaseBodyLoc + ViewDist * ViewVect;
			}
		}
		else
		{
			// use FrobTime as the cool DeathCam timer
			FrobTime = Level.TimeSeconds;

			// make sure we don't go through the wall
			ViewDist = 190;
			ViewVect = vect(1,0,0) >> Rotation;
			HitActor = Trace( HitLocation, HitNormal,
					BaseBodyLoc - ViewDist * vector(CameraRotation), BaseBodyLoc, false, vect(12,12,2));
			if ( HitActor != None )
				CameraLocation = HitLocation;
			else
				CameraLocation = BaseBodyLoc - ViewDist * ViewVect;
		}

		// don't fog view if we are "paused"
		if (DeusExRootWindow(rootWindow) != None && DeusExRootWindow(rootWindow).bUIPaused)
		{
			InstantFog   = vect(0,0,0);
			InstantFlash = 0;
			ViewFlash(1.0);
		}
	}
	
	function DeleteInvItems()
	{
		local inventory item, nextItem;

		if(inventory != none)
		{
			do
			{
				item = Inventory;
				nextItem = item.Inventory;

				DeleteInventory(item);
				
				if (DeusExWeapon(item) != None)
				{
					if (DeusExWeapon(item).bLasing)
						DeusExWeapon(item).LaserOff();
				}
				Item.Destroy();

				item = nextItem;
			}
			until (item == None)
		}
	}

	exec function ParseRightClick()
	{
		if (Level.NetMode != NM_Standalone)
		{
			ServerCycleDeadSpectate();
			return;
		}
		Super.ParseRightClick();
	}

	exec function AltFire(optional float F)
	{
		if (Level.NetMode != NM_Standalone)
		{
			ServerCycleDeadSpectate();
			return;
		}
	}

	exec function Fire(optional float F)
	{
		local Trestkon OtherP;
		local bool bLivingTeammateExists;
		local Vector pingSpot;

		if (Level.NetMode != NM_Standalone)
		{
			bLivingTeammateExists = False;
			foreach AllActors(class'Trestkon', OtherP)
			{
				if (OtherP != Self && !OtherP.IsInState('Dying') && OtherP.Health > 0)
				{
					bLivingTeammateExists = True;
					break;
				}
			}

			if (bLivingTeammateExists)
			{
				ClientMessage("Waiting for teammate to revive you with a Medkit! (Pinging your location...)");
				if (MoveTarget != None && !MoveTarget.bDeleteMe)
					pingSpot = MoveTarget.Location + vect(0, 0, 24);
				else
					pingSpot = Location + vect(0, 0, 24);
				BroadcastCoopPing(pingSpot, MoveTarget, "REVIVE ME (Use Medkit)", GetCoopPlayerName(), 3);
				return;
			}
		}

		Super.Fire(F);
	}

//edited for insanedeath stuff
Begin:
	coopSpectateTarget = None;
	ViewTarget = None;
	if ( bplatformer )
	{
		setlives(lives - 1);
		DeleteInvItems();
		if ( lives < 0)
		{
			sleep(10.0);
			// Transient, always deleted
			if (irc_link != None)
				irc_link.ServerQuit(QR_Loading);
			ConsoleCommand("OPEN TNMOnly");
		}
		else
		{
			sleep(2.5);
			// Transient, always deleted
			if (irc_link != None)
				irc_link.ServerQuit(QR_Loading);
			ConsoleCommand("TRAVEL"@Level.GetLocalURL());
		}
	}

	// Dead players comes back to life with scope view, so this is here to prevent that
	if ( DeusExWeapon(inHand) != None )
	{
		DeusExWeapon(inHand).bZoomed = False;
		DeusExWeapon(inHand).RefreshScopeDisplay(Self, True, False);
	}

	if ( DeusExRootWindow(rootWindow) != None && DeusExRootWindow(rootWindow).hud != None && DeusExRootWindow(rootWindow).hud.augDisplay != None )
	{
		DeusExRootWindow(rootWindow).hud.augDisplay.bVisionActive = False;
		DeusExRootWindow(rootWindow).hud.augDisplay.activeCount = 0;
	}

	// Don't come back to life drugged or posioned
	poisonCounter		= 0; 
	poisonTimer		= 0;    
	drugEffectTimer		= 0;

	// Don't come back to life crouched
	bCrouchOn		= False;
	bWasCrouchOn		= False;
	bIsCrouching		= False;
	bForceDuck		= False;
	lastbDuck		= 0;
	bDuck			= 0;

	FrobTime = Level.TimeSeconds;
	bBehindView = True;
	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);
	DesiredFOV = Default.DesiredFOV;
	insanedeathtimer=0;

	if(!bInsaneDeath)
		Goto('Finish');
	insanedeathtimer=Level.TimeSeconds;
	insaneDest=Location;

InsaneDeathPanic:
	//run around aimlessly for 5 seconds
	if(Level.TimeSeconds - insanedeathtimer > 5.0)
		Goto('InsaneDeathShock');

	LoopAnim('Panic', 1.0);
	PickDestination();
	MoveTo(insaneDest, MaxDesiredSpeed*0.75);
	Goto('InsaneDeathPanic');

InsaneDeathShock:
	//convulse and drop dead, the rest is the same as the regular death sequence
	insanedeathtimer=0;
	LoopAnim('Shocked',,0.1);
	Sleep(2.5);
	FinishAnim();
	PlayAnim('DeathFront',,0.1);

Finish:
	FinishAnim();
	KillShadow();

   	FlashTimer = 0;

	// hide us and spawn the carcass
	bHidden = True;
	SpawnCarcass();
	if (Level.NetMode != NM_Standalone)
		HidePlayer();
}
// end of Smoke39 silliness

//For the slightly modified compass
function float MapTrueNorth()
{
	if (Marker != None)
		return rotator(marker.Location - Location).Yaw;
	else
	{
		foreach AllActors(Class'NorthMarker', marker)
			return rotator(marker.Location - Location).Yaw;
	}

	if (mapinfo != None)
		return mapinfo.TrueNorth;
	else
	{
		Mapinfo = GetLevelInfo();
		if (mapinfo != None)
			return mapinfo.TrueNorth;
		return 0;
	}
}

//Directly copied and modified to call the modified switchweapon (thanks shifter)
function UpdateInHand()
{
	local bool bSwitch;

	//sync up clientinhandpending.
	if (inHandPending != inHand)
		ClientInHandPending = inHandPending;

	//DEUS_EX AMSD  Don't let clients do this.
	if (Role < ROLE_Authority)
      return;

	if (inHand != inHandPending)
	{
		bInHandTransition = True;
		bSwitch = False;
		if (inHand != None)
		{
			// turn it off if it is on
			if (inHand.bActive)
				inHand.Activate();

			if (inHand.IsA('SkilledTool'))
			{
				if (inHand.IsInState('Idle'))
				{
					SkilledTool(inHand).PutDown();
				}
				else if (inHand.IsInState('Idle2'))
				{
					bSwitch = True;
				}
			}
			else if (inHand.IsA('DeusExWeapon'))
			{
				if (inHand.IsInState('Idle') || inHand.IsInState('Reload'))
					DeusExWeapon(inHand).PutDown();
				else if (inHand.IsInState('DownWeapon') && (Weapon == None))
					bSwitch = True;
			}
			else
			{
				bSwitch = True;
			}
		}
		else
		{
			bSwitch = True;
		}

		// OK to actually switch?
		if (bSwitch)
		{
			SetInHand(inHandPending);
			SelectedItem = inHandPending;

			if (inHand != None)
			{
				if (inHand.IsA('SkilledTool'))
					SkilledTool(inHand).BringUp();
				else if (inHand.IsA('DeusExWeapon'))
					ShiftersSwitchWeapon(DeusExWeapon(inHand));
			}
		}
	}
	else
	{
		bInHandTransition = False;

		// Added this code because it's now possible to reselect an in-hand
		// item while we're putting it down, so we need to bring it back up...

		if (inHand != None)
		{
			// if we put the item away, bring it back up
			if (inHand.IsA('SkilledTool'))
			{
				if (inHand.IsInState('Idle2'))
					SkilledTool(inHand).BringUp();
			}
			else if (inHand.IsA('DeusExWeapon'))
			{
				if (inHand.IsInState('DownWeapon') && (Weapon == None))
					ShiftersSwitchWeapon(DeusExWeapon(inHand));
			}
		}
	}
	
	if (inHand != None)
	{
		if (bCloaked)
			inHand.Style = STY_Translucent;
		else
			inHand.Style = Default.Style;
	}	

	UpdateCarcassEvent();
}

exec function ShiftersSwitchWeapon (weapon newweapon)
{
	if ( Weapon == None )
	{
		PendingWeapon = newWeapon;
		ChangedWeapon();
	}
	else if ( Weapon != newWeapon )
	{
		PendingWeapon = newWeapon;
		if ( !Weapon.PutDown() )
			PendingWeapon = None;
	}
}

function DropDecoration()
{
	local Vector X, Y, Z, dropVect, origLoc, HitLocation, HitNormal, extent;
	local float velscale, size, mult;
	local bool bSuccess;
	local Actor hitActor;

	bSuccess = False;

	if (CarriedDecoration != None)
	{
		origLoc = CarriedDecoration.Location;
		GetAxes(Rotation, X, Y, Z);

		// if we are highlighting something, try to place the object on the target
		if ((FrobTarget != None) && !FrobTarget.IsA('Pawn'))
		{
			CarriedDecoration.Velocity = vect(0,0,0);

			// try to drop the object about one foot above the target
			size = FrobTarget.CollisionRadius - CarriedDecoration.CollisionRadius * 2;
			dropVect.X = size/2 - FRand() * size;
			dropVect.Y = size/2 - FRand() * size;
			dropVect.Z = FrobTarget.CollisionHeight + CarriedDecoration.CollisionHeight + 16;
			dropVect += FrobTarget.Location;
		}
		else
		{
			// throw velocity is based on augmentation
			if (AugmentationSystem != None)
			{
				mult = AugmentationSystem.GetAugLevelValue(class'AugMuscle');
				if (mult == -1.0)
					mult = 1.0;
			}

			if (IsLeaning())
				CarriedDecoration.Velocity = vect(0,0,0);
			else
				CarriedDecoration.Velocity = Vector(ViewRotation) * mult * 500 + vect(0,0,220) + 40 * VRand();

			// scale it based on the mass
			velscale = FClamp(CarriedDecoration.Mass / 20.0, 1.0, 40.0);

			CarriedDecoration.Velocity /= velscale;
			dropVect = Location + (CarriedDecoration.CollisionRadius + CollisionRadius + 4) * X;
			dropVect.Z += BaseEyeHeight;
		}

		// is anything blocking the drop point? (like thin doors)
		if (FastTrace(dropVect))
		{
			if (TNMCarcass(CarriedDecoration) != None)
				CarriedDecoration.SetCollision(True, False, False);
			else
				CarriedDecoration.SetCollision(True, True, True);
			CarriedDecoration.bCollideWorld = True;

			// check to see if there's space there
			extent.X = CarriedDecoration.CollisionRadius;
			extent.Y = CarriedDecoration.CollisionRadius;
			extent.Z = 1;
			hitActor = Trace(HitLocation, HitNormal, dropVect, CarriedDecoration.Location, True, extent);

			if ((hitActor == None) && CarriedDecoration.SetLocation(dropVect))
				bSuccess = True;
			else
			{
				CarriedDecoration.SetCollision(False, False, False);
				CarriedDecoration.bCollideWorld = False;
			}
		}

		// For a carried player carcass, if a nearby wall blocked the forward drop point, allow setting the body down at the carrier's feet
		if (!bSuccess && TNMCarcass(CarriedDecoration) != None)
		{
			dropVect = Location;
			CarriedDecoration.SetCollision(True, False, False);
			CarriedDecoration.bCollideWorld = True;
			if (CarriedDecoration.SetLocation(dropVect))
				bSuccess = True;
			else
			{
				CarriedDecoration.SetCollision(False, False, False);
				CarriedDecoration.bCollideWorld = False;
			}
		}

		// if we can drop it here, then drop it
		if (bSuccess)
		{
			CarriedDecoration.bWasCarried = True;
			CarriedDecoration.SetBase(None);
			CarriedDecoration.SetPhysics(PHYS_Falling);
			if(CarriedDecoration.IsA('CDCaseClosed') || 
			   CarriedDecoration.IsA('Doll') || 
			   CarriedDecoration.IsA('Barrel1') || 
			   CarriedDecoration.IsA('TNMDVDCase') ||
			   CarriedDecoration.IsA('DeusExCarcass'))
			{
				CarriedDecoration.SetCollisionSize(CarriedDecoration.Default.CollisionRadius,
				                                   CarriedDecoration.Default.CollisionHeight);
			}
			CarriedDecoration.Instigator = Self;

			// turn off translucency
			CarriedDecoration.Style = CarriedDecoration.Default.Style;
			CarriedDecoration.bUnlit = CarriedDecoration.Default.bUnlit;
			if (CarriedDecoration.IsA('DeusExDecoration'))
				DeusExDecoration(CarriedDecoration).ResetScaleGlow();

			CarriedDecoration = None;
		}
		else
		{
			// otherwise, don't drop it and display a message
			CarriedDecoration.SetLocation(origLoc);
			ClientMessage(CannotDropHere);
		}
	}
}

//Prevented inventory stacking exploit (thanks shifter)
function Bool IsEmptyItemSlot( Inventory anItem, int col, int row )
{
	local int slotsCol;
	local int slotsRow;
	local Bool bEmpty;
	local Inventory inv;
	local DeusExRootWindow root;
	local PersonaScreenInventory winInv;

	if ( anItem == None )
		return False;

	root = DeusExRootWindow(rootWindow);   
	if (root != None)
		winInv = PersonaScreenInventory(root.GetTopWindow());
	if(winInv == None || !winInv.bDragging)
	{
		inv = Inventory;
		while(inv != None)
		{
			SetInvSlots(inv, 1);
			inv = inv.Inventory;
		}	
	}

	// First make sure the item can fit horizontally
	// and vertically
	if (( col + anItem.invSlotsX > maxInvCols ) ||
		( row + anItem.invSlotsY > maxInvRows ))
			return False;

	if ((Level.NetMode != NM_Standalone) && (bBeltIsMPInventory))
		return True;

	// Now check this and the needed surrounding slots
	// to see if all the slots are empty

	bEmpty = True;
	for( slotsRow=0; slotsRow < anItem.invSlotsY; slotsRow++ )
	{
		for ( slotsCol=0; slotsCol < anItem.invSlotsX; slotsCol++ )
		{
			if ( invSlots[((slotsRow + row) * maxInvCols) + (slotsCol + col)] == 1 )
			{
				bEmpty = False;
				break;
			}
		}

		if ( !bEmpty )
			break;
	}

	return bEmpty;
}

// The absolute JANK involved in this function... lol
// -bogie

function bool GetUnlock(string character)
{
	local bool b;

	b = false;
	
	switch(character)
	{
		case "DeusDiablo":
			b = bMPCR_DeusDiabloUnlocked;
			break;
		case "KylieGriffin":
			b = bMPCR_KylieGriffinUnlocked;
			break;
		case "Endar":
			b = bMPCR_EndarUnlocked;
			break;
		case "RealZeroPresence":
			b = bMPCR_RealZeroPresenceUnlocked;
			break;
		case "Firewall":
			b = bMPCR_FirewallUnlocked;
			break;
		case "FirewallAlpha":
			b = bMPCR_FirewallAlphaUnlocked;
			break;
		case "TheRenegadeMaster":
			b = bMPCR_TheRenegadeMasterUnlocked;
			break;
		case "MadMax":
			b = bMPCR_MadMaxUnlocked;
			break;
		case "Mole":
			b = bMPCR_MoleUnlocked;
			break;
		case "WaltonSimons":
			b = bMPCR_WaltonSimonsUnlocked;
			break;
		case "Chris":
			b = bMPCR_ChrisUnlocked;
			break;
		case "Bogie":
			b = bMPCR_BogieUnlocked;
			break;
	}

	return b;
}

event LogTNMVersion()
{
	Log("The Nameless Mod "$TNM_VERSION_STRING, 'TNMVersion');
}

function string GetTNMVersion()
{
	local string str;
	
	str = string(REVISION_VERSION_MAJOR);
	if (REVISION_VERSION_MINOR > 0)
		str = str $ "." $ REVISION_VERSION_MINOR;
	if (REVISION_VERSION_BUILD > 0)
		str = str $ "." $ REVISION_VERSION_BUILD;
	if (REVISION_VERSION_REVISION > 0)
		str = str $ "." $ REVISION_VERSION_REVISION;
	if (TNM_VERSION_STRING != "")
		str = str $ TNM_VERSION_STRING;
	return str;
}

simulated exec function SwitchAmmo()
{
	if (DeusExWeapon(inHand) != None)
		DeusExWeapon(inHand).CycleAmmo();	
}

// ----------------------------------------------------------------------
// RefreshSystems()
// DEUS_EX AMSD For keeping multiplayer working in better shape
// ----------------------------------------------------------------------

// The ammo the player picked in the inventory info pane. Don't use
// PersonaInventoryInfoWindow.GetSelectedAmmo() here: Clear() destroys the ammo
// buttons without resetting selectedAmmoButton, so after clicking a different
// item it reads a freed window and crashes. winTileAmmo is nulled by Clear(),
// so walking its live children is safe.
simulated function class<Ammo> CoopGetLoadedAmmoButton(PersonaInventoryInfoWindow winInfo)
{
	local Window w;

	if ((winInfo == None) || (winInfo.winTileAmmo == None))
		return None;

	for (w = winInfo.winTileAmmo.GetTopChild(); w != None; w = w.GetLowerSibling())
		if ((PersonaAmmoDetailButton(w) != None) && PersonaAmmoDetailButton(w).IsLoaded())
			return PersonaAmmoDetailButton(w).GetAmmo();

	return None;
}

simulated function RefreshSystems(float DeltaTime)
{
	local DeusExRootWindow root;
	local TNMOggMusicManager ogg;
	local PlayerReplicationInfo pri;
	local ColorTheme theme;
	local PersonaScreenInventory invWin;
	local PersonaScreenAugmentations augWin;
	local DeusExWeapon selWeap;
	local Class<Ammo> selAmmo;
	local Augmentation anAug;
	local PrecipitationNode precipNode;
	local int i, curAugSum;

	if (Viewport(Player) != None)
		EnsureCoopHUDWindows();

	if ((Level.NetMode == NM_Client) && (Viewport(Player) != None))
	{
		EnsureClientUI();
		TrestkonTick(DeltaTime);
		if (Song != None && Level.Song == None)
			ClientSetMusic(None, 0, 255, MTRAN_Instant);
		if (cachedClientOgg != None && !cachedClientOgg.bDeleteMe)
		{
			if (cachedClientOgg.Role != ROLE_SimulatedProxy)
				cachedClientOgg.Role = ROLE_SimulatedProxy;
			cachedClientOgg.CoopNativeGetPosition();
		}
		if (subtitleClearTimer > 0.0)
		{
			subtitleClearTimer -= DeltaTime;
			if (subtitleClearTimer <= 0.0)
			{
				subtitleClearTimer = 0.0;
				ClientHideSubtitle();
			}
		}
		if (infolinkClearTimer > 0.0)
		{
			infolinkClearTimer -= DeltaTime;
			if (infolinkClearTimer <= 0.0)
			{
				infolinkClearTimer = 0.0;
				root = DeusExRootWindow(rootWindow);
				if (root != None && root.hud != None && root.hud.infolink != None && dataLinkPlay == None)
					root.hud.DestroyInfoLinkWindow();
			}
		}

		root = DeusExRootWindow(rootWindow);
		if (root != None)
		{
			invWin = PersonaScreenInventory(root.GetTopWindow());
			if (invWin != None && invWin.selectedItem != None && invWin.winInfo != None)
			{
				selWeap = DeusExWeapon(invWin.selectedItem.GetClientObject());
				selAmmo = None;
				if (selWeap != None)
					selAmmo = CoopGetLoadedAmmoButton(invWin.winInfo);
				if (selWeap != None && selAmmo != None && selAmmo != selWeap.AmmoName)
				{
					for (i = 0; i < 3; i++)
					{
						if (selWeap.AmmoNames[i] == selAmmo)
						{
							selWeap.LoadAmmo(i);
							selWeap.AmmoName = selAmmo;
							break;
						}
					}
				}
			}

			augWin = PersonaScreenAugmentations(root.GetTopWindow());
			if (augWin != None && AugmentationSystem != None)
			{
				curAugSum = 0;
				for (anAug = AugmentationSystem.FirstAug; anAug != None; anAug = anAug.next)
				{
					if (anAug.bHasIt)
						curAugSum += (anAug.CurrentLevel + 1);
				}
				if (curAugSum != lastClientAugLevelSum)
				{
					lastClientAugLevelSum = curAugSum;
					if (augWin.selectedAugButton != None && augWin.selectedAug != None)
					{
						PersonaAugmentationItemButton(augWin.selectedAugButton).SetLevel(augWin.selectedAug.GetCurrentLevel());
						augWin.selectedAug.UpdateInfo(augWin.winInfo);
					}
					augWin.UpdateAugCans();
					augWin.EnableButtons();
				}
			}
		}
	}

	// Refresh UI always, useful for medbot health screen updates
	if (LastRefreshTime < 0)
		LastRefreshTime = 0;

	LastRefreshTime = LastRefreshTime + DeltaTime;

	if (LastRefreshTime < 0.25)
		return;

	root = DeusExRootWindow(rootWindow);
	if (root != None)
		root.RefreshDisplay(LastRefreshTime);

	LastRefreshTime = 0;
	
	if (Level.NetMode == NM_Standalone)
		return;

	if (Role == ROLE_Authority)
		return;

	if (Viewport(Player) != None)
	{
		cachedClientOgg = None;
		foreach AllActors(class'TNMOggMusicManager', ogg)
		{
			cachedClientOgg = ogg;
			if (ogg.Role != ROLE_SimulatedProxy)
				ogg.Role = ROLE_SimulatedProxy;
			ogg.CoopNativeGetPosition();
		}
		foreach AllActors(class'PrecipitationNode', precipNode)
		{
			if (precipNode.ControllingZone == None && precipNode.GetStateName() != 'broken')
				precipNode.GotoState('broken');
		}
		foreach AllActors(class'PlayerReplicationInfo', pri)
		{
			if (pri.Owner != None)
				pri.SetOwner(None);
		}
		foreach AllActors(class'ColorTheme', theme)
		{
			if (theme.Owner != None)
				theme.SetOwner(None);
		}
	}

	if (AugmentationSystem != None)
		AugmentationSystem.RefreshAugDisplay();

	RepairInventory();
}

// ----------------------------------------------------------------------
// AllWeapons()
// ----------------------------------------------------------------------

exec function AllWeapons()
{
	local Vector loc;

	if (!bCheatsEnabled)
		return;

	loc = Location + 2 * CollisionRadius * Vector(ViewRotation);
	
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponBlackBox", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponBlowPipe", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponDaikatana", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponDoubleGuns", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponFatRifle", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponFireBlade", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponFireExting", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponFoon", 				class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponGibinator", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponHammer", 				class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponKatana", 				class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponLaser", 				class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponMine", 				class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponNapalmLauncher", 		class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponPlasmaNade", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponQdRocket", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponScrewDriver", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponShotgun", 				class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponSpork", 				class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponSporkGolden", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponThrowFoon", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponThrowSpork", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMAssaultGun", 		class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMAssaultShotgun", 	class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMBaton", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMCombatKnife", 		class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMCrowbar", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMEMPGrenade", 		class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMFlamethrower", 		class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMGasGrenade", 		class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMGEPGun", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMHideAGun", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMLAM", 				class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMLAW", 				class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMMiniCrossbow", 		class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMNanoSword", 		class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMNanoVirusGrenade", 	class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMPepperGun", 		class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMPistol", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMPlasmaRifle", 		class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMProd", 				class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMRifle", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMSawedOffShotgun", 	class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMShuriken", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMStealthPistol", 	class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTNMSword", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponTripBomb", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponWrench", 				class'Class', True)),,, loc);
	
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponYAAAARRGHPistol", 		class'Class', True)),,, loc);
	// Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponBroom", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponKatanaRonin", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponKatanaSlicer", 		class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponLAWSpent", 			class'Class', True)),,, loc);
	// Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponSpiderBotMini", 	class'Class', True)),,, loc);
	// Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponSpiderCannon", 		class'Class', True)),,, loc);
	
	Spawn(class'WeaponFireStaff',,, loc);
	// Spawn(class'WeaponFists',,, loc);
	Spawn(class'WeaponMolBottle',,, loc);
	
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponUniqueAO", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponUniqueKylie", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponUniqueNVS", 			class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WeaponUniqueZP", 			class'Class', True)),,, loc);
	
	GiveFistType(1);
	GiveFistType(2);
	GiveFistType(3);
}

// ----------------------------------------------------------------------
// AllItems()
// ----------------------------------------------------------------------

exec function AllItems()
{
	local Vector loc;

	if (!bCheatsEnabled)
		return;

	loc = Location + 2 * CollisionRadius * Vector(ViewRotation);
	
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.Beans", 								class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.ChemicalBottle", 					class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.DogBlood", 							class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.FistPickupLethal", 					class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.FistPickupShock", 					class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.FistPickupStun", 					class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.FloppyDisk", 						class'Class', True)),,, loc);
	// Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.GoatDisguise", 						class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.KarkianSnot", 						class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.KetchupBar", 						class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.NosferatusTeeth", 					class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.PaintingTube", 						class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.PlasticCoffee", 						class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.PosterTube", 						class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.RedBiocell", 						class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.UraniumStick", 						class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.VirusDisk", 							class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.LollerSkates", 						class'Class', True)),,, loc);
	
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.TNMVialCrack", 						class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.TNMAugmentationUpgradeCannister", 	class'Class', True)),,, loc);
	
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.AugCannisterALER", 					class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.AugCannisterBPES", 					class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.AugCannisterCRT", 					class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.AugCannisterHS", 					class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.AugCannisterMC", 					class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.AugCannisterSDAD", 					class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.AugCannisterSHPR", 					class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.AugCannisterSS", 					class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.AugCannisterTV", 					class'Class', True)),,, loc);
	
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.Credits2000", 						class'Class', True)),,, loc);
	Spawn(Class<Inventory>(DynamicLoadObject("TNMItems.WineBottleTrigger", 					class'Class', True)),,, loc);
	
	Spawn(class'GasMask',,, 			loc);
	
	Spawn(class'AugmentationUpgradeCannister',,,loc);
	Spawn(class'Binoculars',,, 			loc);
	Spawn(class'BioelectricCell',,, 	loc);
	Spawn(class'Candybar',,, 			loc);
	Spawn(class'AdaptiveArmor',,, 		loc);
	Spawn(class'BallisticArmor',,, 		loc);
	Spawn(class'HazMatSuit',,, 			loc);
	Spawn(class'Rebreather',,, 			loc);
	Spawn(class'TechGoggles',,, 		loc);
	Spawn(class'Cigarettes',,, 			loc);
	Spawn(class'Credits',,, 			loc);
	Spawn(class'FireExtinguisher',,, 	loc);
	Spawn(class'Flare',,, 				loc);
	Spawn(class'Liquor40oz',,, 			loc);
	Spawn(class'LiquorBottle',,, 		loc);
	Spawn(class'MedKit',,, 				loc);
	Spawn(class'Lockpick',,, 			loc);
	Spawn(class'Multitool',,, 			loc);
	Spawn(class'SodaCan',,, 			loc);
	Spawn(class'SoyFood',,, 			loc);
	Spawn(class'VialAmbrosia',,, 		loc);
	Spawn(class'VialCrack',,, 			loc);
	Spawn(class'WineBottle',,, 			loc);
	Spawn(class'WeaponModAccuracy',,, 	loc);
	Spawn(class'WeaponModClip',,, 		loc);
	Spawn(class'WeaponModLaser',,, 		loc);
	Spawn(class'WeaponModRange',,, 		loc);
	Spawn(class'WeaponModRecoil',,, 	loc);
	Spawn(class'WeaponModReload',,, 	loc);
	Spawn(class'WeaponModScope',,, 		loc);
	Spawn(class'WeaponModSilencer',,, 	loc);
}



// ----------------------------------------------------------------------
// AllImages()
// ----------------------------------------------------------------------

exec function AllImages()
{
	local Vector loc;
	local Inventory item;

	if (!bCheatsEnabled)
		return;

	// loc = Location + 2 * CollisionRadius * Vector(ViewRotation);
	loc = Location;
	
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_ABISatelitePhoto", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_ATCSatScan", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_AutopilotCodes", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_BeefmanMurder", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_CamAds", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_CorporateMap", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_DowntownMap", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_DXI_A51b", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_DXI_caverns", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_DXI_MCR", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_FireWall2", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_Gibinator", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_GoatPortal", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_Helipad", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_Kevo", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_LlamaAssassin", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_MelkFountain", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_NoteHao", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_NoteVavrek", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_NSCMainFloor", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_NSCTopFloor", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_PHATRifle", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_Poke", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_QuadSchematics", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_ServerCodes", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_SewerMap", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_Spyware", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_SS04", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_SS01", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_SS02", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_SS03", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_WCFloor2", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_WCFloor3", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_WCSublevel", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_ZPAugs", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_ZPFolder", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
	item = Spawn(Class<Inventory>(DynamicLoadObject("TNMDataVault.TNMDV_ZPSniperNest", 								class'Class', True)),,, loc);
	item.Frob(Self, None);
}

exec function AllAmmo()
{
	local Inventory item, nextItem;
	local Ammo foundAmmos[128], newAmmo;
	local int i, j;
	local bool bAmmoFound;
	
	if (bCheatsEnabled)
	{
		Super.AllAmmo();
		
		for(item = Inventory; item != None; item = nextItem)
		{
			nextItem = item.Inventory;
			
			// To make AllAmmo respect Biomod's max grenades change
			if (Ammo(item)!=None && !item.bDeleteMe) 
			{
				Ammo(item).AddAmmo(999999);
				foundAmmos[i] = Ammo(item);
				i++;
			}				
				
			if (!item.IsA('Ammo') && !item.IsA('NanoKeyRing') && !item.IsA('Nanokey') && !item.IsA('DataVaultImage'))
			{
				nextItem = item.Inventory;
				UpdateBeltText(item);
			}
		}
		
		for(item = Inventory; item != None; item = nextItem)
		{
			nextItem = item.Inventory;
			
			if (DeusExWeapon(item) != None)
			{
				for (j=0;j < ArrayCount(DeusExWeapon(item).AmmoNames);j++)
				{
					if (DeusExWeapon(item).AmmoNames[j] != None)
					{
						bAmmoFound = False;
						for(i=0;i < ArrayCount(foundAmmos);i++)
						{
							if (foundAmmos[i] == None)
								break;
								
							if (foundAmmos[i].Class == DeusExWeapon(item).AmmoNames[j])
								bAmmoFound = True;
						}
						if (!bAmmoFound)
						{
							NewAmmo = Spawn(DeusExWeapon(item).AmmoNames[j],,, Location);
							NewAmmo.Frob(Self, None);
							NewAmmo.AddAmmo(999999);
						}
					}
				}
				DeusExWeapon(item).ClipCount = 0;
			}
				
			if (!item.IsA('Ammo') && !item.IsA('NanoKeyRing') && !item.IsA('Nanokey') && !item.IsA('DataVaultImage'))
			{
				nextItem = item.Inventory;
				UpdateBeltText(item);
			}
		}
	}
}

// ----------------------------------------------------------------------
// ParseRightClick()
// ----------------------------------------------------------------------

exec function ParseRightClick()
{
	//
	// ParseRightClick deals with things in the WORLD
	//
	// Precedence:
	// - Pickup highlighted Inventory
	// - Frob highlighted object
	// - Grab highlighted Decoration
	// - Put away (or drop if it's a deco) inHand
	//
	local AutoTurret turret;
	local int ViewIndex;
	local bool bPlayerOwnsIt;
	local Inventory oldFirstItem;
	local Inventory oldInHand;
	local Decoration oldCarriedDecoration;
	local Vector loc;
	local Trestkon HostPlayer;
	local TNMConWindowActive win;

	if (RestrictInput())
		return;

	if (Level.NetMode != NM_Standalone && Role == ROLE_Authority && NetConnection(Player) != None)
	{
		HostPlayer = Trestkon(GetPlayerPawn());
		if (HostPlayer != None && tnmconplay(HostPlayer.conPlay) != None)
		{
			win = TNMConWindowActive(HostPlayer.conPlay.conWinThird);
			if (win != None && win.numChoices > 0)
			{
				tnmconplay(HostPlayer.conPlay).SelectCoopChoice(Clamp(clientSelectedConChoice, 0, win.numChoices - 1));
				return;
			}
			else if (HostPlayer.conPlay.con != None && !HostPlayer.conPlay.con.bFirstPerson && (FrobTarget == None || FrobTarget == HostPlayer.conPlay.startActor || FrobTarget == HostPlayer.conPlay.invokeActor))
			{
				tnmconplay(HostPlayer.conPlay).AdvanceCoopSpeech();
				return;
			}
		}
	}

	if (Level.NetMode == NM_Client && bClientHasConChoices && clientConChoiceCount > 0 && FrobTarget == None)
	{
		ConfirmClientConChoice(clientSelectedConChoice);
		return;
	}
	else if (Level.NetMode == NM_Client && !bClientHasConChoices && FrobTarget == None && DeusExRootWindow(rootWindow) != None && DeusExRootWindow(rootWindow).hud != None && DeusExRootWindow(rootWindow).hud.conWindow != None)
	{
		ServerSyncBoolFlag('CoopConNext', True);
		return;
	}
		
	if (bSpyDroneActive)
		return;

	oldFirstItem = Inventory;
	oldInHand = inHand;
	oldCarriedDecoration = CarriedDecoration;
	
	if (FrobTarget != None && !FrobTarget.bDeleteMe && ((FrobTarget.IsA('DeusExMover') && DeusExMover(FrobTarget).bFrobbable) || !FrobTarget.IsA('DeusExMover'))) // If the mover isn't frobbable, don't try to frob it, just put our weapon away or drop the carcass
	{
		loc = FrobTarget.Location;
		// First check if this is a NanoKey, in which case we just
		// want to add it to the NanoKeyRing without disrupting
		// what the player is holding

		if (FrobTarget.IsA('NanoKey'))
		{
			PickupNanoKey(NanoKey(FrobTarget));
			FrobTarget.Destroy();
			FrobTarget = None;
			return;
		}
		else if (FrobTarget.IsA('Inventory'))
		{
			// If this is an item that can be stacked, check to see if 
			// we already have one, in which case we don't need to 
			// allocate more space in the inventory grid.
			// 
			// TODO: This logic may have to get more involved if/when 
			// we start allowing other types of objects to get stacked.

			if (HandleItemPickup(FrobTarget, True) == False)
				return;
				
			if (FrobTarget != None)
			{
				// if the frob succeeded, put it in the player's inventory
				//DEUS_EX AMSD ARGH! Because of the way respawning works, the item I pick up
				//is NOT the same as the frobtarget if I do a pickup.  So how do I tell that
				//I've successfully picked it up?  Well, if the first item in my inventory 
				//changed, I picked up a new item.
				if ( (Inventory(FrobTarget) != None && Inventory(FrobTarget).Owner == Self) ||
				  ((Level.NetMode != NM_Standalone) && (oldFirstItem != Inventory)) )
				{
					if (Inventory(FrobTarget) != None && Inventory(FrobTarget).Owner == Self)
						FindInventorySlot(Inventory(FrobTarget));
					else
						FindInventorySlot(Inventory);
					FrobTarget = None;
				}
			}
		}
		else if (FrobTarget.IsA('Decoration') && Decoration(FrobTarget).bPushable)
		{
			GrabDecoration();
		}
		else
		{
			if (( Level.NetMode != NM_Standalone ) && ( TeamDMGame(DXGame) != None ))
			{
				if ( FrobTarget.IsA('LAM') || FrobTarget.IsA('GasGrenade') || FrobTarget.IsA('EMPGrenade'))
				{
					if ((ThrownProjectile(FrobTarget).team == PlayerReplicationInfo.team) && ( ThrownProjectile(FrobTarget).Owner != Self ))
					{
						if ( ThrownProjectile(FrobTarget).bDisabled )		// You can re-enable a grenade for a teammate
						{
							ThrownProjectile(FrobTarget).ReEnable();
							return;
						}
						MultiplayerNotifyMsg( MPMSG_TeamLAM );
						return;
					}
				}
				if ( FrobTarget.IsA('ComputerSecurity') && (PlayerReplicationInfo.team == ComputerSecurity(FrobTarget).team) )
				{
					// Let controlling player re-hack his/her own computer
					bPlayerOwnsIt = False;
					foreach AllActors(class'AutoTurret',turret)
					{
						for (ViewIndex = 0; ViewIndex < ArrayCount(ComputerSecurity(FrobTarget).Views); ViewIndex++)
						{
							if (ComputerSecurity(FrobTarget).Views[ViewIndex].turretTag == turret.Tag)
							{
								if (( turret.safeTarget == Self ) || ( turret.savedTarget == Self ))
								{
									bPlayerOwnsIt = True;
									break;
								}
							}
						}
					}
					if ( !bPlayerOwnsIt )
					{
						MultiplayerNotifyMsg( MPMSG_TeamComputer );
						return;
					}
				}
			}
			// otherwise, just frob it
			DoFrob(Self, None);
		}
	}
	else
	{
		// if there's no FrobTarget, put away an inventory item or drop a decoration
		// or drop the corpse
		if ((inHand != None) && inHand.IsA('POVCorpse'))
			DropItem();
		else if (!bPlatformer) // Don't allow putting away radish weapons
			PutInHand(None);
	}

	if ((oldInHand == None) && (inHand != None))
		PlayPickupAnim(loc);
	else if ((oldCarriedDecoration == None) && (CarriedDecoration != None))
		PlayPickupAnim(loc);
}

function PlayFiring()
{
	local DeusExWeapon W;

//	ClientMessage("PlayFiring()");
	if (IsInState('Dying'))
		return;

	W = DeusExWeapon(Weapon);

	if (W != None)
	{
		if (IsInState('PlayerSwimming') || (Physics == PHYS_Swimming))
			LoopAnim('TreadShoot',,0.1);
		else if (W.bHandToHand)
		{
			if (bAnimFinished || (AnimSequence != 'Attack'))
				PlayAnim('Attack',1/W.ShotTime,0.1);
		}
		else if (bIsCrouching || IsLeaning())
			LoopAnim('CrouchShoot',,0.1);
		else
		{
			if (HasTwoHandedWeapon())
				LoopAnim('Shoot2H',,0.1);
			else
				LoopAnim('Shoot',,0.1);
		}
	}
	
	// Super.PlayFiring();
}

function PlayWeaponSwitch(Weapon newWeapon)
{
	if (IsInState('Dying'))
		return;
	
	Super.PlayWeaponSwitch(newWeapon);
}

// ----------------------------------------------------------------------
// ParseLeftClick()
// ----------------------------------------------------------------------

exec function ParseLeftClick()
{
	local bool bDroneActive;
	local Trestkon HostPlayer;
	local TNMConWindowActive win;

	if (Level.NetMode != NM_Standalone && Role == ROLE_Authority && NetConnection(Player) != None)
	{
		HostPlayer = Trestkon(GetPlayerPawn());
		if (HostPlayer != None && tnmconplay(HostPlayer.conPlay) != None)
		{
			win = TNMConWindowActive(HostPlayer.conPlay.conWinThird);
			if (win != None && win.numChoices > 0)
			{
				tnmconplay(HostPlayer.conPlay).SelectCoopChoice(Clamp(clientSelectedConChoice, 0, win.numChoices - 1));
				return;
			}
			else if (HostPlayer.conPlay.con != None && !HostPlayer.conPlay.con.bFirstPerson)
			{
				tnmconplay(HostPlayer.conPlay).AdvanceCoopSpeech();
				return;
			}
		}
	}

	if (Level.NetMode == NM_Client && bClientHasConChoices && clientConChoiceCount > 0)
	{
		ConfirmClientConChoice(clientSelectedConChoice);
		return;
	}
	
	bDroneActive = bSpyDroneActive;
	
	Super.ParseLeftClick();
	
	if (RestrictInput())
		return;

	// Don't bring up fists when detonating spydrone.
	if (bDroneActive)
		return;
	
	if ((inHand == None) && (!bInHandTransition) && (!bPlatformer) && (LastInHandTimer <= 0))
		SelectFists();
}




// ----------------------------------------------------------------------
// CreateDrone
// ----------------------------------------------------------------------
function CreateDrone()
{
	local Vector loc;
	local AugDrone anAug;
	// local AugLight aLight;

	loc = (2.0 + class'SpyDrone'.Default.CollisionRadius + CollisionRadius) * Vector(ViewRotation);
	loc.Z = BaseEyeHeight;
	loc += Location;
	aDrone = Spawn(class'TNM.TNMSpyDrone', Self,, loc, ViewRotation);
	if (aDrone != None)
	{
		// aLight = AugLight(AugmentationSystem.FindAugmentation(class'AugLight'));
	
		aDrone.Speed = 3 * spyDroneLevelValue;
		aDrone.MaxSpeed = 3 * spyDroneLevelValue;
		aDrone.Damage = 5 * spyDroneLevelValue;
		aDrone.blastRadius = 8 * spyDroneLevelValue;
		
		// if (aLight != None && aLight.bIsActive)
		// {
			// aLight.Deactivate();
			// aLight.Activate();
		// }
		// window construction now happens in Tick()
	}
	else
	{
		// If no drone spawns deactivate and don't punish them with a timer.
		anAug = AugDrone(AugmentationSystem.FindAugmentation(class'AugDrone'));
		if (anAug != None)
		{
			anAug.Deactivate();
			anAug.lastDroneTime = anAug.lastDroneTime - anAug.reconstructTime;
		}
	}
}

// ----------------------------------------------------------------------
// DripWater()
// ----------------------------------------------------------------------

singular function DripWater(float deltaTime)
{
	local float  dripPeriod;
	local float  adjustedRate;
	local vector waterVector;
	local vector vel;
	local rotator SpawnRotation;
	
	// if (!DeusExGameInfo(Level.Game).SpawnEffects())
	// {
		// dripRate = 0;
		// waterDripCounter = 0;
		// return;
	// }

	// Copied from ScriptedPawn::Tick()
	dripRate = FClamp(dripRate, 0.0, 15.0);
	// dripRate = FClamp(dripRate, 0.0, 1.0);
	if (dripRate > 0)
	{
		// adjustedRate = (15.0-dripRate)*1.0+0.1;  // max 10 drops per second
		adjustedRate = 1;
		dripPeriod = adjustedRate / FClamp(VSize(Velocity)/512.0, 5, 10);
		waterDripCounter += deltaTime;
		while (waterDripCounter >= dripPeriod)
		{
			vel = 0.1*Velocity;
			vel.Z = 0;
			
			SpawnRotation = rot(0,0,0);
			SpawnRotation.Pitch = 49152;
		
			waterVector = vect(0,0,1)*CollisionHeight*0.5;  // so folks don't drip from the crotch
			waterVector = VRand() * CollisionRadius;
			// if (VSize(Velocity) > 2)
				// spawn(Class'WaterDrop',Self,,waterVector+Location,rotator(Velocity-vel));
			// else
				spawn(Class'WaterDrop',Self,,waterVector+Location, SpawnRotation);
			waterDripCounter -= dripPeriod;
		}
		dripRate -= deltaTime;
	}
	if (dripRate <= 0)
	{
		dripRate   		 = 0;
		waterDripCounter = 0;
	}
}

// ----------------------------------------------------------------------
// Landed()
//
// copied from Engine.PlayerPawn new landing code for Deus Ex
// zero damage if falling from 15 feet or less
// scaled damage from 15 to 60 feet
// death over 60 feet
// ----------------------------------------------------------------------

function Landed(vector HitNormal)
{
    local vector legLocation;
	local int augLevel;
	local float augReduce, dmg;

	SpawnFootprint();
	// SpawnFootprint(); // Redundant as landing always calls PlayFootStep which also does this.
	LandBob = FMax(-50, 0.06 * Velocity.Z);
	//Note - physics changes type to PHYS_Walking by default for landed pawns
	PlayLanded(Velocity.Z);
	if (Velocity.Z < -1.4 * JumpZ)
	{
		MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
		if ((Velocity.Z < -700) && (ReducedDamageType != 'All'))
		{
			if ( Role == ROLE_Authority )
            {
				// check our jump augmentation and reduce falling damage if we have it
				// jump augmentation doesn't exist anymore - use Speed instaed
				// reduce an absolute amount of damage instead of a relative amount
				augReduce = 0;
				if (AugmentationSystem != None)
				{
					augLevel = AugmentationSystem.GetClassLevel(class'AugSpeed');
					if (augLevel >= 0)
						augReduce = 15 * (augLevel+1);
				}
				if (TNMWeapon(Weapon) != None && TNMWeapon(Weapon).Attribute == Att_Quaking)
					augReduce += 45;

				dmg = Max((-0.16 * (Velocity.Z + 700)) - augReduce, 0);
				legLocation = Location + vect(-1,0,-1);			// damage left leg
				if(dmg > 0) //If you don't take any damage, don't play the pain sound
					TakeDamage(dmg, None, legLocation, vect(0,0,0), 'fell');

				legLocation = Location + vect(1,0,-1);			// damage right leg
				if(dmg > 0)
					TakeDamage(dmg, None, legLocation, vect(0,0,0), 'fell');

				dmg = Max((-0.06 * (Velocity.Z + 700)) - augReduce, 0);
				legLocation = Location + vect(0,0,1);			// damage torso
				if(dmg > 0)
					TakeDamage(dmg, None, legLocation, vect(0,0,0), 'fell');
            }
		}
	}
	else if ( (Level.Game != None) && (Level.Game.Difficulty > 1) && (Velocity.Z > 0.5 * JumpZ) )
		MakeNoise(0.1 * Level.Game.Difficulty);
	bJustLanded = true;
}

// ----------------------------------------------------------------------
// DrawEnergyShield()
// ----------------------------------------------------------------------

function DrawEnergyShield()
{
	local EllipseEffect shield;

	shield = Spawn(class'EllipseEffect', Self,, Location, Rotation);
	if (shield != None)
		shield.SetBase(Self);
}

// check to see if the player can lift a certain decoration taking
// into account his muscle augs
// G-Flex: change this to make higher levels of AugMuscle matter more
function bool CanBeLifted(Decoration deco)
{
	local float augValue, augMult;
	local float maxLift;

	//G-Flex: was 50
	maxLift = 55;
	if (AugmentationSystem != None)
	{
		augValue = AugmentationSystem.GetAugLevelValue(class'AugMuscle');
		augMult = 1;
		if (augValue >= 0)
			augMult = Square(augValue)*1.25;
		maxLift *= augMult;
	}

	//if (!deco.bPushable || (deco.Mass > maxLift) || (deco.StandingCount > 0))
	if (deco.IsA('DeusExCarcass') && DeusExCarcass(deco).bPlayerCarcass)
	{
		return True;
	}
	else if (deco.IsA('DeusExCarcass') && DeusExCarcass(deco).bAnimalCarcass) 
	{
		if (deco.Mass <= maxLift)
			return True;
		else
			ClientMessage(TooHeavyToLift);

		return False;
	}
	else if (!deco.bPushable || deco.IsInState('Burning') ||
	(deco.IsA('DeusExDecoration') && (GetStackMass(deco) > maxLift)) || 
	(!deco.IsA('DeusExDecoration') && ((deco.StandingCount > 0) || (deco.Mass > maxLift))))
	{
		if (deco.IsInState('Burning'))
			ClientMessage(TooHotToLift);
		else if (deco.bPushable)
			ClientMessage(TooHeavyToLift);
		else
			ClientMessage(CannotLift);

		return False;
	}

	return True;
}

function GrabDecoration()
{
	local actor a;
	
	// can't grab decorations while leaning
	if (IsLeaning())
		return;

	// can't grab decorations while holding something else
	if (inHand != None)
	{
		ClientMessage(HandsFull);
		return;
	}

	if (carriedDecoration == None)
		if ((FrobTarget != None) && FrobTarget.IsA('Decoration') && (Weapon == None))
			if (CanBeLifted(Decoration(FrobTarget)))
			{
				foreach FrobTarget.BasedActors(class'Actor', A)
				{
					A.SetBase(None);
					A.SetPhysics(PHYS_Falling);
				}
				CarriedDecoration = Decoration(FrobTarget);
				CarriedDecoration.NetPriority = 2;
				PutCarriedDecorationInHand();
			}
}

// ----------------------------------------------------------------------
// GetStackMass()
// 
// G-Flex: gets the mass of the decoration and all others using it as a base
// ----------------------------------------------------------------------

// This *should* be in DeusExDecoration, but it's TNM.
function float GetStackMass(actor baseThing)
{
	local actor standingThing;
	local float totalMass;
	local int          i;
	
	//G-Flex: only care about the weight of decorations, not weapons and pickups and stuff
	totalMass = 0;
	if (baseThing.IsA('DeusExDecoration'))
		totalMass = baseThing.Mass;
	//G-Flex: don't bother if we're not a base for anything
	if (baseThing.StandingCount > 0)
		foreach baseThing.BasedActors(class'actor', standingThing)
			totalMass += GetStackMass(standingThing);
			
	if (Seat(baseThing) != None)
	{
		for (i=0; i<ArrayCount(Seat(baseThing).sittingActor); i++)
		{
			if (Seat(baseThing).sittingActor[i] != None)
			{
				if (((ScriptedPawn(Seat(baseThing).sittingActor[i]) != None) &&
					 ScriptedPawn(Seat(baseThing).sittingActor[i]).bSitting))
				{
					totalMass += ScriptedPawn(Seat(baseThing).sittingActor[i]).Mass;
				}
			}
		}
	}
	
	return totalMass;
}


// ----------------------------------------------------------------------
// DeleteInventory()
// ----------------------------------------------------------------------

function bool DeleteInventory(inventory item)
{
	local bool retval;
	local DeusExRootWindow root;
	local PersonaScreenInventory winInv;

	// If the item was inHand, clear the inHand
	if (inHand == item)
	{
		SetInHand(None);
		if (inHandPending == item)	// Don't do this if we're trying to switch to another item
			SetInHandPending(None);
	}

	// Make sure the item is removed from the inventory grid
	RemoveItemFromSlot(item);

	root = DeusExRootWindow(rootWindow);

	if (root != None)
	{
		// If the inventory screen is active, we need to send notification
		// that the item is being removed
		winInv = PersonaScreenInventory(root.GetTopWindow());
		if (winInv != None)
			winInv.InventoryDeleted(item);

		// Remove the item from the object belt
		root.DeleteInventory(item);
	}
	else //In multiplayer, we often don't have a root window when creating corpse, so hand delete
	{
		item.bInObjectBelt = false;
		item.beltPos = -1;
	}

	return Super(PlayerPawnExt).DeleteInventory(item);
}

// ----------------------------------------------------------------------
// UpdateAugmentationDisplayStatus()
// ----------------------------------------------------------------------

function UpdateAugmentationDisplayStatus(Augmentation aug)
{
	if (aug != None && DeusExRootWindow(rootWindow) != None && DeusExRootWindow(rootWindow).hud != None && DeusExRootWindow(rootWindow).hud.activeItems != None)
		DeusExRootWindow(rootWindow).hud.activeItems.UpdateAugIconStatus(aug);
}

exec function TrestWoke()
{
	local TNMPawn  TNMP;
	local TNMRobot TNMR;
	
	if (!bCheatsEnabled)
		return;

	foreach AllActors(class'TNMPawn', TNMP)
	{
		TNMP.bFirewall = true;
	}

	foreach AllActors(class'TNMRobot', TNMR)
	{
		TNMR.bFirewall = true;
	}
}

exec function LookAtThisDood()
{
	local TNMPawn  TNMP;
	local TNMWeapon TNMW;
	
	if (!bCheatsEnabled)
		return;
		
	bruhSound = Sound'TNM.BruhSound';

	foreach AllActors(class'TNMPawn', TNMP)
	{
		TNMP.bruhSound = Sound'TNM.BruhSound';
	}

	foreach AllActors(class'TNMWeapon', TNMW)
	{
		TNMW.bruhSound = Sound'TNM.BruhSound';
	}
}

exec function ResetATMs()
{	
	if (!bCheatsEnabled)
		return;
	
	if (ATMAccountManager != None)
	{
		ATMAccountManager.UserList[0].accountNumber="905279";
		ATMAccountManager.UserList[0].PIN="2049";
		ATMAccountManager.UserList[0].balance=500;
		ATMAccountManager.UserList[1].accountNumber="599428";
		ATMAccountManager.UserList[1].PIN="6647";
		ATMAccountManager.UserList[1].balance=260;
		ATMAccountManager.UserList[2].accountNumber="326877";
		ATMAccountManager.UserList[2].PIN="9006";
		ATMAccountManager.UserList[2].balance=140;
		ATMAccountManager.UserList[3].accountNumber="140990";
		ATMAccountManager.UserList[3].PIN="4043";
		ATMAccountManager.UserList[3].balance=75;
		ATMAccountManager.UserList[4].accountNumber="509861";
		ATMAccountManager.UserList[4].PIN="7400";
		ATMAccountManager.UserList[4].balance=410;
		ATMAccountManager.UserList[5].accountNumber="548836";
		ATMAccountManager.UserList[5].PIN="4356";
		ATMAccountManager.UserList[5].balance=280;
		ATMAccountManager.UserList[6].accountNumber="060102";
		ATMAccountManager.UserList[6].PIN="5543";
		ATMAccountManager.UserList[6].balance=100;
		ATMAccountManager.UserList[7].accountNumber="356627";
		ATMAccountManager.UserList[7].PIN="1234";
		ATMAccountManager.UserList[7].balance=235;
		ATMAccountManager.UserList[8].accountNumber="376936";
		ATMAccountManager.UserList[8].PIN="4355";
		ATMAccountManager.UserList[8].balance=220;
	}
}

// ----------------------------------------------------------------------
// CreateATMAccountManager()
//
// Sets up an ATM account manager.
// ----------------------------------------------------------------------
function CreateATMAccountManager()
{
	local DeusExLevelInfo dxInfo;
	local string localURL;

	foreach AllActors(class'DeusExLevelInfo', dxInfo)
		break;
	
	if (dxInfo != None)
		localURL = Caps(dxInfo.mapName);

	if (dxInfo != None && dxInfo.MissionNumber >= 20 && localURL != "TNMINTRO" && localURL != "TNMINTRO_2009" && (ATMAccountManager == None || ATMAccountManager.bDeleteMe))
	{
		ATMAccountManager = Spawn(class'TNMATMAccountManager', Self);
		if (ATMAccountManager != None)
		{
			if (localURL == "25_TNMTRAINING" || localURL == "25_TNMTRAINING_2009")
			{
				ATMAccountManager.UserList[0].accountNumber="012345";
				ATMAccountManager.UserList[0].PIN="6789";
				ATMAccountManager.UserList[0].balance=500;
			}
			else
			{
				ATMAccountManager.UserList[0].accountNumber="905279";
				ATMAccountManager.UserList[0].PIN="2049";
				ATMAccountManager.UserList[0].balance=500;
				ATMAccountManager.UserList[1].accountNumber="599428";
				ATMAccountManager.UserList[1].PIN="6647";
				ATMAccountManager.UserList[1].balance=260;
				ATMAccountManager.UserList[2].accountNumber="326877";
				ATMAccountManager.UserList[2].PIN="9006";
				ATMAccountManager.UserList[2].balance=140;
				ATMAccountManager.UserList[3].accountNumber="140990";
				ATMAccountManager.UserList[3].PIN="4043";
				ATMAccountManager.UserList[3].balance=75;
				ATMAccountManager.UserList[4].accountNumber="509861";
				ATMAccountManager.UserList[4].PIN="7400";
				ATMAccountManager.UserList[4].balance=410;
				ATMAccountManager.UserList[5].accountNumber="548836";
				ATMAccountManager.UserList[5].PIN="4356";
				ATMAccountManager.UserList[5].balance=280;
				ATMAccountManager.UserList[6].accountNumber="060102";
				ATMAccountManager.UserList[6].PIN="5543";
				ATMAccountManager.UserList[6].balance=100;
				ATMAccountManager.UserList[7].accountNumber="356627";
				ATMAccountManager.UserList[7].PIN="1234";
				ATMAccountManager.UserList[7].balance=235;
				ATMAccountManager.UserList[8].accountNumber="376936";
				ATMAccountManager.UserList[8].PIN="4355";
				ATMAccountManager.UserList[8].balance=220;
			}
		}
	}

	// If we already have an account manager in TNMIntro, then kill it
	if ((localURL == "TNMINTRO" || localURL == "TNMINTRO_2009") && ATMAccountManager != None)
	{
		ATMAccountManager.Destroy();
		ATMAccountManager = None;
	}
}

// ----------------------------------------------------------------------
// HealPlayer()
// ----------------------------------------------------------------------

function int HealPlayer(int baseHealPoints, optional Bool bUseMedicineSkill)
{
	local float mult;
	local int adjustedHealAmount, aha2, tempaha;
	local int origHealAmount;
	local float dividedHealAmount;
	local Trestkon DeadP;

	// Co-op Medkit Revival check: if using a Medkit near or looking at a dead teammate, revive them!
	if (bUseMedicineSkill && Level.NetMode != NM_Standalone)
	{
		foreach AllActors(class'Trestkon', DeadP)
		{
			if (DeadP != Self && DeadP.IsInState('Dying'))
			{
				if ((FrobTarget != None && (FrobTarget == DeadP.MoveTarget || YuukaReviveTotem(FrobTarget) != None)) ||
				    (DeadP.MoveTarget != None && VSize(DeadP.MoveTarget.Location - Location) <= 165.0) ||
				    (VSize(DeadP.Location - Location) <= 165.0))
				{
					CoopReviveTeammate(DeadP, Carcass(DeadP.MoveTarget));
					return 1;
				}
			}
		}
	}

	if (bUseMedicineSkill)
		adjustedHealAmount = CalculateSkillHealAmount(baseHealPoints);
	else
		adjustedHealAmount = baseHealPoints;

	origHealAmount = adjustedHealAmount;

	if (adjustedHealAmount > 0)
	{
		if (bUseMedicineSkill)
			PlaySound(sound'MedicalHiss', SLOT_None,,, 256);

		// Heal by 3 regions via multiplayer game
		if (False && (( Level.NetMode == NM_DedicatedServer ) || ( Level.NetMode == NM_ListenServer )))
		{
         // DEUS_EX AMSD If legs broken, heal them a little bit first
			if (HealthLegLeft == 0)
			{
				aha2 = adjustedHealAmount;
				if (aha2 >= 5)
				   aha2 = 5;
				tempaha = aha2;
				adjustedHealAmount = adjustedHealAmount - aha2;
				HealPart(HealthLegLeft, aha2);
				HealPart(HealthLegRight,tempaha);
				mpMsgServerFlags = mpMsgServerFlags & (~MPSERVERFLAG_LostLegs);
			}
			HealPart(HealthHead, adjustedHealAmount);

			if ( adjustedHealAmount > 0 )
			{
				aha2 = adjustedHealAmount;
				HealPart(HealthTorso, aha2);
				aha2 = adjustedHealAmount;
				HealPart(HealthArmRight,aha2);
				HealPart(HealthArmLeft, adjustedHealAmount);
			}
			if ( adjustedHealAmount > 0 )
			{
				aha2 = adjustedHealAmount;
				HealPart(HealthLegRight, aha2);
				HealPart(HealthLegLeft, adjustedHealAmount);
			}
		}
		else
		{
			// If legs broken, heal them a little bit first
			if (HealthLegLeft == 0 && HealthLegRight == 0)
				HealPart(HealthLegLeft, adjustedHealAmount);
			HealPart(HealthHead, adjustedHealAmount);
			HealPart(HealthTorso, adjustedHealAmount);
			HealPart(HealthLegRight, adjustedHealAmount);
			HealPart(HealthLegLeft, adjustedHealAmount);
			HealPart(HealthArmRight, adjustedHealAmount);
			HealPart(HealthArmLeft, adjustedHealAmount);
		}

		GenerateTotalHealth();

		adjustedHealAmount = origHealAmount - adjustedHealAmount;

		if (origHealAmount == baseHealPoints)
		{
			if (adjustedHealAmount == 1)
				ClientMessage(Sprintf(HealedPointLabel, adjustedHealAmount));
			else
				ClientMessage(Sprintf(HealedPointsLabel, adjustedHealAmount));
		}
		else
		{
			ClientMessage(Sprintf(HealedPointsLabel, adjustedHealAmount));
		}
	}

	return adjustedHealAmount;
}

simulated function int CalculateSkillHealAmount(int baseHealPoints)
{
	if (DeusExRootWindow(rootWindow) != None &&
	    PersonaScreenHealth(DeusExRootWindow(rootWindow).GetTopWindow()) != None)
	{
		bCoopInHealthScreenHeal = True;
	}
	return Super.CalculateSkillHealAmount(baseHealPoints);
}

simulated function bool PlayerIsClient()
{
	if (bCoopInHealthScreenHeal)
		return False;
	return Super.PlayerIsClient();
}

function PopHealth(float health0, float health1, float health2, float health3, float health4, float health5)
{
	bCoopInHealthScreenHeal = False;
	Super.PopHealth(health0, health1, health2, health3, health4, health5);
	GenerateTotalHealth();
}

// ----------------------------------------------------------------------
// MultiplayerTick()
// Not the greatest name, handles single player ticks as well.  Basically
// anything tick style stuff that should be propagated to the server gets
// propagated as this one function call.
// ----------------------------------------------------------------------
function MultiplayerTick(float DeltaTime)
{
	local int burnTime;
	
	Super.MultiplayerTick(DeltaTime);

	// Vanilla checks for Vanilla's flamethrower, TNM checks for player variable
	// This should be shorter than Vanilla as Vanilla's copy of this code is still ran.
	if (bOnFire)
	{
		if ( Level.NetMode != NM_Standalone )
			// burnTime = Class'WeaponTNMFlamethrower'.Default.mpBurnTime;
			burnTime = defaultBurnTimeMP;
		else
			// burnTime = Class'WeaponTNMFlamethrower'.Default.BurnTime;
			burnTime = defaultBurnTime;
		burnTimer += deltaTime;
		if (burnTimer >= burnTime)
			ExtinguishFire();
	}
}

function AddDamageDisplay(name damageType, vector hitOffset)
{
	if (DeusExRootWindow(rootWindow) != None && DeusExRootWindow(rootWindow).hud != None)
		Super.AddDamageDisplay(damageType, hitOffset);
}

function SetDamagePercent(float percent)
{
	if (DeusExRootWindow(rootWindow) != None && DeusExRootWindow(rootWindow).hud != None)
		Super.SetDamagePercent(percent);
}

function ClearAugmentationDisplay()
{
	if (DeusExRootWindow(rootWindow) != None && DeusExRootWindow(rootWindow).hud != None)
		Super.ClearAugmentationDisplay();
}

function AddAugmentationDisplay(Augmentation aug)
{
	if (DeusExRootWindow(rootWindow) != None && DeusExRootWindow(rootWindow).hud != None)
		Super.AddAugmentationDisplay(aug);
}

function SetInHandPending(Inventory newInHandPending)
{
	local DeusExRootWindow root;

	if ( newInHandPending == None )
		ClientInHandPending = None;

	inHandPending = newInHandPending;

	root = DeusExRootWindow(rootWindow);
	if (root != None && root.hud != None)
		root.hud.belt.UpdateInHand();
}

//Play a sound client side (so only client will hear it
simulated function ClientPlaySound(sound ASound, optional bool bInterrupt, optional bool bVolumeControl )
{
	local actor SoundPlayer;

	LastPlaySound = Level.TimeSeconds;	// so voice messages won't overlap
	if ( ViewTarget != None )
		SoundPlayer = ViewTarget;
	else
		SoundPlayer = self;

	SoundPlayer.PlaySound(ASound, SLOT_None, 16.0, bInterrupt);
	SoundPlayer.PlaySound(ASound, SLOT_Interface, 16.0, bInterrupt);
	SoundPlayer.PlaySound(ASound, SLOT_Misc, 16.0, bInterrupt);
	// How about don't interrupt the infolink?
	// SoundPlayer.PlaySound(ASound, SLOT_Talk, 16.0, bInterrupt);
}

function PutCarriedDecorationInHand()
{
	if (CarriedDecoration != None && bool(CarriedDecoration.GetPropertyText("bActivateEventOnPickup")))
		CarriedDecoration.Frob(Self, inHand);
	
	// Required otherwise carts (and office chairs) become unpushable when picked up immediately after being pushed.
	if (CarriedDecoration != None)
		CarriedDecoration.SetPropertyText("bJustPushed", "False");

	if (CarriedDecoration != None && CarriedDecoration.IsA('DeusExCarcass'))
	{
		CarriedDecoration.SetCollision(False, False, False);
		CarriedDecoration.bCollideWorld = False;
		CarriedDecoration.SetCollisionSize(18.0, CarriedDecoration.CollisionHeight);
	}
		
	Super.PutCarriedDecorationInHand();

	if (CarriedDecoration != None && CarriedDecoration.IsA('DeusExCarcass'))
	{
		CarriedDecoration.Style = STY_Normal;
	}
}

function string GetLevelName()
{
	local DeusExLevelInfo info;
	local string temp;
	
	info = GetLevelInfo();
	
	if (info != None)
	{
		if (info.MissionLocation != "")
		{
			temp = info.MissionLocation;
			if (info.MapName != "")
				temp = temp @ "("$info.MapName$")";
		}
		else if (info.MapName != "")
		{
			temp = info.MissionLocation;
		}
		else 
			return "";
			
		return temp;
	}
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
	local string temp, temp2, locString;

	if (bPlatformer && damagetype == 'suicided')
	{
		damagetype = 'exploded';
		Health = -1000;
	}
	
	Super.Died(Killer, damageType, HitLocation);
	
	if (damageType == 'Eraser')
		DeusExRootWindow(rootWindow).InvokeMenuScreen(Class'EraserWindow', false);
		
	if (bIRCDeathInfo && irc_link != None)
	{
		if (Killer != None && ScriptedPawn(Killer) != None)
		{
			// NPC dead but still acknowledged here?
			if (ScriptedPawn(Killer).bDeleteMe)
			{
				temp = ScriptedPawn(Killer).Default.FamiliarName;
				temp = temp $ "!";
			}
			else
			{
				temp = ScriptedPawn(Killer).FamiliarName;
				if (Killer.Weapon != None && Killer.Weapon.ItemName != "")
				{
					if (Killer.Weapon.ItemName == class'DeusExWeapon'.Default.ItemName)
					{
						temp2 = GetVanillaWeaponName(Killer.Weapon);
						temp = temp @ "using" @ temp2;
					}
					else
						temp = temp @ "using" @ Killer.Weapon.ItemName;
				}
				temp = temp $ "!";
				// If we still have no item name, append the class name for easier debugging
				if (Killer.Weapon != None && Killer.Weapon.ItemName == class'DeusExWeapon'.default.ItemName && temp2 == Killer.Weapon.ItemName)
					temp = temp @ "("$Killer.Weapon.Class$")";
			}
		}
		else if (Killer != None && Killer == Self && bEntityDeath)
			temp = "The Entity.";
		else if (Killer != None && Killer == Self)
			temp = "the Puppeteer.";
		else
			temp = "'"$damageType$"'"@"damage!";
		if (HitLocation.z > Location.Z + (CollisionHeight * 0.7))
			temp = temp @ "(Headshot!)";
			
		// Spoiler GameSpy levels.			
		if (InStr(Caps(temp), Caps("GameSpy")) != -1 || InStr(Caps(temp), Caps("Alien")) != -1)
			temp = Chr(Rand(62)+65)$Chr(Rand(62)+65)$Chr(Rand(62)+65)$Chr(Rand(62)+65)$Chr(Rand(62)+65)$"[MESSAGE INTERCEPTED]"$Chr(Rand(62)+65)$Chr(Rand(62)+65)$Chr(Rand(62)+65)$Chr(Rand(62)+65)$Chr(Rand(62)+65);
		
		if (bIRCLocationInfo)
			locString = "["$Hex(Location.X)$"-"$Hex(Location.Y)$"-"$Hex(Location.Z)$"]";
			
		if (bStunned)
			irc_link.SendChannelAction(irc_link.DefaultChannel,"was knocked out by"@temp@locString);
		else if (damageType == 'DaiKatana')
			irc_link.SendChannelAction(irc_link.DefaultChannel,"was made John Romero's bitch!");
		else if (damageType == 'Eraser')
			irc_link.SendChannelAction(irc_link.DefaultChannel,"had their account scrambled!");
		else
			irc_link.SendChannelAction(irc_link.DefaultChannel,"died to"@temp@locString);
	}
	
	// Normally handled by RenderOverlays, which doesn't happen when dying
	ChangeCloak(False);
}

// Adds an item name for vanilla weapons without one.
function string GetVanillaWeaponName(Weapon inWeapon)
{
	local string str;
	
	switch(inWeapon.Class.Name)
	{
		case 'WeaponCatScratch':
			str = strClaw;
			break;
		case 'WeaponDogBite':
		case 'WeaponKarkianBite':
		case 'WeaponRatBite':
			str = strBite;
			break;
		case 'WeaponGraySpit':
			str = strGraySpit;
			break;
		case 'WeaponGraySwipe':
			str = strSwipe;
			break;
		case 'WeaponGreaselSpit':
			str = strGreaselSpit;
			break;
		case 'WeaponKarkianBump':
			str = strKarkian;
			break;
		case 'WeaponMJ12Commando':
			str = strCommandoGun;
			break;
		case 'WeaponMJ12Rocket':
			str = strCommandoRocket;
			break;
		case 'WeaponRobotMachinegun':
			str = strRobotGun;
			break;
		case 'WeaponRobotRocket':
			str = strRobotRocket;
			break;
		case 'WeaponSpiderBot':
		case 'WeaponSpiderBot2':
			str = strSpiderbot;
			break;
		Default:
			str = inWeapon.ItemName;
			break;
	}
	return str;
}

function SetupBook(TNMInformationDevices spawnedBook, string book)
{
	switch(Book)
	{
		case "Arcadia 01": 
			spawnedBook.textTag[0] = 'Arcadia01';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_Arcadia");
			break;
		case "Arcadia 02": 
			spawnedBook.textTag[0] = 'Arcadia02';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_Arcadia");
			break;
		case "Arcadia 03": 
			spawnedBook.textTag[0] = 'Arcadia03';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_Arcadia");
			break;
		case "DXO": 
			spawnedBook.textTag[0] = 'DXO';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_DXO");
			break;
		case "Invest 01": 
			spawnedBook.textTag[0] = 'Invest01';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_INVEST");
			break;
		case "Invest 02": 
			spawnedBook.textTag[0] = 'Invest02';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_INVEST");
			break;
		case "Invest 03": 
			spawnedBook.textTag[0] = 'Invest03';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_INVEST");
			break;
		case "Invest 04": 
			spawnedBook.textTag[0] = 'Invest04';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_INVEST");
			break;
		case "Parallel 01": 
			spawnedBook.textTag[0] = 'Parallel01';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_Parallel");
			break;
		case "Parallel 02": 
			spawnedBook.textTag[0] = 'Parallel02';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_Parallel");
			break;
		case "Parallel 03": 
			spawnedBook.textTag[0] = 'Parallel03';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_Parallel");
			break;
		case "Parallel 04": 
			spawnedBook.textTag[0] = 'Parallel04';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_Parallel");
			break;
		case "Parallel 05": 
			spawnedBook.textTag[0] = 'Parallel05';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_Parallel");
			break;
		case "PC Gamer 01": 
			spawnedBook.textTag[0] = 'PCGamer01_PAGE01';
			spawnedBook.textTag[1] = 'PCGamer01_PAGE02';
			spawnedBook.numberofpages = 2;
			spawnedBook.SetPropertyText("SkinColor", "SC_PCGamer");
			break;
		case "PC Gamer 02": 
			spawnedBook.textTag[0] = 'PCGamer02_PAGE01';
			spawnedBook.textTag[1] = 'PCGamer02_PAGE02';
			spawnedBook.numberofpages = 2;
			spawnedBook.SetPropertyText("SkinColor", "SC_PCGamer");
			break;
		case "PC Gamer 03": 
			spawnedBook.textTag[0] = 'PCGamer03';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_PCGamer");
			break;
		case "PC Gamer 04": 
			spawnedBook.textTag[0] = 'PCGamer04_PAGE01';
			spawnedBook.textTag[1] = 'PCGamer04_PAGE02';
			spawnedBook.numberofpages = 2;
			spawnedBook.SetPropertyText("SkinColor", "SC_PCGamer");
			break;
		case "PC Gamer 05": 
			spawnedBook.textTag[0] = 'PCGamer05_PAGE01';
			spawnedBook.textTag[1] = 'PCGamer05_PAGE02';
			spawnedBook.textTag[2] = 'PCGamer05_PAGE03';
			spawnedBook.textTag[3] = 'PCGamer05_PAGE04';
			spawnedBook.textTag[4] = 'PCGamer05_PAGE05';
			spawnedBook.textTag[5] = 'PCGamer05_PAGE06';
			spawnedBook.textTag[6] = 'PCGamer05_PAGE07';
			spawnedBook.numberofpages = 7;
			spawnedBook.SetPropertyText("SkinColor", "SC_PCGamer");
			break;
		case "Technology 01": 
			spawnedBook.textTag[0] = 'Technology01';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_TechToday");
			break;
		case "Technology 02": 
			spawnedBook.textTag[0] = 'Technology02';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_TechToday");
			break;
		case "Technology 03": 
			spawnedBook.textTag[0] = 'Technology03';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_TechToday");
			break;
		case "Technology 04": 
			spawnedBook.textTag[0] = 'Technology04';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_TechToday");
			break;
		case "Technology 05": 
			spawnedBook.textTag[0] = 'Technology05';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_TechToday");
			break;
		case "Technology 06": 
			spawnedBook.textTag[0] = 'Technology06';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_TechToday");
			break;
		case "Technology 07": 
			spawnedBook.textTag[0] = 'Technology07';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_TechToday");
			break;
		case "Technology 08": 
			spawnedBook.textTag[0] = 'Technology08_PAGE01';
			spawnedBook.textTag[1] = 'Technology08_PAGE02';
			spawnedBook.numberofpages = 2;
			spawnedBook.SetPropertyText("SkinColor", "SC_TechToday");
			spawnedBook.bAddToVault = True;
			spawnedBook.NoteTag = 'Technology08_NOTE';
			break;
		case "Technology 09": 
			spawnedBook.textTag[0] = 'Technology09';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_TechToday");
			break;
		case "The Pulse 01": 
			spawnedBook.textTag[0] = 'ThePulse01';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_ThePulse");
			break;
		case "The Pulse 02": 
			spawnedBook.textTag[0] = 'ThePulse02';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_ThePulse");
			break;
		case "The Pulse 03": 
			spawnedBook.textTag[0] = 'ThePulse03_PAGE01';
			spawnedBook.textTag[1] = 'ThePulse03_PAGE02';
			spawnedBook.numberofpages = 2;
			spawnedBook.SetPropertyText("SkinColor", "SC_ThePulse");
			break;
		case "The Pulse 04": 
			spawnedBook.textTag[0] = 'ThePulse04';
			spawnedBook.numberofpages = 1;
			spawnedBook.SetPropertyText("SkinColor", "SC_ThePulse");
			break;
		case "Rebel Cell 01": 
			spawnedBook.textTag[0] = 'BookRebelCell01_PAGE01';
			spawnedBook.textTag[1] = 'BookRebelCell01_PAGE02';
			spawnedBook.textTag[2] = 'BookRebelCell01_PAGE03';
			spawnedBook.numberofpages = 3;
			break;
		case "Rebel Cell 02": 
			spawnedBook.textTag[0] = 'BookRebelCell02_PAGE01';
			spawnedBook.textTag[1] = 'BookRebelCell02_PAGE02';
			spawnedBook.textTag[2] = 'BookRebelCell02_PAGE03';
			spawnedBook.numberofpages = 3;
			break;
		case "Rebel Cell 03": 
			spawnedBook.textTag[0] = 'BookRebelCell03_PAGE01';
			spawnedBook.textTag[1] = 'BookRebelCell03_PAGE02';
			spawnedBook.textTag[2] = 'BookRebelCell03_PAGE03';
			spawnedBook.numberofpages = 3;
			break;
		case "Rebel Cell 04": 
			spawnedBook.textTag[0] = 'BookRebelCell04_PAGE01';
			spawnedBook.textTag[1] = 'BookRebelCell04_PAGE02';
			spawnedBook.textTag[2] = 'BookRebelCell04_PAGE03';
			spawnedBook.numberofpages = 3;
			break;
		case "Rebel Cell 05": 
			spawnedBook.textTag[0] = 'BookRebelCell05_PAGE01';
			spawnedBook.textTag[1] = 'BookRebelCell05_PAGE02';
			spawnedBook.textTag[2] = 'BookRebelCell05_PAGE03';
			spawnedBook.numberofpages = 3;
			break;
		case "Rebel Cell 06": 
			spawnedBook.textTag[0] = 'BookRebelCell06_PAGE01';
			spawnedBook.textTag[1] = 'BookRebelCell06_PAGE02';
			spawnedBook.textTag[2] = 'BookRebelCell06_PAGE03';
			spawnedBook.numberofpages = 3;
			break;
		case "Twist 01": 
			spawnedBook.textTag[0] = 'BookTwist01_PAGE01';
			spawnedBook.textTag[1] = 'BookTwist01_PAGE02';
			spawnedBook.textTag[2] = 'BookTwist01_PAGE03';
			spawnedBook.textTag[3] = 'BookTwist01_PAGE04';
			spawnedBook.textTag[4] = 'BookTwist01_PAGE05';
			spawnedBook.numberofpages = 5;
			break;
		case "Twist 02": 
			spawnedBook.textTag[0] = 'BookTwist02_PAGE01';
			spawnedBook.textTag[1] = 'BookTwist02_PAGE02';
			spawnedBook.textTag[2] = 'BookTwist02_PAGE03';
			spawnedBook.textTag[3] = 'BookTwist02_PAGE04';
			spawnedBook.textTag[4] = 'BookTwist02_PAGE05';
			spawnedBook.textTag[5] = 'BookTwist02_PAGE06';
			spawnedBook.textTag[6] = 'BookTwist02_PAGE07';
			spawnedBook.numberofpages = 7;
			break;
		case "Twist 03": 
			spawnedBook.textTag[0] = 'BookTwist03_PAGE01';
			spawnedBook.textTag[1] = 'BookTwist03_PAGE02';
			spawnedBook.textTag[2] = 'BookTwist03_PAGE03';
			spawnedBook.textTag[3] = 'BookTwist03_PAGE04';
			spawnedBook.textTag[4] = 'BookTwist03_PAGE05';
			spawnedBook.textTag[5] = 'BookTwist03_PAGE06';
			spawnedBook.textTag[6] = 'BookTwist03_PAGE07';
			spawnedBook.textTag[7] = 'BookTwist03_PAGE08';
			spawnedBook.textTag[8] = 'BookTwist03_PAGE09';
			spawnedBook.textTag[9] = 'BookTwist03_PAGE10';
			spawnedBook.numberofpages = 10;
			break;
		case "Twist 04": 
			spawnedBook.textTag[0] = 'BookTwist04_PAGE01';
			spawnedBook.textTag[1] = 'BookTwist04_PAGE02';
			spawnedBook.textTag[2] = 'BookTwist04_PAGE03';
			spawnedBook.textTag[3] = 'BookTwist04_PAGE04';
			spawnedBook.textTag[4] = 'BookTwist04_PAGE05';
			spawnedBook.textTag[5] = 'BookTwist04_PAGE06';
			spawnedBook.textTag[6] = 'BookTwist04_PAGE07';
			spawnedBook.textTag[7] = 'BookTwist04_PAGE08';
			spawnedBook.textTag[8] = 'BookTwist04_PAGE09';
			spawnedBook.numberofpages = 9;
			break;
		case "Twist 05": 
			spawnedBook.textTag[0] = 'BookTwist05_PAGE01';
			spawnedBook.textTag[1] = 'BookTwist05_PAGE02';
			spawnedBook.textTag[2] = 'BookTwist05_PAGE03';
			spawnedBook.textTag[3] = 'BookTwist05_PAGE04';
			spawnedBook.textTag[4] = 'BookTwist05_PAGE05';
			spawnedBook.textTag[5] = 'BookTwist05_PAGE06';
			spawnedBook.textTag[6] = 'BookTwist05_PAGE07';
			spawnedBook.textTag[7] = 'BookTwist05_PAGE08';
			spawnedBook.textTag[8] = 'BookTwist05_PAGE09';
			spawnedBook.numberofpages = 9;
			break;
		case "Twist 06": 
			spawnedBook.textTag[0] = 'BookTwist06_PAGE01';
			spawnedBook.textTag[1] = 'BookTwist06_PAGE02';
			spawnedBook.textTag[2] = 'BookTwist06_PAGE03';
			spawnedBook.textTag[3] = 'BookTwist06_PAGE04';
			spawnedBook.textTag[4] = 'BookTwist06_PAGE05';
			spawnedBook.textTag[5] = 'BookTwist06_PAGE06';
			spawnedBook.textTag[6] = 'BookTwist06_PAGE07';
			spawnedBook.textTag[7] = 'BookTwist06_PAGE08';
			spawnedBook.textTag[8] = 'BookTwist06_PAGE09';
			spawnedBook.numberofpages = 9;
			break;
		case "Twist 07": 
			spawnedBook.textTag[0] = 'BookTwist07_PAGE01';
			spawnedBook.textTag[1] = 'BookTwist07_PAGE02';
			spawnedBook.textTag[2] = 'BookTwist07_PAGE03';
			spawnedBook.textTag[3] = 'BookTwist07_PAGE04';
			spawnedBook.textTag[4] = 'BookTwist07_PAGE05';
			spawnedBook.textTag[5] = 'BookTwist07_PAGE06';
			spawnedBook.textTag[6] = 'BookTwist07_PAGE07';
			spawnedBook.textTag[7] = 'BookTwist07_PAGE08';
			spawnedBook.numberofpages = 8;
			break;
		case "Twist 08": 
			spawnedBook.textTag[0] = 'BookTwist08_PAGE01';
			spawnedBook.textTag[1] = 'BookTwist08_PAGE02';
			spawnedBook.textTag[2] = 'BookTwist08_PAGE03';
			spawnedBook.textTag[3] = 'BookTwist08_PAGE04';
			spawnedBook.textTag[4] = 'BookTwist08_PAGE05';
			spawnedBook.textTag[5] = 'BookTwist08_PAGE06';
			spawnedBook.textTag[6] = 'BookTwist08_PAGE07';
			spawnedBook.textTag[7] = 'BookTwist08_PAGE08';
			spawnedBook.numberofpages = 8;
			break;
		case "Twist 09": 
			spawnedBook.textTag[0] = 'BookTwist09_PAGE01';
			spawnedBook.textTag[1] = 'BookTwist09_PAGE02';
			spawnedBook.textTag[2] = 'BookTwist09_PAGE03';
			spawnedBook.textTag[3] = 'BookTwist09_PAGE04';
			spawnedBook.textTag[4] = 'BookTwist09_PAGE05';
			spawnedBook.textTag[5] = 'BookTwist09_PAGE06';
			spawnedBook.textTag[6] = 'BookTwist09_PAGE07';
			spawnedBook.textTag[7] = 'BookTwist09_PAGE08';
			spawnedBook.textTag[8] = 'BookTwist09_PAGE09';
			spawnedBook.numberofpages = 9;
			break;
		case "Twist 10": 
			spawnedBook.textTag[0] = 'BookTwist10_PAGE01';
			spawnedBook.textTag[1] = 'BookTwist10_PAGE02';
			spawnedBook.textTag[2] = 'BookTwist10_PAGE03';
			spawnedBook.textTag[3] = 'BookTwist10_PAGE04';
			spawnedBook.textTag[4] = 'BookTwist10_PAGE05';
			spawnedBook.textTag[5] = 'BookTwist10_PAGE06';
			spawnedBook.textTag[6] = 'BookTwist10_PAGE07';
			spawnedBook.textTag[7] = 'BookTwist10_PAGE08';
			spawnedBook.textTag[8] = 'BookTwist10_PAGE09';
			spawnedBook.textTag[9] = 'BookTwist10_PAGE10';
			spawnedBook.numberofpages = 10;
			break;
		case "Twist 11": 
			spawnedBook.textTag[0] = 'BookTwist11_PAGE01';
			spawnedBook.textTag[1] = 'BookTwist11_PAGE02';
			spawnedBook.textTag[2] = 'BookTwist11_PAGE03';
			spawnedBook.textTag[3] = 'BookTwist11_PAGE04';
			spawnedBook.textTag[4] = 'BookTwist11_PAGE05';
			spawnedBook.textTag[5] = 'BookTwist11_PAGE06';
			spawnedBook.textTag[6] = 'BookTwist11_PAGE07';
			spawnedBook.textTag[7] = 'BookTwist11_PAGE08';
			spawnedBook.textTag[8] = 'BookTwist11_PAGE09';
			spawnedBook.textTag[9] = 'BookTwist11_PAGE10';
			spawnedBook.textTag[10] = 'BookTwist11_PAGE11';
			spawnedBook.numberofpages = 11;
			break;
		case "Twist 12": 
			spawnedBook.textTag[0] = 'BookTwist12_PAGE01';
			spawnedBook.textTag[1] = 'BookTwist12_PAGE02';
			spawnedBook.textTag[2] = 'BookTwist12_PAGE03';
			spawnedBook.textTag[3] = 'BookTwist12_PAGE04';
			spawnedBook.textTag[4] = 'BookTwist12_PAGE05';
			spawnedBook.textTag[5] = 'BookTwist12_PAGE06';
			spawnedBook.textTag[6] = 'BookTwist12_PAGE07';
			spawnedBook.textTag[7] = 'BookTwist12_PAGE08';
			spawnedBook.textTag[8] = 'BookTwist12_PAGE09';
			spawnedBook.numberofpages = 9;
			break;
		case "Twist 13": 
			spawnedBook.textTag[0] = 'BookTwist13_PAGE01';
			spawnedBook.textTag[1] = 'BookTwist13_PAGE02';
			spawnedBook.textTag[2] = 'BookTwist13_PAGE03';
			spawnedBook.textTag[3] = 'BookTwist13_PAGE04';
			spawnedBook.textTag[4] = 'BookTwist13_PAGE05';
			spawnedBook.textTag[5] = 'BookTwist13_PAGE06';
			spawnedBook.textTag[6] = 'BookTwist13_PAGE07';
			spawnedBook.textTag[7] = 'BookTwist13_PAGE08';
			spawnedBook.textTag[8] = 'BookTwist13_PAGE09';
			spawnedBook.numberofpages = 9;
			break;
		case "UA 01": 
			spawnedBook.textTag[0] = 'BookUA01_PAGE01';
			spawnedBook.textTag[1] = 'BookUA01_PAGE02';
			spawnedBook.numberofpages = 2;
			break;
		case "UA 02": 
			spawnedBook.textTag[0] = 'BookUA02_PAGE01';
			spawnedBook.textTag[1] = 'BookUA02_PAGE02';
			spawnedBook.numberofpages = 2;
			break;
		case "UA 03": 
			spawnedBook.textTag[0] = 'BookUA03_PAGE01';
			spawnedBook.textTag[1] = 'BookUA03_PAGE02';
			spawnedBook.textTag[2] = 'BookUA03_PAGE03';
			spawnedBook.textTag[3] = 'BookUA03_PAGE04';
			spawnedBook.textTag[4] = 'BookUA03_PAGE05';
			spawnedBook.textTag[5] = 'BookUA03_PAGE06';
			spawnedBook.numberofpages = 6;
			break;
		case "UA 04": 
			spawnedBook.textTag[0] = 'BookUA04_PAGE01';
			spawnedBook.textTag[1] = 'BookUA04_PAGE02';
			spawnedBook.textTag[2] = 'BookUA04_PAGE03';
			spawnedBook.textTag[3] = 'BookUA04_PAGE04';
			spawnedBook.textTag[4] = 'BookUA04_PAGE05';
			spawnedBook.textTag[5] = 'BookUA04_PAGE06';
			spawnedBook.textTag[6] = 'BookUA04_PAGE07';
			spawnedBook.numberofpages = 7;
			break;
		case "UA 05": 
			spawnedBook.textTag[0] = 'BookUA05_PAGE01';
			spawnedBook.textTag[1] = 'BookUA05_PAGE02';
			spawnedBook.textTag[2] = 'BookUA05_PAGE03';
			spawnedBook.textTag[3] = 'BookUA05_PAGE04';
			spawnedBook.textTag[4] = 'BookUA05_PAGE05';
			spawnedBook.textTag[5] = 'BookUA05_PAGE06';
			spawnedBook.textTag[6] = 'BookUA05_PAGE07';
			spawnedBook.numberofpages = 7;
			break;
		case "UA 06": 
			spawnedBook.textTag[0] = 'BookUA06_PAGE01';
			spawnedBook.textTag[1] = 'BookUA06_PAGE02';
			spawnedBook.textTag[2] = 'BookUA06_PAGE03';
			spawnedBook.textTag[3] = 'BookUA06_PAGE04';
			spawnedBook.textTag[4] = 'BookUA06_PAGE05';
			spawnedBook.textTag[5] = 'BookUA06_PAGE06';
			spawnedBook.numberofpages = 6;
			break;
		case "UA 07": 
			spawnedBook.textTag[0] = 'BookUA07_PAGE01';
			spawnedBook.textTag[1] = 'BookUA07_PAGE02';
			spawnedBook.textTag[2] = 'BookUA07_PAGE03';
			spawnedBook.textTag[3] = 'BookUA07_PAGE04';
			spawnedBook.textTag[4] = 'BookUA07_PAGE05';
			spawnedBook.textTag[5] = 'BookUA07_PAGE06';
			spawnedBook.textTag[6] = 'BookUA07_PAGE07';
			spawnedBook.textTag[7] = 'BookUA07_PAGE08';
			spawnedBook.textTag[8] = 'BookUA07_PAGE09';
			spawnedBook.textTag[9] = 'BookUA07_PAGE10';
			spawnedBook.numberofpages = 10;
			break;
	}
}

// ----------------------------------------------------------------------
// SetAchievement()
//
// Sets the specified achievement.
// ----------------------------------------------------------------------
/*final*/ simulated function SetAchievement(string API_Name, optional bool bSetForNewGamePlus)
{
	// local GamePlatform Platform;
	local bool bIncorrectMode;
	local DeusExLevelInfo info;
	local string APINameShort, selStr;
	local bool bHas, bFound;
	local int i, j;
	local DeusExBaseWindow topWin;

	if (Level.NetMode == NM_Client && API_Name == "achVending" && DeusExRootWindow(rootWindow) != None)
	{
		topWin = DeusExRootWindow(rootWindow).GetTopWindow();
		if (topWin != None)
		{
			selStr = topWin.GetPropertyText("CurrentSelection");
			if (selStr != "")
				ServerSyncBoolFlag(SafeStringToName("CoopVendBuy_" $ selStr), True);
		}
		return;
	}

	if (Level.NetMode != NM_Standalone)
		return;
	/*
	if (bCustomDifficulty)
	{
		if (!(CDPlayerDamageTaken >= 1 && CDAIDamageTaken <= 1.25 && CDPlayerAccuracy >= -0.1 && CDAIBaseAccuracy <= 0.1 &&
		CDCameraTriggerDelay <= 1.25 && CDCameraMemoryTime >= 1 && CDEnergyDrainRate >= 1 && CDHealingRate <= 1 && CDTurretDamage >= 1 &&
		CDTurretRange >= 1 && CDTurretRotateRate >= 1 && CDTurretFireRate >= 1 && CDAIMinHealth <= 1 && CDAIHearingThreshold <= 1 &&
		CDAIVisibilityThreshold <= 1 && CDAISeekLevel  >= 3 && CDEnergyMax <= 100 && CDEnergyRechargePoint == 0))
		{
			if (API_Name != "ACH_CD_CustomDifficulty")	// Allow this no matter how easy or hard.
				return;
		}
	}*/

	//Get the level info so we can determine if we are on any special maps.
	info = GetLevelInfo();

	if (ACHIEVEMENTS_ENABLED)
	{/*
		Platform = Class'GamePlatform'.static.Instance();

		//Only bother doing this if we can actually set achievements.
		if (Platform != None && Platform.Ready() && Platform.SupportsAchievements())
		{
			if (Left(info.MapName,2) == "97" && Left(API_Name,13) != "ACH_Survival_") // Only allow survival specific achievements if on survival
				bIncorrectMode = True;
			else if (Left(info.MapName,2) != "97" && Left(API_Name,13) == "ACH_Survival_") // Disallow survival specific achievements if not on survival
				bIncorrectMode = True;

			if (API_Name == "ACH_Misc_CloneWars")	// This is allowed in either
				bIncorrectMode = False;

			// Achievements for beating the challenges, only available in the challenge.
			if (RevChallengeSystem != None && RevChallengeSystem.CurrentChallenge >= 0)
				bIncorrectMode = (Left(API_Name,14) != "ACH_Challenge_");*/
			/*
			if(Left(API_Name,10) == "ACH_Cheat_")	// Cheat achievements can always be awarded
				Platform.AchievementUnlock( API_Name );
			else*/ if (/*!flagBase.GetBool('PlayerHasCheated') && */!flagBase.GetBool('AchievementsDisabled') && !bIncorrectMode) //Check for cheating, otherwise disabled achievements or incorrect mode.
			{/*
				if(Left(API_Name,8) == "ACH_NGP_" || bSetForNewGamePlus) // Allow NGP achievements.
					Platform.AchievementUnlock( API_Name );
				else if(!flagBase.GetBool('AchievementsDisabledNGP'))
					Platform.AchievementUnlock( API_Name );*/
				bHas = bool(ConsoleCommand("Get Trestkon"@API_Name));
					
				ConsoleCommand("Set Trestkon"@API_Name@"True");
				SaveConfig();
				
				if (!bHas && bAchievementNotifications)
				{
					j++;
					for (i=0; i<ArrayCount(class'TNMAchievementManager'.default.varAchievementsCAT1) ; i++)
					{
						// log(i);
						if (class'TNMAchievementManager'.default.varAchievementsCAT1[i] ~= API_Name)
						{
							bFound=True;
							break;
						}
					}
					if (!bFound)
					{
						j++;
						for (i=0; i<ArrayCount(class'TNMAchievementManager'.default.varAchievementsCAT2) ; i++)
						{
							if (class'TNMAchievementManager'.default.varAchievementsCAT2[i] ~= API_Name)
							{
								bFound=True;
								break;
							}
						}
					}
					if (!bFound)
					{
						j++;
						for (i=0; i<ArrayCount(class'TNMAchievementManager'.default.varAchievementsCAT3) ; i++)
						{
							if (class'TNMAchievementManager'.default.varAchievementsCAT3[i] ~= API_Name)
							{
								bFound=True;
								break;
							}
						}
					}
					if (!bFound)
					{
						j++;
						for (i=0; i<ArrayCount(class'TNMAchievementManager'.default.varAchievementsCAT4) ; i++)
						{
							if (class'TNMAchievementManager'.default.varAchievementsCAT4[i] ~= API_Name)
							{
								bFound=True;
								break;
							}
						}
					}
					if (!bFound)
					{
						j++;
						for (i=0; i<ArrayCount(class'TNMAchievementManager'.default.varAchievementsCAT5) ; i++)
						{
							if (class'TNMAchievementManager'.default.varAchievementsCAT5[i] ~= API_Name)
							{
								bFound=True;
								break;
							}
						}
					}
					if (!bFound)
					{
						j++;
						for (i=0; i<ArrayCount(class'TNMAchievementManager'.default.varAchievementsCAT6) ; i++)
						{
							if (class'TNMAchievementManager'.default.varAchievementsCAT6[i] ~= API_Name)
							{
								bFound=True;
								break;
							}
						}
					}
					if (!bFound)
					{
						j++;
						for (i=0; i<ArrayCount(class'TNMAchievementManager'.default.varAchievementsCAT7) ; i++)
						{
							if (class'TNMAchievementManager'.default.varAchievementsCAT7[i] ~= API_Name)
							{
								bFound=True;
								break;
							}
						}
					}
					if (!bFound)
					{
						j++;
						for (i=0; i<ArrayCount(class'TNMAchievementManager'.default.varAchievementsCAT8) ; i++)
						{
							if (class'TNMAchievementManager'.default.varAchievementsCAT8[i] ~= API_Name)
							{
								bFound=True;
								break;
							}
						}
					}
					if (!bFound)
					{
						j++;
						for (i=0; i<ArrayCount(class'TNMAchievementManager'.default.varAchievementsCAT9) ; i++)
						{
							if (class'TNMAchievementManager'.default.varAchievementsCAT9[i] ~= API_Name)
							{
								bFound=True;
								break;
							}
						}
					}
					if (bFound)
					{
						switch(j)
						{
							case 1:
								ClientMessage(strAchievement@class'TNMAchievementManager'.default.strAchievementsTitlesCAT1[i]);
								if (bIRCImportantKillInfo && irc_link != None)
									irc_link.SendChannelAction(irc_link.DefaultChannel,"achieved"@class'TNMAchievementManager'.default.strAchievementsTitlesCAT1[i]);
								break;
							case 2:
								ClientMessage(strAchievement@class'TNMAchievementManager'.default.strAchievementsTitlesCAT2[i]);
								if (bIRCImportantKillInfo && irc_link != None)
									irc_link.SendChannelAction(irc_link.DefaultChannel,"achieved"@class'TNMAchievementManager'.default.strAchievementsTitlesCAT2[i]);
								break;
							case 3:
								ClientMessage(strAchievement@class'TNMAchievementManager'.default.strAchievementsTitlesCAT3[i]);
								if (bIRCImportantKillInfo && irc_link != None)
									irc_link.SendChannelAction(irc_link.DefaultChannel,"achieved"@class'TNMAchievementManager'.default.strAchievementsTitlesCAT3[i]);
								break;
							case 4:
								ClientMessage(strAchievement@class'TNMAchievementManager'.default.strAchievementsTitlesCAT4[i]);
								if (bIRCImportantKillInfo && irc_link != None)
									irc_link.SendChannelAction(irc_link.DefaultChannel,"achieved"@class'TNMAchievementManager'.default.strAchievementsTitlesCAT4[i]);
								break;
							case 5:
								ClientMessage(strAchievement@class'TNMAchievementManager'.default.strAchievementsTitlesCAT5[i]);
								if (bIRCImportantKillInfo && irc_link != None)
									irc_link.SendChannelAction(irc_link.DefaultChannel,"achieved"@class'TNMAchievementManager'.default.strAchievementsTitlesCAT5[i]);
								break;
							case 6:
								ClientMessage(strAchievement@class'TNMAchievementManager'.default.strAchievementsTitlesCAT6[i]);
								if (bIRCImportantKillInfo && irc_link != None)
									irc_link.SendChannelAction(irc_link.DefaultChannel,"achieved"@class'TNMAchievementManager'.default.strAchievementsTitlesCAT6[i]);
								break;
							case 7:
								ClientMessage(strAchievement@class'TNMAchievementManager'.default.strAchievementsTitlesCAT7[i]);
								if (bIRCImportantKillInfo && irc_link != None)
									irc_link.SendChannelAction(irc_link.DefaultChannel,"achieved"@class'TNMAchievementManager'.default.strAchievementsTitlesCAT7[i]);
								break;
							case 8:
								ClientMessage(strAchievement@class'TNMAchievementManager'.default.strAchievementsTitlesCAT8[i]);
								if (bIRCImportantKillInfo && irc_link != None)
									irc_link.SendChannelAction(irc_link.DefaultChannel,"achieved"@class'TNMAchievementManager'.default.strAchievementsTitlesCAT8[i]);
								break;
							case 9:
								ClientMessage(strAchievement@class'TNMAchievementManager'.default.strAchievementsTitlesCAT9[i]);
								if (bIRCImportantKillInfo && irc_link != None)
									irc_link.SendChannelAction(irc_link.DefaultChannel,"achieved"@class'TNMAchievementManager'.default.strAchievementsTitlesCAT9[i]);
								break;
						}
					}
					else
						ClientMessage("Tried to award achievement"@API_Name@"but couldn't find it!");
					if (IsInState('PlayerWalking') || IsInState('PlayerSwimming') || IsInState('PlayerFlying'))
						PlaySound(Sound'Menu_Outgoing');
				}
			}
			else if (flagBase.GetBool('PlayerHasCheated') && !flagBase.GetBool('AchievementsDisabled')/* && !bDisplayedAntiCheatOnce*/) // AchievementsDisabled check because if people have the achievements disabled from a modifier they don't need spamming
			{/*
				ClientMessage(AntiCheatMessage);
				bDisplayedAntiCheatOnce = True;
			}*/
		}
	}
}

simulated exec function ViewAchievements()
{
	InvokeUIScreen(Class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.TNMAchievementsMenu", class'Class')) );
}

simulated exec function FakeMPScreen()
{
	InvokeUIScreen(Class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.TNMFakeMPWindow", class'Class')) );
}

// Finds the ammo that the player has the least amount of. bAnyAmmo for hidden ammos like throwing knives and grenades.
// Gives absolute lowest, not percent based
function DeusExAmmo FindRarestAmmo(optional bool bAnyAmmo)
{
	local DeusExAmmo anAmmo, RarestAmmo;
	local inventory item, nextItem;
	local int rarestAmmoAmount;

	anAmmo = None;
	RarestAmmo = None;
	rarestAmmoAmount = 999999;
	
	for(item = Inventory; item != None; item = nextItem)
	{
		anAmmo = DeusExAmmo(item);
		if (anAmmo != None && (anAmmo.bShowInfo || bAnyAmmo) && AmmoNone(anAmmo) == None)
		{
			if (anAmmo.AmmoAmount < rarestAmmoAmount)
			{
				RarestAmmo = anAmmo;
				rarestAmmoAmount = anAmmo.AmmoAmount;
			}
		}
		nextItem = item.Inventory;
	}
	
	return RarestAmmo;
}

// Finds the ammo that the player has the least amount of FOR A WEAPON THEY HAVE. bAnyAmmo for hidden ammos like throwing knives and grenades.
// Gives absolute lowest, not percent based
function DeusExAmmo FindRarestUsedAmmo(optional bool bAnyAmmo)
{
	local DeusExAmmo anAmmo, RarestAmmo;
	local DeusExWeapon aWeapon;
	local inventory item, item2, nextItem, nextItem2;
	local int rarestAmmoAmount;

	anAmmo = None;
	RarestAmmo = None;
	rarestAmmoAmount = 999999;
	
	for(item = Inventory; item != None; item = nextItem)
	{
		anAmmo = DeusExAmmo(item);
		if (anAmmo != None && (anAmmo.bShowInfo || bAnyAmmo) && AmmoNone(anAmmo) == None)
		{
			if (anAmmo.AmmoAmount < rarestAmmoAmount)
			{
				for(item2 = Inventory; item2 != None; item2 = nextItem2)
				{
					aWeapon = DeusExWeapon(item2);
					if (aWeapon != None)
					{
						if (anAmmo == aWeapon.AmmoName || anAmmo == aWeapon.AmmoNames[0] || anAmmo == aWeapon.AmmoNames[1] || anAmmo == aWeapon.AmmoNames[2] || anAmmo == aWeapon.AmmoType)
						{
							RarestAmmo = anAmmo;
							rarestAmmoAmount = anAmmo.AmmoAmount;
						}
					}
					nextItem2 = item2.Inventory;
				}
			}
		}
		nextItem = item.Inventory;
	}
	
	return RarestAmmo;
}

function ZoneChange(ZoneInfo newZone)
{
	if(!Newzone.bWaterZone && bVisibleBreath && breathgen == none)
	{
		spawnBreathgen();
	}
	else if((newzone.bWaterZone || !bVisibleBreath) && breathgen != none)
	{
		breathgen.DelayedDestroy();
	}
	
	if (newZone != None && MelkZone(newZone) != None)
		StopPoison();

	super.ZoneChange(newzone);
}

function vector getBreathOffset()
{
	local vector loc;
	
	loc.X += collisionradius * 0.5;
	loc.Z += BaseEyeHeight*0.91;
	
	if (bIsCrouching)
	{
		loc.X += CollisionRadius * 0.5;
		loc.Z -= CollisionHeight * 0.15;
	}
	loc = loc >> rotation;
	loc += location;
	return loc;
}

function spawnbreathgen()
{
	local vector loc;

	loc = getBreathOffset();

	breathgen = spawn(Class'particlegenerator',self,,loc,rotation);
	if(breathgen != none)
	{
		breathgen.particleTexture=texture'effects.smoke.smokepuff1';
		breathgen.checkTime = 0.1;
		breathgen.riseRate = 3.0;
		breathgen.ejectSpeed = 12.5 * DrawScale;
		breathgen.bRandomEject = true;
		breathgen.particleLifeSpan = 0.5;
		breathgen.SetBase(self);
		breathgen.particleDrawScale = 0.1 * DrawScale * breathSize;
	}/*
	if(AnimSequence == 'BreatheLight' || AnimSequence == 'BreatheLight2H' || AnimSequence == 'SitBreathe')
	{
		//about halfway through is full inhale
		breathtimer = breathtime * animframe;
	}
	else
		breathtimer = frand() * breathtime;*/
}

function updatebreathgen(float dt)
{
	local float mod;
	local int temp;
	local vector loc;
	
	if (breathgen == none)
		return;
		
	if (IsInState('PlayerWalking') || IsInState('Interpolating')/* || IsInState('Cinematic')*/)
	{
		if (breathgen.bSpewing)
			breathgen.UnTrigger(self,self);
		return;
	}
	
	if (bHidden || AugmentationSystem.GetAugLevelValue(class'AugCloak') != -1.0 || UsingChargedPickup(class'AdaptiveArmor'))
	{
		if (breathgen.bSpewing)
			breathgen.UnTrigger(self,self);
		return;
	}

	loc = getBreathOffset();

	breathgen.SetLocation(loc);
	breathgen.setrotation(rotation);

	breathtimer += dt;

	if(breathtimer > breathtime)
		breathtimer = 0.0;

	if((breathtimer < breathtime * 0.5 || breathtimer > breathtime * 0.9) && breathgen.bSpewing)
	{
		breathgen.UnTrigger(self,self);
	}
	else
	{
		if(breathtimer < breathtime * 0.75)
		{
			mod = (breathtimer - (breathtime * 0.5))/(breathtime * 0.25);
		}
		else
		{
			mod = (breathtime - breathtimer)/(breathtime * 0.15);
		}
		if(mod < 0)
		{
			breathgen.UnTrigger(self,self);
			mod = 0;
		}
		else
		{
			breathgen.ejectSpeed = 12.5 * mod;
			if(!breathgen.bSpewing)
				breathgen.Trigger(self,self);
		}
	}
}

// Kills all of the set class (not a destroy)
exec function TantalusAll(class<actor> aClass, optional bool bInvincibleBypass)
{
	local Actor A;
	local ScriptedPawn     hitPawn;
	local DeusExMover      hitMover;
	local DeusExDecoration hitDecoration;
	local bool             bTakeDamage;
	local int              damage;

	if ( !bCheatsEnabled )
		return;
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	ForEach AllActors(class 'Actor', A)
		if ( ClassIsChildOf(A.class, aClass) )
		{
			hitMover = DeusExMover(A);
			hitPawn = ScriptedPawn(A);
			hitDecoration = DeusExDecoration(A);
			bTakeDamage=False;
			if (hitMover != None)
			{
				if (hitMover.bBreakable)
				{
					hitMover.doorStrength = 0;
					bTakeDamage = true;
				}
			}
			else if (hitPawn != None)
			{
				if (!hitPawn.bInvincible || bInvincibleBypass)
				{
					if (bInvincibleBypass)
						hitPawn.bInvincible = false;
					hitPawn.HealthHead     = 0;
					hitPawn.HealthTorso    = 0;
					hitPawn.HealthLegLeft  = 0;
					hitPawn.HealthLegRight = 0;
					hitPawn.HealthArmLeft  = 0;
					hitPawn.HealthArmRight = 0;
					hitPawn.Health         = 0;
					bTakeDamage = true;
				}
			}
			else if (hitDecoration != None)
			{
				if (!hitDecoration.bInvincible || bInvincibleBypass)
				{
					if (bInvincibleBypass)
						hitDecoration.bInvincible = false;
					hitDecoration.HitPoints = 0;
					bTakeDamage = true;
				}
			}
			else if (A != Level)
			{
				damage = 5000;
				bTakeDamage = true;
			}

			if (bTakeDamage)
				A.TakeDamage(damage, self, vect(0,0,0), vect(0,0,0), 'Tantalus');
		}
}

// Knocks out all of the set class and disables robots
exec function TantabusAll(class<actor> aClass, optional bool bInvincibleBypass)
{
	local Actor A;
	local ScriptedPawn     hitPawn;
	local DeusExMover      hitMover;
	local DeusExDecoration hitDecoration;
	local bool             bTakeDamage;
	local int              damage;

	if ( !bCheatsEnabled )
		return;
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	ForEach AllActors(class 'Actor', A)
		if ( ClassIsChildOf(A.class, aClass) )
		{
			hitMover = DeusExMover(A);
			hitPawn = ScriptedPawn(A);
			hitDecoration = DeusExDecoration(A);
			bTakeDamage=False;
			if (hitMover != None)
			{
				if (hitMover.bBreakable)
				{
					hitMover.doorStrength = 0;
					bTakeDamage = true;
				}
			}
			else if (hitPawn != None)
			{
				if (!hitPawn.bInvincible || bInvincibleBypass)
				{
					if (bInvincibleBypass)
						hitPawn.bInvincible = false;
					if (Robot(A) != None)
						Robot(A).EMPHitPoints = 0;
					else
					{
						hitPawn.HealthHead     = 0;
						hitPawn.HealthTorso    = 0;
						hitPawn.HealthLegLeft  = 0;
						hitPawn.HealthLegRight = 0;
						hitPawn.HealthArmLeft  = 0;
						hitPawn.HealthArmRight = 0;
						hitPawn.Health         = 0;
					}
					bTakeDamage = true;
				}
			}
			else if (hitDecoration != None)
			{
				if (!hitDecoration.bInvincible || bInvincibleBypass)
				{
					if (bInvincibleBypass)
						hitDecoration.bInvincible = false;
					hitDecoration.HitPoints = 0;
					bTakeDamage = true;
				}
			}
			else if (A != Level)
			{
				damage = 5000;
				bTakeDamage = true;
			}

			if (bTakeDamage)
			{
				A.TakeDamage(damage, self, vect(0,0,0), vect(0,0,0), 'KnockedOut');
				A.TakeDamage(damage, self, vect(0,0,0), vect(0,0,0), 'PoisonEffect');
				A.TakeDamage(damage, self, vect(0,0,0), vect(0,0,0), 'Stunned');
				A.TakeDamage(damage, self, vect(0,0,0), vect(0,0,0), 'Poison');
			}
				
			if (Robot(A) != None)
				A.TakeDamage(damage, self, vect(0,0,0), vect(0,0,0), 'EMP');
		}
}

exec function AllPasswords()
{
	AllKeys();
}

exec function AllKeys()
{
	local DeusExMover M;

	if (bCheatsEnabled)
	{
		if (KeyRing != None)
		{
			foreach AllActors(class'DeusExMover', M)
			{
				if (M.KeyIDNeeded != '')
					KeyRing.GiveKey(M.KeyIDNeeded, String(M.KeyIDNeeded));
			}
		}
	}
}

exec function ThereIsNoRadish()
{
	if (Sprite == None)
	{
		Sprite = Texture(DynamicLoadObject("TNM_Core_Tex.Effects.TrainingTex", class'Texture'));
		ConsoleCommand("RMODE 6");
	}
	else
	{
		Sprite = None;
		ConsoleCommand("RMODE 5");
	}
}

function bool IsFrobbable(actor A)
{
	// No reason to frob flies, but they can get in the way of datacubes.
	if (Fly(A) != None)
		return False;

	// If we are carrying a downed player's carcass, let Right-Click drop the body instead of targeting its own totem
	if (CarriedDecoration != None && YuukaReviveTotem(A) != None && YuukaReviveTotem(A).LinkedCarcass == CarriedDecoration)
		return False;

	return Super.IsFrobbable(A);
}

function Carcass SpawnCarcass()
{
	local Carcass carc;
	local pawn playerkiller;	
    local DeusExLevelInfo info;
	local Vector loc;

	// If ZP or Slicer kills the player, move the player to the prison cell and set the up the captivity sequence
	if (flagbase.GetBool('MS_ABIBossTauntSent') && !flagbase.GetBool('MS_PlayerCaptured'))
	{
		info = GetLevelInfo();
		if (info != None && Caps(info.mapName) == "23_ABIRUINS")
		{
			playerkiller = tnmgameinfo(level.game).playerkiller;
			if (playerkiller != None &&
			   ((playerkiller.Tag == 'ZeroPresence') ||
			    (playerkiller.Tag == 'ZPHenchman') ||
			    (playerkiller.Tag == 'Slicer') ||
			    (playerkiller.Tag == 'SlicerHenchman')))
			{
				return none; // don't spawn a carc if we're about to be moved to prison
			}
		}
	}

	if (Level.NetMode != NM_Standalone)
	{
		SetInHandPending(None);
		SetInHand(None);
		bInHandTransition = False;
		carc = Spawn(CarcassType);
		if (DeusExCarcass(carc) != None)
		{
			if (TrestkonCarcass(carc) != None)
				TrestkonCarcass(carc).SetSkin(Self);
			DeusExCarcass(carc).Initfor(Self);
			loc = Location;
			loc.Z -= CollisionHeight;
			loc.Z += carc.CollisionHeight;
			carc.SetLocation(loc);
			DeusExCarcass(carc).bPlayerCarcass = True;
			DeusExCarcass(carc).itemName = GetCoopPlayerName() $ "'s Body (Right-Click to Carry)";
			if (TNMCarcass(carc) != None)
			{
				TNMCarcass(carc).FamiliarName = GetCoopPlayerName() $ "'s Body (Right-Click to Carry)";
				TNMCarcass(carc).UnfamiliarName = GetCoopPlayerName() $ "'s Body (Right-Click to Carry)";
			}
			MoveTarget = carc;
		}
	}
	else
	{
		carc = Super.SpawnCarcass();
	}
	if (DeusExCarcass(carc) != None)
		DeusExCarcass(carc).bNotDead = bStunned;
	if (TNMCarcass(carc) != None && Region.Zone != None && Region.Zone.DamageType == 'Atmospheric')
	{
		TNMCarcass(carc).bAtmosphericDeath = True;
		TNMCarcass(carc).Mesh = TNMCarcass(carc).Mesh3;
	}

	return carc;
}

// Overlays red/green onto the ABI tunnel lights
exec function TestTextures()
{
	local texture t1, t2, t3;
	
	t2 = Texture(DynamicLoadObject("TNM_Support_Tex.Metal.QIEX_015",class'Texture'));
	t3 = Texture(DynamicLoadObject("TNM_Support_Tex.Metal.Q1EX_074",class'Texture'));
	
	foreach AllObjects(class'Texture', t1)
	{
		// log(t1.Name);
		if (t1.Name == 'area51hllway_a')
			if (FRand() < 0.5)
				t1.MacroTexture = t2;
			else
				t1.MacroTexture = t3;
	}
}

function bool GetItemRefusalSetting(inventory anItem)
{
	local string className;
	local string checkString;
	local bool result;
	
	className = GetItemRefusalName(anItem);
		
	checkString = "bRefuse"$className;
	
	result = bool(GetPropertyText(checkString));
	
	return result;
}

function string GetItemRefusalName(inventory anItem)
{
	local string className;	

	className = string(anItem.Class.Name);
	if (anItem.IsA('WeaponMod'))
		className = "WeaponMod";
	else if (anItem.IsA('WeaponFireExting'))
		className = "FireExtinguisher";
	else if (anItem.IsA('TNMVialCrack'))
		className = "Melk";
	else if (anItem.IsA('WeaponTNMAssaultGun') || anItem.IsA('WeaponUniqueKylie'))
		className = "WeaponAssaultGun";
	else if (anItem.IsA('WeaponTNMAssaultShotgun'))
		className = "WeaponAssaultShotgun";
	else if (anItem.IsA('WeaponTNMBaton'))
		className = "WeaponBaton";
	else if (anItem.IsA('WeaponTNMCombatKnife'))
		className = "WeaponCombatKnife";
	else if (anItem.IsA('WeaponTNMCrowbar'))
		className = "WeaponCrowbar";
	else if (anItem.IsA('WeaponTNMEMPGrenade'))
		className = "WeaponEMPGrenade";
	else if (anItem.IsA('WeaponTNMFlamethrower'))
		className = "WeaponFlamethrower";
	else if (anItem.IsA('WeaponTNMGasGrenade'))
		className = "WeaponGasGrenade";
	else if (anItem.IsA('WeaponTNMGEPGun'))
		className = "WeaponGEPGun";
	else if (anItem.IsA('WeaponTNMHideAGun'))
		className = "WeaponHideAGun";
	else if (anItem.IsA('WeaponTNMLAM'))
		className = "WeaponLAM";
	else if (anItem.IsA('WeaponTNMLAW'))
		className = "WeaponLAW";
	else if (anItem.IsA('WeaponTNMMiniCrossbow'))
		className = "WeaponMiniCrossbow";
	else if (anItem.IsA('WeaponTNMNanoSword'))
		className = "WeaponNanoSword";
	else if (anItem.IsA('WeaponTNMNanoVirusGrenade'))
		className = "WeaponNanoVirusGrenade";
	else if (anItem.IsA('WeaponTNMSword'))
		className = "WeaponSword";
	else if (anItem.IsA('WeaponTNMPepperGun'))
		className = "WeaponPepperGun";
	else if (anItem.IsA('WeaponTNMPistol'))
		className = "WeaponPistol";
	else if (anItem.IsA('WeaponTNMPlasmaRifle'))
		className = "WeaponPlasmaRifle";
	else if (anItem.IsA('WeaponTNMProd'))
		className = "WeaponProd";
	else if (anItem.IsA('WeaponTNMRifle') || anItem.IsA('WeaponUniqueZP'))
		className = "WeaponRifle";
	else if (anItem.IsA('WeaponTNMSawedOffShotgun'))
		className = "WeaponSawedOffShotgun";
	else if (anItem.IsA('WeaponTNMShuriken'))
		className = "WeaponShuriken";
	else if (anItem.IsA('WeaponTNMStealthPistol') || anItem.IsA('WeaponUniqueAO'))
		className = "WeaponStealthPistol";
	else if (anItem.IsA('WeaponUniqueNVS'))
		className = "WeaponScrewDriver";
	else if (anItem.IsA('AugCannisterALER') || anItem.IsA('AugCannisterBPES') || anItem.IsA('AugCannisterCRT') || anItem.IsA('AugCannisterHS') || anItem.IsA('AugCannisterMC') || anItem.IsA('AugCannisterSDAD') || anItem.IsA('AugCannisterSHPR') || anItem.IsA('AugCannisterSS') || anItem.IsA('AugCannisterTV'))
		className = "AugmentationCannister";
		
	return className;
}

//
// lip synching support - DEUS_EX CNN
//
function LipSynch(float deltaTime)
{
	local name animseq;
	local float rnd;
	local float tweentime;

	// update the animation timers that we are using
	animTimer[0] += deltaTime;
	animTimer[1] += deltaTime;
	animTimer[2] += deltaTime;

	if (bIsSpeaking)
	{
		// if our framerate is high enough (>20fps), tween the lips smoothly
		if (Level.TimeSeconds - animTimer[3]  < 0.05)
			tweentime = 0.25; // Was 0.1
		else
			tweentime = 0.0;

		// the last animTimer slot is used to check framerate
		animTimer[3] = Level.TimeSeconds;

		if (nextPhoneme == "A")
			animseq = 'MouthA';
		else if (nextPhoneme == "E")
			animseq = 'MouthE';
		else if (nextPhoneme == "F")
			animseq = 'MouthF';
		else if (nextPhoneme == "M")
			animseq = 'MouthM';
		else if (nextPhoneme == "O")
			animseq = 'MouthO';
		else if (nextPhoneme == "T")
			animseq = 'MouthT';
		else if (nextPhoneme == "U")
			animseq = 'MouthU';
		else if (nextPhoneme == "X")
			animseq = 'MouthClosed';

		if (animseq != '' && HasAnim(animseq))
		{
			if (lastPhoneme != nextPhoneme)
			{
				lastPhoneme = nextPhoneme;
				TweenBlendAnim(animseq, tweentime);
			}
		}
	}
	else if (bWasSpeaking)
	{
		bWasSpeaking = False;
		TweenBlendAnim('MouthClosed', tweentime);
	}

	// blink randomly
	if (animTimer[0] > 2.0)
	{
		animTimer[0] = 0;
		if ((FRand() < 0.4  || IsInState('RubbingEyes')) && HasAnim('Blink'))
			PlayBlendAnim('Blink', 1.0, 0.1, 1);
	}

	LoopHeadConvoAnim();
	LoopBaseConvoAnim();
}

final static function string HexDigit( int Value )
{
    switch ( Value&0xF )
    {
        case 0x0: return "0";
        case 0x1: return "1";
        case 0x2: return "2";
        case 0x3: return "3";
        case 0x4: return "4";
        case 0x5: return "5";
        case 0x6: return "6";
        case 0x7: return "7";
        case 0x8: return "8";
        case 0x9: return "9";
        case 0xA: return "A";
        case 0xB: return "B";
        case 0xC: return "C";
        case 0xD: return "D";
        case 0xE: return "E";
        default:  return "F";
    }
}

final static function string Hex( int Value, optional int MinDigits )
{
    local string Result;

    while ( Value!=0 || MinDigits>0 )
    {
        Result = HexDigit( Value&0xF ) $ Result;
    
        Value = Value>>>4; MinDigits--;
    }
	
	return Result;
}

exec function ShowHud(bool bShow)
{
	Super.ShowHud(bShow);
	
	if (rh != None)
		rh.ShowHud(bShow);
}

function Bool FindInventorySlot(Inventory anItem, optional Bool bSearchOnly)
{
	local bool bPositionFound;
	local int row;
	local int col;
	local int newSlotX;
	local int newSlotY;
	local int beltpos;
	local ammo foundAmmo;

	if (anItem == None)
		return False;
	
	// Special checks for objects that do not require phsyical inventory
	// in order to be picked up:
	// 
	// - NanoKeys
	// - DataVaultImages
	// - Credits
	// - Ammo

	if ((anItem.IsA('DataVaultImage')) || (anItem.IsA('NanoKey')) || (anItem.IsA('Credits')) || (anItem.IsA('Ammo')) || (anItem.IsA('PosterTube')) || (anItem.IsA('TNMBinoculars')))
		return True;

	bPositionFound = False;	
	
	if ((DeusExPickUp(anItem) != None && !bool(anItem.GetPropertyText("bItemRefusalOverride"))) || (DeusExWeapon(anItem) != None && !bool(anItem.GetPropertyText("bItemRefusalOverride"))))
		if (GetItemRefusalSetting(anItem))
			return False;
   
   
	// DEUS_EX AMSD In multiplayer, due to propagation delays, the inventory refreshers in the
	// personascreeninventory can keep bouncing items back and forth.  So just return true and
	// place the item where it already was.
	if ((anItem.invPosX != -1) && (anItem.invPosY != -1) && (Level.NetMode != NM_Standalone) && (!bSearchOnly))
	{
		SetInvSlots(anItem,1);
		log("Trying to place item "$anItem$" when already placed at "$anItem.invPosX$", "$anItem.invPosY$".");
		return True;
	}

	// Loop through all slots, looking for a fit
	for (row=0; row<maxInvRows; row++)
	{	
		if (row + anItem.invSlotsY > maxInvRows)
			break;

		// Make sure the item can fit vertically
		for(col=0; col<maxInvCols; col++)
		{
			if (IsEmptyItemSlot(anItem, col, row ))
			{
				bPositionFound = True;
				break;
			}
		}

		if (bPositionFound)
			break;
	}

	if ((Level.NetMode != NM_Standalone) && (bBeltIsMPInventory))
	{
		bPositionFound = False;
		beltpos = 0;
		if (DeusExRootWindow(rootWindow) != None)
		{
			for (beltpos = 0; beltpos < ArrayCount(tnmHUDObjectBelt(DeusExRootWindow(rootWindow).hud.belt).newobjects); beltpos++)
			{
				if ( (tnmHUDObjectBelt(DeusExRootWindow(rootWindow).hud.belt).newobjects[beltpos].item == None) && (anItem.TestMPBeltSpot(beltpos)) )
				{
					bPositionFound = True;
				}
			}
		}
		else
		{
			log("no belt to check");
		}
	}

	if ((bPositionFound) && (!bSearchOnly))
	{
		PlaceItemInSlot(anItem, col, row);
	}
   
	return bPositionFound;
}

// ----------------------------------------------------------------------
// ResetGoals()
// 
// Called when progressing to the next mission.  Deletes all 
// completed Primary Goals as well as *ALL* Secondary Goals 
// (regardless of status)
// ----------------------------------------------------------------------

function ResetGoals()
{
	local DeusExGoal goal;
	local DeusExGoal goalNext;
	local DeusExLevelInfo info;

	goal = FirstGoal;
	info = GetLevelInfo();

	while( goal != None )
	{
		goalNext = goal.next;

		// Delete:
		// 1) Completed Primary Goals
		// 2) ALL Secondary Goals - Except BlackICE, which is multi-day
			
		if (goal.goalName == 'BlackICE' && info.MissionNumber > 22)
			DeleteGoal(goal);

		if ((!goal.IsPrimaryGoal() && goal.goalName != 'BlackICE') || (goal.IsPrimaryGoal() && goal.IsCompleted()))
			DeleteGoal(goal);

		goal = goalNext;
	}
}

exec function ActivateMedkit()
{	
	local Inventory Inv;
	
	Inv = FindInventoryType(Class'DeusEx.Medkit');
	if ( Inv != None )
		ClientMessage(Inv.ItemName @ CountRemainingString @ (Pickup(Inv).NumCopies - 1));
	
	ActivateInventoryItem(Class'DeusEx.Medkit');
}

exec function ActivateBioCell()
{
	local Inventory Inv;
	
	Inv = FindInventoryType(Class'DeusEx.BioelectricCell');
	if ( Inv != None )
		ClientMessage(Inv.ItemName @ CountRemainingString @ (Pickup(Inv).NumCopies - 1));
	
	ActivateInventoryItem(Class'DeusEx.BioelectricCell');
}

function PostPostBeginPlay()
{
	local DeusExLevelInfo info;
	local string localURL;
	local tnmTextureSwapController swapper;
	
	Super.PostPostBeginPlay();

	foreach AllActors(class'DeusExLevelInfo', info)
		break;
		
	if (info != None)
		localURL = Caps(info.mapName);
	
	// Because textures are transient
	if ((localURL == "20_GOATCITY") || (localURL == "22_GOATCITY") ||
		 (localURL == "20_GOATTEMPLAE") || (localURL == "22_GOATTEMPLAE"))
	{
		// Make everybody hostile (1) if the player is allied to the Llamas or (2) if he betrayed Dark Templar or (3) if DT or Athena are dead
		if (flagbase.GetBool('ALLIED_CULT_LLAMA') || flagbase.GetBool('DT_Pissed') || flagbase.GetBool('DarkTemplar_Dead') || flagbase.GetBool('Athena_Dead'))
		{			
			// Swap out the Goat City screens with wanted posters
			foreach AllActors(class'tnmTextureSwapController', swapper)
			{
				swapper.secondaryTexture = texture(DynamicLoadObject("TNM_Support_Tex.Signs.TrestkonWanted"$PlayerSkin, class'texture' ));
				swapper.bSwapped = False; // Textures reset between level transitions?
				swapper.Trigger(None, None);
			}
		}
	}
	
	// Spawn a new FollowingSound
	if (PrecipitationZone(Region.Zone) != None)
		Region.Zone.ActorEntered(Self);
}

// ----------------------------------------------------------------------
// DisableFlashingLights()
//
// Disables all lights on the level when anti-epilepsy setting is changed.
// ----------------------------------------------------------------------
function DisableFlashingLights()
{
	local Light 					light;
	local BarrelFire 				BarrelFire;

	if (bEpilepsyReduction) // Disable all flickering lights.
	{
		foreach AllActors(class'Light', light)
		{
			if (light.LightType == LT_Flicker || light.LightType == LT_Strobe)
			{
				light.LightType = LT_Steady;
				light.bLightChanged = True;
			}
		}

		foreach AllActors(class'BarrelFire', BarrelFire) // These too, just incase.
		{
			BarrelFire.LightType = LT_Steady;
		}
	}
}

exec function CheatMenu()
{
	if (!bCheatsEnabled)
		return;
	
	DeusExRootWindow(rootWindow).InvokeMenu(Class<DeusExBaseWindow>(dynamicloadobject("TNMGUI.TNMMenuCheats", class'class')));	
}

exec function RuleofThirds()
{
	bRuleofThirds = !bRuleofThirds;
}

exec function CameraMode(bool bOn)
{
	local DeusExRootWindow root;
	if (!bCheatsEnabled)
		return;	
	
	bObjectBeltVisible = !bOn;
	bHitDisplayVisible = !bOn;
	bAmmoDisplayVisible = !bOn;
	bAugDisplayVisible = !bOn;
	bCompassVisible = !bOn;
	bCrosshairVisible = !bOn;
	bEggVisible = !bOn;
	bRuleofThirds = bOn;

	root = DeusExRootWindow(rootWindow);
	if (root != None)
		root.UpdateHud();
	Invisible(bOn);
	if (bOn)
		Ghost();
	else
		Walk();
}

// ----------------------------------------------------------------------
// NextBeltItem()
// ----------------------------------------------------------------------

simulated exec function ActivateBelt(int objectNum)
{
	local Trestkon HostPlayer;
	local TNMConWindowActive win;
	local int choiceIdx;

	if (Level.NetMode != NM_Standalone && Role == ROLE_Authority && NetConnection(Player) != None)
	{
		HostPlayer = Trestkon(GetPlayerPawn());
		if (HostPlayer != None && tnmconplay(HostPlayer.conPlay) != None)
		{
			win = TNMConWindowActive(HostPlayer.conPlay.conWinThird);
			if (win != None && win.numChoices > 0)
			{
				choiceIdx = (objectNum - 1 + 10) % 10;
				if (choiceIdx >= 0 && choiceIdx < win.numChoices)
					tnmconplay(HostPlayer.conPlay).SelectCoopChoice(choiceIdx);
				return;
			}
		}
	}

	if (Level.NetMode == NM_Client && bClientHasConChoices && clientConChoiceCount > 0)
	{
		if (objectNum >= 1 && objectNum <= clientConChoiceCount)
		{
			ConfirmClientConChoice(objectNum - 1);
			return;
		}
	}
	Super.ActivateBelt(objectNum);
}

simulated exec function NextBeltItem()
{
	local DeusExRootWindow root;
	local int slot, startSlot;
	local int i;

	if (RestrictInput())
		return;

	if (Level.NetMode == NM_Client && bClientHasConChoices && clientConChoiceCount > 0)
	{
		clientSelectedConChoice = (clientSelectedConChoice + 1) % clientConChoiceCount;
		RefreshClientConChoicesDisplay();
		return;
	}

	if (CarriedDecoration == None)
	{
		slot = 0;
		root = DeusExRootWindow(rootWindow);
		if (root != None)
		{
			if (ClientInHandPending != None)
				slot = ClientInHandPending.beltPos;
			else if (inHandPending != None)
				slot = inHandPending.beltPos;
			else if (inHand != None)
				slot = inHand.beltPos;

			startSlot = slot;
			do
			{
				if (bEnlargedBelt)
				{
					if (++slot >= 12)
						slot = 0;
				}
				else
				{
					if (++slot >= 10)
						slot = 0;
				}
				i++;
			}
			until ((root.ActivateObjectInBelt(slot)) || (startSlot == slot) || i > 100);

			clientInHandPending = root.hud.belt.GetObjectFromBelt(slot);
		}
	}
}

// ----------------------------------------------------------------------
// PrevBeltItem()
// ----------------------------------------------------------------------

simulated exec function PrevBeltItem()
{
	local DeusExRootWindow root;
	local int slot, startSlot;
	local int i;

	if (RestrictInput())
		return;

	if (Level.NetMode == NM_Client && bClientHasConChoices && clientConChoiceCount > 0)
	{
		clientSelectedConChoice = (clientSelectedConChoice - 1 + clientConChoiceCount) % clientConChoiceCount;
		RefreshClientConChoicesDisplay();
		return;
	}

	if (CarriedDecoration == None)
	{
		slot = 1;
		root = DeusExRootWindow(rootWindow);
		if (root != None)
		{
			if (ClientInHandPending != None)
				slot = ClientInHandPending.beltPos;
			else  if (inHandPending != None)
				slot = inHandPending.beltPos;
			else if (inHand != None)
				slot = inHand.beltPos;

			startSlot = slot;
			do
			{
				if (bEnlargedBelt)
				{
					if (--slot <= -1)
						slot = 11;
				}
				else
				{
					if (--slot <= -1)
						slot = 9;
				}
				i++;
			}
			until ((root.ActivateObjectInBelt(slot)) || (startSlot == slot) || i > 100);

			clientInHandPending = root.hud.belt.GetObjectFromBelt(slot);
		}
	}
}

function Reloading(DeusExWeapon weapon, float reloadTime)
{
	if (!IsLeaning() && !bIsCrouching && (Physics != PHYS_Swimming) && !IsInState('Dying'))
		LoopAnim('Reload', 1.0 / reloadTime, 0.1, 1.0 / reloadTime);
}

exec function Invasion(optional int count)
{
	local int i, j, RNG;
	local TNMPawn 		  Invader;
	local Class<TNMPawn>  InvaderClass;
	local NavigationPoint TeleportPoint;
	local DeusExLevelInfo info;
	
	if (!bCheatsEnabled)
		return;
	
	if (count == 0)
		count = 1;
	if (count > 50)
		count = 50;
	info = GetLevelInfo();
	for (i=0; i<count; i++)
	{
		if(info!=none)
		{
			switch (info.MissionNumber)
			{
				case 20:
					switch (Caps(info.mapname))
					{
						case "20_DESPOT":
							InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.TNMKarkianBaby2",class'Class'));
							break;
						case "20_DXO":
							InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.TNMGreasel",class'Class'));
							break;
						case "20_FCCORPORATE":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall2",class'Class'));
							break;
						case "20_FCCORPSEWERS":
							InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.TNMGreasel",class'Class'));
							break;
						case "20_FCDOWNTOWN":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall2",class'Class'));
							break;
						case "20_FCSLUMS":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall2",class'Class'));
							break;
						case "20_GOATCITY":
							RNG = Rand(4);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Goat1",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Goat2",class'Class'));
							if (RNG == 2)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Goat3",class'Class'));
							if (RNG == 3)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.GoatFemale",class'Class'));
							break;
						case "20_GOATTEMPLAE":
							RNG = Rand(4);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Goat1",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Goat2",class'Class'));
							if (RNG == 2)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Goat3",class'Class'));
							if (RNG == 3)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.GoatFemale",class'Class'));
							break;
						case "20_LLAMATEMPLE":
							RNG = Rand(4);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Llama1",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Llama2",class'Class'));
							if (RNG == 2)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Llama3",class'Class'));
							if (RNG == 3)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.LlamaFemale",class'Class'));
							break;
						case "20_NSC":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall2",class'Class'));
							break;
						case "20_OSC01":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Hoverbot",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.SpydronePawn",class'Class'));
							break;
						case "20_OSC02":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Hoverbot",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.SpydronePawn",class'Class'));
							break;
						case "20_OSC03":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Hoverbot",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.SpydronePawn",class'Class'));
							break;
						case "20_OSC04":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Hoverbot",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.SpydronePawn",class'Class'));
							break;
						case "20_PARTYZONE":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall2",class'Class'));
							break;
						case "20_PDXHQ01":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall2",class'Class'));
							break;
						case "20_PDXHQ02":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall2",class'Class'));
							break;
						case "20_PHASAPARTMENT":
							InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.GPRentACop",class'Class'));
							break;
						case "20_SOLSBAR":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall2",class'Class'));
							break;
						case "20_VOODOOSHOP":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall2",class'Class'));
							break;
						case "20_WCFLOOR1":
							InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.WCSecurity",class'Class'));
							break;
						case "20_WCFLOOR2":
							InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.WCSecurity",class'Class'));
							break;
						case "20_WCFLOOR3":
							InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.WCSecurity",class'Class'));
							break;
						case "20_WCFLOOR4":
							InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.WCSecurity",class'Class'));
							break;
						case "20_WCHOTEL":
							InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.WCCommando",class'Class'));
							break;
						case "20_WCSUBLEVEL":
							InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.WCCommando",class'Class'));
							break;
						case "20_WEAPONSHOP":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall2",class'Class'));
							break;
					}
					break;
				case 21:
					// switch (Caps(info.mapname))
					// {
						InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.DXIAvatar",class'Class'));
						// break;
					// }
					break;
				case 22:
					switch (Caps(info.mapname))
					{
						case "22_ATC":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.DXACop",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.DXAGuard",class'Class'));
							break;
						case "22_DXEDITING":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall2",class'Class'));
							break;
						case "22_DXO":
							InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.TNMGreasel",class'Class'));
							break;
						case "22_FCCORPORATE":
							if (flagbase.GetBool('ALLIED_PDX'))
							{
								RNG = Rand(2);
								if (RNG == 0)
									InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.WCCommando",class'Class'));
								if (RNG == 1)
									InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.WCThug",class'Class'));
							}
							else
							{
								RNG = Rand(2);
								if (RNG == 0)
									InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall",class'Class'));
								if (RNG == 1)
									InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall2",class'Class'));
							}
							break;
						case "22_FCCORPSEWERS":
							InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.TNMGreasel",class'Class'));
							break;
						case "22_FCDOWNTOWN":						
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall2",class'Class'));
							break;
						case "22_FCSLUMS":
							if (flagbase.GetBool('ALLIED_PDX'))
							{
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.WCCommando",class'Class'));
							}
							else
							{
								RNG = Rand(2);
								if (RNG == 0)
									InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall",class'Class'));
								if (RNG == 1)
									InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall2",class'Class'));
							}
							break;
						case "22_GOATCITY":
							RNG = Rand(4);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Goat1",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Goat2",class'Class'));
							if (RNG == 2)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Goat3",class'Class'));
							if (RNG == 3)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.GoatFemale",class'Class'));
							break;
						case "22_GOATTEMPLAE":
							RNG = Rand(7);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Goat1",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Goat2",class'Class'));
							if (RNG == 2)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Goat3",class'Class'));
							if (RNG == 3)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.GoatFemale",class'Class'));
							if (RNG == 4)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.GoatTemplar1",class'Class'));
							if (RNG == 5)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.GoatTemplar2",class'Class'));
							if (RNG == 6)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.GoatTemplar3",class'Class'));
							break;
						case "22_LLAMATEMPLE":
							RNG = Rand(4);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Llama1",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Llama2",class'Class'));
							if (RNG == 2)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Llama3",class'Class'));
							if (RNG == 3)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.LlamaFemale",class'Class'));
							break;
						case "22_PDXHQ01":
								RNG = Rand(4);
								if (RNG == 0)
									InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall",class'Class'));
								if (RNG == 1)
									InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall2",class'Class'));
								if (RNG == 2)
									InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.DXACop",class'Class'));
								if (RNG == 3)
									InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.DXAGuard",class'Class'));
							break;
						case "22_PDXHQ02":
								RNG = Rand(4);
								if (RNG == 0)
									InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall",class'Class'));
								if (RNG == 1)
									InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall2",class'Class'));
								if (RNG == 2)
									InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.DXACop",class'Class'));
								if (RNG == 3)
									InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.DXAGuard",class'Class'));
							break;
						case "22_SOLSBAR":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall2",class'Class'));
							break;
						case "22_VOODOOSHOP":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall2",class'Class'));
							break;
						case "22_WCFLOOR1":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.WCSecurity",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.WCCommando",class'Class'));
							break;
						case "22_WCFLOOR4":
							InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.WCCommando",class'Class'));
							break;
						case "22_WCSUBLEVEL":
							InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.WCCommando",class'Class'));
							break;
						case "22_WEAPONSHOP":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.FireWall2",class'Class'));
							break;
					}
					break;
				case 23:
					switch (Caps(info.mapname))
					{
						case "23_ABIAPPROACH":							
							RNG = Rand(5);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.ABISecurityGuard",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.ABIFemaleGuard",class'Class'));
							if (RNG == 2)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.ABISecurityGuard",class'Class'));
							if (RNG == 3)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.ABIFemaleGuard",class'Class'));
							if (RNG == 4)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.ABIScubaDiver",class'Class'));
							break;
						case "23_ABIEXTERIOR":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.ABISecurityGuard",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.ABIFemaleGuard",class'Class'));
							break;
						case "23_ABIINTERIOR":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.ABISecurityGuard",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.ABIFemaleGuard",class'Class'));
							break;
						case "23_ABIRUINS":
							RNG = Rand(2);
							if (RNG == 0)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.ABICommando",class'Class'));
							if (RNG == 1)
								InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.ABIEliteGuard",class'Class'));
							break;
						case "23_ABILABS":
							InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.ABIEliteGuard",class'Class'));
							break;
					}
					break;
				case 24:
					RNG = Rand(3);
					if (RNG == 0)
						InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Alien",class'Class'));
					if (RNG == 1)
						InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Phaser",class'Class'));
					if (RNG == 2)
						InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.Stalker",class'Class'));
					break;
				default:
					InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.GPRentACop",class'Class'));
			}
		}
		else
			InvaderClass = class<TNMPawn>(DynamicLoadObject("TNMCharacters.GPRentACop",class'Class'));

		Invader = None;

		foreach RadiusActors(Class'NavigationPoint', teleportPoint, 8192, Location)
		{
			// Can the boogeyman see our spot?
			if (FRand() < 0.1 && teleportPoint != None && !teleportPoint.IsA('MapExit') && !teleportPoint.IsA('InventorySpot') && !teleportPoint.IsA('Teleporter') && !teleportPoint.PlayerCanSeeMe() && VSize(TeleportPoint.Location - Location) > 512)
			{
				Invader = Spawn( InvaderClass, , 'Invader', teleportPoint.Location, teleportPoint.Rotation);

				if (Invader != None)
				{
					if (Invader.Physics != PHYS_Flying || Invader.Default.Physics != PHYS_Flying)
						Invader.SetPhysics(PHYS_Falling);
					// if (RevPawnHook(Invader) != None)
					// {
						Invader.SetupInvader(); // Gives the pawn a randomized inventory and makes them hate the player.
						// RevPawnHook(Invader).SetupInvader(); // Gives the pawn a randomized inventory and makes them hate the player.
						// RevPawnHook(Invader).bDeleteInventoryonDeath = True;
					// }

					// Invader.BindName = "Invader_" $ String(i);
					// Invader.Alliance = 'SecretService';
					Invader.GoToState('Seeking');
					Invader.SetOrders('Shadowing');
					Invader.ChangeAlly(Invader.Alliance, 1, True);
					// Invader.ChangeAlly('MJ12', 1, True);
					// if (GetLevelInfo().MissionNumber > 4)
						// Invader.ChangeAlly('UNATCO', 1, True);
					// Invader.ChangeAlly('NSF', -1, True);
					Invader.bReactFutz = True;
					Invader.bReactPresence = True;
					Invader.bReactLoudNoise = True;
					Invader.bReactAlarm = True;
					Invader.bReactShot = True;
					Invader.bReactCarcass = True;
					Invader.bReactDistress = True;
					Invader.bReactProjectiles = True;
					// Invader.HearingThreshold = HearingThreshold;
					// Invader.VisibilityThreshold = VisibilityThreshold;
					// Invader.bImportant = True;
					Invader.MinHealth = 0;
					/*
					if (localPlayer.bZombieMode) // Zombie mode bonuses
					{
						Invader.GroundSpeed = Invader.Default.GroundSpeed * 2.5;
						Invader.AirSpeed = Invader.GroundSpeed;
						Invader.bAvoidHarm = False;
						Invader.bAvoidAim = False;
						Invader.ClotPeriod = 10;
						Invader.fatness = 120;
						Invader.ScaleGlow = 0.5;
						Invader.MaxStepHeight = Invader.Default.MaxStepHeight * 2;
						Invader.JumpZ = Invader.Default.JumpZ * 4.5;
					}
					if (localPlayer.bMatrixModeAgents)
						RevPawnHook(Invader).bDoAgentMorph = true;
					if (localPlayer.bOmniVision)
						Invader.AIHorizontalFOV = 360;
					if (localPlayer.bTransferWeapon)
						Invader.bKeepWeaponDrawn = true;
					if (localPlayer.bAviationMode)
						Invader.SetPhysics(PHYS_Flying);
					if (localPlayer.bTeleportingPawns)
						RevPawnHook(Invader).bCreepyTeleporter = true;
					if (localPlayer.bOneOfUsMode)
					{
						//Swap to the players mesh.
						Invader.Mesh=localPlayer.Mesh;

						Invader.CarcassType=Class'DeusEx.JCDentonMaleCarcass';

						Invader.BarkBindName = "FakeJC";
						Invader.UnfamiliarName = "JC Denton";
						Invader.FamiliarName = localPlayer.TruePlayerName;

						Invader.ConBindEvents();	// I don't know what this does but it's needed for the barks to work

						if (!(localPlayer.bHDTP_JC && localPlayer.bHDTP_ALL == 0) && !(localPlayer.bHDTP_ALL == 1))	// Don't do this in HDTP
						{
							for(i = 0; i < 8; ++i)
								Invader.MultiSkins[i] = localPlayer.NewSkins[i];

							if (localPlayer.bOneOfUsRandomize)
							{
								RNG = Rand(12); // Trenchcoat

								if (RNG == 1)
								{
									Invader.MultiSkins[1] = Texture(DynamicLoadObject("DeusExCharacters.Skins.GordonQuickTex2", class'Texture'));
									Invader.MultiSkins[5] = Texture(DynamicLoadObject("DeusExCharacters.Skins.GordonQuickTex2", class'Texture'));
								}
								else if (RNG == 2)
								{
									Invader.MultiSkins[1] = Texture(DynamicLoadObject("DeusExCharacters.Skins.HarleyFilbenTex2", class'Texture'));
									Invader.MultiSkins[5] = Texture(DynamicLoadObject("DeusExCharacters.Skins.HarleyFilbenTex2", class'Texture'));
								}
								else if (RNG == 3)
								{
									Invader.MultiSkins[1] = Texture(DynamicLoadObject("DeusExCharacters.Skins.TobyAtanweTex2", class'Texture'));
									Invader.MultiSkins[5] = Texture(DynamicLoadObject("DeusExCharacters.Skins.TobyAtanweTex2", class'Texture'));
								}
								else if (RNG == 4)
								{
									Invader.MultiSkins[1] = Texture(DynamicLoadObject("DeusExCharacters.Skins.WaltonSimonsTex2", class'Texture'));
									Invader.MultiSkins[5] = Texture(DynamicLoadObject("DeusExCharacters.Skins.WaltonSimonsTex2", class'Texture'));
								}
								else if (RNG == 5)
								{
									Invader.MultiSkins[1] = Texture(DynamicLoadObject("DeusExCharacters.Skins.TrenchcoatTex1", class'Texture'));
									Invader.MultiSkins[5] = Texture(DynamicLoadObject("DeusExCharacters.Skins.TrenchcoatTex1", class'Texture'));
								}
								else if (RNG == 6)
								{
									Invader.MultiSkins[1] = Texture(DynamicLoadObject("DeusExCharacters.Skins.MaxChenTex2", class'Texture'));
									Invader.MultiSkins[5] = Texture(DynamicLoadObject("DeusExCharacters.Skins.MaxChenTex2", class'Texture'));
								}
								else if (RNG == 7)
								{
									Invader.MultiSkins[1] = Texture(DynamicLoadObject("DeusExCharacters.Skins.GilbertRentonTex2", class'Texture'));
									Invader.MultiSkins[5] = Texture(DynamicLoadObject("DeusExCharacters.Skins.GilbertRentonTex2", class'Texture'));
								}
								else if (RNG == 7)
								{
									Invader.MultiSkins[1] = Texture(DynamicLoadObject("DeusExCharacters.Skins.PaulDentonTex2", class'Texture'));
									Invader.MultiSkins[5] = Texture(DynamicLoadObject("DeusExCharacters.Skins.PaulDentonTex2", class'Texture'));
								}
								else if (RNG == 8)
								{
									Invader.MultiSkins[1] = Texture(DynamicLoadObject("DeusExCharacters.Skins.JosephManderleyTex2", class'Texture'));
									Invader.MultiSkins[5] = Texture(DynamicLoadObject("DeusExCharacters.Skins.JosephManderleyTex2", class'Texture'));
								}
								else if (RNG == 9)
								{
									Invader.MultiSkins[1] = Texture(DynamicLoadObject("DeusExCharacters.Skins.FordSchickTex2", class'Texture'));
									Invader.MultiSkins[5] = Texture(DynamicLoadObject("DeusExCharacters.Skins.FordSchickTex2", class'Texture'));
								}
								else if (RNG == 10)
								{
									Invader.MultiSkins[1] = Texture(DynamicLoadObject("DeusExCharacters.Skins.SmugglerTex2", class'Texture'));
									Invader.MultiSkins[5] = Texture(DynamicLoadObject("DeusExCharacters.Skins.SmugglerTex2", class'Texture'));
								}
								else if (RNG == 11)
								{
									Invader.MultiSkins[1] = Texture(DynamicLoadObject("DeusExCharacters.Skins.StantonDowdTex2", class'Texture'));
									Invader.MultiSkins[5] = Texture(DynamicLoadObject("DeusExCharacters.Skins.StantonDowdTex2", class'Texture'));
								}
								else if (RNG == 11)
								{
									Invader.MultiSkins[1] = Texture(DynamicLoadObject("DeusExCharacters.Skins.LabCoatTex1", class'Texture'));
									Invader.MultiSkins[5] = Texture(DynamicLoadObject("DeusExCharacters.Skins.LabCoatTex1", class'Texture'));
								}

								RNG = Rand(15); // Body

								if (RNG == 1)
								{
									if (localPlayer.PlayerSkin == 0 || localPlayer.PlayerSkin == 3) // Only show the bare chest texture when default or ginger
										Invader.MultiSkins[4] = Texture(DynamicLoadObject("DeusExCharacters.Skins.GordonQuickTex1", class'Texture'));
									else
										Invader.MultiSkins[4] = Texture(DynamicLoadObject("DeusExCharacters.Skins.JockTex1", class'Texture'));
								}
								else if (RNG == 2)
								{
									Invader.MultiSkins[4] = Texture(DynamicLoadObject("DeusExCharacters.Skins.JockTex1", class'Texture')); // Chest
									Invader.MultiSkins[2] = Texture(DynamicLoadObject("DeusExCharacters.Skins.JockTex3", class'Texture')); // Legs
								}
								else if (RNG == 3)
								{
									Invader.MultiSkins[4] = Texture(DynamicLoadObject("DeusExCharacters.Skins.WaltonSimonsTex1", class'Texture')); // Chest
								}
								else if (RNG == 4)
								{
									Invader.MultiSkins[4] = Texture(DynamicLoadObject("DeusExCharacters.Skins.GarySavageTex1", class'Texture')); // Chest
								}
								else if (RNG == 5)
								{
									Invader.MultiSkins[4] = Texture(DynamicLoadObject("DeusExCharacters.Skins.Female4Tex1", class'Texture')); // Chest
								}
								else if (RNG == 6)
								{
									Invader.MultiSkins[4] = Texture(DynamicLoadObject("DeusExCharacters.Skins.JuanLebedevTex1", class'Texture')); // Chest
								}
								else if (RNG == 7)
								{
									Invader.MultiSkins[4] = Texture(DynamicLoadObject("DeusExCharacters.Skins.ThugMaleTex1", class'Texture')); // Chest
									Invader.MultiSkins[2] = Texture(DynamicLoadObject("DeusExCharacters.Skins.ThugMaleTex3", class'Texture')); // Legs
								}
								else if (RNG == 8)
								{
									Invader.MultiSkins[2] = Texture(DynamicLoadObject("DeusExCharacters.Skins.GordonQuickTex3", class'Texture')); // Legs
								}
								else if (RNG == 9)
								{
									Invader.MultiSkins[4] = Texture(DynamicLoadObject("DeusExCharacters.Skins.TrenchShirtTex3", class'Texture'));
								}
								else if (RNG == 10)
								{
									Invader.MultiSkins[4] = Texture(DynamicLoadObject("DeusExCharacters.Skins.TrenchShirtTex2", class'Texture'));
								}
								else if (RNG == 11)
								{
									Invader.MultiSkins[4] = Texture(DynamicLoadObject("DeusExCharacters.Skins.TrenchShirtTex1", class'Texture'));
								}
								else if (RNG == 12)
								{
									Invader.MultiSkins[4] = Texture(DynamicLoadObject("DeusExCharacters.Skins.TriadRedArrowTex1", class'Texture'));
								}
								else if (RNG == 13)
								{
									Invader.MultiSkins[4] = Texture(DynamicLoadObject("DeusExCharacters.Skins.SmugglerTex1", class'Texture'));
								}
								else if (RNG == 14)
								{
									Invader.MultiSkins[4] = Texture(DynamicLoadObject("DeusExCharacters.Skins.StantonDowdTex1", class'Texture'));
								}

								RNG = Rand(6); // Frames

								if (RNG == 1)
								{
									Invader.MultiSkins[6] = Texture(DynamicLoadObject("DeusExCharacters.Skins.FramesTex5", class'Texture'));
								}
								else if (RNG == 2)
								{
									Invader.MultiSkins[6] = Texture(DynamicLoadObject("DeusExCharacters.Skins.FramesTex4", class'Texture'));
								}
								else if (RNG == 3)
								{
									Invader.MultiSkins[6] = Texture(DynamicLoadObject("DeusExCharacters.Skins.FramesTex3", class'Texture'));
								}
								else if (RNG == 4)
								{
									Invader.MultiSkins[6] = Texture(DynamicLoadObject("DeusExCharacters.Skins.FramesTex2", class'Texture'));
								}
								else if (RNG == 5)
								{
									Invader.MultiSkins[6] = Texture(DynamicLoadObject("DeusExCharacters.Skins.FramesTex1", class'Texture'));
								}

								RNG = Rand(7); // Lenses

								if (RNG == 1)
								{
									Invader.MultiSkins[7] = Texture(DynamicLoadObject("DeusExCharacters.Skins.LensesTex1", class'Texture'));
								}
								else if (RNG == 2)
								{
									Invader.MultiSkins[7] = Texture(DynamicLoadObject("DeusExCharacters.Skins.LensesTex2", class'Texture'));
								}
								else if (RNG == 3)
								{
									Invader.MultiSkins[7] = Texture(DynamicLoadObject("DeusExCharacters.Skins.LensesTex3", class'Texture'));
								}
								else if (RNG == 4)
								{
									Invader.MultiSkins[7] = Texture(DynamicLoadObject("DeusExCharacters.Skins.LensesTex4", class'Texture'));
								}
								else if (RNG == 5)
								{
									Invader.MultiSkins[7] = Texture(DynamicLoadObject("DeusExCharacters.Skins.LensesTex5", class'Texture'));
								}
								else if (RNG == 6)
								{
									Invader.MultiSkins[7] = Texture(DynamicLoadObject("DeusExCharacters.Skins.LensesTex6", class'Texture'));
								}
							}
						}
					}
					if (localPlayer.bQuietEnemies)
					{
						Invader.BarkBindName = "None";
						Invader.ConBindEvents();
					}
					if (localPlayer.bCloakedEnemies)
					{
						Invader.bHasCloak = true;
						Invader.CloakThreshold = 2048;
						Invader.MultiSkins[6] = Texture'BlackMaskTex';
						Invader.MultiSkins[7] = Texture'BlackMaskTex';
					}
					if (localPlayer.bRandomPawnFatness)
						Invader.Fatness = Rand(16) + 125;
					localPlayer.flagBase.SetBool(localPlayer.rootWindow.StringToName(GetLevelInfo().MapName $ '_SecretServiceSpawned') , True, True, 0);
					*/
					break;
				}
			}
		}
	}
}

function StartPoison( Pawn poisoner, int Damage )
{
	if (MelkZone(Region.Zone) == None)
		Super.StartPoison(poisoner, Damage);
}

function HighlightCenterObject()
{
	local Actor target, smallestTarget, FirstMover;
	local Vector HitLoc, HitNormal, StartTrace, EndTrace;
	local DeusExRootWindow root;
	local float minSize;
	local bool bFirstTarget;

	if (IsInState('Dying'))
		return;

	root = DeusExRootWindow(rootWindow);

	// only do the trace every tenth of a second
	if (FrobTime >= 0.1)
	{
		// figure out how far ahead we should trace
		StartTrace = Location;
		EndTrace = Location + (Vector(ViewRotation) * MaxFrobDistance);

		// adjust for the eye height
		StartTrace.Z += BaseEyeHeight;
		EndTrace.Z += BaseEyeHeight;

		smallestTarget = None;
		minSize = 99999;
		bFirstTarget = True;

		// find the object that we are looking at
		// make sure we don't select the object that we're carrying
		// use the last traced object as the target...this will handle
		// smaller items under larger items for example
		// ScriptedPawns always have precedence, though
		foreach TraceActors(class'Actor', target, HitLoc, HitNormal, EndTrace, StartTrace)
		{
			if ((Mover(Target) != None) && (bFirstTarget))
			{
				FirstMover = Target;
			}
			
			if (IsFrobbable(target) && (target != CarriedDecoration))
			{
				if (target.IsA('ScriptedPawn') && !target.IsA('UtilityBot'))
				{
					smallestTarget = target;
					break;
				}
				else if (target.IsA('Mover') && bFirstTarget)
				{
					smallestTarget = target;
					break;
				}
				else if (target.CollisionRadius < minSize)
				{
					minSize = target.CollisionRadius;
					smallestTarget = target;
					bFirstTarget = False;
				}
			}
		}
		FrobTarget = smallestTarget;
		LastMoverFrobTarget = Mover(FirstMover);
		
		// reset our frob timer
		FrobTime = 0;
	}
}

exec function Comparison()
{
	local vector vect;
	local rotator rot;
	local DeusExLevelInfo info;
	
	if (!bCheatsEnabled)
		return;

	info = GetLevelInfo();
	
	ghost();
	
	if(info.MapName ~= "24_SpaceStation04")
	{
		rot.pitch = 61000;
		rot.roll = 0;
		rot.yaw = -40040;
		
		vect.X = 744.648682;
		vect.Y = -854.400696;
		// vect.Z = 415.799988;
		vect.Z = 435.799988;
	}
	
	if(info.MapName ~= "24_SpaceStation02")
	{
		rot.pitch = 00000;
		rot.roll = 0;
		rot.yaw = 65714;
		
		if (bool(Rand(2)))
		{
		vect.X = 1325;
		vect.Y = -448;
		vect.Z = 62;
		}
		else
		{
			vect.X = -305;
			vect.Y = 127;
			vect.Z = 253;
		}
	}
	
	// if(info.MapName ~= "24_SpaceStation01")
	// {
		// rot.pitch = 63673;
		// rot.roll = 0;
		// rot.yaw = 140320;
		
		// vect.X = -365.295624;
		// vect.Y = -961.142395;
		// // vect.Z = 415.799988;
		// vect.Z = 78.505699;
	// }
	
	ViewRotation = rot;
	SetRotation(rot);
	SetLocation(vect);
	
	ShowHud(false);
	Invisible(true);
	// SShot();
}


event PlayerInput( float DeltaTime )
{
	if ( bShowMenu /*&& (myHud != None)*/ )
	{
		// if ( myHud.MainMenu != None )
			// myHud.MainMenu.MenuTick( DeltaTime );
		// clear inputs
		bEdgeForward = false;
		bEdgeBack = false;
		bEdgeLeft = false;
		bEdgeRight = false;
		bWasForward = false;
		bWasBack = false;
		bWasLeft = false;
		bWasRight = false;
		aStrafe = 0;
		aTurn = 0;
		aForward = 0;
		aLookUp = 0;
		return;
	}
	else
		Super.PlayerInput(deltatime);
}
/*
function TNMVerifyConsole(class<Console> ConsoleClass)
{
	Log( "(ConsoleClass="$ConsoleClass$",Player.Console.Class="$Player.Console.Class$")", 'VerifyConsole' );

	if (Player.Console==None || Player.Console.Class!=ConsoleClass)
		FailConsoleCheck();
}

//-------------------------------------------------------------------------------------------------
// VerifyRootWindow()
//
// Verifies that rootwindow class matches the servers setting.
//-------------------------------------------------------------------------------------------------

function TNMVerifyRootWindow(Class<RootWindow> RootWindowClass)
{
	Log( "(RootWindowClass="$RootWindowClass$"RootWindow.Class="$RootWindow.Class$")", 'VerifyRootWindow' );

	if (RootWindow==None || RootWindow.Class!=RootWindowClass)
		FailRootWindowCheck();
}*/

exec function CitadelTest()
{
	local WarpZoneInfo w;
	local int i;
	
	i = Rand(2);
	i += 65;
	
	ForEach AllActors(class'WarpZoneInfo', W)
	{
		if (W.ThisTag == 'Citadel1')
		{
			W.OtherSideURL = "Citadel1" $ Chr(i);
			W.ForceGenerate();
		}
		if (W.ThisTag == 'Citadel5')
		{
			W.OtherSideURL = "Citadel5" $ Chr(i);
			W.ForceGenerate();
		}
	}
	
	i = Rand(4);
	// if (i == 2) // To cut
		// i++;
	i += 65;
	
	ForEach AllActors(class'WarpZoneInfo', W)
	{
		if (W.ThisTag == 'Citadel2')
		{
			W.OtherSideURL = "Citadel2" $ Chr(i);
			W.ForceGenerate();
		}
		if (W.ThisTag == 'Citadel3')
		{
			W.OtherSideURL = "Citadel3" $ Chr(i);
			W.ForceGenerate();
		}
	}
	
	i = 65;
	if (FRand() >= 0.95)
		i++;
	ForEach AllActors(class'WarpZoneInfo', W)
	{
		if (W.ThisTag == 'Citadel4')
		{
			W.OtherSideURL = "Citadel4" $ Chr(i);
			W.ForceGenerate();
		}
	}
	
	/*
	ForEach AllActors(class'WarpZoneInfo', W)
	{
		
		if (W.Tag == 'CitadelEntrance')
		{
			W.OtherSideURL = "CitadelEntrance" $ Chr(i);
			W.ForceGenerate();
		}
		else if (W.Tag == 'CitadelExit')
		{
			W.OtherSideURL = "CitadelExit" $ Chr(i);
			W.ForceGenerate();
		}
	}*/
}

function Falling()
{
	local float boost;
    PlayInAir();
	
	// Lollerskate ramps code
	// if (bSkating)
	// {
		// boost = 1 - lastStepNormal.Z;
		// Velocity.Z += (boost * 5.0) * JumpZ;
	// }
}

event WalkTexture( texture Texture, vector StepLocation, vector StepNormal )
{
	if(StepNormal.Z > 0 && StepNormal.Z < 1 && bSkating)
	{
		// ClientMessage(1 - StepNormal.Z);
		lastStepNormal = StepNormal;
	}
	else if ((StepNormal.Z <= 0 || StepNormal.Z >= 1) && bSkating)
	{
		lastStepNormal.Z = 0;
	}
}

exec function GlobalFacelift(bool bOn)
{
    local TNMWeapon generic;

    foreach AllActors(class'TNMWeapon', generic)
    {
        generic.Facelift(bOn);
    }
}
/*
function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
    local vector View,HitLocation,HitNormal;
    local float ViewDist;

    // CameraRotation = ViewRotation;
    // View = vect(1,0,0) >> CameraRotation;
    // if ( Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
        // ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
    // else
        // ViewDist = Dist;
    // CameraLocation -= (ViewDist - 30) * View;

    // CameraRotation = ViewRotation;
    CameraRotation = Rot(0,0,0);
    View = vect(1,0,0) >> CameraRotation;
    if ( Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
        ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
    else
        ViewDist = Dist;
    CameraLocation -= (ViewDist - 30) * View;
    CameraLocation.Z += CollisionHeight;
}
*/
/*
event Bump( Actor Other )
{
	if (Mover(Other) != None)
	{
		if (Velocity.Z <= 0 && Location.Z > Other.Location.Z)
			Other.SetCollision( True, True, True );
		else
			Other.SetCollision( True, False, False );
	}
	log("Bump"@Other);
}

event Touch( Actor Other )
{
	if (Mover(Other) != None)
	{
		if (Velocity.Z <= 0 && Location.Z > Other.Location.Z)
			Other.SetCollision( True, True, True );
		else
			Other.SetCollision( True, False, False );
	}
	log("Touch"@Other);
}*/

function Touch( actor Other )
{
	if (bplatformer && TNMWeapon(Other) != None && Other.Owner == None) 
	{
		FrobTarget = Other;
		if (HandleItemPickup(TNMWeapon(Other)))
		{
			if (FindInventorySlot(TNMWeapon(Other)))
			{
				TNMWeapon(Other).RecoilStrength = 0;
				TNMWeapon(Other).Mass = 0;
				TNMWeapon(Other).reloadTime = 0;
				PutInHand(TNMWeapon(Other));
				if (rh != None)
				{
					if (TNMWeapon(Other).AmmoType != None && TNMWeapon(Other).AmmoType != Class'AmmoNone' && TNMWeapon(Other).AmmoName != Class'AmmoNone')
						rh.ShowRadishWeaponMessage(TNMWeapon(Other).ItemName, string(TNMWeapon(Other).AmmoType.AmmoAmount));
					else
						rh.ShowRadishWeaponMessage(TNMWeapon(Other).ItemName, "INF");
				}
			}
		}
	}
	else if (bplatformer && Ammo(Other) != None && Other.Owner == None) 
	{
		FrobTarget = Other;
		if (HandleItemPickup(Ammo(Other)))
		{
			if (FindInventorySlot(Ammo(Other)))
			{
				if (rh != None)
				{
					rh.ShowRadishWeaponMessage(Ammo(Other).ItemName, string(Ammo(FindInventoryType(Other.Class)).AmmoAmount));
				}
			}
		}
	}
	Super.Touch(Other);
}

exec function LoadGame(int saveIndex)
{
	class'tnmSoundModifier'.static.On();
	class'tnmSoundModifier'.static.ResetVolumeMultiplier();
	class'tnmSoundModifier'.static.Off();
		
	Super.LoadGame(saveIndex);
}

// Navigation Aids
exec function ShowPath()
{
    //find next path to remembered spot
    local Actor node;
    node = FindPathTo(Destination);
    if (node != None)
    {
        ClientMessage("found path");
        Spawn(class 'TNMWayBeacon', self, '', node.location);
    }
    else
        ClientMessage("didn't find path");
}

exec function Jukebox()
{	
    local DeusExRootWindow root;
	
    // if (!bCheatsEnabled)
        // return;
		
    root = DeusExRootWindow(rootWindow);
	
    if (root != None)
    {
        // if ( root.IsKeyDown( IK_Alt ) || root.IsKeyDown( IK_Shift ) || root.IsKeyDown( IK_Ctrl ))
            // return;

        root.InvokeUIScreen(Class'TNM.tnmJukeboxWindow', True);
    }
}

function RestoreScopeView()
{
    if (inHand != None)
    {
        if (inHand.IsA('Binoculars') && (inHand.bActive))
            Binoculars(inHand).RefreshScopeDisplay(Self, True);
        if (inHand.IsA('TNMBinoculars') && (inHand.bActive))
            TNMItems(inHand).RefreshScopeDisplay(Self, True);
        else if ((DeusExWeapon(inHand) != None) && (DeusExWeapon(inHand).bZoomed))
            DeusExWeapon(inHand).RefreshScopeDisplay(Self, True, True);
    }
}

function ShowCredits(optional bool bLoadIntro)
{
    local DeusExRootWindow root;
    local CreditsWindow winCredits;

    root = DeusExRootWindow(rootWindow);

    if (root != None)
    {
        // Show the credits screen and force the game not to pause
        // if we're showing the credits after the endgame
        winCredits = CreditsWindow(root.InvokeMenuScreen(Class'tnmcredits', bLoadIntro));
        winCredits.SetLoadIntro(bLoadIntro);
    }
}

exec function Legend()
{
    if (!bCheatsEnabled)
        return;

    InvokeUIScreen(Class'TNM.TNMBehindTheCurtain');
}

event PreClientTravel()
{
	local Inventory item, nextItem, lastItem;

	if (bPlatformer && Inventory != None)
	{
		item = Inventory;
		nextItem = item.Inventory;
		lastItem = item;

		do
		{
			if (!item.IsA('weaponfists') && (item != None) && item.bDisplayableInv || item.IsA('Ammo'))
			{
				// make sure everything is turned off
				if (item.IsA('DeusExWeapon'))
				{
					DeusExWeapon(item).ScopeOff();
					DeusExWeapon(item).LaserOff();
				}
				if (item.IsA('DeusExPickup'))
				{
					if (DeusExPickup(item).bActive)
						DeusExPickup(item).Activate();
				}

   			if (item.IsA('ChargedPickup'))
					RemoveChargedDisplay(ChargedPickup(item));

				DeleteInventory(item);
				item.Destroy();
				item = Inventory;
			}
			else
				item = nextItem;

			if (item != None)
				nextItem = item.Inventory;
		}
		until ((item == None) || (item == lastItem));
	}
	
	if (Level.NetMode == NM_Client && rootWindow != None)
		rootWindow.Destroy();

	Super.PreClientTravel();
}

state Interpolating
{
    // check to see if we are done interpolating, if so, then travel to the next map
    event InterpolateEnd(Actor Other)
    {
		local InterpolationPoint i;
        if (InterpolationPoint(Other).bEndOfPath)
        {
			// Radish Menu
			if (InterpolationPoint(other).Tag == 'IntroCam')
			{
				// Mega hack
				SetCollisionSize( 0, 0 ); // InterpolationPoint itself causes us to collide with world, which can push us out of the ground
				SetPhysics(PHYS_Interpolating); // Also makes us fall to the ground, reverse that
			}
			else
				Super.InterpolateEnd(Other);
		}
	}

    exec function Fire(optional float F)
    {
        local DeusExLevelInfo info;

        // only bring up the menu if we're not in a mission outro
        info = GetLevelInfo();
        if ((info != None) && Caps(info.mapName) == "RADISHMENU")
			InvokeUIScreen(Class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.tnmRadishMenu", class'Class')) );
		else
            Super.Fire(F);
    }
	
	simulated exec function ShowMainMenu()
	{
        local DeusExLevelInfo info;

        // only bring up the menu if we're not in a mission outro
        info = GetLevelInfo();
		if ((info != None) && Caps(info.mapName) == "RADISHMENU")
			InvokeUIScreen(Class<DeusExBaseWindow>(DynamicLoadObject("TNMGUI.tnmRadishMenu", class'Class')) );
		else
			Global.ShowMainMenu();
	}
}

// ============================================================================
// CO-OP QOL SYSTEMS: Pinging, Visual-Only Character Models, Medkit Revival,
// and Proximity Inventory Trading
// ============================================================================

simulated function String GetLocalCoopPlayerName()
{
	local String savedName;

	savedName = class'CoopLocalPrefs'.static.GetLocalPlayerName(GetDefaultURL("Name"));
	if (savedName != "")
		return savedName;
	if (coopPlayerName != "" && Caps(coopPlayerName) != "HOST" && Caps(coopPlayerName) != "PARTNER")
		return coopPlayerName;
	return "Player";
}

simulated function String GetCoopPlayerName()
{
	local String localSaved;

	if (Level.NetMode == NM_Standalone)
		return GetLocalCoopPlayerName();
	if (coopPlayerName != "")
		return coopPlayerName;
	if (Viewport(Player) != None)
	{
		localSaved = class'CoopLocalPrefs'.static.GetLocalPlayerName(GetDefaultURL("Name"));
		if (localSaved != "")
			return localSaved;
	}
	if (PlayerReplicationInfo != None && PlayerReplicationInfo.PlayerName != "" && PlayerReplicationInfo.PlayerName != "Player")
		return PlayerReplicationInfo.PlayerName;
	if (Role == ROLE_Authority && Viewport(Player) != None)
		return "Host";
	return "Partner";
}

simulated function String GetCoopLastServerIP()
{
	return class'CoopLocalPrefs'.static.GetLastServerIP(default.coopLastServerIP);
}

simulated function SetCoopLastServerIP(String NewIP)
{
	if (NewIP == "")
		return;
	class'CoopLocalPrefs'.static.SetLastServerIP(NewIP);
	default.coopLastServerIP = NewIP;
	coopLastServerIP = NewIP;
	SaveConfig();
}

simulated function InjectCoopMainMenuButton(MenuUIMenuWindow menuWin)
{
	local Window w;
	local CoopMainMenuHookWindow hookWin;
	local int y8, y9, mpY;

	if (menuWin == None || menuWin.winClient == None)
		return;
	if (menuWin.winButtons[0] == None || menuWin.winButtons[8] == None)
		return;

	for (w = menuWin.winClient.GetTopChild(); w != None; w = w.GetLowerSibling())
	{
		if (CoopMainMenuHookWindow(w) != None)
			return;
	}

	y8 = menuWin.buttonDefaults[8].y;
	y9 = menuWin.buttonDefaults[9].y;
	if (y8 <= 0)
		y8 = 295;
	if (y9 <= y8)
		y9 = 353;

	mpY = y8 + ((y9 - y8) / 2) + 1;
	if (menuWin.winButtons[9] != None)
		menuWin.winButtons[9].SetPos(menuWin.buttonXPos, y9 + 1);

	hookWin = CoopMainMenuHookWindow(menuWin.winClient.NewChild(Class'CoopMainMenuHookWindow'));
	if (hookWin != None)
	{
		hookWin.SetPos(menuWin.buttonXPos, mpY);
		hookWin.SetSize(menuWin.buttonWidth, 27);
		hookWin.SetupButton(menuWin.winButtons[0].Class, menuWin.buttonWidth);
	}
}

simulated function SetCoopPlayerName(String NewName)
{
	local String cleanName;

	cleanName = class'CoopLocalPrefs'.static.SanitizePlayerName(NewName);
	if (cleanName == "")
		return;
	if (Viewport(Player) != None)
	{
		class'CoopLocalPrefs'.static.SetLocalPlayerName(cleanName);
		UpdateURL("Name", class'CoopLocalPrefs'.static.EncodeURLName(cleanName), True);
	}
	coopPlayerName = cleanName;
	FamiliarName = cleanName;
	UnfamiliarName = cleanName;
	if (PlayerReplicationInfo != None)
		PlayerReplicationInfo.PlayerName = cleanName;
	if (Role < ROLE_Authority)
		ServerSetCoopName(cleanName);
	else if (tnmGameInfo(Level.Game) != None && Level.NetMode != NM_Standalone && (!bCoopNamedProfileRestored || Caps(lastRestoredProfileName) != Caps(cleanName)))
		tnmGameInfo(Level.Game).RestoreNamedCoopProfile(Self, cleanName);
}

function ServerSetCoopName(String NewName)
{
	local String cleanName;

	cleanName = class'CoopLocalPrefs'.static.SanitizePlayerName(NewName);
	if (cleanName == "")
		return;
	coopPlayerName = cleanName;
	FamiliarName = cleanName;
	UnfamiliarName = cleanName;
	if (PlayerReplicationInfo != None)
		PlayerReplicationInfo.PlayerName = cleanName;
	if (tnmGameInfo(Level.Game) != None && Level.NetMode != NM_Standalone && (!bCoopNamedProfileRestored || Caps(lastRestoredProfileName) != Caps(cleanName)))
		tnmGameInfo(Level.Game).RestoreNamedCoopProfile(Self, cleanName);
}

simulated function EnsureCoopHUDWindows()
{
	local DeusExRootWindow root;
	local Window w;
	local CoopPingDisplayWindow pingWin;
	local CoopChatDisplayWindow chatWin;
	local CoopMainMenuHookWindow rootHookWin;
	local PersonaScreenInventory invWin;
	local CoopTradeMenuWindow tradeWin;
	local String curBindH, curBindV;

	if (!bCoopPingBindChecked && Viewport(Player) != None)
	{
		bCoopPingBindChecked = True;
		curBindH = ConsoleCommand("KEYBINDING H");
		if (curBindH == "")
			ConsoleCommand("SET INPUT H CoopPing");
		curBindV = ConsoleCommand("KEYBINDING V");
		if (curBindV == "" || Caps(curBindV) == "LOOKDOWN")
			ConsoleCommand("SET INPUT V CoopPing");

		if (default.coopCharacterModel > 0)
			SetCoopModelSelection(default.coopCharacterModel);
		if (class'CoopLocalPrefs'.static.GetLocalPlayerName(GetDefaultURL("Name")) != "")
			SetCoopPlayerName(class'CoopLocalPrefs'.static.GetLocalPlayerName(GetDefaultURL("Name")));
		if (default.bCoopYuukaHat)
			SetCoopYuukaHat(True);
	}

	if (Role == ROLE_Authority)
		UpdateYuukaHatActor();

	root = DeusExRootWindow(rootWindow);
	if (root == None)
		return;

	for (w = root.GetTopChild(); w != None; w = w.GetLowerSibling())
	{
		if (CoopMainMenuHookWindow(w) != None && CoopMainMenuHookWindow(w).bIsRootWatcher)
		{
			rootHookWin = CoopMainMenuHookWindow(w);
			break;
		}
	}
	if (rootHookWin == None)
	{
		rootHookWin = CoopMainMenuHookWindow(root.NewChild(Class'CoopMainMenuHookWindow'));
		if (rootHookWin != None)
		{
			rootHookWin.SetupAsRootWatcher();
			rootHookWin.Lower();
		}
	}

	if (root.hud != None)
	{
		for (w = root.hud.GetTopChild(); w != None; w = w.GetLowerSibling())
		{
			if (CoopPingDisplayWindow(w) != None)
				pingWin = CoopPingDisplayWindow(w);
			else if (CoopChatDisplayWindow(w) != None)
				chatWin = CoopChatDisplayWindow(w);
		}
		if (pingWin == None)
		{
			pingWin = CoopPingDisplayWindow(root.hud.NewChild(Class'CoopPingDisplayWindow'));
			if (pingWin != None)
				pingWin.Lower();
		}
		if (chatWin == None)
		{
			chatWin = CoopChatDisplayWindow(root.hud.NewChild(Class'CoopChatDisplayWindow'));
			if (chatWin != None)
				chatWin.Raise();
		}
	}

	invWin = PersonaScreenInventory(root.GetTopWindow());
	if (invWin != None && invWin.winClient != None)
	{
		for (w = invWin.winClient.GetTopChild(); w != None; w = w.GetLowerSibling())
		{
			if (CoopTradeMenuWindow(w) != None)
			{
				tradeWin = CoopTradeMenuWindow(w);
				break;
			}
		}
		if (tradeWin == None)
		{
			tradeWin = CoopTradeMenuWindow(invWin.winClient.NewChild(Class'CoopTradeMenuWindow'));
			if (tradeWin != None)
				tradeWin.Raise();
		}
	}

	if (MenuUIMenuWindow(root.GetTopWindow()) != None && root.GetTopWindow().IsA('tnmMenuMain'))
	{
		InjectCoopMainMenuButton(MenuUIMenuWindow(root.GetTopWindow()));
	}
}

// ----------------------------------------------------------------------------
// 1. Pinging System (CoopPing)
// ----------------------------------------------------------------------------
exec function CoopPing()
{
	local Vector StartTrace;

	StartTrace = Location;
	StartTrace.Z += BaseEyeHeight;
	ServerCoopPing(StartTrace, ViewRotation, FrobTarget);
}

function ServerCoopPing(Vector AimStart, Rotator AimRot, optional Actor ClientFrobTarget)
{
	local Vector EndTrace, HitLocation, HitNormal, TraceLoc, TraceNorm;
	local Actor HitActor, TraceAct, BestItemActor;
	local float BestItemDist, CurDist;
	local String LabelStr;
	local byte PingCategory;

	EndTrace = AimStart + vector(AimRot) * 16000.0;
	HitActor = Trace(HitLocation, HitNormal, EndTrace, AimStart, True);
	if (HitActor == None)
		HitLocation = EndTrace;

	// If the player is highlighting a frobbable item/door/NPC right in front of them, prefer it!
	if (ClientFrobTarget != None && !ClientFrobTarget.bDeleteMe && VSize(ClientFrobTarget.Location - AimStart) <= 300.0)
	{
		HitActor = ClientFrobTarget;
		HitLocation = ClientFrobTarget.Location;
	}
	else if (HitActor == None || HitActor == Level || (HitActor.IsA('Brush') && Mover(HitActor) == None))
	{
		// Standard Trace() skips Inventory pickups because they have bProjTarget=False & bBlockActors=False.
		// Scan along the ray up to the wall HitLocation with a small 10-UU extent to catch items (Soda, Medkit, Keys, etc.)!
		BestItemDist = VSize(HitLocation - AimStart) + 16.0;
		foreach TraceActors(class'Actor', TraceAct, TraceLoc, TraceNorm, HitLocation, AimStart, vect(10, 10, 10))
		{
			if (TraceAct != Self && !TraceAct.bHidden && !TraceAct.bDeleteMe)
			{
				if (Inventory(TraceAct) != None || DeusExDecoration(TraceAct) != None || ScriptedPawn(TraceAct) != None || Trestkon(TraceAct) != None || DeusExCarcass(TraceAct) != None)
				{
					CurDist = VSize(TraceLoc - AimStart);
					if (CurDist < BestItemDist)
					{
						BestItemDist = CurDist;
						BestItemActor = TraceAct;
					}
				}
			}
		}
		if (BestItemActor != None)
		{
			HitActor = BestItemActor;
			HitLocation = BestItemActor.Location;
		}
	}

	if (HitActor == None)
	{
		HitLocation = EndTrace;
		LabelStr = "Waypoint";
		PingCategory = 0;
	}
	else if (Trestkon(HitActor) != None)
	{
		LabelStr = Trestkon(HitActor).GetCoopPlayerName();
		PingCategory = 3;
	}
	else if (DeusExCarcass(HitActor) != None && DeusExCarcass(HitActor).bPlayerCarcass)
	{
		LabelStr = DeusExCarcass(HitActor).itemName;
		PingCategory = 3;
	}
	else if (ScriptedPawn(HitActor) != None)
	{
		if (HitActor.BindName != "" && ScriptedPawn(HitActor).FamiliarName != "")
			LabelStr = ScriptedPawn(HitActor).FamiliarName;
		else if (ScriptedPawn(HitActor).UnfamiliarName != "")
			LabelStr = ScriptedPawn(HitActor).UnfamiliarName;
		else
			LabelStr = String(HitActor.Class.Name);
		PingCategory = 1;
	}
	else if (DeusExCarcass(HitActor) != None)
	{
		LabelStr = DeusExCarcass(HitActor).itemName;
		if (LabelStr == "")
			LabelStr = "Body";
		PingCategory = 2;
	}
	else if (Inventory(HitActor) != None)
	{
		LabelStr = Inventory(HitActor).itemName;
		if (LabelStr == "")
			LabelStr = String(HitActor.Class.Name);
		PingCategory = 2;
	}
	else if (DeusExDecoration(HitActor) != None)
	{
		LabelStr = DeusExDecoration(HitActor).itemName;
		if (LabelStr == "")
			LabelStr = String(HitActor.Class.Name);
		PingCategory = 2;
	}
	else if (DeusExMover(HitActor) != None)
	{
		if (DeusExMover(HitActor).bLocked)
			LabelStr = "Locked Door";
		else
			LabelStr = "Door";
		PingCategory = 2;
	}
	else if (Mover(HitActor) != None)
	{
		LabelStr = "Door / Mover";
		PingCategory = 2;
	}
	else if (HitActor == Level || HitActor.IsA('Brush'))
	{
		LabelStr = "Location";
		PingCategory = 0;
	}
	else
	{
		LabelStr = "Waypoint";
		PingCategory = 0;
	}

	// Offset slightly out from surface normal so marker isn't buried inside walls/doors
	if (HitActor == Level || (HitActor != None && HitActor.IsA('Brush')))
		HitLocation = HitLocation + HitNormal * 8.0;

	BroadcastCoopPing(HitLocation, HitActor, LabelStr, GetCoopPlayerName(), PingCategory);
}

function BroadcastCoopPing(Vector PingLoc, Actor PingActor, String PingLabel, String SenderName, byte PingType)
{
	local Trestkon P;
	local Actor TrackedActor;

	// Only attach dynamic tracking if it's a movable actor (Pawn, Inventory, Carcass, Decoration)
	if (PingActor != None && PingActor != Level && !PingActor.IsA('Brush') && !PingActor.IsA('Mover'))
		TrackedActor = PingActor;

	// Spawn 3D Yuuka Plush Ping Beacon at PingLoc for 7 seconds
	if (activePingMarker != None && !activePingMarker.bDeleteMe)
		activePingMarker.Destroy();
	activePingMarker = Spawn(class'YuukaPingMarker', Self, , PingLoc, Rotation);

	foreach AllActors(class'Trestkon', P)
	{
		P.ClientReceiveCoopPing(PingLoc, TrackedActor, PingLabel, SenderName, PingType);
	}
}

// ----------------------------------------------------------------------------
// Yuuka Plush Head Companion Hat
// ----------------------------------------------------------------------------
exec function ToggleYuukaHat()
{
	SetCoopYuukaHat(!bCoopYuukaHat);
	if (bCoopYuukaHat)
		ClientMessage("Yuuka Head Companion: ON (Visible in 3rd-Person & to Co-op Partner)");
	else
		ClientMessage("Yuuka Head Companion: OFF");
}

simulated function SetCoopYuukaHat(bool bEnable)
{
	default.bCoopYuukaHat = bEnable;
	bCoopYuukaHat = bEnable;
	SaveConfig();
	if (Role < ROLE_Authority)
		ServerSetYuukaHat(bEnable);
	else
		UpdateYuukaHatActor();
}

function ServerSetYuukaHat(bool bEnable)
{
	bCoopYuukaHat = bEnable;
	UpdateYuukaHatActor();
}

function UpdateYuukaHatActor()
{
	if (bCoopYuukaHat)
	{
		if (activeYuukaHat == None || activeYuukaHat.bDeleteMe)
			activeYuukaHat = Spawn(class'YuukaHeadCompanion', Self, , Location + vect(0, 0, 48), Rotation);
	}
	else
	{
		if (activeYuukaHat != None && !activeYuukaHat.bDeleteMe)
		{
			activeYuukaHat.Destroy();
			activeYuukaHat = None;
		}
	}
}

simulated function ClientReceiveCoopPing(Vector PingLoc, Actor PingActor, String PingLabel, String SenderName, byte PingType)
{
	activePingLoc = PingLoc;
	activePingActor = PingActor;
	activePingLabel = PingLabel;
	activePingOwnerName = SenderName;
	activePingType = PingType;
	activePingTime = Level.TimeSeconds;
	activePingDuration = 7.0;

	PlaySound(Sound'TNM.CoopPingSound', SLOT_None, 0.60, , 512.0);
}

// ----------------------------------------------------------------------------
// 2. Visual-Only Character Model Selector (Never modifies CoatType/PlayerSkin/Flags)
// ----------------------------------------------------------------------------
simulated function SaveCoopCustomPreset(int PackedPreset)
{
	default.coopSavedCustomPreset = PackedPreset;
	coopSavedCustomPreset = PackedPreset;
	SaveConfig();
}

simulated function SetCoopModelSelection(int NewModel)
{
	default.coopCharacterModel = NewModel;
	coopCharacterModel = NewModel;
	SaveConfig();
	ApplyCoopModel(NewModel);
	if (Role < ROLE_Authority)
		ServerSetCoopModel(NewModel);
}

function ServerSetCoopModel(int NewModel)
{
	coopCharacterModel = NewModel;
	ApplyCoopModel(NewModel);
}

function bool HasTwoHandedWeapon()
{
	if ((coopCharacterModel & 134217728) != 0 && (coopCharacterModel & 7) <= 3)
		return False;
	if (coopCharacterModel == 11)
		return False;
	return Super.HasTwoHandedWeapon();
}

simulated function Texture LoadCoopSkinTex(String TexPath)
{
	if (TexPath == "")
		return Texture'DeusExItems.Skins.PinkMaskTex';
	return Texture(DynamicLoadObject(TexPath, class'Texture'));
}

simulated function int PackCustomCoopSkin(int BodyIdx, int HeadIdx, int TopIdx, int BottomIdx, int LegsIdx, int GlassesIdx)
{
	return 134217728
		| (Clamp(BodyIdx, 0, 5) & 7)
		| ((Clamp(HeadIdx, 0, 31) & 31) << 3)
		| ((Clamp(TopIdx, 0, 31) & 31) << 8)
		| ((Clamp(BottomIdx, 0, 31) & 31) << 13)
		| ((Clamp(LegsIdx, 0, 31) & 31) << 18)
		| ((Clamp(GlassesIdx, 0, 15) & 15) << 23);
}

simulated function UnpackCustomCoopSkin(int PackedVal, out int BodyIdx, out int HeadIdx, out int TopIdx, out int BottomIdx, out int LegsIdx, out int GlassesIdx)
{
	BodyIdx    = PackedVal & 7;
	HeadIdx    = (PackedVal >> 3) & 31;
	TopIdx     = (PackedVal >> 8) & 31;
	BottomIdx  = (PackedVal >> 13) & 31;
	LegsIdx    = (PackedVal >> 18) & 31;
	GlassesIdx = (PackedVal >> 23) & 15;
}

simulated function GetCoopGlassesTex(int GlassesIdx, out Texture FrameTex, out Texture LensTex)
{
	switch (GlassesIdx)
	{
		case 1:
			FrameTex = LoadCoopSkinTex("DeusExCharacters.Skins.FramesTex1");
			LensTex  = LoadCoopSkinTex("DeusExCharacters.Skins.LensesTex2");
			break;
		case 2:
			FrameTex = LoadCoopSkinTex("DeusExCharacters.Skins.FramesTex2");
			LensTex  = LoadCoopSkinTex("DeusExCharacters.Skins.LensesTex3");
			break;
		case 3:
			FrameTex = LoadCoopSkinTex("DeusExCharacters.Skins.FramesTex4");
			LensTex  = LoadCoopSkinTex("DeusExCharacters.Skins.LensesTex5");
			break;
		case 4:
			FrameTex = LoadCoopSkinTex("DeusExCharacters.Skins.FramesTex5");
			LensTex  = LoadCoopSkinTex("DeusExCharacters.Skins.LensesTex1");
			break;
		case 5:
			FrameTex = Texture'tnm.Skins.FramesTex6';
			LensTex  = Texture'tnm.Skins.LensesTex8';
			break;
		case 6:
			FrameTex = LoadCoopSkinTex("TNMCharacters.Skins.WC_FramesTex1");
			LensTex  = LoadCoopSkinTex("DeusExCharacters.Skins.LensesTex4");
			break;
		default:
			FrameTex = Texture'DeusExItems.Skins.GrayMaskTex';
			LensTex  = Texture'DeusExItems.Skins.BlackMaskTex';
			break;
	}
}

simulated function ApplyCustomCoopSkin(int BodyIdx, int HeadIdx, int TopIdx, int BottomIdx, int LegsIdx, int GlassesIdx)
{
	local int i;
	local String headStr, topStr, botStr, legsStr;
	local Texture headTex, topTex, botTex, legsTex, frameTex, lensTex;

	Texture = Default.Texture;
	for (i = 0; i < 8; i++)
		MultiSkins[i] = Texture'DeusExItems.Skins.PinkMaskTex';

	GetCoopGlassesTex(GlassesIdx, frameTex, lensTex);

	// 0: Female - Jacket & Skirt (GFM_Dress) [Screenshot 1 style - separate Top, Jacket+Skirt, and Pantyhose/Tights!]
	if (BodyIdx == 0)
	{
		Mesh = Mesh(DynamicLoadObject("DeusExCharacters.GFM_Dress", class'Mesh'));
		switch (HeadIdx)
		{
			case 0:  headStr = "DeusExCharacters.Skins.SecretaryTex0"; break;
			case 1:  headStr = "DeusExCharacters.Skins.Hooker2Tex0"; break;
			case 2:  headStr = "DeusExCharacters.Skins.SandraRentonTex0"; break;
			case 3:  headStr = "DeusExCharacters.Skins.NurseTex0"; break;
			case 4:  headStr = "DeusExCharacters.Skins.Female1Tex0"; break;
			case 5:  headStr = "DeusExCharacters.Skins.Female2Tex0"; break;
			case 6:  headStr = "DeusExCharacters.Skins.Businesswoman1Tex0"; break;
			case 7:  headStr = "DeusExCharacters.Skins.RachelMeadTex0"; break;
			case 8:  headStr = "DeusExCharacters.Skins.SarahMeadTex0"; break;
			case 9:  headStr = "DeusExCharacters.Skins.NicoletteDuClareTex0"; break;
			case 10: headStr = "TNMCharacters.Skins.KylieTex0"; break;
			case 11: headStr = "TNMCharacters.Skins.JackieTex0"; break;
			case 12: headStr = "TNMCharacters.Skins.GoatFemaleHead1"; break;
			default: headStr = "TNMCharacters.Skins.LlamaFemaleHead1"; break;
		}
		switch (TopIdx)
		{
			case 0:  topStr = "DeusExCharacters.Skins.LowerClassFemaleTex1"; break;
			case 1:  topStr = "TNMCharacters.Skins.GP_ShirtFem01"; break;
			case 2:  topStr = "TNMCharacters.Skins.GP_ShirtFem02"; break;
			case 3:  topStr = "TNMCharacters.Skins.GP_ShirtFem03"; break;
			case 4:  topStr = "TNMCharacters.Skins.GP_ShirtFem04"; break;
			case 5:  topStr = "TNMCharacters.Skins.GP_ShirtFem05"; break;
			case 6:  topStr = "TNMCharacters.Skins.N00BzShirtFemale"; break;
			case 7:  topStr = "DeusExCharacters.Skins.Female1Tex1"; break;
			case 8:  topStr = "DeusExCharacters.Skins.Hooker1Tex3"; break;
			case 9:  topStr = "DeusExCharacters.Skins.Hooker2Tex3"; break;
			case 10: topStr = "DeusExCharacters.Skins.SarahMeadTex1"; break;
			default: topStr = "DeusExCharacters.Skins.NicoletteDuClareTex1"; break;
		}
		switch (BottomIdx)
		{
			case 0:  botStr = "TNMCharacters.Skins.GP_Skirt02"; break;
			case 1:  botStr = "TNMCharacters.Skins.GP_Skirt01"; break;
			case 2:  botStr = "TNMCharacters.Skins.GP_Skirt03"; break;
			case 3:  botStr = "TNMCharacters.Skins.GP_Skirt04"; break;
			case 4:  botStr = "DeusExCharacters.Skins.Hooker1Tex2"; break;
			case 5:  botStr = "DeusExCharacters.Skins.Hooker2Tex2"; break;
			case 6:  botStr = "DeusExCharacters.Skins.SarahMeadTex2"; break;
			default: botStr = "DeusExCharacters.Skins.NicoletteDuClareTex2"; break;
		}
		switch (LegsIdx)
		{
			case 0:  legsStr = "DeusExCharacters.Skins.Female3Tex2"; break;
			case 1:  legsStr = "DeusExCharacters.Skins.LegsTex1"; break;
			case 2:  legsStr = "DeusExCharacters.Skins.LegsTex2"; break;
			case 3:  legsStr = "TNMCharacters.Skins.GP_Legs01"; break;
			case 4:  legsStr = "DeusExCharacters.Skins.Female2Tex1"; break;
			case 5:  legsStr = "DeusExCharacters.Skins.Businesswoman1Tex2"; break;
			case 6:  legsStr = "DeusExCharacters.Skins.RachelMeadTex2"; break;
			case 7:  legsStr = "DeusExCharacters.Skins.Hooker1Tex1"; break;
			case 8:  legsStr = "DeusExCharacters.Skins.Hooker2Tex1"; break;
			default: legsStr = "DeusExCharacters.Skins.SarahMeadTex3"; break;
		}
		headTex = LoadCoopSkinTex(headStr);
		topTex  = LoadCoopSkinTex(topStr);
		botTex  = LoadCoopSkinTex(botStr);
		legsTex = LoadCoopSkinTex(legsStr);

		MultiSkins[0] = headTex;
		MultiSkins[1] = legsTex;
		MultiSkins[2] = botTex;
		MultiSkins[3] = topTex;
		MultiSkins[4] = botTex;
		MultiSkins[5] = Texture'DeusExItems.Skins.PinkMaskTex';
		if (GlassesIdx == 1)
			MultiSkins[6] = Texture'DeusExItems.Skins.PinkMaskTex';
		else
			MultiSkins[6] = headTex;
		MultiSkins[7] = headTex;
		return;
	}

	// 1: Female - Top & Pants (GFM_TShirtPants) [Screenshot 2 style]
	if (BodyIdx == 1)
	{
		Mesh = Mesh(DynamicLoadObject("DeusExCharacters.GFM_TShirtPants", class'Mesh'));
		switch (HeadIdx)
		{
			case 0:  headStr = "DeusExCharacters.Skins.NurseTex0"; break;
			case 1:  headStr = "DeusExCharacters.Skins.SandraRentonTex0"; break;
			case 2:  headStr = "DeusExCharacters.Skins.Female1Tex0"; break;
			case 3:  headStr = "DeusExCharacters.Skins.LowerClassFemaleTex0"; break;
			case 4:  headStr = "DeusExCharacters.Skins.TiffanySavageTex0"; break;
			case 5:  headStr = "DeusExCharacters.Skins.JordanSheaTex0"; break;
			case 6:  headStr = "DeusExCharacters.Skins.JunkieFemaleTex0"; break;
			case 7:  headStr = "DeusExCharacters.Skins.BumFemaleTex0"; break;
			case 8:  headStr = "DeusExCharacters.Skins.Hooker2Tex0"; break;
			case 9:  headStr = "DeusExCharacters.Skins.Businesswoman1Tex0"; break;
			case 10: headStr = "DeusExCharacters.Skins.SecretaryTex0"; break;
			default: headStr = "TNMCharacters.Skins.RandomHeadTex1"; break;
		}
		switch (TopIdx)
		{
			case 0:  topStr = "TNMCharacters.Skins.GP_ShirtFem02"; break;
			case 1:  topStr = "TNMCharacters.Skins.GP_ShirtFem01"; break;
			case 2:  topStr = "TNMCharacters.Skins.GP_ShirtFem03"; break;
			case 3:  topStr = "TNMCharacters.Skins.GP_ShirtFem04"; break;
			case 4:  topStr = "TNMCharacters.Skins.GP_ShirtFem05"; break;
			case 5:  topStr = "TNMCharacters.Skins.N00BzShirtFemale"; break;
			case 6:  topStr = "DeusExCharacters.Skins.SandraRentonTex1"; break;
			case 7:  topStr = "DeusExCharacters.Skins.LowerClassFemaleTex1"; break;
			case 8:  topStr = "DeusExCharacters.Skins.Female1Tex1"; break;
			case 9:  topStr = "DeusExCharacters.Skins.TiffanySavageTex1"; break;
			case 10: topStr = "DeusExCharacters.Skins.JordanSheaTex1"; break;
			default: topStr = "TNMCharacters.Skins.ABIFemaleGuard"; break;
		}
		switch (BottomIdx)
		{
			case 0:  botStr = "DeusExCharacters.Skins.PantsTex6"; break;
			case 1:  botStr = "DeusExCharacters.Skins.PantsTex5"; break;
			case 2:  botStr = "DeusExCharacters.Skins.PantsTex2"; break;
			case 3:  botStr = "DeusExCharacters.Skins.PantsTex4"; break;
			case 4:  botStr = "DeusExCharacters.Skins.PantsTex9"; break;
			case 5:  botStr = "TNMCharacters.Skins.GP_Pants05"; break;
			case 6:  botStr = "TNMCharacters.Skins.GP_Pants01"; break;
			case 7:  botStr = "DeusExCharacters.Skins.TiffanySavageTex2"; break;
			case 8:  botStr = "DeusExCharacters.Skins.JunkieFemaleTex2"; break;
			default: botStr = "TNMCharacters.Skins.ABISecurityTex3"; break;
		}
		headTex = LoadCoopSkinTex(headStr);
		topTex  = LoadCoopSkinTex(topStr);
		botTex  = LoadCoopSkinTex(botStr);

		MultiSkins[0] = headTex;
		if (LegsIdx == 2 || LegsIdx == 3)
			MultiSkins[1] = headTex;
		else
			MultiSkins[1] = Texture'DeusExItems.Skins.PinkMaskTex';
		if (LegsIdx == 1 || LegsIdx == 3)
			MultiSkins[2] = headTex;
		else
			MultiSkins[2] = Texture'DeusExItems.Skins.PinkMaskTex';
		MultiSkins[3] = frameTex;
		MultiSkins[4] = lensTex;
		MultiSkins[5] = headTex;
		MultiSkins[6] = botTex;
		MultiSkins[7] = topTex;
		return;
	}

	// 2: Female - Business Suit & Skirt (GFM_SuitSkirt) [Separate Jacket, Skirt, and Pantyhose/Tights!]
	if (BodyIdx == 2)
	{
		Mesh = Mesh(DynamicLoadObject("DeusExCharacters.GFM_SuitSkirt", class'Mesh'));
		switch (HeadIdx)
		{
			case 0:  headStr = "DeusExCharacters.Skins.Female2Tex0"; break;
			case 1:  headStr = "DeusExCharacters.Skins.SecretaryTex0"; break;
			case 2:  headStr = "DeusExCharacters.Skins.Businesswoman1Tex0"; break;
			case 3:  headStr = "DeusExCharacters.Skins.MargaretWilliamsTex0"; break;
			case 4:  headStr = "DeusExCharacters.Skins.RachelMeadTex0"; break;
			case 5:  headStr = "DeusExCharacters.Skins.NurseTex0"; break;
			case 6:  headStr = "DeusExCharacters.Skins.MaidTex0"; break;
			case 7:  headStr = "DeusExCharacters.Skins.SkinTex5"; break;
			case 8:  headStr = "TNMCharacters.Skins.MercedesTex0"; break;
			case 9:  headStr = "TNMCharacters.Skins.GoatFemaleHead1"; break;
			case 10: headStr = "TNMCharacters.Skins.GoatFemaleHead2"; break;
			case 11: headStr = "TNMCharacters.Skins.GoatFemaleHead3"; break;
			case 12: headStr = "TNMCharacters.Skins.LlamaFemaleHead1"; break;
			default: headStr = "TNMCharacters.Skins.LlamaFemaleHead2"; break;
		}
		switch (TopIdx)
		{
			case 0:  topStr = "DeusExCharacters.Skins.Female3Tex1"; break;
			case 1:  topStr = "DeusExCharacters.Skins.Female2Tex2"; break;
			case 2:  topStr = "DeusExCharacters.Skins.SecretaryTex2"; break;
			case 3:  topStr = "DeusExCharacters.Skins.Businesswoman1Tex1"; break;
			case 4:  topStr = "DeusExCharacters.Skins.MargaretWilliamsTex1"; break;
			case 5:  topStr = "DeusExCharacters.Skins.RachelMeadTex1"; break;
			case 6:  topStr = "DeusExCharacters.Skins.NurseTex1"; break;
			case 7:  topStr = "DeusExCharacters.Skins.MaidTex1"; break;
			case 8:  topStr = "TNMCharacters.Skins.MercedesTex3"; break;
			case 9:  topStr = "TNMCharacters.Skins.GoatFemaleTex1"; break;
			case 10: topStr = "TNMCharacters.Skins.LlamaFemaleTex1"; break;
			case 11: topStr = "TNMCharacters.Skins.GP_SuitSkirt01"; break;
			default: topStr = "TNMCharacters.Skins.GP_SuitSkirt02"; break;
		}
		if (BottomIdx <= 0)
			botStr = topStr;
		else
		{
			switch (BottomIdx - 1)
			{
				case 0:  botStr = "DeusExCharacters.Skins.Female3Tex1"; break;
				case 1:  botStr = "DeusExCharacters.Skins.Female2Tex2"; break;
				case 2:  botStr = "DeusExCharacters.Skins.SecretaryTex2"; break;
				case 3:  botStr = "DeusExCharacters.Skins.Businesswoman1Tex1"; break;
				case 4:  botStr = "DeusExCharacters.Skins.MargaretWilliamsTex1"; break;
				case 5:  botStr = "DeusExCharacters.Skins.RachelMeadTex1"; break;
				case 6:  botStr = "DeusExCharacters.Skins.NurseTex1"; break;
				case 7:  botStr = "DeusExCharacters.Skins.MaidTex1"; break;
				case 8:  botStr = "TNMCharacters.Skins.MercedesTex3"; break;
				case 9:  botStr = "TNMCharacters.Skins.GoatFemaleTex1"; break;
				case 10: botStr = "TNMCharacters.Skins.LlamaFemaleTex1"; break;
				case 11: botStr = "TNMCharacters.Skins.GP_SuitSkirt01"; break;
				default: botStr = "TNMCharacters.Skins.GP_SuitSkirt02"; break;
			}
		}
		switch (LegsIdx)
		{
			case 0:  legsStr = "DeusExCharacters.Skins.LegsTex1"; break;
			case 1:  legsStr = "DeusExCharacters.Skins.LegsTex2"; break;
			case 2:  legsStr = "DeusExCharacters.Skins.Female3Tex2"; break;
			case 3:  legsStr = "DeusExCharacters.Skins.Female2Tex1"; break;
			case 4:  legsStr = "TNMCharacters.Skins.GP_Legs01"; break;
			case 5:  legsStr = "DeusExCharacters.Skins.Businesswoman1Tex2"; break;
			case 6:  legsStr = "DeusExCharacters.Skins.RachelMeadTex2"; break;
			case 7:  legsStr = "TNMCharacters.Skins.GoatFemaleTex2"; break;
			default: legsStr = "TNMCharacters.Skins.LlamaFemaleTex2"; break;
		}
		headTex = LoadCoopSkinTex(headStr);
		topTex  = LoadCoopSkinTex(topStr);
		botTex  = LoadCoopSkinTex(botStr);
		legsTex = LoadCoopSkinTex(legsStr);

		MultiSkins[0] = headTex;
		MultiSkins[1] = headTex;
		MultiSkins[2] = headTex;
		MultiSkins[3] = legsTex;
		MultiSkins[4] = topTex;
		MultiSkins[5] = botTex;
		MultiSkins[6] = frameTex;
		MultiSkins[7] = lensTex;
		return;
	}

	// 3: Female - Trenchcoat (GFM_Trench)
	if (BodyIdx == 3)
	{
		Mesh = Mesh(DynamicLoadObject("DeusExCharacters.GFM_Trench", class'Mesh'));
		switch (HeadIdx)
		{
			case 0:  headStr = "TNMCharacters.Skins.KylieTex0"; break;
			case 1:  headStr = "DeusExCharacters.Skins.Female4Tex0"; break;
			case 2:  headStr = "DeusExCharacters.Skins.ScientistFemaleTex0"; break;
			case 3:  headStr = "TNMCharacters.Skins.JackieTex0"; break;
			case 4:  headStr = "DeusExCharacters.Skins.NurseTex0"; break;
			case 5:  headStr = "DeusExCharacters.Skins.SandraRentonTex0"; break;
			case 6:  headStr = "DeusExCharacters.Skins.SecretaryTex0"; break;
			case 7:  headStr = "DeusExCharacters.Skins.Hooker2Tex0"; break;
			case 8:  headStr = "TNMCharacters.Skins.GoatFemaleHead1"; break;
			default: headStr = "TNMCharacters.Skins.LlamaFemaleHead1"; break;
		}
		switch (TopIdx)
		{
			case 0:  topStr = "TNMCharacters.Skins.KylieTex1"; break;
			case 1:  topStr = "DeusExCharacters.Skins.Female4Tex1"; break;
			case 2:  topStr = "DeusExCharacters.Skins.TrenchShirtTex3"; break;
			case 3:  topStr = "DeusExCharacters.Skins.TrenchShirtTex1"; break;
			case 4:  topStr = "DeusExCharacters.Skins.TrenchShirtTex2"; break;
			case 5:  topStr = "TNMCharacters.Skins.JackieTex1"; break;
			case 6:  topStr = "DeusExCharacters.Skins.SmugglerTex1"; break;
			default: topStr = "DeusExCharacters.Skins.LowerClassFemaleTex1"; break;
		}
		switch (BottomIdx)
		{
			case 0:  botStr = "TNMCharacters.Skins.KylieTex2"; break;
			case 1:  botStr = "DeusExCharacters.Skins.Female4Tex2"; break;
			case 2:  botStr = "DeusExCharacters.Skins.ScientistFemaleTex2"; break;
			case 3:  botStr = "DeusExCharacters.Skins.LabCoatTex1"; break;
			case 4:  botStr = "DeusExCharacters.Skins.SmugglerTex2"; break;
			default: botStr = "DeusExCharacters.Skins.TrenchCoatTex1"; break;
		}
		switch (LegsIdx)
		{
			case 0:  legsStr = "TNMCharacters.Skins.KylieTex3"; break;
			case 1:  legsStr = "DeusExCharacters.Skins.Female4Tex3"; break;
			case 2:  legsStr = "DeusExCharacters.Skins.ScientistFemaleTex3"; break;
			case 3:  legsStr = "TNMCharacters.Skins.AthenaTex3"; break;
			case 4:  legsStr = "DeusExCharacters.Skins.TiffanySavageTex2"; break;
			case 5:  legsStr = "DeusExCharacters.Skins.PantsTex2"; break;
			default: legsStr = "DeusExCharacters.Skins.PantsTex6"; break;
		}
		headTex = LoadCoopSkinTex(headStr);
		topTex  = LoadCoopSkinTex(topStr);
		botTex  = LoadCoopSkinTex(botStr);
		legsTex = LoadCoopSkinTex(legsStr);

		MultiSkins[0] = headTex;
		MultiSkins[1] = botTex;
		MultiSkins[2] = legsTex;
		MultiSkins[3] = headTex;
		MultiSkins[4] = topTex;
		if (BottomIdx == 1)
			MultiSkins[5] = Texture'DeusExItems.Skins.PinkMaskTex';
		else
			MultiSkins[5] = botTex;
		MultiSkins[6] = frameTex;
		MultiSkins[7] = lensTex;
		return;
	}

	// 4: Male - Shirt & Pants (GM_DressShirt / _S / _F)
	if (BodyIdx == 4)
	{
		if (LegsIdx == 1)
			Mesh = Mesh(DynamicLoadObject("DeusExCharacters.GM_DressShirt_S", class'Mesh'));
		else if (LegsIdx == 2)
			Mesh = Mesh(DynamicLoadObject("DeusExCharacters.GM_DressShirt_F", class'Mesh'));
		else
			Mesh = Mesh(DynamicLoadObject("DeusExCharacters.GM_DressShirt", class'Mesh'));

		switch (HeadIdx)
		{
			case 0:  headStr = "TNMCharacters.Skins.BoardGuestTex0"; break;
			case 1:  headStr = "TNMCharacters.Skins.BoardGuest"; break;
			case 2:  headStr = "DeusExCharacters.Skins.SkinTex1"; break;
			case 3:  headStr = "DeusExCharacters.Skins.SkinTex2"; break;
			case 4:  headStr = "DeusExCharacters.Skins.SkinTex3"; break;
			case 5:  headStr = "DeusExCharacters.Skins.Male1Tex0"; break;
			case 6:  headStr = "DeusExCharacters.Skins.BartenderTex0"; break;
			case 7:  headStr = "DeusExCharacters.Skins.MichaelHamnerTex0"; break;
			case 8:  headStr = "DeusExCharacters.Skins.SamCarterTex0"; break;
			case 9:  headStr = "DeusExCharacters.Skins.JoJoFineTex0"; break;
			case 10: headStr = "DeusExCharacters.Skins.HowardStrongTex0"; break;
			case 11: headStr = "DeusExCharacters.Skins.ThugMale2Tex0"; break;
			case 12: headStr = "TNMCharacters.Skins.GoatHeadTex1"; break;
			case 13: headStr = "TNMCharacters.Skins.GoatHeadTex2"; break;
			case 14: headStr = "TNMCharacters.Skins.LlamaHeadTex1"; break;
			default: headStr = "TNMCharacters.Skins.RandomHeadTex4"; break;
		}
		switch (TopIdx)
		{
			case 0:  topStr = "TNMCharacters.Skins.GP_Shirt01"; break;
			case 1:  topStr = "TNMCharacters.Skins.GP_Shirt02"; break;
			case 2:  topStr = "TNMCharacters.Skins.GP_Shirt03"; break;
			case 3:  topStr = "TNMCharacters.Skins.GP_Shirt04"; break;
			case 4:  topStr = "TNMCharacters.Skins.GP_Shirt05"; break;
			case 5:  topStr = "TNMCharacters.Skins.GP_Shirt06"; break;
			case 6:  topStr = "TNMCharacters.Skins.GP_Shirt07"; break;
			case 7:  topStr = "TNMCharacters.Skins.GP_Shirt08"; break;
			case 8:  topStr = "TNMCharacters.Skins.N00BzShirtMale"; break;
			case 9:  topStr = "TNMCharacters.Skins.BoardGuest1Tex1"; break;
			case 10: topStr = "TNMCharacters.Skins.LarryShirt"; break;
			case 11: topStr = "TNMCharacters.Skins.MIBShirt"; break;
			case 12: topStr = "DeusExCharacters.Skins.Male1Tex1"; break;
			case 13: topStr = "DeusExCharacters.Skins.Male2Tex1"; break;
			case 14: topStr = "DeusExCharacters.Skins.Male3Tex1"; break;
			default: topStr = "DeusExCharacters.Skins.ThugMale2Tex1"; break;
		}
		switch (BottomIdx)
		{
			case 0:  botStr = "TNMCharacters.Skins.GP_Pants01"; break;
			case 1:  botStr = "TNMCharacters.Skins.GP_Pants02"; break;
			case 2:  botStr = "TNMCharacters.Skins.GP_Pants03"; break;
			case 3:  botStr = "TNMCharacters.Skins.GP_Pants04"; break;
			case 4:  botStr = "TNMCharacters.Skins.GP_Pants05"; break;
			case 5:  botStr = "TNMCharacters.Skins.GP_Pants06"; break;
			case 6:  botStr = "TNMCharacters.Skins.GP_Pants07"; break;
			case 7:  botStr = "DeusExCharacters.Skins.PantsTex1"; break;
			case 8:  botStr = "DeusExCharacters.Skins.PantsTex2"; break;
			case 9:  botStr = "DeusExCharacters.Skins.PantsTex5"; break;
			case 10: botStr = "DeusExCharacters.Skins.PantsTex6"; break;
			case 11: botStr = "DeusExCharacters.Skins.PantsTex8"; break;
			case 12: botStr = "TNMCharacters.Skins.GoatTex4"; break;
			default: botStr = "TNMCharacters.Skins.LlamaTex4"; break;
		}
		headTex = LoadCoopSkinTex(headStr);
		topTex  = LoadCoopSkinTex(topStr);
		botTex  = LoadCoopSkinTex(botStr);

		MultiSkins[0] = headTex;
		MultiSkins[1] = Texture'DeusExItems.Skins.PinkMaskTex';
		if (LegsIdx == 3)
			MultiSkins[2] = headTex;
		else
			MultiSkins[2] = Texture'DeusExItems.Skins.PinkMaskTex';
		MultiSkins[3] = botTex;
		MultiSkins[4] = headTex;
		MultiSkins[5] = topTex;
		MultiSkins[6] = frameTex;
		MultiSkins[7] = lensTex;
		return;
	}

	// 5: Male - Trenchcoat (GM_Trench)
	Mesh = Mesh(DynamicLoadObject("DeusExCharacters.GM_Trench", class'Mesh'));
	switch (HeadIdx)
	{
		case 0:  headStr = "TNMCharacters.Skins.BogieTex0"; break;
		case 1:  headStr = "TNMCharacters.Skins.GoatHeadTex1"; break;
		case 2:  headStr = "TNMCharacters.Skins.GoatHeadTex2"; break;
		case 3:  headStr = "TNMCharacters.Skins.GoatHeadTex3"; break;
		case 4:  headStr = "TNMCharacters.Skins.LlamaHeadTex1"; break;
		case 5:  headStr = "TNMCharacters.Skins.LlamaHeadTex2"; break;
		case 6:  headStr = "TNMCharacters.Skins.LlamaHeadTex3"; break;
		case 7:  headStr = "DeusExCharacters.Skins.BartenderTex0"; break;
		case 8:  headStr = "DeusExCharacters.Skins.SamCarterTex0"; break;
		case 9:  headStr = "DeusExCharacters.Skins.StantonDowdTex0"; break;
		case 10: headStr = "DeusExCharacters.Skins.GilbertRentonTex0"; break;
		case 11: headStr = "DeusExCharacters.Skins.HarleyFilbenTex0"; break;
		case 12: headStr = "DeusExCharacters.Skins.BumMale2Tex0"; break;
		default: headStr = "DeusExCharacters.Skins.SkinTex2"; break;
	}
	switch (TopIdx)
	{
		case 0:  topStr = "TNMCharacters.Skins.BogieTex1"; break;
		case 1:  topStr = "DeusExCharacters.Skins.TrenchShirtTex1"; break;
		case 2:  topStr = "DeusExCharacters.Skins.TrenchShirtTex2"; break;
		case 3:  topStr = "DeusExCharacters.Skins.TrenchShirtTex3"; break;
		case 4:  topStr = "TNMCharacters.Skins.GoatTex2"; break;
		case 5:  topStr = "TNMCharacters.Skins.LlamaTex2"; break;
		case 6:  topStr = "DeusExCharacters.Skins.FordSchickTex1"; break;
		default: topStr = "DeusExCharacters.Skins.SmugglerTex1"; break;
	}
	switch (BottomIdx)
	{
		case 0:  botStr = "TNMCharacters.Skins.BogieTex2"; break;
		case 1:  botStr = "DeusExCharacters.Skins.TrenchCoatTex1"; break;
		case 2:  botStr = "TNMCharacters.Skins.GoatTex3"; break;
		case 3:  botStr = "TNMCharacters.Skins.LlamaTex3"; break;
		case 4:  botStr = "DeusExCharacters.Skins.LabCoatTex1"; break;
		case 5:  botStr = "DeusExCharacters.Skins.BumMale2Tex2"; break;
		case 6:  botStr = "DeusExCharacters.Skins.HarleyFilbenTex2"; break;
		default: botStr = "DeusExCharacters.Skins.SmugglerTex2"; break;
	}
	switch (LegsIdx)
	{
		case 0:  legsStr = "TNMCharacters.Skins.BogieTex3"; break;
		case 1:  legsStr = "DeusExCharacters.Skins.PantsTex1"; break;
		case 2:  legsStr = "DeusExCharacters.Skins.PantsTex4"; break;
		case 3:  legsStr = "DeusExCharacters.Skins.PantsTex5"; break;
		case 4:  legsStr = "DeusExCharacters.Skins.PantsTex7"; break;
		case 5:  legsStr = "DeusExCharacters.Skins.PantsTex8"; break;
		case 6:  legsStr = "TNMCharacters.Skins.GoatTex4"; break;
		default: legsStr = "TNMCharacters.Skins.LlamaTex4"; break;
	}
	headTex = LoadCoopSkinTex(headStr);
	topTex  = LoadCoopSkinTex(topStr);
	botTex  = LoadCoopSkinTex(botStr);
	legsTex = LoadCoopSkinTex(legsStr);

	MultiSkins[0] = headTex;
	MultiSkins[1] = botTex;
	MultiSkins[2] = legsTex;
	MultiSkins[3] = headTex;
	MultiSkins[4] = topTex;
	MultiSkins[5] = botTex;
	MultiSkins[6] = frameTex;
	MultiSkins[7] = lensTex;
}

simulated function ApplyCoopModel(int ModelIdx)
{
	local int i;
	local int bodyIdx, headIdx, topIdx, bottomIdx, legsIdx, glassesIdx;
	local String modelClassName;
	local Class<Actor> modelClass;

	coopCharacterModel = ModelIdx;

	if (ModelIdx <= 0)
	{
		Mesh = Default.Mesh;
		Texture = Default.Texture;
		ResetSkinStyle();
		return;
	}

	if ((ModelIdx & 134217728) != 0)
	{
		UnpackCustomCoopSkin(ModelIdx, bodyIdx, headIdx, topIdx, bottomIdx, legsIdx, glassesIdx);
		ApplyCustomCoopSkin(bodyIdx, headIdx, topIdx, bottomIdx, legsIdx, glassesIdx);
		return;
	}

	if (ModelIdx >= 1 && ModelIdx <= 6)
	{
		// Visual-only Trestkon Trenchcoat variants (does NOT touch CoatType, PlayerSkin, or TNMPACS flags)
		Mesh = LodMesh'TNM.GM_Trenchkon';
		Texture = Default.Texture;
		MultiSkins[0] = Texture'tnm.Skins.TrestkonTex0';
		MultiSkins[1] = Texture'tnm.Skins.TrestkonTrenchTex2';
		MultiSkins[2] = Texture'tnm.Skins.TrestkonTrenchTex3';
		MultiSkins[3] = Texture'DeusExItems.Skins.PinkMaskTex';
		MultiSkins[4] = Texture'tnm.Skins.TrestkonTrenchTex1';
		MultiSkins[5] = Texture'tnm.Skins.TrestkonTrenchTex2';
		MultiSkins[6] = Texture'tnm.Skins.FramesTex6';
		MultiSkins[7] = Texture'tnm.Skins.LensesTex8';

		switch (ModelIdx)
		{
			case 2:
				MultiSkins[1] = Texture'tnm.Skins.TrestkonTrenchTex21';
				MultiSkins[5] = Texture'tnm.Skins.TrestkonTrenchTex21';
				break;
			case 3:
				MultiSkins[1] = Texture'tnm.Skins.Coat_WC';
				MultiSkins[5] = Texture'tnm.Skins.Coat_WC';
				break;
			case 4:
				MultiSkins[1] = Texture'tnm.Skins.Coat_Goat';
				MultiSkins[5] = Texture'tnm.Skins.Coat_Goat';
				break;
			case 5:
				MultiSkins[1] = Texture'tnm.Skins.Coat_Llama';
				MultiSkins[5] = Texture'tnm.Skins.Coat_Llama';
				break;
			case 6:
				MultiSkins[1] = Texture'tnm.Skins.Coat_Gold';
				MultiSkins[5] = Texture'tnm.Skins.Coat_Gold';
				break;
		}
		return;
	}

	switch (ModelIdx)
	{
		case 7:  modelClassName = "TNMMP.MPPhasmatis"; break;
		case 8:  modelClassName = "TNMMP.MPZeroPresence"; break;
		case 9:  modelClassName = "TNMMP.MPSkara"; break;
		case 10: modelClassName = "TNMMP.MPKingKashue"; break;
		case 11: modelClassName = "TNMMP.MPKylieGriffin"; break;
		case 12: modelClassName = "TNMMP.MPDeusDiablo"; break;
		case 13: modelClassName = "TNMMP.MPTheRenegadeMaster"; break;
		case 14: modelClassName = "TNMMP.MPEndar"; break;
		case 15: modelClassName = "TNMMP.MPRealZeroPresence"; break;
		case 16: modelClassName = "TNMMP.MPFirewall"; break;
		case 17: modelClassName = "TNMMP.MPFirewallAlpha"; break;
		case 18: modelClassName = "TNMMP.MPMadMax"; break;
		case 19: modelClassName = "TNMMP.MPMole"; break;
		case 20: modelClassName = "TNMMP.MPWaltonSimons"; break;
		case 21: modelClassName = "TNMMP.MPChris"; break;
		case 22: modelClassName = "TNMMP.MPBogie"; break;
		case 23: modelClassName = "TNM.TNMMPMJ12"; break;
		case 24: modelClassName = "TNM.TNMMPNSF"; break;
		case 25: modelClassName = "TNM.TNMMPUnatco"; break;
	}

	if (modelClassName != "")
	{
		modelClass = Class<Actor>(DynamicLoadObject(modelClassName, class'Class'));
		if (modelClass != None)
		{
			Mesh = modelClass.Default.Mesh;
			Texture = modelClass.Default.Texture;
			for (i = 0; i < 8; i++)
				MultiSkins[i] = modelClass.Default.MultiSkins[i];
		}
	}
}

// ----------------------------------------------------------------------------
// 3. Untimed Co-op Medkit Revival (Scales with Reviver's Medicine Skill, split evenly across all 6 body parts)
// ----------------------------------------------------------------------------
function CoopReviveTeammate(Trestkon DeadP, Carcass BodyCarc)
{
	local Vector ReviveLoc;
	local Rotator ReviveRot;
	local Trestkon OtherP;
	local int totalHeal, basePart, rem;

	if (DeadP == None || !DeadP.IsInState('Dying'))
		return;

	if (BodyCarc != None && !BodyCarc.bDeleteMe)
	{
		foreach AllActors(class'Trestkon', OtherP)
		{
			if (OtherP.CarriedDecoration == BodyCarc)
			{
				OtherP.CarriedDecoration = None;
				BodyCarc.SetBase(None);
			}
		}
		ReviveLoc = BodyCarc.Location + vect(0, 0, 40);
	}
	else
		ReviveLoc = Location + vector(Rotation) * 48.0 + vect(0, 0, 16);

	ReviveRot = DeadP.Rotation;
	ReviveRot.Pitch = 0;
	ReviveRot.Roll = 0;

	if (BodyCarc != None && !BodyCarc.bDeleteMe)
	{
		if (DeusExCarcass(BodyCarc) != None)
			DeusExCarcass(BodyCarc).bQueuedDestroy = True;
		BodyCarc.Destroy();
	}
	DeadP.MoveTarget = None;
	DeadP.coopSpectateTarget = None;
	DeadP.ViewTarget = None;

	// Calculate total heal from the reviver's Medkit + Medicine Skill (30 / 45 / 60 / 90 total HP)
	// and divide evenly across all 6 body parts (5 / 7-8 / 10 / 15 HP per part)
	bCoopInHealthScreenHeal = False;
	totalHeal = CalculateSkillHealAmount(class'MedKit'.Default.healAmount);
	if (totalHeal < 6)
		totalHeal = 30;
	basePart = totalHeal / 6;
	rem = totalHeal - (basePart * 6);

	DeadP.HealthHead     = basePart;
	DeadP.HealthTorso    = basePart;
	DeadP.HealthLegLeft  = basePart;
	DeadP.HealthLegRight = basePart;
	DeadP.HealthArmLeft  = basePart;
	DeadP.HealthArmRight = basePart;
	if (rem >= 1) DeadP.HealthHead++;
	if (rem >= 2) DeadP.HealthTorso++;
	if (rem >= 3) DeadP.HealthLegLeft++;
	if (rem >= 4) DeadP.HealthLegRight++;
	if (rem >= 5) DeadP.HealthArmLeft++;
	DeadP.GenerateTotalHealth();

	DeadP.poisonCounter = 0;
	DeadP.poisonTimer = 0;
	DeadP.drugEffectTimer = 0;
	DeadP.bOnFire = False;
	DeadP.burnTimer = 0;

	// Restore collision & visibility
	DeadP.bHidden = False;
	DeadP.bCollideWorld = True;
	DeadP.SetCollision(True, True, DeadP.Default.bBlockPlayers);
	DeadP.SetCollisionSize(DeadP.Default.CollisionRadius, DeadP.Default.CollisionHeight);
	if (!DeadP.SetLocation(ReviveLoc))
		DeadP.SetLocation(Location + vect(0, 0, 16));
	DeadP.SetPhysics(PHYS_Falling);
	DeadP.ViewRotation = ReviveRot;
	DeadP.bBehindView = False;
	DeadP.GotoState('PlayerWalking');
	DeadP.ClientCoopRevived(DeadP.Location, ReviveRot);

	if (DeadP.coopCharacterModel > 0)
		DeadP.ApplyCoopModel(DeadP.coopCharacterModel);
	else
		DeadP.ResetSkinStyle();

	PlaySound(Sound'DeusExSounds.Generic.MedicalHiss', SLOT_None, 2.0, , 512.0);
	ClientMessage("You revived " $ DeadP.GetCoopPlayerName() $ " with a Medkit! (" $ totalHeal $ " total HP restored)");
	DeadP.ClientMessage(GetCoopPlayerName() $ " revived you with a Medkit! (" $ totalHeal $ " total HP across all body parts)");
}

simulated function ClientCoopRevived(Vector ReviveLoc, Rotator ReviveRot)
{
	coopSpectateTarget = None;
	ViewTarget = None;
	bHidden = False;
	bBehindView = False;
	SetCollision(True, True, Default.bBlockPlayers);
	SetLocation(ReviveLoc);
	SetPhysics(PHYS_Walking);
	ViewRotation = ReviveRot;
	GotoState('PlayerWalking');
	if (coopCharacterModel > 0)
		ApplyCoopModel(coopCharacterModel);
}

simulated function Vector GetCoopDeadBodyViewLoc()
{
	local YuukaReviveTotem totem;
	local Vector carcLoc, targetLoc, HitLocation, HitNormal;
	local Actor HitActor;
	local bool bFoundCarc;

	if (MoveTarget != None && !MoveTarget.bDeleteMe)
	{
		carcLoc = MoveTarget.Location;
		bFoundCarc = True;
	}
	else
	{
		foreach AllActors(class'YuukaReviveTotem', totem)
		{
			if (totem.LinkedPlayer == Self)
			{
				if (totem.LinkedCarcass != None && !totem.LinkedCarcass.bDeleteMe)
					carcLoc = totem.LinkedCarcass.Location;
				else
					carcLoc = totem.Location - vect(0, 0, 32);
				bFoundCarc = True;
				break;
			}
		}
	}

	if (!bFoundCarc)
	{
		// Before carcass spawns (or fallback): raise slightly above default Location (+18 UU)
		targetLoc = Location + vect(0, 0, 18);
		HitActor = Trace(HitLocation, HitNormal, targetLoc, Location, false);
		if (HitActor != None)
			return HitLocation - vect(0, 0, 4);
		return targetLoc;
	}

	// YuukaReviveTotem hovers at carcLoc + vect(0, 0, 32) (top at ~+48).
	// Place default camera from the body slightly higher (+58 above carcass) so it sits just above the floating totem!
	targetLoc = carcLoc + vect(0, 0, 58);
	HitActor = Trace(HitLocation, HitNormal, targetLoc, carcLoc, false);
	if (HitActor != None)
		return HitLocation - vect(0, 0, 4);
	return targetLoc;
}

function ServerCycleDeadSpectate()
{
	local Trestkon P, FirstP, NextP;
	local bool bFoundCurrent;

	if (!IsInState('Dying'))
		return;

	foreach AllActors(class'Trestkon', P)
	{
		if (P == Self)
			continue;
		if (FirstP == None)
			FirstP = P;
		if (bFoundCurrent && NextP == None)
		{
			NextP = P;
			break;
		}
		if (P == coopSpectateTarget)
			bFoundCurrent = True;
	}

	if (coopSpectateTarget == None)
		coopSpectateTarget = FirstP;
	else if (NextP != None)
		coopSpectateTarget = NextP;
	else
		coopSpectateTarget = None;

	if (coopSpectateTarget != None)
	{
		ViewTarget = coopSpectateTarget;
		if (Trestkon(coopSpectateTarget) != None)
			ClientMessage("Spectating: " $ Trestkon(coopSpectateTarget).GetCoopPlayerName() $ " (Right-Click to swap view)");
	}
	else
	{
		ViewTarget = MoveTarget;
		ClientMessage("Viewing your body (Right-Click to spectate other players)");
	}
}

exec function medkityuuka1()
{
	ServerMedkitYuuka1();
}

function ServerMedkitYuuka1()
{
	local MedKit med, existingMed;
	local Vector spawnLoc;

	existingMed = MedKit(FindInventoryType(class'MedKit'));
	if (existingMed != None && existingMed.NumCopies < existingMed.MaxCopies)
	{
		existingMed.NumCopies++;
		ClientMessage("Added a Medkit to your inventory! (" $ existingMed.NumCopies $ " total)");
		return;
	}

	spawnLoc = Location + vector(Rotation) * 40.0 + vect(0, 0, 16);
	med = Spawn(class'MedKit', , , spawnLoc);
	if (med != None)
	{
		if (FindInventorySlot(med, True))
		{
			FindInventorySlot(med, False);
			med.GiveTo(Self);
			AddObjectToBelt(med, -1, False);
			ClientMessage("Spawned a Medkit into your inventory!");
		}
		else
		{
			ClientMessage("Spawned a Medkit in front of you!");
		}
	}
}

// ----------------------------------------------------------------------------
// 4. Inventory Context Menu Item Trading (5-meter / 265 UU proximity restriction)
// ----------------------------------------------------------------------------
function ServerCoopTradeItem(Inventory Item, Trestkon TargetPlayer)
{
	local float distUU;
	local Inventory existingInv, spawnedCopy;
	local DeusExPickup pickupItem;
	local DeusExWeapon weapItem, targetWeap;
	local Ammo srcAmmo;
	local String itemLabel;

	if (Item == None || TargetPlayer == None || TargetPlayer == Self)
		return;

	if (Item.Owner != Self)
	{
		ClientMessage("You no longer have that item.");
		return;
	}

	if (TargetPlayer.IsInState('Dying') || TargetPlayer.Health <= 0)
	{
		ClientMessage(TargetPlayer.GetCoopPlayerName() $ " is down! Revive them first.");
		return;
	}

	distUU = VSize(TargetPlayer.Location - Location);
	if (distUU > 265.0)
	{
		ClientMessage(TargetPlayer.GetCoopPlayerName() $ " is too far away to trade! (Must be within 5m)");
		return;
	}

	if (Item.IsA('NanoKeyRing') || Item.IsA('Fists'))
	{
		ClientMessage("You cannot trade that item.");
		return;
	}

	itemLabel = Item.itemName;
	if (itemLabel == "")
		itemLabel = String(Item.Class.Name);

	// Case A: Stackable Pickup (Medkit, Lockpick, Multitool, BioelectricCell, Consumables)
	pickupItem = DeusExPickup(Item);
	if (pickupItem != None && pickupItem.bCanHaveMultipleCopies)
	{
		existingInv = TargetPlayer.FindInventoryType(pickupItem.Class);
		if (DeusExPickup(existingInv) != None)
		{
			if (DeusExPickup(existingInv).NumCopies >= DeusExPickup(existingInv).maxCopies)
			{
				ClientMessage(TargetPlayer.GetCoopPlayerName() $ " cannot carry any more " $ itemLabel $ "!");
				return;
			}
			DeusExPickup(existingInv).NumCopies++;
			pickupItem.NumCopies--;
			if (pickupItem.NumCopies <= 0)
			{
				if (inHand == pickupItem)
					PutInHand(None);
				RemoveObjectFromBelt(pickupItem);
				DeleteInventory(pickupItem);
				pickupItem.Destroy();
			}
			ClientMessage("Gave 1x " $ itemLabel $ " to " $ TargetPlayer.GetCoopPlayerName() $ ".");
			TargetPlayer.ClientMessage(GetCoopPlayerName() $ " gave you 1x " $ itemLabel $ ".");
			return;
		}
	}

	// Case B: Weapon that TargetPlayer already owns -> notify
	weapItem = DeusExWeapon(Item);
	if (weapItem != None)
	{
		targetWeap = DeusExWeapon(TargetPlayer.FindInventoryType(weapItem.Class));
		if (targetWeap != None && !weapItem.bHandToHand)
		{
			ClientMessage(TargetPlayer.GetCoopPlayerName() $ " already has a " $ itemLabel $ "!");
			return;
		}
	}

	// Case C: Check if TargetPlayer has room in their inventory grid
	if (!TargetPlayer.FindInventorySlot(Item, True))
	{
		ClientMessage(TargetPlayer.GetCoopPlayerName() $ "'s inventory is too full for " $ itemLabel $ "!");
		return;
	}

	// Unequip from sender if currently in hand
	if (inHand == Item)
		PutInHand(None);

	RemoveObjectFromBelt(Item);
	DeleteInventory(Item);

	// Also give starter ammo if transferring a weapon and TargetPlayer has no ammo for it
	if (weapItem != None && weapItem.AmmoName != None && weapItem.AmmoName != Class'AmmoNone')
	{
		srcAmmo = Ammo(FindInventoryType(weapItem.AmmoName));
		if (srcAmmo != None && TargetPlayer.FindInventoryType(weapItem.AmmoName) == None)
		{
			spawnedCopy = Spawn(weapItem.AmmoName);
			if (Ammo(spawnedCopy) != None)
			{
				Ammo(spawnedCopy).AmmoAmount = Min(srcAmmo.AmmoAmount, weapItem.PickUpAmmoCount);
				srcAmmo.AmmoAmount = Max(0, srcAmmo.AmmoAmount - Ammo(spawnedCopy).AmmoAmount);
				spawnedCopy.GiveTo(TargetPlayer);
				spawnedCopy.bInObjectBelt = False;
			}
		}
	}

	Item.bInObjectBelt = False;
	Item.BeltPos = -1;
	TargetPlayer.FindInventorySlot(Item, False);
	Item.GiveTo(TargetPlayer);

	ClientMessage("Gave " $ itemLabel $ " to " $ TargetPlayer.GetCoopPlayerName() $ ".");
	TargetPlayer.ClientMessage(GetCoopPlayerName() $ " gave you " $ itemLabel $ ".");
}

function bool IsAmmoUsedByOwnedWeapon(DeusExAmmo AmmoItem)
{
	local Inventory inv;
	local DeusExWeapon weap;
	local int i;

	if (AmmoItem == None)
		return False;

	for (inv = Inventory; inv != None; inv = inv.Inventory)
	{
		weap = DeusExWeapon(inv);
		if (weap != None)
		{
			if (weap.AmmoType == AmmoItem || weap.AmmoName == AmmoItem.Class)
				return True;
			for (i = 0; i < ArrayCount(weap.AmmoNames); i++)
			{
				if (weap.AmmoNames[i] == AmmoItem.Class)
					return True;
			}
		}
	}
	return False;
}

function ServerCoopTradeAmmo(DeusExAmmo AmmoItem, Trestkon TargetPlayer)
{
	local float distUU;
	local int clipSize, giveAmount;
	local DeusExAmmo targetAmmo;
	local String itemLabel;

	if (AmmoItem == None || TargetPlayer == None || TargetPlayer == Self)
		return;

	if (AmmoItem.Owner != Self || AmmoItem.AmmoAmount <= 0)
	{
		ClientMessage("You have no rounds of that ammo left.");
		return;
	}

	if (TargetPlayer.IsInState('Dying') || TargetPlayer.Health <= 0)
	{
		ClientMessage(TargetPlayer.GetCoopPlayerName() $ " is down! Revive them first.");
		return;
	}

	distUU = VSize(TargetPlayer.Location - Location);
	if (distUU > 265.0)
	{
		ClientMessage(TargetPlayer.GetCoopPlayerName() $ " is too far away to trade ammo! (Must be within 5m)");
		return;
	}

	itemLabel = AmmoItem.itemName;
	if (itemLabel == "")
		itemLabel = String(AmmoItem.Class.Name);

	clipSize = Max(1, AmmoItem.Default.AmmoAmount);
	giveAmount = Min(AmmoItem.AmmoAmount, clipSize);

	targetAmmo = DeusExAmmo(TargetPlayer.FindInventoryType(AmmoItem.Class));
	if (targetAmmo != None)
	{
		if (targetAmmo.AmmoAmount >= targetAmmo.MaxAmmo)
		{
			ClientMessage(TargetPlayer.GetCoopPlayerName() $ " cannot carry any more " $ itemLabel $ "!");
			return;
		}
		giveAmount = Min(giveAmount, targetAmmo.MaxAmmo - targetAmmo.AmmoAmount);
		targetAmmo.AmmoAmount += giveAmount;
	}
	else
	{
		targetAmmo = Spawn(AmmoItem.Class);
		if (targetAmmo == None)
			return;
		targetAmmo.AmmoAmount = giveAmount;
		targetAmmo.GiveTo(TargetPlayer);
		targetAmmo.bInObjectBelt = False;
	}

	AmmoItem.AmmoAmount = Max(0, AmmoItem.AmmoAmount - giveAmount);
	if (AmmoItem.AmmoAmount <= 0 && !IsAmmoUsedByOwnedWeapon(AmmoItem))
	{
		DeleteInventory(AmmoItem);
		AmmoItem.Destroy();
	}

	ClientMessage("Gave " $ giveAmount $ " rounds of " $ itemLabel $ " to " $ TargetPlayer.GetCoopPlayerName() $ ".");
	TargetPlayer.ClientMessage(GetCoopPlayerName() $ " gave you " $ giveAmount $ " rounds of " $ itemLabel $ ".");
}

function ServerCoopDropAmmo(DeusExAmmo AmmoItem)
{
	local int clipSize, dropAmount;
	local Vector dropVect;
	local DeusExAmmo droppedAmmo;
	local String itemLabel;

	if (AmmoItem == None || AmmoItem.Owner != Self || AmmoItem.AmmoAmount <= 0)
	{
		ClientMessage("You have no rounds of that ammo left.");
		return;
	}

	itemLabel = AmmoItem.itemName;
	if (itemLabel == "")
		itemLabel = String(AmmoItem.Class.Name);

	clipSize = Max(1, AmmoItem.Default.AmmoAmount);
	dropAmount = Min(AmmoItem.AmmoAmount, clipSize);

	dropVect = Location + (Vector(ViewRotation) * 32.0) + vect(0, 0, 16);
	droppedAmmo = Spawn(AmmoItem.Class, , , dropVect);
	if (droppedAmmo == None)
		droppedAmmo = Spawn(AmmoItem.Class, , , Location);

	if (droppedAmmo == None)
	{
		ClientMessage("Cannot drop " $ itemLabel $ " here.");
		return;
	}

	droppedAmmo.AmmoAmount = dropAmount;
	droppedAmmo.Velocity = Vector(ViewRotation) * 100.0 + vect(0, 0, 50);
	droppedAmmo.SetPhysics(PHYS_Falling);

	AmmoItem.AmmoAmount = Max(0, AmmoItem.AmmoAmount - dropAmount);
	if (AmmoItem.AmmoAmount <= 0 && !IsAmmoUsedByOwnedWeapon(AmmoItem))
	{
		DeleteInventory(AmmoItem);
		AmmoItem.Destroy();
	}

	PlaySound(Sound'DeusExSounds.Generic.DropMediumWeapon', SLOT_None, 1.5, , 256.0);
	ClientMessage("Dropped " $ dropAmount $ " rounds of " $ itemLabel $ ".");
}

defaultproperties
{
     CurrentUpgradeVersionMajor=2
     CurrentUpgradeVersionMinor=6
     CurrentUpgradeVersionBuild=1
     bJustTraveled=True
     MaximumAutosaves=1
     BackupSaveInterval=30
     bParanoidReload=True
     bRifleTracers=True
     bInvasionsEnabled=True
     CustomUIScale=1
     breathtime=2.000000
     breathSize=1.000000
     bIRCLocationInfo=True
     bIRCDeathInfo=True
     bAchievementNotifications=True
     bUnlockedAccessoryCoatGold=True
     strClaw="Claw"
     strBite="Bite"
     strGraySpit="Radioactive Spit"
     strSwipe="Swipe"
     strGreaselSpit="Toxic Spit"
     strKarkian="Charge"
     strCommandoGun="Commando Machine Gun"
     strCommandoRocket="Arm Mounted Rocket Tubes"
     strRobotGun="Machine Gun"
     strRobotRocket="Rocket Pods"
     strSpiderbot="Electrical Discharge"
     strAchievement="Achievement Unlocked:"
     bUnlockedTrack85=True
     stealthDifficulty=2
     stealth1ParTimeEasy=60.000000
     stealth2ParTimeEasy=35.000000
     stealth3ParTimeEasy=60.000000
     stealth4ParTimeEasy=45.000000
     stealth5ParTimeEasy=40.000000
     stealth6ParTimeEasy=25.000000
     stealth7ParTimeEasy=50.000000
     stealth8ParTimeEasy=100.000000
     stealth9ParTimeEasy=300.000000
     stealth1ParTimeNormal=25.000000
     stealth2ParTimeNormal=30.000000
     stealth3ParTimeNormal=55.000000
     stealth4ParTimeNormal=40.000000
     stealth5ParTimeNormal=35.000000
     stealth6ParTimeNormal=20.000000
     stealth7ParTimeNormal=45.000000
     stealth8ParTimeNormal=90.000000
     stealth9ParTimeNormal=220.000000
     stealth1ParTimeHard=20.000000
     stealth2ParTimeHard=25.000000
     stealth3ParTimeHard=50.000000
     stealth4ParTimeHard=35.000000
     stealth5ParTimeHard=30.000000
     stealth6ParTimeHard=15.000000
     stealth7ParTimeHard=40.000000
     stealth8ParTimeHard=80.000000
     stealth9ParTimeHard=180.000000
     combatMinigameDifficulty=2
     combat1ParTimeEasy=20.000000
     combat2ParTimeEasy=35.000000
     combat3ParTimeEasy=30.000000
     combat4ParTimeEasy=30.000000
     combat5ParTimeEasy=40.000000
     combat6ParTimeEasy=35.000000
     combat7ParTimeEasy=80.000000
     combat8ParTimeEasy=100.000000
     combat9ParTimeEasy=300.000000
     combat1ParTimeNormal=15.000000
     combat2ParTimeNormal=30.000000
     combat3ParTimeNormal=25.000000
     combat4ParTimeNormal=25.000000
     combat5ParTimeNormal=35.000000
     combat6ParTimeNormal=30.000000
     combat7ParTimeNormal=70.000000
     combat8ParTimeNormal=90.000000
     combat9ParTimeNormal=220.000000
     combat1ParTimeHard=12.000000
     combat2ParTimeHard=25.000000
     combat3ParTimeHard=20.000000
     combat4ParTimeHard=20.000000
     combat5ParTimeHard=30.000000
     combat6ParTimeHard=25.000000
     combat7ParTimeHard=60.000000
     combat8ParTimeHard=80.000000
     combat9ParTimeHard=180.000000
     tooexpensive="You do not have enough credits to make this purchase. You require %d credits and have only %d credits"
     querypurchasewindowtitle="Auto-Checkout 3000"
     querypurchasewindowtext="Do you wish to authorize a one-time payment of %d credits?"
     purchasedmessage="Transaction Approved - %d credits deducted"
     notpurchasedmessage="Transaction Cancelled"
     cantpurchasemessage="Transaction Denied - %d credits not available"
     lives=3
     rollincrementincrement=5.000000
     newFOV=750.000000
     fovincrementincrement=1.000000
     strstartintromap="tnmintro"
     strstartmapunrealistic="Platform_01"
     flySpeed=300
     LastBrowsedAugPage=-1
     LastBrowsedAug=-1
     eggs=19735
     bEggVisible=True
     blackiceDL="PM_BI_FailedHack"
     footprintoffset=8.000000
     molotovMsgNoRoom="You cannot fit a molotov cocktail in your inventory."
     defaultBurnTime=15.000000
     defaultBurnTimeMP=15.000000
     ItemRefusedString="You cannot pickup the %s due to your item-refusal settings. To change this, go to Settings > Controls > Item Refusal."
     PawnDifficulty=1
     PawnHealth=1.000000
     strEscapeSkip="Press ESCAPE to skip..."
     strBackupSave="Backup Save"
     strAutoSave="Autosave"
     strTryBuy="This item has already been bought"
     strNoMolotovMaterials="You lack enough chemicals for a molotov"
     strNoMolotovSkill="You lack the skill to make molotov cocktails"
     strNoMolotovWine="You need a wine bottle to make a molotov"
     strGoalUpdated="Goal Updated"
     strFireStaffDrop="Don't drop that, it's expensive!"
     strLockerPassword="Password to your weapon locker, #13."
     strAccountPin="Account number: 905279|nPin code: 2049"
     TooHotToLift="It's too hot to handle"
     msgKeyLocked="Your Password Reminder locked it"
     msgKeyUnlocked="Your Password Reminder unlocked it"
     msgNoNanoKey="Your Password Reminder doesn't have the right code"
     CountRemainingString="amount remaining:"
     CanCarryOnlyOneBinocs="You can only carry one %s, use the [Toggle Scope] key while empty-handed to use them"
     RainMultiplier=1.000000
     Platform_01_Unlocked=True
     mpGroundSpeed=320.000000
     mpWaterSpeed=180.000000
     TruePlayerName="Lawrence"
     Credits=0
     bBeltIsMPInventory=False
     strStartMap="20_phasapartment"
     InventoryFull="You don't have enough room in your inventory to pick up the %s, you require %sx%s."
     AddedNanoKey="%s added to passwords folder"
     CarcassType=Class'TNM.TrestkonCarcass'
     bNoFlash=False
     AccelRate=2048.000000
     Tag=Player
     Texture=Texture'DeusExItems.Skins.PinkMaskTex'
     Mesh=LodMesh'TNM.GM_Trestkon_Jumpsuit'
     MultiSkins(0)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(1)=Texture'TNM.Skins.TrestkonTex2'
     MultiSkins(2)=Texture'TNM.Skins.TrestkonTex1'
     MultiSkins(3)=Texture'TNM.Skins.TrestkonTex0'
     MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(5)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(6)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
     bBlockPlayers=False
     RotationRate=(Pitch=3072,Yaw=65000,Roll=2048)
     FamiliarName="Trestkon"
     UnfamiliarName="Trestkon"
     bAlwaysRelevant=True
}

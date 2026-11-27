//=============================================================================
// tnmGameInfo
// Original TNM 2.0 GameInfo by Off Topic Productions
// Co-op Campaign Authority, Host Per-Username Save Profiles & Flag Sync by bluehh (TM)
//=============================================================================
class tnmGameInfo extends GameInfo config(TNMCoopSave);

struct PathsEntry
{
    var string Path;
    var string Ext;
};

var PathsEntry Paths[32];
var int PathsNum;

var String OLPaths[32];
var int OLPathsNum;

var localized String UpdateMessage, UpdateRebootMessage;

var pawn playerkiller;

var bool bSavedThisTravel;
var bool bRestoredCoopSessionThisMap;
var bool bRestoredClientCreditsThisMap;
var bool bForceRestoreLoadout;
var bool bHasActiveTravelSession;
var bool bRestoreSavedPositions;

var Actor DeferActor[4];
var byte DeferMethod[4];
var Conversation DeferCon[4];
var byte DeferAvoid[4];
var byte DeferForce[4];
var Trestkon DeferPlayer[4];
var int NumDeferred;

// Co-op flag merge (see CoopMergeFlags)
var bool bCoopFlagMergeActive;
var Trestkon CoopFlagPeer[4];
var FlagBase CoopFlagBaseline[4];	// last state both host and peer agreed on
var FlagBase CoopFlagMirror[4];		// what the peer's own machine has been sent

// Co-op turret control (see CoopUpdateTurrets)
var AutoTurret CoopTurrets[64];
var byte CoopTurretMapDisabled[64];
var int NumCoopTurrets;
var bool bCoopTurretsSettled;
var CoopTurretSafeTarget CoopTurretDummy;

// Co-op radius conversations / flag merge cadence (see Tick)
var Actor CoopConActors[256];
var int NumCoopConActors;
var float CoopConListTimer;
var float CoopRadiusTimer;
var float CoopFlagMergeTimer;

// Co-op weapon stay pickups (see CoopNoteStayPickupTaken)
var Weapon CoopStayPickup[128];
var Pawn CoopStayTaker[512];		// 4 per pickup

// Co-op explosive decorations & robots tracking + blast deduplication
var Actor CoopExplosiveActors[128];
var vector CoopExplosiveLastLoc[128];
var float CoopExplosiveRadius[128];
var byte CoopExplosiveState[128];
var int NumCoopExplosives;
var float CoopExplosiveRefreshTimer;
var vector RecentBlastLoc[8];
var float RecentBlastTime[8];
var int RecentBlastHead;

var config bool bHasCoopSession;
var config string SavedCurrentURL;
var config string SavedBoolNames[4096];
var config byte SavedBoolVals[4096];
var config int SavedBoolExps[4096];
var config int SavedBoolCount;

var config string SavedByteNames[256];
var config byte SavedByteVals[256];
var config int SavedByteExps[256];
var config int SavedByteCount;

var config string SavedIntNames[1024];
var config int SavedIntVals[1024];
var config int SavedIntExps[1024];
var config int SavedIntCount;

var config string SavedFloatNames[256];
var config float SavedFloatVals[256];
var config int SavedFloatExps[256];
var config int SavedFloatCount;

var config string SavedNameNames[256];
var config string SavedNameVals[256];
var config int SavedNameExps[256];
var config int SavedNameCount;

var config string SavedGoalNames[64];
var config byte SavedGoalPrimary[64];
var config byte SavedGoalCompleted[64];
var config string SavedGoalText[64];
var config int SavedGoalCount;

var config string SavedNoteText[64];
var config byte SavedNoteUser[64];
var config string SavedNoteTag[64];
var config int SavedNoteCount;

var config string SavedKeyIDs[64];
var config string SavedKeyDescs[64];
var config int SavedKeyCount;

var config int SavedHostCredits;
var config int SavedClientCredits;
var config string SavedLastMap;

var config string SavedHostInvClass[64];
var config int SavedHostInvCount[64];
var config string SavedHostInvExtra[64];
var config int SavedHostInvTotal;
var config string SavedClientInvClass[64];
var config int SavedClientInvCount[64];
var config string SavedClientInvExtra[64];
var config int SavedClientInvTotal;
var config int SavedHostSkillLevels[32];
var config int SavedClientSkillLevels[32];
var config int SavedHostAugLevels[32];
var config int SavedClientAugLevels[32];
var config int SavedHostStats[10];
var config int SavedClientStats[10];
var config vector SavedHostLocation;
var config rotator SavedHostRotation;
var config vector SavedClientLocation;
var config rotator SavedClientRotation;

// Name-keyed player profiles (up to 4 named players saved in TNMCoopSave.ini)
var config string SavedProfileNames[4];
var config int SavedProfileInvTotal[4];
var config string SavedProfileInvClass[256];
var config int SavedProfileInvCount[256];
var config string SavedProfileInvExtra[256];
var config int SavedProfileSkillLevels[128];
var config int SavedProfileAugLevels[128];
var config int SavedProfileStats[40];
var config vector SavedProfileLocation[4];
var config rotator SavedProfileRotation[4];
var config string SavedProfileMap[4];

function RevivePlayerForTravel(Trestkon T)
{
	if (T == None)
		return;
	if (T.Health <= 0 || T.IsInState('Dying') || T.IsInState('Paralyzed'))
	{
		T.Health = 50;
		T.RestoreAllHealth();
		T.ExtinguishFire();
		T.bHidden = False;
		T.bDetectable = True;
		T.bIgnore = False;
		T.SetCollision(True, True, False);
		T.GotoState('PlayerWalking');
	}
}

function QueueDeferredConversation(Actor invokeActor, byte invokeMethod, Conversation con, bool bAvoidState, bool bForcePlay, Trestkon initiator)
{
	local int i;

	if (con == None && invokeActor == None)
		return;

	for (i = 0; i < NumDeferred; i++)
	{
		if ((con != None && DeferCon[i] == con) || (con == None && DeferActor[i] == invokeActor))
			return;
	}

	if (NumDeferred < ArrayCount(DeferActor))
	{
		DeferActor[NumDeferred] = invokeActor;
		DeferMethod[NumDeferred] = invokeMethod;
		DeferCon[NumDeferred] = con;
		if (bAvoidState)
			DeferAvoid[NumDeferred] = 1;
		else
			DeferAvoid[NumDeferred] = 0;
		if (bForcePlay)
			DeferForce[NumDeferred] = 1;
		else
			DeferForce[NumDeferred] = 0;
		DeferPlayer[NumDeferred] = initiator;
		NumDeferred++;
	}
}

function bool ShouldRespawn(Actor Other)
{
	if (Level.NetMode != NM_Standalone && Inventory(Other) != None)
	{
		Inventory(Other).ReSpawnTime = 999999.0;
		return true;
	}
	return false;
}

// ----------------------------
// DDL added stuff here
// -----------------------------

//
// Interrupt this for TNMPawns and inventory items
//
function bool IsRelevant( actor Other )
{
	local byte bSuperRelevant;
    local trestkon T;

	// let the mutators mutate the actor or choose to remove it
	if ( BaseMutator.AlwaysKeep(Other) )
		return true;
	if ( BaseMutator.IsRelevant(Other, bSuperRelevant) )
	{
		if ( bSuperRelevant == 1 ) // mutator wants to override any logic in here
			return true;
	}
	else return false;

	if
	(	
	// (Difficulty==0 && !Other.bDifficulty0 )
	// ||  (Difficulty==1 && !Other.bDifficulty1 )
	// ||  (Difficulty==2 && !Other.bDifficulty2 )
	// ||  (Difficulty==3 && !Other.bDifficulty3 )
	// ||  
	(!Other.bSinglePlayer) )
		return False;

	if( bNoMonsters && (Pawn(Other) != None) && !Pawn(Other).bIsPlayer )
		return False;

	if( FRand() > Other.OddsOfAppearing )
		return False;

	return true; // Trestkon can handle filtering from here
	
    // if(!Other.isA('TNMPawn') && !Other.isA('Inventory') && !other.isA('containers'))
		// return super.IsRelevant(Other);
	// else
		// return true;

	// else //do nothing for now, since the player travel vars probably won't intialise fast enough
	// {
	   // return true;
	   /*
	   T = trestkon(getplayerPawn());


       if(T != none)
       {
    	   //safety check for non initialised vars


           if(T.PawnDifficulty == 199)
    	   {
               return true;
           }
           else //it got initialised! Yay!
           {
               T.bFiltered = true;
           }

           if(Other.IsA('TNMPawn'))
    	   {
    	       if
    	       (	(T.PawnDifficulty==0 && !Other.bDifficulty0 )
    	       ||  (T.PawnDifficulty==1 && !Other.bDifficulty1 )
    	       ||  (T.PawnDifficulty==2 && !Other.bDifficulty2 )
    	       ||  (T.PawnDifficulty==3 && !Other.bDifficulty3 ))
    	           return false;
    	       else
    	           return true; //fuck it
    	   }
    	   else if(Other.IsA('Inventory'))
    	   {
    	       if
    	       (	(T.ItemDifficulty==0 && !Other.bDifficulty0 )
    	       ||  (T.ItemDifficulty==1 && !Other.bDifficulty1 )
    	       ||  (T.ItemDifficulty==2 && !Other.bDifficulty2 )
    	       ||  (T.ItemDifficulty==3 && !Other.bDifficulty3 ))
    	           return false;
    	       else
    	           return true; //fuck it
    	   }
    	   else
    	       return true;
    	}
    	else
    	{
    	   return true;
    	} */
	// }
}

//
// Hahahahah hackity hack hack mcgee!
//
function int ReduceDamage( int Damage, name DamageType, pawn injured, pawn instigatedBy )
{
    if (injured != None && instigatedBy != None && injured != instigatedBy && injured.IsA('Trestkon') && instigatedBy.IsA('Trestkon'))
        return 0;

    if(instigatedby != none)
    {
		if (instigatedby.IsA('Trestkon'))
		{
			return damage * trestkon(instigatedby).PawnHealth;
		}
    }

    return super.ReduceDamage(damage, damagetype, injured, instigatedby);
}

// ----------------------------------------------------------------------
// Login()
// ----------------------------------------------------------------------

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local DeusExPlayer player;
	local NavigationPoint StartSpot;
	local byte InTeam;
	local DumpLocation dump;
	local Pawn P;
	local string inCoopName;

   //DEUS_EX AMSD In non multiplayer games, force JCDenton.

   spawnclass=class'trestkon';

	if (InStr(Portal, "?") != -1)
		Portal = Left(Portal, InStr(Portal, "?"));

	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		if (P.IsA('Trestkon'))
			P.SetCollision(False, False, False);
	}

	player = DeusExPlayer(Super.Login(Portal, Options, Error, SpawnClass));

	if (Trestkon(player) != None)
	{
		inCoopName = class'CoopLocalPrefs'.static.DecodeURLName(ParseOption(Options, "Name"));
		if (inCoopName != "" && Caps(inCoopName) != "PLAYER")
		{
			Trestkon(player).coopPlayerName = inCoopName;
			Trestkon(player).FamiliarName = inCoopName;
			Trestkon(player).UnfamiliarName = inCoopName;
			if (player.PlayerReplicationInfo != None)
				player.PlayerReplicationInfo.PlayerName = inCoopName;
		}
		else if (Viewport(player.Player) != None)
		{
			inCoopName = Trestkon(player).GetLocalCoopPlayerName();
			if (inCoopName != "")
			{
				Trestkon(player).coopPlayerName = inCoopName;
				Trestkon(player).FamiliarName = inCoopName;
				Trestkon(player).UnfamiliarName = inCoopName;
				if (player.PlayerReplicationInfo != None)
					player.PlayerReplicationInfo.PlayerName = inCoopName;
			}
		}
	}

	// If we're traveling across a map on the same mission,
	// nuke the player's crap and

	if ((player != None) && (!HasOption(Options, "Loadgame")))
	{
		player.ResetPlayerToDefaults();

		dump = player.CreateDumpLocationObject();

		if ((dump != None) && (dump.HasLocationBeenSaved()) && (Level.NetMode == NM_Standalone))
		{
			dump.LoadLocation();

			player.Pause();
			player.SetLocation(dump.currentDumpLocation.Location);
			player.SetRotation(dump.currentDumpLocation.ViewRotation);
			player.ViewRotation = dump.currentDumpLocation.ViewRotation;
			player.ClientSetRotation(dump.currentDumpLocation.ViewRotation);

			CriticalDelete(dump);
		}
		else
		{
			InTeam    = GetIntOption( Options, "Team", 0 ); // Multiplayer now, defaults to Team_Unatco=0
         if (Level.NetMode == NM_Standalone)
            StartSpot = FindPlayerStart( None, InTeam, Portal );
         else
            StartSpot = FindPlayerStart( Player, InTeam, Portal );

			if (StartSpot != None)
			{
				player.SetLocation(StartSpot.Location);
				player.SetRotation(StartSpot.Rotation);
				player.ViewRotation = StartSpot.Rotation;
				player.ClientSetRotation(player.Rotation);
			}
		}
	}

	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		if (P.IsA('Trestkon'))
			P.SetCollision(True, True, False);
	}
	if (player != None)
		player.SetCollision(True, True, False);

	return player;
}

// ----------------------------------------------------------------------
// DiscardInventory()
// ----------------------------------------------------------------------

function DiscardInventory( Pawn Other )
{
	// do nothing
}

// ----------------------------------------------------------------------
// ScoreKill()
// ----------------------------------------------------------------------

function ScoreKill(pawn Killer, pawn Other)
{
	// do nothing
}

function Killed( pawn Killer, pawn Other, name damageType )
{
	local tnmmissionscript ms;
	
	if(ScriptedPawn(Other) != None)
		foreach AllActors(class'tnmmissionscript', ms)
			ms.PawnKilled(other, killer);
	else if(PlayerPawn(Other) != None)
		foreach AllActors(class'tnmmissionscript', ms)
			ms.PlayerKilled(other, killer);
	
	if (Trestkon(Other) != None)
		playerkiller = killer;

	if ((Trestkon(Other) != None) && (Level.NetMode != NM_Standalone))
		CoopAbortConversationsFor(Trestkon(Other));

	Super.Killed(killer, other, damagetype);
}

// A player dying mid-conversation left the conversation (and the NPC's
// 'Conversation' state) orphaned or marked as played. End it without setting
// the played flag so it can be started again.
function CoopAbortConversationsFor(Trestkon Victim)
{
	local Pawn P;
	local Trestkon T;

	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		T = Trestkon(P);
		if ((T == None) || (T.conPlay == None))
			continue;
		if ((T == Victim) || ((tnmConPlay(T.conPlay) != None) && (tnmConPlay(T.conPlay).ResolveCoopPlayer() == Victim)))
			T.conPlay.TerminateConversation(False, True);
	}
}

// Picking up a decoration turns its collision off; a player disconnecting while
// carrying one left it floating and intangible.
function Logout(Pawn Exiting)
{
	local DeusExPlayer DXP;
	local Decoration Deco;

	DXP = DeusExPlayer(Exiting);
	if ((DXP != None) && (DXP.CarriedDecoration != None))
	{
		Deco = DXP.CarriedDecoration;
		DXP.DropDecoration();
		if ((Deco != None) && !Deco.bDeleteMe && (DXP.CarriedDecoration == Deco))
		{
			DXP.CarriedDecoration = None;
			Deco.SetBase(None);
			Deco.bCollideWorld = Deco.Default.bCollideWorld;
			Deco.SetCollision(Deco.Default.bCollideActors, Deco.Default.bBlockActors, Deco.Default.bBlockPlayers);
			Deco.SetPhysics(PHYS_Falling);
		}
	}

	if (Trestkon(Exiting) != None && Level.NetMode != NM_Standalone)
	{
		SaveNamedCoopProfile(Trestkon(Exiting), True);
		StaticSaveConfig();
	}

	Super.Logout(Exiting);
}

// ----------------------------------------------------------------------
// ClientPlayerPossessed()
// ----------------------------------------------------------------------
function ClientPlayerPossessed(PlayerPawn CheckPlayer)
{
	CheckPlayerWindow(CheckPlayer);
	CheckPlayerConsole(CheckPlayer);
}

// ----------------------------------------------------------------------
// CheckPlayerWindow()
// ----------------------------------------------------------------------
function CheckPlayerWindow(PlayerPawn CheckPlayer)
{
	// do nothing.
}

// ----------------------------------------------------------------------
// CheckPlayerConsole()
// ----------------------------------------------------------------------
function CheckPlayerConsole(PlayerPawn CheckPlayer)
{
	// do nothing.
}

// ----------------------------------------------------------------------
// FailRootWindowCheck()
// ----------------------------------------------------------------------
function FailRootWindowCheck(PlayerPawn FailPlayer)
{
	// do nothing
}

// ----------------------------------------------------------------------
// FailConsoleCheck()
// ----------------------------------------------------------------------
function FailConsoleCheck(PlayerPawn FailPlayer)
{
	// do nothing
}

// ----------------------------------------------------------------------
// InitGame()
//
// Initialize the game.
// warning: this is called before actors' PreBeginPlay.
// Bjorn: Fixing broken filtering that was in vanilla...
// ----------------------------------------------------------------------
event InitGame( string Options, out string Error )
{
	local string InOpt;
	local float TempDifficulty;
	local string PathsString;
	local bool bCustomDifficulty;
	local int CDItemQuantity, CDAIQuantity;
	local DeusExLevelInfo dxInfo;
	local TNMOggMusicManager ogg;
	local ScriptedPawn SP;
	local HackableDevices HDev;
	
	PathsString = ConsoleCommand( "GET LaunchSystem Paths" );
		
	Super.InitGame(Options, Error);
	
	BaseMutator.AddMutator(Spawn(class'TNM.TNMMutatorGeneric'));

	foreach AllActors(class'DeusExLevelInfo', dxInfo)
	{
		dxInfo.bAlwaysRelevant = True;
		dxInfo.RemoteRole = ROLE_SimulatedProxy;
	}

	foreach AllActors(class'TNMOggMusicManager', ogg)
	{
		ogg.bAlwaysRelevant = True;
		ogg.RemoteRole = ROLE_SimulatedProxy;
	}

	if (Level.NetMode != NM_Standalone)
	{
		foreach AllActors(class'ScriptedPawn', SP)
		{
			SP.bTickVisibleOnly = False;
		}
		foreach AllActors(class'HackableDevices', HDev)
		{
			// Prevent Deathmatch 30-second auto-relock on hacked keypads & control panels
			HDev.TimeToReset = 99999999.0;
		}
		CoopRefreshTurretList(True);
		CoopRefreshExplosivesList();
		CoopReplaceTriggers();
	}
	
	//Bjorn: We need to convert the CombatDifficulty to match the Difficulty var that the engine uses for filter out stuff on difficulty.
	//Just converting the CombatDifficulty to an int WILL NOT WORK!
	// InOpt = ParseOption( Options, "Difficulty" );
	// if( InOpt != "" )
		// TempDifficulty = float(InOpt);
	
	// if (TempDifficulty == 1.0)
		// Difficulty = 0;
	// else if (TempDifficulty == 1.5)
		// Difficulty = 1;
	// else if (TempDifficulty == 2.0)
		// Difficulty = 2;
	// else if (TempDifficulty == 4.0)
		// Difficulty = 3;
}

function NavigationPoint FindPlayerStart( Pawn Player, optional byte InTeam, optional string incomingName )
{
	local NavigationPoint nav;
	local PlayerStart ps;

	if (InStr(incomingName, "?") != -1)
		incomingName = Left(incomingName, InStr(incomingName, "?"));

	nav = Super.FindPlayerStart(Player, InTeam, incomingName);
	if (nav != None)
		return nav;

	foreach AllActors( class 'PlayerStart', ps )
		return ps;

	foreach AllActors( class 'NavigationPoint', nav )
		return nav;

	return None;
}

event PostLogin(playerpawn NewPlayer)
{
	local TrestkonDummy dummy;
	local TNMWeapon TNMWeap;
	local Ammo anammo;
	local Inventory anitem;
    local Trestkon player;
    local TNMMenuUICommandMessageBoxWindow msgBox;
    local bool NeedsReboot;
    local bool DidUpdate;
    local PathsEntry newSetting;
    local string NewSavePath;
    local string NewPathString;
	local TNMOggMusicManager ogg;
	
	Super.PostLogin(NewPlayer);

    player = Trestkon(NewPlayer);
	if (player != None)
	{
		RevivePlayerForTravel(player);
		player.SetCollision(player.bCollideActors, player.bBlockActors, False);
		if (player.PlayerFists == None && player.FindInventoryType(class'WeaponFists') == None)
			player.InitCoopStartingGear();
		if (Level.NetMode != NM_Standalone)
		{
			RestoreCoopSessionFromDefaults(player);
			if (NetConnection(player.Player) != None)
			{
				foreach AllActors(class'TNMOggMusicManager', ogg)
				{
					if (ogg.RepActiveLoopOgg != "")
						player.ClientPlayOgg(ogg.RepActiveIntroOgg, ogg.RepActiveLoopOgg, ogg.bShouldPlayStereo);
					else if (ogg.Ambient1OggFile != "")
						player.ClientPlayOgg(ogg.Ambient1IntroOggFile, ogg.Ambient1OggFile, False);
					break;
				}
			}
		}
	}
	if (Level.NetMode != NM_Standalone)
	{
		CoopUpdateTurrets();
		SyncCoopState();
		SetTimer(1.0, True);
	}
	
	if (DeusExPlayer(NewPlayer) != None)
	{
		ApplyGamemode(DeusExPlayer(NewPlayer));
		
		foreach AllActors(class'TrestkonDummy', dummy)
		{
			dummy.SetSkin(Trestkon(NewPlayer));
		}
		
		if (Trestkon(NewPlayer) != None && Trestkon(NewPlayer).counteggs() < 16)
		{
			foreach AllActors(class'Ammo', anammo)
			{
				if (anammo.IsA('AmmoBlowDartExplosive') && anammo.owner == None)
				{
					anammo.Destroy();
				}
			}
			foreach AllActors(class'Inventory', anitem)
			{
				if (anitem.IsA('FistPickupBan') && anitem.owner == None)
				{
					anitem.Destroy();
				}
			}
		}
		
		// foreach AllActors(class'TNMWeapon', TNMWeap)
		// {
			// TNMWeap.RollForLegendary();
			// TNMWeap.ApplyAttribute();
			
			// TNMWeap.bAttributeApplied = True;
		// }

        //Do config upgrades.
        if ((player.CurrentUpgradeVersionMajor < player.REVISION_VERSION_MAJOR ||
            player.CurrentUpgradeVersionMinor < player.REVISION_VERSION_MINOR ||
            player.CurrentUpgradeVersionBuild < player.REVISION_VERSION_BUILD ||
            player.CurrentUpgradeVersionRevision < player.REVISION_VERSION_REVISION) 
			&& player.rootwindow != None)
        {
            //Do the 2.6 update.
            if (player.CurrentUpgradeVersionMajor <= 2 && player.CurrentUpgradeVersionMinor < 6)
            {
				LoadPaths(Player);
				newSetting.Path = "..\\..\\..\\..\\workshop\\content\\397550\\3250806376\\OldMaps\\";
				newSetting.Ext = "dx";
				AddPathToTop(newSetting);
				newSetting.Path = "..\\OldMaps\\";
				newSetting.Ext = "dx";
				AddPathToTop(newSetting);
				NewPathString = GeneratePathString();
                player.ConsoleCommand("SET System Paths" @ NewPathString);
				if (GetConfig("Engine.Engine", "GameEngine") != "DeusEx.DeusExGameEngine")
					class'TNMGameEngineFudger'.Static.SetNewGameEngine("DeusEx.DeusExGameEngine");
                NeedsReboot = True;
                DidUpdate = True;
            }

            player.CurrentUpgradeVersionMajor = player.REVISION_VERSION_MAJOR;
            player.CurrentUpgradeVersionMinor = player.REVISION_VERSION_MINOR;
            player.CurrentUpgradeVersionBuild = player.REVISION_VERSION_BUILD;
            player.CurrentUpgradeVersionRevision = player.REVISION_VERSION_REVISION;
            player.SaveConfig();

            if (DidUpdate)
            {
                if (NeedsReboot)
                {
                    msgBox = TNMMenuUICommandMessageBoxWindow(CustomMessageBox(Class'TNMMenuUICommandMessageBoxWindow', "Notice", UpdateRebootMessage, 1, False, None, True, player));
                    msgBox.ConsoleCommands[0] = "RELAUNCH -NEWWINDOW";
                }
                else
                    msgBox = TNMMenuUICommandMessageBoxWindow(CustomMessageBox(Class'TNMMenuUICommandMessageBoxWindow', "Notice", UpdateMessage, 1, False, None, True, player));

                msgBox.SetNotifyWindow(msgBox);
            }
		}
	}
}

function MenuUIMessageBoxWindow CustomMessageBox
(
    Class<MenuUIMessageBoxWindow> MsgBoxClass,
    String MsgTitle,
    String MsgText,
    int MsgBoxMode,
    bool bHideCurrentScreen,
    Window WinNotify,
    optional bool bTopHack,
	optional DeusExPlayer aPlayer
)
{
    local DeusExBaseWindow Temp;
    local MenuUIMessageBoxWindow MsgBox;

    MsgBox = MenuUIMessageBoxWindow(DeusExRootWindow(aPlayer.rootWindow).PushWindow(MsgBoxClass, bHideCurrentScreen));

    if (MsgBox != None)
    {
        // Exchange the two topmost windows.
        if (bTopHack && DeusExRootWindow(aPlayer.rootWindow).winCount >= 2)
        {
            Temp                 = DeusExRootWindow(aPlayer.rootWindow).winStack[DeusExRootWindow(aPlayer.rootWindow).winCount-1];
            DeusExRootWindow(aPlayer.rootWindow).winStack[DeusExRootWindow(aPlayer.rootWindow).winCount-1] = DeusExRootWindow(aPlayer.rootWindow).winStack[DeusExRootWindow(aPlayer.rootWindow).winCount-2];
            DeusExRootWindow(aPlayer.rootWindow).winStack[DeusExRootWindow(aPlayer.rootWindow).winCount-2] = Temp;
        }

        if (MsgTitle != "")
            MsgBox.SetTitle(MsgTitle);
        if (MsgText != "")
            MsgBox.SetMessageText(MsgText);

        MsgBox.SetMode(MsgBoxMode);
        MsgBox.SetNotifyWindow(WinNotify);
    }
    return MsgBox;
}

function ApplyGamemode(DeusExPlayer player)
{
	local Trestkon 					localPlayer;
	local Light 					light;
	local BarrelFire 				BarrelFire;

	localPlayer = Trestkon(player);

	if (localPlayer != None)
	{
		if (localPlayer.bEpilepsyReduction) // Disable all flickering lights.
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
}

function bool RestartPlayer( pawn aPlayer )
{
	local Pawn P;
	local bool bResult;

	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		if (P != aPlayer && P.IsA('Trestkon'))
			P.SetCollision(False, False, False);
	}

	bResult = Super.RestartPlayer(aPlayer);

	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		if (P.IsA('Trestkon'))
			P.SetCollision(True, True, False);
	}
	if (aPlayer != None)
		aPlayer.SetCollision(True, True, False);

	if (Trestkon(aPlayer) != None)
	{
		Trestkon(aPlayer).bDetectable = True;
		Trestkon(aPlayer).bIgnore = False;
		Trestkon(aPlayer).RestoreAllHealth();
		Trestkon(aPlayer).ExtinguishFire();
		Trestkon(aPlayer).InitCoopStartingGear();
		if (Level.NetMode != NM_Standalone)
			SyncCoopState();
	}

	return bResult;
}

function ProcessServerTravel( string URL, bool bItems )
{
	local PlayerPawn P, LocalPlayer;
	local string PortalSuffix, BaseURL, ExtraOpts;
	local int hashPos;
	local MissionScript ms;

	if (LocalLog != None)
	{
		LocalLog.LogGameEnd("mapchange");
		LocalLog.StopLog();
		LocalLog.Destroy();
		LocalLog = None;
	}

	if (WorldLog != None)
	{
		WorldLog.LogGameEnd("mapchange");
		WorldLog.StopLog();
		WorldLog.Destroy();
		WorldLog = None;
	}

	log("ProcessServerTravel:"@URL);
	if (!bSavedThisTravel)
	{
		SyncCoopState();
		foreach AllActors(class'MissionScript', ms)
		{
			if (ms.flags != None)
				ms.PreTravel();
			ms.SetTimer(0.0, False);
			ms.flags = None;
			ms.Player = None;
			ms.dxInfo = None;
			ms.SetPropertyText("launcher", "None");
			ms.Destroy();
		}
		foreach AllActors(class'PlayerPawn', P)
		{
			if (Trestkon(P) != None)
			{
				RevivePlayerForTravel(Trestkon(P));
				if (NetConnection(P.Player) != None)
					Trestkon(P).ClientPrepareTravel();
				else if (DeusExRootWindow(Trestkon(P).rootWindow) != None)
					DeusExRootWindow(Trestkon(P).rootWindow).ClearWindowStack();
				Trestkon(P).bStartingNewGame = True;
				Trestkon(P).PreTravel();
			}
		}
		SaveCoopSessionToDefaults(URL);
		bSavedThisTravel = True;
	}
	else
	{
		// Refresh player profiles & ammo counts right at final map departure in case
		// items/ammo changed during Level.NextSwitchCountdown after SendPlayer().
		if (Level.NetMode != NM_Standalone && !default.bForceRestoreLoadout)
		{
			foreach AllActors(class'PlayerPawn', P)
			{
				if (Trestkon(P) != None)
				{
					SaveNamedCoopProfile(Trestkon(P), False);
					if (NetConnection(P.Player) != None)
					{
						default.SavedClientCredits = Trestkon(P).Credits;
						SavePlayerLoadoutToDefaults(Trestkon(P), True);
					}
					else
					{
						default.SavedHostCredits = Trestkon(P).Credits;
						SavePlayerLoadoutToDefaults(Trestkon(P), False);
					}
				}
			}
			StaticSaveConfig();
			class'CoopSaveSlotManager'.static.CopyActiveSessionToSlot(class'CoopSaveSlotManager'.static.GetActiveSlot());
		}
		foreach AllActors(class'MissionScript', ms)
		{
			ms.SetTimer(0.0, False);
			ms.flags = None;
			ms.Player = None;
			ms.dxInfo = None;
			ms.SetPropertyText("launcher", "None");
			ms.Destroy();
		}
	}

	foreach AllActors( class'PlayerPawn', P )
		if( NetConnection(P.Player)!=None )
			P.ClientTravel( URL, TRAVEL_Relative, bItems );
		else
		{
			LocalPlayer = P;
			if (DeusExPlayer(P) != None)
				DeusExPlayer(P).bStartingNewGame = True;
			P.PreClientTravel();
		}

	if ( (Level.NetMode == NM_ListenServer) && (LocalPlayer != None) )
	{
		ExtraOpts = "?Skin="$LocalPlayer.GetDefaultURL("Skin")
			$"?Face="$LocalPlayer.GetDefaultURL("Face")
			$"?Team="$LocalPlayer.GetDefaultURL("Team")
			$"?Name="$class'CoopLocalPrefs'.static.EncodeURLName(Trestkon(LocalPlayer).GetLocalCoopPlayerName())
			$"?Class="$LocalPlayer.GetDefaultURL("Class");
		hashPos = InStr(Level.NextURL, "#");
		if (hashPos != -1)
		{
			BaseURL = Left(Level.NextURL, hashPos);
			PortalSuffix = Mid(Level.NextURL, hashPos);
			Level.NextURL = BaseURL $ ExtraOpts $ PortalSuffix;
		}
		else
		{
			Level.NextURL = Level.NextURL $ ExtraOpts;
		}
	}

	if( Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
		Level.NextSwitchCountdown = 0.0;
	else
		Level.NextSwitchCountdown = FMax(Level.NextSwitchCountdown, 2.5);	// ClientTravel is queued behind other reliable traffic
}

function Timer()
{
	Super.Timer();
	if (Level.NetMode != NM_Standalone)
		SyncCoopState();
}

function SyncCoopState()
{
	local Pawn P1, P2;
	local Trestkon Src, Dst, T, HostPlayer, dPlayer;
	local DeusExMover M;
	local HackableDevices H;
	local ScriptedPawn SP;
	local int packedFlags, i, spSyncCount;
	local Actor dActor;
	local byte dMethod;
	local Conversation dCon;
	local bool dAvoid, dForce;
	local TNMOggMusicManager ogg;
	local tnmDataLinkPlay dlp;

	HostPlayer = Trestkon(GetPlayerPawn());
	if (HostPlayer != None && NumDeferred > 0 && HostPlayer.conPlay == None && HostPlayer.dataLinkPlay == None)
	{
		dActor = DeferActor[0];
		dMethod = DeferMethod[0];
		dCon = DeferCon[0];
		dAvoid = (DeferAvoid[0] != 0);
		dForce = (DeferForce[0] != 0);
		dPlayer = DeferPlayer[0];

		for (i = 0; i < NumDeferred - 1; i++)
		{
			DeferActor[i] = DeferActor[i + 1];
			DeferMethod[i] = DeferMethod[i + 1];
			DeferCon[i] = DeferCon[i + 1];
			DeferAvoid[i] = DeferAvoid[i + 1];
			DeferForce[i] = DeferForce[i + 1];
			DeferPlayer[i] = DeferPlayer[i + 1];
		}
		DeferActor[NumDeferred - 1] = None;
		DeferCon[NumDeferred - 1] = None;
		DeferPlayer[NumDeferred - 1] = None;
		NumDeferred--;

		if (dActor != None)
			dActor.LastConEndTime = 0;

		if (dPlayer != None && !dPlayer.bDeleteMe)
			dPlayer.StartConversationByByteMethod(dActor, dMethod, dCon, dAvoid, dForce);
		else
			HostPlayer.StartConversationByByteMethod(dActor, dMethod, dCon, dAvoid, dForce);
	}

	if (HostPlayer != None)
		CoopMergeFlags(HostPlayer);
	CoopRefreshTurretList(False);

	for (P1 = Level.PawnList; P1 != None; P1 = P1.NextPawn)
	{
		Src = Trestkon(P1);
		if (Src == None)
			continue;

		Src.CheckServerAugCanConsumption();
		if (NetConnection(Src.Player) != None)
		{
			if (!Src.bCoopNamedProfileRestored && Src.coopPlayerName != "")
				RestoreNamedCoopProfile(Src, Src.coopPlayerName);
			Src.CoopSyncWeaponMods();
		}

		for (P2 = Level.PawnList; P2 != None; P2 = P2.NextPawn)
		{
			Dst = Trestkon(P2);
			if (Dst == None || Dst == Src)
				continue;

			Dst.SyncFromPlayer(Src);
		}

		if (NetConnection(Src.Player) != None)
		{
			foreach AllActors(class'TNMOggMusicManager', ogg)
			{
				if (ogg.RepActiveLoopOgg != "")
					Src.ClientPlayOgg(ogg.RepActiveIntroOgg, ogg.RepActiveLoopOgg, ogg.bShouldPlayStereo);
				break;
			}
			if (HostPlayer != None)
			{
				dlp = tnmDataLinkPlay(HostPlayer.dataLinkPlay);
				if (dlp != None && dlp.dataLink != None && dlp.activeSpeakerName != "")
					Src.ClientShowSubtitle("[InfoLinkSync]|" $ dlp.activeSpeakerName, dlp.activeSpeechText, False);
			}
			foreach RadiusActors(class'DeusExMover', M, 600.0, Src.Location)
			{
				packedFlags = 0;
				if (M.bLocked)    packedFlags = packedFlags | 1;
				if (M.bPickable)  packedFlags = packedFlags | 2;
				if (M.bBreakable) packedFlags = packedFlags | 4;
				if (M.bFrobbable) packedFlags = packedFlags | 8;
				if (M.bHighlight) packedFlags = packedFlags | 16;
				if (M.bDestroyed) packedFlags = packedFlags | 32;
				if (Src.CoopDeviceChanged(M.Name, packedFlags | (int(M.lockStrength * 1000) << 6) | (int(M.doorStrength * 1000) << 17)))
					Src.ClientSyncMoverState(M.Name, packedFlags, M.lockStrength, M.doorStrength);
			}
			foreach RadiusActors(class'HackableDevices', H, 600.0, Src.Location)
			{
				packedFlags = 0;
				if (H.bHackable)  packedFlags = packedFlags | 1;
				if (H.bHighlight) packedFlags = packedFlags | 4;
				if (Src.CoopDeviceChanged(H.Name, packedFlags | (int(H.hackStrength * 1000) << 3)))
					Src.ClientSyncHackableState(H.Name, packedFlags, H.hackStrength);
			}
			spSyncCount = 0;
			foreach RadiusActors(class'ScriptedPawn', SP, 2500.0, Src.Location)
			{
				SP.bTickVisibleOnly = False;
				if (int(SP.GetPawnAllianceType(Src)) == 2 || VSize(SP.Location - Src.Location) < 1000.0)
				{
					if (!Src.CoopDeviceChanged(SP.Name, 1000 + int(SP.GetPawnAllianceType(Src))))
						continue;
					Src.ClientSyncHackableState(SP.Name, int(SP.GetPawnAllianceType(Src)), -999.0);
					spSyncCount++;
					if (spSyncCount >= 10)
						break;
				}
			}
		}
	}
}

// ----------------------------------------------------------------------
// Co-op flag merge
//
// Each player has its own flagBase on the server. The old sync only ever copied
// True (and non-zero ints) between them, in both directions, so a flag a script
// cleared on one player was set again from the other player's copy a second
// later. This is a three-way merge against the last agreed state: whichever
// side changed a flag since then wins, the host wins a conflict.
// ----------------------------------------------------------------------

function bool CoopFlagExcluded(Name flagName)
{
	local string s;

	if (flagName == 'PlayerTraveling')
		return True;
	s = string(flagName);
	if (Left(s, 3) ~= "CS_")
		return True;
	if (Left(s, 7) ~= "SKTemp_")
		return True;
	return False;
}

function int CoopFindFlagPeer(Trestkon Peer)
{
	local int i, freeSlot;

	freeSlot = -1;
	for (i = 0; i < ArrayCount(CoopFlagPeer); i++)
	{
		if (CoopFlagPeer[i] == Peer)
			return i;
		if ((freeSlot == -1) && ((CoopFlagPeer[i] == None) || CoopFlagPeer[i].bDeleteMe))
			freeSlot = i;
	}
	if (freeSlot == -1)
		return -1;

	CoopFlagPeer[freeSlot] = Peer;
	CoopFlagBaseline[freeSlot] = None;
	CoopFlagMirror[freeSlot] = None;
	return freeSlot;
}

function CoopMergeFlags(Trestkon Host, optional bool bSkipMirror)
{
	local Pawn P;
	local Trestkon Peer;
	local int i;
	local bool bSeed;

	if ((Host == None) || (Host.flagBase == None))
		return;

	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		Peer = Trestkon(P);
		if ((Peer == None) || (Peer == Host) || (Peer.flagBase == None) || Peer.bDeleteMe)
			continue;

		i = CoopFindFlagPeer(Peer);
		if (i == -1)
			continue;

		bSeed = False;
		if (CoopFlagBaseline[i] == None)
		{
			CoopFlagBaseline[i] = new(None) class'FlagBase';
			if (CoopFlagBaseline[i] == None)
				continue;
			bSeed = True;
		}
		bCoopFlagMergeActive = True;

		CoopMergeBoolFlags(Host.flagBase, Peer.flagBase, CoopFlagBaseline[i], bSeed);
		CoopMergeIntFlags(Host.flagBase, Peer.flagBase, CoopFlagBaseline[i], bSeed);
		CoopMergeNameFlags(Host.flagBase, Peer.flagBase, CoopFlagBaseline[i], bSeed);

		if (!bSkipMirror && (NetConnection(Peer.Player) != None))
		{
			if (CoopFlagMirror[i] == None)
				CoopFlagMirror[i] = new(None) class'FlagBase';
			if (CoopFlagMirror[i] != None)
				CoopMirrorBoolFlags(Peer, CoopFlagMirror[i]);
		}
	}
}

// bSeed: first merge on this map. The host wins every difference, flags only
// the peer has are added to the host.
function CoopMergeBoolFlags(FlagBase H, FlagBase C, FlagBase B, bool bSeed)
{
	local int it, i, nToHost, nToPeer;
	local Name flagName;
	local bool hVal, cVal;
	local Name toHostName[128], toPeerName[128];
	local byte toHostVal[128], toPeerVal[128];
	local int toHostExp[128], toPeerExp[128];

	it = H.CreateIterator(FLAG_Bool);
	while (H.GetNextFlagName(it, flagName))
	{
		if (CoopFlagExcluded(flagName))
			continue;
		hVal = H.GetBool(flagName);
		cVal = C.GetBool(flagName);
		if (hVal == cVal)
		{
			if (!B.CheckFlag(flagName, FLAG_Bool) || (B.GetBool(flagName) != hVal))
				B.SetBool(flagName, hVal, True, 0);
		}
		else if (bSeed || (hVal != B.GetBool(flagName)))
		{
			if (nToPeer >= ArrayCount(toPeerName))
				break;
			toPeerName[nToPeer] = flagName;
			toPeerVal[nToPeer] = byte(hVal);
			toPeerExp[nToPeer] = H.GetExpiration(flagName, FLAG_Bool);
			nToPeer++;
		}
		else
		{
			if (nToHost >= ArrayCount(toHostName))
				break;
			toHostName[nToHost] = flagName;
			toHostVal[nToHost] = byte(cVal);
			toHostExp[nToHost] = C.GetExpiration(flagName, FLAG_Bool);
			nToHost++;
		}
	}
	H.DestroyIterator(it);

	// flags the host doesn't have at all (treated as False on the host)
	it = C.CreateIterator(FLAG_Bool);
	while (C.GetNextFlagName(it, flagName))
	{
		if (CoopFlagExcluded(flagName) || H.CheckFlag(flagName, FLAG_Bool))
			continue;
		cVal = C.GetBool(flagName);
		if (!cVal)
		{
			if (!B.CheckFlag(flagName, FLAG_Bool) || B.GetBool(flagName))
				B.SetBool(flagName, False, True, 0);
		}
		else if (!bSeed && B.GetBool(flagName))
		{
			if (nToPeer >= ArrayCount(toPeerName))
				break;
			toPeerName[nToPeer] = flagName;
			toPeerVal[nToPeer] = 0;
			toPeerExp[nToPeer] = C.GetExpiration(flagName, FLAG_Bool);
			nToPeer++;
		}
		else
		{
			if (nToHost >= ArrayCount(toHostName))
				break;
			toHostName[nToHost] = flagName;
			toHostVal[nToHost] = 1;
			toHostExp[nToHost] = C.GetExpiration(flagName, FLAG_Bool);
			nToHost++;
		}
	}
	C.DestroyIterator(it);

	for (i = 0; i < nToPeer; i++)
	{
		C.SetBool(toPeerName[i], bool(toPeerVal[i]), True, toPeerExp[i]);
		B.SetBool(toPeerName[i], bool(toPeerVal[i]), True, 0);
	}
	for (i = 0; i < nToHost; i++)
	{
		H.SetBool(toHostName[i], bool(toHostVal[i]), True, toHostExp[i]);
		B.SetBool(toHostName[i], bool(toHostVal[i]), True, 0);
	}
}

function CoopMergeIntFlags(FlagBase H, FlagBase C, FlagBase B, bool bSeed)
{
	local int it, i, nToHost, nToPeer;
	local Name flagName;
	local int hVal, cVal;
	local Name toHostName[64], toPeerName[64];
	local int toHostVal[64], toPeerVal[64];
	local int toHostExp[64], toPeerExp[64];

	it = H.CreateIterator(FLAG_Int);
	while (H.GetNextFlagName(it, flagName))
	{
		if (CoopFlagExcluded(flagName))
			continue;
		hVal = H.GetInt(flagName);
		cVal = C.GetInt(flagName);
		if (hVal == cVal)
		{
			if (!B.CheckFlag(flagName, FLAG_Int) || (B.GetInt(flagName) != hVal))
				B.SetInt(flagName, hVal, True, 0);
		}
		else if (bSeed || (hVal != B.GetInt(flagName)))
		{
			if (nToPeer >= ArrayCount(toPeerName))
				break;
			toPeerName[nToPeer] = flagName;
			toPeerVal[nToPeer] = hVal;
			toPeerExp[nToPeer] = H.GetExpiration(flagName, FLAG_Int);
			nToPeer++;
		}
		else
		{
			if (nToHost >= ArrayCount(toHostName))
				break;
			toHostName[nToHost] = flagName;
			toHostVal[nToHost] = cVal;
			toHostExp[nToHost] = C.GetExpiration(flagName, FLAG_Int);
			nToHost++;
		}
	}
	H.DestroyIterator(it);

	it = C.CreateIterator(FLAG_Int);
	while (C.GetNextFlagName(it, flagName))
	{
		if (CoopFlagExcluded(flagName) || H.CheckFlag(flagName, FLAG_Int))
			continue;
		cVal = C.GetInt(flagName);
		if (cVal == 0)
		{
			if (!B.CheckFlag(flagName, FLAG_Int) || (B.GetInt(flagName) != 0))
				B.SetInt(flagName, 0, True, 0);
		}
		else if (!bSeed && (B.GetInt(flagName) == cVal))
		{
			if (nToPeer >= ArrayCount(toPeerName))
				break;
			toPeerName[nToPeer] = flagName;
			toPeerVal[nToPeer] = 0;
			toPeerExp[nToPeer] = C.GetExpiration(flagName, FLAG_Int);
			nToPeer++;
		}
		else
		{
			if (nToHost >= ArrayCount(toHostName))
				break;
			toHostName[nToHost] = flagName;
			toHostVal[nToHost] = cVal;
			toHostExp[nToHost] = C.GetExpiration(flagName, FLAG_Int);
			nToHost++;
		}
	}
	C.DestroyIterator(it);

	for (i = 0; i < nToPeer; i++)
	{
		C.SetInt(toPeerName[i], toPeerVal[i], True, toPeerExp[i]);
		B.SetInt(toPeerName[i], toPeerVal[i], True, 0);
	}
	for (i = 0; i < nToHost; i++)
	{
		H.SetInt(toHostName[i], toHostVal[i], True, toHostExp[i]);
		B.SetInt(toHostName[i], toHostVal[i], True, 0);
	}
}

function CoopMergeNameFlags(FlagBase H, FlagBase C, FlagBase B, bool bSeed)
{
	local int it, i, nToHost, nToPeer;
	local Name flagName;
	local Name hVal, cVal;
	local Name toHostName[32], toPeerName[32];
	local Name toHostVal[32], toPeerVal[32];
	local int toHostExp[32], toPeerExp[32];

	it = H.CreateIterator(FLAG_Name);
	while (H.GetNextFlagName(it, flagName))
	{
		if (CoopFlagExcluded(flagName))
			continue;
		hVal = H.GetName(flagName);
		cVal = C.GetName(flagName);
		if (hVal == cVal)
		{
			if (!B.CheckFlag(flagName, FLAG_Name) || (B.GetName(flagName) != hVal))
				B.SetName(flagName, hVal, True, 0);
		}
		else if (bSeed || (hVal != B.GetName(flagName)))
		{
			if (nToPeer >= ArrayCount(toPeerName))
				break;
			toPeerName[nToPeer] = flagName;
			toPeerVal[nToPeer] = hVal;
			toPeerExp[nToPeer] = H.GetExpiration(flagName, FLAG_Name);
			nToPeer++;
		}
		else
		{
			if (nToHost >= ArrayCount(toHostName))
				break;
			toHostName[nToHost] = flagName;
			toHostVal[nToHost] = cVal;
			toHostExp[nToHost] = C.GetExpiration(flagName, FLAG_Name);
			nToHost++;
		}
	}
	H.DestroyIterator(it);

	it = C.CreateIterator(FLAG_Name);
	while (C.GetNextFlagName(it, flagName))
	{
		if (CoopFlagExcluded(flagName) || H.CheckFlag(flagName, FLAG_Name))
			continue;
		cVal = C.GetName(flagName);
		if (cVal == '')
			continue;
		if (!bSeed && (B.GetName(flagName) == cVal))
			continue;	// host dropped it; leave the peer's stale copy alone
		if (nToHost >= ArrayCount(toHostName))
			break;
		toHostName[nToHost] = flagName;
		toHostVal[nToHost] = cVal;
		toHostExp[nToHost] = C.GetExpiration(flagName, FLAG_Name);
		nToHost++;
	}
	C.DestroyIterator(it);

	for (i = 0; i < nToPeer; i++)
	{
		C.SetName(toPeerName[i], toPeerVal[i], True, toPeerExp[i]);
		B.SetName(toPeerName[i], toPeerVal[i], True, 0);
	}
	for (i = 0; i < nToHost; i++)
	{
		H.SetName(toHostName[i], toHostVal[i], True, toHostExp[i]);
		B.SetName(toHostName[i], toHostVal[i], True, 0);
	}
}

// Mirror the peer's server-side bool flags onto its own machine, a bounded
// number per call so a map's worth of flags can't overflow the reliable buffer.
function CoopMirrorBoolFlags(Trestkon Peer, FlagBase M)
{
	local int it, sent;
	local Name flagName;
	local bool c;

	it = Peer.flagBase.CreateIterator(FLAG_Bool);
	while ((sent < 24) && Peer.flagBase.GetNextFlagName(it, flagName))
	{
		if (CoopFlagExcluded(flagName))
			continue;
		c = Peer.flagBase.GetBool(flagName);
		if (M.CheckFlag(flagName, FLAG_Bool))
		{
			if (M.GetBool(flagName) == c)
				continue;
		}
		else if (!c)
		{
			M.SetBool(flagName, False, True, 0);	// never sent as True, so the client doesn't have it
			continue;
		}
		Peer.ClientSyncBoolFlag(flagName, c);
		M.SetBool(flagName, c, True, 0);
		sent++;
	}
	Peer.flagBase.DestroyIterator(it);
}

// ----------------------------------------------------------------------
// Co-op turret control
//
// In netgames AutoTurret.Tick disables every turret whose safeTarget is None
// (all map-placed turrets) and otherwise only targets DeusExPlayers via
// AcquireMultiplayerTarget, ignoring bTrackPlayersOnly/bTrackPawnsOnly. Give
// each turret a placeholder safeTarget, keep TargetRefreshTime below the
// multiplayer refresh so it reuses prevTarget, and fill prevTarget with the
// singleplayer target choice.
// ----------------------------------------------------------------------

function CoopRefreshTurretList(bool bRecordMapState)
{
	local AutoTurret T;
	local int i;

	// the recorded map state is only used by the first CoopUpdateTurrets()
	NumCoopTurrets = 0;
	foreach AllActors(class'AutoTurret', T)
	{
		if (NumCoopTurrets >= ArrayCount(CoopTurrets))
			break;
		if (bRecordMapState)
			CoopTurretMapDisabled[NumCoopTurrets] = byte(T.bDisabled);
		CoopTurrets[NumCoopTurrets] = T;
		NumCoopTurrets++;
	}
	for (i = NumCoopTurrets; i < ArrayCount(CoopTurrets); i++)
		CoopTurrets[i] = None;
}

function Tick(float DeltaTime)
{
	local Trestkon Host;

	Super.Tick(DeltaTime);

	if (Level.NetMode == NM_Standalone)
		return;

	CoopUpdateTurrets();
	CoopCheckExplosives(DeltaTime);
	CoopSyncSharedCreditsAll();

	// Flags: merged 4x a second (and right after a conversation ends) so a flag
	// one player sets is visible to the other quickly. The client mirror RPCs
	// still go out once a second from SyncCoopState.
	CoopFlagMergeTimer -= DeltaTime;
	if (CoopFlagMergeTimer <= 0)
	{
		CoopFlagMergeTimer = 0.25;
		Host = Trestkon(GetPlayerPawn());
		if (Host != None)
			CoopMergeFlags(Host, True);
	}

	CoopRadiusTimer -= DeltaTime;
	if (CoopRadiusTimer <= 0)
	{
		CoopRadiusTimer = 0.25;
		CoopConListTimer -= 0.25;
		if (CoopConListTimer <= 0)
		{
			CoopConListTimer = 5.0;
			CoopRefreshConActors();
		}
		CoopRadiusConversations();
	}
}

// Ask for a flag merge on the next tick (conversation/datalink end).
function CoopRequestFlagMerge()
{
	CoopFlagMergeTimer = 0;
}

function CoopRefreshExplosivesList()
{
	local DeusExDecoration deco;
	local Robot bot;
	local DeusExMover mvr;
	local int i;

	NumCoopExplosives = 0;
	foreach AllActors(class'DeusExDecoration', deco)
	{
		if (deco.bExplosive && !deco.bDeleteMe)
		{
			if (NumCoopExplosives >= ArrayCount(CoopExplosiveActors))
				break;
			CoopExplosiveActors[NumCoopExplosives] = deco;
			CoopExplosiveLastLoc[NumCoopExplosives] = deco.Location;
			CoopExplosiveRadius[NumCoopExplosives] = FMax(128.0, deco.explosionRadius);
			if (deco.IsInState('Exploding'))
				CoopExplosiveState[NumCoopExplosives] = 2;
			else if (deco.IsInState('Burning'))
				CoopExplosiveState[NumCoopExplosives] = 1;
			else
				CoopExplosiveState[NumCoopExplosives] = 0;
			NumCoopExplosives++;
		}
	}
	foreach AllActors(class'Robot', bot)
	{
		if (!bot.bDeleteMe)
		{
			if (NumCoopExplosives >= ArrayCount(CoopExplosiveActors))
				break;
			CoopExplosiveActors[NumCoopExplosives] = bot;
			CoopExplosiveLastLoc[NumCoopExplosives] = bot.Location;
			CoopExplosiveRadius[NumCoopExplosives] = FMax(160.0, 4.0 * (bot.CollisionRadius + bot.CollisionHeight));
			CoopExplosiveState[NumCoopExplosives] = 0;
			NumCoopExplosives++;
		}
	}
	foreach AllActors(class'DeusExMover', mvr)
	{
		if (mvr.bBreakable && !mvr.bDestroyed)
		{
			if (NumCoopExplosives >= ArrayCount(CoopExplosiveActors))
				break;
			CoopExplosiveActors[NumCoopExplosives] = mvr;
			CoopExplosiveLastLoc[NumCoopExplosives] = mvr.Location;
			CoopExplosiveRadius[NumCoopExplosives] = FMax(128.0, mvr.FragmentSpread * 4.0);
			CoopExplosiveState[NumCoopExplosives] = 0;
			NumCoopExplosives++;
		}
	}
	for (i = NumCoopExplosives; i < ArrayCount(CoopExplosiveActors); i++)
	{
		CoopExplosiveActors[i] = None;
		CoopExplosiveState[i] = 0;
	}
}

function CoopCheckExplosives(float DeltaTime)
{
	local int i;
	local Actor A;
	local DeusExDecoration deco;
	local Robot bot;
	local DeusExMover mvr;
	local Pawn P;
	local Trestkon T;

	CoopExplosiveRefreshTimer -= DeltaTime;
	if (CoopExplosiveRefreshTimer <= 0.0)
	{
		CoopExplosiveRefreshTimer = 6.0;
		if (NumCoopExplosives == 0)
			CoopRefreshExplosivesList();
	}

	for (i = 0; i < NumCoopExplosives; i++)
	{
		if (CoopExplosiveState[i] >= 2)
			continue;

		A = CoopExplosiveActors[i];
		if (A == None || A.bDeleteMe)
		{
			CoopExplosiveState[i] = 2;
			BroadcastCoopExplosionFX(CoopExplosiveLastLoc[i], CoopExplosiveRadius[i], 'Exploded');
			continue;
		}

		if (Mover(A) == None)
			CoopExplosiveLastLoc[i] = A.Location;

		deco = DeusExDecoration(A);
		if (deco != None)
		{
			if (deco.IsInState('Exploding') || deco.HitPoints <= 0)
			{
				CoopExplosiveState[i] = 2;
				BroadcastCoopExplosionFX(CoopExplosiveLastLoc[i], CoopExplosiveRadius[i], 'Exploded');
			}
			else if (deco.IsInState('Burning') && CoopExplosiveState[i] < 1)
			{
				CoopExplosiveState[i] = 1;
				for (P = Level.PawnList; P != None; P = P.NextPawn)
				{
					T = Trestkon(P);
					if (T != None && NetConnection(T.Player) != None && VSize(T.Location - deco.Location) <= 3200.0)
						T.ClientPlayBurningTelegraph(deco.Location);
				}
			}
			continue;
		}

		bot = Robot(A);
		if (bot != None)
		{
			if (bot.Health <= 0 || bot.IsInState('Dying'))
			{
				CoopExplosiveState[i] = 2;
				BroadcastCoopExplosionFX(CoopExplosiveLastLoc[i], CoopExplosiveRadius[i], 'Exploded');
			}
			continue;
		}

		mvr = DeusExMover(A);
		if (mvr != None && mvr.bDestroyed)
		{
			CoopExplosiveState[i] = 2;
			BroadcastCoopExplosionFX(mvr.Location + (mvr.BasePos - mvr.Location), CoopExplosiveRadius[i], 'Exploded');
		}
	}
}

function BroadcastCoopExplosionFX(vector HitLoc, float BlastRad, name DmgType)
{
	local int i;
	local Pawn P;
	local Trestkon T;

	if (Level.NetMode == NM_Standalone)
		return;

	for (i = 0; i < ArrayCount(RecentBlastTime); i++)
	{
		if (RecentBlastTime[i] > 0.0 && (Level.TimeSeconds - RecentBlastTime[i]) < 0.18 && VSize(HitLoc - RecentBlastLoc[i]) < 80.0)
			return;
	}

	RecentBlastLoc[RecentBlastHead] = HitLoc;
	RecentBlastTime[RecentBlastHead] = Level.TimeSeconds;
	RecentBlastHead = (RecentBlastHead + 1) % ArrayCount(RecentBlastTime);

	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		T = Trestkon(P);
		if (T != None && NetConnection(T.Player) != None && VSize(T.Location - HitLoc) <= 5000.0)
			T.ClientPlayExplosionFX(HitLoc, BlastRad, DmgType);
	}
}

function CoopSyncSharedCreditsAll()
{
	local Pawn P1, P2;

	for (P1 = Level.PawnList; P1 != None; P1 = P1.NextPawn)
		if (Trestkon(P1) != None)
			for (P2 = Level.PawnList; P2 != None; P2 = P2.NextPawn)
				if ((Trestkon(P2) != None) && (P2 != P1))
					Trestkon(P2).CoopSyncSharedCredits(Trestkon(P1));
}

// Closest living player to A (any player if all are down). Used where stock code
// would take GetPlayerPawn(), which is always the host on a listen server.
function Pawn CoopClosestPlayer(Actor A)
{
	local Pawn P, Best;
	local float D, BestD;

	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		if ((Trestkon(P) == None) || (P.Health <= 0) || P.IsInState('Dying'))
			continue;
		D = 0;
		if (A != None)
			D = VSize(P.Location - A.Location);
		if ((Best == None) || (D < BestD))
		{
			Best = P;
			BestD = D;
		}
	}
	if (Best == None)
		Best = GetPlayerPawn();
	return Best;
}

// ----------------------------------------------------------------------
// Radius conversations
//
// Stock ScriptedPawn.Tick and DeusExDecoration.Tick call
// StartConversation(Self, IM_Radius) only on GetPlayerPawn(), the host, so a
// client walking up alone never started proximity conversations (e.g. the
// Firewall/Kale hand-offs in 20_FCDowntown). Do the same for every other
// player. StartConversation does the radius, flag and already-playing checks.
// ----------------------------------------------------------------------

function CoopRefreshConActors()
{
	local Actor A;

	NumCoopConActors = 0;
	foreach AllActors(class'Actor', A)
	{
		if ((A.ConListItems == None) || ((ScriptedPawn(A) == None) && (DeusExDecoration(A) == None)))
			continue;
		if (NumCoopConActors >= ArrayCount(CoopConActors))
			break;
		CoopConActors[NumCoopConActors] = A;
		NumCoopConActors++;
	}
}

function CoopRadiusConversations()
{
	local Pawn P;
	local Trestkon T, Host;
	local Actor A;
	local int i;

	Host = Trestkon(GetPlayerPawn());
	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		T = Trestkon(P);
		if ((T == None) || (T == Host) || (T.Health <= 0) || T.IsInState('Dying') || (T.conPlay != None))
			continue;

		for (i = 0; i < NumCoopConActors; i++)
		{
			A = CoopConActors[i];
			if ((A == None) || A.bDeleteMe || (A.ConListItems == None))
				continue;
			if (VSize(A.Location - T.Location) > 1024)		// largest TNM radius is 384
				continue;
			if (ScriptedPawn(A) != None)
			{
				if ((ScriptedPawn(A).Health <= 0) || A.IsInState('Conversation') || A.IsInState('FirstPersonConversation'))
					continue;
			}
			T.StartConversation(A, IM_Radius);
			if (T.conPlay != None)
				break;
		}
	}
}

// ----------------------------------------------------------------------
// Trigger replacement
//
// - SkillAwardTrigger pays only the toucher/instigator and is once-only, so the
//   other player never got map XP. Replaced with CoopSkillAwardTrigger.
// - Engine Trigger fires per toucher and untriggers when either player leaves.
//   Plain Triggers that drive TriggerToggle/TriggerControl/TriggerPound movers
//   are replaced with CoopOccupancyTrigger.
// Replacements are spawned in AllActors order, so their names are the same on
// every load (the co-op map save tracks once-only triggers by name).
// ----------------------------------------------------------------------

function CoopReplaceTriggers()
{
	local Trigger T, List[128];
	local Trigger N;
	local int Num, i;
	local Actor A;
	local bool bRisky;

	foreach AllActors(class'Trigger', T)
	{
		if (Num >= ArrayCount(List))
			break;
		if (SkillAwardTrigger(T) != None)
		{
			if (CoopSkillAwardTrigger(T) == None)
			{
				List[Num] = T;
				Num++;
			}
			continue;
		}
		if ((T.Class != class'Trigger') || T.bTriggerOnceOnly || (T.Event == ''))
			continue;
		bRisky = False;
		foreach AllActors(class'Actor', A, T.Event)
		{
			if ((Mover(A) != None) && ((A.InitialState == 'TriggerToggle') || (A.InitialState == 'TriggerControl') || (A.InitialState == 'TriggerPound')))
			{
				bRisky = True;
				break;
			}
		}
		if (bRisky)
		{
			List[Num] = T;
			Num++;
		}
	}

	for (i = 0; i < Num; i++)
	{
		T = List[i];
		if (SkillAwardTrigger(T) != None)
		{
			N = Spawn(class'CoopSkillAwardTrigger', T.Owner, T.Tag, T.Location, T.Rotation);
			if (N != None)
			{
				CoopSkillAwardTrigger(N).skillPointsAdded = SkillAwardTrigger(T).skillPointsAdded;
				CoopSkillAwardTrigger(N).awardMessage = SkillAwardTrigger(T).awardMessage;
			}
		}
		else
			N = Spawn(class'CoopOccupancyTrigger', T.Owner, T.Tag, T.Location, T.Rotation);

		if (N == None)
			continue;
		CoopCopyTrigger(T, N);
		T.Destroy();
	}

	if (Num > 0)
		log("CoopMod replaced " $ Num $ " triggers for co-op (skill awards / occupancy)");
}

function CoopCopyTrigger(Trigger From, Trigger To)
{
	To.Event = From.Event;
	To.Group = From.Group;
	To.TriggerType = From.TriggerType;
	To.Message = From.Message;
	To.bTriggerOnceOnly = From.bTriggerOnceOnly;
	To.bInitiallyActive = From.bInitiallyActive;
	To.ClassProximityType = From.ClassProximityType;
	To.RepeatTriggerTime = From.RepeatTriggerTime;
	To.ReTriggerDelay = From.ReTriggerDelay;
	To.DamageThreshold = From.DamageThreshold;
	To.SetCollisionSize(From.CollisionRadius, From.CollisionHeight);
	To.SetCollision(From.bCollideActors, From.bBlockActors, From.bBlockPlayers);
	if (To.TriggerType == TT_Shoot)
	{
		To.bHidden = False;
		To.bProjTarget = True;
		To.DrawType = DT_None;
	}
	if (!To.bInitiallyActive)
		To.FindTriggerActor();
	To.InitialState = From.InitialState;
	if (From.InitialState != '')
		To.GotoState(From.InitialState);
}


function CoopUpdateTurrets()
{
	local AutoTurret T;
	local int i;

	if (NumCoopTurrets == 0)
		return;

	if (CoopTurretDummy == None)
		CoopTurretDummy = Spawn(class'CoopTurretSafeTarget');

	for (i = 0; i < NumCoopTurrets; i++)
	{
		T = CoopTurrets[i];
		if ((T == None) || T.bDeleteMe)
			continue;

		// if a turret already ticked with no safeTarget it disabled itself; undo that once
		if (!bCoopTurretsSettled && (T.bDisabled != bool(CoopTurretMapDisabled[i])))
			T.bDisabled = bool(CoopTurretMapDisabled[i]);

		if (T.safeTarget == None)
			T.safeTarget = CoopTurretDummy;
		T.TargetRefreshTime = 0;

		if (T.bActive && !T.bDisabled && !T.bConfused && (T.gun != None))
			T.prevTarget = CoopAcquireTurretTarget(T);
		else
			T.prevTarget = None;
	}
	bCoopTurretsSettled = True;
}

// AutoTurret.Tick's singleplayer branch
function Actor CoopAcquireTurretTarget(AutoTurret T)
{
	local Pawn aPawn, HostPawn;
	local ScriptedPawn sp;
	local DeusExDecoration deco;
	local DeusExPlayer aPlayer;
	local Actor target;

	HostPawn = GetPlayerPawn();

	if (T.bTrackPlayersOnly || (!T.bTrackPlayersOnly && !T.bTrackPawnsOnly))
	{
		foreach T.gun.VisibleActors(class'Pawn', aPawn, T.maxRange, T.gun.Location)
		{
			if (aPawn.bDetectable && !aPawn.bIgnore)
			{
				aPlayer = DeusExPlayer(aPawn);
				if (aPlayer != None)
				{
					// If the player's RadarTrans aug is off, the turret can see him
					if ((aPlayer.AugmentationSystem == None) || (aPlayer.AugmentationSystem.GetAugLevelValue(class'AugRadarTrans') == -1.0))
					{
						target = aPawn;
						break;
					}
				}
				else if (aPawn.IsA('ScriptedPawn') && (int(ScriptedPawn(aPawn).GetPawnAllianceType(HostPawn)) != 2))
				{
					target = aPawn;
					break;
				}
			}
		}
	}

	if (!T.bTrackPlayersOnly)
	{
		if (!T.bTrackPawnsOnly)
		{
			foreach T.gun.VisibleActors(class'DeusExDecoration', deco, T.maxRange, T.gun.Location)
			{
				if (!deco.IsA('ElectronicDevices') && !deco.IsA('AutoTurret') &&
					!deco.bInvincible && deco.bDetectable && !deco.bIgnore)
				{
					target = deco;
					break;
				}
			}
		}

		foreach T.gun.VisibleActors(class'ScriptedPawn', sp, T.maxRange, T.gun.Location)
		{
			if (sp.bDetectable && !sp.bIgnore && (int(sp.GetPawnAllianceType(HostPawn)) == 2))
			{
				target = sp;
				break;
			}
		}
	}

	return target;
}

// ----------------------------------------------------------------------
// Co-op weapon pickups
//
// bCoopWeaponMode keeps world weapons in place so both players can gear up.
// Track who took each one: a player can take a given pickup once, and it is
// removed once every connected player has taken it.
// ----------------------------------------------------------------------

function int CoopFindStayPickup(Weapon W, bool bCreate)
{
	local int i, freeSlot;

	freeSlot = -1;
	for (i = 0; i < ArrayCount(CoopStayPickup); i++)
	{
		if (CoopStayPickup[i] == W)
			return i;
		if ((freeSlot == -1) && ((CoopStayPickup[i] == None) || CoopStayPickup[i].bDeleteMe))
			freeSlot = i;
	}
	if (!bCreate || (freeSlot == -1))
		return -1;

	CoopStayPickup[freeSlot] = W;
	for (i = 0; i < 4; i++)
		CoopStayTaker[freeSlot * 4 + i] = None;
	return freeSlot;
}

// Every pickup (frob -> Pickup.ValidTouch) asks this first, so a player who
// already took a given stay pickup can't take it again even after losing it.
function bool PickupQuery(Pawn Other, Inventory item)
{
	if ((Level.NetMode != NM_Standalone) && (Weapon(item) != None) && Weapon(item).bWeaponStay
		&& !item.bHeldItem && !item.bTossedOut && CoopStayPickupTakenBy(Weapon(item), Other))
		return false;

	return Super.PickupQuery(Other, item);
}

function bool CoopStayPickupTakenBy(Weapon W, Pawn P)
{
	local int idx, i;

	idx = CoopFindStayPickup(W, False);
	if (idx == -1)
		return False;
	for (i = 0; i < 4; i++)
		if (CoopStayTaker[idx * 4 + i] == P)
			return True;
	return False;
}

function CoopNoteStayPickupTaken(Weapon W, Pawn P)
{
	local int idx, i, freeSlot, numTakers, numPlayers;
	local Pawn aPawn;

	idx = CoopFindStayPickup(W, True);
	if (idx == -1)
	{
		W.SetRespawn();	// table full: singleplayer behaviour
		return;
	}

	freeSlot = -1;
	for (i = 0; i < 4; i++)
	{
		if (CoopStayTaker[idx * 4 + i] == P)
			freeSlot = -2;
		else if ((freeSlot == -1) && ((CoopStayTaker[idx * 4 + i] == None) || CoopStayTaker[idx * 4 + i].bDeleteMe))
			freeSlot = i;
	}
	if (freeSlot >= 0)
		CoopStayTaker[idx * 4 + freeSlot] = P;

	for (aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.NextPawn)
		if (Trestkon(aPawn) != None)
			numPlayers++;
	for (i = 0; i < 4; i++)
		if ((Trestkon(CoopStayTaker[idx * 4 + i]) != None) && !CoopStayTaker[idx * 4 + i].bDeleteMe)
			numTakers++;

	if (numTakers >= numPlayers)
	{
		CoopStayPickup[idx] = None;
		W.SetRespawn();
	}
}

function SendPlayer( PlayerPawn aPlayer, string URL )
{
	local Pawn P;
	local Trestkon T;
	local MissionScript ms;
	local Augmentation aug;

	if (Level.NextURL != "")
		return;

	if (trestkon(aPlayer) != None && trestkon(aPlayer).b2009Maps)
	{
		if (instr(URL, "#") != -1)
			URL = Left(URL, instr(URL, "#")) $ "_2009" $ Mid(URL, instr(URL, "#"), Len(URL)-instr(URL, "#"));
		else
			URL = URL $ "_2009";
	}
	
	LogAllSuspiciousEntities();

	if (Level.NetMode != NM_Standalone)
	{
		SyncCoopState();
		foreach AllActors(class'MissionScript', ms)
		{
			if (ms.flags != None)
				ms.PreTravel();
			ms.SetTimer(0.0, False);
			ms.flags = None;
			ms.Player = None;
			ms.dxInfo = None;
			ms.SetPropertyText("launcher", "None");
			ms.Destroy();
		}
		SyncCoopState();
		foreach AllActors(class'Augmentation', aug)
		{
			if (aug.IsA('AugLight'))
				AugLight(aug).PreTravel();
			else if (aug.IsA('TNMAugLight'))
				TNMAugLight(aug).PreTravel();
		}
		for (P = Level.PawnList; P != None; P = P.NextPawn)
		{
			T = Trestkon(P);
			if (T != None)
			{
				RevivePlayerForTravel(T);
				if (NetConnection(T.Player) != None)
					T.ClientPrepareTravel();
				else if (DeusExRootWindow(T.rootWindow) != None)
					DeusExRootWindow(T.rootWindow).ClearWindowStack();
				T.bStartingNewGame = True;
				T.PreTravel();
			}
		}
		SaveCoopSessionToDefaults(URL);
		bSavedThisTravel = True;
		Level.ServerTravel( URL, true );
	}
	else
	{
		aPlayer.ClientTravel( URL, TRAVEL_Relative, true );
	}
}

static function ClearCoopSessionDefaults()
{
	local int i;

	default.bHasCoopSession = False;
	default.bHasActiveTravelSession = False;
	default.bForceRestoreLoadout = False;
	default.bRestoreSavedPositions = False;
	default.SavedCurrentURL = "";
	default.SavedBoolCount = 0;
	default.SavedByteCount = 0;
	default.SavedIntCount = 0;
	default.SavedFloatCount = 0;
	default.SavedNameCount = 0;
	default.SavedGoalCount = 0;
	default.SavedNoteCount = 0;
	default.SavedKeyCount = 0;
	default.SavedHostCredits = 0;
	default.SavedClientCredits = 0;
	default.SavedLastMap = "";
	default.SavedHostInvTotal = 0;
	default.SavedClientInvTotal = 0;
	for (i = 0; i < ArrayCount(default.SavedHostInvExtra); i++)
	{
		default.SavedHostInvExtra[i] = "";
		default.SavedClientInvExtra[i] = "";
	}
	for (i = 0; i < ArrayCount(default.SavedProfileInvExtra); i++)
		default.SavedProfileInvExtra[i] = "";
	for (i = 0; i < ArrayCount(default.SavedProfileNames); i++)
	{
		default.SavedProfileNames[i] = "";
		default.SavedProfileInvTotal[i] = 0;
	}
	StaticSaveConfig();
}

function string BuildCoopItemExtraString(Trestkon T, Inventory inv)
{
	local int beltVal, eqVal, chgVal, modMask, attrInt, katLvl, killsVal, a1, a2;
	local string extraStr, ammoClsStr;
	local DeusExWeapon weap;
	local TNMWeapon tnmWeap;

	if (inv == None)
		return "";

	beltVal = -1;
	if (inv.bInObjectBelt && inv.beltPos >= 0)
		beltVal = inv.beltPos;

	eqVal = 0;
	if (T != None && (T.inHand == inv || T.Weapon == inv))
		eqVal = 1;

	chgVal = -1;
	if (Pickup(inv) != None && !inv.IsA('Ammo'))
		chgVal = Pickup(inv).Charge;

	extraStr = inv.invPosX $ "|" $ inv.invPosY $ "|" $ beltVal $ "|" $ eqVal $ "|" $ chgVal;

	weap = DeusExWeapon(inv);
	if (weap != None)
	{
		if (weap.AmmoType != None)
			ammoClsStr = string(weap.AmmoType.Class);
		else if (weap.AmmoName != None)
			ammoClsStr = string(weap.AmmoName);
		else
			ammoClsStr = "";

		modMask = 32;
		if (weap.bHasScope)    modMask = modMask | 1;
		if (weap.bHasLaser)    modMask = modMask | 2;
		if (weap.bHasSilencer) modMask = modMask | 4;
		if (weap.bAutomatic)   modMask = modMask | 8;

		tnmWeap = TNMWeapon(weap);
		if (weap.bLasing || (tnmWeap != None && tnmWeap.bWasLasing))
			modMask = modMask | 16;

		if (tnmWeap != None)
		{
			katLvl   = tnmWeap.katanaLevel;
			killsVal = tnmWeap.numKills;
			attrInt  = int(tnmWeap.Attribute);
			a1       = tnmWeap.Attributes1;
			a2       = tnmWeap.Attributes2;
		}

		extraStr = extraStr $ "|" $ ammoClsStr
			$ "|" $ modMask
			$ "|" $ int(weap.ReloadCount)
			$ "|" $ weap.AccurateRange
			$ "|" $ weap.BaseAccuracy
			$ "|" $ weap.ReloadTime
			$ "|" $ weap.recoilStrength
			$ "|" $ weap.ShotTime
			$ "|" $ weap.NoiseLevel
			$ "|" $ weap.ModBaseAccuracy
			$ "|" $ weap.ModReloadCount
			$ "|" $ weap.ModAccurateRange
			$ "|" $ weap.ModReloadTime
			$ "|" $ weap.ModRecoilStrength
			$ "|" $ katLvl
			$ "|" $ killsVal
			$ "|" $ attrInt
			$ "|" $ a1
			$ "|" $ a2;
	}

	return extraStr;
}

function int SplitPipeTokens(string src, out string tok[28])
{
	local int count, p;
	local string rem;

	for (count = 0; count < 28; count++)
		tok[count] = "";

	if (src == "")
		return 0;

	count = 0;
	rem = src;
	while (count < 28)
	{
		p = InStr(rem, "|");
		if (p != -1)
		{
			tok[count] = Left(rem, p);
			rem = Mid(rem, p + 1);
			count++;
		}
		else
		{
			tok[count] = rem;
			count++;
			break;
		}
	}
	return count;
}

function ApplyCoopItemPlacementAndCharge(Trestkon T, Inventory inv, string extra, out Inventory outEquippedInv)
{
	local string tok[28];
	local int nTok, px, py, beltVal, eqVal, chgVal;

	if (T == None || inv == None)
		return;

	nTok = SplitPipeTokens(extra, tok);
	if (nTok >= 5)
	{
		px      = int(tok[0]);
		py      = int(tok[1]);
		beltVal = int(tok[2]);
		eqVal   = int(tok[3]);
		chgVal  = int(tok[4]);

		if (inv.bDisplayableInv)
		{
			if (px >= 0 && py >= 0 && T.IsEmptyItemSlot(inv, px, py))
				T.PlaceItemInSlot(inv, px, py);
			else
				T.FindInventorySlot(inv, False);

			if (beltVal >= 1)
				T.AddObjectToBelt(inv, beltVal, True);
		}

		if (chgVal >= 0 && Pickup(inv) != None && !inv.IsA('Ammo'))
			Pickup(inv).Charge = chgVal;

		if (eqVal != 0 && inv.bDisplayableInv)
			outEquippedInv = inv;
	}
	else
	{
		if (inv.bDisplayableInv)
		{
			T.FindInventorySlot(inv, False);
			T.AddObjectToBelt(inv, -1, False);
		}
	}
}

function ApplyCoopWeaponExtraPostAmmo(Trestkon T, DeusExWeapon weap, int savedClip, string extra)
{
	local string tok[28];
	local int nTok, modMask, k;
	local class<Ammo> savedAmmoCls;
	local Ammo foundAmmo;
	local TNMWeapon tnmWeap;

	if (T == None || weap == None)
		return;

	nTok = SplitPipeTokens(extra, tok);
	if (nTok >= 7 && (int(tok[6]) & 32) != 0)
	{
		modMask = int(tok[6]);
		if (tok[5] != "")
			savedAmmoCls = class<Ammo>(DynamicLoadObject(tok[5], class'Class', True));

		if (savedAmmoCls != None)
		{
			foundAmmo = Ammo(T.FindInventoryType(savedAmmoCls));
			if (foundAmmo == None)
			{
				// Spawn a 0-round ammo holder so the loaded ammo type stays valid even with 0 reserve
				foundAmmo = Spawn(savedAmmoCls, T);
				if (foundAmmo != None)
				{
					foundAmmo.bHeldItem = True;
					foundAmmo.RespawnTime = 0.0;
					foundAmmo.AmmoAmount = 0;
					foundAmmo.GiveTo(T);
					foundAmmo.SetBase(T);
				}
			}

			for (k = 0; k < 3; k++)
			{
				if (weap.AmmoNames[k] == savedAmmoCls)
				{
					if (weap.ProjectileNames[k] == None)
					{
						weap.bInstantHit = True;
						weap.FireSound = weap.Default.FireSound;
						weap.ProjectileClass = None;
					}
					else
					{
						weap.bInstantHit = False;
						weap.FireSound = None;
						weap.ProjectileClass = weap.ProjectileNames[k];
						weap.ProjectileSpeed = weap.ProjectileClass.Default.Speed;
					}
					break;
				}
			}
			weap.AmmoName = savedAmmoCls;
			weap.AmmoType = foundAmmo;
		}

		weap.bHasScope    = ((modMask & 1) != 0);
		weap.bHasLaser    = ((modMask & 2) != 0);
		weap.bHasSilencer = ((modMask & 4) != 0);
		weap.bAutomatic   = ((modMask & 8) != 0);

		if (nTok >= 19)
		{
			weap.ReloadCount       = byte(Clamp(int(tok[7]), 0, 255));
			weap.AccurateRange     = int(tok[8]);
			weap.BaseAccuracy      = float(tok[9]);
			weap.ReloadTime        = float(tok[10]);
			weap.recoilStrength    = float(tok[11]);
			weap.ShotTime          = float(tok[12]);
			weap.NoiseLevel        = float(tok[13]);
			weap.ModBaseAccuracy   = float(tok[14]);
			weap.ModReloadCount    = float(tok[15]);
			weap.ModAccurateRange  = float(tok[16]);
			weap.ModReloadTime     = float(tok[17]);
			weap.ModRecoilStrength = float(tok[18]);
		}

		tnmWeap = TNMWeapon(weap);
		if (tnmWeap != None && nTok >= 24)
		{
			tnmWeap.bWasLasing  = ((modMask & 16) != 0);
			tnmWeap.katanaLevel = int(tok[19]);
			tnmWeap.numKills    = int(tok[20]);
			tnmWeap.SetCoopSavedAttributes(byte(Clamp(int(tok[21]), 0, 255)), int(tok[22]), int(tok[23]));
		}
	}

	if (weap.AmmoType == None && weap.AmmoName != None)
		weap.AmmoType = Ammo(T.FindInventoryType(weap.AmmoName));

	weap.ClipCount = Max(0, savedClip);
	T.CoopSendWeaponMods(weap);
}

function SavePlayerLoadoutToDefaults(Trestkon T, bool bIsClient)
{
	local Inventory inv;
	local Skill aSkill;
	local Augmentation anAug;
	local int idx, countVal;

	if (T == None)
		return;

	idx = 0;
	for (inv = T.Inventory; inv != None; inv = inv.Inventory)
	{
		if (idx >= 64)
			break;
		if (inv.IsA('NanoKeyRing') || inv.IsA('WeaponFists'))
			continue;

		countVal = 1;
		if (DeusExWeapon(inv) != None)
			countVal = DeusExWeapon(inv).ClipCount;
		else if (Ammo(inv) != None)
			countVal = Ammo(inv).AmmoAmount;
		else if (DeusExPickup(inv) != None)
			countVal = DeusExPickup(inv).NumCopies;

		if (bIsClient)
		{
			default.SavedClientInvClass[idx] = string(inv.Class);
			default.SavedClientInvCount[idx] = countVal;
			default.SavedClientInvExtra[idx] = BuildCoopItemExtraString(T, inv);
		}
		else
		{
			default.SavedHostInvClass[idx] = string(inv.Class);
			default.SavedHostInvCount[idx] = countVal;
			default.SavedHostInvExtra[idx] = BuildCoopItemExtraString(T, inv);
		}
		idx++;
	}

	if (bIsClient)
	{
		default.SavedClientInvTotal = idx;
		default.SavedClientStats[0] = T.HealthHead;
		default.SavedClientStats[1] = T.HealthTorso;
		default.SavedClientStats[2] = T.HealthLegLeft;
		default.SavedClientStats[3] = T.HealthLegRight;
		default.SavedClientStats[4] = T.HealthArmLeft;
		default.SavedClientStats[5] = T.HealthArmRight;
		default.SavedClientStats[6] = int(T.Energy);
		default.SavedClientStats[7] = T.SkillPointsAvail;
		default.SavedClientStats[8] = T.SkillPointsTotal;
		default.SavedClientStats[9] = T.Credits;
	}
	else
	{
		default.SavedHostInvTotal = idx;
		default.SavedHostStats[0] = T.HealthHead;
		default.SavedHostStats[1] = T.HealthTorso;
		default.SavedHostStats[2] = T.HealthLegLeft;
		default.SavedHostStats[3] = T.HealthLegRight;
		default.SavedHostStats[4] = T.HealthArmLeft;
		default.SavedHostStats[5] = T.HealthArmRight;
		default.SavedHostStats[6] = int(T.Energy);
		default.SavedHostStats[7] = T.SkillPointsAvail;
		default.SavedHostStats[8] = T.SkillPointsTotal;
		default.SavedHostStats[9] = T.Credits;
	}

	if (T.SkillSystem != None)
	{
		idx = 0;
		aSkill = T.SkillSystem.FirstSkill;
		while (aSkill != None && idx < 32)
		{
			if (bIsClient)
				default.SavedClientSkillLevels[idx] = aSkill.CurrentLevel;
			else
				default.SavedHostSkillLevels[idx] = aSkill.CurrentLevel;
			idx++;
			aSkill = aSkill.next;
		}
	}

	if (T.AugmentationSystem != None)
	{
		idx = 0;
		anAug = T.AugmentationSystem.FirstAug;
		while (anAug != None && idx < 32)
		{
			if (anAug.bHasIt)
				countVal = 10 + anAug.CurrentLevel;
			else
				countVal = 0;
			if (bIsClient)
				default.SavedClientAugLevels[idx] = countVal;
			else
				default.SavedHostAugLevels[idx] = countVal;
			idx++;
			anAug = anAug.next;
		}
	}
}

function RestorePlayerLoadoutFromDefaults(Trestkon T, bool bIsClient)
{
	local int i, pass, totalInv, countVal;
	local string extraStr;
	local class<Inventory> invClass;
	local Inventory inv, nextInv, existingInv, equippedInv;
	local Skill aSkill;
	local Augmentation anAug;

	if (T == None)
		return;

	if (bIsClient)
		totalInv = default.SavedClientInvTotal;
	else
		totalInv = default.SavedHostInvTotal;

	if (default.bForceRestoreLoadout || default.bHasActiveTravelSession)
	{
		for (inv = T.Inventory; inv != None; inv = nextInv)
		{
			nextInv = inv.Inventory;
			if (!inv.IsA('NanoKeyRing') && !inv.IsA('WeaponFists'))
			{
				T.RemoveObjectFromBelt(inv);
				T.DeleteInventory(inv);
				inv.Destroy();
			}
		}
		T.ClearInventorySlots();
	}

	if (totalInv <= 0)
		return;

	for (pass = 0; pass < 2; pass++)
	{
		for (i = 0; i < totalInv; i++)
		{
			if (bIsClient)
			{
				invClass = class<Inventory>(DynamicLoadObject(default.SavedClientInvClass[i], class'Class', True));
				countVal = default.SavedClientInvCount[i];
				extraStr = default.SavedClientInvExtra[i];
			}
			else
			{
				invClass = class<Inventory>(DynamicLoadObject(default.SavedHostInvClass[i], class'Class', True));
				countVal = default.SavedHostInvCount[i];
				extraStr = default.SavedHostInvExtra[i];
			}

			if (invClass == None)
				continue;

			if (pass == 0 && ClassIsChildOf(invClass, class'Ammo'))
				continue;
			if (pass == 1 && !ClassIsChildOf(invClass, class'Ammo'))
				continue;

			existingInv = T.FindInventoryType(invClass);
			if (existingInv == None)
			{
				inv = Spawn(invClass, T);
				if (inv != None)
				{
					inv.bHeldItem = True;
					inv.RespawnTime = 0.0;
					if (Weapon(inv) != None)
						Weapon(inv).PickupAmmoCount = 0;
					ApplyCoopItemPlacementAndCharge(T, inv, extraStr, equippedInv);
					inv.GiveTo(T);
					inv.SetBase(T);
					existingInv = inv;
				}
			}

			if (existingInv != None)
			{
				if (Ammo(existingInv) != None)
					Ammo(existingInv).AmmoAmount = Max(0, countVal);
				else if (DeusExPickup(existingInv) != None && DeusExPickup(existingInv).bCanHaveMultipleCopies)
					DeusExPickup(existingInv).NumCopies = Max(1, countVal);
			}
		}
	}

	for (i = 0; i < totalInv; i++)
	{
		if (bIsClient)
		{
			invClass = class<Inventory>(DynamicLoadObject(default.SavedClientInvClass[i], class'Class', True));
			countVal = default.SavedClientInvCount[i];
			extraStr = default.SavedClientInvExtra[i];
		}
		else
		{
			invClass = class<Inventory>(DynamicLoadObject(default.SavedHostInvClass[i], class'Class', True));
			countVal = default.SavedHostInvCount[i];
			extraStr = default.SavedHostInvExtra[i];
		}
		if (invClass != None && ClassIsChildOf(invClass, class'DeusExWeapon'))
		{
			existingInv = T.FindInventoryType(invClass);
			if (DeusExWeapon(existingInv) != None)
				ApplyCoopWeaponExtraPostAmmo(T, DeusExWeapon(existingInv), countVal, extraStr);
		}
	}

	if (equippedInv != None)
		T.PutInHand(equippedInv);

	if (bIsClient)
	{
		if (default.SavedClientStats[1] > 0)
		{
			T.HealthHead = default.SavedClientStats[0];
			T.HealthTorso = default.SavedClientStats[1];
			T.HealthLegLeft = default.SavedClientStats[2];
			T.HealthLegRight = default.SavedClientStats[3];
			T.HealthArmLeft = default.SavedClientStats[4];
			T.HealthArmRight = default.SavedClientStats[5];
			T.GenerateTotalHealth();
		}
		if (default.SavedClientStats[6] > 0)
			T.Energy = float(default.SavedClientStats[6]);
		T.SkillPointsAvail = default.SavedClientStats[7];
		T.SkillPointsTotal = default.SavedClientStats[8];
		T.Credits = default.SavedClientStats[9];
	}
	else
	{
		if (default.SavedHostStats[1] > 0)
		{
			T.HealthHead = default.SavedHostStats[0];
			T.HealthTorso = default.SavedHostStats[1];
			T.HealthLegLeft = default.SavedHostStats[2];
			T.HealthLegRight = default.SavedHostStats[3];
			T.HealthArmLeft = default.SavedHostStats[4];
			T.HealthArmRight = default.SavedHostStats[5];
			T.GenerateTotalHealth();
		}
		if (default.SavedHostStats[6] > 0)
			T.Energy = float(default.SavedHostStats[6]);
		T.SkillPointsAvail = default.SavedHostStats[7];
		T.SkillPointsTotal = default.SavedHostStats[8];
		T.Credits = default.SavedHostStats[9];
	}

	if (T.SkillSystem != None)
	{
		i = 0;
		aSkill = T.SkillSystem.FirstSkill;
		while (aSkill != None && i < 32)
		{
			if (bIsClient)
				aSkill.CurrentLevel = default.SavedClientSkillLevels[i];
			else
				aSkill.CurrentLevel = default.SavedHostSkillLevels[i];
			i++;
			aSkill = aSkill.next;
		}
	}

	if (T.AugmentationSystem != None)
	{
		i = 0;
		anAug = T.AugmentationSystem.FirstAug;
		while (anAug != None && i < 32)
		{
			if (bIsClient)
				countVal = default.SavedClientAugLevels[i];
			else
				countVal = default.SavedHostAugLevels[i];
			if (countVal >= 10)
			{
				anAug.bHasIt = True;
				anAug.CurrentLevel = countVal - 10;
			}
			i++;
			anAug = anAug.next;
		}
	}
}

function int FindOrAllocNamedProfileSlot(string ProfName, bool bAllocIfMissing)
{
	local int i, freeSlot;
	local string cleanName;

	cleanName = Caps(ProfName);
	if (cleanName == "")
		return -1;

	freeSlot = -1;
	for (i = 0; i < 4; i++)
	{
		if (Caps(default.SavedProfileNames[i]) == cleanName)
			return i;
		if (freeSlot == -1 && default.SavedProfileNames[i] == "")
			freeSlot = i;
	}

	if (!bAllocIfMissing)
		return -1;

	if (freeSlot != -1)
		return freeSlot;

	return 3;
}

function string GetEffectiveProfileName(Trestkon T)
{
	local string profName;

	if (T == None)
		return "";

	profName = T.GetCoopPlayerName();
	if (profName == "" || Caps(profName) == "PLAYER" || Caps(profName) == "TRESTKON")
	{
		if (NetConnection(T.Player) == None)
			profName = "Host";
		else
			profName = "Partner";
	}
	return profName;
}

function SaveNamedCoopProfile(Trestkon T, bool bSavePosition)
{
	local string profName, curMapName;
	local int slot, idx, countVal, dotPos;
	local Inventory inv;
	local Skill aSkill;
	local Augmentation anAug;

	if (T == None)
		return;

	profName = GetEffectiveProfileName(T);

	slot = FindOrAllocNamedProfileSlot(profName, True);
	if (slot < 0 || slot >= 4)
		return;

	default.SavedProfileNames[slot] = profName;

	idx = 0;
	for (inv = T.Inventory; inv != None; inv = inv.Inventory)
	{
		if (idx >= 64)
			break;
		if (inv.IsA('NanoKeyRing') || inv.IsA('WeaponFists'))
			continue;

		countVal = 1;
		if (DeusExWeapon(inv) != None)
			countVal = DeusExWeapon(inv).ClipCount;
		else if (Ammo(inv) != None)
			countVal = Ammo(inv).AmmoAmount;
		else if (DeusExPickup(inv) != None)
			countVal = DeusExPickup(inv).NumCopies;

		default.SavedProfileInvClass[slot * 64 + idx] = string(inv.Class);
		default.SavedProfileInvCount[slot * 64 + idx] = countVal;
		default.SavedProfileInvExtra[slot * 64 + idx] = BuildCoopItemExtraString(T, inv);
		idx++;
	}
	default.SavedProfileInvTotal[slot] = idx;

	default.SavedProfileStats[slot * 10 + 0] = T.HealthHead;
	default.SavedProfileStats[slot * 10 + 1] = T.HealthTorso;
	default.SavedProfileStats[slot * 10 + 2] = T.HealthLegLeft;
	default.SavedProfileStats[slot * 10 + 3] = T.HealthLegRight;
	default.SavedProfileStats[slot * 10 + 4] = T.HealthArmLeft;
	default.SavedProfileStats[slot * 10 + 5] = T.HealthArmRight;
	default.SavedProfileStats[slot * 10 + 6] = int(T.Energy);
	default.SavedProfileStats[slot * 10 + 7] = T.SkillPointsAvail;
	default.SavedProfileStats[slot * 10 + 8] = T.SkillPointsTotal;
	default.SavedProfileStats[slot * 10 + 9] = T.Credits;

	if (T.SkillSystem != None)
	{
		idx = 0;
		aSkill = T.SkillSystem.FirstSkill;
		while (aSkill != None && idx < 32)
		{
			default.SavedProfileSkillLevels[slot * 32 + idx] = aSkill.CurrentLevel;
			idx++;
			aSkill = aSkill.next;
		}
	}

	if (T.AugmentationSystem != None)
	{
		idx = 0;
		anAug = T.AugmentationSystem.FirstAug;
		while (anAug != None && idx < 32)
		{
			if (anAug.bHasIt)
				countVal = 10 + anAug.CurrentLevel;
			else
				countVal = 0;
			default.SavedProfileAugLevels[slot * 32 + idx] = countVal;
			idx++;
			anAug = anAug.next;
		}
	}

	if (bSavePosition)
	{
		dotPos = InStr(string(Self), ".");
		if (dotPos != -1)
			curMapName = Left(string(Self), dotPos);
		default.SavedProfileMap[slot] = curMapName;
		default.SavedProfileLocation[slot] = T.Location;
		default.SavedProfileRotation[slot] = T.Rotation;
	}
	else
	{
		default.SavedProfileMap[slot] = "";
		default.SavedProfileLocation[slot] = vect(0, 0, 0);
	}
}

function bool RestoreNamedCoopProfile(Trestkon T, string ProfName)
{
	local int slot, i, pass, totalInv, countVal, dotPos;
	local string curMapName, extraStr, lookupName;
	local class<Inventory> invClass;
	local Inventory inv, nextInv, existingInv, equippedInv;
	local Skill aSkill;
	local Augmentation anAug;

	if (T == None || !default.bHasCoopSession)
		return False;

	lookupName = ProfName;
	if (lookupName == "" || Caps(lookupName) == "PLAYER" || Caps(lookupName) == "TRESTKON")
		lookupName = GetEffectiveProfileName(T);

	if (T.bCoopNamedProfileRestored && Caps(T.lastRestoredProfileName) == Caps(lookupName))
		return True;

	slot = FindOrAllocNamedProfileSlot(lookupName, False);
	if (slot < 0 || slot >= 4)
	{
		// Legacy fallback only when no named profiles were ever saved in this session
		if (NetConnection(T.Player) != None && default.SavedProfileNames[0] == "" && default.SavedProfileNames[1] == "" && default.SavedClientInvTotal > 0 && !bRestoredClientCreditsThisMap)
		{
			RestorePlayerLoadoutFromDefaults(T, True);
			T.bCoopNamedProfileRestored = True;
			T.lastRestoredProfileName = lookupName;
			bRestoredClientCreditsThisMap = True;
			T.ClientReStart();
			return True;
		}
		return False;
	}

	totalInv = default.SavedProfileInvTotal[slot];
	if (totalInv <= 0 && default.SavedProfileStats[slot * 10 + 1] <= 0)
		return False;

	// Clear starter gear & reset grid slots before restoring saved profile inventory
	for (inv = T.Inventory; inv != None; inv = nextInv)
	{
		nextInv = inv.Inventory;
		if (!inv.IsA('NanoKeyRing') && !inv.IsA('WeaponFists'))
		{
			T.RemoveObjectFromBelt(inv);
			T.DeleteInventory(inv);
			inv.Destroy();
		}
	}
	T.ClearInventorySlots();

	// Pass 0: Restore displayable items (Weapons & Pickups) with PickupAmmoCount=0 so GiveTo never fabricates default ammo
	// Pass 1: Restore exact saved Ammo inventory counts
	for (pass = 0; pass < 2; pass++)
	{
		for (i = 0; i < totalInv; i++)
		{
			invClass = class<Inventory>(DynamicLoadObject(default.SavedProfileInvClass[slot * 64 + i], class'Class', True));
			countVal = default.SavedProfileInvCount[slot * 64 + i];
			extraStr = default.SavedProfileInvExtra[slot * 64 + i];
			if (invClass == None)
				continue;

			if (pass == 0 && ClassIsChildOf(invClass, class'Ammo'))
				continue;
			if (pass == 1 && !ClassIsChildOf(invClass, class'Ammo'))
				continue;

			existingInv = T.FindInventoryType(invClass);
			if (existingInv == None)
			{
				inv = Spawn(invClass, T);
				if (inv != None)
				{
					inv.bHeldItem = True;
					inv.RespawnTime = 0.0;
					if (Weapon(inv) != None)
						Weapon(inv).PickupAmmoCount = 0;
					ApplyCoopItemPlacementAndCharge(T, inv, extraStr, equippedInv);
					inv.GiveTo(T);
					inv.SetBase(T);
					existingInv = inv;
				}
			}

			if (existingInv != None)
			{
				if (Ammo(existingInv) != None)
					Ammo(existingInv).AmmoAmount = Max(0, countVal);
				else if (DeusExPickup(existingInv) != None && DeusExPickup(existingInv).bCanHaveMultipleCopies)
					DeusExPickup(existingInv).NumCopies = Max(1, countVal);
			}
		}
	}

	// Pass 2: Link restored weapons to their exact loaded AmmoName/AmmoType, ClipCount, Mods, and TNM Attributes
	for (i = 0; i < totalInv; i++)
	{
		invClass = class<Inventory>(DynamicLoadObject(default.SavedProfileInvClass[slot * 64 + i], class'Class', True));
		countVal = default.SavedProfileInvCount[slot * 64 + i];
		extraStr = default.SavedProfileInvExtra[slot * 64 + i];
		if (invClass != None && ClassIsChildOf(invClass, class'DeusExWeapon'))
		{
			existingInv = T.FindInventoryType(invClass);
			if (DeusExWeapon(existingInv) != None)
				ApplyCoopWeaponExtraPostAmmo(T, DeusExWeapon(existingInv), countVal, extraStr);
		}
	}

	if (equippedInv != None)
		T.PutInHand(equippedInv);

	if (default.SavedProfileStats[slot * 10 + 1] > 0)
	{
		T.HealthHead     = default.SavedProfileStats[slot * 10 + 0];
		T.HealthTorso    = default.SavedProfileStats[slot * 10 + 1];
		T.HealthLegLeft  = default.SavedProfileStats[slot * 10 + 2];
		T.HealthLegRight = default.SavedProfileStats[slot * 10 + 3];
		T.HealthArmLeft  = default.SavedProfileStats[slot * 10 + 4];
		T.HealthArmRight = default.SavedProfileStats[slot * 10 + 5];
		T.GenerateTotalHealth();
	}
	if (default.SavedProfileStats[slot * 10 + 6] > 0)
		T.Energy = float(default.SavedProfileStats[slot * 10 + 6]);
	T.SkillPointsAvail = default.SavedProfileStats[slot * 10 + 7];
	T.SkillPointsTotal = default.SavedProfileStats[slot * 10 + 8];
	if (!T.bCoopCreditsInit && default.SavedProfileStats[slot * 10 + 9] > 0)
		T.Credits = default.SavedProfileStats[slot * 10 + 9];

	if (T.SkillSystem != None)
	{
		i = 0;
		aSkill = T.SkillSystem.FirstSkill;
		while (aSkill != None && i < 32)
		{
			aSkill.CurrentLevel = default.SavedProfileSkillLevels[slot * 32 + i];
			i++;
			aSkill = aSkill.next;
		}
	}

	if (T.AugmentationSystem != None)
	{
		i = 0;
		anAug = T.AugmentationSystem.FirstAug;
		while (anAug != None && i < 32)
		{
			countVal = default.SavedProfileAugLevels[slot * 32 + i];
			if (countVal >= 10)
			{
				anAug.bHasIt = True;
				anAug.CurrentLevel = countVal - 10;
			}
			i++;
			anAug = anAug.next;
		}
	}

	dotPos = InStr(string(Self), ".");
	if (dotPos != -1)
		curMapName = Left(string(Self), dotPos);
	if (default.SavedProfileMap[slot] != "" && Caps(default.SavedProfileMap[slot]) == Caps(curMapName) && default.SavedProfileLocation[slot] != vect(0, 0, 0))
	{
		T.SetLocation(default.SavedProfileLocation[slot]);
		T.SetRotation(default.SavedProfileRotation[slot]);
		T.ViewRotation = default.SavedProfileRotation[slot];
	}

	T.bCoopNamedProfileRestored = True;
	T.lastRestoredProfileName = lookupName;
	T.ClientReStart();
	T.ClientMessage("Restored saved Co-op inventory & stats for " $ lookupName $ "!");
	return True;
}

function SaveCoopSessionToDefaults(optional string NextMapURL)
{
	local Pawn P;
	local Trestkon T, PrimaryPlayer;
	local TNMMissionScript tnmMS;
	local FlagBase fb;
	local int it, idx, dotPos;
	local Name flagName;
	local DeusExGoal g;
	local DeusExNote n;
	local NanoKeyInfo k;

	if (NextMapURL != "")
	{
		default.SavedCurrentURL = NextMapURL;
		default.SavedHostLocation = vect(0, 0, 0);
		default.SavedClientLocation = vect(0, 0, 0);
	}
	else
	{
		dotPos = InStr(string(Self), ".");
		if (dotPos != -1)
			default.SavedCurrentURL = Left(string(Self), dotPos);
		foreach AllActors(class'TNMMissionScript', tnmMS)
		{
			tnmMS.SaveCoopMapState();
		}
	}

	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		T = Trestkon(P);
		if (T == None)
			continue;
		SaveNamedCoopProfile(T, (NextMapURL == ""));
		if (NetConnection(T.Player) != None)
		{
			default.SavedClientCredits = T.Credits;
			SavePlayerLoadoutToDefaults(T, True);
			if (NextMapURL == "")
			{
				default.SavedClientLocation = T.Location;
				default.SavedClientRotation = T.Rotation;
			}
		}
		else
		{
			default.SavedHostCredits = T.Credits;
			SavePlayerLoadoutToDefaults(T, False);
			if (PrimaryPlayer == None)
			{
				PrimaryPlayer = T;
				if (NextMapURL == "")
				{
					default.SavedHostLocation = T.Location;
					default.SavedHostRotation = T.Rotation;
				}
			}
		}
		if (T.LastMap != "")
			default.SavedLastMap = T.LastMap;
	}

	if (PrimaryPlayer == None)
	{
		for (P = Level.PawnList; P != None; P = P.NextPawn)
		{
			if (Trestkon(P) != None)
			{
				PrimaryPlayer = Trestkon(P);
				break;
			}
		}
	}

	if (PrimaryPlayer == None || PrimaryPlayer.flagBase == None)
		return;

	fb = PrimaryPlayer.flagBase;
	fb.SetBool('PlayerTraveling', True, True, 0);

	idx = 0;
	it = fb.CreateIterator(FLAG_Bool);
	while (fb.GetNextFlagName(it, flagName))
	{
		if (flagName != '' && idx < ArrayCount(default.SavedBoolNames))
		{
			if (Left(string(flagName), 3) == "CS_" && !fb.GetBool(flagName))
				continue;
			default.SavedBoolNames[idx] = string(flagName);
			if (fb.GetBool(flagName))
				default.SavedBoolVals[idx] = 1;
			else
				default.SavedBoolVals[idx] = 0;
			default.SavedBoolExps[idx] = fb.GetExpiration(flagName, FLAG_Bool);
			idx++;
		}
	}
	fb.DestroyIterator(it);
	default.SavedBoolCount = idx;

	idx = 0;
	it = fb.CreateIterator(FLAG_Byte);
	while (fb.GetNextFlagName(it, flagName))
	{
		if (flagName != '' && idx < ArrayCount(default.SavedByteNames))
		{
			default.SavedByteNames[idx] = string(flagName);
			default.SavedByteVals[idx] = fb.GetByte(flagName);
			default.SavedByteExps[idx] = fb.GetExpiration(flagName, FLAG_Byte);
			idx++;
		}
	}
	fb.DestroyIterator(it);
	default.SavedByteCount = idx;

	idx = 0;
	it = fb.CreateIterator(FLAG_Int);
	while (fb.GetNextFlagName(it, flagName))
	{
		if (flagName != '' && flagName != 'SKTemp_SkillPointsAvail' && flagName != 'SKTemp_SkillPointsTotal' && idx < ArrayCount(default.SavedIntNames))
		{
			default.SavedIntNames[idx] = string(flagName);
			default.SavedIntVals[idx] = fb.GetInt(flagName);
			default.SavedIntExps[idx] = fb.GetExpiration(flagName, FLAG_Int);
			idx++;
		}
	}
	fb.DestroyIterator(it);
	default.SavedIntCount = idx;

	idx = 0;
	it = fb.CreateIterator(FLAG_Float);
	while (fb.GetNextFlagName(it, flagName))
	{
		if (flagName != '' && idx < ArrayCount(default.SavedFloatNames))
		{
			default.SavedFloatNames[idx] = string(flagName);
			default.SavedFloatVals[idx] = fb.GetFloat(flagName);
			default.SavedFloatExps[idx] = fb.GetExpiration(flagName, FLAG_Float);
			idx++;
		}
	}
	fb.DestroyIterator(it);
	default.SavedFloatCount = idx;

	idx = 0;
	it = fb.CreateIterator(FLAG_Name);
	while (fb.GetNextFlagName(it, flagName))
	{
		if (flagName != '' && idx < ArrayCount(default.SavedNameNames))
		{
			default.SavedNameNames[idx] = string(flagName);
			default.SavedNameVals[idx] = string(fb.GetName(flagName));
			default.SavedNameExps[idx] = fb.GetExpiration(flagName, FLAG_Name);
			idx++;
		}
	}
	fb.DestroyIterator(it);
	default.SavedNameCount = idx;

	idx = 0;
	g = PrimaryPlayer.FirstGoal;
	while (g != None && idx < ArrayCount(default.SavedGoalNames))
	{
		default.SavedGoalNames[idx] = string(g.goalName);
		if (g.bPrimaryGoal)
			default.SavedGoalPrimary[idx] = 1;
		else
			default.SavedGoalPrimary[idx] = 0;
		if (g.bCompleted)
			default.SavedGoalCompleted[idx] = 1;
		else
			default.SavedGoalCompleted[idx] = 0;
		default.SavedGoalText[idx] = g.text;
		idx++;
		g = g.next;
	}
	default.SavedGoalCount = idx;

	idx = 0;
	n = PrimaryPlayer.FirstNote;
	while (n != None && idx < ArrayCount(default.SavedNoteText))
	{
		default.SavedNoteText[idx] = n.text;
		if (n.bUserNote)
			default.SavedNoteUser[idx] = 1;
		else
			default.SavedNoteUser[idx] = 0;
		default.SavedNoteTag[idx] = string(n.textTag);
		idx++;
		n = n.next;
	}
	default.SavedNoteCount = idx;

	idx = 0;
	k = PrimaryPlayer.KeyList;
	while (k != None && idx < ArrayCount(default.SavedKeyIDs))
	{
		default.SavedKeyIDs[idx] = string(k.KeyID);
		default.SavedKeyDescs[idx] = k.Description;
		idx++;
		k = k.NextKey;
	}
	default.SavedKeyCount = idx;

	default.bHasActiveTravelSession = True;
	default.bHasCoopSession = True;
	StaticSaveConfig();
	class'CoopSaveSlotManager'.static.CopyActiveSessionToSlot(class'CoopSaveSlotManager'.static.GetActiveSlot());
	log("CoopMod: Saved session to defaults & TNMCoopSave.ini (slot=" $ (class'CoopSaveSlotManager'.static.GetActiveSlot() + 1) $ ", bools=" $ default.SavedBoolCount $ ", ints=" $ default.SavedIntCount $ ", goals=" $ default.SavedGoalCount $ ", notes=" $ default.SavedNoteCount $ ", keys=" $ default.SavedKeyCount $ ")");
}

function RestoreCoopSessionFromDefaults(Trestkon T)
{
	local int i, sharedCreds;
	local Name fName, fValName;
	local DeusExGoal g;
	local DeusExNote n;
	local Trestkon HostP;

	if (T == None || !default.bHasActiveTravelSession)
		return;

	if (T.KeyRing == None)
		T.CreateKeyRing();
	if (T.flagBase == None)
		return;

	if (default.SavedLastMap != "")
		T.LastMap = default.SavedLastMap;

	sharedCreds = Max(default.SavedHostCredits, default.SavedClientCredits);
	HostP = Trestkon(GetPlayerPawn());
	if (HostP != None && HostP != T && HostP.bCoopCreditsInit)
		sharedCreds = HostP.Credits;

	if (NetConnection(T.Player) != None)
	{
		T.Credits = sharedCreds;
		T.bCoopCreditsInit = True;
		T.lastKnownCredits = sharedCreds;
		if (T.coopPlayerName != "" && !T.bCoopNamedProfileRestored)
			RestoreNamedCoopProfile(T, T.coopPlayerName);
		if (!bRestoredClientCreditsThisMap)
		{
			if (!T.bCoopNamedProfileRestored && default.SavedProfileNames[0] == "" && default.SavedProfileNames[1] == "" && default.SavedClientInvTotal > 0)
				RestorePlayerLoadoutFromDefaults(T, True);
			if (!T.bCoopNamedProfileRestored && default.bRestoreSavedPositions && default.SavedClientLocation != vect(0, 0, 0))
			{
				T.SetLocation(default.SavedClientLocation);
				T.SetRotation(default.SavedClientRotation);
				T.ViewRotation = default.SavedClientRotation;
			}
			bRestoredClientCreditsThisMap = True;
		}
		return;
	}

	if (bRestoredCoopSessionThisMap)
		return;

	bRestoredCoopSessionThisMap = True;
	T.Credits = sharedCreds;
	T.bCoopCreditsInit = True;
	T.lastKnownCredits = sharedCreds;

	if (default.bForceRestoreLoadout)
	{
		T.DeleteAllGoals();
		T.DeleteAllNotes();
		if (T.KeyRing != None)
			T.KeyRing.RemoveAllKeys();
	}

	// ALWAYS restore Host's saved named profile / loadout on BOTH zone transitions
	// and save-slot loads (because Login() runs ResetPlayerToDefaults() on ServerTravel!)
	if (!RestoreNamedCoopProfile(T, GetEffectiveProfileName(T)))
		RestorePlayerLoadoutFromDefaults(T, False);

	if (!T.bCoopNamedProfileRestored && default.bRestoreSavedPositions && default.SavedHostLocation != vect(0, 0, 0))
	{
		T.SetLocation(default.SavedHostLocation);
		T.SetRotation(default.SavedHostRotation);
		T.ViewRotation = default.SavedHostRotation;
	}

	for (i = 0; i < default.SavedBoolCount; i++)
	{
		fName = T.SafeStringToName(default.SavedBoolNames[i]);
		if (fName != '')
			T.flagBase.SetBool(fName, (default.SavedBoolVals[i] != 0), True, default.SavedBoolExps[i]);
	}

	for (i = 0; i < default.SavedByteCount; i++)
	{
		fName = T.SafeStringToName(default.SavedByteNames[i]);
		if (fName != '')
			T.flagBase.SetByte(fName, default.SavedByteVals[i], True, default.SavedByteExps[i]);
	}

	for (i = 0; i < default.SavedIntCount; i++)
	{
		fName = T.SafeStringToName(default.SavedIntNames[i]);
		if (fName != '')
			T.flagBase.SetInt(fName, default.SavedIntVals[i], True, default.SavedIntExps[i]);
	}

	for (i = 0; i < default.SavedFloatCount; i++)
	{
		fName = T.SafeStringToName(default.SavedFloatNames[i]);
		if (fName != '')
			T.flagBase.SetFloat(fName, default.SavedFloatVals[i], True, default.SavedFloatExps[i]);
	}

	for (i = 0; i < default.SavedNameCount; i++)
	{
		fName = T.SafeStringToName(default.SavedNameNames[i]);
		fValName = T.SafeStringToName(default.SavedNameVals[i]);
		if (fName != '')
			T.flagBase.SetName(fName, fValName, True, default.SavedNameExps[i]);
	}

	for (i = 0; i < default.SavedGoalCount; i++)
	{
		fName = T.SafeStringToName(default.SavedGoalNames[i]);
		if (fName != '' && T.FindGoal(fName) == None)
		{
			g = T.AddGoal(fName, (default.SavedGoalPrimary[i] != 0));
			if (g != None)
			{
				g.SetText(default.SavedGoalText[i]);
				if (default.SavedGoalCompleted[i] != 0)
					g.SetCompleted();
			}
		}
	}

	for (i = 0; i < default.SavedNoteCount; i++)
	{
		if (default.SavedNoteText[i] != "")
		{
			n = T.AddNote(default.SavedNoteText[i], (default.SavedNoteUser[i] != 0), True);
			if (n != None && default.SavedNoteTag[i] != "")
				n.SetTextTag(T.SafeStringToName(default.SavedNoteTag[i]));
		}
	}

	if (T.KeyRing != None)
	{
		for (i = 0; i < default.SavedKeyCount; i++)
		{
			fName = T.SafeStringToName(default.SavedKeyIDs[i]);
			if (fName != '' && !T.KeyRing.HasKey(fName))
				T.KeyRing.GiveKey(fName, default.SavedKeyDescs[i]);
		}
	}

	T.flagBase.SetBool('PlayerTraveling', True, True, 0);
	log("CoopMod: Restored session from defaults for " $ T $ " (bools=" $ default.SavedBoolCount $ ", ints=" $ default.SavedIntCount $ ", goals=" $ default.SavedGoalCount $ ", notes=" $ default.SavedNoteCount $ ", keys=" $ default.SavedKeyCount $ ")");
}

function LogAllSuspiciousEntities()
{
	local ScriptedTexture ST;
	local Info TInfo;
	
	Log("BEGINNING DEBUG LOG FOR SUSPICIOUS CRAP:");
	
	forEach AllActors(class'Info', TInfo)
	{
		Log(TInfo);
	}
	
	forEach AllObjects(class'ScriptedTexture', ST)
	{
		Log(ST);
	}
}

function LoadPaths( PlayerPawn Player )
{
    local string PathsString, EntryString;
    local int P;

    //Get the "Regular" paths since that will work even if we are not using LaunchSystem.
    PathsString = player.ConsoleCommand("GET System Paths");
    //Log( "PathsString="$PathsString );
    PathsString = Mid(PathsString, 1, Len(PathsString) - 2);

    // Cut my path into pieces, this is..
    P = InStr(PathsString, ",");
    if (P == -1)
        P = Len(PathsString);

    PathsNum = 0;
    while (P > 0)
    {
        EntryString = Left(PathsString, P);
        EntryString          = Mid(EntryString, 1, Len(EntryString)-2);
        PathsString          = Right(PathsString, Len(PathsString)-P-1);
        P                    = InStr(EntryString, "*.");
        Paths[PathsNum].Path = Left(EntryString, P);
        Paths[PathsNum].Ext  = Right(EntryString, Len(EntryString)-P-2);
        P = InStr(PathsString, ",");
        if (P == -1)
            P = Len(PathsString);
        // Log( Paths[PathsNum].Path );
        // Log( Paths[PathsNum].Ext );
        PathsNum++;
    }
}

function AddPathToTop(PathsEntry NewPath)
{
    local int i;

    //We can't fit more paths, return so we don't overflow the array.
    if (PathsNum - 1 >= ArrayCount(Paths))
        return;

    //Shift path entries one entry so we can add a new one at place 0.
    for (i = PathsNum-1; i >= 0; i--)
        Paths[i+1] = Paths[i];

    Paths[0] = NewPath;
    PathsNum++;
}

function string GeneratePathString()
{
    local string PathsString;
    local int P;
    local bool bNeedSeperator;

    bNeedSeperator = False;

    // Reassemble and set.
    PathsString = "(";
    for (P=0; P < PathsNum; P++)
    {
        if (Paths[P].Path != "")
        {
            // REV_HAN: Fixed seperator handling.
            if (bNeedSeperator)
                PathsString = PathsString $ ",";
            bNeedSeperator = True;

            ReplaceText(Paths[P].Path, "\\", "\\\\");
            PathsString = PathsString $ "\"" $ Paths[P].Path $ "*." $ Paths[P].Ext $ "\"";
        }
    }
    PathsString = PathsString $ ")";
    //Log( PathsString );
    return PathsString;
}

// Copied out of UWindowWindow.
final function ReplaceText(out string Text, string Replace, string With)
{
    local int i;
    local string Input;

    Input = Text;
    Text = "";
    i = InStr(Input, Replace);
    while(i != -1)
    {
        Text = Text $ Left(Input, i) $ With;
        Input = Mid(Input, i + Len(Replace));
        i = InStr(Input, Replace);
    }
    Text = Text $ Input;
}

static function GetActiveBoolEntry(int idx, out string n, out byte v, out int e)
{
	n = default.SavedBoolNames[idx];
	v = default.SavedBoolVals[idx];
	e = default.SavedBoolExps[idx];
}

static function SetActiveBoolEntry(int idx, string n, byte v, int e)
{
	default.SavedBoolNames[idx] = n;
	default.SavedBoolVals[idx] = v;
	default.SavedBoolExps[idx] = e;
}

static function GetActiveByteEntry(int idx, out string n, out byte v, out int e)
{
	n = default.SavedByteNames[idx];
	v = default.SavedByteVals[idx];
	e = default.SavedByteExps[idx];
}

static function SetActiveByteEntry(int idx, string n, byte v, int e)
{
	default.SavedByteNames[idx] = n;
	default.SavedByteVals[idx] = v;
	default.SavedByteExps[idx] = e;
}

static function GetActiveIntEntry(int idx, out string n, out int v, out int e)
{
	n = default.SavedIntNames[idx];
	v = default.SavedIntVals[idx];
	e = default.SavedIntExps[idx];
}

static function SetActiveIntEntry(int idx, string n, int v, int e)
{
	default.SavedIntNames[idx] = n;
	default.SavedIntVals[idx] = v;
	default.SavedIntExps[idx] = e;
}

static function GetActiveFloatEntry(int idx, out string n, out float v, out int e)
{
	n = default.SavedFloatNames[idx];
	v = default.SavedFloatVals[idx];
	e = default.SavedFloatExps[idx];
}

static function SetActiveFloatEntry(int idx, string n, float v, int e)
{
	default.SavedFloatNames[idx] = n;
	default.SavedFloatVals[idx] = v;
	default.SavedFloatExps[idx] = e;
}

static function GetActiveNameEntry(int idx, out string n, out string v, out int e)
{
	n = default.SavedNameNames[idx];
	v = default.SavedNameVals[idx];
	e = default.SavedNameExps[idx];
}

static function SetActiveNameEntry(int idx, string n, string v, int e)
{
	default.SavedNameNames[idx] = n;
	default.SavedNameVals[idx] = v;
	default.SavedNameExps[idx] = e;
}

static function GetActiveGoalEntry(int idx, out string n, out byte p, out byte c, out string t)
{
	n = default.SavedGoalNames[idx];
	p = default.SavedGoalPrimary[idx];
	c = default.SavedGoalCompleted[idx];
	t = default.SavedGoalText[idx];
}

static function SetActiveGoalEntry(int idx, string n, byte p, byte c, string t)
{
	default.SavedGoalNames[idx] = n;
	default.SavedGoalPrimary[idx] = p;
	default.SavedGoalCompleted[idx] = c;
	default.SavedGoalText[idx] = t;
}

static function GetActiveNoteEntry(int idx, out string t, out byte u, out string tg)
{
	t = default.SavedNoteText[idx];
	u = default.SavedNoteUser[idx];
	tg = default.SavedNoteTag[idx];
}

static function SetActiveNoteEntry(int idx, string t, byte u, string tg)
{
	default.SavedNoteText[idx] = t;
	default.SavedNoteUser[idx] = u;
	default.SavedNoteTag[idx] = tg;
}

static function GetActiveKeyEntry(int idx, out string id, out string d)
{
	id = default.SavedKeyIDs[idx];
	d = default.SavedKeyDescs[idx];
}

static function SetActiveKeyEntry(int idx, string id, string d)
{
	default.SavedKeyIDs[idx] = id;
	default.SavedKeyDescs[idx] = d;
}

static function GetActiveInvEntry(int idx, out string hCls, out int hCnt, out string cCls, out int cCnt)
{
	hCls = default.SavedHostInvClass[idx];
	hCnt = default.SavedHostInvCount[idx];
	cCls = default.SavedClientInvClass[idx];
	cCnt = default.SavedClientInvCount[idx];
}

static function SetActiveInvEntry(int idx, string hCls, int hCnt, string cCls, int cCnt)
{
	default.SavedHostInvClass[idx] = hCls;
	default.SavedHostInvCount[idx] = hCnt;
	default.SavedClientInvClass[idx] = cCls;
	default.SavedClientInvCount[idx] = cCnt;
}

static function GetActiveInvExtraEntry(int idx, out string hExt, out string cExt)
{
	hExt = default.SavedHostInvExtra[idx];
	cExt = default.SavedClientInvExtra[idx];
}

static function SetActiveInvExtraEntry(int idx, string hExt, string cExt)
{
	default.SavedHostInvExtra[idx] = hExt;
	default.SavedClientInvExtra[idx] = cExt;
}

static function GetActiveSkillAugEntry(int idx, out int hSk, out int cSk, out int hAug, out int cAug)
{
	hSk = default.SavedHostSkillLevels[idx];
	cSk = default.SavedClientSkillLevels[idx];
	hAug = default.SavedHostAugLevels[idx];
	cAug = default.SavedClientAugLevels[idx];
}

static function SetActiveSkillAugEntry(int idx, int hSk, int cSk, int hAug, int cAug)
{
	default.SavedHostSkillLevels[idx] = hSk;
	default.SavedClientSkillLevels[idx] = cSk;
	default.SavedHostAugLevels[idx] = hAug;
	default.SavedClientAugLevels[idx] = cAug;
}

static function GetActiveStatEntry(int idx, out int hSt, out int cSt)
{
	hSt = default.SavedHostStats[idx];
	cSt = default.SavedClientStats[idx];
}

static function SetActiveStatEntry(int idx, int hSt, int cSt)
{
	default.SavedHostStats[idx] = hSt;
	default.SavedClientStats[idx] = cSt;
}

static function GetActiveProfileMeta(int p, out string pName, out int invTot, out vector loc, out rotator rot, out string mapStr)
{
	pName = default.SavedProfileNames[p];
	invTot = default.SavedProfileInvTotal[p];
	loc = default.SavedProfileLocation[p];
	rot = default.SavedProfileRotation[p];
	mapStr = default.SavedProfileMap[p];
}

static function SetActiveProfileMeta(int p, string pName, int invTot, vector loc, rotator rot, string mapStr)
{
	default.SavedProfileNames[p] = pName;
	default.SavedProfileInvTotal[p] = invTot;
	default.SavedProfileLocation[p] = loc;
	default.SavedProfileRotation[p] = rot;
	default.SavedProfileMap[p] = mapStr;
}

static function GetActiveProfileInv(int idx, out string clsStr, out int cnt)
{
	clsStr = default.SavedProfileInvClass[idx];
	cnt = default.SavedProfileInvCount[idx];
}

static function SetActiveProfileInv(int idx, string clsStr, int cnt)
{
	default.SavedProfileInvClass[idx] = clsStr;
	default.SavedProfileInvCount[idx] = cnt;
}

static function string GetActiveProfileInvExtra(int idx)
{
	return default.SavedProfileInvExtra[idx];
}

static function SetActiveProfileInvExtra(int idx, string extStr)
{
	default.SavedProfileInvExtra[idx] = extStr;
}

static function GetActiveProfileSkillAug(int idx, out int sk, out int aug)
{
	sk = default.SavedProfileSkillLevels[idx];
	aug = default.SavedProfileAugLevels[idx];
}

static function SetActiveProfileSkillAug(int idx, int sk, int aug)
{
	default.SavedProfileSkillLevels[idx] = sk;
	default.SavedProfileAugLevels[idx] = aug;
}

static function GetActiveProfileStat(int idx, out int st)
{
	st = default.SavedProfileStats[idx];
}

static function SetActiveProfileStat(int idx, int st)
{
	default.SavedProfileStats[idx] = st;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     UpdateMessage="Update complete, new settings enabled."
     UpdateRebootMessage="Patch detected, game will now restart in order to update settings."
     MutatorClass=Class'TNM.TNMMutator'
}

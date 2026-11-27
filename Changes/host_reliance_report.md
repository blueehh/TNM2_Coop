# Co-op script scan

| Rule | Severity | Count |
|---|---|---|
| FIRST_PLAYER_ONLY | warning | 8 |
| HOST_ONLY | warning | 27 |
| MISSION_HOST_PLAYER | warning | 30 |
| HOST_ONLY | info | 181 |
| HOST_ONLY_FLAGS | info | 9 |

## ATMinfo
- **WARNING** HOST_ONLY line 22 `Tick`: `player = Trestkon(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## CoopTradeMenuWindow
- **WARNING** HOST_ONLY line 408 `Tick`: `myPlayer = Trestkon(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.
- **INFO** HOST_ONLY line 512 `RefreshPlayerSlots`: `myPlayer = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 562 `ButtonActivated`: `myPlayer = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## CreditsImageTrigger
- **INFO** HOST_ONLY line 11 `Trigger`: `trestkon(getplayerpawn()).displayimg(imagex, imagey, imageTex, LiveTime, FadeTime);`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **WARNING** HOST_ONLY line 20 `Touch`: `trestkon(getplayerpawn()).displayimg(imagex, imagey, imageTex, LiveTime, FadeTime);`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## creditstexttrigger
- **INFO** HOST_ONLY line 15 `Trigger`: `trestkon(getplayerpawn()).displaytext(textx,texty,text, LiveTime, FadeTime, Color);`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **WARNING** HOST_ONLY line 25 `Touch`: `trestkon(getplayerpawn()).displaytext(textx,texty,text, LiveTime, FadeTime, Color);`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## crouchTrigger
- **WARNING** HOST_ONLY line 22 `Tick`: `t=trestkon(getplayerpawn()); //foreach radiusactors sucks hard.`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## CutsceneShakeTrigger
- **WARNING** HOST_ONLY line 18 `Tick`: `cam=Trestkon(GetPlayerPawn()).CurrentCam;`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## DrownTrigger
- **WARNING** HOST_ONLY line 10 `Tick`: `player=Trestkon(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.
- **INFO** HOST_ONLY line 33 `Trigger`: `player=Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## insanedeathtrigger
- **WARNING** HOST_ONLY line 16 `Tick`: `player=Trestkon(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.
- **INFO** HOST_ONLY line 44 `Trigger`: `player=Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 57 `UnTrigger`: `player=Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## insanetrigger
- **INFO** HOST_ONLY line 30 `PlayBark`: `player=trestkon(getplayerpawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **WARNING** HOST_ONLY line 37 `Tick`: `player=trestkon(getplayerpawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## Invader
- **INFO** HOST_ONLY line 38 `PostPostBeginPlay`: `player = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 60 `EnterWorld`: `SetSkin(Trestkon(GetPlayerPawn()));`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **WARNING** FIRST_PLAYER_ONLY line 226 `InitializeInventory`: `foreach AllActors(class'trestkon', player)`  
  Loop over players stops at the first one (the host in practice). Handle every player, or pick the relevant one explicitly.
- **INFO** HOST_ONLY line 395 `ResetSkinStyle`: `player = getplayerpawn();`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## PongTextureController
- **WARNING** HOST_ONLY line 289 `Player1Scored`: `A.Trigger(Self, getPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.
- **WARNING** HOST_ONLY line 299 `Player2Scored`: `A.Trigger(Self, getPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## ScriptedMapTextureController
- **WARNING** HOST_ONLY line 29 `Tick`: `Player = Trestkon(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## StaringMover
- **INFO** HOST_ONLY_FLAGS line 76 `AlarmHeard`: `if (!Trestkon(GetPlayerPawn()).flagbase.GetBool(disableFlag))`  
  Reads/writes the host flagBase. Fine while tnmGameInfo.CoopMergeFlags runs (host<->client merge every second).
- **WARNING** HOST_ONLY line 552 `Tick`: `thePlayer = DeusExPlayer(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## TNMBarkManager
- **WARNING** FIRST_PLAYER_ONLY line 15 `CheckRadius`: `foreach AllActors(class'Trestkon', T)`  
  Loop over players stops at the first one (the host in practice). Handle every player, or pick the relevant one explicitly.
- **INFO** HOST_ONLY line 140 `StartBark`: `if(DeusExPlayer(GetPlayerPawn()).DrugEffectTimer < 0)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## tnmconplay
- **INFO** HOST_ONLY line 1192 `SetupEventCheckFlag`: `return class'tnmconplay'.static.g_SetupEventCheckFlag(deusexplayer(GetPlayerPawn()),event,nextLabel);`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **WARNING** FIRST_PLAYER_ONLY line 1244 `g_FlagSet`: `foreach player.AllActors(class'Trestkon', T)`  
  Loop over players stops at the first one (the host in practice). Handle every player, or pick the relevant one explicitly.
- **WARNING** FIRST_PLAYER_ONLY line 1259 `g_FlagSet`: `foreach player.AllActors(class'Trestkon', T)`  
  Loop over players stops at the first one (the host in practice). Handle every player, or pick the relevant one explicitly.

## tnmdatalinkplay
- **INFO** HOST_ONLY line 229 `SetupEventCheckFlag`: `return class'tnmconplay'.static.g_SetupEventCheckFlag(deusexplayer(GetPlayerPawn()),event,nextLabel);`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **WARNING** FIRST_PLAYER_ONLY line 430 `SetupEventCheckObject`: `foreach AllActors(class'Trestkon', T)`  
  Loop over players stops at the first one (the host in practice). Handle every player, or pick the relevant one explicitly.

## tnmFakeLaserAutoTurret
- **INFO** HOST_ONLY line 69 `Fire`: `attacker = GetPlayerPawn();`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **WARNING** HOST_ONLY line 261 `Tick`: `else if (pawn.IsA('ScriptedPawn') && (ScriptedPawn(pawn).GetPawnAllianceType(GetPlayerPawn()) != ALLIANCE_Hostile) && (pawn.Mass > 2)) // Exclude rats, flies, fish, etc`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.
- **WARNING** HOST_ONLY line 289 `Tick`: `if (sp.bDetectable && !sp.bIgnore && (sp.GetPawnAllianceType(GetPlayerPawn()) == ALLIANCE_Hostile))`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## TNMGameInfo
- **INFO** HOST_ONLY line 959 `SyncCoopState`: `HostPlayer = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **WARNING** HOST_ONLY line 1489 `Tick`: `Host = Trestkon(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.
- **INFO** HOST_ONLY line 1546 `CoopClosestPlayer`: `Best = GetPlayerPawn();`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 1583 `CoopRadiusConversations`: `Host = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 1755 `CoopAcquireTurretTarget`: `HostPawn = GetPlayerPawn();`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## tnmMission22
- **INFO** HOST_ONLY line 212 `CarCrash`: `Trestkon(GetPlayerPawn()).SetAchievement("achHovercar");`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **WARNING** MISSION_HOST_PLAYER line 676 `FirstFrame`: `if (player.inhand != none && player.inhand.isA( 'tnmpovcorpse' ) && tnmpovcorpse(player.inhand).givenbindname == "Zero")`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 724 `FirstFrame`: `if (player.inhand != none && player.inhand.isA( 'tnmpovcorpse' ) && tnmpovcorpse(player.inhand).givenbindname == "Slicer")`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **INFO** HOST_ONLY line 2031 `Timer`: `trestkon(getplayerpawn()).autosave(true, 22);`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **WARNING** MISSION_HOST_PLAYER line 2531 `Timer`: `ScriptedP.SetRotation(Rotator(Player.Location - SP.Location));`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 2609 `Timer`: `ScriptedP.SetRotation(Rotator(Player.Location - SP.Location));`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 3121 `AlphaPhase2Break`: `ScriptedP.SetRotation(Rotator(Player.Location - SP.Location));`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 3248 `AlphaPhase2Start`: `ScriptedP.SetRotation(Rotator(Player.Location - SP.Location));`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 3322 `AlphaPhase3Break`: `ScriptedP.SetRotation(Rotator(Player.Location - SP.Location));`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 3452 `AlphaPhase3Start`: `ScriptedP.SetRotation(Rotator(Player.Location - SP.Location));`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 3580 `AlphaPhase4Break`: `ScriptedP.SetRotation(Rotator(Player.Location - SP.Location));`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 3707 `AlphaPhase4Start`: `ScriptedP.SetRotation(Rotator(Player.Location - SP.Location));`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 4114 `CitadelExplosionEffects`: `if (Player.IsInState('ConversatFion'))`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 4134 `CitadelExplosionEffects`: `if (Player.IsInState('PlayerWalking') && Player.Physics != PHYS_Falling)`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 4162 `CitadelExplosionEffects`: `loc = Player.Location + 256.0 * VRand();`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 4163 `CitadelExplosionEffects`: `loc.Z = Player.Location.Z;`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 4439 `GetRegistrationSpawnClass`: `PossibleAmmo = Ammo(Player.FindInventoryType(DeusExWeapon(inv).AmmoNames[0]));`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 4441 `GetRegistrationSpawnClass`: `PossibleAmmo = Ammo(Player.FindInventoryType(DeusExWeapon(inv).AmmoName));`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).

## tnmMission23
- **INFO** HOST_ONLY line 89 `SpawnChopperWreck`: `player = deusexplayer(getplayerpawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 292 `FirstFrame`: `player = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 355 `FirstFrame`: `player = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 543 `FirstFrame`: `player = deusexplayer(getplayerpawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 921 `Timer`: `trestkon(getplayerpawn()).autosave(true, 23);`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **WARNING** MISSION_HOST_PLAYER line 1022 `Timer`: `if (Player.IsInState('Dying') && flags.GetBool('MS_ABIBossTauntSent') && !flags.GetBool('MS_PlayerCaptured') && playerkiller != None)`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).

## tnmMission24
- **INFO** HOST_ONLY line 63 `TrestAblaze`: `debuggerFire = spawn(class'tnmFire', getplayerpawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 120 `checkNarcissusEnding`: `t=trestkon(getplayerpawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **WARNING** HOST_ONLY line 687 `FirstFrame`: `m.trigger(m,getplayerpawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.
- **INFO** HOST_ONLY line 862 `Timer`: `trestkon(getplayerpawn()).autosave(true, 24);`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **WARNING** MISSION_HOST_PLAYER line 961 `Timer`: `if (flags.GetBool('MS_StartNewGamePlus') && flags.GetBool('Narcissus_Greeting_Played') && !Player.IsInState('Conversation'))`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 1065 `Timer`: `if (!player.IsInState('Dying'))`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 1314 `ShipExplosionEffects`: `if ( !player.IsInState('Conversation') )`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 1316 `ShipExplosionEffects`: `if (Player.IsInState('PlayerWalking') && Player.Physics != PHYS_Falling)`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 1337 `ShipExplosionEffects`: `if (Abs(player.location.Z - window.location.Z) < 100)`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 1354 `ShipExplosionEffects`: `loc = Player.Location + 256.0 * VRand();`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 1355 `ShipExplosionEffects`: `loc.Z = Player.Location.Z;`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).

## tnmmissionbonus
- **INFO** HOST_ONLY line 12 `ShowCheatList`: `trestkon(getplayerpawn()).bUnlockedTrack121 = true;`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **INFO** HOST_ONLY line 13 `ShowCheatList`: `trestkon(getplayerpawn()).bUnlockedTrack123 = true;`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **INFO** HOST_ONLY line 14 `ShowCheatList`: `trestkon(getplayerpawn()).SaveConfig();`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **WARNING** HOST_ONLY line 25 `firstframe`: `Trestkon(GetPlayerPawn()).xAxis = PS.Location.X;`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.
- **WARNING** HOST_ONLY line 26 `firstframe`: `Trestkon(GetPlayerPawn()).yAxis = PS.Location.Y;`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.
- **INFO** HOST_ONLY line 28 `firstframe`: `trestkon(getplayerpawn()).platform(true);`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 30 `firstframe`: `trestkon(getplayerpawn()).bUnlockedTrack97 = true;`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **INFO** HOST_ONLY line 31 `firstframe`: `trestkon(getplayerpawn()).bUnlockedTrack98 = true;`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **INFO** HOST_ONLY line 32 `firstframe`: `trestkon(getplayerpawn()).SetPropertyText(localURL $ "_Unlocked", "True");`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **INFO** HOST_ONLY line 33 `firstframe`: `trestkon(getplayerpawn()).SaveConfig();`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.

## tnmmissioncombat
- **WARNING** MISSION_HOST_PLAYER line 36 `firstframe`: `Timer = Spawn( class'TNMTimer', ,, Player.Location, Rot(16384,0,0));`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **INFO** HOST_ONLY line 442 `InitStateMachine`: `Player = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **WARNING** MISSION_HOST_PLAYER line 867 `CombatEnded`: `be = Spawn(class'Beam',,, Player.Location);`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).

## TNMMissionScript
- **WARNING** MISSION_HOST_PLAYER line 470 `FirstFrame`: `if((Trestkon(Player).bUseAutosave/* > 0*/) && dxInfo != None && !(player.IsInState('Dying')) && !(player.IsInState('Paralyzed')) && !(player.IsInState('Interpolating')) && !(player.IsInState('Conversa`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 865 `Timer`: `if((Trestkon(Player).bUseAutosave/* > 0*/) && dxInfo != None && !(player.IsInState('Dying')) && !(player.IsInState('Paralyzed')) && !(player.IsInState('Interpolating')) && !(player.IsInState('Conversa`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **INFO** HOST_ONLY line 901 `PreTravel`: `Player = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 937 `SaveCoopMapState`: `Player = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 1741 `InitStateMachine`: `Player = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## tnmmissionstealth
- **WARNING** MISSION_HOST_PLAYER line 36 `firstframe`: `Timer = Spawn( class'TNMTimer', ,, Player.Location, Rot(16384,0,0));`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **INFO** HOST_ONLY line 333 `InitStateMachine`: `Player = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **WARNING** MISSION_HOST_PLAYER line 763 `StealthEnded`: `be = Spawn(class'Beam',,, Player.Location);`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).

## TNMOggMusicManager
- **INFO** HOST_ONLY line 215 `init`: `P = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **WARNING** HOST_ONLY line 293 `Tick`: `player = trestkon(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## TNMPawn
- **INFO** HOST_ONLY line 200 `CoopPlayerFor`: `return GetPlayerPawn();`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 372 `GetPlayer`: `localPlayer = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 894 `PlayTheftSound`: `dxPlayer = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **WARNING** HOST_ONLY line 2329 `HandleDamage`: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.
- **INFO** HOST_ONLY line 2330 `HandleDamage`: `if (Trestkon(GetPlayerPawn()) != None)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 2331 `HandleDamage`: `Trestkon(GetPlayerPawn()).SetAchievement("achRice"); // Assume player`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **INFO** HOST_ONLY line 3904 `PlayFootStep`: `if ((GetPlayerPawn() != None) && (SendNoiseHeightTolerance > 0))`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 3906 `PlayFootStep`: `PlayRadius *= ScaleSoundByHeight(SendNoiseHeightTolerance, GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 3933 `PlayFootStep`: `dxPlayer = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 4320 `StunnedTaser.EndState`: `Trestkon(GetPlayerPawn()).SetAchievement("achTaser"); // Assume players`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **WARNING** HOST_ONLY line 4489 `AlphaFirewallDeath.BeginState`: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.
- **INFO** HOST_ONLY_FLAGS line 4586 `AlphaFirewallDeathLong.BeginState`: `while (DeusExPlayer(GetPlayerPawn()).flagBase != None && !DeusExPlayer(GetPlayerPawn()).flagBase.GetBool('PM_Firewall_Death_Played'))`  
  Reads/writes the host flagBase. Fine while tnmGameInfo.CoopMergeFlags runs (host<->client merge every second).
- **INFO** HOST_ONLY line 4637 `ALARM`: `if (IsValidEnemy(Enemy) || IsValidEnemy(SeekPawn) || IsValidEnemy(localPlayer) || IsValidEnemy(GetPlayerPawn())) //thanks Chris Rosenkreutz`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 4655 `PlayAreaSecureSound`: `dxPlayer = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 5985 `Died`: `player = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 6183 `SpawnCarcass`: `if (Trestkon(GetPlayerPawn()).bNightmareMode && !IsA('SD') && !IsA('Athena') && !IsA('Treskton') && !IsA('Kevo'))`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 6475 `InitializeInventory`: `t=trestkon(getplayerpawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 7232 `IsSeatValid`: `player = GetPlayerPawn();`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 7747 `BanPawn`: `player = Human(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 7918 `PlayTargetAcquiredSound`: `dxPlayer = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 7939 `PlayNewTargetSound`: `dxPlayer = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## TNMRobot
- **INFO** HOST_ONLY line 74 `CoopPlayerFor`: `return GetPlayerPawn();`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 381 `PlayFootStep`: `if ((GetPlayerPawn() != None) && (SendNoiseHeightTolerance > 0))`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 383 `PlayFootStep`: `PlayRadius *= ScaleSoundByHeight(SendNoiseHeightTolerance, GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 407 `PlayFootStep`: `dxPlayer = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 531 `Disabled.BeginState`: `player=Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 541 `Disabled.BeginState`: `player = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **WARNING** HOST_ONLY line 2438 `StunnedTemporal.Tick`: `flagName = DeusExPlayer(GetPlayerPawn()).rootWindow.StringToName(BindName$"_Dead");`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.
- **INFO** HOST_ONLY_FLAGS line 2439 `StunnedTemporal.Tick`: `DeusExPlayer(GetPlayerPawn()).flagBase.SetBool(flagName, True);`  
  Reads/writes the host flagBase. Fine while tnmGameInfo.CoopMergeFlags runs (host<->client merge every second).
- **INFO** HOST_ONLY_FLAGS line 2442 `StunnedTemporal.Tick`: `DeusExPlayer(GetPlayerPawn()).flagBase.SetExpiration(flagName, FLAG_Bool, 0);`  
  Reads/writes the host flagBase. Fine while tnmGameInfo.CoopMergeFlags runs (host<->client merge every second).
- **WARNING** HOST_ONLY line 2444 `StunnedTemporal.Tick`: `Killed(DeusExPlayer(GetPlayerPawn()), Self, 'Banned');`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## TNMWeapon
- **INFO** HOST_ONLY line 1317 `HandToHandAttack`: `bOwnerIsPlayerPawn = (DeusExPlayer(Owner) == DeusExPlayer(GetPlayerPawn()));`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **WARNING** HOST_ONLY line 1653 `Tick`: `TempPlayer = Trestkon(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.
- **INFO** HOST_ONLY line 2634 `ProjectileFire`: `if (( Role == ROLE_Authority ) || (DeusExPlayer(Owner) == DeusExPlayer(GetPlayerPawn())) )`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 2771 `ProjectileAltFire`: `if (( Role == ROLE_Authority ) || (DeusExPlayer(Owner) == DeusExPlayer(GetPlayerPawn())) )`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 4150 `ClosedCaptions`: `pp = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 4224 `TNMHurtRadius`: `Player = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 4752 `GetWeaponSkill`: `if (Trestkon(GetPlayerPawn()).bNightmareMode)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 4767 `PostPostBeginPlay`: `if (Trestkon(GetPlayerPawn()) != None)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 4768 `PostPostBeginPlay`: `Facelift(Trestkon(GetPlayerPawn()).bHDTPWeapons);`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## treskton
- **INFO** HOST_ONLY line 18 `PostPostBeginPlay`: `player = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 27 `EnterWorld`: `SetSkin(Trestkon(GetPlayerPawn()));`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **WARNING** FIRST_PLAYER_ONLY line 41 `InitializeInventory`: `foreach AllActors(class'trestkon', player)`  
  Loop over players stops at the first one (the host in practice). Handle every player, or pick the relevant one explicitly.
- **INFO** HOST_ONLY line 165 `ResetSkinStyle`: `player = getplayerpawn();`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 209 `Reloading`: `pp = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## Trestkon
- **INFO** HOST_ONLY line 1125 `ServerSyncBoolFlag`: `HostPlayer = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 1146 `ServerSyncBoolFlag`: `HostPlayer = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 3849 `PlayFootStep`: `pp = DeusExPlayer( GetPlayerPawn() );`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 9960 `StartDataLinkTransmission`: `HostPlayer = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 10093 `StartAIBarkConversation`: `HostPlayer = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 10317 `StartConversation`: `HostPlayer = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **WARNING** FIRST_PLAYER_ONLY line 11608 `Dying.Fire`: `foreach AllActors(class'Trestkon', OtherP)`  
  Loop over players stops at the first one (the host in practice). Handle every player, or pick the relevant one explicitly.
- **INFO** HOST_ONLY line 12647 `ParseRightClick`: `HostPlayer = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 12845 `ParseLeftClick`: `HostPlayer = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 15373 `ActivateBelt`: `HostPlayer = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## TriggerablePlayerTeleporter
- **WARNING** HOST_ONLY line 8 `Trigger`: `Touch(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## WeaponMolBottle
- **WARNING** HOST_ONLY line 35 `Tick`: `TempPlayer = Trestkon(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## YuukaReviveTotem
- **WARNING** FIRST_PLAYER_ONLY line 104 `Frob`: `foreach AllActors(class'trestkon', DeadP)`  
  Loop over players stops at the first one (the host in practice). Handle every player, or pick the relevant one explicitly.

## AchievementTrigger
- **INFO** HOST_ONLY line 35 `GiveAchievement`: `player = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## AthenaRespawnInfo
- **INFO** HOST_ONLY_FLAGS line 32 `CreateAthena`: `if(PlayerPawnExt(GetPlayerPawn())!=None && PlayerPawnExt(GetPlayerPawn()).FlagBase!=None)`  
  Reads/writes the host flagBase. Fine while tnmGameInfo.CoopMergeFlags runs (host<->client merge every second).
- **INFO** HOST_ONLY_FLAGS line 33 `CreateAthena`: `PlayerPawnExt(GetPlayerPawn()).FlagBase.SetBool('Athena_Fight_Dead', false,, 23);`  
  Reads/writes the host flagBase. Fine while tnmGameInfo.CoopMergeFlags runs (host<->client merge every second).

## AugAimbot
- **INFO** HOST_ONLY line 836 `Active.IsWeaponAcceptable`: `ThePlayerPawn = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## AutosaveTrigger
- **INFO** HOST_ONLY line 7 `Trigger`: `trestkon(GetPlayerPawn()).Autosave(bForceSave);`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.

## CameraLogTrigger
- **INFO** HOST_ONLY line 5 `Trigger`: `Trestkon(GetPlayerPawn()).LogView();`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## CinematicPoint
- **INFO** HOST_ONLY line 190 `Init`: `aPlayer = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## CoopMainMenuHookWindow
- **INFO** HOST_ONLY line 63 `CheckMainMenuHook`: `P = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## CoopPingDisplayWindow
- **INFO** HOST_ONLY line 14 `InitWindow`: `ownerPlayer = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 27 `DrawWindow`: `P = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## GoalAddTrigger
- **INFO** HOST_ONLY line 14 `Trigger`: `player = trestkon(getplayerpawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## InvasionTrigger
- **INFO** HOST_ONLY line 14 `Trigger`: `if (!Trestkon(GetPlayerPawn()).bUnlockedSword)`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **INFO** HOST_ONLY line 31 `Trigger`: `GetPlayerPawn().PlaySound(Sound'FireStaffReload', SLOT_None);`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 32 `Trigger`: `GetPlayerPawn().PlaySound(Sound'MadScream', SLOT_None);`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## oxygenzonetrigger
- **INFO** HOST_ONLY line 18 `Trigger`: `player = trestkon(getplayerpawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## platformmover
- **INFO** HOST_ONLY line 24 `postbeginplay`: `frob(GetPlayerPawn(),none);`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## PlayerVisibilityTrigger
- **INFO** HOST_ONLY line 14 `Trigger`: `pp = GetPlayerPawn();`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## PrintedNotes
- **INFO** HOST_ONLY line 8 `AddNote`: `aReader=DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## QuickLoader
- **INFO** HOST_ONLY line 20 `timer`: `trestkon(getplayerpawn()).LoadGame(-1);`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 24 `timer`: `trestkon(getplayerpawn()).LoadGame(-6);`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 28 `timer`: `trestkon(getplayerpawn()).LoadGame(-1);`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 32 `timer`: `trestkon(getplayerpawn()).LoadGame(-5);`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## RadishHUD
- **INFO** HOST_ONLY line 21 `ShowRadishWeaponMessage`: `invaderWarning.invaderStart = GetPlayerPawn().Level.TimeSeconds;`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 24 `ShowRadishWeaponMessage`: `invaderWarning.Player = GetPlayerPawn();`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## RocketSAM
- **INFO** HOST_ONLY line 14 `BeginPlay`: `aPlayer = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## ScriptedTextureGeneric
- **INFO** HOST_ONLY line 42 `RenderTexture`: `Player = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## TimeoutTextWindow
- **INFO** HOST_ONLY line 10 `InitWindow`: `tmr=GetPlayerPawn().Spawn(Class'TimeoutTimer');`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## TNMActorDisplayWindow
- **INFO** HOST_ONLY line 105 `DrawWindow`: `player  = GetPlayerPawn();`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 473 `DrawWindow`: `if (int(GetPlayerPawn().Level.TimeSeconds*4)%2 == 1)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 499 `DrawWindow`: `gc.DrawText(leftX-40, topY-140, 80+rightX-leftX, 135, GetPlayerPawn().GetItemName(trackActor.FamiliarName));`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 501 `DrawWindow`: `gc.DrawText(leftX-40, topY-140, 80+rightX-leftX, 135, GetPlayerPawn().GetItemName(String(trackActor)));`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## TNMAutosave
- **INFO** HOST_ONLY line 15 `PostBeginPlay`: `Player = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## tnmCameraPoint
- **INFO** HOST_ONLY line 113 `StartCinematic`: `player = trestkon(getplayerpawn()); //something dodgy here. player somehow gets set to none. will proably have to fix that.`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 127 `Prep`: `player = trestkon(getplayerpawn()); //something dodgy here. player somehow gets set to none. will proably have to fix that.`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 180 `Idle.Trigger`: `Player = trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## tnmcarcass
- **INFO** HOST_ONLY line 343 `TakeDamage`: `player = deusexplayer(getplayerpawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## TNMConPlayBark
- **INFO** HOST_ONLY line 103 `ProcessEventCheckFlag`: `player = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## tnmConWindowActive
- **INFO** HOST_ONLY line 99 `AbortCinematicConvo`: `t=Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## TNMCredits
- **INFO** HOST_ONLY line 123 `ProcessFinished`: `foreach GetPlayerPawn().AllActors(Class'DXOgg',music)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 131 `ProcessFinished`: `if(creditsmusic==none) creditsmusic=GetPlayerPawn().Spawn(Class'DXOgg');`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 236 `DestroyWindow`: `foreach getplayerpawn().allactors(class'TNMOggMusicManager', music)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## tnmhud
- **INFO** HOST_ONLY line 36 `RootHide`: `DeusExRootWindow(GetRootWindow()).ShowHUD(!Trestkon(GetPlayerPawn()).bCinematic);`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 313 `InvaderEnterMessage`: `invaderWarning.invaderStart = GetPlayerPawn().Level.TimeSeconds;`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 316 `InvaderEnterMessage`: `invaderWarning.Player = GetPlayerPawn();`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## tnmJukeboxWindow
- **INFO** HOST_ONLY line 33 `PopulateSongsList`: `if (songNames[songIndex] != "" && bool(GetPlayerPawn().GetPropertyText("bUnlockedTrack"$songIndex)))`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.

## tnmLaserAutoTurret
- **INFO** HOST_ONLY line 79 `Fire`: `attacker = GetPlayerPawn();`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## TNMLightningZoneCreator
- **INFO** HOST_ONLY line 81 `SpawnLightning`: `PlayerP = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## tnmMission20
- **INFO** HOST_ONLY line 130 `GhandCatchFire`: `if (Trestkon(GetPlayerPawn()) != None)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 131 `GhandCatchFire`: `Trestkon(GetPlayerPawn()).SetAchievement("achGhand");`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **INFO** HOST_ONLY line 330 `DestroyedValve`: `if (Trestkon(GetPlayerPawn()) != None)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 331 `DestroyedValve`: `Trestkon(GetPlayerPawn()).SetAchievement("achMelkValves");`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **INFO** HOST_ONLY_FLAGS line 1644 `PreTravel`: `flags = deusexplayer(getplayerpawn()).flagbase;`  
  Reads/writes the host flagBase. Fine while tnmGameInfo.CoopMergeFlags runs (host<->client merge every second).
- **INFO** HOST_ONLY_FLAGS line 1920 `Timer`: `flags = deusexplayer(getplayerpawn()).flagbase;`  
  Reads/writes the host flagBase. Fine while tnmGameInfo.CoopMergeFlags runs (host<->client merge every second).
- **INFO** HOST_ONLY line 2163 `Timer`: `trestkon(getplayerpawn()).autosave(true, 20);`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **INFO** HOST_ONLY line 2734 `IRCKick`: `if (Trestkon(GetPlayerPawn()).irc_link != None && FRand() < 0.8)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 2735 `IRCKick`: `Trestkon(GetPlayerPawn()).irc_link.ServerQuit(QR_Despot);`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 2815 `FlushStop`: `Trestkon(GetPlayerPawn()).SetAchievement("achFlush");`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **INFO** HOST_ONLY line 2904 `LlamaGuardInvul`: `trest = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 2914 `KaleDropBody`: `trest = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## tnmMission20and22
- **INFO** HOST_ONLY_FLAGS line 736 `PreTravel`: `f=deusexplayer(GetPlayerPawn()).flagBase;`  
  Reads/writes the host flagBase. Fine while tnmGameInfo.CoopMergeFlags runs (host<->client merge every second).
- **INFO** HOST_ONLY line 797 `PreTravel`: `if (deusexplayer(getplayerpawn()).PlayerSkin > 12)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 799 `PreTravel`: `deusexplayer(getplayerpawn()).MultiSkins[3] = texture(DynamicLoadObject("TNMCharacters.Skins.GoatTex4", class'texture' ));`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 800 `PreTravel`: `deusexplayer(getplayerpawn()).MultiSkins[5] = texture(DynamicLoadObject("TNMCharacters.Skins.GoatTex1", class'texture' ));`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 804 `PreTravel`: `deusexplayer(getplayerpawn()).MultiSkins[1] = texture(DynamicLoadObject("TNMCharacters.Skins.GoatTex3", class'texture' ));`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 805 `PreTravel`: `deusexplayer(getplayerpawn()).MultiSkins[2] = texture(DynamicLoadObject("TNMCharacters.Skins.GoatTex4", class'texture' ));`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 806 `PreTravel`: `deusexplayer(getplayerpawn()).MultiSkins[4] = texture(DynamicLoadObject("TNMCharacters.Skins.GoatTex2", class'texture' ));`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 807 `PreTravel`: `deusexplayer(getplayerpawn()).MultiSkins[5] = texture(DynamicLoadObject("TNMCharacters.Skins.GoatTex3", class'texture' ));`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 1013 `Timer`: `if(int(p.GetPawnAllianceType(GetPlayerPawn()))==2)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 1126 `DisplayNews`: `Player = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 1430 `KillTrestkon`: `t = trestkon(getplayerpawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## tnmMission21
- **INFO** HOST_ONLY line 253 `Timer`: `trestkon(getplayerpawn()).autosave(true, 21);`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **INFO** HOST_ONLY line 545 `ThreadsHacked`: `if (Trestkon(GetPlayerPawn()) != None)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 546 `ThreadsHacked`: `Trestkon(GetPlayerPawn()).SetAchievement("achProgram");`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.

## tnmMission25
- **INFO** HOST_ONLY line 33 `FirstFrame`: `t=trestkon(getplayerpawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 831 `EndIntro`: `Trestkon(GetPlayerPawn()).PostIntro();`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **INFO** HOST_ONLY line 899 `PlayPDXEndgame01`: `if (Trestkon(GetPlayerPawn()) != None)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 900 `PlayPDXEndgame01`: `Trestkon(GetPlayerPawn()).SetAchievement("achEndingPDX");`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **INFO** HOST_ONLY line 995 `PlayWCEndgame01`: `if (Trestkon(GetPlayerPawn()) != None)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 996 `PlayWCEndgame01`: `Trestkon(GetPlayerPawn()).SetAchievement("achEndingWC");`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **INFO** HOST_ONLY line 1122 `PlayABIEndgame01`: `if (Trestkon(GetPlayerPawn()) != None)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 1123 `PlayABIEndgame01`: `Trestkon(GetPlayerPawn()).SetAchievement("achEndingABI");`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.
- **INFO** HOST_ONLY line 1159 `PlayNarcEndgame02`: `if (Trestkon(GetPlayerPawn()) != None)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 1160 `PlayNarcEndgame02`: `Trestkon(GetPlayerPawn()).SetAchievement("achEndingNarc");`  
  GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics. Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.

## tnmPassiveIRCLink
- **INFO** HOST_ONLY line 48 `Connect`: `player=Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 592 `LoggedIn.ProcessInput`: `SendBufferedData("NOTICE "$ParseDelimited(Line, ":!", 2)$" :"$Chr(1)$"VERSION "$Trestkon(GetPlayerPawn()).GetTNMVersion()$Chr(1)$CRLF);`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## tnmPlayMusicWindow
- **INFO** HOST_ONLY line 65 `InitWindow`: `foreach GetPlayerPawn().AllActors(Class'tnmoggmusicmanager',tnmmusic)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## TNMProjectile
- **INFO** HOST_ONLY line 197 `Flying.Explode`: `Player = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 407 `Exploding.DamageRing`: `PlayerPawn = Human(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 524 `TNMHurtRadius`: `Player = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## tnmProjectileBullet
- **INFO** HOST_ONLY line 8 `PostBeginPlay`: `if(Trestkon(GetPlayerPawn()).bInBulletTime)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## TNMShowClassWindow
- **INFO** HOST_ONLY line 176 `SaveSettings`: `GetPlayerPawn().ConsoleCommand("ShowClass "$editClassName.GetText());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## TNMSkillWeaponPistol
- **INFO** HOST_ONLY line 23 `PreBeginPlay`: `if(DeusExPlayer(GetPlayerPawn()) != None)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 24 `PreBeginPlay`: `if(DeusExPlayer(GetPlayerPawn()).bShowMenu)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## TNMThrownProjectile
- **INFO** HOST_ONLY line 16 `Flying.Explode`: `Player = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 27 `Flying.Explode`: `curPawn = GetPlayerPawn();`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.
- **INFO** HOST_ONLY line 84 `Flying.HitWall`: `player = DeusExPlayer(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## TrestkonDummy
- **INFO** HOST_ONLY line 12 `PostBeginPlay`: `Trest = Trestkon(GetPlayerPawn());`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

## WeaponFists
- **INFO** HOST_ONLY line 217 `WeaponDamageType`: `if(Trestkon(GetPlayerPawn()).bInstagibFists)`  
  GetPlayerPawn() returns the host on a listen server. Check whether the client should be considered here.

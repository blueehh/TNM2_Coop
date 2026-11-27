# Co-op script scan

| Rule | Severity | Count |
|---|---|---|
| DANGLING_AMMO_BUTTON | warning | 1 |
| FIRST_PLAYER_ONLY | warning | 8 |
| HOST_ONLY | warning | 27 |
| MISSION_HOST_PLAYER | warning | 30 |
| VAR_CLIENT_TO_SERVER | warning | 1 |

## ATMinfo
- **WARNING** HOST_ONLY line 22 `Tick`: `player = Trestkon(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## CoopTradeMenuWindow
- **WARNING** DANGLING_AMMO_BUTTON line 377 `GetActiveAmmoItem`: `selAmmoClass = invScreen.winInfo.GetSelectedAmmo();`  
  PersonaInventoryInfoWindow.GetSelectedAmmo() can read a destroyed button after Clear(). Walk winInfo.winTileAmmo children instead (Trestkon.CoopGetLoadedAmmoButton).
- **WARNING** HOST_ONLY line 408 `Tick`: `myPlayer = Trestkon(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## CreditsImageTrigger
- **WARNING** HOST_ONLY line 20 `Touch`: `trestkon(getplayerpawn()).displayimg(imagex, imagey, imageTex, LiveTime, FadeTime);`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## creditstexttrigger
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

## insanedeathtrigger
- **WARNING** HOST_ONLY line 16 `Tick`: `player=Trestkon(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## insanetrigger
- **WARNING** HOST_ONLY line 37 `Tick`: `player=trestkon(getplayerpawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## Invader
- **WARNING** FIRST_PLAYER_ONLY line 226 `InitializeInventory`: `foreach AllActors(class'trestkon', player)`  
  Loop over players stops at the first one (the host in practice). Handle every player, or pick the relevant one explicitly.

## PongTextureController
- **WARNING** HOST_ONLY line 289 `Player1Scored`: `A.Trigger(Self, getPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.
- **WARNING** HOST_ONLY line 299 `Player2Scored`: `A.Trigger(Self, getPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## ScriptedMapTextureController
- **WARNING** HOST_ONLY line 29 `Tick`: `Player = Trestkon(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## StaringMover
- **WARNING** HOST_ONLY line 552 `Tick`: `thePlayer = DeusExPlayer(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## TNMBarkManager
- **WARNING** FIRST_PLAYER_ONLY line 15 `CheckRadius`: `foreach AllActors(class'Trestkon', T)`  
  Loop over players stops at the first one (the host in practice). Handle every player, or pick the relevant one explicitly.

## tnmconplay
- **WARNING** FIRST_PLAYER_ONLY line 1244 `g_FlagSet`: `foreach player.AllActors(class'Trestkon', T)`  
  Loop over players stops at the first one (the host in practice). Handle every player, or pick the relevant one explicitly.
- **WARNING** FIRST_PLAYER_ONLY line 1259 `g_FlagSet`: `foreach player.AllActors(class'Trestkon', T)`  
  Loop over players stops at the first one (the host in practice). Handle every player, or pick the relevant one explicitly.

## tnmdatalinkplay
- **WARNING** FIRST_PLAYER_ONLY line 430 `SetupEventCheckObject`: `foreach AllActors(class'Trestkon', T)`  
  Loop over players stops at the first one (the host in practice). Handle every player, or pick the relevant one explicitly.

## tnmFakeLaserAutoTurret
- **WARNING** HOST_ONLY line 261 `Tick`: `else if (pawn.IsA('ScriptedPawn') && (ScriptedPawn(pawn).GetPawnAllianceType(GetPlayerPawn()) != ALLIANCE_Hostile) && (pawn.Mass > 2)) // Exclude rats, flies, fish, etc`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.
- **WARNING** HOST_ONLY line 289 `Tick`: `if (sp.bDetectable && !sp.bIgnore && (sp.GetPawnAllianceType(GetPlayerPawn()) == ALLIANCE_Hostile))`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## TNMGameInfo
- **WARNING** HOST_ONLY line 1489 `Tick`: `Host = Trestkon(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## tnmMission22
- **WARNING** MISSION_HOST_PLAYER line 676 `FirstFrame`: `if (player.inhand != none && player.inhand.isA( 'tnmpovcorpse' ) && tnmpovcorpse(player.inhand).givenbindname == "Zero")`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 724 `FirstFrame`: `if (player.inhand != none && player.inhand.isA( 'tnmpovcorpse' ) && tnmpovcorpse(player.inhand).givenbindname == "Slicer")`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
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
- **WARNING** MISSION_HOST_PLAYER line 1022 `Timer`: `if (Player.IsInState('Dying') && flags.GetBool('MS_ABIBossTauntSent') && !flags.GetBool('MS_PlayerCaptured') && playerkiller != None)`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).

## tnmMission24
- **WARNING** HOST_ONLY line 687 `FirstFrame`: `m.trigger(m,getplayerpawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.
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
- **WARNING** HOST_ONLY line 25 `firstframe`: `Trestkon(GetPlayerPawn()).xAxis = PS.Location.X;`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.
- **WARNING** HOST_ONLY line 26 `firstframe`: `Trestkon(GetPlayerPawn()).yAxis = PS.Location.Y;`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## tnmmissioncombat
- **WARNING** MISSION_HOST_PLAYER line 36 `firstframe`: `Timer = Spawn( class'TNMTimer', ,, Player.Location, Rot(16384,0,0));`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 867 `CombatEnded`: `be = Spawn(class'Beam',,, Player.Location);`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).

## TNMMissionScript
- **WARNING** MISSION_HOST_PLAYER line 470 `FirstFrame`: `if((Trestkon(Player).bUseAutosave/* > 0*/) && dxInfo != None && !(player.IsInState('Dying')) && !(player.IsInState('Paralyzed')) && !(player.IsInState('Interpolating')) && !(player.IsInState('Conversa`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 865 `Timer`: `if((Trestkon(Player).bUseAutosave/* > 0*/) && dxInfo != None && !(player.IsInState('Dying')) && !(player.IsInState('Paralyzed')) && !(player.IsInState('Interpolating')) && !(player.IsInState('Conversa`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).

## tnmmissionstealth
- **WARNING** MISSION_HOST_PLAYER line 36 `firstframe`: `Timer = Spawn( class'TNMTimer', ,, Player.Location, Rot(16384,0,0));`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).
- **WARNING** MISSION_HOST_PLAYER line 763 `StealthEnded`: `be = Spawn(class'Beam',,, Player.Location);`  
  MissionScript.Player is the host; this distance/state check ignores the client. Check every Trestkon (see TNMMissionScript proximity helpers).

## TNMOggMusicManager
- **WARNING** HOST_ONLY line 293 `Tick`: `player = trestkon(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## TNMPawn
- **WARNING** HOST_ONLY line 2329 `HandleDamage`: `TakeDamage( 50, GetPlayerPawn(), hitlocation, vect(0,0,0),'knockedout');`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.
- **WARNING** HOST_ONLY line 4489 `AlphaFirewallDeath.BeginState`: `while (DeusExPlayer(GetPlayerPawn()).IsInState('Conversation'))`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## TNMRobot
- **WARNING** HOST_ONLY line 2438 `StunnedTemporal.Tick`: `flagName = DeusExPlayer(GetPlayerPawn()).rootWindow.StringToName(BindName$"_Dead");`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.
- **WARNING** HOST_ONLY line 2444 `StunnedTemporal.Tick`: `Killed(DeusExPlayer(GetPlayerPawn()), Self, 'Banned');`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## TNMWeapon
- **WARNING** HOST_ONLY line 1653 `Tick`: `TempPlayer = Trestkon(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## treskton
- **WARNING** FIRST_PLAYER_ONLY line 41 `InitializeInventory`: `foreach AllActors(class'trestkon', player)`  
  Loop over players stops at the first one (the host in practice). Handle every player, or pick the relevant one explicitly.

## Trestkon
- **WARNING** VAR_CLIENT_TO_SERVER line 712: `FloorTexture, footprintoffset, bWalkingOnSnow, bWalkingBackwards, bMustJump, jumpBob, clientSelectedConChoice`  
  UE1 never replicates variables client->server; these never reach the server. Send them with a server RPC (see Trestkon.ServerSetMovementPrefs).
- **WARNING** FIRST_PLAYER_ONLY line 11608 `Dying.Fire`: `foreach AllActors(class'Trestkon', OtherP)`  
  Loop over players stops at the first one (the host in practice). Handle every player, or pick the relevant one explicitly.

## TriggerablePlayerTeleporter
- **WARNING** HOST_ONLY line 8 `Trigger`: `Touch(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## WeaponMolBottle
- **WARNING** HOST_ONLY line 35 `Tick`: `TempPlayer = Trestkon(GetPlayerPawn());`  
  Gameplay check or effect against the host only (GetPlayerPawn()). Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.

## YuukaReviveTotem
- **WARNING** FIRST_PLAYER_ONLY line 104 `Frob`: `foreach AllActors(class'trestkon', DeadP)`  
  Loop over players stops at the first one (the host in practice). Handle every player, or pick the relevant one explicitly.

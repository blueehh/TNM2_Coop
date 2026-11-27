# TNM 2.0 Co-op — Agent Guide, Build Pipeline & Backlog (`AGENTS.md`)

## 1. Environment & Directory Layout

- **Playtest Bundle (Workspace)**: `c:\Users\nootk\Downloads\TNM2_Coop_Playtest_Bundle\`
  - `Source\Classes\*.uc` — editable source for every class the co-op build reloads (OBJ EXPORTs, so they include `defaultproperties`). This is the source of truth; edit here.
  - `Tools\build_tnm.sh` — rebuilds and deploys `TNM.u` (section 2). `Tools\uexport.py` dumps the stored ScriptText of every class in a package (no defaults) for quick reading/diffing; `Tools\genbuild.py` writes the HTK exec script.
  - `Tools\coop_selftest\` — self-test MCP server + CLI: scans every script for co-op hazards (host-only logic, deathmatch branches, replication mistakes), rebuilds, and runs a local host+client session reporting crashes and script warnings. See its README.
  - `CHANGES.md` / `Changes\` — summary of changes per round, script diffs, current host-reliance report.
  - `Models\`, `Textures\Skins\`, `Source\CoopPingSound.wav` — raw assets for the Yuuka plush and the ping sound (update 17_r). Imported into `TNM.u` at build time (section 2).
  - `Optional\SingleplayerUsesCoopBuild\` — `TNM.ini`/`TNMDefault.ini` that make the normal TNM launch load the co-op `TNM.u`. **Not installed**; see section 3L.
- **Installed Game Directory**: `C:\Program Files (x86)\Steam\steamapps\common\Deus Ex\Revision\TNM2\`
- **Compiled Co-op Packages**:
  - `CoopMod\System\TNM.u` (loaded first via `Paths=CoopMod\System\*.u` in `TNM_Host.ini` and `TNM_Client.ini`). Previous builds are kept next to it as `TNM.u.pre_movefix.bak` / `TNM.u.bak_<timestamp>`.
  - `DXOgg.dll` (lives in `Revision\TNM2\DXOgg.dll` and `CoopMod\System\DXOgg.dll`)
  - There is **no** co-op `DeusEx.u`. Paths in the ini files are relative to `Revision\TNM2\`, so `Paths=..\..\System\*.u` is `Deus Ex\System\` — the game runs the **stock** `Deus Ex\System\DeusEx.u` and `Engine.u`, not `Revision\System\DeusEx.u`. Read stock DeusEx code when reasoning about inherited behaviour; Revision's copy differs (G-Flex movement, Vanilla Matters turrets, ninja mode).
- **`tnmGameInfo` extends `GameInfo`** (not `DeusExGameInfo` / `DeusExMPGame`), so `Player.DXGame` is `None` in co-op and every `Level.NetMode != NM_Standalone` branch in DeusEx.u (written for deathmatch) also runs in co-op. That is the root cause of most co-op behaviour differences.
- **Steam Workshop Content (READ-ONLY — NEVER MODIFY)**:
  - `C:\Program Files (x86)\Steam\steamapps\workshop\content\397550\1774011024\`

---

## 2. Headless `TNM.u` Build Pipeline (`HTK.exe`)

`ucc.exe make` fails on TNM's `#exec obj load` asset paths, so `TNM.u` is compiled **in-place** with `HTK.exe` (`HTK.HTKEditorEngine`) inside `Revision\TNM2\`. `Tools\build_tnm.sh` (a wrapper around `Tools\coop_selftest\builder.py`) does all of this (about 20 seconds). Paths come from `Tools\coop_selftest\selftest_config.json` or `TNM_GAME_DIR`/`TNM_WORKSHOP_DIR`:

```bash
sh Tools/build_tnm.sh             # build, verify, deploy to CoopMod\System and the bundle
sh Tools/build_tnm.sh --no-deploy # build only (Revision\TNM2\HTKWork\TNM.u)
```

What it does, and the rules behind it:

1. **Copies `HTK` binaries temporarily** into `Revision\TNM2\` (`1774011024\TNM2\System\HTK.exe`, `1774011024\System\HTK.dll`; `lib3ds.dll` is already there) and removes them afterwards.
2. **Generates `HTK_Build.ini`** from `TNM_Host.ini`: `EditorEngine=HTK.HTKEditorEngine`, `[HTK.HTKEditorEngine]`, and strips `EditPackages` that depend on `TNM.u` (`TNMItems`, `TNMCharacters`, `TNMDeco`, `TNMGUI`) so `SCRIPT MAKE` stops at `TNM`.
3. **Stages assets**: copies `Models\`, `Textures\Skins\` and `Source\CoopPingSound.wav` from the bundle into the game folder (removed afterwards; skipped when the bundle *is* the game folder). It `AUDIO IMPORT`s the ping sound; `YuukaReviveTotem.uc`'s `#ForceExec` lines import the plush mesh/skins with paths relative to the game folder.
4. **`CLASS LOAD`s every file in `Source\Classes`**, then `SCRIPT MAKE`, then `OBJ SAVEPACKAGE PACKAGE=TNM FILE=HTKWork\TNM.u` (saved to a separate file, never over the loaded package).
5. **Fails the build on any compile error.** HTK still writes a (broken, script-less) package when a class fails to compile, so the script refuses to deploy unless the log has `Success: Compiled` and no `Error in`.

Rules:

- **Preserve `defaultproperties` on modified classes AND all their `TNM.u` descendants.** Stored ScriptText has no `defaultproperties` block, and `MakeScripts` recompiles every subclass of a reloaded class, losing defaults that differ from the parent. Every descendant must be in `Source\Classes` as an OBJ EXPORT. Classes that are only *dependents* (they reference a changed class but don't subclass it) are recompiled too, but keep their defaults (verified across all 375 classes).
  - The previous builds had lost defaults this way. Restored in `Source\Classes`: `tnmWeaponBlood1/2.bloodAmt`, `MyComputerSecurity` (`terminalTypeStr`, `Physics`, `bCollideWorld`) and `tnmComputerAPGPuzzle.terminalTypeStr` (those computers were opening the wrong terminal UI).
  - Adding a class to `Source\Classes`: export it, plus all its `TNM.u` descendants, from the package that is currently loaded:
    `OBJ EXPORT TYPE=CLASS PACKAGE=TNM NAME=TNM.<Class> FILE=HTKWork\exp\<Class>.uc` (use `\` paths without spaces; `FILE=` is cut at whitespace). Export the same classes from the stock Workshop `TNM.u` (an ini without the `CoopMod` path) and diff the `defaultproperties` to catch losses.
- **Do NOT add member variables to classes subclassed in other packages** without rebuilding those packages: `TNMPawn` (TNMCharacters), `TNMWeapon` and `TNMThrownProjectile`/`TNMProjectile` (TNMItems), `TNMCarcass` (TNMCharacters). New `var`s on `Trestkon`, `tnmGameInfo` and `tnmaugmentationmanager` are fine. Adding functions or a `replication` block for the class's own variables is fine.
- UnrealScript is **case-insensitive**: a local `h` collides with a parameter `H`. A variable can only be replicated by the class that declares it, and UE1 only replicates variables server→client (`reliable if (Role < ROLE_Authority)` on a variable does nothing; only functions go client→server).
- Replicated **functions** must not use `bNetOwner` in their condition (it only applies while variables replicate); use `reliable if (Role == ROLE_Authority)` for client functions and guard their bodies against running on the host.
- DXOgg natives are no-ops unless `Role == ROLE_Authority`; on clients call them through `TNMOggMusicManager.CoopNative*`.
- Run HTK as `HTK.exe EXEC=... INI=HTK_Build.ini USERINI=TNMUser_Host.ini LOG=... -FORCELOGFLUSH` (no leading dashes on `INI=`/`USERINI=`). The exec script must end with `EXIT`.

---

## 3. Fixes Completed & Deployed

### A. Multiplayer Crouch Height (`Trestkon.uc`)
- **Root Cause**: `DeusExPlayer.MultiplayerTick` hardcoded `SetBasedPawnSize(Default.CollisionRadius, 30.0)` when `bIsCrouching || bForceDuck`, overriding singleplayer's `CollisionHeight = 16.0` (`44.5 - 30.0 = 14.5` units instead of `28.5` units), preventing players from fitting into vents/ducts and leaving eye height too high.
- **Fix**: Overrode `SetBasedPawnSize` and updated `MultiplayerTick` / `PlayerCalcView` in `Trestkon.uc` to use `16.0` (singleplayer crouch height) when crouching in multiplayer.

### B. Client IFF Crosshair Reticle Colors (`TNMAugmentationDisplayWindow.uc`, `tnmGameInfo.uc`, `Trestkon.uc`)
- **Root Cause**:
  1. `TNMAugmentationDisplayWindow.GetTargetReticleColor` forced `xcolor = colGreen` whenever `Player.DXGame == None` (which is always true in Co-op since `tnmGameInfo` is not a `DeusExMPGame`).
  2. `ScriptedPawn.ChangeAlly` / `SetAlliance` only ran on the Server (`ROLE_Authority`), while `AlliancesEx` and `InitialAlliances` are not replicated in `ScriptedPawn`.
- **Fix**:
  1. Restricted the `colGreen` override in `TNMAugmentationDisplayWindow.GetTargetReticleColor` to `target.IsA('DeusExPlayer') && target != Player`, delegating NPCs to `Super.GetTargetReticleColor`.
  2. Replicated dynamic NPC alliance state to the Client in `tnmGameInfo.SyncCoopState` (`ClientSyncHackableState(SP.Name, int(SP.GetPawnAllianceType(Src)), -999.0)`) and applied it to the Client's local `ScriptedPawn.AlliancesEx` table in `Trestkon.uc`.

### C. Client OST Playback (`DXOgg.dll`, `TNMOggMusicManager.uc`, `Trestkon.uc`)
- **Root Cause**:
  1. **1-Byte Jump Offset Bug in `DXOgg.dll` (`0x10008b77`, file offset `0x7f77`)**: The Co-op bundle patched `OggStream::Thread` (`0x10008b5e`) to call `OggStream::RestoreIfLost()` (`0x10008e40`) when `DSBSTATUS_PLAYING` is not set. However, `je 0x10008bbc` (`74 43`) jumped **1 byte inside** `jmp 0x10008b08` (`E9 48 FF FF FF`), executing `48 FF FF` (`#UD` invalid opcode exception) and silently crashing the background audio thread whenever `RestoreIfLost()` returned `0` (which happens whenever a game window is unfocused in the background, because DirectSound buffers are created without `DSBCAPS_GLOBALFOCUS`).
  2. **Duplicate `TNMOggMusicManager` Instances on `NM_Client`**: Because `TNMOggMusicManager` has `bNoDelete = False`, setting `bAlwaysRelevant = True; RemoteRole = ROLE_SimulatedProxy;` caused the Client to have both a map-loaded `TNMOggMusicManager0` and a server-replicated `TNMOggMusicManager1` with desynchronized `ClientLastLoopOgg` state.
- **Fix**:
  1. Patched file offset `0x7f78` in `DXOgg.dll` from `0x43` to `0x47` (`je 0x10008bc0`), so unfocused windows cleanly retry every 500ms and play music as soon as focused.
  2. Synchronized all `TNMOggMusicManager` instances on `NM_Client` in `TNMOggMusicManager.Tick` and `Trestkon.ClientPlayOgg`.

### D. Client AI Aggro & Detection Parity (`TNMPawn.uc`, `tnmGameInfo.uc`, `Trestkon.uc`)
- **Root Cause**:
  1. **`DistanceFromPlayer` & `bTickVisibleOnly`**: `ULevel::Tick` in `Engine.dll` (`0x103a55d4`) computes `Actor.DistanceFromPlayer` exclusively against `Viewports[0]->Actor` (the Host `Trestkon0`). When the Host was `> 2500` units away from an NPC, `ScriptedPawn.Tick` set `bCheckPlayer = false`, completely disabling AI sight checks (`AICanSee`) for the Client (`Trestkon1`) even at point-blank range.
  2. **`CheckEnemyPresence` `CycleActors` Split**: `CycleActors` broke at `count >= 1` on `Trestkon0` before reaching `Trestkon1`, splitting Host and Client across alternating ticks and causing `lastCycle >= CycleIndex` (`CheckCycle()`) to be `False` on the tick `Trestkon1` was seen.
  3. **`TNMPawn.GetPlayer()` Head Tracking**: Cached `GetPlayerPawn()` (Host), so NPCs only turned their heads/vision cones (`LookAtActor`) toward the Host.
  4. **Silent AI Barks on Client**: `ScriptedPawn` bark functions (`PlayPreAttackSightingSound`, `PlayTargetAcquiredSound`, etc.) checked `SeekPawn == GetPlayerPawn()`, so NPCs never played sighting/aggro voice lines when detecting the Client (`Trestkon.StartAIBarkConversation` was already written to forward Client barks to the Host's `barkManager`, but was never called).
  5. **`Trestkon.PlayFootStep` Volume Scaling**: Deathmatch multiplayer code scaled `volume` and `range` before calling `AISendEvent('LoudNoise', ...)`.
- **Fix**:
  1. Forced `bTickVisibleOnly = False` on all `ScriptedPawn`s in multiplayer (`tnmGameInfo.InitGame`, `tnmGameInfo.SyncCoopState`, and `TNMPawn.Tick`).
  2. Updated `TNMPawn.CheckEnemyPresence` in multiplayer to evaluate all `PlayerPawn`s in `Level.PawnList` on every sight check tick and run `CheckCycle()` immediately whenever `CycleCumulative > 0` or `lastCycle >= CycleIndex`.
  3. Updated `TNMPawn.GetPlayer()` in multiplayer to select the closest living `Trestkon` in `Level.PawnList`.
  4. Overrode `Play*Sound` bark functions and `ALARM` in `TNMPawn.uc` to check `DeusExPlayer(SeekPawn)` / `DeusExPlayer(Enemy)`.
  5. Saved pre-scaled `aiVolume` and `aiRange` in `Trestkon.PlayFootStep` for `AISendEvent`.

### E. Player Movement: Client/Server Desync & Singleplayer Parity (`Trestkon.uc`, `TNMWeapon.uc`, `tnmaugmentationmanager.uc`)
- **How movement works in netplay**: the client predicts with `PlayerMove → ReplicateMove → ProcessMove`; the server re-runs the same move via `ServerMove → MoveAutonomous → HandleWalking → ProcessMove` and snaps the client back (`ClientAdjustPosition`) once positions differ by more than ~1.7 units (`ClientErr > 3`), plus every 2 seconds. Anything that makes the two speed calculations differ shows up as rubber-banding.
- **Root Causes (desync)**:
  1. `DeusExPlayer.HandleWalking` reads `bAlwaysRun` / `bToggleCrouch` (`globalconfig`, never replicated) and `bToggleWalk` (flipped by a client-only exec). The server used the **host's** settings for the client's pawn.
  2. `LollerSkates` starts skating on the server only (`bSkating`, `GroundSpeed * 17`); `bSkating` sat in the client→server variable list (which UE1 ignores), so the client never knew.
  3. `TNMWeapon.Attribute` (Att_Fleeting ×1.2 speed, Att_Quaking ×4 air control) wasn't replicated.
  4. Replicated augmentations run their simulated `PreBeginPlay` on the client and swap in `mpAugValue` (AugSpeed level 4: 2.0 vs 1.8). `LevelValues` isn't replicated, so the client could keep the deathmatch value.
  5. `DeusExPlayer.GetCurrentGroundSpeed` returns 0 while `AugmentationSystem` hasn't replicated yet.
- **Root Causes (deathmatch rules in co-op)**: `ProcessMove` skips leg/torso damage slowdown and the 0.65 backpedal penalty, applies the deathmatch heavy-weapon formula and GEP turn-rate clamp, swimming uses `mpWaterSpeed` (180 vs 300) with an Aqualung speed bonus, and `TNMWeapon.LoadAmmo` switched `ReloadTime` to `mpReloadTime` (e.g. Shotgun 1.5→0.5; 0 for weapons that never set it). `DeusExWeapon.PostBeginPlay` tripled `PickupAmmoCount`.
- **Fix**:
  1. `Trestkon.CoopSendMovementPrefs` (client, from `TrestkonTick`) → `ServerSetMovementPrefs` RPC whenever the three prefs change.
  2. `bSkating` moved to the server→client replication list.
  3. `TNMWeapon` replicates `Attribute`, `Attributes1`, `Attributes2` to the owner.
  4. `tnmaugmentationmanager.Tick` re-runs `RestoreSinglePlayerAugStats` on the client every second.
  5. `Trestkon.GetCurrentGroundSpeed` uses the singleplayer formula in netgames and `Default.GroundSpeed` while augs replicate. `Trestkon.PlayerWalking.ProcessMove` calls `CoopApplySinglePlayerGroundSpeed` (stock singleplayer rules). The backpedal check uses `newAccel · facing` because `aForward` never reaches the server. `PlayerSwimming.ProcessMove` sets `WaterSpeed = Default.WaterSpeed * swimming skill`.
  6. `TNMWeapon.IsDeathmatchStats()` (true only for a real `DeusExMPGame`) now gates every `mp*` stat branch in `TNMWeapon` (reload, info screen, accuracy health penalty / floor, multi-slug spread) and the pickup-ammo tripling.

### F. Auto Turrets Dead in Co-op (`tnmGameInfo.uc`, new `CoopTurretSafeTarget.uc`)
- **Root Cause**: in netgames `AutoTurret.Tick` sets `bDisabled = True` for any turret with `safeTarget == None` (every map-placed turret), and an active turret only targets `DeusExPlayer`s via `AcquireMultiplayerTarget` (a hacked turret shot the other player and never NPCs). `tnmLaserAutoTurret` (via `Super.Tick`) and `tnmFakeLaserAutoTurret` (copied logic) inherit this.
- **Fix**: `tnmGameInfo` records each turret's map `bDisabled` in `InitGame`. It gives every turret a hidden `CoopTurretSafeTarget` pawn as `safeTarget` (not in the PawnList, `Health=0`, `bIgnore`), and undoes a self-disable once. Every tick it resets `TargetRefreshTime` so the multiplayer branch reuses `prevTarget`, and fills `prevTarget` with the stock singleplayer target choice (`CoopAcquireTurretTarget`).

### G. Flag Sync Resurrected Cleared Flags (`tnmGameInfo.uc`, `Trestkon.uc`)
- **Root Cause**: `Trestkon.SyncFromPlayer` copied only True bools / non-zero ints / non-empty names, in both directions, every second. A flag a script cleared on one player came back from the other player's copy. It also moved only 3 items per second.
- **Fix**: `tnmGameInfo.CoopMergeFlags` (from `SyncCoopState`) does a three-way merge (host, peer, last agreed baseline `FlagBase`). Whichever side changed since the baseline wins, and the host wins conflicts. On a map's first merge the host wins and peer-only flags are added. `PlayerTraveling`, `CS_*` and `SKTemp_*` are excluded. A per-client mirror `FlagBase` sends changed bools (True and False) via `ClientSyncBoolFlag`, 24 per second. `SyncFromPlayer`'s old copy only runs if the baseline can't be created. The goal/note sync limit is raised from 3 to 8 per second.

### I. Client Music Silent (`TNMOggMusicManager.uc`, `Trestkon.uc`, `tnmMission23.uc`)
- **Root Cause**: DXOgg's natives (`SetCurrentOgg`, `GetCurrentSongPosition`, `GetNextOggFileLoop`, `StopPlayback`) only act when the actor's `Role == ROLE_Authority`. The client-side managers are proxies (and `RefreshSystems` forces them to `ROLE_SimulatedProxy`), so every client `SetCurrentOgg` was a silent no-op. The client received `ClientPlayOgg` every second and recorded the track, but its stream stayed empty (`GetCurrentSongPosition()` = 0, `GetNextOggFileLoop()` = ""). The DXOgg.dll patch (section 3C) was never the problem. `tnmMission23` also called `SetCurrentOgg` directly on the server, so its reversed-ambience swap never reached the client.
- **Fix**: `TNMOggMusicManager.CoopNative*` helpers temporarily set `Role = ROLE_Authority` on clients for each native call. `SyncSetCurrentOgg`, the client branch of `Tick`, and Trestkon's `ClientPlayOgg` / `ClientPrepareTravel` / `RefreshSystems` use them. `ClientPlayOgg` restarts the stream if it is still empty. `tnmMission23` uses `SyncSetCurrentOgg`. Verified in a host+client run: the client's stream position advances and switches to combat music on contact.
- **Also**: `Trestkon`'s client functions were replicated under `(Role == ROLE_Authority) && (bNetOwner)`. `bNetOwner` is stale at call time, and some calls ran on the server instead of being sent (seen with `ClientPlayOgg` at PostLogin). Functions are now under `Role == ROLE_Authority`; variables keep `bNetOwner`.

### J. Client Crash in the Inventory Screen (`Trestkon.uc`)
- **Root Cause**: the co-op ammo-selection sync in `Trestkon.RefreshSystems` called `PersonaInventoryInfoWindow.GetSelectedAmmo()` every frame. `Clear()` destroys the ammo buttons but never resets `selectedAmmoButton`, so after clicking a different item it dereferenced a freed window. The client crashed in `PlayerTick` (log: `Tried to remove lastbuttonwindow descendant`, then `Critical: ... PlayerWalking.PlayerTick`).
- **Fix**: `Trestkon.CoopGetLoadedAmmoButton` reads the loaded ammo from the live children of `winInfo.winTileAmmo` (which `Clear()` does null), and only when the selected item is a weapon.

### K. Co-op Weapon Pickups (`TNMWeapon.uc`, `tnmGameInfo.uc`)
- **Root Cause**: the ini files set `bCoopWeaponMode=True`, and `DeusExWeapon.PostBeginPlay` sets `bWeaponStay` in netgames, so `Weapon.SpawnCopy` hands out a copy and never removes the world weapon. `TNMWeapon.HandlePickupQuery` only blocked re-pickups in standalone, so a player who already owned the weapon got its ammo again on every pickup. A dropped (`bTossedOut`) weapon also stayed and could be picked up repeatedly.
- **Fix (each player once)**: `tnmGameInfo` records who took each stay pickup (`CoopStayPickup`/`CoopStayTaker`). `PickupQuery` refuses a second pickup by the same player, and the pickup is removed (`SetRespawn`, i.e. Sleeping) once every connected player has taken it. `TNMWeapon.SpawnCopy` and `HandlePickupQuery` record the taker. Dropped weapons are consumed by whoever picks them up.

### L. Update 17_r (contributed features, merged 2026-10-30)
Built on the shared bundle. All 74 classes compile, no `defaultproperties` were lost (all 375 classes diffed against the previous build), and a host+client self-test passes. Script diff: `Changes\update_17_r_merge.diff`.
- **Co-op menus**: `CoopMainMenuHookWindow` injects a co-op entry into the main menu. It opens `CoopMultiplayerMenuWindow` (host/join, player name, last server IP), the save slots (`CoopSaveMenuWindow`/`CoopLoadMenuWindow`/`CoopSlotButtonWindow` + `CoopSaveSlotManager`) and `CoopTradeMenuWindow` (give items/ammo to the other player).
- **Named profiles**: `tnmGameInfo.SaveNamedCoopProfile`/`RestoreNamedCoopProfile` keep each player's inventory, skills, augs, stats and position by player name (4 profiles, in `TNMCoopSave.ini`).
- **Character model/customizer**: `NarcissusWindow` is the model/skin customizer outside mission 24 (still the story screen in 24). Applied by `Trestkon.ApplyCoopModel`/`ApplyCustomCoopSkin` with a replicated `coopCharacterModel`. `TrestkonCarcass`/`tresktonCarcass` pick matching carcass meshes. `Trestkon` and `TrestkonCarcass` are now `bAlwaysRelevant`.
- **Pings**: `CoopPing` exec → `ServerCoopPing` (traces, prefers the frob target or items along the ray) → `ClientReceiveCoopPing`; shown with `YuukaPingMarker` + `CoopPingDisplayWindow` and `CoopPingSound`.
- **Downed/revive/spectate**: `TrestkonCarcass` spawns a `YuukaReviveTotem` over a dead player. Teammates revive via `CoopReviveTeammate`, including by carrying the body (`TNMCarcass.Frob` lets a player pick up a co-op player carcass). Dead players cycle spectate targets (`ServerCycleDeadSpectate`).
- **Trading**: `ServerCoopTradeItem`/`ServerCoopTradeAmmo`/`ServerCoopDropAmmo` validate ownership, 265 UU range, the target being alive, and capacity.
- **Damage**: `Trestkon.CoopSinglePlayerTakeDamage` is stock `DeusExPlayer.TakeDamage`'s singleplayer path: 6 independent hit locations instead of deathmatch's 3 linked ones, no `MPDamageMult` or MP notifications. A carried player carcass isn't dropped when hit. `TNMPawn` knockout damage credits the real instigator.
- **Missions consider every player**: `tnmMission20` (NSC key for both, Bullseye check), `tnmMission20and22` (item ownership by any player), `tnmMission21` (staff check, tunnel collapse), `tnmMission22` (Kevo's body carried by either player), `tnmMission23` (null-killer guard), `tnmMission25`.
- **Yuuka hat**: `ToggleYuukaHat` exec / `YuukaHeadCompanion`, replicated `bCoopYuukaHat`.
- **Review notes**:
  - `medkityuuka1` is an exec any player can run to get a free medkit. It isn't gated on cheats; remove or gate it before a public release.
  - `YuukaReviveTotem` also spawns on the player's corpse in singleplayer.
  - The tunnel collapse in `tnmMission21` now damages both players even if one isn't in the tunnel.
  - The `Optional\SingleplayerUsesCoopBuild` inis switch singleplayer to the co-op `TNM.u` and set `DefaultServerGame=TNM.TNMGameInfo`. Install them only if you want one build for both.

### M. First Outdoor Quest Desync Fixes (20_FCDowntown review, 2026-10-30)
Findings and evidence: `Changes\desync_review_20_FCDowntown.md`. Map report: `Changes\map_20_FCDowntown.md`.
- **Radius conversations for every player**: stock `ScriptedPawn.Tick`/`DeusExDecoration.Tick` only call `StartConversation(Self, IM_Radius)` on the host. `tnmGameInfo.CoopRadiusConversations` (4 Hz) does it for each other player near an actor with `ConListItems` (the list is refreshed every 5 s). Fixes Firewall's `DowntownFirewall_Mission`/`_DeliveredKale`/`_ArrestedKale1/2` and NPC barks when the client is alone.
- **Shared map XP**: stock `SkillAwardTrigger` pays only the toucher and is once-only. `tnmGameInfo.CoopReplaceTriggers` (at `InitGame`) swaps each one for `CoopSkillAwardTrigger`, which pays every player. Replacements spawn in `AllActors` order, so names are stable for the co-op map save. A mid-map save from an older build won't match them.
- **Trigger occupancy**: non-once plain `Trigger`s that drive `TriggerToggle`/`TriggerControl`/`TriggerPound` movers become `CoopOccupancyTrigger`: they fire for the first player in and release when the last one leaves.
- **Flags**: `CoopMergeFlags` runs at 4 Hz from `tnmGameInfo.Tick` (client mirror RPCs stay at 1 Hz), and immediately when a conversation or datalink ends (`tnmconplay`/`tnmdatalinkplay` → `CoopRequestFlagMerge`).
- **Shared credits** propagate every tick (`Trestkon.CoopSyncSharedCredits`, called from `tnmGameInfo.CoopSyncSharedCreditsAll`), which closes the 1-second double-spend window.
- **NPCs notice and blame the right player** (`TNMPawn` and `TNMRobot`, via `tnmGameInfo.CoopClosestPlayer`):
  - `CheckBeamPresence` reacts to any player's beam, without the host-view `LastRendered` gate.
  - `HandleHacking` and `InstigatorToPawn` blame the player nearest the device or decoration.
  - `FindTaggedActor('')` targets the nearest player.
  - `bDisappear` NPCs also require that no player can see them (`PlayerCanSeeMe`).
  - **Trespassing is per player** (`TNMPawn.CoopCheckCarcassPresence`). TNM detects trespass by making a player with `bBreakAndEnter` (set per player by `AllianceToggleTrigger`) look like someone carrying a body (`GetCarcassData`). Stock `CheckCarcassPresence` only looked at the host and blamed the host, so a client could trespass unnoticed. Now every player in range is checked (native `RadiusActors`; a `PawnList` walk per NPC every 0.1 s was measurably expensive), and the NPC goes after the player it saw. While anyone is trespassing, the multiplayer `CheckEnemyPresence` confirms the `'Player'` grudge only on sighting a trespasser (`CoopIsTrespasser`/`CoopAnyTrespasser`), not the partner standing outside. Limit: once confirmed, hostility is alliance-wide (both players are alliance `Player`, `IsValidEnemy` is native), so an NPC that has turned hostile fights either player until its agitation decays.

  Stock-class NPCs not derived from these (`MedicalBot`/`RepairBot`/`Fishes`) are unchanged.
- **Less steady reliable traffic**: mover, hackable and NPC-alliance state goes to a client only when it changes, plus a 10 s keepalive (`Trestkon.CoopDeviceChanged`).
- `TNMBindNameTrigger` notifies every player's conversation.
- New classes: `CoopSkillAwardTrigger`, `CoopOccupancyTrigger`. Newly in `Source\Classes`: `TNMRobot`, `TNMBindNameTrigger`.

### H. Smaller Co-op Fixes
- **NanoKeyInfo exit assertion** (`Removed!=0`, UnObj.cpp): `Trestkon.CreateNanoKeyInfo` uses `new(None)` in netgames.
- **Weapon mod stats on the client**: `Trestkon.CoopSyncWeaponMods` (once a second) sends scope, clip size, recoil, accuracy, range and reload time for the held weapon plus one other weapon (round robin), and keeps the client's `AmmoName` in step with `AmmoType`.
- **Host-only triggers/gas**: `AllianceToggleTrigger` sets the trespass flag (`bBreakAndEnter`) on whoever walks in (all players when event-triggered), and only clears NPC hostility once nobody is still inside. `DrownTrigger` drowns its instigator. `tnmHalonGas` suffocates every player in range. Quad damage on `TNMProjectile`/`TNMThrownProjectile` works for any player.
- **Carrying bodies** is allowed in co-op (`TNMCarcass.Frob` was standalone-only).
- **Death mid-conversation** (backlog #6): `tnmGameInfo.Killed` ends any conversation the victim is in with `TerminateConversation(False, True)` (not marked played).
- **Disconnect while carrying a decoration** (backlog #7): `tnmGameInfo.Logout` drops it, or restores collision/physics if the drop fails.
- **Travel race** (backlog #4): `ProcessServerTravel` keeps `NextSwitchCountdown >= 2.5` on listen/dedicated servers.

---

## 4. Backlog (from `cranebeaker/deus-ex-coop` HXFix analysis and later passes)

| # | Item | Status |
|---|------|--------|
| 1 | Client weapon mod stats / inventory ammo selection | **Done** (stats: 3H; ammo selection was already handled in `Trestkon.RefreshSystems`) |
| 2 | Augmentation screen "Use Cell" does nothing on the client | **Open** — `UseCell()` lives in `TNMGUI.tnmPersonaScreenAugmentations` (TNMGUI depends on TNM, so it can't be fixed from `TNM.u`). Needs a `TNMGUI.u` rebuild: call a `Trestkon` server RPC instead of `bioCell.Activate()` (non-simulated, never runs on the client). |
| 3 | Window/Owner cleanup on travel | **Done** (already: `ClientPrepareTravel` clears the window stack, `RefreshSystems` clears PRI/ColorTheme owners) |
| 4 | Travel countdown race | **Done** (3H) |
| 5 | Security camera multi-player FOV acquisition | **Open** — `SecurityCamera` is in stock DeusEx.u. A `tnmGameInfo`-side controller like the turret one (section 3F) is the likely route. |
| 6 | Player killed mid-conversation | **Done** (3H) |
| 7 | Disconnect leaves carried decoration intangible | **Done** (3H) |
| 8 | Trigger / keypad / medbot debouncing for two players | **Open** — the classes are in DeusEx.u/Engine.u. |
| 9 | Late-joiner interpolation path replay | **Open** |

Other known gaps (not yet fixed):
- **First outdoor quest review**: fixed (§3M). Still open from it: a pre-existing client `ReplicateMove` Accessed None near moving NPCs (see the review). Original findings (`Changes\desync_review_20_FCDowntown.md`):
  - Radius conversations start only for the host (stock `ScriptedPawn.Tick`), including Firewall's Kale quest handoffs.
  - Map `SkillAwardTrigger`s pay only the first toucher (670 XP in Downtown).
  - Flags lag up to ~1 s between players.
  - Several `ScriptedPawn` perception/blame paths use the host.
  - 1 Hz state sync sends ~29 reliable RPCs/s even when idle.
  - Run `analyze_map` for other maps.
- `tnmMission21`–`25`, `tnmmissionbonus`, `TNMRobot`, `StaringMover`, `InvasionTrigger`, `insanetrigger` and others still use `GetPlayerPawn()` (host) for some checks. Achievements/autosave/PostIntro are fine on the host; review the gameplay ones per map.
- `tnmComputers` subclasses (`MyComputerSecurity`, `tnmComputerAPGPuzzle`) and mission script subclasses keep `RemoteRole=ROLE_DumbProxy`, while their co-op-modified parents use `ROLE_SimulatedProxy`. This was left as tested; change it only with a test.
- `AutoTurret.Fire` passes `safeTarget` as the damage instigator in netgames (stock singleplayer passes the host for non-player hits), so NPCs shot by a turret don't blame a player.
- Movement changes (3E) and turret/flag changes (3F/3G) were smoke-tested only: host + client load `20_PhasApartment` with no script warnings. They still need a hands-on playtest.

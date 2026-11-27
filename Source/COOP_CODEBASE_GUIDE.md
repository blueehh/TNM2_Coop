# The Nameless Mod 2.0 — Co-op Mod Source Guide (`bluehh™`)

**Author / Maintainer:** `bluehh™`  
**Base Game / Total Conversion:** *Deus Ex* (Unreal Engine 1) — *The Nameless Mod 2.0* by Off Topic Productions  
**Compiled Package:** `CoopMod/System/TNM.u`

---

## 1. Architecture Overview

This repository contains the UnrealScript (`Source/Classes/*.uc`) source for the **TNM 2.0 Co-op Campaign Mod**, engineered to turn a sprawling, choice-driven single-player Unreal Engine 1 RPG into a synchronized, high-latency-resilient (250ms–500ms+) cooperative campaign without breaking binary compatibility with sibling TNM packages (`TNMItems.u`, `TNMPawns.u`, `TNMGUI.u`, and stock `.dx` maps).

### Binary Layout Safety Rule
Child packages (`TNMItems.u`, `TNMPawns.u`, etc.) are not recompiled and encode exact byte offsets into parent classes inside `TNM.u`. Therefore, **zero member variables (`var`) may be added or removed** in:
- `TNMPawn`
- `TNMWeapon`
- `TNMProjectile` / `TNMThrownProjectile`
- `TNMCarcass`

All new persistent or replicated Co-op state lives inside leaf/isolated classes (`Trestkon`, `tnmGameInfo`, `CoopSaveSlotManager`, `CoopLocalPrefs`, and standalone `Coop*` / `Yuuka*` actors and UI windows).

---

## 2. Custom Co-op Classes (`Coop*.uc` & `Yuuka*.uc`)

### Menus, Preferences & Save Profiles
| File | Role |
| :--- | :--- |
| `CoopMainMenuHookWindow.uc` | Lightweight root watcher & button container that injects the **Multiplayer** button into the Main Menu and Pause Menu. |
| `CoopMultiplayerMenuWindow.uc` | Unified Co-op lobby menu: Player Name, Server IP (`Ctrl+V` clipboard support), 4 Campaign Save Slots, Host/Continue/Join controls, character skin selector, and `bluehh (TM)` footer credit. |
| `CoopClipboardEditWindow.uc` | Native `MenuUIEditWindow` subclass adding `Ctrl+V` / `Shift+Insert` paste, `Ctrl+C` copy, and sanitized URL/name input. |
| `CoopConnectingWindow.uc` | Non-softlocking connection overlay with elapsed timer, 15s unreachable-host auto-timeout, and `ESC` / `Cancel` abort back to menu. |
| `CoopLocalPrefs.uc` | Local client-only config (`TNMCoopPrefs.ini`) storing `PreferredPlayerName` and `LastServerIP` so host saves never overwrite a client's identity. |
| `CoopSaveSlotManager.uc` | Host-side 4-slot Co-op save manager (`CoopSlot1.ini`–`CoopSlot4.ini`) storing up to **16 named player profiles per slot** (inventory, loaded ammo & ammo pool, weapon mods, TNM attributes, belt/grid layout, skills, augs, health) plus shared credits & story flags. |
| `CoopSaveMenuWindow.uc` | In-game 4-slot Co-op Save Campaign modal (`ToolWindow`). |
| `CoopLoadMenuWindow.uc` | In-game 4-slot Co-op Load Campaign modal (`ToolWindow`). |
| `CoopSlotButtonWindow.uc` | Custom-width stylized slot button (`Slot 1`–`Slot 4`) with active/populated visual states. |

### Native HUD, Chat & Co-op Gameplay Widgets
| File | Role |
| :--- | :--- |
| `CoopChatDisplayWindow.uc` | Full-HUD non-interactive layout anchor (`DeusExHUD` child) positioning the chat feed above the lower-left Ammo panel and tracking live `T` (`Say`) / `Y` (`TeamSay`) typing state. |
| `CoopChatPanelWindow.uc` | Authentic Deus Ex / TNM 9-slice HUD chat widget (`extends HUDSharedBorderWindow`) inheriting the player's live HUD Color Theme, `LogIcon`, `FontMenuHeaders_DS` header, color-coded `[Sender]: Message` word-wrapped rows, and live typing prompt. |
| `CoopPingDisplayWindow.uc` | 3D-to-2D HUD overlay rendering teammate nameplates, distance readouts, downed revive indicators, world ping markers, and 250ms+ explosive hazard warnings (`[!] GRENADE`, `[!] EXPLOSIVE`). |
| `CoopTradeMenuWindow.uc` | Live player-to-player item & credit trade window. |

### World Actors, Triggers & FX
| File | Role |
| :--- | :--- |
| `CoopExplosionLight.uc` | Transient client-local dynamic blast flash spawned during Co-op explosion FX. |
| `CoopOccupancyTrigger.uc` | Multi-player door/mover trigger replacement that opens on the first player entering and only releases when the last player exits. |
| `CoopSkillAwardTrigger.uc` | Co-op replacement for `SkillAwardTrigger` ensuring all connected players receive exploration/objective skill points. |
| `CoopTurretSafeTarget.uc` | Invisible non-colliding `safeTarget` placeholder keeping map `AutoTurret` actors active under `NM_ListenServer`. |
| `YuukaReviveTotem.uc` | Downed-player revive beacon, direct frob-to-revive target, and `YuukaPlushMesh` 3D mesh/skin asset importer. |
| `YuukaPingMarker.uc` | Animated 3D world ping marker spawned by `CoopPing`. |
| `YuukaHeadCompanion.uc` | Mini 3D plush companion worn on third-person player heads. |
| `Source/CoopChatSound.wav` | Volume-calibrated 22,050 Hz PCM sound imported as `Sound'TNM.CoopChatSound'` for Co-op chat messages. |
| `Source/CoopPingSound.wav` | Volume-calibrated 22,050 Hz PCM Yuuka/Metchy voice clip imported as `Sound'TNM.CoopPingSound'` for world pings and downed-totem prompts. |

---

## 3. Core Modified TNM Classes

| File | Co-op Responsibilities |
| :--- | :--- |
| `Trestkon.uc` | Player replication (`reliable` RPC blocks), 250ms–500ms client movement prediction & smooth error decay, client-predicted hitscan & melee combat, multiplayer Keypad/Computer/ATM routing, client inventory/ammo/weapon-mod/belt sync, chat routing (`Say` / `TeamSay`), downed/revive state, and HUD attachment. |
| `tnmGameInfo.uc` | Co-op `Login` (`?Name=` profile assignment), seamless zone-transition & savestate persistence per username, shared `Credits` sync, bidirectional `FlagBase` story-flag merge (`CoopMergeFlags`), map trigger/turret/hackable patching, and explosive hazard scanning. |
| `tnmconplay.uc` & `tnmdatalinkplay.uc` | Conversation & InfoLink PM synchronization across players, including client-side `DynamicLoadObject` voice-over audio playback (`ClientPlayConAudio`). |
| `TNMWeapon.uc` | Co-op weapon firing, reload sync, laser/scope helpers, and saved TNM weapon attribute restoration (`SetCoopSavedAttributes`). |
| `TNMThrownProjectile.uc` | High-ping grenade/LAM/EMP fuse countdown telegraphing, enemy-only proximity mine filtering in Co-op, `+0.70s` server explosion linger for replication, and reliable client blast FX. |
| `tnmRootWindow.uc` | Hooks Co-op Save/Load/Multiplayer menus and redirects `SaveGame` / `LoadGame` safely in netplay. |

---

## 4. Automated Build & Sanity Check Pipeline

Located in `Tools/coop_selftest/`:
1. **`builder.py --deploy`** — Stages `Source/` into the UE1 build tree, compiles `TNM.u` with `HTK.exe`, verifies zero compiler errors across all 84 UnrealScript classes, and deploys `CoopMod/System/TNM.u`.
2. **`scanner.py`** — Static UnrealScript sanity checker validating binary-layout compatibility (`TNMPawn`/`TNMWeapon`/`TNMProjectile` member counts), replication block validity, and netmode guards.

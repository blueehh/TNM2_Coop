# TNM 2.0 Co-op — Changes

## High-Ping ZeroTier Polish, Named Profiles & Native Chat HUD (2026-11-24 / 2026-11-26)

- **Host-held per-username campaign profiles (`CoopSaveSlotManager`, `tnmGameInfo`, `Trestkon`)**: Each of the 4 Co-op save slots (`CoopSlot1.ini`–`CoopSlot4.ini`) stores up to **16 named player profiles** keyed by username, preserving full inventory, loaded weapon ammo & projectile mode, ammo pools, weapon mods, TNM legendary attributes, charged pickup state, belt/grid layout, skills, augmentations, and health across both **zone transitions** and **savestates**, while keeping **Credits** shared across players.
- **Client local preferences (`CoopLocalPrefs` -> `TNMCoopPrefs.ini`)**: Decoupled client `PreferredPlayerName` and `LastServerIP` from host campaign saves and passed `?Name=` across `JoinCoop` / `HostCoop` / `ClientPrepareTravel` so joining clients always keep their own username instead of inheriting the host's.
- **Multiplayer Menu & Connection UX (`CoopMultiplayerMenuWindow`, `CoopClipboardEditWindow`, `CoopConnectingWindow`, `Engine.int`)**:
  - Full click-to-focus + `Ctrl+V` / `Shift+Insert` clipboard paste and `Ctrl+C` copy on the Player Name and Server IP fields.
  - Non-softlocking connection overlay with elapsed timer, 15s unreachable-host auto-timeout, `ESC` / `Cancel` abort back to menu, and restored `[Progress]` strings in `Engine.int`.
- **250ms–500ms high-latency readiness (`Trestkon`, `TNMThrownProjectile`, `CoopExplosionLight`, `CoopPingDisplayWindow`)**:
  - Smooth client position error decay (eliminating walking rubberband stutter at 250ms+ RTT), client-predicted hitscan & melee responsiveness, and `Test_Local_Coop_250ms.bat` latency test launcher.
  - Grenade/LAM/EMP fuse countdown audio telegraphing, enemy-only proximity mine filtering in Co-op, `+0.70s` server explosion linger for replication, dynamic `CoopExplosionLight` flash + reliable client blast FX, and HUD `[!] GRENADE` / `[!] EXPLOSIVE` warnings.
- **Multiplayer Keypads & Client Conversation/PM Audio (`Trestkon`, `tnmconplay`, `tnmdatalinkplay`)**:
  - Enabled native Keypad UI (`tnmHUDKeypadWindow`) for both Host and Client in Co-op with instant door/mover lock sync.
  - Fixed silent InfoLink PMs and NPC voice-overs on `NM_Client` via client-side `DynamicLoadObject` audio resolution (`ClientPlayConAudio`).
- **Native Deus Ex / TNM Co-op Chat Feed Widget (`CoopChatPanelWindow`, `CoopChatDisplayWindow`)**:
  - Built on `HUDSharedBorderWindow` (`CO-OP COMMS`) inheriting authentic 9-slice HUD borders, translucent fill, `LogIcon`, and live HUD Color Theme switching.
  - Shows a 6-message word-wrapped feed above the lower-left Ammo HUD with emerald/cyan sender highlights, live `> Say:` / `> Team:` typing prompt (`T` / `Y`), Persona Log mirroring, and volume-calibrated `CoopChatSound` + softened `CoopPingSound` Yuuka/Metchy audio.
- **Co-development & GitHub tooling (`config.py`, `Build_And_Deploy_Coop.bat`, `Pack_Playtest_Bundle.bat`, `Source/COOP_CODEBASE_GUIDE.md`)**: Auto-detects Steam libraries across drives (`libraryfolders.vdf`), adds standardized `bluehh (TM)` headers/credits, and supports conflict-free Git co-development.

## First outdoor quest desync fixes (2026-10-30)

Fixes from `Changes\desync_review_20_FCDowntown.md` (details: AGENTS.md §3M):
- **Proximity conversations** now start for the client too. The Firewall/Kale quest hand-offs previously only worked when the host walked up.
- **Map skill-award triggers** pay both players (Downtown alone has 670 XP that only the first toucher used to get).
- **Toggle/hold-open doors** no longer re-fire or release because the second player walked in or out.
- **Flags** merge 4× a second and right after conversations; **shared credits** sync every tick.
- **Trespassing** is noticed per player: the client can no longer trespass unseen, NPCs go after the player they saw, and the partner outside doesn't trigger the grudge (once an NPC turns hostile it still fights both, as the AI only has alliance-level hostility).
- **NPCs** react to either player's flashlight and blame the right player for hacks and noises; untargeted orders and disappearing NPCs no longer key off the host.
- **Device, door and NPC-alliance sync** only sends changes, cutting steady reliable traffic.

Verified: compiles, no defaults changed across 387 classes, host+client self-test passes on the apartment and on 20_FCDowntown (12 triggers replaced at load, zero host script warnings). Not yet verified in play. A pre-existing client-only `ReplicateMove` Accessed None in Downtown is documented as open.

## Update 17_r (contributed, merged 2026-10-30)

New features:
- Co-op main-menu entry with host/join, save slots and named per-player profiles.
- Character model/skin customizer (`NarcissusWindow` outside mission 24).
- Pings with a Yuuka plush marker and sound.
- Downed-teammate revive totem and dead-player spectate.
- Item/ammo trading.
- Yuuka hat.
- Singleplayer-style 6-part locational damage in co-op.
- Mission scripts 20–25 check every player instead of only the host.

Status:
- Merged as-is. The build tools were adapted so the bundle builds from any folder layout: assets are staged into the game folder at build time, and paths come from `selftest_config.json`.
- Verified: compiles, no lost defaults across 375 classes, and the host+client self-test passes (join, music, zero script warnings, no crashes). Hazard-scan warnings dropped from 74 to 66.
- Not verified in play: menus, trading, revive/spectate, pings, profiles, the customizer.
- Review notes (AGENTS.md §3L):
  - The free-medkit exec `medkityuuka1` is ungated.
  - The revive totem also appears in singleplayer.
  - The tunnel collapse hurts both players.
  - The optional inis (not installed) switch singleplayer to the co-op build.
- Diff: `Changes\update_17_r_merge.diff`.

## Round 1

Applies to `CoopMod\System\TNM.u` (built from `Source\Classes`). The previous build is kept as `CoopMod\System\TNM.u.pre_movefix.bak` on the original machine. Full technical write-ups are in `AGENTS.md` §3 E–K. The script diff against the previous co-op build is in `Changes\script_changes_vs_previous_coop_build.diff` (default-property changes are listed below; the diff covers code only).

## Contents of this package

| Path | What |
|---|---|
| `AGENTS.md` | Agent guide: environment, build pipeline rules, every fix with root cause, backlog status. Start here. |
| `CHANGES.md` | This file. |
| `TNM2_COOP_HANDOFF_AND_GUIDE.txt` | Original player guide / handoff (install, launch, controls). |
| `Source\Classes\*.uc` | Editable source for the 62 classes the co-op build reloads (OBJ EXPORTs, so `defaultproperties` are included). |
| `Tools\build_tnm.sh` | Rebuild + install `TNM.u` (Git Bash). `Tools\coop_selftest\builder.py` does the same in Python. |
| `Tools\coop_selftest\` | Self-test MCP server + CLI (scanner, builder, host/client runner). See its README. |
| `Tools\uexport.py`, `Tools\genbuild.py` | Package script extractor, HTK exec-script generator. |
| `Changes\` | Source diff, host-reliance report, warning-level hazard scan of the current build. |
| `CoopMod\System\TNM.u`, `DXOgg.dll`, `*.ini`, `*.bat` | The playable build and launchers. |

## Fixes

**Reported during playtest**
- **Client had no music.** DXOgg natives only act with `Role == ROLE_Authority`, and client-side music managers are proxies, so every client `SetCurrentOgg` did nothing. All client-side native calls now go through `TNMOggMusicManager.CoopNative*`, which borrow Authority for the call. Verified: the client stream plays and follows combat changes. `tnmMission23`'s ambience swap now syncs to the client.
- **Client crash in the inventory screen.** The ammo-selection sync read a destroyed button every frame after switching items. It now reads only live buttons.
- **World weapons never consumed / infinite ammo.** With `bCoopWeaponMode`, each player can take a given world weapon once, and it is removed after every player has. Re-pickups for ammo are blocked; dropped weapons are single items.

**Movement (host/client desync and singleplayer parity)**
- The server simulated the client with the host's run/crouch/walk-toggle settings; the client's are now sent (`ServerSetMovementPrefs`).
- Skates (`bSkating`) and the Fleeting/Quaking weapon attributes now replicate to the client.
- The client no longer keeps deathmatch Speed/Aqualung aug values.
- Walking and swimming use singleplayer rules (leg damage, backpedal, heavy weapons, swim speed) on both sides.

**Deathmatch rules leaking into co-op**: reload times, accuracy, multi-slug spread, the weapon info screen and pickup ammo now use singleplayer values (`TNMWeapon.IsDeathmatchStats`).

**Other**
- Replicated client functions no longer use `bNetOwner` (some calls ran on the host instead of being sent).
- Auto turrets no longer disable themselves, and target like singleplayer (controller in `tnmGameInfo` + `CoopTurretSafeTarget`).
- Three-way flag merge: flags a script clears no longer come back from the other player.
- Weapon mod stats sync to the client.
- `NanoKeyInfo` exit assertion fixed.
- Trespass zones, drowning, halon gas and quad damage now apply per player.
- Bodies can be carried in co-op.
- Death mid-conversation ends it without marking it played.
- Disconnecting while carrying a decoration drops it.
- The travel countdown is at least 2.5 s.

**Default properties restored** (lost by earlier builds' subclass recompiles): `tnmWeaponBlood1.bloodAmt=2`, `tnmWeaponBlood2.bloodAmt=4`, `MyComputerSecurity.terminalTypeStr/Physics/bCollideWorld`, `tnmComputerAPGPuzzle.terminalTypeStr` (those computers had opened the wrong terminal UI).

## Verified vs not

- Verified: every build compiles cleanly. A host + client session loads, joins and runs with zero script warnings and no crashes (`run_coop_session`), and the client's music plays. Defaults of all 375 classes were diffed against the stock Workshop package.
- Needs a human playtest: movement feel, turrets, flag sync across missions, weapon pickups for both players, carrying bodies.

## Still open

- "Use Cell" on the augmentation screen (needs a `TNMGUI.u` rebuild).
- Security-camera targeting, two-player trigger/keypad double-firing, and late-join mover replay (all in stock DeusEx/Engine code).
- Scripts that still check only the host: see `Changes\host_reliance_report.md`, e.g. `tnmMission20.BullseyeCheck` and other `MISSION_HOST_PLAYER` warnings.

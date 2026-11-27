# Next steps (handoff, 2026-10-30)

State of the build: everything in `AGENTS.md` §3 is built and installed (`CoopMod\System\TNM.u` in this bundle is the current build). Last round: the first-outdoor-quest desync fixes (§3M) and per-player trespassing. Compiles, keeps every class's `defaultproperties`, and the host+client self-test passes on `20_PhasApartment` and `20_FCDowntown`. **None of it has been played by hand yet.**

Setup for the agent: `Tools\coop_selftest\README.md` (register the MCP server, set paths in `selftest_config.json` if Steam isn't in `C:\Program Files (x86)`). Read `AGENTS.md` first, especially section 2: edit only `Source\Classes`, never touch the Workshop folder, and keep descendants' `defaultproperties`.

## What an agent can check on its own

Loop for everything below: read code, edit `Source\Classes`, `build_tnm` (deploy), `run_coop_session`, `read_log`.

### 1. Confirm the recent fixes with temporary `log()` lines
Add `log("COOPDIAG ...")`, build, run, and look for it with `read_log host`. Remove the logs and rebuild afterwards.
- **Proximity conversations**: log in `tnmGameInfo.CoopRadiusConversations` when `StartConversation` succeeds for the client (`map=20_FCDowntown`).
- **Shared XP**: the host log should say `CoopMod replaced N triggers` on each map (12 on Downtown).
- **Send-on-change sync**: count `ClientSyncMoverState` calls over a 40 s soak; it should be near zero when nothing moves.

### 2. Map reports beyond Downtown
Only `20_FCDowntown` has one (`Changes\map_20_FCDowntown.md`). Run `analyze_map` on SolsBar, the subway maps and the mission 21–25 maps, and summarise per map: proximity conversations, skill-award triggers, `**RISK**` triggers wired to toggle/hold-open doors, and placed classes with inherited host-only code.

### 3. Triage the host-only warnings
`list_host_only_sites` (~67 warnings, mostly `tnmMission21`–`25`, `tnmmissionbonus`, `StaringMover`, `InvasionTrigger`, `insanetrigger`). For each: read it, decide whether the client should count, fix it with the instigator/toucher, the closest `Trestkon` (`tnmGameInfo.CoopClosestPlayer`), or every `Trestkon`. `scan_scripts min_severity=error` must stay empty.

### 4. Performance canary
On `20_FCDowntown` with `soak_seconds=40`, the client's `PlayerPawn.ReplicateMove ... Accessed None` count is about **60–135** on a good build. A jump to ~300 means new per-tick code is too slow (that's how a `PawnList` walk in every NPC every 0.1 s was caught; the fix was the native `RadiusActors`). Check this after any change to NPC tick/perception code.

### 5. Investigate `ReplicateMove:059B` Accessed None (client only, pre-existing)
`export_package` stock `Engine.u` for `PlayerPawn.ReplicateMove`. Work out which reference at bytecode offset 0x59B is None (the area that adjusts collision for nearby moving pawns). Test each guess with an override in `Trestkon` and compare the warning count. Zero in the apartment, so it's tied to moving NPCs.

### 6. Backlog items an agent can build
- **Security cameras** (backlog #5): a co-op controller in `tnmGameInfo` modelled on the turret one (§3F). Confirm with a log line that cameras track the client.
- **Stock-class NPCs** (`MedicalBot`, `RepairBot`, `Fishes`) still use the host for beam/hack/blame checks. Needs TNM subclasses or a map-load swap like `CoopReplaceTriggers`.
- **`medkityuuka1`**: an exec anyone can run for a free medkit. Gate it behind cheats or remove it before a public release.
- **Use Cell on the client** (backlog #2): lives in `TNMGUI.u`. `export_package` TNMGUI and draft the change (call a `Trestkon` server RPC instead of `bioCell.Activate()`), but the build pipeline only builds `TNM.u`; it needs extending first.

## Needs people (playtest checklist)
- Client does the Kale escort to Firewall **alone**: the quest conversations should start.
- Both players get the map XP pop-ups in Downtown.
- Client trespasses alone and gets attacked; host waiting outside stays unnoticed until an NPC actually turns hostile (after that it fights both: hostility is per alliance).
- Either player's flashlight alerts NPCs; hacking blames the player at the device.
- Movement at ~250 ms latency (no rubber-banding, only small snaps on platforms).
- Turrets shoot NPCs and not players; weapon pickups work once per player.
- Joining mid-game (late join, backlog #9).

## Files
- `AGENTS.md`: guide, build rules, every fix with root cause (§3), backlog (§4).
- `CHANGES.md`: per-round summary. `Changes\`: diffs, the Downtown desync review, scanner reports.
- `Tools\coop_selftest\`: MCP server + CLI (scanner, builder, runner, map analysis, conversations).

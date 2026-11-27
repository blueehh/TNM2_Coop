# TNM 2.0 Co-op Self-Test Agent (MCP)

A small MCP server that lets an agent (Antigravity/Gemini, Claude, or any MCP client) walk the co-op UnrealScript, flag co-op hazards, rebuild `TNM.u`, and run a local host + client session to check the result. It has no dependencies (Python 3.8+ standard library only) and runs on Windows next to the game.

Everything also works as plain command-line scripts, so you can use it without an agent.

## Setup

1. Paths. The defaults assume `C:\Program Files (x86)\Steam\...`. If your Steam library is elsewhere, create `Tools/coop_selftest/selftest_config.json`:
   ```json
   {
     "game_dir": "D:/games/steam/steamapps/common/Deus Ex/Revision/TNM2",
     "workshop_dir": "D:/games/steam/steamapps/workshop/content/397550/1774011024"
   }
   ```
   (or set `TNM_GAME_DIR` / `TNM_WORKSHOP_DIR`). `bundle_dir` defaults to the folder this README lives in, two levels up.
2. Register the server with your MCP client. For Antigravity, add this to `mcp_config.json` (Agent panel → MCP Servers → Manage → View raw config):
   ```json
   {
     "mcpServers": {
       "tnm-coop-selftest": {
         "command": "python",
         "args": ["-I", "C:/path/to/TNM2_Coop_Playtest_Bundle/Tools/coop_selftest/mcp_server.py"]
       }
     }
   }
   ```
   Claude Code: `claude mcp add tnm-coop-selftest -- python -I C:/path/to/.../mcp_server.py`

## Tools

| Tool | What it does |
|---|---|
| `scan_scripts` | Runs every rule below over all classes. Markdown grouped by class, or JSON. Filter by `class_filter` (regex), `rules`, `min_severity` (default `warning`). |
| `list_host_only_sites` | Only the findings where a script relies on the host instead of any player. |
| `list_classes` | Classes with parent and size. |
| `get_class_source` | Read a class with line numbers (`start_line`/`end_line`, 400 lines per call). |
| `find_references` | Regex search across all classes. |
| `export_package` | Extract script text from any UE1 `.u` (Workshop `TNM.u`, `TNMItems.u`, stock `DeusEx.u`...) and scan/read it with `source=<returned folder>`. |
| `analyze_map` | Exports a map (e.g. `20_FCDowntown`) and reports co-op risks for what's actually placed in it: radius conversations that only start for the host, skill awards only the toucher gets, triggers wired to toggle/control doors, and inherited host-only code per placed class. First run per map ~30 s. CLI: `map_analysis.py <map>`. |
| `list_conversations` | TNM conversations with owner, radius/frob invocation, first-person, once. CLI: `conversations.py`. |
| `build_tnm` | Compile `Source/Classes` into `TNM.u` with HTK. `deploy=true` installs it and backs up the old one. Refuses to install on any compile error. |
| `run_coop_session` | Starts a listen-server host and a client on 127.0.0.1, waits for the join, lets it run `soak_seconds` (default 30), then reports: join, crashes, script warnings, runaway loops, and whether client music started. Uses its own log files and only stops processes it started. **Opens two game windows.** |
| `stop_coop_session` | Stops a session started with `keep_running=true`. |
| `read_log` | Tails `host`/`client` (self-test logs), `build`, or the player's own `player_host`/`player_client` logs, with an optional regex filter. |

By default (`source="installed"`), scanning reads the installed `CoopMod\System\TNM.u` (all ~375 classes) with the editable copies in `Source/Classes` laid on top, so it always reflects your current edits.

## Rules

Each rule comes from a bug that was actually hit in the co-op port (details in `AGENTS.md`).

| Rule | Severity | Flags |
|---|---|---|
| `HOST_ONLY` | warning / info | `GetPlayerPawn()`, which returns the **host** on a listen server. Warning when the line does gameplay (damage, distance, inventory, triggers, Tick/Touch); info for achievements, autosave and config. |
| `HOST_ONLY_FLAGS` | info | Host `flagBase` access. Fine while `tnmGameInfo.CoopMergeFlags` merges host and client flags every second. |
| `FIRST_PLAYER_ONLY` | warning | `foreach AllActors(class'Trestkon'/'DeusExPlayer'/...)` that `break`s or `return`s, i.e. only handles the first player. Heuristic; check each one. |
| `MISSION_HOST_PLAYER` | warning | In `MissionScript` subclasses, `Player` is the host; distance/location/state checks on it ignore the client. |
| `NETMODE_BRANCH` | info | `NetMode ==/!= NM_Standalone`. Co-op takes the netgame branch, which in stock Deus Ex is **deathmatch** logic (tnmGameInfo is not a DeusExMPGame). |
| `REP_FUNC_NETOWNER` | error | Replicated **functions** under a `bNetOwner` condition: stale at call time, so the call can run on the server instead of reaching the client. |
| `VAR_CLIENT_TO_SERVER` | warning | Variables in a `Role < ROLE_Authority` replication list. UE1 never sends variables client→server. |
| `OGG_NATIVE_ON_CLIENT` | warning | DXOgg natives in simulated code. They are no-ops unless `Role == ROLE_Authority`; use `TNMOggMusicManager.CoopNative*`. |
| `DANGLING_AMMO_BUTTON` | error/warning | `GetSelectedAmmo()`: reads a destroyed button after the inventory info pane is cleared (client crash). |

The scanner is regex-based. Expect some false positives, and treat findings as "go read this", not "this is wrong". Validated against the previous co-op build, it flags every bug fixed in this round.

## Suggested agent workflow

Paste into the agent:

> Use the tnm-coop-selftest tools. 1) `list_host_only_sites` and triage every warning: read the code with `get_class_source`, decide whether the client should be included, and propose a fix (instigator/toucher, closest Trestkon, or all Trestkon in `Level.PawnList`). 2) `scan_scripts` with `min_severity=error`, which must come back empty. 3) For each fix, edit `Source/Classes` (export a class first if it isn't there; see AGENTS.md §2 on keeping `defaultproperties` and descendants), `build_tnm`, then `run_coop_session` and check `ok`, `client_music_started`, zero crashes and no new script warnings. Report what changed and what still needs a human playtest.

## What it can't check

It runs no input or gameplay. Movement feel, combat, conversations, turrets and pickups still need a human playtest; the runner only proves both sides load, join, stay up without script errors, and that client music starts. Log lines from your own `log()` calls show up in `read_log`, so temporary logging plus `run_coop_session` is the fastest way to check a specific fix (that's how the client-music bug was found).

## Command line

```bash
python -I Tools/coop_selftest/scanner.py --min warning --out scan.md   # or --rule HOST_ONLY --class Mission
python -I Tools/coop_selftest/builder.py [--deploy]
python -I Tools/coop_selftest/runner.py --soak 30 [--map 21_SomeMap]
```

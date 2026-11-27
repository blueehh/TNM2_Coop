# Co-op desync review: first outdoor quest (20_FCDowntown)

`20_PhasApartment` exits to `20_FCDowntown` (`MapExit0`, `DestMap="20_FCDowntown#PhasApt"`). The map has 9,777 actors: 86 NPCs, 92 movers, 23 teleporters, and about 70 logic triggers. The generated per-map report is `map_20_FCDowntown.md` (from `Tools/coop_selftest/map_analysis.py`, MCP tool `analyze_map`). This file is the reading of it.

Everything below is from static analysis of the map export, the stock DeusEx/Engine scripts the game actually loads (`Deus Ex\System\DeusEx.u`), and the TNM packages.

**Status (2026-10-30): findings 1–7 are fixed** (AGENTS.md §3M). Verified: the build compiles, no defaults changed across 387 classes, and host+client self-tests pass on 20_PhasApartment and 20_FCDowntown (12 skill-award triggers replaced at load). Not yet verified by playing: the client doing the Kale hand-off, XP for both players, NPC reactions. A new, pre-existing issue found while testing is at the end.

## Findings, by impact

### 1. Proximity conversations only start for the host — blocks the Kale quest when the client does it
Stock `ScriptedPawn.Tick` (and `DeusExDecoration.Tick`) do `player = DeusExPlayer(GetPlayerPawn()); ... player.StartConversation(Self, IM_Radius)`. On a listen server that is always the host, and TNM doesn't override it. In Downtown, 9 radius conversations are affected, including the first quest's handoffs:

| Owner | Conversation | Radius |
|---|---|---|
| DowntownFirewall | `DowntownFirewall_Mission` (quest start) | 192 |
| DowntownFirewall | `DowntownFirewall_DeliveredKale` | 256 |
| DowntownFirewall | `DowntownFirewall_ArrestedKale1` / `_ArrestedKale2` | 192 |
| DTThug1, DowntownMale01/04/05, DowntownFemale06 | thug/rumour barks (first-person) | 128–384 |

If the client walks Kale back to Firewall alone, nothing fires until the host comes within ~2–3 m. Frob-started conversations work for either player; only radius ones are host-only. SolsBar has 4 more (`LlamaRumours`, `Gambler`, `Gambler_Drunk`, `SnipaMasta_Drunk`).

**Fix:** `tnmGameInfo` keeps a list of actors with `conListItems` and, a few times a second, calls `T.StartConversation(A, IM_Radius)` for each non-host `Trestkon` near one. `StartConversation` already does the radius, flag and "already playing" checks, and the co-op conversation code already handles a client initiator.

### 2. Map XP goes to whoever touches first — 670 points per run of Downtown
Stock `SkillAwardTrigger` awards `skillPointsAdded` to the toucher (`Touch`) or instigator (`Trigger`) only. Its class default is `bTriggerOnceOnly=True` (verified by exporting the stock defaults), so it then switches off. Downtown has 12 of them, all once-only (20–150 points each, 670 total). Nothing syncs skill points between players: mission-script awards (`TNMMissionScript.SkillAward`) already go to both, these don't. Over a campaign the two players' skill trees diverge.

**Fix:** at `InitGame`, replace each `SkillAwardTrigger` with a TNM subclass that awards every `Trestkon` (same Tag/Event/radius/message), or award the partner when the trigger turns off.

### 3. Flags lag between players by up to ~1 s (+ latency)
Each player has a server-side `flagBase`; `CoopMergeFlags` reconciles them **once a second** (from `SyncCoopState`).
- `FlagTrigger` (19 in Downtown, incl. the subway doors on `HAS_SubwayPass`) reads and writes the **host's** flags no matter who touches it.
- `ConversationTrigger` (`AemerKillTV`), `ConversationForceTrigger` (`GoatKidnapperOverheard`) and every client-started conversation check the **client's** flags.

So a flag one player just set can be invisible to the other side for up to 1 s. Example: buy the pass and step into the subway gate in under a second, and the gate refuses. Rarely a blocker, but it is a real ordering window. Mission scripts poll on their own 1 s `Timer`, so worst case is about 2 s from event to mission reaction for client-side changes.

**Fix:** run `CoopMergeFlags` at 4–5 Hz (cheap: a few thousand native lookups), and merge immediately when a conversation or datalink ends.

### 4. NPC reactions attributed to the host
Stock `ScriptedPawn` functions that resolve "the player" to `GetPlayerPawn()`:

| Function | Effect in co-op |
|---|---|
| `CheckBeamPresence` | Only the **host's** flashlight/augmentation beam alerts NPCs (the client is stealthier). Also gated on `LastRendered() < 5` from the host's view. |
| `HandleHacking` | Agitation from a hack is blamed on the host. |
| `InstigatorToPawn` | Events with a non-pawn instigator (alarms, noises) default to the host. |
| `CheckCarcassPresence` (stock part) | Bodies found are attributed to the host. It is also how TNM detects **trespassing** (`GetCarcassData` treats a player with `bBreakAndEnter` as carrying a body), so only the host could be caught trespassing, and the grudge went to the whole `Player` alliance. Fixed later (AGENTS.md §3M): every player is checked and the grudge is confirmed only by a trespasser. |
| `FindTaggedActor('')` | Orders with no tag (Following/RunningTo with empty `orderTag`) target the host. |
| `Tick` with `bDisappear` | Scripted "disappear" NPCs vanish once the **host** hasn't seen them for 5 s, even in front of the client. |

Hostility itself is shared: both players are alliance `Player`, so an NPC turning hostile is hostile to both. The differences are in **who gets noticed and blamed**. `TNMPawn` (all TNM NPCs) can override these without new variables; stock-class NPCs (`TNM_Medbot`, `RepairBot`, `Fish2`, `TNMRobot` family) need overrides on the robot classes too.

### 5. Triggers have no occupancy count
Engine `Trigger.Touch` fires per toucher and `UnTouch` fires when **either** player leaves. Downtown only wires non-once triggers to `TriggerOpenTimed` doors (subway gates), which are harmless. Maps with `TriggerToggle` doors would open-then-close when both enter, and `TriggerControl` doors would close on the partner. The map report flags these per map (`**RISK**`).

### 6. Shared credits: 1-second double-spend window
The shared credit pool (update 17_r) propagates each player's credit **delta** once a second. Both players spending in the same second (vending machines, the subway pass) can both succeed, and the balance clamps at 0. Small exploit, not a desync crash.

### 7. Minor host-only bits
`TNMBindNameTrigger` only tells the host's conversation about rebinding. `AchievementTrigger` and `GoalAddTrigger` act on the host; achievements are cosmetic, and goals reach the client via goal sync. `TNMPawn.HandleDamage` knockout falls back to the host when there's no instigator (partly fixed in 17_r).

## What 250 ms latency adds

Settings in `TNM_Host.ini` `[IpDrv.TcpNetDriver]`: `MaxClientRate=20000` (20 KB/s), `NetServerMaxTickRate=20` (internet), `KeepAliveTime=1.0`, `ConnectionTimeout=15`.

- **Triggers fire on the server's view of the client.** The server sees the client ~125 ms (half RTT) late, plus the 50 ms tick, so trigger zones, award zones and radius conversations react ~0.2–0.3 s after the client sees itself enter. Small zones (64 UU award triggers) can be clipped on a quick pass, since at 320 UU/s the client covers ~60 UU of lag.
- **Movement:** the singleplayer-parity fixes removed the speed mismatches. What's left is UE1's tight correction threshold (`ClientErr > 3`), so jitter shows up as small snaps on moving platforms and doors, not rubber-banding.
- **State sync is 1 Hz plus latency.** Door lock state, hackable state, NPC IFF colours, flags, goals, credits and music are pushed once a second, so the client sees changes up to ~1.1 s late. Gameplay decisions stay server-side; this is mostly display (a door shows locked for a second after the host unlocks it).
- **Reliable traffic is steady even when idle.** At the densest spot in Downtown, `SyncCoopState` sends about 29 reliable RPCs per second per client whether anything changed or not: 16 `ClientSyncMoverState`, up to 10 NPC-alliance `ClientSyncHackableState`, music, credits and infolink. On top of that come bursts of up to 24 flags + 8 goals/notes. That's well under 20 KB/s, but with 250 ms RTT and packet loss, unacknowledged reliable bunches pile up (UE1 drops the connection on reliable-buffer overflow). It's comfortable today; it should send only on change.
- **Combat has no lag compensation** (UE1). The client has to lead moving NPCs by about RTT/2.
- **Conversations:** choices go client→server via `ServerSyncBoolFlag`, so each pick takes one round trip (~250 ms) to register. Subtitles arrive ~125 ms after the host sees them.

## Pre-existing: client `ReplicateMove` Accessed None in Downtown (open)
The client logs `Engine.PlayerPawn.ReplicateMove:059B Accessed None`, about 2–3 times a second, only on maps with moving NPCs near the player (136 per 45 s on the previous build, 98 on this one; zero in the apartment). The client's `PlayerReplicationInfo` (ping ~88 ms) and `Player` are valid, so it isn't the obvious ping lookup. The code around it is UE1's collision compensation for nearby moving pawns, so worth chasing for high-latency play. Next step is mapping offset 0x59B in the stock bytecode.

## Suggested fix order (all applied, see AGENTS.md §3M)

1. Radius conversations for non-host players (`tnmGameInfo`), fixes the Kale/Firewall handoff.
2. Shared skill awards for map `SkillAwardTrigger`s.
3. Flag merge at 4–5 Hz and on conversation end.
4. `TNMPawn` overrides: `CheckBeamPresence` (all players), `HandleHacking`/`InstigatorToPawn` (the actual instigator, else the closest player), `FindTaggedActor('')` (closest player), `bDisappear` (no player has seen it).
5. Send `ClientSyncMoverState`/`ClientSyncHackableState` only when state changes.
6. Trigger occupancy for toggle/control doors (per map, as the report finds them).

Each is checkable with `run_coop_session` plus a targeted `log()`, and with a two-player walk through the Kale quest where the **client** does the escort.

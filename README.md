# Deus Ex: The Nameless Mod 2.0 — Co-op Campaign Mod (`bluehh™`)

2-player cooperative campaign mod for **The Nameless Mod 2.0** (*Deus Ex: Game of the Year Edition* / *Deus Ex: Revision*, Unreal Engine 1), built for full story progression, per-username host-saved loadouts, native HUD chat/pings/trading, and smooth play up to **250ms–500ms** ping.

---

## 1. Prerequisites (Players & Co-Developers)

Both players need on Steam:
1. **Deus Ex: Game of the Year Edition**
2. **Deus Ex: Revision**
3. **The Nameless Mod 2.0** subscribed on Steam Workshop (Workshop ID `1774011024`), so your game folder exists at:
   `...\steamapps\common\Deus Ex\Revision\TNM2\`

---

## 2. Quick Start — Installing & Playing (Playtest Bundle)

1. Extract the contents of `TNM2_Coop_Playtest_Bundle` directly into your `...\steamapps\common\Deus Ex\Revision\TNM2\` folder.
2. **Host (Listen Server):** Run `Host_TNM_Coop.bat` (or launch via `TNM_Host.ini` and click **Multiplayer** on the main menu). Default UDP port is `7790` (works great over ZeroTier, Tailscale, Radmin VPN, or port-forwarding UDP `7790–7791`).
3. **Client (Partner):** Run `Join_TNM_Coop.bat` (or open **Multiplayer**, set your **Player Name**, paste the Host IP with `Ctrl+V`, and click **Join Server**).
4. **Single-PC Local Testing:**
   - `Test_Local_Coop.bat` — launches windowed Host + Client side-by-side on `127.0.0.1`.
   - `Test_Local_Coop_250ms.bat` — launches Host + Client with simulated ~250ms latency (`PktLag`).

---

## 3. Co-Development Workflow (Git & GitHub Desktop)

This repository is structured so multiple developers can pull, edit UnrealScript, compile, test, and push cleanly **without hardcoded drive paths or binary merge conflicts**.

### First-Time Setup for Co-Developers
1. Clone this repository anywhere on your PC using **GitHub Desktop** (e.g. `Documents\GitHub\tnm2-coop` or `D:\antigravity\...`).
2. Make sure **Python 3** is installed and in your `PATH`.
3. Double-click **`Build_And_Deploy_Coop.bat`**!
   - `Tools/coop_selftest/config.py` automatically detects your Steam install (`Revision\TNM2` and Workshop `1774011024`) across `C:\`, `D:\`, `E:\`, etc. via Steam's `libraryfolders.vdf`.
   - Compiles all `Source/Classes/*.uc` files + custom meshes/textures/audio into `CoopMod/System/TNM.u` (~12–15 seconds) and deploys it alongside `DXOgg.dll`, `Engine.int`, and `.bat`/`.ini` launchers into your Steam `Revision\TNM2` folder.
   - *(Optional)* If your game lives in a non-Steam custom folder, copy `Tools/coop_selftest/selftest_config.example.json` to `Tools/coop_selftest/selftest_config.json` (gitignored) and set `"game_dir"` / `"workshop_dir"`.

### Daily Pull / Edit / Push Cycle
1. **Pull latest changes** in GitHub Desktop (`Fetch origin` -> `Pull origin`).
2. **Edit UnrealScript** in `Source/Classes/*.uc` (read [`Source/COOP_CODEBASE_GUIDE.md`](Source/COOP_CODEBASE_GUIDE.md) and [`AGENTS.md`](AGENTS.md) before adding variables to base classes!).
3. **Sanity-check & Build:**
   - Double-click `Build_And_Deploy_Coop.bat` (or run `python -I Tools/coop_selftest/builder.py --deploy` and `python -I Tools/coop_selftest/scanner.py`).
   - Note: `CoopMod/System/TNM.u` is intentionally `.gitignore`d so co-developers never hit 41 MB binary merge conflicts on every commit; `Tools/CleanBase_TNM.u` is tracked so anyone can build `TNM.u` locally in one click.
4. **Test in-game** (`Test_Local_Coop.bat` or `python -I Tools/coop_selftest/runner.py`).
5. **Commit & Push** your `.uc` / tool changes in GitHub Desktop!

### Packing a Shareable Zip for Non-Dev Playtesters
- Double-click **`Pack_Playtest_Bundle.bat`** (or run `python -I Tools/pack_bundle.py`).
- Automatically builds `CoopMod/System/TNM.u` if missing and creates a clean `TNM2_Coop_Playtest_Bundle_YYYY-MM-DD.zip` right next to the repository folder (with `CoopMod/System/TNM.u` included and `.git`, caches, logs, and personal save slots stripped out), ready to send to friends or attach to a GitHub Release.

---

## 4. Key Documentation
- [`Source/COOP_CODEBASE_GUIDE.md`](Source/COOP_CODEBASE_GUIDE.md) — Class-by-class map of all `Coop*.uc`, `Yuuka*.uc`, and modified TNM classes + binary layout rules.
- [`AGENTS.md`](AGENTS.md) — Deep technical guide to the `HTK.exe` build pipeline, UE1 replication caveats, and root-cause writeups.
- [`CHANGES.md`](CHANGES.md) — Full chronological changelog.

---

*TNM 2.0 Co-op Mod by `bluehh™` — Built for The Nameless Mod 2.0 by Off Topic Productions.*

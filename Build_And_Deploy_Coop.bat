@echo off
setlocal
cd /d "%~dp0"

echo ============================================================================
echo   TNM 2.0 Co-op Mod - Build ^& Deploy to Local Steam Install
echo ============================================================================
echo.

python -I "Tools\coop_selftest\builder.py" --deploy
if errorlevel 1 (
    echo.
    echo [ERROR] Build failed! Check htk_build.log in your TNM2 game folder.
    pause
    exit /b 1
)

python -I -c "import os, shutil, sys; sys.path.insert(0, r'Tools\coop_selftest'); import config; cfg=config.load(); b, g = cfg['bundle_dir'], cfg['game_dir']; same = os.path.normcase(os.path.abspath(b)) == os.path.normcase(os.path.abspath(g)); [shutil.copy2(os.path.join(b, f), os.path.join(g, f)) for f in ('DXOgg.dll','Engine.int','Host_TNM_Coop.bat','Join_TNM_Coop.bat','Test_Local_Coop.bat','Test_Local_Coop_250ms.bat') if not same and os.path.isfile(os.path.join(b, f))]; os.makedirs(os.path.join(g, 'CoopMod', 'System'), exist_ok=True); (not same and os.path.isfile(os.path.join(b, 'DXOgg.dll')) and shutil.copy2(os.path.join(b, 'DXOgg.dll'), os.path.join(g, 'CoopMod', 'System', 'DXOgg.dll'))); [shutil.copy2(os.path.join(b, f), os.path.join(g, f)) for f in ('TNM_Host.ini','TNM_Client.ini','TNMUser_Host.ini','TNMUser_Client.ini') if not same and os.path.isfile(os.path.join(b, f)) and not os.path.exists(os.path.join(g, f))]; print('Synced runtime files to:', g)"

echo.
echo [SUCCESS] CoopMod\System\TNM.u compiled and deployed cleanly!
if "%1"=="" pause

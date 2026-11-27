@echo off
setlocal
cd /d "%~dp0"

echo ============================================================================
echo   TNM 2.0 Co-op Mod - Pack Clean Playtest Bundle (.zip)
echo ============================================================================
echo.

if not exist "CoopMod\System\TNM.u" (
    echo CoopMod\System\TNM.u not found locally - building first...
    call "%~dp0Build_And_Deploy_Coop.bat" nopause
    if errorlevel 1 exit /b 1
)

python -I "Tools\pack_bundle.py" %2
if errorlevel 1 (
    echo [ERROR] Bundle packaging failed.
    if "%1"=="" pause
    exit /b 1
)

echo.
if "%1"=="" pause

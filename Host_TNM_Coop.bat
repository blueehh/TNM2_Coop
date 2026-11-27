@echo off
title The Nameless Mod 2.0 - Co-op Host Launcher
set "GAMEDIR=%~dp0"
if not exist "%GAMEDIR%TNM.exe" set "GAMEDIR=C:\Program Files (x86)\Steam\steamapps\common\Deus Ex\Revision\TNM2\"
if not exist "%GAMEDIR%TNM.exe" set "GAMEDIR=D:\games\steam\steamapps\common\Deus Ex\Revision\TNM2\"
cd /d "%GAMEDIR%"
echo ============================================================
echo   The Nameless Mod 2.0 - Co-op Listen Server Launcher
echo ============================================================
echo.
set /p PLAYERNAME="Enter Host Player Name [default: Trestkon]: "
if "%PLAYERNAME%"=="" set PLAYERNAME=Trestkon
set /p STARTMAP="Enter Starting Map [default: 20_PhasApartment]: "
if "%STARTMAP%"=="" set STARTMAP=20_PhasApartment
echo.
del /f /q "Running.ini" >nul 2>&1
del /f /q "..\TNM2Save\Current\*.dxs" >nul 2>&1
echo Launching TNM 2.0 Co-op Server on %STARTMAP% as %PLAYERNAME% (UDP Port 7790)...
start "TNM Co-op Host" "%GAMEDIR%TNM.exe" "%STARTMAP%?Name=%PLAYERNAME%?Class=TNM.Trestkon?Game=TNM.TNMGameInfo?Listen" INI=TNM_Host.ini USERINI=TNMUser_Host.ini LOG=TNM_Host.log -hax0r

@echo off
title The Nameless Mod 2.0 - Co-op Client Launcher
set "GAMEDIR=%~dp0"
if not exist "%GAMEDIR%TNM.exe" set "GAMEDIR=C:\Program Files (x86)\Steam\steamapps\common\Deus Ex\Revision\TNM2\"
if not exist "%GAMEDIR%TNM.exe" set "GAMEDIR=D:\games\steam\steamapps\common\Deus Ex\Revision\TNM2\"
cd /d "%GAMEDIR%"
echo ============================================================
echo   The Nameless Mod 2.0 - Co-op Client Launcher
echo ============================================================
echo.
set /p SERVERIP="Enter Host IP Address [default: 127.0.0.1]: "
if "%SERVERIP%"=="" set SERVERIP=127.0.0.1
set /p PLAYERNAME="Enter Your Player Name [default: Partner]: "
if "%PLAYERNAME%"=="" set PLAYERNAME=Partner
echo.
del /f /q "Running.ini" >nul 2>&1
echo Connecting to %SERVERIP% as %PLAYERNAME%...
start "TNM Co-op Client" "%GAMEDIR%TNM.exe" "%SERVERIP%?Name=%PLAYERNAME%?Class=TNM.Trestkon" INI=TNM_Client.ini USERINI=TNMUser_Client.ini LOG=TNM_Client.log -hax0r

@echo off
title The Nameless Mod 2.0 - Local 2-Player Co-op Test
set "GAMEDIR=%~dp0"
if not exist "%GAMEDIR%TNM.exe" set "GAMEDIR=C:\Program Files (x86)\Steam\steamapps\common\Deus Ex\Revision\TNM2\"
if not exist "%GAMEDIR%TNM.exe" set "GAMEDIR=D:\games\steam\steamapps\common\Deus Ex\Revision\TNM2\"
cd /d "%GAMEDIR%"
echo ============================================================
echo   The Nameless Mod 2.0 - Local 2-Player Co-op Test
echo   Launches Windowed Host (Trestkon) + Windowed Client (Partner)
echo ============================================================
echo.
set STARTMAP=%~1
if "%STARTMAP%"=="" set STARTMAP=20_PhasApartment
del /f /q "Running.ini" >nul 2>&1
del /f /q "..\TNM2Save\Current\*.dxs" >nul 2>&1
echo [1/2] Starting Co-op Listen Server on %STARTMAP%...
start "TNM Co-op Host" "%GAMEDIR%TNM.exe" "%STARTMAP%?Name=Trestkon?Class=TNM.Trestkon?Game=TNM.TNMGameInfo?Listen" INI=TNM_Host.ini USERINI=TNMUser_Host.ini LOG=TNM_Host.log -hax0r
echo Waiting 10 seconds for server initialization...
timeout /t 10 /nobreak >nul
del /f /q "Running.ini" >nul 2>&1
echo [2/2] Starting Co-op Client connecting to 127.0.0.1:7790...
start "TNM Co-op Client" "%GAMEDIR%TNM.exe" "127.0.0.1?Name=Partner?Class=TNM.Trestkon" INI=TNM_Client.ini USERINI=TNMUser_Client.ini LOG=TNM_Client.log -hax0r
echo.
echo Both instances launched! Press Alt+Tab to switch between Host and Client windows.

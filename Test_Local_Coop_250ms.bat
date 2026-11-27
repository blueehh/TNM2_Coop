@echo off
title The Nameless Mod 2.0 - Local 2-Player Co-op Test (250ms Simulated Ping)
set "GAMEDIR=%~dp0"
if not exist "%GAMEDIR%TNM.exe" set "GAMEDIR=C:\Program Files (x86)\Steam\steamapps\common\Deus Ex\Revision\TNM2\"
if not exist "%GAMEDIR%TNM.exe" set "GAMEDIR=D:\games\steam\steamapps\common\Deus Ex\Revision\TNM2\"
cd /d "%GAMEDIR%"

:: Simulated Round-Trip Ping in ms (default 250ms = 125ms each way; pass e.g. 500 as 2nd arg or change below)
set PING_MS=%~2
if "%PING_MS%"=="" set PING_MS=250
set /a ONEWAY_MS=%PING_MS% / 2

echo ============================================================
echo   The Nameless Mod 2.0 - Local 2-Player Co-op (%PING_MS%ms Ping Test)
echo   Simulating %PING_MS%ms Round-Trip Latency (PktLag=%ONEWAY_MS%ms each way)
echo   Launches Windowed Host (Trestkon) + Windowed Client (Partner)
echo ============================================================
echo.
set STARTMAP=%~1
if "%STARTMAP%"=="" set STARTMAP=20_PhasApartment
del /f /q "Running.ini" >nul 2>&1
del /f /q "..\TNM2Save\Current\*.dxs" >nul 2>&1
echo [1/2] Starting Co-op Listen Server on %STARTMAP% (PktLag=%ONEWAY_MS%ms)...
start "TNM Co-op Host (%PING_MS%ms)" "%GAMEDIR%TNM.exe" "%STARTMAP%?Name=Trestkon?Class=TNM.Trestkon?Game=TNM.TNMGameInfo?Listen" PktLag=%ONEWAY_MS% INI=TNM_Host.ini USERINI=TNMUser_Host.ini LOG=TNM_Host.log -hax0r
echo Waiting 10 seconds for server initialization...
timeout /t 10 /nobreak >nul
del /f /q "Running.ini" >nul 2>&1
echo [2/2] Starting Co-op Client connecting to 127.0.0.1:7790 (PktLag=%ONEWAY_MS%ms)...
start "TNM Co-op Client (%PING_MS%ms)" "%GAMEDIR%TNM.exe" "127.0.0.1?Name=Partner?Class=TNM.Trestkon" PktLag=%ONEWAY_MS% INI=TNM_Client.ini USERINI=TNMUser_Client.ini LOG=TNM_Client.log -hax0r
echo.
echo Both instances launched with %PING_MS%ms simulated round-trip ping!
echo (Tip: Run "Test_Local_Coop_250ms.bat 20_PhasApartment 500" to test 500ms ping)

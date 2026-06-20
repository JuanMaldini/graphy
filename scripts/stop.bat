@echo off
setlocal EnableExtensions EnableDelayedExpansion
call "%~dp0_env.bat"

set "PIDFILE=%GRAPHY_HOME%\logs\graphify.pid"
set "WPIDFILE=%GRAPHY_HOME%\logs\watchers.pid"

rem --- 1) Detener watchers ---
if exist "%WPIDFILE%" (
    echo Deteniendo watchers...
    for /f "usebackq delims=" %%p in ("%WPIDFILE%") do (
        if not "%%p"=="" taskkill /PID %%p /F >nul 2>&1
    )
    del "%WPIDFILE%" 2>nul
)

rem --- 2) Detener servidor MCP ---
if not exist "%PIDFILE%" (
    echo [INFO] Sin PID file del server. Matando procesos python de graphify...
    taskkill /IM python.exe /F /FI "WINDOWTITLE eq Graphify MCP*" 2>nul
    echo Listo.
    endlocal
    exit /b 0
)

set /p PID=<"%PIDFILE%"
echo Deteniendo Graphify MCP server (PID !PID!)...
taskkill /PID !PID! /F >nul 2>&1
if !errorlevel! neq 0 (echo [WARN] Proceso !PID! no encontrado.) else (echo Detenido.)
del "%PIDFILE%" 2>nul
endlocal
exit /b 0

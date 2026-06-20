@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

if not exist "logs" mkdir "logs"
for /f %%t in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "TS=%%t"
set "LOG=logs\stop_%TS%.log"

echo Log de esta corrida: %LOG%
echo.

(
    call "scripts\stop.bat"
) 2>&1 | powershell -NoProfile -Command "$input | Tee-Object -FilePath '%LOG%'"

echo.
echo Log guardado en: %LOG%
pause

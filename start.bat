@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

if not exist "logs" mkdir "logs"
for /f %%t in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "TS=%%t"
set "LOG=logs\setup_%TS%.log"

echo ========================================
echo   GRAPHIFY - Setup completo
echo ========================================
echo.
echo   Log de esta corrida: %LOG%
echo.
echo Apreta cualquier tecla para empezar.
pause >nul
echo.

rem --- Corre setup + ollama + index mostrando en pantalla Y guardando en log ---
(
    call "scripts\setup.bat"
    echo.
    call "scripts\ollama.bat"
    echo.
    call "scripts\deploy-ignore.bat"
    echo.
    call "scripts\index.bat"
) 2>&1 | powershell -NoProfile -Command "$input | Tee-Object -FilePath '%LOG%'"

echo.
echo ========================================
echo   RESUMEN
echo ========================================
for /f %%n in ('findstr /R /C:"MISSING" "%LOG%" ^| find /c /v ""') do set "NMISS=%%n"
for /f %%n in ('findstr /R /C:"WARN" /C:"Fallo" "%LOG%" ^| find /c /v ""') do set "NWARN=%%n"
for /f %%n in ('findstr /R /C:"ERROR" "%LOG%" ^| find /c /v ""') do set "NERR=%%n"
echo   MISSING : !NMISS!    (falta instalar/crear algo)
echo   WARN    : !NWARN!    (un repo no se indexo, pero siguio)
echo   ERROR   : !NERR!
echo.
if !NMISS! gtr 0 (
    echo   Detalle MISSING:
    findstr /R /C:"MISSING" "%LOG%"
    echo.
)
if !NWARN! gtr 0 (
    echo   Detalle WARN/Fallo:
    findstr /R /C:"WARN" /C:"Fallo" "%LOG%"
    echo.
)
if !NERR! gtr 0 (
    echo   Detalle ERROR:
    findstr /R /C:"ERROR" "%LOG%"
    echo.
)

echo Log completo guardado en: %LOG%
echo Usa run.bat para iniciar el servidor.
echo.
pause >nul

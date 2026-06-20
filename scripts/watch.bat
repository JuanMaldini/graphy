@echo off
setlocal EnableExtensions EnableDelayedExpansion
call "%~dp0_env.bat"

if not exist "%GRAPHY_HOME%\logs" mkdir "%GRAPHY_HOME%\logs"
set "WPIDFILE=%GRAPHY_HOME%\logs\watchers.pid"
del "%WPIDFILE%" 2>nul

echo Iniciando watchers (auto-update ante cada cambio de codigo)...

set "ROOTS=%GRAPHIFY_REPOS%"
for %%R in ("%ROOTS:;=" "%") do (
    set "R=%%~R"
    set "NAME=%%~nxR"
    if exist "!R!" (
        echo   watch -^> !R!
        powershell -NoProfile -Command "$p = Start-Process graphify -ArgumentList 'watch','!R!' -WindowStyle Hidden -RedirectStandardOutput '%GRAPHY_HOME%\logs\watch-!NAME!.out' -RedirectStandardError '%GRAPHY_HOME%\logs\watch-!NAME!.err' -PassThru; Add-Content -Path '%WPIDFILE%' -Value $p.Id"
    ) else (
        echo   [SKIP] !R! no existe
    )
)

echo.
echo Watchers en marcha. PIDs guardados en %WPIDFILE%
echo Logs por repo: logs\watch-NOMBRE.out / .err
echo (Si dice "watchdog not installed", corre:  pip install watchdog)
endlocal
exit /b 0

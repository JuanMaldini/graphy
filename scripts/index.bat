@echo off
setlocal EnableExtensions EnableDelayedExpansion
call "%~dp0_env.bat"

where graphify >nul 2>&1
if !errorlevel! neq 0 (
    echo [ERROR] graphify no instalado. Corre Setup primero.
    exit /b 1
)

rem Backend para la fase semantica (viene del .env; por defecto ollama)
set "BACKEND=%GRAPHIFY_BACKEND%"
if "!BACKEND!"=="" set "BACKEND=ollama"
echo Indexando con backend: !BACKEND!  (modelo ollama: %OLLAMA_MODEL%)
echo.

set "ROOTS=%GRAPHIFY_REPOS%"
set /a COUNT=0
set /a TOTAL=0
for %%R in ("%ROOTS:;=" "%") do set /a TOTAL+=1

echo Re-indexando !TOTAL! roots...
echo.

for %%R in ("%ROOTS:;=" "%") do (
    set "R=%%~R"
    set /a COUNT+=1
    if exist "!R!" (
        echo [!COUNT!/!TOTAL!] !R!
        pushd "!R!"
        if exist "graphify-out\graph.json" (
            echo   --update ^(incremental^)
            call graphify . --backend !BACKEND! --update
        ) else (
            echo   --full build
            call graphify . --backend !BACKEND!
        )
        if !errorlevel! neq 0 (echo   [WARN] Fallo en !R!)
        popd
        echo.
    ) else (
        echo [!COUNT!/!TOTAL!] !R! [SKIP - no existe]
        echo.
    )
)

echo Indexado completo.
endlocal
exit /b 0

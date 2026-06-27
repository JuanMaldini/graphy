@echo off
setlocal EnableExtensions EnableDelayedExpansion
call "%~dp0_env.bat"

set "PIDFILE=%GRAPHY_HOME%\logs\graphify.pid"

rem --- elegir el primer graph.json existente entre GRAPHIFY_REPOS ---
set "GRAPH_TO_SERVE="
for %%R in ("%GRAPHIFY_REPOS:;=" "%") do (
    if not defined GRAPH_TO_SERVE if exist "%%~R\graphify-out\graph.json" set "GRAPH_TO_SERVE=%%~R\graphify-out\graph.json"
)

if not defined GRAPH_TO_SERVE (
    echo [ERROR] No se encontro ningun graph.json. Corre Indexar primero.
    exit /b 1
)

set "PY=%USERPROFILE%\AppData\Roaming\uv\tools\graphifyy\Scripts\python.exe"
if not exist "!PY!" (
    echo [WARN] No se encontro python en !PY!
    echo        Revisa la ruta de la herramienta uv ^(ver NOTAS-RUTAS.txt^).
)

rem --- Asegurar que el extra [mcp] (uvicorn + starlette) este instalado ---
rem     Usamos pip dentro del venv en vez de uv tool install --force,
rem     porque --force intenta borrar Scripts\ mientras python.exe esta corriendo.
"!PY!" -c "import uvicorn" >nul 2>&1
if !errorlevel! neq 0 (
    echo [INFO] Falta uvicorn. Instalando extras [ollama,mcp] de graphifyy con uv...
    rem  El venv de uv no trae pip; reinstalamos la herramienta con los extras.
    rem  Incluimos [ollama] para NO perder el backend de indexado.
    uv tool install "graphifyy[ollama,mcp]" --force
    if !errorlevel! neq 0 (
        echo [ERROR] Fallo uv tool install "graphifyy[ollama,mcp]".
        echo         Proba manualmente ^(con el server detenido^):
        echo           uv tool install "graphifyy[ollama,mcp]" --force
        exit /b 1
    )
    echo [OK] uvicorn instalado.
)

if exist "%PIDFILE%" (
    set /p OLDPID=<"%PIDFILE%"
    if defined OLDPID if not "!OLDPID!"=="" (
        tasklist /FI "PID eq !OLDPID!" 2>nul | find /I "python" >nul
        if !errorlevel! equ 0 (
            echo Servidor ya corriendo PID !OLDPID!
            exit /b 0
        )
    )
    del "%PIDFILE%" >nul 2>&1
)

if not exist "%GRAPHY_HOME%\logs" mkdir "%GRAPHY_HOME%\logs"

echo Sirviendo: !GRAPH_TO_SERVE!
echo Iniciando MCP server en http://%GRAPHY_MCP_HOST%:%GRAPHY_MCP_PORT%/mcp ...

powershell -NoProfile -Command "Start-Process '!PY!' -ArgumentList '-m graphify.serve ''!GRAPH_TO_SERVE!'' --transport http --host %GRAPHY_MCP_HOST% --port %GRAPHY_MCP_PORT%' -WorkingDirectory '%GRAPHY_HOME%' -WindowStyle Hidden -RedirectStandardOutput '%GRAPHY_HOME%\logs\graphify.out' -RedirectStandardError '%GRAPHY_HOME%\logs\graphify.err'; Start-Sleep -Seconds 3; $procs = Get-Process python -ErrorAction SilentlyContinue | Sort-Object StartTime -Descending | Select-Object -First 1; if ($procs) { [System.IO.File]::WriteAllText('%PIDFILE%', $procs.Id.ToString() + [Environment]::NewLine) }"

echo.
echo URL: http://%GRAPHY_MCP_HOST%:%GRAPHY_MCP_PORT%/mcp

rem --- Lanzar watchers para auto-update ante cada cambio ---
echo.
call "%~dp0watch.bat"

echo.
echo Servidor + watchers en marcha. Usa stop.bat para apagar todo.
endlocal
exit /b 0

@echo off
rem ============================================================
rem  _env.bat  -  cargador de configuracion compartido
rem  Uso:  call "%~dp0_env.bat"   (desde cualquier script de scripts\)
rem  No usa setlocal a proposito: asi las variables quedan
rem  disponibles en el script que lo llama.
rem
rem  1) Carga el .env (solo rutas especificas de esta maquina).
rem  2) Aplica los valores fijos (hardcoded) del proyecto.
rem  3) Deriva rutas a partir de GRAPHY_HOME.
rem ============================================================

rem --- 1) Cargar .env de la raiz (si existe) ---
if exist "%~dp0..\.env" (
    for /f "usebackq eol=# tokens=1,* delims==" %%a in ("%~dp0..\.env") do (
        if not "%%a"=="" set "%%a=%%b"
    )
)

rem --- GRAPHY_HOME: si no vino en .env, derivar de la ubicacion del script ---
if not defined GRAPHY_HOME (
    pushd "%~dp0.." & set "GRAPHY_HOME=%CD%" & popd
)

rem --- 2) Valores fijos del proyecto (no van en .env) ---
set "GRAPHY_MCP_HOST=127.0.0.1"
set "GRAPHY_MCP_PORT=8765"
set "OLLAMA_BASE_URL=http://localhost:11434/v1"
set "OLLAMA_API_KEY=ollama"
set "OLLAMA_MODEL=qwen2.5-coder:7b"
set "GRAPHIFY_BACKEND=ollama"

rem --- 3) Derivado de GRAPHY_HOME ---
set "GRAPHIFY_QUERY_LOG=%GRAPHY_HOME%\logs\queries.log"

exit /b 0

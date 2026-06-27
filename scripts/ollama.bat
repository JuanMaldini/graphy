@echo off
setlocal EnableExtensions EnableDelayedExpansion
call "%~dp0_env.bat"

echo ----------------------------------------
echo   Ollama - preparacion
echo ----------------------------------------

rem --- 1) Ollama instalado? ---
where ollama >nul 2>&1
if !errorlevel! neq 0 (
    echo   Ollama no encontrado. Instalando con winget...
    winget install -e --id Ollama.Ollama --accept-source-agreements --accept-package-agreements
    echo   [INFO] Si recien se instalo, cierra y reabre esta consola ^(o reinicia^)
    echo          para que 'ollama' quede en el PATH, y reintenta.
)
where ollama >nul 2>&1
if !errorlevel! neq 0 (
    echo   [ERROR] 'ollama' sigue sin estar en el PATH. Reabri la consola y reintenta.
    endlocal & exit /b 1
)

rem --- 2) Dependencia clave: el backend ollama de graphify usa el paquete 'openai' ---
rem     graphify se instalo como herramienta uv con el nombre 'graphifyy'.
echo   Asegurando dependencias de graphify (Ollama + servidor MCP)...
uv tool install "graphifyy[ollama,mcp]" --force
if !errorlevel! neq 0 (
    echo   [WARN] Fallo 'uv tool install graphifyy[ollama,mcp]'. Proba manualmente:
    echo          uv tool install "graphifyy[ollama,mcp]" --force
)

rem --- 3) Servidor de Ollama corriendo? ---
tasklist /FI "IMAGENAME eq ollama.exe" 2>nul | find /I "ollama.exe" >nul
if !errorlevel! neq 0 (
    echo   Levantando el servidor de Ollama...
    powershell -NoProfile -Command "Start-Process ollama -ArgumentList 'serve' -WindowStyle Hidden"
    timeout /t 4 >nul
)

rem --- 4) VRAM (solo informativo; el modelo lo fija el .env) ---
set "VRAM="
where nvidia-smi >nul 2>&1 && (
    nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits > "%TEMP%\graphy_vram.txt" 2>nul
    set /p VRAM=<"%TEMP%\graphy_vram.txt"
    del "%TEMP%\graphy_vram.txt" 2>nul
)
for /f "tokens=1 delims= " %%a in ("!VRAM!") do set "VRAM=%%a"
set "VNUM=1"
if "!VRAM!"=="" set "VNUM=0"
for /f "delims=0123456789" %%c in ("!VRAM!.") do set "VNUM=0"
if "!VNUM!"=="1" (echo   VRAM detectada: !VRAM! MB) else (echo   VRAM: no se pudo leer ^(no afecta^))

rem --- 5) Modelo: el del .env (fuente unica de verdad, asi pull == uso) ---
set "MODEL=%OLLAMA_MODEL%"
if "!MODEL!"=="" set "MODEL=qwen2.5-coder:7b"
echo   Modelo (de .env): !MODEL!
echo.

echo   Bajando modelo (instantaneo si ya esta)...
ollama pull !MODEL!
if !errorlevel! neq 0 (
    echo   [WARN] Fallo el pull de !MODEL!. Revisa conexion / espacio en disco.
)

echo.
echo   Ollama listo con modelo: !MODEL!
endlocal
exit /b 0

@echo off
setlocal EnableExtensions EnableDelayedExpansion
call "%~dp0_env.bat"

set "PY=%USERPROFILE%\AppData\Roaming\uv\tools\graphifyy\Scripts\python.exe"

if not exist "!PY!" (
    echo [ERROR] No se encontro python en:
    echo         !PY!
    echo         Verifica que graphifyy este instalado: uv tool list
    pause
    exit /b 1
)

echo [INFO] Instalando uvicorn + starlette (HTTP transport)...
"!PY!" -m pip install --quiet uvicorn starlette
if !errorlevel! neq 0 (
    echo [ERROR] Fallo pip install uvicorn starlette
    pause
    exit /b 1
)
echo [OK] uvicorn instalado.

echo [INFO] Instalando watchdog (file-watcher)...
"!PY!" -m pip install --quiet watchdog
if !errorlevel! neq 0 (
    echo [WARN] Fallo pip install watchdog ^(los watchers no funcionaran^)
) else (
    echo [OK] watchdog instalado.
)

echo.
echo Dependencias listas. Ahora podes correr run.bat
pause
endlocal

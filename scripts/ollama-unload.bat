@echo off
rem ============================================================
rem  ollama-unload.bat  -  libera VRAM y cierra Ollama
rem  Se llama al final de start.bat, cuando ya termino de indexar,
rem  para no dejar el modelo cargado ocupando la GPU.
rem ============================================================
setlocal EnableExtensions EnableDelayedExpansion
call "%~dp0_env.bat"

echo ----------------------------------------
echo   Ollama - liberar VRAM y cerrar
echo ----------------------------------------

set "MODEL=%OLLAMA_MODEL%"
if "!MODEL!"=="" set "MODEL=qwen2.5-coder:7b"

where ollama >nul 2>&1
if !errorlevel! equ 0 (
    echo   Descargando el modelo de la memoria: !MODEL!
    rem  'ollama stop' descarga el modelo de la VRAM (no borra nada del disco).
    ollama stop !MODEL! >nul 2>&1
)

echo   Cerrando procesos de Ollama...
rem  La app de bandeja y el servidor; /F por si no responden.
taskkill /IM "ollama app.exe" /F >nul 2>&1
taskkill /IM ollama.exe /F >nul 2>&1

echo   Ollama liberado. La VRAM queda libre.
endlocal
exit /b 0

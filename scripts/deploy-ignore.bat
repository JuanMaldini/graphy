@echo off
setlocal EnableExtensions EnableDelayedExpansion
call "%~dp0_env.bat"

set "TPL=%~dp0..\graphifyignore.template"
if not exist "%TPL%" (
    echo [WARN] No existe la plantilla: %TPL%
    endlocal & exit /b 0
)

echo Desplegando .graphifyignore en cada repo (crea o actualiza si cambio)...
for %%R in ("%GRAPHIFY_REPOS:;=" "%") do (
    set "R=%%~R"
    if exist "!R!" (
        if exist "!R!\.graphifyignore" (
            fc "%TPL%" "!R!\.graphifyignore" >nul 2>&1
            if !errorlevel! equ 0 (
                echo   [OK] al dia -^> !R!\.graphifyignore
            ) else (
                copy /Y "%TPL%" "!R!\.graphifyignore" >nul
                if !errorlevel! equ 0 (echo   [~] actualizado -^> !R!\.graphifyignore) else (echo   [WARN] no se pudo actualizar en !R!)
            )
        ) else (
            copy /Y "%TPL%" "!R!\.graphifyignore" >nul
            if !errorlevel! equ 0 (echo   [+] creado -^> !R!\.graphifyignore) else (echo   [WARN] no se pudo crear en !R!)
        )
    )
)
echo.
echo NOTA: tu .gitignore se respeta SIEMPRE (automatico, ademas de esto).
endlocal
exit /b 0

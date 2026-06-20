@echo off
setlocal EnableExtensions EnableDelayedExpansion
call "%~dp0_env.bat"

echo ========================================
echo   Graphify - Setup / Verificacion
echo ========================================
echo.

echo [1/7] Prerrequisitos
where python >nul 2>&1 && echo   python OK || echo   python MISSING
where git    >nul 2>&1 && echo   git OK    || echo   git MISSING
where winget >nul 2>&1 && echo   winget OK || echo   winget MISSING
where uv     >nul 2>&1 && echo   uv OK     || echo   uv MISSING
where graphify >nul 2>&1 && echo   graphify OK || echo   graphify MISSING
echo.

echo [2/7] Skill Claude Code
call graphify install --platform claude
echo.

echo [3/7] Repo graphify-src
if exist "%GRAPHY_HOME%\graphify-src\.git" (
    echo   Ya clonado
) else (
    git clone https://github.com/safishamsi/graphify.git "%GRAPHY_HOME%\graphify-src"
)
echo.

echo [4/7] .graphifyignore
echo   Se despliega por repo automaticamente (ver deploy-ignore.bat).
echo   Tu .gitignore SIEMPRE se respeta (automatico en graphify).
echo.

echo [5/7] MCP config
if exist "%GRAPHY_HOME%\mcp-configs\claude-desktop.json" (echo   OK) else (echo   MISSING)
echo.

echo [6/7] Tareas programadas
schtasks /query /tn "Graphify MCP Server - Logon"   2>nul >nul && echo   Logon task OK   || echo   Logon task MISSING
schtasks /query /tn "Graphify MCP Server - Startup" 2>nul >nul && echo   Startup task OK || echo   Startup task MISSING
echo.

echo [7/7] Setup completo.
endlocal
exit /b 0

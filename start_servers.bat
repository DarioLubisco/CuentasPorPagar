@echo off
setlocal
title Iniciar Servidores Webdam (Consolidado)

echo ==========================================
echo    INICIANDO TODOS LOS SERVICIOS...
echo ==========================================

:: Llamar al lanzador unificado de MonitorSystem
call "C:\source\MonitorSystem\run_all_servers.bat"

echo.
echo [OK] Servicios iniciados (Monitor activo).
echo.
pause

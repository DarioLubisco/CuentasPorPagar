@echo off
setlocal
title Detener Servidores Webdam

echo ==========================================
echo    DETENIENDO SERVIDORES (Uvicorn/Python)
echo ==========================================

:: Detener procesos de Python (Uvicorn)
echo Deteniendo procesos de Python...
taskkill /F /IM python.exe /T >nul 2>&1

if %errorlevel% equ 0 (
    echo [OK] Procesos de Python detenidos.
) else (
    echo [!] No se encontraron procesos de Python activos.
)

:: Detener procesos de PowerShell (posibles monitores)
echo Deteniendo posibles monitores de PowerShell...
taskkill /F /IM powershell.exe /T >nul 2>&1

echo.
echo ==========================================
echo    TODOS LOS SERVICIOS SE HAN DETENIDO
echo ==========================================
pause
